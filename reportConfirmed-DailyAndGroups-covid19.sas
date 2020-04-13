proc sql feedback noprint;

	select min(Day1), max(Total_Days)
	into :minDay1, :maxDays
	from work.control_panel_brazil ;

	select name
		into :data_selection separated by ','
	from dictionary.columns
	where libname = 'COVID19'
	and memname = UPCASE('report_world_base')
	and substr(name,1,1) = '_';

	select name
		into :drop_it separated by ' '
	from dictionary.columns
	where libname = 'COVID19'
	and memname = UPCASE('report_world_base')
	and substr(name,1,1) = '_';
quit;

options nosymbolgen nomprint nomlogic;
data covid19.report_daily (drop=Codigo Gentilico Governador_2019 Capital_2010 Group vazia
	Ensino_Fundamental_2018 Densidade_demografica_Km2_2010 
	ReceitasBRL_2017 DespesasBRL_2017 Renda_mensal_domi_percap_2019 Total_veiculos_2018
	UF province_location i);
	
	if 0 then
		set work.control_panel_brazil work.support_brazil_data;

	if _N_ = 1 then do;
		declare hash panel_brazil(dataset: 'work.control_panel_brazil');
		panel_brazil.definekey("Location");
		panel_brazil.definedata("Day1","Day_Snapshot","Total_Days","Confirmed");
		panel_brazil.definedone();

		declare hash support_brazil(dataset: 'work.support_brazil_data');
		support_brazil.definekey("UF");
		support_brazil.definedata("IDH_2010","area_km2_2018","populacao_estimada_2019");
		support_brazil.definedone();

		call missing (province_location);
		declare hash panel_world(dataset: 'work.control_panel_world');
		panel_world.definekey("Location");
		panel_world.definedata("Day1","Day_Snapshot","Total_Days","Confirmed");
		panel_world.definedone();
		
		array dias[&maxDays];
		array columns[*] &drop_it;

	end;

	set covid19.report_world_base;
	
	location = province_state;
	UF = province_state;

	If Country_Region = 'Brazil' then do;
		if Lat ne '0' then do;
			panel_brazil.find();
			support_brazil.find();
		end;

 		do i=(dim(columns) - Total_Days + 1) to dim(columns);

			dias[i-(dim(columns) - Total_Days)] = columns[i-1];
		end;
		output;
	end;
	*else do;
	*	location = country_region;
	*	panel_world.find();
		*output;
	*end;
	
	drop &drop_it;
run;
options nosymbolgen;

