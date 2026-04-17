# Fitting Generalized Linear Models in Parallel

Function like [`glm`](https://rdrr.io/r/stats/glm.html) which can make
the computation in parallel. The function supports most families listed
in [`family`](https://rdrr.io/r/stats/family.html). See
"`vignette("parglm", "parglm")`" for run time examples.

## Usage

``` r
parglm(
  formula,
  family = gaussian,
  data,
  weights,
  subset,
  na.action,
  start = NULL,
  offset,
  control = list(...),
  contrasts = NULL,
  model = TRUE,
  x = FALSE,
  y = TRUE,
  ...
)

parglm.fit(
  x,
  y,
  weights = rep(1, NROW(x)),
  start = NULL,
  etastart = NULL,
  mustart = NULL,
  offset = rep(0, NROW(x)),
  family = gaussian(),
  control = list(),
  intercept = TRUE,
  ...
)
```

## Arguments

- formula:

  an object of class [`formula`](https://rdrr.io/r/stats/formula.html).

- family:

  a [`family`](https://rdrr.io/r/stats/family.html) object.

- data:

  an optional data frame, list or environment containing the variables
  in the model.

- weights:

  an optional vector of 'prior weights' to be used in the fitting
  process. Should be `NULL` or a numeric vector.

- subset:

  an optional vector specifying a subset of observations to be used in
  the fitting process.

- na.action:

  a function which indicates what should happen when the data contain
  `NA`s.

- start:

  starting values for the parameters in the linear predictor.

- offset:

  this can be used to specify an a priori known component to be included
  in the linear predictor during fitting.

- control:

  a list of parameters for controlling the fitting process. For
  parglm.fit this is passed to
  [`parglm.control`](https://remlapmot.github.io/parglm/reference/parglm.control.md).

- contrasts:

  an optional list. See the `contrasts.arg` of
  [`model.matrix.default`](https://rdrr.io/r/stats/model.matrix.html).

- model:

  a logical value indicating whether model frame should be included as a
  component of the returned value.

- x, y:

  For `parglm`: logical values indicating whether the response vector
  and model matrix used in the fitting process should be returned as
  components of the returned value.

  For `parglm.fit`: `x` is a design matrix of dimension `n * p`, and `y`
  is a vector of observations of length `n`.

- ...:

  For `parglm`: arguments to be used to form the default `control`
  argument if it is not supplied directly.

  For `parglm.fit`: unused.

- etastart:

  starting values for the linear predictor. Not supported.

- mustart:

  starting values for the vector of means. Not supported.

- intercept:

  logical. Should an intercept be included in the null model?

## Value

`glm` object as returned by [`glm`](https://rdrr.io/r/stats/glm.html)
but differs mainly by the `qr` element. The `qr` element in the object
returned by `parglm`(`.fit`) only has the \\R\\ matrix from the QR
decomposition.

## Details

The current implementation uses `min(as.integer(n / p), nthreads)`
threads where `n` is the number observations, `p` is the number of
covariates, and `nthreads` is the `nthreads` element of the list
returned by
[`parglm.control`](https://remlapmot.github.io/parglm/reference/parglm.control.md).
Thus, there is likely little (if any) reduction in computation time if
`p` is almost equal to `n`. The current implementation cannot handle
`p > n`.

## Examples

``` r
# mtcars has 32 rows, sufficient for 2 threads (>= 16 rows per thread)
f1 <- glm   (mpg ~ wt + hp, data = mtcars, family = Gamma(link = "log"))
f2 <- parglm(mpg ~ wt + hp, data = mtcars, family = Gamma(link = "log"),
             control = parglm.control(nthreads = 2L))
all.equal(coef(f1), coef(f2))
#> [1] TRUE
```
