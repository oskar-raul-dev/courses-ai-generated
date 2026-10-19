"""Fase 25 · el simulacro de corte, con su vuelta atrás.

El frontal escribe como en `05_convivencia.py` y el aplicador lo sigue. A los `segundos` se corta:

  1. congelar  se le quita la escritura al rol del frontal y se cortan sus sesiones (lo que ve recepción: un
               error de permisos, contado);
  2. drenar    el aplicador trae todo lo confirmado hasta el LSN del congelamiento;
  3. reconciliar  el día, legacy contra el modelo: protocolos, prácticas, unidades y resultados;
  4. decidir   si todo da cero, el corte sigue (en Alameda, el frontal nuevo empieza a escribir en el modelo);
               si no, vuelta atrás: se le devuelve la escritura al frontal y legacy sigue mandando.

Con `--romper`, antes de reconciliar se borra del modelo una práctica del día: la reconciliación tiene que
encontrarla y el simulacro tiene que volver atrás.

Uso (desde ruta-sql/src, después de 04_cdc_setup.sql):
    uv run python 25-la-migracion-sin-parar/07_corte.py [segundos] [--romper]
"""

import importlib.util
import sys
import threading
import time
from pathlib import Path

import psycopg

from lab import config

AQUI = Path(__file__).parent
sys.path.insert(0, str(AQUI))
import cdc  # noqa: E402

ROMPER = "--romper" in sys.argv
args = [a for a in sys.argv[1:] if not a.startswith("--")]
SEGUNDOS = float(args[0]) if args else 20.0
sys.argv = [sys.argv[0], str(SEGUNDOS), "1996"]          # 05_convivencia lee sus argumentos al importarse
spec = importlib.util.spec_from_file_location("convivencia", AQUI / "05_convivencia.py")
conv = importlib.util.module_from_spec(spec)
spec.loader.exec_module(conv)

TABLAS = 'legacy."Protocolos", legacy."ProtocoloPracticas", legacy."ResultadoItem"'
admin = psycopg.connect(**config.POSTGRES, autocommit=True)
errores_frontal = []


# el mismo ritmo de 05_convivencia (200 protocolos por sede cada `segundos`), pero sin final: lo detiene el corte
conv.SEGUNDOS *= 100
conv.PROTOCOLOS_POR_SEDE *= 100


def frontal_hasta_el_corte(sede, rng, fin):
    try:
        conv.frontal(sede, rng, fin + 3600, [])
    except psycopg.Error as e:
        errores_frontal.append(type(e).__name__ + ": " + str(e).splitlines()[0][:90])


def reconciliar():
    return admin.execute("""
        WITH lp AS (SELECT "IdProtocolo" FROM legacy."Protocolos" WHERE "Fecha" >= %(dia)s),
             lx AS (SELECT * FROM legacy."ProtocoloPracticas" WHERE "Id" > %(x0)s),   -- por la clave: sin índice
             li AS (SELECT * FROM legacy."ResultadoItem" WHERE "IdItem" > %(i0)s)      -- por IdProtocolo, 97 s
        SELECT (SELECT count(*) FROM lp) - (SELECT count(*) FROM alameda.lab_order WHERE lab_order_id IN (SELECT * FROM lp)),
               (SELECT count(*) FROM lx WHERE NOT EXISTS (SELECT 1 FROM alameda.billed_practice AS b
                                                          WHERE b.legacy_order_practice_id = lx."Id" AND b.quantity = lx."Cantidad")
                                          AND NOT EXISTS (SELECT 1 FROM staging.rejection AS r
                                                          WHERE r.phase = '25' AND r.source_table = 'ProtocoloPracticas'
                                                            AND r.source_key = lx."Id"::text)),
               (SELECT count(*) FROM li WHERE NOT EXISTS (
                    SELECT 1 FROM alameda.result AS t CROSS JOIN LATERAL staging.f25_value(li."Valor") AS v
                    WHERE t.result_id = li."IdItem" AND t.lab_order_id = li."IdProtocolo"
                      AND t.value_numeric IS NOT DISTINCT FROM v.value_numeric))
        """, dict(dia=conv.DIA, x0=conv.INICIO[1], i0=conv.INICIO[2])).fetchone()


def main():
    rng = conv.random.Random(1996)
    fin = time.time() + SEGUNDOS
    hilos = [threading.Thread(target=frontal_hasta_el_corte, args=(s, conv.random.Random(rng.random()), fin))
             for s in conv.SEDES]
    for h in hilos:
        h.start()
    aplicador = psycopg.connect(**config.POSTGRES, autocommit=True)
    while time.time() < fin:
        cdc.drenar(aplicador)
        time.sleep(0.5)

    t0 = time.time()
    admin.execute(f"REVOKE INSERT, UPDATE, DELETE ON {TABLAS} FROM access_frontend")
    cortadas = admin.execute("SELECT count(pg_terminate_backend(pid)) FROM pg_stat_activity "
                             "WHERE usename = 'access_frontend'").fetchone()[0]
    for h in hilos:
        h.join()
    lsn = admin.execute("SELECT pg_current_wal_lsn()::text").fetchone()[0]
    t1 = time.time()
    n = cdc.drenar(aplicador)
    aplicado = admin.execute("SELECT applied_lsn::text FROM staging.f25_cdc_position").fetchone()[0]
    t2 = time.time()
    if ROMPER:
        admin.execute("DELETE FROM alameda.billed_practice WHERE legacy_order_practice_id = (SELECT max(\"Id\") "
                      "FROM legacy.\"ProtocoloPracticas\" WHERE \"IdProtocolo\" IN "
                      "(SELECT \"IdProtocolo\" FROM legacy.\"Protocolos\" WHERE \"Fecha\" >= %s))", (conv.DIA,))
    dif = reconciliar()
    t3 = time.time()
    if dif == (0, 0, 0):
        decision = "el corte sigue: legacy queda de solo lectura y el modelo manda"
    else:
        admin.execute(f"GRANT INSERT, UPDATE, DELETE ON {TABLAS} TO access_frontend")
        decision = "vuelta atrás: el frontal vuelve a escribir en legacy"
    t4 = time.time()

    print(f"frontal escribiendo {SEGUNDOS:.0f} s · sesiones cortadas al congelar: {cortadas}")
    print(f"lo que vio recepción: {len(errores_frontal)} errores · {sorted(set(errores_frontal))}")
    print(f"congelar {1000 * (t1 - t0):.0f} ms · drenar {1000 * (t2 - t1):.0f} ms ({n} transacciones; "
          f"LSN del congelamiento {lsn}, aplicado hasta {aplicado}) · reconciliar {1000 * (t3 - t2):.0f} ms")
    print(f"diferencias (protocolos, prácticas, resultados): {dif}")
    print(f"decisión: {decision} · ventana sin escritura: {t4 - t0:.1f} s")


if __name__ == "__main__":
    main()
