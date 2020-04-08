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