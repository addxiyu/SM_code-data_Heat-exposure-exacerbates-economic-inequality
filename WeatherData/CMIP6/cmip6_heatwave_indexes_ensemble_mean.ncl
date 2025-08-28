;;;
;;;
;;;
begin
;;;
    per = 95  
    dur = 2 

;;;
    diri_ssp = "/mnt/x/CMIP6_SSP/new_HWD/heatwaves/"

    diri_out    = "/mnt/x/CMIP6_SSP/new_HWD/"

    {scenario}_{model}_heatwave_{per}p_{dur}d_{heatwave_period}_thresh{threshold_period}.nc

    fils_ssp119 = systemfunc("ls "+diri_ssp+"ssp119_*_heatwave_"+per+"p_"+dur+"d_2040-2050_thresh2020-2050.nc")
    fils_ssp126 = systemfunc("ls "+diri_ssp+"ssp126_*_heatwave_"+per+"p_"+dur+"d_2040-2050_thresh2020-2050.nc")
    fils_ssp534 = systemfunc("ls "+diri_ssp+"ssp534_*_heatwave_"+per+"p_"+dur+"d_2040-2050_thresh2020-2050.nc")
    fils_ssp585 = systemfunc("ls "+diri_ssp+"ssp585_*_heatwave_"+per+"p_"+dur+"d_2040-2050_thresh2020-2050.nc")

    f_ssp119       = addfiles(fils_ssp119, "r")
    ListSetType (f_ssp119, "join") 
    ssp119_hwd     = f_ssp119[:]->hwd
    ssp119_hotday  = f_ssp119[:]->hotday
    ssp119_hwtimes = f_ssp119[:]->hwtimes
    ssp119_hwmax   = f_ssp119[:]->hwmax

    ssp119_hwd_MMM     = dim_avg_n_Wrap(ssp119_hwd, 0)
    ssp119_hotday_MMM  = dim_avg_n_Wrap(ssp119_hotday, 0)
    ssp119_hwtimes_MMM = dim_avg_n_Wrap(ssp119_hwtimes, 0)
    ssp119_hwmax_MMM   = dim_avg_n_Wrap(ssp119_hwmax, 0)

    cdf_ssp119  = diri_out+"ssp119_MMM_heatwave_"+per+"p_"+dur+"d_2040-2050_thresh2020-2050.nc"
    system("/bin/rm -f "+cdf_ssp119)    
    setfileoption("nc","Format","NetCDF4Classic")     
    ncdf_ssp119    = addfile(cdf_ssp119 ,"c")      
    ncdf_ssp119->hwd     = ssp119_hwd_MMM
    ncdf_ssp119->hotday  = ssp119_hotday_MMM
    ncdf_ssp119->hwtimes = ssp119_hwtimes_MMM
    ncdf_ssp119->hwmax   = ssp119_hwmax_MMM
    delete(ssp119_hwd)
    delete(ssp119_hwd_MMM)
    delete(ssp119_hotday)
    delete(ssp119_hotday_MMM)
    delete(ssp119_hwtimes)
    delete(ssp119_hwtimes_MMM)
    delete(ssp119_hwmax)
    delete(ssp119_hwmax_MMM)

    f_ssp126       = addfiles(fils_ssp126, "r")
    ListSetType (f_ssp126, "join") 
    ssp126_hwd     = f_ssp126[:]->hwd
    ssp126_hotday  = f_ssp126[:]->hotday
    ssp126_hwtimes = f_ssp126[:]->hwtimes
    ssp126_hwmax   = f_ssp126[:]->hwmax

    ssp126_hwd_MMM     = dim_avg_n_Wrap(ssp126_hwd, 0)
    ssp126_hotday_MMM  = dim_avg_n_Wrap(ssp126_hotday, 0)
    ssp126_hwtimes_MMM = dim_avg_n_Wrap(ssp126_hwtimes, 0)
    ssp126_hwmax_MMM   = dim_avg_n_Wrap(ssp126_hwmax, 0)

    cdf_ssp126  = diri_out+"ssp126_MMM_heatwave_"+per+"p_"+dur+"d_2040-2050_thresh2020-2050.nc"
    system("/bin/rm -f "+cdf_ssp126)    
    setfileoption("nc","Format","NetCDF4Classic")     
    ncdf_ssp126    = addfile(cdf_ssp126 ,"c")      
    ncdf_ssp126->hwd     = ssp126_hwd_MMM
    ncdf_ssp126->hotday  = ssp126_hotday_MMM
    ncdf_ssp126->hwtimes = ssp126_hwtimes_MMM
    ncdf_ssp126->hwmax   = ssp126_hwmax_MMM
    delete(ssp126_hwd)
    delete(ssp126_hwd_MMM)
    delete(ssp126_hotday)
    delete(ssp126_hotday_MMM)
    delete(ssp126_hwtimes)
    delete(ssp126_hwtimes_MMM)
    delete(ssp126_hwmax)
    delete(ssp126_hwmax_MMM)

    f_ssp534       = addfiles(fils_ssp534, "r")
    ListSetType (f_ssp534, "join") 
    ssp534_hwd     = f_ssp534[:]->hwd
    ssp534_hotday  = f_ssp534[:]->hotday
    ssp534_hwtimes = f_ssp534[:]->hwtimes
    ssp534_hwmax   = f_ssp534[:]->hwmax

    ssp534_hwd_MMM     = dim_avg_n_Wrap(ssp534_hwd, 0)
    ssp534_hotday_MMM  = dim_avg_n_Wrap(ssp534_hotday, 0)
    ssp534_hwtimes_MMM = dim_avg_n_Wrap(ssp534_hwtimes, 0)
    ssp534_hwmax_MMM   = dim_avg_n_Wrap(ssp534_hwmax, 0)

    cdf_ssp534  = diri_out+"ssp534_MMM_heatwave_"+per+"p_"+dur+"d_2040-2050_thresh2020-2050.nc"
    system("/bin/rm -f "+cdf_ssp534)    
    setfileoption("nc","Format","NetCDF4Classic")     
    ncdf_ssp534    = addfile(cdf_ssp534 ,"c")      
    ncdf_ssp534->hwd     = ssp534_hwd_MMM
    ncdf_ssp534->hotday  = ssp534_hotday_MMM
    ncdf_ssp534->hwtimes = ssp534_hwtimes_MMM
    ncdf_ssp534->hwmax   = ssp534_hwmax_MMM
    delete(ssp534_hwd)
    delete(ssp534_hwd_MMM)
    delete(ssp534_hotday)
    delete(ssp534_hotday_MMM)
    delete(ssp534_hwtimes)
    delete(ssp534_hwtimes_MMM)
    delete(ssp534_hwmax)
    delete(ssp534_hwmax_MMM)

    f_ssp585       = addfiles(fils_ssp585, "r")
    ListSetType (f_ssp585, "join") 
    ssp585_hwd     = f_ssp585[:]->hwd
    ssp585_hotday  = f_ssp585[:]->hotday
    ssp585_hwtimes = f_ssp585[:]->hwtimes
    ssp585_hwmax   = f_ssp585[:]->hwmax

    ssp585_hwd_MMM     = dim_avg_n_Wrap(ssp585_hwd, 0)
    ssp585_hotday_MMM  = dim_avg_n_Wrap(ssp585_hotday, 0)
    ssp585_hwtimes_MMM = dim_avg_n_Wrap(ssp585_hwtimes, 0)
    ssp585_hwmax_MMM   = dim_avg_n_Wrap(ssp585_hwmax, 0)

    cdf_ssp585  = diri_out+"ssp585_MMM_heatwave_"+per+"p_"+dur+"d_2040-2050_thresh2020-2050.nc"
    system("/bin/rm -f "+cdf_ssp585)    
    setfileoption("nc","Format","NetCDF4Classic")     
    ncdf_ssp585    = addfile(cdf_ssp585 ,"c")      
    ncdf_ssp585->hwd     = ssp585_hwd_MMM
    ncdf_ssp585->hotday  = ssp585_hotday_MMM
    ncdf_ssp585->hwtimes = ssp585_hwtimes_MMM
    ncdf_ssp585->hwmax   = ssp585_hwmax_MMM
    delete(ssp585_hwd)
    delete(ssp585_hwd_MMM)
    delete(ssp585_hotday)
    delete(ssp585_hotday_MMM)
    delete(ssp585_hwtimes)
    delete(ssp585_hwtimes_MMM)
    delete(ssp585_hwmax)
    delete(ssp585_hwmax_MMM)

end