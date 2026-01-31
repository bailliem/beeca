# Technology Stack

**Analysis Date:** 2026-01-31

## Languages

**Primary:**
- R 3.10+ (specified in DESCRIPTION: `R (>= 2.10)`)

**Markup/Documentation:**
- R Markdown - Used in vignettes (`R/vignettes/*.Rmd`)
- YAML - Configuration files (workflows, pkgdown)

## Runtime

**Environment:**
- R runtime (base R statistical computing environment)

**Package Manager:**
- CRAN - Primary distribution channel
- GitHub - Development distribution via `remotes::install_github("openpharma/beeca")`
- Lockfile: Not detected (standard R package, uses DESCRIPTION)

## Frameworks

**Core Statistical:**
- stats (base R) - Generalized Linear Models (GLM), binomial family with logit link
  - Imported: `binomial()`, `model.frame()`, `model.matrix()`, `predict()`, `terms()`, `vcov()`, `var()`, `cov()`
  - Location: `R/estimate_varcov.R`, `R/predict_counterfactuals.R`, `R/sanitize.R`, and others

**Robust Variance Estimation:**
- sandwich (>= 3.0.0) - HC0, HC1, HC2, HC3, HC4, HC4m, HC5 heteroscedasticity-consistent estimators
  - Used in: `R/estimate_varcov.R` for Ge et al. (2011) variance estimation
  - Via `sandwich::vcovHC()` for variance-covariance matrix computation

**Data Manipulation:**
- dplyr - Data frame operations, tibbles, pipe syntax
  - Imported: `as_tibble()`, `rename()`, `mutate()`, `select()`, `case_when()`, column selection helpers
  - Location: `R/beeca_to_cards_ard.R`, `R/apply_contrast.R`, multiple files

**Function Generics:**
- generics - S3 generic function dispatch
  - Imported: `augment()`, `tidy()` from generics package
  - Used for broom-compatible output methods in `R/augment.R` and `R/tidy.R`

**Error Handling & Metaprogramming:**
- rlang - R language utilities for non-standard evaluation
  - Imported: `.data` pronoun for tidyverse compatibility
  - Location: `R/beeca_to_cards_ard.R`, `R/apply_contrast.R`, and other data manipulation functions

**Lifecycle Management:**
- lifecycle - Package lifecycle badges and deprecation messaging
  - Imported: `deprecated()` function
  - Used for marking deprecated functions and parameters

**Documentation Generation:**
- roxygen2 (>= 7.3.2) - Automatic documentation and NAMESPACE generation
  - Configured in DESCRIPTION: `RoxygenNote: 7.3.2`
  - All function documentation processed via roxygen2
  - Location: Inline roxygen comments in all `R/*.R` files

**Website/Documentation:**
- pkgdown - Static site generation from R documentation
  - Config: `_pkgdown.yml`, `.github/workflows/pkgdown.yaml`
  - Generates website at: https://openpharma.github.io/beeca/

**Testing:**
- testthat (>= 3.0.0) - Unit testing framework
  - Config: `Config/testthat/edition: 3` in DESCRIPTION
  - Location: `tests/testthat/*.R` files (12 test suites)
  - Execution: `tests/testthat.R` orchestrates test discovery

**Vignette Building:**
- knitr - Dynamic report generation
- rmarkdown - R Markdown processing
  - Config: `VignetteBuilder: knitr` in DESCRIPTION
  - Location: `vignettes/*.Rmd` (3 vignettes)

## Key Dependencies

**Imports (Required for Package Functionality):**

| Package | Purpose | Files |
|---------|---------|-------|
| dplyr | Data manipulation, tibbles, piping | `R/beeca_to_cards_ard.R`, `R/apply_contrast.R`, multiple |
| sandwich | Robust variance estimation (HC0-HC5) | `R/estimate_varcov.R` |
| generics | S3 generic dispatch for `tidy()`, `augment()` | `R/tidy.R`, `R/augment.R` |
| lifecycle | Package lifecycle and deprecation | `R/get_marginal_effect.R`, `R/beeca_fit.R` |
| rlang | Non-standard evaluation (`.data` pronoun) | `R/beeca_to_cards_ard.R`, `R/apply_contrast.R` |
| stats | Base GLM, model matrices, prediction | `R/estimate_varcov.R`, `R/sanitize.R`, `R/predict_counterfactuals.R` |

