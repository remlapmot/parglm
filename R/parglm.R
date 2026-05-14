#' @useDynLib parglm
#' @importFrom Rcpp sourceCpp
NULL

#' @name parglm
#' @title Fitting Generalized Linear Models in Parallel
#'
#' @description Function like \code{\link{glm}} which can make the computation
#' in parallel. The function supports most families listed in \code{\link{family}}.
#' See "\code{vignette("parglm", "parglm")}" for run time examples.
#'
#' @param formula an object of class \code{\link{formula}}.
#' @param family a \code{\link{family}} object.
#' @param data an optional data frame, list or environment containing the variables
#' in the model.
#' @param weights an optional vector of 'prior weights' to be used in the fitting process. Should
#' be \code{NULL} or a numeric vector.
#' @param subset	an optional vector specifying a subset of observations to be used in
#' the fitting process.
#' @param na.action a function which indicates what should happen when the data contain \code{NA}s.
#' @param start starting values for the parameters in the linear predictor.
#' @param etastart starting values for the linear predictor. Not supported.
#' @param mustart starting values for the vector of means. Not supported.
#' @param offset this can be used to specify an a priori known component to be
#' included in the linear predictor during fitting.
#' @param control	a list of parameters for controlling the fitting process.
#' For parglm.fit this is passed to \code{\link{parglm.control}}.
#' @param model	a logical value indicating whether model frame should be included
#' as a component of the returned value.
#' @param x,y For \code{parglm}: logical values indicating whether the response vector
#' and model matrix used in the fitting process should be returned as components of the
#' returned value.
#'
#' For \code{parglm.fit}: \code{x} is a design matrix of dimension \code{n * p}, and
#' \code{y} is a vector of observations of length \code{n}.
#' @param contrasts	an optional list. See the \code{contrasts.arg} of
#' \code{\link{model.matrix.default}}.
#' @param intercept	logical. Should an intercept be included in the null model?
#' @param ...	For \code{parglm}: arguments to be used to form the default \code{control} argument
#' if it is not supplied directly.
#'
#' For \code{parglm.fit}: unused.
#'
#' @return
#' \code{glm} object as returned by \code{\link{glm}} but differs mainly by the \code{qr}
#' element. The \code{qr} element in the object returned by \code{parglm}(\code{.fit}) only has the \eqn{R}
#' matrix from the QR decomposition.
#'
#' @details
#' The current implementation uses \code{min(as.integer(n / p), nthreads)}
#' threads where \code{n} is the number of observations, \code{p} is the
#' number of covariates, and \code{nthreads} is the \code{nthreads} element of
#' the list
#' returned by \code{\link{parglm.control}}. Thus, there is likely little (if
#' any) reduction in computation time if \code{p} is almost equal to \code{n}.
#' The current implementation cannot handle \code{p > n}.
#'
#' Since \code{parglm} returns a standard \code{\link{glm}} object, it is
#' compatible with the \pkg{sandwich} package for heteroskedasticity-consistent
#' (HC) and cluster-robust standard errors via \code{\link[sandwich]{vcovHC}}
#' and \code{\link[sandwich]{vcovCL}}. This requires \code{model = TRUE}
#' (the default). See \code{vignette("sandwich", "parglm")} for examples.
#'
#' @examples
#' # mtcars has 32 rows, sufficient for 2 threads (>= 16 rows per thread)
#' f1 <- glm   (mpg ~ wt + hp, data = mtcars, family = Gamma(link = "log"))
#' f2 <- parglm(mpg ~ wt + hp, data = mtcars, family = Gamma(link = "log"),
#'              control = parglm.control(nthreads = 2L))
#' all.equal(coef(f1), coef(f2))
#'
#' @importFrom stats glm
#' @export
parglm <- function(
  formula, family = gaussian, data, weights, subset,
  na.action, start = NULL, offset, control = list(...),
  contrasts = NULL, model = TRUE, x = FALSE, y = TRUE, ...){
  cl <- match.call()
  cl[[1L]] <- quote(glm)
  cl["method"] <- list(quote(parglm::parglm.fit))
  if("singular.ok" %in% names(formals(glm)))
    cl["singular.ok"] <- FALSE
  eval(cl, parent.frame())
}

