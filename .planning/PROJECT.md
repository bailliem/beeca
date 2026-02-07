# beeca — GEE Extension

## What This Is

beeca is an R package for covariate-adjusted binary endpoint analysis in clinical trials. v0.4.0 extends the package to accept GEE (Generalized Estimating Equations) objects for single-timepoint covariate-adjusted analysis, broadening beeca's applicability to clustered/correlated data designs while preserving its focused, GxP-compliant identity.

## Core Value

GEE objects flow through beeca's existing g-computation pipeline with correct variance estimation — no regressions in existing GLM functionality.

## Requirements

### Validated

- ✓ Functional pipeline for marginal treatment effects — existing
- ✓ Two robust variance methods (Ge et al. 2011, Ye et al. 2023) — existing
- ✓ Five summary measures (diff, or, rr, logor, logrr) — existing
- ✓ S3 methods (print, summary, tidy, augment, plot) — existing
- ✓ ARD output format for pharmaceutical reporting — existing
- ✓ Test suite with testthat (308 tests, 88.9% coverage) — v0.3.0
- ✓ Vignettes and pkgdown documentation — v0.3.0
- ✓ CI/CD via GitHub Actions — existing
- ✓ R CMD check passes with no errors/warnings — v0.3.0
- ✓ Documentation accurate and complete (25+ man pages) — v0.3.0

### Active

- [ ] GEE objects accepted via sanitize_model S3 methods (glmgee, geeglm)
- [ ] Ge delta method variance estimation routes to GEE's own vcov
- [ ] Full pipeline works end-to-end for GEE objects (predict, average, varcov, contrast)
- [ ] All five contrast types work with GEE objects
- [ ] Tests for GEE extension with cross-validation
- [ ] Documentation for GEE usage (man pages, vignette or vignette section)
- [ ] R CMD check passes with no errors/warnings

### Out of Scope

- Multi-timepoint longitudinal GEE — requires companion package (beecal), not beeca's scope
- Ye et al. method for GEE — assumes independence, not extensible for correlated data
- CRAN submission — GitHub release only for v0.4.0
- ARD improvements — deferred to v0.5.0 milestone
- Major refactoring — surgical changes only

## Current Milestone: v0.4.0 GEE Extension

**Goal:** Accept GEE objects (glmgee from glmtoolbox, geeglm from geepack) for single-timepoint covariate-adjusted binary endpoint analysis using the Ge delta method.

**Target features:**
- sanitize_model.glmgee() and sanitize_model.geeglm() S3 methods
- Variance estimation routing to GEE's own vcov (robust, bias-corrected, df-adjusted)
- End-to-end pipeline: GEE object through predict_counterfactuals, average_predictions, estimate_varcov, apply_contrast
- Comprehensive tests and documentation

## Context

**Package purpose:** Facilitate quick industry adoption of covariate-adjusted analyses in GxP environments for clinical trials with binary outcomes.

**Current state:** v0.3.0 shipped. 2,751 lines of R code, 308 tests passing, 88.9% coverage. Package validated against SAS %margins macro, {margins}, {marginaleffects}, and {RobinCar}.

**GEE feasibility (completed):** Conditional go for Option A (minimal, single-timepoint). Empirical tests confirm predict(newdata) and vcov() work for both glmgee and geeglm. Pipeline needs 2-3 targeted changes. See `.planning/phases/01.1-gee-longitudinal-feasibility/` for full report.

**Key findings from feasibility:**
- predict(newdata, type='response') works for both GEE packages
- vcov(type='robust') works for both GEE packages
- sanitize_model needs new S3 methods (currently rejects GEE objects)
- estimate_varcov needs routing to GEE vcov instead of sandwich::vcovHC
- Ye method NOT extensible for GEE (assumes independence)
- Manual Ge delta method test produced valid results

**Key files:**
- `R/sanitize.R` — S3 generic, needs glmgee/geeglm methods
- `R/estimate_varcov.R` — Needs GEE variance routing
- `R/predict_counterfactuals.R` — Will work once sanitize extended
- `R/average_predictions.R` — Will work once predict_counterfactuals works
- `.planning/phases/01.1-gee-longitudinal-feasibility/feasibility-test.R` — Empirical test script

**Working group context:** Developed with ASA-BIOP Covariate Adjustment Scientific Working Group (carswg.github.io).

**Future milestone (v0.5.0):** ARD improvements — test coverage for beeca_to_cards_ard(), confidence intervals, metadata enrichment, converter infrastructure.

## Constraints

- **Tech stack**: R package following CRAN conventions
- **Compatibility**: Must maintain R >= 2.10 support as stated in DESCRIPTION
- **Dependencies**: Keep minimal — add glmtoolbox and geepack to Suggests (not Imports)
- **Backward compatibility**: All 308 existing tests must continue to pass
- **Scope**: Single-timepoint GEE only — no multi-timepoint longitudinal support

## Key Decisions

| Decision | Rationale | Outcome |
|----------|-----------|---------|
| GitHub release (not CRAN) | Faster iteration, less overhead | ✓ Good |
| trial02_cdisc as primary dataset | CDISC ADaM format, 3-arm design, industry standard | ✓ Good |
| Magirr et al. updated to published DOI | Published in Pharmaceutical Statistics 2025 | ✓ Good |
| GEE Option A (minimal, single-timepoint) | Preserves beeca identity, feasibility confirmed | — Pending |
| Ye method excluded for GEE | Assumes independence, not valid for correlated data | — Pending |
| GEE packages in Suggests (not Imports) | Keep beeca lightweight, GEE is optional capability | — Pending |
| v0.4.0 GEE, v0.5.0 ARD | Separate milestones for cleaner scope and testing | — Pending |

---
*Last updated: 2026-02-07 after v0.4.0 milestone start*
