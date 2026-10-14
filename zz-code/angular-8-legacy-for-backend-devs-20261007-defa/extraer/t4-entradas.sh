#!/usr/bin/env bash
# Extracts incident 22 blocks (detector, spec, preparation data) into sondas/angular8/inc22/.
# Source: the course (CURSO) once inserted; before insertion, pass FUENTE=ediciones to read the fragments.
set -euo pipefail
cd "$(dirname "$0")/.."
: "${CURSO:?set CURSO}"
I=sondas/angular8/inc22
blk() {  # file needle
  if [ "${FUENTE:-curso}" = ediciones ]; then CURSO="$PWD/ediciones" python3 extraer/bloque.py "$@"; else python3 extraer/bloque.py "$@"; fi
}
if [ "${FUENTE:-curso}" = ediciones ]; then C=t4-incidente22.md; P=t4-preparacion22.md; else C=cuaderno-incidentes.md; P=prompts/preparaciones-de-incidentes.md; fi
blk $C "export function offsetDoesNotMatchZone" > $I/offset-check.ts
blk $C "describe('offsetDoesNotMatchZone'" > $I/offset-check.spec.ts
blk $P '"id": 7202' > $I/prep22.jsonc
blk $C "toLocaleString('es', { timeZone: 'America/Toronto' })" > $I/tolocale.js
cp sondas/angular8/extraidos/app-date.pipe.ts $I/app-date.pipe.ts
wc -l $I/*.ts $I/*.jsonc $I/*.js
