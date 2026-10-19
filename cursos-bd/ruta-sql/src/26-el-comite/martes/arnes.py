"""🏆 "Un martes" · el arnés del boss global: cinco criterios.

    uv run python 26-el-comite/martes/arnes.py [directorio]

Evalúa el directorio que se le pasa (por defecto, este): corre `00_base.sql` del curso, prepara el CDC de la
Fase 25, corre tu `01_setup.sql` e importa tu `flujo.py`. Después juega el martes 6 de octubre de 2026:

  1. a la mañana, recepción todavía escribe en legacy: agrega prácticas olvidadas a protocolos de la semana,
     corrige una cantidad, borra una práctica cargada por error, y agrega un panel con uno de sus
     componentes al mismo protocolo (la caja no trae paneles en 2026); el CDC de la Fase 25 las trae;
  2. al mediodía se emite la presentación de la semana del lunes 28/09 al domingo 04/10, con
     `flujo.presentar(conn, desde)` y una conexión del rol `facturacion`, que no ve legacy;
  3. a la tarde llegan dos prácticas más de esa semana; el CDC las trae, y se vuelve a llamar a `presentar`.

Lo esperado lo calcula el arnés por su cuenta: lo que pasó sale de legacy (prácticas, cantidades, coseguros), y
los precios, los convenios, la composición, los topes y las fusiones de pacientes salen del modelo. Sale con
código 0 solo si pasan los cinco.

  C1  cada práctica presentada lleva el precio de su obra social vigente el día de la práctica
  C2  no se presenta lo que la obra social no paga: sin precio, fuera de convenio, incluida en su panel,
      o por encima del tope mensual del afiliado; y se presenta todo lo demás
  C3  la cantidad de cada práctica, y el coseguro descontado por protocolo, sin pasar de lo presentado
  C4  la reconciliación con la planilla de legacy cierra al centavo: cada práctica de la semana tiene un
      destino, y los totales por obra social son los esperados
  C5  legacy sigue viva: lo de la mañana entra, lo borrado no, la corrección sí, lo de la tarde queda para la
      próxima, y volver a emitir no cambia una presentación ya emitida
"""

import datetime as dt
import hashlib
import importlib.util
import pathlib
import sys
from collections import defaultdict
from decimal import Decimal

import psycopg

from lab import config

AQUI = pathlib.Path(__file__).parent
DIR = pathlib.Path(sys.argv[1]) if len(sys.argv) > 1 else AQUI
F25 = AQUI.parent.parent / "25-la-migracion-sin-parar"
sys.path.insert(0, str(F25))
import cdc  # noqa: E402

DESDE = dt.date(2026, 9, 28)
HASTA = DESDE + dt.timedelta(days=7)
MES = dt.date(2026, 9, 1)                       # el tope es por mes calendario: septiembre cuenta desde el 1
FRONTAL = dict(config.POSTGRES, user="access_frontend", password="frontal-de-laboratorio")
FACTURACION = dict(config.POSTGRES, user="facturacion", password="facturacion-de-laboratorio")
CENTAVO = Decimal("0.01")

admin = psycopg.connect(**config.POSTGRES, autocommit=True)


def correr(path: pathlib.Path) -> None:
    cdc.correr_sql(admin, path)


# 0. Lo que dejó una corrida anterior del arnés: solo sus propias filas, en legacy y en el modelo.
admin.execute("CREATE TABLE IF NOT EXISTS staging.martes_writes (legacy_id integer PRIMARY KEY, moment text NOT NULL)")
viejas = [r[0] for r in admin.execute("SELECT legacy_id FROM staging.martes_writes").fetchall()]
if viejas:
    admin.execute("DELETE FROM alameda.presentation_line WHERE legacy_order_practice_id = ANY(%s)", (viejas,))
    admin.execute("DELETE FROM alameda.presentation_excluded WHERE legacy_order_practice_id = ANY(%s)", (viejas,))
    admin.execute("DELETE FROM alameda.billed_practice WHERE legacy_order_practice_id = ANY(%s)", (viejas,))
    admin.execute('DELETE FROM legacy."ProtocoloPracticas" WHERE "Id" = ANY(%s)', (viejas,))
    admin.execute("DELETE FROM staging.rejection WHERE source_table = 'ProtocoloPracticas' AND source_key = ANY(%s)",
                  ([str(v) for v in viejas],))
    admin.execute("TRUNCATE staging.martes_writes")

