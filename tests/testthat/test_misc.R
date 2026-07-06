context("Miscellaneous tests")

test_that("'parglm' works when package is not attached",{
  # Issue: https://github.com/boennecd/parglm/issues/2#issue-397286510
  # See https://github.com/r-lib/devtools/issues/1797#issuecomment-423288947

  expect_silent(
    local({
      detach("package:parglm", unload = TRUE, force = TRUE)
      parglm::parglm(mpg ~ gear , data = datasets::mtcars,
                     control = parglm::parglm.control(nthreads = 2L))
      library(parglm)
    },
    envir= new.env(parent = environment(glm))))
})

test_that("Using more threads then rows yields a warning", {
  # Issue: https://github.com/boennecd/parglm/issues/3#issue-399052270

  this_df <- data.frame( a = sample( 1:1000000 , 20 ) / 100 , b = 1 )
  expect_warning(
    parglm( a ~ b - 1, data = this_df , nthreads = 64),
    regexp = "Too few observations compared to the number of threads. 1 thread(s) will be used instead of 64.",
    fixed = TRUE)

  # should yield one thread (the number of rows is less than the number required
  # per thread)
  this_df <- data.frame( a = sample( 1:1000000 , 5 ) / 100 , b = 1 )
  expect_warning(
    parglm( a ~ b - 1, data = this_df , nthreads = 64),
    regexp = "Too few observations compared to the number of threads. 1 thread(s) will be used instead of 64.",
    fixed = TRUE)

  expect_silent(parglm( a ~ b - 1, data = this_df , nthreads = 1))
})

test_that("default nthreads in parglm.control() uses parallelly::availableCores(omit = 1L)", {
  expect_equal(
    parglm.control()$nthreads,
    parallelly::availableCores(omit = 1L)
  )
})

test_that("parglm() works with Gamma log-link family", {
  expect_silent(parglm(mpg ~ wt + hp, data = mtcars, family = Gamma(link = "log"),
                       control = parglm.control(nthreads = 2L)))
})

test_that("summary() and vcov() return coefficients in formula order with LAPACK method", {
  # With LAPACK (DGEQP3), pivot can be non-trivial when predictors are on
  # very different scales. summary.glm / vcov.glm return results in pivot
  # order; summary.parglm / vcov.parglm must reorder to match glm.
  set.seed(1)
  n  <- 500
  x1 <- rnorm(n)
  x2 <- rnorm(n) * 100    # larger scale forces non-trivial LAPACK pivot
  x3 <- rnorm(n) * 0.01   # smaller scale
  y  <- rpois(n, exp(0.5 + 0.3 * x1 + 0.01 * x2 + 30 * x3))
  df <- data.frame(y = y, x1 = x1, x2 = x2, x3 = x3)

  fg <- glm(y ~ x1 + x2 + x3, data = df, family = poisson())
  fp <- parglm(y ~ x1 + x2 + x3, data = df, family = poisson(),
               control = parglm.control(nthreads = 1L, method = "LAPACK"))

  # coefficient names must be in formula order
  expect_equal(names(coef(fp)), names(coef(fg)))

  # summary coefficient table rows must be in formula order
  expect_equal(rownames(summary(fp)$coefficients),
               rownames(summary(fg)$coefficients))

  # vcov row/col names must be in formula order
  expect_equal(dimnames(vcov(fp)), dimnames(vcov(fg)))

  # values must agree with glm to reasonable tolerance
  expect_equal(coef(fp), coef(fg), tolerance = 1e-6)
  expect_equal(vcov(fp), vcov(fg), tolerance = 1e-4)
})

test_that("nthreads = 2L is used when set explicitly", {
  expect_equal(parglm.control(nthreads = 2L)$nthreads, 2L)

  # iris has 150 rows (>= 16 * 2 = 32), so 2 threads should not be reduced
  expect_silent(
    parglm(Sepal.Length ~ Sepal.Width + Petal.Length, data = iris,
           control = parglm.control(nthreads = 2L))
  )
})

test_that("tbl_regression works for Gaussian, log-link, and logistic parglm models", {
  skip_if_not_installed("gtsummary")
  skip_if_not_installed("broom")
  skip_if_not_installed("broom.helpers")

  ctrl <- parglm.control(nthreads = 1L)

  # Gaussian (identity link)
  fp_gauss <- parglm(mpg ~ wt + hp, data = mtcars, control = ctrl)
  expect_no_error(t_gauss <- suppressWarnings(gtsummary::tbl_regression(fp_gauss)))
  expect_equal(nrow(t_gauss$table_body), 2L)

  # Poisson with log link, exponentiate = TRUE (rate ratios)
  set.seed(1)
  df_pois <- data.frame(y = rpois(200, 3), x = rnorm(200))
  fp_pois <- parglm(y ~ x, data = df_pois, family = poisson(link = "log"),
                   control = ctrl)
  expect_no_error(
    t_pois <- suppressWarnings(gtsummary::tbl_regression(fp_pois, exponentiate = TRUE))
  )
  expect_true(all(t_pois$table_body$estimate > 0, na.rm = TRUE))

  # Logistic regression (binomial, logit link), exponentiate = TRUE (odds ratios)
  df_bin <- data.frame(y = rbinom(200, 1, 0.4), x = rnorm(200))
  fp_bin <- parglm(y ~ x, data = df_bin, family = binomial(),
                   control = ctrl)
  expect_no_error(
    t_bin <- suppressWarnings(gtsummary::tbl_regression(fp_bin, exponentiate = TRUE))
  )
  expect_true(all(t_bin$table_body$estimate > 0, na.rm = TRUE))

  # Binomial with log link, exponentiate = TRUE (risk ratios)
  fp_bin_log <- parglm(y ~ x, data = df_bin, family = binomial(link = "log"),
                       control = ctrl)
  expect_no_error(
    t_bin_log <- suppressWarnings(
      gtsummary::tbl_regression(fp_bin_log, exponentiate = TRUE)
    )
  )
  expect_true(all(t_bin_log$table_body$estimate > 0, na.rm = TRUE))
})

