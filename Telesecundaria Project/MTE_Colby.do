clear all
import delimited "C:\Users\cport\OneDrive\Desktop\EDUC1765\Mexico_Data\Data\data_main.csv"

//REPLCATION NOTES
// This file does the calculations to create the Propensity Score Table and MTE Graphs from my paper
// It produces readable output in the STATA editor.
// To create Table 3 in the final paper, I copy and pasted the STATA table into ChatGPT and had it produce LATEX code. I edited the LATEX code for formatting/labelling purposes to produce the final result. 

//drop students who drop out or who don't have school type
drop if drop_rosterenlace != 0
drop if missing_gr7school != 0

//remove private school students
destring roster_gr7private, replace
drop if roster_gr7private != 0

//Calculate relative distance
gen rel_dist = nearesttele - cond(nearestgeneral < nearesttechnical, nearestgeneral , nearesttechnical)

//Remove outlier reldist
summarize rel_dist, detail
keep if inrange(rel_dist, -20, 20)

//Remove too far secondary schools (means they might've moved)
destring distance_pri_sec, replace force
keep if inrange(distance_pri_sec, 0, 20)

//Drop copycats
drop if copying != 0

//Double check count here! I believe it should be 134502 (this aligns with Prep_Repo.R)

destring numbersiblings, replace force

destring telescore, replace force

destring tradscore, replace force

destring roster_gr7tele, replace force

destring spanish_7, replace force

destring math_7, replace force

destring math_6, replace force

destring female, replace force

destring prospera, replace force

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
//looks like 0, 1, 2, 3 = Primary
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

//This gets the results for Table 3: The propensity score model
//The actual results of the probit regression aren't really interpretable so we have to run margins to calculate the marginal effects of the regressors. This means that if I wer to hold all of the regressors constant except one, the marginal effect would tell me how much the conditional probability of the outcome changes
probit roster_gr7tele rel_dist math_6 spanish_6 age numbersiblings prospera female computerhome rural northern indigenous homebooks_l20 homebooks_l50 homebooks_l100 mother_middle mother_secondary mother_postsec low_income middle_income high_income
margins, dydx(*) atmeans

// Actually run the MTE functions 
//If you look at the first table output, it lines up with the probit estimation from earlier (still not really interpretable it turns out)
//marginal treatment effect on Spanish_7 scores (parametric) - No Tradscore
margte spanish_7 math_6 spanish_6 age numbersiblings prospera female computerhome rural northern indigenous homebooks_l20 homebooks_l50 homebooks_l100 mother_middle mother_secondary mother_postsec low_income middle_income high_income, treatment(roster_gr7tele rel_dist math_6 spanish_6 age numbersiblings prospera female computerhome rural northern indigenous homebooks_l20 homebooks_l50 homebooks_l100 mother_middle mother_secondary mother_postsec low_income middle_income high_income) level(90) first 

//maringal treatment effect on Math_7 scores (parametric) - No Tradscore
margte math_7 math_6 spanish_6 age numbersiblings prospera female computerhome rural northern indigenous homebooks_l20 homebooks_l50 homebooks_l100 mother_middle mother_secondary mother_postsec low_income middle_income high_income, treatment(roster_gr7tele rel_dist math_6 spanish_6 age numbersiblings prospera female computerhome rural northern indigenous homebooks_l20 homebooks_l50 homebooks_l100 mother_middle mother_secondary mother_postsec low_income middle_income high_income) level(90) first 

//marginal treatment effect on Spanish_7 scores (parametric) - Yes Tradscore
margte spanish_7 math_6 spanish_6 tradscore age numbersiblings prospera female computerhome rural northern indigenous homebooks_l20 homebooks_l50 homebooks_l100 mother_middle mother_secondary mother_postsec low_income middle_income high_income, treatment(roster_gr7tele rel_dist math_6 spanish_6 age numbersiblings prospera female computerhome rural northern indigenous homebooks_l20 homebooks_l50 homebooks_l100 mother_middle mother_secondary mother_postsec low_income middle_income high_income) level(90) first  


//marginal treatment effect on Math_7 scores (parametric) - Yes Tradscore
margte math_7 math_6 spanish_6 tradscore age numbersiblings prospera female computerhome rural northern indigenous homebooks_l20 homebooks_l50 homebooks_l100 mother_middle mother_secondary mother_postsec low_income middle_income high_income, treatment(roster_gr7tele rel_dist math_6 spanish_6 age numbersiblings prospera female computerhome rural northern indigenous homebooks_l20 homebooks_l50 homebooks_l100 mother_middle mother_secondary mother_postsec low_income middle_income high_income) level(90) first common  
