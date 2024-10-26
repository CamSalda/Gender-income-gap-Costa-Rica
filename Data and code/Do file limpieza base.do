clear mata
capture log close
clear

cd "C:\Users\camil\OneDrive\Documentos\Artículos académicos\Gender income gap Costa Rica\Datos y análisis\Base de datos"

use "Raw ECE Q1 2023"

* Selection of the variables *
keep ID_AMO ID_VIVIENDA ID_HOGAR ID_LINEA Consecutivo Relacion_parentesco Sexo Edad Estado_conyugal Educacion_nivel_grado Cod_rama Cod_rama_5digitos Horas_efectivas_principal Horas_normales_principal Region Zona Amos_educacion Nivel_educativo Condicion_actividad Posicion_empleo Establecimiento_independiente Hora_normal_total Horas_efectivas_total Tamano_empresa Sector_institucional Rama_actividad Sector_actividad Condicion_aseguramiento Formalidad_informalidad Empleo_secundario Ingreso_principal Regimen_pension Mayor_15 Factor_ponderacion


*****FIX THE DATABASE********
***SELECTION
 
 *num_children
//To count the number of children: First I generate a unique identificator of the household
generate id_household = Consecutivo+(ID_VIVIENDA/100)+(ID_HOGAR/1000)
 //Then I create a dummy for the children
generate children =1 if Edad<15
bys id_household: egen num_children=count(children) 


*mar_status
generate mar_status=3 if Estado_conyugal==6
replace mar_status=1 if Estado_conyugal==2 | Estado_conyugal==7
replace mar_status=2 if Estado_conyugal==1 | Estado_conyugal==8
replace mar_status=3 if Estado_conyugal==6
replace mar_status=4 if Estado_conyugal==5
replace mar_status=5 if Estado_conyugal==3 | Estado_conyugal==4
label define marital_status 1 "Casado (a)" 2 "Conviviente" 3 "Soltero (a)" 4 "Viudo (a)" 5 "Separado (a) o divorciado (a)"
label values mar_status marital_status


***INCOME EQUATION

*i_labor
//The values are transform into USD using the average exchange rate of the quarter
generate i_labor= Ingreso_principal

*ihour_labor
 generate ihour_labor= i_labor/(4*Horas_normales_principal)
 
*education
rename Amos_educacion education
replace education=. if education>25
 
*hours 
rename Horas_normales_principal hours
replace hours=. if hours>140
 
 
*Occupational position 
rename Posicion_empleo occu_position
 
*Size of establishment 
rename Tamano_empresa size_estab
 
 
*pay_pension
generate pay_pension=2 if Regimen_pension==0
replace pay_pension=1 if Regimen_pension==1 | Regimen_pension==2
replace pay_pension=2 if Regimen_pension==0
replace pay_pension=2 if missing(Regimen_pension) & Condicion_actividad==1
label define cot_pension 1 "si cotiza" 2 "no cotiza" 3 "ya es pensionado"
label values pay_pension cot_pension
 
*pay_health
generate pay_health=1 if Condicion_aseguramiento==1
replace pay_health=2 if Condicion_aseguramiento==0
replace pay_health=3 if Condicion_aseguramiento==9
label define pay_healthl 1 "Sí" 2 "No" 3 "No"
label values pay_health pay_healthl
 
***BOTH***
*gender
rename Sexo gender
replace gender=0 if gender==1
replace gender=1 if gender==2
label define genderl 0 "Man" 1 "Women"
label values gender genderl
 
*age
rename Edad age
 
*rel_headhouse
generate rel_headhouse=1 if Relacion_parentesco==1
replace rel_headhouse=2 if Relacion_parentesco==2 | Relacion_parentesco==16
replace rel_headhouse=3 if Relacion_parentesco==3 | Relacion_parentesco==14
replace rel_headhouse=4 if Relacion_parentesco==5
replace rel_headhouse=5 if Relacion_parentesco==4 | Relacion_parentesco==6 | Relacion_parentesco==7 | Relacion_parentesco==8 | Relacion_parentesco==9 | Relacion_parentesco==10 | Relacion_parentesco==11 | Relacion_parentesco==12 | Relacion_parentesco==13 | Relacion_parentesco==15 | Relacion_parentesco==17    
label define rel_headhousel 1 "Jefe de hogar" 2 "Pareja, esposo(a), cónyuge" 3 "Hijo(a), hijastro(a)" 4 "Nieto(a)" 5 "otro"
label values rel_headhouse rel_headhousel
 
*informal
rename Formalidad_informalidad informal
replace informal=0 if informal==1
replace informal=1 if informal==2

*region 
rename Region region

*empl_condition
generate empl_condition=1 if Condicion_actividad==1
replace empl_condition=2 if Condicion_actividad==2
replace empl_condition=3 if Condicion_actividad==3 
replace empl_condition=4 if missing(Mayor_15) 
label define empl_conditionl 1 "Ocupado" 2 "Desocupado" 3 "Inactivo" 4 "Menor de 15 años"
label values empl_condition empl_conditionl
 
*weights
rename Factor_ponderacion surv_weight
 

 
 
***Label variables***
label variable gender "gender(1=woman)"
label variable age age 
label variable education "Years of education"
label variable surv_weight "Survey weight factor"
label variable hours "Weekly hours worked"
label variable i_labor "Monthly labor income"
label variable mar_status "Marital status"
label variable ihour_labor "Labor income per hour worked"
label variable informal "Informal employment(1=informal) "
label variable pay_pension "Payment to pension system"
label variable pay_health "Payment to health system"
label variable rel_headhouse "Relationship to the head of household"
label variable region "Geographical region"
label variable surv_year "Year of the survey"
label variable num_children "Number of children in the household"
label variable country "Country"
***Label values
label define gender 1 "Man" 2 "Woman"
label values gender gender
label define mar_st 1 "Married" 2 "Living together" 3 "Single" 4 "Widowed" 5 "Divorced or separated"
label values mar_status mar_st 
label define rel_head 1 "Head of household" 2 "Spouse or partner" 3 "Child" 4 "Grandchild" 5 "Other"
label values rel_headhouse rel_head
label define informal  0 "Formal" 1 "Informal"
label values informal informal
label define health 1 "Yes " 2 "No" 3 "No answer"
label values pay_health health 
label define pension 1 "Yes " 2 "No" 3 "No answer" 4 "Already retired"
label values pay_pension pension
label values rel_headhouse rel_head


 save "ECE_Q1_2023_pulida.dta", replace
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 