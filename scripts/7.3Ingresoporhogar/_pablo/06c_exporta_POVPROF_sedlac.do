
********* ABRE BASE DE DATOS *********
********** DEFINE MATRICES *********

* CONTADOR DE FILAS (encuestas + espacios intermedios)
loc n = $nn

*** Numero de replicas del bootstrap (si reps < 50 no corre el bootstrap)

loc rep = $rrep

 forvalue i=1/`n' {
	{
		********* TRANSFERENCIA A XLS *********
		loc ncomp = wordcount("${lista_comparacion}")
		loc DD =""
		forvalues i = 1 / `ncomp' {
			loc a=3+(`i'-1)*5
			loc DD ="`DD' `a'"
		}
		* Arma matrices
		summ ano
		local ano=r(min)
		local var "dem reg aglo viv edu em1 em2 em3 pap ing des nbi" 
		foreach v of local var {
			loc lmm ""
			foreach mm of global lista_comparacion {
				loc lmm "`lmm' `v'_`mm',`v'_MS,"
			}
			loc lmm "`lmm' `v'_MS"
			mat Pov_prof_`v'=`lmm'
		} 

		loc asteriscos "dem reg aglo viv edu em1 em2 em3 pap ing"
		foreach a of local asteriscos	{
			
			loc decimales = 1

			drop _all
			svmat double Pov_prof_`a'

			loc D = "`DD'"
			foreach d of local D	{
				loc e = `d' + 1
				gen aux`d'=string(Pov_prof_`a'`d',"%15.`decimales'f")
				if "`a'"=="em2" {
					replace aux`d'=string(Pov_prof_`a'`d',"%15.1f") if _n>=8 & _n<=20
				}
				if "`a'"=="ing" {
					replace aux`d'=string(Pov_prof_`a'`d',"%15.1f") if _n<=2
					replace aux`d'=string(Pov_prof_`a'`d',"%15.3f") if _n==4
				}
				replace aux`d' = aux`d' + "*" if Pov_prof_`a'`e' < 0.10
				replace aux`d' = aux`d' + "*" if Pov_prof_`a'`e' < 0.05
				replace aux`d' = aux`d' + "*" if Pov_prof_`a'`e' < 0.01
				replace aux`d' = "" if aux`d' == "."
				move aux`d'  Pov_prof_`a'`e'
				drop Pov_prof_`a'`d' Pov_prof_`a'`e'
			}
			loc celda "${celda}"
			if "`a'"=="aglo" loc celda "B90"
			export excel using "${pathout}\${nombrexls}", cell(`celda') sheetmodify sheet("`a'")
		}

		local tablas "des nbi"
		foreach t of local tablas {
			drop _all
			svmat double Pov_prof_`t'
			export excel using "${pathout}\${nombrexls}", cell(${celda}) sheetmodify sheet("`t'")
		}

	} 
} 
