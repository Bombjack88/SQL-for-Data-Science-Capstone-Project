/* SQL for Data Science Capstone Project - Milestone 1: Project Proposal and Data Selection/Preparation */

/* #0.1 - IMPORT DATA*/

/*
SportsStats (Olympics Dataset - 120 years of data)

SportsStats is a sports analysis firm partnering with local news and elite personal trainers to provide “interesting” insights to help 
their partners.  Insights could be patterns/trends highlighting certain groups/events/countries, etc. for the purpose of developing a 
news story or discovering key health insights.

*/


libname BD "C:\SASstg\DDE\IFM\Data\Controlo_qualidade\Daniel_Silva\Base_Dados_Coursera";

OPTION COMPRESS=YES;
OPTION VALIDVARNAME=V7;


proc import datafile="C:\SASstg\DDE\IFM\Data\Controlo_qualidade\Daniel_Silva\Base_Dados_Coursera\athlete_events.csv"
        out=athlete_events
        dbms=csv
        replace;
     getnames=yes;
	 GUESSINGROWS=5000;
run;


proc import datafile="C:\SASstg\DDE\IFM\Data\Controlo_qualidade\Daniel_Silva\Base_Dados_Coursera\noc_regions.csv"
        out=noc_regions
        dbms=csv
        replace;
     getnames=yes;
run;


data BD.athlete_events;
set athlete_events;
run;

data BD.NOC_REGIONS;
set NOC_REGIONS;
run;

/* # 0.2 - Create data tables with the information */

data athlete_events;
set BD.athlete_events;
run;

data NOC_REGIONS;
set BD.NOC_REGIONS;
run;

/* #1 - CLEANING THE DATA*/

/* #1.1 Count*/

	/* 271.116 obs*/

proc sql;
select Count(ID) 
from athlete_events;
quit;

	/*230 obs*/

proc sql;
select Count(Noc)
from NOC_REGIONS;
quit;

/* # 1.2 - Looking for duplicating rows - DISTINCT BY ALL VARIABLES*/

/* Option: Clean data from duplicates - 269.731 distinct obs (1.385 duplicate obs)*/ 


proc sql;
create table athlete_events as
select distinct ID,
Name,
Sex,
AGE,
Height,
Weight,
Team,
NOC,
Games,
Year,
Season,
City,
Sport,
Event,
Medal
from athlete_events;
quit;


proc sql;
select Count(ID) 
from distinct_athlete_events;
quit;

/* # 1.2 Athlete data - Create a table with the information about athletes*/


/*## 1.2.1 - 1st try*/

proc sql;
create table Athlete as
select distinct ID,
Name,
Sex,
AGE,
Height,
Weight,
Team,
NOC

from athlete_events;
quit;

/* Exists duplicates  - Why ?*/

proc sql;
create table duplicates as
select ID, count
from (
select ID, 
Count(id) as count
from Athlete
group by ID)
where count >=2;
quit;

/* Analizing the Duplicates - Reason: different age in different Years */
/* Solution - Replace Age and calculate birthdate  (did not work)*/

proc sql;
create table duplicates_info as
select ID,
Name,
Sex,
Age,
Height,
Weight,
Team,
NOC
from Athlete
where ID in 
(select ID
from duplicates);
quit;


/*## 1.2.2 - 2nd try (implementing solution 1 - calculate birthdate ) */

proc sql;
Create table Athlete as
select distinct ID,
Name,
Sex,
Birthdate,
Height,
Weight,
Team,
NOC
from (
select ID,
Name,
Sex,
Year - INPUT(Age, 4.) as Birthdate,
Height,
Weight,
Team,
NOC
from athlete_events);
quit;

/* Exists duplicates  - Why ?*/

proc sql;
create table duplicates as
select ID, count
from (
select ID, 
Count(id) as count
from Athlete
group by ID)
where count >=2;
quit;


/* Analizing the duplicates - Reason: In some cases calculating the birthdate using the Age could give different years:
	Ex: ex:ID 100046 - Year: 2008 24 years old (birthdate year = 1984)  / Year: 2012 27 years old (birthdate year = 1985) */
	/* Solution - Eliminate variable 'Age' from the table Athlete*/

proc sql;
create table duplicates_info as
select ID,
Name,
Sex,
Birthdate,
Height,
Weight,
Team,
NOC
from Athlete
where ID in 
(select ID
from duplicates);
quit;


/*## 1.2.3 - 3rd try (implementing solution 2) */


proc sql;
create table Athlete as
select distinct ID,
Name,
Sex,
Height,
Weight,
Team,
NOC

from athlete_events;
quit;

/* Identify duplicates*/

proc sql;
create table duplicates as
select ID, count
from (
select ID, 
Count(id) as count
from Athlete
group by ID)
where count >=2;
quit;

