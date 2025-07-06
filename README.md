---
# Mental-Health-Analysis
**🧠 Project Overview**
This project analyzed data from the Hennepin County SHAPE 2022 survey data to examine whether individuals who needed mental health care but did not receive it experienced insurance or stigma-related barriers, and how these barriers differ across gender and race/ethnicity. We used statistical modeling to identify patterns and disparities in access to care using R language.

**❓ Research Question**
How do insurance and stigma-related barriers affect the likelihood of unmet mental health care needs, and do these effects vary across gender and racial/ethnic groups?
---
**🎯 Objectives**
1. Analyzed unmet mental health needs by race and gender using descriptive statistics.
2. Performed chi-square tests to assess group differences in unmet need.
3. Built unadjusted, adjusted, and interaction logistic regression models to evaluate confounding and effect modification by stigma and insurance barriers.
4. Conducted stratified and subgroup visualizations to highlight disparities across race-gender-barrier groups.
---
**🔬 Method Summary**
1. Data inspection and recoding with dplyr in R language
2. Visualization with ggplot2 (boxplot, proportion bar chart)
3. Chi-square test for associations
4. Logistic regression with:
-Main effects
-Adjusted models
-Interaction term 
5. Confounding check using the 10% change-in-estimate rule
---
**📈 Key Findings**
1. About 38% of people who needed mental health care did not receive it.
2. People with insurance barriers were 95% less likely to get care.
3. People facing stigma were 87% less likely to receive care.
4. Black, Hispanic, and Asian individuals had lower odds of unmet need compared to White individuals.
5. Black and White females had the highest rates of unmet need among all race-gender groups.
---0
**📂 Data Source**
[🔗 Hennepin County SHAPE 2022 survey dataset and documentation](https://www.hennepin.us/your-government/research-data/shape-surveys)

🏛️ This public-facing product was shared with and used by Hennepin County Public Health for policy and program planning related to immigrant health equity.
