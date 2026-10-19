"""Fase 25 · la convivencia: el frontal sigue escribiendo en legacy y el modelo lo sigue por CDC.

Tres hilos hacen de frontal Access (una sede cada uno) durante un día comprimido: protocolos con sus prácticas,
resultados que llegan después en otra transacción (como los trae ImportarEquipos), correcciones de un 3 % de
los resultados y un 1 % de prácticas borradas. Escriben con el rol `access_frontend`. Al lado, el aplicador de
`cdc.py` drena el slot cada medio segundo, y una vez, a mitad del día, se cae entre confirmar en el modelo y
avanzar el slot (la caída de la Fase 22).

Al final se drena lo que quede y se reconcilia lo escrito en el día: protocolos, prácticas, unidades,
resultados y valores, legacy contra el modelo. Y se cuenta lo que la convivencia pisó de la migración.

Uso (desde ruta-sql/src, con 04_cdc_setup.sql corrido):
    uv run python 25-la-migracion-sin-parar/05_convivencia.py [segundos] [semilla]
"""

import datetime as dt
import random
import statistics
import sys
import threading
import time
from pathlib import Path

import psycopg

from lab import config

sys.path.insert(0, str(Path(__file__).parent))
import cdc  # noqa: E402

SEGUNDOS = float(sys.argv[1]) if len(sys.argv) > 1 else 60.0
SEMILLA = int(sys.argv[2]) if len(sys.argv) > 2 else 1996
DIA = dt.date(2026, 10, 12)                 # el lunes siguiente al último día de la caja
SEDES = ("C", "A", "V")
PROTOCOLOS_POR_SEDE = 200                   # unos 600 en el día, como un día de 2026
FRONTAL = dict(config.POSTGRES, user="access_frontend", password="frontal-de-laboratorio")

admin = psycopg.connect(**config.POSTGRES, autocommit=True)


def preparar():
    pacientes = [r[0] for r in admin.execute(
        'SELECT DISTINCT o."IdPaciente" FROM legacy."Protocolos" AS o '
        'JOIN alameda.patient AS p ON p.legacy_patient_id = o."IdPaciente" '
        "WHERE o.\"Fecha\" >= '2026-09-01' AND o.\"Fecha\" < '2027-01-01' ORDER BY 1").fetchall()]
    practicas = admin.execute(
        'SELECT x."CodigoPractica", x."Nomenclador", count(*) FROM legacy."ProtocoloPracticas" AS x '
        'JOIN legacy."Protocolos" AS o USING ("IdProtocolo") '
        "WHERE o.\"Fecha\" >= '2026-09-01' AND o.\"Fecha\" < '2027-01-01' GROUP BY 1, 2 ORDER BY 1, 2").fetchall()
    analitos = {}
    for cod, practica in admin.execute('SELECT "CodDeterminacion", "CodPractica" FROM legacy."Determinaciones" '
                                       'ORDER BY 2, 1').fetchall():
        analitos.setdefault(practica, []).append(cod)
    # la obra social de cada protocolo, con el reparto de septiembre de 2026 (una fila por protocolo)
    obras = admin.execute(
        'SELECT o."IdObraSocial", o."ObraSocial" FROM legacy."Protocolos" AS o '
        "WHERE o.\"Fecha\" >= '2026-09-01' AND o.\"Fecha\" < '2026-10-01' AND o.\"IdObraSocial\" IS NOT NULL "
        'ORDER BY o."IdProtocolo"').fetchall()
    # las claves que daría la IDENTITY de SQL Server: desde 2012 cuenta desde diez millones (Fase 10); el
    # máximo de todo el rango es un número aleatorio de la replicación de 2004, a 70.000 del límite del entero
    inicio = admin.execute(
        'SELECT (SELECT max("IdProtocolo") FROM legacy."Protocolos" WHERE "Fecha" >= \'2012-01-01\'), '
        '(SELECT max("Id") FROM legacy."ProtocoloPracticas"), (SELECT max("IdItem") FROM legacy."ResultadoItem")').fetchone()
    return pacientes, practicas, analitos, obras, inicio


PACIENTES, PRACTICAS, ANALITOS, OBRAS, INICIO = preparar()
contador = {"protocolo": INICIO[0], "practica": INICIO[1], "item": INICIO[2]}
candado = threading.Lock()


def siguiente(clave: str) -> int:
    with candado:                               # el Access numera con DMax + 1: aquí, con un candado
        contador[clave] += 1
        return contador[clave]


