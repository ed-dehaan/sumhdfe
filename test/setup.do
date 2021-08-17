// --------------------------------------------------------------------------
// Install sumhdfe
// --------------------------------------------------------------------------
// Note: this do-file is hardcoded to the author's paths and is for internal purposes
	
	cap cd "E:\Dropbox\Work\Programming\active\sumhdfe\test"
	cap cd "C:\Git\sumhdfe\test"

	cap ado uninstall sumhdfe
	mata: st_local("path", pathresolve(pwd(), "..//src"))
	di as text `"Installing sumhdfe from "`path'"'
	net install sumhdfe, from("`path'")

	which sumhdfe


exit


use "C:\Git\sumhdfe\sumhdfe_demo_data.dta", clear
mdesc
	reghdfe y x1 x2 , a(year firm)
gen insample = e(sample)
tab insample
sumhdfe y x1 x2 , a(year firm) keepmissing
asd


* Demo
set trace off
set tracedepth 4
	
	clear all
	cls
	sysuse auto, clear
	bys turn: gen t = _n
	xtset turn t

	reghdfe price weight, a(turn) keepsingletons
	cap noi sumhdfe
	assert c(rc)

	sumhdfe price weight if _n>1, a(turn mpg) stat(N mean min max p50 sd)
	sumhdfe price weight if _n>1, a(turn mpg) format(%8.1fc) varwidth(10)
	sumhdfe price weight if _n>1, a(turn mpg) panels(sum) format(%8.1fc) varwidth(10)

	reghdfe price weight length, a(turn)
	sumhdfe weight mpg, a(turn)

	reghdfe price weight length, a(turn) keepmata
	sumhdfe weight mpg, a(turn)

	reghdfe price weight length, a(turn trunk)
	sumhdfe
	
	sumhdfe price i.rep78, a(turn foreign)

	sumhdfe price i.rep78, a(turn) panels(sum)
	sumhdfe price weight, a(turn##c.length foreign)

	set varabbrev on
	sumhdfe price i.rep78 L(0/3).gear, a(turn) basevars
	sumhdfe price i.rep78 L(0/3).gear, a(turn)
	sumhdfe price i.rep78 L(0/3).gear, a(turn) stat(mean)
	sumhdfe price i.rep78 L(0/3).gear, a(turn) stat(skewness)


	sumhdfe price i.rep78 L(0/3).gear, a(turn trunk foreign) keepmiss

	
	reghdfe price i.rep78, a(turn)
	cap noi sumhdfe price, keepmiss
	assert c(rc)

exit
