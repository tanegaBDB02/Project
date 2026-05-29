library(readr)
library(dplyr)
library(ggplot2)
library(forcats)

data <- read_csv("/home/ibab/SEM4_RCT_Project/KVV2/Hyperphagia_Final(Meta-analysis).csv")
colnames(data)
colnames(data)
data <- data %>%
  rename(
    Drug = `Active/Drug`,
    AbsChange = `Absolute Change`
  )
colnames(data)

energy_data <- data %>%
  filter(Biomarker == "Energy Intake")
head(energy_data)

ggplot(energy_data, aes(x = AbsChange, y = Drug)) +
  geom_point(size = 3) +
  geom_vline(xintercept = 0, linetype = "dashed") +
  labs(
    title = "Energy Intake - Absolute Change",
    x = "Absolute Change",
    y = "Drug"
  ) +
  theme_minimal()

energy_data %>%
  group_by(Drug) %>%
  summarise(mean_effect = mean(AbsChange, na.rm = TRUE)) %>%
  arrange(mean_effect)



data <- data %>%
  mutate(
    Drug = case_when(
      grepl("Semaglutide", Drug, ignore.case = TRUE) ~ "Semaglutide",
      grepl("Liraglutide", Drug, ignore.case = TRUE) ~ "Liraglutide",
      grepl("Tirzepatide", Drug, ignore.case = TRUE) ~ "Tirzepatide",
      grepl("Orlistat", Drug, ignore.case = TRUE) ~ "Orlistat",
      TRUE ~ Drug
    )
  )

unique(data$Drug)

data <- data %>%
  mutate(
    Drug = case_when(
      grepl("Semaglutide", Drug, ignore.case = TRUE) ~ "Semaglutide",
      grepl("Liraglutide", Drug, ignore.case = TRUE) ~ "Liraglutide",
      grepl("Tirzepatide", Drug, ignore.case = TRUE) ~ "Tirzepatide",
      grepl("Orlistat", Drug, ignore.case = TRUE) ~ "Orlistat",
      grepl("Dulaglutide", Drug, ignore.case = TRUE) ~ "Dulaglutide",
      TRUE ~ Drug
    )
  )

unique(data$Drug)

energy_data <- data %>%
  filter(Biomarker == "Energy Intake")

energy_data %>%
  group_by(Drug) %>%
  summarise(mean_effect = mean(AbsChange, na.rm = TRUE)) %>%
  arrange(mean_effect)


#energy Intake 1st metric
energy_data <- data %>%
  filter(Biomarker == "Energy Intake")


ggplot(energy_data, aes(x = AbsChange, 
                        y = fct_reorder(Drug, AbsChange))) +
  geom_point(size = 3) +
  geom_vline(xintercept = 0, linetype = "dashed") +
  labs(
    title = "Energy Intake - Absolute Change",
    x = "Absolute Change",
    y = "Drug"
  ) +
  theme_minimal()


energy_summary <- energy_data %>%
  group_by(Drug) %>%
  summarise(mean_effect = mean(AbsChange, na.rm = TRUE))

ggplot(energy_summary, aes(x = mean_effect, 
                           y = fct_reorder(Drug, mean_effect))) +
  geom_point(size = 5, color = "blue") +
  geom_vline(xintercept = 0, linetype = "dashed") +
  labs(
    title = "Energy Intake - Mean Effect",
    x = "Mean Absolute Change",
    y = "Drug"
  ) +
  theme_minimal()



#Energy Intake 2nd metric
dnr_summary <- energy_data %>%
  group_by(Drug) %>%
  summarise(mean_dnr = mean(`Dose Normalised rate`, na.rm = TRUE)) %>%
  arrange(mean_dnr)

dnr_summary


ggplot(dnr_summary, aes(x = mean_dnr, 
                        y = fct_reorder(Drug, mean_dnr))) +
  geom_point(size = 5, color = "red") +
  geom_vline(xintercept = 0, linetype = "dashed") +
  labs(
    title = "Energy Intake - Dose Normalised Rate",
    x = "Mean Dose Normalised Rate",
    y = "Drug"
  ) +
  theme_minimal()



ggplot(energy_data, aes(x = `Dose Normalised rate`, 
                        y = Drug)) +
  geom_point(size = 3, color = "red") +
  geom_vline(xintercept = 0, linetype = "dashed") +
  labs(
    title = "Energy Intake - Dose Normalised Rate (Spread)",
    x = "Dose Normalised Rate",
    y = "Drug"
  ) +
  theme_minimal()


