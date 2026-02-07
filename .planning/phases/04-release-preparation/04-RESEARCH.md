# Phase 4: Release Preparation - Research

**Researched:** 2026-02-07
**Domain:** R package release preparation, CRAN submission workflows, version control practices
**Confidence:** HIGH

## Summary

Phase 4 prepares the beeca package for a v0.3.0 GitHub release by finalizing NEWS.md, verifying package metadata, validating build integrity, and creating a release branch. The research reveals that R package release preparation follows well-established standards defined by CRAN submission requirements, tidyverse style guides, and modern Git workflows.

The standard approach combines three pillars: (1) accurate, user-focused changelog documentation following tidyverse NEWS.md conventions; (2) comprehensive validation through R CMD check --as-cran with zero errors/warnings; and (3) Git release branch workflow that isolates the release from ongoing development.

Key findings indicate that DESCRIPTION already shows Version: 0.3.0, .Rbuildignore properly excludes .planning/ and .claude/ directories, and no lifecycle deprecations exist in the codebase. The main work involves NEWS.md restructuring, URL validation, CRAN-readiness checks, and release branch creation.

**Primary recommendation:** Follow tidyverse NEWS.md style (simpler sections, one-liner bullets, function names early), run comprehensive validation suite (devtools::check with cran=TRUE, urlchecker::url_check, pkgdown::build_site), create release/v0.3.0 branch from main, and prepare for manual tagging by user.

## Standard Stack

### Core Tools

| Tool | Version | Purpose | Why Standard |
|------|---------|---------|--------------|
| devtools | Latest | Package development and validation | Official R package development toolkit, provides check() wrapper with CRAN settings |
| usethis | Latest | Package setup and release automation | Part of tidyverse ecosystem, standardizes release workflows |
| pkgdown | Latest | Documentation website generation | Official documentation site builder for R packages |
| urlchecker | Latest | URL validation in package documentation | CRAN pre-submission requirement for URL availability checks |

### Supporting Tools

| Tool | Version | Purpose | When to Use |
|------|---------|---------|-------------|
| rcmdcheck | Latest | R CMD check from R with structured output | Programmatic check execution in scripts/CI |
| rhub | Latest | Multi-platform CRAN checks | Testing on platforms not locally available |
| goodpractice | Latest | Package quality assessment | Pre-submission quality audit |

### Alternatives Considered

| Instead of | Could Use | Tradeoff |
|------------|-----------|----------|
| Git Flow release branches | Trunk-based development | Git Flow better for versioned releases; trunk-based better for continuous deployment |
| Manual NEWS.md editing | Automated changelog from commits | Manual provides better narrative; automated ensures completeness |
| devtools::check() | R CMD check directly | devtools provides consistent CRAN simulation; direct check offers more control |

**Installation:**

All tools are available from CRAN:

```r
install.packages(c("devtools", "usethis", "pkgdown", "urlchecker"))
```

## Architecture Patterns

### Recommended Release Workflow Structure

```
.planning/phases/04-release-preparation/
├── 04-CONTEXT.md           # User decisions from /gsd:discuss-phase
├── 04-RESEARCH.md          # This research document
├── 04-PLAN-01-news-update.md      # NEWS.md restructuring plan
├── 04-PLAN-02-validation.md       # Pre-release validation plan
└── 04-PLAN-03-release-branch.md   # Release branch creation plan
```

### Pattern 1: NEWS.md Tidyverse Style

**What:** Structure changelog with standardized sections and concise, scannable bullets

**When to use:** All R package releases targeting CRAN or wide community use

**Example:**

```markdown
# beeca 0.3.0

## New Features

- `beeca_fit()`: Convenience function combining model fitting and marginal effect estimation.
- `plot_forest()`: Forest plots for visualizing treatment effects with customizable confidence levels.
- `beeca_summary_table()`: Generate publication-quality summary tables from beeca objects.

## Improvements

- Added `trial02_cdisc` dataset for CDISC-compliant workflows.
- Enhanced `print.beeca()` with concise output showing treatment effect estimates.
- Updated Magirr et al. reference from OSF preprint to published version (Pharmaceutical Statistics 2025).

## Bug Fixes

- Fixed function name conflict in `plot_forest()` where base R's `diff()` was called incorrectly.
```

