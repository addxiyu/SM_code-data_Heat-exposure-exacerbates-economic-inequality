# -*- coding: utf-8 -*-
"""
Created on Sun Feb 25 10:17:09 2024
Update on 2025-04-14 by Edward
@author: mingx
@edit: Edward
Note: add:自适应文件路径、参数化数据loc
"""

import numpy as np
import pandas as pd
import math
import os
import csv
from collections import OrderedDict
import re

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
# Columns with all zeros cause the matrix to be non-invertible
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""


# Construct the identity matrix for calculating the Leontief inverse
I = np.eye(4940)

# os.listdir() method gets folder names and returns them as an array
current_dir = os.getcwd()
file_pattern = re.compile(r"Eora26_\d+_bp\.csv")
yearfile_list = [f for f in os.listdir(current_dir) if file_pattern.match(f)]

eva_total_prod = pd.read_csv(os.path.join(current_dir,'comparative advantage/total/production-based EVA total.csv'),header=None)  # 第二个文件结果：production-based EVA total.csv
eva_total_prod = eva_total_prod.iloc[1:]  # 删去第一行

years = list(range(1990, 2023))
parts = ["PART1", "PART1", "PART3", "PART4", "PART5"]
colunmns_name = pd.DataFrame([f"{y}_{p}" for y in years for p in parts]).T

country_sector = pd.read_csv(os.path.join(current_dir, "Eora26_1999_bp.csv"),header=None) 
subset = country_sector.iloc[3:4943, [1, 3]]


def first_net(file_path):
    io_table = pd.read_csv(file_path,header=None)
    io_table = io_table.iloc[1:]  # 删去第一行
    # Extract data
    # 1. Extract intermediate inputs (Z)
    Z = ((io_table.iloc[3:4943, 4:4944]).astype('float')).values
    
    ## Replace diagonal elements equal to 0 with 10**(-20)
    np.fill_diagonal(Z, np.where(np.diag(Z) == 0, 10**(-20), np.diag(Z)))
    ## Column sum of intermediate inputs
    Z_rowsum = np.reshape(np.sum(Z, axis=0),(1, 4940))
    
    # 2. Extract primary inputs (V)
    V = ((io_table.iloc[4943:4949, 4:4944]).astype('float')).values
    
    ## Column sum of primary inputs
    V_rowsum = np.reshape(np.sum(V, axis=0),(1,4940))
    
    # 3. Extract total inputs (X)
    X = V_rowsum + Z_rowsum
    X[X == 0] = 10**(-20)
    
    # 4. Calculate V/X and diagonalize
    V_X_diag = np.diag((V_rowsum / X).flatten())
    
    # 5. Extract final demand
    Y_sector = ((io_table.iloc[3:4943, 4944:6084]).astype('float')).values
    
    ## Aggregate all sub-final demand
    Y = []
    for j in range(0, Y_sector.shape[1], 6):
        ### Select every 6 columns
        Y_column_slice = Y_sector[:, j:j+6]  
        ### Sum over selected columns
        Y_column_sum = np.sum(Y_column_slice, axis=1)  
        Y.append(Y_column_sum)

    ### Transpose so that each row corresponds to the original rows
    Y = np.array(Y).T  
    
    # Base calculations
    
    # 1. Calculate direct input coefficients (A) = Z * diag(X)^(-1)
    X_diag = np.diag(X.flatten())
    X_diag_inverse = np.linalg.inv(X_diag)
    A = np.dot(Z, X_diag_inverse)
   
    # 2. Calculate Leontief inverse (B, L) based on A of all countries
    I_A = I - A
    B = np.linalg.pinv(I_A)
    
    ## Initialize empty list to store extracted sub-matrices
    L_pros = []
    ## Extract sub-matrices from the top-left corner
    for i in range(0, 4940 - 26 + 1, 26):
        # Extract current sub-matrix
        sub_matrix = B[i:i+26, i:i+26]
        # Append the sub-matrix to the list
        L_pros.append(sub_matrix)
    L_pros = np.array(L_pros)
    
    # Create an empty 4940x4940 matrix
    L = np.zeros((4940, 4940))
    
    # Starting index of the diagonal block
    start_index = 0
    
    # Fill the diagonal with each 26x26 block
    for i in range(190):
        L[start_index:start_index+26, start_index:start_index+26] = L_pros[i]
        start_index += 26
    
    
    # 3. Compute Yrr and sum(Yrs)
    diagonal_vectors = []
    for i in range(190):
        # Starting row and column index
        start_index = i * 26
        # Extract 26-element vector
        Yvector = Y[start_index:start_index+26, i]
        diagonal_vectors.append(Yvector)
    # Convert to NumPy array
    YL = np.reshape(diagonal_vectors,(4940,1))
    YB = np.reshape(np.sum(Y, axis=1),(4940,1)) - YL
    
    # 4. Ars
    Ars = A.copy()
    for i in range(0, 4940, 26):
        # Set all elements of the block-diagonal 26x26 matrices to zero
        Ars[i:i+26, i:i+26] = 0
    
    return V_X_diag, L, YL, YB, Ars, B, Y, A
    


