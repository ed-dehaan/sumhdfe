<h1 align="center">
   <img src="#" alt="sumhdfe" title="sumhdfe" />
</h1>
<p align="center">  
 <a href="https://opensource.org/licenses/MIT"><img src="https://img.shields.io/badge/license-MIT-blue.svg"></a>
</p>

<p align="left">
  <strong>Sumhdfe</strong> is a Stata package that produces summary and diagnostic information to characterize within-fixed-effect variation in regression variables.  See <a href="https://papers.ssrn.com/sol3/papers.cfm?abstract_id=3699777">deHaan (2021)</a> for discussion of within-FE variation and for further explanation of the sumhdfe diagnostics.
 <br> <br>
  <span><strong>Authors:</strong> <br>
  <a href="http://scorreia.com/">Sergio Correia</a><br>
  <a href="https://foster.uw.edu/faculty-research/directory/ed-dehaan/">Ed deHaan</a><br>
  <a href="http://www.TiesdeKok.com">Ties de Kok</a><br>
  </span><br>
  <span><strong>Help file: </strong><a href="#">link</a></span>
</p>

## Table of contents

  * [Install Sumhdfe](#install) 
  * [Using sumhdfe](#using)
  * [File List](#files)
  * [Features List](#features)
  * [Changelog](#changelog)
  * [Questions?](#questions)
  * [License](#license)


## Installing `sumhdfe`

```stata
* Define development directory
local devDir "E:\Dropbox\Work\Programming\active\sumhdfe"

* Install ftools from dev branch
cap ado uninstall ftools
net install ftools, from("https://raw.githubusercontent.com/sergiocorreia/ftools/groupreg/src/")

* Install reghdfe from dev branch
cap ado uninstall reghdfe
net install reghdfe, from("https://raw.githubusercontent.com/sergiocorreia/reghdfe/reghdfe6/src/")

cap ado uninstall sumhdfe
net install sumhdfe, from("`devDir'\src")
```

### TODO

- If we receive `sumhfe x2 x3` only summarize these variables



### **Dependencies**

- [`ftools`](http://scorreia.com/software/ftools/)
- [`reghdfe`](http://scorreia.com/software/reghdfe/)




<h2 id="using">Using <i>sumhdfe</i></h2>

<!--- You can use `sumhdfe` in the following way: --->

See the Stata help file for usage instructions.

<h2 id="files">Files</h2>

The following files are in this Github directory

1) make_data.do - 		this do file creates a test dataset
2) sumhdfe.ado - 		rough version of the ado file 
3) sumhdfe_data.dta - 	dataset produced by make_data.do
4) sumhdfe_example.do -	simple do file to call sumhdfe using the example data
5) sumhdfe example table - Excel file showing table mockup.  Contains notes on what else to include

<h2 id="features">Features List</h2>

See the Stata help file.


<h2 id="changelog">Changelog</h2>

...
    
<h2 id="questions">Questions?</h2>

If you have questions or experience problems please use the `issues` tab of this repository.   

<h2 id="license">License</h2>  
....

