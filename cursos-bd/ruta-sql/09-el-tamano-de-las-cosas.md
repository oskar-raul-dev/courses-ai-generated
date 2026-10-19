# 📦 Fase 09 — El tamaño de las cosas: páginas, filas, archivos y meses

> **Curso:** Ruta SQL · Fase 09 de 27 · Bloque II — La física y el tuning · **10 h**
> **Motores:** PostgreSQL `pgvector/pgvector@sha256:2358fcba361e…` · contraste MySQL `mysql@sha256:e2bde46db656…` · Oracle (apuesta sin resolver)
> **Entorno de ejecución:** SQL + Python
> **Perfil de volumen:** M, con el modelo de `uv run lab load --profile m --model`
> **El dolor de Alameda:** 1,1 TB de órdenes escaneadas y PDF dentro de la base, y un respaldo de seis horas (historia §3, 2013–2014, y §4)
> **Depende de:** Fase 08 · **Habilita:** Fase 10
> **Apéndices de apoyo:** a03, a04, a05, a08
> **Fecha de verificación ejecutada:** 14/10/2026
> **Objetivo:** medir de qué está hecho el tamaño de una base (páginas, filas, relleno, valores fuera de la
> fila y archivos) y decidir qué va adentro, qué va afuera y cómo se parte lo que crece.

---

## 🧭 1. Dónde estamos

El Bloque I terminó con un modelo que el motor puede defender. Este bloque desmonta otra frase de Alameda:
*"la base está lenta"*. Antes de hablar de índices, estadísticas y planes, hay que saber de qué está hecho el
tamaño, porque todo lo que sigue se mide en bloques leídos, y un bloque es una página.

La historia da los números: **1,4 TB de base, de los cuales 1,1 TB son órdenes escaneadas y PDF**, y un respaldo
completo de seis horas que ya no entra en la ventana nocturna. Esta fase no enseña a respaldar (eso es
operación y queda fuera del curso); mide **qué** hay que respaldar y por qué es tanto.

---

## 🎯 2. Objetivos de esta fase

1. Leer el tamaño de una tabla en páginas, en los dos motores que se miden.
2. Medir el relleno por alineación de una fila, y cuándo el orden de las columnas lo cambia.
3. Guardar un PDF de tres formas (en la fila, como objeto grande y fuera de la base con su hash) y medir
   cada una.
4. Ver qué significa que InnoDB *sea* su clave primaria.
5. Particionar `result` por mes como diseño: *pruning* en el plan y un mes que se desprende entero.

---

## 🚫 3. Qué NO entra todavía

- **Los identificadores y su efecto en el tamaño** (UUID, secuencias) → [Fase 10](10-identificadores.md).
- **Los índices y lo que cuestan** → [Fase 11](11-indices-y-lo-que-cuestan.md).
- **Respaldos, réplicas y restauración**: operación, fuera del curso (alcance D2).

---

## 🏚️ 4. El dolor, en la caja

> 🏚️ **La historia, 2013:** *"Para «que no se pierdan», los PDF de cada informe se guardan también en SQL
> Server, en una columna `varbinary(max)`, al lado de las órdenes escaneadas que llegaron de Access."*

La caja no trae el terabyte: trae `archivos/listado.csv`, con el nombre, el tipo y el tamaño de cada archivo
que la base de verdad guarda. `01_file_listing.sql` lo carga en `staging.file_listing`:

```text
    file_type    |  count  | total  | promedio |    min     |    max
-----------------+---------+--------+----------+------------+------------
 INFORME_PDF     | 1194978 | 106 GB | 93 kB    | 2013-05-01 | 2026-10-10
 ORDEN_ESCANEADA |  995898 | 378 GB | 398 kB   | 2006-03-01 | 2026-10-10
(2 rows)
```

**484 GB de archivos**, contra **2.058 MB** de las 419 tablas de `legacy` en el mismo perfil. En la base de
verdad la proporción es 1,1 TB sobre 1,4; en la caja M los archivos son más de doscientas veces las filas,
porque el perfil achica las filas y no los archivos. La conclusión es la misma: **el tamaño de la base de
Alameda no son sus datos, son sus archivos**.

El listado también cuenta la historia por año. Hasta 2011 las órdenes son mapas de bits de Access, de 2,4 MB
cada una; después del pasaje a SQL Server, JPG de 310 kB. En 2012 las órdenes ocupan 4.704 MB y en 2010, 26 GB.
Y desde 2020 el volumen se dispara con la pandemia: 2025 suma 43 GB de órdenes y 17 GB de PDF.

---

## 🧩 5. De qué está hecho el tamaño

### 5.1 La página

Todo motor guarda las filas en páginas de tamaño fijo, y lee y escribe páginas enteras. Por eso el curso mide
en bloques y no en filas:

