# Print method for beeca objects

Provides a concise summary of a beeca analysis, showing the treatment
effect estimate, standard error, and p-value. For more detailed output,
use [`summary()`](https://rdrr.io/r/base/summary.html).

## Usage

``` r
# S3 method for class 'beeca'
print(x, digits = 4, ...)
```

## Arguments

- x:

  a beeca object (from
  [get_marginal_effect](https://openpharma.github.io/beeca/reference/get_marginal_effect.md))

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

[`summary.beeca()`](https://openpharma.github.io/beeca/reference/summary.beeca.md)
for detailed output

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

# Concise output
print(fit1)
#> beeca: Covariate-Adjusted Marginal Treatment Effect
#> =======================================================
#> 
#> Contrast:  diff: 1-0
#> Estimate:  -0.0684 (SE = 0.0609)
#> Z-value:   -1.1229
#> P-value:   0.2615
#> 
#> Use summary() for detailed results
#> Use tidy() for broom-compatible output
#> Use plot() for visualizations

# More detail
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
```
