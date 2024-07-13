#!/bin/bash

battery_info=$(upower -i /org/freedesktop/UPower/devices/battery_BAT0)

state=$(echo "$battery_info" | grep -E "state" | awk '{print $2}')
percentage=$(echo "$battery_info" | grep -E "percentage" | awk '{gsub("%","",$2); print $2}')  # Remove "%" using gsub
percentage_base10=$(( (percentage + 5) / 10 * 10 ))
time_to_full=$(echo "$battery_info" | grep -E "time to full" | awk '{print int($4 + 0.5),$5}')  # Captures time and unit
time_to_empty=$(echo "$battery_info" | grep -E "time to empty" | awk '{print int($4 + 0.5),$5}')  # Captures time and unit

low_battery_notified=false

if [ "$percentage" -lt 15 ] && [ "$low_battery_notified" = false ]; then
    notify-send -u critical --icon=$HOME/.config/eww/images/bell.svg --app-name=System "Low Battery" "Plug in the device."
    low_battery_notified=true
elif [ "$percentage" -ge 15 ]; then
    low_battery_notified=false
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