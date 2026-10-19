# ✅ Soluciones — Fase 19: JSON en los motores

> **Curso:** Ruta SQL · Solucionario de la [Fase 19](../19-json-en-los-motores.md)
> **Ejercicios:** 24 · **Perfil:** M, con la verdad de antibiogramas (`truth.antibiogram`, D46) · **Motores:** Postgres 18.6 y MySQL 9.7 de [`a02`](../a02-compose-de-la-ruta.md)
> **Fecha de verificación ejecutada:** 14/10/2026

> ⚠️ **Intenta el ejercicio antes de leer su solución.** Leída antes, solo te enseña a reconocerla.

Todas las soluciones suponen `19-json-en-los-motores/01_setup.sql` corrido en Postgres, y `04_mysql_setup.sql` en MySQL. Las consultas de los ejercicios 🟢 y 🟡 están ejecutadas, con su salida; los de 🟠 y 🔴 llevan rúbrica. Las medidas de WAL y de redo son de esta caja y de este orden de corridas: se repiten con la misma forma, pero no con el mismo número.

---

## 🟢 Fácil (1–8)

### Ejercicio 1

```sql
SELECT '{"a": 1}'::json @> '{"a": 1}'::json AS resultado;
```

```text
ERROR:  operator does not exist: json @> json
HINT:  No operator matches the given name and argument types.
```

**Por qué:** `@>` es un operador de `jsonb`. `json` guarda el texto y no tiene índices GIN ni operadores de contención. La solución es `::jsonb` o guardar la columna como `jsonb`.

### Ejercicio 2

```sql
SELECT culture_id, antibiogram ->> 'MEROPENEM' AS como_texto, antibiogram -> 'MEROPENEM' AS como_jsonb
FROM staging.culture_doc WHERE antibiogram ? 'MEROPENEM' ORDER BY culture_id LIMIT 3;
```

```text
 culture_id | como_texto | como_jsonb 
------------+------------+------------
         10 | S          | "S"
         18 | S          | "S"
         20 | S          | "S"
```

**Lectura:** `->>` devuelve texto sin comillas; `->` devuelve `jsonb`, con comillas. Comparar `->` con `'S'` falla en silencio. El filtro `?` elige solo los cultivos que tienen la clave: sin él, los de otros germenes devuelven nulo.

### Ejercicio 3

```sql
SELECT count(DISTINCT k) AS antibioticos, string_agg(DISTINCT k, ', ' ORDER BY k) AS lista
FROM staging.culture_doc, jsonb_object_keys(antibiogram) AS k
WHERE germ = 'Enterococcus faecalis';
```

```text
 antibioticos |                                 lista                                 
--------------+-----------------------------------------------------------------------
            5 | AMPICILINA, CIPROFLOXACINA, GENTAMICINA, NITROFURANTOINA, VANCOMICINA
```

### Ejercicio 4

```sql
SELECT count(*) AS con_algun_r FROM staging.culture_doc WHERE antibiogram @@ '$.* == "R"';
```

```text
 con_algun_r 
-------------
       50195
```

**Lectura:** `@@` evalúa el predicado de `jsonpath` y devuelve un booleano. `$.*` recorre todos los valores del objeto.

### Ejercicio 5

```sql
CREATE INDEX culture_doc_cipro_expr ON staging.culture_doc ((antibiogram ->> 'CIPROFLOXACINA'));
ANALYZE staging.culture_doc;
EXPLAIN (COSTS OFF) SELECT count(*) FROM staging.culture_doc WHERE antibiogram ->> 'CIPROFLOXACINA' = 'R';
EXPLAIN (COSTS OFF) SELECT count(*) FROM staging.culture_doc WHERE antibiogram ->> 'MEROPENEM' = 'R';
```

```text
   ->  Bitmap Heap Scan on culture_doc          -- CIPROFLOXACINA: usa el índice
         ->  Bitmap Index Scan on culture_doc_cipro_expr
   ->  Seq Scan on culture_doc                  -- MEROPENEM: no hay índice para esa expresión
```

**Lectura:** el índice de expresión responde a la expresión exacta y a ninguna otra. Por eso el curso prefiere GIN cuando la pregunta cambia de clave.

### Ejercicio 6

