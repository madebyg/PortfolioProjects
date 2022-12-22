	-- Data as of 04/30/2021
	-- Total Cases vs Total Death (death percentage) - USA
SELECT location, total_deaths/total_cases :: float*100 AS deathratio
WHERE continent IS NOT null
FROM coviddeaths


GROUP BY location
ORDER BY location, deathratio desc

	-- Total Cases vs Population (percentage of population that got COVID) - USA
	-- Infection Rate in the US
SELECT location, date, population, total_cases, total_cases/population :: float*100 as infection
FROM coviddeaths
WHERE location LIKE '%States%' AND continent IS NOT null
GROUP BY location, date, population, total_cases

	--Highest Infection Rate?

SELECT location, population, MAX(total_cases) as infection_count, Max(total_cases/population :: float*100) as infection
FROM coviddeaths
WHERE continent IS NOT null
GROUP BY location, population
HAVING Max(total_cases/population :: float*100) IS NOT null

ORDER BY infection desc 

	--highest death count per population
	
SELECT location, MAX(total_deaths) as deaths
FROM coviddeaths
WHERE continent IS NOT null
GROUP BY location
HAVING MAX(total_deaths) IS NOT null
order by deaths desc

	--deaths by continent
SELECT location, MAX(total_deaths) as deaths
FROM coviddeaths
WHERE continent IS null
GROUP BY location
HAVING MAX(total_deaths) IS NOT null
order by deaths desc

	-- Global #s
	--Death Percentage daily in the world

SELECT date, SUM(new_cases) as globalcases, SUM(new_deaths) as globaldeaths,
		SUM(new_deaths)/SUM(new_cases) :: float*100 as GlobalDeathPercent
FROM coviddeaths
WHERE continent IS NOT null
GROUP BY date
ORDER BY date

	--global death percentage
	
SELECT SUM(new_cases) as globalcases, SUM(new_deaths) as globaldeaths,
		SUM(new_deaths)/SUM(new_cases) :: float*100 as GlobalDeathPercent
FROM coviddeaths
WHERE continent IS NOT null

	--Join with Vaccination Table
	-- Population vs Vaccine
	
WITH A as
(
SELECT cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations,
SUM(new_vaccinations) OVER (partition by (cd.location) Order by cd.location, cd.date) as totalvac_daily

from coviddeaths as cd
JOIN covidvaccinations as cv ON
cd.location = cv.location AND cd.date = cv.date
WHERE cd.continent IS NOT null
ORDER BY location, date)

SELECT *, totalvac_daily/population :: float*100 as VaccinatedPercentage From A 


