;;;
;;;
;;;
begin
    yrStrt = 1990
    yrLast = 2022
    year   = ispan(yrStrt, yrLast, 1)
    nyear  = yrLast - yrStrt + 1
    year@units = "year from " + yrStrt

    ymStrt = yrStrt*100 +  1              ; 开始时间 190001
    ymLast = yrLast*100 + 12              ; 结束时间 201912

;;;
    f_eg = addfile("/mnt/f/Reanalysis/ERA5/hourly/daily/2m_temperature/ERA5-Land_daily_mean_2m_temperature_1990_01.nc","r")
    new_lat = f_eg->lat
    new_lon = f_eg->lon
    printVarSummary(new_lat)
    printVarSummary(new_lon)

;;; read the population density data file
    diri_popu = "/mnt/x/【202311】/"
    f_Population_Density = addfile(diri_popu+"new_gpw_v4_population_density_rev11_30_min.nc", "r")
    Population_Density   = f_Population_Density->Population_Density
    Population_Density   = Population_Density(:,::-1,:)
    ; Population_Density   = lonFlip(Population_Density)
    printVarSummary(Population_Density)
    ;;; the latitude and longitude information of population density data, as the standard for interpolation of model data
    lat_pop   = Population_Density&latitude
    ; lat_pop = lat_1(::-1)
    lon_pop = Population_Density&longitude

;;;
    Population_Density_new = linint2_Wrap(lon_pop,lat_pop,Population_Density,True,new_lon,new_lat,0)
    Population_Density_new!1 = "latitude"
    Population_Density_new&latitude = new_lat
    Population_Density_new!2 = "longitude"
    Population_Density_new&longitude = new_lon
    delete(Population_Density)

    population_density_2000 = Population_Density_new({1},:,:)
    population_density_2005 = Population_Density_new({2},:,:)
    population_density_2010 = Population_Density_new({3},:,:)
    population_density_2015 = Population_Density_new({4},:,:)
    population_density_2020 = Population_Density_new({5},:,:)

    delete(Population_Density_new)

;;;read data
    diri_ERA5 = "/mnt/x/data/data/ERA/ERA5/"
    fprecip= addfile(diri_ERA5+"ERA5_monthly_total_precipitation_1959-2022.nc", "r")
    time   = fprecip->time    ; Time
    YYYYMM = cd_calendar(time, -1)      ; ALL dates assciated with precip  190001 190002
    tStrt  = ind(YYYYMM.eq.ymStrt)        ; indices of selected times
    tLast  = ind(YYYYMM.eq.ymLast)
    ERA5_precip = short2flt( fprecip->tp(tStrt:tLast,::-1,:) )
    ERA5_precip = lonFlip(ERA5_precip)
    ERA5_precip = ERA5_precip*1000
    ERA5_precip@units = "mm/mon"
    printVarSummary(ERA5_precip)

    ERA5_precip_c = clmMonTLL(ERA5_precip)
    ERA5_precip_a = calcMonAnomTLL(ERA5_precip, ERA5_precip_c)
    ERA5_precip_a_ann = month_to_annual(ERA5_precip_a, 1)
    ERA5_precip_a_ann!0 = "year"
    ERA5_precip_a_ann&year = year
    printVarSummary(ERA5_precip_a_ann)

    lat_ERA5 = ERA5_precip_a_ann&latitude
    lon_ERA5 = ERA5_precip_a_ann&longitude

    delete(fprecip)
    delete(time)
    delete(YYYYMM)
    delete(tStrt)
    delete(tLast)
    delete(ERA5_precip)
    delete(ERA5_precip_c)
    delete(ERA5_precip_a)

    ERA5_precip_a_ann_new = linint2_Wrap(lon_ERA5,lat_ERA5,ERA5_precip_a_ann,True,new_lon,new_lat,0)
    ERA5_precip_a_ann_new!1 = "lat"
    ERA5_precip_a_ann_new&lat = new_lat
    ERA5_precip_a_ann_new!2 = "lon"
    ERA5_precip_a_ann_new&lon = new_lon
    delete(ERA5_precip_a_ann)

;;;write data
    cdf_ERA5 = "ERA5_monthly_precip_anomaly_annual_mean_grid_0.1_0.1_"+ymStrt+"-"+ymLast+".nc"
    system("/bin/rm -f "+cdf_ERA5)         
    ncdf_ERA5    = addfile(cdf_ERA5 ,"c")      
    ncdf_ERA5->precip = ERA5_precip_a_ann_new

;;;population density weight
    ERA5_gwp = ERA5_precip_a_ann_new

    do i = 1990, 2000
        ERA5_gwp({i},:,:) = ERA5_precip_a_ann_new({i},:,:)*population_density_2000
    end do

    do i = 2001, 2005
        ERA5_gwp({i},:,:) = ERA5_precip_a_ann_new({i},:,:)*population_density_2005
    end do

    do i = 2006, 2010
        ERA5_gwp({i},:,:) = ERA5_precip_a_ann_new({i},:,:)*population_density_2010
    end do

    do i = 2011, 2015
        ERA5_gwp({i},:,:) = ERA5_precip_a_ann_new({i},:,:)*population_density_2015
    end do

    do i = 2016, 2022
        ERA5_gwp({i},:,:) = ERA5_precip_a_ann_new({i},:,:)*population_density_2020
    end do

    delete(ERA5_precip_a_ann_new)

;;;
    cdf_ERA5_gwp = "ERA5_monthly_precip_anomaly_annual_mean_weighting_Population_Density_0.1_0.1_"+ymStrt+"-"+ymLast+".nc"
    system("/bin/rm -f "+cdf_ERA5_gwp)         ; remove any pre-existing file
    ncdf_ERA5_gwp= addfile(cdf_ERA5_gwp ,"c")      ; open output netCDF file
    ncdf_ERA5_gwp->precip = ERA5_gwp

end