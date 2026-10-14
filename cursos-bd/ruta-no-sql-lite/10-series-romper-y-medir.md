# ⏱️ Fase 10 — Series temporales: el rival es Postgres, y la tarjeta de cinco medidas

> **Curso:** Ruta NoSQL Lite · Fase 10 de 26 · Bloque II — Leer de otra forma · **10 h**
> **Familia:** series temporales · **Motor:** TimescaleDB 2.30.1 sobre PostgreSQL 18.6, imagen con
> Timescale License `timescale/timescaledb@sha256:9dede0e3ccc0…`
> **Línea base:** PostgreSQL 18.6 `pgvector/pgvector@sha256:2ba9ca5f2e7d…` con **particionado declarativo**
> por mes (`reading_part`, base `series_base`)
> **Entorno de ejecución:** TypeScript
> **Volumen:** `reading_x10`, 50 M lecturas (ampliación ×10 de `reading-5m`, `8dc486dea089…`), la misma
> huella de las Fases 07 y 09; la rotura, sobre las 5 M reales
> **Depende de:** Fase 09 · **Habilita:** Fase 11
> **Apéndices de apoyo:** [`a02`](a02-compose-de-la-ruta.md), [`a04`](a04-el-arnes-de-medida.md),
> [`a09`](a09-catalogo-de-errores.md), [`a10`](a10-licencias-y-riesgo.md)
> **Fecha de verificación ejecutada:** 07/10/2026, en macOS arm64
> **Objetivo:** poner a Timescale contra Postgres particionado en cinco medidas de forma, separar lo que
> resuelve Postgres solo de lo que justifica la extensión, y encontrar el número de chunks al que la
> hypertable deja de poder ni siquiera borrarse.

---

## 🧭 1. Dónde estamos

La [Fase 09](09-series-levantar-y-modelar.md) midió la hypertable contra una tabla normal con buenos
índices y encontró lo que el marketing de la familia no dice: **para leer, empatan**. Las diferencias
aparecieron al borrar el año viejo y al mantener el resumen diario. Pero aquella tabla normal no era el
rival de verdad. Lo que haría alguien que conoce Postgres no es una tabla con índice en la fecha: es
**particionar por tiempo**, que Postgres trae sin extensiones desde la versión 10.

Esta fase pone ese rival en la mesa. **El rival aquí es Postgres, y ese es el punto**: Timescale es una
extensión de Postgres, así que la pregunta no es *"¿Timescale o una base relacional?"* sino *"¿esta
extensión me da algo que no tenga ya, y vale lo que cuesta?"*. Y cuesta dos cosas: un componente más que
mantener, y una licencia que no es la de Postgres.

Después de la apuesta viene lo que la familia promete que no pasa —datos que llegan tarde a un período
ya comprimido— y lo que se rompe cuando se le pide demasiado al modelo: chunks tan pequeños que el motor
ya no puede ni borrar la tabla.

---

## 🎯 2. Objetivos de esta fase

1. Particionar los mismos 50 M por mes en Postgres puro y medir la tarjeta de cinco medidas contra la
   hypertable comprimida: lectura de la flota, lectura de una aeronave, tamaño, mantenimiento del
   resumen y borrado del primer año.
2. Resolver la apuesta con esa tarjeta, y decir **cuáles de las cinco gana Postgres sin extensión**.
3. Medir el *backfill* de dos meses tardíos sobre chunks comprimidos.
4. Medir la cardinalidad en la compresión —por aeronave o por vuelo— y llevar el tamaño de chunk hasta
   que el motor falla.
5. Escribir el veredicto con la licencia en la balanza.

> 🧰 **Miniproyecto de esta familia:** [Voltaria — el `DELETE` que se come el lunes de
> facturación](h-mini-04-series-voltaria.md). Opcional, fuera de las horas del curso, y no entra a la
> bitácora.

---

## 🪞 3. La apuesta

> 🪞 **Apuesta antes de ejecutar.** Creo que **el particionado declarativo de Postgres a secas llega al
> 80 % del rendimiento de Timescale y me ahorra una extensión.** Como este curso no mide velocidad, "80 %"
> se lee así: en una tarjeta de cinco medidas de forma —páginas para la flota en un mes, páginas para una
> aeronave en 60 días, tamaño de los cinco años, lecturas para mantener el resumen diario tras un vuelo
> nuevo y WAL para borrar el primer año—, **Postgres queda a 1,25× o menos de Timescale en al menos
> cuatro**.

