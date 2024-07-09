#!/bin/bash

# Function to get the current volume and mute state
get_current_volume_and_mute() {
  volume=$(pactl get-sink-volume @DEFAULT_SINK@ | grep -Po '[0-9]+(?=%)' | head -1)
  mute=$(pactl get-sink-mute @DEFAULT_SINK@ | grep -Po '(?<=Mute: ).*')
  echo "$volume" "$mute"
}

# Initialize the last volume and mute state variables
last_volume=""
last_mute=""

# Start listening for events
pactl subscribe | while read -r event; do
  # Check if the event is related to sink (volume or mute state)
  if echo "$event" | grep -q "sink"; then
    # Get the current volume and mute state
    read current_volume current_mute <<< $(get_current_volume_and_mute)

    # Mute the device if the volume is 0%
    if [ "$current_volume" -eq 0 ] && [ "$current_mute" != "yes" ]; then
      pactl set-sink-mute @DEFAULT_SINK@ 1
      current_mute="yes"
    fi

    # Print the volume if it has changed and is not 0%
    if [ "$current_volume" != "$last_volume" ] && [ "$current_volume" -ne 0 ]; then
      pactl set-sink-mute @DEFAULT_SINK@ 0
      last_volume="$current_volume"
    fi

    # Print the mute state if it has changed
    if [ "$current_mute" != "$last_mute" ]; then
      last_mute="$current_mute"
    fi


    echo "{\"volume\": ${last_volume}, \"muted\": \"${last_mute}\"}"
  fi
done
