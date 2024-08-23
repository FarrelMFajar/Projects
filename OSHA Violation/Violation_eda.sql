--1. Initial check
USE osha;
SELECT * FROM incidents;

--2a1. Check for duplicate Event ID
SELECT [Event ID],COUNT([Event ID]) FROM incidents GROUP BY [Event ID] having COUNT([Event ID])>1 order by COUNT([Event ID]) desc

--2a2. Verify the kind of duplicates
SELECT * FROM incidents WHERE "Event ID" in (
SELECT [Event ID] FROM incidents GROUP BY [Event ID] having COUNT("Event ID")>1)
--2b. Search for any improper usage of question mark ("'" becomes ?)
SELECT [Event ID],[Event Description] FROM incidents WHERE [Event Description] like '%?%';

--It's found that the abstract text was split and there's a number of improper use of "?" mark. 

-- All column names except the old Abstract Text are copied FROM the query below. Because there's no known easy way to perform it in Microsoft SQL server Management Studio (not that I know), the query is made. 
WITH cte AS(
	SELECT 
		concat('[',COLUMN_NAME,']') as COLUMN_NAME
	FROM 
		INFORMATION_SCHEMA.COLUMNS
	WHERE 
		TABLE_NAME = 'incidents'
)
SELECT     STRING_AGG(COLUMN_NAME, ',')
FROM cte

