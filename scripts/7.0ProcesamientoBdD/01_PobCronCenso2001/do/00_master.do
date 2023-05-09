drop _all

glo path "P:\OneDrive\"

glo pathw "${path}\penpag\Work\C_arggeo\dofiles\01_PobCronCenso2001\\"
glo path_dbh "${path}\dbh\"
glo pathdpe "${path_dbh}\censos\"
glo pathd "${pathdpe}\bases_arg\Arg_imputado\"
glo pathdcenso2001 "${path_dbh}\censos\arg_censo2001\"
glo pathdcenso2010 "${path_dbh}\censos\arg_censo2010\"

****** crea variables en EPH y estima probit de pobreza moderada
*do "${pathw}\do\01_probit_ephc.do"
****** crea variables en Censo 2010 y arma los predict para todos los modelos
do "${pathw}\do\02_censo_variables.do"
****** crea pobreza
do "${pathw}\do\03_predict_censo.do"
-- hasta acá

****** computa tasas por provincia y dpto/partido
do "${pathw}\do\04_pobre_estruc_xprov_dpto.do"
****** machea con etiquetas de provincias y partidos, hace mapas
do "${pathw}\do\05_matching_datos_geograficos.do"

