* Uninstall any old versions of ftools, reghdfe, sumhdfe
cap ado uninstall ftools     
cap ado uninstall reghdfe     
cap ado uninstall sumhdfe

* Install the most recent version of ftools, reghdfe, and sumhdfe
net install ftools, from("https://raw.githubusercontent.com/sergiocorreia/ftools/master/src/")
net install reghdfe, from("https://raw.githubusercontent.com/sergiocorreia/reghdfe/master/src/")
net install sumhdfe, from("https://raw.githubusercontent.com/ed-dehaan/sumhdfe/master/src/")

* Load data

use "https://raw.githubusercontent.com/ed-dehaan/sumhdfe/master/sumhdfe_demo_data.dta", clear
reghdfe y x1 x2  , a(firm year) 
sumhdfe