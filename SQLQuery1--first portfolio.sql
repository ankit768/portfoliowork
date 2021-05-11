select *
from [porfolio project]..covid_deaths
where continent is not null
order by 3,4

--select *
--from [porfolio project]..covid_vaccination
--order by 3,4;

select location,date,total_cases,new_cases,total_deaths,population
from [porfolio project]..covid_deaths
where continent is not null
order by 1,2


--looking at total cases vs total deaths 

select location,date,total_cases,total_deaths,(total_deaths/total_cases)*100 as death_persent
from [porfolio project]..covid_deaths
where continent is not null and
 location = 'India'
order by 1,2

--looking at total cases vs population
--show what percentage of popupation got covid

select location,date,population,total_cases,(total_cases/population)*100 as percentagepopulationinfected
from [porfolio project]..covid_deaths
--where location = 'India'
where continent is not null
order by 1,2

--looking at countries with higest infection rate compared to population

select location,population,max(total_cases) as maximamtotalcasescount,max((total_cases/population))*100 as percentagepopulationinfected
from [porfolio project]..covid_deaths
--where location = 'India'
where continent is not null
group by  location,population
order by percentagepopulationinfected desc

--showing countries with highest death rate
select location,max(cast(total_deaths as int)) as maxmiumdeathscount
from [porfolio project]..covid_deaths
--where location = 'India'
where continent is not null
group by  location
order by maxmiumdeathscount desc

--let's break things down by continent

--showing countintents with higest death count per population

select continent,max(cast(total_deaths as int)) as maxmiumdeathscount
from [porfolio project]..covid_deaths
--where location = 'India'
where continent is not null
group by  continent
order by maxmiumdeathscount desc

--global number
select date,sum(new_cases)as newtotal_cases ,sum(cast(new_deaths as float)) as new_total_death, (sum(cast(new_deaths as int))/sum(new_cases))*100 as newinfectedpersentage
from [porfolio project]..covid_deaths
--where location = 'India'
where continent is not null
group by  date
order by newinfectedpersentage desc

--looking at total population vs vaccinates

select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,sum(convert(int,vac.new_vaccinations)) over(partition by dea.location order by dea.location,dea.date) as rollingpeoplevaccinationted
from [porfolio project]..covid_deaths dea
join [porfolio project]..covid_vaccination vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
order by 2,3

--use cts
with popvsvac (continent,location,date,population,new_vaccination,rollingpeoplevaccinationted)
as
(
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,sum(convert(int,vac.new_vaccinations)) over(partition by dea.location order by dea.location,dea.date) as rollingpeoplevaccinationted
from [porfolio project]..covid_deaths dea
join [porfolio project]..covid_vaccination vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)
select *,(rollingpeoplevaccinationted/population)*100
from popvsvac;

--temp table
drop table if exists  #percentpopulationvaccinated
create table #percentpopulationvaccinated 
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
rollingpeoplevaccinationted numeric
)
insert into #percentpopulationvaccinated

 select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,sum(convert(int,vac.new_vaccinations)) over(partition by dea.location order by dea.location,dea.date) as rollingpeoplevaccinationted
from [porfolio project]..covid_deaths dea
join [porfolio project]..covid_vaccination vac
on dea.location = vac.location
and dea.date = vac.date
--where dea.continent is not null
--order by 2,3

 select *,(rollingpeoplevaccinationted/population)*100
from  #percentpopulationvaccinated ;

--creating view to store data for later viz

create view percentpopulationvaccinated as
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,sum(convert(int,vac.new_vaccinations)) over(partition by dea.location order by dea.location,dea.date) as rollingpeoplevaccinationted
from [porfolio project]..covid_deaths dea
join [porfolio project]..covid_vaccination vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
--order by 2,3

select *
from percentpopulationvaccinated;