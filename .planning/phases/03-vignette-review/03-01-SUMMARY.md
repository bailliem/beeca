---
phase: 03-vignette-review
plan: 01
subsystem: documentation
tags: [vignettes, estimand, user-guidance, references, cross-linking]

requires:
  - 02-01-PLAN.md  # Man page documentation standardization
  - 02-03-PLAN.md  # Pkgdown site restructure

provides:
  - Polished estimand_and_implementations.Rmd vignette with problem-based hook
  - Practical method selection guidance (Ye vs Ge)
  - Updated references (Magirr 2025 published version)
  - Cross-vignette navigation links

affects:
  - 03-02-PLAN.md  # Clinical trial table vignette polish (next in sequence)
  - 03-03-PLAN.md  # ARD integration vignette polish (next in sequence)

tech-stack:
  added: []
  patterns:
    - Problem-based learning approach (hook before theory)
    - Progressive disclosure (teaser → theory → practice)
    - Cross-document navigation (vignette linking)

key-files:
  created: []
  modified:
    - vignettes/estimand_and_implementations.Rmd

decisions:
  - id: DOCS-VIG-01
    what: Use problem-based hook instead of learning objectives boxes
    why: More engaging for both biostatisticians and programmers
    impact: Sets pattern for other vignettes in phase
  - id: DOCS-VIG-02
    what: Keep trial01 for comparisons despite trial02_cdisc being primary
    why: Pre-computed SAS validation datasets only exist for trial01
    impact: Requires explanatory note to avoid confusion

metrics:
  duration: "3 minutes"
  completed: "2026-02-07"
---

# Phase 03 Plan 01: Estimand Vignette Polish Summary

**One-liner:** Problem-based opening hook, Ye/Ge method selection guidance, and published Magirr 2025 reference in estimand vignette

## What Was Built

Enhanced the `estimand_and_implementations.Rmd` vignette to serve as an engaging entry point for the progressive learning path. The vignette now opens with a real-world problem (which variance estimator?) and a 3-line teaser showing beeca in action before diving into theory. Added practical "Which method should I use?" guidance mapping Ye to PATE and Ge to CPATE with FDA alignment rationale.

### Task Breakdown

| Task | Description | Commit | Duration |
|------|-------------|--------|----------|
| 1 | Add opening hook, teaser, and "Which method?" section | c5988e6 | ~1.5 min |
| 2 | Update references and add cross-vignette navigation | b3309eb | ~1.5 min |

**Total execution time:** 3 minutes

## Technical Implementation

### Hook and Teaser (Task 1)

**Before:**
```
## Introduction

The [ICH E9(R1) addendum](...) proposed a framework...
```

**After:**
```
## Introduction

The FDA recommends covariate-adjusted analyses for randomized clinical trials,
but which variance estimator should you use? The `beeca` package makes this simple:

```r
library(beeca)
fit <- glm(AVAL ~ TRTP + SEX + RACE + AGE, family = "binomial", data = trial02_cdisc)
get_marginal_effect(fit, trt = "TRTP", method = "Ye", contrast = "diff", reference = "Placebo")
```

To understand why this works and when to use each method, we need to clarify
what type of treatment effect we're estimating.

The [ICH E9(R1) addendum](...) proposed a framework...
```

### Method Selection Guidance (Task 1)

Added new section after PATE/CPATE explanation:

```markdown
## Which method should I use?

For most regulatory submissions, use `method = "Ye"`. This method targets the
**population average treatment effect (PATE)**, which is an unconditional estimand
recommended by the FDA guidance (2023) for primary analyses.

The **Ye et al. (2023)** method provides robust variance estimation for PATE...
The **Ge et al. (2011)** method targets the **conditional population average
treatment effect (CPATE)**...

**Key points:**
- Point estimates are identical between methods; only standard errors differ.
- If your protocol specifies an unconditional estimand (most common), use `method = "Ye"`.
- If your protocol specifies a conditional estimand, use `method = "Ge"`.
- When in doubt, use `method = "Ye"` — it aligns with FDA guidance...

For practical reporting examples, see `vignette('clinical-trial-table')`.
```

### Reference Updates (Task 2)

1. **Magirr et al. preprint → published version:**
   - Removed: `[Magirr et al. (2024)](https://osf.io/9mp58/)`
   - Added: `[Magirr et al. (2025)](https://doi.org/10.1002/pst.70021)`
   - Citation: "Pharmaceutical Statistics 24(4): e70021"

2. **Removed package version numbers:**
   - marginaleffects: "version 0.14.0" → (removed)
   - margins: "version 0.3.26" → (removed)
   - RobinCar: "version 0.2.0" → (removed)

3. **Added DOIs to all methodology references:**
   - Ge et al. 2011: https://doi.org/10.1177/009286151104500409
   - Ye et al. 2023: https://doi.org/10.1080/24754269.2023.2205802
   - Magirr et al. 2025: https://doi.org/10.1002/pst.70021

### Comparison Section Enhancements (Task 2)

**Added explanatory note:**
```markdown
**Note:** For these cross-validation comparisons, we use the `trial01` dataset
(2-arm trial) because pre-computed results from SAS macros (`margins_trial01`,
`ge_macro_trial01`) are available for this dataset. The methodology applies
identically to `trial02_cdisc`.
```

