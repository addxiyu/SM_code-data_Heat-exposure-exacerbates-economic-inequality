;;;
;;;
;;;
begin
;;;
    threshold = "18.3"

;;;
    diri_ssp119 = "/mnt/x/CMIP6_SSP/new_CDD/ssp119/"
    diri_ssp126 = "/mnt/x/CMIP6_SSP/new_CDD/ssp126/"
    diri_ssp534 = "/mnt/x/CMIP6_SSP/new_CDD/ssp534/"
    diri_ssp585 = "/mnt/x/CMIP6_SSP/new_CDD/ssp585/"

    diri_out    = "/mnt/x/CMIP6_SSP/new_CDD/"

    fils_ssp119 = systemfunc("ls "+diri_ssp119+"CDD_*_ssp119_"+threshold+"degC_2023-2050.nc")
    fils_ssp126 = systemfunc("ls "+diri_ssp126+"CDD_*_ssp126_"+threshold+"degC_2023-2050.nc")
    fils_ssp534 = systemfunc("ls "+diri_ssp534+"CDD_*_ssp534_"+threshold+"degC_2040-2050.nc")
    fils_ssp585 = systemfunc("ls "+diri_ssp585+"CDD_*_ssp585_"+threshold+"degC_2023-2050.nc")
    print(fils_ssp119)
    print(fils_ssp126)
    print(fils_ssp534)
    print(fils_ssp585)

    f_ssp119    = addfiles(fils_ssp119, "r")
    ListSetType (f_ssp119, "join") 
    ssp119_CDD  = f_ssp119[:]->CDDyear   
    printVarSummary(ssp119_CDD)
    ssp119_CDD_MMM = dim_avg_n_Wrap(ssp119_CDD, 0)
    printVarSummary(ssp119_CDD_MMM)
    cdf_ssp119  = diri_out+"CDD_ssp119_MMM_"+threshold+"degC_2023-2050.nc"
    system("/bin/rm -f "+cdf_ssp119)    
    setfileoption("nc","Format","NetCDF4Classic")     
    ncdf_ssp119    = addfile(cdf_ssp119 ,"c")      
    ncdf_ssp119->CDDyear = ssp119_CDD_MMM
    delete(ssp119_CDD)
    delete(ssp119_CDD_MMM)

    f_ssp126    = addfiles(fils_ssp126, "r")
    ListSetType (f_ssp126, "join") 
    ssp126_CDD  = f_ssp126[:]->CDDyear   
    printVarSummary(ssp126_CDD)
    ssp126_CDD_MMM = dim_avg_n_Wrap(ssp126_CDD, 0)
    cdf_ssp126  = diri_out+"CDD_ssp126_MMM_"+threshold+"degC_2023-2050.nc"
    system("/bin/rm -f "+cdf_ssp126)    
    setfileoption("nc","Format","NetCDF4Classic")     
    ncdf_ssp126    = addfile(cdf_ssp126 ,"c")      
    ncdf_ssp126->CDDyear = ssp126_CDD_MMM
    delete(ssp126_CDD)
    delete(ssp126_CDD_MMM)

    f_ssp534    = addfiles(fils_ssp534, "r")
    ListSetType (f_ssp534, "join") 
    ssp534_CDD  = f_ssp534[:]->CDDyear   
    printVarSummary(ssp534_CDD)
    ssp534_CDD_MMM = dim_avg_n_Wrap(ssp534_CDD, 0)
    cdf_ssp534  = diri_out+"CDD_ssp534_MMM_"+threshold+"degC_2040-2050.nc"
    system("/bin/rm -f "+cdf_ssp534)    
    setfileoption("nc","Format","NetCDF4Classic")     
    ncdf_ssp534    = addfile(cdf_ssp534 ,"c")      
    ncdf_ssp534->CDDyear = ssp534_CDD_MMM
    delete(ssp534_CDD)
    delete(ssp534_CDD_MMM)

    f_ssp585    = addfiles(fils_ssp585, "r")
    ListSetType (f_ssp585, "join") 
    ssp585_CDD  = f_ssp585[:]->CDDyear   
    ssp585_CDD_MMM = dim_avg_n_Wrap(ssp585_CDD, 0)
    cdf_ssp585  = diri_out+"CDD_ssp585_MMM_"+threshold+"degC_2023-2050.nc"
    system("/bin/rm -f "+cdf_ssp585)    
    setfileoption("nc","Format","NetCDF4Classic")     
    ncdf_ssp585    = addfile(cdf_ssp585 ,"c")      
    ncdf_ssp585->CDDyear = ssp585_CDD_MMM
    delete(ssp585_CDD)
    delete(ssp585_CDD_MMM)
end