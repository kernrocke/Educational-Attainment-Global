
clear
cls

**  GENERAL DO-FILE COMMENTS
**  Program:		education_001
**  Project:      	Education Attainment
**  Analyst:		Kern Rocke
**	Date Created:	02/07/2020
**	Date Modified: 	02/07/2020
**  Algorithm Task: Descriptives of Education Attainment by Country


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
	
*Use both male annd female --- Note: This can change for analysis for males and females (ensure age range is considered)
keep if sex_id == 3

*-------------------------------------------------------------------------------

*Merging data with iso mapping file

rename location_code country_iso
rename location_name country_name

*Save data
save "`datapath'/Manuscripts/Education_Attainment/education_attainment", replace

*-------------------------------------------------------------------------------

*Reshaping dataset to wide format
encode country_iso, gen(iso)
drop if iso==.
keep mean upper lower iso year country_name
collapse (mean) mean lower upper, by(country_name year iso)
reshape wide mean lower upper country_name , i(iso) j(year)
decode iso, gen(country_iso)
order country_iso, after(iso)


rename country_name1970 country_name
drop country_name19*
drop country_name20*

save "`datapath'/Manuscripts/Education_Attainment/education_attainment_wide", replace
*-------------------------------------------------------------------------------


*Change data path
cd "`datapath'/Manuscripts/COVID-19/Community Mobility/04_TechDocs/Mobility Map"

*Unzip compressed file
unzipfile ne_10m_admin_0_countries, replace

*Create Shapefile Datasets (Data and Coordinates)
shp2dta using ne_10m_admin_0_countries, database("world_data") coordinates("world_coordinates") genid(id) replace

*Open shapefile coordinates datasets
use world_coordinates, clear

*Open shapefile datasets
use world_data, clear

rename ADM0_A3 country_iso
merge 1:1 country_iso using "`datapath'/Manuscripts/Education_Attainment/education_attainment_wide.dta", force

forvalues time = 1970/2015 {
	spmap mean`time' using world_coordinates, id(id) ///
	fcolor(BuYlRd) ///
	ocolor(gs01) osize(vthin) ///
	title("Educational Attainment in `time'") ///
	subtitle("Global Burden of Disease") ///
	clmethod(custom) ///
	clnumber(8) ///
	clbreak(0 1 3 5 7 9 11 13 15)
	
	// Creating a sequential file number and export the map
	
	local filenum = string(`time' - 1969)
	graph export "`datapath'/Manuscripts/Education_Attainment/map_`filenum'.png", replace as(png)
	
	}
