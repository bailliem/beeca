# beeca Package - Claude Agent Context

## Package Overview

**beeca** (Binary Endpoint Estimation with Covariate Adjustment) is a lightweight R package for estimating marginal treatment effects in clinical trials with binary outcomes using logistic regression working models with covariate adjustment.

**Version:** 0.2.0
**License:** LGPL (>= 3)
**Authors:** Alex Przybylski, Mark Baillie, Craig Wang, Dominic Magirr (Novartis)

## Purpose and Scope

### Primary Goal
Facilitate quick industry adoption and use within GxP environments for covariate-adjusted analyses in randomized clinical trials.

### Use Cases
- Clinical trials with binary endpoints
- Covariate-adaptive randomization (stratified permuted block or biased coin)
- Superiority and non-inferiority trials
- FDA guidance-compliant robust variance estimation

### Summary Measures Supported
- Risk Difference (diff)
- Odds Ratio (or)
- Risk Ratio (rr)
- Log Odds Ratio (logor)
- Log Risk Ratio (logrr)

## Methodology

The package implements two robust variance estimation approaches:

1. **Ge et al. (2011)** - Delta method for conditional average treatment effect
   - Uses sandwich variance estimators (HC0, HC1, HC2, HC3, HC4, HC4m, HC5, model-based)
   - Suitable for conditional ATE estimation

2. **Ye et al. (2023)** - Robust variance for population average treatment effect
   - Supports stratification variables
   - Cross-validated against RobinCar package
   - Modified implementation option for improved stability

Both methods use g-computation for marginal effect estimation.

## Core Architecture

### Functional Pipeline

The package uses a functional composition pattern with 5 main exported functions:

```r
glm_object |>
  predict_counterfactuals(trt) |>    # Generate potential outcomes
  average_predictions() |>           # Average across population
  estimate_varcov(method, type) |>   # Robust variance estimation
  apply_contrast(contrast, ref) |>   # Calculate treatment effect
  get_marginal_effect()              # Wrapper function
```

### Key Functions

| Function | Location | Purpose |
|----------|----------|---------|
| `get_marginal_effect()` | `R/get_marginal_effect.R` | High-level wrapper orchestrating the pipeline |
| `predict_counterfactuals()` | `R/predict_counterfactuals.R` | Generate predictions for all treatment levels |
| `average_predictions()` | `R/average_predictions.R` | Compute mean predictions per treatment |
| `estimate_varcov()` | `R/estimate_varcov.R` | Estimate variance-covariance matrix |
| `apply_contrast()` | `R/apply_contrast.R` | Calculate marginal effects with contrasts |
| `sanitize_model()` | `R/sanitize.R` | Validate glm object (S3 generic) |

### Object Structure

The package augments the standard glm object rather than creating new classes. After processing, a glm object contains:

**Original glm components** (preserved):
- coefficients, residuals, fitted.values, etc.

**Added by beeca**:
- `counterfactual.predictions` - Tibble with predictions for all treatment scenarios
- `counterfactual.means` - Named vector of mean predictions per treatment
- `robust_varcov` - Variance-covariance matrix with method attribute
- `marginal_est` - Point estimate(s) of treatment effect(s)
- `marginal_se` - Standard error(s) of treatment effect(s)
- `marginal_results` - **Analysis Results Data (ARD) tibble**

## Analysis Results Data (ARD) Structure

The `marginal_results` component is a key output providing pharmaceutical industry-standard reporting format.

### ARD Schema

| Column | Type | Description |
|--------|------|-------------|
| `TRTVAR` | character | Treatment variable name |
| `TRTVAL` | character | Treatment level value |
| `PARAM` | character | Parameter name (outcome variable) |
| `ANALTYP1` | character | "DESCRIPTIVE" or "INFERENTIAL" |
| `STAT` | character | Statistic type (N, n, %, risk, risk_se, contrast, contrast_se) |
| `STATVAL` | numeric | Numeric value of the statistic |
| `ANALMETH` | character | Method (count, percentage, g-computation, variance type) |
| `ANALDESC` | character | Description including beeca version |

### ARD Row Structure

**For 2-arm trial (12 rows):**
- Rows 1-5: Treatment arm 0 (N, n, %, risk, risk_se)
- Rows 6-10: Treatment arm 1 (N, n, %, risk, risk_se)
- Rows 11-12: Contrast estimate and SE

**For 3-arm trial (19 rows):**
- Rows 1-15: Three arms × 5 statistics each
- Rows 16-19: Multiple pairwise contrasts

## File Organization

```
beeca/
├── R/
│   ├── get_marginal_effect.R      # Main wrapper function
│   ├── predict_counterfactuals.R  # Counterfactual generation
│   ├── average_predictions.R      # Averaging step
│   ├── estimate_varcov.R          # Variance estimation
│   ├── apply_contrast.R           # Contrast calculation
│   ├── sanitize.R                 # Model validation (S3 methods)
│   ├── trial01.R                  # Example dataset
│   ├── trial02_cdisc.R           # CDISC example dataset
│   ├── margins_trial01.R         # SAS comparison data
│   └── ge_macro_trial01.R        # SAS macro comparison data
├── tests/testthat/
│   ├── test-get_marginal_effect.R
│   ├── test-predict_counterfactuals.R
│   ├── test-average_predictions.R
│   ├── test-estimate_varcov.R
│   ├── test-apply_contrasts.R
│   └── test-sanitize.R
├── man/                           # Generated documentation
├── vignettes/                     # User guides
├── DESCRIPTION
├── NAMESPACE
└── README.md
```

