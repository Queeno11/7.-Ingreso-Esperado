
* nombre del excel
glo nombrexls "Pobre_vulnerable_hog_lpmod.xlsx"
glo celda "B60"
******** ACTIVA PROGRAMAS *********
local path_do  "C:\cedlas\Cedlas\do" 
loc programs "fgt shares gini shares_group hotel_mio diff_gini diff_shares"
foreach p of local programs {
	run "`path_do'\\`p'.do"
}
* Programas
* local path_do "\\\cedlas\cedlas\do" 
* CONTADOR DE FILAS (encuestas + espacios intermedios)
glo nn = 1
*** Numero de replicas del bootstrap (si reps < 50 no corre el bootstrap)
glo rrep = 1

*loc base_in_1 "${pathb}\2019_pob_estructural\Bases_predict\\ARG_2018_s1_pmod_29_29.dta"
loc base_in_1 "${pathb}\2019_pob_estructural\Bases_predict\\ARG_2019_s1_pmod_32_32.dta"

* abre base
use "`base_in_1'", clear
noi di in ye "Base = `base_in_1'"


**** GENERA VARIABLES ***
include "${pathdo}\06a_variables_profile.doi"


* computo para pobre_estruct vs vulnerable estruct
preserve
global comp_pob1 "pobre_estruct"
global comp_pob2 "vulne_estruct"
global exclusivo ="no"
run "${pathdo}\06b_calculaPOVPROF.do"

restore

* computo para pobre_monequi vs vulne_monequi
preserve
global comp_pob1 "pobre_monequi"
global comp_pob2 "vulne_monequi"
global exclusivo ="no"
keep if ${comp_pob1} ==1 | ${comp_pob2} ==1
run "${pathdo}\06b_calculaPOVPROF.do"
restore

* computo para pobre_estruct vs pobre_monequi sacando al grupo comun
preserve
global comp_pob1 "pobre_estruct"
global comp_pob2 "pobre_monequi"
global exclusivo ="si"
keep if ${comp_pob1} ==1 | ${comp_pob2} ==1
run "${pathdo}\06b_calculaPOVPROF.do"
restore

* computo para pobre_estruct vs pobre_monequi sacando al grupo comun
preserve
global comp_pob1 "pobre_cond"
global comp_pob2 "vulne_cond"
global exclusivo ="si"
keep if ${comp_pob1} ==1 | ${comp_pob2} ==1
run "${pathdo}\06b_calculaPOVPROF.do"
restore

glo lista_comparacion "pobre_estruct_vulne_estruct pobre_monequi_vulne_monequi pobre_estruct_pobre_monequi pobre_cond_vulne_cond"

do "${pathdo}\06c_exporta_POVPROF_sedlac.do"

