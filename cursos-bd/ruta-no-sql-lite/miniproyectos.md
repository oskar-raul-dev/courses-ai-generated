# 🧰 Los diez miniproyectos de familia
## Ruta NoSQL Lite — una empresa distinta por cada modelo de acceso

> **Qué es este documento:** el índice y el criterio de los **diez miniproyectos de familia**.
> Cada minicurso de la ruta cierra con un encargo que **no es de Cóndor**: viene de otra
> empresa, con otro dolor, y existe para demostrar que lo aprendido es un modelo de acceso y
> no un truco del dominio del curso. La empresa del curso es
> [`00-historia-de-condor.md`](00-historia-de-condor.md).
> **Vigencia:** 2026-10-06.

---

## 1. 🧭 Por qué existen

El curso tiene una decisión cerrada que no se toca: **un dominio único, modelado diez veces**.
Fijar el dominio y variar solo el modelo es lo único que hace comparables las mediciones; si
cada familia trajera su propio ejemplo, esto serían diez tutoriales puestos en fila.

Esa decisión es correcta y tiene un costo: **el lector aprende diez modelos sobre un solo
negocio**, y el riesgo es que salga sabiendo modelar el mantenimiento aeronáutico en diez
formas en vez de sabiendo reconocer diez modelos de acceso en cualquier parte. Es un riesgo
real, y tiene nombre en pedagogía: aprender el ejemplo en vez de la regla.

Los miniproyectos lo resuelven sin tocar la decisión:

> 🧭 **Cóndor mide; las otras empresas aplican.** Todo lo que entra a la bitácora —mediciones,
> apuestas falsables, puntos de rotura, línea base de Postgres— vive en Cóndor y solo en
> Cóndor. Los miniproyectos se construyen, se razonan y se defienden, pero **no entran al arnés
> de medición**. Así la comparabilidad queda intacta y la transferencia queda demostrada.

Hay una segunda razón, más práctica: **cada una de estas empresas tiene una familia donde su
dolor es más agudo que el de Cóndor**. La topología de una red eléctrica es mejor grafo que
una cadena de trazabilidad; las notas de catación de un café son mejor corpus vectorial que un
reporte de piloto; el tablero de una agencia de publicidad es el caso para el que el motor
analítico embebido parece diseñado. Desaprovechar eso por fidelidad al dominio único sería
cambiar pedagogía por coherencia, y en este curso la pedagogía manda.

---

## 2. 📐 Qué es un miniproyecto y qué no

El curso tiene cuatro clases de entregable, y conviene que ninguna se confunda con otra:

| Entregable | Dominio | ¿Se mide? | Cuándo | ¿Opcional? |
|---|---|---|---|---|
| **Las 26 fases** | Cóndor | ✅ sí, todo | El curso | No |
| 💀 **Boss de bloque** (5) | Cóndor | ✅ sí | Al cierre de cada bloque | Sí |
| 🧰 **Miniproyecto de familia** (10) | **otra empresa** | ❌ no | Al cierre de cada minicurso | Sí |
| 🏆 **El Hangar**, boss global | Cóndor | ✅ sí | Crece con el curso | Sí |

**El miniproyecto es un encargo, no un ejercicio grande.** Llega con una empresa que tiene un
problema, un dolor que se puede fechar y una persona que lo pide. La señal de que está bien
planteado es la misma que la del boss: **si cabe en tres líneas, era un 🔴 con mejor nombre**.

**Lo que un miniproyecto sí hace:** poner el modelo de acceso recién aprendido frente a un
dominio que no has visto, obligarte a reconocer la forma sin las pistas del ejemplo, y
terminar en un veredicto escrito —incluido el veredicto incómodo de *"en esta empresa esta
familia no se justifica"*, que en dos de los diez es la respuesta correcta.

**Lo que no hace:** producir números para la bitácora, introducir motores nuevos, ni pedir
levantar infraestructura distinta de la que ya tiene el `compose.yaml` de la ruta
([`a02`](a02-compose-de-la-ruta.md)).

---

## 3. 🗂️ El reparto

