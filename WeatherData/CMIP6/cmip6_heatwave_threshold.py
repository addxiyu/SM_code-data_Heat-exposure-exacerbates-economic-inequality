import xarray as xr
import numpy as np
import dask
from dask.distributed import Client
import os
import glob
from tqdm import tqdm
import warnings
from netCDF4 import Dataset
import multiprocessing  # 新增：导入multiprocessing
from dask.diagnostics import ProgressBar

warnings.filterwarnings('ignore')

# 配置参数
base_path_era5 = "F:/Reanalysis/ERA5/hourly/daily/2m_temperature/"
base_path_cmip6 = "F:/CMIP6/daily/new_grid/"
output_base = "X:/CMIP6_SSP/new_HWD/thresholds/"
per = 95
q = per / 100.0

os.makedirs(output_base, exist_ok=True)

# 情景和模式
# 数据配置
all_models = {
    'ssp119': ["CanESM5", "CanESM5-1", "EC-Earth3-Veg", "EC-Earth3-Veg-LR", "FGOALS-g3", "IPSL-CM6A-LR", "MIROC6", "MPI-ESM1-2-LR", "MRI-ESM2-0"],
    'ssp126': ["CanESM5", "CanESM5-1", "EC-Earth3-Veg", "EC-Earth3-Veg-LR", "FGOALS-g3", "IPSL-CM6A-LR", "MIROC6", "MPI-ESM1-2-LR", "MRI-ESM2-0"],
    'ssp534': ["CanESM5", "CanESM5-1", "EC-Earth3-Veg", "EC-Earth3-Veg-LR", "FGOALS-g3", "IPSL-CM6A-LR", "MIROC6", "MPI-ESM1-2-LR", "MRI-ESM2-0"],
    'ssp585': ["CanESM5", "CanESM5-1", "EC-Earth3-Veg", "EC-Earth3-Veg-LR", "FGOALS-g3", "IPSL-CM6A-LR", "MIROC6", "MPI-ESM1-2-LR", "MRI-ESM2-0"]
}

# 定义所有函数（保持不变，但不执行任何进程相关操作）

def check_lat_lon_consistency(ds1, ds2, name1="Dataset 1", name2="Dataset 2"):
    required_coords = ['latitude', 'longitude']
    for coord in required_coords:
        if coord not in ds1.coords or coord not in ds2.coords:
            print(f"Missing coordinate '{coord}' in {name1} or {name2}")
            return False
    # 修正纬度顺序
    if ds1['latitude'].values[0] > ds1['latitude'].values[-1]:
        ds1 = ds1.reindex(latitude=ds1['latitude'][::-1])
    if ds2['latitude'].values[0] > ds2['latitude'].values[-1]:
        ds2 = ds2.reindex(latitude=ds2['latitude'][::-1])
    # 检查数值一致性
    if not np.allclose(ds1['latitude'], ds2['latitude'], atol=1e-4):
        print(f"Latitude mismatch between {name1} and {name2}")
        return False
    if not np.allclose(ds1['longitude'], ds2['longitude'], atol=1e-4):
        print(f"Longitude mismatch between {name1} and {name2}")
        return False
    return True

def is_valid_netcdf(file_path):
    try:
        with Dataset(file_path, 'r') as nc:
            return True
    except Exception as e:
        print(f"Invalid file: {file_path} (Error: {e})")
        return False

def load_era5_data(years):
    files = []
    for year in years:
        pattern = os.path.join(base_path_era5, f"ERA5-Land_daily_2m_temperature_0.1_{year}_??.nc")
        files.extend([f for f in glob.glob(pattern) if is_valid_netcdf(f)])
    if not files:
        raise ValueError(f"No ERA5 files for years {years}")
    print(f"Loading {len(files)} ERA5 files (years {min(years)}-{max(years)})")
    ds = xr.open_mfdataset(
        files,
        chunks={'valid_time': 365, 'latitude': 100, 'longitude': 100},
        combine='by_coords',
        engine='netcdf4'
    )
    
    if 'expver' in ds.coords:
        ds = ds.drop_vars('expver')
    if 'expver' in ds.dims:
        ds = ds.squeeze('expver', drop=True)
    return ds['t2m']

def load_cmip6_data(scenario, model, years):
    files = []
    for year in years:
        pattern = os.path.join(base_path_cmip6, scenario, f"tas_day_{model}_{scenario}_r1i1p1f1_0.1_{year}*_new.nc")
        year_files = glob.glob(pattern)
        if not year_files:
            print(f"Warning: No files for {scenario}/{model} year {year}")
        files.extend([f for f in year_files if is_valid_netcdf(f)])
    if not files:
        raise ValueError(f"No CMIP6 files for {scenario}/{model} years {years}")
    print(f"Loading {len(files)} CMIP6 files for {scenario}/{model}")
    ds = xr.open_mfdataset(
        files,
        chunks={'time': 365, 'lat': 100, 'lon': 100},
        combine='by_coords',
        engine='netcdf4'
    )
    ds = ds.rename({'time': 'valid_time', 'lat': 'latitude', 'lon': 'longitude'})
    if ds['latitude'].values[0] > ds['latitude'].values[-1]:
        ds = ds.reindex(latitude=ds['latitude'][::-1])
    return ds['tas']

