"""ss05 · §5.2 y §8. La API de Data API builder vista desde afuera: los mismos pedidos que la Fase 23 le hizo a PostgREST.

DAB corre con el proveedor `AppService`: la identidad llega en el encabezado `X-MS-CLIENT-PRINCIPAL`, un JSON en base64
que en Azure App Service escribe la plataforma después de autenticar al usuario. Aquí lo escribe este script, que es
exactamente lo que puede hacer cualquiera si DAB queda expuesto sin App Service delante (sección 8).

  1. sin identidad                         → el rol anónimo no tiene permisos
  2. paciente 39, sus resultados           → la seguridad por fila de SQL Server filtra por SESSION_CONTEXT
  3. paciente 39 pide un protocolo ajeno   → nada: una ausencia, no un error
  4. médico 144, lo que derivó
  5. identidad sin X-MS-API-ROLE           → el rol "authenticated", que no tiene permisos
  6. alguien escribe la identidad de otro  → DAB le cree

Las respuestas (códigos y conteos de filas) son del contrato de la API y de la caja, como en la Fase 23; los tiempos no
se miden aquí.

    uv run --extra sqlserver python ss05-data-api-builder-y-json/03_api.py      (desde src/, con lab up base sqlserver dab)
"""

import base64
import json
import os
import urllib.error
import urllib.request

BASE = f"http://{os.environ.get('DAB_HOST', '127.0.0.1')}:{os.environ.get('DAB_PORT', '25000')}/api"


def principal(roles: list[str], **claims) -> str:
    """El encabezado de EasyAuth: el tipo de autenticación, los claims y cuáles son el nombre y el rol."""
    doc = {"auth_typ": "aad", "name_typ": "name", "role_typ": "roles",
           "claims": [{"typ": "roles", "val": r} for r in roles] + [{"typ": k, "val": str(v)} for k, v in claims.items()]}
    return base64.b64encode(json.dumps(doc).encode()).decode()


def get(path: str, who: str | None = None, role: str | None = None) -> tuple[int, list | dict]:
    """GET con paginación: DAB devuelve de a páginas con nextLink; se siguen todas."""
    rows, url = [], f"{BASE}{path}"
    while url:
        req = urllib.request.Request(url)
        if who:
            req.add_header("X-MS-CLIENT-PRINCIPAL", who)
        if role:
            req.add_header("X-MS-API-ROLE", role)
        try:
            with urllib.request.urlopen(req) as resp:
                body = json.load(resp)
        except urllib.error.HTTPError as exc:
            return exc.code, json.loads(exc.read() or b"{}")
        rows += body.get("value", [])
        url = body.get("nextLink")
    return 200, rows


def main() -> None:
    paciente = principal(["paciente"], patient_id=39)
    medico = principal(["medico"], physician_id=144)

    code, body = get("/resultados")
    print(f"1 · sin identidad: HTTP {code} · {body.get('error', {}).get('message') if isinstance(body, dict) else body}")
    code, body = get("/resultados?$first=1000", paciente, "paciente")
    if not isinstance(body, list):
        raise SystemExit(f"2 · paciente 39: HTTP {code} · {body}")
    print(f"2 · paciente 39: HTTP {code} · {len(body)} resultados · protocolos distintos {len({r['lab_order_id'] for r in body})}")
    code, body = get("/protocolos/lab_order_id/-2147402959", paciente, "paciente")
    print(f"3 · paciente 39 pide el protocolo -2147402959 (del paciente 12594): HTTP {code} · "
          f"{body if isinstance(body, list) else body.get('error', {}).get('message')}")
    code, body = get("/protocolos?$first=1000", medico, "medico")
    print(f"4 · médico 144: HTTP {code} · {len(body)} protocolos")
    code, body = get("/resultados", paciente)
    print(f"5 · paciente 39 sin X-MS-API-ROLE: HTTP {code} · "
          f"{body.get('error', {}).get('message') if isinstance(body, dict) else len(body)}")
    otro = principal(["paciente"], patient_id=12594)
    code, body = get("/resultados?$first=1000", otro, "paciente")
    print(f"6 · cualquiera escribe la identidad del paciente 12594: HTTP {code} · "
          f"{f'{len(body)} resultados ajenos' if isinstance(body, list) else body.get('error', {}).get('message')}")


if __name__ == "__main__":
    main()
