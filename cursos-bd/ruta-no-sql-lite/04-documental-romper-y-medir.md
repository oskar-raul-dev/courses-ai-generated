# 🍃 Fase 04 — Documental: romper la ficha, medirla contra JSONB y decidir cuándo no

> **Curso:** Ruta NoSQL Lite · Fase 04 de 25 · Bloque I — Los dos que ya usas · **10 h**
> **Familia:** documental · **Motor:** MongoDB 8.0.20 `mongo@sha256:098862b1339f…`
> **Línea base:** PostgreSQL 18.6 `pgvector/pgvector@sha256:2ba9ca5f2e7d…` (JSONB con GIN)
> **Entorno de ejecución:** TypeScript
> **Volumen:** `part-1m` en los dos motores (`datasetSha256` `b0b7988921428c1f…`)
> **Depende de:** Fase 03 · **Habilita:** Fase 05
> **Apéndices de apoyo:** [`a04`](a04-el-arnes-de-medida.md), [`a07`](a07-postgres-linea-base.md),
> [`a09`](a09-catalogo-de-errores.md), [`a10`](a10-licencias-y-riesgo.md)
> **Fecha de verificación ejecutada:** 29/09/2026, en macOS arm64
> **Objetivo:** medir Mongo contra un Postgres bien jugado sobre los mismos bytes, llevar la ficha
> hasta que no cabe, y escribir con números cuándo **no** usar esta familia.

---

## 🧭 1. Dónde estamos

La [Fase 03](03-documental-levantar-y-modelar.md) modeló Cóndor en Mongo de dos formas y midió lo que
separa una ficha embebida de una referenciada: **1 viaje contra 25**. Faltaba la comparación que
justifica el curso entero: **contra Postgres**, y no contra el Postgres de `SIGMA`, con cuarenta
columnas anulables, sino contra el que un senior pondría hoy: columnas fijas para lo común, JSONB
para lo que cambia según el tipo, y un índice GIN encima ([`a07`](a07-postgres-linea-base.md)).

Esta fase hace tres cosas. **Mide**: las dos bases cargadas con el mismo `part-1m`, comprobado por
hash, y las mismas tres consultas en las dos. **Rompe**: lleva la ficha hasta que no cabe en un
documento y anota el volumen exacto. Y **decide**: termina con las cinco preguntas contestadas para
esta familia y con el veredicto honesto.

Hay una apuesta escrita antes de medir, y se publica el resultado, se gane o se pierda. Y hay un
miniproyecto, el de Barlovento, para comprobar después que lo aprendido sirve fuera de Cóndor.

---

## 🎯 2. Objetivos

1. Medir tres consultas del dominio en Mongo y en Postgres, con documentos o filas examinadas y
   viajes, sobre el mismo dataset.
2. Resolver la apuesta: **¿aguanta JSONB la consulta polimórfica con menos de 2× de degradación?**
3. Encontrar el volumen exacto al que la ficha deja de caber, con sus mensajes literales.
4. Mover una pieza entre dos fichas en una transacción, y reproducir el conflicto de dos técnicos
   sobre la misma ficha.
5. Contestar las cinco preguntas para documental y escribir cuándo no usarla.

> 🧰 **Miniproyecto de esta familia:** [Barlovento — la ficha de carga que no comparte un solo campo
> y no puede dejar vacíos los regulatorios](h-mini-01-documental-barlovento.md). Opcional, fuera de las
> horas del curso, y no entra a la bitácora.

---

## 🪞 3. La apuesta

> 🪞 **Apuesta antes de ejecutar.** Creo que **Postgres con JSONB y un índice GIN aguanta la misma
> consulta polimórfica con menos de 2× de degradación frente a Mongo**, medida en filas contra
> documentos examinados. Y creo que Mongo gana donde se supone que gana, la ficha completa, pero por
> menos de lo que el instinto dice.

Escrita el 29/09/2026, antes de ejecutar `measure.ts`. **Resultado, en la sección 4.4: la gané en
la consulta polimórfica —1,00×— y la perdí a medias en la ficha.**

---

## 📐 4. La medición contra la línea base

### 4.1 Las dos bases, los mismos bytes

Mongo tiene `part-1m` cargado por la [Fase 03](03-documental-levantar-y-modelar.md) en `condor_doc` y
`condor_ref`. Postgres se carga con el cargador de la [Fase 01](01-el-dominio-de-flota-y-el-arnes.md)
sobre el **mismo** dataset, y los dos cargadores comprueban el mismo `datasetSha256` antes de
empezar:

