
/***************************** 
	Importing Excel files 
******************************/

options validvarname=v7;
proc import datafile="&xlsx_fileBRHist"
	out=confirmed_BR_unofficial
	dbms=xlsx 
	replace;
	range=&xlsx_sheet_area;
	sheet=&xlsx_BR_sheet;
	getnames=yes;
run;


/* I don't need do this anymore
proc transpose data=confirmed_BR_unofficial out=confirmed_BR_unofficial (rename=(_name_=date_Ref col1=confirmed));
	by Descri__o Local Lat Lon Total notsorted;
run;*/

/*
options validvarname=v7;
proc import datafile=confurlB
 out=original_dataBR dbms=dlm replace;
	delimiter=';';
	getnames=yes;
	guessingrows=all;
run;
*/

/* Importing brazilian official data */
proc sql noprint;
	select covidBrFileName, catx('','"','C:\Dados\Covid\COVID-19-Marco\BR_Saude_Hist\CSV\COVID19_',covidBrFileName,'.csv','"')
		into : covidBrFileName, :nomeArquivo
	from configEnvironment;
quit;

filename cnfurlBR &nomeArquivo;
options validvarname=v7;
proc import datafile=cnfurlBR
 out=original_dataBR dbms=dlm replace;
	delimiter=';';
	getnames=yes;
	guessingrows=all;
run;

proc sort data=original_dataBR;
	by data estado;
run;


/****************************************************************************************/

proc sql number;
	create table covid19.confirmed_data_br as
	select UNF.Descri__o as Province_State
		, 'Brazil' as Country_Region
		, UNF.Lat as Lat
		, UNF.Lon as Long
		, BR.casosAcumulados as Confirmed
		, BR.data as Snapshot
	from work.original_databr BR
	inner join work.confirmed_br_unofficial UNF on UNF.local = BR.estado
	where BR.data <= (select max(snapshot) from base_confirmed_data)
	order by UNF.Descri__o, Snapshot
	;
quit;

data covid19.confirmed_data_br;
	set covid19.confirmed_data_br;

	province_state = translate(province_state,'AAAAaaaaEEeeIiOOOoooUUuuCc','ÁÃÀÂáãàâÉÊéêÍíÓÕÔóõôÚÜúüÇç');

run;

proc sql number;
	create table covid19.death_data_br as
	select UNF.Descri__o as Province_State
		, 'Brazil' as Country_Region
		, UNF.Lat as Lat
		, UNF.Lon as Long
		, BR.obitosAcumulados as Confirmed
		, BR.data as Snapshot
	from work.original_databr BR
	inner join work.confirmed_br_unofficial UNF on UNF.local = BR.estado
	where BR.data <= (select max(snapshot) from base_confirmed_data)
	order by UNF.Descri__o, Snapshot
	;
quit;

data covid19.death_data_br;
	set covid19.death_data_br;

	province_state = translate(province_state,'AAAAaaaaEEeeIiOOOoooUUuuCc','ÁÃÀÂáãàâÉÊéêÍíÓÕÔóõôÚÜúüÇç');

run;