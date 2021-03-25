*SUMHDFE

*cd "/Users/edehaan/Dropbox/Work/Research/methods"
cd "E:\Dropbox\Work\Programming\active\SUMHDFE\dontsync"

******************************************	
	
*** SUMHDFE
	
	clear all 
	use sumhdfe_data
	
	* dummy command
*	SUMHDFE [set of regressors y, x1, etc], a(fe1 fe2) stats(other summary statistics)
	
	reghdfe y x1 x2, a(firm year)
	sumhdfe
	
	sumhdfe y x1 x2, a(firm year) stats(n mean median sd)
	

	
	
	
	
	
	
	
	
	
	
	
	
	
