# ☕ Coffee Sales Analysis – R Pipeline

> Projeto de análise de vendas de café com **R**, estruturado em camadas de dados (**Bronze - Silver - Gold**) e com geração automática de relatórios e gráficos.

---

## 📁 Estrutura de Pastas

```
coffee-r-analysis/
│
├── data/
│   ├── 01_bronze_layer/   # Dados brutos (entrada)
│   ├── 02_silver_layer/   # Dados limpos e padronizados
│   └── 03_gold_layer/     # Dados agregados e KPIs
│
├── R/                     # Scripts principais (pipeline)
│   ├── 01_load_clean.R        # BRONZE - SILVER
│   ├── 02_analysis.R          # SILVER - GOLD
│   ├── 03_visualization.R     # GOLD - Gráficos
│   └── 04_report.R            # GOLD - Relatório HTML
│
├── reports/               # Gráficos e relatório final
│   ├── monthly_sales.png
│   └── coffee_sales_report.html
│
├── .gitignore
├── README.md
└── requirements.txt        # Pacotes R utilizados
```

---

## 🚀 Objetivo

Este projeto tem como objetivo demonstrar um pipeline analítico completo em **R**, utilizando o padrão de camadas de dados (**Medallion Architecture**):

1. **Padronizar** dados brutos de vendas de café.  
2. **Gerar KPIs e agregações** mensais, por produto e por forma de pagamento.  
3. **Criar visualizações** e um **relatório HTML automático** consolidando as análises.

---

## 🧩 Fluxo de Processamento

| Etapa | Script | Entrada | Saída | Descrição |
|-------|---------|----------|-------|------------|
| **1. Load & Clean** | `R/01_load_clean.R` | `data/01_bronze_layer/Coffe_sales.csv` | `data/02_silver_layer/coffee_sales_clean.csv` | Leitura concorrente (multithread), limpeza e padronização dos dados brutos. |
| **2. Analysis** | `R/02_analysis.R` | Silver | Gold (`monthly_sales.csv`, `top_products.csv`, `by_payment.csv`, `kpis.csv`) | Cálculo de KPIs e agregações. |
| **3. Visualization** | `R/03_visualization.R` | Gold | `reports/monthly_sales.png` | Criação do gráfico de receita mensal. |
| **4. Report** | `R/04_report.R` | Gold + gráfico | `reports/coffee_sales_report.html` | Gera o relatório HTML final (sem depender de Pandoc). |

---

## ⚙️ Configuração do Ambiente

1. **Instalar o R:**  
   [https://cran.r-project.org](https://cran.r-project.org)

2. **Abrir o projeto no VS Code** e instalar as extensões:
   - **R** (Yuki Ueda)  
   - **R Language Server**

3. **Instalar os pacotes necessários (uma vez):**
   ```r
   install.packages(c(
     "tidyverse", "lubridate", "janitor", "readr", "readxl",
     "ggplot2", "scales", "dplyr", "data.table", "tibble"
   ))
   ```

4. **Colocar o arquivo bruto** (`Coffe_sales.csv` ou `coffee_sales.csv`) em:  
   ```
   data/01_bronze_layer/
   ```

---

## ▶️ Execução do Pipeline

Rode os scripts no terminal R do VS Code, na ordem:

```r
source("R/01_load_clean.R")     # BRONZE - SILVER
source("R/02_analysis.R")       # SILVER - GOLD
source("R/03_visualization.R")  # GOLD - PNG
source("R/04_report.R")         # GOLD - HTML
```

Após a execução, abra o relatório final:

```
reports/coffee_sales_report.html
```

---

## 📊 KPIs Gerados

| Indicador | Descrição |
|------------|------------|
| **Receita total** | Soma de `revenue` no período. |
| **Transações (tx)** | Quantidade de registros (vendas). |
| **Ticket médio** | Receita / número de transações. |
| **Top 5 produtos** | Produtos com maior receita total. |
| **Receita por forma de pagamento** | Receita agregada por `cash_type`. |
| **Receita mensal** | Evolução da receita ao longo do tempo. |

---

## 📈 Visualizações

O script `R/03_visualization.R` gera automaticamente o gráfico **“Evolução Mensal da Receita”**, salvo em:

```
reports/monthly_sales.png
```

Esse gráfico também é incorporado no relatório HTML final, junto com as tabelas:

- Receita mensal (tabela)  
- Top 5 produtos por receita  
- Receita por forma de pagamento  

---

## ⚡ Leitura Concorrente (Multithread)

A leitura dos arquivos CSV no script `R/01_load_clean.R` agora é feita com **`data.table::fread()`**, que realiza **leitura concorrente** em múltiplos núcleos da CPU.

```r
if (grepl("\.csv$", path_in, ignore.case = TRUE)) {
  data.table::setDTthreads(max(1L, parallel::detectCores() - 1L))
  raw <- data.table::fread(
    file         = path_in,
    showProgress = interactive(),
    nThread      = data.table::getDTthreads(),
    encoding     = "UTF-8",
    na.strings   = c("", "NA", "NaN", "null", "NULL")
  ) |> tibble::as_tibble()
} else {
  raw <- readxl::read_excel(path_in)
}
```

🔹 **Como funciona:**  
O `fread()` divide o arquivo em blocos e processa cada parte em **threads paralelas**, tornando a leitura até **10x mais rápida** em CSVs grandes, aproveitando o hardware disponível.

---

## 🧠 Notas Técnicas

- Cada linha no dataset representa **1 transação**, com `qty = 1`.  
- A variável **`tx`** no relatório indica o **número de transações** por mês.  
- O pipeline segue o padrão **Medallion Architecture**:
  - **Bronze:** dados crus (como vieram da origem)
  - **Silver:** dados limpos e padronizados
  - **Gold:** dados prontos para análise e visualização
- O relatório final (`04_report.R`) é gerado **sem dependência do Pandoc**, compatível com execução direta no VS Code.
- A leitura de dados é **concorrente** via `data.table::fread()` - ideal para arquivos CSV grandes.

---

## 🧹 Versionamento e .gitignore

O repositório mantém apenas scripts e metadados versionados.  
Arquivos de dados e relatórios são ignorados por padrão:

```
data/01_bronze_layer/
data/03_gold_layer/
reports/*.html
reports/*.png
.Rhistory
.Rproj.user
.RData
.Ruserdata
```

---

## 📄 Licença

Uso interno e educacional.  
© 2025 Coffee Sales Analysis — Desenvolvido em R por Eric Amorim e Mateus Stangherlin
