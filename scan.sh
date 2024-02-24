#!/bin/bash

# Location of the existing JSON file
OUTPUT_FILE="hosts.json"

# Check if jq is installed
if ! command -v jq &> /dev/null
then
    echo "jq could not be found, please install jq."
    exit
fi

# Determine the local network IP range
IP_RANGE=$(ip addr show | grep 'inet ' | grep -v '127.0.0.1' | awk '{print $2}' | cut -d/ -f1 | head -n 1 | cut -d. -f1-3).0/24

# Use nmap to scan the network
echo "Scanning network range $IP_RANGE..."
nmap -sn --min-parallelism 100 $IP_RANGE | grep 'Nmap scan report for' | awk '{print $5, $6}' > scan_results.txt

# Read each line of scan results and add them to the JSON file
while IFS= read -r line
do
  HOSTNAME=$(echo $line | cut -d ' ' -f2 | tr -d '()')
  IP=$(echo $line | cut -d ' ' -f1)
  
  # Ignore lines without hostname
  if [ "$HOSTNAME" != "" ]; then
    # Create a new JSON object for the host and add it to the existing file
    jq --arg ip "$IP" --arg hostname "$HOSTNAME" '.hosts += [{"ip": $ip, "hostname": $hostname}]' $OUTPUT_FILE > tmp.$$.json && mv tmp.$$.json $OUTPUT_FILE
  fi
done < scan_results.txt

echo "Network scan complete. Results added to $OUTPUT_FILE."

# Clean up the temporary file
rm scan_results.txt
