clear all
import delimited "C:\Users\cport\OneDrive\Desktop\EDUC1765\Mexico_Data\Data\data_main.csv"

//REPLCATION NOTES
// This file does the calculations to create the summary statistics table from my paper
// It produces readable output in the STATA editor.
// To create the table in the final paper, I copy and pasted the STATA table into ChatGPT and had it produce LATEX code. I edited the LATEX code for formatting/labelling purposes to produce the final result. 



//drop students who drop out or who don't have school type
drop if drop_rosterenlace != 0
drop if missing_gr7school != 0

//Remove students who copy
drop if copying != 0

//remove private school students
destring roster_gr7private, replace
drop if roster_gr7private != 0



//destring all the variables you need
destring math_7, replace force
destring spanish_7, replace force
destring numbersiblings, replace force
destring computerhome, replace force
destring homebooks, replace force
destring indigenous, replace force

//separate out homebooks
gen homebooks_l10 = homebooks == 10
gen homebooks_l20 = homebooks == 20
gen homebooks_l50 = homebooks == 50
gen homebooks_l100 = homebooks >= 100


//separate out mother's education
// 0, 1, 2, 3 = Primary
// 4 = Middle
// 5 = Secondary
// 6, 7, 8 = postsecondary
gen mother_primary = mothereduc <= "3" 
gen mother_middle = mothereduc == "4"
gen mother_secondary = mothereduc == "5"
gen mother_postsec = mothereduc >= "6"
gen test2 = mothereduc <= "3" 



//separate out income
// <= 2500pesos/month == 1
// 2500-2999 == 2
// 3000-7499 == 3
// >=7500 == 4,5,6
gen lowest_income = monthlyincome == "1"
gen low_income = monthlyincome == "2"
gen middle_income = monthlyincome == "3"
gen high_income = monthlyincome >= "4"

//Calculate relative distance
gen rel_dist = nearesttele - cond(nearestgeneral < nearesttechnical, nearestgeneral , nearesttechnical)

//Drop if relative distance is outside of middle 99%
summarize rel_dist, detail
keep if inrange(rel_dist, r(p1), r(p99))

//Drop if distance from primary to secondary school is > 15km
destring distance_pri_sec, replace force
keep if inrange(distance_pri_sec, 0, 15)

//More destrings
destring telescore, replace force
destring tradscore, replace force



destring roster_gr7tele, replace force
label define telelabel 0 "Traditional" 1 "Telesecundaria"
label values roster_gr7tele telelabel



//Define macro of variables that go in the table
local varlist rel_dist telescore tradscore age numbersiblings prospera female computerhome rural northern indigenous homebooks_l10 homebooks_l20 homebooks_l50 homebooks_l100 mother_primary mother_middle mother_secondary mother_postsec lowest_income low_income middle_income high_income 


collect clear
//Set labels for Top Row
collect get Var = "Mean_tele", tags(Row["."] C[2])
collect get Var = "SD_tele", tags(Row["."] C[3])
collect get Var = "Mean_trad", tags(Row["."] C[4])
collect get Var = "SD_trad", tags(Row["."] C[5])
collect get Var = "Diff", tags(Row["."] C[6])
collect get Var = "T Score", tags(Row["."] C[7])

* Loop through each variable in the list
foreach var of local varlist {
	ttest `var', by(roster_gr7tele) //run t-test
	return list
	local meantele_`var' = r(mu_2) //mu_2 = telesecundaria, mu_1 = traditional
	local meantrad_`var' = r(mu_1)  
	local sdtele_`var' = r(sd_2) 
	local sdtrad_`var' = r(sd_1) 
	local `var'_difft = r(mu_1) - r(mu_2) //calculate difference in means
	local `var'_t = r(t)
	
//	Place local variables in table spots
	collect get `var' =  `meantele_`var'', tags(C[2] Row[`var'])
	collect get `var' =  `sdtele_`var'', tags(C[3] Row[`var'])
	collect get `var' =  `meantrad_`var'', tags(C[4] Row[`var'])
	collect get `var' =  `sdtrad_`var'', tags(C[5] Row[`var'])
	collect get `var' =  ``var'_difft', tags(C[6] Row[`var'])
	collect get `var' =  ``var'_t', tags(C[7] Row[`var'])

}
//Table formatting
collect style cell Row["."], border(bottom) border(top, pattern(nil))
collect style cell, sformat(" %s ")
collect style cell, nformat(%4.2f)
collect style header C, level(hide)
collect style cell Row, smcl(text)

//Produce the table
collect layout (Row) (C)


