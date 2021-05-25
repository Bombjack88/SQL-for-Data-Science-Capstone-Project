/* SQL for Data Science Capstone Project - Milestone 4: Presenting Your Findings (Storytelling)*/

/* LIBNAMES*/

libname BD "C:\SASstg\DDE\IFM\Data\Controlo_qualidade\Daniel_Silva\Base_Dados_Coursera";

OPTION COMPRESS=YES;
OPTION VALIDVARNAME=V7;

/* #1 What has been the demographics of Olympics – what age group, gender (sex) and countries have more participants and better results? 

/* #1.1  Variable: Age */

/* #1.1.1 Age Group*/

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
end as Age_Group
from (select INPUT(age, 4.) as age
from  BD.EVENT_table);
quit;

proc sql;
create table  group_age_count as 
select Age_Group, count(age) as count
from  Age_Group
where Age_Group not in ('')
group by Age_Group
order by Age_Group asc;
quit;

* graphs;
PROC SGPLOT DATA = Age_group;
 VBAR Age_Group;
 TITLE 'Olympic Athletes by Age';
RUN; 


/* #1.1.2 - Descriptive Stats (age)*/

proc sql;
create table Age_NA as
select *
from BD.EVENT_TABLE
where Age='NA';
quit;

proc sql;
select Count(ID) as count
from Age_NA;
quit;

proc sql;
Create table  Age as 
select Count(Age) as count, 
mean(Age) as mean,
min(Age) as min,
max(Age) as max
from (select INPUT(age, 4.) as age
from  BD.EVENT_table);
run;

proc sql;
create table Age_10 as
select *, b.name
from BD.EVENT_TABLE as a left join BD.Athlete_INFO as b on a.ID=b.ID
where Age='10';
quit;

proc sql;
create table Age_97 as
select *, b.name
from BD.EVENT_TABLE as a left join BD.Athlete_INFO as b on a.ID=b.ID
where Age='97';
quit;


/* #1.1.3  - Average Age  by year and games*/


proc sql;
Create table  Age as 
select b.year, b.season,
mean(INPUT(age, 4.)) as mean
from  BD.EVENT_table as a left join BD.Games_info as b
on a.Games=b.Games
group by b.year, b.season;
run;

proc sort data=age; by season year; run; 


/* line plot*/

symbol1 interpol=join;
proc gplot data = Age;
plot mean*year=season/hminor=0;
TITLE 'Average Age by Season Over Time';
RUN;

/* Compare two independent samples*/

proc ttest data=age sides=2 alpha=0.05 h0=0;
 	title "Two sample t-test example";
 	class Season; 
	var mean;
   run;

/* #1.1.3  - Age Group by Medals */
   
/* Age Group X medals - number of medals*/

proc sql;
create table Age_group_medal as
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
from (select INPUT(a.age, 4.) as age, /*b.sex,*/ a.medal
from  BD.EVENT_table as a left join BD.ATHLETE_INFO as b on a.ID=b.ID);
quit;


proc sql;
create table  Medal_group_age as
Select group_age,
SUM(case medal when 'Gold' then 1 else 0 end) as Count_Gold,
SUM(case medal when 'Silver' then 1 else 0 end) as Count_Silver,
SUM(case medal when 'Bronze' then 1 else 0 end) as Count_Bronze,
SUM(case medal when 'NA' then 1 else 0 end) as Count_NA,
Count(medal) as Total
from Age_group_medal
where group_age not in ('')
group by group_age;
quit;

/* Age Group X medals - percentage of medals*/

proc sql;
create table  Percent_Medal_group_age as
Select *,
((Count_Gold + Count_Silver + Count_Bronze)/Total)*100 as percent_medals,
(Count_Gold / total)*100 as percent_gold,
(Count_Silver / total)*100 as percent_silver,
(Count_bronze / total)*100 as percent_bronze
from Medal_group_age;
quit;


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


/* #1.2  Variable: Gender (sex) */


/* #1.2.1  Sex by height */


/* Descriptive statistics without NA*/
	/* Height*/

proc sql;
Create table  Stats_Height as 
select Count(Height) as count, 
mean(Height) as mean,
min(Height) as min,
max(Height) as max,
std(Height) as std
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
max(Height) as max,
std(Height) as std
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


