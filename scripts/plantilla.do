*##############################################################################*
* PLANTILLA *
*##############################################################################*

global path_user "$path_compu/$proyecto"

capture mkdir		"$path_user/data"
capture mkdir		"$path_user/data/data_in"
capture mkdir		"$path_user/data/data_out"
capture mkdir		"$path_user/docs"
capture mkdir		"$path_user/scripts"
capture mkdir		"$path_user/scripts/$subproyecto"
capture mkdir		"$path_user/outputs"
capture mkdir		"$path_user/outputs/figures"
capture mkdir		"$path_user/outputs/figures/$subproyecto"
capture mkdir		"$path_user/outputs/maps"
capture mkdir		"$path_user/outputs/maps/$subproyecto"
capture mkdir		"$path_user/outputs/tables"
capture mkdir		"$path_user/outputs/tables/$subproyecto"

global path_datain	"D:\MECON\7. Ingreso Esperado\data\data_in"
global path_dataout	"$path_user/data/data_out"
global path_scripts	"$path_user/scripts/$subproyecto"
global path_figures	"$path_user/outputs/figures/$subproyecto"
global path_maps	"$path_user/outputs/maps/$subproyecto"
global path_tables	"$path_user/outputs/tables/$subproyecto"