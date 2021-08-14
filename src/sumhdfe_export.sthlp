{smcl}
{* *! version 0.9.5 28may2021}{...}
{vieweralsosee "sumhdfe" "help sumhdfe"}{...}
{vieweralsosee "" "--"}{...}
{vieweralsosee "esttab" "help esttab"}{...}
{vieweralsosee "parallel" "help parallel"}{...}
{vieweralsosee "hshell" "help hshell"}{...}
{title:Title}

{p2colset 5 23 25 2}{...}
{p2col :{cmd:sumhdfe_export} {hline 2}} Export sumhdfe tables and figures. {p_end}
{p2colreset}{...}


{marker syntax}{...}
{title:Syntax}

{p 8 16 2}
{cmd:sumhdfe_export}
[{cmd:using}]
[{cmd:,}
[{opt panel:s(string)}]
[{opt l:abel}]
[{opt stand:alone}]
[{opt compile}]


{marker options_table}{...}
{synoptset 22 tabbed}{...}
{synopthdr}
{synoptline}
{syntab:Main}
{synopt :{opt stand:alone}}produce output with an appropriate header and footer, so the document is a standalone file. In the case of TEX output, this option adds \begin{document}, \end{document}, and so on{p_end}
{synopt :{opt panel:s}}list the panels that will be exported. For instance, "a b" will only export panels A and B. By default, all panels (A-D) are exported{p_end}
{synopt :{opt l:abel}}make use of variable labels instead of variable names{p_end}
{synopt :{opt compile}}(experimental option) compile TEX output into a PDF; implies standalone option{p_end}


{marker description}{...}
{title:Description}

{pstd}
{cmd:sumhdfe_exports} exports the output of sumhdfe into different formats, including TEX (for latex output), and RTF (for Word output).

{pstd}
The type of file exported is based on the filename ({it: .tex} or {it: .rtf}). The RTF file can be copied into an Excel sheet. 

{pstd}
The {browse "https://github.com/ed-dehaan/sumhdfe#publication-ready-tables":Github page} provides examples of the tables.


{marker examples}{...}
{title:Examples}

{hline}
To produce a {it:LaTeX} file: 

{phang2}{cmd:use "https://raw.githubusercontent.com/ed-dehaan/sumhdfe/master/sumhdfe_demo_data.dta", clear}{p_end}
{phang2}{cmd:sumhdfe y x1 x2, a(firm year)}{p_end}
{phang2}{cmd:sumhdfe_export using sumhdfe.tex, panels(a b)}{p_end}

To produce an {it:RTF} (Word or Excel) file:

{phang2}{cmd:use "https://raw.githubusercontent.com/ed-dehaan/sumhdfe/master/sumhdfe_demo_data.dta", clear}{p_end}
{phang2}{cmd:sumhdfe y x1 x2, a(firm year)}{p_end}
{phang2}{cmd:sumhdfe_export using sumhdfe.rtf, panels(a b)}{p_end}
