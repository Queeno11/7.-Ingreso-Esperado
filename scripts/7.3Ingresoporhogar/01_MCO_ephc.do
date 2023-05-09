drop _all
loc base_1  "ARG_2003_EPHC-S2"
loc base_2  "ARG_2004_EPHC-S1"
loc base_3  "ARG_2004_EPHC-S2"
loc base_4  "ARG_2005_EPHC-S1"
loc base_5  "ARG_2005_EPHC-S2"
loc base_6  "ARG_2006_EPHC-S1"
loc base_7  "ARG_2006_EPHC-S2"
loc base_8  "ARG_2007_EPHC-S1"
loc base_9  "ARG_2007_EPHC-S2"
loc base_10 "ARG_2008_EPHC-S1"
loc base_11 "ARG_2008_EPHC-S2"
loc base_12 "ARG_2009_EPHC-S1"
loc base_13 "ARG_2009_EPHC-S2"
loc base_14 "ARG_2010_EPHC-S1"
loc base_15 "ARG_2010_EPHC-S2"
loc base_16 "ARG_2011_EPHC-S1"
loc base_17 "ARG_2011_EPHC-S2"
loc base_18 "ARG_2012_EPHC-S1"
loc base_19 "ARG_2012_EPHC-S2"
loc base_20 "ARG_2013_EPHC-S1"
loc base_21 "ARG_2013_EPHC-S2"
loc base_22 "ARG_2014_EPHC-S1"
loc base_23 "ARG_2014_EPHC-S2"
loc base_24 "ARG_2015_EPHC-S1"

loc base_25 "ARG_2016_EPHC-S2"
loc base_26 "ARG_2017_EPHC-S1"
loc base_27 "ARG_2017_EPHC-S2"
loc base_28 "ARG_2018_EPHC-S1"
loc base_29 "ARG_2018_EPHC-S2"
loc base_30 "ARG_2019_EPHC-S1" 


* variables independientes pablo 
loc vjefe "c.hombre c.edad c.edad2 c.edad2540 c.edad4164 c.edad65 c.pric c.seci c.secc c.supi c.supc"
*****hombre no la usa? xq? 
loc vviv "c.hv_precaria c.hv_matpreca c.hv_agua c.hv_banio c.hv_cloacas c.hv_propieta "
loc vhog "c.hv_miemhabi c.miembros " 
loc vreg "reg3 reg4 reg5 reg6 reg7 reg8 reg9 reg10 reg12 reg13 reg14 reg15 reg17 reg18 reg19 reg20 reg22 reg23 reg25 reg26 reg27 reg29 reg30 reg31 reg32 reg33 reg34 reg36 "


