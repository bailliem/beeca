# ARD Integration Decision: Change beeca's API or Handle in Consuming Packages?

**Created:** 2026-02-02
**Decision Status:** Recommended (Pending Approval)
**Related:** ARD-EXPANSION-PLAN.md

## The Question

You asked: **"Can we change the ARD API in beeca or handle it in consuming packages?"**

This document provides a clear recommendation with detailed analysis.

---

## TL;DR Recommendation

**Recommended Approach: Hybrid Strategy**

✅ **Keep beeca's current ARD format** as the internal standard (TRTVAR, TRTVAL, PARAM, STAT, STATVAL, etc.)
✅ **Enhance beeca** with metadata attributes and converter infrastructure
✅ **Let consuming packages choose** via `beeca_to_ard(format = "cards" | "cdisc_ars" | "custom")`
✅ **Provide adapters** so consuming packages can work directly with beeca output

**Why:** Maximizes flexibility, maintains stability, avoids coupling beeca to external standards.

---

## Option Analysis

### Option 1: Change beeca's ARD API

**What this means:**
- Modify `get_marginal_effect()$marginal_results` structure
- Align with a target standard (e.g., cards or CDISC ARS)
- Breaking change requiring major version bump (v1.0.0)

**Example: If we aligned with cards package:**

```r
# Current beeca ARD
fit$marginal_results
#> # A tibble: 20 × 8
#>   TRTVAR TRTVAL PARAM ANALTYP1    STAT     STATVAL ANALMETH    ANALDESC
#>   <chr>  <chr>  <chr> <chr>       <chr>      <dbl> <chr>       <chr>
#> 1 trtp   0      aval  DESCRIPTIVE N        200     count       beeca@0.3.0
#> 2 trtp   0      aval  DESCRIPTIVE n         89     count       beeca@0.3.0
#> 3 trtp   0      aval  INFERENTIAL risk       0.445 g-computation beeca@0.3.0

# After changing to cards format
fit$marginal_results
#> # A tibble: 20 × 11
#>   group1 group1_level variable variable_level stat_name stat_label stat    context fmt_fn warning error
#>   <chr>  <list>       <chr>    <chr>          <chr>     <chr>      <list>  <chr>   <list> <list>  <list>
#> 1 trtp   <chr [1]>    aval     <NA>           N         N          <dbl>   ...     <NULL> <NULL>  <NULL>
#> 2 trtp   <chr [1]>    aval     <NA>           n         n          <dbl>   ...     <NULL> <NULL>  <NULL>
```

#### Pros
- ✅ Single source of truth - one ARD format
- ✅ Direct compatibility with cards ecosystem
- ✅ Potential for tighter integration with downstream tools

#### Cons
- ❌ **Breaking change** - existing code breaks
  ```r
  # This breaks after changing to cards format
  fit$marginal_results %>%
    filter(STAT == "diff")  # Column STAT no longer exists!
  ```
- ❌ **User disruption** - existing scripts, vignettes, teaching materials all break
- ❌ **Couples beeca to external standard** - if cards changes, beeca must change
- ❌ **Loss of control** - beeca's API now determined by external package
- ❌ **Migration burden** - users must update code, packages must update dependencies
- ❌ **Doesn't solve multi-standard problem** - what if users need CDISC ARS format instead?

#### Migration Pain Example

Users would need to rewrite code like this:

```r
# Before (current beeca)
fit$marginal_results %>%
  filter(ANALTYP1 == "INFERENTIAL", STAT == "diff") %>%
  select(TRTVAL, STATVAL)

# After (if changed to cards)
fit$marginal_results %>%
  filter(stat_name == "diff") %>%
  tidyr::unnest(group1_level) %>%
  tidyr::unnest(stat) %>%
  select(group1_level, stat)
```

**Verdict:** ❌ **Not Recommended** - Too disruptive, too risky

---

### Option 2: Handle in Consuming Packages Only

**What this means:**
- beeca keeps its current ARD format unchanged
- Consuming packages (like hypothetical `beecarep` reporting package) do all conversion
- beeca provides no native conversion functions

**Example: Consuming package handles everything**

```r
# In hypothetical "beecarep" package
library(beecarep)

# User must convert manually or via beecarep
fit <- beeca::get_marginal_effect(...)

# Option A: beecarep provides converter
cards_ard <- beecarep::beeca_to_cards(fit)
report <- beecarep::create_report(cards_ard)

# Option B: User does manual conversion
cards_ard <- fit$marginal_results %>%
  mutate(
    group1 = TRTVAR,
    stat_name = STAT,
    # ... 20 more lines of mapping logic
  ) %>%
  cards::as_card()
```

