# Changelog

## parglm (development version)

- Add biglm, fastglm, glm2, and mgcv to the timing comparison in the
  vignette. And add some timings for fewer observations and fewer
  coefficients.
- Bump roxygen2 to 8.0.0
- Remove busy-wait polling in qr_parallel::get_stacks_res
- Return eta and mu from parallelglm to skip R-side recomputation
- Sum only upper triangle of per-chunk Fisher information in FAST path
- Drop const from R_F members to enable move semantics
- Hoist NA-zeroing of beta out of per-chunk workers
- Use thread_local index for thread_pool::get_id
- Skip intermediate matrix when reverse-pivoting R
- Cache parglm_supported keys to avoid rebuilding family objects per fit
- Change the default of `parglm.control(nthreads)` to be
  `parallelly::availableCores(omit = 1L)` to make better use of
  available cores
- Implement persistent thread pool
- Replace linked-list task queue with deque under single mutex
- Fuse X chunk copy and weight scaling into one memory pass
- Support [`quasibinomial()`](https://rdrr.io/r/stats/family.html) and
  [`quasipoisson()`](https://rdrr.io/r/stats/family.html) family
  specification
- Enable full compatibility with the sandwich package for robust
  standard errors, including adding comments to the parglm helpfile, a
  new vignette, and tests
- Add fastglm’s `method = 3L` to the benchmarks in the parglm vignette
- Allow for two column response for family binomial and quasibinomial
- Fix issue with order in `summary.glm`
- Warn rather than error when starting values cannot be found

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
  then solves the normal equation as in `speedglm`.
- One change which decreased the computation time.
- Minor bug fixes.
