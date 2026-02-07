# Summary method for beeca objects

Provides a comprehensive summary of a beeca analysis, including marginal
risks for each treatment arm, treatment effect estimates with confidence
intervals, and key model information.

## Usage

``` r
# S3 method for class 'beeca'
summary(object, conf.level = 0.95, digits = 4, ...)
```

## Arguments

- object:

  a beeca object (from
  [get_marginal_effect](https://openpharma.github.io/beeca/reference/get_marginal_effect.md))

- conf.level:

  confidence level for confidence intervals. Default is 0.95.

- digits:

  integer, number of decimal places for rounding. Default is 4.

- ...:

  additional arguments (not currently used)

## Value

Invisibly returns the input object

## See also

[`get_marginal_effect()`](https://openpharma.github.io/beeca/reference/get_marginal_effect.md)
for the main analysis function

[`beeca_fit()`](https://openpharma.github.io/beeca/reference/beeca_fit.md)
for streamlined analysis pipeline

[`print.beeca()`](https://openpharma.github.io/beeca/reference/print.beeca.md)
for concise output

[`tidy.beeca()`](https://openpharma.github.io/beeca/reference/tidy.beeca.md)
for broom-compatible output

[`plot.beeca()`](https://openpharma.github.io/beeca/reference/plot.beeca.md)
for visualizations

[`augment.beeca()`](https://openpharma.github.io/beeca/reference/augment.beeca.md)
for augmented predictions

[`as_gt()`](https://openpharma.github.io/beeca/reference/as_gt.md) for
publication-ready tables

## Examples

``` r
trial01$trtp <- factor(trial01$trtp)
fit1 <- glm(aval ~ trtp + bl_cov, family = "binomial", data = trial01) |>
  get_marginal_effect(trt = "trtp", method = "Ye", contrast = "diff", reference = "0")
#> Warning: There is 1 record omitted from the original data due to missing values, please check if they should be imputed prior to model fitting.

# Detailed summary
summary(fit1)
#> 
#> Covariate-Adjusted Marginal Treatment Effect Analysis
#> ============================================================
#> 
#> Model Information:
#> ------------------------------------------------------------
#>   Working model:      Logistic regression with covariate adjustment
#>   Variance estimator: Ye
#>   Contrast type:      diff
#>   Sample size:        267
#>   Outcome variable:   aval
#> 
#> Marginal Risks (g-computation):
#> ------------------------------------------------------------
#>  Treatment Risk   SE     95% CI          
#>  0         0.4875 0.0435 (0.4022, 0.5728)
#>  1         0.4191 0.0427 (0.3354, 0.5028)
#> 
#> Treatment Effect Estimates:
#> ------------------------------------------------------------
#>  Comparison Estimate SE     Z value 95% CI            P value
#>  diff: 1-0  -0.0684  0.0609 -1.1232 (-0.1878, 0.0510) 0.26   
#> 
#> ------------------------------------------------------------
#> Note: Standard errors and tests based on robust variance estimation
#> Use tidy() for data frame output or plot() for visualizations

# With 90% confidence intervals
summary(fit1, conf.level = 0.90)
#> 
#> Covariate-Adjusted Marginal Treatment Effect Analysis
#> ============================================================
#> 
#> Model Information:
#> ------------------------------------------------------------
#>   Working model:      Logistic regression with covariate adjustment
#>   Variance estimator: Ye
#>   Contrast type:      diff
#>   Sample size:        267
#>   Outcome variable:   aval
#> 
#> Marginal Risks (g-computation):
#> ------------------------------------------------------------
#>  Treatment Risk   SE     90% CI          
#>  0         0.4875 0.0435 (0.4159, 0.5591)
#>  1         0.4191 0.0427 (0.3489, 0.4893)
#> 
#> Treatment Effect Estimates:
#> ------------------------------------------------------------
#>  Comparison Estimate SE     Z value 90% CI            P value
#>  diff: 1-0  -0.0684  0.0609 -1.1232 (-0.1686, 0.0318) 0.26   
#> 
#> ------------------------------------------------------------
#> Note: Standard errors and tests based on robust variance estimation
#> Use tidy() for data frame output or plot() for visualizations
```
