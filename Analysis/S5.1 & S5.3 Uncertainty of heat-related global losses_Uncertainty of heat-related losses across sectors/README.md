# Projected dynamics and uncertainty — folder guide

This folder contains the materials for the “Projected dynamics and uncertainty” analysis: a small preprocessing notebook and Tableau packaged workbooks.

## Process.ipynb

- Purpose: prepare and produce intermediate and final tables for uncertainty analysis and country/sector-level results, as inputs for visualization.
- Typical inputs: spreadsheets like `All_*` and `Result_*`.
- Typical outputs: e.g., `dynamic_uncertainty_2022—2050.xlsx`, `merged_output_MED.xlsx`, and tables split by country/sector.
- How to use: open locally and run cells in order. Common dependencies include pandas, numpy, and openpyxl; please follow the actual imports in the notebook.

## Tableau packaged workbooks (.twbx)

- Files (examples):
  - `Supplementary Fig.5.twbx` — corresponds to Supplementary Information section 5.1.
  - `Supplementary Fig.6.twbx` — corresponds to Supplementary Information section 5.3.
- Important: the .twbx file name is the same as its section title in the Supplementary Information.
- How to open: use Tableau Desktop. Each workbook embeds data connections and chart configurations to reproduce the figures.

## Suggested reproduction steps

1. Run `Process.ipynb` to generate/update the outputs used for visualization.
2. Open the relevant `.twbx` and verify data connections. If paths changed, use “Replace Data Source” in Tableau.
3. Refresh data and export figures/dashboards for the main text and the Supplementary Information.

## Notes

- Other `.xlsx` files here are intermediate or final data products; for provenance and calculation details, refer to `Process.ipynb`.
