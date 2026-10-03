# 📎 Apéndice a05 — El dominio de flota y sus datos

> **Curso:** Ruta NoSQL Lite · Consulta rápida · **2 h**
> **Usado por:** todas las fases · **Versiones cubiertas:** generador 1.0.0 en
> [`src/lab/generator/`](src/lab/generator/), Node 24.21.0
> **Fecha de verificación ejecutada:** 29/09/2026 — mismos hashes en macOS arm64, Linux arm64 y
> Linux amd64

**Esto no se lee de corrido.** Se entra por el índice buscando algo concreto y se sale. Resuelve
una sola cosa: que la medición de este curso sea **la misma en tu máquina y en la mía**, porque
los datos salen de un generador determinista y su resultado se comprueba con un hash.

**Qué queda fuera:** la empresa y su historia, que están en
[`00-historia-de-condor.md`](00-historia-de-condor.md); **cómo se carga cada motor**, que es
modelar y por eso lo escribe cada fase A (el de Postgres, F01); y los datos reales de nadie.
Aquí no se descarga ningún dataset que pueda desaparecer: todo se genera.

---

## Índice

- [La decisión que sostiene el curso](#-la-decisión-que-sostiene-el-curso)
- [Las diez entidades](#-las-diez-entidades)
- [Generar un dataset](#-generar-un-dataset)
- [Los volúmenes: qué significa 1 M](#-los-volúmenes-qué-significa-1-m)
- [Qué sale del generador](#-qué-sale-del-generador)
- [Determinismo: la prueba del hash](#-determinismo-la-prueba-del-hash)
- [Cómo simula cinco años](#-cómo-simula-cinco-años)
- [Los casos plantados](#-los-casos-plantados)
- [Lo que el generador simplifica](#-lo-que-el-generador-simplifica)
- [Cuándo usar qué](#-cuándo-usar-qué)
- [Advertencias](#️-advertencias)
- [Referencias](#-referencias)
- [Ejercicios](#-ejercicios-6)

---

## 🧭 La decisión que sostiene el curso

**Los datos salen del mismo generador, con la misma semilla y las mismas proporciones, en las
diez familias.** Si cada minicurso trajera su propio ejemplo, no habría comparación posible y
esto serían diez tutoriales en fila.

Y el matiz que lo hace funcionar: **dentro de cada familia, el motor y Postgres cargan
exactamente los mismos bytes**, comprobados por hash. La comparación que publica una fase B
—Mongo contra JSONB, Qdrant contra `pgvector`— es entre dos modelos del mismo dato, nunca entre
dos datos parecidos.

---

## 🗂️ Las diez entidades

Las mismas en todo el curso y con sus nombres fijos (§5 de la guía). Qué es cada una en el
hangar está en [`00-historia-de-condor.md`](00-historia-de-condor.md) §6; aquí, qué trae el
dataset:

| Entidad | Clave | Lo que trae |
|---|---|---|
| `hangar` | `hangarId` | las seis bases, de Villavicencio al Coca |
| `technician` | `technicianId` | licencia y si firma; las personas de la historia (Hernán, Freddy…) están |
| `supplier` | `supplierId` | 19 talleres aliados (`repairShop`, 4 con el convenio vencido) y 41 proveedores |
| `aircraft` | `registration` | modelo, operador y `options` **distintas por tipo de aeronave** |
| `partCatalog` | `partNumber` | alternos, modelos compatibles y el mismo número escrito de varias formas |
| `part` | `serialNumber` | lote, horas y ciclos, `details` **distintos por categoría**, y su estado final |
| `assembly` | `assemblyId` | motor y trenes, con las piezas que tienen dentro al cierre |
| `workOrder` | `workOrderId` | lo que se instaló y lo que se retiró, con su destino |
| `reading` | `aircraft` + `ts` | una lectura por minuto de vuelo, de las aeronaves con grabador |
| `pirep` | `pirepId` | prosa telegráfica con jerga y faltas |

Cómo se relacionan, en el sentido en que se leen:

```text
hangar ◄── technician                         supplier ◄── partCatalog.supplierIds
  ▲            ▲  (technicianIds, releasedBy)    ▲
  │            │                                 │ (removed[].supplierId, part.supplierId)
aircraft ◄── workOrder ──► removed[] / installed[] ──► part ──► partCatalog
  ▲  ▲          │ (pirepId)                              ▲
  │  │          ▼                                        │ (partSerials)
  │  └──── pirep                                     assembly ──► aircraft
  └──── reading
```

> 🧠 **El grafo de trazabilidad no es una entidad.** Qué pieza estuvo en qué aeronave y cuándo se
> reconstruye con los `removed[]` e `installed[]` de `workOrder`. Es exactamente el punto de F13.

---

## ⚙️ Generar un dataset

Requiere Node 24 y **ninguna dependencia**: no hay `npm install`.

```bash
cd src/lab/generator
node src/generate.ts --focus workOrder --volume 10k
```

```text
…/src/lab/data/workOrder-10k
  aircraft.ndjson               26 registros
  answers.json                   1 registros
  assembly.ndjson              109 registros
  hangar.ndjson                  6 registros
  part.ndjson                 7407 registros
  partCatalog.ndjson         14815 registros
  pirep-labels.ndjson         2185 registros
  pirep.ndjson                2185 registros
  reading.ndjson             50000 registros
  supplier.ndjson               60 registros
  technician.ndjson             12 registros
  workOrder.ndjson           10000 registros
datasetSha256 5a107518d72635a0d745353aeb0a8519b204c69bc3b0911bd5aafc850b306909
```

| Opción | Valores | Por defecto |
|---|---|---|
| `--focus` | `part`, `partCatalog`, `workOrder`, `reading`, `pirep` | `workOrder` |
| `--volume` | `10k`, `1m` o un entero (`250000`) | `10k` |
| `--seed` | cualquier texto | `condor-mro` |
| `--out` | un directorio | `src/lab/data` |

El resultado va a `src/lab/data/<focus>-<volume>/`, que **no se versiona** (`src/lab/.gitignore`):
se regenera en segundos. Cambiar la semilla da otro Cóndor igual de coherente; para comparar
con este curso, no la cambies.

---

## 📏 Los volúmenes: qué significa 1 M

**El volumen cuenta los registros de la entidad principal de la familia.** `--focus part
--volume 1m` produce **exactamente** 1 000 000 de `part`, y el resto de la empresa escala en la
misma proporción que tiene Cóndor (§5 de la historia, llevado a cinco años).

¿Por qué no "cinco años de la red", como decía la primera versión de la historia? Porque con los
números de Cóndor ninguna entidad llega sola a un millón —son unas 54 000 órdenes de trabajo—,
salvo las lecturas, que se pasan de largo. **Un volumen fijado por calendario no deja medir 1 M
donde importa.**

La entidad principal que propone este apéndice para cada familia —cada fase A la confirma en su
paso 1—:

| Familia | Fases | `--focus` | Por qué |
|---|---|---|---|
| documental | F03–F04 | `part` | la ficha de componente es la que nunca tiene los mismos campos |
| clave-valor | F05–F06 | `workOrder` | las reservas y los candados son de órdenes |
| analítico | F07–F08 | `workOrder` | el costo por hora volada sale de las órdenes |
| series | F09–F10 | `reading` | |
| búsqueda | F11–F12 | `partCatalog` | |
| grafos | F13–F14 | `workOrder` | el grafo se construye con sus instalaciones y retiros |
| vectorial | F15–F16 | `pirep` | |
| columnar | F17–F18 | `reading` | |
| offline | F19–F20 | `workOrder` | lo que el técnico edita sin señal |
| NewSQL | F21–F22 | `workOrder` | el expediente |

**Dos topes, y los dos están declarados en `src/scale.ts`:**

- **La escala del resto de la empresa no pasa de ×25.** Sin tope, 1 M de pireps (base de 11 800)
  multiplicaba Cóndor por 85 y el generador se quedaba sin memoria:
  `FATAL ERROR: Ineffective mark-compacts near heap limit Allocation failed - JavaScript heap out of memory`.
- **Fuera de series, las lecturas son contexto:** como mucho cinco por registro principal y
  200 000 en total.

Lo que sale a cada volumen, medido el 29/09/2026:

| Dataset | Escala | aircraft | part | partCatalog | workOrder | reading | pirep |
|---|---|---|---|---|---|---|---|
| `part-10k` | 0,25 | 35 | **10 000** | 20 000 | 13 500 | 50 000 | 2 950 |
| `partCatalog-10k` | 0,125 | 18 | 5 000 | **10 000** | 6 750 | 50 000 | 1 475 |
| `workOrder-10k` | 0,185 | 26 | 7 407 | 14 815 | **10 000** | 50 000 | 2 185 |
| `reading-10k` | 0,001 | 4 | 160 | 500 | 62 | **10 000** | 50 |
| `pirep-10k` | 0,85 | 119 | 33 898 | 67 797 | 45 763 | 50 000 | **10 000** |
| `part-1m` | 25 | 3 500 | **1 000 000** | 2 000 000 | 1 350 000 | 200 000 | 295 000 |
| `partCatalog-1m` | 12,5 | 1 750 | 500 000 | **1 000 000** | 675 000 | 200 000 | 147 500 |
| `workOrder-1m` | 18,5 | 2 593 | 740 741 | 1 481 481 | **1 000 000** | 200 000 | 218 519 |
| `reading-1m` | 0,11 | 16 | 4 566 | 9 132 | 6 164 | **1 000 000** | 1 347 |
| `pirep-1m` | 25 | 3 500 | 1 000 000 | 2 000 000 | 1 350 000 | 200 000 | **1 000 000** |

**El volumen de rotura** no se fija aquí: cada fase B lo calibra con `--volume` y un entero hasta
que el motor falla de verdad, y lo anota en su punto de rotura.

---

## 📦 Qué sale del generador

**Un NDJSON por entidad** (una línea, un registro JSON) y **canónico**: neutro respecto del
modelo. Los registros traen arrays anidados donde el dominio los tiene —`removed[]` e
`installed[]` en `workOrder`, `details` en `part`, `options` en `aircraft`— y cada cargador
decide qué hacer con ellos. Aplanarlos en tablas, embeberlos o partirlos en N tablas por consulta
**es modelar**, y lo enseña la fase de cada familia.

Una orden de trabajo, tal como sale:

```json
{"workOrderId":"WO-0000001","aircraft":"HK-5339","hangarId":"BOG","type":"routine","openedAt":"2021-10-01T00:58:38Z","closedAt":"2021-10-02T01:58:38Z","pirepId":null,"technicianIds":["T-002"],"releasedBy":"T-002","laborHours":16,"laborCostUsd":720,"partsCostUsd":0,"tasks":["prueba de fugas","inspección visual"],"removed":[],"installed":[]}
```

Además del NDJSON:

- **`manifest.json`** — versión del generador, semilla, foco, volumen, escala, conteos, y por
  archivo: registros, bytes y **SHA-256**. Al final, `datasetSha256`, el hash de todos los hashes.
- **`answers.json`** — las respuestas de los casos plantados. **No se carga en ningún motor**: es
  contra lo que se comprueba una consulta.
- **`pirep-labels.ndjson`** — el arquetipo de avería de cada pirep: la verdad de referencia
  para medir recall en F16. Tampoco se carga junto a los pireps.

Los instantes van en UTC, al segundo (`2021-10-01T00:58:38Z`), dentro de la ventana
**01/10/2021 – 29/09/2026**.

---

## 🔐 Determinismo: la prueba del hash

**El mismo comando produce los mismos bytes en cualquier máquina.** Y se comprueba, no se
promete:

```bash
node src/generate.ts --focus workOrder --volume 10k | tail -1
```

Si tu `datasetSha256` coincide con el de la tabla, tu dataset es idéntico byte a byte al de este
curso. Si no coincide, **algo en tu entorno cambió los datos**, y cualquier medición que hagas
encima dejará de ser comparable. Verificado el 29/09/2026:

| Dataset | macOS arm64 | Linux arm64 | Linux amd64 |
|---|---|---|---|
| `part-10k` | `b758e8bf7a073ce6…` | ✅ igual | ✅ igual |
| `partCatalog-10k` | `06a8900248129ddc…` | ✅ igual | ✅ igual |
| `workOrder-10k` | `5a107518d72635a0…` | ✅ igual | ✅ igual |
| `reading-10k` | `e579db576329f802…` | ✅ igual | ✅ igual |
| `pirep-10k` | `75d3b6802f56fb98…` | ✅ igual | ✅ igual |
| `part-1m` | `b0b7988921428c1f…` | no verificado | no verificado |
| `partCatalog-1m` | `a28d39be0bdb1311…` | no verificado | no verificado |
| `workOrder-1m` | `11a67c65fb22fdc9…` | no verificado | no verificado |
| `reading-1m` | `5999b66c77ad8f3c…` | ✅ igual | ✅ igual |
| `pirep-1m` | `d8a956d0c85a8217…` | no verificado | no verificado |

(Linux en contenedor `node:24-slim`; amd64, emulado. Los 1 M de `part`, `partCatalog`,
`workOrder` y `pirep` **no se verificaron en Linux**: generarlos emulados tardaría horas. Se
verifican en la sesión de laboratorio de Linux.)

**Qué lo garantiza, y por qué cada pieza:**

- **Un PRNG propio, sin dependencias** (sfc32, sembrado con cyrb128, en `src/rng.ts`). Una
  librería podría cambiar su algoritmo en una versión menor y romper el determinismo sin avisar.
  Solo usa aritmética entera de 32 bits, idéntica en toda plataforma donde corra V8.
- **Un flujo por entidad** (`rng.fork("workOrder")`…). Añadir una entidad o cambiar una no
  desplaza los valores de las demás.
- **Fecha ancla fija, sin `Date.now()`** en ninguna parte.
- **Nada que dependa del orden de un `Map` o de `Object.keys`**; las listas se ordenan antes de
  escribirse.
- **Node 24**, que ejecuta TypeScript sin compilar: no hay compilador ni bundler en medio.

---

## 🔁 Cómo simula cinco años

Lo justo para entender qué hay en los datos. El código está en `src/generate.ts`.

- **Cada aeronave tiene posiciones con pieza serializada**, según su tipo: motores, hélices o
  rotor, trenes y sus actuadores, llantas, bombas, instrumentos y aviónica (`src/domain.ts`).
  Al comienzo de la ventana cada posición tiene su pieza, y el resto de las piezas son repuestos
  en almacén.
- **Las órdenes de trabajo recorren los cinco años en orden cronológico.** Según su tipo
  —rutina, inspección, defecto o mayor— una orden cambia piezas o no. Una pieza se elige con más
  probabilidad cuanto menor es su tiempo medio entre fallas: las llantas rotan mucho más que un
  tren.
- **La pieza retirada va a almacén (40 %), a un taller aliado (50 %) o a chatarra (10 %).** La que
  va al taller vuelve entre 2 semanas y 8 meses después. **Una de cada cinco vuelve como
  intercambio**: el aliado devuelve otra pieza equivalente, con otro número de serie, y la
  original sale del inventario de Cóndor (`status: "exchanged"`).
- **Las aeronaves entran y salen de la flota.** Un 10 % entra durante la ventana y un 4 % sale;
  las piezas que llevaba puestas salen con ella (`leftWithAircraft`).
- **Las órdenes de defecto atienden pireps pendientes** de esa aeronave (`pirepId`).
- **Las lecturas** simulan vuelos de 40 a 120 minutos, una por minuto, con subida, crucero y
  descenso.

---

## 🎯 Los casos plantados

Casos con **respuesta conocida**, generados con la misma semilla y escritos en `answers.json`. Son
lo que convierte una consulta en una comprobación: la fase sabe qué tiene que devolver.

| Caso | Qué es | Dónde se usa |
|---|---|---|
| `directiveLot` | el lote `LOT-2022-117` de un actuador de tren; en `workOrder-1m`, 713 piezas que pasaron por 351 aeronaves | F13–F14: *"¿en qué aeronaves estuvo alguna vez una pieza de este lote, y qué se desmontó junto con ella?"* |
| `marchActuator` | el actuador de marzo de 2026: retirado en 2024 de una aeronave que salió de la flota, enviado a un taller aliado en abril de 2025 y **nunca devuelto** | F00 y el boss del Bloque V |
| `egtTrend` | una aeronave cuya EGT sube 0,6 °C por día durante los 60 días previos a la remoción de su motor | F09–F10 y F17–F18 |
| `exchanges` | cada intercambio, con el número de serie que salió y el que entró | F13–F14: la historia se bifurca |
| `pirep-labels.ndjson` | el arquetipo de avería de cada pirep | F15–F16: recall contra una verdad conocida |

Lo que contiene cada caso depende del dataset: el de `workOrder-10k` no es el de
`workOrder-1m`. Por eso las respuestas se leen siempre del `answers.json` **de ese mismo
directorio**.

---

## 🩹 Lo que el generador simplifica

Declarado, porque es la marca de la casa (§5.1 de la guía):

- **Es una empresa de mentira** construida para enseñar bases de datos. No modela regulación
  aeronáutica, y si algo choca con la realidad del oficio, gana el modelo de datos.
- **En un intercambio, la pieza que entra sale de los repuestos de Cóndor**, no de un inventario
  del aliado que el dataset no tiene. En los datos se ve igual que en la realidad —otro número de
  serie a partir de esa orden—, pero su historia anterior es la de un repuesto.
- **Las lecturas son de un solo motor por aeronave** y con valores sintéticos plausibles, no
  física de vuelo.
- **Horas y ciclos crecen en línea recta** con los días instalados.
- **Los pireps salen de diez arquetipos con plantillas**, sinónimos de plataforma y faltas. A 10 k
  son distintos el 99,9 %; **a 1 M, el 85,1 %**: un 15 % son duplicados exactos, y el más
  repetido aparece 214 veces. En reportes reales también hay duplicados, pero conviene saberlo
  antes de medir recall.
- **Las descripciones del catálogo son combinaciones** de un vocabulario de almacén, así que se
  repiten mucho a 1 M.

---

## 🧭 Cuándo usar qué

| Situación | Comando o archivo | Nota |
|---|---|---|
| Ejemplos de una fase A | `--volume 10k` con el foco de la familia | cabe en pantalla y carga en segundos |
| Mediciones publicadas de una fase B | `--volume 1m` con el mismo foco | el volumen de la bitácora |
| Punto de rotura | `--volume <entero>`, subiendo | anota el entero exacto en la fase |
| Comprobar que tu dataset es el del curso | `datasetSha256` contra la tabla | antes de medir, no después |
| Saber qué tiene que devolver una consulta | `answers.json` del mismo directorio | nunca se carga en el motor |
| Medir recall | `pirep-labels.ndjson` | la verdad de referencia |
| Un dataset que no está en la tabla | cualquier otra combinación | funciona, pero su hash no está publicado |

---

## ⚠️ Advertencias

- **1 M necesita memoria y disco.** Medido en macOS arm64 el 29/09/2026:

  | Dataset | Tiempo | Memoria máxima | En disco |
  |---|---|---|---|
  | `part-10k` | 0,41 s | 193 MiB | 25M |
  | `partCatalog-10k` | 0,28 s | 144 MiB | 17M |
  | `workOrder-10k` | 0,32 s | 148 MiB | 21M |
  | `reading-10k` | 0,13 s | 99 MiB | 2.0M |
  | `pirep-10k` | 0,91 s | 340 MiB | 66M |
  | `part-1m` | 28,94 s | 2406 MiB | 1.7G |
  | `partCatalog-1m` | 12,73 s | 1463 MiB | 882M |
  | `workOrder-1m` | 21,10 s | 2017 MiB | 1.3G |
  | `reading-1m` | 1,50 s | 188 MiB | 190M |
  | `pirep-1m` | 32,71 s | 2439 MiB | 1.9G |

  Con el laboratorio arriba en una máquina de 16 GB, genera antes de levantar las familias JVM.
- **Un cambio en el generador cambia los hashes.** Si un día cambia, sube su versión en
  `generatorVersion`, y los datasets de antes y de después dejan de ser comparables. Las fases
  citan la versión con la que midieron.
- **No mezcles volúmenes** entre el motor y Postgres de una misma medición. La tabla de conteos
  deja claro por qué: `workOrder-10k` y `workOrder-1m` no son "el mismo Cóndor, más grande".
  Tienen otra flota.

---

## 📚 Referencias

> ⚠️ Las URLs y sus contenidos cambian, y la documentación suele cubrir solo la última versión.
> Este apéndice se verificó con Node 24.21.0.

- **Node.js: ejecutar TypeScript** — https://nodejs.org/api/typescript.html — la sintaxis
  "borrable" que acepta Node sin compilar.
- **`util.parseArgs`** — https://nodejs.org/api/util.html#utilparseargsconfig — el parser de la
  línea de comandos, sin dependencias.
- **NDJSON** — https://github.com/ndjson/ndjson-spec — el formato de una línea, un registro.
- **PractRand y los PRNG pequeños**, sfc32 incluido — https://pracrand.sourceforge.net/ — de
  dónde sale el algoritmo y por qué pasa las pruebas estadísticas.
- **Dentro de este repositorio:** [`00-historia-de-condor.md`](00-historia-de-condor.md), §5 y
  §6.

**Orden sugerido:** las entidades antes de F01; los volúmenes y el determinismo antes de la
primera medición; los casos plantados cuando una fase los nombre.

---

## 🧪 Ejercicios (6)

### 🟢 Ejercicio 1 — Tu hash

Genera `workOrder-10k` y compara tu `datasetSha256` con la tabla.

**Objetivo:** saber, antes de medir nada, si tu dataset es el del curso.

### 🟢 Ejercicio 2 — Una aeronave de principio a fin

Elige una matrícula de `aircraft.ndjson` y busca sus órdenes en `workOrder.ndjson` (con `grep` o
`jq`).

**Pregunta:** ¿qué piezas se le cambiaron en cinco años, y a dónde fue cada una de las
retiradas?

### 🟡 Ejercicio 3 — La semilla

Genera `workOrder-10k` con `--seed otra` y compara conteos y hash con los de la semilla por
defecto.

**Objetivo:** ver qué cambia —los datos y el hash— y qué no —los conteos y la estructura—, y
explicar por qué el curso no cambia la semilla.

### 🟡 Ejercicio 4 — El actuador de marzo

Con `answers.json`, reconstruye la historia de `marchActuator` usando **solo**
`workOrder.ndjson` y `part.ndjson`.

**Pregunta:** ¿qué parte de la historia está en las órdenes, qué parte solo en el estado final de
la pieza, y qué parte no está en ningún archivo?

### 🟠 Ejercicio 5 — Qué significa 1 M aquí

Compara los manifiestos de `workOrder-1m` y `reading-1m`.

**Pregunta:** ¿cuántas aeronaves tiene cada uno, y por qué no se puede comparar una medición de
series hecha sobre `reading-1m` con una de NewSQL hecha sobre `workOrder-1m` como si fueran
"el mismo Cóndor"?

### 🔴 Ejercicio 6 — Romper el determinismo

Añade `Date.now()` a algún campo de `src/generate.ts`, genera dos veces y compara los hashes.
Deshaz el cambio.

**Objetivo:** ver cómo una sola llamada rompe la comparabilidad de todo el curso, y enumerar otras
tres formas de romperla sin tocar el reloj.

---

> 🏷️ **Este apéndice deja un archivo en el repositorio**: el generador de `src/lab/generator/`.
> El commit se etiqueta `apendice-a05-generador`.
