# 🗂️ Fase 11 — Índices y lo que cuestan: qué compra cada uno y quién lo paga

> **Curso:** Ruta SQL · Fase 11 de 27 · Bloque II — La física y el tuning · **10 h**
> **Motores:** PostgreSQL `pgvector/pgvector@sha256:2358fcba361e…` · contraste MySQL `mysql@sha256:e2bde46db656…` · —
> **Entorno de ejecución:** SQL
> **Perfil de volumen:** M, con el modelo de `uv run lab load --profile m --model`
> **El dolor de Alameda:** el `AutoIndex` de Access, trasladado intacto a SQL Server por el asistente de *upsizing* (historia §3, 2011)
> **Depende de:** Fase 10 · **Habilita:** Fase 12
> **Apéndices de apoyo:** a03, a04, a07, a08
> **Fecha de verificación ejecutada:** 14/10/2026
> **Objetivo:** medir lo que cada tipo de índice compra en bloques leídos y lo que cuesta en bytes de WAL y en
> actualizaciones HOT perdidas, y decidir cuándo no indexar.

---

## 🧭 1. Dónde estamos

La [Fase 10](10-identificadores.md) eligió la clave y midió lo que cuesta en cada índice. Esta fase mide los índices
mismos. Hasta aquí, todas las consultas del curso recorrieron tablas enteras a propósito: la [Fase 08](08-los-dos-extremos-del-mismo-error.md)
comparó cuatro modelos con los mismos índices mínimos, y su ejercicio 15 mostró que un índice sobre el valor ni
siquiera bajaba los bloques. Era una advertencia: **un índice no es una mejora; es una apuesta** sobre qué consultas
van a llegar, que se paga en cada escritura.

El dolor de Alameda es el contrario del que esperaría un curso de rendimiento: no faltan índices, sobran. Access tenía
una opción que indexaba sola cualquier columna con ciertos nombres, y el asistente de 2011 los pasó a SQL Server.

---

## 🎯 2. Objetivos de esta fase

1. Leer en un plan de Postgres 18 qué índice se usó y cuántas veces se buscó (`Index Searches`).
2. Elegir el orden de las columnas de un índice compuesto, y reconocer el *skip scan*.
3. Usar índices parciales, de expresión, con `INCLUDE`, GIN y BRIN donde cada uno compra algo.
4. Medir el costo de escritura de cada índice en bytes de WAL por fila.
5. Medir las actualizaciones HOT y lo que las mata.

---

## 🚫 3. Qué NO entra todavía

- **Las estadísticas que usa el optimizador para elegir un índice** → [Fase 12](12-estadisticas-y-cardinalidad.md).
- **Cómo cambia el plan con los parámetros de una sentencia preparada** → [Fase 13](13-el-optimizador-en-tres-motores.md).
- **El mantenimiento de índices (`REINDEX`, el *bloat* en el tiempo)**: operación, fuera del curso.

---

## 🏚️ 4. El dolor, en la caja

> 🏚️ **La documentación de Access, sobre la opción *AutoIndex on Import/Create*:** *"Access automatically indexes any
> fields with names that match the characters entered here"* (las referencias).

La opción toma una lista de comienzos o finales de nombre de campo, y Access indexa cualquier campo que coincida, al
crearlo o al importarlo. La documentación oficial no da la lista que traía la instalación; los foros de usuarios de la
época la reportan como `ID;key;code;num`. Con esa lista, sobre los nombres de columna de la caja:

```text
 columnas | tablas
----------+--------
      135 |     98
(1 row)
```

**135 índices en 98 tablas**, que nadie pidió. En `Protocolos`, cuatro (`IdProtocolo`, `IdPaciente`, `IdObraSocial`,
`IdMedico`); en `ResultadoItem`, dos. Algunos sirven, porque una columna que termina en `Id` suele ser una clave
foránea; otros no los usa ninguna consulta, y todos se escriben en cada `INSERT`. El asistente de *upsizing* de 2011
los convirtió en índices de SQL Server sin preguntar, y la caja no los trae (la exportación de `ALAMEDA.sql` no
incluye índices): esta fase mide lo que costaban. La regla tenía su lógica: en la mayoría de los esquemas, una columna que se llama
`IdAlgo` es la que se usa para unir tablas, y unir sin índice era lo más lento que hacía Access. Lo que la regla no podía
saber es cuáles de esas uniones se hacían de verdad, ni cuánto se escribía en cada tabla. El `Numero` de los
comprobantes también entraba, por empezar con `num`, y un comprobante se busca por su punto de venta y su número juntos, no por el número solo.

---

## 🧩 5. Lo que compra cada índice

Las mediciones de las secciones 5.1 a 5.4 usan `staging.result_recent` (`03_index_kinds.sql`): los 3.975.626
resultados de 2024 y 2025, copiados **en el orden de su fecha de carga**, como crece una tabla que solo recibe filas
nuevas.