Escrita en el temario el 30/09/2026 y traducida a la tarjeta el 07/10/2026, antes de ejecutar
`scorecard.ts`. **Resultado, en la sección 4.7: perdida. Postgres llega en dos de cinco**, y las dos que
gana son exactamente las que la familia vende como suyas.

---

## 📐 4. La medición contra la línea base

### 4.1 Tres tablas con los mismos 50 M

Desde `src/`, después de `load.ts` de la Fase 09 (que recarga las dos bases con la huella de siempre):

```bash
docker compose -f lab/compose.yaml exec -T series psql -U postgres -d condor < 09-series-levantar-y-modelar/rollups.sql
docker compose -f lab/compose.yaml exec -T series psql -U postgres -d condor < 10-series-romper-y-medir/compress.sql
node 10-series-romper-y-medir/partition.ts
```

```text
reading_part: 61 particiones · 7629 MB con índices · 701080 lecturas en DEFAULT · cargada en 178.0 s
```

`partition.ts` crea la tabla particionada con **un bucle que escribe 60 `CREATE TABLE … PARTITION OF`**,
uno por mes, más una partición `DEFAULT`. Es el trabajo que Timescale hace solo al insertar, y aquí se
ve escrito. La `DEFAULT` recogió **701 080 lecturas**: las del futuro que la Fase 07 encontró en el
generador, ampliadas ×10. Timescale les había creado diez chunks sin preguntar; Postgres las metió en el
cajón de lo que no tiene mes, y eso tiene consecuencias (sección 9).

En el otro lado, la hypertable de la Fase 09 con sus dos agregados continuos y **222 chunks comprimidos** (en esa corrida; la de la Fase 09 dio 223),
todo lo anterior a 2026, en 49,4 s. Es la hypertable **tal como se usaría**, no la de la Fase 09 recién
cargada, y la diferencia importa en la sección 4.2.

### 4.2 Leer: chunks contra particiones

```bash
node 10-series-romper-y-medir/scorecard.ts --with-retention
```

> 📐 **Medición — leer por tiempo, con la compresión puesta** · 50 M · TimescaleDB 2.30.1 (chunks de 7
> días, comprimidos antes de 2026) · PostgreSQL 18.6 particionado por mes · verificado el 07/10/2026
>
> | Consulta | Timescale | Postgres particionado |
> |---|---|---|
> | la flota, marzo de 2025 | 1460 lotes comprimidos · **3970 páginas** · 5 chunks | 839 270 filas · **9611 páginas** · 1 partición |
> | `HC-2157`, 60 días | 19 lotes · **343 páginas** · 10 chunks | 9666 filas · **161 páginas** · 3 particiones |
>
> Reproducir: `node 10-series-romper-y-medir/scorecard.ts` (desde `src/`)

Con la partición del mes exacto, Postgres lee **una sola tabla** para la flota, sin bordes: 9611 páginas,
menos que las 10 733 que leía la hypertable **sin** comprimir en la Fase 09. Si la apuesta se jugara sin
compresión, la ganaría en lectura. Pero comprimida, Timescale lee **3970**: el chunk comprimido guarda
cada columna aparte en lotes de hasta mil lecturas por aeronave, y la consulta solo descomprime las
columnas que nombra. Es la Fase 07 otra vez —leer columnas, no filas— dentro de Postgres.

Para una aeronave, al revés: Postgres lee **161 páginas** con su índice en tres particiones; Timescale,
**343** recorriendo los índices de diez chunks comprimidos. Leer de a poco es terreno del B-tree.

Una nota de método: en la hypertable comprimida, el arnés cuenta como "examinadas" las filas de lotes
comprimidos —1460 y 19—, no lecturas, porque eso es lo que recorre el plan. Por eso la comparación justa
de esta tabla son las páginas.

### 4.3 Borrar: `drop_chunks` contra `DROP TABLE` de una partición

> 📐 **Medición — borrar el primer año** · el mismo volumen, corte en el 01/10/2022 · verificado el
> 07/10/2026
>
> | | Timescale | Postgres particionado |
> |---|---|---|
> | lo que se borra | 52 chunks | 12 particiones |
> | WAL | 3,5 MiB | **0,5 MiB** |
>
> (Referencia de la Fase 09, tabla sin particionar: `DELETE` de 8 823 630 filas, 1254,2 MiB.)

Aquí **gana Postgres, y por mucho**: tirar doce tablas escribe menos que tirar 52. Y es la medida que
importa de la Fase 09: lo que hundía a la tabla normal era el `DELETE`, y el particionado declarativo lo
resuelve **sin ninguna extensión**. Es lo que el miniproyecto de Voltaria tiene que poder decir con estas
mismas palabras.

