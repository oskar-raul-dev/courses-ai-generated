# 🔍 Fase 12 — Búsqueda: el full-text de Postgres cubre el catálogo, y el índice que no es la fuente

> **Curso:** Ruta NoSQL Lite · Fase 12 de 26 · Bloque II — Leer de otra forma · **10 h**
> **Familia:** búsqueda · **Motor:** OpenSearch 3.8.0 `opensearchproject/opensearch@sha256:fafe3fc35870…`
> **Línea base:** PostgreSQL 18.6 `pgvector/pgvector@sha256:2ba9ca5f2e7d…` con `tsvector`, `unaccent` y GIN
> (base `busqueda_base`)
> **Entorno de ejecución:** TypeScript; el boss usa además Python para su tablero de DuckDB
> **Volumen:** `partCatalog-1m` (`a28d39be0bdb…`); el boss, `reading-5m` (`8dc486dea089…`)
> **Depende de:** Fase 11 · **Habilita:** Fase 13
> **Apéndices de apoyo:** [`a02`](a02-compose-de-la-ruta.md), [`a04`](a04-el-arnes-de-medida.md),
> [`a09`](a09-catalogo-de-errores.md), [`a10`](a10-licencias-y-riesgo.md)
> **Fecha de verificación ejecutada:** 07/10/2026, en macOS arm64
> **Objetivo:** medir si el full-text de Postgres cubre las búsquedas del almacén, y llevar el buscador a
> sus tres bordes: reconstruirlo, llenarle el disco y escribir algo que todavía no se ve.

---

## 🧭 1. Dónde estamos

La [Fase 11](11-busqueda-levantar-y-modelar.md) dejó un catálogo que se busca como habla el hangar, y una
medición sin matices: con lo que escribe Sandra, `LIKE` encuentra **0 de 10 287** y OpenSearch **10 287 de
10 287**. Pero `LIKE` no era un rival: era el instinto. El rival de verdad es el full-text de Postgres, que
tokeniza, quita tildes, reduce a la raíz y usa un índice GIN, sin un servicio más.

Esta fase lo pone en la mesa con una apuesta que favorece a Postgres, y después hace con el buscador lo que
se hace en producción: reconstruirlo sin cortar la búsqueda, llenarle el disco y medir cuánto tarda en
verse una referencia nueva. Las tres cosas tienen el mismo trasfondo, que la sección 8 de la Fase 11 dejó
dicho: **un buscador es un índice, no una fuente de verdad**.

Una nota sobre la apuesta antes de leerla: **esta vez apuesta a favor de Postgres**. Las de las Fases 04,
06 y 16 también lo hacían, y el curso lo hace a propósito. Una apuesta que solo puede ganar el motor nuevo no
sirve para decidir nada; la que importa es la que dice *"lo que ya tienes alcanza"*, porque es la que, si se
gana, te ahorra un componente en producción. Si se pierde, la pérdida dice exactamente dónde.

Al final va el boss del Bloque II, que cruza las tres familias del bloque: tres tableros, tres cifras del
mismo costo por hora volada.

---

## 🎯 2. Objetivos de esta fase

1. Montar el full-text de Postgres bien jugado —configuración española con `unaccent`, GIN, sinónimos con
   `ts_rewrite` y números normalizados— y medir veinte búsquedas del almacén contra OpenSearch.
2. Medir las facetas con el filtro de texto de Postgres en páginas leídas.
3. Reconstruir el índice del millón desde la fuente **sin que la búsqueda se entere**, con un alias.
4. Llevar el buscador a disco lleno y leer su error literal.
5. Medir cuánto tarda en verse lo recién escrito, y escribir cuándo no usar un motor de búsqueda.

> 🧰 **Miniproyecto de esta familia:** [Bengala — el archivo de diez años que solo encuentra lo que ya
> sabías que existía](h-mini-05-busqueda-bengala.md). Opcional, fuera de las horas del curso, y no entra a
> la bitácora.

---

## 🪞 3. La apuesta

> 🪞 **Apuesta antes de ejecutar.** Creo que **el full-text de Postgres con `tsvector` y un índice GIN cubre
> el 90 % de este catálogo y nadie notará la diferencia.** Se mide con una batería de veinte búsquedas del
> almacén —diez de descripción, diez de número de parte— con su verdad sacada del catálogo. Una búsqueda
> está **cubierta** si los diez primeros de Postgres traen tantos aciertos como los diez primeros de
> OpenSearch. La apuesta se gana con **18 de 20**.

Escrita en el temario el 30/09/2026 y traducida a la batería el 07/10/2026, antes de ejecutar
`battery.ts`. **Resultado, en la sección 4.7: ganada, 19 de 20**, y la que falló dice algo útil de cómo
ordena cada motor.

---

## 📐 4. La medición contra la línea base

### 4.1 El full-text de Postgres, bien montado

Desde `src/`, sobre la base de la Fase 11:

```bash
docker compose -f lab/compose.yaml exec -T base psql -U postgres -d busqueda_base < 12-busqueda-romper-y-medir/fts.sql
```

`fts.sql` hace con Postgres lo mismo que los analizadores de la Fase 11:

