# GEE Testing Suite
#
# This file tests the GEE implementation (glmgee from glmtoolbox, geeglm from geepack)
# added in Phase 5. Tests cover three areas:
#
# 1. Validation (sanitize_model) - family/link, interactions, single-timepoint, convergence
# 2. Variance Estimation - Cross-validated against manual delta method computation (Ge et al 2011)
# 3. End-to-End Pipeline - Full get_marginal_effect() with ARD output
#
# Reference: Ge et al (2011) "Covariate-Adjusted Difference in Proportions..."
#   Delta method variance: V = D * V_beta * D^T
#   where D is the derivative matrix and V_beta is the GEE robust variance of coefficients
#
# Cross-validation approach: For variance tests, we independently compute the expected
# variance using the delta method WITHOUT using beeca's counterfactual.predictions,
# then compare to beeca's output to ensure correctness.

# Setup helper function ---------------------------------------------------

setup_gee_test_data <- function(n = 100, seed = 123) {
  set.seed(seed)
  data.frame(
    id = 1:n,
    trtp = factor(rep(c("0", "1"), each = n/2)),
    bl_cov = rnorm(n),
    aval = rbinom(n, 1, 0.5)
  )
}


# Section 1: GEE Validation Tests -----------------------------------------

test_that("Valid glmgee model passes sanitize_model", {
  skip_if_not_installed("glmtoolbox")
  library(glmtoolbox)

  d <- setup_gee_test_data(n = 100, seed = 123)
  fit <- glmgee(aval ~ trtp + bl_cov, id = id,
                family = binomial(link = "logit"),
                data = d, corstr = "independence")

  result <- sanitize_model(fit, "trtp")
  expect_true(result$sanitized)
})

test_that("glmgee with wrong family rejected", {
  skip_if_not_installed("glmtoolbox")
  library(glmtoolbox)

  d <- setup_gee_test_data(n = 100, seed = 124)
  fit <- glmgee(aval ~ trtp + bl_cov, id = id,
                family = poisson(),
                data = d, corstr = "independence")

  expect_error(
    sanitize_model(fit, "trtp"),
    "not in the binomial family with logit link function"
  )
})

test_that("glmgee with treatment interaction rejected", {
  skip_if_not_installed("glmtoolbox")
  library(glmtoolbox)

  d <- setup_gee_test_data(n = 100, seed = 125)
  fit <- glmgee(aval ~ trtp * bl_cov, id = id,
                family = binomial(link = "logit"),
                data = d, corstr = "independence")

  expect_error(
    sanitize_model(fit, "trtp"),
    "treatment-covariate interaction terms"
  )
})

test_that("glmgee with multi-timepoint data rejected", {
  skip_if_not_installed("glmtoolbox")
  library(glmtoolbox)

  d <- setup_gee_test_data(n = 100, seed = 126)
  # Create multi-timepoint data: each ID has 2 observations
  d_multi <- rbind(d, d)
  d_multi$id <- rep(1:(nrow(d)/2), each = 2)
  d_multi$aval <- rbinom(nrow(d_multi), 1, 0.5)

  fit <- glmgee(aval ~ trtp + bl_cov, id = id,
                family = binomial(link = "logit"),
                data = d_multi, corstr = "independence")

  expect_error(
    sanitize_model(fit, "trtp"),
    "Multi-timepoint data detected"
  )
})

test_that("glmgee with Ye method rejected", {
  skip_if_not_installed("glmtoolbox")
  library(glmtoolbox)

  d <- setup_gee_test_data(n = 100, seed = 127)
  fit <- glmgee(aval ~ trtp + bl_cov, id = id,
                family = binomial(link = "logit"),
                data = d, corstr = "independence")

  obj <- fit |>
    predict_counterfactuals(trt = "trtp") |>
    average_predictions()

  expect_error(
    estimate_varcov(obj, method = "Ye"),
    "Ye's method assumes independence and is not valid for GEE models. Use method='Ge' instead.",
    fixed = TRUE
  )
})

test_that("Valid geeglm model passes sanitize_model", {
  skip_if_not_installed("geepack")
  library(geepack)

  d <- setup_gee_test_data(n = 100, seed = 128)
  fit <- geeglm(aval ~ trtp + bl_cov, id = id,
                family = binomial(link = "logit"),
                data = d, corstr = "independence")

  result <- sanitize_model(fit, "trtp")
  expect_true(result$sanitized)
})

