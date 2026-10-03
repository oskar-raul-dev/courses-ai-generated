# 🍃 Fase 03 — Documental: la ficha que nunca tiene los mismos campos, modelada para leerse de una vez

> **Curso:** Ruta NoSQL Lite · Fase 03 de 25 · Bloque I — Los dos que ya usas · **10 h**
> **Familia:** documental · **Motor:** MongoDB 8.0.20 `mongo@sha256:098862b1339f…`
> **Línea base:** PostgreSQL 18.6 `pgvector/pgvector@sha256:2ba9ca5f2e7d…` (JSONB)
> **Entorno de ejecución:** TypeScript
> **Volumen:** `part-10k` para los ejemplos, `part-1m` para las mediciones
> **Depende de:** Fase 02 · **Habilita:** Fase 04
> **Apéndices de apoyo:** [`a01`](a01-laboratorio-contenerizado.md), [`a02`](a02-compose-de-la-ruta.md),
> [`a03`](a03-clis-de-los-motores.md), [`a05`](a05-el-dominio-de-flota.md), [`a06`](a06-lenguajes-y-drivers.md)
> **Fecha de verificación ejecutada:** 29/09/2026, en macOS arm64
> **Objetivo:** modelar la ficha de aeronave de forma que leerla completa cueste **un viaje y un
> documento**, y demostrarlo con `explain` y con el contador de viajes.

---

## 🧭 1. Dónde estamos

El Bloque 0 dejó dos instrumentos: uno que mide (Fase 01) y cinco preguntas que deciden (Fase
02). Este bloque los estrena con las dos familias que casi todo el mundo ya usa, y empieza por la
más elegida y peor entendida: la documental.

Es también la familia de las autopsias de la Fase 00. El sistema de Camilo era documental, y
tenía razón en serlo: **la ficha de un componente no tiene los mismos campos que la de otro**. Lo
que salió mal no fue el modelo, fue modelarlo como si fuera relacional y resolver los cruces en la
aplicación. Esta fase monta Mongo, modela Cóndor dos veces —como lo haría quien viene de SQL y como
lo haría quien piensa en documentos— y mide la diferencia.

Una advertencia antes de empezar: **no hay comparación contra Postgres en esta fase**. La hay en la
Fase 04, con el mismo dataset y Postgres bien jugado. Aquí se aprende a modelar la familia y a leer
lo que mide.

---

## 🎯 2. Objetivos de esta fase

1. Cargar `part-1m` en Mongo en dos formas —referenciada y documental— desde los mismos bytes,
   comprobados por hash.
2. Decidir qué se embebe y qué se referencia con la pregunta de la unidad de lectura, y justificar
   cada decisión.
3. Leer la ficha completa de una aeronave en **1 viaje**, y medir los **25** que cuesta la forma
   referenciada con N+1.
4. Leer `explain("executionStats")` y distinguir documentos examinados, claves examinadas y
   devueltos.
5. Explicar qué hace `$lookup` por dentro: **22 documentos examinados con índice, 1 000 000 sin
   él**.
6. Nombrar qué crece sin cota en este dominio, y por qué el límite de 16 MB importa aunque tu ficha
   pese 8 kB.

---

## 🚫 3. Qué NO entra todavía

- **La comparación contra Postgres JSONB.** Es la apuesta de la
  [Fase 04](04-documental-romper-y-medir.md).
- **Transacciones multi-documento y su costo.** Se miden en la Fase 04.
- **El punto de rotura** —el documento que no cabe— y actualizar arrays anidados bajo
  concurrencia: Fase 04.
- **Sharding, replicación y operación.** Fuera del alcance del curso (alcance §11). El replica set
  de un nodo del laboratorio existe solo porque sin él no hay transacciones.

---

## 🏗️ 4. Levantar el motor

La receta y el porqué de cada pieza —la versión fijada, el replica set de un nodo que inicia el
healthcheck— están en [`a02`](a02-compose-de-la-ruta.md). Aquí, tres comandos desde la raíz del
curso:

```bash
cd src/lab && docker compose --profile documental up -d --wait && cd ..
node lab/generator/src/generate.ts --focus part --volume 1m
node 03-documental-levantar-y-modelar/load.ts --dataset lab/data/part-1m
```

```text
dataset part-1m · datasetSha256 b0b7988921428c1f… verificado
  condor_ref.partCatalog                     2000000
  condor_ref.aircraft                           3500
  condor_ref.part                            1000000
  condor_ref.assembly                          14938
  condor_ref.pirep                            295000
  condor_ref.workOrder                       1350000
  condor_doc.aircraft                           3500
  condor_doc.installedParts (embebidas)        63947
cargado en 69.7 s · 944 viajes a MongoDB (lotes de 5000)
```

