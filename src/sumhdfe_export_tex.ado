prog sumhdfe_export_tex
	* Parse syntax
	syntax, standalone(integer) filename(string) [a(string) b(string) c(string) d(string) ns(string) ps(string)] [compile label]
	_assert inlist(`standalone', 0, 1)
	_assert strpos("`filename'", ".tex") == strlen("`filename'") - 3 // equivalent to filename.endswith(".tex")

	* Decide which panels to save
	loc show_a = ("`a'" != "")
	loc show_b = ("`b'" != "")
	loc show_c = ("`c'" != "")
	loc show_d = ("`d'" != "")
	if (`show_a') loc show_a = colsof(`a') > 1
	if (`show_b') loc show_b = colsof(`b') > 1
	if (`show_c') loc show_c = colsof(`c') > 1
	if (`show_d') loc show_d = colsof(`d') > 1

	* ---------------
	* Create TEX file
	* ---------------
	tempname fh
	tempfile panelfile

	qui file open `fh' using `filename', write replace
	if (`standalone') {
		qui file write `fh' "\documentclass{article} `=char(10)'\usepackage{booktabs} `=char(10)'\usepackage{pdflscape} `=char(10)'\usepackage{caption} `=char(10)'\usepackage{hyperref} `=char(10)'\begin{document} `=char(10)'\pagenumbering{gobble} `=char(10)' `=char(10)'\begin{titlepage} `=char(10)'\begin{center} `=char(10)'\vspace*{1cm} `=char(10)'\textbf{\Large SUMHDFE - Fixed Effects Diagnostics } \\ `=char(10)'\vspace{0.5cm} `=char(10)'\textit{\large Auto-generated tables} \\ `=char(10)'\vspace{1.5cm} `=char(10)'Created by: \\ `=char(10)'\textbf{Sergio Correia} \\ `=char(10)'\textbf{Ed deHaan} \\ `=char(10)'\textbf{Ties de Kok} \\  `=char(10)'\vspace{1.5cm} `=char(10)'Using \textbf{SUMHDFE} in your paper? Please cite: \\ `=char(10)'\vspace{0.2cm} `=char(10)'\textit{deHaan, Ed. (2021). Using and Interpreting Fixed Effects Models. \\ \vspace{0.1cm}  SSRN Working Paper} \\ \vspace{0.1cm} \url{https://papers.ssrn.com/sol3/papers.cfm?abstract_id=3699777} `=char(10)'\end{center} `=char(10)'\end{titlepage} `=char(10)'"
	}
	file close `fh'

	* ---------------
	* Panel A
	* ---------------
	if (`show_a') {
		* Create esttab
		
		loc colnames : colnames `a'
		loc fancy_colnames
		foreach colname of local colnames {
			if ("`colname'" == "N")	loc colname "Num. Obs."
			if ("`colname'" == "mean")	loc colname "Mean"
			if ("`colname'" == "sd")	loc colname "Std. Dev."
			if ("`colname'" == "min")	loc colname "Min."
			if ("`colname'" == "max")	loc colname "Max."
			if ("`colname'" == "p50")	loc colname "Median"
			if ("`colname'" == "p25")	loc colname "25th Perc."
			if ("`colname'" == "p75")	loc colname "75th Perc."
			loc fancy_colnames `"`fancy_colnames' "`colname'""'
		}
		matrix colnames `a' = `fancy_colnames'

		mata: cleanup_stata_matrix("`a'")
		qui esttab matrix(`a') using "`panelfile'", `label' replace booktabs ///
			title("\textbf{Panel A:} Summary statistics of regression variables") ///
			addnotes("Note 1: Singleton observations are included in these statistics.") nomtitles

		** Modify Latex code to fix formatting
		LoadFileToString "`panelfile'"

		*** Define appropriate colsep
		loc colsep = 60 - 5 * colsof(`a')
		loc file_content = subinstr("`file_content'","} `=char(10)'\begin{tabular}{","} `=char(10)'\def\arraystretch{1.2} `=char(10)'\begin{tabular}{@{\extracolsep{`colsep'pt}}",.)

		file open `fh' using `filename', write append
		file write `fh' "\begin{landscape} `=char(10)'`file_content' `=char(10)'\end{landscape} `=char(10)' `=char(10)'\newpage"
		file close `fh'
	}


	* ---------------
	* Panel B
	* ---------------
	if (`show_b') {
		loc title "\textbf{Panel B:} Summary statistics of fixed effects"
		qui esttab matrix(`b', fmt(0 0 0 0 2 0)) using "`panelfile'", `label' replace booktabs nonumber ///
		nomtitles title("`title'") collabels(none) ///
		addnotes("Note 1: There are ${numSingleton} singletons (${percSingleton}\% of all observations)") 

		* Generate header
		GetHeaderLatex `b'
		loc totalTex `"`r(totalTex)'"'

		LoadFileToString "`panelfile'"

		** Inject header
		loc file_content = subinstr("`file_content'","\toprule `=char(10)'\midrule","\toprule `=char(10)'`totalTex' \midrule",.)

		** Inject formatting
		loc file_content = subinstr("`file_content'","} `=char(10)'\begin{tabular}{","} `=char(10)'\def\arraystretch{1.2} `=char(10)'\begin{tabular}{@{\extracolsep{30pt}}",.)

		** Add table code to tex file
		file open `fh' using `filename', write append
		file write `fh' "\begin{landscape} `=char(10)'`file_content' `=char(10)'\end{landscape} `=char(10)' `=char(10)'\newpage"
		file close `fh'
	}

	* ---------------
	* Panel C
	* ---------------
	if (`show_c') {
		loc title "\textbf{Panel C:} Variables that are constant within a fixed effect group"
		qui esttab matrix(`c') using "`panelfile'", `label' replace booktabs nonumber nomtitles title("`title'") addnotes("Note 1: goes here")  collabels(none)

		** Generate header
		GetHeaderLatex `c'
		loc totalTex `"`r(totalTex)'"'

		LoadFileToString "`panelfile'"

		** Inject header
		loc file_content = subinstr("`file_content'","\toprule `=char(10)'\midrule","\toprule `=char(10)'`totalTex' \midrule",.)

		** Inject formatting

		*** Define appropriate colsep
		scalar colsep = 60 - 7.5 * (colsof(`c') - 2)
		loc file_content = subinstr("`file_content'","} `=char(10)'\begin{tabular}{","} `=char(10)'\def\arraystretch{1.2} `=char(10)'\begin{tabular}{@{\extracolsep{`=colsep'pt}}",.)

		** Add table code to tex file
		file open `fh' using `filename', write append
		file write `fh' "\begin{landscape} `=char(10)'`file_content' `=char(10)'\end{landscape} `=char(10)' `=char(10)'\newpage"
		file close `fh'
	}

	* ---------------
	* Panel D
	* ---------------
	if (`show_d') {
		loc title "\textbf{Panel D:} Residual variation after partialling-out"

		** This is necessary to make sure the formatting list for esttab scales with the number of FE.
		loc num_cols = colsof(`d') - 4
		loc formatListTmp
		forvalues i = 1/`num_cols' {
			loc formatListTmp `formatListTmp' 3
		}

		** Create esttab
		qui esttab matrix(`d', fmt(0 4 4 2 `formatListTmp')) using "`panelfile'", `label' replace booktabs nonumber nomtitles title("`title'") addnotes("Note 1: columns with * were computed excluding singleton observations") collabels(none)

		** Generate header
		GetHeaderLatex `d'
		loc totalTex `"`r(totalTex)'"'

		LoadFileToString "`panelfile'"

		** Inject header
		loc file_content = subinstr("`file_content'","\toprule `=char(10)'\midrule","\toprule `=char(10)'`totalTex' \midrule",.)

		** Inject formatting
		loc file_content = subinstr("`file_content'","} `=char(10)'\begin{tabular}{","} `=char(10)'\def\arraystretch{1.2} `=char(10)'\begin{tabular}{@{\extracolsep{30pt}}",.)

		** Escape % in column name
		loc file_content = subinstr("`file_content'","Ratio (%)", "Ratio (\%)",.)

		** Add table code to tex file
		file open `fh' using `filename', write append
		file write `fh' "\begin{landscape} `=char(10)'`file_content' `=char(10)'\end{landscape} `=char(10)' `=char(10)'\newpage"
		file close `fh'
	}

	* -----------------
	* Finish Latex file
	* -----------------

	** Add closing tag
	if (`standalone') {
		file open `fh' using `filename', write append
		file write `fh' "\end{document}"
		file close `fh'
	}

	** Final formatting issues
	LoadFileToString "`filename'"

	*** Prevent table numbering
	while (1) {
		loc ok = regexm(`"`file_content'"',"\\caption\{")
		if (!`ok') continue, break
		loc file_content = regexr(`"`file_content'"', "\\caption\{", "\caption*{")
	}

	*** Prevent pound sign (#) from throwing errors
	while (1) {
		loc ok = regexm(`"`file_content'"',"\{\#")
		if (!`ok') continue, break
		loc file_content = regexr(`"`file_content'"', "\{\#", "{\#")
	}

	*** Fix weird lower bar causing latex errors
	while (1) {
		loc ok = regexm(`"`file_content'"',"\{_\}")
		if (!`ok') continue, break
		loc file_content = regexr(`"`file_content'"', "\{_\}", "{}")
	}

	*** The sanitizer somehow introduces a weird unicode character ("\xa0") that breaks Overleaf
	*local ubs = ustrunescape("\xa0")
	*
	*while (1) {
	*	loc ok = regexm(`"`file_content'"', `"`ubs'"')
	*	if (!`ok') continue, break
	*	loc file_content = regexr(`"`file_content'"',  `"`ubs'"', " ")
	*}

	file open `fh' using `filename', write replace
	file write `fh' "`file_content'"
	file close `fh'

	* Display clickable link
	di as text `"sumhdfe tables saved in {browse "`filename'"}"'

	* -----------------
	* Compile PDF file if requested
	* -----------------
	if ("`compile'" != "") {
		BuildPDF, filename("`filename'")
	}
end


program LoadFileToString
	tempname fh
	loc fileContentTmp
	local linenum = 0
	file open `fh' using "`1'", read
	file read `fh' line
	while (!r(eof)) {
			local linenum = `linenum' + 1
			loc fileContentTmp `"`fileContentTmp'`line' `=char(10)'"'
			file read `fh' line
	}
	file close `fh'
	c_local file_content `fileContentTmp'
end


prog def GetHeaderLatex, rclass
	/*
	Modified from:
	http://fmwww.bc.edu/RePEc/bocode/q/qcolname.ado
	*/

	gettoken matname 0 : 0 , parse(", ")
	confirm name `matname'

	local ncol=colsof(`matname')
	
	local START "yes"
	local topRowCount = 0
	local topRowLabel ""
	local topRowTex ""
	
	local topRowTexTotal "\\[-2.8ex]"
	local bottomRowTexTotal ""
	local midRuleTotal ""

	local midRuleStart 1
	local midRuleEnd 1
	
	
	tempname tempmat
	forv i1=1(1)`ncol' {
	  mat def `tempmat'=`matname'[1..1,`i1']
	  local eqcur:coleq `tempmat'
	  local namecur:colnames `tempmat'
	  local fullcur:colfullnames `tempmat'
	  
	  if (`"`eqcur'"' != `"`topRowLabel'"') loc topRowCount = 0
	  
	  if (`"`eqcur'"' != `"`topRowLabel'"') & ("`START'" != "yes") loc topRowTexTotal `"`topRowTexTotal' & `topRowTex'"' 
	  	  
	  if (`"`eqcur'"' != `"`topRowLabel'"') & ("`START'" != "yes") & (length(`"`topRowLabel'"') > 1) loc midRuleTotal `"`midRuleTotal' \cmidrule(lr){`midRuleStart'-`midRuleEnd'}"'
	  
	  loc midRuleEnd = `i1' + 1
	  if (`"`eqcur'"' != `"`topRowLabel'"') loc midRuleStart = `i1'+1
	  if (`"`eqcur'"' != `"`topRowLabel'"') loc topRowLabel `"`eqcur'"'
	
	  loc START "no"

	  loc topRowCount = `topRowCount' + 1	  
	  loc topRowTex `"\multicolumn{`topRowCount'}{c}{`topRowLabel'} "'
	  
	  loc bottomRowLabel `"`namecur'"'
	  loc bottomRowTexTotal `"`bottomRowTexTotal' & \multicolumn{1}{c}{`bottomRowLabel'} "'

	}
	
	loc topRowTexTotal `"`topRowTexTotal' & `topRowTex' \\[0.5ex]"' 
	loc midRuleTotal `"`midRuleTotal' \cmidrule(lr){`midRuleStart'-`midRuleEnd'}"'
	loc totalTex `"`topRowTexTotal' `midRuleTotal' `bottomRowTexTotal' \\ "'
			
	retu local totalTex `"`totalTex'"'
	retu local topRowTexTotal `"`topRowTexTotal'"'
	retu local bottomRowTexTotal `"`bottomRowTexTotal'"'
	retu local midRuleTotal `"`midRuleEnd'"'

end


capture program drop BuildPDF
program define BuildPDF
	syntax, filename(string)
	loc outputname = subinstr("`filename'", ".tex", ".pdf", 1)
	cap erase "`outputname'"

	tempfile error_log

	*loc cmd `"(xelatex --halt-on-error `inputname' && xelatex --halt-on-error `inputname') > "`error_log'""'
	*loc cmd `"(pdflatex --halt-on-error `inputname' && pdflatex --halt-on-error `inputname') > "`error_log'""'
	loc cmd `"(latexmk -pdf --halt-on-error `filename') > "`error_log'""'

	noi di as input `"`cmd'"'
	hshell, cmd(`cmd') // https://github.com/sergiocorreia/stata-misc 
	mata: check_pdf_ok("`error_log'")

	if (!`pdf_ok') {
		type "`error_log'"
		cap erase "`outputname'"
		error 999
	}
	else {
		*hshell, cmd(mv "$output/tex/`inputname'.pdf" "$output/tex/`outputname'.pdf")
		*type "`error_log'"
		di as text `"PDF CREATED: {browse "`outputname'"} "'
	}
end


mata:
mata set matastrict off

void cleanup_stata_matrix(mat)
{
	header = st_matrixcolstripe(mat)[., 2]
	special_chars = "_", "#", "$", "%", "&", "~"
	for (i=1; i<=cols(special_chars); i++) {
		char = special_chars[i]
		header = subinstr(header, char, "\" + char)
	}
	header = J(rows(header), 1, ""), header
	st_matrixcolstripe(mat, header)
}


void check_pdf_ok(string scalar error_log)
{
	ok = 1
	fh = fopen(error_log, "r")
	while ((line=fget(fh))!=J(0,0,"")) {
			if (strpos(line, "No pages of output")) {
				ok = 0
			}
			if (strpos(line, "!")==1) {
				ok = 0
			}
	        //printf("%s\n", line) 
	}
	fclose(fh)
	st_local("pdf_ok", strofreal(ok))
}

end
