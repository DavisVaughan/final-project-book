library(ratekit)

# IMPORTANT) The data has been downloaded, converted to xlsx and then the 
# original xls file was deleted. Github does not allow files >100mb to be 
# uploaded, and the xls file was 104mb. It does not matter, as we only use
# the xls. The commented out code is included for completeness so someone
# can recreate this

# download_rates_xls(dest = "data/raw/feds200628.xls")

# Now make sure to go and open the xls file with Excel, and resave it as
# an xlsx in the same location with the same name (feds200628.xlsx)