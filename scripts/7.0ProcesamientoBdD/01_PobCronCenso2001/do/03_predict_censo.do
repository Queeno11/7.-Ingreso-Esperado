drop _all

loc umbralfijo =1
loc umbralfijo =0

use "${pathdcenso2001}\predict_pobcron_censo2001.dta"
drop if persona_ref_id ==.
duplicates tag persona_ref_id , gen(reps)
count if reps !=0
assert r(N)==0

*keep cprov cdpto muni local urp link nviv nhog nper idv idh idi nhog_orig totpers tothog id com hogarsec jefe miembros pp* p03
clonevar nper = persona_ref_id
clonevar nhog = hogar_ref_id
clonevar nviv = vivienda_ref_id
*nviv nhog nper 
keep link cprov cdpto nper nhog nviv id com hogarsec miembros pp* p3 loc aglo urp muni idfrac idradio prov_ref_id dpto_ref_id frac_ref_id radio_ref_id seg_ref_id vivienda_ref_id hogar_ref_id persona_ref_id 
*link nviv nhog nper 
* opción 1 promedio probabilidad de ser pobre por hogar
* me quedo con la minima y maxima probabilidad
gen pmin =.
gen pmax =.
forvalues i =1/29 {
	replace pmin = pp`i' if pp`i' < pmin
	replace pmax = pp`i' if (pmax ==.) | (pmax <pp`i' & pp`i'<.)
}
drop pp*

sort id com
compress
save "${pathdcenso2001}\predict_pobcron_censo_2001_min_max.dta", replace
*/
drop _all
use "${pathdcenso2001}\predict_pobcron_censo_2001_min_max.dta"

*Opcion 1:promedio probabilidad por hogar
by id: egen pminh=mean(pmin) if hogarsec ==0
by id: egen pmaxh=mean(pmax) if hogarsec ==0

* opcion 2: promedio pobres

*********************************************************
* computo umbrales endogenamente
*********************************************************
loc vpmin ="pminh"
loc vpmax ="pmaxh"

if "`umbralfijo'" == "0" {
	loc target_pob_estruct  =1/10
	loc target_rico_estruct =1/10
}

if "`umbralfijo'" == "0" {
	*********************************************************
	* pob1_estruct_mod
	*********************************************************
	sort `vpmin' id com
	gen byte uno=1 if `vpmin' !=. | `vpmax' !=. 
	gen double aux1=sum(uno)
	gen double aux2=aux1/aux1[_N]
	compress
	count if aux2==(1-`target_pob_estruct')
	loc daigual=r(N)
	if `daigual' >0 {
		sum `vpmin' if aux2==(1-`target_pob_estruct'), mean
		loc umbral_pob =r(mean)
	}
	if `daigual' ==0 {
		sum `vpmin' if aux2>(1-`target_pob_estruct'), mean
		loc pr_min =r(min)
		sum `vpmin' if aux2<(1-`target_pob_estruct'), mean
		loc pr_max =r(max)
		loc umbral_pob =(`pr_min'+`pr_max')/2
	}
	drop aux1 aux2
	*********************************************************
	* rico1_estruct_mod
	*********************************************************
	sort `vpmax' id com
	gen double aux1=sum(uno)
	gen double aux2=aux1/aux1[_N]
	compress
	count if aux2 == `target_rico_estruct'
	loc daigual = r(N)
	if `daigual' >0 {
		sum `vpmax' if aux2==`target_rico_estruct', mean
		loc umbral_ric =r(mean)
	}
	if `daigual' ==0 {
		sum `vpmax' if aux2>`target_rico_estruct', mean
		loc pr_min =r(min)
		sum `vpmax' if aux2<`target_rico_estruct', mean
		loc pr_max =r(max)
		loc umbral_ric =(`pr_min'+`pr_max')/2
	}
	drop aux1 aux2
	noi di "umbral_pob (corte de probabilidad) que da " `target_pob_estruct'*100 "% de pob1_estruct_mod: `umbral_pob'"
	noi di "umbral_ric (corte de probabilidad) que da " `target_rico_estruct'*100 "% de rico1_estruct_mod: `umbral_ric'"
	noi di "linea de pobreza modequi que da " `target_pob_estruct'*100 "% de pobre_modequi: `lp_modequi'"
	noi di "linea de pobreza modequi que da " `target_rico_estruct'*100 "% de rico_modequi: `lr_modequi'"
	drop uno
}