test_that("geeglm with wrong family rejected", {
  skip_if_not_installed("geepack")
  library(geepack)

  d <- setup_gee_test_data(n = 100, seed = 129)
  fit <- geeglm(aval ~ trtp + bl_cov, id = id,
                family = poisson(),
                data = d, corstr = "independence")

  expect_error(
    sanitize_model(fit, "trtp"),
    "not in the binomial family with logit link function"
  )
})

test_that("geeglm with multi-timepoint data rejected", {
  skip_if_not_installed("geepack")
  library(geepack)

  d <- setup_gee_test_data(n = 100, seed = 130)
  # Create multi-timepoint data
  d_multi <- rbind(d, d)
  d_multi$id <- rep(1:(nrow(d)/2), each = 2)
  d_multi$aval <- rbinom(nrow(d_multi), 1, 0.5)

  fit <- geeglm(aval ~ trtp + bl_cov, id = id,
                family = binomial(link = "logit"),
                data = d_multi, corstr = "independence")

  expect_error(
    sanitize_model(fit, "trtp"),
    "Multi-timepoint data detected"
  )
})


# Section 2: GEE Variance Estimation Tests --------------------------------

test_that("glmgee robust variance matches manual delta method computation", {
  skip_if_not_installed("glmtoolbox")
  library(glmtoolbox)

  # Use fixed seed for reproducibility
  d <- setup_gee_test_data(n = 50, seed = 42)

  # Fit glmgee model
  fit <- glmgee(aval ~ trtp + bl_cov, id = id,
                family = binomial(link = "logit"),
                data = d, corstr = "independence")

  # Run beeca pipeline through estimate_varcov
  result <- fit |>
    predict_counterfactuals(trt = "trtp") |>
    average_predictions() |>
    estimate_varcov(method = "Ge", type = "robust")

  # --- MANUAL DELTA METHOD COMPUTATION (independent of beeca internals) ---
  # Reference: Ge et al (2011) delta method for conditional ATE variance
  # Formula: V = D * V_beta * D^T
  # where:
  #   D = derivative matrix (one row per treatment level)
  #   V_beta = GEE's robust variance-covariance matrix of coefficients

  # Step 1: Get V_beta from GEE fit
  V_beta <- vcov(fit)  # GEE's robust variance of coefficients

  # Step 2: Compute derivative matrix D
  # For each treatment level k, compute D_k = (1/n) * sum(p_k * (1 - p_k) * X_k)
  # where p_k are predictions with all subjects set to treatment k

  d_list <- list()
  for (trtlvl in c("0", "1")) {
    # Create counterfactual data: set all trtp to current level
    X_cf <- d
    X_cf$trtp <- factor(trtlvl, levels = c("0", "1"))

    # Build model matrix
    X_k <- model.matrix(aval ~ trtp + bl_cov, X_cf)

    # Compute predictions independently (NOT using beeca's predictions)
    linear_pred <- X_k %*% coef(fit)
    phat_k <- plogis(linear_pred)  # inverse logit

    # Compute derivatives: d(p)/d(beta) = p * (1 - p) for logit link
    pderiv_k <- phat_k * (1 - phat_k)

    # Compute D_k: average of derivative-weighted design matrix
    D_k <- (t(pderiv_k) %*% X_k) / nrow(d)

    d_list[[trtlvl]] <- D_k
  }

  # Step 3: Stack D rows
  D <- do.call(rbind, d_list)

  # Step 4: Compute V_manual = D * V_beta * D^T
  V_manual <- D %*% V_beta %*% t(D)
  rownames(V_manual) <- colnames(V_manual) <- c("0", "1")

  # --- END MANUAL COMPUTATION ---

  # Compare beeca result to manual computation (compare matrix values, ignore attributes)
  expect_equal(result$robust_varcov[,], V_manual[,], tolerance = 1e-10)
})

