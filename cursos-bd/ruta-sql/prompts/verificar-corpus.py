#!/usr/bin/env python3
"""Verificador de la Ruta SQL (guía de estilo §19.4).

Hereda las validaciones base de `verificador_base.py` (copia sin cambios de la base de los
lineamientos de producción del repositorio: enlaces y anclas —con el U+FE0F que GitHub conserva—,
enlaces que salen del curso, restos de plantilla, codificación rota, emoji en ###, callouts y
encabezado), con el perfil `courses-ia`, y agrega las de este curso.

Uso, desde la raíz del curso:
    python3 prompts/verificar-corpus.py                  # todo el curso
    python3 prompts/verificar-corpus.py --publicacion    # además, lo que exige el repositorio público

Validaciones propias de este curso, además de las base:
  ERROR EJERCICIOS   fase (NN- o ssNN-) con otro número de ejercicios que su fila de la propuesta
                     (§11 para el camino base, §10 para el track)
  ERROR NUMERACION   ejercicios que no van 1, 2, 3… sin saltos
  ERROR SOLUCIONARIO documento con ejercicios (fase, apéndice o track) sin `soluciones/<mismo-nombre>.md`,
                     o con otros números de `### Ejercicio N` que los del documento (guía §10.3, D18)
  aviso ENLACE-SOL   ejercicio sin enlace a `soluciones/<documento>.md#ejercicio-N`
  aviso PALABRAS     cuerpo fuera de la banda de palabras de sus horas (guía §9), contado hasta el
                     encabezado de 🧪
  aviso DIAGRAMA     bloque `text` con forma de diagrama de cajas; va en Mermaid (D-12), salvo que
                     sean sesiones intercaladas, salida, plan, árbol o ficha de cierre
  aviso README       `README.md` o `0-ESTRUCTURA-CURSO.md` en la raíz antes de T15 (plan, regla 3);
                     se apaga cambiando ESCRITOS_LOS_README a True al abrir T15
  con --publicacion, además: enlaces a `prompts/` (PROMPTS) y menciones a material privado
  (ZZ-CODE, PRIVADO), los errores del perfil de publicación de la etapa E9.

Lo que no ve y se revisa a mano: que ningún número de Oracle ni de SQL Server entre en lo publicado
(plan §4), que las cifras coincidan con la bitácora y que cada bloque `mermaid` dibuje (con `mmdc`).
"""

import os
import re
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from verificador_base import FENCE_RE, PerfilCoursesIA, PerfilPublicacion, leer, main  # noqa: E402

RAIZ = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
PROPUESTA = os.path.join(RAIZ, "prompts", "propuesta-fases-y-alcance.md")
ESCRITOS_LOS_README = False          # True desde T15

