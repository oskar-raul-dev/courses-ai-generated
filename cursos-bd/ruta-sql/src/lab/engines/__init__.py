"""Lo común a los tres motores: qué tablas se cargan y cómo se comprueba la carga."""

import json
from pathlib import Path

from .. import config
from ..generator import schema


class LoadError(RuntimeError):
    pass


def manifest(profile: str) -> dict:
    path = config.caja_dir() / profile / "MANIFIESTO.json"
    if not path.exists():
        raise LoadError(f"No existe la caja del perfil {profile} en {path.parent}. "
                        f"Genérala con: uv run lab generate --profile {profile}")
    return json.loads(path.read_text(encoding="utf-8"))


def selected(names: list[str] | None) -> list[schema.Table]:
    if not names:
        return list(schema.TABLES.values())
    missing = [n for n in names if n not in schema.TABLES]
    if missing:
        raise LoadError(f"La caja no tiene estas tablas: {', '.join(missing)}")
    return [schema.TABLES[n] for n in names]


def check(table: schema.Table, loaded: int, man: dict) -> None:
    """El arnés no se cree a sí mismo: cada tabla tiene que tener las filas que escribió el generador."""
    expected = man["rows"].get(table.name)
    if expected is not None and loaded != expected:
        raise LoadError(f'{table.name}: se cargaron {loaded} filas y el generador escribió {expected}')


def short_hash(man: dict) -> str:
    return man["sha256"][:12]


def caja_path(profile: str, table: schema.Table) -> str:
    """La ruta del archivo dentro del contenedor, donde el compose monta la caja."""
    return str(Path("/caja") / profile / table.file)
