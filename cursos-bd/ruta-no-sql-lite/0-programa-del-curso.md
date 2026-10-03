# 🗓️ Programa del curso

> **Curso:** Ruta NoSQL Lite · documento vivo, se actualiza con cada tanda publicada
> **Última actualización:** 29/09/2026, con la Tanda 1 publicada: Bloque 0 y Bloque I completos
> **Qué es:** el temario entero en una página: qué fase va dónde, cuánto cuesta, qué está publicado y
> en qué orden conviene seguirlo. Qué es el curso y para quién está en el [README](README.md).

---

## 🧭 Cómo se sigue

**Una fase por sesión de trabajo, y en orden dentro de cada bloque.** El Bloque 0 no se salta: es el
instrumento con el que se miden y se deciden todos los demás. Después, cada familia es un minicurso de
dos fases de 10 h:

- **Fase A — levantar y modelar.** El motor arriba, el dominio de Cóndor modelado a la manera de la
  familia, el 🪞 instinto relacional que falla, con su medición, y la ⚰️ situación 3: la familia bien
  elegida y mal modelada.
- **Fase B — romper, medir y decidir.** La 🪞 apuesta escrita antes de medir, la medición contra
  Postgres bien jugado, el 💥 punto de rotura con su mensaje literal, las cinco preguntas respondidas
  para la familia y el ⚖️ veredicto honesto: cuándo **no** usarla.

Cada fase cierra con su checklist y su tag `fase-NN-<slug>`. Lo que mide va a la
[bitácora](bitacora-de-medicion.md), lo que falla con mensaje literal al
[catálogo de errores](a09-catalogo-de-errores.md), y cada instinto que se rompe a
[`INSTINTOS.md`](INSTINTOS.md). Esos tres documentos, leídos juntos, son el resumen del curso.

**Si solo vas a hacer un bloque, haz el 0 y el I**: 52 horas, con su boss, y ya están publicados.

---

## 📋 Las fases

✅ publicada · 🚧 pendiente

| # | Fase | Bloque | Horas | Ejercicios | Estado |
|---|---|---|---|---|---|
| 00 | [La decisión que se hereda](00-la-decision-que-se-hereda.md) | 0 | 4 | 12 | ✅ |
| 01 | [El dominio de flota y el arnés](01-el-dominio-de-flota-y-el-arnes.md) | 0 | 5 | 22 | ✅ |
| 02 | [Las cinco preguntas](02-las-cinco-preguntas.md) | 0 | 3 | 12 | ✅ |
| 03 | [Documental: levantar y modelar](03-documental-levantar-y-modelar.md) | I | 10 | 26 | ✅ |
| 04 | [Documental: romper, medir y decidir](04-documental-romper-y-medir.md) | I | 10 | 28 | ✅ |
| 05 | [Clave-valor: levantar y modelar](05-clave-valor-levantar-y-modelar.md) | I | 10 | 24 | ✅ |
| 06 | [Clave-valor: romper, medir y decidir](06-clave-valor-romper-y-medir.md) | I | 10 | 26 | ✅ |
| 07 | Analítico embebido: levantar y modelar | II | 10 | 24 | 🚧 |
| 08 | Analítico embebido: romper, medir y decidir | II | 10 | 26 | 🚧 |
| 09 | Series temporales: levantar y modelar | II | 10 | 26 | 🚧 |
| 10 | Series temporales: romper, medir y decidir | II | 10 | 26 | 🚧 |
| 11 | Búsqueda: levantar y modelar | II | 10 | 26 | 🚧 |
| 12 | Búsqueda: romper, medir y decidir | II | 10 | 28 | 🚧 |
| 13 | Grafos: levantar y modelar | III | 10 | 24 | 🚧 |
| 14 | Grafos: romper, medir y decidir | III | 10 | 28 | 🚧 |
| 15 | Vectorial: levantar y modelar | III | 10 | 24 | 🚧 |
| 16 | Vectorial: romper, medir y decidir | III | 10 | 26 | 🚧 |
| 17 | Columnar ancha: levantar y modelar | IV | 10 | 28 | 🚧 |
| 18 | Columnar ancha: romper, medir y decidir | IV | 10 | 28 | 🚧 |
| 19 | Offline-first: levantar y modelar | IV | 10 | 24 | 🚧 |
| 20 | Offline-first: romper, medir y decidir | IV | 10 | 24 | 🚧 |
| 21 | NewSQL: levantar y modelar | IV | 10 | 26 | 🚧 |
| 22 | NewSQL: romper, medir y decidir | IV | 10 | 26 | 🚧 |
| 23 | El diseño: qué motor para qué parte | V | 12 | 22 | 🚧 |
| 24 | La costura: consistencia entre motores | V | 14 | 26 | 🚧 |
| 25 | La factura y el veredicto final | V | 14 | 24 | 🚧 |
| | **Total** | | **252 h** | **636** | **52 h publicadas** |

