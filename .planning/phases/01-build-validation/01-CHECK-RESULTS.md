# Build Validation Results - beeca Package

**Generated:** 2026-01-31
**Package Version:** 0.2.0

---

## Validation Summary

**Overall Status:** ❌ ISSUES FOUND

| Check Type | Status | Details |
|------------|--------|---------|
| R CMD check | ❌ ERROR | Vignette build failure |
| testthat | Pending | Not yet run |
| Coverage | Pending | Not yet run |

---

## Issue Categories

### Blockers
- **Vignette Build Failure**: `ard-cards-integration.Rmd` fails to build
  - Error: `object 'fit_study1' not found` at lines 176-192 [meta-analysis chunk]
  - Function: `beeca_to_cards_ard(fit_study1$marginal_results)`
  - Impact: R CMD check cannot complete, package cannot be built

### Warnings
None yet detected.

### Notes
None yet detected.

---

## Detailed Results

### R CMD check

**Status:** ERROR (build failed during vignette creation)

**Output:**

```
══ Documenting ═════════════════════════════════════════════════════════════════
ℹ Updating beeca documentation
ℹ Loading beeca

══ Building ════════════════════════════════════════════════════════════════════
Setting env vars:
• CFLAGS    : -Wall -pedantic
• CXXFLAGS  : -Wall -pedantic
• CXX11FLAGS: -Wall -pedantic
• CXX14FLAGS: -Wall -pedantic
• CXX17FLAGS: -Wall -pedantic
• CXX20FLAGS: -Wall -pedantic
```

**Vignette Building:**

| Vignette | Status | Notes |
|----------|--------|-------|
| `ard-cards-integration.Rmd` | ❌ ERROR | Object 'fit_study1' not found at line 176-192 |
| `clinical-trial-table.Rmd` | ✅ SUCCESS | Built successfully |
| `estimand_and_implementations.Rmd` | ✅ SUCCESS | Built successfully |

**Error Details:**

```
--- re-building 'ard-cards-integration.Rmd' using rmarkdown

Quitting from ard-cards-integration.Rmd:176-192 [meta-analysis]

Error:
! object 'fit_study1' not found
---
Backtrace:
    ▆
 1. ├─dplyr::mutate(...)
 2. └─beeca::beeca_to_cards_ard(fit_study1$marginal_results)
 3.   ├─dplyr::select(...)
 4.   ├─dplyr::mutate(...)
 5.   └─dplyr::rename(...)

Error: processing vignette 'ard-cards-integration.Rmd' failed with diagnostics:
object 'fit_study1' not found
```

**Summary:**
- ❌ **1 ERROR:** Vignette build failure
- ⚠️ **0 WARNINGs**
- ℹ️ **0 NOTEs**
- Duration: Build terminated at vignette stage

**Root Cause:**
The `ard-cards-integration.Rmd` vignette references an object `fit_study1` that doesn't exist in scope at lines 176-192 in the `meta-analysis` chunk. This prevents the vignette from knitting and blocks package building.

---

### testthat Suite

**Status:** Not yet run (blocked by R CMD check failure)

Will run after vignette issue is resolved.

---

### Test Coverage

**Status:** Not yet run (blocked by R CMD check failure)

Will run after vignette issue is resolved.

---

## Next Steps

1. **Fix vignette error** in `ard-cards-integration.Rmd`:
   - Investigate lines 176-192 (meta-analysis chunk)
   - Ensure `fit_study1` object is created before use
   - Or remove/comment out problematic code if not ready

2. **Re-run R CMD check** after vignette fix

3. **Run testthat suite** once build succeeds

4. **Run coverage analysis** for gap identification

---

## Notes

- R CMD check uses `error_on = 'never'` to capture all issues
- Two vignettes built successfully, indicating issue is isolated to `ard-cards-integration.Rmd`
- Package documentation updates completed successfully
- Build environment properly configured with compiler flags
