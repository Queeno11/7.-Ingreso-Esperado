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
global subproyecto "7.3 Ingreso por hogar"

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


glo path_dataout "D:\MECON\7. Ingreso Esperado\data\data_out\7.3 Ingreso por hogar"
global path_ster "D:\MECON\7. Ingreso Esperado\data\data_out\ster"

capture mkdir "${path_dataout}"
capture mkdir "${path_dataout}\ster"
capture mkdir "${path_dataout}\compara"
capture mkdir "${path_figures}\compara\"
capture mkdir "${path_figures}\compara\graph"
capture mkdir "${path_figures}\graficos_regresion"


*############      Creo globales bases     ##############*
global prepara_censo             "${path_dataout}\prepara_censo"
global censo             "${path_dataout}\predict_censo"
global censo_analisis    "${path_dataout}\predict_ingreso_analisis" 
global collapse    "${path_dataout}\predict_ingreso_collapse" 

*global total_bases 30
global total_bases 30
global bases_eleccion "1 8 16 24 30"

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
glo tengo_censo  "SI"
glo tengo_censo  "NO"

* Winsor entes de la regresion
glo winsor  "NO"
glo winsor  "SI" 


* Analiza modelos de regresion
glo analisis_modelos  "SI"
*glo analisis_modelos  "NO"

*##########################################################*
****** crea variables en EPH y regresiona por MCO el ingreso percápita de pobreza moderada

timer on 1
*do "${path_scripts}\01_MCO_ephc.do"
dis "Terminó: 01_MCO_ephc"
timer off 1
****** crea variables en Censo 2010 y arma los predict
timer on 2
*do "${path_scripts}\02_censo_variables.do"
dis "Terminó: 02_censo_variables"
timer off 2
****** Crea variables intertemporales 
timer on 3
*do "${path_scripts}\03a_variables_analisis.do"
dis "Terminó: 03_variables_analisis"
timer off 3

****** Crea variables intra radios censales
timer on 4
*do "${path_scripts}\03b_collapse_link.do"
dis "Terminó: 03b_collapse_link"
timer off 4



****** Crea variables intra radios circuitos 
timer on 5
do "${path_scripts}\03c_collapse_circuito.do"
dis "Terminó: 03c_collapse_circuito"
timer off 5

// ****** Prepara gráficos
// timer on 6
// do "${path_scripts}\10_prepara_graficos.do"
// dis "Terminó: 10_prepara_graficos"
// timer off 6

****** Crea gráficos
timer on 7
qui do "${path_scripts}\06_graficos.do"
dis "Terminó: 06_graficos"
timer off 7 

**********************
**********************

timer list 
dis "goooooool"