correr(AQUI / "00_base.sql")
correr(F25 / "04_cdc_setup.sql")
correr(DIR / "01_setup.sql")
spec = importlib.util.spec_from_file_location("flujo", DIR / "flujo.py")
flujo = importlib.util.module_from_spec(spec)
spec.loader.exec_module(flujo)


# 1. Las escrituras del martes. Protocolos de la semana con obra social que tiene convenio, prácticas con
#    precio y convenio que el protocolo todavía no tiene, y obras sociales sin tope (para que el tope no
#    tape lo que se quiere ver). Siempre las mismas, en orden de clave.
candidatas = admin.execute("""
    SELECT o."IdProtocolo", c.code, c.nomenclator_code
    FROM legacy."Protocolos" AS o
    JOIN alameda.payer AS y ON y.payer_id = o."IdObraSocial"
    JOIN alameda.agreement AS a ON a.payer_code = y.payer_code AND a.site_code = o."Sede"
    JOIN alameda.practice_code AS c ON c.practice_id = a.practice_id AND c.nomenclator_code = 'NBU2012'
    WHERE o."Fecha" >= %s AND o."Fecha" < %s AND y.payer_code IN ('OSDE', 'SANCOR', 'OSECAC', 'UOM')
      AND NOT EXISTS (SELECT 1 FROM staging.practice_composition AS k WHERE k.component_id = a.practice_id)
      AND NOT EXISTS (SELECT 1 FROM legacy."ProtocoloPracticas" AS x JOIN alameda.practice_code AS pc
                        ON pc.nomenclator_code = x."Nomenclador" AND pc.code = x."CodigoPractica"
                      WHERE x."IdProtocolo" = o."IdProtocolo" AND pc.practice_id = a.practice_id)
      AND EXISTS (SELECT 1 FROM alameda.agreement_price AS p WHERE p.payer_code = y.payer_code
                    AND p.practice_id = a.practice_id AND p.valid_during @> o."Fecha"::date)
    ORDER BY o."IdProtocolo", c.code""", (DESDE, HASTA)).fetchall()
elegidas, vistos = [], set()
for pid, code, nom in candidatas:
    if pid not in vistos:
        elegidas.append((pid, code, nom))
        vistos.add(pid)
    if len(elegidas) == 8:
        break
# La caja no trae paneles en 2026: los trae recepción el martes. Un panel y uno de sus componentes, en un
# protocolo de la semana cuya obra social y sede tienen convenio y precio para los dos.
panel = admin.execute("""
    SELECT o."IdProtocolo", cp.code, cc.code
    FROM legacy."Protocolos" AS o
    JOIN alameda.payer AS y ON y.payer_id = o."IdObraSocial"
    JOIN staging.practice_composition AS k ON true
    JOIN alameda.agreement AS ap ON ap.payer_code = y.payer_code AND ap.site_code = o."Sede" AND ap.practice_id = k.panel_id
    JOIN alameda.agreement AS ac ON ac.payer_code = y.payer_code AND ac.site_code = o."Sede" AND ac.practice_id = k.component_id
    JOIN alameda.practice_code AS cp ON cp.practice_id = k.panel_id AND cp.nomenclator_code = 'NBU2012'
    JOIN alameda.practice_code AS cc ON cc.practice_id = k.component_id AND cc.nomenclator_code = 'NBU2012'
    WHERE o."Fecha" >= %s AND o."Fecha" < %s AND y.payer_code IN ('OSDE', 'SANCOR', 'OSECAC', 'UOM')
      AND o."IdProtocolo" NOT IN (SELECT pid FROM unnest(%s::integer[]) AS pid)
      AND EXISTS (SELECT 1 FROM alameda.agreement_price AS p WHERE p.payer_code = y.payer_code
                    AND p.practice_id = k.panel_id AND p.valid_during @> o."Fecha"::date)
      AND EXISTS (SELECT 1 FROM alameda.agreement_price AS p WHERE p.payer_code = y.payer_code
                    AND p.practice_id = k.component_id AND p.valid_during @> o."Fecha"::date)
    ORDER BY o."IdProtocolo", k.panel_id, k.component_id LIMIT 1""", (DESDE, HASTA, [e[0] for e in elegidas])).fetchone()
