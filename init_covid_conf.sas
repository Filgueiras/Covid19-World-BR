/**********************************************************
	Environment and session variables initialization

	By Marco Antonio Filgueiras Guimaraes (Github: Filgueiras)
	Date: 2020/03/31
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
  This is the data from Brazilian Healthy Ministry
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

	if sessionTime > 61200 then
		dataCSV = todayIs;
	else 
		dataCSV = yesterdayWas;

	covidSaude = catx('','"https://covid.saude.gov.br/assets/files/COVID19_',compress(put(dataCSV,yymmddb10.)),'.csv"');
	covidSaude = compress(covidSaude);
	covidBrFileName = compress(put(dataCSV,yymmddb10.));
run;

proc sql;
	select covidSaude
	into :covidSaude
	from work.configEnvironment;
quit;

/*There are 2 patterns for name until now...*/
/*filename confurlB url "https://covid.saude.gov.br/assets/files/BRnCov19_30032020.csv";*/

/*Brasil mudou o método de nomear os arquivos, comentei o confiurlB pq não funciona mais (20200403)*/
*filename confurlB url &covidSaude;

%let xlsx_BR_sheet = BR_TimeSeries;
%let xlsx_fileBRHist = C:\Dados\Covid\COVID-19-Marco\Covid19-World-BR\support_data\Coronavirus-Brasil-Timeseries.xlsx;
%let xlsx_sheet_area = 'A1:AO28'n;

/*Brazil population and density information. Source: IBGE*/
filename ibge "C:\Dados\Covid\COVID-19-Marco\IBGE_BR_data\demographicData-20200403.csv";

proc sql;
	select name, value
	from dictionary.macros
	where scope = 'GLOBAL'
	and substr(name,1,1) ne '_'
	and substr(name,1,3) not in ('SQL','SAS','SYS');
quit;