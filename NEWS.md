# beeca 0.3.0

## New Features

### User Experience Enhancements

- **`beeca_fit()`**: New convenience function that streamlines the analysis workflow by combining model fitting and marginal effect estimation in a single call. Features include:
  - Automatic treatment variable factorization
  - Input validation with helpful error messages
  - Optional progress messages
  - Support for multiple covariates and stratification

### Output & Reporting Enhancements

- **Enhanced `print.beeca()`**: Concise output showing treatment effect estimate, standard error, Z-value, and p-value with helpful usage hints
- **Enhanced `summary.beeca()`**: Comprehensive output including:
  - Model information (method, sample size, outcome variable)
  - Marginal risks table with confidence intervals
  - Treatment effects table with full statistics

### Visualization

- **`plot.beeca()`**: New S3 plot method for beeca objects
- **`plot_forest()`**: Professional forest plots for visualizing treatment effects with:
  - Automatic null line positioning based on contrast type
  - Customizable titles, labels, colors, and confidence levels
  - Optional numerical value display
  - Built on ggplot2 for easy customization

## Minor Improvements

- Added `rlang` to package dependencies for safe non-standard evaluation
- Updated documentation with examples of new features
- Added comprehensive test suites for all new functions (69 new tests)

## Bug Fixes

- Fixed function name conflict in `plot_forest()` where base R's `diff()` was being called incorrectly

# beeca 0.2.0

- Extensions to allow for more than two treatment arms in the model fit.

# beeca 0.1.3

- Preparation for CRAN submission

# beeca 0.1.0

- Added a `NEWS.md` file to track changes to the package.
- Added documentation via `pkgdown`.
