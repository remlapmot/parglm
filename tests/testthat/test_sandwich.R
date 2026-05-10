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