### 5.1 El B-tree, el orden de las columnas y el *skip scan*

Un índice compuesto está ordenado por su primera columna, y dentro de ella por la segunda. Las glucemias cargadas en
octubre de 2024, con los dos órdenes posibles:

| Índice | Bloques | `Index Searches` |
|---|---|---|
| `(analyte_code, recorded_at)` | 37 | 1 |
| `(recorded_at, analyte_code)` | 593 | 1 |

Con la determinación primero, las glucemias de octubre están juntas en el índice: un tramo de 37 bloques. Con la fecha
primero, el índice recorre todo octubre, todas las determinaciones, y descarta las que no son glucemia. **La columna
de igualdad va primero, la de rango después.**

¿Y si la consulta solo filtra por la fecha? Hasta Postgres 17, el índice `(analyte_code, recorded_at)` no servía sin la
primera columna. Postgres 18 trae el ***skip scan***: salta de un código de determinación al siguiente y, dentro de cada
uno, busca el rango de fechas. El plan lo dice en una línea nueva:

```text
   ->  Index Only Scan using result_recent_analyte_code_recorded_at_idx on result_recent (actual rows=5397.00 loops=1)
         Heap Fetches: 0
         Index Searches: 65
         Buffers: shared hit=85 read=154
```

**65 búsquedas** en un solo índice, 239 bloques, para los resultados de un día. Funciona porque la primera columna tiene
pocos valores (33 determinaciones); con una primera columna de millones de valores, el salto no conviene, y el
optimizador no lo elige.

### 5.2 Parciales y de expresión

Un índice **parcial** indexa solo las filas que cumplen una condición. `result_recent_glu_value_idx` indexa el valor de
las glucemias y nada más: **5.232 kB**, contra los 110 MB de un índice compuesto sobre toda la tabla. Para "glucemias sin
calificador mayores que 250 en 2024 y 2025":

| Con | Bloques |
|---|---|
| el índice parcial | 11.747 |
| sin él (el compuesto por determinación) | 29.592 |

La mayor parte de los 11.747 son visitas a la tabla: las 10.137 glucemias que pasan el filtro están repartidas en miles de
páginas. El índice encuentra rápido, y la tabla cobra lo suyo.

Un índice **de expresión** indexa el resultado de una función. Es la salida que la [Fase 08](08-los-dos-extremos-del-mismo-error.md)
dejó abierta para el EAV: indexar el valor ya convertido. Sobre `staging.result_eav`, parcial y de expresión a la vez:

```sql
-- postgres
CREATE INDEX result_eav_glu_parsed_idx ON staging.result_eav
    ((CASE WHEN value ~ '^[0-9]+([.,][0-9]+)?$' THEN replace(value, ',', '.')::numeric END))
    WHERE analyte_code = 'GLU';
```

Las glucemias mayores que 250 de todas las épocas leen 27.823 bloques. La misma consulta con la conversión escrita
apenas distinto (`::numeric(10,2)` en lugar de `::numeric`) lee **136.180**: el optimizador solo usa un índice de
expresión si la consulta repite la expresión exacta. Aquí todavía lo usa como índice parcial, para recorrer todas las
glucemias, y filtra después. La regla que el EAV pedía ahora vive en dos lugares, el índice y cada consulta, y la [Fase
04](04-un-valor-un-hecho.md) ya mostró qué pasa con las reglas en dos lugares.

### 5.3 `INCLUDE`, *index-only scans* y el mapa de visibilidad

Si un índice tiene todas las columnas que pide la consulta, el motor puede no ir a la tabla: es un ***index-only scan***.
`INCLUDE` agrega columnas al índice sin ordenarlo por ellas. Con `(lab_order_id) INCLUDE (analyte_code, value_numeric)`,
los resultados de mil protocolos:

| Momento | `Heap Fetches` | Bloques |
|---|---|---|
| recién hecho el `VACUUM` | 0 | 44 |
| después de actualizar la mitad de esos protocolos | 10.560 | 1.149 |
| después de otro `VACUUM` | 170 | 84 |

El *index-only scan* tiene una condición: saber que la fila del índice es visible para todos sin mirar la tabla. Eso lo
dice el **mapa de visibilidad**, un bit por página que marca `VACUUM`. Una actualización apaga el bit de su página, y el
"solo índice" vuelve a ir a la tabla para cada fila de esas páginas. Un *index-only scan* sobre una tabla que se
actualiza mucho y se aspira poco es un índice común con más columnas.

### 5.4 GIN y BRIN

**GIN** indexa los elementos de un valor: las palabras de un texto, las claves de un `jsonb`, los trigramas de un nombre. Es
lo que la [Fase 05](05-una-persona-no-es-su-documento.md) necesitaba para buscar por parecido. Con un índice de trigramas
sobre el nombre normalizado de los pacientes (8.440 kB):