elegidas += [(panel[0], panel[1], "NBU2012"), (panel[0], panel[2], "NBU2012")]
proxima = admin.execute('SELECT max("Id") FROM legacy."ProtocoloPracticas"').fetchone()[0]
frontal = psycopg.connect(**FRONTAL, autocommit=True)


def agregar(i: int, momento: str) -> int:
    pid, code, nom = elegidas[i]
    lid = proxima + 1 + i
    frontal.execute('INSERT INTO legacy."ProtocoloPracticas" ("Id", "IdProtocolo", "CodigoPractica", "Nomenclador", '
                    '"Cantidad") VALUES (%s, %s, %s, %s, 1)', (lid, pid, code, nom))
    admin.execute("INSERT INTO staging.martes_writes VALUES (%s, %s)", (lid, momento))
    return lid


manana = [agregar(i, "mañana") for i in range(4)]                       # cuatro olvidadas
corregida = agregar(4, "mañana: cantidad 1 → 2")
frontal.execute('UPDATE legacy."ProtocoloPracticas" SET "Cantidad" = 2 WHERE "Id" = %s', (corregida,))
borrada = agregar(5, "mañana: cargada por error y borrada")
frontal.execute('DELETE FROM legacy."ProtocoloPracticas" WHERE "Id" = %s', (borrada,))
en_panel = [agregar(8, "mañana: el panel"), agregar(9, "mañana: un componente del panel")]
cdc.drenar(admin)

fact = psycopg.connect(**FACTURACION, autocommit=True)
error_presentar = None
try:
    flujo.presentar(fact, DESDE)
except Exception as e:  # un flujo que revienta deja todos los criterios en rojo, con el motivo
    error_presentar = f"{type(e).__name__}: {str(e).splitlines()[0][:140]}"


def foto():
    cab = admin.execute("SELECT payer_code, gross, copay, net, issued_at FROM alameda.presentation "
                        "WHERE week_start = %s ORDER BY 1", (DESDE,)).fetchall()
    lin = admin.execute("SELECT legacy_order_practice_id, quantity, unit_amount, amount FROM alameda.presentation_line "
                        "WHERE week_start = %s ORDER BY 1", (DESDE,)).fetchall()
    return hashlib.md5(repr((cab, lin)).encode()).hexdigest()


antes = foto()
tarde = [agregar(6, "tarde"), agregar(7, "tarde")]                       # después del corte
cdc.drenar(admin)
try:
    flujo.presentar(fact, DESDE)
except Exception as e:
    error_presentar = error_presentar or f"{type(e).__name__}: {str(e).splitlines()[0][:140]}"
despues = foto()


# 2. Lo esperado. Las prácticas desde el 1 de septiembre (el tope cuenta el mes), tal como estaban al corte.
filas = admin.execute("""
    SELECT x."Id", x."IdProtocolo", o."Fecha"::date, o."Sede", y.payer_code, pc.practice_id, x."Cantidad",
           coalesce(o."Coseguro", 0), coalesce(p.merged_into_patient_id, p.patient_id),
           (SELECT ap.amount FROM alameda.agreement_price AS ap WHERE ap.payer_code = y.payer_code
              AND ap.practice_id = pc.practice_id AND ap.valid_during @> o."Fecha"::date),
           EXISTS (SELECT 1 FROM alameda.agreement AS a WHERE a.payer_code = y.payer_code
                     AND a.practice_id = pc.practice_id AND a.site_code = o."Sede"),
           EXISTS (SELECT 1 FROM staging.practice_composition AS k
                   JOIN legacy."ProtocoloPracticas" AS x2 ON x2."IdProtocolo" = x."IdProtocolo"
                   JOIN alameda.practice_code AS pc2 ON pc2.nomenclator_code = x2."Nomenclador"
                                                    AND pc2.code = x2."CodigoPractica" AND pc2.practice_id = k.panel_id
                   WHERE k.component_id = pc.practice_id AND x2."Id" <> ALL(%(tarde)s)),
           (SELECT amount FROM (SELECT DISTINCT ON (1) 1, "Valor" AS amount FROM legacy."Precios" AS lp
                                JOIN legacy."Practicas" AS lq ON lp."CodPractica" = lq."CodNBU2012"
                                WHERE lp."IdObraSocial" = o."IdObraSocial" AND lp."VigenciaDesde" <= o."Fecha"
                                  AND x."CodigoPractica" IN (lq."CodNBU2012", lq."CodNBU")
                                ORDER BY 1, lp."VigenciaDesde" DESC, lp."Id" DESC) AS z)
    FROM legacy."ProtocoloPracticas" AS x
    JOIN legacy."Protocolos" AS o USING ("IdProtocolo")
    JOIN alameda.payer AS y ON y.payer_id = o."IdObraSocial"
    JOIN alameda.practice_code AS pc ON pc.nomenclator_code = x."Nomenclador" AND pc.code = x."CodigoPractica"
    JOIN alameda.patient AS p ON p.legacy_patient_id = o."IdPaciente"
    WHERE o."Fecha" >= %(mes)s AND o."Fecha" < %(hasta)s AND y.payer_code <> 'PARTICULAR'
      AND x."Id" <> ALL(%(tarde)s)
    ORDER BY o."Fecha", x."Id" """, dict(mes=MES, hasta=HASTA, tarde=tarde)).fetchall()
