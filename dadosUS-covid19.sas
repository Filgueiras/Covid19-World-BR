/**********************************************************
	STEP 03
	DadosUS - US Data. Importing data from JHU

	By Marco Antonio Filgueiras Guimaraes (Github: Filgueiras)
	Date: 2020/03/31

	Tables created:
	From files: original_dataUS, death_dataUS, .
	Transposed: original_dataUS, death_dataUS (yes, it´s the same).
	For now, I'm not droping the tables. (My work is in progress, I need to check information). 
***********************************************************/

/*US data being imported and, then, simplified*/
options validvarname=v7;
proc import datafile=confurlU
 out=original_dataUS dbms=csv replace;
	getnames=yes;
	guessingrows=all;
run;

options validvarname=v7;
proc import datafile=deaturlU
 out=death_dataUS dbms=csv replace;
	getnames=yes;
	guessingrows=all;
run;

data work.original_dataUS;
	set original_dataUS;
	rename Long_=Long;
	drop UID iso2 iso3 code3 FIPS Admin2 Combined_Key Population;
run;

data work.death_dataUS;
	set death_dataUS;
	rename Long_=Long;
	drop UID iso2 iso3 code3 FIPS Admin2 Combined_Key Population;
run;

/*******************************************************************/

proc transpose data=work.original_dataUS out=work.original_dataUS (rename=(_name_=datestring col1=confirmed));
	by Province_State Country_Region Lat Long notsorted;
run;

proc transpose data=work.death_dataUS out=work.death_dataUS (rename=(_name_=datestring col1=confirmed));
	by Province_State Country_Region Lat Long notsorted;
run;

/*******************************************************************/

data work.original_dataUS (drop = month day year hour minute datestring);
 set work.original_dataUS;
	month=.; month=scan(datestring,1,'_');
	day=.; day=scan(datestring,2,'_');
	year=.; year=2000+scan(datestring,3,'_'); 
	hour=.; hour=scan(datestring,4,'_');
	minute=.; minute=scan(datestring,5,'_');
	format snapshot ddmmyy10.; /*Date in Brazilian format, by Marco*/
	snapshot=mdy(month,day,year);
run;

data work.death_dataUS (drop = month day year hour minute datestring);
 set work.death_dataUS;
	month=.; month=scan(datestring,1,'_');
	day=.; day=scan(datestring,2,'_');
	year=.; year=2000+scan(datestring,3,'_'); 
	hour=.; hour=scan(datestring,4,'_');
	minute=.; minute=scan(datestring,5,'_');
	format snapshot ddmmyy10.; /*Date in Brazilian format, by Marco*/
	snapshot=mdy(month,day,year);
run;