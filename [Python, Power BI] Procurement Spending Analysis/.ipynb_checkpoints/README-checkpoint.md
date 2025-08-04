<img width="767" height="629" alt="image" src="https://github.com/user-attachments/assets/23fc0bf2-5fdf-4923-ad7b-0e32bac07b25" /># Procurement Analysis for Wide World Importers

## Background and Overview

Wide World Importers is a wholesale novelty goods distributor. The Procurement Board has requested the Data Analyst to review the company’s procurement data in order to understand spending trends from 2013 to 2016 and to formulate strategies to optimize future procurement spending.

The company's procurement data, previously underutilized, holds the key to understanding our spending patterns, supplier dependencies, and operational inefficiencies. This analysis synthesizes this data to address the following key business questions:

  * **Spending Trends:** How has our procurement spending evolved over time, and what are the underlying drivers?
  * **Supplier Dependency:** How diverse is our supplier base, and are there associated risks or opportunities?
  * **Operational Efficiency:** Is our procurement process planned and proactive, or reactive and inefficient?

The findings and recommendations are summarized in this report, with links to the full technical analysis for those interested in the details.


### Database Relationship Diagram

The data consists of one fact table of purchase data, linked to two dimension tables: Supplier and Stock Item.
<img width="767" height="629" alt="image" src="https://github.com/user-attachments/assets/873492b5-feda-4887-a6be-faedda55038f" />

-----

## Executive Summary of Findings

After a thorough analysis, several critical insights emerged:
* While total purchases grew over 570% from 2013 to 2015, this growth was erratic and followed by a sudden 44% drop in 2016. This volatility appears to be driven by a highly reactive and unplanned procurement process, characterized by massive, infrequent orders rather than steady, predictable purchasing.
<img width="1364" height="668" alt="image" src="https://github.com/user-attachments/assets/de0c6e76-5793-48be-aed3-153fd8a73376" /> <img width="1224" height="682" alt="image" src="https://github.com/user-attachments/assets/cab752fb-f767-4994-83c4-bdb9b1112cda" />



* Furthermore, our supply chain is exposed to significant risk, with 85-90% of our total spending concentrated with just two main suppliers, Fabrikam, Inc. and Litware, Inc. An investigation into spending patterns also revealed a major anomaly: a massive expenditure on "Tape dispensers" in May 2015, which accounted for nearly 20% of our total budget in that period and may indicate a data entry error or a significant one-off purchase.

## Insights Deep Dive

### 1\. Spending is Unstable and Driven by Massive, Infrequent Orders

[cite\_start]While the overall trend showed growth until 2016, a closer look at the monthly data reveals a highly volatile purchasing pattern[cite: 9]. [cite\_start]The chart below shows that after an initial period of smaller, more frequent orders in 2013, the company shifted to placing massive, irregular orders, particularly in 2015[cite: 16]. [cite\_start]This culminated in a dramatic spending collapse in mid-2016, suggesting the company may have been overstocked and was forced to freeze procurement[cite: 9, 367].

 *(Placeholder for your chart)*

This reactive purchasing behavior is a significant risk, leading to inefficient cash flow management, potential stockouts, and high carrying costs.

### 2\. Extreme Supplier Concentration

[cite\_start]Our analysis of supplier spending shows a heavy reliance on two vendors: Fabrikam, Inc. and Litware, Inc.[cite: 62, 69, 75, 112]. [cite\_start]Fabrikam, our clothing supplier, and Litware, our packaging supplier, together account for the vast majority of our total procurement spend[cite: 210]. This lack of supplier diversity creates a high-risk dependency. Any disruption from either of these suppliers could severely impact our operations.

 *(Placeholder for your chart)*

### 3\. Anomaly in Item Spending: The Tape Dispenser Incident

A detailed look at item-level spending uncovered a major outlier. [cite\_start]In May 2015, the company spent over $600,000 on "Tape dispenser (Red)" from Litware, Inc., making it the single highest-spend item in our entire dataset[cite: 11, 12]. This single purchase represents a significant portion of our budget and seems highly unusual for a novelty goods distributor.

[cite\_start]This could be a case of mislabeling (e.g., purchasing "packaging tape" but recording it as "tape dispensers")[cite: 13]. This highlights a potential weakness in our data governance and inventory tracking.

 *(Placeholder for your chart)*

## Actionable Recommendations

Based on the insights uncovered, here are five key recommendations to improve procurement strategy and drive business value:

1.  **Develop a Strategic Sourcing and Inventory Management Plan:** Move from a reactive to a proactive procurement model. Implement a rolling forecast system based on historical sales and stock levels to smooth out purchasing and avoid large, unplanned orders. [cite\_start]This will improve cash flow and reduce carrying costs[cite: 374, 376].

2.  [cite\_start]**Investigate and Validate Spending Anomalies:** Immediately clarify the large "tape dispenser" purchase with Litware, Inc. to determine if it was a data entry error[cite: 14, 368, 371]. This will help correct historical data and prevent future errors. [cite\_start]A full audit of 2016's spending drop is also needed to understand the cause and plan for more stable growth[cite: 372].

3.  **Diversify the Supplier Base:** While maintaining strong relationships with Fabrikam and Litware, actively seek and onboard alternative suppliers for key product categories like clothing and packaging. [cite\_start]This will mitigate supply chain risk and increase negotiating power[cite: 211, 375].

4.  [cite\_start]**Implement Spending Controls:** Introduce monthly or quarterly spending caps for different product categories to ensure that procurement aligns with the overall budget and financial strategy[cite: 373].

5.  [cite\_start]**Refine Product Strategy for "The Gu" T-shirts:** The six top-selling variants of "The Gu" t-shirts are the backbone of our clothing sales[cite: 17]. [cite\_start]However, many other variants are purchased only once or twice[cite: 18]. We should focus marketing efforts on the top-performing variants and consider discontinuing or using promotional bundles to clear out the underperforming ones.

## Technical Details

For those interested in the technical implementation of this analysis, the following resources are available:

  * **Jupyter Notebook:** The complete Python code for data cleaning, transformation, analysis, and visualization can be found in the `notebooks/` folder.
  * **Requirements:** A `requirements.txt` file is included in the root directory to ensure the notebook can be run in a reproducible environment.
