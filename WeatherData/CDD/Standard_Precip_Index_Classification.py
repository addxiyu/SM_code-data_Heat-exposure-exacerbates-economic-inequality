import geopandas as gpd
import xarray as xr
import numpy as np
from shapely.geometry import mapping
import pandas as pd
import datetime
import netCDF4 as nc
import rioxarray
import rasterio

# 读取shp文件
world = gpd.read_file('X:/Map_shp/GADM_levels_shp/gadm36_0.shp')
print(world)

# 读取nc文件
ERA_precip_ano = xr.open_dataset('X:/CRU_ERA5/ERA5_monthly_precip_anomaly_annual_mean_grid_0.1_0.1_199001-202212.nc')
precip_ERA     = ERA_precip_ano['precip']
precip_ERA_clm = np.mean(precip_ERA, axis=0)

ERA_precip_Pop = xr.open_dataset('X:/CRU_ERA5/ERA5_monthly_precip_anomaly_annual_mean_weighting_Population_Density_0.1_0.1_199001-202212.nc')
precip_ERA_Pop = ERA_precip_ano['precip']
precip_ERA_Pop_clm = np.mean(precip_ERA_Pop, axis=0)

# 将数据转换为地理坐标
precip_ERA_data_georeferenced     = precip_ERA.rio.write_crs("EPSG:4326")
precip_ERA_clm_data_georeferenced = precip_ERA_clm.rio.write_crs("EPSG:4326")

precip_ERA_Pop_data_georeferenced     = precip_ERA_Pop.rio.write_crs("EPSG:4326")
precip_ERA_Pop_clm_data_georeferenced = precip_ERA_Pop_clm.rio.write_crs("EPSG:4326")

# 创建一个与hwd相同格式的空数组来存储结果
result1 = np.full(precip_ERA.shape, -9999.99)
result2 = np.full(precip_ERA_clm.shape, -9999.99)

result3 = np.full(precip_ERA_Pop.shape, -9999.99)
result4 = np.full(precip_ERA_Pop_clm.shape, -9999.99)

# 准备存储SPI结果的数据结构
spi_results = []

# 遍历每个国家
for country in world['NAME_0']:
    print(f"Processing country: {country}")
    # 提取该国家的形状
    try:
        shape = world[world['NAME_0'] == country]['geometry'].values[0]
    except IndexError:
        print(f"Warning: Could not find geometry for {country}, skipping...")
        continue

    # 存储当前国家所有年份的降水异常值，用于计算SPI
    country_precip_anomalies     = []
    country_precip_anomalies_Pop = []
    country_years                = []
    
    # 遍历每一年
    for year_idx in range(precip_ERA.shape[0]):
        # 获取年份（假设时间坐标是datetime类型）
        year = precip_ERA.time[year_idx].dt.year.item()
        
        # 使用国家的几何形状来掩膜地表数据
        masked_precip_ERA     = precip_ERA_data_georeferenced[year_idx, :, :].rio.clip([shape], world.crs, drop=False)
        masked_precip_ERA_Pop = precip_ERA_Pop_data_georeferenced[year_idx, :, :].rio.clip([shape], world.crs, drop=False)

        # 计算掩膜区域的平均值
        mean_precip_ERA       = masked_precip_ERA.mean().values
        mean_precip_ERA_Pop   = masked_precip_ERA_Pop.mean().values           

        # 保存国家年度降水异常值，用于后续计算SPI
        country_precip_anomalies.append(mean_precip_ERA)
        country_precip_anomalies_Pop.append(mean_precip_ERA_Pop)
        country_years.append(year)
        
        # 获取掩膜区域的索引
        mask_indices = np.where(~np.isnan(masked_precip_ERA.values))
        
        # 将平均赋值给国家范围内所有格点
        result1[year_idx, mask_indices[0], mask_indices[1]] = mean_precip_ERA
        result3[year_idx, mask_indices[0], mask_indices[1]] = mean_precip_ERA_Pop
        
    # 计算SPI（标准化降水指数）
    try:
        # 转换为numpy数组以便计算
        country_precip_array     = np.array(country_precip_anomalies)
        country_precip_Pop_array = np.array(country_precip_anomalies_Pop)
        
        # 计算均值和标准差
        mean = np.nanmean(country_precip_array)
        std  = np.nanstd(country_precip_array)

        mean_Pop = np.nanmean(country_precip_Pop_array)
        std_Pop  = np.nanstd(country_precip_Pop_array)
        
        # 避免除以零
        if std == 0:
            print(f"Warning: Standard deviation is zero for {country}, cannot calculate SPI")
            spi_values = np.zeros_like(country_precip_array)
        else:
            # 计算SPI (z-score标准化)
            spi_values = (country_precip_array - mean) / std

        if std_Pop == 0:
            print(f"Warning: Standard deviation is zero for {country}, cannot calculate SPI")
            spi_Pop_values = np.zeros_like(country_precip_Pop_array)
        else:
            # 计算SPI (z-score标准化)
            spi_Pop_values = (country_precip_Pop_array - mean_Pop) / std_Pop
            
        # 为每个年份分类
        for i, (year, spi, precip_anomaly) in enumerate(zip(country_years, spi_values, country_precip_anomalies)):
            if spi < -2:
                category = "Extreme drought"
            elif -2 <= spi < -1:
                category = "Drought"
            elif -1 <= spi < 0:
                category = "Precipitation decrease"
            elif 0 <= spi < 1:
                category = "Precipitation increase"
            elif 1 <= spi < 2:
                category = "Heavy precipitation"
            else:  # spi >= 2
                category = "Extreme precipitation"

        for i, (year, spi_Pop, precip_anomaly_Pop) in enumerate(zip(country_years, spi_Pop_values, country_precip_anomalies_Pop)):
            if spi_Pop < -2:
                category_Pop = "Extreme drought"
            elif -2 <= spi_Pop < -1:
                category_Pop = "Drought"
            elif -1 <= spi_Pop < 0:
                category_Pop = "Precipitation decrease"
            elif 0 <= spi_Pop < 1:
                category_Pop = "Precipitation increase"
            elif 1 <= spi_Pop < 2:
                category_Pop = "Heavy precipitation"
            else:  # spi_Pop >= 2
                category_Pop = "Extreme precipitation"
                
            # 保存结果
            spi_results.append({
                'Country': country,
                'Year': year,
                'Precipitation_Anomaly': precip_anomaly,
                'SPI': spi,
                'Category': category,
                'Precipitation_Anomaly_Pop': precip_anomaly_Pop,
                'SPI_Pop': spi_Pop,
                'Category_Pop': category_Pop
            })
            
    except Exception as e:
        print(f"Error processing SPI for {country}: {str(e)}")
        continue        
        
    # 处理气候态数据
    masked_precip_ERA_clm     = precip_ERA_clm_data_georeferenced.rio.clip([shape], world.crs, drop=False)
    masked_precip_ERA_Pop_clm = precip_ERA_Pop_clm_data_georeferenced.rio.clip([shape], world.crs, drop=False)
    
    # 计算掩膜区域的平均
    mean_precip_ERA_clm = masked_precip_ERA_clm.mean().values
    mean_precip_ERA_Pop_clm = masked_precip_ERA_Pop_clm.mean().values
    
    # 将平均赋值给国家范围内所有格点
    result2[np.where(~np.isnan(masked_precip_ERA_clm.values))] = mean_precip_ERA_clm
    result4[np.where(~np.isnan(masked_precip_ERA_Pop_clm.values))] = mean_precip_ERA_Pop_clm


