#!/usr/bin/env python3
"""Verificador de la Ruta NoSQL Lite (guía de estilo §18.4).

Hereda las validaciones base de `verificador_base.py` (copia sin cambios de la base de los
lineamientos de producción del repositorio: enlaces y anclas —con el U+FE0F que GitHub conserva—,
enlaces que salen del curso, restos de plantilla, codificación rota, emoji en ###, callouts y
encabezado), con el perfil `courses-ia`, y agrega las de este curso.

Uso, desde la raíz del curso:
    python3 prompts/verificar-corpus.py                  # todo el curso
    python3 prompts/verificar-corpus.py --publicacion    # además, lo que exige el repositorio público

Validaciones propias de este curso, además de las base:
  ERROR EJERCICIOS   fase con otro número de ejercicios que su fila de la propuesta §9
  ERROR NUMERACION   ejercicios que no van 1, 2, 3… sin saltos
  aviso PALABRAS     cuerpo fuera de su banda de palabras (guía §15: 4.000–5.000; F00 y F02,
                     2.000–3.000; F01, 3.000–4.000), contado hasta el encabezado de 🧪
  aviso DIAGRAMA     bloque `text` con forma de diagrama de cajas o de flechas; va en Mermaid (D-12),
                     salvo que sea salida, árbol de claves o de archivos, o ficha de cierre
  con --publicacion, además: enlaces a `prompts/` (PROMPTS) y menciones a material privado
  (ZZ-CODE, PRIVADO), los errores del perfil de publicación de la etapa E9.

Lo que no ve y se revisa a mano: que las cifras citadas coincidan con `bitacora-de-medicion.md`,
que el catálogo `a09` tenga el mensaje literal, y que cada bloque `mermaid` dibuje (con `mmdc`).
"""

import os
import re
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from verificador_base import FENCE_RE, PerfilCoursesIA, PerfilPublicacion, leer, main  # noqa: E402

RAIZ = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
PROPUESTA = os.path.join(RAIZ, "prompts", "propuesta-fases-y-alcance.md")

# Fila del resumen de la propuesta §9: | 03 | Documental: levantar y modelar | I | 10 | 26 |
FILA_RE = re.compile(r"^\| (\d{2}) \| [^|]+\| [^|]+\| (\d+) \| (\d+) \|\s*$")
EJERCICIO_RE = re.compile(r"^#{3,4} (🟢|🟡|🟠|🔴) Ejercicio (\d+)\b")
DIAGRAMA_RE = re.compile(r"[┌┐└┘▼▲►◄]")


def bloques_de_codigo(texto):
    """[(número de la línea de apertura, lenguaje, [líneas])] de los bloques cercados."""
    salida, abierto, lenguaje, inicio, cuerpo = [], None, "", 0, []
    for n, linea in enumerate(texto.split("\n"), 1):
        m = FENCE_RE.match(linea)
        if m and abierto is None:
            abierto, lenguaje, inicio, cuerpo = m.group(1), linea.strip()[len(m.group(1)):].strip(), n, []
            continue
        if m and abierto and m.group(1)[0] == abierto[0] and linea.strip() == m.group(1):
            salida.append((inicio, lenguaje, cuerpo))
            abierto = None
            continue
        if abierto:
            cuerpo.append(linea)
    return salida


class VerificadorDelCurso(PerfilCoursesIA):
    # Fases NN-…; la historia (00-historia-de-condor.md) no es una fase.
    NO_CAPITULO = PerfilCoursesIA.NO_CAPITULO + ("historia",)
    # Callouts de la guía §7.3 y marcadores de §7.2, más 🏆 (boss global) y 📍 (dónde empezar,
    # en el README).
    CALLOUTS = PerfilCoursesIA.CALLOUTS | {"💥", "🏆", "📍", "💀", "⭐"}
    # En ###: la escala de dificultad y los marcadores de la guía §7.2. La historia, que es
    # narrativa y no una fase, lleva un emoji por subsección de su cronología (guía §18.2).
    EMOJI_PERMITIDOS_H3 = PerfilCoursesIA.EMOJI_PERMITIDOS_H3 | {"🧰", "🕊", "️"}

    def __init__(self, raiz):
        super().__init__(raiz)
        self.fichas = {}
        if os.path.exists(PROPUESTA):
            for linea in leer(PROPUESTA).split("\n"):
                m = FILA_RE.match(linea)
                if m:
                    self.fichas[m.group(1)] = (int(m.group(2)), int(m.group(3)))

    def verificar_capitulo_extra(self, ruta, lineas, texto, preguntas):
        nombre = os.path.basename(ruta)
        clave = nombre[:2]
        rel = self.rel(ruta)
        numeros = [int(m.group(2)) for _, l in lineas for m in [EJERCICIO_RE.match(l)] if m]
        ficha = self.fichas.get(clave)
        if ficha is None:
            self.error("EJERCICIOS", f"{rel}: la fase no está en el resumen de la propuesta §9")
        elif len(numeros) != ficha[1]:
            self.error("EJERCICIOS", f"{rel}: {len(numeros)} ejercicios; la propuesta §9 dice {ficha[1]}")
        if numeros != list(range(1, len(numeros) + 1)):
            self.error("NUMERACION", f"{rel}: los ejercicios no van de 1 a {len(numeros)} sin saltos")
        cuerpo = re.split(r"^## 🧪", texto, maxsplit=1, flags=re.M)[0]
        palabras = len(cuerpo.split())
        banda = {"00": (2000, 3000), "02": (2000, 3000), "01": (3000, 4000)}.get(clave, (4000, 5000))
        if not banda[0] <= palabras <= banda[1]:
            self.aviso("PALABRAS", f"{rel}: {palabras} palabras de cuerpo (banda {banda[0]}–{banda[1]})")

    def verificar_documento_extra(self, ruta, lineas, texto):
        for inicio, lenguaje, cuerpo in bloques_de_codigo(texto):
            if lenguaje != "text":
                continue
            if sum(1 for l in cuerpo if DIAGRAMA_RE.search(l)) >= 2:
                self.aviso("DIAGRAMA", f"{self.rel(ruta)}:{inicio}: bloque text con forma de diagrama; va en"
                                       " Mermaid (D-12), salvo que sea salida, árbol o ficha de cierre")


class VerificadorDePublicacion(VerificadorDelCurso):
    """Etapa E9: lo del curso, más lo que el repositorio público exige (sin `prompts/`)."""
    PROHIBIR_ENLACES_A_PROMPTS = True
    PROHIBIDOS_EN_PUBLICADOS = PerfilPublicacion.PROHIBIDOS_EN_PUBLICADOS


if __name__ == "__main__":
    clase = VerificadorDelCurso
    if "--publicacion" in sys.argv:
        sys.argv.remove("--publicacion")
        clase = VerificadorDePublicacion
    sys.exit(main(clase, RAIZ))
