#' Confidence Intervals for Marginal Treatment Effects
#'
#' @description
#' Computes confidence intervals for marginal treatment effect estimates
#' from a fitted model with `get_marginal_effect()`.
#'
#' @param object a fitted model object augmented with marginal effect
#' estimates via \code{\link{get_marginal_effect}}. Must contain
#' `marginal_est` and `marginal_se` components.
#'
#' @param parm currently unused, included for S3 method consistency.
#'
#' @param level the confidence level required. Default is 0.95 for
#' 95% confidence intervals.
#'
#' @param ... additional arguments (currently unused).
#'
#' @return A data frame with columns:
#' \describe{
#'   \item{contrast}{Description of the treatment contrast}
#'   \item{estimate}{Point estimate of the treatment effect}
#'   \item{std.error}{Standard error of the estimate}
#'   \item{lower}{Lower confidence limit}
#'   \item{upper}{Upper confidence limit}
#'   \item{conf.level}{Confidence level used}
#' }
#'
#' @details
#' Confidence intervals are calculated using normal approximation:
#' estimate ± z * std.error, where z is the appropriate quantile
#' from the standard normal distribution.
#'
#' For ratio-based measures (odds ratio, risk ratio), consider using
#' log-transformed contrasts (logor, logrr) as they typically have
#' better normal approximation properties.
#'
#' @importFrom stats qnorm confint.glm
#' @export
#'
#' @examples
#' trial01$trtp <- factor(trial01$trtp)
#' fit1 <- glm(aval ~ trtp + bl_cov, family = "binomial", data = trial01) |>
#'   get_marginal_effect(trt = "trtp", method = "Ye", contrast = "diff", reference = "0")
#'
#' # Get 95% confidence intervals
#' confint(fit1)
#'
#' # Get 90% confidence intervals
#' confint(fit1, level = 0.90)
#'
confint.glm <- function(object, parm, level = 0.95, ...) {
  # Check if object has been processed with get_marginal_effect
  if (!"marginal_est" %in% names(object) || !"marginal_se" %in% names(object)) {
    # Fall back to default confint.glm from stats package
    return(stats::confint.glm(object, parm = parm, level = level, ...))
  }

  alpha <- 1 - level
  z <- qnorm(1 - alpha / 2)

  est <- object$marginal_est
  se <- object$marginal_se
  contrast_desc <- attr(object$marginal_est, "contrast")

  result <- data.frame(
    contrast = contrast_desc,
    estimate = as.numeric(est),
    std.error = as.numeric(se),
    lower = as.numeric(est - z * se),
    upper = as.numeric(est + z * se),
    conf.level = level,
    row.names = NULL,
    stringsAsFactors = FALSE
  )

  return(result)
}


#' Print Confidence Intervals for Marginal Effects
#'
#' @param x output from \code{\link{confint.glm}} for a beeca marginal effect model
#' @param digits number of digits to display
#' @param ... additional arguments passed to print
#'
#' @return invisibly returns x
#' @keywords internal
print.confint.beeca <- function(x, digits = 4, ...) {
  cat("\nConfidence Intervals for Marginal Treatment Effects\n")
  cat(sprintf("Confidence level: %.1f%%\n\n", x$conf.level[1] * 100))

  print_df <- x
  print_df$estimate <- format(round(print_df$estimate, digits), nsmall = digits)
  print_df$std.error <- format(round(print_df$std.error, digits), nsmall = digits)
  print_df$lower <- format(round(print_df$lower, digits), nsmall = digits)
  print_df$upper <- format(round(print_df$upper, digits), nsmall = digits)
  print_df$conf.level <- NULL

  print(print_df, row.names = FALSE, ...)
  invisible(x)
}


