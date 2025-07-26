*******************************************************
* HSPI COVID-19 Health System Performance Analysis
* Countries: UK, France, Italy, Germany, Spain
* Period: Q1 2020 – Q4 2022
* Author: Anastasiia Golovchenko
*******************************************************

clear all
set more off


// Load data
use HP434.dta, clear


// Label countries
label define country_labels 1 "France" 2 "Italy" 3 "UK" 4 "Germany" 5 "Spain"
label values country country_labels
label define country_labels , add
label values country country_labels


// Data exploration
describe
codebook
summarize

misstable sum
misstable pattern

// Check correlation between main components
correlate EM GDP



*******************************************************
// ===== COMPOSITE INDEX CONSTRUCTION =====
*******************************************************

// Normalize Excess Mortality (EM)
egen EM_min = min(EM)
egen EM_max = max(EM)
gen EM_norm = (EM - EM_min) / (EM_max - EM_min)
gen EM_inv = 1 - EM_norm

// Normalize GDP Growth
egen GDP_min = min(GDP)
egen GDP_max = max(GDP)
gen GDP_norm = (GDP - GDP_min) / (GDP_max - GDP_min)

// Create Health System Performance Index
gen HS = (EM_inv + GDP_norm) / 2
sum HS


histogram HS, normal title("Histogram of Health System Index") xtitle("Health System Index") ytitle ("Density")
graph export "/Users/Ferniz/Documents/LSE /HP434/hist_HS.pdf", replace


*******************************************************
*******************************************************
// ===== ECONOMETRIC ANALYSIS =====

// Set panel structure
xtset country quarter

*******************************************************
// Model 1: Pooled OLS
*******************************************************
reg HS c.test_per_case c.ful_vac c.CFR c.ICU c.unempl c.CCI c.gov_resp
outreg2 using "HP434_Res.xlm"

// Diagnostic tests for OLS
predict yhat
predict residual, residuals
pnorm residual
graph export "/Users/Ferniz/Documents/LSE /HP434/pnorm.pdf", replace

qnorm residual
graph export "/Users/Ferniz/Documents/LSE /HP434/qnorm.pdf", replace


// Residual vs fitted plot
twoway (scatter residual yhat, mcolor(blue) msize(small)) ///
    (function y=0, range(yhat) lcolor(black)) ///
    (lfit residual yhat, lcolor(red) lpattern(dash)), ///
    title("Residual vs Fitted Plot") xtitle("Fitted Values") ytitle("Residuals") ///
    legend(order(1 "Residuals" 2 "Zero Line" 3 "Fitted Line"))
graph export "ols_residual_fitted.pdf", replace


// Test for heteroskedasticity
estat hettest

/*
Since the p-value (0.0020) is less than the conventional significance levels (e.g., 0.05 or 0.01), we reject the null hypothesis of constant variance. This suggests the presence of heteroskedasticity in regression model.
>*/


// Check multicollinearity
vif


*******************************************************
// Model 1A: Pooled OLS with robust standard errors
*******************************************************
reg HS c.test_per_case c.ful_vac c.CFR c.ICU c.unempl c.CCI c.gov_resp, robust
outreg2 using "HP434_Res.xlm"

vif

*******************************************************
*******************************************************
*** PANEL DATA MODELS =====
// Model 2: Fixed Effects
*******************************************************

xtset country quarter

xtreg HS c.test_per_case c.ful_vac c.CFR c.ICU c.unempl c.CCI c.gov_resp, fe

estimates store fixed

outreg2 using "HP434_Res.xlm"

*******************************************************
// Model 3: Random Effects
*******************************************************
xtreg HS c.test_per_case c.ful_vac c.CFR c.ICU c.unempl c.CCI c.gov_resp, re

estimates store random
outreg2 using "HP434_Res.xlm"


