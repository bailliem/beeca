# Phase 4: Release Preparation - Context

**Gathered:** 2026-02-07
**Status:** Ready for planning

<domain>
## Phase Boundary

Finalize package artifacts and metadata for the v0.3.0 GitHub release. This covers NEWS.md completion, DESCRIPTION verification, pre-release validation, and release branch creation. The scope is: update changelog, validate build, prepare for tagging. Actual tagging and pushing are done by the user manually.

</domain>

<decisions>
## Implementation Decisions

### NEWS.md scope
- Add trial02_cdisc dataset as an explicit bullet point (new dataset for CDISC-compliant workflows)
- Add bullet noting Magirr et al. reference updated from OSF preprint to published version (Pharmaceutical Statistics 2025)
- No acknowledgments section in NEWS.md (belongs in DESCRIPTION/README)

### NEWS.md structure and tone
- Restructure to simpler sections: "New Features", "Improvements", "Bug Fixes" (standard R package convention, like tidyverse)
- One-liner per function instead of multi-bullet descriptions (e.g., "beeca_fit(): Convenience function combining model fitting and marginal effect estimation.")
- Audience is both pharma statisticians and R developers — balance clinical relevance with technical precision

### GitHub Release format
- Git tag only — no GitHub Release page with notes
- Tag will be on a release branch (release/v0.3.0), created from current HEAD of main
- Phase 4 prepares everything but does NOT create the tag — user tags manually
- Phase 4 DOES create the release branch from main

### Pre-release validation checklist
- Run final R CMD check on release branch (0 errors, 0 warnings required)
- Run CRAN-readiness check (devtools::check with cran = TRUE)
- Verify pkgdown site builds cleanly on release branch
- Check all URLs in package (DESCRIPTION, man pages, vignettes) are valid and reachable
- Verify .Rbuildignore properly excludes .planning/, .claude/, and other non-package files from tarball
- No lifecycle deprecations to document in v0.3.0

### Claude's Discretion
- Whether to add a "Documentation" section to NEWS.md for Phase 2-3 work (doc updates, vignette polish, pkgdown restructure)
- Whether to explicitly list dependency changes beyond rlang (generics, cards, gt, ggplot2 are Suggests)
- Exact ordering of NEWS.md sections and bullets
- How to handle any issues found during CRAN-readiness check

</decisions>

<specifics>
## Specific Ideas

- User wants simpler changelog format — scan tidyverse packages (dplyr, ggplot2) for reference style
- DESCRIPTION already has Version: 0.3.0, so version bump step is verification only
- Pre-existing test failure in test-beeca-fit.R:174 is known and accepted — should not block release

</specifics>

<deferred>
## Deferred Ideas

None — discussion stayed within phase scope

</deferred>

---

*Phase: 04-release-preparation*
*Context gathered: 2026-02-07*
