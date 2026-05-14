#!/bin/bash

# Script to handle idle/resume actions for Waybar and Screensaver
PATH=$PATH:$HOME/.local/share/omarchy/bin

ACTION=$1
FLAG="$HOME/.local/state/omarchy/toggles/waybar-off"

# Helper to hide waybar
hide_waybar() {
    if pgrep -x waybar >/dev/null; then
        pkill -x waybar
    fi
    # Ensure flag is present
    mkdir -p "$(dirname "$FLAG")"
    touch "$FLAG"
}

# Helper to show waybar
show_waybar() {
    # Remove flag first so it doesn't interfere
    if [[ -f "$FLAG" ]]; then
        rm "$FLAG"
    fi
    # Restart waybar properly
    if ! pgrep -x waybar >/dev/null; then
        setsid uwsm-app -- waybar >/dev/null 2>&1 &
    fi
}

case $ACTION in
    timeout-screensaver)
        if ! pidof hyprlock >/dev/null; then
            omarchy launch screensaver
            hide_waybar
        fi
        ;;
    resume-screensaver)
        pidof hyprlock >/dev/null || show_waybar
        ;;
    timeout-lock)
        hide_waybar
        omarchy system lock
        ;;
    resume-lock)
        show_waybar
        omarchy system wake
        ;;
esac
