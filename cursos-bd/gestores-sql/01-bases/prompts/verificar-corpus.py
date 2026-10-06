#!/usr/bin/env python3
"""Verificador del curso El motor de motores (guía de estilo §18.3).

Hereda las validaciones base de `verificador_base.py` (copia sin cambios de la base de los
lineamientos de producción: enlaces, anclas con U+FE0F, enlaces que salen del curso, restos de
plantilla, codificación rota, emoji en ###, callouts, encabezado de fase), con el perfil del
repositorio, y agrega las de este curso.

Uso, desde la raíz del curso:
    python3 prompts/verificar-corpus.py                  # todo el curso
    python3 prompts/verificar-corpus.py soluciones       # solo una carpeta
    python3 prompts/verificar-corpus.py --publicacion    # además, lo que exige el repositorio público

Validaciones propias de este curso, además de las base:
  ERROR SECCION      fase sin una sección de su plantilla (guía §8; panorama, A.C. y caso de estudio)
  ERROR EJERCICIOS   fase con otro número de ejercicios que su fila de la propuesta §13
  ERROR NUMERACION   ejercicios que no van 1, 2, 3… sin saltos
  ERROR SOLUCIONARIO falta `soluciones/<misma-fase>.md`, o tiene otro número de `### Ejercicio N`
  ERROR LATEX        LaTeX en la prosa (`$…$`, `\\(`) o un bloque ```math (guía §3.1)
  ERROR IDENT        `grade` solo, `foo`, `bar` o `tabla1` dentro de un bloque de código (guía §5)
  ERROR RADB         un bloque de `radb` (primera línea `// radb`) con una línea que empieza por `--`
  aviso PALABRAS     cuerpo fuera de la banda de palabras de sus horas (guía §8)
  aviso ENLACE-SOL   ejercicio sin enlace a `soluciones/<fase>.md#ejercicio-N` (guía §9)
  aviso ANCHO-TEXT   línea de un bloque `text` de más de 75 columnas (guía §3.2)
  aviso DIAGRAMA     bloque `text` con forma de diagrama de cajas; va en Mermaid (D-12)
  con --publicacion, los errores PROMPTS, ZZ-CODE y PRIVADO del perfil de publicación

El dibujo de los bloques `mermaid` lo comprueba `verificar-diagramas.py`, que necesita `mmdc`.
"""

import os
import re
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from verificador_base import FENCE_RE, PerfilCoursesIA, PerfilPublicacion, leer, main, sin_inline  # noqa: E402

RAIZ = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
PROPUESTA = os.path.join(RAIZ, "prompts", "propuesta-fases-y-alcance.md")

# Fila del resumen de la propuesta §13: | 07 | Álgebra II… | II | 14 | 45 |  o  | AC03 | … | A.C. | 10 | 30 |
FILA_RE = re.compile(r"^\| (AC\d{2}|\d{2}) \| [^|]+\| [^|]+\| (\d+) \| (\d+) \|\s*$")
EJERCICIO_RE = re.compile(r"^### (🟢|🟡|🟠|🔴) Ejercicio (\d+)\b")
SOLUCION_RE = re.compile(r"^### Ejercicio (\d+)\b")
LATEX_RE = re.compile(r"\$[^$\s][^$]*\$|\\\(")
IDENT_RE = re.compile(r"\b(grade|foo|bar|tabla1)\b")
DIAGRAMA_RE = re.compile(r"[┌┐└┘▼▲]")

