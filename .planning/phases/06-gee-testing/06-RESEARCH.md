# Phase 6: GEE Testing - Research

**Researched:** 2026-02-07
**Domain:** R package testing with testthat 3e, GEE variance validation, R CMD check compliance
**Confidence:** HIGH

## Summary

This research investigates how to build a comprehensive test suite for GEE functionality in beeca, ensure zero regressions in existing GLM tests, and pass R CMD check. The standard approach uses testthat 3e patterns with skip_if_not_installed() for conditional testing of suggested packages (glmtoolbox, geepack), manual computation for cross-validation of variance estimates, and devtools::check() for R CMD check compliance.

The key technical challenges are: (1) validating GEE variance estimates without an external reference implementation like RobinCar (which doesn't support GEE), (2) testing optional dependencies without breaking CI when packages aren't installed, and (3) ensuring existing GLM tests continue to pass unchanged as a regression gate.

**Primary recommendation:** Create a single GEE-specific test file (test-gee.R) with three test sections (validation, variance, end-to-end) using skip_if_not_installed() guards, cross-validate variance against manual delta method computation, run existing test suite as regression check, and use devtools::check() to ensure R CMD check compliance.

## Standard Stack

The established tools for R package testing:

### Core Testing Framework
| Library | Version | Purpose | Why Standard |
|---------|---------|---------|--------------|
| testthat | 3.0.0+ | Unit testing framework for R packages | Used by thousands of CRAN packages, edition 3 is current standard, provides skip_if_not_installed() for conditional tests |
| devtools | Current | Package development tools including check() | Standard workflow tool, wraps R CMD check with helpful defaults, integrates with testthat |

### Supporting Tools
| Library | Version | Purpose | When to Use |
|---------|---------|---------|-------------|
| withr | Current | Test isolation and cleanup | Already in many R package dependency chains, useful for temporary state changes in tests |
| mockery | Current | Function mocking for tests | Only if needed to test package availability failures (likely not needed for this phase) |

### Validation Sources (NOT for automated testing)
| Source | Purpose | Why Not Automated |
|--------|---------|-------------------|
| Manual delta method computation | Cross-validate GEE variance estimates | No external reference implementation exists, must compute by hand |
| glmtoolbox examples | Verify object structure assumptions | Documentation examples, not programmatic test fixtures |
| geepack examples | Verify object structure assumptions | Documentation examples, not programmatic test fixtures |

**Installation:**
```bash
# Core testing already in DESCRIPTION Suggests
# testthat (>= 3.0.0) already declared
# devtools used for development workflow (not in DESCRIPTION)
```

## Architecture Patterns

### Test File Organization

beeca follows testthat convention: one test file per exported function, plus specialized files for integration testing.

**Recommended structure for GEE tests:**

```
tests/testthat/
├── test-sanitize.R         # EXISTING - GLM validation tests (14 tests)
├── test-estimate_varcov.R  # EXISTING - GLM variance tests (18 tests)
├── test-get_marginal_effect.R # EXISTING - GLM integration tests
├── test-gee.R              # NEW - GEE-specific tests (validation + variance + e2e)
└── helper-*.R              # Shared test fixtures and utilities
```

**Rationale:** A single test-gee.R file keeps all GEE tests together with shared skip_if_not_installed() guards, makes it easy to see GEE test coverage at a glance, and isolates optional dependency code.

**Alternative considered:** Separate test-gee-glmgee.R and test-gee-geeglm.R files. **Rejected because:** Both packages are always installed together in practice (both in Suggests), tests share setup code, and single file is easier to maintain.

### Conditional Testing Pattern with skip_if_not_installed()

testthat 3e provides skip_if_not_installed() for testing suggested packages:

```r
# Pattern 1: Skip entire test block if package missing
test_that("glmgee validation works", {
  skip_if_not_installed("glmtoolbox")

  library(glmtoolbox)
  # Test code using glmtoolbox
})

# Pattern 2: Shared skip guard for related tests
test_that("glmgee end-to-end pipeline", {
  skip_if_not_installed("glmtoolbox")

  library(glmtoolbox)
  # Setup data
  set.seed(123)
  n <- 100
  d <- data.frame(
    id = 1:n,
    trtp = factor(rep(c('A', 'B'), each = n/2)),
    bl_cov = rnorm(n),
    aval = rbinom(n, 1, 0.5)
  )

  # Fit GEE model
  fit <- glmgee(aval ~ trtp + bl_cov, id = id, family = binomial(link = "logit"),
                data = d, corstr = "independence")

  # Test pipeline
  result <- get_marginal_effect(fit, trt = "trtp", method = "Ge",
                                 contrast = "diff", reference = "A")

  expect_s3_class(result, "glmgee")
  expect_true(!is.null(result$marginal_est))
})
```

**Best practice from search results:** "Generally, you can assume that suggested packages are installed, and you do not need to check for them specifically, unless they are particularly difficult to install." ([Skipping tests • testthat](https://testthat.r-lib.org/articles/skipping.html))

**However:** glmtoolbox and geepack are NOT in standard R installations, so skip guards are appropriate.

**IMPORTANT:** On CRAN, testthat automatically skips tests if suggested packages are missing. Local developers see skip messages. CI should install all Suggests to run full suite.

### Manual Computation Cross-Validation

**Problem:** No external reference implementation exists for GEE variance in beeca's context. RobinCar validates Ye method but not GEE. glmtoolbox and geepack provide vcov() but we need to validate our delta method transformation.

**Solution:** Hand-compute expected variance using delta method and compare to beeca output.

**Pattern:**

```r
test_that("GEE variance matches manual delta method computation", {
  skip_if_not_installed("glmtoolbox")

  library(glmtoolbox)
  set.seed(42)
  n <- 50
  d <- data.frame(
    id = 1:n,
    trtp = factor(rep(c('0', '1'), each = n/2)),
    bl_cov = rnorm(n),
    aval = rbinom(n, 1, 0.5)
  )

  # Fit GEE model
  fit <- glmgee(aval ~ trtp + bl_cov, id = id, family = binomial(link = "logit"),
                data = d, corstr = "independence")

  # Get beeca result
  result <- fit |>
    predict_counterfactuals(trt = "trtp") |>
    average_predictions() |>
    estimate_varcov(method = "Ge", type = "robust")

  # Manual computation - delta method variance
  # Step 1: Get GEE variance-covariance matrix of coefficients
  V_beta <- vcov(fit)  # Uses glmtoolbox's robust variance by default

  # Step 2: Compute derivatives (same as existing varcov_ge logic)
  cf_pred <- result$counterfactual.predictions

  # For treatment level '0'
  X_0 <- d
  X_0$trtp <- factor('0', levels = c('0', '1'))
  X_0_mat <- model.matrix(~ trtp + bl_cov, X_0)
  pderiv_0 <- cf_pred[, '0'] * (1 - cf_pred[, '0'])
  d_0 <- (t(pderiv_0) %*% as.matrix(X_0_mat)) / nrow(X_0_mat)

  # For treatment level '1'
  X_1 <- d
  X_1$trtp <- factor('1', levels = c('0', '1'))
  X_1_mat <- model.matrix(~ trtp + bl_cov, X_1)
  pderiv_1 <- cf_pred[, '1'] * (1 - cf_pred[, '1'])
  d_1 <- (t(pderiv_1) %*% as.matrix(X_1_mat)) / nrow(X_1_mat)

  # Step 3: Delta method - V_theta = D * V_beta * D^T
  D <- rbind(d_0, d_1)
  V_manual <- D %*% V_beta %*% t(D)
  rownames(V_manual) <- colnames(V_manual) <- c('0', '1')

  # Compare to beeca result
  expect_equal(result$robust_varcov, V_manual, tolerance = 1e-10)
})
```

**Key insight:** This validates that varcov_ge_gee() correctly applies the delta method transformation to GEE's vcov(). It does NOT validate GEE's vcov() itself (we trust glmtoolbox/geepack for that).

**Confidence level:** MEDIUM - Manual computation is error-prone, but delta method is well-established and existing varcov_ge() implementation provides a reference pattern.

### Regression Testing Strategy

**Goal:** Ensure existing 308 GLM tests continue to pass without modification.

**Pattern:**

```r
# At top of test-gee.R or in a comment:
# REGRESSION CHECK: This test file adds GEE-specific tests.
# All existing GLM tests in test-sanitize.R, test-estimate_varcov.R,
# test-get_marginal_effect.R, etc. must continue to pass unchanged.
# Current GLM test count: 308 tests
# Run: devtools::test() should show PASS 308 + [new GEE tests]
```

**Verification in plan:**
1. Run devtools::test() BEFORE adding GEE tests → record baseline count (308)
2. Add GEE tests
3. Run devtools::test() AFTER → verify 308 still pass + new GEE tests pass
4. No modifications to existing test files allowed

**Best practice:** Treat existing test suite as acceptance criteria. If any existing test changes from PASS to FAIL/WARN/SKIP, the change is blocked.

### Test Coverage for GEE Validation (sanitize_model)

Tests should mirror existing GLM validation tests in test-sanitize.R but for GEE objects:

```r
# Section 1: GEE Validation Tests
# ~8-10 tests covering sanitize_model.glmgee and sanitize_model.geeglm

test_that("glmgee with correct family/link passes validation", {
  skip_if_not_installed("glmtoolbox")
  # Setup and test
})

test_that("glmgee with wrong family produces informative error", {
  skip_if_not_installed("glmtoolbox")
  # Test error message mentions "glmgee"
})

test_that("glmgee with multi-timepoint data is rejected", {
  skip_if_not_installed("glmtoolbox")
  # Create data with cluster size > 1, expect error with count
})

test_that("glmgee with treatment interactions is rejected", {
  skip_if_not_installed("glmtoolbox")
  # Test interaction check
})

test_that("glmgee validation fails gracefully when glmtoolbox not installed", {
  # Mock requireNamespace to return FALSE - SKIP if too complex
  # OR document expected behavior in comment
})

# Repeat for geeglm
test_that("geeglm with correct family/link passes validation", {
  skip_if_not_installed("geepack")
  # Setup and test
})

# ... additional geeglm validation tests
```

**Coverage target:** ~8-10 validation tests (4-5 per GEE package)

### Test Coverage for GEE Variance Estimation

Tests should cover variance routing and delta method application:

```r
# Section 2: GEE Variance Tests
# ~6-8 tests covering estimate_varcov routing and variance types

test_that("glmgee variance uses GEE vcov (not sandwich)", {
  skip_if_not_installed("glmtoolbox")
  # Verify varcov_ge_gee is called, not varcov_ge
  # Can check via attr(result$robust_varcov, "type") contains "robust" not "HC0"
})

test_that("glmgee robust variance matches manual delta method", {
  skip_if_not_installed("glmtoolbox")
  # Use pattern from Manual Computation section above
})

test_that("glmgee bias-corrected variance type works", {
  skip_if_not_installed("glmtoolbox")
  # Test type = "bias-corrected"
})

test_that("glmgee df-adjusted variance type works", {
  skip_if_not_installed("glmtoolbox")
  # Test type = "df-adjusted"
})

test_that("glmgee with invalid variance type produces helpful error", {
  skip_if_not_installed("glmtoolbox")
  # Pass type = "HC0", expect error listing valid GEE types
})

test_that("GEE with Ye method produces informative error", {
  skip_if_not_installed("glmtoolbox")
  # Test method = "Ye" rejection with clear message
})

test_that("geeglm robust variance works", {
  skip_if_not_installed("geepack")
  # geeglm only supports robust variance
})

test_that("geeglm variance matches manual delta method", {
  skip_if_not_installed("geepack")
  # Manual computation cross-validation
})
```

**Coverage target:** ~6-8 variance tests

### Test Coverage for End-to-End Pipeline

Tests should validate full get_marginal_effect workflow:

```r
# Section 3: GEE End-to-End Tests
# ~4-6 tests covering full pipeline for multiple contrast types

test_that("glmgee end-to-end with diff contrast", {
  skip_if_not_installed("glmtoolbox")
  # Full pipeline: fit → get_marginal_effect → verify output structure
})

test_that("glmgee end-to-end with or contrast", {
  skip_if_not_installed("glmtoolbox")
  # Test odds ratio contrast
})

test_that("geeglm end-to-end with diff contrast", {
  skip_if_not_installed("geepack")
  # Full pipeline
})

test_that("geeglm end-to-end with rr contrast", {
  skip_if_not_installed("geepack")
  # Test risk ratio contrast
})

test_that("GEE pipeline produces complete marginal_results ARD", {
  skip_if_not_installed("glmtoolbox")
  # Verify ARD structure matches GLM output format
})
```

**Coverage target:** ~4-6 end-to-end tests

**Total new GEE tests:** ~18-24 tests

## Don't Hand-Roll

Problems with existing solutions:

| Problem | Don't Build | Use Instead | Why |
|---------|-------------|-------------|-----|
| Test data generation with realistic variance structure | Complex simulation code in each test | Shared test fixture in helper-gee-data.R | DRY principle, consistent test data across tests, easier to debug |
| Cross-validation against external packages | Integration with glmtoolbox/geepack internal functions | Manual delta method computation | No external reference exists, manual computation is tractable and documents expected behavior |
| Mocking package availability | Complex mockery setup | Document expected behavior + skip_if_not_installed() | testthat handles package skipping automatically on CRAN, mocking adds complexity |
| R CMD check runner | Custom validation scripts | devtools::check() or R CMD check | Standard tools are well-maintained and match CRAN requirements exactly |

**Key insight:** testthat 3e and devtools provide comprehensive solutions for package testing and R CMD check. Focus effort on domain-specific validation logic (GEE variance cross-validation) rather than testing infrastructure.

## Common Pitfalls

### Pitfall 1: Relying on External Packages for Validation Without Fallback
**What goes wrong:** Tests use RobinCar for cross-validation like existing GLM tests, but RobinCar doesn't support GEE. Tests fail or skip.

**Why it happens:** Natural to follow existing pattern (test-estimate_varcov.R uses `if (robincar_available)`).

**How to avoid:** Use manual delta method computation for GEE variance validation. Document why external validation isn't available.

**Warning signs:** Test file has `skip_if_not_installed("RobinCar")` in GEE tests.

### Pitfall 2: Test Data with Actual Multi-Timepoint Structure
**What goes wrong:** Test data for validation tests accidentally has multi-timepoint structure (cluster size > 1), causing tests to fail during setup rather than testing validation logic.

**Why it happens:** GEE data naturally has repeated measures. Test data copy-pasted from GEE examples.

**How to avoid:** Single-timepoint test data has `id = 1:n` (unique ID per observation). Multi-timepoint data for error testing should be clearly labeled.

**Warning signs:** Test failures in setup code before expect_* statements.

### Pitfall 3: Forgetting to Load Package After skip_if_not_installed()
**What goes wrong:** Test has `skip_if_not_installed("glmtoolbox")` but no `library(glmtoolbox)`, causing "object 'glmgee' not found" errors.

**Why it happens:** skip_if_not_installed() checks availability but doesn't load the package.

**How to avoid:** Always pair skip_if_not_installed() with library() call:
```r
test_that("test name", {
  skip_if_not_installed("glmtoolbox")
  library(glmtoolbox)  # Required!
  # Test code
})
```

**Warning signs:** Tests fail with "object not found" when package IS installed.

### Pitfall 4: Hardcoded Expected Values Without Reproducible Seeds
**What goes wrong:** Manual computation validation uses fixed expected values (e.g., variance = 0.003706813) but test data is randomly generated without set.seed(). Tests are non-deterministic.

**Why it happens:** Following pattern from test-estimate_varcov.R which hardcodes expected values but omitting seed.

**How to avoid:** ALWAYS set.seed() before generating test data:
```r
test_that("variance matches manual computation", {
  skip_if_not_installed("glmtoolbox")
  library(glmtoolbox)

  set.seed(123)  # Required for reproducibility!
  d <- data.frame(
    id = 1:n,
    trtp = factor(rbinom(n, 1, 0.5)),
    aval = rbinom(n, 1, 0.5)
  )
  # Rest of test
})
```

**Warning signs:** Tests pass locally but fail in CI or for other developers.

### Pitfall 5: R CMD Check Failures from Undeclared Test Dependencies
**What goes wrong:** R CMD check fails with "Namespace dependency not required" because test code uses packages not in DESCRIPTION Suggests.

**Why it happens:** Test helper functions use packages for convenience (e.g., tidyr for test data manipulation).

**How to avoid:**
1. Only use packages already in Suggests within test code
2. If adding new test dependency, add to DESCRIPTION Suggests
3. Current Suggests already includes testthat, glmtoolbox, geepack - sufficient for GEE tests

**Warning signs:** R CMD check notes about undeclared dependencies during --as-cran check.

### Pitfall 6: Breaking Existing Tests by Modifying Shared Utilities
**What goes wrong:** New GEE tests need helper function, developer modifies .get_data() or sanitize_variable(), inadvertently breaking GLM tests.

**Why it happens:** Shared utilities are used across GLM and GEE code paths.

**How to avoid:**
1. Never modify existing test files (test-sanitize.R, test-estimate_varcov.R, etc.)
2. If shared utility must change, verify ALL 308 existing tests still pass
3. Prefer GEE-specific helper functions in test-gee.R over modifying shared code

**Warning signs:** devtools::test() shows fewer than 308 passing tests after adding GEE tests.

## R CMD Check Requirements

Based on [R Packages (2e) - Appendix A: R CMD check](https://r-pkgs.org/R-CMD-check.html), the key checks relevant to this phase:

### Critical Checks (Must Pass - 0 Errors, 0 Warnings)

**DESCRIPTION validation:**
- All packages in Suggests must be used conditionally (✓ already compliant - GEE tests use skip_if_not_installed())
- glmtoolbox and geepack already in Suggests with version constraints

**NAMESPACE validation:**
- S3 methods properly exported (✓ sanitize_model.glmgee and sanitize_model.geeglm already exported in Phase 5)
- No missing imports

**R code validation:**
- No syntax errors
- All dependencies declared (glmtoolbox, geepack in Suggests)
- S3 method signatures match generics (✓ sanitize_model methods match signature)

**Documentation validation:**
- All exported functions documented
- No broken cross-references
- Examples run successfully (may need \donttest{} for GEE examples if packages not installed)

**Test validation:**
- Tests run successfully
- Tests may be skipped if suggested packages not available (testthat handles this automatically)

### Acceptable Notes

**"New submission" note:** Not applicable (beeca already on CRAN)

**"Non-ASCII data" note:** May appear if trial data has non-ASCII characters. Document encoding in data documentation.

**"Undeclared indirect dependencies in Rd cross-references" note:** May appear on some CRAN flavors. Rarely requires action.

### Running R CMD Check Locally

**Recommended workflow:**

```bash
# During development
Rscript -e "devtools::check()"

# Before submission (more stringent)
Rscript -e "devtools::check(args = '--as-cran')"

# Check with all Suggests installed (full test suite)
Rscript -e "devtools::check()"  # devtools installs Suggests by default
```

**Expected output for Phase 6 success:**
```
── R CMD check results ──────────────────── beeca 0.4.0 ────
Duration: 2m 15s

0 errors ✔ | 0 warnings ✔ | 0 notes ✔
```

**If notes appear:** Evaluate each note. Common acceptable notes include initial CRAN submission, non-ASCII data with declared encoding, or indirect documentation dependencies.

## Code Examples

### Pattern 1: Shared Test Data Setup

```r
# In tests/testthat/test-gee.R
# Shared setup for multiple GEE tests
setup_gee_test_data <- function(n = 100, seed = 123) {
  set.seed(seed)
  data.frame(
    id = 1:n,
    trtp = factor(rep(c('0', '1'), each = n/2)),
    bl_cov = rnorm(n),
    aval = rbinom(n, 1, 0.5)
  )
}

test_that("glmgee validation works", {
  skip_if_not_installed("glmtoolbox")
  library(glmtoolbox)

  d <- setup_gee_test_data()
  fit <- glmgee(aval ~ trtp + bl_cov, id = id, family = binomial(link = "logit"),
                data = d, corstr = "independence")

  result <- sanitize_model(fit, "trtp")
  expect_true(result$sanitized)
})
```

### Pattern 2: Error Message Validation

```r
test_that("GEE Ye method rejection has clear error message", {
  skip_if_not_installed("glmtoolbox")
  library(glmtoolbox)

  d <- setup_gee_test_data()
  fit <- glmgee(aval ~ trtp + bl_cov, id = id, family = binomial(link = "logit"),
                data = d, corstr = "independence")

  result <- fit |>
    predict_counterfactuals(trt = "trtp") |>
    average_predictions()

  expect_error(
    estimate_varcov(result, method = "Ye"),
    "Ye's method assumes independence and is not valid for GEE models. Use method='Ge' instead.",
    fixed = TRUE
  )
})
```

### Pattern 3: Manual Delta Method Cross-Validation

```r
test_that("glmgee robust variance matches manual delta method", {
  skip_if_not_installed("glmtoolbox")
  library(glmtoolbox)

  set.seed(42)
  d <- setup_gee_test_data(n = 50, seed = 42)

  fit <- glmgee(aval ~ trtp + bl_cov, id = id, family = binomial(link = "logit"),
                data = d, corstr = "independence")

  # Get beeca result
  result <- fit |>
    predict_counterfactuals(trt = "trtp") |>
    average_predictions() |>
    estimate_varcov(method = "Ge", type = "robust")

  # Manual computation
  V_beta <- vcov(fit)  # GEE's robust variance of coefficients
  cf_pred <- result$counterfactual.predictions
  frm <- formula(fit)

  # Compute derivatives for each treatment level
  compute_derivative <- function(trt_level, data, cf_pred, formula) {
    X_i <- data
    X_i$trtp <- factor(trt_level, levels = levels(data$trtp))
    X_i_mat <- model.matrix(formula, X_i)
    pderiv_i <- cf_pred[, trt_level] * (1 - cf_pred[, trt_level])
    (t(pderiv_i) %*% as.matrix(X_i_mat)) / nrow(X_i_mat)
  }

  d_0 <- compute_derivative('0', d, cf_pred, frm)
  d_1 <- compute_derivative('1', d, cf_pred, frm)

  # Delta method: V = D * V_beta * D^T
  D <- rbind(d_0, d_1)
  V_manual <- D %*% V_beta %*% t(D)
  rownames(V_manual) <- colnames(V_manual) <- c('0', '1')

  # Compare
  expect_equal(result$robust_varcov, V_manual, tolerance = 1e-10)
})
```

### Pattern 4: Variance Type Validation

```r
test_that("glmgee with GLM-style variance type produces helpful error", {
  skip_if_not_installed("glmtoolbox")
  library(glmtoolbox)

  d <- setup_gee_test_data()
  fit <- glmgee(aval ~ trtp + bl_cov, id = id, family = binomial(link = "logit"),
                data = d, corstr = "independence")

  result <- fit |>
    predict_counterfactuals(trt = "trtp") |>
    average_predictions()

  expect_error(
    estimate_varcov(result, method = "Ge", type = "HC0"),
    'Variance type "HC0" is not supported for glmgee objects. Valid types: robust, bias-corrected, df-adjusted',
    fixed = TRUE
  )
})
```

### Pattern 5: End-to-End Pipeline Test

```r
test_that("glmgee end-to-end pipeline with diff contrast", {
  skip_if_not_installed("glmtoolbox")
  library(glmtoolbox)

  d <- setup_gee_test_data(n = 100)
  fit <- glmgee(aval ~ trtp + bl_cov, id = id, family = binomial(link = "logit"),
                data = d, corstr = "independence")

  result <- get_marginal_effect(
    fit,
    trt = "trtp",
    method = "Ge",
    type = "robust",
    contrast = "diff",
    reference = "0"
  )

  # Verify output structure
  expect_s3_class(result, "glmgee")
  expect_true(!is.null(result$marginal_est))
  expect_true(!is.null(result$marginal_se))
  expect_true(!is.null(result$robust_varcov))
  expect_true(!is.null(result$marginal_results))

  # Verify ARD structure matches GLM output
  expect_true(is.data.frame(result$marginal_results))
  expect_true("STAT" %in% names(result$marginal_results))
  expect_true("STATVAL" %in% names(result$marginal_results))

  # Verify contrast type in ARD
  contrast_rows <- result$marginal_results[result$marginal_results$STAT == "contrast", ]
  expect_equal(nrow(contrast_rows), 1)
})
```

## State of the Art

| Old Approach | Current Approach | When Changed | Impact |
|--------------|------------------|--------------|--------|
| Manual requireNamespace checks in every test | skip_if_not_installed() helper | testthat 3.0.0 (2020) | Tests automatically skip on CRAN when suggested packages unavailable |
| Separate if/else blocks with hardcoded values for cross-validation | if (package_available) { external validation } else { hardcoded values } | Current beeca pattern (test-estimate_varcov.R) | Enables validation against reference implementations when available, fallback to regression tests otherwise |
| R CMD check via command line only | devtools::check() wrapper | devtools maturity (~2015) | Integrates check into R workflow, handles temporary package installation, better output formatting |
| testthat edition 2 | testthat edition 3 | testthat 3.0.0 (2020) | Improved snapshot testing, better skip handling, clearer test organization |

**Deprecated/outdated:**
- `expect_that()` syntax: Replaced by `expect_*()` functions in testthat 3e
- `context()` function: Removed in testthat 3e, use file names for organization instead
- Manual skip logic: `if (!requireNamespace("pkg")) skip()` → use `skip_if_not_installed("pkg")`

## Open Questions

### Question 1: Should GEE tests include 3-arm examples?

**What we know:** Existing GLM tests include 3-arm scenarios (trial02_cdisc data). GEE implementation supports multiple treatment levels via S3 dispatch and loop in varcov_ge_gee().

**What's unclear:** Whether 3-arm GEE tests add meaningful coverage or are redundant given GLM 3-arm tests already exist.

**Recommendation:** Start with 2-arm tests only. Add 3-arm GEE test only if time permits or if 3-arm reveals GEE-specific issues. Rationale: GEE variance logic doesn't branch on treatment count, and 2-arm tests validate the core mechanism.

### Question 2: How much manual computation detail to include in test comments?

**What we know:** Manual delta method computation is the primary cross-validation approach. Future maintainers need to understand the computation to debug test failures.

**What's unclear:** Balance between inline comments (clutters test code) vs. external documentation (harder to find).

**Recommendation:** Include a single detailed manual computation test with extensive comments showing each step. Subsequent tests can reference this "canonical" example. Add a comment block at top of test-gee.R linking to delta method equations in Ge et al (2011) paper.

### Question 3: Should we test package availability failure mode?

**What we know:** sanitize_model.glmgee() checks requireNamespace("glmtoolbox", quietly = TRUE) and errors if FALSE. This is covered by the skip_if_not_installed() pattern in tests.

**What's unclear:** Whether to explicitly test the error message when package is missing.

**Recommendation:** Skip this test. Rationale: (1) Requires mocking requireNamespace which adds complexity, (2) testthat handles this gracefully via skips, (3) manual testing during development suffices. Focus effort on domain logic validation.

## Sources

### Primary (HIGH confidence)
- [R Packages (2e) - Testing basics](https://r-pkgs.org/testing-basics.html) - testthat best practices and organization
- [R Packages (2e) - Designing your test suite](https://r-pkgs.org/testing-design.html) - Test design patterns and philosophy
- [R Packages (2e) - R CMD check](https://r-pkgs.org/R-CMD-check.html) - Complete R CMD check requirements
- [testthat 3.3.2 Reference Manual](https://cran.r-project.org/web/packages/testthat/testthat.pdf) - skip_if_not_installed() and edition 3 features
- [Skipping tests • testthat](https://testthat.r-lib.org/articles/skipping.html) - Official guidance on skip_if_not_installed() usage
- beeca codebase test-estimate_varcov.R - Existing cross-validation pattern with RobinCar

### Secondary (MEDIUM confidence)
- [Testing with {testthat}](https://www.jumpingrivers.com/blog/r-testthat/) - Practical testthat patterns
- [glmtoolbox R Journal article](https://journal.r-project.org/articles/RJ-2023-056/) - glmgee vcov implementation details
- [Generalized Estimating Equations (GEE)](https://rlbarter.github.io/Practical-Statistics/2017/05/10/generalized-estimating-equations-gee/) - GEE variance estimation context

### Tertiary (LOW confidence)
- WebSearch results on GEE variance validation - No specific R package testing patterns found, general GEE methodology only

## Metadata

**Confidence breakdown:**
- R testthat patterns: HIGH - Official documentation and mature ecosystem
- R CMD check requirements: HIGH - Official R documentation via r-pkgs.org
- GEE cross-validation approach: MEDIUM - Manual computation is well-defined but no external reference implementation to compare against
- Test coverage targets: MEDIUM - Based on existing beeca test patterns and domain complexity

**Research date:** 2026-02-07
**Valid until:** 90 days (testthat and R CMD check are stable; GEE package APIs are mature)