```bash
cd src
node 01-el-dominio-de-flota-y-el-arnes/load.ts --dataset lab/data/part-1m
psql -f 01-el-dominio-de-flota-y-el-arnes/indexes.sql    # con PGHOST=localhost PGPORT=15432…
node 04-documental-romper-y-medir/measure.ts --dataset lab/data/part-1m
```

El script mide las tres consultas y crea los índices de cada lado **en el orden en que aparecen en
esta sección**, así que se puede repetir: los índices que crea se borran antes de medir sin ellos.
`extra.ts`, en la misma carpeta, mide lo que las secciones 4.5 y 4.7 comparan con Postgres: el
conflicto de dos transacciones y el espacio en disco.

Dos precisiones de método, porque sin ellas los números no significan lo mismo en los dos lados.
**Se compara lo examinado, no lo tardado**: documentos examinados en Mongo contra filas examinadas en
Postgres, las dos cifras que el arnés lee de los planes ([`a04`](a04-el-arnes-de-medida.md)). Y **cada
lado usa su mejor índice razonable** para la consulta: en Mongo, el del campo o el comodín; en
Postgres, el GIN de [`a07`](a07-postgres-linea-base.md). Si alguno de los dos se midiera sin su índice,
la comparación sería contra un hombre de paja, y lo que ganaría sería la configuración, no el modelo.

### 4.2 Q1: la ficha completa

La misma aeronave que en la Fase 03, **`HC-10265`**, con 22 piezas instaladas. En Mongo, la ficha
embebida de `condor_doc`. En Postgres, **una sola consulta**, que junta aeronave, conjuntos y piezas
con su catálogo usando `json_agg`:

```sql
SELECT a.registration, a.options,
  (SELECT json_agg(s) FROM assembly s WHERE s.aircraft = a.registration) AS assemblies,
  (SELECT json_agg(json_build_object('serial', p.serial_number, 'position', p.position,
                                     'details', p.details, 'description', c.description))
     FROM part p JOIN part_catalog c USING (part_number)
    WHERE p.aircraft = a.registration AND p.status = 'installed') AS parts
FROM aircraft a WHERE a.registration = $1;
```

| | Viajes | Examinados |
|---|---|---|
| Mongo, ficha embebida | 1 | **1 documento** |
| Postgres, una consulta | 1 | **50 filas** |

**Los dos hacen un viaje.** Los 25 viajes de la Fase 03 no eran culpa del modelo relacional: eran
culpa de leerlo desde la aplicación, entidad por entidad. En SQL, el `JOIN` vive en el servidor.

Lo que Mongo sí gana, y con claridad, es **dónde están los datos**: la ficha es un documento, y
Postgres tiene que examinar 50 filas en cuatro tablas para armar lo mismo. Es la ventaja real del
modelo documental, y tiene nombre: la unidad de lectura. **50 contra 1 es la diferencia medida.**

> ⚠️ **La primera medición de Q1 dio 14 983 filas, no 50.** A la tabla `assembly` le faltaba un
> índice en `aircraft`, y cada ficha recorría los 14 938 conjuntos. No era Postgres: era una línea
> base mal puesta, justo lo que [`a07`](a07-postgres-linea-base.md) prohíbe. Se añadió el índice a
> los de referencia de la Fase 01, y es la razón de que esa regla vaya en la primera línea del
> apéndice. **Ganarle a una línea base mal puesta no demuestra nada.**

### 4.3 Q2 y Q3: la consulta polimórfica

**Q2**, la de siempre: las piezas de motor con un TBO de 6000 horas. En Mongo, con un índice sobre
el campo, `{ "details.tboHours": 1 }`. En Postgres, con el GIN `jsonb_path_ops` sobre `details`:

```sql
SELECT serial_number FROM part WHERE details @> '{"tboHours": 6000}';
```

**Q3**, la que nadie previó: las llantas con tres recauchados, `details.retreadCount = 3`. Es una
clave distinta, y aquí se ve la diferencia de fondo entre los dos índices. En Mongo, el índice de Q2
no sirve para Q3: sin otro índice es un `COLLSCAN`, y la alternativa es un índice comodín,
`{ "details.$**": 1 }`, que indexa todas las claves de `details`. En Postgres, **el mismo GIN de Q2
sirve para Q3**, porque indexa el documento entero.

| | Mongo | Postgres (GIN) |
|---|---|---|
| Q2 `tboHours = 6000` | 27 865 docs → 27 865 (índice del campo) | 27 865 filas → 27 865 |
| Q3 `retreadCount = 3`, sin índice nuevo | **1 000 000** docs (`COLLSCAN`) | 28 127 filas → 28 127 |
| Q3 con índice comodín `details.$**` | 28 127 docs → 28 127 | — (el mismo GIN) |

