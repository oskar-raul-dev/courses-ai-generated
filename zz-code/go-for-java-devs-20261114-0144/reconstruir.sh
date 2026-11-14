#!/usr/bin/env bash
# Reconstruye lector/ con las fases 00..N (N = primer argumento, p. ej. 03) y aplica completar.py.
set -euo pipefail
cd "$(dirname "$0")"
C=../../cursos-algoritmos-lenguajes/go-for-java-devs
N=$1
rm -f salidas/fusionados.txt
rm -rf lector
fases=$(ls $C/[01][0-9]-*.md | awk -v n="$N" -F/ '{f=$NF; if (substr(f,1,2) <= n) print}')
python3 extraer.py $fases | grep -c . | sed 's/^/bloques escritos: /'
rm -f lector/main.go
python3 completar.py
cp -f salidas/fusionados.txt scripts/fusionados.txt 2>/dev/null || : > scripts/fusionados.txt
