# Requirements: beeca v0.4.0 GEE Extension

**Defined:** 2026-02-07
**Core Value:** GEE objects flow through beeca's g-computation pipeline with correct variance estimation

## v0.4.0 Requirements

### Input Validation

- [ ] **VALID-01**: sanitize_model.glmgee() S3 method validates glmgee objects (binomial/logit, factor treatment, no interactions)
- [ ] **VALID-02**: sanitize_model.geeglm() S3 method validates geeglm objects (binomial/logit, factor treatment, no interactions)
- [ ] **VALID-03**: Informative error messages when GEE objects fail validation

### Variance Estimation

- [ ] **VAR-01**: estimate_varcov routes GEE objects to GEE's own vcov instead of sandwich::vcovHC
- [ ] **VAR-02**: Robust sandwich variance supported for both glmgee and geeglm
- [ ] **VAR-03**: Bias-corrected (Mancl-DeRouen) variance supported for glmgee
- [ ] **VAR-04**: DF-adjusted variance supported for glmgee
- [ ] **VAR-05**: Informative error when Ye method requested for GEE objects

### Pipeline

- [ ] **PIPE-01**: predict_counterfactuals works with GEE objects
- [ ] **PIPE-02**: average_predictions works with GEE objects
- [ ] **PIPE-03**: All five contrast types work with GEE objects (diff, or, rr, logor, logrr)
- [ ] **PIPE-04**: get_marginal_effect works end-to-end with GEE objects

### Testing

- [ ] **TEST-01**: GEE-specific test suite with cross-validation against manual computation
- [ ] **TEST-02**: All 308 existing GLM tests continue to pass (no regressions)
- [ ] **TEST-03**: R CMD check passes with no errors/warnings

### Documentation

- [x] **DOC-01**: New GEE vignette with end-to-end workflow example
- [x] **DOC-02**: Man pages document GEE support (sanitize_model, estimate_varcov)
- [x] **DOC-03**: NEWS.md updated for v0.4.0

## Future Requirements (v0.5.0 ARD)

- **ARD-01**: Test coverage for beeca_to_cards_ard()
- **ARD-02**: Confidence intervals in marginal_results ARD
- **ARD-03**: Metadata enrichment (beeca_metadata attributes)
- **ARD-04**: Converter infrastructure (beeca_to_ard dispatcher, CDISC ARS)

## Out of Scope

| Feature | Reason |
|---------|--------|
| Multi-timepoint longitudinal GEE | Requires companion package (beecal), not beeca's identity |
| Ye et al. method for GEE | Assumes independence, not valid for correlated data |
| gee package support | Older package, lower priority -- can add later if needed |
| CRAN submission | GitHub release only for v0.4.0 |
| ARD improvements | Deferred to v0.5.0 milestone |

## Traceability

| Requirement | Phase | Status |
|-------------|-------|--------|
| VALID-01 | Phase 5 | Complete |
| VALID-02 | Phase 5 | Complete |
| VALID-03 | Phase 5 | Complete |
| VAR-01 | Phase 5 | Complete |
| VAR-02 | Phase 5 | Complete |
| VAR-03 | Phase 5 | Complete |
| VAR-04 | Phase 5 | Complete |
| VAR-05 | Phase 5 | Complete |
| PIPE-01 | Phase 5 | Complete |
| PIPE-02 | Phase 5 | Complete |
| PIPE-03 | Phase 5 | Complete |
| PIPE-04 | Phase 5 | Complete |
| TEST-01 | Phase 6 | Complete |
| TEST-02 | Phase 6 | Complete |
| TEST-03 | Phase 6 | Complete |
| DOC-01 | Phase 7 | Pending |
| DOC-02 | Phase 7 | Pending |
| DOC-03 | Phase 7 | Pending |

**Coverage:**
- v0.4.0 requirements: 18 total
- Mapped to phases: 18
- Unmapped: 0

---
*Requirements defined: 2026-02-07*
*Last updated: 2026-02-08 after Phase 6 execution*
