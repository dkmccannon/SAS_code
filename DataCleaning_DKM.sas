********************************
DataCleaning_DKM

Written by: Kyle McCannon

General Description:
Exploring Data for cleaning to prepare for table 1 and descriptive stats

Date: 
10/15/2021

Input Folders: 
\\fsmresfiles.fsm.northwestern.edu\fsmresfiles\PrevMed\Biostatistics\MSB\2021_2022\Thesis Projects\McCannon\Code

Output Folders:
\\fsmresfiles.fsm.northwestern.edu\fsmresfiles\PrevMed\Biostatistics\MSB\2021_2022\Thesis Projects\McCannon\Reports


*********************************;



*clear work library;
proc datasets library=work kill nolist; quit;

****************************************************

Importing Data Set


****************************************************;



*renamed excel file;
proc import 
	datafile = "\\fsmresfiles.fsm.northwestern.edu\fsmresfiles\PrevMed\Biostatistics\MSB\2021_2022\Thesis Projects\McCannon\Data\R01data_9_14_21.xlsm"
	Out=work.frail
	dbms = excel replace;
	sheet = master;
	getnames = yes;
run;

*Original Excel File;
proc import 
	datafile = "\\fsmresfiles.fsm.northwestern.edu\fsmresfiles\PrevMed\Biostatistics\MSB\2021_2022\Thesis Projects\McCannon\Data\updated R01 data for SPSS 9.14.21.xlsm"
	Out=work.frail
	dbms = excel replace;
	sheet = master;
	getnames = yes;
run;



************************************************************
Variable Renaming & Labeling

************************************************************;

proc contents data=work.frail;run;

option validvarname=any;

data work.frailrenamed;
	set work.frail;
	rename 	Age=age
			Total=mapstotal
			Race:=race
			census__tract__income=cti
			Gender_=gender
			Frailty_Score_=frailtyscore
			Frailty_Category_=frailtycat
			Highest_Level_of_Education_=educ
			Assistive_Device_=assist_dev
			__health_conditions=healthcon
			How_would_you_rate_your_pain_on_=avg_pr
			Destinations_and_Land_Use=dl_use
			Aesthetics_and_Social=a_s
			Segments__average_of_all_segment=avg_allseg
			Crossings__average_of_all_crossi=avg_allcros
			Cul_de_sac__average_of_all_cul_d=avg_allCDS
			TOTAL_WITHOUT_CROSSINGS_CDS=tot_wo_cros
			__apts_=apts
			Building_type__0__subsidized__1_=building_subsid
			Total=total
			Age=age
			Record_ID=rec_ID
			Streetscape=streetscape;
run;

proc contents data=work.frailrenamed;run;

data work.frail;
	set work.frailrenamed;
	label	age="Age (years)"
			streetscape="Streetscape Score"
			a_s="Aesthetics and Social"
			apts="Apts per Center"
			assist_dev="Assistive Device Type"
			avg_allCDS="Avg all Cul-de-sac Totals in proximity to Center"
			avg_allcros="Avg all Crossing Scale Totals in proximity to Center"
			avg_allseg="Avg all Segment Scale Totals in proximity to Center"
			avg_pr="Pain Rating - 7-day Avg"
			building_ID="Building ID"
			building_subsid="Private=1, Subsidized=0"
			cti="Census Tract Income: Socio-economic Status Proxy"	
			city_burb="Suburb=1, City=0: Geographic Location of Center"
			daylight="Daylight - 7-day Avg (minutes)"
			dl_use="Destinations and Land Use"
			educ="Highest Level of Education"
			frailtycat="Frailty Category (Non-, Pre-, Frail)"
			frailtyscore="Frailty Score by SHARE-FI"
			gender="Gender"
			healthcon="Comorbidities"
			race="Race"
			rain="Precipitation 7-day Avg (inches)"
			rec_ID="Record ID"
			steps="Steps (7-day Avg) Physical Activity Proxy"
			temp="Avg Temperature 7-day Avg (degrees F)"
			tot_wo_cros="Total MAP Assessment without Crosswalk Data"
			mapstotal="MAP Assessment Total Score";
run;

proc contents data=work.frail;run;



***********************************************************************************
*
* Data Cleaning
*
***********************************************************************************;

proc freq data=work.frail;
	table Rec_ID / nopercent nocum norow nocol missing;
	title 'Missing';
run;
*rec_ID= . 
7 missing record IDs;
*no duplicate IDs;

**********************************;
*2 Report empty cells
**********************************;

proc print data=work.frail;
	where Rec_ID=.;
run;
*missing record IDs are empty, remove Obs 109 - 115;

