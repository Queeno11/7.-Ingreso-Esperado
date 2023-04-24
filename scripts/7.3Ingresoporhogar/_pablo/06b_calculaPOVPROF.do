
********* ABRE BASE DE DATOS *********
********** DEFINE MATRICES *********

* CONTADOR DE FILAS (encuestas + espacios intermedios)
loc n = $nn

*** Numero de replicas del bootstrap (si reps < 50 no corre el bootstrap)

loc rep = $rrep

keep if ${comp_pob1} ==1 | ${comp_pob2} ==1
if "${exclusivo}" == "si" drop if ${comp_pob1} ==1 & ${comp_pob2} ==1

***********************************************
********** defino matrices ********************
***********************************************
matrix dem_${comp_pob1}_${comp_pob2} = J(37,4,.)
matrix reg_${comp_pob1}_${comp_pob2} = J(42,4,.)
matrix viv_${comp_pob1}_${comp_pob2} = J(17,4,.)
matrix edu_${comp_pob1}_${comp_pob2} = J(37,4,.)
matrix em1_${comp_pob1}_${comp_pob2} = J(26,4,.)
matrix em2_${comp_pob1}_${comp_pob2} = J(22,4,.)
matrix em3_${comp_pob1}_${comp_pob2} = J(49,4,.)
matrix pap_${comp_pob1}_${comp_pob2} = J(7,4,.)
matrix ing_${comp_pob1}_${comp_pob2} = J(23,4,.)
matrix des_${comp_pob1}_${comp_pob2} = J(11,2,.)
matrix nbi_${comp_pob1}_${comp_pob2} = J(6,2,.)
*nueva
matrix aglo_${comp_pob1}_${comp_pob2} = J(76,4,.)

matrix dem_MS = J(37,1,.)
matrix reg_MS = J(42,1,.)
matrix viv_MS = J(17,1,.)
matrix edu_MS = J(37,1,.)
matrix em1_MS = J(26,1,.)
matrix em2_MS = J(22,1,.)
matrix em3_MS = J(49,1,.)
matrix pap_MS = J(7,1,.)
matrix ing_MS = J(23,1,.)
matrix des_MS = J(11,1,.)
matrix nbi_MS = J(6,1,.)
*nueva
matrix aglo_MS= J(76,1,.)


