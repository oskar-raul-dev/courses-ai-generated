#!/usr/bin/env python3
"""Quita del material publicado de la Ruta NoSQL Lite las citas a prompts/ (alcance, guía, formato
de la bitácora, hallazgos), que no viajan al repositorio público (etapa E9).

Cada reemplazo es literal y debe aparecer exactamente las veces indicadas; si no, el script se
detiene sin escribir ese archivo. Uso: python3 sin-citas-a-prompts.py <carpeta-del-curso>
"""
import sys
from pathlib import Path

CURSO = Path(sys.argv[1])

TS_RULE_OLD = "generador de datos son TypeScript siempre** (alcance §9)"
TS_RULE_NEW = "generador de datos son TypeScript siempre** (`a06`)"

R = [
    ("00-historia-de-condor.md", "En inglés, como manda la guía de estilo; el glosario es para leer el texto.",
     "En inglés, como todo el código del curso; el glosario es para leer el texto.", 1),
    ("00-historia-de-condor.md", "se\n  escriben con la estructura de §2.1 de la guía de estilo — la decisión, su mejor argumento,",
     "se\n  escriben siempre con la misma estructura — la decisión, su mejor argumento,", 1),
    ("00-la-decision-que-se-hereda.md", "(exención declarada de la guía §9: esta fase es de criterio, no de\nejecución)",
     "(esta fase es de criterio, no de\nejecución, y por eso lleva doce y no veinte)", 1),
    ("02-las-cinco-preguntas.md", "(exención declarada de la guía §9)",
     "(fase de criterio, como la 00: doce ejercicios y no veinte)", 1),
    ("05-clave-valor-levantar-y-modelar.md", "Fuera del alcance del curso (alcance §11).", "Fuera del alcance del curso.", 1),
    ("03-documental-levantar-y-modelar.md", "Fuera del alcance del curso (alcance §11).", "Fuera del alcance del curso.", 1),
    ("15-vectorial-levantar-y-modelar.md", "(alcance §12, decisión 18)", "(`a06` fija el modelo y su revisión)", 1),
    ("15-vectorial-levantar-y-modelar.md", "(decisión 18 del alcance)", "(es una decisión del curso)", 1),
    ("a04-el-arnes-de-medida.md", "Este curso **mide la forma, no la velocidad** (alcance §6).",
     "Este curso **mide la forma, no la velocidad**.", 1),
    ("a04-el-arnes-de-medida.md", "\nLa tabla de correspondencia de partida está en `prompts/formato-bitacora-de-medicion.md` §2.3.\n", "", 1),
    ("a04-el-arnes-de-medida.md", "Las reglas están en `prompts/formato-bitacora-de-medicion.md` §3; aquí va cómo se cumplen en la\npráctica,",
     "Son seis reglas, y aquí van con cómo se cumplen en la\npráctica,", 1),
    ("a04-el-arnes-de-medida.md", "**Una por minicurso**, dice el formato.", "**Una por minicurso**, es la regla general.", 1),
    ("a04-el-arnes-de-medida.md", "venía de la sesión de laboratorio (hallazgo H8) y", "venía de la verificación del laboratorio y", 1),
    ("a04-el-arnes-de-medida.md", "con los cinco datos de la\nguía §6 —", "con los cinco datos de toda\nmedición del curso —", 1),
    ("a09-catalogo-de-errores.md", "cada fase añade lo que encontró al ejecutarse (formato en\n`prompts/formato-bitacora-de-medicion.md` §6).",
     "cada fase añade lo que encontró al ejecutarse, con el mismo formato que las entradas de abajo.", 1),
    ("bitacora-de-medicion.md", "con los cinco datos\n> de la guía de estilo §6 y su comando de reproducción. Sustituye al `BENCHMARKS.md` del\n> repositorio, porque este curso **mide la forma y no la velocidad** (guía §16).\n> **Formato de cada entrada:** `prompts/formato-bitacora-de-medicion.md` §2 y §5.",
     "con los cinco datos\n> de toda medición —qué se midió, volumen con su hash, motor y digest, máquina si hay tiempos, y el\n> comando exacto— (la ficha de [`a04`](a04-el-arnes-de-medida.md)). No hay un archivo de latencias,\n> porque este curso **mide la forma y no la velocidad**.", 1),
    ("INSTINTOS.md", "> **Formato de cada entrada** (`prompts/formato-bitacora-de-medicion.md` §7): el instinto en tu voz ·",
     "> **Formato de cada entrada:** el instinto en tu voz ·", 1),
    ("a10-licencias-y-riesgo.md", "La verificación del laboratorio (alcance §12, decisiones 16, 19 y 20) tropezó",
     "La verificación del laboratorio tropezó", 1),
    ("h-mini-10-newsql-barlovento.md", "y está declarado en\n`prompts/formato-bitacora-de-medicion.md` §2.4:",
     "y es la única excepción declarada\na la regla de no argumentar con tiempos:", 1),
    ("h-mini-02-clave-valor-nodo-sur.md", "Decidido en el alcance §12 (17); la versión vive en `a06`", "La versión y el porqué viven en `a06`", 1),
    ("h-mini-08-columnar-nodo-sur.md", "se descartó por licencia (alcance §12, 16)", "se descartó por licencia (`a10`)", 1),
    ("h-mini-10-newsql-barlovento.md", "sin licencia (alcance §12, 19).", "sin licencia (`a10`).", 1),
    ("h-mini-03-analitico-bengala.md", "por la regla del alcance §9:", "por la regla de los dos entornos de `a06`:", 1),
    ("h-mini-03-analitico-bengala.md", "| Regla del alcance §9, sin excepción |", "| Regla de `a06`, sin excepción |", 1),
]
for n in ["01-documental-barlovento", "02-clave-valor-nodo-sur", "03-analitico-bengala", "04-series-voltaria",
          "05-busqueda-bengala", "06-grafos-voltaria", "07-vectorial-cumbre-roja", "08-columnar-nodo-sur",
          "09-offline-cumbre-roja", "10-newsql-barlovento"]:
    R.append((f"h-mini-{n}.md", TS_RULE_OLD, TS_RULE_NEW, 1))

archivos = {}
for f, a, b, veces in R:
    t = archivos.get(f) or (CURSO / f).read_text(encoding="utf-8")
    n = t.count(a)
    if n != veces:
        sys.exit(f"{f}: «{a[:50]}…» aparece {n} veces, se esperaban {veces}")
    archivos[f] = t.replace(a, b)
for f, t in archivos.items():
    (CURSO / f).write_text(t, encoding="utf-8")
    print("ok", f)
