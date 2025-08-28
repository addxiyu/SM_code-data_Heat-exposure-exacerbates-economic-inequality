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
    f_heatwave = addfile("/mnt/x/python_calu_hotday/new_calu/ERA5_heatwave_95p_2d_1990_2022_based_on_1990-2019.nc","r")
    hwd     = f_heatwave->hwd          ;;; heatwave duration
    hotday  = f_heatwave->hotday          ;;; heatwave duration
    hwtimes = f_heatwave->hwtimes          ;;; heatwave duration
    hwmax   = f_heatwave->hwmax          ;;; heatwave duration

    lat_hwd = hwd&lat
    lon_hwd = hwd&lon

    print("new write over")
;;;
    Population_Density_new = linint2_Wrap(lon_pop,lat_pop,Population_Density,True,lon_hwd,lat_hwd,0)
    Population_Density_new!1 = "lat"
    Population_Density_new&lat = lat_hwd
    Population_Density_new!2 = "lon"
    Population_Density_new&lon = lon_hwd
    delete(Population_Density)

    population_density_2000 = Population_Density_new({1},:,:)
    population_density_2005 = Population_Density_new({2},:,:)
    population_density_2010 = Population_Density_new({3},:,:)
    population_density_2015 = Population_Density_new({4},:,:)
    population_density_2020 = Population_Density_new({5},:,:)

    delete(Population_Density_new)

;;;population density weight
    hwd_gwp     = hwd
    hotday_gwp  = hotday
    hwtimes_gwp = hwtimes
    hwmax_gwp   = hwmax

    ;;;1990-2000年
    do i = 0, 10
        hwd_gwp(i,:,:)     = hwd(i,:,:)*population_density_2000
        hotday_gwp(i,:,:)  = hotday(i,:,:)*population_density_2000
        hwtimes_gwp(i,:,:) = hwtimes(i,:,:)*population_density_2000
        hwmax_gwp(i,:,:)   = hwmax(i,:,:)*population_density_2000
    end do

    ;;;2001-2005年
    do i = 11, 15
        hwd_gwp(i,:,:)     = hwd(i,:,:)*population_density_2005
        hotday_gwp(i,:,:)  = hotday(i,:,:)*population_density_2000
        hwtimes_gwp(i,:,:) = hwtimes(i,:,:)*population_density_2000
        hwmax_gwp(i,:,:)   = hwmax(i,:,:)*population_density_2000
    end do

    ;;;2006-2010年
    do i = 16, 20
        hwd_gwp(i,:,:)     = hwd(i,:,:)*population_density_2010
        hotday_gwp(i,:,:)  = hotday(i,:,:)*population_density_2000
        hwtimes_gwp(i,:,:) = hwtimes(i,:,:)*population_density_2000
        hwmax_gwp(i,:,:)   = hwmax(i,:,:)*population_density_2000
    end do

    ;;;2011-2015年
    do i = 21, 25
        hwd_gwp(i,:,:)     = hwd(i,:,:)*population_density_2015
        hotday_gwp(i,:,:)  = hotday(i,:,:)*population_density_2000
        hwtimes_gwp(i,:,:) = hwtimes(i,:,:)*population_density_2000
        hwmax_gwp(i,:,:)   = hwmax(i,:,:)*population_density_2000
    end do

    ;;;2016-2022年
    do i = 26, 32
        hwd_gwp(i,:,:)     = hwd(i,:,:)*population_density_2020
        hotday_gwp(i,:,:)  = hotday(i,:,:)*population_density_2000
        hwtimes_gwp(i,:,:) = hwtimes(i,:,:)*population_density_2000
        hwmax_gwp(i,:,:)   = hwmax(i,:,:)*population_density_2000
    end do

    printVarSummary(hwd_gwp)

;;;
    cdf_hwd_gwp = "ERA5_heatwave_95p_2d_weighting_Population_Density_0.1_0.1_1990_2022.nc"
    system("/bin/rm -f "+cdf_hwd_gwp)         ; remove any pre-existing file
    setfileoption("nc","Format","NetCDF4Classic")
    ncdf_hwd_gwp= addfile(cdf_hwd_gwp ,"c")      ; open output netCDF file
    ncdf_hwd_gwp->hwd     = hwd_gwp
    ncdf_hwd_gwp->hotday  = hotday_gwp
    ncdf_hwd_gwp->hwtimes = hwtimes_gwp
    ncdf_hwd_gwp->hwmax   = hwmax_gwp

    print("popu write over")
end