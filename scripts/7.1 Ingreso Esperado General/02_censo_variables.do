

if "${tengo_censo}" == "NO" {
qui include "${path_scripts}\02a_prepara_censo.doi"
} 

use "${prepara_censo}", clear

forvalues i = 1(1)$total_bases {
	estimates use "${path_dataout}\ster\MCO_ingreso_`i'"
	predict pp`i'
	gen ln_pp`i' = .
	replace ln_pp`i' = pp`i'
	replace pp`i' = exp(pp`i')
	
	estimates use "${path_dataout}\ster\probit_pobreza_`i'"
	predict rr`i'
}

save "${path_dataout}\predict_censo.dta", replace