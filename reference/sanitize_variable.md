# (internal) Sanitize function to check model and data

(internal) Sanitize function to check model and data

## Usage

``` r
sanitize_variable(model, trt)
```

## Arguments

- model:

  an [glm](https://rdrr.io/r/stats/glm.html) model object.

- trt:

  the name of the treatment variable on the right-hand side of the glm
  formula.

## Value

if model and variable are non-compliant, will throw warnings or error.
