/* Covid-19 Data Exploration */
/* Skills used: Joins, CTE's, Temp Tables, Windows Functions, Aggregate Functions, Creating Views, Converting Data Types */

SELECT *
FROM public.Covid_deaths
--WHERE continent IS NOT NULL
ORDER BY 3,4

/* Select Data that we are going to be starting with */
-- Some location data contains continent data so it skews the data. To solve this use WHERE continent IS NOT NULL.
SELECT 
	LOCATION, 
	date, 
	total_cases, 
	new_cases, 
	total_deaths, 
	population
FROM public.Covid_deaths
WHERE continent IS NOT NULL
ORDER BY 1,2

/* Total Cases vs. Total Deaths */
-- Shows the liklihood of dying if you contract covid in your country 
Select 
	Location, 
	date, 
	total_cases,
	total_deaths, 
	(total_deaths/total_cases)*100 as death_percentage
From public.Covid_deaths
Where location like '%States%'
and continent is not null 
order by 1,2

/* Total Cases vs. Population */
-- Shows what percentage of population infected with Covid
Select 
	Location, 
	date, 
	Population, 
	total_cases,  
	(total_cases/population)*100 as percent_population_infected
From public.Covid_deaths
order by 1,2 

/* Countries with Highest Infection Rate compared to Population */
Select 
	Location, 
	Population, 
	MAX(total_cases) as HighestInfectionCount, 
	Max((total_cases/population))*100 as percent_population_infected
From public.Covid_deaths
Group by Location, Population
order by percent_population_infected DESC

/* Countries with Highest Death Count per Population */
Select 
	Location, 
	MAX(Total_deaths) as total_death_count
From public.Covid_deaths
Where continent is not null 
Group by Location
order by total_death_count DESC

-- Breaking things down by continent
-- Showing continents with the highest death count per population
Select 
	continent, 
	MAX(Total_deaths) as total_death_count
From public.Covid_deaths
Where continent is not null 
Group by continent
order by total_death_count DESC

-- Global Numbers
-- Removing GROUP BY date will produce overall total
Select 
	SUM(new_cases) as total_cases, 
	SUM(new_deaths) as total_deaths, 
	SUM(new_deaths)/SUM(New_Cases)*100 as death_percentage
From public.Covid_deaths
where continent is not null 
GROUP BY date
order by 1,2

/* Total Population vs. Vaccinations */
-- Shows percentage of Population that has recieved at least one Covid Vaccination
Select 
	dea.continent, 
	dea.location, 
	dea.date, 
	dea.population, 
	vax.new_vaccinations, 
	SUM(vax.new_vaccinations) OVER (Partition by dea.Location Order by dea.location, dea.Date) as rolling_vaccinations
From public.Covid_deaths dea
Join public.Covid_vax vax
	On dea.location = vax.location
	and dea.date = vax.date
where dea.continent is not null 
order by 2,3

-- Using CTE to perform Calculation on Partition By in previous query
With PopvsVac (Continent, Location, Date, Population, new_vaccinations, rolling_vaccinations)
as
(
Select 
	dea.continent, 
	dea.location, 
	dea.date, 
	dea.population, 
	vax.new_vaccinations, 
	SUM(vax.new_vaccinations) OVER (Partition by dea.Location Order by dea.location, dea.Date) as rolling_vaccinations
From public.Covid_deaths dea
Join public.Covid_vax vax
	On dea.location = vax.location
	and dea.date = vax.date
where dea.continent is not null
)
Select *, (rolling_vaccinations/population)*100
From PopvsVac

-- Using Temp Table to perform Calculation on Partition By in the previous query

DROP Table if exists percent_pop_vax
Create Table percent_pop_vax
(
Continent varchar(255),
Location varchar(255),
Date date,
Population numeric,
New_vaccinations numeric,
rolling_vaccinations numeric
)

Insert into percent_pop_vax
Select 
	dea.continent, 
	dea.location, 
	dea.date, 
	dea.population, 
	vax.new_vaccinations, 
	SUM(vax.new_vaccinations) OVER (Partition by dea.Location Order by dea.location, dea.Date) as rolling_vaccinations
From public.Covid_deaths dea
Join public.Covid_vax vax
	On dea.location = vax.location
	and dea.date = vax.date
where dea.continent is not null

Select *, (rolling_vaccinations/population)*100 AS rolling_vax_for_populations
From percent_pop_vax

-- Creating View to store data for later visualizations

CREATE VIEW PopvsVac AS
Select 
	dea.continent, 
	dea.location, 
	dea.date, 
	dea.population, 
	vax.new_vaccinations, 
	SUM(vax.new_vaccinations) OVER (Partition by dea.Location Order by dea.location, dea.Date) as rolling_vaccinations
From public.Covid_deaths dea
Join public.Covid_vax vax
	On dea.location = vax.location
	and dea.date = vax.date
where dea.continent is not NULL

SELECT *
FROM PopvsVac
