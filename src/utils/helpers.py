import numpy as np
def compute_return_period(df):
    df = df.sort_values("season_total_mm", ascending=True).copy()
    df["rank"] = np.arange(1, len(df) + 1)
    df["return_period"] = (len(df) + 1) / df["rank"]
    return df
