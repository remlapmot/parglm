# Changelog

## parglm 0.2.0

CRAN release: 2026-07-06

- `parglm` now accepts factor, character, and logical responses for the
  binomial and quasibinomial families like `glm` does, and errors on
  numeric responses outside \[0, 1\].
- Fix an out-of-bounds write when a user-supplied `block_size` was
  rounded down below the number of coefficients. The block size is now
  kept at or above the number of coefficients.
- Zero the working response for zero-weight observations in the IWLS
  step so a non-finite value (e.g. from a zero `mu.eta`) cannot poison
  the QR decomposition.
- Fix `inverse_gaussian_identity::name()` which returned the name of the
  inverse link (internal).
- Remove the unused `R_F::R_rev_piv` member function.

## parglm 0.1.10

CRAN release: 2026-05-22

- Fix a few minor grammar errors in the documentation.
- Add missing include to fix build on MacOSX11.3.1 SDK.
- Fix thread_pool.h includes: add missing, remove unused, alphabetise.
- Ensure tests use a maximum of 2 cores due to CRAN requirement.

## parglm 0.1.9-1

CRAN release: 2026-05-14

- Add missing `<thread>` include to fix build on older Apple SDKs.

## parglm 0.1.9

CRAN release: 2026-05-12

- Add **biglm**, **fastglm**, **glm2**, and **mgcv** to the timing
  comparison in the parglm.Rmd vignette. And add some timings for fewer
  observations and fewer coefficients.
- Bump roxygen2 to 8.0.0
- Remove busy-wait polling in `qr_parallel::get_stacks_res`
- Return `eta` and `mu` from `parallelglm` to skip R-side recomputation
- Sum only upper triangle of per-chunk Fisher information in FAST path
- Drop `const` from `R_F` members to enable move semantics
- Hoist NA-zeroing of beta out of per-chunk workers
- Use thread_local index for `thread_pool::get_id`
- Skip intermediate matrix when reverse-pivoting R
- Cache parglm_supported keys to avoid rebuilding family objects per fit
- Change the default of `parglm.control(nthreads)` to be
  `parallelly::availableCores(omit = 1L)` to make better use of
  available cores
- Replace linked-list task queue with deque under single mutex
- Fuse X chunk copy and weight scaling into one memory pass
- Support [`quasibinomial()`](https://rdrr.io/r/stats/family.html) and
  [`quasipoisson()`](https://rdrr.io/r/stats/family.html) family
  specification
- Enable full compatibility with the sandwich package for robust
  standard errors, including adding comments to the parglm helpfile, a
  new vignette, and tests
- Add **fastglm**’s `method = 3L`, and **parglm**’s
  `parglm.control(method = "LAPACK")` to the benchmarks in the
  parglm.Rmd vignette
- Allow for two column response for family binomial and quasibinomial
- Fix issue with order in `summary.parglm` and `vcov.parglm`
- Warn rather than error when starting values cannot be found
- Add `confint.parglm` to fix profile and Wald CI compatibility, and to
  give compatibility with the **gtsummary** package (e.g.,
  [`gtsummary::tbl_regression()`](https://www.danieldsjoberg.com/gtsummary/reference/tbl_regression.html))
- Add `tidy_parglm_robust` for tidying a parglm model with robust
  standard errors
- Add **gtsummary** examples to the second vignette

## parglm 0.1.8

CRAN release: 2026-04-21

- Remove specification of C++11
- Amend `std::result_of` to `std::invoke_result` in a header file
- Fix infinite recursion in `QR_base::qyt` by removing `std::move`
- Require C++17 on Linux, macOS, and Windows
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
  then solves the normal equation as in **speedglm**.
- One change which decreased the computation time.
- Minor bug fixes.
