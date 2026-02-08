# Phase 7: GEE Documentation - Research

**Researched:** 2026-02-08
**Domain:** R package documentation (roxygen2, vignettes, NEWS.md)
**Confidence:** HIGH

## Summary

This research investigates how to document GEE support for beeca users through a vignette, updated man pages, and NEWS.md entry. The package already has established documentation patterns: three existing vignettes using R Markdown with knitr, roxygen2-generated man pages following pharmaceutical industry standards, and a NEWS.md file tracking releases chronologically. The standard approach is to create a new vignette following the existing structure (clinical workflow narrative with code examples), update roxygen @param and @description sections in sanitize.R and estimate_varcov.R to mention GEE object support, and add a v0.4.0 section to NEWS.md listing GEE as the primary new feature.

The key technical challenges are: (1) writing a vignette that clearly explains when/why to use GEE models vs. standard GLM without overwhelming users, (2) updating existing roxygen docs to mention GEE support without breaking the flow for GLM users (majority use case), and (3) ensuring documentation examples use skip guards appropriately since glmtoolbox and geepack are in Suggests.

**Primary recommendation:** Create vignettes/gee-workflow.Rmd following the existing clinical-trial-table.Rmd structure, update roxygen @param object documentation in get_marginal_effect.R and estimate_varcov.R to mention supported GEE classes, document variance type constraints for GEE in estimate_varcov.R @details section, and add v0.4.0 section to NEWS.md with GEE feature bullet points.

## Standard Stack

The established tools for R package documentation:

### Core Documentation Framework
| Library | Version | Purpose | Why Standard |
|---------|---------|---------|--------------|
| roxygen2 | 7.3.2 | Inline R documentation | Used by virtually all CRAN packages, generates .Rd files from inline comments |
| knitr | Current | Dynamic document generation | Standard vignette engine specified in DESCRIPTION VignetteBuilder |
| rmarkdown | Current | R Markdown processing | Standard format for vignettes, integrates with knitr and pandoc |
| pkgdown | Current | Website generation from package docs | Creates https://openpharma.github.io/beeca/ from vignettes and man pages |

### Supporting Tools
| Library | Version | Purpose | When to Use |
|---------|---------|---------|-------------|
| devtools | Current | Documentation build/preview workflow | document() to rebuild .Rd files, build_vignettes() to preview |
| markdown | Current | NEWS.md rendering | pkgdown renders NEWS.md to website changelog |

**Installation:**
```bash
# Core already in DESCRIPTION
# VignetteBuilder: knitr
# Suggests: knitr, rmarkdown

# Development tools (not in DESCRIPTION)
# install.packages(c("devtools", "pkgdown"))
```

## Architecture Patterns

### Vignette Structure in beeca

beeca follows a consistent vignette pattern optimized for clinical trial statisticians:

**Existing vignettes:**
```
vignettes/
├── estimand_and_implementations.Rmd   # Get Started - theory and methods
├── clinical-trial-table.Rmd           # Application - creating tables
└── ard-cards-integration.Rmd          # Application - ARD interoperability
```

**Common structure:**
1. YAML header with title, VignetteIndexEntry, VignetteEngine, VignetteEncoding
2. Setup chunk with knitr opts and library() calls
3. Overview section (motivation and what the vignette covers)
4. Concept explanation (when needed)
5. Example dataset introduction
6. Step-by-step workflow with code chunks and output
7. Interpretation guidance
8. Cross-references to related vignettes
9. References section (if applicable)

**Pattern from clinical-trial-table.Rmd (most similar to GEE needs):**
```r
---
title: "Creating Clinical Trial Tables with beeca"
output: rmarkdown::html_vignette
vignette: >
  %\VignetteIndexEntry{Creating Clinical Trial Tables with beeca}
  %\VignetteEngine{knitr::rmarkdown}
  %\VignetteEncoding{UTF-8}
---

```{r, include = FALSE}
knitr::opts_chunk$set(
  collapse = TRUE,
  comment = "#>",
  fig.width = 7,
  fig.height = 5
)
```

## Overview

[Motivation paragraph explaining why this topic matters]

## Setup

```{r setup, message=FALSE, warning=FALSE}
library(beeca)
library(dplyr)
```

[Conditional library loads with eval guards]

## Example Dataset

[Introduce data, show structure]

## End-to-End Analysis

### Step 1: [First step]
### Step 2: [Second step]
...
```

