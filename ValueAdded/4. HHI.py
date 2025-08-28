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
# 计算调整后的HHI（分进口/出口方式），维度是m*n
# ROW的行和列需要拆分:按照之前table_rowsep.py拆分方式，ROW比例是剩下国家加总到行业层面之后的占比
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
n = 190
m = 26


# os.listdir()方法获取文件夹名字，返回数组
current_dir = os.getcwd()
file_pattern = re.compile(r"Eora26_\d+_bp\.csv")
yearfile_list = [f for f in os.listdir(current_dir) if file_pattern.match(f)]

rr_zero = [q*26 + 26 for q in range(190)]
HHI_import_all = []
HHI_export_all = []

for i in yearfile_list:
    io_table = pd.read_csv(os.path.join(current_dir, i), header=None)

    # 提取中间投入（Z）
    Z = ((io_table.iloc[3:4943, 4:4944]).astype('float')).values
    for j in rr_zero:
        Z[(j-26):j, (j-26):j] = 0
    
    # import-based country sector-specific Herfindahl index
    # 每26行加总
    himport_numerator = np.add.reduceat(Z, np.arange(0, Z.shape[0], 26), axis=0)
    himport_denominator = np.reshape(np.sum(Z, axis=0),(1,4940))
    # h (share)
    himport = himport_numerator/himport_denominator
    # 基于import一年的HHI
    HHI_import = (10000*n/(n-1)*(np.reshape(np.sum(np.power(himport, 2), axis=0),(1,4940))-1/n)).tolist()
    # 所有年份基于import的HHI
    HHI_import_all.append(HHI_import)
    
    # export-based country sector-specific Herfindahl index
    # 每26行加总
    hexport_numerator = np.add.reduceat(Z, np.arange(0, Z.shape[1], 26), axis=1)
    hexport_denominator = np.reshape(np.sum(Z, axis=1),(4940,1))
    # h (share)
    hexport = hexport_numerator/hexport_denominator
    # 基于export一年的HHI
    HHI_export = (10000*n/(n-1)*(np.reshape(np.sum(np.power(hexport, 2), axis=1),(1,4940))-1/n)).tolist()
    # 所有年份基于export的HHI
    HHI_export_all.append(HHI_export)
    
HHI_import_all = np.transpose(np.reshape(np.array(HHI_import_all), (33,4940)))  
HHI_export_all = np.transpose(np.reshape(np.array(HHI_export_all), (33,4940)))


# 拼接label
## 拼接左边的label
label_total = (io_table.iloc[3:4943, 0:4]).values
HHI_import_all = np.concatenate((label_total, HHI_import_all), axis=1)
HHI_export_all = np.concatenate((label_total, HHI_export_all), axis=1)
## 接着拼接上面的label
year = list(range(1990, 2023))
year.insert(0, '')
year.insert(1, '')
year.insert(2, '')
year.insert(3, '')
year = np.reshape(np.array(year),(1,37))
HHI_import_all = np.concatenate((year, HHI_import_all), axis=0)
HHI_export_all = np.concatenate((year, HHI_export_all), axis=0)

HHI_import_all = pd.DataFrame(HHI_import_all)
HHI_export_all = pd.DataFrame(HHI_export_all)

HHI_outpath = os.path.join(current_dir, 'HHI/')
if not os.path.exists(HHI_outpath):
    os.makedirs(HHI_outpath)

HHI_import_all.to_csv(os.path.join(HHI_outpath, 'HHI_import.csv'), sep=',', index=False, header=False)    
HHI_export_all.to_csv(os.path.join(HHI_outpath, 'HHI_export.csv'), sep=',', index=False, header=False)   
