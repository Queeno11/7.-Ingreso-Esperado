*===================================================================*
* Centro de Esutdios Distributivos, Laborales y Sociales (CEDLAS)   *
* Departamento de Economia                                          *
* Facultad de Ciencias Economicas                                   *
* Universidad Nacional de La Plata                                  *
*-------------------------------------------------------------------*
* INDICE DE THEIL                                                   *
* Martín Cicowiez                                                   *
* martin@depeco.econo.unlp.edu.ar                                   *
* Leonardo Gasparini                                                *
* leonardo@depeco.econo.unlp.edu.ar                                 *
* ===================================================================*

capture program drop theil

* Sintaxis:
*  theil varlist [if exp] [weight]
* Ejemplo:
*  theil ipcf if ipcf>0 [w=pondera]

program define theil, rclass byable(recall)
  version 8.0
  syntax varlist(max=1) [if] [fweight] 
  tokenize `varlist'

  quietly {
  
    preserve

    * pongo un 1 en touse si se cumple el if
    * si `if' está vacio sirven todas
    marksample touse 
    * le quito el 1 a sirve si `1' es missing
    markout `touse' `1'
    count if `touse'==1
    * en la macro local N guardo el numero de observaciones que sirven
    local N = r(N)
    
    keep if `touse' == 1

    local wt : word 2 of `exp'
    if "`wt'"=="" {
      local wt = 1
    }

    summarize `1' [`weight'`exp'] in 1/`N'
    * media
    local media=r(mean)
    * poblacion de referencia
    local obs=r(sum_w)
    * desvio estandar
    local std=r(sd)

    tempvar suma 
    gen `suma'=.
    replace `suma' = sum(`wt'*(`1'/`media')*ln(`1'/`media')) in 1/`N'
    local theil = (1/`obs')*`suma'[`N']
    return scalar theil = `theil'

    restore
  }    

  * si el programa fue invocado con by...
  * notas:
  * funcion _by() vale 1 si el programa fue invocado con by
  * macro local _byvars me dice cual variable se uso en by
  * funcion _byindex() me dice numero de INDICE actual (1,2,...) 
  if _by()==1 {
    * obtengo el número de grupo
    local which_index=_byindex()
    * guardo theil para el grupo actual
    scalar theil_`_byvars'_`which_index' = `theil'  
    return scalar numero_grupos = `which_index'
  }

 display
 display in yellow "Indice de Theil=   " `theil'

end




