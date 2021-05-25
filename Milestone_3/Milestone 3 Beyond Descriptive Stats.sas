/* SQL for Data Science Capstone Project - Milestone 3: Beyond Descriptive Stats */

/* LIBNAMES*/

libname BD "C:\SASstg\DDE\IFM\Data\Controlo_qualidade\Daniel_Silva\Base_Dados_Coursera";

OPTION COMPRESS=YES;
OPTION VALIDVARNAME=V7;

/*#1 Has the number of athletes, countries, and events changed over time?*/

proc sql;
create table overt_time as
select b.year, b.season, count(distinct a.ID) as Athletes, count(distinct a.NOC) as Countries, count(distinct a.Event) as Events
from BD.ATHLETE_EVENTS as a left join BD.GAMES_INFO as b on a.games=b.games
group by b.year, b.season;
quit;


proc gplot data = overt_time;
plot Athletes*year=season/ caxis=blue hminor=0;
TITLE 'Number of athletes over time';
RUN;

/* #2 Demographics of Olympics*/

/* Total (male and female)*/

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

/* Separated by gender - male and female */

proc sql;
create table Age_group_sex as
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
from (select INPUT(a.age, 4.) as age, b.sex
from  BD.EVENT_table as a left join BD.ATHLETE_INFO as b on a.ID=b.ID);
quit;


proc sql;
create table  group_age_count as 
select sex, group_age, count(age) as count
from  Age_group_sex
where group_age not in ('')
group by sex, group_age
order by sex, group_age asc;
quit;

proc sql;
create table  percent_group_age_count as
Select sex, group_age,count,
(Count/SUM(count))*100 as percent,
SUM(count) as Total
from group_age_count
group by sex;
quit;

/* Age group medals*/

proc sql;
create table Age_group_sex_medal as
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
from (select INPUT(a.age, 4.) as age, b.sex, a.medal
from  BD.EVENT_table as a left join BD.ATHLETE_INFO as b on a.ID=b.ID);
quit;


proc sql;
create table  Medal_group_age as
Select sex, group_age,
SUM(case medal when 'Gold' then 1 else 0 end) as Count_Gold,
SUM(case medal when 'Silver' then 1 else 0 end) as Count_Silver,
SUM(case medal when 'Bronze' then 1 else 0 end) as Count_Bronze,
SUM(case medal when 'NA' then 1 else 0 end) as Count_NA,
Count(medal) as Total
from Age_group_sex_medal
where group_age not in ('')
group by sex, group_age;
quit;

proc sql;
create table  Percent_Medal_group_age as
Select *,
((Count_Gold + Count_Silver + Count_Bronze)/Total)*100 as percent_medals,
(Count_Gold / total)*100 as percent_gold,
(Count_Silver / total)*100 as percent_silver,
(Count_bronze / total)*100 as percent_bronze
from Medal_group_age;
quit;

/* Age group medals over the time*/

proc sql;
create table Age_group_sex_medal_year as
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
from (select INPUT(a.age, 4.) as age, b.sex, a.medal, c.Year, c.Season
from  BD.EVENT_table as a left join BD.ATHLETE_INFO as b on a.ID=b.ID
left join BD.GAMES_INFO as c on a.games=c.games);
quit;


proc sql;
create table  Medal_group_age_year as
Select year, season, sex, group_age,
SUM(case medal when 'Gold' then 1 else 0 end) as Count_Gold,
SUM(case medal when 'Silver' then 1 else 0 end) as Count_Silver,
SUM(case medal when 'Bronze' then 1 else 0 end) as Count_Bronze,
SUM(case medal when 'NA' then 1 else 0 end) as Count_NA,
Count(medal) as Total
from Age_group_sex_medal_year
where group_age not in ('')
group by year, season, sex, group_age;
quit;


proc sql;
create table  Percent_Medal_group_age_year as
Select *,
((Count_Gold + Count_Silver + Count_Bronze)/Total)*100 as percent_medals
from Medal_group_age_year;
quit;

proc sql;
create table  Percent_Medal_group_age_year as
Select year, season, sex,
(case percent_medals when Max(percent_medals) then group_age else '' end) as group_age, 
Max(percent_medals) as Maximo
from Percent_Medal_group_age_year
where year>=1998 
group by  year, season, sex;
quit;

proc sql;
create table  Percent_Medal_group_age_year as
select *
from Percent_Medal_group_age_year
where group_age not in ('')
order by season, sex, year;
quit;

