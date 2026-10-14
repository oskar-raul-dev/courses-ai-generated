# 🗓️ Programa del curso

> **Curso:** Ruta NoSQL Lite
> **Última actualización:** 12/10/2026, con las 26 fases escritas y verificadas en macOS arm64
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

**Si solo vas a hacer un bloque, haz el 0 y el I**: 52 horas, con su boss. **Si solo vas a hacer una fase después
del Bloque 0, haz la 25**: dice cuándo no hacía falta nada del resto.

---

## 📋 Las fases

✅ escrita, ejecutada y verificada en macOS arm64 (Linux y Windows 11 con WSL2, pendientes: ver [`a01`](a01-laboratorio-contenerizado.md))

| # | Fase | Bloque | Horas | Ejercicios | Estado |
|---|---|---|---|---|---|
| 00 | [La decisión que se hereda](00-la-decision-que-se-hereda.md) | 0 | 4 | 12 | ✅ |
| 01 | [El dominio de flota y el arnés](01-el-dominio-de-flota-y-el-arnes.md) | 0 | 5 | 22 | ✅ |
| 02 | [Las cinco preguntas](02-las-cinco-preguntas.md) | 0 | 3 | 12 | ✅ |
| 03 | [Documental: levantar y modelar](03-documental-levantar-y-modelar.md) | I | 10 | 26 | ✅ |
| 04 | [Documental: romper, medir y decidir](04-documental-romper-y-medir.md) | I | 10 | 28 | ✅ |
| 05 | [Clave-valor: levantar y modelar](05-clave-valor-levantar-y-modelar.md) | I | 10 | 24 | ✅ |
| 06 | [Clave-valor: romper, medir y decidir](06-clave-valor-romper-y-medir.md) | I | 10 | 26 | ✅ |
| 07 | [Analítico embebido: levantar y modelar](07-analitico-levantar-y-modelar.md) | II | 10 | 24 | ✅ |
| 08 | [Analítico embebido: romper, medir y decidir](08-analitico-romper-y-medir.md) | II | 10 | 26 | ✅ |
| 09 | [Series temporales: levantar y modelar](09-series-levantar-y-modelar.md) | II | 10 | 26 | ✅ |
| 10 | [Series temporales: romper, medir y decidir](10-series-romper-y-medir.md) | II | 10 | 26 | ✅ |
| 11 | [Búsqueda: levantar y modelar](11-busqueda-levantar-y-modelar.md) | II | 10 | 26 | ✅ |
| 12 | [Búsqueda: romper, medir y decidir](12-busqueda-romper-y-medir.md) | II | 10 | 28 | ✅ |
| 13 | [Grafos: levantar y modelar](13-grafos-levantar-y-modelar.md) | III | 10 | 24 | ✅ |
| 14 | [Grafos: romper, medir y decidir](14-grafos-romper-y-medir.md) | III | 10 | 28 | ✅ |
| 15 | [Vectorial: levantar y modelar](15-vectorial-levantar-y-modelar.md) | III | 10 | 24 | ✅ |
| 16 | [Vectorial: romper, medir y decidir](16-vectorial-romper-y-medir.md) | III | 10 | 26 | ✅ |
| 17 | [Columnar ancha: levantar y modelar](17-columnar-levantar-y-modelar.md) | IV | 10 | 28 | ✅ |
| 18 | [Columnar ancha: romper, medir y decidir](18-columnar-romper-y-medir.md) | IV | 10 | 28 | ✅ |
| 19 | [Offline-first: levantar y modelar](19-offline-levantar-y-modelar.md) | IV | 10 | 24 | ✅ |
| 20 | [Offline-first: romper, medir y decidir](20-offline-romper-y-medir.md) | IV | 10 | 24 | ✅ |
| 21 | [NewSQL: levantar y modelar](21-newsql-levantar-y-modelar.md) | IV | 10 | 26 | ✅ |
| 22 | [NewSQL: romper, medir y decidir](22-newsql-romper-y-medir.md) | IV | 10 | 26 | ✅ |
| 23 | [El diseño: qué motor para qué parte](23-poliglota-el-diseno.md) | V | 12 | 22 | ✅ |
| 24 | [La costura: consistencia entre motores](24-poliglota-la-costura.md) | V | 14 | 26 | ✅ |
| 25 | [La factura y el veredicto final](25-poliglota-la-factura.md) | V | 14 | 24 | ✅ |
| | **Total** | | **252 h** | **636** | **26 de 26** |

---

## 📎 Los apéndices

Van fuera de las horas del curso, y se consultan cuando una fase los pide.

