#!/bin/bash

# Script de Respaldo de Los Sims 4 para HDD Externo
# Generado por Gemini CLI

# --- CONFIGURACIÓN ---
# La ruta de tus documentos de los Sims 4 (detectada automáticamente)
SIMS_SOURCE="/home/elyefris/.local/share/Steam/steamapps/compatdata/1222670/pfx/drive_c/users/steamuser/Documents/Electronic Arts/The Sims 4"

# Aquí debes poner la ruta de tu HDD Externo cuando esté conectado
# Ejemplo: "/run/media/elyefris/MiDiscoDuro/Backup_Sims4"
DEST_BASE="/run/media/$USER"

echo "🎮 Script de Respaldo de Los Sims 4"
echo "-----------------------------------"

# 1. Buscar el HDD Externo
echo "🔍 Buscando discos externos conectados en $DEST_BASE..."
DISCOS=($(ls "$DEST_BASE" 2>/dev/null))

if [ ${#DISCOS[@]} -eq 0 ]; then
    echo "❌ ERROR: No se detectó ningún disco duro externo en $DEST_BASE."
    echo "Asegúrate de que tu disco esté conectado y montado."
    exit 1
fi

# Seleccionar el primer disco detectado (o puedes editar esto para uno específico)
HDD_DEST="$DEST_BASE/${DISCOS[0]}/Backup_Sims4_$(date +%Y%m%d)"

echo "✅ Se usará el destino: $HDD_DEST"
echo "-----------------------------------"

# 2. Crear carpetas de destino
mkdir -p "$HDD_DEST"

# 3. Función de copia
backup_folder() {
    FOLDER_NAME=$1
    if [ -d "$SIMS_SOURCE/$FOLDER_NAME" ]; then
        echo "📦 Respaldando $FOLDER_NAME..."
        cp -r "$SIMS_SOURCE/$FOLDER_NAME" "$HDD_DEST/"
    else
        echo "⚠️ No se encontró la carpeta $FOLDER_NAME, saltando..."
    fi
}

# 4. Iniciar respaldo de carpetas críticas
backup_folder "saves"        # Partidas guardadas
backup_folder "Mods"         # Contenido personalizado
backup_folder "Tray"         # Tu biblioteca (casas/sims guardados)
backup_folder "Screenshots"  # Capturas de pantalla
backup_folder "Recorded Videos" # Videos
backup_folder "Custom Music" # Música personalizada

echo "-----------------------------------"
echo "✨ ¡Respaldo completado con éxito!"
echo "📍 Ubicación: $HDD_DEST"
echo "Recuerda revisar que todo esté ahí antes de formatear."
