# Architecture

**Analysis Date:** 2026-01-31

## Pattern Overview

**Overall:** Functional composition pipeline with S3 method dispatch for object augmentation

**Key Characteristics:**
- Linear, sequential processing chain with explicit piping (`|>`) support
- Lightweight GLM augmentation rather than new class creation (until final wrapping)
- S3 method dispatch for output formatting (print, summary, tidy, augment, plot)
- Methodological variance: Two competing robust variance estimators (Ge et al. 2011, Ye et al. 2023)
- Pharmaceutical industry standards: ARD (Analysis Results Data) format output
- Delta method for contrast calculation with analytical gradients

## Layers

**Input Validation & Sanitization:**
- Purpose: Ensure GLM meets strict requirements before processing
- Location: `R/sanitize.R`
- Contains: S3 generic `sanitize_model()` with glm method; helper `sanitize_variable()`
- Depends on: Base R stats, model frame inspection
- Used by: All pipeline steps via `.assert_sanitized()` helper

Checks enforced:
- Family: binomial with logit link only
- Treatment: factor with 2+ levels, on formula RHS
- Response: 0/1 coded binary outcome
- Model: Converged, full rank, no treatment-covariate interactions
- Data: No missing values allowed

**Counterfactual Generation Layer:**
- Purpose: Compute potential outcomes under all treatment levels
- Location: `R/predict_counterfactuals.R`
- Contains: `predict_counterfactuals()` - creates cloned datasets with treatment levels swapped, generates predictions
- Depends on: `stats::predict()`, dplyr tibble conversion, `.get_data()` helper
- Used by: Direct pipeline entry or via `get_marginal_effect()` wrapper
- Output: Added to glm as `$counterfactual.predictions` tibble + attributes (labels, treatment variable name)

**Averaging Layer:**
- Purpose: Collapse counterfactual predictions to treatment arm means
- Location: `R/average_predictions.R`
- Contains: `average_predictions()` - simple column-wise mean computation
- Depends on: `counterfactual.predictions` component (will error if missing)
- Used by: Direct pipeline or via wrapper
- Output: Added as `$counterfactual.means` named vector (names = treatment levels)

**Variance-Covariance Estimation Layer:**
- Purpose: Compute robust variance-covariance matrix of marginal treatment effects
- Location: `R/estimate_varcov.R`
- Contains: `estimate_varcov()` dispatcher + two method implementations:
  - `varcov_ge()`: Ge et al. (2011) sandwich estimator using delta method
  - `varcov_ye()`: Ye et al. (2023) variance decomposition with optional stratification adjustment via `ye_strata_adjustment()`
- Depends on: `sandwich::vcovHC()` for HC0/HC1/HC2/HC3/HC4/HC4m/HC5 estimators
- Used by: Direct pipeline or wrapper
- Output: Added as `$robust_varcov` matrix with method type in attributes

Key parameters:
- `method`: "Ge" (default) or "Ye"
- `type` (Ge only): HC0, HC1, HC2, HC3, HC4, HC4m, HC5, model-based
- `strata` (Ye only): Stratification variables for variance adjustment
- `mod`: Toggle between original Ye et al. and RobinCar-style implementation

**Contrast Application Layer:**
- Purpose: Calculate treatment effect estimates and standard errors for specified summary measures
- Location: `R/apply_contrast.R`
- Contains: `apply_contrast()` dispatcher + contrast function family:
  - Estimation: `diff()`, `rr()`, `or()`, `logrr()`, `logor()`
  - Formatting: `*_str()` helpers for labels
  - Gradients: `grad_*()` analytical derivatives for delta method SE calculation
- Depends on: `counterfactual.means`, `robust_varcov`, `utils::combn()` for pairwise contrasts
- Used by: Final stage before ARD generation
- Output: Added as `$marginal_est` and `$marginal_se` vectors with attributes (reference levels, contrast descriptions)

Contrast matrix logic:
- Computes outer product of means via contrast function
- Filters to requested reference level comparisons
- Applies jacobian (gradient matrix) to variance: SE = sqrt(diag(J * Sigma * J^T))

**S3 Output Methods:**
- Purpose: Provide standard R interface for extraction and visualization
- Locations: `R/print.R`, `R/summary.R`, `R/tidy.R`, `R/augment.R`, `R/plot.R`, `R/as_gt.R`
- Methods:
  - `print.beeca()`: Concise table of contrasts with p-values
  - `summary.beeca()`: Detailed report with arm means, contrasts, model info, confidence intervals
  - `tidy.beeca()`: Broom-compatible tibble for downstream R analysis
  - `augment.beeca()`: Original data + fitted values + individual-level counterfactuals
  - `plot.beeca()`: Forest plot of treatment effects
  - `as_gt.beeca()`: gt table formatting for reports
