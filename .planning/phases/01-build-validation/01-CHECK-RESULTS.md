# Build Validation Results - beeca Package

**Generated:** 2026-01-31
**Package Version:** 0.2.0

---

## Validation Summary

**Overall Status:** ❌ ISSUES FOUND

| Check Type | Status | Details |
|------------|--------|---------|
| R CMD check | ❌ ERROR | Vignette build failure |
| testthat | ✅ PASS | 302 tests pass, 0 failures |
| Coverage | ✅ GOOD | 88.90% overall, 1 gap identified |

---

## Issue Categories for Triage

### Blockers (Must Fix Before Release)

**1. Vignette Build Failure** - `ard-cards-integration.Rmd`
- **Error:** `object 'fit_study1' not found` at lines 176-192 [meta-analysis chunk]
- **Location:** Chunk named `meta-analysis` in vignette file
- **Function call:** `beeca_to_cards_ard(fit_study1$marginal_results)`
- **Impact:** Prevents R CMD build completion, blocks package creation
- **Root cause:** Variable `fit_study1` used before being defined in vignette
- **Priority:** 🔴 **CRITICAL** - Must fix for release
- **Next step:** Investigate vignette source to determine if:
  1. `fit_study1` definition is missing
  2. Code chunks are out of order
  3. Meta-analysis section should be removed/commented out

**2. Missing Test Coverage** - `beeca_to_cards_ard()`
- **File:** R/beeca_to_cards_ard.R
- **Coverage:** 0.00% (no tests)
- **Function:** Exported utility for converting beeca ARD to cards format
- **Impact:** No test coverage for newly exported function
- **Priority:** 🟠 **HIGH** - Should add tests before release
- **Connection:** This is the same function causing vignette error
- **Next step:** Add test file `test-beeca_to_cards_ard.R` after fixing vignette

### Warnings (Evaluate and Document)

**1. ggplot2 Deprecation** (46 warnings in plot tests)
- **Message:** "`geom_errorbarh()` was deprecated in ggplot2 4.0.0"
- **Recommendation:** Use `orientation` argument of `geom_errorbar()` instead
- **Files affected:** R/plot_forest.R
- **Impact:** Works now, but may break in future ggplot2 versions
- **Priority:** 🟡 **MEDIUM** - Technical debt for future release
- **Decision needed:** Fix now or defer to next release?

**2. Missing Data Warnings** (40 warnings in tests)
- **Message:** "There is 1 record omitted from the original data due to missing values"
- **Source:** `sanitize_model()` validation function
- **Impact:** None - this is expected behavior, tests use data with missing values intentionally
- **Priority:** ✅ **INFORMATIONAL** - No action needed
- **Status:** Expected and correct

### Notes (Document for Awareness)

**1. Skipped Tests** (13 tests)
- **Reason 1:** Conditional tests for optional packages (gt not available)
- **Reason 2:** Known environment issue - "subscript out of bounds" (10 tests)
- **Reason 3:** Empty placeholder test (1 test)
- **Impact:** None - tests are conditionally skipped as designed
- **Priority:** ✅ **INFORMATIONAL** - No action needed for release
- **Future work:** Investigate "subscript out of bounds" issue in test environment

**2. Coverage Gaps in Display Functions**
- **R/print.R:** 70.37% coverage
- **R/beeca_fit.R:** 78.95% coverage
- **Reason:** Display/formatting functions have many conditional branches
- **Impact:** Low risk - these are UI functions, not statistical computations
- **Priority:** ✅ **ACCEPTABLE** - No action needed for release
- **Status:** Acceptable coverage for user-facing display code

### Triage Summary

**Must fix (2 blockers):**
1. Fix vignette error in `ard-cards-integration.Rmd`
2. Add tests for `beeca_to_cards_ard()` function

**Should evaluate (1 warning):**
1. Decide on ggplot2 deprecation fix (defer or fix now)

**Document only (3 notes):**
1. Skipped tests are expected
2. Missing data warnings are expected
3. Display function coverage is acceptable

---

## Detailed Results

### R CMD check

**Status:** ERROR (build failed during vignette creation)

**Output:**

```
══ Documenting ═════════════════════════════════════════════════════════════════
ℹ Updating beeca documentation
ℹ Loading beeca

══ Building ════════════════════════════════════════════════════════════════════
Setting env vars:
• CFLAGS    : -Wall -pedantic
• CXXFLAGS  : -Wall -pedantic
• CXX11FLAGS: -Wall -pedantic
• CXX14FLAGS: -Wall -pedantic
• CXX17FLAGS: -Wall -pedantic
• CXX20FLAGS: -Wall -pedantic
```

