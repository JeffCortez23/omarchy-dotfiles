#!/bin/bash

# Configuration paths
COLORS_FILE="$HOME/.config/omarchy/current/theme/colors.toml"
TEMPLATE_FILE="$HOME/.config/fastfetch/config.jsonc.template"
OUTPUT_FILE="$HOME/.config/fastfetch/config.jsonc"

# Check if colors file exists
if [ ! -f "$COLORS_FILE" ]; then
    echo "Omarchy colors file not found at $COLORS_FILE"
    exit 1
fi

# Function to get hex from TOML
get_hex() {
    grep "^$1 =" "$COLORS_FILE" | head -n 1 | cut -d'"' -f2
}

# Function to convert hex to ANSI escape (\u001b[38;2;R;G;Bm)
# We use \\u001b because it's for a JSON file
hex_to_ansi() {
    local hex=${1:1}
    local r=$(printf "%d" "0x${hex:0:2}")
    local g=$(printf "%d" "0x${hex:2:2}")
    local b=$(printf "%d" "0x${hex:4:2}")
    echo "\\\\u001b[38;2;${r};${g};${b}m"
}

# Extract colors
C1=$(get_hex "color1")
C5=$(get_hex "color5")
C7=$(get_hex "color7")

# Fallbacks
[[ -z "$C1" ]] && C1="#f7768e"
[[ -z "$C5" ]] && C5="#bb9af7"
[[ -z "$C7" ]] && C7="#c0caf5"

# Convert to ANSI
A1=$(hex_to_ansi "$C1")
A5=$(hex_to_ansi "$C5")
A7=$(hex_to_ansi "$C7")

# Replace placeholders in template and write to config
sed -e "s/__C1__/$C1/g" \
    -e "s/__C5__/$C5/g" \
    -e "s/__C7__/$C7/g" \
    -e "s/__A1__/$A1/g" \
    -e "s/__A5__/$A5/g" \
    -e "s/__A7__/$A7/g" \
    "$TEMPLATE_FILE" > "$OUTPUT_FILE"

echo "Fastfetch colors updated using theme color mapping."
