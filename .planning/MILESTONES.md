# Project Milestones: beeca

## v0.4.0 GEE Extension (Shipped: 2026-02-08)

**Delivered:** GEE objects (glmgee, geeglm) flow through beeca's g-computation pipeline with correct variance estimation for single-timepoint covariate-adjusted binary endpoint analysis.

**Phases completed:** 5-7 (4 plans total)

**Key accomplishments:**

- GEE objects (glmgee from glmtoolbox, geeglm from geepack) accepted via new S3 validation methods
- Ge delta method variance estimation routes to GEE's own vcov with 3 variance types for glmgee (robust, bias-corrected, df-adjusted)
- Manual delta method cross-validation confirms correctness to 1e-10 tolerance
- 60 new test assertions (368 total), 0 regressions, R CMD check clean (0 errors, 0 warnings)
- Complete documentation: GEE workflow vignette, updated man pages, NEWS.md, pkgdown navigation

**Stats:**

- 14 source files created/modified (+1,184 / -39 lines)
- 3,093 lines of R code total
- 3 phases, 4 plans, 8 source commits
- 2 days from start to ship (2026-02-07 to 2026-02-08)
- Total execution time: 15.46 minutes

**Git range:** `dd275a1` (add GEE packages to Suggests) → `4625eb7` (complete documentation phase)

**What's next:** v0.5.0 ARD improvements (test coverage, confidence intervals, metadata enrichment, converter infrastructure)

---

## v0.3.0 GitHub Release Readiness (Shipped: 2026-02-07)

**Delivered:** Release-ready beeca v0.3.0 with validated build, standardized documentation, polished vignettes, and complete release artifacts for GitHub release.

**Phases completed:** 1-4 plus 1.1 (11 plans total)

**Key accomplishments:**

- Validated build integrity: 0 errors, 0 warnings, 308 tests passing, 88.9% coverage
- Standardized all roxygen2 documentation with complete DOI citations and cross-references
- Polished 3 vignettes with motivation-driven storytelling and cross-vignette navigation
- Completed GEE longitudinal feasibility research (CONDITIONAL GO for future version)
- Updated all Magirr et al. references from OSF preprint to published DOI (Pharmaceutical Statistics 2025)
- Created release branch with clean R CMD check and user approval

**Stats:**

- 44 package files created/modified (+5,451 lines, -73 lines)
- 2,751 lines of R code
- 5 phases, 11 plans
- 8 days from start to ship (2026-01-31 to 2026-02-07)
- Total execution time: 103 minutes across 11 plans

**Git range:** `81a4f0f` → `95ad701`

**What's next:** v0.4.0 GEE Extension

---
