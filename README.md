# Linux Security and Privacy Toolkit

This toolkit includes a set of scripts designed to enhance the security and privacy of Linux environments. It covers network scanning, environment setup, and daily operations maintenance.

## Scripts Overview

- **scan.sh**: Scans the local network to identify hosts and updates a JSON file with the results.
- **setup_env.sh**: Configures a Linux environment with essential security and privacy settings, including installing necessary packages.
- **daily_ops.sh**: Performs daily maintenance tasks, such as updating the system, cleaning with BleachBit, and scanning for malware with ClamAV.

## Getting Started

### Prerequisites

- A Debian-based Linux distribution.
- Root or sudo access.
- Internet connection for package installation.

### Installation

1. **Ensure jq, nmap, and other dependencies are installed:**
   Run `setup_env.sh` to install necessary packages and perform initial configuration. This script must be run as root.

2. **Perform a Network Scan:**
   Execute `scan.sh` to scan your local network and identify hosts. The results will be saved in a `hosts.json` file.

3. **Daily Operations:**
   Run `daily_ops.sh` regularly (preferably via a cron job) to maintain system health. This includes system updates, cleaning, and malware scanning.

## Detailed Description

### scan.sh

- Determines the local IP range.
- Uses `nmap` to scan the network.
- Updates `hosts.json` with scan results.

### setup_env.sh

- Installs necessary packages: jq, nmap, macchanger, clamav, bleachbit.
- Disables Bluetooth.
- Clears terminal history and prevents its recording.
- Removes spyware packages.
- Configures a systemd service for updating MAC addresses and hostnames.
- Applies privacy settings using `gsettings`.

### daily_ops.sh

- Ensures jq is installed.
- Requires root privileges.
- Selects a hostname-MAC pair from `hosts.json`.
- Applies the MAC address and changes the hostname.
- Performs system updates and cleaning.
- Scans the system for malware with ClamAV.

## Usage

### Running Scripts

- **scan.sh**: `./scan.sh`
- **setup_env.sh**: `sudo ./setup_env.sh`
- **daily_ops.sh**: `sudo ./daily_ops.sh`

Ensure you have executable permissions on the scripts: `chmod +x *.sh`

### Configurations

- Modify `hosts.json` as necessary for network scanning results.
- Adjust the systemd service file `/etc/systemd/system/update_hostname_mac.service` as needed.

## Contributions

Contributions are welcome. Please submit pull requests or issues to improve the scripts or add new features.

## License

This toolkit is open-sourced under the MIT License.
