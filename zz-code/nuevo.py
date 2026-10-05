#!/usr/bin/env python3
"""Crea el directorio de trabajo de una sesión en zz-code/.

Uso, desde cualquier sitio:
    python3 zz-code/nuevo.py <curso> [--tanda T3] [--proposito "prototipo del outbox"]

Crea `zz-code/<curso>-<AAAAMMDD>-<hash>/` con su MANIFIESTO.md y escribe la ruta en la salida, para
pegarla en la bitácora del plan de producción. Nunca reutiliza ni toca un directorio existente.
Solo biblioteca estándar.
"""

import argparse
import datetime
import os
import re
import secrets
import sys

RAIZ = os.path.dirname(os.path.abspath(__file__))

MANIFIESTO = """# {ident}

- **Curso:** {curso}
- **Tanda:** {tanda}
- **Creado:** {fecha}
- **Propósito:** {proposito}
- **Estado:** vigente
- **Cómo regenerar lo que limpiar.py borra:** {{{{p. ej. `npm ci`, `mvn -q package`, `python3 -m venv .venv && .venv/bin/pip install -r requirements.txt`}}}}

## Qué hay

{{{{Una línea por subdirectorio o archivo que importe.}}}}

## Qué sirvió

{{{{Lo que se extrajo al curso, a su laboratorio o a zz-instrucciones/herramientas/, con su destino.}}}}
"""


def main():
    p = argparse.ArgumentParser(description="Crea zz-code/<curso>-<AAAAMMDD>-<hash>/ con su manifiesto.")
    p.add_argument("curso", help="slug del curso, p. ej. 05-event-driven o lab-docker-kubernetes")
    p.add_argument("--tanda", default="—")
    p.add_argument("--proposito", default="{{qué se va a probar}}")
    p.add_argument("--raiz", default=RAIZ, help="otra raíz (solo para pruebas)")
    a = p.parse_args()

    if not re.fullmatch(r"[a-z0-9][a-z0-9-]*", a.curso):
        sys.exit("El curso va en minúsculas, números y guiones, p. ej. 05-event-driven.")
    fecha = datetime.date.today()
    for _ in range(10):
        ident = f"{a.curso}-{fecha:%Y%m%d}-{secrets.token_hex(2)}"
        ruta = os.path.join(a.raiz, ident)
        if not os.path.exists(ruta):
            break
    else:
        sys.exit("No se encontró un identificador libre; vuelve a intentarlo.")
    os.makedirs(ruta)
    with open(os.path.join(ruta, "MANIFIESTO.md"), "w", encoding="utf-8") as f:
        f.write(MANIFIESTO.format(ident=ident, curso=a.curso, tanda=a.tanda,
                                  fecha=fecha.isoformat(), proposito=a.proposito))
    print(ruta)


if __name__ == "__main__":
    main()
