#!/usr/bin/env bash
# Recomprime un video crudo (ej. export de dron) al patron liviano del sitio:
# H.264, sin audio, 720p, ~30fps, + poster .webp opcional.
# Uso:
#   scripts/optimize-video.sh <input.mp4> <output.mp4> [crf] [ancho] [inicio_seg] [fin_seg]
#
# Ejemplos:
#   scripts/optimize-video.sh "~/Desktop/DJI_0001.MP4" imgs/proyecto-vid.mp4
#   scripts/optimize-video.sh "~/Desktop/DJI_0001.MP4" imgs/proyecto-vid.mp4 27 1280 7 9
#
# Requiere ffmpeg en PATH. Genera tambien <output sin .mp4>-poster.webp con un frame cercano al inicio.

set -euo pipefail

if [ "$#" -lt 2 ]; then
  echo "Uso: $0 <input.mp4> <output.mp4> [crf] [ancho] [inicio_seg] [fin_seg]" >&2
  exit 1
fi

IN="$1"
OUT="$2"
CRF="${3:-27}"
WIDTH="${4:-1280}"
START="${5:-}"
END="${6:-}"

if [ ! -f "$IN" ]; then
  echo "No existe el archivo de origen: $IN" >&2
  exit 1
fi

TRIM_ARGS=()
if [ -n "$START" ]; then TRIM_ARGS+=(-ss "$START"); fi
if [ -n "$END" ]; then TRIM_ARGS+=(-to "$END"); fi

ffmpeg -y "${TRIM_ARGS[@]}" -i "$IN" -vf "scale=${WIDTH}:-2,fps=30" -c:v libx264 -crf "$CRF" -preset medium -an -movflags +faststart "$OUT" -loglevel error

POSTER="${OUT%.mp4}-poster.webp"
ffmpeg -y -ss 0.3 -i "$OUT" -vframes 1 -vf "scale=1200:-2" -q:v 80 "$POSTER" -loglevel error

echo "Listo: $OUT ($(du -h "$OUT" | cut -f1)) + poster $POSTER"
echo "Recordatorio: revisar el clip entero antes de usarlo -- muchos exports de dron/redes"
echo "tienen intro/outro/texto quemado que no sirve para loop (ver dron1.mp4 en la historia del repo)."