#' @title Auxiliary for Controlling GLM Fitting in Parallel
#'
#' @description
#' Auxiliary function for \code{\link{parglm}} fitting.
#'
#' @param epsilon positive convergence tolerance.
#' @param maxit integer giving the maximal number of IWLS iterations.
#' @param trace logical indicating if output should be produced during estimation.
#' @param nthreads number of cores to use. Defaults to
#' \code{parallelly::availableCores(omit = 1L)}, which leaves one core free.
#' You may get the best performance by using all available physical cores if
#' your data set is sufficiently large.
#' @param block_size number of observations to include in each parallel block.
#' @param method string specifying which method to use. Either \code{"LINPACK"},
#' \code{"LAPACK"}, or \code{"FAST"}.
#' @param nthreads_auto logical; for internal use only. Records whether
#' \code{nthreads} was auto-detected (suppresses the thread-reduction warning
#' when the dataset is small). Do not set this argument directly.
#'
#' @details
#' The \code{LINPACK} method uses the same QR method as \code{\link{glm.fit}} for the final QR decomposition.
#' This is the \code{dqrdc2} method described in \code{\link[base]{qr}}. All other QR
#' decompositions except the last are made with \code{DGEQP3} from \code{LAPACK}.
#' See Wood, Goude, and Shaw (2015) for details on the QR method.
#'
#' The \code{FAST} method computes the Fisher information and then solves the normal
#' equation. This is faster but less numerically stable.
#'
#' @references
#' Wood, S.N., Goude, Y. & Shaw, S. (2015) Generalized additive models for
#' large datasets. Journal of the Royal Statistical Society, Series C
#' 64(1): 139-155.
#'
#' @return
#' A list with components named as the arguments.
#'
#' @examples
#' # use one core
#' f1 <- parglm(mpg ~ wt + hp, data = mtcars, family = Gamma(link = "log"),
#'              control = parglm.control(nthreads = 1L))
#'
#' # use two cores (mtcars has 32 rows, sufficient for 2 threads)
#' f2 <- parglm(mpg ~ wt + hp, data = mtcars, family = Gamma(link = "log"),
#'              control = parglm.control(nthreads = 2L))
#' all.equal(coef(f1), coef(f2))
#'
#' @export
parglm.control <- function(
  epsilon = 1e-08, maxit = 25, trace = FALSE,
  nthreads = parallelly::availableCores(omit = 1L),
  block_size = NULL, method = "LINPACK",
  nthreads_auto = missing(nthreads))
{
  if (!is.numeric(epsilon) || epsilon <= 0)
    stop("value of 'epsilon' must be > 0")
  if (!is.numeric(maxit) || maxit <= 0)
    stop("maximum number of iterations must be > 0")
  stopifnot(
    is.numeric(nthreads) && nthreads >= 1,
    is.null(block_size) || (is.numeric(block_size) && block_size >= 1),
    method %in% c("LAPACK", "LINPACK", "FAST"))
  list(epsilon = epsilon, maxit = maxit, trace = trace, nthreads = nthreads,
       nthreads_auto = nthreads_auto, block_size = block_size, method = method)
}

