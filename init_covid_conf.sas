/**********************************************************
	STEP 01
	Environment and session variables initialization

	By Marco Antonio Filgueiras Guimaraes (Github: Filgueiras)
	Date: 2020/03/31
***********************************************************
	Desc: changing the time to change the brazilian data file name
			from 5pm to 7pm (and to 6pm 2020/04/13).
	Date: 2020/04/14
***********************************************************/

libname covid19 'C:\Dados\Covid\DB_COVID';

*%let gitData = https://github.com/CSSEGISandData/COVID-19/tree/master/csse_covid_19_data/csse_covid_19_time_series;

/********* World data
  This is the data from Github repository "pulled" to my machine (we can´t download directly from the Github page
  Put your repository address here
*********/
/*I need to put the commando to do the pull in my git repository...*/
/*data _null_;
	call system('cmd; cd C:\Dados\Covid\COVID-19-World\COVID-19\;git pull;exit');
run;*/

filename confurlW 'C:\Dados\Covid\COVID-19-World\COVID-19\csse_covid_19_data\csse_covid_19_time_series\time_series_covid19_confirmed_global.csv';
filename deaturlW /*url*/ "C:\Dados\Covid\COVID-19-World\COVID-19\csse_covid_19_data\csse_covid_19_time_series\time_series_covid19_deaths_global.csv";
filename rcvrurlW /*url*/ "C:\Dados\Covid\COVID-19-World\COVID-19\csse_covid_19_data\csse_covid_19_time_series\time_series_covid19_recovered_global.csv";

/********* US data */
filename confurlU "C:\Dados\Covid\COVID-19-World\COVID-19\csse_covid_19_data\csse_covid_19_time_series\time_series_covid19_confirmed_US.csv";
filename deaturlU "C:\Dados\Covid\COVID-19-World\COVID-19\csse_covid_19_data\csse_covid_19_time_series\time_series_covid19_deaths_US.csv";
/**********/

/*Data about population*/
filename people "C:\Dados\Covid\COVID-19-Marco\Covid19-World-BR\support_data\World_Population_By_Country-20200402.xlsx";

/********* Brazil data
  This is the data from Brazilian Health Ministry
  Updated everyday. Trying to update daily, but the file name have changed some days ago...
	I did the date in 2 steps: first today yymmddb10. (b, before 10, stands for blank). 
	I've tried n, standing for 'none', but it returned me an error message (invalid format).
	Then, I made it in two steps: blank and trim using compress function.
*********/

/*Do that is better than fight against macro var errors*/
data work.configEnvironment;
	sessionTime = time();
	yesterdayWas = intnx('day', today(),-1);
	todayIs =today();

	/*5pm, time of a new file... 
	They use to be delayed and, finally, 2020-04-13, they changed from 61200 (5pm) to 64800 (6pm)*/
	if sessionTime > (19*3600) then /*I decided to get the new file only after 7pm : 7*3600 = */
		dataCSV = todayIs;
	else 
		dataCSV = yesterdayWas;

	/*It doesn't work anymore - you can check in the repo. They have changed the file name.*/
	covidSaude = catx('','"https://covid.saude.gov.br/assets/files/COVID19_',compress(put(dataCSV,yymmddb10.)),'.csv"');
	covidSaude = compress(covidSaude);
	covidBrFileName = compress(put(dataCSV,yymmddb10.));
run;

proc sql;
	select covidSaude
	into :covidSaude
	from work.configEnvironment;
quit;

%let xlsx_BR_sheet = BR_TimeSeries;
%let xlsx_fileBRHist = C:\Dados\Covid\COVID-19-Marco\Covid19-World-BR\support_data\Coronavirus-Brasil-Timeseries.xlsx;
%let xlsx_sheet_area = 'A1:AO28'n;

/*Brazil population and density information. Source: IBGE*/
filename ibge "C:\Dados\Covid\COVID-19-Marco\IBGE_BR_data\demographicData-20200403.csv";

/*Just checking the variables in the end*/
proc sql;
	select name, value
	from dictionary.macros
	where scope = 'GLOBAL'
	and substr(name,1,1) ne '_'
	and substr(name,1,3) not in ('SQL','SAS','SYS');
quit;