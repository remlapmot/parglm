# Auxiliary for Controlling GLM Fitting in Parallel

Auxiliary function for
[`parglm`](https://remlapmot.github.io/parglm/reference/parglm.md)
fitting.

## Usage

``` r
parglm.control(
  epsilon = 1e-08,
  maxit = 25,
  trace = FALSE,
  nthreads = parallelly::availableCores(omit = 1L),
  block_size = NULL,
  method = "LINPACK",
  nthreads_auto = missing(nthreads)
)
```

## Arguments

- epsilon:

  positive convergence tolerance.

- maxit:

  integer giving the maximal number of IWLS iterations.

- trace:

  logical indicating if output should be produced during estimation.

- nthreads:

  number of cores to use. Defaults to
  `parallelly::availableCores(omit = 1L)`, which leaves one core free.
  You may get the best performance by using all available physical cores
  if your data set is sufficiently large.

- block_size:

  number of observations to include in each parallel block.

- method:

  string specifying which method to use. Either `"LINPACK"`, `"LAPACK"`,
  or `"FAST"`.

- nthreads_auto:

  logical; for internal use only. Records whether `nthreads` was
  auto-detected (suppresses the thread-reduction warning when the
  dataset is small). Do not set this argument directly.

## Value

A list with components named as the arguments.

## Details

The `LINPACK` method uses the same QR method as
[`glm.fit`](https://rdrr.io/r/stats/glm.html) for the final QR
decomposition. This is the `dqrdc2` method described in
[`qr`](https://rdrr.io/r/base/qr.html). All other QR decompositions
except the last are made with `DGEQP3` from `LAPACK`. See Wood, Goude,
and Shaw (2015) for details on the QR method.

The `FAST` method computes the Fisher information and then solves the
normal equation. This is faster but less numerically stable.

## References

Wood, S.N., Goude, Y. & Shaw, S. (2015) Generalized additive models for
large datasets. Journal of the Royal Statistical Society, Series C
64(1): 139-155.

## Examples

``` r
# use one core
f1 <- parglm(mpg ~ wt + hp, data = mtcars, family = Gamma(link = "log"),
             control = parglm.control(nthreads = 1L))

# use two cores (mtcars has 32 rows, sufficient for 2 threads)
f2 <- parglm(mpg ~ wt + hp, data = mtcars, family = Gamma(link = "log"),
             control = parglm.control(nthreads = 2L))
all.equal(coef(f1), coef(f2))
#> [1] TRUE
```
