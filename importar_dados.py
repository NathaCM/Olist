
import csv
import sqlite3
from pathlib import Path

PASTA_DADOS = Path("data")
PASTA_BANCO = Path("database")
ARQUIVO_BANCO = PASTA_BANCO / "olist.db"

PASTA_BANCO.mkdir(exist_ok=True)

arquivos = {
    "olist_customers_dataset.csv": "customers",
    "olist_geolocation_dataset.csv": "geolocation",
    "olist_order_items_dataset.csv": "order_items",
    "olist_order_payments_dataset.csv": "order_payments",
    "olist_order_reviews_dataset.csv": "order_reviews",
    "olist_orders_dataset.csv": "orders",
    "olist_products_dataset.csv": "products",
    "olist_sellers_dataset.csv": "sellers",
    "product_category_name_translation.csv": "category_translation",
}

with sqlite3.connect(ARQUIVO_BANCO) as conn:
    for arquivo, tabela in arquivos.items():
        caminho = PASTA_DADOS / arquivo

        with caminho.open(
            "r", encoding="utf-8-sig", newline=""
        ) as f:
            leitor = csv.reader(f)
            colunas = next(leitor)

            nomes_sql = ", ".join(
                '"' + c.replace('"', '""') + '"'
                for c in colunas
            )
            definicoes = ", ".join(
                '"' + c.replace('"', '""') + '" TEXT'
                for c in colunas
            )

            conn.execute(
                f'CREATE TABLE IF NOT EXISTS "{tabela}" '
                f"({definicoes})"
            )

            # Recarrega a tabela para evitar duplicar linhas
            # ao executar o script novamente.
            conn.execute(f'DELETE FROM "{tabela}"')

            placeholders = ", ".join(
                "?" for _ in colunas
            )
            sql = (
                f'INSERT INTO "{tabela}" ({nomes_sql}) '
                f"VALUES ({placeholders})"
            )

            conn.executemany(sql, leitor)
            total = conn.execute(
                f'SELECT COUNT(*) FROM "{tabela}"'
            ).fetchone()[0]

            print(f"{tabela}: {total:,} linhas")

print(f"Banco criado em: {ARQUIVO_BANCO}")
