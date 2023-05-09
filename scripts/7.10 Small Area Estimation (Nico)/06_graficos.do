
set graph off
******************************************
*Análisis de los modelos 
******************************************

use "${path_dataout}\compara\EPH10_mco", clear 


forvalues i = 2(1)4 {
	merge 1:1 id com using "${path_dataout}\compara\EPH10_mco`i'", nogen 
	}

	keep if jefe == 1 
	keep if aglomerado<=36
save "${path_dataout}\compara\EPH10_modelos", replace  


set graph on
kdensity ln_ipcf_ppp11 if ln_ipcf_ppp11 > 4 & ln_ipcf_ppp11 < 8, addplot(kdensity ee_ln_mco10 || kdensity ee_ln_mco210 || kdensity ee_ln_mco310 || kdensity ee_ln_mco410)

loc lista_aglo = ""


	
foreach aglo in 32 33  {
	capture kdensity ln_ipcf_ppp11  if aglomerado == `aglo' &  ln_ipcf_ppp11 > 4 & ln_ipcf_ppp11 < 8, addplot(kdensity ee_ln_mco10  if aglomerado == `aglo' &  ln_ipcf_ppp11 > 4 & ln_ipcf_ppp11 < 8 || kdensity ee_ln_mco210  if aglomerado == `aglo' &  ln_ipcf_ppp11 > 4 & ln_ipcf_ppp11 < 8 || kdensity ee_ln_mco310  if aglomerado == `aglo' &  ln_ipcf_ppp11 > 4 & ln_ipcf_ppp11 < 8|| kdensity ee_ln_mco410 if aglomerado == `aglo' &  ln_ipcf_ppp11 > 4 & ln_ipcf_ppp11 < 8) name(g`aglo')
	if _rc ==0 {
		loc lista_aglo = "`lista_aglo' g`aglo'"
	}	
}


graph combine g32 g33





















use "${path_dataout}\analisis_modelos.dta", clear

loc lisvar = "lowess ee_dif_mco1 cc_ipcf_ppp11, sort legend(off)"
loc lisvar2 = "qfit ee_dif_mco1 cc_ipcf_ppp11, sort legend(off)"
loc lisvarres = "lowess ee_res_mco1 cc_ipcf_ppp11, sort legend(off)"
loc lisvarres2 = "qfit ee_res_mco1 cc_ipcf_ppp11, sort legend(off)"


forvalues i = 2(1)$total_bases {
	loc lisvar = "`lisvar' ||lowess ee_dif_mco`i' cc_ipcf_ppp11, sort legend(off)"
	loc lisvar2 = "`lisvar2' ||qfit ee_dif_mco`i' cc_ipcf_ppp11, sort legend(off)"
	loc lisvarres = "`lisvarres' ||lowess ee_res_mco`i' cc_ipcf_ppp11, sort legend(off)"
	loc lisvarres2 = "`lisvarres2' ||qfit ee_res_mco`i' cc_ipcf_ppp11, sort legend(off)"
}


loc xtit1  xtitle("Percentiles IPCF") 
loc ytit1  ytitle("IPCF real / IPCF estimado") 
loc yline1 yline(1,  lpattern("- ##") lcolor(black))
loc xtit2  xtitle("IPCF") 
loc ytit2  ytitle("Densidad")
loc xtit3  xtitle("Percentiles IPCF") 
loc ytit3  ytitle("IPCF") 
loc ytit4  ytitle("ln(IPCF)") 
loc legreal legend(label(1 "IPCF real"))
loc legesti legend(label(2 "IPCF estimado")) 
loc legreal2 legend(label(1 "IPCF estimado por MCO"))
loc legesti2 legend(label(2 "IPCF estimado por Lasso")) 
loc legreal3 legend(label(1 "ln(IPCF real)"))
loc legesti3 legend(label(2 "ln(IPCF estimado)")) 
loc leggen  legend(size(*0.5) symxsize(*.5)  rows(1))
loc gra1 `xtit1' `ytit1' `yline1' 
loc gra2 `xtit2' `ytit2' `legreal' `legesti' `leggen'
loc gra3 `xtit2' `ytit2' `legreal2' `legesti2' `leggen'
loc gra4 `xtit2' `ytit2' `legreal3' `legesti3' `leggen'
loc gra5 `xtit1' `ytit1' `yline1'  `leggen' legend(label( 1 "IPCF real / IPCF estimado"))
loc gra6 `xtit3' `ytit3' `legreal' `legesti' `leggen'
loc gra7 `xtit3' `ytit4' `legreal3' `legesti3' `leggen'


