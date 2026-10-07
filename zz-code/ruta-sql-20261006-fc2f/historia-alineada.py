#!/usr/bin/env python3
"""Alinea 00-historia-de-alameda.md con la plantilla de historia de zz-instrucciones: encabezado
con Vigencia y sin citas a prompts/ ni a otros cursos (D-03 editorial sin enlaces), un emoji por
sección mayor, y la §9 de preguntas abiertas (ya decididas en el alcance) reemplazada por cómo usa
el curso la historia. Uso: python3 historia-alineada.py <ruta-al-curso>"""
import sys
from pathlib import Path

p = Path(sys.argv[1]) / "00-historia-de-alameda.md"
t = p.read_text(encoding="utf-8")

def rep(a, b):
    global t
    assert t.count(a) == 1, a[:60]
    t = t.replace(a, b)

rep("""## Ruta SQL — borrador narrativo

> 📝 **Estado:** desde el 30/09/2026, con el alcance escrito
> ([`prompts/alcance-del-proyecto.md`](prompts/alcance-del-proyecto.md)), este documento es la
> **fuente de verdad de todo lo narrativo**, igual que `00-historia-de-condor.md` en la NoSQL
> Lite o `00-historia-de-cordillera.md` en el curso de C#. Lo marcado con 🔍 en §8 sigue sin
> usarse como material hasta que se verifique.
""", """## Ruta SQL — la historia del curso

> **Qué es este documento:** la **fuente de verdad de todo lo narrativo** del curso: la empresa, su
> gente, su sistema, sus cifras y sus dolores. Ninguna fase inventa un dato; si lo necesita y no
> está aquí, se agrega aquí primero. Lo marcado con 🔍 en §8 no se usa como material hasta que se
> verifique.
> **Vigencia:** 2026-10-06.
""")
rep("## 1. Cómo llegó a existir", "## 1. 🏗️ Cómo llegó a existir")
rep("## 5. Quién es quién", "## 5. 👥 Quién es quién")
rep("""Hay dos cursos en el repositorio que ya cuentan historias de sistemas heredados, y esta tiene que
contar otra cosa.

**Cóndor MRO** (NoSQL Lite) sirve para ver qué pasa cuando un dominio no es relacional en todas
sus partes. **Cordillera Media** (C#) sirve para ver qué pasa con el *código* heredado: FoxPro,
pasantes y una migración de runtime. **Alameda** es la historia del *modelo de datos* heredado:""",
"""Hay muchas historias de sistemas heredados, y casi todas son la del *código*: el lenguaje que ya
nadie sabe, el runtime que no se puede migrar. **Alameda** es la historia del *modelo de datos* heredado:""")
rep("""Además, esta historia hace que **los cuatro motores del curso lleguen solos**, igual que
Cordillera nunca decidió ser una casa Microsoft:""",
"""Además, esta historia hace que **los cuatro motores del curso lleguen solos**, como llegan en
casi todas las empresas, sin que nadie los elija:""")
rep("🧭 Igual que en Cordillera, lo importante de esta sección no es la nostalgia.",
    "🧭 Lo importante de esta sección no es la nostalgia.")

i = t.index("## 9. ❓ Lo que este borrador todavía no decide")
j = t.index("## 📚 Fuentes de la verificación")
t = t[:i] + """## 9. 🧭 Cómo usa el curso esta historia

- **Córdoba, y no otro sitio**, por tres dolores que la ciudad trae solos: obras sociales con
  convenios distintos, precios que la inflación obliga a versionar y una red que absorbe clínicas
  del interior. Además, el NBU nació allí.
- **Access solo existe en la historia.** El lector no recibe el `.mdb`: recibe **la caja**, el
  volcado en CSV que Matías armó en un fin de semana (§3, 2026), y la carga en Postgres. El
  `.accdb` de turnos vuelve como pieza de museo en el apéndice `a10`, opcional.
- **Los 1,9 millones de pacientes y los 140 millones de `ResultadoItem` no entran en un
  laboratorio de 16 GB.** Los datos son sintéticos, con semilla determinista, en tres perfiles de
  volumen (S, M y L); se conservan las proporciones de la historia —duplicados, nacidos en el
  futuro, valores con coma y con punto— y el generador sabe qué registros son la misma persona.
- **Cada bloque cierra con un encargo de alguien de esta historia**, con un sistema roto de partida:
  la señora que es tres pacientes (Norma), el portal de 2018 (Verónica), una tarde de julio
  (Matías), el informe en la app (Florencia), las 9:40 (Verónica) y el puente con el SIH (Matías).
  El encargo global, **"Un martes"**, sale del `LEEME.txt` de Matías: termina cuando la facturación
  de un martes corre entera sobre la base nueva.

---

""" + t[j:]
p.write_text(t, encoding="utf-8")
print("ok")