#' @rdname parglm
#' @importFrom stats gaussian binomial Gamma inverse.gaussian poisson quasipoisson quasibinomial weighted.mean
#' @export
parglm.fit <- function(
  x, y, weights = rep(1, NROW(x)), start = NULL, etastart = NULL,
  mustart = NULL, offset = rep(0, NROW(x)), family = gaussian(),
  control = list(), intercept = TRUE, ...){
  .check_fam(family)
  stopifnot(nrow(x) == NROW(y))
  if(NCOL(x) > NROW(x))
    stop("not implemented with more variables than observations")

  if(!is.null(mustart))
    warning(sQuote("mustart"), " will not be used")
  if(!is.null(etastart))
    warning(sQuote("etastart"), " will not be used")

  #####
  # like in `glm.fit`
  control <- do.call("parglm.control", control)
  x <- as.matrix(x)
  xnames <- dimnames(x)[[2L]]
  ynames <- if(is.matrix(y)) rownames(y) else names(y)

  n_trials <- rep(1, NROW(y))
  if(NCOL(y) == 2L && family$family %in% c("binomial", "quasibinomial")) {
    n_trials <- y[, 1L] + y[, 2L]
    y        <- ifelse(n_trials == 0, 0, y[, 1L] / n_trials)
    weights  <- if(is.null(weights)) n_trials else weights * n_trials
  } else if(NCOL(y) > 1L)
    stop("Multi column ", sQuote("y"), " is not supported")

  conv <- FALSE
  nobs <- NROW(y)
  nvars <- ncol(x)
  EMPTY <- nvars == 0

  if(EMPTY)
    stop("not implemented for empty model")

  if (is.null(weights))
    weights <- rep.int(1, nobs)
  if (is.null(offset))
    offset <- rep.int(0, nobs)

  n_min_per_thread <- 16L
  n_per_thread <- nrow(x) / control$nthreads
  if(n_per_thread < n_min_per_thread){
    nthreads_new <- nrow(x) %/% n_min_per_thread
    if(nthreads_new < 1L)
      nthreads_new <- 1L

    if(control$nthreads != nthreads_new && !isTRUE(control$nthreads_auto))
      warning(
        "Too few observations compared to the number of threads. ",
        nthreads_new, " thread(s) will be used instead of ",
        control$nthreads, ".")

    control$nthreads <- nthreads_new
  }

  block_size <- if(!is.null(control$block_size))
    control$block_size else
      if(control$nthreads > 1L)
        max(nrow(x) / control$nthreads, control$nthreads) else
          nrow(x)
  block_size <- max(block_size, NCOL(x))

  use_start <- !is.null(start)

  # Families whose C++ initialize() requires strictly positive y. When any y
  # is non-positive or non-finite, compute a safe starting beta from the valid
  # observations and warn rather than stop, matching glm()/fastglm() behaviour.
  if (!use_start) {
    fam_key <- paste0(family$family, "_", family$link)
    needs_pos_y <- fam_key %in% c(
      "gaussian_log", "gaussian_inverse",
      "Gamma_inverse", "Gamma_identity", "Gamma_log",
      "inverse.gaussian_1/mu^2", "inverse.gaussian_inverse",
      "inverse.gaussian_identity", "inverse.gaussian_log")
    if (needs_pos_y && any(!is.finite(y) | y <= 0)) {
      warning("cannot find valid starting values: using default starting value",
              call. = FALSE)
      y_ok <- is.finite(y) & y > 0
      mu0  <- if (any(y_ok)) weighted.mean(y[y_ok], weights[y_ok]) else 1
      eta0 <- family$linkfun(mu0)
      start     <- rep(0, ncol(x))
      start[1L] <- eta0
      use_start <- TRUE
    }
  }

  fit <- parallelglm(
    X = x, Ys = y, family = paste0(family$family, "_", family$link),
    start = if(use_start) start else numeric(ncol(x)), weights = weights,
    offsets = offset, tol = control$epsilon, nthreads = control$nthreads,
    it_max = control$maxit, trace = control$trace, block_size = block_size,
    use_start = use_start, method = control$method)

  #####
  # compute objects as in `glm.fit`
  coef <- drop(fit$coefficients)
  names(coef) <- xnames
  eta <- drop(fit$eta)
  mu  <- drop(fit$mu)
  mu.eta.val <- family$mu.eta(eta)
  good <- (weights > 0) & (mu.eta.val != 0)
  w <- sqrt((weights[good] * mu.eta.val[good]^2) / family$variance(mu)[good])

  wt <- rep.int(0, nobs)
  wt[good] <- w^2

  residuals <- (y - mu) / mu.eta.val

  dev <- sum(family$dev.resids(y, mu, weights))

  conv <- fit$conv
  iter <- fit$n_iter

  boundary <- FALSE # TODO: not as in `glm.fit`

  Rmat <- fit$R
  dimnames(Rmat) <- list(xnames, xnames)

  names(residuals) <- names(mu) <- names(eta) <- names(wt) <- names(weights) <-
    names(y) <- ynames

  # do as in `Matrix::rankMatrix`
  rtol <- max(dim(x)) * .Machine$double.eps
  fit$rank <- rank <- fit$rank
  rdiag <- abs(diag(fit$R))
  if(control$method != "LINPACK" && any(rdiag <= rtol * max(rdiag)))
    warning("Non-full rank problem. Output may not be reliable.")

  #####
  # do roughly as in `glm.fit`
  if (!conv)
    warning("parglm.fit: algorithm did not converge", call. = FALSE)

  wtdmu <-
    if (intercept) sum(weights * y)/sum(weights) else family$linkinv(offset)
  nulldev <- sum(family$dev.resids(y, wtdmu, weights))

  n.ok <- nobs - sum(weights==0)
  nulldf <- n.ok - as.integer(intercept)
  rank <- fit$rank
  resdf  <- n.ok - rank
  #-----------------------------------------------------------------------------
  # calculate AIC; n_trials is 1 for single-column y, trial counts for two-column binomial
  aic.model <- family$aic(y, n_trials, mu, weights, dev) + 2*rank
  #-----------------------------------------------------------------------------
  list(coefficients = coef, residuals = residuals, fitted.values = mu,
       # effects = fit$effects, # TODO: add
       R = Rmat, rank = rank,
       qr = structure(c(fit, list(qr = fit$R)), class = "parglmqr"),
       family = family,
       linear.predictors = eta, deviance = dev, aic = aic.model,
       null.deviance = nulldev, iter = iter, weights = wt,
       prior.weights = weights, df.residual = resdf, df.null = nulldf,
       y = y, converged = conv, boundary = boundary,
       class = "parglm")
}


