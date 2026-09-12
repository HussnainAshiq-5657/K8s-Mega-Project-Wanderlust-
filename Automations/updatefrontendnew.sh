#!/bin/bash

set -euo pipefail

INSTANCE_ID="i-0bbb6993aa807558f"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"

file_to_find="$PROJECT_DIR/frontend/.env.docker"

echo "Project directory: $PROJECT_DIR"
echo "Env file: $file_to_find"

# Create .env.docker if it does not exist
if [[ ! -f "$file_to_find" ]]; then
    echo "File not found. Creating $file_to_find"
    touch "$file_to_find"
fi

# Get EC2 public IP
ipv4_address=$(aws ec2 describe-instances \
    --instance-ids "$INSTANCE_ID" \
    --query 'Reservations[0].Instances[0].PublicIpAddress' \
    --output text)

# Validate IP
if [[ -z "$ipv4_address" || "$ipv4_address" == "None" ]]; then
    echo "ERROR: Could not retrieve EC2 public IP."
    exit 1
fi

echo "EC2 Public IP: $ipv4_address"

# Update or add VITE_API_PATH
if grep -q '^VITE_API_PATH=' "$file_to_find"; then
    sed -i \
        "s|^VITE_API_PATH=.*|VITE_API_PATH=\"http://${ipv4_address}:31100\"|" \
        "$file_to_find"
else
    echo "VITE_API_PATH=\"http://${ipv4_address}:31100\"" >> "$file_to_find"
fi

echo "Updated VITE_API_PATH to http://${ipv4_address}:31100"

# Show final value
echo "Current VITE_API_PATH:"
grep '^VITE_API_PATH=' "$file_to_find"
