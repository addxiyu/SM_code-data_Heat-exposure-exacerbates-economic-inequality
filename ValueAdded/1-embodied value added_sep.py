# -*- coding: utf-8 -*-
"""
Created on Sun Feb 25 10:17:09 2024
Edited on Wed Oct 27 2025

@author: mingx
@edit: Edward
"""

import numpy as np
import pandas as pd
import math
import os
import csv
from collections import OrderedDict
import re

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
#           存在全为0的列导致矩阵计算不可逆
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

# 构造用于计算里昂惕夫逆矩阵的单位阵
I = np.eye(4940)

current_dir = os.getcwd()
file_pattern = re.compile(r"Eora26_\d+_bp\.csv")
yearfile_list = [f for f in os.listdir(current_dir) if file_pattern.match(f)]

for i in yearfile_list:
    io_table = pd.read_csv(os.path.join(current_dir, i),header=None) 
    # 移除io_table的第一行
    io_table = io_table.iloc[1:]
    
    # 提取中间投入（Z）
    Z = ((io_table.iloc[3:4943, 4:4944]).astype('float')).values
    
    ## 对角线元素为0的改为10**(-20)
    np.fill_diagonal(Z, np.where(np.diag(Z)==0, 10**(-20), np.diag(Z)))
    
    # 中间投入列加总
    Z_rowsum = np.reshape(np.sum(Z, axis=0),(1, 4940))
    
    # 提取最初投入（V）
    V = ((io_table.iloc[4943:4949, 4:4944]).astype('float')).values  ## 改污染物行列
    
    # 最初投入列加总   ## VA分6类，加总成一行
    V_rowsum = np.reshape(np.sum(V, axis=0),(1,4940))    ## 改污染物行列
    V_rowsum[V_rowsum == 0] = 10**(-20)  # VA行向量中0值替换为正值
    
    # 提取总投入（X）
    X = V_rowsum + Z_rowsum
    
    # 计算里昂惕夫逆矩阵
    ## X对角化
    X_diag = np.diag(X.flatten())
    X_diag_inverse = np.linalg.inv(X_diag)
    
    ## 计算直接消耗系数（A） = Z * diag(X)^(-1)
    A = np.dot(Z, X_diag_inverse)
    ## 计算L  Leontief矩阵
    I_A = I-A
    L = np.linalg.pinv(I_A)
    
    # 计算V/X 并对角化
    V_X_diag = np.diag((V_rowsum / X).flatten())
    
    # 提取最终需求
    ## 提取最初投入（V）
    Y = ((io_table.iloc[3:4943, 4944:6084]).astype('float')).values    #调整行列 去掉ROW
    
    ## 加总所有子最终需求   6类FD加总 成一列
    Y_subsum = []
    for j in range(0, Y.shape[1], 6):
        ### 选取每6列
        Y_column_slice = Y[:, j:j+6]  
        ### 对选取的列进行求和
        Y_column_sum = np.sum(Y_column_slice, axis=1)  
        Y_subsum.append(Y_column_sum)

    ### 转置得到和的每一行对应一个原始数组的行
    Y_subsum = np.array(Y_subsum).T  
    
    
    # 隐含增加值矩阵  计算EVA公式】
    V_embodied = np.dot(np.dot(V_X_diag, L), Y_subsum)
    
    
    # 输出隐含增加值矩阵
    label_total = (io_table.iloc[3:4943, 0:4]).values
    
    ## 用OrderedDict保存非重复值
    unique_values_dict = OrderedDict.fromkeys(label_total[:,1])
    
    ## 获取第二列的非重复值且保持原顺序
    country_name = list(unique_values_dict.keys())
    country_name.insert(0, '')
    country_name.insert(1, '')
    country_name.insert(2, '')
    country_name.insert(3, '')
    country_name = np.reshape(np.array(country_name),(1,194))
    
    ## 拼接左边的label
    V_lr = np.concatenate((label_total, V_embodied), axis=1)
    ## 接着拼接上面的label
    V_lrud = np.concatenate((country_name, V_lr), axis=0)
    
    V_lrud = pd.DataFrame(V_lrud)
    
    V_outpath = 'Eora_embodied value added/total/' + i + '_embodied value added.csv'
    out_dir = os.path.join(current_dir, os.path.dirname(V_outpath))
    if not os.path.exists(out_dir):
        os.makedirs(out_dir)
    V_lrud.to_csv(os.path.join(current_dir, V_outpath), sep=',', index=False, header=False)

    
    
    
    
    
    
    
    
    