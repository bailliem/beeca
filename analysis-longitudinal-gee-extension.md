# Analysis: Extending beeca for Longitudinal / GEE Settings

## Issue Summary

A user requests that beeca be extended to support **longitudinal studies
with binary (and ordinal) endpoints** fitted via **Generalized
Estimating Equations (GEE)**, with support for:

1.  GEE estimation for non-Gaussian outcomes (logistic, ordinal)
2.  Small-sample variance corrections (Mancl-DeRouen)
3.  Firth-like penalised GEE logistic regression
4.  Multiplicity adjustment (MVT-based, gatekeeping) across multiple
    timepoints
5.  Integration with packages like `glmtoolbox`, `geesbin`, `mice`,
    `emmeans`

------------------------------------------------------------------------

## 1. Current beeca Architecture and Assumptions

### Core statistical identity

beeca implements **g-computation** (standardisation) for binary
endpoints from a **single-timepoint, cross-sectional GLM**:

    glm(Y ~ Trt + Covariates, family = binomial(logit), data)

The pipeline is:

1.  **Fit** a logistic regression working model
2.  **Predict counterfactuals**: for every subject, predict P(Y=1) under
    each treatment assignment
3.  **Average** counterfactual predictions per arm → marginal means
4.  **Estimate variance** using either:
    - **Ge et al. (2011)**: delta-method + HC sandwich on the GLM
      parameter variance → CATE
    - **Ye et al. (2023)**: variance decomposition using residuals and
      counterfactual predictions → PATE
5.  **Apply contrast**: risk difference, risk ratio, odds ratio (+
    log-transformed)

### Key assumptions baked into the code