| Motor | Página | De dónde |
|---|---|---|
| Postgres 18 | 8 KB | `SHOW block_size;` → `8192` |
| MySQL 9.7 (InnoDB) | 16 KB | `SELECT @@innodb_page_size;` → `16384` |
| Oracle | 8 KB por defecto | `DB_BLOCK_SIZE`, en su documentación |

Una página no se llena hasta el último byte. Postgres reserva 24 bytes de cabecera de página, 4 bytes de
puntero por fila y **23 bytes de cabecera por fila**, redondeados a 24; y cada fila empieza alineada a 8 bytes.

Y no toda página está llena. Hay tres fuentes de espacio vacío, y las tres aparecen en esta fase. La última página de
una tabla queda a medio llenar: con una tabla no se nota, con las 223 particiones de la sección 5.6 son seis megabytes.
El espacio que se deja a propósito para las actualizaciones (`fillfactor`, sección 5.4). Y las filas borradas o
reemplazadas, que siguen ocupando su lugar hasta que `VACUUM` las recorre y lo marca como reutilizable: después de
borrar un mes entero de `result`, la tabla sigue midiendo 686 MB. `VACUUM` no le devuelve ese espacio al sistema de
archivos; lo deja para las filas que vengan. Por eso el tamaño de una tabla en Postgres casi nunca baja, y por eso
importa tanto no escribir lo que no hace falta escribir.

### 5.2 El relleno por alineación, y la apuesta que no lo encontró

Cada tipo de Postgres tiene una alineación: `boolean` a 1 byte, `integer` a 4, `bigint` y `timestamp` a 8. Si
un `boolean` va antes de un `bigint`, el motor rellena siete bytes para que el `bigint` empiece donde debe. La
tabla de protocolos con tres booleanos intercalados entre columnas de 8 bytes (`03_alignment.sql`):

> 📐 **Medición: el orden de las columnas** · perfil M · `pgvector/pgvector@sha256:2358fcba361e…` · verificado el
> 14/10/2026
>
> | Tabla | Orden | Bytes por fila | Bloques | Tamaño |
> |---|---|---|---|---|
> | protocolos de prueba | booleanos entre `bigint` | 72 | 12.414 | 97 MB |
> | protocolos de prueba | `bigint` primero | 51 | 9.767 | 76 MB |
> | `alameda.result` | como está | 54,8 en promedio | 87.835 | 686 MB |
> | `alameda.result` | reordenada | 49,8 en promedio | 87.835 | 686 MB |

Un 21 % menos en la primera; **nada** en `result`. Sus columnas son casi todas de largo variable (`varchar`,
`numeric`, `char(1)`) con alineación de 4 bytes o menos, así que casi no hay relleno que ahorrar. Los cinco bytes
que se ahorran por fila se pierden al redondear la fila entera a múltiplos de 8: caben las mismas filas por
página.

### 5.3 Lo que no cabe en la fila: TOAST

Un valor de más de unos 2 kB no se guarda en la página de su fila. Postgres lo comprime si puede y lo manda a
una tabla aparte, la **tabla TOAST**, en trozos; la fila guarda un puntero. `02_report_files.sql` guarda 2.000
PDF de octubre de 2026, del tamaño que dice el listado (bytes al azar: un PDF ya viene comprimido), de tres
formas:

> 📐 **Medición: el PDF de un informe, guardado de tres formas** · 2.000 informes, 181 MB de PDF · verificado el
> 14/10/2026
>
> | Forma | Tabla | Fuera de la tabla | Total |
> |---|---|---|---|
> | `bytea` en la fila | 120 kB | 187 MB en TOAST | 189 MB |
> | objeto grande (`lo_from_bytea`) | 88 kB | 241 MB en `pg_largeobject` | 241 MB |
> | ruta, tamaño y SHA-256 | 216 kB | — | 312 kB |

Lo que TOAST compra es que **las consultas que no piden el PDF no lo leen**:

```text
-- SELECT lab_order_id, created_on … WHERE created_on = '2026-10-02'
 Seq Scan on report_pdf_bytea (actual rows=531.00 loops=1)
   Buffers: shared hit=15
-- SELECT sum(length(pdf || ''::bytea)) … WHERE created_on = '2026-10-02'
 Aggregate (actual rows=1.00 loops=1)
   Buffers: shared hit=7862
```

Quince bloques para los metadatos de 531 informes, y 7.862 para leer sus PDF. Incluso `length(pdf)` lee solo
quince: el largo está en el puntero. El objeto grande ocupa un 28 % más, porque `pg_largeobject` lo parte en
trozos de 2 kB, cada uno con su fila y su cabecera; a cambio, se puede leer y escribir por partes.

