Here’s a Bash script that prompts the user for their AWS profile and region, checks for existing Kinesis Data Streams, and backs up the configuration of each stream to a JSON file with the stream's name.

### Bash Script

```bash
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
```

### Instructions

1. **Save the Script**: Save the above script as `backup_kinesis_streams.sh`.
2. **Make it Executable**: Run `chmod +x backup_kinesis_streams.sh` to make it executable.
3. **Run the Script**: Execute the script:
   ```bash
   ./backup_kinesis_streams.sh
   ```

### What the Script Does

1. **Prompts for AWS Profile and Region**: The user provides their AWS profile and region.
2. **Lists Kinesis Data Streams**: It checks for existing Kinesis Data Streams in the specified region.
3. **Backs Up Configuration**: For each found stream, it retrieves the stream configuration and saves it to a JSON file in a `kinesis_backups` directory, naming the file according to the stream name.
4. **Handles Errors**: The script checks for errors during the AWS CLI commands and reports them accordingly.

This script provides a straightforward way to back up Kinesis Data Stream configurations while ensuring the user can easily specify their AWS environment. If you have any further requirements or adjustments, let me know!