| Búsqueda | Pacientes | Con GIN | Sin índice |
|---|---|---|---|
| `LIKE '%SOSA GUTIERREZ%'` | 12 | 92 bloques | 2.112 bloques |
| `LIKE '%BUSTOS%'` | 4.662 | 1.895 bloques | 2.112 bloques |

El índice ayuda en proporción a lo que descarta. Un apellido común está en casi todas las páginas de la tabla.

**BRIN** guarda, por cada rango de 128 páginas, el mínimo y el máximo de la columna. Es diminuto (**24 kB** para la fecha de
casi cuatro millones de resultados, contra 110 MB de un B-tree) y solo sirve si la columna sigue el orden físico de la tabla.
Los resultados de un día, en dos copias de la misma tabla:

| Tabla | Correlación de `recorded_at` | Bloques | Filas descartadas al revisar |
|---|---|---|---|
| `result_recent`, copiada en orden de fecha | 1 | 136 | 12.317 |
| `result_as_is`, como se cargó `alameda.result` | 0,06 | 3.758 | 501.303 |

La correlación es la que mide `ANALYZE` entre el orden de los valores y el de las filas. `alameda.result` se cargó con un
`INSERT … SELECT` que no ordenó nada, y su fecha está casi al azar en las páginas: el BRIN marca casi todos los rangos como
posibles. Una tabla que crece por fecha la tiene ordenada sin esfuerzo, y ahí el BRIN es el índice más barato del curso.

> 🩻 **Esto sí funciona igual** en los dos motores que se miden: el B-tree, el orden de las columnas, el índice que cubre la
> consulta y el *skip scan* (MySQL lo tiene desde la 8.0.13). No existen en MySQL los índices parciales, GIN ni BRIN.

### 5.5 Lo que cuesta: bytes de WAL por fila

`01_write_cost.sql` carga 200.000 resultados de 2025 en la misma tabla con cero, uno, … ocho índices, y mide el WAL de cada
carga después de un `CHECKPOINT`:

> 📐 **Medición: el WAL por fila con cero a ocho índices** · 200.000 resultados · `pgvector/pgvector@sha256:2358fcba361e…` ·
> verificado el 14/10/2026
>
> | Índices | El que se agrega | Bytes de WAL por fila | Lo que agrega |
> |---|---|---|---|
> | 0 | — | 146,8 | |
> | 1 | `PRIMARY KEY (result_id)` | 190,4 | 43,6 |
> | 2 | `(lab_order_id)` | 250,8 | 60,4 |
> | 3 | `(analyte_code)` | 298,9 | 48,1 |
> | 4 | `(recorded_at)` | 365,0 | 66,1 |
> | 5 | `(analyte_code, value_numeric)` | 454,2 | 89,2 |
> | 6 | `(value_numeric)` | 528,9 | 74,7 |
> | 7 | `(lab_order_id, analyte_code)` | 607,5 | 78,6 |
> | 8 | `(value_text)` | 672,4 | 64,9 |

De qué están hechos los números. Sin índices, cada fila escribe en el WAL un registro de inserción en la tabla: la
cabecera del registro, la de la fila y la fila misma, unos 147 bytes para un resultado de unos 55. Cada índice agrega otro
registro por fila, con su propia cabecera, la referencia a la página del índice, el puntero a la fila y la clave; la clave
es lo único que cambia de un índice a otro, y es la parte chica. Por eso un índice sobre cuatro letras cuesta casi lo mismo
que uno sobre un número y una fecha. Y el `CHECKPOINT` antes de cada carga agrega las páginas enteras que se tocan por
primera vez: un índice que recibe sus entradas en desorden toca más páginas distintas y paga más.

**Con ocho índices, cada fila escribe 4,6 veces lo que escribe sola.** Y la tabla de 200.000 filas ocupa 11 MB, con 32 MB de
índices. **El total se repite; el reparto, no.** En tres corridas, sin índices y con ocho dieron siempre 146,7–146,8 y
672,4 bytes por fila, pero lo que agrega cada índice cambió: el primero sumó 43,6 en una y unos 16 en las otras dos, y en la
tercera el séptimo sumó 138,4 y el octavo 5,1, donde las otras dos daban 78,6 y 64,9. El curso no aisló la causa de ese
vaivén; lo que se puede afirmar es la suma, y que ninguna corrida ordenó los índices por su ancho.

### 5.6 HOT, y lo que lo mata

Una actualización en Postgres escribe una versión nueva de la fila. Si la versión nueva cabe en la **misma página** y la
actualización **no cambia ninguna columna indexada**, el motor la encadena a la vieja sin tocar los índices: es una
actualización **HOT** (*heap-only tuple*). Si no, cada índice de la tabla recibe una entrada nueva.

