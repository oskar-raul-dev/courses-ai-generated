#!/usr/bin/env bash
# T3: incidente 21 (y su vecino, el 15). Arma tres árboles desde el markdown:
#   base  = fase-10 extraída de las fases (+ los dos servicios que el fix toca, + stubs)
#   fix21 = base + la solución de referencia del 21, aplicada desde el cuaderno
#   roto15 = base + el diff de la preparación del 15, aplicado desde preparaciones
# y corre tsc estricto y Jasmine sobre cada uno. Ver README §T3.
set -euo pipefail
AQUI="$(cd "$(dirname "$0")" && pwd)"
CURSO="${CURSO:-$AQUI/../../cursos-legacy/angular-16-legacy-for-backend-devs}"
IMAGEN="node:18.18.2-alpine"
T3="$AQUI/salidas/t3"
corre() { docker run --rm --label curso=angular16 -e NPM_CONFIG_UPDATE_NOTIFIER=false -v "$AQUI":/w -w /w "$IMAGEN" sh -c "$1"; }

# Los árboles se rehacen en un directorio nuevo por corrida: nunca se borra uno entero.
SELLO="$(date +%Y%m%d-%H%M%S)"
if [ -d "$T3" ]; then mv "$T3" "$AQUI/salidas/t3-anterior-$SELLO"; fi
mkdir -p "$T3"

# 1. base
python3 "$AQUI/extraer.py" --curso "$CURSO" --salida "$T3/base" > "$T3/extraccion.txt"
python3 "$AQUI/bloque.py" "$CURSO/10-certificados-vigencia.md" "// src/app/core/state/certificate-state.service.ts" \
  "$T3/base/src/app/core/state/certificate-state.service.ts"
python3 "$AQUI/bloque.py" "$CURSO/10-certificados-vigencia.md" \
  "// src/app/features/certificates/certificate-pdf.service.ts — LA VERSIÓN QUE PAGA" \
  "$T3/base/src/app/features/certificates/certificate-pdf.service.ts" --antes "$AQUI/pruebas/stubs-t3/cabecera-pdf-service.ts"
python3 "$AQUI/bloque.py" "$CURSO/07-plantillas-versionadas.md" "// src/app/core/api/template-api.service.ts — lo que se añade" \
  "$T3/base/src/app/core/api/template-api.service.ts" --despues "$AQUI/pruebas/stubs-t3/src/app/core/api/template-api.service.class.ts"
python3 - "$T3/base/src/app/core/api/template-api.service.ts" <<'PY'
# El bloque de F07 sigue con "// …dentro de TemplateApiService…" y métodos sueltos: se corta ahí.
import sys, pathlib
p = pathlib.Path(sys.argv[1]); t = p.read_text(encoding="utf-8")
cab, resto = t.split("// …dentro de TemplateApiService…", 1)
p.write_text(cab + resto[resto.index("\n// STUB DE PRUEBA"):], encoding="utf-8")
PY
for f in certificate-api asset-api inspection-api client-api; do
  cp "$AQUI/pruebas/stubs-t3/src/app/core/api/$f.service.ts" "$T3/base/src/app/core/api/$f.service.ts"
done
cp "$AQUI/pruebas/stubs-t3/src/app/core/state/inspection-state.service.ts" "$T3/base/src/app/core/state/inspection-state.service.ts"

# 2. fix21 y roto15
python3 "$AQUI/aplicar-solucion.py" "$CURSO/cuaderno-incidentes.md" 21 "$T3/base" "$T3/fix21" | tee "$T3/aplicado-21.txt"
python3 "$AQUI/aplicar-solucion.py" "$CURSO/cuaderno-incidentes.md" 15 "$T3/base" "$T3/base15" > "$T3/aplicado-15.txt"
python3 "$AQUI/aplicar-preparacion.py" "$CURSO/prompts/preparaciones-de-incidentes.md" 15 \
  src/app/core/domain/certificate-status.ts "$T3/base15" "$T3/roto15"
