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
FROM
