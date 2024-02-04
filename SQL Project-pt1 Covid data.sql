-- Explore Covid Death Data

-- Display basic information about the Covid Death data table
SELECT TOP 5 *
FROM covid_death

-- Check for missing values in key columns
SELECT
    COUNT(*) AS TotalRows,
    COUNT(location) AS NonNullLocations,
    COUNT(total_cases) AS NonNullTotalCases,
    COUNT(total_deaths) AS NonNullTotalDeaths
FROM covid_death


-- Display summary statistics for numerical columns in Covid Death data
SELECT
    MIN(CAST(total_cases AS float)) AS MinTotalCases,
    MAX(CAST(total_cases AS float)) AS MaxTotalCases,
    AVG(CAST(total_cases AS float)) AS AvgTotalCases,
    MIN(CAST(total_deaths AS float)) AS MinTotalDeaths,
    MAX(CAST(total_deaths AS float)) AS MaxTotalDeaths,
    AVG(CAST(total_deaths AS float)) AS AvgTotalDeaths
FROM covid_death


-- Check for missing values in all columns
SELECT
    'covid_death' AS TableName,
    COLUMN_NAME,
    COUNT(*) AS MissingValues
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'covid_death' AND TABLE_SCHEMA = 'dbo'
    AND COLUMN_NAME NOT IN ('iso_code', 'continent', 'location', 'date')
    AND EXISTS (
        SELECT 1
        FROM covid_death
        WHERE COLUMN_NAME = COLUMN_NAME AND COLUMN_NAME IS NULL
    )
GROUP BY COLUMN_NAME
ORDER BY MissingValues DESC

-- Explore Covid Vaccination Data

-- Display basic information about the Covid Vaccination data table
SELECT TOP 5 *
FROM covid_vaccination

-- Check for missing values in key columns
SELECT
    COUNT(*) AS TotalRows,
    COUNT(location) AS NonNullLocations,
    COUNT(total_vaccinations) AS NonNullTotalVaccinations,
    COUNT(people_vaccinated) AS NonNullPeopleVaccinated
FROM covid_vaccination

--- Display summary statistics for numerical columns in Covid Vaccination data
SELECT
    MIN(CAST(total_vaccinations AS float)) AS MinTotalVaccinations,
    MAX(CAST(total_vaccinations AS float)) AS MaxTotalVaccinations,
    AVG(CAST(total_vaccinations AS float)) AS AvgTotalVaccinations,
    MIN(CAST(people_vaccinated AS float)) AS MinPeopleVaccinated,
    MAX(CAST(people_vaccinated AS float)) AS MaxPeopleVaccinated,
    AVG(CAST(people_vaccinated AS float)) AS AvgPeopleVaccinated
FROM covid_vaccination

-- Check for missing values in all columns
SELECT
    'covid_vaccination' AS TableName,
    COLUMN_NAME,
    COUNT(*) AS MissingValues
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'covid_vaccination' AND TABLE_SCHEMA = 'dbo'
    AND COLUMN_NAME NOT IN ('iso_code', 'continent', 'location', 'date')
    AND EXISTS (
        SELECT 1
        FROM covid_vaccination
        WHERE COLUMN_NAME = COLUMN_NAME AND COLUMN_NAME IS NULL
    )
GROUP BY COLUMN_NAME
ORDER BY MissingValues DESC

-- Commonly Used Data Analysis Queries

-- Example: Top 10 locations with the highest total deaths
SELECT TOP 10
    location,
    MAX(total_deaths) AS TotalDeaths
FROM covid_death
GROUP BY location
ORDER BY TotalDeaths DESC

-- Example: Total cases and total deaths by continent
SELECT
    continent,
    SUM(CAST(total_cases AS float)) AS TotalCases,
    SUM(CAST(total_deaths AS float)) AS TotalDeaths
FROM covid_death
GROUP BY continent

-- Explore Covid Death Data

-- Example: Identify locations with the highest total cases and their details
SELECT
    location,
    MAX(total_cases) AS HighestTotalCases,
    MAX(date) AS DateOfHighestCases
FROM covid_death
GROUP BY location
ORDER BY HighestTotalCases DESC

--- Example: Monthly total deaths trend
SELECT
    FORMAT(date, 'yyyy-MM') AS Month,
    SUM(CAST(total_deaths AS float)) AS TotalDeaths
FROM covid_death
GROUP BY FORMAT(date, 'yyyy-MM')
ORDER BY Month

