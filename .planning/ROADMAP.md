# Roadmap: beeca v0.4.0 GEE Extension

## Milestones

- v0.3.0 GitHub Release Readiness (Shipped: 2026-02-07) -- archived to `.planning/milestones/v0.3.0-ROADMAP.md`
- v0.4.0 GEE Extension (Complete: 2026-02-08) -- Phases 5-7

## Overview

v0.4.0 extends beeca to accept GEE objects (glmgee from glmtoolbox, geeglm from geepack) for single-timepoint covariate-adjusted binary endpoint analysis. The work is surgical: add S3 validation methods, route variance estimation to GEE's own vcov, verify the existing pipeline flows through, then validate with tests and documentation. Three phases deliver the complete capability: core implementation, testing, and documentation.

## Phases

- [x] **Phase 5: GEE Core Implementation** - S3 validation methods, variance routing, and end-to-end pipeline for GEE objects
- [x] **Phase 6: GEE Testing** - Comprehensive test suite, regression validation, R CMD check
- [x] **Phase 7: GEE Documentation** - Vignette, man pages, NEWS.md for v0.4.0

## Phase Details

### Phase 5: GEE Core Implementation
**Goal**: GEE objects (glmgee and geeglm) flow through beeca's full pipeline and produce correct marginal treatment effect estimates with robust variance
**Depends on**: Phase 4 (v0.3.0 shipped)
**Requirements**: VALID-01, VALID-02, VALID-03, VAR-01, VAR-02, VAR-03, VAR-04, VAR-05, PIPE-01, PIPE-02, PIPE-03, PIPE-04
**Success Criteria** (what must be TRUE):
  1. A glmgee object fitted with glmtoolbox passes through sanitize_model and get_marginal_effect returns marginal treatment effect estimates for all five contrast types
  2. A geeglm object fitted with geepack passes through sanitize_model and get_marginal_effect returns marginal treatment effect estimates for all five contrast types
  3. estimate_varcov with a GEE object uses GEE's own vcov (not sandwich::vcovHC) and supports robust, bias-corrected (Mancl-DeRouen), and DF-adjusted variance types for glmgee
  4. Calling get_marginal_effect with method="Ye" on a GEE object produces an informative error explaining that Ye's method assumes independence and is not valid for GEE
  5. Invalid GEE objects (wrong family, non-factor treatment, interactions present) produce clear, informative error messages matching the existing GLM validation style
**Plans**: 2 plans

Plans:
- [x] 05-01-PLAN.md -- S3 validation methods for glmgee and geeglm (sanitize_model + DESCRIPTION)
- [x] 05-02-PLAN.md -- GEE variance routing and end-to-end pipeline verification

### Phase 6: GEE Testing
**Goal**: GEE functionality is validated by a comprehensive test suite, existing GLM functionality has no regressions, and the package passes R CMD check
**Depends on**: Phase 5
**Requirements**: TEST-01, TEST-02, TEST-03
**Success Criteria** (what must be TRUE):
  1. A GEE-specific test file exists with tests covering validation, variance estimation, and end-to-end pipeline for both glmgee and geeglm, cross-validated against manual computation
  2. All 308 existing GLM tests continue to pass without modification
  3. R CMD check passes with 0 errors and 0 warnings (notes acceptable)
**Plans**: 1 plan

Plans:
- [x] 06-01-PLAN.md -- Comprehensive GEE test suite with manual delta method cross-validation and R CMD check

### Phase 7: GEE Documentation
**Goal**: Users can discover and use beeca's GEE support through a vignette, updated man pages, and release notes
**Depends on**: Phase 6
**Requirements**: DOC-01, DOC-02, DOC-03
**Success Criteria** (what must be TRUE):
  1. A GEE vignette exists that walks through a complete end-to-end example: fitting a GEE model, running get_marginal_effect, and interpreting results
  2. The sanitize_model and estimate_varcov man pages document GEE support including accepted object types and variance type options
  3. NEWS.md has a v0.4.0 section listing GEE support as a new feature with the key capabilities
**Plans**: 1 plan

Plans:
- [x] 07-01-PLAN.md -- GEE vignette, roxygen man page updates, NEWS.md v0.4.0, pkgdown config

## Progress

**Execution Order:** 5 -> 6 -> 7

| Phase | Plans Complete | Status | Completed |
|-------|----------------|--------|-----------|
| 5. GEE Core Implementation | 2/2 | Complete | 2026-02-07 |
| 6. GEE Testing | 1/1 | Complete | 2026-02-07 |
| 7. GEE Documentation | 1/1 | Complete | 2026-02-08 |
