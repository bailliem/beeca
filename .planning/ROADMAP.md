# Roadmap: beeca v0.3.0 Release

## Overview

This roadmap guides the v0.3.0 GitHub release readiness review for the beeca R package. The journey validates build integrity, reviews documentation accuracy, ensures vignette quality (especially ARD and clinical trial reporting examples), and prepares release artifacts. Core value: All R CMD checks pass with no errors or warnings.

## Phases

**Phase Numbering:**
- Integer phases (1, 2, 3, 4): Planned milestone work
- Decimal phases (2.1, 2.2): Urgent insertions (marked with INSERTED)

Decimal phases appear between their surrounding integers in numeric order.

- [x] **Phase 1: Build Validation** - Ensure R CMD check passes and all tests run cleanly
- [x] **Phase 1.1: GEE Longitudinal Extension Feasibility** (INSERTED) - Feasibility spike for extending beeca to support GEE/longitudinal binary endpoints
- [x] **Phase 2: Documentation Review** - Verify all documentation is accurate and complete
- [x] **Phase 3: Vignette Review** - Review and polish vignettes for clarity and storytelling
- [ ] **Phase 4: Release Preparation** - Update release artifacts and finalize v0.3.0

## Phase Details

### Phase 1: Build Validation
**Goal**: All package checks and tests pass without errors or warnings
**Depends on**: Nothing (first phase)
**Requirements**: BUILD-01, BUILD-02, BUILD-03, BUILD-04
**Success Criteria** (what must be TRUE):
  1. R CMD check completes with 0 errors
  2. R CMD check completes with 0 warnings
  3. All 80+ testthat tests pass
  4. Test coverage gaps (if any) are identified and documented
**Plans**: 2 plans

Plans:
- [x] 01-01-PLAN.md — Run R CMD check and testthat suite, capture results
- [x] 01-02-PLAN.md — Triage issues with user, apply fixes, finalize validation

### Phase 1.1: GEE Longitudinal Extension Feasibility (INSERTED)
**Goal**: Determine feasibility and scope of extending beeca to support GEE-fitted models for longitudinal binary endpoints
**Depends on**: Phase 1
**Requirements**: RESEARCH — user feature request for GEE/longitudinal support
**Success Criteria** (what must be TRUE):
  1. Feasibility report produced: can beeca's pipeline accept glmgee/geeglm objects?
  2. Tested with glmtoolbox and/or geepack on a simple longitudinal binary example
  3. Go/no-go recommendation with clear rationale
  4. If go: scoped implementation plan (beeca vs. companion package)
**Plans**: 2 plans

Plans:
- [x] 01.1-01-PLAN.md — Run GEE feasibility test script through beeca pipeline
- [x] 01.1-02-PLAN.md — Synthesize results into feasibility report with go/no-go recommendation

### Phase 2: Documentation Review
**Goal**: All documentation is accurate and complete for v0.3.0
**Depends on**: Phase 1
**Requirements**: DOCS-01, DOCS-02, DOCS-03
**Success Criteria** (what must be TRUE):
  1. README.md accurately reflects v0.3.0 features and examples
  2. All exported functions have complete, accurate man pages
  3. pkgdown site builds successfully without errors
**Plans**: 3 plans

Plans:
- [x] 02-01-PLAN.md — Review and standardize all man page documentation + DESCRIPTION audit
- [x] 02-02-PLAN.md — Update README.md for v0.3.0
- [x] 02-03-PLAN.md — Restructure pkgdown site and verify build

### Phase 3: Vignette Review
**Goal**: All vignettes are clear, informative, and render without errors
**Depends on**: Phase 2
**Requirements**: VIG-01, VIG-02, VIG-03
**Success Criteria** (what must be TRUE):
  1. ARD vignette clearly explains ARD format and tells a good story
  2. Clinical trial reporting vignette demonstrates complete, realistic workflow
  3. All vignettes (estimand_and_implementations, ARD, clinical reporting) render without errors
**Plans**: 2 plans

Plans:
- [x] 03-01-PLAN.md — Polish estimand vignette: add hook, method guidance, update references
- [x] 03-02-PLAN.md — Polish ARD and clinical-trial-table vignettes, verify all vignettes render

### Phase 4: Release Preparation
**Goal**: Package is ready for v0.3.0 GitHub release
**Depends on**: Phase 3
**Requirements**: REL-01, REL-02, REL-03
**Success Criteria** (what must be TRUE):
  1. NEWS.md includes complete v0.3.0 changelog
  2. DESCRIPTION file version set to 0.3.0
  3. All lifecycle deprecations (if any) are properly documented
  4. Git tag v0.3.0 is ready to push
**Plans**: TBD

Plans:
- [ ] 04-01: TBD during planning

## Progress

**Execution Order:**
Phases execute in numeric order: 1 -> 1.1 -> 2 -> 3 -> 4

| Phase | Plans Complete | Status | Completed |
|-------|----------------|--------|-----------|
| 1. Build Validation | 2/2 | Complete | 2026-01-31 |
| 1.1 GEE Longitudinal Feasibility (INSERTED) | 2/2 | Complete | 2026-02-03 |
| 2. Documentation Review | 3/3 | Complete | 2026-02-06 |
| 3. Vignette Review | 2/2 | Complete | 2026-02-07 |
| 4. Release Preparation | 0/? | Not started | - |

---
*Last updated: 2026-02-07 after Phase 3 execution complete*
