# Codebase Concerns

**Analysis Date:** 2026-01-31

## Tech Debt

**Gradient Function Edge Cases in Contrasts:**
- Issue: Gradient functions in `apply_contrast.R` perform division without boundary checks for probabilities near 0 or 1
- Files: `R/apply_contrast.R` (lines 202-259)
- Impact: When predicted probabilities approach 0 or 1, gradients for odds ratio (`grad_or`, line 218-226) and log odds ratio (`grad_logor`, line 254-258) compute 1/(x*(1-x)) and 1/(y*(1-y)), which can produce Inf/-Inf or numerical instability
- Fix approach: Add safeguards: (1) Check for boundary probabilities before computing gradients, (2) Add small epsilon value to denominators (e.g., 1-x becomes max(1-x, 1e-10)), (3) Document the assumption that probabilities should be strictly between 0 and 1

**Symmetry Check Implementation:**
- Issue: Variance-covariance matrix symmetry check uses `all.equal()` with default tolerance but doesn't handle numerical precision issues robustly
- Files: `R/estimate_varcov.R` (lines 125-129)
- Impact: May produce false negatives for matrices that are numerically symmetric but differ beyond default tolerance (e.g., from floating-point accumulated errors in variance calculation)
- Fix approach: Use stricter tolerance check with explicit `tolerance` parameter, or use `Matrix::isSymmetric()` with configurable tolerance

**Covariate Validation in beeca_fit:**
- Issue: `beeca_fit()` does not validate that covariates are in complete-case format before modeling
- Files: `R/beeca_fit.R` (lines 125-141, 152-161)
- Impact: Missing data handling occurs post-formula construction; potential for inconsistent variable availability across model components
- Fix approach: Validate variable existence and missing data status earlier; construct complete-case subset before formula building

## Known Bugs

**Subscript Out of Bounds in beeca_fit Tests:**
- Symptoms: 10 test cases in `test-beeca-fit.R` are skipped with message "Known issue: subscript out of bounds in test environment"
- Files: `tests/testthat/test-beeca-fit.R` (lines 25, 29, 95, 99, 155, 159, 163, 188, 193, 198)
- Trigger: Tests for `beeca_fit()` with various configurations (auto-factoring treatment, no covariates, type parameter with Ge method)
- Workaround: Use underlying `get_marginal_effect()` workflow directly instead of `beeca_fit()`
- Priority: High - blocks high-level convenience function testing

**Incomplete ARD Column Documentation:**
- Symptoms: `ANALDESC` column in marginal_results contains version string but format not documented
- Files: `R/get_marginal_effect.R` (line 124)
- Impact: Consumers of marginal_results cannot reliably parse metadata; version string format could break if beeca versioning changes
- Fix approach: Document ARD schema in `?get_marginal_effect` with example ANALDESC values; consider structured metadata column

## Security Considerations