**Added subheadings for scannability:**
```markdown
### Ge et al (2011)

#### beeca
[beeca code...]

#### Paper code (Ge et al. 2011)
[paper code...]

#### Using {margins}
[margins code...]

#### Using {marginaleffects}
[marginaleffects code...]

#### SAS %Margins macro
[SAS code...]
```

### Cross-Vignette Navigation (Task 2)

Added "Next Steps" section before References:

```markdown
## Next Steps

- For creating clinical trial tables from beeca results: `vignette('clinical-trial-table')`
- For integrating with the cards ARD framework: `vignette('ard-cards-integration')`
```

## Deviations from Plan

None - plan executed exactly as written.

## Testing and Verification

All verification checks passed:

```bash
# No OSF/preprint references
$ grep -in "osf.io\|preprint" vignettes/estimand_and_implementations.Rmd
# (no output - PASS)

# No package version numbers
$ grep -n "version [0-9]" vignettes/estimand_and_implementations.Rmd
# (no output - PASS)

# Magirr 2025 present
$ grep -n "Magirr.*2025" vignettes/estimand_and_implementations.Rmd
66:See [Magirr et al. (2025)](https://doi.org/10.1002/pst.70021)...
298:* Magirr D, Wang C, Przybylski A, Baillie M (2025)...

# Cross-references present
$ grep -n "vignette(" vignettes/estimand_and_implementations.Rmd
83:For practical reporting examples, see `vignette('clinical-trial-table')`.
282:- For creating clinical trial tables: `vignette('clinical-trial-table')`
283:- For integrating with cards: `vignette('ard-cards-integration')`

# Dataset switch note present
$ grep -n "trial01.*dataset" vignettes/estimand_and_implementations.Rmd
153:**Note:** For these cross-validation comparisons, we use the `trial01` dataset...
```

**Narrative flow verified:**
1. Hook (problem-based opening) ✓
2. Theory (ICH E9(R1), FDA guidance, estimand types) ✓
3. Method guidance (Which method should I use?) ✓
4. Example (trial02_cdisc primary example) ✓
5. Comparisons (trial01 with explanatory note) ✓
6. Next steps (cross-references) ✓
7. References (updated, no preprints, no version numbers) ✓

## Self-Check: PASSED

All files verified to exist:
- vignettes/estimand_and_implementations.Rmd ✓

All commits verified:
- c5988e6: Add opening hook, teaser, and method guidance section ✓
- b3309eb: Update references and add cross-vignette navigation ✓

## Decisions Made

**DOCS-VIG-01: Problem-based hook instead of learning objectives boxes**
- **Context:** Research phase identified that learning objectives boxes are common but not universally loved
- **Decision:** Use problem-based hook ("which variance estimator?") + teaser code instead
- **Rationale:** More engaging for mixed audience (biostatisticians + programmers), shows value immediately
- **Alternative rejected:** Traditional learning objectives/prerequisites boxes
- **Impact:** Sets pattern for other vignettes in phase 03

**DOCS-VIG-02: Retain trial01 for comparisons despite trial02_cdisc being primary**
- **Context:** Comparison section cross-validates against SAS macros (margins_trial01, ge_macro_trial01)
- **Decision:** Keep trial01 for comparisons, add explicit explanatory note
- **Rationale:** Pre-computed SAS validation datasets only exist for trial01; methodology is identical
- **Alternative rejected:** Re-running SAS macros for trial02_cdisc (out of scope, adds no value)
- **Impact:** Users understand why dataset switches mid-vignette

## Next Phase Readiness

**Ready for 03-02 (Clinical Trial Table Vignette):**
- Cross-reference from estimand vignette now points to clinical-trial-table
- Pattern established: hook → theory → practice
- trial02_cdisc confirmed as standard example dataset

**No blockers.**

## Key Metrics

- **Files modified:** 1 (vignettes/estimand_and_implementations.Rmd)
- **Commits:** 2 (c5988e6, b3309eb)
- **Locked decisions honored:** 2/2 (no learning objectives boxes, keep Ge paper code inline)
- **Cross-references added:** 3 (clinical-trial-table × 2, ard-cards-integration × 1)
- **References updated:** 3 (Magirr to 2025, removed version numbers, added DOIs)

## Lessons Learned

1. **Problem-based hooks work:** Teaser code snippet engages immediately without requiring setup chunk execution (eval=FALSE pattern)
2. **Version numbers in references date quickly:** Package citations should reference project URLs/DOIs, not version numbers
3. **Dataset consistency needs explanation:** When primary dataset changes mid-vignette (even for good reason), explicit note prevents confusion
4. **Progressive learning paths need signposting:** "Next Steps" section with cross-references guides users through documentation journey

## Files Changed

```
vignettes/estimand_and_implementations.Rmd
├── Introduction section: Added hook + teaser (lines 10-20)
├── Added "Which method should I use?" section (lines 68-83)
├── Comparison section: Added note + subheadings (lines 153-260)
├── Added "Next Steps" section (lines 281-283)
└── References section: Updated Magirr, removed versions, added DOIs (lines 285-306)
```

## Related Documentation

- Plan: `.planning/phases/03-vignette-review/03-01-PLAN.md`
- Research: `.planning/phases/03-vignette-review/03-RESEARCH.md`
- Context: `.planning/phases/03-vignette-review/03-CONTEXT.md`
- Vignette: `vignettes/estimand_and_implementations.Rmd`

---

**Status:** ✅ Complete
**Quality:** All success criteria met, all locked decisions honored
**Next:** Plan 03-02 (Clinical Trial Table Vignette Polish)
