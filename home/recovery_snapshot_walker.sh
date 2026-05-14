#!/bin/bash

echo "🍏 Iniciando recuperación de configuración post-snapshot..."

echo "🧹 1. Eliminando rastros y fantasmas de Waydroid..."
# Usamos sudo para los archivos de sistema que bloqueaban el borrado antes
sudo rm -rf /var/lib/waydroid
sudo rm -rf ~/.local/share/waydroid
rm -f ~/.local/share/applications/waydroid.*
rm -rf ~/.local/share/icons/hicolor/*/apps/waydroid.*
rm -rf ~/.cache/thumbnails/*

echo "🍎 2. Configurando Emojis de Apple y limpiando los de Google..."
# Eliminar las fuentes de emojis que causan conflictos
sudo pacman -Rs --noconfirm noto-fonts-emoji 2>/dev/null
yay -Rns --noconfirm ttf-joypixels ttf-twemoji 2>/dev/null

# Asegurar que el paquete de símbolos base esté instalado (para evitar los Tofu)
sudo pacman -S --noconfirm noto-fonts

# Reconstruir el archivo fonts.conf con la configuración impecable
mkdir -p ~/.config/fontconfig
cat << 'EOF' > ~/.config/fontconfig/fonts.conf
<?xml version="1.0"?>
<!DOCTYPE fontconfig SYSTEM "fonts.dtd">
<fontconfig>

  <match target="pattern">
    <test name="family" qual="any"><string>sans-serif</string></test>
    <edit name="family" mode="assign" binding="strong"><string>Liberation Sans</string></edit>
  </match>

  <match target="pattern">
    <test name="family" qual="any"><string>serif</string></test>
    <edit name="family" mode="assign" binding="strong"><string>Liberation Serif</string></edit>
  </match>

  <match target="pattern">
    <test name="family" qual="any"><string>monospace</string></test>
    <edit name="family" mode="assign" binding="strong"><string>JetBrainsMono Nerd Font</string></edit>
  </match>

  <alias>
    <family>sans-serif</family>
    <prefer><family>Apple Color Emoji</family></prefer>
  </alias>

  <alias>
    <family>serif</family>
    <prefer><family>Apple Color Emoji</family></prefer>
  </alias>

  <alias>
    <family>monospace</family>
    <prefer><family>Apple Color Emoji</family></prefer>
  </alias>

  <alias>
    <family>system-ui</family>
    <prefer>
      <family>Liberation Sans</family>
      <family>Apple Color Emoji</family>
    </prefer>
  </alias>

  <alias>
    <family>emoji</family>
    <prefer><family>Apple Color Emoji</family></prefer>
  </alias>

  <match target="pattern">
    <test qual="any" name="family"><string>sans-serif</string></test>
    <edit name="family" mode="append" binding="strong">
      <string>Apple Color Emoji</string>
    </edit>
  </match>

</fontconfig>
EOF

echo "🔄 Actualizando caché de fuentes de forma forzada..."
fc-cache -f -v > /dev/null

echo "💾 3. Configuración del HDD Secundario..."
echo "⚠️  ATENCIÓN: Por seguridad, la edición del fstab es manual."
echo "Se va a abrir nvim. Busca la línea de tu disco y añade al bloque de opciones:"
echo "👉 ,x-gvfs-show 👈 (pegado a 'defaults' o las opciones que tengas, separado por coma)."
echo ""
read -p "Presiona ENTER para abrir nvim..."
sudo nvim /etc/fstab

echo "🔄 Recargando puntos de montaje..."
sudo mount -a

echo "✅ ¡Recuperación completada, Jeff!"
echo "No olvides editar tu /etc/pacman.conf y añadir 'IgnorePkg = walker' antes de hacer tu próximo sudo pacman -Syu."
