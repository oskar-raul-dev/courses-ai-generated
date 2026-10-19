"""SQL Server (el track): la caja vuelve a su motor original, en la base `ALAMEDA` y el esquema `dbo`.

La carga no inventa el esquema: corre `esquema/ALAMEDA.sql`, el script que generó el Management Studio y
que trae la caja, y después manda cada CSV por la copia masiva de TDS (el protocolo de `bcp`), leído y
convertido aquí. Por qué no `bcp in` ni `BULK INSERT`, lo cuenta ss01.

Regla del curso: de SQL Server no se publica ningún número (apéndice a09). Este módulo no muestra
tiempos de carga, y `measure` devuelve solo la **estructura** del plan estimado, sin filas ni costos,
salvo que tú pidas `--private` para resolver una apuesta en tu máquina.

Necesita el extra `sqlserver` del proyecto: `uv run --extra sqlserver lab …`.
"""

import csv
import datetime as dt
import re
import time
from decimal import Decimal
import xml.etree.ElementTree as ET

from .. import config
from ..generator import schema
from . import LoadError, check

SHOWPLAN = "{http://schemas.microsoft.com/sqlserver/2004/07/showplan}"


def connect(database: str = "ALAMEDA", autocommit: bool = True):
    try:
        import mssql_python
    except ImportError as exc:      # el camino base no instala el driver del track
        raise LoadError("Falta el driver del track: corre con `uv run --extra sqlserver lab …`") from exc
    s = config.SQLSERVER
    conn = mssql_python.connect(
        f"Server={s['host']},{s['port']};Database={database};UID={s['user']};PWD={s['password']};"
        "Encrypt=yes;TrustServerCertificate=yes")     # el certificado del contenedor es autofirmado
    conn.autocommit = autocommit
    return conn


def batches(script: str) -> list[str]:
    """Parte un script de SSMS en lotes por sus líneas `GO`, como hace sqlcmd."""
    return [b.strip() for b in re.split(r"^\s*GO\s*$", script, flags=re.MULTILINE | re.IGNORECASE) if b.strip()]


def _ddl(profile: str) -> list[str]:
    """El script de SSMS sin el `USE`: la base la crea el cargador, y los lotes corren conectados a ella."""
    path = config.caja_dir() / profile / "esquema" / "ALAMEDA.sql"
    if not path.exists():
        raise LoadError(f"La caja del perfil {profile} no trae {path.name}")
    out = []
    for b in batches(path.read_text(encoding="utf-8")):
        if re.match(r"(USE \[|CREATE DATABASE)", b):
            continue
        out.append(b)
    return out


def load(profile: str, man: dict, tables: list[schema.Table], log=print, private=False) -> None:
    started = time.time()
    whole = len(tables) == len(schema.TABLES)
    master = connect("master")
    cur = master.cursor()
    if whole:
        cur.execute("IF DB_ID('ALAMEDA') IS NOT NULL BEGIN "
                    "ALTER DATABASE ALAMEDA SET SINGLE_USER WITH ROLLBACK IMMEDIATE; DROP DATABASE ALAMEDA; END")
    cur.execute("IF DB_ID('ALAMEDA') IS NULL CREATE DATABASE ALAMEDA")
    # La base de Matías no usa el modelo de recuperación completo: una carga entera llenaría el log.
    cur.execute("ALTER DATABASE ALAMEDA SET RECOVERY SIMPLE")
    master.close()

    conn = connect()
    cur = conn.cursor()
    wanted = {t.name for t in tables}
    if not whole:
        # Recargar unas tablas: primero las claves foráneas que las tocan, o SQL Server no deja borrarlas.
        cur.execute("SELECT OBJECT_NAME(parent_object_id), name, OBJECT_NAME(referenced_object_id) "
                    "FROM sys.foreign_keys")
        for parent, fk_name, referenced in cur.fetchall():
            if parent in wanted or referenced in wanted:
                cur.execute(f"ALTER TABLE [dbo].[{parent}] DROP CONSTRAINT [{fk_name}]")
    created: set[str] = set()
    for b in _ddl(profile):
        # Cada lote crea una tabla o le agrega una clave foránea; con --tables, solo los de lo pedido.
        named = re.findall(r"(?:CREATE TABLE|ALTER TABLE|REFERENCES) \[dbo\]\.\[([^\]]+)\]", b)
        if any(n not in wanted for n in named):
            continue
        added = re.search(r"ADD\s+CONSTRAINT \[([^\]]+)\]", b)
        if added:
            created.add(added.group(1))
        disabled = re.search(r"NOCHECK CONSTRAINT \[([^\]]+)\]", b)
        if disabled and not added and disabled.group(1) not in created:
            continue
        m = re.search(r"CREATE TABLE \[dbo\]\.\[([^\]]+)\]", b)
        if m and not whole:
            cur.execute(f"DROP TABLE IF EXISTS [dbo].[{m.group(1)}]")
        cur.execute(b)
    cur.execute("IF SCHEMA_ID('lab') IS NULL EXEC('CREATE SCHEMA lab')")
    for t in tables:
        target = f"[dbo].[{t.name}]"
        cols = t.exported_columns
        if len(cols) < len(t.columns):
            # La orden escaneada y el PDF no viajan en la caja: se carga a través de una vista con lo que sí.
            target = f"[lab].[carga_{t.name}]"
            cur.execute(f"CREATE OR ALTER VIEW {target} AS SELECT {', '.join(f'[{c.name}]' for c in cols)} "
                        f"FROM [dbo].[{t.name}]")
        # Por la copia masiva de TDS (la de bcp), con el CSV leído aquí. BULK INSERT del lado del servidor
        # sería más directo, y ss01 muestra por qué no: en Linux no acepta CODEPAGE (Msg 16202) y no lee las
        # dos tablas en Latin-1, y su FORMAT = 'CSV' no distingue "" de un campo vacío.
        cur.bulkcopy(target, _rows(profile, t), timeout=0, keep_identity=any(c.identity for c in cols),
                     keep_nulls=True, table_lock=True, column_mappings=[c.name for c in cols])
        cur.execute(f"SELECT COUNT_BIG(*) FROM [dbo].[{t.name}]")
        check(t, cur.fetchone()[0], man)
        if target.startswith("[lab]"):
            cur.execute(f"DROP VIEW {target}")
    cur.execute("CREATE TABLE lab.loaded (profile varchar(1), seed int, sha256 char(64), tables int, "
                "loaded_at datetime2 DEFAULT sysdatetime())" if not _exists(cur, "lab.loaded") else "SELECT 1")
    if whole:
        cur.execute("DELETE FROM lab.loaded")
    cur.execute("INSERT INTO lab.loaded (profile, seed, sha256, tables) VALUES (?, ?, ?, ?)",
                (profile, man["seed"], man["sha256"], len(tables)))
    conn.close()
    elapsed = f" en {time.time() - started:.0f} s" if private else " (🔒 el tiempo de SQL Server no se muestra)"
    log(f"  sqlserver: {len(tables)} tablas{elapsed}")