/* #1.2.2  Sex by Weight */

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
max(Weight) as max,
std(Weight) as std
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
max(Weight) as max,
std(Weight) as std
from 
(select sex, INPUT(Weight, 4.) as Weight
from BD.ATHLETE_INFO
where Weight not in ('NA'))
group by Sex;
quit;


/* graphs*/

data Males_Weight;
set BD.ATHLETE_INFO;
Weight_2=INPUT(Weight, 4.);
where Weight not in ('NA') and sex='M';
run;

PROC SGPLOT DATA = Males_Weight;
 HISTOGRAM Weight_2;
  Density Weight_2;
 TITLE "Olympic Men's Weight";
RUN; 


data Females_Weight;
set BD.ATHLETE_INFO;
Weight_2=INPUT(Weight, 4.);
where Weight not in ('NA') and sex='F';
run;

PROC SGPLOT DATA = Females_Weight;
 HISTOGRAM Weight_2;
  Density Weight_2;
 TITLE "Olympic Wonen's Weight";
RUN; 


/*# 1.2.3  Athlete by gender (sex) */

proc sql;
create table gender as
select sex, count(ID) as N_Athlete
from BD.Athlete_info
group by sex;
quit;

/* #1.2.4  - Gender by year (separated by season)*/

proc sql;
Create table  Gender_year_season as 
select b.year, b.season, c.sex,
count(c.ID) as number
from  BD.EVENT_table as a left join BD.Games_info as b on a.Games=b.Games 
left join  BD.ATHLETE_INFO as c on a.Id=C.ID
group by b.year, b.season, c.sex;
run;

proc sort data=Gender_year_season; by season descending sex year; run; 

data Gender_year_season_summer;
set Gender_year_season;
where season='Summer';
run;

/* line plot*/

symbol1 interpol=join;
proc gplot data = Gender_year_season_summer;
plot number*year=sex/hminor=0;
TITLE 'Summer Games by Gender Over Time';
RUN;


data Gender_year_season_winter;
set Gender_year_season;
where season='Winter';
run;

/* line plot*/

symbol1 interpol=join;
proc gplot data = Gender_year_season_winter;
plot number*year=sex/hminor=0;
TITLE 'Winter Games by Gender Over Time';
RUN;


/* #1.2.5  - Medals by sex */


proc sql;
create table Medal_Sex as
select *
from (select b.sex, a.medal
from  BD.EVENT_table as a left join BD.ATHLETE_INFO as b on a.ID=b.ID);
quit;


proc sql;
create table  Medal_Sex as
Select sex,
SUM(case medal when 'Gold' then 1 else 0 end) as Count_Gold,
SUM(case medal when 'Silver' then 1 else 0 end) as Count_Silver,
SUM(case medal when 'Bronze' then 1 else 0 end) as Count_Bronze,
SUM(case medal when 'NA' then 1 else 0 end) as Count_NA,
Count(medal) as Total
from Medal_Sex
where sex in ('M','F')
group by sex;
quit;

/* Age Group X medals - percentage of medals*/

proc sql;
create table  Percent_Medal_Sex as
Select *,
((Count_Gold + Count_Silver + Count_Bronze)/Total)*100 as percent_medals,
(Count_Gold / total)*100 as percent_gold,
(Count_Silver / total)*100 as percent_silver,
(Count_bronze / total)*100 as percent_bronze
from Medal_Sex;
quit;

/* #1.3  Variable: Country */


/* #1.3.1 Country   */

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


/* Medals and participants by country*/

proc sql;
create table Countries_medals_participants as
select b.region as country, count (distinct a.ID) as N_participants,  
SUM(case when medal not in ('NA') then 1 else 0 end)  as N_medals 
from  BD.EVENT_table as a left join BD.NOC_REGIONS as b on a.NOC=b.NOC
group by country;
quit;

proc sort data=Countries_medals_participants; by descending N_medals; run;

data Countries_medals_participants;
set Countries_medals_participants;
percentage=(N_medals/N_participants)*100;
run;

/* #2 Which country has been most regular in Olympics, who has been winning more medals? 
	Which sports in which season Olympics is popular amongst the top countries? 


/* #2.1 Medals by country - year, season*/

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


/* #2.2 Sports by top 3 countries (USA, Russia and Germany)*/