**GEE vignette should follow this pattern:** Motivation → Setup → Dataset → Workflow → Interpretation → Cross-references

### Roxygen Documentation Patterns

**Current pattern for object parameter in get_marginal_effect.R:**
```r
#' @param object a fitted \link[stats]{glm} object.
```

**Pattern for documenting S3 method variants:**
- Generic function documents all possibilities
- Individual S3 methods can have their own documentation (currently sanitize_model.glmgee and sanitize_model.geeglm are marked @keywords internal)

**beeca roxygen conventions (from existing code):**
- Use @description for high-level purpose
- Use @details for technical explanations and caveats
- Use @param with type info and constraints
- Use @return with \tabular{} for complex objects
- Use @examples with executable code (may need \donttest{} for suggested packages)
- Use @references with full citations and DOIs
- Use @seealso for cross-references with \code{\link{}}

**Example from estimate_varcov.R:**
```r
#' @param type a string indicating the type of
#' variance estimator to use (only applicable for Ge's method). Supported types include HC0 (default),
#' model-based, HC3, HC, HC1, HC2, HC4, HC4m, and HC5. See \link[sandwich]{vcovHC} for heteroscedasticity-consistent estimators.
```

**For GEE update, this becomes:**
```r
#' @param type a string indicating the type of variance estimator to use
#' (only applicable for Ge's method).
#' For \code{glm} objects: Supported types include HC0 (default), model-based,
#' HC3, HC, HC1, HC2, HC4, HC4m, and HC5. See \link[sandwich]{vcovHC}.
#' For \code{glmgee} objects: Supported types include "robust" (default),
#' "bias-corrected", "df-adjusted".
#' For \code{geeglm} objects: Only "robust" is supported.
```

### NEWS.md Format

**Current pattern (from NEWS.md):**
```markdown
# beeca 0.3.0

## New Features

* `beeca_fit()`: Convenience function combining model fitting and marginal effect estimation.
* `plot_forest()`: Forest plots for visualizing treatment effects.
[... more bullets ...]

## Improvements

* Updated Magirr et al. reference from OSF preprint to published version.
[... more bullets ...]

## Bug Fixes

* Fixed function name conflict in `plot_forest()`.
[... more bullets ...]

# beeca 0.2.0

- Extensions to allow for more than two treatment arms.
```

**Conventions:**
- Newest version at top
- Version header with single # (h1)
- Subsections with ## (h2): New Features, Improvements, Bug Fixes
- Bullet lists with * (not -)
- Function names in backticks: `function_name()`
- Package names in curly braces: `{package}`
- Brief descriptions (1-2 sentences max per bullet)

**For v0.4.0:**
```markdown
# beeca 0.4.0

## New Features

* **GEE support**: `get_marginal_effect()` now accepts GEE objects from
  `{glmtoolbox}` (`glmgee`) and `{geepack}` (`geeglm`) for analyzing
  single-timepoint trials with cluster-randomized designs or within-subject
  correlation structures.
* GEE variance estimation via Ge et al. (2011) delta method using GEE's robust
  sandwich estimator.
* New S3 methods `sanitize_model.glmgee()` and `sanitize_model.geeglm()`
  validate GEE objects before analysis.

## Improvements

* Updated documentation to clarify variance estimator options for GLM vs. GEE objects.
* Enhanced error messages for GEE-specific validation failures.

[... existing sections from 0.3.0 below ...]
```

### Documentation Testing Pattern

**Pattern for vignette code:**
```r
# For packages in Suggests, use conditional evaluation:
```{r gee-example, eval=requireNamespace("glmtoolbox", quietly = TRUE)}
library(glmtoolbox)
# GEE code here
```

# Alternatively, for inline text:
if (requireNamespace("glmtoolbox", quietly = TRUE)) {
  # Show example
} else {
  message("Install glmtoolbox to run this example")
}
```

**Why:** Vignettes are built during R CMD check. If glmtoolbox/geepack aren't available, eval=FALSE prevents errors but shows code. CRAN build machines may not have all Suggests installed.

**From R Packages book:** "If you want all readers to see the code, but only readers with appropriate dependencies to run it, use eval=requireNamespace("pkg", quietly = TRUE)."