| # | Apéndice | Estado |
|---|---|---|
| a01 | [Laboratorio contenerizado](a01-laboratorio-contenerizado.md) | ✅ verificado en macOS arm64; Linux y Windows 11, escritos y sin verificar |
| a02 | [El `compose.yaml` de la ruta](a02-compose-de-la-ruta.md) | ✅ |
| a03 | [CLIs de los motores](a03-clis-de-los-motores.md) | ✅ los once motores |
| a04 | [El arnés de medida](a04-el-arnes-de-medida.md) | ✅ los once motores, la huella de un derivado y la ventana de inconsistencia |
| a05 | [El dominio de flota y sus datos](a05-el-dominio-de-flota.md) | ✅ |
| a06 | [Lenguajes y drivers](a06-lenguajes-y-drivers.md) | ✅ |
| a07 | [Postgres como línea base](a07-postgres-linea-base.md) | ✅ |
| a08 | [Diccionario y glosario](a08-diccionario-y-glosario.md) | ✅ las diez familias y el capstone |
| a09 | [Catálogo de errores](a09-catalogo-de-errores.md) | ✅ 83 entradas; el curso se proponía 50 |
| a10 | [Licencias y riesgo](a10-licencias-y-riesgo.md) | ✅ |

---

## 💀 Los boss y los miniproyectos

Todos opcionales y fuera de las 252 h.

| Bloque | 💀 Boss de bloque | Lo pide | Estado |
|---|---|---|---|
| I | [La orden que entró dos veces](06-clave-valor-romper-y-medir.md#-boss-del-bloque-i--la-orden-que-entró-dos-veces) | Yamile Cruz | ✅ |
| II | [El tablero que nadie puede reconstruir](12-busqueda-romper-y-medir.md#-boss-del-bloque-ii--el-tablero-que-nadie-puede-reconstruir) | Lucía Arango | ✅ |
| III | [Freddy ya vio esto](16-vectorial-romper-y-medir.md#-boss-del-bloque-iii--freddy-ya-vio-esto) | Hernán Peñaloza | ✅ |
| IV | [La estación del Coca](22-newsql-romper-y-medir.md#-boss-del-bloque-iv--la-estación-del-coca) | Lucía Arango | ✅ |
| V | [Las dos verdades](25-poliglota-la-factura.md#-boss-del-bloque-v--las-dos-verdades) | Lucía Arango | ✅ |

Ningún boss publica su solución: el criterio de aceptación es el entregable.

🏆 **El Hangar**, el boss global, crece bloque a bloque y [cierra en la Fase 25](25-poliglota-la-factura.md#el-hangar-cerrado). Es lo único del curso
que se consume en orden ([`00-historia-de-condor.md`](00-historia-de-condor.md) §7).

🧰 **Los miniproyectos** son de otras empresas, uno por familia, y se anuncian al abrir cada fase B. El
índice está en [`miniproyectos.md`](miniproyectos.md), y los diez están escritos: cinco empresas, dos familias cada
una ([Barlovento](h-mini-01-documental-barlovento.md), [Nodo Sur](h-mini-02-clave-valor-nodo-sur.md),
[Bengala](h-mini-03-analitico-bengala.md), [Voltaria](h-mini-04-series-voltaria.md),
[Cumbre Roja](h-mini-07-vectorial-cumbre-roja.md)).

---

## 🚦 El orden en que se escribió

El orden de las fases es el mejor para aprender. **El de escritura fue otro**, y es el que importa si alguien
publica el curso por partes: cada fila se escribió, se ejecutó y se verificó entera antes de la siguiente.

1. **Bloque 0 y Bloque I** (F00–F06), con su boss y sus dos miniproyectos. ✅ 29/09/2026
2. **Vectorial** (F15–F16), adelantado a propósito por su conexión con RAG. ✅ 30/09/2026
3. **Bloque II** (F07–F12): analítico embebido, series temporales y búsqueda, con su boss. ✅ 07/10/2026
4. **Bloque III completo**: grafos (F13–F14) y el boss del bloque, que necesitaba vectorial. ✅ 07/10/2026
5. **Bloque IV** (F17–F22): columnar ancha, offline-first y NewSQL, con su boss. ✅ 10–12/10/2026
6. **Bloque V** (F23–F25), con el boss *"Las dos verdades"* y el cierre de El Hangar. ✅ 12/10/2026

**Vectorial antes del Bloque II se puede seguir igual**: sus dos fases necesitan solo el Bloque 0. Los demás bloques
van en orden.
