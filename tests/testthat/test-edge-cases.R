# Edge Case Tests for beeca Package
# Testing boundary conditions, extreme values, and error handling

# Setup test data
set.seed(123)
data <- trial01
data$trtp <- factor(data$trtp)
data_complete <- na.omit(data)

# Test 1: Perfect separation in logistic regression ----------------------

test_that("Handle perfect separation gracefully", {
  # Create perfectly separated data
  data_sep <- data.frame(
    y = c(rep(0, 50), rep(1, 50)),
    trt = factor(c(rep("A", 50), rep("B", 50))),
    x = rnorm(100)
  )

  # GLM will issue warnings about perfect separation
  expect_warning(
    fit <- glm(y ~ trt + x, family = "binomial", data = data_sep)
  )

  # Should still be able to get marginal effects (though may not be meaningful)
  expect_warning(
    result <- get_marginal_effect(fit, trt = "trt", method = "Ge", contrast = "diff")
  )
})


# Test 2: Extreme probability values (near 0 or 1) ----------------------

test_that("Handle extreme probability values", {
  # Create data with very high response rate in one arm
  data_extreme <- data.frame(
    y = c(rep(1, 95), rep(0, 5), rep(1, 50), rep(0, 50)),
    trt = factor(c(rep("A", 100), rep("B", 100))),
    x = rnorm(200)
  )

  fit <- glm(y ~ trt + x, family = "binomial", data = data_extreme)

  # Should work but may produce warnings for certain contrasts
  expect_no_error(
    result_diff <- get_marginal_effect(fit, trt = "trt", method = "Ge", contrast = "diff", reference = "B")
  )

  # Odds ratio with extreme values should warn
  expect_warning(
    result_or <- get_marginal_effect(fit, trt = "trt", method = "Ge", contrast = "or", reference = "B")
  )
})


# Test 3: Single observation per treatment arm --------------------------

test_that("Handle very small sample sizes", {
  # Create minimal dataset
  data_small <- data.frame(
    y = c(0, 1, 0),
    trt = factor(c("A", "B", "C")),
    x = c(1, 2, 3)
  )

  # Should fail or warn about insufficient data
  expect_warning({
    fit <- glm(y ~ trt + x, family = "binomial", data = data_small)
  })
})


# Test 4: All zeros or all ones in outcome -------------------------------

test_that("Handle constant outcome variable", {
  # All zeros
  data_zeros <- data.frame(
    y = rep(0, 100),
    trt = factor(sample(c("A", "B"), 100, replace = TRUE)),
    x = rnorm(100)
  )

  expect_warning(
    fit_zeros <- glm(y ~ trt + x, family = "binomial", data = data_zeros)
  )

  # All ones
  data_ones <- data.frame(
    y = rep(1, 100),
    trt = factor(sample(c("A", "B"), 100, replace = TRUE)),
    x = rnorm(100)
  )

  expect_warning(
    fit_ones <- glm(y ~ trt + x, family = "binomial", data = data_ones)
  )
})


# Test 5: Division by zero in contrasts ----------------------------------

test_that("Risk ratio handles zero denominator", {
  # Test the internal contrast functions directly
  expect_warning(
    result <- beeca:::rr(0.5, 0),
    "Zero denominator detected in risk ratio"
  )
  expect_true(is.na(beeca:::rr(0.5, 0)))
})

test_that("Odds ratio handles boundary values", {
  # Test x = 0
  expect_warning(
    result <- beeca:::or(0, 0.5),
    "Boundary value.*detected in odds ratio"
  )

  # Test x = 1
  expect_warning(
    result <- beeca:::or(1, 0.5),
    "Boundary value.*detected in odds ratio"
  )

  # Test y = 0
  expect_warning(
    result <- beeca:::or(0.5, 0),
    "Boundary value.*detected in odds ratio"
  )

  # Test y = 1
  expect_warning(
    result <- beeca:::or(0.5, 1),
    "Boundary value.*detected in odds ratio"
  )
})

