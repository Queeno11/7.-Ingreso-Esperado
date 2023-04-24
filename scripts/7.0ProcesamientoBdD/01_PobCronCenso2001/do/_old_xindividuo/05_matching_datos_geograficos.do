
drop _all

*glo path "C:\Users\gluzm\OneDrive\"


use "${pathdcenso}\cartografia\arg_dptos_db.dta"
destring codpcia, gen(cprov)

save temp.dta, replace
drop _all
use "${pathdpe}\censo2010\pobre_provincia.dta"
merge 1:m cprov using temp.dta
keep cprov pobre_estruct rico_estruct pminh pmaxh provincia
duplicates drop cprov, force
order cprov provincia pobre_estruct rico_estruct pminh pmaxh 
export excel using "${pathw}\out\Pobresa_estructural.xlsx", sheetmodify sheet("data_prov") cell(C9) firstrow(variables)

drop _all
use "${pathdpe}\censo2010\pobre_dptos.dta"
merge 1:1 cdpto using temp.dta
keep cprov provincia cdpto departamen pobre_estruct rico_estruct pminh pmaxh 
order cprov provincia cdpto departamen pobre_estruct rico_estruct pminh pmaxh 
export excel using "${pathw}\out\Pobresa_estructural.xlsx", sheetmodify sheet("data_dptos") cell(C9) firstrow(variables)

*spmap pobre_estruct 
drop _all
use "${pathdpe}\censo2010\pobre_dptos.dta"
merge 1:1 cdpto using temp.dta

drop if idd == 527
drop if idd == 440


replace pobre_estruct  =pobre_estruct  *100
gen pobre_estruct_r =round(pobre_estruct,1)

spmap pobre_estruct_r  using "${pathdcenso}\cartografia\arg_dptos_c", id(idd) ///
graphregion(color(ltbluishgray)) fcolor(Reds2) ndfcolor(gs12)   clnumber(10) legend(position(5))

graph export "${pathw}\out\tasa_pob_cronica_xdptos.png", replace
---
replace rico_estruct  =rico_estruct  *100
spmap rico_estruct  using "${pathdcenso}\cartografia\arg_dptos_c", id(idd) ///
graphregion(color(ltbluishgray)) fcolor(Reds2) ndfcolor(gs12)  clnumber(10) legend(position(5))

graph export "${pathw}\out\tasa_no_vulnerables_xdptos.png", replace
