/******************************************************************/
%let countries = 'Brazil','Italy','Austria','Germany','Portugal','Turkey';
%let paises = Brasil, Itália, Áustria, Alemanha, Portugal, Turquia;

title "Covid19 Mortes por DIA entre: &paises";
proc sgplot data=covid19.covid_world_death;
	where Country_Region in (&countries)
		and Province_State in ('')
		and Confirmed > 0;
	series x=Snapshot y=Confirmed / 
	group=Country_Region 
	lineattrs=(thickness=3);
	styleattrs datacontrastcolors=(red blue green orange grey purple);
	*yaxis type=log logbase=10;
run;
title;

/******************************************************************/
%let countries = 'Brazil';
%let paises = estados do Brasil;

title "Covid19 Mortes por DIA entre estados no &paises";
proc sgplot data=covid19.covid_br_death;
	where Country_Region in (&countries)
		and Province_State in ('','Sao Paulo', 'Rio de Janeiro', 'Ceara', 'Amazonas','Pernambuco')
		and Confirmed > 0;
	series x=Snapshot y=Confirmed / 
	group=Province_state
	lineattrs=(thickness=2);
	styleattrs datacontrastcolors=(red blue green orange grey purple);
	*yaxis type=log logbase=10;
run;
title;

%let countries = 'Brazil';
%let paises = estados do Brasil;
title "Covid19 Mortes por DIA entre &paises";
proc sgplot data=covid19.covid_world_death;
	where Country_Region in (&countries)
		and Province_State in ('','Sao Paulo', 'Rio de Janeiro','Pernambuco', 'Brasil sem SP')
		and Confirmed > 0;
	series x=Snapshot y=Confirmed / 
	group=province_state
	lineattrs=(thickness=3);
	styleattrs datacontrastcolors=(red blue green orange grey purple);
	*yaxis type=log logbase=10;
run;
title;

proc sql;
	select *
	from covid19.covid_world_death
	where Province_State in ('','Sao Paulo', 'Rio de Janeiro','Pernambuco', 'Brasil sem SP')
	and country_region = 'Brazil'
	and confirmed > 0;
quit;