**TOAST también comprime**, y ahí los dos tipos de archivo de Alameda se separan. Un PDF ya viene comprimido:
`pg_column_compression(pdf)` da vacío en los 2.000, porque Postgres probó, no ganó nada y lo guardó como estaba. Una
orden escaneada de Access era un mapa de bits sin comprimir, casi todo fondo blanco. Con 200 órdenes sintéticas de
2,4 MB con esa forma (`05_compression.sql`; son de juguete, más comprimibles que un escaneo real):

| Compresión | Original | Guardado |
|---|---|---|
| `pglz` (la de fábrica) | 184 MB | 2.528 kB |
| `lz4` | 184 MB | 896 kB |

La trampa que deja la medición: la primera versión copiaba la tabla `pglz` a la `lz4` con un `INSERT … SELECT`, y las
dos ocupaban lo mismo. Postgres copia el valor ya comprimido tal como está, sin recomprimirlo; cambiar la compresión
de una columna solo afecta a los valores nuevos.

La tercera forma no guarda el archivo: guarda **dónde está y qué es**. El SHA-256 es lo que permite demostrar,
años después, que el PDF del disco es el que se firmó.

### 5.4 InnoDB es su clave primaria

En Postgres, la tabla es un montón (*heap*): las filas van donde haya lugar, y la clave primaria es un índice
aparte que apunta a ellas. En InnoDB, **la tabla es el índice de la clave primaria**: las filas viven en las hojas
del árbol, ordenadas por la clave. La caja tiene el caso perfecto: los protocolos de 2004 a 2011 tienen los
identificadores aleatorios de la replicación de Jet (36.310 negativos en M), y `LOAD DATA` los carga en el orden del
archivo, que es el de la fecha.

| Tabla de MySQL | Páginas del índice primario | Hojas |
|---|---|---|
| `legacy.Protocolos`, cargada en orden de fecha | 6.441 | 6.330 |
| la misma, insertada en orden de clave | 6.184 | 6.162 |

Un 4 % más de páginas, por las divisiones que provocan las claves fuera de orden. Y como cada índice secundario
de InnoDB guarda la clave primaria para llegar a la fila, el índice por paciente ocupa 21,5 MB en MySQL contra
14 MB en Postgres, que guarda un puntero físico de 6 bytes. La [Fase 10](10-identificadores.md) lleva las dos
cosas al extremo con UUID.

**`fillfactor`**, del lado de Postgres, es el espacio que se deja libre en cada página para que una
actualización quepa en la misma: `alameda.lab_order` con `fillfactor = 70` pasa de 68 a 97 MB. Es espacio que se
paga siempre, para un beneficio que solo existe si la tabla se actualiza; la [Fase 11](11-indices-y-lo-que-cuestan.md) mide ese beneficio.

### 5.5 Lo que se respalda

Con los números de la caja, la pregunta del respaldo de seis horas se contesta sin herramientas de respaldo. De lo
que hay que copiar, **el 99,6 % son archivos** (484 GB contra 2 GB de filas en M; el 79 % en la base de verdad). Y casi
todos esos archivos no cambian nunca: una orden de 2009 es la misma en 2026. Un respaldo completo de la base los copia
todos, todas las noches; un almacén de archivos aparte los copia una vez. El respaldo no es lento: es grande, y es
grande por lo que guarda, no por cómo lo guarda.

Lo mismo vale para el crecimiento. En 2025 la caja agrega 60 GB de archivos y, del lado de las filas, los resultados
de un año: unos 10 MB de `result` por mes en M, lo que pesa en promedio cada partición mensual de 2025. Cualquier plan de capacidad de Alameda que mire la base sin separar
las dos cosas va a proyectar mal las dos.

### 5.6 El particionado de `result` por mes

`result` solo crece, y casi toda consulta pregunta por un período. `04_result_by_month.sql` la parte en **223
particiones**, una por mes de carga desde abril de 2008:

```sql
-- postgres
CREATE TABLE staging.result_by_month (LIKE alameda.result INCLUDING DEFAULTS INCLUDING CONSTRAINTS)
    PARTITION BY RANGE (recorded_at);
-- y una partición por mes: … PARTITION OF staging.result_by_month FOR VALUES FROM ('2024-10-01') TO ('2024-11-01')
```

Las glucemias cargadas en octubre de 2024:

```text
-- sin particionar
 Finalize Aggregate (actual rows=1.00 loops=1)
   Buffers: shared read=87808
         ->  Parallel Seq Scan on result_as_is (actual rows=3223.67 loops=3)
-- particionada
 Finalize Aggregate (actual rows=1.00 loops=1)
   Buffers: shared hit=871 read=302
               ->  Parallel Seq Scan on result_2024_10 result_by_month (actual rows=4835.50 loops=2)
```

