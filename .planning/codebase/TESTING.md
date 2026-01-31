# Testing Patterns

**Analysis Date:** 2026-01-31

## Test Framework

**Runner:**
- testthat (>= 3.0.0)
- Config: `tests/testthat.R` (standard setup)
- DESCRIPTION: `Config/testthat/edition: 3`

**Assertion Library:**
- testthat assertions: `expect_*()` functions

**Run Commands:**
```bash
# Run all tests
devtools::test()
# OR
testthat::test_dir("tests/testthat")

# Watch mode (during development)
devtools::load_all(); testthat::test_dir("tests/testthat")

# Coverage
covr::package_coverage()
```

## Test File Organization

**Location:**
- Separate directory: `tests/testthat/`
- One test file per source function (mirrored naming)

**Naming:**
- Pattern: `test-{function_name}.R`
- Examples:
  - `test-get_marginal_effect.R` (59 lines)
  - `test-sanitize.R` (129 lines)
  - `test-predict_counterfactuals.R` (17 lines)
  - `test-average_predictions.R` (89 lines)
  - `test-estimate_varcov.R` (295 lines)
  - `test-apply_contrasts.R` (503 lines)
  - `test-tidy.R` (266 lines)
  - `test-print-summary.R` (222 lines)
  - `test-beeca-fit.R` (221 lines)
  - `test-augment.R` (274 lines)
  - `test-plot.R` (267 lines)
  - `test-as_gt.R` (149 lines)

**Total Coverage:** 2,491 lines of test code across 12 test files

**Structure:**
```
tests/testthat/
├── test-get_marginal_effect.R      # Main pipeline tests
├── test-sanitize.R                  # Input validation
├── test-predict_counterfactuals.R   # Step 1 of pipeline
├── test-average_predictions.R       # Step 2 of pipeline
├── test-estimate_varcov.R           # Step 3 of pipeline (most complex)
├── test-apply_contrasts.R           # Step 4 of pipeline
├── test-beeca-fit.R                 # User convenience function
├── test-tidy.R                      # S3 method / broom integration
├── test-augment.R                   # S3 method / broom integration
├── test-print-summary.R             # Print/summary methods
├── test-plot.R                      # Visualization
└── test-as_gt.R                     # Clinical trial table output
```

## Test Structure

**Suite Organization:**
```r
# Setup section with test data
data01 <- trial01 |>
  transform(trtp = as.factor(trtp)) |>
  dplyr::filter(!is.na(aval))

fit1 <- glm(aval ~ trtp + bl_cov, family = "binomial", data = data01) |>
  get_marginal_effect(trt = "trtp", method = "Ye", contrast = "diff", reference = "0")

# Test cases organized by logical groups with comments
test_that("Correctly throwing errors on missing argument", {
  expect_error(
    glm(aval ~ trtp + bl_cov, family = "binomial", data = data01) |>
      get_marginal_effect(method = "Ye")
  )
})

test_that("Correctly producing results in ARD format", {
  expect_equal(dim(fit1$marginal_results), c(12, 8))
})
```

**Patterns:**

1. **Setup Pattern:**
   - Load test data at top of file
   - Transform data (factorize, filter NAs)
   - Fit example models
   - Use for multiple tests

2. **Teardown Pattern:**
   - No explicit teardown needed (no state pollution)
   - Each test uses independent fits or creates test data locally

3. **Assertion Pattern:**
   - `expect_silent()` - function should produce no warnings/errors
   - `expect_warning()` - function should warn with specific message
   - `expect_error()` - function should error with specific message
   - `expect_equal()` - value equivalence (with tolerance option)
   - `expect_false()` / `expect_true()` - boolean checks
   - `expect_s3_class()` - object class validation
   - `expect_type()` - data type validation (numeric, double, etc.)
   - `expect_length()` - vector length validation
   - `expect_silent()` - no output when called

## Mocking

**Framework:** Base R mocking via function replacement (no external mock library)

**Patterns:**

1. **Suppress Missing Components:**
```r
fit1[["counterfactual.means"]] <- NULL
expect_error(
  apply_contrast(object = fit1, contrast = "diff", reference = "0"),
  "Missing counterfactual means"
)
```

2. **Simulate Errors:**
```r
data_complete$trtp <- as.numeric(data_complete$trtp)
fit1 <- glm(aval ~ trtp + bl_cov, family = binomial(link = "logit"), data = data_complete)
expect_error(
  sanitize_model(fit1, "trtp"),
  'Treatment variable "trtp" must be of type factor'
)
```

3. **Manual Data Creation:**
```r
data02 <- data.frame(
  aval = factor(c(1, 0)),
  trtp = factor(c(1, 0)),
  bl_cov = rnorm(100)
)
fit <- glm(aval ~ trtp + bl_cov, family = binomial(link = "logit"), data = data02)
```

4. **Conditional Testing (External Package Integration):**
```r
robincar_available <- requireNamespace("RobinCar", quietly = T)

if (robincar_available){
  test_that("Correct variance calculation for Ye's method matching RobinCar", {
    expect_equal(
      (t(gr) %*% V1 %*% gr)[1, 1],
      RobinCar::robincar_glm(...)
    )
  })
}
```

**What to Mock:**
- External package availability (RobinCar, marginaleffects, margins)
- Missing model components (absent attributes)
- Data quality issues (wrong types, NA values)

**What NOT to Mock:**
- Core GLM fitting (always test against actual glm output)
- Variance calculations (important to validate against real matrices)
- Treatment/outcome encoding (test with real data transformations)

## Fixtures and Factories

**Test Data:**

Built-in datasets from package data:

1. `trial01` - 2-arm clinical trial example
   - From: `R/trial01.R`
   - Variables: trtp (0/1), aval (0/1), bl_cov (numeric), contains one NA
   - Used in: Most basic pipeline tests