test_that("glmgee bias-corrected variance type works", {
  skip_if_not_installed("glmtoolbox")
  library(glmtoolbox)

  d <- setup_gee_test_data(n = 50, seed = 43)
  fit <- glmgee(aval ~ trtp + bl_cov, id = id,
                family = binomial(link = "logit"),
                data = d, corstr = "independence")

  result <- fit |>
    predict_counterfactuals(trt = "trtp") |>
    average_predictions() |>
    estimate_varcov(method = "Ge", type = "bias-corrected")

  expect_false(is.null(result$robust_varcov))
  expect_true(is.matrix(result$robust_varcov))
  expect_equal(dim(result$robust_varcov), c(2, 2))
  expect_equal(rownames(result$robust_varcov), c("0", "1"))
  expect_equal(colnames(result$robust_varcov), c("0", "1"))
})

test_that("glmgee df-adjusted variance type works", {
  skip_if_not_installed("glmtoolbox")
  library(glmtoolbox)

  d <- setup_gee_test_data(n = 50, seed = 44)
  fit <- glmgee(aval ~ trtp + bl_cov, id = id,
                family = binomial(link = "logit"),
                data = d, corstr = "independence")

  result <- fit |>
    predict_counterfactuals(trt = "trtp") |>
    average_predictions() |>
    estimate_varcov(method = "Ge", type = "df-adjusted")

  expect_false(is.null(result$robust_varcov))
  expect_true(is.matrix(result$robust_varcov))
  expect_equal(dim(result$robust_varcov), c(2, 2))
})

test_that("glmgee with GLM-style variance type produces helpful error", {
  skip_if_not_installed("glmtoolbox")
  library(glmtoolbox)

  d <- setup_gee_test_data(n = 50, seed = 45)
  fit <- glmgee(aval ~ trtp + bl_cov, id = id,
                family = binomial(link = "logit"),
                data = d, corstr = "independence")

  obj <- fit |>
    predict_counterfactuals(trt = "trtp") |>
    average_predictions()

  expect_error(
    estimate_varcov(obj, method = "Ge", type = "HC0"),
    'Variance type "HC0" is not supported for glmgee objects. Valid types: robust, bias-corrected, df-adjusted',
    fixed = TRUE
  )
})

test_that("geeglm robust variance matches manual delta method computation", {
  skip_if_not_installed("geepack")
  library(geepack)

  # Use identical data for cross-validation
  d <- setup_gee_test_data(n = 50, seed = 42)

  # Fit geeglm model
  fit <- geeglm(aval ~ trtp + bl_cov, id = id,
                family = binomial(link = "logit"),
                data = d, corstr = "independence")

  # Run beeca pipeline
  result <- fit |>
    predict_counterfactuals(trt = "trtp") |>
    average_predictions() |>
    estimate_varcov(method = "Ge", type = "robust")

  # --- MANUAL DELTA METHOD COMPUTATION ---
  V_beta <- vcov(fit)

  d_list <- list()
  for (trtlvl in c("0", "1")) {
    X_cf <- d
    X_cf$trtp <- factor(trtlvl, levels = c("0", "1"))
    X_k <- model.matrix(aval ~ trtp + bl_cov, X_cf)

    # Compute predictions independently
    linear_pred <- X_k %*% coef(fit)
    phat_k <- plogis(linear_pred)

    pderiv_k <- phat_k * (1 - phat_k)
    D_k <- (t(pderiv_k) %*% X_k) / nrow(d)

    d_list[[trtlvl]] <- D_k
  }

  D <- do.call(rbind, d_list)
  V_manual <- D %*% V_beta %*% t(D)
  rownames(V_manual) <- colnames(V_manual) <- c("0", "1")
  # --- END MANUAL COMPUTATION ---

  expect_equal(result$robust_varcov[,], V_manual[,], tolerance = 1e-10)
})

test_that("geeglm with non-robust type produces error", {
  skip_if_not_installed("geepack")
  library(geepack)

  d <- setup_gee_test_data(n = 50, seed = 46)
  fit <- geeglm(aval ~ trtp + bl_cov, id = id,
                family = binomial(link = "logit"),
                data = d, corstr = "independence")

  obj <- fit |>
    predict_counterfactuals(trt = "trtp") |>
    average_predictions()

  expect_error(
    estimate_varcov(obj, method = "Ge", type = "bias-corrected"),
    'Valid types: robust'
  )
})


