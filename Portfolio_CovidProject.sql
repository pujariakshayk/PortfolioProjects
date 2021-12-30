/****** Script for SelectTopNRows command from SSMS  ******/
SELECT *
  FROM CovidDeaths
  order by 3,4;

  /****** Script for SelectTopNRows command from SSMS  ******/
SELECT *
  FROM CovidVaccinations
  order by 3,4;

  --Looking at Total Cases vs Total Deaths
  --shows likelihood of dying in respective country
  SELECT location, date, total_cases, total_deaths, (Total_deaths/total_cases)*100 as DeathPercentage
  FROM CovidDeaths
  where location like '%ndia'
  order by 1,2;

--looking at total cases vs population
--shows percentage of population with covid
  SELECT location, date, total_cases, population, (total_cases/population)*100 as CovidPercentageRate
  FROM CovidDeaths
  where location like '%states'
  order by 1,2;

  --Country with highest infected rate
  SELECT location, Max(total_cases) as HighestInfectionCount, population, Max((total_cases/population)*100) as CovidPercentageRate
  FROM CovidDeaths
  where continent is not null
  group by population,location
  order by 4 desc;

    --Country with highest death rate with continents
  SELECT location, MAX(cast(total_deaths as int)) as TotalDeathCount
  FROM CovidDeaths
  where continent is not null
  group by location
  order by 2 desc;

  --Group By Continents
  SELECT continent, MAX(cast(total_deaths as int)) as TotalDeathCount
  FROM CovidDeaths
  where continent is not null
  group by continent
  order by 2 desc;

 --showing continents with the highest death count per population
   SELECT date,continent, MAX(cast(total_deaths as int)) as TotalDeathCount, Max(total_deaths/population)*100 as DeathPercentageRate 
  FROM CovidDeaths
  where continent is not null
  group by continent,date
  order by 1 desc;

  --Global Numbers
  SELECT SuM(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_deaths, sum(cast(new_deaths as int))/Sum(new_cases)*100 as DeathPercentageRate 
  FROM CovidDeaths
  where continent is not null
  --group by date
  order by 1,2;
  

  --Vaccinations Table
  select dt.continent,dt.location, dt.date,dt.population,cv.new_vaccinations, sum(convert(bigint,cv.new_vaccinations)) over (partition by dt.location order by dt.location, dt.date) as RollingPeopleVaccinated
  from CovidDeaths Dt, CovidVaccinations cv
  where dt.location = cv.location
  and dt.date = cv.date
  and dt.continent is not null
  and cv.new_vaccinations is not null
  order by 2,3;

  -- Use CTE

  with PopulationVsVaccination (Continent, location, Date, Population, new_vaccinations, RollingPeopleVaccinated)
  as 
  (
  select dt.continent,dt.location, dt.date,dt.population,cv.new_vaccinations, sum(convert(bigint,cv.new_vaccinations)) over (partition by dt.location order by dt.location, dt.date) as RollingPeopleVaccinated
  from CovidDeaths Dt, CovidVaccinations cv
  where dt.location = cv.location
  and dt.date = cv.date
  and dt.continent is not null
  and cv.new_vaccinations is not null
)
select *, (RollingPeopleVaccinated/Population)*100
from PopulationVsVaccination
order by 2;


-- Temp Table

Drop table if exists temp_PercentPopulationVaccinated;

create table temp_PercentPopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)



insert into temp_PercentPopulationVaccinated
select dt.continent,dt.location, dt.date,dt.population,cv.new_vaccinations, sum(convert(bigint,cv.new_vaccinations)) over (partition by dt.location order by dt.location, dt.date) as RollingPeopleVaccinated
  from CovidDeaths Dt, CovidVaccinations cv
  where dt.location = cv.location
  and dt.date = cv.date
  --and cv.new_vaccinations is not null;
  --and dt.continent is not null


select *, (RollingPeopleVaccinated/Population)*100
from temp_PercentPopulationVaccinated
--order by 2;

create view view_PercentPopulationVaccinated as
select dt.continent,dt.location, dt.date,dt.population,cv.new_vaccinations, sum(convert(bigint,cv.new_vaccinations)) over (partition by dt.location order by dt.location, dt.date) as RollingPeopleVaccinated
  from CovidDeaths Dt, CovidVaccinations cv
  where dt.location = cv.location
  and dt.date = cv.date
  --and cv.new_vaccinations is not null;
  and dt.continent is not null

/****** Script for SelectTopNRows command from SSMS  ******/
SELECT TOP (1000) [continent]
      ,[location]
      ,[date]
      ,[population]
      ,[new_vaccinations]
      ,[RollingPeopleVaccinated]
  FROM [CovidPortfolioProject].[dbo].[view_PercentPopulationVaccinated]