(Recortada: `condor_ref` también carga `hangar`, `technician` y `supplier`.) El cargador crea **dos
bases desde el mismo dataset**: `condor_ref`, una colección por entidad, como las tablas de la
Fase 01; y `condor_doc`, donde cada aeronave es un documento con sus conjuntos y sus piezas
instaladas dentro. Comparar las dos es el grueso de la fase.

> ⚠️ **Desde tu máquina, la URL lleva `directConnection=true`.** El replica set se anuncia como
> `localhost:27017`, su dirección dentro del contenedor, y sin esa opción el driver la persigue y se
> cuelga hasta el timeout (`MongoServerSelectionError`, [`a09`](a09-catalogo-de-errores.md) E-03).

---

## 📖 5. El diccionario de la familia

| Relacional | Documental | Dónde se rompe el paralelo |
|---|---|---|
| tabla | colección | dos documentos de una colección no tienen por qué tener las mismas claves |
| fila | documento | un documento puede tener arrays y subdocumentos: una "fila" con filas dentro |
| clave primaria | `_id` | siempre existe e indexada; el cargador del curso usa la clave natural (`registration`, `serialNumber`) |
| `JOIN` | embeber (se resuelve al escribir) o `$lookup` (al leer) | `$lookup` existe, pero es un recorrido por documento de entrada (sección 6.6) |
| índice B-tree | índice B-tree, también sobre campos anidados y arrays | un índice sobre un array es *multikey*: una entrada por elemento |
| `EXPLAIN ANALYZE` | `explain("executionStats")` | en vez de filas, `totalDocsExamined` y `totalKeysExamined` |
| esquema | ninguno declarado, salvo validación opcional | el esquema no desapareció: se mudó al código |

> 🩻 **Esto sí funciona igual.** Un índice sigue siendo un índice, y una consulta sin índice sigue
> recorriendo todo: `COLLSCAN` es el `Seq Scan` de Mongo. El cociente examinados/devueltos se lee
> igual que en la Fase 01, y el contador de viajes del arnés funciona igual, escuchando los eventos
> de comando del driver ([`a04`](a04-el-arnes-de-medida.md)).

---

## 🧩 6. Modelar Cóndor a la manera documental

### 6.1 La unidad de lectura decide

La pregunta 3 de la Fase 02 es la que manda aquí: **¿qué se lee siempre junto?** En la pantalla de
Yamile, la ficha de una aeronave se lee entera y de una vez: su matrícula, su modelo, su
equipamiento opcional, sus conjuntos (motores, trenes) y las piezas que tiene instaladas en cada
posición, con la descripción de cada una. Nadie abre la ficha para ver solo el año de fabricación.

Esa es la unidad, y el modelo documental la convierte en **un documento**. Así queda una ficha en
`condor_doc.aircraft` (recortada a un conjunto y una pieza):

```javascript
{
  _id: 'HC-11799', registration: 'HC-11799', model: 'DHC-6-300 Twin Otter', kind: 'turboprop-twin',
  options: { weatherRadar: true, tcas: false, cargoDoor: false, seats: 30, apu: false },
  assemblies: [
    { assemblyId: 'ASM-HC-11799-ENG1', kind: 'powerplant', position: 'engine-1',
      partSerials: [ 'SN-0829719', 'SN-0512340', 'SN-0768317' ] }
  ],
  installedParts: [
    { serialNumber: 'SN-0333967', partNumber: '34-884350-20', category: 'instrument',
      lotNumber: 'LOT-2020-235', hoursSinceNew: 975, cyclesSinceNew: 13415,
      details: { calibrationIntervalDays: 365, lastCalibrationOn: '2021-01-02' },
      position: 'altimeter', catalog: { description: 'altímetro analógico', ataChapter: 34 } }
  ]
}
```

### 6.2 Embeber o referenciar: las tres reglas

Cada decisión de la ficha sale de tres preguntas, y conviene poder decir cuál de las tres decidió
cada campo:

- **¿Se lee junto con el padre?** Si sí, candidato a embeber. Conjuntos y piezas instaladas se leen
  siempre con la aeronave: van dentro.
- **¿Crece sin cota?** Si sí, **no se embebe**, aunque se lea junto. Las piezas instaladas están
  acotadas por las posiciones de la aeronave (22 como mucho en este dataset); el historial de
  órdenes de trabajo **no lo está**: crece cada semana, para siempre. Se queda en su colección.
- **¿Tiene vida propia o se comparte?** Si sí, se referencia, y a lo sumo se copia lo imprescindible.
  La pieza tiene historia propia —pasa por almacenes y otras aeronaves—, así que existe en su
  colección `part`, y la ficha embebe **una copia** de lo que la pantalla muestra. Del catálogo se
  copian solo la descripción y el capítulo ATA: si el catálogo cambia una descripción, la copia
  queda vieja, y es un precio que se acepta a sabiendas (💸 deuda intencional: se paga con una
  actualización periódica de las fichas, que la Fase 04 no necesita medir).