--2c. Correcting the Abstract Text and make a new table out of it
SELECT
	[Event Date],    
	STRING_AGG([Abstract Text], ' ') AS [Abstract Text],
	replace([Event Description],'?','''') as [Event Description],
	[Event ID],
	[Event Keywords],
	[Degree of Injury],
	[con_end],
	[Construction End Use],
	[build_stor],
	[Building Stories],
	[proj_cost],
	[Project Cost],
	[proj_type],
	[Project Type],
	[nature_of_inj],
	[Nature of Injury],
	[part_of_body],
	[Part of Body],
	[event_type],
	[Event type],
	[evn_factor],
	[Environmental Factor],
	[hum_factor],
	[Human Factor],
	[task_assigned],
	[Task Assigned],
	[hazsub],
	[fat_cause],
	[fall_ht]
 into clean_incidents
FROM
    incidents  
GROUP BY 
[Event Date],[Event Description],[Event ID],[Event Keywords],[Degree of Injury],[con_end],[Construction End Use],[build_stor],[Building Stories],[proj_cost],[Project Cost],[proj_type],[Project Type],[nature_of_inj],[Nature of Injury],[part_of_body],[Part of Body],[event_type],[Event type],[evn_factor],[Environmental Factor],[hum_factor],[Human Factor],[task_assigned],[Task Assigned],[hazsub],[fat_cause],[fall_ht];

SELECT * FROM clean_incidents 

--3. Make Event ID as Primary Key
ALTER TABLE clean_incidents 
	ALTER COLUMN 
		[Event ID] int NOT NULL;

ALTER TABLE clean_incidents
	ADD CONSTRAINT PK_OSHAINCIDENT_EventID PRIMARY KEY CLUSTERED ([Event ID]);

--4. Create a table that shows the total occurrence of keywords

SELECT
	value AS [Event Keyword], 
	COUNT(value) AS [Occurrence] 
FROM 
	clean_incidents CROSS APPLY string_split("Event Keywords",',') 
WHERE 
	value <>'' 
GROUP BY 
	value 
ORDER BY 
	COUNT(value) desc;

--4a. Total Occurrence of keyword, grouped by Fatal/Nonfatal

SELECT 
    SUM(CASE WHEN [Degree of Injury] = 'Fatal' THEN 1 ELSE 0 END) AS [Total Occurrence in Fatal],
    SUM(CASE WHEN [Degree of Injury] = 'Nonfatal' THEN 1 ELSE 0 END) AS [Total Occurrence in Nonfatal],
    COUNT(*) AS [Total Occurrence]
FROM 
    clean_incidents
CROSS APPLY 
    string_split([Event Keywords], ',') 
WHERE 
    value <> '';

	
--4b. Occurrence of each keyword grouped by Fatal/Nonfatal


WITH cte_degree AS
(
	SELECT 
		[Degree of Injury], 
		value AS [Event Keyword], 
		COUNT(value) as [Occurrence] 
	FROM 
		clean_incidents CROSS APPLY string_split("Event Keywords",',') 
	WHERE 
		value <>'' 
	GROUP BY 
		[Degree of Injury], 
		value

) 
SELECT 
    [Event Keyword],
    SUM(CASE WHEN [Degree of Injury] = 'Fatal' THEN [Occurrence] ELSE 0 END) AS Fatal,
	SUM(CASE WHEN [Degree of Injury] = 'Nonfatal' THEN [Occurrence] ELSE 0 END) AS Nonfatal,
    SUM(occurrence) AS Total,
    FORMAT(SUM(CASE WHEN [Degree of Injury] = 'Fatal' THEN [Occurrence] ELSE 0 END) * 1.00/ 
    (SELECT
		SUM([Occurrence]) FROM cte_degree WHERE [Degree of Injury] = 'Fatal'),'P') AS [% Fatal of total occurrence in Fatal],
    FORMAT(SUM(CASE WHEN [Degree of Injury] = 'Nonfatal' THEN [Occurrence] ELSE 0 END) * 1.00/ 
     (SELECT 
		SUM([Occurrence]) FROM cte_degree WHERE [Degree of Injury] = 'Nonfatal'),'P') AS [% Nonfatal of total occurence in Nonfatal],
    FORMAT(SUM(CASE WHEN [Degree of Injury] = 'Fatal' THEN [Occurrence] ELSE 0 END) * 1.00/ 
    (SELECT
		SUM([Occurrence]) FROM cte_degree),'P') AS [% Fatal Occurence of combined occurrence],
    FORMAT(SUM(CASE WHEN [Degree of Injury] = 'Nonfatal' THEN [Occurrence] ELSE 0 END) * 1.00/ 
    (SELECT
		SUM([Occurrence]) FROM cte_degree),'P') AS [% Nonatal Occurence of combined occurrence],
    FORMAT(SUM(occurrence) * 1.00 / 
     (SELECT SUM([Occurrence]) FROM cte_degree),'P') AS Percentage
FROM 
    cte_degree
GROUP BY 
    [Event Keyword]
ORDER BY 
    Percentage desc;

--5. Check part of body and nature of injury

SELECT DISTINCT [part_of_body], [Part of Body]
FROM clean_incidents
Order by [Part_of_Body] ASC;

-- 5a. Check Nature of Injury
SELECT 
	DISTINCT [Nature of Injury]
FROM clean_incidents;
-- It is known that there are 20 natures of injury
-- 5b. Check the data with N/A nature of injury
SELECT * FROM clean_incidents WHERE [Nature of Injury] = '#N/A'
-- 5c. From event keywords, check data with similar keywords (EXPOSURE) to see the nature of injury
SELECT * FROM clean_incidents WHERE [Event Keywords] LIKE '%EXPOSURE%'

-- 5d. Nature of injury, ranked by frequency
SELECT [Nature of Injury], COUNT(*) AS Frequency
FROM incidents
GROUP BY [Nature of Injury]
ORDER BY Frequency DESC;

-- 5e. Nature of Injury, ranked by frequency and percentage of total
WITH injury_counts AS (
    SELECT 
        [Nature of Injury], 
        COUNT(*) AS Frequency
    FROM incidents
    GROUP BY [Nature of Injury]
)
SELECT 
    [Nature of Injury],
    Frequency,
    FORMAT(Frequency * 1.0 / SUM(Frequency) OVER (), 'P') AS Percentage
FROM injury_counts
ORDER BY Frequency DESC;

-- 5f. Nature of injury, grouped by fatal and nonfatal incidents
SELECT 
    [Nature of Injury],
    SUM(CASE WHEN [Degree of Injury] = 'Fatal' THEN 1 ELSE 0 END) AS Fatal,
    SUM(CASE WHEN [Degree of Injury] = 'Nonfatal' THEN 1 ELSE 0 END) AS Nonfatal,
    COUNT(*) AS Total
FROM incidents
GROUP BY [Nature of Injury]
ORDER BY Total DESC, [Nature of Injury];

-- 5g. Incident occurrence, grouped by nature of injury and part of body
SELECT 
    [Nature of Injury],
    [Part of Body],
    COUNT(*) AS Frequency
FROM incidents
GROUP BY [Nature of Injury], [Part of Body]
ORDER BY [Nature of Injury], Frequency DESC;

-- 5h. Check incidents with specific part of body ID
select * from clean_incidents where part_of_body = 6 or part_of_body = 25 or part_of_body = 30

--6. Monthly occurrence of OSHA violations, grouped by degree of injury (fatal/non-fatal)
SELECT 
    YEAR([Event Date]) AS [Year], 
    DATENAME(MONTH, [Event Date]) AS [Month],
    SUM(CASE WHEN [Degree of Injury] = 'Fatal' THEN 1 ELSE 0 END) AS [Fatal Occurrence],
    SUM(CASE WHEN [Degree of Injury] = 'Nonfatal' THEN 1 ELSE 0 END) AS [Nonfatal Occurrence],
    COUNT(*) AS [Total Occurrence]
FROM incidents
GROUP BY 
    YEAR([Event Date]), 
    DATENAME(MONTH, [Event Date]), 
    MONTH([Event Date])
ORDER BY 
    [Year], 
    MONTH([Event Date]);

--Which types of incidents are most common across all worksites?
WITH Monthly_Incidents AS (
    SELECT 
        YEAR([Event Date]) AS [Year], 
        DATENAME(MONTH, [Event Date]) AS [Month],
        MONTH([Event Date]) AS [Month_Number], -- Extract the numeric month for ordering
        COUNT(*) AS [Total Incidents]
    FROM 
        incidents
    GROUP BY 
        YEAR([Event Date]), 
        DATENAME(MONTH, [Event Date]), 
        MONTH([Event Date])
),
Monthly_Trend AS (
    SELECT 
        [Year], 
        [Month],
        [Month_Number],
        [Total Incidents],
        [Total Incidents] - LAG([Total Incidents], 1) OVER (ORDER BY [Year], [Month_Number]) AS [Change from Previous Month],
        CASE 
            WHEN [Total Incidents] - LAG([Total Incidents], 1) OVER (ORDER BY [Year], [Month_Number]) > 0 THEN 'Increase'
            WHEN [Total Incidents] - LAG([Total Incidents], 1) OVER (ORDER BY [Year], [Month_Number]) < 0 THEN 'Decrease'
            ELSE 'No Change'
        END AS [Trend],
        ROUND(
            (CAST([Total Incidents] AS FLOAT) - LAG(CAST([Total Incidents] AS FLOAT), 1) OVER (ORDER BY [Year], [Month_Number])) * 100.0 / 
            LAG(CAST([Total Incidents] AS FLOAT), 1) OVER (ORDER BY [Year], [Month_Number]), 2
        ) AS [Percentage Change]
    FROM 
        Monthly_Incidents
)
SELECT 
    [Year], 
    [Month], 
    [Total Incidents], 
    [Change from Previous Month], 
    [Percentage Change],
    [Trend]
FROM 
    Monthly_Trend
ORDER BY 
    [Year], 
    [Month_Number];

-- Table version
WITH Monthly_Incidents AS (
    SELECT 
        YEAR([Event Date]) AS [Year], 
        DATENAME(MONTH, [Event Date]) AS [Month_Name],
        MONTH([Event Date]) AS [Month_Number], -- Extract the numeric month for proper ordering
        COUNT(*) AS [Total Incidents]
    FROM 
        incidents
    GROUP BY 
        YEAR([Event Date]), 
        DATENAME(MONTH, [Event Date]), 
        MONTH([Event Date])
)
SELECT 
    [Year],
    ISNULL(MAX(CASE WHEN [Month_Name] = 'January' THEN [Total Incidents] END), 0) AS [January],
    ISNULL(MAX(CASE WHEN [Month_Name] = 'February' THEN [Total Incidents] END), 0) AS [February],
    ISNULL(MAX(CASE WHEN [Month_Name] = 'March' THEN [Total Incidents] END), 0) AS [March],
    ISNULL(MAX(CASE WHEN [Month_Name] = 'April' THEN [Total Incidents] END), 0) AS [April],
    ISNULL(MAX(CASE WHEN [Month_Name] = 'May' THEN [Total Incidents] END), 0) AS [May],
    ISNULL(MAX(CASE WHEN [Month_Name] = 'June' THEN [Total Incidents] END), 0) AS [June],
    ISNULL(MAX(CASE WHEN [Month_Name] = 'July' THEN [Total Incidents] END), 0) AS [July],
    ISNULL(MAX(CASE WHEN [Month_Name] = 'August' THEN [Total Incidents] END), 0) AS [August],
    ISNULL(MAX(CASE WHEN [Month_Name] = 'September' THEN [Total Incidents] END), 0) AS [September],
    ISNULL(MAX(CASE WHEN [Month_Name] = 'October' THEN [Total Incidents] END), 0) AS [October],
    ISNULL(MAX(CASE WHEN [Month_Name] = 'November' THEN [Total Incidents] END), 0) AS [November],
    ISNULL(MAX(CASE WHEN [Month_Name] = 'December' THEN [Total Incidents] END), 0) AS [December]
FROM 
    Monthly_Incidents
GROUP BY 
    [Year]
ORDER BY 
    [Year];

-- See number of incidents based on day of week

WITH Daily_Incidents AS (
    SELECT 
        YEAR([Event Date]) AS [Year], 
        DATENAME(WEEKDAY, [Event Date]) AS [Day_of_Week],
        COUNT(*) AS [Total Incidents]
    FROM 
        incidents
    GROUP BY 
        YEAR([Event Date]), 
        DATENAME(WEEKDAY, [Event Date])
)
SELECT 
    [Year],
    ISNULL([Sunday], 0) AS [Sunday],
    ISNULL([Monday], 0) AS [Monday],
    ISNULL([Tuesday], 0) AS [Tuesday],
    ISNULL([Wednesday], 0) AS [Wednesday],
    ISNULL([Thursday], 0) AS [Thursday],
    ISNULL([Friday], 0) AS [Friday],
    ISNULL([Saturday], 0) AS [Saturday]
FROM 
    Daily_Incidents
PIVOT (
    SUM([Total Incidents])
    FOR [Day_of_Week] IN ([Sunday], [Monday], [Tuesday], [Wednesday], [Thursday], [Friday], [Saturday])
) AS PivotTable
ORDER BY 
    [Year];

SELECT DISTINCT 
    YEAR([Event Date]) AS [Year], 
    MONTH([Event Date]) AS [Month]
FROM 
    clean_incidents
ORDER BY 
    [Year], [Month];

-- Fatal percentage
SELECT 
    [Nature of Injury],
    SUM(CASE WHEN [Degree of Injury] = 'Fatal' THEN 1 ELSE 0 END) AS [Fatal Incidents],
    COUNT(*) AS [Total Incidents],
    FORMAT(SUM(CASE WHEN [Degree of Injury] = 'Fatal' THEN 1 ELSE 0 END) * 1.0 / COUNT(*), 'P') AS [% of Incidents that are Fatal]
FROM 
    clean_incidents
GROUP BY 
    [Nature of Injury]
ORDER BY 
    [% of Incidents that are Fatal] DESC;	

-- What proportion leads to severe injury
CREATE FUNCTION dbo.GCD (@a INT, @b INT)
RETURNS INT
AS
BEGIN
    WHILE @b <> 0
    BEGIN
        DECLARE @temp INT = @b;
        SET @b = @a % @b;
        SET @a = @temp;
    END
    RETURN @a;
END

SELECT 
    [Nature of Injury],
    SUM(CASE WHEN [Degree of Injury] = 'Fatal' THEN 1 ELSE 0 END) AS [Fatal Incidents],
    SUM(CASE WHEN [Degree of Injury] = 'Nonfatal' THEN 1 ELSE 0 END) AS [Nonfatal Incidents],
    CASE 
        WHEN SUM(CASE WHEN [Degree of Injury] = 'Nonfatal' THEN 1 ELSE 0 END) = 0 THEN 'N/A'
        ELSE 
            CAST(SUM(CASE WHEN [Degree of Injury] = 'Fatal' THEN 1 ELSE 0 END) / dbo.GCD(SUM(CASE WHEN [Degree of Injury] = 'Fatal' THEN 1 ELSE 0 END), SUM(CASE WHEN [Degree of Injury] = 'Nonfatal' THEN 1 ELSE 0 END)) AS VARCHAR) 
            + ' : ' + 
            CAST(SUM(CASE WHEN [Degree of Injury] = 'Nonfatal' THEN 1 ELSE 0 END) / dbo.GCD(SUM(CASE WHEN [Degree of Injury] = 'Fatal' THEN 1 ELSE 0 END), SUM(CASE WHEN [Degree of Injury] = 'Nonfatal' THEN 1 ELSE 0 END)) AS VARCHAR)
    END AS [Fatal to Nonfatal Ratio]
FROM 
    clean_incidents
GROUP BY 
    [Nature of Injury]
ORDER BY 
    [Fatal to Nonfatal Ratio] DESC;

	-- Body parts most commonly injured
SELECT 
	'Total' AS [Total Incidents],
    COUNT(*) AS [Total Incidents]
FROM 
    clean_incidents
SELECT 
    [Part of Body],
    COUNT(*) AS [Total Incidents]
FROM 
    clean_incidents
GROUP BY 
    [Part of Body]
ORDER BY 
    [Total Incidents] DESC;

-- Specific tasks associated with injuries to particular body parts
SELECT 
    [Task Assigned],
    [Part of Body],
    COUNT(*) AS [Total Incidents]
FROM 
    clean_incidents
GROUP BY 
    [Task Assigned], 
    [Part of Body]
ORDER BY 
    [Total Incidents] DESC;

-- In tabular
SELECT
	'Total Cases' as [Part of Body \ Task Routine],
    SUM(CASE WHEN [Task Assigned] = 'Regularly Assigned' THEN 1 ELSE 0 END) AS [Regularly Assigned],
    SUM(CASE WHEN [Task Assigned] = 'Not Regularly Assigned' THEN 1 ELSE 0 END) AS [Not Regularly Assigned]
FROM
	clean_incidents;


WITH Task_Body_Incidents AS (
    SELECT 
        [Part of Body],
        [Task Assigned],
        COUNT(*) AS [Total Incidents]
    FROM 
        clean_incidents
    GROUP BY 
        [Part of Body],
        [Task Assigned]
)
SELECT 
    [Part of Body] AS [Part of Body \ Task Routine],
    ISNULL([Regularly Assigned], 0) AS [Regularly Assigned],
    ISNULL([Not Regularly Assigned], 0) AS [Not Regularly Assigned],
	ISNULL([Regularly Assigned], 0)+ISNULL([Not Regularly Assigned],0) AS [Total Incidents]
FROM 
    Task_Body_Incidents
PIVOT (
    SUM([Total Incidents])
    FOR [Task Assigned] IN ([Regularly Assigned], [Not Regularly Assigned])
) AS PivotTable
ORDER BY 
     [Total Incidents] DESC,[Part of Body] ASC;


-- Correlation on Type of with the Part of the Body Affected

SELECT 
    [Nature of Injury],
    [Part of Body],
    COUNT(*) AS [Total Incidents]
FROM 
    clean_incidents
GROUP BY 
    [Nature of Injury], 
    [Part of Body]
ORDER BY 
    [Total Incidents] DESC;

	select distinct [Nature of Injury]
from clean_incidents

-- in Tabular
WITH Injury_Body_Incidents AS (
    SELECT 
        [Part of Body] as [Part of Body / Nature of Injury],
        [Nature of Injury],
        COUNT(*) AS [Total Incidents]
    FROM 
        incidents
WHERE [Degree of Injury] = 'NonFatal'
    GROUP BY 
        [Part of Body],
        [Nature of Injury]
)
SELECT 
    [Part of Body / Nature of Injury],
    ISNULL([Amputation, Crushing], 0) AS [Amputation, Crushing],
    ISNULL([Fracture, Broken Bones], 0) AS [Fracture, Broken Bones],
    ISNULL([Serious Fall/Strike], 0) AS [Serious Fall/Strike],
    ISNULL([Laceration], 0) AS [Laceration],
    ISNULL([Chemical Burn], 0) AS [Chemical Burn],
    ISNULL([Fall from Elevation], 0) AS [Fall from Elevation],
    ISNULL([Fall/strike], 0) AS [Fall/strike],
    ISNULL([Dislocation], 0) AS [Dislocation],
    ISNULL([Puncture], 0) AS [Puncture],
    ISNULL([Poison], 0) AS [Poison],
    ISNULL([Heat Exhaustion], 0) AS [Heat Exhaustion],
    ISNULL([Bruising, Contusion], 0) AS [Bruising, Contusion],
    ISNULL([Head Trauma], 0) AS [Head Trauma],
    ISNULL([Illness], 0) AS [Illness],
    ISNULL([Asphyxiation, Drowning], 0) AS [Asphyxiation, Drowning],
    ISNULL([#N/A], 0) AS [#N/A],
    ISNULL([Fire Burn], 0) AS [Fire Burn],
    ISNULL([Eye injury], 0) AS [Eye injury],
    ISNULL([Electrocution], 0) AS [Electrocution],
    ISNULL([Freezer burn], 0) AS [Freezer burn]
FROM 
    Injury_Body_Incidents
PIVOT (
    SUM([Total Incidents])
    FOR [Nature of Injury] IN (
        [Amputation, Crushing], [Fracture, Broken Bones], [Serious Fall/Strike], 
        [Laceration], [Chemical Burn], [Fall from Elevation], [Fall/strike], 
        [Dislocation], [Puncture], [Poison], [Heat Exhaustion], [Bruising, Contusion], 
        [Head Trauma], [Illness], [Asphyxiation, Drowning], [#N/A], [Fire Burn], 
        [Eye injury], [Electrocution], [Freezer burn]
    )
) AS PivotTable
ORDER BY 
    [Part of Body / Nature of Injury];

select distinct [nature of injury] from clean_incidents
