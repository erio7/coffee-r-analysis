library(tidyverse)
library(scales)

monthly_sales <- readr::read_csv("data/03_gold_layer/monthly_sales.csv", show_col_types = FALSE)

p <- ggplot(monthly_sales, aes(month, revenue)) +
  geom_line(linewidth = 1) +
  geom_point(size = 2) +
  scale_y_continuous(
    labels = scales::label_number(prefix = "R$ ", scale_cut = scales::cut_short_scale())
    # ou: labels = scales::label_currency(prefix = "R$ ", big.mark = ".", decimal.mark = ",")
  ) +
  labs(title = "Evolução mensal da receita", x = "Mês", y = "Receita") +
  theme_minimal(base_size = 12)

dir.create("reports", showWarnings = FALSE)
ggsave("reports/monthly_sales.png", p, width = 10, height = 5, dpi = 150)
message("✅ Gráfico salvo em reports/monthly_sales.png")
