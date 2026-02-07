# Implementation Plan: Output/Reporting & User Experience Enhancements

## Phase 1: Core Plotting Functions (Category 4.2)

### 1.1 Forest Plot for Treatment Effects

**Priority:** High **Estimated effort:** Medium

**Implementation:**

``` r
# R/plot_forest.R
plot_forest.beeca <- function(x,
                              conf.level = 0.95,
                              show_heterogeneity = FALSE,
                              title = NULL,
                              ...) {
  # Extract treatment effect estimates
  # Create forest plot using ggplot2
  # Return ggplot object
}
```

**Features:** - Point estimates with confidence intervals - Reference
line at null effect - Flexible customization (colors, labels) - Support
for multiple contrasts (3+ arm trials) - Optional subgroup display

**Dependencies:** ggplot2 (Suggests)

------------------------------------------------------------------------

### 1.2 Diagnostic Plots

**Priority:** Medium **Estimated effort:** Medium

**Implementation:**

``` r
# R/plot_diagnostics.R
plot_diagnostics.beeca <- function(x,
                                   which = c(1:4),
                                   ask = FALSE,
                                   ...) {
  # 1. Residuals vs fitted
  # 2. Q-Q plot
  # 3. Scale-Location
  # 4. Cook's distance
  # 5. Leverage plot
  # 6. Covariate balance
}
```

**Features:** - Standard GLM diagnostics extended for beeca - Influence
diagnostics - Covariate balance visualization - Multi-panel layout

------------------------------------------------------------------------

### 1.3 Effect Plots

**Priority:** Medium-High **Estimated effort:** Medium

**Implementation:**

``` r
# R/plot_effects.R
plot_effects.beeca <- function(x,
                               covariate = NULL,
                               type = c("marginal", "conditional", "ite"),
                               ...) {
  # Marginal: Bar/point plot of marginal risks
  # Conditional: Effects across covariate values
  # ITE: Individual treatment effect distribution
}
```

**Features:** - Marginal risk comparison (bar chart or point range) -
Conditional effects across continuous covariates - Individual treatment
effect (ITE) distribution (histogram/density) - Customizable themes

------------------------------------------------------------------------

### 1.4 S3 Plot Method Dispatcher

**Priority:** High **Estimated effort:** Low

**Implementation:**

``` r
# R/plot.R
#' Plot method for beeca objects
#'
#' @export
plot.beeca <- function(x,
                       type = c("forest", "effects", "diagnostics"),
                       ...) {
  type <- match.arg(type)

  switch(type,
    forest = plot_forest(x, ...),
    effects = plot_effects(x, ...),
    diagnostics = plot_diagnostics(x, ...)
  )
}
```

------------------------------------------------------------------------

## Phase 2: Enhanced Error Messages (Category 6.1)

### 2.1 Informative Error Messages

**Priority:** High **Estimated effort:** Low-Medium

**Current state:**

``` r
# Current (example)
stop("Invalid trt")
```

**Enhanced:**

``` r
# R/utils_messages.R
stop_invalid_trt <- function(trt, available_vars) {
  msg <- sprintf(
    "Treatment variable '%s' not found in model.\n",
    trt
  )

  # Suggest similar variables
  suggestions <- agrep(trt, available_vars, value = TRUE, max.distance = 2)
  if (length(suggestions) > 0) {
    msg <- paste0(msg, sprintf("Did you mean: %s?",
                               paste(suggestions, collapse = ", ")))
  } else {
    msg <- paste0(msg, sprintf("Available variables: %s",
                               paste(available_vars, collapse = ", ")))
  }

  stop(msg, call. = FALSE)
}
```

**Apply to:** - Invalid treatment variable - Model validation failures -
Misspecified contrasts - Incompatible stratification - Convergence
issues

------------------------------------------------------------------------

### 2.2 Diagnostic Warnings

**Priority:** Medium **Estimated effort:** Low

**Implementation:**

``` r
# R/diagnostics.R
check_model_diagnostics <- function(object, warn = TRUE) {
  issues <- list()

  # Check for separation
  if (has_separation(object)) {
    issues$separation <- "Perfect/quasi-separation detected. Estimates may be unreliable."
  }

  # Check for sparse cells
  sparse_cells <- check_sparse_cells(object)
  if (sparse_cells$has_sparse) {
    issues$sparse <- sprintf(
      "Sparse cells detected in %s. Consider collapsing categories.",
      sparse_cells$variables
    )
  }

  # Check convergence
  if (!object$converged) {
    issues$convergence <- "Model did not converge. Consider rescaling covariates."
  }

  # Check influential points
  influential <- check_influence(object)
  if (influential$has_influential) {
    issues$influence <- sprintf(
      "%d observations have high influence (Cook's D > 1).",
      influential$n
    )
  }

  if (warn && length(issues) > 0) {
    for (issue in issues) {
      warning(issue, call. = FALSE)
    }
  }

  invisible(issues)
}
```

------------------------------------------------------------------------

### 2.3 Progress Indicators

**Priority:** Low-Medium **Estimated effort:** Low

**Implementation:**

