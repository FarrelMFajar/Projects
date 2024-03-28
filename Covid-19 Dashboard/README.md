## COVID-19 Dashboard

### Dashboard Link: https://app.powerbi.com/groups/me/reports/19393122-81c5-4d1e-8258-f6e320048b57/ReportSection

### Problem Statement

This dashboard helps observers understand the development of Novel Coronavirus (COVID-19) cases, down to every district within cities of Jakarta province, Indonesia. It also lets the user observe the dynamics of the data range back in 2021 and obtain historical analysis with how cases, deaths, recoveries, and other metrics evolved over time. In addition, this data can be used to evaluate the effectiveness of policy stated by the Ministry of health.

### Data Import

There are two ways to import the resulting table into Power BI.
a. Exporting the CSV via Microsoft SQL Server Studio Management
b. "Import" function on Power BI

**a. Exporting the CSV via Microsoft SQL Server Studio Management**
1. Right click on the database → Tasks → Export
2. SQL Server import and Export Wizard will open → Next
3. Data source: Choose "**Microsoft OLE DB Provider for SQL Server**" → Server name: (Server name), I use local SQL server → Next
4. Choose a destination → **Flat File Destination** → File Name: (File name).csv → Format: Delimited → Next
5. Specify Table Copy or Query: **Write a query to specify the data to transfer** → Next
6. Provide a Source Query: **Insert your query** → Parse → If OK, then click Next
7. Source query: [Query] → Next
8. Save and Run Package: Check **Run Immediately** → Next
9. Complete the Wizard → Finish
Open Power BI
10. Home tab → **Get Data → text/csv**
11. Open the csv file you exported earlier
12. **Transform Data**. if you already did the data cleaning via SQL beforehand like what I did, click **load** instead.

**b. "Import" function on Power BI**
1. File → **New Report**
2. Home tab  →  **Get Data → SQL Server**
3. SQL Server Database → Server: **Insert your server name** → Database (optional): **Input your database** → Data Connectivity Mode: I use **Import** as Power BI has some trouble parsing Common Table Expressions (WITH functions on SQL)
4. Advanced options → **Input your Query** → Next
5. **Transform Data**. if you already did the data cleaning via SQL beforehand like what I did, click **load** instead.

### Page #1. Dashboard
**Slicers**
1. Date range
2. City

**Callouts**, includes change from the previous date
1. Cumulative Cases (between two dates bound by the slicer)
2. Cumulative Deaths (between two dates bound by the slicer)
3. Cumulative Recoveries (between two dates bound by the slicer)
4. Latest Hospitalizations 
5. Latest Self-Isolations 

**Charts**
1. Cumulative Cases
2. Cumulative Deaths
3. Cumulative Recoveries
4. Weekly New Cases
5. Weekly new Deaths
6. Weekly New recoveries
7. Weekly Hospitalizations and Self-Isolations
8. Case-Fatality Ratio
  
### Page #2. Summary Weekly Charts
**Slicers**
1. Date range
2. City
3. Parameters (Based on charts in 2.3.1.)

**Charts**
1. Value-time chart with district for small multiples
2. "ALL" chart for reference
  
### Page #3. Fact Sheet
**Slicers**
1. Date range
2. City
3. Parameters (Based on callouts in 2.3.1.)

**Charts**
1. Value-time callout card with district for small multiples
2. "ALL" callout card for reference

### 2.3.4. Interactive District Chart
This is an interactive chart to observe all parameters in a single district (or single city) 

**Slicers**
1. Date range
2. City
3. Parameters (Based on charts in 2.3.1.)
4. Parameters (based on charts in 2.3.1.)
