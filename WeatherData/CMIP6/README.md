# CMIP6 WeatherData Guide

This guide explains how to use the NCL and Python scripts in this folder to process CMIP6 scenarios (ssp119/ssp126/ssp534/ssp585) for:

- Regridding to ERA5 grid
- Computing Cooling Degree Days (CDD)
- Computing heatwave thresholds and indices, and generating multi-model means (MMM)

## System Requirements

### Hardware

- A typical workstation with sufficient disk space and memory (≥32 GB recommended). For large datasets, consider Dask chunking.

### Software

- Recommended OS: Linux (tested on Ubuntu 22.04.1 LTS). On Windows, use WSL2 or adjust paths to Windows drive letters.
- Core tools: NCL and Python.

## Installation & Environment

### NCL Installation (Ubuntu 22.04.1 LTS example)

Install NCL 6.6.2 via conda:

```bash
conda create -n ncl_stable -c conda-forge ncl
conda activate ncl_stable
```

### Python Dependencies

- Recommended Python: 3.11
- Main libraries:
  - numpy==2.1.3
  - xarray==2025.4.0
  - netCDF4==1.7.2
  - dask, distributed (for lazy/chunked computation)
  - tqdm (progress bar)

Example environment setup (aligned with WeatherData/CDD, plus dask/tqdm):

```bash
# Create env
conda create -n weatherdata python=3.11 -y
conda activate weatherdata

# Install core deps via conda-forge
conda install -c conda-forge \
    numpy==2.1.3 \
    netCDF4==1.7.2 -y

# Optional: match CDD folder fully
# conda install -c conda-forge geopandas==1.1.1 shapely==2.0.6 rioxarray==0.19.0 rasterio==1.4.3 -y

# Pip packages
pip install xarray==2025.4.0 dask distributed tqdm
```

Note: Scripts contain hard-coded Windows drive letters (e.g., `F:/`, `X:/`) and Linux mount paths (e.g., `/mnt/f`, `/mnt/x`). Unify them for your environment.

## Data Sources & Download