twoway `lisvar2' , `gra1' 
graph export "${path_figures}\compara\diferencias_intertermporales2.png", replace
graph save "${path_figures}\compara\graph\diferencias_intertermporales2.gph", replace

twoway `lisvar' , `gra1'
graph export "${path_figures}\compara\diferencias_intertermporales.png", replace
graph save "${path_figures}\compara\graph\diferencias_intertermporales.gph", replace

use "${path_dataout}\compara\EPH1", clear
foreach var in edad edad2 aglomerado miembros miembros2 {

twoway scatter `var' cc_ipcf_ppp11 if cc_ipcf_ppp11 <99 & cc_ipcf_ppp11 >2, msize(vtiny) ||  scatter `var' cc_ipcf_ppp11 if cc_ipcf_ppp11 <99 & cc_ipcf_ppp11 >2, yline(0,  lpattern("- ##") lcolor(black))

graph export "${path_figures}\compara\aaaa`var'.png", replace
graph save "${path_figures}\compara\graph\`var'.gph", replace

}

capture drop ee_res_mco1c
gen ee_res_mco1c = ee_res_mco1 * ee_res_mco1

twoway scatter ee_res_mco1c cc_ipcf_ppp11 if cc_ipcf_ppp11 <99 & cc_ipcf_ppp11 >2, msize(vtiny)|| lowess ee_res_mco1c cc_ipcf_ppp11  if cc_ipcf_ppp11 <99 & cc_ipcf_ppp11 >2, yline(0,  lpattern("- ##") lcolor(black))
graph export "${path_figures}\compara\diferencias_intertermporales_scatter_res_cuadrado.png", replace
graph save "${path_figures}\compara\graph\diferencias_intertermporales2__scatter_res_cuadrado.gph", replace

twoway scatter ee_res_mco1 cc_ipcf_ppp11 if cc_ipcf_ppp11 <99 & cc_ipcf_ppp11 >2, msize(vtiny) || lowess ee_res_mco1c cc_ipcf_ppp11  if cc_ipcf_ppp11 <99 & cc_ipcf_ppp11 >2, yline(0,  lpattern("- ##") lcolor(black))
graph export "${path_figures}\compara\diferencias_intertermporales_scatter_res2.png", replace
graph save "${path_figures}\compara\graph\diferencias_intertermporales2__scatter_res.gph", replace

twoway `lisvarres2' , `gra1' 
graph export "${path_figures}\compara\diferencias_intertermporales_res2.png", replace
graph save "${path_figures}\compara\graph\diferencias_intertermporales2_res.gph", replace

twoway `lisvarres' , `gra1'
graph export "${path_figures}\compara\diferencias_intertermporales_res.png", replace
graph save "${path_figures}\compara\graph\diferencias_intertermporales_res.gph", replace


forvalues i = 1(1)$total_bases {
	use "${path_dataout}\compara\EPH`i'", clear 
	
	kdensity ipcf_ppp11, addplot(kdensity nn_mco) `gra2'
	graph export "${path_figures}\compara\EPH`i'.png", replace
	graph save "${path_figures}\compara\graph\EPH`i'", replace

	kdensity nn_mco, addplot(kdensity nn_lasso) `gra3'
	graph export "${path_figures}\compara\lasso_MCO_EPH`i'.png", replace
	graph save "${path_figures}\compara\graph\lasso_MCO_EPH`i'", replace
	
	kdensity ln_ipcf_ppp11, addplot(kdensity nn_ln_mco) `gra4'
	graph export "${path_figures}\compara\ln_EPH`i'.png", replace
	graph save "${path_figures}\compara\graph\ln_EPH`i'", replace
	
	twoway lowess nn_dif_mco cc_ipcf_ppp11, sort `gra5' 
	graph export "${path_figures}\compara\dif_EPH`i'.png", replace
	graph save "${path_figures}\compara\graph\dif_EPH`i'", replace
	
	twoway line ipcf_ppp11 cc_ipcf_ppp11, sort|| line nn_mco cc_nn_mco, sort `gra6'
	graph export "${path_figures}\compara\pen_EPH`i'.png", replace
	graph save "${path_figures}\compara\graph\pen_EPH`i'", replace
	
	twoway line ln_ipcf_ppp11 cc_ipcf_ppp11, sort|| line nn_ln_mco cc_nn_mco, sort `gra7'
	graph export "${path_figures}\compara\lnpen_EPH`i'.png", replace
	graph save "${path_figures}\compara\graph\lnpen_EPH`i'", replace
	}

	