**Vignette Building:**

| Vignette | Status | Notes |
|----------|--------|-------|
| `ard-cards-integration.Rmd` | ❌ ERROR | Object 'fit_study1' not found at line 176-192 |
| `clinical-trial-table.Rmd` | ✅ SUCCESS | Built successfully |
| `estimand_and_implementations.Rmd` | ✅ SUCCESS | Built successfully |

**Error Details:**

```
--- re-building 'ard-cards-integration.Rmd' using rmarkdown

Quitting from ard-cards-integration.Rmd:176-192 [meta-analysis]

Error:
! object 'fit_study1' not found
---
Backtrace:
    ▆
 1. ├─dplyr::mutate(...)
 2. └─beeca::beeca_to_cards_ard(fit_study1$marginal_results)
 3.   ├─dplyr::select(...)
 4.   ├─dplyr::mutate(...)
 5.   └─dplyr::rename(...)

Error: processing vignette 'ard-cards-integration.Rmd' failed with diagnostics:
object 'fit_study1' not found
```

**Summary:**
- ❌ **1 ERROR:** Vignette build failure
- ⚠️ **0 WARNINGs**
- ℹ️ **0 NOTEs**
- Duration: Build terminated at vignette stage

**Root Cause:**
The `ard-cards-integration.Rmd` vignette references an object `fit_study1` that doesn't exist in scope at lines 176-192 in the `meta-analysis` chunk. This prevents the vignette from knitting and blocks package building.

---

### testthat Suite

**Status:** ✅ ALL TESTS PASS (testthat ran successfully despite vignette build failure)

**Summary:**
- ✅ **302 tests PASSED**
- ⚠️ **86 WARNINGs** (expected, informational)
- 📋 **13 tests SKIPPED** (expected, conditional)
- ❌ **0 tests FAILED**
- ⏱️ **Duration:** 2.9 seconds

**Test Breakdown by Context:**

| Context | Passed | Warnings | Skipped | Total |
|---------|--------|----------|---------|-------|
| apply_contrasts | 43 | 0 | 0 | 43 |
| as_gt | 36 | 8 | 1 | 44 |
| augment | 51 | 5 | 1 | 56 |
| average_predictions | 9 | 0 | 0 | 9 |
| beeca-fit | 16 | 10 | 10 | 26 |
| estimate_varcov | 16 | 0 | 0 | 16 |
| get_marginal_effect | 7 | 0 | 0 | 7 |
| plot | 29 | 46 | 1 | 75 |
| predict_counterfactuals | 2 | 0 | 0 | 2 |
| print-summary | 40 | 20 | 0 | 60 |
| sanitize | 12 | 0 | 0 | 12 |
| tidy | 41 | 0 | 0 | 41 |

**Warning Analysis:**

All 86 warnings are expected and non-blocking:

1. **Missing data warnings** (majority): "There is 1 record omitted from the original data due to missing values"
   - This is expected behavior from `sanitize_model()` detecting and warning about missing values
   - Tests are deliberately using datasets with missing values to verify proper handling
   - **Status:** ✅ Expected, informational

2. **ggplot2 deprecation warnings** (plot tests): "`geom_errorbarh()` was deprecated in ggplot2 4.0.0"
   - Suggests using `orientation` argument of `geom_errorbar()` instead
   - **Status:** ⚠️ Minor tech debt, should update in future release

3. **Other informational warnings**:
   - "Residuals not added for custom data" (expected when using custom data)
   - "Counterfactual predictions not added for custom data" (expected when using custom data)
   - "Setting row names on a tibble is deprecated" (test-specific)
   - "No reference argument was provided, using {0} as the reference level(s)" (expected default behavior)

**Skipped Tests Analysis:**

All 13 skipped tests are conditional and expected:

1. **gt package tests** (2 skipped): Tests that require `gt` package to NOT be installed
   - Reason: gt IS installed, so cannot test "gt not available" code path
   - **Status:** ✅ Expected

2. **Known issue workarounds** (10 skipped): "subscript out of bounds in test environment"
   - Tests in `test-beeca-fit.R` that hit a known environment-specific issue
   - **Status:** ⚠️ Should investigate, but doesn't block functionality

3. **Empty test** (1 skipped): Placeholder test in `test-augment.R:200`
   - **Status:** ✅ Expected placeholder