#VAS Scores Plot
vas_data <- data %>%
  filter(Biomarker == "VAS Scores")


unique(vas_data$Drug)


ggplot(vas_data, aes(x = AbsChange, y = Drug)) +
  geom_point(size = 3) +
  geom_vline(xintercept = 0, linetype = "dashed") +
  labs(
    title = "VAS Scores - Absolute Change (Spread)",
    x = "Absolute Change",
    y = "Drug"
  ) +
  theme_minimal()

# 
# vas_summary <- vas_data %>%
#   group_by(Drug) %>%
#   summarise(mean_effect = mean(AbsChange, na.rm = TRUE)) %>%
#   arrange(mean_effect)
# 
# vas_data %>%
#   group_by(Drug) %>%
#   summarise(mean_effect = mean(AbsChange, na.rm = TRUE)) %>%
#   arrange(mean_effect)

data <- data %>%
  mutate(
    Biomarker_type = case_when(
      grepl("Hunger|Appetite|Food Consumption", `Outcome name`, ignore.case = TRUE) ~ "VAS_Hunger",
      grepl("Satiety|Fullness", `Outcome name`, ignore.case = TRUE) ~ "VAS_Satiety",
      TRUE ~ Biomarker
    )
  )
table(data$Biomarker_type)

data <- data %>%
  filter(Biomarker_type != "VAS Scores")


hunger_data <- data %>%
  filter(Biomarker_type == "VAS_Hunger")


head(hunger_data)


ggplot(hunger_data, aes(x = AbsChange, y = Drug)) +
  geom_point(size = 3) +
  geom_vline(xintercept = 0, linetype = "dashed") +
  labs(
    title = "VAS Hunger - Absolute Change (Spread)",
    x = "Absolute Change",
    y = "Drug"
  ) +
  theme_minimal()

hunger_summary <- hunger_data %>%
  group_by(Drug) %>%
  summarise(mean_effect = mean(AbsChange, na.rm = TRUE)) %>%
  arrange(mean_effect)

hunger_summary

hunger_data %>%
  filter(Drug == "Tirzepatide") %>%
  select(`Outcome name`, AbsChange)

hunger_data <- data %>%
  filter(Biomarker_type == "VAS_Hunger") %>%
  filter(!grepl("Overall Appetite", `Outcome name`, ignore.case = TRUE))



hunger_summary <- hunger_data %>%
  group_by(Drug) %>%
  summarise(mean_effect = mean(AbsChange, na.rm = TRUE)) %>%
  arrange(mean_effect)

hunger_summary


hunger_data <- data %>%
  filter(Biomarker_type == "VAS_Hunger") %>%
  filter(!grepl("Overall Appetite", `Outcome name`, ignore.case = TRUE))


ggplot(hunger_data, aes(x = AbsChange, y = Drug)) +
  geom_point(size = 3) +
  geom_vline(xintercept = 0, linetype = "dashed") +
  labs(
    title = "VAS Hunger - Absolute Change (Spread)",
    x = "Absolute Change",
    y = "Drug"
  ) +
  theme_minimal()

ggplot(hunger_summary, aes(x = mean_effect, y = Drug)) +
  geom_point(size = 4, color = "blue") +
  geom_vline(xintercept = 0, linetype = "dashed") +
  labs(
    title = "VAS Hunger - Mean Effect",
    x = "Mean Absolute Change",
    y = "Drug"
  ) +
  theme_minimal()

hunger_dnr <- hunger_data %>%
  group_by(Drug) %>%
  summarise(mean_dnr = mean(`Dose Normalised rate`, na.rm = TRUE)) %>%
  arrange(mean_dnr)


hunger_dnr


ggplot(hunger_dnr, aes(x = mean_dnr, y = fct_reorder(Drug, mean_dnr))) +
  geom_point(size = 4, color = "red") +
  geom_vline(xintercept = 0, linetype = "dashed") +
  labs(
    title = "VAS Hunger - Mean Dose Normalised Rate",
    x = "Mean DNR",
    y = "Drug"
  ) +
  theme_minimal()


satiety_data <- data %>%
  filter(Biomarker_type == "VAS_Satiety")

satiety_data
unique(satiety_data$`Outcome name`)


ggplot(satiety_data, aes(x = AbsChange, y = Drug)) +
  geom_point(size = 3) +
  geom_vline(xintercept = 0, linetype = "dashed") +
  labs(
    title = "VAS Satiety - Absolute Change (Spread)",
    x = "Absolute Change",
    y = "Drug"
  ) +
  theme_minimal()


