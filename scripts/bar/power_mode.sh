#!/bin/bash

get_power_mode () {
    power_mode=$(powerprofilesctl get)
    case "$power_mode" in
        "power-saver")
            echo "Power Saver"
            ;;
        "balanced")
            echo "Balanced"
            ;;
        "performance")
            echo "Performance"
            ;;
        *)
        echo "Invalid value: select between saver, balanced or performance."
            ;;
    esac
}

set_power_mode () {
    case "$1" in
        "saver")
            powerprofilesctl set power-saver
            ;;
        "balanced")
            powerprofilesctl set balanced
            ;;
        "performance")
            powerprofilesctl set performance
            ;;
        *)
        echo "Invalid value: select between saver, balanced or performance."
            ;;
    esac
}

if [[ "$1" == "get" ]]; then
    get_power_mode
elif [[ "$1" == "set" ]]; then
    if [[ -z "$2" ]]; then
        echo "Please provide a profile to set: saver, balanced, or performance."
    else
        set_power_mode "$2"
    fi
else
    echo "Usage: $0 {get|set} [profile]"
fi