/**********************************************************
	STEP 06
	dadosSuporte (Support data)

	By Marco Antonio Filgueiras Guimaraes (Github: Filgueiras)
	Date: 2020/03/31

	Tables created: SUPPORT_WORLD_DATA, SUPPORT_BRAZIL_DATA
	Just importing additional info about population and areas
************************************************************/

/*Dados suporte*/

/*Support data about countries*/

/***************************** 
	Importing Excel files 
******************************/

options validvarname=v7;
proc import datafile=people
	out=work.SUPPORT_WORLD_DATA
	dbms=xlsx 
	replace;
	range='A1:L236'n;
	sheet='world';
	getnames=yes;
run;


options validvarname=v7;
proc import datafile=ibge
 out=SUPPORT_BRAZIL_DATA dbms=csv replace;
	getnames=yes;
	guessingrows=all;
run;

/*http://www.bibliotecavirtual.sp.gov.br/temas/sao-paulo/sao-paulo-populacao-do-estado.php
De acordo com as estimativas populacionais da Fundação SEADE (novembro de 2018), o estado de São Paulo possui 43.993.159 habitantes. Com uma área territorial de 248.219 km², 
a densidade demográfica é de 177,23 habitantes por km².
*/

data SUPPORT_BRAZIL_DATA;
	set SUPPORT_BRAZIL_DATA;
	uf = tranwrd(uf,';','');
	governador_2019 = propcase(governador_2019);
	gentilico = tranwrd(gentilico,'&aacute;','a');
	gentilico = tranwrd(gentilico,'&eacute;','e');
	gentilico = tranwrd(gentilico,'&iacute;','i');
	gentilico = tranwrd(gentilico,'&oacute;','o');
	gentilico = tranwrd(gentilico,'&uacute;','u');
	gentilico = tranwrd(gentilico,'&atilde;','a');
	gentilico = tranwrd(gentilico,'&acirc;','a');
	gentilico = tranwrd(gentilico,'&ocirc;','o');
	governador_2019 = tranwrd(governador_2019,'&aacute;','a');
	governador_2019 = tranwrd(governador_2019,'&eacute;','e');
	governador_2019 = tranwrd(governador_2019,'&iacute;','i');
	governador_2019 = tranwrd(governador_2019,'&oacute;','o');
	governador_2019 = tranwrd(governador_2019,'&uacute;','u');
	governador_2019 = tranwrd(governador_2019,'&atilde;','a');
	governador_2019 = tranwrd(governador_2019,'&acirc;','a');
	governador_2019 = tranwrd(governador_2019,'&ocirc;','o');
	governador_2019 = tranwrd(governador_2019,';','');
	capital_2010 = tranwrd(capital_2010,'&aacute;','a');
	capital_2010 = tranwrd(capital_2010,'&eacute;','e');
	capital_2010 = tranwrd(capital_2010,'&iacute;','i');
	capital_2010 = tranwrd(capital_2010,'&oacute;','o');
	capital_2010 = tranwrd(capital_2010,'&uacute;','u');
	capital_2010 = tranwrd(capital_2010,'&atilde;','a');
	capital_2010 = tranwrd(capital_2010,'&otilde;','o');
	capital_2010 = tranwrd(capital_2010,'&acirc;','a');
	capital_2010 = tranwrd(capital_2010,'&ocirc;','o');
	capital_2010 = tranwrd(capital_2010,';','');
	governador_2019 = tranwrd(governador_2019,'Da','da');
	governador_2019 = tranwrd(governador_2019,'De','de');
	governador_2019 = tranwrd(governador_2019,'Dos','dos');
	governador_2019 = tranwrd(governador_2019,' E ',' e ');
run;

data SUPPORT_WORLD_DATA(rename=(pop=population_2020 net=net_change));
	set SUPPORT_WORLD_DATA;
	length pop 8.;
	pop = input(population_2020,COMMA13.);
	net = input(net_change,COMMA13.);
	land_area_km = input(land_area,COMMA13.);
	drop Population_2020 net_change land_area;

run;

/**************************************************************************
	Standardizing names of countries
***************************************************************************/

data SUPPORT_WORLD_DATA;
	set work.support_world_data(rename=(country_name=name_changing));
	/*Data Synch:
	Support World Hash Country Missing = Burma
	Support World Hash Country Missing = Congo (Brazzaville)
	Support World Hash Country Missing = Congo (Kinshasa)
	Support World Hash Country Missing = Cote d'Ivoire
	Support World Hash Country Missing = Czechia
	Support World Hash Country Missing = Diamond Princess
	Support World Hash Country Missing = Korea, South
	Support World Hash Country Missing = Kosovo
	Support World Hash Country Missing = MS Zaandam
	Support World Hash Country Missing = Saint Kitts and Nevis
	Support World Hash Country Missing = Saint Vincent and the Grenadines
	Support World Hash Country Missing = Sao Tome and Principe
	Support World Hash Country Missing = Taiwan*
	Support World Hash Country Missing = West Bank and Gaza

	https://geology.com/world/burma-satellite-image.shtml
	Names adaptation from one source to another
	*/
	length Country_Name $ 40.;
	Country_Name = name_changing;

	if country_name = 'Myanmar' then country_name = 'Burma';
	if country_name = 'Congo' then country_name = 'Congo (Brazzaville)';
	if country_name = 'DR Congo' then country_name = 'Congo (Kinshasa)';
	if country_name = "Côte d'Ivoire" then country_name = "Cote d'Ivoire";

	if country_name = 'Saint Kitts & Nevis' then country_name = 'Saint Kitts and Nevis';
	if country_name = 'St. Vincent & Grenadines' then country_name = 'Saint Vincent and the Grenadines';
	if country_name = 'Sao Tome & Principe' then country_name = 'Sao Tome and Principe';
	if country_name = 'Taiwan' then country_name = 'Taiwan*';
	
	drop name_changing;

run;
/*
proc sql;

	select *
	from work.support_world_data
	where country_name contains '&'
	order by country_name;
	
	select *
	from work.control_panel_world
	where location in ('MS Zaandam','Diamond Princess','Taiwan*')
	or location contains ' and '
	order by location;

quit;
*/