qui {
	drop _all

	loc base_1  "ARG_2003_s2"
	loc base_2  "ARG_2004_s1"
	loc base_3  "ARG_2004_s2"
	loc base_4  "ARG_2005_s1"
	loc base_5  "ARG_2005_s2"
	loc base_6  "ARG_2006_s1"
	loc base_7  "ARG_2006_s2"
	loc base_8  "ARG_2007_s1"
	loc base_9  "ARG_2007_s2"
	loc base_10 "ARG_2008_s1"
	loc base_11 "ARG_2008_s2"
	loc base_12 "ARG_2009_s1"
	loc base_13 "ARG_2009_s2"
	loc base_14 "ARG_2010_s1"
	loc base_15 "ARG_2010_s2"
	loc base_16 "ARG_2011_s1"
	loc base_17 "ARG_2011_s2"
	loc base_18 "ARG_2012_s1"
	loc base_19 "ARG_2012_s2"
	loc base_20 "ARG_2013_s1"
	loc base_21 "ARG_2013_s2"
	loc base_22 "ARG_2014_s1"
	loc base_23 "ARG_2014_s2"
	loc base_24 "ARG_2015_s1"

	loc base_25 "ARG_2016_s1"
	loc base_26 "ARG_2016_s2"
	loc base_27 "ARG_2017_s1"
	loc base_28 "ARG_2017_s2"
	loc base_29 "ARG_2018_s1"
}

forvalues i =1/29 {
	drop _all
	noi di "i `i'"
	noi use "${pathd}\\`base_`i''_mi_hd_sedlac_03.dta"
	qui include "${pathw}\do\01a_variables_censo.doi"
	noi probit pobre_mod edad edad2 edad1217 edad1824 edad2540 edad4164 edad65 pric seci secc supi supc hv_* miembros miembros2 jj_* jefe reg3 reg4 reg5 reg6 reg7 reg8 reg9 reg10 reg12 reg13 reg14 reg15 reg17 reg18 reg19 reg20 reg22 reg23 reg25 reg26 reg27 reg29 reg30 reg31 reg32 reg33 reg34 reg36
	noi estimates save "${pathw}\out\ster\probit_t1_base_`i'", replace
}

