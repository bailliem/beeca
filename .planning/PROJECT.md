# beeca — Covariate-Adjusted Binary Endpoint Analysis

## What This Is

beeca is an R package for covariate-adjusted binary endpoint analysis in clinical trials. Supports both standard GLM and GEE (Generalized Estimating Equations) models for single-timepoint analysis, enabling covariate adjustment for both independent and clustered/correlated data designs while maintaining GxP compliance.

## Core Value

Marginal treatment effects from covariate-adjusted models with correct robust variance estimation — for both GLM and GEE objects, through a single g-computation pipeline.

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
- ✓ GEE objects accepted via sanitize_model S3 methods (glmgee, geeglm) — v0.4.0
- ✓ Ge delta method variance estimation routes to GEE's own vcov — v0.4.0
- ✓ Full pipeline works end-to-end for GEE objects (predict, average, varcov, contrast) — v0.4.0
- ✓ All five contrast types work with GEE objects — v0.4.0
- ✓ Tests for GEE extension with cross-validation (368 tests, 0 regressions) — v0.4.0
- ✓ Documentation for GEE usage (vignette, man pages, NEWS.md) — v0.4.0
- ✓ R CMD check passes with no errors/warnings (v0.4.0) — v0.4.0

### Active

(None — next milestone requirements to be defined)

### Out of Scope

- Multi-timepoint longitudinal GEE — requires companion package (beecal), not beeca's scope
- Ye et al. method for GEE — assumes independence, not extensible for correlated data
- Major refactoring — surgical changes only

## Context

**Package purpose:** Facilitate quick industry adoption of covariate-adjusted analyses in GxP environments for clinical trials with binary outcomes.

**Current state:** v0.4.0 shipped. 3,093 lines of R code, 368 tests passing, R CMD check clean (0 errors, 0 warnings). GEE support validated via manual delta method cross-validation to 1e-10 tolerance. Package validated against SAS %margins macro, {margins}, {marginaleffects}, and {RobinCar}.

**Shipped versions:**
- v0.3.0 (2026-02-07): GitHub release readiness — build validation, documentation polish, vignette review, release preparation
- v0.4.0 (2026-02-08): GEE extension — S3 validation, variance routing, testing, documentation

**Working group context:** Developed with ASA-BIOP Covariate Adjustment Scientific Working Group (carswg.github.io).

**Future milestone (v0.5.0):** ARD improvements — test coverage for beeca_to_cards_ard(), confidence intervals, metadata enrichment, converter infrastructure.

## Constraints

- **Tech stack**: R package following CRAN conventions
- **Compatibility**: Must maintain R >= 2.10 support as stated in DESCRIPTION
- **Dependencies**: Keep minimal — glmtoolbox and geepack in Suggests (not Imports)
- **Backward compatibility**: All existing tests must continue to pass
- **GEE scope**: Single-timepoint GEE only — no multi-timepoint longitudinal support

## Key Decisions

| Decision | Rationale | Outcome |
|----------|-----------|---------|
| GitHub release (not CRAN) | Faster iteration, less overhead | ✓ Good |
| trial02_cdisc as primary dataset | CDISC ADaM format, 3-arm design, industry standard | ✓ Good |
| Magirr et al. updated to published DOI | Published in Pharmaceutical Statistics 2025 | ✓ Good |
| GEE Option A (minimal, single-timepoint) | Preserves beeca identity, feasibility confirmed | ✓ Good |
| Ye method excluded for GEE | Assumes independence, not valid for correlated data | ✓ Good |
| GEE packages in Suggests (not Imports) | Keep beeca lightweight, GEE is optional capability | ✓ Good |
| v0.4.0 GEE, v0.5.0 ARD | Separate milestones for cleaner scope and testing | ✓ Good |
| GEE default variance type "robust" | Matches sandwich HC0 philosophy, most common choice | ✓ Good |
| glmgee: 3 variance types | Matches glmtoolbox vcov() API (robust, bias-corrected, df-adjusted) | ✓ Good |
| geeglm: robust only | Native geepack sandwich SE, only option available | ✓ Good |
| Manual delta method cross-validation | Independent correctness verification for GEE variance | ✓ Good |

---
*Last updated: 2026-02-08 after v0.4.0 milestone*
