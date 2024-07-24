#!/bin/bash

# Run the nmcli command and get the Wi-Fi networks in a structured format
wifi_scan=$(nmcli -t -f SSID,RATE,SIGNAL,SECURITY dev wifi)

# Initialize an empty JSON array
json_output='['

# Loop through each line of the wifi_scan output
while IFS= read -r line; do
    # Split the line into fields
    IFS=':' read -r ssid rate signal security <<< "$line"

    # Check if signal strength is below 10
    if (( signal < 10 )); then
        continue
    fi

    # Remove slashes from the SSID field
    ssid=$(echo "$ssid" | sed 's/[\\]//g')

    # Add each network as a JSON object
    json_output+='{"ssid":"'"$ssid"'","rate":"'"$rate"'","signal":"'"$signal"'","security":"'"$security"'"},'
done <<< "$wifi_scan"

# Remove the trailing comma and close the JSON array
json_output="${json_output%,}]"

# Print the JSON output
echo "$json_output"
