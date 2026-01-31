# beeca v0.3.0 Release Readiness

## What This Is

A release readiness review for beeca v0.3.0 — ensuring the R package for covariate-adjusted binary endpoint analysis is ready for GitHub release. Focus areas: tests passing, documentation accuracy, code quality, and vignette clarity (especially ARD and clinical trial reporting examples).

## Core Value

All R CMD checks pass with no errors or warnings — the gate for tagging v0.3.0.

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

### Active

- [ ] R CMD check passes with no errors/warnings
- [ ] All tests pass (testthat suite)
- [ ] Documentation is accurate and complete
- [ ] Code quality is consistent across package
- [ ] ARD vignette is clear and informative
- [ ] Clinical trial reporting vignette tells a good story
- [ ] NEWS.md updated for v0.3.0
- [ ] Version bumped to 0.3.0 in DESCRIPTION

### Out of Scope

- CRAN submission — this is GitHub release only
- New features — review and polish existing functionality
- Major refactoring — only fix issues found during review

## Context

**Package purpose:** Facilitate quick industry adoption of covariate-adjusted analyses in GxP environments for clinical trials with binary outcomes.

**Current state:** Functioning package with core statistical methods implemented. Has been cross-validated against SAS %margins macro, {margins}, {marginaleffects}, and {RobinCar}.

**Key files for review:**
- `vignettes/` — especially ARD and clinical trial reporting vignettes
- `tests/testthat/` — 12 test suites
- `R/` — 20+ function files
- `man/` — generated documentation

**Working group context:** Developed with ASA-BIOP Covariate Adjustment Scientific Working Group (carswg.github.io).

## Constraints

- **Tech stack**: R package following CRAN conventions
- **Compatibility**: Must maintain R >= 2.10 support as stated in DESCRIPTION
- **Dependencies**: Keep minimal — dplyr, sandwich, generics, lifecycle, rlang, stats

## Key Decisions

| Decision | Rationale | Outcome |
|----------|-----------|---------|
| GitHub release (not CRAN) | Faster iteration, less overhead | — Pending |
| Version 0.3.0 (minor bump) | New features since 0.2.0 warrant minor version | — Pending |
| Focus on vignette quality | ARD/reporting examples are key for adoption | — Pending |

---
*Last updated: 2026-01-31 after initialization*
