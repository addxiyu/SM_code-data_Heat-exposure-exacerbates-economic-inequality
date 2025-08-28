#
#
#
import xarray as xr
from tqdm import tqdm
import numpy as np

#数据类型
clm='ERA5_Land' #other cases: 'ssp245'; 'ssp585'; 'era5'
#变量名
variable='2m_temperature'

#阈值
threshold = 18.3

final_results = []
for year in tqdm(range(1990,2023,1)):
    print(year)
    f_t2m = xr.open_mfdataset(f'F:/Reanalysis/ERA5/hourly/daily/2m_temperature/ERA5-Land_daily_{variable}_0.1_{year}_*.nc')
    t2m_year = f_t2m['t2m'].load()
    
    CDDday = np.maximum(t2m_year - (threshold + 273.15), 0)
    
    # 计算每年的冷却度日总和
    CDDyear = CDDday.sum(dim='valid_time')

    year_result = xr.Dataset({
        'CDDyear': CDDyear  # 添加每年的冷却度日总和到结果中
    })    
    
    result = year_result.assign_coords(time=[year]) # Set the year as the time coordinate
    
    final_results.append(result)
    
final_dataset = xr.concat(final_results, dim='time')
final_dataset.to_netcdf(f'X:/Cooling_Degree_Days/new/{clm}_daily_CDDyrer_{threshold}degC_1990_2022.nc')

    
    


