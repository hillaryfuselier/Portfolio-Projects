Select *
From Portfolio..['Covid Deaths$']
Where continent is not null
order by 3,4

--Select *
--From Portfolio..['Covid Vac$']
--order by 3,4

--Select Data that we are going to be using

Select Location, date, total_cases, new_cases, total_deaths, population
From Portfolio..['Covid Deaths$']
order by 1,2


--Looking at Total Cases vs Total Deaths
--Shows likelihood dying
Select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From Portfolio..['Covid Deaths$']
Where location like '%states%'
order by 1,2


--Looking at the Total Cases vs Population
--Shows what percentage of the population has had Covid

Select Location, date, total_cases, population, (total_cases/population)*100 as DeathPercentage
From Portfolio..['Covid Deaths$']
Where location like '%states%'
order by 1,2


--Looking at Countries with highest infection rate compared to population

Select Location, population, MAX(total_cases) as HighestIngfectionCount, MAX((total_cases/population))*100 as PercentofPopulationInfected
From Portfolio..['Covid Deaths$']
--Where location like '%states%'
Group by Location, Population
order by PercentofPopulationInfected desc


--Showing Conutries with the highest Death Count Per Population

Select Location, MAX(cast(total_deaths as int)) as TotalDeathCount
From Portfolio..['Covid Deaths$']
--Where location like '%states%'
Where continent is not null
Group by Location
order by TotalDeathCount desc

--Let's break things down by continent

--Showing Conteinent with highest death count

Select continent, MAX(cast(total_deaths as int)) as TotalDeathCount
From Portfolio..['Covid Deaths$']
--Where location like '%states%'
Where continent is not null
Group by continent
order by TotalDeathCount desc


--GLOBAL NUMBERS

Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_cases)*100 as DeathPercentage
From Portfolio..['Covid Deaths$']
--Where location like '%states%'
Where continent is not null
--Group by date
order by 1,2


--Looking at Total Population vs Vaccinations

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CAST(vac.new_vaccinations as bigint)) OVER (Partition by dea.location ORDER by dea.location, dea.date) as RollingPeopleVaccinated
--(RollingPeopleVaccinated
From Portfolio..['Covid Deaths$'] dea
Join Portfolio..['Covid Vac$'] vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
Order by 2,3


--USE CTE

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CAST(vac.new_vaccinations as bigint)) OVER (Partition by dea.location ORDER by dea.location, dea.date) as RollingPeopleVaccinated
--(RollingPeopleVaccinated
From Portfolio..['Covid Deaths$'] dea
Join Portfolio..['Covid Vac$'] vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
--Order by 2,3
)
Select *
From PopvsVac

--TEMP TABLE

DROP TABLE if exists #PercentPopulationVaccinated
Create table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(225),
Data datetime,
Population numeric,
New_Vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CAST(vac.new_vaccinations as bigint)) OVER (Partition by dea.location ORDER by dea.location, dea.date) as RollingPeopleVaccinated
--(RollingPeopleVaccinated
From Portfolio..['Covid Deaths$'] dea
Join Portfolio..['Covid Vac$'] vac
	On dea.location = vac.location
	and dea.date = vac.date
--Where dea.continent is not null
--Order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated


--Creating View to Store Data for later visualizations

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CAST(vac.new_vaccinations as bigint)) OVER (Partition by dea.location ORDER by dea.location, dea.date) as RollingPeopleVaccinated
--(RollingPeopleVaccinated
From Portfolio..['Covid Deaths$'] dea
Join Portfolio..['Covid Vac$'] vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
--Order by 2,3

Select *
From PercentPopulationVaccinated