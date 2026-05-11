context("Miscellaneous tests")

test_that("'parglm' works when package is not attached",{
  # Issue: https://github.com/boennecd/parglm/issues/2#issue-397286510
  # See https://github.com/r-lib/devtools/issues/1797#issuecomment-423288947

  expect_silent(
    local({
      detach("package:parglm", unload = TRUE, force = TRUE)
      parglm::parglm(mpg ~ gear , data = datasets::mtcars)
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

test_that("parglm() works without specifying nthreads", {
  expect_silent(parglm(mpg ~ wt + hp, data = mtcars, family = Gamma(link = "log")))
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

test_that("nthreads = 3L is used when set explicitly", {
  expect_equal(parglm.control(nthreads = 3L)$nthreads, 3L)

  # iris has 150 rows (>= 16 * 3 = 48), so 3 threads should not be reduced
  expect_silent(
    parglm(Sepal.Length ~ Sepal.Width + Petal.Length, data = iris,
           control = parglm.control(nthreads = 3L))
  )
})
