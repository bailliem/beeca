#!/usr/bin/env Rscript

# Feasibility Test: beeca Pipeline with GEE Objects
# Plan: 01.1-01
# Purpose: Test each beeca pipeline step with GEE objects to assess compatibility

cat("============================================================\n")
cat("beeca + GEE Feasibility Test\n")
cat("============================================================\n\n")

# ==============================================================================
# Setup
# ==============================================================================

cat("## SETUP ##\n")

# Load beeca from source
cat("Loading beeca from source...\n")
suppressPackageStartupMessages({
  devtools::load_all(".", quiet = TRUE)
})
cat("  ✓ beeca loaded\n\n")

# Install/load GEE packages
cat("Loading GEE packages...\n")
required_pkgs <- c("glmtoolbox", "geepack")
for (pkg in required_pkgs) {
  if (!requireNamespace(pkg, quietly = TRUE)) {
    cat(sprintf("  Installing %s...\n", pkg))
    install.packages(pkg, quiet = TRUE)
  }
  suppressPackageStartupMessages(library(pkg, character.only = TRUE))
}
cat("  ✓ glmtoolbox and geepack loaded\n\n")

# ==============================================================================
# Create Test Data
# ==============================================================================

cat("## TEST DATA ##\n")
cat("Creating longitudinal binary dataset...\n")

set.seed(42)
n_subjects <- 100
n_visits <- 4

# Subject-level data
subjects <- data.frame(
  id = rep(1:n_subjects, each = n_visits),
  trtp = rep(factor(sample(c("A", "B"), n_subjects, replace = TRUE)), each = n_visits),
  bl_cov = rep(rnorm(n_subjects, mean = 50, sd = 10), each = n_visits)
)

# Visit-level data
subjects$visit <- rep(1:n_visits, times = n_subjects)
subjects$time <- (subjects$visit - 1) * 4  # weeks

# Generate binary outcome (visits correlated within subject)
# Simulate with random subject effect
subject_effects <- rep(rnorm(n_subjects, 0, 0.5), each = n_visits)
logit_p <- -0.5 +
           0.3 * (subjects$trtp == "B") +
           0.01 * (subjects$bl_cov - 50) +
           0.05 * subjects$time +
           subject_effects
p <- plogis(logit_p)
subjects$aval <- rbinom(nrow(subjects), 1, p)

cat(sprintf("  Created dataset: %d subjects × %d visits = %d observations\n",
            n_subjects, n_visits, nrow(subjects)))
cat(sprintf("  Treatment arms: %s\n", paste(levels(subjects$trtp), collapse = ", ")))
cat(sprintf("  Outcome prevalence: %.1f%%\n", 100*mean(subjects$aval)))

# Single-timepoint subset for Phase 1 testing
subjects_t1 <- subjects[subjects$visit == 1, ]
cat(sprintf("  Single timepoint subset: %d observations\n", nrow(subjects_t1)))
cat("\n")

# ==============================================================================
# Fit GEE Models
# ==============================================================================

cat("## FIT GEE MODELS ##\n")

# glmgee (glmtoolbox) - longitudinal
cat("Fitting glmgee (longitudinal)...\n")
tryCatch({
  fit_glmgee <- glmgee(
    aval ~ trtp + bl_cov + time,
    id = id,
    family = binomial(logit),
    data = subjects,
    corstr = "exchangeable"
  )
  cat(sprintf("  ✓ glmgee converged: %s\n", fit_glmgee$converged))
  cat(sprintf("    Coefficients: %s\n", paste(names(coef(fit_glmgee)), collapse = ", ")))
}, error = function(e) {
  cat(sprintf("  ✗ glmgee fitting FAILED: %s\n", e$message))
  fit_glmgee <<- NULL
})

