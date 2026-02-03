# ARD Reporting Expansion Plan

**Created:** 2026-02-02
**Status:** Planning
**Purpose:** Future-proof beeca's Analysis Results Data (ARD) reporting capabilities

## Executive Summary

This document outlines a strategic plan to expand beeca's ARD reporting capabilities to support evolving regulatory requirements, interoperability with downstream reporting tools, and alignment with emerging industry standards (CDISC ARS, cards/cardx ecosystem).

**Recommendation:** Adopt a **modular extensibility approach** that:
1. Preserves beeca's current CDISC-inspired ARD format as the internal standard
2. Provides pluggable converters for external formats (cards, CDISC ARS, custom)
3. Adds metadata enrichment capabilities for regulatory traceability
4. Maintains backward compatibility while enabling future expansion

---

## Current State Analysis

### beeca's Existing ARD Structure

Location: `get_marginal_effect()$marginal_results`

**Current Columns:**
```r
tibble::tibble(
  TRTVAR    = character,  # Treatment variable name
  TRTVAL    = character,  # Treatment level
  PARAM     = character,  # Outcome parameter
  ANALTYP1  = character,  # Analysis type: DESCRIPTIVE | INFERENTIAL
  STAT      = character,  # Statistic identifier (N, n, %, risk, risk_se, diff, diff_se, etc.)
  STATVAL   = numeric,    # Statistic value
  ANALMETH  = character,  # Analysis method (count, percentage, g-computation, HC0, etc.)
  ANALDESC  = character   # Analysis description (software version)
)
```

**Strengths:**
- ✅ CDISC-inspired naming conventions
- ✅ Captures both arm-level stats and contrasts
- ✅ Method metadata in ANALMETH
- ✅ Distinguishes descriptive vs. inferential stats
- ✅ Already has converter to cards format (`beeca_to_cards_ard()`)

**Gaps for Future-Proofing:**
- ❌ No structured context metadata (lists/attributes are lost in flat tibble)
- ❌ No formatting specifications (decimal places, display formats)
- ❌ No confidence intervals as separate rows
- ❌ Limited traceability (no analysis_id, result_id, or provenance chain)
- ❌ No support for subgroup analyses
- ❌ No extensibility mechanism for custom statistics

---

## Strategic Options

### Option A: Evolve beeca's ARD (Breaking Change)

**Approach:** Redesign `marginal_results` to align with a target external standard (e.g., cards or CDISC ARS).

**Pros:**
- Single source of truth
- Simpler mental model
- Eliminates converter layer

**Cons:**
- **Breaking change** for existing users
- Couples beeca to external standard evolution
- Requires coordinated release with dependent packages
- May not serve all use cases (cards vs. CDISC vs. custom)

**Verdict:** ❌ **Not recommended** — Too disruptive, reduces beeca's independence

---

### Option B: Converter Ecosystem (Current + Enhanced)

**Approach:** Keep beeca's ARD format, expand converter infrastructure.

**Current:**
- `beeca_to_cards_ard()` - Converts to cards package format

**Proposed Additions:**
```r
# Core converter interface
beeca_to_ard(fit, format = c("beeca", "cards", "cdisc_ars", "custom"), ...)

# Specific converters
beeca_to_cards_ard()   # Existing, enhanced
beeca_to_cdisc_ard()   # New - CDISC ARS compliance
beeca_to_custom_ard()  # New - User-defined schema

# Reverse converters (if needed)
ard_to_beeca()         # Import external ARD
```

**Pros:**
- ✅ Backward compatible
- ✅ Flexible - supports multiple standards
- ✅ beeca remains independent
- ✅ Users choose output format

**Cons:**
- Maintenance burden of multiple converters
- Risk of drift between formats
- Converters may need updates as external standards evolve

**Verdict:** ✅ **Recommended** — Balances flexibility with stability

---

### Option C: Modular Extensibility (Recommended)

