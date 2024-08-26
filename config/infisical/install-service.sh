#!/bin/bash

handle_error() {
  echo "Error: $1"
  exit 1
}

if [ "$EUID" -ne 0 ]; then
  handle_error "Please run this script as root."
fi

cp -f infisical-agent.service /etc/systemd/system/infisical-agent.service || handle_error "Failed to copy service file."

systemctl daemon-reload || handle_error "Failed to reload systemd."

systemctl enable infisical-agent || handle_error "Failed to enable infisical-agent service."

systemctl restart infisical-agent || handle_error "Failed to restart infisical-agent service."

echo "Infisical agent service installed and started successfully."