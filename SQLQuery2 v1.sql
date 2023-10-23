
SELECT *
FROM
	portfolioprojects..CovidDeaths
ORDER BY 3,4;

SELECT * 
FROM 
	dbo.CovidVaccinations
ORDER BY 3,4;

/* select the data we are going to analyze */

SELECT
	location, 
	date,
	population,
	new_cases,
	total_cases,
	total_deaths,
	population
FROM
	dbo.CovidDeaths
ORDER BY 1,2;

-- comparing the total cases to the total deaths

SELECT
	location, 
	date,
	population,
	new_cases,
	total_cases,
	total_deaths,
	(total_deaths/total_cases)*100,
	population
FROM
			dbo.CovidDeaths
ORDER BY 1,2;

-- This query retrieves COVID-19 data, including location, date, population, new cases, total cases, total deaths,
-- and the death percentage, from the CovidDeaths table.
-- the percentage of deaths compared to the total case peape contrancted to the virus.

SELECT
    location, 
    date,
    new_cases,
    CAST(total_cases AS INT) AS total_cases, -- Cast total_cases to INT
    CAST(total_deaths AS INT) AS total_deaths, -- Cast total_deaths to INT

    -- To compare the total_cases to the total_deaths, we divide total deaths by the total cases
    (CAST(total_deaths AS FLOAT) / CAST(total_cases AS FLOAT)) * 100 AS death_percentage -- Calculate death percentage
FROM
    dbo.CovidDeaths
WHERE location = 'United States'
ORDER BY 1, 2;

-- comparing the total case to the total population of that contries

SELECT
    location, 
    date,
    new_cases,
	CAST(population AS INT) AS population,
    CAST(total_cases AS INT) AS total_cases, -- Cast total_cases to INT
    -- To compare the total_cases to the population, we divide total cases by the population
    (CAST(total_deaths AS FLOAT) / CAST(total_cases AS FLOAT)) * 100 AS percentage_infacted -- Calculate percentage of peaple infacted 
FROM
    dbo.CovidDeaths
-- checking Canada as an example country
WHERE location = 'Canada'
ORDER BY 1, 2;
--
-- Checking the countries that has the highies infection rate according the thier total population.
SELECT 
	location,
	CAST(population AS FLOAT) AS population,
	MAX(CAST(total_cases AS FLOAT)) AS highiest_cases,
	MAX(CAST(total_cases AS FLOAT)/CAST(population AS FLOAT))*100 AS percentagepopulationinfacted
FROM
	dbo.CovidDeaths
GROUP BY location, CAST(population AS FLOAT)
ORDER BY percentagepopulationinfacted DESC

-- checking the countries with the highiest death counts compare to their total population.
SELECT 
	location,
	CAST(population AS FLOAT) AS population,
	CAST(total_deaths AS FLOAT) AS total_deaths,
	MAX(CAST(total_deaths AS FLOAT)/CAST(population AS FLOAT))*100 AS percentagepopulationdeath
FROM
	dbo.CovidDeaths
GROUP BY 
	location,
	CAST(population AS FLOAT),
	CAST(total_deaths AS FLOAT) 
ORDER BY percentagepopulationdeath DESC

-- countries with the highiest death count 

SELECT
	location,
	MAX(CAST(total_deaths AS FLOAT)) AS highiest_deaths
FROM
	dbo.CovidDeaths
WHERE continent IS NOT NULL -- removing we continent entries is not null 
 GROUP BY
	location, continent
ORDER BY highiest_deaths DESC

-- checking the continents with the highiest death counts
-- Total deaths per continent


SELECT
	location,
	Max(CAST(total_deaths AS INT)) AS total_deaths_Per_continent
FROM
	dbo.CovidDeaths
WHERE continent IS NULL -- filtering out the null values
	AND location in ('Europe','Asia','North America','South America','Africa','Oceania')
GROUP BY 
	location
ORDER BY total_deaths_Per_continent DESC


-- ckecking the date of the highiest cases

SELECT
	date,
	MAX(new_cases) AS highiest_case_dates
FROM
	dbo.CovidDeaths
GROUP BY
	date
ORDER BY
	highiest_case_dates DESC

-- world death percentage of total cases

SELECT
	(MAX(CAST(total_deaths AS FLOAT))/MAX(CAST(total_cases AS FLOAT)))*100  AS globaltotaldeathpercentage
FROM
	dbo.CovidDeaths

-- Global covid19 new cases and new deaths
-- percentage death of new cases and new deaths