def valor(rng: random.Random) -> str:
    v = rng.uniform(0.5, 300)
    return f"{v:.1f}".replace(".", ",") if rng.random() < 0.85 else f"{v:.1f}"


def frontal(sede: str, rng: random.Random, fin: float, hechos: list):
    conn = psycopg.connect(**FRONTAL, autocommit=False)
    pendientes = []                             # resultados que el equipo trae más tarde
    paso = SEGUNDOS / PROTOCOLOS_POR_SEDE
    for i in range(PROTOCOLOS_POR_SEDE):
        if time.time() > fin:
            break
        pid = siguiente("protocolo")
        obra = rng.choice(OBRAS)
        with conn.cursor() as cur:
            cur.execute('INSERT INTO legacy."Protocolos" ("IdProtocolo", "NroProtocolo", "IdPaciente", "Fecha", "Sede", '
                        '"ObraSocial", "IdObraSocial", "IdMedico", "Coseguro", "Estado") '
                        "VALUES (%s, %s, %s, %s, %s, %s, %s, NULL, NULL, 'PENDIENTE')",
                        (pid, f"{sede}-{pid % 10_000_000:07d}", rng.choice(PACIENTES), DIA, sede, obra[1], obra[0]))
            elegidas = rng.sample(PRACTICAS, k=rng.randint(1, 6))
            for cod, nom, _ in elegidas:
                xid = siguiente("practica")
                cur.execute('INSERT INTO legacy."ProtocoloPracticas" ("Id", "IdProtocolo", "CodigoPractica", '
                            '"Nomenclador", "Cantidad") VALUES (%s, %s, %s, %s, %s)',
                            (xid, pid, cod, nom, 2 if rng.random() < 0.02 else 1))
                if rng.random() < 0.01:
                    hechos.append(("borrar_practica", xid))
                pendientes += [(pid, a) for a in ANALITOS.get(cod, [])]
        conn.commit()
        if pendientes and rng.random() < 0.5:   # el equipo descarga lo que tiene
            with conn.cursor() as cur:
                for pid_r, analito in pendientes:
                    item = siguiente("item")
                    cur.execute('INSERT INTO legacy."ResultadoItem" ("IdItem", "IdProtocolo", "CodDeterminacion", '
                                '"Valor", "Unidad", "RangoReferencia", "Equipo", "FechaCarga") '
                                "VALUES (%s, %s, %s, %s, NULL, NULL, 'COBAS c311', %s)",
                                (item, pid_r, analito, valor(rng), dt.datetime.combine(DIA, dt.time(9)) +
                                 dt.timedelta(minutes=i)))
                    if rng.random() < 0.03:
                        hechos.append(("corregir", item))
            conn.commit()
            pendientes = []
        for tipo, clave in [h for h in hechos if h[0] in ("corregir", "borrar_practica")][:2]:
            with conn.cursor() as cur:
                if tipo == "corregir":
                    cur.execute('UPDATE legacy."ResultadoItem" SET "Valor" = %s WHERE "IdItem" = %s', (valor(rng), clave))
                else:
                    cur.execute('DELETE FROM legacy."ProtocoloPracticas" WHERE "Id" = %s', (clave,))
            conn.commit()
            hechos.remove((tipo, clave))
        time.sleep(paso * rng.uniform(0.5, 1.5))
    conn.close()


def aplicador(fin: float, estado: dict):
    conn = psycopg.connect(**config.POSTGRES, autocommit=True)
    cayo = False
    while time.time() < fin + 1:
        try:
            estado["aplicadas"] += cdc.drenar(conn, caer_antes_de_avanzar=(not cayo and time.time() > fin - SEGUNDOS / 2))
        except cdc.CaidaSimulada as e:
            cayo = True
            estado["caida"] = str(e)
            conn.close()                         # el proceso muere; el siguiente arranca de cero
            conn = psycopg.connect(**config.POSTGRES, autocommit=True)
        time.sleep(0.5)
    estado["aplicadas"] += cdc.drenar(conn)
    conn.close()


