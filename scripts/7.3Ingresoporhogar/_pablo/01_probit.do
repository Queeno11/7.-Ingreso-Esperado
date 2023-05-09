
capture erase 	"${pathout}\outreg_pr_${tprob}.txt"

include "${pathdo}\01a_pathbases.doi"

mat stat_var_${tprob}=J(`bfin'-`bini'+1,50,1)
qui forvalues i=`bini' / `bfin' {
	noi di "estima `base_`i''" 
	drop _all
	use "${pathdatalib}\\`base_completo_`i''"
	*defino linea de pobreza e ingreso
	include "${pathdo}\01b_variables_probit.doi"
	keep if jefe ==1
	* variables independientes
	loc vjefe "edad edad2 edad2540 edad4164 edad65 pric seci secc supi supc aedu"
	loc vviv "hv_precaria hv_matpreca hv_agua hv_banio hv_cloacas hv_propieta "
	loc vhog "hv_miemhabi miembros " 
	loc vreg "reg3 reg4 reg5 reg6 reg7 reg8 reg9 reg10 reg12 reg13 reg14 reg15 reg17 reg18 reg19 reg20 reg22 reg23 reg25 reg26 reg27 reg29 reg30 reg31 reg32 reg33 reg34 reg36 "
	* probit v3 hogar, todo simple, caract jefe
	noi probit pobre_${tprob} `vjefe' `vviv' `vhog' `vreg' , iterate(100)
	estimates save "${pathout}\ster\pr_`base_`i''.ster", replace
	outreg2 using  "${pathout}\outreg_pr_${tprob}.txt", append ctitle("`base_`i''")
	loc col=1
	foreach var of varlist `vjefe' `vviv' `vhog' `vreg' {
		sum `var' [w=pondera] if e(sample)
		mat stat_var_${tprob}[`i',`col']=r(mean)
		loc ++col
	}

}
*/
preserve
drop _all
svmat stat_var_${tprob}
export excel using "${pathout}\stat_var_${tprob}.xlsx", cell(b36) sheetmodify sheet("stat_var_${tprob}")
restore

* exporto outreg a excel
preserve
drop _all
insheet using "${pathout}\outreg_pr_${tprob}.txt"
export excel using "${pathout}\outreg_pr_${tprob}.xlsx", cell(a1) sheetmodify sheet("probit_p${tprob}")
restore

capture erase "${pathout}\outreg_pr_${tprob}.txt"

