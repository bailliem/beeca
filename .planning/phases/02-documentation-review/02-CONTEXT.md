# Phase 2: Documentation Review - Context

**Gathered:** 2026-02-06
**Status:** Ready for planning

<domain>
## Phase Boundary

Verify all documentation (README, man pages, pkgdown site, DESCRIPTION) is accurate and complete for v0.3.0 GitHub release. Fix issues found during review. Does NOT include vignette content review (Phase 3) or release artifacts like NEWS.md (Phase 4).

</domain>

<decisions>
## Implementation Decisions

### README scope
- Moderate rewrite: update version references, revise feature descriptions, add any new functions/methods to the overview, refresh examples
- Only shipping features in v0.3.0 — no mention of GEE feasibility or future work
- GitHub install primary: lead with `remotes::install_github()`, keep CRAN as secondary
- Review and update badges: check all work, add missing ones (e.g., lifecycle stable), remove broken ones
- Keep existing section structure — no new sections needed
- pkgdown homepage mirrors README (single source of truth)

### Man page review depth
- Review ALL 26 man pages, not just exported functions
- Run ALL @examples to verify they execute without error
- Standardize roxygen style across functions: @return format, @param naming conventions, @seealso links
- Verify ALL @references citations are complete with correct, resolving DOIs

### pkgdown site structure
- Restructure _pkgdown.yml if needed — rethink reference grouping
- Claude's discretion on function grouping approach (by pipeline step vs. by user task)
- Standard pkgdown features — articles tab shows vignettes, reference well-organized
- Verify all internal cross-references between man pages and vignettes resolve in built site

### What's changed since 0.2.0
- NEWS.md-driven approach: use existing changelog as source of truth, cross-check against code
- Fix issues immediately as found — don't batch
- New functions (beeca_summary_table, as_gt, plot_forest, beeca_to_cards_ard) must match documentation quality of core functions like get_marginal_effect()
- Full DESCRIPTION audit: authors, URLs, Imports, Suggests, version constraints, license

### Claude's Discretion
- Whether to lead README examples with get_marginal_effect() wrapper or pipeline approach
- Whether to include ARD output example in README or just link to vignette
- What new v0.3.0 features to highlight in README (e.g., S3 methods, summary table)
- pkgdown reference grouping strategy (by pipeline step vs. by user task)

</decisions>

<specifics>
## Specific Ideas

- Target audience is clinical statisticians in GxP environments
- Package developed with ASA-BIOP Covariate Adjustment Scientific Working Group
- Cross-validation against SAS %margins macro, {margins}, {marginaleffects}, {RobinCar} is a key selling point

</specifics>

<deferred>
## Deferred Ideas

None — discussion stayed within phase scope

</deferred>

---

*Phase: 02-documentation-review*
*Context gathered: 2026-02-06*