**Approach:** Enhance beeca's internal ARD + pluggable converter system + metadata enrichment.

**Architecture:**

```
┌──────────────────────────────────────────────┐
│         beeca Core ARD Engine                │
│  (Enhanced marginal_results structure)       │
└──────────────┬───────────────────────────────┘
               │
               ├─ Metadata Layer (NEW)
               │  ├─ Context (method, call, software)
               │  ├─ Provenance (analysis_id, timestamps)
               │  └─ Formatting (decimal_places, labels)
               │
               ├─ Converter Layer
               │  ├─ beeca_to_cards_ard()
               │  ├─ beeca_to_cdisc_ard() [NEW]
               │  └─ beeca_to_custom_ard() [NEW]
               │
               └─ Extension API (NEW)
                  ├─ Register custom statistics
                  ├─ Add subgroup results
                  └─ Attach supplemental analyses
```

**Enhanced beeca ARD Structure:**

```r
# Core tibble (unchanged columns, but enriched attributes)
marginal_results <- tibble::tibble(
  TRTVAR   = ...,
  TRTVAL   = ...,
  PARAM    = ...,
  ANALTYP1 = ...,
  STAT     = ...,
  STATVAL  = ...,
  ANALMETH = ...,
  ANALDESC = ...
)

# NEW: Rich attributes for metadata (no breaking change to tibble structure)
attr(marginal_results, "beeca_metadata") <- list(
  analysis_id = "BEECA-2026-001",
  created_at = Sys.time(),
  software = list(
    package = "beeca",
    version = packageVersion("beeca"),
    r_version = R.version.string
  ),
  model = list(
    formula = deparse(fit$formula),
    family = fit$family$family,
    n_obs = nrow(fit$data)
  ),
  method = list(
    variance = attr(fit$marginal_se, "type"),
    contrast = attr(fit$marginal_est, "contrast"),
    reference = attr(fit$marginal_est, "reference")
  ),
  formatting = list(
    risk = list(decimal_places = 3, label = "Risk"),
    diff = list(decimal_places = 3, label = "Risk Difference"),
    pvalue = list(decimal_places = 4, label = "P-value", format_fn = "format.pval")
  )
)

# NEW: Optional subgroup results (extensibility)
attr(marginal_results, "subgroups") <- NULL  # Populated by future get_marginal_effect(..., subgroups = ...)
```

**Implementation Phases:**

1. **v0.4.0: Metadata Enrichment** (Non-breaking)
   - Add `beeca_metadata` attribute structure
   - Enhance `beeca_to_cards_ard()` to use metadata
   - Add `beeca_metadata()` extractor function

2. **v0.5.0: Converter Infrastructure** (Non-breaking)
   - Add `beeca_to_ard()` generic dispatcher
   - Implement `beeca_to_cdisc_ard()` converter
   - Add converter registration system

3. **v0.6.0: Extensibility API** (Non-breaking)
   - Add subgroup analysis support
   - Custom statistic registration
   - ARD composition/binding utilities

