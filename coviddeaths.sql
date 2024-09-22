SELECT * FROM PortfolioProject..CovidDeaths 
WHERE continent is not null
ORDER BY 3,4

--SELECT * FROM PortfolioProject..CovidVaccincation ORDER BY 3,4


--SELECTING DATA

SELECT location, date, total_cases, new_cases, total_deaths, population FROM PortfolioProject..CovidDeaths ORDER BY 1,2


--CHECKING TOTAL CASE VS TOTAL DEATHS
SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DethPercentage
FROM PortfolioProject..CovidDeaths 
WHERE location like '%kenya%'
and continent is not null
ORDER BY 1,2

--CHECKING TOTAL CASES VS POPULATION
--SHOWS WHAT % OF POPULATION GOT COVID
SELECT location, date, total_cases, population, (total_cases/population)*100 as PercentPopulationInfected
FROM PortfolioProject..CovidDeaths 
WHERE location like '%kenya%'
and continent is not null
ORDER BY 1,2

-- CHECKING counttries with hightest infection rate compared to population
SELECT location, MAX(total_cases) as HighestInfactionRate, population, MAX((total_cases)/population)*100 as PercentPopulationInfected
FROM PortfolioProject..CovidDeaths 
--WHERE location like '%kenya
GROUP BY location, population
ORDER BY PercentPopulationInfected desc


--			BREAKING IT BY CONTINET
--SHOWING COUNTRIES WITH HIGHEST DEATH COUNT PER POPULATION
 SELECT continent, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM PortfolioProject..CovidDeaths 
--WHERE location like '%kenya
WHERE continent is not null
GROUP BY continent
ORDER BY TotalDeathCount desc


 SELECT location, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM PortfolioProject..CovidDeaths 
--WHERE location like '%kenya
WHERE continent is null
GROUP BY location
ORDER BY TotalDeathCount desc



--SHOWING THE CONTINETNS WITH THE HIGHEST DEATH COUNT PER POPULATION

SELECT location, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM PortfolioProject..CovidDeaths 
--WHERE location like '%kenya
WHERE continent is null
GROUP BY location
ORDER BY TotalDeathCount desc


--global NO

SELECT SUM(new_cases) as total_cases,SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 AS DeathPercentage
FROM PortfolioProject..CovidDeaths
--WHERE location is like '%kenya%'
WHERE continent is not null
--GROUP BY date
order by 1,2

-- TOTAL POPULATION VS VACCINATION
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location, dea.date)
as RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccincation vac
on dea.location= vac.location
and dea.date = vac.date
where dea.continent is not null
order by 2,3

--USING CTE

with PopvsVac (continet, location, date, population,new_vaccinations, RollingPeopleVaccinated)
as
(select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location, dea.date)
as RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccincation vac
on dea.location= vac.location
and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)

SELECT *, (RollingPeopleVaccinated/population)*100 from PopvsVac

	
	--USING TEMP TABLE
CREATE TABLE #PercentPopulationVaccinated(
continet nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric, 
new_vaccinations numeric,
RollingPeopleVaccinated numeric
)
insert into #PercentPopulationVaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location, dea.date)
as RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccincation vac
on dea.location= vac.location
and dea.date = vac.date
where dea.continent is not null
--order by 2,3

SELECT *, (RollingPeopleVaccinated/population)*100 from #PercentPopulationVaccinated
FROM  PopvsVac


--TEMP TABLE
DROP TABLE if exists #PercentagePopulationVaccinated
create table #PercentagePopulationVaccinated
(Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric)

insert into #PercentagePopulationVaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location, dea.date)
as RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccincation vac
on dea.location= vac.location
and dea.date = vac.date
--where dea.continent is not null
--order by 2,3

select *, (RollingPeopleVaccinated/Population)*100
from #PercentagePopulationVaccinated


--creating view to store data for later

CREATE VIEW  percentagePopulationVaccinated AS
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location, dea.date)
as RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccincation vac
on dea.location= vac.location
and dea.date = vac.date
where dea.continent is not null
--order by 2,3



