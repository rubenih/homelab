#!/usr/bin/env bash
# Hook de pre-commit: falla si algún fichero contiene patrones reales de sanitize.local.
# sanitize.local (ignorado por git) tiene líneas "regex_real => sustituto"; aquí solo se usa el regex.
set -euo pipefail
cd "$(git rev-parse --show-toplevel)"
[ -f sanitize.local ] || { echo "Falta sanitize.local (ver scripts/sanitize.sh)"; exit 1; }
[ "$#" -gt 0 ] || exit 0
python3 -I - sanitize.local "$@" <<'PY'
import re, sys
pats = []
for line in open(sys.argv[1], encoding="utf-8"):
    line = line.rstrip("\n")
    if line.strip() and not line.lstrip().startswith("#"):
        pats.append(re.compile(line.partition(" => ")[0]))
blob = re.compile(r"data:image/[A-Za-z+]+[,;][A-Za-z0-9+/=,;]*")
bad = 0
for path in sys.argv[2:]:
    try:
        lines = open(path, encoding="utf-8").read().splitlines()
    except (UnicodeDecodeError, IsADirectoryError, FileNotFoundError):
        continue
    for n, l in enumerate(lines, 1):
        l = blob.sub("", l)
        for rx in pats:
            if rx.search(l):
                print(f"{path}:{n}: coincide con un patrón real")
                bad += 1
                break
if bad:
    print("ERROR: datos reales del lab. Ejecuta scripts/sanitize.sh sobre esos ficheros.")
    sys.exit(1)
PY
