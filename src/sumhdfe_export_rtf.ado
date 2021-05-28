prog sumhdfe_export_rtf
	* Parse syntax
	syntax, standalone(integer) filename(string) [a(string) b(string) c(string) d(string) ns(string) ps(string)] [label]
	_assert inlist(`standalone', 0, 1)
	_assert strpos("`filename'", ".rtf") == strlen("`filename'") - 3 // equivalent to filename.endswith(".rtf")

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
	* Create RTF file
	* ---------------
	tempname handle

	* Title page
	rtfopen `handle' using "`filename'", replace paper(us) template(minimal) margins(1800 1800 1500 1500)
	if (`standalone') {
		file write `handle' "\b \fs36 SUMHDFE - Fixed Effects Diagnostics \b0 \fs30 \line\line Created by: \line\line Sergio Correia \line Ed deHaan \line Ties de Kok \line \line \line Using \b SUMHDFE \b0 in your paper? Please cite: \line \line \i deHaan, Ed. (2021). Using and Interpreting Fixed Effects Models. SSRN Working Paper \i0 \line \line https://papers.ssrn.com/sol3/papers.cfm?abstract_id=3699777 \fs24"
	}
	rtfsect `handle', paper(usland) landscape
	rtfclose `handle'

	* Panel A
	if (`show_a') {
		loc colnames : colnames `a'
		loc fancy_colnames
		foreach colname of local colnames {
			if ("`colname'" == "N")		loc colname "Num. Obs."
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

		qui esttab matrix(`a', fmt(0 4 4)) using "`filename'", append nonumber wide nomtitles ///
			varwidth(10) modelwidth(10) ///
			title("\b \line Panel A: Summary statistics of regression variables \line \b0") ///
			addnotes("Note 1: Singleton observations are included in these statistics. \b0 \trrh100")
		rtfappend `handle' using "`filename'", replace
		file write `handle' "\page" _n
		rtfclose `handle'
	}

	* Panel B
	if (`show_b') {
		loc title "\b \line Panel B: Summary statistics of fixed effects \line \b0"
		tempfile output
		qui esttab matrix(`b', fmt(0 0 0 0 2 0)) using "`output'", replace nonumber wide nomtitles ///
			title("`title'") varwidth(14) modelwidth(12) rtf prehead("") posthead("") collabels("") type
		qui BuildHeader using "`output'", matrix(`b') title("`title'")
		qui sreturn list
		qui esttab matrix(`b', fmt(0 0 0 0 2 0)) using "`filename'", append nonumber wide nomtitles ///
			addnotes("Note 1: There are ${numSingleton} singletons (${percSingleton}% of all observations)") ///
			varwidth(14) modelwidth(12) prehead(`"`s(prehead)'"') collabels(none)
		rtfappend `handle' using "`filename'", replace 
		file write `handle' "\page" _n
		rtfclose `handle'
	}

	* Panel C
	if (`show_c') {
		loc title "\b \line Panel C: Variables that are constant within a fixed effect group \line \b0"

		tempfile output
		qui esttab matrix(`c') using "`output'", replace nonumber wide nomtitles title("`title'") ///
			addnotes("Note 1: <goes here>") varwidth(10) modelwidth(10) rtf prehead("") posthead("") ///
			type collabels("")
		BuildHeader using "`output'", matrix(`c') title("`title'")
		qui sreturn list
		qui esttab matrix(`c') using "`filename'", append nonumber wide nomtitles ///
			addnotes("Note: columns with * were computed excluding singleton observations") ///
			varwidth(10) modelwidth(10) prehead(`"`s(prehead)'"') collabels(none)
		rtfappend `handle' using "`filename'", replace
		file write `handle' "\page" _n
		rtfclose `handle'
	}

	* Panel D
	if (`show_d') {
		loc title "\b \line Panel D: Residual variation after partialling-out \line \b0"
		* This is nescessary to make sure the formatting list for esttab scales with the number of FE.
		loc num_cols = colsof(`d') - 4
		loc formatListTmp
		forvalues i = 1/`num_cols' {
			loc formatListTmp `formatListTmp' 3
		}

		tempfile output
		qui esttab matrix(`d') using "`output'", replace nonumber wide nomtitles title("`title'") ///
			addnotes("Note 1: columns with * were computed excluding singleton observations") ///
			varwidth(10) modelwidth(10) rtf prehead("") posthead("") type collabels("")
		BuildHeader using "`output'", matrix(`d') title("`title'")
		qui sreturn list
		qui esttab matrix(`d', fmt(0 4 4 2 `formatListTmp')) using "`filename'", append nonumber wide ///
			nomtitles title("\b \line Panel D: Residual variation after partialling-out \line \b0") ///
			addnotes("Note 1: columns with * were computed excluding singleton observations") ///
			varwidth(10) modelwidth(10) prehead(`"`s(prehead)'"') collabels(none)
	}

	*** In the spirit of full spaghetti code --> below I read in the RTF file and patch the spacing with some regex

	* Load the file into a single string
	loc fileContentTmp
	local linenum = 0
	tempname fh
	file open `fh' using "`filename'", read
	file read `fh' line
	while (!r(eof)) {
			local linenum = `linenum' + 1
			loc fileContentTmp `"`fileContentTmp'`line'"'
			file read `fh' line
	}
	file close `fh'

	** Patch the spacing of panel A headers
	loc fileContentTmp = regexr(`"`fileContentTmp'"', "\\qc \{mean}\\cell", "\qc \sb100 {mean} \sa100 \cell")
	loc fileContentTmp = regexr(`"`fileContentTmp'"', "\\qc \{N}\\cell", "\qc \sb100 {N} \sa100 \cell")
	loc fileContentTmp = regexr(`"`fileContentTmp'"', "\\qc \{sd}\\cell", "\qc \sb100 {sd} \sa100 \cell")

	*display `"`fileContentTmp'"'
	loc cellSpacing 50
	while (1) {
		loc ok = regexm(`"`fileContentTmp'"',"(\\q[cl] )(\{[0-9a-zA-Z. -]*})(\\cell)")
		if (!`ok') continue, break
		loc newCellStr `"`=regexs(1)' \sb`cellSpacing' `=regexs(2)' \sa`cellSpacing' `=regexs(3)'"'
		*display "`newCellStr'"
		loc fileContentTmp = regexr(`"`fileContentTmp'"', "\\q[cl] \{[0-9a-zA-Z. -]*}\\cell", `"`newCellStr'"')
	}

	*display `"`fileContentTmp'"'
	file open `fh' using "`filename'", write replace
	file write `fh' `"`fileContentTmp'"'
	file close `fh'

	* Display clickable link
	di as text `"sumhdfe tables saved in {browse "`filename'"}"'
end


program define BuildHeader, sclass
syntax using/ , matrix(string) title(string)
	sreturn clear

	tempname fh
	file open `fh' using "`using'", read text
	file read `fh' line // first line is empty
	file read `fh' line
	*di as error "`line'"

	while (1) {
		loc ok = regexm(`"`line'"', "cellx([0-9]+)")
		if (!`ok') continue, break
		loc offset = regexs(1)
		loc offsets "`offsets' `offset'"
		loc line = regexr(`"`line'"', "cellx([0-9]+)", "")
	}
	*di as error "OFFSETS: `offsets'"
	loc backup_offsets `"`offsets'"'
	file close `fh'

	loc headers : coleq `matrix', quoted
	loc headers `""" `headers' "STOP""' // add first column, plus a fake column at the end
	*di as error `"HEADERS: `headers'"'
	
	loc headerSpacing 100

	loc first 1
	while (`"`headers'"' != "") {
		gettoken header headers : headers
		gettoken offset offsets : offsets
		loc break = (!`first') & (`"`header'"' != `"`last_header'"')
		if ("`header'" == "_") loc header " " // make it empty

		*di as error "break=`break' header=`header' offset=`offset'"

		if (`break') {
			loc ROW1PART1 `"`ROW1PART1'\cellx`last_offset'\clbrdrt\brdrw10\brdrs"'
			loc ROW1PART2 `"`ROW1PART2'\pard\intbl\qc \sb`headerSpacing' {`last_header'} \sa`headerSpacing'\cell "'
		}


		loc last_header `"`header'"'
		loc last_offset `"`offset'"'
		loc first 0
	}
	
	loc headers : colnames `matrix', quoted
	loc headers `""" `headers'"'
	*di as error `"`headers'"'
	loc offsets `"`backup_offsets'"'
	while (`"`headers'"' != "") {
		gettoken header headers : headers
		gettoken offset offsets : offsets
		loc header = subinstr("`header'", " ", " ", .)
		loc ROW2PART1 `"`ROW2PART1'\cellx`offset'\clbrdrt\brdrw10\brdrs"'
		loc ROW2PART2 `"`ROW2PART2'\pard\intbl\qc \sb`headerSpacing' {`header'} \sa`headerSpacing' \cell "'
	}
	loc TITLE `"{\pard\keepn\ql `title'\par}{"'
	loc ROW1 `"{\trowd\trgaph108\trleft-108\clbrdrt\brdrw10\brdrs`ROW1PART1'`ROW1PART2'\row}"'
	loc ROW2 `"{\trowd\trgaph108\trleft-108\clbrdrt\brdrw10\brdrs`ROW2PART1'`ROW2PART2'\row}"'
	loc prehead `"`TITLE'`ROW1'`ROW2'"'
	sreturn local prehead `"`prehead'"'
end
