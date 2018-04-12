library(tibbletime)
library(readr)

parameters <- read_rds("data/cleaned/parameters/parameters.rds")

parameters_monthly <- parameters %>%
  as_tbl_time(date) %>%
  arrange(date) %>% 
  as_period("monthly", side = "end")

write_rds(parameters_monthly, "data/cleaned/parameters/parameters_monthly.rds")