# geeglm (geepack) - longitudinal
cat("Fitting geeglm (longitudinal)...\n")
tryCatch({
  fit_geeglm <- geeglm(
    aval ~ trtp + bl_cov + time,
    id = id,
    family = binomial(link = "logit"),
    data = subjects,
    corstr = "exchangeable"
  )
  cat(sprintf("  ✓ geeglm fitted\n"))
  cat(sprintf("    Coefficients: %s\n", paste(names(coef(fit_geeglm)), collapse = ", ")))
}, error = function(e) {
  cat(sprintf("  ✗ geeglm fitting FAILED: %s\n", e$message))
  fit_geeglm <<- NULL
})

# glmgee - single timepoint (Phase 1 scenario)
cat("Fitting glmgee (single timepoint)...\n")
tryCatch({
  fit_glmgee_t1 <- glmgee(
    aval ~ trtp + bl_cov,
    id = id,
    family = binomial(logit),
    data = subjects_t1,
    corstr = "independence"
  )
  cat(sprintf("  ✓ glmgee-t1 converged: %s\n", fit_glmgee_t1$converged))
}, error = function(e) {
  cat(sprintf("  ✗ glmgee-t1 fitting FAILED: %s\n", e$message))
  fit_glmgee_t1 <<- NULL
})

cat("\n")

# ==============================================================================
# Test beeca Pipeline Steps
# ==============================================================================

cat("## PIPELINE STEP TESTS ##\n")
cat("Testing each beeca function with GEE objects...\n\n")

results <- list()

# ------------------------------------------------------------------------------
# Step 1: sanitize_model()
# ------------------------------------------------------------------------------

cat("### Step 1: sanitize_model() ###\n")

# Test with glmgee (longitudinal)
cat("[glmgee-longitudinal] Testing sanitize_model()...\n")
results$sanitize_glmgee <- tryCatch({
  sanitized <- sanitize_model(fit_glmgee, "trtp")
  list(status = "PASS",
       result = "Sanitize succeeded",
       sanitized = sanitized$sanitized)
}, error = function(e) {
  list(status = "FAIL",
       error = e$message)
})
cat(sprintf("  Result: %s\n", results$sanitize_glmgee$status))
if (results$sanitize_glmgee$status == "FAIL") {
  cat(sprintf("  Error: %s\n", results$sanitize_glmgee$error))
}

# Test with geeglm (longitudinal)
cat("[geeglm-longitudinal] Testing sanitize_model()...\n")
results$sanitize_geeglm <- tryCatch({
  sanitized <- sanitize_model(fit_geeglm, "trtp")
  list(status = "PASS",
       result = "Sanitize succeeded",
       sanitized = sanitized$sanitized)
}, error = function(e) {
  list(status = "FAIL",
       error = e$message)
})
cat(sprintf("  Result: %s\n", results$sanitize_geeglm$status))
if (results$sanitize_geeglm$status == "FAIL") {
  cat(sprintf("  Error: %s\n", results$sanitize_geeglm$error))
}

# Test with glmgee single timepoint
cat("[glmgee-t1] Testing sanitize_model()...\n")
results$sanitize_glmgee_t1 <- tryCatch({
  sanitized <- sanitize_model(fit_glmgee_t1, "trtp")
  list(status = "PASS",
       result = "Sanitize succeeded",
       sanitized = sanitized$sanitized)
}, error = function(e) {
  list(status = "FAIL",
       error = e$message)
})
cat(sprintf("  Result: %s\n", results$sanitize_glmgee_t1$status))
if (results$sanitize_glmgee_t1$status == "FAIL") {
  cat(sprintf("  Error: %s\n", results$sanitize_glmgee_t1$error))
}
cat("\n")

# ------------------------------------------------------------------------------
# Step 2: .get_data()
# ------------------------------------------------------------------------------

cat("### Step 2: beeca:::.get_data() ###\n")

