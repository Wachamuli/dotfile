#!/bin/bash

# Get the list of all sources (input devices)
state=$(pactl list sources short | grep "51" | grep "RUNNING" 2>&1)

if [ $? -eq 0 ]; then
    echo "{\"state\": \"on\"}"
else
    echo "{\"state\": \"off\"}"
fi
