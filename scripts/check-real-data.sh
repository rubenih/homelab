#!/usr/bin/env bash
# Hook de pre-commit: falla si algún fichero contiene patrones de sanitize.local.
# sanitize.local (ignorado por git) tiene líneas "patrón_real|sustituto"; aquí solo se usa el patrón.
set -euo pipefail
cd "$(git rev-parse --show-toplevel)"
[ -f sanitize.local ] || { echo "Falta sanitize.local (ver scripts/sanitize.sh)"; exit 1; }
patterns=$(grep -vE '^\s*(#|$)' sanitize.local | cut -d'|' -f1)
[ -n "$patterns" ] || exit 0
[ "$#" -gt 0 ] || exit 0
if grep -nIE -f <(printf '%s\n' "$patterns") -- "$@"; then
  echo "ERROR: datos reales del lab en los ficheros de arriba. Ejecuta scripts/sanitize.sh"
  exit 1
fi
