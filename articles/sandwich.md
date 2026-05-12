# Robust standard errors with parglm and the sandwich package and regression tables with gtsummary

Since
[`parglm()`](https://remlapmot.github.io/parglm/reference/parglm.md)
returns a standard `glm` object, it works directly with the
[`sandwich`](https://cran.r-project.org/package=sandwich) package for
heteroskedasticity-consistent (HC) and cluster-robust standard errors.
The [`lmtest`](https://cran.r-project.org/package=lmtest) package
provides [`coeftest()`](https://rdrr.io/pkg/lmtest/man/coeftest.html)
for displaying results with alternative covariance matrices.

## Setup

``` r

library(parglm)
library(sandwich)
library(lmtest)
```

We simulate a Poisson dataset with 20 clusters of 10 observations each,
where a cluster-level random effect induces within-cluster correlation.

``` r

set.seed(1)
n          <- 200
cluster_id <- rep(1:20, each = 10)
x1         <- rnorm(n)
x2         <- rnorm(n)
u          <- rep(rnorm(20, sd = 0.5), each = 10)  # cluster random effect
y          <- rpois(n, exp(0.5 + 0.3 * x1 - 0.2 * x2 + u))
dat        <- data.frame(y = y, x1 = x1, x2 = x2, cluster = cluster_id)
```

## Fitting the model

``` r

fit <- parglm(y ~ x1 + x2, data = dat, family = poisson(),
              control = parglm.control(nthreads = 1L))
```

## Standard errors

The default model-based standard errors assume the Poisson variance
equals the mean. They will be too small here because the cluster random
effects induce overdispersion.

``` r

coeftest(fit)
#> 
#> z test of coefficients:
#> 
#>             Estimate Std. Error z value  Pr(>|z|)    
#> (Intercept)  0.68030    0.05198 13.0877 < 2.2e-16 ***
#> x1           0.30156    0.05228  5.7681 8.015e-09 ***
#> x2          -0.23389    0.04742 -4.9322 8.129e-07 ***
#> ---
#> Signif. codes:  0 '***' 0.001 '**' 0.01 '*' 0.05 '.' 0.1 ' ' 1
```

## Heteroskedasticity-consistent (HC) standard errors

[`vcovHC()`](https://sandwich.R-Forge.R-project.org/reference/vcovHC.html)
computes sandwich standard errors that are robust to misspecification of
the variance function. HC3 (the default) is recommended for small to
moderate samples.

``` r

coeftest(fit, vcov = vcovHC)
#> 
#> z test of coefficients:
#> 
#>              Estimate Std. Error z value  Pr(>|z|)    
#> (Intercept)  0.680296   0.069394  9.8034 < 2.2e-16 ***
#> x1           0.301561   0.078775  3.8281 0.0001291 ***
#> x2          -0.233887   0.058692 -3.9850 6.749e-05 ***
#> ---
#> Signif. codes:  0 '***' 0.001 '**' 0.01 '*' 0.05 '.' 0.1 ' ' 1
```

## Cluster-robust standard errors

[`vcovCL()`](https://sandwich.R-Forge.R-project.org/reference/vcovCL.html)
accounts for within-cluster correlation, which is the appropriate
correction here.

``` r

coeftest(fit, vcov = vcovCL, cluster = ~cluster)
#> 
#> z test of coefficients:
#> 
#>              Estimate Std. Error z value  Pr(>|z|)    
#> (Intercept)  0.680296   0.130871  5.1982 2.012e-07 ***
#> x1           0.301561   0.045306  6.6561 2.813e-11 ***
#> x2          -0.233887   0.059090 -3.9581 7.554e-05 ***
#> ---
#> Signif. codes:  0 '***' 0.001 '**' 0.01 '*' 0.05 '.' 0.1 ' ' 1
```

As expected, the cluster-robust standard errors are larger than the
model-based ones, reflecting the extra variability due to the cluster
random effects.

## Covariance matrices directly

The covariance matrices themselves are also available:

``` r

vcovHC(fit, type = "HC3")
#>               (Intercept)            x1           x2
#> (Intercept)  0.0048154924 -1.496148e-03 1.564757e-04
#> x1          -0.0014961477  6.205443e-03 9.089414e-05
#> x2           0.0001564757  9.089414e-05 3.444771e-03
vcovCL(fit, cluster = ~cluster)
#>               (Intercept)            x1            x2
#> (Intercept)  0.0171271937  0.0006650872 -0.0006143826
#> x1           0.0006650872  0.0020526462 -0.0002594062
#> x2          -0.0006143826 -0.0002594062  0.0034916456
```

### Note

`model = TRUE` (the default in `parglm`) must be set so that the model
frame is stored, allowing `sandwich` to reconstruct the design matrix
internally.

## Regression tables with gtsummary

The [`gtsummary`](https://cran.r-project.org/package=gtsummary) package
produces publication-ready regression tables from model objects.
[`parglm()`](https://remlapmot.github.io/parglm/reference/parglm.md)
models are supported directly because they inherit from `glm`.

``` r

library(gtsummary)
```

### Logistic regression

We fit a logistic regression model with
[`parglm()`](https://remlapmot.github.io/parglm/reference/parglm.md) and
pass it to
[`tbl_regression()`](https://www.danieldsjoberg.com/gtsummary/reference/tbl_regression.html).
Setting `exponentiate = TRUE` displays odds ratios with their confidence
intervals.

``` r

set.seed(2)
n2    <- 300
x1_b  <- rnorm(n2)
x2_b  <- rnorm(n2)
y_bin <- rbinom(n2, 1, plogis(0.4 + 0.6 * x1_b - 0.4 * x2_b))
dat_b <- data.frame(y = y_bin, x1 = x1_b, x2 = x2_b)

fit_logistic <- parglm(y ~ x1 + x2, data = dat_b, family = binomial(),
                       control = parglm.control(nthreads = 1L))

suppressWarnings(
  tbl_regression(fit_logistic, exponentiate = TRUE)
)
```

| **Characteristic** | **OR** | **95% CI** | **p-value** |
|----|----|----|----|
| x1 | 1.50 | 1.20, 1.90 | \<0.001 |
| x2 | 0.73 | 0.57, 0.93 | 0.012 |
| Abbreviations: CI = Confidence Interval, OR = Odds Ratio |  |  |  |

### Robust standard errors in a gtsummary table

[`tidy_parglm_robust()`](https://remlapmot.github.io/parglm/reference/tidy_parglm_robust.md)
is a drop-in `tidy_fun` for
[`tbl_regression()`](https://www.danieldsjoberg.com/gtsummary/reference/tbl_regression.html)
that replaces the default model-based standard errors with sandwich
estimates. Here we use cluster-robust standard errors for the Poisson
model fitted earlier.

``` r

tbl_regression(fit, tidy_fun = tidy_parglm_robust)
```

| **Characteristic** | **log(IRR)** | **95% CI** | **p-value** |
|----|----|----|----|
| x1 | 0.30 | 0.15, 0.46 | \<0.001 |
| x2 | -0.23 | -0.35, -0.12 | \<0.001 |
| Abbreviations: CI = Confidence Interval, IRR = Incidence Rate Ratio |  |  |  |
