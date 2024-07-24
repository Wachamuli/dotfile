keyboard_layout_info=$(hyprctl -j devices)

availables=$(echo $keyboard_layout_info | jq -r '.keyboards[-1].layout')
active_keymap=$(echo $keyboard_layout_info | jq -r '.keyboards[-1].active_keymap' | awk '{print $1}')

case "$active_keymap" in
    "English")
        abbreviated_keymap="US"
        ;;
    "Spanish")
        abbreviated_keymap="ES"
        ;;
    *)
        abbreviated_keymap=$active_keymap
        ;;
esac

output=$(cat << EOM 
{ 
    "keymaps": "[${availables}]",
    "active_keymap": "${active_keymap}",
    "abbreviated_active_keymap": "${abbreviated_keymap}" 
}
EOM
)


echo $output
