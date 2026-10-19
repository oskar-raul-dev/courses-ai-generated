#!/usr/bin/env bash
# T2b: todo core/{models,domain,time,pdf} con los specs puros de F12 compila con el
# tsconfig estricto del curso, y los specs sin Angular corren en Jasmine 4.6.
set -euo pipefail
AQUI="$(cd "$(dirname "$0")" && pwd)"
CURSO="${CURSO:-$AQUI/../../cursos-legacy/angular-16-legacy-for-backend-devs}"
IMAGEN="node:18.18.2-alpine"
SAL="$AQUI/salidas/src-t2b"
mkdir -p "$AQUI/salidas"

python3 "$AQUI/extraer.py" --curso "$CURSO" --specs --salida "$SAL" | tee "$AQUI/salidas/extraccion-t2b.txt"

# core/api no se reconstruye (sus "lo que se añade" son métodos DENTRO de la clase).
# derive-all-findings.ts solo necesita buildTemplateRowId: se copia la cabecera del
# bloque de F07 tal como está, hasta la marca "// …dentro de TemplateApiService…".
python3 - "$CURSO/07-plantillas-versionadas.md" "$SAL/src/app/core/api/template-api.service.ts" <<'PY'
import sys, pathlib
texto = pathlib.Path(sys.argv[1]).read_text(encoding="utf-8")
inicio = texto.index("// src/app/core/api/template-api.service.ts — lo que se añade")
fin = texto.index("// …dentro de TemplateApiService…", inicio)
destino = pathlib.Path(sys.argv[2]); destino.parent.mkdir(parents=True, exist_ok=True)
destino.write_text(texto[inicio:fin], encoding="utf-8")
print("cabecera de template-api.service.ts copiada de F07")
PY

corre() {
  docker run --rm --label curso=angular16 -e NPM_CONFIG_UPDATE_NOTIFIER=false -v "$AQUI":/w -w /w "$IMAGEN" sh -c "$1"
}
[ -d "$AQUI/node_modules/jasmine" ] || corre "npm install --no-audit --no-fund --loglevel=error"

# 1. Compilación estricta de todo lo extraído, specs incluidos (tsconfig.t2b.json).
corre "npx tsc -p tsconfig.t2b.json" > "$AQUI/salidas/tsc-t2b.txt" 2>&1 \
  && echo "tsc t2b: OK" || { echo "tsc t2b: FALLA"; cat "$AQUI/salidas/tsc-t2b.txt"; }

# 2. Los specs que no dependen de Angular, a CommonJS y en Jasmine (orden aleatorio, como Karma).
corre "npx tsc -p tsconfig.t2b-run.json && cd salidas/js-t2b/salidas/src-t2b/src/app/core && npx --prefix /w jasmine --random=true \
  domain/certificate-status.spec.js domain/certificate-validity.spec.js time/business-day.spec.js domain/resolve-template-version.spec.js" \
  > "$AQUI/salidas/jasmine-t2b.txt" 2>&1 && echo "jasmine: OK" || echo "jasmine: FALLA"
tail -20 "$AQUI/salidas/jasmine-t2b.txt"

# 3. La línea base de T2 no se movió.
bash "$AQUI/correr-t2.sh" > /dev/null
diff "$AQUI/salidas/linea-base.json" "$AQUI/linea-base-t2.json" && echo "línea base: igual a la de T2"