```sql
-- 12-busqueda-romper-y-medir/fts.sql (fragmento)
CREATE TEXT SEARCH CONFIGURATION es_unaccent (COPY = spanish);
ALTER TEXT SEARCH CONFIGURATION es_unaccent
    ALTER MAPPING FOR hword, hword_part, word WITH unaccent, spanish_stem;
ALTER TABLE part_catalog ADD COLUMN description_tsv tsvector
    GENERATED ALWAYS AS (to_tsvector('es_unaccent', description)) STORED;
CREATE INDEX part_catalog_description_tsv ON part_catalog USING gin (description_tsv);
```

Los sinónimos del almacén van en una tabla de reglas que `ts_rewrite` aplica a la consulta —*oring* pasa a
*junta & tórica*, *llanta* a *llanta | neumático*—, sin archivos de diccionario dentro del contenedor. Y los
números de parte, con una función que quita los separadores, un índice de expresión sobre el número y un
GIN sobre las grafías de los proveedores. Lo que hace Postgres con *"oring del tren"*:

```text
 'tren' & 'junt' & 'toric'
```

Los mismos lexemas que OpenSearch. Construir todo tardó unos 17 s sobre el millón: 6,0 s la columna
generada, que reescribe la tabla; 0,4 s el GIN de la descripción; 9,1 s los tres índices de números. El GIN
de la descripción ocupa **5256 kB** —son pocas palabras distintas, repetidas un millón de veces—, los
índices de números **105 MB**, y la tabla con todo, **456 MB**, contra los **170 MiB** del índice de
OpenSearch.

Detalle con intención: **la columna `tsvector` es generada y se guarda**. Cada vez que cambia una
descripción, Postgres recalcula sus lexemas en la misma transacción, y el GIN se actualiza con ella. No hay
un proceso que mantenga el índice al día, ni una ventana en que la fila dice una cosa y el índice otra. Es
la diferencia de fondo con el buscador, y la sección 4.5 la mide.

Los números de parte se buscan con una consulta que alguien tiene que escribir, porque el alterno no está
modelado en la tabla como lo está en el índice de la Fase 11:

```sql
-- battery.ts (fragmento): el número normalizado, sus alternos y las referencias que lo nombran
WITH m AS (SELECT part_number, alternates FROM part_catalog
    WHERE pn_normalize(part_number) = pn_normalize($1) OR pn_normalize_all(supplier_part_numbers) @> ARRAY[pn_normalize($1)])
SELECT part_number FROM m
UNION SELECT unnest(alternates) FROM m
UNION SELECT c.part_number FROM part_catalog c, m WHERE c.alternates @> ARRAY[m.part_number]
ORDER BY 1 LIMIT 10;
```

Tres lecturas con índice —el número, sus grafías y los que lo nombran— en una sola consulta. Es la misma
relación inversa que la Fase 11 calculó al cargar el buscador, resuelta al consultar: Postgres no necesita
desnormalizarla porque tiene `JOIN`.

### 4.2 Veinte búsquedas del almacén

```bash
node 12-busqueda-romper-y-medir/battery.ts
```

> 📐 **Medición — la batería de la apuesta** · `partCatalog-1m` · OpenSearch 3.8.0 · PostgreSQL 18.6 con
> `fts.sql` · verificado el 07/10/2026
>
> ```text
> búsqueda                          verdad · OpenSearch top10 · Postgres top10 · Postgres examinadas · cubierta
>   juntas toricas tren               10287 · 10/10 · 10/10 ·   10288 · sí
>   oring del tren                    10287 · 10/10 · 10/10 ·   10288 · sí
>   neumaticos principales             3128 · 10/10 · 10/10 ·    3129 · sí
>   filtros de aceite del motor       10258 · 10/10 · 10/10 ·   10259 · sí
>   abrazaderas hidraulicas           10298 · 10/10 · 10/10 ·   10299 · sí
>   empaques del tanque               20624 · 10/10 · 10/10 ·   20625 · sí
>   rodamientos de cabina             10403 · 10/10 · 10/10 ·   10404 · sí
>   bomba de combustible electrica     2152 · 10/10 · 10/10 ·    2153 · sí
>   actuador flap                      6249 · 10/10 · 10/10 ·    6250 · sí
>   helice tripala                     2081 · 10/10 ·  4/10 ·    8206 · NO
>   20990689-27                           2 ·  2/10 ·  2/10 ·       4 · sí
>   3410168722                            2 ·  2/10 ·  2/10 ·       4 · sí
>   20 910080 15                          2 ·  2/10 ·  2/10 ·       4 · sí
>   20-202412-29                          2 ·  2/10 ·  2/10 ·       5 · sí
>   …                                                         (seis números más, todos cubiertos)
> cubiertas por Postgres: 19 de 20
> ```
>
> Reproducir: `node 12-busqueda-romper-y-medir/battery.ts` (desde `src/`)

**El GIN cambia la forma de Postgres.** Donde `LIKE` examinaba el millón, el full-text examina **las filas
que tienen los términos**: 10 288 para 10 287 correctas, cuatro o cinco para un número de parte. Es el
mismo trabajo estructural que hace el buscador, con otro nombre: listas de documentos por lexema.

