cscript regsave adofile regsave

clear
adopath ++"../src"
set more off
tempfile t results
version 11
program drop _all

* 1. Store regression results in the active dataset:

 sysuse auto.dta, clear
 regress price mpg trunk headroom length
 regsave
 cf _all using "compare/examp1.dta"


* 2. Store regression results in a file:

 sysuse auto.dta, clear
 regress price mpg trunk headroom length
 regsave using `t', tstat covar(mpg trunk) replace
 use `t', clear
 cf _all using "compare/examp2.dta"

* 3. Store regression results in table form:
 sysuse auto.dta, clear
 regress price mpg trunk headroom length
 regsave, tstat pval table(regression_1, parentheses(stderr) brackets(tstat pval))
 cf _all using "compare/examp3.dta"

* 4. Store a user-created statistic and label a series of regressions:

 sysuse auto.dta, clear
 regress price mpg trunk headroom length if gear_ratio > 3
 regsave using `t', addlabel(scenario, gear ratio > 3, dataset, auto) replace
 regress price mpg trunk headroom length if gear_ratio <= 3
 regsave using `t', addlabel(scenario, gear ratio <=3, dataset, auto) append
 use "`t'", clear
 cf _all using "compare/examp4.dta"

* 5. Store regression results and add coefficient and standard error estimates for an additional variable:

 sysuse auto.dta, clear
 regress price mpg trunk headroom length
 local mycoef = _b[mpg]*5
 local mystderr = _se[mpg]*5
 regsave, addvar(mpg_5, `mycoef', `mystderr')
 cf _all using "compare/examp5.dta"


* 6. Run a series of regressions and outsheet them into a text file that can be opened by MS Excel:

 sysuse auto.dta, clear
 regress price mpg trunk headroom length
 regsave mpg trunk using `t', table(OLS_stderr, order(regvars r2)) replace
 regress price mpg trunk headroom length, robust
 regsave mpg trunk using `t', table(Robust_stderr, order(regvars r2)) append
 use `t', clear
 cf _all using "compare/examp6.dta"


* 7. Run a series of regressions and output the results in a nice LaTeX format that can be opened by Scientific Word. (This example requires the user-written command {help texsave:texsave to be installed.):

 sysuse auto.dta, clear
 regress price mpg trunk headroom length
 regsave mpg trunk using `t', table(OLS, order(regvars r2) format(%5.3f) parentheses(stderr) asterisk()) replace
 regress price mpg trunk headroom length, robust
 regsave mpg trunk using `t', table(Robust, order(regvars r2) format(%5.3f) parentheses(stderr) asterisk()) append
 use `t', clear
 replace var = subinstr(var,"_coef","",.)
 replace var = "" if strpos(var,"_stderr")!=0
 replace var = "R-squared" if var == "r2"
 rename var Variable
 cf _all using "compare/examp7.dta"
 
* regsave table example + autoid option (from Github)
sysuse auto, clear
local num = 1
local replace replace
foreach rhs in "mpg" "mpg weight" {
	foreach type in "Domestic" "Foreign" {
	
		reg price `rhs' if foreign=="`type'":origin, robust
		regsave using "`results'", pval autoid `replace' addlabel(rhs,"`rhs'",origin,"`type'") table(col_`num', asterisk(5 1) parentheses(stderr))
		local replace append
		local num = `num'+1
	}
}
use "`results'", clear
cf _all using "compare/regsave_tbl_autoid.dta"

* Test time series notation for one lag. Note there is a bug: you cannot specify F(1 3).ma with -regsave-
sysuse "tsline1.dta", clear
regress ar L.ar F1.ma S1.ma
regsave L1.ar F1.ma S1.ma using `t', replace addlabel(Scen, 1)
regress ar L1.ar F.ma S.ma
regsave L.ar F.ma S.ma using `t', append addlabel(Scen, 2)
regress ar F(1 3).ma L(1/3).ar
regsave F(1,3).ma L(1/3).ar using `t', append addlabel(Scen, 3)
use `t', clear
cf _all using "compare/ts0.dta"

* Test the order option, with time series variables and an added var
sysuse "tsline1.dta", clear
regress ar S2.ar
local mycoef = _b[S2.ar]*5
local mystderr = _se[S2.ar]*5
regsave, addvar(mpg 5, `mycoef', `mystderr')
cf _all using "compare/ts1.dta"
regsave S2.ar, addvar(mpg 5 somebad^&chars and a very long name, `mycoef', `mystderr') table(my_tbl, order(_cons))
cf _all using "compare/ts2.dta"
regsave S2.ar using `t', addvar(mpg 5, `mycoef', `mystderr') table(my_tbl, order(_cons)) replace		
regsave S2.ar using `t', table(my_tbl2, order(S2.ar r2 mpg)) append
use `t', clear
cf _all using "compare/ts3.dta"

* Equation example
sysuse auto, clear
gen selection = trunk>15
heckman price mpg, select(selection = rep78)
regsave mpg rep78, table(eqtbl)
cf _all using "compare/eq.dta"

* Wildcard example
sysuse auto, clear
regress price mpg rep78 headroom trunk turn
regsave t* mpg-headroom using "`t'", replace
use "`t'", clear
cf _all using "compare/wildcards.dta"

* Dprobit and coef/varmat examples
sysuse auto, clear
gen bin = price>8000
dprobit bin trunk mpg
regsave using "`t'", replace addlabel(Scenario, dfdx)
regsave using "`t'", coefmat(e(b)) varmat(e(V)) addlabel(Scenario, std) append
nlcom (ratio: _b[trunk]/_b[mpg])
regsave using "`t'", coefmat(r(b)) varmat(r(V)) addlabel(Scenario, nlcom) append
use "`t'", clear
cf _all using "compare/dprobit.dta"

* Asterisk examples
sysuse auto.dta, clear
regress price mpg trunk headroom length
regsave mpg trunk, table(OLS, order(regvars r2) format(%5.3f) parentheses(pval) asterisk(30 15)) pval
cf _all using "compare/asterisk.dta"

* ci examples
sysuse auto.dta, clear
regress price mpg trunk headroom length, level(80)
regsave mpg trunk, ci level(80) table(OLS, order(regvars r2) format(%5.3f) brackets(stderr))
cf _all using "compare/ci.dta"

* Factor variables
sysuse auto.dta, clear
regress price mpg foreign##c.trunk
regsave
cf _all using "compare/fv1.dta"
regsave 0b.foreign 1.foreign 1.foreign#c.trunk, table(test)
cf _all using "compare/fv2.dta"

* autoid
sysuse auto.dta, clear
regress price mpg
regsave using "`t'", replace autoid
regress price trunk
regsave using "`t'", append autoid
use "`t'", clear
cf _all using "compare/autoid1.dta"
sysuse auto.dta, clear
regress price mpg
regsave using "`t'", replace table(reg1) autoid
regress price trunk
regsave using "`t'", append table(reg2) autoid
use "`t'", clear
cf _all using "compare/autoid2.dta"

sysuse auto.dta, clear
regress price mpg trunk headroom length
regsave mpg trunk using `t', replace autoid
regress price mpg trunk headroom length, robust
regsave mpg trunk using `t', append autoid
use `t', clear
regsave_tbl using "`t'" if _id==1, replace name(_1) asterisk(10 5 1)
regsave_tbl using "`t'" if _id==2, append name(_2) asterisk(10 5 1)
use "`t'", clear
cf _all using "compare/autoid3.dta"

sysuse auto.dta, clear
regress price mpg
regsave using "`t'", replace autoid addlabel(strlabel,"string") table(reg1)
regress price trunk
regsave using "`t'", append autoid table(reg2)
use "`t'", clear
cf _all using "compare/autoid4.dta"

* Case where we don't have df
sysuse xtline1.dta, clear
xtreg calories day, cluster(person)
regsave , ci
cf _all using "compare/xt1.dta"
regsave, ci table(test) level(95)
cf _all using "compare/xt2.dta"

* df option
sysuse auto.dta, clear
regress price mpg trunk
regsave, p df(11)
cf _all using "compare/df.dta"

regsave, p table(df, asterisk())
list
regsave, p df(3) table(df, asterisk())
list
regsave, df(3) table(df, asterisk())
list
regsave, table(df, asterisk())
list


* Typecast missing values in addlabel() correctly
clear
set seed 29
set obs 3
gen y = uniform()
gen x = uniform()
regress y x
regsave using "`t'", addlabel(F,`e(F)') replace
regress y x in 1/2
regsave using "`t'", addlabel(F,`e(F)') append
use "`t'", clear
cf _all using "compare/label_missing.dta"

* regsave_tbl
sysuse auto, clear
regress price mpg weight
regsave
regsave_tbl, name(test) asterisk(5 1)
cf _all using "compare/regsave_tbl.dta"

* texsave example
sysuse auto.dta, clear
regress price mpg trunk
regsave using `t', table(reg1, order(regvars r2) format(%5.1f) parentheses(stderr) asterisk(10 5)) replace
regress price mpg trunk headroom
regsave using `t', table(reg2, order(regvars r2) format(%5.1f) parentheses(stderr) asterisk(10 5)) append
regress price mpg trunk headroom length
regsave using `t', table(reg3, order(regvars r2) format(%5.1f) parentheses(stderr) asterisk(10 5)) append
use `t', clear
drop if strpos(var,"_cons")!=0
replace var = subinstr(var,"_coef","",.)
replace var = "" if strpos(var,"_stderr")!=0
replace var = "R-squared" if var == "r2"
replace var = "Observations" if var == "N"
rename var Regressor
cf _all using "compare/texsave_example.dta"

* Ensure that labels can contain quotes
sysuse auto, clear
reg price mpg
regsave, addlabel(scen,lim,sex,Male,race,Black,weight,pw, years,"years ")
cf _all using "compare/label_example.dta"

* Huebler example -- check that allnumeric is working correctly with allnumeric labels
sysuse auto, clear
reg mpg weight
local f = e(F)
regsave using `t', tstat pval table(reg1) replace
regsave using `t', tstat pval addlabel(F, `f') table(reg2) append
use "`t'", clear
cf _all using "compare/label_example2.dta"

* Problems when appending empty labels - currently there is no fix for this
sysuse auto, clear
regress price mpg weight
regsave using "`t'", addlabel(label1, "reg1",observations,`e(N)') replace
regsave using "`t'", addlabel(label1, "reg2",observations,"") append
use "`t'", clear

* Mi impute
clear
webuse mheart0
misstable summarize
mi set mlong
mi register imputed bmi
mi impute regress bmi attack smokes age female hsgrad, add(5) rseed(123)
mi estimate: logit attack smokes age bmi female hsgrad
regsave
cf _all using "compare/mi_estimate1.dta"

clear
webuse mheart0
misstable summarize
mi set mlong
mi register imputed bmi
mi impute regress bmi attack smokes age female hsgrad, add(5) rseed(123)
mi estimate, post: logit attack smokes age bmi female hsgrad
regsave
cf _all using "compare/mi_estimate2.dta"


* Test the saveold option
sysuse auto, clear
regress price mpg weight
regsave using "`t'", addlabel(label1, "reg1",observations,`e(N)') replace saveold(12)
regsave using "`t'", addlabel(label1, "reg2",observations,"") append saveold(12)
dtaversion "`t'"
assert r(version)==115

sysuse auto.dta, clear
regress price mpg trunk headroom length
regsave mpg trunk using `t', table(OLS, order(regvars r2) format(%5.3f) parentheses(stderr) asterisk()) replace saveold(13)
dtaversion "`t'"
assert r(version)==117

sysuse auto.dta, clear
regress price mpg trunk headroom length
cap regsave mpg trunk, table(OLS, order(regvars r2) format(%5.3f) parentheses(stderr) asterisk()) saveold(13)
assert _rc==198


* Make sure blanks for contents are allowed
sysuse auto, clear
reg price mpg
regsave , addlabel(y,"hlthst",blank,"",var3,"test3", blank2,,var4,"test4",var5,"test5")
cf _all using "compare/addlabels.dta"

* Generate error when user inserts a blank for the variable name
sysuse auto, clear
reg price mpg
cap regsave , addlabel(y,"hlthst",blank,"",var3,"test", blank2,,var4,"test4",,"test5")
assert _rc==198

* QC folder space bug
cap mkdir "folder with space"
sysuse auto, clear
reg price mpg
regsave using "folder with space/reg1.dta", replace
regsave using `"folder with space/reg2.dta"', replace
regsave using "folder with space/reg3.dta", table(test) replace
regsave using `"folder with space/reg4.dta"', table(test) replace
erase "folder with space/reg1.dta"
erase "folder with space/reg2.dta"
erase "folder with space/reg3.dta"
erase "folder with space/reg4.dta"
rmdir "folder with space"

* sigfig option
sysuse auto.dta, clear
replace price = price*3.2
regress price mpg trunk headroom length
regsave mpg trunk, table(OLS, sigfig(5) asterisk())
cf _all using "compare/sigfig1.dta"

sysuse auto.dta, clear
replace price = price/100
regress price mpg trunk headroom length
regsave mpg trunk, table(OLS, sigfig(3) asterisk())
cf _all using "compare/sigfig2.dta"

regsave mpg trunk, table(OLS, sigfig(4) asterisk() parentheses(stderr) bracket(pval)) pval
cf _all using "compare/sigfig3.dta"

* sigfig trailing zero check - trunk_coef should be 259.0, not 259. 
sysuse auto.dta, clear
replace price = price*3.201
regress price mpg trunk headroom length
regsave mpg trunk, table(OLS, sigfig(4) asterisk())
cf _all using "compare/sigfig4.dta"

* Test whether missing standard errors are stored correctly with sigfig
sysuse auto.dta, clear
keep in 1/2
reg price mpg
regsave, rtable table(OLS, sigfig(4) asterisk())
cf _all using "compare/sigfig5.dta"

* leading zero following the decimal point check (mpg pval should be 0.00010 , not 0.0001)
sysuse auto.dta, clear
replace mpg = mpg+gear_ratio*.2
regress price mpg trunk headroom foreign
regsave, table(OLS, sigfig(2) asterisk()) p
cf _all using "compare/sigfig6.dta"

cap regsave mpg trunk, table(OLS, sigfig(4) format(%12.0fc) asterisk() parentheses(stderr) bracket(pval)) pval
assert _rc==198

cap regsave mpg trunk, table(OLS, sigfig(33) asterisk())
assert _rc==125

cap regsave mpg trunk, table(OLS, sigfig(2 2) asterisk())
assert _rc==123

* regsave_tbl and sigfig formatting
program drop _all
tempfile t
sysuse auto, clear
reg price mpg, robust
regsave using "`t'", t p autoid replace
use "`t'", clear
regsave_tbl using "`t'", name(test) asterisk(10 5 1) parentheses(stderr) sigfig(3) replace
use "`t'", clear
cf _all using "compare/sigfig7.dta"

* Confirm that N's larger than float size (eg N=16777217) are stored properly as double/long
set seed 10
clear
set obs 16777217
gen price = uniform()
_regress price
regsave
cf N using "compare/big_N.dta"

*********
* regsave_tbl
*********
tempfile t
* Example 1
sysuse auto.dta, clear
regress price mpg trunk headroom length
regsave, tstat pval table(regression_1, parentheses(stderr) brackets(tstat pval))
save "`t'", replace

* Example 2 

sysuse auto.dta, clear
regress price mpg trunk headroom length
regsave, tstat pval
list
regsave_tbl, name(regression_1) parentheses(stderr) brackets(tstat pval)
cf _all using "`t'"

* sig fig 
sysuse auto, clear
regress price mpg trunk headroom
regsave, tstat pval
regsave_tbl, name(regression_1) parentheses(stderr) brackets(tstat pval) asterisk(10 5 1) sigfig(4)
cf _all using "compare/sigfig_tbl.dta"

* Error handling
sysuse auto, clear
cap regsave_tbl, name(t)
assert _rc==198

reg price mpg
regsave
tostring coef, force replace
cap regsave_tbl, name(t)
assert _rc==198

* Ensure that large scalars and macros outside the normal integer/string storage range are saved correctly
program define big_returns, eclass
	regress price mpg trunk headroom length
	matrix b = e(b)
	matrix V = e(V)
	ereturn clear
	ereturn post b V
	ereturn scalar big_scalar=100000
	local big_macro = "t"*30000
	ereturn local big_macro = "`big_macro'"
end
sysuse auto.dta, clear
big_returns
regsave, detail(all)
cf _all using "compare/bigreturns.dta"


***
* rtable tests
***
* Source: use "https://stats.idre.ucla.edu/stat/stata/notes/lahigh", clear
use "compare/lahigh.dta", clear

poisson daysabs mathnce langnce, irr

regsave, pval tstat ci rtable
cf _all using "compare/rtable1.dta"

regsave, pval tstat ci
cf _all using "compare/rtable2.dta"

use "compare/lahigh.dta", clear
poisson daysabs mathnce langnce, irr
cap regsave, pval tstat ci rtable covar(langnce mathnce)
assert _rc==198
cap regsave, pval tstat ci rtable coefmat(e(b))
assert _rc==198

* other examples that didn't use the rtable option should also work here with the table option
sysuse auto.dta, clear
regress price mpg trunk headroom length, level(80)
regsave mpg trunk, ci level(80) table(OLS, order(regvars r2) format(%5.3f) brackets(stderr)) rtable
cf _all using "compare/ci.dta"

sysuse auto.dta, clear
regress price mpg foreign##c.trunk
regsave, rtable
replace stderr=0 if mi(stderr)
cf _all using "compare/fv1.dta"
sysuse auto.dta, clear
regress price mpg foreign##c.trunk
regsave 0b.foreign 1.foreign 1.foreign#c.trunk, table(test) rtable
replace test = 0 if mi(test)
cf _all using "compare/fv2.dta"

sysuse auto.dta, clear
regress price mpg trunk headroom length
local mycoef = _b[mpg]*5
local mystderr = _se[mpg]*5
regsave, addvar(mpg_5, `mycoef', `mystderr') rtable
cf _all using "compare/examp5.dta"


** EOF