## Model Requirements

The package validates that input models meet these requirements:

1. **Model Type:** Binomial family with logit link
2. **Treatment Variable:** Must be a factor with 2+ levels
3. **Response Variable:** Must be coded as 0/1
4. **Convergence:** Model must have converged
5. **Model Matrix:** Must have full rank
6. **Interactions:** No treatment-covariate interactions allowed
7. **Missing Data:** No missing values in model data

These are checked via `sanitize_model()` before processing.

## Testing Strategy

- **Test Framework:** testthat (edition 3)
- **Total Tests:** 80+ test cases
- **Cross-validation:** Against SAS %margins macro, {margins}, {marginaleffects}, {RobinCar}

Test files mirror the function structure:
- `test-sanitize.R` - 14 tests for input validation
- `test-predict_counterfactuals.R` - Counterfactual generation
- `test-average_predictions.R` - 9 tests including edge cases
- `test-estimate_varcov.R` - 18 tests (Ge, Ye, stratified)
- `test-apply_contrasts.R` - 28+ tests for all contrast types
- `test-get_marginal_effect.R` - End-to-end integration tests

## Dependencies

### Required (Imports)
- `dplyr` - Data manipulation
- `sandwich` - Robust variance estimation
- `stats` - GLM fitting
- `lifecycle` - Package lifecycle badges

### Suggested (Testing/Vignettes)
- `testthat` (>= 3.0.0)
- `knitr`, `rmarkdown`
- `tidyr`
- `marginaleffects`, `margins` - Cross-validation
- `RobinCar` (>= 0.3.0) - Cross-validation

## Example Usage

```r
library(beeca)

# Prepare data
trial01$trtp <- factor(trial01$trtp)

# Fit working model and estimate marginal effect
fit1 <- glm(aval ~ trtp + bl_cov, family = "binomial", data = trial01) |>
  get_marginal_effect(
    trt = "trtp",
    method = "Ye",
    contrast = "diff",
    reference = "0"
  )

# View ARD results
fit1$marginal_results

# Access specific components
fit1$marginal_est       # Treatment effect estimate
fit1$marginal_se        # Standard error
fit1$counterfactual.means  # Mean predictions per arm
fit1$robust_varcov      # Variance-covariance matrix
```

## Documentation Standards

All functions use roxygen2 documentation with:
- `@description` - Purpose and use case
- `@details` - Technical details and methods
- `@param` - Parameter descriptions with constraints
- `@return` - Return value structure (often using `\tabular`)
- `@examples` - Executable examples
- `@references` - Academic citations with DOIs
- `@seealso` - Links to related functions
- `@export` or `@keywords internal`

## Quality Assurance

- FDA guidance compliant (2023)
- Cross-validated against multiple implementations
- Stable lifecycle badge
- Continuous integration (R-CMD-check, test-coverage)
- CRAN release + GitHub development

## References

### FDA Guidance
FDA. 2023. "Adjusting for Covariates in Randomized Clinical Trials for Drugs and Biological Products."
https://www.fda.gov/regulatory-information/search-fda-guidance-documents/adjusting-covariates-randomized-clinical-trials-drugs-and-biological-products

### Methodology Papers
- Ge et al. (2011). "Covariate-Adjusted Difference in Proportions from Clinical Trials Using Logistic Regression and Weighted Risk Differences." Drug Information Journal 45: 481-93. https://doi.org/10.1177/009286151104500409

- Ye et al. (2023). "Robust Variance Estimation for Covariate-Adjusted Unconditional Treatment Effect in Randomized Clinical Trials with Binary Outcomes." Statistical Theory and Related Fields 7(2): 159-63. https://doi.org/10.1080/24754269.2023.2205802

- Magirr et al. (2025). "Estimating the Variance of Covariate-Adjusted Estimators of Average Treatment Effects in Clinical Trials With Binary Endpoints." Pharmaceutical Statistics 24(4): e70021. https://doi.org/10.1002/pst.70021 [PMID: 40557557]

### Related Packages
- RobinCar: https://cran.r-project.org/package=RobinCar
- marginaleffects: https://cran.r-project.org/package=marginaleffects
- margins: https://cran.r-project.org/package=margins
- sandwich: https://cran.r-project.org/package=sandwich

## Development Resources

- **Package Website:** https://openpharma.github.io/beeca/
- **GitHub Repository:** https://github.com/openpharma/beeca
- **Bug Reports:** https://github.com/openpharma/beeca/issues
- **Vignettes:** `vignette("estimand_and_implementations")`

## Working Group

Developed in collaboration with the ASA-BIOP Covariate Adjustment Scientific Working Group (https://carswg.github.io/), specifically the Software Subteam.

---

**Note for Claude Agent:** This package prioritizes simplicity, GxP compliance, and industry adoption. When proposing enhancements, maintain the lightweight nature, comprehensive testing, cross-validation approach, and pharmaceutical industry standards (ARD format, CDISC compatibility).
