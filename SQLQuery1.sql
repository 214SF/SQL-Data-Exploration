-- verifing two datasets are upload correctly
select * from covidVaccination$
select * from covidDeaths$
where continent is not null

-- using cast to convert nvarchar values to float
-- this shows the chance of dying
select location, Date, total_cases, total_deaths, (cast(total_deaths as float)/cast(total_cases as float))*100 as Death_percentage
from covidDeaths$ where continent is not null
where location like '%india%' 

-- Looking total case vs population 
select location, Date, total_cases, population, (cast(total_deaths as float)/cast(population as float))*100 as population_percentage
from covidDeaths$ where continent is not null
where location like '%india%' 

--highest infection 
select location, population, max(total_cases) as highestcase,  max((cast(total_cases as float)/cast(population as float))*100) as populationinfected_percentage
from covidDeaths$ where continent is not null
Group by location, population
order by populationinfected_percentage desc

-- highest death count 
select location, max(cast(total_deaths as int)) as highestdeaths
from covidDeaths$ where continent is not null
Group by location 
order by highestdeaths desc

-- highest death count by continent 
select location, max(cast(total_deaths as int)) as highestdeaths
from covidDeaths$ where continent is null
Group by location 
order by highestdeaths desc

--global number 
SELECT location, population, MAX(Date) as Date,MAX(total_cases) as Total_case,  
    MAX(
        CASE 
            WHEN CAST(population AS float) = 0 THEN 0  -- handle divide by zero
            ELSE (CAST(total_deaths AS float) / CAST(population AS float)) * 100
        END
    ) as populationinfected_percentage
FROM covidDeaths$
GROUP BY location, population;

--join the table 
select * from covidDeaths$ join covidVaccination$ 
	on covidDeaths$.location = covidVaccination$.location
	and covidDeaths$.date = covidVaccination$.date


--total population vs vaccinations
select covidDeaths$.continent, covidDeaths$.population, covidDeaths$.location, covidDeaths$.date, Sum(cast(covidVaccination$.new_vaccinations as float)) 
over (partition by covidDeaths$.location) as count_
from covidDeaths$ join covidVaccination$ 
	on covidDeaths$.location = covidVaccination$.location
	and covidDeaths$.date = covidVaccination$.date
	where covidDeaths$.continent is not null --and  covidDeaths$.location like '%india%'
order by 2,3
	
-- Use CTE(Common Table Expression)
with popvsvac (continent, population, location, date,count_) 
as
(
select covidDeaths$.continent, covidDeaths$.population, covidDeaths$.location, covidDeaths$.date,
Sum(cast(covidVaccination$.new_vaccinations as float)) 
over (partition by covidDeaths$.location) as count_ 
from covidDeaths$ join covidVaccination$ 
	on covidDeaths$.location = covidVaccination$.location
	and covidDeaths$.date = covidVaccination$.date
	where covidDeaths$.continent is not null --and  covidDeaths$.location like '%india%'
)
SELECT * 
FROM popvsvac
ORDER BY population, location;

--Temp Table
create table percentagepopulationvaccinated(
continent nvarchar(255),
population numeric,
location nvarchar(255),
date datetime,
count_ numeric
)

insert into percentagepopulationvaccinated
select covidDeaths$.continent, covidDeaths$.population, covidDeaths$.location, covidDeaths$.date,
Sum(cast(covidVaccination$.new_vaccinations as float)) 
over (partition by covidDeaths$.location) as count_ 
from covidDeaths$ join covidVaccination$ 
	on covidDeaths$.location = covidVaccination$.location
	and covidDeaths$.date = covidVaccination$.date
	where covidDeaths$.continent is not null --and  covidDeaths$.location like '%india%'

SELECT * 
FROM percentagepopulationvaccinated



-- Views 
create view first_view as 
select covidDeaths$.continent, covidDeaths$.population, covidDeaths$.location, covidDeaths$.date, Sum(cast(covidVaccination$.new_vaccinations as float)) 
over (partition by covidDeaths$.location) as count_
from covidDeaths$ join covidVaccination$ 
	on covidDeaths$.location = covidVaccination$.location
	and covidDeaths$.date = covidVaccination$.date
	where covidDeaths$.continent is not null --and  covidDeaths$.location like '%india%'