```sql
SELECT pg_column_size(antibiogram) AS bytes_documento,
       (SELECT sum(pg_column_size(l.*)) FROM staging.antibiogram_long l WHERE l.culture_id = c.culture_id) AS bytes_filas
FROM staging.culture_doc c WHERE culture_id = (SELECT min(culture_id) FROM staging.culture_doc WHERE person_id = 4977);
```

```text
 bytes_documento | bytes_filas 
-----------------+-------------
             221 |         633
```

**Lectura:** el documento es más chico que sus filas porque no repite la clave de la tabla (`culture_id`, `person_id`, `culture_date`, `germ`) por cada antibiótico. Las filas largas sí la repiten. Eso es parte de la diferencia de tamaño, y no solo el formato.

### Ejercicio 7

```sql
SELECT '{"a": "R", "b": "S"}'::jsonb = '{"b": "S", "a": "R"}'::jsonb AS iguales,
       '{"a": "R", "b": "S"}'::text  = '{"b": "S", "a": "R"}'::text  AS iguales_como_texto;
```

```text
 iguales | iguales_como_texto 
---------+--------------------
 t       | f
```

**Lectura:** `jsonb` no conserva el orden de las claves, así que la igualdad lo ignora. El texto, sí. Un `DISTINCT` o un `GROUP BY` sobre `jsonb` trata los dos documentos como iguales.

### Ejercicio 8

```sql
SELECT count(*) AS cuatro_o_mas_r
FROM staging.culture_doc c
WHERE (SELECT count(*) FROM jsonb_each_text(c.antibiogram) e WHERE e.value = 'R') >= 4;
```

```text
 cuatro_o_mas_r 
----------------
           2119
```

---

## 🟡 Intermedio (9–15)

### Ejercicio 9

```sql
CREATE INDEX ex_gin_ops  ON staging.culture_doc USING gin (antibiogram jsonb_ops);
CREATE INDEX ex_gin_path ON staging.culture_doc USING gin (antibiogram jsonb_path_ops);
SELECT pg_size_pretty(pg_relation_size('staging.ex_gin_ops'))  AS jsonb_ops,
       pg_size_pretty(pg_relation_size('staging.ex_gin_path')) AS jsonb_path_ops;
```

```text
 jsonb_ops | jsonb_path_ops 
-----------+----------------
 808 kB    | 816 kB
```

**Lectura:** en esta caja los dos pesan lo mismo. La ventaja de `jsonb_path_ops` que muestra la lección (527 bloques contra 1.632) es de selectividad: el índice lleva la ruta completa, así que `@>` con clave y valor no obliga a recheck de tantas filas. Si esperabas que `jsonb_path_ops` fuera mucho más chico, la caja dice que no; la regla general depende de cuánto pesan las claves.

### Ejercicio 10

```sql
CREATE INDEX ex_gin_path ON staging.culture_doc USING gin (antibiogram jsonb_path_ops);
SELECT count(*) AS cultivos_cipro_r,
       round(100.0 * count(*) / (SELECT count(*) FROM staging.culture_doc), 1) AS porcentaje
FROM staging.culture_doc WHERE antibiogram @> '{"CIPROFLOXACINA": "R"}';
EXPLAIN (ANALYZE, BUFFERS, COSTS OFF, TIMING OFF) SELECT count(*) FROM staging.culture_doc WHERE antibiogram @> '{"CIPROFLOXACINA": "R"}';
```

```text
 cultivos_cipro_r | porcentaje 
------------------+------------
            13303 |       22.2
   Bitmap Heap Scan on culture_doc ... Buffers: shared hit=1915
```

**Por qué el índice deja de ayudar:** el índice devuelve 13.303 cultivos, el 22 % de la tabla, y el heap los tiene repartidos sobre casi todas sus páginas. Leer 1.915 bloques con índice es lo mismo que leerlos todos sin él (1.920). A partir de un 15–20 % de la tabla, el *seq scan* suele ganar; aquí la medida lo confirma en el punto de empate.

### Ejercicio 11

