-- Verifying that the tables were imported correctly
Select *
From HealthExp
Order by 4 desc

Select *
From continents

Select * 
From gdp
order by 3 desc

-- Shows the total healthcare expenditure of locations 
Select location, year, health_expenditure_per_capita, population_estimate, 
(health_expenditure_per_capita * population_estimate) as total_health_expenditure
From healthExp
Order by  5 desc

--Shows locations average life expectancy of locations between 2009 and 2019
Select location,AVG(life_expectancy) as Avg_life_expectancy
From healthExp
Where year BETWEEN 2009 AND 2019
Group by location
Order by 2 desc

--Shows the top 10 years with the highest health expenditure per capita in the United States
Select Top 10 location,year, health_expenditure_per_capita
From healthExp
Where location = 'United States'
Order by health_expenditure_per_capita desc

-- Shows what the year that a location had the highest health expenditure per capita was
With highest_expenditure as (
	Select *,
	ROW_NUMBER() OVER(PARTITION BY location ORDER BY health_expenditure_per_capita DESC) AS row_number
From healthExp)
Select location,year,health_expenditure_per_capita
From highest_expenditure
Where row_number = 1
Order by 3 desc


--Excluding locations that are aggregates of others
SELECT *
FROM healthExp
WHERE health_expenditure_per_capita IS NOT NULL
AND life_expectancy IS NOT NULL
AND location NOT IN ('High income','European Union','North America','Europe and Central Asia','Latin America and Caribbean','Middle East and North Africa','East Asia and Pacific','Upper middle income',
'Middle income','Low and middle income','Lower middle income','South Asia','Sub-Saharan Africa','Low income')

--Creating a temp table based on the the previous query
Drop Table If Exists #Temp_healthExp
Create Table #Temp_healthExp(
location nvarchar(255),
year int,
life_expectancy float,
health_expenditure_per_capita float,
population_estimate float
)

Insert Into #Temp_healthExp
SELECT *
FROM healthExp
WHERE health_expenditure_per_capita IS NOT NULL
AND life_expectancy IS NOT NULL
AND location NOT IN ('World','High income','European Union','North America','Europe and Central Asia','Latin America and Caribbean','Middle East and North Africa','East Asia and Pacific','Upper middle income',
'Middle income','Low and middle income','Lower middle income','South Asia','Sub-Saharan Africa','Low income')

Select * 
From #Temp_healthExp

--Uses the temp table to show the years that countries had their lowest health expenditure per capita
With lowest_expenditure as (
	Select *,
	ROW_NUMBER() OVER(PARTITION BY location ORDER BY health_expenditure_per_capita ASC) AS row_number
From #Temp_healthExp)
Select location,year,health_expenditure_per_capita
From lowest_expenditure
Where row_number = 1 
Order by 3 asc

-- Total healthcare spending from  2000 to 2019 for each country
Select location, year, health_expenditure_per_capita
From #Temp_healthExp
Where year Between 2000 and 2019
Order by  3 desc



--Joining on the continents table to display the continent of a location alongside it
Select #Temp_healthExp.location, continents.continent, #Temp_healthExp.year, #Temp_healthExp.health_expenditure_per_capita, #Temp_healthExp.life_expectancy
From #Temp_healthExp
Join continents on #Temp_healthExp.location = continents.entity
Order by 5 desc

--Displays the health expenditure per capita, population estimate and life expectancy of locations in North America
Select healthExp.location, healthExp.year, healthExp.health_expenditure_per_capita, healthExp.population_estimate, healthExp.life_expectancy 
From healthExp
Join continents on healthExp.location = continents.entity
Where continents.continent = 'North America'
Order by 3 desc

--Displays average life expectancy between 2000 and 2019 of each continent 
Select continents.continent, AVG(healthExp.life_expectancy) as average_life_expectancy
From healthExp
Join continents on healthExp.location = continents.entity
Where healthExp.year BETWEEN 2000 AND 2019
Group by continents.continent
Order by 2 desc

--Displays the total health care expenditure of the continents per year
Select continents.continent, healthExp.year, SUM(health_expenditure_per_capita * population_estimate) as total_health_expenditure
From healthExp
Join continents on healthExp.location = continents.entity
Group by continents.continent, healthExp.year
Order by 3 desc

--Percentage of global health expenditure per continent in 2019
With continent_expenditure as (
	Select continents.continent, healthExp.year, SUM(health_expenditure_per_capita * population_estimate) as total_health_expenditure
From healthExp
Join continents on healthExp.location = continents.entity
Group by continents.continent, healthExp.year
)
Select continent,total_health_expenditure, ((total_health_expenditure/(Select SUM(total_health_expenditure) From continent_expenditure Where year = 2019)) * 100) as global_expenditure_percentage
From continent_expenditure
Where year = 2019
Order by 3 desc


--Displays the information at a continent level rather than being broken down by individual locations
Select continents.continent, healthExp.year, (SUM(health_expenditure_per_capita * population_estimate)/SUM(healthExp.population_estimate)) as health_expenditure_per_capita, 
SUM(healthExp.population_estimate) as population_estimate, AVG(healthExp.life_expectancy) as life_expectancy
From healthExp
Join continents on healthExp.location = continents.entity
Group by continents.continent, healthExp.year
Order by 3 desc

-- Shows the GDP of locations alongside health expenditure per capita
Select  healthExp.location , healthExp.year, healthExp.health_expenditure_per_capita, gdp.gdp_per_capita
From healthExp
Join gdp on healthExp.location = gdp.entity and healthExp.year = gdp.year

--Healthcare expenditure per capita as a percentage of the gdp per capita that year
Select  #Temp_healthExp.location , #Temp_healthExp.year, #Temp_healthExp.health_expenditure_per_capita, gdp.gdp_per_capita, ((#Temp_healthExp.health_expenditure_per_capita/gdp.gdp_per_capita)*100) as health_expenditure_as_percent_of_GDP
From #Temp_healthExp
Join gdp on #Temp_healthExp.location = gdp.entity and #Temp_healthExp.year = gdp.year
order by 5 desc











