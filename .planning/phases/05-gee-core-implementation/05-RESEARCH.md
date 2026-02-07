# Phase 5: GEE Core Implementation - Research

**Researched:** 2026-02-07
**Domain:** GEE (Generalized Estimating Equations) integration with beeca's g-computation pipeline
**Confidence:** MEDIUM

## Summary

This research investigates integrating GEE model objects (glmgee from glmtoolbox, geeglm from geepack) into beeca's existing covariate-adjusted marginal treatment effect estimation pipeline. The focus is single-timepoint data where GEE with independence working correlation degenerates to GLM-like analysis but requires different variance estimation approaches.

The standard approach is to create S3 methods for sanitize_model (validation), route variance estimation through GEE-native vcov methods instead of sandwich::vcovHC, and leverage existing predict methods that work similarly to GLM. The key technical challenge is that GEE variance estimation uses sandwich estimators built into the GEE packages rather than the sandwich package, and Ye's method (which assumes independence) is invalid for GEE models.

**Primary recommendation:** Implement S3 dispatch pattern matching existing GLM code, use GEE-native vcov methods for variance, enforce single-timepoint validation, reject Ye method explicitly, and keep GEE packages in Suggests with early package availability checking.

<user_constraints>
## User Constraints (from CONTEXT.md)

### Locked Decisions
**Variance type mapping:**
- Use GEE-native type names ("robust", "bias-corrected", "df-adjusted"), NOT HC0/HC1/etc.
- When a user passes a GLM-style type (e.g., "HC0") to a GEE object, produce an error listing valid GEE types

**Validation rules:**
- Mirror existing GLM validation checks where applicable
- Validate that cluster/id variable is present and accessible
- Validate single-timepoint: check that each cluster has exactly 1 observation — error if multi-timepoint data detected

**Error messaging:**
- Ye method rejection: short + reference — "Ye's method assumes independence and is not valid for GEE models. Use method='Ge' instead."
- GEE errors should mention the specific package name ("glmgee" or "geeglm") to help users debug

**Package availability:**
- GEE packages stay in Suggests (not Imports) — per existing decision
- Check package availability early in sanitize_model(), not lazily — fail fast
- When package missing: error with install hint — "glmtoolbox is required for glmgee objects. Install with install.packages('glmtoolbox')"
- Pin minimum versions in DESCRIPTION Suggests based on API features needed
- Tests use skip_if_not_installed() — run when packages available, skip gracefully otherwise

### Claude's Discretion
- glmgee variance types to expose (robust, bias-corrected, DF-adjusted — assess feasibility)
- geeglm variance coverage (native only vs computed corrections)
- Default variance type for GEE objects
- vcov extraction approach (method call vs object internals)
- Ge delta method adaptation for GEE
- Method parameter API design for GEE
- Correlation structure validation rules
- Multi-error vs first-error reporting (match GLM pattern)
- Whether unsupported type errors list valid options

### Deferred Ideas (OUT OF SCOPE)
None — discussion stayed within phase scope
</user_constraints>

## Standard Stack

The established packages for GEE analysis in R:

### Core GEE Packages
| Package | Version | Purpose | Why Standard |
|---------|---------|---------|--------------|
| glmtoolbox | 0.1.12+ | Modern GEE implementation via glmgee() | Actively maintained, comprehensive variance types (robust, bias-corrected/Mancl-DeRouen, DF-adjusted, model-based, jackknife), published in The R Journal 2023 |
| geepack | 1.3.13+ | Established GEE implementation via geeglm() | Widely adopted, stable API, glm-like syntax, standard in epidemiology/biostatistics |

### Supporting Infrastructure
| Library | Version | Purpose | When to Use |
|---------|---------|---------|-------------|
| testthat | 3.0.0+ | skip_if_not_installed() for optional package testing | Already in beeca Suggests, required for conditional test execution |
| sandwich | Current | NOT used for GEE variance (used only for GLM) | GEE objects use their own vcov methods, not sandwich::vcovHC |

