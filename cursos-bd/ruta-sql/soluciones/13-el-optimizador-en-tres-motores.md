# ✅ Soluciones — Fase 13: El optimizador en tres motores

> **Curso:** Ruta SQL · Solucionario de la [Fase 13](../13-el-optimizador-en-tres-motores.md)
> **Ejercicios:** 24 y un 🔥 · **Perfil:** M · **Motores:** Postgres y MySQL de
> [`a02`](../a02-compose-de-la-ruta.md#-las-versiones-del-curso)
> **Fecha de verificación ejecutada:** 14/10/2026

> ⚠️ **Intenta el ejercicio antes de leer su solución.** Leída antes, solo te enseña a reconocerla.

Todas las soluciones suponen el modelo de `uv run lab load --profile m --model`, las tablas de staging de las fases 09 a 12, y
`01_generic_plans.sql` corrido una vez (crea `staging.order_site` con su índice `(site_code, ordered_on)`). Los scripts de
Python se corren desde `src/` con `uv run python`. Los tiempos son de una máquina con otros contenedores corriendo: las
comparaciones valen dentro de una corrida.

---

## 🟢 Fácil (1–7)

### Ejercicio 1

**Enunciado (resumen):** los tres métodos.

**Solución.** `02_join_methods.sql`. Las líneas que importan de cada bloque:

```text
== central, elegido
   Buffers: shared hit=25077 read=62876
                     ->  Parallel Hash Join  (cost=9359.12..160958.66 rows=37102 width=3) (actual rows=36478.00 loops=3)
 Execution Time: 402.209 ms
== central, nested loop
   Buffers: shared hit=41953
 Execution Time: 35.377 ms
== central, merge join
   Buffers: shared hit=1168429 read=101425
 Execution Time: 986.106 ms
== centro V, elegido
   Buffers: shared hit=10865
                     ->  Nested Loop  (cost=35.39..147027.92 rows=11815 width=3) (actual rows=14022.00 loops=2)
 Execution Time: 23.653 ms
== centro V, hash join
   Buffers: shared hit=62795 read=25132
 Execution Time: 935.717 ms
== centro V, merge join
   Buffers: shared hit=1168386 read=101416
 Execution Time: 979.867 ms
```

Los bloques son la suma de `hit` y `read`. El tiempo del *hash join* elegido para el central bajó a 265 ms de mediana en cinco
ejecuciones seguidas: los 402 ms de este bloque incluyen lecturas que no estaban en `shared_buffers`. El *hash join* forzado para
la sede V no es paralelo (936 ms); el genérico de la sección 5.2 sí lo es (242 ms). Por eso no se comparan entre sí.

**Rúbrica.** Una respuesta correcta tiene que:
- sumar `hit` y `read` para los bloques;
- notar que el método elegido para el central no es el más rápido.

[← Volver al ejercicio](../13-el-optimizador-en-tres-motores.md#-ejercicio-1--los-tres-métodos)

### Ejercicio 2

**Enunciado (resumen):** lo que lee el *hash join*.

**Solución.**

```sql
-- postgres
SELECT relpages FROM pg_class WHERE oid = 'alameda.result'::regclass;
```

```text
 relpages
----------
    87779
```

El *hash join* arma la tabla de hash con los protocolos de la sede (el lado chico) y recorre `result` entera, 87.779 páginas, para
buscar en ella. Los 88.000 bloques del plan son esas páginas más las del lado chico y del índice de `order_site`. No depende de
cuántos protocolos tenga la sede: con 2.626 o con 10.255, la tabla grande se lee completa.

**Rúbrica.** Una respuesta correcta tiene que:
- relacionar los bloques con las páginas de `result`;
- explicar por qué no dependen de la sede.

[← Volver al ejercicio](../13-el-optimizador-en-tres-motores.md#-ejercicio-2--lo-que-lee-el-hash-join)

### Ejercicio 3

**Enunciado (resumen):** `random_page_cost`.

**Solución.**

```sql
-- postgres
SET random_page_cost = 1.1;
EXPLAIN SELECT r.analyte_code, count(*) FROM staging.order_site o JOIN alameda.result r USING (lab_order_id)
WHERE o.site_code = 'C' AND o.ordered_on >= '2026-09-01' GROUP BY r.analyte_code;
RESET random_page_cost;
```

```text
                     ->  Nested Loop  (cost=110.64..56074.90 rows=37102 width=3)
                           ->  Index Scan using result_lab_order_id_idx on result r  (cost=0.43..11.82 rows=39 width=7)
```

Con 1.1, el *nested loop* cuesta 57.262 en total; el *hash join*, que no lee nada al azar, sigue costando unos 161.000. Con el 4
de fábrica, el mismo *nested loop* costaba 173.579 (lo da el `EXPLAIN` del bloque forzado de `02_join_methods.sql`), por encima
del *hash join*. Las 37.102 búsquedas en el índice de `result` son lecturas al azar, y su precio decide el método.

**Rúbrica.** Una respuesta correcta tiene que:
- dar el método y el costo con los dos valores del parámetro;
- explicar que solo cambió el precio de la lectura al azar.

[← Volver al ejercicio](../13-el-optimizador-en-tres-motores.md#-ejercicio-3--random_page_cost)

### Ejercicio 4

**Enunciado (resumen):** seis `EXECUTE`.

**Solución.** La parte 2 de `01_generic_plans.sql`, con el central también en la sexta:

```sql
-- postgres
PREPARE by_site(char) AS
SELECT r.analyte_code, count(*) FROM staging.order_site o JOIN alameda.result r USING (lab_order_id)
WHERE o.site_code = $1 AND o.ordered_on >= '2026-09-01' GROUP BY r.analyte_code;
EXECUTE by_site('C');   -- cinco veces
EXPLAIN EXECUTE by_site('C');
SELECT generic_plans, custom_plans FROM pg_prepared_statements WHERE name = 'by_site';
```

```text
 generic_plans | custom_plans
---------------+--------------
             1 |            5
```

Cinco personalizados, y en la sexta el genérico. El plan muestra `site_code = $1` en las condiciones del índice: es la marca del
genérico. Para el central, el genérico y el personalizado son el mismo método (*hash join*), y el cambio no se nota.

**Rúbrica.** Una respuesta correcta tiene que:
- leer los contadores;
- encontrar el `$1` en el plan.

[← Volver al ejercicio](../13-el-optimizador-en-tres-motores.md#-ejercicio-4--seis-execute)

### Ejercicio 5

**Enunciado (resumen):** empezar por los chicos.

**Solución.** La parte 1 de `01_generic_plans.sql`:

```text
== 1. el día empieza en los centros chicos
                     ->  Parallel Hash Join  (cost=9359.12..160958.66 rows=37102 width=3) (actual rows=36478.00 loops=3)
 generic_plans | custom_plans
---------------+--------------
             0 |            6
```

Los cinco personalizados de los centros cuestan unos 150.000 (*nested loop*); el genérico, unos 160.000 (*hash join* para un sexto
de la tabla). Más caro que el promedio: Postgres lo descarta y planifica la sexta con el valor. El central recibe su propio plan.

**Rúbrica.** Una respuesta correcta tiene que:
- mostrar cero genéricos;
- explicarlo con la comparación de costos.

[← Volver al ejercicio](../13-el-optimizador-en-tres-motores.md#-ejercicio-5--empezar-por-los-chicos)

### Ejercicio 6

**Enunciado (resumen):** el *driver* que prepara.

**Solución.**

```text
prepare_threshold = 5
 1 C   400.1 ms  preparadas=0 genéricos=0 personalizados=0
 …
 5 C   289.0 ms  preparadas=0 genéricos=0 personalizados=0
 6 C   300.7 ms  preparadas=1 genéricos=0 personalizados=1
 …
10 C   263.6 ms  preparadas=1 genéricos=0 personalizados=5
11 V   265.3 ms  preparadas=1 genéricos=1 personalizados=5
12 V   265.8 ms  preparadas=1 genéricos=2 personalizados=5
13 V   271.4 ms  preparadas=1 genéricos=3 personalizados=5
```

Psycopg prepara en la sexta ejecución; Postgres hace cinco personalizados (de la 6 a la 10); la undécima es la primera genérica.
El script filtra la consulta de control, que psycopg también prepara sola después de cinco usos.

**Rúbrica.** Una respuesta correcta tiene que:
- separar los dos umbrales, el del *driver* y el del motor;
- llegar a la undécima.

[← Volver al ejercicio](../13-el-optimizador-en-tres-motores.md#-ejercicio-6--el-driver-que-prepara)

### Ejercicio 7

**Enunciado (resumen):** `EXPLAIN` preparado en MySQL.

**Solución.** `03_mysql_prepared.sql`:

```text
… over (Sede = 'C' AND '2026-09-01 00:00:00.000' <= Fecha)  (cost=3823 rows=18892)
… over (Sede = 'V' AND '2026-09-01 00:00:00.000' <= Fecha)  (cost=532 rows=2626)
… over (Sede = 'E' AND '2026-09-01 00:00:00.000' <= Fecha)  (cost=1.21 rows=1)
Sede	count(*)
A	2823
C	10255
J	2674
R	2784
V	2626
```

Tres estimaciones distintas para la misma sentencia preparada: MySQL la optimizó en cada `EXECUTE`. La de V es exacta, la de C
casi el doble (las *index dives* estiman por páginas del índice), y la de E es 1, el mínimo, para una sede sin protocolos.

**Rúbrica.** Una respuesta correcta tiene que:
- mostrar que la estimación cambia con el valor;
- compararla con la real.

[← Volver al ejercicio](../13-el-optimizador-en-tres-motores.md#-ejercicio-7--explain-preparado-en-mysql)

---

## 🟡 Intermedio (8–14)

### Ejercicio 8

**Enunciado (resumen):** de dónde sale el 3.446.

**Solución.**

```sql
-- postgres
SELECT n_distinct FROM pg_stats WHERE schemaname = 'staging' AND tablename = 'order_site' AND attname = 'site_code';
EXPLAIN SELECT * FROM staging.order_site WHERE ordered_on >= '2026-09-01';
```

```text
 n_distinct
------------
          6
 Bitmap Heap Scan on order_site  (cost=247.25..9209.71 rows=20677 width=20)
```

20.677 filas desde el 1 de septiembre, por 1/6 de una sede cualquiera: 3.446. El genérico no usa la lista de valores frecuentes,
donde el central es el 47 %, porque no sabe qué valor va a llegar: usa uno sobre la cantidad de valores distintos.

**Rúbrica.** Una respuesta correcta tiene que:
- reconstruir la cuenta;
- explicar por qué el genérico ignora la frecuencia de cada sede.

[← Volver al ejercicio](../13-el-optimizador-en-tres-motores.md#-ejercicio-8--de-dónde-sale-el-3446)

### Ejercicio 9

**Enunciado (resumen):** el costo de planificar.

**Solución.**

```sql
-- postgres
EXPLAIN (ANALYZE, SUMMARY ON, TIMING OFF, COSTS OFF)
SELECT r.analyte_code, count(*) FROM staging.order_site o JOIN alameda.result r USING (lab_order_id)
WHERE o.site_code = 'V' AND o.ordered_on >= '2026-09-01' GROUP BY r.analyte_code;
```

```text
 Planning Time: 0.134 ms
```

Entre 0,13 y 0,3 ms en las corridas de esta fase. El plan genérico ahorra eso por ejecución, y a la sede V le cuesta 220 ms. Hacen
falta unas mil ejecuciones con el plan genérico correcto para pagar una sola con el equivocado. Para una consulta de dos tablas, planificar es gratis.

**Rúbrica.** Una respuesta correcta tiene que:
- medir el tiempo de planificación;
- ponerlo en proporción con lo que cuesta el plan equivocado.

[← Volver al ejercicio](../13-el-optimizador-en-tres-motores.md#-ejercicio-9--el-costo-de-planificar)

### Ejercicio 10

**Enunciado (resumen):** `force_custom_plan`.

**Solución.**

```sql
-- postgres
SET plan_cache_mode = force_custom_plan;
PREPARE by_site(char) AS …;
EXECUTE by_site('C');   -- cinco veces
EXPLAIN (ANALYZE, BUFFERS, TIMING OFF, COSTS OFF) EXECUTE by_site('V');
SELECT generic_plans, custom_plans FROM pg_prepared_statements WHERE name = 'by_site';
```

```text
                     ->  Nested Loop (actual rows=14022.00 loops=2)
                                       Index Cond: ((site_code = 'V'::bpchar) AND (ordered_on >= '2026-09-01'::date))
 Execution Time: 22.440 ms
 generic_plans | custom_plans
---------------+--------------
             0 |            6
```

El valor aparece en el plan (`'V'::bpchar`), el método es el *nested loop*, y la sede V vuelve a 22 ms. `plan_cache_mode` se puede
fijar por rol (`ALTER ROLE … SET plan_cache_mode = force_custom_plan`), y así afecta solo a la aplicación que lo necesita.

**Rúbrica.** Una respuesta correcta tiene que:
- mostrar el plan con el valor;
- proponer dónde fijarlo sin afectar a todo el servidor.

[← Volver al ejercicio](../13-el-optimizador-en-tres-motores.md#-ejercicio-10--force_custom_plan)

### Ejercicio 11

**Enunciado (resumen):** sin preparar en Python.

**Solución.**

```python
with psycopg.connect(**config.POSTGRES, autocommit=True) as conn:
    conn.prepare_threshold = None
    for _ in range(10):
        run(conn, "C")
    times = [run(conn, "V") for _ in range(3)]
```

```text
V: 24.6 ms, 19.2 ms, 20.1 ms | preparadas, genéricos, personalizados = (0, Decimal('0'), Decimal('0'))
```

`prepare_threshold = None` desactiva la preparación en el servidor para esa conexión. Cada consulta se planifica con su valor:
cero sentencias preparadas, y la sede V en 20 ms después de diez ejecuciones del central.

**Rúbrica.** Una respuesta correcta tiene que:
- cambiar el umbral en la conexión;
- mostrar cero sentencias preparadas y el tiempo de la sede V.

[← Volver al ejercicio](../13-el-optimizador-en-tres-motores.md#-ejercicio-11--sin-preparar-en-python)

### Ejercicio 12

**Enunciado (resumen):** el genérico con el modelo de costos ajustado.

**Solución.**

```sql
-- postgres
SET random_page_cost = 1.1;
PREPARE by_site(char) AS …;
EXECUTE by_site('C');   -- cinco veces
EXPLAIN (ANALYZE, BUFFERS, TIMING OFF, COSTS OFF) EXECUTE by_site('V');
SELECT generic_plans, custom_plans FROM pg_prepared_statements WHERE name = 'by_site';
```

```text
                     ->  Nested Loop (actual rows=14022.00 loops=2)
 Execution Time: 16.009 ms
 generic_plans | custom_plans
---------------+--------------
             0 |            6
```

Con 1.1, los personalizados del central también son *nested loop*, baratos, y el genérico no los mejora: Postgres sigue
planificando, y la sede V recibe su plan. Arreglar el modelo de costos arregla el plan del central y desarma la trampa del
genérico a la vez.

**Rúbrica.** Una respuesta correcta tiene que:
- mostrar los contadores y el método;
- relacionar los dos efectos con un solo cambio.

[← Volver al ejercicio](../13-el-optimizador-en-tres-motores.md#-ejercicio-12--el-genérico-con-el-modelo-de-costos-ajustado)

### Ejercicio 13

**Enunciado (resumen):** el *merge join*.

**Solución.**

```text
                           ->  Parallel Index Scan using result_lab_order_id_idx on result r  (cost=0.43..516777.84 rows=5055089 width=7) (actual rows=3969842.33 loops=3)
                                 Buffers: shared hit=1168052 read=101262
```

Para unir en orden, el *merge join* necesita `result` ordenado por `lab_order_id`, y lo obtiene recorriendo su índice entero: 12
millones de entradas, y por cada una, una visita a la página de la tabla. Casi todo el millón y cuarto de bloques sale de ese
nodo. Ganaría si los dos lados ya vinieran ordenados por la clave y fueran grandes los dos: por ejemplo, unir `result` entera con
`lab_order` entera, recorriendo los dos por su clave.

**Rúbrica.** Una respuesta correcta tiene que:
- encontrar el nodo;
- describir el caso en que el *merge join* gana.

[← Volver al ejercicio](../13-el-optimizador-en-tres-motores.md#-ejercicio-13--el-merge-join)

### Ejercicio 14

**Enunciado (resumen):** los hints de MySQL sobre la caja.

**Solución.**

```sql
-- mysql
EXPLAIN FORMAT=TREE SELECT /*+ NO_INDEX(p protocolos_en_orden_sede_fecha_idx) */ count(*)
FROM staging.protocolos_en_orden p WHERE Sede = 'V' AND Fecha >= '2026-09-01';
EXPLAIN FORMAT=TREE SELECT count(*)
FROM staging.protocolos_en_orden p FORCE INDEX (protocolos_en_orden_idpaciente_idx)
WHERE Sede = 'V' AND Fecha >= '2026-09-01';
```

```text
-> Aggregate: count(0)  (cost=158182 rows=1)
    -> Filter: ((p.Sede = 'V') and (p.Fecha >= TIMESTAMP'2026-09-01 00:00:00'))  (cost=137942 rows=87841)
        -> Table scan on p  (cost=137942 rows=1.32e+6)
-> Aggregate: count(0)  (cost=1.47e+6 rows=1)
    -> Filter: ((p.Sede = 'V') and (p.Fecha >= TIMESTAMP'2026-09-01 00:00:00'))  (cost=1.45e+6 rows=87841)
        -> Table scan on p  (cost=1.45e+6 rows=1.32e+6)
```

`NO_INDEX` deja sin el índice útil, y el plan recorre la tabla. `FORCE INDEX` sobre el índice por paciente también recorre la
tabla: un índice por paciente no sirve para filtrar por sede y fecha, y `FORCE INDEX` no lo vuelve útil; solo encarece la
alternativa (el costo de 1,45 millones es el de una recorrida que el hint hizo parecer cara). Un hint no puede forzar un camino
que no existe.

**Rúbrica.** Una respuesta correcta tiene que:
- mostrar los dos planes;
- explicar por qué el `FORCE INDEX` no usa el índice.

[← Volver al ejercicio](../13-el-optimizador-en-tres-motores.md#-ejercicio-14--los-hints-de-mysql-sobre-la-caja)

---

## 🟠 Difícil (15–20)

### Ejercicio 15

**Enunciado (resumen):** el hint en las sedes activas.

**Solución de referencia.**

| Sede | Proporción de protocolos | Entradas leídas con el hint |
|---|---|---|
| C | 47 % | 118 |
| A | 13 % | 338 |
| R | 12 % | 387 |
| V | 11 % | 367 |
| J | 11 % | 423 |
| E | 0 % desde 2022 | 691.136 |

Para encontrar 50 protocolos de una sede que tiene una fracción *p* de los recientes, el índice por fecha recorre unas 50/*p*
entradas: 106 para el central y unas 450 para un centro. Los números medidos se acercan a eso. Para la sede `E`, *p* es cero en los
últimos cuatro años, y la cuenta recorre todo hasta 2021. El hint fue correcto para cada sede mientras todas tuvieron movimiento.

**Rúbrica.** Una respuesta correcta tiene que:
- medir las seis sedes;
- explicar la relación 50/*p* y por qué falla con *p* = 0.

[← Volver al ejercicio](../13-el-optimizador-en-tres-motores.md#-ejercicio-15--el-hint-en-las-sedes-activas)

### Ejercicio 16

**Enunciado (resumen):** los dos hints que ya no encuentran su índice.

**Solución de referencia.**

```text
ERROR 1176 (42000) at line 36: Key 'protocol_hint_fecha_idx' doesn't exist in table 'protocol_hint'
Warning	3128	Unresolved name `p`@`select#1` `protocol_hint_gone_idx` for INDEX hint
```

El `FORCE INDEX` hace fallar la consulta: la pantalla deja de andar y alguien se entera ese día. El *optimizer hint* deja un aviso
que ningún *driver* muestra por defecto, y la consulta sigue con el plan que el optimizador elija. Para producción, una
respuesta defendible elige el error: un hint que dejó de aplicar es una decisión que ya nadie controla, y es mejor saberlo. La
otra respuesta defendible elige el aviso, si hay una alarma que lea `SHOW WARNINGS` o el *performance schema*; sin esa alarma,
el aviso es silencio.

**Rúbrica.** Una respuesta correcta tiene que:
- reproducir los dos mensajes;
- elegir uno con la condición que lo hace aceptable.

[← Volver al ejercicio](../13-el-optimizador-en-tres-motores.md#-ejercicio-16--los-dos-hints-que-ya-no-encuentran-su-índice)

### Ejercicio 17

**Enunciado (resumen):** un plan fijado que envejece.

**Solución de referencia.**

```text
   since    | nested |  hash
------------+--------+--------
 2026-09-01 |   36.8 |  250.1
 2026-01-01 |  201.0 |  310.8
 2022-01-01 |  630.5 |  586.5
 2012-01-01 | 1534.6 | 1548.4
 1997-01-01 | 1405.1 | 1243.5
```

El *nested loop* fijado gana hasta el año (72.592 protocolos), y desde 2022 (379.483) empata o pierde. En una corrida anterior,
desde 2012 perdió por un 29 % (1.626 contra 1.262 ms). Con los datos en memoria la diferencia es chica en los dos sentidos; lo que
el ejercicio muestra es que el punto de cruce existe, y que un hint lo ignora.

**Rúbrica.** Una respuesta correcta tiene que:
- ubicar el cruce entre el año y los cinco años;
- no exagerar la pérdida, que con estos datos es chica.

[← Volver al ejercicio](../13-el-optimizador-en-tres-motores.md#-ejercicio-17--un-plan-fijado-que-envejece)

### Ejercicio 18

**Enunciado (resumen):** el central, mes por mes.

**Solución de referencia.**

```sql
-- postgres
PREPARE by_month(char, date) AS
SELECT r.analyte_code, count(*) FROM staging.order_site o JOIN alameda.result r USING (lab_order_id)
WHERE o.site_code = $1 AND o.ordered_on >= $2 AND o.ordered_on < $2 + 31 GROUP BY r.analyte_code;
EXECUTE by_month('C', '2025-01-01');   -- y así hasta noviembre
EXPLAIN (COSTS OFF) EXECUTE by_month('C', '2025-12-01');
SELECT generic_plans, custom_plans FROM pg_prepared_statements WHERE name = 'by_month';
```

```text
                     ->  Nested Loop
                                       Index Cond: ((site_code = $1) AND (ordered_on >= $2) AND (ordered_on < ($2 + 31)))
 generic_plans | custom_plans
---------------+--------------
             7 |            5
```

Aparece el genérico, y es un *nested loop*: con la fecha también como parámetro, estima un sexto de la tabla por un rango
desconocido, unas 1.100 filas, y le sale barato (costo 89.302). Los personalizados del central son *hash join* (161.852) y el
genérico, más barato, gana. **Es la dirección de la apuesta**: el genérico le da al central el método de un centro chico. Y
aquí acierta: 22 ms el genérico contra 244 ms el personalizado (mediana de cuatro, con `plan_cache_mode` forzado en cada
sentido). Dos errores del optimizador, el del modelo de costos y el del genérico, se cancelaron.

**Rúbrica.** Una respuesta correcta tiene que:
- mostrar que aparece el genérico, y con qué método;
- medir los dos planes y no confundir "genérico" con "peor".

[← Volver al ejercicio](../13-el-optimizador-en-tres-motores.md#-ejercicio-18--el-central-mes-por-mes)

### Ejercicio 19

**Enunciado (resumen):** la pantalla de la sede, en Postgres.

**Solución de referencia.**

```sql
-- postgres
EXPLAIN (ANALYZE, BUFFERS, TIMING OFF, COSTS OFF)
SELECT lab_order_id, ordered_on FROM staging.order_site WHERE site_code = 'E' ORDER BY ordered_on DESC LIMIT 50;
BEGIN;
DROP INDEX staging.order_site_site_ordered_idx;
CREATE INDEX order_site_ordered_idx ON staging.order_site (ordered_on);
-- la misma consulta, para E y para V
ROLLBACK;
```

```text
   ->  Index Scan Backward using order_site_site_ordered_idx on order_site (actual rows=50.00 loops=1)
         Buffers: shared hit=1 read=5
 Execution Time: 0.272 ms

   ->  Index Scan Backward using order_site_ordered_idx on order_site (actual rows=50.00 loops=1)
         Filter: (site_code = 'E'::bpchar)
         Rows Removed by Filter: 691064
         Buffers: shared hit=14404 read=611
 Execution Time: 63.421 ms
```

Con el índice compuesto, seis bloques. Sin él, **Postgres comete solo el error del hint**: recorre el índice por fecha hacia atrás
y descarta 691.064 protocolos, porque cree que la sede `E` (el 6 % de la tabla) está repartida en el tiempo, y no que terminó en
2022. Es la correlación de la Fase 12 entre la sede y la fecha. Para la sede V, el mismo plan descarta 314 filas y tarda 0,05 ms.
La lección vale sin hints: un plan bueno para los valores comunes es malo para un valor que se concentra en otro lugar.

**Rúbrica.** Una respuesta correcta tiene que:
- medir con y sin el índice compuesto;
- explicar el error con la correlación, no con el hint.

[← Volver al ejercicio](../13-el-optimizador-en-tres-motores.md#-ejercicio-19--la-pantalla-de-la-sede-en-postgres)

### Ejercicio 20

**Enunciado (resumen):** el *pool* de conexiones.

**Solución de referencia.**

```python
with psycopg.connect(**config.POSTGRES, autocommit=True) as early, \
        psycopg.connect(**config.POSTGRES, autocommit=True) as late:
    for _ in range(10):
        run(early, "C")
    for _ in range(10):
        run(late, "V")
    print("la del central, V:", f"{run(early, 'V'):.1f} ms", counters(early))
    print("la de los centros, V:", f"{run(late, 'V'):.1f} ms", counters(late))
```

```text
la del central, V: 236.4 ms (1, Decimal('1'), Decimal('5'))
la de los centros, V: 20.6 ms (1, Decimal('0'), Decimal('6'))
```

La misma consulta, con el mismo valor, en el mismo segundo: 236 ms en una conexión y 21 en la otra. `pg_prepared_statements`
muestra solo las sentencias de la conexión que la consulta, y cada una tiene sus contadores. En un *pool*, qué conexión te toca
decide qué plan recibes.

**Rúbrica.** Una respuesta correcta tiene que:
- usar dos conexiones con historias distintas;
- mostrar los contadores de cada una, consultados desde ella misma.

[← Volver al ejercicio](../13-el-optimizador-en-tres-motores.md#-ejercicio-20--el-pool-de-conexiones)

---

## 🔴 Muy difícil (21–24)

### Ejercicio 21

**Enunciado (resumen):** Oracle.

**Solución de referencia.** El curso no publica números de Oracle. Lo que hay que mirar, entre ejecuciones de la consulta con la
variable de enlace: en `V$SQL`, para el `SQL_ID` de la consulta, las columnas `CHILD_NUMBER`, `IS_BIND_SENSITIVE`,
`IS_BIND_AWARE` y `EXECUTIONS`, y el plan de cada cursor hijo con `DBMS_XPLAN.DISPLAY_CURSOR(sql_id, child_number)`. La hipótesis
se confirma si después de unas ejecuciones con la sede V aparece un segundo cursor hijo marcado `IS_BIND_AWARE = 'Y'` con otro
plan. Y se refuta si Oracle nunca marca el cursor como sensible a los valores; la documentación pide un histograma sobre la
columna para que eso pase, así que el experimento tiene que recogerlo antes.

**Rúbrica.** Una respuesta correcta tiene que:
- leer los cursores hijos y sus marcas;
- decir qué resultado confirma y cuál refuta;
- no publicar ningún número.

[← Volver al ejercicio](../13-el-optimizador-en-tres-motores.md#-ejercicio-21--oracle)

### Ejercicio 22

**Enunciado (resumen):** la política de Alameda.

**Solución de referencia.** Una regla defendible, con sus mediciones:

1. **El modelo de costos primero**: `random_page_cost = 1.1` para la base de Alameda, si sus datos viven en SSD o caben en
   memoria. Arregla el plan del central (7,6 veces más rápido) y desarma la trampa del genérico (ejercicio 12).
2. **Las consultas parametrizadas por sede, con planes personalizados**: `ALTER ROLE` de la aplicación con
   `plan_cache_mode = force_custom_plan`. Cuesta unas décimas de milisegundo por ejecución (ejercicio 9) y evita los 220 ms
   del ejercicio 20.
3. **Sin hints** en la aplicación nueva. Si alguno hace falta, con su fecha, su medición y su revisión (ejercicio 24).

Lo que cuesta: el punto 1 cambia el plan de todas las consultas, y hay que medir las conocidas antes y después; el punto 2
renuncia a la reutilización también en consultas donde no hace daño.

**Rúbrica.** Una respuesta correcta tiene que:
- ordenar las medidas de la más general a la más puntual;
- dar el costo de cada una con una medición.

[← Volver al ejercicio](../13-el-optimizador-en-tres-motores.md#-ejercicio-22--la-política-de-alameda)

### Ejercicio 23

**Enunciado (resumen):** ¿bajar `random_page_cost` en el servidor?

**Solución de referencia.** Sí, con una condición. En la Fase 12, con 1.1 el barrido del precipicio movió el cambio de método de
entre cuatro y seis años a entre seis y diez, y a seis años el plan elegido fue el índice, cercano al más rápido. En esta, el
central pasa al *nested loop*, de 265 a 35 ms. Las dos mediciones son con los datos en memoria, en el contenedor del curso. La
condición: el disco del servidor real. En SSD, o si la base cabe en la memoria del servidor, el valor bajo describe lo que pasa;
en un disco giratorio, el 4 de fábrica sigue siendo el que corresponde, y bajar el valor haría que el optimizador prefiera
lecturas al azar que el disco cobra. La decisión se toma con el disco a la vista, no con el contenedor.

**Rúbrica.** Una respuesta correcta tiene que:
- usar las dos mediciones;
- condicionar la decisión al disco del servidor real.

[← Volver al ejercicio](../13-el-optimizador-en-tres-motores.md#-ejercicio-23--bajar-random_page_cost-en-el-servidor)

### Ejercicio 24

**Enunciado (resumen):** inventario de hints.

**Solución de referencia.**

```bash
grep -rnE "FORCE INDEX|USE INDEX|IGNORE INDEX|STRAIGHT_JOIN|/\*\+|SET (LOCAL )?enable_|plan_cache_mode" \
     --include='*.py' --include='*.sql' .
```

La ficha de cada hint encontrado, en un comentario al lado del hint:

```sql
-- HINT 2012-03-14 · Matías · el índice por fecha, porque el motor elegía recorrer la tabla
-- medido: 0,5 ms con el hint contra 180 ms sin él, sede V, 2 años de datos
-- depende de: que todas las sedes tengan protocolos recientes; que no exista un índice (Sede, Fecha)
-- revisar: cuando cambien los índices de Protocolos, o una vez por año
```

El campo que habría salvado a la sede `E` es **"depende de"**: escrito en 2012, decía que el hint suponía sedes activas, y el
cierre de la sede en 2022 lo invalidaba. Los números de la ficha de ejemplo son ilustrativos: en una ficha real son los de la
medición que justificó el hint.

**Rúbrica.** Una respuesta correcta tiene que:
- buscar las dos familias de hints de MySQL y los equivalentes de Postgres;
- tener en la ficha la fecha, la medición, el supuesto y la revisión.

[← Volver al ejercicio](../13-el-optimizador-en-tres-motores.md#-ejercicio-24--inventario-de-hints)

---

## 🔥 Opcionales

### Ejercicio 🔥 1

**Enunciado (resumen):** `pg_hint_plan` en una imagen derivada.

**Solución.** El `Dockerfile`, sobre la imagen del curso, con el paquete de PGDG (el repositorio ya está configurado en la imagen
oficial de Postgres):

```dockerfile
ARG BASE
FROM ${BASE}
RUN apt-get update && apt-get install -y --no-install-recommends postgresql-18-pg-hint-plan \
    && rm -rf /var/lib/apt/lists/*
```

```bash
docker build --label curso=ruta-sql --build-arg BASE=pgvector/pgvector@sha256:2358fcba361e… -t ruta-sql/postgres-hint-plan:f13 .
docker run -d --rm --label curso=ruta-sql --name ruta-sql-hint-f13 -e POSTGRES_PASSWORD=lab \
    ruta-sql/postgres-hint-plan:f13 -c shared_preload_libraries=pg_hint_plan
```

Sin datos de la caja: dos tablas de prueba, `o` con 200.000 filas y `r` con un millón y un índice por `oid`.

```sql
-- postgres
CREATE EXTENSION pg_hint_plan;   -- 1.8.0
EXPLAIN (COSTS OFF) SELECT count(*) FROM o JOIN r ON r.oid = o.id WHERE o.site = '1';
/*+ NestLoop(o r) */ EXPLAIN (COSTS OFF) SELECT count(*) FROM o JOIN r ON r.oid = o.id WHERE o.site = '1';
/*+ NestLoop(o x) */ EXPLAIN (COSTS OFF) SELECT count(*) FROM o JOIN r ON r.oid = o.id WHERE o.site = '1';
SET pg_hint_plan.debug_print = on; SET client_min_messages = log;
/*+ NestLoop(o x) */ EXPLAIN (COSTS OFF) SELECT count(*) FROM o JOIN r ON r.oid = o.id WHERE o.site = '1';
```

```text
               ->  Hash Join                          -- sin hint
   ->  Nested Loop                                    -- con NestLoop(o r)
         ->  Index Only Scan using r_oid_idx on r
               ->  Hash Join                          -- con NestLoop(o x), sin aviso
LOG:  pg_hint_plan:
used hint:
not used hint:
NestLoop(o x)
```

El hint bien escrito cambia el método. El mal escrito no hace nada, **sin error ni aviso**: solo con `debug_print` aparece como
"not used hint". Es el comportamiento del *optimizer hint* de MySQL llevado al extremo, sin siquiera el aviso. El contenedor se
borra al pararlo (`--rm`); la imagen queda con la etiqueta del curso.

[← Volver al ejercicio](../13-el-optimizador-en-tres-motores.md#-ejercicio--1--pg_hint_plan-en-una-imagen-derivada)
