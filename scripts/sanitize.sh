#!/usr/bin/env bash
# Sustituye datos reales por marcadores en los ficheros indicados (in situ).
# Uso: scripts/sanitize.sh fichero1 [fichero2 ...]
#
# Las reglas se leen de sanitize.local (ignorado por git), una por línea, en orden:
#   regex_real => sustituto
# Ejemplos ilustrativos (no son los valores reales):
#   172\.99\.([0-9]+)\. => 10.0.\1.
#   midominio\.tld => example.com
#   ([0-9A-Fa-f]{2}:){5}[0-9A-Fa-f]{2} => XX:XX:XX:XX:XX:XX
set -euo pipefail
cd "$(git rev-parse --show-toplevel)"
[ -f sanitize.local ] || { echo "Falta sanitize.local"; exit 1; }
[ "$#" -gt 0 ] || { echo "Uso: $0 fichero..."; exit 1; }
python3 -I - sanitize.local "$@" <<'PY'
import re, sys
rules = []
for line in open(sys.argv[1], encoding="utf-8"):
    line = line.rstrip("\n")
    if not line.strip() or line.lstrip().startswith("#"):
        continue
    src, _, dst = line.partition(" => ")
    rules.append((re.compile(src), dst))
for path in sys.argv[2:]:
    text = open(path, encoding="utf-8").read()
    for rx, dst in rules:
        text = rx.sub(dst, text)
    open(path, "w", encoding="utf-8").write(text)
PY
echo "Saneado. Revisa el diff y ejecuta: scripts/check-real-data.sh $*"