gen byte pobre_estruct =.
replace pobre_estruct =0 if `vpmin'<`umbral_pob' & `vpmin'!=.
replace pobre_estruct =1 if `vpmin'>`umbral_pob' & `vpmin'!=.

gen byte rico_estruct =.
replace rico_estruct =0 if `vpmax'>`umbral_ric' & `vpmax'!=.
replace rico_estruct =1 if `vpmax'<`umbral_ric' & `vpmax'!=.

*keep link id com `vpmin' `vpmax' pobre_estruct rico_estruct 
keep link cprov cdpto nper nhog nviv id com `vpmin' `vpmax' pobre_estruct rico_estruct loc aglo urp muni idfrac idradio prov_ref_id dpto_ref_id frac_ref_id radio_ref_id seg_ref_id vivienda_ref_id hogar_ref_id persona_ref_id 
order link cprov cdpto nper nhog nviv id com `vpmin' `vpmax' pobre_estruct rico_estruct loc aglo urp muni idfrac idradio prov_ref_id dpto_ref_id frac_ref_id radio_ref_id seg_ref_id vivienda_ref_id hogar_ref_id persona_ref_id 
label var pminh "minima probabilidad de ser pobre en todos los modelos (usada para pobre_estruct)"
label var pmaxh "maxima probabilidad de ser pobre en todos los modelos (usada para rico_estruct)"
label var pobre_estruct  "=1 pobre estructural"
label var rico_estruct   "=1 rico estructural"
sort link id com
compress
save "${pathdcenso2001}\PobrezaCronicaCenso2001.dta", replace

collapse (mean) pminh pmaxh pobre_estruct rico_estruct, by(link cprov cdpto loc aglo urp muni idfrac idradio prov_ref_id dpto_ref_id frac_ref_id radio_ref_id seg_ref_id)

order link cprov cdpto pobre_estruct rico_estruct pminh pmaxh loc aglo urp muni idfrac idradio prov_ref_id dpto_ref_id frac_ref_id radio_ref_id seg_ref_id 
label var pminh "minima probabilidad de ser pobre, promedio x radio 2001, (p/pobre_estruct)"
label var pmaxh "maxima probabilidad de ser pobre, promedio x radio 2001, (p/pobre_estruct)"
label var pobre_estruct  "pobreza estructural (10% de mayor pminh), promedio por radio censal 2001"
label var rico_estruct   "riqueza estructural (10% de menor pmaxh), promedio  por radio censal 2001"

compress
*Base por radio censal
save "${pathdcenso2001}\PobrezaCronicaCenso2001xRadio.dta", replace
*Base por Departamento
sort persona_ref_id 
gen qper =1
sort hogar_ref_id persona_ref_id 
gen qhog =1 if hogar_ref_id != hogar_ref_id[_n-1]

sort vivienda_ref_id hogar_ref_id persona_ref_id 
gen qviv =1 if vivienda_ref_id != vivienda_ref_id[_n-1]


preserve
collapse (mean) pobre_estruct rico_estruct pminh pmaxh aglo urp (sum) qper qhog qviv, by(prov_ref_id dpto_ref_id cprov cdpto)
compress
save "${pathdcenso2001}\PobrezaCronicaCenso2001xDpto.dta", replace
restore

*Base por Provincia
preserve
collapse (mean) pobre_estruct rico_estruct pminh pmaxh aglo urp (sum) qper qhog qviv, by(prov_ref_id cprov )
compress
save "${pathdcenso2001}\PobrezaCronicaCenso2001xProv.dta", replace
restore
*
