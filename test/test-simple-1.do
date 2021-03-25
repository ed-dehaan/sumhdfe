clear all
pr drop _all
set trace off
cls

/*local devDir "E:\Dropbox\Work\Programming\active\sumhdfe"

cap ado uninstall reghdfe
net install reghdfe, from("`devDir'\reghdfe")

* Note: make sure there is no old ado file called sumhdfe in any of your ado directories, doesn't get auto uninstalled if placed manually.

cap ado uninstall sumhdfe
net install sumhdfe, from("`devDir'\src")

* If the compiled version of reghdfe is installed, it's Mata functions will take precedence over the new ones and cause trouble
cap noi findfile lreghdfe.mlib
if (!c(rc)) erase "`r(fn)'"
*/

sysuse auto,clear
replace price = 7123 if turn==43 // price will have the same value when turn==43
replace price = 8765 if turn==40


* 1) Follow-up syntax
reghdfe price weight length, a(turn trunk#foreign)
set trace off
sumhdfe

reghdfe price weight length, a(turn)
sumhdfe

* 2) Follow up with forethought (saves time but uses more memory)
reghdfe price weight length, a(turn) keepmata
sumhdfe

* 3) Standalone syntax
sumhdfe price weight length, a(turn)

* 4) Histogram
sumhdfe price weight length, a(turn trunk) hist(2)

* 5) Corner cases
gen dropit = turn
sumhdfe price weight dropit, a(turn)


*******
*example
rename turn firm
rename trunk year
reghdfe price weight length, a(firm year)
sumhdfe