**La copia es la parte incómoda para quien viene de SQL**: es desnormalización a propósito. La
justifica la unidad de lectura, y se paga en escritura: cambiar una pieza de aeronave es tocar dos
fichas y la pieza. Esa factura es la Fase 04.

### 6.3 La forma referenciada, que también se midió

`condor_ref` es lo que haría quien piensa en tablas: `aircraft`, `part`, `assembly`, `partCatalog`,
cada una con su `_id` y con índices en las claves foráneas (`part.aircraft`, `assembly.aircraft`,
`workOrder` por aeronave y fecha). No es un hombre de paja: es la forma más común de Mongo en
producción, y es la del sistema de Camilo.

Tiene una virtud que conviene no despreciar: **cada entidad está una sola vez**. Cambiar la
descripción de un número de parte es tocar un documento; en `condor_doc`, es tocar todas las fichas
que lo copian. Y tiene un costo que no se ve en el modelo, solo en el código: **cada pantalla tiene
que saber cómo juntar las piezas**. En Postgres ese saber vive en un `JOIN` que el planificador
resuelve; en `condor_ref` vive en la aplicación, repetido en cada sitio que arma una ficha.

### 6.4 Leer la ficha completa, de cuatro maneras

La aeronave con más piezas instaladas de `part-1m` es la **`HC-10265`**, con 22. Su ficha completa,
contando los viajes con el arnés:

| Forma | Viajes | Qué hace |
|---|---|---|
| **embebida** (`condor_doc`) | **1** | `findOne({ _id })` |
| referenciada, N+1 | **25** | aeronave, piezas, conjuntos, y una consulta al catálogo por cada una de las 22 piezas |
| referenciada, con `$in` | 4 | aeronave, piezas, conjuntos, y el catálogo de todas en una |
| referenciada, con `$lookup` | 1 | una agregación que hace los cruces en el servidor |

`explain` de la embebida: `EXPRESS_IXSCAN { _id: 1 }` y **1 documento examinado**. Es el camino más
corto que tiene Mongo: búsqueda por `_id`, un documento, sin planificador de por medio.

Las dos filas del medio merecen una lectura. Con `$in`, la aplicación sigue haciendo los cruces,
pero agrupa las 22 consultas al catálogo en una: **de 25 a 4 viajes sin cambiar el modelo**. Es la
primera mejora que cualquiera debería probar antes de reescribir nada, y es la misma que el cargador
usa para copiar las descripciones. Lo que `$in` no arregla es que la ficha se arme con cuatro
lecturas en cuatro instantes distintos: los documentos examinados son los mismos 50, y la frontera
sigue igual de disuelta que con N+1 (sección 8).

Y fíjate en la última fila: `$lookup` también cuesta un viaje. **El número de viajes no basta para
entender el costo**, y la sección 6.6 abre la caja.

> **Prueba de fuego.** Ejecuta `node 03-documental-levantar-y-modelar/measure.ts --dataset
> lab/data/part-1m` y confirma que tu tabla dice 1, 25, 4 y 1. Con el mismo dataset, la aeronave
> elegida es la misma y el número de piezas también: si ves otra matrícula, tu carga no es la del
> curso.

### 6.5 Leer `explain("executionStats")`

Las piezas de motor con un TBO de 6000 horas, en `condor_ref.part`, con el índice
`{ "details.tboHours": 1 }`:

```javascript
db.part.find({ "details.tboHours": 6000 }).explain("executionStats")
```

```text
winningPlan: {
  stage: 'FETCH',
  inputStage: {
    stage: 'IXSCAN',
    keyPattern: { 'details.tboHours': 1 },
    indexName: 'details.tboHours_1',
    isMultiKey: false,
    indexBounds: { 'details.tboHours': [ '[6000, 6000]' ] }
  }
},
executionStats: {
  nReturned: 27865,
  executionTimeMillis: 27,
  totalKeysExamined: 27865,
  totalDocsExamined: 27865
}
```

- **`winningPlan`**: el plan que ganó. Se lee de adentro hacia afuera: `IXSCAN` recorre el índice
  entre los límites de `indexBounds`, y `FETCH` trae cada documento.
- **`totalKeysExamined`**: entradas de índice recorridas.
- **`totalDocsExamined`**: documentos leídos. **Es el equivalente de las filas examinadas de la
  Fase 01, y es el número que el curso compara.**
- **`nReturned`**: los devueltos. Aquí los tres coinciden: el índice llevó exactamente a lo
  pedido. Cociente 1.
