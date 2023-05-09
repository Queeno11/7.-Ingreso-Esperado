drop _all



use "${pathdpe}\censo2010\predict_censo_min_max.dta"

keep link persona_ref_id hogar_ref_id vivienda_ref_id radio_ref_id frac_ref_id dpto_ref_id prov_ref_id id com
merge 1:1 id com using "${pathdpe}\censo2010\pobre_censo.dta"


keep link persona_ref_id hogar_ref_id vivienda_ref_id radio_ref_id frac_ref_id dpto_ref_id prov_ref_id pobre_estruct
ren pobre_estruct pc
label var pc ""
compress
save "${pathdpe}\censo2010\base_censo_pc.dta", replace


