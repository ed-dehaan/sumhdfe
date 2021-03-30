* ===========================================================================
* Test advanced histogram options
* ===========================================================================

clear all
cls

sysuse auto
sumhdfe price weight, a(turn trunk#foreign) histogram(2, nodraw)
sumhdfe price weight, a(turn trunk#foreign) histogram(1, percent)
sumhdfe price weight, a(turn trunk#foreign) histogram(trunk#foreign, nodraw)

* FE does not exist
cap noi sumhdfe price weight, a(turn trunk#foreign) histogram(trunk)
assert c(rc)

* conflicting options
cap noi sumhdfe price weight, a(turn trunk#foreign) histogram(1, percent fraction)
assert c(rc)

* only one FE allowed
cap noi sumhdfe price weight, a(turn trunk#foreign) histogram(1 2)
assert c(rc)

* Complex call
sumhdfe price weight, a(turn trunk#foreign) histogram(turn, frac subtitle("Some subtitle") lcolor(red) fcolor(red%50) scheme(s1color))
