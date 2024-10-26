clear mata
capture log close
clear

cd "C:\Users\camil\OneDrive\Documentos\Artículos académicos\Gender income gap Costa Rica\Datos y análisis\Base de datos"

use "C:\Users\camil\OneDrive\Documentos\Artículos académicos\Gender income gap Costa Rica\Datos y análisis\Base de datos\ECE_Q1_2023_pulida.dta"

gen surv_year= 2023

****** ECONOMETRIC ESTIMATIONS
****MINCER EQUATION
*We take natural logarithm of the dependent variable (hourly labor income)
*-> So we can analyze the results like semi-elasticities and avoid some problems like heteroskedasticity
gen lihour_labor=ln(ihour_labor)
*We change or create variables to estimate several especifications of the model. 
*Proxy of experience (experience=age-education-5)
gen experience=age-education-5
gen experience2=experience*experience
*Square of education
gen education2=education*education
*Interaction lineal
gen gen_educa=gender*education
gen gen_exper=gender*experience
*Interaction square 
gen gen_educa2=gender*education2
gen gen_exper2=gender*experience2


*We generate a variable in order to identify the group of worker selected to analyze the earnings gaps 
*-> Following the approach of Juhn, Murphy & Pierce (1993) the criteria is:
*-> Paid workers between 18 and 55 years old, who have worked at least 12 hours per week and have 
*-> a daily labor income at least equal to one dolar, with ana average exchange rate for Costa Rica of 567.17 colones per dolar in the first quarter of 2023.
gen sub_sample=1 if (ihour_labor>70.89 & ihour_labor!=.) & (age>17 & age<56) & (hours>11 & hours!=.)
replace sub_sample=0 if sub_sample==. & (hours!=.)


*We run the Mincer equation
*For every estimation we are going to consider the Akaike's information criterion and the Bayesian
*-> information criterion in order to check the especification that could fix better the estimation.


*********************************************************************************1
*Lineal education without control of household variables 
reg lihour_labor gender education experience informal i.region [w=surv_weight] if sub_sample==1
estat ic 

******************************************************************************** 2
 *Lineal education with control of household variables 
 ***2018
reg lihour_labor gender education experience informal i.mar_status  i.rel_headhouse ///
	num_children i.region [w=surv_weight]  if sub_sample==1
estat ic 

***Funtional form: We check preliminarly if including education and experience to square is or not relevant
*-> This shows if there is a non-linear relation between those variables and wages. 
ssc install binscatter
binscatter lihour_labor education if sub_sample==1, line(lfit) // using linear fitting 
binscatter lihour_labor education if sub_sample==1, line(qfit) // using quadratic line fitting 


******************************************************************************** 3
****Mincer's equation with quadratic education and experience without household controls
reg lihour_labor gender education education2 experience experience2 informal  i.region [w=surv_weight] if sub_sample==1
estat ic 
test education education2

estat ic 
test education education2


******************************************************************************** 4
****Mincer's equation with quadratic education and experience with household controls
*Square education and experience with control of household variables 
reg lihour_labor gender education education2 experience experience2 informal ///
	i.mar_status  i.rel_headhouse num_children i.region [w=surv_weight] if sub_sample==1
estat ic 
test education education2

**Only square education and experience 
reg lihour_labor gender  education2  experience2 informal ///
	i.mar_status  i.rel_headhouse num_children i.region [w=surv_weight] if sub_sample==1
estat ic 


**Only square education and experience 
reg lihour_labor gender  education2  experience2 informal ///
	i.mar_status  i.rel_headhouse num_children i.region [w=surv_weight] if sub_sample==1
estat ic 


*********************************************************************************5
***Mincer's equations with interactions of gender with education and experience, different especifications
*Interaction lineal with control of household variables
reg lihour_labor gender education gen_educa experience gen_exper informal i.mar_status ///  
	i.rel_headhouse num_children i.region [w=surv_weight] if sub_sample==1
estat ic 
test gen_educa
test gen_exper
test gen_educa gen_exper    

