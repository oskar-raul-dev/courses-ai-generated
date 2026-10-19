"""`lab load --model`: después de cargar la caja, el modelo de las fases 04 a 08 (D41).

Corre en orden los scripts `0N_*.sql` de cada carpeta de fase, igual que los corrías a mano, y carga
la planilla de convenios cuando la Fase 06 la necesita (entre su `02_` y su `03_`). Lo que queda:
`legacy` → `staging` → `alameda`, el punto de partida del Bloque II.
"""

import importlib.util
import time
from pathlib import Path

from . import config
from .engines import postgres

SRC = config.HERE.parent
PHASES = ("04-", "05-", "06-", "07-", "08-")


def _scripts() -> list[Path]:
    out = []
    for prefix in PHASES:
        folder = next(SRC.glob(prefix + "*"), None)
        if folder is None:
            raise FileNotFoundError(f"falta la carpeta {prefix}… en {SRC}")
        out += sorted(folder.glob("0*.sql"))
    return out


def _agreements(conn, profile: str) -> int:
    """La planilla de convenios a staging.agreement_raw, con el lector de la Fase 06."""
    reader = next(SRC.glob("06-*")) / "xlsx_to_csv.py"
    spec = importlib.util.spec_from_file_location("xlsx_to_csv", reader)
    module = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(module)
    rows = list(module.rows(str(config.caja_dir() / profile / "planillas" / "convenios_2026.xlsx")))[1:]
    with conn.cursor().copy("COPY staging.agreement_raw (payer, practice, site) FROM STDIN") as copy:
        for row in rows:
            copy.write_row(row[:3])
    return len(rows)


def build(profile: str, log=print) -> None:
    started = time.time()
    with postgres.connect(autocommit=True) as conn:
        # el modelo se rehace entero: lo que haya de una corrida anterior depende de legacy, que es nueva
        conn.execute("DROP SCHEMA IF EXISTS alameda, staging CASCADE")
        for script in _scripts():
            conn.execute(script.read_text(encoding="utf-8"))
            if script.parent.name.startswith("06-") and script.name.startswith("02_"):
                log(f"  {script.parent.name}: planilla de convenios, {_agreements(conn, profile)} filas")
            log(f"  {script.parent.name}/{script.name} ({time.time() - started:.0f} s)")
    log(f"  modelo: listo en {time.time() - started:.0f} s")
