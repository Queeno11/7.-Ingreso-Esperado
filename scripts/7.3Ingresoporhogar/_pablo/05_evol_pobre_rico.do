if "${path}"== "" glo path "J:\Work\C_Gasparini\2018_paper_pobreza\"
if "${pathb}"== "" glo pathb "${path}\bases_arg\Arg_imputado\"
if "${pathdo}"== "" glo pathdo "${path}\pobreza_estructural\do\"


loc umbral1 =.5
loc umbral_ric1 =.1
loc umbral3 =.5
loc umbral_ric3 =.1
global lista_pob "pobre1_estruct rico1_estruct pobre_mod pob1_estruct_mod pobre3_estruct rico3_estruct pob3_estruct_mod "


loc minmodelo=1
loc maxmodelo=1
loc lista_tpob "mod2"


include "${pathdo}\01a_pathbases.doi"


mat evol_pobre_rico=J(28,7,.)

 qui forvalues i=1/28 {
	noi di "`base_`i''"
	drop _all
	use "${pathb}\estructural\\${rangoedad}`base_`i''_pp.dta"
	if "${rangoedad}"=="25-60" keep if edad>=25 & edad<=60
	*defino pobreza estructural y resto

	gen pobre1_estruct =.
	replace pobre1_estruct =0 if pmin_p1_mod2 < `umbral1' 
	replace pobre1_estruct =1 if pmin_p1_mod2 >= `umbral1' & pmin_p1_mod2 <.
	
	gen pob1_estruct_mod =.
	replace pob1_estruct_mod =0 if pobre1_estruct ==0 | pobre_mod ==0
	replace pob1_estruct_mod =1 if pobre1_estruct ==1 & pobre_mod ==1

	gen rico1_estruct =.
	replace rico1_estruct =1 if pmax_p1_mod2 < `umbral_ric1' 
	replace rico1_estruct =0 if pmax_p1_mod2 >= `umbral_ric1' & pmax_p1_mod2 <.
	
	gen pobre3_estruct =.
	replace pobre3_estruct =0 if pmin_p3_mod2 < `umbral3' 
	replace pobre3_estruct =1 if pmin_p3_mod2 >= `umbral3' & pmin_p3_mod2 <.
	
	gen pob3_estruct_mod =.
	replace pob3_estruct_mod =0 if pobre3_estruct ==0 | pobre_mod ==0
	replace pob3_estruct_mod =1 if pobre3_estruct ==1 & pobre_mod ==1

	gen rico3_estruct =.
	replace rico3_estruct =1 if pmax_p3_mod2 < `umbral_ric3' 
	replace rico3_estruct =0 if pmax_p3_mod2 >= `umbral_ric3' & pmax_p3_mod2 <.
	loc j=1
	foreach var of varlist ${lista_pob} {
		sum `var' [w=pondera]
		mat evol_pobre_rico[`i',`j']=r(mean)
		loc ++j
	}
}
drop _all
svmat evol_pobre_rico
export excel using "${path}\pobreza_estructural\output\evol_pobre_rico.xlsx", cell(b36) sheetmodify sheet("evol_pobre_rico")