****We use the results of interaction to have a preliminary approach to the difference level of returns to
*-> education between women and men
scalar b_education = _b[education]
scalar b_interac = _b[ gen_educa]
gen li_educa_h= b_education*education if sub_sample==1
gen li_educa_w=(b_education+b_interac)*education if sub_sample==1
label variable li_educa_h men
label variable li_educa_w women
*Graph of difference in returns of education by gender
twoway (line li_educa_h education, sort lcolor(black)) (line li_educa_w education, sort lcolor(cranberry)), ytitle(Expected log of labor income) ylabel(, nogrid) title(Returns to education by gender) subtitle(2023) note(Source: Own elaboration based on household survey (Dane, 2021)) legend(on) graphregion(fcolor(white) ifcolor(white)) plotregion(fcolor(white) ifcolor(white))	


***Now we can use the coefficient of gender and the fact that the returns of women are higher to simulate
*-> the progressive effect of education on the reduction of the gaps
scalar b_gender = _b[ gender]
gen gap_1=b_gender + b_interac*education  if sub_sample==1
label variable gap_1 "Estimated earning gap"
capture label variable education education
twoway (line gap_1 education, sort lcolor(cranberry)), ytitle(Expected log of labor income) yline(0, lpattern(dash) lcolor(black)) ylabel(, nogrid) title(Earning gender gap and education (interaction)) subtitle(2023) note(Source: Own elaboration based on household survey (Dane, 2021)) legend(off) graphregion(fcolor(white) ifcolor(white)) plotregion(fcolor(white) ifcolor(white))


*********************************************************************************6
*Interaction square with control of household variables
*2018
reg lihour_labor gender education education2 gen_educa gen_educa2 experience experience2 ///
	gen_exper gen_exper2 informal i.mar_status ///  
	i.rel_headhouse num_children i.region [w=surv_weight] if sub_sample==1
estat ic 
test gen_educa gen_educa2
test gen_exper gen_exper2
test gen_educa gen_exper
test gen_educa2 gen_exper2

**** Difference level of returns to education between women and men. Square
scalar drop _all
scalar b2_education = _b[education]
scalar b2_education2 = _b[education2]
scalar b2_interac = _b[ gen_educa]
scalar b2_interac2 = _b[ gen_educa2]
gen li_educas_h=(b2_education*education) + (b2_education2*education2) if sub_sample==1
gen li_educas_w=((b2_education+b2_interac)*education) + ((b2_education2+b2_interac2)*education2) if sub_sample==1
label variable li_educas_h men
label variable li_educas_w women
twoway (line li_educas_h education, sort lcolor(black)) (line li_educas_w education, sort lcolor(cranberry)), ytitle(Expected log of labor income) ylabel(, nogrid) title(Returns to education by gender. Square) subtitle(Costa Rica 2021) note(Source: Own elaboration based on household survey (INEC, 2021)) legend(on) graphregion(fcolor(white) ifcolor(white)) plotregion(fcolor(white) ifcolor(white))

*-> the progressive effect of education on the reduction of the gaps
scalar b_gender = _b[ gender]
gen gap_2= (b_gender) + (b2_interac*education) + (b2_interac2*education2) if sub_sample==1
label variable gap_2 "Estimated earning gap"
capture label variable education education
twoway (line gap_2 education, sort), ytitle(Expected log of labor income) yline(0, lpattern(dash) lcolor(black)) ylabel(, nogrid) title(Earning gender gap and education (interaction square)) subtitle(Costa Rica 2021) note(Source: Own elaboration based on household survey (INEC, 2021)) legend(off) graphregion(fcolor(white) ifcolor(white)) plotregion(fcolor(white) ifcolor(white))


****Optional to check better fitting: the last model only with square education, experience and interactions
*Interaction ONLY square with control of household variables
*2018
reg lihour_labor gender  education2  gen_educa2  experience2 ///
	 gen_exper2 informal i.mar_status ///  
	i.rel_headhouse num_children i.region [w=surv_weight] if sub_sample==1
