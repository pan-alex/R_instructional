# This is the data generation script for the exercise in analyzing cooties survival.


library(tidyverse)
library(lubridate)


set.seed(1)
n <- 1000


# Generate birthdates in a skewed distribution
# (Birthdates are being used instead of age for the sake of inconvenience--
# it is an exercise to convert birthdays to age.
trial_entrance = sample(
    seq(as.Date('2010-01-01'), as.Date('2012-12-30'),
        by = 'day'), n)
sample_age <- rpois(n, 8)    # Age is not actually Poisson distributed but these are just convenient numbers
dob_year <- as.integer(year(trial_entrance) - sample_age)
dob_month_text <- sample(month.name, n, replace = T)
dob_day <- sample(c(1, 28), n, replace = T)    # No one is born on the 29th-31st because that would be too much work
dob_text <- paste(dob_month_text, dob_day, dob_year, sep = ' ')


dob_day_num <- sample(seq(1, 28), n, replace = T)
dob_month_num <- match(dob_month_text, month.name)
dob <- paste(dob_month_num, dob_day_num, dob_year, sep = '/')

# Generate data
cooties <- data.frame(
    id = seq(1, n),
    sex = sample(c(1, 0), n, replace = T),    # 1 is Male
    date_of_birth = dob_text,
    age_continuous = sample_age,
    treatment_arm = sample(c(1, 0), n, replace = T),    # 1 is Cooticure
    trial_entrance = sample(
        seq(as.Date('2010-01-01'), as.Date('2012-12-30'),
                    by = 'day'), n)
)

# Generate survival in days
# Survival is a function of treatment arm, age, and sex, based on a logistic
# function
# A portion of samples are also tagged as being censored to simulate dropouts


# The data are currently modeled with a random chance of dying based on a normal distribution.
# A better way to model this is to model time to death with an exponential distribution, and then randomly censor some individuals

modifier <- (0.2 * cooties$age_continuous 
           + 1.0 * cooties$sex
           - 3.0 * cooties$treatment_arm
           + 0.05 * cooties$age_continuous*cooties$treatment_arm)

# s <- rnorm(n, mean = modifier, sd = abs(mean(modifier) / 2))
# prob_of_death <- 1 / (1 + exp(-s))

t <- rexp(n, rate= (1 
                    + 0.01 * cooties$age_continuous
                    + 0.5 * cooties$sex
                    - 3 * cooties$treatment_arm
                    + 0.05 * cooties$age_continuous*cooties$treatment_arm))
hist(t)

cooties_new <- cooties %>%
  mutate()


cooties <- cooties %>%
    mutate(death = runif(n, 0, 1) < prob_of_death,
           trial_exit = trial_entrance + as.integer(abs(rnorm(n, mean = 1095, sd = 800))),
           trial_exit = if_else(trial_exit > min(trial_exit) + 1826,    # 5 years
                                min(trial_exit) + 1826, trial_exit)) %>%
    select(-age_continuous)

cooties <- mutate(cooties, days_in_trial = as.numeric(trial_exit - trial_entrance))

survival <- survfit(
  Surv(time = days_in_trial / 365.25, event = death) ~ treatment_arm,
  data = cooties)

ggsurvplot(survival,
           linetype = 'strata',
           conf.int = T,
           pval = T)



write_csv(cooties, 'cooties_data.csv')
