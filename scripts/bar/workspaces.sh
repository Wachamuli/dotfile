#!/bin/bash

# Use grep and awk to filter and extract workspace IDs
focused_workspace=$(hyprctl activeworkspace | grep -m 1 "ID" | awk '{print $3}')


workspace_ids=$(hyprctl workspaces | grep 'workspace ID' | awk '{print $3}' | tr -d '(' | tr -d ')' | awk '$1 >= 0')

special_workspace=$(hyprctl workspaces | grep 'workspace ID' | awk '{print $3}' | tr -d '(' | tr -d ')' | awk '$1 < 0')

# Sort the IDs and convert them into a string formatted as an array in one line
sorted_ids=$(echo "$workspace_ids" | tr ' ' '\n' | sort -n | tr '\n' ',' | sed 's/,$//')

max_id=$(echo "$workspace_ids" | tr ' ' '\n' | sort -n | tail -n 1)

# Calculate max_id + 1
next_id=$((max_id + 1))

# Format as an array string
active_workspace_ids_array="[$sorted_ids,$next_id]"

output=$(cat << EOM
{ 
    "focused": "${focused_workspace}",
    "actives": ${active_workspace_ids_array},
    "special_workspace": "${special_workspace}"
}
EOM
)

echo $output