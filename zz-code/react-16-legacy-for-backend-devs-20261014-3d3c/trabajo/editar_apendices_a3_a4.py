# Edita A3 y A4 al dominio nuevo, con comprobación del conteo de cada reemplazo.
# Uso: python3 editar_apendices_a3_a4.py <carpeta-del-curso>
import re
import sys
from pathlib import Path

CURSO = Path(sys.argv[1])


def editar(nombre, reemplazos):
    ruta = CURSO / nombre
    s = ruta.read_text(encoding="utf-8")
    for old, new, count in reemplazos:
        hits = s.count(old)
        assert hits == count, f"{nombre}: esperaba {count} y hay {hits}: {old[:60]!r}"
        s = s.replace(old, new)
    ruta.write_text(s, encoding="utf-8")
    print(f"{nombre}: {len(reemplazos)} reemplazos verificados")


editar("A3-node-y-npm.md", [
    ("Tutorial React 16 — Rifas y chances", "Tutorial React 16 — La Esclusa, la consola de Jewel Locks", 1),
    ("y vuelves a la lotería.", "y vuelves a la casilla de salida.", 1),
])

editar("A4-cra-por-dentro.md", [
    ("Tutorial React 16 — Rifas y chances", "Tutorial React 16 — La Esclusa, la consola de Jewel Locks", 1),
    ("el CRUD mock en `3001` y la lotería mock en `3002` (Fase 3).",
     "el mock de la API en `3001` (Fase 3) y el mock de Google Play en `3002` (Fases 3 y 7).", 1),
    ("raffles-app/", "esclusa-app/", 1),
    ("logo-lottery.png", "logo-esclusa.png", 2),
    ('alt="Rifas y chances"', 'alt="La Esclusa"', 1),
    ("**Ejemplo mínimo — `/api` al CRUD, `/lottery` a la lotería:**",
     "**Ejemplo mínimo — `/api` al mock de la API, `/play` al de Google Play:**", 1),
    ("// El CRUD de rifas vive en el mock de la Fase 3, puerto 3001.",
     "// El mock de la API vive en la Fase 3, puerto 3001.", 1),
    ("// /api/raffles → /raffles en el mock", "// /api/wheels → /wheels en el mock", 1),
    ("// La lotería simulada vive aparte, en 3002 (Fase 7).",
     "// El mock de Google Play vive aparte, en 3002 (Fase 7).", 1),
    ('    "/lottery",', '    "/play",', 1),
    ("`/lottery/*` a la lotería de `3002`.", "`/play/*` al mock de Google Play de `3002`.", 1),
    ("`GET /api/raffles` desde la app", "`GET /api/wheels` desde la app", 1),
])
