parglm
======

[![R-CMD-check](https://github.com/remlapmot/parglm/workflows/R-CMD-check/badge.svg)](https://github.com/remlapmot/parglm/actions)
[![CRAN version](https://www.r-pkg.org/badges/version/parglm)](https://CRAN.R-project.org/package=parglm)
[![CRAN RStudio mirror downloads](http://cranlogs.r-pkg.org/badges/parglm)](https://CRAN.R-project.org/package=parglm)

The `parglm` package provides a parallel estimation method  for generalized 
linear models without compiling with a multithreaded LAPACK or BLAS. You can install
the release version from CRAN with

```r
install.packages("parglm")
```

or install the development version from GitHub by calling:

```r
remotes::install_github("remlapmot/parglm")
```

See the [vignette](https://remlapmot.github.io/parglm/articles/parglm.html) for an example of run times and further details.
