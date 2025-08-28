# Regression Codes Guide

## System Requirements

### Hardware Requirements

- A standard computer or laptop with sufficient RAM for regression analysis.

### Software Requirements

- Stata 17 (SE/MP recommended). This repository was developed and tested with Stata 17 MP.
- OS: Windows 10/11 or macOS/Linux (any OS supported by Stata 17). Examples below use Windows.
- Stata installation/download: [https://www.stata.com/](https://www.stata.com/)


## Data and Folder Structure

This folder contains the main script, input datasets, and newly added files:

- `Code.do` — Main Stata do-file for regression analysis and figure generation.
- `Data 1. Main.dta` — Main analysis dataset.
- `Data 2.  GVC components .dta` — GVC components dataset.
- `Data_3_Channel3_Sectoral_labor_hours.dta` — NEW: Sectoral labor hours data.
- `Marginal effect_Fig.1e_26_sector_hwd_50P.gph` — NEW: Marginal effect graph (26 sectors, 50P heat exposure).
- `Marginal effect_Fig.1f_6_sector_hwd_50P.gph` — NEW: Marginal effect graph (6 sectors, 50P heat exposure).
- `Marginal effect_Fig.1g_26_sector_hwd_90P.gph` — NEW: Marginal effect graph (26 sectors, 90P heat exposure).
- More new data and figure files are available in this directory.

Outputs (figures) are saved to `Regression/regression_figures/` as `.gph` files.

## Quick Start

1. Open Stata.
2. Set the working directory to this folder `Regression/regression_codes`.
   - In Stata Command window: use `cd` to point to this directory.
3. Run the entire do-file `Code.do`.
   - In the Do-file Editor, click "Do"; or in the Command window: `do Code.do`.
4. Upon completion, check the generated `.gph` figures under `Regression/regression_figures/`.

## Command-line (Windows, optional)

If you prefer batch mode from Windows Command Prompt (cmd):

```bat
StataMP-64.exe -b do Code.do
```

- Replace `StataMP-64.exe` with `StataSE-64.exe` or your installed edition name as appropriate.
- `-b` runs in batch mode and writes a log file in the current directory.

## Notes and Tips

- Stata version: 17. If you see version mismatch warnings, ensure your Stata is version 17 and that the do-file does not enforce an older `version` statement incompatible with 17.
- Working directory: If Stata reports `file not found`, confirm you have set `cd` to `Regression/regression_codes` and that data files are present with the exact filenames listed above.
- User-written packages: If the do-file uses community commands (e.g., `esttab/estout`, `outreg2`), install them first:
  - In Stata: `ssc install estout, replace` and/or `ssc install outreg2, replace`.
- Reproducibility: Keep the relative folder structure unchanged so that file paths in the do-file resolve correctly.

## Outputs

- Regression figures will be exported as `.gph` files to `Regression/regression_figures/`.
- If you need image formats (e.g., PNG/PDF), you can open each `.gph` in Stata and export via `graph export`.

## Troubleshooting

- Encoding/filenames: Paths with spaces are supported, but ensure they are quoted in Stata commands if you adapt paths.
- Permissions: If Stata cannot write outputs, verify write permission for the repository folders.
