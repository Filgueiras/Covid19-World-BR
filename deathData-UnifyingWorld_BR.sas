/**********************************************************
	STEP 09 Overall - STEP 01 for unify Death information (based on STEP 05)

	By Marco Antonio Filgueiras Guimaraes (Github: Filgueiras)
	Date: 2020/04/15

	Create time series from day 1 (first positive report until newest day)

	Tables created:
	From "base": COVID19.COVID_DEATH_CONFIRMED (base_death_data + covid19.COVID_BR_DEATH).
	Then inserts from: COVID19.COVID_US_CONFIRMED and simplified countries that were detailed

	Drops: 	covid_us_confirmed, death_datajh, original_dataus, confirmed_br_unofficial;
	For now, I'm not droping the tables. (My work is in progress, I need to check information). 

	Updates in world countries and territories to fit support data
	based on UN names (names in world support data).
		Table: covid19.covid_world_confirmed
		Deleting 'Diamond Princess' & 'MS Zaandam' lines...
		'Korea, South' to South Korea
		'West Bank and Gaza' as part of 'Israel'
		'Kosovo' as part of 'Serbia'
		'Czechia' changed to 'Czech Republic (Czechia)'
/***********************************************************/

/*Adjusting the origin... same schema than confirmed*/
proc sql;
	update work.base_death_data
	set country_region = 'United States',
		province_state = ''
	where countrY_region = 'US';
quit;

/* Joining information World and Brazil */
proc sql;
	create table COVID19.COVID_WORLD_DEATH as
		select country_region as Country_Region label 'País/Região'
				, province_state as Province_State label 'Estado'
				, put(Lat, 11.) as Lat label='Latitude' format=$15.
				, put(Long, 11.) as Long label='Longitude' format=$15.
				, confirmed as Confirmed label 'Mortes'
				, snapshot as Snapshot label 'Data' format=ddmmyy10.
		from work.base_death_data 
		where country_region ne 'Brazil' 
		and country_region not in (
			select distinct country_region
			from work.base_death_data
			where province_state is not null
			/*China,Canada,Australia,Denmark,France,Netherlands,United Kingdom*/
			/*It's not personal, but I don't want details about those countries.*/
		)
		UNION
		select country_region 
				, province_state 
				, Lat 
				, Long 
				, confirmed 
				, snapshot 
		from covid19.COVID_BR_DEATH
		UNION
		/*Brazilian overall from the same source...*/
		select country_region 
				, '' 
				, '0' 
				, '0' 
				, sum(confirmed)
				, snapshot 
		from covid19.COVID_BR_DEATH
		group by country_region, snapshot
		order by country_region, province_state, snapshot;
quit;

proc sql;
	update work.death_dataus
	set province_state = 'Continental (except NY)'
	where province_state not in ('American Samoa','Diamond Princess','Grand Princess'
	,'Guam','Hawaii','Northern Mariana Islands','Puerto Rico', 'New York');
quit;

/*******************************
	Simplifying US data... (step 1)
********************************/
proc sql;
	create table COVID19.COVID_US_DEATH as
	select 'United States' as country_region
			, province_state 
			, '38.8753496' as Lat label='Latitude' format=$11.
			, '-105.0385572' as Long label='Longitude' format=$11.
			, snapshot
			, sum(confirmed) as Confirmed
	from work.death_dataus
	where province_state not in ('American Samoa','Diamond Princess','Grand Princess'
	,'Guam','Hawaii','Northern Mariana Islands','Puerto Rico', 'New York')
	UNION
	select 'United States' 
			, province_state 
			, put(Lat,11.) 
			, put(Long,11.) 
			, snapshot
			, confirmed 
	from work.death_dataus
	where province_state in ('American Samoa',/*'Diamond Princess','Grand Princess'
	,*/'Guam','Northern Mariana Islands','Puerto Rico')
	UNION /*I needed to work Hawaii and NY apart because there are more than one lat and long*/
	select 'United States' as country_region
			, province_state 
			, '21.665019' as Lat label='Latitude' 
			, '-158.0529937' as Long label='Longitude'
			, snapshot
			, sum(confirmed) as Confirmed
	from work.death_dataus
	where province_state in ('Hawaii')
	group by country_region
			, province_state 
			, snapshot
	UNION
	select 'United States' as country_region
			, province_state 
			, '40.7055689' as Lat label='Latitude' 
			, '-74.0156334' as Long label='Longitude'
			, snapshot
			, sum(confirmed) as Confirmed
	from work.death_dataus
	where province_state in ('New York')
	group by country_region
			, province_state 
			, snapshot
	order by province_state, snapshot;
quit;

/*For now, keeping US data from JHU and putting only NY*/
proc sql;
	insert into covid19.covid_world_death
	select 'United States'
			, province_state 
			, Lat 
			, Long 
			, confirmed 
			, snapshot 
	from COVID19.covid_us_death
	where province_state in ('New York');
quit;

/******************************
	World data from the other "more detailed than I want places"
******************************/
proc sql;
	delete from work.base_death_data
	where country_region eq 'Canada' 
	and Province_state in ('Recovered','Diamond Princess','Grand Princess');
quit;

proc sql;
	insert into covid19.covid_world_death
		select country_region 
				, '' 
				, '0' 
				, '0' 
				, sum(confirmed)
				, snapshot
		from work.base_death_data 
		where country_region in ('China','Canada','Australia','Denmark',
				'France','Netherlands','United Kingdom')
		group by country_region, snapshot
		;
quit;

/*Adjusting name areas to fit UN country data in support world*/
proc sql;

	update covid19.covid_world_death
	set country_region = 'Israel',
		province_state = 'West Bank and Gaza'
	where country_region = 'West Bank and Gaza';

	update covid19.covid_world_death
	set country_region = 'Czech Republic (Czechia)',
		province_state = ''
	where country_region = 'Czechia';

	update covid19.covid_world_death
	set country_region = 'Serbia',
		province_state = 'Kosovo'
	where country_region = 'Kosovo';

	update covid19.covid_world_death
	set country_region = 'South Korea',
		province_state = ''
	where country_region = 'Korea, South';

	delete from covid19.covid_world_death
	where country_region in ('Diamond Princess','MS Zaandam');

quit;