topes = dict(admin.execute("SELECT payer_code, units_per_month FROM staging.martes_cap").fetchall())

esperado, consumo = {}, defaultdict(int)
for (lid, oid, dia, sede, payer, practica, cant, cos, persona, precio, convenio, en_panel, precio_legacy) in filas:
    if precio is None:
        motivo = "sin_precio"
    elif not convenio:
        motivo = "fuera_de_convenio"
    elif en_panel:
        motivo = "incluida_en_panel"
    elif payer in topes and consumo[(persona, payer, dia.month)] + cant > topes[payer]:
        motivo = "excede_tope"
    else:
        motivo = None
        consumo[(persona, payer, dia.month)] += cant
    if dia >= DESDE:
        importe = None if motivo else (precio * cant).quantize(CENTAVO)
        esperado[lid] = dict(oid=oid, dia=dia, payer=payer, cant=cant, cos=Decimal(cos), precio=precio,
                             motivo=motivo, importe=importe,
                             legacy=(precio_legacy * cant).quantize(CENTAVO) if precio_legacy is not None else None)

totales = defaultdict(lambda: dict(gross=Decimal(0), copay=Decimal(0)))
por_protocolo = defaultdict(Decimal)
for e in esperado.values():
    if e["importe"] is not None:
        totales[e["payer"]]["gross"] += e["importe"]
        por_protocolo[(e["payer"], e["oid"])] += e["importe"]
cos_protocolo = {e["oid"]: e["cos"] for e in esperado.values()}
for (payer, oid), bruto in por_protocolo.items():
    totales[payer]["copay"] += min(cos_protocolo[oid], bruto)

lineas = {r[0]: r for r in admin.execute(
    "SELECT legacy_order_practice_id, payer_code, practice_date, quantity, unit_amount, amount "
    "FROM alameda.presentation_line WHERE week_start = %s", (DESDE,)).fetchall()}
excluidas = dict(admin.execute("SELECT legacy_order_practice_id, reason FROM alameda.presentation_excluded "
                               "WHERE week_start = %s", (DESDE,)).fetchall())
cabeceras = {r[0]: r for r in admin.execute(
    "SELECT payer_code, gross, copay, net FROM alameda.presentation WHERE week_start = %s", (DESDE,)).fetchall()}
de_la_manana = set(manana) | {corregida}

resultados = {}


def criterio(n: int, nombre: str, fn) -> None:
    try:
        ok, detalle = (False, f"presentar falló: {error_presentar}") if error_presentar else fn()
    except Exception as e:
        ok, detalle = False, f"excepción: {type(e).__name__}: {str(e)[:120]}"
    resultados[n] = ok
    print(f"{'✅' if ok else '❌'} C{n} · {nombre}: {detalle}")


def c1():
    malas = [lid for lid, l in lineas.items() if lid in esperado and esperado[lid]["precio"] is not None
             and Decimal(l[4]) != esperado[lid]["precio"]]
    octubre = sum(1 for lid, l in lineas.items() if l[2] >= dt.date(2026, 10, 1))
    return (not malas and len(lineas) > 0 and octubre > 0,
            f"{len(malas)} de {len(lineas)} líneas con otro precio; {octubre} líneas con el precio de octubre")


