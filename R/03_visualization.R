# ---- 03_visualization_themed.R (gera gráfico com tema de café) ----
library(tidyverse)
library(scales)

# --- 1. Definir o Tema de Café para o ggplot2 ---
theme_coffee <- function(base_size = 12, base_family = "Open Sans") {
  # Cores do tema (baseadas no index.html)
  color_primary <- "#6F4E37" # Marrom Café Escuro
  color_secondary <- "#A0522D" # Sienna
  color_background <- "#F5F5DC" # Bege Claro (Creme)
  color_text_dark <- "#2C2C2C"
  
  # Usando theme_minimal como base
  theme_minimal(base_size = base_size, base_family = base_family) +
    theme(
      # Fundo do gráfico
      plot.background = element_rect(fill = color_background, color = NA),
      panel.background = element_rect(fill = color_background, color = NA),
      
      # Título e subtítulo
      plot.title = element_text(color = color_primary, face = "bold", size = rel(1.4), margin = margin(b = 10)),
      plot.subtitle = element_text(color = color_text_dark, size = rel(1.1), margin = margin(b = 15)),
      
      # Eixos
      axis.title = element_text(color = color_secondary, face = "bold", size = rel(1.0)),
      axis.text = element_text(color = color_text_dark, size = rel(0.9)),
      axis.line = element_line(color = color_secondary),
      axis.ticks = element_line(color = color_secondary),
      
      # Grid lines
      panel.grid.major = element_line(color = "white", linewidth = 0.5),
      panel.grid.minor = element_line(color = "white", linewidth = 0.25),
      
      # Legenda
      legend.background = element_rect(fill = color_background, color = NA),
      legend.text = element_text(color = color_text_dark),
      legend.title = element_text(color = color_primary, face = "bold"),
      
      # Strip background (para facet_wrap/grid)
      strip.background = element_rect(fill = color_secondary, color = color_secondary),
      strip.text = element_text(color = "white", face = "bold")
    )
}

# --- 2. Carregar Dados ---
# O script está em R/, então o caminho é relativo à raiz do projeto
monthly_sales <- readr::read_csv("data/03_gold_layer/monthly_sales.csv", show_col_types = FALSE)

# --- 3. Gerar o Gráfico com o Novo Tema ---
p <- ggplot(monthly_sales, aes(x = month, y = revenue, group = 1)) + # group=1 para garantir a linha
  geom_line(color = "#A0522D", linewidth = 1.2) + # Cor da linha: Sienna
  geom_point(color = "#6F4E37", size = 3, fill = "#FFD700", shape = 21, stroke = 1) + # Cor do ponto: Marrom Escuro com contorno Dourado
  
  scale_y_continuous(
    labels = scales::label_number(prefix = "R$ ", big.mark = ".", decimal.mark = ",", scale_cut = scales::cut_short_scale())
  ) +
  
  labs(
    title = "Evolução Mensal da Receita de Vendas de Café",
    subtitle = "Análise de Tendência ao Longo do Tempo",
    x = "Mês", 
    y = "Receita (R$)"
  ) +
  
  theme_coffee(base_family = "sans") # Aplicar o tema de café

# --- 4. Salvar o Gráfico ---
dir.create("reports", showWarnings = FALSE)
ggsave("reports/monthly_sales.png", p, width = 10, height = 5, dpi = 300) # Aumentei o DPI para melhor qualidade
message("Gráfico salvo em reports/monthly_sales.png")
