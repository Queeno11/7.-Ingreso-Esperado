drop _all

if "${pathdcenso2001}"=="" {
	glo path "P:\OneDrive\"

	glo pathw "${path}\penpag\Work\C_arggeo\dofiles\01_PobCronCenso2001\\"
	glo path_dbh "${path}\dbh\"
	glo pathdpe "${path_dbh}\censos\"
	glo pathd "${pathdpe}\bases_arg\Arg_imputado\"
	glo pathdcenso2001 "${path_dbh}\censos\arg_censo2001\"
	glo pathdcenso2010 "${path_dbh}\censos\arg_censo2010\"
}
/*
use "${pathdcenso2010}\arg_dptos_db_2010.dta"
duplicates report cdpto
destring codpcia, gen(cprov)
keep cdpto cprov x_cent y_cent
merge 1:1 cdpto cprov using "${pathdcenso2010}\dptos_aglos_2010.dta"
drop _merge
* identifico los departamentos por provincia más cercanos a cada aglomerado
* 1 solo aglomerado por provincia
duplicates report cprov cdpto
sort cprov cdpto
by cprov: egen min=min(caglo)
by cprov: egen max=max(caglo)
gen dif =max-min
gen aglo_p=max if dif ==0
* dif =0 provincias con un solo aglomerado
* dif !=0 provincias con más de un aglomerado
gen masaglo =1 if dif !=0
*--/
*No es problema:
*26 chubut
*	9
*	91 * no en probit
*--/
replace aglo_p = . if cprov ==62
replace aglo_p = 9 if cprov ==26
* armo dummies sin problemas (los que tengo en aglo_p)
foreach a in 7 8 9 10 12 15 17 18 19 20 22 23 25 26 27 29 30 31 32 {
	gen reg`a' =0
	replace reg`a' = 1 if aglo_p ==`a'
}
************************* corrijo buenos aires
* 6 bsas
* aglos
*	2
*	3
*	33
*	34
*	38 * no en probit
*	93 * no en probit

loc prov =6
loc listaa "2 3 33 34"
foreach a in `listaa' {
	gen reg`a' =0
	* distancia de cada dpto 
	sum x_cent if caglo == `a'
	loc x=r(mean)
	sum y_cent if caglo == `a'
	loc y=r(mean)
	gen double distancia_`a' =((x_cent-`x')^2+(y_cent-`y')^2)^(1/2) if cprov == `prov'
}
egen double dtot = rsum(distancia_*) if cprov == `prov'

foreach a in `listaa' {
	replace reg`a'  = distancia_`a' / dtot if cprov == `prov'
}
drop distancia_* dtot 

*14 cordoba
*	13
*	36
loc prov =14
loc listaa "13 36"
foreach a in `listaa' {
	gen reg`a' =0
	* distancia de cada dpto 
	sum x_cent if caglo == `a'
	loc x=r(mean)
	sum y_cent if caglo == `a'
	loc y=r(mean)
	gen double distancia_`a' =((x_cent-`x')^2+(y_cent-`y')^2)^(1/2) if cprov == `prov'
}
egen double dtot = rsum(distancia_*) if cprov == `prov'

foreach a in `listaa' {
	replace reg`a'  = distancia_`a' / dtot if cprov == `prov'
}
drop distancia_* dtot 


*30 entrerios
*	6
*	14 
loc prov =30
loc listaa "6 14"
foreach a in `listaa' {
	gen reg`a' =0
	* distancia de cada dpto 
	sum x_cent if caglo == `a'
	loc x=r(mean)
	sum y_cent if caglo == `a'
	loc y=r(mean)
	gen double distancia_`a' =((x_cent-`x')^2+(y_cent-`y')^2)^(1/2) if cprov == `prov'
}
egen double dtot = rsum(distancia_*) if cprov == `prov'

foreach a in `listaa' {
	replace reg`a'  = distancia_`a' / dtot if cprov == `prov'
}
drop distancia_* dtot 

*82 santafe
*	4
*	5
*	38 * no en probit
loc prov =82
loc listaa "4 5"
foreach a in `listaa' {
	gen reg`a' =0
	* distancia de cada dpto 
	sum x_cent if caglo == `a'
	loc x=r(mean)
	sum y_cent if caglo == `a'
	loc y=r(mean)
	gen double distancia_`a' =((x_cent-`x')^2+(y_cent-`y')^2)^(1/2) if cprov == `prov'
}
egen double dtot = rsum(distancia_*) if cprov == `prov'

foreach a in `listaa' {
	replace reg`a'  = distancia_`a' / dtot if cprov == `prov'
}
drop distancia_* dtot 

* problema!! 62 rionegro no tiene aglo por que el único es 93 y no hay dummie
* puede ser chubut o neuquen?
* 26 chubut
* 	9 Comodoro Rivadavia - Rada Tilly
* 58 neuquen
* 	17 Neuquén - Plottier
loc prov =82
loc listaa "9 17"
foreach a in `listaa' {
	* distancia de cada dpto 
	sum x_cent if caglo == `a'
	loc x=r(mean)
	sum y_cent if caglo == `a'
	loc y=r(mean)
	gen double distancia_`a' =((x_cent-`x')^2+(y_cent-`y')^2)^(1/2) if cprov == 62
}
egen double dtot = rsum(distancia_*) if cprov == 62

foreach a in `listaa' {
	replace reg`a'  = distancia_`a' / dtot if cprov == 62
}
egen control=rsum(reg*) 
ta control
drop distancia_* dtot control
drop ndpto nprov naglo aglo_p masaglo dif min max y_cent x_cent
order cdpto cprov caglo reg2 reg3 reg4 reg5 reg6 reg7 reg8 reg9 reg10 reg12 reg13 reg14 reg15 reg17 reg18 reg19 reg20 reg22 reg23 reg25 reg26 reg27 reg29 reg30 reg31 reg32 reg33 reg34 reg36
compress
save "${pathdcenso2001}\dummies_aglo_xdpto_2010.dta", replace

use "${pathdcenso2001}\dummies_aglo_xdpto_2010.dta"
* agrego secciones de CABA no incluidas en 2010 pero si en 2001 (están más divididas)
count
loc n1 = r(N)
loc n2 = `n1' + 6
set obs `n2'

forvalues i=1/6 {
	replace cdpto =2015+`i' if _n == `n1' +`i'
	replace reg32 =1 if _n == `n1' +`i'
}
replace caglo =32 if caglo ==.
replace cprov =2  if cprov ==.
foreach var of varlist reg* {
	replace `var'=0 if `var'==.
}
sort cprov cdpto caglo
save "${pathdcenso2001}\dummies_aglo_xdpto_2001.dta", replace


*/

