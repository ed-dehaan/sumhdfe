*! version 0.9.4 22may2021

program define sumhdfe
	* version 14 // set minimum version
	qui which ftools // ms_get_version
	ms_get_version ftools, min_version("2.47.0")
	ms_get_version reghdfe, min_version("6.0.9")

	loc keep_mata 0
	cap noi Main `0' // might modify local `keep_mata'
	Cleanup `c(rc)' `keep_mata'
end


program Cleanup
	args rc keep_mata
	if (!`keep_mata') cap mata: mata drop HDFE
	cap mata: mata drop HDFE_*
	cap mata: mata drop sumhdfe_*
	cap matrix drop sumhdfe*
	version 14: cap drop sumhdfe_hist* // need to use version control else -drop- clears r() including our matrices
	if (`rc') exit `rc'
end


program define Main

	* Detect which SUMHDFE mode we are running
	* ---------------------------------------------------------------

	* -sumhdfe- has four modes:
	* a) standalone:		if we received an "absorb()" option
	* b) keepmissings:		as (a), but missing values in one variable won't propagate to the others
	* c) postestimation:	as a postestimation command, so we can retrieve e(cmdline)
	* d) keepmata:			as (c), but faster b/c the HDFE object was not deleted

	* Detect keepmissings
	if ("`mode'" == "") {
		cap syntax anything(everything) [fw aw pw], [*] Absorb(string) KEEPMissings
		if (!c(rc)) loc mode "keepmissings"
	}

	* Detect standalone
	if ("`mode'" == "") {
		cap syntax anything(everything) [fw aw pw], [*] Absorb(string)
		if (!c(rc)) loc mode "standalone"
	}

	* Detect keepmata
	if ("`mode'" == "") {
		cap mata: HDFE
		if (!c(rc)) {
			loc mode "keepmata"
	
			* Raise error if previous reghdfe call had "nopartial" or "noregress" options
			mata: st_local("cmdline_exists", strofreal(HDFE.solution.cmdline != ""))
			_assert `cmdline_exists', msg("a Mata HDFE object exists but was not fully executed")
			c_local keep_mata 1
		}
	}

	* Detect postestimation
	if ("`mode'" == "") {
		if ("`e(cmd)'" == "reghdfe") loc mode "postestimation"

		* Raise error if previous reghdfe call had "nopartial" or "noregress" options
		_assert `"`e(cmdline)'"' != "", msg("e(cmdline) does not exist")
	}

	_assert "`mode'" != "", msg("option {bf:absorb()} required unless sumhdfe is ran after reghdfe")

	* Create HDFE and HDFE_Singletons object as needed
	* HDFE_Singletons is the version that includes singleton observations
	* ---------------------------------------------------------------

	if ("`mode'" == "keepmissings") {
		* Parse sumhdfe+reghdfe (combined)
		syntax varlist(fv ts numeric default=none) [if] [in] [fw aw pw], [*] /// passthrough to reghdfe
			[KEEPSINgletons] /// discarded
			[Histogram(string) TABles(string) Statistics(string) VARwidth(integer 16) format(string)] /// sumhdfe options (note that -basevars- is incompatible with -keepmissings-)
			KEEPMissings // keepmissings option
		
		if ("`tables'" == "") loc tables "fe sum zero rss"
		loc show_table_fe : list posof "fe" in tables		// Fixed effects table
		loc show_table_sum : list posof "sum" in tables		// Summary stats table
		loc show_table_zero : list posof "zero" in tables	// Zero-variation table
		loc show_table_rss : list posof "rss" in tables		// RSS table (residual variation)
		loc fullsample_table "fes"
		loc loop_tables : list tables - fullsample_table

		ParseVarlist `varlist' `if' `in' // updates `sumhdfe_varlist'
		loc is_first 1
		tempname M_stats M_zero M_rss
		foreach var of local sumhdfe_varlist {
			*di as error "var=`var'"
			cap mata: mata drop HDFE_*
			reghdfe `var' `if' `in' [`weight'`exp'], `options' nowarn verbose(-1) noregress
			mata: mata rename HDFE HDFE_Compact
			reghdfe `var' `if' `in' [`weight'`exp'], `options' nowarn verbose(-1) nopartialout keepsingletons
			mata: mata rename HDFE HDFE_Singletons
			qui Inner, tables(`loop_tables') statistics(`statistics')
			
			if (`is_first') {
				matrix rename r(stats) `M_stats'
				matrix rename r(zero_variation) `M_zero'
				matrix rename r(rss) `M_rss'
			}
			else {
				* Maybe use "matrix rowjoinbyname STATS = STATS r(stats)" ?
				matrix `M_stats' = `M_stats' \ r(stats)
				matrix `M_zero' = `M_zero' \ r(zero_variation)
				matrix `M_rss' = `M_rss' \ r(rss)
			}
			loc is_first 0
		}

		* Compute table #2 (FEs) ignoring all variables
		if (`show_table_fe') {
			tempvar c
			gen byte `c' = 1
			cap mata: mata drop HDFE_*
			reghdfe `c' `if' `in' [`weight'`exp'], `options' nowarn verbose(-1) noregress
			mata: mata rename HDFE HDFE_Compact
			reghdfe `c' `if' `in' [`weight'`exp'], `options' nowarn verbose(-1) nopartialout keepsingletons
			mata: mata rename HDFE HDFE_Singletons
			qui Inner, histogram(`histogram') tables(fe)
			matrix rename r(fes) sumhdfe_fes
		}

		matrix rename `M_stats' sumhdfe_stats
		matrix rename `M_zero' sumhdfe_zero_variation
		matrix rename `M_rss' sumhdfe_variation
		Post
		Replay, varwidth(`varwidth') format(`format') show_table_fe(`show_table_fe') show_table_sum(`show_table_sum') show_table_zero(`show_table_zero') show_table_rss(`show_table_rss')
	}
	else if ("`mode'" == "standalone") {
		* Parse sumhdfe+reghdfe (combined)
		syntax varlist(fv ts numeric default=none) [if] [in] [fw aw pw], [*] /// passthrough to reghdfe
			[KEEPSINgletons] /// discarded
			[Histogram(string) TABles(string) Statistics(string) BASEVars VARwidth(integer 16) format(string)] // sumhdfe options
		
		* Create HDFE object that excludes singletons
		reghdfe `varlist' `if' `in' [`weight'`exp'], `options' nowarn verbose(-1) noregress
		mata: mata rename HDFE HDFE_Compact
		
		* Create HDFE object that includes singletons
		reghdfe `varlist' `if' `in' [`weight'`exp'], `options' nowarn verbose(-1) nopartialout keepsingletons
		mata: mata rename HDFE HDFE_Singletons

		loc sumhdfe_options "histogram(`histogram') tables(`tables') statistics(`statistics') `basevars' varwidth(`varwidth') format(`format')"
		Inner, `sumhdfe_options'
	}
	else if inlist("`mode'", "postestimation", "keepmata") {
		* Parse sumhdfe
		syntax [varlist(fv ts numeric default=none)], [Histogram(string) TABles(string) Statistics(string) BASEVars VARwidth(integer 16) format(string)]
		loc sumhdfe_fullvarlist `varlist'
		loc sumhdfe_options "histogram(`histogram') tables(`tables') statistics(`statistics') `basevars' varwidth(`varwidth') format(`format')"
		loc cmdline `"`e(cmdline)'"'

		if ("`mode'" == "postestimation") {
			* Need to run reghdfe again to keep the HDFE object
			`cmdline' nowarn verbose(-1) noregress
		}

		* SUMHDFE does not work if reghdfe call had -keepsingletons- option
		mata: assert_msg(HDFE.drop_singletons == 1, "error: last reghdfe call had keepsingletons option", 100, 0)
		mata: mata rename HDFE HDFE_Compact

		* Create HDFE object that includes singletons
		`cmdline' nowarn verbose(-1) nopartialout keepsingletons
		mata: mata rename HDFE HDFE_Singletons

		* Problem: if we requested an explicit list of variables (other than "all the vars from the reghdfe call")
		* Then we need to use the exact sample when we expand the fvvars (i.x, etc) otherwise we might not get the same results
		* EG: the sample excludes x==1, so now the base omitted variable is x==2, so correct varlist = "ib2.x 3.x 4.x"
		* and wrong varlist with full sample would be "ib1.x 2.x 3.x 4.x"
		if ("`sumhdfe_fullvarlist'" != "") {
			tempvar quick_touse
			mata: HDFE_Compact.save_touse("`quick_touse'")
			ParseVarlist `sumhdfe_fullvarlist' if `quick_touse' // updates `sumhdfe_fullvarlist'
		}

		Inner `sumhdfe_fullvarlist', `sumhdfe_options'
		mata: mata rename HDFE_Compact HDFE
	}
	else {
		error 123
	}
end


program define ParseVarlist
	syntax varlist(ts fv numeric) [if]
	ms_expand_varlist `varlist' `if'
	*return list
	c_local sumhdfe_varlist "`r(varlist)'"
	c_local sumhdfe_fullvarlist "`r(fullvarlist)'"
end


program define Inner
	* -syntax- CANNOT have varlist
	* otherwise, it will convert "1b.race .race" into "i(1 2)b1.race" which messes up all further code
	syntax [anything], ///
		[histogram(string)] ///
		[Statistics(string) BASEVars KEEPMissings] ///
		[tables(string)] ///
		[VARwidth(integer 16) format(string)] ///

	if ("`tables'" == "") loc tables "fe sum zero rss"
	loc show_table_fe : list posof "fe" in tables		// Fixed effects table
	loc show_table_sum : list posof "sum" in tables		// Summary stats table
	loc show_table_zero : list posof "zero" in tables	// Zero-variation table
	loc show_table_rss : list posof "rss" in tables		// RSS table (residual variation)

	* SUMHDFE needs an intercept
	mata: assert_msg(HDFE_Compact.has_intercept, "no intercept in absorb()", 3333, 0)

	* Create samples
	tempvar touse touse_with_singletons
	mata: HDFE_Compact.save_touse("`touse'")
	mata: HDFE_Singletons.save_touse("`touse_with_singletons'")

	* Create and clean up variables (this is very tricky due to variables omitted for various reasons)
	* Note on the internals:
	* - HDFE.indepvar_status 					--> 0=Ok 1=basevars 2=CollinearWithFEs 3=CollinearWithX ; First cell is actually depvar!
	*
	* - ms_parse_varlist `varlist'				--> create locals depvar, indepvars, basevars
	* - ms_expand_varlist `indepvars'			--> create fullindepvars (which include base levels)
	* - HDFE.partial_out("`depvar' `indepvars'")
	*											--> HDFE.solution.data created, excluding indepvar_status 1
	*											--> HDFE.solution.varlist is set, based on tokens("`depvar' `indepvars'")
	* - HDFE.indepvar_status assigned values of 0/1 at this point
	* - HDFE.solution.check_collinear_with_fe() --> Adds indepvar_status 2
	*											--> HDFE.solution.data trimmed to remove indepvar_status 2
	* - reghdfe_solve_ols() 					--> adds indepvar_status 3

	* sumhdfe_index has the position of each variable within solution.data
	mata: init_varlist("`anything'", HDFE_Compact, HDFE_Singletons, sumhdfe_vars="", sumhdfe_vars_bn="", sumhdfe_index=.)

	if ("`anything'" == "") mata: st_local("anything", invtokens(sumhdfe_vars))

	if (`show_table_sum') SummarizeVariables `anything', statistics(`statistics') touse(`touse_with_singletons') `basevars'
	if (`show_table_fe') SummarizeFEs
	if (`show_table_zero') SummarizeZeroVariation
	if (`show_table_rss') SummarizeVariation
	if (`"`histogram'"' != "") Histogram `histogram'

	* Post tables
	Post

	* View tables
	Replay, varwidth(`varwidth') format(`format') show_table_fe(`show_table_fe') show_table_sum(`show_table_sum') show_table_zero(`show_table_zero') show_table_rss(`show_table_rss')
end


program SummarizeVariables
	syntax anything, touse(varname) [Statistics(string) BASEvars]

	if ("`statistics'" == "") loc statistics N mean sd  // default values

	* Optional weights
	mata: st_local("weight", sprintf("[%s=%s]", HDFE_Compact.weight_type, HDFE_Compact.weight_var))
	assert "`weight'" != ""
	if ("`weight'" == "[=]") loc weight
	loc weight : subinstr local weight "[pweight" "[aweight"

	if ("`basevars'" != "") {
		* quick workaround b/c -tabstat- does not support factor variables
		qui fvrevar `anything' if `touse', list
		loc anything `r(varlist)'
		loc anything : list uniq anything // remove dupes; unsure why fvrevar converts "L(0/1).x" into "x x" instead of "x"
	}

	sumhdfe_tabstat `anything' if `touse' `weight' , statistics(`statistics')
	matrix sumhdfe_stats = r(StatTotal)'
	* TODO? Add better column headers (i.e. "Std. Dev." instead of "sd")
end


program SummarizeFEs
	mata: summarize_fes(HDFE_Compact, HDFE_Singletons)
end


program SummarizeZeroVariation
	mata: summarize_zero_variation(sumhdfe_vars, sumhdfe_vars_bn, HDFE_Compact) // save matrix sumhdfe_variation
end


program SummarizeVariation
	mata: summarize_variation(sumhdfe_vars, sumhdfe_vars_bn, sumhdfe_index, HDFE_Compact, HDFE_Singletons) // save matrix sumhdfe_variation
	//matrix colnames sumhdfe_variation = "RSS" "TSS" "RSS (% of TSS)"
end


program Histogram
	syntax anything(name=fe), [start(integer 0) width(integer 1) DENsity FRACtion FREQuency percent xtitle(string) *]

	* Select if we want fraction, frequency, etc (freq by default)
	opts_exclusive "`density' `fraction' `frequency' `percent'" histogram
	loc draw_type "`density'`fraction'`frequency'`percent'"
	if ("`draw_type'" == "") loc draw_type "frequency"

	* histogram() accepts numbers or strings. The two calls below are equivalent:
	* sumhdfe .. a(year firm) hist(2)
	* sumhdfe .. a(year firm) hist(firm)
	cap confirm integer number `fe'
	if (c(rc)) {
		loc fe_name "`fe'"
		mata: st_local("fe_number", strofreal(selectindex(HDFE_Compact.absvars :== "`fe_name'")))
	}
	else {
		loc fe_number `fe'
		mata: st_local("fe_name", HDFE_Compact.absvars[`fe_number'])
	}

	if ("`xtitle'" == "") loc xtitle "Number of observations per `fe_name'"

	mata: fe_histogram(HDFE_Compact, `fe_number')
	histogram sumhdfe_hist, `draw_type' start(`start') width(`width') discrete xtitle(`"`xtitle'"') `options'
end


program Post, rclass
	cap return matrix stats = sumhdfe_stats
	cap return matrix fes = sumhdfe_fes
	cap return matrix zero_variation = sumhdfe_zero_variation
	cap return matrix rss = sumhdfe_variation
	cap return scalar num_singletons = r(num_singletons)
	cap return local fraction_singletons = r(fraction_singletons)
end


program Replay
	syntax, show_table_fe(integer) show_table_sum(integer) show_table_zero(integer) show_table_rss(integer) ///
		[VARwidth(integer 16) Format(string)]
	if ("`format'"=="") loc format "%9.0g"
	loc note_no_singletons "Note: columns with * were computed excluding singleton observations"
	

	if (`show_table_sum') {
		di as text _n "{title:Panel A:} Summary statistics of regression variables (including singleton observations)"
		matlist r(stats), border(top bottom) rowtitle(Variable) noblank nohalf twidth(`varwidth') format(`format')
	}	


	if (`show_table_fe') {
		di as text _n _n "{title:Panel B}: Summary statistics of fixed effects"
		loc spaces = (`: rowsof r(fes)' - 3) * "&"
		matlist r(fes), border(top bottom) rowtitle(Fixed Effect) noblank nohalf ///
			cspec(& %`varwidth's | %12.0fc & %12.0fc & %12.0fc | %8.0fc & %10.2fc & %8.0fc &) rspec(||`spaces'|&|) ///
			showcoleq(combined) aligncolnames(center)
		di as text "Note: there are `r(num_singletons)' singletons (`r(fraction_singletons)'% of all observations)"
	}


	if (`show_table_zero') {
		di as text _n _n "{title:Panel C}: Variables that are constant within a fixed effect group"
		loc spaces = (`: rowsof r(zero_variation)' - 1) * "&"

		loc cols : colsof r(zero_variation)
		loc G = round((`cols'-2) / 2)
		loc cspec "& %`varwidth's | %8.0fc & %8.0fc"
		forval g = 1/`G' {
			loc cspec "`cspec' | %8.0fc & %8.0fc"
		}
		loc cspec "`cspec' &"
		matlist r(zero_variation), rowtitle(Variable) noblank nohalf ///
			cspec(`cspec') rspec(||`spaces'|) showcoleq(combined)
		di as text "`note_no_singletons'"
	}

	
	if (`show_table_rss') {
		di as text _n _n "{title:Panel D}: Residual variation after partialling-out"
		loc partial_r2s = (`: rowsof r(fes)' - 3) * "%10.3f & " + "%10.3f "
		loc spaces = (`: rowsof r(rss)' - 1) * "&"

		matlist r(rss), rowtitle(Variable) noblank nohalf ///
			cspec(& %`varwidth's | %8.0fc | `format' &  `format' & %9.2f | `partial_r2s' | %8.3f &) rspec(||`spaces'|) ///
			showcoleq(combined) aligncolnames(center)
		di as text "`note_no_singletons'"
	}
end


// --------------------------------------------------------------------------
// Include reghdfe code
// --------------------------------------------------------------------------
	
	include "reghdfe.mata", adopath



// --------------------------------------------------------------------------
// Mata Code
// --------------------------------------------------------------------------

mata:

void init_varlist(string rowvector vars, class FixedEffects scalar HDFE, class FixedEffects scalar HDFE_Singletons,
				  string rowvector fixedvars, string rowvector fixedvars_bn, real rowvector index)
{
	string rowvector		allvars, datavars
	string rowvector		allvars_bn, datavars_bn
	real rowvector			indepvar_status
	real scalar				i, posof
	transmorphic			dict

	// The key here is -indepvar_status-, which takes values:
	//	0: variable is ok! 
	// 	1: variable is a basevar (e.g. i2000.year in ib2000.year)
	//	2: variable is collinear with FEs
	//	3: variable is collinear with partialled-out regressors
	// Also, note that:
	//	- The first cell is the depvar
	//	- Case 1 (basevars) are never loaded into solution.data but are listed in solution.fullindepvars
	//	- check_collinear_with_fe() will trim solution.data by excluding case 2
	//	- reghdfe_solve_ols() deletes solution.data so no need to trim it for case 3
	indepvar_status = HDFE.solution.indepvar_status

	// Note: we use fullindepvars_bn instead of fullindepvars_bn because
	// fullindepvars_bn lists factor variables as "1b.rep78 2.rep78 ..."
	// This then causes some factor variables to be loaded as a vector of zeroes!!! (bug in st_data?)
	// The workaround is to have the variables as "2bn.rep78 .." where the "bn" forces Stata to load the vars
	// For more details, see "viewsource ms_expand_varlist.ado"
	// For an example:
	// 		sysuse auto, clear
	// 		mata: colsum(st_data(., tokens("2.rep78 3.rep78 4.rep78 5.rep78")))
	// 		mata: colsum(st_data(., tokens("2bn.rep78 3bn.rep78 4bn.rep78 5bn.rep78")))
	allvars = HDFE.solution.depvar , HDFE.solution.fullindepvars
	allvars_bn = HDFE.solution.depvar , HDFE.solution.fullindepvars_bn
	assert_msg(cols(allvars) == cols(indepvar_status))

	// Remove _cons from allvars and indepvar_status
	if (allvars[cols(allvars)] == "_cons") {
		allvars = allvars[1..cols(allvars)-1]
		allvars_bn = allvars_bn[1..cols(allvars_bn)-1]
		assert(indepvar_status[cols(indepvar_status)]==0)
		indepvar_status = indepvar_status[1..cols(indepvar_status)-1]
	}

	// Select variables to report on. If varlist is empty, use allvars (don't use solution.varlist, which excludes case 1!)
	vars = (vars == "") ? allvars : tokens(vars)

	// Sanity check
	for (i=1; i<=cols(vars); i++) {
		assert_msg(anyof(allvars, vars[i]), sprintf("variable %s does not exist in HDFE object: %s\n", vars[i], invtokens(allvars)), 123, 0)
	}

	// Exclude variables with indepvar_status=2 (indepvar_status=1 shouldn't be needed because they are already excluded)
	fixedvars = J(1, 0, "")
	fixedvars_bn = J(1, 0, "")
	index = J(1, 0, .)

	datavars = select(allvars, indepvar_status :== 0 :| indepvar_status :== 3)
	datavars_bn = select(allvars_bn, indepvar_status :== 0 :| indepvar_status :== 3)

	dict = asarray_create("string", 1)
	asarray_notfound(dict, 0)
	for (i=1; i<=cols(datavars);i++) {
	    asarray(dict, datavars[i], i)
	}
	
	for (i=1; i<=cols(vars);i++) {
		// Within the variables in solution.data , what's the position of vars[i] ?
		posof = asarray(dict, vars[i])
		if (posof) {
			assert(vars[i] == datavars[posof])
			fixedvars = fixedvars, datavars[posof]
			fixedvars_bn = fixedvars_bn , datavars_bn[posof]
			index = index, posof
		}
	}
}


void summarize_fes(class FixedEffects scalar HDFE, class FixedEffects scalar HDFE_Singletons)
{
// number of groups, number of singletons probably due to this FE,
// avg count per group, max count per group (THIS IS WHAT XTREG, FE OUTPUTS.. obs per group min avg max)
	real scalar g, G
	real scalar sum_singletons
	real matrix output
	real matrix min_max
	string matrix rowstripe
	string matrix colstripe

	G = HDFE_Singletons.G
	assert(G == HDFE_Singletons.G)

	output = J(G+2, 6, .)
	rowstripe = J(G+2, 2, "")

	colstripe = J(6, 2, "")
	colstripe[1::3, 1] = J(3, 1, "Number of ...")
	colstripe[1, 2] = "Observations"
	colstripe[2, 2] = "Groups"
	colstripe[3, 2] = "Singletons"
	colstripe[4::6, 1] = J(3, 1, "Observations per group")
	colstripe[4, 2] = "Min."
	colstripe[5, 2] = "Avg."
	colstripe[6, 2] = "Max."

	sum_singletons = 0
	for (g=1; g<=G; g++) {
		rowstripe[g, 2] = invtokens(HDFE.factors[g].ivars, "#")
		output[g, 1] = HDFE_Singletons.N
		output[g, 2] = HDFE_Singletons.factors[g].num_levels
		output[g, 3] = sum(HDFE_Singletons.factors[g].counts:==1)
		sum_singletons = sum_singletons + output[g, 3]
		min_max = minmax(HDFE_Singletons.factors[g].counts)
		output[g, 4] = min_max[1]
		output[g, 5] = mean(HDFE_Singletons.factors[g].counts)
		output[g, 6] = min_max[2]
	}
	rowstripe[G+1, 2] = "Joint singletons"
	rowstripe[G+2, 2] = "Total singletons"
	output[G+1, 3] = HDFE.num_singletons - sum_singletons
	output[G+2, 3] = HDFE.num_singletons

	st_matrix("sumhdfe_fes", output)
	st_matrixrowstripe("sumhdfe_fes", rowstripe)
	st_matrixcolstripe("sumhdfe_fes", colstripe)

	st_numscalar("r(num_singletons)", HDFE.num_singletons)
	st_global("r(fraction_singletons)", sprintf("%3.1f", 100*HDFE.num_singletons/(HDFE.N+HDFE.num_singletons)))
}



void summarize_variation(string rowvector vars, string rowvector vars_bn, real rowvector index,
						 class FixedEffects scalar HDFE, class FixedEffects scalar HDFE_Singletons)
{
	real rowvector means, tss, rss
	real vector pooled_stdevs, within_stdevs
	real vector r2
	real scalar N_sd
	real matrix output, data
	real matrix partial_r2s
	string matrix colstripe, rowstripe
	string vector tweaked_absvars
	real scalar g, G, poolsize
	real vector resids

	G = HDFE.G
	poolsize = HDFE.poolsize
	assert(G == HDFE_Singletons.G)
	assert(poolsize == HDFE_Singletons.poolsize)

	// Compute rss and within stdevs using sample that EXCLUDES singletons
	data = HDFE.solution.data[., index] :* HDFE.solution.stdevs[., index]
	rss = diagonal(quadcross(data, HDFE.weights, data)) // this has the same values in the samples with and without singletons (by definition!); and already has mean zero
	N_sd = HDFE.has_weights ? sum(HDFE.weights) : rows(data)
	within_stdevs = sqrt(rss :/ (N_sd - 1))

	// Compute pooled stdevs using sample that INCLUDES singletons
	data = st_data_pool(HDFE_Singletons.sample, vars_bn, poolsize)
	means = mean(data, HDFE_Singletons.weights)
	tss = diagonal(quadcrossdev(data, means, HDFE_Singletons.weights, data, means)) // Compute denominator of R2 (TSS) using sample that INCLUDES singletons
	N_sd = HDFE_Singletons.has_weights ? sum(HDFE_Singletons.weights) : rows(data)
	pooled_stdevs = sqrt(tss :/ (N_sd - 1))

	// Compute R2s (computed AS IF we use the sample that INCLUDES singletons)
	r2 = 1 :- rss :/ tss

	// Compute R2s with respect to one FE at a time, using sample that INCLUDES singletons
	partial_r2s = J(cols(data), G, .)
	// We cannot run project_one_fe() with FE slopes i.e. a("group#c.var") if we haven't precomputed certain objects
		HDFE_Singletons.technique = "map"
		HDFE_Singletons.update_preconditioner()
	for (g=1; g<=G; g++) {
		resids = data - HDFE_Singletons.project_one_fe(data, g)
		partial_r2s[., g] = diagonal(quadcross(resids, HDFE_Singletons.weights, resids))
	}
	partial_r2s = 1 :- partial_r2s :/ tss

	// Construct results matrix
	output = J(cols(data), 1, HDFE.N), pooled_stdevs, within_stdevs, 100 * within_stdevs :/ pooled_stdevs, partial_r2s, r2

	// Construct row headers
	rowstripe = J(cols(vars), 1, "") , vars'

	// Construct column headers
	colstripe = J(5 + HDFE.G, 2, "")
	// It seems we can't have "." (as in c.price) or "##" (as in turn#c.price) as colstripes
		tweaked_absvars = HDFE.absvars'
		tweaked_absvars = subinstr(tweaked_absvars, "i.", "")
		tweaked_absvars = subinstr(tweaked_absvars, "c.", "C=")
		tweaked_absvars = subinstr(tweaked_absvars, "##", "@")
	// Stdev headers
		colstripe[1, 2] = "N*"
		colstripe[2::4, 1] = J(3, 1, "Std. Dev.")
		colstripe[2, 2] = "Pooled"
		colstripe[3, 2] = "Within*"
		colstripe[4, 2] = "Ratio (%)" // Use NBSP instead of Space: https://en.wikipedia.org/wiki/Non-breaking_space
	// R2 headers
		colstripe[(5..rows(colstripe)-1), 1] = J(HDFE.G, 1, "R2 by fixed effect")
		colstripe[(5..rows(colstripe)-1), 2] = tweaked_absvars
		colstripe[rows(colstripe), 1] = "R2"
		colstripe[rows(colstripe), 2] = "Overall"

	// Add results matrix to Stata
	st_matrix("sumhdfe_variation", output)
	st_matrixrowstripe("sumhdfe_variation", rowstripe)
	st_matrixcolstripe("sumhdfe_variation", colstripe)
}


void summarize_zero_variation(string rowvector vars, string rowvector vars_bn, class FixedEffects scalar HDFE)
{
	real scalar g, i, n
	real matrix data, resids, output
	real rowvector idx
	string matrix colstripe
	string matrix rowstripe

	n = cols(vars)
	rowstripe = J(n, 1, "") , vars'
	output = J(n, 2+2*HDFE.G, .)
	colstripe = J(2+2*HDFE.G, 2, "")
	data = st_data_pool(HDFE.sample, vars_bn, HDFE.poolsize) // st_data(HDFE.sample, vars_bn)

	colstripe[1::2, 1] = J(2, 1, "Number of ...")
	colstripe[1, 2] = "Obs"
	colstripe[2, 2] = "Singl"
	output[., 1] = J(n, 1, HDFE.N + HDFE.num_singletons)
	output[., 2] = J(n, 1, HDFE.num_singletons)

	// A variable has zero variation within a group if sum(abs(..)) is zero
	HDFE.technique = "map"
	HDFE.update_preconditioner()
	for (g=1; g<=HDFE.G; g++) {
		resids = data - HDFE.project_one_fe(data, g)
		_edittozerotol(resids, HDFE.tolerance) // Should we be MORE or less aggressive than the reghdfe tolerance?
		resids = abs(resids)
		resids = panelsum(HDFE.factors[g].sort(resids), HDFE.factors[g].info)
		for (i=1; i<=n; i++) {
			idx = selectindex(!resids[., i])
			output[i, 2+2*g-1] = rows(idx)
			output[i, 2+2*g] = sum(HDFE.factors[g].counts[idx])
		}
		colstripe[2+2*g-1, 1] = colstripe[2+2*g, 1] = invtokens(HDFE.factors[g].ivars, "#") :+ "*"
		colstripe[2+2*g-1, 2] = "#Groups"
		colstripe[2+2*g, 2] = "#Obs"
	}

	st_matrix("sumhdfe_zero_variation", output)
	st_matrixcolstripe("sumhdfe_zero_variation", colstripe)
	st_matrixrowstripe("sumhdfe_zero_variation", rowstripe)
}


void fe_histogram(class FixedEffects scalar HDFE, real scalar g)
{
	real vector counts
	real vector idx

	assert_msg(g<=HDFE.G, sprintf("Cannot build histogram of %g-nd FE if there are only %g FEs", g, HDFE.G), 123, 0)
	
	counts = HDFE.factors[g].counts
	idx = 1::HDFE.factors[g].num_levels

	mata: st_store(idx, st_addvar("long", "sumhdfe_hist", 0), counts)
}

end

exit