Y lo que cuesta cada índice:

| Índice | Tamaño | Qué cubre |
|---|---|---|
| Mongo `details.tboHours_1` | 4228 kB | una clave |
| Mongo `details.$**_1` | 11 364 kB | todas las claves de `details` |
| Postgres GIN `jsonb_path_ops` | 5152 kB | todas las claves, para `@>` |

### 4.4 El resultado de la apuesta

> 🪞 **Resultado.** En la consulta polimórfica, **la gané**: Postgres examina **exactamente las
> mismas filas que Mongo documentos** —27 865 y 28 127—, una degradación de **1,00×**. Y para cubrir
> cualquier clave de `details`, el GIN de Postgres ocupa **menos de la mitad** que el índice comodín
> de Mongo (5152 kB contra 11 364 kB).
>
> En la ficha, **la perdí a medias**. Mongo gana, y por mucho: 1 documento contra 50 filas. Pero no
> gana en viajes, que eran lo que el instinto decía. **La ventaja medida del modelo documental es la
> unidad de lectura, no el polimorfismo.**

Es un resultado incómodo para la razón con la que casi todo el mundo elige Mongo —*"cada registro
tiene campos distintos"*—, y conviene decirlo con esas palabras. **Para campos que cambian según el
tipo, JSONB con GIN alcanza.** Lo que JSONB no te da es la ficha en un documento, y eso solo importa
si la ficha es de verdad tu unidad de lectura.

### 4.5 Transacciones: mover una pieza entre dos fichas

Mover una pieza de una aeronave a otra toca **dos fichas**: sacarla del array de una y ponerla en el
de la otra. Si solo se escribe una de las dos, la pieza queda en dos sitios o en ninguno. Con el
replica set de un nodo del laboratorio, las dos escrituras van en una transacción:

```ts
await session.withTransaction(async () => {
  await fichas.updateOne({ _id: from }, { $pull: { installedParts: { serialNumber } } }, { session });
  await fichas.updateOne({ _id: to }, { $push: { installedParts: moved } }, { session });
});
```

```text
transacción: SN-0140420 pasó de HC-10011 a HC-10019 en una sola transacción (replica set de un nodo)
```

Funciona, y la [Fase 00](00-la-decision-que-se-hereda.md) ya citó qué pasa **sin** replica set:
`Transaction numbers are only allowed on a replica set member or mongos` (E-01).

Lo que no se ve hasta que se prueba es **qué bloquea una transacción**. Dos técnicos actualizan la
misma ficha a la vez, cada uno una pieza distinta —la primera y la segunda del array—, en dos
transacciones:

```text
MongoServerError: Caused by :: Write conflict during plan execution and yielding is disabled. :: Please retry your operation or multi-document transaction. (code 112, WriteConflict, etiquetas ["TransientTransactionError"])
```

**Piezas distintas, mismo documento, conflicto.** Mongo detecta el conflicto por documento, no por
campo, y la segunda transacción tiene que reintentarse. La etiqueta `TransientTransactionError` es
la señal de que reintentar es correcto, y `withTransaction` lo hace solo. Pero es el precio exacto de
haber embebido: **la ficha que se lee de una vez también se bloquea de una vez**.

El mismo experimento en Postgres, con `extra.ts`: dos transacciones abiertas a la vez, cada una
actualizando una pieza distinta de `HC-10265`.

```text
Postgres, piezas distintas: la segunda transacción actualizó sin esperar (4 ms)
Postgres, la misma pieza: canceling statement due to lock timeout (espera al primero; con lock_timeout de 2 s)
```

**En Postgres el conflicto es por fila.** Dos piezas de la misma aeronave son dos filas, y no se
estorban; la misma pieza sí, y la segunda transacción espera a la primera (aquí, hasta que el
`lock_timeout` de dos segundos la cancela). Es la misma regla de siempre, y conviene tenerla
presente al comparar: **la granularidad del conflicto la decide el modelo**. En `condor_ref`, con
una pieza por documento, Mongo tampoco chocaría; la ficha embebida sí.

Y el costo en viajes de la transacción de Mongo, contado con el arnés: **3 viajes**, dos `update` y
el `commitTransaction`. Una transacción multi-documento no es cara en viajes; es cara en lo que
bloquea y en lo que exige, un replica set.

### 4.6 Actualizar una pieza dentro del array

El dolor clásico del modelo documental son los arrays anidados. Aumentar las horas de una pieza
dentro de `installedParts` sin reescribir la ficha entera necesita un filtro de array:

