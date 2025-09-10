This project explores global COVID-19 data using SQL to identify trends in cases, deaths, and vaccinations. The datasets include CovidDeaths and CovidVaccinations tables, containing information such as cases, deaths, population, and vaccination progress across countries and continents.

The primary goal was to analyze key metrics (infection rates, death percentages, vaccination rollouts) and create reusable queries, views, and insights for further visualization in BI tools like Tableau or Power BI.

Skills & SQL Concepts Applied

Data Cleaning & Filtering → Handling missing continent values

Aggregations → Identifying highest infection & death counts

Window Functions → Tracking rolling vaccination counts

CTEs & Temp Tables → Breaking down complex calculations

Views → Creating reusable datasets for visualization

Data Type Conversion → Ensuring numerical calculations are accurate

Key Insights

Death Likelihood: Calculated the probability of dying after contracting COVID-19 in specific countries.

Infection Rates: Determined the highest infection percentages relative to population.

Global Death Counts: Aggregated cases and deaths at a global scale for trend analysis.

Vaccination Progress: Analyzed percentage of population vaccinated using rolling sums and partitions.

Continental Analysis: Compared total deaths across continents to identify worst-hit regions.

Example Results

Countries like the United States and India showed some of the highest case numbers.

Infection percentages revealed smaller nations with relatively higher exposure rates.

Vaccination analysis highlighted disparities between continents in rollout efficiency.

/* 
COVID-19 Data Exploration Project
Skills Demonstrated:
- Joins
- CTEs
- Temp Tables
- Window Functions
- Aggregate Functions
- Creating Views
- Data Type Conversions
*/

/* -------------------------------
   1. Initial Data Exploration
---------------------------------*/

-- Preview CovidDeaths dataset
SELECT *
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
ORDER BY location, date;

-- Preview CovidVaccinations dataset
SELECT *
FROM PortfolioProject..CovidVaccinations
ORDER BY location, date;


/* -------------------------------
   2. Selecting Relevant Fields
---------------------------------*/
SELECT 
    location, 
    date, 
    total_cases, 
    new_cases, 
    total_deaths, 
    population
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
ORDER BY location, date;


/* -------------------------------
   3. Total Cases vs Total Deaths
   Shows likelihood of dying if you contract COVID-19
---------------------------------*/
SELECT 
    location, 
    date, 
    total_cases, 
    total_deaths, 
    (total_deaths / total_cases) * 100 AS DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE location LIKE '%states%'
  AND continent IS NOT NULL
ORDER BY location, date;


/* -------------------------------
   4. Total Cases vs Population
   Shows what percentage of population has been infected
---------------------------------*/
SELECT 
    location, 
    date, 
    population, 
    total_cases,  
    (total_cases / population) * 100 AS PercentPopulationInfected
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
ORDER BY location, date;


/* -------------------------------
   5. Countries with Highest Infection Rate vs Population
---------------------------------*/
SELECT 
    location, 
    population, 
    MAX(total_cases) AS HighestInfectionCount,  
    MAX((total_cases / population)) * 100 AS PercentPopulationInfected
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location, population
ORDER BY PercentPopulationInfected DESC;


/* -------------------------------
   6. Countries with Highest Death Count
---------------------------------*/
SELECT 
    location, 
    MAX(CAST(total_deaths AS INT)) AS TotalDeathCount
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY TotalDeathCount DESC;


/* -------------------------------
   7. Death Count by Continent
---------------------------------*/
SELECT 
    continent, 
    MAX(CAST(total_deaths AS INT)) AS TotalDeathCount
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY TotalDeathCount DESC;


/* -------------------------------
   8. Global Numbers
---------------------------------*/
SELECT 
    SUM(new_cases) AS total_cases, 
    SUM(CAST(new_deaths AS INT)) AS total_deaths, 
    (SUM(CAST(new_deaths AS INT)) / SUM(new_cases)) * 100 AS DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL;


/* -------------------------------
   9. Population vs Vaccinations
   Shows % of population that has received at least one dose
---------------------------------*/
SELECT 
    dea.continent, 
    dea.location, 
    dea.date, 
    dea.population, 
    vac.new_vaccinations,
    SUM(CONVERT(INT, vac.new_vaccinations)) 
        OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
    ON dea.location = vac.location
   AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
ORDER BY dea.location, dea.date;


/* -------------------------------
   10. Using CTE for % Vaccinated
---------------------------------*/
WITH PopvsVac AS (
    SELECT 
        dea.continent, 
        dea.location, 
        dea.date, 
        dea.population, 
        vac.new_vaccinations,
        SUM(CONVERT(INT, vac.new_vaccinations)) 
            OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
    FROM PortfolioProject..CovidDeaths dea
    JOIN PortfolioProject..CovidVaccinations vac
        ON dea.location = vac.location
       AND dea.date = vac.date
    WHERE dea.continent IS NOT NULL
)
SELECT *, (RollingPeopleVaccinated / population) * 100 AS PercentPopulationVaccinated
FROM PopvsVac;


/* -------------------------------
   11. Using Temp Table for % Vaccinated
---------------------------------*/
DROP TABLE IF EXISTS #PercentPopulationVaccinated;

CREATE TABLE #PercentPopulationVaccinated (
    Continent NVARCHAR(255),
    Location NVARCHAR(255),
    Date DATETIME,
    Population NUMERIC,
    New_vaccinations NUMERIC,
    RollingPeopleVaccinated NUMERIC
);

INSERT INTO #PercentPopulationVaccinated
SELECT 
    dea.continent, 
    dea.location, 
    dea.date, 
    dea.population, 
    vac.new_vaccinations,
    SUM(CONVERT(INT, vac.new_vaccinations)) 
        OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
    ON dea.location = vac.location
   AND dea.date = vac.date;

SELECT *, (RollingPeopleVaccinated / population) * 100 AS PercentPopulationVaccinated
FROM #PercentPopulationVaccinated;


/* -------------------------------
   12. Creating View for Visualization
---------------------------------*/
CREATE VIEW PercentPopulationVaccinated AS
SELECT 
    dea.continent, 
    dea.location, 
    dea.date, 
    dea.population, 
    vac.new_vaccinations,
    SUM(CONVERT(INT, vac.new_vaccinations)) 
        OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
    ON dea.location = vac.location
   AND dea.date = vac.date
WHERE dea.continent IS NOT NULL;

-- Preview View
SELECT *
FROM PercentPopulationVaccinated
ORDER BY population DESC;
