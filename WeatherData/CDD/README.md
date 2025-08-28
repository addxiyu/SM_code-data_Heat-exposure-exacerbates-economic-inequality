# WeatherData Calculation Guide

## System Requirements

### Hardware Requirements

- A standard computer with sufficient RAM for data processing.

### Software Requirements

- Recommended OS: Linux (tested on Ubuntu 22.04.1 LTS)
- Core tools: NCL and Python for meteorological data processing.

## Installation Guide

### NCL Installation (Ubuntu 22.04.1 LTS example)

It is recommended to install NCL 6.6.2 using conda.

```bash
conda create -n ncl_stable -c conda-forge ncl
conda activate ncl_stable
```

Installation takes about 30 minutes.

### Python Dependencies

- Recommended Python version: 3.11

- Main scientific libraries:

  - numpy Version == 2.1.3
  - xarray Version == 2025.4.0
  - netCDF4 Version == 1.7.2
  - geopandas Version == 1.1.1
  - shapely Version == 2.0.6
  - rioxarray Version == 0.19.0
  - rasterio Version == 1.4.3  

Following bash script could be use to configure the environment when using conda.  

```bash  
# bash  
# Create environment with Python 3.11
conda create -n weatherdata python=3.11 -y
conda activate weatherdata

# Step 1: Install most dependencies via conda-forge
conda install -c conda-forge \
    numpy==2.1.3 \
    netCDF4==1.7.2 \
    geopandas==1.1.1 \
    shapely==2.0.6 \
    rioxarray==0.19.0 \
    rasterio==1.4.3 -y

# Step 2: Install packages with unusual version requirements via pip
pip install xarray==2025.4.0
```

## Calculation Workflow

### 1. Heatwave Index Calculation

1. Calculate percentile-based thresholds of surface temperature within a specified time range and save as a NetCDF file.

   ```bash
   python heatwave_threshold.py
   ```

2. Compute heatwave indices (Heatwave Days, Heatwave Times, Maximum Heatwave Days, etc.) using the pre-calculated thresholds.

   ```bash
   python heatwave_indexes.py
   ```

3. Compute population-weighted results for the heatwave indices.

   ```bash
   ncl heatwave_indexes_Population_weighted.ncl
   ```

### 2. Cooling Degree Days (CDD)

1. Compute the CDD index based on the given threshold and save as a NetCDF file.

   ```bash
   python Cooling_Degree_days.py
   ```

2. Compute population-weighted results for the CDD index.

   ```bash
   ncl CDD_Population_weighted.ncl
   ```

### 3. Standardized Precipitation Index (SPI)

1. Compute monthly precipitation anomalies and population-weighted results, and save as a NetCDF file.

   ```bash
   ncl Precip_anomaly_and_Population_weighted.ncl
   ```

2. Compute SPI for each country and year, and classify precipitation scenarios based on SPI values.

   ```bash
   python Standard_Precip_Index_Classification.py
   ```
