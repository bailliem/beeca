# Create a summary statistics table for beeca analysis

Creates a summary table showing descriptive statistics and treatment
effects from a beeca analysis. This function provides a simpler
alternative to
[`as_gt()`](https://openpharma.github.io/beeca/reference/as_gt.md) that
returns a data frame suitable for further customization.

## Usage

``` r
beeca_summary_table(x, conf.level = 0.95, risk_percent = TRUE)
```

## Arguments

- x:

  a beeca object

- conf.level:

  numeric, confidence level for intervals. Default is 0.95.

- risk_percent:

  logical, if TRUE displays risks as percentages. Default is TRUE.

## Value

a data frame with summary statistics

## Examples

``` r
trial01$trtp <- factor(trial01$trtp)
fit <- glm(aval ~ trtp + bl_cov, family = "binomial", data = trial01) |>
  get_marginal_effect(trt = "trtp", method = "Ye", contrast = "diff", reference = "0")
#> Warning: There is 1 record omitted from the original data due to missing values, please check if they should be imputed prior to model fitting.

beeca_summary_table(fit)
#> $arm_statistics
#> # A tibble: 2 × 8
#>   treatment     N n_responders observed_rate marginal_risk marginal_risk_se
#>   <chr>     <dbl>        <dbl>         <dbl>         <dbl>            <dbl>
#> 1 0           133           65          48.9          48.7             4.35
#> 2 1           134           56          41.8          41.9             4.27
#> # ℹ 2 more variables: marginal_risk_ci_low <dbl>, marginal_risk_ci_high <dbl>
#> 
#> $treatment_effects
#> # A tibble: 1 × 7
#>   comparison estimate std_error ci_low ci_high z_statistic p_value
#>   <chr>         <dbl>     <dbl>  <dbl>   <dbl>       <dbl>   <dbl>
#> 1 diff: 1-0     -6.84      6.09  -18.8    5.10       -1.12   0.261
#> 
#> $metadata
#> $metadata$conf_level
#> [1] 0.95
#> 
#> $metadata$contrast_type
#> [1] "diff"
#> 
#> $metadata$variance_method
#> [1] "Ye"
#> 
#> $metadata$reference
#> [1] "0"
#> 
#> $metadata$n_total
#> [1] 267
#> 
#> $metadata$risk_percent
#> [1] TRUE
#> 
#> 
```
