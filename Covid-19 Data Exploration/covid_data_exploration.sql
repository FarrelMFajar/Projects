--0. Checks how the data looks like in table form--
Select top 100 *
from jakarta_covid.dbo.covid;

 --1. Checks the table for the number of abnormal data. Because the column 'tanggal' shares the same string length for normal data, we check for the ones with different length--
select
tanggal, count(tanggal) as 'count'
from Jakarta_covid.dbo.covid
where len(tanggal) <> 10
group by tanggal;

 --2. Data Cleaning: Delete those abnormal data--
DELETE
FROM Jakarta_covid.dbo.covid WHERE len(tanggal) <> 10;

--3a. To increase data compatibility to other programs like Microsoft Excel, we change the column type--
alter table Jakarta_covid.dbo.covid
alter column tanggal date;
alter table Jakarta_covid.dbo.covid
alter column id_kel int;
alter table Jakarta_covid.dbo.covid
alter column jumlah int;

--3b. We change "KAB.ADM.KEP.SERIBU" to "Kepulauan Seribu" to improve geographical accuracy for data visualization
UPDATE Jakarta_covid.dbo.covid
SET nama_kota = REPLACE(nama_kota, 'KAB.ADM.KEP.SERIBU', 'KEPULAUAN SERIBU')
WHERE nama_kota = 'KAB.ADM.KEP.SERIBU';


---4. Data Transformation: Finding out the change of recovery and death cases over time per week in the variable sembuh_difference and meninggal_difference, utilizing the LAG function---
--The first week (January 2nd) was omitted from the table because the resulting data was NULL due to the absence of previous data (2020), which can result in abnormal-looking charts in visualization.
WITH covid_summary AS ( -- This Common Table Expression (CTE) gives the total number of 'sembuh' (recovered) and 'meninggal' (dead) from all cities, divided by 'tanggal' (date) and 'nama_kota' (city name)
    SELECT 
        c.tanggal,
        c.nama_kota,
        SUM(CASE WHEN c.sub_kategori = 'dirawat' THEN c.jumlah ELSE 0 END) AS dirawat,
        SUM(CASE WHEN c.sub_kategori = 'self isolation' THEN c.jumlah ELSE 0 END) AS self_isolation,
        SUM(CASE WHEN c.sub_kategori = 'sembuh' THEN c.jumlah ELSE 0 END) AS sembuh,
        SUM(CASE WHEN c.sub_kategori = 'meninggal' THEN c.jumlah ELSE 0 END) AS meninggal
    FROM 
        jakarta_covid.dbo.covid c
    WHERE 
        c.kategori = 'positif'
    GROUP BY 
        c.tanggal, c.nama_kota
)

SELECT 
    *
FROM ( --Used Subquery so we can omit the NULL data in WHERE
    SELECT 
        tanggal,
        nama_kota,
        dirawat,
        self_isolation,
        sembuh,
        sembuh - LAG(sembuh) OVER (PARTITION BY nama_kota ORDER BY tanggal) AS sembuh_delta,
        meninggal,
        meninggal - LAG(meninggal) OVER (PARTITION BY nama_kota ORDER BY tanggal) AS meninggal_delta
    FROM 
        covid_summary
) AS subquery
WHERE 
    sembuh_delta IS NOT NULL AND meninggal_delta IS NOT NULL
ORDER BY 
    tanggal;

---5. Data Exploration: Find out the reovery rate and mortality rate for each city. Also change the date to week # (column 'minggu') using the function DATEPART(wk, tanggal) (as opposed to MySQL's WEEK() function.--- 
-- recovery_rate = total_recoveries / total_cases
-- mortality_rate = total_deaths / total_cases
-- We make both aggregates above into FLOAT using CAST() function because the variables used are integers