### 4.4 Tamaño: comprimido contra sin comprimir

```bash
docker compose -f lab/compose.yaml exec -T series psql -U postgres -d condor < 10-series-romper-y-medir/size_by_year.sql
docker compose -f lab/compose.yaml exec -T base psql -U postgres -d series_base < 10-series-romper-y-medir/size_by_year_base.sql
```

> 📐 **Medición — tamaño por año, con índices** · después de borrar el primer año · verificado el
> 07/10/2026
>
> | Año | Timescale sin comprimir → comprimido | Postgres particionado |
> |---|---|---|
> | 2022 (oct–dic) | 393 → **25** MiB | 340 MiB |
> | 2023 | 1479 → **92** MiB | 1361 MiB |
> | 2024 | 1633 → **102** MiB | 1512 MiB |
> | 2025 | 1633 → **101** MiB | 1509 MiB |
> | 2026 (sin comprimir los últimos 22 chunks) | 1719 → 707 MiB | 1473 MiB + 89 de `DEFAULT` |
> | **total, antes de borrar** | **1090,7 MiB** | **7631,0 MiB** |

Un año completo de lecturas comprimido ocupa **unos 100 MiB contra 1500**: dieciséis veces menos. No hay
nada equivalente en Postgres para enteros —TOAST comprime valores grandes, no columnas de números—, y
esta es la mitad del argumento de la extensión. La otra mitad viene ahora.

### 4.5 Resumir: el agregado continuo contra la vista y contra el resumen a mano

En la Fase 09, la vista materializada perdía por cuatro órdenes de magnitud. Pero un Postgres bien
jugado no refresca la vista entera: guarda el resumen **en una tabla** y lo recalcula solo para la
ventana que cambió, con un `DELETE` y un `INSERT … SELECT` que la partición y el índice dejan barato.
`scorecard.ts` mide las tres formas tras el mismo vuelo nuevo de 90 minutos:

| Forma de mantener el diario | Lecturas leídas |
|---|---|
| Timescale, agregado continuo | **2420** |
| Postgres, `REFRESH MATERIALIZED VIEW` | 50 000 090 |
| Postgres, resumen en tabla con la ventana de tres días a mano | **112 560** |

El resumen a mano mejora la vista 444 veces y sigue leyendo **46 veces más** que el agregado continuo. La
diferencia no es de motor sino de información: Timescale **anotó qué tramo invalidó** el vuelo nuevo y
recalcula ese tramo; tu job recalcula la ventana entera porque no sabe qué cambió dentro. Llegar a 2420
pediría escribir también el registro de invalidaciones, con un disparador por inserción. **Es el código
que la extensión ya trae escrito**, y el ejercicio 21 lo intenta.

### 4.6 El *backfill*: dos meses que llegan tarde

La promesa de la familia es que los datos llegan en orden. La realidad es que un grabador a veces se
descarga semanas después. `backfill.ts` mete dos meses de lecturas de una aeronave tardía —marzo y abril
de 2025, ya comprimidos— en los dos motores:

```bash
node 10-series-romper-y-medir/backfill.ts
```

```text
timescale filas 9818 · WAL 3.0 MiB · 0.1 s · chunks a medias 9
postgres  filas 9818 · WAL 2.3 MiB · 0.0 s
timescale recomprimir · WAL 2.1 MiB · 0.0 s · chunks a medias 0
```

Con este tamaño, **el *backfill* es barato en los dos**: 9818 filas, un poco más de WAL en Timescale, y
nueve chunks que quedan con filas sin comprimir al lado hasta que se recomprimen (2,1 MiB más). No toca el
límite de la Fase 09 porque **insertar no descomprime**: las filas nuevas van al lado del *columnstore*. El
problema aparece si el *backfill* trae **correcciones** de filas que ya existen —un `UPDATE`, no un
`INSERT—`, y eso ya está medido: E-44 de la Fase 09.

### 4.7 La tarjeta y el resultado de la apuesta

```text
la tarjeta (Postgres / Timescale; la apuesta pide ≤ 1,25 en cuatro de cinco)
  páginas · la flota, marzo de 2025        3970.0 ·     9611.0 páginas   → 2.42× ✗
  páginas · HC-2157, 60 días                343.0 ·      161.0 páginas   → 0.47× ✓
  tamaño de los cinco años                 1090.7 ·     7631.0 MiB       → 7.00× ✗
  lecturas para mantener el diario         2420.0 ·   112560.0 lecturas  → 46.51× ✗
  WAL de borrar el primer año                 3.5 ·        0.5 MiB       → 0.13× ✓
  Postgres llega en 2 de 5
```

