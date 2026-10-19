"""Dónde está cada cosa: el compose, la caja y cómo se conecta el CLI a cada motor.

Todo se puede cambiar por variable de entorno, con los mismos nombres que usa `compose.yaml`
(`POSTGRES_PORT`, `LAB_PASSWORD`, `LAB_CAJA`…), o con un archivo `lab/.env`.
"""

import os
import re
import shlex
from pathlib import Path

HERE = Path(__file__).resolve().parent
COMPOSE_FILE = HERE / "compose.yaml"
ENV_FILE = HERE / ".env"


def _load_env_file() -> None:
    if not ENV_FILE.exists():
        return
    for line in ENV_FILE.read_text(encoding="utf-8").splitlines():
        line = line.strip()
        if line and not line.startswith("#") and "=" in line:
            key, value = line.split("=", 1)
            os.environ.setdefault(key.strip(), value.strip().strip('"'))


_load_env_file()


def env(name: str, default: str) -> str:
    return os.environ.get(name, default)


def compose_command() -> list[str]:
    """`docker compose` por defecto; `LAB_COMPOSE="podman compose"` para Podman. Si existe
    `lab/compose.override.yaml` (o el archivo que diga `LAB_COMPOSE_OVERRIDE`), va encima, como hace
    Compose cuando no le pasan `-f`: ahí van tus puertos o tu memoria, sin tocar el del curso."""
    files = ["-f", str(COMPOSE_FILE)]
    override = Path(env("LAB_COMPOSE_OVERRIDE", str(HERE / "compose.override.yaml")))
    if override.exists():
        files += ["-f", str(override)]
    return shlex.split(env("LAB_COMPOSE", "docker compose")) + files


def caja_dir() -> Path:
    raw = env("LAB_CAJA", "./caja")
    path = Path(raw)
    return path if path.is_absolute() else (HERE / path).resolve()


PASSWORD = env("LAB_PASSWORD", "lab")

POSTGRES = dict(host=env("LAB_POSTGRES_HOST", "127.0.0.1"), port=int(env("POSTGRES_PORT", "25432")),
                user="postgres", password=PASSWORD, dbname="alameda")
MYSQL = dict(host=env("LAB_MYSQL_HOST", "127.0.0.1"), port=int(env("MYSQL_PORT", "23306")),
             user="root", password=PASSWORD)
ORACLE = dict(host=env("LAB_ORACLE_HOST", "127.0.0.1"), port=int(env("ORACLE_PORT", "21521")),
              service="FREEPDB1", user="system", password=PASSWORD)
SQLSERVER = dict(host=env("LAB_SQLSERVER_HOST", "127.0.0.1"), port=int(env("SQLSERVER_PORT", "21433")),
                 user="sa", password=env("SQLSERVER_PASSWORD", "Lab-2026-pass"))


def images() -> dict[str, str]:
    """service → imagen con digest, leída del compose (el único sitio donde vive una versión)."""
    out, service = {}, None
    for line in COMPOSE_FILE.read_text(encoding="utf-8").splitlines():
        m = re.match(r"^  ([a-z]+):\s*$", line)
        if m:
            service = m.group(1)
        m = re.match(r"^\s+# ([\w./:-]+) .*verificado", line)
        if m and service:
            out.setdefault(service + ":tag", m.group(1))
        m = re.match(r"^\s+image:\s*(\S+)", line)
        if m and service:
            out[service] = m.group(1)
    return out