**1.173 bloques contra 87.808**: el plan nombra una sola partición. Eso es el *pruning*: el optimizador descarta
las particiones que el `WHERE` no puede tocar, antes de leerlas.

Y el mes viejo que se va. Sacar enero de 2025, 174.933 resultados:

| Cómo | WAL escrito |
|---|---|
| `DELETE … WHERE recorded_at` en la tabla entera | 20 MB |
| `DETACH PARTITION` y `DROP TABLE` | 179 kB |

El `DELETE` escribe en el WAL cada fila que marca como borrada, y la tabla sigue ocupando lo mismo hasta que el
`VACUUM` la recorre. Desprender la partición es un cambio de catálogo: el mismo costo para un mes de mil filas que
para uno de un millón. Con abril de 2008, un mes de 9.065 filas, el `DELETE` escribió 1.170 kB y el `DETACH` con `DROP`, 178 kB:
el segundo número casi no se movió, el primero bajó con las filas.

> 🩻 **Esto sí funciona igual** en los tres motores: páginas de tamaño fijo, valores grandes fuera de la fila, y
> particionado por rango con *pruning*. Cambian los nombres y los tamaños por defecto.

---

## 🔀 6. El contraste: dónde otro motor cambia la decisión

**MySQL tiene un límite de paquete**, y un PDF grande lo cruza. `max_allowed_packet` vale 64 MB en MySQL 9.7: un
PDF de 10 MB entra, y uno de 70 MB, enviado con el driver del curso (`PyMySQL`), termina así:

```text
max_allowed_packet: 67108864
10 MB: guardado
70 MB: OperationalError: (2006, "MySQL server has gone away (BrokenPipeError(32, 'Broken pipe'))")
```

El servidor corta la conexión, y el cliente no recibe un "paquete demasiado grande" sino un "el servidor se fue".
El contador `Aborted_clients` sube en uno. La decisión que cambia: en MySQL, guardar archivos en la base tiene un
techo que no depende del tipo de columna (`LONGBLOB` acepta hasta 4 GB) sino de la configuración del servidor y del
cliente, y hay que subirla en los dos.

