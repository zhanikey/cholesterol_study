/* Data Importing process */

/* Demographic Variables and Sample Weights */

libname XP xport "...\DEMO_J.xpt";

proc copy in=xp out=work;
run;

libname nh "...\NHANES_database";

data nh.DEMO_J;
  set xp.DEMO_J;
run;

/* Dietary Interview - Individual Foods, First Day */

libname XP xport "...\DR1IFF_J.xpt";

proc copy in=xp out=work;
run;

libname nh "...\NHANES_database";

data nh.Dr1iff_j;
  set xp.Dr1iff_j;
run;

/* Dietary Interview - Total Nutrient Intakes, First Day */

libname XP xport "...\DR1TOT_J.xpt";

proc copy in=xp out=work;
run;

libname nh "...\NHANES_database";

data nh.Dr1tot_j;
  set xp.Dr1tot_j;
run;

/* Cholesterol - Total */

libname XP xport "...\TCHOL_J.xpt";

proc copy in=xp out=work;
run;

libname nh "...\NHANES_database";

data nh.TCHOL_J;
  set xp.TCHOL_J;
run;

/* Blood Pressure & Cholesterol */

libname XP xport "...\BPQ_J.xpt";

proc copy in=xp out=work;
run;

libname nh "...\NHANES_database";

data nh.BPQ_J;
  set xp.BPQ_J;
run;

/* Blood Pressure */

libname XP xport "...\BPX_J.xpt";

proc copy in=xp out=work;
run;

libname nh "...\NHANES_database";

data nh.BPX_J;
  set xp.BPX_J;
run;

/* Body Measures */

libname XP xport "...\BMX_J.xpt";

proc copy in=xp out=work;
run;

libname nh "...\NHANES_database";

data nh.BMX_J;
  set xp.BMX_J;
run;

/* Smoking - Cigarette Use */

libname XP xport "...\SMQ_J.xpt";

proc copy in=xp out=work;
run;

libname nh "...\NHANES_database";

data nh.SMQ_J;
  set xp.SMQ_J;
run;

/* Cholesterol - High - Density Lipoprotein (HDL) */

libname XP xport "...\HDL_J.xpt";

proc copy in=xp out=work;
run;

libname nh "...\NHANES_database";

data nh.HDL_J;
  set xp.HDL_J;
run;

/* creating additional table */

proc sql;
create table nh.analysis_data as 
select x.*,y.*,z.*,a.*,b.bmxbmi,c.*,d.* 
from DEMO_J
as x left join TCHOL_J as y 
on x.SEQN=y.SEQN
left join BPQ_J as z
on y.SEQN=z.SEQN
left join SMQ_J as a
on z.SEQN=a.SEQN
left join BMX_J as b
on a.SEQN=b.SEQN
left join HDL_J as c
on b.SEQN=c.SEQN
left join DR1TOT_J as d
on c.SEQN=d.SEQN;
quit;

proc sql; 
create table nh.analysis_data as
select*,
cats(DMDEDUC3,DMDEDUC2) as DMDEDUC from nh.analysis_data;
quit;

data nh.analysis_data;
set nh.analysis_data;
DMDEDUC = compress(DMDEDUC,'.');
run;


/* Check Frequency Distribution and Normality */

/* Using the univariate procedure to generate descriptive statistics  */


LIBNAME NH "...\NHANES_database";
OPTIONS NODATE NOCENTER;
options ls=72;

proc format;                                       
                                                   
  VALUE sexfmt  1 = 'Male'                          
                2 = 'Female'                        
                ;                                  
  

  VALUE racefmt  1 = 'NH White'
                 2 = 'NH Black'
			     3 = 'Mexican American'
			     4 = 'Other'
			      ;
                       
  VALUE agefmt                             
                1 = '20-39'                               
                2 = '40-59'                               
				3 = '60+'       
				;         

 run;   
data nh.analysis_data;
set nh.analysis_data; 

if ridstatr = 2;  ***examined  ;
 
age = .;
if 20 LE ridageyr LE 39 then age=1;
if 40 LE ridageyr LE 59 then age=2;   
if ridageyr GE 60 then age=3;  

race=.;
if ridreth1=3 then race=1;
if ridreth1=4 then race=2; 
if ridreth1=1 then race=3;
if ridreth1=2 or ridreth1=5 then race=4;

LABEL                           
       age  = 'AGE GROUP'    
	   race = 'Race Ethnicity'
       riagendr = 'Gender'  
          ;                                                       
                                                                                                              
RUN;

proc sort; by riagendr age; 
run;

/* Selective statistics */

LIBNAME NH "...\NHANES_database";
OPTIONS NODATE NOCENTER;
options ls=72;

proc format;                                       
                                                   
                                                 
  VALUE sexfmt  1 = 'Male'                          
                2 = 'Female'                        
                ;                                  
  

  VALUE racefmt  1 = 'NH White'
                 2 = 'NH Black'
			     3 = 'Mexican American'
			     4 = 'Other'
			      ;
                       
  VALUE agefmt                             
                1 = '20-39'                               
                2 = '40-59'                               
				3 = '60+'       
				;         

 run;   
data nh.analysis_data;
set nh.analysis_data; 

if ridstatr = 2;  ***examined  ;
 
