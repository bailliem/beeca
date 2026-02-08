---
phase: 07-gee-documentation
plan: 01
subsystem: documentation
status: complete
completed: 2026-02-08

requires:
  - 05-gee-core (GEE implementation)
  - 06-gee-testing (validated GEE functionality)

provides:
  - GEE workflow vignette with glmtoolbox and geepack examples
  - Updated roxygen documentation for GEE support in get_marginal_effect and estimate_varcov
  - v0.4.0 release notes in NEWS.md
  - pkgdown navigation for GEE vignette

affects:
  - Phase 08 (v0.4.0 release preparation will reference this documentation)

tech-stack:
  added: []
  patterns:
    - vignette documentation with conditional evaluation guards
    - comprehensive roxygen with per-class parameter documentation

key-files:
  created:
    - vignettes/gee-workflow.Rmd
  modified:
    - R/get_marginal_effect.R
    - R/estimate_varcov.R
    - NEWS.md
    - _pkgdown.yml
    - man/get_marginal_effect.Rd
    - man/estimate_varcov.Rd

decisions:
  - DOC-01: Vignette uses eval guards for glmtoolbox and geepack chunks
  - DOC-02: Roxygen documents all three GEE variance types (robust, bias-corrected, df-adjusted)
  - DOC-03: NEWS.md follows existing format (bullets with *, subsections, references to functions)

metrics:
  duration: 4.56 minutes
  tasks_completed: 2
  commits: 2
  files_changed: 7
---

# Phase 07 Plan 01: GEE Documentation Summary

**One-liner:** Complete end-user documentation for GEE support (vignette, roxygen, NEWS) enabling discovery and usage through standard R documentation channels

## What Was Built

### Vignette: Using GEE Models with beeca

Created `vignettes/gee-workflow.Rmd` following the structure of `clinical-trial-table.Rmd`:

- **Overview**: Explains when GEE models are appropriate (cluster randomization, within-subject correlation)
- **Setup**: Load beeca, dplyr; install glmtoolbox/geepack if needed
- **Example Data**: Uses trial01 with added cluster ID (site_id), explains single-timepoint structure
- **glmtoolbox workflow**: Complete example with glmgee model fitting and marginal effect estimation
- **Interpreting Results**: Shows marginal_est, marginal_se, marginal_results structure
- **Variance Types**: Demonstrates robust, bias-corrected, df-adjusted with comparison table
- **geepack workflow**: Equivalent workflow with geeglm
- **Key Differences**: Bullet list of GEE vs GLM differences (method restriction, variance types, data structure)
- **References**: Ge et al. (2011), Ye et al. (2023), Magirr et al. (2025)

All code chunks use `eval=requireNamespace("glmtoolbox", quietly = TRUE)` guards to prevent build failures when packages not installed.

### Roxygen Updates

**R/get_marginal_effect.R:**
- Updated `@description` to mention GEE models
- Replaced `@param object` with itemized list of supported types (glm, glmgee, geeglm)
- Added single-timepoint note for GEE objects
- Updated `@param method` to note only Ge supported for GEE
- Updated `@param type` to document GEE variance types per class
- Updated `@return` to "model object (of the same class as the input)"
- Added `@details` paragraph explaining GEE method restriction and default variance type
- Added GEE example in `\donttest{}` block using glmtoolbox

**R/estimate_varcov.R:**
- Updated `@description` to "GLM or GEE model object"
- Updated `@param object` to list glm, glmgee, geeglm
- Replaced `@param type` with comprehensive per-class documentation:
  - glm: HC0 (default), model-based, HC1-HC5
  - glmgee: robust (default), bias-corrected, df-adjusted
  - geeglm: robust (only option)
  - Note about informative error when passing GLM types to GEE
- Updated `@param method` to note Ye not valid for GEE
- Added `@details` paragraph on GEE variance estimation using vcov()
- Updated `@return` to "model object (of the same class as the input)"

### NEWS.md v0.4.0

Prepended NEWS.md with v0.4.0 section following existing format:

**New Features:**
- GEE support in get_marginal_effect() for glmgee and geeglm objects
- sanitize_model.glmgee() and sanitize_model.geeglm() S3 methods
- GEE variance estimation details (delta method with vcov(), variance types per class)

**Documentation:**
- New vignette "Using GEE Models with beeca"
- Updated get_marginal_effect() and estimate_varcov() documentation

### pkgdown Navigation

Updated `_pkgdown.yml` articles section with new "GEE Extension" title containing gee-workflow.

## Task Commits

