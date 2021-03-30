clear all
cls

sysuse auto
reghdfe price weight length, a(turn trunk) 
sumhdfe // price weight



sysuse nlsw88.dta
drop if grade>5
gen byte c = 1

reghdfe wage grade c.tenure##c.tenure i.race [fw=c], a(industry) nofvlabel base
set trace off
sumhdfe wage i.race


reghdfe wage grade c.tenure##c.tenure, a(occupation) vce(robust)
sumhdfe


reghdfe wage grade c.tenure##c.tenure i.race, a(industry) vce(robust)
sumhdfe

* -- ERROR case #1 --

* CODE:
reghdfe wage i.grade##c.industry, a(industry) vce(robust)
set trace off
sumhdfe 

* ERROR MSG:
*   summarize_variation():  3301  subscript invalid
*                 <istmt>:     -  function returned error
*

* -- ERROR case #2 --

* CODE:
*sumhdfe wage grade c.tenure##c.tenure, a(occupation) vce(robust) hist(2) // there is only one absvar
sumhdfe wage grade c.tenure##c.tenure [fw=c], a(occupation) vce(robust)

* ERROR MSG:
*
*          fe_histogram():  3301  subscript invalid
*                 <istmt>:     -  function returned error
*





* ERROR 3:
cap noi sumhdfe price weight // no a()



* ERROR 4:
* DOUBLE CHECK THAT FACTOR VARIABLES ARE NOT MAKING OUR RESULTS END UP IN THE WRONG ROW


