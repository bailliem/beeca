# (internal) Sanitize a geeglm model

(internal) Sanitize a geeglm model

## Usage

``` r
# S3 method for class 'geeglm'
sanitize_model(model, trt, ...)
```

## Arguments

- model:

  a geeglm object from
  [geeglm](https://rdrr.io/pkg/geepack/man/geeglm.html) with binomial
  family canonical link.

- trt:

  the name of the treatment variable on the right-hand side of the
  formula.

- ...:

  ignored.

## Value

if model is non-compliant will throw warnings or errors.
