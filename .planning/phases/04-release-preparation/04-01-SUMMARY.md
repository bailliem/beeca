---
phase: 04-release-preparation
plan: 01
subsystem: documentation
tags: [NEWS.md, changelog, references, doi, roxygen2]

# Dependency graph
requires:
  - phase: 03-vignette-review
    provides: Updated Magirr et al. reference to published version in vignettes
provides:
  - NEWS.md in tidyverse style with complete v0.3.0 changelog
  - All roxygen documentation updated with published Magirr et al. DOI
  - Zero OSF preprint references in codebase
affects: [04-02-final-checks, release]

# Tech tracking
tech-stack:
  added: []
  patterns: [tidyverse-style changelog formatting]

key-files:
  created: []
  modified:
    - NEWS.md
    - R/estimate_varcov.R
    - R/get_marginal_effect.R
    - man/estimate_varcov.Rd
    - man/get_marginal_effect.Rd

key-decisions:
  - "Restructured NEWS.md to standard R package style (New Features, Improvements, Bug Fixes sections)"
  - "One-liner bullets for all functions with backtick formatting"
  - "Included trial02_cdisc dataset as explicit bullet item"
  - "Updated all OSF preprint references to published DOI 10.1002/pst.70021"

patterns-established:
  - "Changelog follows tidyverse conventions: section headers, one-liner bullets, function names in backticks"
  - "Academic references use roxygen2 \\doi{} tag for clickable DOI links"

# Metrics
duration: 2min
completed: 2026-02-07
---

# Phase 04 Plan 01: NEWS.md Restructure and Reference Updates Summary

**Tidyverse-style NEWS.md changelog with 11 v0.3.0 features documented and all OSF preprint references updated to published DOI**

## Performance

- **Duration:** 2 min
- **Started:** 2026-02-07T20:21:48Z
- **Completed:** 2026-02-07T20:23:37Z
- **Tasks:** 2
- **Files modified:** 5

## Accomplishments

- Restructured NEWS.md v0.3.0 section to tidyverse style with New Features, Improvements, Bug Fixes sections
- Documented all 11 new functions (beeca_fit, plot_forest, plot.beeca, beeca_summary_table, beeca_to_cards_ard, tidy.beeca, augment.beeca, print.beeca, summary.beeca, as_gt.beeca, trial02_cdisc dataset)
- Updated Magirr et al. (2024) OSF preprint references to Magirr et al. (2025) published DOI in R source files and man pages
- Verified zero OSF preprint URLs remain in R/ directory

## Task Commits

Each task was committed atomically:

1. **Task 1: Restructure NEWS.md to tidyverse style** - `0c6ad6f` (docs)
2. **Task 2: Update OSF preprint references to published DOI** - `e20bcef` (docs)

## Files Created/Modified

- `NEWS.md` - Restructured v0.3.0 section to tidyverse style (New Features: 11 bullets, Improvements: 4 bullets, Bug Fixes: 1 bullet)
- `R/estimate_varcov.R` - Updated roxygen @param method documentation with DOI
- `R/get_marginal_effect.R` - Updated roxygen @param method documentation with DOI
- `man/estimate_varcov.Rd` - Regenerated with DOI reference
- `man/get_marginal_effect.Rd` - Regenerated with DOI reference

## Decisions Made

1. **One-liner bullets for all functions:** Each function gets a single concise line describing its purpose, following tidyverse convention for scannable changelogs
2. **trial02_cdisc as explicit bullet:** Made dataset a standalone bullet item (not buried in narrative) per CONTEXT.md decision for pharma audience visibility
3. **Magirr et al. reference noted in Improvements:** Explicitly documented the OSF-to-DOI update as an improvement for transparency
4. **Used roxygen2 \\doi{} tag:** Ensures DOI renders as clickable link in help pages (not markdown syntax which doesn't work in roxygen)

## Deviations from Plan

None - plan executed exactly as written.

## Issues Encountered

None.

## User Setup Required

None - no external service configuration required.

## Next Phase Readiness

- NEWS.md ready for v0.3.0 release (complete changelog, clear formatting)
- All academic references cite published versions (no preprints)
- Documentation fully consistent with published methodology
- Ready for final R CMD check and release verification

---

## Self-Check: PASSED

*Phase: 04-release-preparation*
*Completed: 2026-02-07*