#' @importFrom stats coef hatvalues model.matrix summary.glm vcov
#' @export
summary.parglm <- function(object, ...) {
  s   <- NextMethod()
  rnk <- object$rank
  pvt <- object$qr$pivot[seq_len(rnk)]
  idx <- order(pvt)
  if (!identical(idx, seq_len(rnk))) {
    s$coefficients <- s$coefficients[idx, , drop = FALSE]
    s$cov.unscaled <- s$cov.unscaled[idx, idx, drop = FALSE]
    if (!is.null(s$cov.scaled))
      s$cov.scaled <- s$cov.scaled[idx, idx, drop = FALSE]
  }
  s
}

#' @export
vcov.parglm <- function(object, complete = TRUE, ...) {
  s   <- summary(object, ...)
  cf0 <- coef(object)
  p   <- length(cf0)
  cf  <- !is.na(cf0)
  vc  <- matrix(NA_real_, p, p, dimnames = list(names(cf0), names(cf0)))
  if (any(cf))
    vc[cf, cf] <- s$dispersion * s$cov.unscaled
  if (complete) vc else vc[cf, cf, drop = FALSE]
}

#' @export
hatvalues.parglm <- function(model, ...) {
  wts <- model$weights
  X   <- model.matrix(model)
  pvt <- model$qr$pivot
  rnk <- model$rank
  Xw  <- X[, pvt[seq_len(rnk)], drop = FALSE] * sqrt(wts)
  R   <- model$R[seq_len(rnk), seq_len(rnk), drop = FALSE]
  Z   <- forwardsolve(t(R), t(Xw))
  colSums(Z^2)
}

.check_fam <- function(family){
  stopifnot(
    inherits(family, "family"),
    paste(family$family, family$link) %in% .parglm_supported_keys())
}

parglm_supported <- function()
  list(
    gaussian("identity"), gaussian("log"), gaussian("inverse"),

    binomial("logit"), binomial("probit"), binomial("cauchit"),
    binomial("log"), binomial("cloglog"),

    Gamma("inverse"), Gamma("identity"), Gamma("log"),

    poisson("log"), poisson("identity"), poisson("sqrt"),

    quasipoisson("log"), quasipoisson("identity"), quasipoisson("sqrt"),

    quasibinomial("logit"), quasibinomial("probit"), quasibinomial("cauchit"),
    quasibinomial("log"), quasibinomial("cloglog"),

    inverse.gaussian("1/mu^2"), inverse.gaussian("inverse"),
    inverse.gaussian("identity"), inverse.gaussian("log"))

.parglm_supported_keys <- local({
  cached <- NULL
  function() {
    if (is.null(cached))
      cached <<- vapply(
        parglm_supported(),
        function(x) paste(x$family, x$link),
        character(1))
    cached
  }
})

#' @export
confint.parglm <- function(object, parm, level = 0.95, ...) {
  keep <- intersect(names(object$control), c("epsilon", "maxit", "trace"))
  object$control <- object$control[keep]
  NextMethod()
}

#' @importFrom Matrix qr.R
#' @export
qr.R.parglmqr <- function(x, ...){
  x$R
}
