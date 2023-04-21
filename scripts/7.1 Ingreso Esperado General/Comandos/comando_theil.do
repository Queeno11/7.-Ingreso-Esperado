capture program drop theil

program define theil, rclass
syntax varlist (max=1 numeric) [iweight] [if]
display "varlist:`varlist'" _newline "varlist_1:`varlist_1'" _newline "weight:`weight'" _newline "exp:`exp'"

quietly {

preserve

*touse=1 -> observación si cumple if & !=.
*touse=0 -> observación no cumple if | !=.

marksample touse
keep if (`touse'==1)

local wt:word 2 of `exp'

if "`wt'" == "" {
	local wt=1
}

summarize `varlist' [`weight' `exp'] if (`varlist'>0)
local media=r(mean)
local income=`media'*r(sum_w)

tempvar each

generate `each'=`varlist'/`media'*ln(`varlist'/`media')
summarize `each' [`weight' `exp']
local theil=r(sum)/r(sum_w)

restore

}

display as text "Theil = " as result `theil'
return scalar theil=`theil'

/*
quietly {

levelsof `varlist_1', local(levels)

foreach i in local levels {

	summarize `varlist' [`weight' `exp'] if (`varlist_1'==`i')
	local income_`i'=r(mean)*r(sum_w)
	local fancy_`i'=ln(r(mean)/`media')
	local tot_`i'=(`income_`i''/`income')*`fancy_`i''

}

local theil_inter=sum(tot_`i')

}

display as text "Theil Intergrupal = " as result `theil_inter'
return scalar theil_inter=`theil_inter'

quietly {

levelsof `varlist_1', local(levels)

foreach i in local levels {

	summarize `varlist' [`weight' `exp'] if (`varlist_1'==`i')
	local media_`i'=r(mean)
	local income_`i'=`media_`i''*r(sum_w)

	tempvar each

	generate `each'=`varlist'/`media_`i''*ln(`varlist'/`media_`i'')
	summarize `each' [`weight' `exp']
	local theil_`i'=r(sum)/r(sum_w)
	
	local tot_`i'=(`income_`i''/`income')*`theil_`i''

}

local theil_intra=sum(tot_`i')

}

display as text "Theil Intragrupal = " as result `theil_intra'
return scalar theil_intra=`theil_intra'
*/

end