```sql
CREATE TABLE staging.ex_doc AS SELECT * FROM staging.culture_doc;
ALTER TABLE staging.ex_doc ADD PRIMARY KEY (culture_id);
CREATE INDEX ex11_mero_btree ON staging.ex_doc ((antibiogram ->> 'MEROPENEM'));
VACUUM ANALYZE staging.ex_doc;
EXPLAIN (ANALYZE, BUFFERS, COSTS OFF, TIMING OFF) SELECT count(*) FROM staging.ex_doc WHERE antibiogram ->> 'MEROPENEM' = 'R';
CLUSTER staging.ex_doc USING ex11_mero_btree;
VACUUM ANALYZE staging.ex_doc;
EXPLAIN (ANALYZE, BUFFERS, COSTS OFF, TIMING OFF) SELECT count(*) FROM staging.ex_doc WHERE antibiogram ->> 'MEROPENEM' = 'R';
```

```text
   Buffers: shared hit=525 read=2    -- antes de CLUSTER: Index Scan con 600 filas
   Buffers: shared hit=15 read=2     -- después de CLUSTER
```

**Lectura:** antes, los 600 cultivos con meropenem resistente caen en páginas distintas (527 bloques). Después de `CLUSTER`, quedan juntos (17 bloques). Es un 31 veces menos de bloques en la misma consulta, sin cambiar la forma del documento. El costo: `CLUSTER` reescribe la tabla entera, y la orden se degrada con cada escritura nueva.

### Ejercicio 12

Ejecutado en MySQL 9.7 sobre copias de `staging.culture_doc` (el registro de la sesión y su salida en la sesión de verificación del 14/10/2026):

```sql
ALTER TABLE staging.ex12_virt ADD COLUMN cipro CHAR(1) GENERATED ALWAYS AS (JSON_UNQUOTE(JSON_EXTRACT(antibiogram, '$.CIPROFLOXACINA'))) VIRTUAL, ADD INDEX ix_cipro (cipro);
ALTER TABLE staging.ex12_stored ADD COLUMN cipro CHAR(1) GENERATED ALWAYS AS (JSON_UNQUOTE(JSON_EXTRACT(antibiogram, '$.CIPROFLOXACINA'))) STORED, ADD INDEX ix_cipro (cipro);
```

| Tabla | Tamaño (datos + índices) | `UPDATE` de 20.000 filas con `JSON_SET` |
|---|---:|---:|
| `ex12_virt` (VIRTUAL) | 17,0 MB | 311,6 ms |
| `ex12_stored` (STORED) | 15,0 MB | 282,2 ms |

**Lectura:** con `STORED` la columna se guarda en la fila, y con `VIRTUAL` se calcula al leer. En esta caja, la diferencia de tamaño y de tiempo de escritura es menor que el ruido de una corrida, así que la decisión se toma por la lectura: un índice sobre una columna `VIRTUAL` ya guarda el valor en el índice, y `STORED` es necesario sobre todo para operaciones que no son de índice. No hay una respuesta general en estas medidas.

### Ejercicio 13

*(de referencia, con rúbrica)*

Un índice multivalor de MySQL indexa los elementos de un arreglo dentro del documento: por ejemplo, los `culture_id` de la historia de un paciente, si la historia guardara un arreglo de cultivos. Con `CAST(... AS ... ARRAY)`, cada elemento se vuelve una entrada del índice y `MEMBER OF` o `JSON_CONTAINS` lo usan.

**No aplica al antibiograma** porque el antibiograma es un objeto (clave → valor), no un arreglo. Buscar por una clave dentro de un objeto es lo que resuelve la columna generada (§6 de la lección).

**Rúbrica (sobre 3 puntos):**
- 1 punto: describe el índice multivalor con un ejemplo de arreglo.
- 1 punto: explica por qué el antibiograma es un objeto y no un arreglo.
- 1 punto: propone la columna generada como alternativa y dice qué ruta indexa.

### Ejercicio 14

```sql
-- sin GIN
INSERT INTO staging.ex_ins SELECT * FROM staging.ex_ins_src;   -- 1.000 cultivos
-- con GIN jsonb_path_ops, después de TRUNCATE
CREATE INDEX ex_ins_gin ON staging.ex_ins USING gin (antibiogram jsonb_path_ops);
INSERT INTO staging.ex_ins SELECT * FROM staging.ex_ins_src;
```

```text
NOTICE:  sin GIN: 292576 bytes de WAL para 1.000 cultivos
NOTICE:  con GIN jsonb_path_ops: 563760 bytes de WAL para 1.000 cultivos
```

