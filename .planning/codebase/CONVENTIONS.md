# Coding Conventions

**Analysis Date:** 2026-01-31

## Naming Patterns

**Files:**
- Snake case with lowercase: `get_marginal_effect.R`, `predict_counterfactuals.R`, `apply_contrast.R`
- One exported function per file (generally)
- Test files mirror source names: `R/function_name.R` → `tests/testthat/test-function_name.R`

**Functions:**
- Snake case with lowercase: `get_marginal_effect()`, `predict_counterfactuals()`, `average_predictions()`, `estimate_varcov()`, `apply_contrast()`, `sanitize_model()`
- S3 methods use dot notation: `sanitize_model.glm()`, `sanitize_model.default()`, `print.beeca()`, `tidy.beeca()`, `augment.beeca()`
- Internal/helper functions prefixed with dot: `.get_data()`, `.assert_sanitized()`

**Variables:**
- Snake case lowercase: `trt`, `data`, `fit1`, `counterfactual.means`, `counterfactual.predictions`, `robust_varcov`
- Named vectors with treatment level names: `levels(data[[trt]])`
- Loop variables use abbreviated forms: `trtlevel`, `x` (in anonymous functions)

**Types/Classes:**
- S3 class assignment: `class(object) <- c("beeca", class(object))` stacks beeca on top of glm class
- Attributes used for metadata: `attr(predictions, "label")`, `attr(predictions, "treatment.variable")`

## Code Style

**Formatting:**
- roxygen2 documentation (DESCRIPTION: `RoxygenNote: 7.3.2`)
- Markdown in roxygen: `Roxygen: list(markdown = TRUE)`
- Pipe operator (`|>`) used extensively for function chaining
- Standard R formatting conventions (no explicit linter config detected)

**Linting:**
- No .lintr or styler config files detected in repository
- No explicit linting enforcement configured
- Follows implicit tidyverse/R standard conventions

## Import Organization

**Order:**
1. Roxygen imports via `@importFrom`: `@importFrom stats predict`, `@importFrom dplyr as_tibble`, `@importFrom utils packageVersion`, `@importFrom utils combn`
2. NAMESPACE imports declared in roxygen comments
3. Explicit function references via `package::function()` used in code (e.g., `stats::pnorm()`, `dplyr::as_tibble()`, `utils::packageVersion()`)

**Path Aliases:**
- No explicit path aliases used
- Functions referenced fully with package prefix when not imported
- Example: `dplyr::filter()` used directly in pipes

**Documentation Pattern:**
```r
#' @importFrom stats predict
#' @importFrom dplyr as_tibble
#' @export
function_name <- function(object) {
  # implementation
}
```

## Error Handling

**Patterns:**
- Base R `stop()` with `call. = FALSE` for errors (silent call context)
- Base R `warning()` with `call. = FALSE` for warnings
- `sprintf()` for formatted messages
- No rlang or cli packages used
- Error messages are descriptive and include context

**Examples from codebase:**
```r
# From sanitize.R
stop(msg, call. = FALSE)

# From average_predictions.R
stop(msg, call. = FALSE)

# From apply_contrast.R
warning(sprintf("No reference argument was provided, using {%s} as the reference level(s)",
                paste(reference, collapse = ", ")), call. = FALSE)
```

**Validation Strategy:**
- Sanitize functions validate model properties upfront (`sanitize_model()`)
- Internal assertion functions check for required components: `.assert_sanitized()`
- Missing data checks at model fit time
- Treatment variable must be factor with 2+ levels
- Response variable must be coded 0/1
- Model must be binomial family with logit link

## Logging

**Framework:** Base R `message()` and `cat()`

**Patterns:**
- `cat()` used in print methods for formatted output
- No structured logging framework
- Informative progress messages in user-facing functions like `beeca_fit()`
- verbose parameter controls message output (in `beeca_fit()`)

**Example from print.R:**
```r
cat("beeca: Covariate-Adjusted Marginal Treatment Effect\n")
cat(strrep("=", 55), "\n\n", sep = "")
cat(sprintf("Contrast:  %s\n", contrast_label))
```

## Comments