**No Input Sanitization for Formula Construction:**
- Risk: `beeca_fit()` constructs formula strings using `sprintf()` without validation of variable names
- Files: `R/beeca_fit.R` (lines 164-178)
- Current mitigation: Variables checked for existence in data, but no check for R reserved words or special characters
- Recommendations: (1) Validate variable names against R syntax rules, (2) Use backticks in formula string for non-standard names (e.g., \`2010_Revenue\`), (3) Add test cases for edge-case variable names

**Data Validation Order:**
- Risk: Model fitting via `glm()` occurs before complete validation in `sanitize_model()`
- Files: `R/beeca_fit.R` (lines 181-186) then `get_marginal_effect()` (line 76)
- Current mitigation: Validation warnings issued post-hoc
- Recommendations: Move validation checks to pre-fitting phase; consider strict vs. permissive modes

## Performance Bottlenecks

**Variance Decomposition Loop Inefficiency:**
- Problem: Ye's method variance calculation (varcov_ye) iterates over treatment levels multiple times with redundant covariance calculations
- Files: `R/estimate_varcov.R` (lines 139-233)
- Cause: Lines 162-185 (diagonal variance) and 189-205 (covariance components) each loop independently over treatment levels; counterfactual predictions subset repeatedly
- Improvement path: (1) Vectorize covariance calculations, (2) Cache data subsets by treatment level, (3) Profile on large datasets (n > 10K) to quantify impact

**Data Subsetting in ye_strata_adjustment:**
- Problem: Stratification adjustment recalculates predictions and residuals on original data
- Files: `R/estimate_varcov.R` (lines 235-277)
- Cause: Line 251 calls `predict(object, type = "response")` on full model data; line 252 calculates residuals; both repeated across strata levels
- Improvement path: Cache predictions and residuals once before strata loop; vectorize strata-level operations

**gt Table Generation Complexity:**
- Problem: `as_gt.beeca()` rebuilds table structure iteratively via nested loops
- Files: `R/as_gt.R` (lines 129-242)
- Cause: Lines 129-150 build arm_data list with lapply then rbind; lines 165-203 repeat for effects_data; line 208-242 loop again for table rows
- Improvement path: Consolidate into single pass or vectorized data frame construction

## Fragile Areas

**Variance-Covariance Matrix Construction:**
- Files: `R/estimate_varcov.R` (lines 208-214 in varcov_ye)
- Why fragile: Matrix construction via indexing with logical matrix (`idxs`) is error-prone; relies on correct row/column ordering
- Safe modification: (1) Add explicit dimension checks before and after matrix operations, (2) Validate row/column names match expected treatment levels, (3) Add comprehensive comments explaining indexing logic
- Test coverage: `test-estimate_varcov.R` has 18 tests covering both methods, but matrix indexing logic could benefit from specific unit tests

**Treatment Level Ordering in apply_contrast:**
- Files: `R/apply_contrast.R` (lines 125-143)
- Why fragile: `combn()` output combined with reference level filtering creates complex index mapping; vulnerable to treatment level reordering
- Safe modification: (1) Add explicit tests for all reference level combinations, (2) Validate output dimensions match expected contrast count, (3) Consider explicit mapping dictionary instead of index-based approach
- Test coverage: `test-apply_contrasts.R` has 28+ tests but would benefit from edge cases (single reference, all but one as reference)

**Model Data Extraction via attributes:**
- Files: `R/sanitize.R` (line 138), used throughout codebase
- Why fragile: `.get_data(object)` assumes `object$model` exists; no validation that glm object has expected structure
- Safe modification: (1) Add explicit check for `$model` component before extraction, (2) Handle alternative glm storage formats, (3) Add defensive tests for non-standard glm objects
- Test coverage: Tests assume standard `glm()` output structure

## Scaling Limits

**Counterfactual Predictions Memory:**
- Current capacity: Predictions stored as full tibble with n_rows × n_treatment_levels columns; scales to ~1M rows × 10 arms without issue
- Limit: Datasets > 100M rows or > 50 treatment levels may exceed typical R memory limits
- Scaling path: (1) Consider lazy evaluation or chunked processing for large datasets, (2) Document memory requirements, (3) Add data size warnings in `predict_counterfactuals()`

**Variance Calculation Numerical Precision:**
- Current capacity: Tested on trials up to n=5000 with stable variance estimates
- Limit: Very large trials (n > 100K) or extreme covariate distributions may encounter numerical instability in covariance matrix calculations
- Scaling path: (1) Profile variance matrix condition numbers on large datasets, (2) Consider regularization if condition number becomes problematic, (3) Document assumptions about data scale

## Dependencies at Risk

**gt Package Soft Dependency:**
- Risk: `as_gt()` requires external ggplot2/gt packages but no hard dependency
- Impact: Users without gt installed cannot generate publication tables
- Migration plan: Already handled via `requireNamespace()` check (line 79); consider documenting as "Suggested" in DESCRIPTION

**ggplot2 Dependency for plot():**
- Risk: `plot()` methods depend on ggplot2 but skip tests when unavailable
- Impact: Plot functionality silently fails or degrades if ggplot2 not installed
- Migration plan: Already handled; document as "Suggested" package

## Missing Critical Features

**No Interaction Term Support:**
- Problem: Package explicitly prohibits treatment-covariate interactions (sanitize.R lines 49-55)
- Blocks: Cannot estimate personalized/heterogeneous treatment effects, limited applicability in precision medicine
- Mitigation: Document this as intentional design choice; provide workaround guidance in vignettes

**No Missing Data Imputation:**
- Problem: Package requires complete cases; no mechanism for imputation or sensitivity analysis
- Blocks: Cannot handle realistic trial data with dropout or intermittent missingness
- Mitigation: Document requirement for complete cases; recommend mice/amelia preprocessing

**No Multi-Arm Pairwise Comparison Helpers:**
- Problem: apply_contrast generates all pairwise comparisons with reference arms but no convenience functions for common patterns (e.g., "compare all to control", "compare consecutive arms")
- Blocks: Users must manually specify reference levels for multi-arm trials
- Mitigation: Add helper functions in future release (e.g., `all_vs_control()`, `sequential_comparisons()`)

## Test Coverage Gaps

**Gradient Functions Under Boundary Conditions:**
- What's not tested: Gradient calculations when predicted probabilities equal/approach 0 or 1
- Files: `R/apply_contrast.R` (lines 186-259 gradient functions); no tests in `test-apply_contrasts.R`
- Risk: Inf or NaN values silently propagate to standard errors; users may not detect failed calculations
- Priority: High - affects all non-diff contrast types (rr, or, logrr, logor)

**Stratification with Missing Strata Levels:**
- What's not tested: Behavior when stratification variable has unequal representation across treatment arms
- Files: `R/estimate_varcov.R` ye_strata_adjustment (lines 235-277)
- Risk: May produce misleading variance estimates if certain strata-treatment combinations are empty
- Priority: Medium

**Numerical Stability Across Variance Methods:**
- What's not tested: Comparison of Ge vs Ye variance estimates when model predictions are extreme (near 0/1)
- Files: `R/estimate_varcov.R` varcov_ge and varcov_ye
- Risk: Discrepancies between methods may remain undetected
- Priority: Medium

**Edge Cases in ARD Generation:**
- What's not tested: Single-arm analysis (if attempted), treatment arms with zero events, outcome prevalence at boundaries (0% or 100%)
- Files: `R/get_marginal_effect.R` (lines 88-124 marginal_results construction)
- Risk: Division by zero or Inf/NaN in ARD statistics (lines 100-101 sqrt of diagonal)
- Priority: Medium

---

*Concerns audit: 2026-01-31*
