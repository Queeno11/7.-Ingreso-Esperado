*===================================================================*
* Centro de Esutdios Distributivos, Laborales y Sociales (CEDLAS)   *
* Departamento de Economia                                          *
* Universidad Nacional de La Plata                                  *
*-------------------------------------------------------------------*
* MEDIDAS DE POBREZA                                                *
* Martín Cicowiez                                                   *
* martin@depeco.econo.unlp.edu.ar                                   *
* Leonardo Gasparini                                                *
* leonardo@depeco.econo.unlp.edu.ar                                 *
* 22-11-2002                                                        *
* 26-03-2004                                                        *
* 16-01-2005                                                        *
* 09-02-2005                                                        *
* 13-04-2005                                                        *
* 20-03-2006                                                        *
*===================================================================*

* Sintaxis:
*  [by varlist:] fgt varname [fweight] [if exp], Alfa(real) Zeta(string) [bs] [Reps(#)] [Dots] [SAving(filename)] [replace]

* Ejemplo:
*  by aglomera: fgt ipcf if ipcf>0 [w=pondera], a(0) z(150) bs reps(100) dots saving(resultados_bs.dta) replace

capture program drop fgt

program define fgt, rclass byable(recall)
  version 8.0
  syntax varlist(max=1) [fweight] [if], Alfa(real) Zeta(string) [Reps(passthru)] [SAving(passthru)] [replace] [Dots] [bs]
  
* CONTROL SINTAXIS ++++++++++++++++++++++++++++++++++++++++++++++++++                                             

  if "`bs'" == "" {
    if "`reps'" != "" {
      display as error "Option reps not allowed without option bs"
      exit 198
    }
    if "`saving'" != "" {
      display as error "Option saving not allowed without option bs"
      exit 198
    }
    if "`replace'" != "" {
      display as error "Option replace not allowed without option bs"
      exit 198
    }
    if "`dots'" != "" {
      display as error "Option dots not allowed without option bs"
      exit 198
    }
  }

/*
  display "varlist = `varlist'"
  display "     if = `if'"
  display " weight = `weight'"
  display "    exp = `exp'"
  display "   alfa = `alfa'"
  display "   zeta = `zeta'"
  display "   reps = `reps'"
  display " saving = `saving'"
  display "replace = `replace'"
  display "   dots = `dots'"
  display "     bs = `bs'"  
*/
  
  quietly {

    tempvar sirve each

* OBSERVACIONES A USAR ++++++++++++++++++++++++++++++++++++++++++++++

    * pone un 1 en sirve si se cumple el if
    * si `if' está vacio sirven todas
    mark `sirve' `if' 
    * le quita el 1 a sirve si `1' es missing
    markout `sirve' `1'
    
    summ `varlist' [`weight'`exp'] if `sirve' == 1
    local pob_ref = r(sum_w)

    local wt : word 2 of `exp'
    if "`wt'"=="" {
      local wt = 1
    }

* CALCULO FGT +++++++++++++++++++++++++++++++++++++++++++++++++++++++

    capture confirm numeric variable `zeta'
    * noi display _rc
    * zeta es variable numerica
    if _rc==0 {
      * noi display "**** fgt usando variable como lp ****"
    }
    else {
      * noi display "**** fgt usando escalar como lp ****"
      capture local zeta = scalar(`zeta')
      local aux_control=real("`zeta'")
      if `aux_control'==. {
        noi display as error "linea de pobreza mal especificada"
        exit 198
      }
    }

    gen `each' = `wt' * ( 1 - `varlist' / `zeta' ) ^ `alfa' if `varlist' < `zeta' & `sirve' == 1
    summ `each' if `sirve' == 1

    local fgt = (r(sum)/`pob_ref')*100
    local nro_pobres = r(sum)
    
  }

* MUESTRA RESULTADOS ++++++++++++++++++++++++++++++++++++++++++++++++

  display _newline as text "fgt(alfa=`alfa',zeta=`zeta') `varlist' = " as result %4.2f `fgt'
  return scalar fgt = `fgt'
  
  * si el programa fue invocado con by guardo los fgt calculados usando scalar
  * notas:
  * la funcion _by() vale 1 si el programa fue invocado con by
  * la macro local _byvars me dice cual variable se uso en by
  * la funcion _byindex() me dice el numero de INDICE actual (1,2,...) 
  if _by()==1 {

    * obtengo el número de grupo
    local which_index=_byindex()

    * guardo fgt para el grupo actual
    scalar fgt_`_byvars'`which_index' = `fgt'  

    * devuelvo el numero de grupo actual
    * funciona porque finalmente se muestra el ultimo
    return scalar numero_grupos = `which_index'
  }

  if `alfa'==0 {
    display _newline as text "nro_pobres = " as result `nro_pobres' _newline /*
    */               as text "pob_ref    = " as result `pob_ref'
    return scalar nro_pobres = `nro_pobres'
    return scalar pob_ref    = `pob_ref'
  }
  
* BOOTSTRAP +++++++++++++++++++++++++++++++++++++++++++++++++++++++++

  * ojo! si no hay observaciones para el bootstrap no lo hace
  if "`bs'" != "" & `pob_ref' !=0 {
    display _newline as text "Bootstraping..."
    preserve
    keep if `sirve' == 1
    bs "hacebs_fgt `varlist', z(`zeta') a(`alfa') w(`wt')" "r(fgt)", `reps' `saving' `replace' `dots' nowarn
    
    tempname aux1 aux2
    matrix `aux1' = e(ci_bc)
    return scalar ci_bc_ll = `aux1'[1,1]
    return scalar ci_bc_ul = `aux1'[2,1]
    matrix `aux2' = e(se)
    return scalar se = `aux2'[1,1]
    
    restore
  }
  
end
  


capture program drop hacebs_fgt

program define hacebs_fgt, rclass
  version 8.0
  syntax varlist(max=1), Alfa(real) Zeta(string) [Weight(string)]

/*
  display "varlist = `varlist'"
  display " weight = `weight'"
*/

  local wt="`weight'"

  summ `varlist' [w=`wt']
  local pob_ref = r(sum_w)

  tempvar each

  gen `each' = `wt' * ( 1 - `varlist' / `zeta' ) ^ `alfa' if `varlist' < `zeta' 
  summ `each' 

  local fgt = (r(sum)/`pob_ref')*100

  return scalar fgt = `fgt'
end






