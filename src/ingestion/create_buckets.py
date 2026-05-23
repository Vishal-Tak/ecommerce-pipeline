from google.cloud import storage

def create_buckets():
    client = storage.Client(project="ecommerce-pipeline-497207")
    
    buckets = [
        "ecommerce-raw-landing-497207",
        "ecommerce-medallion-497207"
    ]
    
    for bucket_name in buckets:
        try:
            bucket = client.create_bucket(bucket_name, location="asia-south1")
            print(f"Bucket created: {bucket_name}")
        except Exception as e:
            print(f"Bucket {bucket_name} already exists or error: {e}")

if __name__ == "__main__":
    create_buckets()