* variables independientes
loc vjefe "c.hombre c.edad c.edad2 c.pric c.seci c.secc c.supi c.supc"
loc vviv "c.hv_precaria c.hv_matpreca c.hv_agua c.hv_banio c.hv_cloacas c.hv_propieta "
loc vhog "c.hv_miemhabi c.miembros " 
loc vreg "reg3 reg4 reg5 reg6 reg7 reg8 reg9 reg10 reg12 reg13 reg14 reg15 reg17 reg18 reg19 reg20 reg22 reg23 reg25 reg26 reg27 reg29 reg30 reg31 reg32 reg33 reg34 reg36 "


 forvalues i =1/$total_bases {
	drop _all
	est clear
	noi di "i `i'"
	noi use "${path_datain}\\EPH SEDLAS\\`base_`i''_v03_M_v01_A_SEDLAC-03_all.dta"
	noi include "${path_scripts}\01a_variables_censo.doi"
	keep if jefe ==1 & aglomerado <= 36
	
	capture erase  "${path_tables}\modelos_`i'.xlsx"
	******************
	*MCO Ingreso
	eststo: noi reg ln_ipcf_ppp11 `vjefe' `vviv' `vhog' `vreg'
	*esttab, b(3) not noobs mtitle("Ingreso Esperado")
	esttab using "${path_tables}\\regresion_`i'", replace b(3) se(3) noobs not mtitle("Ingreso Esperado")	 ///
	 booktabs long alignment(D{.}{.}{-1}) 																		///
	title("Tabla `i'") addnotes("Elaboración propia en base a EPH")
	noi estimates save "${path_dataout}\ster\MCO_ingreso_`i'", replace
	capture erase  "${path_dataout}\ster\MCO_ingreso_`i'.txt"
	outreg2 using  "${path_dataout}\ster\MCO_ingreso_`i'.txt", append ctitle("`EPH_`i''")
	outreg2 using  "${path_tables}\modelos_`i'.xlsx", append ctitle("MCO")
	
	* exporto outreg a excel
	preserve
	drop _all
	insheet using "${path_dataout}\ster\MCO_ingreso_`i'.txt"
	export excel using "${path_tables}\MCO_ingreso.xlsx", cell(a1) sheetmodify sheet("MCO_ingreso`i'")
	restore

	******************
	*MCO Ingreso x aglo 
	eststo: noi reg ln_ipcf_ppp11 (`vjefe' `vviv' `vhog')##i.aglo
	*esttab, b(3) not noobs mtitle("Ingreso Esperado")
	esttab using "${path_tables}\\regresion_`i'", replace b(3) se(3) noobs not mtitle("Ingreso Esperado")	 ///
	 booktabs long alignment(D{.}{.}{-1}) 																		///
	title("Tabla `i'") addnotes("Elaboración propia en base a EPH")
	noi estimates save "${path_dataout}\ster\MCO_ingresoxaglo_`i'", replace
	capture erase  "${path_dataout}\ster\MCO_ingresoxaglo_`i'.txt"
	outreg2 using  "${path_dataout}\ster\MCO_ingresoxaglo_`i'.txt", append ctitle("`EPH_`i''")
	outreg2 using  "${path_tables}\modelos_`i'.xlsx", append ctitle("MCO_xaglo")
	
	* exporto outreg a excel
	preserve
	drop _all
	insheet using "${path_dataout}\ster\MCO_ingresoxaglo_`i'.txt"
	export excel using "${path_tables}\MCO_ingresoxaglo.xlsx", cell(a1) sheetmodify sheet("MCO_ingresoxaglo`i'")
	restore
	
	
	******************
	*MCO Ingreso x aglo (un #)
	eststo: noi reg ln_ipcf_ppp11 (`vjefe' `vviv' `vhog')#i.aglo
	*esttab, b(3) not noobs mtitle("Ingreso Esperado")
	esttab using "${path_tables}\\regresion_`i'", replace b(3) se(3) noobs not mtitle("Ingreso Esperado")	 ///
	 booktabs long alignment(D{.}{.}{-1}) 																		///
	title("Tabla `i'") addnotes("Elaboración propia en base a EPH")
	noi estimates save "${path_dataout}\ster\MCO_ingresoxaglo_noef_`i'", replace
	capture erase  "${path_dataout}\ster\MCO_ingresoxaglo_noef_`i'.txt"
	outreg2 using  "${path_dataout}\ster\MCO_ingresoxaglo_noef_`i'.txt", append ctitle("`EPH_`i''")
	outreg2 using  "${path_tables}\modelos_`i'.xlsx", append ctitle("MCO_xaglo_sinef")
	
	* exporto outreg a excel
	preserve
	drop _all
	insheet using "${path_dataout}\ster\MCO_ingresoxaglo_noef_`i'.txt"
	export excel using "${path_tables}\MCO_ingresoxaglo_noef.xlsx", cell(a1) sheetmodify sheet("MCO_ingresoxaglo_noef`i'")
	restore
	
	******************
	*MCO Ingreso sin aglo 
	eststo: noi reg ln_ipcf_ppp11 `vjefe' `vviv' `vhog'
	*esttab, b(3) not noobs mtitle("Ingreso Esperado")
	esttab using "${path_tables}\\regresion_`i'", replace b(3) se(3) noobs not mtitle("Ingreso Esperado")	 ///
	 booktabs long alignment(D{.}{.}{-1}) 																		///
	title("Tabla `i'") addnotes("Elaboración propia en base a EPH")
	noi estimates save "${path_dataout}\ster\MCO_ingreso_sin_aglo_`i'", replace
	capture erase  "${path_dataout}\ster\MCO_ingreso_sin_aglo_`i'.txt"
	outreg2 using  "${path_dataout}\ster\MCO_ingreso_sin_aglo_`i'.txt", append ctitle("`EPH_`i''")
	outreg2 using  "${path_tables}\modelos_`i'.xlsx", append ctitle("MCO_sinaglo")
	
	* exporto outreg a excel
	preserve
	drop _all
	insheet using "${path_dataout}\ster\MCO_ingreso_sin_aglo_`i'.txt"
	export excel using "${path_tables}\MCO_ingreso_sin_aglo.xlsx", cell(a1) sheetmodify sheet("MCO_ingreso_sin_aglo`i'")
	restore
	
	******************
	*Probit pobreza 
	noi probit pobre_mod `vjefe' `vviv' `vhog' `vreg'
	noi estimates save "${path_dataout}\ster\probit_pobreza_`i'", replace
	capture erase  "${path_dataout}\ster\probit_pobreza_`i'.txt"
	outreg2 using  "${path_dataout}\ster\probit_pobreza_`i'.txt", append ctitle("`EPH_`i''")
	
	* exporto outreg a excel
	preserve
	drop _all
	insheet using "${path_dataout}\ster\probit_pobreza_`i'.txt"
	export excel using "${path_tables}\probit_pobreza_.xlsx", cell(a1) sheetmodify sheet("probit_pobreza`i'")
	restore
	}

if "${analisis_modelos}" == "SI" {
include "${path_scripts}\01b_analisis_modelos.doi"
}