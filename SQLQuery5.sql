SELECT *
FROM CovidDeaths$
where continent is not null
Order by 3,4;

SELECT Location,date,total_cases,new_cases,total_deaths,population
FROM CovidDeaths$
Order by 1,2;

--Comparing Total cases Vs Total deaths
SELECT Location,date,total_cases,total_deaths,(total_deaths/total_cases)*100 as DeathPercentage
FROM CovidDeaths$
where location like '%states%'
Order by 1,2;

--Comparing total cases vs population
SELECT Location,date,total_cases,population,(total_cases/population)*100 as casesperpopulationPercentage
FROM CovidDeaths$
where location like '%states%'
Order by 1,2;

--countries with highest infection rates
SELECT Location,population,MAX(total_cases) as HighestInfectionCount,MAX((total_cases/population))*100 as Percentpopulationinfected
FROM CovidDeaths$
--where location like '%states%'
group by population ,location
Order by Percentpopulationinfected desc;


--show countries with highest death count per population
SELECT Location,MAX(cast(total_deaths as int)) as Totaldeathscount
FROM CovidDeaths$
where continent is not null
group by location
Order by Totaldeathscount desc;




--showing continents with highest death count per poulation
SELECT continent,MAX(cast(total_deaths as int)) as Totaldeathscount
FROM CovidDeaths$
where continent is not null
group by Continent
order by Totaldeathscount desc;

--GLOBAL NUMBERS(per day)
SELECT date,Sum(new_cases) total_cases,sum(cast(new_deaths as int)) total_deaths,SUM(cast(new_deaths as int))/SUM(new_cases)*100 AS Death_perecentage
FROM CovidDeaths$
where continent is not null
group by date
Order by 1,2;


---------------------------------------------------------------------------------------------------------------------------------


--looking at totalpeople vs vaccination(per day)

SELECT dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
SUM(CONVERT(bigint, vac.new_vaccinations))OVER (Partition by dea.Location)
FROM [Portfolio Project]..CovidDeaths$ dea
Join [Portfolio Project]..CovidVaccinations$ vac
on dea.location=vac.location 
and dea.date=vac.date
where dea.continent is not null
order by 2,3;

--Rolling people vaccinated
SELECT dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
SUM(CONVERT(bigint, vac.new_vaccinations))OVER (Partition by dea.Location ORDER BY dea.date,dea.location) AS Rollingpeoplevaccinated
--,(Rollingpeoplevaccinated/population)*100 can't use a column we've just created instead cte,temp_table and in cte can't use order by
FROM [Portfolio Project]..CovidDeaths$ dea
Join [Portfolio Project]..CovidVaccinations$ vac
on dea.location=vac.location 
and dea.date=vac.date
where dea.continent is not null
order by 2,3;


--USING CTE
with PopuvsVac(Continent,Location,Date,Population,new_vaccinations,Rollingpeoplevaccinated)
as(
SELECT dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
SUM(CONVERT(bigint, vac.new_vaccinations))OVER (Partition by dea.Location ORDER BY dea.date,dea.location) AS Rollingpeoplevaccinated
FROM [Portfolio Project]..CovidDeaths$ dea
Join [Portfolio Project]..CovidVaccinations$ vac
on dea.location=vac.location 
and dea.date=vac.date
where dea.continent is not null
--order by 2,3;
)
Select *,(Rollingpeoplevaccinated/population)*100
From PopuvsVac






--using temp table
DROP TABLE IF EXISTS #PercentPopuVaccinated
CREATE TABLE #PercentPopuVaccinated(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
new_vaccinations numeric,
Rollingpeoplevaccinated numeric)

Insert into #PercentPopuVaccinated
SELECT dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
SUM(CONVERT(bigint, vac.new_vaccinations))OVER (Partition by dea.Location ORDER BY dea.date,dea.location) AS Rollingpeoplevaccinated
FROM [Portfolio Project]..CovidDeaths$ dea
Join [Portfolio Project]..CovidVaccinations$ vac
on dea.location=vac.location 
and dea.date=vac.date
--where dea.continent is not null
--order by 2,3;

Select *,(Rollingpeoplevaccinated/population)*100
From #PercentPopuVaccinated


--Creating view for later visulaizations

CREATE VIEW PercentPopulationVaccinated as
SELECT dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
SUM(CONVERT(bigint, vac.new_vaccinations))OVER (Partition by dea.Location ORDER BY dea.date,dea.location) AS Rollingpeoplevaccinated
FROM [Portfolio Project]..CovidDeaths$ dea
Join [Portfolio Project]..CovidVaccinations$ vac
on dea.location=vac.location 
and dea.date=vac.date
where dea.continent is not null
--order by 2,3;

Select *
FROM PercentPopulationVaccinated