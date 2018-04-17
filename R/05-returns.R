library(readr)
library(ratekit)
library(purrr)
library(tidyr)
library(dplyr)

rates_and_prices <- read_rds("data/computed/rates_and_prices.rds")

# Returns are only for a specific number of n-year's
n <- c("1", "3", "5", "7", "10")
n_delta <- paste0(n, "-1/12")

# ------------------------------------------------------------------------------
# P_t(n)
prices_n <- rates_and_prices %>% 
  filter(maturity_nm %in% n) %>% 
  unnest() %>%
  select(-spot_rate)

# P_{t+delta}(n - delta)
prices_n_delta <- rates_and_prices %>% 
  filter(maturity_nm %in% n_delta) %>% 
  mutate(maturity_nm_base = n) %>% 
  unnest() %>%
  select(-spot_rate, -maturity) %>%
  rename(maturity_nm_delta = maturity_nm, zero_price_delta = zero_price)

# Join the prices for n-years with the prices for (n-delta)-years
prices <- left_join(prices_n, prices_n_delta, by = c("maturity_nm" = "maturity_nm_base", "date" = "date"))

# ------------------------------------------------------------------------------
# RET_{t+delta}(n) for each n-year
# RET_n is the 1 month return on the n year bond
returns <- prices %>%
  group_by(maturity_nm) %>%
  mutate(
    zero_price_lag = lag(zero_price),
    RET_n = zero_price_delta / zero_price_lag - 1
  ) %>%
  ungroup() %>%
  select(maturity_nm, date, RET_n)

# ------------------------------------------------------------------------------
# Repeat the calculation for benchmark returns
prices_bench <- filter(rates_and_prices, maturity_nm %in% "1/12")

# RET_{t+delta}(delta)
# Here, P_{t+delta}(0) = 1
returns_bench <- prices_bench %>%
  unnest() %>%
  mutate(
    zero_price_lag = lag(zero_price),
    RET_n_bench = 1 / zero_price_lag - 1
  ) %>%
  select(date, RET_n_bench)

# ------------------------------------------------------------------------------

# ER_{t+delta}(n)
# 1 month excess returns over the 1 month treasury
excess_returns <- returns %>%
  left_join(returns_bench, by = "date") %>%
  mutate(ER_n = RET_n - RET_n_bench) %>%
  select(maturity_nm, date, ER_n)

# ------------------------------------------------------------------------------

write_rds(returns, "data/computed/returns.rds")
write_rds(excess_returns, "data/computed/excess_returns.rds")