proc sql;
create table medals_country_year_season_sport as 
select a.sport, c.year, c.season, b.region as Country, 
count(a.ID) as N_medals
from BD.Event_table as a left join BD.NOC_REGIONS as b on a.NOC=b.NOC left join BD.GAMES_INFO as c on a.games=c.games
where medal not in ('NA')
group by a.sport, c.year, c.season, b.region
order by year asc;
quit; 

data medals_country_year_season_sport;
set medals_country_year_season_sport;
where Country in ('USA','Russia', 'Germany');
run;


proc sql;
create table Sum_medals_country_season_sport as 
select Country, Season, Sport, sum(N_medals) as Total 
from medals_country_year_season_sport
group by Country, Season, Sport
order by country, total desc;
quit; 



/* #3 -  What effect does the host country have in the medals won at the Olympics?


/* Which countries have hosted Olympics and how many times ?*/


/* Olympics by country*/

data Games_Country;
set BD.GAMES_INFO;
length country $25;
if year='1896' and Season='Summer' then country='Greece';
if year='1900' and Season='Summer' then country='France';
if year='1904' and Season='Summer' then country='USA';
if year='1906' and Season='Summer' then country='Greece';
if year='1908' and Season='Summer' then country='UK';
if year='1912' and Season='Summer' then country='Sweden';
if year='1920' and Season='Summer' then country='Belgium';
if year='1924' and Season='Summer' then country='France';
if year='1928' and Season='Summer' then country='Netherlands';
if year='1932' and Season='Summer' then country='USA';
if year='1936' and Season='Summer' then country='Germany';
if year='1948' and Season='Summer' then country='UK';
if year='1952' and Season='Summer' then country='Finland';
if year='1956' and Season='Summer' then country='Australia';
if year='1960' and Season='Summer' then country='Italy';
if year='1964' and Season='Summer' then country='Japan';
if year='1968' and Season='Summer' then country='Mexico';
if year='1972' and Season='Summer' then country='Germany';
if year='1976' and Season='Summer' then country='Canada';
if year='1980' and Season='Summer' then country='Russia';
if year='1984' and Season='Summer' then country='USA';
if year='1988' and Season='Summer' then country='South Korea';
if year='1992' and Season='Summer' then country='Spain';
if year='1996' and Season='Summer' then country='USA';
if year='2000' and Season='Summer' then country='Australia';
if year='2004' and Season='Summer' then country='Greece';
if year='2008' and Season='Summer' then country='China';
if year='2012' and Season='Summer' then country='UK';
if year='2016' and Season='Summer' then country='Brazil';
if year='2020' and Season='Summer' then country='Japan';
if year='2024' and Season='Summer' then country='France';
if year='2028' and Season='Summer' then country='USA';
if year='1924' and Season='Winter' then country='France';
if year='1928' and Season='Winter' then country='Switzerland';
if year='1932' and Season='Winter' then country='USA';
if year='1936' and Season='Winter' then country='Germany';
if year='1948' and Season='Winter' then country='Switzerland';
if year='1952' and Season='Winter' then country='Norway';
if year='1956' and Season='Winter' then country='Italy';
if year='1960' and Season='Winter' then country='USA';
if year='1964' and Season='Winter' then country='Austria';
if year='1968' and Season='Winter' then country='France';
if year='1972' and Season='Winter' then country='Japan';
if year='1976' and Season='Winter' then country='Austria';
if year='1980' and Season='Winter' then country='USA';
if year='1984' and Season='Winter' then country='Serbia';
if year='1988' and Season='Winter' then country='Canada';
if year='1992' and Season='Winter' then country='France';
if year='1994' and Season='Winter' then country='Norway';
if year='1998' and Season='Winter' then country='Japan';
if year='2002' and Season='Winter' then country='USA';
if year='2006' and Season='Winter' then country='Italy';
if year='2010' and Season='Winter' then country='Canada';
if year='2014' and Season='Winter' then country='Russia';
if year='2018' and Season='Winter' then country='South Korea';
if year='2022' and Season='Winter' then country='China';
run;

proc sql;
create table Games_country_Stat as 
select a.country, /*b.noc,*/ count(a.year) as number
from Games_Country as a /*left join BD.NOC_REGIONS as b on a.country=b.region*/
group by country/*, noc*/
order by number desc;
quit;

/* country by season*/

proc sql;
create table Games_country_Stat as 
select a.country, a. season, /*b.noc,*/ count(a.year) as number
from Games_Country as a /*left join BD.NOC_REGIONS as b on a.country=b.region*/
group by country, season/*, noc*/
order by number desc;
quit;


