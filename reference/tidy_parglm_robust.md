# Tidy a parglm model with robust standard errors

A drop-in `tidy_fun` for
[`tbl_regression`](https://www.danieldsjoberg.com/gtsummary/reference/tbl_regression.html)
that computes heteroskedasticity-consistent (HC) or cluster-robust
confidence intervals via sandwich and lmtest.

## Usage

``` r
tidy_parglm_robust(
  x,
  vcov. = "HC3",
  conf.int = TRUE,
  conf.level = 0.95,
  exponentiate = FALSE,
  ...
)
```

## Arguments

- x:

  a `parglm` (or `glm`) model object.

- vcov.:

  the robust variance-covariance estimator. A string is passed as the
  `type` argument to
  [`vcovHC`](https://sandwich.R-Forge.R-project.org/reference/vcovHC.html)
  (e.g. `"HC3"`). A function is called as `vcov.(x)` and should return a
  covariance matrix (use this for cluster-robust SEs via
  [`vcovCL`](https://sandwich.R-Forge.R-project.org/reference/vcovCL.html)).
  A matrix is used directly. Defaults to `"HC3"`.

- conf.int:

  logical; whether to include confidence intervals.

- conf.level:

  confidence level for the intervals.

- exponentiate:

  logical; whether to exponentiate the estimate and confidence interval
  limits.

- ...:

  unused; present for compatibility with the `tidy_fun` interface of
  [`tbl_regression`](https://www.danieldsjoberg.com/gtsummary/reference/tbl_regression.html).

## Value

a `data.frame` with columns `term`, `estimate`, `std.error`,
`statistic`, `p.value`, and (when `conf.int = TRUE`) `conf.low` and
`conf.high`.

## Details

Pass this function as `tidy_fun` to
[`tbl_regression`](https://www.danieldsjoberg.com/gtsummary/reference/tbl_regression.html):


    # HC3 (default)
    tbl_regression(fit, tidy_fun = tidy_parglm_robust)

    # HC1
    tbl_regression(fit, tidy_fun = \(x, ...) tidy_parglm_robust(x, vcov. = "HC1", ...))

    # Cluster-robust
    tbl_regression(fit, tidy_fun = \(x, ...) tidy_parglm_robust(
      x, vcov. = \(m) sandwich::vcovCL(m, cluster = ~ cluster_var), ...))

## Examples

``` r
fp <- parglm(mpg ~ wt + hp, data = mtcars,
             control = parglm.control(nthreads = 1L))
if (requireNamespace("sandwich", quietly = TRUE) &&
    requireNamespace("lmtest",   quietly = TRUE)) {
  tidy_parglm_robust(fp)
}
#>                    term    estimate   std.error statistic      p.value
#> (Intercept) (Intercept) 37.22727012 2.229805403 16.695300 1.418047e-62
#> wt                   wt -3.87783074 0.768519050 -5.045849 4.515129e-07
#> hp                   hp -0.03177295 0.009385138 -3.385453 7.106078e-04
#>                conf.low   conf.high
#> (Intercept) 32.85693183 41.59760840
#> wt          -5.38410040 -2.37156108
#> hp          -0.05016748 -0.01337841
```
