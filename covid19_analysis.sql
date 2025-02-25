-- select *
-- from coviddeaths;
-- ORDER BY iso_code;
SELECT country,report_date,total_cases,new_cases,total_deaths,population
FROM deaths;
-- ORDER BY location;

-- looking at the total cases vs total deaths 
 SELECT country, report_date ,total_cases,total_deaths,(total_deaths/total_cases)*100 AS deathpercentage
FROM deaths;

-- looking at the total cases vs population
-- shows what percentage of population has got covid 
SELECT country, report_date ,total_cases,population,(total_cases/population)*100 AS percentpopulationinfected
FROM deaths;

-- LOOKING at countries with highest infection rate compared to population 
SELECT country, population, 
       MAX(total_cases) AS highest_infection_count, 
       MAX(total_cases / population) * 100 AS percent_population_infected
FROM deaths
GROUP BY country, population
ORDER BY percent_population_infected DESC
LIMIT 1000;
-- lets break down
-- showing countries highest death count per population conversion to int data 
SELECT country, 
       MAX(CAST(NULLIF(total_deaths, '') AS UNSIGNED)) AS total_deathcount
FROM deaths 
WHERE total_deaths IS NOT NULL AND total_deaths <> '' AND continent IS NOT NULL
GROUP BY country
ORDER BY total_deathcount DESC;

-- same thing by continent 
SELECT continent, 
       MAX(CAST(NULLIF(total_deaths, '') AS UNSIGNED)) AS total_deathcount
FROM deaths 
WHERE total_deaths IS NOT NULL AND total_deaths <> '' AND continent IS NOT NULL
GROUP BY continent
ORDER BY total_deathcount DESC;


-- showing the continent with highest death count
SELECT continent,MAX(CAST(NULLIF(total_deaths,'')AS unsigned)) AS death_count
FROM deaths
WHERE total_deaths IS NOT NULL AND total_deaths <> '' AND continent IS NOT NULL
GROUP BY continent
ORDER BY death_count DESC;


-- global numbers
 SELECT SUM(new_cases)AS totalcases ,SUM(new_deaths) AS totaldeaths,SUM(new_deaths)/SUM(new_cases)*100 AS deathpercentage
FROM deaths
WHERE continent IS NOT NULL

-- vacination
SELECT *
FROM vacination;
-- joining the two tables 
SELECT *
FROM deaths AS dea
JOIN vacination AS vac
ON  dea.country=vac.location AND dea.country_code=vac.iso_code  ;



-- looking at total population vs vaccinations
-- USE CTE
WITH popvsvac (continent, location, date, population, new_vaccination, rollingpeoplevaccinated) AS  
(
    SELECT dea.continent, 
           dea.country AS location, 
           dea.report_date AS date, 
           dea.population, 
           vac.new_vaccinations, 
           CAST(SUM(vac.new_vaccinations) OVER (PARTITION BY dea.report_date ORDER BY dea.country, dea.report_date) AS UNSIGNED) AS rollingpeoplevaccinated
    FROM deaths AS dea
    JOIN vacination AS vac  
    ON dea.continent = vac.continent
)
SELECT * ,(rollingpeoplevaccinated/population)*100 AS rollingpeoplevaccinated_percentage
FROM popvsvac;

-- create view to store data for later visualisation
CREATE VIEW percentpopulationvaccinated AS 
SELECT dea.continent, 
           dea.country AS location, 
           dea.report_date AS date, 
           dea.population, 
           vac.new_vaccinations, 
           CAST(SUM(vac.new_vaccinations) OVER (PARTITION BY dea.report_date ORDER BY dea.country, dea.report_date) AS UNSIGNED) AS rollingpeoplevaccinated
    FROM deaths AS dea
    JOIN vacination AS vac  
    ON dea.continent = vac.continent

SELECT *
FROM percentpopulationvaccinated