/*country= USA (Summer)*/

proc sql;
create table medals_country as 
select c.year, b.region,  
count(ID) as N_medals
from BD.Event_table as a left join BD.NOC_REGIONS as b on a.NOC=b.NOC 
left join BD.Games_info as c on a.Games=c.Games
where medal not in ('NA') and b.region='USA' and c.season='Summer'
group by c.year, b.region
order by year;
quit; 


data medals_country;
set medals_country;
if year in (1904,1932,1964,1966)then ySpecial = 'y';
run;


/* line plot*/

symbol1 interpol=join;
proc gplot data = medals_country;
plot N_medals*year;
TITLE 'USA Medals Over the Years';
RUN;

/*country= USA (Winter)*/

proc sql;
create table medals_country as 
select c.year, b.region,  
count(ID) as N_medals
from BD.Event_table as a left join BD.NOC_REGIONS as b on a.NOC=b.NOC 
left join BD.Games_info as c on a.Games=c.Games
where medal not in ('NA') and b.region='USA' and c.season='Winter'
group by c.year, b.region
order by year;
quit; 


data medals_country;
set medals_country;
if year in (1932,1960,1980,2002) then ySpecial = 'y';
run;

/* line plot*/

symbol1 interpol=join;
proc gplot data = medals_country;
plot N_medals*year;
TITLE 'USA Medals Over the Years';
RUN;

/* all countries - Summer*/

proc sql;
create table medals_country_Summer as 
select c.year, b.region,  
count(ID) as N_medals
from BD.Event_table as a left join BD.NOC_REGIONS as b on a.NOC=b.NOC 
left join BD.Games_info as c on a.Games=c.Games
where medal not in ('NA') and b.region in 
('USA',
'France',
'Japan',
'Germany',
'Canada',
'Greece',
'UK',
'Italy',
'Norway',
'Switzerland',
'Australia',
'Austria',
'Russia',
'Finland',
'Netherlands',
'Belgium',
'China',
'Mexico',
'Sweden',
'Spain',
'South Korea',
'Brazil',
'Serbia') and c.season='Summer'
group by c.year, b.region
order by year;
quit; 

 data medals_country_Summer;
 set  medals_country_Summer;

if year=1896 and region='Greece' then x='Hosted';
if year=1900 and region='France' then x='Hosted';
if year=1904 and region='USA' then x='Hosted';
if year=1906 and region='Greece' then x='Hosted';
if year=1908 and region='UK' then x='Hosted';
if year=1912 and region='Sweden' then x='Hosted';
if year=1920 and region='Belgium' then x='Hosted';
if year=1924 and region='France' then x='Hosted';
if year=1928 and region='Netherlands' then x='Hosted';
if year=1932 and region='USA' then x='Hosted';
if year=1936 and region='Germany' then x='Hosted';
if year=1948 and region='UK' then x='Hosted';
if year=1952 and region='Finland' then x='Hosted';
if year=1956 and region='Australia' then x='Hosted';
if year=1960 and region='Italy' then x='Hosted';
if year=1964 and region='Japan' then x='Hosted';
if year=1968 and region='Mexico' then x='Hosted';
if year=1972 and region='Germany' then x='Hosted';
if year=1976 and region='Canada' then x='Hosted';
if year=1980 and region='Russia' then x='Hosted';
if year=1984 and region='USA' then x='Hosted';
if year=1988 and region='South Korea' then x='Hosted';
if year=1992 and region='Spain' then x='Hosted';
if year=1996 and region='USA' then x='Hosted';
if year=2000 and region='Australia' then x='Hosted';
if year=2004 and region='Greece' then x='Hosted';
if year=2008 and region='China' then x='Hosted';
if year=2012 and region='UK' then x='Hosted';
if year=2016 and region='Brazil' then x='Hosted';
if year=2020 and region='Japan' then x='Hosted';
if year=2024 and region='France' then x='Hosted';
if year=2028 and region='USA' then x='Hosted';

