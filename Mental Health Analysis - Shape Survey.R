### Step 1 Load the Packages & Data

# Research Question:How do insurance and stigma-related barriers affect the likelihood of unmet mental health needs, and do these effects vary across gender and racial/ethnic groups?


# Step 1:  Load tidyverse for data manipulation and visualization

library(tidyverse)
library(dplyr)
# Load the dataset from your local drive

df <- read.csv("C:/Users/srive/Downloads/SHAPEdata2022 (1).csv")


### Step 2 : Handle Missing Values in Key Variables
# Define key variables required for your analysis

key_vars <- c("B8", "B9", "G1", "G12", "EthRace5_2022", "B10_4", "B10_5")

# View the number of missing values per key variable
na_counts <- colSums(is.na(df[key_vars]))
print(na_counts)  # Helps identify which variables need cleaning

# Create a clean dataset by removing rows with missing values in key variables
df_clean <- df %>%
  drop_na(all_of(key_vars))

# Confirm that missing values are removed
colSums(is.na(df_clean[key_vars]))

### STEP 3: Create Key Variables for Analysis

df_clean <- df_clean %>%
  mutate(
    # Create binary outcome: 1 = unmet need, 0 = no unmet need
    unmet_need = ifelse(B8 == 1 & B9 == 2, 1, 0),
    
    # Recode gender: 1 = Male, 2 = Female, else = Other
    gender = factor(case_when(
      G1 == 1 ~ "Male",
      G1 == 2 ~ "Female",
      TRUE ~ "Other"
    )),
    
    # Recode race/ethnicity from numeric to descriptive labels
    race = factor(EthRace5_2022, levels = 1:5,
                  labels = c("Native", "Hispanic", "Asian", "Black", "White")),
    
    # Create binary variables for barriers
    insurance_barrier = ifelse(B10_5 == 1, 1, 0),
    stigma_barrier = ifelse(B10_4 == 1, 1, 0)
  )

### STEP 4: Examine Distribution of Unmet Needs by Gender and Race & **Barriers Across Gender and Race**


# Create contingency tables
table(df_clean$unmet_need, df_clean$gender)
table(df_clean$unmet_need, df_clean$race)

# Perform Chi-square tests
chisq.test(table(df_clean$unmet_need, df_clean$gender))  # Gender vs Unmet Need
chisq.test(table(df_clean$unmet_need, df_clean$race))    # Race vs Unmet Need



# Stigma barrier differences by gender and race
chisq.test(table(df_clean$gender, df_clean$stigma_barrier))
chisq.test(table(df_clean$race, df_clean$stigma_barrier))

# Insurance barrier differences by gender and race
chisq.test(table(df_clean$gender, df_clean$insurance_barrier))
chisq.test(table(df_clean$race, df_clean$insurance_barrier))

### STEP 5: Unadjusted Logistic Regression Models


# Unadjusted model for Gender
model_gender_unadj <- glm(unmet_need ~ gender, data = df_clean, family = binomial)
summary(model_gender_unadj)
exp(coef(model_gender_unadj))  # Odds Ratios (ORs)

# Unadjusted model for Race
model_race_unadj <- glm(unmet_need ~ race, data = df_clean, family = binomial)
summary(model_race_unadj)
exp(coef(model_race_unadj))

# Unadjusted model for Insurance Barrier
model_insurance_unadj <- glm(unmet_need ~ insurance_barrier, data = df_clean, family = binomial)
summary(model_insurance_unadj)
exp(coef(model_insurance_unadj))

# Unadjusted model for Stigma Barrier
model_stigma_unadj <- glm(unmet_need ~ stigma_barrier, data = df_clean, family = binomial)
summary(model_stigma_unadj)
exp(coef(model_stigma_unadj))


###STEP 6: Fully Adjusted Logistic Regression Model


# Set "Female" as the reference group for gender
df_clean$gender <- relevel(df_clean$gender, ref = "Female")

