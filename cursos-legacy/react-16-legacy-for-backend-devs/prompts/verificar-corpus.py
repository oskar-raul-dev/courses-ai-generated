#!/usr/bin/env python3
"""Verificador del curso React 16 Legacy — Rifas y chances (guía de estilo §17.3).

Hereda las validaciones base de `verificador_base.py` (enlaces, anclas, restos de plantilla,
codificación, emoji en ###, callouts, encabezado de fase) con el perfil del repositorio, y agrega
las de este curso.

Uso, desde la raíz del curso:
    python3 prompts/verificar-corpus.py                  # todo el curso
    python3 prompts/verificar-corpus.py --publicacion    # además, lo que exige la etapa E9

Validaciones propias de este curso, además de las base:
  aviso DIAGRAMA     un bloque sin lenguaje o `text` con forma de diagrama; va en Mermaid (D-12)
  con --publicacion, los errores PROMPTS, ZZ-CODE y PRIVADO del perfil de publicación, y además
  ERROR CITA-PROMPTS un documento publicado que nombra un archivo de `prompts/` en la prosa o en el
                     código: en el repositorio público no existiría (guía §17.4)
"""

import os
import re
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from verificador_base import FENCE_RE, PerfilCoursesIA, PerfilPublicacion, main  # noqa: E402

RAIZ = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))

# Un diagrama de flujo, de estados o de cajas: esquinas de caja o puntas de flecha que unen pasos.
# Los árboles de archivos (`├──`), las anatomías de un token o de un hash (`└── sal ─┴──`), las
# correspondencias `a → b` y los registros de acciones de DevTools no llevan ninguna en dos líneas, y
# se quedan como texto (guía §17.1).
DIAGRAMA_RE = re.compile(r"[┌┐┘▼▲►↓]")
CITA_PROMPTS_RE = re.compile(r"prompts/[\w.-]+\.md")


class VerificadorDelCurso(PerfilCoursesIA):
    # Marcadores (guía §7.1), callouts (guía §7.2) y los del CLAUDE.md que el curso usa en silencio
    # (🧭, 🧠, 🩻, 🧪). 📓 señala, desde una fase, los incidentes que produce (guía §17.2).
    CALLOUTS = PerfilCoursesIA.CALLOUTS | {"💸", "🔥", "⭐", "🏷️", "📝", "📚", "🪦", "⚠️", "💡",
                                           "🧭", "🧠", "🩻", "🧪", "📓", "📓🔥"}
    # Dos callouts de un solo uso, heredados del curso ya publicado: se toleran y no se multiplican
    # (guía §17.2).
    CALLOUTS_HEREDADOS = {"🔑", "🚀"}
    CALLOUTS = CALLOUTS | CALLOUTS_HEREDADOS
    # Emoji en ### (guía §3): los emoji-tipo de §7, la estructura fija de cada incidente
    # (🎫 🎯 🔧 📝) y los títulos de era y de plataforma que ya existen. El verificador compara
    # carácter por carácter, así que van también sin el U+FE0F.
    EMOJI_H3 = {"💸", "🎫", "🎯", "🔧", "📝", "🩻", "🪦", "💻", "🚨", "🪟", "🐧", "🍎", "🏷️",
                "✅", "🪨", "🧱", "🌀", "❌"}
    EMOJI_PERMITIDOS_H3 = (PerfilCoursesIA.EMOJI_PERMITIDOS_H3 | CALLOUTS | EMOJI_H3
                           | {c.replace("️", "") for c in CALLOUTS | EMOJI_H3})
    # El encabezado de fase (guía §8): «Tutorial React 16 — Rifas y chances · Fase N de 11 · N horas».
    # El curso no fecha sus fases: las versiones viven congeladas en decisiones-y-versiones.md.
    CAMPOS_ENCABEZADO = ("Tutorial React 16", "horas")
    # 00-alcance, 00-convencion, 00-decisiones y 00-historia llevan número pero son encuadre o
    # consulta, no fases.
    NO_CAPITULO = PerfilCoursesIA.NO_CAPITULO + ("alcance", "convencion", "decisiones", "historia")

    def verificar_documento_extra(self, ruta, lineas, texto):
        # `lineas` llega sin los bloques de código: los diagramas se buscan en el texto crudo.
        # bloque: None fuera de código; una lista dentro de un bloque sin lenguaje o `text`; False
        # dentro de un bloque con lenguaje, que se salta entero.
        bloque, inicio = None, 0
        for n, linea in enumerate(texto.splitlines(), 1):
            m = FENCE_RE.match(linea)
            if bloque is None:
                if m:
                    lenguaje = linea.strip()[len(m.group(1)):].strip()
                    bloque, inicio = ([] if lenguaje in ("", "text") else False), n
            elif m and linea.strip() == m.group(1):
                if bloque and sum(1 for l in bloque if DIAGRAMA_RE.search(l)) >= 2:
                    self.aviso("DIAGRAMA", f"{self.rel(ruta)}:{inicio}: bloque de texto con forma de"
                                           " diagrama; va en Mermaid (D-12)")
                bloque = None
            elif bloque is not False:
                bloque.append(linea)


class VerificadorDePublicacion(VerificadorDelCurso):
    """Etapa E9: lo del curso, más lo que el repositorio público exige (sin `prompts/`)."""
    PROHIBIR_ENLACES_A_PROMPTS = True
    PROHIBIDOS_EN_PUBLICADOS = PerfilPublicacion.PROHIBIDOS_EN_PUBLICADOS

    def verificar_documento_extra(self, ruta, lineas, texto):
        super().verificar_documento_extra(ruta, lineas, texto)
        for n, linea in enumerate(texto.splitlines(), 1):
            for cita in sorted(set(CITA_PROMPTS_RE.findall(linea))):
                self.error("CITA-PROMPTS", f"{self.rel(ruta)}:{n} → nombra {cita}")


if __name__ == "__main__":
    clase = VerificadorDelCurso
    if "--publicacion" in sys.argv:
        sys.argv.remove("--publicacion")
        clase = VerificadorDePublicacion
    sys.exit(main(clase, RAIZ))
