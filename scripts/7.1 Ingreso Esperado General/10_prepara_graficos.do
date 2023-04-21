
set trace off
set graph on

local tipo = "MCO_ingreso probit_pobreza"


*hago tablas de regresiones 
est clear
foreach i in $bases_eleccion {
	dis `i'
	eststo: estimates use "${path_ster}\\MCO_ingreso_`i'.ster"
	}

esttab using "${path_tables}\\regresion_IPCF", replace b(3) se(3) r2 noobs not mtitles("2003" "2007" "2011" "2015" "2019")	 /// 
	booktabs long alignment(D{.}{.}{-1}) 																					///
	title("Ingreso per cápita Familiar predicho")																		   ///
	addnotes("Elaboración propia en base a EPH")


estimates use "${path_ster}\\MCO_ingreso_1.ster"
loc variables = "`e(cmdline)'"
loc variables = subinstr("`variables'", "regress ln_ipcf_ppp11 ","",.)
di "`variables'"

*Abro la base con los predicts para recuperar los nombres de las columnas (sino en `variables' tengo los jj_*, no los nombres de las columnas verdaderas)
use "${path_dataout}\predict_censo.dta" in 1, clear
keep `variables'
order `variables'
ds
loc variables = r(varlist) /* ACA ROMPO TODO */
loc variables = "`variables' constant"
di "`variables'"

* Genero el excel con los betas
foreach t in `tipo' {
	capture mkdir "${path_figures}\graficos_regresion\\`t'"
	capture mkdir "${path_figures}\graficos_regresion\\`t'\png"
	capture mkdir "${path_figures}\graficos_regresion\\`t'\gph"
	mat define `t' = J(30,61,.)
	mat colnames `t' = `variables'
	forvalues i = 1/30{
		estimates use "${path_ster}\\`t'_`i'.ster"
		forvalues j = 1(1)61{
			mat `t'[`i',`j'] = e(b)[1,`j']
		}
	}
	putexcel set "D:\MECON\7. Ingreso Esperado\data\data_out\base_`t'.xlsx", replace
	putexcel A1 = matrix(`t'), colnames 
	


	import excel using "D:\MECON\7. Ingreso Esperado\data\data_out\base_`t'.xlsx", firstrow case(lower) clear
	save "D:\MECON\7. Ingreso Esperado\data\data_out\base_`t'", replace
	use "D:\MECON\7. Ingreso Esperado\data\data_out\base_`t'", clear
	*do "${path_scripts}\\10.1_ labels"
	ds
	loc variables = r(varlist)
	loc nivel_ed = "pric seci secc supi supc"
	loc grup_edad = "edad1217 edad1824 edad2540 edad4164 edad65"
	loc hogar = "hv_precaria hv_matpreca hv_agua hv_banio hv_cloacas hv_propieta"
	loc jefe = "jj_pric jj_seci jj_secc jj_supi jj_supc jj_hombre"
	loc regiones = "reg2 reg3 reg4 reg5 reg6 reg7 reg8 reg9 reg10 reg13 reg14 reg15 reg17 reg18 reg19 reg20 reg22 reg23 reg25 reg26 reg27 reg29 reg30 reg31 reg32 reg33 reg34 reg36"
	loc listas = "nivel_ed grup_edad hogar jefe"
	loc listas_n = "nivel_ed_`t'.gph grup_edad_`t'.gph hogar_`t'.gph jefe_`t'.gph"
	gen encuesta = _n

	foreach var in `variables'{
		twoway (scatter `var' encuesta) (lowess `var' encuesta)
		graph export "${path_figures}\graficos_regresion\\`t'\png\\`var'_`t'.png", replace
		graph save "${path_figures}\graficos_regresion\\`t'\gph\\`var'_`t'.gph", replace
	}
	
	foreach lista in `listas'{
		twoway (line ``lista'' encuesta), name(`lista', replace)legend(rows(2) symxsize(1.5) keygap(.005) textwidt() symysize(*))
		graph export "${path_figures}\graficos_regresion\\`t'\png\\`lista'_`t'.png", replace
		graph save "${path_figures}\graficos_regresion\\`t'\gph\\`lista'_`t'.gph", replace
	}
	*cd "${path_aux}"
	graph combine `listas', r(2) 
	graph export "${path_figures}\graficos_regresion\\`t'\png\listas_`t'.png", replace
	graph save "${path_figures}\graficos_regresion\\`t'\gph\\listas_`t'.gph", replace
}



// capture mkdir "${path_figures}\graficos_regresion\histogramas"
// forvalues i = 1/30{
// 	use "${path_dataout}\EPH_`i'.dta", clear 
// 	*kdensity resid 
// 	*graph export "${path_figures}\graficos_residuos\EPH_`i'.png", replace
// 	*graph save "${path_figures}\graficos_residuos\EPH_`i'.gph", replace
// 	hist ipcf_hat
// 	graph export "${path_figures}\graficos_regresion\histogramas\hist_ipcfhat_`i'.png", replace
// 	graph save "${path_figures}\graficos_regresion\histogramas\hist_ipcfhat_`i'.gph", replace
// 	hist ln_ipcf_hat 
// 	graph export "${path_figures}\graficos_regresion\histogramas\hist_ln_ipcfhat_`i'.png", replace
// 	graph save "${path_figures}\graficos_regresion\histogramas\hist_ln_ipcfhat_`i'.gph", replace
// }
//
//