### Key API Compatibility
Both glmgee and geeglm provide:
- `predict(object, newdata, type = "response")` - Works like glm predict
- `vcov(object, type = ...)` - Returns variance-covariance matrix with package-specific type options
- GLM-like object structure inheriting glm/lm classes
- Standard extractor functions (coef, fitted, residuals, etc.)

## Architecture Patterns

### S3 Dispatch Pattern (Mirror Existing GLM Code)

beeca uses S3 generic dispatch for sanitize_model. Extend this for GEE:

```r
# Existing pattern in R/sanitize.R
sanitize_model <- function(model, ...) {
  UseMethod("sanitize_model")
}

sanitize_model.glm <- function(model, trt, ...) {
  # GLM-specific validation
}

# NEW: Add GEE methods
sanitize_model.glmgee <- function(model, trt, ...) {
  # Check package availability first (fail fast)
  if (!requireNamespace("glmtoolbox", quietly = TRUE)) {
    stop("glmtoolbox is required for glmgee objects. Install with install.packages('glmtoolbox')",
         call. = FALSE)
  }

  # Validate cluster/id variable present
  # Validate single-timepoint (each cluster size == 1)
  # Mirror GLM checks (family, link, factor treatment, etc.)
  # Set model$sanitized <- TRUE
}

sanitize_model.geeglm <- function(model, trt, ...) {
  # Similar structure for geepack
  if (!requireNamespace("geepack", quietly = TRUE)) {
    stop("geepack is required for geeglm objects. Install with install.packages('geepack')",
         call. = FALSE)
  }
  # Validation logic
}
```

**Rationale:** This matches beeca's existing architecture and requires minimal changes to the pipeline. All downstream functions (predict_counterfactuals, average_predictions, apply_contrast) work without modification because GEE objects inherit from glm and provide predict() methods.

### Variance Estimation Routing

The estimate_varcov function needs conditional routing for GEE objects:

```r
# In R/estimate_varcov.R - modify existing function
estimate_varcov <- function(object, strata = NULL, method = c("Ge", "Ye"),
                            type = c("HC0", "model-based", "HC3", ...), # GLM types
                            mod = FALSE) {

  # Early rejection of Ye method for GEE
  if (method == "Ye" && (inherits(object, "glmgee") || inherits(object, "geeglm"))) {
    stop("Ye's method assumes independence and is not valid for GEE models. Use method='Ge' instead.",
         call. = FALSE)
  }

  # Route to appropriate variance function
  if (inherits(object, "glmgee")) {
    varcov <- varcov_ge_glmgee(object, trt, type)
  } else if (inherits(object, "geeglm")) {
    varcov <- varcov_ge_geeglm(object, trt, type)
  } else if (method == "Ye") {
    varcov <- varcov_ye(object, trt, strata, mod)
  } else if (method == "Ge") {
    varcov <- varcov_ge(object, trt, type)
  }

  # Rest unchanged
}
```

### GEE-Specific Variance Functions

Create new internal variance functions for GEE objects:

```r
# NEW internal function for glmgee
varcov_ge_glmgee <- function(object, trt, type) {
  # Validate type is GEE-native
  valid_types <- c("robust", "bias-corrected", "df-adjusted", "model", "jackknife")

  if (!type %in% valid_types) {
    stop(sprintf('Unsupported variance type "%s" for glmgee objects. Valid options: %s',
                 type, paste(valid_types, collapse = ", ")),
         call. = FALSE)
  }

  # Get GEE's own variance-covariance matrix
  V <- vcov(object, type = type)

  # Apply delta method (same approach as existing varcov_ge)
  # Counterfactual predictions already computed by predict_counterfactuals
  # Compute derivatives and apply delta method transformation

  # Return variance-covariance matrix of marginal means
}

# NEW internal function for geeglm
varcov_ge_geeglm <- function(object, trt, type) {
  # Similar structure but using geepack's vcov
  # geeglm uses std.err parameter for variance type
  # May need to extract from fitted object rather than recompute
}
```

**Key insight:** The delta method approach in existing varcov_ge (lines 288-319 in estimate_varcov.R) can be reused. The only change is using `vcov(object, type = ...)` from GEE packages instead of `sandwich::vcovHC(object, type = type)`.

