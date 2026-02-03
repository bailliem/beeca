# ARD Expansion Plans: Alignment with Existing Planning

**Created:** 2026-02-02
**Purpose:** Validate ARD expansion plans against existing project planning materials
**Status:** Validated ✅

---

## Executive Summary

The ARD expansion plans (ARD-EXPANSION-PLAN.md, ARD-INTEGRATION-DECISION.md) have been validated against existing planning materials. **No conflicts identified.** These plans represent future development (post v0.3.0 release) and align with existing enhancement roadmap.

**Key Finding:** Plans are **additive and complementary** to current v0.3.0 release work, not conflicting.

---

## Alignment Matrix

### 1. Project Scope Alignment

| Existing Planning | ARD Expansion Plans | Alignment Status |
|-------------------|---------------------|------------------|
| **PROJECT.md:** v0.3.0 Release Readiness | Plans target v0.4.0, v0.5.0, v0.6.0 (future) | ✅ **Non-overlapping** |
| **ROADMAP.md:** Phases 1-4 for v0.3.0 | ARD plans are post-Phase 4 | ✅ **Sequential** |
| **REQUIREMENTS.md:** Build, docs, vignettes, release prep | ARD plans are new features (out of scope for v0.3.0) | ✅ **Separate scope** |
| **STATE.md:** Currently at Phase 1 complete, moving to Phase 2 | ARD plans don't affect Phase 2-4 execution | ✅ **No interference** |

**Verdict:** ✅ **No scope conflicts.** ARD plans are clearly marked as future development.

---

### 2. Feature Alignment with ENHANCEMENTS.md

The ARD expansion plans directly elaborate on **ENHANCEMENTS.md Section 4.1**:

**ENHANCEMENTS.md Section 4.1: Enhanced cards/cardx Integration**
```
Priority: Medium-High
Description: Native cards ARD output option.

get_marginal_effect(..., ard_format = c("beeca", "cards"))

# Or conversion
as_card(fit1$marginal_results, add_formatting = TRUE)
```

**ARD-EXPANSION-PLAN.md provides:**
- ✅ Detailed design for this enhancement
- ✅ Extends to multiple formats (cards, CDISC ARS, custom)
- ✅ Adds metadata enrichment strategy
- ✅ Phased implementation roadmap
- ✅ Testing and documentation plan

**Relationship:** ARD expansion plans are **detailed specifications** for ENHANCEMENTS.md Section 4.1.

**Additional alignments:**
- ENHANCEMENTS.md 4.3 (Table Generation) → ARD plans enable via standardized formats
- ENHANCEMENTS.md 7.2 (CDISC/ADaM Integration) → ARD plans include CDISC ARS converter
- ENHANCEMENTS.md 7.4 (SAS Macro Compatibility) → ARD plans preserve beeca's current format

**Verdict:** ✅ **Strong alignment.** ARD plans directly implement ENHANCEMENTS.md priorities.

---

### 3. Architecture Alignment

**ARCHITECTURE.md describes existing ARD system:**

**Current State:**
- ARD generated in `get_marginal_effect()` (ARCHITECTURE.md lines 93-101)
- Structure: TRTVAR, TRTVAL, PARAM, ANALTYP1, STAT, STATVAL, ANALMETH, ANALDESC
- Output: `fit$marginal_results` tibble
- Converter: `beeca_to_cards_ard()` exists (R/beeca_to_cards_ard.R)