**Lectura:** el índice GIN casi duplica el WAL de la inserción. Un índice GIN se actualiza por cada clave y cada valor de cada documento nuevo. El costo se paga en escritura, y es el argumento para no crear índices de más sobre tablas que se escriben mucho.

### Ejercicio 15

```sql
SELECT count(DISTINCT k) AS claves_distintas FROM staging.culture_doc, jsonb_object_keys(antibiogram) AS k;
```

```text
 claves_distintas 
------------------
               17
```

**Lectura:** 17 nombres de antibiótico distintos aparecen en 60.001 cultivos, sin que nadie los haya declarado. Eso es el esquema: un conjunto de claves que existe porque los datos lo tienen, sin ningún `CREATE TABLE` que lo diga. Por eso una columna `extra jsonb` acaba siendo el esquema (§10 de la lección).

---

## 🟠 Difícil (16–21)

### Ejercicio 16

Medido con cinco cultivos, con calentamiento de las dos formas antes de la medida, tras un `CHECKPOINT`:

```text
NOTICE:  jsonb_set en 5 cultivos: 1344 bytes; documento entero: 1368 bytes
```

**Lectura:** la diferencia en WAL es casi nula. Postgres escribe la tupla nueva completa en las dos formas, sea cual sea la función que la produjo. `jsonb_set` ahorra trabajo de la aplicación (no manda el documento entero por la red ni lo reconstruye), no WAL. Esa es la distinción que la lección pedía: cuánto escribe el motor y cuánto se transmite. La rúbrica pide decirlo así, sin inventar un ahorro que la medida no muestra.

### Ejercicio 17

```sql
CREATE OR REPLACE FUNCTION staging.n_antibiotics(doc jsonb) RETURNS integer
  LANGUAGE sql IMMUTABLE AS $$ SELECT count(*)::integer FROM jsonb_object_keys(doc) $$;
ALTER TABLE staging.ex_check ADD CONSTRAINT min_three CHECK (staging.n_antibiotics(antibiogram) >= 3) NOT VALID;
SELECT count(*) AS cultivos_que_violarian FROM staging.ex_check WHERE staging.n_antibiotics(antibiogram) < 3;
ALTER TABLE staging.ex_check VALIDATE CONSTRAINT min_three;
```

```text
 cultivos_que_violarian 
------------------------
                      0
```

**Lectura:** ningún cultivo viola la regla, porque el panel más corto (*Enterococcus faecalis*) tiene cinco antibióticos. El ejercicio enseña el método sin que haya nada que migrar: `NOT VALID` agrega la restricción sin revisar las filas, la consulta cuenta las que violarían, y `VALIDATE` las revisa. En una tabla con datos sucios, las violaciones aparecen en ese conteo, y se corrigen antes de validar. Una subconsulta no sirve en un `CHECK`; una función `IMMUTABLE`, sí.

### Ejercicio 18

```sql
SELECT count(*) FROM (
  SELECT c.culture_id, e.key, e.value FROM staging.culture_doc c, jsonb_each_text(c.antibiogram) e
  EXCEPT SELECT culture_id, antibiotic, sensitivity FROM staging.antibiogram_long) x;
-- y la inversa
```

```text
 en_documento_no_en_larga 
--------------------------
                        0
 en_larga_no_en_documento 
--------------------------
                        0
```

**Lectura:** la forma larga y el documento contienen exactamente los mismos hechos. Si el número no fuera cero, la causa sería un documento que se modificó sin su fila larga, o al revés. Esta prueba es la que usaría un equipo que mantiene las dos formas a la vez.

### Ejercicio 19

```sql
SELECT germ, count(*) FILTER (WHERE antibiogram ->> 'CIPROFLOXACINA' = 'R') AS r_documento
FROM staging.culture_doc GROUP BY germ ORDER BY germ;
SELECT germ, count(DISTINCT culture_id) AS r_larga
FROM staging.antibiogram_long WHERE antibiotic = 'CIPROFLOXACINA' AND sensitivity = 'R' GROUP BY germ ORDER BY germ;
```

