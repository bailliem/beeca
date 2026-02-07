# Forest plot for marginal treatment effects

Creates a forest plot displaying treatment effect estimates with
confidence intervals. Useful for visualizing results from
covariate-adjusted analyses, especially with multiple treatment
comparisons.

## Usage

``` r
plot_forest(
  x,
  conf.level = 0.95,
  title = NULL,
  xlab = NULL,
  show_values = TRUE,
  null_line_color = "darkgray",
  point_size = 3,
  ...
)
```

## Arguments

- x:

  a beeca object (from
  [get_marginal_effect](https://openpharma.github.io/beeca/reference/get_marginal_effect.md))

- conf.level:

  confidence level for confidence intervals. Default is 0.95.

- title:

  optional plot title. If NULL, a default title is generated.

- xlab:

  optional x-axis label. If NULL, a label based on the contrast type is
  generated.

- show_values:

  logical indicating whether to display numerical values on the plot.
  Default is TRUE.

- null_line_color:

  color for the null effect reference line. Default is "darkgray".

- point_size:

  size of the point estimates. Default is 3.

- ...:

  additional arguments (not currently used)

## Value

a ggplot object

## Details

The forest plot displays point estimates as dots with horizontal lines
representing confidence intervals. A vertical reference line is drawn at
the null effect value (0 for differences, 1 for ratios). For multiple
comparisons (e.g., 3-arm trials), each comparison is shown on a separate
row.

The plot can be customized using standard ggplot2 functions by adding
layers to the returned ggplot object.

## See also

[`get_marginal_effect()`](https://openpharma.github.io/beeca/reference/get_marginal_effect.md)
for the main analysis function

[`beeca_fit()`](https://openpharma.github.io/beeca/reference/beeca_fit.md)
for streamlined analysis pipeline

[`plot.beeca()`](https://openpharma.github.io/beeca/reference/plot.beeca.md)
for the generic plot method

[`tidy.beeca()`](https://openpharma.github.io/beeca/reference/tidy.beeca.md)
for extracting estimates in tabular form

[`print.beeca()`](https://openpharma.github.io/beeca/reference/print.beeca.md)
for concise output

[`summary.beeca()`](https://openpharma.github.io/beeca/reference/summary.beeca.md)
for detailed summary output

[`as_gt()`](https://openpharma.github.io/beeca/reference/as_gt.md) for
publication-ready tables

## Examples

``` r
if (requireNamespace("ggplot2", quietly = TRUE)) {
  trial01$trtp <- factor(trial01$trtp)
  fit1 <- glm(aval ~ trtp + bl_cov, family = "binomial", data = trial01) |>
    get_marginal_effect(trt = "trtp", method = "Ye", contrast = "diff", reference = "0")

  # Basic forest plot
  plot_forest(fit1)

  # Customize with ggplot2
  plot_forest(fit1) +
    ggplot2::theme_minimal() +
    ggplot2::labs(title = "Treatment Effect: My Study")

  # Risk ratio example
  fit_rr <- glm(aval ~ trtp + bl_cov, family = "binomial", data = trial01) |>
    get_marginal_effect(trt = "trtp", method = "Ye", contrast = "rr", reference = "0")
  plot_forest(fit_rr)
}
#> Warning: There is 1 record omitted from the original data due to missing values, please check if they should be imputed prior to model fitting.
#> Warning: There is 1 record omitted from the original data due to missing values, please check if they should be imputed prior to model fitting.

```