Cinco empresas, diez familias, dos familias por empresa — y cada una se quedó con aquella
donde su dolor es más agudo.

| # | Familia | Empresa | El dolor que la lleva ahí | Archivo |
|---|---|---|---|---|
| 01 | 🍃 Documental | 🚢 **Barlovento** | La ficha de carga: refrigerada, peligrosa, a granel y de proyecto no comparten un solo campo, y los campos regulatorios no pueden ir vacíos | [`h-mini-01-documental-barlovento.md`](h-mini-01-documental-barlovento.md) |
| 02 | 🔑 Clave-valor | 📡 **Nodo Sur** | Cien mil sesiones vivas en una tabla relacional que se volvió el cuello de botella del portal | [`h-mini-02-clave-valor-nodo-sur.md`](h-mini-02-clave-valor-nodo-sur.md) |
| 03 | 🦆 Analítico embebido | 📣 **Bengala** | El tablero que tarda cuatro horas en armarse a mano y que tres personas arman distinto | [`h-mini-03-analitico-bengala.md`](h-mini-03-analitico-bengala.md) |
| 04 | ⏱️ Series temporales | ⚡ **Voltaria** | Borrar el año pasado de la tabla de lecturas tarda dos días y bloquea la facturación | [`h-mini-04-series-voltaria.md`](h-mini-04-series-voltaria.md) |
| 05 | 🔍 Búsqueda | 📣 **Bengala** | Vuelven a producir piezas que ya existen porque nadie las encuentra en el archivo | [`h-mini-05-busqueda-bengala.md`](h-mini-05-busqueda-bengala.md) |
| 06 | 🕸️ Grafos | ⚡ **Voltaria** | *"Si abro este seccionador, ¿quién se queda sin luz?"* — hoy se contesta llamando por radio | [`h-mini-06-grafos-voltaria.md`](h-mini-06-grafos-voltaria.md) |
| 07 | 🧬 Vectorial | ☕ **Cumbre Roja** | *"¿Qué lote se parece a este?"* es la pregunta del negocio y vive en la memoria de una catadora | [`h-mini-07-vectorial-cumbre-roja.md`](h-mini-07-vectorial-cumbre-roja.md) |
| 08 | 🏛️ Columnar ancha | 📡 **Nodo Sur** | Los registros de tráfico dejaron de caber en un nodo y la consulta del soporte tarda minutos | [`h-mini-08-columnar-nodo-sur.md`](h-mini-08-columnar-nodo-sur.md) |
| 09 | 📴 Offline-first | ☕ **Cumbre Roja** | El técnico sube a la finca el lunes y transcribe el viernes lo que ya no recuerda | [`h-mini-09-offline-cumbre-roja.md`](h-mini-09-offline-cumbre-roja.md) |
| 10 | ⚡ NewSQL | 🚢 **Barlovento** | La misma carga liberada dos veces en dos terminales de dos países | [`h-mini-10-newsql-barlovento.md`](h-mini-10-newsql-barlovento.md) |

> 📝 **Por qué no hay una empresa de mantenimiento industrial.** Sería hermana de Cóndor y su
> dolor sería el mismo. Un miniproyecto que se parece al dominio del curso no demuestra
> transferencia; la disimula.

### 3.1 Los dos veredictos incómodos, y son deliberados

En ocho de los diez casos, la familia recién aprendida es la respuesta correcta para esa
empresa. En dos **no lo es**, y eso está puesto a propósito:

- **En Bengala, el miniproyecto de búsqueda termina reconociendo que media solución era un
  índice de Postgres** y que el motor dedicado se justifica solo por las facetas y la
  tolerancia a errores de tecleo — no por el buscador en sí.
- **En Cumbre Roja, el miniproyecto de vectorial gana, pero no solo.** La respuesta honesta es
  híbrida: el parecido semántico encuentra el lote, y el filtro por metadatos —cosecha,
  altura, variedad— es lo que hace utilizable el resultado. Vectorial sin filtro devuelve
  poesía.

Un curso donde los diez encargos terminan comprando el motor que acaba de enseñar es
propaganda. **Estos dos existen para que no lo sea**: si al resolverlos llegas a otra conclusión,
defiéndela con el mismo cuidado.