# 将结果转换为xarray DataArray
result_da1 = xr.DataArray(result1, coords=precip_ERA.coords, dims=precip_ERA.dims, attrs={'_FillValue': -9999.99})
result_da2 = xr.DataArray(result2, coords=precip_ERA_clm.coords, dims=precip_ERA_clm.dims, attrs={'_FillValue': -9999.99})
result_da3 = xr.DataArray(result3, coords=precip_ERA_Pop.coords, dims=precip_ERA_Pop.dims, attrs={'_FillValue': -9999.99})
result_da4 = xr.DataArray(result4, coords=precip_ERA_Pop_clm.coords, dims=precip_ERA_Pop_clm.dims, attrs={'_FillValue': -9999.99})

country_result1 = xr.Dataset({
    'precip': result_da1
})

country_result2 = xr.Dataset({
    'precip': result_da2
})
  
country_result3 = xr.Dataset({
    'precip': result_da3
})

country_result4 = xr.Dataset({
    'precip': result_da4
})  
    

# 将结果保存为新的nc文件
country_result1.to_netcdf('ERA5_monthly_precip_anomaly_annual_mean_country_results_0.1_0.1_199001-202212.nc')
country_result2.to_netcdf('ERA5_monthly_precip_anomaly_clm_country_results_0.1_0.1_199001-202212.nc')
country_result3.to_netcdf('ERA5_monthly_precip_anomaly_annual_mean_weighting_Population_Density_country_results_0.1_0.1_199001-202212.nc')
country_result4.to_netcdf('ERA5_monthly_precip_anomaly_clm_weighting_Population_Density_country_results_0.1_0.1_199001-202212.nc')

# 将SPI结果写入Excel
try:
    # 创建DataFrame
    spi_df = pd.DataFrame(spi_results)
    
    # 按照国家和年份排序
    spi_df = spi_df.sort_values(by=['Country', 'Year'])
    
    # 保存到Excel
    excel_filename = 'Country_Precipitation_SPI_Classification_1990-2022.xlsx'
    spi_df.to_excel(excel_filename, index=False)
    print(f"SPI results saved to {excel_filename}")
except Exception as e:
    print(f"Error saving SPI results to Excel: {str(e)}")
    