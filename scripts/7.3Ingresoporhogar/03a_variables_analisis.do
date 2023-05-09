******************************************
*Análisis ingreso permanente
******************************************

use "${censo}", clear

loc collapse = "max min mean median sd mimm total"
loc collapse = "mean median"
******************************************
****    genero variables 
******************************************
//
// foreach i in `collapse'{
// 	capture drop aa_`i'
// 	egen aa_t`i' = row`i'(pp*) 
// 	dis "`i'"
// }

// capture drop aa_var aa_dif
//
// gen aa_var = aa_sd * aa_sd
// gen aa_co_var = aa_sd/aa_mean
// gen aa_co_var2 = aa_var/aa_mean
// gen aa_dif = aa_max - aa_min

foreach i in `collapse'{
		forvalues m = 1(1)4 {
		capture drop dd`m'_t`i'
		egen dd`m'_t`i' = row`i'(mm`m'*) 
		dis "`i'" "`m'"
	}
}
// capture drop dd_var dd_dif
//
// gen dd_var = dd_sd * dd_sd
// gen dd_co_var = dd_sd/dd_mean
// gen dd_co_var2 = dd_var/dd_mean
// gen dd_dif = dd_max - dd_min

//
// foreach i in `collapse'{
// 	capture drop bb_`i'
// 	egen bb_t`i' = row`i'(rr*) 
// 	dis "`i'"
// }

// capture drop bb_var 
//
// gen bb_var = bb_sd * bb_sd
// gen bb_co_var = bb_sd/bb_mean
// gen bb_co_var2 = bb_var/bb_mean


save "${censo_analisis}", replace
*erase "${censo}" 

******************************************
****    creo percentiles por variables
******************************************

// use "${censo_analisis}", clear
/*
forvalues i = 1/$total_bases {
		sort pp`i', stable
		cuantiles pp`i', ncuantiles(100) orden_aux(pp`i') generate(cc_pp`i')
}

foreach var in dd_mean dd_sd {
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
*/
