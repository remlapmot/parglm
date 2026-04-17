# Changelog

## parglm 0.1.8

- Remove specification of C++11
- Amend `std::result_of` to `std::invoke_result` in a header file
- New maintainer - Tom Palmer

## parglm 0.1.7

CRAN release: 2021-10-14

- Avoid some virtual function calls and remove a few macros.
- Fix an issue due to the new `STRICT_R_HEADERS` variable in Rcpp.

## parglm 0.1.6

CRAN release: 2020-08-10

- Avoid some memory allocations.
- Fix a test issue with ATLAS.

## parglm 0.1.4

CRAN release: 2020-01-07

- `stop`s when there are more variables than observations. Previously,
  this caused a crash.
- Handle Fortran string length argument.

## parglm 0.1.3

CRAN release: 2019-03-18

- Fix bug found with Valgrind.

## parglm 0.1.2

CRAN release: 2019-03-14

- Minor changes in implementation.
- Fix bugs in patched R and oldrel R.

## parglm 0.1.1

CRAN release: 2019-01-19

- A `FAST` method is added which computes the Fisher information and
  then solves the normal equation as in `speedglm`.
- One change which decreased the computation time.
- Minor bug fixes.
