#!/bin/bash

# Initialize default values
hours=0
minutes=0
seconds=0
profile="none"  # Added initialization for profile

control_file="/tmp/countdown_control.txt"

# Create the control file with initial values if it doesn't exist
if [ ! -f "$control_file" ]; then
    echo "hours=0" > "$control_file"
    echo "minutes=0" >> "$control_file"
    echo "seconds=0" >> "$control_file"
    echo "command=stop" >> "$control_file"
    echo "remaining_time=0" >> "$control_file"
    echo "profile=none" >> "$control_file"  # Added profile initialization in control file
fi

# Function to read parameters from the control file
read_parameters() {
    while IFS='=' read -r key value; do
        case "$key" in
            hours) hours=$value ;;
            minutes) minutes=$value ;;
            seconds) seconds=$value ;;
            command) command=$value ;;
            remaining_time) remaining_time=$value ;;
            profile) profile=$value ;;
        esac
    done < "$control_file"
}

# Function to save remaining time to control file
save_remaining_time() {
    echo "remaining_time=$remaining_time" >> "$control_file"
}

# Initial read of parameters
read_parameters

# Calculate total seconds
total_seconds=$((hours * 3600 + minutes * 60 + seconds))

# Countdown loop
while true; do
    if [ "$command" = "start" ]; then
        end_time="$(($(date +%s) + remaining_time))"
        while [ "$end_time" -ge "$(date +%s)" ]; do
            read_parameters
            if [ "$command" = "stop" ]; then
                remaining_time="$(( $end_time - $(date +%s) ))"
                save_remaining_time
                break
            elif [ "$command" = "clear" ]; then
                remaining_time=0
                echo -e "$(date -u -d "@$remaining_time" +'{"hour": "00", "minute": "00", "second": "00", "profile": "'$profile'"}')\r"  # Modified to include profile
                break
            fi

            remaining_time="$(( $end_time - $(date +%s) ))"
            echo -e "$(date -u -d "@$remaining_time" +'{"hour": "%H", "minute": "%M", "second": "%S", "profile": "'$profile'"}')\r"  # Modified to include profile
            sleep 1
        done

        if [ "$command" != "stop" ]; then
            remaining_time=0
        fi
    fi

    # Re-read parameters every second
    read_parameters
    total_seconds=$((hours * 3600 + minutes * 60 + seconds))
    remaining_time=$total_seconds
    sleep 1
done