- All depend on: `$marginal_results` (ARD) or individual components

**ARD Generation & Integration:**
- Purpose: Create pharmaceutical-standard output; bridge to external tools
- Locations: `R/get_marginal_effect.R` (ARD creation), `R/beeca_to_cards_ard.R` (cards conversion)
- Contains:
  - In `get_marginal_effect()`: Constructs `$marginal_results` tibble from components
  - `beeca_to_cards_ard()`: Mapping from beeca ARD to cards package format
- Output structure (ARD): 12 rows (2-arm: 5 descriptive per arm + 2 contrasts) or 19 rows (3-arm)
- Columns: TRTVAR, TRTVAL, PARAM, ANALTYP1, STAT, STATVAL, ANALMETH, ANALDESC
- Used by: Reporting, quality control, regulatory submissions

## Data Flow

**Standard Pipeline - Ge Method:**

1. `glm(outcome ~ trt + covariates, family = "binomial", data)`
   - Input: Raw dataset with binary outcome (0/1), factor treatment, covariates
   - State: Standard glm object

2. `predict_counterfactuals(fit, trt = "treatment_var")`
   - Action: For each treatment level, clone data with treatment swapped, predict
   - State: glm + `$counterfactual.predictions` (N × K tibble, K = treatment levels)
   - Attaches: label strings, treatment variable name

3. `average_predictions(fit)`
   - Action: colMeans across rows
   - State: glm + `$counterfactual.means` (named vector, length K)

4. `estimate_varcov(fit, method = "Ge", type = "HC0")`
   - Action: Compute sandwich estimator; apply delta method derivatives
   - State: glm + `$robust_varcov` (K × K symmetric matrix with method attribute)

5. `apply_contrast(fit, contrast = "diff", reference = "0")`
   - Action: Compute contrasts between reference and non-reference arms
   - State: glm + `$marginal_est` and `$marginal_se` (vectors with contrast labels)

6. `get_marginal_effect()` wrapper
   - Action: Executes full pipeline above + builds ARD tibble + adds "beeca" class
   - State: glm (now "beeca" class) with all 6 components

**Ye Method with Stratification:**

Same as above, but step 4 calls `varcov_ye()` instead:
- Variance decomposition: per-arm residual variance + covariances between predictions
- Optional: Stratification adjustment via `ye_strata_adjustment()` reducing variance by permuted block allocation offset
- Warning if strata has >3 unique values (multistratum design beyond supported assumptions)

**State Management:**

The glm object accumulates components at each step:
```r
fit$counterfactual.predictions   # After step 2
fit$counterfactual.means         # After step 3
fit$robust_varcov                # After step 4
fit$marginal_est                 # After step 5
fit$marginal_se                  # After step 5
fit$marginal_results             # After step 6 (ARD)
fit$sanitized                    # Boolean flag after input validation
class(fit)                       # Becomes c("beeca", "glm", ...) in step 6
```

No explicit state machine; relies on component presence checking in each layer to enforce sequencing.

## Key Abstractions

**The Counterfactual Prediction:**
- Purpose: Represents potential outcome under each treatment, for each subject
- Examples: `R/predict_counterfactuals.R`
- Pattern: Clone + modify + predict; store in tibble; attach metadata labels

**The Sandwich Variance Estimator:**
- Purpose: Capture model misspecification robustness (Ge) or sampling variability (Ye)
- Examples: `R/estimate_varcov.R` lines 287-315 (Ge), 139-233 (Ye)
- Pattern: Sandwich: V = J^T H J (Ge) or variance decomposition (Ye); delta method for derived quantities

**The Contrast Function Family:**
- Purpose: Define summary measures (risk diff, odds ratio, etc.) with analytical gradients
- Examples: `R/apply_contrast.R` lines 177-259 (diff, rr, or, logrr, logor)
- Pattern: Each contrast C has three components:
  - `c_est(x, y)`: Point estimate function (e.g., x - y for diff)
  - `c_str(x, y)`: String formatter for labels
  - `grad_c(x, y)`: Jacobian vector [∂C/∂x, ∂C/∂y]
- Dispatch via `get(contrast)` string matching

