/**********************************************************
	STEP 03
	DadosBrasil - Brazil Data. Importing data from covid.saude.gov.br 

	By Marco Antonio Filgueiras Guimaraes (Github: Filgueiras)
	Date: 2020/03/31

	Tables created:
	From files: confirmed_BR_unofficial (my data), original_dataBR (official BR data).
	Working data: covid19.COVID_BR_CONFIRMED, covid19.covid_br_death.
	For now, I'm not droping the tables. (My work is in progress, I need to check information). 
***********************************************************/

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

/* Importing brazilian official data */
proc sql noprint;
	select covidBrFileName, catx('','"','C:\Dados\Covid\COVID-19-Marco\BR_Saude_Hist\CSV\COVID19_',covidBrFileName,'.csv','"')
		into :covidBrFileName, :nomeArquivo
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

/*The ideia here is check the max date because I don´t want brazilian's data date higher
	than world's data date*/

proc sql noprint;
	select max(snapshot)
	into :dataMax 
	from base_confirmed_data;

	create table covid19.COVID_BR_CONFIRMED as
	select UNF.Descri__o as Province_State
		, 'Brazil' as Country_Region
		, UNF.Lat as Lat
		, UNF.Lon as Long
		, BR.casosAcumulados as Confirmed
		, BR.data as Snapshot
	from work.original_databr BR
	inner join work.confirmed_br_unofficial UNF on UNF.local = BR.estado
	where BR.data <= &dataMax
	order by UNF.Descri__o, Snapshot
	;
quit;

data covid19.COVID_BR_CONFIRMED;
	set covid19.COVID_BR_CONFIRMED;

	province_state = translate(province_state,'AAAAaaaaEEeeIiOOOoooUUuuCc','ÁÃÀÂáãàâÉÊéêÍíÓÕÔóõôÚÜúüÇç');

run;

proc sql number;
	create table covid19.covid_br_death as
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

data covid19.covid_br_death;
	set covid19.covid_br_death;

	province_state = translate(province_state,'AAAAaaaaEEeeIiOOOoooUUuuCc','ÁÃÀÂáãàâÉÊéêÍíÓÕÔóõôÚÜúüÇç');

run;