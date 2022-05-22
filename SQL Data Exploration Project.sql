Select *
From PortfolioProject..CovidDeaths$
where continent is not null
Order by 3,4

--Select *
--From PortfolioProject..CovidVaccinations$
--where continent is not null
--Order by 3,4

Select Location,date, total_cases, new_cases, total_deaths, population
From PortfolioProject..CovidDeaths$
where continent is not null
Order by 1,2

-- Looking at Total cases vs. Total Deaths
-- Shows the likelihood of dying if you contract Covid in a certain country

Select Location,date, total_cases, total_deaths,(total_deaths/total_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths$
Where location like '%states%'
--Where continent is not null
Order by 1,2

--Looking at Total Cases Vs Population
--Shows what percentage of the total population has gotten covid

Select Location,date, total_cases, population,(total_cases/population)*100 as PercentPopulutionInfected
From PortfolioProject..CovidDeaths$
--Where location like '%states%'
where continent is not null
Order by 1,2

--Looking at countries with the Highest Infection Rates compared to Population

Select Location, Population, Max(total_cases) as HighestInvectionCount, Max((total_cases/population))*100 as PercentPopulutionInfected
From PortfolioProject..CovidDeaths$
--Where location like '%states%'
where continent is not null
Group by Location, Population
order by PercentPopulutionInfected desc


--LET'S BREAK THINGS DOWN BY CONTINENT


--Showing Countries with the Hightest Death Count per Population
Select continent, Max(Cast(total_cases as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths$
--Where location like '%states%'
where continent is not null
Group by continent
order by TotalDeathCount desc

--Showing Continents with the Highest Death Counts

Select continent, Max(Cast(total_cases as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths$
--Where location like '%states%'
where continent is not null
Group by continent
order by TotalDeathCount desc

--GLOBAL NUMBERS

Select date, SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths,SUM(Cast(New_deaths as int))/SUM(new_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths$
--Where location like '%states%'
where continent is not null
Group By date
Order by 1,2

--Looking at Total Population vs Vaccinations

--USE CTE

With PopVSVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.Location, dea.Date) 
as RollingPeopleVaccinated
--,(RollingPeopleVaccinated/Population)*100
From PortfolioProject..CovidDeaths$ dea
Join PortfolioProject..CovidVaccinations$ vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--Order by 2,3
)
Select *, (RollingPeopleVaccinated/Population)*100 
From PopVSVac


-- TEMP TABLE

DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar (255),
Location nvarchar (255), 
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)



Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.Location, dea.Date) 
as RollingPeopleVaccinated
--,(RollingPeopleVaccinated/Population)*100
From PortfolioProject..CovidDeaths$ dea
Join PortfolioProject..CovidVaccinations$ vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--Order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated


--Creating View to store data for later vizualizations

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.Location, dea.Date) 
as RollingPeopleVaccinated
--,(RollingPeopleVaccinated/Population)*100
From PortfolioProject..CovidDeaths$ dea
Join PortfolioProject..CovidVaccinations$ vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--Order by 2,3




Select *
from PercentPopulationVaccinated
