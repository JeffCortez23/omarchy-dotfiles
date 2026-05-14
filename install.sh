#!/bin/bash

# Omarchy Dotfiles Installation Script
# Updated by Gemini CLI

set -e

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_DIR="$HOME/.config"
THEMES_DIR="$CONFIG_DIR/omarchy/themes"

echo "🚀 Starting Omarchy dotfiles restoration..."

# 1. Install Software
if [ -f "$DOTFILES_DIR/scripts/pkg_native.txt" ]; then
    echo "📦 Installing native packages (pacman)..."
    sudo pacman -S --needed --noconfirm - < "$DOTFILES_DIR/scripts/pkg_native.txt" || echo "⚠️ Some native packages failed to install."
fi

if [ -f "$DOTFILES_DIR/scripts/pkg_aur.txt" ] && command -v yay >/dev/null; then
    echo "📦 Installing AUR packages (yay)..."
    yay -S --needed --noconfirm - < "$DOTFILES_DIR/scripts/pkg_aur.txt" || echo "⚠️ Some AUR packages failed to install."
elif [ -f "$DOTFILES_DIR/scripts/pkg_aur.txt" ]; then
    echo "⚠️ yay (AUR helper) not found. Skipping AUR packages. Install yay first if needed."
fi

if [ -f "$DOTFILES_DIR/scripts/pkg_flatpak.txt" ] && command -v flatpak >/dev/null; then
    echo "📦 Installing Flatpaks..."
    while read -r pkg; do
        flatpak install -y flathub "$pkg" || echo "⚠️ Failed to install Flatpak: $pkg"
    done < "$DOTFILES_DIR/scripts/pkg_flatpak.txt"
fi

# 2. Restore .config files
echo "⚙️ Restoring configuration files to $CONFIG_DIR..."
mkdir -p "$CONFIG_DIR"
cp -r "$DOTFILES_DIR/config/"* "$CONFIG_DIR/"

# 3. Restore home directory files (including scripts)
echo "🏠 Restoring home directory files and scripts..."
cp -r "$DOTFILES_DIR/home/".* "$HOME/" 2>/dev/null || true
cp "$DOTFILES_DIR/home/"* "$HOME/" 2>/dev/null || true
# Ensure scripts are executable
chmod +x ~/*.sh 2>/dev/null || true

# 4. Restore Web Apps (Desktop entries)
if [ -d "$DOTFILES_DIR/webapps" ]; then
    echo "🌐 Restoring Web App desktop entries..."
    mkdir -p "$HOME/.local/share/applications"
    cp "$DOTFILES_DIR/webapps/"* "$HOME/.local/share/applications/"
fi

# 5. Restore themes from URLs
if [ -f "$DOTFILES_DIR/scripts/themes_urls.txt" ]; then
    echo "🎨 Restoring installed themes (this may take a while)..."
    mkdir -p "$THEMES_DIR"
    while IFS="|" read -r theme url; do
        if [ -n "$theme" ] && [ -n "$url" ]; then
            if [ ! -d "$THEMES_DIR/$theme" ]; then
                echo "📥 Cloning theme: $theme..."
                git clone --depth 1 "$url" "$THEMES_DIR/$theme" || echo "⚠️ Failed to clone $theme"
            else
                echo "✅ Theme $theme already exists, skipping."
            fi
        fi
    done < "$DOTFILES_DIR/scripts/themes_urls.txt"
fi

echo "✨ Restoration complete!"
echo "🔄 Running omarchy refresh to apply changes..."
omarchy refresh waybar || true
omarchy refresh walker || true
hyprctl reload || true

echo "🎉 Done! You might need to restart your session for some changes to take effect."
