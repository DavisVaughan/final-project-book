library(ratekit)
library(dplyr)
library(readr)
library(visdat)
library(purrr)

# ------------------------------------------------------------------------------
# Rates data cleaning

raw <- read_rates("data/raw/feds200628.xlsx")

## Visualize the dataset - many missing data points!
# vis_dat(raw, warn_large_data = FALSE)

## Separate into multiple series
zero_coupon_yield     <- select(raw, date, contains("SVENY"))
par_yield             <- select(raw, date, contains("SVENPY"))
instant_forward_rate  <- select(raw, date, contains("SVENF"))
one_year_forward_rate <- select(raw, date, contains("SVENF1"))
parameters            <- select(raw, date, contains("BETA"), contains("TAU"))

## Clean the parameters dataset further, since this contains the values needed for the project

## Every TAU2 param past 9544 is NA
# is_na_param <- which(is.na(parameters$TAU2))
parameters <- parameters %>% na.omit()

# Save all series
series <- list_named(zero_coupon_yield, par_yield, instant_forward_rate, one_year_forward_rate)
iwalk(series, ~write_rds(.x, paste0("data/cleaned/rates-yields/", .y, ".rds")))

# Save parameters
write_rds(parameters, "data/cleaned/parameters/parameters.rds")

# ------------------------------------------------------------------------------
# Meta data cleaning

raw_meta <- read_rates_meta_data("data/raw/feds200628.xlsx")

clean_meta <- raw_meta %>%
  rename(series = Series,
         compounding_convention = `Compounding Convention`,
         key = `Mnemonic(s)`)

write_rds(clean_meta, "data/cleaned/meta/meta.rds")