La que falla, *"helice tripala"*, falla por el orden, no por lo que encuentra. Los dos motores encuentran
también *"pala de hélice tripala"*, *"gobernador de hélice tripala"* y *"cubo de hélice tripala"*, que
tienen los dos términos. OpenSearch pone primero las descripciones cortas, porque su relevancia (BM25)
penaliza un campo largo; `ts_rank` sin normalizar no mira el largo, y mezcla. Con la normalización por
largo —`ts_rank(…, 1)`— Postgres también trae 10 de 10; se probó después de cerrar la batería y no cuenta
para la apuesta.

### 4.3 Las facetas con el filtro de texto

En la Fase 11, cuatro facetas con `ILIKE` examinaron 4 142 651 filas. Con el filtro del GIN:

```bash
node 12-busqueda-romper-y-medir/facets-fts.ts
```

| Facetas de *"juntas tóricas"* | Postgres con GIN | OpenSearch (Fase 11) |
|---|---|---|
| una faceta | 34 169–34 172 páginas, *bitmap heap scan* | — |
| las cuatro, una consulta por faceta | 4 viajes, ~136 700 páginas | **1 viaje** |
| las cuatro en una consulta con la coincidencia materializada | 1 viaje, **34 169 páginas** | 1 viaje |

Las 72 485 juntas tóricas están repartidas por casi toda la tabla, así que el GIN encuentra las filas pero
el recorrido del *heap* tiene que leer **34 169 de sus unas 40 400 páginas**: el índice ahorra el filtro, no
la lectura. OpenSearch cuenta las facetas con columnas propias de cada campo (*doc values*) sin tocar el
documento. Escrita como una sola consulta, Postgres lee una vez; la diferencia que queda es exactamente la
de la Fase 07, filas contra columnas.

### 4.4 Reconstruir el millón sin cortar la búsqueda

La Fase 11 terminó con la regla: si el `mapping` cambia, se reconstruye desde la fuente. Lo que falta es
hacerlo sin que la pantalla de Sandra se quede vacía. La pantalla no consulta un índice, consulta un
**alias**; el índice nuevo se carga al lado, y el alias cambia de uno a otro en una sola operación:

```bash
node 12-busqueda-romper-y-medir/reindex-alias.ts
```

```text
reconstrucción desde la fuente: 36.3 s · 174 búsquedas durante la carga
  por el alias:            10287 (174 veces)
  contra el índice nuevo:  2 respuestas distintas, de error: index_not_found_exception: [index_not_found_exception] Reaso a 0
  por el alias, después del cambio: 10287
```

El script corta cada mensaje de error a 60 caracteres, por eso la línea acaba en «Reaso a 0»: es la salida
literal del programa, no una errata. La corrida que la reprodujo para este texto dio otros recuentos, 187
búsquedas y 40,3 s, lo que es normal en una carga concurrente.

**Por el alias, 174 de 174 búsquedas dieron 10 287**, antes, durante y después. Contra el índice nuevo por
su nombre —lo que vería la pantalla sin alias—, primero un error porque el índice no existía, y después **0
resultados durante toda la carga**, porque `load.ts` desactiva el refresco mientras escribe. Treinta y seis
segundos de catálogo vacío para un millón; en el de Cóndor, con 80 000 referencias, serían unos tres.

### 4.5 Lo recién escrito

Sandra da de alta una referencia y la busca. `visibility.ts` mide cuánto tarda en aparecer:

```text
refresh_interval 1s  · GET por id lo encontró: true · búsquedas que no lo vieron:   5 · visible a los 308 ms
refresh_interval 1s  · GET por id lo encontró: true · búsquedas que no lo vieron:  17 · visible a los 1007 ms
refresh_interval 1s  · GET por id lo encontró: true · búsquedas que no lo vieron:  18 · visible a los 1023 ms
refresh_interval 1s  · GET por id lo encontró: true · búsquedas que no lo vieron:  17 · visible a los 964 ms
refresh_interval 1s  · GET por id lo encontró: true · búsquedas que no lo vieron:  18 · visible a los 1039 ms
refresh_interval 30s · GET por id lo encontró: true · búsquedas que no lo vieron: 520 · visible a los 30037 ms
refresh_interval 30s · GET por id lo encontró: true · búsquedas que no lo vieron: 523 · visible a los 30026 ms
```

Aquí el tiempo **es** lo que se mide, y se declara: es la ventana en que el buscador ya aceptó la escritura
y todavía no la devuelve. Con el refresco por defecto, **hasta un segundo**; con 30 s —lo que se pone para
cargar más rápido—, medio minuto y 520 búsquedas que no la ven. El `GET` por identificador la encontró
siempre al instante, porque lee el documento recién escrito sin esperar a que el segmento se abra para
buscar. La sección 6.6 de la Fase 11 explica por qué: lo escrito vive en un segmento nuevo, y el refresco es
el momento en que ese segmento empieza a contar. La primera medición, 308 ms, es más corta porque el
fragmento llevaba un rato sin búsquedas y refrescó con la primera; no se investigó más.

La misma prueba del lado de Postgres —alta en una conexión, búsqueda por texto desde otra, enseguida—:

```text
postgres · alta 99-VISPG-0 · la siguiente búsqueda desde otra conexión la encontró: true
…   (cinco de cinco)
```