---

## 4. 🧰 Los diez stacks de un vistazo

| # | Familia | Entorno | Motor · perfil | Driver o cliente | Línea base |
|---|---|---|---|---|---|
| 01 | 🍃 Documental | TypeScript | MongoDB · `documental` | `mongodb` (sin ODM) | Postgres JSONB + GIN |
| 02 | 🔑 Clave-valor | TypeScript + **Lua** | Valkey · `clave-valor` | `iovalkey` | Tabla `UNLOGGED` |
| 03 | 🦆 Analítico | **Python** (arnés en TS) | DuckDB · `analitico` | cliente de Python + CLI | Postgres, tabla ancha |
| 04 | ⏱️ Series | TypeScript | TimescaleDB · `series` | `pg` — es una extensión | Postgres particionado |
| 05 | 🔍 Búsqueda | TypeScript | OpenSearch · `busqueda` | HTTP + cliente de JS | Postgres `tsvector` + GIN |
| 06 | 🕸️ Grafos | TypeScript | Neo4j · `grafos` | `neo4j-driver` · Cypher | `WITH RECURSIVE` con corte de ciclos |
| 07 | 🧬 Vectorial | **Python** ingesta · TS consulta | Qdrant · `vectorial` | `qdrant-client` + HTTP | `pgvector` con HNSW |
| 08 | 🏛️ Columnar | TypeScript | Cassandra · `columnar` | `cassandra-driver` · CQL | Postgres particionado |
| 09 | 📴 Offline | TypeScript de punta a punta | CouchDB + PouchDB · `offline` | HTTP · IndexedDB | **ninguna, y se declara** |
| 10 | ⚡ NewSQL | TypeScript | CockroachDB · `newsql` | **`pg`**, el mismo de Postgres | Postgres de un nodo con réplica |

Dos lecturas que esta tabla deja a la vista y que valen más que la tabla:

**Python aparece dos veces y solo dos**, por la regla de los dos entornos de
[`a06`](a06-lenguajes-y-drivers.md) — y en vectorial aparece únicamente en la ingesta, porque la
consulta se hace en TypeScript a propósito: es la forma de desmontar el mito de que esa familia
"es de Python".

**Tres familias usan el driver de Postgres contra un motor que no es Postgres.** Series, porque
es una extensión; NewSQL, porque habla su protocolo; y analítico embebido, porque habla SQL. Es
la tesis del curso visible en una columna: **la etiqueta no decide nada, el modelo de acceso
sí.**

---

## 5. 🏢 Las cinco empresas, en una línea

- 🚢 **Barlovento** — operador portuario y de patio de contenedores. Cuatro terminales, dos
  países, y una aduana que no perdona.
- 📡 **Nodo Sur** — proveedor regional de internet por fibra. Creció más rápido de lo que su
  base de datos aguantaba.
- 📣 **Bengala** — agencia de publicidad y medios. *"La atención se compra; la memoria se
  construye"*, y no son dueños de sus propias métricas.
- ⚡ **Voltaria** — distribuidora eléctrica regional. Novecientos mil clientes y nadie sabe con
  certeza qué transformador alimenta a qué casa.
- ☕ **Cumbre Roja** — cooperativa cafetera vuelta exportadora. La calidad la decide una mesa de
  catación; la plata la decide una báscula.

Cada `h-mini` cuenta su empresa en tres párrafos: lo justo para entender el negocio. La única
empresa con historia larga es la que se mide, Cóndor.

---

## 6. ⏱️ Cuándo y cuánto

- **Son opcionales y van fuera de las 252 h del curso**, como los boss: de 4 a 6 h cada uno.
- **Se anuncian al abrir la fase B de su familia**, no al cerrarla: un encargo que conoces desde el
  principio cambia cómo lees la fase entera. Se hacen al terminarla.
- **Cada uno cierra con criterios de aceptación** verificables, y con su puente de vuelta a Cóndor:
  qué de lo que hiciste vuelve al dominio del curso y en qué fase.
