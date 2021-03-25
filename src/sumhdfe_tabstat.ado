* Alternative to tabstat customized for sumhdfe
* Based on summarize
* Does not support by()
program define sumhdfe_tabstat, rclass
	syntax anything [if] [in] [aw fw], Statistics(string)
	local nvars : word count `anything'

	marksample touse

	Stats `statistics'
	local stats   `r(names)'			// mean, var, ...
	local expr    `r(expr)'				// r(mean), r(Var), ...
	local summopt `r(summopt)'			// either empty, "meanonly", or "detail"
	local nstats : word count `stats'

	tokenize `expr'
	forvalues i = 1/`nstats' {
	        local expr`i' ``i''
	}

	* compute the statistics
	tempname Stat
	mat `Stat' = J(`nstats',`nvars',0)
	mat colnames `Stat' = `anything'
	mat rownames `Stat' = `stats'

	forvalues i = 1/`nvars' {
		gettoken var anything : anything
	        qui summ `var' if `touse' [`weight'`exp'], `summopt'
	        forvalues j = 1/`nstats' {
	                mat `Stat'[`j',`i'] = `expr`j''
	        }
	}

	return matrix StatTotal `Stat'
end



* ---------------------------------------------------------------------------
* THIS PROGRAM FROM TABSTAT.ADO:
* ---------------------------------------------------------------------------

/* Stats str
   processes the contents() option. It returns in
     r(names)   -- names of statistics, separated by blanks
     r(expr)    -- r() expressions for statistics, separated by blanks
     r(summopt) -- option for summarize command (meanonly, detail)

   note: if you add statistics, ensure that the name of the statistic
   is at most 8 chars long.
*/
program define Stats, rclass
        if `"`0'"' == "" {
                local opt "mean"
        }
        else {
                local opt `"`0'"'
        }

        * ensure that order of requested statistics is preserved
        * invoke syntax for each word in input
        local class 0
        foreach st of local opt {
                local 0 = lower(`", `st'"')

                capt syntax [, n MEan sd Variance SUm COunt MIn MAx Range SKewness Kurtosis /*
                        */  SDMean SEMean p1 p5 p10 p25 p50 p75 p90 p95 p99 iqr q MEDian CV ]
                if _rc {
                        di in err `"unknown statistic: `st'"'
                        exit 198
                }

                if "`median'" != "" {
                        local p50 p50
                }
                if "`count'" != "" {
                        local n n
                }

                * class 1 : available via -summarize, meanonly-

                * summarize.r(N) returns #obs (note capitalization)
                if "`n'" != "" {
                        local n N
                }
                local s "`n'`min'`mean'`max'`sum'"
                if "`s'" != "" {
                        local names "`names' `s'"
                        local expr  "`expr' r(`s')"
                        local class = max(`class',1)
                }
                if "`range'" != "" {
                        local names "`names' range"
                        local expr  "`expr' r(max)-r(min)"
                        local class = max(`class',1)
                }

                * class 2 : available via -summarize-

                if "`sd'" != "" {
                        local names "`names' sd"
                        local expr  "`expr' r(sd)"
                        local class = max(`class',2)
                }
                if "`sdmean'" != "" | "`semean'"!="" {
                        local names "`names' se(mean)"
                        local expr  "`expr' r(sd)/sqrt(r(N))"
                        local class = max(`class',2)
                }
                if "`variance'" != "" {
                        local names "`names' variance"
                        local expr  "`expr' r(Var)"
                        local class = max(`class',2)
                }
                if "`cv'" != "" {
                        local names "`names' cv"
                        local expr  "`expr' (r(sd)/r(mean))"
                        local class = max(`class',2)
                }

                * class 3 : available via -detail-

                local s "`skewness'`kurtosis'`p1'`p5'`p10'`p25'`p50'`p75'`p90'`p95'`p99'"
                if "`s'" != "" {
                        local names "`names' `s'"
                        local expr  "`expr' r(`s')"
                        local class = max(`class',3)
                }
                if "`iqr'" != "" {
                        local names "`names' iqr"
                        local expr  "`expr' r(p75)-r(p25)"
                        local class = max(`class',3)
                }
                if "`q'" != "" {
                        local names "`names' p25 p50 p75"
                        local expr  "`expr' r(p25) r(p50) r(p75)"
                        local class = max(`class',3)
                }
        }

        return local names `names'
        return local expr  `expr'
        if `class' == 1 {
                return local summopt "meanonly"
        }
        else if `class' == 3 {
                return local summopt "detail"
        }

end