El flujo de correcciones de Alameda cambia el valor de un resultado. `02_hot_updates.sql` corrige unos diez mil resultados
de 2025 (uno de cada veinte, dispersos como las correcciones de verdad) en cuatro variantes de la misma tabla:

| Variante | Actualizaciones | HOT | WAL por actualización |
|---|---|---|---|
| tres índices, `fillfactor` 100 | 9.488 | 98 (1 %) | 2.272 bytes |
| tres índices, `fillfactor` 90 | 9.488 | 9.488 (100 %) | 1.363 bytes |
| cuarto índice sobre `recorded_at`, `fillfactor` 90 | 9.488 | 9.488 (100 %) | 1.364 bytes |
| cuarto índice sobre `value_numeric`, `fillfactor` 90 | 9.488 | 0 | 2.763 bytes |

Dos cosas matan HOT, y la tabla las separa. **La falta de lugar**: con las páginas llenas (`fillfactor` 100) no hay dónde
poner la versión nueva. **Un índice sobre la columna que cambia**: el cuarto índice sobre `recorded_at` no le hace nada a
HOT, el cuarto índice sobre `value_numeric` lo anula. Y cada actualización no HOT escribe el doble de WAL.

La primera versión del experimento corregía diez mil resultados seguidos, y con `fillfactor` 90 solo el 13 % fue HOT: el 10 %
libre de cada página alcanza para unas pocas filas, no para todas. El `fillfactor` es para correcciones dispersas.

---

## 🔀 6. El contraste: dónde otro motor cambia la decisión

**En MySQL, cada índice secundario carga la clave primaria**, y eso cose esta fase con la anterior: con un UUID como clave,
cada índice que se agrega es un 45 % más grande (Fase 10). Un índice de más en InnoDB cuesta más que en Postgres.

**MySQL rechaza el índice antes de que llegue el dato.** El mismo índice sobre una nota de texto libre:

```text
ERROR 1071 (42000) at line 3: Specified key was too long; max key length is 3072 bytes
ERROR 1170 (42000) at line 5: BLOB/TEXT column 'note' used in key specification without a key length
```

La primera, al declararlo sobre un `varchar(5000)`; la segunda, sobre un `text`, que solo se indexa por un prefijo
(`note(100)`). En Postgres el índice se crea, y el error llega con la primera nota larga (sección 8). La decisión que cambia:
en MySQL el límite se ve en el diseño; en Postgres, en producción.

Y el *skip scan* de MySQL se reconoce en su plan:

```text
        -> Covering index skip scan on protocolos_en_orden using protocolos_en_orden_sede_fecha_idx over '2024-10-15 00:00:00.000' <= Fecha < '2024-10-16 00:00:00.000'  (cost=36949 rows=146386)
```

---

## 🪞 7. Tu instinto dice… y la apuesta

**Tu instinto dice** que un índice cuesta en proporción a lo que guarda, y que hay un número de índices a partir del cual las
actualizaciones se arruinan. Las dos ideas tienen algo de cierto.

> 🪞 **Apuesta antes de ejecutar** (escrita el 30/09/2026, al diseñar esta fase). *"Cada índice adicional sobre `result` agrega
> bytes de WAL por fila en proporción a su ancho, y el cuarto índice anula las actualizaciones HOT del flujo de
> correcciones."*
> **Resultado:** **perdida, en sus dos mitades.** Ocho índices multiplican por 4,6 los bytes de WAL de cada fila, y lo que agrega
> cada uno no sigue su ancho: en la primera corrida, el de `value_text`, casi siempre nulo, sumó 64,9, y el de `analyte_code`,
> cuatro letras, 48,1; en otra, el reparto entre índices cambió, y tampoco siguió el ancho. Y el cuarto índice no anula
> HOT por ser el cuarto: sobre `recorded_at`, HOT sigue en el 100 %; sobre `value_numeric`, cae a 0.

La primera mitad confundió el tamaño del índice con el costo de escribirlo. Cada inserción en un B-tree es un registro de WAL
con su cabecera, el puntero a la fila y la clave; la clave es la parte chica. La segunda contó índices en lugar de mirar qué
columnas cubren. HOT no depende de cuántos índices hay sino de si alguno cubre lo que cambia, y del lugar libre en la página.

---

## 💥 8. El punto de rotura

Indexar las observaciones de texto libre, que en el modelo nuevo son `text` (`04_free_text_index.sql`):

```text
ERROR:  index row size 2984 exceeds btree version 4 maximum 2704 for index "order_note_note_idx"
DETAIL:  Index row references tuple (3,60) in relation "order_note".
HINT:  Values larger than 1/3 of a buffer page cannot be indexed.
Consider a function index of an MD5 hash of the value, or use full text indexing.
```

