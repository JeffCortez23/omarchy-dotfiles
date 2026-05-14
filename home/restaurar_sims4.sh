#!/bin/bash

# Script de Restauración de Los Sims 4 desde HDD Externo
# Generado por Gemini CLI

# --- CONFIGURACIÓN ---
# La ruta de destino (donde Steam guarda los documentos de los Sims 4)
SIMS_DEST="/home/elyefris/.local/share/Steam/steamapps/compatdata/1222670/pfx/drive_c/users/steamuser/Documents/Electronic Arts/The Sims 4"

# Base de búsqueda de discos externos
DEST_BASE="/run/media/$USER"

echo "🎮 Script de Restauración de Los Sims 4"
echo "---------------------------------------"

# 1. Verificar si el juego ya fue instalado/ejecutado al menos una vez
if [ ! -d "$SIMS_DEST" ]; then
    echo "❌ ERROR: No se encontró la carpeta de destino en:"
    echo "$SIMS_DEST"
    echo ""
    echo "TIP: Primero instala Los Sims 4 en Steam y ejecútalo al menos una vez"
    echo "para que el sistema cree las carpetas necesarias."
    exit 1
fi

# 2. Buscar el respaldo en el HDD Externo
echo "🔍 Buscando respaldos en discos externos..."
DISCOS=($(ls "$DEST_BASE" 2>/dev/null))

if [ ${#DISCOS[@]} -eq 0 ]; then
    echo "❌ ERROR: No se detectó ningún disco duro externo conectado."
    exit 1
fi

# Buscar carpetas que empiecen con Backup_Sims4_
RESPALDO_PATH=$(find "$DEST_BASE" -maxdepth 2 -name "Backup_Sims4_*" -type d | sort -r | head -n 1)

if [ -z "$RESPALDO_PATH" ]; then
    echo "❌ ERROR: No se encontró ninguna carpeta de respaldo 'Backup_Sims4_...' en tus discos."
    exit 1
fi

echo "✅ Respaldo encontrado en: $RESPALDO_PATH"
echo "❓ ¿Deseas restaurar estos archivos ahora? (s/n)"
read -r respuesta

if [[ "$respuesta" != "s" ]]; then
    echo "🚫 Restauración cancelada."
    exit 0
fi

# 3. Función de restauración
restore_folder() {
    FOLDER_NAME=$1
    if [ -d "$RESPALDO_PATH/$FOLDER_NAME" ]; then
        echo "📥 Restaurando $FOLDER_NAME..."
        # Borrar carpeta actual para evitar conflictos y copiar la del respaldo
        rm -rf "$SIMS_DEST/$FOLDER_NAME"
        cp -r "$RESPALDO_PATH/$FOLDER_NAME" "$SIMS_DEST/"
    else
        echo "⚠️ No se encontró la carpeta $FOLDER_NAME en el respaldo, saltando..."
    fi
}

# 4. Iniciar restauración
echo "---------------------------------------"
restore_folder "saves"
restore_folder "Mods"
restore_folder "Tray"
restore_folder "Screenshots"
restore_folder "Recorded Videos"
restore_folder "Custom Music"

echo "---------------------------------------"
echo "✨ ¡Restauración completada con éxito!"
echo "🎮 Ya puedes abrir Los Sims 4 y todo debería estar ahí."
