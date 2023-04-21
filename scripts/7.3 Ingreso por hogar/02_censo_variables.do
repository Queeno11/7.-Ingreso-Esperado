

if "${tengo_censo}" == "NO" {
qui include "${path_scripts}\02a_prepara_censo.doi"
} 

use "${prepara_censo}", clear

drop cprov cdpto muni local urp nviv nhog nper idv idh idi tipvv v00 v01 v02 persona_ref_id hogar_ref_id vivienda_ref_id radio_ref_id frac_ref_id dpto_ref_id prov_ref_id p01 p02 p03 p05 p06 p07 p12 edadagru edadqui p08 p09 p10 condact nhog_orig h05 h06 h07 h08 h09 h10 h11 h12 h13 h14 h15 h16 h19a h19b h19c h19d prop indhac totpers algunbi incalserv inmat incalcons tothog id


forvalues i = 1(1)$total_bases {
// 	estimates use "${path_dataout}\ster\MCO_ingreso_`i'"
// 	predict pp`i'
// 	gen ln_pp`i' = .
// 	replace ln_pp`i' = pp`i'
// 	replace pp`i' = exp(pp`i')
		
	estimates use "${path_dataout}\ster\MCO_ingreso_`i'"
	predict mm1`i'
// 	gen ln_mm1`i' = .
// 	replace ln_mm1`i' = mm1`i'
	replace mm1`i' = exp(mm1`i')
	
	estimates use "${path_dataout}\ster\MCO_ingresoxaglo_`i'"
	predict mm2`i'
// 	gen ln_mm2`i' = .
// 	replace ln_mm2`i' = mm2`i'
	replace mm2`i' = exp(mm2`i')
	
	estimates use "${path_dataout}\ster\MCO_ingreso_sin_aglo_`i'"
	predict mm3`i'
// 	gen ln_mm3`i' = .
// 	replace ln_mm3`i' = mm3`i'
	replace mm3`i' = exp(mm3`i')
	
	estimates use "${path_dataout}\ster\MCO_ingresoxaglo_noef_`i'"
	predict mm4`i'
// 	gen ln_mm4`i' = .
// 	replace ln_mm4`i' = mm4`i'
	replace mm4`i' = exp(mm4`i')
	
// 	estimates use "${path_dataout}\ster\probit_pobreza_`i'"
// 	predict rr`i'
}

save "${path_dataout}\predict_censo.dta", replace

/*
	keep idv idh idi pp* mm* ln_* rr* 
	
	save "${path_dataout}\predict_censo_`i'.dta", replace

use "${prepara_censo}", clear

forvalues i = 1(1)$total_bases {
	merge 1:1 idv idh idi using "${path_dataout}\predict_censo_`i'.dta", nogen 
}

save "${path_dataout}\predict_censo.dta", replace
*/