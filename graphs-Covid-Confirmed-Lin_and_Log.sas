
/*
proc transpose 
	data=covid19.covid_world_confirmed 
	out=covid19.report_world_base
	(drop=_label_ _name_);
	by Province_State Country_Region Lat Long notsorted;
	id snapshot;
run;
*/

proc transpose 
	data=covid19.report_daily
	out=covid19.report_day_to_day_graph
	(RENAME=(Confirmed = Overall _NAME_=Hist COL1=Confirmed));
	by 	Province_State Country_Region Lat Long 
		Day1 Day_Snapshot Total_Days Area_km2_2018 
		Populacao_estimada_2019 IDH_2010 
		Confirmed 
		notsorted;
run;


/*Graphics*/
%let countries = 'Brazil','Italy','Austria','Germany','Portugal','Turkey';
%let paises = Brasil, Itália, Áustria, Alemanha, Portugal, Turquia;
title "Covid19 Confirmações por dia do ano entre: &paises. (linear)";
proc sgplot data=covid19.covid_world_confirmed;
	where Country_Region in (&countries)
		and Province_State in ('')
		and snapshot > input('26/02/2020', ddmmyy10.)
		and Confirmed > 0;
	series x=Snapshot y=Confirmed / 
	group=Country_Region 
	lineattrs=(thickness=3);
	styleattrs datacontrastcolors=(red blue green orange grey purple);
run;
title;

%let countries = 'Brazil','Italy','Austria','Germany','Portugal','Turkey';
%let paises = Brasil, Itália, Áustria, Alemanha, Portugal, Turquia;
title "Covid19 Confirmações por dia do ano entre: &paises. (logartimico)";
proc sgplot data=covid19.covid_world_confirmed;
	where Country_Region in (&countries)
		and Province_State in ('')
		and snapshot > input('26/02/2020', ddmmyy10.)
		and Confirmed > 0;
	series x=Snapshot y=Confirmed / 
	group=Country_Region 
	lineattrs=(thickness=3);
	styleattrs datacontrastcolors=(red blue green orange grey purple);
	yaxis type=log logbase=10;
run;
title;

/***********************************
  TIMELINE
***********************************/

%let countries = 'Brazil','Italy','Austria','Germany','Portugal','Turkey';
%let paises = Brasil, Itália, Áustria, Alemanha, Portugal, Turquia;
title "Covid19 Confirmações por Linha de Tempo entre: &paises. (linear)";
proc sgplot data=covid19.report_day_to_day_graph;
	where Country_Region in (&countries)
		and Province_State in ('')
		and Confirmed > 0;
	series x=Hist y=Confirmed / 
	group=Country_Region 
	lineattrs=(thickness=2);
	styleattrs datacontrastcolors=(red blue green orange grey purple);
	yaxis type=log logbase=10;
;
run;
title;

%let countries = 'Brazil';
%let paises = Brasil (interno);
title "Covid19 Confirmações por Linha de Tempo entre estados do &paises. (linear)";
proc sgplot data=covid19.report_day_to_day_graph;
	where Country_Region in (&countries)
		and Province_State in ('', 'Sao Paulo','Pernambuco','Minas Gerais','Goias','Rio de Janeiro','Brasil sem SP')
		and Confirmed > 0;
	series x=Hist y=Confirmed / 
	group=Province_state 
	lineattrs=(thickness=2);
	styleattrs datacontrastcolors=(red blue green orange grey purple yellow);
run;
title;

/***********LOG******/
%let countries = 'Brazil';
%let paises = Brasil (interno);
title "Covid19 Confirmações por Linha de Tempo entre estados do &paises. (log)";
proc sgplot data=covid19.report_day_to_day_graph;
	where Country_Region in (&countries)
		and Province_State in ('', 'Sao Paulo','Pernambuco','Minas Gerais','Goias','Rio de Janeiro','Brasil sem SP')
		and Confirmed > 0;
	series x=Hist y=Confirmed / 
	group=Province_state 
	lineattrs=(thickness=2);
	styleattrs datacontrastcolors=(red blue green orange grey purple yellow pink);
	yaxis type=log logbase=10;
run;
title;

proc sql;
	select distinct Province_state
	from covid19.report_day_to_day_graph
	where country_region = 'Brazil';
quit;

%let countries = 'Brazil','Italy','Austria','Germany','Portugal','Turkey';
%let paises = Brasil, Itália, Áustria, Alemanha, Portugal, Turquia;
title "Covid19 Confirmações por Linha de Tempo entre: &paises. (logartimico)";
proc sgplot data=covid19.report_day_to_day_graph;
	where Country_Region in (&countries)
		and Province_State in ('')
		and Confirmed > 0;
	series x=Hist y=Confirmed / 
	group=Country_Region 
	lineattrs=(thickness=3);
	styleattrs datacontrastcolors=(red blue green orange grey purple);
	yaxis type=log logbase=10;
run;
title;