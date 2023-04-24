*********************
* defino umbrales y variables de pobreza
*********************
loc umbralfijo =1
loc umbralfijo =0
if "`umbralfijo'" == "1" {
	loc umbral1 =.5
	loc umbral_ric1 =.1
	*loc umbral3 =.5
	*loc umbral_ric3 =.1
	global output  "${path_pp}\Pov_prof_3cat_3.xlsx"
}
if "`umbralfijo'" == "0" {
	loc prop_pob  =1/10
	loc prop_vuln  =2/10
	loc prop_rico =1/10
}

include "${pathdo}\01a_pathbases.doi"

*
qui forvalues i= `predini' / `predfin' {
	noi di "abre  `base_`i''" 
	drop _all
	use "${pathdatalib}\\`base_completo_`i''"
	* cargo variables
	include "${pathdo}\01b_variables_probit.doi"
	* me quedo solo con el jefe (el predict es a nivel hogar)
	keep if jefe ==1
	* me aseguro que no haya variables en la base que empiecen con prmod_*
	capture drop prmod_*
	* % de personas con caracteristicas de pobre
	forvalues j= `prbini' / `prbfin' {
		noi di "predicts `base_`j''" 
		* cargo coeficientes del probit de cada período
		estimates use "${pathout}\ster\pr_`base_`j''.ster"
		* creo predicciones de probabilidad
		predict pr${tprob}_`base_`j''
	}
	* junto las predicciones de probabilidad a nivel hogar con la base de individuos
	tempfile temp`i'
	keep id prmod_*
	save `temp`i'', replace
	drop _all
	use "${pathdatalib}\\`base_completo_`i''"
	include "${pathdo}\01b_variables_probit.doi"
	merge m:1 id using `temp`i''
	drop if _merge!=3
	drop _merge

	*********************************************************
	* defino grupos de pobres bajo distintos criterios
	*********************************************************
	egen pmin_pr${tprob}=rowmin(pr${tprob}*)
	egen pmax_pr${tprob}=rowmax(pr${tprob}*)
	* elimino observaciones en las que me falta una variable para predecir pobreza o tienen missing en ingreso
	drop if pmin_pr${tprob} ==. | pmax_pr${tprob} ==. | pobre_${tprob} ==. | ipcf ==.
	if "`umbralfijo'" == "0" {
		* pobre_estruct, vulnerable s
		set seed 1234
		gen double alea =uniform()
		sort alea,stable
		sort pmin_pr${tprob} id alea,stable

		*acumulo poblacion en términos de pmin
		gen aux1=sum(pondera) if pmin_pr${tprob}!=.
		sum aux1
		loc pobmax=r(max)
		*porcentaje acumulado de población
		gen aux2 = aux1/ `pobmax'
		* pobres estructurales: el x% cuya mínima probabilidad es más alta
		gen pobre_estruct =.
		replace pobre_estruct =0 if aux2 <(1-`prop_pob')
		replace pobre_estruct =1 if aux2 >=(1-`prop_pob') & aux2!=.

		* vulnerables estructurales: el siguiente x% cuya mínima probabilidad es más alta
		gen vulne_estruct =.
		replace vulne_estruct =0 if aux2 <(1-`prop_vuln') 
		replace vulne_estruct =0 if aux2 >=(1-`prop_pob') & aux2!=.
		replace vulne_estruct =1 if aux2 >=(1-`prop_vuln') & aux2 <(1-`prop_pob') & aux2!=.
		drop aux*

		* ricos estructurales: x% cuya maxima probabilidad de ser pobre es mas baja
		sort alea,stable
		sort pmax_pr${tprob} id alea,stable
		gen aux1=sum(pondera) if pmax_pr${tprob}!=.
		sum aux1
		loc pobmax=r(max)
		gen aux2 = aux1/ `pobmax'
		gen rico_estruct =.
		replace rico_estruct =0 if aux2 >= `prop_rico' & aux2 !=.
		replace rico_estruct =1 if aux2 < `prop_pob'
		drop aux*

		* pobres por ingreso
		sort ipcf id alea,stable
		gen aux1=sum(pondera) if pmax_pr${tprob}!=.
		sum aux1
		loc pobmax=r(max)
		gen aux2 = aux1/ `pobmax'
		gen pobre_monequi =.
		replace pobre_monequi =0 if aux2 >= `prop_pob' & aux2 !=.
		replace pobre_monequi =1 if aux2 < `prop_pob'
		* vulnerables por ingreso: el siguiente x% cuya mínima probabilidad es más alta
		gen vulne_monequi =.
		replace vulne_monequi =0 if aux2 <`prop_pob'
		replace vulne_monequi =0 if aux2 >=`prop_vuln' & aux2!=.
		replace vulne_monequi =1 if aux2 >=`prop_pob' & aux2 <`prop_vuln' & aux2!=.
		drop aux*

		* pobres estructurales condicional en que hoy son pobres
		sort alea,stable
		sort pobre_mod pmin_pr${tprob} id alea,stable

		*acumulo poblacion en términos de pmin
		gen aux1=sum(pondera) if pmin_pr${tprob}!=.
		sum aux1
		loc pobmax=r(max)
		*porcentaje acumulado de población
		gen aux2 = aux1/ `pobmax'
		* pobres estructurales condicional: el x% cuya mínima probabilidad es más alta
		gen pobre_cond =.
		replace pobre_cond =0 if aux2 <(1-`prop_pob')
		replace pobre_cond =1 if aux2 >=(1-`prop_pob') & aux2!=.	
		* vulnerables estructurales condicional: el siguiente x% cuya mínima probabilidad es más alta
		gen vulne_cond =.
		replace vulne_cond =0 if aux2 <(1-`prop_vuln') 
		replace vulne_cond =0 if aux2 >=(1-`prop_pob') & aux2!=.
		replace vulne_cond =1 if aux2 >=(1-`prop_vuln') & aux2 <(1-`prop_pob') & aux2!=.
		drop aux*
	}
	compress
	save "${pathb}\2019_pob_estructural\Bases_predict\\`base_`i''_p${tprob}_`prbini'_`prbfin'.dta", replace
}
*/

