/*REPORT*/

/*World First Step*/
proc sql;
	create table control_panel_world as
	select country_region as Location
		, min(Snapshot) as Day1 format ddmmyy10.
		, max(snapshot) as Day_Snapshot format ddmmyy10.
		, max(confirmed) as Confirmed
		, max(snapshot) - min(Snapshot) as Total_Days
		, 'WORLD' as Group
	from covid19.covid_world_confirmed
	where confirmed > 0
	and province_state is null
	group by country_region;
quit;

/*World Last Step*/
proc sql noprint;
	select max(snapshot) 
	into :limitDate
	from covid19.covid_world_confirmed;

	insert into control_panel_world
	select a.country_region as Location
		, min(a.Snapshot) as Day1 format ddmmyy10.
		, max(a.snapshot) as Day_Snapshot format ddmmyy10.
		, (select sum(confirmed) 
			from covid19.covid_world_confirmed b
			where b.country_region = a.country_region
			and b.snapshot = &limitDate
			) as Confirmed
		, max(a.snapshot) - min(a.Snapshot) as Total_Days
		, 'WORLD' as Group
	from covid19.covid_world_confirmed a
	where confirmed > 0
	and province_state is not null
	group by country_region;
quit;

/*Brazil 1st Step*/
proc sql;
	create table control_panel_brazil as
	select province_state as Location
		, min(Snapshot) as Day1 format ddmmyy10.
		, max(snapshot) as Day_Snapshot format ddmmyy10.
		, max(confirmed) as Confirmed
		, max(snapshot) - min(Snapshot) as Total_Days
		, 'BRASIL' as Group 
	from covid19.covid_world_confirmed
	where confirmed > 0
	and country_region = 'Brazil'
	group by province_state
	;
quit;

/*Brazil detailed*/
proc sql;
	insert into control_panel_brazil
	select distinct 'Brasil sem SP' as Location /*the province column made me do it*/
		, min(a.snapshot) as Day1 format ddmmyy10.
		, max(a.snapshot) as Day_Snapshot format ddmmyy10.
		, (select sum(b.confirmed) 
			from covid19.covid_world_confirmed b
			where b.country_region = a.country_region
			and b.province_state ne 'Sao Paulo'
			and b.snapshot = &limitDate
			) as Confirmed
		, max(a.snapshot) - min(a.Snapshot) as Total_Days
		, 'BR0SP' as Group
	from covid19.covid_world_confirmed a
	where a.confirmed > 0
	and a.country_region = 'Brazil'
	and a.province_state ne 'Sao Paulo';
quit;

proc sql;
	insert into control_panel_brazil
	select distinct 'Brasil Sudeste' as Location
		, min(a.snapshot) as Day1 format ddmmyy10.
		, max(a.snapshot) as Day_Snapshot format ddmmyy10.
		,(select sum(b.confirmed) 
			from covid19.covid_world_confirmed b
			where b.country_region = a.country_region
			and b.province_state in ('Sao Paulo', 'Minas', 'Rio de Janeiro', 'Espirito Santo')
			and b.snapshot = &limitDate
			) as Confirmed
		,max(a.snapshot) - min(a.Snapshot) as Total_Days
		, 'BRLSE' as Group
	from covid19.covid_world_confirmed a
	where a.confirmed > 0
	and a.country_region = 'Brazil'	
	and a.province_state in ('Sao Paulo', 'Minas', 'Rio de Janeiro', 'Espirito Santo');
quit;

proc sql;
	insert into control_panel_brazil
	select distinct 'Brasil Sul' as Location
		, min(a.snapshot) as Day1 format ddmmyy10.
		, max(a.snapshot) as Day_Snapshot format ddmmyy10.
		,(select sum(b.confirmed) 
			from covid19.covid_world_confirmed b
			where b.country_region = a.country_region
			and b.province_state in ('Santa Catarina', 'Parana', 'Rio Grande do Sul')
			and b.snapshot = &limitDate
			) as Confirmed
		,max(a.snapshot) - min(a.Snapshot) as Total_Days
		, 'BRLS1' as Group
	from covid19.covid_world_confirmed a
	where a.confirmed > 0
	and a.country_region = 'Brazil'	
	and a.province_state in ('Santa Catarina', 'Parana', 'Rio Grande do Sul');
