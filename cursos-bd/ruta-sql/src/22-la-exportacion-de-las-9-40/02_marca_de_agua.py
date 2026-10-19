"""Fase 22 · la exportación por marca de agua, con transacciones concurrentes de verdad.

Cuatro escritores replayan los 6.651 resultados del 26/12/2025, un protocolo por transacción. Entre
el INSERT y el COMMIT hay una demora aleatoria (95 % de 1 a 5 ms, y 5 % de 0,3 a 0,6 s): es la transacción lenta que la ficha describe. El
exportador avanza una marca de agua sobre `recorded_at`, y envía lo que ve confirmado con `recorded_at` posterior a
la marca.

Dos variantes, cada una en 10 corridas:
  ingenua   la marca es el máximo `recorded_at` ya exportado.
  ventana   la consulta mira desde (marca − 1 h del día): el retroceso cubre la demora lenta máxima y los empates
            de `recorded_at` (la caja registra al minuto: 6.651 resultados, 357 instantes); lo ya exportado
            se descarta por `result_id`, así que reenviar no duplica nada.

La verdad es `staging.f22_expected`. Pérdida = verdad − exportado. El modelo de demora es un supuesto del curso
(95 % de 1 a 5 ms, y 5 % de 0,3 a 0,6 s de reloj); la ventana de 1 h del día se elige por encima de la demora lenta máxima.

Uso (desde ruta-sql/src, con POSTGRES_PORT):  uv run python 22-la-exportacion-de-las-9-40/02_marca_de_agua.py
"""

import datetime as dt
import random
import statistics
import sys
import threading
import time

import psycopg

from lab import config

RUNS = 10
LOTE = 50
ESCRITORES = 4
LENTA_P = 0.05                  # fracción de transacciones lentas (la ficha: la transacción que tarda)
LENTA = (0.3, 0.6)              # segundos que tarda una transacción lenta antes de confirmar
RAPIDA = (0.001, 0.005)         # segundos de una transacción normal
DEMORA_MAX = LENTA[1]           # la demora que la ventana tiene que cubrir
TICK = 0.005
VENTANA = dt.timedelta(hours=1)  # en tiempo del día: cubre la demora lenta máxima (0,6 s de reloj ≈ 29 min del día) y los empates
DIA_EN_SEGUNDOS = 30.0         # el día del 26/12 se reproduce en 30 s de reloj: 1 s de reloj son 48 min del día
DIA = dt.datetime(2025, 12, 26)
INICIO = "2025-12-25 23:59:59"


