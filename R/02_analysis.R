# ---- 02_analysis.R ----
library(tidyverse)
library(lubridate)
library(readr)

path_silver <- "data/02_silver_layer/coffee_sales_clean.csv"
stopifnot(file.exists(path_silver))

df <- readr::read_csv(path_silver, show_col_types = FALSE)

# KPIs principais
kpi_total_revenue <- sum(df$revenue, na.rm = TRUE)
kpi_total_tx      <- nrow(df)                 # nº de transações
kpi_ticket_medio  <- ifelse(kpi_total_tx > 0, kpi_total_revenue / kpi_total_tx, NA_real_)

# Receita mensal
monthly_sales <- df |>
  mutate(month = floor_date(date, "month")) |>
  group_by(month) |>
  summarise(revenue = sum(revenue, na.rm = TRUE),
            tx      = n(), .groups = "drop") |>
  arrange(month)

# Top produtos por receita
top_products <- df |>
  group_by(product) |>
  summarise(revenue = sum(revenue, na.rm = TRUE),
            tx      = n(), .groups = "drop") |>
  arrange(desc(revenue)) |>
  slice_head(n = 5)

# Receita por forma de pagamento
by_payment <- df |>
  group_by(cash_type) |>
  summarise(revenue = sum(revenue, na.rm = TRUE),
            tx      = n(), .groups = "drop") |>
  arrange(desc(revenue))

# Grava GOLD
dir.create("data/03_gold_layer", showWarnings = FALSE, recursive = TRUE)
write_csv(monthly_sales, "data/03_gold_layer/monthly_sales.csv")
write_csv(top_products,  "data/03_gold_layer/top_products.csv")
write_csv(by_payment,    "data/03_gold_layer/by_payment.csv")
write_csv(tibble(
  kpi_total_revenue, kpi_total_tx, kpi_ticket_medio
), "data/03_gold_layer/kpis.csv")

message("✅ GOLD gerado em data/03_gold_layer/")
