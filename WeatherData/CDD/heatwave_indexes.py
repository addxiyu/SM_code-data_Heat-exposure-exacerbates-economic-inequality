import xarray as xr
import numpy as np
from dask.diagnostics import ProgressBar
import os
from tqdm import tqdm
import numba
import dask.array as da

# 配置参数
clm = 'ERA5'  # 其他选项: 'ssp245'; 'ssp585'; 'era5'
per = '95'    # 百分位阈值
dur = 2       # 热浪最低持续时间
variable = '2m_temperature'
yrStrt = 1990
yrLast = 2019

# 1. 使用Dask分块读取数据（优化内存使用）
print("使用Dask分块读取数据...")
era5_all = xr.open_mfdataset(
    f'F:/Reanalysis/ERA5/hourly/daily/2m_temperature/ERA5-Land_daily_{variable}_*.nc',
    chunks={'valid_time': 365, 'latitude': 100, 'longitude': 100}  # 调整分块大小
)
t2m_all = era5_all['t2m']
print(f"数据加载完成，形状: {t2m_all.shape}")

# 2. 加载阈值数据
threshold_path = f'X:/python_calu_hotday/new_calu/{clm}_t2m_{per}p_threshold_based_on_{yrStrt}-{yrLast}.nc'
print(f"加载阈值数据: {threshold_path}")

ds = xr.open_dataset(threshold_path)
threshold = ds['threshold']

# 3. 优化热浪检测算法 - 修复Numba类型问题
def calculate_consecutive_days(hot_days, dur):
    """
    计算连续高温天数和热浪指标
    返回: (连续高温天数数组, 热浪日数组, 热浪事件开始数组)
    """
    n_time, n_lat, n_lon = hot_days.shape
    consecutive = np.zeros(hot_days.shape, dtype=np.int16)
    heatwave_days = np.zeros(hot_days.shape, dtype=np.int8)  # 使用int8代替bool
    heatwave_events = np.zeros(hot_days.shape, dtype=np.int8)  # 使用int8代替bool
    
    # 处理每个纬度/经度点
    for lat in range(n_lat):
        for lon in range(n_lon):
            current_run = 0
            
            for t in range(n_time):
                if hot_days[t, lat, lon]:
                    current_run += 1
                    consecutive[t, lat, lon] = current_run
                    
                    # 标记热浪日
                    if current_run >= dur:
                        heatwave_days[t, lat, lon] = 1
                        
                        # 标记热浪事件开始（仅当连续天数恰好等于dur时）
                        if current_run == dur:
                            heatwave_events[t, lat, lon] = 1
                else:
                    current_run = 0
                    consecutive[t, lat, lon] = 0
    
    return consecutive, heatwave_days, heatwave_events

# 4. 逐年份高效处理热浪指数
print("开始计算热浪指数...")
results = []
years = range(1990, 2023)

# 预分配内存用于存储中间结果
prev_year_end = None

for year in tqdm(years, desc="处理年份"):
    # 1. 加载当前年份数据
    t2m_year = t2m_all.sel(valid_time=slice(f"{year}-01-01", f"{year}-12-31"))
    
    # 2. 识别高温日
    hot_days = (t2m_year > threshold).compute()  # 显式计算以避免延迟计算
    
    # 3. 处理跨年热浪（如果dur>1）
    if dur > 1:
        if prev_year_end is not None:
            # 合并上一年最后几天的数据
            combined = xr.concat([prev_year_end, hot_days], dim='valid_time')
        else:
            combined = hot_days
    else:
        combined = hot_days
    
    # 确保数组是C连续格式
    hot_days_arr = np.ascontiguousarray(combined.values.astype(bool))
    
    # 4. 使用优化算法计算连续高温天数和热浪指标
    consecutive_arr, heatwave_days_arr, heatwave_events_arr = calculate_consecutive_days(
        hot_days_arr, dur
    )
    
    # 5. 保存当前年份最后几天的连续天数状态（用于下一年）
    if dur > 1:
        # 提取最后 (dur-1) 天的连续天数
        prev_year_end = combined.isel(valid_time=slice(-(dur-1), None)).copy()
        prev_year_end.values = consecutive_arr[-(dur-1):, :, :]
        
        # 如果是第一年，则移除上一年添加的数据
        if prev_year_end is None:
            consecutive_arr = consecutive_arr[(dur-1):, :, :]
            heatwave_days_arr = heatwave_days_arr[(dur-1):, :, :]
            heatwave_events_arr = heatwave_events_arr[(dur-1):, :, :]
    
    # 6. 创建数据数组
    dims = list(combined.dims)
    coords = {dim: combined.coords[dim] for dim in dims}
    
    consecutive_da = xr.DataArray(
        consecutive_arr,
        dims=dims,
        coords=coords
    )
    
    heatwave_days_da = xr.DataArray(
        heatwave_days_arr,
        dims=dims,
        coords=coords
    )
    
    heatwave_events_da = xr.DataArray(
        heatwave_events_arr,
        dims=dims,
        coords=coords
    )
    
    # 7. 计算年度指标
    metrics = xr.Dataset({
        'hwd': heatwave_days_da.sum(dim='valid_time'),
        'hotday': hot_days.sum(dim='valid_time'),
        'hwtimes': heatwave_events_da.sum(dim='valid_time'),
        'hwmax': consecutive_da.max(dim='valid_time')
    })
    
    # 添加时间坐标
    metrics = metrics.expand_dims(time=[np.datetime64(f"{year}-01-01")])
    results.append(metrics)
    
    # 8. 清除中间变量释放内存
    del t2m_year, hot_days, combined, consecutive_arr, heatwave_days_arr, heatwave_events_arr
    del consecutive_da, heatwave_days_da, heatwave_events_da

# 5. 合并并保存结果
print("\n合并年度结果...")
final_dataset = xr.concat(results, dim='time')

output_path = f'X:/python_calu_hotday/new_calu/{clm}_heatwave_{per}p_{dur}d_1990_2022_based_on_{yrStrt}-{yrLast}.nc'
print(f"保存结果到: {output_path}")

# 使用Dask并行保存
final_dataset = final_dataset.chunk({'time': 10, 'latitude': 100, 'longitude': 100})
with ProgressBar():
    final_dataset.to_netcdf(output_path)

print("处理完成！")