cat("[glmgee] Testing .get_data()...\n")
results$get_data_glmgee <- tryCatch({
  data <- beeca:::.get_data(fit_glmgee)
  list(status = "PASS",
       nrow = nrow(data),
       ncol = ncol(data),
       has_model_slot = !is.null(fit_glmgee$model))
}, error = function(e) {
  list(status = "FAIL",
       error = e$message,
       has_model_slot = !is.null(fit_glmgee$model))
})
cat(sprintf("  Result: %s\n", results$get_data_glmgee$status))
if (results$get_data_glmgee$status == "PASS") {
  cat(sprintf("  Data dimensions: %d × %d\n",
              results$get_data_glmgee$nrow,
              results$get_data_glmgee$ncol))
} else {
  cat(sprintf("  Error: %s\n", results$get_data_glmgee$error))
}
cat(sprintf("  Has model$model slot: %s\n", results$get_data_glmgee$has_model_slot))

cat("[geeglm] Testing .get_data()...\n")
results$get_data_geeglm <- tryCatch({
  data <- beeca:::.get_data(fit_geeglm)
  list(status = "PASS",
       nrow = nrow(data),
       ncol = ncol(data),
       has_model_slot = !is.null(fit_geeglm$model))
}, error = function(e) {
  list(status = "FAIL",
       error = e$message,
       has_model_slot = !is.null(fit_geeglm$model))
})
cat(sprintf("  Result: %s\n", results$get_data_geeglm$status))
if (results$get_data_geeglm$status == "PASS") {
  cat(sprintf("  Data dimensions: %d × %d\n",
              results$get_data_geeglm$nrow,
              results$get_data_geeglm$ncol))
} else {
  cat(sprintf("  Error: %s\n", results$get_data_geeglm$error))
}
cat(sprintf("  Has model$model slot: %s\n", results$get_data_geeglm$has_model_slot))
cat("\n")

# ------------------------------------------------------------------------------
# Step 3: predict() with newdata (CRITICAL TEST)
# ------------------------------------------------------------------------------

cat("### Step 3: predict() with newdata (CRITICAL) ###\n")

# Test with glmgee
cat("[glmgee] Testing predict(newdata, type='response')...\n")
results$predict_glmgee <- tryCatch({
  # Create counterfactual data: all subjects set to treatment A
  cf_data_A <- subjects
  cf_data_A$trtp <- factor("A", levels = c("A", "B"))

  # Predict
  pred_A <- predict(fit_glmgee, newdata = cf_data_A, type = "response")

  # Create counterfactual data: all subjects set to treatment B
  cf_data_B <- subjects
  cf_data_B$trtp <- factor("B", levels = c("A", "B"))
  pred_B <- predict(fit_glmgee, newdata = cf_data_B, type = "response")

  list(status = "PASS",
       length_A = length(pred_A),
       length_B = length(pred_B),
       range_A = range(pred_A),
       range_B = range(pred_B),
       mean_A = mean(pred_A),
       mean_B = mean(pred_B),
       all_in_01 = all(pred_A >= 0 & pred_A <= 1) && all(pred_B >= 0 & pred_B <= 1))
}, error = function(e) {
  list(status = "FAIL",
       error = e$message)
})
cat(sprintf("  Result: %s\n", results$predict_glmgee$status))
if (results$predict_glmgee$status == "PASS") {
  cat(sprintf("  Predictions length: A=%d, B=%d\n",
              results$predict_glmgee$length_A,
              results$predict_glmgee$length_B))
  cat(sprintf("  Mean predictions: A=%.4f, B=%.4f\n",
              results$predict_glmgee$mean_A,
              results$predict_glmgee$mean_B))
  cat(sprintf("  All predictions in [0,1]: %s\n",
              results$predict_glmgee$all_in_01))
} else {
  cat(sprintf("  Error: %s\n", results$predict_glmgee$error))
}

