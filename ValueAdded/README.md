# ValueAdded Calculation Guide

## System Requirements

### Hardware Requirements

- Standard workstation; 16 GB RAM or more is recommended due to 4940×4940 matrix inversions (Leontief inverse) and large dense arrays.

### Software Requirements

- Recommended OS: Windows 10/11 or Linux (recent distributions). Scripts use Python only.
- Core tools: Python with NumPy and pandas.

## Installation Guide

### Python Environment (conda on Windows cmd example)

```cmd
:: Create and activate environment
conda create -n valueadded python=3.11 -y
conda activate valueadded

:: Install dependencies
conda install -c conda-forge numpy pandas -y
```

Notes

- Python 3.8 or newer works (3.9–3.11 recommended).
- If not using conda, you can also run: `pip install numpy pandas`.


## Data and Directory Layout

Data availability: The datasets used here are published at Zenodo DOI: [10.5281/zenodo.16964992](https://doi.org/10.5281/zenodo.16964992). After downloading, place the files in the `ValueAdded/` directory to run the scripts.

- Working directory: scripts use the current working directory (`os.getcwd()`). Run them from `ValueAdded/` or ensure required files are in the active folder.
- Required inputs (file name patterns are fixed):
  - `Eora26_YYYY_bp.csv` for 1990–2022; matched by regex `Eora26_\d+_bp.csv`.
  - Additional files for `3.1-GVC_prod_simple.py`:
    - `comparative advantage/total/production-based EVA total.csv` (production-based EVA totals by year)
    - `Eora26_1999_bp.csv` (used only to extract country/sector labels)

Note specific to script 2.1

- Script `2.1-production_based CA_total_sep.py` uses repository-relative paths rooted at `ValueAdded/../data/` by default:
  - Inputs it expects:
    - `data/Eora_all_csv/` (used only to enumerate years by filename stem, e.g., `Eora26_1990_bp.csv` → `1990`)
    - `data/separate row/Eora_embodied value added/total/{stem}_embodied value added.csv` (outputs from Step 1)
  - Outputs it writes:
    - `data/separate row/comparative advantage/total/production-based EVA total.csv`
    - `data/separate row/comparative advantage/total/production-based EVA total_growth.csv` (log-diff growth rates)
  - You can change these locations by editing the constants at the top of `2.1-production_based CA_total_sep.py`.

Assumed Eora26 layout

- Total industries: 190 countries × 26 sectors = 4940 rows/columns.
- Intermediate use matrix Z: rows 3:4943, cols 4:4944 (after initial row drop in pandas). A tiny diagonal jitter is applied to avoid singularity.
- Primary inputs V: rows 4943:4949, cols 4:4944; VA is the column sum (per industry) of V; X = VA + column-sum(Z).
- Final demand Y: rows 3:4943, cols 4944:6084; every 6 columns form one country’s final demand categories and are aggregated to one column.

## Calculation Workflow

Run the scripts in the following order.

### 1) Embodied Value Added (EVA)

Script: `1-embodied value added_sep.py`

- Purpose:
  - Build A = Z · diag(X)^(-1), compute Leontief inverse L = (I − A)^(-1) (pseudo-inverse), aggregate final demand columns by 6, and compute `V_embodied = diag(V/X) · L · Y_aggregated`.
- Inputs: all `Eora26_YYYY_bp.csv` files in the working directory.
- Outputs (per year):
  - `Eora_embodied value added/total/Eora26_YYYY_bp.csv_embodied value added.csv`
- File structure:
  - Leftmost 4 columns are labels copied from the IO table.
  - A top row of country names is added as a visual column-group label (first 4 cells are blank).
  - Data block is 4940×190 (industry × demand country EVA).

Run (Windows cmd)

```cmd
python "1-embodied value added_sep.py"
```

### 2) EVA totals and growth rates for regression (Eq. 14–15: EVA_total / EVA_imt)

Script: `2.1-production_based CA_total_sep.py`

- Purpose:
  - Aggregate production-based EVA totals by year into a single table (industry × year) and prepare dependent variables for Eq. (14) and Eq. (15) in the Manuscript.
  - Compute growth rates as log-differences: Δln(EVA) per industry between adjacent years, for regression use.
- Inputs:
  - Yearly files from Step 1 under `data/separate row/Eora_embodied value added/total/` with names like `{stem}_embodied value added.csv`.
  - A year enumeration folder `data/Eora_all_csv/` containing files like `Eora26_YYYY_bp.csv` (only stems are used to list years).
- Outputs:
  - `data/separate row/comparative advantage/total/production-based EVA total.csv` (levels)
  - `data/separate row/comparative advantage/total/production-based EVA total_growth.csv` (log-diff growth)

Run (Windows cmd)

```cmd
python "2.1-production_based CA_total_sep.py"
```

### 3) GVC Component Decomposition (variables for Manuscript Eq. 16–17)

Script: `3.1-GVC_prod_simple.py`

- Purpose:
  - For each year, construct Cr = diag(V/X), A, and B = (I − A)^(-1); extract diagonal/off-diagonal blocks and compute components:
    - PART1: Cr · L_rr · Y_rr
    - PART2: Cr · L_rr · Σ_s[ A_rs · Σ_u( B_su · Y_ur ) ]
    - PART3: Cr · L_rr · Σ_s( Y_rs )
    - PART4: Cr · L_rr · Σ_s( A_rs · L_ss · Y_ss )
    - PART5: Residual = Total (production-based EVA) − PART1 − PART2 − PART3 − PART4
  - These components serve as dependent variables for Eq. (16) and Eq. (17) in the Manuscript.
- Additional inputs:
  - `comparative advantage/total/production-based EVA total.csv`
  - `Eora26_1999_bp.csv`
- Output:
  - Writes to a relative path under the working directory:
    `output/comparative advantage/GVC-prod.csv`
  - The output folder is created automatically if it does not exist.
- Column layout (logical expectation):
  - First two columns: country and sector labels.
  - For each year, columns appended in blocks: [Total, PART1, PART2, PART3, PART4, PART5].

Run (Windows cmd)

```cmd
python "3.1-GVC_prod_simple.py"
```

Note

- The list used to construct the first row of “column labels” is defined as `parts = ["PART1", "PART1", "PART3", "PART4", "PART5"]`. This does not include `TOTAL` and duplicates `PART1`, which only affects the label row, not the numeric results. If needed, modify it to `["TOTAL","PART1","PART2","PART3","PART4","PART5"]` and adjust the write-out accordingly.

### 4) Sector Market Concentration (HHI)

Script: `4. HHI.py`

- Purpose:
  - Based on intermediate inputs Z, zero out each 26×26 domestic block (diagonal), then compute:
    - Import-based HHI (by column shares of sources)
    - Export-based HHI (by row shares of destinations)
  - Used as the dependent variables in the “Sector market concentration” section of the Manuscript.
- Inputs: all `Eora26_YYYY_bp.csv` files in the working directory.
- Outputs:
  - `HHI/HHI_import.csv`
  - `HHI/HHI_export.csv`
- File structure:
  - First row is a year label row (first 4 cells blank to align with label columns).
  - Leftmost 4 columns are labels; the data block is 4940×33 (years 1990–2022).

Run (Windows cmd)

```cmd
python "4. HHI.py"
```

## Tips and Notes

- Hard-coded paths: `3.1-GVC_prod_simple.py` writes to an absolute drive path. Change to a relative path under the repo (e.g., `ValueAdded/output/`). Ensure the folder exists before writing.
- “Header rows” are written as the first data row: scripts write a pseudo-header as row 1 instead of using `header=True`. When reading, skip the first row or assign your own header.
- Performance: if memory/time is tight, run fewer years at once (temporarily keep only selected `Eora26_YYYY_bp.csv` files in the working directory), or increase RAM. Large pseudo-inverses dominate runtime.
- Consistency of label rows: the `parts` list in `3.1-GVC_prod_simple.py` is only for the label row and does not affect numeric outputs.

## Minimal Reproduction Steps

1) Place all `Eora26_YYYY_bp.csv` in the working folder for Step 1 and run it to produce yearly EVA files under `Eora_embodied value added/total/`.
2) For Step 2.1, ensure the following relative paths exist under the repo root: `data/Eora_all_csv/` and `data/separate row/Eora_embodied value added/total/` (copy or link the needed files). Run `2.1-production_based CA_total_sep.py` to generate the two outputs under `data/separate row/comparative advantage/total/`.
3) Place `comparative advantage/total/production-based EVA total.csv` and `Eora26_1999_bp.csv` in the working folder for Step 3.1 (or adjust paths) and run `3.1-GVC_prod_simple.py` to produce `output/comparative advantage/GVC-prod.csv`.
4) Run `4. HHI.py` to generate `HHI/HHI_import.csv` and `HHI/HHI_export.csv`.

## License

Follow the repository root `LICENSE`.
