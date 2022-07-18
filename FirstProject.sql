select *
from PortfolioProject..CovidDeaths$
where continent is not null
order by 3,4

--select *
--from PortfolioProject..CovidVaccinations$
--order by 3,4

select location,date,total_cases,new_cases, total_deaths,population
from PortfolioProject..CovidDeaths$
order by 1,2

select location,date,total_cases,total_deaths,(total_deaths/total_cases)*100 as DeathPercentage
from PortfolioProject..CovidDeaths$
where location like 'India'
order by 1,2

-- shows what %age of population got covid

select location,date,population,total_cases,(total_cases/population)*100 as PercentPopulationInfected
from PortfolioProject..CovidDeaths$
where location like '%state%'
order by 1,2

--highest infection rate wrt popuation

select location,population,MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as PercentPopulationInfected
from PortfolioProject..CovidDeaths$
--where location like '%state%'
where continent is not null
group by location,population
order by PercentPopulationInfected desc

-- showing countries with highest death count per population

select location,MAX(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProject..CovidDeaths$
--where location like '%state%'
where continent is not null
group by location
order by TotalDeathCount desc

-- seperating wrt Continents
-- Showing continents with the highest death count per population

select continent,MAX(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProject..CovidDeaths$
--where location like '%state%'
where continent is not null
group by continent
order by TotalDeathCount desc


-- Global Numbers

select  SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
from PortfolioProject..CovidDeaths$
--where location like '%state%'
where continent is not null
--group by date
order by 1,2

--total population  vs vaccincation

select dea.continent, dea.location , dea.date, dea.population, vac.new_vaccinations
,SUM(Cast(vac.new_vaccinations as int)) OVER (Partition by dea.location order by dea.location, dea.date)
as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths$ dea
join PortfolioProject..CovidVaccinations$ vac
on dea.location= vac.location
and dea.date= vac.date
where dea.continent is not null
order by 2,3

--use CTE

With PopvsVac (Continent, location, date, Population, new_vaccinations,RollingPeopleVaccinated)
as
(
select dea.continent, dea.location , dea.date, dea.population, vac.new_vaccinations
,SUM(Cast(vac.new_vaccinations as int)) OVER (Partition by dea.location order by dea.location, dea.date)
as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths$ dea
join PortfolioProject..CovidVaccinations$ vac
on dea.location= vac.location
and dea.date= vac.date
where dea.continent is not null
--order by 2,3
)

Select *,(RollingPeopleVaccinated/Population)*100
from PopvsVac	

-- TEMP Table

create table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric ,
New_Vaccinations numeric,
RollingPeopleVaccinated numeric
)

insert into #PercentPopulationVaccinated
select dea.continent, dea.location , dea.date, dea.population, vac.new_vaccinations
,SUM(Cast(vac.new_vaccinations as int)) OVER (Partition by dea.location order by dea.location, dea.date)
as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths$ dea
join PortfolioProject..CovidVaccinations$ vac
on dea.location= vac.location
and dea.date= vac.date
where dea.continent is not null

Select *,(RollingPeopleVaccinated/Population)*100
from #PercentPopulationVaccinated

--creating VIEW

create view PercentPopulationVaccinated as
select dea.continent, dea.location , dea.date, dea.population, vac.new_vaccinations
,SUM(Cast(vac.new_vaccinations as int)) OVER (Partition by dea.location order by dea.location, dea.date)
as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths$ dea
join PortfolioProject..CovidVaccinations$ vac
on dea.location= vac.location
and dea.date= vac.date
where dea.continent is not null
--order by 2,3


Select * from
PercentPopulationVaccinated
