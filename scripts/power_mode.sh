#!/bin/bash

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
esac
