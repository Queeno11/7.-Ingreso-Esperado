
drop _all





use "${pathdpe}\censo2010\pobre_censo.dta"
keep link id com pminh pmaxh pobre_estruct rico_estruct 
label var pminh "minima probabilidad de ser pobre en todos los modelos (usada para pobre_estruct)"
label var pmaxh "maxima probabilidad de ser pobre en todos los modelos (usada para rico_estruct)"


gen cprov =int(link/10000000)
gen cdpto =int(link/10000)

* base por provincia
preserve
collapse (mean) pobre_estruct rico_estruct pminh pmaxh , by(cprov)
save "${pathdpe}\censo2010\pobre_provincia.dta", replace
restore

preserve
collapse (mean) pobre_estruct rico_estruct pminh pmaxh , by(cdpto)
save "${pathdpe}\censo2010\pobre_dptos.dta", replace
restore

