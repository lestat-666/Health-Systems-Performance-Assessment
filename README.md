# Health-Systems-Performance-Assessment

## Overview
Panel data analysis evaluating health system performance across 5 European countries (UK, France, Italy, Germany, Spain) in addressing the health and economic consequences of COVID-19

## Key Features
- **Composite Performance Index**: Health System Performance Index combining GDP growth and inverted excess mortality
- **Panel Data Analysis**: Quarterly data from Q1 2020 to Q4 2022 across 5 countries (60 observations)
- **Multiple Model Comparison**: Pooled OLS → Panel Fixed Effects → Country Fixed Effects
- **Comprehensive Indicators**: 9 variables covering pandemic response, health outcomes, and economic impact

## Methodology
- Multi-source data integration: Our World in Data, OECD, Oxford COVID-19 Government Response Tracker
- Min-max normalization for composite index construction with equal weighting
- Econometric modeling with Hausman test validation and robust standard errors
- Panel fixed effects to control for unobserved country-specific heterogeneity

## Key Results
- **Progressive model improvement**: Pooled OLS (R² = 0.292) → Panel FE (R² = 0.483) → Country FE (R² = 0.936)
- **Country ranking**: Germany (highest) → Italy → Spain → UK → France (lowest performance)
- **Critical factors**: Testing capacity (+), vaccination coverage (+), consumer confidence (+), case fatality rate (-), ICU occupancy (-), unemployment (-)
- **Statistical validation**: All key variables significant at 95% confidence level

## Technologies
- **Statistical Software**: Stata (panel data econometrics, fixed effects modeling)
- **Analysis**: Panel regression, composite index construction, diagnostic testing

## Author
**Anastasiia Golovchenko** 