*report of missing Records removed from dataset;
ods trace on;
/*
ods pdf file="\\fsmresfiles.fsm.northwestern.edu\fsmresfiles\PrevMed\Biostatistics\MSB\2021_2022\Thesis Projects\McCannon\EmptyCellsRemovedReport.pdf" Style=Journal;
proc print data=work.frail;
	where Rec_ID=.;
	title "Empty Cells in Frailty Data Set";
run;

ods pdf close;
*/
*****************************************************************;
*removed missing Record_ID where all variables were also missing
*****************************************************************;
data work.frailty;
	set work.frail;
	if Rec_ID=. then delete;
run;


*check for missing data observations;
proc means data=frailty n nmiss;
	var _numeric_ _character_;
	run;

proc freq data=frailty;
	tables _all_ / missing;
	run;

proc print data=work.frailty;
	where Frailtyscore= . 
			or age=. 
			or healthcon=. 
			or avg_pr=.
			or race= .
			or gender= .
			or frailtycat=.
			or educ=.
			or assist_dev=.;
run;

*frailty_score
age
healthcon
avg_pr have missing data;

*Proc Means showing missing NUMERIC data;
proc means data=frailty n nmiss; *specify n & nmiss;
	var _numeric_;
	run;

proc freq data=frailty;
	table _character_;
	run;

data work.frailty_missing;
	set work.frailty;
	where Frailty_Score= . 
			or age=. 
			or healthcon=. 
			or avg_pr=.
			or race= " "
			or gender= " "
			or frailtycat=" "
			or educ=" "
			or assist_dev=" ";
run;

/*
ods pdf file="\\fsmresfiles.fsm.northwestern.edu\fsmresfiles\PrevMed\Biostatistics\MSB\2021_2022\Thesis Projects\McCannon\Output\Null_Entries.pdf" style=Journal;
proc print data=frailty_missing;run;
ods pdf close;
*/
title2 "Re-coding Propcase Assistive Devices";
*
Collapse Race into White, African-American, Other

1015 = Non-White Hispanic
1008 = Asian
2017 = Black and American Indian
6003 = Asian

Also Propcase assistive_device & education_level

2004 = Scooter assist_dev
4008 = Wheelchair

;
data work.frailty2 (drop= assist_dev educ);
	set work.frailty;
	assistdev=propcase(assist_dev);
	education=propcase(educ);
	if rec_ID=2017 or rec_ID=1008 or rec_ID=1015 or rec_ID=6003 then race="Other"; *recoding to Other category;
run;

*collapse assistdev Other category;
data work.frailty3;
	attrib assistdev length=$50.; *set length to include renaming convention for Other/scooter/wheelchair;
	set work.frailty2;
	if assistdev="Scooter" then assistdev="Other/Scooter/Wheelchair";
	if assistdev="Other" then assistdev="Other/Scooter/Wheelchair";
	if assistdev="Wheelchair" then assistdev="Other/Scooter/Wheelchair";
run;

*Verify Collapse of assistdev;
proc freq data=work.frailty3;
	table assistdev / nocol norow nocum;
run;

************************************************************************;

*Verify Race converted to Other category;
proc print data=work.frailty3;
	where race="Other";
	title "Cross Validation Check: Race Recategorized";
run;

*verify race recategorized cross check;
proc freq data=frailty3;
	table race / nocum nocol norow;
run;
title;

*verify assistive devices propcase;
proc freq data=frailty3;
	table assistdev / nocum norow nocol;
	title "CVC: assist dev propcased";
run;
title;

*verify education propcase;
proc freq data=frailty3;
	table education / nocum norow nocol;
	title "CVC: education propcased";
run;
title;

**************************************************************
Add missing demographics from data set
**************************************************************;

*numbers next to hard-coding is the REDCap 
survey answer indicator number - provided by PI;
data work.frailty4;
	set work.frailty3;
	if rec_ID=5002 then do;
		race="White"; *3;
		gender="Female";*0;
		frailtyscore=3.243;
		frailtycat="Frail";*0;
		age=85;
		education="Master's Or Beyond"; *3;
		assistdev="Walker";
		healthcon=8;
		avg_pr=6;
	end;
	if rec_ID=7022 then do;
		race="White";*3;
		gender="Male";*1;
		frailtyscore=3.475;
		frailtycat="Frail";*0;
		age=66;
		education="Some College";*1;
		assistdev="None";
		healthcon=7;
		avg_pr=6;
	end;
	if rec_ID=9001 then do;
		race="African-American"; *3;
		gender="Female"; *0;
		frailtyscore=1.347;
		frailtycat="Pre-Frail";*1;
		age=89;
		education="Some College"; *1;
		assistdev="Cane";
		healthcon=5;
		avg_pr=4;
	end;