**ARD Expansion Plans propose:**
- ✅ **Keep existing ARD structure** (no changes to ARCHITECTURE.md flow)
- ✅ **Add metadata as attributes** (non-breaking, invisible to existing flow)
- ✅ **Add converter layer** (new abstraction, doesn't affect core pipeline)
- ✅ **Extend beeca S3 object** (add `beeca_metadata()` method)

**Integration Points:**

1. **Layer: ARD Generation & Integration** (ARCHITECTURE.md lines 93-101)
   - Current: Constructs `$marginal_results` tibble in `get_marginal_effect()`
   - Proposed change (v0.4.0):
     ```r
     # After creating marginal_results:
     attr(object$marginal_results, "beeca_metadata") <- list(
       analysis_id = analysis_id %||% generate_analysis_id(),
       created_at = Sys.time(),
       software = list(...),
       model = list(...),
       method = list(...),
       formatting = list(...)
     )
     ```
   - Impact: **Additive only, no disruption to existing flow**

2. **Key Abstraction: The ARD** (ARCHITECTURE.md lines 176-180)
   - Current definition preserved
   - Proposed: Add metadata as attributes (ARCHITECTURE.md doesn't forbid attributes)
   - Impact: **Extends abstraction, doesn't redefine it**

3. **Extensibility** (ARCHITECTURE.md lines 263-266)
   - Current: S3 methods for output, adding contrasts, adding variance methods
   - Proposed: Add converter registration system
   - Impact: **New extensibility dimension, consistent with existing patterns**

**Verdict:** ✅ **Architecturally sound.** Plans extend existing architecture without breaking it.

---

### 4. Timeline Alignment

**Existing Timeline (from ROADMAP.md, STATE.md):**

```
NOW (2026-02-02): Phase 1 complete, entering Phase 2
Phase 2: Documentation Review (TBD duration)
Phase 3: Vignette Review (TBD duration)
Phase 4: Release Preparation (TBD duration)
Target: v0.3.0 GitHub release (date TBD)
```

**ARD Expansion Timeline (from ARD-EXPANSION-PLAN.md):**

```
Q2 2026: v0.4.0 - Phase 1: Metadata Enrichment (2-3 weeks)
Q3 2026: v0.5.0 - Phase 2: Converter Infrastructure (3-4 weeks)
Q4 2026: v0.6.0 - Phase 3: Extensibility API (4-5 weeks)
```

**Sequencing Analysis:**

```
┌─────────────────────────────────────────────────────────────┐
│  Current v0.3.0 Release Work (Priority 1)                   │
│  ├─ Phase 2: Documentation Review                           │
│  ├─ Phase 3: Vignette Review                                │
│  ├─ Phase 4: Release Preparation                            │
│  └─ TAG: v0.3.0                                             │
└───────────────────────────┬─────────────────────────────────┘
                            │
                            ▼ (After v0.3.0 release)
┌─────────────────────────────────────────────────────────────┐
│  Future ARD Expansion Work (Priority 2)                     │
│  ├─ Q2 2026: v0.4.0 - Metadata (Phase 1)                    │
│  ├─ Q3 2026: v0.5.0 - Converters (Phase 2)                  │
│  └─ Q4 2026: v0.6.0 - Extensibility (Phase 3)               │
└─────────────────────────────────────────────────────────────┘
```

**Dependency:** ARD expansion phases **require v0.3.0 release complete** first.

**Verdict:** ✅ **Timelines are sequential and non-conflicting.**

---

### 5. Requirements Alignment

**REQUIREMENTS.md (v0.3.0):**

Active requirements:
- [ ] DOCS-01: README reflects v0.3.0 features
- [ ] DOCS-02: All functions have man pages
- [ ] DOCS-03: pkgdown builds
- [ ] VIG-01: ARD vignette is clear
- [ ] VIG-02: Clinical trial reporting vignette complete
- [ ] VIG-03: All vignettes render
- [ ] REL-01: NEWS.md updated
- [ ] REL-02: DESCRIPTION version = 0.3.0
- [ ] REL-03: Lifecycle deprecations handled

**ARD Expansion Plans propose new requirements (for v0.4.0+):**

None of these affect v0.3.0 requirements. New requirements would be:
- [ ] META-01: Metadata structure implemented (v0.4.0)
- [ ] META-02: beeca_metadata() extractor works (v0.4.0)
- [ ] CONV-01: beeca_to_ard() dispatcher implemented (v0.5.0)
- [ ] CONV-02: beeca_to_cdisc_ard() works (v0.5.0)
- [ ] CONV-03: Converter registration system works (v0.5.0)
- [ ] EXT-01: Subgroup analysis support (v0.6.0)
- [ ] EXT-02: Custom statistic registration (v0.6.0)

**Verdict:** ✅ **No requirements overlap.** ARD plans create new requirements for future versions.

---

### 6. Technical Debt & Risk Analysis

**Existing Concerns (from STATE.md):**

Phase 1 Complete:
- ✓ Vignette error fixed
- ✓ beeca_to_cards_ard() has 0% test coverage (accepted as gap)
- ✓ ggplot2 deprecation deferred

**ARD Plans address:**
- ✅ **Test coverage gap:** Phase 2 (v0.5.0) includes comprehensive converter tests
- ✅ **Future-proofing:** Metadata and converter infrastructure prevent future tech debt

**New risks introduced by ARD plans:**
- ⚠️ **Maintenance burden:** Multiple converters to maintain
  - *Mitigation:* Only core standards (cards, CDISC), extensibility for custom
- ⚠️ **Version drift:** External standards evolve
  - *Mitigation:* Versioned converters, documented standard versions
- ⚠️ **Complexity increase:** More code surface area
  - *Mitigation:* Clear separation of concerns, comprehensive tests

**Verdict:** ⚠️ **New risks are manageable** with proposed mitigations.

---

## Integration Points Summary

### Where ARD Plans Touch Existing Code

1. **R/get_marginal_effect.R** (v0.4.0)
   - Add metadata attribute after creating `marginal_results`
   - 5-10 lines of code addition
   - Non-breaking change

2. **R/beeca_to_cards_ard.R** (v0.4.0)
   - Enhance to use `beeca_metadata()` for richer conversion
   - Backward compatible (metadata optional)

3. **New files** (v0.4.0-v0.6.0):
   - R/metadata.R (NEW) - `beeca_metadata()`, print method
   - R/converters.R (NEW) - `beeca_to_ard()`, registration system
   - R/beeca_to_cdisc_ard.R (NEW) - CDISC ARS converter
   - R/extensibility.R (NEW) - Custom stat registration
   - tests/testthat/test-metadata.R (NEW)
   - tests/testthat/test-converters.R (NEW)

4. **Documentation** (v0.4.0-v0.6.0):
   - man/beeca_metadata.Rd (NEW)
   - man/beeca_to_ard.Rd (NEW)
   - man/beeca_to_cdisc_ard.Rd (NEW)
   - vignettes/ard-metadata.Rmd (NEW)
   - vignettes/ard-conversion.Rmd (NEW)

**All additions, no modifications to existing v0.3.0 code paths.**

---

## Decision Validation

**ARD-INTEGRATION-DECISION.md recommends: Hybrid Approach (Option 3)**

Validated against existing decisions:

**From PROJECT.md Key Decisions:**
- ✅ "GitHub release (not CRAN)": ARD plans compatible with GitHub-first strategy
- ✅ "Version 0.3.0 (minor bump)": ARD plans propose 0.4.0, 0.5.0, 0.6.0 (correct versioning)
- ✅ "Focus on vignette quality": ARD plans include comprehensive vignette strategy

**From STATE.md accumulated decisions:**
- ✅ "beeca_to_cards_ard() 0% coverage accepted": ARD Phase 2 adds tests (resolves gap)
- ✅ "ggplot2 deprecation deferred": ARD plans don't touch plot functionality (orthogonal)

**Verdict:** ✅ **Decision is consistent with existing project philosophy.**

---

## Conflicts & Resolutions

### Potential Conflict 1: Phase Numbering

**Issue:** ROADMAP.md uses Phases 1-4 for v0.3.0. ARD-EXPANSION-PLAN.md uses Phases 1-3 for v0.4.0-v0.6.0.

**Resolution:** ✅ **Not a conflict - different context**
- ROADMAP.md phases are for v0.3.0 release
- ARD expansion phases are for post-v0.3.0 development
- Recommendation: Rename ARD expansion phases to avoid confusion:
  - ARD Phase 1 → "ARD Expansion: Metadata Phase"
  - ARD Phase 2 → "ARD Expansion: Converter Phase"
  - ARD Phase 3 → "ARD Expansion: Extensibility Phase"

### Potential Conflict 2: Current Focus vs. Future Planning

**Issue:** STATE.md says "Current focus: Phase 1 - Build Validation" for v0.3.0, but ARD plans discuss v0.4.0.

**Resolution:** ✅ **Not a conflict - these are strategic planning documents**
- ARD plans are **planning materials**, not implementation work
- No execution until after v0.3.0 release complete
- These documents belong in `.planning/` for future reference

### Potential Conflict 3: Out of Scope vs. New Features

**Issue:** PROJECT.md says "Out of Scope: New features - review and polish existing functionality"

**Resolution:** ✅ **Not a conflict - ARD plans are for POST v0.3.0**
- v0.3.0 scope: No new features (confirmed)
- ARD plans: Explicitly target v0.4.0+ (after v0.3.0 release)
- These plans support "future considerations" mentioned in ENHANCEMENTS.md

---

## Recommendations

### 1. Document Metadata Updates

**Action:** Add reference to ARD expansion plans in existing planning docs

**ENHANCEMENTS.md update:**
```markdown
### 4.1 Enhanced cards/cardx Integration
**Priority:** Medium-High
**Description:** Native cards ARD output option.

**Status:** Detailed planning complete (see .planning/ARD-EXPANSION-PLAN.md)
**Target:** v0.4.0 (Q2 2026)

get_marginal_effect(..., ard_format = c("beeca", "cards"))

# Or conversion
as_card(fit1$marginal_results, add_formatting = TRUE)
```

### 2. Create Post-v0.3.0 Roadmap Section

**Action:** Add to ROADMAP.md after Phase 4:

```markdown
## Future Development (Post v0.3.0)

### ARD Expansion Initiative
**Timeline:** Q2-Q4 2026
**Planning:** See .planning/ARD-EXPANSION-PLAN.md

- v0.4.0 (Q2): Metadata enrichment
- v0.5.0 (Q3): Converter infrastructure
- v0.6.0 (Q4): Extensibility API

Full details in:
- .planning/ARD-EXPANSION-PLAN.md (technical design)
- .planning/ARD-INTEGRATION-DECISION.md (strategic rationale)
- .planning/ARD-PLANS-ALIGNMENT.md (validation against existing plans)
```

### 3. Add Note to PROJECT.md

**Action:** Add to PROJECT.md Context section:

```markdown
**Future Development:**
ARD expansion plans for v0.4.0-v0.6.0 are documented in .planning/ but are
out of scope for v0.3.0 release. See ARD-EXPANSION-PLAN.md for post-release
roadmap.
```

---

## Validation Summary

| Validation Criterion | Status | Notes |
|---------------------|--------|-------|
| Scope alignment | ✅ Pass | No overlap with v0.3.0 work |
| Feature alignment | ✅ Pass | Elaborates ENHANCEMENTS.md 4.1 |
| Architecture alignment | ✅ Pass | Extends without breaking |
| Timeline alignment | ✅ Pass | Sequential, post-v0.3.0 |
| Requirements alignment | ✅ Pass | New reqs for future versions |
| Existing decisions | ✅ Pass | Consistent with project philosophy |
| Integration alignment | ✅ Pass | Builds on existing cards support |
| Concerns addressed | ✅ Pass | Resolves ARD documentation & test gaps |
| Technical debt | ⚠️ Managed | New risks have mitigations |
| Conflicts | ✅ None | Minor naming clarifications needed |

**Overall Validation:** ✅ **APPROVED**

---

## Additional Validations

### Integration with Existing Cards Support

**From INTEGRATIONS.md (lines 118-132):**

Current state:
- `beeca_to_cards_ard()` exists in `R/beeca_to_cards_ard.R`
- Converts beeca ARD to cards/CDISC ARD format
- Soft dependency (Suggests)
- Error handling for missing cards package

**ARD Plans alignment:**
- ✅ Plans build on existing `beeca_to_cards_ard()` (enhance, not replace)
- ✅ Plans maintain soft dependency pattern (cards in Suggests)
- ✅ Plans add similar functions for CDISC ARS (consistent pattern)
- ✅ Plans preserve existing error handling approach

**Recommendation:** ARD expansion enhances existing integration, no conflicts.

---

### Addressing Known Concerns

**From CONCERNS.md:**

**1. Incomplete ARD Column Documentation (lines 34-39)**
- Issue: ANALDESC column format not documented, version string unparseable
- Impact: Consumers cannot reliably parse metadata
- **ARD Plans address:** Phase 1 (v0.4.0) metadata structure resolves this
  - Structured metadata in attributes (not ad-hoc string)
  - `beeca_metadata()` extractor provides programmatic access
  - Version info in `$software` list, not unparseable string

**2. Test Coverage Gaps (lines 136-160)**
- Issue: Multiple ARD-related test gaps identified
- Priority: High for gradient functions, Medium for ARD generation edge cases
- **ARD Plans address:** Phase 2 (v0.5.0) includes comprehensive converter tests
  - Edge case testing for metadata structure
  - Converter validation tests
  - Target: >95% coverage for new functionality

**3. cards Integration Test Coverage**
- Current: `beeca_to_cards_ard()` has 0% test coverage (from STATE.md)
- **ARD Plans address:** Phase 2 adds tests for all converters
  - Test existing `beeca_to_cards_ard()` thoroughly
  - Test new `beeca_to_cdisc_ard()`
  - Test converter registration system

**Verdict:** ✅ **ARD plans directly address documented concerns.**

---

## Next Actions

1. **Immediate:**
   - [x] Create ARD-PLANS-ALIGNMENT.md (this document)
   - [ ] Review alignment findings with maintainers

2. **Before starting ARD implementation:**
   - [ ] Complete v0.3.0 Phases 2-4 (documentation, vignettes, release)
   - [ ] Tag v0.3.0 release
   - [ ] Update ENHANCEMENTS.md to reference ARD plans
   - [ ] Add post-v0.3.0 section to ROADMAP.md

3. **When ready for v0.4.0:**
   - [ ] Create feature branch `feature/ard-metadata-v0.4.0`
   - [ ] Begin ARD Expansion Phase 1 (Metadata Enrichment)
   - [ ] Use ARD-EXPANSION-PLAN.md as implementation guide

---

## References

**Existing Planning Documents:**
- `.planning/PROJECT.md` - Project definition and core value
- `.planning/ROADMAP.md` - v0.3.0 phase roadmap
- `.planning/REQUIREMENTS.md` - v0.3.0 requirements
- `.planning/STATE.md` - Current project state
- `.planning/codebase/ARCHITECTURE.md` - Technical architecture
- `.planning/codebase/INTEGRATIONS.md` - External integrations and package dependencies
- `.planning/codebase/CONCERNS.md` - Known issues and tech debt
- `ENHANCEMENTS.md` - Future enhancement brainstorming

**New ARD Planning Documents:**
- `.planning/ARD-EXPANSION-PLAN.md` - Full technical design
- `.planning/ARD-INTEGRATION-DECISION.md` - Strategic decision analysis
- `.planning/ARD-PLANS-ALIGNMENT.md` - This document

---

**Validation Date:** 2026-02-02
**Validated By:** Claude (Sonnet 4.5)
**Approval Status:** Pending maintainer review

*Last updated: 2026-02-02*