``` r
# For bootstrap methods (future enhancement)
library(cli)  # Suggests

get_marginal_effect_bootstrap <- function(..., n_boot = 1000, verbose = TRUE) {
  if (verbose) {
    cli_progress_bar("Bootstrap resampling", total = n_boot)
  }

  for (i in seq_len(n_boot)) {
    # Bootstrap iteration
    if (verbose) cli_progress_update()
  }

  if (verbose) cli_progress_done()
}
```

------------------------------------------------------------------------

## Phase 3: Workflow Helpers (Category 6.3)

### 3.1 Quick Analysis Function

**Priority:** Medium-High **Estimated effort:** Medium

**Implementation:**

``` r
# R/beeca_fit.R
#' Quick beeca analysis pipeline
#'
#' @export
beeca_fit <- function(data,
                      outcome,
                      treatment,
                      covariates = NULL,
                      method = c("Ye", "Ge"),
                      contrast = c("diff", "rr", "or"),
                      reference = NULL,
                      strata = NULL,
                      family = binomial(),
                      ...) {

  method <- match.arg(method)
  contrast <- match.arg(contrast)

  # Validate inputs
  stopifnot(
    is.data.frame(data),
    outcome %in% names(data),
    treatment %in% names(data)
  )

  # Ensure treatment is factor
  if (!is.factor(data[[treatment]])) {
    message(sprintf("Converting %s to factor", treatment))
    data[[treatment]] <- as.factor(data[[treatment]])
  }

  # Build formula
  if (is.null(covariates)) {
    formula <- as.formula(sprintf("%s ~ %s", outcome, treatment))
  } else {
    cov_str <- paste(covariates, collapse = " + ")
    formula <- as.formula(sprintf("%s ~ %s + %s", outcome, treatment, cov_str))
  }

  # Fit model
  message("Fitting logistic regression model...")
  fit <- glm(formula, family = family, data = data)

  # Get marginal effect
  message(sprintf("Computing marginal effects (method: %s, contrast: %s)...",
                  method, contrast))
  result <- get_marginal_effect(
    fit,
    trt = treatment,
    strata = strata,
    method = method,
    contrast = contrast,
    reference = reference,
    ...
  )

  message("Done!")
  result
}
```

**Usage:**

``` r
# Simple workflow
fit <- beeca_fit(
  data = trial01,
  outcome = "aval",
  treatment = "trtp",
  covariates = c("bl_cov", "age", "sex"),
  method = "Ye",
  contrast = "diff"
)

# View results
tidy(fit, conf.int = TRUE)
plot(fit, type = "forest")
```

------------------------------------------------------------------------

### 3.2 Summary Method Enhancement

**Priority:** Medium **Estimated effort:** Low

**Implementation:**

``` r
# R/summary.R
#' @export
summary.beeca <- function(object, conf.level = 0.95, digits = 3, ...) {

  cat("Covariate-Adjusted Marginal Treatment Effect\n")
  cat(rep("=", 50), "\n\n", sep = "")

  # Model info
  cat("Model: Logistic regression with covariate adjustment\n")
  cat(sprintf("Method: %s variance estimator\n",
              attr(object$marginal_se, "type")))
  cat(sprintf("Contrast: %s\n",
              attr(object$marginal_est, "contrast")[1]))
  cat(sprintf("Sample size: %d\n\n", nrow(object$data)))

  # Marginal risks
  cat("Marginal Risks:\n")
  risks <- data.frame(
    Treatment = names(object$counterfactual.means),
    Risk = round(object$counterfactual.means, digits),
    SE = round(sqrt(diag(object$robust_varcov)), digits)
  )
  print(risks, row.names = FALSE)
  cat("\n")

  # Treatment effect
  cat("Treatment Effect:\n")
  z_crit <- qnorm(1 - (1 - conf.level) / 2)
  effects <- data.frame(
    Comparison = attr(object$marginal_est, "contrast"),
    Estimate = round(object$marginal_est, digits),
    SE = round(object$marginal_se, digits),
    CI_lower = round(object$marginal_est - z_crit * object$marginal_se, digits),
    CI_upper = round(object$marginal_est + z_crit * object$marginal_se, digits),
    Z = round(object$marginal_est / object$marginal_se, digits),
    P_value = format.pval(2 * pnorm(-abs(object$marginal_est / object$marginal_se)))
  )
  print(effects, row.names = FALSE)
  cat("\n")

  # Model diagnostics
  diagnostics <- check_model_diagnostics(object, warn = FALSE)
  if (length(diagnostics) > 0) {
    cat("Diagnostics:\n")
    for (name in names(diagnostics)) {
      cat(sprintf("  [!] %s\n", diagnostics[[name]]))
    }
  }

  invisible(object)
}
```

------------------------------------------------------------------------

### 3.3 Print Method Enhancement

**Priority:** Medium **Estimated effort:** Low

**Implementation:**

