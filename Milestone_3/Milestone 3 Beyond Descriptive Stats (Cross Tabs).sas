/* SQL for Data Science Capstone Project - Milestone 3: Beyond Descriptive Stats (CROSS TABS) */

/*LIBNAMES*/

libname BD "C:\SASstg\DDE\IFM\Data\Controlo_qualidade\Daniel_Silva\Base_Dados_Coursera";

OPTION COMPRESS=YES;
OPTION VALIDVARNAME=V7;

/* Age Group X medals*/

proc sql;
create table Cross_tab_table as
select *,
case
	when age between 10 and 15 then 'group_10_15'
	when age between 15 and 20 then 'group_15_20'
	when age between 20 and 25 then 'group_20_25'
	when age between 25 and 30 then 'group_25_30'
	when age between 30 and 35 then 'group_30_35'
	when age between 35 and 40 then 'group_35_40'
	when age between 40 and 50 then 'group_40_50'
	when age between 50 and 60 then 'group_50_60'
	when age between 60 and 70 then 'group_60_70'
	when age between 70 and 80 then 'group_70_80'
	when age between 80 and 90 then 'group_80_90'
	when age between 90 and 100 then 'group_90_100'
end as Age_Group
from (select INPUT(age, 4.) as age, medal
from  BD.EVENT_table);
quit;



PROC FREQ DATA=Cross_tab_table;
    TABLES Age_Group*medal/ chisq measures cmh;
RUN;


/* Sex X medals (female)*/

proc sql;
create table Cross_tab_table_female as
select *,
case
	when age between 10 and 15 then 'group_10_15'
	when age between 15 and 20 then 'group_15_20'
	when age between 20 and 25 then 'group_20_25'
	when age between 25 and 30 then 'group_25_30'
	when age between 30 and 35 then 'group_30_35'
	when age between 35 and 40 then 'group_35_40'
	when age between 40 and 50 then 'group_40_50'
	when age between 50 and 60 then 'group_50_60'
	when age between 60 and 70 then 'group_60_70'
	when age between 70 and 80 then 'group_70_80'
	when age between 80 and 90 then 'group_80_90'
	when age between 90 and 100 then 'group_90_100'
end as Age_Group
from (select INPUT(age, 4.) as age, medal
from  BD.EVENT_table as a left join BD.Athlete_info as b on a.ID=b.ID
where sex ='F');
quit;


PROC FREQ DATA=Cross_tab_table_female;
    TABLES Age_Group*medal/ chisq measures cmh;
RUN;


/* Sex X medals (male)*/

proc sql;
create table Cross_tab_table_male as
select *,
case
	when age between 10 and 15 then 'group_10_15'
	when age between 15 and 20 then 'group_15_20'
	when age between 20 and 25 then 'group_20_25'
	when age between 25 and 30 then 'group_25_30'
	when age between 30 and 35 then 'group_30_35'
	when age between 35 and 40 then 'group_35_40'
	when age between 40 and 50 then 'group_40_50'
	when age between 50 and 60 then 'group_50_60'
	when age between 60 and 70 then 'group_60_70'
	when age between 70 and 80 then 'group_70_80'
	when age between 80 and 90 then 'group_80_90'
	when age between 90 and 100 then 'group_90_100'
end as Age_Group
from (select INPUT(age, 4.) as age, medal
from  BD.EVENT_table as a left join BD.Athlete_info as b on a.ID=b.ID
where sex ='M');
quit;


PROC FREQ DATA=Cross_tab_table_male;
    TABLES Age_Group*medal/ chisq measures cmh;
RUN;

/* N_participants (numeric) x N_medals (numeric) - information by country*/

proc sql;
create table N_participants_medals as
select b.region as country, count (distinct a.ID) as N_participants,  
SUM(case when medal not in ('NA') then 1 else 0 end)  as N_medals 
from  BD.EVENT_table as a left join BD.NOC_REGIONS as b on a.NOC=b.NOC
where country not in ('')
group by country;
quit;


ods graphics on;

PROC CORR DATA=N_participants_medals PLOTS=SCATTER(NVAR=all);
   VAR N_participants N_medals;
RUN;