SELECT
	date,
	SUM(CAST(new_cases AS FLOAT)) AS Totol_cases,
	SUM(CAST(new_deaths AS FLOAT)) AS total_deaths,
	(SUM(CAST(new_deaths AS FLOAT))/SUM(CAST(new_cases AS FLOAT)))*100 AS Deathpercentage
FROM
	dbo.CovidDeaths
WHERE 
	CAST(new_deaths AS FLOAT) !=0 AND CAST(new_cases AS FLOAT) !=0
GROUP BY date
ORDER BY 1,2

-- Joining the CovidDeaths table to CovidVaccinations table
-- getting an overview of how to join my tables

SELECT TOP 100
	*
FROM
	dbo.CovidDeaths cd
JOIN
	dbo.CovidVaccinations cv
ON
	cd.location=cv.location
AND cd.date = cv.date


-- checking how many peaple vaccinated per continent or location

SELECT 
	cd.continent,
	cd.location,
	cd.date,
	population,
	cv.new_vaccinations
FROM
	dbo.CovidDeaths cd
JOIN
	dbo.CovidVaccinations cv
ON
	cd.location=cv.location
AND cd.date = cv.date
WHERE cd.continent IS NOT NULL
ORDER BY 
	2,3

-- we want to calculate the comulatvie total (rolliing total) of peaple vaccinated in each country
-- This query retrieves data related to COVID-19 vaccinations and cumulative vaccination sums for locations with a specified continent.

-- Select columns from the CovidDeaths (aliased as 'cd') and CovidVaccinations (aliased as 'cv') tables.
SELECT 
    cd.continent,                   -- The continent where the location is situated
    cd.location,                    -- The location (e.g., country)
    cd.date,                        -- The date of the data
    population,                     -- The population of the location
    cv.new_vaccinations,            -- The number of new vaccinations on a given date
    SUM(CONVERT(FLOAT, cv.new_vaccinations)) 
        OVER (PARTITION BY cd.location ORDER BY cd.location, cd.date) AS CummulativeSumOfVaccinations
        -- Calculate the cumulative sum of vaccinations for each location
        -- The SUM(...) OVER (...) clause is used to compute the cumulative sum partitioned by location and ordered by location and date.
FROM
    dbo.CovidDeaths cd
JOIN
    dbo.CovidVaccinations cv
ON
    cd.location = cv.location           -- Join on the 'location' column
    AND cd.date = cv.date               -- Match rows based on the 'date' column
WHERE cd.continent IS NOT NULL         -- Filter to include only rows where 'continent' is not NULL
ORDER BY 
    2,3                                 -- Sort the result set by location and date


-- This query calculates the cumulative percentage of people vaccinated for locations with a specified continent.

-- Select columns from the CovidDeaths (aliased as 'cd') and CovidVaccinations (aliased as 'cv') tables.
SELECT 
    cd.continent,                   -- The continent where the location is situated
    cd.location,                    -- The location (e.g., country)
    cd.date,                        -- The date of the data
    population,                     -- The population of the location
    cv.new_vaccinations,            -- The number of new vaccinations on a given date
    SUM(CONVERT(FLOAT, cv.new_vaccinations)) 
        OVER (PARTITION BY cd.location ORDER BY cd.location, cd.date) AS CummulativeSumOfVaccinations,
        -- Calculate the cumulative sum of vaccinations for each location

    -- Calculate the cumulative percentage of people vaccinated for each location
    (SUM(CONVERT(FLOAT, cv.new_vaccinations)) 
        OVER (PARTITION BY cd.location ORDER BY cd.location, cd.date) / population) * 100 AS CumulativePercentageVaccinated
FROM
    dbo.CovidDeaths cd
JOIN
    dbo.CovidVaccinations cv
ON
    cd.location = cv.location           -- Join on the 'location' column
    AND cd.date = cv.date               -- Match rows based on the 'date' column
WHERE cd.continent IS NOT NULL         -- Filter to include only rows where 'continent' is not NULL
ORDER BY 
    2, 3                                 -- Sort the result set by location and date


-- ANOTHER WAY TO DO THIS IS TO USE (CTE) 
-- CTE stands for "Common Table Expression." 
-- It's a temporary result set that you can reference within a SELECT, INSERT, UPDATE, or DELETE statement in SQL. 
-- CTEs are defined using the WITH keyword and are typically used to simplify complex SQL queries, improve readability, and break down a query into more manageable, modular parts. 
-- They are especially useful for recursive queries, hierarchical data, and situations where you need to use the same subquery multiple times within a larger query.