- ERA5 reanalysis:
  [https://cds.climate.copernicus.eu/datasets/reanalysis-era5-single-levels?tab=download](https://cds.climate.copernicus.eu/datasets/reanalysis-era5-single-levels?tab=download)
- CMIP6 model data:
  [https://esgf-node.ipsl.upmc.fr/search/cmip6-ipsl/](https://esgf-node.ipsl.upmc.fr/search/cmip6-ipsl/)
- Supplementary test data (to be provided with the study):
  - ERA5 2 m temperature (1990–2019)
  - CMIP6 CanESM5, SSP119 daily tas (2015–2100): `tas_day_CanESM5_ssp119_r1i1p1f1_gn_20150101-21001231`

## Scripts Overview

- Regrid to ERA5 (NCL): `cmip6_new_grid.ncl`
- CDD calculation (Python): `cmip6_Cooling_Degree_days.py`
- CDD multi-model mean (NCL): `cmip6_CDD_ensemble_mean.ncl`
- Heatwave threshold (Python): `cmip6_heatwave_threshold.py`
- Heatwave indices (Python): `cmip6_heatwave_indexes.py`
- Heatwave MMM (NCL): `cmip6_heatwave_indexes_ensemble_mean.ncl`

## Paths & Naming (adjust as needed)

Key paths/parameters in scripts (edit to match local data locations):

- `cmip6_new_grid.ncl`
  - Input CMIP6 daily tas: `/mnt/f/CMIP6/daily/{scenario}/{model}/tas_day_{model}_{scenario}_r1i1p1f1_*.nc`
  - Target grid (from ERA5 example file): `/mnt/f/Reanalysis/ERA5/hourly/daily/2m_temperature/ERA5-Land_daily_2m_temperature_0.1_1990_01.nc`
  - Output (regridded): `/mnt/f/CMIP6/daily/new_grid/{scenario}/tas_day_{model}_{scenario}_r1i1p1f1_0.1_YYYYMMDD-YYYYMMDD.nc`

- `cmip6_Cooling_Degree_days.py`
  - Input: `base_path = 'F:/CMIP6/daily/new_grid/'`
  - Output: `output_dir = 'X:/CMIP6_SSP/new_CDD/'`
  - Variable/threshold: `variable='tas'` (K), `threshold=18.3` (°C)
  - Years:
    - ssp119/ssp126/ssp585: 2023–2050
    - ssp534: 2040–2050

  Note (what to replace with):
  - Replace `base_path` with the absolute folder containing regridded CMIP6 daily tas files, organized as `{scenario}/tas_day_{model}_{scenario}_r1i1p1f1_0.1_YYYY..._new.nc`.
    - Windows example: `F:/CMIP6/daily/new_grid/`
    - WSL/Linux example: `/mnt/f/CMIP6/daily/new_grid/`
  - Replace `output_dir` with the absolute folder where CDD results will be written. Ensure it exists or the script can create it.
    - Windows example: `X:/CMIP6_SSP/new_CDD/`
    - WSL/Linux example: `/mnt/x/CMIP6_SSP/new_CDD/`

- `cmip6_CDD_ensemble_mean.ncl`
  - Input: `/mnt/x/CMIP6_SSP/new_CDD/{scenario}/CDD_*_{scenario}_18.3degC_YYYY-YYYY.nc`
  - Output: `/mnt/x/CMIP6_SSP/new_CDD/CDD_{scenario}_MMM_18.3degC_YYYY-YYYY.nc`

- `cmip6_heatwave_threshold.py`
  - ERA5 path: `base_path_era5 = 'F:/Reanalysis/ERA5/hourly/daily/2m_temperature/'`
  - CMIP6 regridded data: `base_path_cmip6 = 'F:/CMIP6/daily/new_grid/'`
  - Threshold output: `output_base = 'X:/CMIP6_SSP/new_HWD/thresholds/'`
  - Percentile: `per = 95` (P95 dynamic thresholds)
  - Threshold windows:
    - 2000–2029: ERA5 (2000–2014) + CMIP6 (2015–2029)
    - 2010–2039: ERA5 (2010–2014) + CMIP6 (2015–2039)
    - 2020–2050: CMIP6 (2020–2050)
    - ssp534 special: CMIP6 (ssp585 2020–2039 + ssp534 2040–2050)

  Note (what to replace with):
  - Replace `base_path_era5` with the absolute folder containing ERA5 daily 2-m temperature files named like `ERA5-Land_daily_2m_temperature_0.1_{YYYY}_{MM}.nc`.
    - Windows example: `F:/Reanalysis/ERA5/hourly/daily/2m_temperature/`
    - WSL/Linux example: `/mnt/f/Reanalysis/ERA5/hourly/daily/2m_temperature/`
  - Replace `base_path_cmip6` with the absolute folder containing regridded CMIP6 daily tas, organized under scenario subfolders.
    - Windows example: `F:/CMIP6/daily/new_grid/`
    - WSL/Linux example: `/mnt/f/CMIP6/daily/new_grid/`
  - Replace `output_base` with the absolute folder where threshold NetCDFs will be written (`threshold_{scenario}_{model}_{period}.nc`). Ensure it exists.
    - Windows example: `X:/CMIP6_SSP/new_HWD/thresholds/`
    - WSL/Linux example: `/mnt/x/CMIP6_SSP/new_HWD/thresholds/`

- `cmip6_heatwave_indexes.py`
  - Thresholds dir: `threshold_base = 'X:/CMIP6_SSP/new_HWD/thresholds/'`
  - CMIP6 data dir: `cmip6_base = 'F:/CMIP6/daily/new_grid/'`
  - Output dir: `output_base = 'X:/CMIP6_SSP/new_HWD/heatwaves/'`
  - Defaults: `per=95`, `dur=2` (heatwave if consecutive days ≥2)
  - Period mapping:
    - ssp119/ssp126/ssp585:
      - Heatwave 2025–2029 → Threshold 2000–2029
      - Heatwave 2030–2039 → Threshold 2010–2039
      - Heatwave 2040–2050 → Threshold 2020–2050
    - ssp534: Heatwave 2040–2050 → Threshold 2020–2050
  - Output name: `{scenario}_{model}_heatwave_{per}p_{dur}d_{heatwave_period}_thresh{threshold_period}.nc`

- `cmip6_heatwave_indexes_ensemble_mean.ncl`
  - Input: `/mnt/x/CMIP6_SSP/new_HWD/heatwaves/{scenario}_*_{per}p_{dur}d_2040-2050_thresh2020-2050.nc`
  - Output: `/mnt/x/CMIP6_SSP/new_HWD/{scenario}_MMM_heatwave_{per}p_{dur}d_2040-2050_thresh2020-2050.nc`

## Workflow

### 1. Regrid CMIP6 to ERA5 grid

Resample CMIP6 daily tas to match ERA5 0.1° grid and lat/lon convention.

```bash
ncl cmip6_new_grid.ncl
```

Outputs should appear under `.../CMIP6/daily/new_grid/{scenario}/` as annual NetCDF chunks:
`tas_day_{model}_{scenario}_r1i1p1f1_0.1_YYYY0101-YYYY1231.nc`

### 2. Cooling Degree Days (CDD)

Compute annual CDD sums from regridded tas (in K). Default threshold is 18.3°C (converted to K in the script).

```bash
python cmip6_Cooling_Degree_days.py
ncl cmip6_CDD_ensemble_mean.ncl
```

- Per-scenario outputs:
  - Single-model: `X:/CMIP6_SSP/new_CDD/{scenario}/CDD_{model}_{scenario}_18.3degC_2023-2050.nc` (ssp534: 2040–2050)
  - Multi-model mean: `X:/CMIP6_SSP/new_CDD/CDD_{scenario}_MMM_18.3degC_2023-2050.nc` (ssp534: 2040–2050)

### 3. Heatwave thresholds & indices

Compute dynamic P95 thresholds and heatwave metrics (days, events, max duration, etc.) using consecutive-day logic (default dur=2).

```bash
# 3.1 Thresholds
python cmip6_heatwave_threshold.py

# 3.2 Heatwave indices (batch by period/threshold mapping)
python cmip6_heatwave_indexes.py

# 3.3 Multi-model mean (example: 2040–2050 outputs)
ncl cmip6_heatwave_indexes_ensemble_mean.ncl
```

- Threshold outputs: `X:/CMIP6_SSP/new_HWD/thresholds/threshold_{scenario}_{model}_{period}.nc`
- Heatwave outputs: `X:/CMIP6_SSP/new_HWD/heatwaves/{scenario}_{model}_heatwave_95p_2d_{heatwave_period}_thresh{threshold_period}.nc`
- MMM outputs: `X:/CMIP6_SSP/new_HWD/{scenario}_MMM_heatwave_95p_2d_2040-2050_thresh2020-2050.nc`

## Notes & Tips

- Coordinate consistency: latitude order is handled, but ensure exact lat/lon match between thresholds and CMIP6 inputs (tolerance ~1e-4).
- Units & thresholds: CMIP6/ERA5 temperatures are in K. CDD uses 18.3°C converted to K (tas - (18.3 + 273.15)).
- Chunking & memory: `cmip6_heatwave_threshold.py` and `cmip6_heatwave_indexes.py` use Dask chunks and a ProgressBar; tune chunk sizes for your memory.
- NetCDF engine: `engine='netcdf4'` is used for performance/compatibility; if errors occur, consider `h5netcdf`.
- Path unification: Use either Linux/WSL mounts (`/mnt/f`, `/mnt/x`) or Windows drives (`F:/`, `X:/`) consistently.

## FAQ

- Input files or output dirs not found: check `base_path`/`output_base`/`output_dir` in script headers and create directories as needed.
- Latitude/longitude mismatch: ensure regridding is completed and the same regridded grid is used across threshold and index steps.
- NetCDF open failures: verify files with `ncdump -h` or `xarray.open_dataset`, and check permissions.
- Performance and memory: reduce year ranges, adjust chunk sizes, or use Dask distributed.
- Known issue: in `cmip6_heatwave_threshold.py`, a variable name typo may raise an error (`combined3 = combined3.chunk(...)`). Replace it with chunking on the correct variable (`combined2 = combined2.chunk(...)`) before computing.

## Reproducibility & Validation

- Start with the supplementary test subset (CanESM5/ssp119 + ERA5 sample) to validate the workflow and outputs:
  - CDD: `CDDyear(time, latitude, longitude)`
  - Heatwaves: `hwd/hotday/hwtimes/hwmax(time, latitude, longitude)`
- Then scale up to all models and scenarios, and compute MMM for comparisons.

---

To experiment with different percentiles, durations, or windows, adjust `per`, `dur`, and period mappings in `cmip6_heatwave_threshold.py` and `cmip6_heatwave_indexes.py` accordingly.