if year=1892 and region='Greece' then x='Before';
if year=1896 and region='France' then x='Before';
if year=1900 and region='USA' then x='Before';
if year=1902 and region='Greece' then x='Before';
if year=1904 and region='UK' then x='Before';
if year=1908 and region='Sweden' then x='Before';
if year=1916 and region='Belgium' then x='Before';
if year=1920 and region='France' then x='Before';
if year=1924 and region='Netherlands' then x='Before';
if year=1928 and region='USA' then x='Before';
if year=1932 and region='Germany' then x='Before';
if year=1944 and region='UK' then x='Before';
if year=1948 and region='Finland' then x='Before';
if year=1952 and region='Australia' then x='Before';
if year=1956 and region='Italy' then x='Before';
if year=1960 and region='Japan' then x='Before';
if year=1964 and region='Mexico' then x='Before';
if year=1968 and region='Germany' then x='Before';
if year=1972 and region='Canada' then x='Before';
if year=1976 and region='Russia' then x='Before';
if year=1980 and region='USA' then x='Before';
if year=1984 and region='South Korea' then x='Before';
if year=1988 and region='Spain' then x='Before';
if year=1992 and region='USA' then x='Before';
if year=1996 and region='Australia' then x='Before';
if year=2000 and region='Greece' then x='Before';
if year=2004 and region='China' then x='Before';
if year=2008 and region='UK' then x='Before';
if year=2012 and region='Brazil' then x='Before';
if year=2016 and region='Japan' then x='Before';
if year=2020 and region='France' then x='Before';
if year=2024 and region='USA' then x='Before';

if year=1900 and region='Greece' then x='After';
if year=1904 and region='France' then x='After';
if year=1908 and region='USA' then x='After';
if year=1910 and region='Greece' then x='After';
if year=1912 and region='UK' then x='After';
if year=1916 and region='Sweden' then x='After';
if year=1924 and region='Belgium' then x='After';
if year=1928 and region='France' then x='After';
if year=1932 and region='Netherlands' then x='After';
if year=1936 and region='USA' then x='After';
if year=1940 and region='Germany' then x='After';
if year=1952 and region='UK' then x='After';
if year=1956 and region='Finland' then x='After';
if year=1960 and region='Australia' then x='After';
if year=1964 and region='Italy' then x='After';
if year=1968 and region='Japan' then x='After';
if year=1972 and region='Mexico' then x='After';
if year=1976 and region='Germany' then x='After';
if year=1980 and region='Canada' then x='After';
if year=1984 and region='Russia' then x='After';
if year=1988 and region='USA' then x='After';
if year=1992 and region='South Korea' then x='After';
if year=1996 and region='Spain' then x='After';
if year=2000 and region='USA' then x='After';
if year=2004 and region='Australia' then x='After';
if year=2008 and region='Greece' then x='After';
if year=2012 and region='China' then x='After';
if year=2016 and region='UK' then x='After';
if year=2020 and region='Brazil' then x='After';
if year=2024 and region='Japan' then x='After';
if year=2028 and region='France' then x='After';
if year=2032 and region='USA' then x='After';

run;

 data medals_country_Summmer;
 set  medals_country_Summer;
 where x ne '';
 run;

 proc sort data=medals_country; by region year; run;


/* all countries - winter*/

proc sql;
create table medals_country_Winter as 
select c.year, b.region,  
count(ID) as N_medals
from BD.Event_table as a left join BD.NOC_REGIONS as b on a.NOC=b.NOC 
left join BD.Games_info as c on a.Games=c.Games
where medal not in ('NA') and b.region in 
('France',
'Switzerland',
'USA',
'Germany',
'Switzerland',
'Norway',
'Italy',
'USA',
'Austria',
'France',
'Japan',
'Austria',
'USA',
'Serbia',
'Canada',
'France',
'Norway',
'Japan',
'USA',
'Italy',
'Canada',
'Russia',
'South Korea',
'China'
) and c.season='Winter'
group by c.year, b.region
order by year;
quit; 

 data medals_country_Winter;
 set  medals_country_Winter;