/*
* paso csv a dta
cd "P:\OneDrive\dbh\censos\arg_censo2001\CNPHyV-2001.csv"
foreach base in hogar persona vivienda prov dpto frac radio seg {
	import delimited `base'.csv, case(lower) asdouble clear
	save "${pathdcenso2001}\CNPHyV-2001.csv\\`base'.dta",replace
}
*/
*

drop _all
cap use "${pathdcenso2001}\censo2001_fullraw_p.dta"
*cap use "${pathdcenso2001}\censo2001_fullraw_p_s1.dta"

if _rc!=0 {
	* prov
	use "${pathdcenso2001}\CNPHyV-2001.csv\prov.dta" 
	duplicates tag prov_ref_id , gen(reps)
	count if reps !=0
	assert r(N)==0
	drop reps
	* paso a numericas algunas muy largas
	labmask prov, val(nomprov)
	drop nomprov idprov cpv2001_ref_id

	*dptos 
	merge 1:m prov_ref_id using "${pathdcenso2001}\CNPHyV-2001.csv\dpto.dta" 
	sum _merge
	assert r(min)==3 & r(max)==3
	drop _merge
	duplicates tag dpto_ref_id , gen(reps)
	count if reps !=0
	assert r(N)==0
	drop reps
	* paso a numericas algunas muy largas
	labmask dpto, val(nomdepto)
	drop nomdepto iddpto

	* frac
	merge 1:m dpto_ref_id using "${pathdcenso2001}\CNPHyV-2001.csv\frac.dta" 
	sum _merge
	assert r(min)==3 & r(max)==3
	drop _merge
	duplicates tag frac_ref_id , gen(reps)
	count if reps !=0
	assert r(N)==0
	drop reps
	*radios
	merge 1:m frac_ref_id using "${pathdcenso2001}\CNPHyV-2001.csv\radio.dta" 
	sum _merge
	assert r(min)==3 & r(max)==3
	drop _merge
	duplicates tag radio_ref_id , gen(reps)
	count if reps !=0
	assert r(N)==0
	drop reps
	*segmento	
	merge 1:m radio_ref_id using "${pathdcenso2001}\CNPHyV-2001.csv\seg.dta" 
	sum _merge
	assert r(min)==3 & r(max)==3
	drop _merge
	duplicates tag seg_ref_id , gen(reps)
	count if reps !=0
	assert r(N)==0
	drop reps
	* armo link
	/*
	dpto+frac+radio todo string, después destring
	*/
	tostring dpto, gen(aux1)
	tostring idfrac, gen(aux2)
	replace aux2="0"+aux2 if idfrac<=9
	tostring idradio, gen(aux3)
	replace aux3="0"+aux3 if idradio<=9
	gen link =aux1+aux2+aux3
	destring link, replace
	drop aux*
	save temp_srfdp.dta, replace

	use "${pathdcenso2001}\CNPHyV-2001.csv\persona.dta" 
	duplicates tag persona_ref_id hogar_ref_id, gen(reps)
	count if reps !=0
	assert r(N)==0
	drop reps
	save temp_p.dta, replace
	use "${pathdcenso2001}\CNPHyV-2001.csv\hogar.dta" 
	duplicates tag hogar_ref_id, gen(reps)
	count if reps !=0
	assert r(N)==0
	drop reps
	save temp_h.dta, replace
	use "${pathdcenso2001}\CNPHyV-2001.csv\vivienda.dta" 
	duplicates tag vivienda_ref_id, gen(reps)
	count if reps !=0
	assert r(N)==0
	drop reps
	save temp_v.dta, replace

	* abro base con datos de prov, dpto, frac, radio, seg
	use temp_srfdp
	* macheo con viviendas
	merge 1:m seg_ref_id using temp_v
	sum _merge, mean
	assert r(min)==3 & r(max)==3
	drop _merge
	* macheo con hogares
	merge 1:m vivienda_ref_id using temp_h
	sum _merge, mean
	assert r(min)==3 & r(max)==3
	drop _merge
	* macheo con personas
	merge 1:m hogar_ref_id using temp_p
	* elimino viviendas vacías (estos no machean con la base de personas
	drop if tipoviv ==2
	sum _merge, mean
	assert r(min)==3 & r(max)==3
	drop _merge
	* etiquetas
	label language Spanish, rename
	order vivienda_ref_id hogar_ref_id persona_ref_id prov dpto link, first 
	order idfrac idradio prov_ref_id dpto_ref_id frac_ref_id radio_ref_id seg_ref_id, last
	compress
	save "${pathdcenso2001}\censo2001_fullraw_p.dta", replace
	foreach file in p h v srfdp {
		erase temp_`file'.dta
	}
}
/*
tipoviv
1 Realizada en vivienda particular 
2 No realizada (vivienda desocupada) 
3 Realizada a hogar en la calle 
4 Realizada en institución 
5 MISSING                      
0 NOTAPPLICABLE 
*/
egen id =group(link vivienda_ref_id hogar_ref_id)
gen com =persona_ref_id
compress id com
duplicates tag persona_ref_id hogar_ref_id, gen(reps)
count if reps !=0
assert r(N)==0
drop reps
sort id com
* hogarsec
* Relación con el jefe de hogar  
/* 
Código Rótulo
0 residente en instituci�n colectiva 
1 Jefe(a)
2 Cónyuge
3 Hijo(a) / hijastro (a)
4 Yerno / nuera
5 Nieto(a)
6 Padre / madre / suegro(a)
7 Otros familiares
8 Otros no familiares
9 Servicio doméstico y sus familiares
*/
drop if p1 ==0
gen byte relacion=p1

* Miembros de hogares secundarios (personal doméstico y su familia y pensionistas)
gen	byte hogarsec = 0 if p1 !=0 & p1 !=. 
*p1 = 9  Servicio domestico y sus familiares
replace hogarsec = 1 if p1 == 9 

*p1 = 1 Jefe
gen byte jefe = 0 if p1 !=0 & p1 !=.
replace jefe = 1 if p1 == 1 


*p3 edad
gen edad = p3 
* edad al cuadrado
gen edad2 = edad * edad
compress edad edad2

*edad1217 edad1824 edad2540 edad4164 edad65 
gen byte edad11=.
replace edad11= 0 if edad!=.
replace edad11= 1 if edad<12

gen byte edad1217=.
replace edad1217= 0 if edad!=.
replace edad1217= 1 if edad>=12 & edad<18

gen byte edad1824=.
replace edad1824= 0 if edad!=.
replace edad1824= 1 if edad>=18 & edad<25

gen byte edad2540=.
replace edad2540= 0 if edad!=.
replace edad2540= 1 if edad>=25 & edad<41

gen byte edad4164=.
replace edad4164= 0 if edad!=.
replace edad4164= 1 if edad>=41 & edad<65


gen byte edad65=.
replace edad65= 0 if edad!=.
replace edad65= 1 if edad>=65 & edad<.

* pric seci secc supi supc 
/*
p4 2001
Sabe leer y escribir (condición de alfabetismo - p4):
Código Rótulo
1 Sí
2 No

cp3 2001
0 nunca asistio 
1 asiste establecimiento público 
2 asiste establecimiento privado 
3 no asiste pero asistió 
4 notapplicable 
*/

******** primero creo nivel educativo al estilo indec
/* NIVEL-ED N(2): Nivel Educativo
	1= Primaria Incompleta(incluye educación especial)
	2= Primaria Completa
	3= Secundaria Incompleta
	4= Secundaria Completa
	5= Superior Universitaria Incompleta
	6= Superior Universitaria Completa 
	7= Sin instrucción 
	9= Ns/ Nr
*/


* Nivel educativo
/* 0= nunca asistió, 
   1= primario incompleto, 
   2= primario completo, 
   3= secundario incompleto, 
   4= secundario completo, 
   5= superior incompleto,
   6= superior completo  */
/*
cp4 2001
 0 nunca asistió	
 1 asiste jard�n/preescolar	
 2 asiste 1er grado	
 3 asiste 2do o 3er grado	
 4 asiste 4to a 6to grado	
 5 asiste egb o 7mo grado	
 6 asiste secundaria 1ro o egb 8vo	
 7 asiste secundaria 2do o egb 9no	
 8 asiste secundaria 3ro o m�s o polimodal1
 9 asiste terciario 1er a�o	
10 asiste terciario 2do o m�s	
11 asiste universitario 1er a�o	
12 asiste universitario 2do a�o o m�s	
13 asistió preescolar	
14 asistió primaria/egb 1er grado incomple
15 asistió 1ro a 2do grado	
16 asistió 3er grado	
17 asistió 4to a 5to grado	
18 asistió 6to grado	
19 asistió primaria completa	
20 asistió egb aprob� 7mo grado	
21 asistió secundario aprobo ninguno	
22 asistió egb aprob� 8vo grado 
23 asistió egb completo	 
24 asistió secundario aprob� 1ro	 
25 asistió secundario aprob� 2do	 
26 asistió secundario aprob� 3ero o m�s	 
27 asistió polimodal y aprob� 1ro a 2do	 
28 asistió polimodal aprob� ninguno	 
29 asistió secundario completo	 
31 asistió terciario aprob� ninguno	 
32 asistió universitario aprob� ninguno	 
33 asistió terciario aprob� 1ro o m�s	 
34 asistió terciario completo	 
35 asistió universitario aprob� 1ro o m�s	 
36 asistió universitario completo	 
37 notapplicable	 
*/
* le empienzan a preguntar a los de 3 y más
gen byte nivel =.
* nunca asistio
replace nivel =0 if edad <=2
replace nivel =0 if cp3 ==0 
replace nivel =0 if cp4 ==1
replace nivel =0 if cp4 ==13

* prii
replace nivel =1 if cp4 >=2 & cp4<=5
replace nivel =1 if cp4 >=14 & cp4<=18
replace nivel =1 if cp4 ==20

* edu especial = prii
* replace nivel =1 if ==> no hay en censo 2001

* pric
replace nivel =2 if cp4 ==19

* seci
replace nivel =3 if cp4 >=6 & cp4<=8
replace nivel =3 if cp4 >=21 & cp4<=28

* secc
replace nivel =4 if cp4 ==29

* supi
replace nivel =5 if cp4 ==31
replace nivel =5 if cp4 ==32
replace nivel =5 if cp4 ==33
replace nivel =5 if cp4 ==35

* supc
replace nivel =6 if cp4 ==34
replace nivel =6 if cp4 ==36


* Dummy del nivel educativo 
gen byte prii = 0 if  nivel>=0 & nivel<=6
replace prii = 1 if  nivel==0 | nivel==1

gen byte pric = 0 if  nivel>=0 & nivel<=6
replace pric = 1 if  nivel==2

gen byte seci = 0 if  nivel>=0 & nivel<=6
replace seci = 1 if  nivel==3

gen byte secc = 0 if  nivel>=0 & nivel<=6
replace secc = 1 if  nivel==4

gen byte supi = 0 if  nivel>=0 & nivel<=6
replace supi = 1 if  nivel==5

gen byte supc = 0 if  nivel>=0 & nivel<=6
replace supc = 1 if  nivel==6

*miembros miembros2 
* Numero de miembros del hogar (de la familia principal)


*duplicates report link nviv nhog nper
gen uno=1
by id: egen miembros =sum(uno) if hogarsec==0 & relacion!=.
drop uno

gen miembros2 = miembros * miembros

*jj_edad jj_edad2 jj_pric jj_seci jj_secc jj_supi jj_supc 
* datos del jefe

capture drop aux*
foreach var of varlist edad edad2 pric seci secc supi supc {
	gen aux =`var' if jefe ==1
	egen int jj_`var'=max(aux), by(id)
	drop aux
}
compress

* Vivienda "precaria"

/*
Tipo de vivienda particular (V04):
V4
0 Casa tipo A
1 Casa tipo B
2 Rancho     
3 Casilla    
4 Departamento 
5 Pieza/s en inquilinato
6 Pieza/s en hotel o pensión
7 Local no construido para habitación
8 Vivienda móvil
9 En la calle
11 "MISSING   
10 "NOTAPPLICABLE"


Código Rótulo
1 Casa
2 Rancho
3 Casilla
4 Departamento
5 Pieza en inquilinato
6 Pieza en hotel familiar o pensión
7 Local no construido para habitación
8 Vivienda móvil
9 Persona/s viviendo en la calle
*/
gen byte hv_precaria=.
replace hv_precaria=1 if v4==5 | v4==6 | v4==7 | v4==8 | v4==9 
replace hv_precaria=1 if v4==3 | v4==2 
replace hv_precaria=0 if v4==0 | v4==1 | v4==4 
label var hv_precaria "vivienda precaria"

*hv_matpreca 
/*
ch28 Calidad de los materiales de la vivienda
1 CALMAT I  
2 CALMAT II 
3 CALMAT III
4 CALMAT IV 
5 CALMAT V  
6 MISSING   
0 NOTAPPLICABLE

*/
/*
v5      material predominante de los pisos de vivienda
0 NOTAPPLICABLE
1 Cerámica, baldosa, mosaico, mármol, madera o alfombrado
2 Cemento o ladrillo fijo
3 Otros
4 Tierra o ladrillo suelto
5 MISSING   
*/
/*
cv13    material cubierta exterior de los techos de vivienda
ch13    material cubierta exterior de los techos

cv13 Material cubierta exterior de los techos de vivienda

1 Cubierta asfáltica o membrana con cielorraso
2 Baldosa o losa (sin cubierta) con cielorraso
3 Pizarra o teja con cielorraso
4 Chapa de metal (sin cubierta) con cielorraso
5 Chapa de fibrocemento o plástico con cielorraso
6 Otros materiales con cielorraso
7 Cubierta asfáltica o membrana sin cielorraso
8 Baldosa o losa (sin cubierta) sin cielorraso
9 Pizarra o teja sin cielorraso
10 Otros materiales sin cielorraso
11 Chapa de metal (sin cubierta) sin cielorraso
12 Chapa de fibrocemento o plástico sin cielorraso
13 Chapa de cartón
14 Caña, tabla o paja con barro, paja sola
16 MISSING
15 NOTAPPLICABLE



-Revestimiento interior o cielorraso del techo (H07): cobertura del techo del lado de adentro de una vivienda (revestimiento interior), que puede ser revoque, yeso, madera y/o placas de poliestireno expandido, etcétera. El cielorraso es un aislamiento adicional al techo que sirve para proteger a los habitantes de los ruidos y de las inclemencias climáticas. Cuando alguna/s de las habitaciones de la vivienda no tenga/n cielorraso, se registra la situación predominante.
Código Rótulo
1 Si tiene
2 No tiene
*/

gen hv_matpreca =.
replace hv_matpreca =1 if (v5 ==4 | cv13 ==13 | cv13 ==14)
replace hv_matpreca =0 if (v5 <=2 & cv13 <=12)
* los missing son los que tienen h05 =4 o h06 =8 completo con ch28
replace hv_matpreca =0 if hv_matpreca ==. & ch28<=3
replace hv_matpreca =1 if hv_matpreca ==. & (ch28==4 | ch28==5) 

*
**************************
* agua y cloacas
**************************

/*
-Tenencia de agua (h10): forma en que el hogar accede al agua que utiliza. Las categorías son:
Provisión de agua en la vivienda –V10-
1. Por cañería dentro de la vivienda
2. Fuera de la vivienda pero dentro del terreno
3. Fuera del terreno

Procedencia del agua para beber y cocinar (H09): fuente y sistema de abastecimiento del agua que el hogar utiliza para beber y cocinar. En caso de abastecerse con más de una fuente, se considera la que predomina en el uso cotidiano del hogar. Las categorías son:
Código Rótulo
1 Red pública
2 Perforación con bomba a motor
3 Perforación con bomba manual
4 Pozo
5 Transporte por cisterna
6 Agua de lluvia, río, canal, arroyo o acequia

Procedencia de agua en la vivienda –h11-
1. De red pública (agua corriente)
2. De perforación con bomba a motor
3. De perforación con bomba manual
4. De pozo con bomba
5. De agua de lluvia
6. De transporte por cisterna
7. De río, canal, arroyo
8. De pozo sin bomba
*/

gen byte hv_agua =.
replace hv_agua = 0 if h10 ==3
replace hv_agua = 0 if h11 >=2 & h11<=8
replace hv_agua = 1 if (h10 ==1 | h10 ==2) | h11==1


/*
Servicio sanitario –CH9-: refiere a la disponibilidad del hogar de la infraestructura interna para la evacuación de excretas y se presenta en forma conjunta la tenencia y tipo de desagüe del inodoro con descarga de agua. Se definen las siguientes categorías:
1. Inodoro con descarga de agua y desagüe a red pública
2. Inodoro con descarga de agua y desagüe a cámara séptica y pozo ciego
3. Inodoro con descarga de agua y desagüe sólo a pozo ciego u hoyo, excavación en la tierra
4. Inodoro sin descarga de agua, sin inodoro o sin baño

Tenencia de baño exclusivo –H16-: refiere al tipo de uso del baño por los hogares. Solamente se aplica a los hogares que tienen infraestructura interna para la evacuación de excretas. Se definen las siguientes categorías:
1. Usado sólo por este hogar
2. Compartido con otro hogar


-Desagüe del inodoro (H12): disponibilidad de un sistema de cañerías que permite el arrastre del agua y la eliminación de las excretas del inodoro. Las categorías son:
Código Rótulo
1 A red pública
2 A cámara séptica y pozo ciego
3 Sólo a pozo ciego
4 A hoyo, excavación en la tierra, etc.
*/
gen byte hv_banio =1 if ch9>=1 & ch9<=4
replace hv_banio =0 if ch9 == 0

gen byte hv_cloacas =.
replace hv_cloacas = 0 if hv_banio ==0
replace hv_cloacas = 0 if ch9>=2 & ch9<=4  
replace hv_cloacas = 1 if ch9==1 


* Propiedad de la vivienda
/*
ch6
Régimen de tenencia de la vivienda que ocupa el hogar –CH6-
1. Propietario de la vivienda y del terreno
2. Propietario de la vivienda solamente
3. Inquilino
4. Ocupante por préstamo
5. Ocupante por trabajo
6. Otra situación
*/
gen hv_propieta =.
replace hv_propieta =1 if ch6 ==1 
replace hv_propieta =0 if (ch6>=2 & ch6<=6)
label var hv_propieta "propietario de la vivienda"



* Numero de habitaciones de uso exclusivo no contando el banio y la cocina 

/*
Habitaciones o piezas que tiene en total el hogar –H21-: 

En el total de habitaciones o piezas se contabiliza: el comedor (aunque se encuentre integrado a la cocina: cocina-comedor) y los entrepisos (construidos en algunas viviendas, pese a no 11
tener alguna de las paredes señaladas en la definición); se excluyen: baños, cocinas (usadas exclusivamente para cocinar), lavaderos, garajes, pasillos, halls, recibidores y galpones (siempre y cuando no se utilicen para que duerma una persona) y quinchos sin cerramiento.
*/
gen habita=.
replace habita=h21
replace habita=. if habita<=0 
label var habita "habitaciones uso exclusivo"


gen hv_miemhabi=miembros/habita
compress

* reg3 reg4 reg5 reg6 reg7 reg8 reg9 reg10 reg12 reg13 reg14 reg15 reg17 reg18 reg19 reg20 reg22 reg23 reg25 reg26 reg27 reg29 reg30 reg31 reg32 reg33 reg34 reg36
ren prov cprov 
ren dpto cdpto



merge m:1 cdpto cprov using "${pathdcenso2001}\dummies_aglo_xdpto_2001.dta"
ta _merge

save "${pathdcenso2001}\censo2010_harm_var_p.dta", replace
forvalues i=1/29 {
	estimates use "${pathw}\out\ster\probit_t1_base_`i'"
	predict pp`i'
}

save "${pathdcenso2001}\predict_pobcron_censo2001.dta", replace