**Cinco de cinco a la primera.** El `COMMIT` actualiza la fila, su `tsvector` y el GIN a la vez, y la
siguiente consulta los ve (`visibility-pg.ts`). En el buscador, la ventana existe por diseño: es lo que le
permite escribir rápido por lotes.

### 4.6 Lo que cuesta tener los dos

Hasta aquí, cada medición comparó una consulta. La decisión real compara **sistemas**, y conviene poner
lado a lado lo que cada uno pide para que la búsqueda de Sandra funcione el lunes, con las cifras de esta
fase y de la anterior:

| Lo que hay que hacer | Postgres con `fts.sql` | OpenSearch al lado de Postgres |
|---|---|---|
| tener el catálogo buscable | 17 s de índices sobre la tabla que ya existe | 33 s de carga en 200 viajes, y un servicio más |
| cambiar un analizador o un sinónimo | reescribir la regla de `ts_rewrite` (una fila) | reconstruir el índice: 36 s con alias, el doble de disco un rato |
| que un alta se vea al buscar | en la misma transacción (5 de 5) | hasta 1 s, o 30 con el refresco de carga |
| que una corrección no se pierda | se escribe en la fuente, que es la tabla | se escribe en la fuente **y** llega al índice por un proceso que hay que escribir |
| facetas de una búsqueda | 34 169 páginas, exactas | 1 petición, aproximadas si no se pide `shard_size` |

La tabla no tiene un ganador, y ese es el punto: **cada fila es un costo que alguien paga**. Con un solo
motor, las filas 2 a 4 desaparecen. Con dos, la búsqueda mejora en la última fila y en lo que la batería no
midió, y la operación hereda las otras tres. La [Fase 24](24-poliglota-la-costura.md) mide la cuarta, que es la que más cuesta.

### 4.7 El resultado de la apuesta

> 🪞 **Resultado: ganada, 19 de 20.** El full-text de Postgres, bien montado, trajo en los diez primeros
> tantos aciertos como OpenSearch en **diecinueve de las veinte búsquedas**, examinando solo las filas con
> los términos (10 288 para 10 287 correctas). La que perdió fue por orden, no por cobertura, y se arregla
> con un parámetro de `ts_rank`.

Lo que el "nadie notará la diferencia" no cubre es lo que no está en la batería. **Las facetas**: una
petición contra una consulta que lee 34 169 páginas. **El tamaño**: 456 MB de tabla e índices en Postgres
contra 170 MiB del índice de OpenSearch, aunque en Postgres la tabla es además la fuente. Y **todo lo que no
se midió**: relevancia más fina que el orden de los diez primeros, autocompletado, resaltado,
tolerancia a tecleo (`fuzziness` existe en OpenSearch y en Postgres pide `pg_trgm`). Para el catálogo de
Sandra, con estas búsquedas, **Postgres alcanza**.

### 4.8 Lo que no se midió

**La tolerancia a errores de tecleo** en Postgres con `pg_trgm`. **La relevancia** más allá de los diez
primeros. **La concurrencia**: muchas pantallas buscando mientras se carga. Y **un clúster de varios
nodos**: todo fue un nodo, un fragmento.

---

## 💥 5. El punto de rotura

El punto de rotura de esta familia es **el disco lleno y el índice en solo lectura**. Se provoca sin llenar
el disco, como se decidió: bajando los umbrales de disco de OpenSearch por debajo de lo que el nodo ya usa
(12,5 %), que para el motor es lo mismo.

```bash
node 12-busqueda-romper-y-medir/disk-full.ts
```

> 💥 **Rotura — disco por encima del umbral de inundación** · OpenSearch 3.8.0 · umbrales de 1 %, 2 % y 3 %
> con el disco al 12,5 % · verificado el 07/10/2026
>
> ```text
> disco del nodo: 12.5 % usado
> índice bloqueado a los 28.4 s · read_only_allow_delete = true
>   escribir: 429 cluster_block_exception: index [part_catalog] blocked by: [TOO_MANY_REQUESTS/12/disk usage exceeded flood-stage watermark, index has read-only-allow-delete block];
>   leer: 72485 juntas
> bloqueo levantado solo a los 9.7 s · escribir: escribe
> ```

Tres cosas para el oficio. **El índice no muere: se cierra a la escritura.** Las búsquedas siguen
contestando, y por eso el síntoma en una pantalla de almacén es raro: todo funciona salvo dar de alta. **El
código de estado es 429**, *demasiadas peticiones*, el mismo que un límite de tasa: un cliente que reintenta
los 429 con espera —como debe— va a reintentar contra un disco lleno sin saberlo. Y **el bloqueo se levantó
solo** a los 9,7 s de devolver los umbrales a su valor, cuando el motor volvió a mirar el disco. No hubo que
tocar el índice. Los mensajes están en
[`a09`](a09-catalogo-de-errores.md) como E-51 y, el del intervalo de chequeo que no baja de 10 s, E-52.

Lo que hay que cambiar para salir: **liberar disco o subir el umbral**, y entender qué ocupa. En un
buscador, el disco no lo llenan solo los datos: lo llenan los segmentos con documentos borrados que todavía
no se fusionaron (Fase 11, sección 6.6) y el índice viejo que queda al lado durante una reconstrucción como
la de la sección 4.4. **Reconstruir un índice pide el doble de disco por un rato**, y es justo el momento en
que el umbral se cruza.

---

