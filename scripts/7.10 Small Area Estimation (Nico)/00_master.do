drop _all
set trace off
set graph off 
set more off 
*set scheme economist
timer clear 
*##########################################################*
*##############       01 MASTER      ###################*
*##########################################################*

*##############      Configuración    #####################*

clear all
cls

global path_compu "C:\Users\Administrador\Documents\MECON"
global proyecto "7. Ingreso Esperado"
global subproyecto "7.10 Small Area Estimation (Nico)"

qui do "${path_compu}\7. Ingreso Esperado\scripts\plantilla.do" 
*fix me pla

/* Globales de las rutas definidas de forma automática:

$path_user 		- Ubicación de la carpeta del Proyecto
$path_datain	- Bases de datos inputs (raw y que recibis procesadas)
$path_dataout	- Bases procesadas por tus scripts
$path_scripts	- Ubicacion de dofiles, py, ipynb, etc.
$path_figures	- Output para las figuras/gráficos
$path_maps		- Output para los mapas (html o imagen)
$path_tables	- Output para las tablas (imagen o excel)
$path_programas	- Programas (fgt, gini, cuantiles, etc.)
*/


glo path_dataout "D:\MECON\7. Ingreso Esperado\data\data_out\7.10 Small Area Estimation (Nico)"
global path_ster "D:\MECON\7. Ingreso Esperado\data\data_out\7.10 Small Area Estimation (Nico)\ster"

capture mkdir "${path_dataout}"
capture mkdir "${path_dataout}\ster"
capture mkdir "${path_dataout}\compara"
capture mkdir "${path_figures}\compara\"
capture mkdir "${path_figures}\compara\graph"
capture mkdir "${path_figures}\graficos_regresion"


*############      Creo globales bases     ##############*
global prepara_censo     "${path_dataout}\prepara_censo"
global censo             "${path_dataout}\predict_censo"
global censo_analisis    "${path_dataout}\predict_ingreso_analisis" 
global collapse    		 "${path_dataout}\predict_ingreso_collapse" 

*global total_bases 30
global eph_seleccionada "15"

** Fijo
glo path_programas "$path_scripts\Comandos"
include "$path_programas\comandos.do"
*capture ssc install spmap
*capture ssc install unique
*capture ssc install outreg2
*capture ssc install qregsel

*##########################################################*
*############      Botonera    ##############* 

* Evita correr el prepara_censo
glo tengo_censo  "NO" // "SI" o "NO"


*##########################################################*
****** crea variables en EPH y regresiona por MCO el ingreso percápita de pobreza moderada
timer on 1
/* do "${path_scripts}\01_prepara_eph.do" */
dis "Terminó: 01_prepara_eph"
timer off 1

****** crea variables en Censo 2010 y arma los predict
timer on 2
/* do "${path_scripts}\02_censo_variables.do" */
dis "Terminó: 02_censo_variables"
timer off 2

loc base_15 "ARG_2010_EPHC-S2"
use "${path_dataout}\\`base_15'_v03_M_v01_A_SEDLAC-03_proc.dta", clear
keep if jefe==1

loc vjefe "hombre edad edad2 pric seci secc supi supc"
loc vviv "hv_precaria hv_matpreca hv_agua hv_banio hv_cloacas hv_propieta "
loc vhog "hv_miemhabi miembros " 
loc vreg "reg3 reg4 reg5 reg6 reg7 reg8 reg9 reg10 reg12 reg13 reg14 reg15 reg17 reg18 reg19 reg20 reg22 reg23 reg25 reg26 reg27 reg29 reg30 reg31 reg32 reg33 reg34 reg36 "

sae data import, datain("${prepara_censo}") varlist(`vjefe' `vviv' `vhog' `vreg') area(link) uniqid(id) dataout("${path_dataout}\\mata_censo")
sae data import, datain("${path_dataout}\\`base_15'_v03_M_v01_A_SEDLAC-03_proc.dta") varlist(`vjefe' `vviv' `vhog' `vreg') area(link) uniqid(id) dataout("${path_dataout}\\mata_eph")

sae model povmap ipcf `vjefe' `vviv' `vhog' `vreg', area(link) vce(ell)

// ****** Crea variables intertemporales 
// timer on 3
// *do "${path_scripts}\03a_variables_analisis.do"
// dis "Terminó: 03_variables_analisis"
// timer off 3
//
// ****** Crea variables intra radios censales
// timer on 4
// *do "${path_scripts}\03b_collapse_link.do"
// dis "Terminó: 03b_collapse_link"
// timer off 4
//
//
//
// ****** Crea variables intra radios circuitos 
// timer on 5
// do "${path_scripts}\03c_collapse_circuito.do"
// dis "Terminó: 03c_collapse_circuito"
// timer off 5
//
// // ****** Prepara gráficos
// // timer on 6
// // do "${path_scripts}\10_prepara_graficos.do"
// // dis "Terminó: 10_prepara_graficos"
// // timer off 6
//
// ****** Crea gráficos
// timer on 7
// qui do "${path_scripts}\06_graficos.do"
// dis "Terminó: 06_graficos"
// timer off 7 
//
// **********************
// **********************
//
// timer list 
// dis "goooooool"
//


