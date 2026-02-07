# Format p-value for clinical trial tables

Formats p-values according to common clinical trial reporting
conventions. Values less than 0.001 are displayed as "\<0.001",
otherwise rounded to 3 decimal places.

## Usage

``` r
format_pvalue(p, digits = 3, small_threshold = 0.001)
```

## Arguments

- p:

  numeric p-value(s) to format

- digits:

  integer, number of decimal places. Default is 3.

- small_threshold:

  numeric, values below this threshold are displayed as "\<threshold".
  Default is 0.001.

## Value

character vector of formatted p-values

## Examples

``` r
format_pvalue(0.0001)
#> [1] "<0.001"
format_pvalue(c(0.05, 0.001, 0.0001))
#> [1] "0.050"  "0.001"  "<0.001"
```