SELECT
    DATEPART(wk, tanggal) as minggu,
    nama_kota,
  --  kategori,
    SUM(CASE WHEN sub_kategori IN ('Sembuh') THEN jumlah ELSE 0 END) AS total_recoveries,
    SUM(CASE WHEN sub_kategori IN ('Meninggal', 'Probable Meninggal', 'Suspek meninggal') THEN jumlah ELSE 0 END) AS total_deaths,
    SUM(jumlah) AS total_cases,
    CAST(SUM(CASE WHEN sub_kategori = 'Sembuh' THEN jumlah ELSE 0 END) AS FLOAT) / NULLIF(SUM(jumlah), 0) AS recovery_rate,
    CAST(SUM(CASE WHEN sub_kategori IN ('Meninggal', 'Probable Meninggal', 'Suspek meninggal') THEN jumlah ELSE 0 END) AS FLOAT) / NULLIF(SUM(jumlah), 0) AS mortality_rate
FROM
    Jakarta_covid.dbo.covid
GROUP BY
    tanggal,
    nama_provinsi,
    nama_kota
order by minggu,nama_kota
;

---5a. Exploratory Data Analysis: City ranked based on 2021 COVID mortality rate 
WITH CityMortalityRates AS (
    SELECT
        tanggal,
        nama_kota,
        SUM(CASE WHEN sub_kategori IN ('Meninggal', 'Probable Meninggal', 'Suspek meninggal') THEN jumlah ELSE 0 END) AS total_deaths,
        SUM(jumlah) AS total_cases,
        ROW_NUMBER() OVER ( -- Window Function so we can find the peak mortality rate for EACH CITY
			PARTITION BY 
				nama_kota 
			ORDER BY 
				CAST(SUM(CASE WHEN sub_kategori IN ('Meninggal', 'Probable Meninggal', 'Suspek meninggal') THEN jumlah ELSE 0 END) AS FLOAT) / NULLIF(SUM(jumlah), 0) DESC) 
			AS peak_rank
    FROM
        Jakarta_covid.dbo.covid
    GROUP BY
        tanggal,
        nama_provinsi,
        nama_kota
)

SELECT
    nama_kota,
    tanggal AS peak_mortality_date,
    CAST(total_deaths AS FLOAT) / NULLIF(total_cases, 0) AS peak_mortality_rate
FROM
    CityMortalityRates
WHERE
    peak_rank = 1
ORDER BY
    peak_mortality_rate DESC;

-- 5b. Alternative without Window Function---
WITH CityMortalityRates AS (
    SELECT
        tanggal,
        nama_kota,
        SUM(CASE WHEN sub_kategori IN ('Meninggal', 'Probable Meninggal', 'Suspek meninggal') THEN jumlah ELSE 0 END) AS total_deaths,
        SUM(jumlah) AS total_cases,
        CAST(SUM(CASE WHEN sub_kategori IN ('Meninggal', 'Probable Meninggal', 'Suspek meninggal') THEN jumlah ELSE 0 END) AS FLOAT) / NULLIF(SUM(jumlah), 0) AS mortality_rate
    FROM
        Jakarta_covid.dbo.covid
    GROUP BY
        tanggal,
        nama_provinsi,
        nama_kota
)

SELECT
    nama_kota,
    tanggal AS peak_mortality_date,
    mortality_rate AS peak_mortality_rate
FROM
    CityMortalityRates cmr1
WHERE
	-- Choosing the maximum mortality rate
    mortality_rate = (
        SELECT MAX(mortality_rate)
        FROM CityMortalityRates cmr2
        WHERE cmr1.nama_kota = cmr2.nama_kota
    )
ORDER BY
    mortality_rate DESC;

