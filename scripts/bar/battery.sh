#!/bin/bash

battery_info=$(upower -i /org/freedesktop/UPower/devices/battery_BAT0)

state=$(echo "$battery_info" | grep -E "state" | awk '{print $2}')
percentage=$(echo "$battery_info" | grep -E "percentage" | awk '{gsub("%","",$2); print $2}')  # Remove "%" using gsub
percentage_base10=$(( (percentage + 5) / 10 * 10 ))
time_to_full=$(echo "$battery_info" | grep -E "time to full" | awk '{print int($4 + 0.5),$5}')  # Captures time and unit
time_to_empty=$(echo "$battery_info" | grep -E "time to empty" | awk '{print int($4 + 0.5),$5}')  # Captures time and unit

echo "{\"state\": \"${state}\", \"percentage\": ${percentage}, \"percentage_base10\": ${percentage_base10}, \"time_to_full\": \"${time_to_full}\", \"time_to_empty\": \"${time_to_empty}\" }"
