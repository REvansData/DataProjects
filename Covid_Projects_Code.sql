Select * 
From Covid_Project.dbo.CovidDeaths$
order by 3,4

--Select * 
--From Covid_Project..CovidVaccinations$
--Order by 3,4

--Selecting our data
Select Location,date,total_cases,new_cases,total_deaths,population
From Covid_Project.dbo.CovidDeaths$
Order by 1,2

--Looking at total cases vs total deaths
--Showing likelihood of death in your country. 
Select Location,date,total_cases,total_deaths,(total_deaths/total_cases)*100 as death_percentage
From Covid_Project.dbo.CovidDeaths$
Where location like '%states%' and continent is not null
Order by 1,2

--Looking at total cases vs population
Select Location,date,Population,total_cases,(total_cases/population)*100 as infected_percentage
From Covid_Project.dbo.CovidDeaths$
Where location like '%states%' and continent is not null
Order by 1,2

--Countries with Highest Infection Rates to Population
Select Location,Population,MAX(total_cases) as Highest_Infection_Count,MAX((total_cases/population)*100) as infected_percentage
From Covid_Project.dbo.CovidDeaths$
Where continent is not null
Group By Population,Location
Order by 4 desc

--Countries with Highest Death count per population
Select Location,Max(cast(total_deaths as int)) as TotalDeathCount
From Covid_Project.dbo.CovidDeaths$
Where continent is not null
Group By Location
Order by 2 desc

--By Continent
--Showing Continents with Highest Death Counts
Select location,Max(cast(total_deaths as int)) as TotalDeathCount
From Covid_Project.dbo.CovidDeaths$
Where continent is  null
Group By location
Order by 2 desc

Select SUM(new_cases) as Total_Cases,Sum(cast(new_deaths as int)) as Total_Deaths,Sum(cast(new_deaths as int))/Sum(new_cases) *100 as DeathPercentage
From Covid_Project..CovidDeaths$
Where continent  is not null
--group by date
Order by 1,2


Select d.continent,d.location,d.date,d.population,v.new_vaccinations,Sum(convert(bigint,v.new_vaccinations)) OVER (Partition by d.location Order by d.location,d.date) as RollingPeopleVaccinated
From Covid_Project..CovidDeaths$ d
Join covid_project..CovidVaccinations$ v
on d.location=v.location
and d.date =v.date
where d.continent is not null
order by 2,3

--CTE

With PopvsVac (continent,location,date,population,new_vaccinations,RollingPeopleVaccinated)
as 
(Select d.continent,d.location,d.date,d.population,v.new_vaccinations,Sum(convert(bigint,v.new_vaccinations)) OVER (Partition by d.location Order by d.location,d.date) as RollingPeopleVaccinated
From Covid_Project..CovidDeaths$ d
Join covid_project..CovidVaccinations$ v
on d.location=v.location
and d.date =v.date
where d.continent is not null
--order by 2,3
)
Select *,(RollingPeopleVaccinated/population)*100
From PopvsVac

--Temp Table
Drop Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
date datetime,
Population numeric,
New_Vaccinations numeric,
RollingPeopleVaccinated numeric
)
Insert Into #PercentPopulationVaccinated
Select d.continent,d.location,d.date,d.population,v.new_vaccinations,Sum(convert(bigint,v.new_vaccinations)) OVER (Partition by d.location Order by d.location,d.date) as RollingPeopleVaccinated
From Covid_Project..CovidDeaths$ d
Join covid_project..CovidVaccinations$ v
on d.location=v.location
and d.date =v.date
where d.continent is not null
--order by 2,3

Select * From #PercentPopulationVaccinated

--create view for later
Create View PercentPopulationVaccinated As 
Select d.continent,d.location,d.date,d.population,v.new_vaccinations,Sum(convert(bigint,v.new_vaccinations)) OVER (Partition by d.location Order by d.location,d.date) as RollingPeopleVaccinated
From Covid_Project..CovidDeaths$ d
Join covid_project..CovidVaccinations$ v
on d.location=v.location
and d.date =v.date
where d.continent is not null
--order by 2,3


Select * From PercentPopulationVaccinated