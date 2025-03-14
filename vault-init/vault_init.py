import time

import hvac

pause_duration = 6  # You can set this to any number of seconds
print("Script starts")
time.sleep(pause_duration)  # Pause for the specified number of seconds
print(f"Script resumes after {pause_duration} seconds")

# Initialize the client
client = hvac.Client(
    url='http://vault:8200',  # Replace with your Vault server URL
    token='root'  # Replace with your Vault token
)

# Define the keys and values to store

keys_to_store = {
    'cdh': {
        's3': {
            'aws_access_key_id': 'minioadmin',
            'aws_secret_access_key': 'minioadmin',
            'aws_endpoint_override': 'http://minio:9000',
            'uri': 's3://tiledb/data'
        },
        'mongo': {
            'uri': 'mongodb://mongodb/cdh'
        }
    }
}

for key, value in keys_to_store.items():
    # Store the keys in Vault
    store_path = f"secret/{key}"
    client.secrets.kv.v2.create_or_update_secret(
        path=store_path,
        secret=value,
    )
    print(f"Keys stored at {store_path}")