---5c. Exploratory Data Analysis: When was the peak mortality rate for each month during 2021, broken down by city?---
WITH CityMonthlyMortalityRates AS (
    SELECT
        DATEPART(month, tanggal) AS month_number,
        nama_kota,
        tanggal,
        SUM(CASE WHEN sub_kategori IN ('Meninggal', 'Probable Meninggal', 'Suspek meninggal') THEN jumlah ELSE 0 END) AS total_deaths,
        SUM(jumlah) AS total_cases,
        ROW_NUMBER() OVER (
			PARTITION BY 
				nama_kota, 
				DATEPART(month, tanggal) ORDER BY CAST(SUM(CASE WHEN sub_kategori IN ('Meninggal', 'Probable Meninggal', 'Suspek meninggal') THEN jumlah ELSE 0 END) AS FLOAT) / NULLIF(SUM(jumlah), 0) DESC) 
			AS peak_rank
    FROM
        Jakarta_covid.dbo.covid
    GROUP BY
        DATEPART(month, tanggal),
        nama_provinsi,
        nama_kota,
        tanggal
)
SELECT
    nama_kota,
    FORMAT(DATEFROMPARTS(YEAR(tanggal), month_number, 1), 'MM') AS peak_month,
    tanggal AS peak_date,
    CAST(total_deaths AS FLOAT) / NULLIF(total_cases, 0) AS peak_mortality_rate
FROM
    CityMonthlyMortalityRates
WHERE
    peak_rank = 1
ORDER BY
    FORMAT(DATEFROMPARTS(YEAR(tanggal), month_number, 1), 'MM'),nama_kota, peak_mortality_rate DESC;

---5d. Exploratory Data Analysis: Determine the peak mortality rate, minimum mortality rate, and average mortality rate per month, broken down by city, and when the highest and lowest rate happened

WITH CityMonthlyMortalityRates AS (
    SELECT
        nama_kota,
        DATEPART(YEAR, tanggal) AS year,
        DATEPART(MONTH, tanggal) AS month,
        tanggal,
        SUM(CASE WHEN sub_kategori IN ('Meninggal', 'Probable Meninggal', 'Suspek meninggal') THEN jumlah ELSE 0 END) AS total_deaths,
        SUM(jumlah) AS total_cases,
        ROW_NUMBER() OVER (PARTITION BY nama_kota, DATEPART(YEAR, tanggal), DATEPART(MONTH, tanggal) ORDER BY CAST(SUM(CASE WHEN sub_kategori IN ('Meninggal', 'Probable Meninggal', 'Suspek meninggal') THEN jumlah ELSE 0 END) AS FLOAT) / NULLIF(SUM(jumlah), 0) DESC) AS peak_rank,
        AVG(CAST(SUM(CASE WHEN sub_kategori IN ('Meninggal', 'Probable Meninggal', 'Suspek meninggal') THEN jumlah ELSE 0 END) AS FLOAT) / NULLIF(SUM(jumlah), 0)) OVER (PARTITION BY nama_kota, DATEPART(YEAR, tanggal), DATEPART(MONTH, tanggal)) AS monthly_avg_mortality_rate,
        MIN(CAST(SUM(CASE WHEN sub_kategori IN ('Meninggal', 'Probable Meninggal', 'Suspek meninggal') THEN jumlah ELSE 0 END) AS FLOAT) / NULLIF(SUM(jumlah), 0)) OVER (PARTITION BY nama_kota, DATEPART(YEAR, tanggal), DATEPART(MONTH, tanggal)) AS min_mortality_rate
    FROM
        Jakarta_covid.dbo.covid
    GROUP BY
        nama_kota,
        DATEPART(YEAR, tanggal),
        DATEPART(MONTH, tanggal),
        tanggal
)
SELECT
    nama_kota,
    FORMAT(DATEFROMPARTS(year, month, 1), 'yyyy-MM') AS month_year,
    tanggal AS peak_date,
    (SELECT TOP 1 tanggal FROM CityMonthlyMortalityRates WHERE nama_kota = CMR.nama_kota AND year = CMR.year AND month = CMR.month ORDER BY min_mortality_rate ASC) AS min_date,
    CAST(total_deaths AS FLOAT) / NULLIF(total_cases, 0) AS peak_mortality_rate,
    monthly_avg_mortality_rate,
    min_mortality_rate
FROM
    CityMonthlyMortalityRates AS CMR
WHERE
    peak_rank = 1
ORDER BY
    month_year, peak_mortality_rate DESC;