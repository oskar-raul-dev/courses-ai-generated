"""Fase 16 · cada diseño de numeración, intercalado con lab race y autorizado contra el web service simulado.

    uv run python 16-el-folio-sin-huecos/races.py dmax|ultimo_numero|sequence|counter|lost_response|reconcile

Dos cajas (a y b) del punto de venta 1, comprobantes B. El organismo arranca en el último autorizado de
la caja (247.581). Cada paso que llama al organismo es una función que corre en el hilo de su caja.
"""

import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent))

from fiscal import FiscalService, Rejected, Timeout  # noqa: E402
from lab.race import Race  # noqa: E402

POS, KIND, START = 1, "B", 247581
ws = FiscalService()

RESET = [
    "TRUNCATE staging.invoice",
    f"DELETE FROM staging.invoice_counter",
    f"INSERT INTO staging.invoice_counter VALUES ({POS}, '{KIND}', {START})",
    f"SELECT setval('staging.invoice_number_seq', {START})",
]
CHECK = [
    "SELECT count(*) AS invoices, count(DISTINCT number) AS numbers, count(cae) AS authorized FROM staging.invoice",
    "SELECT string_agg(number || ':' || coalesce(left(cae, 4) || '…', 'sin CAE'), ' ' ORDER BY invoice_id) FROM staging.invoice",
    "SELECT string_agg(number::text, ' ' ORDER BY number) AS en_el_organismo FROM fiscal.authorized",
]


def authorize(number_sql: str):
    """Un paso que lee el número que la caja ya tiene y lo manda al organismo; guarda el CAE si vuelve."""
    def step(conn):
        number = conn.execute(number_sql).fetchone()[0]
        try:
            cae = ws.request_cae(POS, KIND, number)
        except Rejected as exc:
            return f"organismo: rechazado {exc.code} ({exc.message})"
        except Timeout as exc:
            return f"organismo: {exc}"
        conn.execute("UPDATE staging.invoice SET cae = %s WHERE invoice_id = (SELECT max(invoice_id) FROM staging.invoice "
                     "WHERE number = %s AND cae IS NULL)", (cae, number))
        return f"organismo: autorizado {number}"
    return step


def race(steps: list[tuple[str, object]], order: str) -> None:
    ws.reset()
    r = Race("postgres", setup=RESET, checks=CHECK)
    for label, action in steps:
        r.step(label, action)
    r.run(order.split())


def dmax() -> None:
    """2004 y 2015: el número es el máximo más uno, sin transacción, en cada caja."""
    nxt = f"SELECT coalesce(max(number), {START}) + 1 FROM staging.invoice"
    race([
        ("a1", nxt), ("b1", nxt),
        ("a2", f"INSERT INTO staging.invoice (point_of_sale, kind, number, till) "
               f"SELECT {POS}, '{KIND}', coalesce(max(number), {START}) + 1, 'a' FROM staging.invoice"),
        ("b2", f"INSERT INTO staging.invoice (point_of_sale, kind, number, till) VALUES ({POS}, '{KIND}', {START + 1}, 'b')"),
        ("a3", authorize("SELECT number FROM staging.invoice WHERE till = 'a'")),
        ("b3", authorize("SELECT number FROM staging.invoice WHERE till = 'b'")),
    ], "a1 b1 a2 b2 a3 b3")


def ultimo_numero() -> None:
    """2015, el arreglo de Matías: UPDATE y después SELECT, en ese orden y sin transacción."""
    upd = f"UPDATE staging.invoice_counter SET last_number = last_number + 1 WHERE point_of_sale = {POS} AND kind = '{KIND}'"
    sel = f"SELECT last_number FROM staging.invoice_counter WHERE point_of_sale = {POS} AND kind = '{KIND}'"
    ins = (f"INSERT INTO staging.invoice (point_of_sale, kind, number, till) SELECT {POS}, '{KIND}', last_number, '%s' "
           f"FROM staging.invoice_counter WHERE point_of_sale = {POS} AND kind = '{KIND}'")
    race([
        ("a1", upd), ("b1", upd), ("a2", sel), ("b2", sel), ("a3", ins % "a"), ("b3", ins % "b"),
        ("a4", authorize("SELECT number FROM staging.invoice WHERE till = 'a'")),
        ("b4", authorize("SELECT number FROM staging.invoice WHERE till = 'b'")),
    ], "a1 b1 a2 b2 a3 b3 a4 b4")


