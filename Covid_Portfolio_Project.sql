


ALTER TABLE PortfolioProject.dbo.CovidDeaths
alter COLUMN total_cases float;


ALTER TABLE PortfolioProject.dbo.CovidDeaths
alter COLUMN total_deaths float;

select location, date,total_cases, total_deaths,(total_deaths/total_cases) * 100 as DeathPercentage
from PortfolioProject.dbo.CovidDeaths
where location like '%states%'
order by DeathPercentage DESC 

Select location, population, MAX (total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as PercentPopulationInfected
From PortfolioProject.dbo.CovidDeaths
Group by location, population
order by PercentPopulationInfected DESC 
--showing countries with the highest death count per population
Select location, population, MAX (total_deaths) as HighestDeathCount, MAX((total_deaths/population))*100 as PercentPopulationDeaths
From PortfolioProject.dbo.CovidDeaths
where continent is not null 
Group by location, population
order by PercentPopulationDeaths DESC 

Select continent, MAX (total_deaths) as HighestDeathCount, MAX((total_deaths/population))*100 as PercentPopulationDeaths
From PortfolioProject.dbo.CovidDeaths
where continent is not null 
Group by continent
order by HighestDeathCount DESC 


--global numbers 
select date,continent,total_cases, total_deaths,(total_deaths/total_cases) * 100 as DeathPercentage
from PortfolioProject.dbo.CovidDeaths
--where location like '%states%'
where continent is not null
order by DeathPercentage DESC 

select date,sum(new_cases) AS TotalCasesbyDate, SUM(new_deaths) AS TotalDeathsByDate, sum(new_deaths)/sum(new_cases) * 100 as DeathPercentage
from PortfolioProject.dbo.CovidDeaths
--where location like '%states%'
where continent is not null and new_cases<>0 
group by date
order by 1,2

select sum(new_cases) AS TotalCases, SUM(new_deaths) AS TotalDeaths, sum(new_deaths)/sum(new_cases) * 100 as DeathPercentage
from PortfolioProject.dbo.CovidDeaths
--where location like '%states%'
where continent is not null and new_cases<>0 
--group by date
order by 1,2


--Looking at Total Population vs Vaccinations 
select PortfolioProject..CovidDeaths.continent,PortfolioProject..CovidDeaths.location, PortfolioProject..CovidDeaths.date, PortfolioProject..CovidDeaths.population, PortfolioProject..CovidDeaths.new_vaccinations
From PortfolioProject..CovidDeaths
Join [PortfolioProject].[dbo].[CovidVacinations$]
ON PortfolioProject..CovidDeaths.location =  [PortfolioProject].[dbo].[CovidVacinations$].[location] AND PortfolioProject..CovidDeaths.date =  [PortfolioProject].[dbo].[CovidVacinations$].[date]
where PortfolioProject..CovidDeaths.continent is not null
order by 2,3

--rolling counts 

select PortfolioProject..CovidDeaths.continent,PortfolioProject..CovidDeaths.location, PortfolioProject..CovidDeaths.date, PortfolioProject..CovidDeaths.population, [PortfolioProject].[dbo].[CovidVacinations$].[new_vaccinations],
sum (CAST([PortfolioProject].[dbo].[CovidVacinations$].[new_vaccinations] as float)) Over (partition by PortfolioProject..CovidDeaths.location order by PortfolioProject..CovidDeaths.location, PortfolioProject..CovidDeaths.date) 
as RollingPeopleVaxed, (RollingPeopleVaxed/population)*100
From PortfolioProject..CovidDeaths
Join [PortfolioProject].[dbo].[CovidVacinations$]
ON PortfolioProject..CovidDeaths.location =  [PortfolioProject].[dbo].[CovidVacinations$].[location] AND PortfolioProject..CovidDeaths.date =  [PortfolioProject].[dbo].[CovidVacinations$].[date]
where PortfolioProject..CovidDeaths.continent is not null
order by 2,3




--USE CTE 

With PopvsVac (continent, location, date, population, New_vaccinations, RollingPeopleVaxed)
as
(
select PortfolioProject..CovidDeaths.continent,PortfolioProject..CovidDeaths.location, PortfolioProject..CovidDeaths.date, PortfolioProject..CovidDeaths.population, [PortfolioProject].[dbo].[CovidVacinations$].[new_vaccinations],
sum (CAST([PortfolioProject].[dbo].[CovidVacinations$].[new_vaccinations] as float)) Over (partition by PortfolioProject..CovidDeaths.location order by PortfolioProject..CovidDeaths.location, PortfolioProject..CovidDeaths.date) 
as RollingPeopleVaxed--, (RollingPeopleVaxed/population)*100
From PortfolioProject..CovidDeaths
Join [PortfolioProject].[dbo].[CovidVacinations$]
ON PortfolioProject..CovidDeaths.location =  [PortfolioProject].[dbo].[CovidVacinations$].[location] AND PortfolioProject..CovidDeaths.date =  [PortfolioProject].[dbo].[CovidVacinations$].[date]
where PortfolioProject..CovidDeaths.continent is not null
)

Select *, (RollingPeopleVaxed/population) * 100
from PopvsVac


--TEMP TABLE 

DROP Table if exists #PercentPopVaxed
create table #PercentPopVaxed
(
Continent nvarchar (255),
location nvarchar (255),
Date datetime,
Population  numeric, 
new_vaccinations numeric, 
RollingPeopleVaxed numeric
)

insert into #PercentPopVaxed
select PortfolioProject..CovidDeaths.continent,PortfolioProject..CovidDeaths.location, PortfolioProject..CovidDeaths.date, PortfolioProject..CovidDeaths.population, [PortfolioProject].[dbo].[CovidVacinations$].[new_vaccinations],
sum (CAST([PortfolioProject].[dbo].[CovidVacinations$].[new_vaccinations] as float)) Over (partition by PortfolioProject..CovidDeaths.location order by PortfolioProject..CovidDeaths.location, PortfolioProject..CovidDeaths.date) 
as RollingPeopleVaxed--, (RollingPeopleVaxed/population)*100
From PortfolioProject..CovidDeaths
Join [PortfolioProject].[dbo].[CovidVacinations$]
ON PortfolioProject..CovidDeaths.location =  [PortfolioProject].[dbo].[CovidVacinations$].[location] AND PortfolioProject..CovidDeaths.date =  [PortfolioProject].[dbo].[CovidVacinations$].[date]
--where PortfolioProject..CovidDeaths.continent is not null
--order by 2,3

Select *, (RollingPeopleVaxed/population) * 100
from #PercentPopVaxed


--creating a view to store data for later viz 
create view PercentPopVaxed as
select PortfolioProject..CovidDeaths.continent,PortfolioProject..CovidDeaths.location, PortfolioProject..CovidDeaths.date, PortfolioProject..CovidDeaths.population, [PortfolioProject].[dbo].[CovidVacinations$].[new_vaccinations],
sum (CAST([PortfolioProject].[dbo].[CovidVacinations$].[new_vaccinations] as float)) Over (partition by PortfolioProject..CovidDeaths.location order by PortfolioProject..CovidDeaths.location, PortfolioProject..CovidDeaths.date) 
as RollingPeopleVaxed--, (RollingPeopleVaxed/population)*100
From PortfolioProject..CovidDeaths
Join [PortfolioProject].[dbo].[CovidVacinations$]
ON PortfolioProject..CovidDeaths.location =  [PortfolioProject].[dbo].[CovidVacinations$].[location] AND PortfolioProject..CovidDeaths.date =  [PortfolioProject].[dbo].[CovidVacinations$].[date]
where PortfolioProject..CovidDeaths.continent is not null
--order by 2,3


select * from PercentPopVaxed