### Single-Timepoint Validation

Single-timepoint constraint is CRITICAL for v0.4.0 scope:

```r
# In sanitize_model.glmgee and sanitize_model.geeglm
validate_single_timepoint <- function(model) {
  # Extract cluster ID variable
  # For glmgee: check model structure for id/cluster component
  # For geeglm: object$id contains cluster identifiers

  id_var <- extract_cluster_id(model)

  # Count observations per cluster
  cluster_sizes <- table(id_var)

  # All clusters must have exactly 1 observation
  if (!all(cluster_sizes == 1)) {
    multi_clusters <- sum(cluster_sizes > 1)
    stop(sprintf(
      "Multi-timepoint GEE detected: %d clusters have >1 observation. This phase supports single-timepoint data only.",
      multi_clusters
    ), call. = FALSE)
  }
}
```

**Warning:** GEE documentation states "if all clusters are of size one you should not use GEEs; if all clusters are of size one a GEE corresponds to a generalized linear model." However, for beeca's use case, we're allowing single-timepoint GEE to flow through the pipeline because users may have fitted GEE models for consistency with other analyses.

### Testing Pattern with Optional Packages

```r
# In tests/testthat/test-sanitize.R
test_that("sanitize_model.glmgee validates glmgee objects", {
  skip_if_not_installed("glmtoolbox")

  library(glmtoolbox)
  # Test validation logic
})

test_that("glmgee object flows through full pipeline", {
  skip_if_not_installed("glmtoolbox")

  library(glmtoolbox)
  # End-to-end integration test
})
```

**Best practice:** All GEE tests should be in separate test files (test-gee-glmgee.R, test-gee-geeglm.R) to isolate optional dependencies.

## Don't Hand-Roll

Problems that have existing solutions in the GEE ecosystem:

| Problem | Don't Build | Use Instead | Why |
|---------|-------------|-------------|-----|
| Bias-corrected variance for small samples | Custom Mancl-DeRouen implementation | vcov(glmgee_obj, type = "bias-corrected") | glmtoolbox implements published Mancl-DeRouen (2001) method, tested and validated |
| Jackknife variance | Manual resampling | vcov(glmgee_obj, type = "jackknife") | Built-in jackknife in glmtoolbox avoids resampling bugs |
| GEE convergence checking | Custom convergence logic | Use underlying geese.fit convergence | geeglm delegates to geese.fit which handles convergence; glmgee has internal convergence checks |
| Cluster data sorting | Manual sorting validation | Document data sorting requirement, let packages handle | Both packages assume sorted data by cluster; enforce via documentation not code |

**Key insight:** GEE packages are mature implementations of published methods. Prefer package-native functionality over custom implementations to maintain validation alignment with established software.

## Common Pitfalls

### Pitfall 1: Convergence Checking Differs from GLM
**What goes wrong:** Attempting to check `model$converged` on a geeglm object fails because this attribute is explicitly removed from the returned object.
**Why it happens:** geeglm source code (lines from geeglm.R) shows: `toDelete <- c("R","deviance","aic","null.deviance","iter","df.null", "converged","boundary")` - convergence info is deleted.
**How to avoid:** For geeglm, convergence checking must access the underlying geese object or be skipped. For glmgee, check package documentation for convergence attribute location.
**Warning signs:** Error "object 'converged' not found" when validating geeglm objects.

### Pitfall 2: Using GLM-Style Variance Types with GEE
**What goes wrong:** Passing `type = "HC0"` to vcov for a glmgee object either errors or produces incorrect variance.
**Why it happens:** GEE packages use different variance type naming conventions. glmtoolbox uses "robust", "bias-corrected", "df-adjusted", "model", "jackknife" - NOT HC0/HC1/etc.
**How to avoid:** Validate variance type against GEE-specific allowed values. Provide clear error message listing valid options when mismatch detected.
**Warning signs:** Cryptic errors from vcov.glmgee or incorrect variance estimates.

