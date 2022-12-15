********************************
Data Folder: 
\\fsmresfiles.fsm.northwestern.edu\fsmresfiles\PrevMed\Biostatistics\MSB\2021_2022\Thesis Projects\McCannon\Code\Table1_Final_DKM.sas

Written by: Kyle McCannon

General Description: 
Table 1 Macro for descriptive statistics of continuous, ordinal, and categorical data.
Outputs to an excel file with a Journal Style format in the Output folder.

Date: 2/8/22

Input Folders: 
\\fsmresfiles.fsm.northwestern.edu\fsmresfiles\PrevMed\Biostatistics\MSB\2021_2022\Thesis Projects\McCannon\Code

Output Folders:
\\fsmresfiles.fsm.northwestern.edu\fsmresfiles\PrevMed\Biostatistics\MSB\2021_2022\Thesis Projects\McCannon\Output

File:
Table1.rtf

*********************************;








proc datasets library=work kill nolist; quit;


Title "Table 1: Descriptive Summary for Baseline older population data of Retirement Communities of a Randomized Cluster Community Trial";



option mprint symbolgen;







***********************************************************

LABELING

***********************************************************;


DATA FRAILTY.FRAIL;
	SET FRAILTY.FRAIL_CLN;
	LABEL 	a_s=				"Aesthetics and Social Score"
			age=				"Age of Participant"
			apts=				"Apartments per Center"
			assist_dev=			"Assistive Device Type"
			avg_allCDS=			"Average of all Cul-de-sac Totals in proximity to Center"
			avg_allcros=		"Average of all Crossing Scale Totals in proximity to Center"
			avg_allseg=			"Average of all Segment Scale Totals in proximity to Center"
			avg_pain_rating=	"Pain Rating - 7 Day Avg"
			building_ID=		"Building ID"
			building_subsid=	"Subsidized=0 or Private=1"
			census_tract_income="Proxy for Socio-Economic Status"
			city_burb=			"Center in City=0 or Suburb=1"
			daylight=			"Daylight - 7 Day Avg (minutes)"
			dl_use=				"Destinations and Land Use"
			education=			"Highest Level of Education"
			frailty_category=	"Frailty Category (Non-Frail, Pre-Frail, Frail)"
			frailty_score=		"Frailty Score"
			gender=				"Gender"
			health_conditions=	"Comorbidities"
			race=				"Race"
			rain=				"Precipitation (inches)"
			rec_ID= 			"Record ID"
			steps=				"Steps (7 Day Avg) proxy for Physical Activity"
			streetscape=		"Positive Streetscape - Negative Streetscape = Average in proximity to Center"
			temp=				"Average Temperature (degrees F) 7 Day Avg"
			tot_wo_cros=		"Total MAP assessment without Crosswalk data"
			total=				"MAP Assessment Total Score";
run;

proc contents data=frailty.frail;run;



************************************************************

Formatting

************************************************************;

*Variables to be scaled or formatted: Ask thesis advisor

