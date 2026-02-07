# Changelog

## beeca 0.3.0

### New Features

- [`beeca_fit()`](https://openpharma.github.io/beeca/reference/beeca_fit.md):
  Convenience function combining model fitting and marginal effect
  estimation in a single call.
- [`plot_forest()`](https://openpharma.github.io/beeca/reference/plot_forest.md):
  Forest plots for visualizing treatment effects with customizable
  confidence levels and styling.
- [`plot.beeca()`](https://openpharma.github.io/beeca/reference/plot.beeca.md):
  S3 plot method for beeca objects.
- [`beeca_summary_table()`](https://openpharma.github.io/beeca/reference/beeca_summary_table.md):
  Generate summary tables from beeca objects returning a data frame with
  arm statistics and treatment effects.
- [`beeca_to_cards_ard()`](https://openpharma.github.io/beeca/reference/beeca_to_cards_ard.md):
  Convert beeca results to Analysis Results Data format via cards.
- [`tidy.beeca()`](https://openpharma.github.io/beeca/reference/tidy.beeca.md):
  Tidy method returning treatment effect estimates as a tibble.
- [`augment.beeca()`](https://openpharma.github.io/beeca/reference/augment.beeca.md):
  Augment method returning original data with fitted values and
  predictions.
- [`print.beeca()`](https://openpharma.github.io/beeca/reference/print.beeca.md):
  Concise print output showing treatment effect, standard error,
  Z-value, and p-value.
- [`summary.beeca()`](https://openpharma.github.io/beeca/reference/summary.beeca.md):
  Comprehensive summary including marginal risks and treatment effects
  with confidence intervals.
- [`as_gt.beeca()`](https://openpharma.github.io/beeca/reference/as_gt.md):
  Create publication-ready gt tables from beeca objects with
  customizable titles and footnotes.
- `trial02_cdisc`: CDISC-compliant example dataset for clinical trial
  workflows.

### Improvements

- Updated Magirr et al. reference from OSF preprint to published version
  in Pharmaceutical Statistics (2025).
- Added `rlang` and `generics` to package Imports for robust
  non-standard evaluation and S3 method support.
- Added Suggests dependencies for enhanced visualization (`ggplot2`) and
  table formatting (`gt`, `cards`).
- Enhanced vignettes with improved narrative flow, cross-referencing,
  and method guidance.

### Bug Fixes

- Fixed function name conflict in
  [`plot_forest()`](https://openpharma.github.io/beeca/reference/plot_forest.md)
  where base R’s [`diff()`](https://rdrr.io/r/base/diff.html) was called
  incorrectly.
- Replaced deprecated
  [`geom_errorbarh()`](https://ggplot2.tidyverse.org/reference/geom_linerange.html)
  with `geom_errorbar(orientation = "y")` in
  [`plot_forest()`](https://openpharma.github.io/beeca/reference/plot_forest.md)
  for ggplot2 4.0.0 compatibility.

## beeca 0.2.0

CRAN release: 2024-11-12

- Extensions to allow for more than two treatment arms in the model fit.

## beeca 0.1.3

CRAN release: 2024-06-18

- Preparation for CRAN submission

## beeca 0.1.0

- Added a `NEWS.md` file to track changes to the package.
- Added documentation via `pkgdown`.
