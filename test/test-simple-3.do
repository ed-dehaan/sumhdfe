clear all
cls

sysuse auto
clonevar www=weight


reghdfe price ibn.rep78 weight www, a(turn)
sumhdfe

reghdfe price i.rep78 weight www, a(turn)
sumhdfe