-- Example: Identify locations with the highest death percentage
SELECT
    location,
    MAX(CAST(total_deaths AS float)/CAST(total_cases AS float))*100 AS HighestDeathPercentage
FROM covid_death
GROUP BY location
ORDER BY HighestDeathPercentage DESC


-- Explore Covid Vaccination Data

-- Example: Identify locations with the highest total vaccinations
SELECT
    location,
    MAX(total_vaccinations) AS HighestTotalVaccinations
FROM covid_vaccination
GROUP BY location
ORDER BY HighestTotalVaccinations DESC

-- Example: Weekly new vaccinations trend
SELECT
    DATEPART(WEEK, date) AS WeekNumber,
    SUM(CAST(new_vaccinations AS float)) AS WeeklyNewVaccinations
FROM covid_vaccination
GROUP BY DATEPART(WEEK, date)
ORDER BY WeekNumber;


-- Example: Identify locations with the highest percentage of people fully vaccinated
SELECT
    location,
    MAX(people_fully_vaccinated_per_hundred) AS HighestPercentageFullyVaccinated
FROM covid_vaccination
GROUP BY location
ORDER BY HighestPercentageFullyVaccinated DESC

-- Common Data Analysis Queries

-- Example: Identify locations with the highest weekly average new cases
SELECT
    location,
    AVG(new_cases) AS WeeklyAverageNewCases
FROM covid_death
WHERE date >= DATEADD(WEEK, -1, GETDATE())
GROUP BY location
ORDER BY WeeklyAverageNewCases DESC

-- Example: Find outliers in total deaths using z-score
-- Example: Find outliers in total deaths using z-score

-- Common Table Expression (CTE) to calculate the Z-score for total_deaths
WITH DeathZScore AS (
    -- Selecting necessary columns and casting total_deaths to float for numeric operations
    SELECT
        location,
        date,
        CAST(total_deaths AS float) AS total_deaths,
        -- Calculating Z-score using the formula: (X - AVG(X)) / STDEV(X)
        (CAST(total_deaths AS float) - AVG(CAST(total_deaths AS float)) OVER ()) / STDEV(CAST(total_deaths AS float)) OVER () AS ZScore
    FROM covid_death
)

-- Selecting outliers based on Z-score threshold
SELECT
    location,
    date,
    total_deaths
FROM DeathZScore
-- Filtering for Z-scores greater than 3 or less than -3 (common threshold for outliers)
WHERE ZScore > 3 OR ZScore < -3
-- Ordering the result by location and date
ORDER BY location, date;





-- Start From Here Alex the data 



/*
Covid 19 Data Exploration 

Skills used: Joins, CTE's, Temp Tables, Windows Functions, Aggregate Functions, Creating Views, Converting Data Types
*/

-- Selecting all data from the CovidDeaths table where continent is not null and ordering by columns 3 and 4
Select *
From covid_death
Where continent is not null 
order by 3,4

-- Selecting specific columns from the CovidDeaths table where continent is not null and ordering by columns 1 and 2
Select Location, date, total_cases, new_cases, total_deaths, population
From covid_death
Where continent is not null 
order by 1,2

-- Calculating death percentage based on total cases and total deaths for locations containing 'states'
SELECT
    Location,
    date,
    total_cases,
    total_deaths,
    (CAST(total_deaths AS float) / CAST(total_cases AS float)) * 100 as DeathPercentage
FROM covid_death
WHERE location like '%states%'
    AND continent is not null 
ORDER BY 1, 2;


-- Calculating percentage of population infected with Covid based on total cases and population
Select Location, date, Population, total_cases,  (total_cases/population)*100 as PercentPopulationInfected
From covid_death
--Where location like '%states%'
order by 1,2

-- Finding countries with the highest infection rate compared to population
Select Location, Population, MAX(total_cases) as HighestInfectionCount,  Max((total_cases/population))*100 as PercentPopulationInfected
From covid_death
--Where location like '%states%'
Group by Location, Population
order by PercentPopulationInfected desc

-- Finding countries with the highest death count per population
Select Location, MAX(cast(Total_deaths as int)) as TotalDeathCount
From covid_death
--Where location like '%states%'
Where continent is not null 
Group by Location
order by TotalDeathCount desc

-- Breaking things down by continent and showing continents with the highest death count per population
Select continent, MAX(cast(Total_deaths as int)) as TotalDeathCount
From covid_death
--Where location like '%states%'
Where continent is not null 
Group by continent
order by TotalDeathCount desc

-- Global numbers - Summing up new cases, total deaths, and calculating death percentage
Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
From covid_death
--Where location like '%states%'
where continent is not null 
--Group By date
order by 1,2

