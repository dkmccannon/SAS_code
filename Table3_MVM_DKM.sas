********************************
Data Folder: 

Written by: Kyle McCannon

General Description:
Generated Table 3 of Multivariable Model

Date: 03/20/2022

Input Folders: \\fsmresfiles.fsm.northwestern.edu\fsmresfiles\PrevMed\Biostatistics\MSB\2021_2022\Thesis Projects\McCannon\Code\frail.sas

file: \frail.sas

Output Folders: \\fsmresfiles.fsm.northwestern.edu\fsmresfiles\PrevMed\Biostatistics\MSB\2021_2022\Thesis Projects\McCannon\Output

file: \Table3.rtf

*********************************;

proc datasets library=work kill nolist; quit;

* complete model;
ods trace on;
proc glm data=frailty.frail plots=(diagnostics residuals) outstat=frailstats;
	class gender;
	model steps = gender temp streetscape a_s / clparm solution;
	ods output ParameterEstimates=frailtymvm;
	ods output OverallANOVA=frailtyanova;
run;quit;

proc print data=frailtymvm;run;




data work.frailmvm;
	attrib 	Parameter length=$50.
			Beta length=$50.
			CI length=$50.
			Pval length=$50.;

	set work.frailtymvm;
	Beta=round(Estimate, 0.1);
	Pval=round(Probt, 0.0001);
	CI="("||trim(left(round(LowerCL, 0.1)))||" - "||trim(left(round(UpperCL, 0.1)))||")";
	keep Parameter Beta CI Pval;
run;



data work.frailanova;
	attrib Parameter length=$50.
			Beta length=$50.
			CI length=$50.
			Pval length=$50.;

	set work.frailtyanova;
	Parameter=Source;
	Beta=" ";
	Pval=round(ProbF, 0.0001);
	CI=" ";
	if Source="Error" or Source="Corrected Total" then delete;
	keep Parameter Beta CI Pval;
run;



proc append base=frailmvm data=work.frailanova;run;

/*
proc sort data=frailmvm;
	by Parameter;
run;


* remove daylight model;
ods trace on;
proc glm data=frailty.frail plots=(diagnostics residuals) outstat=frailstats;
	class gender;
	model steps = gender temp streetscape a_s / clparm solution;
	ods output ParameterEstimates=frailtymvm;
	ods output OverallANOVA=frailtyanova;
run;quit;

proc print data=frailtymvm;run;




data work.frailmvm2;
	attrib 	Parameter length=$50.
			Beta length=$50.
			CI length=$50.
			Pval length=$50.;

	set work.frailtymvm;
	Beta=round(Estimate, 0.1);
	Pval=round(Probt, 0.0001);
	CI="("||trim(left(round(LowerCL, 0.1)))||" - "||trim(left(round(UpperCL, 0.1)))||")";
	keep Parameter Beta CI Pval;
run;



data work.frailanova2;
	attrib Parameter length=$50.
			Beta length=$50.
			CI length=$50.
			Pval length=$50.;

	set work.frailtyanova;
	Parameter=Source;
	Beta=" ";
	Pval=round(ProbF, 0.0001);
	CI=" ";
	if Source="Error" or Source="Corrected Total" then delete;
	keep Parameter Beta CI Pval;
run;

proc append base=frailmvm2 data=work.frailanova2;run;

proc sort data=frailmvm2;
	by Parameter;
run;

data work.mergemvm;
	merge frailmvm frailmvm2;
	by Parameter;
run;

proc print data=work.mergemvm;run;

*/

ods rtf file="\\fsmresfiles.fsm.northwestern.edu\fsmresfiles\PrevMed\Biostatistics\MSB\2021_2022\Thesis Projects\McCannon\Output\Table3_daylight.rtf" Style=Journal;
title "Table 3: Multivariable Model of Predictors for Physical Activity";
title2 "Daylight Removed";
proc print data=frailMVM noobs;run;
title;
ods rtf close;
