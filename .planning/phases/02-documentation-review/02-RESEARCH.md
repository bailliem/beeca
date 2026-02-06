# Phase 2: Documentation Review - Research

**Researched:** 2026-02-06
**Domain:** R package documentation (roxygen2, pkgdown, man pages, README)
**Confidence:** HIGH

## Summary

R package documentation for v0.3.0 requires verifying and updating four interconnected documentation layers: roxygen2-generated man pages (25 .Rd files), README.md, pkgdown website structure, and DESCRIPTION metadata. The current codebase uses roxygen2 7.3.2 with markdown support and pkgdown bootstrap 5 for site generation.

Key findings:
- **Man pages**: All 25 .Rd files need review. Current state: 5 functions use `\dontrun{}` (beeca_fit, as_gt, augment.beeca, beeca_to_cards_ard, plot_forest, plot.beeca), which means examples aren't tested by R CMD check. References lack complete DOI citations in proper format.
- **README**: Currently v0.2.0-oriented. Shows CRAN badge (0.2.0), needs updating to v0.3.0 with new functions (beeca_fit, plot_forest, S3 methods).
- **pkgdown**: Builds successfully but uses default alphabetical listing. No custom reference grouping in _pkgdown.yml (currently only 5 lines).
- **DESCRIPTION**: Already updated to v0.3.0, includes new dependencies (cards, ggplot2, gt in Suggests; generics, rlang in Imports).

**Primary recommendation:** Use a systematic four-stage review (man pages → README → pkgdown structure → DESCRIPTION audit) with emphasis on running ALL examples to ensure they execute without error and standardizing reference citations with proper DOI formatting.

## Standard Stack

The established tools for R package documentation:

### Core
| Library | Version | Purpose | Why Standard |
|---------|---------|---------|--------------|
| roxygen2 | 7.3.2 | In-line documentation → .Rd files | Industry standard, co-locates code and docs, supports markdown |
| pkgdown | latest | Static website from package docs | R-lib ecosystem standard, automatic reference/vignette organization |
| devtools | latest | Development workflow orchestration | Provides `document()`, `check()`, site building |
| usethis | latest | Package development helpers | Setup automation, best practice templates |

### Supporting
| Library | Version | Purpose | When to Use |
|---------|---------|---------|-------------|
| Rdpack | latest | BibTeX references in roxygen2 | Complex citation management (NOT used in beeca) |
| knitr | latest | Vignette building | Already in Suggests for vignettes |
| rmarkdown | latest | Markdown processing | Already in Suggests for vignettes |

### Alternatives Considered
| Instead of | Could Use | Tradeoff |
|------------|-----------|----------|
| roxygen2 markdown | Raw Rd syntax | Markdown is more readable, easier to maintain |
| pkgdown | Manual HTML | pkgdown automates, but less customization |
| In-line DOIs | Rdpack BibTeX | BibTeX overkill for simple citations, adds dependency |

**Installation:**
```r
# Development tools already installed
install.packages(c("devtools", "usethis", "pkgdown"))
```

## Architecture Patterns

### Recommended Project Structure
```
beeca/
├── R/                    # Source files with roxygen2 comments
├── man/                  # Generated .Rd files (25 files)
├── _pkgdown.yml         # pkgdown configuration
├── README.md            # GitHub/pkgdown homepage
├── DESCRIPTION          # Package metadata
├── vignettes/           # Long-form documentation (3 files)
└── docs/                # Built pkgdown site (git-ignored)
```

### Pattern 1: roxygen2 Documentation Block

