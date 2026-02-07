# Output from the Margins SAS macro applied to the trial01 dataset

For purposes of implementation comparisons, these are the result outputs
from the SAS Margins macro (https://support.sas.com/kb/63/038.html),
applied to the trial01 dataset included with beeca, adjusting for
treatment (trtp) and a single covariate (bl_cov) and targeting a risk
difference contrast.

## Usage

``` r
margins_trial01
```

## Format

`margins_trial01` A tibble with 1 row and 11 columns:

- Estimate:

  Marginal risk difference estimate

- ChiSq:

  Wald Chi-Square statistic

- Row:

  Row number

- StdErr:

  Standard error of marginal risk difference estimate

- Lower:

  Lower bound of 95 percent confidence interval of estimate

- Upper:

  Upper bound of 95 percent confidence interval of estimate

- Contrast:

  Descriptive label for contrast

- df:

  Degrees of freedom

- Pr:

  p-value

- Alpha:

  Significance level alpha

- label:

  Label for contrast
