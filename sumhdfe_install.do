
*** this do file will install the latest developer versions of ftools, reghdfe, and sumhdfe.  
*** Sumhdfe will not work with the live version of reghdfe currently on ssc.


* uninstall previous versions
cap ado uninstall ftools
cap ado uninstall reghdfe
cap ado uninstall sumhdfe

* install latest
net install ftools, from("https://raw.githubusercontent.com/sergiocorreia/ftools/groupreg/src/")
net install reghdfe, from("https://raw.githubusercontent.com/sergiocorreia/reghdfe/reghdfe6/src/")
net install sumhdfe, from("https://raw.githubusercontent.com/ed-dehaan/sumhdfe/master/src/"")
