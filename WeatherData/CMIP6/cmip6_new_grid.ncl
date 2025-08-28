;;;
;;;
;;;
begin

    yrStrt_ssp= 2015
    yrLast_ssp= 2060
    year_ssp  = ispan(yrStrt_ssp,yrLast_ssp,1)         ; 要分析的年份
    year_ssp@units = "year from "+yrStrt_ssp
    nyear_ssp  = dimsizes(year_ssp)

;;;
    f_eg    = addfile("/mnt/f/Reanalysis/ERA5/hourly/daily/2m_temperature/ERA5-Land_daily_2m_temperature_0.1_1990_01.nc","r")
    new_lat = f_eg->latitude
    new_lon = f_eg->longitude
    printVarSummary(new_lat)
    printVarSummary(new_lon)

;;;
    exps  = (/"ssp119", "ssp126", "ssp534", "ssp585"/) ;;;
    N_exp = dimsizes(exps)

    models= (/"CanESM5", "CanESM5-1", "EC-Earth3-Veg", "EC-Earth3-Veg-LR", "FGOALS-g3", "IPSL-CM6A-LR", "MIROC6", "MPI-ESM1-2-LR", "MRI-ESM2-0"/) ;;;
    N_mod = dimsizes(models)

    do i = 0, N_exp-1

        do j = 0, N_mod-1
            diri = "/mnt/f/CMIP6/daily/"+exps(i)+"/"+models(j)+"/"
            fils = systemfunc("ls "+diri+"tas_day_"+models(j)+"_"+exps(i)+"*_r1i1p1f1_*.nc")
            N_fil= dimsizes(fils)

            diri_out = "/mnt/f/CMIP6/daily/new_grid/"+exps(i)+"/"

            if ((N_fil.eq.1).and.ismissing(fils)) then
                print(exps(i)+" "+models(j)+" have no data, please check")
                delete(fils)
                continue

            else
                fil_1  = addfile(fils(0),"r")  
                time   = fil_1->time    ; Time
                YYYYMMDD = cd_calendar(time, 2)      ; ALL dates assciated with precip  190001 190002
                print(exps(i)+" "+models(j)+" data from "+YYYYMMDD(0))
                delete(fil_1)
                delete(time)
                delete(YYYYMMDD)

                if (N_fil.eq.1) then

                    f_var  = addfile(fils, "r")
                    time   = f_var->time
                    YYYYMMDD = cd_calendar(time, 2)

                    do k = 0, nyear_ssp-1
                        ymdStrt_ssp = year_ssp(k)*10000 +  1*100 +  1
                        ymdLast_ssp = year_ssp(k)*10000 + 12*100 + 31

                        tStrt  = ind(YYYYMMDD.eq.ymdStrt_ssp)        ; indices of selected times
                        tLast  = ind(YYYYMMDD.eq.ymdLast_ssp)

                        tas    = f_var->tas(tStrt:tLast,::-1,:)

                        tas_new = linint2_Wrap(tas&lon,tas&lat,tas,True,new_lon,new_lat,0)
                        tas_new!1 = "lat"
                        tas_new&lat = new_lat
                        tas_new!2 = "lon"
                        tas_new&lon = new_lon
                        delete(tStrt)
                        delete(tLast)
                        delete(tas)

                        cdf_tas = diri_out+"tas_day_"+models(j)+"_"+exps(i)+"_r1i1p1f1_0.1_"+ymdStrt_ssp+"-"+ymdLast_ssp+".nc"
                        system("/bin/rm -f "+cdf_tas)    
                        setfileoption("nc","Format","NetCDF4Classic")     
                        ncdf_tas    = addfile(cdf_tas ,"c")      
                        ncdf_tas->tas = tas_new
                        delete(ymdStrt_ssp)
                        delete(ymdLast_ssp)
                        delete(tas_new)
                    end do

                    delete(fils)
                    delete(N_fil)
                    delete(f_var)
                    delete(time)
                    delete(YYYYMMDD)

                    print(models(j)+" "+exps(i)+" tas deal over")                    
                else
                    
                    f_var  = addfiles(fils, "r")
                    aa_all = f_var[:]->tas

                    time   = aa_all&time
                    YYYYMMDD = cd_calendar(time, 2)      ; ALL dates assciated with uaecip  190001 190002

                    do k = 0, nyear_ssp-1
                        ymdStrt_ssp = year_ssp(k)*10000 +  1*100 +  1
                        ymdLast_ssp = year_ssp(k)*10000 + 12*100 + 31

                        tStrt  = ind(YYYYMMDD.eq.ymdStrt_ssp)        ; indices of selected times
                        tLast  = ind(YYYYMMDD.eq.ymdLast_ssp)

                        tas    = aa_all(tStrt:tLast,::-1,:)

                        tas_new = linint2_Wrap(tas&lon,tas&lat,tas,True,new_lon,new_lat,0)
                        tas_new!1 = "lat"
                        tas_new&lat = new_lat
                        tas_new!2 = "lon"
                        tas_new&lon = new_lon
                        delete(tStrt)
                        delete(tLast)
                        delete(tas)

                        cdf_tas = diri_out+"tas_day_"+models(j)+"_"+exps(i)+"_r1i1p1f1_0.1_"+ymdStrt_ssp+"-"+ymdLast_ssp+".nc"
                        system("/bin/rm -f "+cdf_tas)    
                        setfileoption("nc","Format","NetCDF4Classic")     
                        ncdf_tas    = addfile(cdf_tas ,"c")      
                        ncdf_tas->tas = tas_new
                        delete(ymdStrt_ssp)
                        delete(ymdLast_ssp)
                        delete(tas_new)
                    end do

                    delete(fils)
                    delete(N_fil)
                    delete(f_var)
                    delete(time)
                    delete(YYYYMMDD)
                    delete(aa_all)

                    print(models(j)+" "+exps(i)+" tas deal over")  

                end if

            end if

        end do

    end do
    
end