def corrida(variante: str, rows: list, seed: int) -> int:
    rnd = random.Random(seed)
    admin = psycopg.connect(**config.POSTGRES, autocommit=True)
    admin.execute("TRUNCATE staging.f22_result")
    admin.execute("TRUNCATE staging.f22_exported")
    admin.execute("DELETE FROM staging.f22_watermark WHERE name = 'exp'")
    admin.execute("INSERT INTO staging.f22_watermark VALUES ('exp', %s)", (INICIO,))

    # Un lote es un protocolo: sus resultados se registran en una ventana corta y se confirman juntos. Lotes de
    # 50 filas consecutivas del día abarcan horas de `recorded_at`, y eso no es el modelo de la carga.
    por_protocolo: dict = {}
    for r in rows:
        por_protocolo.setdefault(r[1], []).append(r)
    lotes = sorted(por_protocolo.values(), key=lambda g: min(x[4] for x in g))
    cola = list(reversed(lotes))  # el último de la lista invertida es el protocolo más antiguo
    cerrojo = threading.Lock()
    inicio = time.perf_counter()
    hecho = threading.Event()

    def escritor(_):
        conn = psycopg.connect(**config.POSTGRES, autocommit=False)
        while True:
            with cerrojo:
                if not cola:
                    break
                lote = cola.pop()
            # Pacing: el protocolo se registra a su hora del día, reproducida en DIA_EN_SEGUNDOS de reloj.
            llega = inicio + (min(x[4] for x in lote) - DIA).total_seconds() * DIA_EN_SEGUNDOS / 86400
            espera = llega - time.perf_counter()
            if espera > 0:
                time.sleep(espera)
            with conn.transaction():
                with conn.cursor() as cur:
                    for r in lote:
                        cur.execute("INSERT INTO staging.f22_result VALUES (%s, %s, %s, %s, %s)", r)
                time.sleep(rnd.uniform(*LENTA) if rnd.random() < LENTA_P else rnd.uniform(*RAPIDA))
        conn.close()

    def exportador():
        conn = psycopg.connect(**config.POSTGRES, autocommit=True)
        enviados: set = set()  # lo que este exportador ya mandó: la ventana vuelve a leer filas que ya salieron
        while True:
            wm = conn.execute("SELECT mark FROM staging.f22_watermark WHERE name = 'exp'").fetchone()[0]
            desde = wm if variante == "ingenua" else wm - VENTANA
            visibles = conn.execute("""SELECT result_id, recorded_at FROM staging.f22_result
                                       WHERE recorded_at > %s ORDER BY recorded_at, result_id LIMIT 1000""", (desde,)).fetchall()
            nuevos = [v for v in visibles if v[0] not in enviados]
            if nuevos:
                conn.execute("""INSERT INTO staging.f22_exported (result_id) SELECT unnest(%s::int[])
                                ON CONFLICT (result_id) DO NOTHING""", ([v[0] for v in nuevos],))
                enviados.update(v[0] for v in nuevos)
                nueva = max(v[1] for v in nuevos)
                if nueva > wm:
                    conn.execute("UPDATE staging.f22_watermark SET mark = %s WHERE name = 'exp'", (nueva,))
            elif hecho.is_set():
                break
            time.sleep(TICK)
        conn.close()

    hilos = [threading.Thread(target=escritor, args=(i,)) for i in range(ESCRITORES)]
    exp = threading.Thread(target=exportador)
    exp.start()
    for h in hilos:
        h.start()
    for h in hilos:
        h.join()
    hecho.set()
    exp.join()

    perdidas = admin.execute("""SELECT count(*) FROM staging.f22_expected e
                                WHERE NOT EXISTS (SELECT 1 FROM staging.f22_exported x WHERE x.result_id = e.result_id)""").fetchone()[0]
    admin.close()
    return perdidas


def main() -> None:
    variante = sys.argv[1] if len(sys.argv) > 1 else "ingenua"
    admin = psycopg.connect(**config.POSTGRES, autocommit=True)
    rows = admin.execute("""SELECT result_id, lab_order_id, analyte_code, value_numeric, recorded_at
                            FROM staging.f22_result_source ORDER BY recorded_at, result_id""").fetchall() \
        if admin.execute("SELECT to_regclass('staging.f22_result_source')").fetchone()[0] else None
    if rows is None:
        admin.execute("""CREATE TABLE staging.f22_result_source AS
                         SELECT result_id, lab_order_id, analyte_code, value_numeric, recorded_at FROM alameda.result
                         WHERE recorded_at >= '2025-12-26' AND recorded_at < '2025-12-27'""")
        rows = admin.execute("""SELECT result_id, lab_order_id, analyte_code, value_numeric, recorded_at
                                FROM staging.f22_result_source ORDER BY recorded_at, result_id""").fetchall()
    admin.close()
    print(f"variante {variante} · {len(rows)} resultados · un protocolo por transacción · {LENTA_P:.0%} lentas de {LENTA[0]}–{LENTA[1]} s de reloj · día de {DIA_EN_SEGUNDOS:.0f} s")
    perdidas = []
    t0 = time.perf_counter()
    for i in range(RUNS):
        p = corrida(variante, rows, seed=1996 + i)
        perdidas.append(p)
        print(f"  corrida {i + 1:2d}: {p} filas perdidas")
    con = sum(1 for p in perdidas if p > 0)
    print(f"corridas con pérdida: {con} de {RUNS} · mediana de filas perdidas: {statistics.median(perdidas)} · {time.perf_counter() - t0:.1f} s")


if __name__ == "__main__":
    main()
