# ✅ Soluciones — Fase 12: Estadísticas y cardinalidad

> **Curso:** Ruta SQL · Solucionario de la [Fase 12](../12-estadisticas-y-cardinalidad.md)
> **Ejercicios:** 24 · **Perfil:** M · **Motores:** Postgres y MySQL de
> [`a02`](../a02-compose-de-la-ruta.md#-las-versiones-del-curso)
> **Fecha de verificación ejecutada:** 14/10/2026

> ⚠️ **Intenta el ejercicio antes de leer su solución.** Leída antes, solo te enseña a reconocerla.

Todas las soluciones suponen el modelo de `uv run lab load --profile m --model`, las tablas de staging de las fases 08 a 11, y
los scripts de `src/12-estadisticas-y-cardinalidad/` corridos con `psql` o con el cliente `mysql`. Las estimaciones salen de una
muestra: cada `ANALYZE` puede moverlas unos puntos, y los números de esta página son los de una corrida. Lo que se compara es
el orden de magnitud y el método del plan.

---

## 🟢 Fácil (1–6)

### Ejercicio 1

**Enunciado (resumen):** `pg_stats` de `site_code`.

**Solución.**

```sql
-- postgres
SELECT n_distinct, most_common_vals, most_common_freqs, correlation
FROM pg_stats WHERE schemaname = 'alameda' AND tablename = 'lab_order' AND attname = 'site_code';
```

```text
 n_distinct | most_common_vals |                        most_common_freqs                        | correlation
------------+------------------+-----------------------------------------------------------------+-------------
          6 | {C,A,R,J,V,E}    | {0.46563333,0.12583333,0.12343334,0.11703333,0.1081,0.05996667} |  0.27563202
```

Seis valores, todos en la lista de los más frecuentes, y las frecuencias suman 1: con seis valores distintos la muestra los ve
todos, y la estimación de `site_code = 'E'` es exacta salvo por el error de la muestra (5,997 % contra el 6,1 % real de
80.918 sobre 1.327.622). La correlación de 0,28 dice que las sedes están bastante mezcladas en las páginas.

**Rúbrica.** Una respuesta correcta tiene que:
- leer los seis valores y ver que no hay histograma (todos son "más frecuentes");
- interpretar la correlación.

[← Volver al ejercicio](../12-estadisticas-y-cardinalidad.md#-ejercicio-1--pg_stats-de-una-columna)

### Ejercicio 2

**Enunciado (resumen):** los 239.414 de la Fase 01.

**Solución.**

```sql
-- mysql
SELECT table_rows FROM information_schema.tables WHERE table_schema = 'legacy' AND table_name = 'Pacientes';
SELECT n_rows, clustered_index_size FROM mysql.innodb_table_stats
WHERE database_name = 'legacy' AND table_name = 'Pacientes';
SELECT stat_name, stat_value, sample_size FROM mysql.innodb_index_stats
WHERE database_name = 'legacy' AND table_name = 'Pacientes';
SELECT @@innodb_stats_persistent_sample_pages;
```

```text
TABLE_ROWS
240979
n_rows	clustered_index_size
240979	1892
stat_name	stat_value	sample_size
n_diff_pfx01	240979	20
n_leaf_pages	1863	NULL
size	1892	NULL
@@innodb_stats_persistent_sample_pages
20
```

`TABLE_ROWS` es `n_rows` de `mysql.innodb_table_stats`, las estadísticas persistentes de InnoDB. Salen de mirar **20 páginas**
de las 1.863 hojas del índice primario y extrapolar. Ese día dio 239.414; hoy, después de otra recarga, 240.979. La tabla
tiene 242.427. Ninguna de las dos es una cuenta, y cambian cada vez que InnoDB recalcula.

**Rúbrica.** Una respuesta correcta tiene que:
- encontrar la tabla de donde sale el número;
- explicar la muestra de 20 páginas, y que el número cambia entre recálculos.

[← Volver al ejercicio](../12-estadisticas-y-cardinalidad.md#-ejercicio-2--los-239414-de-la-fase-01)

### Ejercicio 3

**Enunciado (resumen):** el histograma alfabético.

**Solución.**

```sql
-- postgres
SELECT histogram_bounds FROM pg_stats
WHERE schemaname = 'staging' AND tablename = 'result_eav' AND attname = 'value';
```

```text
{"< 0,05","0,33","0,63","0,79","0,96",10.1,10.4,"10,7","11,0",113,1159,118,<12.0,122,12.5,"1,28",130,…
```

Tres cortes fuera del orden numérico: `1159` entre `113` y `118`; `<12.0` entre `118` y `122`; `"1,28"` después de `12.5`.
Están ahí porque el histograma de una columna de texto se ordena con la *collation* del texto, carácter por carácter: `'115'`
va antes que `'118'` porque `'5' < '8'`, sin mirar cuántos dígitos siguen. Y el `<` y la coma del calificador y del decimal
viejo también son caracteres que se ordenan.

**Rúbrica.** Una respuesta correcta tiene que:
- encontrar tres cortes desordenados como números;
- explicar el orden carácter por carácter.

[← Volver al ejercicio](../12-estadisticas-y-cardinalidad.md#-ejercicio-3--el-histograma-alfabético)

### Ejercicio 4

**Enunciado (resumen):** mayor que 126.

**Solución.**

```sql
-- postgres
SELECT count(*) FROM staging.result_eav WHERE analyte_code = 'GLU' AND value > '126';
SELECT count(*) FILTER (WHERE value_numeric > 126) FROM alameda.result WHERE analyte_code = 'GLU';
```

```text
 605229
 442426
```

La primera cuenta 162.803 glucemias de más: entre ellas, todas las que empiezan con un dígito mayor que `1` (`13`, `2`, `99`)
aunque sean menores que 126, y los valores que no son números. La segunda compara números.

**Rúbrica.** Una respuesta correcta tiene que:
- dar las dos cifras;
- explicar con un ejemplo (`'99' > '126'`) por qué la primera está mal.

[← Volver al ejercicio](../12-estadisticas-y-cardinalidad.md#-ejercicio-4--mayor-que-126)

### Ejercicio 5

**Enunciado (resumen):** por proceso.

**Solución.**

```text
->  Parallel Seq Scan on protocol_stats  (cost=0.00..18192.58 rows=165 width=0) (actual rows=26972.67 loops=3)
```

Real: 26.972,67 × 3 = **80.918**, la cuenta exacta. Estimado: Postgres divide su estimación por 2,4 con dos *workers*
(supone que el proceso principal trabaja menos), así que el total estimado es 165 × 2,4 = **396**. El error es de unas 204
veces sobre el total, o de 163 veces comparando las cifras por proceso, que es como se lee en el plan.

**Rúbrica.** Una respuesta correcta tiene que:
- multiplicar las reales por `loops`;
- multiplicar las estimadas por 2,4, no por 3.

[← Volver al ejercicio](../12-estadisticas-y-cardinalidad.md#-ejercicio-5--por-proceso)

### Ejercicio 6

**Enunciado (resumen):** el mismo rango en Postgres.

**Solución.**

```sql
-- postgres
EXPLAIN SELECT count(*) FROM staging.protocol_stats WHERE ordered_on >= '2015-03-10' AND ordered_on < '2015-03-11';
SELECT count(*) FROM staging.protocol_stats WHERE ordered_on >= '2015-03-10' AND ordered_on < '2015-03-11';
```

```text
               ->  Parallel Seq Scan on protocol_stats  (cost=0.00..16809.64 rows=25 width=0)
    65
```

25 por proceso, unas 60 en total, para 65. Postgres reconoce que las dos comparaciones son sobre la misma columna y calcula la
fracción del histograma entre los dos bordes, en lugar de multiplicar la de cada uno.

**Rúbrica.** Una respuesta correcta tiene que:
- dar la estimación total;
- explicar por qué no multiplica, comparando con MySQL.

[← Volver al ejercicio](../12-estadisticas-y-cardinalidad.md#-ejercicio-6--el-mismo-rango-en-postgres)

---

## 🟡 Intermedio (7–12)

### Ejercicio 7

**Enunciado (resumen):** sede y prefijo, sin y con.

**Solución.** La sección 2 de `01_text_and_correlation.sql`. Las líneas que importan:

```text
== sin estadísticas extendidas
->  Parallel Seq Scan on protocol_stats  (cost=0.00..18192.58 rows=165 width=0) (actual rows=26972.67 loops=3)
== con estadísticas extendidas
->  Parallel Seq Scan on protocol_stats  (cost=0.00..18192.58 rows=34537 width=0) (actual rows=26972.67 loops=3)
```

Sin: la frecuencia de `'E'` (un 6 %) por la del prefijo `'E-'` (otro 6 %). Con: la frecuencia conjunta de `('E', 'E-')` en la
lista `mcv` del objeto de estadísticas, un 6,3 % de la muestra. La estimación nueva es un 28 % alta, porque la muestra de
ese `ANALYZE` vio un poco más de la sede `E` que la tabla.

**Rúbrica.** Una respuesta correcta tiene que:
- dar las dos estimaciones contra la real;
- explicar de dónde sale cada una.

[← Volver al ejercicio](../12-estadisticas-y-cardinalidad.md#-ejercicio-7--sede-y-prefijo-sin-y-con)

### Ejercicio 8

**Enunciado (resumen):** lo que guardó `CREATE STATISTICS`.

**Solución.**

```sql
-- postgres
SELECT dependencies FROM pg_stats_ext WHERE statistics_name = 'protocol_stats_site_prefix_stat';
SELECT m.values, m.frequency
FROM pg_statistic_ext s JOIN pg_statistic_ext_data d ON d.stxoid = s.oid, pg_mcv_list_items(d.stxdmcv) m
WHERE s.stxname = 'protocol_stats_site_prefix_stat' ORDER BY m.frequency DESC LIMIT 8;
```

```text
{"2 => -1": 0.405100, "-1 => 2": 0.991100}

 values |      frequency
--------+---------------------
 {C,C-} |              0.4506
 {A,A-} | 0.12793333333333334
 {R,R-} | 0.11713333333333334
 {J,J-} | 0.11543333333333333
 {V,V-} |              0.1092
 {E,E-} | 0.06333333333333334
 {C,00} |              0.0074
 {C,01} |              0.0073
```

Las columnas se numeran: `2` es `site_code` y `-1` la primera expresión, el prefijo. **El prefijo determina la sede en un
99,1 %** (el `-1 => 2`): sabiendo el prefijo se sabe la sede, salvo en los números viejos sin prefijo. La sede determina el
prefijo solo en un 40,5 %, porque la sede `C` tiene números `00…`, `01…`, `02…` además de `C-`. Y la frecuencia de `('E', 'E-')`
es 0,0633.

**Rúbrica.** Una respuesta correcta tiene que:
- leer las dos direcciones de la dependencia;
- explicar por qué no son simétricas con los números viejos de la sede `C`.

[← Volver al ejercicio](../12-estadisticas-y-cardinalidad.md#-ejercicio-8--lo-que-guardó-create-statistics)

### Ejercicio 9

**Enunciado (resumen):** solo `dependencies`.

**Solución.**

```sql
-- postgres
BEGIN;
DROP STATISTICS staging.protocol_stats_site_prefix_stat;
CREATE STATISTICS staging.protocol_stats_dep_only (dependencies)
    ON site_code, (left(visible_number, 2)) FROM staging.protocol_stats;
ANALYZE staging.protocol_stats;
EXPLAIN SELECT count(*) FROM staging.protocol_stats WHERE site_code = 'E' AND left(visible_number, 2) = 'E-';
EXPLAIN SELECT count(*) FROM staging.protocol_stats WHERE site_code = 'C' AND left(visible_number, 2) = '00';
ROLLBACK;
ANALYZE staging.protocol_stats;
```

```text
               ->  Parallel Seq Scan on protocol_stats  (cost=0.00..18192.58 rows=34552 width=0)
               ->  Parallel Seq Scan on protocol_stats  (cost=0.00..18192.58 rows=4203 width=0)
```

Para `('E', 'E-')`, casi lo mismo que con las dos: 34.552 por proceso. `dependencies` dice que el prefijo determina la sede,
y el estimador toma la selectividad del prefijo sin multiplicarla por la de la sede. Para `('C', '00')`, 9.999 reales (unas
4.166 por proceso): 4.203 con solo `dependencies`, y 3.670 con las dos. `mcv` aporta frecuencias exactas de las combinaciones
que vio; `dependencies`, una regla general que sirve también para combinaciones que la muestra no vio. Aquí, con la dependencia
casi perfecta, cualquiera de las dos alcanza.

**Rúbrica.** Una respuesta correcta tiene que:
- medir las dos estimaciones con solo `dependencies`;
- explicar qué aporta cada tipo.

[← Volver al ejercicio](../12-estadisticas-y-cardinalidad.md#-ejercicio-9--solo-dependencies)

### Ejercicio 10

**Enunciado (resumen):** un valor que no existía.

**Solución.** La parte de carga de `02_stale_statistics.sql` (hasta antes de los informes), y después:

```sql
-- postgres
EXPLAIN SELECT * FROM staging.result_2020 WHERE analyte_code = 'COVPCR';
EXPLAIN SELECT * FROM staging.result_2020 WHERE analyte_code = 'GLU';
SELECT analyte_code, count(*) FROM staging.result_2020 WHERE analyte_code IN ('COVPCR', 'GLU') GROUP BY 1;
SELECT n_distinct FROM pg_stats WHERE schemaname = 'staging' AND tablename = 'result_2020' AND attname = 'analyte_code';
```

```text
 Index Scan using result_2020_analyte_recorded_idx on result_2020  (cost=0.43..8.45 rows=1 width=155)
 Bitmap Heap Scan on result_2020  (cost=2693.48..13837.98 rows=82200 width=155)
 GLU          | 77077
 COVPCR       | 91475
 n_distinct: 32
```

`COVPCR`: 1 contra 91.475. Las estadísticas conocen 32 determinaciones y ninguna es esa; el estimador le da la fracción de un
valor poco frecuente, que en enero y febrero es casi cero. `GLU`: 82.200 contra 77.077, bien. Postgres corrige la frecuencia
guardada por el tamaño actual de la tabla (que lee de las páginas, no de las estadísticas): las glucemias crecieron con la tabla y
la estimación las acompañó. Lo que no puede corregir es un valor que no está.

**Rúbrica.** Una respuesta correcta tiene que:
- dar las dos estimaciones contra las reales;
- explicar por qué `GLU` sí escala y `COVPCR` no.

[← Volver al ejercicio](../12-estadisticas-y-cardinalidad.md#-ejercicio-10--un-valor-que-no-existía)

### Ejercicio 11

**Enunciado (resumen):** el informe que no lo nota.

**Solución.** `02_stale_statistics.sql` mide el informe simple cinco veces antes y cinco después del `ANALYZE`:

```text
== con las estadísticas de febrero
Time: 355.655 ms
Time: 189.918 ms
Time: 182.054 ms
Time: 186.694 ms
Time: 189.973 ms
== después del ANALYZE
Time: 291.114 ms
Time: 131.889 ms
Time: 240.582 ms
Time: 143.644 ms
Time: 116.835 ms
```

Medianas: 190 contra 144 ms. Con la fila estimada, el plan es un *nested loop* de tres tablas por clave primaria: por cada PCR,
una búsqueda en `lab_order` y otra en `patient`. Para 91.475 PCR son unas 180.000 búsquedas en índices que están en memoria, y
eso es un plan razonable aunque se haya elegido por error. **Un error de estimación cuesta cuando el plan que produce es caro
con las filas reales**, no por su tamaño.

**Rúbrica.** Una respuesta correcta tiene que:
- dar las medianas;
- explicar por qué el *nested loop* sigue siendo barato aquí.

[← Volver al ejercicio](../12-estadisticas-y-cardinalidad.md#-ejercicio-11--el-informe-que-no-lo-nota)

### Ejercicio 12

**Enunciado (resumen):** cuándo habría llegado el automático.

**Solución.**

```sql
-- postgres
SHOW autovacuum_analyze_scale_factor;   -- 0.1
SHOW autovacuum_analyze_threshold;      -- 50
WITH base AS (SELECT count(*) AS n FROM alameda.result WHERE recorded_at < '2020-03-01'),
     t AS (SELECT recorded_at, row_number() OVER (ORDER BY recorded_at) AS k
           FROM alameda.result WHERE recorded_at >= '2020-03-01')
SELECT (SELECT n FROM base) AS antes, (SELECT 0.1 * n + 50 FROM base) AS umbral, min(recorded_at) AS cuando
FROM t WHERE k >= (SELECT 0.1 * n + 50 FROM base);
```

```text
  antes  |  umbral  |       cuando
---------+----------+---------------------
 2762555 | 276305.5 | 2020-08-05 13:44:00
```

Y las PCR cargadas hasta ese momento:

```sql
-- postgres
SELECT count(*) FROM alameda.result WHERE analyte_code = 'COVPCR' AND recorded_at < '2020-08-05 13:44:00';
```

```text
 17475
```

El cálculo supone que nada más modifica la tabla (sin actualizaciones ni borrados que también cuenten), y que el autovacuum
corre en cuanto se cruza el umbral; en la práctica pasa unos minutos después.

**Rúbrica.** Una respuesta correcta tiene que:
- usar el umbral con sus dos partes;
- llegar al 5 de agosto de 2020 y a las 17.475 PCR.

[← Volver al ejercicio](../12-estadisticas-y-cardinalidad.md#-ejercicio-12--cuándo-habría-llegado-el-automático)

---

## 🟠 Difícil (13–18)

### Ejercicio 13

**Enunciado (resumen):** el informe de las repetidas, chico.

**Solución.** En `02_stale_statistics.sql`, la segunda carga hasta `'2020-05-01'` en lugar de `'2022-01-01'`:

```text
== con las estadísticas de febrero
 count
-------
   140
Time: 40873.534 ms (00:40.874)
== después del ANALYZE
   140
Time: 154.407 ms
   140
Time: 95.733 ms
```

5.303 PCR, 140 pacientes con una repetida. **40,9 s contra 0,1 s.** El plan con las estadísticas de febrero es el de la sección 9:
por cada PCR del lado externo, el lado interno recorre todas las PCR por el índice `(analyte_code, recorded_at)`, y filtra por
fecha y paciente después. 5.303 × 5.303 son 28 millones de filas visitadas.

**Rúbrica.** Una respuesta correcta tiene que:
- medir los dos tiempos;
- encontrar en el plan el lado interno que no es una búsqueda puntual.

[← Volver al ejercicio](../12-estadisticas-y-cardinalidad.md#-ejercicio-13--el-informe-de-las-repetidas-chico)

### Ejercicio 14

**Enunciado (resumen):** el informe de las repetidas, entero.

**Solución.** `02_stale_statistics.sql` tal como está:

```text
ERROR:  canceling statement due to statement timeout
Time: 300020.003 ms (05:00.020)
== después del ANALYZE
  2494
Time: 199.547 ms
  2494
Time: 146.976 ms
```

En una corrida anterior, después del `ANALYZE`, tardó 719 y 704 ms: el *hash join* paralelo depende de lo que esté haciendo el
resto de la máquina. La extrapolación: el trabajo del *nested loop* es proporcional al cuadrado de las PCR, y
(91.475 / 5.303)² = 297,5; 40,9 s × 297,5 = 12.170 s, **unas 3,4 horas**. Es un orden de magnitud, no una medición: supone que
cada fila visitada cuesta lo mismo con 5.303 que con 91.475 PCR.

**Rúbrica.** Una respuesta correcta tiene que:
- reportar el corte, no inventar el tiempo final;
- hacer la extrapolación diciendo lo que supone.

[← Volver al ejercicio](../12-estadisticas-y-cardinalidad.md#-ejercicio-14--el-informe-de-las-repetidas-entero)

### Ejercicio 15

**Enunciado (resumen):** diez `ANALYZE` seguidos.

**Solución.**

```sql
-- postgres
CREATE TEMP TABLE choice (run int, est_filter bigint, est_join bigint, node text);
DO $$
DECLARE p jsonb;
BEGIN
  FOR i IN 1..10 LOOP
    ANALYZE staging.protocol_stats;
    EXECUTE $q$EXPLAIN (FORMAT JSON)
      SELECT r.analyte_code, count(*) FROM staging.protocol_stats s JOIN staging.result_eav r USING (lab_order_id)
      WHERE s.site_code = 'E' AND left(s.visible_number, 2) = 'E-' GROUP BY r.analyte_code$q$ INTO p;
    INSERT INTO choice VALUES (i,
      (jsonb_path_query_first(p, '$[0].Plan.** ? (@."Relation Name" == "protocol_stats")."Plan Rows"') #>> '{}')::numeric::bigint,
      (jsonb_path_query_first(p, '$[0].Plan.** ? (@."Node Type" like_regex "Join|Nested")."Plan Rows"') #>> '{}')::numeric::bigint,
      jsonb_path_query_first(p, '$[0].Plan.** ? (@."Node Type" like_regex "Join|Nested")."Node Type"') #>> '{}');
  END LOOP;
END $$;
SELECT * FROM choice;
```

```text
 run | est_filter | est_join |   node
-----+------------+----------+-----------
   1 |      32287 |   295082 | Hash Join
   2 |      34795 |   317999 | Hash Join
   3 |      33228 |   303677 | Hash Join
   …
  10 |      35035 |   320192 | Hash Join
```

Diez de diez *hash join*. El filtro varió entre 32.287 y 35.035 por proceso, un 8 %, y el join, entre 295.082 y 320.192.
Ninguna muestra se acercó a la zona en que el *nested loop* vuelve a ser más barato para el optimizador.

**Rúbrica.** Una respuesta correcta tiene que:
- mostrar los diez métodos;
- medir la variación de la estimación entre muestras.

[← Volver al ejercicio](../12-estadisticas-y-cardinalidad.md#-ejercicio-15--diez-analyze-seguidos)

### Ejercicio 16

**Enunciado (resumen):** los dos joins, forzados.

**Solución.**

```sql
-- postgres
\timing on
SET enable_hashjoin = off; SET enable_mergejoin = off;
-- la consulta del join, cuatro veces, con \g /dev/null
RESET enable_hashjoin; RESET enable_mergejoin; SET enable_nestloop = off;
-- la misma, cuatro veces
```

```text
== nested loop forzado, caliente
Time: 251.720 ms
Time: 135.687 ms
Time: 115.263 ms
Time: 133.081 ms
== hash join forzado, caliente
Time: 944.583 ms
Time: 727.736 ms
Time: 598.303 ms
Time: 666.716 ms
```

Medianas: 134 contra 697 ms, **5,2 veces**. El *nested loop* hace 80.918 búsquedas en un índice que está en memoria; el *hash
join* lee los 134.208 bloques de `result_eav` para quedarse con 80.918 filas de 12 millones.

**Rúbrica.** Una respuesta correcta tiene que:
- medir con la caché caliente (descartar la primera ejecución o mirar la mediana);
- explicar la diferencia por los bloques que lee cada uno.

[← Volver al ejercicio](../12-estadisticas-y-cardinalidad.md#-ejercicio-16--los-dos-joins-forzados)

### Ejercicio 17

**Enunciado (resumen):** el segundo error.

**Solución.**

```text
->  Index Scan using result_eav_lab_order_id_idx on result_eav r  (cost=0.43..225.34 rows=60 width=7) (actual rows=1.00 loops=80918)
```

60 estimadas por vuelta, 1 real. El 60 sale de `n_distinct`:

```sql
-- postgres
SELECT n_distinct FROM pg_stats WHERE schemaname = 'staging' AND tablename = 'result_eav' AND attname = 'lab_order_id';
SELECT reltuples::bigint FROM pg_class WHERE oid = 'staging.result_eav'::regclass;
```

```text
 202393
 12133553
```

12.133.553 / 202.393 = 60. Hay 1,33 millones de protocolos distintos, pero una muestra de 30.000 filas de una tabla donde cada
protocolo tiene unas nueve filas ve muchos repetidos, y el estimador de distintos de Postgres los extrapola a la baja. Con el
`n_distinct` real, el promedio sería de 9; y para los protocolos de la sede `E`, que tienen una sola PCR, ni el promedio
correcto alcanza. Se puede fijar el número con `ALTER TABLE staging.result_eav ALTER COLUMN lab_order_id SET (n_distinct =
-0.11)` (una proporción de las filas): eso llevaría el promedio a nueve, y seguiría sin decir nada de la sede.

**Rúbrica.** Una respuesta correcta tiene que:
- encontrar el 60 y explicarlo con `n_distinct` y `reltuples`;
- distinguir el error del promedio del error de la sede.

[← Volver al ejercicio](../12-estadisticas-y-cardinalidad.md#-ejercicio-17--el-segundo-error)

### Ejercicio 18

**Enunciado (resumen):** el histograma de MySQL.

**Solución.** `04_mysql_histograms.sql`. Las líneas que importan:

```text
-> Filter: (staging.protocol_hist.Fecha >= TIMESTAMP'2015-03-10 00:00:00')  (cost=134029 rows=1.15e+6)
-> Filter: (staging.protocol_hist.Fecha < TIMESTAMP'2015-03-11 00:00:00')  (cost=134029 rows=173087)
-> Filter: ((… >= …) and (… < …))  (cost=134029 rows=150478)
-> Filter: (staging.protocol_hist.Fecha = TIMESTAMP'2015-03-10 00:00:00')  (cost=134029 rows=1325)
desde	hasta	el_dia	total
1152979	174708	65	1327622
```

La tercera es el producto de las dos primeras: (1.152.979 / 1.327.622) × (173.087 / 1.327.622) × 1.327.622 ≈ 150.300, con las
fracciones que MySQL leyó de su histograma. Cada mitad es buena; MySQL las combina como condiciones independientes. La igualdad
usa el tramo del histograma que contiene la fecha: las filas del tramo divididas por sus valores distintos.

**Rúbrica.** Una respuesta correcta tiene que:
- reproducir las cuatro estimaciones;
- mostrar la multiplicación con números.

[← Volver al ejercicio](../12-estadisticas-y-cardinalidad.md#-ejercicio-18--el-histograma-de-mysql)

---

## 🔴 Muy difícil (19–24)

### Ejercicio 19

**Enunciado (resumen):** el precipicio en tu máquina.

**Solución de referencia.** Las dos corridas del curso, a seis años de rango:

| Corrida | Índice | *Bitmap* | Entera | Elegido |
|---|---|---|---|---|
| primera | 305,9 ms | 314,2 ms | 897,4 ms | 1.002,3 ms (entera) |
| segunda | 167,2 ms | 145,9 ms | 439,9 ms | 492,1 ms (entera) |

En las dos, el método cambió entre cuatro y seis años; los milisegundos, hasta el doble entre corridas, con otros contenedores
en la máquina. La comparación vale dentro de una corrida, no entre corridas. En tu máquina el cambio de método tiene que caer en el
mismo rango, porque lo decide el modelo de costos con las mismas estadísticas; los tiempos, no.

**Rúbrica.** Una respuesta correcta tiene que:
- correr dos veces y comparar el rango del cambio;
- no sacar conclusiones de milisegundos entre corridas.

[← Volver al ejercicio](../12-estadisticas-y-cardinalidad.md#-ejercicio-19--el-precipicio-en-tu-máquina)

### Ejercicio 20

**Enunciado (resumen):** mover el precipicio.

**Solución.**

```bash
docker exec -i -e PGOPTIONS='-c random_page_cost=1.1' <contenedor de postgres> \
    psql -U postgres -d alameda < src/12-estadisticas-y-cardinalidad/03_plan_cliff.sql
```

```text
  width   |     elegido      | estimadas | reales  | index_ms | bitmap_ms | seq_ms | elegido_ms
----------+------------------+-----------+---------+----------+-----------+--------+------------
 4 years  | Index Scan       |   1029213 | 1058595 |    101.9 |      93.8 |  434.6 |      114.0
 6 years  | Index Scan       |   1993251 | 2017282 |    158.4 |     161.0 |  517.0 |      213.7
 10 years | Seq Scan         |   7159992 | 7210380 |    637.6 |     536.9 |  630.4 |      709.3
```

Con las páginas al azar casi tan baratas como las secuenciales, el cambio a recorrida entera se corre a entre seis y diez años, y
a seis años el plan elegido es el índice, del orden del más rápido. A diez años, el rango es el 60 % de la tabla y los tres métodos
cuestan parecido. El precipicio no desaparece: se mueve hacia donde ya no hay mucho que ganar. El valor bajo es para datos que
caben en memoria o en SSD; el 4 de fábrica está pensado para discos giratorios.

**Rúbrica.** Una respuesta correcta tiene que:
- correr el barrido con el parámetro en la sesión, no en el servidor;
- decir dónde se corrió el cambio y para qué discos vale el número.

[← Volver al ejercicio](../12-estadisticas-y-cardinalidad.md#-ejercicio-20--mover-el-precipicio)

### Ejercicio 21

**Enunciado (resumen):** el umbral de `result`.

**Solución de referencia.**

```sql
-- postgres
SELECT date_trunc('week', recorded_at)::date AS semana, count(*)
FROM alameda.result WHERE recorded_at >= '2026-08-01' AND recorded_at < '2026-10-01' GROUP BY 1 ORDER BY 1;
SELECT count(*) FROM alameda.result;
```

```text
 2026-08-03 | 39570
 2026-08-10 | 38896
 …
 2026-09-21 | 39681
 12132303
```

Unos 39.500 resultados por semana sobre 12,13 millones de filas: un 0,33 % por semana. Con
`autovacuum_analyze_scale_factor = 0.003` el umbral es de 36.447 filas, unos seis días y medio. Un código nuevo que llega el
lunes se analiza antes del domingo. Para tenerlo en el día, mejor que bajar más el factor es un `ANALYZE` explícito después de
dar de alta una determinación, que es un evento conocido.

```sql
-- postgres
ALTER TABLE alameda.result SET (autovacuum_analyze_scale_factor = 0.003);
```

**Rúbrica.** Una respuesta correcta tiene que:
- partir de las filas por semana medidas;
- considerar el `ANALYZE` explícito como alternativa.

[← Volver al ejercicio](../12-estadisticas-y-cardinalidad.md#-ejercicio-21--el-umbral-de-result)

### Ejercicio 22

**Enunciado (resumen):** la glucemia de la Fase 08.

**Solución de referencia.** La Fase 08 pedía un histograma del valor **por determinación**, y las estadísticas de Postgres son
por columna: el histograma de `value_numeric` mezcla glucemias, hemoglobinas y TSH. Con el modelo actual:

```text
== result
               ->  Parallel Seq Scan on result  (cost=0.00..163605.34 rows=104200 width=0)
 442426
```

Unas 250.000 estimadas (104.200 × 2,4) para 442.426. Dos cambios lo arreglan, y los dos se midieron:

```sql
-- postgres
-- 1. particionar por determinación: cada partición tiene su histograma
CREATE TABLE staging.result_by_analyte (LIKE alameda.result) PARTITION BY LIST (analyte_code);
CREATE TABLE staging.result_by_analyte_glu PARTITION OF staging.result_by_analyte FOR VALUES IN ('GLU');
CREATE TABLE staging.result_by_analyte_rest PARTITION OF staging.result_by_analyte DEFAULT;
INSERT INTO staging.result_by_analyte SELECT * FROM alameda.result;
ANALYZE staging.result_by_analyte;

-- 2. estadísticas sobre la expresión que separa la glucemia
CREATE STATISTICS staging.result_as_is_glu_value_stat
    ON ((CASE WHEN analyte_code = 'GLU' THEN value_numeric END)) FROM staging.result_as_is;
ANALYZE staging.result_as_is;
```

```text
== particionado
               ->  Parallel Seq Scan on result_by_analyte_glu result_by_analyte  (cost=0.00..9700.46 rows=183312 width=0)
== expresión, escrita igual en la consulta
               ->  Parallel Seq Scan on result_as_is  (cost=0.00..162513.36 rows=183093 width=0)
== expresión, con la consulta de siempre
               ->  Parallel Seq Scan on result_as_is  (cost=0.00..162513.36 rows=101632 width=0)
```

Particionado: 183.312 × 2,4 ≈ 440.000 para 442.426, con la consulta de siempre, porque el *pruning* deja una partición y el
optimizador usa sus estadísticas. Expresión: 183.093 × 2,4 ≈ 439.000 para 435.530 (en `result_as_is`), **solo si la consulta
repite la expresión**; con `analyte_code = 'GLU' AND value_numeric > 126` vuelve a 101.632. Es la misma condición que el índice
de expresión de la Fase 11. La partición por determinación arregla la estimación de todas las consultas por determinación; su
costo es el de la Fase 09: una consulta que no filtra por determinación recorre todas las particiones.

**Rúbrica.** Una respuesta correcta tiene que:
- explicar que el histograma es por columna, no por combinación;
- medir al menos un arreglo, con su condición o su costo.

[← Volver al ejercicio](../12-estadisticas-y-cardinalidad.md#-ejercicio-22--la-glucemia-de-la-fase-08)

### Ejercicio 23

**Enunciado (resumen):** Oracle.

**Solución de referencia.** El curso no publica números de Oracle. Lo que hay que mirar: con `DBMS_XPLAN.DISPLAY_CURSOR(format =>
'ALLSTATS LAST')`, las columnas `E-Rows` y `A-Rows` del filtro por sede y prefijo, antes y después de
`DBMS_STATS.CREATE_EXTENDED_STATS(NULL, 'PROTOCOL_STATS', '(SITE_CODE, SUBSTR(VISIBLE_NUMBER, 1, 2))')` y de volver a recoger
las estadísticas. Y la nota del plan: si dice `dynamic statistics used`, el muestreo dinámico intervino, y la hipótesis de que no
actúa sobre una tabla con estadísticas queda refutada para ese caso. La documentación explica cuándo el optimizador decide
muestrear en tiempo de compilación (las referencias de la fase).

**Rúbrica.** Una respuesta correcta tiene que:
- comparar `E-Rows` con `A-Rows` antes y después;
- leer la nota del muestreo dinámico;
- no publicar ningún número.

[← Volver al ejercicio](../12-estadisticas-y-cardinalidad.md#-ejercicio-23--oracle)

### Ejercicio 24

**Enunciado (resumen):** ¿estadísticas extendidas o no?

**Solución de referencia.** Se quedan, con una condición. Las consultas que filtran por sede y prefijo estiman bien con ellas, y el filtro solo pasa de 163 veces de
error a un 28 %. La que pierde es el join con `result_eav`, y pierde por otro error, el del lado interno (ejercicio 17), que las
estadísticas extendidas destaparon pero no causaron. La decisión correcta es arreglar el segundo error (el `n_distinct` de
`lab_order_id`, o el modelo, donde la PCR de la sede `E` es un resultado y no nueve), no quitar las estadísticas que arreglaron
el primero. Quitarlas sería dejar un plan bueno que depende de dos errores que se cancelan, y que se rompe el día que uno de los
dos cambie.

**Rúbrica.** Una respuesta correcta tiene que:
- separar los dos errores;
- rechazar mantener un plan que funciona por compensación.

[← Volver al ejercicio](../12-estadisticas-y-cardinalidad.md#-ejercicio-24--estadísticas-extendidas-o-no)
