"""Carga solo el esquema `truth` de la caja M en Postgres (T9, D46).

No toca `legacy` ni los modelos: los archivos viejos de la caja tienen los mismos hashes que el
manifiesto publicado (ver salidas/comprobacion-hashes.txt), así que la carga entera daría los mismos
bytes. `_load_truth` recrea `truth` desde los CSV de la caja que el contenedor monta en /caja.

Uso (desde ruta-sql/src, con LAB_CAJA apuntando a la caja nueva):
    uv run python -I ../../zz-code/ruta-sql-20261014-d471/cargar-verdad.py
"""

import json
import os
import sys
from pathlib import Path

CAJA = Path(os.environ["LAB_CAJA"]) / "m"
man = json.loads((CAJA / "MANIFIESTO.json").read_text(encoding="utf-8"))

from lab.engines import postgres  # noqa: E402

with postgres.connect(autocommit=True) as conn:
    postgres._load_truth(conn, "m", man)
    for name in postgres.TRUTH:
        n = conn.execute(f"SELECT count(*) FROM truth.{name}").fetchone()[0]
        print(f"truth.{name}: {n} filas")
sys.exit(0)