## Don't Hand-Roll

Problems with existing solutions:

| Problem | Don't Build | Use Instead | Why |
|---------|-------------|-------------|-----|
| Vignette workflow examples | Synthetic fake data | Adapt trial01 or trial02_cdisc with GEE structure | Users need to see real data patterns, continuity with existing vignettes |
| Roxygen documentation | Plain text descriptions | \link{}, \code{}, \doi{}, \tabular{} | Ensures cross-references work in pkgdown, help pages link correctly |
| NEWS.md format | Freeform prose | Structured sections (New Features, Improvements, Bug Fixes) with bullets | pkgdown parses this structure for changelog page |
| Man page updates | Manual .Rd file editing | roxygen2 inline comments + devtools::document() | Roxygen ensures consistency, reduces errors, easier maintenance |

**Key insight:** R package documentation has mature tooling (roxygen2, knitr, pkgdown). Use these tools as intended rather than fighting them. The existing beeca documentation is HIGH quality and follows best practices — replicate those patterns.

## Common Pitfalls

### Pitfall 1: Vignette Examples That Fail on CRAN
**What goes wrong:** Vignette uses glmgee without conditional evaluation guards. CRAN build fails because glmtoolbox isn't in Imports.

**Why it happens:** Vignettes are built during R CMD check. Suggested packages may not be installed on all CRAN flavors.

**How to avoid:** Use `eval=requireNamespace("pkg", quietly = TRUE)` in code chunks that require suggested packages:
```r
```{r gee-workflow, eval=requireNamespace("glmtoolbox", quietly = TRUE)}
library(glmtoolbox)
# GEE example code
```
```

**Warning signs:** Local vignette builds fine, R CMD check with --as-cran fails.

### Pitfall 2: Over-documenting Internal Implementation Details
**What goes wrong:** Roxygen documentation for estimate_varcov explains the delta method math step-by-step. Users are confused, documentation is cluttered.

**Why it happens:** Desire to be thorough and document how the code works.

**How to avoid:** User-facing documentation (@description, @details) explains WHAT and WHEN. Implementation details go in code comments or academic references.

**Pattern:**
```r
# GOOD:
#' @details For GEE objects, variance estimation uses the delta method with
#' GEE's robust sandwich estimator. See Ge et al. (2011) for methodology.

# BAD:
#' @details For GEE objects, we extract V_beta from vcov(), compute derivatives
#' d_i = (1/n) * sum(p_i * (1-p_i) * X_i), form D matrix, calculate V = D * V_beta * D^T,
#' [... 5 more lines of math ...]
```

**Warning signs:** @details section longer than @description section, equations in roxygen comments.

### Pitfall 3: Inconsistent NEWS.md Format Breaking pkgdown
**What goes wrong:** NEWS.md uses ### (h3) for version headers instead of # (h1). pkgdown changelog page shows empty content.

**Why it happens:** Markdown allows multiple header levels, easy to use wrong one.

**How to avoid:** Follow exact pattern from existing NEWS.md:
- Version: `# beeca 0.4.0` (h1)
- Sections: `## New Features` (h2)
- Bullets: `* Feature description` (asterisk, not dash)

**Warning signs:** pkgdown site changelog is malformed, version headers don't render correctly.

### Pitfall 4: Roxygen Links to Unexported Functions
**What goes wrong:** Documentation uses `\link{varcov_ge_gee}` to reference internal function. Help page shows broken link.

**Why it happens:** Internal functions aren't exported, so \link{} can't resolve them.

**How to avoid:** Only link to exported functions. Internal implementation can be mentioned in text without links:
```r
# GOOD:
#' For GEE objects, variance estimation uses the internal varcov_ge_gee
#' helper which applies the delta method to GEE's vcov output.

# BAD:
#' For GEE objects, variance estimation uses \link{varcov_ge_gee} which...
```

**Warning signs:** R CMD check warns "Missing link target: varcov_ge_gee", help page shows \[varcov_ge_gee\] in brackets.

### Pitfall 5: Vignette Narrative Assumes GEE Expertise
**What goes wrong:** GEE vignette starts with "GEE handles within-cluster correlation using working correlation matrices..." Most users have never heard of GEE and close the tab.

