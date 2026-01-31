# External Integrations

**Analysis Date:** 2026-01-31

## APIs & External Services

**None Detected**

The beeca package is a pure statistical computation library with no external API integrations. It does not call out to remote services, cloud APIs, or web endpoints. All analysis is performed locally on the user's data.

## Data Storage

**Local File System:**
- Package includes 4 built-in example datasets stored as R data files (`.rda`)
  - `data/trial01.rda` - Clinical trial example data
  - `data/trial02_cdisc.rda` - CDISC-formatted trial data
  - `data/margins_trial01.rda` - SAS margins comparison data
  - `data/ge_macro_trial01.rda` - SAS macro comparison data

**Database Connections:**
- Not applicable - Package accepts pre-loaded R data frames only
- No database client libraries (DBI, RSQLite, etc.) in dependencies
- Data must be loaded into memory as R data frames before analysis

**File Storage:**
- Local filesystem only
- No cloud storage integration (S3, Azure Blob, GCS, etc.)
- Users provide data as R data frames to `glm()` function

**Caching:**
- None detected - Package does not implement caching mechanisms
- Results are computed fresh each invocation

## Authentication & Identity

**Auth Provider:**
- Not applicable - Package is pure computation, no authentication required
- No OAuth, API keys, or user identity management
- No user session or login system

**Authorization:**
- Not applicable

## External Software & Cross-Validation

**Reference Implementations (Testing Only):**

The package validates against multiple external implementations for correctness:

| Software | Purpose | Type | Reference |
|----------|---------|------|-----------|
| SAS %margins macro | Validate Ge et al. variance estimates | External statistical software | Data: `data/margins_trial01.rda` |
| SAS macro (custom) | Validate Ge variance computation | External statistical software | Data: `data/ge_macro_trial01.rda` |
| RobinCar R package | Validate Ye et al. variance estimates | R package (>= 0.3.0, Suggests) | Used for method validation and cross-checking |
| marginaleffects R package | Validate treatment effect estimates | R package (Suggests) | Cross-validation of margin computations |
| margins R package | Validate treatment effect estimates | R package (Suggests) | Cross-validation of contrast calculations |

These are **validation references only** - not runtime dependencies. They are used in testing to ensure beeca produces correct results.

## Monitoring & Observability

**Error Tracking:**
- Not detected - Package has no error reporting or monitoring integration
- Errors are returned to the user's R session (standard error handling)

**Logs:**
- Package does not produce structured logs
- Users can capture output/errors through standard R mechanisms:
  - `sink()` for redirecting output
  - `tryCatch()` for error handling
  - Standard R message/warning/error functions

**Diagnostic Output:**
- `print()`, `summary()`, `plot()` methods available for result inspection
- Location: `R/print.R`, `R/summary.R`, `R/plot.R`

## CI/CD & Deployment

**Continuous Integration:**
- GitHub Actions (primary CI platform)
- Workflows:
  - `.github/workflows/R-CMD-check.yaml` - Package checks on Windows, macOS, Linux
  - `.github/workflows/test-coverage.yaml` - Code coverage analysis
  - `.github/workflows/pkgdown.yaml` - Documentation site generation and deployment
  - `.github/workflows/rhub.yaml` - R-hub validation checks

**Continuous Deployment:**
- GitHub Pages for documentation
  - Automatic deployment on push to main
  - Branch: `gh-pages`
  - URL: https://openpharma.github.io/beeca/

**Package Distribution:**
- CRAN (Comprehensive R Archive Network) - Manual submission/release
- GitHub releases - Automatic via GitHub Actions
- GitHub package registry - Development versions

## Environment Configuration

**Required Environment Variables:**
- None required for core functionality
- CI system uses: `GITHUB_PAT` (GitHub Personal Access Token for package installation)
  - Used in workflows for `remotes::install_github()` calls

**Secrets Location:**
- GitHub Secrets (for CI/CD workflows)
  - `GITHUB_TOKEN` - Automatic GitHub Actions token
  - `RHUB_TOKEN` - R-hub validation token (if configured)

**Build Configuration:**
- No external service configuration needed
- Standard R package build process via `R CMD build`

## Package Integrations

**Optional Package Integrations (Runtime):**

### cards Package Integration
- **Location:** `R/beeca_to_cards_ard.R`
- **Function:** `beeca_to_cards_ard(marginal_results)`
- **Purpose:** Convert beeca Analysis Results Data (ARD) to cards package ARD format
- **Dependency Type:** Soft (Suggests)
- **What it enables:**
  - Integration with cards/cardx ecosystem for reporting
  - Quality control workflows via cards validation functions
  - Binding with other ARD outputs via `cards::bind_ard()`
- **Error Handling:** If cards not installed, function throws informative error:
  ```
  "Package 'cards' is required for this conversion. Please install it with:
   install.packages("cards")"
  ```

### ggplot2 Package Integration
- **Location:** `R/plot_forest.R`, `R/plot.R`
- **Function:** `plot_forest()`, `plot.beeca()`
- **Purpose:** Forest plot visualization of treatment effects
- **Dependency Type:** Soft (Suggests)
- **What it enables:**
  - Graphical visualization of marginal treatment effects
  - Forest plot with confidence intervals

### gt Package Integration
- **Location:** `R/as_gt.R`
- **Methods:** `as_gt.beeca()`, `as_gt.default()`
- **Purpose:** Convert results to gt (Great Tables) format for publication
- **Dependency Type:** Soft (Suggests)
- **What it enables:**
  - Publication-quality formatted tables
  - ARD summary tables for regulatory submission

## Data Format Standards

**Input Format:**
- R data frames with columns containing:
  - Binary outcome (0/1 coded)
  - Treatment variable (factor with 2+ levels)
  - Optional covariates (numeric or factors)
  - Optional stratification variables

**Output Format (Analysis Results Data):**
- beeca proprietary ARD tibble (internal format)
  - Columns: `TRTVAR`, `TRTVAL`, `PARAM`, `ANALTYP1`, `STAT`, `STATVAL`, `ANALMETH`, `ANALDESC`
  - CDISC-inspired but beeca-specific structure
  - Location: Attached to glm object as `$marginal_results`

**Cards Format Output:**
- Converts beeca ARD to cards/CDISC ARD via `beeca_to_cards_ard()`
- Cards ARD columns: `group1`, `group1_level`, `variable`, `variable_level`, `stat_name`, `stat_label`, `stat`, `context`
- Standardized pharmaceutical industry ARD format

## Webhooks & Callbacks

**Incoming Webhooks:**
- None detected

**Outgoing Webhooks:**
- None detected

**GitHub Integration:**
- No webhook-based integrations
- Uses standard GitHub API for releases/documentation (via Actions)

## External References & Methods

**Methodological References (Not Runtime Dependencies):**
- FDA Guidance (2023) - Referenced in documentation
- Ge et al. (2011) paper - Variance estimation method implementation
- Ye et al. (2023) paper - Robust variance for population ATE
- Magirr et al. (2025) paper - Extended methodology paper (PMID: 40557557)

These are literature references for validation and methodology understanding, not API integrations.

## Development Community

**Working Group:**
- ASA-BIOP Covariate Adjustment Scientific Working Group
- URL: https://carswg.github.io/
- Software Subteam collaboration

**Bug Reporting:**
- GitHub Issues: https://github.com/openpharma/beeca/issues

**Community Resources:**
- OpenPharma (nonprofit) - Package stewardship
- GitHub Repository: https://github.com/openpharma/beeca

---

*Integration audit: 2026-01-31*
