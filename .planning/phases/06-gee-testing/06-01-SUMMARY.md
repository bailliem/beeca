---
phase: 06-gee-testing
plan: 01
subsystem: testing
tags: [gee, test, validation, variance, cross-validation, glmgee, geeglm, delta-method]
requires: [05-01-PLAN, 05-02-PLAN]
provides: [gee-test-suite, variance-cross-validation, r-cmd-check-compliance]
affects: [07-gee-documentation]
tech-stack:
  added: []
  patterns: [manual-delta-method-cross-validation, independent-variance-computation]
key-files:
  created: [tests/testthat/test-gee.R]
  modified: []
decisions:
  - id: use-inherits-not-tibble-pkg
    context: R CMD check flagged undeclared tibble import
    choice: Use inherits(x, "tbl_df") instead of tibble::is_tibble()
    rationale: Avoids adding tibble to test dependencies, uses base R check
metrics:
  duration: 333
  completed: 2026-02-07
---

# Phase 06 Plan 01: GEE Testing Summary

**One-liner:** Comprehensive GEE test suite with manual delta method cross-validation, covering glmgee/geeglm validation, variance estimation, and end-to-end pipeline

## What Was Built

Created `tests/testthat/test-gee.R` with 19 test_that blocks (60 test assertions) covering:

### Section 1: GEE Validation Tests (9 tests)
- **glmgee validation**: Valid models pass, wrong family/link rejected, treatment interactions rejected, multi-timepoint data rejected, Ye method correctly rejected
- **geeglm validation**: Valid models pass, wrong family rejected, multi-timepoint data rejected
- All tests use `skip_if_not_installed()` guards with paired `library()` calls

### Section 2: GEE Variance Estimation Tests (6 tests)
- **Manual delta method cross-validation** (CANONICAL tests):
  - For both glmgee and geeglm: independently compute V = D × V_beta × D^T
  - Predictions computed WITHOUT using beeca's counterfactual.predictions
  - Derivatives: p_k × (1 - p_k) for logit link
  - Cross-validated to 1e-10 tolerance against Ge et al (2011) formula
- **Variance type support**: bias-corrected, df-adjusted (glmgee), robust-only (geeglm)
- **Error handling**: GLM-style variance types (HC0, HC3, etc.) produce helpful errors

### Section 3: End-to-End Pipeline Tests (4 tests)
- **Multiple contrasts**: diff, or, rr, logor, logrr all produce valid output
- **ARD structure verification**: 12 rows, 8 columns, no NA values, correct STAT values
- **Default type resolution**: HC0 auto-resolves to "robust" for GEE objects
- **Both packages**: glmgee and geeglm tested in full pipeline

## Test Results

### Baseline Preservation
- **Before GEE tests**: 308 PASS (existing GLM tests)
- **After GEE tests**: 368 PASS (308 + 60 new GEE tests)
- **Regression check**: Zero existing test assertions modified or broken

### R CMD Check Compliance
```
0 errors ✔ | 0 warnings ✔ | 2 notes ✖
```

**Notes (acceptable):**
1. "unable to verify current time" - system time verification issue
2. "analysis-longitudinal-gee-extension.md" - research doc at top level

## Technical Details

### Manual Delta Method Cross-Validation

The canonical variance tests (glmgee and geeglm) independently compute expected variance:

```r
# Step 1: Get GEE's robust coefficient variance
V_beta <- vcov(fit)

# Step 2: For each treatment level k, compute derivative matrix D_k
for (trtlvl in c("0", "1")) {
  X_cf <- data; X_cf$trtp <- factor(trtlvl, levels = c("0", "1"))
  X_k <- model.matrix(formula, X_cf)

  # Independent predictions (NOT using beeca internals)
  linear_pred <- X_k %*% coef(fit)
  phat_k <- plogis(linear_pred)

  # Logit link derivative
  pderiv_k <- phat_k * (1 - phat_k)

  # Average derivative-weighted design matrix
  D_k <- (t(pderiv_k) %*% X_k) / n
}

# Step 3: Compute V_manual = D × V_beta × D^T
D <- rbind(D_0, D_1)
V_manual <- D %*% V_beta %*% t(D)

# Step 4: Compare to beeca output
expect_equal(result$robust_varcov[,], V_manual[,], tolerance = 1e-10)
```

### Test Data Setup

All tests use `setup_gee_test_data(n, seed)` helper:
- Single-timepoint: id = 1:n (cluster size = 1)
- Balanced allocation: 50% each arm
- Binary outcome: aval ~ rbinom(n, 1, 0.5)
- Continuous covariate: bl_cov ~ rnorm(n)

## Deviations from Plan

### Auto-fixed Issues

**1. [Rule 1 - Bug] Undeclared tibble import in tests**
- **Found during:** Task 1, R CMD check
- **Issue:** Used tibble::is_tibble() without declaring tibble in test dependencies
- **Fix:** Replaced with inherits(x, "tbl_df") using base R
- **Files modified:** tests/testthat/test-gee.R
- **Commit:** 91fe257

**2. [Rule 1 - Bug] Attribute mismatch in variance comparison**
- **Found during:** Task 1, test execution
- **Issue:** expect_equal() compared attributes (resolved_type, type) not just matrix values
- **Fix:** Changed to `result$robust_varcov[,]` vs `V_manual[,]` to compare values only
- **Files modified:** tests/testthat/test-gee.R
- **Commit:** ccae04d (included in initial commit after debugging)

**3. [Rule 1 - Bug] Wrong STAT value check**
- **Found during:** Task 1, test execution
- **Issue:** Checked for "contrast" in STAT column, but actual value is "diff" (the contrast name)
- **Fix:** Changed expect to check for "diff" in STAT column
- **Files modified:** tests/testthat/test-gee.R
- **Commit:** ccae04d (included in initial commit after debugging)

## Task Commits

| Task | Name | Commit | Files |
|------|------|--------|-------|
| 1 | Create GEE test suite | ccae04d | tests/testthat/test-gee.R |
| 2 | R CMD check compliance | 91fe257 | tests/testthat/test-gee.R |

## Verification

All success criteria met:

- ✅ **TEST-01**: test-gee.R exists with 19 tests covering validation, variance (manual delta method cross-validation for both packages), and end-to-end pipeline
- ✅ **TEST-02**: All 308 existing GLM test assertions pass unchanged (total: 368 PASS = 308 baseline + 60 new)
- ✅ **TEST-03**: R CMD check passes with 0 errors, 0 warnings (2 acceptable notes)

### Test Coverage Breakdown

```
Section 1 (Validation):     9 test_that blocks, ~15 assertions
Section 2 (Variance):       6 test_that blocks, ~25 assertions
Section 3 (End-to-End):     4 test_that blocks, ~20 assertions
Total:                      19 test_that blocks, 60 assertions
```

## Key Technical Patterns Established

1. **Manual cross-validation approach**: Independently compute expected values WITHOUT using beeca's internal data structures, then compare
2. **GEE test guards**: Always pair `skip_if_not_installed()` with `library()` call
3. **Single-timepoint test data**: Use id = 1:n to ensure cluster size = 1
4. **Variance comparison**: Use matrix indexing `[,]` to compare values, ignoring attributes

## Next Phase Readiness

Phase 7 (GEE Documentation) can proceed:

**Ready:**
- Test suite validates all GEE functionality
- R CMD check compliance achieved
- Cross-validation confirms correctness

**Blockers:** None

**Concerns:** None

## Self-Check: PASSED

All created files exist:
- ✅ tests/testthat/test-gee.R

All commits exist:
- ✅ ccae04d (test suite)
- ✅ 91fe257 (tibble fix)
