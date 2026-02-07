# Convert beeca marginal_results to cards ARD format

Converts the `marginal_results` component from a beeca analysis to the
ARD (Analysis Results Data) format used by the cards package. This
enables integration with the cards/cardx ecosystem for comprehensive
reporting and quality control workflows.

## Usage

``` r
beeca_to_cards_ard(marginal_results)
```

## Arguments

- marginal_results:

  A beeca `marginal_results` tibble/data frame containing the output
  from `get_marginal_effect()$marginal_results`.

## Value

A cards ARD object (tibble with class 'card') containing:

- `group1`: Treatment variable name (character)

- `group1_level`: Treatment level (list-column, numeric if possible,
  else character)

- `variable`: Outcome variable name (character)

- `variable_level`: Specific level of variable (character, NA for beeca)

- `stat_name`, `stat_label`: Statistic identifier and human-readable
  label

- `stat`: The calculated value (list-column)

- `context`: Analysis context (combining ANALTYP1 and ANALMETH)

- `fmt_fn`, `warning`, `error`: Cards-specific metadata (list-columns)

## Details

The function maps beeca's CDISC-inspired ARD structure to the cards
package format:

|                         |                |                                |
|-------------------------|----------------|--------------------------------|
| beeca                   | cards          | Notes                          |
| `TRTVAR`                | `group1`       | Treatment variable name        |
| `TRTVAL`                | `group1_level` | Treatment level                |
| `PARAM`                 | `variable`     | Outcome variable               |
| `STAT`                  | `stat_name`    | Statistic identifier           |
| `STATVAL`               | `stat`         | Value (numeric vs list-column) |
| `ANALTYP1` + `ANALMETH` | `context`      | Analysis context               |

Original beeca metadata is preserved in the `beeca_description`
attribute.

## Package Requirements

This function requires the `cards` package to be installed. It is listed
as a suggested dependency and will provide an informative error if not
available.

## See also

[`get_marginal_effect()`](https://openpharma.github.io/beeca/reference/get_marginal_effect.md)
for creating the input `marginal_results`

[`beeca_fit()`](https://openpharma.github.io/beeca/reference/beeca_fit.md)
for streamlined analysis pipeline

[`as_gt()`](https://openpharma.github.io/beeca/reference/as_gt.md) for
publication-ready tables

[`tidy.beeca()`](https://openpharma.github.io/beeca/reference/tidy.beeca.md)
for broom-compatible output

[`vignette("ard-cards-integration")`](https://openpharma.github.io/beeca/articles/ard-cards-integration.md)
for detailed integration examples

## Examples

``` r
if (requireNamespace("cards", quietly = TRUE)) {
  # Fit model and get beeca results
  trial01$trtp <- factor(trial01$trtp)
  fit1 <- glm(aval ~ trtp + bl_cov, family = "binomial", data = trial01) |>
    get_marginal_effect(trt = "trtp", method = "Ye", contrast = "diff", reference = "0")

  # Convert to cards format
  cards_ard <- beeca_to_cards_ard(fit1$marginal_results)

  # Print the cards ARD (uses print method for 'card' class)
  print(cards_ard)

  # Bind with other cards ARDs
  combined_ard <- cards::bind_ard(
    cards_ard,
    cards::ard_continuous(trial01, by = trtp, variables = bl_cov)
  )
}
#> Warning: There is 1 record omitted from the original data due to missing values, please check if they should be imputed prior to model fitting.
#> {cards} data frame: 12 x 11
#>    group1 group1_level variable variable_level stat_name stat_label   stat
#> 1    trtp            0     aval             NA         N          N    133
#> 2    trtp            0     aval             NA         n          n     65
#> 3    trtp            0     aval             NA         %          % 48.872
#> 4    trtp            0     aval             NA      risk       Risk  0.487
#> 5    trtp            0     aval             NA   risk_se    Risk SE  0.044
#> 6    trtp            1     aval             NA         N          N    134
#> 7    trtp            1     aval             NA         n          n     56
#> 8    trtp            1     aval             NA         %          % 41.791
#> 9    trtp            1     aval             NA      risk       Risk  0.419
#> 10   trtp            1     aval             NA   risk_se    Risk SE  0.043
#> 11   trtp    diff: 1-0     aval             NA      diff  Differen… -0.068
#> 12   trtp    diff: 1-0     aval             NA   diff_se  Differen…  0.061
#> ℹ 4 more variables: context, warning, error, fmt_fn
```
