import re
import pandas as pd

def parse_cpt_lines(lines):
    def is_numeric_line(ln):
        return bool(re.match(r"^\s*-?\d+(\.\d+)?(\s+-?\d+(\.\d+)?)+$", ln.strip()))

    def clean_T(tval):
        if tval is None:
            return None
        m = re.match(r"(\d{4})-(\d{2})/(\d{2})", tval)
        if not m:
            return None
        year, m1, m2 = m.groups()
        return f"{year}-{m1}-01"

    all_blocks = []
    current_meta = []
    current_pixels = []
    state = "meta"

    for ln in lines:
        if ln.lstrip().startswith("cpt:"):
            if state == "pixel" and current_pixels:
                all_blocks.append((current_meta, current_pixels))
                current_meta = []
                current_pixels = []
            current_meta.append(ln)
            state = "meta"
            continue
        if is_numeric_line(ln):
            current_pixels.append(ln)
            state = "pixel"
            continue

    if current_pixels:
        all_blocks.append((current_meta, current_pixels))

    dfs = []
    last_T = None

    drop_keys = {"field", "thrsh", "nrow", "ncol", "row", "col", "units", "missing"}

    for meta_lines, pix_lines in all_blocks:
        meta = {}
        for ln in meta_lines:
            clean = ln.replace("cpt:", "")
            parts = [p.strip() for p in clean.split(",")]
            for p in parts:
                if "=" in p:
                    k, v = p.split("=", 1)
                    meta[k.strip()] = v.strip()

        if "T" in meta:
            meta["T"] = clean_T(meta["T"])
            last_T = meta["T"]
        else:
            meta["T"] = last_T

        below = meta.pop("clim_prob_blw", None)
        above = meta.pop("clim_prob_abv", None)

        if below is not None:
            meta["clim_prob"] = below
            meta["clim_prob_type"] = "below"
        elif above is not None:
            meta["clim_prob"] = above
            meta["clim_prob_type"] = "above"

        for key in drop_keys:
            meta.pop(key, None)

        lon_parts = pix_lines[0].split()
        lons = list(map(float, lon_parts))

        lat_vals = []
        pixel_vals = []
        for ln in pix_lines[1:]:
            parts = ln.split()
            lat_vals.append(float(parts[0]))
            pixel_vals.append(list(map(float, parts[1:])))

        rows = []
        for i, lat in enumerate(lat_vals):
            for j, lon in enumerate(lons):
                row = {"lat": lat, "lon": lon, "value": pixel_vals[i][j]}
                for k, v in meta.items():
                    row[k] = v
                rows.append(row)

        dfs.append(pd.DataFrame(rows))

    return dfs