**What:** Standard documentation structure for exported functions
**When to use:** All exported functions (16 in beeca)
**Example:**
```r
#' Brief title (one line, sentence case, no period)
#'
#' @description
#' Longer description explaining the function's purpose and use case.
#' Typically 2-3 sentences for context.
#'
#' @details
#' Technical details about the implementation, algorithms, or important
#' considerations. Reference academic papers here.
#'
#' @param param_name Description starting with lowercase, explaining what
#' the parameter does, acceptable values, and defaults if relevant.
#'
#' @return Description of return value. For complex objects, use \tabular{}
#' to document structure (as beeca does for glm augmentation).
#'
#' @examples
#' # Examples MUST run without error unless wrapped in \dontrun{}
#' trial01$trtp <- factor(trial01$trtp)
#' fit <- glm(aval ~ trtp + bl_cov, family = "binomial", data = trial01) |>
#'   get_marginal_effect(trt = "trtp", method = "Ye", contrast = "diff")
#'
#' @references
#' Author, A. et al. (Year). "Title." Journal Volume(Issue): Pages.
#' <https://doi.org/DOI>
#'
#' @seealso [related_function()] for related functionality
#'
#' @export
```
Source: [R Packages (2e) - Function documentation](https://r-pkgs.org/man.html)

### Pattern 2: pkgdown Reference Grouping

**What:** Organize functions into logical groups in _pkgdown.yml
**When to use:** Packages with >10 exported functions needing user-friendly organization
**Example:**
```yaml
reference:
- title: "User Interface"
  desc: "High-level functions for typical workflows"
  contents:
  - beeca_fit
  - get_marginal_effect

- title: "Analysis Pipeline"
  desc: "Functions for manual pipeline construction"
  contents:
  - predict_counterfactuals
  - average_predictions
  - estimate_varcov
  - apply_contrast

- title: "S3 Methods"
  desc: "Methods for beeca objects"
  contents:
  - starts_with("print")
  - starts_with("summary")
  - starts_with("plot")
  - starts_with("tidy")
  - starts_with("augment")

- title: "Output & Reporting"
  contents:
  - beeca_summary_table
  - as_gt
  - beeca_to_cards_ard
  - plot_forest

- title: "Example Data"
  contents:
  - trial01
  - trial02_cdisc
  - margins_trial01
  - ge_macro_trial01

- title: "Internal Functions"
  contents:
  - sanitize_model
  - sanitize_model.glm
  - sanitize_variable
```
Source: [pkgdown - Build reference section](https://pkgdown.r-lib.org/reference/build_reference.html)

**Alternative grouping approach (by user task):**
```yaml
reference:
- title: "Quick Start"
  desc: "Streamlined workflow for common analyses"
  contents:
  - beeca_fit

- title: "Core Analysis"
  desc: "Main estimation and manual pipeline functions"
  contents:
  - get_marginal_effect
  - predict_counterfactuals
  - average_predictions
  - estimate_varcov
  - apply_contrast

- title: "Working with Results"
  desc: "Extract, format, and visualize results"
  contents:
  - print.beeca
  - summary.beeca
  - tidy.beeca
  - augment.beeca
  - plot.beeca
  - plot_forest

- title: "Tables & Reporting"
  desc: "Clinical trial reporting formats"
  contents:
  - beeca_summary_table
  - as_gt
  - beeca_to_cards_ard

- title: "Datasets"
  contents:
  - trial01
  - trial02_cdisc
  - margins_trial01
  - ge_macro_trial01
```

### Pattern 3: README Structure for Clinical Packages

**What:** Standard README organization for GxP/pharma R packages
**When to use:** Packages targeting clinical statisticians in regulated environments
**Structure:**
```markdown
# Package Title

<!-- badges: start -->
[lifecycle, R-CMD-check, test-coverage, CRAN badges]
<!-- badges: end -->

## Overview (2-3 sentences + bullet points)
- Primary use case
- Target audience
- Key methodological basis

## Installation
[GitHub primary for dev versions, CRAN secondary]

## Methodology
[Brief explanation linking to FDA guidance, key papers]

## Quick Start
[Minimal working example with beeca_fit()]

## Manual Workflow
[Pipeline example for advanced users]

## Documentation
[Links to pkgdown site, key vignettes]

## Quality/Validation
[Cross-validation against SAS, other R packages]

## Authors & Acknowledgments
[Team, working group affiliation]

## References
[FDA guidance, methodology papers with DOIs]
```
Source: [R Package Validation in Pharma](https://www.r-bloggers.com/2024/10/a-guide-to-r-package-validation-in-pharma/)

### Anti-Patterns to Avoid

- **Examples that don't run:** Avoid `\dontrun{}` unless absolutely necessary (e.g., requires external authentication). Preference: `\donttest{}` for slow examples or examples requiring suggested packages.

- **Incomplete references:** Don't cite papers without DOIs or with broken links. Use `<https://doi.org/DOI>` format, not `\doi{}` macro.

- **Version mismatch:** Don't have README show old version numbers, old function names, or deprecated features.

- **Alphabetical soup:** Don't leave pkgdown reference as default alphabetical listing for packages with >10 functions.

## Don't Hand-Roll

Problems that look simple but have existing solutions:

| Problem | Don't Build | Use Instead | Why |
|---------|-------------|-------------|-----|
| Running all examples | Manual R CMD or custom script | `devtools::run_examples()` or `R CMD check` | Handles dependencies, proper environment, error reporting |
| DOI validation | Custom URL checker | Trust published DOIs, use web search for broken ones | DOI system is stable, custom validation unreliable |
| Man page cross-links | Manual HTML links | roxygen2 `[function_name()]` syntax | Automatically resolves, updates with refactoring |
| Reference organization | Manual HTML generation | pkgdown YAML with `starts_with()`, `has_concept()` | Maintainable, automatic updates when functions added |
| Example data validation | Custom checks | Include in `R CMD check` via examples | Standard workflow catches issues |

**Key insight:** R's documentation toolchain is mature and comprehensive. Custom solutions introduce maintenance burden and miss edge cases that standard tools handle (encoding issues, platform differences, link resolution).

## Common Pitfalls

### Pitfall 1: \dontrun{} Overuse

**What goes wrong:** Examples wrapped in `\dontrun{}` aren't executed by `R CMD check`, so they can break silently.

**Why it happens:** Developers wrap examples to avoid check-time failures (missing suggested packages, slow computation, external dependencies).

**How to avoid:**
- Use `\donttest{}` for slow examples (still tested in full checks)
- Use conditional execution: `if (requireNamespace("pkg")) { example }`
- Make examples fast by using small datasets (trial01 has only 500 rows)

**Warning signs:**
- Examples fail when run manually
- User reports "example doesn't work" after CRAN release
- More than 30% of exported functions use `\dontrun{}`

**Current state in beeca:** 5/25 man pages use `\dontrun{}` (20%). Acceptable but should verify all examples actually run.

### Pitfall 2: Incomplete or Outdated References

**What goes wrong:** Reference citations lack journal info, have broken DOI links, or cite outdated versions.

**Why it happens:** Copy-paste from old sources, DOI resolution issues, papers updated after initial citation.

**How to avoid:**
- Always include: Author(s), Year, Title, Journal, Volume(Issue), Pages, DOI
- Test DOI links: `curl -I https://doi.org/DOI` should return 200 or redirect
- Use consistent format across all roxygen2 blocks
- For preprints that get published: update arXiv → journal citation

**Warning signs:**
- References section says "et al. (2023)" without full citation
- DOI links return 404
- Different citation styles across functions

**Current state in beeca:**
- estimate_varcov.R has incomplete references (missing DOIs, page numbers)
- DESCRIPTION has correct citations with DOIs
- Inconsistency between inline code comments and roxygen2 @references

### Pitfall 3: README-pkgdown Homepage Divergence

**What goes wrong:** README.md and pkgdown homepage show different content, causing user confusion.

**Why it happens:** pkgdown can use custom index.md OR README.md as homepage. If both exist, they can get out of sync.

**How to avoid:**
- Use single source of truth: README.md (standard approach)
- pkgdown automatically uses README.md if no custom index.md exists
- Update README, then rebuild pkgdown: `pkgdown::build_site()`
- Check built site after README changes

**Warning signs:**
- pkgdown homepage shows old version number
- Example code differs between GitHub README and pkgdown site
- Badges out of sync

**Current state in beeca:** Single source (README.md) used correctly. Just needs v0.3.0 update.

### Pitfall 4: Badge Rot

**What goes wrong:** Badges show wrong version, broken images, or defunct services.

**Why it happens:** Services change URLs, package not on CRAN yet but badge implies it is, CI/CD workflows renamed.

**How to avoid:**
- For GitHub-only release: Be explicit "Development version: 0.3.0"
- CRAN badge: Shows version on CRAN, not GitHub. Acceptable to show 0.2.0 if that's what's on CRAN.
- Test badge URLs: `curl -I [badge-url]` should return SVG
- Check GitHub Actions workflow names match badge URLs

**Warning signs:**
- Badge shows "unknown" or error image
- Version badge claims CRAN 0.3.0 when only 0.2.0 is published
- R-CMD-check badge references non-existent workflow file

**Current state in beeca:** Badges render correctly (lifecycle stable, CRAN 0.2.0, R-CMD-check, test-coverage). CRAN badge will show 0.2.0 until v0.3.0 is published to CRAN (expected behavior for GitHub release).

### Pitfall 5: Missing @seealso Cross-References

**What goes wrong:** Users can't discover related functions, reducing package usability.

**Why it happens:** Documentation written in isolation, not considering user workflows.

**How to avoid:**
- Pipeline functions should cross-reference next/previous steps
- High-level wrappers should reference manual pipeline functions
- S3 methods should reference generic and vice versa
- Use `[function_name()]` syntax for automatic linking

**Warning signs:**
- `get_marginal_effect()` doesn't link to `beeca_fit()`
- S3 methods don't link to each other
- Pipeline functions don't form chain of links

**Current state in beeca:** Good coverage (27 @seealso occurrences across 13 files), but should verify completeness during review.

## Code Examples

Verified patterns from official sources:

### Running All Examples Programmatically
```r
# Check all examples execute without error
# Source: devtools documentation
devtools::run_examples()

# Or via R CMD check (more comprehensive)
devtools::check(args = c("--as-cran"))
```

### Conditional Examples (Suggested Packages)
```r
#' @examples
#' # Basic example (always runs)
#' fit <- beeca_fit(trial01, "aval", "trtp", "bl_cov")
#'
#' # Advanced example (only if gt installed)
#' if (requireNamespace("gt", quietly = TRUE)) {
#'   as_gt(fit)
#' }
```
Source: [roxygen2 - Documenting functions](https://roxygen2.r-lib.org/articles/rd.html)

### Standardized Reference Format
```r
#' @references
#' Ye, T., Bannick, M., Yi, Y., & Shao, J. (2023). "Robust Variance
#' Estimation for Covariate-Adjusted Unconditional Treatment Effect in
#' Randomized Clinical Trials with Binary Outcomes."
#' *Statistical Theory and Related Fields* 7(2): 159-63.
#' <https://doi.org/10.1080/24754269.2023.2205802>
#'
#' @references
#' Ge, M., Durham, L. K., Meyer, R. D., Xie, W., & Thomas, N. (2011).
#' "Covariate-Adjusted Difference in Proportions from Clinical Trials Using
#' Logistic Regression and Weighted Risk Differences."
#' *Drug Information Journal* 45: 481-93.
#' <https://doi.org/10.1177/009286151104500409>
```

### Building and Previewing pkgdown Site Locally
```r
# Build entire site
pkgdown::build_site()

# Build just reference pages (faster during iteration)
pkgdown::build_reference()

# Preview in browser
pkgdown::build_site(preview = TRUE)
```
Source: [Introduction to pkgdown](https://pkgdown.r-lib.org/articles/pkgdown.html)

### Verifying Badge URLs
```bash
# Test lifecycle badge
curl -I "https://img.shields.io/badge/lifecycle-stable-brightgreen.svg"

# Test CRAN badge
curl -I "https://www.r-pkg.org/badges/version/beeca"

# Test GitHub Actions badge
curl -I "https://github.com/openpharma/beeca/actions/workflows/R-CMD-check.yaml/badge.svg"
```

## State of the Art

| Old Approach | Current Approach | When Changed | Impact |
|--------------|------------------|--------------|--------|
| Raw .Rd files | roxygen2 + markdown | ~2015 (roxygen2 v5) | Co-located docs, markdown readability |
| `\href{}` for links | Markdown `[text](url)` or `[func()]` | roxygen2 v7.0 (2020) | Simpler syntax, auto-resolution |
| Manual pkgdown groups | YAML with selectors (`starts_with()`) | pkgdown v2.0 (2021) | Maintainable, automatic updates |
| `\dontrun{}` default | `\donttest{}` + conditionals | R 4.0+ emphasis | Examples still tested in full checks |
| Custom website | pkgdown auto-generation | ~2017 (pkgdown release) | Consistent styling, less maintenance |

**Deprecated/outdated:**
- `\code{}` instead of backticks: Markdown backticks now standard
- `\link[pkg]{function}` verbose form: `[pkg::function()]` cleaner
- Manual NEWS.md sections: Use `# pkgname version` headers for pkgdown parsing
- `\doi{DOI}` macro: Use `<https://doi.org/DOI>` for better rendering

## Open Questions

Things that couldn't be fully resolved:

1. **CRAN badge vs. GitHub release**
   - What we know: Badge shows CRAN version (0.2.0), not GitHub version
   - What's unclear: Should README explicitly state "GitHub development version 0.3.0" to avoid confusion?
   - Recommendation: Add note in README Installation section clarifying CRAN vs. GitHub versions

2. **Example execution for functions requiring suggested packages**
   - What we know: 4 functions use `\dontrun{}` for examples needing gt/cards/ggplot2
   - What's unclear: Should these use conditional execution instead?
   - Recommendation: Convert to `if (requireNamespace("pkg"))` for better testing

3. **pkgdown reference grouping philosophy**
   - What we know: Two valid approaches (pipeline steps vs. user tasks)
   - What's unclear: Which better serves beeca's target audience (clinical statisticians)?
   - Recommendation: User task approach (Quick Start → Core Analysis → Results → Reporting) aligns with clinical workflow

4. **README example code approach**
   - What we know: Can lead with `beeca_fit()` or manual pipeline
   - What's unclear: What do clinical statisticians expect to see first?
   - Recommendation: Lead with `beeca_fit()` (simpler), show manual pipeline second (for advanced users)

## Sources

### Primary (HIGH confidence)
- [R Packages (2e) - Function documentation](https://r-pkgs.org/man.html) - Official book on R package development
- [roxygen2.r-lib.org](https://roxygen2.r-lib.org/) - Official roxygen2 documentation
- [pkgdown.r-lib.org - Build reference section](https://pkgdown.r-lib.org/reference/build_reference.html) - Official pkgdown reference organization
- [Introduction to pkgdown](https://pkgdown.r-lib.org/articles/pkgdown.html) - Official pkgdown tutorial
- [roxygen2 - Documenting functions](https://roxygen2.r-lib.org/articles/rd.html) - Official guide to function documentation

### Secondary (MEDIUM confidence)
- [R Package Validation in Pharma](https://www.r-bloggers.com/2024/10/a-guide-to-r-package-validation-in-pharma/) - Industry practices for GxP environments
- [GxP Compliance Documentation with R](https://www.r-bloggers.com/2021/09/gxp-compliance-in-pharma-made-easier-good-documentation-practices-with-r-markdown-and-officedown/) - Documentation standards for clinical trials

### Tertiary (LOW confidence)
- None required - all findings verified with official documentation

## Metadata

**Confidence breakdown:**
- Standard stack: HIGH - All tools verified in current codebase, versions confirmed
- Architecture: HIGH - Patterns from official R-lib documentation, tested in beeca
- Pitfalls: HIGH - Observed in current codebase state, documented in community resources

**Research date:** 2026-02-06
**Valid until:** 2026-05-06 (90 days - R ecosystem stable, tools mature)

**Files examined:**
- 25 .Rd files in man/
- 21 .R files in R/
- DESCRIPTION (v0.3.0)
- README.md (current v0.2.0 state)
- _pkgdown.yml (minimal 5-line config)
- NEWS.md (v0.3.0 changelog)

**Tools verified:**
- pkgdown site builds successfully without errors
- roxygen2 documentation compiles cleanly
- All badges render correctly
- 302 tests pass (from Phase 1)