# Set "White" as the reference group for race
df_clean$race <- relevel(df_clean$race, ref = "White")

#Logistic Regression Model : Insurance barrier

model_full1 <- glm(unmet_need ~ gender + race + insurance_barrier,
                   data = df_clean, family = binomial)

summary(model_full1)
exp(coef(model_full1))  # Adjusted Odds Ratios



#Logistic Regression Model : Stigma barrier

model_full2 <- glm(unmet_need ~ gender + race + stigma_barrier,
                   data = df_clean, family = binomial)

summary(model_full2)
exp(coef(model_full2))  # Adjusted Odds Ratios


### Step 7: Compare Adjusted and Unadjusted Effects ( 10% rule)


#  Extract odds ratios from unadjusted models
or_insurance_unadj <- exp(coef(glm(unmet_need ~ insurance_barrier, data = df_clean, family = binomial)))
or_stigma_unadj    <- exp(coef(glm(unmet_need ~ stigma_barrier, data = df_clean, family = binomial)))

#  Extract odds ratios from adjusted models
or_insurance_adj <- exp(coef(model_full1))
or_stigma_adj    <- exp(coef(model_full2))

# Calculate % change in ORs for 10% rule
percent_change_insurance <- abs((or_insurance_unadj["insurance_barrier"] - or_insurance_adj["insurance_barrier"]) /
                                  or_insurance_unadj["insurance_barrier"]) * 100

percent_change_stigma <- abs((or_stigma_unadj["stigma_barrier"] - or_stigma_adj["stigma_barrier"]) /
                               or_stigma_unadj["stigma_barrier"]) * 100

#️ Print results
print(paste("Percent change in OR for insurance_barrier:", round(percent_change_insurance, 2), "%"))
print(paste("Percent change in OR for stigma_barrier:", round(percent_change_stigma, 2), "%"))


### STEP 8: Interaction Models

# Interaction: Gender × Insurance Barrier
model_interact_gender_ins <- glm(unmet_need ~ gender + race + insurance_barrier +
                                   gender:insurance_barrier,
                                 data = df_clean, family = binomial)
summary(model_interact_gender_ins)

#  Interaction: Race × Insurance Barrier
model_interact_race_ins <- glm(unmet_need ~ gender + race + insurance_barrier +
                                 race:insurance_barrier,
                               data = df_clean, family = binomial)
summary(model_interact_race_ins)

# Interaction: Gender × Stigma Barrier
model_interact_gender_stigma <- glm(unmet_need ~ gender + race + stigma_barrier +
                                      gender:stigma_barrier,
                                    data = df_clean, family = binomial)
summary(model_interact_gender_stigma)

#  Interaction: Race × Stigma Barrier
model_interact_race_stigma <- glm(unmet_need ~ gender + race + stigma_barrier +
                                    race:stigma_barrier,
                                  data = df_clean, family = binomial)
summary(model_interact_race_stigma)



###  Step 9 : Stratified analysis 

# Create race_gender variable
df_clean <- df_clean %>%
  mutate(race_gender = paste(race, gender, sep = "_"),
         race_gender = as.factor(race_gender))

# Create contingency tables
table(df_clean$unmet_need, df_clean$race_gender)

# Chi square test: Race-Gender vs Unmet Need
# Does the rate of unmet mental health needs differ across race-gender groups?
chisq.test(table(df_clean$race_gender, df_clean$unmet_need))

# Chi square test:Insurance barriers vs Race- Gender 
# How does barriers are distributed across sub groups


# Contingency table
table_insurance <- table(df_clean$race_gender, df_clean$insurance_barrier)
print(table_insurance)

# Chi-square test
chisq.test(table_insurance)


# Chi square test : Stigma barriers vs Race- Gender
table_stigma <- table(df_clean$race_gender, df_clean$stigma_barrier)
print(table_stigma)

# Chi-square test
chisq.test(table_stigma)


