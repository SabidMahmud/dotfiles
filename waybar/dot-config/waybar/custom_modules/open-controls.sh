#!/usr/bin/env bash

case "${1:-}" in
    network) settings=(nm-connection-editor) ;;
    sound) settings=(pavucontrol) ;;
    bluetooth) settings=(blueman-manager) ;;
    power) settings=(tuned-switcher) ;;
    brightness) settings=() ;;
    *) exit 2 ;;
esac

config="${XDG_CONFIG_HOME:-$HOME/.config}/quickshell/waybar-controls/shell.qml"
if command -v quickshell >/dev/null && [[ -r "$config" ]]; then
    if WAYBAR_CONTROL_SECTION="$1" quickshell --no-duplicate --path "$config"; then
        exit 0
    fi
fi

if (( ${#settings[@]} )); then
    exec "${settings[@]}"
fi
exit 1
