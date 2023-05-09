drop _all

capture cd "D:\onepag\OneDrive\"

if _rc==0 glo path "D:\onepag\OneDrive\"
capture cd "C:\onepag\OneDrive\"
if _rc==0 glo path "C:\onepag\OneDrive\"
glo pathb "${path}\dbh\C_Gasparini\"
glo pathdatalib "${path}\dbh\datalib\"
glo pathdo "${path}\penpag\Work\C_Gasparini\2019_pob_estructural\do\"
glo pathout "${path}\penpag\Work\C_Gasparini\2019_pob_estructural\output\"


******************************************
* versión final
* Pobreza moderada con ingreso_hd (total) *
******************************************
******************************************

glo tprob  = "mod"
do "${pathdo}\01_probit.do"
----
do "${pathdo}\02_predict_ypobres.do"
do "${pathdo}\06_pobprofile.do"


