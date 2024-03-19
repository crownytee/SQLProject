Select *
From PortfolioProject1..CovidDeaths$
Where continent is not null
Order By 3,4

--Select *
--From PortfolioProject1..CovidVaccinations$
--Order By 3,4

Select location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject1..CovidDeaths$
Where continent is not null
Order By 1,2

--Total Cases vs Total Deaths
-- Likelihood of dying when a person is infected with covid
Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 DeathPercentage
From PortfolioProject1..CovidDeaths$
Where location like '%states%'
Where continent is not null
Order By 1,2

Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 DeathPercentage
From PortfolioProject1..CovidDeaths$
Where location = 'Africa'
Where continent is not null
Order By 1,2

Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 DeathPercentage
From PortfolioProject1..CovidDeaths$
Where location like '%A%f%g%'
Where continent is not null
Order By 1,2

--Total Cases vs Population
--Percentage of population infected by Covid in a country
Select location, date, total_cases, population, (total_cases/population)*100 PercentPopulationInfected
From PortfolioProject1..CovidDeaths$
Where location like '%A%f%g%'
Where continent is not null
Order By 1,2

Select location, date, total_cases, population, (total_cases/population)*100 PercentPopulationInfected
From PortfolioProject1..CovidDeaths$
Where location like '%states%'
Where continent is not null
Order By 1,2

--Country with the highest infection rate compared with population

Select location, population, MAX(total_cases) as HighestInfectionCount, Max((total_cases/population))*100 PercentPopulationInfected
From PortfolioProject1..CovidDeaths$
Where continent is not null
Group By location, population
Order By PercentPopulationInfected desc

--Countries with highest Death Count 

Select location, MAX(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject1..CovidDeaths$
Where continent is null
Group By location
Order By TotalDeathCount desc

-- Continent with highest Death Count

Select continent, MAX(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject1..CovidDeaths$
Where continent is not null
Group By continent
Order By TotalDeathCount desc

-- Continent with the highest death count per population

Select continent, MAX(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject1..CovidDeaths$
Where continent is not null
Group By continent
Order By TotalDeathCount desc

--Global Numbers
--Sum of new cases across the world
select date, SUM(new_cases)
From PortfolioProject1.dbo.CovidDeaths$
Where Continent is not null
group By date
order by 1,2

--
select date, SUM(new_cases), SUM(cast(new_deaths as int)) as DeathPercentage
From PortfolioProject1.dbo.CovidDeaths$
Where Continent is not null
group By date
order by 1,2

-- Total cases, total Deaths per day
select date, SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int)) / SUM 
(new_cases) * 100 as DeathPercentage
From PortfolioProject1.dbo.CovidDeaths$
Where Continent is not null
Group By date
order by 1,2

-- Total Cases, Total Deaths and Death Percent across the World.
select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int)) / SUM 
(new_cases) * 100 as DeathPercentage
From PortfolioProject1.dbo.CovidDeaths$
Where Continent is not null
order by 1,2

-- Total Popuation vs Vaccinations
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
FROM PortfolioProject1..CovidDeaths$ dea
Join PortfolioProject1..CovidVaccinations$ vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null
ORDER By 2,3


select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as int)) OVER (partition by dea.location)
FROM PortfolioProject1..CovidDeaths$ dea
Join PortfolioProject1..CovidVaccinations$ vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null
ORDER By 2,3

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(convert(int, vac.new_vaccinations)) OVER (partition by dea.location)
FROM PortfolioProject1..CovidDeaths$ dea
Join PortfolioProject1..CovidVaccinations$ vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null
ORDER By 2,3

-- Using CTE

with popvsvac (continent, location, Date, population, new_vaccinations, RollingPeopleVaccinated)
as
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(convert(int, vac.new_vaccinations)) OVER (partition by dea.location, dea.date) as RollingPeopleVaccinated
FROM PortfolioProject1..CovidDeaths$ dea
Join PortfolioProject1..CovidVaccinations$ vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null
)
SELECT *, (RollingPeopleVaccinated/population) * 100
FROM popvsvac

--Using Temp Table
DROP TABLE if Exists #PercentPopulationVaccinated
create Table #percentpopulationvaccinated
(
Continent nvarchar(225),
Location nvarchar(225),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)
INSERT INTO #percentpopulationvaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(convert(int, vac.new_vaccinations)) OVER (partition by dea.location, dea.date) as RollingPeopleVaccinated
FROM PortfolioProject1..CovidDeaths$ dea
Join PortfolioProject1..CovidVaccinations$ vac
	ON dea.location = vac.location
	and dea.date = vac.date
--WHERE dea.continent is not null
--order by 2,3

SELECT *, (RollingPeopleVaccinated/population) * 100
FROM #percentpopulationvaccinated

-- Create View to Store Data for Later Visualizations

Create View PercentPopulationVaccinated as 
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(convert(int, vac.new_vaccinations)) OVER (partition by dea.location, dea.date) as RollingPeopleVaccinated
FROM PortfolioProject1..CovidDeaths$ dea
Join PortfolioProject1..CovidVaccinations$ vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null

SELECT *
FROM PercentPopulationVaccinated   --Table for visualization