```ts
await fichas.updateOne(
  { _id: registration },
  { $inc: { "installedParts.$[p].hoursSinceNew": 3 } },
  { arrayFilters: [{ "p.serialNumber": serial }] },
);
```

¿Cuánto se escribe? El oplog del replica set registra el cambio que se replicaría, y para esta
ficha de 8 kB registró esto:

```text
{"$v":2,"diff":{"sinstalledParts":{"a":true,"s0":{"u":{"hoursSinceNew":5433}}}}}
```

Unos 80 bytes: **un diff del campo, no la ficha entera**. El dolor de los arrays anidados no es el
volumen de escritura: es la sintaxis —`$[p]` con `arrayFilters`, `$` posicional, `$[]`— y el
conflicto de la sección anterior.

### 4.7 El espacio: la compresión que no se pidió

La comparación que nadie pone en el temario, y que aquí sale a favor de Mongo. Los mismos 1 000 000
de piezas, en disco:

| | Datos | Índices |
|---|---|---|
| Mongo, `condor_ref.part` | **83 MB** en disco (326 MB sin comprimir) | 48 MB |
| Postgres, tabla `part` | **159 MB** | 42 MB |

**WiredTiger, el motor de almacenamiento de Mongo, comprime los datos por defecto**, y la colección
ocupa en disco una cuarta parte de lo que pesan sus documentos. Postgres no comprime las filas
normales: solo los valores grandes que van a TOAST. Resultado: **la misma información ocupa la mitad
en Mongo**. Los índices no son comparables uno a uno —en Mongo están el de `_id`, el de `aircraft`, el
de `details.tboHours` y el comodín; en Postgres, la clave primaria, dos B-tree y el GIN—, pero el total
queda parecido.

No es un argumento para elegir Mongo —el espacio rara vez decide una familia—, pero es un número que
el veredicto tiene que mencionar, porque **las pérdidas y las ganancias van con cifra**, también cuando
ganan a favor del motor que no se esperaba. Y es un recordatorio de que Postgres no es gratis en todo:
quien necesite compresión ahí tiene que buscarla, y eso ya no es la configuración de fábrica. (Que
Postgres solo comprima los valores que pasan a TOAST, y no las filas normales, no se midió en este
curso: la documentación de PostgreSQL lo describe así.)

### 4.8 Lo que la apuesta no midió

Un 1,00× en filas examinadas es un resultado fuerte, y conviene decir exactamente qué afirma y qué
no. **Afirma** que, para encontrar las 27 865 piezas de Q2, ninguno de los dos motores miró una sola
pieza de más: el índice de cada uno llevó directo a lo pedido. **No afirma** que el trabajo sea el
mismo.

Postgres, con el GIN, no lee las filas una por una en orden de índice: primero arma un mapa de bits
con las páginas que contienen filas candidatas (`Bitmap Index Scan`) y después lee esas páginas
(`Bitmap Heap Scan`). En [`a07`](a07-postgres-linea-base.md), la consulta equivalente leyó **11 423
bloques** del montón para 20 733 filas. Mongo, en cambio, no expone cuántos bloques leyó: su
`executionStats` cuenta claves y documentos, no páginas. **No hay forma de poner los dos números de
bloques lado a lado**, y por eso la apuesta se escribió en la única medida que los dos reportan.

Es una limitación declarada, no una trampa, y tiene una consecuencia práctica: cuando una fase
compare dos motores, la medida común es la que los dos exponen —aquí, examinados contra devueltos—, y
lo que solo uno expone se cuenta aparte, como contexto de ese motor. Lo contrario sería comparar
bloques de Postgres contra una estimación de Mongo, y eso ya no es medir.

---

## 💥 5. El punto de rotura

La [Fase 03](03-documental-levantar-y-modelar.md) dejó una regla: **no se embebe lo que crece sin
cota**. Esta sección la rompe a propósito. Toma una ficha de `condor_doc` y le embebe los
parámetros de vuelo, que en Cóndor llegan uno por minuto de vuelo y nunca dejan de llegar:
`$push` de lecturas en lotes de 1000 hasta el primer fallo, y después en lotes de 100, 10 y 1 hasta
encontrar la lectura exacta que ya no cabe.

> 💥 **Rotura.** La ficha acepta **exactamente 90 344 lecturas** y pesa **16 777 036 bytes**: a 180
> bytes del límite de 16 MiB (16 777 216). La lectura 90 345 ya no cabe. Cada lectura ocupa unos 175
> bytes en JSON, así que con una lectura por minuto de vuelo, **una aeronave llena su ficha en unas
> 1500 horas de vuelo**. Con el ritmo de vuelo del dataset, unas dos horas y media por día, eso es
algo más de un año y medio de operación.

