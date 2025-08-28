# -*- coding: utf-8 -*-
"""
Created on Sun Feb 25 10:17:09 2024
Update on 2025-04-14 by Edward
@author: mingx
@edit: Edward
"""

import numpy as np
import pandas as pd
import math
import os
import csv
from pathlib import Path

# Project root (relative to this script)
PROJECT_ROOT = Path(__file__).resolve().parents[1]

# Data directory structure (modifiable if needed)
DATA_DIR = PROJECT_ROOT / 'data'
EORA_ALL_CSV_DIR = DATA_DIR / 'Eora_all_csv'
EVA_TOTAL_DIR = DATA_DIR / 'separate row' / 'Eora_embodied value added' / 'total'
OUT_DIR = DATA_DIR / 'separate row' / 'comparative advantage' / 'total'

# Ensure the output directory exists
OUT_DIR.mkdir(parents=True, exist_ok=True)

# Build the list of years (or base filenames)
# Be tolerant of files/folders: use stem as the year key
if EORA_ALL_CSV_DIR.exists():
        yearfile_list = sorted([Path(p).stem for p in os.listdir(EORA_ALL_CSV_DIR)])
else:
    raise FileNotFoundError(f"Data directory not found: {EORA_ALL_CSV_DIR}")

compar_advan = np.empty((4940, 1))

V_allyear = []

for i in yearfile_list:
    V_path = EVA_TOTAL_DIR / f"{i}_embodied value added.csv"
    V = pd.read_csv(str(V_path), header=None)  
    V_value = (V.iloc[1:4941, 4:194].astype('float')).values
    
    V_prod = np.reshape(np.sum(V_value, axis=1),(4940,1))   # V_prod: row-wise sums
    
    """ Compute comparative advantage (CA) components """
    
    
    ## Numerator's numerator
    
    V_prod_sectorsum = []
    
    for k in range(0, V_prod.shape[0], 26):
        ### Select each 26-row sector block
        V_row_slice = V_prod[k:k+26, :]  
        ### Sum over the selected rows
        V_row_sum = np.sum(V_row_slice, axis=0)  
        V_prod_sectorsum.append(V_row_sum)
        
    ## Numerator's denominator
    V_prod_sectorsum = np.array(V_prod_sectorsum)
    V_prod_sectorsum_rep = np.reshape(np.repeat(V_prod_sectorsum, 26),(4940,1))
    
    """ Denominator """
    
    ## Row indices (countries) to be aggregated
    country_values = [26*i for i in range(0,190)]
    
    ## Sum over the specified rows
    V_prodsum = []
    for l in range(0, 26):
        
        V_noRow_conrow_slice = [x + l for x in country_values]
        V_noRow_conrow_sum = np.sum(V_prod[V_noRow_conrow_slice,:], axis=0)  
        V_prodsum.append(V_noRow_conrow_sum)
        
    ## Denominator's numerator
    V_prodsum = np.reshape(np.array(V_prodsum),(26,1))
    V_prodsum_rep = np.reshape(np.transpose(np.tile(V_prodsum, 190)),(4940,1))
    
    ## Denominator's denominator
    V_prodectssum = np.reshape(np.sum(V_prodsum, axis=0),(1,1))
    V_prodectssum_rep = np.reshape(np.repeat(V_prodectssum, 4940),(4940,1))
    
    V_allyear.append(V_prod)
    


label_total = (V.iloc[1:4941, 0:4]).values      # Adjust row count if using pollutant rows
year = list(range(1990, 2023))
for i in range(4):
    year.insert(0, '')
    
year = np.reshape(np.array(year),(1,37))


V_allyear = (np.array(V_allyear)[:,:,0]).T
V_allyear_lr = np.concatenate((label_total, V_allyear), axis=1)
V_allyear_lrud = pd.DataFrame(np.concatenate((year, V_allyear_lr), axis=0))

# Write level (total) EVA by year
V_allyear_lrud.to_csv(str(OUT_DIR / 'production-based EVA total.csv'), sep=',', index=False, header=False)

# Compute growth rates for regression: log-difference Δln(EVA)
# Add a tiny epsilon to avoid log(0) when EVA is zero
epsilon = 1e-12
V_log = np.log(V_allyear + epsilon)
V_growth = np.diff(V_log, axis=1)  # shape: 4940 x (n_years-1)

# Header row for growth years: start from 1991 to 2022, with 4 blanks in front
growth_years = list(range(1991, 2023))
growth_header = growth_years.copy()
for _ in range(4):
    growth_header.insert(0, '')
growth_header = np.reshape(np.array(growth_header), (1, len(growth_header)))

# Assemble growth table with labels on the left
V_growth_lr = np.concatenate((label_total, V_growth), axis=1)
V_growth_lrud = pd.DataFrame(np.concatenate((growth_header, V_growth_lr), axis=0))

# Write growth-rate table
V_growth_lrud.to_csv(str(OUT_DIR / 'production-based EVA total_growth.csv'), sep=',', index=False, header=False)
