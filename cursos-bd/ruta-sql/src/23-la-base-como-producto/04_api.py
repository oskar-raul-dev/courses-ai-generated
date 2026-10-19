"""Fase 23 · la API de PostgREST con RLS, vista desde afuera: lo que ve cada token.

Los JWT se firman con HS256 usando solo la biblioteca estándar, con el secreto de laboratorio del compose
(`API_JWT_SECRET`, publicado a propósito: no es para producción). Pruebas:

  1. sin token                      → web_anon no tiene permisos: la API no muestra datos
  2. paciente 39                    → sus resultados
  3. paciente 39, protocolo ajeno   → lista vacía, sin error
  4. médico 144                     → los protocolos que derivó
  5. token con la firma adulterada  → rechazado
  6. latencia del portal del paciente: mediana de 20 pedidos

Uso (con `uv run lab up base api` y 01_setup.sql corrido):  uv run python 23-la-base-como-producto/04_api.py
"""

import base64
import hashlib
import hmac
import json
import os
import statistics
import time
import urllib.error
import urllib.request

BASE = f"http://127.0.0.1:{os.environ.get('API_PORT', '23000')}"
SECRET = os.environ.get("API_JWT_SECRET", "ruta-sql-laboratorio-secreto-jwt-de-prueba-2026").encode()


def b64(data: bytes) -> str:
    return base64.urlsafe_b64encode(data).rstrip(b"=").decode()


def token(claims: dict, secret: bytes = SECRET) -> str:
    header = b64(json.dumps({"alg": "HS256", "typ": "JWT"}).encode())
    body = b64(json.dumps({**claims, "exp": int(time.time()) + 600}).encode())
    firma = b64(hmac.new(secret, f"{header}.{body}".encode(), hashlib.sha256).digest())
    return f"{header}.{body}.{firma}"


def get(path: str, jwt: str | None = None) -> tuple[int, object]:
    req = urllib.request.Request(BASE + path)
    if jwt:
        req.add_header("Authorization", f"Bearer {jwt}")
    try:
        with urllib.request.urlopen(req) as r:
            return r.status, json.loads(r.read())
    except urllib.error.HTTPError as e:
        return e.code, json.loads(e.read() or b"{}")


def main() -> None:
    paciente = token({"role": "paciente", "patient_id": "39"})
    medico = token({"role": "medico", "physician_id": "144"})

    code, body = get("/resultados?limit=1")
    print(f"1 · sin token: HTTP {code} · {body.get('message') if isinstance(body, dict) else body}")

    code, body = get("/resultados", paciente)
    print(f"2 · paciente 39: HTTP {code} · {len(body)} resultados · protocolos distintos {len({r['lab_order_id'] for r in body})}")

    code, body = get("/protocolos?lab_order_id=eq.-2147402959", paciente)
    print(f"3 · paciente 39 pide el protocolo -2147402959 (del paciente 12594): HTTP {code} · {body}")

    code, body = get("/protocolos", medico)
    print(f"4 · médico 144: HTTP {code} · {len(body)} protocolos")

    adulterado = paciente[:-4] + ("AAAA" if not paciente.endswith("AAAA") else "BBBB")
    code, body = get("/resultados?limit=1", adulterado)
    print(f"5 · token adulterado: HTTP {code} · {body.get('message') if isinstance(body, dict) else body}")

    get("/resultados", paciente)  # calentamiento
    ms = []
    for _ in range(20):
        t0 = time.perf_counter()
        get("/resultados", paciente)
        ms.append((time.perf_counter() - t0) * 1000)
    print(f"6 · portal del paciente: mediana {statistics.median(ms):.1f} ms sobre 20 pedidos (426 resultados por pedido)")


if __name__ == "__main__":
    main()
