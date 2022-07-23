SELECT *
FROM PortfolioProject..CovidDeaths
ORDER BY 3,4

--SELECT *
--FROM PortfolioProject..CovidVaccinations
--ORDER BY 3,4

-- Select Relevant Data
SELECT location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject..CovidDeaths
ORDER BY 1,2

-- Looking at total cases VS total deaths
-- Shows likelihood of succumbing to Covid by country
SELECT location, continent, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE Location like '%Canada%'
ORDER BY 5 DESC

-- Looking at total cases VS population
-- Shows what percentage of population tested positive for Covid
SELECT location, date, total_cases, population, (total_cases/population)*100 AS PopulationPercentageInfected
FROM PortfolioProject..CovidDeaths
WHERE Location like '%Bahamas%'
ORDER BY 5 DESC
-- Looking at Countries with Highest infection rate
-- Shows what percentage of population tested positive for Covid
SELECT location, MAX(total_cases)as HighestInfectionCount, population, (MAX(total_cases)/population)*100 AS PopulationPercentageInfected
FROM PortfolioProject..CovidDeaths
Group By Location, Population
ORDER BY 1

--Countries with Highest Fatality per Population
SELECT location, MAX(cast(total_deaths as int)) AS FatalityCount
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
Group By Location
ORDER BY 2 DESC

-- Breaking Covid Deaths down by country and continent
SELECT location, continent, MAX(cast(total_deaths as int)) AS FatalityCount
FROM PortfolioProject..CovidDeaths
WHERE continent LIKE '%NORTH%'
AND total_deaths is not null
Group By continent, location
ORDER BY 2,3 DESC

-- Showing continents with the highest Covid Fatality count
SELECT location, continent, MAX(cast(total_deaths as int)) AS FatalityCount
INTO DeathByCountry /* Creates new table with Highest Fatality Count per Country */
FROM PortfolioProject..CovidDeaths
WHERE continent LIKE '%Ocean%'
AND total_deaths is not null
Group By continent, location
ORDER BY 2,3 DESC

-- Calculate Total Covid Fatalities by Continent
SELECT continent, SUM(FatalityCount) AS FatalityCount
FROM PortfolioProject..DeathByCountry
GROUP BY continent
ORDER BY 1 ;

-- Global Percentages of Fatal Cases of Infections by Day
SELECT date, SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths,
SUM(cast(new_deaths as int))/SUM(new_cases)*100 AS DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
GROUP BY date
ORDER BY 1,2


-- Looking at Total Population vs Vaccinations
With PopvsVac (continent, location, date, population, new_vaccinations, RollingVaxCount)
AS
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(convert(decimal,vac.new_vaccinations)) OVER (Partition by dea.location ORDER by dea.location, dea.date) AS RollingVaxCount
FROM PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null
--AND vac.location like '%united states%'
--Order by 2,3
)
Select *, (RollingVaxCount/population) *100 AS PercentageVaccinated
From PopvsVac