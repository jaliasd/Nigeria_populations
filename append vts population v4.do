********************************************************************************
*	Setting up Nigeria population data from the the VTS
*	Downloaded xlsx files from 
*		http://vts.eocng.org/population/LGA?s=&l=&gender=MF&from=0&to=100
*		on 4/30/16
********************************************************************************

*			the following age disags 
/*			From 0 to 4 years old
			From 5 to 9 years old
			From 10 to 14 years old
			From 15 to 19 years old
			From 20 to 24 years old
			From 25 to 29 years old
			From 30 to 34 years old
			From 35 to 39 years old
			From 40 to 44 years old
			From 45 to 49 years old
			From 50 to 54 years old
			From 55 to 59 years old
			From 60 to 64 years old
			From 65 to 69 years old
			From 70 to 74 years old
			*/
**	Changelog
	*5/2/16 - changing from merge to append
			
			
*Set globals
global data "C:\Users\GHFP\Documents\ICPI\Nigeria\population work" 

cd "$data"

clear
foreach num of numlist 1/15 {

	import excel "population (`num').xlsx"
	ta A
**	Create disagg variable
	*convert populations to numeric
		gen ne=real(E)
		gen nf=real(F)
	*create a var for age group
	split A, generate(x_) parse(From , years old)
	*now, value x to y is in cell x_2[2]
	split x_2, parse(" to ") destring
	*values for x and y are numeric in seperate cells
	*create age cat var
	gen age=""
	local j=x_21[2]
	local k=x_22[2]
	replace age="`j'-`k'"

**	clean up the rest
		
		rename A state_code	
		rename B state	
		rename C Lga_Code	
		rename D Lga
		rename ne popfemale
		rename nf popmale
		drop if Lga_Code==""
		drop if Lga_Code=="Lga Code"
		gen lga_code=real(Lga_Code)
		drop x* E F G
**	Reshape
	reshape long pop, i(lga_code) j(gender) string

		save "ng`j'_`k'.dta", replace
		clear
		}
		*
		*at this point, you should have 15 .dta files
		*let's append!
				
		u "ng0_4.dta",clear
		
		foreach c in 5_9 ///
						10_14 ///
						15_19 ///
						20_24 ///
						25_29 ///
						30_34 ///
						35_39 ///
						40_44 ///
						45_49 ///
						50_54 ///
						55_59 ///
						60_64 ///
						65_69 ///
						70_74 {

						append using "ng`c'.dta"
 }
*
**	Some tabs
	*little cleaning
	encode state_code, gen(st_code)
*************************************************
**	lga level totals
	egen lga_pop=total(pop), by(lga_code)
**	State totals
	egen st_pop=total(pop), by(st_code)





