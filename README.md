# E-Commerce Data Pipeline — GCP

End-to-end data pipeline processing 100K+ Brazilian e-commerce 
orders using a medallion architecture on Google Cloud Platform.

## Architecture

```
Raw CSVs (Kaggle Olist)
    ↓
Google Cloud Storage (bronze layer — Parquet)
    ↓
PySpark (bronze_layer.py)
    ↓
BigQuery (ecommerce_raw_us dataset)
    ↓
dbt (silver + gold transformations)
    ↓
Looker Studio Dashboard
```

## Tech Stack

- Python / PySpark — data ingestion and bronze layer 
- Google Cloud Storage — raw and bronze data lake
- BigQuery — analytical warehouse
- dbt — silver and gold transformations (SQL models)
- Looker Studio — business intelligence dashboard
- Apache Airflow — orchestration (in progress)

## Dataset

Brazilian E-Commerce Public Dataset by Olist — 9 tables, 
100K+ orders, 1M+ geolocation records spanning 2016–2018.

## Medallion Architecture

| Layer | Location | Description |
|---|---|---|
| Bronze | GCS + BigQuery | Raw ingested data as Parquet |
| Silver | BigQuery (dbt) | Cleaned, typed, joined tables |
| Gold | BigQuery (dbt) | Business metrics and aggregations |

## dbt Models

Silver layer:
- `silver_orders` — cleaned orders with delivery metrics
- `silver_customers` — customer dimension
- `silver_order_items` — line items with total value
- `silver_payments` — payment methods and values
- `silver_sellers` — seller dimension

Gold layer:
- `gold_seller_performance` — revenue, delivery rate per seller
- `gold_daily_revenue` — daily trend with cumulative revenue
- `gold_customer_segments` — RFM segmentation

## Dashboard

Live: [View on Looker Studio](YOUR-LINK-HERE)

Key metrics:
- R$16M total revenue across 99K orders
- 12.2 days average delivery time
- 86.8% new customers — high acquisition, low retention signal
- São Paulo dominant in both orders and revenue

## Project Structure

```
ecommerce-pipeline/
├── src/
│   ├── ingestion/
│   │   ├── create_buckets.py
│   │   ├── upload_raw_data.py
│   │   └── load_to_bigquery.py
│   └── transform/
│       └── bronze_layer.py
├── ecommerce_dbt/
│   └── models/
│       ├── bronze/sources.yml
│       ├── silver/
│       └── gold/
├── scripts/
│   └── run_bronze.sh
└── README.md
```

## How to Run

```bash
# 1. Set up GCP project
gcloud config set project ecommerce-pipeline-497207

# 2. Create GCS buckets
python src/ingestion/create_buckets.py

# 3. Upload raw data
python src/ingestion/upload_raw_data.py

# 4. Run bronze layer
python src/transform/bronze_layer.py

# 5. Load to BigQuery
python src/ingestion/load_to_bigquery.py

# 6. Run dbt transformations
cd ecommerce_dbt
dbt run
dbt test
```

## Key Learnings

- Medallion architecture separates concerns cleanly across layers
- dbt handles silver/gold transformations better than PySpark for 
  SQL-native warehouses like BigQuery
- GCS connector auth on local Mac requires USER_CREDENTIALS 
  approach — documented in bronze_layer.py
