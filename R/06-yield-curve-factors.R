# Forming the three yield curve factors, level slope and curvature

library(readr)
library(ratekit)
library(purrr)
library(tidyr)
library(dplyr)

rates_and_prices <- read_rds("data/computed/rates_and_prices.rds")

n <- c("1/4", "2", "8")

factor_rates <- rates_and_prices %>% 
  filter(maturity_nm %in% n) %>%
  unnest() %>%
  select(-zero_price, -maturity) %>%
  spread(maturity_nm, spot_rate)

yield_curve_factors <- factor_rates %>%
  mutate(
    level = `1/4`,
    slope = `8` - `1/4`,
    curvature = (`8` - `2`) - (`2` - `1/4`)
  ) %>%
  select(date, level, slope, curvature)


write_rds(yield_curve_factors, "data/computed/yield_curve_factors.rds")