quit;

proc sql;
	insert into control_panel_brazil
	select distinct 'Brasil Nordeste' as Location
		, min(a.snapshot) as Day1 format ddmmyy10.
		, max(a.snapshot) as Day_Snapshot format ddmmyy10.
		,(select sum(b.confirmed) 
			from covid19.covid_world_confirmed b
			where b.country_region = a.country_region
			and b.province_state in ('Bahia','Pernambuco','Rio Grande do Norte','Ceara','Maranhao','Sergipe','Piaui','Alagoas','Paraiba')
			and b.snapshot = &limitDate
			) as Confirmed
		,max(a.snapshot) - min(a.Snapshot) as Total_Days
		, 'BRLNE' as Group
	from covid19.covid_world_confirmed a
	where a.confirmed > 0
	and a.country_region = 'Brazil'	
	and a.province_state in ('Bahia','Pernambuco','Rio Grande do Norte','Ceara','Maranhao','Sergipe','Piaui','Alagoas','Paraiba');
quit;

proc sql;
	insert into control_panel_brazil
	select distinct 'Brasil Centro Oeste' as Location
		, min(a.snapshot) as Day1 format ddmmyy10.
		, max(a.snapshot) as Day_Snapshot format ddmmyy10.
		,(select sum(b.confirmed) 
			from covid19.covid_world_confirmed b
			where b.country_region = a.country_region
			and b.province_state in ('Goias', 'Mato Grosso', 'Mato Grosso do Sul', 'Distrito Federal')
			and b.snapshot = &limitDate
			) as Confirmed
		,max(a.snapshot) - min(a.Snapshot) as Total_Days
		, 'BRLCO' as Group
	from covid19.covid_world_confirmed a
	where a.confirmed > 0
	and a.country_region = 'Brazil'	
	and a.province_state in ('Goias', 'Mato Grosso', 'Mato Grosso do Sul', 'Distrito Federal')
	UNION
	select distinct 'Brasil Norte' as Location
		, min(a.snapshot) as Day1 format ddmmyy10.
		, max(a.snapshot) as Day_Snapshot format ddmmyy10.
		,(select sum(b.confirmed) 
			from covid19.covid_world_confirmed b
			where b.country_region = a.country_region
			and b.province_state in ('Tocantins', 'Para', 'Amazonas', 'Rondonia','Amapa','Roraima','Acre')
			and b.snapshot = &limitDate
			) as Confirmed
		,max(a.snapshot) - min(a.Snapshot) as Total_Days
		, 'BRLN1' as Group
	from covid19.covid_world_confirmed a
	where a.confirmed > 0
	and a.country_region = 'Brazil'	
	and a.province_state in ('Tocantins', 'Para', 'Amazonas', 'Rondonia','Amapa','Roraima','Acre');
quit;

/*******************************************
*  Transpose time and data driven routines
********************************************/
/*
proc sql;
	select country_region as Pais, province_state as Interno, count(snapshot) as Dias
	from covid19.covid_world_confirmed
	group by country_region, province_state 
	having count(snapshot) > 77;
quit;

proc sql;
	select *
	from covid19.covid_world_confirmed
	where province_state = 'New York'
	;
quit;
*/
proc transpose 
	data=covid19.covid_world_confirmed
	out=covid19.report_world_base
	(drop=_label_ _name_);
	by Province_State Country_Region Lat Long notsorted;
	id snapshot;
run;

/*Data driven time*/

/*

%macro createTimeline();


	data _null_;
		

	run;

	proc sql;
		select br.location
		, br.day1
		, br.group
		, br.total_days
		, wb.lat
		, wb.long
		


		from covid19.report_world_base wb
		inner join control_panel_brazil br 
			on br.location = wb.province_state
		;
	quit;
%mend createTimeline;

proc sql;
	select *
	from covid19.REPORT_WORLD_BASE
	where country_region = 'Brazil';
quit;

*/