**Why it happens:** Writer has deep domain knowledge and forgets users may be encountering GEE for first time.

**How to avoid:** Start with the USER'S problem, not the TECHNICAL solution:
```markdown
# GOOD:
## When to Use GEE Models with beeca

If your trial has one of these characteristics, GEE models may be appropriate:
- Cluster randomization (e.g., randomize clinics, not individual patients)
- Matched pairs design
- Stratified randomization with very small strata

beeca now supports GEE objects from the glmtoolbox and geepack packages.

# BAD:
## GEE Theory

Generalized Estimating Equations (Liang & Zeger 1986) extend GLMs to
correlated data using quasi-likelihood estimation with working correlation
structures including independence, exchangeable, AR(1), and unstructured...
```

**Warning signs:** Vignette intro has citations before examples, technical jargon in first paragraph, no clear "you should read this if..." statement.

### Pitfall 6: Forgetting to Update _pkgdown.yml
**What goes wrong:** New vignette exists but doesn't appear in pkgdown website navigation. Users can't find it.

**Why it happens:** pkgdown doesn't auto-discover vignettes for custom navigation menus (only for default config).

**How to avoid:** Add new vignette to _pkgdown.yml articles section:
```yaml
articles:
- title: Get Started
  navbar: ~
  contents:
  - estimand_and_implementations

- title: Applications
  navbar: Applications
  contents:
  - clinical-trial-table
  - ard-cards-integration
  - gee-workflow  # ADD THIS
```

**Warning signs:** Vignette appears in help() but not on pkgdown website.

## Code Examples

### Pattern 1: Vignette YAML Header

```yaml
---
title: "Using GEE Models with beeca"
output: rmarkdown::html_vignette
vignette: >
  %\VignetteIndexEntry{Using GEE Models with beeca}
  %\VignetteEngine{knitr::rmarkdown}
  %\VignetteEncoding{UTF-8}
---
```

**Key points:**
- Title in quotes
- VignetteIndexEntry matches title (appears in vignette index)
- VignetteEngine: knitr::rmarkdown (matches DESCRIPTION VignetteBuilder)
- VignetteEncoding: UTF-8 (standard)

### Pattern 2: Vignette Setup Chunk

```r
```{r, include = FALSE}
knitr::opts_chunk$set(
  collapse = TRUE,
  comment = "#>",
  fig.width = 7,
  fig.height = 5
)
```

```{r setup, message=FALSE, warning=FALSE}
library(beeca)
library(dplyr)
```

```{r gee-setup, eval=requireNamespace("glmtoolbox", quietly = TRUE)}
library(glmtoolbox)
```
```

**Key points:**
- First chunk sets knitr options, include = FALSE hides it
- Second chunk loads core packages (always available)
- Third chunk loads suggested packages with eval guard

### Pattern 3: GEE Workflow Example

```r
## Example: Cluster-Randomized Trial

In this example, we analyze a hypothetical trial where clinics were randomized
to treatment arms. Each clinic enrolled multiple patients, creating within-cluster
correlation.

```{r gee-data, eval=requireNamespace("glmtoolbox", quietly = TRUE)}
# Create example data (in practice, use your trial data)
set.seed(123)
n_clusters <- 50
dat <- data.frame(
  clinic_id = 1:n_clusters,
  trtp = factor(rep(c("A", "B"), each = n_clusters/2)),
  bl_cov = rnorm(n_clusters),
  aval = rbinom(n_clusters, 1, 0.5)
)

# View data structure
head(dat)
```

```{r gee-fit, eval=requireNamespace("glmtoolbox", quietly = TRUE)}
# Fit GEE model accounting for cluster structure
fit_gee <- glmgee(
  aval ~ trtp + bl_cov,
  id = clinic_id,
  family = binomial(link = "logit"),
  data = dat,
  corstr = "independence"  # For single-timepoint data
)

# Estimate marginal treatment effect
result <- get_marginal_effect(
  fit_gee,
  trt = "trtp",
  method = "Ge",
  contrast = "diff",
  reference = "A"
)

# View results
result$marginal_results
```
```

### Pattern 4: Roxygen Update for object Parameter

**Before (current get_marginal_effect.R):**
```r
#' @param object a fitted \link[stats]{glm} object.
```