run;

**********************************************************************;

*verify hardcoded correctly by rec_ID number
using codebook;
proc print data=frailty4;
	var race gender frailtyscore frailtycat age education assistdev healthcon avg_pr;
	where rec_ID=9001 or rec_ID=7022 or rec_ID=5002;
run;

*Frailty.frail_cln: includes 
missing demographics from 5002, 7022, and 9001
extraneous observations with no data removed
variable names are renamed for ease of use
Race categories are collapsed to White, African American, and Other.
Assistive Devices and Education are PROPCASED to provide cohesive frequencies
; 

*********************************************************************

Recoding Census Tract Income for Analysis

03/03/2022

*********************************************************************;

data work.fraill;
	set frailty4;
	*census tract income recategorizing per PI;
	if building_id = 4 or building_id = 7 or building_id = 8 then
	cticat="Middle Income";
	else if building_id = 9 then cticat="Low Income";
	else cticat="High Income";
	*census tract income recategorizing per analyst;
	if cti > 64660 then mhi="Above";
	else mhi="Below";
	*education recategorizing;
	if education ="Grade School" or education = "Some High School" 
		then educ_clps="Less than High School";
	else if education ="High School" then educ_clps="High School";
	else if education ="College" or education = "Some College" 
		then educ_clps="College";
	else educ_clps="Masters Or Higher";
run;

********************************************************************;

proc freq data=work.fraill;
	table cti cticat / norow nocum nocol nopercent;
run;

proc freq data=work.fraill;
	table education educ_clps / norow nocum nocol nopercent;
run;

proc freq data=work.fraill;
	table MHI cti / nocum norow nocol;
run;

data frailty.frailty;
	set work.fraill;
run;


/*
*****************************************************************************

Proc Tabulate

*****************************************************************************;

ods trace on;
ods output Table=tabulate;
ods escapechar='^';
proc tabulate data=Frailty.Frail_cln  out=tab1 missing;
where rec_ID ne .;

var age healthcon daylight rain temp steps / style=[just=left font_size=0.8];

class 	education gender frailtycat assistdev
		 race / style=[just=left font_size=0.8];

table	all='N'
		age='Age'*((mean std)*f=5.1)
		gender='Gender'*(N (colpctn='%'*f=5.1))
		race='Race'*((N colpctn='%')*f=5.1)
		frailtycat='Frailty Baseline'*(N (colpctn='%'*f=5.1))
		assistdev='Assistive Devices'*(N (colpctn='%'*f=5.1))
		healthcon='Health Conditions'*((median min max)*f=5.1)
		daylight='Daylight (minutes)'*((mean std)*f=5.1)
		rain='Precipitation (inches)'*((mean std)*f=5.3)
		temp='Temperature ^{unicode 00B0} F'*((mean std)*f=5.1)
		steps='Step Count'*((median min max)*f=5.1)
		,
		all='Overall';

keyword all / style=[just=left font_size=0.8];
keyword N colpctn mean std median min max/  style=[just=left font_size=0.8];
run;
ods trace off;

proc print data=tab1;run;

**************************************************************************
Tabulate export table removed and export as Word File for submission;


ods trace on;
ods graphics on;
ods rtf file='\\fsmresfiles.fsm.northwestern.edu\fsmresfiles\PrevMed\Biostatistics\MSB\2021_2022\Thesis Projects\McCannon\Documents\Table1RD.rtf' style=Analysis;
ods escapechar='^';
proc tabulate data=Frailty.Frail_cln  out=tab1 missing;
where rec_ID ne .;

var age health_conditions daylight rain temp steps / style=[just=left font_size=0.8];

class 	education gender frailty_category assist_dev
		 race / style=[just=left font_size=0.8];

table	all='N'
		age='Age'*((mean std)*f=5.1)
		gender='Gender'*(N (colpctn='%'*f=5.1))
		race='Race'*((N colpctn='%')*f=5.1)
		frailty_category='Frailty Baseline'*(N (colpctn='%'*f=5.1))
		assist_dev='Assistive Devices'*(N (colpctn='%'*f=5.1))
		health_conditions='Health Conditions'*((median p25 p75)*f=5.1)
		daylight='Daylight (minutes)'*((mean std)*f=5.1)
		rain='Precipitation (inches)'*((mean std)*f=5.3)
		temp='Temperature (^{unicode 00B0} F)'*((mean std)*f=5.1)
		steps='Step Count'*((median p25 p75)*f=5.1)
		,
		all='Overall';

keyword all / style=[just=left font_size=0.8];
keyword N colpctn mean std median min max/  style=[just=left font_size=0.8];
run;
ods trace off;
ods rtf close;


