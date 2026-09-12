#!/bin/bash

INSTANCE_ID="i-0bbb6993aa807558f"
file_to_find="../frontend/.env.docker"

ipv4_address=$(aws ec2 describe-instances \
    --instance-ids "$INSTANCE_ID" \
    --query 'Reservations[0].Instances[0].PublicIpAddress' \
    --output text)

if [[ -z "$ipv4_address" || "$ipv4_address" == "None" ]]; then
    echo "ERROR: Could not retrieve EC2 public IP."
    exit 1
fi

if [ ! -f "$file_to_find" ]; then
    echo "ERROR: File not found: $file_to_find"
    exit 1
fi

sed -i \
    "s|^VITE_API_PATH=.*|VITE_API_PATH=\"http://${ipv4_address}:31100\"|" \
    "$file_to_find"

echo "Updated VITE_API_PATH to http://${ipv4_address}:31100"