> 🪞 **Resultado: perdida.** Postgres particionado queda a 1,25× o menos en **dos de cinco**: lee menos
> para una aeronave (0,47×) y escribe menos para borrar un año (0,13×). Pierde el tamaño (**7,0×**), el
> mantenimiento del resumen (**46,5×**, y 20 661× con la vista materializada) y la lectura de la flota
> (2,42×), y **las tres pérdidas salen de lo mismo: compresión por columnas y agregados que saben qué
> cambió.**

Lo interesante de perder así es lo que separa. **La retención la resuelve Postgres sin extensión**, mejor
que Timescale: era el dolor urgente de la Fase 09 y no necesita nada más. **La compresión y los roll-ups
incrementales son lo que justifica la extensión**, y son otro problema con otra factura —incluida la
licencia—. Una empresa que solo necesite borrar el pasado no tiene que instalar nada.

### 4.8 Lo que no se midió

**La ingesta concurrente** de muchas aeronaves a la vez: todo se cargó desde un proceso. **Un volumen
donde el chunk activo ya no cabe en memoria.** **Postgres con una extensión de compresión columnar** de
terceros, que existe y no es la línea base de este curso. Y **la latencia**, por diseño.

---

## 💥 5. El punto de rotura

La cardinalidad que mata tiene dos caras, y se midieron las dos sobre las 5 M lecturas reales.

**La primera es la de la compresión: qué identifica una serie.** Comprimir agrupando por aeronave
(17 series) o por aeronave y vuelo (62 486):

```bash
node 10-series-romper-y-medir/cardinality.ts --segmentby
```

```text
segmentby aircraft             600.9 MiB → 70.6 MiB · lotes comprimidos 8490 · comprimir 5.1 s · HC-2157 60 días: páginas 163, examinadas 19
segmentby aircraft, flight_id  600.9 MiB → 93.3 MiB · lotes comprimidos 63021 · comprimir 6.5 s · HC-2157 60 días: páginas 54, examinadas 119
```

Por vuelo, **siete veces más lotes y un 32 % más de disco**: cada lote lleva su propia cabecera y sus
mínimos y máximos, y un vuelo de 80 minutos llena un lote de 80 filas en vez de mil. A cambio, la
consulta de una aeronave en 60 días leyó **menos páginas** (54 contra 163), porque los lotes pequeños
traen menos lecturas ajenas a la ventana. No es una rotura: es un costo que crece con la cardinalidad, y
que con 140 aeronaves y miles de parámetros por segundo deja de ser un 32 %.

**La segunda es la que rompe: chunks diminutos.** `cardinality.ts --chunks` carga las mismas 5 M con
chunks cada vez más pequeños y corre dos consultas:

```bash
node 10-series-romper-y-medir/cardinality.ts --chunks --intervals "7 days,1 day,6 hours"
```

> 💥 **Rotura — chunks diminutos** · `reading`, 5 M · TimescaleDB 2.30.1, `max_locks_per_transaction` 128 ·
> verificado el 07/10/2026
>
> ```text
> chunk de 7 days      271 chunks · carga 22.6 s · cinco años chunks en el plan    271 · planificar 14 ms · ejecutar 67 ms
> chunk de 1 day      1894 chunks · carga 27.3 s · cinco años chunks en el plan   1894 · planificar 117 ms · ejecutar 425 ms
> chunk de 6 hours  el INSERT de una vez (7573 chunks) falla: ERROR: out of shared memory · HINT: You might need to increase "max_locks_per_transaction".
> chunk de 6 hours  cargado un mes por transacción
> chunk de 6 hours    7573 chunks · carga 48.2 s · 60 días    chunks en el plan    240 · planificar 19 ms · ejecutar 10 ms
> chunk de 6 hours    7573 chunks · cinco años: ERROR: could not resize shared memory segment "/PostgreSQL.2591385338" to 73551744 bytes: No space left on device · HINT: undefined
> chunk de 6 hours  DROP TABLE: ERROR: out of shared memory · HINT: You might need to increase "max_locks_per_transaction".
> chunk de 6 hours  borrada por tandas de tres meses
> ```

