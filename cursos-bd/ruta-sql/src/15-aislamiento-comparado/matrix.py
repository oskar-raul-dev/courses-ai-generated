"""Fase 15 · la matriz anomalía × nivel × motor, corrida con lab race.

    uv run python 15-aislamiento-comparado/matrix.py

Cada escenario se corre en los cuatro niveles y en los dos motores, siempre con la misma
permutación. Una celda dice qué pasó: la anomalía, un error que la evitó (con su código), una espera
que la evitó o nada.
"""

from pathlib import Path

from lab.race import ISOLATION, Race

HERE = Path(__file__).resolve().parent


def value(outcomes, label):
    return next((o.rows[0][0] for o in outcomes if o.label == label and o.rows), None)


def differ(a, b):
    return a is not None and b is not None and a != b


def first_error(outcomes):
    return next((o for o in outcomes if o.error), None)


# Para cada escenario: qué pasos mirar y cuándo hay anomalía (etiquetas de Postgres, MySQL).
JUDGES = {
    "dirty_read": lambda out, chk, eng: str(value(out, "b2" if eng == "postgres" else "b3")) == "18.00",
    "nonrepeatable_read": lambda out, chk, eng: differ(
        value(out, "a2" if eng == "postgres" else "a3"), value(out, "a3" if eng == "postgres" else "a4")),
    "phantom": lambda out, chk, eng: differ(
        value(out, "a2" if eng == "postgres" else "a3"), value(out, "a3" if eng == "postgres" else "a4")),
    "lost_update": lambda out, chk, eng: chk[0] != "1 fila  (13.00)",
    "write_skew": lambda out, chk, eng: chk[0] == "1 fila  (2, 2)",
    "read_only": lambda out, chk, eng: (
        str(value(out, "c3" if eng == "postgres" else "c4")) == "1000.00" and chk[0] == "1 fila  (2500.00)"),
}
NAMES = {"dirty_read": "lectura sucia", "nonrepeatable_read": "lectura no repetible", "phantom": "fantasma",
         "lost_update": "actualización perdida", "write_skew": "write skew (la muestra)",
         "read_only": "anomalía de solo lectura"}


def cell(name: str, engine: str, level: str) -> str:
    path = HERE / (name + ("" if engine == "postgres" else "_mysql") + ".race")
    race = Race.from_file(str(path))
    race.isolation = ISOLATION[level]
    out = race.run(echo=False)
    err = first_error(out)
    # Hay anomalía si el resultado lo muestra y nadie falló: un error o una espera que la impidió es
    # la protección del nivel, no la anomalía.
    if err is None and JUDGES[name](out, race.checked, engine):
        return "❌ pasa"
    if err is None:
        return "✅ no pasa"
    if err.error == "imposible":
        return "✅ espera"
    return f"✅ error {err.error}"


def main() -> None:
    levels = list(ISOLATION)
    for engine in ("postgres", "mysql"):
        print(f"\n{engine}")
        print("| anomalía | " + " | ".join(ISOLATION[x] for x in levels) + " |")
        print("|---|" + "---|" * len(levels))
        for name in JUDGES:
            print(f"| {NAMES[name]} | " + " | ".join(cell(name, engine, x) for x in levels) + " |")


if __name__ == "__main__":
    main()