## 🚑 6. Salir de aquí

Cuando un buscador ya duele, en orden de costo:

1. **Configuración.** El analizador, los sinónimos al buscar y no al indexar, `shard_size` en las facetas,
   el `refresh_interval` según lo que la pantalla tolere y los umbrales de disco con margen para una
   reconstrucción.
2. **Modelo.** Los campos que hay que preparar al indexar —el alterno inverso de la Fase 11— y un alias
   delante de cada índice desde el primer día, para que reconstruir no sea cortar.
3. **Motor.** Si tus búsquedas son las de la batería —palabras del dominio, números, sinónimos—, la sección
   4.7 dice que **Postgres alcanza**, y es un motor menos. Si necesitas facetas sobre millones, relevancia
   fina, tolerancia a tecleo y autocompletado, el buscador se gana su sitio.
4. **Arquitectura.** El buscador al lado de la fuente de verdad, **alimentado desde ella y reconstruible**,
   con la ventana de inconsistencia medida. Es la [Fase 24](24-poliglota-la-costura.md).

---

## ❓ 7. Las cinco preguntas, respondidas para búsqueda

1. **Frontera transaccional.** Ninguna propia: un buscador no tiene transacciones entre documentos, y lo
   recién escrito tarda en verse. La frontera vive en la fuente; el buscador la sigue.
2. **Consultas conocidas.** A medias: las palabras de la consulta no hace falta conocerlas, pero **cómo se
   analizan sí**, y cambiarlo es reconstruir el índice.
3. **Unidad de lectura.** Los diez más relevantes, y los conteos al lado. Nunca "todas las filas que
   cumplen", que es para lo que el buscador no está hecho (10 000 por defecto).
4. **Saltos.** Ninguno; las relaciones se resuelven al indexar, como el alterno inverso.
5. **Exactitud o parecido.** **Es la pregunta de esta familia**: exactitud sobre lo que el usuario quiso
   decir, con plurales, tildes y sinónimos. No es parecido de significado: eso es vectorial.

---

## ⚖️ 8. Veredicto honesto: cuándo NO usar esto

> ⚖️ **No uses un motor de búsqueda como fuente de verdad**: 500 de 500 correcciones perdidas al
> reconstruirlo desde la fuente (Fase 11). **No lo agregues para buscar palabras y números de un catálogo
> como el de Cóndor**: el full-text de Postgres cubrió **19 de 20** búsquedas, examinando solo las filas con
> los términos, sin un servicio más ni una copia que mantener al día. **Y no confíes en sus facetas sin
> mirar el error**: la de proveedores salió equivocada con 3521 de margen declarado (Fase 11).
>
> **Úsalo** cuando necesites lo que Postgres no da en la medición: **facetas sobre millones en una
> petición** (contra 34 169 páginas), **relevancia** que ordene bien sin que lo pidas, tolerancia a tecleo,
> autocompletado. Siempre **al lado y siempre reconstruible**, con un alias delante.

El veredicto de esta familia se parece al de vectorial (Fase 16) más de lo que parece: allí, `pgvector`
alcanzaba para "lo más parecido de todo" y fallaba con filtros de selectividad media; aquí, el full-text de
Postgres alcanza para buscar y se queda corto en facetas sobre muchas coincidencias. En las dos familias, la
pregunta que decide no es *"¿qué motor busca mejor?"* sino *"¿qué consulta concreta tengo, y la resuelve lo
que ya tengo?"*.

Para Cóndor: el buscador del almacén puede empezar en Postgres, con lo que montó `fts.sql`. Si un día la
pantalla de Sandra necesita facetas por modelo y proveedor sobre el catálogo de los ocho operadores, o
búsquedas con errores de tecleo, OpenSearch entra **al lado**, alimentado desde la tabla, y nunca recibe una
corrección de precio. La licencia de OpenSearch es Apache 2.0, y por qué el curso no usa Elasticsearch está
en [`a10`](a10-licencias-y-riesgo.md).

---

## ⚠️ 9. Errores comunes y diagnóstico

**El índice que no acepta escrituras** (E-51 en [`a09`](a09-catalogo-de-errores.md)):

```text
429 cluster_block_exception: index [part_catalog] blocked by: [TOO_MANY_REQUESTS/12/disk usage exceeded flood-stage watermark, index has read-only-allow-delete block];
```

🩺 `GET <índice>/_settings` muestra `index.blocks.read_only_allow_delete: true`, y `_cat/allocation` el uso de
disco. No es un límite de tasa aunque diga 429.

**El intervalo de chequeo de disco que no baja** (E-52):

```text
illegal_argument_exception: [illegal_argument_exception] Reason: failed to parse value [5s] for setting [cluster.info.update.interval], must be >= [10s]
```

🩺 El mínimo es 10 s. Es lo que tarda, como poco, el motor en notar el disco lleno: el bloqueo llegó a los
28 s.

**La búsqueda que no ve lo recién escrito.** Sin error. 🩺 `GET <índice>/_doc/<id>` lo encuentra y `_search`
no: es el refresco. `?refresh=wait_for` en la escritura, si la pantalla lo necesita, o aceptar el segundo.

**El índice vacío durante una reconstrucción.** 🩺 Si la pantalla consulta un índice por su nombre, el día
que se reconstruye ve 0. Alias siempre.

