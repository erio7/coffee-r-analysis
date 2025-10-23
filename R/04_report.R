# ---- 04_report.R (gera HTML direto, sem rmarkdown/pandoc) ----
library(readr)
library(dplyr)
library(scales)

# caminhos
gold_dir <- "data/03_gold_layer"
rep_dir  <- "reports"
if (!dir.exists(rep_dir)) dir.create(rep_dir, recursive = TRUE)

# lê saídas do GOLD
kpis         <- read_csv(file.path(gold_dir, "kpis.csv"), show_col_types = FALSE)
monthly      <- read_csv(file.path(gold_dir, "monthly_sales.csv"), show_col_types = FALSE)
top_products <- read_csv(file.path(gold_dir, "top_products.csv"), show_col_types = FALSE)
by_payment   <- read_csv(file.path(gold_dir, "by_payment.csv"), show_col_types = FALSE)

# helper: df -> <table> HTML
df_to_table <- function(df, caption = NULL) {
  thead <- paste0("<tr>", paste(sprintf("<th>%s</th>", names(df)), collapse = ""), "</tr>")
  fmt <- function(x) { if (is.numeric(x)) number(x, big.mark = ".", decimal.mark = ",") else as.character(x) }
  rows <- apply(df, 1, function(r) paste0("<tr>", paste(sprintf("<td>%s</td>", mapply(fmt, r)), collapse = ""), "</tr>"))
  tab <- paste0(
    "<table style='border-collapse:collapse;width:100%;margin:12px 0'>",
    if (!is.null(caption)) sprintf("<caption style='text-align:left;font-weight:600;margin-bottom:6px'>%s</caption>", caption) else "",
    "<thead style='background:#f4f4f4'>", thead, "</thead>",
    "<tbody>", paste(rows, collapse = ""), "</tbody>",
    "</table>"
  )
  gsub("<(th|td)>", "<\\1 style='border:1px solid #ddd;padding:6px'>", tab)
}

# garante gráfico gerado (03_visualization.R)
plot_file <- "monthly_sales.png"                                # <- nome do arquivo (sem 'reports/')
plot_path_fs <- file.path(rep_dir, plot_file)                   # caminho no FS para validar existência
plot_tag  <- if (file.exists(plot_path_fs)) {
  sprintf("<img src='%s' style='max-width:100%%;height:auto;border:1px solid #ddd;border-radius:6px'/>", plot_file)
} else {
  "<p style='color:#b00'>[Aviso] Rodar primeiro: source(\"R/03_visualization.R\") para gerar o gráfico.</p>"
}

# KPIs bonitinhos
kpi_card <- function(label, value) {
  sprintf(
    "<div style='flex:1;padding:14px;border:1px solid #ddd;border-radius:10px;margin-right:10px'>
       <div style='font-size:12px;color:#666'>%s</div>
       <div style='font-size:20px;font-weight:700'>%s</div>
     </div>",
    label, value
  )
}
kpi_html <- paste0(
  "<div style='display:flex;gap:10px;margin:10px 0'>",
  kpi_card("Receita total", paste0("R$ ", number(kpis$kpi_total_revenue, big.mark=".", decimal.mark=","))),
  kpi_card("Transações", format(kpis$kpi_total_tx, big.mark=".")),
  kpi_card("Ticket médio", paste0("R$ ", number(kpis$kpi_ticket_medio, big.mark=".", decimal.mark=","))),
  "</div>"
)

# monta HTML
html <- paste(
"<!DOCTYPE html>",
"<html lang='pt-br'><head><meta charset='utf-8'/>",
"<title>Análise de Vendas de Café</title>",
"<style>body{font-family:Segoe UI, Arial;max-width:980px;margin:32px auto;padding:0 16px;color:#222} h1,h2{margin:12px 0}</style>",
"</head><body>",
"<h1>Análise de Vendas de Café</h1>",
kpi_html,
"<h2>Evolução mensal da receita</h2>",
plot_tag,
df_to_table(monthly |> mutate(revenue = paste0("R$ ", number(revenue, big.mark=".", decimal.mark=","))),
            "Receita mensal (tabela)"),
"<h2>Top 5 produtos por receita</h2>",
df_to_table(top_products |> mutate(revenue = paste0("R$ ", number(revenue, big.mark=".", decimal.mark=",")))),
"<h2>Receita por forma de pagamento</h2>",
df_to_table(by_payment |> mutate(revenue = paste0("R$ ", number(revenue, big.mark=".", decimal.mark=",")))),
"<hr/><div style='color:#888;font-size:12px'></div>",
"</body></html>",
sep = "\n"
)

out_file <- file.path(rep_dir, "coffee_sales_report.html")
writeLines(html, out_file, useBytes = TRUE)
message("✅ Relatório gerado em: ", normalizePath(out_file))
if (interactive()) utils::browseURL(out_file)
