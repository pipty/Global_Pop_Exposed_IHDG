# Public workflow skeleton for the IHDG analysis.
#
# This file intentionally provides the main analytical framework rather than
# the internal project scripts. Replace placeholder paths with local copies of
# appropriately licensed datasets before running.

library(dplyr)
library(tidyr)
library(sf)
library(terra)
library(exactextractr)
library(broom)
library(ggplot2)

# ---------------------------------------------------------------------------
# 1. Configure paths and inputs
# ---------------------------------------------------------------------------

config <- list(
  years = 2000:2022,
  grid_path = "data/populated_grid/populated_grid.gpkg",
  population_path = "data/population/population_by_grid_year.csv",
  greenness_dir = "data/greenness/annual_ndvi/",
  heat_dir = "data/heat/annual_utci/",
  country_lookup_path = "data/lookups/country_income_region.csv",
  output_dir = "outputs/"
)

dir.create(config$output_dir, showWarnings = FALSE, recursive = TRUE)

# ---------------------------------------------------------------------------
# 2. Load analysis grid and demographic attributes
# ---------------------------------------------------------------------------

grid <- st_read(config$grid_path, quiet = TRUE)
population <- read.csv(config$population_path)
country_lookup <- read.csv(config$country_lookup_path)

grid_attributes <- grid %>%
  st_drop_geometry() %>%
  select(grid_id, country_code, urbanicity = any_of("urbanicity"))

# ---------------------------------------------------------------------------
# 3. Extract annual heat and greenness to populated grid cells
# ---------------------------------------------------------------------------

extract_indicator <- function(year, indicator_dir, value_name) {
  raster_path <- file.path(indicator_dir, paste0(value_name, "_", year, ".tif"))
  raster_layer <- terra::rast(raster_path)

  extracted <- exactextractr::exact_extract(raster_layer, grid, "mean")

  tibble(
    grid_id = grid$grid_id,
    year = year,
    value = extracted
  ) %>%
    rename(!!value_name := value)
}

annual_indicators <- lapply(config$years, function(year) {
  ndvi <- extract_indicator(year, config$greenness_dir, "ndvi")
  utci <- extract_indicator(year, config$heat_dir, "utci")

  ndvi %>%
    inner_join(utci, by = c("grid_id", "year"))
}) %>%
  bind_rows()

# ---------------------------------------------------------------------------
# 4. Estimate grid-level long-term trends
# ---------------------------------------------------------------------------

estimate_trend <- function(data, outcome) {
  data %>%
    group_by(grid_id) %>%
    do({
      model_data <- .
      fit <- lm(stats::as.formula(paste(outcome, "~ year")), data = model_data)
      broom::tidy(fit)
    }) %>%
    ungroup() %>%
    filter(term == "year") %>%
    transmute(
      grid_id,
      !!paste0(outcome, "_slope") := estimate,
      !!paste0(outcome, "_p_value") := p.value
    )
}

ndvi_trends <- estimate_trend(annual_indicators, "ndvi")
utci_trends <- estimate_trend(annual_indicators, "utci")

trend_classification <- ndvi_trends %>%
  inner_join(utci_trends, by = "grid_id") %>%
  mutate(
    heat_increasing = utci_slope > 0,
    greenness_decreasing = ndvi_slope < 0,
    ihdg = heat_increasing & greenness_decreasing,
    trend_group = case_when(
      ihdg ~ "Increasing heat and decreasing greenness",
      heat_increasing & !greenness_decreasing ~ "Increasing heat and non-decreasing greenness",
      !heat_increasing & greenness_decreasing ~ "Non-increasing heat and decreasing greenness",
      TRUE ~ "Other"
    )
  )

# ---------------------------------------------------------------------------
# 5. Join population and summarize exposed population
# ---------------------------------------------------------------------------

exposure_by_grid_year <- population %>%
  inner_join(trend_classification, by = "grid_id") %>%
  left_join(grid_attributes, by = "grid_id") %>%
  left_join(country_lookup, by = "country_code")

summary_by_country <- exposure_by_grid_year %>%
  group_by(country_code, country_name, year, ihdg) %>%
  summarise(population = sum(population, na.rm = TRUE), .groups = "drop")

summary_by_income <- exposure_by_grid_year %>%
  group_by(income_group, year, ihdg) %>%
  summarise(population = sum(population, na.rm = TRUE), .groups = "drop")

summary_by_urbanicity <- exposure_by_grid_year %>%
  group_by(urbanicity, year, ihdg) %>%
  summarise(population = sum(population, na.rm = TRUE), .groups = "drop")

write.csv(summary_by_country, file.path(config$output_dir, "summary_by_country.csv"), row.names = FALSE)
write.csv(summary_by_income, file.path(config$output_dir, "summary_by_income.csv"), row.names = FALSE)
write.csv(summary_by_urbanicity, file.path(config$output_dir, "summary_by_urbanicity.csv"), row.names = FALSE)

# ---------------------------------------------------------------------------
# 6. Example publication-style plot
# ---------------------------------------------------------------------------

plot_data <- summary_by_income %>%
  filter(ihdg) %>%
  group_by(income_group) %>%
  summarise(population = mean(population, na.rm = TRUE), .groups = "drop")

ggplot(plot_data, aes(x = reorder(income_group, population), y = population)) +
  geom_col(fill = "#4A7C59") +
  coord_flip() +
  labs(x = NULL, y = "Population exposed to IHDG", title = "Exposure by income group") +
  theme_classic()

ggsave(file.path(config$output_dir, "example_exposure_by_income_group.png"), width = 7, height = 4)