**`ts_rank` que ordena raro.** 🩺 Sin normalización, una descripción larga con los términos pesa lo mismo que
una corta. El tercer argumento de `ts_rank` (1 o 2) divide por el largo.

**`operator does not exist: text = text[]`.** Comparar un número con un `ANY` de una subconsulta que devuelve
un array, no sus elementos. 🩺 `IN (SELECT unnest(alternates) …)`.

---

## 📋 10. Checklist de validación

```text
[ ] fts.sql montado: es_unaccent, GIN de 5256 kB, sinónimos con ts_rewrite, números normalizados
[ ] La batería da 19 de 20, y sé por qué falla "helice tripala"
[ ] Postgres examina 10 288 filas donde LIKE examinaba el millón
[ ] Las facetas con GIN leen 34 169 páginas, y sé por qué no menos
[ ] Por el alias, 174 de 174 búsquedas vieron el catálogo durante la reconstrucción
[ ] Lo recién escrito tarda hasta 1 s con el refresco por defecto, y GET lo ve al instante
[ ] Provoqué E-51 bajando los umbrales, y el bloqueo se levantó solo
[ ] La apuesta está escrita antes, con la batería, y su resultado
[ ] M-31 a M-33 en la bitácora, la apuesta 7, E-51 y E-52 en a09
```

---

## 🧪 11. Ejercicios (28)

Desde `src/`, con el perfil `busqueda` arriba, el catálogo de la Fase 11 cargado y `fts.sql` corrido.

### 🟢 Fácil — reproducir (1–6)

#### 🟢 Ejercicio 1 — La batería

Corre `battery.ts`.

**Objetivo:** 19 de 20, y nombrar la búsqueda que falla.

#### 🟢 Ejercicio 2 — Los lexemas

Compara `to_tsvector('es_unaccent', 'juntas tóricas del tren')` con `_analyze` de la Fase 11.

**Pregunta:** ¿producen los mismos términos? ¿Qué palabra trata distinto cada uno?

#### 🟢 Ejercicio 3 — El alias

Corre `reindex-alias.ts`.

**Objetivo:** las 174 búsquedas iguales por el alias, y qué vio la consulta al índice por su nombre.

#### 🟢 Ejercicio 4 — El refresco

Corre `visibility.ts`.

**Objetivo:** cuántas búsquedas no ven el documento con cada intervalo, y por qué el `GET` sí.

#### 🟢 Ejercicio 5 — El disco lleno

Corre `disk-full.ts`.

**Objetivo:** E-51, y comprobar que la búsqueda sigue funcionando con el índice bloqueado.

#### 🟢 Ejercicio 6 — Las facetas con GIN

Corre `facets-fts.ts`.

**Objetivo:** las páginas de cada forma, y explicar por qué la de una consulta lee lo mismo que una faceta.

### 🟡 Intermedio — medir de otra forma (7–14)

#### 🟡 Ejercicio 7 — `ts_rank` normalizado

Repite la batería con `ts_rank(…, 1)`.

**Objetivo:** 20 de 20, y si alguna otra búsqueda cambia de orden.

#### 🟡 Ejercicio 8 — Un sinónimo más en los dos

Añade *"empaque, junta"* a la tabla de `ts_rewrite` y al analizador de búsqueda de OpenSearch.

**Pregunta:** ¿qué tuviste que reconstruir en cada uno?

#### 🟡 Ejercicio 9 — Tolerancia a tecleo en Postgres

Instala `pg_trgm` y busca *"junta torcia"* por similitud.

**Objetivo:** cuántas filas examina, y lo que encuentra contra `fuzziness: AUTO`.

#### 🟡 Ejercicio 10 — Diez búsquedas tuyas

Escribe diez búsquedas como las escribiría Sandra y su verdad, y añádelas a la batería.

**Objetivo:** el resultado de las treinta, y si la apuesta se sostiene.

#### 🟡 Ejercicio 11 — El refresco y la carga

Carga el millón con `refresh_interval` de 1 s en lugar de `-1`.

**Objetivo:** cuántos segmentos quedan y cuánto tarda, contra la carga de la Fase 11.

#### 🟡 Ejercicio 12 — `refresh=wait_for`

Escribe una referencia con `?refresh=wait_for` y búscala enseguida.

**Pregunta:** ¿cuánto tardó la escritura en responder?

#### 🟡 Ejercicio 13 — El GIN, por dentro

Con `EXPLAIN (ANALYZE, BUFFERS)`, mira una búsqueda de número y una de descripción.

**Objetivo:** qué índice usa cada una y cuántas páginas toca.

#### 🟡 Ejercicio 14 — El tamaño de los dos

Suma lo que ocupa en Postgres solo lo que sirve para buscar (los índices y la columna `tsvector`).

**Objetivo:** compararlo con los 170 MiB de OpenSearch, y decir qué parte de la tabla ya estaba igual.

### 🟠 Difícil — diagnosticar y decidir (15–22)

#### 🟠 Ejercicio 15 — Predecir el bloqueo

Antes de correr `disk-full.ts`, predice cuánto tarda el índice en bloquearse con el intervalo de 10 s.

**Objetivo:** tu número escrito antes, y por qué no es 10.

