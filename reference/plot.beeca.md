# Plot method for beeca objects

Creates visualizations for beeca analysis results. Currently supports
forest plots showing treatment effect estimates with confidence
intervals. Additional plot types will be added in future versions.

## Usage

``` r
# S3 method for class 'beeca'
plot(x, type = c("forest"), ...)
```

## Arguments

- x:

  a beeca object (from
  [get_marginal_effect](https://openpharma.github.io/beeca/reference/get_marginal_effect.md))

- type:

  character string specifying the plot type. Currently only "forest" is
  supported.

- ...:

  additional arguments passed to the specific plot function

## Value

a ggplot object

## See also

[`get_marginal_effect()`](https://openpharma.github.io/beeca/reference/get_marginal_effect.md)
for the main analysis function

[`beeca_fit()`](https://openpharma.github.io/beeca/reference/beeca_fit.md)
for streamlined analysis pipeline

[`plot_forest()`](https://openpharma.github.io/beeca/reference/plot_forest.md)
for forest plot details

[`print.beeca()`](https://openpharma.github.io/beeca/reference/print.beeca.md)
for concise output

[`summary.beeca()`](https://openpharma.github.io/beeca/reference/summary.beeca.md)
for detailed summary output

[`tidy.beeca()`](https://openpharma.github.io/beeca/reference/tidy.beeca.md)
for tidied parameter estimates

[`as_gt()`](https://openpharma.github.io/beeca/reference/as_gt.md) for
publication-ready tables

## Examples

``` r
if (requireNamespace("ggplot2", quietly = TRUE)) {
  trial01$trtp <- factor(trial01$trtp)
  fit1 <- glm(aval ~ trtp + bl_cov, family = "binomial", data = trial01) |>
    get_marginal_effect(trt = "trtp", method = "Ye", contrast = "diff", reference = "0")

  # Forest plot (default)
  plot(fit1)

  # Explicit type specification
  plot(fit1, type = "forest")

  # Customize
  plot(fit1, conf.level = 0.90, title = "My Treatment Effect")
}
#> Warning: There is 1 record omitted from the original data due to missing values, please check if they should be imputed prior to model fitting.

```
