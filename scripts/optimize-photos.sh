#!/usr/bin/env bash
# Convierte un lote de fotos (jpg/png) al patron webp del sitio: full + -thumb (1200) + -sm (640).
# Uso:
#   scripts/optimize-photos.sh <carpeta_origen> <carpeta_destino> <prefijo> [indice_inicial]
#
# Ejemplo (fotos de un evento nuevo, numeradas prefijo-01, prefijo-02, ...):
#   scripts/optimize-photos.sh "/c/Users/Home/Desktop/Fotos Evento" proyectos/her-araoz/imgs evento-2026-01 1
#
# Requiere ffmpeg en PATH.

set -euo pipefail

if [ "$#" -lt 3 ]; then
  echo "Uso: $0 <carpeta_origen> <carpeta_destino> <prefijo> [indice_inicial]" >&2
  exit 1
fi

SRC="$1"
DEST="$2"
PREFIX="$3"
START="${4:-1}"

if [ ! -d "$SRC" ]; then
  echo "No existe la carpeta de origen: $SRC" >&2
  exit 1
fi

mkdir -p "$DEST"

i="$START"
shopt -s nullglob nocaseglob
files=("$SRC"/*.jpg "$SRC"/*.jpeg "$SRC"/*.png)
shopt -u nocaseglob

if [ "${#files[@]}" -eq 0 ]; then
  echo "No se encontraron .jpg/.jpeg/.png en $SRC" >&2
  exit 1
fi

for f in "${files[@]}"; do
  num=$(printf "%02d" "$i")
  out="$DEST/${PREFIX}-${num}"
  echo "→ ${PREFIX}-${num}  (${f##*/})"
  ffmpeg -y -i "$f" -vf "scale=w=1920:h=1920:force_original_aspect_ratio=decrease" -q:v 80 "${out}.webp" -loglevel error
  ffmpeg -y -i "$f" -vf "scale=w=1200:h=1200:force_original_aspect_ratio=decrease" -q:v 80 "${out}-thumb.webp" -loglevel error
  ffmpeg -y -i "$f" -vf "scale=w=640:h=640:force_original_aspect_ratio=decrease" -q:v 80 "${out}-sm.webp" -loglevel error
  i=$((i+1))
done

echo "Listo: $((i - START)) fotos procesadas en $DEST"
echo "Recordatorio: sumar los <img> nuevos al array de fotos del HTML (file + alt) y probar antes de commitear."