a_s (-1, 0, 1, 2, 3)
apts (
avg_allCDS
avg_allcros
avg_allseg
census_tract_income
dl_use
streetscape
tot_wo_cros
total

;
proc format;
	value centracin;
	value	subpri		0="Subsidized"
						1="Private";
	value	ctbrb		0="City"
						1="Suburb";
run;



************************************************************

MACRO FOR TABLE

************************************************************;

%MACRO summarytable(dataset, vartype, varname, longname, fmtname);
%if &vartype="continuous" %then %do;

PROC MEANS data=&dataset mean std noprint; *&dataset;
	var &varname; *&varname;
	output out=continuous_&varname mean=avg std=std; *continuous_&varname;
RUN;

DATA continuous_&varname._2(keep=Descriptive Overall);*continuous_&varname._2;
	set continuous_&varname;*continuous_&varname;
	length descriptive $40.;
	Overall = " ";
	descriptive=trim(left(put(avg, 8.2)))||" ("||trim(left(put(std, 8.2)))||")";
RUN;

DATA added_descript;
	length varname display_cat $200.; *&varname;
	set continuous_&varname._2;*&longname._2;
	display_cat="Mean (SD)";
	varname= "&longname"; *&longname;
	overall=" ";
	keep overall varname display_cat descriptive;
RUN;

%END;

%if &vartype="ordinal" %then %do;
PROC MEANS data=&dataset median p25 p75 noprint;
  var &varname ;
  output out=continuous_&varname median=med p25=p25 p75=p75;
RUN;

DATA continuous_&varname._2 (keep= Descriptive Overall);
  set continuous_&varname;
  length descriptive $40.;
  Overall=" ";
  descriptive=trim(left(put(med,8.0)))||" ("||trim(left(put(p25,8.1)))||" - "||trim(left(put(p75,8.1)))||")";
RUN;

DATA added_descript;
	length Overall $40.;
	length varname display_cat $200.;
	set continuous_&varname._2;
	Overall = _999;
	display_cat = "Median (IQR)";
 	varname = "&longname";
	keep Overall varname display_cat descriptive; 
RUN;
%end;



%if &vartype="categorical" %then %do;
	%if  &fmtname ="missing" %then %do;  *added for cat without format; 
	PROC FREQ data= &dataset ;*&dataset;
		table &varname / missing nocum;*&varname;
		ods output OneWayFreqs=cat;
	RUN;

	DATA cat2;
		set cat;
		if &varname= . then call symput ("ntot", put(frequency, best12.));
	RUN;

	DATA cat3 (keep = descriptive &varname); *&varname;
		set cat2;
		length descriptive $40.;
		descriptive = trim(left(put(frequency,8.0)))||" ("||trim(left(put(percent,8.1)))||"%)";
	RUN;

	PROC SORT data= cat3;
		by &varname; *&varname;
	RUN;

	DATA cat4 (drop= &varname);
		set cat3;
		varname = "&longname";*&longname;
		display_cat= &varname;
	RUN;

	DATA added_descript;
		length overall $40.;
		length varname display_cat $200.;
		set cat4;
		Overall =" ";
		keep overall varname display_cat descriptive;
	RUN;
	%END;

	%else %do;
		PROC FREQ data= &dataset ;*&dataset;
			table &varname / missing nocum;*&varname;
			ods output OneWayFreqs=cat;
		RUN;

		DATA cat2;
			set cat;
			if &varname= . then call symput ("ntot", put(frequency, best12.));
		RUN;

		DATA cat3 (keep = descriptive &varname); *&varname;
			set cat2;
			length descriptive $40.;
			format &varname &fmtname..; *add &varname &fmtname;
			descriptive = trim(left(put(frequency,8.0)))||" ("||trim(left(put(percent,8.1)))||"%)";
		RUN;

		PROC SORT data= cat3;
			by &varname; *&varname;
		RUN;

		DATA cat4 (drop= &varname);
			set cat3;
			varname = "&longname";*&longname;
			display_cat= put(&varname, &fmtname..); *&varname + &fmtname;
		RUN;

		DATA added_descript;
			length overall $40.;
			length varname display_cat $200.;
			set cat4;
			Overall =" ";
			format &varname &fmtname..;
			keep overall varname display_cat descriptive;
		RUN;
	%END;

%END;
proc append base=descriptives data=added_descript force; run;


%MEND;


*Demographic Variables

;

*age;

%summarytable(dataset=frailty.frail, vartype="continuous", varname=age, longname=Age)

*gender;

%summarytable(dataset=frailty.frail, vartype="categorical", varname=gender, longname=Gender, fmtname="missing") *LB - add fmtname="missing" for categorical variables without formats;


*education;


%summarytable(dataset=frailty.frail, vartype="categorical", varname=education, longname=Highest Level of Education, fmtname="missing")

*census_tract_income;


%summarytable(dataset=frailty.frail, vartype="categorical", varname=census_tract_income, longname=Census Tract Income, fmtname=centracin)

*Health Related Variables

;

data added_descript;
	

*Assistive Devices;


%summarytable(dataset=frailty.frail, vartype="categorical", varname=assist_dev, longname=Assistive Devices, fmtname="missing")


*Frailty Category;


%summarytable(dataset=frailty.frail, vartype="categorical", varname=frailty_category, longname=Frailty Category Baseline, fmtname="missing")


*Frailty Score;


%summarytable(dataset=frailty.frail, vartype="continuous", varname=frailty_score, longname=Frailty Score Baseline)


*Health Conditions;


%summarytable(dataset=frailty.frail, vartype="ordinal", varname=health_conditions, longname=Other Health Conditions)


*Pain Rating (Scale of 1 to 10: average 7 days prior to baseline assessment);


%summarytable(dataset=frailty.frail, vartype="ordinal", varname=avg_pain_rating, longname=Average Pain Rating)


*Environmental Variables

;

*Daylight (minutes)(7 day average prior to baseline assessment);


%summarytable(dataset=frailty.frail, vartype="continuous", varname=daylight, longname=Daylight (minutes))


*Precipitation (inches) (7 days prior to baseline assessment);


%summarytable(dataset=frailty.frail, vartype="continuous", varname=rain, longname=Precipitation (inches))


*Temperature (degrees Fahrenheit);


%summarytable(dataset=frailty.frail, vartype="continuous", varname=temp, longname=Temperature (degrees Fahrenheit))


*Center related variables

;

*aesthetics and social (scale by score);


%summarytable(dataset=frailty.frail, vartype="continuous", varname=a_s, longname=Aesthetics and Social, fmtname="missing")


*Number of Apartments;


%summarytable(dataset=frailty.frail, vartype="ordinal", varname=apts, longname=Apartments per Site)


*destinations and land use (scale by score);

%summarytable(dataset=frailty.frail, vartype="continuous", varname=dl_use, longname=Destinations and Land Use, fmtname="missing")


*census tract income (scale by score)
placed in demographic variables;



*building private or subsidized;

%summarytable(dataset=frailty.frail, vartype="categorical", varname=building_subsid, longname=Subsidized or Private, fmtname=subpri)



*city or suburb;


%summarytable(dataset=frailty.frail, vartype="categorical", varname=city_burb, longname=City or Suburb , fmtname=ctbrb)


*MAPS Assessment parts;

*Crossings (scale by score);

%summarytable(dataset=frailty.frail, vartype="continuous", varname=avg_allcros, longname=Average Crossing Total , fmtname=)


*Cul-de-sacs (scale by score);

%summarytable(dataset=frailty.frail, vartype="continuous", varname=avg_allCDS, longname=Average Cul-de-sac Total , fmtname=)


*Segments (scale by score);


%summarytable(dataset=frailty.frail, vartype="continuous", varname=avg_allseg, longname=Average Segment Total, fmtname=)


*Streetscape (scale by score);


%summarytable(dataset=frailty.frail, vartype="continuous", varname=streetscape, longname=Average Streetscape Total Score , fmtname=)


*total without Crossing Average (scale by score);


%summarytable(dataset=frailty.frail, vartype="continuous", varname=tot_wo_cros, longname=Total without Crossing Score, fmtname=)



*total (scale by score) ;


%summarytable(dataset=frailty.frail, vartype="continuous", varname=total, longname=MAPS Total , fmtname=)

/*
ods trace on;
ods excel file="\\fsmresfiles.fsm.northwestern.edu\fsmresfiles\PrevMed\Biostatistics\MSB\2021_2022\Thesis Projects\McCannon\Output\Table1.xlsx" 
style=Journal;

title "Table 1. Baseline Characteristics of a Cluster-Randomized Community Trial investigating the association between Individual and Center Level Predictors of Physical Activity for a Frail-prone Older Adult Population in the Chicago Area";

proc print data=descriptives;run;

title;
ods excel close;

*/


ods trace on;
ods rtf file="\\fsmresfiles.fsm.northwestern.edu\fsmresfiles\PrevMed\Biostatistics\MSB\2021_2022\Thesis Projects\McCannon\Output\Table1.rtf" 
style=Journal;

title "Table 1. Baseline Characteristics of a Cluster-Randomized Community Trial investigating the association between Individual and Center Level Predictors of Physical Activity for a Frail-prone Older Adult Population in the Chicago Area";

proc print data=descriptives noobs;run;

title;
ods rtf close;










