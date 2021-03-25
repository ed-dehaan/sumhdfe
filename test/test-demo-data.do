*cscript "sumhdfe simple case" adofile sumhdfe


// --------------------------------------------------------------------------
// Load dataset
// --------------------------------------------------------------------------

	use "../sumhdfe_demo_data.dta", clear
	compress
	save, replace


// --------------------------------------------------------------------------
// Verify it runs
// --------------------------------------------------------------------------
	
	sumhdfe y x1, a(year firm i.fe3##c.x3) varwidth(20)




exit
// --------------------------------------------------------------------------
// sumhdfe call
// --------------------------------------------------------------------------

	reghdfe price weight length, a(turn trunk#foreign)
	sumhdfe
	return list
	gen byte sample = e(sample)
	matrix rss = r(rss)
	loc pooled_sd = rss["price", 1]
	loc within_sd = rss["price", 2]
	loc r2_fe1 =  rss["price", 4]
	loc r2_fe2 =  rss["price", 5]
	loc r2_overall =  rss["price", 6]

	foreach stat in pooled_sd within_sd r2_fe1 r2_fe2 r2_overall {
		di as text "`stat' = ``stat''"
	}


// --------------------------------------------------------------------------
// Manually construct objects
// --------------------------------------------------------------------------

	* 1) Pooled SD
	su price
	assert reldif(`pooled_sd', r(sd)) < 1e-12

	* 2) Within SD
	qui areg price i.turn if sample, a(fe2) // I don't want to use reghdfe in case that's where the error is
	predict double resid if sample, resid
	su resid
	assert reldif(`within_sd', r(sd)) < 1e-12

	* R2 wrt FE1
	qui areg price, a(turn)
	assert reldif(`r2_fe1', e(r2)) < 1e-12

	* R2 wrt FE2
	qui areg price, a(fe2)
	assert reldif(`r2_fe2', e(r2)) < 1e-12

	* Overall R2
	qui areg price i.turn, a(fe2) // I don't want to use reghdfe in case that's where the error is
	assert reldif(`r2_overall', e(r2)) < 1e-12


exit