**After (GEE support added):**
```r
#' @param object a fitted model object. Supported types:
#'   \itemize{
#'     \item \code{\link[stats]{glm}} with binomial family and logit link
#'     \item \code{glmgee} from \code{\link[glmtoolbox]{glmgee}} (requires glmtoolbox package)
#'     \item \code{geeglm} from \code{\link[geepack]{geeglm}} (requires geepack package)
#'   }
#'   For GEE objects, only single-timepoint data (one observation per cluster)
#'   is currently supported.
```

### Pattern 5: Roxygen Update for estimate_varcov type Parameter

**Current estimate_varcov.R @param type:**
```r
#' @param type a string indicating the type of
#' variance estimator to use (only applicable for Ge's method). Supported types include HC0 (default),
#' model-based, HC3, HC, HC1, HC2, HC4, HC4m, and HC5. See \link[sandwich]{vcovHC} for heteroscedasticity-consistent estimators.
#' This parameter allows for flexibility in handling heteroscedasticity
#' and model specification errors.
```

**Updated with GEE info:**
```r
#' @param type a string indicating the type of variance estimator to use
#'   (only applicable for Ge's method). Supported types depend on the model class:
#'
#'   For \code{glm} objects:
#'   \itemize{
#'     \item HC0 (default) - Heteroscedasticity-consistent (White's estimator)
#'     \item model-based - Model-based variance
#'     \item HC1, HC2, HC3, HC4, HC4m, HC5 - Alternative HC estimators
#'   }
#'   See \link[sandwich]{vcovHC} for details.
#'
#'   For \code{glmgee} objects:
#'   \itemize{
#'     \item "robust" (default) - Robust sandwich estimator
#'     \item "bias-corrected" - Bias-corrected sandwich estimator
#'     \item "df-adjusted" - Degrees-of-freedom adjusted estimator
#'   }
#'
#'   For \code{geeglm} objects:
#'   \itemize{
#'     \item "robust" (only option) - Robust sandwich estimator
#'   }
#'
#'   Passing a GLM-style type (e.g., "HC0") to a GEE object will produce an
#'   informative error listing valid GEE types.
```

### Pattern 6: NEWS.md Entry

```markdown
# beeca 0.4.0

## New Features

* **GEE support**: `get_marginal_effect()` now accepts GEE objects from
  `{glmtoolbox}` (`glmgee`) and `{geepack}` (`geeglm`) for analyzing
  single-timepoint trials with cluster-randomized designs or correlation structures.
  Only the Ge et al. (2011) variance method is supported for GEE; the Ye et al. (2023)
  method assumes independence and is not applicable.

* `sanitize_model.glmgee()` and `sanitize_model.geeglm()`: New S3 methods validate
  GEE objects, ensuring binomial family, logit link, and single-timepoint data
  (one observation per cluster).

* GEE variance estimation uses the delta method with GEE's robust sandwich
  estimator via `vcov()`. For `glmgee` objects, supported variance types are
  "robust" (default), "bias-corrected", and "df-adjusted". For `geeglm` objects,
  only "robust" is supported.

## Improvements

* Enhanced `estimate_varcov()` documentation to clarify variance type options
  for GLM vs. GEE objects. Passing a GLM-style variance type (e.g., "HC0") to
  a GEE object now produces a clear error message listing valid GEE types.

* Updated `get_marginal_effect()` and `estimate_varcov()` documentation to list
  supported model classes (`glm`, `glmgee`, `geeglm`).

## Documentation

* New vignette: "Using GEE Models with beeca" demonstrates end-to-end workflow
  for cluster-randomized trials and explains when GEE models are appropriate.

# beeca 0.3.0

[... existing content ...]
```

## State of the Art

| Old Approach | Current Approach | When Changed | Impact |
|--------------|------------------|--------------|--------|
| Separate .Rd files in man/ | roxygen2 inline documentation | roxygen2 maturity (~2010) | Documentation lives with code, reduced errors, easier maintenance |
| Static vignettes in inst/doc | Dynamic R Markdown vignettes | knitr introduction (2012) | Executable examples, always up-to-date with code changes |
| Plain text NEWS file | Markdown NEWS.md with structured sections | pkgdown adoption (~2017) | Changelog rendered beautifully on package website |
| \dontrun{} for conditional examples | eval= in vignette chunks | knitr maturity | Better control, code still visible when skipped |

