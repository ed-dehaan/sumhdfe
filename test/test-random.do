* Randomize the sample a bit, for more exhaustive testing

cls
clear all

sysuse auto
clonevar www=weight
set seed 345426

forval rep=1/10 {
    di as text "rep=`rep'"
	preserve
	keep if runiform() > 0.4
	cap reghdfe price weight i.trunk ibn.foreign 231.disp www length, a(turn) 
	if (c(rc)) {
	    restore
		continue
	}
	cap qui sumhdfe // i.trunk ibn.foreign weight 
	if (c(rc)) {
	    restore, not
		error 99
	}
	else {
	    restore
	}
}
