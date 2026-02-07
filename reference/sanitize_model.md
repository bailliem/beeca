# (internal) Sanitize functions to check model and data within GLM model object

Performs checks on a GLM model object to ensure it meets specific
criteria required for further analysis using other functions from the
`beeca` package.

This includes verifying the model's family, link function, data
completeness and mode convergence.

Currently it supports models with a binomial family and canonical logit
link.

## Usage

``` r
sanitize_model(model, ...)
```

## Arguments

- model:

  a model object, currently only [glm](https://rdrr.io/r/stats/glm.html)
  with binomial family canonical link is supported.

- ...:

  arguments passed to or from other methods.

## Value

if model is non-compliant will throw warnings or errors.
