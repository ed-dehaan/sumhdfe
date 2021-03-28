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

1) The first panel shows summary statistics (similar to `estat summarize`) which can be customized:

<img src="https://user-images.githubusercontent.com/74987960/112763970-80f30a80-8fbb-11eb-91c7-67072f0f7da5.png" width="750">


![image](https://user-images.githubusercontent.com/214056/112561652-02744e00-8dac-11eb-891e-271c4c57b240.png)

2) The second panel shows summary statistics of the _fixed effects_ themselves:

<img src="https://user-images.githubusercontent.com/74987960/112763985-91a38080-8fbb-11eb-8ac5-d05e2f578ca9.png" width="750">


For instance, you can see that there are 18 different groups of the _turn_ fixed effect, and that four of those are singletons (appear only once).

3) The third panel how often each variable is constant within a given group (such as a given year, firm, etc.). These observations can have unexpected effects on regression coefficients and, if numerous, should be carefully considered.

<img src="https://user-images.githubusercontent.com/74987960/112763999-9bc57f00-8fbb-11eb-8297-20275a901aab.png" width="750">


4) The fourth panel shows how much variation of the dependent variable and the regressors is lost (or absorbed) due to the fixed effects.

<img src="https://user-images.githubusercontent.com/74987960/112764014-a718aa80-8fbb-11eb-8651-e85693d423e0.png" width="750">


In this example, even though the R2 was quite high (0.46 excluding singleton observations, 0.54 including them), most of this is due to the fixed effects, which have an R2 of 0.49.

5) The `histogram(#)` option tabulates the frequencies of observations within a fixed effect grouping. For example, `sumhdfe, histogram(1)` shows the frequencies of observations for the first fixed effect grouping listed within `a(firm year)`, which in this case if firm:

<img src="https://user-images.githubusercontent.com/74987960/112764325-d2e86000-8fbc-11eb-8108-6056e00656b5.png" width="500">


For additional examples and additional options, see the stata help file with `help sumhdfe`, or its [online version](http://scorreia.com/help/sumhdfe.html).


## Pending Items

1. Allow for easy export of each table to csv/excel/tex
2. Tutorial/documentation with real-world example


## Changelog

(will be added as new versions are posted)

## Questions and bug reports

If you have questions or experience problems please use the [issues](https://github.com/ed-dehaan/sumhdfe/issues) tab of this repository.
