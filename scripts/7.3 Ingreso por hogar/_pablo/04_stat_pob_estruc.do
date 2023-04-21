loc minmodelo=1
loc maxmodelo=1
loc lista_tpob "mod2"

glo umbral = 0.5

include "${pathdo}\01a_pathbases.doi"


* estadisticas de probit
foreach tipo in `lista_tpob' {
	foreach pr in ${listatprob} {
		if "`pr'"=="3" mat pp_3h_`tipo' =J(28,45,.)
		mat pp_`pr'_`tipo'=J(28,45,.)
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
		foreach pr in ${listatprob} {
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
			forvalues j=1/19 {
				* predicción pobreza
				gen pe`j'_`pr'_`tipo' =.
				replace pe`j'_`pr'_`tipo' =0 if pmin_p`pr'_`tipo'<`j'/20
				replace pe`j'_`pr'_`tipo' =1 if pmin_p`pr'_`tipo'>=`j'/20 & pmin_p`pr'_`tipo'<.
				* tasa de predicción pobreza
				sum pe`j'_`pr'_`tipo' [w=pondera]
				mat pp_`pr'_`tipo'[`i',7+`j']=r(mean)

			}
			forvalues j=1/19 {
				* predicción pobreza condicional en que es pobre
				gen pecp_`j'_`pr'_`tipo'=.
				replace pecp_`j'_`pr'_`tipo' =0 if pe`j'_`pr'_`tipo' ==0 | pobre_`tipo' ==0
				replace pecp_`j'_`pr'_`tipo' =1 if pe`j'_`pr'_`tipo' ==1 & pobre_`tipo' ==1
				replace pecp_`j'_`pr'_`tipo' =. if pe`j'_`pr'_`tipo' ==. | pobre_`tipo' ==.
				* tasa de predicción pobreza condicional en que es pobre
				sum pecp_`j'_`pr'_`tipo' [w=pondera]
				mat pp_`pr'_`tipo'[`i',26+`j']=r(mean)
			}

			if "`pr'"=="3" {
				* tasas de pobreza hogares
				sum pobre_`tipo' [w=pondera] if jefe ==1
				mat pp_`pr'h_`tipo'[`i',1]=r(mean)
				* distribución de la minima probabilidad de ser pobre
				sum pmin_p`pr'_`tipo' [w=pondera]  if jefe ==1,d
				mat pp_`pr'h_`tipo'[`i',2]=r(mean)
				mat pp_`pr'h_`tipo'[`i',3]=r(p50)
				mat pp_`pr'h_`tipo'[`i',4]=r(min)
				mat pp_`pr'h_`tipo'[`i',5]=r(p5)
				mat pp_`pr'h_`tipo'[`i',6]=r(p95)
				mat pp_`pr'h_`tipo'[`i',7]=r(max)
				forvalues j=1/19 {
					* predicción pobreza
					gen pe`j'_`pr'h_`tipo' =.
					replace pe`j'_`pr'h_`tipo' =0 if pmin_p`pr'_`tipo'<`j'/20
					replace pe`j'_`pr'h_`tipo' =1 if pmin_p`pr'_`tipo'>=`j'/20 & pmin_p`pr'_`tipo'<.
					replace pe`j'_`pr'h_`tipo' =. if jefe!=1
					* tasa de predicción pobreza
					sum pe`j'_`pr'h_`tipo' [w=pondera]  if jefe ==1
					mat pp_`pr'h_`tipo'[`i',7+`j']=r(mean)

				}
				forvalues j=1/19 {
					* predicción pobreza condicional en que es pobre
					gen pecp_`j'_`pr'h_`tipo'=.
					replace pecp_`j'_`pr'h_`tipo' =0 if pe`j'_`pr'h_`tipo' ==0 | pobre_`tipo' ==0
					replace pecp_`j'_`pr'h_`tipo' =1 if pe`j'_`pr'h_`tipo' ==1 & pobre_`tipo' ==1
					replace pecp_`j'_`pr'h_`tipo' =. if pe`j'_`pr'h_`tipo' ==. | pobre_`tipo' ==.
					replace pecp_`j'_`pr'h_`tipo' =. if jefe!=1
					* tasa de predicción pobreza condicional en que es pobre
					sum pecp_`j'_`pr'h_`tipo' [w=pondera]  if jefe ==1
					mat pp_`pr'h_`tipo'[`i',26+`j']=r(mean)
				}
				
			}

		}

	}
}
foreach tipo in `lista_tpob'  {
	foreach pr in ${listatprob} {
		drop _all
		svmat pp_`pr'_`tipo'
		export excel using "${path}\pobreza_estructural\output\result_${rangoedad}.xlsx", cell(b36) sheetmodify sheet("pp_`pr'_`tipo'")
		if "`pr'"=="3" {
			drop _all
			svmat pp_`pr'h_`tipo'
			export excel using "${path}\pobreza_estructural\output\result_${rangoedad}.xlsx", cell(b36) sheetmodify sheet("pp_`pr'h_`tipo'")
		}
	}
}


