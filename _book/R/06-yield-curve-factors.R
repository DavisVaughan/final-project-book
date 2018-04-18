# Forming the three yield curve factors, level slope and curvature

library(readr)
library(ratekit)
library(purrr)
library(tidyr)
library(dplyr)

rates <- read_rds("data/computed/rates.rds")

n <- c("1/4", "2", "8")

factor_rates <- rates %>% 
  filter(maturity_nm %in% n) %>%
  select(-maturity) %>%
  spread(maturity_nm, spot_rate)

yield_curve_factors <- factor_rates %>%
  mutate(
    level = `1/4`,
    slope = `8` - `1/4`,
    curvature = (`8` - `2`) - (`2` - `1/4`)
  ) %>%
  select(date, level, slope, curvature)


write_rds(yield_curve_factors, "data/computed/yield_curve_factors.rds")