Y el mismo límite da **dos mensajes distintos**, según cuánto se intentó añadir:

```text
con 1000 lecturas de más:
MongoServerError: BSONObj size: 16898785 (0x101DAE1) is invalid. Size must be between 0 and 16793600(16MB) First element: _id: "HC-10011" (code 10334)

con 1 lectura de más:
MongoServerError: Resulting document after update is larger than 16777216 (code 10334)
```

Los dos llevan el mismo código, 10334, y los dos entran en [`a09`](a09-catalogo-de-errores.md). Fíjate
en el primero: el límite que cita, 16 793 600, es 16 MiB más 16 kB de margen interno del servidor.
**El límite de un documento sigue siendo 16 777 216**, como dice el segundo.

**Lo que se cambia para salir** no es un parámetro, porque el límite no se configura. Es el modelo:
las lecturas salen de la ficha a una colección propia, una lectura o un grupo por documento. Es el
**patrón bucket**: un documento por aeronave y por día, con las lecturas de ese día dentro, que
acota el crecimiento de cada documento. MongoDB tiene además colecciones de series temporales que
hacen ese agrupamiento por su cuenta. No se midieron en este curso: la familia de series se mide en
las Fases 09 y 10.

---

## 🚑 6. Salir de aquí

Cuando un sistema documental ya duele, la escalera se sube en orden de costo, del peldaño más barato
al más caro:

1. **Índice.** Un `$lookup` sin índice en el campo ajeno examina un millón de documentos por ficha
   (Fase 03); con índice, 22. Una consulta polimórfica sin índice es un `COLLSCAN` de un millón. Antes
   de tocar el modelo, mira el `explain`.
2. **Modelo.** Lo que crece sin cota sale del documento (sección 5). Lo que se lee junto entra, y la
   ficha referenciada con N+1 pasa de 25 viajes a 1. Lo que dos escritores tocan a la vez se separa,
   para que no choquen (sección 4.5). Para las lecturas de vuelo, la cuenta del patrón bucket sale de
   los números de esta fase —es un cálculo, no una medición—: unas 160 lecturas por día de vuelo, de
   unos 175 bytes cada una, dan documentos de unos 28 kB por aeronave y día. Seiscientas veces por
   debajo del límite, y con un crecimiento que termina cada medianoche. El ejercicio 11 lo mide.
3. **Motor.** Si la frontera transaccional cruza agregados en casi cada escritura —mover piezas,
   liberar una aeronave con todo lo instalado—, cada escritura es una transacción multi-documento, y
   Postgres las hace sin replica set y con conflictos por fila, no por documento. Si el polimorfismo
   era la razón, JSONB alcanzó en la sección 4.4.
4. **Arquitectura.** Mongo al lado de Postgres, para la parte cuya unidad de lectura es de verdad el
   documento, alimentado desde la fuente de verdad ([Fase 24](24-poliglota-la-costura.md)). Es el
   peldaño más caro, y el triaje de la [Fase 02](02-las-cinco-preguntas.md) dice cómo subirlo sin
   parar el negocio.

---

## ❓ 7. Las cinco preguntas, respondidas para documental

1. **Frontera transaccional.** Documental funciona cuando **la frontera coincide con el documento**:
   todo lo que tiene que cambiar junto está dentro. En cuanto la frontera cruza documentos, hacen
   falta transacciones multi-documento, con su replica set y sus conflictos por documento. Cóndor la
   cruza en cada movimiento de pieza.
2. **Consultas conocidas.** Documental las necesita a medias: la forma de la ficha se diseña para una
   lectura concreta, y un índice por cada campo nuevo que se quiera consultar (o uno comodín de
   11 MB). Con los números de la sección 4.3: cada clave nueva de `details` que alguien quiera
   filtrar cuesta en Mongo otro índice de unos 4 MB, o el comodín entero; en Postgres, el GIN que ya
   estaba. Una pantalla nueva puede pedir otro modelo.
3. **Unidad de lectura.** **Es la pregunta de esta familia.** Si la unidad es el agregado entero,
   documental gana: 1 documento contra 50 filas. Si la unidad son rebanadas de muchos agregados,
   pierde.
4. **Saltos.** Documental no los resuelve: `$lookup` es un bucle anidado de un salto, y
   `$graphLookup` existe pero no se midió aquí. Para profundidad desconocida, Fases 13–14.
5. **Exactitud o parecido.** Exactitud, como el relacional. Nada que decir a favor ni en contra.

---

## ⚖️ 8. Veredicto honesto: cuándo NO usar documental