- **`executionTimeMillis`**: contexto, nunca argumento.

Sin el índice, la misma consulta es un `COLLSCAN`: **1 000 000 de documentos examinados para
devolver 27 865**. El índice ocupa 4,1 MB.

### 6.6 `$lookup` por dentro

`$lookup` es el `JOIN` de Mongo, y la trampa está en cómo se ejecuta: **para cada documento de
entrada, busca en la colección ajena**. Con un índice en el campo de cruce, cada búsqueda es barata;
sin él, cada búsqueda recorre la colección entera. El `explain` de la agregación de la ficha,
mirando la etapa `$lookup` que trae las piezas:

| `part.aircraft` | Documentos examinados | Claves examinadas | Recorridos completos |
|---|---|---|---|
| con índice | 22 | 22 | 0 |
| sin índice | **1 000 000** | 0 | 1 |

Y esto es **para una sola ficha**. Una agregación que haga `$lookup` sobre 3500 aeronaves sin ese
índice recorre la colección de piezas 3500 veces. El `$lookup` no es malo: es un bucle anidado, y
necesita lo mismo que un bucle anidado en Postgres.

### 6.7 Índices sobre arrays: multikey

*"¿En qué ficha está instalada la pieza `SN-0011135`?"*. En `condor_doc`, la pieza está dentro del
array `installedParts`, y un índice sobre `installedParts.serialNumber` es **multikey**: una
entrada por cada elemento del array, no una por documento.

| | Documentos examinados | Claves examinadas |
|---|---|---|
| sin índice | 3 500 | 0 |
| con índice multikey | 1 | 1 |

El índice ocupa **0,8 MB para 3500 fichas y 63 947 piezas**: su tamaño lo decide el número de
elementos, no el de documentos. Y tiene una restricción que se descubre tarde: **un índice
compuesto no puede incluir dos arrays del mismo documento**.

```text
MongoServerError: Index build failed: … :: caused by :: cannot index parallel arrays [assemblies] [installedParts] (code 171, CannotIndexParallelArrays)
```

Si una consulta necesita cruzar dos arrays de la ficha con un índice, el modelo tiene que cambiar,
no el índice.

### 6.8 Lo que crece sin cota, y el límite de 16 MB

Un documento de MongoDB no puede pasar de **16 MB**. Con la ficha de Cóndor parece irrelevante:

```text
ficha embebida: media 7.0 kB · máxima 8.4 kB · límite 16384 kB
```

Pero la regla de la sección 6.2 existe por esto. **Lo que se embebe y crece sin cota termina
chocando con el límite**, y en este dominio hay dos candidatos: el historial de órdenes (1,35
millones de órdenes para 3500 aeronaves, unas 386 por aeronave y subiendo cada semana) y los
parámetros de vuelo, que llegan cada minuto. Si alguien decide *"la ficha con todo su historial
dentro, que se lee de una vez"*, la ficha deja de pesar 8 kB y empieza a crecer. Cuánto aguanta, y
con qué mensaje se rompe, es el punto de rotura de la Fase 04.

### 6.9 El esquema que se mudó al código

La analogía peligrosa del tema es *"documental es SQL sin esquema"*. El esquema no desapareció:
**se mudó al código**, y ahora vive en el cargador, en cada consulta y en la cabeza de quien las
escribe. La ficha de Cóndor lo muestra en cuanto se le hace una pregunta sencilla: *¿cuántas
aeronaves no tienen APU?*

```javascript
db.aircraft.countDocuments({ "options.apu": false })             // 1210
db.aircraft.countDocuments({ "options.apu": { $exists: false } }) // 1761
db.aircraft.countDocuments({ "options.apu": { $ne: true } })      // 2971
```

La respuesta correcta es **2971**, y la consulta que casi todo el mundo escribe primero devuelve
**1210**. La diferencia son 1761 fichas —helicópteros, monomotores y bimotores de pistón— que no
tienen la clave `apu` porque en su tipo de aeronave no aplica. En relacional sería una columna con
`NULL`, y el `NULL` obliga a pensar en él. Aquí, **"falso" y "no existe" se escriben distinto y se
consultan distinto**, y nada avisa.

Por tipo de aeronave, las claves de `options` son estas: los 1739 bimotores turbohélice tienen
`apu`, y ninguna otra ficha la tiene; los 381 helicópteros tienen `rotorBlades`, y ningún otro tipo.
**Ese reparto es el esquema**, y no está escrito en ningún sitio que Mongo pueda comprobar. Mongo
admite validar documentos con `$jsonSchema`, y el ejercicio 21 lo prueba. La decisión honesta es
validar lo que es común a todas las fichas —matrícula, modelo, las dos listas— y dejar libre lo que
cambia según el tipo, que es justo lo que justificó elegir esta familia.