Una entrada de B-tree no puede ocupar más de un tercio de página: 2.704 bytes. El índice se creó sin problema sobre las 529
notas cortas del día; el error llegó con el `INSERT` de una nota de 3 kB, que no se pudo guardar. **Un índice puede impedir
que se guarde un dato.** El *hint* del motor dice las dos salidas: un índice sobre el MD5 del valor (que sirve para buscar
por igualdad y nada más) o búsqueda de texto completo (GIN), que es lo que se busca en un texto libre.

---

## ⚰️ 9. Autopsia: un índice por columna, "por las dudas"

**1. La decisión.** *"Que se indexe solo todo lo que termina en ID."* La opción de Access, que nadie tocó; y en 2011, *"que el
asistente pase todo como está"*.

**2. Por qué era razonable.** En Access, sin índices, cada búsqueda era lenta y la lentitud se veía. Un índice de más no se
veía nunca: la base era chica, las escrituras pocas, y el costo de un índice que no se usa es invisible hasta que hay mucho
para escribir.

**3. Qué pasó después.** 135 índices en 98 tablas, sin una consulta que los justificara. Medido sobre `result`: ocho índices
multiplican por 4,6 los bytes de WAL de cada fila, y ocupan casi tres veces la tabla (32 MB de índices para 11 MB de filas).
Y cada uno sobre una columna que se corrige mata HOT en esa columna.

**4. Cuánto cuesta salir.** Poco en el motor (`DROP INDEX`) y mucho en la decisión: saber cuáles se usan. Postgres lo cuenta en
`pg_stat_user_indexes.idx_scan`; MySQL, en `sys.schema_unused_indexes`, y deja probar con un índice invisible antes de
borrarlo.

**5. Qué lo habría cambiado.** Un índice por consulta conocida, no por columna: la clave primaria, las claves foráneas que se
recorren, y cada índice que una consulta medida pide, con su plan delante.

**Antes y después, con números:** 672 bytes de WAL por fila con ocho índices puestos por nombre, contra 251 con los dos que
piden las consultas de la Fase 08 (la clave y el protocolo).

---

## 📖 10. Traducción

| Concepto | Access / T-SQL | Postgres | MySQL | Oracle |
|---|---|---|---|---|
| índice parcial | índice filtrado (`WHERE`) | `CREATE INDEX … WHERE` | — | índice de función con `CASE` |
| índice de expresión | columna calculada indexada | `CREATE INDEX … ((expr))` | índice funcional (8.0.13) | índice basado en función |
| columnas incluidas | `INCLUDE` | `INCLUDE` | — (índice compuesto) | — (índice compuesto) |
| *skip scan* | — | *skip scan* (18) | *skip scan* (8.0.13) | *index skip scan* |
| índice por rangos de páginas | — | BRIN | — | *zone maps* (Exadata) |
| índices sin uso | `sys.dm_db_index_usage_stats` | `pg_stat_user_indexes` | `sys.schema_unused_indexes` | `V$OBJECT_USAGE` |
| actualización sin tocar índices | — | HOT | — | — |

Hacia la NoSQL Lite: un índice de Mongo cuesta lo mismo al escribir, y el instinto de indexar cada campo del documento es el
mismo `AutoIndex`. El diccionario completo está en [`a07`](a07-diccionario-y-glosario.md).

---

## ⚖️ 11. Veredicto honesto: cuándo NO usar esto

**Cuándo no indexar.** Cuando no hay una consulta conocida que el índice compre, medida. Cuando la tabla es chica (las 33
determinaciones, los 75 códigos de práctica): la recorrida entera cuesta menos que bajar por un árbol. Cuando la columna tiene
pocos valores y la consulta los pide casi todos (un índice por sede en una tabla donde el central tiene la mitad). Y cuando la
columna se actualiza mucho y la tabla vive de HOT, como el valor de un resultado: el índice sobre `value_numeric` que gana la
consulta clínica pierde todas las correcciones.

**Cuándo no agregar un índice para una consulta rara.** El informe mensual que corre una vez al mes puede leer la tabla
entera sin que nadie lo note; un índice para él se paga en cada una de las millones de escrituras del mes. La cuenta no es
"cuánto más rápida es la consulta" sino "cuántas veces corre la consulta contra cuántas veces se escribe la tabla". Para
`result`, que se escribe dos millones de veces al año en la caja M, un índice que sirve a una consulta mensual casi nunca
gana.

**Lo que no se mide aquí:** el costo de un índice en la lectura del resto (la memoria que ocupa, que deja menos para la tabla) y
en el mantenimiento. Los dos existen; el curso mide lo que se puede medir con la caja.

**Cuándo sí, sin dudar:** la clave primaria, las claves foráneas que se recorren en los joins, y el índice que una consulta
frecuente necesita para no leer la tabla entera, con su `EXPLAIN` antes y después.

