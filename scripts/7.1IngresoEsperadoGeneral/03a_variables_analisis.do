******************************************
*Análisis ingreso permanente
******************************************

use "${censo}", clear

if "${winsor2}" == "SI" {

forvalues i = 1/$total_bases {

	sum pp`i', d 

	replace pp`i' = r(p99) if pp`i' > r(p99)
	replace pp`i' = r(p1)  if pp`i' < r(p1)
	}
	
} 

******************************************
****    genero variables 
******************************************
foreach i in max min mean median sd miss total{
	capture drop aa_`i'
	egen aa_`i' = row`i'(pp*) 
	dis "`i'"
}

capture drop aa_var aa_dif

gen aa_var = aa_sd * aa_sd
gen aa_co_var = aa_sd/aa_mean
gen aa_co_var2 = aa_var/aa_mean
gen aa_dif = aa_max - aa_min

foreach i in max min mean median sd miss{
	capture drop bb_`i'
	egen bb_`i' = row`i'(rr*) 
	dis "`i'"
}

capture drop bb_var 

gen bb_var = bb_sd * bb_sd
gen bb_co_var = bb_sd/bb_mean
gen bb_co_var2 = bb_var/bb_mean


// save "${censo_analisis}", replace
*erase "${censo}" 

******************************************
****    creo percentiles por variables
******************************************

// use "${censo_analisis}", clear

forvalues i = 1/$total_bases {
		sort pp`i', stable
		cuantiles pp`i', ncuantiles(100) orden_aux(pp`i') generate(cc_pp`i')
}

foreach var in aa_mean aa_sd {
	sort `var', stable
	cuantiles `var', ncuantiles(100) orden_aux(`var') generate(cc_`var')
}

forvalues i = 1/$total_bases {
		sort rr`i', stable
		cuantiles rr`i', ncuantiles(100) orden_aux(rr`i') generate(cc_rr`i')
}

foreach var in bb_mean bb_sd {
	sort `var', stable
	cuantiles `var', ncuantiles(100) orden_aux(`var') generate(cc_`var')
}

save "${censo_analisis}", replace