**Source:** [Tidyverse NEWS.md Style Guide](https://style.tidyverse.org/news.html)

**Key principles:**
- Function names in backticks with parentheses: `function()`
- One-liner per feature/fix, not multi-bullet descriptions
- Sections: "New Features", "Improvements", "Bug Fixes" (standard R convention)
- Place function name early in bullet for scannable lists
- End each bullet with period
- Wrap lines to 80 characters

### Pattern 2: CRAN Pre-Release Validation Checklist

**What:** Comprehensive validation sequence to catch issues before submission

**When to use:** Before creating release branch and tagging any version

**Example:**

```r
# Step 1: Local R CMD check with CRAN settings
devtools::check(
  remote = TRUE,      # Check remote dependencies
  manual = TRUE,      # Build manual
  cran = TRUE         # Use CRAN settings
)
# REQUIRED: 0 errors, 0 warnings
# GOAL: 0 notes (some informational notes acceptable with justification)

# Step 2: URL validation
urlchecker::url_check()
# Check all URLs in DESCRIPTION, README, man/, vignettes/ are reachable
# Update any redirected URLs to canonical versions

# Step 3: pkgdown site build
pkgdown::build_site()
# Verify documentation renders without errors
# Check all cross-references resolve correctly

# Step 4: Platform testing (optional but recommended)
devtools::check_win_devel()  # Windows R-devel
rhub::check_for_cran()       # Multi-platform CRAN checks

# Step 5: Verify .Rbuildignore excludes non-package files
# Ensure .planning/, .claude/, docs/, etc. not in source tarball
```

**Source:** [R Packages Book: Releasing to CRAN](https://r-pkgs.org/release.html), [CRAN Submission Checklist](https://cran.r-project.org/web/packages/submission_checklist.html)

**Critical requirements:**
- Packages MUST pass `R CMD check --as-cran` with zero errors and warnings
- Run checks using current R-devel version before submission
- URL checks equivalent to `curl -I -L` on command line
- NOTEs should be minimized; unavoidable ones documented in cran-comments.md

### Pattern 3: Git Release Branch Workflow

**What:** Create dedicated release branch for version stabilization

**When to use:** When preparing versioned release while allowing main branch development to continue

**Example:**

```bash
# Create release branch from current main HEAD
git checkout main
git pull origin main
git checkout -b release/v0.3.0

# Perform final validation on release branch
# R CMD check, URL validation, pkgdown build

# Tag the release (done manually by user, NOT by Phase 4)
git tag -a v0.3.0 -m "Release v0.3.0"
git push origin release/v0.3.0
git push origin v0.3.0

# After release, merge back to main (if needed)
git checkout main
git merge release/v0.3.0
git push origin main
```

**Source:** [Atlassian Git Flow Workflow](https://www.atlassian.com/git/tutorials/comparing-workflows/gitflow-workflow), [Mastering GitHub Release Branches](https://medium.com/@smita.s.kothari/mastering-github-release-branches-versioning-a-complete-guide-3ea42ebd0d0f)

**Key decisions:**
- **Merge, not rebase:** Release branches are shared, so merge preserves history safely
- **Branch naming:** `release/v{version}` convention (e.g., release/v0.3.0)
- **Tag on release branch:** Tags mark specific commit, can be on branch or main
- **Phase 4 scope:** Create branch, validate, prepare — but user manually tags/pushes

### Anti-Patterns to Avoid

- **Editing NEWS.md after release tag:** Changelog should match tagged version exactly
- **Skipping URL validation:** CRAN checks will fail on unreachable URLs
- **Committing .Rbuildignore gaps:** .planning/ and .claude/ MUST be excluded from tarball
- **Assuming check() passes means CRAN-ready:** Must use `cran = TRUE` parameter
- **Tagging main before validation:** Tag release branch after final validation passes

## Don't Hand-Roll

Problems that have existing R ecosystem solutions:

| Problem | Don't Build | Use Instead | Why |
|---------|-------------|-------------|-----|
| URL validation | Custom curl/wget scripts | `urlchecker::url_check()` | CRAN uses specific rules for URL checks (redirects, HEAD requests, etc.) |
| CRAN check simulation | Manual R CMD check | `devtools::check(cran = TRUE)` | Sets all CRAN-specific environment variables correctly |
| Release checklist | Manual TODO list | `usethis::use_release_issue()` | Creates GitHub issue with version-specific steps |
| NEWS.md formatting | Custom templates | Tidyverse style guide | Community-standard format, pkgdown recognizes automatically |
| Package website | Custom HTML | `pkgdown::build_site()` | Automatic cross-referencing, standard structure, CRAN-friendly |

**Key insight:** CRAN submission has accumulated 20+ years of edge cases and requirements. Using official tooling (devtools, usethis, urlchecker) ensures compliance with current standards without rediscovering known pitfalls.

## Common Pitfalls

### Pitfall 1: Incomplete .Rbuildignore Patterns

**What goes wrong:** Non-package files (.planning/, .claude/, local config files) get included in source tarball, causing CRAN NOTE or rejection

**Why it happens:** .Rbuildignore uses Perl regex without anchoring by default; easy to miss directories

**How to avoid:**
- Use `usethis::use_build_ignore(".planning")` instead of manual editing
- Verify exclusions by building tarball: `pkgbuild::build()`
- Check tarball contents: `tar -tzf beeca_0.3.0.tar.gz | grep planning`

**Warning signs:**
- `R CMD check` shows NOTE about "non-standard file/directory found"
- Tarball size unexpectedly large

### Pitfall 2: Outdated URL References

**What goes wrong:** Documentation contains broken links, redirected URLs, or preprint references that moved to published versions

**Why it happens:** URLs change over time; OSF preprints become journal articles; HTTP redirects to HTTPS

**How to avoid:**
- Run `urlchecker::url_check()` before release
- Update all Magirr et al. OSF references to DOI: 10.1002/pst.70021
- Use angle brackets for all URLs in DESCRIPTION: `<https://example.com/>`
- Check DOIs resolve correctly before finalizing

**Warning signs:**
- CRAN pre-check returns URL NOTE
- urlchecker reports 301/302 redirects
- References cite preprints when published version available

**Current status in beeca:**
- Two files still reference OSF preprint: `R/estimate_varcov.R` and `R/get_marginal_effect.R`
- Need update from `https://osf.io/9mp58/` to DOI-based citation

### Pitfall 3: NEWS.md Becoming Stale Documentation

**What goes wrong:** Changelog written for developers, not users; includes version numbers in dependencies; promises future features

**Why it happens:** Developers focus on what changed technically, not user-visible impact

**How to avoid:**
- Write for users, not developers: "now supports X" not "refactored Y module"
- Remove version numbers from package citations (go stale quickly)
- No "Future Enhancements" sections in release changelogs
- Focus on function-level changes users directly interact with

**Warning signs:**
- Bullets describe internal code changes
- Mentions of roadmap items or planned features
- Package version numbers in dependency mentions

### Pitfall 4: Skipping Pre-Release Validation on Release Branch

**What goes wrong:** Create release branch, tag immediately, discover errors during CRAN check

**Why it happens:** Assumes main branch checks are sufficient; rush to release

**How to avoid:**
- Always run full validation suite ON release branch before tagging
- Sequence: create branch → validate → fix issues → validate again → tag
- Use `devtools::check(cran = TRUE)` not just `devtools::check()`
- Build pkgdown site on release branch to verify doc rendering

**Warning signs:**
- Tagging without check results
- Skipping URL validation step
- Not testing pkgdown build

### Pitfall 5: Dependency Changes Undocumented

**What goes wrong:** New dependencies (rlang, generics, cards, gt, ggplot2) added in v0.3.0 but not mentioned in NEWS.md

**Why it happens:** Focuses on user-facing functions, forgets Imports/Suggests changes

**How to avoid:**
- Review DESCRIPTION changes since last release
- Document new Imports (always) and significant Suggests (user-visible)
- Note when dependencies REMOVED (equally important)
- Check if minimum R version changed

**Warning signs:**
- `git diff v0.2.0 DESCRIPTION` shows dependency changes not in NEWS
- Users surprised by new installation requirements

## Code Examples

Verified patterns from official sources:

### Running Complete Pre-Release Validation

```r
# Source: https://r-pkgs.org/release.html
# Location: Run from package root directory

# 1. Update documentation
devtools::document()

# 2. Build README from Rmd (if applicable)
devtools::build_readme()

# 3. Full CRAN-style check
devtools::check(
  remote = TRUE,      # Check remote dependencies
  manual = TRUE,      # Build and check PDF manual
  cran = TRUE         # Use CRAN settings
)
# REQUIRED: 0 errors ✓ | 0 warnings ✓ | 0 notes ✓ (or justified)

# 4. URL validation
urlchecker::url_check()
# Fix any broken or redirected URLs

# 5. pkgdown site build
pkgdown::build_site()
# Verify no errors in documentation rendering

# 6. Platform-specific checks (optional)
devtools::check_win_devel()  # Windows R-devel
# Wait for email with results
```

### Creating and Validating Release Branch

```bash
# Source: https://www.atlassian.com/git/tutorials/comparing-workflows/gitflow-workflow
# Adapted for R package release

# From main branch, create release branch
git checkout main
git pull origin main
git checkout -b release/v0.3.0

# Make any final adjustments to NEWS.md, documentation
# Commit changes to release branch
git add NEWS.md
git commit -m "docs(04): finalize v0.3.0 changelog"

# Run validation suite on release branch (R code above)
# Fix any issues found, commit to release branch

# Push release branch (do NOT tag yet - user does this manually)
git push -u origin release/v0.3.0

# Manual step for user: After confirming everything passes
# git tag -a v0.3.0 -m "Release v0.3.0"
# git push origin v0.3.0
```

### Checking .Rbuildignore Effectiveness

```r
# Source: https://blog.r-hub.io/2020/05/20/rbuildignore/
# Verify non-package files excluded from tarball

# Build source tarball
pkg_tarball <- pkgbuild::build()

# List contents and check for unwanted files
contents <- system(paste("tar -tzf", pkg_tarball), intern = TRUE)

# Should NOT appear in tarball
unwanted <- c(".planning", ".claude", "docs/", "CLAUDE.MD")
for (pattern in unwanted) {
  matches <- grep(pattern, contents, value = TRUE)
  if (length(matches) > 0) {
    message("WARNING: Found ", pattern, " in tarball:")
    print(matches)
  }
}

# Clean up
unlink(pkg_tarball)
```

### Updating OSF Preprint References to Published DOI

```r
# Current pattern in R/estimate_varcov.R and R/get_marginal_effect.R:
# For more details, see [Magirr et al. (2024)](https://osf.io/9mp58/).

# Updated pattern (roxygen2 comment):
#' For more details, see Magirr et al. (2025) \doi{10.1002/pst.70021}.

# In vignettes (markdown format):
# See [Magirr et al. (2025)](https://doi.org/10.1002/pst.70021) for discussion...

# In DESCRIPTION (DOI format):
# (see Magirr et al (2025) <doi:10.1002/pst.70021>).
```

## State of the Art

| Old Approach | Current Approach | When Changed | Impact |
|--------------|------------------|--------------|--------|
| Multi-section NEWS with verbose bullets | Simpler sections (New Features, Improvements, Bug Fixes) with one-liners | Tidyverse adoption ~2018 | More scannable, easier for users to find relevant changes |
| Manual R CMD check | `devtools::check(cran = TRUE)` | devtools 2.x (~2019) | Consistent CRAN simulation, catches more issues pre-submission |
| Manual URL checking | `urlchecker::url_check()` | Package released 2020 | Automated detection of broken/redirected URLs before CRAN submission |
| Git Flow with long-lived release branches | Git Flow with short-lived release branches OR trunk-based | ~2020 shift | Modern CI/CD favors trunk-based, but versioned releases still use short Git Flow |

**Deprecated/outdated:**
- **Manual CRAN submission form**: Now use `devtools::submit_cran()` for automated submission
- **`devtools::release()`**: Deprecated in favor of `devtools::submit_cran()`
- **Including docs/ in git**: Now excluded via .Rbuildignore, built by pkgdown CI/CD
- **Version numbers in dependency mentions**: Tidyverse style now omits versions from NEWS.md

## Open Questions

### 1. Documentation Section in NEWS.md

**What we know:**
- Phases 2-3 included substantial documentation work (man page polish, vignette restructure, pkgdown reorganization)
- Tidyverse style says "minor changes to documentation don't need to be documented"
- User decisions specify simpler sections: "New Features", "Improvements", "Bug Fixes"

**What's unclear:**
- Does "doc updates, vignette polish, pkgdown restructure" qualify as "minor" or should it be noted?
- If included, does it go in "Improvements" or a separate "Documentation" section?

**Recommendation:**
- Add one-liner in "Improvements": "Enhanced vignettes with improved narrative flow and cross-referencing."
- Do NOT create separate "Documentation" section (not standard tidyverse practice)
- Rationale: User-visible documentation improvements belong in Improvements; internal roxygen tweaks don't

### 2. Dependency Changes in NEWS.md

**What we know:**
- v0.3.0 added `rlang` to Imports (mentioned in current NEWS.md)
- Also added to Suggests: `generics`, `cards`, `gt`, `ggplot2`
- Tidyverse packages (dplyr, tidyr) prominently note dependency changes

**What's unclear:**
- Should all dependency additions be listed, or only Imports?
- Current NEWS.md only mentions `rlang` - are others worth noting?

**Recommendation:**
- Keep rlang mention (Imports change, always note these)
- Add one-liner for Suggests: "Added Suggests dependencies for enhanced visualization (ggplot2) and table formatting (gt, cards, generics)."
- Rationale: These enable major new features (plot_forest, beeca_summary_table, beeca_to_cards_ard)

### 3. Known Test Failure Handling

**What we know:**
- test-beeca-fit.R line 174 has pre-existing test failure (skip with "Known issue")
- Additional context states this is "known and accepted — should not block release"
- CRAN requires 0 errors, 0 warnings from R CMD check (but skipped tests don't cause check errors)

**What's unclear:**
- Does skipped test with "Known issue" comment satisfy CRAN standards?
- Should this be documented in NEWS.md or cran-comments.md?

**Recommendation:**
- Keep test skipped (won't block CRAN)
- Do NOT mention in NEWS.md (internal test issue, not user-facing)
- If CRAN asks about it, explain in cran-comments.md: "One test skipped in test environment due to subscript bounds issue in mocked data; does not affect package functionality"

## Sources

### Primary (HIGH confidence)

**Tidyverse Style and Standards:**
- [Tidyverse NEWS.md Style Guide](https://style.tidyverse.org/news.html) - Official guidance on changelog structure and tone
- [dplyr NEWS.md Examples](https://github.com/tidyverse/dplyr/blob/main/NEWS.md) - Reference implementation of tidyverse changelog style
- [R Packages Book: NEWS.md](https://r-pkgs.org/other-markdown.html#sec-news) - Comprehensive guide to maintaining package changelog

**CRAN Submission Requirements:**
- [CRAN Submission Checklist](https://cran.r-project.org/web/packages/submission_checklist.html) - Official CRAN submission requirements
- [R Packages Book: Releasing to CRAN](https://r-pkgs.org/release.html) - Complete release workflow with validation steps
- [CRAN URL Checks Documentation](https://cran.r-project.org/web/packages/URL_checks.html) - URL validation requirements

**Package Development Tools:**
- [devtools::check() Reference](https://devtools.r-lib.org/reference/check.html) - Official documentation for CRAN-style checking
- [urlchecker Package](https://github.com/r-lib/urlchecker) - URL validation tool used by CRAN
- [usethis::use_release_issue()](https://usethis.r-lib.org/reference/use_release_issue.html) - Automated release checklist generation

**Version Control Workflows:**
- [Atlassian Git Flow Workflow](https://www.atlassian.com/git/tutorials/comparing-workflows/gitflow-workflow) - Standard release branching strategy
- [Mastering GitHub Release Branches](https://medium.com/@smita.s.kothari/mastering-github-release-branches-versioning-a-complete-guide-3ea42ebd0d0f) - Modern GitHub release practices

### Secondary (MEDIUM confidence)

- [R-hub Blog: .Rbuildignore](https://blog.r-hub.io/2020/05/20/rbuildignore/) - Best practices for build exclusions
- [R-hub Blog: URL Checks](https://blog.r-hub.io/2020/12/01/url-checks/) - Understanding CRAN URL validation
- [pkgdown: Build and Deploy](https://pkgdown.r-lib.org/reference/build_site.html) - Documentation site building

### Tertiary (LOW confidence)

None - All critical findings verified with authoritative sources

## Metadata

**Confidence breakdown:**
- **Standard stack:** HIGH - devtools, usethis, pkgdown, urlchecker are official R ecosystem tools
- **Architecture:** HIGH - Tidyverse style guide, CRAN checklist, Git Flow are established standards
- **Pitfalls:** HIGH - Derived from official CRAN rejection patterns and R-hub blog analysis

**Research date:** 2026-02-07
**Valid until:** 2026-08-07 (6 months - R ecosystem moves slowly, CRAN standards very stable)

**Package-specific findings verified:**
- DESCRIPTION already shows Version: 0.3.0 (confirmed)
- .Rbuildignore includes `^\.planning$` and `^\.claude$` (confirmed)
- No lifecycle deprecations in codebase (grep found zero matches)
- Two files need OSF → DOI update (confirmed via grep)
- test-beeca-fit.R:174 has known skip (confirmed via read)

**Next steps for planner:**
- Create PLAN-01 for NEWS.md restructuring (add trial02_cdisc, update Magirr reference, restructure sections)
- Create PLAN-02 for pre-release validation (R CMD check, URL validation, pkgdown build)
- Create PLAN-03 for release branch creation (release/v0.3.0 from main, final validation)