### Step 10: Unadjusted and Adjusted logistic regression

model_unadj <- glm(unmet_need ~ race_gender, data = df_clean, family = binomial)
summary(model_unadj)
exp(coef(model_unadj))  # Odds Ratios


# Relevel the race_gender factor to set White_Female as the reference
df_clean$race_gender <- relevel(df_clean$race_gender, ref = "White_Female")

#Adjusted logistic regression : Insurance barrier

model_adj_Insurance1 <- glm(unmet_need ~ race_gender + insurance_barrier,
                            data = df_clean, family = binomial)
summary(model_adj_Insurance1)
exp(coef(model_adj_Insurance1))  # Adjusted ORs



#Adjusted logistic regression : stigma barrier

model_adj_Stigma1 <- glm(unmet_need ~ race_gender + stigma_barrier,
                         data = df_clean, family = binomial)
summary(model_adj_Stigma1)
exp(coef(model_adj_Stigma1))  # Adjusted ORs


### Step 11: Effect modification : Race_gender 


# Interaction: Race-Gender x Insurance Barrier

model_effectmod_ins <- glm(unmet_need ~ race_gender * insurance_barrier, 
                           family = binomial, data = df_clean)
summary(model_effectmod_ins)

#Interaction: Race-Gender x Stigma Barrier
model_effectmod_stigma <- glm(unmet_need ~ race_gender * stigma_barrier, 
                              family = binomial, data = df_clean)
summary(model_effectmod_stigma)


### Step 12 : Bar Plot: Unmet Mental Health need by gender

# Proportion table with percentage labels
gender_pct <- df_clean %>%
  count(gender, unmet_need) %>%
  group_by(gender) %>%
  mutate(perc = round(n / sum(n) * 100, 1))

# Bar plot with % labels
ggplot(gender_pct, aes(x = gender, y = perc, fill = unmet_need)) +
  geom_bar(stat = "identity", position = position_stack()) +
  geom_text(aes(label = paste0(perc, "%")),
            color= "white",
            position = position_stack(vjust = 0.5), size = 4) +
  labs(title = "Unmet Mental Health Need by Gender",
       x = "Gender", y = "Percentage",
       fill = "Unmet Need") +
  theme_minimal()


### Step 13: Bar Plot : Unmet Mental Need by Race

# Proportion table with percentage labels
race_pct <- df_clean %>%
  count(race, unmet_need) %>%
  group_by(race) %>%
  mutate(perc = round(n / sum(n) * 100, 1))

# Bar plot with % labels
ggplot(race_pct, aes(x = race, y = perc, fill = unmet_need)) +
  geom_bar(stat = "identity", position = position_stack()) +
  geom_text(aes(label = paste0(perc, "%")),
            color ="white",
            position = position_stack(vjust = 0.5), size = 4) +
  labs(title = "Unmet Mental Health Need by Race",
       x = "Race", y = "Percentage",
       fill = "Unmet Need") +
  theme_minimal()


### Step 14: Bar Plot : Unmet Mental Need by Race-Gender

library(dplyr)
library(ggplot2)

df_summary <- df_clean %>%
  group_by(race_gender) %>%
  summarise(
    unmet_need_rate = mean(unmet_need) * 100,  # Convert to percentage
    n = n()
  )

ggplot(df_summary, aes(x = reorder(race_gender, -unmet_need_rate), y = unmet_need_rate)) +
  geom_bar(stat = "identity", fill = "steelblue") +
  geom_text(aes(label = paste0(round(unmet_need_rate, 1), "%")), 
            hjust = -0.1, size = 3.5) +  # Adjust position and size
  labs(x = "Race-Gender Group", y = "Unmet Mental Health Need (%)") +
  theme_minimal() +
  coord_flip() +
  theme(axis.text = element_text(size = 10)) +
  ylim(0, max(df_summary$unmet_need_rate) + 10) 
