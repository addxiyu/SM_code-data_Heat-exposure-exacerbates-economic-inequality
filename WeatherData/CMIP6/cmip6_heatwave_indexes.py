import xarray as xr
import numpy as np
import os
import glob
from tqdm import tqdm
from dask.diagnostics import ProgressBar
import warnings

warnings.filterwarnings('ignore')

# 配置参数
threshold_base = "X:/CMIP6_SSP/new_HWD/thresholds/"  # 阈值数据路径（来自之前计算的结果）
cmip6_base = "F:/CMIP6/daily/new_grid/"              # CMIP6数据路径
output_base = "X:/CMIP6_SSP/new_HWD/heatwaves/"      # 热浪指数输出路径
per = 95                                             # 百分位阈值
dur = 2                                              # 热浪最低持续时间（天）

# 创建输出目录
os.makedirs(output_base, exist_ok=True)

# 情景和模式配置
all_models = {
    'ssp119': ["CanESM5", "CanESM5-1", "EC-Earth3-Veg", "EC-Earth3-Veg-LR", "FGOALS-g3", "IPSL-CM6A-LR", "MIROC6", "MPI-ESM1-2-LR", "MRI-ESM2-0"],
    'ssp126': ["CanESM5", "CanESM5-1", "EC-Earth3-Veg", "EC-Earth3-Veg-LR", "FGOALS-g3", "IPSL-CM6A-LR", "MIROC6", "MPI-ESM1-2-LR", "MRI-ESM2-0"],
    'ssp534': ["CanESM5", "CanESM5-1", "EC-Earth3-Veg", "EC-Earth3-Veg-LR", "FGOALS-g3", "IPSL-CM6A-LR", "MIROC6", "MPI-ESM1-2-LR", "MRI-ESM2-0"],
    'ssp585': ["CanESM5", "CanESM5-1", "EC-Earth3-Veg", "EC-Earth3-Veg-LR", "FGOALS-g3", "IPSL-CM6A-LR", "MIROC6", "MPI-ESM1-2-LR", "MRI-ESM2-0"]
}

# 热浪计算时段与对应阈值时段的映射（保持动态阈值逻辑）
time_mapping = {
    'ssp119': [
        {'heatwave_period': '2025-2029', 'threshold_period': '2000-2029'},
        {'heatwave_period': '2030-2039', 'threshold_period': '2010-2039'},
        {'heatwave_period': '2040-2050', 'threshold_period': '2020-2050'}
    ],
    'ssp126': [
        {'heatwave_period': '2025-2029', 'threshold_period': '2000-2029'},
        {'heatwave_period': '2030-2039', 'threshold_period': '2010-2039'},
        {'heatwave_period': '2040-2050', 'threshold_period': '2020-2050'}
    ],
    'ssp534': [
        {'heatwave_period': '2040-2050', 'threshold_period': '2020-2050'}
    ],
    'ssp585': [
        {'heatwave_period': '2025-2029', 'threshold_period': '2000-2029'},
        {'heatwave_period': '2030-2039', 'threshold_period': '2010-2039'},
        {'heatwave_period': '2040-2050', 'threshold_period': '2020-2050'}
    ]
}

def is_valid_netcdf(file_path):
    """检查NetCDF文件是否有效"""
    try:
        with xr.open_dataset(file_path) as ds:
            return True
    except Exception as e:
        print(f"无效的文件: {file_path} (错误: {e})")
        return False

