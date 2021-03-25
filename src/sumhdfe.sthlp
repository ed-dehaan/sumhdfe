{smcl}
{* *! version 0.9.0 02Mar2021}{...}
{vieweralsosee "reghdfe" "help reghdfe"}{...}
{vieweralsosee "" "--"}{...}
{vieweralsosee "ivreghdfe" "help ivreghdfe"}{...}
{vieweralsosee "ppmlhdfe" "help ppmlhdfe"}{...}
{vieweralsosee "sumhdfe" "help sumhdfe"}{...}
{vieweralsosee "tabstat" "help tabstat"}{...}
{vieweralsosee "ftools" "help ftools"}{...}
{vieweralsosee "" "--"}{...}
{viewerjumpto "Syntax" "sumhdfe##syntax"}{...}
{viewerjumpto "Description" "sumhdfe##description"}{...}
{viewerjumpto "Options" "sumhdfe##options"}{...}
{viewerjumpto "Examples" "sumhdfe##examples"}{...}
{viewerjumpto "Stored results" "sumhdfe##results"}{...}
{viewerjumpto "Authors" "sumhdfe##contact"}{...}
{viewerjumpto "Acknowledgements" "sumhdfe##acknowledgements"}{...}
{viewerjumpto "References" "sumhdfe##references"}{...}
{title:Title}

{p2colset 5 18 20 2}{...}
{p2col :{cmd:sumhdfe} {hline 2}} Diagnostics to characterize the frequency of fixed effects and within-fixed-effect variation in linear regressions. {p_end}
{p2colreset}{...}

{marker syntax}{...}
{title:Syntax}

{pstd}
{bf:Standalone usage:}

