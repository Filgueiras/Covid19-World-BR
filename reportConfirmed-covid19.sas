/*REPORT*/

/*World First Step*/
proc sql;
	create table control_panel_world as
	select country_region as Location
		, min(Snapshot) as Day1 format ddmmyy10.
		, max(snapshot) as Day_Snapshot format ddmmyy10.
		, max(confirmed) as Confirmed
		, max(snapshot) - min(Snapshot) as Total_Days
	from covid19.covid_world_confirmed
	where confirmed > 0
	and province_state is null
	group by country_region;
quit;

/*World Last Step*/
proc sql;
	insert into control_panel_world
	select a.country_region as Location
		, min(a.Snapshot) as Day1 format ddmmyy10.
		, max(a.snapshot) as Day_Snapshot format ddmmyy10.
		, (select sum(confirmed) 
			from covid19.covid_world_confirmed b
			where b.country_region = a.country_region
			and b.snapshot = (select max(c.snapshot) 
				from covid19.covid_world_confirmed c)
			) as Confirmed
		, max(a.snapshot) - min(a.Snapshot) as Total_Days
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
		, 0 as Group
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
			and b.snapshot = (select max(c.snapshot) 
				from covid19.covid_world_confirmed c)
			) as Confirmed
		, max(a.snapshot) - min(a.Snapshot) as Total_Days
		, 1 as Group
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
			and b.snapshot = (select max(c.snapshot) from covid19.covid_world_confirmed c)
			) as Confirmed
		,max(a.snapshot) - min(a.Snapshot) as Total_Days
		, 2 as Group
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
			and b.snapshot = (select max(c.snapshot) from covid19.covid_world_confirmed c)
			) as Confirmed
		,max(a.snapshot) - min(a.Snapshot) as Total_Days
		, 3 as Group
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
			and b.snapshot = (select max(c.snapshot) from covid19.covid_world_confirmed c)
			) as Confirmed
		,max(a.snapshot) - min(a.Snapshot) as Total_Days
		, 4 as Group
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
			and b.snapshot = (select max(c.snapshot) from covid19.covid_world_confirmed c)
			) as Confirmed
		,max(a.snapshot) - min(a.Snapshot) as Total_Days
		, 5 as Group
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
			and b.snapshot = (select max(c.snapshot) from covid19.covid_world_confirmed c)
			) as Confirmed
		,max(a.snapshot) - min(a.Snapshot) as Total_Days
		, 6 as Group
	from covid19.covid_world_confirmed a
	where a.confirmed > 0
	and a.country_region = 'Brazil'	
	and a.province_state in ('Tocantins', 'Para', 'Amazonas', 'Rondonia','Amapa','Roraima','Acre');
quit;

/*
proc sql;
	select min(Snapshot), max(SnapShot), (max(SnapShot) - min(Snapshot))
	into :fisrtDay, :lastDay , :totalDays
	from covid19.covid_world_confirmed
	where confirmed > 0
	and country_region = 'Brazil'
	and province_state in ('Sao Paulo', 'Minas', 'Rio de Janeiro', 'Espirito Santo');

	select  sum(confirmed) 
	into  :confirmed
	from covid19.covid_world_confirmed
	where confirmed > 0
	and country_region = 'Brazil'
	and province_state in ('Sao Paulo', 'Minas', 'Rio de Janeiro', 'Espirito Santo')
	and snapshot = &lastDay;

	insert into control_panel_brazil(location, day1, day_snapshot, confirmed, total_days)
	values ("Brasil Sudeste", put(&firstday,$8.), put(&lastDay,$8.),put(&confirmed,$8.),put(&totalDays,$8.));
quit;*/
