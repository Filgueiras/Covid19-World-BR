/**********************************************************
	STEP 10 based on STEP 07
	

	By Marco Antonio Filgueiras Guimaraes (Github: Filgueiras)
	Date: 2020/03/31

	Tables created: SUPPORT_WORLD_DATA, SUPPORT_BRAZIL_DATA
	Just importing additional info about population and areas
************************************************************/


proc sql;
	create table work.covid_world_death_POL as
	select wd.Country_Region as Country_region, sub.Group_Description as Province_State, 
		'0' as Long, '0' as Lat, sum(wd.confirmed) as Confirmed label='Death', wd.Snapshot as Snpashot
	from covid19.covid_world_death wd
		inner join covid19.subareagroup sub on 
		(sub.country_region = wd.country_region and
		sub.province_state = wd.province_state)
	where sub.flg_active = 'Y'
	group by wd.Country_Region, sub.Group_Description,wd.Snapshot
	;
	insert into covid19.covid_world_death
	select *
	from work.covid_world_death_POL;

	drop table work.covid_world_death_POL;

quit;

/************************************/
/*World First Step*/
proc sql noprint;
	create table control_panel_death_world as
	select country_region as Location
		, min(Snapshot) as Day1 format ddmmyy10.
		, max(snapshot) as Day_Snapshot format ddmmyy10.
		, max(confirmed) as Confirmed label='Death'
		, max(snapshot) - min(Snapshot) as Total_Days
		, 'WORLD' as Group
	from covid19.covid_world_death
	where confirmed > 0
	and province_state is null
	group by country_region;

	select max(snapshot) 
	into :limitDate
	from covid19.covid_world_death;

	insert into control_panel_death_world
	select a.country_region as Location
		, min(a.Snapshot) as Day1 format ddmmyy10.
		, max(a.snapshot) as Day_Snapshot format ddmmyy10.
		, (select sum(confirmed) 
			from covid19.covid_world_death b
			where b.country_region = a.country_region
			and b.snapshot = &limitDate
			) as Confirmed
		, max(a.snapshot) - min(a.Snapshot) as Total_Days
		, 'WORLD' as Group
	from covid19.covid_world_death a
	where confirmed > 0
	and province_state is not null
	group by country_region;
quit;

/*Brazil 1st Step*/
proc sql;
	create table control_panel_death_brazil as
	select province_state as Location
		, min(Snapshot) as Day1 format ddmmyy10.
		, max(snapshot) as Day_Snapshot format ddmmyy10.
		, max(confirmed) as Confirmed label='Death'
		, max(snapshot) - min(Snapshot) as Total_Days
		, 'BRASIL' as Group 
	from covid19.covid_world_death
	where confirmed > 0
	and country_region = 'Brazil'
	group by province_state
	;
quit;

/*******************************************
*  Transpose time and data driven routines
********************************************/

proc transpose 
	data=covid19.covid_world_death 
	out=covid19.report_world_death_base
	(drop=_label_ _name_);
	by Province_State Country_Region Lat Long notsorted;
	id snapshot;
run;