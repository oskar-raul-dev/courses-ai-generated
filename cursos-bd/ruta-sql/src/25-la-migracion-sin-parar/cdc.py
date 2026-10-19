"""Fase 25 · el aplicador del CDC: lee el slot `f25_legacy` y aplica en el modelo cada transacción de legacy.

Cada transacción de legacy se aplica en una transacción del modelo, junto con la posición (el LSN de su COMMIT)
en `staging.f25_cdc_position`. Recién después se avanza el slot. Si el proceso se cae entre las dos cosas, al
volver relee esas transacciones y saltea las que la posición ya tiene: el efecto es una vez, aunque la entrega
sea al menos una vez (Fase 22).

Lo usan `05_convivencia.py`, `07_corte.py` y el arnés del 🏆 "Un martes":

    import cdc
    cdc.drenar(conn)            # aplica todo lo pendiente y devuelve cuántas transacciones aplicó
"""

import json
import re

SLOT = "f25_legacy"
TABLAS = {'"Protocolos"', '"ProtocoloPracticas"', '"ResultadoItem"'}
CABEZA = re.compile(r'^table legacy\.(?P<tabla>"(?:[^"]|"")+"|\w+): (?P<op>INSERT|UPDATE|DELETE): (?P<resto>.*)$', re.S)
CAMPO = re.compile(r'(?P<col>"(?:[^"]|"")+"|\w+)\[(?P<tipo>[^\]]+)\]:(?P<val>\'(?:[^\']|\'\')*\'|null|\S+)')
COMMIT = re.compile(r'^COMMIT (?P<xid>\d+) \(at (?P<ts>.+)\)$')


def correr_sql(conn, path) -> None:
    """Corre un archivo .sql sentencia por sentencia, como psql. Mandado entero, el archivo es una sola transacción
    implícita, y Postgres no crea un slot lógico en una transacción que ya escribió."""
    sentencia, dentro = [], False
    for linea in open(path, encoding="utf-8"):
        sentencia.append(linea)
        if linea.count("$$") % 2:
            dentro = not dentro
        if not dentro and linea.rstrip().endswith(";") and not linea.lstrip().startswith("--"):
            texto = "".join(sentencia).strip()
            if any(not l.strip().startswith("--") and l.strip() for l in texto.splitlines()):
                conn.execute(texto)
            sentencia = []


def _n(lsn: str) -> int:
    """Un LSN como número: '0/1A2B' se compara mal como texto."""
    alto, bajo = lsn.split("/")
    return (int(alto, 16) << 32) + int(bajo, 16)


SALTEADAS = [0]                                 # transacciones releídas que la posición ya tenía


class CaidaSimulada(Exception):
    """La caída entre confirmar en el modelo y avanzar el slot."""


def _fila(resto: str) -> dict:
    fila = {}
    for m in CAMPO.finditer(resto):
        col, tipo, val = m["col"].strip('"').replace('""', '"'), m["tipo"], m["val"]
        if val == "null":
            fila[col] = None
        elif val.startswith("'"):
            fila[col] = val[1:-1].replace("''", "'")
        elif tipo in ("integer", "bigint", "smallint"):
            fila[col] = int(val)
        else:
            fila[col] = val
    return fila


def _transacciones(filas):
    """Agrupa la salida de test_decoding en transacciones: (lsn del COMMIT, xid, instante, cambios)."""
    cambios = []
    for lsn, xid, data in filas:
        if data.startswith("BEGIN"):
            cambios = []
        elif data.startswith("COMMIT"):
            m = COMMIT.match(data)
            yield lsn, int(m["xid"]), m["ts"], cambios
        else:
            m = CABEZA.match(data)
            if m and m["tabla"] in TABLAS:
                cambios.append((m["tabla"].strip('"'), m["op"], _fila(m["resto"])))


def _aplicar(cur, tabla: str, op: str, f: dict) -> None:
    """La fila va entera, como jsonb: qué columnas usa cada función del modelo lo decide la función, no el aplicador."""
    fila = json.dumps(f)
    if tabla == "Protocolos":
        if op == "DELETE":
            cur.execute("INSERT INTO staging.rejection (phase, rule, source_table, source_key, value, detail) "
                        "VALUES ('25', 'cdc.borrado_de_protocolo', 'Protocolos', %s, NULL, 'lo decide una persona')",
                        (str(f["IdProtocolo"]),))
        else:
            cur.execute("SELECT staging.f25_apply_protocol(%s::jsonb)", (fila,))
    elif tabla == "ProtocoloPracticas":
        if op == "DELETE":
            cur.execute("DELETE FROM alameda.billed_practice WHERE legacy_order_practice_id = %s", (f["Id"],))
        else:
            cur.execute("SELECT staging.f25_apply_practice(%s::jsonb)", (fila,))
    elif tabla == "ResultadoItem":
        if op == "DELETE":
            cur.execute("DELETE FROM alameda.result WHERE result_id = %s", (f["IdItem"],))
        else:
            cur.execute("SELECT staging.f25_apply_result(%s::jsonb)", (fila,))


def drenar(conn, caer_antes_de_avanzar: bool = False, limite: int = 50_000) -> int:
    """Aplica lo pendiente del slot. `conn` es del superusuario y en autocommit; devuelve las transacciones aplicadas."""
    aplicadas = 0
    while True:
        posicion = conn.execute("SELECT applied_lsn::text FROM staging.f25_cdc_position WHERE slot_name = %s",
                                (SLOT,)).fetchone()[0]
        filas = conn.execute(
            "SELECT lsn::text, xid, data FROM pg_logical_slot_peek_changes(%s, NULL, %s, "
            "'include-xids', '1', 'include-timestamp', '1')", (SLOT, limite)).fetchall()
        if not filas:
            return aplicadas
        ultimo = None
        for lsn, xid, instante, cambios in _transacciones(filas):
            ultimo = lsn
            if not cambios:                         # nada de legacy
                continue
            if _n(lsn) <= _n(posicion):             # ya aplicada antes de una caída: se saltea
                SALTEADAS[0] += 1
                continue
            with conn.transaction():
                with conn.cursor() as cur:
                    for tabla, op, fila in cambios:
                        _aplicar(cur, tabla, op, fila)
                    cur.execute("INSERT INTO staging.f25_cdc_log (xid, commit_lsn, committed_at, changes) "
                                "VALUES (%s, %s, %s, %s) ON CONFLICT (commit_lsn) DO NOTHING",
                                (xid, lsn, instante, len(cambios)))
                    cur.execute("UPDATE staging.f25_cdc_position SET applied_lsn = %s, applied_at = clock_timestamp() "
                                "WHERE slot_name = %s", (lsn, SLOT))
            aplicadas += 1
        if ultimo is None:                          # solo había una transacción a medias: vuelve más tarde
            return aplicadas
        if caer_antes_de_avanzar:
            raise CaidaSimulada(f"aplicado hasta {ultimo}, el slot sin avanzar")
        conn.execute("SELECT pg_replication_slot_advance(%s, %s)", (SLOT, ultimo))
