# Phase 3: Vignette Review - Context

**Gathered:** 2026-02-07
**Status:** Ready for planning

<domain>
## Phase Boundary

Review and polish the 3 existing vignettes (estimand_and_implementations, ard-cards-integration, clinical-trial-table) for clarity, storytelling, and error-free rendering. No new vignettes. No new features. Content quality and accuracy for v0.3.0 release.

</domain>

<decisions>
## Implementation Decisions

### Narrative flow & storytelling
- Estimand vignette: add brief hook + teaser code snippet before the theory section ("brief hook then theory")
- Keep Ge et al. raw paper code inline — shows the value of beeca's clean API vs verbose manual code
- Add a "Which method should I use?" section in the estimand vignette after explaining PATE/CPATE (map Ye→PATE, Ge→CPATE with guidance)
- ARD/cards vignette: add motivation section at top with a real scenario ("You've run beeca, now you need to combine results with baseline tables...")
- Clinical-trial-table vignette: end with a summary takeaway (what was demonstrated, key functions, pointers to other vignettes)
- No explicit learning objectives or prerequisites boxes — let the title and opening paragraph set context naturally

### Cross-vignette coherence
- Vignettes form a **progressive learning path**: Estimand (concepts + methods) → Clinical tables (practical workflow) → ARD/cards (advanced integration)
- Standardize on **trial02_cdisc** dataset across all 3 vignettes (currently estimand and ARD use trial01)
- Cross-reference naturally between vignettes (e.g., clinical-table vignette notes "For cards integration, see the ARD vignette")

### Content accuracy & freshness
- Update all references to published versions (Magirr et al. preprint → Pharmaceutical Statistics 2025 published version)
- Remove version numbers from package citations (margins, marginaleffects, RobinCar) — they go stale quickly
- Remove "Future Enhancements" section from ARD/cards vignette — release vignettes document what IS, not what MIGHT be
- Verify all vignettes render without errors after edits

### Claude's Discretion
- Comparison section structure in estimand vignette (inline vs shortened — Claude determines best balance)
- Math notation depth for PATE/CATE/CPATE/SATE definitions (Claude judges rigor vs accessibility)
- Number of table examples in clinical-trial-table vignette (Claude determines which are essential vs redundant)
- Whether to mention alternative table packages (flextable, huxtable) briefly
- Whether pkgdown article grouping needs adjustment after content changes

</decisions>

<specifics>
## Specific Ideas

- The audience is both biostatisticians AND statistical programmers — methodology for statisticians, practical recipes for programmers
- The estimand vignette's educational role is valued: beeca should EXPLAIN estimand concepts, not assume prior knowledge
- Cross-validation comparisons (beeca vs SAS, margins, marginaleffects, RobinCar) are a key trust-building feature — keep visible

</specifics>

<deferred>
## Deferred Ideas

None — discussion stayed within phase scope

</deferred>

---

*Phase: 03-vignette-review*
*Context gathered: 2026-02-07*
