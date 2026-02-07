# Average over counterfactual predictions

`average_predictions()` averages counterfactual predictions stored
within a `glm` object. This is pivotal for estimating treatment
contrasts and associated variance estimates using g-computation. The
function assumes predictions are generated via
[`predict_counterfactuals()`](https://openpharma.github.io/beeca/reference/predict_counterfactuals.md).

## Usage

``` r
average_predictions(object)
```

## Arguments

- object:

  a fitted [`glm`](https://rdrr.io/r/stats/glm.html) object augmented
  with counterfactual predictions named: `counterfactual.predictions`

## Value

an updated `glm` object appended with an additional component
`counterfactual.means`.

## Details

The `average_predictions()` function calculates the average over the
counterfactual predictions which can then be used to estimate a
treatment contrast and associated variance estimate.

The function appends a `glm` object with the averaged counterfactual
predictions.

Note: Ensure that the `glm` object has been adequately prepared with
[`predict_counterfactuals()`](https://openpharma.github.io/beeca/reference/predict_counterfactuals.md)
before applying `average_predictions()`. Failure to do so may result in
errors indicating missing components.

## See also

[`predict_counterfactuals()`](https://openpharma.github.io/beeca/reference/predict_counterfactuals.md)
for generating counterfactual predictions.

[`estimate_varcov()`](https://openpharma.github.io/beeca/reference/estimate_varcov.md)
for estimating the variance-covariance matrix of marginal effects

[`get_marginal_effect()`](https://openpharma.github.io/beeca/reference/get_marginal_effect.md)
for estimating marginal effects directly from an original
[`glm`](https://rdrr.io/r/stats/glm.html) object

## Examples

``` r
# Use the trial01 dataset
data(trial01)

# ensure the treatment indicator is a factor
trial01$trtp <- factor(trial01$trtp)

# fit glm model for trial data
fit1 <- glm(aval ~ trtp + bl_cov, family = "binomial", data = trial01)

# Preprocess fit1 as required by average_predictions
fit2 <- fit1 |>
  predict_counterfactuals(trt = "trtp")
#> Warning: There is 1 record omitted from the original data due to missing values, please check if they should be imputed prior to model fitting.

# average over the counterfactual predictions
fit3 <- average_predictions(fit2)

# display the average predictions
fit3$counterfactual.means
#>         0         1 
#> 0.4874723 0.4191083 
```
