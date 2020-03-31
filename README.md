# REGSAVE: extract and store regression results

- Current regsave version: `1.4.8 25oct2019`
- Current regsave_tbl version: `1.1.8 30mar2020`
- Jump to:  [`overview`](#overview) [`installation`](#installation) [`tutorial`](#tutorial) [`updates`](#update-history) [`author`](#author)

-----------

## Overview

`regsave` is a [Stata](http://www.stata.com) command that fetches estimation results from `e()` and stores them in "wide" format (default) or "table" format:

- By default, results are stored in wide format. Use this format when you want to further analyze your regression results using Stata.

- If you specify the `table()` option, results are stored in table format.  You can then outsheet those results to a text file, or use [texsave](https://github.com/reifjulian/texsave) to output your table in LaTeX format (see example below). Use the `table()` option when you want to create a publication-quality table.

The helper command `regsave_tbl` converts the dataset in memory from wide format to table format.

For more details, see the Stata help file included in this package.

## Installation

```stata
* Determine which version of -regsave- you have installed
which regsave
which regsave_tbl

* Install the most recent version of -regsave-
net install regsave, from("https://raw.githubusercontent.com/reifjulian/regsave/master") replace
```

## Tutorial

This tutorial assumes you have already [installed](#installation) the `regsave` Stata package. Here is code that opens up Stata's built in dataset and regresses automobile price on miles per gallaon and/or weight. We will do this for two different types of automobiles: domestic cars and foreign cars. We will save the results of each regression to a tempfile, and then display the contents of that file at the end.

```stata
tempfile results
sysuse auto, clear

local replace replace
foreach rhs in "mpg" "mpg weight" {
	foreach type in "Domestic" "Foreign" {
	
		reg price `rhs' if foreign=="`type'":origin, robust
		regsave using "`results'", pval autoid `replace' addlabel(rhs,"`rhs'",origin,"`type'") 
		local replace append
	}
}

use "`results'", clear
list
```

The contents of the dataset, as displayed by `list`, look like this:
![Stata regsave output](images/stata_regsave_list.png)

We could also have saved t statistics or confidence intervals by specifying the appropriate options. (Type `help regsave` at the Stata prompt to see the full set of options.)

The `table()` option saves results in a "wide" format that is more appropriate for creating tables. The following code runs the same regressions as above, but saves the output in table format.

```stata
tempfile results_tbl
sysuse auto, clear

local num = 1
local replace replace
foreach rhs in "mpg" "mpg weight" {
	foreach type in "Domestic" "Foreign" {
	
		reg price `rhs' if foreign=="`type'":origin, robust
		regsave using "`results_tbl'", pval autoid `replace' addlabel(rhs,"`rhs'",origin,"`type'") table(col_`num', asterisk(5 1) parentheses(stderr))
		local replace append
		local num = `num'+1
	}
}

use "`results_tbl'", clear
list
```

You can also convert a dataset saved by `regsave` directly into a table by using the helper command `regsave_tbl`.

## Update History
  
* **October 25, 2019**
  - Added `rtable` option
  
* **January 30, 2019**
  - N now stored as double/long for large datasets

* **January 26, 2019**
  - Added `sigfig()` option

* **December 31, 2018**
  - Added the help file `regsave_tbl.hlp` to installation package
  - Added error catching code to `regsave_tbl.ado`


## Author

[Julian Reif](http://www.julianreif.com)
<br>University of Illinois
<br>jreif@illinois.edu