A **7573 chunks** el modelo se rompe por tres lados. **El `INSERT` de las 5 M de una vez falla**, porque
una transacción toma un candado por chunk que toca y la tabla de candados no da más. **La consulta de cinco
años falla**, aquí por otra memoria: el plan en paralelo sobre 7573 chunks pide 70 MB de memoria compartida
y el contenedor `series` tiene los 64 MB de `/dev/shm` que Docker da por defecto (el mismo límite que la
Fase 16 subió para `base`, E-35). Y lo peor: **la tabla no se puede borrar**, porque `DROP TABLE` también
toma un candado por chunk. Hay que borrarla por tandas con `drop_chunks`. Los mensajes literales están en
[`a09`](a09-catalogo-de-errores.md) como E-45, y el de la memoria compartida, en E-35. Con 1 hora (unos 45 000
chunks) no se midió: con 6 ya está roto.

La lectura de los números de arriba es la otra mitad de la rotura: **planear cuesta en proporción a los
chunks**, 14 ms con 271 y 117 ms con 1894, **antes de leer una fila**. El chunk diminuto no da nada a
cambio: la consulta de 60 días tocó 240 chunks para lo que con 7 días eran 10.

**Lo que hay que cambiar para salir:** el intervalo del chunk se elige para que el chunk activo, con sus
índices, quepa en memoria, no para que sea pequeño; si ya está creado, `set_chunk_time_interval` afecta a
los chunks nuevos, y los viejos se reagrupan copiando a una hypertable nueva. Subir
`max_locks_per_transaction` mueve el borde, no lo quita.

---

## 🚑 6. Salir de aquí

Cuando una serie temporal ya duele, en orden de costo:

1. **Configuración.** El intervalo del chunk, `segmentby` por la columna por la que se filtra —no por la
   de más cardinalidad—, la edad a la que se comprime y la ventana de refresco de los agregados. Ninguna
   requiere cambiar de motor.
2. **Modelo.** Si el dolor es **borrar el pasado**, particionar por tiempo en Postgres puro lo resuelve
   (sección 4.3): 0,5 MiB de WAL para un año. Si el dolor es **corregir el pasado**, el modelo tiene que
   corregir al leer (Fase 09, sección 8), no reescribir lo comprimido.
3. **Motor.** Si el dolor es **el tamaño o el resumen**, ahí está la extensión: dieciséis veces menos disco
   por año y 46 veces menos lectura para mantener el diario. Si no es ninguno de los dos, no hace falta.
4. **Arquitectura.** Cuando las lecturas son de las 140 aeronaves y ya no caben en un nodo, ninguna de
   las dos alcanza: es la columnar ancha del Bloque IV.

---

## ❓ 7. Las cinco preguntas, respondidas para series temporales

1. **Frontera transaccional.** Débil y local: una lectura es un hecho aislado. Pero ojo con lo que
   arrastra: el *backfill* y las correcciones tocan chunks comprimidos y agregados, y el resumen puede
   quedar un tramo atrás del dato crudo hasta el próximo refresco.
2. **Consultas conocidas.** Sí, y por tiempo: rango, resumen y borrado del pasado. **Es la pregunta de
   esta familia**: si tus consultas no tienen el tiempo como primera condición, el chunk no te ayuda.
3. **Unidad de lectura.** Un rango de tiempo de una serie o de todas. Una aeronave en pocos días la lee
   mejor un B-tree; la flota en un mes, la compresión por columnas.
4. **Saltos.** Ninguno.
5. **Exactitud o parecido.** Exactitud, con una salvedad: un resumen es exacto **hasta su último
   refresco**.

---

## ⚖️ 8. Veredicto honesto: cuándo NO usar esto

> ⚖️ **No instales la extensión para borrar el pasado.** Particionar por mes en Postgres escribe **0,5 MiB**
> de WAL para tirar un año, menos que `drop_chunks` (3,5 MiB), sin componentes nuevos ni otra licencia.
> **No la uses si tus datos se corrigen**: corregir un mes de la flota comprimida choca con el límite de
> 100 000 filas descomprimidas y escribe un 66 % más que la tabla normal (Fase 09). **No la uses si lees de
> a una serie en ventanas cortas**: el B-tree de Postgres lee 161 páginas donde la hypertable comprimida lee
> 343. **Y no hagas chunks pequeños**: a 7573, la tabla no se puede ni borrar.
>
> **Úsala** cuando el dato **llega en orden, no se corrige y se consulta por rango**, y además pesa: un año
> de lecturas en **100 MiB contra 1500**, y el resumen diario mantenido con **2420 lecturas contra 112 560**
> del mejor Postgres a mano.