def second_net(A,B,Y):
   # B is a 4940x4940 array, Y is a 4940x190 array
    ABY_p2 = []
    for r in range(190):
        ABY_rr = []
        for s in [x for x in range(190) if x != r]:
            
            # part 2
            A_rs = A[r*26:(r+1)*26, s*26:(s+1)*26]
            BY_sr = []
            for u in range(190):
                B_su = B[s*26:(s+1)*26, u*26:(u+1)*26]
                Y_ur = Y[u*26:(u+1)*26, r:(r+1)]
                BY_sr.append(np.dot(B_su,Y_ur).tolist())
                
            BY_sr_1 = np.reshape(np.sum(BY_sr,axis=0),(26,1))
            ABY_rr.append(np.dot(A_rs,BY_sr_1).tolist())

        
        ABY_p2.append(np.reshape(np.sum(ABY_rr,axis=0),(26,1)))            
            
    ABY_p2 = np.array([element for array in ABY_p2 for element in array])
    
    return ABY_p2

    
combined_df = subset
for i in range(33):
    eva_year = (eva_total_prod.iloc[1:,(i+4):(i+5)]).to_numpy()
    
    V_X_diag, L, YL, YB, Ars, B, Y, A = first_net(yearfile_list[i])    
    
    # PART 1: hat(Cr) Lrr Yrr
    part_1 = np.reshape(np.dot(np.dot(V_X_diag, L), YL),(4940,1))
    
    # PART 3: hat(Cr) Lrr sum_s(Yrs)
    part_3 = np.reshape(np.dot(np.dot(V_X_diag, L), YB),(4940,1))
    
    # PART 4: hat(Cr) Lrr sum_s(Ars Lss Yss)
    part_4 = np.reshape(np.dot(np.dot(V_X_diag, L), np.dot(np.dot(Ars,L),YL)),(4940,1))
    
    # PART 2: hat(Cr) Lrr sum_s(Ars sum_u(Bsu Yur))
    ABY_p2 = second_net(A,B,Y) 
    part_2 = np.reshape(np.dot(np.dot(V_X_diag, L), ABY_p2),(4940,1))
    
    # PART 5: hat(Cr) Lrr sum_s(sum_t(Art sum_u(Btu Yus)))
    # Second result file: eva_year
    part_5 = eva_year - part_1 - part_2 - part_3 - part_4   
    
    # Horizontally concatenate these arrays
    combined_df = pd.concat(
        [combined_df, pd.DataFrame(np.concatenate((eva_year, part_1, part_2, part_3, part_4, part_5), axis=1))],
        axis=1
    )

combined_df = pd.concat([colunmns_name, combined_df], ignore_index=True)   

# Write to a relative path inside the repository (ensure directory exists)
output_dir = os.path.join(current_dir, 'output', 'comparative advantage')
if not os.path.exists(output_dir):
    os.makedirs(output_dir, exist_ok=True)
output_path = os.path.join(output_dir, 'GVC-prod.csv')
combined_df.to_csv(output_path, sep=',', index=False, header=False)
