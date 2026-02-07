# Phase 3: Vignette Review - Research

**Researched:** 2026-02-07
**Domain:** R package vignette authoring, technical writing, clinical trial documentation
**Confidence:** HIGH

## Summary

This research investigates best practices for reviewing and polishing R package vignettes to achieve clarity, effective storytelling, and error-free rendering. The domain combines three areas: R Markdown/knitr vignette mechanics, technical documentation principles for dual audiences (biostatisticians and programmers), and clinical trial reporting standards.

**Key findings:**
- Vignettes should be framed around target problems, not function catalogs
- Progressive disclosure and modular content serve dual audiences effectively
- Opening hooks (problem-based, scenario-based) engage readers before diving into theory
- Cross-vignette coherence requires intentional linking and consistent dataset usage
- R CMD check validates both rendering and code execution

**Primary recommendation:** Structure vignettes with problem-scenario hooks, theory/methodology sections for statisticians, and practical code recipes for programmers, using progressive disclosure to serve both audiences without dilution.

---

<user_constraints>
## User Constraints (from CONTEXT.md)

### Locked Decisions

**Narrative flow & storytelling:**
- Estimand vignette: add brief hook + teaser code snippet before the theory section
- Keep Ge et al. raw paper code inline — shows the value of beeca's clean API vs verbose manual code
- Add a "Which method should I use?" section in the estimand vignette after explaining PATE/CPATE (map Ye→PATE, Ge→CPATE with guidance)
- ARD/cards vignette: add motivation section at top with a real scenario
- Clinical-trial-table vignette: end with a summary takeaway
- No explicit learning objectives or prerequisites boxes

**Cross-vignette coherence:**
- Vignettes form a progressive learning path: Estimand (concepts + methods) → Clinical tables (practical workflow) → ARD/cards (advanced integration)
- Standardize on trial02_cdisc dataset across all 3 vignettes (currently estimand and ARD use trial01)
- Cross-reference naturally between vignettes

**Content accuracy & freshness:**
- Update Magirr et al. preprint → Pharmaceutical Statistics 2025 published version
- Remove version numbers from package citations (margins, marginaleffects, RobinCar)
- Remove "Future Enhancements" section from ARD/cards vignette
- Verify all vignettes render without errors after edits

### Claude's Discretion

- Comparison section structure in estimand vignette (inline vs shortened)
- Math notation depth for PATE/CATE/CPATE/SATE definitions
- Number of table examples in clinical-trial-table vignette
- Whether to mention alternative table packages (flextable, huxtable) briefly
- Whether pkgdown article grouping needs adjustment after content changes

### Deferred Ideas (OUT OF SCOPE)

None — discussion stayed within phase scope

</user_constraints>

---

## Standard Stack

### Core Vignette Infrastructure

| Tool | Version | Purpose | Why Standard |
|------|---------|---------|--------------|
| knitr | Latest stable | Vignette execution engine | Official R package vignette standard, recommended in R Packages book |
| rmarkdown | Latest stable | Markdown-to-HTML rendering | De facto standard for R vignettes (HTML output), pkgdown compatibility |
| pkgdown | Latest stable | Website generation | R Consortium standard for package documentation websites |

**Installation:**
All are already in beeca's DESCRIPTION (knitr, rmarkdown in VignetteBuilder/Suggests).

**Configuration:**
```yaml
# Vignette YAML header (current standard)
output: rmarkdown::html_vignette
vignette: >
  %\VignetteIndexEntry{Title}
  %\VignetteEngine{knitr::rmarkdown}
  %\VignetteEncoding{UTF-8}
```

### Supporting Packages for Examples

| Package | Purpose | Current Status in beeca |
|---------|---------|-------------------------|
| gt | Clinical trial table formatting | Used in clinical-trial-table vignette |
| cards/cardx | ARD framework integration | Used in ard-cards-integration vignette |
| dplyr | Data manipulation in examples | Already imported |

**Note:** The vignettes use `requireNamespace("gt", quietly = TRUE)` and `eval=` conditions to gracefully handle optional dependencies.

### Alternatives Considered

