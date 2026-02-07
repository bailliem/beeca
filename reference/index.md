# Package index

## Quick Start

Streamlined workflow for rapid analysis with sensible defaults.

- [`beeca_fit()`](https://openpharma.github.io/beeca/reference/beeca_fit.md)
  : Quick beeca analysis pipeline

## Core Analysis Pipeline

Manual pipeline for full control over each step of marginal effect
estimation.

- [`get_marginal_effect()`](https://openpharma.github.io/beeca/reference/get_marginal_effect.md)
  : Estimate marginal treatment effects using a GLM working model
- [`predict_counterfactuals()`](https://openpharma.github.io/beeca/reference/predict_counterfactuals.md)
  : Predict counterfactual outcomes in GLM models
- [`average_predictions()`](https://openpharma.github.io/beeca/reference/average_predictions.md)
  : Average over counterfactual predictions
- [`estimate_varcov()`](https://openpharma.github.io/beeca/reference/estimate_varcov.md)
  : Estimate variance-covariance matrix for marginal estimand based on
  GLM model
- [`apply_contrast()`](https://openpharma.github.io/beeca/reference/apply_contrast.md)
  : Apply contrast to calculate marginal estimate of treatment effect
  and corresponding standard error

## Working with Results

S3 methods and visualization tools for beeca objects.

- [`print(`*`<beeca>`*`)`](https://openpharma.github.io/beeca/reference/print.beeca.md)
  : Print method for beeca objects
- [`summary(`*`<beeca>`*`)`](https://openpharma.github.io/beeca/reference/summary.beeca.md)
  : Summary method for beeca objects
- [`tidy(`*`<beeca>`*`)`](https://openpharma.github.io/beeca/reference/tidy.beeca.md)
  : Tidy method for beeca objects
- [`augment(`*`<beeca>`*`)`](https://openpharma.github.io/beeca/reference/augment.beeca.md)
  : Augment method for beeca objects
- [`plot(`*`<beeca>`*`)`](https://openpharma.github.io/beeca/reference/plot.beeca.md)
  : Plot method for beeca objects
- [`plot_forest()`](https://openpharma.github.io/beeca/reference/plot_forest.md)
  : Forest plot for marginal treatment effects

## Tables and Reporting

Functions for creating publication-quality tables and ARD formats.

- [`beeca_summary_table()`](https://openpharma.github.io/beeca/reference/beeca_summary_table.md)
  : Create a summary statistics table for beeca analysis
- [`as_gt()`](https://openpharma.github.io/beeca/reference/as_gt.md) :
  Convert beeca object to gt table
- [`beeca_to_cards_ard()`](https://openpharma.github.io/beeca/reference/beeca_to_cards_ard.md)
  : Convert beeca marginal_results to cards ARD format
- [`format_pvalue()`](https://openpharma.github.io/beeca/reference/format_pvalue.md)
  : Format p-value for clinical trial tables

## Model Validation

Input validation for ensuring models meet beeca requirements.

- [`sanitize_model()`](https://openpharma.github.io/beeca/reference/sanitize_model.md)
  : (internal) Sanitize functions to check model and data within GLM
  model object
- [`sanitize_model(`*`<glm>`*`)`](https://openpharma.github.io/beeca/reference/sanitize_model.glm.md)
  : (internal) Sanitize a glm model
- [`sanitize_variable()`](https://openpharma.github.io/beeca/reference/sanitize_variable.md)
  : (internal) Sanitize function to check model and data

## Example Datasets

Clinical trial datasets for examples and cross-validation.

- [`trial01`](https://openpharma.github.io/beeca/reference/trial01.md) :
  Example trial dataset 01
- [`trial02_cdisc`](https://openpharma.github.io/beeca/reference/trial02_cdisc.md)
  : Example CDISC Clinical Trial Dataset in ADaM Format
- [`margins_trial01`](https://openpharma.github.io/beeca/reference/margins_trial01.md)
  : Output from the Margins SAS macro applied to the trial01 dataset
- [`ge_macro_trial01`](https://openpharma.github.io/beeca/reference/ge_macro_trial01.md)
  : Output from the Ge et al (2011) SAS macro applied to the trial01
  dataset

## Package Documentation

Package-level documentation and re-exported functions.

- [`beeca`](https://openpharma.github.io/beeca/reference/beeca-package.md)
  [`beeca-package`](https://openpharma.github.io/beeca/reference/beeca-package.md)
  : beeca: Binary Endpoint Estimation with Covariate Adjustment
- [`reexports`](https://openpharma.github.io/beeca/reference/reexports.md)
  [`tidy`](https://openpharma.github.io/beeca/reference/reexports.md)
  [`augment`](https://openpharma.github.io/beeca/reference/reexports.md)
  : Objects exported from other packages