# Test with geeglm
cat("[geeglm] Testing predict(newdata, type='response')...\n")
results$predict_geeglm <- tryCatch({
  cf_data_A <- subjects
  cf_data_A$trtp <- factor("A", levels = c("A", "B"))
  pred_A <- predict(fit_geeglm, newdata = cf_data_A, type = "response")

  cf_data_B <- subjects
  cf_data_B$trtp <- factor("B", levels = c("A", "B"))
  pred_B <- predict(fit_geeglm, newdata = cf_data_B, type = "response")

  list(status = "PASS",
       length_A = length(pred_A),
       length_B = length(pred_B),
       range_A = range(pred_A),
       range_B = range(pred_B),
       mean_A = mean(pred_A),
       mean_B = mean(pred_B),
       all_in_01 = all(pred_A >= 0 & pred_A <= 1) && all(pred_B >= 0 & pred_B <= 1))
}, error = function(e) {
  list(status = "FAIL",
       error = e$message)
})
cat(sprintf("  Result: %s\n", results$predict_geeglm$status))
if (results$predict_geeglm$status == "PASS") {
  cat(sprintf("  Predictions length: A=%d, B=%d\n",
              results$predict_geeglm$length_A,
              results$predict_geeglm$length_B))
  cat(sprintf("  Mean predictions: A=%.4f, B=%.4f\n",
              results$predict_geeglm$mean_A,
              results$predict_geeglm$mean_B))
  cat(sprintf("  All predictions in [0,1]: %s\n",
              results$predict_geeglm$all_in_01))
} else {
  cat(sprintf("  Error: %s\n", results$predict_geeglm$error))
}
cat("\n")

# ------------------------------------------------------------------------------
# Step 4: predict_counterfactuals()
# ------------------------------------------------------------------------------

cat("### Step 4: predict_counterfactuals() ###\n")

cat("[glmgee-t1] Testing predict_counterfactuals()...\n")
results$pred_cf_glmgee_t1 <- tryCatch({
  fit_cf <- predict_counterfactuals(fit_glmgee_t1, "trtp")
  list(status = "PASS",
       has_cf_predictions = "counterfactual.predictions" %in% names(fit_cf),
       cf_dims = if("counterfactual.predictions" %in% names(fit_cf)) dim(fit_cf$counterfactual.predictions) else NULL)
}, error = function(e) {
  list(status = "FAIL",
       error = e$message)
})
cat(sprintf("  Result: %s\n", results$pred_cf_glmgee_t1$status))
if (results$pred_cf_glmgee_t1$status == "FAIL") {
  cat(sprintf("  Error: %s\n", results$pred_cf_glmgee_t1$error))
} else {
  cat(sprintf("  Has counterfactual.predictions: %s\n",
              results$pred_cf_glmgee_t1$has_cf_predictions))
  if (!is.null(results$pred_cf_glmgee_t1$cf_dims)) {
    cat(sprintf("  CF predictions dimensions: %d × %d\n",
                results$pred_cf_glmgee_t1$cf_dims[1],
                results$pred_cf_glmgee_t1$cf_dims[2]))
  }
}
cat("\n")

# ------------------------------------------------------------------------------
# Step 5: model.matrix()
# ------------------------------------------------------------------------------

cat("### Step 5: model.matrix() ###\n")

cat("[glmgee] Testing model.matrix()...\n")
results$model_matrix_glmgee <- tryCatch({
  # Test direct model.matrix call
  mm <- model.matrix(fit_glmgee)

  # Test with modified data (needed for Ge variance)
  data <- beeca:::.get_data(fit_glmgee)
  modified_data <- data
  modified_data$trtp <- factor("A", levels = c("A", "B"))
  mm_modified <- model.matrix(fit_glmgee$formula, modified_data)

  list(status = "PASS",
       mm_dims = dim(mm),
       mm_modified_dims = dim(mm_modified),
       n_coef = length(coef(fit_glmgee)))
}, error = function(e) {
  list(status = "FAIL",
       error = e$message)
})
cat(sprintf("  Result: %s\n", results$model_matrix_glmgee$status))
if (results$model_matrix_glmgee$status == "PASS") {
  cat(sprintf("  model.matrix() dimensions: %d × %d\n",
              results$model_matrix_glmgee$mm_dims[1],
              results$model_matrix_glmgee$mm_dims[2]))
  cat(sprintf("  With modified data: %d × %d\n",
              results$model_matrix_glmgee$mm_modified_dims[1],
              results$model_matrix_glmgee$mm_modified_dims[2]))
  cat(sprintf("  Number of coefficients: %d\n",
              results$model_matrix_glmgee$n_coef))
} else {
  cat(sprintf("  Error: %s\n", results$model_matrix_glmgee$error))
}
cat("\n")