### 6.10 La fecha que es un texto

El dataset canónico trae los instantes como texto ISO —`"2021-10-01T00:58:38Z"`— y el cargador los
deja así. En Mongo son `string`, no `Date`, y conviene decir por qué se aceptó.

**Lo que sigue funcionando:** comparar rangos. El formato ISO ordena de forma cronológica, así que
`{ openedAt: { $gte: "2025-01-01", $lt: "2025-04-01" } }` devuelve las 21 órdenes de `HC-10265` en
ese trimestre, igual que lo haría con fechas, y un índice sobre el campo sirve para ese rango.

**Lo que deja de funcionar:** todo lo que necesita saber que es una fecha. Agrupar las órdenes por
mes con `$dateTrunc`, por ejemplo:

```text
MongoServerError: PlanExecutor error during aggregation :: caused by :: $dateTrunc requires 'date' to be a date, but got string (code 5439012, Location5439012)
```

Se resuelve al vuelo con `{ $dateTrunc: { date: { $toDate: "$openedAt" }, unit: "month" } }`, pagando
la conversión en cada documento. Y los índices TTL, que borran documentos al vencer, solo
funcionan sobre `Date`: esto último no se ejecutó en el curso, la documentación de MongoDB lo
describe así. 💸 **Deuda intencional:** el curso conserva el texto para que Mongo y
Postgres carguen exactamente los mismos valores. En un sistema tuyo, la conversión va en el
cargador, que es donde vive el esquema.

### 6.11 Cargar es modelar

El cargador de esta fase no es un trámite: **es donde se tomaron todas las decisiones de la ficha**.
Algunas se ven en sus números:

- **944 viajes para cargar más de 4,6 millones de documentos**, porque cada lote de 5000 viaja en
  un `insertMany`. Es la misma idea que el `jsonb_to_recordset` de la Fase 01.
- **Una sola consulta al catálogo para las 63 947 piezas instaladas**, con `$in`, en lugar de una por
  pieza. Si el cargador hiciera lo que la forma referenciada hace al leer, serían 63 947 viajes más
  solo para copiar descripciones.
- **Las piezas se ordenan por posición dentro de la ficha**, para que la pantalla no tenga que
  hacerlo. Es una decisión de la unidad de lectura tomada al escribir.
- **Las dos bases se borran y se recargan enteras** (`dropDatabase`). El cargador es idempotente,
  que es lo que permite repetir la medición y obtener los mismos números.

Por eso esta fase escribe su propio cargador y no lo hereda de [`a05`](a05-el-dominio-de-flota.md):
el dataset canónico es neutro, y **pasar de neutro a documental es exactamente lo que la fase
enseña**.

> 🧠 **El patrón a memorizar.** En documental no se modela la entidad: se modela **la lectura**. Se
> embebe lo que se lee junto y está acotado; se referencia lo que crece sin cota o tiene vida
> propia; y lo que se copia, se copia sabiendo quién lo tiene que mantener al día.

---

## 🪞 7. Tu instinto relacional dice… y esta vez se equivoca

> 🪞 **"Normalizo, que para eso aprendí."** Una colección por entidad, referencias por `_id`, y los
> cruces cuando haga falta.

Es un instinto razonable: la normalización evita la redundancia, y la redundancia es lo que se
desincroniza. En Postgres funciona porque el `JOIN` se resuelve en el servidor, en un viaje.

En Mongo, la ficha normalizada y leída como se leería en SQL —una consulta por entidad y una por
cada referencia— cuesta **25 viajes** donde la ficha embebida cuesta **1**. Con `$in` baja a 4, y
con `$lookup` a 1, pero pagando un recorrido por cada documento de entrada, que sin índice es la
colección entera. **El instinto no se equivoca en evitar la redundancia: se equivoca en creer que
el cruce es gratis.** En documental, el cruce se decide al modelar, no al consultar.

La pregunta del instrumento que lo habría anticipado es la 3: la unidad de lectura. Este instinto
entra en [`INSTINTOS.md`](INSTINTOS.md) con la medición M-02.

---

## ⚰️ 8. La situación 3: elegiste bien la familia y la modelaste como relacional

Es el sistema de Camilo, y el patrón más común de Mongo en producción: **referencias por todas
partes y el `JOIN` escrito en el código de la aplicación**.

**Antes**, la ficha como la arma la aplicación sobre `condor_ref`: 25 viajes, y entre el primero y
el último, cualquier otra escritura puede cambiar lo que ya se leyó. Si una orden de trabajo mueve
una pieza de aeronave mientras la aplicación arma la ficha, la ficha muestra la pieza en dos sitios
o en ninguno. Nada avisa.

