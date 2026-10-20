#!/usr/bin/env python3
"""Verificador del curso Angular 16 legacy para backend devs (guía de estilo §16).

Hereda las validaciones base de `verificador_base.py` con el perfil `PerfilCoursesIA` (enlaces,
anclas, restos de plantilla, emoji en ###, callouts, sincronía con el solucionario) y agrega las
excepciones que la guía declara en su §16: emoji en ### de marcadores y secciones, callouts propios,
encabezado sin fecha de vigencia y el aviso DIAGRAMA para bloques `text` con forma de diagrama.

Uso, desde la raíz del curso:
    python3 prompts/verificar-corpus.py

Qué esperar: un único `ERROR FUERA` (el puente a angular-8, §16) y ningún otro error.
"""

import os
import re
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from verificador_base import PerfilCoursesIA, main  # noqa: E402

RAIZ = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))

# Un diagrama de flujo o de cajas: esquinas de caja, o flechas verticales que unen pasos. Los árboles
# de archivos y las correspondencias `a → b` no llevan ninguna, y se quedan en `text` (§16).
DIAGRAMA_RE = re.compile(r"[┌┐┘▼↓]")


class VerificadorDelCurso(PerfilCoursesIA):
    # Callouts: los de la guía §7.2, los de §7.1 que usa el curso y los dos propios de §16.
    CALLOUTS = PerfilCoursesIA.CALLOUTS | {"🔑", "🧬"}

    # Emoji en ### (guía §7.1, §7.3 y §16): marcadores, secciones de la plantilla de incidente (formato
    # §3) y títulos de era de la historia. El verificador compara carácter por carácter, así que van
    # también sin el selector U+FE0F.
    EMOJI_H3 = {
        "🎫", "🎯", "🔧", "📝",                                   # plantilla de incidente
        "⭐", "💸", "🧬", "🪦", "🩻", "⚠️",                         # marcadores de §7.1 y §7.3
        "🛗", "📜", "🗂️", "🌎", "🏝️", "🗄️", "🪨", "🏢", "🧱", "🔀", "🧊", "📓",  # títulos de era
    }
    EMOJI_PERMITIDOS_H3 = (PerfilCoursesIA.EMOJI_PERMITIDOS_H3 | CALLOUTS | EMOJI_H3
                           | {c.replace("️", "") for c in CALLOUTS | EMOJI_H3})

    # Ningún encabezado de fase lleva fecha de vigencia: la guía no la pide (§16).
    CAMPOS_ENCABEZADO = ()

    def verificar_documento_extra(self, ruta, lineas, texto):
        # `lineas` llega sin los bloques de código: los diagramas se buscan en el texto crudo.
        bloque, inicio = None, 0
        for n, linea in enumerate(texto.splitlines(), 1):
            if bloque is None and linea.strip() == "```text":
                bloque, inicio = [], n
            elif bloque is not None and linea.strip() == "```":
                if sum(1 for l in bloque if DIAGRAMA_RE.search(l)) >= 2:
                    self.aviso("DIAGRAMA", f"{self.rel(ruta)}:{inicio}: bloque text con forma de diagrama;"
                                           " va en Mermaid (§16)")
                bloque = None
            elif bloque is not None:
                bloque.append(linea)


if __name__ == "__main__":
    sys.exit(main(VerificadorDelCurso, RAIZ))