estat ic 
test  gen_educa2
test  gen_exper2
test gen_educa2 gen_exper2

**** Difference level of returns to education between women and men. Square
scalar drop _all
scalar b2_education2 = _b[education2]
scalar b2_interac2 = _b[ gen_educa2]
scalar b_gender = _b[ gender]
gen li_educas2_h=  (b2_education2*education2) if sub_sample==1
gen li_educas2_w= (b_gender) + ((b2_education2+b2_interac2)*education2) if sub_sample==1
label variable li_educas2_h men
label variable li_educas2_w women


*Graph of difference in returns of education by gender
twoway (line li_educas2_h education, sort lcolor(black)) (line li_educas2_w education, sort lcolor(cranberry)), ytitle(Expected log of labor income) ylabel(, nogrid) title(Returns to education by gender) subtitle(Costa Rica 2021) note(Source: Own elaboration based on household survey (INEC, 2021)) legend(on) graphregion(fcolor(white) ifcolor(white)) plotregion(fcolor(white) ifcolor(white))


****OAXACA-BLINDER DECOMPOSITION****
***First we install the command "oaxaca" available to compute the decomposition
ssc install oaxaca, replace
***OAXACA-BLINDER 
**In this methodology we are going to estimate the same especifications used in the Mincer's equation. 
*->But in this case the interaction term does not make sense because precisely the decomposition estimate
*-> different coefficientes for each group (gender)

**Creating control regional variables. The command oaxaxa does not recognize i.varible like a set of ///
*->dummies therefore, we need to create each dummy variable. It is easier with tabulate
*region
tabulate region, generate(region_d)
rename region_d1 region_base
*mar_status 
tabulate mar_status, generate(mar_status_d)
rename mar_status_d1 mar_status_base
*rel_headhouse
tabulate rel_headhouse, generate(rel_headhouse_d)
rename rel_headhouse_d1 rel_headhouse_base

*Lineal education without control of household variables 
bysort surv_year: oaxaca lihour_labor education experience informal region_d* if sub_sample==1  ///
	[w=surv_weight], by(gender) noisily swap d xb
*Lineal education with control of household variables 
bysort surv_year: oaxaca lihour_labor  education experience informal mar_status_d*  rel_headhouse_d* ///
	num_children region_d* if sub_sample==1 [w=surv_weight],  by(gender) noisily swap d xb
*Square education and experience without control of household variables 
bysort surv_year: oaxaca lihour_labor education education2 experience experience2 informal region_d*  ///
	if sub_sample==1 [w=surv_weight], by(gender) noisily swap d xb
*Square education and experience with control of household variables 
bysort surv_year: oaxaca lihour_labor education education2 experience experience2 informal ///
	mar_status_d*  rel_headhouse_d* num_children region_d* if sub_sample==1 [w=surv_weight], by(gender) noisily swap d xb


***QUANTILE REGRESSION
**We are going to estimate the quantile regression in order to check potencial differences of the 
*->earnings gender gaps in differents points of the conditional distribution. 
***Fisrt we can estimate the quantile regression for the whole model, specifically considering the 
*-> quantiles 10 25 50 75 and 90
***Later we need to install the command qrqreg that is used to estimate the gender gap and its graphs 
*-> the result considering only the variable of interes (gender) and its confidence intervals. 
ssc install grqreg
forvalues i=05(5)95 {
	if (`i'==10) | (`i'==25) | (`i'==50) | (`i'==75) | (`i'==90) {
	qreg lihour_labor gender education education2   experience ///
	experience2  informal  mar_status_d*  rel_headhouse_d* num_children region_d* ///
	  if sub_sample==1, quantile(`i') wlsiter(400)
	}
}
grqreg gender, qmin(.025) qmax(.975) qstep(.05) ci seed(121) quantile(5 10 15 20 25 30 35 40 45 50 55 60 65 70 75 80 85 90 95) ols olsci list






