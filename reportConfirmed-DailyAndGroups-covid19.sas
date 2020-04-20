/**********************************************************
	STEP 08
	Generating the report itself and the time series data
	(I´m shifting the data to columns dias01 (days01) and so on...)

	By Marco Antonio Filgueiras Guimaraes (Github: Filgueiras)
	Date: 2020/04/12

	Tables created: covid19.report_daily
	Temp tables: hash objects and arrays.
		hash panel_brazil(dataset: 'work.control_panel_brazil')
		hash support_brazil(dataset: 'work.support_brazil_data')
		hash panel_world(dataset: 'work.control_panel_world')
		hash support_world(dataset: 'work.support_world_data')
	For now creates an Excel file and then I create the graph there, but I will
	develop the graphs on SAS in next releases...

	Create time series from day 1 (first positive report until newest day)
************************************************************/

proc sql feedback noprint;
	*select min(Day1), max(Total_Days)
	into :minDay1, :maxDays
	from work.control_panel_brazil ;

	select min(Day1), max(Total_Days), max(Day_Snapshot) format yymmddn10.
	into :minDay1, :maxDays, :fileName
	from work.control_panel_world ;

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
	UF province_location i population_2020 land_area_km ret);
	
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

		declare hash support_world(dataset: 'work.support_world_data');
		support_world.definekey("Country_Name");
		support_world.definedata("land_area_km","population_2020");
		support_world.definedone();

		array dias[&maxDays];
		array columns[*] &drop_it;

	end;

	set covid19.report_world_base;
	
	location = province_state;
	UF = province_state;
	Country_name = Country_Region;

	ret = 0;
	If (Country_Region = 'Brazil' and Province_State ne '' ) then do;

		ret= panel_brazil.find();
		if ret then do;
			call missing(Day1,Day_Snapshot,Total_Days,Confirmed);
			put 'Panel Brazil Hash Province Missing = ' province_state;
		end;

		ret = 0;
		ret = support_brazil.find();

		if ret then do;
			call missing(IDH_2010,area_km2_2018,populacao_estimada_2019);
			put 'Support Brazil Hash Province Missing = ' province_state;
		end;

		/*Debug*/
		put '********************************';
		put 'Iniciando estado ' Province_State;
		ret = dim(columns); 
		put 'Máximo de colunas =' ret;
		ret = (dim(columns) - Total_Days + 1);
		put 'O i inicial será ' ret;
		put 'O total de dias é ' ToTal_Days;

 		do i=(dim(columns) - Total_Days + 1) to (dim(columns));
			dias[i-(dim(columns) - Total_Days)] = columns[i-1];
			ret = i-(dim(columns) - Total_Days);
			put 'Índice do dias: ' ret;
			ret = i-1;
			put 'Índice do Geral = ' ret;
			if i = dim(columns) then do;
				dias[i-(dim(columns) - Total_Days)+1] = columns[i];
				ret = i-(dim(columns) - Total_Days)+1;
				put 'Índice do dias: ' ret;
				ret = i;
				put 'Índice do Geral = ' ret;
				put '**** Fim do Loop ****';
			end;
		end;

		output;
	end;
	else do;
		/*Inside Brazil, location is a Province, outside, is the country*/
		location = country_region;

		ret = 0;
		ret = support_world.find();
		if ret then  do;
			call missing(population_2020, land_area_km);
			put 'Support World Hash Country Missing = ' country_region;
		end;

		ret = 0;
		ret = panel_world.find();
		if ret then  do;
			call missing(Day1,Day_Snapshot,Total_Days,Confirmed);
			put 'Panel World Hash Country Missing = ' country_region;
		end;


		populacao_estimada_2019 = population_2020;
		area_km2_2018 = land_area_km;

 		do i=(dim(columns) - Total_Days + 1) to (dim(columns));

			dias[i-(dim(columns) - Total_Days)] = columns[i-1];
		end;
		
		/*Changing Location for report purposes*/
		If Province_State ne '' then Location = Province_State;
		output;
	end;
	
	drop &drop_it;
run;

options nosymbolgen;

proc sql feedback;
	select *
	from covid19.report_daily;

quit;


proc plot data=covid19.report_daily;

run;
/*
proc format;
 value nulos 
	. = " "
	other = [8.0];
run;

ODS EXCEL FILE = "C:\Dados\Covid\MIGRA_OUTPUT\REPORT_COVID19_WORLD_OUT - &filename..xlsx"
options(sheet_name='DADOS_COVID' ABSOLUTE_COLUMN_WIDTH='100px,100px,100px,100px,100px,100px,100px,200px' AUTOFILTER='ALL');
proc report data=covid19.report_daily;
	column Country_Region Area_km2_2018 Populacao_estimada_2019 Day1 Day_Snapshot  
			Province_State Confirmed Location
			dias1 dias2 dias3 dias4 dias5 dias6 dias7 dias8 dias9 dias10-dias19
			dias20-dias29 dias30-dias39 dias40-dias49 dias50-dias59 dias60-dias69
			dias70-dias79 dias80-dias82
	;
	where Country_Region in ('Brazil','Austria', 'Italy','Portugal', 'Angola');
	format dias1 dias2 dias3 dias4 dias5 dias6 dias7 dias8 dias9 dias10-dias19
			dias20-dias29 dias30-dias39 dias40-dias49 dias50-dias59 dias60-dias69
			dias70-dias79 dias80-dias82 nulos.;
	define Location / style(column)={tagattr='Type:Text' width=100%};
	define Country_Region / style(column)={tagattr='Type:Text' width=100%};
run;
ODS EXCEL CLOSE ;
*/

/*
proc sql;
	select name, value
	from dictionary.macros
	where scope = 'GLOBAL'
	and substr(name,1,1) ne '_'
	and substr(name,1,3) not in ('SQL','SAS','SYS');
quit;
*/
