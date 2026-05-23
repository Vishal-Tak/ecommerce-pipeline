# src/transform/bronze_layer.py

import os
import logging
from pyspark.sql import SparkSession
from pyspark.sql.functions import current_timestamp, lit
from google.cloud import storage

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

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

def create_spark_session():
    return SparkSession.builder \
        .appName("EcommerceBronzeLayer") \
        .getOrCreate()

def upload_folder_to_gcs(local_folder: str, bucket_name: str, gcs_prefix: str):
    """Upload a local folder of parquet files to GCS."""
    client = storage.Client(project="ecommerce-pipeline-497207")
    bucket = client.bucket(bucket_name)

    for filename in os.listdir(local_folder):
        if filename.startswith(".") or filename.startswith("_"):
            continue
        local_path = os.path.join(local_folder, filename)
        blob_path = f"{gcs_prefix}/{filename}"
        blob = bucket.blob(blob_path)
        blob.upload_from_filename(local_path)
        logger.info(f"Uploaded: {blob_path}")

def ingest_to_bronze(spark, raw_data_folder: str, medallion_bucket: str):
    # local temp folder for parquet output
    local_bronze = "./data/bronze"
    os.makedirs(local_bronze, exist_ok=True)

    for table in TABLES:
        logger.info(f"Processing: {table}")

        input_path  = os.path.join(raw_data_folder, f"{table}.csv")
        local_out   = os.path.join(local_bronze, table)
        gcs_prefix  = f"bronze/{table}"

        try:
            df = spark.read.csv(input_path, header=True, inferSchema=True)

            df = df \
                .withColumn("_ingested_at", current_timestamp()) \
                .withColumn("_source_file", lit(f"{table}.csv"))

            row_count = df.count()

            # write parquet locally first
            df.write.mode("overwrite").parquet(local_out)
            logger.info(f"Written locally: {local_out} | rows: {row_count}")

            # upload to GCS using google-cloud-storage (no JAR needed)
            upload_folder_to_gcs(local_out, medallion_bucket, gcs_prefix)
            logger.info(f"Uploaded to GCS: gs://{medallion_bucket}/{gcs_prefix}")

        except Exception as e:
            logger.error(f"Failed: {table} | error: {e}")

    logger.info("Bronze layer complete.")

if __name__ == "__main__":
    RAW_DATA_FOLDER  = "./data"
    MEDALLION_BUCKET = "ecommerce-medallion-497207"

    spark = create_spark_session()
    ingest_to_bronze(spark, RAW_DATA_FOLDER, MEDALLION_BUCKET)
    spark.stop()