*** Create a dataset to use for developing SUMHDFE

*set personal working directory
cd "/Users/edehaan/Dropbox/Work/Research/methods/6. sumhdfe"


clear all
set seed 11234
vers 15

*** set the number of firms
	local n_firms = "100000"
	
*** set the number of firms
	set obs `n_firms'
	gen firm = _n

*** make a firm-specific x
	gen x_firm = rnormal(5,5)
	
*** expand the panel to be unbalanced by date.  
	expand runiform(1,10)
	gen date = floor((mdy(12,31,2020)-mdy(1,1,2000)+1)*runiform() + mdy(1,1,2000))
	format date %tdCCYYNNDD	
	gen year = year(date)
	tab year
	bys firm: egen dates_per_firm = count(date)
	tab dates_per_firm	
		
*** ensure there are at least some date singletons (there must be a more elegent way to do this instead of using a 55 cutoff)
	bys date: egen firms_per_date = count(firm)
	bys firms_per_date: drop if _n > 1 & firms_per_date < 55
	tab firms_per_date	
	
*** generate an x_date variable
	gen x_date = rnormal(5,5)
	bys date: replace x_date = x_date[1]
	
*** calculate x1 x2
	gen x1 = rnormal(5,5) + 15*x_firm + 5*x_date
	gen x2 = rnormal(5,5) - .025*x1
	
	* make 50% of firms with no variation in x1
	bys firm: replace x1 = x1[1] if firm < 0.50*`n_firms'
	
	* make some years have no variation in x2
	bys year: replace x2 = x2[1] if year == 2008 | year == 2009
	

*** generate Y
	gen y = 5*x1 + 5*x2 + 15*x_firm + 5*x_date + rnormal(0,100)
	sum
	
	save sumhdfe_data, replace	
	
	reghdfe y x1 x2, a(firm date)
	gen insample=1 if e(sample)
	reghdfe y x1 x2, noa

