library(readr)
library(ratekit)
library(purrr)
library(tidyr)
library(dplyr)

parameters_monthly <- read_rds("data/cleaned/parameters/parameters_monthly.rds")

generate_spot_rates <- with(parameters_monthly, spot_rate_factory(BETA0, BETA1, BETA2, BETA3, TAU1, TAU2))
generate_zero_prices <- zero_bond_price_factory(generate_spot_rates)

maturity_nm <- c("1/12", "1/4", "1-1/12", "1", "2", "3-1/12", "3", "5-1/12", "5", "7-1/12", "7", "8", "10-1/12", "10")
maturity <- c(1/12, 1/4, 1 - 1/12, 1, 2, 3 - 1/12, 3, 5 - 1/12, 5, 7 - 1/12, 7, 8, 10 - 1/12, 10)

mat_tbl <- tibble(maturity, maturity_nm)

nested_rates_and_prices <- mat_tbl %>%
  mutate(
    # For each maturity, calculate the series of spot rates and zero prices
    # using the parameters from the Fed paper
    rates_and_prices = map(
      .x = maturity, 
      .f = ~{
        tibble(date = parameters_monthly$date, 
               spot_rate = generate_spot_rates(.x),
               zero_price = generate_zero_prices(.x)
               )
      })
  )
  
# library(ggplot2)
# nested_rates_and_prices %>%
#   filter(maturity_nm == "1") %>%
#   unnest() %>%
#   ggplot(aes(x = date, y = spot_rate)) +
#   geom_line()

unnested_rates_and_prices <- unnest(nested_rates_and_prices)

rates <- select(unnested_rates_and_prices, -zero_price)
prices <- select(unnested_rates_and_prices, -spot_rate)

write_rds(rates, "data/computed/rates.rds")
write_rds(prices, "data/computed/prices.rds")
