#!/bin/bash
wifi_blocked=$(rfkill list wifi | grep -qi "Soft blocked: yes"; echo $?)
bluetooth_blocked=$(rfkill list bluetooth | grep -qi "Soft blocked: yes"; echo $?)

if [ $wifi_blocked -eq 0 ] && [ $bluetooth_blocked -eq 0 ]; then
  echo "true"
else
  echo "false"
fi