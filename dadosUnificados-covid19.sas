/* Joining information World and Brazil */

proc sql;
	create table COVID19.COVID_WORLD_CONFIRMED as
		select country_region as Country_Region label 'País/Região'
				, province_state as Province_State label 'Estado'
				, put(Lat, 11.) as Lat label='Latitude' format=$15.
				, put(Long, 11.) as Long label='Longitude' format=$15.
				, confirmed as Confirmed label 'Confirmação'
				, snapshot as Snapshot label 'Data' format=ddmmyy10.
		from work.base_confirmed_data
		where country_region ne 'Brazil'
		UNION
		select country_region 
				, province_state 
				, Lat 
				, Long 
				, confirmed 
				, snapshot 
		from covid19.confirmed_data_br
		order by country_region, province_state, snapshot;
quit;


proc sql;
	update work.original_dataus
	set province_state = 'Continental'
	where province_state not in ('American Samoa','Diamond Princess','Grand Princess'
	,'Guam','Hawaii','Northern Mariana Islands','Puerto Rico');
quit;

proc sql;
	create table COVID19.COVID_US_CONFIRMED as
	select 'United States' as country_region
			, province_state 
			, '38.8753496' as Lat label='Latitude' format=$11.
			, '-105.0385572' as Long label='Longitude' format=$11.
			, snapshot
			, sum(confirmed) as Confirmed
	from covid19.original_dataus
	where province_state not in ('American Samoa','Diamond Princess','Grand Princess'
	,'Guam','Hawaii','Northern Mariana Islands','Puerto Rico')
	group by country_region
			, province_state 
			, snapshot
	UNION
	select 'United States' 
			, province_state 
			, put(Lat,11.) 
			, put(Long,11.) 
			, snapshot
			, confirmed 
	from covid19.original_dataus
	where province_state in ('American Samoa','Diamond Princess','Grand Princess'
	,'Guam','Northern Mariana Islands','Puerto Rico')
	UNION
	select 'United States' as country_region
			, province_state 
			, '21.665019' as Lat label='Latitude' 
			, '-158.0529937' as Long label='Longitude'
			, snapshot
			, sum(confirmed) as Confirmed
	from covid19.original_dataus
	where province_state in ('Hawaii')
	group by country_region
			, province_state 
			, snapshot
	order by province_state, snapshot;
quit;

proc sql;
	drop table covid19.original_dataus;
	insert into covid19.covid_world_confirmed
	select 'United States'
			, province_state 
			, Lat 
			, Long 
			, confirmed 
			, snapshot 
	from covid19.covid_us_confirmed;
quit;

proc sql;
	update covid19.covid_world_confirmed
	set countrY_region = 'United States',
		province_state = 'United States'
	where countrY_region = 'US';
quit;

proc sql;
	drop table covid19.covid_us_confirmed;
	drop table covid19.death_dataus;
	drop table work.death_dataus;
	drop table work.death_datajh;
	drop table work.original_dataus;
	drop table work.original_databr;
	drop table work.original_datajh;
	drop table work.confirmed_br_unofficial;
quit;