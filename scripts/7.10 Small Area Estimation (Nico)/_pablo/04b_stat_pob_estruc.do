if "${path}"== "" glo path "J:\Work\C_Gasparini\2018_paper_pobreza\"
if "${pathb}"== "" glo pathb "${path}\bases_arg\Arg_imputado\"
if "${pathdo}"== "" glo pathdo "${path}\pobreza_estructural\do\"

loc minmodelo=1
loc maxmodelo=1
loc lista_tpob "mod2"

glo umbral = 0.5

include "${pathdo}\01a_pathbases.doi"

* estadisticas de probit
foreach tipo in `lista_tpob' {
	mat pp_3p_`tipo'=J(28,47,.)
	forvalues pr=`minmodelo'/`maxmodelo' {
		mat pp_`pr'_`tipo'=J(28,47,.)
	}
}

 qui forvalues i=1/28 {
	noi di "`base_`i''"
	drop _all
	use "${pathb}\estructural\\${rangoedad}`base_`i''_pp.dta"
	if "${rangoedad}"=="25-60" keep if edad>=25 & edad<=60
	*duplicates report id com
	sort id com
	foreach tipo in `lista_tpob' {
		forvalues pr=`minmodelo'/`maxmodelo' {
			* tasas de pobreza personas
			sum pobre_`tipo' [w=pondera]
			mat pp_`pr'_`tipo'[`i',1]=r(mean)
			* distribución de la minima probabilidad de ser pobre
			sum pmin_p`pr'_`tipo' [w=pondera],d
			mat pp_`pr'_`tipo'[`i',2]=r(mean)
			mat pp_`pr'_`tipo'[`i',3]=r(p50)
			mat pp_`pr'_`tipo'[`i',4]=r(min)
			mat pp_`pr'_`tipo'[`i',5]=r(p5)
			mat pp_`pr'_`tipo'[`i',6]=r(p95)
			mat pp_`pr'_`tipo'[`i',7]=r(max)
			forvalues j=1/20 {
				* predicción pobreza
				gen pe`j'_`pr'_`tipo' =.
				replace pe`j'_`pr'_`tipo' =0 if pmin_p`pr'_`tipo'<(`j'/20)*pp_`pr'_`tipo'[`i',1]
				replace pe`j'_`pr'_`tipo' =1 if pmin_p`pr'_`tipo'>=(`j'/20)*pp_`pr'_`tipo'[`i',1] & pmin_p`pr'_`tipo'<.
				* tasa de predicción pobreza
				sum pe`j'_`pr'_`tipo' [w=pondera]
				mat pp_`pr'_`tipo'[`i',7+`j']=r(mean)

			}
			forvalues j=1/20 {
				* predicción pobreza condicional en que es pobre
				gen pecp_`j'_`pr'_`tipo'=.
				replace pecp_`j'_`pr'_`tipo' =0 if pe`j'_`pr'_`tipo' ==0 | pobre_`tipo' ==0
				replace pecp_`j'_`pr'_`tipo' =1 if pe`j'_`pr'_`tipo' ==1 & pobre_`tipo' ==1
				replace pecp_`j'_`pr'_`tipo' =. if pe`j'_`pr'_`tipo' ==. | pobre_`tipo' ==.
				* tasa de predicción pobreza condicional en que es pobre
				sum pecp_`j'_`pr'_`tipo' [w=pondera]
				mat pp_`pr'_`tipo'[`i',27+`j']=r(mean)
			}
		}
		* modelo 3 por hogar
		* tasas de pobreza personas
		sum pobre_`tipo' [w=pondera] if jefe ==1
		mat pp_3_`tipo'[`i',1]=r(mean)
		* distribución de la minima probabilidad de ser pobre
		sum pmin_p3_`tipo' [w=pondera] if jefe ==1,d
		mat pp_3_`tipo'[`i',2]=r(mean)
		mat pp_3_`tipo'[`i',3]=r(p50)
		mat pp_3_`tipo'[`i',4]=r(min)
		mat pp_3_`tipo'[`i',5]=r(p5)
		mat pp_3_`tipo'[`i',6]=r(p95)
		mat pp_3_`tipo'[`i',7]=r(max)
		forvalues j=1/20 {
			* predicción pobreza
			gen pe`j'_3_`tipo' =.
			replace pe`j'_3_`tipo' =0 if pmin_p3_`tipo'<(`j'/20)*pp_3_`tipo'[`i',1]
			replace pe`j'_3_`tipo' =1 if pmin_p3_`tipo'>=(`j'/20)*pp_3_`tipo'[`i',1] & pmin_p3_`tipo'<. 
			replace pe`j'_3_`tipo'=. if jefe!=1
			* tasa de predicción pobreza
			sum pe`j'_3_`tipo' [w=pondera] if jefe ==1
			mat pp_3_`tipo'[`i',7+`j']=r(mean)

		}
		forvalues j=1/20 {
			* predicción pobreza condicional en que es pobre
			gen pecp_`j'_3_`tipo'=.
			replace pecp_`j'_3_`tipo' =0 if pe`j'_3_`tipo' ==0 | pobre_`tipo' ==0
			replace pecp_`j'_3_`tipo' =1 if pe`j'_3_`tipo' ==1 & pobre_`tipo' ==1
			replace pecp_`j'_3_`tipo' =. if pe`j'_3_`tipo' ==. | pobre_`tipo' ==.
			replace pecp_`j'_3_`tipo' =. if jefe!=1
			* tasa de predicción pobreza condicional en que es pobre
			sum pecp_`j'_3_`tipo' [w=pondera] if jefe ==1
			mat pp_3_`tipo'[`i',27+`j']=r(mean)
		}
		* modelo 3 personas
		* tasas de pobreza personas
		sum pobre_`tipo' [w=pondera] 
		mat pp_3p_`tipo'[`i',1]=r(mean)
		* distribución de la minima probabilidad de ser pobre
		by id: egen pmin_p3p_`tipo' =max(pmin_p3_`tipo')
		sum pmin_p3p_`tipo' [w=pondera] ,d
		mat pp_3p_`tipo'[`i',2]=r(mean)
		mat pp_3p_`tipo'[`i',3]=r(p50)
		mat pp_3p_`tipo'[`i',4]=r(min)
		mat pp_3p_`tipo'[`i',5]=r(p5)
		mat pp_3p_`tipo'[`i',6]=r(p95)
		mat pp_3p_`tipo'[`i',7]=r(max)
		forvalues j=1/20 {
			* predicción pobreza
			gen pe`j'_3p_`tipo' =.
			replace pe`j'_3p_`tipo' =0 if pmin_p3p_`tipo'<(`j'/20)*pp_3p_`tipo'[`i',1]
			replace pe`j'_3p_`tipo' =1 if pmin_p3p_`tipo'>=(`j'/20)*pp_3p_`tipo'[`i',1] & pmin_p3p_`tipo'<. 
			* tasa de predicción pobreza
			sum pe`j'_3p_`tipo' [w=pondera] 
			mat pp_3p_`tipo'[`i',7+`j']=r(mean)
		}
		forvalues j=1/20 {
			* predicción pobreza condicional en que es pobre
			gen pecp_`j'_3p_`tipo'=.
			replace pecp_`j'_3p_`tipo' =0 if pe`j'_3p_`tipo' ==0 | pobre_`tipo' ==0
			replace pecp_`j'_3p_`tipo' =1 if pe`j'_3p_`tipo' ==1 & pobre_`tipo' ==1
			replace pecp_`j'_3p_`tipo' =. if pe`j'_3p_`tipo' ==. | pobre_`tipo' ==.
			* tasa de predicción pobreza condicional en que es pobre
			sum pecp_`j'_3p_`tipo' [w=pondera] 
			mat pp_3p_`tipo'[`i',27+`j']=r(mean)
		}
	}
}
foreach tipo in `lista_tpob'  {
	drop _all
	svmat pp_3p_`tipo'
	export excel using "${path}\pobreza_estructural\output\result_p.xlsx", cell(b36) sheetmodify sheet("pp_3p_`tipo'")
	forvalues pr=`minmodelo'/`maxmodelo' {
		drop _all
		svmat pp_`pr'_`tipo'
		export excel using "${path}\pobreza_estructural\output\result_${rangoedad}.xlsx", cell(b36) sheetmodify sheet("pp_`pr'_`tipo'")
	}
}

