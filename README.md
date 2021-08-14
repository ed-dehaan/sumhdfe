<h1 align="left">
   <img src="https://i.imgur.com/krmdzHa.png" alt="sumhdfe" title="sumhdfe" />
</h1>

**Sumhdfe** is a Stata package that produces summary and diagnostic information of linear fixed effect models. 

You can use `sumhdfe` to:

- Check the frequency of fixed effects
- Check the number of groups that have no variation within fixed effects 
- Check the residual within-fixed-effect variation of the regression variables
- Generate publication-ready Word and Latex tables for all fixed-effects diagnostics

***Sumhdfe is currently in beta version and we welcome comments and suggestions in the `issue` tab!***

For a discussion on the issues that `sumhdfe` addresses, see [deHaan (2021)](https://papers.ssrn.com/sol3/papers.cfm?abstract_id=3699777).    
Similarly, if you find these diagnostics to be useful, please cite:

> deHaan, Ed. (2021). *Using and Interpreting Fixed Effects Models*.   
> Available at SSRN: https://ssrn.com/abstract=3699777.

----

## Authors

- [Sergio Correia](http://scorreia.com/)
- [Ed deHaan](https://foster.uw.edu/faculty-research/directory/ed-dehaan/)
- [Ties de Kok](https://www.tiesdekok.com)

## Table of contents

- [Installation](#installing-sumhdfe) 
- [Usage & Features](#usage--features)
- [Pending Items](#pending-items)
- [Changelog](#changelog)
- [Questions?](#questions-and-bug-reports)

---
## Installing sumhdfe

`Sumhdfe` is an extension to [`reghdfe`](http://scorreia.com/software/reghdfe/) and requires version 6+ of [`reghdfe`](http://scorreia.com/software/reghdfe/) and [`ftools`](https://github.com/sergiocorreia/ftools/) to work. 

To install `sumhdfe` and its dependencies follow the steps below:

```stata
* Uninstall any old versions of ftools, reghdfe, sumhdfe
cap ado uninstall ftools     
cap ado uninstall reghdfe     
cap ado uninstall sumhdfe

* Install the most recent version of ftools, reghdfe, and sumhdfe
net install ftools, from("https://raw.githubusercontent.com/sergiocorreia/ftools/master/src/")
net install reghdfe, from("https://raw.githubusercontent.com/sergiocorreia/reghdfe/master/src/")
net install sumhdfe, from("https://raw.githubusercontent.com/ed-dehaan/sumhdfe/master/src/")
```

**Note:** `sumhdfe` does not work with `reghdfe` version 5, which is the version that is installed by when running `ssc install reghdfe`.   
Make sure to use the commands above to install `reghdfe` version 6.

---
## Usage & Features

### Example usage

`Sumhdfe` can be used in one of two ways:
1. As a postestimation command following `reghdfe`
2. As a standalone command 

**Post-estimation version**

First run `reghdfe` and then run `sumhdfe`. A simple example is show below, see the Stata help file for additional examples. 
```stata
use "https://raw.githubusercontent.com/ed-dehaan/sumhdfe/master/sumhdfe_demo_data.dta", clear
reghdfe y x1 x2  , a(firm year) 
sumhdfe
```
**Standalone version**

Run `sumhdfe` directly. 

```stata
use "https://raw.githubusercontent.com/ed-dehaan/sumhdfe/master/sumhdfe_demo_data.dta", clear
sumhdfe y x1 x2 , a(firm year)
```
-----
## Features

The `sumhdfe` command will provide four panels by default:

- [Panel A - summary statistics for the full sample](#panel-a---summary-statistics)
- [Panel B - summary statistics for the fixed effects](#panel-b---summary-statistics-for-fixed-effects)
- [Panel C - groups without any within-fixed-effect variation](#panel-c---groups-without-any-within-fixed-effect-variation ) 
- [Panel D - variation lost (absorbed) due to fixed effects](#panel-d---variation-lost-absorbed-due-to-fixed-effects)

Additionally, `sumhdfe` can provide:

- [A histogram that shows the frequencies of observations within a fixed effect group](#histogram)
- [Publication ready tables](#publication-ready-tables)

---
### Panel A - Summary statistics  

Summary statistics for the sample used in `reghdfe`.   

*Note:* This panel can be selected using the `sum` accronym: `panels(sum)`

**Example:**

<img src="https://user-images.githubusercontent.com/74987960/112763970-80f30a80-8fbb-11eb-91c7-67072f0f7da5.png" width="750">

**Notes:**
- It can be customized similar to `estat summarize`
- N includes singletons, so it differs from N shown in the `reghdfe` output
----
### Panel B - Summary statistics for fixed effects 

Summary statistics for the *fixed effects* themselves.  

*Note:* This panel can be selected using the `fe` accronym: `panels(fe)`

**Example:**

<img src="https://user-images.githubusercontent.com/74987960/112998721-2a084500-9123-11eb-8791-8c1a85d086c1.png" width="750">

**Notes:**

- Interpretation of the above example:
	 - There are 189 unique firms within the _firm_ fixed effects, 28 of which are singletons (i.e., appear just once). An individual firm has between 1 and 8 observations. 
	 - There are 39 unique years within the _year_ fixed effects, 8 of which are singletons.
	 - Iterating across both _firm_ and _year_ eliminates 2 more "joint singletons," for a total of 38 singletons eliminated from the `reghdfe` output.
----
### Panel C - Groups without any within fixed effect variation 

Panel C quantifies how often each variable is constant within a given fixed effect group (such as within a given firm). These observations can have unexpected effects on regression coefficients and, if numerous, should be carefully evaluated.

*Note:* This panel can be selected using the `zero` accronym: `panels(zero)`

**Example:**

<img src="https://user-images.githubusercontent.com/74987960/112763999-9bc57f00-8fbb-11eb-8297-20275a901aab.png" width="750">

**Notes:**

- Interpretation of the above example:
	- Variable x1 has (623-38=) 585 observations excluding singletons. 
	- Within the non-singleton data, 58 firms have no variation in x1; i.e., each firm has the same x1 in all years. Those 58 firms relate to 217 observations. 
	- X1 is constant within 4 years, relating to 28 observations.
---
### Panel D - Variation lost (absorbed) due to fixed effects

Panel D shows how much variation in each variable is lost (or absorbed) due to the fixed effects, in terms of both standard deviations and r-squared.

*Note:* This panel can be selected using the `rss` accronym: `panels(rss)`

**Example:**

<img src="https://user-images.githubusercontent.com/74987960/112764014-a718aa80-8fbb-11eb-8651-e85693d423e0.png" width="750">

**Notes:**

- Interpretation of the above example:
	- The standard deviation of x1 is 79.7 in the pooled sample (as also showed in Panel A), but the within-fixed-effect standard deviation of x1 is 22.7. Thus, the within-fixed effect variation of x1 is roughly 28.4% of the pooled sample. 
	- In terms of r-squared, the firm fixed effects explain roughly 87% of the variation in x1 while the year fixed effects explain roughly 13%. Combined, the fixed effects explain 92.4% of the variation in x1. 
		- *Technical note:  the r-squared is relative to the sample including singletons, for which the r-squared is mechanically equal to 100%.*

---
### Histogram

The `histogram(#)` option tabulates the frequencies of observations within a fixed effect grouping.

**Example:**

For example, `sumhdfe, histogram(1)` shows the frequencies of observations for the first fixed effect grouping listed within `a(firm year)`, i.e., *firm*. You can also specify the fixed effect name; for example `sumhdfe, histogram(year)`.

<img src="https://user-images.githubusercontent.com/74987960/112764325-d2e86000-8fbc-11eb-8108-6056e00656b5.png" width="400">

----

### Publication ready tables

All panels can be exported to a publication ready *RTF* or *Latex* table. The *RTF* table can be used in Word or Excel (by copying the contents to an Excel sheet). 

To export the tables:

- First run `sumhdfe`
- Run the `sumhdfe_export` command 
	- You can optionally specify the panels you want using "`panels(a b c d)`"
	- For the export help file run `help sumhdfe_export`
	- The filename you pass to `sumhdfe_export` will determine the output, use `.rtf` or `.tex`

**Example 1: RTF**

```stata
reghdfe y x1 x2, a(firm year) 
sumhdfe
sumhdfe_export using table.rtf, panels(a b c d)
```

You can open the `.rtf` file using Word and you can copy the table to Excel as well.

<img src="https://github.com/ed-dehaan/sumhdfe/raw/main/img/table-example-rtf.png" width=400px>

**Example 2: Tex**
```stata
reghdfe y x1 x2, a(firm year) 
sumhdfe
sumhdfe_export using table.tex, panels(a b c d) standalone
```

You can render the `.tex` file using your prefered LaTeX editor (e.g., Overleaf). 

<img src="https://github.com/ed-dehaan/sumhdfe/raw/main/img/table-example-latex.png" width=400px>

----

### Additional options

For additional examples and additional options, see the stata help file with `help sumhdfe`, or its [online version](http://scorreia.com/help/sumhdfe.html).

----

## Pending Items

1. ~~Allow for easy export of each table to Word/Excel/LaTeX~~
2. Full walkthrough with real-word example
3. Add an option to visually compare the pooled- and within-fixed-effect variation in a variable. In the meantime, it can be manually done as follows:

```stata
use "https://raw.githubusercontent.com/ed-dehaan/sumhdfe/master/sumhdfe_demo_data.dta", clear
qui: reghdfe y x1 x2, a(firm year)
qui: reghdfe x1 if e(sample), a(firm year) resid
twoway (histogram x1, fcolor(green%75) lcolor(none)) (histogram _reghdfe_resid, ///
fcolor(navy%70) lcolor(none)), legend(on order(1 "x1" 2 "within-FE x1"))
```
<img src="https://user-images.githubusercontent.com/74987960/112765144-ae8e8280-8fc0-11eb-8723-8ce0758515e8.png" width="500">

## Questions and bug reports

If you have questions or experience problems please use the [issues](https://github.com/ed-dehaan/sumhdfe/issues) tab of this repository.

Known bugs:

- The RTF file might have blank pages in the beginning or end if only a selection of panels are returned. 