``` r
# R/print.R
#' @export
print.beeca <- function(x, digits = 3, ...) {
  cat("beeca object: Covariate-Adjusted Marginal Treatment Effect\n\n")

  cat(sprintf("Contrast: %s\n", attr(x$marginal_est, "contrast")[1]))
  cat(sprintf("Estimate: %s (SE = %s)\n",
              round(x$marginal_est, digits),
              round(x$marginal_se, digits)))

  p_val <- 2 * pnorm(-abs(x$marginal_est / x$marginal_se))
  cat(sprintf("P-value: %s\n\n", format.pval(p_val)))

  cat("Use summary() for detailed results\n")
  cat("Use tidy() for broom-compatible output\n")
  cat("Use plot() for visualizations\n")

  invisible(x)
}
```

------------------------------------------------------------------------

## Phase 4: Table Generation (Category 4.3)

### 4.1 Basic Table Function

**Priority:** Medium **Estimated effort:** Medium

**Implementation:**

``` r
# R/table_marginal_effects.R
#' Create publication-ready tables
#'
#' @export
table_marginal_effects <- function(x,
                                   conf.level = 0.95,
                                   format = c("gt", "kable", "flextable"),
                                   caption = NULL,
                                   footnote = TRUE,
                                   ...) {

  format <- match.arg(format)

  # Extract data
  tidy_data <- tidy(x, conf.int = TRUE, conf.level = conf.level,
                    include_marginal = TRUE)

  # Format based on output type
  switch(format,
    kable = table_kable(tidy_data, caption, footnote, ...),
    gt = table_gt(tidy_data, caption, footnote, ...),
    flextable = table_flextable(tidy_data, caption, footnote, ...)
  )
}

# Internal formatters
table_kable <- function(data, caption, footnote, ...) {
  requireNamespace("knitr", quietly = TRUE)

  tbl <- knitr::kable(
    data,
    caption = caption %||% "Marginal Treatment Effects",
    digits = 3,
    ...
  )

  if (footnote) {
    # Add footnote about method
    attr(tbl, "footnote") <- "Covariate-adjusted analysis using beeca package"
  }

  tbl
}
```

------------------------------------------------------------------------

## Implementation Timeline

### Sprint 1 (Weeks 1-2): Core Plotting

Implement
[`plot.beeca()`](https://openpharma.github.io/beeca/reference/plot.beeca.md)
S3 method

Implement
[`plot_forest()`](https://openpharma.github.io/beeca/reference/plot_forest.md)

Add basic tests

Add ggplot2 to Suggests

Create plotting vignette

### Sprint 2 (Weeks 3-4): Enhanced Messages

Implement informative error messages

Add diagnostic warnings to
[`get_marginal_effect()`](https://openpharma.github.io/beeca/reference/get_marginal_effect.md)

Improve validation error messages in
[`sanitize_model()`](https://openpharma.github.io/beeca/reference/sanitize_model.md)

Add tests for error messages

### Sprint 3 (Weeks 5-6): Workflow Helpers

Implement
[`beeca_fit()`](https://openpharma.github.io/beeca/reference/beeca_fit.md)
convenience function

Enhance
[`summary.beeca()`](https://openpharma.github.io/beeca/reference/summary.beeca.md)
method

Enhance
[`print.beeca()`](https://openpharma.github.io/beeca/reference/print.beeca.md)
method

Add workflow vignette

### Sprint 4 (Weeks 7-8): Additional Plots & Tables

Implement `plot_effects()`

Implement `plot_diagnostics()`

Implement `table_marginal_effects()`

Add comprehensive plotting tests

------------------------------------------------------------------------

## Dependencies to Add

### Required (Imports):

- None (keep lightweight)

### Suggested:

- `ggplot2` - for plotting functions
- `cli` - for progress bars and better messages
- `gt` - for table generation (optional)
- `knitr` - for kable tables (already in Suggests)

------------------------------------------------------------------------

## Testing Strategy

### Unit Tests:

- Plot functions return ggplot objects
- Error messages contain expected text
- Diagnostic checks catch issues
- Helper functions validate inputs

### Visual Tests:

- Use vdiffr for plot regression testing
- Manual inspection of example plots

### Integration Tests:

- Full workflow from data to visualization
- Multiple scenarios (2-arm, 3-arm, different contrasts)

------------------------------------------------------------------------

## Documentation Requirements

### Vignettes:

1.  **Visualization Guide** - All plot types with examples
2.  **Workflow Examples** - Common analysis patterns
3.  **Customization Guide** - Customizing plots and tables

### Man Pages:

- Complete @examples for all new functions
- Cross-references between related functions
- Detailed parameter documentation

------------------------------------------------------------------------

## Success Criteria

1.  **Usability:** Users can create publication-ready plots with single
    function call
2.  **Clarity:** Error messages guide users to solutions
3.  **Flexibility:** Plots are customizable via ggplot2
4.  **Performance:** Functions run efficiently on typical datasets
5.  **Documentation:** Comprehensive examples and vignettes
6.  **Tests:** \>90% coverage for new functions

------------------------------------------------------------------------

## Future Enhancements (Post-Phase 4)

- Interactive plots with plotly
- Shiny dashboard for exploratory analysis
- Report templates (Quarto/RMarkdown)
- Integration with gt/flextable for advanced formatting
- Custom themes for different journal styles