**La licencia va en la balanza** ([`a10`](a10-licencias-y-riesgo.md)). Los agregados continuos y la
compresión —justo lo que ganó en la tarjeta— son **Timescale License**, *source-available*: se pueden usar
internamente y para servicios propios, pero no ofrecer TimescaleDB como servicio de base de datos a
terceros. La imagen `-oss`, con licencia Apache, no los trae. **El particionado declarativo de Postgres no
tiene esa restricción**, y por eso la retención —lo único que Postgres resuelve igual o mejor— es también lo
único que no pide aceptar otra licencia.

Para Cóndor: las 17 aeronaves del dataset —30 en la empresa— caben en Postgres particionado si lo que
Édinson necesita es borrar el pasado y mirar una aeronave. **Si quiere el tablero de la flota con años de
historia a un clic, comprimido y resumido**, la extensión se gana su sitio, con la licencia leída y
aceptada.

---

## ⚠️ 9. Errores comunes y diagnóstico

**Demasiados chunks en una transacción** (E-45 en [`a09`](a09-catalogo-de-errores.md)):

```text
ERROR: out of shared memory
HINT: You might need to increase "max_locks_per_transaction".
```

🩺 No es memoria de datos: es la tabla de candados, uno por chunk y por índice que toca la transacción.
`SELECT count(*) FROM timescaledb_information.chunks WHERE hypertable_name = '…'` dice cuántos hay. Salir:
transacciones más chicas, chunks más grandes, y `drop_chunks` por tandas si ya no se puede ni borrar.

**La memoria compartida del contenedor** (E-35, que ya estaba por la Fase 16): `could not resize shared
memory segment "/PostgreSQL.…" to 73551744 bytes: No space left on device`. 🩺 `df -h /dev/shm` en el
contenedor `series` dice 64M; el servicio `base` lleva `shm_size` y `series` no. Para una consulta paralela
sobre miles de chunks, `shm_size` en el compose o `SET max_parallel_workers_per_gather = 0`.

**La partición del mes que no se puede crear** (E-46):

```text
ERROR:  updated partition constraint for default partition "reading_part_default" would be violated by some row
```

🩺 La `DEFAULT` ya tiene filas de ese mes —aquí, las lecturas del futuro—. Postgres no las mueve solo: hay
que sacarlas de la `DEFAULT` (`DETACH`, mover, volver a adjuntar) antes de crear la partición. Es la razón
por la que una `DEFAULT` llena es una deuda, y por la que Timescale crea el chunk que haga falta al
insertar.

**El `backfill` que no aparece en el resumen.** Sin mensaje: los agregados continuos solo refrescan su
ventana. 🩺 Si las lecturas tardías caen fuera de la ventana de la política, hay que llamar a
`refresh_continuous_aggregate` con su rango.

**Lotes comprimidos que parecen filas.** En un plan sobre chunks comprimidos, las filas "examinadas" son
lotes de hasta mil lecturas (1460 para un mes de la flota). 🩺 Compara páginas, no filas, entre una
hypertable comprimida y una tabla.

---

## 📋 10. Checklist de validación

```text
[ ] reading_part tiene 61 particiones, y sé por qué la DEFAULT tiene 701 080 lecturas
[ ] La flota en un mes: 3970 páginas en Timescale comprimido, 9611 en Postgres particionado
[ ] Una aeronave en 60 días: 343 contra 161 páginas, y sé por qué gana el B-tree
[ ] Borrar el primer año: 52 chunks y 3,5 MiB contra 12 particiones y 0,5 MiB
[ ] Un año completo: ~100 MiB comprimido contra ~1500 MiB en Postgres
[ ] Mantener el diario: 2420 lecturas contra 112 560 del resumen a mano y 50 M de la vista
[ ] La apuesta está escrita antes, con la tarjeta, y su resultado es 2 de 5
[ ] Provoqué E-45 con chunks de 6 horas, y sé por qué DROP TABLE también falla
[ ] Sé qué parte de lo que gana Timescale es Timescale License
[ ] M-25 a M-27 en la bitácora, la apuesta 6 en su tabla, E-45 y E-46 en a09
```

---

## 🧪 11. Ejercicios (26)

Desde `src/`, con las dos bases recargadas por `load.ts`, `rollups.sql`, `compress.sql` y `partition.ts`.
`scorecard.ts --with-retention` borra el primer año.

### 🟢 Fácil — reproducir (1–6)

#### 🟢 Ejercicio 1 — La tarjeta

Corre `scorecard.ts` sin `--with-retention`.

**Objetivo:** las cuatro primeras filas de la tarjeta, y cuál esperas que cambie en otra máquina.