**The ARD (Analysis Results Data):**
- Purpose: Pharmaceutical-standard tabular output for regulatory and reporting use
- Examples: Generated in `R/get_marginal_effect.R` lines 88-124
- Pattern: Long format; one row per statistic per arm/contrast; includes method metadata
- Schema: TRTVAR, TRTVAL, PARAM, ANALTYP1 (DESCRIPTIVE/INFERENTIAL), STAT, STATVAL, ANALMETH, ANALDESC

**The Beeca S3 Object:**
- Purpose: Extend glm with beeca-specific methods while preserving base glm functionality
- Pattern: Add "beeca" to class vector in addition to "glm"; all methods dispatch before falling back to glm methods
- Enables: print/summary/tidy/augment/plot without new class, reducing complexity

## Entry Points

**User-facing wrapper (recommended):**
- Location: `R/beeca_fit.R`
- Triggers: User calls `beeca_fit(data, outcome, treatment, covariates, method, contrast, ...)`
- Responsibilities: Formula building, covariate validation, model fitting, calling `get_marginal_effect()`, informative messaging

**Direct pipeline (expert users):**
- Location: `R/get_marginal_effect.R`
- Triggers: User calls `get_marginal_effect(glm_object, trt, method, contrast, reference)`
- Responsibilities: Orchestrate all 5 pipeline steps, build ARD, attach "beeca" class

**Individual function entry (advanced/diagnostic):**
- Triggers: User calls `predict_counterfactuals()`, `average_predictions()`, `estimate_varcov()`, or `apply_contrast()` directly
- Pattern: Chain with pipe `|>` or assign intermediate results
- Risk: Skipping steps or calling out of order breaks subsequent functions

**Data (test/example):**
- Locations: `R/trial01.R`, `R/trial02_cdisc.R` (data definitions); `data/trial01.rda`, `data/trial02_cdisc.rda` (serialized)
- Usage: `data(trial01)` loads for examples and tests
- Comparator data: `R/margins_trial01.R`, `R/ge_macro_trial01.R` (SAS macro results for validation)

## Error Handling

**Strategy:** Defensive programming with early validation; informative error/warning messages

**Patterns:**

1. **Input validation** (in `sanitize_model.glm()`, `R/sanitize.R`):
   - Binary (stop/warn decision): Model family/link checks → stop
   - Graded (warn): Missing data, non-convergence, full-rank issues → warn
   - Message: Includes variable names, expected values, remediation hints

2. **Component presence checking** (in `average_predictions()`, `estimate_varcov()`, `apply_contrast()`):
   ```r
   if (!"counterfactual.predictions" %in% names(object)) {
     msg <- sprintf("Missing X. First run `%1$s <- func(%1$s)`.", deparse(substitute(object)))
     stop(msg, call. = FALSE)
   }
   ```
   - Guides users to correct sequencing

3. **Reference level validation** (in `apply_contrast()`, lines 105-114):
   - Assert reference is subset of treatment levels
   - Assert not too many references (max n-1)
   - Provide valid options in error message

4. **Strata validation** (in `ye_strata_adjustment()`, lines 239-243):
   - Assert strata variables exist in model
   - Warn if any strata has >3 levels (design assumption violation)

5. **Stratification count check** (in `ye_strata_adjustment()`, lines 219-227):
   - Heuristic: >3 unique values suggests misconfiguration
   - Warning, not error, for user judgment

## Cross-Cutting Concerns

**Logging:**
- Approach: Informative messages (not warnings) for progress
- Used in: `beeca_fit()` via `message()` (verbose = TRUE)
- Not used in: Core pipeline functions (get_marginal_effect, lower layers) to allow silent piping

**Validation:**
- Approach: S3 generic `sanitize_model()` with dispatch to glm method
- Enforced: Before counterfactual generation (in `predict_counterfactuals()` via `.assert_sanitized()`)
- Flag: `$sanitized` boolean appended to glm; re-checks if FALSE (defensive)
- Warnings: Propagate but do not stop (convergence, missing data)

**Authentication/Authorization:**
- Not applicable: Pure statistical computation, no external services or access control

**Performance Considerations:**
- Delta method: O(K) contrasts from K treatment arms, O(K²) variance matrix operations
- Bottleneck: Model fitting (stats::glm), not beeca operations
- No caching: Each function call recomputes (idempotent)

**Extensibility:**
- Pattern: S3 methods for output (print, summary, tidy, augment, plot)
- Adding new contrast: Create `my_contrast()`, `my_contrast_str()`, `grad_my_contrast()` in `apply_contrast.R`; register in match.arg() list
- Adding new variance method: Create `varcov_new()` in `estimate_varcov.R`; add dispatch case in `estimate_varcov()` function

---

*Architecture analysis: 2026-01-31*