**Pros:**
- ✅ Backward compatible (attributes don't break existing code)
- ✅ Incremental rollout (phased approach)
- ✅ Future-proof (extensible without breaking changes)
- ✅ Standards-agnostic (supports cards, CDISC, custom)
- ✅ Rich metadata without restructuring core tibble

**Cons:**
- More complex architecture
- Requires careful API design
- Documentation burden

**Verdict:** ✅✅ **Strongly Recommended** — Best long-term strategy

---

## Integration with External Ecosystems

### 1. cards Package (Insights Engineering)

**Current State:** `beeca_to_cards_ard()` exists (R/beeca_to_cards_ard.R)

**cards Format:**
```r
tibble::tibble(
  group1 = character,
  group1_level = list,      # List-column
  variable = character,
  variable_level = character,
  stat_name = character,
  stat_label = character,
  stat = list,              # List-column
  context = character,
  fmt_fn = list,            # List-column
  warning = list,
  error = list
) %>%
  cards::as_card()
```

**Enhancement Plan:**
- ✅ Leverage new `beeca_metadata` attributes
- Add confidence intervals as separate stat_name rows
- Preserve full context in `context` column
- Add formatter functions in `fmt_fn` based on `formatting` metadata

---

### 2. CDISC Analysis Results Standard (ARS)

**Target:** CDISC Analysis Results Data Model (ADaM derivatives)

**Proposed Converter:** `beeca_to_cdisc_ard()`

**CDISC ARS Alignment:**
```r
beeca_to_cdisc_ard <- function(fit,
                               analysis_id = "AN01",
                               display_id = "T-01.01",
                               ...) {
  # Maps to CDISC columns
  tibble::tibble(
    ANALYSIS_ID = analysis_id,
    DISPLAY_ID = display_id,
    RESULT_ID = paste0(analysis_id, "-", seq_len(nrow(...))),
    CATEGORY_ID = ...,      # Maps from ANALTYP1
    GROUP_ID = ...,         # Maps from TRTVAR
    GROUP_LEVEL = ...,      # Maps from TRTVAL
    RESULT_TYPE = ...,      # Maps from STAT
    RESULT_VALUE = ...,     # Maps from STATVAL
    RESULT_LABEL = ...,
    RESULT_METHOD = ...,    # Maps from ANALMETH
    # ... additional CDISC ARS columns
  )
}
```

**Reference:** [CDISC Analysis Results Standard](https://www.cdisc.org/standards/foundational/analysis-results-standard)

---

### 3. Custom ARD Formats

**Use Case:** Organization-specific reporting standards

**Proposed API:**
```r
# User-defined converter
beeca_to_custom_ard <- function(fit,
                                template = list(
                                  col_mapping = list(
                                    TRTVAR = "treatment_variable",
                                    STAT = "statistic_name",
                                    STATVAL = "value"
                                  ),
                                  add_columns = c("study_id", "protocol"),
                                  format_rules = list(...)
                                )) {
  # Apply custom transformation
}

# Registration system
register_ard_converter("my_org_ard", function(fit, ...) {
  # Custom logic
})

# Usage
fit %>% beeca_to_ard(format = "my_org_ard")
```

---

## Detailed Implementation Plan

### Phase 1: Metadata Enrichment (v0.4.0)

**Timeline:** Q2 2026
**Effort:** 2-3 weeks
**Breaking:** No

**Tasks:**

1. **Add metadata attribute structure** (R/get_marginal_effect.R)
   ```r
   # In get_marginal_effect(), after creating marginal_results:
   attr(object$marginal_results, "beeca_metadata") <- list(
     analysis_id = analysis_id %||% generate_analysis_id(),
     created_at = Sys.time(),
     software = list(...),
     model = list(...),
     method = list(...),
     formatting = list(...)
   )
   ```

2. **Add metadata extractor** (R/metadata.R - NEW)
   ```r
   #' Extract beeca metadata
   #' @export
   beeca_metadata <- function(x) {
     if (inherits(x, "beeca")) {
       attr(x$marginal_results, "beeca_metadata")
     } else {
       attr(x, "beeca_metadata")
     }
   }

   #' @export
   print.beeca_metadata <- function(x, ...) {
     cat("beeca Analysis Metadata\n")
     cat("─────────────────────────\n")
     cat("Analysis ID:", x$analysis_id, "\n")
     cat("Created:", format(x$created_at), "\n")
     cat("Method:", x$method$variance, "\n")
     cat("Contrast:", x$method$contrast, "\n")
     invisible(x)
   }
   ```

3. **Enhance beeca_to_cards_ard()** (R/beeca_to_cards_ard.R)
   - Use `beeca_metadata()$formatting` for `fmt_fn`
   - Add method details to `context` column
   - Preserve analysis_id

4. **Update documentation**
   - Add `beeca_metadata()` man page
   - Update `get_marginal_effect()` docs to mention metadata
   - Add metadata vignette section

5. **Tests** (tests/testthat/test-metadata.R - NEW)
   - Test metadata structure
   - Test metadata extraction
   - Test print method

**Success Criteria:**
- [ ] `get_marginal_effect()` attaches metadata attributes
- [ ] `beeca_metadata()` extracts metadata successfully
- [ ] `print.beeca_metadata()` displays readable summary
- [ ] `beeca_to_cards_ard()` leverages metadata
- [ ] All existing tests pass (backward compatibility)
- [ ] New metadata tests achieve >95% coverage

---

### Phase 2: Converter Infrastructure (v0.5.0)

**Timeline:** Q3 2026
**Effort:** 3-4 weeks
**Breaking:** No

**Tasks:**

1. **Create converter generic** (R/converters.R - NEW)
   ```r
   #' Convert beeca results to various ARD formats
   #'
   #' @param fit A beeca object
   #' @param format Target format: "beeca", "cards", "cdisc_ars", or registered custom format
   #' @param ... Additional arguments passed to specific converter
   #' @export
   beeca_to_ard <- function(fit,
                            format = c("beeca", "cards", "cdisc_ars"),
                            ...) {
     format <- match.arg(format, choices = c("beeca", "cards", "cdisc_ars", names(.converter_registry)))

     if (format == "beeca") {
       return(fit$marginal_results)
     }

     converter <- switch(format,
       cards = beeca_to_cards_ard,
       cdisc_ars = beeca_to_cdisc_ard,
       .converter_registry[[format]]  # Custom converters
     )

     converter(fit$marginal_results, ...)
   }
   ```

2. **Implement CDISC ARS converter** (R/beeca_to_cdisc_ard.R - NEW)
   ```r
   #' Convert beeca results to CDISC ARS format
   #'
   #' @param marginal_results beeca marginal_results tibble
   #' @param analysis_id CDISC analysis identifier
   #' @param display_id CDISC display identifier
   #' @export
   beeca_to_cdisc_ard <- function(marginal_results,
                                   analysis_id = "AN01",
                                   display_id = "T-01.01",
                                   ...) {
     # Map beeca columns to CDISC ARS
     # ...
   }
   ```

3. **Add converter registration system** (R/converters.R)
   ```r
   .converter_registry <- new.env()

   #' Register custom ARD converter
   #' @export
   register_ard_converter <- function(name, converter_fn) {
     stopifnot(is.function(converter_fn))
     .converter_registry[[name]] <- converter_fn
     invisible(NULL)
   }

   #' List registered converters
   #' @export
   list_ard_converters <- function() {
     c("beeca", "cards", "cdisc_ars", names(.converter_registry))
   }
   ```

4. **Documentation**
   - Add ARD conversion vignette
   - Document CDISC ARS mapping
   - Show custom converter examples

5. **Tests** (tests/testthat/test-converters.R - NEW)
   - Test `beeca_to_ard()` dispatcher
   - Test CDISC converter
   - Test registration system

**Success Criteria:**
- [ ] `beeca_to_ard()` dispatches to correct converter
- [ ] `beeca_to_cdisc_ard()` produces valid CDISC ARS structure
- [ ] Custom converter registration works
- [ ] All converters preserve metadata
- [ ] Vignette demonstrates all formats

---

### Phase 3: Extensibility API (v0.6.0)

**Timeline:** Q4 2026
**Effort:** 4-5 weeks
**Breaking:** No

**Tasks:**

1. **Subgroup analysis support** (R/get_marginal_effect.R)
   ```r
   get_marginal_effect <- function(...,
                                   subgroups = NULL,  # NEW parameter
                                   ...) {
     # Main analysis
     object <- ...

     # If subgroups requested
     if (!is.null(subgroups)) {
       object$marginal_results <- add_subgroup_results(
         object,
         subgroups = subgroups
       )
     }
   }
   ```

2. **Custom statistic registration** (R/extensibility.R - NEW)
   ```r
   #' Add custom statistic to ARD
   #' @export
   add_custom_stat <- function(fit,
                               stat_name,
                               stat_fn,
                               stat_label = stat_name) {
     # Compute custom statistic
     custom_val <- stat_fn(fit)

     # Append to marginal_results
     fit$marginal_results <- bind_rows(
       fit$marginal_results,
       tibble(
         TRTVAR = fit$trt,
         TRTVAL = "Overall",
         PARAM = ...,
         ANALTYP1 = "CUSTOM",
         STAT = stat_name,
         STATVAL = custom_val,
         ANALMETH = "custom",
         ANALDESC = stat_label
       )
     )

     fit
   }
   ```

3. **ARD composition utilities** (R/ard_utils.R - NEW)
   ```r
   #' Bind multiple beeca ARD objects
   #' @export
   bind_beeca_ard <- function(...) {
     # Combine multiple analyses
   }

   #' Filter beeca ARD
   #' @export
   filter_beeca_ard <- function(ard,
                                stat_type = NULL,
                                trt_level = NULL) {
     # Subset ARD
   }
   ```

4. **Documentation**
   - Extensibility vignette
   - Subgroup analysis examples
   - Custom statistic examples

5. **Tests**
   - Test subgroup functionality
   - Test custom statistic addition
   - Test ARD composition

**Success Criteria:**
- [ ] Subgroup analyses append to ARD
- [ ] Custom statistics integrate seamlessly
- [ ] Composition utilities work
- [ ] Documentation is comprehensive

---

## Migration Path for Users

### Non-Breaking Evolution

All phases maintain **100% backward compatibility**:

```r
# Existing code continues to work unchanged
fit <- glm(aval ~ trtp + bl_cov, family = "binomial", data = trial01) %>%
  get_marginal_effect(trt = "trtp", method = "Ye")

fit$marginal_results  # Still works exactly as before

# New functionality is additive
beeca_metadata(fit)   # NEW - extract metadata
fit %>% beeca_to_ard(format = "cdisc_ars")  # NEW - convert to CDISC
```

### Deprecation (if needed in future)

If columns need to change (unlikely):

1. **v0.x.0**: Add new columns, keep old columns
2. **v0.y.0**: Deprecate old columns with `.Deprecated()` warnings
3. **v1.0.0**: Remove old columns (major version bump)

---

## Testing Strategy

### Unit Tests

For each phase:
- Test core functionality
- Test edge cases
- Test backward compatibility
- Achieve >95% coverage

### Integration Tests

- Full workflow: `glm()` → `get_marginal_effect()` → converters
- Multi-format conversion pipelines
- Subgroup + custom statistics

### Cross-Package Validation

- Verify `cards` package integration
- Test with downstream packages (if any)
- Validate CDISC ARS compliance with external tools

---

## Documentation Requirements

### New Vignettes

1. **ARD Metadata Guide** (v0.4.0)
   - What metadata is captured
   - How to access metadata
   - Using metadata for reporting

2. **ARD Conversion Guide** (v0.5.0)
   - Converting to cards format
   - Converting to CDISC ARS
   - Creating custom converters

3. **Extending beeca ARD** (v0.6.0)
   - Subgroup analyses
   - Custom statistics
   - Composing complex ARDs

### Updated Documentation

- `get_marginal_effect()` man page - document new parameters
- README - show ARD conversion examples
- Package vignette index

---

## Risk Assessment

| Risk | Likelihood | Impact | Mitigation |
|------|------------|--------|------------|
| Breaking changes upset users | Low | High | Maintain strict backward compatibility |
| External standards evolve | Medium | Medium | Use converter pattern, isolate changes |
| Complexity increases maintenance burden | Medium | Medium | Comprehensive tests, clear documentation |
| Converters drift from standards | Low | Medium | Automated validation, version pinning |
| Performance degradation | Low | Low | Profile, optimize metadata handling |

---

## Decision Points

### Decision 1: Metadata Storage Mechanism

**Options:**
A. Attributes (recommended)
B. Nested list-columns
C. Separate metadata object

**Chosen:** A (Attributes)
**Rationale:** Non-breaking, R-native, preserved by most operations

---

### Decision 2: Converter Pattern

**Options:**
A. S3 methods (`as.data.frame.beeca()`, etc.)
B. Explicit converter functions (`beeca_to_cards_ard()`)
C. Generic dispatcher (`beeca_to_ard(format = ...)`)

**Chosen:** C (Generic dispatcher) with B (explicit functions) underneath
**Rationale:** Flexibility + discoverability + extensibility

---

### Decision 3: CDISC ARS Compliance

**Options:**
A. Full CDISC ARS conformance (all required columns)
B. Partial mapping (core columns only)
C. Defer to future based on demand

**Chosen:** B initially, evolve to A based on user feedback
**Rationale:** Balance pragmatism with standards alignment

---

## Success Metrics

### Technical Metrics
- ✅ 100% backward compatibility (no failing existing tests)
- ✅ >95% test coverage for new functionality
- ✅ R CMD check passes with no errors/warnings
- ✅ Converters produce valid ARD structures

### User Adoption Metrics
- Number of users adopting new converters
- GitHub issues requesting ARD features
- Downloads of vignettes
- Community contributions to converters

### Quality Metrics
- Documentation clarity (user feedback)
- Vignette completion rates
- Support burden (issue volume)

---

## Open Questions

1. **Should beeca depend on cards package, or keep it in Suggests?**
   - Current: Suggests (soft dependency)
   - Recommendation: Keep in Suggests (beeca remains lightweight)

2. **What CDISC ARS version should we target?**
   - Recommendation: CDISC ARS 1.1 (current stable version as of 2026)
   - Action: Monitor CDISC updates, version converter if needed

3. **Should subgroup analysis be in core get_marginal_effect() or separate function?**
   - Option A: `get_marginal_effect(..., subgroups = c("age", "sex"))`
   - Option B: `get_marginal_effect_subgroups(fit, subgroups = ...)`
   - Recommendation: Defer to Phase 3 planning based on user research

4. **How should confidence intervals be represented in ARD?**
   - Current: Not in ARD
   - Option A: Separate rows (STAT = "diff_ci_lower", "diff_ci_upper")
   - Option B: List-column
   - Option C: Both (flat for beeca, list-column in cards)
   - Recommendation: A (separate rows for consistency)

---

## Next Steps

1. **Immediate (This Session):**
   - ✅ Draft this planning document
   - [ ] Review with maintainers
   - [ ] Prioritize phases based on user demand

2. **Phase 1 Kickoff (v0.4.0 - Q2 2026):**
   - Create feature branch
   - Implement metadata structure
   - Write tests
   - Draft vignette

3. **Community Engagement:**
   - Present plan to ASA-BIOP CARS Working Group
   - Solicit feedback on CDISC ARS requirements
   - Survey users on converter priorities

---

## Appendix: Reference Materials

### CDISC Analysis Results Standard
- [CDISC ARS Documentation](https://www.cdisc.org/standards/foundational/analysis-results-standard)
- [CDISC GitHub](https://github.com/cdisc-org)

### cards Package
- [cards R package](https://insightsengineering.github.io/cards/)
- [cardx R package](https://insightsengineering.github.io/cardx/)

### Related Initiatives
- [ASA-BIOP CARS Working Group](https://carswg.github.io/)
- [R Consortium Submissions Working Group](https://rconsortium.github.io/submissions-wg/)

---

**Document Status:** Draft
**Review Required:** Yes
**Approvers:** beeca maintainers, ASA-BIOP CARS WG

*Last updated: 2026-02-02*
