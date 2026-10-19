"""El frontal de 2011, simulado contra la caja de MySQL: tres pantallas como las armaba Access sobre tablas vinculadas
por ODBC, y las mismas tres como las pediría alguien que sabe lo que la pantalla muestra. Para cada una se mide lo
que cruza la red: viajes (sentencias), filas y bytes que manda el servidor (Bytes_sent de la sesión de MySQL).

1. El formulario de protocolos en hoja de datos: primero todas las claves de la tabla, después las filas de a diez
   hasta llenar la pantalla (60 filas), como lee Access una tabla vinculada.
2. El informe de la pantalla, cada protocolo con sus resultados: una consulta por protocolo (N+1). Todo lo que
   llega se muestra; lo que sobra son viajes.
3. Los turnos del día, en una tabla local del .accdb, unidos con Pacientes del servidor: el join se hace en el
   cliente, con la tabla de pacientes entera.

Uso, desde src/, después de 14-la-base-no-estaba-lenta/01_autoindex_copy.sql:
    uv run python 14-la-base-no-estaba-lenta/front.py
"""

import time

import pymysql

from lab import config

SHOWN = 60          # filas visibles en la hoja de datos
BATCH = 10          # filas por pedido, como Access
DAY = "2026-10-07"  # el día de los turnos


class Wire:
    """Una conexión que cuenta lo que cruza la red."""

    def __init__(self):
        self.conn = pymysql.connect(host=config.MYSQL["host"], port=config.MYSQL["port"], user="root",
                                    password=config.PASSWORD, autocommit=True)
        self.trips = self.rows = 0
        self._calibrate()

    def _bytes_sent(self) -> int:
        with self.conn.cursor() as cur:
            cur.execute("SHOW SESSION STATUS LIKE 'Bytes_sent'")
            return int(cur.fetchone()[1])

    def _calibrate(self) -> None:
        # lo que manda el servidor por la propia consulta de estado, para restarlo
        first = self._bytes_sent()
        self.status_cost = self._bytes_sent() - first

    def query(self, sql: str, args=None) -> list:
        with self.conn.cursor() as cur:
            cur.execute(sql, args)
            rows = cur.fetchall()
        self.trips += 1
        self.rows += len(rows)
        return rows

    def measure(self, name: str, shown: int, screen) -> dict:
        self.trips = self.rows = 0
        before = self._bytes_sent()
        start = time.perf_counter()
        screen(self)
        elapsed = (time.perf_counter() - start) * 1000
        sent = self._bytes_sent() - before - self.status_cost
        # shown=None: la pantalla muestra todo lo que llega (los resultados de cada protocolo)
        return dict(name=name, trips=self.trips, rows=self.rows, shown=shown or self.rows, bytes=sent, ms=elapsed)


def protocol_keys(w: Wire) -> list:
    return [r[0] for r in w.query("SELECT IdProtocolo FROM staging.protocolos ORDER BY IdProtocolo DESC")]


def form_access(w: Wire) -> None:
    keys = protocol_keys(w)
    for i in range(0, SHOWN, BATCH):
        batch = keys[i:i + BATCH]
        w.query(f"SELECT * FROM staging.protocolos WHERE IdProtocolo IN ({', '.join(['%s'] * len(batch))})", batch)


def form_right(w: Wire) -> None:
    w.query("SELECT * FROM staging.protocolos ORDER BY IdProtocolo DESC LIMIT %s", (SHOWN,))


def screen_ids(w: Wire) -> list:
    return [r[0] for r in w.query("SELECT IdProtocolo FROM staging.protocolos ORDER BY IdProtocolo DESC LIMIT %s",
                                  (SHOWN,))]


def subform_access(w: Wire) -> None:
    for protocol in screen_ids(w):
        w.query("SELECT * FROM staging.resultado_item WHERE IdProtocolo = %s", (protocol,))


def subform_right(w: Wire) -> None:
    ids = screen_ids(w)
    w.query(f"SELECT * FROM staging.resultado_item WHERE IdProtocolo IN ({', '.join(['%s'] * len(ids))})", ids)


def local_appointments(w: Wire) -> list:
    # la tabla local de turnos: los pacientes con protocolo ese día en el central (no cruza la red en Access;
    # aquí se arma antes de medir)
    return [r[0] for r in w.query("SELECT DISTINCT IdPaciente FROM staging.protocolos "
                                  "WHERE Fecha >= %s AND Fecha < %s + INTERVAL 1 DAY AND Sede = 'C'", (DAY, DAY))]


def appointments_access(w: Wire, patients: list) -> None:
    wanted = set(patients)
    rows = w.query("SELECT * FROM legacy.Pacientes")
    [row for row in rows if row[0] in wanted]   # el join, en el cliente


def appointments_right(w: Wire, patients: list) -> None:
    w.query(f"SELECT * FROM legacy.Pacientes WHERE IdPaciente IN ({', '.join(['%s'] * len(patients))})", patients)


def main() -> None:
    w = Wire()
    patients = local_appointments(w)
    results = [
        w.measure("formulario, como Access", SHOWN, form_access),
        w.measure("formulario, 60 filas", SHOWN, form_right),
        w.measure("resultados, uno por protocolo", None, subform_access),
        w.measure("resultados, una consulta", None, subform_right),
        w.measure("turnos, join en el cliente", len(patients), lambda x: appointments_access(x, patients)),
        w.measure("turnos, join en el servidor", len(patients), lambda x: appointments_right(x, patients)),
    ]
    print(f"{'pantalla':34} {'viajes':>7} {'filas':>10} {'muestra':>8} {'filas/muestra':>14} {'bytes':>12} {'ms':>9}")
    for r in results:
        print(f"{r['name']:34} {r['trips']:7} {r['rows']:10} {r['shown']:8} {r['rows'] / r['shown']:14.1f} "
              f"{r['bytes']:12} {r['ms']:9.1f}")


if __name__ == "__main__":
    main()
