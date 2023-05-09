******************************************
*Análisis ingreso permanente
******************************************

****    Hago un destring del radio censal de la base de equivalencias para merge
use "${path_datain}\equivalencias_link_circuito.dta", clear
destring link, replace 
save "${path_dataout}\equivalencias_link_circuito.dta", replace

****    Mergeo para tener radio censal y circuito electoral
use "${censo_analisis}", clear
merge m:1 link using "${path_dataout}\equivalencias_link_circuito", nogen

save "${censo_analisis}_circuito", replace

****    Agrupo por circuito electoral y guardo la base
foreach i in max mean median min sd semean p75 p25 {
	use "${censo_analisis}_circuito", clear
	collapse (`i') pp* aa* rr* bb*, by(id_circuito)
	rename (pp* aa* rr* bb*) (pp*_`i' aa*_`i' rr*_`i' bb*_`i')
	sort id_circuito
	save "${path_dataout}\predict_ingreso_`i'.dta", replace
}

****   Agarro una de las bases para quedarme solamente con el circuito electoral

use "${path_dataout}\predict_ingreso_max.dta", clear
keep id_circuito  
save "${path_dataout}\predict_ingreso_collapse.dta", replace

****    Mergeo las bases de cada una de las variables en una única
foreach i in max min mean median sd semean p75 p25 {
	merge 1:1 id_circuito using "${path_dataout}\predict_ingreso_`i'.dta", keepusing(id_circuito pp* aa* rr* bb*)
	capture drop _merg
	save "${collapse}2", replace
	*erase "${path_dataout}\predict_ingreso_`i'.dta"
}
*/

*** 

use "${censo_analisis}_circuito", clear

local crear "prii pric seci secc supi supc"
foreach v in `crear'{
	bysort id_circuito: egen q_`v' = total(`v') if `v'==1
}
local edades "edad11 edad1217 edad1824 edad2540 edad4164 edad65"
foreach vr in `edades'{
	bysort id_circuito: egen q_`vr' = total(`vr') if `vr'==1
}
bysort id_circuito: egen q_h = total(hombre) if hombre==1
bysort id_circuito: egen q_m = total(hombre) if hombre==2

bysort id_circuito: egen q_urb = total(urp) if urp==1
bysort id_circuito: egen q_rur = total(urp) if urp==2 | urp==3
replace q_rur = 0 if q_rur == .
replace q_urb = 0 if q_rur == .



collapse (mean) q* edad, by(id_circuito)

* Reemplazo missing por 0
ds
loc varlist = r(varlist) 
foreach var in `varlist' {
	capture replace `var' = 0 if `var'==.
}

*egen totales = rowtotal(q_prii q_pric q_seci q_secc q_supi q_supc)
foreach v in `crear'{
	gen porc_`v' = q_`v' / (q_prii + q_pric + q_seci + q_secc + q_supi + q_supc)
}
local edades "edad11 edad1217 edad1824 edad2540 edad4164 edad65"
foreach vr in `edades'{
	gen porc_`vr' = q_`vr'/ (q_edad11 + q_edad1217 + q_edad1824 + q_edad2540 + q_edad4164 + q_edad65)
}

*drop totales
*egen aux = rowtotal(q_h q_m)
gen porc_h = q_h/(q_h + q_m)
gen porc_m = q_m/(q_h + q_m)
*drop aux
*egen aux = rowtotal(q_urb q_rur)
gen porc_urb = q_urb/(q_urb + q_rur)
gen porc_rur = q_rur/(q_urb + q_rur)
*drop aux
rename edad edad_prom
save "${collapse}_hombre", replace
use "${collapse}2", clear
merge 1:1 id_circuito using "${collapse}_hombre", keepusing(id_circuito porc* edad_prom)
save "${collapse}_final", replace


*Abro base del censo sin collapse
use "${censo_analisis}_circuito", clear

*Ordeno por identificador de persona
sort idi

*Loop para generar diferencias por persona entre los años de elecciones (EPH 1, 8, 24 y 30)
local i_prev = 1
foreach i in 8 16 24 30{
	gen dt_ln_pp`i' = ln_pp`i' - ln_pp`i_prev'
	gen dt_rr`i' = rr`i' - rr`i_prev'
	local i_prev = `i'
}

*Hago collapse de la media y del desvío estándar de las diferencias del logaritmo de pp y de rr 
collapse (mean) dt_* (sd) sd_dt_rr8 = dt_rr8 sd_dt_rr16 = dt_rr16 sd_dt_rr24 = dt_rr24 sd_dt_rr30 = dt_rr30 sd_dt_ln_pp8 = dt_ln_pp8 sd_dt_ln_pp16 = dt_ln_pp16 sd_dt_ln_pp24 = dt_ln_pp24 sd_dt_ln_pp30 = dt_ln_pp30, by(id_circuito)
save "${collapse}_dif", replace 

*Mergeo con el collapse anterior 
merge 1:1 id_circuito using "${collapse}_final", gen(_merge_dif)

save "${collapse}_final_dif", replace

************** Mediana por circuito del desvío respecto al promedio histórico del individuo

*Abro base del censo sin collapse
use "${censo_analisis}_circuito", clear

sort idi

* Genero la media en el tiempo de ln_pp y rr para cada individuo
egen pp_mean2 = rowmean(ln_pp*)
egen rr_mean2 = rowmean(rr*)
egen pp_mean = rowmean(ln_pp1 ln_pp8 ln_pp16 ln_pp24 ln_pp30)
egen rr_mean = rowmean(rr1 rr8 rr16 rr24 rr30)

*Genero los desvíos en el tiempo respecto a la media para los semestres de años electorales
foreach i in 1 8 16 24 30{
	gen dm_ln_pp`i' = ln_pp`i' - pp_mean
	gen dm_rr`i' = rr`i' - rr_mean
	gen dm_ln_pp`i'_2 = ln_pp`i' - pp_mean2
	gen dm_ln_rr`i'_2 = rr`i' - rr_mean2
}

*Collapse y genero la mediana por circuito electoral de los desvíos respecto a la media
collapse (median) dm_*, by(id_circuito)
save "${collapse}_dm", replace

*Mergeo con el último collapse por id_circuito
merge 1:1 id_circuito using "${collapse}_final_dif", gen(_merge_dm)
save "${collapse}_final_dm", replace

use "${collapse}_final_dm", clear
*Renombro las variables que acabo de crear y guardo
foreach i in 1 8 16 24 30{
	rename dm_ln_pp`i' dm_ppintra`i'
	rename dm_rr`i' dm_rrintra`i'
	rename dm_ln_pp`i'_2 dm_ppintra`i'_2
	rename dm_ln_rr`i'_2 dm_rrintra`i'_2
}

foreach i in 8 16 24 30{
	rename dt_ln_pp`i' dt_ppintra`i'
	rename dt_rr`i' dt_rrintra`i'
}
save "${collapse}_circuitos", replace
