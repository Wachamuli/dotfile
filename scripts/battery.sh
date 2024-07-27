#!/bin/bash

battery_info=$(upower -i /org/freedesktop/UPower/devices/battery_BAT0)

# Battery state variables
state=$(echo "$battery_info" | grep -E "state" | awk '{print $2}')
percentage=$(echo "$battery_info" | grep -E "percentage" | awk '{gsub("%","",$2); print $2}')  # Remove "%" using gsub
percentage_base10=$(( (percentage + 5) / 10 * 10 ))
time_to_full=$(echo "$battery_info" | grep -E "time to full" | awk '{print int($4 + 0.5),$5}')  # Captures time and unit
time_to_empty=$(echo "$battery_info" | grep -E "time to empty" | awk '{print int($4 + 0.5),$5}')  # Captures time and unit

# Notify when battery is low 
NOTIFIED_STATE_FILE="/tmp/low_battery_notified"

# Check if the state file exists, if not create it and set the initial state to false
if [ ! -f "$NOTIFIED_STATE_FILE" ]; then
    echo "false" > "$NOTIFIED_STATE_FILE"
fi

low_battery_notified=$(cat "$NOTIFIED_STATE_FILE")

if [ "$percentage" -lt 15 ] && [ "$low_battery_notified" = "false" ]; then
    notify-send -u critical --icon=$HOME/.config/eww/assets/icons/battery-0.svg --app-name=System "Low Battery" "Plug in the device."
    echo "true" > "$NOTIFIED_STATE_FILE"
elif [ "$percentage" -ge 15 ]; then
    echo "false" > "$NOTIFIED_STATE_FILE"
fi

output=$(cat << EOM
{
    "state": "${state}", 
    "percentage": ${percentage}, 
    "percentage_base10": ${percentage_base10}, 
    "time_to_full": "${time_to_full}", 
    "time_to_empty": "${time_to_empty}" 
} 
EOM
) 

echo $output