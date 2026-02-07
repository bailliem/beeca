# Integration with cards/cardx ARD Framework

## Motivation

You’ve completed your covariate-adjusted analysis using
[`get_marginal_effect()`](https://openpharma.github.io/beeca/reference/get_marginal_effect.md)
and obtained marginal treatment effects. Now you need to create Table
14.2.1 for your Clinical Study Report. This table requires:

- **Baseline characteristics** from
  [`cards::ard_continuous()`](https://insightsengineering.github.io/cards/latest-tag/reference/deprecated.html)
  and
  [`cards::ard_categorical()`](https://insightsengineering.github.io/cards/latest-tag/reference/deprecated.html)
- **Treatment effects** from beeca’s robust variance estimation
- **Combined into a single ARD** for your reporting pipeline (gtsummary,
  tfrmt, etc.)

This vignette shows how beeca’s ARD format integrates seamlessly with
the cards/cardx ecosystem for comprehensive clinical trial reporting.
For methodology background and choosing between variance estimation
methods, see
[`vignette('estimand_and_implementations')`](https://openpharma.github.io/beeca/articles/estimand_and_implementations.md).

## ARD Frameworks Comparison

### beeca ARD Structure

The beeca package creates ARDs following pharmaceutical industry
conventions for clinical trial reporting:

``` r
library(beeca)

dat <- trial02_cdisc |>
  dplyr::mutate(TRTP = factor(TRTP))
fit1 <- glm(AVAL ~ TRTP + SEX + RACE + AGE, family = binomial, data = dat) |>
  get_marginal_effect(trt = "TRTP", method = "Ye", contrast = "diff", reference = "Placebo")

fit1$marginal_results
#> # A tibble: 19 × 8
#>    TRTVAR TRTVAL                  PARAM ANALTYP1 STAT  STATVAL ANALMETH ANALDESC
#>    <chr>  <chr>                   <chr> <chr>    <chr>   <dbl> <chr>    <chr>   
#>  1 TRTP   Placebo                 AVAL  DESCRIP… N     86      count    Compute…
#>  2 TRTP   Placebo                 AVAL  DESCRIP… n     29      count    Compute…
#>  3 TRTP   Placebo                 AVAL  DESCRIP… %     33.7    percent… Compute…
#>  4 TRTP   Placebo                 AVAL  INFEREN… risk   0.343  g-compu… Compute…
#>  5 TRTP   Placebo                 AVAL  INFEREN… risk…  0.0519 Ye       Compute…
#>  6 TRTP   Xanomeline High Dose    AVAL  DESCRIP… N     84      count    Compute…
#>  7 TRTP   Xanomeline High Dose    AVAL  DESCRIP… n     61      count    Compute…
#>  8 TRTP   Xanomeline High Dose    AVAL  DESCRIP… %     72.6    percent… Compute…
#>  9 TRTP   Xanomeline High Dose    AVAL  INFEREN… risk   0.716  g-compu… Compute…
#> 10 TRTP   Xanomeline High Dose    AVAL  INFEREN… risk…  0.0484 Ye       Compute…
#> 11 TRTP   Xanomeline Low Dose     AVAL  DESCRIP… N     84      count    Compute…
#> 12 TRTP   Xanomeline Low Dose     AVAL  DESCRIP… n     62      count    Compute…
#> 13 TRTP   Xanomeline Low Dose     AVAL  DESCRIP… %     73.8    percent… Compute…
#> 14 TRTP   Xanomeline Low Dose     AVAL  INFEREN… risk   0.743  g-compu… Compute…
#> 15 TRTP   Xanomeline Low Dose     AVAL  INFEREN… risk…  0.0474 Ye       Compute…
#> 16 TRTP   diff: Xanomeline High … AVAL  INFEREN… diff   0.374  g-compu… Compute…
#> 17 TRTP   diff: Xanomeline High … AVAL  INFEREN… diff…  0.0708 Ye       Compute…
#> 18 TRTP   diff: Xanomeline Low D… AVAL  INFEREN… diff   0.400  g-compu… Compute…
#> 19 TRTP   diff: Xanomeline Low D… AVAL  INFEREN… diff…  0.0702 Ye       Compute…
```

**beeca ARD Schema:**

| Column     | Type      | Description                                                   |
|------------|-----------|---------------------------------------------------------------|
| `TRTVAR`   | character | Treatment variable name                                       |
| `TRTVAL`   | character | Treatment level value                                         |
| `PARAM`    | character | Parameter/outcome variable name                               |
| `ANALTYP1` | character | Analysis type (DESCRIPTIVE or INFERENTIAL)                    |
| `STAT`     | character | Statistic identifier (N, n, %, risk, risk_se, diff, diff_se)  |
| `STATVAL`  | numeric   | Numeric value of the statistic                                |
| `ANALMETH` | character | Analysis method (count, percentage, g-computation, HC0, etc.) |
| `ANALDESC` | character | Analysis description including package version                |

**Key Features:** - CDISC ADaM-inspired column names (PARAM, ANALTYP1) -
Compact structure optimized for clinical trial reporting - Single value
per row (atomic numeric type) - Direct integration with CDISC workflows

### cards/cardx ARD Structure

The cards package provides a more general ARD framework for statistical
computing:

**cards ARD Schema:**

| Column           | Description                                        |
|------------------|----------------------------------------------------|
| `group1`         | First grouping variable name                       |
| `group1_level`   | Level/value of first grouping variable             |
| `group2`         | Second grouping variable name (optional)           |
| `group2_level`   | Level/value of second grouping variable (optional) |
| `variable`       | The analysis variable name                         |
| `variable_level` | Specific level of the variable (for categorical)   |
| `stat_name`      | Statistical measure identifier                     |
| `stat_label`     | Human-readable label for the statistic             |
| `stat`           | The calculated value (list-column)                 |
| `context`        | Analysis context metadata                          |
| `fmt_fn`         | Formatting function reference (list-column)        |
| `warning`        | Warnings from calculation (list-column)            |
| `error`          | Errors from calculation (list-column)              |

**Key Features:** - List-column structure for flexible data types -
Built-in error/warning capture - Human-readable labels separate from
internal names - Formatting functions attached to each statistic -
Extensible context system

## Mapping Between Frameworks

| beeca                   | cards              | Notes                          |
|-------------------------|--------------------|--------------------------------|
| `TRTVAR`                | `group1`           | Treatment variable name        |
| `TRTVAL`                | `group1_level`     | Treatment level                |
| `PARAM`                 | `variable`         | Outcome variable               |
| `STAT`                  | `stat_name`        | Statistic identifier           |
| `STATVAL`               | `stat`             | Value (numeric vs list-column) |
| `ANALTYP1` + `ANALMETH` | `context`          | Analysis context               |
| —                       | `stat_label`       | Missing in beeca               |
| —                       | `fmt_fn`           | Missing in beeca               |
| —                       | `warning`, `error` | Missing in beeca               |
| `ANALDESC`              | attribute          | Package metadata               |

## Converting beeca ARD to cards Format

The beeca package provides the
[`beeca_to_cards_ard()`](https://openpharma.github.io/beeca/reference/beeca_to_cards_ard.md)
function to convert `marginal_results` output to the cards ARD format.
This enables seamless integration with the cards/cardx ecosystem.

The conversion function: - Maps beeca columns (TRTVAR, TRTVAL, PARAM,
STAT, STATVAL) to cards columns (group1, group1_level, variable,
stat_name, stat) - Adds human-readable stat_label for each statistic -
Converts atomic numeric values to list-columns (required by cards) -
Consolidates ANALTYP1 and ANALMETH into a single context field -
Preserves original beeca metadata as attributes

See
[`?beeca_to_cards_ard`](https://openpharma.github.io/beeca/reference/beeca_to_cards_ard.md)
for detailed documentation and the mapping table between beeca and cards
columns.

## Example Usage

``` r
library(cards)

# Convert to cards format (fit1 created in setup chunk)
cards_ard <- beeca_to_cards_ard(fit1$marginal_results)

# Print the cards ARD (uses print method for 'card' class)
print(cards_ard)
#> {cards} data frame: 19 x 11
#>    group1 group1_level variable variable_level stat_name stat_label   stat
#> 1    TRTP      Placebo     AVAL             NA         N          N     86
#> 2    TRTP      Placebo     AVAL             NA         n          n     29
#> 3    TRTP      Placebo     AVAL             NA         %          % 33.721
#> 4    TRTP      Placebo     AVAL             NA      risk       Risk  0.343
#> 5    TRTP      Placebo     AVAL             NA   risk_se    Risk SE  0.052
#> 6    TRTP    Xanomeli…     AVAL             NA         N          N     84
#> 7    TRTP    Xanomeli…     AVAL             NA         n          n     61
#> 8    TRTP    Xanomeli…     AVAL             NA         %          % 72.619
#> 9    TRTP    Xanomeli…     AVAL             NA      risk       Risk  0.716
#> 10   TRTP    Xanomeli…     AVAL             NA   risk_se    Risk SE  0.048
#> 11   TRTP    Xanomeli…     AVAL             NA         N          N     84
#> 12   TRTP    Xanomeli…     AVAL             NA         n          n     62
#> 13   TRTP    Xanomeli…     AVAL             NA         %          %  73.81
#> 14   TRTP    Xanomeli…     AVAL             NA      risk       Risk  0.743
#> 15   TRTP    Xanomeli…     AVAL             NA   risk_se    Risk SE  0.047
#> 16   TRTP    diff: Xa…     AVAL             NA      diff  Differen…  0.374
#> 17   TRTP    diff: Xa…     AVAL             NA   diff_se  Differen…  0.071
#> 18   TRTP    diff: Xa…     AVAL             NA      diff  Differen…    0.4
#> 19   TRTP    diff: Xa…     AVAL             NA   diff_se  Differen…   0.07
#> ℹ 4 more variables: context, warning, error, fmt_fn

# Bind with other cards ARDs
combined_ard <- cards::bind_ard(
  cards_ard,
  cards::ard_continuous(dat, by = TRTP, variables = AGE)
)

print(combined_ard)
#> {cards} data frame: 43 x 12
#>    group1 group1_level variable variable_level stat_name stat_label   stat
#> 1    TRTP      Placebo     AVAL             NA         N          N     86
#> 2    TRTP      Placebo     AVAL             NA         n          n     29
#> 3    TRTP      Placebo     AVAL             NA         %          % 33.721
#> 4    TRTP      Placebo     AVAL             NA      risk       Risk  0.343
#> 5    TRTP      Placebo     AVAL             NA   risk_se    Risk SE  0.052
#> 6    TRTP    Xanomeli…     AVAL             NA         N          N     84
#> 7    TRTP    Xanomeli…     AVAL             NA         n          n     61
#> 8    TRTP    Xanomeli…     AVAL             NA         %          % 72.619
#> 9    TRTP    Xanomeli…     AVAL             NA      risk       Risk  0.716
#> 10   TRTP    Xanomeli…     AVAL             NA   risk_se    Risk SE  0.048
#> ℹ 33 more rows
#> ℹ Use `print(n = ...)` to see more rows
#> ℹ 5 more variables: context, fmt_fun, warning, error, fmt_fn
```

## Use Cases for Integration

### 1. Comprehensive Reporting

Combine beeca’s covariate-adjusted treatment effects with descriptive
statistics from cards:

``` r
# Treatment effect from beeca
te_ard <- beeca_to_cards_ard(fit1$marginal_results)

# Baseline characteristics from cards
baseline_ard <- cards::ard_continuous(
  data = dat,
  by = TRTP,
  variables = AGE
)

# Combine into comprehensive ARD
full_ard <- cards::bind_ard(te_ard, baseline_ard)
```

### 2. Quality Control Workflows

Use cards error-handling features with beeca results:

``` r
# Multiple analyses with error capture
contrasts <- c("diff", "rr", "or")
analyses <- lapply(contrasts, function(contrast_type) {
  cards::eval_capture_conditions({
    glm(AVAL ~ TRTP + SEX + RACE + AGE, family = binomial, data = dat) |>
      get_marginal_effect(trt = "TRTP", contrast = contrast_type, reference = "Placebo") |>
      (\(x) x$marginal_results)()
  })
})

# Check for errors
errors <- Filter(function(x) !is.null(x$error), analyses)
```

### 3. Cross-Study Meta-Analysis

Standardize results across multiple studies:

``` r
# Create fit objects for two studies (using same data for illustration)
fit_study1 <- glm(AVAL ~ TRTP + SEX + RACE + AGE, family = binomial, data = dat) |>
  get_marginal_effect(trt = "TRTP", method = "Ye", contrast = "diff", reference = "Placebo")

fit_study2 <- glm(AVAL ~ TRTP + SEX + RACE + AGE, family = binomial, data = dat) |>
  get_marginal_effect(trt = "TRTP", method = "Ye", contrast = "diff", reference = "Placebo")
```

``` r
# Study 1 (beeca)
study1_ard <- beeca_to_cards_ard(fit_study1$marginal_results) |>
  dplyr::mutate(study = "STUDY001")

# Study 2 (beeca)
study2_ard <- beeca_to_cards_ard(fit_study2$marginal_results) |>
  dplyr::mutate(study = "STUDY002")

# Combine
meta_ard <- cards::bind_ard(study1_ard, study2_ard)
#> ℹ 19 rows with duplicated statistic values have been removed.
#> • See cards::bind_ard(.distinct) (`?cards::bind_ard()`) for details.

# Extract estimates for meta-analysis
estimates <- meta_ard |>
  dplyr::filter(stat_name == "diff") |>
  dplyr::mutate(estimate = unlist(stat))
```

## When to Use Each Format

### Use beeca’s Native ARD When:

- Working primarily in CDISC environments
- Generating clinical trial reports
- Compact storage is preferred
- Integrating with ADaM datasets
- Direct numeric values are sufficient

### Convert to cards ARD When:

- Combining with other cards/cardx analyses
- Need error/warning tracking
- Want formatting functions attached
- Working with general statistical workflows
- Need extensible metadata system
- Generating complex multi-analysis reports

## Design Philosophy Differences

### beeca ARD

- **Goal:** Clinical trial reporting efficiency
- **Structure:** Compact, CDISC-aligned
- **Storage:** Atomic numeric values
- **Context:** Domain-specific columns (ANALTYP1, ANALMETH)
- **Focus:** Marginal treatment effects

### cards ARD

- **Goal:** General statistical computing reproducibility
- **Structure:** Flexible, extensible
- **Storage:** List-columns for any data type
- **Context:** Single extensible context column
- **Focus:** Any statistical analysis

## Next Steps

- For estimand concepts and method selection, see
  [`vignette('estimand_and_implementations')`](https://openpharma.github.io/beeca/articles/estimand_and_implementations.md)
- For creating regulatory-ready tables, see
  [`vignette('clinical-trial-table')`](https://openpharma.github.io/beeca/articles/clinical-trial-table.md)

## References

- [cards package
  documentation](https://insightsengineering.github.io/cards/)
- [cardx package
  documentation](https://insightsengineering.github.io/cardx/)
- [CDISC ADaM Implementation
  Guide](https://www.cdisc.org/standards/foundational/adam)
- [beeca package documentation](https://openpharma.github.io/beeca/)

## Session Info

``` r
sessionInfo()
#> R version 4.5.2 (2025-10-31)
#> Platform: x86_64-pc-linux-gnu
#> Running under: Ubuntu 24.04.3 LTS
#> 
#> Matrix products: default
#> BLAS:   /usr/lib/x86_64-linux-gnu/openblas-pthread/libblas.so.3 
#> LAPACK: /usr/lib/x86_64-linux-gnu/openblas-pthread/libopenblasp-r0.3.26.so;  LAPACK version 3.12.0
#> 
#> locale:
#>  [1] LC_CTYPE=C.UTF-8       LC_NUMERIC=C           LC_TIME=C.UTF-8       
#>  [4] LC_COLLATE=C.UTF-8     LC_MONETARY=C.UTF-8    LC_MESSAGES=C.UTF-8   
#>  [7] LC_PAPER=C.UTF-8       LC_NAME=C              LC_ADDRESS=C          
#> [10] LC_TELEPHONE=C         LC_MEASUREMENT=C.UTF-8 LC_IDENTIFICATION=C   
#> 
#> time zone: UTC
#> tzcode source: system (glibc)
#> 
#> attached base packages:
#> [1] stats     graphics  grDevices utils     datasets  methods   base     
#> 
#> other attached packages:
#> [1] cards_0.7.1 beeca_0.3.0
#> 
#> loaded via a namespace (and not attached):
#>  [1] jsonlite_2.0.0    dplyr_1.2.0       compiler_4.5.2    tidyselect_1.2.1 
#>  [5] tidyr_1.3.2       jquerylib_0.1.4   systemfonts_1.3.1 textshaping_1.0.4
#>  [9] yaml_2.3.12       fastmap_1.2.0     lattice_0.22-7    R6_2.6.1         
#> [13] generics_0.1.4    knitr_1.51        htmlwidgets_1.6.4 tibble_3.3.1     
#> [17] desc_1.4.3        bslib_0.10.0      pillar_1.11.1     rlang_1.1.7      
#> [21] utf8_1.2.6        cachem_1.1.0      xfun_0.56         fs_1.6.6         
#> [25] sass_0.4.10       cli_3.6.5         pkgdown_2.2.0     withr_3.0.2      
#> [29] magrittr_2.0.4    grid_4.5.2        digest_0.6.39     sandwich_3.1-1   
#> [33] lifecycle_1.0.5   vctrs_0.7.1       evaluate_1.0.5    glue_1.8.0       
#> [37] ragg_1.5.0        zoo_1.8-15        rmarkdown_2.30    purrr_1.2.1      
#> [41] tools_4.5.2       pkgconfig_2.0.3   htmltools_0.5.9
```