#### 🟢 Ejercicio 2 — Las particiones

Lista las particiones de `reading_part` con su tamaño.

**Pregunta:** ¿qué mes es el más grande, y por qué la `DEFAULT` no está vacía?

#### 🟢 Ejercicio 3 — El tamaño por año

Corre los dos `size_by_year`.

**Objetivo:** la razón de compresión de cada año completo.

#### 🟢 Ejercicio 4 — El *backfill*

Corre `backfill.ts`.

**Objetivo:** los nueve chunks a medias, y comprobar que quedan en cero tras recomprimir.

#### 🟢 Ejercicio 5 — Lotes contra filas

Con `EXPLAIN (ANALYZE, BUFFERS)`, corre la consulta de la flota en un mes sobre la hypertable comprimida.

**Pregunta:** ¿qué nodo descomprime, y cuántos lotes lee?

#### 🟢 Ejercicio 6 — El borde

Corre `cardinality.ts --chunks --intervals "1 day"`.

**Objetivo:** chunks, tiempo de planificar la consulta de cinco años, y compararlo con 7 días.

### 🟡 Intermedio — medir de otra forma (7–13)

#### 🟡 Ejercicio 7 — Particiones semanales

Repite `partition.ts` con particiones de 7 días.

**Objetivo:** cuántas particiones, y cómo cambian las dos lecturas y el borrado de la tarjeta.

#### 🟡 Ejercicio 8 — Sin compresión

Corre la tarjeta contra la hypertable antes de `compress.sql`.

**Pregunta:** ¿cuántas medidas gana Postgres con la hypertable sin comprimir?

#### 🟡 Ejercicio 9 — `segmentby` por nada

Comprime una copia sin `segmentby`.

**Objetivo:** tamaño y páginas de la consulta de una aeronave, contra los dos casos de la sección 5.

#### 🟡 Ejercicio 10 — La `DEFAULT`, vaciada

Saca de la `DEFAULT` las lecturas de octubre de 2026 y crea su partición.

**Objetivo:** los pasos que evitan E-46, en orden, y cuántas filas se movieron.

#### 🟡 Ejercicio 11 — El *backfill* que corrige

Repite `backfill.ts` con un `UPDATE` de esas mismas lecturas en lugar de un `INSERT`.

**Objetivo:** cuántas filas descomprime, y a qué tamaño de *backfill* aparece E-44.

#### 🟡 Ejercicio 12 — `max_locks_per_transaction`

Sube el parámetro a 512 en el contenedor `series` y repite los chunks de 6 horas.

**Pregunta:** ¿qué falla ahora, y a qué número de chunks crees que vuelve a fallar?

#### 🟡 Ejercicio 13 — `shm_size` para `series`

Añade `shm_size` al servicio `series` y repite la consulta de cinco años con 7573 chunks.

**Objetivo:** si termina, cuánto tarda en planear, y qué error aparece en su lugar si no.

### 🟠 Difícil — diagnosticar y decidir (14–21)

#### 🟠 Ejercicio 14 — Predecir la tarjeta con 140 aeronaves

Antes de medir, predice cómo cambia cada fila de la tarjeta con ocho veces más aeronaves.

**Objetivo:** tu predicción por escrito, y medirla con una ampliación ×80 de una sola copia por aeronave.

#### 🟠 Ejercicio 15 — El planificador sin particiones

Desactiva `enable_partition_pruning` y repite la lectura de la flota.

**Objetivo:** cuántas particiones toca, y qué hace por ti el *pruning* que no ves en la consulta.

#### 🟠 Ejercicio 16 — La política que comprime tarde

Cambia la política a 7 días y simula el paso del tiempo insertando un mes nuevo.

**Pregunta:** ¿qué pasa con los vuelos que llegan con tres días de retraso?

#### 🟠 Ejercicio 17 — El resumen que se queda atrás

Inserta un vuelo de hace 40 días en las dos bases y consulta los dos resúmenes.

**Objetivo:** cuál lo refleja, cuál no, y qué tendrías que cambiar en cada uno.

#### 🟠 Ejercicio 18 — Cardinalidad estrecha

Construye sobre las 5 M un modelo estrecho —una fila por aeronave, parámetro e instante (35 M filas)— y
comprímelo por `(aircraft, parameter)`.

**Objetivo:** tamaño, lotes y la consulta de 60 días del EGT, contra el modelo ancho.

#### 🟠 Ejercicio 19 — Reagrupar chunks

Pasa la hypertable de chunks de 1 día a chunks de 7 días sin perder datos.

