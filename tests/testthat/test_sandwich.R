context("sandwich-compatible standard errors")

test_that("hatvalues and vcovHC HC0-HC3 match glm", {
  skip_if_not_installed("sandwich")

  set.seed(42)
  n  <- 200
  x1 <- rnorm(n)
  x2 <- rnorm(n)
  y  <- rpois(n, exp(0.5 + 0.3 * x1 - 0.2 * x2))
  dat <- data.frame(y = y, x1 = x1, x2 = x2)

  ctrl_glm    <- list(maxit = 25L, epsilon = .Machine$double.xmin)
  ctrl_parglm <- parglm.control(nthreads = 1L, maxit = 25L,
                                epsilon = .Machine$double.xmin)

  fglm  <- suppressWarnings(glm(y ~ x1 + x2, poisson(), dat,
                                control = ctrl_glm))
  fpar  <- parglm(y ~ x1 + x2, poisson(), dat, control = ctrl_parglm)

  tol <- .Machine$double.eps^(1/4)

  expect_equal(unname(hatvalues(fpar)), unname(hatvalues(fglm)),
               tolerance = tol, label = "hatvalues")

  for (type in c("HC0", "HC1", "HC2", "HC3")) {
    expect_equal(sandwich::vcovHC(fpar, type = type),
                 sandwich::vcovHC(fglm, type = type),
                 tolerance = tol, label = paste("vcovHC", type))
  }
})

test_that("vcovCL matches glm", {
  skip_if_not_installed("sandwich")

  set.seed(42)
  n          <- 200
  cluster_id <- rep(1:20, each = 10)
  x1         <- rnorm(n)
  x2         <- rnorm(n)
  y          <- rpois(n, exp(0.5 + 0.3 * x1 - 0.2 * x2))
  dat        <- data.frame(y = y, x1 = x1, x2 = x2, cluster = cluster_id)

  ctrl_glm    <- list(maxit = 25L, epsilon = .Machine$double.xmin)
  ctrl_parglm <- parglm.control(nthreads = 1L, maxit = 25L,
                                epsilon = .Machine$double.xmin)

  fglm <- suppressWarnings(glm(y ~ x1 + x2, poisson(), dat,
                               control = ctrl_glm))
  fpar <- parglm(y ~ x1 + x2, poisson(), dat, control = ctrl_parglm)

  expect_equal(sandwich::vcovCL(fpar, cluster = ~cluster),
               sandwich::vcovCL(fglm, cluster = ~cluster),
               tolerance = .Machine$double.eps^(1/4),
               label = "vcovCL")
})

test_that("working weights, hatvalues, vcovHC and vcovCL match glm with default convergence settings", {
  skip_if_not_installed("sandwich")

  # glm.fit() returns the working weights from the start of the final
  # iteration, i.e., those used to compute R. Without forcing full convergence
  # these differ from the weights at the final fitted values.
  set.seed(1)
  n   <- 2000
  dat <- data.frame(x1 = rnorm(n), g = factor(sample(letters[1:3], n, TRUE)),
                    w = runif(n, .5, 2), cluster = rep(1:(n / 2), 2))
  dat$y <- rbinom(n, 1, plogis(dat$x1 + (dat$g == "b")))

  fglm <- suppressWarnings(
    glm(y ~ x1 + g, binomial(), dat, weights = w))
  fpar <- suppressWarnings(
    parglm(y ~ x1 + g, binomial(), dat, weights = w,
           control = parglm.control(nthreads = 2L)))

  tol <- 1e-8
  expect_equal(fpar$iter, fglm$iter)
  expect_equal(fpar$weights, fglm$weights, tolerance = tol)
  expect_equal(hatvalues(fpar), hatvalues(fglm), tolerance = tol)
  expect_equal(sandwich::vcovHC(fpar, type = "HC0"),
               sandwich::vcovHC(fglm, type = "HC0"), tolerance = tol)
  expect_equal(sandwich::vcovCL(fpar, cluster = ~cluster, type = "HC0"),
               sandwich::vcovCL(fglm, cluster = ~cluster, type = "HC0"),
               tolerance = tol)
})