# Resumen §11: | 03 | `03-lo-que-sql-le-hace-al-modelo.md` | I | 8 | 22 |
FILA_BASE_RE = re.compile(r"^\| (\d{2}) \| `[^`]+` \| [^|]+\| (\d+) \| (\d+) \|\s*$")
# Track §10: | ss01 | La base en su motor original | 8 | 20 | … |
FILA_TRACK_RE = re.compile(r"^\| (ss\d{2}) \| [^|]+\| (\d+) \| (\d+) \|")
EJERCICIO_RE = re.compile(r"^#{3,4} (🟢|🟡|🟠|🔴) Ejercicio (\d+)\b")
DIAGRAMA_RE = re.compile(r"[┌┐└┘▼▲►◄]")
SOLUCION_RE = re.compile(r"^### Ejercicio (\d+)\b")
DIR_SOLUCIONES = "soluciones"
# Guía §9: palabras de cuerpo por horas
BANDAS = {3: (2000, 3000), 4: (2000, 3000), 5: (3000, 4000), 8: (3500, 4500), 10: (4000, 5000),
          12: (4000, 5000), 15: (5000, 6500)}


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
    # Fases del camino base (NN-) y del track (ssNN-); la historia no es una fase.
    CAPITULO_RE = re.compile(r"^(?:ss)?(\d{2})-.*\.md$")
    NO_CAPITULO = PerfilCoursesIA.NO_CAPITULO + ("historia", "estructura")
    # Callouts y marcadores de la guía §8: 🔒 y 🪞🔒 (lo no publicable de Oracle y SQL Server), 🏚️
    # (la caja), 💀 y 🏆 (los boss).
    CALLOUTS = PerfilCoursesIA.CALLOUTS | {"💥", "🏆", "💀", "🔒", "🪞🔒", "⭐", "🏚️", "🏚"}

    def es_capitulo(self, ruta):
        # soluciones/NN-slug.md lleva el nombre de su fase, pero no es una fase.
        if DIR_SOLUCIONES in self.rel(ruta).split(os.sep):
            return False
        return super().es_capitulo(ruta)

    def __init__(self, raiz):
        super().__init__(raiz)
        self.fichas = {}
        if os.path.exists(PROPUESTA):
            for linea in leer(PROPUESTA).split("\n"):
                m = FILA_BASE_RE.match(linea) or FILA_TRACK_RE.match(linea)
                if m:
                    self.fichas[m.group(1)] = (int(m.group(2)), int(m.group(3)))

    def verificar_capitulo_extra(self, ruta, lineas, texto, preguntas):
        nombre = os.path.basename(ruta)
        clave = nombre.split("-")[0]
        rel = self.rel(ruta)
        numeros = [int(m.group(2)) for _, l in lineas for m in [EJERCICIO_RE.match(l)] if m]
        ficha = self.fichas.get(clave)
        if ficha is None:
            self.error("EJERCICIOS", f"{rel}: la fase no está en el resumen de la propuesta")
            return
        if len(numeros) != ficha[1]:
            self.error("EJERCICIOS", f"{rel}: {len(numeros)} ejercicios; la propuesta dice {ficha[1]}")
        if numeros != list(range(1, len(numeros) + 1)):
            self.error("NUMERACION", f"{rel}: los ejercicios no van de 1 a {len(numeros)} sin saltos")
        banda = BANDAS.get(ficha[0])
        if banda:
            cuerpo = re.split(r"^## 🧪", texto, maxsplit=1, flags=re.M)[0]
            palabras = len(cuerpo.split())
            if not banda[0] <= palabras <= banda[1]:
                self.aviso("PALABRAS", f"{rel}: {palabras} palabras de cuerpo (banda {banda[0]}–{banda[1]})")

    def verificar_documento_extra(self, ruta, lineas, texto):
        self.verificar_solucionario(ruta, lineas, texto)
        for inicio, lenguaje, cuerpo in bloques_de_codigo(texto):
            if lenguaje == "text" and sum(1 for l in cuerpo if DIAGRAMA_RE.search(l)) >= 2:
                self.aviso("DIAGRAMA", f"{self.rel(ruta)}:{inicio}: bloque text con forma de diagrama; va en"
                                       " Mermaid (D-12), salvo sesiones intercaladas, salida, plan o árbol")

    def verificar_solucionario(self, ruta, lineas, texto):
        partes = self.rel(ruta).split(os.sep)
        if DIR_SOLUCIONES in partes or len(partes) != 1:      # solo documentos de la raíz del curso
            return
        nombre = os.path.basename(ruta)
        numeros = [int(m.group(2)) for _, l in lineas for m in [EJERCICIO_RE.match(l)] if m]
        if not numeros:
            return
        objetivo = f"{DIR_SOLUCIONES}/{nombre}#ejercicio-"
        for n in numeros:
            if f"{objetivo}{n})" not in texto:
                self.aviso("ENLACE-SOL", f"{nombre}: el ejercicio {n} no enlaza {objetivo}{n}")
        sol = os.path.join(self.raiz, DIR_SOLUCIONES, nombre)
        if not os.path.exists(sol):
            self.error("SOLUCIONARIO", f"{nombre}: falta {DIR_SOLUCIONES}/{nombre}")
            return
        resueltos = [int(m.group(1)) for l in leer(sol).split("\n") for m in [SOLUCION_RE.match(l)] if m]
        if resueltos != numeros:
            self.error("SOLUCIONARIO", f"{DIR_SOLUCIONES}/{nombre}: {len(resueltos)} soluciones para "
                                       f"{len(numeros)} ejercicios, o en otro orden o numeración")

    def verificar_corpus_extra(self):
        if ESCRITOS_LOS_README:
            return
        for nombre in ("README.md", "0-ESTRUCTURA-CURSO.md"):
            if os.path.exists(os.path.join(self.raiz, nombre)):
                self.aviso("README", f"{nombre} existe antes de T15 (plan, regla 3)")


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