#### Pros
- ✅ No changes to beeca - completely backward compatible
- ✅ beeca stays focused on statistical methods
- ✅ Consuming packages can customize conversions

#### Cons
- ❌ **Duplicated effort** - every consuming package writes own converter
- ❌ **Inconsistent conversions** - package A might map differently than package B
- ❌ **Maintenance burden** - if beeca changes, all converters break
- ❌ **Poor user experience** - users do manual conversion or juggle multiple packages
- ❌ **Lost opportunity** - beeca knows best how to convert its own data

#### Current State Reality Check

We **already have** `beeca_to_cards_ard()` in beeca! So this ship has sailed - beeca is already providing conversion functions.

**Verdict:** ❌ **Not Recommended** - Doesn't leverage existing infrastructure, poor UX

---

### Option 3: Hybrid Approach (Recommended)

**What this means:**
- beeca keeps its current ARD format as internal standard
- beeca provides **official converters** to popular formats
- beeca adds **metadata attributes** to enable rich conversions
- Consuming packages can use converters or work directly with beeca ARD

**Architecture:**

```
┌─────────────────────────────────────────────┐
│  beeca Core: Statistical Engine             │
│  • get_marginal_effect()                    │
│  • Internal ARD: TRTVAR/STAT/STATVAL/...    │
│  • Metadata attributes                      │
└──────────────┬──────────────────────────────┘
               │
               ├─ Converter Layer (IN BEECA)
               │  ├─ beeca_to_cards_ard() [EXISTS]
               │  ├─ beeca_to_cdisc_ard() [NEW]
               │  └─ beeca_to_ard(format = ...) [NEW]
               │
               └─ Extension API
                  └─ register_ard_converter() [NEW]

                    ↓  ↓  ↓  (Users and consuming packages choose)

┌──────────────────┐  ┌──────────────────┐  ┌──────────────────┐
│  Consuming Pkg A │  │  Consuming Pkg B │  │  Direct User     │
│  Uses cards ARD  │  │  Uses CDISC ARS  │  │  Uses beeca ARD  │
└──────────────────┘  └──────────────────┘  └──────────────────┘
```

**Example Usage:**

```r
library(beeca)

# Fit model (unchanged)
fit <- glm(aval ~ trtp + bl_cov, family = "binomial", data = trial01) %>%
  get_marginal_effect(trt = "trtp", method = "Ye")

# Option 1: Use beeca's native ARD (current workflow unchanged)
fit$marginal_results %>%
  filter(STAT == "diff")

# Option 2: Convert to cards format
cards_ard <- fit %>% beeca_to_ard(format = "cards")
cards_ard %>% cards::build_table()

# Option 3: Convert to CDISC ARS
cdisc_ard <- fit %>% beeca_to_ard(format = "cdisc_ars",
                                  analysis_id = "AN01",
                                  display_id = "T-14-01.01")

# Option 4: Custom format (consuming package registers converter)
mypackage::register_ard_converter("myformat", mypackage::my_converter)
custom_ard <- fit %>% beeca_to_ard(format = "myformat")
```

**Enhanced Metadata (Non-breaking):**

```r
# NEW: Access rich metadata
metadata <- beeca_metadata(fit)
metadata$method$variance   #> "Ye"
metadata$method$contrast   #> "diff"
metadata$formatting$diff   #> list(decimal_places = 3, label = "Risk Difference")

# Metadata is preserved through conversions
cards_ard <- beeca_to_cards_ard(fit$marginal_results)
attr(cards_ard, "beeca_metadata")  #> Full metadata available
```

#### Pros
- ✅ **Backward compatible** - existing code works unchanged
- ✅ **Best of both worlds** - official converters + flexibility
- ✅ **Standards-agnostic** - supports cards, CDISC, custom
- ✅ **Authoritative conversions** - beeca knows how to convert beeca data
- ✅ **Extensible** - consuming packages can register custom converters
- ✅ **Rich metadata** - attributes enable sophisticated conversions
- ✅ **Incremental rollout** - can add converters over multiple versions

#### Cons
- ⚠️ **Maintenance burden** - beeca maintains converter layer
  - *Mitigation:* Only add converters for widely-used standards, accept community contributions
- ⚠️ **Complexity** - more code surface area
  - *Mitigation:* Clear separation of concerns, comprehensive tests
- ⚠️ **Version drift risk** - external standards evolve
  - *Mitigation:* Version converters, document supported standard versions

**Verdict:** ✅✅ **Strongly Recommended**

---

