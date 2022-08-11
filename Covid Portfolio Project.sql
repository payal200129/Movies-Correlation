create database PortfolioProject;
SELECT *
FROM PortfolioProject..CovidDeaths
--WHERE continent is not null;

SELECT location,date,new_cases,total_cases,population,total_deaths
FROM PortfolioProject..CovidDeaths
ORDER BY 3,4;

--Looking at Total cases vs Total Deaths
--Shows the likelihood of dying if you contract Covid in India
SELECT location,date,total_cases,total_deaths,(total_deaths/total_cases)*100 as PercentagePopulationInfected
FROM PortfolioProject..CovidDeaths
WHERE location like '%india%'
ORDER BY 1,2;

--Looking at Total Cases vs Population
SELECT location,date,total_cases,Population,(total_deaths/total_cases)*100 as PercentagePopulationInfected
FROM PortfolioProject..CovidDeaths
WHERE location like '%india%'
ORDER BY 1,2;

--Looking at countries with hoighest infection rate compared to Population
SELECT location,population,MAX(total_cases) AS HighestInfectionCount,max((total_cases/population))*100 as PercentagePopulationInfected
FROM PortfolioProject..CovidDeaths
--WHERE location like '%india%'
GROUP BY location,population
ORDER BY PercentagePopulationInfected DESC;

--LET'S BREAK THINGS DOWN BY CONTINENT

--Showing countries with highest death count per population
SELECT location,MAX(cast(total_deaths as int)) AS TotalDeathCount
FROM PortfolioProject..CovidDeaths
--WHERE location like '%india%'
WHERE continent is  not null
GROUP BY location
ORDER BY TotalDeathCount DESC;

--Showing continents with highest death count
SELECT continent,MAX(cast(total_deaths as int)) AS TotalDeathCount
FROM PortfolioProject..CovidDeaths
--WHERE location like '%india%'
WHERE continent is  not null
GROUP BY continent
ORDER BY TotalDeathCount DESC;

--Global Numbers
SELECT date,SUM(new_cases) as total_cases,SUM(cast(new_deaths as int)) as total_deaths,SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
FROM PortfolioProject..CovidDeaths
--WHERE location like '%india%'
WHERE continent is  not null
GROUP BY date
ORDER BY 1,2;


-- Total Population vs Vaccinations
--USE CTE
WITH PopvsVac (continent,location,date,Population,rollingPeopleVaccinated,new_vaccinations)
as 
(
SELECT dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations
,SUM(CONVERT(int,vac.new_vaccinations)) OVER (partition by dea.location ORDER BY dea.location,dea.date) as rollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths as dea
JOIN PortfolioProject..CovidVaccinations as vac
ON dea.location=vac.location
AND dea.date=vac.date
WHERE dea.continent is  not null
--ORDER BY 2,3
)
SELECT *,(rollingPeopleVaccinated/Population)*100
FROM PopvsVac

--TEMP TABLE
DROP TABLE if exists PercentPopulationVaccinated
CREATE TABLE PercentPopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
Date datetime,
Population numeric,
rollingPeopleVaccinated numeric
)

INSERT INTO PercentPopulationVaccinated
SELECT dea.continent,dea.location,dea.date,dea.population
,SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (partition by dea.location ORDER BY dea.location,dea.date) as rollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths as dea
JOIN PortfolioProject..CovidVaccinations as vac
ON dea.location=vac.location
AND dea.date=vac.date
--WHERE dea.continent is  not null
--ORDER BY 2,3
SELECT *,(rollingPeopleVaccinated/Population)*100
FROM PercentPopulationVaccinated