**When to Comment:**
- Roxygen documentation for all exported functions (required)
- Inline comments for non-obvious logic
- Section headers for logical code blocks (e.g., `# set up example`, `# test warnings/errors`)
- Comments marking internal functions: `#' (internal)` in roxygen

**JSDoc/TSDoc:**
- roxygen2 used exclusively for documentation
- All exported functions have full roxygen documentation
- All parameters documented with `@param`
- Return values documented with `@return` (including tabular structures)
- Examples provided with `@examples`
- References with `@references` including DOIs

**Example:**
```r
#' Estimate marginal treatment effects using a GLM working model
#'
#' @description
#' Estimates the marginal treatment effect from a logistic regression working model
#' using a specified choice of variance estimator and contrast.
#'
#' @param object a fitted \link[stats]{glm} object.
#' @param trt a string specifying the name of the treatment variable
#' @return an updated `glm` object appended with marginal estimate components
#' @export
#' @examples
#' trial01$trtp <- factor(trial01$trtp)
#' fit1 <- glm(aval ~ trtp + bl_cov, family = "binomial", data = trial01) |>
#'   get_marginal_effect(trt = "trtp", method = "Ye", contrast = "diff", reference = "0")
```

## Function Design

**Size:** Functions are purposefully small and focused:
- `get_marginal_effect()`: ~130 lines (main orchestrator, still under 2-minute read time)
- `predict_counterfactuals()`: ~85 lines
- `average_predictions()`: ~78 lines
- `estimate_varcov()`: ~150+ lines (most complex due to method branching)
- Helper functions are extracted to internal functions

**Parameters:**
- Named parameters preferred over positional
- Default values for optional parameters: `method = "Ge"`, `type = "HC0"`, `strata = NULL`
- Factor parameters with `c()` constraints shown: `method = c("Ge", "Ye")`
- Object-first pattern used: `function(object, param1, param2, ...)`

**Return Values:**
- Functions return modified object with additional components appended
- Attributes used for metadata: `attr(object$predictions, "label")`
- New tibbles/dataframes created via `dplyr::as_tibble()`
- Consistent return: always return object for piping

**Example:**
```r
get_marginal_effect <- function(object, trt, strata = NULL,
                                method = "Ge",
                                type = "HC0",
                                contrast = "diff",
                                reference, mod = FALSE) {
  # validation
  object <- .assert_sanitized(object, trt)

  # processing pipeline
  object <- object |>
    predict_counterfactuals(trt) |>
    average_predictions() |>
    estimate_varcov(strata, method, type, mod) |>
    apply_contrast(contrast, reference)

  # add results
  # return object
}
```

## Module Design

**Exports:**
- Explicit `@export` in roxygen for public functions
- No barrel files used
- All exports through NAMESPACE (generated from roxygen)
- S3 generic functions exported: `sanitize_model()` with methods `sanitize_model.glm()`, `sanitize_model.default()`

**Barrel Files:**
- Not used; each function in its own file

**Piping:**
- Native pipe `|>` used throughout
- Pipeline pattern: glm → predict_counterfactuals → average_predictions → estimate_varcov → apply_contrast
- Functions designed to be composable in sequences

**Data Flow:**
- Functions augment the glm object by adding named components: `object$counterfactual.predictions`, `object$counterfactual.means`, `object$robust_varcov`, `object$marginal_est`, `object$marginal_se`, `object$marginal_results`
- Object immutability: each function returns a new/modified object rather than mutating in-place
- Tibbles used for tabular data: `dplyr::as_tibble()`

## S3 Method Convention

**Pattern:**
```r
# Generic
sanitize_model <- function(model, ...) {
  UseMethod("sanitize_model")
}

# Method for glm
sanitize_model.glm <- function(model, trt, ...) {
  # implementation specific to glm
}

# Default method
sanitize_model.default <- function(model, trt, ...) {
  # fallback for unsupported classes
}
```

**Applied to:**
- `sanitize_model()` - validates model type
- `print.beeca()` - custom print for beeca class
- `tidy.beeca()` - broom compatibility
- `augment.beeca()` - broom compatibility
- `summary.beeca()` - custom summary

---

*Convention analysis: 2026-01-31*