#' Summary Method for Marginal Treatment Effects
#'
#' @description
#' Provides a comprehensive summary of marginal treatment effect estimates
#' including point estimates, standard errors, and confidence intervals.
#'
#' @param object a fitted model object augmented with marginal effect
#' estimates via \code{\link{get_marginal_effect}}.
#'
#' @param conf.level confidence level for confidence intervals. Default is 0.95.
#'
#' @param ... additional arguments (currently unused).
#'
#' @return A list of class "summary.beeca_marginal" containing:
#' \describe{
#'   \item{method}{Variance estimation method used}
#'   \item{contrast}{Type of contrast (e.g., diff, rr, or)}
#'   \item{reference}{Reference treatment level(s)}
#'   \item{n_obs}{Number of observations in the model}
#'   \item{n_arms}{Number of treatment arms}
#'   \item{treatment_var}{Name of treatment variable}
#'   \item{estimates}{Data frame with estimates and confidence intervals}
#'   \item{marginal_means}{Marginal mean estimates for each treatment arm}
#' }
#'
#' @export
#'
#' @examples
#' trial01$trtp <- factor(trial01$trtp)
#' fit1 <- glm(aval ~ trtp + bl_cov, family = "binomial", data = trial01) |>
#'   get_marginal_effect(trt = "trtp", method = "Ye", contrast = "diff", reference = "0")
#'
#' # Get summary
#' summary(fit1)
#'
summary.beeca_marginal <- function(object, conf.level = 0.95, ...) {
  # Check if object has been processed with get_marginal_effect
  if (!"marginal_est" %in% names(object)) {
    stop("Object does not contain marginal effect estimates. Run get_marginal_effect() first.",
      call. = FALSE
    )
  }

  trt <- attributes(object$counterfactual.predictions)$treatment.variable

  result <- structure(
    list(
      method = attr(object$robust_varcov, "type"),
      contrast = names(object$marginal_est)[1] |> strsplit(":") |> unlist() |> head(1),
      reference = attr(object$marginal_est, "reference"),
      n_obs = nrow(object$model),
      n_arms = length(object$counterfactual.means),
      treatment_var = trt,
      estimates = confint.glm(object, level = conf.level),
      marginal_means = object$counterfactual.means
    ),
    class = "summary.beeca_marginal"
  )

  return(result)
}


#' Print Summary of Marginal Treatment Effects
#'
#' @param x a summary.beeca_marginal object from \code{\link{summary.beeca_marginal}}
#' @param digits number of digits to display
#' @param ... additional arguments (currently unused)
#'
#' @return invisibly returns x
#' @export
#'
print.summary.beeca_marginal <- function(x, digits = 4, ...) {
  cat("\n")
  cat("Marginal Treatment Effect Analysis\n")
  cat(rep("=", 50), "\n\n", sep = "")

  cat(sprintf("Treatment variable: %s\n", x$treatment_var))
  cat(sprintf("Number of observations: %d\n", x$n_obs))
  cat(sprintf("Number of treatment arms: %d\n", x$n_arms))
  cat(sprintf("Variance estimation method: %s\n", x$method))
  cat(sprintf("Contrast type: %s\n", x$contrast))
  cat(sprintf("Reference level(s): %s\n\n", paste(x$reference, collapse = ", ")))

  cat("Marginal Means (Counterfactual Predictions):\n")
  cat(rep("-", 50), "\n", sep = "")
  means_df <- data.frame(
    Treatment = names(x$marginal_means),
    `Marginal Mean` = format(round(x$marginal_means, digits), nsmall = digits),
    check.names = FALSE,
    stringsAsFactors = FALSE
  )
  print(means_df, row.names = FALSE)
  cat("\n")

  cat("Treatment Effect Estimates:\n")
  cat(rep("-", 50), "\n", sep = "")
  est_df <- x$estimates
  est_df$estimate <- format(round(est_df$estimate, digits), nsmall = digits)
  est_df$std.error <- format(round(est_df$std.error, digits), nsmall = digits)
  est_df$lower <- format(round(est_df$lower, digits), nsmall = digits)
  est_df$upper <- format(round(est_df$upper, digits), nsmall = digits)
  est_df$conf.level <- paste0(est_df$conf.level * 100, "%")
  names(est_df)[names(est_df) == "conf.level"] <- "CI Level"
  print(est_df, row.names = FALSE)
  cat("\n")

  invisible(x)
}


#' Get Marginal Effect (Enhanced with S3 Class)
#'
#' @description
#' Internal wrapper to add S3 class to get_marginal_effect output
#' This enables the summary and confint methods to work properly.
#'
#' @keywords internal
.add_beeca_class <- function(object) {
  if (!"marginal_est" %in% names(object)) {
    return(object)
  }

  # Add beeca_marginal class for S3 method dispatch
  class(object) <- c("beeca_marginal", class(object))
  return(object)
}
