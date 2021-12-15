SELECT location, date, total_cases, new_cases, total_deaths, population
FROM CovidDeaths
order by 1,2;

--Looking at total cases vs total deaths
--shows likelihood of dying if you contract COVID in the U.S.
SELECT location, date, total_cases, total_deaths,((total_deaths/total_cases) * 100) as death_percentage
FROM CovidDeaths
WHERE location LIKE '%States%'
order by 1,2;

--Total cases vs Population
--shows what percent of population has contracted COVID
SELECT location, date, total_cases, population,((total_cases/population) * 100) as cases_percentage
FROM CovidDeaths
--WHERE location LIKE '%States%'
order by 1,2;

-- Look at countries with highest infection rate compared to population
SELECT location,population, MAX(total_cases) as HighestInfectionCount,MAX((total_cases/population)) * 100 as PercentPopulationInfected
FROM CovidDeaths
--WHERE location LIKE '%States%'
GROUP BY location, population
order by PercentPopulationInfected DESC

-- showing countries with highest death count per population
SELECT location, MAX(total_deaths) as TotalDeathCount
FROM CovidDeaths
--WHERE location LIKE '%States%'
WHERE continent IS NOT NULL
GROUP BY location
order by TotalDeathCount DESC

--break it down by continent?
-- showing the continents with the highest death count per population

SELECT continent, MAX(total_deaths) as TotalDeathCount
FROM CovidDeaths
--WHERE location LIKE '%States%'
WHERE continent IS NOT NULL
GROUP BY continent
order by TotalDeathCount DESC

-- Global numbers --
SELECT date, SUM(new_cases) total_cases, SUM(new_deaths) total_deaths,((SUM(new_deaths)/SUM(new_cases)) * 100) as death_percentage
FROM CovidDeaths
--WHERE location LIKE '%States%'
WHERE  continent IS NOT NULL
GROUP BY date
order by 1,2

--global new cases, deaths, death percentage
SELECT SUM(new_cases) total_cases, SUM(new_deaths) total_deaths,((SUM(new_deaths)/SUM(new_cases)) * 100) as death_percentage
FROM CovidDeaths
--WHERE location LIKE '%States%'
WHERE  continent IS NOT NULL
order by 1,2


--looking at total pop vs vaccinations *partition by*

SELECT dea.continent, dea.location, dea.date,dea.population, vac.new_vaccinations,
SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) rolling_new_vaccinations
--, (rolling_new_vaccinations/population)*100
FROM CovidDeaths dea
JOIN CovidVaccinations vac
ON dea.location = vac.location and dea.date = vac.date 
WHERE dea.continent IS NOT NULL
ORDER BY 2,3

-- USE CTE
WITH PopvsVac (Continent, location, date, population, new_vaccinations,rolling_new_vaccinations)
AS 
(SELECT dea.continent, dea.location, dea.date,dea.population, vac.new_vaccinations,
SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) rolling_new_vaccinations
--, (rolling_new_vaccinations/population)*100
FROM CovidDeaths dea
JOIN CovidVaccinations vac
ON dea.location = vac.location and dea.date = vac.date 
WHERE dea.continent IS NOT NULL
--ORDER BY 2,3
)
SELECT *, (rolling_new_vaccinations/population)*100 
FROM PopvsVac

-- TEMP TABLE
DROP TABLE IF EXISTS #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
Continent NVARCHAR(255),
Location NVARCHAR(255),
Date DATETIME,
Population NUMERIC,
new_vaccinations NUMERIC,
RollingPeopleVaccinated NUMERIC
)

INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date,dea.population, vac.new_vaccinations,
SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) rolling_new_vaccinations
--, (rolling_new_vaccinations/population)*100
FROM CovidDeaths dea
JOIN CovidVaccinations vac
ON dea.location = vac.location and dea.date = vac.date 
WHERE dea.continent IS NOT NULL
--ORDER BY 2,3

SELECT *, (RollingPeopleVaccinated/population)*100 AS percent_vax_pop
FROM #PercentPopulationVaccinated

--Creating view to store data for later visualizations

CREATE VIEW PercentPopulationVaccinated AS
SELECT dea.continent, dea.location, dea.date,dea.population, vac.new_vaccinations,
SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) rolling_new_vaccinations
--, (rolling_new_vaccinations/population)*100
FROM CovidDeaths dea
JOIN CovidVaccinations vac
ON dea.location = vac.location and dea.date = vac.date 
WHERE dea.continent IS NOT NULL
--ORDER BY 2,3

SELECT * 
FROM PercentPopulationVaccinated