if year=1924 and  region='France' then x='Hosted';
if year=1928 and  region='Switzerland' then x='Hosted';
if year=1932 and  region='USA' then x='Hosted';
if year=1936 and  region='Germany' then x='Hosted';
if year=1948 and  region='Switzerland' then x='Hosted';
if year=1952 and  region='Norway' then x='Hosted';
if year=1956 and  region='Italy' then x='Hosted';
if year=1960 and  region='USA' then x='Hosted';
if year=1964 and  region='Austria' then x='Hosted';
if year=1968 and  region='France' then x='Hosted';
if year=1972 and  region='Japan' then x='Hosted';
if year=1976 and  region='Austria' then x='Hosted';
if year=1980 and  region='USA' then x='Hosted';
if year=1984 and  region='Serbia' then x='Hosted';
if year=1988 and  region='Canada' then x='Hosted';
if year=1992 and  region='France' then x='Hosted';
if year=1994 and  region='Norway' then x='Hosted';
if year=1998 and  region='Japan' then x='Hosted';
if year=2002 and  region='USA' then x='Hosted';
if year=2006 and  region='Italy' then x='Hosted';
if year=2010 and  region='Canada' then x='Hosted';
if year=2014 and  region='Russia' then x='Hosted';
if year=2018 and  region='South Korea' then x='Hosted';
if year=2022 and  region='China' then x='Hosted';

if year=1920 and  region='France' then x='Before';
if year=1924 and  region='Switzerland' then x='Before';
if year=1928 and  region='USA' then x='Before';
if year=1932 and  region='Germany' then x='Before';
if year=1944 and  region='Switzerland' then x='Before';
if year=1948 and  region='Norway' then x='Before';
if year=1952 and  region='Italy' then x='Before';
if year=1956 and  region='USA' then x='Before';
if year=1960 and  region='Austria' then x='Before';
if year=1964 and  region='France' then x='Before';
if year=1968 and  region='Japan' then x='Before';
if year=1972 and  region='Austria' then x='Before';
if year=1976 and  region='USA' then x='Before';
if year=1980 and  region='Serbia' then x='Before';
if year=1984 and  region='Canada' then x='Before';
if year=1988 and  region='France' then x='Before';
if year=1990 and  region='Norway' then x='Before';
if year=1994 and  region='Japan' then x='Before';
if year=1998 and  region='USA' then x='Before';
if year=2002 and  region='Italy' then x='Before';
if year=2006 and  region='Canada' then x='Before';
if year=2010 and  region='Russia' then x='Before';
if year=2014 and  region='South Korea' then x='Before';
if year=2018 and  region='China' then x='Before';

if year=1928 and  region='France' then x='After';
if year=1932 and  region='Switzerland' then x='After';
if year=1936 and  region='USA' then x='After';
if year=1940 and  region='Germany' then x='After';
if year=1952 and  region='Switzerland' then x='After';
if year=1956 and  region='Norway' then x='After';
if year=1960 and  region='Italy' then x='After';
if year=1964 and  region='USA' then x='After';
if year=1968 and  region='Austria' then x='After';
if year=1972 and  region='France' then x='After';
if year=1976 and  region='Japan' then x='After';
if year=1980 and  region='Austria' then x='After';
if year=1984 and  region='USA' then x='After';
if year=1988 and  region='Serbia' then x='After';
if year=1992 and  region='Canada' then x='After';
if year=1996 and  region='France' then x='After';
if year=1998 and  region='Norway' then x='After';
if year=2002 and  region='Japan' then x='After';
if year=2006 and  region='USA' then x='After';
if year=2010 and  region='Italy' then x='After';
if year=2014 and  region='Canada' then x='After';
if year=2018 and  region='Russia' then x='After';
if year=2022 and  region='South Korea' then x='After';
if year=2026 and  region='China' then x='After';

run;

 data medals_country_Winter;
 set  medals_country_Winter;
 where x ne '';
 run;

 proc sort data=medals_country_Winter; by region year; run;

/*  Liner Regression */

/* Model: N_Medals ~ N_participants, Host_Effect (HE) (dummy 0/1), After_Host_Effect(AHE) (dummy 0/1) */


/* # Medals and participants by country - year, season*/


proc sql;
create table Countries_medals_participants as
select c.year, c.season, b.region as country, count (distinct a.ID) as N_participants,  
SUM(case when medal not in ('NA') then 1 else 0 end)  as N_medals 
from  BD.EVENT_table as a left join BD.NOC_REGIONS as b on a.NOC=b.NOC left join BD.GAMES_INFO as c on a.games=c.games
group by c.year, c.season, country;
quit;


