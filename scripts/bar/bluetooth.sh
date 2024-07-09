#!/bin/bash

state=$(rfkill list bluetooth | grep -i 'soft blocked' | awk '{print $3}')

echo "{\"state\": \"${state}\"}"