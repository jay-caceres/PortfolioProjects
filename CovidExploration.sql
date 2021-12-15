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
SELECT location, MAX(total_deaths) as TotalDeathCount
FROM CovidDeaths
--WHERE location LIKE '%States%'
WHERE continent IS NULL
GROUP BY location
order by TotalDeathCount DESC