// Hausman test to choose between FE and RE
hausman fixed random
/*based on the Hausman test result, the fixed effects (FE) model is preferred over the random effects (RE) model. The test rejects the null hypothesis (H0) that the difference in coefficients is not systematic, with a p-value of 0.0095 (Prob > chi2 = 0.0095), which is less than the conventional significance level of 0.05.
Therefore, we should proceed with the fixed effects model and perform the diagnostic tests on the FE model.
P-value (Prob > chi2): The p-value associated with the test statistic is 0.0032. Since the p-value (0.0032) is less than the conventional significance levels (e.g., 0.05 or 0.01), we reject the null hypothesis. This means that the difference in coefficients between the fixed-effects  and random-effects models is systematic, and the fixed-effects model is preferred over the random-effects model.*//


// Diagnostic tests for FE model
xtreg HS c.test_per_case c.ful_vac c.CFR c.ICU c.unempl c.CCI c.gov_resp, fe
predict residual, e


// Normality tests
swilk residual
histogram fe_residual, normal title("FE Model Residuals")

qnorm fe_residual
graph export "fe_qnorm.pdf", replace

pnorm fe_residual
graph export "fe_pnorm.pdf", replace

// Test for heteroskedasticity in panel data
xttest3

// FE model with robust standard errors
xtreg HS c.test_per_case c.ful_vac c.CFR c.ICU c.unempl c.CCI c.gov_resp, fe robust
outreg2 using "regression_results.xlsx", append

*******************************************************
// ===== COUNTRY DUMMY MODEL =====
*******************************************************

// Create country dummies (France as reference)
tab country, gen(country_dummy)

* Create interaction terms for each country and explanatory variable
* Create interaction terms for each country and explanatory variable
forvalues i = 1/5 {
    gen int_test_per_case_`i' = country_dummy`i' * test_per_case
    gen int_ful_vac_`i' = country_dummy`i' * ful_vac
    gen int_CFR_`i' = country_dummy`i' * CFR
    gen int_ICU_`i' = country_dummy`i' * ICU
    gen int_unempl_`i' = country_dummy`i' * unempl
    gen int_CCI_`i' = country_dummy`i' * CCI
    gen int_gov_resp_`i' = country_dummy`i' * gov_resp
}

	
reg HS country_dummy2-country_dummy5 c.test_per_case c.ful_vac c.CFR c.ICU c.unempl c.CCI c.gov_resp int_test_per_case_2-int_test_per_case_5 int_ful_vac_2-int_ful_vac_5 int_CFR_2-int_CFR_5 int_ICU_2-int_ICU_5 int_unempl_2-int_unempl_5 int_CCI_2-int_CCI_5 int_gov_resp_2-int_gov_resp_5

// Second regression with robust standard errors
reg HS country_dummy2-country_dummy5 c.test_per_case c.ful_vac c.CFR c.ICU c.unempl c.CCI c.gov_resp int_test_per_case_2-int_test_per_case_5 int_ful_vac_2-int_ful_vac_5 int_CFR_2-int_CFR_5 int_ICU_2-int_ICU_5 int_unempl_2-int_unempl_5 int_CCI_2-int_CCI_5 int_gov_resp_2-int_gov_resp_5, robust
	

// Diagnostic tests for country dummy model
predict cd_yhat
predict cd_residual, residuals

pnorm cd_residual
graph export "dummy_pnorm.pdf", replace

qnorm cd_residual
graph export "dummy_qnorm.pdf", replace

// Residual vs fitted plot for dummy model
twoway (scatter cd_residual cd_yhat, mcolor(blue) msize(small)) ///
    (function y=0, range(cd_yhat) lcolor(black)), ///
    title("Country Dummy Model: Residual vs Fitted") ///
    xtitle("Fitted Values") ytitle("Residuals")
graph export "dummy_residual_fitted.pdf", replace

// Check multicollinearity
vif

// Attempt heteroskedasticity test (will fail with robust standard errors)
estat hettest

capture log close