age = .;
if 20 LE ridageyr LE 39 then age=1;
if 40 LE ridageyr LE 59 then age=2;   
if ridageyr GE 60 then age=3;  

race=.;
if ridreth1=3 then race=1;
if ridreth1=4 then race=2; 
if ridreth1=1 then race=3;
if ridreth1=2 or ridreth1=5 then race=4;

LABEL                           
       age  = 'AGE GROUP'    
	   race = 'Race Ethnicity'	
       riagendr = 'Gender' 
          ;                                                       
                                                                                                              
RUN;




proc sort; by riagendr age; 
run;


PROC UNIVARIATE NOPRINT;

where ridageyr >= 20;

by riagendr age;    

VAR lbxtc;         
 
freq WTMEC2YR; 

FORMAT age AGEFMT. riagendr SEXFMT.  race RACEFMT. ; 

output out=sasdataset mean=mean q1=p_25 median=median q3=p_75;


proc print data=sasdataset;
title "Distribution of cholesterol: NHANES 2017-2018";           
run;
 
/* LINEAR REGRESSION */

LIBNAME NH "...\NHANES_database";
OPTIONS NODATE NOCENTER;
options ls=72;
proc format;
  VALUE sexfmt   1 = 'Male'
                 2 = 'Female'
                 ;
  VALUE sex2fmt  1 = 'Female'
                 2 = 'Male'
                 ;
  VALUE race2fmt 1='Mexican Americans'
                 3='Non-Hispanic white'
                 4='Non-Hispanic black'
                 ;
  VALUE race3fmt 1='Mexican American'
                 2='Non-Hispanic black'
                 5='Non-Hispanic white'
                 ;
  VALUE smkfmt   1='Never smoker'
                 2='Past smoker'
                 3='Current smoker'
                 ;
  VALUE educ     1="< HS"
                 2="HS/GED"
                 3="> HS"
                 ;
 VALUE bmicat   1="underweight"
                 2="normal weight"
                 3="overweight"
                 4="obese"; 
  VALUE bmicatf  1="under weight"
                 2="overweight"
                 3="obese"
                 4="normal weight"; 
run;
data nh.analysis_data;
set nh.analysis_data;
if ridstatr=2; *all mec exam data;

/*set don't know and refused (7,9) to missing*/
if dmdeduc>3 then dmdeduc=.;

/*define smokers*/
if smq020 eq 2 then smoker=1;
else if smq020 eq 1 and smq040 eq 3 then smoker=2;
else if smq020 eq 1 and smq040 in(1,2) then smoker=3;

/*for input to SAS PROC SURVEYREG - recode gender so that men is the reference group*/
if riagendr eq 1 then sex=2;
else if riagendr eq 2 then sex=1;

/*for input to SAS PROC SURVEYREG - recode race/ethnicity so that non-Hispanic white is the reference group*/
ethn=ridreth1;
if ridreth1 eq 3 then ethn=5;
else if ridreth1 eq 4 then ethn=2;
else if ridreth1 eq 2 then ethn=3;
else if ridreth1 eq 5 then ethn=4;

if 0 le bmxbmi lt 18.5 then bmicatf=1; 
else if 18.5 le bmxbmi lt 25 then bmicatf=4; 
else if 25 le bmxbmi lt 30 then bmicatf=2; 
else if bmxbmi ge 30 then bmicatf=3; 

if 0 le bmxbmi lt 18.5 then bmicat=1; 
else if 18.5 le bmxbmi lt 25 then bmicat=2; 
else if 25 le bmxbmi lt 30 then bmicat=3; 
else if bmxbmi ge 30 then bmicat=4; 

if (LBDHDD^=. and riagendr^=. and  ridreth1^=. and smoker^=. and dmdeduc^=. and bmxbmi^=.)and WTMEC2YR>0
   and (ridageyr>=20) then eligible=1; 	*else eligible=2;

label riagendr='Gender'
      sex = 'Gender - recode'
      ridreth1='Race/ethnicity'
      ridageyr='Age in years'
	  ethn = 'Race/ethnicity - recode'
      dmdeduc='Education'
      bmicatf='BMI category';
run;

PROC SURVEYREG data=nh.analysis_data nomcar;
STRATA sdmvstra;
CLUSTER sdmvpsu;
WEIGHT WTMEC2YR;
CLASS  sex ethn dmdeduc smoker bmicatf DRQSDIET;
DOMAIN eligible;
MODEL  LBDHDD = sex ethn ridageyr dmdeduc bmicatf DRQSDIET DR1TKCAL DR1TPROT DR1TCARB DR1TSFAT /CLPARM solution vadjust=none;
ESTIMATE 'Never vs past smoker' smoker 1 -1 0;
TITLE     'Linear regression model for high density lipoprotein and selected covariates: NHANES 2017-2018';
run;     



PROC SURVEYREG data=nh.analysis_data nomcar;
STRATA sdmvstra;
CLUSTER sdmvpsu;
WEIGHT WTMEC2YR;
CLASS  sex ethn smoker dmdeduc bmicatf;
DOMAIN eligible;
MODEL  DR1TCHOL = DR1TKCAL DR1TPROT DR1TCARB DR1TSFAT DR1TLYCO DR1TMAGN DR1TNIAC /CLPARM solution vadjust=none;;
TITLE     'Linear regression model for total cholesterol and selected covariates: NHANES 2017-2018';
run;  
