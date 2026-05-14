#!/bin/bash
# Themarchy — Generate and apply Omarchy theme from current wallpaper colors

THEMARCHY_DIR="$HOME/.config/omarchy/themes/themarchy"

WALLPAPER=$(readlink -f "$HOME/.config/omarchy/current/background" 2>/dev/null)
if [[ -z "$WALLPAPER" || ! -f "$WALLPAPER" ]]; then
    WALLPAPER=$(pgrep -a swaybg 2>/dev/null | grep -oP '(?<=-i )\S+' | head -1)
fi
if [[ -z "$WALLPAPER" || ! -f "$WALLPAPER" ]]; then
    notify-send "Themarchy" "Could not detect current wallpaper" -u critical 2>/dev/null
    exit 1
fi

if ! command -v wal &>/dev/null; then
    notify-send "Themarchy" "pywal required (wal not found — install python-pywal)" -u critical 2>/dev/null
    exit 1
fi

mkdir -p "$THEMARCHY_DIR"

if ! wal -i "$WALLPAPER" -n -q 2>/dev/null; then
    notify-send "Themarchy" "pywal failed to generate palette" -u critical 2>/dev/null
    exit 1
fi

python3 << 'PYEOF' > "$THEMARCHY_DIR/colors.toml"
import json, sys, os

wal_json = os.path.expanduser("~/.cache/wal/colors.json")
try:
    with open(wal_json) as f:
        data = json.load(f)
except (OSError, json.JSONDecodeError):
    sys.exit(1)

special = data.get("special", {})
colors  = data.get("colors", {})

bg     = special.get("background", colors.get("color0", "#000000"))
fg     = special.get("foreground", colors.get("color7", "#ffffff"))
cursor = special.get("cursor", fg)
accent = colors.get("color5", colors.get("color1", fg))
sel_bg = accent
sel_fg = colors.get("color0", bg)

print(f'accent = "{accent}"')
print(f'cursor = "{cursor}"')
print(f'foreground = "{fg}"')
print(f'background = "{bg}"')
print(f'selection_foreground = "{sel_fg}"')
print(f'selection_background = "{sel_bg}"')
print()
for i in range(16):
    key = f"color{i}"
    val = colors.get(key, "#000000")
    print(f'{key} = "{val}"')
PYEOF

if [[ $? -ne 0 || ! -s "$THEMARCHY_DIR/colors.toml" ]]; then
    notify-send "Themarchy" "Failed to generate theme palette" -u critical 2>/dev/null
    exit 1
fi

# Generate themed fastfetch config from wallpaper palette
python3 << 'FASTFETCH_EOF'
import os, re, json

colors_file = os.path.expanduser("~/.config/omarchy/themes/themarchy/colors.toml")
colors = {}
try:
    with open(colors_file) as f:
        for line in f:
            m = re.match(r'^(\w+)\s*=\s*"(#[0-9a-fA-F]{6})"', line)
            if m:
                colors[m.group(1)] = m.group(2)
except OSError:
    pass

if not colors:
    exit(0)

accent  = colors.get('accent', None)
hw      = colors.get('color2', None)
sw      = colors.get('color4', None)
sys_col = colors.get('color5', None)

if not all([accent, hw, sw, sys_col]):
    exit(0)

config_path = os.path.expanduser("~/.config/fastfetch/config.jsonc")
try:
    with open(config_path) as f:
        config = json.loads(f.read())
except (OSError, json.JSONDecodeError):
    exit(0)

# Update logo accent color
if "logo" in config and isinstance(config["logo"].get("color"), dict):
    config["logo"]["color"]["1"] = accent

# Update keyColors by section: scan for custom separator headers to determine
# which color role to apply to the modules that follow.
section_colors = {"hardware": hw, "software": sw, "system": sys_col}
current_section = None

for module in config.get("modules", []):
    if not isinstance(module, dict):
        continue
    if module.get("type") == "custom":
        fmt = module.get("format", "")
        if "Hardware" in fmt:
            current_section = "hardware"
        elif "Software" in fmt:
            current_section = "software"
        elif "Age" in fmt:
            current_section = "system"
        continue
    if current_section and "keyColor" in module:
        module["keyColor"] = section_colors[current_section]

with open(config_path, 'w') as f:
    json.dump(config, f, indent=2, ensure_ascii=False)
    f.write('\n')
FASTFETCH_EOF


# Copy the current wallpaper into the themarchy theme BEFORE the theme swap,
# so omarchy-theme-bg-next finds it after current/theme is replaced.
WALLPAPER_REAL=$(readlink -f "$HOME/.config/omarchy/current/background" 2>/dev/null)
[[ -z "$WALLPAPER_REAL" || ! -f "$WALLPAPER_REAL" ]] && WALLPAPER_REAL="$WALLPAPER"
if [[ -n "$WALLPAPER_REAL" && -f "$WALLPAPER_REAL" ]]; then
    WALLPAPER_EXT="${WALLPAPER_REAL##*.}"
    mkdir -p "$THEMARCHY_DIR/backgrounds"
    rm -f "$THEMARCHY_DIR/backgrounds/"*
    cp "$WALLPAPER_REAL" "$THEMARCHY_DIR/backgrounds/0-wallpaper.$WALLPAPER_EXT"
fi

if omarchy-theme-set themarchy; then
    notify-send "Themarchy" "Theme applied from wallpaper!" 2>/dev/null
    exit 0
else
    notify-send "Themarchy" "Failed to apply theme" -u critical 2>/dev/null
    exit 1
fi
