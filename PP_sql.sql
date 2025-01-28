SELECT *
FROM covid_Deaths
ORDER BY  3,4;

--Selecting the data we are goinng to use

SELECT location,date, total_cases,new_cases, total_deaths, population 
FROM covid_Deaths
order by 1,2;


--looking at total_cases vs Total_deaths 

SELECT location,date, total_cases, total_deaths, (total_deaths/total_cases)*100 as deathpercentage
FROM covid_Deaths
WHERE location LIKE 'India'
order by 1,2;

-- Looking at total cases vs population 
-- showing percentage of population got covid

SELECT location,date, population, total_cases, (total_deaths/population)*100 as infectPercentage
FROM covid_Deaths
WHERE location LIKE 'India'
order by 1,2;

-- looking at countries with highest infectioinn rate compared to population 

SELECT location,population, MAX(total_cases) as maxInfectCount, max(cast((total_cases/population)*100 as bigint)) as deathpercentage
FROM covid_Deaths
--WHERE location LIKE 'India'
GROUP BY 1,2
order by 1,2;


-- Showing countries with highest death count per population 
SELECT location, max(total_deaths) as total_death_count
FROM covid_Deaths
WHERE continent  is not null 
group by 1
order by 2 desc;

--Breaking  things down by continents

--Showing continents with the highest death count per population
SELECT continent, max(total_deaths) as total_death_count
FROM covid_Deaths
WHERE continent  is not null 
group by 1
order by 2 desc;


  
-- GLOBAL NUMBERS 

SELECT date, total_cases, total_deaths, (total_deaths/total_cases)*100 as deathpercentage
FROM covid_Deaths
WHERE continent is not null
order by 1,2;


-- looking at total  poplation vs vaccinations

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(cast(vac.new_vaccinations as int) ) OVER (partition by dea.location order by dea.location,
 dea.date)  AS rollingpeoplevaccinated
FROM covid_deaths dea
join covid_vaccinations vac
on dea.date = vac.date 
where dea.continent is not null and vac.new_vaccinations is not null
order by 2,3 


--Using CTE

WITH PopVsVac(continet,  location, date, new_vaccinations,rollingpeoplevaccinated)
AS (
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(cast(vac.new_vaccinations as int) ) OVER (partition by dea.location order by dea.location,
 dea.date)  AS rollingpeoplevaccinated
FROM covid_deaths dea
join covid_vaccinations vac
on dea.date = vac.date 
where dea.continent is not null and vac.new_vaccinations is not null
--order by 2,3 
)

SELECT *  
FROM PopVsVac;



create view PercentPopulationVaccinated as 
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(cast(vac.new_vaccinations as int) ) OVER (partition by dea.location order by dea.location,
 dea.date)  AS rollingpeoplevaccinated
FROM covid_deaths dea
join covid_vaccinations vac
on dea.date = vac.date 
where dea.continent is not null;



SELECT * 
FROM PercentPopulationVaccinated;