def calculate_sliding_thresholds(era5_2000_2014, era5_2010_2014):
    # 处理非ssp534情景
    for scenario in [s for s in scenarios if s != 'ssp534']:
        for model in tqdm(all_models[scenario], desc=f"Processing {scenario}"):
            try:
                # 2000-2029年
                cmip1 = load_cmip6_data(scenario, model, range(2015, 2030))
                if not check_lat_lon_consistency(era5_2000_2014, cmip1, "ERA5 2000-2014", f"{scenario} 2015-2029"):
                    continue
                combined1 = xr.concat([era5_2000_2014, cmip1], dim='valid_time')
                combined1 = combined1.chunk({'valid_time': -1, 'latitude': 100, 'longitude': 100})
                print(f"Combine ERA5 and {scenario} {model} 2000-2029 data over")
                threshold1 = combined1.quantile(float(per) * 0.01, dim='valid_time', skipna=True)
                # 计算并保存结果 
                with ProgressBar():
                    threshold1 = threshold1.compute()
                with ProgressBar():
                    threshold_dataset1 = xr.Dataset({'threshold': threshold1})
                    threshold_dataset1.to_netcdf(os.path.join(output_base, f"threshold_{scenario}_{model}_2000-2029.nc"))
                print(f"ERA5 and {scenario} {model} 2000-2029 threshold write over")

                # 2010-2039年
                cmip2 = load_cmip6_data(scenario, model, range(2015, 2040))
                if not check_lat_lon_consistency(era5_2010_2014, cmip2, "ERA5 2010-2014", f"{scenario} 2015-2039"):
                    continue
                combined2 = xr.concat([era5_2010_2014, cmip2], dim='valid_time')
                combined3 = combined3.chunk({'valid_time': -1, 'latitude': 100, 'longitude': 100})
                print(f"Combine ERA5 and {scenario} {model} 2010-2039 data over")
                threshold2 = combined2.quantile(float(per) * 0.01, dim='valid_time', skipna=True)
                # 计算并保存结果
                with ProgressBar():
                    threshold2 = threshold2.compute()
                with ProgressBar():
                    threshold_dataset2 = xr.Dataset({'threshold': threshold2})
                    threshold_dataset2.to_netcdf(os.path.join(output_base, f"threshold_{scenario}_{model}_2010-2039.nc"))
                print(f"ERA5 and {scenario} {model} 2010-2039 threshold write over")

                # 2020-2050年
                cmip3 = load_cmip6_data(scenario, model, range(2020, 2051))
                cmip3 = cmip3.chunk({'valid_time': -1, 'latitude': 100, 'longitude': 100})
                threshold3 = cmip3.quantile(float(per) * 0.01, dim='valid_time', skipna=True)
                # 计算并保存结果
                with ProgressBar():
                    threshold3 = threshold3.compute()
                with ProgressBar():
                    threshold_dataset3 = xr.Dataset({'threshold': threshold3})
                    threshold_dataset3.to_netcdf(os.path.join(output_base, f"threshold_{scenario}_{model}_2020-2050.nc"))
                print(f"{scenario} {model} 2020-2059 threshold write over")
            except Exception as e:
                print(f"Error with {scenario}/{model}: {e}")
                continue

    # 处理ssp534
    for model in tqdm(all_models['ssp534'], desc="Processing ssp534"):
        try:
            cmip585 = load_cmip6_data('ssp585', model, range(2020, 2040))
            cmip534 = load_cmip6_data('ssp534', model, range(2040, 2051))
            if not check_lat_lon_consistency(cmip585, cmip534, "ssp585 2020-2039", "ssp534 2040-2050"):
                continue
            combined = xr.concat([cmip585, cmip534], dim='valid_time')
            combined = combined.chunk({'valid_time': -1, 'latitude': 100, 'longitude': 100})
            threshold = combined.quantile(float(per) * 0.01, dim='valid_time', skipna=True)
            # 计算并保存结果
            with ProgressBar():
                threshold = threshold.compute()
            with ProgressBar():
                threshold_dataset = xr.Dataset({'threshold': threshold})
                threshold_dataset.to_netcdf(os.path.join(output_base, f"threshold_ssp534_{model}_2020-2050.nc"))
            print(f"ssp534 {model} 2000-2029 threshold write over")
        except Exception as e:
            print(f"Error with ssp534/{model}: {e}")
            continue

# --------------------------
# 主函数：所有进程相关代码在此处
# --------------------------
if __name__ == '__main__':


    # 加载数据（全部在main块内执行）
    era5_2000_2014 = load_era5_data(range(2000, 2015))
    era5_2010_2014 = era5_2000_2014.sel(valid_time=slice('2010-01-01', '2014-12-31'))

    # 执行计算
    calculate_sliding_thresholds(era5_2000_2014, era5_2010_2014)

    print("All thresholds calculated!")