# ------------------------------------------------------------------------------
# Step 6: vcov() with different types
# ------------------------------------------------------------------------------

cat("### Step 6: vcov() ###\n")

# Test glmgee vcov() with different types
cat("[glmgee] Testing vcov() with type options...\n")
vcov_types <- c("robust", "bias-corrected", "df-adjusted")
results$vcov_glmgee <- list()

for (vtype in vcov_types) {
  cat(sprintf("  Testing type='%s'...\n", vtype))
  results$vcov_glmgee[[vtype]] <- tryCatch({
    V <- vcov(fit_glmgee, type = vtype)
    list(status = "PASS",
         dims = dim(V),
         is_symmetric = isSymmetric(V),
         diag_positive = all(diag(V) > 0))
  }, error = function(e) {
    list(status = "FAIL",
         error = e$message)
  })

  if (results$vcov_glmgee[[vtype]]$status == "PASS") {
    cat(sprintf("    ✓ Dimensions: %d × %d, Symmetric: %s, Positive diagonal: %s\n",
                results$vcov_glmgee[[vtype]]$dims[1],
                results$vcov_glmgee[[vtype]]$dims[2],
                results$vcov_glmgee[[vtype]]$is_symmetric,
                results$vcov_glmgee[[vtype]]$diag_positive))
  } else {
    cat(sprintf("    ✗ Error: %s\n", results$vcov_glmgee[[vtype]]$error))
  }
}

# Test geeglm vcov()
cat("[geeglm] Testing vcov()...\n")
results$vcov_geeglm <- tryCatch({
  V <- vcov(fit_geeglm)
  list(status = "PASS",
       dims = dim(V),
       is_symmetric = isSymmetric(V),
       diag_positive = all(diag(V) > 0))
}, error = function(e) {
  list(status = "FAIL",
       error = e$message)
})
cat(sprintf("  Result: %s\n", results$vcov_geeglm$status))
if (results$vcov_geeglm$status == "PASS") {
  cat(sprintf("  Dimensions: %d × %d, Symmetric: %s, Positive diagonal: %s\n",
              results$vcov_geeglm$dims[1],
              results$vcov_geeglm$dims[2],
              results$vcov_geeglm$is_symmetric,
              results$vcov_geeglm$diag_positive))
} else {
  cat(sprintf("  Error: %s\n", results$vcov_geeglm$error))
}
cat("\n")

# ------------------------------------------------------------------------------
# Step 7: sandwich::vcovHC()
# ------------------------------------------------------------------------------

cat("### Step 7: sandwich::vcovHC() ###\n")

cat("[glmgee] Testing sandwich::vcovHC()...\n")
results$sandwich_glmgee <- tryCatch({
  V <- sandwich::vcovHC(fit_glmgee, type = "HC0")
  list(status = "PASS",
       dims = dim(V))
}, error = function(e) {
  list(status = "FAIL",
       error = e$message)
})
cat(sprintf("  Result: %s\n", results$sandwich_glmgee$status))
if (results$sandwich_glmgee$status == "FAIL") {
  cat(sprintf("  Error: %s\n", results$sandwich_glmgee$error))
}
cat("\n")

# ------------------------------------------------------------------------------
# Step 8: Manual Ge delta method
# ------------------------------------------------------------------------------