satiety_summary <- satiety_data %>%
  group_by(Drug) %>%
  summarise(mean_effect = mean(AbsChange, na.rm = TRUE)) %>%
  arrange(desc(mean_effect))

satiety_summary


ggplot(satiety_summary, aes(x = mean_effect, y = Drug)) +
  geom_point(size = 4, color = "blue") +
  geom_vline(xintercept = 0, linetype = "dashed") +
  labs(
    title = "VAS Satiety - Mean Effect",
    x = "Mean Absolute Change",
    y = "Drug"
  ) +
  theme_minimal()

satiety_dnr <- satiety_data %>%
  group_by(Drug) %>%
  summarise(mean_dnr = mean(`Dose Normalised rate`, na.rm = TRUE)) %>%
  arrange(desc(mean_dnr))   # IMPORTANT: descending

satiety_dnr


ggplot(satiety_dnr, aes(x = mean_dnr, y = Drug)) +
  geom_point(size = 4, color = "blue") +
  geom_vline(xintercept = 0, linetype = "dashed") +
  labs(
    title = "VAS Satiety - Mean Dose Normalised Rate",
    x = "Mean DNR",
    y = "Drug"
  ) +
  theme_minimal()


leptin_data <- data %>%
  filter(Biomarker == "Leptin")

head(leptin_data)

ggplot(leptin_data, aes(x = AbsChange, y = Drug)) +
  geom_point(size = 3) +
  geom_vline(xintercept = 0, linetype = "dashed") +
  labs(
    title = "Leptin - Absolute Change (Spread)",
    x = "Absolute Change",
    y = "Drug"
  ) +
  theme_minimal()

leptin_summary <- leptin_data %>%
  group_by(Drug) %>%
  summarise(mean_effect = mean(AbsChange, na.rm = TRUE)) %>%
  arrange(mean_effect)

leptin_summary

leptin_dnr <- leptin_data %>%
  group_by(Drug) %>%
  summarise(mean_dnr = mean(`Dose Normalised rate`, na.rm = TRUE)) %>%
  arrange(mean_dnr)

leptin_dnr

leptin_data %>%
  select(Drug, Unit, AbsChange)

leptin_clean <- leptin_data %>%
  filter(Drug != "Dulaglutide")


leptin_summary <- leptin_clean %>%
  group_by(Drug) %>%
  summarise(mean_effect = mean(AbsChange, na.rm = TRUE)) %>%
  arrange(mean_effect)

leptin_dnr <- leptin_clean %>%
  group_by(Drug) %>%
  summarise(mean_dnr = mean(`Dose Normalised rate`, na.rm = TRUE)) %>%
  arrange(mean_dnr)

leptin_summary
leptin_dnr

ggplot(leptin_clean, aes(x = AbsChange, y = Drug)) +
  geom_point(size = 3) +
  geom_vline(xintercept = 0, linetype = "dashed") +
  labs(
    title = "Leptin - Absolute Change (Spread)",
    x = "Absolute Change",
    y = "Drug"
  ) +
  theme_minimal()

ggplot(leptin_summary, aes(x = mean_effect, y = Drug)) +
  geom_point(size = 4, color = "blue") +
  geom_vline(xintercept = 0, linetype = "dashed") +
  labs(
    title = "Leptin - Mean Effect",
    x = "Mean Absolute Change",
    y = "Drug"
  ) +
  theme_minimal()

ggplot(leptin_dnr, aes(x = mean_dnr, y = Drug)) +
  geom_point(size = 4, color = "red") +
  geom_vline(xintercept = 0, linetype = "dashed") +
  labs(
    title = "Leptin - Mean Dose Normalised Rate",
    x = "Mean DNR",
    y = "Drug"
  ) +
  theme_minimal()

pyy_data <- data %>%
  filter(Biomarker == "PYY")

head(pyy_data)

ggplot(pyy_data, aes(x = AbsChange, y = Drug)) +
  geom_point(size = 3) +
  geom_vline(xintercept = 0, linetype = "dashed") +
  labs(
    title = "PYY - Absolute Change (Spread)",
    x = "Absolute Change",
    y = "Drug"
  ) +
  theme_minimal()

pyy_summary <- pyy_data %>%
  group_by(Drug) %>%
  summarise(mean_effect = mean(AbsChange, na.rm = TRUE)) %>%
  arrange(desc(mean_effect))   # IMPORTANT (positive = good)

pyy_summary

pyy_data %>%
  select(Drug, Unit, AbsChange)