/* #2 Which country has been most regular in Olympics, who has been winning the most medals? 


/* Medals by country - type of medal*/

proc sql;
create table medals_country as 
select b.region as Country, 
a.medal, 
count(ID) as N_medals
from BD.Event_table as a left join BD.NOC_REGIONS as b
on a.NOC=b.NOC
where medal not in ('NA')
group by b.region, a.medal
order by N_medals desc;
quit; 


/* Medals by country - ignoring the type of medal*/

proc sql outobs=10;
create table medals_country as 
select b.region as Country,
count(ID) as N_medals
from BD.Event_table as a left join BD.NOC_REGIONS as b
on a.NOC=b.NOC
where medal not in ('NA')
group by b.region
order by N_medals desc;
quit; 


/* Medals by country - year, season*/

proc sql;
create table medals_country_year_season as 
select c.year, C.season, b.region as Country, 
count(a.ID) as N_medals
from BD.Event_table as a left join BD.NOC_REGIONS as b on a.NOC=b.NOC left join BD.GAMES_INFO as c on a.games=c.games
where medal not in ('NA')
group by c.year, c.season, b.region
order by year asc;
quit; 

proc sql;
create table max_medals_country_year as
select year, season, 
(case  N_medals when max(N_medals) then country else '' end ) as country,
max(N_medals) as Total_medals
from medals_country_year_season
group by year, season;
quit;

proc sql;
create table max_medals_country_year as
select *
from max_medals_country_year
where country not in ('');
quit;

/* Times a country is the one with more medals (season=summer and winter)*/

proc sql;
create table times_more_medals as
select country, count(country) as Times_more_medals
from max_medals_country_year
group by country;
quit;


/* Times a country is the one with more medals - year by season*/

proc sql;
create table times_more_medals as
select country, season, count(country) as Times_more_medals
from max_medals_country_year
group by country, season
order by season;
quit;

/* # 3  Which sports in which season Olympics is popular amongst countries (metrics: number of participants and numbre of medals)?*/

/* sport by age*/
 
	/*by age group*/

proc sql;
create table Age_group_sport as
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
from (select INPUT(a.age, 4.) as age, a.sport
from  BD.EVENT_table as a left join BD.ATHLETE_INFO as b on a.ID=b.ID
left join BD.GAMES_INFO as c on a.games=c.games);
quit;


proc sql;
create table  Age_group_sport as 
select sport, group_age, count(age) as count
from  Age_group_sport
where group_age not in ('')
group by sport, group_age
order by group_age asc;
quit;


proc sql;
create table max_medals_country_year as
select sport,  
(case  count when max(count) then group_age  else '' end ) as group_age ,
max(count) as count_participants
from Age_group_sport
group by sport;
quit;

proc sql;
create table max_medals_country_year  as
select *
from max_medals_country_year
where group_age not in ('')
order by count_participants desc;
quit;

proc sort data=max_medals_country_year nodupkey; by sport; run;
proc sort data=max_medals_country_year; by descending count_participants; run;

	/* Sport by age  (count, mean, min, max (descending mean)*/			


proc sql;
Create table  Stats_age as 
select Sport,
Count(age) as count, 
mean(age) as mean,
min(age) as min,
max(age) as max
from 
(select Sport, INPUT(age, 4.) as age
from BD.EVENT_TABLE
where age not in ('NA'))
group by sport
order by mean asc;
quit;	

/* Countries by sports (metrics participants, medals)*/


proc sql;
create table Countries_sport as
select a.sport, b.region as country, count (distinct a.ID) as N_participants,  
SUM(case when medal not in ('NA') then 1 else 0 end)  as N_medals 
from  BD.EVENT_table as a left join BD.NOC_REGIONS as b on a.NOC=b.NOC
group by sport, country;
quit;

	/* metric participants*/

proc sql;
create table Countries_sport_participants as
select country,
(case when N_participants=max(N_participants) then sport else '' end) as sport,
max(N_participants) as Maximo
from Countries_sport
group by country;
quit;

proc sql;
create table Countries_sport_participants as
select *
from Countries_sport_participants
where sport not in ('') and country not in ('')
order by maximo desc;
quit;

	/* metric medals*/

proc sql;
create table Countries_sport_medals as
select country,
(case when N_medals=max(N_medals) then sport else '' end) as sport,
max(N_medals) as Maximo
from Countries_sport
group by country;
quit;

proc sql;
create table Countries_sport_medals as
select *
from Countries_sport_medals
where sport not in ('') and country not in ('')
order by maximo desc;
quit;