Las cinco preguntas, para lo que enseñó esta fase:

- **Frontera transaccional:** cada índice está dentro de la transacción de cada escritura, y la alarga.
- **Consultas conocidas:** son las que deciden cada índice; sin ellas, un índice es una apuesta.
- **Unidad de lectura:** el *index-only scan* lee el índice como si fuera la tabla, si el mapa de visibilidad lo deja.
- **Saltos:** un índice por clave foránea recorrida.
- **Exactitud o parecido:** el B-tree para la exactitud, GIN para el parecido.

---

## ⚠️ 12. Errores comunes y diagnóstico

- **`index row size … exceeds btree version 4 maximum 2704`.** 🩺 Un valor de más de un tercio de página. Indexa su MD5 o usa
  GIN, según se busque por igualdad o por contenido.
- **`Specified key was too long; max key length is 3072 bytes` en MySQL.** 🩺 Un índice por prefijo, o un hash en una columna
  generada.
- **Un *index-only scan* con miles de `Heap Fetches`.** 🩺 El mapa de visibilidad está desactualizado: `VACUUM`, o revisa por qué
  autovacuum no llega.
- **Un BRIN que lee casi toda la tabla.** 🩺 `SELECT correlation FROM pg_stats …`: si está lejos de 1 o −1, la columna no sigue el
  orden físico.
- **Un índice de expresión que no se usa.** 🩺 Compara la expresión de la consulta con la del índice, carácter por carácter.
- **Actualizaciones lentas en una tabla con muchos índices.** 🩺 `n_tup_hot_upd` contra `n_tup_upd` en `pg_stat_user_tables`.

---

## 📋 13. Checklist de validación

```text
[ ] 01_write_cost.sql da ~147 bytes por fila sin índices y ~672 con ocho
[ ] 02_hot_updates.sql: 100 % HOT con fillfactor 90 y el cuarto índice sobre recorded_at; 0 con el de value_numeric
[ ] (analyte_code, recorded_at) lee 37 bloques y (recorded_at, analyte_code) 593 para las glucemias de un mes
[ ] el skip scan muestra Index Searches: 65
[ ] el BRIN lee 136 bloques en la copia ordenada y 3.758 en la cargada sin orden
[ ] el índice sobre note falla con la primera nota de 3 kB
```

---

## 🧪 14. Ejercicios (28)

## 🟢 Fácil — leer un índice (1–7)

### 🟢 Ejercicio 1 — El `AutoIndex` sobre la caja

Cuenta las columnas de `legacy` que empiezan o terminan con `id`, `key`, `code` o `num`.

**Objetivo:** 135 columnas en 98 tablas.