### Pitfall 3: Missing Data Handling
**What goes wrong:** geeglm crashes or produces wrong results with NA values in data.
**Why it happens:** GEE packages (especially geepack) only work on complete data. Unlike glm which uses na.omit internally, geeglm requires explicit NA handling.
**How to avoid:** beeca's existing sanitize_model checks for missing data (lines 58-65 in sanitize.R). This check should work for GEE too, but verify data completeness before GEE-specific validation.
**Warning signs:** Cryptic errors about dimension mismatches or cluster sizes.

### Pitfall 4: Unstructured Correlation Crashes R
**What goes wrong:** When validating correlation structure, encountering "unstructured" correlation can crash the entire R session (not just throw an error).
**Why it happens:** geepack documentation warns: "Use 'unstructured' correlation structure only with great care (It may cause R to crash)."
**How to avoid:** For single-timepoint data, correlation structure is irrelevant (all clusters size 1 = no within-cluster correlation). Validation should ignore correlation structure or verify it's set to "independence".
**Warning signs:** Users report R crashes when running beeca with GEE objects.

### Pitfall 5: Data Ordering Requirements
**What goes wrong:** GEE estimates are incorrect despite model converging and passing validation.
**Why it happens:** Both geepack and glmtoolbox documentation state: "Data are assumed to be sorted so that observations on each cluster appear as contiguous rows in data."
**How to avoid:** Document data sorting requirement. For single-timepoint data (cluster size = 1), this is automatically satisfied. For future multi-timepoint support, add explicit validation of data ordering.
**Warning signs:** Variance estimates are unexpectedly large or results don't match other software.

### Pitfall 6: Ye Method Applied to GEE
**What goes wrong:** User calls `get_marginal_effect(gee_obj, method = "Ye")` and gets nonsensical results or errors.
**Why it happens:** Ye's method assumes independent observations. GEE explicitly models within-cluster correlation, making independence assumption invalid.
**How to avoid:** Explicit early check in estimate_varcov: if method == "Ye" and object is GEE, stop with clear message referencing the independence assumption.
**Warning signs:** User confusion about which variance method to use with GEE.

## Code Examples

Verified patterns based on package documentation:

### glmgee Object Creation and Variance Extraction
```r
# Source: https://rdrr.io/cran/glmtoolbox/man/glmgee.html
# Requires glmtoolbox package

library(glmtoolbox)

# Fit GEE model with independence correlation (single-timepoint equivalent)
fit_gee <- glmgee(
  formula = aval ~ trtp + bl_cov,
  id = subject_id,
  family = binomial(link = "logit"),
  data = trial_data,
  corstr = "independence"
)

# Extract variance-covariance matrix - robust (default)
V_robust <- vcov(fit_gee, type = "robust")

# Extract with bias correction (Mancl-DeRouen)
V_bc <- vcov(fit_gee, type = "bias-corrected")

# DF-adjusted variance
V_df <- vcov(fit_gee, type = "df-adjusted")

# Model-based (naive) variance
V_model <- vcov(fit_gee, type = "model")

# Jackknife variance
V_jack <- vcov(fit_gee, type = "jackknife")
```

### geeglm Object Creation and Variance Extraction
```r
# Source: https://rdrr.io/cran/geepack/man/geeglm.html
# Requires geepack package

library(geepack)

# Fit GEE model
fit_gee <- geeglm(
  formula = aval ~ trtp + bl_cov,
  id = subject_id,
  family = binomial(link = "logit"),
  data = trial_data,
  corstr = "independence",
  std.err = "san.se"  # Robust sandwich SE (default)
)

# Extract variance-covariance matrix
# Note: vcov.geeglm returns variance based on std.err specified in fitting
V <- vcov(fit_gee)

# Alternative std.err options when fitting:
# std.err = "jack"   - Approximate jackknife
# std.err = "j1s"    - 1-step jackknife
# std.err = "fij"    - Fully iterated jackknife
```

