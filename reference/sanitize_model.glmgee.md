# (internal) Sanitize a glmgee model

(internal) Sanitize a glmgee model

## Usage

``` r
# S3 method for class 'glmgee'
sanitize_model(model, trt, ...)
```

## Arguments

- model:

  a glmgee object from
  [glmgee](https://rdrr.io/pkg/glmtoolbox/man/glmgee.html) with binomial
  family canonical link.

- trt:

  the name of the treatment variable on the right-hand side of the
  formula.

- ...:

  ignored.

## Value

if model is non-compliant will throw warnings or errors.
