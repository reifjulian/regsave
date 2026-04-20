# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

**regsave** is a Stata package that extracts estimation results from `e()` and stores them as Stata datasets. It has two commands:

- **regsave** (`src/regsave.ado`): Extracts regression results into wide format (default) or table format (via `table()` option).
- **regsave_tbl** (`src/regsave_tbl.ado`): Converts a wide-format dataset (created by regsave) into table format. This is a helper command.

Both commands have corresponding help files (`src/regsave.hlp`, `src/regsave_tbl.hlp`).

## Running Tests

Tests are in `test/regsave_tests.do` and run via Stata's `cscript` framework. The test script compares command output against 48 reference `.dta` files in `test/compare/`.

To run tests, execute from the `test/` directory in Stata:

```stata
do regsave_tests.do
```

Or in batch mode from the command line:

```
powershell.exe -Command "Start-Process -FilePath 'C:\Program Files\Stata19\StataMP-64.exe' -ArgumentList '/e do regsave_tests.do' -WorkingDirectory 'C:\Users\jreif\Documents\GitHub\regsave\test' -Wait -NoNewWindow"
```

The test log is written to `test/regsave_tests.log`. If all tests pass, the log ends with "end of do-file" without errors. Failures appear as `cf` comparison errors.

## Architecture

- `src/regsave.ado` — Core command. Extracts `e(b)` and `e(V)` matrices (or custom matrices via `coefmat`/`varmat`/`rtable` options), transposes them into a dataset with columns for coefficients, standard errors, and optionally t-stats, p-values, confidence intervals, covariances, and additional scalars. When the `table()` option is specified, it delegates formatting to `regsave_tbl`.
- `src/regsave_tbl.ado` — Reshapes wide-format regsave output into a publication-ready table with one string column per regression. Handles significance asterisks, parentheses/brackets formatting, and significant figures (`sigfig()` option).
- The two `.ado` files are coupled: `regsave` calls `regsave_tbl` internally when `table()` is specified. `regsave_tbl` can also be called standalone on a dataset previously created by `regsave`.

## Package Distribution

- `stata.toc` and `regsave.pkg` define the Stata package for `net install`. The `.pkg` file lists the four files under `src/` that are distributed.
- Users install via: `net install regsave, from("https://raw.githubusercontent.com/reifjulian/regsave/master") replace`

## Development Notes

- The test script adds the local `src/` directory to the adopath (`adopath ++"../src"`), so development changes to `.ado` files are picked up without reinstalling.
- Stata version compatibility: minimum Stata 8.2 (set in regsave.ado). The test script uses `version 11`.
- When updating reference test data, replace the corresponding `.dta` file in `test/compare/`.
- The `.gitignore` excludes `.log` files, so test logs are not committed.

## Git Commits

Do not add `Co-authored-by` trailers or sign yourself as a coauthor in commit messages.