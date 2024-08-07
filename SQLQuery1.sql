select * from PortfolioProject..CovidDeaths
order by 3,4

--selecting data to be used
select location, date, total_cases, new_cases, total_deaths, population from PortfolioProject..CovidDeaths
order by 1,2;

--looking at total cases vs total deaths
select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from PortfolioProject..CovidDeaths
where total_cases > 0
order by 1,2;

--looking at death percentage of a country
select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from PortfolioProject..CovidDeaths
where total_cases > 0 and location = 'India'
order by 1,2;

--looking at total cases vs population
--to see what percentage of population got covid
select location, date, population, total_cases, (total_cases/population)*100 as PercentPopulationInfected
from PortfolioProject..CovidDeaths
where total_cases > 0 and location = 'India'
order by 1,2;

--looking at countries with highest infection rate
select location, population, max(total_cases) as HighestInfectionCount, max((total_cases/population)*100) as PercentPopulationInfected
from PortfolioProject..CovidDeaths
where total_cases > 0
group by location, population
order by PercentPopulationInfected desc;

--showing countries with highest death count per population
select location, max(total_deaths) as TotalDeathCount
from PortfolioProject..CovidDeaths
where total_cases > 0 and continent is not null
group by location
order by TotalDeathCount desc;

--same thing but with continent wise
select continent, max(total_deaths) as TotalDeathCount
from PortfolioProject..CovidDeaths
where continent is not null
group by continent
order by TotalDeathCount desc;


--global numbers 
select sum(new_cases) as total_cases, sum(new_deaths) as total_deaths, (sum(total_deaths)/sum(total_cases))*100 as DeathPercentage
from PortfolioProject..CovidDeaths
where total_cases > 0 and continent is not null
order by 1,2;


--total population vs vaccinations
-- using CTE
with PopVsVac (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
as
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(cast(vac.new_vaccinations as float)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations  vac
	on dea.location = vac.location
	and dea.date = vac.date
	where dea.continent is not null
)
select *, (RollingPeopleVaccinated/population)*100
from PopVsVac;


--temp table
drop table if exists #PercentPopulationVaccinated;
create table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

insert into #PercentPopulationVaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(cast(vac.new_vaccinations as bigint)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations  vac
	on dea.location = vac.location
	and dea.date = vac.date
	where dea.continent is not null

select *, (RollingPeopleVaccinated/population)*100
from #PercentPopulationVaccinated;
 
--creating view to store data for visualization if needed
drop view if exists PercentPopulationVaccinated;
create view PercentPopulationVaccinated as
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(cast(vac.new_vaccinations as bigint)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations  vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null;