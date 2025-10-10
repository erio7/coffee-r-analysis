# 01_load_clean.R
library(tidyverse)
library(readr)
library(readxl)
library(janitor)
library(lubridate)

# Caminhos
bronze_dir <- "data/01_bronze_layer"
cand <- c(
  file.path(bronze_dir, "coffee_sales.csv")
)
path_in <- cand[file.exists(cand)][1]
if (is.na(path_in)) stop("Coloque o arquivo em data/01_bronze_layer/ (coffee_sales.csv ou Coffe_sales.csv)")

# Leitura
if (grepl("\\.csv$", path_in, ignore.case = TRUE)) {
  raw <- readr::read_csv(path_in, show_col_types = FALSE)
} else {
  raw <- readxl::read_excel(path_in)
}

# Limpeza
df <- raw |>
  janitor::clean_names()

# Ajusta para o Coffe_sales.csv
df <- df |>
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
    qty         = 1,  # uma linha = uma transação
    hour_of_day = suppressWarnings(as.integer(hour_of_day)),
    revenue     = suppressWarnings(as.numeric(revenue))
  ) |>
  drop_na(date, revenue)

# Reordena colunas úteis
df <- df |>
  select(date, product, revenue, qty, cash_type, time_of_day,
         weekday, month_name, hour_of_day, everything())

# Exporta para SILVER
dir.create("data/02_silver_layer", showWarnings = FALSE, recursive = TRUE)
write_csv(df, "data/02_silver_layer/coffee_sales_clean.csv")

message("SILVER salvo em data/02_silver_layer/coffee_sales_clean.csv")
