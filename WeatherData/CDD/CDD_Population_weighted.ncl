;;;
;;;
;;;
begin
    yrStrt = 1990
    yrLast = 2022
    year   = ispan(yrStrt, yrLast, 1)
    nyear  = yrLast - yrStrt + 1
    year@units = "year from " + yrStrt

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

;;;read data
    f_heatwave = addfile("/mnt/x/Cooling_Degree_days/ERA5_daily_CDDyrer_24.0degC_1990_2022.nc","r")
    CDDyear     = f_heatwave->CDDyear          ;;; heatwave duration
    printVarSummary(CDDyear)

    lat_CDDyear = CDDyear&lat
    lon_CDDyear = CDDyear&lon

    print("new write over")
;;;
    Population_Density_new = linint2_Wrap(lon_pop,lat_pop,Population_Density,True,lon_CDDyear,lat_CDDyear,0)
    Population_Density_new!1 = "lat"
    Population_Density_new&lat = lat_CDDyear
    Population_Density_new!2 = "lon"
    Population_Density_new&lon = lon_CDDyear
    delete(Population_Density)

    population_density_2000 = Population_Density_new({1},:,:)
    population_density_2005 = Population_Density_new({2},:,:)
    population_density_2010 = Population_Density_new({3},:,:)
    population_density_2015 = Population_Density_new({4},:,:)
    population_density_2020 = Population_Density_new({5},:,:)

    delete(Population_Density_new)

;;;population density weight
    CDDyear_gwp     = CDDyear

    ;;;1990-2000年
    do i = 0, 10
        CDDyear_gwp(i,:,:)     = CDDyear(i,:,:)*population_density_2000
    end do

    ;;;2001-2005年
    do i = 11, 15
        CDDyear_gwp(i,:,:)     = CDDyear(i,:,:)*population_density_2005
    end do

    ;;;2006-2010年
    do i = 16, 20
        CDDyear_gwp(i,:,:)     = CDDyear(i,:,:)*population_density_2010
    end do

    ;;;2011-2015年
    do i = 21, 25
        CDDyear_gwp(i,:,:)     = CDDyear(i,:,:)*population_density_2015
    end do

    ;;;2016-2022年
    do i = 26, 32
        CDDyear_gwp(i,:,:)     = CDDyear(i,:,:)*population_density_2020
    end do

    delete(CDDyear)

    printVarSummary(CDDyear_gwp)

;;;
    cdf_CDDyear_gwp = "ERA5_CDDyrer_24.0degC_weighting_Population_Density_0.1_0.1_1990_2022.nc"
    system("/bin/rm -f "+cdf_CDDyear_gwp)         ; remove any pre-existing file
    setfileoption("nc","Format","NetCDF4Classic")
    ncdf_CDDyear_gwp= addfile(cdf_CDDyear_gwp ,"c")      ; open output netCDF file
    ncdf_CDDyear_gwp->CDDyear = CDDyear_gwp

    print("popu write over")
end