```text
 Enterococcus faecalis  |        1738   (documento)    |   1738   (larga)
 Escherichia coli       |        7134                  |   7134
 Klebsiella pneumoniae  |        1236                  |   1236
 Proteus mirabilis      |         351                  |    351
 Pseudomonas aeruginosa |        1337                  |   1337
 Staphylococcus aureus  |        1507                  |   1507
```

**Lectura:** el resultado es idéntico. Para este reporte, la forma larga gana cuando se agrega por germen y por antibiótico sin reconstruir nada, y el documento gana cuando se lee un cultivo completo. La medida de planes se deja a la rúbrica: aquí las dos consultas leen la caja entera, y la diferencia no es el punto.

**Rúbrica (sobre 4 puntos):** 1 punto por resultado idéntico; 1 por decir cuál forma gana y en qué; 1 por medir los planes; 1 por decir cuándo cambiaría la respuesta (con un índice o con una consulta que lee un solo cultivo).

### Ejercicio 20

```sql
INSERT INTO staging.culture_doc VALUES (-3, 1, '2020-01-01', 'Prueba', '{"AMPICILINA": "X", "CIPROFLOXACINA": "R"}');
CREATE OR REPLACE VIEW staging.culture_doc_invalid AS
SELECT c.culture_id, e.key, e.value FROM staging.culture_doc c, jsonb_each_text(c.antibiogram) e
WHERE e.value NOT IN ('S', 'I', 'R');
SELECT * FROM staging.culture_doc_invalid;
```

```text
 culture_id |    key     | value 
------------+------------+-------
         -3 | AMPICILINA | X
```

**Lectura:** la vista encuentra el documento sin borrarlo, y la aplicación puede reportarlo. Con el `CHECK` del §5.3, el `INSERT` ni siquiera entra; la vista sirve para las filas que entraron antes de la regla. La regla de la aplicación y la del motor no se reemplazan.

### Ejercicio 21

```text
NOTICE:  sin índice: 1428536 bytes, 3 ms
NOTICE:  con GIN y expresión: 3116984 bytes, 11 ms
```

**Lectura:** para 5.000 cultivos, el índice GIN y el de expresión llevan el WAL de 1,4 MB a 3,1 MB, y el tiempo de inserción de 3 a 11 ms (una sola corrida: el tiempo es orientativo, el WAL es la medida firme). El costo no es de un índice, es de cada índice por cada escritura. Esa es la cuenta que decide si un índice se justifica: cuántas lecturas ahorra y cuántas escrituras cuesta, sobre la carga real.

---

## 🔴 Muy difícil (22–24) — rúbrica

Estos tres no tienen solución completa: piden un juicio con argumentos y las medidas de la fase. Se evalúan con la rúbrica.

### Ejercicio 22

*Oracle, con la documentación*

**Rúbrica (sobre 4 puntos):**
- 1 punto: describe qué es el tipo JSON nativo de Oracle, sin cifras.
- 1 punto: explica la validación por esquema y qué restricciones impone que `CHECK` no impone.
- 1 punto: dice qué perdería el antibiograma frente a `CHECK` (la flexibilidad de agregar claves sin cambiar el esquema).
- 1 punto: deja la comparación en 🪞🔒 y no pone ningún número de Oracle en el texto (D20).

### Ejercicio 23

*La regla de Alameda*

**Rúbrica (sobre 4 puntos):**
- 1 punto: decide (documento, forma larga o ambas) y lo justifica en una frase.
- 1 punto: cita la consulta que más se hace (reporte por germen, búsqueda de un resultado) y su medida de §5 o §7.
- 1 punto: cita la escritura que más se hace (la corrección de un resultado) y su medida de WAL.
- 1 punto: dice qué medida cambiaría la decisión (un paciente con cincuenta cultivos, un panel que cambia por año).

### Ejercicio 24

*EAV con mejor marketing*

**Rúbrica (sobre 4 puntos):**
- 1 punto: diseña el EAV con sus columnas (`culture_id`, `antibiotic`, `sensitivity`), que es la forma larga.
- 1 punto: mide las tres búsquedas del §5 sobre ese diseño, y compara con el documento.
- 1 punto: dice en qué gana el EAV de verdad (agregación, integridad por clave primaria) y en qué no gana lo que promete.
- 1 punto: la conclusión respeta la lección: el EAV dentro de `jsonb` pierde la forma sin ganar flexibilidad real.
