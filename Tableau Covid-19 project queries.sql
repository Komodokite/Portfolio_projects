/* Tableau Covid-19 project queries */

-- 1)

Select 
	SUM(new_cases) as total_cases, 
	SUM(new_deaths) as total_deaths, 
	SUM(new_deaths)/SUM(New_Cases)*100 as death_percentage
From public.Covid_deaths
where continent is not null 
order by 1,2

-- 2)
Select 
	Location, 
	Sum(Total_deaths) as total_death_count
From public.covid_deaths
Where continent is null 
AND LOCATION NOT IN ('World', 'European Union', 'International')
GROUP BY LOCATION
order by total_death_count DESC

-- 3)
Select 
	Location, 
	Population, 
	MAX(total_cases) as highest_infection_count, 
	Max((total_cases/population))*100 as percent_population_infected
From public.Covid_deaths
Group by Location, Population
order by percent_population_infected DESC

-- 4)
Select 
	Location, 
	Population, 
	date,
	MAX(total_cases) as highest_infection_count, 
	Max((total_cases/population))*100 as percent_population_infected
From public.Covid_deaths
Group by Location, Population, date
order by percent_population_infected DESC
