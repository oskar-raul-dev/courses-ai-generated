#!/usr/bin/env bash
# Comandos de la revisión del 06/10/2026 contra zz-instrucciones, tal como corrieron y en orden.
# Desde la raíz del repositorio. Los pasos 3 y 4 ya se aplicaron: volver a correrlos no encuentra
# nada que corregir (el verificador sale en cero). Se guardan como registro de cómo se hizo.
set -euo pipefail
REPO="$(cd "$(dirname "$0")/../.." && pwd)"
CURSO="$REPO/cursos-bd/ruta-no-sql-lite"
AQUI="$(cd "$(dirname "$0")" && pwd)"
S="$AQUI/salidas"; mkdir -p "$S"
cd "$REPO"

# 1. Barrido inicial con la base de los lineamientos
python3 zz-instrucciones/herramientas/verificador_base.py "$CURSO" --perfil=courses-ia || true
python3 zz-instrucciones/herramientas/verificador_base.py "$CURSO" --perfil=publicacion || true

# 2. .gitignore unificado: listas antes (con src/lab/.gitignore) y después (solo src/.gitignore)
cd "$CURSO"
git ls-files -oi --exclude-standard src | sort > "$S/gitignore-despues-oi.txt"
git ls-files -o  --exclude-standard src | sort > "$S/gitignore-despues-o.txt"
git ls-files -ci --exclude-standard src | sort > "$S/gitignore-despues-ci.txt"
for k in oi o ci; do diff -q "$S/gitignore-antes-$k.txt" "$S/gitignore-despues-$k.txt" && echo "$k idéntico"; done
cd "$REPO"

# 3. Anclas sin U+FE0F: se toma la salida del verificador y se reemplaza el ancla en su línea
python3 zz-instrucciones/herramientas/verificador_base.py "$CURSO" --perfil=courses-ia 2>&1 \
  | grep ANCLA-FE0F > "$S/ancla-fe0f-antes.txt" || true
python3 - "$CURSO" "$S/ancla-fe0f-antes.txt" <<'PY'
import re, sys
base, lista = sys.argv[1] + "/", sys.argv[2]
for l in open(lista, encoding="utf-8"):
    m = re.search(r"ANCLA-FE0F (\S+):(\d+) → (#\S+) \(en GitHub es (#\S+)\)", l)
    f, n, old, new = m.group(1), int(m.group(2)), m.group(3), m.group(4)
    L = open(base + f, encoding="utf-8").read().split("\n")
    L[n - 1] = L[n - 1].replace("(" + old + ")", "(" + new + ")")
    open(base + f, "w", encoding="utf-8").write("\n".join(L))
PY

# 4. Enlaces a fases que no existen: el enlace se deja como texto (la deuda va al plan)
python3 zz-instrucciones/herramientas/verificador_base.py "$CURSO" --perfil=courses-ia 2>&1 \
  | grep ROTO > "$S/roto-antes.txt" || true
python3 - "$CURSO" "$S/roto-antes.txt" <<'PY'
import re, sys
base, lista = sys.argv[1] + "/", sys.argv[2]
for l in open(lista, encoding="utf-8"):
    m = re.search(r"ROTO\s+(\S+):(\d+) → (\S+)", l)
    f, n, target = m.group(1), int(m.group(2)), m.group(3)
    L = open(base + f, encoding="utf-8").read().split("\n")
    L[n - 1] = re.sub(r"\[([^\]]+)\]\(" + re.escape(target) + r"\)", r"\1", L[n - 1])
    open(base + f, "w", encoding="utf-8").write("\n".join(L))
PY

# 5. Citas a prompts/ en lo publicado (reemplazos literales, ver el script)
python3 "$AQUI/sin-citas-a-prompts.py" "$CURSO" || true

# 6. Los diagramas Mermaid, dibujados (mmdc 12.0.0 del host)
for d in "$AQUI"/diagramas/*.mmd; do
  mmdc -q -i "$d" -o "$S/$(basename "${d%.mmd}").png" -s 2 -b white
done

# 7. El verificador del curso, en sus dos modos
cd "$CURSO"
python3 prompts/verificar-corpus.py
python3 prompts/verificar-corpus.py --publicacion || true