/* Analizing the Duplicates - Reason: athlete could have two different teams (this variable not make sense
sometimes is the country, other is the country with underscore and other seem to be the real team) */
	/* Solution - Eliminate variable 'Team' from the table Athlete*/

proc sql;
create table duplicates_info as
select ID,
Name,
Sex,
Height,
Weight,
Team,
NOC
from Athlete
where ID in 
(select ID
from duplicates);
quit;


/*## 1.2.4 - 4th try (implementing solution) */

proc sql;
create table Athlete as
select distinct ID,
Name,
Sex,
Height,
Weight,
NOC
from athlete_events;
quit;


/* Identify duplicates*/

proc sql;
create table duplicates as
select ID, count
from (
select ID, 
Count(id) as count
from Athlete
group by ID)
where count >=2;
quit;

/* Analizing the Duplicates (same athlete different NOC) */
/* Solution - Eliminate variable 'NOC' from the table Athlete*/


proc sql;
create table duplicates_info as
select ID,
Name,
Sex,
Height,
Weight,
NOC
from Athlete
where ID in 
(select ID
from duplicates);
quit;



/*## 1.2.5 - 5th try (implementing solution) */

proc sql;
create table Athlete as
select distinct ID,
Name,
Sex,
Height,
Weight,
Sport
from athlete_events;
quit;

/* Identify duplicates*/

proc sql;
create table duplicates as
select ID, count
from (
select ID, 
Count(id) as count
from Athlete
group by ID)
where count >=2;
quit;

/* Analizing the Duplicates */

proc sql;
create table duplicates_info as
select ID,
Name,
Sex,
Height,
Weight,
Sport
from Athlete
where ID in 
(select ID
from duplicates);
quit;

/* Create Table Athlete_info*/

proc sql;
create table BD.Athlete_info as
select distinct
ID,
Name,
Sex,
Height,
Weight
from Athlete;
quit;

/* Extra - Teste*/

proc sort data=Athlete_info nodupkey; by ID; run;

/* # 1.2 Games_info - Create a table with the information about the Olympic Games*/

proc sql;
create table Games as
select distinct
Games,
Year,
Season,
City
from athlete_events;
quit;

proc sql;
create table duplicates as
select Games, count
from (
select Games, 
Count(Games) as count
from Games
group by Games)
where count >=2;
quit;

/* Analizing the duplicates */

proc sql;
create table duplicates_info as
select Games,
Year,
Season,
City
from Games
where Games in 
(select Games
from duplicates);
quit;

/*create the table games_info*/

proc sql;
create table Games as
select distinct
Games,
Year,
Season,
City
from athlete_events;
quit;

/* correct a value*/

proc sql;
update Games
set city='Melbourne'
where Games = '1956 Summer';
quit;

proc sql;
create table Games as
select distinct
Games,
Year,
Season,
City
from Games;
quit;

proc sql;
create table duplicates as
select Games, count
from (
select Games, 
Count(Games) as count
from Games
group by Games)
where count >=2;
quit;

proc sql;
create table BD.Games_info as
select *
from Games;
quit;

/* # 1.3 Event_table - Create a table with the information about the event*/

proc sql;
create table BD.athlete_events as
select distinct ID,
Name,
Sex,
AGE,
Height,
Weight,
Team,
NOC,
Games,
Year,
Season,
City,
Sport,
Event,
Medal
from BD.athlete_events;
quit;

proc sql;
create table Event_table as 
select
ID,
Games,
Age,
Team,
NOC,
Event,
Sport,
Medal
from BD.athlete_events;
quit;

proc sort data=Event_table nodupkey; by  _all_; run;

proc sql;
create table BD.Event_table as
select*
from Event_table;
quit;


/* # 1.4 NOC - NOC information (no duplicates)*/

proc sql;
create table NOC_Count as
select NOC, count(NOC)
from NOC_REGIONS
group by NOC;
quit;

proc sql;
create table BD.NOC as
select *
from NOC_REGIONS;
quit;

/* #2 - EXPLORING DATA*/

/* Athlete by country*/

proc sql;
create table athlete_country as 
select count(distinct ID) as N_Athlete,
b.region
from BD.Event_table as a left join BD.NOC_REGIONS as b
on a.NOC=b.NOC
group by region
order by N_Athlete desc;
quit; 

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

/* Games with more observations*/

proc sql; 
create table Games_obs as
select distinct(a.Games), b.City, count(ID) as N_obs
from BD.Event_table as a left join BD.Games_info as b
on a.Games=b.Games
group by b.Games
order by N_obs desc;
quit;

/* Athlete by gender*/

proc sql;
create table gender as
select sex, count(ID) as N_Athlete
from BD.Athlete_info
group by sex;
quit;
