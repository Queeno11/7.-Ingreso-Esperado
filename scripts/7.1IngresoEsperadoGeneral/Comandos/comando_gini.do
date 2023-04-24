capture program drop gini

program define gini, rclass
syntax varlist (max=1 numeric) [iweight] [if]
display "varlist:`varlist'" _newline "weight:`weight'" _newline "exp:`exp'"

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
local obs=r(sum_w)

sort `varlist'

tempvar tmptmp i tmp

generate `tmptmp'=sum(`wt') if (`varlist'>0)
generate `i'=(2*`tmptmp'-`wt'+1)/2 
generate `tmp'=`varlist'*(`obs'-`i'+1)
summarize `tmp' [`weight' `exp'] 
local gini=1+(1/`obs')-(2/(`media'*`obs'^2))*r(sum)

restore

}

display as text "Gini = " as result `gini'
return scalar gini=`gini'

end