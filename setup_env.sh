#!/bin/bash

# DONT FORGET TO ADD A PSWD TO BIOS MENU

# This script configures a Linux environment with security and privacy settings.
# It installs necessary packages, disables Bluetooth, clears terminal history,
# and sets up a systemd service for updating MAC addresses and hostnames.

# Define color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m' # No Color

# Function to display an error message and exit if not run as root
check_root() {
    if [ "$(id -u)" != "0" ]; then
        echo -e "${RED}This script must be run as root.${NC}" 1>&2
        exit 1
    fi
}

# Function to check for required commands (apt and dpkg)
check_commands() {
    if ! command -v apt > /dev/null || ! command -v dpkg > /dev/null; then
        echo -e "${RED}This script requires 'apt' and 'dpkg' which are not available on your system.${NC}" 1>&2
        echo -e "${RED}Please run this script on a Debian-based Linux distribution.${NC}" 1>&2
        exit 1
    fi
}

# Function to install a package if it's not already installed
install_if_not_installed() {
    local package_name=$1
    if ! dpkg-query -W -f='${Status}' $package_name 2>/dev/null | grep -c "ok installed" > /dev/null; then
        echo "Attempting to install $package_name..."
        if ! apt install -y $package_name > /dev/null 2>&1; then
            echo -e "${RED}Failed to install $package_name. Please check your internet connection or package name.${NC}" 1>&2
        else
            echo -e "${GREEN}$package_name has been successfully installed.${NC}"
        fi
    else
        echo "$package_name is already installed."
    fi
}

# Check if the script is run as root
check_root

# Check for required commands
check_commands

# Update package list
echo -e "${GREEN}Updating package list...${NC}"
apt update

# Install necessary packages
install_if_not_installed macchanger
install_if_not_installed jq
install_if_not_installed nmap
install_if_not_installed clamav clamav-daemon
install_if_not_installed bleachbit

# Disable Bluetooth at startup
echo "Disabling Bluetooth..."
systemctl disable bluetooth

# Clear terminal history and prevent its recording
echo "Clearing terminal history..."
unset HISTFILE SAVEHIST
rm -f ~/.bash_history ~/.zsh_history
ln -s /dev/null ~/.bash_history
ln -s /dev/null ~/.zsh_history
export HISTFILESIZE=0 HISTSIZE=0 HISTFILE=/dev/null SAVEHIST=/dev/null

# Remove spyware packages
echo "Removing spyware packages..."
apt purge apport popularity-contest -y
apt autoremove -y

# Setup update_hostname systemd service
SCRIPT_PATH="$(pwd)/*.sh"
chmod +x "$SCRIPT_PATH"

SERVICE_FILE_PATH="/etc/systemd/system/update_hostname.service"
cat > "$SERVICE_FILE_PATH" <<EOF
[Unit]
Description=Update MAC address and hostname

[Service]
Type=oneshot
ExecStart=$SCRIPT_PATH

[Install]
WantedBy=multi-user.target
EOF

# Reload systemd, enable and start the service
echo -e "${GREEN}Configuring systemd service for MAC and hostname updates...${NC}"
systemctl daemon-reload
systemctl enable update_hostname.service
systemctl start update_hostname.service

# Update ClamAV database
echo "Updating ClamAV database..."
service clamav-freshclam stop
freshclam

# Apply privacy settings using gsettings if available
if command -v gsettings > /dev/null; then
    echo "Applying privacy settings..."
    gsettings set org.gnome.system.location enabled false
    gsettings set org.gnome.desktop.privacy send-software-usage-stats false
    gsettings set org.gnome.desktop.privacy report-technical-problems false
fi

echo -e "${GREEN}All configurations and installations have been completed.${NC}"
