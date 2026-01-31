# Codebase Structure

**Analysis Date:** 2026-01-31

## Directory Layout

```
beeca/
├── R/                          # Source code (23 .R files)
│   ├── Core Pipeline:
│   │   ├── get_marginal_effect.R       # Main wrapper orchestrating full pipeline
│   │   ├── predict_counterfactuals.R   # Generate potential outcomes
│   │   ├── average_predictions.R       # Collapse to arm means
│   │   ├── estimate_varcov.R           # Robust variance estimation (Ge, Ye)
│   │   ├── apply_contrast.R            # Calculate treatment effects with contrasts
│   │   └── sanitize.R                  # Input validation (S3 generic)
│   │
│   ├── User Convenience:
│   │   ├── beeca_fit.R                 # One-function pipeline wrapper
│   │   └── beeca_to_cards_ard.R        # ARD → cards package format
│   │
│   ├── Output Methods (S3 dispatch):
│   │   ├── print.R                     # Concise summary
│   │   ├── summary.R                   # Detailed report
│   │   ├── tidy.R                      # Broom-compatible extraction
│   │   ├── augment.R                   # Add predictions to original data
│   │   ├── plot.R                      # Forest plot
│   │   └── as_gt.R                     # gt table formatting
│   │
│   ├── Data & Documentation:
│   │   ├── trial01.R                   # 2-arm trial dataset
│   │   ├── trial02_cdisc.R             # 3-arm trial (CDISC format)
│   │   ├── margins_trial01.R           # SAS margins macro results (validation)
│   │   ├── ge_macro_trial01.R          # SAS Ge et al. macro results
│   │   ├── reexports.R                 # Re-export generics from other packages
│   │   ├── beeca-package.R             # Package metadata
│   │   └── plot_forest.R               # Internal helper for forest plots
│   │
│   └── Summary tables:
│       └── summary-related helpers     # (split across summary.R, as_gt.R)
│
├── tests/testthat/                     # Test suite (12 test files, 80+ tests)
│   ├── test-sanitize.R                 # Input validation (14 tests)
│   ├── test-predict_counterfactuals.R  # Counterfactual generation
│   ├── test-average_predictions.R      # Averaging step (9 tests)
│   ├── test-estimate_varcov.R          # Variance estimation (18 tests, Ge/Ye/strata)
│   ├── test-apply_contrasts.R          # Contrasts (28+ tests, all types)
│   ├── test-get_marginal_effect.R      # Integration tests
│   ├── test-beeca-fit.R                # beeca_fit() convenience function
│   ├── test-print-summary.R            # Output methods
│   ├── test-tidy.R                     # broom compatibility
│   ├── test-augment.R                  # augment() method
│   ├── test-plot.R                     # Forest plots
│   └── test-as_gt.R                    # gt tables
│
├── data/                               # Serialized example data
│   ├── trial01.rda                     # Loaded by data(trial01)
│   ├── trial02_cdisc.rda               # Loaded by data(trial02_cdisc)
│   ├── margins_trial01.rda             # Validation comparison
│   └── ge_macro_trial01.rda            # Validation comparison
│
├── data-raw/                           # Data generation scripts (not in package)
│   └── [preprocessing code]
│
├── man/                                # Generated roxygen2 documentation
│   └── [*.Rd files, auto-generated]
│
├── vignettes/                          # User guides
│   ├── estimand_and_implementations.Rmd  # Core methodology & Ge vs Ye
│   ├── clinical-trial-table.Rmd          # Reporting tables example
│   └── ard-cards-integration.Rmd         # cards package integration
│
├── inst/                               # Package data
│   ├── extdata/                        # External data files
│   └── sasdoc/                         # SAS macro documentation
│
├── DESCRIPTION                         # Package metadata
├── NAMESPACE                           # Export/import declarations
├── NEWS.md                             # Version history
├── README.md                           # User introduction
├── LICENSE.md                          # LGPL v3 license
├── beeca.Rproj                         # RStudio project file
├── _pkgdown.yml                        # Website build config
├── .Rbuildignore                       # Build exclusions
└── .gitignore                          # Git exclusions
```

## Directory Purposes

**R/:**
- Purpose: All source code; functions exported and documented via roxygen2
- Contains: 23 .R files organized by function: core pipeline, convenience wrappers, S3 methods, data definitions
- Key files: `get_marginal_effect.R` (entry point), `estimate_varcov.R` (largest, 316 lines, Ge + Ye implementations), `apply_contrast.R` (contrast functions + gradients)
- Compiled: By roxygen2 into `man/` .Rd files

**tests/testthat/:**
- Purpose: Test suite using testthat edition 3
- Contains: 12 test files mirroring R/ structure (one per exported function or feature)
- Run: `devtools::test()` or `testthat::test_dir()`
- Coverage: 80+ test cases covering unit, integration, edge cases, cross-validation vs SAS/RobinCar

