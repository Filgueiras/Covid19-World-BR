/**********************************************************
	STEP 02
	DadosMundo - World Data. Importing data from JHU and 
	doing some transformations. This step was inspired by 
	SAS Blog post (see it in a comment below).

	By Marco Antonio Filgueiras Guimaraes (Github: Filgueiras)
	Date: 2020/03/31

	Tables created:
	From files: original_dataJH, death_dataJH,recover_dataJH  
	Transposed: base_confirmed_data, base_death_data, base_recovered_data
	For now, I'm not droping the tables. (My work is in progress, I need to check information). 
***********************************************************/

/*Import files area*/

options validvarname=v7;
proc import datafile=confurlW
 out=original_dataJH dbms=csv replace;
	getnames=yes;
	guessingrows=all;
run;

/*I need to force some data types for lat and long... then I need to get the 'long way' to import data*/


options validvarname=v7;
proc import datafile=deaturlW
 out=death_dataJH dbms=csv replace;
	getnames=yes;
	guessingrows=all;
run;

options validvarname=v7;
proc import datafile=rcvrurlW
 out=recover_dataJH dbms=csv replace;
	getnames=yes;
	guessingrows=all;
run;

/************************************************************************************/
/* 
	The lines below are based in a SAS code presented by Robert Allison
	https://blogs.sas.com/content/graphicallyspeaking/2020/02/03/improving-the-wuhan-coronavirus-dashboard/
*/
/************************************************************************************/

proc transpose data=original_dataJH out=base_confirmed_data (rename=(_name_=datestring col1=confirmed));
	by Province_State Country_Region Lat Long notsorted;
run;

proc transpose data=death_dataJH out=base_death_data (rename=(_name_=datestring col1=confirmed));
	by Province_State Country_Region Lat Long notsorted;
run;

proc transpose data=recover_dataJH out=base_recovered_data (rename=(_name_=datestring col1=confirmed));
	by Province_State Country_Region Lat Long notsorted;
run;

/****************************************************************************************/

/* The date/timestamp is in a string - parse it apart, and create a real datetime variable */
data base_confirmed_data (drop = month day year hour minute datestring);
 set base_confirmed_data;
	month=.; month=scan(datestring,1,'_');
	day=.; day=scan(datestring,2,'_');
	year=.; year=2000+scan(datestring,3,'_'); 
	hour=.; hour=scan(datestring,4,'_');
	minute=.; minute=scan(datestring,5,'_');
	format snapshot ddmmyy10.; /*Date in Brazilian format, by Marco*/
	snapshot=mdy(month,day,year);
run;


data base_death_data (drop = month day year hour minute datestring);
 set base_death_data;
	month=.; month=scan(datestring,1,'_');
	day=.; day=scan(datestring,2,'_');
	year=.; year=2000+scan(datestring,3,'_'); 
	hour=.; hour=scan(datestring,4,'_');
	minute=.; minute=scan(datestring,5,'_');
	format snapshot ddmmyy10.; /*Date in Brazilian format, by Marco*/
	snapshot=mdy(month,day,year);
run;

data base_recovered_data (drop = month day year hour minute datestring);
 set base_recovered_data;
	month=.; month=scan(datestring,1,'_');
	day=.; day=scan(datestring,2,'_');
	year=.; year=2000+scan(datestring,3,'_'); 
	hour=.; hour=scan(datestring,4,'_');
	minute=.; minute=scan(datestring,5,'_');
	mdystring=put(year,z4.)||'-'||put(month,z2.)||'-'||put(day,z2.)||'T'||put(hour,z2.)||':'||put(minute,z2.)||':00 ';
	format snapshot ddmmyy10.; /*Date in Brazilian format, by Marco*/
	snapshot=mdy(month,day,year);
run;


/*
proc sql;
	drop table death_datajh;
	drop table original_datajh;
	drop table recover_datajh;
quit;
*/