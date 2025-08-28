
***
set processors 16  //  Parallel Computation



*** 【Reghdfe】 Installation for Multi-Dimensional Panel Fixed Effects Estimation
ssc install gtools, replace  // 第一步
ssc install reghdfe, replace // 第二步，安装最新版命令
ssc install ftools, replace  // 第三步 




*** Converting String Variables into Numeric Categorical Variables
encode  country, generate(country_id)
encode  sector, generate(sector_id)
encode  id, generate(id1)
encode  precip_abn_total_w_01_nozc, generate(precip_abn_total_w_01_nozc1)


*** Construction of Individual-Specific Time Trends
bys id1 (year): gen trend = _n    
gen trend2 = trend*trend


*** Data Preprocessing
gen cddyearavgdays_w_183c_01_1 = cddyearavgdays_w_183c_01/100 // Unit：100℃
gen cddyearavgdays_w_24c_01_1 = cddyearavgdays_w_24c_01/100   // Unit：100℃



*** Independence Test: Pearson Correlation	  
pwcorr cddyearavgdays_w_183c_01_1   hwdavgdays_w_95p_01 if sector_id==1 , sig		  


		  








/* ----------------【1. Main Results：Estimates of main regression and robustness tests】------------- */  

** (1) Baseline model  -  CDDs: Linear; Heatwave 95p; CDD 18.3°C

