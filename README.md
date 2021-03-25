<p align="center">  
 <a href="https://opensource.org/licenses/MIT"><img src="https://img.shields.io/badge/license-MIT-blue.svg"></a>
</p>

<p align="left">
  <strong>SUMHDFE</strong> is a Stata package that produces summary and diagnostic information to characterize the frequency of fixed effects and within-fixed-effect variation in variables in linear models.  
 
See <a href="https://papers.ssrn.com/sol3/papers.cfm?abstract_id=3699777">deHaan (2021)</a> for discussion of within-FE variation and for explanation of the diagnostics produced by sumhdfe. Sumhdfe complements Sergio Correia's <a href="https://github.com/sergiocorreia/reghdfe"><strong>reghdfe</strong></a> Stata package for fixed effect regression models.
   
If you find these diagnostics to be useful, please cite: deHaan, Ed. (2021). *Using and Interpreting Fixed Effects Models*. Available at SSRN: https://ssrn.com/abstract=3699777.
   
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
  * [Usage & Features](#using)
  * [File List](#files)
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



### **Dependencies**

- [`ftools`](http://scorreia.com/software/ftools/)
- [`reghdfe`](http://scorreia.com/software/reghdfe/)




<h2 id="using">Usage & Features</h2>

<!--- You can use `sumhdfe` in the following way: --->

See the Stata help file.

<h2 id="files">Files</h2>

The following files are in this Github directory

1) ...


<h2 id="changelog">Changelog</h2>

...
    
<h2 id="questions">Questions?</h2>

If you have questions or experience problems please use the `issues` tab of this repository.   

<h2 id="license">License</h2>  
....