#### 🟠 Ejercicio 16 — El cliente que reintenta 429

Escribe en el bloqueo con un cliente que reintente los 429 con espera exponencial.

**Pregunta:** ¿cuánto espera antes de rendirse, y qué vería la pantalla de Sandra?

#### 🟠 Ejercicio 17 — El doble de disco

Mide el disco del nodo antes, durante y después de `reindex-alias.ts`.

**Objetivo:** el pico, y con qué umbral habría bloqueado una reconstrucción.

#### 🟠 Ejercicio 18 — La facetas que no cuadran, en Postgres

Diseña en Postgres las facetas de la Fase 11 para que lean menos de 34 169 páginas.

**Objetivo:** el diseño (columnas aparte, índices cubrientes o una tabla resumen) y su medición.

#### 🟠 Ejercicio 19 — Escribir en la fuente y en el buscador

Cambia un precio en Postgres y propágalo a OpenSearch desde un script.

**Objetivo:** cuánto tarda en verse en cada uno, y qué pasa si el script falla entre los dos.

#### 🟠 Ejercicio 20 — La búsqueda que Postgres no alcanza

Encuentra una búsqueda del catálogo que el full-text de Postgres no pueda cubrir con ninguna configuración.

**Objetivo:** la búsqueda, las dos mediciones, y si es una que Sandra haría.

#### 🟠 Ejercicio 21 — Un alias para escribir

Configura un alias de escritura además del de lectura, y reconstruye mientras llegan altas.

**Pregunta:** ¿dónde quedan las altas que llegaron durante la carga? ¿Se pierden?

#### 🟠 Ejercicio 22 — Los segmentos y el disco

Fuerza una fusión (`_forcemerge`) después de las correcciones de la Fase 11.

**Objetivo:** cuántos documentos borrados se van, cuánto disco vuelve y cuánto se usó mientras tanto.

### 🔴 Muy difícil — romper y autopsias (23–28)

#### 🔴 Ejercicio 23 — La autopsia del buscador sin alias

Un equipo reconstruye el índice de producción borrándolo y volviendo a cargarlo.

**Objetivo:** los cinco pasos de la Fase 00, con la sección 4.4 como factura.

#### 🔴 Ejercicio 24 — Disco lleno de verdad

Pon un límite de disco real al volumen de OpenSearch y llénalo cargando copias del catálogo.

**Objetivo:** el volumen exacto al que bloquea, el mensaje, y si coincide con E-51.

#### 🔴 Ejercicio 25 — La apuesta inversa

Escribe una apuesta, antes de medir, donde OpenSearch gane a Postgres por más de 2× en algo estructural.

**Objetivo:** medirla y publicarla, gane o pierda.

#### 🔴 Ejercicio 26 — Relevancia de verdad

Define para cinco búsquedas el orden correcto de los diez primeros, a mano, y mide los dos motores.

**Objetivo:** cuántas posiciones aciertan, y si BM25 contra `ts_rank` cambia el veredicto.

#### 🔴 Ejercicio 27 — El catálogo de Cóndor, decidido

Con las Fases 11 y 12, decide si el almacén de Cóndor necesita OpenSearch.

**Objetivo:** una página con la decisión, las búsquedas de Sandra clasificadas y la factura de cada opción.

#### 🔴 Ejercicio 28 — Las tres cifras, antes del boss

Corre los tres tableros del boss sin leer el encargo.

**Objetivo:** anotar las tres cifras y, antes de investigar, tu hipótesis de por qué no coinciden.

### 🔥 Opcionales

- **Resaltado** de los términos en los resultados, en los dos motores.
- **Autocompletado** de números de parte con `search_as_you_type`, y su costo en disco.

---

## 📚 12. Referencias

> ⚠️ Las URLs y sus contenidos cambian, y la documentación cubre la última versión. Esta fase se verificó
> con OpenSearch 3.8.0 y PostgreSQL 18.6.

- **PostgreSQL 18, búsqueda de texto** — https://www.postgresql.org/docs/18/textsearch.html — configuraciones,
  `ts_rank` y `ts_rewrite`.
- **PostgreSQL 18, `unaccent`** — https://www.postgresql.org/docs/18/unaccent.html
- **OpenSearch, alias** — https://docs.opensearch.org/latest/im-plugin/index-alias/
- **OpenSearch, umbrales de disco** — https://docs.opensearch.org/latest/install-and-configure/configuring-opensearch/cluster-settings/
- **OpenSearch, refresco** — https://docs.opensearch.org/latest/api-reference/index-apis/refresh/
- **Robertson y Zaragoza, *The Probabilistic Relevance Framework: BM25 and Beyond*** (2009) —
  https://www.nowpublishers.com/article/Details/INR-019 — la relevancia de OpenSearch.
- **La licencia**, en [`a10`](a10-licencias-y-riesgo.md).

**Orden sugerido:** búsqueda de texto de Postgres antes de la sección 4.1; alias antes de la 4.4; umbrales de
disco antes de la sección 5; BM25 después.

---

## 🏁 13. Resultado de la fase

Pusiste el full-text de Postgres contra el buscador y **ganó la apuesta**: 19 de 20 búsquedas del almacén,
examinando solo las filas con los términos. Mediste lo que la batería no ve —facetas, tamaño, relevancia— y
llevaste el buscador a sus bordes: reconstruido sin que nadie lo note gracias a un alias, cerrado a la
escritura por disco lleno con un 429 que engaña, y un segundo de ceguera para lo recién escrito.

