# Estimate marginal treatment effects using a GLM working model

Estimates the marginal treatment effect from a logistic regression
working model using a specified choice of variance estimator and
contrast.

## Usage

``` r
get_marginal_effect(
  object,
  trt,
  strata = NULL,
  method = "Ge",
  type = "HC0",
  contrast = "diff",
  reference,
  mod = FALSE
)
```

## Arguments

- object:

  a fitted [glm](https://rdrr.io/r/stats/glm.html) object.

- trt:

  a string specifying the name of the treatment variable in the model
  formula. It must be one of the linear predictor variables used in
  fitting the `object`.

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
  for heteroscedasticity-consistent estimators.

- contrast:

  a string indicating choice of contrast. Defaults to 'diff' for a risk
  difference. See
  [apply_contrast](https://openpharma.github.io/beeca/reference/apply_contrast.md).

- reference:

  a string or list of strings indicating which treatment group(s) to use
  as reference level for pairwise comparisons. Accepted values must be a
  subset of the levels in the treatment variable. Default to the first
  n-1 treatment levels used in the `glm` object. This parameter
  influences the calculation of treatment effects relative to the chosen
  reference group.

- mod:

  for Ye's method, the implementation of open-source RobinCar package
  has an additional variance decomposition step when estimating the
  robust variance, which then utilizes different counterfactual outcomes
  than the original reference. Set `mod = TRUE` to use exactly the
  implementation method described in Ye et al (2022), default to `FALSE`
  to use the modified implementation in RobinCar and Bannick et
  al (2023) which improves stability.

## Value

an updated `glm` object appended with marginal estimate components:
counterfactual.predictions (see
[predict_counterfactuals](https://openpharma.github.io/beeca/reference/predict_counterfactuals.md)),
counterfactual.means (see
[average_predictions](https://openpharma.github.io/beeca/reference/average_predictions.md)),
robust_varcov (see
[estimate_varcov](https://openpharma.github.io/beeca/reference/estimate_varcov.md)),
marginal_est, marginal_se (see
[apply_contrast](https://openpharma.github.io/beeca/reference/apply_contrast.md))
and marginal_results. A summary is shown below

|                            |                                                                                                                                                                                                                                                                                                            |
|----------------------------|------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| counterfactual.predictions | Counterfactual predictions based on the working model. For each subject in the input glm data, the potential outcomes are obtained by assigning subjects to each of the possible treatment variable levels. Each prediction is associated with a descriptive label explaining the counterfactual scenario. |
| counterfactual.means       | Average of the counterfactual predictions for each level of the treatment variable.                                                                                                                                                                                                                        |
| robust_varcov              | Variance-covariance matrix of the marginal effect estimate for each level of treatment variable, with estimation method indicated in the attributes.                                                                                                                                                       |
| marginal_est               | Marginal treatment effect estimate for a given contrast.                                                                                                                                                                                                                                                   |
| marginal_se                | Standard error estimate of the marginal treatment effect estimate.                                                                                                                                                                                                                                         |
| marginal_results           | Analysis results data (ARD) containing a summary of the analysis for subsequent reporting.                                                                                                                                                                                                                 |

## Details

The `get_marginal_effect` function is a wrapper that facilitates
advanced variance estimation techniques for GLM models with covariate
adjustment targeting a population average treatment effect. It is
particularly useful in clinical trial analysis and other fields
requiring robust statistical inference. It allows researchers to account
for complex study designs, including stratification and treatment
contrasts, by providing a flexible interface for variance-covariance
estimation.

## See also

[`predict_counterfactuals()`](https://openpharma.github.io/beeca/reference/predict_counterfactuals.md)
for generating counterfactual predictions

[`average_predictions()`](https://openpharma.github.io/beeca/reference/average_predictions.md)
for averaging counterfactual predictions

[`estimate_varcov()`](https://openpharma.github.io/beeca/reference/estimate_varcov.md)
for robust variance estimation

[`apply_contrast()`](https://openpharma.github.io/beeca/reference/apply_contrast.md)
for computing treatment contrasts

[`beeca_fit()`](https://openpharma.github.io/beeca/reference/beeca_fit.md)
for streamlined convenience wrapper

[`tidy.beeca()`](https://openpharma.github.io/beeca/reference/tidy.beeca.md)
for tidied parameter estimates

[`summary.beeca()`](https://openpharma.github.io/beeca/reference/summary.beeca.md)
for detailed summary output

[`print.beeca()`](https://openpharma.github.io/beeca/reference/print.beeca.md)
for concise output

[`plot.beeca()`](https://openpharma.github.io/beeca/reference/plot.beeca.md)
and
[`plot_forest()`](https://openpharma.github.io/beeca/reference/plot_forest.md)
for visualizations

[`augment.beeca()`](https://openpharma.github.io/beeca/reference/augment.beeca.md)
for augmented data with predictions

[`as_gt()`](https://openpharma.github.io/beeca/reference/as_gt.md) for
publication-ready tables

[`beeca_to_cards_ard()`](https://openpharma.github.io/beeca/reference/beeca_to_cards_ard.md)
for cards ARD integration

## Examples

``` r
trial01$trtp <- factor(trial01$trtp)
fit1 <- glm(aval ~ trtp + bl_cov, family = "binomial", data = trial01) |>
  get_marginal_effect(trt = "trtp", method = "Ye", contrast = "diff", reference = "0")
#> Warning: There is 1 record omitted from the original data due to missing values, please check if they should be imputed prior to model fitting.
fit1$marginal_results
#> # A tibble: 12 × 8
#>    TRTVAR TRTVAL    PARAM ANALTYP1    STAT     STATVAL ANALMETH      ANALDESC   
#>    <chr>  <chr>     <chr> <chr>       <chr>      <dbl> <chr>         <chr>      
#>  1 trtp   0         aval  DESCRIPTIVE N       133      count         Computed u…
#>  2 trtp   0         aval  DESCRIPTIVE n        65      count         Computed u…
#>  3 trtp   0         aval  DESCRIPTIVE %        48.9    percentage    Computed u…
#>  4 trtp   0         aval  INFERENTIAL risk      0.487  g-computation Computed u…
#>  5 trtp   0         aval  INFERENTIAL risk_se   0.0435 Ye            Computed u…
#>  6 trtp   1         aval  DESCRIPTIVE N       134      count         Computed u…
#>  7 trtp   1         aval  DESCRIPTIVE n        56      count         Computed u…
#>  8 trtp   1         aval  DESCRIPTIVE %        41.8    percentage    Computed u…
#>  9 trtp   1         aval  INFERENTIAL risk      0.419  g-computation Computed u…
#> 10 trtp   1         aval  INFERENTIAL risk_se   0.0427 Ye            Computed u…
#> 11 trtp   diff: 1-0 aval  INFERENTIAL diff     -0.0684 g-computation Computed u…
#> 12 trtp   diff: 1-0 aval  INFERENTIAL diff_se   0.0609 Ye            Computed u…
```