| Instead of | Could Use | Tradeoff |
|------------|-----------|----------|
| rmarkdown::html_vignette | bookdown::html_vignette2 | Bookdown adds cross-referencing, figure/table autonumbering, but adds dependency weight |
| gt | flextable, huxtable | flextable/huxtable support Word/PowerPoint output; gt is HTML-focused but simpler API for web documentation |
| Inline examples | External .R scripts | External scripts reduce duplication but break inline narrative flow |

**Recommendation:** Stick with current stack (rmarkdown, gt) for beeca's web-first documentation approach.

---

## Architecture Patterns

### Recommended Vignette Structure (Problem-First Pattern)

```
## Opening Hook (NEW)
[Problem scenario OR quick result teaser - 1-2 paragraphs]
[Optional: Minimal code snippet showing end result]

## Conceptual Foundation
[Theory, methodology, estimands - for biostatisticians]
[Mathematical notation with accessibility balance]

## Practical Workflow
[Step-by-step code examples - for programmers]
[Real dataset, reproducible examples]

## Advanced Topics / Comparisons
[Cross-validation, method comparisons, edge cases]

## References
[Citations with DOIs, URLs]

## Session Info (optional but recommended)
sessionInfo()
```

### Pattern 1: Progressive Disclosure for Dual Audiences

**What:** Layer content so statisticians get methodological depth while programmers get practical recipes, without forcing either to wade through irrelevant content.

**When to use:** Vignettes with both theoretical methodology and practical implementation (like estimand vignette).

**Implementation:**
- **Level 1 (All readers):** Opening hook with scenario + quick example
- **Level 2 (Statisticians):** Theory sections with mathematical notation
- **Level 3 (Programmers):** Code-heavy sections with inline comments
- **Level 4 (Advanced):** Comparison sections, alternative implementations

**Example structure from research:**
```markdown
## Quick Start (Level 1 - hook)
You've run a clinical trial with 3 arms and binary outcome.
FDA guidance recommends covariate adjustment. Here's how:

\```r
get_marginal_effect(fit, trt = "TRTP", method = "Ye")
\```

## Understanding Estimands (Level 2 - theory)
[PATE, CPATE, SATE definitions with math]

## Step-by-Step Analysis (Level 3 - practical)
[Full reproducible workflow with trial02_cdisc]

## Comparing Implementations (Level 4 - advanced)
[beeca vs SAS, margins, marginaleffects]
```

### Pattern 2: Cross-Vignette Learning Path

**What:** Organize vignettes as a deliberate progression from concepts → basic application → advanced integration.

**Current beeca path:**
1. **estimand_and_implementations** (Get Started) — "What are marginal estimands? Which method should I use?"
2. **clinical-trial-table** (Applications) — "How do I create regulatory tables from beeca results?"
3. **ard-cards-integration** (Applications) — "How do I integrate beeca with broader ARD workflows?"

**Implementation:**
- Each vignette opens with context about where it fits in the path
- Natural cross-references: "For details on estimands, see vignette('estimand_and_implementations')"
- Dataset consistency (trial02_cdisc) across all three reduces cognitive load

**Example cross-reference patterns:**
```markdown
# In clinical-trial-table vignette:
> For advanced integration with the cards ARD framework,
> see `vignette('ard-cards-integration')`.

# In ard-cards-integration vignette:
> This vignette assumes you understand beeca's marginal effect
> estimation. For methodology background, see
> `vignette('estimand_and_implementations')`.
```

### Pattern 3: Opening Hooks for Technical Content

**What:** Start with a concrete problem or scenario that readers recognize, then transition to solution.

**Hook types suitable for beeca vignettes:**

| Hook Type | When to Use | Example for beeca |
|-----------|-------------|-------------------|
| **Problem-based** | When audience has shared pain point | "Covariate adjustment in trials is FDA-recommended but variance estimation is ambiguous..." |
| **Scenario-based** | For practical workflow vignettes | "You've just run `get_marginal_effect()` and need to create Table 14.2.1 for your CSR..." |
| **Result-teaser** | When showing workflow efficiency | "Compare 50 lines of manual g-computation code vs 3 lines with beeca:" |