| Assumption                                                                                                                       | Where enforced                                                                                                                                                          | Implication for GEE                                                                    |
|----------------------------------------------------------------------------------------------------------------------------------|-------------------------------------------------------------------------------------------------------------------------------------------------------------------------|----------------------------------------------------------------------------------------|
| Single binary outcome per subject                                                                                                | [`sanitize_variable()`](https://openpharma.github.io/beeca/reference/sanitize_variable.md) checks 0/1 coding                                                            | GEE has repeated measurements per subject                                              |
| [`stats::glm()`](https://rdrr.io/r/stats/glm.html) object as input                                                               | [`sanitize_model.glm()`](https://openpharma.github.io/beeca/reference/sanitize_model.glm.md), S3 dispatch on class `"glm"`                                              | GEE objects are class `"glmgee"` (glmtoolbox) or `"geeglm"` (geepack)                  |
| Independent observations                                                                                                         | Ge variance uses [`sandwich::vcovHC()`](https://sandwich.R-Forge.R-project.org/reference/vcovHC.html) which assumes independence                                        | GEE explicitly models within-cluster correlation                                       |
| [`model.matrix()`](https://rdrr.io/r/stats/model.matrix.html) and [`predict()`](https://rdrr.io/r/stats/predict.html) from stats | [`predict_counterfactuals()`](https://openpharma.github.io/beeca/reference/predict_counterfactuals.md) calls [`stats::predict()`](https://rdrr.io/r/stats/predict.html) | GEE objects need their own [`predict()`](https://rdrr.io/r/stats/predict.html) methods |
| `$y`, `$qr`, `$converged`, `$family`, `$terms` slots                                                                             | Used throughout sanitize/varcov code                                                                                                                                    | GEE objects have different internal structures                                         |
| No cluster/subject identifier                                                                                                    | Not tracked anywhere                                                                                                                                                    | GEE requires cluster ID for correlation structure                                      |

------------------------------------------------------------------------

## 2. Methodological Implications

### 2.1 What changes conceptually

In a **single-timepoint** trial with binary endpoint: - **Estimand**:
P(Y=1 \| Trt=A) - P(Y=1 \| Trt=B) (risk difference at one timepoint) -
**Working model**: logistic regression - **Variance**: robust sandwich
or variance decomposition

In a **longitudinal** trial with binary endpoint at multiple visits: -
**Estimand(s)**: Risk difference at each timepoint t ∈ {t₁, t₂, …, tₖ} -
Primary: one designated timepoint - Secondary: remaining timepoints -
**Working model**: GEE logistic regression with working correlation
(exchangeable, AR(1), unstructured, etc.) - **Variance**: GEE sandwich
estimator (or Mancl-DeRouen corrected), which accounts for
within-subject correlation - **Multiplicity**: MVT adjustment or
gatekeeping across timepoints

### 2.2 Marginal vs. conditional estimands

This is where beeca’s current framework actually aligns well
conceptually:

- **GEE already targets marginal (population-averaged) effects** — this
  is the defining feature of GEE vs. GLMM
- beeca’s g-computation approach also targets marginal effects via
  standardisation
- The fundamental question becomes: **do you need g-computation on top
  of GEE, or does the GEE marginal model suffice?**

**Key insight**: In the longitudinal GEE context, the primary reason to
use g-computation/standardisation would be: - When the GEE model
includes covariates beyond treatment and you want covariate-adjusted
marginal effects - When you want effects on a different scale than the
model’s link function

If the GEE model is
`GEE(Y_it ~ Trt + Time + Trt:Time + Covariates, family=binomial, corstr="unstructured")`,
the marginal treatment effects at each timepoint can be obtained
either: 1. Directly from the model coefficients (conditional on
covariates staying at reference) 2. Via g-computation/standardisation
(averaged over the covariate distribution) — **this is what beeca does**

So the g-computation step remains relevant and valuable.

### 2.3 Variance estimation: the critical challenge

This is where the biggest methodological departure occurs:

**Current (GLM)**: - Ge method: `D × vcovHC(glm) × D'` — the sandwich is
for independent observations - Ye method: variance decomposition using
per-subject residuals — also assumes independence

**Required (GEE)**: - The “meat” of the sandwich must account for
**within-cluster (within-subject) correlation** - GEE sandwich:
`B⁻¹ × M × B⁻¹` where M = Σᵢ Dᵢ’ Vᵢ⁻¹ (Yᵢ - μᵢ)(Yᵢ - μᵢ)’ Vᵢ⁻¹ Dᵢ,
summed over **clusters** not individual observations - The Mancl-DeRouen
(2001) correction replaces raw residuals with leverage-corrected
residuals: `eᵢ* = (I - Hᵢ)⁻¹ eᵢ`

**Neither the Ge nor the Ye variance method directly applies to the GEE
case.** Both assume the model is a single-observation-per-subject GLM.
The extension would need to:

1.  Use the GEE’s own cluster-robust sandwich variance for the parameter
    estimates
2.  Propagate this through the delta method for g-computation (analogous
    to what Ge does, but with the GEE sandwich instead of `vcovHC()`)
3.  Or develop a Ye-style variance decomposition that respects the
    clustered structure

### 2.4 Counterfactual predictions in longitudinal setting

The current
[`predict_counterfactuals()`](https://openpharma.github.io/beeca/reference/predict_counterfactuals.md)
creates an N × K matrix (N subjects, K treatment levels). In a
longitudinal setting, you would need:

- An (N × T) × K matrix (N subjects × T timepoints × K treatments), or
- Marginal means at each timepoint separately
- The “average” step would need to average within timepoint-treatment
  cells, not just treatment cells

### 2.5 The Mancl-DeRouen estimator

The Mancl-DeRouen (M-dR) corrected sandwich estimator is a small-sample
bias correction for the GEE sandwich variance. It inflates residuals by
the inverse of `(I - H_i)` where `H_i` is the leverage matrix for
cluster i.

- This is analogous to HC3 in the single-observation case (HC3 uses
  `1/(1-h_ii)²` per observation)
- beeca already supports HC0-HC5 for single-observation GLMs via
  [`sandwich::vcovHC()`](https://sandwich.R-Forge.R-project.org/reference/vcovHC.html)
- For GEE,
  [`sandwich::vcovHC()`](https://sandwich.R-Forge.R-project.org/reference/vcovHC.html)
  does not apply — you need the clustered version
- The `glmtoolbox` package provides M-dR directly; `geesbin` does as
  well

### 2.6 Firth-like penalised GEE

Firth penalisation addresses separation/quasi-separation in logistic
regression — events where ML estimation fails because a covariate
perfectly predicts the outcome. In GEE:

- Standard GEE can suffer from the same convergence issues with rare
  events
- Firth-type penalisation adds a Jeffreys-prior-like penalty to the GEE
  estimating equations
- The `geesbin` package implements this
- beeca would need to accept the fitted penalised GEE object and use its
  predictions/variance

------------------------------------------------------------------------

## 3. Technical Implications: What Would Need to Change

### 3.1 Input validation (`sanitize.R`)

| Current                               | Required change                                                                     |
|---------------------------------------|-------------------------------------------------------------------------------------|
| Only accepts `glm` class              | Add `sanitize_model.glmgee()` and/or `sanitize_model.geeglm()` S3 methods           |
| Checks `$family$family == "binomial"` | GEE objects store family differently; `glmgee` uses `$family` but structure differs |
| Checks `$converged`                   | GEE convergence flag location differs                                               |
| Checks `$qr$rank`                     | GEE objects may not have QR decomposition                                           |
| Checks response is 0/1                | Would need to also handle ordinal responses if extending to ordinal GEE             |
| No cluster ID concept                 | Need to validate and track cluster/subject identifier                               |
| No timepoint concept                  | Need to validate and track visit/timepoint variable                                 |

### 3.2 Counterfactual predictions (`predict_counterfactuals.R`)

| Current                                                 | Required change                                                                   |
|---------------------------------------------------------|-----------------------------------------------------------------------------------|
| Uses `stats::predict(object, newdata, type="response")` | GEE predict methods differ; `glmtoolbox::predict.glmgee()` exists but API differs |
| Creates N × K tibble                                    | Need N×T × K structure, or predict at each timepoint separately                   |
| Single response per subject                             | Need to handle multiple responses per subject                                     |
| No time dimension                                       | Counterfactuals need to be timepoint-specific                                     |

### 3.3 Averaging (`average_predictions.R`)

| Current                                                                      | Required change                                  |
|------------------------------------------------------------------------------|--------------------------------------------------|
| Simple [`colMeans()`](https://rdrr.io/r/base/colSums.html) over all subjects | Need to average within timepoint-treatment cells |
| Returns K-length vector                                                      | Returns K × T matrix of marginal means           |

### 3.4 Variance estimation (`estimate_varcov.R`)

This is the **most substantial** change required.

**Ge method path**: - Currently: `D × sandwich::vcovHC(glm) × D'` -
Required: `D × vcov_gee_clustered(gee_model) × D'` - Where
`vcov_gee_clustered` is the GEE sandwich (or M-dR corrected) variance of
parameters - The `D` matrix (gradient of g-computation w.r.t.
parameters) would need to be computed per timepoint - The result would
be a (K×T) × (K×T) variance-covariance matrix spanning all
treatment-timepoint combinations

**Ye method path**: - The Ye et al. variance decomposition was derived
specifically for independent binary outcomes - It is **not directly
applicable** to longitudinal data - A new derivation would be needed, or
this method would not be supported for GEE

**Practical approach**: Use the GEE model’s own cluster-robust variance
and propagate through the delta method. This is methodologically sound
and sidesteps the need to re-derive Ye’s decomposition.

### 3.5 Contrasts (`apply_contrast.R`)

| Current                     | Required change                                                    |
|-----------------------------|--------------------------------------------------------------------|
| K × K contrast matrix       | Need (K×T) × (K×T) structure, or contrasts computed per timepoint  |
| Single set of contrasts     | Multiple contrasts: one per timepoint, or pooled across timepoints |
| No multiplicity adjustment  | Need MVT-based p-value adjustment or gatekeeping                   |
| Delta method on K-dim means | Delta method on K×T-dim means                                      |

### 3.6 Output / reporting (`get_marginal_effect.R`, `tidy.R`, `summary.R`)

| Current                                                                                 | Required change                               |
|-----------------------------------------------------------------------------------------|-----------------------------------------------|
| ARD format assumes single timepoint                                                     | Need AVISIT/timepoint dimension in ARD output |
| `marginal_results` has TRTVAR/TRTVAL/PARAM/STAT                                         | Add visit/timepoint column                    |
| Forest plot for single timepoint                                                        | Multi-timepoint forest plot                   |
| [`tidy()`](https://generics.r-lib.org/reference/tidy.html) returns one row per contrast | Returns rows per contrast × timepoint         |

### 3.7 New dependencies

| Package      | Purpose                           | Status                                         |
|--------------|-----------------------------------|------------------------------------------------|
| `glmtoolbox` | GEE fitting, M-dR variance        | Would move from nothing to Suggests or Imports |
| `geepack`    | Alternative GEE fitting           | Suggests                                       |
| `geesbin`    | Firth-penalised GEE               | Suggests                                       |
| `mvtnorm`    | MVT-based multiplicity adjustment | New dependency (Imports or Suggests)           |
| `emmeans`    | Marginal means integration        | Suggests                                       |

------------------------------------------------------------------------

## 4. Pros and Cons

### 4.1 Pros of extending beeca

1.  **Fills a genuine gap**: There is no R package that combines
    g-computation-based covariate adjustment with GEE for longitudinal
    binary endpoints in a clinical-trial-focused workflow
2.  **Natural extension of the estimand framework**: The ICH E9(R1)
    estimand framework (which beeca’s documentation references)
    explicitly applies to longitudinal settings
3.  **Regulatory relevance**: FDA guidance on covariate adjustment
    applies to longitudinal trials too; having robust tools strengthens
    submissions
4.  **Reuse of existing infrastructure**: The g-computation pipeline
    (predict counterfactuals → average → contrast) is conceptually
    identical; only the variance step fundamentally changes
5.  **M-dR estimator demand**: The issue author highlights real
    regulatory pushback on standard sandwich in small samples —
    providing M-dR support meets a practical need
6.  **Package differentiation**: beeca would become unique in combining
    covariate-adjusted marginal effects + GEE + small-sample
    corrections + clinical trial reporting (ARD/CDISC format)

### 4.2 Cons / Risks

1.  **Scope creep**: beeca is currently a focused, well-scoped package
    (~4500 lines). Adding longitudinal support could double or triple
    complexity
2.  **Methodological uncertainty**: The Ye variance decomposition has no
    published extension to GEE — only the Ge/delta-method approach would
    transfer. This means half the current methodology doesn’t extend
3.  **Dependency burden**: Adding `glmtoolbox`, `geesbin`, `mvtnorm` as
    dependencies increases maintenance risk and GxP validation burden
4.  **Testing complexity**: Longitudinal data has many more edge cases
    (unbalanced visits, dropout patterns, monotone missingness,
    time-varying covariates)
5.  **Package identity**: “Binary Endpoint Estimation with Covariate
    Adjustment” — the name and scope are tied to the
    single-binary-endpoint case. Longitudinal binary data is a different
    use case
6.  **Validation burden**: For pharma use, every new method pathway
    needs extensive validation against known results (SAS, other
    validated tools). There are fewer published benchmarks for
    g-computation + GEE
7.  **Competing approaches**: Some would argue that for longitudinal
    binary data with covariate adjustment, MMRM-like approaches
    (treating each visit as a separate endpoint in a multivariate model)
    are more established than GEE
8.  **Ordinal extension**: The issue mentions ordinal endpoints — this
    is an even larger departure from binary logistic regression

### 4.3 Middle-ground options

Rather than full longitudinal GEE support, consider:

1.  **Accept GEE objects but only for single-timepoint analysis**: Allow
    users to fit a GEE (which handles clustering from other sources,
    e.g., site-level clustering) and extract marginal effects at a
    single timepoint. This is a much smaller change.

2.  **Multi-endpoint wrapper**: Keep the per-endpoint analysis as-is,
    but add a higher-level function that runs beeca independently at
    each timepoint and then applies MVT adjustment to the collection of
    p-values. This requires no changes to the core pipeline.

3.  **Point to RobinCar**: The `RobinCar` package (already in Suggests)
    has been developing longitudinal extensions. beeca could focus on
    being the clinical-trial-reporting layer on top of RobinCar’s
    longitudinal capabilities.

------------------------------------------------------------------------

## 5. Specific Technical Concerns

### 5.1 The `sandwich::vcovHC()` dependency

beeca’s Ge method relies entirely on
[`sandwich::vcovHC()`](https://sandwich.R-Forge.R-project.org/reference/vcovHC.html)
for the parameter variance matrix. This function is designed for
`lm`/`glm` objects with independent observations. For GEE:

- [`sandwich::vcovCL()`](https://sandwich.R-Forge.R-project.org/reference/vcovCL.html)
  (cluster-robust) could be used if the GEE object can be coerced, but
  this doesn’t account for the working correlation
- The GEE model’s own [`vcov()`](https://rdrr.io/r/stats/vcov.html)
  method already provides the robust sandwich
- For M-dR, you need the GEE package’s own implementation (glmtoolbox
  provides this)
- **Bottom line**: The `sandwich` package dependency would become less
  central; the GEE package itself would provide the variance

### 5.2 The `.get_data()` assumption

Currently `.get_data()` returns `model$model` (the model frame from
`glm`). GEE objects may store data differently: - `glmtoolbox::glmgee`
stores data in `$model` (similar to glm) - `geepack::geeglm` stores data
in `$data` or `$model` - Need to verify data retrieval works correctly
with repeated-measures data structure

### 5.3 The `predict()` step

GEE predict methods may not support `newdata` arguments in the same way
as [`stats::predict.glm()`](https://rdrr.io/r/stats/predict.glm.html).
This needs careful testing. If `predict.glmgee()` doesn’t support
arbitrary newdata, the counterfactual prediction step breaks down
entirely.

### 5.4 Treatment-by-time interactions

For longitudinal analysis, the model almost always includes `Trt × Time`
interaction. beeca currently **blocks** treatment interactions
([`sanitize_model.glm()`](https://openpharma.github.io/beeca/reference/sanitize_model.glm.md)
lines 50-55). This check would need to be relaxed for GEE models to
allow `Trt × Visit` interactions (which are essential for estimating
timepoint-specific effects).

------------------------------------------------------------------------

## 6. Recommended Path Forward

### Phase 0: Scoping (no code changes)

- Decide whether longitudinal support belongs in beeca or a companion
  package (e.g., `beecal` for “longitudinal”)
- Survey the regulatory landscape: are sponsors actually using
  g-computation + GEE, or is GEE direct estimation sufficient?
- Check whether RobinCar’s longitudinal features cover this need

### Phase 1: Accept GEE objects for cross-sectional analysis

- Add `sanitize_model.glmgee()` S3 method
- Allow GEE-fitted models to flow through the existing pipeline
- Use GEE’s own vcov (including M-dR) instead of
  [`sandwich::vcovHC()`](https://sandwich.R-Forge.R-project.org/reference/vcovHC.html)
- No multi-timepoint support yet — just robustness to clustered data
- Smallest change, biggest immediate value

### Phase 2: Multi-timepoint marginal effects

- Extend counterfactual predictions to be timepoint-specific
- Extend averaging to produce means per treatment × timepoint
- Extend variance to produce joint (treatment × timepoint)
  variance-covariance
- Only Ge-style delta method (not Ye decomposition)

### Phase 3: Multiplicity adjustment

- Add MVT-based adjustment using the joint variance-covariance matrix
- Add gatekeeping procedures
- Potentially via
  [`mvtnorm::pmvt()`](https://rdrr.io/pkg/mvtnorm/man/pmvt.html) for the
  multivariate t distribution

### Phase 4: Firth-penalised GEE and ordinal

- Accept `geesbin` objects
- Consider ordinal GEE (proportional odds GEE) — major additional work

------------------------------------------------------------------------

## 7. Summary Table

| Feature requested             | Difficulty                  | Value  | Recommendation                                       |
|-------------------------------|-----------------------------|--------|------------------------------------------------------|
| Accept GEE model objects      | Medium                      | High   | Phase 1 — do this                                    |
| Mancl-DeRouen variance        | Low (use GEE package’s own) | High   | Phase 1 — comes naturally                            |
| Multi-timepoint g-computation | High                        | High   | Phase 2 — significant new code                       |
| MVT multiplicity adjustment   | Medium                      | Medium | Phase 3 — mostly wrapper code                        |
| Firth-penalised GEE           | Medium                      | Medium | Phase 4 — accept the object                          |
| Ordinal endpoints             | Very High                   | Medium | Separate consideration — changes the entire pipeline |
| Integration with emmeans      | Medium                      | Medium | Deferred — requires S3 method registration           |
| Integration with mice         | Low                         | Low    | Already possible if user fits GEE on imputed data    |
