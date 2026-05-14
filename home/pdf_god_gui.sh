#!/bin/bash

# ===== DEPENDENCIAS =====
for cmd in gs zenity zip; do
    command -v $cmd >/dev/null 2>&1 || {
        zenity --error --text="Falta instalar: $cmd\nEjecuta: sudo pacman -S $cmd"
        exit 1
    }
done

# ===== SELECCIONAR ARCHIVO =====
FILE=$(zenity --file-selection \
    --title="Selecciona un PDF" \
    --file-filter="*.pdf")

[ -z "$FILE" ] && exit 0

# ===== SELECCIONAR CALIDAD =====
QUALITY=$(zenity --list \
    --title="Calidad de compresión" \
    --column="Opción" --column="Descripción" \
    screen "Máxima compresión (baja calidad)" \
    ebook "Balance ideal" \
    printer "Alta calidad (recomendado)" \
    prepress "Casi sin pérdida" \
    --height=300 --width=500 | awk '{print $1}')

[ -z "$QUALITY" ] && exit 0

# ===== OPCIÓN ZIP =====
zenity --question --text="¿Deseas crear también un archivo ZIP?"
[ $? -eq 0 ] && ZIP=true || ZIP=false

# ===== NOMBRES =====
BASENAME=$(basename "$FILE" .pdf)
OUTPUT="${BASENAME}_comprimido.pdf"
ZIPFILE="${BASENAME}.zip"

# ===== PROCESO CON BARRA REAL =====
(
echo "10"; echo "# Iniciando compresión..."

gs -sDEVICE=pdfwrite \
   -dCompatibilityLevel=1.4 \
   -dPDFSETTINGS=/$QUALITY \
   -dNOPAUSE -dQUIET -dBATCH \
   -sOutputFile="$OUTPUT" \
   "$FILE"

echo "70"; echo "# Procesando archivo..."

sleep 1

if [ "$ZIP" = true ]; then
    echo "85"; echo "# Creando ZIP..."
    zip -9 "$ZIPFILE" "$OUTPUT" >/dev/null
fi

echo "100"; echo "# Finalizado!"

) | zenity --progress \
    --title="Compresor PDF GOD" \
    --percentage=0 \
    --auto-close

# ===== RESULTADO =====
if [ "$ZIP" = true ]; then
    zenity --info --text="✅ Listo!\n\nPDF: $OUTPUT\nZIP: $ZIPFILE"
else
    zenity --info --text="✅ Listo!\n\nPDF: $OUTPUT"
fi
