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

### New Measures
Despite my best efforts to utilize SQL for data cleaning and tranformation, some data are more effectively done in power DAX measures in Power BI.
#### 1. Cumulative Cases, Deaths, Recoveries
For cumulative Cases, Deaths, and Recoveries, the callout is made in such a way that it's compatible with the date range filter that's in the dashboard. The cumulative variable can be expressed with the equation below:
```
Cumulative = f(tb) - (f(ta) - f(to)), where
f = The value function of cumulative case, death, or recoveries over time 
ta = First filtered date
tb = Last filtered date
to = Very first date regardless of filter
```
A new measure is added that incorporates the equation above into DAX language. Replace variable "efu" to change from case to death or recoveries. The date _t_ is stored in column "combination[tanggal]"
```
var efu = total_cases
Cumulative Data =
var fb =  CALCULATE(
            sum(combination[efu]),
            FILTER(
              combination, combination[tanggal]=
              max(combination[tanggal])
            )
          )
var fa =  CALCULATE(
            sum(combination[efu]),
            ALL(combination[tanggal]),
            FILTER(
              ALL(combination),combination[tanggal] = MIN(combination[tanggal])
            )
          )
var fo = CALCULATE(
            sum(combination[efu]),
            ALL(combination[tanggal]),
            FILTER(
              ALL(combination),combination[tanggal] = FIRSTDATE(all(combination[tanggal]))
            )
          )
RETURN fb = fa-fo
```

#### 2. The difference between the data from latest date and the date before the latest date
This measure is used for all callout cards except CFR. The difference df can be expressed with the equation below:
```
df = f(tb) - ft(b-1)), where
f = The value function of cumulative case, death, or recoveries over time
tb = Last filtered date
tb-1 = previous recorded date before last filtered date
```
In addition to the calculation, the "plus" notation needs to be added for any positive changes. As a result, the variable _df_ will be converted to string format, _df_ is reformatted beforehand so that the number shows thousands separator. Replace variable "efu" to the data you want to see the delta. The date _t_ is stored in column "combination[tanggal]"
```
var efu = total_cases
var tb = 
    CALCULATE(
    sum(combination[efu]),
    filter(
        combination, combination[tanggal] = max(combination[tanggal])))

var tbminusone = 
CALCULATE(
    sum(combination[efu]),
    filter(
        combination, combination[tanggal] =
        CALCULATE(MAX( combination[tanggal] ),REMOVEFILTERS(combination),combination[tanggal]<max(combination[tanggal]))))
return 
        "(" &
        if(tb>=tbminusone,"+",if(tb=tbminusone,"±"))
        & format(tb-tbminusone,"#,##0") 
        & ")" 
```

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

### Page #4. Interactive District Chart
This is an interactive chart to observe all parameters in a single district (or single city) 

**Slicers**
1. Date range
2. City
3. Parameters (Based on charts in 2.3.1.)
4. Parameters (based on charts in 2.3.1.)