| Task | Description | Commit | Files |
|------|-------------|--------|-------|
| 1 | Create GEE workflow vignette | 76f5c8d | vignettes/gee-workflow.Rmd, _pkgdown.yml |
| 2 | Update roxygen and NEWS for GEE support | 85e41ce | R/get_marginal_effect.R, R/estimate_varcov.R, NEWS.md, man/*.Rd |

## Deviations from Plan

None - plan executed exactly as written.

## Verification Results

All verification checks passed:

1. ✅ `rmarkdown::render('vignettes/gee-workflow.Rmd')` - vignette builds
2. ✅ `devtools::document()` - man pages regenerate without errors
3. ✅ Grep for "glmgee" in man/get_marginal_effect.Rd - found (4 occurrences)
4. ✅ Grep for "bias-corrected" in man/estimate_varcov.Rd - found (1 occurrence)
5. ✅ Grep for "gee-workflow" in _pkgdown.yml - found
6. ✅ NEWS.md first line contains "beeca 0.4.0" - confirmed

## Self-Check: PASSED

Created files exist:
- ✅ vignettes/gee-workflow.Rmd

Commits exist:
- ✅ 76f5c8d
- ✅ 85e41ce

## Decisions Made

**DOC-01: Vignette evaluation guards**
- Used `eval=requireNamespace("glmtoolbox", quietly = TRUE)` for all glmtoolbox chunks
- Used `eval=requireNamespace("geepack", quietly = TRUE)` for geepack chunks
- Prevents vignette build failures when suggested packages not installed
- Follows pattern from clinical-trial-table.Rmd

**DOC-02: Comprehensive variance type documentation**
- Documented all three glmgee variance types (robust, bias-corrected, df-adjusted)
- Documented geeglm single variance type (robust only)
- Added note about informative error when passing GLM types to GEE
- Uses itemized lists for clarity

**DOC-03: NEWS.md format consistency**
- Followed existing format: bullets with *, ## subsections, references to {package} and function()
- Placed GEE support as primary new feature in v0.4.0
- Included both New Features and Documentation sections

## Issues & Resolutions

**Issue:** Vignette rendering failed with "Model of class glmgee is not supported"
**Cause:** Using installed beeca version (without GEE methods) instead of development version
**Resolution:** Used `devtools::load_all()` before `rmarkdown::render()` to use development code

## Requirements Satisfied

- ✅ **DOC-01**: Vignette demonstrates glmgee and geeglm workflows with variance type comparison
- ✅ **DOC-02**: help(get_marginal_effect) lists glmgee and geeglm as accepted types
- ✅ **DOC-03**: help(estimate_varcov) documents robust/bias-corrected/df-adjusted for glmgee, robust for geeglm
- ✅ **DOC-04** (implicit in must_haves): NEWS.md v0.4.0 section documents GEE as primary feature

All plan must_haves satisfied:
- ✅ User searching for GEE support finds gee-workflow vignette via pkgdown
- ✅ Vignette runs complete glmgee example (data setup, model fitting, get_marginal_effect, interpretation)
- ✅ help(get_marginal_effect) lists glmgee and geeglm as accepted object types
- ✅ help(estimate_varcov) documents valid variance types per model class
- ✅ NEWS.md shows v0.4.0 with GEE support as primary new feature

## Next Phase Readiness

Phase 07 (GEE Documentation) is complete. All v0.4.0 work finished:
- Phase 05: GEE core implementation ✅
- Phase 06: GEE testing ✅
- Phase 07: GEE documentation ✅

**Ready for v0.4.0 release preparation** (if planned as Phase 08) or next feature work.

**Recommended next steps:**
1. Install beeca development version to make GEE methods available: `devtools::install()`
2. Build pkgdown site to verify vignette renders correctly: `pkgdown::build_site()`
3. Tag v0.4.0 release if ready for CRAN submission

## Technical Notes

### Vignette Structure
- Follows clinical-trial-table.Rmd pattern exactly
- Uses requireNamespace guards for optional dependencies
- Explains WHY (when to use GEE) before HOW (technical details)
- Includes complete working examples with trial01 data

### Roxygen Patterns
- Per-class parameter documentation using itemized lists
- Consistent use of \code{class} and \link{function}
- Notes about method/type restrictions appear inline with parameter docs
- GEE examples in \donttest{} to avoid CRAN check issues with suggested packages

### Documentation Completeness
- Vignette cross-references existing vignettes (estimand_and_implementations, clinical-trial-table)
- Man pages cross-reference each other (get_marginal_effect <-> estimate_varcov)
- NEWS.md references specific functions and packages with proper formatting
- All three documentation channels (vignette, man pages, NEWS) consistent