test_that("tidy_parglm_robust returns correct structure and matches coeftest", {
  skip_if_not_installed("sandwich")
  skip_if_not_installed("lmtest")

  fp <- parglm(mpg ~ wt + hp, data = mtcars,
               control = parglm.control(nthreads = 1L))

  res <- tidy_parglm_robust(fp)
  expect_s3_class(res, "data.frame")
  expect_named(res, c("term", "estimate", "std.error", "statistic", "p.value",
                      "conf.low", "conf.high"))
  expect_equal(res$term, c("(Intercept)", "wt", "hp"))

  # estimates match coef()
  expect_equal(res$estimate, unname(coef(fp)))

  # std.error matches coeftest output
  ct <- lmtest::coeftest(fp, vcov. = sandwich::vcovHC(fp, type = "HC3"))
  expect_equal(res$std.error, unname(ct[, "Std. Error"]))

  # conf.int = FALSE omits CI columns
  res_no_ci <- tidy_parglm_robust(fp, conf.int = FALSE)
  expect_false("conf.low" %in% names(res_no_ci))

  # vcov. as a function
  res_fn <- tidy_parglm_robust(fp, vcov. = function(m) sandwich::vcovHC(m, type = "HC3"))
  expect_equal(res$std.error, res_fn$std.error)

  # exponentiate flips estimates and CIs
  res_exp <- tidy_parglm_robust(fp, exponentiate = TRUE)
  expect_equal(res_exp$estimate, exp(res$estimate))
  expect_equal(res_exp$conf.low,  exp(res$conf.low))
  expect_equal(res_exp$conf.high, exp(res$conf.high))
})

test_that("tidy_parglm_robust works as tidy_fun in tbl_regression", {
  skip_if_not_installed("sandwich")
  skip_if_not_installed("lmtest")
  skip_if_not_installed("gtsummary")
  skip_if_not_installed("broom")
  skip_if_not_installed("broom.helpers")

  fp <- parglm(mpg ~ wt + hp, data = mtcars,
               control = parglm.control(nthreads = 1L))
  expect_no_error(
    gtsummary::tbl_regression(fp, tidy_fun = tidy_parglm_robust)
  )

  # logistic with exponentiate
  set.seed(1)
  df <- data.frame(y = rbinom(200, 1, 0.5), x = rnorm(200))
  fp_b <- parglm(y ~ x, data = df, family = binomial(),
                 control = parglm.control(nthreads = 1L))
  expect_no_error(
    gtsummary::tbl_regression(fp_b, exponentiate = TRUE,
                              tidy_fun = tidy_parglm_robust)
  )
})

test_that("parglm warns rather than errors when starting values cannot be found", {
  # gaussian(log) requires y > 0; a zero in the response used to stop()
  df <- data.frame(y = c(0, 1, 2, 3), x = 1:4)
  expect_warning(
    parglm(y ~ x, data = df, family = gaussian(link = "log"),
           control = parglm.control(nthreads = 1L)),
    regexp = "cannot find valid starting values"
  )

  # Gamma(log) requires y > 0; same check
  df2 <- data.frame(y = c(0.0, 1.5, 2.0, 3.0), x = 1:4)
  expect_warning(
    parglm(y ~ x, data = df2, family = Gamma(link = "log"),
           control = parglm.control(nthreads = 1L)),
    regexp = "cannot find valid starting values"
  )
})

test_that("a block_size smaller than the number of coefficients works", {
  # the C++ code rounds block_size to a multiple of the cache line size which
  # used to floor it below the number of coefficients and write out of bounds
  set.seed(77)
  n <- 200
  X <- cbind(1, matrix(rnorm(n * 20), n))
  y <- rnorm(n)
  fit_lm <- lm.fit(X, y)

  for(method in c("LINPACK", "LAPACK", "FAST")){
    fit <- parglm.fit(
      X, y, family = gaussian(),
      control = list(nthreads = 2L, block_size = 21, method = method))
    expect_equal(unname(fit$coefficients), unname(fit_lm$coefficients),
                 info = method)
  }
})