-- This query calculates the cumulative percentage of people vaccinated for locations with a specified continent using a CTE.

-- Define a CTE that calculates the cumulative sum of vaccinations for each location.
WITH VaccPop (continent, location, date, population, new_vaccinations,CummulativeSumOfVaccinations
	) 
	AS
(
SELECT 
    cd.continent,                   -- The continent where the location is situated
    cd.location,                    -- The location (e.g., country)
    cd.date,                        -- The date of the data
    population,                     -- The population of the location
    cv.new_vaccinations,            -- The number of new vaccinations on a given date
    SUM(CONVERT(FLOAT, cv.new_vaccinations)) 
        OVER (PARTITION BY cd.location ORDER BY cd.location, cd.date) AS CummulativeSumOfVaccinations
        -- Calculate the cumulative sum of vaccinations for each location
        -- The SUM(...) OVER (...) clause is used to compute the cumulative sum partitioned by location and ordered by location and date.
FROM
    dbo.CovidDeaths cd
JOIN
    dbo.CovidVaccinations cv
ON
    cd.location = cv.location           -- Join on the 'location' column
    AND cd.date = cv.date               -- Match rows based on the 'date' column
WHERE cd.continent IS NOT NULL         -- Filter to include only rows where 'continent' is not NULL
)
SELECT *, (CummulativeSumOfVaccinations/population)*100
FROM
	VaccPop
order by location, date


------- TEMP TABLE---------------
--Create a temporary table to store the cumulative sum of vaccinations
CREATE TABLE #commulativepercentagevaccinated
(
	continent nvarchar(255),
	location nvarchar(255),
	date datetime,
	population numeric,
	new_vaccinations numeric,
	CummulativeSumOfVaccinations numeric
)
INSERT INTO #commulativepercentagevaccinated
SELECT 
    cd.continent,                   -- The continent where the location is situated
    cd.location,                    -- The location (e.g., country)
    cd.date,                        -- The date of the data
    population,                     -- The population of the location
    cv.new_vaccinations,            -- The number of new vaccinations on a given date
    SUM(CONVERT(FLOAT, cv.new_vaccinations)) 
        OVER (PARTITION BY cd.location ORDER BY cd.location, cd.date) AS CummulativeSumOfVaccinations
        -- Calculate the cumulative sum of vaccinations for each location
        -- The SUM(...) OVER (...) clause is used to compute the cumulative sum partitioned by location and ordered by location and date.
FROM
    dbo.CovidDeaths cd
JOIN
    dbo.CovidVaccinations cv
ON
    cd.location = cv.location           -- Join on the 'location' column
    AND cd.date = cv.date               -- Match rows based on the 'date' column
WHERE cd.continent IS NOT NULL         -- Filter to include only rows where 'continent' is not NULL
ORDER BY 
    2,3                                 -- Sort the result set by location and date

SELECT *, (CummulativeSumOfVaccinations/population)*100
FROM
	#commulativepercentagevaccinated

-- if you want to modify the table you need to drop the table and re-run it again

DROP TABLE IF EXISTS #commulativepercentagevaccinated


----- CREAING TABLE VIEW ----------------
-- creating view for later data visualization operations.

CREATE VIEW
	commulativepercentagevaccinated
AS
SELECT 
    cd.continent,                   -- The continent where the location is situated
    cd.location,                    -- The location (e.g., country)
    cd.date,                        -- The date of the data
    population,                     -- The population of the location
    cv.new_vaccinations,            -- The number of new vaccinations on a given date
    SUM(CONVERT(FLOAT, cv.new_vaccinations)) 
        OVER (PARTITION BY cd.location ORDER BY cd.location, cd.date) AS CummulativeSumOfVaccinations
        -- Calculate the cumulative sum of vaccinations for each location
        -- The SUM(...) OVER (...) clause is used to compute the cumulative sum partitioned by location and ordered by location and date.
FROM
    dbo.CovidDeaths cd
JOIN
    dbo.CovidVaccinations cv
ON
    cd.location = cv.location           -- Join on the 'location' column
    AND cd.date = cv.date               -- Match rows based on the 'date' column
WHERE cd.continent IS NOT NULL         -- Filter to include only rows where 'continent' is not NULL
--ORDER BY 
--    2,3 


-- let's query our know table view

SELECT *
FROM
	commulativepercentagevaccinated
ORDER BY 2,3

-- To drop a view we can use 

DROP VIEW commulativepercentagevaccinated

