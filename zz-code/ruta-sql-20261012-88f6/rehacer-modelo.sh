#!/usr/bin/env bash
# Después de `lab load`, rehace staging y alameda corriendo en orden los scripts de las fases ya escritas.
# Uso: ./rehacer-modelo.sh  (desde este directorio, con el laboratorio arriba y M cargado)
set -euo pipefail
cd "$(dirname "$0")"
SRC=../../cursos-bd/ruta-sql/src
PSQL=(docker exec -i alameda-lab-postgres-1 psql -q -v ON_ERROR_STOP=1 -U postgres -d alameda)
for f in "$SRC"/04-*/0*.sql "$SRC"/05-*/0*.sql "$SRC"/06-*/01_*.sql "$SRC"/06-*/02_*.sql; do
  echo "== $f"; "${PSQL[@]}" < "$f" 2>&1 | grep -v NOTICE || true
done
python3 -I "$SRC"/06-*/xlsx_to_csv.py salidas/caja/m/planillas/convenios_2026.xlsx \
  | docker exec -i alameda-lab-postgres-1 psql -U postgres -d alameda -c "\copy staging.agreement_raw FROM STDIN CSV HEADER"
for f in "$SRC"/06-*/0[3-9]_*.sql "$SRC"/07-*/0*.sql; do
  [ -e "$f" ] || continue
  echo "== $f"; "${PSQL[@]}" < "$f" 2>&1 | grep -v NOTICE || true
done
