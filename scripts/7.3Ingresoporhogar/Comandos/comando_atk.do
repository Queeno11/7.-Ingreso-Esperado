capture program drop atk

program define atk, rclass
syntax varlist (max=1 numeric) [iweight] [if], Epsilon(real)
display "varlist:`varlist'" _newline "weight:`weight'" _newline "exp:`exp'"

quietly {

preserve

*touse=1 -> observación si cumple if & !=.
*touse=0 -> observación no cumple if | ==.

marksample touse 
keep if (`touse'==1)

local wt:word 2 of `exp'

if "`wt'" == "" {
	local wt=1
}

summarize `varlist' [`weight' `exp'] if (`varlist'>0)
local media=r(mean)
local obs=r(sum_w)
capture drop each

	*Epsilon==1*

	if `epsilon'==1 {
    generate each=ln(`varlist'/`media')
	summarize each [`weight' `exp']
	local atk=1-exp(1/`obs'*r(sum))
	}

	*Epsilon!=1*

	else {
    generate each=(`varlist'/`media')^(1-`epsilon')
	summarize each [`weight' `exp']
	local atk=1-(r(sum)/`obs')^(1/(1-`epsilon'))
	}

restore

}

display as text "Atkinson (e=`epsilon') = " as result `atk'
return scalar atk=`atk'

end