# SM_code&data_Heat-exposure-exacerbates-economic-inequality

Source code and datasets for the publication of "Heat exposure exacerbates economic inequality through cascading losses in global trade"

## Table of Contents

<details>
 <summary><strong>1. <a href="#1-valueadded">ValueAdded</a> <em>(Value Added Accounting)</em></strong></summary>
 <ul>
  <li>Contains code and data for calculating the implicit value added, used as the explained variable in regression analyses.</li>
 </ul>
</details>
<details>
 <summary><strong>2. <a href="#2-weatherdata">WeatherData</a> <em>(Meteorological Data Preprocessing)</em></strong></summary>
 <ul>
  <li>Scripts and datasets for preprocessing meteorological data, providing explanatory variables for regression models.</li>
 </ul>
</details>
<details>
 <summary><strong>3. <a href="#3-regression">Regression</a> <em>(Regression Model Construction)</em></strong></summary>
 <ul>
  <li>Construction and implementation of regression models, including processing of additional explanatory variables.</li>
 </ul>
</details>
<details>
 <summary><strong>4. <a href="#4-analysis">Analysis</a> <em>(Regression Results Analysis)</em></strong></summary>
 <ul>
  <li>Analysis of regression results, focusing on uncertainty in estimating losses due to heat exposure.</li>
 </ul>
</details>

This repository is organized into four main sections:

---

### 1. ValueAdded

Contains code and data for calculating the implicit value added, used as the explained variable in regression analyses.

---

### 2. WeatherData

Scripts and datasets for preprocessing meteorological data, providing explanatory variables for regression models.

---

### 3. Regression

Construction and implementation of regression models, including processing of additional explanatory variables.

---

### 4. Analysis

Analysis of regression results, focusing on uncertainty in estimating losses due to heat exposure.

---

## System & Software Requirements (brief)

- OS: Windows 10/11 (preferred); macOS/Linux generally supported
- Python: 3.8+ (Anaconda recommended); common packages: pandas, numpy, openpyxl, jupyter
- Stata: 15+ (for running `.do` files in `Regression`)
- NCL (NCAR Command Language): 6.6+ (for `.ncl` scripts under `WeatherData/`)
- Optional: Tableau Desktop (to open `.twbx`), Microsoft Excel (to view `.xlsx`)

---

## Instruction for use

- Each subdirectory includes a more detailed README with run instructions—please refer to the corresponding README first.

- **ValueAdded** - Explained Variable Preparation
  - Provides code and data for calculating the implicit value added, which is used as the explained (dependent) variable in the regression model.
  - Inputs: packaged accounting/trade datasets in this repo (see `ValueAdded/`)
  - Outputs: implicit value added by country–sector (CSV/Excel) for downstream regression
  - Key scripts: `1-embodied value added_sep.py`, `2.1-production_based CA_total_sep.py`, `3.1-GVC_prod_simple.py`, `4. HHI.py`

- **WeatherData** - Explanatory Variable Preparation
  - Includes scripts and datasets for preprocessing meteorological data, supplying the main explanatory (independent) variables for the regression model.
  - Inputs: raw meteorological datasets under `WeatherData/` (e.g., `CDD/`, `CMIP6/`)
  - Outputs: aggregated heat-exposure indicators aligned by country/sector/time for regression use
  - Key scripts: e.g., `CDD/CDD_Population_weighted.ncl` (population-weighted metrics)

- **Regression** - Model Construction & Variable Integration
  - Contains the construction and implementation of regression models, integrating both explained and explanatory variables, and handling additional control variables.
  - Inputs: outputs from `ValueAdded` and `WeatherData`, plus additional controls provided in `regression_codes/`
  - Outputs: estimates and figures saved to `regression_figures/`
  - Key script: `regression_codes/regression_main.do`

- **Analysis** - Results & Uncertainty Assessment
  - Analyzes regression outputs, focusing on the uncertainty and robustness of heat exposure loss estimates.
  - Contents: result tables (`.xlsx`), notebook `Process.ipynb`, and optional visualizations (`.twbx`)