def sequence() -> None:
    """Una secuencia: nunca repite, pero no espera a nadie y no se deshace."""
    ins = (f"INSERT INTO staging.invoice (point_of_sale, kind, number, till) "
           f"VALUES ({POS}, '{KIND}', nextval('staging.invoice_number_seq'), '%s') RETURNING number")
    race([
        ("a1", "BEGIN"), ("a2", ins % "a"),
        ("b1", "BEGIN"), ("b2", ins % "b"),
        ("b3", authorize("SELECT number FROM staging.invoice WHERE till = 'b'")), ("b4", "COMMIT"),
        ("a3", "ROLLBACK"),
        ("c1", ins % "c"),
        ("c2", authorize("SELECT number FROM staging.invoice WHERE till = 'c'")),
    ], "a1 a2 b1 b2 b3 b4 a3 c1 c2")


def counter() -> None:
    """La fila contador dentro de la transacción: el número se reserva, se autoriza y se confirma junto."""
    take = (f"UPDATE staging.invoice_counter SET last_number = last_number + 1 "
            f"WHERE point_of_sale = {POS} AND kind = '{KIND}' RETURNING last_number")
    ins = (f"INSERT INTO staging.invoice (point_of_sale, kind, number, till) SELECT {POS}, '{KIND}', last_number, '%s' "
           f"FROM staging.invoice_counter WHERE point_of_sale = {POS} AND kind = '{KIND}'")
    race([
        ("a1", "BEGIN"), ("a2", take), ("a3", ins % "a"),
        ("b1", "BEGIN"), ("b2", take),
        ("a4", authorize("SELECT number FROM staging.invoice WHERE till = 'a'")), ("a5", "COMMIT"),
        ("b3", ins % "b"), ("b4", authorize("SELECT number FROM staging.invoice WHERE till = 'b'")), ("b5", "COMMIT"),
    ], "a1 a2 a3 b1 b2 a4 a5 b3 b4 b5")


def lost_response(reconcile: bool = False) -> None:
    """La fila contador, y el organismo que autoriza pero no responde: la caja deshace, el organismo no."""
    take = (f"UPDATE staging.invoice_counter SET last_number = last_number + 1 "
            f"WHERE point_of_sale = {POS} AND kind = '{KIND}' RETURNING last_number")
    ins = (f"INSERT INTO staging.invoice (point_of_sale, kind, number, till) SELECT {POS}, '{KIND}', last_number, '%s' "
           f"FROM staging.invoice_counter WHERE point_of_sale = {POS} AND kind = '{KIND}'")

    def arm(conn):
        ws.lose_next_response()
        return "la próxima respuesta del organismo se pierde"

    def a_authorize(conn):
        number = conn.execute("SELECT number FROM staging.invoice WHERE till = 'a'").fetchone()[0]
        try:
            cae = ws.request_cae(POS, KIND, number)
        except Timeout:
            if not reconcile:
                conn.execute("ROLLBACK")          # la caja hace lo de siempre: deshace y reintenta después
                return f"organismo: sin respuesta; la caja deshace el {number}"
            cae = ws.query(POS, KIND, number)     # FECompConsultar: ¿llegó o no?
            if cae is None:
                conn.execute("ROLLBACK")
                return f"organismo: sin respuesta y sin autorizar; la caja deshace el {number}"
        conn.execute("UPDATE staging.invoice SET cae = %s WHERE till = 'a'", (cae,))
        conn.execute("COMMIT")
        return f"organismo: autorizado {number} (confirmado después de consultar)" if reconcile else f"autorizado {number}"

    race([
        ("a1", arm), ("a2", "BEGIN"), ("a3", take), ("a4", ins % "a"), ("a5", a_authorize),
        ("b1", "BEGIN"), ("b2", take), ("b3", ins % "b"),
        ("b4", authorize("SELECT number FROM staging.invoice WHERE till = 'b'")), ("b5", "COMMIT"),
    ], "a1 a2 a3 a4 a5 b1 b2 b3 b4 b5")


if __name__ == "__main__":
    name = sys.argv[1] if len(sys.argv) > 1 else "counter"
    {"dmax": dmax, "ultimo_numero": ultimo_numero, "sequence": sequence, "counter": counter,
     "lost_response": lost_response, "reconcile": lambda: lost_response(True)}[name]()
    ws.close()
