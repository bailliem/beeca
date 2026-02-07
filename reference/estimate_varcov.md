# Estimate variance-covariance matrix for marginal estimand based on GLM model

Main variance estimation function. Estimates the variance-covariance
matrix of a marginal estimand for a generalized linear model (GLM)
object using specified methods. This function supports both Ge's and
Ye's methods for variance estimation, accommodating different estimand
specifications.

## Usage

``` r
estimate_varcov(
  object,
  strata = NULL,
  method = c("Ge", "Ye"),
  type = c("HC0", "model-based", "HC3", "HC", "HC1", "HC2", "HC4", "HC4m", "HC5"),
  mod = FALSE
)
```

## Arguments

- object:

  a fitted [`glm`](https://rdrr.io/r/stats/glm.html) object augmented
  with `counterfactual.predictions`, `counterfactual.predictions` and
  `counterfactual.means`

- strata:

  an optional string or vector of strings specifying the names of
  stratification variables. Relevant only for Ye's method and used to
  adjust the variance-covariance estimation for stratification. If
  provided, each specified variable must be present in the model.

- method:

  a string indicating the chosen method for variance estimation.
  Supported methods are `Ge` and `Ye`. The default method is `Ge` based
  on Ge et al (2011) which is suitable for the variance estimation of
  conditional average treatment effect. The method `Ye` is based on Ye
  et al (2023) and is suitable for the variance estimation of population
  average treatment effect. For more details, see Magirr et al. (2025)
  [doi:10.1002/pst.70021](https://doi.org/10.1002/pst.70021) .

- type:

  a string indicating the type of variance estimator to use (only
  applicable for Ge's method). Supported types include HC0 (default),
  model-based, HC3, HC, HC1, HC2, HC4, HC4m, and HC5. See
  [vcovHC](https://sandwich.R-Forge.R-project.org/reference/vcovHC.html)
  for heteroscedasticity-consistent estimators. This parameter allows
  for flexibility in handling heteroscedasticity and model specification
  errors.

- mod:

  For Ye's method, the implementation of open-source RobinCar package
  has an additional variance decomposition step when estimating the
  robust variance, which then utilizes different counterfactual outcomes
  than the original reference. Set `mod = TRUE` to use exactly the
  implementation method described in Ye et al (2022), default to `FALSE`
  to use the modified implementation in RobinCar and Bannick et
  al (2023) which improves stability.

## Value

an updated `glm` object appended with an additional component
`robust_varcov`, which is the estimated variance-covariance matrix of
the marginal effect. The matrix format and estimation method are
indicated in the matrix attributes.

## Details

The `estimate_varcov` function facilitates robust variance estimation
techniques for GLM models, particularly useful in clinical trial
analysis and other fields requiring robust statistical inference. It
allows researchers to account for complex study designs, including
stratification and different treatment contrasts, by providing a
flexible interface for variance-covariance estimation.

Note: Ensure that the `glm` object has been adequately prepared with
[`predict_counterfactuals`](https://openpharma.github.io/beeca/reference/predict_counterfactuals.md)
and
[`average_predictions`](https://openpharma.github.io/beeca/reference/average_predictions.md)
before applying `estimate_varcov()`. Failure to do so may result in
errors indicating missing components.

## References

Ye, T., Shao, J., Yi, Y., and Zhao, Q. (2023). "Robust Variance
Estimation for Covariate-Adjusted Unconditional Treatment Effect in
Randomized Clinical Trials with Binary Outcomes." *Statistical Theory
and Related Fields* 7(2): 159-163.
<https://doi.org/10.1080/24754269.2023.2205802>

Ge, M., Durham, L. K., Meyer, R. D., Xie, W., and Flournoy, N. (2011).
"Covariate-Adjusted Difference in Proportions from Clinical Trials Using
Logistic Regression and Weighted Risk Differences." *Drug Information
Journal* 45(4): 481-493. <https://doi.org/10.1177/009286151104500409>

Bannick, M. S., Jun, Y., Josey, K., Weinberg, C. R., and Karlson, E. W.
(2023). "A General Form of Covariate Adjustment in Randomized Clinical
Trials." arXiv preprint arXiv:2306.10213.
<https://arxiv.org/abs/2306.10213>

## See also

[`predict_counterfactuals()`](https://openpharma.github.io/beeca/reference/predict_counterfactuals.md)
for generating counterfactual predictions

[`average_predictions()`](https://openpharma.github.io/beeca/reference/average_predictions.md)
for averaging counterfactual predictions

[`apply_contrast()`](https://openpharma.github.io/beeca/reference/apply_contrast.md)
for computing a summary measure

[`get_marginal_effect()`](https://openpharma.github.io/beeca/reference/get_marginal_effect.md)
for estimating marginal effects directly from an original
[`glm`](https://rdrr.io/r/stats/glm.html) object

[`beeca_fit()`](https://openpharma.github.io/beeca/reference/beeca_fit.md)
for streamlined analysis pipeline

## Examples

``` r
# Example usage with a binary outcome GLM model
trial01$trtp <- factor(trial01$trtp)
fit1 <- glm(aval ~ trtp + bl_cov, family = "binomial", data = trial01)

#' # Preprocess fit1 as required by estimate_varcov
fit2 <- fit1 |>
  predict_counterfactuals(trt = "trtp") |>
  average_predictions()
#> Warning: There is 1 record omitted from the original data due to missing values, please check if they should be imputed prior to model fitting.

# Estimate variance-covariance using Ge's method
fit3_ge <- estimate_varcov(fit2, method = "Ge")
print(fit3_ge$robust_varcov)
#>               0             1
#> 0  1.878839e-03 -2.759138e-06
#> 1 -2.759138e-06  1.808457e-03
#> attr(,"type")
#> [1] "Ge - HC0"


# Estimate variance-covariance using Ye's method with stratification
fit4 <- glm(aval ~ trtp + bl_cov_c, family = "binomial", data = trial01) |>
  predict_counterfactuals(trt = "trtp") |>
  average_predictions()
#> Warning: There are 2 records omitted from the original data due to missing values, please check if they should be imputed prior to model fitting.
fit4_ye <- estimate_varcov(fit4, method = "Ye", strata = "bl_cov_c")
print(fit4_ye$robust_varcov)
#>               0             1
#> 0  1.890549e-03 -3.739455e-07
#> 1 -3.739455e-07  1.846667e-03
#> attr(,"type")
#> [1] "Ye"
```
