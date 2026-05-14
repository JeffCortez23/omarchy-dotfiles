#!/bin/bash

# ===== DEPENDENCIAS =====
command -v gs >/dev/null 2>&1 || { echo "❌ Instala ghostscript: sudo pacman -S ghostscript"; exit 1; }
command -v zip >/dev/null 2>&1 || { echo "❌ Instala zip: sudo pacman -S zip"; exit 1; }

# ===== COLORES =====
GREEN="\e[32m"
RED="\e[31m"
YELLOW="\e[33m"
CYAN="\e[36m"
RESET="\e[0m"

# ===== BARRA DE PROGRESO =====
progress_bar() {
    local duration=$1
    local steps=30
    local delay=$(echo "$duration / $steps" | bc -l)

    for ((i=0; i<=steps; i++)); do
        filled=$(printf "%${i}s" | tr ' ' '#')
        empty=$(printf "%$((steps-i))s")
        printf "\r⏳ [%s%s]" "$filled" "$empty"
        sleep $delay
    done
    echo ""
}

# ===== MENÚ =====
menu() {
    echo -e "${CYAN}=== COMPRESOR PDF NIVEL DIOS ===${RESET}"
    echo "1) Alta compresión (screen)"
    echo "2) Balance ideal (ebook)"
    echo "3) Alta calidad (printer)"
    echo "4) Casi sin pérdida (prepress)"
    echo ""
    read -p "Elige opción [1-4]: " opt

    case $opt in
        1) QUALITY="screen" ;;
        2) QUALITY="ebook" ;;
        3) QUALITY="printer" ;;
        4) QUALITY="prepress" ;;
        *) echo -e "${RED}Opción inválida${RESET}"; exit 1 ;;
    esac

    read -p "¿Crear ZIP también? (s/n): " zipopt
    [[ "$zipopt" =~ ^[sS]$ ]] && ZIP=true || ZIP=false
}

# ===== SI NO PASA ARCHIVO → MENÚ =====
if [ "$#" -eq 0 ]; then
    menu
    read -p "Arrastra el/los PDF aquí: " FILES
    set -- $FILES
else
    QUALITY="printer"
    ZIP=false
fi

# ===== PROCESAMIENTO =====
for INPUT in "$@"; do

    if [[ ! -f "$INPUT" ]]; then
        echo -e "${YELLOW}⚠️ No encontrado: $INPUT${RESET}"
        continue
    fi

    BASENAME=$(basename "$INPUT" .pdf)
    OUTPUT="${BASENAME}_comprimido.pdf"
    ZIPFILE="${BASENAME}.zip"

    echo -e "${GREEN}📄 Procesando: $INPUT${RESET}"
    echo -e "⚙️ Calidad: $QUALITY"

    # Ejecutar compresión en background
    gs -sDEVICE=pdfwrite \
       -dCompatibilityLevel=1.4 \
       -dPDFSETTINGS=/$QUALITY \
       -dNOPAUSE -dQUIET -dBATCH \
       -sOutputFile="$OUTPUT" \
       "$INPUT" &

    PID=$!

    # Barra fake (mientras corre gs)
    while kill -0 $PID 2>/dev/null; do
        progress_bar 0.5
    done

    wait $PID

    if [ $? -ne 0 ]; then
        echo -e "${RED}❌ Error en $INPUT${RESET}"
        continue
    fi

    echo -e "${GREEN}✅ PDF listo: $OUTPUT${RESET}"

    if [ "$ZIP" = true ]; then
        zip -9 "$ZIPFILE" "$OUTPUT" >/dev/null
        echo -e "📦 ZIP: $ZIPFILE"
    fi

    echo ""
done
