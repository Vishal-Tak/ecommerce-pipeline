import os
from google.cloud import storage

def upload_csv_files(local_folder: str, bucket_name: str):
    client = storage.Client(project="ecommerce-pipeline-497207")
    bucket = client.bucket(bucket_name)

    csv_files = [f for f in os.listdir(local_folder) if f.endswith(".csv")]

    if not csv_files:
        print(f"No CSV files found in {local_folder}")
        return

    print(f"Found {len(csv_files)} CSV files. Uploading...\n")

    for filename in csv_files:
        local_path = os.path.join(local_folder, filename)
        gcs_path = f"raw/{filename}"

        blob = bucket.blob(gcs_path)
        blob.upload_from_filename(local_path)
        print(f"Uploaded: {filename} → gs://{bucket_name}/{gcs_path}")

    print(f"\nAll files uploaded successfully.")

if __name__ == "__main__":
    # Change this path to where your Olist CSVs are
    LOCAL_DATA_FOLDER = "./data"
    BUCKET_NAME = "ecommerce-raw-landing-497207"

    upload_csv_files(LOCAL_DATA_FOLDER, BUCKET_NAME)