cat("### Step 8: Manual Ge Delta Method ###\n")

cat("[glmgee-t1] Testing manual Ge variance calculation...\n")
results$manual_ge_glmgee_t1 <- tryCatch({
  # Get counterfactual predictions (if available from step 4)
  if (results$pred_cf_glmgee_t1$status == "PASS") {
    fit_temp <- predict_counterfactuals(fit_glmgee_t1, "trtp")
    cf_pred <- fit_temp$counterfactual.predictions

    # Get data
    data <- beeca:::.get_data(fit_glmgee_t1)

    # Get vcov from GEE (robust)
    V <- vcov(fit_glmgee_t1, type = "robust")

    # Compute derivatives for each treatment level
    d_list <- list()
    for (trtlvl in levels(data$trtp)) {
      X_i <- data
      X_i$trtp <- factor(trtlvl, levels = levels(data$trtp))
      X_i <- model.matrix(fit_glmgee_t1$formula, X_i)

      pderiv_i <- cf_pred[[trtlvl]] * (1 - cf_pred[[trtlvl]])
      d_i <- (t(pderiv_i) %*% as.matrix(X_i)) / nrow(X_i)
      d_list[[trtlvl]] <- d_i
    }

    all_d <- do.call(rbind, d_list)
    varcov_ge <- all_d %*% V %*% t(all_d)

    list(status = "PASS",
         varcov_dims = dim(varcov_ge),
         varcov_ge = varcov_ge,
         is_symmetric = isSymmetric(as.matrix(varcov_ge)),
         diag_positive = all(diag(varcov_ge) > 0))
  } else {
    list(status = "SKIP",
         reason = "predict_counterfactuals failed")
  }
}, error = function(e) {
  list(status = "FAIL",
       error = e$message)
})
cat(sprintf("  Result: %s\n", results$manual_ge_glmgee_t1$status))
if (results$manual_ge_glmgee_t1$status == "PASS") {
  cat(sprintf("  Variance-covariance matrix: %d × %d\n",
              results$manual_ge_glmgee_t1$varcov_dims[1],
              results$manual_ge_glmgee_t1$varcov_dims[2]))
  cat(sprintf("  Symmetric: %s, Positive diagonal: %s\n",
              results$manual_ge_glmgee_t1$is_symmetric,
              results$manual_ge_glmgee_t1$diag_positive))
  cat("  Matrix values:\n")
  print(results$manual_ge_glmgee_t1$varcov_ge)
} else if (results$manual_ge_glmgee_t1$status == "FAIL") {
  cat(sprintf("  Error: %s\n", results$manual_ge_glmgee_t1$error))
} else {
  cat(sprintf("  Skipped: %s\n", results$manual_ge_glmgee_t1$reason))
}
cat("\n")

# ------------------------------------------------------------------------------
# Step 9: average_predictions()
# ------------------------------------------------------------------------------

cat("### Step 9: average_predictions() ###\n")

cat("[glmgee-t1] Testing average_predictions()...\n")
results$avg_pred_glmgee_t1 <- tryCatch({
  if (results$pred_cf_glmgee_t1$status == "PASS") {
    fit_temp <- predict_counterfactuals(fit_glmgee_t1, "trtp")
    fit_avg <- average_predictions(fit_temp)
    list(status = "PASS",
         has_means = "counterfactual.means" %in% names(fit_avg),
         means = if("counterfactual.means" %in% names(fit_avg)) fit_avg$counterfactual.means else NULL)
  } else {
    list(status = "SKIP",
         reason = "predict_counterfactuals failed")
  }
}, error = function(e) {
  list(status = "FAIL",
       error = e$message)
})
cat(sprintf("  Result: %s\n", results$avg_pred_glmgee_t1$status))
if (results$avg_pred_glmgee_t1$status == "PASS") {
  cat(sprintf("  Has counterfactual.means: %s\n",
              results$avg_pred_glmgee_t1$has_means))
  if (!is.null(results$avg_pred_glmgee_t1$means)) {
    cat("  Means:\n")
    print(results$avg_pred_glmgee_t1$means)
  }
} else if (results$avg_pred_glmgee_t1$status == "FAIL") {
  cat(sprintf("  Error: %s\n", results$avg_pred_glmgee_t1$error))
} else {
  cat(sprintf("  Skipped: %s\n", results$avg_pred_glmgee_t1$reason))
}
cat("\n")

