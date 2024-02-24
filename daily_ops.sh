#!/bin/bash

# Ensure jq is installed
if ! command -v jq &> /dev/null; then
    echo "jq is not installed. Please install jq to continue."
    exit 1
fi

# Check if the user is root
if [ "$(id -u)" -ne 0 ]; then
    echo "This script must be run with superuser privileges."
    exit 1
fi

# Location of the JSON configuration file
CONFIG_FILE="/hosts.json"

# Verify the JSON configuration file exists and is not empty
if [ ! -s "$CONFIG_FILE" ]; then
    echo "Configuration file $CONFIG_FILE does not exist or is empty."
    exit 1
fi

# Randomly select a hostname-MAC pair from the JSON file
SELECTED_HOST=$(jq -e '.hosts | .[]' $CONFIG_FILE | shuf -n 1)
if [ $? -ne 0 ]; then
    echo "Failed to select a host from the configuration file."
    exit 1
fi
RANDOM_MAC=$(echo "$SELECTED_HOST" | jq -r '.mac_address')
RANDOM_HOSTNAME=$(echo "$SELECTED_HOST" | jq -r '.hostname')

# Apply the MAC address
echo "Identifying active network interface..."
INTERFACE=$(ip link | awk '/state UP/ {print $2}' | sed 's/://g' | head -n 1)
if [ -z "$INTERFACE" ]; then
    echo "No active network interface found."
    exit 1
fi
echo "Updating MAC address for interface $INTERFACE..."
sudo ip link set dev $INTERFACE down
sudo macchanger --mac=$RANDOM_MAC $INTERFACE
sudo ip link set dev $INTERFACE up

# Change the hostname
echo "Updating hostname to $RANDOM_HOSTNAME..."
sudo hostnamectl set-hostname $RANDOM_HOSTNAME

# Confirmation of changes
echo "New MAC address: $RANDOM_MAC"
echo "New hostname: $RANDOM_HOSTNAME"

# System Update and Maintenance Section

# Update the system
echo "Updating the system..."
sudo apt update && sudo apt upgrade -y

# Clean the system with BleachBit (command line mode)
echo "Cleaning the system with BleachBit..."
sudo bleachbit --clean --preset

# Scan the system for malware with ClamAV
echo "Scanning the system for malware with ClamAV..."
sudo clamscan -r -i --remove=yes /

# Empty the trash
echo "Emptying the trash..."
gio trash --empty

# Add any other daily maintenance operations you wish to perform here
echo "Daily maintenance is complete."