> ⚖️ **No uses documental** cuando la frontera transaccional cruza agregados en las escrituras
> frecuentes: cada una será una transacción multi-documento que se bloquea por documento completo.
> **No la uses** cuando la unidad de lectura son rebanadas de muchos registros —el costo por hora
> volada, un informe por modelo—. **No la uses** cuando todos tus documentos tienen las mismas claves:
> eso es una tabla cara. **Y no la uses por el polimorfismo**: medido sobre un millón de piezas, JSONB
> con GIN examina exactamente lo mismo que Mongo y su índice ocupa menos de la mitad que el comodín.
>
> Y ponle la cifra a lo que sí gana, además de la ficha: **la mitad de espacio en disco** para los
> mismos datos, por la compresión de WiredTiger.
>
> **Úsala** cuando la unidad de lectura es de verdad un agregado acotado, que se lee entero y se
> escribe casi siempre entero: la ficha de aeronave, la ficha de componente de Camilo. Ahí la
> diferencia es **1 documento contra 50 filas**, y no hay índice que la compense.

Para Cóndor, el veredicto es mixto, y es el más frecuente: **la ficha es documental; el movimiento de
piezas, no**. Y el costo de tener las dos en motores distintos es el Bloque V.

---

## ⚠️ 9. Errores comunes y diagnóstico

**El documento que no cabe** (E-22 y E-23 en [`a09`](a09-catalogo-de-errores.md)):
`Resulting document after update is larger than 16777216 (code 10334)`, o, si el intento es grande,
`BSONObj size: … is invalid. Size must be between 0 and 16793600(16MB)`. 🩺 `$bsonSize` sobre el
documento en una agregación: si se acerca a 16 777 216, algo embebido crece sin cota. **No hay
parámetro que subir**: el cambio es de modelo.

**Dos escrituras sobre la misma ficha chocan** (E-24): `WriteConflict` (code 112) con la etiqueta
`TransientTransactionError`. 🩺 Si las dos escrituras tocan el mismo `_id`, es esto. La salida corta
es reintentar (`withTransaction` lo hace); la larga es que lo que dos escritores tocan a la vez no
viva en el mismo documento.

**Transacción sin replica set** (E-01). 🩺 `rs.status()` responde `not running with --replSet`.

**La línea base que pierde por un índice que falta.** No da error: da 14 983 filas examinadas donde
debían ser 50. 🩺 En el plan de Postgres, un `Seq Scan` sobre una tabla que la consulta filtra por
una columna. Antes de publicar una comparación, revisa los dos planes, no solo el del motor que
estás estudiando.

---

## 📋 10. Checklist de validación

```text
[ ] Mongo y Postgres están cargados con part-1m (b0b7988921428c1f…)
[ ] Q1: 1 documento en Mongo y 50 filas en Postgres, 1 viaje en los dos
[ ] Q2: 27 865 en los dos; Q3: 28 127 en los dos, y 1 000 000 en Mongo sin índice nuevo
[ ] Sé por qué el GIN de Postgres sirve para Q3 y el índice de Q2 de Mongo no
[ ] La ficha aceptó 90 344 lecturas y tengo los dos mensajes del código 10334
[ ] Moví una pieza entre dos fichas en una transacción, y reproduje el WriteConflict
[ ] Sé por qué el mismo experimento no choca en Postgres, y cuándo sí
[ ] La colección part ocupa 83 MB en Mongo y la tabla 159 MB en Postgres
[ ] La apuesta está escrita antes de la medición, con su resultado
[ ] Puedo decir en una frase cuándo NO usar documental, con los números de esta fase
[ ] M-04 y M-05 están en la bitácora; E-22 a E-24, en a09
```

---

## 🧪 11. Ejercicios (28)

Salvo donde se indique, contra `part-1m` cargado en los dos motores. El código está en
`src/04-documental-romper-y-medir/`.

### 🟢 Fácil — reproducir (1–6)

#### 🟢 Ejercicio 1 — La tabla de la apuesta

Ejecuta `measure.ts --only apuesta` y reproduce las tablas de 4.2 y 4.3.

**Objetivo:** los mismos números, y encontrar en el código dónde se crea cada índice.

#### 🟢 Ejercicio 2 — El plan de Q1 en Postgres

Pide el `EXPLAIN (ANALYZE, BUFFERS)` de la consulta de la ficha.

**Objetivo:** señalar de qué tabla sale cada una de las 50 filas examinadas.

#### 🟢 Ejercicio 3 — El índice que faltaba

Borra `assembly_aircraft` y repite Q1 en Postgres.

**Objetivo:** reproducir las 14 983 filas y encontrar el `Seq Scan` responsable.

