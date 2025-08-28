import xarray as xr
import numpy as np
from dask.diagnostics import ProgressBar
import os
import dask.array as da
from dask.distributed import Client, LocalCluster
import glob
from netCDF4 import Dataset
import time  # 导入时间模块用于计时

# 记录程序开始时间
start_time = time.perf_counter()

# 配置参数
clm = 'ERA5'  # 其他选项: 'ssp245'; 'ssp585'; 'era5'
per = '99'    # 百分位阈值
dur = 2       # 热浪最低持续时间
variable = '2m_temperature'
base_path_era5 = "F:/Reanalysis/ERA5/hourly/daily/2m_temperature/"

def is_valid_netcdf(file_path):
    try:
        with Dataset(file_path, 'r') as nc:
            return True
    except Exception as e:
        print(f"Invalid file: {file_path} (Error: {e})")
        return False
    
# 1. 使用Dask分块读取数据（避免一次性加载全部数据）
yrStrt = 1990
yrLast = 2019

# 记录文件读取开始时间
file_read_start = time.perf_counter()

files = []
for year in range(yrStrt, yrLast):
    pattern = os.path.join(base_path_era5, f"ERA5-Land_daily_2m_temperature_0.1_{year}_??.nc")
    files.extend([f for f in glob.glob(pattern) if is_valid_netcdf(f)])

print(f"Loading {len(files)} ERA5 files (years {yrStrt}-{yrLast})")
print("使用Dask分块读取数据...")

ds = xr.open_mfdataset(
    files,
    chunks={'valid_time': 365, 'latitude': 100, 'longitude': 100},
)
    
t2m_selected = ds['t2m']
print(f"数据加载完成，形状: {t2m_selected.shape}")

# 计算文件读取耗时
file_read_end = time.perf_counter()
print(f"文件读取耗时: {file_read_end - file_read_start:.2f} 秒")

# 2. 计算阈值（1990-2019年）
print(f"计算{yrStrt}-{yrLast}年的阈值...")

# 记录阈值计算开始时间
threshold_calc_start = time.perf_counter()

print("尝试并行计算方法...")
# 重新分块时间维度
t2m_selected = t2m_selected.chunk({'valid_time': -1, 'latitude': 100, 'longitude': 100})

# 计算分位数（不使用dask_gufunc_kwargs）
threshold = t2m_selected.quantile(float(per) * 0.01, dim='valid_time', skipna=True)

# 计算并保存结果
with ProgressBar():
    threshold = threshold.compute()
print("并行计算方法成功!")
# 计算阈值计算耗时
threshold_calc_end = time.perf_counter()
print(f"阈值计算耗时: {threshold_calc_end - threshold_calc_start:.2f} 秒")

# 保存阈值
# 记录结果保存开始时间
save_start = time.perf_counter()

threshold_path = f'X:/python_calu_hotday/new_calu/{clm}_t2m_{per}p_threshold_based_on_{yrStrt}-{yrLast}.nc'
if not os.path.exists(os.path.dirname(threshold_path)):
    os.makedirs(os.path.dirname(threshold_path))

with ProgressBar():
    threshold_dataset = xr.Dataset({'threshold': threshold})
    threshold_dataset.to_netcdf(threshold_path)

print(f"阈值计算完成并保存至: {threshold_path}")
# 计算结果保存耗时
save_end = time.perf_counter()
print(f"结果保存耗时: {save_end - save_start:.2f} 秒")

# 计算并显示总运行时间
total_time = time.perf_counter() - start_time
print(f"\n程序总运行时间: {total_time:.2f} s ({total_time/60:.2f} min) ({total_time/3690:.2f} h)")