{p 8 15 2}
{cmd:sumhdfe} {varlist} {ifin} {it:{weight}}
{cmd:,} {opth a:bsorb(reghdfe##absorb:absvars)}
[{help reghdfe##options_table:reghdfe_options}]
[{help sumhdfe##options_table:sumhdfe_options}]
[{opt keepm:issings}]
{p_end}

{pstd}
{bf:Postestimation usage:}

{p 8 15 2}
{cmd:reghdfe} {depvar} [{indepvars}] {ifin} {it:{weight}}
{cmd:,} {opth a:bsorb(reghdfe##absorb:absvars)}
[{help reghdfe##options_table:reghdfe_options}]
[{opt keepmata}]
{p_end}

{p 8 15 2}
{cmd:sumhdfe} [{varlist}]
{cmd:,} [{help sumhdfe##options_table:sumhdfe_options}]
[{opt basev:ars}]
{p_end}


{marker options_table}{...}
{synoptset 22 tabbed}{...}
{synopthdr}
{synoptline}
{syntab:Main}
{synopt: {opth a:bsorb(reghdfe##absorb:absvars)}}categorical variables representing the fixed effects to be absorbed{p_end}
{synopt :{opt keepm:issings}}include observations with some missing variables. Standalone usage only. {p_end}
{synopt: {opt h:istogram(#)}}plot histogram of group size frequencies, for the #th fixed effect{p_end}
{synopt:{cmdab:s:tatistics:(}{it:{help tabstat##statname:str}} [{it:...}]{cmd:)}}report specified summary statistics (default is {it: n mean min max}){p_end}
{synopt:{opt var:width(#)}}variable width; default is {cmd:varwidth(16)}{p_end}
{synopt:{opt f:ormat}{cmd:(%}{it:{help format:fmt}}{cmd:)}}display format for statistics; default format is {cmd:%9.0g}{p_end}
{synopt :{opt basev:ars}}report summary statistics on base variables instead of factor or lagged variables (incompatible with {opt keepm:issings}){p_end}
{synopt:{opt tab:les(str)}}show only a subset of the sumhdfe tables; default is {it:"fe sum zero rss"}{p_end}
{synopt:{opt out:put}}output a consolidated summary statistics table. NOT YET FUNCTIONAL. {p_end}
{synoptline}
{p 4 6 2}Note: under the postestimation syntax, {depvar} and all [{indepvars}] from {cmd:reghdfe} are included by default unless [{varlist}] is specified. If [{varlist}] is specified, variables must be a subset of those used in the preceding regression{p_end}


{marker description}{...}
{title:Description}

{pstd}
{cmd:sumhdfe} produces summary and diagnostic information to characterize within-fixed-effect variation in regression variables.
See
{browse "https://papers.ssrn.com/sol3/papers.cfm?abstract_id=3699777":deHaan (2021)}
for discussion of within-fixed-effect variation and for explanation of the diagnostics produced by sumhdfe. 


{pstd}
{cmd:sumhdfe} can be used as a standalone package or as a postestimation command for {cmd:reghdfe}. 

{phang2} {bf:Postestimation:} automatically limits output to the observations used in the preceding {cmd:reghdfe} command. Thus, requires non-missing values for all covariates, FE variables, cluster parameters, etc.

{phang3} To speed up {cmd:sumhdfe} in postestimation usage, run {cmd:reghdfe} with the {help reghdfe##options:keepmata} option.
 This avoids rerunning reghdfe internally, potentially saving significant time.

{phang2} {bf:Standalone usage:} Option {help sumhdfe##options:keepmissing} will prevent {cmd:sumhdfe} from dropping observations without complete data (but will still respect IF and IN statements). This is useful for creating summary statistics tables and evaluating an overall sample.


{pstd}
The default {cmd:sumhdfe} output includes four Panels:

{marker opt_absorb}{...}
{dlgtab 8 16:Panel A: Pooled sample summary statistics}

{tab} Summary statistics for the specified regressors. Options include most standard summary statistics; e.g., n, mean, median, etc.


{dlgtab 8 16: Panel B: Fixed effect summary statistics}

{tab} For each FE grouping (e.g., firm, year, etc), provides:

{phang2}  1. Number of unique groups within each FE{p_end}
{phang2}  2. Number of singletons{p_end}
{phang2}  3. Min/Avg/Max observations per FE group{p_end}

{tab} "Total" singletons is the total joint singletons identified through iterative elimination of singletons across multiple FE.


{dlgtab 8 16:Panel C: Fixed effect groups with no within-group variation}

{tab} For each regressor:

{phang2}  1. Number of observations and joint singletons considering all FE (will differ by regressor with KEEPMISSING option){p_end}
{phang2}  2. For each FE grouping, the number of unique groups and observations that have no variation within each regressor, after excluding singletons{p_end}


{dlgtab 8 16:Panel D: Remaining within-fixed-effect variation}

{tab} Two ways of representing the within-FE variation for each regressor:

{phang2}  1. Using standard deviations: "Std. Dev. Within" is the standard deviation of each regressor after it is orthogonalized to the full FE structure.  "Ratio" is the within-standard-deviation scaled by pooled-standard-deviation. {p_end}
{phang3}     - Technical note: the within-standard-deviation excludes singletons.{p_end}

{phang2}  2. Using R-squared: reports the unadjusted r-squared of regressing each regressor on each individual FE grouping and the full set of FE groupings (labeled "R2 overall). {p_end}
{phang3}     - Technical note: in a dataset without singletons, the square root of the within-standard-deviation is equal to the R2-overall. The two differ in datasets with singletons due to the "n" adjustment in the standard deviation denominator.  
{p_end}
		

{marker options}{...}
{title:Options}

{marker opt_absorb}{...}
{dlgtab:Main}

{phang}
{opth a:bsorb(reghdfe##absorb:absvars)} list of categorical variables (or interactions) representing the fixed effects to be absorbed.
This is equivalent to including an indicator/dummy variable for each category of each {it:absvar}. {cmd:absorb()} is required.

{phang}
{opt varwidth(#)} specifies the maximum width to be used within the stub to
   display the names of the variables.  The default is
   {cmd:varwidth(16)}.

{phang}
   {cmd:format(%}{it:fmt}{cmd:)} specifies the format to be used for all
   statistics. The default is to use a {cmd:%9.0g}
   format.

{phang}
{opt keep:missings} includes observations with some missing variables. The default is to otherwise retain only observations with complete data for all input variables. 

{phang}
{opt basev:ars} report statistics only for base variables instead of factor, lagged, or delta variables; i.e., ignore i., l., and d.  Currently incompatible with {opt keepm:issings}).


{phang}
{cmd:statistics(}{it:statname} [{it:...}]{cmd:)}
   specifies the statistics to be displayed; the default is equivalent to
   specifying {cmd:statistics(n mean min max)}.
   Multiple statistics may be specified
   and are separated by white space, such as {cmd:statistics(mean sd)}.
   Available statistics are:

{marker statname}{...}
{synoptset 17}{...}
{synopt:    {it:statname}}Definition{p_end}
    {synoptline}
{synopt:    {opt me:an}} mean{p_end}
{synopt:    {opt co:unt}} count of nonmissing observations{p_end}
{synopt:    {opt n}} same as {cmd:count}{p_end}
{synopt:    {opt su:m}} sum{p_end}
{synopt:    {opt ma:x}} maximum{p_end}
{synopt:    {opt mi:n}} minimum{p_end}
{synopt:    {opt r:ange}} range = {opt max} - {opt min}{p_end}
{synopt:    {opt sd}} standard deviation{p_end}
{synopt:    {opt v:ariance}} variance{p_end}
{synopt:    {opt cv}} coefficient of variation ({cmd:sd/mean}){p_end}
{synopt:    {opt sem:ean}} standard error of mean ({cmd:sd/sqrt(n)}){p_end}
{synopt:    {opt sk:ewness}} skewness{p_end}
{synopt:    {opt k:urtosis}} kurtosis{p_end}
{synopt:    {opt p1}} 1st percentile{p_end}
{synopt:    {opt p5}} 5th percentile{p_end}
{synopt:    {opt p10}} 10th percentile{p_end}
{synopt:    {opt p25}} 25th percentile{p_end}
{synopt:    {opt med:ian}} median (same as {opt p50}){p_end}
{synopt:    {opt p50}} 50th percentile (same as {opt median}){p_end}
{synopt:    {opt p75}} 75th percentile{p_end}
{synopt:    {opt p90}} 90th percentile{p_end}
{synopt:    {opt p95}} 95th percentile{p_end}
{synopt:    {opt p99}} 99th percentile{p_end}
{synopt:    {opt iqr}} interquartile range = {opt p75} - {opt p25}{p_end}
{synopt:    {opt q}} equivalent to specifying {cmd:p25 p50 p75}{p_end}
    {synoptline}
{p2colreset}{...}


{marker examples}{...}
{title:Examples}

SETUP NEEDS CHANGING TO WEBUSE FROM GIT

{hline}
{pstd}Setup: example firm-year panel dataset{p_end}
{phang2}{cmd:use "/Users/edehaan/Dropbox/Work/Research/methods/6. sumhdfe/github/sumhdfe/sumhdfe_demo_data.dta", clear}{p_end}

{pstd}Standalone usage{p_end}
{phang2}{cmd:sumhdfe y x1 x2, a(firm year)}{p_end}

{pstd}Postestimation usage (same results as standalone){p_end}
{phang2}{cmd:reghdfe y x1 x2, a(firm year)}{p_end}
{phang2}{cmd:sumhdfe}{p_end}

{pstd}Keep observations with missing x2; add summary stats. (keepmissings disallowed postestimation){p_end}
{phang2}{cmd:sumhdfe y x1 x2, a(firm year) keepmissing s(n mean p25 p50 p75 sd)}{p_end}

{pstd}With factor variable and conditional statement (works same for postestimation){p_end}
{phang2}{cmd:sumhdfe y x1 i.fe3 if x2 < ., a(firm year)}{p_end}

{pstd}With higher-order fixed effects (works same for postestimation){p_end}
{phang2}{cmd:sumhdfe y x1 , a(i.year##i.fe3)}{p_end}



{hline}

{marker results}{...}
{title:Stored results}

{pstd}
{cmd:sumhdfe} stores the following in {cmd:r()}:

{synoptset 24 tabbed}{...}
{syntab:Matrices}
{synopt:{cmd:r(stats)}}matrix of summary statistics{p_end}
{synopt:{cmd:r(fes)}}matrix of fixed effect and singleton information{p_end}
{synopt:{cmd:r(zero_variation)}}matrix with zero-variation observation within each FE category{p_end}
{synopt:{cmd:r(rss)}}matrix with residual variation after partialling for FEs{p_end}


{marker contact}{...}
{title:Authors}

{pstd}Sergio Correia{break}
Board of Governors of the Federal Reserve{break}
Email: {browse "mailto:sergio.correia@gmail.com":sergio.correia@gmail.com}
{p_end}

{pstd}Ed deHaan{break}
University of Washington{break}
Email: {browse "mailto:edehaan@uw.edu":edehaan@uw.edu}
{p_end}

{pstd}Ties de Kok{break}
University of Washington{break}
Email: {browse "tdekok@uw.edu":tdekok@uw.edu}
{p_end}


{marker support}{...}
{title:Support and updates}

{pstd}{cmd:sumhdfe} requires the {cmd:reghdfe} package (version 6 or newer) and the {cmd:ftools} package.{p_end}

{pstd}Links to online documentation & code:{p_end}

{p2colset 8 10 10 2}{...}
{p2col: -}{browse "https://github.com/ed-dehaan/sumhdfe":Github page}: code repository, issues, etc.{p_end}
{p2colreset}{...}

{marker acknowledgements}{...}
{title:Acknowledgements}

{pstd}
Thank you in advance for bug-spotting and feature suggestions.{p_end}

{marker references}{...}
{title:References}

{pstd} If you use these diagnostics, please cite: deHaan, Ed. (2021) "Using and Interpreting Fixed Effects Models." {it:Available on {browse "https://papers.ssrn.com/sol3/papers.cfm?abstract_id=3699777":SSRN}}
{p_end}
