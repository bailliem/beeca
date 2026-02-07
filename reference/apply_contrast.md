# Apply contrast to calculate marginal estimate of treatment effect and corresponding standard error

Calculates the marginal estimate of treatment effect and its
corresponding standard error based on a fitted GLM object using
specified contrast (summary measure) methods

## Usage

``` r
apply_contrast(
  object,
  contrast = c("diff", "rr", "or", "logrr", "logor"),
  reference
)
```

## Arguments

- object:

  a fitted [`glm`](https://rdrr.io/r/stats/glm.html) object augmented
  with `counterfactual.predictions`, `counterfactual.means` and
  `robust_varcov`.

- contrast:

  a string specifying the type of contrast to apply. Accepted values are
  "diff" (risk difference), "rr" (risk ratio), "or" (odds ratio),
  "logrr" (log risk ratio), "logor" (log odds ratio). Note:
  log-transformed ratios (logrr and logor) work better compared to rr
  and or when computing confidence intervals using normal approximation.
  The choice of contrast affects how treatment effects are calculated
  and interpreted. Default is `diff`.

- reference:

  a string or list of strings indicating which treatment group(s) to use
  as reference level for pairwise comparisons. Accepted values must be a
  subset of the levels in the treatment variable. Default to the first
  n-1 treatment levels used in the `glm` object.

  This parameter influences the calculation of treatment effects
  relative to the chosen reference group.

## Value

An updated `glm` object with two additional components appended:
`marginal_est` (marginal estimate of the treatment effect) and
`marginal_se` (standard error of the marginal estimate). These appended
component provide crucial information for interpreting the treatment
effect using the specified contrast method.

## Details

The `apply_constrast()` functions computes the summary measure between
two arms based on the estimated marginal effect and its
variance-covariance matrix using the Delta method.

Note: Ensure that the `glm` object has been adequately prepared with
[`average_predictions()`](https://openpharma.github.io/beeca/reference/average_predictions.md)
and
[`estimate_varcov()`](https://openpharma.github.io/beeca/reference/estimate_varcov.md)
before applying `apply_contrast()`. Failure to do so may result in
errors indicating missing components.

## See also

[`predict_counterfactuals()`](https://openpharma.github.io/beeca/reference/predict_counterfactuals.md)
for generating counterfactual predictions

[`average_predictions()`](https://openpharma.github.io/beeca/reference/average_predictions.md)
for averaging counterfactual predictions

[`estimate_varcov()`](https://openpharma.github.io/beeca/reference/estimate_varcov.md)
for robust variance estimation

[`get_marginal_effect()`](https://openpharma.github.io/beeca/reference/get_marginal_effect.md)
for estimating marginal effects directly from an original
[`glm`](https://rdrr.io/r/stats/glm.html) object

[`beeca_fit()`](https://openpharma.github.io/beeca/reference/beeca_fit.md)
for streamlined analysis pipeline

## Examples

``` r
trial01$trtp <- factor(trial01$trtp)
fit1 <- glm(aval ~ trtp + bl_cov, family = "binomial", data = trial01) |>
  predict_counterfactuals(trt = "trtp") |>
  average_predictions() |>
  estimate_varcov(method = "Ye") |>
  apply_contrast("diff", reference = "0")
#> Warning: There is 1 record omitted from the original data due to missing values, please check if they should be imputed prior to model fitting.

# Assuming `trial01` is a dataset with treatment (`trtp`)
# and baseline covariate (`bl_cov`)
trial01$trtp <- factor(trial01$trtp)
fit1 <- glm(aval ~ trtp + bl_cov, family = "binomial", data = trial01)

# Preprocess fit1 as required by apply_contrast
fit2 <- fit1 |>
  predict_counterfactuals(trt = "trtp") |>
  average_predictions() |>
  estimate_varcov(method = "Ye")
#> Warning: There is 1 record omitted from the original data due to missing values, please check if they should be imputed prior to model fitting.

# Apply contrast to calculate marginal estimates
fit3 <- apply_contrast(fit2, contrast = "diff", reference = "0")

fit3$marginal_est
#>   diff: 1-0 
#> -0.06836399 
#> attr(,"reference")
#> [1] "0"
#> attr(,"contrast")
#> [1] "diff: 1-0"
fit3$marginal_se
#> diff: 1-0 
#> 0.0608836 
#> attr(,"reference")
#> [1] "0"
#> attr(,"contrast")
#> [1] "diff: 1-0"
#> attr(,"type")
#> [1] "Ye"
```