**Después**, la ficha embebida: 1 viaje y **un documento**, que Mongo lee y escribe de forma
atómica. Una ficha nunca se ve a medio actualizar, porque un documento es la unidad atómica de
Mongo sin necesidad de transacciones.

| | Viajes | Documentos examinados | Qué ve la pantalla |
|---|---|---|---|
| antes: referenciada, N+1 | 25 | 50: 1 aeronave + 22 piezas + 5 conjuntos + 22 del catálogo | lo que había en cada una de las 25 lecturas |
| después: embebida | 1 | 1 | la ficha en un único instante |

La factura del *antes* no es la lentitud: es la **frontera transaccional disuelta** que la Fase 00
contó. La del *después* también existe —cambiar una pieza de aeronave toca varios documentos— y es
exactamente lo que la Fase 04 mide: cuándo hacen falta transacciones multi-documento y qué pasa
cuando dos técnicos tocan la misma ficha.

---

## ⚠️ 9. Errores comunes y diagnóstico

**El driver se cuelga al conectar desde tu máquina.**
`MongoServerSelectionError: Server selection timed out after 8000 ms`. 🩺 Falta
`directConnection=true` ([`a09`](a09-catalogo-de-errores.md) E-03).

**Un índice compuesto sobre dos arrays.** `cannot index parallel arrays [assemblies]
[installedParts] (code 171, CannotIndexParallelArrays)`. 🩺 Mira qué campos del índice son arrays
con `isMultiKey` y `multiKeyPaths` en el `explain`. La salida es cambiar el modelo.

**`$lookup` lento sin mensaje de error.** 🩺 En el `explain` de la agregación, la etapa `$lookup`
con `collectionScans: 1` y `totalDocsExamined` igual al tamaño de la colección ajena. Falta el
índice en `foreignField`.

**Una función de fechas sobre un texto.**
`$dateTrunc requires 'date' to be a date, but got string (code 5439012, Location5439012)`. 🩺 Mira el
tipo del campo con `{ $type: "$openedAt" }` en una proyección: si dice `string`, o conviertes con
`$toDate` en la consulta o, mejor, en el cargador (sección 6.10). Es el mismo problema de fondo que
el `"6000"` de más abajo: en documental, el tipo lo decide quien escribe, y nadie lo comprueba por ti.

**Una transacción en un nodo sin replica set.**
`Transaction numbers are only allowed on a replica set member or mongos` (E-01). En el laboratorio
no pasa, porque el healthcheck inicia el replica set; en tu instalación, sí.

**La consulta que no encuentra nada y no dice por qué.** `{ "details.tboHours": "6000" }`, con el
valor como texto, usa el índice, examina 0 documentos y devuelve 0: en el campo hay números. 🩺
`indexBounds` en el `explain` muestra qué se buscó exactamente: `["6000", "6000"]`, entre comillas.
Lo mismo con `"options.apu": false` cuando la clave no existe (sección 6.9).

---

## 📋 10. Checklist de validación

```text
[ ] load.ts verificó part-1m (b0b7988921428c1f…) y cargó 3500 fichas con 63 947 piezas embebidas
[ ] La ficha de HC-10265 cuesta 1 viaje embebida y 25 referenciada con N+1
[ ] Sé por qué $in baja a 4 y $lookup a 1, y qué paga cada uno
[ ] $lookup sin índice en part.aircraft examina 1 000 000 de documentos por ficha
[ ] Leo en un explain: winningPlan, totalKeysExamined, totalDocsExamined y nReturned
[ ] El índice multikey sobre installedParts.serialNumber lleva de 3500 documentos a 1
[ ] Puedo justificar cada campo embebido de la ficha con una de las tres reglas de 6.2
[ ] Sé qué dos cosas crecen sin cota en este dominio
[ ] Sé por qué { "options.apu": false } devuelve 1210 y la respuesta correcta es 2971
[ ] El 🪞 de esta fase está en INSTINTOS.md y M-02 en la bitácora
```

---

## 🧪 11. Ejercicios (26)

Todos se ejecutan contra `condor_ref` y `condor_doc` cargados desde `part-1m`, salvo donde se
indique. El código de la fase está en `src/03-documental-levantar-y-modelar/`.

### 🟢 Fácil — la colección y su forma (1–8)

#### 🟢 Ejercicio 1 — Tu carga

Carga `part-10k` y compara los conteos con los de `part-1m`.

**Pregunta:** ¿cuántas piezas embebidas tiene cada ficha de media en cada volumen, y por qué no es
el mismo número?

#### 🟢 Ejercicio 2 — Una ficha en `mongosh`

Abre la ficha de `HC-10265` en `condor_doc` y en `condor_ref`.

