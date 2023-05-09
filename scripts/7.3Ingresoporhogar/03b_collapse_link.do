
******************************************
****    medidas por radios censales
******************************************

// use "${censo_analisis}", clear

loc collapse_link1 = "pp* aa* mm* dd* rr* bb*"
loc collapse_link2 = "pp*_l`i' aa*_l`i' mm*_l`i' dd*_l`i' rr*_l`i' bb*_l`i'"


loc collapse_link1 = "mm* dd*"
loc collapse_link2 = "mm*_l`i' dd*_l`i'"


foreach i in mean median{
	use "${censo_analisis}", clear
	collapse (`i') mm* dd*, by(link)
	rename (mm* dd*) (mm*_l`i' dd*_l`i')
	sort link
	save "${path_dataout}\predict_ingreso_link`i'_resumen.dta", replace
}

----


foreach i in mean median{
	use "${censo_analisis}", clear
	collapse (`i') pp* aa* rr* bb* mm* dd*, by(link)
	rename (pp* aa* mm* dd* rr* bb*) (pp*_l`i' aa*_l`i' mm*_l`i' dd*_l`i' rr*_l`i' bb*_l`i')
	sort link
	save "${path_dataout}\predict_ingreso_link`i'_resumen.dta", replace
}


foreach i in max mean median min sd semean p75 p25 {
	use "${censo_analisis}", clear
	collapse (`i') pp* aa* rr* bb* cc* mm* dd*, by(link)
	rename (pp* aa* mm* dd* rr* bb*) (pp*_l`i' aa*_l`i' mm*_l`i' dd*_l`i' rr*_l`i' bb*_l`i')
	sort link
	save "${path_dataout}\predict_ingreso_link_`i'.dta", replace
}

****    junto todo esto en una misma base


use "${path_dataout}\predict_ingreso_link_max.dta", clear
keep link  
save "${path_dataout}\predict_ingreso_collapse_link.dta", replace
foreach i in max min mean median sd semean p75 p25 {
	merge 1:1 link using "${path_dataout}\predict_ingreso_link_`i'.dta", keepusing(link pp* mm* aa* rr* bb* cc* mm* dd*)
	capture drop _merg
	save "${collapse}_link", replace
	erase "${path_dataout}\predict_ingreso_link_`i'.dta"
}

use  "${censo_analisis}", clear 
collapse dpto, by(link)
merge 1:1 link using "${collapse}_link"
save "${collapse}_link", replace 

use "${path_datain}\equivalencias_link_circuito.dta", clear
destring link, replace 
save "${path_dataout}\equivalencias_link_circuito.dta", replace

use "${censo_analisis}", clear
merge m:1 link using "${path_dataout}\equivalencias_link_circuito"
save "${collapse}_link", replace 