def load_cmip6_data(scenario, model, years):
    """加载CMIP6数据"""
    files = []
    for year in years:
        pattern = os.path.join(cmip6_base, scenario, f"tas_day_{model}_{scenario}_r1i1p1f1_0.1_{year}*_new.nc")
        year_files = glob.glob(pattern)
        if not year_files:
            print(f"警告: 未找到 {scenario}/{model} {year}年 的文件")
        files.extend([f for f in year_files if is_valid_netcdf(f)])
    
    if not files:
        raise ValueError(f"没有找到 {scenario}/{model} {years[0]}-{years[-1]}年 的CMIP6文件")
    
    print(f"加载 {len(files)} 个CMIP6文件: {scenario}/{model} {years[0]}-{years[-1]}")
    ds = xr.open_mfdataset(
        files,
        chunks={'time': 365, 'lat': 100, 'lon': 100},
        combine='by_coords',
        engine='netcdf4'
    )
    
    # 重命名变量和维度以保持一致性
    ds = ds.rename({'time': 'valid_time', 'lat': 'latitude', 'lon': 'longitude', 'tas': 't2m'})
    
    # 确保纬度是递增的
    if ds['latitude'].values[0] > ds['latitude'].values[-1]:
        ds = ds.reindex(latitude=ds['latitude'][::-1])
    
    return ds['t2m']

def calculate_consecutive_days(hot_days, dur):
    """
    计算连续高温天数和热浪指标
    返回: (连续高温天数数组, 热浪日数组, 热浪事件开始数组)
    """
    n_time, n_lat, n_lon = hot_days.shape
    consecutive = np.zeros(hot_days.shape, dtype=np.int16)
    heatwave_days = np.zeros(hot_days.shape, dtype=np.int8)
    heatwave_events = np.zeros(hot_days.shape, dtype=np.int8)
    
    # 处理每个网格点
    for lat in range(n_lat):
        for lon in range(n_lon):
            current_run = 0
            for t in range(n_time):
                if hot_days[t, lat, lon]:
                    current_run += 1
                    consecutive[t, lat, lon] = current_run
                    
                    # 标记热浪日（当连续天数达到阈值）
                    if current_run >= dur:
                        heatwave_days[t, lat, lon] = 1
                        
                        # 标记热浪事件开始（仅在连续天数首次达到阈值时）
                        if current_run == dur:
                            heatwave_events[t, lat, lon] = 1
                else:
                    current_run = 0
                    consecutive[t, lat, lon] = 0
    
    return consecutive, heatwave_days, heatwave_events

def process_heatwaves(scenario, model, heatwave_period, threshold_period, t2m_data, threshold):
    """处理特定情景、模型和时段的热浪指数计算（仅95%阈值）"""
    # 提取年份范围
    start_year, end_year = map(int, heatwave_period.split('-'))
    years = range(start_year, end_year + 1)
    
    results = []
    prev_year_end = None  # 用于处理跨年热浪
    
    for year in tqdm(years, desc=f"处理 {scenario}/{model} {heatwave_period} (P{per})"):
        # 1. 提取当前年份数据
        t2m_year = t2m_data.sel(valid_time=slice(f"{year}-01-01", f"{year}-12-31"))
        
        # 2. 识别高温日（超过95%阈值）
        hot_days = (t2m_year > threshold).compute()
        
        # 3. 处理跨年热浪（如果持续时间要求>1天）
        if dur > 1:
            if prev_year_end is not None:
                # 合并上一年最后几天的数据
                combined = xr.concat([prev_year_end, hot_days], dim='valid_time')
            else:
                combined = hot_days
        else:
            combined = hot_days
        
        # 确保数组是连续的以提高计算效率
        hot_days_arr = np.ascontiguousarray(combined.values.astype(bool))
        
        # 4. 计算连续高温天数和热浪指标
        consecutive_arr, heatwave_days_arr, heatwave_events_arr = calculate_consecutive_days(
            hot_days_arr, dur
        )
        
        # 5. 保存当前年份最后几天的状态用于下一年计算
        if dur > 1:
            # 提取最后(dur-1)天的连续天数
            prev_year_end = combined.isel(valid_time=slice(-(dur-1), None)).copy()
            prev_year_end.values = consecutive_arr[-(dur-1):, :, :]
            
            # 如果是该时段的第一年，移除上一年添加的数据
            if year == start_year:
                consecutive_arr = consecutive_arr[(dur-1):, :, :]
                heatwave_days_arr = heatwave_days_arr[(dur-1):, :, :]
                heatwave_events_arr = heatwave_events_arr[(dur-1):, :, :]
        
        # 6. 创建数据数组
        dims = list(t2m_year.dims)
        coords = {dim: t2m_year.coords[dim] for dim in dims}
        
        # 7. 计算年度热浪指标
        metrics = xr.Dataset({
            'hwd': xr.DataArray(heatwave_days_arr, dims=dims, coords=coords).sum(dim='valid_time'),
            'hotday': hot_days.sum(dim='valid_time'),
            'hwtimes': xr.DataArray(heatwave_events_arr, dims=dims, coords=coords).sum(dim='valid_time'),
            'hwmax': xr.DataArray(consecutive_arr, dims=dims, coords=coords).max(dim='valid_time')
        })
        
        # 添加时间坐标
        metrics = metrics.expand_dims(time=[np.datetime64(f"{year}-01-01")])
        results.append(metrics)
        
        # 清理内存
        del t2m_year, hot_days, combined, consecutive_arr, heatwave_days_arr, heatwave_events_arr
    
    # 合并年度结果
    final_dataset = xr.concat(results, dim='time')
    
    # 保存结果（包含95%阈值标识）
    output_file = os.path.join(
        output_base, 
        f"{scenario}_{model}_heatwave_{per}p_{dur}d_{heatwave_period}_thresh{threshold_period}.nc"
    )
    final_dataset = final_dataset.chunk({'time': 10, 'latitude': 100, 'longitude': 100})
    
    with ProgressBar():
        final_dataset.to_netcdf(output_file)
    
    print(f"已保存结果: {output_file}")
    return final_dataset

