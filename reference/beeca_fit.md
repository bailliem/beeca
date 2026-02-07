# Quick beeca analysis pipeline

A convenience function that streamlines the workflow for conducting a
covariate-adjusted marginal treatment effect analysis. This function
combines model fitting and marginal effect estimation in a single call,
with automatic data preprocessing and informative messages.

## Usage

``` r
beeca_fit(
  data,
  outcome,
  treatment,
  covariates = NULL,
  method = c("Ye", "Ge"),
  contrast = c("diff", "rr", "or", "logrr", "logor"),
  reference = NULL,
  strata = NULL,
  family = binomial(),
  verbose = TRUE,
  ...
)
```

## Arguments

- data:

  a data frame containing the analysis variables

- outcome:

  character string specifying the outcome variable name. Must be coded
  as 0/1 or a factor with two levels.

- treatment:

  character string specifying the treatment variable name. Will be
  converted to a factor if not already one.

- covariates:

  optional character vector specifying covariate names for adjustment.
  If NULL, an unadjusted analysis is performed.

- method:

  variance estimation method. One of "Ye" (default) or "Ge". See
  [get_marginal_effect](https://openpharma.github.io/beeca/reference/get_marginal_effect.md)
  for details.

- contrast:

  type of summary measure. One of "diff" (risk difference, default),
  "rr" (risk ratio), "or" (odds ratio), "logrr" (log risk ratio), or
  "logor" (log odds ratio).

- reference:

  optional character string or vector specifying reference treatment
  level(s) for comparisons. If NULL, defaults to first level.

- strata:

  optional character vector specifying stratification variables (only
  used with method = "Ye").

- family:

  a GLM family. Default is binomial() for logistic regression.

- verbose:

  logical indicating whether to print progress messages. Default is
  TRUE.

- ...:

  additional arguments passed to
  [get_marginal_effect](https://openpharma.github.io/beeca/reference/get_marginal_effect.md)

## Value

a beeca object (augmented glm object) with marginal effect estimates.
See
[get_marginal_effect](https://openpharma.github.io/beeca/reference/get_marginal_effect.md)
for details on the returned object.

## Details

This function provides a simplified interface to the beeca workflow by:

- Automatically converting the treatment variable to a factor if needed

- Building the model formula from variable names

- Fitting the logistic regression model

- Computing marginal effects with robust variance estimation

- Providing informative progress messages

For more control over the analysis, use
[`glm()`](https://rdrr.io/r/stats/glm.html) followed by
[`get_marginal_effect()`](https://openpharma.github.io/beeca/reference/get_marginal_effect.md)
directly.

## See also

[`get_marginal_effect()`](https://openpharma.github.io/beeca/reference/get_marginal_effect.md)
for the underlying estimation function

[`predict_counterfactuals()`](https://openpharma.github.io/beeca/reference/predict_counterfactuals.md)
for counterfactual prediction step

[`average_predictions()`](https://openpharma.github.io/beeca/reference/average_predictions.md)
for averaging step

[`estimate_varcov()`](https://openpharma.github.io/beeca/reference/estimate_varcov.md)
for variance estimation step

[`apply_contrast()`](https://openpharma.github.io/beeca/reference/apply_contrast.md)
for contrast computation step

[`tidy.beeca()`](https://openpharma.github.io/beeca/reference/tidy.beeca.md)
for extracting results

[`summary.beeca()`](https://openpharma.github.io/beeca/reference/summary.beeca.md)
for detailed output

[`print.beeca()`](https://openpharma.github.io/beeca/reference/print.beeca.md)
for concise output

[`plot.beeca()`](https://openpharma.github.io/beeca/reference/plot.beeca.md)
and
[`plot_forest()`](https://openpharma.github.io/beeca/reference/plot_forest.md)
for visualizations

[`augment.beeca()`](https://openpharma.github.io/beeca/reference/augment.beeca.md)
for augmented predictions

[`as_gt()`](https://openpharma.github.io/beeca/reference/as_gt.md) for
publication-ready tables

## Examples

``` r
# Simple two-arm analysis
fit <- beeca_fit(
  data = trial01,
  outcome = "aval",
  treatment = "trtp",
  covariates = "bl_cov",
  method = "Ye",
  contrast = "diff",
  verbose = FALSE
)
#> Warning: There is 1 record omitted from the original data due to missing values, please check if they should be imputed prior to model fitting.
#> Warning: No reference argument was provided, using {0} as the reference level(s)

# View results
print(fit)
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
summary(fit)
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
