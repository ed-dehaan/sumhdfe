*! version 0.0.1 29jan2021

* use "E:\Dropbox\Work\Programming\active\SUMHDFE\dontsync\sumhdfe_data.dta"
* sumhdfe y x1 x2, absorb(firm year)

program sumhdfe, eclass
	di as text "The SUMHDFE command is running!"
	syntax anything(name=iv_cmd) [if], [Absorb(string)] [VCE(string)] [Verbose(string)] [stats(string)] [ * ]
	_iv_parse `iv_cmd'
    local depvar `s(lhs)'
    local exog `s(exog)'

	local reghdfe_opts "absorb(`absorb') vce(`vce') verbose(`verbose') `options'"
	
	*reghdfe `depvar' `exog' `if', `reghdfe_opts'
	
	
	* Get estimates
	
	capture {
	
		* get within FE standard deviations of each variable. save singletons number
		local sing_vars
		foreach v of varlist `depvar' `exog' {
			reghdfe `v', `reghdfe_opts' res(`v'_resid)
			gen `v'_sing = e(num_singletons)	
			local sing_vars `sing_vars' `v'_sing	
		}
		
		* calculate zero-var FE units.  do the following for each FE specification
		local novar_fe_vars
		foreach av of varlist `absorb' {
			local novar_fe_vars_`av'
			foreach v of varlist `depvar' `exog' {
				bys `av': egen `v'_sd = sd(`v')
				replace `v'_sd = 0 if `v'_sd == .
				gen `v'_novar_fe_`av' = 0
				replace `v'_novar_fe_`av' = 1 if `v'_sd == 0
				drop `v'_sd
				local novar_fe_vars_`av' `novar_fe_vars_`av'' `v'_novar_fe_`av'
			}	
		}
	}

	* get the regular summary statistics that you want (options in command for this would be useful)
	
	di as text "The regular summary statistics:"
	tabstat `depvar' `exog' , stat(`stats') c(s)
	
	* column of singleton counts for each regressor
	di as text "The singleton statistics:"
	tabstat `sing_vars', stat(mean) c(s)
	
	* obs for FE groups that have no variation in variable
	foreach av of varlist `absorb' {
		di as text "The stats for the group: `av'"
		tabstat `novar_fe_vars_`av'', stat(sum) c(s)
		drop `novar_fe_vars_`av''
	}
	
	* residual standard deviation
	
	local resid_vars
	foreach v of varlist `depvar' `exog' {
		local resid_vars `resid_vars' `v'_resid
	}
	di as text "The residual standard deviation:"
	tabstat `resid_vars' , stat(sd) c(s)
	
	* drop variables
	drop `resid_vars' `sing_vars'
	
	timer off 1
	timer list 1	
	

end

exit

* to avoid line issues.

