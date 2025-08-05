## Background and Overview

GYS Importer is a wholesale novelty goods distributor. The Procurement Board has requested the Data Analyst to review the company’s procurement data in order to understand spending trends from 2013 to 2016 and to formulate strategies to optimize future procurement spending.

The company's procurement data, previously underutilized, holds the key to understanding our spending patterns, supplier dependencies, and operational inefficiencies. This analysis synthesizes this data to address the following key business questions:

  * **Spending Trends:** How has our procurement spending evolved over time, and what are the underlying drivers?
  * **Supplier Dependency:** How diverse is our supplier base, and are there associated risks or opportunities?
  * **Operational Efficiency:** Is our procurement process planned and proactive, or reactive and inefficient?

The findings and recommendations are summarized in this report, with links to the full technical analysis for those interested in the details.

The interactive PowerBI dashboard can be downloaded [here](https://github.com/FarrelMFajar/Projects/blob/8e28460f527a0b6061700209fc82bbc102ff70ad/%5BPython%2C%20Power%20BI%5D%20Procurement%20Spending%20Analysis/Dashboard/Procurement%20Monitoring%20Dashboard_final.pbix)
The Python code utilized to clean, explore, and visualize data can be found [here](https://github.com/FarrelMFajar/Projects/blob/3c319ca795ab0c910e189fc0be5e15dd62a2de89/%5BPython%2C%20Power%20BI%5D%20Procurement%20Spending%20Analysis/Procurement%20Spending%20Analysis.ipynb)

### Database Relationship Diagram

The data consists of one fact table of purchase data, linked to two dimension tables: Supplier and Stock Item.
<img width="921" height="354" alt="image" src="https://github.com/user-attachments/assets/3c1fffa9-933e-4e89-8d2c-4ba32353a054" />


-----

## Executive Summary of Findings

After a thorough analysis, several critical insights emerged:
* While total purchases grew over 570% from 2013 to 2015, this growth was erratic and followed by a sudden 44% drop in 2016. This volatility appears to be driven by a highly reactive and unplanned procurement process, characterized by massive, infrequent orders rather than steady, predictable purchasing.
<img width="1364" height="668" alt="image" src="https://github.com/user-attachments/assets/de0c6e76-5793-48be-aed3-153fd8a73376" /> <img width="1224" height="682" alt="image" src="https://github.com/user-attachments/assets/cab752fb-f767-4994-83c4-bdb9b1112cda" />



* Furthermore, our supply chain is exposed to significant risk, with 85-90% of our total spending concentrated with just two main suppliers, Fabrikam, Inc. and Litware, Inc. An investigation into spending patterns also revealed a major anomaly: a massive expenditure on "Tape dispensers" in May 2015, which accounted for nearly 20% of our total budget in that period and may indicate a data entry error or a significant one-off purchase.

## Insights Deep Dive

### 1\. Spending is Unstable and Driven by Massive, Infrequent Orders

While the overall trend showed growth until 2016, a closer look at the monthly data reveals a highly volatile purchasing pattern. The chart below shows that after an initial period of smaller, more frequent orders in 2013, the company shifted to placing massive, irregular orders, particularly in 2015. This culminated in a dramatic spending collapse in mid-2016, suggesting the company may have been overstocked and was forced to freeze procurement.

<img width="1103" height="500" alt="Monthly-Transaction-vs-Total-Purchases" src="https://github.com/user-attachments/assets/5f6ba060-c605-4b3a-96f4-cdf2ec456ab1" />

This reactive purchasing behavior is a significant risk, leading to inefficient cash flow management, potential stockouts, and high carrying costs.

### 2\. Extreme Supplier Concentration

Our analysis of supplier spending shows a heavy reliance on two vendors: Fabrikam, Inc. and Litware, Inc. Fabrikam, our clothing supplier, and Litware, our packaging supplier, together account for the vast majority of our total procurement spend. This lack of supplier diversity creates a high-risk dependency. Any disruption from either of these suppliers could severely impact our operations.

<img width="1101" height="400" alt="procurement flow" src="https://github.com/user-attachments/assets/5f9129a5-85e2-438c-a490-6ae1536b2201" />

### 3\. Anomaly in Item Spending: The Tape Dispenser

A detailed look at item-level spending uncovered a major outlier. In May 2015, the company spent over $600,000 on "Tape dispenser (Red)" from Litware, Inc., making it the single highest-spend item in our entire dataset. This single purchase represents a significant portion of our budget and seems highly unusual for a novelty goods distributor.

This could be a case of mislabeling (e.g., purchasing "packaging tape" but recording it as "tape dispensers"). This highlights a potential weakness in our data governance and inventory tracking.

 <img width="852" height="592" alt="image" src="https://github.com/user-attachments/assets/13d13d92-d7e1-42b9-abaf-d50e7b409ffe" />

### 3\. "The Gu" T-Shirts Dominate Clothing, but with Inefficient Variety
Six variants of "The Gu" t-shirts are the most procured items in the clothing category, accounting for a substantial portion of items being consistently procured throughout the period. However, dozens of other t-shirt variants were procured only once or twice, primarily at the beginning of 2013. This suggests an inefficient "long-tail" of products that likely contribute to dead stock and increased inventory complexity.

<img width="1101" height="700" alt="the gu shirt" src="https://github.com/user-attachments/assets/5fb71c4c-d32a-4f26-bff2-f3ec303f299b" />


## Actionable Recommendations

Based on the insights uncovered, here are five key recommendations to improve procurement strategy and drive business value:

1.  **Develop a Strategic Sourcing and Inventory Management Plan:** Move from a reactive to a proactive procurement model. Implement a rolling forecast system based on historical sales and stock levels to smooth out purchasing and avoid large, unplanned orders. This will improve cash flow and reduce carrying costs.

2.  **Investigate and Validate Spending Anomalies:** Immediately clarify the large "tape dispenser" purchase with Litware, Inc. to determine if it was a data entry error. This will help correct historical data and prevent future errors. A full audit of 2016's spending drop is also needed to understand the cause and plan for more stable growth.

3.  **Diversify the Supplier Base:** While maintaining strong relationships with Fabrikam and Litware, actively seek and onboard alternative suppliers for key product categories like clothing and packaging. This will mitigate supply chain risk and increase negotiating power.

4.  **Implement Spending Controls:** Introduce monthly or quarterly spending caps for different product categories to ensure that procurement aligns with the overall budget and financial strategy.

5.  **Refine Product Strategy for "The Gu" T-shirts:** The six top-selling variants of "The Gu" t-shirts are the backbone of our clothing sales. However, many other variants are purchased only once or twice. We should focus marketing efforts on the top-performing variants and consider discontinuing or using promotional bundles to clear out the underperforming ones.