COMUNES = ("Dónde estamos", "Objetivos de esta fase", "Qué NO entra todavía",
           "Errores conceptuales comunes", "Traducción de notación y vocabulario",
           "Hasta dónde llega la teoría", "Resumen", "Ejercicios", "Bibliografía y recursos", "Cierre")


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
    # Fases del camino base (NN-) y del bloque A.C. (acNN-); los apéndices (aNN-, aca-NN-) no lo son.
    CAPITULO_RE = re.compile(r"^(?:ac)?(\d{2})-.*\.md$")
    NO_CAPITULO = PerfilCoursesIA.NO_CAPITULO + ("estructura",)
    # Ninguna fase cita prompts/ ni un desechable (guía §13).
    PROHIBIR_ENLACES_A_PROMPTS = True
    # Callouts de la guía §7.3, más los marcadores en blockquote de §7.2.
    CALLOUTS = {"📏", "📐", "✍️", "🔎", "🧮", "🪞", "🩻", "📖", "🧠", "⚠️", "📝", "💡", "📚",
                "⚖️", "🏛️", "🧭", "🚧"}
    # En ###: la escala de dificultad y los tipos de ejercicio (guía §9), con y sin U+FE0F.
    TIPOS = {"✍️", "🔎", "🧮", "🧩", "📖", "🧵"}
    EMOJI_PERMITIDOS_H3 = (PerfilCoursesIA.EMOJI_PERMITIDOS_H3 | TIPOS
                           | {c.replace("️", "") for c in TIPOS})
    # El encabezado de fase (guía §7.1).
    CAMPOS_ENCABEZADO = ("**Curso:**", "**Fecha de verificación", "**Objetivo")

    def __init__(self, raiz):
        super().__init__(raiz)
        self.fichas = {}
        if os.path.exists(PROPUESTA):
            for linea in leer(PROPUESTA).split("\n"):
                m = FILA_RE.match(linea)
                if m:
                    self.fichas[m.group(1).lower()] = (int(m.group(2)), int(m.group(3)))

    # --- secciones de la plantilla que corresponde (plantillas de capítulo 1 a 4)
    def secciones_de(self, clave):
        if clave in ("00", "37"):
            return COMUNES + ("De la teoría a los motores",)
        if clave in ("ac06", "ac07", "ac08"):
            return COMUNES + ("El caso", "De entonces a ahora")
        if clave.startswith("ac"):
            return COMUNES + ("Teoría", "De entonces a ahora")
        return COMUNES + ("Teoría", "De la teoría a los motores")

    def verificar_capitulo(self, ruta, lineas, texto, solucionario):
        nombre = os.path.basename(ruta)
        self.clave = nombre.split("-")[0]
        self.SECCIONES_OBLIGATORIAS = self.secciones_de(self.clave)
        super().verificar_capitulo(ruta, lineas, texto, solucionario)

    def verificar_capitulo_extra(self, ruta, lineas, texto, preguntas):
        nombre = os.path.basename(ruta)
        rel = self.rel(ruta)
        numeros = [int(m.group(2)) for _, l in lineas for m in [EJERCICIO_RE.match(l)] if m]
        ficha = self.fichas.get(self.clave)
        if ficha is None:
            self.error("EJERCICIOS", f"{rel}: la fase no está en el resumen de la propuesta §13")
        elif len(numeros) != ficha[1]:
            self.error("EJERCICIOS", f"{rel}: {len(numeros)} ejercicios; la propuesta §13 dice {ficha[1]}")
        if numeros != list(range(1, len(numeros) + 1)):
            self.error("NUMERACION", f"{rel}: los ejercicios no van de 1 a {len(numeros)} sin saltos")
        # enlace de cada ejercicio a su solución
        objetivo = f"soluciones/{nombre}#ejercicio-"
        for n in numeros:
            if f"{objetivo}{n})" not in texto:
                self.aviso("ENLACE-SOL", f"{rel}: el ejercicio {n} no enlaza {objetivo}{n}")
        # el solucionario, con el mismo número de ejercicios
        sol = os.path.join(self.raiz, "soluciones", nombre)
        if not os.path.exists(sol):
            self.error("SOLUCIONARIO", f"{rel}: falta soluciones/{nombre}")
        else:
            resueltos = [int(m.group(1)) for l in leer(sol).split("\n") for m in [SOLUCION_RE.match(l)] if m]
            if sorted(resueltos) != sorted(numeros):
                self.error("SOLUCIONARIO", f"soluciones/{nombre}: {len(resueltos)} soluciones para "
                                           f"{len(numeros)} ejercicios, o con otra numeración")
        # la banda de palabras del cuerpo, cortando por el encabezado de 🧪 (guía §8)
        if ficha:
            cuerpo = re.split(r"^## 🧪", texto, maxsplit=1, flags=re.M)[0]
            palabras = len(cuerpo.split())
            banda = self.banda(self.clave, ficha[0])
            if not banda[0] <= palabras <= banda[1]:
                self.aviso("PALABRAS", f"{rel}: {palabras} palabras de cuerpo (banda {banda[0]}–{banda[1]})")

    @staticmethod
    def banda(clave, horas):
        if clave in ("00", "37", "ac00"):
            return (2000, 3000)
        if clave.startswith("ac") or horas <= 8:
            return (3000, 4500)
        if horas <= 12:
            return (4500, 6500)
        return (5500, 7500)

    # --- todo documento publicado
    def verificar_documento_extra(self, ruta, lineas, texto):
        rel = self.rel(ruta)
        for n, linea in lineas:
            if LATEX_RE.search(sin_inline(linea)):
                self.error("LATEX", f"{rel}:{n} → {linea.strip()[:70]}")
        for inicio, lenguaje, cuerpo in bloques_de_codigo(texto):
            if lenguaje == "math":
                self.error("LATEX", f"{rel}:{inicio}: bloque math")
            if lenguaje == "mermaid":
                continue
            for k, linea in enumerate(cuerpo, inicio + 1):
                if IDENT_RE.search(linea):
                    self.error("IDENT", f"{rel}:{k} → {linea.strip()[:70]}")
            if lenguaje != "text":
                continue
            for k, linea in enumerate(cuerpo, inicio + 1):
                if len(linea) > 75:
                    self.aviso("ANCHO-TEXT", f"{rel}:{k} ({len(linea)} columnas)")
            primera = next((l.strip() for l in cuerpo if l.strip()), "")
            if primera.startswith("// radb"):
                for k, linea in enumerate(cuerpo, inicio + 1):
                    if linea.lstrip().startswith("--"):
                        self.error("RADB", f"{rel}:{k}: `--` no es comentario en radb; va `//` (H4)")
            if sum(1 for l in cuerpo if DIAGRAMA_RE.search(l)) >= 2:
                self.aviso("DIAGRAMA", f"{rel}:{inicio}: bloque text con forma de diagrama; va en Mermaid"
                                       " (D-12), salvo que sea salida literal de una herramienta")


class VerificadorDePublicacion(VerificadorDelCurso):
    """Etapa E9: lo del curso, más lo que el repositorio público exige (sin `prompts/`)."""
    PROHIBIDOS_EN_PUBLICADOS = PerfilPublicacion.PROHIBIDOS_EN_PUBLICADOS


if __name__ == "__main__":
    clase = VerificadorDelCurso
    if "--publicacion" in sys.argv:
        sys.argv.remove("--publicacion")
        clase = VerificadorDePublicacion
    sys.exit(main(clase, RAIZ))
