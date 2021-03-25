
*** DEMO DATASET FOR SUMHDFE

*** properties;
	* unbalanced panel dataset of consecutive firm-years
	* singletons by year & firm, and joint singletons
	* some observations have no variation within each of year and firm
	* not all variables have same number of observations



cd "/Users/edehaan/Dropbox/Work/Research/methods/6. sumhdfe"


clear all
set seed 11234
vers 16

*** set the number of firms
	local n_firms = "200"
	
*** set the number of firms
	set obs 200
	gen firm = _n

*** make a firm-specific x
	gen x_firm = rnormal(5,5)
	
*** expand the panel to be unbalanced by date.
	gen year = round(rnormal(2010,6))
	expand runiform(1,3)
	sort firm
	
	bys firm: gen year2 = _n - 1
	replace year = year + year2
	drop year2
	
	* make more singletons
	bys year: drop if _n > 2 & year < 2002
	bys year: drop if _n > 2 & year > 2018
	
	tab year
	bys firm: egen years_per_firm = count(year)
	tab years_per_firm		
	bys year: egen firms_per_year = count(firm)
	tab firms_per_year	


	
*** generate an x_date variable
	gen x_year = rnormal(5,5)
	bys year: replace x_year = x_year[1]
	
*** calculate x1 x2 and another FE
	gen x1 = rnormal(5,5) + 15*x_firm + 5*x_year
	gen x2 = rnormal(5,5) - .025*x1
	gen x3 = rnormal(5,5)
	gen fe3 = round(runiform(1,4))
	
	* make 20% of firms with no variation in x1
	gen rand = runiform(0,10)
	bys firm: replace rand = rand[1]
	bys firm: replace x1 = x1[1] if rand < 2
	drop rand

	* make some years have no variation in x1
	gen rand = runiform(0,10)
	bys year: replace rand = rand[1]
	bys year: replace x1 = x1[1] if rand < 1.5
	drop rand	
	

*** generate Y
	gen y = 5*x1 + 5*x2 + 15*x_firm + 5*x_year + rnormal(0,100)
	sum
	
*** set some missing x2
	replace x2 = . if runiform(0,10) <= 2

	
	
*** tsset	
	xtset firm year, yearly
	

*** save
	drop x_firm x_year firms_per_year years_per_firm
	save "/Users/edehaan/Dropbox/Work/Research/methods/6. sumhdfe/sumhdfe_demo_data.dta", replace


*** test
	reghdfe y x1 l.x1 i.fe3, a(firm)
	sumhdfe
	sumhdfe, basev
	
	sumhdfe y x1 l.x1 i.fe3, a(firm) keepmissing

	
