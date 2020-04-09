/*
proc sql;
	create table groups_config as
	select group_name, country_region, province_state, flag_active
	from 

quit;
*/
proc sql feedback;
	select *
	from control_panel_brazil;
quit;

/*

*/

data covid19.report_daily;
	set covid19.report_world_base;
	declare hash panel_world(dataset: 'control_panel_world');
	declare hash groups_config
run;