**Deprecated/outdated:**
- Manual .Rd files: Use roxygen2 instead
- Sweave (.Rnw) vignettes: Use R Markdown (.Rmd) instead
- NEWS in plain text: Use NEWS.md for pkgdown compatibility
- \dontrun{} for suggested package examples: Use conditional eval= in vignettes

## Open Questions

### Question 1: Should the GEE vignette include simulation to show why GEE variance differs from GLM?

**What we know:** GEE and GLM produce same point estimates but different standard errors when data has correlation structure. A simulation could demonstrate this.

**What's unclear:** Whether beeca vignette should teach GEE theory or just show how to use the package.

**Recommendation:** NO simulation. Rationale: (1) beeca is a tool package, not a tutorial package, (2) users consulting this vignette already know they need GEE (referred by statistician or protocol), (3) existing vignettes don't include simulations, maintain consistency. Brief conceptual explanation is sufficient: "GEE accounts for within-cluster correlation, producing correct standard errors."

### Question 2: Should roxygen examples use \donttest{} for GEE examples?

**What we know:** GEE examples require glmtoolbox/geepack from Suggests. Examples are run during R CMD check. \donttest{} prevents execution during check.

**What's unclear:** Whether to use \donttest{} or rely on conditional skip in examples.

**Recommendation:** Use \donttest{} for GEE examples in roxygen. Rationale: (1) Examples must be runnable by users who DO have the package, (2) \donttest{} shows code without running during check, (3) avoids conditional if-else logic cluttering examples. Pattern:
```r
#' @examples
#' # Standard GLM example (always runs)
#' fit <- glm(aval ~ trtp + bl_cov, family = binomial, data = trial01)
#' get_marginal_effect(fit, trt = "trtp")
#'
#' \donttest{
#' # GEE example (requires glmtoolbox)
#' library(glmtoolbox)
#' fit_gee <- glmgee(aval ~ trtp + bl_cov, id = id, ...)
#' get_marginal_effect(fit_gee, trt = "trtp")
#' }
```

### Question 3: Should sanitize_model generic roxygen docs list all S3 methods?

**What we know:** sanitize_model is currently @keywords internal. The S3 methods (sanitize_model.glm, sanitize_model.glmgee, sanitize_model.geeglm) are also @keywords internal.

**What's unclear:** Whether to promote sanitize_model to user-facing (@export) now that GEE support exists, or keep it internal.

**Recommendation:** Keep @keywords internal. Rationale: (1) Users don't call sanitize_model directly, it's called by get_marginal_effect, (2) Making it exported would require full user-facing documentation, (3) Current pattern works fine, no user complaints. The GEE-specific S3 methods can remain internal with basic documentation.

## Sources

### Primary (HIGH confidence)
- beeca codebase vignettes/ - Existing vignette patterns and structure
- beeca codebase R/sanitize.R, R/estimate_varcov.R - Existing roxygen patterns
- beeca codebase NEWS.md - Existing NEWS format and conventions
- beeca codebase _pkgdown.yml - Website structure and article organization
- [R Packages (2e) - Documentation](https://r-pkgs.org/man.html) - Roxygen2 best practices
- [R Packages (2e) - Vignettes](https://r-pkgs.org/vignettes.html) - Vignette best practices
- [roxygen2 7.3.2 Manual](https://cran.r-project.org/web/packages/roxygen2/roxygen2.pdf) - Tag reference

### Secondary (MEDIUM confidence)
- beeca Phase 5 and 6 research - GEE implementation details to document
- [knitr chunk options](https://yihui.org/knitr/options/) - Conditional evaluation with eval=
- [pkgdown configuration](https://pkgdown.r-lib.org/reference/build_articles.html) - Article organization

### Tertiary (LOW confidence)
- None (all research used authoritative sources)

## Metadata

**Confidence breakdown:**
- Vignette structure: HIGH - Three existing vignettes provide clear pattern
- Roxygen patterns: HIGH - Extensive existing documentation to follow
- NEWS.md format: HIGH - Established pattern in codebase
- GEE content details: MEDIUM - Must balance technical accuracy with user accessibility

**Research date:** 2026-02-08
**Valid until:** 90 days (R documentation tooling is stable; beeca patterns are established)