### Predict Method Works Like GLM
```r
# Source: https://rdrr.io/cran/glmtoolbox/man/predict.glmgee.html
# Both glmgee and geeglm provide predict methods compatible with GLM

# Predict on response scale (same as beeca uses for GLM)
cf_pred <- predict(fit_gee, newdata = counterfactual_data, type = "response")

# predict.glmgee signature:
# predict(object, newdata, se.fit = FALSE, type = c("link", "response"),
#         varest = c("robust", "df-adjusted", "model", "bias-corrected"))
```

### Validation Pattern
```r
# Based on beeca's existing sanitize_model.glm pattern

sanitize_model.glmgee <- function(model, trt, ...) {
  # Package availability check
  if (!requireNamespace("glmtoolbox", quietly = TRUE)) {
    stop("glmtoolbox is required for glmgee objects. Install with install.packages('glmtoolbox')",
         call. = FALSE)
  }

  reasons_stop <- reasons_warn <- NULL

  # Validate family and link
  if (model$family$family != "binomial" | model$family$link != "logit") {
    reasons_stop <- c(reasons_stop,
                      "not in the binomial family with logit link function")
  }

  # Validate treatment variable
  sanitize_variable(model, trt)  # Reuse existing helper

  # Check for interactions (reuse existing GLM check)
  if (any(attr(model$terms, "order") > 1)) {
    interactions <- attr(model$terms, "term.labels")[which(attr(model$terms, "order") > 1)]
    if (trt %in% unlist(strsplit(interactions, ":"))) {
      reasons_stop <- c(reasons_stop,
                        "with treatment-covariate interaction terms")
    }
  }

  # GEE-specific: validate single-timepoint
  # Extract cluster ID and check all cluster sizes == 1
  # (Implementation details depend on glmgee object structure)

  # Print errors (match GLM pattern)
  if (!is.null(reasons_stop)) {
    msg_stop <- sapply(reasons_stop, function(x)
      c(sprintf("Model of class glmgee %s is not supported.", x), "\n"))
    stop(msg_stop, call. = FALSE)
  }

  if (!is.null(reasons_warn)) {
    for (msg_warn in reasons_warn) warning(msg_warn, call. = FALSE)
  }

  model$sanitized <- TRUE
  return(model)
}
```

## State of the Art

| Old Approach | Current Approach | When Changed | Impact |
|--------------|------------------|--------------|--------|
| gee package (unmaintained) | glmtoolbox::glmgee | 2023 (R Journal publication) | Modern implementation with comprehensive variance types, active maintenance |
| Single variance type in geepack | Multiple small-sample corrections | geepack 1.3.x series | Bias-corrected and jackknife options improve small-sample performance |
| Manual delta method for marginal effects | Built-in predict with varest parameter in glmgee | glmtoolbox development | Marginal effect SEs can be computed directly (though beeca uses g-computation) |

**Deprecated/outdated:**
- **gee package:** Original GEE implementation, now unmaintained. Both geepack and glmtoolbox are modern replacements.
- **Assuming GEE objects lack predict methods:** Both glmgee and geeglm inherit from glm and provide standard predict methods.
- **Manual sandwich variance computation:** GEE packages provide vcov methods; don't use sandwich::vcovHC for GEE objects.

## Open Questions

Things that couldn't be fully resolved:

1. **glmgee object structure for cluster ID extraction**
   - What we know: glmgee takes an `id` parameter in fitting, similar to geeglm
   - What's unclear: How to extract cluster ID from fitted glmgee object for validation
   - Recommendation: Inspect fitted glmgee object structure with str() on test object; check glmtoolbox source code if needed

2. **Convergence checking for glmgee**
   - What we know: geeglm explicitly removes `converged` attribute; convergence info in underlying geese object
   - What's unclear: Does glmgee retain convergence attribute or remove it like geeglm?
   - Recommendation: Test-driven development - fit glmgee model, inspect attributes, determine if convergence check is feasible

3. **Default variance type for GEE**
   - What we know: glmgee vcov defaults to "robust"; geeglm uses std.err specified during fitting (default "san.se")
   - What's unclear: Best default for beeca's GEE support given clinical trial context
   - Recommendation: Use "robust" as default (matches sandwich HC0 philosophy for GLM), document that bias-corrected may be better for small samples