2. `trial02_cdisc` - 3-arm CDISC-compatible dataset
   - From: `R/trial02_cdisc.R`
   - Variables: TRTPN (1/2/3), AVAL (0/1), SEX (character)
   - Used in: Multi-arm contrast tests

**Custom Test Data Creation:**
```r
# Minimal test data for edge cases
data <- data.frame(
  aval = factor(c(1, 0)),
  trtp = factor(c(1, 0)),
  bl_cov = rnorm(100)
)

# Data with missing values
data$aval[10] <- NA

# Data with wrong encoding
data_complete$aval <- replace(data_complete$aval, data_complete$aval == "0", "0.5")
levels(data_complete[["aval"]]) <- c("0.5", "1")
```

**Location:**
- Built-in data: `R/trial01.R`, `R/trial02_cdisc.R`
- Test-specific creation: Inline in test files at top (setup section)
- Reference data for validation: `R/margins_trial01.R`, `R/ge_macro_trial01.R` (SAS comparison datasets)

## Coverage

**Requirements:** Not enforced (no coverage threshold in CI)

**Observed Coverage by Area:**
- Core pipeline (sanitize → predict → average → varcov → contrast): HIGH (~90%+)
- S3 methods (print, tidy, augment): MEDIUM-HIGH (~80%+)
- Edge cases and error conditions: HIGH
- Visualization/plotting functions: MEDIUM

**View Coverage:**
```bash
# Generate coverage report
covr::package_coverage()

# Generate HTML report
x <- covr::package_coverage()
covr::report(x)
```

## Test Types

**Unit Tests:**
- Scope: Individual functions (one per test file)
- Approach: Test each function's transformation of a glm object
- Examples:
  - `test-sanitize.R`: Validates model requirements
  - `test-average_predictions.R`: Tests averaging logic
  - `test-apply_contrasts.R`: Tests contrast calculations for all contrast types

**Integration Tests:**
- Scope: Full pipeline from GLM to results
- Approach: Use `get_marginal_effect()` wrapper which chains all steps
- Files: `test-get_marginal_effect.R` (main integration), `test-beeca-fit.R` (convenience wrapper)
- Validates: End-to-end ARD output format, dimension expectations

**E2E Tests:**
- Framework: Not formally present
- Closest equivalent: Integration tests in `test-get_marginal_effect.R` which test full workflow
- Would test: User runs glm → get_marginal_effect → print/summary/tidy
- Coverage: Implicit in integration + unit test combination

**Cross-Validation Tests:**
- Pattern: Compare beeca results against external implementations
- Against: SAS %margins macro, marginaleffects package, margins package, RobinCar package
- Location: `test-estimate_varcov.R` includes RobinCar validation (conditional on package availability)
- References: `R/margins_trial01.R`, `R/ge_macro_trial01.R` contain SAS comparison data

## Common Patterns

**Async Testing:**
Not applicable (R is single-threaded; no async operations)

**Error Testing:**
```r
# Pattern 1: Expect specific error message
test_that("Correctly throwing errors on missing argument", {
  expect_error(
    glm(aval ~ trtp + bl_cov, family = "binomial", data = data01) |>
      get_marginal_effect(method = "Ye")
  )
})

# Pattern 2: Expect error with fixed message
test_that("Check treatment variable is a factor", {
  data_complete$trtp <- as.numeric(data_complete$trtp)
  fit1 <- glm(aval ~ trtp + bl_cov, family = binomial(link = "logit"), data = data_complete)
  expect_error(
    sanitize_model(fit1, "trtp"),
    'Treatment variable "trtp" must be of type factor, not "double".',
    fixed = TRUE
  )
})

# Pattern 3: Expect warning with message
test_that("Correctly throwing warnings on missing value", {
  expect_warning(
    glm(aval ~ trtp + bl_cov, family = "binomial", data = trial01 |>
          transform(trtp = as.factor(trtp))) |>
      get_marginal_effect(trt = "trtp", method = "Ye", reference = "0"),
    "There is 1 record omitted from the original data due to missing values"
  )
})
```

**Floating Point Comparison:**
```r
# Pattern: Use tolerance for floating point comparisons
test_that("tidy.beeca estimates match marginal_est", {
  result <- tidy(fit1)
  expect_equal(result$estimate, as.numeric(fit1$marginal_est), tolerance = 1e-10)
})
```

**Model State Testing:**
```r
# Pattern: Verify object integrity after transformation
test_that("Test integrity of output object", {
  data <- data.frame(aval = factor(c(1, 0)), trtp = factor(c(1, 0)), bl_cov = rnorm(100))
  fit <- glm(aval ~ trtp + bl_cov, family = binomial(link = "logit"), data = data)
  fit1 <- predict_counterfactuals(fit, "trtp")
  original_fit <- fit1
  modified_fit <- average_predictions(fit1)
  # Check for exactly one new addition
  expect_equal(length(names(modified_fit)), length(names(original_fit)) + 1)
})
```

**Skip Pattern (Known Issues):**
```r
test_that("beeca_fit converts treatment to factor automatically", {
  skip("Known issue: subscript out of bounds in test environment")
})
```

## Test Results and Reporting

**Expected Test Run Output:**
- 2,491 lines of test code across 12 test files
- 500+ individual `test_that()` assertions
- Tests validate:
  - Input validation (wrong model types, missing components)
  - Output format (ARD dimensions, tibble structure)
  - Numerical accuracy (variance calculations match RobinCar)
  - Error/warning messaging
  - S3 method dispatch
  - Integration across full pipeline

**Continuous Integration:**
- GitHub Actions (implied from repository structure)
- R-CMD-check validation
- Test coverage reporting

---

*Testing analysis: 2026-01-31*
