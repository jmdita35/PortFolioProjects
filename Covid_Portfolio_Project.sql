
--Looking at total cases vs population
-- shows likelihood of dying if you contract covid in your country

SELECT location, date, total_cases, total_deaths, total_deaths/cast(total_cases as float)*100 as death_percentage
FROM Portfolio_Project..CovidDeaths
WHERE location like '%Philippines%'
order by 1,2 

--Looking at total cases vs population
-- Shows what percentage of population got Covid

SELECT location, date, population, total_cases, total_cases/cast(population as float)*100 as Percent_Population_Infected
FROM Portfolio_Project..CovidDeaths
WHERE location like '%Philippines%'
order by 1,2

--looking at Countries with the Highest Infection Rate compared to Population

SELECT location, population, MAX(total_cases) AS Highest_Infection_Count,MAX(total_cases/cast(population as float))*100 as Percent_Population_Infected
FROM Portfolio_Project..CovidDeaths
-- WHERE location like '%Philippines%'
GROUP BY location, population
order by Percent_Population_Infected DESC

-- Showing Countries with Highest Death Count per Population

SELECT continent, MAX(total_deaths) as TotalDeathCount
FROM Portfolio_Project..CovidDeaths
WHERE location like '%Philippines%'
-- WHERE continent is not null
GROUP BY continent
order by TotalDeathCount DESC

-- Break things by continent

SELECT location, MAX(total_deaths) as TotalDeathCount
FROM Portfolio_Project..CovidDeaths
--WHERE location like '%Philippines%'
WHERE continent is null
GROUP BY location
order by TotalDeathCount DESC

-- Showing the continents with the highest death count per population

SELECT location, MAX(total_deaths) as TotalDeathCount
FROM Portfolio_Project..CovidDeaths
WHERE location like '%Philippines%'
-- WHERE continent is null
GROUP BY location
order by TotalDeathCount DESC

-- GLOBAL NUMBERS

SELECT date, SUM(new_cases) AS total_cases, SUM(new_deaths) as total_deaths, SUM(new_deaths)/SUM(new_cases) *100 as death_percentage
FROM Portfolio_Project..CovidDeaths
--WHERE location like '%Philippines%'
WHERE continent is not null
GROUP BY date
order by 1,2 

-- Looking at Total Population vs Vaccinations
-- USE CTE

With PopvsVac (Continent,Location, Date, Population, new_vaccinations, Rolling_People_Vaccinated)
as
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CAST (vac.new_vaccinations AS int))
OVER (Partition by dea.location ORDER BY dea.location, dea.date) as Rolling_People_Vaccinated
--,(Rolling_People_Vaccinated/population)*100
FROM Portfolio_Project..CovidDeaths AS dea
JOIN Portfolio_Project..CovidVaccinations AS vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null
-- order by 2,3
)

SELECT *, (Rolling_People_Vaccinated/Population)*100
FROM PopvsVac

--TEMP TABLE
DROP TABLE if exists #Percentage_Population_Vaccinated
CREATE TABLE #Percentage_Population_Vaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
Rolling_People_Vaccinated numeric
)

INSERT INTO #Percentage_Population_Vaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CAST (vac.new_vaccinations AS int))
OVER (Partition by dea.location ORDER BY dea.location, dea.date) as Rolling_People_Vaccinated
--,(Rolling_People_Vaccinated/population)*100
FROM Portfolio_Project..CovidDeaths AS dea
JOIN Portfolio_Project..CovidVaccinations AS vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null
-- order by 2,3

SELECT *, (Rolling_People_Vaccinated/Population)*100
FROM #Percentage_Population_Vaccinated

-- Creating View to store data for later visualizations

CREATE VIEW Percent_Population_Vaccinated AS
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CAST (vac.new_vaccinations AS int))
OVER (Partition by dea.location ORDER BY dea.location, dea.date) as Rolling_People_Vaccinated
--,(Rolling_People_Vaccinated/population)*100
FROM Portfolio_Project..CovidDeaths AS dea
JOIN Portfolio_Project..CovidVaccinations AS vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null
-- order by 2,3