def main():
    rng = random.Random(SEMILLA)
    fin = time.time() + SEGUNDOS
    estado = {"aplicadas": 0, "caida": None}
    hilos = [threading.Thread(target=frontal, args=(s, random.Random(rng.random()), fin, [])) for s in SEDES]
    ap = threading.Thread(target=aplicador, args=(fin, estado))
    for h in hilos + [ap]:
        h.start()
    for h in hilos:
        h.join()
    ap.join()
    print(f"día comprimido en {SEGUNDOS:.0f} s · semilla {SEMILLA} · protocolos desde {INICIO[0] + 1}")
    aplicadas = admin.execute("SELECT count(*) FROM staging.f25_cdc_log").fetchone()[0]
    print(f"transacciones de legacy aplicadas: {aplicadas} · releídas tras la caída y salteadas: {cdc.SALTEADAS[0]}")
    print(f"caída: {estado['caida']}")

    atraso = [r[0] for r in admin.execute(
        "SELECT extract(epoch FROM applied_at - committed_at) * 1000 FROM staging.f25_cdc_log").fetchall()]
    if atraso:
        q = statistics.quantiles(atraso, n=20)
        print(f"atraso legacy → modelo (ms): mediana {statistics.median(atraso):.0f} · p95 {q[18]:.0f} · "
              f"máximo {max(atraso):.0f} · {len(atraso)} transacciones")

    p0, x0, i0 = INICIO
    r = admin.execute("""
        WITH lp AS (SELECT * FROM legacy."Protocolos" WHERE "Fecha" >= %(dia)s),
             lx AS (SELECT * FROM legacy."ProtocoloPracticas" WHERE "Id" > %(x0)s),
             li AS (SELECT * FROM legacy."ResultadoItem" WHERE "IdItem" > %(i0)s)
        SELECT (SELECT count(*) FROM lp),
               (SELECT count(*) FROM alameda.lab_order WHERE lab_order_id IN (SELECT "IdProtocolo" FROM lp)),
               (SELECT count(*) FROM lx),
               (SELECT count(*) FROM alameda.billed_practice WHERE legacy_order_practice_id > %(x0)s),
               (SELECT count(DISTINCT source_key) FROM staging.rejection WHERE phase = '25' AND source_table = 'ProtocoloPracticas'
                                                      AND source_key::integer IN (SELECT "Id" FROM lx)
                                                      AND NOT EXISTS (SELECT 1 FROM alameda.billed_practice AS b
                                                                      WHERE b.legacy_order_practice_id = source_key::integer)),
               (SELECT coalesce(sum("Cantidad"), 0) FROM lx),
               (SELECT coalesce(sum(quantity), 0) FROM alameda.billed_practice WHERE legacy_order_practice_id > %(x0)s),
               (SELECT count(*) FROM li),
               (SELECT count(*) FROM li JOIN alameda.result AS t ON t.result_id = li."IdItem"
                 CROSS JOIN LATERAL staging.f25_value(li."Valor") AS v
                 WHERE t.lab_order_id = li."IdProtocolo" AND t.analyte_code = li."CodDeterminacion"
                   AND t.value_numeric IS NOT DISTINCT FROM v.value_numeric),
               (SELECT count(*) FROM li JOIN staging.wide_result AS w ON w.result_id = li."IdItem"),
               (SELECT count(*) FROM staging.rejection WHERE phase = '25' AND rule = 'cdc.clave_ocupada'),
               (SELECT count(*) FROM alameda.billed_practice AS b WHERE b.legacy_order_practice_id > %(x0)s
                 AND NOT EXISTS (SELECT 1 FROM lx WHERE lx."Id" = b.legacy_order_practice_id))
        """, dict(dia=DIA, x0=x0, i0=i0)).fetchone()
    print(f"protocolos: legacy {r[0]} · modelo {r[1]}")
    print(f"prácticas: legacy {r[2]} · facturadas {r[3]} · rechazadas {r[4]} · sin destino {r[2] - r[3] - r[4]}")
    for regla, n in admin.execute("SELECT rule, count(*) FROM staging.rejection WHERE phase = '25' AND rule <> 'anchas.valor_no_numerico' "
                                  "GROUP BY 1 ORDER BY 1").fetchall():
        print(f"    rechazos {regla}: {n}")
    print(f"prácticas borradas en legacy que siguen facturadas en el modelo: {r[11]}")
    print(f"unidades facturadas: legacy (incluye las sin precio) {r[5]} · modelo {r[6]}")
    print(f"resultados: legacy {r[7]} · iguales en el modelo {r[8]} · distintos o faltantes {r[7] - r[8]}")
    print(f"resultados nuevos con una clave de las anchas: {r[9]} · claves ocupadas rechazadas: {r[10]}")


if __name__ == "__main__":
    main()
