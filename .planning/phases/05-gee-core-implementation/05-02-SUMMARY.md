---
phase: 05-gee-core-implementation
plan: 02
subsystem: variance-estimation
tags: [gee, variance, delta-method, vcov, glmgee, geeglm]
requires: [05-01]
provides: [gee-variance-routing, gee-end-to-end-pipeline]
affects: [05-03, 05-04]
tech-stack:
  added: []
  patterns: [gee-variance-resolution, type-attribute-forwarding]
key-files:
  created: []
  modified:
    - R/estimate_varcov.R
    - R/get_marginal_effect.R
    - R/predict_counterfactuals.R
    - R/sanitize.R
key-decisions:
  - decision: GEE default variance type is "robust"
    rationale: Matches sandwich HC0 philosophy, most common choice
  - decision: geeglm exposes only "robust" variance type
    rationale: Native geepack sandwich SE, other types not available
  - decision: glmgee exposes "robust", "bias-corrected", "df-adjusted" types
    rationale: glmtoolbox vcov() supports these types
  - decision: Use vcov() method call instead of object internals
    rationale: Respects package API, more maintainable
  - decision: Auto-fix GEE predict matrix output in predict_counterfactuals
    rationale: Bug (duplicate column names), Rule 1 auto-fix
duration: 3.5 minutes
completed: 2026-02-07
---

# Phase 5 Plan 02: GEE Variance Routing and End-to-End Pipeline Summary

**One-liner:** GEE objects flow through beeca's g-computation pipeline with GEE-native robust variance estimation via delta method

## Performance

**Duration:** 3.5 minutes
**Tasks completed:** 2/2
**Commits:** 2
**Tests:** All 308 existing tests pass

## Accomplishments

### Core Implementation

1. **GEE Variance Routing**
   - Added `varcov_ge_gee()` internal function for GEE-specific Ge delta method
   - GEE objects use GEE's own `vcov()` instead of `sandwich::vcovHC`
   - Type resolution: GLM types (HC0, HC3, etc.) rejected with valid options listed
   - Default type handling: unspecified type silently maps to "robust"
   - Resolved type attribute forwarding for correct type labeling

2. **GEE Variance Types**
   - glmgee: "robust", "bias-corrected", "df-adjusted"
   - geeglm: "robust" only (native geepack sandwich SE)
   - Informative errors when user passes invalid types

3. **Ye Method Rejection**
   - GEE objects with `method="Ye"` produce locked error message
   - Message: "Ye's method assumes independence and is not valid for GEE models. Use method='Ge' instead."

4. **Formula Extraction**
   - Added `.get_formula()` helper for robust formula access
   - Works for glmgee, geeglm, and standard glm objects
   - Fallback chain: `model$formula` → `model$call$formula` → `stats::formula()`
   - Updated all formula access points to use helper

5. **End-to-End Pipeline**
   - GEE type default handling in `get_marginal_effect()` (HC0 → robust)
   - Full pipeline verified: sanitize → predict → average → estimate_varcov → apply_contrast
   - Tested with both glmgee and geeglm objects
   - All 5 contrast types work: diff, or, rr, logor, logrr
   - marginal_results ARD tibble has correct structure (12 rows for 2-arm trial)

## Task Commits

| Task | Commit | Description |
|------|--------|-------------|
| 1 | cd9813a | Add GEE variance routing to estimate_varcov |
| 2 | 5c26e03 | Wire end-to-end pipeline for GEE objects |

## Files Created

None

## Files Modified

1. **R/estimate_varcov.R**
   - Added early Ye rejection for GEE objects (lines 118-122)
   - Added GEE routing in method="Ge" branch (lines 124-141)
   - Added `varcov_ge_gee()` internal function (lines 356-412)
   - Updated `varcov_ge()` to use `.get_formula()` (line 338)
   - Added resolved_type attribute tracking (lines 348-352, 163-166)

2. **R/sanitize.R**
   - Added `.get_formula()` helper function (lines 314-323)

3. **R/predict_counterfactuals.R**
   - Fixed GEE predict matrix output handling (lines 68-71)
   - Converts matrix predictions to vectors to avoid duplicate column names

4. **R/get_marginal_effect.R**
   - Added GEE type default handling (lines 91-93)
   - Updated formula access to use `.get_formula()` (line 99)

## Decisions Made

1. **GEE variance types mapped to package capabilities**
   - glmgee: expose 3 types matching glmtoolbox::vcov() API
   - geeglm: expose 1 type matching geepack sandwich SE
   - Prevents user confusion about what's available

2. **Type resolution strategy**
   - Default vector (length > 1): silently map to "robust"
   - Explicit GLM type: error with valid GEE types listed
   - Unrecognized type: error with valid GEE types listed
   - This gives helpful errors while maintaining backward compatibility

3. **Resolved type attribute forwarding**
   - `varcov_ge_gee()` returns `resolved_type` attribute
   - `estimate_varcov()` uses it for final type labeling
   - Ensures "Ge - robust" not "Ge - HC0" in output

4. **Formula extraction robustness**
   - Multiple fallback attempts prevent failures
   - Works across GLM and GEE classes with different internal structures

## Deviations from Plan

### Auto-fixed Issues

**[Rule 1 - Bug] Fixed GEE predict matrix output causing duplicate column names**
- **Found during:** Task 1 verification
- **Issue:** glmgee and geeglm `predict()` methods return matrices with column name "fit", not vectors. When `cbind()` combines multiple predictions, duplicate "fit" columns trigger tibble warning and break column indexing by treatment level.
- **Fix:** Added matrix detection and vector conversion in `predict_counterfactuals()` (lines 68-71)
- **Files modified:** R/predict_counterfactuals.R
- **Commit:** cd9813a
- **Impact:** GEE counterfactual predictions now have correct treatment level column names (A, B) instead of (fit, V2)

## Issues Encountered

None. Plan executed smoothly.

## Next Phase Readiness

**Phase 5 Core Implementation (05-03, 05-04):**
- ✅ GEE variance estimation working
- ✅ End-to-end pipeline functional
- ✅ All 5 contrast types verified
- ✅ Existing tests unchanged (308 pass)
- ⏭️ Ready for testing suite expansion (05-03)
- ⏭️ Ready for documentation updates (05-04)

**Verification:**
- glmgee with 5 contrasts: ✅ all produce valid results
- geeglm with 5 contrasts: ✅ all produce valid results
- Ye rejection: ✅ correct message
- GLM type rejection: ✅ lists valid types
- Default type: ✅ resolves to "robust"
- ARD structure: ✅ 12 rows, correct schema
- Existing tests: ✅ 308 pass, 0 fail

**Outstanding Work:**
- None for core implementation
- Testing coverage (plan 05-03)
- Vignette updates (plan 05-04)

## Self-Check: PASSED

All commits verified:
- cd9813a: found
- 5c26e03: found

All modified files verified:
- R/estimate_varcov.R: found
- R/sanitize.R: found
- R/predict_counterfactuals.R: found
- R/get_marginal_effect.R: found
