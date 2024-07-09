#!/bin/bash

# Use grep and awk to filter and extract workspace IDs
workspace_ids=$(hyprctl workspaces | grep 'workspace ID' | awk '{print $3}' | tr -d '(' | tr -d ')')

# Sort the IDs and convert them into a string formatted as an array in one line
sorted_ids=$(echo "$workspace_ids" | tr ' ' '\n' | sort -n | tr '\n' ',' | sed 's/,$//')
# Format as an array string
active_workspace_ids_array="[$sorted_ids]"

focused_workspace=$(hyprctl activeworkspace | grep -m 1 "ID" | awk '{print $3}')

echo "{ \"focused\": ${focused_workspace}, \"actives\": ${active_workspace_ids_array} }"