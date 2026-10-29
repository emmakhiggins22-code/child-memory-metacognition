library(tidyverse)
library(readxl)
library(lme4)

cued_recall <- read_excel("Cued_Recall_Datafile.xlsx", sheet = "Full_Dataset")

acc_by_age <- cued_recall %>% 
  mutate(age_label = factor(age_grp, levels = c(1,2,3), 
                            labels = c("5-6 yrs", "7-8 yrs", "9-11 yrs"))) %>% 
  group_by(age_label) %>% 
  summarise(mean_acc = mean(Acc), n = n())
         
ggplot(acc_by_age, aes(x = age_label, y = mean_acc)) + 
  geom_col(fill = "lightblue3") + 
  labs(x = "Age Group", y = "Mean Accuracy", title = "Cued-recall accuracy by age group") + 
  theme_classic()

ggsave("plots/accuracy_by_age.png", width = 6, height = 4)

acc_by_confidence <- cued_recall %>% 
  filter(DK == 0) %>% 
  mutate(age_label = factor(age_grp, levels = c(1,2,3), 
                            labels = c("5-6 yrs", "7-8 yrs", "9-11 yrs"))) %>% 
  group_by(age_label, Confidence) %>% 
  summarise(mean_acc = mean(Acc), n = n())

ggplot(acc_by_confidence, aes(x = Confidence, y = mean_acc, color = age_label)) +
  geom_line() +
  geom_point() +
  labs(x = "Confidence rating", y = "Mean accuracy",
       title = "Confidence-accuracy calibration by age group",
       color = "Age group") +
  theme_classic()

ggsave("plots/confidence_calibration.png", width = 6, height = 4)

# Mixed-effects logistic regression:
# does confidence predict accuracy, and does age add anything beyond confidence?
# Random intercept for each child to account for repeated measures
model <- glmer(Acc ~ Confidence + age_grp + (1 | ppt),
               data = cued_recall %>% filter(DK == 0),
               family = binomial)

summary(model)
exp(fixef(model))  # odds ratios
