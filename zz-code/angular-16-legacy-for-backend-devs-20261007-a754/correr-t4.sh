#!/usr/bin/env bash
# T4: incidente 22. Árboles desde el markdown:
#   base  = el formulario de clientes de F06 (componente, plantilla, validador asíncrono)
#           + modelos de F03 + api-error de F03 + stubs de ClientApiService/ClientStateService
#   fix22 = base + la solución de referencia del 22, aplicada desde el cuaderno
# tsc estricto con Angular Material 16.2.14, y Jasmine sobre un bundle de esbuild
# (Angular 16 es ESM parcialmente compilado: se carga @angular/compiler primero).
set -euo pipefail
AQUI="$(cd "$(dirname "$0")" && pwd)"
CURSO="${CURSO:-$AQUI/../../cursos-legacy/angular-16-legacy-for-backend-devs}"
IMAGEN="node:18.18.2-alpine"
T4="$AQUI/salidas/t4"
corre() { docker run --rm --label curso=angular16 -e NPM_CONFIG_UPDATE_NOTIFIER=false -v "$AQUI":/w -w /w "$IMAGEN" sh -c "$1"; }

SELLO="$(date +%Y%m%d-%H%M%S)"
if [ -d "$T4" ]; then mv "$T4" "$AQUI/salidas/t4-anterior-$SELLO"; fi
mkdir -p "$T4"

B="$T4/base/src/app"
python3 "$AQUI/extraer.py" --curso "$CURSO" --salida "$T4/base" --prefijo src/app/core/models/ > "$T4/extraccion.txt"
python3 "$AQUI/bloque.py" "$CURSO/03-mock-api-caos.md" "// src/app/core/api/api-error.ts" "$B/core/api/api-error.ts"
python3 "$AQUI/bloque.py" "$CURSO/06-clientes-activos.md" "// src/app/features/clients/client-form/client-form.component.ts" "$B/features/clients/client-form/client-form.component.ts"
python3 "$AQUI/bloque.py" "$CURSO/06-clientes-activos.md" "<!-- src/app/features/clients/client-form/client-form.component.html -->" "$B/features/clients/client-form/client-form.component.html"
python3 "$AQUI/bloque.py" "$CURSO/06-clientes-activos.md" "// src/app/features/clients/unique-tax-id.validator.ts" "$B/features/clients/unique-tax-id.validator.ts"
cp "$AQUI/pruebas/stubs-t4/src/app/core/api/client-api.service.ts" "$B/core/api/"
mkdir -p "$B/core/state"; cp "$AQUI/pruebas/stubs-t4/src/app/core/state/client-state.service.ts" "$B/core/state/"

python3 "$AQUI/aplicar-solucion.py" "$CURSO/cuaderno-incidentes.md" 22 "$T4/base" "$T4/fix22" | tee "$T4/aplicado-22.txt"

# El arreglo `validators` del control taxId, copiado tal cual de cada componente.
for arbol in base fix22; do
  python3 "$AQUI/validadores-del-arbol.py" "$T4/$arbol"
  mkdir -p "$T4/$arbol/pruebas"; cp "$AQUI/pruebas/t4-extra.spec.ts" "$T4/$arbol/pruebas/"
done

# 1. tsc estricto. El spec del cuaderno solo existe en fix22: importa tax-id.validator.ts, que
#    fase-06 no tiene (en base, el fallo "antes" lo muestra t4-extra.spec.ts).
for arbol in base fix22; do
  cat > "$T4/tsconfig.$arbol.json" <<JSON
{ "extends": "../../tsconfig.json", "compilerOptions": { "experimentalDecorators": true, "types": ["jasmine"] },
  "include": ["$arbol/**/*.ts"], "exclude": [] }
JSON
  corre "npx tsc -p salidas/t4/tsconfig.$arbol.json" > "$T4/tsc-$arbol.txt" 2>&1 \
    && echo "tsc $arbol: OK" || { echo "tsc $arbol: FALLA"; cat "$T4/tsc-$arbol.txt"; }
done

# 2. Jasmine sobre un bundle por árbol
for arbol in base fix22; do
  specs="pruebas/t4-extra.spec.ts"
  [ "$arbol" = fix22 ] && specs="$specs src/app/features/clients/tax-id.validator.incidente-22.spec.ts"
  { echo "import '@angular/compiler';"; for s in $specs; do echo "import './${s%.ts}';"; done; } > "$T4/$arbol/entrada.ts"
  corre "npx esbuild salidas/t4/$arbol/entrada.ts --bundle --platform=node --format=cjs --log-level=warning \
      --outfile=salidas/t4/$arbol/bundle.cjs && npx jasmine --random=true salidas/t4/$arbol/bundle.cjs" > "$T4/jasmine-$arbol.txt" 2>&1 \
    && echo "jasmine $arbol: OK — $(grep -o '[0-9]* specs\?, [0-9]* failures\?' "$T4/jasmine-$arbol.txt")" \
    || echo "jasmine $arbol: FALLA — $(grep -o '[0-9]* specs\?, [0-9]* failures\?' "$T4/jasmine-$arbol.txt")"
done
