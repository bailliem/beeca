# Predict counterfactual outcomes in GLM models

This function calculates counterfactual predictions for each level of a
specified treatment variable in a generalized linear model (GLM). It is
designed to aid in the assessment of treatment effects by predicting
outcomes under different treatments under causal inference framework.

## Usage

``` r
predict_counterfactuals(object, trt)
```

## Arguments

- object:

  a fitted [`glm`](https://rdrr.io/r/stats/glm.html) object for which
  counterfactual predictions are desired.

- trt:

  a string specifying the name of the treatment variable in the model
  formula. It must be one of the linear predictor variables used in
  fitting the `object`.

## Value

an updated `glm` object appended with an additional component
`counterfactual.predictions`.

This component contains a tibble with columns representing
counterfactual predictions for each level of the treatment variable. A
descriptive `label` attribute explains the counterfactual scenario
associated with each column.

## Details

The function works by creating new datasets from the original data used
to fit the GLM model. In these datasets, the treatment variable for all
records (e.g., patients) is set to each possible treatment level.

Predictions are then made for each dataset based on the fitted GLM
model, simulating the response variable under each treatment condition.

The results are stored in a tidy format and appended to the original
model object for further analysis or inspection.

For averaging counterfactual outcomes, apply
[`average_predictions()`](https://openpharma.github.io/beeca/reference/average_predictions.md).

## See also

[`average_predictions()`](https://openpharma.github.io/beeca/reference/average_predictions.md)
for averaging counterfactual predictions.

[`get_marginal_effect()`](https://openpharma.github.io/beeca/reference/get_marginal_effect.md)
for estimating marginal effects directly from an original
[`glm`](https://rdrr.io/r/stats/glm.html) object

## Examples

``` r
# Preparing data and fitting a GLM model
trial01$trtp <- factor(trial01$trtp)
fit1 <- glm(aval ~ trtp + bl_cov, family = "binomial", data = trial01)

# Generating counterfactual predictions
fit2 <- predict_counterfactuals(fit1, "trtp")
#> Warning: There is 1 record omitted from the original data due to missing values, please check if they should be imputed prior to model fitting.

# Accessing the counterfactual predictions
fit2$counterfactual.predictions
#> # A tibble: 267 × 2
#>      `0`   `1`
#>    <dbl> <dbl>
#>  1 0.533 0.463
#>  2 0.537 0.468
#>  3 0.481 0.413
#>  4 0.510 0.441
#>  5 0.428 0.362
#>  6 0.474 0.406
#>  7 0.490 0.421
#>  8 0.496 0.427
#>  9 0.514 0.445
#> 10 0.490 0.422
#> # ℹ 257 more rows
attributes(fit2$counterfactual.predictions)
#> $class
#> [1] "tbl_df"     "tbl"        "data.frame"
#> 
#> $row.names
#>   [1]   1   2   3   4   5   6   7   8   9  10  11  12  13  14  15  16  17  18
#>  [19]  19  20  21  22  23  24  25  26  27  28  29  30  31  32  33  34  35  36
#>  [37]  37  38  39  40  41  42  43  44  45  46  47  48  49  50  51  52  53  54
#>  [55]  55  56  57  58  59  60  61  62  63  64  65  66  67  68  69  70  71  72
#>  [73]  73  74  75  76  77  78  79  80  81  82  83  84  85  86  87  88  89  90
#>  [91]  91  92  93  94  95  96  97  98  99 100 101 102 103 104 105 106 107 108
#> [109] 109 110 111 112 113 114 115 116 117 118 119 120 121 122 123 124 125 126
#> [127] 127 128 129 130 131 132 133 134 135 136 137 138 139 140 141 142 143 144
#> [145] 145 146 147 148 149 150 151 152 153 154 155 156 157 158 159 160 161 162
#> [163] 163 164 165 166 167 168 169 170 171 172 173 174 175 176 177 178 179 180
#> [181] 181 182 183 184 185 186 187 188 189 190 191 192 193 194 195 196 197 198
#> [199] 199 200 201 202 203 204 205 206 207 208 209 210 211 212 213 214 215 216
#> [217] 217 218 219 220 221 222 223 224 225 226 227 228 229 230 231 232 233 234
#> [235] 235 236 237 238 239 240 241 242 243 244 245 246 247 248 249 250 251 252
#> [253] 253 254 255 256 257 258 259 260 261 262 263 264 265 266 267
#> 
#> $names
#> [1] "0" "1"
#> 
#> $label
#>                                                           0 
#> "Counterfactual predictions setting trtp=0 for all records" 
#>                                                           1 
#> "Counterfactual predictions setting trtp=1 for all records" 
#> 
#> $treatment.variable
#> [1] "trtp"
#> 
```
