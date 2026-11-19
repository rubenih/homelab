#!/usr/bin/env bash
# Sustituye datos reales por marcadores en los ficheros indicados (in situ).
# Uso: scripts/sanitize.sh fichero1 [fichero2 ...]
#
# Las reglas se leen de sanitize.local (ignorado por git), una por línea:
#   regex_real|sustituto
# Ejemplo (no uses estos valores, son ilustrativos):
#   172\.99\.([0-9]+)\.|10.0.\1.
#   midominio\.tld|example.com
#   ([0-9A-Fa-f]{2}:){5}[0-9A-Fa-f]{2}|XX:XX:XX:XX:XX:XX
set -euo pipefail
cd "$(git rev-parse --show-toplevel)"
[ -f sanitize.local ] || { echo "Falta sanitize.local"; exit 1; }
[ "$#" -gt 0 ] || { echo "Uso: $0 fichero..."; exit 1; }
while IFS='|' read -r from to; do
  [[ -z "$from" || "$from" == \#* ]] && continue
  sed -E -i "s#${from}#${to}#g" "$@"
done < sanitize.local
echo "Saneado. Revisa el diff y ejecuta: scripts/check-real-data.sh $*"