---

## 📎 Los apéndices

Van fuera de las horas del curso, y se consultan cuando una fase los pide.

| # | Apéndice | Estado |
|---|---|---|
| a01 | [Laboratorio contenerizado](a01-laboratorio-contenerizado.md) | ✅ verificado en macOS arm64; Linux y Windows 11, escritos y sin verificar |
| a02 | [El `compose.yaml` de la ruta](a02-compose-de-la-ruta.md) | ✅ |
| a03 | [CLIs de los motores](a03-clis-de-los-motores.md) | crece con el curso: `psql`, `mongosh` y `valkey-cli` |
| a04 | [El arnés de medida](a04-el-arnes-de-medida.md) | crece con el curso: viajes, Postgres, MongoDB y Valkey |
| a05 | [El dominio de flota y sus datos](a05-el-dominio-de-flota.md) | ✅ |
| a06 | [Lenguajes y drivers](a06-lenguajes-y-drivers.md) | ✅ |
| a07 | [Postgres como línea base](a07-postgres-linea-base.md) | ✅ |
| a08 | [Diccionario y glosario](a08-diccionario-y-glosario.md) | crece con el curso: documental y clave-valor |
| a09 | [Catálogo de errores](a09-catalogo-de-errores.md) | crece con el curso: 31 de 50 entradas |
| a10 | [Licencias y riesgo](a10-licencias-y-riesgo.md) | ✅ |

---

## 💀 Los boss y los miniproyectos

Todos opcionales y fuera de las 252 h.

| Bloque | 💀 Boss de bloque | Lo pide | Estado |
|---|---|---|---|
| I | [La orden que entró dos veces](06-clave-valor-romper-y-medir.md#-boss-del-bloque-i--la-orden-que-entró-dos-veces) | Yamile Cruz | ✅ |
| II | El tablero que nadie puede reconstruir | Lucía Arango | 🚧 |
| III | Freddy ya vio esto | Hernán Peñaloza | 🚧 |
| IV | La estación del Coca | Lucía Arango | 🚧 |
| V | Las dos verdades | Lucía Arango | 🚧 |

🏆 **El Hangar**, el boss global, crece bloque a bloque y cierra en la Fase 25. Es lo único del curso
que se consume en orden ([`00-historia-de-condor.md`](00-historia-de-condor.md) §7).

🧰 **Los miniproyectos** son de otras empresas, uno por familia, y se anuncian al abrir cada fase B. El
índice está en [`propuestas-mini-proyectos.md`](propuestas-mini-proyectos.md); los dos del Bloque I son
[Barlovento](h-mini-01-documental-barlovento.md) y [Nodo Sur](h-mini-02-clave-valor-nodo-sur.md).

---

## 🚦 El orden de publicación

El orden de las fases es el mejor para aprender. **El de publicación es otro, y es un plan, no un
hecho**: solo la primera fila está publicada.

1. **Bloque 0 y Bloque I** (F00–F06), con su boss y sus dos miniproyectos. ✅ 29/09/2026
2. **Vectorial** (F15–F16), adelantado a propósito por su conexión con RAG. Se puede seguir con el
   Bloque 0 hecho.
3. **Bloque II** (F07–F12): analítico embebido, series temporales y búsqueda.
4. **Bloque III completo**: grafos (F13–F14) y el boss del bloque, que necesita vectorial.
5. **Bloque IV** (F17–F22): columnar ancha, offline-first y NewSQL.
6. **Bloque V** (F23–F25) y el cierre del curso.

Este documento se actualiza cada vez que se publica una fila, y en el cierre del curso se reescribe con
el orden real.
