#!/bin/bash

set -euo pipefail

INSTANCE_ID="i-0bbb6993aa807558f"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"

file_to_find="$PROJECT_DIR/frontend/.env.docker"

echo "Project directory: $PROJECT_DIR"
echo "Env file: $file_to_find"

if [[ ! -f "$file_to_find" ]]; then
    echo "ERROR: File not found: $file_to_find"
    exit 1
fi

ipv4_address=$(aws ec2 describe-instances \
    --instance-ids "$INSTANCE_ID" \
    --query 'Reservations[0].Instances[0].PublicIpAddress' \
    --output text)

if [[ -z "$ipv4_address" || "$ipv4_address" == "None" ]]; then
    echo "ERROR: Could not retrieve EC2 public IP."
    exit 1
fi

echo "EC2 Public IP: $ipv4_address"

sed -i \
    "s|^VITE_API_PATH=.*|VITE_API_PATH=\"http://${ipv4_address}:31100\"|" \
    "$file_to_find"

echo "Updated VITE_API_PATH to http://${ipv4_address}:31100"
