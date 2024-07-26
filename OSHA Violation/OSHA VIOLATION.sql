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

SELECT [part_of_body], [Part of Body]
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
