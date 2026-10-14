#!/usr/bin/env bash
# Extracts the T1 test inputs from the course markdown into sondas/angular8/extraidos/.
set -euo pipefail
cd "$(dirname "$0")/.."
: "${CURSO:?set CURSO}"
x() { python3 extraer/bloque.py "$@"; }
E=sondas/angular8/extraidos
mkdir -p $E
x 08-resultados-rangos.md "export function selectActiveRange" > $E/reference-range.selector.ts
x 04-mock-api-caos.md '"referenceRanges": [' > $E/fase04-db.json
x prompts/preparaciones-de-incidentes.md '"id": 612,' > $E/prep07.jsonc
x cuaderno-incidentes.md "un borde escrito en UTC adelanta la norma nueva" > $E/inc07-regression.spec.ts
x 05-pacientes.md "function toLocalDate(isoDate: string)" | sed -n '/^function toLocalDate/,/^}/p' > $E/fase05-toLocalDate.ts
x 02-i18n.md "export class AppDatePipe" > $E/app-date.pipe.ts
x 09-entrega-pdf.md "formatDate(iso: string): string" | sed -n '/formatDate(iso: string)/,/^  }/p' > $E/fase09-formatDate.ts
wc -l $E/*
