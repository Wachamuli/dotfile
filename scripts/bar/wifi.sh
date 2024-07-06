wifi_info=$(nmcli -t -f active,ssid,signal dev wifi | grep 'yes')

state=$(echo "$wifi_info" | awk -F':' '{print $1}')
name=$(echo "$wifi_info" | awk -F':' '{print $2}')
signal=$(echo "$wifi_info" | awk -F':' '{print $3}')

echo "{\"state\": \"${state}\", \"name\": \"${name}\", \"signal\": \"${signal}\"}"