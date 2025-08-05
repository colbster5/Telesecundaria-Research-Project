clear
. import delimited "C:\Users\cport\OneDrive\Desktop\EDUC1765\Mexico_Data\Data\data_main.csv"

//REPLCATION NOTES
// This file does the calculations to create Exam Scores table from my paper
// It produces readable output in the STATA editor.
// To create the table in the final paper, I copy and pasted the STATA table into ChatGPT and had it produce LATEX code for the table. I slightly edited the LATEX code for formatting purposes to produce the final result. 

//Drop students who drop out or who don't have school type
drop if drop_rosterenlace != 0
drop if missing_gr7school != 0

//Remove students who copy
drop if copying != 0

//Remove private school students
destring roster_gr7private, replace
drop if roster_gr7private != 0

//Calculate relative distance
gen rel_dist = nearesttele - cond(nearestgeneral < nearesttechnical, nearestgeneral , nearesttechnical)

//Drop if relative distance is outside of middle 99%
summarize rel_dist, detail
keep if inrange(rel_dist, r(p1), r(p99))

//Drop if distance from primary to secondary school is > 15km
destring distance_pri_sec, replace force
keep if inrange(distance_pri_sec, 0, 15)


// Destrings 
destring math_6, replace force
destring math_7, replace force
destring math_8, replace force
destring math_9, replace force

 
destring spanish_6, replace force
destring spanish_7, replace force
destring spanish_8, replace force
destring spanish_9, replace force
destring roster_gr7tele, replace force


// for calculating differences locally 
// https://stackoverflow.com/questions/52306513/calculate-difference-in-means

collect clear
//Set labels for top row
collect get Var = "All", tags(Row["."] M[1])
collect get Var = "Traditional", tags(Row["."] M[2])
collect get Var = "Telesecundaria", tags(Row["."] M[3])
collect get Var = "Difference", tags(Row["."] M[4])
collect get Var = "All", tags(Row["."] S[1])
collect get Var = "Traditional", tags(Row["."] S[2])
collect get Var = "Telesecundaria", tags(Row["."] S[3])
collect get Var = "Difference", tags(Row["."] S[4])

//Loop through n = 6,7,8,9 (the grade levels)
foreach n of numlist 6/9 {
//	calculate means for math scores in all schools, telesecundaria, traditional
	sum math_`n', de
	return list
	local math_all = r(mean)
	di `math_all'
	sum math_`n' if roster_gr7tele == 1, de
	return list
	local math_tele = r(mean)
	di `math_tele'
	sum math_`n' if roster_gr7tele == 0, de
	return list
	local math_trad = r(mean)
	di `math_trad'
//	calculate difference in means
	local math_diff = `math_tele' - `math_trad'
	di `math_diff'
//	Place values in table
	collect get Grade_`n' =  `math_all', tags(M[1] Row[`n'])
	collect get Grade_`n' =  `math_trad', tags(M[2] Row[`n'])
	collect get Grade_`n' =  `math_tele', tags(M[3] Row[`n'])
	collect get Grade_`n' =  `math_diff', tags(M[4] Row[`n'])
//	calculate means for spanish scores in all schools, telesecundaria, traditional
	sum spanish_`n', de
	return list
	local spanish_all = r(mean)
	di `spanish_all'
	sum spanish_`n' if roster_gr7tele == 1, de
	return list
	local spanish_tele = r(mean)
	di `spanish_tele'
	sum spanish_`n' if roster_gr7tele == 0, de
	return list
	local spanish_trad = r(mean)
	di `spanish_trad'
//	Calculate difference in means
	local spanish_diff = `spanish_tele' - `spanish_trad'
	di `spanish_diff'
//	Place values in table
	collect get Grade_`n' =  `spanish_all', tags(S[1] Row[`n'])
	collect get Grade_`n' =  `spanish_trad', tags(S[2] Row[`n'])
	collect get Grade_`n' =  `spanish_tele', tags(S[3] Row[`n'])
	collect get Grade_`n' =  `spanish_diff', tags(S[4] Row[`n'])
}
//Table formatting
collect label dim M "Math"
collect label dim S "Spanish"
collect style header M, title(label)
collect style header S, title(label)
collect style column, dups(center)
collect style header M, level(hide)
collect style header S, level(hide)
collect style cell Row["."], border(bottom) border(top, pattern(nil))
collect style cell, sformat(" %s ")
collect style cell, nformat(%4.1f)
collect style cell Row, smcl(text)
collect label dim Row ""
collect label levels Row 6 "Grade 6" 7 "Grade 7" 8 "Grade 8" 9 "Grade 9"

// Produce the Table
collect layout (Row) (M S)