#### 🟢 Ejercicio 4 — Otra clave polimórfica

Busca en los dos motores las piezas con `details.blades = 4`.

**Pregunta:** ¿qué índice usa cada uno sin que crees nada nuevo?

#### 🟢 Ejercicio 5 — La rotura, otra vez

Ejecuta `measure.ts --only rotura`.

**Objetivo:** obtener 90 344 lecturas y los dos mensajes del código 10334.

#### 🟢 Ejercicio 6 — La transacción

Ejecuta `measure.ts --only transacciones` y comprueba en `mongosh` que la pieza volvió a su ficha al
terminar.

**Pregunta:** ¿en qué línea del script se devuelve, y qué pasaría si el script fallara antes?

### 🟡 Intermedio — medir de otra forma (7–14)

#### 🟡 Ejercicio 7 — `jsonb_ops` contra `jsonb_path_ops`

Repite Q2 y Q3 en Postgres con un GIN `jsonb_ops`.

**Objetivo:** filas examinadas y tamaño del índice en los dos casos, y una consulta de la Fase 04 que
solo `jsonb_ops` resuelva por índice.

#### 🟡 Ejercicio 8 — El comodín, de cerca

Con el índice `details.$**`, consulta dos claves a la vez (`tboHours` y `blades`).

**Pregunta:** ¿usa el índice para las dos? Compáralo con `@>` de las dos claves en Postgres.

#### 🟡 Ejercicio 9 — La ficha en Postgres, en N+1

Arma la ficha en Postgres como lo hizo `condor_ref` en la Fase 03: una consulta por entidad y una por
pieza.

**Objetivo:** contar los viajes con el arnés, y explicar por qué el problema de los 25 viajes no era
de Mongo.

#### 🟡 Ejercicio 10 — Volumen de la ficha

Predice cuántas lecturas cabrían en una ficha si cada lectura tuviera la mitad de campos. Compruébalo
con `$bsonSize` sin llegar a romperla.

**Objetivo:** tu predicción contra el número medido.

#### 🟡 Ejercicio 11 — Bucket

Guarda las lecturas de una aeronave en documentos de un día cada uno.

**Objetivo:** el tamaño del documento más grande y cuántos documentos necesita un año de vuelo.

#### 🟡 Ejercicio 12 — El conflicto, en Postgres

Reproduce el experimento de 4.5 en Postgres: dos transacciones que actualizan dos piezas distintas de
la misma aeronave.

**Pregunta:** ¿chocan? ¿Qué cambia si las dos actualizan la misma pieza?

#### 🟡 Ejercicio 13 — `withTransaction` y el reintento

Provoca el `WriteConflict` dentro de `withTransaction` en lugar de con transacciones manuales.

**Pregunta:** ¿qué ves ahora? Cuenta cuántos intentos hizo la segunda transacción.

#### 🟡 Ejercicio 14 — El diff del oplog

Actualiza tres campos de una pieza embebida en una sola operación y lee la entrada del oplog.

**Objetivo:** explicar la estructura del `diff` y cuánto ocupa comparado con la ficha.

### 🟠 Difícil — diagnosticar y decidir (15–22)

#### 🟠 Ejercicio 15 — La apuesta en otra clave

Formula tú una apuesta para una consulta polimórfica con rango (`details.hoursSinceOverhaul > 2000`),
**escríbela antes** y mídela en los dos motores.

**Objetivo:** la apuesta, el número y si la ganaste.

#### 🟠 Ejercicio 16 — El rango en el GIN

La consulta del ejercicio 15 no se puede escribir con `@>`.

**Pregunta:** ¿qué índice de Postgres la resuelve, y qué índice de Mongo? Compara tamaños.

#### 🟠 Ejercicio 17 — La ficha con historial acotado

Embebe en la ficha solo las **últimas 20** órdenes de trabajo, con `$push` y `$slice`.

**Objetivo:** demostrar que la ficha deja de crecer, y decidir qué pantalla pierde con ese modelo.

#### 🟠 Ejercicio 18 — Liberar una aeronave

La liberación al servicio lee la ficha y marca como verificadas todas sus piezas en `condor_ref.part`.

**Pregunta:** ¿cuántos documentos toca? Escríbela como una transacción y cuenta sus viajes.

#### 🟠 Ejercicio 19 — La frontera de Cóndor

Enumera las cinco escrituras más frecuentes de Cóndor y di cuántos documentos toca cada una en
`condor_doc`.

**Objetivo:** estimar qué fracción de las escrituras necesitaría una transacción multi-documento.

#### 🟠 Ejercicio 20 — El reparto con 16 MB