> 🪞🔒 **Apuesta sin resolver: Oracle.** Hipótesis: un BLOB de 90 kB en una columna `SecureFiles` se guarda fuera
> de la fila (el almacenamiento en la fila solo alcanza para unos 4.000 bytes), y una consulta que lee solo los
> metadatos no toca sus bloques, como TOAST en Postgres. Condiciones: una tabla con 2.000 filas como
> `staging.report_pdf_bytea`, y la consulta por fecha con `SET AUTOTRACE TRACEONLY STATISTICS` en `sqlplus`
> ([`a03`](a03-clis-de-los-motores.md#️-oracle--sqlplus)). El mecanismo, en la documentación oficial: *SecureFiles
> LOB Storage* (en las referencias). 📝 No publicamos números de Oracle; el porqué está en
> [`a09`](a09-licencias-publicacion-y-riesgo.md).

---

## 🪞 7. Tu instinto dice… y la apuesta

**Tu instinto dice** que el orden de las columnas importa, porque lo leíste en cualquier guía de Postgres: poner
las de 8 bytes primero y las chicas al final. Es cierto, y la tabla de protocolos de prueba lo demuestra con un 21 %.

> 🪞 **Apuesta antes de ejecutar** (escrita el 30/09/2026, al diseñar esta fase). *"Reordenar las columnas de
> `result` reduce su tamaño en al menos un 10 %."*
> **Resultado:** **perdida.** Reordenada, `result` ocupa **exactamente lo mismo**: 87.835 bloques, 686 MB. El
> promedio de bytes por fila baja de 54,8 a 49,8, y la diferencia se pierde en el redondeo a 8 bytes de cada fila.

La regla es correcta para las filas de ancho fijo con tipos mezclados. `result`, después de la Fase 08, tiene un
solo campo de 8 bytes (`recorded_at`), dos `integer` y cinco de largo variable: no hay relleno que ahorrar. El
ahorro de tamaño de `result` no está en el orden de sus columnas; está en lo que la Fase 08 ya sacó (la unidad y el
rango repetidos) y en lo que la Fase 10 decide (el ancho de sus identificadores).

---

## 💥 8. El punto de rotura

La rotura de esta fase es la de la sección 6, y vale la pena repetir lo que enseña: **el error de un archivo
demasiado grande no dice que el archivo es demasiado grande.** En el portal de 2013, con PHP y MySQL, un PDF de
más de 64 MB habría aparecido en el registro de la aplicación como una caída del servidor. Con un PDF de informe de
93 kB en promedio no pasa; con una orden escaneada en alta resolución, sí.

Y la otra rotura, la de Postgres, es menos ruidosa. Una fila con una fecha sin partición:

```text
ERROR:  no partition of relation "result_by_month" found for row
DETAIL:  Partition key of the failing row contains (recorded_at) = (2026-11-02 09:00:00).
```

Las particiones por rango tienen que existir **antes** de que llegue el mes. El primer resultado de noviembre falla
si nadie creó la partición de noviembre, y el laboratorio no puede dejar de cargar resultados. La salida es crear
las particiones por adelantado, o una partición `DEFAULT` que reciba lo que no tiene lugar, sabiendo que después
habrá que mudarlo.

---

## ⚰️ 9. Autopsia: los PDF de 2013, guardados "para que no se pierdan"

**1. La decisión.** *"El portal genera un PDF por informe. Lo guardamos también en la base, para que no se pierda."*
2013, con el portal nuevo.

**2. Por qué era razonable.** La base era lo único que se respaldaba en serio. Una carpeta de archivos en el
servidor no tenía respaldo, ni permisos, ni nadie que la cuidara; una columna `varbinary(max)` sí. Y un PDF guardado
con su protocolo, en la misma transacción, no se pierde ni se separa de su fila.

**3. Qué pasó después.** En el listado de la caja, los PDF son 106 GB, y las órdenes escaneadas 378 GB, contra 2 GB
de filas. En la base de verdad, 1,1 TB de 1,4. En 2014, con los archivos adentro, la base llegó al límite de 10 GB de
SQL Server Express en once meses, y hubo que comprar la licencia Standard. Y el respaldo completo tarda seis horas,
casi todas copiando archivos que no cambian nunca.

**4. Cuánto cuesta salir.** Una tabla como `staging.report_file` (ruta, tamaño y SHA-256), un almacén de archivos
con su propio respaldo, y una migración que saca cada archivo, lo escribe afuera, verifica el hash y recién
entonces lo borra de la base. Sobre 484 GB de la caja M, es una tarea de días, no de una noche.

**5. Qué lo habría cambiado.** Ver que **el PDF es un derivado**: se genera desde los resultados, y lo que hay que
guardar con garantías es el resultado firmado. Guardar el hash del PDF entregado alcanza para probar qué se entregó.

**Antes y después, con números:** 189 MB por cada 2.000 informes dentro de la base, contra 312 kB de rutas y hashes,
y un respaldo de la base que deja de copiar archivos.

---

## 📖 10. Traducción

| Concepto | Access / T-SQL | Postgres | MySQL | Oracle |
|---|---|---|---|---|
| página | 4 KB (Jet); 8 KB (SQL Server) | 8 KB | 16 KB | 8 KB por defecto |
| valor fuera de la fila | `varbinary(max)` fuera de la fila | TOAST | páginas de desbordamiento (`LONGBLOB`) | `SecureFiles` LOB |
| archivo como objeto | OLE en Access; `FILESTREAM` | objeto grande (`lo_*`) | — | `BFILE` |
| tabla ordenada por la clave | índice *clustered* | `CLUSTER` (una vez, no se mantiene) | siempre: la tabla es su clave | tabla organizada por índice |
| espacio libre por página | `FILLFACTOR` de índices | `fillfactor` | `MERGE_THRESHOLD` (índices) | `PCTFREE` |
| particionado por rango | `PARTITION FUNCTION` | `PARTITION BY RANGE` | `PARTITION BY RANGE` | `PARTITION BY RANGE`, `INTERVAL` |

Hacia la NoSQL Lite: un documento con el PDF adentro tiene el mismo problema y otro límite (16 MB por documento en
Mongo), y la misma salida: el archivo afuera, la referencia adentro. El diccionario completo está en
[`a07`](a07-diccionario-y-glosario.md).

---

## ⚖️ 11. Veredicto honesto: cuándo NO usar esto

**Cuándo sí va el archivo en la base.** Cuando la consistencia transaccional importa más que el tamaño: un archivo
que tiene que existir si y solo si existe su fila, y que se escribe en la misma transacción. Cuando los archivos son
chicos (un PDF de informe de 93 kB lo es; una orden escaneada de 2,4 MB empieza a no serlo). Y cuando un solo
respaldo es una ventaja real: un laboratorio de cinco personas sin nadie que cuide un almacén de archivos está
mejor con todo en la base que con una carpeta que nadie respalda. Esa era la situación de 2013.

**Cuándo no particionar.** Cuando la tabla no es grande o las consultas no filtran por la clave de partición. Una
consulta por paciente sobre `result_by_month` recorre las 223 particiones; el *pruning* solo existe si el `WHERE`
habla del mes. Y cuando nadie va a crear las particiones del mes que viene.

**Cuándo no reordenar columnas.** Cuando son de largo variable, como en `result`: se gana nada y se reescribe la
tabla entera. Reordenar es una decisión de diseño que se toma al crear la tabla, mirando sus tipos; hacerlo después
cuesta una copia completa y un bloqueo, y solo vale cuando hay columnas de ancho fijo mezcladas, como en la tabla de
prueba del 21 %.

Las cinco preguntas, para lo que enseñó esta fase:

- **Frontera transaccional:** el archivo dentro de la base entra en la transacción; afuera, no, y el hash es lo que
  queda de la garantía.
- **Consultas conocidas:** "los resultados de un mes", que el particionado convierte en una partición.
- **Unidad de lectura:** el informe sin su PDF, casi siempre; TOAST lo respeta.
- **Saltos:** ninguno nuevo.
- **Exactitud o parecido:** exactitud, y el SHA-256 la da para un archivo que vive afuera.

---

## ⚠️ 12. Errores comunes y diagnóstico

- **`MySQL server has gone away` al guardar un archivo.** 🩺 `SELECT @@max_allowed_packet;` y el tamaño del
  archivo. Si el archivo es más grande, el servidor cortó la conexión.
- **`no partition of relation … found for row`.** 🩺 Falta la partición del período. Créala antes de que llegue, o
  agrega una `DEFAULT`.
- **Una tabla que no achica después de un `DELETE` masivo.** 🩺 `pg_table_size` igual: las filas muertas siguen
  ocupando hasta el `VACUUM`, y el espacio se reusa pero no se devuelve. Para sacar períodos enteros, particiona.
- **Una consulta de metadatos lenta sobre una tabla con archivos.** 🩺 Mira los bloques: si son muchos, la consulta
  está leyendo los valores TOAST (un `SELECT *`, una función sobre el archivo).
- **`pg_largeobject` crece aunque se borraron las filas.** 🩺 Un objeto grande no se borra con la fila que guarda su
  OID: `SELECT count(*) FROM pg_largeobject_metadata WHERE oid NOT IN (…)` cuenta los huérfanos. Al volver a correr
  `02_report_files.sql` antes de corregirlo, `pg_largeobject` pasó de 241 a 482 MB con 2.000 huérfanos. Se borran
  con `lo_unlink` (o `vacuumlo`), y el espacio vuelve con `VACUUM FULL pg_largeobject`.

---

## 📋 13. Checklist de validación

```text
[ ] los cuatro scripts de src/09-el-tamano-de-las-cosas/ corren en orden sobre el modelo de --model
[ ] staging.file_listing suma 484 GB en 2.190.876 archivos
[ ] result reordenada ocupa los mismos 87.835 bloques; la tabla de booleanos baja de 12.414 a 9.767
[ ] los 2.000 PDF: 189 MB en bytea, 241 MB como objeto grande, 312 kB como ruta y hash
[ ] la consulta de un mes lee 1.173 bloques en la particionada y 87.808 en la entera
[ ] el PDF de 70 MB corta la conexión en MySQL
```

---

## 🧪 14. Ejercicios (24)

## 🟢 Fácil — medir el tamaño (1–7)

### 🟢 Ejercicio 1 — La página

Consulta el tamaño de página en Postgres y en MySQL.

**Objetivo:** 8.192 y 16.384, y qué se lee cuando el plan dice "un bloque".

[Solución](soluciones/09-el-tamano-de-las-cosas.md#ejercicio-1)

### 🟢 Ejercicio 2 — El listado

Carga `archivos/listado.csv` con `01_file_listing.sql` y resúmelo por tipo.

**Objetivo:** 1.194.978 PDF que suman 106 GB y 995.898 órdenes que suman 378 GB.

[Solución](soluciones/09-el-tamano-de-las-cosas.md#ejercicio-2)

### 🟢 Ejercicio 3 — Filas contra archivos

Compara el tamaño de `legacy` con el del listado.

**Objetivo:** 2.058 MB contra 484 GB, y por qué en la base de verdad la proporción es otra.

[Solución](soluciones/09-el-tamano-de-las-cosas.md#ejercicio-3)

### 🟢 Ejercicio 4 — Los tipos de `result`

Lista las columnas de `alameda.result` con su largo y su alineación desde `pg_attribute` y `pg_type`.

**Pregunta:** ¿cuántas columnas tienen largo fijo?

[Solución](soluciones/09-el-tamano-de-las-cosas.md#ejercicio-4)

### 🟢 Ejercicio 5 — `result` reordenada

Corre `03_alignment.sql` y compara los bloques de `result` en los dos órdenes.

**Objetivo:** 87.835 en los dos.

[Solución](soluciones/09-el-tamano-de-las-cosas.md#ejercicio-5)

### 🟢 Ejercicio 6 — `fillfactor`

Copia `alameda.lab_order` en una tabla con `fillfactor = 70` y compara.

**Objetivo:** 68 MB contra 97 MB, y para qué es ese espacio.

[Solución](soluciones/09-el-tamano-de-las-cosas.md#ejercicio-6)

### 🟢 Ejercicio 7 — El PDF en TOAST

Corre `02_report_files.sql` y mide la tabla y su tabla TOAST.

**Objetivo:** 120 kB y 187 MB, y el nombre de la tabla TOAST.

[Solución](soluciones/09-el-tamano-de-las-cosas.md#ejercicio-7)

## 🟡 Intermedio — dentro y fuera de la fila (8–14)

### 🟡 Ejercicio 8 — Metadatos sin el PDF

Mide con `EXPLAIN (ANALYZE, BUFFERS)` la consulta por fecha que no pide el PDF, la que pide su largo y la que lo lee.

**Objetivo:** 15, 15 y 7.862 bloques, y por qué el largo no lee el PDF.

[Solución](soluciones/09-el-tamano-de-las-cosas.md#ejercicio-8)

### 🟡 Ejercicio 9 — El objeto grande

Explica por qué los mismos PDF ocupan 241 MB como objetos grandes y 189 MB en TOAST.

**Objetivo:** el tamaño de cada trozo de `pg_largeobject` y cuántos hay.

[Solución](soluciones/09-el-tamano-de-las-cosas.md#ejercicio-9)

### 🟡 Ejercicio 10 — Ruta y hash

Verifica que el SHA-256 de `staging.report_file` coincide con el de cada PDF.

**Objetivo:** 2.000 de 2.000, y qué demostraría un hash distinto.

[Solución](soluciones/09-el-tamano-de-las-cosas.md#ejercicio-10)

### 🟡 Ejercicio 11 — El relleno que sí se ahorra

Mide las dos tablas de protocolos de prueba de `03_alignment.sql`.

**Objetivo:** 72 contra 51 bytes por fila y 97 contra 76 MB.

[Solución](soluciones/09-el-tamano-de-las-cosas.md#ejercicio-11)

### 🟡 Ejercicio 12 — InnoDB en orden de clave

Copia `legacy.Protocolos` de MySQL a una tabla insertada en orden de clave, y compara las páginas del índice primario.

**Objetivo:** 6.441 contra 6.184, y de dónde salen las claves fuera de orden.

[Solución](soluciones/09-el-tamano-de-las-cosas.md#ejercicio-12)

### 🟡 Ejercicio 13 — El índice secundario en dos motores

Crea un índice por paciente sobre los protocolos en MySQL y en Postgres, y compara su tamaño.

**Objetivo:** 21,5 MB contra 14 MB, y qué guarda cada uno para llegar a la fila.

[Solución](soluciones/09-el-tamano-de-las-cosas.md#ejercicio-13)

### 🟡 Ejercicio 14 — Los archivos por año

Suma el listado por año y por tipo.

**Pregunta:** ¿qué pasó en 2012 y qué pasó en 2020?

[Solución](soluciones/09-el-tamano-de-las-cosas.md#ejercicio-14)

## 🟠 Difícil — el particionado (15–20)

### 🟠 Ejercicio 15 — Particionar `result`

Corre `04_result_by_month.sql` y cuenta las particiones y su tamaño total.

**Objetivo:** 223 particiones y 692 MB.

[Solución](soluciones/09-el-tamano-de-las-cosas.md#ejercicio-15)

### 🟠 Ejercicio 16 — El *pruning*

Mide las glucemias cargadas en octubre de 2024 en la tabla entera y en la particionada.

**Objetivo:** 87.808 contra 1.173 bloques, y la línea del plan que muestra la partición.

[Solución](soluciones/09-el-tamano-de-las-cosas.md#ejercicio-16)

### 🟠 Ejercicio 17 — Desprender un mes

Mide el WAL de sacar enero de 2025 con `DELETE` y con `DETACH PARTITION` y `DROP`.

**Objetivo:** 20 MB contra 179 kB.

[Solución](soluciones/09-el-tamano-de-las-cosas.md#ejercicio-17)

### 🟠 Ejercicio 18 — El PDF de 70 MB

Guarda en MySQL un archivo de 10 MB y uno de 70 MB con PyMySQL.

**Objetivo:** el error literal, y dónde hay que subir el límite.

[Solución](soluciones/09-el-tamano-de-las-cosas.md#ejercicio-18)

### 🟠 Ejercicio 19 — El respaldo

Con el listado y el tamaño de la base, estima qué parte de un respaldo completo son archivos.

**Objetivo:** el porcentaje, y cuánto queda si los archivos salen.

[Solución](soluciones/09-el-tamano-de-las-cosas.md#ejercicio-19)

### 🟠 Ejercicio 20 — Noviembre sin partición

Inserta un resultado con fecha de noviembre de 2026 en la tabla particionada.

**Objetivo:** el error literal, y las dos formas de evitarlo.

[Solución](soluciones/09-el-tamano-de-las-cosas.md#ejercicio-20)

## 🔴 Muy difícil — decidir (21–24)

### 🔴 Ejercicio 21 — El informe firmado

Decide dónde vive el PDF del informe que firma Norma, sabiendo que tiene que poder probarse años después.

**Objetivo:** el esquema, el almacén y qué garantiza cada parte.

[Solución](soluciones/09-el-tamano-de-las-cosas.md#ejercicio-21)

### 🔴 Ejercicio 22 — Sacar el terabyte

Diseña la migración de los archivos de la base a un almacén externo sin perder ninguno.

**Objetivo:** los pasos, la verificación por hash y el orden en que se borra.

[Solución](soluciones/09-el-tamano-de-las-cosas.md#ejercicio-22)

### 🔴 Ejercicio 23 — El LOB de Oracle

Resuelve en tu máquina la apuesta 🪞🔒 de la sección 6.

**Objetivo:** explicar el resultado con la documentación de Oracle, sin publicar ningún número.

[Solución](soluciones/09-el-tamano-de-las-cosas.md#ejercicio-23)

### 🔴 Ejercicio 24 — ¿Por mes o por sede?

Decide la clave de partición de `result` para Alameda, con las consultas que conoces.

**Objetivo:** la decisión, y la consulta que empeora con ella.

[Solución](soluciones/09-el-tamano-de-las-cosas.md#ejercicio-24)

---

## 📚 15. Referencias

**Documentación oficial**

- **Disposición física de una página en Postgres 18** — https://www.postgresql.org/docs/18/storage-page-layout.html —
  la cabecera de página, la de fila y la alineación.
- **TOAST** — https://www.postgresql.org/docs/18/storage-toast.html — cuándo un valor sale de la fila.
- **Particionado en Postgres 18** — https://www.postgresql.org/docs/18/ddl-partitioning.html — *pruning*, `DETACH`
  y la partición `DEFAULT`.
- **`max_allowed_packet` en MySQL 9.7** — https://dev.mysql.com/doc/refman/9.7/en/packet-too-large.html — el
  límite, y por qué el error a veces es "server has gone away".
- **SecureFiles LOB Storage en Oracle 23** — https://docs.oracle.com/en/database/oracle/oracle-database/23/adlob/ —
  el almacenamiento de los LOB dentro y fuera de la fila.

**Papers y libros**

- **Hironobu Suzuki, *The Internals of PostgreSQL*** — https://www.interdb.jp/pg/ — páginas, filas y TOAST, con
  diagramas.
- **Jeremy Cole, "The physical structure of InnoDB index pages"** — https://blog.jcole.us/innodb/ — cómo InnoDB
  guarda la tabla en su clave primaria.

**Orden de lectura sugerido:** la disposición de la página antes de la sección 5.2; TOAST antes de la 5.3; Cole
antes de la 5.4.

> ⚠️ Las URL y sus contenidos cambian. Se consultaron el 14/10/2026.

---

## 🏁 16. Resultado de la fase

```text
EL TAMAÑO DE ALAMEDA · perfil M
  filas (legacy)           2.058 MB
  archivos (listado)       484 GB · PDF 106 GB · órdenes 378 GB
EL ORDEN DE LAS COLUMNAS
  result                   87.835 bloques en los dos órdenes · la apuesta, perdida
  booleanos entre bigint   12.414 → 9.767 bloques · −21 %
EL PDF, 2.000 INFORMES
  bytea / objeto grande / ruta y hash     189 MB / 241 MB / 312 kB
  metadatos contra contenido              15 contra 7.862 bloques
INNODB
  en orden de fecha / de clave            6.441 / 6.184 páginas
EL PARTICIONADO
  un mes                                  1.173 contra 87.808 bloques
  sacar un mes                            179 kB de WAL contra 20 MB
```

> **La señal de que quedó bien:** *"Sé de qué está hecho cada gigabyte de la base, cuál de ellos tiene que estar
> adentro, y cuánto cuesta sacar un mes."*

> 🏷️ **No cierres la fase sin el tag.** Con el checklist en verde y `git status` limpio:
>
> ```bash
> git tag -a fase-09-el-tamano-de-las-cosas -m "F09 cerrada: páginas y relleno medidos, el PDF de tres formas, InnoDB en su clave, y result particionado por mes"
> ```
>
> Commits de la fase con prefijo `f09:`, los de ejercicio `f09 ej17: …`.
