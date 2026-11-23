# Introduction to the parglm package

The motivation for the `parglm` package is a parallel version of the
`glm` function. It solves the iteratively re-weighted least squares
using a QR decomposition with column pivoting with the `DGEQP3` function
from LAPACK. The computation is done in parallel as in the `bam`
function in the `mgcv` package. The cost is an additional \\O(Mp^2 +
p^3)\\ where \\p\\ is the number of coefficients and \\M\\ is the number
of chunks to be computed in parallel. The advantage is that you do not
need to compile the package with an optimized BLAS or LAPACK which
supports multithreading. The package also includes a method that
computes the Fisher information and then solves the normal equation as
in the `speedglm` package. This is faster but less numerically stable.

## Example of computation time

Below, we estimate a logistic regression with 1000000 observations and
50 covariates. We vary the number of cores being used with the
`nthreads` argument to `parglm.control`. The `method` argument sets
which method is used. `LINPACK` uses the same pivoted QR (`dqrdc2`) as
`glm.fit` for the final decomposition; `LAPACK` uses `DGEQP3` from
LAPACK throughout; and `FAST` solves the normal equations from the
Fisher information, similar to the `speedglm` package.

``` r

#####
# simulate
n # number of observations
#> [1] 1000000
p # number of covariates
#> [1] 50
set.seed(68024947)
X <- matrix(rnorm(n * p, 1/p, 1/sqrt(p)), n, ncol = p)
df <- data.frame(y = 1/(1 + exp(-(rowSums(X) - 1))) > runif(n), X)
```