Diseña un modelo donde la ficha tenga las lecturas de las últimas 24 horas y el resto viva aparte.

**Pregunta:** ¿cuántas escrituras cuesta cada lectura nueva, y qué pasa si una falla entre las dos?

#### 🟠 Ejercicio 21 — La línea base, a prueba

Busca otra consulta de esta fase donde Postgres, **mal configurado**, pierda por mucho.

**Objetivo:** el número malo, el número bueno y el índice o la reescritura que los separa.

#### 🟠 Ejercicio 22 — Validar lo regulatorio

Barlovento no puede dejar vacíos los campos regulatorios de una carga peligrosa. Escribe la validación
en Mongo (`$jsonSchema`) y en Postgres (`CHECK` sobre JSONB).

**Pregunta:** ¿cuál es más fácil de mantener cuando cambia la norma?

### 🔴 Muy difícil — autopsias y romper (23–28)

#### 🔴 Ejercicio 23 — Romper Postgres

Lleva una fila de `part` con un `details` JSONB creciente hasta que falle.

**Objetivo:** el volumen exacto y el mensaje literal. **Predice antes** si Postgres aguanta más o
menos que los 16 MB de Mongo, y por qué.

#### 🔴 Ejercicio 24 — La apuesta que yo perdí

Encuentra una forma de modelar la ficha en Postgres que examine menos de 50 filas para Q1.

**Pregunta:** ¿qué pierdes a cambio? Mídelo.

#### 🔴 Ejercicio 25 — El sistema de Camilo, medido

Con lo aprendido en las dos fases, estima cuántas transacciones multi-documento por día habría
necesitado el sistema de Camilo para no disolver la frontera.

**Objetivo:** una cifra justificada, y la pregunta que habría cambiado la decisión.

#### 🔴 Ejercicio 26 — Dos técnicos, cien fichas

Escribe una carga donde 32 técnicos actualizan piezas de 100 fichas al azar durante un minuto, con
transacciones.

**Objetivo:** contar los `WriteConflict` y los reintentos. Repite con las piezas en `condor_ref.part` y
compara.

#### 🔴 Ejercicio 27 — El veredicto para Barlovento

Aplica el veredicto de esta fase al encargo de [`h-mini-01`](h-mini-01-documental-barlovento.md), sin
hacerlo entero.

**Pregunta:** ¿la ficha de carga es documental o JSONB? Defiéndelo con una de las cinco preguntas.

#### 🔴 Ejercicio 28 — La autopsia de esta fase

Escribe la autopsia de un equipo que eligió Mongo **por el polimorfismo**.

**Objetivo:** los cinco pasos de la Fase 00, usando los números de 4.3 como factura.

---

## 📚 12. Referencias

> ⚠️ Las URLs y sus contenidos cambian, y la documentación de MongoDB cubre la última versión. Esta
> fase se verificó con MongoDB 8.0.20 y PostgreSQL 18.6.

- **Transacciones en MongoDB** — https://www.mongodb.com/docs/manual/core/transactions/ — qué exigen, y
  los errores transitorios.
- **Límites** — https://www.mongodb.com/docs/manual/reference/limits/ — el tamaño máximo de un
  documento.
- **Índices comodín** — https://www.mongodb.com/docs/manual/core/indexes/index-types/index-wildcard/
- **arrayFilters** — https://www.mongodb.com/docs/manual/reference/operator/update/positional-filtered/
- **Patrón bucket** — https://www.mongodb.com/blog/post/building-with-patterns-the-bucket-pattern — el
  fabricante lo explica con series temporales.
- **Indexación de JSONB en PostgreSQL** — https://www.postgresql.org/docs/current/datatype-json.html#JSON-INDEXING

**Orden sugerido:** [`a07`](a07-postgres-linea-base.md) antes de la sección 4; los límites antes de la
5; las transacciones durante la 4.5.

---

## 🏁 13. Resultado de la fase

Mediste Mongo contra un Postgres bien jugado sobre los mismos bytes, y el resultado dice dos cosas a la
vez: **en el polimorfismo, empate exacto**, y en la ficha, **1 documento contra 50 filas** a favor de
Mongo. Rompiste la ficha a las 90 344 lecturas, con sus dos mensajes. Y viste el precio del documento
como unidad: se lee de una vez, y también se bloquea de una vez.

> **La señal de que quedó bien:** *"Puedo decir por qué elegiría Mongo para la ficha y no para el
> movimiento de piezas, y lo puedo decir con los números de esta fase."*

> 🏷️ **Tag:** `fase-04-documental-romper-y-medir` · prefijo de commit `f04:`