> **La señal de que quedó bien:** *"Puedo decir, para un catálogo, si basta el full-text de Postgres o hace
> falta un buscador, con la batería de búsquedas reales y las facetas como prueba, y cómo reconstruiría el
> buscador sin cortar la búsqueda."*

> 🏷️ **Tag:** `fase-12-busqueda-romper-y-medir` · prefijo de commit `f12:`

---

### 💀 Boss del Bloque II — "El tablero que nadie puede reconstruir"

> *"El jueves renuevo con Carga del Llano y con dos operadores más la tarifa del Twin Otter en Ala
> Continua. Pedí el costo por hora volada de lo que va del año, y me llegaron **tres números**: el tablero de
> análisis dice 797,96 dólares, el de parámetros de vuelo dice 905,16 y el de almacén, 1059,20. Si firmo con el
> bajo y el bueno es el alto, el contrato nace perdiendo un 25 % y no nos enteramos hasta el año tres. No
> quiero un promedio. Quiero saber cuál es el correcto, **por qué los otros dos no lo son**, y si el
> correcto es alguno de los tres."*
>
> — Lucía Arango, gerente

**El sistema, tal como está.** Tres tableros, cada uno armado por alguien distinto y con buen criterio, sobre
la flota de Twin Otter con grabador y lo que va de 2026:

- **El de análisis** es DuckDB, la base de la [Fase 07](07-analitico-levantar-y-modelar.md):
  `boss/tablero_duckdb.py`.
- **El de parámetros de vuelo** es Timescale: las horas de un agregado continuo mensual y las órdenes en
  una tabla al lado, en `boss/tableros.ts`.
- **El de almacén** es OpenSearch: las órdenes indexadas con las partes instaladas, valoradas al precio del
  catálogo del buscador, y las horas que le pasa el de parámetros. También en `boss/tableros.ts`.

```bash
node 12-busqueda-romper-y-medir/boss/setup.ts           # arma los tres (perfiles base, series y busqueda)
uv run python 12-busqueda-romper-y-medir/boss/tablero_duckdb.py
node 12-busqueda-romper-y-medir/boss/tableros.ts
```

```text
DuckDB     · Twin Otter, 2026 · costo 7862753.12 USD · horas 9853.5 · 797.96 USD por hora volada
Timescale  · Twin Otter, ene–sep 2026 · costo 7862753.12 USD · horas 8686.6 · 905.16 USD por hora volada
OpenSearch · Twin Otter, ene–sep 2026 · costo 9200840.98 USD · horas 8686.6 · 1059.20 USD por hora volada
```

Los tres motores caben a la vez en la máquina de laboratorio: medidos juntos, OpenSearch usó unos 1,0 GiB de
su límite de 1,37, y los dos Postgres, menos de 400 MiB cada uno según `docker stats` (que se queda corto,
Fase 16). El boss es el primero del curso con una sola JVM: la advertencia de memoria de
[`a02`](a02-compose-de-la-ruta.md) para dos familias JVM juntas no aplica todavía.

**Qué hay que entregar.** Un informe de reconciliación para Lucía, de no más de dos páginas, con:

1. **De dónde sale cada número**: qué horas y qué costos suma cada tablero, con la consulta que lo prueba.
2. **Por qué difieren**, con la cifra exacta de cada diferencia, no con una explicación cualitativa. Hay
   más de una causa, y al menos una está en los datos y no en ningún tablero.
3. **Cuál es la cifra correcta**, con la definición escrita —qué es una hora volada para Ala Continua, en qué
   zona horaria se corta un mes, qué precio vale para una parte ya instalada— y su número.
4. **El arreglo mínimo** de cada tablero, y cuál de los tres debería ser la fuente del número de Lucía.

**Criterios de aceptación.**

```text
[ ] Cada diferencia entre tableros está explicada con su cifra, y las cifras suman la diferencia total
[ ] El informe nombra un problema de los datos que ninguno de los tres tableros detecta, con un argumento físico
[ ] La definición de "hora volada" y de "mes" está escrita antes del número
[ ] El número final no es un promedio de los tres
[ ] Cada afirmación tiene la consulta que la reproduce
[ ] El arreglo de cada tablero está probado: después del arreglo, dos tableros dan el mismo número
```

**Pistas, si te atascas**, de la más suave a la más directa: el ejercicio 22 de la Fase 07; la sección 9 de
la Fase 07, sobre la zona horaria; la sección 9 de la Fase 11, sobre el cliente que reintenta; y `a05`, sobre
las aeronaves que entran tarde a la flota.

> 🏷️ **Tag del boss:** `boss-bloque-2` · la solución no se publica.

> 🏆 **El Hangar, opcional.** Si lo vienes construyendo, el Bloque II le añade **el tablero de flota**: las
> horas por aeronave desde una serie temporal, el costo por hora desde un motor analítico, y el catálogo de
> partes buscable con sus alternos. Y le añade una regla que vale para todo lo que sigue: **cada número del
> tablero dice de qué fuente sale**. Quien no lo siguió no ha perdido nada del curso.
