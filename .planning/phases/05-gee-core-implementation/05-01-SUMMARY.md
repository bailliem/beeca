---
phase: 05-gee-core-implementation
plan: "01"
subsystem: validation
tags: [gee, glmgee, geeglm, s3-methods, sanitize]
requires: [DESCRIPTION, R/sanitize.R]
provides: [sanitize_model.glmgee, sanitize_model.geeglm]
affects: [05-02, 05-03]
tech-stack:
  added: [glmtoolbox, geepack]
  patterns: [S3-dispatch, fail-fast-validation]
key-files:
  created: [man/sanitize_model.glmgee.Rd, man/sanitize_model.geeglm.Rd]
  modified: [DESCRIPTION, R/sanitize.R, NAMESPACE]
key-decisions:
  - GEE packages in Suggests (not Imports) for optional dependency
  - Fail fast on missing packages with install hints
  - Single-timepoint validation via cluster size check
  - Reuse sanitize_variable helper for treatment/response checks
  - Skip convergence check for geeglm (attribute removed by package)
  - Skip rank check if $qr component missing (GEE internals differ)
duration: 2min
completed: 2026-02-07
---

# Phase 5 Plan 01: GEE Sanitization Gateway Summary

**One-liner:** S3 methods for glmgee/geeglm validation unlock GEE support in beeca's g-computation pipeline

## Performance

**Execution time:** 2 minutes 8 seconds
**Tasks completed:** 2/2 (100%)
**Tests:** 308 passed, 0 failed (zero regressions)
**Integration verified:** GEE objects flow through predict_counterfactuals and average_predictions

## What Was Accomplished

### Core Deliverables

1. **DESCRIPTION updated** - Added glmtoolbox (>= 0.1.12) and geepack (>= 1.3.13) to Suggests
2. **sanitize_model.glmgee** - Validates glmgee objects with GEE-specific checks
3. **sanitize_model.geeglm** - Validates geeglm objects with GEE-specific checks
4. **NAMESPACE exports** - S3method entries for both new methods

### Validation Implemented

Both methods perform these checks:

**Reused from GLM validation:**
- Treatment variable on RHS, factor with 2+ levels (via sanitize_variable)
- Response coded 0/1 (via sanitize_variable)
- Binomial family with logit link
- No treatment-covariate interactions
- Missing data detection (if model$model available)

**GEE-specific additions:**
- Package availability check (fail fast with install hints)
- Single-timepoint validation (cluster size = 1 for all IDs)
- Conditional rank check (skip if $qr missing)
- Conditional convergence check (skip for geeglm which removes attribute)

### Integration Success

**The gate is now open:**
- `sanitize_model(glmgee_object, "trtp")` returns sanitized object
- `sanitize_model(geeglm_object, "trtp")` returns sanitized object
- `predict_counterfactuals()` works immediately (glmgee/geeglm provide GLM-compatible predict())
- `average_predictions()` works on GEE counterfactuals

**Zero code changes needed in:**
- R/predict_counterfactuals.R
- R/average_predictions.R

This validates the design decision: GEE packages provide GLM-compatible interfaces, so only validation needed updating.

## Task Commits

| Task | Commit | Description |
|------|--------|-------------|
| 1 | dd275a1 | Add glmtoolbox and geepack to DESCRIPTION Suggests |
| 2 | a062ec8 | Implement sanitize_model.glmgee and sanitize_model.geeglm S3 methods |

## Files Created

- `man/sanitize_model.glmgee.Rd` - Generated documentation for glmgee method
- `man/sanitize_model.geeglm.Rd` - Generated documentation for geeglm method

## Files Modified

- `DESCRIPTION` - Added glmtoolbox (>= 0.1.12) and geepack (>= 1.3.13) to Suggests
- `R/sanitize.R` - Added 220 lines for two new S3 methods
- `NAMESPACE` - Added S3method(sanitize_model, glmgee) and S3method(sanitize_model, geeglm)

## Decisions Made

### 1. Fail-Fast Package Availability

**Decision:** Check `requireNamespace()` FIRST in each method before any other validation.

**Rationale:** Provides immediate, clear error with install hint rather than obscure failure later.

**Implementation:**
```r
if (!requireNamespace("glmtoolbox", quietly = TRUE)) {
  stop('glmtoolbox is required for glmgee objects. Install with install.packages("glmtoolbox")', call. = FALSE)
}
```

### 2. Single-Timepoint Validation Strategy

**Decision:** Extract cluster IDs and validate all have size = 1.

**Rationale:** beeca's current variance estimators (Ge, Ye) assume independence. Multi-timepoint GEE introduces correlation that requires different variance estimation.

**Implementation:**
- glmgee: Try `model$id` first, fallback to `eval(model$call$id, .get_data(model))`
- geeglm: Use `model$id` directly
- Reject with informative error if any cluster has > 1 observation

### 3. Conditional Component Checks

**Decision:** Skip rank check if `model$qr` is NULL, skip convergence for geeglm.

**Rationale:** GEE fitting uses different internals than GLM. Rather than error on missing components, gracefully skip checks that aren't applicable.

**Evidence:**
- Research confirmed geeglm removes `$converged` attribute
- GEE may not populate `$qr` (uses GEE solver, not QR decomposition)

### 4. Reuse sanitize_variable Helper

**Decision:** Call `sanitize_variable(model, trt)` at start of both methods.

**Rationale:**
- Treatment/response validation identical for GLM and GEE
- .get_data(model) works for both (all have $model slot)
- DRY principle - one source of truth for variable validation

### 5. Error Message Format

**Decision:** Include class name in error messages ("Model of class glmgee...").

**Rationale:** Users may not know object class. Explicit class name helps with troubleshooting and searching documentation.

## Deviations from Plan

None - plan executed exactly as written.

## Issues Encountered

None. Feasibility testing in research phase identified all edge cases:
- glmgee cluster ID location
- geeglm missing $converged
- GEE objects may lack $qr
- Both packages have $model slot for .get_data()

## Next Phase Readiness

**Ready for 05-02 (GEE variance estimation):**
- ✅ GEE objects validated
- ✅ Counterfactual predictions work
- ✅ Average predictions work
- ✅ Object structure compatible with GLM pipeline

**Next dependency:** estimate_varcov() needs GEE-aware variance estimation (Ge method only per project decisions).

**Blockers:** None

**Concerns:** None - integration testing confirms design assumptions.

## Self-Check: PASSED

All created files exist:
- man/sanitize_model.glmgee.Rd ✓
- man/sanitize_model.geeglm.Rd ✓

All commits exist:
- dd275a1 ✓
- a062ec8 ✓
