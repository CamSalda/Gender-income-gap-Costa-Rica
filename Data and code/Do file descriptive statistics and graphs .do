clear mata
capture log close
clear

cd "C:\Users\camil\OneDrive\Documentos\Artículos académicos\Gender income gap Costa Rica\Datos y análisis\Base de datos"

use "C:\Users\camil\OneDrive\Documentos\Artículos académicos\Gender income gap Costa Rica\Datos y análisis\Base de datos\ECE_Q1_2023_pulida.dta"

****Generate var****
gen experience=age-education-5

gen sub_sample=1 if (ihour_labor>70.89 & ihour_labor!=.) & (age>17 & age<56) & (hours>11 & hours!=.)
replace sub_sample=0 if sub_sample==. & (hours!=.)

***Note 0=Men and 1=Women*** 

sum age gender education informal i_labor ihour_labor hours experience

sum age education informal i_labor ihour_labor hours experience if gender==0 
sum age education informal i_labor ihour_labor hours experience if gender==1

gen ln_i_labor = log(i_labor)
gen ln_education = log(education)
gen ln_ihour_labor = log(ihour_labor)





****Graph 1****
twoway kdensity ln_ihour_labor if gender==0 || kdensity ln_ihour_labor if gender==1

****Graph 2****
twoway kdensity ln_i_labor if gender==0 || kdensity ln_i_labor if gender==1




kdensity i_labor
**# Bookmark #1



***Analysis subsabmple
  
sum age gender education informal i_labor ihour_labor hours experience if sub_sample==1

sum age education informal i_labor ihour_labor hours experience if gender==0 & sub_sample==1
sum age education informal i_labor ihour_labor hours experience if gender==1 & sub_sample==1







****Gender GAP graph: Graph 3****
clear mata
capture log close
clear

import excel "C:\Users\camil\OneDrive\Documentos\Artículos académicos\Gender income gap Costa Rica\Datos y análisis\Gender gaps indicator .xlsx", sheet("Sheet1") firstrow clear

graph bar GenderGAP, over(Specification)