# ==============================================================================
# Summary Results
# ==============================================================================

cat("============================================================\n")
cat("SUMMARY\n")
cat("============================================================\n\n")

summary_table <- data.frame(
  Step = c(
    "1. sanitize_model (glmgee-long)",
    "1. sanitize_model (geeglm-long)",
    "1. sanitize_model (glmgee-t1)",
    "2. .get_data (glmgee)",
    "2. .get_data (geeglm)",
    "3. predict+newdata (glmgee)",
    "3. predict+newdata (geeglm)",
    "4. predict_counterfactuals (glmgee-t1)",
    "5. model.matrix (glmgee)",
    "6. vcov-robust (glmgee)",
    "6. vcov-bias-corrected (glmgee)",
    "6. vcov-df-adjusted (glmgee)",
    "6. vcov (geeglm)",
    "7. sandwich::vcovHC (glmgee)",
    "8. manual Ge delta (glmgee-t1)",
    "9. average_predictions (glmgee-t1)"
  ),
  Result = c(
    results$sanitize_glmgee$status,
    results$sanitize_geeglm$status,
    results$sanitize_glmgee_t1$status,
    results$get_data_glmgee$status,
    results$get_data_geeglm$status,
    results$predict_glmgee$status,
    results$predict_geeglm$status,
    results$pred_cf_glmgee_t1$status,
    results$model_matrix_glmgee$status,
    results$vcov_glmgee$robust$status,
    results$vcov_glmgee$`bias-corrected`$status,
    results$vcov_glmgee$`df-adjusted`$status,
    results$vcov_geeglm$status,
    results$sandwich_glmgee$status,
    results$manual_ge_glmgee_t1$status,
    results$avg_pred_glmgee_t1$status
  ),
  stringsAsFactors = FALSE
)

print(summary_table, row.names = FALSE)

cat("\n")
cat("## KEY FINDINGS ##\n\n")

cat("CRITICAL TESTS:\n")
cat(sprintf("  predict() with newdata: %s (glmgee), %s (geeglm)\n",
            results$predict_glmgee$status,
            results$predict_geeglm$status))
cat(sprintf("  vcov() with type options: %s (glmgee robust)\n",
            results$vcov_glmgee$robust$status))
cat("\n")

cat("EXPECTED FAILURES:\n")
cat(sprintf("  sanitize_model (no S3 method): %s\n",
            ifelse(results$sanitize_glmgee$status == "FAIL", "✓ Failed as expected",
                   "✗ Unexpected pass")))
cat(sprintf("  sandwich::vcovHC (not for GEE): %s\n",
            ifelse(results$sandwich_glmgee$status == "FAIL", "✓ Failed as expected",
                   "✗ Unexpected pass")))
cat("\n")

cat("FEASIBILITY ASSESSMENT:\n")
if (results$predict_glmgee$status == "PASS" && results$vcov_glmgee$robust$status == "PASS") {
  cat("  ✓ FEASIBLE: Core requirements (predict + vcov) work with GEE objects\n")
  cat("  ✓ Manual Ge delta method can be implemented using vcov(gee, type='robust')\n")
} else {
  cat("  ✗ NOT FEASIBLE: Core requirements failed\n")
}
cat("\n")

cat("============================================================\n")
cat("Test complete. Results saved for Plan 02 feasibility report.\n")
cat("============================================================\n")
