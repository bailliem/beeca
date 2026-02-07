# Phase 5: GEE Core Implementation - Context

**Gathered:** 2026-02-07
**Status:** Ready for planning

<domain>
## Phase Boundary

Make GEE model objects (glmgee from glmtoolbox, geeglm from geepack) flow through beeca's existing g-computation pipeline — S3 validation methods, variance routing via GEE's own vcov, and end-to-end marginal treatment effect estimation. Single-timepoint covariate-adjusted binary endpoint analysis only. Multi-timepoint GEE, new contrast types, and ARD changes are out of scope.

</domain>

<decisions>
## Implementation Decisions

### Variance type mapping
- Use GEE-native type names ("robust", "bias-corrected", "df-adjusted"), NOT HC0/HC1/etc.
- When a user passes a GLM-style type (e.g., "HC0") to a GEE object, produce an error listing valid GEE types
- glmgee variance types: Claude's discretion on which of robust, bias-corrected (Mancl-DeRouen), and DF-adjusted to expose, based on glmtoolbox's vcov API
- geeglm variance types: Claude's discretion on whether to expose only native geepack variance or compute additional corrections
- Default variance type for GEE: Claude's discretion on sensible default

### Variance method
- vcov source: Claude's discretion on whether to call vcov() method or extract from object internals
- Ge method with GEE: Claude's discretion on whether delta method needs GEE-specific adaptation
- Method parameter for GEE: Claude's discretion on cleanest API design (Ge-only, default-inferred, etc.)

### Validation rules
- Mirror existing GLM validation checks where applicable; Claude determines which need GEE-specific adaptation (e.g., convergence checking differs for GEE)
- Validate that cluster/id variable is present and accessible
- Validate single-timepoint: check that each cluster has exactly 1 observation — error if multi-timepoint data detected
- Correlation structure constraints: Claude's discretion based on single-timepoint use case

### Error messaging
- Ye method rejection: short + reference — "Ye's method assumes independence and is not valid for GEE models. Use method='Ge' instead."
- GEE errors should mention the specific package name ("glmgee" or "geeglm") to help users debug
- Unsupported variance type errors: Claude's discretion on whether to list valid options
- Multi-error reporting: Claude's discretion, match current GLM behavior

### Package availability
- GEE packages stay in Suggests (not Imports) — per existing decision
- Check package availability early in sanitize_model(), not lazily — fail fast
- When package missing: error with install hint — "glmtoolbox is required for glmgee objects. Install with install.packages('glmtoolbox')"
- Pin minimum versions in DESCRIPTION Suggests based on API features needed
- Tests use skip_if_not_installed() — run when packages available, skip gracefully otherwise

### Claude's Discretion
- glmgee variance types to expose (robust, bias-corrected, DF-adjusted — assess feasibility)
- geeglm variance coverage (native only vs computed corrections)
- Default variance type for GEE objects
- vcov extraction approach (method call vs object internals)
- Ge delta method adaptation for GEE
- Method parameter API design for GEE
- Correlation structure validation rules
- Multi-error vs first-error reporting (match GLM pattern)
- Whether unsupported type errors list valid options

</decisions>

<specifics>
## Specific Ideas

- Ye rejection message should be concise: "Ye's method assumes independence and is not valid for GEE models. Use method='Ge' instead."
- Error messages should include the specific GEE class name (glmgee/geeglm) — helps users know which object type caused the issue
- Single-timepoint enforcement: each cluster must have exactly 1 observation
- Package check at sanitize_model() entry point, with actionable install.packages() hint

</specifics>

<deferred>
## Deferred Ideas

None — discussion stayed within phase scope

</deferred>

---

*Phase: 05-gee-core-implementation*
*Context gathered: 2026-02-07*