test_that("Log risk ratio handles zero and negative values", {
  # Zero denominator
  expect_warning(
    result <- beeca:::logrr(0.5, 0),
    "Invalid value detected in log risk ratio"
  )

  # Zero numerator
  expect_warning(
    result <- beeca:::logrr(0, 0.5),
    "Invalid value detected in log risk ratio"
  )

  # Negative numerator
  expect_warning(
    result <- beeca:::logrr(-0.1, 0.5),
    "Invalid value detected in log risk ratio"
  )
})

test_that("Log odds ratio handles boundary values", {
  # Test all boundary combinations
  expect_warning(beeca:::logor(0, 0.5))
  expect_warning(beeca:::logor(1, 0.5))
  expect_warning(beeca:::logor(0.5, 0))
  expect_warning(beeca:::logor(0.5, 1))
})


# Test 6: Gradient functions with extreme values -------------------------

test_that("Gradient functions handle division by zero", {
  expect_warning(
    grad <- beeca:::grad_rr(0.5, 0),
    "Zero denominator detected in risk ratio gradient"
  )
  expect_true(all(is.na(grad)))
})

test_that("Gradient functions for odds ratio handle boundaries", {
  expect_warning(
    grad <- beeca:::grad_or(0, 0.5),
    "Boundary value detected in odds ratio gradient"
  )
  expect_true(all(is.na(grad)))

  expect_warning(
    grad <- beeca:::grad_or(1, 0.5),
    "Boundary value detected in odds ratio gradient"
  )
  expect_true(all(is.na(grad)))
})

test_that("Gradient functions for log contrasts handle zeros", {
  expect_warning(
    grad <- beeca:::grad_logrr(0, 0.5),
    "Zero value detected in log risk ratio gradient"
  )
  expect_true(all(is.na(grad)))

  expect_warning(
    grad <- beeca:::grad_logrr(0.5, 0),
    "Zero value detected in log risk ratio gradient"
  )
  expect_true(all(is.na(grad)))
})


# Test 7: Missing reference level in contrasts ---------------------------

test_that("Apply contrast with missing reference level", {
  fit <- glm(aval ~ trtp + bl_cov, family = "binomial", data = data_complete)
  fit_prep <- fit |>
    predict_counterfactuals(trt = "trtp") |>
    average_predictions() |>
    estimate_varcov(method = "Ge")

  # Invalid reference level
  expect_error(
    apply_contrast(fit_prep, contrast = "diff", reference = "NonExistent"),
    "Reference levels must be a subset of treatment levels"
  )

  # Too many reference levels
  expect_error(
    apply_contrast(fit_prep, contrast = "diff", reference = c("0", "1")),
    "Too many reference levels provided"
  )
})


# Test 8: Empty strata ---------------------------------------------------

test_that("Handle stratification with empty strata", {
  # Create data with stratification variable
  data_strata <- data_complete
  data_strata$strata <- factor(sample(c("S1", "S2", "S3"), nrow(data_strata), replace = TRUE))

  # Now remove all observations from one stratum
  data_strata <- data_strata[data_strata$strata != "S3", ]
  data_strata$strata <- droplevels(data_strata$strata)

  fit <- glm(aval ~ trtp + bl_cov + strata, family = "binomial", data = data_strata)

  # Should work with Ye's method and strata
  expect_no_error(
    result <- get_marginal_effect(fit, trt = "trtp", strata = "strata", method = "Ye", contrast = "diff", reference = "0")
  )
})


# Test 9: High-dimensional covariates (many strata) ----------------------

test_that("Warn when stratification variable has many levels", {
  data_many_strata <- data_complete
  # Create a stratification variable with many unique values (simulating continuous variable)
  data_many_strata$strata <- sample(1:50, nrow(data_many_strata), replace = TRUE)

  fit <- glm(aval ~ trtp + bl_cov, family = "binomial", data = data_many_strata)

  # Should warn about many unique values in strata
  expect_warning(
    result <- get_marginal_effect(fit, trt = "trtp", strata = "strata", method = "Ye", contrast = "diff", reference = "0"),
    "More than three unique values are found in stratification variable"
  )
})


# Test 10: Confidence interval edge cases --------------------------------

