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


* variables independientes
loc vjefe "c.hombre c.edad c.edad2 c.pric c.seci c.secc c.supi c.supc"
loc vviv "c.hv_precaria c.hv_matpreca c.hv_agua c.hv_banio c.hv_cloacas c.hv_propieta "
loc vhog "c.hv_miemhabi c.miembros " 
loc vreg "reg3 reg4 reg5 reg6 reg7 reg8 reg9 reg10 reg12 reg13 reg14 reg15 reg17 reg18 reg19 reg20 reg22 reg23 reg25 reg26 reg27 reg29 reg30 reg31 reg32 reg33 reg34 reg36 "

loc i = $eph_seleccionada

drop _all
est clear
noi di "i: `i'"
noi use "${path_datain}\\EPH SEDLAS\\`base_`i''_v03_M_v01_A_SEDLAC-03_all.dta"
noi include "${path_scripts}\01a_variables_censo.doi"
keep if jefe ==1 & aglomerado <= 36
save "${path_dataout}\\`base_`i''_v03_M_v01_A_SEDLAC-03_proc.dta", replace
exit

// capture erase  "${path_tables}\modelos_`i'.xlsx"
//
// ******************
// *MCO Ingreso
// eststo: noi reg ln_ipcf_ppp11 `vjefe' `vviv' `vhog' `vreg'
// *esttab, b(3) not noobs mtitle("Ingreso Esperado")
// esttab using "${path_tables}\\regresion_`i'", replace b(3) se(3) noobs not mtitle("Ingreso Esperado")	 ///
// booktabs long alignment(D{.}{.}{-1}) 																		///
// title("Tabla `i'") addnotes("Elaboración propia en base a EPH")
// noi estimates save "${path_dataout}\ster\MCO_ingreso_`i'", replace
// capture erase  "${path_dataout}\ster\MCO_ingreso_`i'.txt"
// outreg2 using  "${path_dataout}\ster\MCO_ingreso_`i'.txt", append ctitle("`EPH_`i''")
// outreg2 using  "${path_tables}\modelos_`i'.xlsx", append ctitle("MCO")
//
// * exporto outreg a excel
// preserve
// drop _all
// import delimited using "${path_dataout}\ster\MCO_ingreso_`i'.txt", clear
// export excel using "${path_tables}\MCO_ingreso.xlsx", cell(a1) sheetmodify sheet("MCO_ingreso`i'")
// restore
// ******************