data Countries_medals_participants;
set Countries_medals_participants;
if year=1896 and Season='Summer' and country='Greece' then HE=1;
if year=1900 and Season='Summer' and country='France' then HE=1;
if year=1904 and Season='Summer' and country='USA' then HE=1;
if year=1906 and Season='Summer' and country='Greece' then HE=1;
if year=1908 and Season='Summer' and country='UK' then  HE=1;
if year=1912 and Season='Summer' and country='Sweden' then  HE=1;
if year=1920 and Season='Summer' and country='Belgium' then  HE=1;
if year=1924 and Season='Summer' and country='France' then  HE=1;
if year=1928 and Season='Summer' and country='Netherlands' then  HE=1;
if year=1932 and Season='Summer' and country='USA' then  HE=1;
if year=1936 and Season='Summer' and country='Germany' then  HE=1;
if year=1948 and Season='Summer' and country='UK' then  HE=1;
if year=1952 and Season='Summer' and country='Finland' then  HE=1;
if year=1956 and Season='Summer' and country='Australia' then  HE=1;
if year=1960 and Season='Summer' and country='Italy' then  HE=1;
if year=1964 and Season='Summer' and country='Japan' then  HE=1;
if year=1968 and Season='Summer' and country='Mexico' then  HE=1;
if year=1972 and Season='Summer' and country='Germany' then  HE=1;
if year=1976 and Season='Summer' and country='Canada' then  HE=1;
if year=1980 and Season='Summer' and country='Russia' then  HE=1;
if year=1984 and Season='Summer' and country='USA' then  HE=1;
if year=1988 and Season='Summer' and country='South Korea' then  HE=1;
if year=1992 and Season='Summer' and country='Spain' then  HE=1;
if year=1996 and Season='Summer' and country='USA' then  HE=1;
if year=2000 and Season='Summer' and country='Australia' then  HE=1;
if year=2004 and Season='Summer' and country='Greece' then  HE=1;
if year=2008 and Season='Summer' and country='China' then  HE=1;
if year=2012 and Season='Summer' and country='UK' then  HE=1;
if year=2016 and Season='Summer' and country='Brazil' then  HE=1;
if year=2020 and Season='Summer' and country='Japan' then  HE=1;
if year=2024 and Season='Summer' and country='France' then  HE=1;
if year=2028 and Season='Summer' and country='USA' then  HE=1;

if year=1924 and  Season='Winter' and country='France' then HE=1;
if year=1928 and  Season='Winter' and country='Switzerland' then HE=1;
if year=1932 and  Season='Winter' and country='USA' then HE=1;
if year=1936 and  Season='Winter' and country='Germany' then HE=1;
if year=1948 and  Season='Winter' and country='Switzerland' then HE=1;
if year=1952 and  Season='Winter' and country='Norway' then HE=1;
if year=1956 and  Season='Winter' and country='Italy' then HE=1;
if year=1960 and  Season='Winter' and country='USA' then HE=1;
if year=1964 and  Season='Winter' and country='Austria' then HE=1;
if year=1968 and  Season='Winter' and country='France' then HE=1;
if year=1972 and  Season='Winter' and country='Japan' then HE=1;
if year=1976 and  Season='Winter' and country='Austria' then HE=1;
if year=1980 and  Season='Winter' and country='USA' then HE=1;
if year=1984 and  Season='Winter' and country='Serbia' then HE=1;
if year=1988 and  Season='Winter' and country='Canada' then HE=1;
if year=1992 and  Season='Winter' and country='France' then HE=1;
if year=1994 and  Season='Winter' and country='Norway' then HE=1;
if year=1998 and  Season='Winter' and country='Japan' then HE=1;
if year=2002 and  Season='Winter' and country='USA' then HE=1;
if year=2006 and  Season='Winter' and country='Italy' then HE=1;
if year=2010 and  Season='Winter' and country='Canada' then HE=1;
if year=2014 and  Season='Winter' and country='Russia' then HE=1;
if year=2018 and  Season='Winter' and country='South Korea' then HE=1;
if year=2022 and  Season='Winter' and country='China' then HE=1;
run;