## Decision Matrix

| Criterion | Option 1: Change API | Option 2: Consuming Pkgs Only | Option 3: Hybrid ✅ |
|-----------|---------------------|-------------------------------|-------------------|
| Backward Compatibility | ❌ Breaking | ✅ Compatible | ✅ Compatible |
| User Disruption | ❌ High | ⚠️ Medium | ✅ Low |
| Flexibility | ❌ Locked to one format | ✅ Flexible | ✅ Flexible |
| Standards Support | ⚠️ One standard only | ⚠️ Inconsistent | ✅ Multiple standards |
| Maintenance Burden | ⚠️ Coupled to external | ✅ Low for beeca | ⚠️ Medium |
| User Experience | ⚠️ Format-specific | ❌ Manual conversion | ✅ Excellent |
| Authoritative Conversions | N/A | ❌ No | ✅ Yes |
| Extensibility | ❌ Limited | ⚠️ Duplicated effort | ✅ Excellent |
| **Overall Score** | 2/8 | 4/8 | **8/8** |

---

## Comparison with Other Ecosystems

### How other R packages handle this

1. **broom package** (tidyverse)
   - Core: `tidy()`, `glance()`, `augment()` return tidy format
   - Extensions: Consuming packages can extend via S3 methods
   - **Lesson:** Standard internal format + extensibility = success

2. **ggplot2 package**
   - Core: ggplot2 objects with specific structure
   - Extensions: Extension packages (ggfortify, ggiraph) work with ggplot2 objects
   - **Lesson:** Stable core + extension API = ecosystem growth

3. **targets package** (workflow management)
   - Core: targets stores objects in internal format
   - Integration: Provides `tar_read()`, `tar_load()` for various output formats
   - **Lesson:** Internal format + export flexibility = adoption

**Insight:** Successful packages maintain stable internal formats while providing flexible export options. This is the **hybrid approach**.

---

## Answer to Your Question

> "Can we change the ARD API in beeca or handle it in consuming packages?"

### Short Answer

**Do both, but prioritize handling in beeca with converters.**

1. **Don't change beeca's core ARD API** (keep TRTVAR/STAT/STATVAL/etc.)
2. **Enhance beeca with metadata** (non-breaking attributes)
3. **Provide official converters** in beeca (`beeca_to_cards_ard()` already exists, add more)
4. **Allow consuming packages to extend** via registration system

### Longer Answer

**The ARD "API" has two layers:**

**Layer 1: Internal Representation** (what `get_marginal_effect()` returns)
- **Keep current format** - it's working well
- **Enhance with attributes** - add metadata without breaking structure
- **This is beeca's domain** - beeca controls this

**Layer 2: External Interfaces** (what consuming packages work with)
- **Provide converters** - beeca offers `beeca_to_ard(format = ...)`
- **Support multiple standards** - cards, CDISC, custom
- **This is shared responsibility:**
  - beeca provides converters for major standards
  - Consuming packages can register custom converters
  - Users choose which format to use

---

## Implementation Roadmap

### Phase 1: Enhance Current State (v0.4.0 - Q2 2026)

**No breaking changes, just additions:**

```r
# All existing code works
fit$marginal_results  # Still returns current TRTVAR/STAT/etc. format

# NEW: Metadata access
beeca_metadata(fit)

# ENHANCED: Better cards conversion
beeca_to_cards_ard(fit$marginal_results)  # Uses metadata for richer output
```

**Changes:**
- Add metadata attributes to `marginal_results`
- Enhance existing `beeca_to_cards_ard()` to use metadata
- Add `beeca_metadata()` extractor function

### Phase 2: Add Converter Infrastructure (v0.5.0 - Q3 2026)

**Still no breaking changes:**

```r
# NEW: Generic dispatcher
fit %>% beeca_to_ard(format = "cards")
fit %>% beeca_to_ard(format = "cdisc_ars")

# NEW: CDISC converter
beeca_to_cdisc_ard(fit$marginal_results, analysis_id = "AN01")

# NEW: Registration system
register_ard_converter("myformat", my_converter_fn)
```

**Changes:**
- Add `beeca_to_ard()` generic dispatcher
- Implement `beeca_to_cdisc_ard()`
- Add converter registration system

### Phase 3: Extensibility (v0.6.0 - Q4 2026)

**Advanced features, still backward compatible:**

```r
# NEW: Subgroup analyses
fit <- get_marginal_effect(..., subgroups = c("age", "sex"))

# NEW: Custom statistics
fit <- add_custom_stat(fit, "my_stat", my_stat_fn)

# All converters work with extensions
fit %>% beeca_to_ard(format = "cards")  # Includes subgroups and custom stats
```

