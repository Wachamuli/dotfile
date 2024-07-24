#!/bin/bash

SSID="$1"
PASSWORD="$2"

output=$(nmcli dev wifi connect "$SSID" password "$PASSWORD" 2>&1) 

if [ $? -eq 0 ]; then
    # Eww is not triggered
    eww update password_output="Connection established"
else
    eww update password_output="Incorrect password!"
fi