# 01_load_clean.R
library(tidyverse)
library(readr)
library(readxl)
library(janitor)
library(lubridate)
library(future)
library(furrr)
library(tibble)

# Caminhos
bronze_dir <- "data/01_bronze_layer"

# Procura um ou mais CSVs de coffee_sales (permite escalonar no futuro)
files <- list.files(
  path = bronze_dir,
  pattern = "(?i)^coffee_sales.*\\.csv$",  # case-insensitive
  full.names = TRUE
)

if (length(files) == 0) {
  stop("Coloque ao menos um CSV em data/01_bronze_layer/ (ex.: coffee_sales.csv)")
}

# Leitura concorrente com future/furrr (multisession funciona no Windows/macOS/Linux)
plan(multisession, workers = max(1L, parallel::detectCores() - 1L))

read_one_csv <- function(p) {
  readr::read_csv(p, show_col_types = FALSE, progress = interactive())
}

raw <- furrr::future_map_dfr(files, read_one_csv, .options = furrr::furrr_options(seed = TRUE))

# Limpeza
df <- raw |>
  janitor::clean_names() |>
  rename(
    date        = date,
    product     = coffee_name,
    revenue     = money,
    time_of_day = time_of_day,
    weekday     = weekday,
    month_name  = month_name
  ) |>
  mutate(
    date        = as_date(date),
    qty         = 1,
    hour_of_day = suppressWarnings(as.integer(hour_of_day)),
    revenue     = suppressWarnings(as.numeric(revenue))
  ) |>
  drop_na(date, revenue)

# Reordena colunas
df <- df |>
  select(
    date, product, revenue, qty, cash_type, time_of_day,
    weekday, month_name, hour_of_day, everything()
  )

# Exporta para SILVER
dir.create("data/02_silver_layer", showWarnings = FALSE, recursive = TRUE)
write_csv(df, "data/02_silver_layer/coffee_sales_clean.csv")

message("SILVER salvo em data/02_silver_layer/coffee_sales_clean.csv")
