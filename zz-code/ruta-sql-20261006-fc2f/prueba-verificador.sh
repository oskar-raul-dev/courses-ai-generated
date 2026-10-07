#!/usr/bin/env bash
# Prueba del chequeo de solucionarios de prompts/verificar-corpus.py (D18), sobre un curso falso en
# salidas/prueba-verificador/: una F03 de 22 ejercicios sin solucionario, con 21 soluciones y completo.
# Esperado: SOLUCIONARIO en los dos primeros casos y nada del curso en el tercero. Los ROTO de
# prompts/propuesta-fases-y-alcance.md son de la copia parcial de prompts/ y no cuentan.
set -uo pipefail
AQUI="$(cd "$(dirname "$0")" && pwd)"
CURSO="$AQUI/../../cursos-bd/ruta-sql"
Z="$AQUI/salidas/prueba-verificador"
mkdir -p "$Z/prompts" "$Z/soluciones"
cp "$CURSO"/prompts/{verificar-corpus.py,verificador_base.py,propuesta-fases-y-alcance.md} "$Z/prompts/"
F=03-lo-que-sql-le-hace-al-modelo.md
rm -f "$Z/soluciones/$F"
python3 - "$Z/$F" <<'PY'
import sys
ej = []
for n in range(1, 23):
    e = '🟢' if n < 8 else '🟡' if n < 15 else '🟠' if n < 20 else '🔴'
    ej.append(f"### {e} Ejercicio {n} — Caso {n}\n\n**Objetivo:** algo.\n\n"
              f"[Solución](soluciones/03-lo-que-sql-le-hace-al-modelo.md#ejercicio-{n})\n")
open(sys.argv[1], 'w').write("# 🧮 Fase 03 — Prueba\n\n> **Curso:** Ruta SQL\n> **Fecha de verificación "
    "ejecutada:** 06/10/2026\n\n## 🧭 1. Dónde estamos\n\n" + "palabra " * 3800 +
    "\n\n## 🧪 14. Ejercicios (22)\n\n" + "\n".join(ej))
PY
echo "--- sin solucionario:"; (cd "$Z" && python3 prompts/verificar-corpus.py | grep -v "^ERROR ROTO .*prompts/")
python3 - "$Z/soluciones/$F" <<'PY'
import sys
open(sys.argv[1], 'w').write("# ✅ Soluciones — Fase 03\n\n" + "".join(
    f"### Ejercicio {n}\n\nSolución.\n\n[← Volver al ejercicio](../03-lo-que-sql-le-hace-al-modelo.md"
    f"#-ejercicio-{n}--caso-{n})\n\n" for n in range(1, 22)))
PY
echo "--- con 21 de 22:"; (cd "$Z" && python3 prompts/verificar-corpus.py | grep -v "^ERROR ROTO .*prompts/")
echo "### Ejercicio 22" >> "$Z/soluciones/$F"
echo "--- completo:"; (cd "$Z" && python3 prompts/verificar-corpus.py | grep -v "^ERROR ROTO .*prompts/")
