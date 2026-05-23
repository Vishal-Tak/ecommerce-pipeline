import logging
from google.cloud import bigquery

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

PROJECT    = "ecommerce-pipeline-497207"
DATASET    = "ecommerce_raw_us"
GCS_BUCKET = "ecommerce-medallion-497207"

TABLES = [
    "olist_customers_dataset",
    "olist_orders_dataset",
    "olist_order_items_dataset",
    "olist_order_payments_dataset",
    "olist_order_reviews_dataset",
    "olist_products_dataset",
    "olist_sellers_dataset",
    "olist_geolocation_dataset",
    "product_category_name_translation",
]

def load_to_bigquery():
    client = bigquery.Client(project=PROJECT)

    for table in TABLES:
        gcs_uri    = f"gs://{GCS_BUCKET}/bronze/{table}/*.parquet"
        table_ref  = f"{PROJECT}.{DATASET}.{table}"

        logger.info(f"Loading: {table} → {table_ref}")

        job_config = bigquery.LoadJobConfig(
            source_format=bigquery.SourceFormat.PARQUET,
            write_disposition=bigquery.WriteDisposition.WRITE_TRUNCATE,
            autodetect=True,
        )

        try:
            load_job = client.load_table_from_uri(
                gcs_uri,
                table_ref,
                job_config=job_config
            )
            load_job.result()  # wait for job to finish

            table_obj = client.get_table(table_ref)
            logger.info(f"Done: {table} | rows: {table_obj.num_rows:,}")

        except Exception as e:
            logger.error(f"Failed: {table} | error: {e}")

    logger.info("All tables loaded to BigQuery.")

if __name__ == "__main__":
    load_to_bigquery()