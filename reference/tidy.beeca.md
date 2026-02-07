# Tidy method for beeca objects

Extracts and tidies the marginal treatment effect estimates from a beeca
object. This function provides a broom-compatible interface for
extracting specific statistics from the Analysis Results Data (ARD)
structure.

## Usage

``` r
# S3 method for class 'beeca'
tidy(x, conf.int = FALSE, conf.level = 0.95, include_marginal = FALSE, ...)
```

## Arguments

- x:

  a beeca object (glm object modified by
  [get_marginal_effect](https://openpharma.github.io/beeca/reference/get_marginal_effect.md))

- conf.int:

  logical indicating whether to include confidence intervals. Defaults
  to FALSE.

- conf.level:

  confidence level for intervals. Defaults to 0.95.

- include_marginal:

  logical indicating whether to include marginal risk estimates for each
  treatment arm in addition to contrasts. Defaults to FALSE.

- ...:

  additional arguments (not currently used)

## Value

a tibble with columns:

|           |                                                  |
|-----------|--------------------------------------------------|
| term      | The parameter name (contrast or treatment level) |
| estimate  | The point estimate                               |
| std.error | The standard error of the estimate               |
| statistic | The Wald test statistic (estimate / std.error)   |
| p.value   | Two-sided p-value from the Wald test             |
| conf.low  | Lower confidence limit (if conf.int = TRUE)      |
| conf.high | Upper confidence limit (if conf.int = TRUE)      |

## Details

The `tidy.beeca()` method extracts key inferential statistics from the
`marginal_results` component of a beeca object. By default, it returns
the contrast estimates (treatment effects) with their standard errors,
test statistics, and p-values. Optionally, it can also include the
marginal risk estimates for each treatment arm.

The function computes Wald test statistics (estimate / std.error) and
corresponding two-sided p-values for each estimate.

## See also

[`get_marginal_effect()`](https://openpharma.github.io/beeca/reference/get_marginal_effect.md)
for the main analysis function

[`beeca_fit()`](https://openpharma.github.io/beeca/reference/beeca_fit.md)
for streamlined analysis pipeline

[`print.beeca()`](https://openpharma.github.io/beeca/reference/print.beeca.md)
for concise output

[`summary.beeca()`](https://openpharma.github.io/beeca/reference/summary.beeca.md)
for detailed summary output

[`augment.beeca()`](https://openpharma.github.io/beeca/reference/augment.beeca.md)
for augmented predictions

[`plot.beeca()`](https://openpharma.github.io/beeca/reference/plot.beeca.md)
and
[`plot_forest()`](https://openpharma.github.io/beeca/reference/plot_forest.md)
for visualizations

[`as_gt()`](https://openpharma.github.io/beeca/reference/as_gt.md) for
publication-ready tables

## Examples

``` r
trial01$trtp <- factor(trial01$trtp)
fit1 <- glm(aval ~ trtp + bl_cov, family = "binomial", data = trial01) |>
  get_marginal_effect(trt = "trtp", method = "Ye", contrast = "diff", reference = "0")
#> Warning: There is 1 record omitted from the original data due to missing values, please check if they should be imputed prior to model fitting.

# Tidy the contrast results
tidy(fit1)
#> # A tibble: 1 × 5
#>   term      estimate std.error statistic p.value
#>   <chr>        <dbl>     <dbl>     <dbl>   <dbl>
#> 1 diff: 1-0  -0.0684    0.0609     -1.12   0.261

# Include confidence intervals
tidy(fit1, conf.int = TRUE)
#> # A tibble: 1 × 7
#>   term      estimate std.error statistic p.value conf.low conf.high
#>   <chr>        <dbl>     <dbl>     <dbl>   <dbl>    <dbl>     <dbl>
#> 1 diff: 1-0  -0.0684    0.0609     -1.12   0.261   -0.188    0.0510

# Include marginal risk estimates for each arm
tidy(fit1, include_marginal = TRUE, conf.int = TRUE)
#> # A tibble: 3 × 7
#>   term      estimate std.error statistic  p.value conf.low conf.high
#>   <chr>        <dbl>     <dbl>     <dbl>    <dbl>    <dbl>     <dbl>
#> 1 risk_0      0.487     0.0435     11.2  3.84e-29    0.402    0.573 
#> 2 risk_1      0.419     0.0427      9.82 9.39e-23    0.335    0.503 
#> 3 diff: 1-0  -0.0684    0.0609     -1.12 2.61e- 1   -0.188    0.0510
```