# Los specs de regresión también van a los demás árboles: así se ven fallar antes.
cp "$T3/fix21/src/app/core/domain/certificate-status.incidente-21.spec.ts" "$T3/base/src/app/core/domain/"
cp "$T3/base15/src/app/core/domain/certificate-status.incidente-15.spec.ts" "$T3/base/src/app/core/domain/"
cp "$T3/base15/src/app/core/domain/certificate-status.incidente-15.spec.ts" "$T3/fix21/src/app/core/domain/"
for arbol in base fix21; do
  mkdir -p "$T3/$arbol/pruebas"
  sed "s#'../salidas/src-extraido/src/#'../src/#" "$AQUI/pruebas/linea-base.ts" > "$T3/$arbol/pruebas/linea-base.ts"
done
cp "$AQUI/pruebas/t3-extra.spec.ts" "$T3/fix21/pruebas/"

# 3. Los datos: la semilla de F03 + las filas de la receta del 21.
python3 "$AQUI/gen-db-21.py" "$CURSO" "$T3"

# 4. tsc estricto
corre "npx tsc -p tsconfig.t3-fix.json" > "$T3/tsc-fix21.txt" 2>&1 && echo "tsc fix21: OK" || { echo "tsc fix21: FALLA"; cat "$T3/tsc-fix21.txt"; }
corre "npx tsc -p tsconfig.t3-base.json" > "$T3/tsc-base.txt" 2>&1 && echo "tsc base: OK" \
  || { echo "tsc base: FALLA"; cat "$T3/tsc-base.txt"; }

# 5. Jasmine sobre cada árbol (a CommonJS; tsc emite aunque haya errores de tipos)
jas() {  # árbol, specs .ts relativos a la raíz del árbol
  local arbol="$1"; shift
  local ts="" js=""
  for f in "$@"; do ts="$ts salidas/t3/$arbol/$f"; js="$js ${f%.ts}.js"; done
  corre "npx tsc --outDir salidas/t3/js-$arbol --rootDir salidas/t3/$arbol --module commonjs --target ES2022 --lib ES2022,dom \
    --strict --skipLibCheck --experimentalDecorators --types jasmine --moduleResolution node $ts > /dev/null 2>&1; \
    cd salidas/t3/js-$arbol && npx --prefix /w jasmine --random=true $js" > "$T3/jasmine-$arbol.txt" 2>&1 \
    && echo "jasmine $arbol: OK — $(grep -o '[0-9]* specs\?, [0-9]* failures\?' "$T3/jasmine-$arbol.txt")" \
    || echo "jasmine $arbol: FALLA — $(grep -o '[0-9]* specs\?, [0-9]* failures\?' "$T3/jasmine-$arbol.txt")"
}
jas fix21  src/app/core/domain/certificate-status.incidente-21.spec.ts src/app/core/domain/certificate-status.incidente-15.spec.ts pruebas/t3-extra.spec.ts
jas base   src/app/core/domain/certificate-status.incidente-21.spec.ts src/app/core/domain/certificate-status.incidente-15.spec.ts
jas roto15 src/app/core/domain/certificate-status.incidente-15.spec.ts

# 6. La línea base de T2, sobre el árbol con el fix: tiene que dar lo mismo.
corre "npx tsc --outDir salidas/t3/js-lb --rootDir salidas/t3/fix21 --module commonjs --target ES2022 --lib ES2022,dom --strict --skipLibCheck \
  salidas/t3/fix21/pruebas/linea-base.ts && node salidas/t3/js-lb/pruebas/linea-base.js" > "$T3/linea-base-fix21.json" 2> "$T3/linea-base-fix21.err"
diff "$T3/linea-base-fix21.json" "$AQUI/linea-base-t2.json" && echo "línea base con el fix: igual a la de T2"
