# #!/bin/bash

input=$(pactl list sink-inputs)

declare -a jsonArray
while read -r line; do
    if [[ $line =~ ^Sink\ Input\ \#([0-9]+)$ ]]; then
        sink_input_number="${BASH_REMATCH[1]}"
    elif [[ $line =~ ^\ *application\.name\ =\ \"([^\"]+)\"$ ]]; then
        application_name="${BASH_REMATCH[1]}"
    elif [[ $line =~ ^\ *Volume:\ front-left:\ ([0-9]+)\ /\ *([0-9]+)%\ /\ *(-?[0-9.]+)\ dB,\ *front-right:\ ([0-9]+)\ /\ *([0-9]+)%\ /\ *(-?[0-9.]+)\ dB ]]; then
        volume_front_left="${BASH_REMATCH[1]}"
        volume_front_right="${BASH_REMATCH[4]}"
    elif [[ $line =~ ^\ *application\.process\.binary\ =\ \"([^\"]+)\"$ ]]; then
        application_process_binary="${BASH_REMATCH[1]}"
        jsonObject=$(jq -n \
            --arg sin "$sink_input_number" \
            --arg app "$application_name" \
            --arg vfl "$volume_front_left" \
            --arg vfr "$volume_front_right" \
            --arg bin "$application_process_binary" \
            '{sink_id: $sin, app_name: $app, volume_left: $vfl, volume_right: $vfr, app_bin_name: $bin}')
        jsonArray+=("$jsonObject")
    fi
done <<< "$input"

jsonArrayJoined=$(IFS=,; echo "[${jsonArray[*]}]")

echo "$jsonArrayJoined"
