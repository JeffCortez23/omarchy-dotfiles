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
fi

if [ -f "$DOTFILES_DIR/scripts/pkg_flatpak.txt" ] && command -v flatpak >/dev/null; then
    echo "📦 Installing Flatpaks..."
    while read -r pkg; do
        flatpak install -y flathub "$pkg" || echo "⚠️ Failed to install Flatpak: $pkg"
    done < "$DOTFILES_DIR/scripts/pkg_flatpak.txt"
fi

if [ -f "$DOTFILES_DIR/scripts/pkg_npm.txt" ] && command -v npm >/dev/null; then
    echo "📦 Installing global NPM packages..."
    while read -r pkg; do
        if [ -n "$pkg" ]; then
            sudo npm install -g "$pkg" || echo "⚠️ Failed to install NPM package: $pkg"
        fi
    done < "$DOTFILES_DIR/scripts/pkg_npm.txt"
fi

if [ -f "$DOTFILES_DIR/scripts/pkg_pip.txt" ] && command -v pip >/dev/null; then
    echo "📦 Installing user Pip packages..."
    pip install --user -r "$DOTFILES_DIR/scripts/pkg_pip.txt" || echo "⚠️ Some Pip packages failed to install."
fi

# 2. Restore .config files
echo "⚙️ Restoring configuration files to $CONFIG_DIR..."
mkdir -p "$CONFIG_DIR"
cp -r "$DOTFILES_DIR/config/"* "$CONFIG_DIR/"

# 3. Restore home directory files and scripts
echo "🏠 Restoring home directory files and scripts..."
cp -r "$DOTFILES_DIR/home/".* "$HOME/" 2>/dev/null || true
cp "$DOTFILES_DIR/home/"* "$HOME/" 2>/dev/null || true
chmod +x ~/*.sh 2>/dev/null || true

# 4. Restore local binaries
if [ -d "$DOTFILES_DIR/local-bin" ]; then
    echo "📂 Restoring local binaries to ~/.local/bin..."
    mkdir -p "$HOME/.local/bin"
    cp -r "$DOTFILES_DIR/local-bin/"* "$HOME/.local/bin/"
    chmod +x "$HOME/.local/bin/"* 2>/dev/null || true
fi

# 5. Restore Desktop entries (Web Apps & Apps)
if [ -d "$DOTFILES_DIR/desktop-entries" ]; then
    echo "🌐 Restoring desktop entries..."
    mkdir -p "$HOME/.local/share/applications"
    cp "$DOTFILES_DIR/desktop-entries/"* "$HOME/.local/share/applications/"
fi

# 6. Restore themes from URLs
if [ -f "$DOTFILES_DIR/scripts/themes_urls.txt" ]; then
    echo "🎨 Restoring installed themes..."
    mkdir -p "$THEMES_DIR"
    while IFS="|" read -r theme url; do
        if [ -n "$theme" ] && [ -n "$url" ]; then
            if [ ! -d "$THEMES_DIR/$theme" ]; then
                echo "📥 Cloning theme: $theme..."
                git clone --depth 1 "$url" "$THEMES_DIR/$theme" || echo "⚠️ Failed to clone $theme"
            fi
        fi
    done < "$DOTFILES_DIR/scripts/themes_urls.txt"
fi

echo "✨ Restoration complete!"
echo "🔄 Running omarchy refresh to apply changes..."
omarchy refresh waybar || true
omarchy refresh walker || true
hyprctl reload || true

echo "🎉 Done!"