**Source:** [10 hook techniques every tech content creator should use](https://www.techfinitive.com/checklists/10-hook-techniques-every-tech-content-creator-should-use/)

### Anti-Patterns to Avoid

- **Function catalog vignettes:** Listing functions with minimal examples (users want workflows, not API documentation)
- **Theory-only or code-only:** Alienates half the audience (biostatisticians OR programmers, not both)
- **Stale package version citations:** "marginaleffects 0.14.0" becomes outdated quickly; cite package name only
- **"Future enhancements" sections in release vignettes:** Undermines confidence in current capabilities
- **Forcing prerequisites boxes:** Feels academic/intimidating; natural prose context is friendlier

---

## Don't Hand-Roll

| Problem | Don't Build | Use Instead | Why |
|---------|-------------|-------------|-----|
| Vignette cross-referencing | Manual markdown links with hardcoded URLs | `` `vignette('name')` `` syntax in prose | pkgdown auto-links vignette references; maintains links across local/web contexts |
| Dataset switching logic | Conditional code paths for trial01 vs trial02 | Standardize on **trial02_cdisc** in all vignettes | Reduces cognitive load, follows CDISC standards, supports progressive learning |
| Math rendering | HTML entities or Unicode | LaTeX syntax (`` $\mathrm{PATE}^S$ ``) | rmarkdown/MathJax handles rendering; standard scientific notation |
| Citation management | Manual reference list maintenance | Consistent DOI + author-year format | Easier to update, verifiable sources |
| Code chunk error handling | Try-catch wrappers | `eval=requireNamespace("pkg", quietly=TRUE)` in chunk options | Standard R Markdown pattern for optional dependencies |

**Key insight:** R ecosystem has mature patterns for all these problems. Vignettes that follow standard patterns are easier for users to navigate (familiar structure) and easier to maintain.

---

## Common Pitfalls

### Pitfall 1: Dataset Inconsistency Across Vignettes

**What goes wrong:** Using trial01 in some vignettes and trial02_cdisc in others forces readers to mentally translate between datasets when following the learning path.

**Why it happens:** Vignettes written at different times with different example datasets; estimand vignette historically used trial01 for cross-validation comparisons.

**How to avoid:**
- Standardize on **trial02_cdisc** for all primary workflows (already decided in CONTEXT.md)
- Keep trial01 ONLY in the "Comparing Implementations" section of estimand vignette (needed for margins_trial01, ge_macro_trial01 cross-validation datasets)
- Add comment explaining dataset switch: "For cross-validation with external implementations, we use trial01..."

**Warning signs:** Reader must re-learn variable names (TRTP vs trtp, AVAL vs aval, SEX vs bl_cov) when moving between vignettes.

### Pitfall 2: Stale Package Version References

**What goes wrong:** Citations like "marginaleffects 0.14.0" become outdated, requiring constant maintenance and confusing users who have newer versions.

**Why it happens:** Copying citation format from `citation("package")` without considering shelf life.

**How to avoid:**
- Cite package **name only** in references: "Arel-Bundock V. marginaleffects: Predictions, Comparisons, Slopes, Marginal Means. R package. <https://marginaleffects.com/>"
- Remove all "version X.Y.Z" strings from bibliography
- Exception: If discussing a version-specific behavior or bug, note the version inline in text, not in references

**Warning signs:**
```bash
grep -n "version [0-9]" vignettes/*.Rmd
```

### Pitfall 3: Vignette Build Failures After Content Changes

**What goes wrong:** Edits to vignettes introduce R code errors or missing dependencies, causing `R CMD check` to fail.

**Why it happens:**
- Missing `library()` calls after adding new code
- Chunk dependencies broken (later chunk uses object from earlier chunk that was removed)
- Changed variable names in dataset without updating all references

**How to avoid:**
1. **Test locally before committing:**
   ```bash
   Rscript -e "devtools::build_vignettes()"
   R CMD check --as-cran .
   ```
2. **Use chunk naming and dependencies:**
   ```markdown
   ```{r setup}
   library(beeca)
   library(dplyr)
   ```

   ```{r analysis, depends="setup"}
   # Code that needs setup chunk
   ```
   ```
3. **Check for undefined objects:**
   - After dataset changes (trial01 → trial02_cdisc), verify all variable names updated
   - After function changes, verify all examples still work

**Warning signs:**
- Error: "object 'X' not found"
- Warning: "package 'Y' not found"
- Build log shows vignette rebuild skipped

### Pitfall 4: Outdated Preprint References

**What goes wrong:** Citing OSF preprints or arXiv links for papers that have since been published in peer-reviewed journals.

**Why it happens:** Vignettes written during development when paper was in preprint; publication happens later; vignettes not updated.

**How to avoid:**
- Audit references before each release
- Search for "osf.io", "arxiv.org", "preprint" in vignette .Rmd files
- Update to published version with journal, volume, pages, DOI, PMID

**Example update (from beeca estimand vignette):**

**OLD (line 55, 260):**
```markdown
See [Magirr et al. (2024)](https://osf.io/9mp58/) for discussion...

* Magirr, Dominic, Mark Baillie, Craig Wang, and Alexander Przybylski. 2024.
  "Estimating the Variance..." OSF. May 16. osf.io/9mp58.
```

**NEW:**
```markdown
See Magirr et al. (2025) for discussion...

* Magirr D, Wang C, Przybylski A, Baillie M (2025). Estimating the Variance
  of Covariate-Adjusted Estimators of Average Treatment Effects in Clinical
  Trials With Binary Endpoints. *Pharmaceutical Statistics* 24(4): e70021.
  https://doi.org/10.1002/pst.70021 [PMID: 40557557]
```

**Warning signs:**
```bash
grep -i "osf.io\|arxiv\|preprint" vignettes/*.Rmd
```

### Pitfall 5: Future Enhancements Section in Release Vignettes

**What goes wrong:** Listing "future enhancements" or "planned features" in vignettes that ship with CRAN releases signals incomplete functionality and undermines user confidence.

**Why it happens:** Vignettes written for development versions where feature roadmaps are appropriate; not removed before CRAN release.

**How to avoid:**
- Remove "Future Enhancements" sections before release
- If integration possibilities exist, frame as "Integration Opportunities" with present-tense: "The cards ecosystem enables..." (describes what's possible NOW, not what MIGHT be added)
- Move roadmap content to GitHub issues, development branch docs, or NEWS.md

**Example fix (ard-cards-integration vignette line 236):**

**REMOVE:**
```markdown
## Future Enhancements

The beeca package now includes `beeca_to_cards_ard()`...
Potential future additions include:
1. **S3 Method:** `as_card.beeca()`...
```

**Warning signs:** Sections titled "Future", "Planned", "Roadmap", "Coming Soon" in vignettes/

---

## Code Examples

### Hook + Teaser Pattern (Estimand Vignette)

**Source:** Progressive disclosure + problem-based hook research

```markdown
## Introduction

Covariate adjustment in randomized clinical trials improves precision, and recent
[FDA guidance (2023)](https://www.fda.gov/...) encourages its use. But a critical
question remains: *which variance estimator should you use?*

Here's a 3-arm trial analysis in 3 lines:

\```r
library(beeca)
fit <- glm(AVAL ~ TRTP + SEX + RACE + AGE, family = binomial, data = trial02_cdisc)
get_marginal_effect(fit, trt = "TRTP", method = "Ye", contrast = "diff")
\```

To understand *why* this works and *when* to use "Ye" vs "Ge", we need to
understand marginal estimands.

## Estimands: PATE, CPATE, and SATE
[Theory section follows...]
```

**Rationale:** Opens with the pain point (which variance estimator?), shows immediate solution (beeca is simple), then transitions to theory. Serves programmers (quick result) and statisticians (theory follows).

### Motivation Scenario (ARD/Cards Vignette)

**Source:** Scenario-based hook research

```markdown
## Overview

**Scenario:** You've run `get_marginal_effect()` and now need to create Table 14.2.1
for your Clinical Study Report. Your table requires:
- Baseline characteristics (from `cards::ard_continuous()`)
- Treatment effects (from beeca's `marginal_results`)
- Combined into a single ARD for your reporting pipeline

This vignette shows how beeca's ARD format integrates with the
[cards](https://insightsengineering.github.io/cards/) ecosystem.

## ARD Frameworks Comparison
[Content follows...]
```

**Rationale:** Concrete scenario readers recognize → immediate value proposition → technical details.

### Natural Cross-Reference (Clinical-Trial-Table Vignette)

**Source:** pkgdown auto-linking research

```markdown
## Complete Reporting Example

This example demonstrates the full workflow from data to regulatory table.

For advanced integration with baseline tables using the cards framework,
see `vignette('ard-cards-integration')`.

\```r
# Primary efficacy analysis
primary_analysis <- glm(...) |>
  get_marginal_effect(...)

as_gt(primary_analysis, title = "Table 14.2.1: Primary Efficacy Analysis")
\```
```

**Rationale:** `` `vignette('name')` `` syntax auto-links in pkgdown; natural prose flow; points to next learning step.

### Dataset Switch Comment (Estimand Vignette)

```markdown
## Comparing Different Implementations

To illustrate the usage of {beeca} and for purposes of results validation,
we compare {beeca} with other implementations in R and SAS.

**Note:** For these cross-validation comparisons, we use the `trial01` dataset
(2-arm trial) because we have pre-computed results from SAS macros
(`margins_trial01`, `ge_macro_trial01`) for this dataset. The methodology
applies identically to `trial02_cdisc`.

\```r
# pre-process trial01 dataset...
data01 <- trial01 |>
  transform(trtp = as.factor(trtp))
\```
```

**Rationale:** Explicit comment explains why dataset switches; reassures readers this isn't inconsistent design.

### Summary Takeaway (Clinical-Trial-Table Vignette End)

```markdown
## Session Information

\```{r session-info}
sessionInfo()
\```

---

**Summary:** This vignette demonstrated beeca's complete table workflow:
- `get_marginal_effect()` for covariate-adjusted treatment effects
- `as_gt()` for publication-ready regulatory tables
- `beeca_summary_table()` for custom table creation

**Next steps:**
- For estimand concepts and method selection, see `vignette('estimand_and_implementations')`
- For ARD framework integration, see `vignette('ard-cards-integration')`
- For function details, see `?get_marginal_effect`

## References
[...]
```

**Rationale:** Concise summary of what was shown + pointers to related vignettes + function documentation links.

---

## Verification and Testing

### Vignette Build Validation

**Local testing workflow:**
```bash
# Clean rebuild
Rscript -e "devtools::clean_vignettes()"
Rscript -e "devtools::build_vignettes()"

# Full R CMD check (includes vignette rebuild)
R CMD build .
R CMD check --as-cran beeca_*.tar.gz

# pkgdown preview
Rscript -e "pkgdown::build_articles(preview = TRUE)"
```

**What R CMD check validates:**
- Vignette YAML metadata correct (VignetteEngine, VignetteIndexEntry)
- R code in chunks executes without error
- Packages used in vignettes are in DESCRIPTION (Imports or Suggests)
- Vignette rebuilds produce same output as committed version
- No missing objects, undefined variables

**Source:** [R Packages book - R CMD check](https://r-pkgs.org/R-CMD-check.html)

### Reference Audit Commands

```bash
# Find stale version numbers
grep -n "version [0-9]" vignettes/*.Rmd

# Find preprint references
grep -in "osf.io\|arxiv\|preprint" vignettes/*.Rmd

# Find dataset inconsistencies
grep -n "trial01\|trial02" vignettes/*.Rmd

# Find "Future" sections
grep -in "^## Future\|^### Future" vignettes/*.Rmd
```

### Cross-Vignette Consistency Checks

| Aspect | How to Verify |
|--------|---------------|
| **Dataset usage** | Primary workflows use trial02_cdisc; trial01 only in estimand comparison section |
| **Function signatures** | `get_marginal_effect()` calls use same parameter names (trt, method, contrast, reference) |
| **Cross-references** | Use `` `vignette('name')` `` syntax, not hardcoded URLs |
| **Citation format** | DOIs for papers, URLs for packages, no version numbers |
| **Code style** | Pipe operator consistent (`|>` in recent examples, `%>%` acceptable in older sections) |

---

## State of the Art

| Practice | Current Approach | Recommendation | Impact |
|----------|------------------|----------------|--------|
| **Opening hooks** | Estimand vignette starts with theory | Add problem-based hook + teaser code before theory | Engages programmers; maintains statistician content |
| **Dataset standardization** | Mixed trial01/trial02_cdisc usage | Use trial02_cdisc in all primary workflows | Reduces cognitive load in learning path |
| **Preprint citations** | Magirr et al. OSF link | Update to Pharmaceutical Statistics 2025 published version | Authoritative, findable, professional |
| **Package version citations** | Some references include version numbers | Remove version numbers | Reduces maintenance, avoids staleness |
| **Future sections** | ARD vignette has "Future Enhancements" | Remove section | Builds confidence in current capabilities |

**Deprecated/outdated:**
- **Learning objectives boxes:** Felt academic/intimidating; natural prose context preferred
- **Function-catalog vignettes:** Users want problem-solution workflows, not API listings
- **Vignette-specific datasets:** Inconsistent datasets across vignettes increase cognitive load

---

## Open Questions

### 1. Table Package Alternatives (flextable, huxtable)

**What we know:**
- gt is HTML-focused, excellent for pkgdown websites and web-based documentation
- flextable and huxtable support Word/PowerPoint output for regulatory submissions
- beeca currently uses gt exclusively in clinical-trial-table vignette

**What's unclear:**
- Should clinical-trial-table vignette mention flextable/huxtable for users needing Word output?
- Risk: Adding package mentions increases scope; users may expect full examples

**Recommendation:**
- **Brief mention acceptable** in clinical-trial-table vignette introduction:
  > "This vignette demonstrates table creation with the `{gt}` package, which produces
  > HTML tables ideal for pkgdown websites and web-based reports. For Word/PowerPoint
  > output, consider `{flextable}` or `{huxtable}` packages, which can consume the same
  > `beeca_summary_table()` output."
- No code examples for alternative packages (out of scope)
- Links to their documentation sufficient

**Sources:**
- [R Markdown Cookbook: Other packages for creating tables](https://bookdown.org/yihui/rmarkdown-cookbook/table-other.html)
- [huxtable design principles](https://hughjonesd.github.io/huxtable/design-principles.html)

### 2. Math Notation Depth for Estimands

**What we know:**
- Estimand vignette targets dual audience: biostatisticians need rigor, programmers need actionable guidance
- Current notation uses LaTeX (e.g., $\mathrm{PATE}^S$, $\mathrm{CATE}^S(x)$)

**What's unclear:**
- Optimal balance between mathematical rigor (satisfies statisticians) and accessibility (doesn't intimidate programmers)
- Whether full mathematical definitions needed, or conceptual descriptions sufficient

**Recommendation:**
- **Keep current level of math notation** (HIGH confidence)
- Current approach is good: defines estimands with subscripts/superscripts but avoids dense integral notation
- Progressive disclosure helps: theory section can have math; programmers can skip to "Which method should I use?" section (to be added)
- Math is rendering correctly via MathJax in HTML vignettes

**Rationale:** Estimands are inherently statistical concepts; removing math would reduce credibility with biostatistician audience. Progressive structure lets programmers skip theory sections.

### 3. Comparison Section Length in Estimand Vignette

**What we know:**
- Current comparison section shows beeca vs 4 alternatives (Ge paper code, margins, marginaleffects, SAS %margins, RobinCar)
- Ge et al. paper code is verbose (38 lines) vs beeca (1 line)
- User decision: Keep Ge paper code inline to show beeca's value

**What's unclear:**
- Whether all 5 comparisons needed, or some could be summarized/shortened
- Balance between "demonstrates equivalence" (validation value) vs "too much detail" (reader fatigue)

**Recommendation:**
- **Keep all 5 comparisons, current structure** (MEDIUM confidence)
- **Rationale:** Cross-validation is a trust-building feature (CONTEXT.md: "valued") and differentiates beeca from other packages
- **Mitigation for length:** Add subheadings to improve scannability:
  ```markdown
  ### Ge et al. (2011) Variance Estimation
  #### beeca implementation
  #### Paper code (for comparison)
  #### Using {margins}
  #### Using {marginaleffects}
  #### Using SAS %margins macro
  ```
- Readers can skim subheadings and dive into comparisons they care about

### 4. pkgdown Article Grouping After Content Changes

**What we know:**
- Current _pkgdown.yml structure:
  ```yaml
  articles:
  - title: Get Started
    contents:
    - estimand_and_implementations
  - title: Applications
    contents:
    - clinical-trial-table
    - ard-cards-integration
  ```
- Vignettes form progressive path: estimand → clinical-table → ard-cards

**What's unclear:**
- Whether this grouping remains optimal after content changes
- Whether "Applications" title clearly signals "build on estimand knowledge"

**Recommendation:**
- **Keep current grouping** (HIGH confidence)
- "Get Started" = one vignette (estimand concepts) is appropriate
- "Applications" = two vignettes (practical workflows) is clear
- Progressive path is supported by vignette order in YAML (clinical-table before ard-cards)
- Alternative considered: Single "Articles" section with all three, relying on narrative cross-references instead of grouping — rejected because "Get Started" signals entry point clearly

**No changes needed** to _pkgdown.yml article section.

---

## Sources

### Primary (HIGH confidence)

**R Package Development Standards:**
- [R Packages (2e) - Vignettes](https://r-pkgs.org/vignettes.html) — Authoritative guide to vignette creation
- [R Packages (2e) - R CMD check](https://r-pkgs.org/R-CMD-check.html) — Vignette validation process
- [pkgdown: Introduction](https://pkgdown.r-lib.org/articles/pkgdown.html) — Website generation and article organization
- [R Markdown Cookbook - Package vignettes](https://bookdown.org/yihui/rmarkdown-cookbook/package-vignette.html) — Technical vignette mechanics

**Technical Writing Best Practices:**
- [10 hook techniques every tech content creator should use | TechFinitive](https://www.techfinitive.com/checklists/10-hook-techniques-every-tech-content-creator-should-use/) — Opening hook strategies
- [Progressive Disclosure - Nielsen Norman Group](https://www.nngroup.com/articles/progressive-disclosure/) — Layered information presentation
- [Audience | Technical Writing | Google for Developers](https://developers.google.com/tech-writing/one/audience) — Writing for multiple audience types

**Clinical Trial Reporting:**
- [Suggested Statistical Reporting Guidelines for Clinical Trials Data - PMC](https://pmc.ncbi.nlm.nih.gov/articles/PMC3361838/) — Statistical reporting standards
- [Case Study: Clinical Tables - GT package](https://gt.rstudio.com/articles/case-study-clinical-tables.html) — Clinical table formatting with gt
- [Tables in Clinical Trials with R](https://rconsortium.github.io/rtrs-wg/) — R Consortium clinical tables working group

**Published Citation (for vignette updates):**
- [Magirr et al. (2025) Pharmaceutical Statistics - PubMed](https://pubmed.ncbi.nlm.nih.gov/40557557/) — Published version with PMID 40557557, DOI 10.1002/pst.70021

### Secondary (MEDIUM confidence)

- [Optimal workflows for package vignettes - R-hub blog](https://blog.r-hub.io/2020/06/03/vignettes/) — Build and testing workflows
- [R Markdown Cookbook: Other packages for creating tables](https://bookdown.org/yihui/rmarkdown-cookbook/table-other.html) — Table package comparison
- [huxtable design principles](https://hughjonesd.github.io/huxtable/design-principles.html) — Alternative table package features

### Tertiary (Context/Background)

- [What Is Progressive Disclosure? | IxDF](https://www.interaction-design.org/literature/topics/progressive-disclosure) — UX design concept applied to documentation
- [Technical Writing Trends 2026](https://www.timelytext.com/technical-writing-trends-for-2026/) — Industry context for documentation practices

---

## Metadata

**Confidence breakdown:**
- **Standard stack:** HIGH — knitr/rmarkdown/pkgdown are documented R standards with official guidance
- **Architecture patterns:** HIGH — Progressive disclosure, problem-first hooks, cross-referencing backed by multiple authoritative sources
- **Vignette mechanics:** HIGH — R CMD check process documented in R Packages book
- **Content recommendations:** MEDIUM-HIGH — Hook patterns and dual-audience writing validated by technical writing research; specific application to beeca vignettes is informed judgment
- **Citation updates:** HIGH — Magirr et al. published version verified via PubMed with PMID

**Research date:** 2026-02-07
**Valid until:** ~30 days (R ecosystem stable; vignette best practices evolve slowly; citation info is permanent)

**Key evidence gaps:** None blocking planning. Open questions (table packages, math depth, comparison length) have clear recommendations with rationale.
