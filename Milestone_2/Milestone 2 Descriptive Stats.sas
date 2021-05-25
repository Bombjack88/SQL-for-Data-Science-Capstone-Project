/* SQL for Data Science Capstone Project - Milestone 2: Descriptive Stats */

/* LIBNAMES*/

libname BD "C:\SASstg\DDE\IFM\Data\Controlo_qualidade\Daniel_Silva\Base_Dados_Coursera";

OPTION COMPRESS=YES;
OPTION VALIDVARNAME=V7;


/* Exploring the data*/

/* #1 Table_1: BD.ATHLETE_INFO N_OBS=135.571*/

data Table_1;
set BD.ATHLETE_INFO;
run;


proc sql;
select Count(ID) as count
from Table_1;
quit;

/* #1.1 Variable: Height*/

proc Sql;
create table Height_NA as
select *
from Table_1
where height='NA';
quit;

/*NA values = 33.916 (25% precent NA)*/

proc sql;
select Count(ID) as count_NA
from Height_NA;
quit;

/* Descriptive statistics without NA*/
	/* Height*/

proc sql;
Create table  Stats_Height as 
select Count(Height) as count, 
mean(Height) as mean,
min(Height) as min,
max(Height) as max
from 
(select INPUT(Height, 4.) as Height
from BD.ATHLETE_INFO
where height not in ('NA'));
quit;

/* Height by sex*/

proc sql;
Create table  Stats_Height as 
select sex, Count(Height) as count, 
mean(Height) as mean,
min(Height) as min,
max(Height) as max
from 
(select sex, INPUT(Height, 4.) as Height
from BD.ATHLETE_INFO
where height not in ('NA'))
group by Sex;
quit;

/* graphs*/

data Males_Height;
set BD.ATHLETE_INFO;
height_2=INPUT(Height, 4.);
where height not in ('NA') and sex='M';
run;

PROC SGPLOT DATA = Males_Height;
 HISTOGRAM height_2;
  Density height_2;
 TITLE "Olympic Men's Height";
RUN; 


data Females_Height;
set BD.ATHLETE_INFO;
height_2=INPUT(Height, 4.);
where height not in ('NA') and sex='F';
run;

PROC SGPLOT DATA = Females_Height;
 HISTOGRAM height_2;
  Density height_2;
 TITLE "Olympic Wonen's Height";
RUN; 


/*#1.2 Variable: Weight */

proc sql;
create table Weight_NA as
select *
from Table_1
where Weight='NA';
quit;

/*NA values =34.885 (25% precent NA)*/

proc sql;
select Count(ID) as count_NA
from Weight_NA;
quit;

/* Descriptive statistics without NA*/

/*Weight*/

proc sql;
Create table  Stats_Weight as 
select Count(Weight) as count, 
mean(Weight) as mean,
min(Weight) as min,
max(Weight) as max
from 
(select INPUT(Weight, 4.) as Weight
from BD.ATHLETE_INFO
where Weight not in ('NA'));
quit;

/* Weight by sex*/

proc sql;
Create table  Stats_Weight as 
select sex, Count(Weight) as count, 
mean(Weight) as mean,
min(Weight) as min,
max(Weight) as max
from 
(select sex, INPUT(Weight, 4.) as Weight
from BD.ATHLETE_INFO
where Weight not in ('NA'))
group by Sex;
quit;


/*#1.3 Variable: Sex*/

/* Athlete by gender*/

proc sql;
create table gender as
select sex, count(ID) as N_Athlete
from BD.Athlete_info
group by sex;
quit;

*****************************************************************************************;

/* #2 Table_2: BD.EVENT_TABLE N_OBS=269.731*/

data Table_2;
set BD.EVENT_TABLE;
run;


proc sql;
select Count(ID) as count
from Table_2;
quit;

/* #2.1 Variable: Games */

proc Sql;
create table Count_games as
select games, count(games)as count
from Table_2
group by games
order by count descending;
quit;

/* #2.2 Variable: Age */

proc sql;
create table Age_NA as
select *
from Table_2
where Age='NA';
quit;


proc sql;
select Count(ID) as count
from Age_NA ;
quit;


proc sql;
Create table  Age as 
select Count(Age) as count, 
mean(Age) as mean,
min(Age) as min,
max(Age) as max
from (select INPUT(age, 4.) as age
from  BD.EVENT_table)
;
run;

proc sql;
create table Age_group as
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
end as group_age
from (select INPUT(age, 4.) as age
from  BD.EVENT_table);
quit;

proc sql;
create table  group_age_count as 
select group_age, count(age) as count
from  Age_group
where group_age not in ('')
group by group_age
order by group_age asc;
quit;

* graphs;

PROC SGPLOT DATA = Age_group;
 VBAR group_age;
 TITLE 'Olympic Athletes by Age';
RUN; 


/* #2.3 Variable: NOC*/

/* Athlete by NOC(Country)*/

proc sql;
create table athlete_country as 
select count(distinct ID) as N_Athlete,
b.region
from BD.Event_table as a left join BD.NOC_REGIONS as b
on a.NOC=b.NOC
group by region
order by N_Athlete desc;
quit; 


/* #2.4 Variables: Sport and Event*/

/* Sport by Event*/

proc sql;
create table Sport_count_event as
select Sport, count (Event) as Count_event
from (select distinct Sport, Event
from BD.Event_table)
group by Sport
order by count_event descending;
run; 

/* Events of Sport in (Shooting','Athletics')*/

proc sql;
create table Sport_count_event as
select Sport, Event 
from (select distinct Sport, Event
from BD.Event_table)
where Sport in ('Shooting','Athletics')
group by Sport;
run;

/* #2.5 Variable: medals*/ 

proc sql;
create table count_medals as
select distinct(medal) as medals, Count(medals) as count_medlas
from BD.Event_table
group by medals;
run;

*graph;

PROC SGPLOT DATA = BD.Event_table;
 VBAR medal;
 TITLE 'Olympic Athletes by medals';
RUN; 

/* Medals by country*/

proc sql;
create table medals_country as 
select b.region, 
a.medal, 
count(ID) as N_medals
from BD.Event_table as a left join BD.NOC_REGIONS as b
on a.NOC=b.NOC
where medal not in ('NA')
group by b.region, a.medal
order by N_medals desc;
quit; 

/* Athlete with more medals*/

proc sql;
create table athlete_medals as 
select distinct (a.ID),
C.Name,
b.region,
count(a.medal) as N_medals
from BD.Event_table as a left join BD.NOC_REGIONS as b on a.NOC=b.NOC
left join BD.Athlete_info as c on a.ID=c.ID
where medal not in ('NA')
group by a.ID
order by N_medals desc;
quit; 