#!/bin/bash

# Prompt the user for the AWS profile and region
read -p "Enter your AWS profile name: " aws_profile
read -p "Enter your AWS region: " aws_region

# Temporary file to store backup
backup_dir="kinesis_backups"
mkdir -p "$backup_dir"

# Fetch the list of Kinesis Data Streams
streams=$(aws kinesis list-streams --profile "$aws_profile" --region "$aws_region" --query 'StreamNames[*]' --output text)

if [ $? -ne 0 ]; then
    echo "Error fetching Kinesis streams. Please check your AWS CLI configuration."
    exit 1
fi

# Check if there are any streams
if [ -z "$streams" ]; then
    echo "No Kinesis Data Streams found in the specified region."
    exit 0
fi

# Loop through each stream and back up its configuration
for stream_name in $streams; do
    echo "Backing up configuration for stream: $stream_name"
    
    # Fetch the stream configuration
    aws kinesis describe-stream --stream-name "$stream_name" --profile "$aws_profile" --region "$aws_region" \
    --query "StreamDescription" --output json > "$backup_dir/${stream_name}_backup.json"

    if [ $? -eq 0 ]; then
        echo "Backup for stream '$stream_name' saved to '${backup_dir}/${stream_name}_backup.json'."
    else
        echo "Failed to back up stream '$stream_name'."
    fi
done

echo "Backup process completed."

