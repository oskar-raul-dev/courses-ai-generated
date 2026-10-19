"""💀 Boss V · Las 9:40 · el arnés: cinco criterios.

    uv run python 23-la-base-como-producto/boss/arnes.py [directorio]

Evalúa el directorio que se le pasa (por defecto, este): corre su `01_setup.sql`, importa su `flujo.py` y prueba.
Necesita el laboratorio con `uv run lab up base api` y `23-la-base-como-producto/01_setup.sql` corrido.
Sale con código 0 solo si pasan los cinco.

  C1  la exportación no pierde la fila de la transacción que confirma tarde
  C2  un mensaje repetido por el transporte no se aplica dos veces en el destino
  C3  la notificación de un detectable sale dentro de las doce horas del registro
  C4  la API no le muestra a un paciente informes de otro
  C5  una corrección vieja que llega tarde no pisa a la nueva
"""

import base64
import datetime as dt
import hashlib
import hmac
import importlib.util
import json
import os
import pathlib
import sys
import time
import urllib.error
import urllib.request

import psycopg

from lab import config

DIR = pathlib.Path(sys.argv[1]) if len(sys.argv) > 1 else pathlib.Path(__file__).parent
API = f"http://127.0.0.1:{os.environ.get('API_PORT', '23000')}"
SECRET = os.environ.get("API_JWT_SECRET", "ruta-sql-laboratorio-secreto-jwt-de-prueba-2026").encode()
DIA = dt.date(2025, 12, 26)

admin = psycopg.connect(**config.POSTGRES, autocommit=True)
admin.execute((DIR / "01_setup.sql").read_text(encoding="utf-8"))
spec = importlib.util.spec_from_file_location("flujo", DIR / "flujo.py")
flujo = importlib.util.module_from_spec(spec)
spec.loader.exec_module(flujo)
time.sleep(1)  # PostgREST recarga el esquema con el NOTIFY del setup

resultados: dict[int, bool] = {}


def criterio(n: int, nombre: str, fn) -> None:
    try:
        ok, detalle = fn()
    except Exception as e:  # un criterio que revienta cuenta como rojo
        ok, detalle = False, f"excepción: {type(e).__name__}: {str(e)[:120]}"
    resultados[n] = ok
    print(f"{'✅' if ok else '❌'} C{n} · {nombre}: {detalle}")


def c1():
    admin.execute("INSERT INTO staging.b5_watermark VALUES ('portal', %s) ON CONFLICT (name) DO UPDATE SET mark = excluded.mark",
                  (dt.datetime(2025, 12, 26, 0, 0),))
    tarde = psycopg.connect(**config.POSTGRES, autocommit=False)
    otra = psycopg.connect(**config.POSTGRES, autocommit=True)
    exp = psycopg.connect(**config.POSTGRES, autocommit=True)
    flujo.registrar_resultado(tarde, 1, 1, "GLU", "110", dt.datetime(2025, 12, 26, 10, 0))   # abierta, sin confirmar
    flujo.registrar_resultado(otra, 2, 2, "GLU", "96", dt.datetime(2025, 12, 26, 10, 5))     # confirma primero
    flujo.exportar(exp)
    tarde.commit()                                                                           # confirma tarde
    flujo.exportar(exp)
    flujo.exportar(exp)
    salieron = {r[0] for r in admin.execute("SELECT result_id FROM staging.b5_exported").fetchall()}
    for c in (tarde, otra, exp):
        c.close()
    return {1, 2} <= salieron, f"exportados {sorted(salieron)} de [1, 2]"


def c2():
    conn = psycopg.connect(**config.POSTGRES, autocommit=True)
    flujo.entregar(conn, "res-500", 1, "GLU 110")
    flujo.entregar(conn, "res-500", 1, "GLU 110")
    n = admin.execute("SELECT count(*) FROM staging.b5_destination WHERE message_id = 'res-500'").fetchone()[0]
    conn.close()
    return n == 1, f"el destino tiene {n} copias de res-500"


def c3():
    conn = psycopg.connect(**config.POSTGRES, autocommit=True)
    registrado = dt.datetime(2025, 12, 26, 8, 0)
    flujo.registrar_resultado(conn, 700, 7, "COVPCR", "DETECTABLE", registrado)
    flujo.cerrar_dia(conn, DIA)
    fila = admin.execute("SELECT min(notified_at) FROM staging.b5_notification WHERE result_id = 700").fetchone()[0]
    conn.close()
    if fila is None:
        return False, "el detectable no se notificó"
    horas = (fila - registrado).total_seconds() / 3600
    return horas <= 12, f"notificado {horas:.1f} h después del registro (plazo: 12 h)"


def _jwt(claims: dict) -> str:
    b = lambda x: base64.urlsafe_b64encode(x).rstrip(b"=").decode()
    h = b(json.dumps({"alg": "HS256", "typ": "JWT"}).encode())
    p = b(json.dumps({**claims, "exp": int(time.time()) + 600}).encode())
    return f"{h}.{p}.{b(hmac.new(SECRET, f'{h}.{p}'.encode(), hashlib.sha256).digest())}"


def c4():
    req = urllib.request.Request(API + "/resultados_boss?limit=50")
    req.add_header("Authorization", "Bearer " + _jwt({"role": "paciente", "patient_id": "39"}))
    try:
        with urllib.request.urlopen(req) as r:
            filas = json.loads(r.read())
    except urllib.error.HTTPError as e:
        return False, f"HTTP {e.code}"
    ajenas = [f for f in filas if f["patient_id"] != 39]
    return bool(filas) and not ajenas, f"{len(filas)} filas devueltas, {len(ajenas)} de otros pacientes"


def c5():
    conn = psycopg.connect(**config.POSTGRES, autocommit=True)
    flujo.entregar(conn, "res-900", 2, "GLU 112 (corregido)")
    flujo.entregar(conn, "res-900", 1, "GLU 110 (original, llega tarde)")
    filas = admin.execute("SELECT version FROM staging.b5_destination WHERE message_id = 'res-900'").fetchall()
    conn.close()
    return [v[0] for v in filas] == [2], f"versiones en el destino: {[v[0] for v in filas]}"


criterio(1, "la exportación no pierde la fila que confirma tarde", c1)
criterio(2, "un mensaje repetido no se aplica dos veces", c2)
criterio(3, "la notificación sale dentro de las doce horas", c3)
criterio(4, "la API no muestra informes ajenos", c4)
criterio(5, "una corrección vieja no pisa a la nueva", c5)
pasan = sum(resultados.values())
print(f"\n{pasan} de 5 criterios pasan.")
sys.exit(0 if pasan == 5 else 1)
