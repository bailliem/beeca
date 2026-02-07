# Convert beeca object to gt table

Creates a publication-ready clinical trial table from beeca analysis
results using the gt package. The table includes marginal risks by
treatment arm, treatment effect estimates with confidence intervals, and
supports customization for titles, footnotes, and analysis set
information.

## Usage

``` r
as_gt(x, ...)

# S3 method for class 'beeca'
as_gt(
  x,
  title = NULL,
  subtitle = NULL,
  source_note = NULL,
  analysis_set = NULL,
  analysis_set_n = NULL,
  conf.level = 0.95,
  risk_digits = 1,
  effect_digits = 2,
  include_ci = TRUE,
  include_pvalue = TRUE,
  risk_percent = TRUE,
  ...
)
```

## Arguments

- x:

  a beeca object (from
  [get_marginal_effect](https://openpharma.github.io/beeca/reference/get_marginal_effect.md)
  or
  [beeca_fit](https://openpharma.github.io/beeca/reference/beeca_fit.md))

- ...:

  additional arguments passed to gt functions

- title:

  character string for table title. Default is NULL (no title).

- subtitle:

  character string for table subtitle. Default is NULL.

- source_note:

  character string for table source/footnote. Default is NULL.

- analysis_set:

  character string describing the analysis population (e.g., "Full
  Analysis Set (FAS)", "Per Protocol Set"). Default is NULL.

- analysis_set_n:

  integer, number of subjects in analysis set. If NULL (default), uses
  the sample size from the model.

- conf.level:

  numeric, confidence level for intervals. Default is 0.95.

- risk_digits:

  integer, decimal places for risk estimates. Default is 1 (displays as
  percentages).

- effect_digits:

  integer, decimal places for treatment effect. Default is 2.

- include_ci:

  logical, whether to include confidence intervals. Default is TRUE.

- include_pvalue:

  logical, whether to include p-values. Default is TRUE.

- risk_percent:

  logical, if TRUE displays risks as percentages (0-100), if FALSE
  displays as proportions (0-1). Default is TRUE.

## Value

a gt table object

## See also

[`get_marginal_effect()`](https://openpharma.github.io/beeca/reference/get_marginal_effect.md)
for the main analysis function

[`beeca_fit()`](https://openpharma.github.io/beeca/reference/beeca_fit.md)
for streamlined analysis pipeline

[`tidy.beeca()`](https://openpharma.github.io/beeca/reference/tidy.beeca.md)
for data frame output

[`summary.beeca()`](https://openpharma.github.io/beeca/reference/summary.beeca.md)
for console output

[`print.beeca()`](https://openpharma.github.io/beeca/reference/print.beeca.md)
for concise output

[`plot.beeca()`](https://openpharma.github.io/beeca/reference/plot.beeca.md)
and
[`plot_forest()`](https://openpharma.github.io/beeca/reference/plot_forest.md)
for visualizations

[`beeca_summary_table()`](https://openpharma.github.io/beeca/reference/beeca_summary_table.md)
for simpler data frame alternative

[`beeca_to_cards_ard()`](https://openpharma.github.io/beeca/reference/beeca_to_cards_ard.md)
for cards ARD integration

## Examples

``` r
if (requireNamespace("gt", quietly = TRUE)) {
  # Fit model
  trial01$trtp <- factor(trial01$trtp)
  fit <- glm(aval ~ trtp + bl_cov, family = "binomial", data = trial01) |>
    get_marginal_effect(trt = "trtp", method = "Ye", contrast = "diff", reference = "0")

  # Create clinical trial table
  as_gt(fit,
    title = "Table 14.2.1: Primary Efficacy Analysis",
    subtitle = "Response Rate by Treatment Group",
    source_note = paste("Risk difference estimated using g-computation",
                        "with robust variance (Ye et al. 2023)"),
    analysis_set = "Full Analysis Set (FAS)"
  )
}
#> Warning: There is 1 record omitted from the original data due to missing values, please check if they should be imputed prior to model fitting.


  


Table 14.2.1: Primary Efficacy Analysis
```

Response Rate by Treatment Group

Treatment

N

Responders

Estimate (%)

95% CI

P-value

Marginal Risk

0

133

65

48.7

(40.2, 57.3)

1

134

56

41.9

(33.5, 50.3)

NA

Risk Difference

diff: 1-0

-6.84

(-18.77, 5.10)

0.261

Full Analysis Set (FAS) (N = 267)

Risk difference estimated using g-computation with robust variance (Ye
et al. 2023)

Marginal risks estimated using g-computation. Variance estimated using
Ye method.