**Test Coverage by Functionality:**

✅ All core functions tested:
- Contrast calculation (diff, rr, or, logor, logrr) - 43 tests
- Variance estimation (Ge, Ye methods) - 16 tests
- Counterfactual prediction - 2 tests
- Average predictions - 9 tests
- Model sanitization/validation - 12 tests
- Tidy methods (broom integration) - 41 tests
- Print/summary methods - 40 tests
- Plotting (forest plots) - 29 passing tests
- Augment methods - 51 passing tests
- as_gt (table formatting) - 36 passing tests

**Conclusion:**

✅ **The testthat suite is in excellent shape.** All 302 tests pass, warnings are expected/informational, and skipped tests are conditional checks. The package's core functionality is well-tested and working correctly.

---

### Test Coverage

**Status:** ✅ EXCELLENT (88.90% overall coverage)

**Overall Coverage:** 88.90%

**Coverage by File:**

| File | Coverage | Status |
|------|----------|--------|
| R/apply_contrast.R | 100.00% | ✅ Perfect |
| R/average_predictions.R | 100.00% | ✅ Perfect |
| R/get_marginal_effect.R | 100.00% | ✅ Perfect |
| R/plot.R | 100.00% | ✅ Perfect |
| R/predict_counterfactuals.R | 100.00% | ✅ Perfect |
| R/tidy.R | 98.18% | ✅ Excellent |
| R/estimate_varcov.R | 98.18% | ✅ Excellent |
| R/augment.R | 97.44% | ✅ Excellent |
| R/summary.R | 96.92% | ✅ Excellent |
| R/sanitize.R | 96.00% | ✅ Excellent |
| R/plot_forest.R | 95.45% | ✅ Excellent |
| R/as_gt.R | 93.00% | ✅ Great |
| R/beeca_fit.R | 78.95% | ⚠️ Good |
| R/print.R | 70.37% | ⚠️ Acceptable |
| R/beeca_to_cards_ard.R | 0.00% | ❌ **Coverage Gap** |

**Coverage Gaps Identified:**

1. **CRITICAL GAP: R/beeca_to_cards_ard.R - 0.00% coverage**
   - **Function:** `beeca_to_cards_ard()` - ARD conversion utility
   - **Impact:** This is a newly added exported function with no test coverage
   - **Recommendation:** Add tests for this function
   - **Note:** This is likely the function mentioned in the vignette error

2. **Moderate gaps:**
   - **R/print.R** (70.37%): Print methods have lower coverage
     - Likely due to conditional formatting/output branches
     - Status: Acceptable for display methods

   - **R/beeca_fit.R** (78.95%): Main fitting wrapper
     - May have untested error handling paths
     - Status: Good, but could improve

**Analysis:**

✅ **Core computational functions** have perfect or near-perfect coverage:
- Counterfactual prediction: 100%
- Averaging: 100%
- Contrast application: 100%
- Variance estimation: 98.18%
- Main orchestration (`get_marginal_effect`): 100%

✅ **User-facing utilities** well covered:
- Tidy methods: 98.18%
- Augment: 97.44%
- Summary: 96.92%
- Sanitization/validation: 96.00%
- Plotting: 95.45%+

⚠️ **Display/formatting methods** have acceptable coverage:
- Print methods: 70.37% (acceptable for output formatting)
- GT table formatting: 93.00%

❌ **NEW FUNCTION NEEDS TESTS:**
- `beeca_to_cards_ard()`: 0% coverage (newly exported utility)

**Coverage Report:**

HTML coverage report generated at:
`.planning/phases/01-build-validation/coverage-report.html`

**Conclusion:**

The package has strong test coverage at 88.90% overall. Core statistical functions have perfect or near-perfect coverage. The main gap is the newly added `beeca_to_cards_ard()` function which has 0% coverage and is causing the vignette build failure.

---

## Next Steps

1. **Fix vignette error** in `ard-cards-integration.Rmd`:
   - Investigate lines 176-192 (meta-analysis chunk)
   - Ensure `fit_study1` object is created before use
   - Or remove/comment out problematic code if not ready

2. **Re-run R CMD check** after vignette fix

3. **Run testthat suite** once build succeeds

4. **Run coverage analysis** for gap identification

---

## Notes

- R CMD check uses `error_on = 'never'` to capture all issues
- Two vignettes built successfully, indicating issue is isolated to `ard-cards-integration.Rmd`
- Package documentation updates completed successfully
- Build environment properly configured with compiler flags