---

## Consuming Package Integration Examples

### Example 1: Reporting Package Uses cards Format

```r
# In "beecarep" package
library(beecarep)

create_report <- function(beeca_fit, format = "cards") {
  # Use beeca's official converter
  ard <- beeca::beeca_to_ard(beeca_fit, format = format)

  # Work with cards ARD
  ard %>%
    cards::build_table() %>%
    cards::add_formatting() %>%
    cards::export_to_word()
}

# User workflow
fit <- beeca::get_marginal_effect(...)
create_report(fit)
```

### Example 2: Submission Package Uses CDISC ARS

```r
# In "beecasubmit" package
library(beecasubmit)

prepare_submission <- function(beeca_fit,
                               analysis_id,
                               display_id) {
  # Use beeca's CDISC converter
  ard <- beeca::beeca_to_ard(
    beeca_fit,
    format = "cdisc_ars",
    analysis_id = analysis_id,
    display_id = display_id
  )

  # Integrate with ADaM datasets
  bind_to_adam(ard, adam_dataset)
}

# User workflow
fit <- beeca::get_marginal_effect(...)
prepare_submission(fit, analysis_id = "AN01", display_id = "T-14-01.01")
```

### Example 3: Custom In-House Format

```r
# In "myorgtools" package
library(myorgtools)

# Register our custom converter with beeca
.onLoad <- function(libname, pkgname) {
  beeca::register_ard_converter("myorg", convert_to_myorg)
}

convert_to_myorg <- function(marginal_results, ...) {
  # Custom transformation logic
  marginal_results %>%
    mutate(
      org_stat = case_when(
        STAT == "diff" ~ "Risk Difference",
        STAT == "or" ~ "Odds Ratio",
        TRUE ~ STAT
      )
    ) %>%
    # ... more custom logic
}

# User workflow
fit <- beeca::get_marginal_effect(...)
myorg_ard <- beeca::beeca_to_ard(fit, format = "myorg")
```

---

## Recommendations Summary

### For beeca Package

1. ✅ **Keep current ARD format** - don't break existing users
2. ✅ **Add metadata attributes** - enable richer conversions (v0.4.0)
3. ✅ **Implement converter infrastructure** - `beeca_to_ard(format = ...)` (v0.5.0)
4. ✅ **Provide major standard converters:**
   - `beeca_to_cards_ard()` - exists, enhance
   - `beeca_to_cdisc_ard()` - new
5. ✅ **Enable extensibility** - registration system for custom converters (v0.5.0)
6. ✅ **Document thoroughly** - vignettes showing all conversion patterns

### For Consuming Packages

1. ✅ **Use beeca's converters** when possible - authoritative, maintained
2. ✅ **Register custom converters** if org-specific format needed
3. ✅ **Work directly with beeca ARD** if no conversion needed
4. ✅ **Contribute converters** back to beeca if broadly useful

### For Users

1. ✅ **Choose format based on workflow:**
   - beeca ARD for custom analysis
   - cards for cards ecosystem
   - CDISC ARS for regulatory submissions
2. ✅ **Use `beeca_to_ard(format = ...)` for conversions**
3. ✅ **Access metadata via `beeca_metadata()` when needed**

---

## Final Recommendation

**Adopt Option 3: Hybrid Approach**

**This means:**

1. **beeca package responsibility:**
   - Maintain current ARD format (stable API)
   - Add metadata attributes (v0.4.0)
   - Provide converters to major standards (v0.5.0)
   - Enable custom converter registration (v0.5.0)

2. **Consuming package flexibility:**
   - Use beeca's converters or work directly with beeca ARD
   - Register custom converters for org-specific needs
   - Extend via composition, not modification

3. **User empowerment:**
   - Choose output format based on needs
   - Seamless integration with cards, CDISC, or custom workflows
   - Backward compatibility preserved

**This balances stability, flexibility, and ecosystem growth.**

---

## Next Actions

1. **Review this decision document** with beeca maintainers
2. **Socialize with community:**
   - ASA-BIOP CARS Working Group
   - cards/cardx maintainers
   - CDISC representatives
3. **Prototype Phase 1** (metadata enhancement)
4. **Update ARD-EXPANSION-PLAN.md** based on feedback
5. **Create feature branch** for v0.4.0 development

---

**Decision Status:** Recommended (Pending Approval)
**Approver:** beeca Package Maintainers
**Stakeholders:** ASA-BIOP CARS WG, cards maintainers, beeca users

*Last updated: 2026-02-02*