test_that("Confidence intervals work with different levels", {
  fit <- glm(aval ~ trtp + bl_cov, family = "binomial", data = data_complete) |>
    get_marginal_effect(trt = "trtp", method = "Ge", contrast = "diff", reference = "0")

  # 95% CI
  ci_95 <- confint(fit, level = 0.95)
  expect_equal(nrow(ci_95), 1)
  expect_equal(ci_95$conf.level[1], 0.95)

  # 90% CI
  ci_90 <- confint(fit, level = 0.90)
  expect_equal(ci_90$conf.level[1], 0.90)

  # 99% CI
  ci_99 <- confint(fit, level = 0.99)
  expect_equal(ci_99$conf.level[1], 0.99)

  # Verify that wider CI has larger interval
  width_90 <- ci_90$upper - ci_90$lower
  width_95 <- ci_95$upper - ci_95$lower
  width_99 <- ci_99$upper - ci_99$lower
  expect_true(width_90 < width_95)
  expect_true(width_95 < width_99)
})

test_that("confint falls back to stats::confint.glm for non-beeca objects", {
  fit <- glm(aval ~ trtp + bl_cov, family = "binomial", data = data_complete)

  # Should use default confint.glm
  expect_no_error(ci <- confint(fit))
  expect_true(is.matrix(ci))
})


# Test 11: Summary method edge cases -------------------------------------

test_that("Summary method works correctly", {
  fit <- glm(aval ~ trtp + bl_cov, family = "binomial", data = data_complete) |>
    get_marginal_effect(trt = "trtp", method = "Ge", contrast = "diff", reference = "0")

  expect_no_error(summ <- summary(fit))
  expect_s3_class(summ, "summary.beeca_marginal")
  expect_equal(summ$n_arms, 2)
  expect_equal(summ$treatment_var, "trtp")
})

test_that("Summary fails gracefully without marginal effects", {
  fit <- glm(aval ~ trtp + bl_cov, family = "binomial", data = data_complete)

  expect_error(
    summary.beeca_marginal(fit),
    "Object does not contain marginal effect estimates"
  )
})


# Test 12: Multi-arm trials with various contrasts -----------------------

test_that("Multi-arm trials work with all contrasts", {
  # Create 3-arm trial data
  data_3arm <- data.frame(
    y = rbinom(300, 1, 0.5),
    trt = factor(sample(c("A", "B", "C"), 300, replace = TRUE)),
    x = rnorm(300)
  )

  fit <- glm(y ~ trt + x, family = "binomial", data = data_3arm)

  # Test all contrast types
  contrasts <- c("diff", "rr", "or", "logrr", "logor")

  for (contrast_type in contrasts) {
    expect_no_error({
      result <- get_marginal_effect(
        fit,
        trt = "trt",
        method = "Ge",
        contrast = contrast_type,
        reference = c("A", "B")
      )
    }, info = paste("Testing contrast:", contrast_type))

    # Should have 2 contrasts (C vs A, C vs B)
    expect_equal(length(result$marginal_est), 2, info = paste("Testing contrast:", contrast_type))
  }
})


# Test 13: Numerical stability with very small/large values --------------

test_that("Handle very small probabilities", {
  # Simulate data that will produce very small predicted probabilities
  data_small_p <- data.frame(
    y = c(rep(0, 990), rep(1, 10)),
    trt = factor(sample(c("A", "B"), 1000, replace = TRUE)),
    x = rnorm(1000)
  )

  fit <- glm(y ~ trt + x, family = "binomial", data = data_small_p)

  expect_no_error(
    result <- get_marginal_effect(fit, trt = "trt", method = "Ge", contrast = "diff", reference = "A")
  )

  # Check that estimates are reasonable (should be close to observed rate)
  expect_true(abs(result$counterfactual.means["A"]) < 0.1)
  expect_true(abs(result$counterfactual.means["B"]) < 0.1)
})


# Test 14: Verify warning suppression doesn't hide real issues -----------

test_that("Important warnings are not suppressed", {
  # Non-convergence should still warn
  suppressWarnings(
    fit <- glm(aval ~ trtp,
      family = "binomial",
      data = data_complete,
      control = glm.control(maxit = 1)
    )
  )

  expect_warning(
    sanitize_model(fit, "trtp"),
    "not converged"
  )
})