4. **Full rank checking for GEE**
   - What we know: GLM validation checks `ncol(model.matrix(model)) != model$qr$rank`
   - What's unclear: Do glmgee/geeglm objects have $qr component? Alternative rank checking?
   - Recommendation: Inspect GEE object structure; if $qr missing, consider skipping rank check or finding GEE-equivalent

5. **Correlation structure validation necessity**
   - What we know: For single-timepoint (all cluster sizes = 1), correlation structure is meaningless
   - What's unclear: Should we validate correlation structure is set to "independence" or ignore it?
   - Recommendation: Ignore correlation structure for v0.4.0 since single-timepoint constraint makes it irrelevant; document that any correlation structure is acceptable when all clusters have size 1

## Sources

### Primary (HIGH confidence)
- [glmtoolbox vcov.glmgee documentation](https://rdrr.io/cran/glmtoolbox/man/vcov.glmgee.html) - Official CRAN documentation for glmgee variance types
- [geepack geeglm documentation](https://rdrr.io/cran/geepack/man/geeglm.html) - Official CRAN documentation for geeglm fitting
- [geepack source code (geeglm.R)](https://rdrr.io/cran/geepack/src/R/geeglm.R) - Source inspection revealing convergence attribute removal
- [predict.glmgee documentation](https://rdrr.io/cran/glmtoolbox/man/predict.glmgee.html) - Official prediction method signature
- [testthat skip documentation](https://testthat.r-lib.org/reference/skip.html) - skip_if_not_installed() for optional packages
- [glmtoolbox package page](https://rdrr.io/cran/glmtoolbox/) - Current version 0.1.12, July 2025 update

### Secondary (MEDIUM confidence)
- [Small Sample Performance of Bias-corrected Sandwich Estimators (PMC)](https://pmc.ncbi.nlm.nih.gov/articles/PMC4268228/) - Mancl-DeRouen bias correction performance
- [Adjusted predictions for GEE (Biometrics 2025)](https://academic.oup.com/biometrics/article/81/3/ujaf090/8211796) - Recent methodological developments in GEE marginal effects
- [geepack manual vignette](https://cran.r-project.org/web/packages/geepack/vignettes/geepack-manual.pdf) - Data sorting requirements, correlation structure warnings
- [Getting Started with GEE (UVA Library)](https://library.virginia.edu/data/articles/getting-started-with-generalized-estimating-equations) - Independence correlation structure and cluster size one considerations

### Tertiary (LOW confidence - flag for validation)
- [emmeans Issue #454](https://github.com/rvlenth/emmeans/issues/454) - Community discussion of glmtoolbox support, mentions package stability concerns with geepack
- Various StackOverflow/ResearchGate discussions about GEE with single observations per cluster - Community consensus but not authoritative

## Metadata

**Confidence breakdown:**
- Standard stack: HIGH - Both packages well-documented on CRAN with clear version history
- Architecture patterns: HIGH - beeca's existing S3 dispatch and pipeline architecture are well-established; GEE integration follows same patterns
- GEE variance types: HIGH - Official documentation clearly lists available types for glmtoolbox; geepack std.err options documented
- Object structure details: MEDIUM - Some attributes (convergence, cluster ID extraction) require empirical testing
- Single-timepoint validation: MEDIUM - Approach is clear but implementation details need object structure inspection
- Pitfalls: MEDIUM/HIGH - Most pitfalls documented in official package docs, some from community experience

**Research date:** 2026-02-07
**Valid until:** ~30 days (packages are stable; glmtoolbox updated July 2025, geepack updated October 2025)

**Key risks:**
- Object structure assumptions may need adjustment when implementing (empirical testing required)
- Convergence checking may differ between glmgee and geeglm (needs test-driven validation)
- Cluster ID extraction approach not verified for glmgee (requires package inspection)

**Mitigation:**
- Write tests early to validate object structure assumptions
- Use skip_if_not_installed() to make all GEE tests conditional
- Document assumptions explicitly in code comments for future reference
