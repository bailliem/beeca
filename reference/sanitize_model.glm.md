# (internal) Sanitize a glm model

(internal) Sanitize a glm model

## Usage

``` r
# S3 method for class 'glm'
sanitize_model(model, trt, ...)
```

## Arguments

- model:

  a [glm](https://rdrr.io/r/stats/glm.html) with binomial family
  canonical link.

- trt:

  the name of the treatment variable on the right-hand side of the
  formula in a [glm](https://rdrr.io/r/stats/glm.html).

- ...:

  ignored.

## Value

if model is non-compliant will throw warnings or errors.

## Examples

``` r
trial01$trtp <- factor(trial01$trtp)
fit1 <- glm(aval ~ trtp + bl_cov, family = "binomial", data = trial01)
fit1 <- sanitize_model(fit1, "trtp")
#> Warning: There is 1 record omitted from the original data due to missing values, please check if they should be imputed prior to model fitting.
```
