#!/bin/bash

# Verificar que el script se ejecuta como root (superusuario)
if [ "$EUID" -ne 0 ]; then
  echo "Por favor, ejecuta este script como root (usando sudo)."
  exit 1
fi

echo "=========================================="
echo "Iniciando liberación extrema de memoria RAM..."
echo "=========================================="

echo "Memoria antes de la limpieza:"
free -h
echo "------------------------------------------"

# 1. Sincronizar los datos en caché con el disco duro
echo "[1/4] Sincronizando datos con el disco..."
sync; sync; sync;

# 2. Liberar PageCache, dentries e inodes
echo "[2/4] Liberando la caché de la memoria RAM (drop_caches)..."
echo 3 > /proc/sys/vm/drop_caches

# 3. Compactar la memoria
# Esto reorganiza la memoria para crear bloques contiguos más grandes,
# lo que ayuda a reducir la fragmentación de la RAM.
echo "[3/4] Compactando la memoria fragmentada..."
echo 1 > /proc/sys/vm/compact_memory

# 4. Vaciar la memoria Swap
# Mueve los datos de la Swap a la RAM y luego vuelve a activarla.
# Nota: Si tu RAM está físicamente al límite, esto puede tardar o congelar el PC un momento.
#echo "[4/4] Limpiando la partición Swap (puede tardar un momento)..."
#swapoff -a && swapon -a

echo "------------------------------------------"
echo "Memoria después de la limpieza:"
free -h
echo "=========================================="
echo "¡Liberación máxima de RAM completada!"
echo "=========================================="