def main():
    """主函数：仅使用95%阈值处理所有情景和模型的热浪指数计算"""
    print(f"===== 开始处理 {per}% 百分位阈值 =====")
    
    for scenario in time_mapping.keys():
        # 处理每个情景下的时段映射
        for period_map in time_mapping[scenario]:
            heatwave_period = period_map['heatwave_period']
            threshold_period = period_map['threshold_period']
            
            for model in all_models[scenario]:
                try:
                    # 1. 加载对应的95%阈值数据
                    threshold_file = os.path.join(
                        threshold_base, 
                        f"threshold_{scenario}_{model}_{threshold_period}.nc"
                    )
                    if not os.path.exists(threshold_file):
                        # 检查可能的含百分位的命名格式
                        threshold_file = os.path.join(
                            threshold_base, 
                            f"threshold_{per}p_{scenario}_{model}_{threshold_period}.nc"
                        )
                    if not os.path.exists(threshold_file):
                        print(f"警告: 未找到阈值文件 {threshold_file}，跳过该组合")
                        continue
                    
                    print(f"加载阈值数据: {threshold_file}")
                    threshold_ds = xr.open_dataset(threshold_file)
                    threshold = threshold_ds['threshold']
                    
                    # 2. 确定热浪计算的年份范围
                    hw_start, hw_end = map(int, heatwave_period.split('-'))
                    data_years = range(hw_start, hw_end + 1)
                    
                    # 3. 加载对应时段的CMIP6数据
                    t2m_data = load_cmip6_data(scenario, model, data_years)
                    
                    # 4. 确保坐标一致性
                    if not np.allclose(t2m_data.latitude, threshold.latitude, atol=1e-4) or \
                       not np.allclose(t2m_data.longitude, threshold.longitude, atol=1e-4):
                        print(f"坐标不匹配: {scenario}/{model} {heatwave_period}，跳过")
                        continue
                    
                    # 5. 计算并保存热浪指数
                    process_heatwaves(
                        scenario, model, heatwave_period, 
                        threshold_period, t2m_data, threshold
                    )
                
                except Exception as e:
                    print(f"处理 {scenario}/{model} {heatwave_period} 时出错: {str(e)}")
                    continue

if __name__ == '__main__':
    main()
    print("所有热浪指数计算完成！")