data Countries_medals_participants;
set Countries_medals_participants;
if year=1900 and  Season='Summer' and country='Greece' then AHE=1;
if year=1904 and  Season='Summer' and country='France' then AHE=1;
if year=1908 and  Season='Summer' and country='USA' then AHE=1;
if year=1910 and  Season='Summer' and country='Greece' then AHE=1;
if year=1912 and  Season='Summer' and country='UK' then AHE=1;
if year=1916 and  Season='Summer' and country='Sweden' then AHE=1;
if year=1924 and  Season='Summer' and country='Belgium' then AHE=1;
if year=1928 and  Season='Summer' and country='France' then AHE=1;
if year=1932 and  Season='Summer' and country='Netherlands' then AHE=1;
if year=1936 and  Season='Summer' and country='USA' then AHE=1;
if year=1940 and  Season='Summer' and country='Germany' then AHE=1;
if year=1952 and  Season='Summer' and country='UK' then AHE=1;
if year=1956 and  Season='Summer' and country='Finland' then AHE=1;
if year=1960 and  Season='Summer' and country='Australia' then AHE=1;
if year=1964 and  Season='Summer' and country='Italy' then AHE=1;
if year=1968 and  Season='Summer' and country='Japan' then AHE=1;
if year=1972 and  Season='Summer' and country='Mexico' then AHE=1;
if year=1976 and  Season='Summer' and country='Germany' then AHE=1;
if year=1980 and  Season='Summer' and country='Canada' then AHE=1;
if year=1984 and  Season='Summer' and country='Russia' then AHE=1;
if year=1988 and  Season='Summer' and country='USA' then AHE=1;
if year=1992 and  Season='Summer' and country='South Korea' then AHE=1;
if year=1996 and  Season='Summer' and country='Spain' then AHE=1;
if year=2000 and  Season='Summer' and country='USA' then AHE=1;
if year=2004 and  Season='Summer' and country='Australia' then AHE=1;
if year=2008 and  Season='Summer' and country='Greece' then AHE=1;
if year=2012 and  Season='Summer' and country='China' then AHE=1;
if year=2016 and  Season='Summer' and country='UK' then AHE=1;
if year=2020 and  Season='Summer' and country='Brazil' then AHE=1;
if year=2024 and  Season='Summer' and country='Japan' then AHE=1;
if year=2028 and  Season='Summer' and country='France' then AHE=1;
if year=2032 and  Season='Summer' and country='USA' then AHE=1;

if year=1928 and  Season='Winter' and country='France' then AHE=1;
if year=1932 and  Season='Winter' and country='Switzerland' then AHE=1;
if year=1936 and  Season='Winter' and country='USA' then AHE=1;
if year=1940 and  Season='Winter' and country='Germany' then AHE=1;
if year=1952 and  Season='Winter' and country='Switzerland' then AHE=1;
if year=1956 and  Season='Winter' and country='Norway' then AHE=1;
if year=1960 and  Season='Winter' and country='Italy' then AHE=1;
if year=1964 and  Season='Winter' and country='USA' then AHE=1;
if year=1968 and  Season='Winter' and country='Austria' then AHE=1;
if year=1972 and  Season='Winter' and country='France' then AHE=1;
if year=1976 and  Season='Winter' and country='Japan' then AHE=1;
if year=1980 and  Season='Winter' and country='Austria' then AHE=1;
if year=1984 and  Season='Winter' and country='USA' then AHE=1;
if year=1988 and  Season='Winter' and country='Serbia' then AHE=1;
if year=1992 and  Season='Winter' and country='Canada' then AHE=1;
if year=1996 and  Season='Winter' and country='France' then AHE=1;
if year=1998 and  Season='Winter' and country='Norway' then AHE=1;
if year=2002 and  Season='Winter' and country='Japan' then AHE=1;
if year=2006 and  Season='Winter' and country='USA' then AHE=1;
if year=2010 and  Season='Winter' and country='Italy' then AHE=1;
if year=2014 and  Season='Winter' and country='Canada' then AHE=1;
if year=2018 and  Season='Winter' and country='Russia' then AHE=1;
if year=2022 and  Season='Winter' and country='South Korea' then AHE=1;
if year=2026 and  Season='Winter' and country='China' then AHE=1;
run;


data Countries_medals_participants;
set Countries_medals_participants;
if HE ne 1 then HE=0;
if AHE ne 1 then AHE=0;
run;


PROC REG DATA = Countries_medals_participants;
MODEL N_medals = N_participants HE AHE /stb;

data Countries_Summer;
set Countries_medals_participants;
where season='Summer';
run;

PROC REG DATA = Countries_Summer;
MODEL N_medals = N_participants HE AHE /stb;


data Countries_winter;
set Countries_medals_participants;
where season='Winter';
run;


PROC REG DATA = Countries_winter;
MODEL N_medals = N_participants HE AHE /stb;

