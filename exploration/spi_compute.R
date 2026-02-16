# R script to compute SPI

# install.packages("devtools")
#devtools::install_github("OCHA-DAP/cumulus")

library(cumulus)
library(DBI)
library(SPEI)
library(tidyverse)
library(sf)
library(gghdx)
gghdx()
arid_counties <- c(
  "Turkana",
  "Marsabit",
  "Mandera",
  "Wajir",
  "Garissa",
  "Tana River",
  "Isiolo",
  "Samburu",
  "Baringo"
)
con_prod <- pg_con(stage = "prod")

dbListTables(con_prod)

# read the table era5 for iso3 KEN 
era5 <- dbGetQuery(
  con_prod,
  "
  SELECT *
  FROM era5
  WHERE iso3 = 'KEN'
  "
)
# load ken codab
ken_codab <- download_shapefile("https://data.fieldmaps.io/cod/extended/ken.gpkg.zip", layer = "ken_adm2")
# only using the codab file to get the names of counties
# dissolve codab file into adm1
ken_codab <- ken_codab$ken_adm2 |> 
  group_by(adm1_src, adm1_name) |> 
  summarise(geom = st_union(geom)) |> 
  ungroup()

era5_summary <- era5 |>
  mutate(days_in_month = days_in_month(valid_date), 
         monthly_rainfall = median * days_in_month, 
         year = year(valid_date))


# merge era5 summary with ken codab 
ken_spi <- ken_codab |> 
  left_join(era5_summary, by = c("adm1_src" = "pcode")) |> 
  filter(adm1_name %in% arid_counties) |>
  group_by(adm1_src, adm1_name) |> 
  arrange(valid_date) |>
  mutate(
    spi1 = spi(monthly_rainfall, 1, distribution = "Gamma")$fitted,
    spi3 = spi(monthly_rainfall, 3, distribution = "Gamma")$fitted
  ) |>
  ungroup()

ken_spi_ond <- ken_spi |>
  filter(month(valid_date) %in% 10:12)

ond_spi <- ken_spi |>
  filter(month(valid_date) == 12) |>
  mutate(year = year(valid_date)) |>
  group_by(year) |>
  summarise(spi3 = median(spi3, na.rm = TRUE)) |>
  ungroup()

ggplot(ond_spi, aes(x = factor(year), y = spi3)) +
  annotate("rect", xmin = -Inf, xmax = Inf, ymin = -0.43, ymax = 0,
           fill = "#fde0dd", alpha = 0.35) +
  annotate("rect", xmin = -Inf, xmax = Inf, ymin = -0.84, ymax = -0.43,
           fill = "#f9b4b0", alpha = 0.35) +
  geom_col(aes(fill = spi3), width = 0.7) +
  geom_text(
    aes(label = round(spi3, 2)),
    vjust = ifelse(ond_spi$spi3 >= 0, -0.3, 1.2),
    size = 3,
    fontface = "bold",
    colour = "black"
  ) +
  geom_hline(yintercept = 0, linewidth = 0.6) +
  geom_hline(yintercept = c(-0.43, -0.84),
             linetype = "dashed", linewidth = 0.5) +
  scale_fill_gradient2(
    low = "#c0392b",
    mid = "#ecf0f1",
    high = "#2980b9",
    midpoint = 0,
    guide = "none"
  ) +
  labs(
    title = paste("OND SPI-3 | Median SPI for All Arid Counties"),
    subtitle = "Bars show Oct-Dec SPI-3 computed from ERA5 rainfall data for all arid counties. Shaded areas indicate drought severity thresholds.",
    x = "Year",
    y = "SPI-3"
  ) +
  theme_minimal(base_size = 13) +
  theme(
    axis.text.x = element_text(angle = 90, vjust = 0.5),
    panel.grid.minor = element_blank(),
    panel.grid.major.x = element_blank(),
    plot.title = element_text(face = "bold")
  )

# return period
# less than -0.43
yr_len <- max(ond_spi$year, na.rm = TRUE) - min(ond_spi$year, na.rm = TRUE) + 1
yr_len / sum(ond_spi$spi3 <= -0.43, na.rm = TRUE)
# less than -0.84
yr_len / sum(ond_spi$spi3 <= -0.84, na.rm = TRUE)
# events between -0.43 and -0.84
yr_len / sum(ond_spi$spi3 < -0.43 & ond_spi$spi3 > -0.84, na.rm = TRUE)