*****************************************
**Análisis evolucion variables
*****************************************

capture mkdir "${path_figures}\compara\variables"
glo path_figures_variables "${path_figures}\compara\variables\"

capture mkdir "${path_figures_variables}\graph"
glo path_figures_variables_graph "${path_figures_variables}\graph"



forvalues i = 1(1)$total_bases {
	use "${path_dataout}\compara\EPH`i'", clear 
	
	foreach var of varlist ln_ipcf_ppp11 hombre edad nivel hv_* miembros jj_* cc_* {
		
		kdensity `var',  saving(gg_`var'_`i')
		graph export "${path_figures_variables}\kdensity_`var'_`i'.png", replace
		graph save "${path_figures_variables_graph}\kdensity_`var'_`i'", replace
		
		twoway scatter `var' cc_ipcf_ppp11 if cc_ipcf_ppp11 <99 & cc_ipcf_ppp11 >2, msize(vtiny)  saving(gg1_`var'_`i')
		graph export "${path_figures_variables}\scatter_`var'_`i'.png", replace
		graph save "${path_figures_variables_graph}\scatter_`var'_`i'", replace
		}
}


foreach var of varlist ln_ipcf_ppp11 hombre edad nivel hv_* miembros jj_* cc_* {
	graph combine gg_`var'_1 gg_`var'_2 gg_`var'_3 gg_`var'_4 gg_`var'_5 gg_`var'_6 gg_`var'_7 gg_`var'_8 gg_`var'_9 gg_`var'_10 gg_`var'_11 gg_`var'_12 gg_`var'_13 gg_`var'_14 gg_`var'_15 gg_`var'_16 gg_`var'_17 gg_`var'_18 gg_`var'_19 gg_`var'_20 gg_`var'_21 gg_`var'_22 gg_`var'_23 gg_`var'_24 gg_`var'_25 gg_`var'_26 gg_`var'_27 gg_`var'_28 gg_`var'_29 gg_`var'_30   
		graph export "${path_figures_variables}\kdensity_comb_`var'.png", replace
		graph save "${path_figures_variables_graph}\kdensity_comb_`var'", replace
	
	graph combine gg1_`var'_1 gg1_`var'_2 gg1_`var'_3 gg1_`var'_4 gg1_`var'_5 gg1_`var'_6 gg1_`var'_7 gg1_`var'_8 gg1_`var'_9 gg1_`var'_10 gg1_`var'_11 gg1_`var'_12 gg1_`var'_13 gg1_`var'_14 gg1_`var'_15 gg1_`var'_16 gg1_`var'_17 gg1_`var'_18 gg1_`var'_19 gg1_`var'_20 gg1_`var'_21 gg1_`var'_22 gg1_`var'_23 gg1_`var'_24 gg1_`var'_25 gg1_`var'_26 gg1_`var'_27 gg1_`var'_28 gg1_`var'_29 gg1_`var'_30   
		graph export "${path_figures_variables}\scatter_comb_`var'.png", replace
		graph save "${path_figures_variables_graph}\scatter_comb_`var'", replace
	}


use "${path_dataout}\compara\EPH1", clear 

loc gg3 = ""

loc variables11 = ""
foreach var of varlist ln_ipcf_ppp11 hombre edad nivel hv_* miembros jj_* cc_* {
loc variables11 = "`variables11' `var'"
}

use "${path_dataout}\analisis_modelos.dta", clear

foreach var in `variables11' {

	loc lis_`var'_gg2 = "kdensity zz_`var'_1"
	
	forvalues i = 2(1)$total_bases {
		loc lis_`var'_gg2 = "`lis_`var'_gg2' || kdensity zz_`var'_`i'"
	}
	
	twoway `lis_`var'_gg2', legend(off) saving(gg2_`var')
	graph export "${path_figures}\compara\variables3_`var'.png", replace
	graph save "${path_figures}\compara\graph\variables3_`var'.gph", replace
	loc gg3 = "`gg3' ${path_figures}\compara\graph\variables3_`var'.gph"
}

graph combine `gg3'
graph export "${path_figures}\compara\variables3.png", replace
graph save "${path_figures}\compara\graph\variables3.gph", replace