def _value(tsql: str, raw: str | None):
    """Un campo del CSV en el tipo de su columna. None es el campo vacío sin comillas: el NULL de bcp."""
    if raw is None:
        return None
    base = tsql.partition("(")[0]
    if base in ("int", "bigint"):
        return int(raw)
    if base == "bit":
        return raw == "1"
    if base in ("money", "decimal"):
        return Decimal(raw)
    if base == "datetime":
        return dt.datetime.strptime(raw, "%Y-%m-%d %H:%M:%S.%f")
    return raw


def _rows(profile: str, t: schema.Table):
    cols = t.exported_columns
    path = config.caja_dir() / profile / t.file
    with open(path, encoding=t.encoding, newline="") as f:
        reader = csv.reader(f, quoting=csv.QUOTE_NOTNULL)     # vacío sin comillas → None; "" → ""
        next(reader)
        for row in reader:
            yield tuple(_value(c.tsql, v) for c, v in zip(cols, row))


def _exists(cur, name: str) -> bool:
    cur.execute("SELECT OBJECT_ID(?)", (name,))
    return cur.fetchone()[0] is not None


# --- La medición: solo la forma -------------------------------------------------------------------

def measure(query: str, private: bool = False) -> dict:
    """El plan **estimado** (`SHOWPLAN_XML`, la consulta no se ejecuta) reducido a operadores y objetos.
    Con `private`, el plan real (`STATISTICS XML`): tiene filas reales, y no se publica."""
    conn = connect()
    cur = conn.cursor()
    cur.execute("SET STATISTICS XML ON" if private else "SET SHOWPLAN_XML ON")
    cur.execute(query)
    xml = None
    while True:
        try:
            rows = cur.fetchall()
        except Exception:
            rows = []
        for r in rows:
            if r and isinstance(r[0], str) and r[0].lstrip().startswith("<ShowPlanXML"):
                xml = r[0]
        if not cur.nextset():
            break
    conn.close()
    if xml is None:
        raise LoadError("SQL Server no devolvió un plan")
    return {"plan": plan_lines(xml, private), "private": private}


def plan_lines(xml: str, private: bool = False) -> list[str]:
    """Un plan de SQL Server en XML (de SHOWPLAN, de la caché o de Query Store) como árbol de operadores y
    objetos. Sin `private`, solo la estructura: ni filas, ni costos, que no se publican."""
    lines: list[str] = []
    root = ET.fromstring(xml)
    for stmt in root.iter(f"{SHOWPLAN}StmtSimple"):
        for op in stmt.findall(f"{SHOWPLAN}QueryPlan/{SHOWPLAN}RelOp"):
            _walk(op, 0, lines, private)
    return lines


def _walk(op: ET.Element, depth: int, lines: list[str], private: bool) -> None:
    obj = None
    for child in op:
        o = child.find(f"{SHOWPLAN}Object")
        if o is not None:
            obj = ".".join(p.strip("[]") for p in (o.get("Table"), o.get("Index")) if p)
            break
    text = f"{'  ' * depth}{op.get('PhysicalOp')}"
    if op.get("LogicalOp") != op.get("PhysicalOp"):
        text += f" ({op.get('LogicalOp')})"
    if obj:
        text += f" on {obj}"
    if private:
        rt = op.find(f"{SHOWPLAN}RunTimeInformation")
        if rt is not None:
            real = sum(int(t.get("ActualRows", 0)) for t in rt.findall(f"{SHOWPLAN}RunTimeCountersPerThread"))
            text += f" · estimadas {op.get('EstimateRows')} · reales {real}"
    lines.append(text)
    for child in op:
        for sub in child.findall(f"{SHOWPLAN}RelOp"):
            _walk(sub, depth + 1, lines, private)
