*! version 0.9.5 28may2021

program define sumhdfe_export

	* Parse syntax
	syntax using/ , [STANDalone PANELs(string) COMPILE Label]
	GetFileSuffix, filename("`using'") // save results in local `suffix'
	loc standalone = ("`standalone'" != "")

	if ("`panels'" == "") loc panels "a b c d"
	loc panels = strlower("`panels'")

	loc show_a = (`: list posof "a" in panels') | (`: list posof "sum" in panels')
	loc show_b = (`: list posof "b" in panels') | (`: list posof "fe" in panels')
	loc show_c = (`: list posof "c" in panels') | (`: list posof "zero" in panels')
	loc show_d = (`: list posof "d" in panels') | (`: list posof "rss" in panels')

	* Store results
	tempname A B C D
	mat `A' = r(stats)
	mat `B' = r(fes)
	mat `C' = r(zero_variation)
	mat `D' = r(rss)
	loc ns = r(num_singletons)
	loc ps = r(fraction_singletons)

	* Create options
	loc opt ns(`ns') ps(`ps')
	if (`show_a')	loc opt `"`opt' a(`A')"'	// Summary stats table
	if (`show_b')	loc opt `"`opt' b(`B')"'	// Fixed effects table
	if (`show_c')	loc opt `"`opt' c(`C')"'	// Zero-variation table
	if (`show_d')	loc opt `"`opt' d(`D')"'	// RSS table (residual variation)

	* Add compilation option (TEX to PDF)
	if ("`compile'" != "" & "`suffix'" == "tex") {
		CheckDependencies // to compile we also need the -parallel- and -hshell- packages
		loc opt `"`opt' compile"'
		loc standalone 1 // this option turns on -standalone-
	}
	
	* Write tables
	sumhdfe_export_`suffix', standalone(`standalone') filename("`using'") `opt' `label'
end


program define GetFileSuffix
	syntax, filename(string)
	loc ok = regexm("`filename'", "[.](tex|rtf|xlsx|pdf)$")
	loc suffix = regexs(1)
	_assert `ok', msg(`"filename "`filename'" invalid (valid filetype not detected)"')
	c_local suffix `suffix'
end


program define CheckDependencies
	cap which parallel
	loc ok1 = !c(rc)
	if (!`ok1') {
	    di as error "to compile PDFs, sumhdfe requires the {bf:parallel} package, which is not installed."
	    di as error `"  - Install from {stata `"net install parallel, from("https://raw.github.com/gvegayon/parallel/stable/")"':Github}"'
	}

	cap which hshell
	loc ok2 = !c(rc)
	if (!`ok2') {
	    di as error "to compile PDFs, sumhdfe requires the {bf:hshell} package, which is not installed."
	    di as error `"  - Install from {stata `"net install hshell, from("https://github.com/sergiocorreia/stata-misc/raw/master/src/")"':Github}"'
	}

	if (!`ok1' | !`ok2') {
		exit 9
	}
end