-- Total Population vs Vaccinations - Calculating the percentage of population that received at least one Covid vaccine
-- Calculating death percentage based on total cases and total deaths for locations containing 'states'
SELECT
    Location,
    date,
    total_cases,
    total_deaths,
    (CAST(total_deaths AS bigint) / CAST(total_cases AS bigint)) * 100 as DeathPercentage
FROM covid_death
WHERE location like '%states%'
    AND continent is not null 
ORDER BY 1, 2;


-- Using CTE to perform calculation on Partition By in the previous query
WITH PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
AS (
    SELECT
        dea.continent,
        dea.location,
        dea.date,
        dea.population,
        vac.new_vaccinations,
        SUM(CONVERT(bigint, vac.new_vaccinations)) OVER (PARTITION BY dea.Location ORDER BY dea.location, dea.Date) AS RollingPeopleVaccinated
    FROM
        covid_death dea
    JOIN
        covid_Vaccination vac ON dea.location = vac.location AND dea.date = vac.date
    WHERE
        dea.continent IS NOT NULL 
)
SELECT
    *,
    (RollingPeopleVaccinated / Population) * 100
FROM
    PopvsVac;


-- Using Temp Table to perform calculation on Partition By in the previous query
DROP TABLE IF EXISTS #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
    Continent NVARCHAR(255),
    Location NVARCHAR(255),
    Date DATETIME,
    Population NUMERIC,
    New_vaccinations NUMERIC,
    RollingPeopleVaccinated BIGINT  -- Change to BIGINT to avoid arithmetic overflow
)

INSERT INTO #PercentPopulationVaccinated
SELECT
    dea.continent,
    dea.location,
    dea.date,
    dea.population,
    vac.new_vaccinations,
    SUM(CONVERT(BIGINT, vac.new_vaccinations)) OVER (PARTITION BY dea.Location ORDER BY dea.location, dea.Date) AS RollingPeopleVaccinated
FROM
    covid_death dea
JOIN
    covid_Vaccination vac ON dea.location = vac.location AND dea.date = vac.date
-- WHERE dea.continent IS NOT NULL 
-- ORDER BY 2,3

-- Displaying the calculated values from Temp Table
SELECT
    *,
    (RollingPeopleVaccinated / Population) * 100 AS PercentPopulationVaccinated
FROM
    #PercentPopulationVaccinated;

-- Creating a view to store data for later visualizations
-- Creating a view to store data for later visualizations   -- getting issue 
CREATE VIEW PercentPopulationVaccinated AS
SELECT
    dea.continent,
    dea.location,
    dea.date,
    dea.population,
    vac.new_vaccinations,
    SUM(CONVERT(DECIMAL(18, 0), vac.new_vaccinations)) OVER (PARTITION BY dea.Location ORDER BY dea.location, dea.Date) AS RollingPeopleVaccinated,
    -- Calculate the percentage of population vaccinated
    (CONVERT(DECIMAL(18, 4), SUM(CONVERT(DECIMAL(18, 0), vac.new_vaccinations)) OVER (PARTITION BY dea.Location ORDER BY dea.location, dea.Date)) / NULLIF(dea.population, 0)) * 100 AS PercentPopulationVaccinated
FROM
    covid_death dea
JOIN
    covid_Vaccination vac ON dea.location = vac.location AND dea.date = vac.date
WHERE
    dea.continent IS NOT NULL;  -- fixed it in below query 


	-- Altering the existing view to fix the column name issue
ALTER VIEW PercentPopulationVaccinated AS
SELECT
    dea.continent,
    dea.location,
    dea.date,
    dea.population,
    vac.new_vaccinations,
    SUM(CONVERT(DECIMAL(18, 0), vac.new_vaccinations)) OVER (PARTITION BY dea.Location ORDER BY dea.location, dea.Date) AS RollingPeopleVaccinated,
    -- Calculate the percentage of population vaccinated
    (CONVERT(DECIMAL(18, 4), SUM(CONVERT(DECIMAL(18, 0), vac.new_vaccinations)) OVER (PARTITION BY dea.Location ORDER BY dea.location, dea.Date)) / NULLIF(dea.population, 0)) * 100 AS PercentPopulationVaccinated
FROM
    covid_death dea
JOIN
    covid_Vaccination vac ON dea.location = vac.location AND dea.date = vac.date
WHERE
    dea.continent IS NOT NULL;



	Select * from PercentPopulationVaccinated

