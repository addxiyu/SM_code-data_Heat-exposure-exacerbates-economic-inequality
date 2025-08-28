import xarray as xr
from tqdm import tqdm
import numpy as np
import os

# 数据配置
scenarios = ['ssp119', 'ssp126', 'ssp534', 'ssp585']
models = ["CanESM5", "CanESM5-1", "EC-Earth3-Veg", "EC-Earth3-Veg-LR", 
          "FGOALS-g3", "IPSL-CM6A-LR", "MIROC6", "MPI-ESM1-2-LR", "MRI-ESM2-0"]

# 为每个情景定义对应的模式和年份
scenario_config = {
    'ssp119': {'models': models, 'years': list(range(2023, 2051))},
    'ssp126': {'models': models, 'years': list(range(2023, 2051))},
    'ssp534': {'models': models, 'years': list(range(2040, 2051))},  # 只有2050年数据
    'ssp585': {'models': models, 'years': list(range(2023, 2051))}
}

variable = 'tas'  # CMIP6数据中的温度变量名
threshold = 18.3  # 阈值(°C)
base_path = 'F:/CMIP6/daily/new_grid/'  # 数据基础路径
output_dir = 'X:/CMIP6_SSP/new_CDD/'  # 输出路径

# 确保输出目录存在
os.makedirs(output_dir, exist_ok=True)

# 遍历每个情景、模式和年份
for scenario in tqdm(scenarios, desc='情景'):
    scenario_models = scenario_config[scenario]['models']
    scenario_years = scenario_config[scenario]['years']

    # 确保情景子目录存在
    scenario_output_dir = f"{output_dir}{scenario}/"
    os.makedirs(scenario_output_dir, exist_ok=True)
    
    for model in tqdm(scenario_models, desc=f'{scenario} 模式', leave=False):
        # 构建输出文件路径
        output_file = f"{scenario_output_dir}CDD_{model}_{scenario}_{threshold}degC_{min(scenario_years)}-{max(scenario_years)}.nc"        
        
        # 检查文件是否已存在
        if os.path.exists(output_file):
            print(f"跳过已存在的文件: {output_file}")
            continue
        
        model_results = []
        
        for year in scenario_years:
            try:
                # 构建数据文件路径列表
                file_pattern = f"{base_path}{scenario}/{variable}_day_{model}_{scenario}_r1i1p1f1_0.1_{year}*_new.nc"
                print(f"处理文件: {file_pattern}")
                
                # 打开并加载数据
                ds = xr.open_mfdataset(file_pattern)
                tas = ds[variable].load()
                
                # 计算CDD (冷却度日)
                cdd_day = np.maximum(tas - (threshold + 273.15), 0)
                
                # 计算年CDD总和
                cdd_year = cdd_day.sum(dim='time')
                
                # 创建结果数据集
                result = xr.Dataset({
                    'CDDyear': cdd_year
                }).assign_coords(time=[year])
                
                model_results.append(result)
                
            except Exception as e:
                print(f"处理 {scenario} {model} {year} 时出错: {e}")
                continue
        
        # 如果有该模式的有效结果，则合并并保存
        if model_results:
            model_dataset = xr.concat(model_results, dim='time')
            model_dataset.to_netcdf(output_file)
            print(f"已保存: {output_file}")

print("所有情景和模式的CDD计算已完成!")