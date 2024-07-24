status=$(systemctl is-active geoclue)

# Store the new status in a variable
echo "{ \"state\": \"${status}\" }"