[Solución](soluciones/11-indices-y-lo-que-cuestan.md#ejercicio-1)

### 🟢 Ejercicio 2 — El compuesto bien ordenado

Cuenta las glucemias de octubre de 2024 con el índice `(analyte_code, recorded_at)`.

**Objetivo:** 37 bloques y una búsqueda.

[Solución](soluciones/11-indices-y-lo-que-cuestan.md#ejercicio-2)

### 🟢 Ejercicio 3 — El compuesto al revés

La misma consulta con `(recorded_at, analyte_code)`.

**Objetivo:** 593 bloques, y por qué.

[Solución](soluciones/11-indices-y-lo-que-cuestan.md#ejercicio-3)

### 🟢 Ejercicio 4 — El *skip scan*

Cuenta los resultados de un día con el índice `(analyte_code, recorded_at)` como único índice disponible.

**Objetivo:** `Index Searches: 65`.

[Solución](soluciones/11-indices-y-lo-que-cuestan.md#ejercicio-4)

### 🟢 Ejercicio 5 — El tamaño de un parcial

Compara el tamaño del índice parcial de las glucemias con el del compuesto.

**Objetivo:** 5.232 kB contra 110 MB.

[Solución](soluciones/11-indices-y-lo-que-cuestan.md#ejercicio-5)

### 🟢 Ejercicio 6 — El tamaño de un BRIN

Compara el BRIN sobre la fecha con un B-tree sobre la misma columna.

**Objetivo:** 24 kB contra 110 MB.

[Solución](soluciones/11-indices-y-lo-que-cuestan.md#ejercicio-6)

### 🟢 Ejercicio 7 — Un *index-only scan*

Lee el valor de los resultados de mil protocolos con el índice que los incluye, recién hecho el `VACUUM`.

**Objetivo:** `Heap Fetches: 0`.

[Solución](soluciones/11-indices-y-lo-que-cuestan.md#ejercicio-7)

## 🟡 Intermedio — lo que compra (8–14)

### 🟡 Ejercicio 8 — El mapa de visibilidad

Actualiza la mitad de esos protocolos, repite la lectura, aspira, y repite otra vez.

**Objetivo:** 0, 10.560 y 170 `Heap Fetches`.

[Solución](soluciones/11-indices-y-lo-que-cuestan.md#ejercicio-8)

### 🟡 Ejercicio 9 — El BRIN y el orden físico

Mide los resultados de un día con un BRIN en la copia ordenada y en la tabla como se cargó.

**Objetivo:** 136 contra 3.758 bloques, y las dos correlaciones.

[Solución](soluciones/11-indices-y-lo-que-cuestan.md#ejercicio-9)

### 🟡 Ejercicio 10 — El parcial, con y sin

Cuenta las glucemias sin calificador mayores que 250 con el índice parcial y sin él.

**Objetivo:** 11.747 contra 29.592 bloques.

[Solución](soluciones/11-indices-y-lo-que-cuestan.md#ejercicio-10)

### 🟡 Ejercicio 11 — La expresión exacta

Usa el índice de expresión del EAV con la conversión exacta y con una apenas distinta.

**Objetivo:** 27.823 contra 136.180 bloques.

[Solución](soluciones/11-indices-y-lo-que-cuestan.md#ejercicio-11)

### 🟡 Ejercicio 12 — GIN, selectivo y no

Busca `'%SOSA GUTIERREZ%'` y `'%BUSTOS%'` con el índice de trigramas y sin él.

**Objetivo:** 92 contra 2.112, y 1.895 contra 2.112.

[Solución](soluciones/11-indices-y-lo-que-cuestan.md#ejercicio-12)

### 🟡 Ejercicio 13 — El WAL sin índices

Mide el WAL de cargar las 200.000 filas en la tabla sin índices.

**Objetivo:** unos 147 bytes por fila, y de qué están hechos.

[Solución](soluciones/11-indices-y-lo-que-cuestan.md#ejercicio-13)

### 🟡 Ejercicio 14 — El WAL con ocho

Corre `01_write_cost.sql` entero.

**Objetivo:** unos 672 bytes por fila con ocho índices, y el tamaño de los índices contra la tabla.

[Solución](soluciones/11-indices-y-lo-que-cuestan.md#ejercicio-14)

## 🟠 Difícil — lo que cuesta (15–21)

### 🟠 Ejercicio 15 — ¿En proporción al ancho?

Con la tabla de `01_write_cost.sql`, compara lo que agrega cada índice con el ancho de su clave.

**Objetivo:** la relación, o la falta de ella, con números.

[Solución](soluciones/11-indices-y-lo-que-cuestan.md#ejercicio-15)

### 🟠 Ejercicio 16 — HOT con las páginas llenas

Corre la primera variante de `02_hot_updates.sql`.

**Objetivo:** 98 HOT de 9.488, y por qué.

[Solución](soluciones/11-indices-y-lo-que-cuestan.md#ejercicio-16)

### 🟠 Ejercicio 17 — HOT con lugar

Corre la segunda.

**Objetivo:** 9.488 de 9.488, y el WAL por actualización de cada una.

[Solución](soluciones/11-indices-y-lo-que-cuestan.md#ejercicio-17)

### 🟠 Ejercicio 18 — El cuarto índice

Corre la tercera y la cuarta.

**Objetivo:** 100 % y 0 %, y qué los separa.

[Solución](soluciones/11-indices-y-lo-que-cuestan.md#ejercicio-18)

### 🟠 Ejercicio 19 — Correcciones juntas

Cambia `02_hot_updates.sql` para que corrija diez mil resultados seguidos, y mide con `fillfactor` 90.

**Objetivo:** alrededor de un 13 % de HOT, y por qué el espacio libre no alcanza.

[Solución](soluciones/11-indices-y-lo-que-cuestan.md#ejercicio-19)

### 🟠 Ejercicio 20 — La nota larga

Corre `04_free_text_index.sql` y la variante que crea el índice antes de la nota larga.

**Objetivo:** el error en los dos momentos.

[Solución](soluciones/11-indices-y-lo-que-cuestan.md#ejercicio-20)

### 🟠 Ejercicio 21 — La nota larga en MySQL

Declara en MySQL el índice sobre un `varchar(5000)` y sobre un `text`.

**Objetivo:** los dos errores, y el índice por prefijo.

[Solución](soluciones/11-indices-y-lo-que-cuestan.md#ejercicio-21)

## 🔴 Muy difícil — decidir (22–28)

### 🔴 Ejercicio 22 — El índice sobre el MD5

Crea el índice que propone el *hint* y busca una nota por igualdad.

**Objetivo:** el plan, y qué búsquedas no sirve.

[Solución](soluciones/11-indices-y-lo-que-cuestan.md#ejercicio-22)

### 🔴 Ejercicio 23 — Qué índices se usan

Corre las consultas conocidas de las fases 08 a 11 sobre una tabla con los ocho índices, y cuenta cuáles se usaron.

**Objetivo:** la lista de los que sobran, con `pg_stat_user_indexes`.

[Solución](soluciones/11-indices-y-lo-que-cuestan.md#ejercicio-23)

### 🔴 Ejercicio 24 — Los índices de `result`

Propón el conjunto de índices de `alameda.result` para las consultas conocidas de Alameda.

**Objetivo:** cada índice con la consulta que lo pide y lo que cuesta al escribir y al corregir.

[Solución](soluciones/11-indices-y-lo-que-cuestan.md#ejercicio-24)

### 🔴 Ejercicio 25 — ¿BRIN o particionado?

Compara el BRIN de esta fase con el particionado por mes de la Fase 09.

**Objetivo:** cuándo alcanza el BRIN y cuándo hace falta particionar.

[Solución](soluciones/11-indices-y-lo-que-cuestan.md#ejercicio-25)

### 🔴 Ejercicio 26 — El *skip scan* en MySQL

Crea en MySQL un índice `(Sede, Fecha)` y consulta un día sin filtrar por sede.

**Objetivo:** la línea del plan que lo muestra.

[Solución](soluciones/11-indices-y-lo-que-cuestan.md#ejercicio-26)

### 🔴 Ejercicio 27 — Los 135 de 2011

De los 135 índices del `AutoIndex`, decide cuáles conservar en el modelo nuevo de `Protocolos` y `ResultadoItem`.

**Objetivo:** la lista, con la consulta conocida de cada uno.

[Solución](soluciones/11-indices-y-lo-que-cuestan.md#ejercicio-27)

### 🔴 Ejercicio 28 — Cuándo no indexar

Para `staging.file_listing` y para `alameda.analyte`, decide si llevan algún índice además de la clave.

**Objetivo:** la decisión, con la consulta y el tamaño de cada tabla.

[Solución](soluciones/11-indices-y-lo-que-cuestan.md#ejercicio-28)

---

## 📚 15. Referencias

**Documentación oficial**

- **Índices en Postgres 18** — https://www.postgresql.org/docs/18/indexes.html — compuestos, parciales, de expresión,
  `INCLUDE` e *index-only scans*.
- **BRIN** — https://www.postgresql.org/docs/18/brin.html — los rangos de páginas y la correlación.
- **HOT** — https://www.postgresql.org/docs/18/storage-hot.html — cuándo una actualización no toca los índices.
- **Optimización de rangos y *skip scan* en MySQL 9.7** — https://dev.mysql.com/doc/refman/9.7/en/range-optimization.html
- **Opciones de diseño de Access** — https://support.microsoft.com/en-us/access/customize-design-settings-for-objects-in-your-database
  — *AutoIndex on Import/Create*.

**Papers y libros**

- **Markus Winand, *SQL Performance Explained*** — https://use-the-index-luke.com — el orden de las columnas, los índices
  parciales y lo que cuesta escribir.
- **Goetz Graefe, "Modern B-Tree Techniques", *Foundations and Trends in Databases*, 2011** — el B-tree por dentro.

**Orden de lectura sugerido:** Winand antes de la sección 5.1; la página de HOT antes de la 5.6.

> ⚠️ Las URL y sus contenidos cambian. Se consultaron el 14/10/2026.

---

## 🏁 16. Resultado de la fase

```text
LO QUE COMPRA · resultados de 2024 y 2025 en orden de fecha
  compuesto bien / mal ordenado      37 / 593 bloques
  skip scan                          65 búsquedas, 239 bloques
  parcial                            5.232 kB · 11.747 contra 29.592 bloques
  BRIN                               24 kB · 136 bloques ordenado, 3.758 sin orden
  index-only                         0 → 10.560 → 170 Heap Fetches
LO QUE CUESTA · 200.000 filas
  WAL por fila                       146,8 sin índices · 672,4 con ocho
  HOT                                1 % lleno · 100 % con fillfactor 90 · 0 con un índice sobre el valor
LA ROTURA
  B-tree                             2.704 bytes por entrada · la nota de 3 kB no se guarda
```

> **La señal de que quedó bien:** *"Puedo decir qué consulta paga cada índice, cuánto le cuesta a cada escritura, y cuál de
> mis índices le quita HOT a las correcciones."*

> 🏷️ **No cierres la fase sin el tag.** Con el checklist en verde y `git status` limpio:
>
> ```bash
> git tag -a fase-11-indices-y-lo-que-cuestan -m "F11 cerrada: tipos de índice medidos, WAL por fila con cero a ocho índices, HOT y lo que lo mata, y el límite del B-tree"
> ```
>
> Commits de la fase con prefijo `f11:`, los de ejercicio `f11 ej24: …`.
