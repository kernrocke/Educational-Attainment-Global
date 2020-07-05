

clear
cls

**  GENERAL DO-FILE COMMENTS
**  Program:		education_002
**  Project:      	Education Attainment
**  Analyst:		Kern Rocke
**	Date Created:	04/07/2020
**	Date Modified: 	04/07/2020
**  Algorithm Task: Trend in Education Attainment by Caribbean Country


** DO-FILE SET UP COMMANDS
version 13
clear all
macro drop _all
set more 1
set linesize 150


** Set working directories: this is for DATASET and LOG files
local datapath "/Users/kernrocke/OneDrive - The University of the West Indies"
local dopath "/Users/kernrocke/OneDrive - The University of the West Indies/Github Repositories"


*Load in data from data source
import delimited "`datapath'/Manuscripts/Education_Attainment/IHME_GLOBAL_EDUCATIONAL_ATTAINMENT_1970_2015_Y2015M04D27.CSV", varnames(1) 

/*
Data Source
http://ghdx.healthdata.org/record/ihme-data/global-educational-attainment-1970-2015
*/
*-------------------------------------------------------------------------------
					*DATA CLEANING

*Remove regions from dataset - use loop for ease of analysis and management
foreach x in 1 2 3 4 5 6 7 {
	drop if location_code == "S`x'"
	
	}
foreach x in 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 {
	drop if location_code == "R`x'"
	
	}

drop if location_code == "G"	

*-------------------------------------------------------------------------------

*Merging data with iso mapping file

rename location_code country_iso
rename location_name country_name

*Save data
save "`datapath'/Manuscripts/Education_Attainment/education_attainment", replace

preserve


encode metric, gen(metric_1)
drop metric
rename metric_1 metric
order metric, before(unit)

lowess mean year if metric == 1, gen(lowi_edu)nog
lowess mean year if metric == 2, gen(lowi_pop)nog

keep if metric == 1

*Use both male annd female --- Note: This can change for analysis for males and females (ensure age range is considered)
keep if sex_id == 3

#delimit ;
	graph twoway 
		(line mean year if country_name == "Barbados" , clw(0.25) clc(blue))
		(line mean year if country_name == "Jamaica" , clw(0.25) clc(green))
		(line mean year if country_name == "Trinidad and Tobago" , clw(0.25) clc(red))
		(line mean year if country_name == "The Bahamas" , clw(0.25) clc(brown))
		(line mean year if country_name == "Dominica" , clw(0.25) clc(purple))
		(line mean year if country_name == "Guyana" , clw(0.25) clc(pink))
		(line mean year if country_name == "Antigua and Barbuda" , clw(0.25) clc(gold))
		(line mean year if country_name == "Saint Lucia" , clw(0.25) clc(maroon))
		(line mean year if country_name == "Saint Vincent and the Grenadines" , clw(0.25) clc(gs0))
		(line mean year if country_name == "Belize" , clw(0.25) clc(orange))

		,
		ysize(6) xsize(10)
		plotregion(c(gs16) ic(gs16) ilw(thin) lw(thin)) 
		graphregion(color(gs16) ic(gs16) ilw(thin) lw(thin)) 
		
		xlab(1970(5)2015,
		labs(3) nogrid glc(gs12) angle(0))
		xtitle("Year", size(3) margin(t=5))
		xmtick(1970(1)2015)
		
		ylab(2(1)14, axis(1) labs(3) nogrid glc(gs12) angle(0) format(%9.1f))
	    ytitle("Year of Education Attained", axis(1) size(3) margin(r=3)) 
		ytick(2(0.5)12)
		ymtick(2(0.5)12)
		
		title("Years of Educational Attainment in the Caribbean", size(5) c(gs0))
		subtitle("Aged 25 years plus", size(3) c(gs0))
		
		legend(nobox size(2) fcolor(gs16) position(6) colf cols(6)
		order(1 "Barbados" 2 "Jamaica" 3 "Trinidad and Tobago" 4 "Bahamas" 
		5 "Dominica" 6 "Guyana" 7 "Antigua and Barbuda" 8 "St.Lucia" 
		9 "SVG" 10 "Belize")
		
		region(fcolor(gs16) lw(vthin) margin(l=2 r=2 t=2 b=2)) 
		sub("Country", size(3))
	
		)
		;
		

#delimit cr

restore
