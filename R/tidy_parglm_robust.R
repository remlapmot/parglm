#' Tidy a parglm model with robust standard errors
#'
#' A drop-in \code{tidy_fun} for \code{\link[gtsummary]{tbl_regression}} that
#' computes heteroskedasticity-consistent (HC) or cluster-robust confidence
#' intervals via \pkg{sandwich} and \pkg{lmtest}.
#'
#' @param x a \code{parglm} (or \code{glm}) model object.
#' @param vcov. the robust variance-covariance estimator. A string is passed
#'   as the \code{type} argument to \code{\link[sandwich]{vcovHC}} (e.g.
#'   \code{"HC3"}). A function is called as \code{vcov.(x)} and should return
#'   a covariance matrix (use this for cluster-robust SEs via
#'   \code{\link[sandwich]{vcovCL}}). A matrix is used directly.
#'   Defaults to \code{"HC3"}.
#' @param conf.int logical; whether to include confidence intervals.
#' @param conf.level confidence level for the intervals.
#' @param exponentiate logical; whether to exponentiate the estimate and
#'   confidence interval limits.
#' @param ... unused; present for compatibility with the \code{tidy_fun}
#'   interface of \code{\link[gtsummary]{tbl_regression}}.
#'
#' @details
#' Pass this function as \code{tidy_fun} to
#' \code{\link[gtsummary]{tbl_regression}}:
#'
#' \preformatted{
#' # HC3 (default)
#' tbl_regression(fit, tidy_fun = tidy_parglm_robust)
#'
#' # HC1
#' tbl_regression(fit, tidy_fun = \(x, ...) tidy_parglm_robust(x, vcov. = "HC1", ...))
#'
#' # Cluster-robust
#' tbl_regression(fit, tidy_fun = \(x, ...) tidy_parglm_robust(
#'   x, vcov. = \(m) sandwich::vcovCL(m, cluster = ~ cluster_var), ...))
#' }
#'
#' @return a \code{data.frame} with columns \code{term}, \code{estimate},
#'   \code{std.error}, \code{statistic}, \code{p.value}, and (when
#'   \code{conf.int = TRUE}) \code{conf.low} and \code{conf.high}.
#'
#' @examples
#' fp <- parglm(mpg ~ wt + hp, data = mtcars,
#'              control = parglm.control(nthreads = 1L))
#' if (requireNamespace("sandwich", quietly = TRUE) &&
#'     requireNamespace("lmtest",   quietly = TRUE)) {
#'   tidy_parglm_robust(fp)
#' }
#'
#' @export
tidy_parglm_robust <- function(x, vcov. = "HC3", conf.int = TRUE,
                               conf.level = 0.95, exponentiate = FALSE, ...) {
  if (!requireNamespace("sandwich", quietly = TRUE))
    stop("package 'sandwich' must be installed to use tidy_parglm_robust()")
  if (!requireNamespace("lmtest", quietly = TRUE))
    stop("package 'lmtest' must be installed to use tidy_parglm_robust()")

  vc <- if (is.character(vcov.)) {
    sandwich::vcovHC(x, type = vcov.)
  } else if (is.function(vcov.)) {
    vcov.(x)
  } else {
    vcov.
  }

  ct <- lmtest::coeftest(x, vcov. = vc)

  res <- data.frame(
    term      = rownames(ct),
    estimate  = ct[, 1L],
    std.error = ct[, 2L],
    statistic = ct[, 3L],
    p.value   = ct[, 4L],
    stringsAsFactors = FALSE
  )

  if (conf.int) {
    ci <- lmtest::coefci(x, vcov. = vc, level = conf.level)
    res$conf.low  <- ci[, 1L]
    res$conf.high <- ci[, 2L]
  }

  if (exponentiate) {
    res$estimate <- exp(res$estimate)
    if (conf.int) {
      res$conf.low  <- exp(res$conf.low)
      res$conf.high <- exp(res$conf.high)
    }
  }

  res
}
