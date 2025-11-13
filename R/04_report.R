# ---- 04_report.R (gera HTML aprimorado) ----
library(readr)
library(dplyr)
library(scales)

# caminhos
# O script R está sendo executado a partir da raiz do projeto, então os caminhos são relativos à raiz.
gold_dir <- "data/03_gold_layer"
rep_dir  <- "reports"
if (!dir.exists(rep_dir)) dir.create(rep_dir, recursive = TRUE)

# lê saídas do GOLD
# O usuário deve garantir que esses arquivos existam.
kpis         <- read_csv(file.path(gold_dir, "kpis.csv"), show_col_types = FALSE)
monthly      <- read_csv(file.path(gold_dir, "monthly_sales.csv"), show_col_types = FALSE)
top_products <- read_csv(file.path(gold_dir, "top_products.csv"), show_col_types = FALSE)
by_payment   <- read_csv(file.path(gold_dir, "by_payment.csv"), show_col_types = FALSE)

# Função de formatação para valores monetários e numéricos
fmt_currency <- function(x) paste0("R$ ", number(x, big.mark = ".", decimal.mark = ",", accuracy = 0.01))
# Corrigido para usar number() do scales, eliminando o warning de formatação
fmt_number <- function(x) number(x, big.mark = ".", decimal.mark = ",", accuracy = 1)

# helper: df -> <table> HTML (Aprimorada para usar as classes CSS)
df_to_table <- function(df, caption = NULL) {
  # Aplica formatação de moeda nas colunas que contêm "revenue"
  df_formatted <- df %>%
    mutate(across(contains("revenue"), fmt_currency)) %>%
    mutate(across(contains("tx"), fmt_number)) # Aplica formatação de número em colunas com "tx"

  thead <- paste0("<tr>", paste(sprintf("<th>%s</th>", names(df_formatted)), collapse = ""), "</tr>")
  
  rows <- apply(df_formatted, 1, function(r) paste0("<tr>", paste(sprintf("<td>%s</td>", r), collapse = ""), "</tr>"))
  
  tab <- paste0(
    "<table class='data-table'>",
    if (!is.null(caption)) sprintf("<caption>%s</caption>", caption) else "",
    "<thead>", thead, "</thead>",
    "<tbody>", paste(rows, collapse = ""), "</tbody>",
    "</table>"
  )
  return(tab)
}

# garante gráfico gerado (03_visualization.R)
plot_file <- "monthly_sales.png"
plot_path_fs <- file.path(rep_dir, plot_file)                   # caminho no FS para validar existência
plot_tag  <- if (file.exists(plot_path_fs)) {
  # O caminho da imagem no HTML deve ser relativo ao arquivo HTML de saída (reports/)
  sprintf("<img src='%s' alt='Gráfico de Evolução Mensal da Receita'/>", plot_file)
} else {
  "<p class='warning-message'>[Aviso] Rodar primeiro: source(\"R/03_visualization.R\") para gerar o gráfico.</p>"
}

# KPIs bonitinhos (Aprimorada para usar as classes CSS)
kpi_card <- function(label, value) {
  sprintf(
    "<div class='kpi-card'>
       <div class='kpi-label'>%s</div>
       <div class='kpi-value'>%s</div>
     </div>",
    label, value
  )
}

kpi_html <- paste0(
  "<div class='kpi-container'>",
  kpi_card("Receita total", fmt_currency(kpis$kpi_total_revenue)),
  kpi_card("Transações", fmt_number(kpis$kpi_total_tx)),
  kpi_card("Ticket médio", fmt_currency(kpis$kpi_ticket_medio)),
  "</div>"
)

# Conteúdo do HTML (separado para melhor legibilidade)
html_content <- paste(
  "<!-- Seção de KPIs -->",
  "<h2>Indicadores Chave de Performance (KPIs)</h2>",
  kpi_html,
  
  "<!-- Seção de Gráfico -->",
  "<h2>Evolução Mensal da Receita</h2>",
  "<div class='chart-section'>",
  plot_tag,
  "</div>",
  
  "<!-- Seção de Tabelas -->",
  "<h2>Receita Mensal (Tabela)</h2>",
  df_to_table(monthly, "Receita mensal detalhada"),
  
  "<h2>Top 5 Produtos por Receita</h2>",
  df_to_table(top_products),
  
  "<h2>Receita por Forma de Pagamento</h2>",
  df_to_table(by_payment),
  
  sep = "\n"
)

# Monta o HTML final, lendo o template do diretório R/
html_template_path <- "R/index.html" # O template HTML está em R/index.html
html_template <- readLines(html_template_path)

# Encontra a linha onde o conteúdo deve ser injetado (após a tag <div class="container">)
container_start_line <- grep("<div class=\"container\">", html_template)
# Encontra a linha onde o conteúdo deve ser injetado (antes da tag </div> que fecha o container)
container_end_line <- grep("</footer>", html_template) - 1

# Injeta o conteúdo gerado pelo R dentro do container
html_final <- c(
  html_template[1:container_start_line],
  html_content,
  html_template[container_end_line:length(html_template)]
)

# Monta o HTML final
html <- paste(html_final, collapse = "\n")

out_file <- file.path(rep_dir, "coffee_sales_report.html")
writeLines(html, out_file, useBytes = TRUE)
message("✅ Relatório aprimorado gerado em: ", normalizePath(out_file))
# if (interactive()) utils::browseURL(out_file)
