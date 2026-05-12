# Robust standard errors with parglm and the sandwich package

Since
[`parglm()`](https://remlapmot.github.io/parglm/dev/reference/parglm.md)
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

## Note

`model = TRUE` (the default in `parglm`) must be set so that the model
frame is stored, allowing `sandwich` to reconstruct the design matrix
internally.
