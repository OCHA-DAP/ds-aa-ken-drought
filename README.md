# Kenya Drought Anticipatory Action Trigger

Early warning system for drought in Kenya's arid counties, developed for OCHA's anticipatory action (AA) framework. The project analyzes Kenya Meteorological Department (KMD) seasonal forecasts, ERA5 rainfall observations, and climate drivers (Indian Ocean Dipole) to define and evaluate drought activation triggers for the October–November–December (OND) season.

## Background

The trigger system targets 9 arid counties in Kenya: Baringo, Mandera, Isiolo, Wajir, Garissa, Marsabit, Turkana, Tana River, and Samburu. Forecasts are issued at three lead times (July, August, September) and evaluated against 1-in-3-year (RP3) and 1-in-5-year (RP5) drought return periods. Activation thresholds are adjusted based on the state of the Indian Ocean Dipole (IOD), which is a known driver of East Africa rainfall variability.

## Repository Structure

```
ds-aa-ken-drought/
├── analysis/                          # Jupyter notebooks
│   ├── 01.0_review_kmd_hindcasts.ipynb          # Core hindcast review and trigger evaluation
│   ├── 01.1_review_climate_drivers.ipynb         # IOD analysis and persistent negative IOD identification
│   ├── 01.3_testing_forecast_behaviour_leadtime.ipynb  # Lead-time variability by IOD state
│   └── 01.4_review_kmd_hindcasts_with_iod.ipynb # Hindcast review with IOD-adjusted thresholds
├── exploration/
│   └── spi_compute.R                  # SPI-1 and SPI-3 computation from ERA5 data
├── src/                               # Python package
│   ├── datasources/
│   │   └── era5.py                    # ERA5 rainfall data fetcher
│   └── utils/
│       ├── constants.py               # Arid counties, thresholds, geographic constants
│       ├── db_utils.py                # Azure PostgreSQL connection utilities
│       ├── helpers.py                 # Return period computation
│       └── parser.py                  # CPT format hindcast file parser
├── pyproject.toml
└── requirements.txt
```

## Analysis Notebooks

| Notebook | Description |
|---|---|
| `01.0_review_kmd_hindcasts` | Loads and parses KMD CPT hindcast files, maps forecast probabilities spatially, identifies trigger activation years at RP3 and RP5 thresholds, and validates against ERA5 observations |
| `01.1_review_climate_drivers` | Analyzes weekly IOD (DMI) data from BoM, identifies persistent negative IOD events (≥8 consecutive weeks at DMI ≤ −0.4), and flags activation dates |
| `01.3_testing_forecast_behaviour_leadtime` | Evaluates how forecast probability varies across lead times and whether variability differs in negative IOD vs. normal years |
| `01.4_review_kmd_hindcasts_with_iod` | Repeats the hindcast review applying IOD-state-aware activation thresholds |

## Trigger Thresholds

Thresholds represent the minimum county-level probability of below-normal rainfall required for trigger activation.

| Return Period | Climate State | July | August | September |
|---|---|---|---|---|
| RP5 (1-in-5) | Non-negative IOD | 40% | 35% | 35% |
| RP5 (1-in-5) | Negative IOD | 35% | 30% | 30% |
| RP3 (1-in-3) | Non-negative IOD | 60% | 50% | 50% |
| RP3 (1-in-3) | Negative IOD | 50% | 45% | 45% |

## Data Sources

| Source | Description | Access |
|---|---|---|
| KMD hindcasts | Seasonal forecast probabilities in CPT format (July/Aug/Sep) | Azure blob storage: `ds-aa-ken-drought/raw/` |
| ERA5 rainfall | Daily/monthly precipitation observations by county | Azure PostgreSQL (production) |
| IOD (DMI) | Weekly Dipole Mode Index from Bureau of Meteorology | `ds-aa-ken-drought/raw/iod.csv` / [BoM](https://www.bom.gov.au/clim_data/IDCK000072/iod_1.txt) |
| Admin boundaries | Kenya admin levels 0–2 shapefiles | FieldMaps COD API |

## Setup

### Python

Requires Python ≥ 3.8.

```bash
pip install -e .
pip install -r requirements.txt
```

Set the following environment variables (e.g., in a `.env` file) for database access:

```
DSCI_AZ_DB_PROD_PW=...
DSCI_AZ_DB_PROD_UID=...
DSCI_AZ_DB_DEV_PW=...
DSCI_AZ_DB_DEV_UID=...
```

### R

Run the install script to set up all R dependencies:

```r
source("exploration/install_packages.R")
```

## Key Dependencies

- [`ocha_stratus`](https://github.com/OCHA-DAP/ocha-stratus) — OCHA cloud storage and geospatial utilities
- `geopandas` — spatial operations and mapping
- `xarray` / `netcdf4` — climate data handling
- `sqlalchemy` — Azure PostgreSQL connectivity
- `SPEI` (R) — Standardized Precipitation Index computation

## Contact

Pauline Ndirangu — pauline.ndirangu@un.org — OCHA Centre for Humanitarian Data
