# beeca v0.3.0 — Shipped

## What This Is

A release readiness review for beeca v0.3.0 — the R package for covariate-adjusted binary endpoint analysis has been validated, documented, polished, and released on GitHub. All tests pass, documentation is standardized, vignettes tell clear stories, and the package is ready for industry adoption.

## Core Value

All R CMD checks pass with no errors or warnings — the gate for v0.3.0 achieved.

## Requirements

### Validated

- ✓ Functional pipeline for marginal treatment effects — existing
- ✓ Two robust variance methods (Ge et al. 2011, Ye et al. 2023) — existing
- ✓ Five summary measures (diff, or, rr, logor, logrr) — existing
- ✓ S3 methods (print, summary, tidy, augment, plot) — existing
- ✓ ARD output format for pharmaceutical reporting — existing
- ✓ Test suite with testthat (80+ test cases) — existing
- ✓ Vignettes and pkgdown documentation — existing
- ✓ CI/CD via GitHub Actions — existing
- ✓ R CMD check passes with no errors/warnings — v0.3.0
- ✓ All tests pass (308 testthat tests, 88.9% coverage) — v0.3.0
- ✓ Documentation accurate and complete (25+ man pages standardized) — v0.3.0
- ✓ ARD vignette clear and informative with motivation scenario — v0.3.0
- ✓ Clinical trial reporting vignette with complete workflow — v0.3.0
- ✓ NEWS.md updated for v0.3.0 (tidyverse style) — v0.3.0
- ✓ Version bumped to 0.3.0 in DESCRIPTION — v0.3.0

### Active

(None — milestone complete. Next milestone will define new requirements.)

### Out of Scope

- CRAN submission — GitHub release only for v0.3.0
- GEE/longitudinal extension — feasibility confirmed (CONDITIONAL GO), deferred to future version
- Major refactoring — only issues found during review were fixed

## Context

**Package purpose:** Facilitate quick industry adoption of covariate-adjusted analyses in GxP environments for clinical trials with binary outcomes.

**Current state:** v0.3.0 shipped. 2,751 lines of R code, 308 tests passing, 88.9% coverage. Package validated against SAS %margins macro, {margins}, {marginaleffects}, and {RobinCar}.

**Key files:**
- `R/` — 20+ function files (beeca_fit, get_marginal_effect, S3 methods, ARD utilities)
- `vignettes/` — 3 polished vignettes with cross-references
- `tests/testthat/` — 12 test suites, 308 tests
- `man/` — 25+ standardized man pages

**Working group context:** Developed with ASA-BIOP Covariate Adjustment Scientific Working Group (carswg.github.io).

**GEE feasibility:** Conditional go for Option A (minimal, single-timepoint). Scoped at 3.5 days, 4 phases. See `.planning/phases/01.1-gee-longitudinal-feasibility/` for full report.

## Constraints

- **Tech stack**: R package following CRAN conventions
- **Compatibility**: Must maintain R >= 2.10 support as stated in DESCRIPTION
- **Dependencies**: Keep minimal — dplyr, sandwich, generics, lifecycle, rlang, stats

## Key Decisions

| Decision | Rationale | Outcome |
|----------|-----------|---------|
| GitHub release (not CRAN) | Faster iteration, less overhead | ✓ Good |
| Version 0.3.0 (minor bump) | New features since 0.2.0 warrant minor version | ✓ Good |
| Focus on vignette quality | ARD/reporting examples key for adoption | ✓ Good |
| trial02_cdisc as primary dataset | CDISC ADaM format, 3-arm design, industry standard | ✓ Good |
| trial01 retained for cross-validation | Pre-computed SAS results available | ✓ Good |
| Magirr et al. updated to published DOI | Published in Pharmaceutical Statistics 2025 | ✓ Good |
| beeca_to_cards_ard() 0% coverage accepted | Working in vignette, minimal value for timeline | ⚠️ Revisit |
| GEE extension conditional go (deferred) | Out of scope for v0.3.0, future version | — Pending |
| ggplot2 deprecation fixed | geom_errorbarh → geom_errorbar for ggplot2 4.0.0 | ✓ Good |
| Tidyverse-style NEWS.md | One-liner bullets, clear sections | ✓ Good |

---
*Last updated: 2026-02-07 after v0.3.0 milestone*
