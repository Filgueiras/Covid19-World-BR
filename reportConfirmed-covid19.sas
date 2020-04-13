/*REPORT*/
/************************************/
proc sql;
	create table work.covid_world_confirmed_POL as
	select wd.Country_Region as Country_region, sub.Group_Description as Province_State, 
		'0' as Long, '0' as Lat, sum(wd.confirmed) as Confirmed, wd.Snapshot as Snpashot
	from covid19.covid_world_confirmed wd
		inner join covid19.subareagroup sub on 
		(sub.country_region = wd.country_region and
		sub.province_state = wd.province_state)
	where sub.flg_active = 'Y'
	group by wd.Country_Region, sub.Group_Description,wd.Snapshot
	;
	insert into covid19.covid_world_confirmed
	select *
	from work.covid_world_confirmed_POL;
	drop table work.covid_world_confirmed_POL;
quit;

/************************************/
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

/******************************************* daqui em diante será descartado) ****************/
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
	select distinct 'Brasil Centro-Oeste' as Location
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

proc sql;
	create table covid19.subAreaGroup
	(
		group_name char(10),
		group_description char(40),
		country_region char(40),
		province_state char(40),
		flg_active char(1)
	);
	insert into covid19.subAreaGroup(group_name, group_description, country_region, province_state, flg_active)
 
	values('BRLSE','Brasil Sudeste','Brazil','Sao Paulo','Y')
	values('BRLSE','Brasil Sudeste','Brazil','Minas Gerais','Y')
	values('BRLSE','Brasil Sudeste','Brazil','Rio de Janeiro','Y')
	values('BRLSE','Brasil Sudeste','Brazil','Espirito Santo','Y')

	values('BRLS1','Brasil Sul','Brazil','Santa Catarina','Y')
	values('BRLS1','Brasil Sul','Brazil','Parana','Y')
	values('BRLS1','Brasil Sul','Brazil','Rio Grande do Sul','Y')

	values('BRLNE','Brasil Nordeste','Brazil','Bahia','Y')
	values('BRLNE','Brasil Nordeste','Brazil','Pernambuco','Y')
	values('BRLNE','Brasil Nordeste','Brazil','Rio Grande do Norte','Y')
	values('BRLNE','Brasil Nordeste','Brazil','Ceara','Y')
	values('BRLNE','Brasil Nordeste','Brazil','Maranhao','Y')
	values('BRLNE','Brasil Nordeste','Brazil','Sergipe','Y')
	values('BRLNE','Brasil Nordeste','Brazil','Piaui','Y')
	values('BRLNE','Brasil Nordeste','Brazil','Alagoas','Y')
	values('BRLNE','Brasil Nordeste','Brazil','Paraiba','Y')


	values('BRLCO','Brasil Centro-Oeste','Brazil','Goias','Y')
	values('BRLCO','Brasil Centro-Oeste','Brazil','Mato Grosso', 'Y')
	values('BRLCO','Brasil Centro-Oeste','Brazil','Mato Grosso do Sul','Y')
	values('BRLCO','Brasil Centro-Oeste','Brazil','Distrito Federal','Y')

	values('BRLN1','Brasil Norte','Brazil','Amazonas','Y')
	values('BRLN1','Brasil Norte','Brazil','Para','Y')
	values('BRLN1','Brasil Norte','Brazil','Tocantins','Y')
	values('BRLN1','Brasil Norte','Brazil','Roraima','Y')
	values('BRLN1','Brasil Norte','Brazil','Amapa','Y')
	values('BRLN1','Brasil Norte','Brazil','Rondonia','Y')
	values('BRLN1','Brasil Norte','Brazil','Acre','Y')

	values('BR0SP','Brasil sem SP','Brazil','Acre','Y')
	values('BR0SP','Brasil sem SP','Brazil','Alagoas','Y')
	values('BR0SP','Brasil sem SP','Brazil','Amapa','Y')
	values('BR0SP','Brasil sem SP','Brazil','Amazonas','Y')
	values('BR0SP','Brasil sem SP','Brazil','Bahia','Y')
	values('BR0SP','Brasil sem SP','Brazil','Ceara','Y')
	values('BR0SP','Brasil sem SP','Brazil','Distrito Federal','Y')
	values('BR0SP','Brasil sem SP','Brazil','Espirito Santo','Y')
	values('BR0SP','Brasil sem SP','Brazil','Goias','Y')
	values('BR0SP','Brasil sem SP','Brazil','Maranhao','Y')
	values('BR0SP','Brasil sem SP','Brazil','Mato Grosso','Y')
	values('BR0SP','Brasil sem SP','Brazil','Mato Grosso do Sul','Y')
	values('BR0SP','Brasil sem SP','Brazil','Minas Gerais','Y')
	values('BR0SP','Brasil sem SP','Brazil','Para','Y')
	values('BR0SP','Brasil sem SP','Brazil','Paraiba','Y')
	values('BR0SP','Brasil sem SP','Brazil','Parana','Y')
	values('BR0SP','Brasil sem SP','Brazil','Pernambuco','Y')
	values('BR0SP','Brasil sem SP','Brazil','Piaui','Y')
	values('BR0SP','Brasil sem SP','Brazil','Rondonia','Y')
	values('BR0SP','Brasil sem SP','Brazil','Roraima','Y')
	values('BR0SP','Brasil sem SP','Brazil','Rio de Janeiro','Y')
	values('BR0SP','Brasil sem SP','Brazil','Rio Grande do Norte','Y')
	values('BR0SP','Brasil sem SP','Brazil','Rio Grande do Sul','Y')
	values('BR0SP','Brasil sem SP','Brazil','Santa Catarina','Y')
	values('BR0SP','Brasil sem SP','Brazil','Sergipe','Y')
	values('BR0SP','Brasil sem SP','Brazil','Tocantins','Y')
	;
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