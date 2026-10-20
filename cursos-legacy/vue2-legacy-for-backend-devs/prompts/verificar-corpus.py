#!/usr/bin/env python3
"""Verificador del paquete Tiquetera: Curso 01 (Vue 2 legacy) y Curso 02 (MongoDB/Express).

Guía de estilo §17.3. Hereda las validaciones base de `verificador_base.py` (enlaces, anclas, restos
de plantilla, codificación, emoji en ###, callouts, encabezado de fase, bandas de ejercicios) con el
perfil del repositorio, y agrega las de este paquete.

Uso, desde la raíz del paquete:
    python3 prompts/verificar-corpus.py                  # todo el paquete
    python3 prompts/verificar-corpus.py 01-vue2-legacy   # solo un curso
    python3 prompts/verificar-corpus.py --publicacion    # además, lo que exige la etapa E9

Validaciones propias de este paquete, además de las base:
  aviso DIAGRAMA     un bloque sin lenguaje o `text` con forma de diagrama; va en Mermaid (D4 a, §17.1)
  con --publicacion, los errores PROMPTS, ZZ-CODE y PRIVADO del perfil de publicación, y además
  ERROR CITA-PROMPTS un documento publicado que nombra un archivo de `prompts/` o un `_desechable-`
                     en la prosa o en el código: en el repositorio público no existiría (§17.4)
"""

import os
import re
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from verificador_base import FENCE_RE, PerfilCoursesIA, PerfilPublicacion, main  # noqa: E402

RAIZ = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))

# Un diagrama de flujo, de estados o de cajas (guía §17.1). Los árboles de archivos, las salidas de
# terminal y las correspondencias `a → b` no llevan puntas de flecha que unan pasos, y se quedan como
# texto.
DIAGRAMA_RE = re.compile(r"[┌┐┘▼▲►↓]")
CITA_PROMPTS_RE = re.compile(r"prompts/[\w.-]+\.md|_desechable-[\w.-]+\.md|zz-code/[\w./-]*")


class VerificadorDelPaquete(PerfilCoursesIA):
    # Callouts de la guía §8.1 a §8.4. Lo que el paquete usa fuera de esa lista se cambia en R2 (§17.2).
    CALLOUTS = {"📝", "📚", "⚠️", "💡", "🪦", "🔑", "💸", "🔥", "⭐", "🏷️", "🩻", "🪞", "⚰️",
                # Los tres de la plantilla base de los lineamientos del repositorio (CLAUDE.md), que
                # el paquete usa desde su primera fase (§17.2).
                "🧭", "🧠", "🧪",
                # 📄 es la línea que une una fase con su pieza forense (§9.2 y §15); 📌 abre el bloque de
                # reservas del cuaderno y las notas de servicio (§15).
                "📄", "📌"}
    # Emoji en ### (guía §3): los que el paquete usa en subtítulos de ejemplo y de código.
    EMOJI_H3 = set()
    # Los archivos que son capítulo: fases (00-…), rutas (q1-…, vu1-…, nx1-…) y apéndices (a1-…, a01-…).
    CAPITULO_RE = re.compile(r"^(\d{2}|q\d|vu\d|nx\d|a\d{1,2})-.*\.md$")
    # Documentos con número que son encuadre, consulta o plantilla, no fases (guía §17.2).
    NO_CAPITULO = PerfilCoursesIA.NO_CAPITULO + ("convencion", "historia", "audit", "decisiones",
                                                  "estructura", "plan-del-curso", "readme")
    # Ejercicios (guía §17.1 y D5): fases del tronco y de rutas 25–35; el Curso 02 llega a 38 en
    # tres fases, declaradas; los apéndices de práctica, 30–40.
    BANDA_FASE = (25, 38)
    BANDA_APENDICE = (30, 40)
    # Los dos apéndices de plataforma del Curso 01 (a6 y a7, guía §17.6) traen 15.
    BANDA_APENDICE_PLATAFORMA = (12, 18)
    APENDICES_PLATAFORMA = ("a6-arm64-m1.md", "a7-docker-colima.md")
    CAMPOS_ENCABEZADO = ()
    SECCION_PREGUNTAS = "Ejercicios"  # las rutas numeran la sección: «## 🧪 7. Ejercicios (29)»

    def archivos(self, alcance=None):
        # Los `_desechable-*` de `prompts/` se borran en C y no se verifican (plan §2, regla 9 y C).
        for ruta in super().archivos(alcance):
            if not os.path.basename(ruta).startswith("_desechable-"):
                yield ruta

    def preguntas(self, lineas):
        # Las rutas numeran sus ejercicios en negrita, «**🟢 9.** …», y el verificador base solo lee
        # «9. …»: se normaliza la forma antes de contar (guía §10).
        normal = [(n, re.sub(r"^\*\*(?:[🟢🟡🟠🔴] )?(\d+)\.\*\*\s*", r"\1. ", linea)) for n, linea in lineas]
        return super().preguntas(normal)

    def verificar_capitulo(self, ruta, lineas, texto, solucionario):
        nombre = os.path.basename(ruta)
        if nombre in self.APENDICES_PLATAFORMA:
            self.BANDA_PREGUNTAS = self.BANDA_APENDICE_PLATAFORMA
        else:
            self.BANDA_PREGUNTAS = (self.BANDA_APENDICE if re.match(r"^a\d", nombre) else self.BANDA_FASE)
        super().verificar_capitulo(ruta, lineas, texto, solucionario)

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
                                           " diagrama; va en Mermaid (§17.1)")
                bloque = None
            elif bloque is not False:
                bloque.append(linea)


class VerificadorDePublicacion(VerificadorDelPaquete):
    """Etapa E9: lo del paquete, más lo que el repositorio público exige (sin `prompts/`)."""
    PROHIBIR_ENLACES_A_PROMPTS = True
    PROHIBIDOS_EN_PUBLICADOS = PerfilPublicacion.PROHIBIDOS_EN_PUBLICADOS

    def verificar_documento_extra(self, ruta, lineas, texto):
        super().verificar_documento_extra(ruta, lineas, texto)
        for n, linea in enumerate(texto.splitlines(), 1):
            for cita in sorted(set(CITA_PROMPTS_RE.findall(linea))):
                self.error("CITA-PROMPTS", f"{self.rel(ruta)}:{n} → nombra {cita}")


if __name__ == "__main__":
    clase = VerificadorDelPaquete
    if "--publicacion" in sys.argv:
        sys.argv.remove("--publicacion")
        clase = VerificadorDePublicacion
    sys.exit(main(clase, RAIZ))
