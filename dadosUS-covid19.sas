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

data covid19.original_dataUS;
	set original_dataUS;
	rename Long_=Long;
	drop UID iso2 iso3 code3 FIPS Admin2 Combined_Key Population;
run;

data covid19.death_dataUS;
	set death_dataUS;
	rename Long_=Long;
	drop UID iso2 iso3 code3 FIPS Admin2 Combined_Key Population;
run;

/*******************************************************************/

proc transpose data=covid19.original_dataUS out=covid19.original_dataUS (rename=(_name_=datestring col1=confirmed));
	by Province_State Country_Region Lat Long notsorted;
run;

proc transpose data=covid19.death_dataUS out=covid19.death_dataUS (rename=(_name_=datestring col1=confirmed));
	by Province_State Country_Region Lat Long notsorted;
run;

/*******************************************************************/

data covid19.original_dataUS (drop = month day year hour minute datestring);
 set covid19.original_dataUS;
	month=.; month=scan(datestring,1,'_');
	day=.; day=scan(datestring,2,'_');
	year=.; year=2000+scan(datestring,3,'_'); 
	hour=.; hour=scan(datestring,4,'_');
	minute=.; minute=scan(datestring,5,'_');
	format snapshot ddmmyy10.; /*Date in Brazilian format, by Marco*/
	snapshot=mdy(month,day,year);
run;

data covid19.death_dataUS (drop = month day year hour minute datestring);
 set covid19.death_dataUS;
	month=.; month=scan(datestring,1,'_');
	day=.; day=scan(datestring,2,'_');
	year=.; year=2000+scan(datestring,3,'_'); 
	hour=.; hour=scan(datestring,4,'_');
	minute=.; minute=scan(datestring,5,'_');
	format snapshot ddmmyy10.; /*Date in Brazilian format, by Marco*/
	snapshot=mdy(month,day,year);
run;