def c2():
    deben = {lid for lid, e in esperado.items() if e["motivo"] is None} - de_la_manana
    hay = set(lineas) - de_la_manana
    motivos_mal = sum(1 for lid, e in esperado.items() if e["motivo"] and excluidas.get(lid) != e["motivo"])
    cuenta = defaultdict(int)
    for e in esperado.values():
        cuenta[e["motivo"] or "presentada"] += 1
    return (deben == hay and motivos_mal == 0,
            f"presentadas de más {len(hay - deben)}, de menos {len(deben - hay)}, exclusiones con otro motivo o sin "
            f"motivo {motivos_mal}; lo esperado: {dict(sorted(cuenta.items()))}")


def c3():
    cant_mal = sum(1 for lid, l in lineas.items() if lid in esperado and l[3] != esperado[lid]["cant"])
    cos_mal = [p for p, t in totales.items() if p not in cabeceras or Decimal(cabeceras[p][2]) != t["copay"]]
    return (cant_mal == 0 and not cos_mal,
            f"{cant_mal} líneas con otra cantidad; coseguro distinto en {cos_mal or 'ninguna'} "
            f"(esperado {sum(t['copay'] for t in totales.values())})")


def c4():
    sin_destino = [lid for lid in esperado if lid not in lineas and lid not in excluidas]
    mal = [p for p, t in totales.items() if p not in cabeceras or Decimal(cabeceras[p][1]) != t["gross"]
           or Decimal(cabeceras[p][3]) != t["gross"] - t["copay"]]
    print("   La planilla de legacy contra la presentación, por obra social:")
    print(f"   {'obra social':12} {'planilla':>16} {'sin precio':>12} {'fuera conv.':>14} {'en panel':>12} "
          f"{'tope':>12} {'precio':>10} {'presentado':>16} {'coseguro':>13} {'neto':>16}")
    for payer in sorted({e["payer"] for e in esperado.values()}):
        es = [e for e in esperado.values() if e["payer"] == payer]
        planilla = sum(e["legacy"] or 0 for e in es)
        por = {m: sum(e["legacy"] or 0 for e in es if e["motivo"] == m)
               for m in ("sin_precio", "fuera_de_convenio", "incluida_en_panel", "excede_tope")}
        presentado = totales[payer]["gross"]
        dif_precio = sum((e["legacy"] or 0) - e["importe"] for e in es if e["importe"] is not None)
        sin_explicar = planilla - sum(por.values()) - dif_precio - presentado
        print(f"   {payer:12} {planilla:16,.2f} {por['sin_precio']:12,.2f} {por['fuera_de_convenio']:14,.2f} "
              f"{por['incluida_en_panel']:12,.2f} {por['excede_tope']:12,.2f} {dif_precio:10,.2f} {presentado:16,.2f} "
              f"{totales[payer]['copay']:13,.2f} {presentado - totales[payer]['copay']:16,.2f}"
              + (f"  sin explicar {sin_explicar}" if sin_explicar else ""))
    return (not sin_destino and not mal,
            f"{len(sin_destino)} prácticas de la semana sin destino; totales distintos en {mal or 'ninguna'}")


def c5():
    falta_manana = [lid for lid in manana if lid not in lineas]
    cant = lineas.get(corregida, (None,) * 4)[3]
    return (not falta_manana and cant == 2 and borrada not in lineas and not (set(tarde) & set(lineas))
            and antes == despues,
            f"de la mañana faltan {len(falta_manana)} de {len(manana)}; corregida con cantidad {cant}; borrada "
            f"{'presentada' if borrada in lineas else 'afuera'}; de la tarde en la presentación "
            f"{len(set(tarde) & set(lineas))} de {len(tarde)}; volver a emitir "
            f"{'no cambió nada' if antes == despues else 'cambió la presentación'}")


print(f"🏆 Un martes · semana del {DESDE:%d/%m} al {HASTA - dt.timedelta(days=1):%d/%m/%Y} · {len(esperado)} prácticas")
criterio(1, "precio a la fecha", c1)
criterio(2, "lo que no se paga no se presenta", c2)
criterio(3, "cantidad y coseguro", c3)
criterio(4, "la reconciliación cierra al centavo", c4)
criterio(5, "legacy sigue viva", c5)
admin.execute("SELECT pg_drop_replication_slot('f25_legacy')")    # un slot sin consumidor retiene WAL (Fase 22)
print(f"{sum(resultados.values())} de 5")
sys.exit(0 if all(resultados.values()) else 1)
