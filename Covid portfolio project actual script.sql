SELECT * FROM PortfolioProjects..CovidDeaths
ORDER BY 3,4;


SELECT   Location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProjects..CovidDeaths
ORDER BY 1,2;

-- Looking at Total Cases  vs Total Deaths
-- shows likelihood of dying if you contract covid in your country

SELECT   Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage
FROM PortfolioProjects..CovidDeaths
WHERE Location like '%states%'
and continent is not null
ORDER BY 1,2;

-- looking at total cases vs population
-- Shows what percentage of population got covid

SELECT  Location, date, total_cases, population, (total_cases/population) AS PercentagePopulationinfected
FROM PortfolioProjects..CovidDeaths
WHERE Location like '%states%' 
ORDER BY 1,2;

SELECT  Location, date, population,total_cases,(total_cases/population) AS PercentagePopulationinfected
FROM PortfolioProjects..CovidDeaths
WHERE Location like '%states%' 
and continent is not null
ORDER BY 1,2;  

--looking at countries with highest infection Rate compared to Population

SELECT location, population, MAX(total_cases) as HighestInfectionCount, MAX(total_cases/population) * 100 AS PercentagePopulationinfected
FROM PortfolioProjects..CovidDeaths
Where continent is not null
Group by Location, population
ORDER BY PercentagePopulationinfected desc; 

showing countries with Highest Death Count per Population
SELECT location, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM PortfolioProjects..CovidDeaths
Where continent is not null
Group by Location
ORDER BY TotalDeathCount desc; 

-- LET'S  BREAK THINGS DOWN BY CONTINENT

SELECT location, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM PortfolioProjects..CovidDeaths
Where continent is null
Group by location
ORDER BY TotalDeathCount desc; 

SELECT continent, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM PortfolioProjects..CovidDeaths
Where continent is null
Group by continent
ORDER BY TotalDeathCount desc; 

-- GLOBAL NUMBERS
select date, SUM(new_cases) as totalcases, SUM(cast(new_deaths as int)) as totaldeaths, SUM(cast(new_deaths as int))/SUM(new_cases) *100 as DeathPercentage
From PortfolioProjects..CovidDeaths
where continent is not null
Group by date
order by 1,2;

-- GLOBAL NUMBERS
select SUM(new_cases) as totalcases, SUM(cast(new_deaths as int)) as totaldeaths, SUM(cast(new_deaths as int))/SUM(new_cases) *100 as DeathPercentage
From PortfolioProjects..CovidDeaths
where continent is not null
--Group by date
order by 1,2;

--JOINING TABLES

select *
from PortfolioProjects..CovidDeaths dea
join PortfolioProjects..CovidVaccination vac
ON dea.location = vac.location
and dea.date= vac.date;

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
from PortfolioProjects..CovidDeaths dea
join PortfolioProjects..CovidVaccination vac
ON dea.location = vac.location
and dea.date= vac.date
where dea.continent is not null
order by 2,3;



select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.location order by dea.location,
dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
from PortfolioProjects..CovidDeaths dea
join PortfolioProjects..CovidVaccination vac
ON dea.location = vac.location
and dea.date= vac.date
where dea.continent is not null
order by 2,3;

DROP Table if exists #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(Continent nvarchar (255),
Location nvarchar (255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)
Insert into #PercentPopulationVaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.location order by dea.location,
dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
from PortfolioProjects..CovidDeaths dea
join PortfolioProjects..CovidVaccination vac
ON dea.location = vac.location
and dea.date= vac.date
--where dea.continent is not null
--order by 2,3
;

SELECT * , (RollingPeopleVaccinated/ Population)* 100
From  #PercentPopulationVaccinated



-- USE CTE

With PopvsVac (Continent, location, Date, Population, New_vaccinations, RollingPeopleVaccinated )
as
(
select dea.continent, dea.location, dea.date, dea.population, vac.New_vaccinations
, SUM(convert (int, vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location,
dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
from PortfolioProjects..CovidDeaths dea
join PortfolioProjects..CovidVaccination vac
ON dea.location = vac.location
and dea.date= vac.date
where dea.continent is not null
--order by 2,3 1:03:36
)

select *
from PortfolioProjects..CovidVaccination



--Creating View to store data for later visualizations
Create view PercentPopulationVaccinated1 as
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.location order by dea.location,
dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
from PortfolioProjects..CovidDeaths dea
join PortfolioProjects..CovidVaccination vac
ON dea.location = vac.location
and dea.date= vac.date
where dea.continent is not null
--order by 2,3
;

select * 
from PercentPopulationVaccinated1 



