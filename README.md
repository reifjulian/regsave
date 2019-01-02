# REGSAVE: extract and store regression results

- Current version: `1.4.4 16may2018`
- Jump to: [`updates`](#recent-updates) [`install`](#install) [`description`](#description) [`author`](#author)

-----------

## Updates:

* **December 31, 2018**
  - Added the help file `regsave_tbl.hlp` to installation package
  - Added error catching code to `regsave_tbl.ado`

## Install:

Type `which regsave` at the Stata prompt to determine which version you have installed. To install the most recent version of `regsave`, copy/paste the following line of code:

```
net install regsave, from("https://raw.githubusercontent.com/reifjulian/regsave/master") replace
```

To install the version that was uploaded to SSC, copy/paste the following line of code:
```
ssc install regsave, replace
```

These two versions are typically synced, but occasionally the SSC version may be slightly out of date.

## Description: 

`regsave` is a [Stata](http://www.stata.com) command that fetches estimation results from `e()` and stores them in "wide" format (default) or "table" format:

- By default, results are stored in wide format. Use this format when you want to further analyze your regression results using Stata.

- If you specify the `table()` option, results are stored in table format.  You can then outsheet those results to a text file, or use texsave (if installed) to output your table in LaTeX format (see example 6 below). Use the `table()` option when you want to create a publication-quality table.

The helper command `regsave_tbl` converts the dataset in memory from wide format to table format.

For more details, see the Stata help file included in this package.

## Author:

[Julian Reif](http://www.julianreif.com)
<br>University of Illinois
<br>jreif@illinois.edu
