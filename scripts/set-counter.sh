# #!/bin/bash

# control_file="/tmp/countdown_control.txt"

# # Usage function
# usage() {
#     echo "Usage: $0 -H <hours> -M <minutes> -S <seconds>"
#     exit 1
# }

# # Parse arguments
# while getopts ":H:M:S:" opt; do
#     case $opt in
#         H) hours=$OPTARG ;;
#         M) minutes=$OPTARG ;;
#         S) seconds=$OPTARG ;;
#         *) usage ;;
#     esac
# done

# # Update the control file
# [ -n "$hours" ] && sed -i "s/^hours=.*/hours=$hours/" "$control_file"
# [ -n "$minutes" ] && sed -i "s/^minutes=.*/minutes=$minutes/" "$control_file"
# [ -n "$seconds" ] && sed -i "s/^seconds=.*/seconds=$seconds/" "$control_file"


#!/bin/bash

control_file="/tmp/countdown_control.txt"

# Usage function
usage() {
    echo "Usage: $0 [-H <hours>] [-M <minutes>] [-S <seconds>] [-C clear] [-T start|stop|restart]"
    exit 1
}

# Parse arguments
while getopts ":H:M:S:C:T:" opt; do
    case $opt in
        H) hours=$OPTARG ;;
        M) minutes=$OPTARG ;;
        S) seconds=$OPTARG ;;
        C) clear=true ;;
        T) command=$OPTARG ;;
        *) usage ;;
    esac
done

# Update the control file
if [ "$clear" = true ]; then
    echo "command=clear" > "$control_file"
else
    [ -n "$hours" ] && sed -i "s/^hours=.*/hours=$hours/" "$control_file"
    [ -n "$minutes" ] && sed -i "s/^minutes=.*/minutes=$minutes/" "$control_file"
    [ -n "$seconds" ] && sed -i "s/^seconds=.*/seconds=$seconds/" "$control_file"

    if [ -n "$command" ]; then
        if [ "$command" = "restart" ]; then
            remaining_time=$(grep remaining_time "$control_file" | cut -d '=' -f 2)
            sed -i "s/^remaining_time=.*/remaining_time=$remaining_time/" "$control_file"
            sed -i "s/^command=.*/command=start/" "$control_file"
        else
            sed -i "s/^command=.*/command=$command/" "$control_file"
        fi
    else
        echo "command=start" >> "$control_file"
    fi
fi
