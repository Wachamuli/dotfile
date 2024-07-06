#!/bin/bash

# Get master volume information using amixer
volume_info=$(amixer get Master)

volume=$(echo "$volume_info" | grep -oP '\d+%' | head -n 1 | tr -d '%')
mute=$(echo "$volume_info" | grep -oP '\[(on|off)\]' | head -n 1 | tr -d '[]')

echo "{\"volume\": ${volume}, \"mute\": \"${mute}\"}"