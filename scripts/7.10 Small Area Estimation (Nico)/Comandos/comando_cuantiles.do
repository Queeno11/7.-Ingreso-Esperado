capture program drop cuantiles

program define cuantiles
syntax varlist (max=1 numeric) [iweight] [if], Ncuantiles(integer) Orden_aux(namelist) Generate(namelist)
display "varlist:`varlist'" _newline "weight:`weight'" _newline "exp:`exp'"

quietly {

tokenize `varlist'

*touse=1 -> observación si cumple if & !=.
*touse=0 -> observación no cumple if | ==.

marksample touse

local wt:word 2 of `exp'

if "`wt'" == "" {
	local wt=1
}

*Variables temporales*
tempvar myvar shrpop popwt

*Hacer copia de `1'*
generate `myvar'=`1'
replace `myvar'=. if (`touse'!=1)

*Ordenar por `1'*
sort `myvar', stable
generate `popwt'=`wt'
replace `popwt'=0 if (`touse'!=1)

*Computar porcentaje acumulado población*
generate double `shrpop'=sum(`popwt')
replace `shrpop'=`shrpop'/`shrpop'[_N]

*Share de la encuesta que percenece a cada cuantil (por ejemplo, 20% si ncuantiles=5)*
local shrcuantil=1/`ncuantiles'

*Nombre de variable a generar con número de cuantil para cada observación*
local cuantil="`generate'"

*Identificar cuantiles de `1'*
generate `cuantil'=.
forvalues i=1(1)`ncuantiles' {
	replace `cuantil'=`i' if (`shrpop'>(`i'-1)*`shrcuantil' & `shrpop'<=`i'*`shrcuantil' & `myvar'!=.)
}

}
  
*Mostrar descripción cuantiles*
*tabulate `cuantil' [`weight'`exp'], sum(`1')
 
end