**Objetivo:** listar qué campos de la ficha embebida no existen en `condor_ref.aircraft`, y de qué
colección salen.

#### 🟢 Ejercicio 3 — Dos aeronaves, dos formas

Compara `options` de un helicóptero y de un turbohélice.

**Pregunta:** ¿qué claves comparten? ¿Qué hace Mongo con una consulta sobre una clave que la mitad
de los documentos no tienen?

#### 🟢 Ejercicio 4 — El `explain` de la ficha

Pide `explain("executionStats")` de `findOne({ _id: "HC-10265" })` en `condor_doc`.

**Objetivo:** encontrar `EXPRESS_IXSCAN` y explicar por qué no hay `FETCH` separado.

#### 🟢 Ejercicio 5 — Los 25 viajes

Ejecuta `measure.ts` y encuentra en el código las cuatro formas de leer la ficha.

**Objetivo:** reproducir 1, 25, 4 y 1 viajes, y explicar de dónde sale el 25.

#### 🟢 Ejercicio 6 — Contar con los eventos

Escribe un script que lea tres fichas y cuente sus viajes con `countMongoRoundTrips`.

**Pregunta:** ¿el contador incluye el `hello` del arranque? ¿Por qué el arnés lo excluye?

#### 🟢 Ejercicio 7 — Sin índice

Busca las piezas con `details.tboHours = 4000` sin índice y con él.

**Objetivo:** documentos examinados contra devueltos en los dos casos, con el cociente.

#### 🟢 Ejercicio 8 — El tamaño de una ficha

Con `$bsonSize`, encuentra la ficha más pesada de `condor_doc`.

**Pregunta:** ¿cuántas fichas como esa caben en el límite de 16 MB, y por qué la pregunta está mal
planteada?

### 🟡 Intermedio — embeber y referenciar (9–16)

#### 🟡 Ejercicio 9 — Justificar cada campo

Para cada campo de la ficha embebida, di cuál de las tres reglas de 6.2 lo decidió.

**Objetivo:** que ningún campo quede sin regla, y que la copia del catálogo esté justificada.

#### 🟡 Ejercicio 10 — La ficha de componente

La colección `part` de `condor_ref` ya es polimórfica. Busca tres categorías y compara sus
`details`.

**Pregunta:** ¿por qué la ficha de componente no necesita embeber nada, y la de aeronave sí?

#### 🟡 Ejercicio 11 — `$lookup` con y sin índice

Reproduce la tabla de 6.6 quitando y volviendo a crear el índice `aircraft_1` de `part`.

**Objetivo:** obtener 22 y 1 000 000 documentos examinados, y encontrar `collectionScans` en el
`explain`.

#### 🟡 Ejercicio 12 — `$lookup` para todas las fichas

Escribe una agregación que haga el `$lookup` de piezas para las 3500 aeronaves. **Predice** los
documentos examinados con índice y sin él antes de ejecutar.

**Objetivo:** confirmar tu predicción con el `explain`. (Sin índice, limita a 10 aeronaves.)

#### 🟡 Ejercicio 13 — Multikey

Crea el índice sobre `installedParts.serialNumber` y busca en qué ficha está una pieza.

**Pregunta:** ¿por qué `isMultiKey` es `true`, y cuántas entradas tiene el índice?

#### 🟡 Ejercicio 14 — Parallel arrays

Intenta el índice compuesto sobre `installedParts.serialNumber` y `assemblies.assemblyId`.

**Objetivo:** reproducir el error 171 y proponer un cambio de modelo que permita la consulta.

#### 🟡 Ejercicio 15 — Una pantalla nueva

La pantalla de almacén muestra, por número de parte, las fichas donde está instalado.

**Pregunta:** ¿la ficha de aeronave sirve para esa pantalla? ¿Qué índice necesitarías, o qué otra
colección?

#### 🟡 Ejercicio 16 — La copia que envejece

Cambia la descripción de un número de parte en `condor_ref.partCatalog`.

**Objetivo:** encontrar cuántas fichas embebidas quedaron con la descripción vieja, y escribir la
actualización que las pone al día.

### 🟠 Difícil — cuando el modelo no es el de la pantalla (17–22)

#### 🟠 Ejercicio 17 — El historial dentro

Embebe en una copia de una ficha sus órdenes de trabajo de `condor_ref.workOrder`.

**Pregunta:** ¿cuánto pesa ahora? Extrapola: ¿en cuántos años de operación llegaría a 16 MB esa
aeronave?

#### 🟠 Ejercicio 18 — Una pieza en dos sitios

Con dos scripts a la vez, arma la ficha referenciada de una aeronave mientras el otro mueve una
pieza de esa aeronave a otra.

**Objetivo:** reproducir una ficha que muestra la pieza en un sitio donde ya no está, y explicar
por qué la embebida no puede mostrarla así.