**data/:**
- Purpose: Serialized example datasets for examples and tests
- Contains: trial01 (2-arm, 200 obs), trial02_cdisc (3-arm, CDISC format), validation datasets
- Loaded via: `data(trial01)` in R session or automatic in tests
- Not committed as source: Generated from data-raw/ and stored as .rda

**data-raw/:**
- Purpose: Data preprocessing scripts (not in built package)
- Generated from external sources or manually crafted for examples
- Regenerate: Run scripts, serialize to data/, update .gitignore to exclude

**man/:**
- Purpose: Auto-generated roxygen2 documentation
- Files: One .Rd per exported function/method
- Never edit manually: Generated from roxygen comments in R/*.R files
- Regenerate: `devtools::document()` or `roxygen2::roxygenise()`

**vignettes/:**
- Purpose: User-facing guides with examples and narrative
- Contents:
  - `estimand_and_implementations.Rmd`: Explains Ge vs Ye methods, when to use each
  - `clinical-trial-table.Rmd`: Shows how to create reportable tables from results
  - `ard-cards-integration.Rmd`: Bridges beeca ARD to cards package for reporting
- Format: Rmd with knitr chunks; renders to HTML via `devtools::build_vignettes()`
- User access: `vignette("estimand_and_implementations")` in R session

**inst/extdata/, inst/sasdoc/:**
- Purpose: Ancillary package data (SAS macro docs, validation reference files)
- Not typical: Usually for external data; here mainly documentation

## Key File Locations

**Entry Points:**

- `R/get_marginal_effect.R`: Main expert-level function; orchestrates pipeline; returns beeca object with ARD
- `R/beeca_fit.R`: High-level convenience wrapper; builds formula, fits model, calls get_marginal_effect(), handles messaging
- `tests/testthat/test-get_marginal_effect.R`: Integration tests; 2-arm and 3-arm examples showing end-to-end usage

**Configuration:**

- `DESCRIPTION`: Package version (0.3.0), authors, dependencies (dplyr, sandwich, rlang, generics, lifecycle, stats)
- `NAMESPACE`: Export list (25 exports, S3 methods for 5 classes, importFrom statements)
- `_pkgdown.yml`: Website build (references, vignettes)
- `.Rbuildignore`: Excludes development files (vignettes source, tests, README)

**Core Logic:**

- `R/sanitize.R`: Input validation; S3 generic `sanitize_model()` for glm class; checks family, link, treatment factor, response coding, convergence, full rank
- `R/predict_counterfactuals.R`: Clone data per treatment level, predict; store in tibble with labels
- `R/average_predictions.R`: colMeans() across counterfactuals
- `R/estimate_varcov.R`: Ge method (sandwich + delta) and Ye method (variance decomposition ± strata adjustment); 316 lines
- `R/apply_contrast.R`: Contrast function dispatch (diff, rr, or, logrr, logor); gradient helpers for delta method

**Testing:**

- `tests/testthat/test-sanitize.R`: 14 tests for input validation (family/link, treatment factor, response coding, etc.)
- `tests/testthat/test-estimate_varcov.R`: 18 tests covering Ge (HC0/HC1/etc), Ye, stratified Ye, symmetry
- `tests/testthat/test-apply_contrasts.R`: 28+ tests for all 5 contrast types and reference level combinations
- `tests/testthat/test-get_marginal_effect.R`: Integration (ARD shape, 2-arm + 3-arm)

**Output Methods:**

- `R/print.R`, `R/summary.R`: User-friendly console output
- `R/tidy.R`: broom-compatible tibble extraction (for ggplot, other tools)
- `R/augment.R`: Original data + fitted + counterfactuals (individual-level predictions)
- `R/plot.R`, `R/plot_forest.R`: Forest plot
- `R/as_gt.R`: gt table (HTML/LaTeX) formatting

**Example Data:**

- `R/trial01.R`: Definition/description of trial01 (200 obs, aval = binary outcome, trtp = factor treatment, bl_cov = baseline covariate)
- `R/trial02_cdisc.R`: CDISC-style dataset (AVAL, TRTPN, SEX, etc.)
- `data/trial01.rda`, `data/trial02_cdisc.rda`: Serialized; loaded automatically in examples/tests

## Naming Conventions

**Files:**

- Pattern: Lower case with underscore separators (e.g., `get_marginal_effect.R`, `test-apply_contrasts.R`)
- Tests: Prefix `test-` followed by function/feature name (e.g., `test-estimate_varcov.R`)
- Data files: Name matches exported object (e.g., `trial01.R` defines `trial01` dataset, serialized as `trial01.rda`)
- Excluded: Uppercase, camelCase

**Functions:**

- Pattern: `verb_noun` in snake_case (e.g., `predict_counterfactuals()`, `estimate_varcov()`, `apply_contrast()`)
- Abbreviated helpers: `.get_data()`, `.assert_sanitized()` (leading dot indicates internal, not exported)
- S3 methods: `method.class` format (e.g., `print.beeca()`, `tidy.beeca()`)
- Contrast functions: Named by contrast type without verb (e.g., `diff()`, `rr()`, `or()`) with helper suffixes (`_str`, `grad_`)

**Variables:**

- Pattern: Snake case (e.g., `counterfactual.predictions`, `marginal_est`, `robust_varcov`)
- Dots in object components: `glm$counterfactual.means`, `fit$marginal_results` (align with statistics convention)
- Matrix/vector names: Treatment level names passed through (e.g., `names(counterfactual.means) <- c("0", "1")`)

**Parameters:**

- Pattern: Short, descriptive (e.g., `trt` = treatment variable name, `strata` = stratification vars)
- Consistency: Same parameter names across related functions (e.g., `trt`, `method`, `contrast`, `reference` used in get_marginal_effect, beeca_fit, apply_contrast)

**Classes & Methods:**

- S3 class: `beeca` (added to glm class vector, not a new class)
- Methods: Registered via S3method() in NAMESPACE
- Generic dispatch: `print(x)`, `summary(x)`, `tidy(x)`, `augment(x)`, `plot(x)`, `as_gt(x)` automatically call beeca method if present

## Where to Add New Code

**New Feature (full pipeline extension):**

1. **Primary code:** `R/new_feature.R` with exported function
2. **Tests:** `tests/testthat/test-new_feature.R` with comprehensive coverage
3. **Documentation:** roxygen comments in function definition (rendered to `man/new_feature.Rd`)
4. **Export:** Declare in roxygen `@export` tag (auto-updates NAMESPACE)

Example: To add a new contrast method (e.g., "log-log-diff"):
- Create in `R/apply_contrast.R`: `loglogdiff()`, `loglogdiff_str()`, `grad_loglogdiff()`
- Add to `match.arg(contrast)` list in function signature
- Add tests in `tests/testthat/test-apply_contrasts.R` for new contrast
- Add to roxygen `@param contrast` documentation

**New Component/Module (new user entry point):**

1. **Implementation:** Create `R/new_module.R` with main exported function + internal helpers
2. **Tests:** Create `tests/testthat/test-new_module.R`
3. **Documentation:** roxygen `@export`, `@examples`, `@seealso` cross-links
4. **Integration:** If used by existing pipeline, update those functions to call new_module

Example: To add a sensitivity analysis wrapper:
- Create `R/sensitivity_analysis.R` exporting `beeca_sensitivity()`
- Takes beeca object or raw fit + parameters
- Returns tibble of results across scenarios
- Tests in `tests/testthat/test-sensitivity_analysis.R`
- Link from `get_marginal_effect()` @seealso

**Utilities (shared helpers):**

- Shared helpers: `R/sanitize.R` (already houses validation utilities)
- Or create `R/utils.R` if multiple functions
- Pattern: Prefix internal functions with `.` (e.g., `.get_data()`, `.assert_sanitized()`)
- No `@export` tag; not in NAMESPACE

**Testing patterns:** See `tests/testthat/test-get_marginal_effect.R` for structure:
```r
# Setup example data
data01 <- trial01 |> transform(...) |> dplyr::filter(...)
fit1 <- glm(...) |> get_marginal_effect(...)

# Test errors
test_that("Error when argument missing", {
  expect_error(glm(...) |> get_marginal_effect(...))
})

# Test warnings
test_that("Warning for missing data", {
  expect_warning(glm(...) |> get_marginal_effect(...), "pattern")
})

# Test output
test_that("Correct dimensions", {
  expect_equal(dim(fit1$marginal_results), c(12, 8))
})
```

## Special Directories

**man/:**
- Purpose: roxygen2-generated reference documentation
- Generated: Auto-created from roxygen comments via `devtools::document()`
- Committed: Yes (distributed with package)
- Manual edit: Never; regenerate from R/*.R roxygen comments if changes needed

**vignettes/:**
- Purpose: Narrative guides with executable examples
- Generated: Rmd source files (not auto-generated)
- Committed: Yes (source Rmd committed; HTML built on CRAN/devtools::build_vignettes())
- Manual edit: Yes; edit .Rmd directly, re-run knitr to rebuild

**tests/testthat/ (coverage):**
- Purpose: Comprehensive test suite
- Run: `devtools::test()` or `testthat::test_dir("tests/testthat")`
- Committed: Yes (essential for package validation)
- Coverage target: No formal requirement but >70% expected for production package

*Structure analysis: 2026-01-31*