**Objetivo:** los pasos, el tiempo, y cuántos chunks quedan.

#### 🟠 Ejercicio 20 — La licencia, aplicada

Cóndor quiere vender a otros talleres un servicio de "tablero de flota" basado en su base de series.

**Pregunta:** ¿qué dice la Timescale License de ese caso, según [`a10`](a10-licencias-y-riesgo.md), y qué
parte de esta fase seguiría disponible con la imagen `-oss`?

#### 🟠 Ejercicio 21 — Invalidaciones a mano

Escribe en Postgres un disparador que anote el día y la aeronave de cada inserción, y un job que solo
recalcule esos días.

**Objetivo:** cuántas lecturas lee tu job tras el vuelo de 90 minutos, contra 2420 y 112 560.

### 🔴 Muy difícil — romper y autopsias (22–26)

#### 🔴 Ejercicio 22 — La autopsia del chunk de una hora

Un equipo eligió chunks de una hora *"para que las consultas del día toquen poco"*.

**Objetivo:** los cinco pasos de la Fase 00, con la sección 5 como factura, incluido el día que quisieron
borrar la tabla.

#### 🔴 Ejercicio 23 — La apuesta, con otro rival

Escribe una apuesta nueva, antes de medir, contra Postgres con una extensión de compresión columnar de
terceros.

**Objetivo:** la tarjeta completa con ese rival, y publicarla se gane o se pierda.

#### 🔴 Ejercicio 24 — Dónde se cruza

Encuentra el volumen al que el tamaño comprimido empieza a importar en una máquina de 8 GB.

**Objetivo:** el número de años de las 30 aeronaves de Cóndor que caben en memoria comprimidos y sin
comprimir.

#### 🔴 Ejercicio 25 — El veredicto de Voltaria, con números de Cóndor

Sin mirar el miniproyecto, escribe el veredicto de una empresa que solo necesita borrar meses viejos.

**Objetivo:** una página, con las filas de la tarjeta que le importan y las que no.

#### 🔴 Ejercicio 26 — La rotura a 1 hora

Lleva `cardinality.ts` a chunks de 1 hora con transacciones de un día.

**Objetivo:** el número de chunks, qué se rompe primero y cómo se borra después.

### 🔥 Opcionales

- **Tiered storage** de Timescale y por qué no se puede probar aquí.
- **`pg_partman`** para crear las particiones de Postgres sin escribir el bucle.

---

## 📚 12. Referencias

> ⚠️ Las URLs y sus contenidos cambian, y la documentación cubre la última versión. Esta fase se verificó
> con TimescaleDB 2.30.1 y PostgreSQL 18.6.

- **PostgreSQL 18, particionado** — https://www.postgresql.org/docs/18/ddl-partitioning.html — rango,
  `DEFAULT`, *pruning* y `DETACH`.
- **PostgreSQL 18, candados** — https://www.postgresql.org/docs/18/runtime-config-locks.html —
  `max_locks_per_transaction`.
- **Timescale, hypertables y tamaño de chunk** — https://github.com/timescale/docs/blob/latest/use-timescale/hypertables/index.md
  — la fuente de su documentación; el sitio redirigía a otro dominio al revisar los enlaces (07/10/2026).
- **Timescale, compresión** — https://github.com/timescale/docs/blob/latest/use-timescale/compression/index.md — `segmentby` y
  `orderby`.
- **Timescale, *backfill*** — https://github.com/timescale/docs/blob/latest/use-timescale/compression/modify-compressed-data.md
- **La licencia**, en [`a10`](a10-licencias-y-riesgo.md).

**Orden sugerido:** particionado de Postgres antes de la sección 4.1; compresión durante la 4.4; candados
antes de la sección 5.

---

## 🏁 13. Resultado de la fase

Pusiste a Timescale contra el rival que de verdad tiene —Postgres particionado— y perdiste la apuesta en
público: **dos de cinco**. Lo que Postgres gana es la retención y la lectura de una serie; lo que pierde es
el tamaño y el resumen, y esas dos cosas son las que justifican la extensión y las que están bajo
Timescale License. Y encontraste el borde: a **7573 chunks**, ni el `INSERT`, ni la consulta, ni el
`DROP TABLE`.

> **La señal de que quedó bien:** *"Puedo decir, para una serie de Cóndor, si necesita la extensión o
> le basta particionar, señalando la fila de la tarjeta que decide, y qué licencia acepta si la usa."*

> 🏷️ **Tag:** `fase-10-series-romper-y-medir` · prefijo de commit `f10:`

