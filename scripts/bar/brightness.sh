#!/bin/bash

# Initialize the last brightness level variable
# last_brightness=$(get_current_brightness)

# Start monitoring brightness level
while true; do
  # Get the current brightness level
  current_brightness=$(brightnessctl g)

  # Print the brightness level if it has changed
  if [ "$current_brightness" != "$last_brightness" ]; then
    echo $((current_brightness * 100 / 96000))
    last_brightness="$current_brightness"
  fi
done