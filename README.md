# sumhdfe: summaries and diagnostics of fixed effect models

Sumhdfe is a Stata package that produces summary and diagnostic information of linear fixed effect models. It characterizes the frequency of fixed effects, how many groups (e.g., firms) have no variation within fixed effects, and the residual within-fixed-effect variation of the regression variables. **It is currently in beta version, so all comments and suggestions are welcome.**

For a discussion of within-fixed-effect variation, and the underlying issues that sumhdfe addresses, see [deHaan (2021)](https://papers.ssrn.com/sol3/papers.cfm?abstract_id=3699777). Similarly, if you find these diagnostics to be useful, please cite:

> deHaan, Ed. (2021). *Using and Interpreting Fixed Effects Models*. Available at SSRN: https://ssrn.com/abstract=3699777.


## Authors

- [Sergio Correia](http://scorreia.com/)
- [Ed deHaan](https://foster.uw.edu/faculty-research/directory/ed-dehaan/)
- [Ties de Kok](http://www.TiesdeKok.com)


## Table of contents

- [Installation](#installing-sumhdfe) 
- [Usage & Features](#usage--features)
- [Pending Items](#pending-items)
- [Changelog](#changelog)
- [Questions?](#questions-and-bug-reports)


## Installing sumhdfe

To install sumhdfe, you also need the latest development versions of [`reghdfe`](http://scorreia.com/software/reghdfe/) and [`ftools`](https://github.com/sergiocorreia/ftools/):

```stata
cap ado uninstall ftools
cap ado uninstall reghdfe
cap ado uninstall sumhdfe

net install ftools, from("https://raw.githubusercontent.com/sergiocorreia/ftools/groupreg/src/")
net install reghdfe, from("https://raw.githubusercontent.com/sergiocorreia/reghdfe/reghdfe6/src/")
net install sumhdfe, from("https://raw.githubusercontent.com/ed-dehaan/sumhdfe/master/src/")
```

## Usage & Features

### Example usage

The following runs reghdfe, and then sumhdfe as a postestimation command. See the Stata help file for additional examples:
```stata
use "https://raw.githubusercontent.com/ed-dehaan/sumhdfe/master/sumhdfe_demo_data.dta", clear
reghdfe y x1 x2  , a(firm year) 
sumhdfe
```

Or, sumhdfe standalone produces the same results, but without the regression:
```stata
use "https://raw.githubusercontent.com/ed-dehaan/sumhdfe/master/sumhdfe_demo_data.dta", clear
sumhdfe y x1 x2  , a(firm year) 
```




The reghdfe results are as usual:

<img src="https://user-images.githubusercontent.com/74987960/112763530-a8e16e80-8fb9-11eb-89a3-7c0afcd0bc70.png" width="750">


The sumhdfe results are composed of four panels:

1) Panel A shows summary statistics for the sample used in reghdfe, and can be customized similar to `estat summarize`. N includes singletons so differs from the reghdfe output above:

<img src="https://user-images.githubusercontent.com/74987960/112763970-80f30a80-8fbb-11eb-91c7-67072f0f7da5.png" width="750">


2) Panel B shows summary statistics for the _fixed effects_ themselves. 

<img src="https://user-images.githubusercontent.com/74987960/112763985-91a38080-8fbb-11eb-8ac5-d05e2f578ca9.png" width="750">

In this example, there are 189 unique firms within the _firm_ fixed effects, 28 of which are singletons (i.e., appear just once). An individual firm has between 1 and 8 observations. There are 39 unique years within the _year_ fixed effects, 8 of which are singletons. Iteratively dropping singletons eliminates additional 2 observations, for a total of 38 singletons eliminated from the reghdfe output.

3) Panel C quantifies how often each variable is constant within a given fixed effect group (such as within a given firm). These observations can have unexpected effects on regression coefficients and, if numerous, should be carefully evaluated.

<img src="https://user-images.githubusercontent.com/74987960/112763999-9bc57f00-8fbb-11eb-8297-20275a901aab.png" width="750">

This example shows that variable x1 has (623-38=) 585 observations excluding singletons. Within the non-singleton data, 58 firms have no variation in x1; i.e., each firm has the same x1 in all years. Those 58 firms relate to 217 observations. X1 is constant within 4 years, relating to 28 observations.

4) Panel D shows how much variation of the dependent variable and the regressors is lost (or absorbed) due to the fixed effects, in terms of both standard deviations and r-squared:

<img src="https://user-images.githubusercontent.com/74987960/112764014-a718aa80-8fbb-11eb-8651-e85693d423e0.png" width="750">

The standard deviation of x1 is 79.7 in the pooled sample (as also showed in Panel A), but the within-fixed-effect standard deviation of x1 is just 22.7. Thus, the within-fixed effect variation of x1 is roughly 28% of the pooled sample. 

In terms of r-squared, the firm fixed effects explain roughly 87% of the variation in x1 while the year fixed effects explain roughly 13%. Combined, the fixed effects explain 92.4% of the variation in x1. 
--> technial note: r-squared are relative to the sample including singletons, for which r-squared is mechanically equal to 100%.




5) The `histogram(#)` option tabulates the frequencies of observations within a fixed effect grouping. For example, `sumhdfe, histogram(1)` shows the frequencies of observations for the first fixed effect grouping listed within `a(firm year)`, which in this case if firm:

<img src="https://user-images.githubusercontent.com/74987960/112764325-d2e86000-8fbc-11eb-8108-6056e00656b5.png" width="500">


For additional examples and additional options, see the stata help file with `help sumhdfe`, or its [online version](http://scorreia.com/help/sumhdfe.html).


## Pending Items

1. Allow for easy export of each table to csv/excel/tex
2. Tutorial/documentation with real-world example
3. Add an option to visually compare the pooled- and within-fixed-effect variation in a variable. In the meantime, it can be manually done as follows:

```stata
use "https://raw.githubusercontent.com/ed-dehaan/sumhdfe/master/sumhdfe_demo_data.dta", clear
qui: reghdfe y x1 x2, a(firm year)
qui: reghdfe x1 if e(sample), a(firm year) resid
twoway (histogram x1, fcolor(green%75) lcolor(none)) (histogram _reghdfe_resid, ///
fcolor(navy%70) lcolor(none)), legend(on order(1 "x1" 2 "within-FE x1"))
```
<img src="https://user-images.githubusercontent.com/74987960/112765144-ae8e8280-8fc0-11eb-8723-8ce0758515e8.png" width="500">



## Changelog

(will be added as new versions are posted)

## Questions and bug reports

If you have questions or experience problems please use the [issues](https://github.com/ed-dehaan/sumhdfe/issues) tab of this repository.