**Suggested/Soft Dependencies (Testing & Vignettes):**

| Package | Purpose | Version | Usage |
|---------|---------|---------|-------|
| testthat | Unit testing framework | >= 3.0.0 | `tests/testthat/` (12 test files) |
| cards | ARD format conversion | None specified | Optional integration via `beeca_to_cards_ard()` |
| ggplot2 | Forest plot visualization | None specified | Optional in `R/plot_forest.R` |
| gt | Formatted table output | None specified | Optional in `R/as_gt.R` for ARD tables |
| knitr | Dynamic report generation | None specified | Vignette building |
| rmarkdown | R Markdown processing | None specified | Vignette building |
| tidyr | Data reshaping | None specified | Optional in vignettes |
| marginaleffects | Cross-validation against other implementations | None specified | Testing/validation only |
| margins | Cross-validation against R package | None specified | Testing/validation only |
| RobinCar | Cross-validation and Ye variance method | >= 0.3.0 | Testing/validation and method implementation reference |
| covr | Code coverage analysis | None specified | CI workflow for test-coverage.yaml |

## Configuration

**Environment:**
- Standard R environment variables (R_LIBS, etc.)
- No .env file detected
- No environment-specific configuration

**Build Configuration:**
- `beeca.Rproj` - RStudio project configuration
  - Settings: UTF-8 encoding, 2-space tabs, roxygen2 integration
  - Location: `/Users/bailliem/R-projects/beeca-gsd/beeca.Rproj`

**Package Configuration:**
- `DESCRIPTION` - Package metadata, dependencies, version (0.3.0)
  - License: LGPL (>= 3)
  - Maintainer: Alex Przybylski <alexander.przybylski@novartis.com>

**Documentation Configuration:**
- `_pkgdown.yml` - Website template configuration
  - Template: Bootstrap 5
  - URL: https://openpharma.github.io/beeca/

**Build Ignore List:**
- `.Rbuildignore` - Excludes test files, documentation, GitHub workflows, Claude files from package distribution

## Platform Requirements

**Development:**
- R >= 3.10 (minimum R version for newer dplyr, generics)
- RStudio (optional but recommended)
- Git (for version control and GitHub integration)
- GitHub Actions runner support (Linux, macOS, Windows)

**Production/CRAN:**
- R >= 2.10 (stated minimum in DESCRIPTION)
- Windows, macOS, Linux (multi-platform tested via R-CMD-check)
- Old R release (oldrel-1) tested in CI to ensure backwards compatibility

**CI/CD Platforms:**
- GitHub Actions (primary)
  - Tested on: macos-latest, windows-latest, ubuntu-latest
  - R versions: devel, release, oldrel-1
- R-hub (secondary validation)
  - Configured in `.github/workflows/rhub.yaml`
  - Tests across Linux containers, Windows, macOS

## Code Quality & Validation

**Documentation Generation:**
- roxygen2 (7.3.2) - Automatic doc generation from inline comments
  - Generates: `man/*.Rd` files, `NAMESPACE`

**Linting/Formatting:**
- Not explicitly configured (relies on roxygen2 and standard R conventions)

**Testing Coverage:**
- covr - Code coverage analysis in CI
  - Workflow: `.github/workflows/test-coverage.yaml`
  - Reports coverage metrics from test suite

## External Integrations

**Version Control:**
- GitHub repository: https://github.com/openpharma/beeca
- Issue tracking: GitHub Issues

**Package Registry:**
- CRAN - Official R package repository (release distribution)
- GitHub packages - Development versions

**Documentation Hosting:**
- GitHub Pages - Static site generation and hosting
  - URL: https://openpharma.github.io/beeca/
  - Branch: `gh-pages`

---

*Stack analysis: 2026-01-31*
