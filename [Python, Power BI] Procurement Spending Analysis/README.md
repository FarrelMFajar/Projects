# **Procurement Analysis for Wide World Importers**

## **Introduction: The Business Problem**

This project analyzes the procurement data of Wide World Importers, a fictional wholesale novelty goods importer and distributor, from 2013 to 2016\. The primary goal is to identify spending trends, uncover potential risks and inefficiencies, and provide actionable recommendations to optimize future procurement spending.

The key questions addressed in this analysis are:

1. What are the main issues or risks in the current procurement process?  
2. Are there any significant outliers or spikes in purchases that need investigation?  
3. What are the actionable findings and recommendations to improve procurement strategy?

## **Data Source**

The data for this project is contained within the data/ directory, organized into two subfolders: raw/ and processed/. This structure separates the original, untouched data from the cleaned, analysis-ready data, showcasing the data preparation process.

### **data/raw/**

This folder contains the original, unaltered data source:

* Tech Test ( Take Home Test ) \- GYS.xlsx: The raw Excel file with multiple sheets containing transactional data, supplier details, and stock item information. This file includes various data quality issues such as inconsistent date formats, duplicate entries, and formatting errors.

### **data/processed/**

This folder contains the cleaned and processed data, ready for analysis. These files are the output of the data cleaning and preparation steps detailed in the Jupyter Notebook (notebooks/procurement\_analysis.ipynb).

* fact\_purchase.csv: Cleaned transactional data.  
* dim\_supplier.csv: Cleaned supplier dimension table with duplicates resolved.  
* dim\_stock\_item.csv: Cleaned stock item dimension table with versioning history corrected.

The separation of raw and processed data highlights the crucial data wrangling phase of the project, a detailed walkthrough of which can be found in the analysis notebook.

### **Database Relationship Diagram**

The processed data is structured in a star schema:

erDiagram  
    fact\_purchase ||--o{ dim\_supplier : "Supplier Key"  
    fact\_purchase ||--o{ dim\_stock\_item : "Stock Item Key"

    fact\_purchase {  
        int "Purchase Key" PK  
        date "Date Key"  
        int "Supplier Key" FK  
        int "Stock Item Key" FK  
        int "Ordered Outers"  
        int "Ordered Quantity"  
    }

    dim\_supplier {  
        int "Supplier Key" PK  
        string Supplier  
        string Category  
    }

    dim\_stock\_item {  
        int "Stock Item Key" PK  
        string "Stock Item"  
        string Color  
        string Brand  
        float "Unit Price"  
    }

## **Methodology**

*(...rest of the README remains t he same...)*