# Section 3: End-to-End Pipeline Tests ------------------------------------

test_that("glmgee end-to-end with diff contrast", {
  skip_if_not_installed("glmtoolbox")
  library(glmtoolbox)

  d <- setup_gee_test_data(n = 100, seed = 50)
  fit <- glmgee(aval ~ trtp + bl_cov, id = id,
                family = binomial(link = "logit"),
                data = d, corstr = "independence")

  result <- get_marginal_effect(fit, trt = "trtp", method = "Ge",
                                 type = "robust", contrast = "diff",
                                 reference = "0")

  # Verify result structure
  expect_true("beeca" %in% class(result))
  expect_false(is.null(result$marginal_est))
  expect_false(is.null(result$marginal_se))
  expect_false(is.null(result$robust_varcov))

  # Verify ARD structure
  expect_true(tibble::is_tibble(result$marginal_results))
  expect_equal(nrow(result$marginal_results), 12)
  expect_equal(ncol(result$marginal_results), 8)
  expect_false(any(is.na(result$marginal_results)))
  expect_true("diff" %in% result$marginal_results$STAT)
})

test_that("glmgee end-to-end with or contrast", {
  skip_if_not_installed("glmtoolbox")
  library(glmtoolbox)

  d <- setup_gee_test_data(n = 100, seed = 51)
  fit <- glmgee(aval ~ trtp + bl_cov, id = id,
                family = binomial(link = "logit"),
                data = d, corstr = "independence")

  result <- get_marginal_effect(fit, trt = "trtp", method = "Ge",
                                 type = "robust", contrast = "or",
                                 reference = "0")

  expect_false(is.null(result$marginal_est))
  expect_false(is.null(result$marginal_se))
})

test_that("geeglm end-to-end with diff contrast", {
  skip_if_not_installed("geepack")
  library(geepack)

  d <- setup_gee_test_data(n = 100, seed = 52)
  fit <- geeglm(aval ~ trtp + bl_cov, id = id,
                family = binomial(link = "logit"),
                data = d, corstr = "independence")

  result <- get_marginal_effect(fit, trt = "trtp", method = "Ge",
                                 type = "robust", contrast = "diff",
                                 reference = "0")

  # Verify result structure
  expect_true("beeca" %in% class(result))
  expect_false(is.null(result$marginal_est))
  expect_false(is.null(result$marginal_se))
  expect_false(is.null(result$robust_varcov))

  # Verify ARD structure
  expect_true(tibble::is_tibble(result$marginal_results))
  expect_equal(nrow(result$marginal_results), 12)
  expect_equal(ncol(result$marginal_results), 8)
})

test_that("geeglm end-to-end with all five contrast types", {
  skip_if_not_installed("geepack")
  library(geepack)

  d <- setup_gee_test_data(n = 100, seed = 53)
  fit <- geeglm(aval ~ trtp + bl_cov, id = id,
                family = binomial(link = "logit"),
                data = d, corstr = "independence")

  contrasts <- c("diff", "or", "rr", "logor", "logrr")

  for (contrast_type in contrasts) {
    result <- get_marginal_effect(fit, trt = "trtp", method = "Ge",
                                   type = "robust", contrast = contrast_type,
                                   reference = "0")

    # Verify each produces valid output
    expect_true(is.numeric(result$marginal_est))
    expect_true(is.finite(result$marginal_est))
    expect_true(is.numeric(result$marginal_se))
    expect_true(is.finite(result$marginal_se))
  }
})

test_that("GEE default type resolution", {
  skip_if_not_installed("glmtoolbox")
  library(glmtoolbox)

  d <- setup_gee_test_data(n = 100, seed = 54)
  fit <- glmgee(aval ~ trtp + bl_cov, id = id,
                family = binomial(link = "logit"),
                data = d, corstr = "independence")

  # Call without specifying type (default HC0 should resolve to "robust" for GEE)
  result <- get_marginal_effect(fit, trt = "trtp", method = "Ge",
                                 contrast = "diff", reference = "0")

  # Check that the resolved type is "robust" not "HC0"
  type_attr <- attr(result$robust_varcov, "type")
  expect_true(grepl("robust", type_attr))
  expect_false(grepl("HC0", type_attr))
})
