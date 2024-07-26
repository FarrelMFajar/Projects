## Portofilio Projects
In this section I will list data analytics projects briefly describing the methods I used to achive the project's goal.

### 1. Covid-19 Data Exploration

#### Code:** ['covid_data_exploration.sql'](https://github.com/FarrelMFajar/Data-Analyst-Portofolio/tree/main/Covid-19%20Data%20Exploration)

#### 1.1. Project Description:
The proje­ct focuses on examining COVID-19 data in Jakarta for 2021. It involves loading the­ dataset, cleaning and preparing the­ data, and conducting exploratory data analysis (EDA) to uncover insights from the available­ information. 

#### 1.2. Data Loading:
The dataset contains records of COVID-19 case­s in Jakarta for 2021. It has several columns, including date, province­ name, city name, subdistrict name, district name­, 
category, subcategory, and quantity. 

#### 1.3. Data Cleaning:
* Abnormal e­ntries in the date column we­re identified and re­moved. The column types we­re also adjusted to ensure­ compatibility with other programs like Microsoft Excel.
* Geographical accuracy was improved by changing "KAB.ADM.KEP.SERIBU" to "Kepulauan Seribu" in the nama_kota column.

#### 1.4. Data exploration:
* The­ analysis looks at how recovery and death case­s changed over time e­ach week. It also calculates the­ recovery and mortality rates for e­ach city, and identifies the pe­ak mortality rates for cities and months. The ave­rage and standard deviation of the re­covery and mortality rates were­ calculated. Weekly ave­rage rows were adde­d for each week, including an ove­rall "WEEKLY AVERAGE" row. 

#### 1.5. Skills Showcase:
* Microsoft SQL Server Studio Management 19
* Data cleaning, aggregation, window functions, common table­ expressions (CTEs), and data transformation. 
* Data manipulation, cleaning, pre­processing, and exploratory data analysis.
* Functions: SELECT, CASE WHEN, GROUP BY, ORDER BY, PARTITION, ALTER TABLE, AVG, STDEV, UNION ALL, FORMAT

### 2. Covid-19 Dashboard

#### Code:

#### 2.1. Project Description:**
This project is a follow-up to the project "1. Covid-19 Data Exploration", in which the resulting table from ['query #6 in covid_data_exploration.sql'](https://github.com/FarrelMFajar/Data-Analyst-Portofolio/blob/d0d42b90e64c8e6a273223dbdca45f562cd0de26/Covid-19%20Data%20Exploration/covid_data_exploration.sql) is imported to Power BI. 

The purpose of this project is to observe metrics obtained from the table, both city-wise and district-wise

#### 2.2. Data Importing
The dataset contains records of COVID-19 case­s in Jakarta for 2021 that have been transformed in such a way that Power Query and DAX functions are used as efficiently as possible 

#### 2.3. Data Visualization
I based my visualiations off of existing one from a ['page'](http://arctic.som.ou.edu/tburg/products/covid19/) created by [Tomer burg](https://github.com/tomerburg). 

The report consists of four visualization pages.
1. **General Dashboard**. The user can interact with the slicer to filter the charts and metrics by date range, city, and district
2. **Summary Weekly Charts**. Shows graph for every single district in Jakarta. The user can choose which parameter to be compared
3. **Fact Sheets**. Shows callout cards for every single district in Jakarta. The user can choose which parameter to be compared
4. **Interactive District Chart**. One large graph of one district or city, that the user can select and compare parameters

#### 2.4. Skills Showcase:
* Microsoft Power BI
* Importing SQL to Power BI
* Data Transformation by Power Query
* DAX Measure Calculations
* Data Visualization: Card, Line Chart, Area Chart, Small Multiples, Slicer Handling, Data Filtering
* Dashboard User Interface


### 3. OSHA Incident Data Exploration
#### Code: 'osha_violation.sql'

#### 3.1. Project Description:
The project focuses on examining OSHA incident data from 2015 to 2017. It involves loading the dataset, cleaning and preparing the data, and conducting exploratory data analysis (EDA) to uncover insights from the available information.

#### 3.2. Data Loading:
The dataset contains records of OSHA incidents with various columns, including event date, event ID, abstract text, event description, event keywords, degree of injury, construction end use, building stories, project cost, project type, nature of injury, part of body, event type, environmental factor, human factor, task assigned, hazsub, fat_cause, and fall_ht.

#### 3.3. Data Cleaning:
* Initial check to load and inspect the data.
* Identified and handled duplicate Event IDs.
* Corrected abstract text that was split across multiple rows.
* Fixed improper usage of the question mark ("?") in event descriptions.
* Created new table clean_incidents to put in the cleaned data with the corrected abstract text and cleaned event descriptions.
* Set Event ID as the primary key in the clean_incidents table.

#### 3.4. Data Exploration:
* Examined the total occurrence of keywords and their distribution between fatal and nonfatal incidents.
* Explored the frequency and percentage of each nature of injury.
* Analyzed incidents grouped by nature of injury, part of body, and event type.
* Investigated monthly occurrences of OSHA violations, grouped by degree of injury (fatal/non-fatal).

#### 3.5. Skills Showcase:
* Microsoft SQL Server Management Studio (SSMS)
* Data cleaning, aggregation, common table expressions (CTEs), and data transformation.
* Data manipulation, preprocessing, and exploratory data analysis.
* Functions: SELECT, CASE WHEN, GROUP BY, ORDER BY, CROSS APPLY, STRING_SPLIT, FORMAT, ALTER TABLE, COUNT, SUM, CONCAT, INFORMATION_SCHEMA.COLUMNS, HAVING

#### 3.6. Detailed SQL Steps:

##### 1. Initial Data Inspection:
* Loaded the OSHA incident data and inspected the initial dataset.

##### 2. Data Cleaning:
* Checked for duplicate Event IDs and verified the kind of duplicates.
* Corrected split abstract text and improper usage of the question mark ("?").
* Created a new table clean_incidents with the cleaned data.

##### 3. Primary Key Assignment:
* Set the Event ID column as the primary key for the clean_incidents table.

##### 4. Keyword Analysis:
* Analyzed the total occurrence of keywords.
* Investigated the occurrence of each keyword grouped by fatal and nonfatal incidents.

##### 5. Nature of Injury Analysis:
* Checked and cleaned part of body and nature of injury data.
* Ranked nature of injuries by frequency and percentage of total occurrences.
* Examined the distribution of incidents grouped by nature of injury and part of body.

##### 6. Monthly Occurrence Analysis:
* Analyzed the monthly occurrence of OSHA violations, grouped by degree of injury (fatal/non-fatal).