#### 🟠 Ejercicio 19 — `$in` o `$lookup`

Compara `$in` (4 viajes) con `$lookup` (1 viaje) para la ficha de `HC-10265`: documentos
examinados en cada caso.

**Pregunta:** ¿cuál examina más documentos en el servidor, y cuál carga más a la aplicación?

#### 🟠 Ejercicio 20 — El índice comodín

Crea un índice `{ "details.$**": 1 }` y consulta dos claves distintas de `details`.

**Objetivo:** documentos examinados con él y comparación de su tamaño con el de un índice de un solo
campo. (La Fase 04 lo compara contra el GIN de Postgres.)

#### 🟠 Ejercicio 21 — Validación de esquema

Añade a `condor_doc.aircraft` un validador `$jsonSchema` que exija `registration`, `model` y
`installedParts` como array, e intenta insertar una ficha sin `model`.

**Objetivo:** el mensaje de error literal, y decidir qué campos de `options` validarías y cuáles no.

#### 🟠 Ejercicio 22 — Las dos formas, el mismo dato

Comprueba con un script que, para cada aeronave, las piezas embebidas de `condor_doc` son exactamente
las piezas instaladas de `condor_ref`.

**Objetivo:** una reconciliación que termine con cero diferencias, y medir cuántos viajes necesita.

### 🔴 Muy difícil — modelos ajenos (23–26)

#### 🔴 Ejercicio 23 — El sistema de Camilo

Modela en Mongo la ficha de componente de Aerotécnica del Sur tal como la cuenta la historia de
Cóndor: una colección por familia de componente y el cruce con órdenes en la aplicación.

**Objetivo:** medir cuántos viajes cuesta la historia de un componente, y señalar dónde se disuelve
la frontera transaccional.

#### 🔴 Ejercicio 24 — Otra pantalla, otro modelo

La pantalla de Hernán muestra, para una liberación al servicio, cada pieza instalada con su
trazabilidad completa: dónde estuvo antes y con qué certificado volvió.

**Pregunta:** ¿qué parte de eso cabe en la ficha y qué parte no? Diseña el modelo y justifica cada
decisión con las tres reglas.

#### 🔴 Ejercicio 25 — Cuando la unidad no es la ficha

El costo por hora volada lee tres campos de 1,35 millones de órdenes.

**Pregunta:** ¿qué forma de Mongo le sirve, y por qué la respuesta honesta probablemente no es
Mongo? (Se retoma en la Fase 07.)

#### 🔴 Ejercicio 26 — La autopsia inversa

Escribe la autopsia de un equipo que eligió `condor_doc` —la ficha embebida— para **todo**: también
para el almacén, el catálogo y la trazabilidad.

**Objetivo:** los cinco pasos de la Fase 00, con la factura estimada con los números de esta fase.

---

## 📚 12. Referencias

> ⚠️ Las URLs y sus contenidos cambian, y la documentación de MongoDB cubre la última versión. Esta
> fase se verificó con MongoDB 8.0.20.

- **Modelado de datos** — https://www.mongodb.com/docs/manual/data-modeling/ — embeber contra
  referenciar, en la voz del fabricante. Leer antes de la sección 6.
- **explain y executionStats** — https://www.mongodb.com/docs/manual/reference/explain-results/ —
  cada campo del plan.
- **Índices multikey** — https://www.mongodb.com/docs/manual/core/indexes/index-types/index-multikey/ —
  y la restricción de los arrays paralelos.
- **$lookup** — https://www.mongodb.com/docs/manual/reference/operator/aggregation/lookup/
- **Límites de MongoDB** — https://www.mongodb.com/docs/manual/reference/limits/ — los 16 MB, entre
  otros.
- **Pramod Sadalage y Martin Fowler, *NoSQL Distilled*** (Addison-Wesley) — el capítulo de
  agregados, que es la unidad de lectura con otro nombre.

**Orden sugerido:** el modelado de datos antes de la sección 6; `explain-results` durante la 6.5;
los límites, antes de la Fase 04.

---

## 🏁 13. Resultado de la fase

Tienes Cóndor en Mongo de dos formas, y los números que las separan: **1 viaje contra 25** para la
misma ficha, **22 documentos contra un millón** para el mismo `$lookup` con y sin índice, y una
regla para decidir qué se embebe que no depende del gusto: unidad de lectura, cota de crecimiento y
vida propia.

> **La señal de que quedó bien:** *"Puedo decir, para cada campo de la ficha, por qué está dentro o
> fuera, y cuánto me costaría haberlo decidido al revés."*

> 🏷️ **Tag:** `fase-03-documental-levantar-y-modelar` · prefijo de commit `f03:`