reghdfe eva_prod_growth1 ///
		cddyearavgdays_w_183c_01_1  c.cddyearavgdays_w_183c_01_1#c.hwdavgdays_w_95p_01  hwdavgdays_w_95p_01 /// 
		precipavgdays_era5_01_w  c.precipavgdays_era5_01_w#c.precipavgdays_era5_01_w /// 
		ib6.precip_abn_total_w_01_nozc /// 
		, absorb(  i.sector_id#i.year   i.sector_id#i.country_id   /// 
		i.year#i.poor  /// 
		i.WTO#i.year  i.OECD#i.year  i.EU#i.year  i.ASEAN#i.year i.APEC#i.year i.BR#i.year ) /// 
		vce(cluster id1)   // 

** Asymmetric economic effects of precipitation anomalies		
* SPI catergory: precip_abn_total_w_01_nozc
1. Drought 2. Heavy Precip. 3. Extreme Drought
4. Extreme Precip. 5. Precip. Decrease 6. Precip. Increase

nlcom _b[i5.precip_abn_total_w_01_nozc]-_b[i6.precip_abn_total_w_01_nozc] // Precipitation decrease vs. Precipitation increase
nlcom _b[i1.precip_abn_total_w_01_nozc]-_b[i2.precip_abn_total_w_01_nozc] // Drought vs. Heavy precipitation
nlcom _b[i3.precip_abn_total_w_01_nozc]-_b[i4.precip_abn_total_w_01_nozc] // Extreme drought vs. Extreme precipitation



** (2) Robustness  -  Heatwave 99p 

reghdfe eva_prod_growth1 ///
		cddyearavgdays_w_183c_01_1  c.cddyearavgdays_w_183c_01_1#c.hwdavgdays_w_99p_01  hwdavgdays_w_99p_01 /// 
		precipavgdays_era5_01_w  c.precipavgdays_era5_01_w#c.precipavgdays_era5_01_w /// 
		ib6.precip_abn_total_w_01_nozc /// 
		, absorb(  i.sector_id#i.year   i.sector_id#i.country_id   /// 
		i.year#i.poor  /// 
		i.WTO#i.year  i.OECD#i.year  i.EU#i.year  i.ASEAN#i.year i.APEC#i.year i.BR#i.year ) /// 
		vce(cluster id1)   // 


** (3) Robustness  -  Heatwave 90p 

reghdfe eva_prod_growth1 ///
		cddyearavgdays_w_183c_01_1  c.cddyearavgdays_w_183c_01_1#c.hwdavgdays_w_90p_01  hwdavgdays_w_90p_01 /// 
		precipavgdays_era5_01_w  c.precipavgdays_era5_01_w#c.precipavgdays_era5_01_w /// 
		ib6.precip_abn_total_w_01_nozc /// 
		, absorb(  i.sector_id#i.year   i.sector_id#i.country_id   /// 
		i.year#i.poor  /// 
		i.WTO#i.year  i.OECD#i.year  i.EU#i.year  i.ASEAN#i.year i.APEC#i.year i.BR#i.year ) /// 
		vce(cluster id1)   // 

		
** (4) Robustness  -  CDD-unrelated Heatwave 

* 【CDD-unrelated Heatwave】 Meteorological approach (see Compo and Sardeshmukh, 2010)

regress cddyearavgdays_w_183c_01_1  hwdavgdays_w_95p_01    //
** hwdavgdays_w_95p_01      coefficient：0.0231215  
	
*  adj_hwd_183c = hwdavgdays_w_95p_01 - 【0.0231215】* cddyearavgdays_w_183c_01 //  【CDD-unrelated Heatwave】

reghdfe eva_prod_growth1 ///
		cddyearavgdays_w_183c_01_1  c.cddyearavgdays_w_183c_01_1#c.adj_hwd_183c  adj_hwd_183c /// 
		precipavgdays_era5_01_w  c.precipavgdays_era5_01_w#c.precipavgdays_era5_01_w /// 
		ib6.precip_abn_total_w_01_nozc /// 
		, absorb(  i.sector_id#i.year   i.sector_id#i.country_id   /// 
		i.year#i.poor  /// 
		i.WTO#i.year  i.OECD#i.year  i.EU#i.year  i.ASEAN#i.year i.APEC#i.year i.BR#i.year ) /// 
		vce(cluster id1)   // 

		
** (5) Robustness  -  CDD 24°C

reghdfe eva_prod_growth1 ///
		cddyearavgdays_w_24c_01_1  c.cddyearavgdays_w_24c_01_1#c.hwdavgdays_w_95p_01  hwdavgdays_w_95p_01 /// 
		precipavgdays_era5_01_w  c.precipavgdays_era5_01_w#c.precipavgdays_era5_01_w /// 
		ib6.precip_abn_total_w_01_nozc /// 
		, absorb(  i.sector_id#i.year   i.sector_id#i.country_id   /// 
		i.year#i.poor  /// 
		i.WTO#i.year  i.OECD#i.year  i.EU#i.year  i.ASEAN#i.year i.APEC#i.year i.BR#i.year ) /// 
		vce(cluster id1)   // 

		
** (6) Robustness  -  NO CHN/USA

reghdfe eva_prod_growth1 ///
		cddyearavgdays_w_183c_01_1  c.cddyearavgdays_w_183c_01_1#c.hwdavgdays_w_95p_01  hwdavgdays_w_95p_01 /// 
		precipavgdays_era5_01_w  c.precipavgdays_era5_01_w#c.precipavgdays_era5_01_w /// 
		ib6.precip_abn_total_w_01_nozc /// 
		if  country_id ~= 35&176 /// NO CHN/USA		
		, absorb(  i.sector_id#i.year   i.sector_id#i.country_id   /// 
		i.year#i.poor  /// 
		i.WTO#i.year  i.OECD#i.year  i.EU#i.year  i.ASEAN#i.year i.APEC#i.year i.BR#i.year ) /// 
		vce(cluster id1)   // 

		
** (7) Robustness  -  NO EU

reghdfe eva_prod_growth1 ///
		cddyearavgdays_w_183c_01_1  c.cddyearavgdays_w_183c_01_1#c.hwdavgdays_w_95p_01  hwdavgdays_w_95p_01 /// 
		precipavgdays_era5_01_w  c.precipavgdays_era5_01_w#c.precipavgdays_era5_01_w /// 
		ib6.precip_abn_total_w_01_nozc /// 
		if  eu ~= 1 /// NO EU		
		, absorb(  i.sector_id#i.year   i.sector_id#i.country_id   /// 
		i.year#i.poor  /// 
		i.WTO#i.year  i.OECD#i.year  i.EU#i.year  i.ASEAN#i.year i.APEC#i.year i.BR#i.year ) /// 
		vce(cluster id1)   // 

		
** (8) Robustness  -  NO Yr × Poor FE

reghdfe eva_prod_growth1 ///
		cddyearavgdays_w_183c_01_1  c.cddyearavgdays_w_183c_01_1#c.hwdavgdays_w_95p_01  hwdavgdays_w_95p_01 /// 
		precipavgdays_era5_01_w  c.precipavgdays_era5_01_w#c.precipavgdays_era5_01_w /// 
		ib6.precip_abn_total_w_01_nozc /// 
		, absorb(  i.sector_id#i.year   i.sector_id#i.country_id   /// 
		///i.year#i.poor  /// 
		i.WTO#i.year  i.OECD#i.year  i.EU#i.year  i.ASEAN#i.year i.APEC#i.year i.BR#i.year ) /// 
		vce(cluster id1)   // 

		
		
** (9) Robustness  -  NO RTOs × Yr FE

reghdfe eva_prod_growth1 ///
		cddyearavgdays_w_183c_01_1  c.cddyearavgdays_w_183c_01_1#c.hwdavgdays_w_95p_01  hwdavgdays_w_95p_01 /// 
		precipavgdays_era5_01_w  c.precipavgdays_era5_01_w#c.precipavgdays_era5_01_w /// 
		ib6.precip_abn_total_w_01_nozc /// 
		, absorb(  i.sector_id#i.year   i.sector_id#i.country_id   /// 
		i.year#i.poor  /// 
		///i.WTO#i.year  i.OECD#i.year  i.EU#i.year  i.ASEAN#i.year i.APEC#i.year i.BR#i.year ) /// 
		vce(cluster id1)   // 
		

** (10) Robustness  -  Before COVID-19

reghdfe eva_prod_growth1 ///
		cddyearavgdays_w_183c_01_1  c.cddyearavgdays_w_183c_01_1#c.hwdavgdays_w_95p_01  hwdavgdays_w_95p_01 /// 
		precipavgdays_era5_01_w  c.precipavgdays_era5_01_w#c.precipavgdays_era5_01_w /// 
		ib6.precip_abn_total_w_01_nozc /// 
		if year < 2020  ///  Before the COVID-19 pandemic
		, absorb(  i.sector_id#i.year   i.sector_id#i.country_id   /// 
		i.year#i.poor  /// 
		i.WTO#i.year  i.OECD#i.year  i.EU#i.year  i.ASEAN#i.year i.APEC#i.year i.BR#i.year ) /// 
		vce(cluster id1)   // 

		
		
/* -----------【2. Alternative Specification：Estimates of main regression and robustness tests】---------- */  


** CDDs: Quadratic; Heatwave 95p; CDD 18.3°C

** (1) All sample

reghdfe eva_prod_growth1 ///
		cddyearavgdays_w_183c_01_1 c.cddyearavgdays_w_183c_01_1#c.cddyearavgdays_w_183c_01_1 /// 
		hwdavgdays_w_95p_01 c.cddyearavgdays_w_183c_01_1#c.hwdavgdays_w_95p_01  c.cddyearavgdays_w_183c_01_1#c.cddyearavgdays_w_183c_01_1#c.hwdavgdays_w_95p_01 /// 
		precipavgdays_era5_01_w  c.precipavgdays_era5_01_w#c.precipavgdays_era5_01_w /// 
		ib6.precip_abn_total_w_01_nozc /// 
		, absorb(  i.sector_id#i.year   i.sector_id#i.country_id   /// 
		i.year#i.poor  /// 
		i.WTO#i.year  i.OECD#i.year  i.EU#i.year  i.ASEAN#i.year i.APEC#i.year i.BR#i.year ) /// 
		vce(cluster id1)   // 

/*【Visualization】  Inverted U-shaped */ 
** Fig. 1a

sum  cddyearavgdays_w_183c_01_1 

margins  , at(cddyearavgdays_w_183c_01_1=(0(2)40))  //at(hwdavgdays_w_95p_01=(0(10)80 86))

marginsplot, recast(line) recastci(rarea) ///
             xlabel(0(10)40) ///
			 ///ytitle("∂Y/∂CDD") xtitle("Cooling Degree Days") ysize(5) 
			 ytitle("dY/dCDD") xtitle("Cooling Degree Days") ysize(4)

			 
** (2)  Poor countires v.s. Rich countries

reghdfe eva_prod_growth1 ///
		cddyearavgdays_w_183c_01_1 c.cddyearavgdays_w_183c_01_1#c.cddyearavgdays_w_183c_01_1 /// 
		hwdavgdays_w_95p_01 c.cddyearavgdays_w_183c_01_1#c.hwdavgdays_w_95p_01  c.cddyearavgdays_w_183c_01_1#c.cddyearavgdays_w_183c_01_1#c.hwdavgdays_w_95p_01 /// 
		i.poor#c.cddyearavgdays_w_183c_01_1 i.poor#c.cddyearavgdays_w_183c_01_1#c.cddyearavgdays_w_183c_01_1 ///
		i.poor#c.hwdavgdays_w_95p_01 i.poor#c.cddyearavgdays_w_183c_01_1#c.hwdavgdays_w_95p_01 i.poor#c.cddyearavgdays_w_183c_01_1#c.cddyearavgdays_w_183c_01_1#c.hwdavgdays_w_95p_01  /// 
		precipavgdays_era5_01_w  c.precipavgdays_era5_01_w#c.precipavgdays_era5_01_w /// 
		ib6.precip_abn_total_w_01_nozc /// 
		, absorb(  i.sector_id#i.year   i.sector_id#i.country_id   /// 
		i.year#i.poor  /// 
		i.WTO#i.year  i.OECD#i.year  i.EU#i.year  i.ASEAN#i.year i.APEC#i.year i.BR#i.year ) /// 
		vce(cluster id1)   //  
		
/*【Visualization】*/ 
** Fig. 1b

sum  cddyearavgdays_w_183c_01_1 

margins  poor , at(cddyearavgdays_w_183c_01_1=(0(2)40))  //at(hwdavgdays_w_95p_01=(0(10)80 86))

marginsplot, recast(line) recastci(rarea) ///
             xlabel(0(10)40) ///
			 ytitle("dY/dCDD") xtitle("Cooling Degree Days") ysize(4)
		
	
	
	
/* -----------------------------【3. Heterogeneous effect：Countries】-------------------- */  
	
	
** (1)  Poor countries  v.s.  Rich countries

reghdfe eva_prod_growth1 ///
		cddyearavgdays_w_183c_01_1  c.cddyearavgdays_w_183c_01_1#c.hwdavgdays_w_95p_01  hwdavgdays_w_95p_01 /// 
		i.poor#c.cddyearavgdays_w_183c_01_1 i.poor#c.cddyearavgdays_w_183c_01_1#c.hwdavgdays_w_95p_01  i.poor#c.hwdavgdays_w_95p_01   ///
		precipavgdays_era5_01_w  c.precipavgdays_era5_01_w#c.precipavgdays_era5_01_w /// 
		ib6.precip_abn_total_w_01_nozc /// 
		, absorb(  i.sector_id#i.year   i.sector_id#i.country_id   /// 
		i.year#i.poor  /// 
		i.WTO#i.year  i.OECD#i.year  i.EU#i.year  i.ASEAN#i.year i.APEC#i.year i.BR#i.year ) /// 
		vce(cluster id1)   // 

/*【Visualization】 */ 
** see Supplementary Fig. 1a	

margins poor , dydx(cddyearavgdays_w_183c_01_1) at(hwdavgdays_w_95p_01=(0(10)80 86)) 
marginsplot  , xlabel(0(10)80 ) ylabel(-3(1)1 ) ///
               ytitle("∂EVA / ∂CDD") xtitle("Heatwave Days") 
			 
		
	
** (2)  High inequality countries  v.s.  Low inequality countries

reghdfe eva_prod_growth1 ///
		cddyearavgdays_w_183c_01_1  c.cddyearavgdays_w_183c_01_1#c.hwdavgdays_w_95p_01  hwdavgdays_w_95p_01 /// 
		i.inequality#c.cddyearavgdays_w_183c_01_1 i.inequality#c.cddyearavgdays_w_183c_01_1#c.hwdavgdays_w_95p_01  i.inequality#c.hwdavgdays_w_95p_01   ///
		precipavgdays_era5_01_w  c.precipavgdays_era5_01_w#c.precipavgdays_era5_01_w /// 
		ib6.precip_abn_total_w_01_nozc /// 
		, absorb(  i.sector_id#i.year   i.sector_id#i.country_id   /// 
		i.year#i.poor  /// 
		i.WTO#i.year  i.OECD#i.year  i.EU#i.year  i.ASEAN#i.year i.APEC#i.year i.BR#i.year ) /// 
		vce(cluster id1)   // 

		
** (3)  High-tech countries  v.s.  Low-tech countries

reghdfe eva_prod_growth1 ///
		cddyearavgdays_w_183c_01_1  c.cddyearavgdays_w_183c_01_1#c.hwdavgdays_w_95p_01  hwdavgdays_w_95p_01 /// 
		i.hi_tech#c.cddyearavgdays_w_183c_01_1 i.hi_tech#c.cddyearavgdays_w_183c_01_1#c.hwdavgdays_w_95p_01  i.hi_tech#c.hwdavgdays_w_95p_01   ///
		precipavgdays_era5_01_w  c.precipavgdays_era5_01_w#c.precipavgdays_era5_01_w /// 
		ib6.precip_abn_total_w_01_nozc /// 
		, absorb(  i.sector_id#i.year   i.sector_id#i.country_id   /// 
		i.year#i.poor  /// 
		i.WTO#i.year  i.OECD#i.year  i.EU#i.year  i.ASEAN#i.year i.APEC#i.year i.BR#i.year ) /// 
		vce(cluster id1)   // 


** (4)  High unemployment countries  v.s.  Low unemployment countries

reghdfe eva_prod_growth1 ///
		cddyearavgdays_w_183c_01_1  c.cddyearavgdays_w_183c_01_1#c.hwdavgdays_w_95p_01  hwdavgdays_w_95p_01 /// 
		i.high_unemployment#c.cddyearavgdays_w_183c_01_1 i.high_unemployment#c.cddyearavgdays_w_183c_01_1#c.hwdavgdays_w_95p_01  i.high_unemployment#c.hwdavgdays_w_95p_01   ///
		precipavgdays_era5_01_w  c.precipavgdays_era5_01_w#c.precipavgdays_era5_01_w /// 
		ib6.precip_abn_total_w_01_nozc /// 
		, absorb(  i.sector_id#i.year   i.sector_id#i.country_id   /// 
		i.year#i.poor  /// 
		i.WTO#i.year  i.OECD#i.year  i.EU#i.year  i.ASEAN#i.year i.APEC#i.year i.BR#i.year ) /// 
		vce(cluster id1)   // 


** (5)  High altitude countries  v.s.  Low altitude countries

reghdfe eva_prod_growth1 ///
		cddyearavgdays_w_183c_01_1  c.cddyearavgdays_w_183c_01_1#c.hwdavgdays_w_95p_01  hwdavgdays_w_95p_01 /// 
		i.low_altitude#c.cddyearavgdays_w_183c_01_1 i.low_altitude#c.cddyearavgdays_w_183c_01_1#c.hwdavgdays_w_95p_01  i.low_altitude#c.hwdavgdays_w_95p_01   ///
		precipavgdays_era5_01_w  c.precipavgdays_era5_01_w#c.precipavgdays_era5_01_w /// 
		ib6.precip_abn_total_w_01_nozc /// 
		, absorb(  i.sector_id#i.year   i.sector_id#i.country_id   /// 
		i.year#i.poor  /// 
		i.WTO#i.year  i.OECD#i.year  i.EU#i.year  i.ASEAN#i.year i.APEC#i.year i.BR#i.year ) /// 
		vce(cluster id1)   // 

		
** (6)  High transparency countries  v.s.  Low transparency countries

reghdfe eva_prod_growth1 ///
		cddyearavgdays_w_183c_01_1  c.cddyearavgdays_w_183c_01_1#c.hwdavgdays_w_95p_01  hwdavgdays_w_95p_01 /// 
		i.high_transparency#c.cddyearavgdays_w_183c_01_1 i.high_transparency#c.cddyearavgdays_w_183c_01_1#c.hwdavgdays_w_95p_01  i.high_transparency#c.hwdavgdays_w_95p_01   ///
		precipavgdays_era5_01_w  c.precipavgdays_era5_01_w#c.precipavgdays_era5_01_w /// 
		ib6.precip_abn_total_w_01_nozc /// 
		, absorb(  i.sector_id#i.year   i.sector_id#i.country_id   /// 
		i.year#i.poor  /// 
		i.WTO#i.year  i.OECD#i.year  i.EU#i.year  i.ASEAN#i.year i.APEC#i.year i.BR#i.year ) /// 
		vce(cluster id1)   // 

		


/* ---------------------------【4. Heterogeneous effect：Sectors】---------------------- */  

** (1)  26 Sectors


reghdfe eva_prod_growth1 ///
		cddyearavgdays_w_183c_01_1  c.cddyearavgdays_w_183c_01_1#c.hwdavgdays_w_95p_01  hwdavgdays_w_95p_01 /// 
		i.sector_id#c.cddyearavgdays_w_183c_01_1 i.sector_id#c.cddyearavgdays_w_183c_01_1#c.hwdavgdays_w_95p_01  i.sector_id#c.hwdavgdays_w_95p_01   ///
		precipavgdays_era5_01_w  c.precipavgdays_era5_01_w#c.precipavgdays_era5_01_w /// 
		ib6.precip_abn_total_w_01_nozc /// 
		, absorb(  i.sector_id#i.year   i.sector_id#i.country_id   /// 
		i.year#i.poor  /// 
		i.WTO#i.year  i.OECD#i.year  i.EU#i.year  i.ASEAN#i.year i.APEC#i.year i.BR#i.year ) /// 
		vce(cluster id1)   // 

/*【Visualization】 */ 
** see Fig. 1e, 1g	

margins sector_id , dydx(cddyearavgdays_w_183c_01_1) at((p50)hwdavgdays_w_95p_01) /// at((p90)hwdavgdays_w_95p_01)
marginsplot       , ylabel(-6(2)2) ///
                    ytitle("∂EVA / ∂CDD") xtitle("Heatwave Days") 


					
** (2)  Six aggregated industry groups 

reghdfe eva_prod_growth1 ///
		cddyearavgdays_w_183c_01_1  c.cddyearavgdays_w_183c_01_1#c.hwdavgdays_w_95p_01  hwdavgdays_w_95p_01 /// 
		i.sector_new1#i.poor#c.cddyearavgdays_w_183c_01_1 i.sector_new1#i.poor#c.cddyearavgdays_w_183c_01_1#c.hwdavgdays_w_95p_01  i.sector_new1#i.poor#c.hwdavgdays_w_95p_01   ///
		precipavgdays_era5_01_w  c.precipavgdays_era5_01_w#c.precipavgdays_era5_01_w /// 
		ib6.precip_abn_total_w_01_nozc /// 
		, absorb(  i.sector_id#i.year   i.sector_id#i.country_id   /// 
		i.year#i.poor  /// 
		i.WTO#i.year  i.OECD#i.year  i.EU#i.year  i.ASEAN#i.year i.APEC#i.year i.BR#i.year ) /// 
		vce(cluster id1)   // 

/*【Visualization】 */   
** see Fig. 1f, 1h	
margins i.sector_new1#i.poor , dydx(cddyearavgdays_w_183c_01_1) at((p50)hwdavgdays_w_95p_01) 
marginsplot  , ylabel(-3(1)2) ///
               ytitle("∂EVA / ∂CDD") xtitle("Heatwave Days") 

	
	
		
/* ----------------------【5. Heterogeneous effect：Heatwave intensities】--------------------- */  
			
** (1) Heatwave Days (HWD)
** HWD: the total number of heatwave days per year 

reghdfe eva_prod_growth1 ///
		cddyearavgdays_w_183c_01_1  c.cddyearavgdays_w_183c_01_1#c.hwdavgdays_w_95p_01  hwdavgdays_w_95p_01 /// 
		i.poor#c.cddyearavgdays_w_183c_01_1 i.poor#c.cddyearavgdays_w_183c_01_1#c.hwdavgdays_w_95p_01  i.poor#c.hwdavgdays_w_95p_01   ///
		precipavgdays_era5_01_w  c.precipavgdays_era5_01_w#c.precipavgdays_era5_01_w /// 
		ib6.precip_abn_total_w_01_nozc /// 
		, absorb(  i.sector_id#i.year   i.sector_id#i.country_id   /// 
		i.year#i.poor  /// 
		i.WTO#i.year  i.OECD#i.year  i.EU#i.year  i.ASEAN#i.year i.APEC#i.year i.BR#i.year ) /// 
		vce(cluster id1)   // 

/*【Visualization】 */ 
** Supplementary Fig. 3a

margins      poor , dydx(cddyearavgdays_w_183c_01_1) at(hwdavgdays_w_95p_01=(0(10)90)) // 
marginsplot       , ylabel(-3(1)1) ///
                    ytitle("∂EVA / ∂CDD") xtitle("Heatwave Days") 

					
					
** (2) Hot Days (HD)
** HD: the total number of days per year with daily mean temperature exceeding the 95th percentile 

reghdfe eva_prod_growth1 ///
		cddyearavgdays_w_183c_01_1  c.cddyearavgdays_w_183c_01_1#c.hotdayavgdays_w_95p_01  hotdayavgdays_w_95p_01 /// 
		i.poor#c.cddyearavgdays_w_183c_01_1 i.poor#c.cddyearavgdays_w_183c_01_1#c.hotdayavgdays_w_95p_01  i.poor#c.hotdayavgdays_w_95p_01   ///
		precipavgdays_era5_01_w  c.precipavgdays_era5_01_w#c.precipavgdays_era5_01_w /// 
		ib6.precip_abn_total_w_01_nozc /// 
		, absorb(  i.sector_id#i.year   i.sector_id#i.country_id   /// 
		i.year#i.poor  /// 
		i.WTO#i.year  i.OECD#i.year  i.EU#i.year  i.ASEAN#i.year i.APEC#i.year i.BR#i.year ) /// 
		vce(cluster id1)   // 

/*【Visualization】 */ 
** Supplementary Fig. 3b

margins  poor , dydx(cddyearavgdays_w_183c_01_1)  at(hotdayavgdays_w_95p_01=(0(10)100)) 
marginsplot       , ylabel(-3(1)1) ///
                    ytitle("∂EVA / ∂CDD") xtitle("Heatwave Days") 
		
		
** (3) Heatwave Times (HWTimes)
** HWTimes: the annual number of discrete heatwave events per year. 

reghdfe eva_prod_growth1 ///
		cddyearavgdays_w_183c_01_1  c.cddyearavgdays_w_183c_01_1#c.hwtimesavgtimes_w_95p_01  hwtimesavgtimes_w_95p_01 /// 
		i.poor#c.cddyearavgdays_w_183c_01_1 i.poor#c.cddyearavgdays_w_183c_01_1#c.hwtimesavgtimes_w_95p_01  i.poor#c.hwtimesavgtimes_w_95p_01   ///
		precipavgdays_era5_01_w  c.precipavgdays_era5_01_w#c.precipavgdays_era5_01_w /// 
		ib6.precip_abn_total_w_01_nozc /// 
		, absorb(  i.sector_id#i.year   i.sector_id#i.country_id   /// 
		i.year#i.poor  /// 
		i.WTO#i.year  i.OECD#i.year  i.EU#i.year  i.ASEAN#i.year i.APEC#i.year i.BR#i.year ) /// 
		vce(cluster id1)   // 

margins  poor , dydx(cddyearavgdays_w_183c_01_1)  at(hwtimesavgtimes_w_95p_01=(0(2)20)) 


** (4) Heatwave Max (HTMax)
** HTMax: the duration (in days) of the longest single heatwave event each year.

reghdfe eva_prod_growth1 ///
		cddyearavgdays_w_183c_01_1  c.cddyearavgdays_w_183c_01_1#c.hwmaxavgdays_w_95p_01  hwmaxavgdays_w_95p_01 /// 
		i.poor#c.cddyearavgdays_w_183c_01_1 i.poor#c.cddyearavgdays_w_183c_01_1#c.hwmaxavgdays_w_95p_01  i.poor#c.hwmaxavgdays_w_95p_01   ///
		precipavgdays_era5_01_w  c.precipavgdays_era5_01_w#c.precipavgdays_era5_01_w /// 
		ib6.precip_abn_total_w_01_nozc /// 
		, absorb(  i.sector_id#i.year   i.sector_id#i.country_id   /// 
		i.year#i.poor  /// 
		i.WTO#i.year  i.OECD#i.year  i.EU#i.year  i.ASEAN#i.year i.APEC#i.year i.BR#i.year ) /// 
		vce(cluster id1)   // 

margins  poor , dydx(cddyearavgdays_w_183c_01_1)  at(hwmaxavgdays_w_95p_01=(0(5)52)) 
		

		
/* ----------------------【6. Heterogeneous effect：Regions】--------------------- */  
		
		
** Nine Regions:  
1. Caribbean      2. Central and East Asia         3. Europe
4. Latin America  5. Middle East and North Africa  6. North America
7. Oceania        8. South and Southeast Asia      9. Sub-Saharan Africa


reghdfe eva_prod_growth1 ///
		cddyearavgdays_w_183c_01_1  c.cddyearavgdays_w_183c_01_1#c.hwdavgdays_w_95p_01  hwdavgdays_w_95p_01 /// 
		precipavgdays_era5_01_w  c.precipavgdays_era5_01_w#c.precipavgdays_era5_01_w /// 
		ib6.precip_abn_total_w_01_nozc /// 
	    if  region_final == 6 ///  【Replaceable】
		, absorb(  i.sector_id#i.year   i.sector_id#i.country_id   /// 
		i.year#i.poor  /// 
		i.WTO#i.year  i.OECD#i.year  i.EU#i.year  i.ASEAN#i.year i.APEC#i.year i.BR#i.year ) /// 
		vce(cluster id1)   // 

/*【Visualization】 */ 
** Supplementary Fig. 7	
		
margins  , dydx(cddyearavgdays_w_183c_01_1)  at(hwdavgdays_w_95p_01=(0(10)90)) 
marginsplot  , ylabel(-6(1)6) ///
               ytitle("∂EVA / ∂CDD") xtitle("Heatwave Days") 

		
		
		
/* --------------------【7. Expected v.s. realized exposure to heat and economic losses】--------------- */  

** 1[Real > Expected]: an indicator variable 

** 1[Real > Expected] equals 1 in year t if the number of heatwave days in the current period (year t) exceeds the moving average of heatwave days over the preceding n years, and 0 otherwise. 



reghdfe eva_prod_growth1 ///       
        c.cddyearavgdays_w_183c_01_1#i.real_over_hist_1#i.poor  ///  real_over_hist_1 is 【replaceable】
		cddyearavgdays_w_183c_01_1 i.real_over_hist_1           ///  real_over_hist_1 is 【replaceable】
		precipavgdays_era5_01_w  c.precipavgdays_era5_01_w#c.precipavgdays_era5_01_w /// 
		ib6.precip_abn_total_w_01_nozc  /// 
		, absorb(  i.sector_id#i.year   i.sector_id#i.country_id  /// 
		i.year#i.poor  /// 
		i.WTO#i.year  i.OECD#i.year  i.EU#i.year i.ASEAN#i.year i.APEC#i.year i.BR#i.year ) /// 
		vce(cluster id1)   //  
  
margins i.real_over_hist_1#i.poor , dydx(cddyearavgdays_w_183c_01_1)  //

** Note: real_over_hist_n, where n=1,2,...,6


		
/* --------------------【8. Heat-induced cascading losses in global value chains (GVCs)】----------------- */  
			 
** Four-Dimensional Panel Setting
egen  id1 = group(country_id sector_id GVC)
tsset id1 year	
		
		
 ** (1) GVC Heterogeneity

reghdfe eva_prod_growth1 /// 
		cddyearavgdays_w_183c_01_1 c.cddyearavgdays_w_183c_01_1#c.hwdavgdays_w_95p_01  hwdavgdays_w_95p_01 /// 
		i.component_5#c.cddyearavgdays_w_183c_01_1 i.component_5#c.cddyearavgdays_w_183c_01_1#c.hwdavgdays_w_95p_01  i.component_5#c.hwdavgdays_w_95p_01  /// 
		precipavgdays_era5_01_w  c.precipavgdays_era5_01_w#c.precipavgdays_era5_01_w /// 
		ib6.precip_abn_total_w_01_nozc /// 
		, ///  
		absorb( i.sector_id#i.year   i.sector_id#i.country_id   /// 
		i.sector_id#i.component_5  i.country_id#i.component_5 i.year#i.component_5  /// 
		i.year#i.poor  /// 
		i.WTO#i.year  i.OECD#i.year  i.EU#i.year i.ASEAN#i.year i.APEC#i.year i.BR#i.year ) /// 
		vce(cluster id1)   //  


margins component_5 , dydx(cddyearavgdays_w_183c_01_1)  ///                  
                      at((p50)hwdavgdays_w_95p_01)      //    【Replaceable】
 
** Note: at((p25)hwdavgdays_w_95p_01), at((p50)hwdavgdays_w_95p_01), at((p75)hwdavgdays_w_95p_01), at((p90)hwdavgdays_w_95p_01), at((p99)hwdavgdays_w_95p_01)



 ** (2) GVC Heterogeneity Between Poor and Rich Countries

reghdfe eva_prod_growth1 /// 
		cddyearavgdays_w_183c_01_1 c.cddyearavgdays_w_183c_01_1#c.hwdavgdays_w_95p_01  hwdavgdays_w_95p_01 /// 
		i.poor#i.component_5#c.cddyearavgdays_w_183c_01_1 i.poor#i.component_5#c.cddyearavgdays_w_183c_01_1#c.hwdavgdays_w_95p_01  i.poor#i.component_5#c.hwdavgdays_w_95p_01  /// 
		precipavgdays_era5_01_w  c.precipavgdays_era5_01_w#c.precipavgdays_era5_01_w /// 
		ib6.precip_abn_total_w_01_nozc /// 
		, ///  
		absorb( i.sector_id#i.year   i.sector_id#i.country_id   /// 
		i.sector_id#i.component_5  i.country_id#i.component_5 i.year#i.component_5  /// 
		i.year#i.poor  /// 
		i.WTO#i.year  i.OECD#i.year  i.EU#i.year i.ASEAN#i.year i.APEC#i.year i.BR#i.year ) /// 
		vce(cluster id1)   //  

		
margins i.component_5#i.poor , dydx(cddyearavgdays_w_183c_01_1) ///
                               at((p50)hwdavgdays_w_95p_01)     // 【Replaceable】

** Note: at((p25)hwdavgdays_w_95p_01), at((p50)hwdavgdays_w_95p_01), at((p75)hwdavgdays_w_95p_01), at((p90)hwdavgdays_w_95p_01), at((p99)hwdavgdays_w_95p_01)
				

		
** (3) 	GVC Heterogeneity across sectors
	
reghdfe eva_prod_growth1 /// 
		cddyearavgdays_w_183c_01_1 c.cddyearavgdays_w_183c_01_1#c.hwdavgdays_w_95p_01  hwdavgdays_w_95p_01 /// 
		i.sector_id#i.component_5#c.cddyearavgdays_w_183c_01_1 i.sector_id#i.component_5#c.cddyearavgdays_w_183c_01_1#c.hwdavgdays_w_95p_01  i.sector_id#i.component_5#c.hwdavgdays_w_95p_01  /// 
		precipavgdays_era5_01_w  c.precipavgdays_era5_01_w#c.precipavgdays_era5_01_w /// 
		ib6.precip_abn_total_w_01_nozc /// 
		, ///  
		absorb( i.sector_id#i.year   i.sector_id#i.country_id   /// 
		i.sector_id#i.component_5  i.country_id#i.component_5 i.year#i.component_5  /// 
		i.year#i.poor  /// 
		i.WTO#i.year  i.OECD#i.year  i.EU#i.year i.ASEAN#i.year i.APEC#i.year i.BR#i.year ) /// 
		vce(cluster id1)   //  
	

margins i.component_5#i.sector_id , dydx(cddyearavgdays_w_183c_01_1) ///
        at(hwdavgdays_w_95p_01=15.6995)  // hwdavgdays_w_95p_01 at mean value


		
** (4) 	GVC Heterogeneity across countries and sectors
		
reghdfe eva_prod_growth1 /// 
		cddyearavgdays_w_183c_01_1 c.cddyearavgdays_w_183c_01_1#c.hwdavgdays_w_95p_01  hwdavgdays_w_95p_01 /// 
		i.sector_id#i.poor#i.component_5#c.cddyearavgdays_w_183c_01_1 i.sector_id#i.poor#i.component_5#c.cddyearavgdays_w_183c_01_1#c.hwdavgdays_w_95p_01  i.sector_id#i.poor#i.component_5#c.hwdavgdays_w_95p_01  /// 
		precipavgdays_era5_01_w  c.precipavgdays_era5_01_w#c.precipavgdays_era5_01_w /// 
		ib6.precip_abn_total_w_01_nozc /// 
		, ///  
		absorb( i.sector_id#i.year   i.sector_id#i.country_id   /// 
		i.sector_id#i.component_5  i.country_id#i.component_5 i.year#i.component_5  /// 
		i.year#i.poor  /// 
		i.WTO#i.year  i.OECD#i.year  i.EU#i.year i.ASEAN#i.year i.APEC#i.year i.BR#i.year ) /// 
		vce(cluster id1)   //  
	
	
** 【Data Stratification】

set processors 16   //  Parallel Computation  

** 【Parameter Settings】
1. poor=1, Rich;  poor=2, Poor
2. sector_id = 1, 2, ..., 26
3. component_5=(1(1)5)       


** Example 1, the heterogeneous effects of the five GVC components in 【Sector 11】 of 【Poor】 countries.

margins , dydx(cddyearavgdays_w_183c_01_1) ///
          at(sector_id=(11) poor=(2) component_5=(1(1)5) hwdavgdays_w_95p_01=15.6995 ) 

		  
** Example 2, the heterogeneous effects of the five GVC components in 【Sector 24】 of 【Poor】 countries.
	
margins , dydx(cddyearavgdays_w_183c_01_1) ///
          at(sector_id=(24) poor=(2) component_5=(1(1)5) hwdavgdays_w_95p_01=15.6995 )

		  
** Example 3, the heterogeneous effects of the five GVC components in 【Sector 24】 of 【Rich】 countries.
	
margins , dydx(cddyearavgdays_w_183c_01_1) ///
          at(sector_id=(24) poor=(1) component_5=(1(1)5) hwdavgdays_w_95p_01=15.6995 )


** Example 4, the heterogeneous effects of the five GVC components in 【Sector 10】 of 【Rich】 countries.

margins , dydx(cddyearavgdays_w_183c_01_1) ///
          at(sector_id=(10) poor=(1) component_5=(1(1)5) hwdavgdays_w_95p_01=15.6995 )

		  


/* ---------------------------------------------【9. Channels】------------------------------------------ */  

** (1) Sub-value added

1. Compensation of employees    // eva_prod_va1_growth1  
2. Net operating surplus        // eva_prod_va4_growth1
3. Net mixed income             // eva_prod_va5_growth1
4. Consumption of fixed capital // eva_prod_va6_growth1


reghdfe eva_prod_va1_growth1 ///  【replaceable】
		cddyearavgdays_w_183c_01_1  c.cddyearavgdays_w_183c_01_1#c.hwdavgdays_w_95p_01  hwdavgdays_w_95p_01 /// 
		i.poor#c.cddyearavgdays_w_183c_01_1 i.poor#c.cddyearavgdays_w_183c_01_1#c.hwdavgdays_w_95p_01  i.poor#c.hwdavgdays_w_95p_01   ///
		precipavgdays_era5_01_w  c.precipavgdays_era5_01_w#c.precipavgdays_era5_01_w /// 
		ib6.precip_abn_total_w_01_nozc /// 
		, absorb(  i.sector_id#i.year   i.sector_id#i.country_id   /// 
		i.year#i.poor  /// 
		i.WTO#i.year  i.OECD#i.year  i.EU#i.year  i.ASEAN#i.year i.APEC#i.year i.BR#i.year ) /// 
		vce(cluster id1)   // 

/*【Visualization】 */ 
** Supplementary Fig. 22	
		
margins      poor , dydx(cddyearavgdays_w_183c_01_1) at(hwdavgdays_w_95p_01=(0(10)90)) // 
marginsplot       , ylabel(-0.8(0.4)0.8) ///
                    ytitle("∂EVA / ∂CDD") xtitle("Heatwave Days") 

					

** (2) Sectoral market concentration, HHI
		
** (2.1) Heatwave 95p		
reghdfe hhi_growth ///  
		cddyearavgdays_w_183c_01_1  c.cddyearavgdays_w_183c_01_1#c.hwdavgdays_w_95p_01  hwdavgdays_w_95p_01 /// 
		i.poor#c.cddyearavgdays_w_183c_01_1 i.poor#c.cddyearavgdays_w_183c_01_1#c.hwdavgdays_w_95p_01  i.poor#c.hwdavgdays_w_95p_01   ///
		precipavgdays_era5_01_w  c.precipavgdays_era5_01_w#c.precipavgdays_era5_01_w /// 
		ib6.precip_abn_total_w_01_nozc /// 
		, absorb(  i.sector_id#i.year   i.sector_id#i.country_id   /// 
		i.year#i.poor  /// 
		i.WTO#i.year  i.OECD#i.year  i.EU#i.year  i.ASEAN#i.year i.APEC#i.year i.BR#i.year ) /// 
		vce(cluster id1)   // 

/*【Visualization】 */ 
** Supplementary Fig. 23a	
		
margins      poor , dydx(cddyearavgdays_w_183c_01_1) at(hwdavgdays_w_95p_01=(0(10)90)) // 
marginsplot       , ylabel(-0.03(0.01)0.03) ///
                    ytitle("∂EVA / ∂CDD") xtitle("Heatwave Days") 


** (2.2) Heatwave 99p							
reghdfe hhi_growth ///  
		cddyearavgdays_w_183c_01_1  c.cddyearavgdays_w_183c_01_1#c.hwdavgdays_w_99p_01  hwdavgdays_w_99p_01 /// 
		i.poor#c.cddyearavgdays_w_183c_01_1 i.poor#c.cddyearavgdays_w_183c_01_1#c.hwdavgdays_w_99p_01  i.poor#c.hwdavgdays_w_99p_01   ///
		precipavgdays_era5_01_w  c.precipavgdays_era5_01_w#c.precipavgdays_era5_01_w /// 
		ib6.precip_abn_total_w_01_nozc /// 
		, absorb(  i.sector_id#i.year   i.sector_id#i.country_id   /// 
		i.year#i.poor  /// 
		i.WTO#i.year  i.OECD#i.year  i.EU#i.year  i.ASEAN#i.year i.APEC#i.year i.BR#i.year ) /// 
		vce(cluster id1)   // 

/*【Visualization】 */ 
** Supplementary Fig. 23b	
		
margins      poor , dydx(cddyearavgdays_w_183c_01_1) at(hwdavgdays_w_99p_01=(0(5)45)) // 
marginsplot       , ylabel(-0.03(0.01)0.03) ///
                    ytitle("∂EVA / ∂CDD") xtitle("Heatwave Days") 
					
		
** (3) Sectoral labor inputs   

** Note: Dataset - Channel_3_Sector_level_labor_hours
	
reghdfe work_hour_growth1 ///  
		cddyearavgdays_w_183c_01_1  c.cddyearavgdays_w_183c_01_1#c.hwdavgdays_w_99p_01  hwdavgdays_w_99p_01 /// 
		i.poor#i.sector_id#c.cddyearavgdays_w_183c_01_1 i.poor#i.sector_id#c.cddyearavgdays_w_183c_01_1#c.hwdavgdays_w_99p_01  i.poor#i.sector_id#c.hwdavgdays_w_99p_01   ///
		precipavgdays_era5_01_w  c.precipavgdays_era5_01_w#c.precipavgdays_era5_01_w /// 
		ib6.precip_abn_total_w_01_nozc /// 
		, absorb(  i.sector_id#i.year   i.sector_id#i.country_id   /// 
		i.year#i.poor  /// 
		i.WTO#i.year  i.OECD#i.year  i.EU#i.year  i.ASEAN#i.year i.APEC#i.year i.BR#i.year ) /// 
		vce(cluster id1)   // 
		
margins i.poor#i.sector_id , dydx(cddyearavgdays_w_183c_01_1) at((p50)hwdavgdays_w_95p_01) 