forvalue i=1/`n' {
		{
		count if ${comp_pob1}!=.
		if r(N)>0 {

			* Define pobreza por NBI e ingreso
			gen	nbi_${comp_pob1}_${comp_pob2} = .
			replace nbi_${comp_pob1}_${comp_pob2} = 1  if  nbi==1 & ${comp_pob1}==1
			replace nbi_${comp_pob1}_${comp_pob2} = 0  if  nbi==0 | ${comp_pob1}==0

			capture drop coh
			gen coh=cohh

			********** VARIABLES DEMOGRÁFICAS ***********

			* Poverty 
			summ ${comp_pob1} [w=pondera] 
			mat dem_${comp_pob1}_${comp_pob2}[1,1] = r(mean)*100
			mat dem_${comp_pob1}_${comp_pob2}[1,2] = 100 - dem_${comp_pob1}_${comp_pob2}[1,1]

			* Population Share by Age
			forvalues i=1/5 {
				summ ${comp_pob1} [w=pondera] if gedad==`i' 
				mat dem_${comp_pob1}_${comp_pob2}[`i'+3,1] = r(mean)*100
			}

			forvalues i=1/5 {
				mat dem_${comp_pob1}_${comp_pob2}[`i'+3,2] = 100 - dem_${comp_pob1}_${comp_pob2}[`i'+3,1]
			}

			* Age Distribution
			tab gedad ${comp_pob1} [w=pondera], matcell(aux)
			local sum_pob    = aux[1,2] + aux[2,2] + aux[3,2] + aux[4,2] + aux[5,2]
			local sum_no_pob = aux[1,1] + aux[2,1] + aux[3,1] + aux[4,1] + aux[5,1]

			forvalues i=1/5 {
				mat dem_${comp_pob1}_${comp_pob2}[10+`i',1] = aux[`i',2] / `sum_pob'    * 100
				mat dem_${comp_pob1}_${comp_pob2}[10+`i',2] = aux[`i',1] / `sum_no_pob' * 100
			}

			mat dem_${comp_pob1}_${comp_pob2}[16,1] = dem_${comp_pob1}_${comp_pob2}[11,1] + dem_${comp_pob1}_${comp_pob2}[12,1] + dem_${comp_pob1}_${comp_pob2}[13,1] + dem_${comp_pob1}_${comp_pob2}[14,1] + dem_${comp_pob1}_${comp_pob2}[15,1]
			mat dem_${comp_pob1}_${comp_pob2}[16,2] = dem_${comp_pob1}_${comp_pob2}[11,2] + dem_${comp_pob1}_${comp_pob2}[12,2] + dem_${comp_pob1}_${comp_pob2}[13,2] + dem_${comp_pob1}_${comp_pob2}[14,2] + dem_${comp_pob1}_${comp_pob2}[15,2]

			qui ta gedad, g(auxedad)
			forvalues i=1/5	{
				qui count if auxedad`i'<. & pondera<. & ${comp_pob1}==1
				loc n1=r(N)
				qui count if auxedad`i'<. & pondera<. & ${comp_pob1}==0
				loc n2=r(N)
				if `n1'>0 & `n2'>0  {
					hotel_mio auxedad`i' [w=pondera], by(${comp_pob1})
					mat dem_${comp_pob1}_${comp_pob2}[10+`i',3] = dem_${comp_pob1}_${comp_pob2}[10+`i',1] - dem_${comp_pob1}_${comp_pob2}[10+`i',2]
					mat dem_${comp_pob1}_${comp_pob2}[10+`i',4] = r(zeta)
				}
			}
			drop auxedad*	

			* Mean Age
			summ edad [w=pondera]  if  ${comp_pob1}==1
			mat dem_${comp_pob1}_${comp_pob2}[18,1] = r(mean)
			summ edad [w=pondera]  if  ${comp_pob1}==0
			mat dem_${comp_pob1}_${comp_pob2}[18,2] = r(mean)

			qui count if edad <. & pondera <. & ${comp_pob1}==1
			loc n1=r(N)
			qui count if edad <. & pondera <. & ${comp_pob1}==0
			loc n2=r(N)
			if `n1'>0 & `n2'>0  {
				hotel_mio edad [w=pondera], by(${comp_pob1})
				mat dem_${comp_pob1}_${comp_pob2}[18,3] = dem_${comp_pob1}_${comp_pob2}[18,1] - dem_${comp_pob1}_${comp_pob2}[18,2] 
				mat dem_${comp_pob1}_${comp_pob2}[18,4] = r(zeta) 
			}

			* Share Males
			summ hombre [w=pondera] if ${comp_pob1}==1
			mat dem_${comp_pob1}_${comp_pob2}[21,1] = r(mean)*100		
			summ hombre [w=pondera] if ${comp_pob1}==0
			mat dem_${comp_pob1}_${comp_pob2}[21,2] = r(mean)*100		

			hotel_mio hombre [w=pondera], by(${comp_pob1})
			mat dem_${comp_pob1}_${comp_pob2}[21,3] = dem_${comp_pob1}_${comp_pob2}[21,1] - dem_${comp_pob1}_${comp_pob2}[21,2]
			mat dem_${comp_pob1}_${comp_pob2}[21,4] = r(zeta)

			* Family Size
			summ miembros [w=pondera] if hogar==1 & ${comp_pob1}==1
			mat dem_${comp_pob1}_${comp_pob2}[23,1] = r(mean)
			summ miembros [w=pondera] if hogar==1 & ${comp_pob1}==0
			mat dem_${comp_pob1}_${comp_pob2}[23,2] = r(mean)

			qui count if miembros <. & pondera <. & ${comp_pob1}==1
			loc n1=r(N)
			qui count if miembros <. & pondera <. & ${comp_pob1}==0
			loc n2=r(N)
			if `n1'>0 & `n2'>0  {
				hotel_mio miembros [w=pondera], by(${comp_pob1})
				mat dem_${comp_pob1}_${comp_pob2}[23,3] = dem_${comp_pob1}_${comp_pob2}[23,1] - dem_${comp_pob1}_${comp_pob2}[23,2]
				mat dem_${comp_pob1}_${comp_pob2}[23,4] = r(zeta)
			}

			* Children 
			summ m12h [w=pondera]  if  jefe==1 & edad>=25 & edad<=45 & ${comp_pob1}==1
			mat dem_${comp_pob1}_${comp_pob2}[25,1] = r(mean)
			summ m12h [w=pondera]  if  jefe==1 & edad>=25 & edad<=45 & ${comp_pob1}==0
			mat dem_${comp_pob1}_${comp_pob2}[25,2] = r(mean)

			qui count if m12h <. & pondera <. & ${comp_pob1}==1
			loc n1=r(N)
			qui count if m12h <. & pondera <. & ${comp_pob1}==0
			loc n2=r(N)
			if `n1'>0 & `n2'>0  {
				hotel_mio m12h [w=pondera], by(${comp_pob1})
				mat dem_${comp_pob1}_${comp_pob2}[25,3] = dem_${comp_pob1}_${comp_pob2}[25,1] - dem_${comp_pob1}_${comp_pob2}[25,2]
				mat dem_${comp_pob1}_${comp_pob2}[25,4] = r(zeta)
			}

			* Dependency Rate
			summ depen [w=pondera]  if  hogar==1 & ${comp_pob1}==1
			mat dem_${comp_pob1}_${comp_pob2}[27,1] = r(mean)
			summ depen [w=pondera]  if  hogar==1 & ${comp_pob1}==0
			mat dem_${comp_pob1}_${comp_pob2}[27,2] = r(mean)

			qui count if depen <. & pondera <. & ${comp_pob1}==1
			loc n1=r(N)
			qui count if depen <. & pondera <. & ${comp_pob1}==0
			loc n2=r(N)
			if `n1'>0 & `n2'>0  {
				hotel_mio depen [w=pondera], by(${comp_pob1})
				mat dem_${comp_pob1}_${comp_pob2}[27,3] = dem_${comp_pob1}_${comp_pob2}[27,1] - dem_${comp_pob1}_${comp_pob2}[27,2]
				mat dem_${comp_pob1}_${comp_pob2}[27,4] = r(zeta)
			}

			* Female-Headed Households
			summ mujer_jefe [w=pondera]  if  hogar==1 & ${comp_pob1}==1
			mat dem_${comp_pob1}_${comp_pob2}[29,1] = r(mean)*100		
			summ mujer_jefe [w=pondera]  if  hogar==1 & ${comp_pob1}==0
			mat dem_${comp_pob1}_${comp_pob2}[29,2] = r(mean)*100		

			qui count if mujer_jefe <. & pondera <. & ${comp_pob1}==1
			loc n1=r(N)
			qui count if mujer_jefe <. & pondera <. & ${comp_pob1}==0
			loc n2=r(N)
			if `n1'>0 & `n2'>0  {
				hotel_mio mujer_jefe [w=pondera], by(${comp_pob1})
				mat dem_${comp_pob1}_${comp_pob2}[29,3] = dem_${comp_pob1}_${comp_pob2}[29,1] - dem_${comp_pob1}_${comp_pob2}[29,2]
				mat dem_${comp_pob1}_${comp_pob2}[29,4] = r(zeta)
			}

			* Ethnicity
			summ raza [w=pondera]  if  ${comp_pob1}==1 & raza<=7 
			local    sum_pob = r(sum_w)
			summ raza [w=pondera]  if  ${comp_pob1}==0 & raza<=7 
			local sum_no_pob = r(sum_w)

			/*(** Muestra los resultados sin dejar espacios para categorías faltantes (cada uno debería adaptar su xls) *)*/
			count if raza!=.
			if r(N)>0 {

				qui ta raza, g(auxraza)

				foreach v of varlist auxraza* {
					display as text "v = " as result "`v'"
					local j=substr("`v'",8,1)	
				}

				forvalues i=1/`j' {
					summ auxraza`i' [w=pondera]  if  auxraza`i'==1 & ${comp_pob1}==1 
					mat dem_${comp_pob1}_${comp_pob2}[30+`i',1] = r(sum_w) / `sum_pob'    * 100
					summ auxraza`i' [w=pondera]  if auxraza`i'==1 & ${comp_pob1}==0 
					mat dem_${comp_pob1}_${comp_pob2}[30+`i',2] = r(sum_w) / `sum_no_pob' * 100
				}

				mat dem_${comp_pob1}_${comp_pob2}[36,1] = dem_${comp_pob1}_${comp_pob2}[31,1] + dem_${comp_pob1}_${comp_pob2}[32,1] + dem_${comp_pob1}_${comp_pob2}[33,1] + dem_${comp_pob1}_${comp_pob2}[34,1] + dem_${comp_pob1}_${comp_pob2}[35,1]
				mat dem_${comp_pob1}_${comp_pob2}[36,2] = dem_${comp_pob1}_${comp_pob2}[31,2] + dem_${comp_pob1}_${comp_pob2}[32,2] + dem_${comp_pob1}_${comp_pob2}[33,2] + dem_${comp_pob1}_${comp_pob2}[34,2] + dem_${comp_pob1}_${comp_pob2}[35,2]

				forvalues i=1/`j' {
					capture qui count if auxraza`i' <. & pondera <. & ${comp_pob1}==1
					loc n1=r(N)
					capture qui count if auxraza`i' <. & pondera <. & ${comp_pob1}==0
					loc n2=r(N)
					if `n1'>0 & `n2'>0  {
						hotel_mio auxraza`i' [w=pondera], by(${comp_pob1})
						mat dem_${comp_pob1}_${comp_pob2}[30+`i',3] = dem_${comp_pob1}_${comp_pob2}[30+`i',1] - dem_${comp_pob1}_${comp_pob2}[30+`i',2]
						mat dem_${comp_pob1}_${comp_pob2}[30+`i',4] = r(zeta)
					}
				}
				capture drop auxraza*
			}

			********** REGIONES ***********

			** Urban-Rural

			count if urbano==0
			if r(N)>0 {

				* Poverty 
				forvalues i=0/1 {
					summ ${comp_pob1} [w=pondera]  if  urbano==`i'
					mat reg_${comp_pob1}_${comp_pob2}[`i'+1,1] = r(mean)*100
					mat reg_${comp_pob1}_${comp_pob2}[`i'+1,2] = 100 - reg_${comp_pob1}_${comp_pob2}[`i'+1,1]
				}

				count if ${comp_pob1}!=.
				if r(N)>0 {

					* Distribution of Poor  
					tab urbano ${comp_pob1} [w=pondera], matcell(aux)
					local    sum_pob = aux[1,2] + aux[2,2]
					local sum_no_pob = aux[1,1] + aux[2,1]

					forvalues i=0/1	{
						mat reg_${comp_pob1}_${comp_pob2}[4+`i',1] = aux[`i'+1,2]/`sum_pob'*100
						mat reg_${comp_pob1}_${comp_pob2}[4+`i',2] = aux[`i'+1,1]/`sum_no_pob'*100
					}

					mat reg_${comp_pob1}_${comp_pob2}[6,1] = reg_${comp_pob1}_${comp_pob2}[4,1] + reg_${comp_pob1}_${comp_pob2}[5,1]
					mat reg_${comp_pob1}_${comp_pob2}[6,2] = reg_${comp_pob1}_${comp_pob2}[4,2] + reg_${comp_pob1}_${comp_pob2}[5,2]
						
					qui count if urbano <. & pondera <. & ${comp_pob1}==1
					loc n1=r(N)
					qui count if urbano <. & pondera <. & ${comp_pob1}==0
					loc n2=r(N)
					if `n1'>0 & `n2'>0  {
						hotel_mio urbano [w=pondera], by(${comp_pob1})
						mat reg_${comp_pob1}_${comp_pob2}[4,3] = reg_${comp_pob1}_${comp_pob2}[4,1] - reg_${comp_pob1}_${comp_pob2}[4,2]
						mat reg_${comp_pob1}_${comp_pob2}[4,4] = r(zeta)
						mat reg_${comp_pob1}_${comp_pob2}[5,3] = reg_${comp_pob1}_${comp_pob2}[5,1] - reg_${comp_pob1}_${comp_pob2}[5,2]
						mat reg_${comp_pob1}_${comp_pob2}[5,4] = r(zeta)
					}
				}
			}

			** Regions
			* Poverty 
			forvalues i=1/16 {
				summ ${comp_pob1} [w=pondera]  if  region==`i'
				mat reg_${comp_pob1}_${comp_pob2}[9+`i',1] = r(mean) * 100
				mat reg_${comp_pob1}_${comp_pob2}[9+`i',2] = 100 - reg_${comp_pob1}_${comp_pob2}[9+`i',1]
			}

			* Distribution of poor  
			tab region
			local nro_regiones=r(r)

			tab region ${comp_pob1} [w=pondera], matcell(aux)

			local i=1
			local sum_no_pob=0
			forvalues i=1/`nro_regiones' {
				local sum_no_pob = `sum_no_pob' + aux[`i',1]
				local i = `i' + 1
			}
			local i=1
			local sum_pob=0
			forvalues i=1/`nro_regiones' {
				local sum_pob = `sum_pob' + aux[`i',2]
				local i = `i' + 1
			}

			forvalues i=1/`nro_regiones' {
				mat reg_${comp_pob1}_${comp_pob2}[10+`nro_regiones'+`i',1] = aux[`i',2] / `sum_pob'    * 100
				mat reg_${comp_pob1}_${comp_pob2}[10+`nro_regiones'+`i',2] = aux[`i',1] / `sum_no_pob' * 100
			}

			qui ta region, g(auxreg)
			forvalues i=1/`nro_regiones' {
				qui count if auxreg`i' <. & pondera <. & ${comp_pob1}==1
				loc n1=r(N)
				qui count if auxreg`i' <. & pondera <. & ${comp_pob1}==0
				loc n2=r(N)
				if `n1'>0 & `n2'>0  {
					hotel_mio auxreg`i' [w=pondera], by(${comp_pob1}) 
					mat reg_${comp_pob1}_${comp_pob2}[10+`nro_regiones'+`i',3] = reg_${comp_pob1}_${comp_pob2}[10+`nro_regiones'+`i',1] - reg_${comp_pob1}_${comp_pob2}[10+`nro_regiones'+`i',2]
					mat reg_${comp_pob1}_${comp_pob2}[10+`nro_regiones'+`i',4] = r(zeta)
				}
			}
			drop auxreg*

			********** AGLOMERADOS ***********

			** Urban-Rural

			count if urbano==0
			if r(N)>0 {

				* Poverty 
				forvalues i=0/1 {
					summ ${comp_pob1} [w=pondera]  if  urbano==`i'
					mat aglo_${comp_pob1}_${comp_pob2}[`i'+1,1] = r(mean)*100
					mat aglo_${comp_pob1}_${comp_pob2}[`i'+1,2] = 100 - aglo_${comp_pob1}_${comp_pob2}[`i'+1,1]
				}

				count if ${comp_pob1}!=.
				if r(N)>0 {

					* Distribution of Poor  
					tab urbano ${comp_pob1} [w=pondera], matcell(aux)
					local    sum_pob = aux[1,2] + aux[2,2]
					local sum_no_pob = aux[1,1] + aux[2,1]

					forvalues i=0/1	{
						mat aglo_${comp_pob1}_${comp_pob2}[4+`i',1] = aux[`i'+1,2]/`sum_pob'*100
						mat aglo_${comp_pob1}_${comp_pob2}[4+`i',2] = aux[`i'+1,1]/`sum_no_pob'*100
					}

					mat aglo_${comp_pob1}_${comp_pob2}[6,1] = aglo_${comp_pob1}_${comp_pob2}[4,1] + aglo_${comp_pob1}_${comp_pob2}[5,1]
					mat aglo_${comp_pob1}_${comp_pob2}[6,2] = aglo_${comp_pob1}_${comp_pob2}[4,2] + aglo_${comp_pob1}_${comp_pob2}[5,2]
						
					qui count if urbano <. & pondera <. & ${comp_pob1}==1
					loc n1=r(N)
					qui count if urbano <. & pondera <. & ${comp_pob1}==0
					loc n2=r(N)
					if `n1'>0 & `n2'>0  {
						hotel_mio urbano [w=pondera], by(${comp_pob1})
						mat aglo_${comp_pob1}_${comp_pob2}[4,3] = aglo_${comp_pob1}_${comp_pob2}[4,1] - aglo_${comp_pob1}_${comp_pob2}[4,2]
						mat aglo_${comp_pob1}_${comp_pob2}[4,4] = r(zeta)
						mat aglo_${comp_pob1}_${comp_pob2}[5,3] = aglo_${comp_pob1}_${comp_pob2}[5,1] - aglo_${comp_pob1}_${comp_pob2}[5,2]
						mat aglo_${comp_pob1}_${comp_pob2}[5,4] = r(zeta)
					}
				}
			}

			** Regions
			* Poverty 
			forvalues i=1/33 {
				summ ${comp_pob1} [w=pondera]  if  aglo_orden==`i'
				mat aglo_${comp_pob1}_${comp_pob2}[9+`i',1] = r(mean) * 100
				mat aglo_${comp_pob1}_${comp_pob2}[9+`i',2] = 100 - aglo_${comp_pob1}_${comp_pob2}[9+`i',1]
			}

			* Distribution of poor  
			tab aglo_orden
			local nro_aglos=r(r)

			tab aglo_orden ${comp_pob1} [w=pondera], matcell(aux)

			local i=1
			local sum_no_pob=0
			forvalues i=1/`nro_aglos' {
				local sum_no_pob = `sum_no_pob' + aux[`i',1]
				local i = `i' + 1
			}
			local i=1
			local sum_pob=0
			forvalues i=1/`nro_aglos' {
				local sum_pob = `sum_pob' + aux[`i',2]
				local i = `i' + 1
			}

			forvalues i=1/`nro_aglos' {
				mat aglo_${comp_pob1}_${comp_pob2}[10+`nro_aglos'+`i',1] = aux[`i',2] / `sum_pob'    * 100
				mat aglo_${comp_pob1}_${comp_pob2}[10+`nro_aglos'+`i',2] = aux[`i',1] / `sum_no_pob' * 100
			}

			qui ta aglo_orden, g(auxaglo)
			forvalues i=1/`nro_aglos' {
				qui count if auxaglo`i' <. & pondera <. & ${comp_pob1}==1
				loc n1=r(N)
				qui count if auxaglo`i' <. & pondera <. & ${comp_pob1}==0
				loc n2=r(N)
				if `n1'>0 & `n2'>0  {
					hotel_mio auxaglo`i' [w=pondera], by(${comp_pob1}) 
					mat aglo_${comp_pob1}_${comp_pob2}[10+`nro_aglos'+`i',3] = aglo_${comp_pob1}_${comp_pob2}[10+`nro_aglos'+`i',1] - aglo_${comp_pob1}_${comp_pob2}[10+`nro_aglos'+`i',2]
					mat aglo_${comp_pob1}_${comp_pob2}[10+`nro_aglos'+`i',4] = r(zeta)
				}
			}
			drop auxaglo*

			********** VIVIENDA Y SERVICIOS **********
			local variables "propieta habita per_habita precar matpreca agua banio cloaca elec"

			local i=1
			foreach v of local variables {
				summ `v' [w=pondera] if hogar==1 & ${comp_pob1}==1
				if ("`v'"=="habita" | "`v'"=="per_habita") mat viv_${comp_pob1}_${comp_pob2}[`i',1] = r(mean)	
				else mat viv_${comp_pob1}_${comp_pob2}[`i',1] = r(mean)*100		
				local i=`i'+2
			}

			local i=1
			foreach v of local variables {
				summ `v' [w=pondera] if hogar==1 & ${comp_pob1}==0
				if ("`v'"=="habita" | "`v'"=="per_habita") mat viv_${comp_pob1}_${comp_pob2}[`i',2] = r(mean)	
				else mat viv_${comp_pob1}_${comp_pob2}[`i',2] = r(mean)*100		
				local i=`i'+2
			}

			local i=1
			foreach v of local variables {
				sum `v'  if hogar==1 & ${comp_pob1}==0
				loc n1=r(N)
				sum `v'  if hogar==1 & ${comp_pob1}==1
				loc n2=r(N)
				if `n1'>0 & `n2'>0 {
					hotel_mio `v' [w=pondera] if hogar==1, by(${comp_pob1})
				}
				mat viv_${comp_pob1}_${comp_pob2}[`i',3] = viv_${comp_pob1}_${comp_pob2}[`i',1] - viv_${comp_pob1}_${comp_pob2}[`i',2]
				mat viv_${comp_pob1}_${comp_pob2}[`i',4] = r(zeta)
				local i=`i'+2
			}

			********** EDUCACION **********

			* Years of Education
			summ aedu [w=pondera]  if  ${comp_pob1}==1
			mat edu_${comp_pob1}_${comp_pob2}[1,1] = r(mean)
			summ aedu [w=pondera]  if  ${comp_pob1}==0
			mat edu_${comp_pob1}_${comp_pob2}[1,2] = r(mean)

			qui count if aedu <. & pondera <. & ${comp_pob1}==1
			loc n1=r(N)
			qui count if aedu <. & pondera <. & ${comp_pob1}==0
			loc n2=r(N)
			if `n1'>0 & `n2'>0 {
				hotel_mio aedu [w=pondera], by(${comp_pob1})
			}

			mat edu_${comp_pob1}_${comp_pob2}[1,3] = edu_${comp_pob1}_${comp_pob2}[1,1] - edu_${comp_pob1}_${comp_pob2}[1,2]
			mat edu_${comp_pob1}_${comp_pob2}[1,4] = r(zeta)

			summ aedu [w=pondera]  if  edad>=10 & edad<=20 & ${comp_pob1}==1
			mat edu_${comp_pob1}_${comp_pob2}[2,1] = r(mean)
			summ aedu [w=pondera]  if  edad>=10 & edad<=20 & ${comp_pob1}==0
			mat edu_${comp_pob1}_${comp_pob2}[2,2] = r(mean)

			qui count if aedu <. & pondera <. & ${comp_pob1}==1 & edad>=10 & edad<=20 
			loc n1=r(N)
			qui count if aedu <. & pondera <. & ${comp_pob1}==0 & edad>=10 & edad<=20 
			loc n2=r(N)
			if `n1'>0 & `n2'>0 {
				hotel_mio aedu [w=pondera] if edad>=10 & edad<=20, by(${comp_pob1})
			}

			mat edu_${comp_pob1}_${comp_pob2}[2,3] = edu_${comp_pob1}_${comp_pob2}[2,1] - edu_${comp_pob1}_${comp_pob2}[2,2] 
			mat edu_${comp_pob1}_${comp_pob2}[2,4] = r(zeta)

			summ aedu [w=pondera]  if  edad>=21 & edad<=30 & ${comp_pob1}==1
			mat edu_${comp_pob1}_${comp_pob2}[3,1] = r(mean)
			summ aedu [w=pondera]  if  edad>=21 & edad<=30 & ${comp_pob1}==0
			mat edu_${comp_pob1}_${comp_pob2}[3,2] = r(mean)

			qui count if aedu <. & pondera <. & ${comp_pob1}==1 & edad>=21 & edad<=30 
			loc n1=r(N)
			qui count if aedu <. & pondera <. & ${comp_pob1}==0 & edad>=21 & edad<=30
			loc n2=r(N)
			if `n1'>0 & `n2'>0 {
				hotel_mio aedu [w=pondera] if edad>=21 & edad<=30, by(${comp_pob1})
			}

			mat edu_${comp_pob1}_${comp_pob2}[3,3] = edu_${comp_pob1}_${comp_pob2}[3,1] - edu_${comp_pob1}_${comp_pob2}[3,2] 
			mat edu_${comp_pob1}_${comp_pob2}[3,4] = r(zeta)

			summ aedu [w=pondera]  if  edad>=31 & edad<=40 & ${comp_pob1}==1
			mat edu_${comp_pob1}_${comp_pob2}[4,1] = r(mean)
			summ aedu [w=pondera]  if  edad>=31 & edad<=40 & ${comp_pob1}==0
			mat edu_${comp_pob1}_${comp_pob2}[4,2] = r(mean)

			qui count if aedu <. & pondera <. & ${comp_pob1}==1 & edad>=31 & edad<=40
			loc n1=r(N)
			qui count if aedu <. & pondera <. & ${comp_pob1}==0 & edad>=31 & edad<=40
			loc n2=r(N)
			if `n1'>0 & `n2'>0 {
				hotel_mio aedu [w=pondera] if edad>=31 & edad<=40, by(${comp_pob1})
			}

			mat edu_${comp_pob1}_${comp_pob2}[4,3] = edu_${comp_pob1}_${comp_pob2}[4,1] - edu_${comp_pob1}_${comp_pob2}[4,2]
			mat edu_${comp_pob1}_${comp_pob2}[4,4] = r(zeta)

			summ aedu [w=pondera]  if  edad>=41 & edad<=50 & ${comp_pob1}==1
			mat edu_${comp_pob1}_${comp_pob2}[5,1] = r(mean)
			summ aedu [w=pondera]  if  edad>=41 & edad<=50 & ${comp_pob1}==0
			mat edu_${comp_pob1}_${comp_pob2}[5,2] = r(mean)

			qui count if aedu <. & pondera <. & ${comp_pob1}==1 & edad>=41 & edad<=50
			loc n1=r(N)
			qui count if aedu <. & pondera <. & ${comp_pob1}==0 & edad>=41 & edad<=50
			loc n2=r(N)
			if `n1'>0 & `n2'>0 {
				hotel_mio aedu [w=pondera] if edad>=41 & edad<=50, by(${comp_pob1})
			}

			mat edu_${comp_pob1}_${comp_pob2}[5,3] = edu_${comp_pob1}_${comp_pob2}[5,1] - edu_${comp_pob1}_${comp_pob2}[5,2]
			mat edu_${comp_pob1}_${comp_pob2}[5,4] = r(zeta)

			summ aedu [w=pondera]  if  edad>=51 & edad<=60 & ${comp_pob1}==1
			mat edu_${comp_pob1}_${comp_pob2}[6,1] = r(mean)
			summ aedu [w=pondera]  if  edad>=51 & edad<=60 & ${comp_pob1}==0
			mat edu_${comp_pob1}_${comp_pob2}[6,2] = r(mean)
			qui count if aedu <. & pondera <. & ${comp_pob1}==1 & edad>=51 & edad<=60
			loc n1=r(N)

			qui count if aedu <. & pondera <. & ${comp_pob1}==0 & edad>=51 & edad<=60
			loc n2=r(N)
			if `n1'>0 & `n2'>0 {
				hotel_mio aedu [w=pondera] if edad>=51 & edad<=60, by(${comp_pob1})
			}

			mat edu_${comp_pob1}_${comp_pob2}[6,3] = edu_${comp_pob1}_${comp_pob2}[6,1] - edu_${comp_pob1}_${comp_pob2}[6,2]
			mat edu_${comp_pob1}_${comp_pob2}[6,4] = r(zeta)

			summ aedu [w=pondera]  if  edad>=61 & edad<=100 & ${comp_pob1}==1
			mat edu_${comp_pob1}_${comp_pob2}[7,1] = r(mean)
			summ aedu [w=pondera]  if  edad>=61 & edad<=100 & ${comp_pob1}==0
			mat edu_${comp_pob1}_${comp_pob2}[7,2] = r(mean)

			qui count if aedu <. & pondera <. & ${comp_pob1}==1 & edad>=61 & edad<=100
			loc n1=r(N)
			qui count if aedu <. & pondera <. & ${comp_pob1}==0 & edad>=61 & edad<=100
			loc n2=r(N)
			if `n1'>0 & `n2'>0 {
				hotel_mio aedu [w=pondera] if edad>=61 & edad<=100, by(${comp_pob1})
			}
			mat edu_${comp_pob1}_${comp_pob2}[7,3] = edu_${comp_pob1}_${comp_pob2}[7,1] - edu_${comp_pob1}_${comp_pob2}[7,2]
			mat edu_${comp_pob1}_${comp_pob2}[7,4] = r(zeta)


			* Educational Groups
			summ nivedu [w=pondera]  if  edad>=25 & edad<=65 & ${comp_pob1}==1
			local sum_pob = r(sum_w)
			summ nivedu [w=pondera]  if  edad>=25 & edad<=65 & ${comp_pob1}==0
			local sum_no_pob = r(sum_w)

			tab nivedu ${comp_pob1} [w=pondera]  if  edad>=25 & edad<=65, matcell(aux)
			forvalues i=1/3 {
				mat edu_${comp_pob1}_${comp_pob2}[10+`i',1] = aux[`i',2] / `sum_pob'    * 100
				mat edu_${comp_pob1}_${comp_pob2}[10+`i',2] = aux[`i',1] / `sum_no_pob' * 100
			}

			mat edu_${comp_pob1}_${comp_pob2}[14,1] = edu_${comp_pob1}_${comp_pob2}[11,1] + edu_${comp_pob1}_${comp_pob2}[12,1] + edu_${comp_pob1}_${comp_pob2}[13,1]
			mat edu_${comp_pob1}_${comp_pob2}[14,2] = edu_${comp_pob1}_${comp_pob2}[11,2] + edu_${comp_pob1}_${comp_pob2}[12,2] + edu_${comp_pob1}_${comp_pob2}[13,2]

			count if nivedu!=.
			if r(N)>0 {
				qui ta nivedu, g(auxnivel)
				forvalues i=1/3 {
					qui count if auxnivel`i' <. & pondera <. & ${comp_pob1}==1 & edad>=25 & edad<=65
					loc n1=r(N)
					qui count if auxnivel`i' <. & pondera <. & ${comp_pob1}==0 & edad>=25 & edad<=65
					loc n2=r(N)
					if `n1'>0 & `n2'>0 {
						hotel_mio auxnivel`i' [w=pondera]  if  edad>=25 & edad<=65, by(${comp_pob1})
						mat edu_${comp_pob1}_${comp_pob2}[10+`i',3] = edu_${comp_pob1}_${comp_pob2}[10+`i',1] - edu_${comp_pob1}_${comp_pob2}[10+`i',2]
						mat edu_${comp_pob1}_${comp_pob2}[10+`i',4] = r(zeta)
					}
				}
			}

			summ nivedu [w=pondera]  if  edad>=25 & edad<=65 & hombre==1 & ${comp_pob1}==1
			local sum_pob = r(sum_w)
			summ nivedu [w=pondera]  if  edad>=25 & edad<=65 & hombre==1 & ${comp_pob1}==0
			local sum_no_pob = r(sum_w)

			tab nivedu ${comp_pob1} [w=pondera]  if  edad>=25 & edad<=65 & hombre==1, matcell(aux)
			forvalues i=1/3 {
					mat edu_${comp_pob1}_${comp_pob2}[15+`i',1] = aux[`i',2] / `sum_pob'    * 100
					mat edu_${comp_pob1}_${comp_pob2}[15+`i',2] = aux[`i',1] / `sum_no_pob' * 100
			}
			mat edu_${comp_pob1}_${comp_pob2}[19,1] = edu_${comp_pob1}_${comp_pob2}[16,1] + edu_${comp_pob1}_${comp_pob2}[17,1] + edu_${comp_pob1}_${comp_pob2}[18,1]
			mat edu_${comp_pob1}_${comp_pob2}[19,2] = edu_${comp_pob1}_${comp_pob2}[16,2] + edu_${comp_pob1}_${comp_pob2}[17,2] + edu_${comp_pob1}_${comp_pob2}[18,2]

			count if nivedu!=.
			if r(N)>0 {
				  forvalues i=1/3 {
					qui count if auxnivel`i' <. & pondera <. & ${comp_pob1}==1 & edad>=25 & edad<=65 & hombre==1
					loc n1=r(N)
					qui count if auxnivel`i' <. & pondera <. & ${comp_pob1}==0 & edad>=25 & edad<=65 & hombre==1
					loc n2=r(N)
					if `n1'>0 & `n2'>0 {
						hotel_mio auxnivel`i' [w=pondera] if edad>=25 & edad<=65 & hombre==1, by(${comp_pob1}) 
						mat edu_${comp_pob1}_${comp_pob2}[15+`i',3] = edu_${comp_pob1}_${comp_pob2}[15+`i',1] - edu_${comp_pob1}_${comp_pob2}[15+`i',2]
						mat edu_${comp_pob1}_${comp_pob2}[15+`i',4] = r(zeta)                                    
					}                                                                     
				}                                                                     
			}

			summ nivedu [w=pondera]  if  edad>=25 & edad<=65 & hombre==0 & ${comp_pob1}==1
			local sum_pob = r(sum_w) 
			summ nivedu [w=pondera]  if  edad>=25 & edad<=65 & hombre==0 & ${comp_pob1}==0
			local sum_no_pob = r(sum_w)

			tab nivedu ${comp_pob1} [w=pondera]  if  edad>=25 & edad<=65 & hombre==0, matcell(aux)
			forvalues i=1/3 {
				mat edu_${comp_pob1}_${comp_pob2}[20+`i',1] = aux[`i',2] / `sum_pob'    * 100
				mat edu_${comp_pob1}_${comp_pob2}[20+`i',2] = aux[`i',1] / `sum_no_pob' * 100
			}
			mat edu_${comp_pob1}_${comp_pob2}[24,1] = edu_${comp_pob1}_${comp_pob2}[21,1] + edu_${comp_pob1}_${comp_pob2}[22,1] + edu_${comp_pob1}_${comp_pob2}[23,1]
			mat edu_${comp_pob1}_${comp_pob2}[24,2] = edu_${comp_pob1}_${comp_pob2}[21,2] + edu_${comp_pob1}_${comp_pob2}[22,2] + edu_${comp_pob1}_${comp_pob2}[23,2]

			count if nivedu!=.
			if r(N)>0 {
				  forvalues i=1/3 {
					qui count if auxnivel`i' <. & pondera <. & ${comp_pob1}==1 & edad>=25 & edad<=65 & hombre==0
					loc n1=r(N)
					qui count if auxnivel`i' <. & pondera <. & ${comp_pob1}==0 & edad>=25 & edad<=65 & hombre==0
					loc n2=r(N)
					if `n1'>0 & `n2'>0 {
						hotel_mio auxnivel`i' [w=pondera] if edad>=25 & edad<=65 & hombre==0, by(${comp_pob1}) 
						mat edu_${comp_pob1}_${comp_pob2}[20+`i',3] = edu_${comp_pob1}_${comp_pob2}[20+`i',1] - edu_${comp_pob1}_${comp_pob2}[20+`i',2]
						mat edu_${comp_pob1}_${comp_pob2}[20+`i',4] = r(zeta)                                    
					}   
				}   
			}

			summ nivedu [w=pondera]  if  jefe==1 & ${comp_pob1}==1
			local sum_pob = r(sum_w)
			summ nivedu [w=pondera]  if  jefe==1 & ${comp_pob1}==0
			local sum_no_pob = r(sum_w)

			tab nivedu ${comp_pob1} [w=pondera]  if  jefe==1, matcell(aux)
			forvalues i=1/3 {
					mat edu_${comp_pob1}_${comp_pob2}[25+`i',1] = aux[`i',2] / `sum_pob'    * 100
					mat edu_${comp_pob1}_${comp_pob2}[25+`i',2] = aux[`i',1] / `sum_no_pob' * 100
					}
			mat edu_${comp_pob1}_${comp_pob2}[29,1] = edu_${comp_pob1}_${comp_pob2}[26,1] + edu_${comp_pob1}_${comp_pob2}[27,1] + edu_${comp_pob1}_${comp_pob2}[28,1]
			mat edu_${comp_pob1}_${comp_pob2}[29,2] = edu_${comp_pob1}_${comp_pob2}[26,2] + edu_${comp_pob1}_${comp_pob2}[27,2] + edu_${comp_pob1}_${comp_pob2}[28,2]

			count if nivedu!=.
			if r(N)>0 {
				  forvalues i=1/3 {
					qui count if auxnivel`i' <. & pondera <. & ${comp_pob1}==1 & jefe==1
					loc n1=r(N)
					qui count if auxnivel`i' <. & pondera <. & ${comp_pob1}==0 & jefe==1
					loc n2=r(N)
					if `n1'>0 & `n2'>0 {
						hotel_mio auxnivel`i' [w=pondera] if jefe==1, by(${comp_pob1}) 
						mat edu_${comp_pob1}_${comp_pob2}[25+`i',3] = edu_${comp_pob1}_${comp_pob2}[25+`i',1] - edu_${comp_pob1}_${comp_pob2}[25+`i',2]
						mat edu_${comp_pob1}_${comp_pob2}[25+`i',4] = r(zeta)                                    
					}   
				}   
				drop auxnivel*
			}

			* Literacy 
			summ alfabeto [w=pondera]  if  edad>10 & ${comp_pob1}==1
			mat edu_${comp_pob1}_${comp_pob2}[31,1] = r(mean)*100		
			summ alfabeto [w=pondera]  if  edad>10 & ${comp_pob1}==0
			mat edu_${comp_pob1}_${comp_pob2}[31,2] = r(mean)*100	

			qui count if alfabeto <. & pondera <. & ${comp_pob1}==1 & edad>10
			loc n1=r(N)
			qui count if alfabeto <. & pondera <. & ${comp_pob1}==0 & edad>10
			loc n2=r(N)
			if `n1'>0 & `n2'>0 {
				hotel_mio alfabeto [w=pondera] if edad>10, by(${comp_pob1}) 
			}

			mat edu_${comp_pob1}_${comp_pob2}[31,3] = edu_${comp_pob1}_${comp_pob2}[31,1] - edu_${comp_pob1}_${comp_pob2}[31,2]
			mat edu_${comp_pob1}_${comp_pob2}[31,4] = r(zeta)                                        

			* School Attendance
			summ asiste [w=pondera]  if  edad>=3 & edad<=5 & ${comp_pob1}==1
			mat edu_${comp_pob1}_${comp_pob2}[34,1] = r(mean)*100		
			summ asiste [w=pondera]  if  edad>=3 & edad<=5 & ${comp_pob1}==0
			mat edu_${comp_pob1}_${comp_pob2}[34,2] = r(mean)*100		

			qui count if asiste <. & pondera <. & ${comp_pob1}==1 & edad>=3 & edad<=5
			loc n1=r(N)
			qui count if asiste <. & pondera <. & ${comp_pob1}==0 & edad>=3 & edad<=5
			loc n2=r(N)
			if `n1'>0 & `n2'>0 {
				hotel_mio asiste [w=pondera] if edad>=3 & edad<=5, by(${comp_pob1})      
			}
			mat edu_${comp_pob1}_${comp_pob2}[34,3] = edu_${comp_pob1}_${comp_pob2}[34,1] - edu_${comp_pob1}_${comp_pob2}[34,2]
			mat edu_${comp_pob1}_${comp_pob2}[34,4] = r(zeta)   

			summ asiste [w=pondera]  if  edad>=6 & edad<=12 & ${comp_pob1}==1
			mat edu_${comp_pob1}_${comp_pob2}[35,1] = r(mean)*100		
			summ asiste [w=pondera]  if  edad>=6 & edad<=12 & ${comp_pob1}==0
			mat edu_${comp_pob1}_${comp_pob2}[35,2] = r(mean)*100		

			qui count if asiste <. & pondera <. & ${comp_pob1}==1 & edad>=6 & edad<=12
			loc n1=r(N)
			qui count if asiste <. & pondera <. & ${comp_pob1}==0 & edad>=6 & edad<=12
			loc n2=r(N)
			if `n1'>0 & `n2'>0 {
				hotel_mio asiste [w=pondera] if edad>=6 & edad<=12, by(${comp_pob1})  
			}
			mat edu_${comp_pob1}_${comp_pob2}[35,3] = edu_${comp_pob1}_${comp_pob2}[35,1] - edu_${comp_pob1}_${comp_pob2}[35,2]
			mat edu_${comp_pob1}_${comp_pob2}[35,4] = r(zeta)  

			summ asiste [w=pondera]  if  edad>=13 & edad<=17 & ${comp_pob1}==1
			mat edu_${comp_pob1}_${comp_pob2}[36,1] = r(mean)*100		
			summ asiste [w=pondera]  if  edad>=13 & edad<=17 & ${comp_pob1}==0
			mat edu_${comp_pob1}_${comp_pob2}[36,2] = r(mean)*100		

			qui count if asiste <. & pondera <. & ${comp_pob1}==1 & edad>=13 & edad<=17
			loc n1=r(N)
			qui count if asiste <. & pondera <. & ${comp_pob1}==0 & edad>=13 & edad<=17
			loc n2=r(N)
			if `n1'>0 & `n2'>0 {
					   hotel_mio asiste [w=pondera] if edad>=13 & edad<=17, by(${comp_pob1})   
					   }
			mat edu_${comp_pob1}_${comp_pob2}[36,3] = edu_${comp_pob1}_${comp_pob2}[36,1] - edu_${comp_pob1}_${comp_pob2}[36,2]
			mat edu_${comp_pob1}_${comp_pob2}[36,4] = r(zeta) 

			summ asiste [w=pondera]  if  edad>=18 & edad<=23 & ${comp_pob1}==1
			mat edu_${comp_pob1}_${comp_pob2}[37,1] = r(mean)*100		
			summ asiste [w=pondera]  if  edad>=18 & edad<=23 & ${comp_pob1}==0
			mat edu_${comp_pob1}_${comp_pob2}[37,2] = r(mean)*100	

			qui count if asiste <. & pondera <. & ${comp_pob1}==1 & edad>=18 & edad<=23
			loc n1=r(N)
			qui count if asiste <. & pondera <. & ${comp_pob1}==0 & edad>=18 & edad<=23
			loc n2=r(N)
			if `n1'>0 & `n2'>0 {
					   hotel_mio asiste [w=pondera] if edad>=18 & edad<=23, by(${comp_pob1})         
					   }
			mat edu_${comp_pob1}_${comp_pob2}[37,3] = edu_${comp_pob1}_${comp_pob2}[37,1] - edu_${comp_pob1}_${comp_pob2}[37,2]
			mat edu_${comp_pob1}_${comp_pob2}[37,4] = r(zeta) 


			*** VARIABLES LABORALES ***

			* PEA - Employment - Unemployment
			local variables "pea ocupado"

			local i=1
			foreach v of local variables {
				summ `v' [w=pondera]  if  ${comp_pob1}==1
				mat em1_${comp_pob1}_${comp_pob2}[`i',1] = r(mean)*100		
				summ `v' [w=pondera]  if  ${comp_pob1}==0
				mat em1_${comp_pob1}_${comp_pob2}[`i',2] = r(mean)*100	

				qui count if `v' <. & pondera <. & ${comp_pob1}==1
				loc n1=r(N)
				qui count if `v' <. & pondera <. & ${comp_pob1}==0
				loc n2=r(N)
				if `n1'>0 & `n2'>0 {
						   hotel_mio `v' [w=pondera], by(${comp_pob1})
						   }
				mat em1_${comp_pob1}_${comp_pob2}[`i',3] = em1_${comp_pob1}_${comp_pob2}[`i',1] - em1_${comp_pob1}_${comp_pob2}[`i',2]
				mat em1_${comp_pob1}_${comp_pob2}[`i',4] = r(zeta)

				summ `v' [w=pondera]  if  edad>=16 & edad<=24 & ${comp_pob1}==1
				mat em1_${comp_pob1}_${comp_pob2}[`i'+1,1] = r(mean)*100		
				summ `v' [w=pondera]  if  edad>=16 & edad<=24 & ${comp_pob1}==0
				mat em1_${comp_pob1}_${comp_pob2}[`i'+1,2] = r(mean)*100	

				qui count if `v' <. & pondera <. & ${comp_pob1}==1 & edad>=16 & edad<=24
				loc n1=r(N)
				qui count if `v' <. & pondera <. & ${comp_pob1}==0 & edad>=16 & edad<=24
				loc n2=r(N)
				if `n1'>0 & `n2'>0 {
						   hotel_mio `v' [w=pondera] if edad>=16 & edad<=24, by(${comp_pob1})
						   }
				mat em1_${comp_pob1}_${comp_pob2}[`i'+1,3] = em1_${comp_pob1}_${comp_pob2}[`i'+1,1] - em1_${comp_pob1}_${comp_pob2}[`i'+1,2]
				mat em1_${comp_pob1}_${comp_pob2}[`i'+1,4] = r(zeta)

				summ `v' [w=pondera]  if  edad>=25 & edad<=55 & ${comp_pob1}==1
				mat em1_${comp_pob1}_${comp_pob2}[`i'+2,1] = r(mean)*100		
				summ `v' [w=pondera]  if  edad>=25 & edad<=55 & ${comp_pob1}==0
				mat em1_${comp_pob1}_${comp_pob2}[`i'+2,2] = r(mean)*100

				qui count if `v' <. & pondera <. & ${comp_pob1}==1 & edad>=25 & edad<=55
				loc n1=r(N)
				qui count if `v' <. & pondera <. & ${comp_pob1}==0 & edad>=25 & edad<=55
				loc n2=r(N)
				if `n1'>0 & `n2'>0 {
						   hotel_mio `v' [w=pondera] if edad>=25 & edad<=55, by(${comp_pob1})
						   }
				mat em1_${comp_pob1}_${comp_pob2}[`i'+2,3] = em1_${comp_pob1}_${comp_pob2}[`i'+2,1] - em1_${comp_pob1}_${comp_pob2}[`i'+2,2]
				mat em1_${comp_pob1}_${comp_pob2}[`i'+2,4] = r(zeta)

				summ `v' [w=pondera]  if  edad>=56& edad<=100 & ${comp_pob1}==1
				mat em1_${comp_pob1}_${comp_pob2}[`i'+3,1] = r(mean)*100		 
				summ `v' [w=pondera]  if  edad>=56 & edad<=100 & ${comp_pob1}==0
				mat em1_${comp_pob1}_${comp_pob2}[`i'+3,2] = r(mean)*100

				qui count if `v' <. & pondera <. & ${comp_pob1}==1 & edad>=56 & edad<=100
				loc n1=r(N)
				qui count if `v' <. & pondera <. & ${comp_pob1}==0 & edad>=56 & edad<=100
				loc n2=r(N)
				if `n1'>0 & `n2'>0 {
						   hotel_mio `v' [w=pondera] if edad>=56 & edad<=100, by(${comp_pob1})
						   }
				mat em1_${comp_pob1}_${comp_pob2}[`i'+3,3] = em1_${comp_pob1}_${comp_pob2}[`i'+3,1] - em1_${comp_pob1}_${comp_pob2}[`i'+3,2]
				mat em1_${comp_pob1}_${comp_pob2}[`i'+3,4] = r(zeta)

				summ `v' [w=pondera]  if  edad>=25 & edad<=55 & hombre==1 & ${comp_pob1}==1
				mat em1_${comp_pob1}_${comp_pob2}[`i'+4,1] = r(mean)*100		 
				summ `v' [w=pondera]  if  edad>=25 & edad<=55 & hombre==1 & ${comp_pob1}==0
				mat em1_${comp_pob1}_${comp_pob2}[`i'+4,2] = r(mean)*100		 

				qui count if `v' <. & pondera <. & ${comp_pob1}==1 & edad>=25 & edad<=55 & hombre==1
				loc n1=r(N)
				qui count if `v' <. & pondera <. & ${comp_pob1}==0 & edad>=25 & edad<=55 & hombre==1
				loc n2=r(N)
				if `n1'>0 & `n2'>0 {
						   hotel_mio `v' [w=pondera] if edad>=25 & edad<=55 & hombre==1, by(${comp_pob1})
						   }
				mat em1_${comp_pob1}_${comp_pob2}[`i'+4,3] = em1_${comp_pob1}_${comp_pob2}[`i'+4,1] - em1_${comp_pob1}_${comp_pob2}[`i'+4,2]
				mat em1_${comp_pob1}_${comp_pob2}[`i'+4,4] = r(zeta)

				summ `v' [w=pondera]  if  edad>=25 & edad<=55 & hombre==0 & ${comp_pob1}==1
				mat em1_${comp_pob1}_${comp_pob2}[`i'+5,1] = r(mean)*100		 
				summ `v' [w=pondera]  if  edad>=25 & edad<=55 & hombre==0 & ${comp_pob1}==0
				mat em1_${comp_pob1}_${comp_pob2}[`i'+5,2] = r(mean)*100	

				qui count if `v' <. & pondera <. & ${comp_pob1}==1 & edad>=25 & edad<=55 & hombre==0
				loc n1=r(N)
				qui count if `v' <. & pondera <. & ${comp_pob1}==0 & edad>=25 & edad<=55 & hombre==0
				loc n2=r(N)
				if `n1'>0 & `n2'>0 {
						   hotel_mio `v' [w=pondera] if edad>=25 & edad<=55 & hombre==0, by(${comp_pob1})
						   }
				mat em1_${comp_pob1}_${comp_pob2}[`i'+5,3] = em1_${comp_pob1}_${comp_pob2}[`i'+5,1] - em1_${comp_pob1}_${comp_pob2}[`i'+5,2]
				mat em1_${comp_pob1}_${comp_pob2}[`i'+5,4] = r(zeta)

				local i=`i'+8
			}

			local i=17
			summ desocupa [w=pondera]  if  pea==1 & ${comp_pob1}==1
			mat em1_${comp_pob1}_${comp_pob2}[`i',1] = r(mean)*100		 
			summ desocupa [w=pondera]  if  pea==1 & ${comp_pob1}==0
			mat em1_${comp_pob1}_${comp_pob2}[`i',2] = r(mean)*100	

			count if desocupa!=.
			qui count if desocupa <. & pondera <. & ${comp_pob1}==1 & pea==1
			loc n1=r(N)
			qui count if desocupa <. & pondera <. & ${comp_pob1}==0 & pea==1
			loc n2=r(N)
			if `n1'>0 & `n2'>0 {
				hotel_mio desocupa [w=pondera] if pea==1, by(${comp_pob1})
			}
			mat em1_${comp_pob1}_${comp_pob2}[`i',3] = em1_${comp_pob1}_${comp_pob2}[`i',1] - em1_${comp_pob1}_${comp_pob2}[`i',2]
			mat em1_${comp_pob1}_${comp_pob2}[`i',4] = r(zeta)

			summ desocupa [w=pondera]  if  edad>=16 & edad<=24 & pea==1 & ${comp_pob1}==1
			mat em1_${comp_pob1}_${comp_pob2}[`i'+1,1] = r(mean)*100		 
			summ desocupa [w=pondera]  if  edad>=16 & edad<=24 & pea==1 & ${comp_pob1}==0
			mat em1_${comp_pob1}_${comp_pob2}[`i'+1,2] = r(mean)*100	

			count if desocupa!=.
			qui count if desocupa <. & pondera <. & ${comp_pob1}==1 & edad>=16 & edad<=24 & pea==1
			loc n1=r(N)
			qui count if desocupa <. & pondera <. & ${comp_pob1}==0 & edad>=16 & edad<=24 & pea==1
			loc n2=r(N)
			if `n1'>0 & `n2'>0 {
					   hotel_mio desocupa [w=pondera] if edad>=16 & edad<=24 & pea==1, by(${comp_pob1})
					   }
			mat em1_${comp_pob1}_${comp_pob2}[`i'+1,3] = em1_${comp_pob1}_${comp_pob2}[`i'+1,1] - em1_${comp_pob1}_${comp_pob2}[`i'+1,2]
			mat em1_${comp_pob1}_${comp_pob2}[`i'+1,4] = r(zeta)

			summ desocupa [w=pondera]  if  edad>=25 & edad<=55 & pea==1 & ${comp_pob1}==1
			mat em1_${comp_pob1}_${comp_pob2}[`i'+2,1] = r(mean)*100		 
			summ desocupa [w=pondera]  if  edad>=25 & edad<=55 & pea==1 & ${comp_pob1}==0
			mat em1_${comp_pob1}_${comp_pob2}[`i'+2,2] = r(mean)*100		

			qui count if desocupa <. & pondera <. & ${comp_pob1}==1 & edad>=25 & edad<=55 & pea==1
			loc n1=r(N)
			qui count if desocupa <. & pondera <. & ${comp_pob1}==0 & edad>=25 & edad<=55 & pea==1
			loc n2=r(N)
			if `n1'>0 & `n2'>0 {
					   hotel_mio desocupa [w=pondera] if edad>=25 & edad<=55 & pea==1, by(${comp_pob1})
					   }
			mat em1_${comp_pob1}_${comp_pob2}[`i'+2,3] = em1_${comp_pob1}_${comp_pob2}[`i'+2,1] - em1_${comp_pob1}_${comp_pob2}[`i'+2,2]
			mat em1_${comp_pob1}_${comp_pob2}[`i'+2,4] = r(zeta)

			summ desocupa [w=pondera]  if  edad>=56& edad<=100 & pea==1 & ${comp_pob1}==1
			mat em1_${comp_pob1}_${comp_pob2}[`i'+3,1] = r(mean)*100		 
			summ desocupa [w=pondera]  if  edad>=56 & edad<=100 & pea==1 & ${comp_pob1}==0
			mat em1_${comp_pob1}_${comp_pob2}[`i'+3,2] = r(mean)*100		 

			qui count if desocupa <. & pondera <. & ${comp_pob1}==1 & edad>=56 & edad<=100 & pea==1
			loc n1=r(N)
			qui count if desocupa <. & pondera <. & ${comp_pob1}==0 & edad>=56 & edad<=100 & pea==1
			loc n2=r(N)
			if `n1'>0 & `n2'>0 {
					   hotel_mio desocupa [w=pondera] if edad>=56 & edad<=100 & pea==1, by(${comp_pob1})
					   }
			mat em1_${comp_pob1}_${comp_pob2}[`i'+3,3] = em1_${comp_pob1}_${comp_pob2}[`i'+3,1] - em1_${comp_pob1}_${comp_pob2}[`i'+3,2]
			mat em1_${comp_pob1}_${comp_pob2}[`i'+3,4] = r(zeta)

			summ desocupa [w=pondera]  if  edad>=25 & edad<=55 & hombre==1 & pea==1 & ${comp_pob1}==1
			mat em1_${comp_pob1}_${comp_pob2}[`i'+4,1] = r(mean)*100		 
			summ desocupa [w=pondera]  if  edad>=25 & edad<=55 & hombre==1 & pea==1 & ${comp_pob1}==0
			mat em1_${comp_pob1}_${comp_pob2}[`i'+4,2] = r(mean)*100

			qui count if desocupa <. & pondera <. & ${comp_pob1}==1 & edad>=25 & edad<=55 & hombre==1 & pea==1
			loc n1=r(N)
			qui count if desocupa <. & pondera <. & ${comp_pob1}==0 & edad>=25 & edad<=55 & hombre==1 & pea==1
			loc n2=r(N)
			if `n1'>0 & `n2'>0 {
					   hotel_mio desocupa [w=pondera] if edad>=25 & edad<=55 & hombre==1 & pea==1, by(${comp_pob1})
					   }
			mat em1_${comp_pob1}_${comp_pob2}[`i'+4,3] = em1_${comp_pob1}_${comp_pob2}[`i'+4,1] - em1_${comp_pob1}_${comp_pob2}[`i'+4,2]
			mat em1_${comp_pob1}_${comp_pob2}[`i'+4,4] = r(zeta)

			summ desocupa [w=pondera]  if  edad>=25 & edad<=55 & hombre==0 & pea==1 & ${comp_pob1}==1
			mat em1_${comp_pob1}_${comp_pob2}[`i'+5,1] = r(mean)*100		 
			summ desocupa [w=pondera]  if  edad>=25 & edad<=55 & hombre==0 & pea==1 & ${comp_pob1}==0
			mat em1_${comp_pob1}_${comp_pob2}[`i'+5,2] = r(mean)*100	

			qui count if desocupa <. & pondera <. & ${comp_pob1}==1 & edad>=25 & edad<=55 & hombre==0 & pea==1
			loc n1=r(N)
			qui count if desocupa <. & pondera <. & ${comp_pob1}==0 & edad>=25 & edad<=55 & hombre==0 & pea==1
			loc n2=r(N)
			if `n1'>0 & `n2'>0 {
					   hotel_mio desocupa [w=pondera] if edad>=25 & edad<=55 & hombre==0 & pea==1, by(${comp_pob1})
					   }
			mat em1_${comp_pob1}_${comp_pob2}[`i'+5,3] = em1_${comp_pob1}_${comp_pob2}[`i'+5,1] - em1_${comp_pob1}_${comp_pob2}[`i'+5,2]
			mat em1_${comp_pob1}_${comp_pob2}[`i'+5,4] = r(zeta)

			* Unemployment Spell
			summ durades [w=pondera]  if   edad>=18 & edad<=65 & desocupa==1 & ${comp_pob1}==1
			mat em1_${comp_pob1}_${comp_pob2}[24,1] = r(mean)
			summ durades [w=pondera]  if  edad>=18 & edad<=65 & desocupa==1 & ${comp_pob1}==0
			mat em1_${comp_pob1}_${comp_pob2}[24,2] = r(mean)

			qui count if durades <. & pondera <. & ${comp_pob1}==1 & edad>=18 & edad<=65 & desocupa==1
			loc n1=r(N)
			qui count if durades <. & pondera <. & ${comp_pob1}==0 & edad>=18 & edad<=65 & desocupa==1
			loc n2=r(N)
			if `n1'>0 & `n2'>0 {
					   hotel_mio durades [w=pondera] if edad>=18 & edad<=65 & desocupa==1, by(${comp_pob1})
					   }
			mat em1_${comp_pob1}_${comp_pob2}[24,3] = em1_${comp_pob1}_${comp_pob2}[24,1] - em1_${comp_pob1}_${comp_pob2}[24,2]
			mat em1_${comp_pob1}_${comp_pob2}[24,4] = r(zeta)

			* Child Labor
			summ ocupado [w=pondera]  if  edad>=10 & edad<=14 & ${comp_pob1}==1
			mat em1_${comp_pob1}_${comp_pob2}[26,1] = r(mean)*100		 
			summ ocupado [w=pondera]  if  edad>=10 & edad<=14 & ${comp_pob1}==0
			mat em1_${comp_pob1}_${comp_pob2}[26,2] = r(mean)*100	

			qui count if ocupado <. & pondera <. & ${comp_pob1}==1 & edad>=10 & edad<=14
			loc n1=r(N)
			qui count if ocupado <. & pondera <. & ${comp_pob1}==0 & edad>=10 & edad<=14
			loc n2=r(N)
			if `n1'>0 & `n2'>0 {
					   hotel_mio ocupado [w=pondera] if edad>=10 & edad<=14, by(${comp_pob1})
					   }
			mat em1_${comp_pob1}_${comp_pob2}[26,3] = em1_${comp_pob1}_${comp_pob2}[26,1] - em1_${comp_pob1}_${comp_pob2}[26,2]
			mat em1_${comp_pob1}_${comp_pob2}[26,4] = r(zeta)


			* Worked Hours, Hourly Wages and Earnings
			local variables "hstrt wage ila"

			local i=1
			foreach v of local variables {
				summ `v' [w=pondera]  if  `v'>0 & ${comp_pob1}==1
				mat em2_${comp_pob1}_${comp_pob2}[`i',1] = r(mean)
				summ `v' [w=pondera]  if  `v'>0 & ${comp_pob1}==0
				mat em2_${comp_pob1}_${comp_pob2}[`i',2] = r(mean)

				qui count if `v' <. & pondera <. & ${comp_pob1}==1 
				loc n1=r(N)
				qui count if `v' <. & pondera <. & ${comp_pob1}==0 
				loc n2=r(N)
				if `n1'>0 & `n2'>0 {
					hotel_mio `v' [w=pondera] if `v'>0, by(${comp_pob1})
				}

				mat em2_${comp_pob1}_${comp_pob2}[`i',3] = em2_${comp_pob1}_${comp_pob2}[`i',1] - em2_${comp_pob1}_${comp_pob2}[`i',2]
				mat em2_${comp_pob1}_${comp_pob2}[`i',4] = r(zeta)

				summ `v' [w=pondera]  if  edad>=16 & edad<=24 & `v'>0 & ${comp_pob1}==1
				mat em2_${comp_pob1}_${comp_pob2}[`i'+1,1] = r(mean)
				summ `v' [w=pondera]  if  edad>=16 & edad<=24 & `v'>0 & ${comp_pob1}==0
				mat em2_${comp_pob1}_${comp_pob2}[`i'+1,2] = r(mean)

				qui count if `v' <. & pondera <. & ${comp_pob1}==1 & edad>=16 & edad<=24 & `v'>0
				loc n1=r(N)
				qui count if `v' <. & pondera <. & ${comp_pob1}==0 & edad>=16 & edad<=24 & `v'>0
				loc n2=r(N)
				if `n1'>0 & `n2'>0 {
						   hotel_mio `v' [w=pondera] if edad>=16 & edad<=24 & `v'>0, by(${comp_pob1})
						   }

				mat em2_${comp_pob1}_${comp_pob2}[`i'+1,3] = em2_${comp_pob1}_${comp_pob2}[`i'+1,1] - em2_${comp_pob1}_${comp_pob2}[`i'+1,2]
				mat em2_${comp_pob1}_${comp_pob2}[`i'+1,4] = r(zeta)

				summ `v' [w=pondera]  if  edad>=25 & edad<=55 & `v'>0 & ${comp_pob1}==1
				mat em2_${comp_pob1}_${comp_pob2}[`i'+2,1] = r(mean)
				summ `v' [w=pondera]  if  edad>=25 & edad<=55 & `v'>0 & ${comp_pob1}==0
				mat em2_${comp_pob1}_${comp_pob2}[`i'+2,2] = r(mean)

				qui count if `v' <. & pondera <. & ${comp_pob1}==1 & edad>=25 & edad<=55 & `v'>0
				loc n1=r(N)
				qui count if `v' <. & pondera <. & ${comp_pob1}==0 & edad>=25 & edad<=55 & `v'>0
				loc n2=r(N)
				if `n1'>0 & `n2'>0 {
						   hotel_mio `v' [w=pondera] if edad>=25 & edad<=55 & `v'>0, by(${comp_pob1})
						   }

				mat em2_${comp_pob1}_${comp_pob2}[`i'+2,3] = em2_${comp_pob1}_${comp_pob2}[`i'+2,1] - em2_${comp_pob1}_${comp_pob2}[`i'+2,2]
				mat em2_${comp_pob1}_${comp_pob2}[`i'+2,4] = r(zeta)

				summ `v' [w=pondera]  if  edad>=56 & edad<=100 & `v'>0 & ${comp_pob1}==1
				mat em2_${comp_pob1}_${comp_pob2}[`i'+3,1] = r(mean)
				summ `v' [w=pondera]  if  edad>=56 & edad<=100 & `v'>0 & ${comp_pob1}==0
				mat em2_${comp_pob1}_${comp_pob2}[`i'+3,2] = r(mean)

				qui count if `v' <. & pondera <. & ${comp_pob1}==1 & edad>=56 & edad<=100 & `v'>0
				loc n1=r(N)
				qui count if `v' <. & pondera <. & ${comp_pob1}==0 & edad>=56 & edad<=100 & `v'>0
				loc n2=r(N)
				if `n1'>0 & `n2'>0 {
						   hotel_mio `v' [w=pondera] if edad>=56 & edad<=100 & `v'>0, by(${comp_pob1})
						   }

				mat em2_${comp_pob1}_${comp_pob2}[`i'+3,3] = em2_${comp_pob1}_${comp_pob2}[`i'+3,1] - em2_${comp_pob1}_${comp_pob2}[`i'+3,2]
				mat em2_${comp_pob1}_${comp_pob2}[`i'+3,4] = r(zeta)

				summ `v' [w=pondera]  if  edad>=25 & edad<=55 & hombre==1 & `v'>0 & ${comp_pob1}==1
				mat em2_${comp_pob1}_${comp_pob2}[`i'+4,1] = r(mean)
				summ `v' [w=pondera]  if  edad>=25 & edad<=55 & hombre==1 & `v'>0 & ${comp_pob1}==0
				mat em2_${comp_pob1}_${comp_pob2}[`i'+4,2] = r(mean)

				qui count if `v' <. & pondera <. & ${comp_pob1}==1 & edad>=25 & edad<=55 & hombre==1 & `v'>0
				loc n1=r(N)
				qui count if `v' <. & pondera <. & ${comp_pob1}==0 & edad>=25 & edad<=55 & hombre==1 & `v'>0
				loc n2=r(N)
				if `n1'>0 & `n2'>0 {
						   hotel_mio `v' [w=pondera] if edad>=25 & edad<=55 & hombre==1 & `v'>0, by(${comp_pob1})
						   }

				mat em2_${comp_pob1}_${comp_pob2}[`i'+4,3] = em2_${comp_pob1}_${comp_pob2}[`i'+4,1] - em2_${comp_pob1}_${comp_pob2}[`i'+4,2]
				mat em2_${comp_pob1}_${comp_pob2}[`i'+4,4] = r(zeta)

				summ `v' [w=pondera]  if  edad>=25 & edad<=55 & hombre==0 & `v'>0 & ${comp_pob1}==1
				mat em2_${comp_pob1}_${comp_pob2}[`i'+5,1] = r(mean)
				summ `v' [w=pondera]  if  edad>=25 & edad<=55 & hombre==0 & `v'>0 & ${comp_pob1}==0
				mat em2_${comp_pob1}_${comp_pob2}[`i'+5,2] = r(mean)

				qui count if `v' <. & pondera <. & ${comp_pob1}==1 & edad>=25 & edad<=55 & hombre==0 & `v'>0
				loc n1=r(N)
				qui count if `v' <. & pondera <. & ${comp_pob1}==0 & edad>=25 & edad<=55 & hombre==0 & `v'>0
				loc n2=r(N)
				if `n1'>0 & `n2'>0 {
						   hotel_mio `v' [w=pondera] if edad>=25 & edad<=55 & hombre==0 & `v'>0, by(${comp_pob1})
						   }

				mat em2_${comp_pob1}_${comp_pob2}[`i'+5,3] = em2_${comp_pob1}_${comp_pob2}[`i'+5,1] - em2_${comp_pob1}_${comp_pob2}[`i'+5,2]
				mat em2_${comp_pob1}_${comp_pob2}[`i'+5,4] = r(zeta)

				local i=`i'+8
			}

			* Labor Relationship 
			tab relab ${comp_pob1} [w=pondera], matcell(aux)

			local i=1
			local sum_no_pob=0
			forvalues i=1/5 {
					local sum_no_pob = `sum_no_pob' + aux[`i',1]
					local i=`i'+1
					}
			local i=1
			local sum_pob=0
			forvalues i=1/5 {
					local sum_pob = `sum_pob' + aux[`i',2]
					local i=`i'+1
					}

			forvalues i=1/5 {
					mat em3_${comp_pob1}_${comp_pob2}[`i',1] = aux[`i',2]/`sum_pob'*100
					mat em3_${comp_pob1}_${comp_pob2}[`i',2] = aux[`i',1]/`sum_no_pob'*100
					}

			mat em3_${comp_pob1}_${comp_pob2}[6,1] = em3_${comp_pob1}_${comp_pob2}[1,1] + em3_${comp_pob1}_${comp_pob2}[2,1] + em3_${comp_pob1}_${comp_pob2}[3,1] + em3_${comp_pob1}_${comp_pob2}[4,1] + em3_${comp_pob1}_${comp_pob2}[5,1]
			mat em3_${comp_pob1}_${comp_pob2}[6,2] = em3_${comp_pob1}_${comp_pob2}[1,2] + em3_${comp_pob1}_${comp_pob2}[2,2] + em3_${comp_pob1}_${comp_pob2}[3,2] + em3_${comp_pob1}_${comp_pob2}[4,2] + em3_${comp_pob1}_${comp_pob2}[5,2]

			count if relab!=.
			if r(N)>0 {
				qui tab relab, g(auxrelab)
				forvalues i=1/5	{
					qui count if auxrelab`i' <. & pondera <. & ${comp_pob1}==1 
					loc n1=r(N)
					qui count if auxrelab`i' <. & pondera <. & ${comp_pob1}==0 
					loc n2=r(N)
					if `n1'>0 & `n2'>0 {
							   hotel_mio auxrelab`i' [w=pondera], by(${comp_pob1})
							   mat em3_${comp_pob1}_${comp_pob2}[`i',3] = em3_${comp_pob1}_${comp_pob2}[`i',1] - em3_${comp_pob1}_${comp_pob2}[`i',2]
							   mat em3_${comp_pob1}_${comp_pob2}[`i',4] = r(zeta)
							   }
						 }
				 drop auxrelab*
			}

			* Labor Group
			sum grupo_lab if ${comp_pob1}==0 [w=pondera]
			local sum_no_pob=r(sum_w)

			sum grupo_lab if ${comp_pob1}==1 [w=pondera]
			local sum_pob=r(sum_w)

			forvalues i=1/7 {
					sum grupo_lab if grupo_lab==`i' & ${comp_pob1}==1 [w=pondera]
					mat em3_${comp_pob1}_${comp_pob2}[`i'+8,1] = r(sum_w) / `sum_pob'    * 100
					sum grupo_lab if grupo_lab==`i' & ${comp_pob1}==0 [w=pondera]
					mat em3_${comp_pob1}_${comp_pob2}[`i'+8,2] = r(sum_w) / `sum_no_pob' * 100
			}

			mat em3_${comp_pob1}_${comp_pob2}[16,1] = em3_${comp_pob1}_${comp_pob2}[9,1] + em3_${comp_pob1}_${comp_pob2}[10,1] + em3_${comp_pob1}_${comp_pob2}[11,1] + em3_${comp_pob1}_${comp_pob2}[12,1] + em3_${comp_pob1}_${comp_pob2}[13,1] + em3_${comp_pob1}_${comp_pob2}[14,1] + em3_${comp_pob1}_${comp_pob2}[15,1]
			mat em3_${comp_pob1}_${comp_pob2}[16,2] = em3_${comp_pob1}_${comp_pob2}[9,2] + em3_${comp_pob1}_${comp_pob2}[10,2] + em3_${comp_pob1}_${comp_pob2}[11,2] + em3_${comp_pob1}_${comp_pob2}[12,2] + em3_${comp_pob1}_${comp_pob2}[13,2] + em3_${comp_pob1}_${comp_pob2}[14,2] + em3_${comp_pob1}_${comp_pob2}[15,2]

			count if grupo_lab!=.
			if r(N)>0 {

			forvalues i=1/7	{
			gen auxgrupo_lab`i'=.
			replace auxgrupo_lab`i'=1 if grupo_lab==`i'
			replace auxgrupo_lab`i'=0 if grupo_lab!=`i' & grupo_lab!=.
			summ auxgrupo_lab`i'
			replace auxgrupo_lab`i'=. if r(mean)==0
					}
				
				forvalues i=1/7	{
					qui count if auxgrupo_lab`i' <. & pondera <. & ${comp_pob1}==1 
					loc n1=r(N)
					qui count if auxgrupo_lab`i' <. & pondera <. & ${comp_pob1}==0 
					loc n2=r(N)
					if `n1'>0 & `n2'>0 {
							   hotel_mio auxgrupo_lab`i' [w=pondera], by(${comp_pob1})
							   mat em3_${comp_pob1}_${comp_pob2}[`i'+8,3] = em3_${comp_pob1}_${comp_pob2}[`i'+8,1] - em3_${comp_pob1}_${comp_pob2}[`i'+8,2]
							   mat em3_${comp_pob1}_${comp_pob2}[`i'+8,4] = r(zeta)
							   }
						}
				drop auxgrupo_lab*
			}

			count if ${comp_pob1}!=.
			if r(N)>0 {

				* Informality (Based on Labor Group)
				tab categ_lab ${comp_pob1} [w=pondera], matcell(aux)

				count if categ_lab!=.
				if r(N)>0 {

					local i=1
					local sum_no_pob=0
					forvalues i=1/2 {
						local sum_no_pob = `sum_no_pob' + aux[`i',1]
						local i=`i'+1
					}
					local i=1
					local sum_pob=0
					forvalues i=1/2 {
						local sum_pob = `sum_pob' + aux[`i',2]
						local i=`i'+1
					}

					forvalues i=1/2 {
						mat em3_${comp_pob1}_${comp_pob2}[`i'+18,1] = aux[`i',2] / `sum_pob'    * 100
						mat em3_${comp_pob1}_${comp_pob2}[`i'+18,2] = aux[`i',1] / `sum_no_pob' * 100
					}

					mat em3_${comp_pob1}_${comp_pob2}[21,1] = em3_${comp_pob1}_${comp_pob2}[19,1] + em3_${comp_pob1}_${comp_pob2}[20,1]
					mat em3_${comp_pob1}_${comp_pob2}[21,2] = em3_${comp_pob1}_${comp_pob2}[19,2] + em3_${comp_pob1}_${comp_pob2}[20,2]

					qui ta categ_lab, g(auxcateg_lab)
					forvalues i=1/2 {
						qui count if auxcateg_lab`i' <. & pondera <. & ${comp_pob1}==1 
						loc n1=r(N)
						qui count if auxcateg_lab`i' <. & pondera <. & ${comp_pob1}==0 
						loc n2=r(N)
						if `n1'>0 & `n2'>0 {
							hotel_mio auxcateg_lab`i' [w=pondera], by(${comp_pob1})
							mat em3_${comp_pob1}_${comp_pob2}[`i'+18,3] = em3_${comp_pob1}_${comp_pob2}[`i'+18,1] - em3_${comp_pob1}_${comp_pob2}[`i'+18,2]
							mat em3_${comp_pob1}_${comp_pob2}[`i'+18,4] = r(zeta)
						}
					}
					drop auxcateg_lab*
				}

				* Informality (Based on Social Security Rights)
				tab inf_jubi ${comp_pob1} [w=pondera], matcell(aux)

				count if inf_jubi!=.
				if r(N)>0 {

					local i=1
					local sum_no_pob=0
					forvalues i=1/2 {
							local sum_no_pob = `sum_no_pob' + aux[`i',1]
							local i=`i'+1
							}
					local i=1
					local sum_pob=0
					forvalues i=1/2 {
							local sum_pob = `sum_pob' + aux[`i',2]
							local i=`i'+1
							}

					forvalues i=1/2 {
							mat em3_${comp_pob1}_${comp_pob2}[`i'+23,1] = aux[`i',2] / `sum_pob'    * 100
							mat em3_${comp_pob1}_${comp_pob2}[`i'+23,2] = aux[`i',1] / `sum_no_pob' * 100
							}

					mat em3_${comp_pob1}_${comp_pob2}[26,1] = em3_${comp_pob1}_${comp_pob2}[24,1] + em3_${comp_pob1}_${comp_pob2}[25,1]
					mat em3_${comp_pob1}_${comp_pob2}[26,2] = em3_${comp_pob1}_${comp_pob2}[24,2] + em3_${comp_pob1}_${comp_pob2}[25,2]

						  qui tab inf_jubi, g(auxinf_jubi)
						  forvalues i=1/2 {
							qui count if auxinf_jubi`i' <. & pondera <. & ${comp_pob1}==1 
							loc n1=r(N)
							qui count if auxinf_jubi`i' <. & pondera <. & ${comp_pob1}==0 
							loc n2=r(N)
							if `n1'>0 & `n2'>0 {
									   hotel_mio auxinf_jubi`i' [w=pondera], by(${comp_pob1})
									   mat em3_${comp_pob1}_${comp_pob2}[`i'+23,3] = em3_${comp_pob1}_${comp_pob2}[`i'+23,1] - em3_${comp_pob1}_${comp_pob2}[`i'+23,2]
									   mat em3_${comp_pob1}_${comp_pob2}[`i'+23,4] = r(zeta)
									   }
								 }
					  drop auxinf_jubi*
				  }
			}
			*
			* Sectors
			tab sector ${comp_pob1} [w=pondera], matcell(aux)

			local i=1
			local sum_no_pob=0
			forvalues i=1/10 {
				local sum_no_pob = `sum_no_pob' + aux[`i',1]
				local i=`i'+1
			}
			local i=1
			local sum_pob=0
			forvalues i=1/10 {
				local sum_pob = `sum_pob' + aux[`i',2]
				local i=`i'+1
			}

			forvalues i=1/10 {
				mat em3_${comp_pob1}_${comp_pob2}[`i'+28,1] = aux[`i',2] / `sum_pob'    * 100
				mat em3_${comp_pob1}_${comp_pob2}[`i'+28,2] = aux[`i',1] / `sum_no_pob' * 100
			}

			mat em3_${comp_pob1}_${comp_pob2}[39,1] = em3_${comp_pob1}_${comp_pob2}[29,1] + em3_${comp_pob1}_${comp_pob2}[30,1] + em3_${comp_pob1}_${comp_pob2}[31,1] + em3_${comp_pob1}_${comp_pob2}[32,1] + em3_${comp_pob1}_${comp_pob2}[33,1] + em3_${comp_pob1}_${comp_pob2}[34,1] + em3_${comp_pob1}_${comp_pob2}[35,1] + em3_${comp_pob1}_${comp_pob2}[36,1] + em3_${comp_pob1}_${comp_pob2}[37,1] + em3_${comp_pob1}_${comp_pob2}[38,1]
			mat em3_${comp_pob1}_${comp_pob2}[39,2] = em3_${comp_pob1}_${comp_pob2}[29,2] + em3_${comp_pob1}_${comp_pob2}[30,2] + em3_${comp_pob1}_${comp_pob2}[31,2] + em3_${comp_pob1}_${comp_pob2}[32,2] + em3_${comp_pob1}_${comp_pob2}[33,2] + em3_${comp_pob1}_${comp_pob2}[34,2] + em3_${comp_pob1}_${comp_pob2}[35,2] + em3_${comp_pob1}_${comp_pob2}[36,2] + em3_${comp_pob1}_${comp_pob2}[37,2] + em3_${comp_pob1}_${comp_pob2}[38,2]

			count if sector!=.
			if r(N)>0 {
				qui ta sector, g(auxsector)
				forvalues i=1/10 {
					qui count if auxsector`i' <. & pondera <. & ${comp_pob1}==1 
					loc n1=r(N)
					qui count if auxsector`i' <. & pondera <. & ${comp_pob1}==0 
					loc n2=r(N)
					if `n1'>0 & `n2'>0 {
						hotel_mio auxsector`i' [w=pondera], by(${comp_pob1})
						mat em3_${comp_pob1}_${comp_pob2}[`i'+28,3] = em3_${comp_pob1}_${comp_pob2}[`i'+28,1] - em3_${comp_pob1}_${comp_pob2}[`i'+28,2]
						mat em3_${comp_pob1}_${comp_pob2}[`i'+28,4] = r(zeta)
					}
				}
				drop auxsector*
			}

			* Labor Benefits
			local var "contrato ocuperma djubila dsegsale sindicato"

			local i=41
			foreach v of local var { 
				summ `v' [w=pondera]  if  edad>=18 & edad<=65 & ocupado==1 & relab==2 & ${comp_pob1}==1
				mat em3_${comp_pob1}_${comp_pob2}[`i',1] = r(mean)*100		 
				summ `v' [w=pondera]  if  edad>=18 & edad<=65 & ocupado==1 & relab==2 & ${comp_pob1}==0
				mat em3_${comp_pob1}_${comp_pob2}[`i',2] = r(mean)*100		 
				
				qui count if `v' <. & pondera <. & ${comp_pob1}==1 & edad>=18 & edad<=65 & ocupado==1 & relab==2
				loc n1=r(N)
				qui count if `v' <. & pondera <. & ${comp_pob1}==0 & edad>=18 & edad<=65 & ocupado==1 & relab==2
				loc n2=r(N)
				if `n1'>0 & `n2'>0 {
						   hotel_mio `v' [w=pondera] if edad>=18 & edad<=65 & ocupado==1 & relab==2, by(${comp_pob1})
						   mat em3_${comp_pob1}_${comp_pob2}[`i',3] = em3_${comp_pob1}_${comp_pob2}[`i',1] - em3_${comp_pob1}_${comp_pob2}[`i',2]
						   mat em3_${comp_pob1}_${comp_pob2}[`i',4] = r(zeta)
						   }
				local i=`i'+2
			}
		}

		*** ASISTENCIA SOCIAL ***
		summ asist_hog [w=pondera]  if  hogar==1 & ${comp_pob1}==1
		mat pap_${comp_pob1}_${comp_pob2}[1,1] = r(mean)*100		 
		summ asist_hog [w=pondera]  if  hogar==1 & ${comp_pob1}==0
		mat pap_${comp_pob1}_${comp_pob2}[1,2] = r(mean)*100

		qui count if asist_hog <. & pondera <. & ${comp_pob1}==1 & hogar==1
		loc n1=r(N)
		qui count if asist_hog <. & pondera <. & ${comp_pob1}==0 & hogar==1
		loc n2=r(N)
		if `n1'>0 & `n2'>0 {
				   hotel_mio asist_hog [w=pondera] if hogar==1, by(${comp_pob1})
				   mat pap_${comp_pob1}_${comp_pob2}[1,3] =  pap_${comp_pob1}_${comp_pob2}[1,1] - pap_${comp_pob1}_${comp_pob2}[1,2]
				   mat pap_${comp_pob1}_${comp_pob2}[1,4] = r(zeta)
		}

		summ iasis [w=pondera]  if  jefe==1 & ${comp_pob1}==1
		mat pap_${comp_pob1}_${comp_pob2}[3,1] = r(mean)
		summ iasis [w=pondera]  if  jefe==1 & ${comp_pob1}==0
		mat pap_${comp_pob1}_${comp_pob2}[3,2] = r(mean)

		qui count if iasis <. & pondera <. & ${comp_pob1}==1 & jefe==1
		loc n1=r(N)
		qui count if iasis <. & pondera <. & ${comp_pob1}==0 & jefe==1
		loc n2=r(N)
		if `n1'>0 & `n2'>0 {
			hotel_mio iasis [w=pondera] if jefe==1, by(${comp_pob1})
			mat pap_${comp_pob1}_${comp_pob2}[3,3] =  pap_${comp_pob1}_${comp_pob2}[3,1] - pap_${comp_pob1}_${comp_pob2}[3,2]
			mat pap_${comp_pob1}_${comp_pob2}[3,4] = r(zeta)
		}

		count if ${comp_pob1}!=.
		if r(N)>0 {
			  shares_group asist_hog [w=pondera]  if  ${comp_pob1}>=0 & ${comp_pob1}<=1, by(${comp_pob1})
			  mat pap_${comp_pob1}_${comp_pob2}[6,1] = r(${comp_pob1}_1)
			  mat pap_${comp_pob1}_${comp_pob2}[6,2] = r(${comp_pob1}_0)

			  shares_group iasis [w=pondera]  if  ${comp_pob1}>=0 & ${comp_pob1}<=1, by(${comp_pob1})
			  mat pap_${comp_pob1}_${comp_pob2}[7,1] = r(${comp_pob1}_1)
			  mat pap_${comp_pob1}_${comp_pob2}[7,2] = r(${comp_pob1}_0)
		}

		*** INGRESOS ***

		* Per Capita Income
		summ ipcf [w=pondera]  if  cohh==1 & ${comp_pob1}==1
		mat ing_${comp_pob1}_${comp_pob2}[1,1] = r(mean)
		summ ipcf [w=pondera]  if  cohh==1 & ${comp_pob1}==0
		mat ing_${comp_pob1}_${comp_pob2}[1,2] = r(mean)

		qui count if ipcf <. & pondera <. & ${comp_pob1}==1 & cohh==1
		loc n1=r(N)
		qui count if ipcf <. & pondera <. & ${comp_pob1}==0 & cohh==1
		loc n2=r(N)
		if `n1'>0 & `n2'>0 {
				   hotel_mio ipcf [w=pondera] if cohh==1, by(${comp_pob1})
				   mat ing_${comp_pob1}_${comp_pob2}[1,3] = ing_${comp_pob1}_${comp_pob2}[1,1] - ing_${comp_pob1}_${comp_pob2}[1,2]
				   mat ing_${comp_pob1}_${comp_pob2}[1,4] = r(zeta)
		}

		* Household Income
		summ itf [w=pondera]  if  cohh==1 & hogar==1 & ${comp_pob1}==1
		mat ing_${comp_pob1}_${comp_pob2}[2,1] = r(mean)
		summ itf [w=pondera]  if  cohh==1 & hogar==1 & ${comp_pob1}==0
		mat ing_${comp_pob1}_${comp_pob2}[2,2] = r(mean)

		hotel_mio itf [w=pondera]  if  cohh==1 & hogar==1, by(${comp_pob1})
		mat ing_${comp_pob1}_${comp_pob2}[2,3] = ing_${comp_pob1}_${comp_pob2}[2,1] - ing_${comp_pob1}_${comp_pob2}[2,2]
		mat ing_${comp_pob1}_${comp_pob2}[2,4] = r(zeta)

		* Inequality
		gini ipcf [w=pondera]  if  ipcf>0 & cohh==1 & ${comp_pob1}==1
		mat ing_${comp_pob1}_${comp_pob2}[4,1] = r(gini)
		gini ipcf [w=pondera]  if  ipcf>0 & cohh==1 & ${comp_pob1}==0
		mat ing_${comp_pob1}_${comp_pob2}[4,2] = r(gini)
		if `rep' >= 50	{
				diff_gini ipcf [w=pondera]  if  ipcf>0 & cohh==1, by(${comp_pob1}) reps(`rep')
				mat ing_${comp_pob1}_${comp_pob2}[4,3] = ing_${comp_pob1}_${comp_pob2}[4,1] - ing_${comp_pob1}_${comp_pob2}[4,2]
				mat ing_${comp_pob1}_${comp_pob2}[4,4] = r(vp)
		}

		count if ${comp_pob1}!=.
		if r(N)>0 {

			* Income Shares 
			shares ila inla  if  cohi==1 & ${comp_pob1}==1 [w=pondera], variable_total(ii)
			mat ing_${comp_pob1}_${comp_pob2}[7,1] = r(shr_ila)
			mat ing_${comp_pob1}_${comp_pob2}[8,1] = r(shr_inla)
			mat ing_${comp_pob1}_${comp_pob2}[9,1] = r(shr_ila) + r(shr_inla)

			shares ila inla  if  cohi==1 & ${comp_pob1}==0 [w=pondera], variable_total(ii)
			mat ing_${comp_pob1}_${comp_pob2}[7,2] = r(shr_ila)
			mat ing_${comp_pob1}_${comp_pob2}[8,2] = r(shr_inla)
			mat ing_${comp_pob1}_${comp_pob2}[9,2] = r(shr_ila) + r(shr_inla)

			if `rep'>=50 {
				     diff_shares ila inla if cohi==1 [w=pondera], vt(ii) by(${comp_pob1}) reps(`rep')
				     mat vp = e(vp)
				     mat ing_${comp_pob1}_${comp_pob2}[7,3] = ing_${comp_pob1}_${comp_pob2}[7,1] - ing_${comp_pob1}_${comp_pob2}[7,2]
				     mat ing_${comp_pob1}_${comp_pob2}[8,3] = ing_${comp_pob1}_${comp_pob2}[8,1] - ing_${comp_pob1}_${comp_pob2}[8,2]
				     mat ing_${comp_pob1}_${comp_pob2}[7,4] = vp[1,1]
				     mat ing_${comp_pob1}_${comp_pob2}[8,4] = vp[2,1]
				     }

			* Share de ingresos laborales
			shares iasal ictap ipatr iol if cohi==1 & ${comp_pob1}==1 [w=pondera], variable_total(ila)
			mat ing_${comp_pob1}_${comp_pob2}[12,1] = r(shr_iasal)
			mat ing_${comp_pob1}_${comp_pob2}[13,1] = r(shr_ictap)
			mat ing_${comp_pob1}_${comp_pob2}[14,1] = r(shr_ipatr)
			mat ing_${comp_pob1}_${comp_pob2}[15,1] = r(shr_iol)
			mat ing_${comp_pob1}_${comp_pob2}[16,1] = r(shr_iasal) + r(shr_ictap) + r(shr_ipatr) + r(shr_iol)

			shares iasal ictap ipatr iol if cohi==1 & ${comp_pob1}==0 [w=pondera], variable_total(ila)
			mat ing_${comp_pob1}_${comp_pob2}[12,2] = r(shr_iasal)
			mat ing_${comp_pob1}_${comp_pob2}[13,2] = r(shr_ictap)
			mat ing_${comp_pob1}_${comp_pob2}[14,2] = r(shr_ipatr)
			mat ing_${comp_pob1}_${comp_pob2}[15,2] = r(shr_iol)
			mat ing_${comp_pob1}_${comp_pob2}[16,2] = r(shr_iasal) + r(shr_ictap) + r(shr_ipatr) + r(shr_iol)

			if `rep'>=50 {
				     diff_shares iasal ictap ipatr iol if cohi==1 [w=pondera], vt(ila) by(${comp_pob1}) reps(`rep')
				     mat vp = e(vp)
				     mat ing_${comp_pob1}_${comp_pob2}[12,3] = ing_${comp_pob1}_${comp_pob2}[12,1] - ing_${comp_pob1}_${comp_pob2}[12,2]
				     mat ing_${comp_pob1}_${comp_pob2}[13,3] = ing_${comp_pob1}_${comp_pob2}[13,1] - ing_${comp_pob1}_${comp_pob2}[13,2]
				     mat ing_${comp_pob1}_${comp_pob2}[14,3] = ing_${comp_pob1}_${comp_pob2}[14,1] - ing_${comp_pob1}_${comp_pob2}[14,2]
				     mat ing_${comp_pob1}_${comp_pob2}[15,3] = ing_${comp_pob1}_${comp_pob2}[15,1] - ing_${comp_pob1}_${comp_pob2}[15,2]
				     mat ing_${comp_pob1}_${comp_pob2}[12,4] = vp[1,1]
				     mat ing_${comp_pob1}_${comp_pob2}[13,4] = vp[2,1]
				     mat ing_${comp_pob1}_${comp_pob2}[14,4] = vp[3,1]
				     mat ing_${comp_pob1}_${comp_pob2}[15,4] = vp[4,1]
			}

			* Share de ingresos 
			shares icap ijubi itran ionl if cohi==1 & ${comp_pob1}==1 [w=pondera], variable_total(inla)
			mat ing_${comp_pob1}_${comp_pob2}[19,1] = r(shr_icap)
			mat ing_${comp_pob1}_${comp_pob2}[20,1] = r(shr_ijubi)
			mat ing_${comp_pob1}_${comp_pob2}[21,1] = r(shr_itran)
			mat ing_${comp_pob1}_${comp_pob2}[22,1] = r(shr_ionl)
			mat ing_${comp_pob1}_${comp_pob2}[23,1] = r(shr_icap) + r(shr_ijubi) + r(shr_itran) + r(shr_ionl)

			shares icap ijubi itran ionl if cohi==1 & ${comp_pob1}==0 [w=pondera], variable_total(inla)
			mat ing_${comp_pob1}_${comp_pob2}[19,2] = r(shr_icap)
			mat ing_${comp_pob1}_${comp_pob2}[20,2] = r(shr_ijubi)
			mat ing_${comp_pob1}_${comp_pob2}[21,2] = r(shr_itran)
			mat ing_${comp_pob1}_${comp_pob2}[22,2] = r(shr_ionl)
			mat ing_${comp_pob1}_${comp_pob2}[23,2] = r(shr_icap) + r(shr_ijubi) + r(shr_itran) + r(shr_ionl)

			if `rep'>=50 {
				     diff_shares icap ijubi itran ionl if cohi==1 [w=pondera], vt(inla) by(${comp_pob1}) reps(`rep')
				     mat vp = e(vp)
				     mat ing_${comp_pob1}_${comp_pob2}[19,3] = ing_${comp_pob1}_${comp_pob2}[19,1] - ing_${comp_pob1}_${comp_pob2}[19,2]
				     mat ing_${comp_pob1}_${comp_pob2}[20,3] = ing_${comp_pob1}_${comp_pob2}[20,1] - ing_${comp_pob1}_${comp_pob2}[20,2]
				     mat ing_${comp_pob1}_${comp_pob2}[21,3] = ing_${comp_pob1}_${comp_pob2}[21,1] - ing_${comp_pob1}_${comp_pob2}[21,2]
				     mat ing_${comp_pob1}_${comp_pob2}[22,3] = ing_${comp_pob1}_${comp_pob2}[22,1] - ing_${comp_pob1}_${comp_pob2}[22,2]
				     mat ing_${comp_pob1}_${comp_pob2}[19,4] = vp[1,1]	 		     
				     mat ing_${comp_pob1}_${comp_pob2}[20,4] = vp[2,1]
				     mat ing_${comp_pob1}_${comp_pob2}[21,4] = vp[3,1]
				     mat ing_${comp_pob1}_${comp_pob2}[22,4] = vp[4,1]
			}		     
		}

		**** DESCOMPOSICION ************
		summ ipcf [w=pondera]  if  cohh==1 & ${comp_pob1}==1
		mat des_${comp_pob1}_${comp_pob2}[1,1] = r(mean)
		summ ipcf [w=pondera]  if  cohh==1 & ${comp_pob1}==0
		mat des_${comp_pob1}_${comp_pob2}[1,2] = r(mean)

		summ itf [w=pondera]  if  cohh==1 & hogar==1 & ${comp_pob1}==1
		mat des_${comp_pob1}_${comp_pob2}[3,1] = r(mean)
		summ itf [w=pondera]  if  cohh==1 & hogar==1 & ${comp_pob1}==0
		mat des_${comp_pob1}_${comp_pob2}[3,2] = r(mean)

		summ miembros [w=pondera]  if  cohh==1 & hogar==1 & ${comp_pob1}==1
		mat des_${comp_pob1}_${comp_pob2}[5,1] = r(mean)
		summ miembros [w=pondera]  if  cohh==1 & hogar==1 & ${comp_pob1}==0
		mat des_${comp_pob1}_${comp_pob2}[5,2] = r(mean)

		summ ila [w=pondera]  if  cohh==1 & ila>0 & hogarsec==0 & ${comp_pob1}==1
		mat des_${comp_pob1}_${comp_pob2}[7,1] = r(mean)
		summ ila [w=pondera]  if  cohh==1 & ila>0 & hogarsec==0 & ${comp_pob1}==0
		mat des_${comp_pob1}_${comp_pob2}[7,2] = r(mean)

		summ n_perila_h [w=pondera]  if  cohh==1 & hogar==1 & ${comp_pob1}==1
		mat des_${comp_pob1}_${comp_pob2}[9,1] = r(mean)
		summ n_perila_h [w=pondera]  if  cohh==1 & hogar==1 & ${comp_pob1}==0
		mat des_${comp_pob1}_${comp_pob2}[9,2] = r(mean)

		summ inlaf [w=pondera]  if  cohh==1 & hogar==1 & ${comp_pob1}==1
		mat des_${comp_pob1}_${comp_pob2}[11,1] = r(mean)
		summ inlaf [w=pondera]  if  cohh==1 & hogar==1 & ${comp_pob1}==0
		mat des_${comp_pob1}_${comp_pob2}[11,2] = r(mean)


		**** NBI ************
		sum nbi [w=pondera]  if  urbano==1 & ${comp_pob1}==1
		mat nbi_${comp_pob1}_${comp_pob2}[1,1] = r(mean)*100
		sum nbi [w=pondera]  if  urbano==1 & ${comp_pob1}==0
		mat nbi_${comp_pob1}_${comp_pob2}[1,2] = r(mean)*100 

		tab nbi_${comp_pob1}_${comp_pob2} [w=pondera]  if  urbano==1, matcell(aux)
		mat nbi_${comp_pob1}_${comp_pob2}[2,1] = (aux[2,1] / (aux[1,1] + aux[2,1])) * 100	
		mat nbi_${comp_pob1}_${comp_pob2}[2,2] = (aux[1,1] / (aux[1,1] + aux[2,1])) * 100		 

		sum nbi [w=pondera] if ${comp_pob1}==1 
		mat nbi_${comp_pob1}_${comp_pob2}[5,1] = r(mean)*100
		sum nbi [w=pondera] if ${comp_pob1}==0
		mat nbi_${comp_pob1}_${comp_pob2}[5,2] = r(mean)*100		 

		tab nbi_${comp_pob1}_${comp_pob2} [w=pondera], matcell(aux)
		mat nbi_${comp_pob1}_${comp_pob2}[6,1] = (aux[2,1] / (aux[1,1] + aux[2,1])) * 100		 
		mat nbi_${comp_pob1}_${comp_pob2}[6,2] = (aux[1,1] / (aux[1,1] + aux[2,1])) * 100		 
		
	} 
} 
