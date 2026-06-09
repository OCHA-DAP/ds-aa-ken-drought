# Install R package dependencies for ds-aa-ken-drought
# Run this script once before executing spi_compute.R

# CRAN packages
install.packages(c(
  "DBI",
  "SPEI",
  "tidyverse",
  "sf"
))

# OCHA-DAP GitHub packages
if (!requireNamespace("remotes", quietly = TRUE)) install.packages("remotes")
remotes::install_github("OCHA-DAP/cumulus")
remotes::install_github("OCHA-DAP/gghdx")
