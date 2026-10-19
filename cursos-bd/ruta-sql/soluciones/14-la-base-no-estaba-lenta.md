# ✅ Soluciones — Fase 14: La base no estaba lenta

> **Curso:** Ruta SQL · Solucionario de la [Fase 14](../14-la-base-no-estaba-lenta.md)
> **Ejercicios:** 26 · **Perfil:** M · **Motores:** Postgres y MySQL de
> [`a02`](../a02-compose-de-la-ruta.md#-las-versiones-del-curso)
> **Fecha de verificación ejecutada:** 14/10/2026

> ⚠️ **Intenta el ejercicio antes de leer su solución.** Leída antes, solo te enseña a reconocerla.

Todas las soluciones suponen el modelo de `uv run lab load --profile m --model`, `01_autoindex_copy.sql` corrido en MySQL y
`02_portal_paging.sql` en Postgres. `front.py` se corre desde `src/` con `uv run python`. Los `.pgbench` se copian al contenedor
de Postgres y se corren con el `pgbench` que trae la imagen, sin publicar puertos. El boss no está aquí: es un encargo.

---

## 🟢 Fácil (1–8)

### Ejercicio 1

**Enunciado (resumen):** el formulario, como Access.

**Solución.**

```text
pantalla                            viajes      filas  muestra  filas/muestra        bytes        ms
formulario, como Access                  7    1327682       60        22128.0     17337090    1895.5
```

El primer viaje es `SELECT IdProtocolo FROM staging.protocolos ORDER BY IdProtocolo DESC`: las 1.327.622 claves. Los otros seis
piden diez filas cada uno con `WHERE IdProtocolo IN (…)`, las 60 que llenan la hoja de datos. 1.327.622 + 60 = 1.327.682.

**Rúbrica.** Una respuesta correcta tiene que:
- separar el viaje de las claves de los seis de las filas;
- reconstruir las 1.327.682.

[← Volver al ejercicio](../14-la-base-no-estaba-lenta.md#-ejercicio-1--el-formulario-como-access)

### Ejercicio 2

**Enunciado (resumen):** el formulario, bien pedido.

**Solución.**

```sql
-- mysql
SELECT * FROM staging.protocolos ORDER BY IdProtocolo DESC LIMIT 60;
```

```text
formulario, 60 filas                     1         60       60            1.0         5692       0.8
```

Una consulta, las 60 filas que se ven. Lo que el usuario pierde es la barra de desplazamiento sobre toda la tabla, que en un
formulario de un millón de protocolos no sirve para nada.

**Rúbrica.** Una respuesta correcta tiene que:
- escribir la consulta con `LIMIT`;
- comparar los bytes con los del ejercicio 1.

[← Volver al ejercicio](../14-la-base-no-estaba-lenta.md#-ejercicio-2--el-formulario-bien-pedido)

### Ejercicio 3

**Enunciado (resumen):** el N+1.

**Solución.**

```text
resultados, uno por protocolo           61        429      429            1.0        73612      18.9
resultados, una consulta                 2        429      429            1.0        34613       2.9
```

En los dos casos, un viaje para los 60 protocolos de la pantalla. Después, 60 consultas de `WHERE IdProtocolo = %s` contra una
sola de `WHERE IdProtocolo IN (…)`, que traen los 369 resultados. Las filas son las mismas 429 (60 protocolos y 369
resultados); sobran 59 viajes.

**Rúbrica.** Una respuesta correcta tiene que:
- ver que las filas no cambian;
- contar los viajes de cada versión.

[← Volver al ejercicio](../14-la-base-no-estaba-lenta.md#-ejercicio-3--el-n1)

### Ejercicio 4

**Enunciado (resumen):** el join en el cliente.

**Solución.**

```text
turnos, join en el cliente               1     242427      249          973.6     33065042    1904.9
turnos, join en el servidor              1        249      249            1.0        34475       3.1
```

Un viaje en los dos casos: el problema no es la cantidad de viajes sino lo que trae cada uno. 33.065.042 bytes contra 34.475, 959
veces más.

**Rúbrica.** Una respuesta correcta tiene que:
- dar las filas y los bytes;
- notar que los viajes son los mismos.

[← Volver al ejercicio](../14-la-base-no-estaba-lenta.md#-ejercicio-4--el-join-en-el-cliente)

### Ejercicio 5

**Enunciado (resumen):** `OFFSET`, página 1 y página 1.000.

**Solución.**

```sql
-- postgres
EXPLAIN (ANALYZE, BUFFERS)
SELECT * FROM staging.portal_order ORDER BY ordered_on DESC, lab_order_id DESC OFFSET 0 LIMIT 20;
EXPLAIN (ANALYZE, BUFFERS)
SELECT * FROM staging.portal_order ORDER BY ordered_on DESC, lab_order_id DESC OFFSET 19980 LIMIT 20;
```

```text
 page  | offset_bloques | offset_ms
-------+----------------+-----------
     1 |             20 |      0.01
  1000 |          17687 |      3.83
```

La página 1.000 recorre 20.000 entradas del índice y visita la tabla por cada una, para mostrar las últimas 20.

**Rúbrica.** Una respuesta correcta tiene que:
- calcular el `OFFSET` de la página 1.000 (19.980);
- dar los bloques de las dos.

[← Volver al ejercicio](../14-la-base-no-estaba-lenta.md#-ejercicio-5--offset-página-1-y-página-1000)

### Ejercicio 6

**Enunciado (resumen):** *keyset*, página 1.000.

**Solución.**

```sql
-- postgres
-- el último de la página 999, que el enlace de "siguiente" lleva consigo
SELECT ordered_on, lab_order_id FROM staging.portal_order
ORDER BY ordered_on DESC, lab_order_id DESC OFFSET 19979 LIMIT 1;
-- la página 1.000
SELECT * FROM staging.portal_order
WHERE (ordered_on, lab_order_id) < (:last_on, :last_id)
ORDER BY ordered_on DESC, lab_order_id DESC LIMIT 20;
```

```text
 page  | keyset_bloques | keyset_ms
-------+----------------+-----------
  1000 |             22 |      0.02
```

22 bloques: baja por el índice hasta el punto de la clave y lee 20 entradas. El primer `SELECT` solo existe en la medición; en el
portal, la clave del último protocolo viene en el enlace de la página anterior.

**Rúbrica.** Una respuesta correcta tiene que:
- usar la clave completa, con el desempate;
- explicar de dónde sale la clave en el portal real.

[← Volver al ejercicio](../14-la-base-no-estaba-lenta.md#-ejercicio-6--keyset-página-1000)

### Ejercicio 7

**Enunciado (resumen):** "página 1 de …".

**Solución.**

```text
               ->  Parallel Seq Scan on portal_order  (cost=0.00..16219.76 rows=553176 width=0) (actual rows=442540.67 loops=3)
                     Buffers: shared hit=10688
 Execution Time: 38.348 ms
```

10.688 bloques, la tabla entera, en cada página que muestre el total. Un usuario que hojea diez páginas paga diez veces el
`count(*)` para un número que no cambió entre una página y la siguiente.

**Rúbrica.** Una respuesta correcta tiene que:
- dar los bloques;
- ver que se paga en cada página.

[← Volver al ejercicio](../14-la-base-no-estaba-lenta.md#-ejercicio-7--página-1-de-)

### Ejercicio 8

**Enunciado (resumen):** `pg_stat_statements`.

**Solución.**

```text
 calls | rows | total_ms | mean_ms |                                 query
-------+------+----------+---------+------------------------------------------------------------------------
    60 |  369 |     7.87 |   0.131 | SELECT * FROM alameda.result WHERE lab_order_id = $1
     1 |  369 |     0.26 |   0.256 | SELECT r.* FROM alameda.result r WHERE r.lab_order_id IN (SELECT lab_o
```

Las 60 consultas distintas (cada una con su número) quedan como una sola entrada, con el número reemplazado por `$1` y 60
llamadas. Son los mismos 369 resultados que en MySQL: las 429 filas de `front.py` suman además las 60 de los protocolos de la
pantalla.

**Rúbrica.** Una respuesta correcta tiene que:
- leer las 60 llamadas de una entrada;
- explicar la normalización.

[← Volver al ejercicio](../14-la-base-no-estaba-lenta.md#-ejercicio-8--pg_stat_statements)

---

## 🟡 Intermedio (9–16)

### Ejercicio 9

**Enunciado (resumen):** la cuenta de la VPN.

**Solución.** Tiempo de red = viajes × ida y vuelta + bytes × 8 / ancho de banda.

| Pantalla | 30 ms, 4 Mbit/s | 80 ms, 1 Mbit/s |
|---|---|---|
| formulario, como Access | 0,21 + 34,67 = 34,9 s | 0,56 + 138,70 = 139,3 s |
| formulario, 60 filas | 0,03 + 0,01 = 0,04 s | 0,08 + 0,05 = 0,13 s |
| resultados, uno por protocolo | 1,83 + 0,15 = 2,0 s | 4,88 + 0,59 = 5,5 s |
| resultados, una consulta | 0,06 + 0,07 = 0,13 s | 0,16 + 0,28 = 0,44 s |
| turnos, join en el cliente | 0,03 + 66,13 = 66,2 s | 0,08 + 264,52 = 264,6 s |
| turnos, join en el servidor | 0,03 + 0,07 = 0,10 s | 0,08 + 0,28 = 0,36 s |

El N+1 depende de la latencia: casi todo su tiempo es viajes por ida y vuelta. El formulario y el join en el cliente dependen del
ancho de banda: un viaje con decenas de megabytes. Las versiones bien pedidas no pasan de medio segundo con la peor conexión.

**Rúbrica.** Una respuesta correcta tiene que:
- separar el término de latencia del de ancho de banda;
- decir que son cuentas con supuestos, no mediciones.

[← Volver al ejercicio](../14-la-base-no-estaba-lenta.md#-ejercicio-9--la-cuenta-de-la-vpn)

### Ejercicio 10

**Enunciado (resumen):** lo que pesa un viaje.

**Solución.** 73.612 − 34.613 = 38.999 bytes de más, por 59 viajes de más: **unos 661 bytes por viaje**. Es lo que MySQL manda
en cada respuesta además de las filas: la descripción de cada columna (nombre, tabla, tipo, largo) y los paquetes de fin de
resultado. `ResultadoItem` tiene ocho columnas; la descripción viaja una vez por respuesta, y el N+1 la repite sesenta veces.

**Rúbrica.** Una respuesta correcta tiene que:
- calcular los bytes por viaje;
- atribuirlos a la descripción de columnas de cada respuesta.

[← Volver al ejercicio](../14-la-base-no-estaba-lenta.md#-ejercicio-10--lo-que-pesa-un-viaje)

### Ejercicio 11

**Enunciado (resumen):** la página 50.000.

**Solución.**

```text
 page  | offset_bloques | offset_ms | keyset_bloques | keyset_ms
-------+----------------+-----------+----------------+-----------
 50000 |         878758 |    195.97 |             21 |      0.07
```

878.758 contra 21 bloques: 41.845 veces. La página 50.000 con `OFFSET` recorre un millón de entradas del índice, y por cada una
visita la tabla; la de *keyset* lee lo mismo que la página 1.

**Rúbrica.** Una respuesta correcta tiene que:
- dar los bloques de los dos;
- explicar por qué *keyset* no depende de la página.

[← Volver al ejercicio](../14-la-base-no-estaba-lenta.md#-ejercicio-11--la-página-50000)

### Ejercicio 12

**Enunciado (resumen):** el total aproximado.

**Solución.**

```sql
-- postgres
SELECT reltuples::bigint FROM pg_class WHERE oid = 'staging.portal_order'::regclass;
```

```text
 reltuples
-----------
   1327622
 Index Scan using pg_class_oid_index on pg_class (actual rows=1.00 loops=1)
   Buffers: shared hit=3
```

Tres bloques del catálogo contra 10.688 de la tabla. Aquí coincide con el total exacto (1.327.622) porque la tabla se analizó
después de crearse y no cambió; en una tabla que recibe escrituras, se aleja hasta el próximo `ANALYZE` (Fase 12). Para "unos 1,3
millones de protocolos" alcanza.

**Rúbrica.** Una respuesta correcta tiene que:
- leer `reltuples`;
- decir cuándo se aleja del total real.

[← Volver al ejercicio](../14-la-base-no-estaba-lenta.md#-ejercicio-12--el-total-aproximado)

### Ejercicio 13

**Enunciado (resumen):** el N+1 visto desde el servidor.

**Solución.** El promedio del N+1 es 0,131 ms, la mitad que la consulta única (0,256 ms): ordenado por promedio, el N+1 parece la
consulta más barata del sistema. El total es 7,87 ms contra 0,26 ms: 30 veces. `ORDER BY total_exec_time DESC` lo pone arriba,
y `calls` dice por qué.

**Rúbrica.** Una respuesta correcta tiene que:
- comparar promedio y total;
- proponer el orden por total.

[← Volver al ejercicio](../14-la-base-no-estaba-lenta.md#-ejercicio-13--el-n1-visto-desde-el-servidor)

### Ejercicio 14

**Enunciado (resumen):** *keyset* sin su índice.

**Solución.**

```sql
-- postgres
BEGIN;
DROP INDEX staging.portal_order_newest_idx;
EXPLAIN (ANALYZE, BUFFERS, TIMING OFF, COSTS OFF)
SELECT * FROM staging.portal_order WHERE (ordered_on, lab_order_id) < ('2020-06-01', 900000)
ORDER BY ordered_on DESC, lab_order_id DESC LIMIT 20;
ROLLBACK;
```

```text
               Sort Method: top-N heapsort  Memory: 27kB
               ->  Parallel Seq Scan on portal_order (actual rows=111810.33 loops=3)
                     Filter: (ROW(ordered_on, lab_order_id) < ROW('2020-06-01'::date, 900000))
                     Buffers: shared hit=10688
 Execution Time: 46.178 ms
```

Sin el índice, *keyset* recorre la tabla entera y ordena para quedarse con 20: 10.688 bloques y 46 ms, en cada página. *Keyset*
no es una manera de escribir la consulta; es una consulta más un índice en el orden de la lista.

**Rúbrica.** Una respuesta correcta tiene que:
- mostrar el plan sin índice;
- concluir que el índice es parte del diseño.

[← Volver al ejercicio](../14-la-base-no-estaba-lenta.md#-ejercicio-14--keyset-sin-su-índice)

### Ejercicio 15

**Enunciado (resumen):** los turnos, con los identificadores.

**Solución.**

```sql
-- mysql
SELECT * FROM legacy.Pacientes WHERE IdPaciente IN (%s, %s, …);   -- los 249 de la tabla local
```

```text
turnos, join en el servidor              1        249      249            1.0        34475       3.1
```

249 filas en un viaje. El límite práctico es el tamaño de la lista: con miles de identificadores, la sentencia se vuelve enorme
(MySQL la rechaza si pasa `max_allowed_packet`, Fase 09), y conviene cargarlos en una tabla temporal del servidor y unir allí. En
Access, la salida equivalente era llevar la tabla de turnos al servidor.

**Rúbrica.** Una respuesta correcta tiene que:
- escribir la consulta con `IN`;
- nombrar el límite y la alternativa.

[← Volver al ejercicio](../14-la-base-no-estaba-lenta.md#-ejercicio-15--los-turnos-con-los-identificadores)

### Ejercicio 16

**Enunciado (resumen):** cien páginas en `pg_stat_statements`.

**Solución.**

```sql
-- postgres
SELECT pg_stat_statements_reset();
SELECT format('SELECT * FROM staging.portal_order ORDER BY ordered_on DESC, lab_order_id DESC OFFSET %s LIMIT 20',
              20 * (n - 1))
FROM generate_series(1, 100) n \gexec
SELECT calls, total_exec_time, mean_exec_time, min_exec_time, max_exec_time, shared_blks_hit + shared_blks_read
FROM pg_stat_statements WHERE query LIKE '%portal_order ORDER BY%';
```

```text
 calls | total_ms | mean_ms | min_ms | max_ms | bloques
-------+----------+---------+--------+--------+---------
   100 |     13.6 |   0.136 |  0.017 |  0.282 |   88800
```

Las cien páginas son una entrada (el `OFFSET` también se normaliza). El mínimo es de las primeras páginas y el máximo de las últimas:
17 veces. `pg_stat_statements` no separa por valor de parámetro, así que una entrada con un máximo muy lejos del mínimo es la señal
de una consulta cuyo costo depende del valor: un `OFFSET`, o la sede de la Fase 13.

**Rúbrica.** Una respuesta correcta tiene que:
- leer el mínimo y el máximo;
- interpretar la distancia entre los dos.

[← Volver al ejercicio](../14-la-base-no-estaba-lenta.md#-ejercicio-16--cien-páginas-en-pg_stat_statements)

---

## 🟠 Difícil (17–22)

### Ejercicio 17

**Enunciado (resumen):** ocho clientes con `OFFSET`.

**Solución de referencia.**

```bash
docker exec -w /tmp/f14 <contenedor de postgres> sh -c "pgbench -U postgres -n -c 8 -j 4 -T 30 \
    -f portal_offset.pgbench --log --log-prefix=lat_offset alameda; \
    cat lat_offset* | awk '{n++; if (\$3/1000 > 100) o++} END {print n, o, 100*o/n}'"
```

```text
number of transactions actually processed: 1851
latency average = 130.256 ms
tps = 61.417661 (without initial connection time)
n=1851  >100ms=1137 (61.4%)
```

La tercera columna del registro de `pgbench` es la latencia en microsegundos. Con ocho clientes, una página al azar promedia 130
ms, aunque sola tarde entre décimas de milisegundo y 60 ms: los ocho compiten por la CPU recorriendo índices. Con `statement_timeout = '100ms'`,
seis de cada diez se cancelarían.

**Rúbrica.** Una respuesta correcta tiene que:
- contar sobre el registro, no estimar desde el promedio;
- explicar por qué bajo carga es peor que solo.

[← Volver al ejercicio](../14-la-base-no-estaba-lenta.md#-ejercicio-17--ocho-clientes-con-offset)

### Ejercicio 18

**Enunciado (resumen):** ocho clientes con *keyset*.

**Solución de referencia.**

```text
number of transactions actually processed: 1590281
latency average = 0.151 ms
tps = 53019.359049 (without initial connection time)
n=1590281  >100ms=0 (0.0%)
```

53.019 páginas por segundo contra 61: 863 veces. Ninguna por encima de 100 ms. El script elige un día al azar entre marzo de 1997
y octubre de 2026 como punto de partida, que es lo que haría un enlace de "siguiente" en cualquier lugar de la lista.

**Rúbrica.** Una respuesta correcta tiene que:
- dar la proporción contra `OFFSET`;
- explicar cómo el script elige la página.

[← Volver al ejercicio](../14-la-base-no-estaba-lenta.md#-ejercicio-18--ocho-clientes-con-keyset)

### Ejercicio 19

**Enunciado (resumen):** el formulario con filtro.

**Solución de referencia.**

```sql
-- mysql
SHOW SESSION STATUS LIKE 'Bytes_sent';
SELECT IdProtocolo FROM staging.protocolos WHERE Fecha >= '2026-09-01' ORDER BY IdProtocolo DESC;
SHOW SESSION STATUS LIKE 'Bytes_sent';
```

```text
Bytes_sent	347
Bytes_sent	275759
```

Unos 275 kB para las 21.162 claves de septiembre, contra 17 MB de la tabla entera: 63 veces menos. En la VPN de la sección 5.2,
de 35 s a medio segundo. El filtro no arregla el patrón (sigue trayendo claves que no muestra, 353 por fila mostrada), pero lo
achica lo suficiente para que deje de doler.

**Rúbrica.** Una respuesta correcta tiene que:
- medir los bytes con el contador de la sesión;
- decir que el filtro achica el patrón sin eliminarlo.

[← Volver al ejercicio](../14-la-base-no-estaba-lenta.md#-ejercicio-19--el-formulario-con-filtro)

### Ejercicio 20

**Enunciado (resumen):** *keyset* solo por fecha.

**Solución de referencia.**

```sql
-- postgres
WITH page1 AS (SELECT * FROM staging.portal_order ORDER BY ordered_on DESC, lab_order_id DESC LIMIT 20),
     last AS (SELECT min(ordered_on) AS d FROM page1)
SELECT (SELECT count(*) FROM staging.portal_order, last WHERE ordered_on = last.d) AS mismo_dia,
       (SELECT count(*) FROM page1, last WHERE page1.ordered_on = last.d) AS en_la_pagina_1;
```

```text
 mismo_dia | en_la_pagina_1
-----------+----------------
       518 |             20
```

La primera página entera es del último día, que tiene 518 protocolos. Con la clave solo por fecha, la página 2 pediría
`ordered_on < ese día`, y **los otros 498 protocolos de ese día no aparecerían en ninguna página**. Con `<=` aparecerían, pero la
página 2 repetiría las 20 de la primera, una y otra vez. El desempate por `lab_order_id` es lo que hace única la posición.

**Rúbrica.** Una respuesta correcta tiene que:
- medir cuántos comparten el día;
- describir las dos fallas, `<` y `<=`.

[← Volver al ejercicio](../14-la-base-no-estaba-lenta.md#-ejercicio-20--keyset-solo-por-fecha)

### Ejercicio 21

**Enunciado (resumen):** *keyset* en MySQL.

**Solución de referencia.**

```sql
-- mysql
EXPLAIN ANALYZE SELECT * FROM staging.protocolos WHERE (Fecha, IdProtocolo) < ('2001-06-01', 2147483647)
ORDER BY Fecha DESC, IdProtocolo DESC LIMIT 20;
EXPLAIN ANALYZE SELECT * FROM staging.protocolos
WHERE Fecha < '2001-06-01' OR (Fecha = '2001-06-01' AND IdProtocolo < 2147483647)
ORDER BY Fecha DESC, IdProtocolo DESC LIMIT 20;
```

```text
-> Index scan on protocolos using protocolos_fecha_idx (reverse)  (cost=0.0234 rows=20) (actual time=0.0842..1099 rows=1.32e+6 loops=1)
-> Index range scan on protocolos using protocolos_fecha_idx over (NULL < Fecha < '2001-06-01 00:00:00.000') OR (…) (reverse)  (actual time=0.353..0.445 rows=20 loops=1)
```

Con la comparación de filas, MySQL recorre el índice al revés desde el principio y filtra cada entrada: los protocolos más nuevos
que 2001 son casi todos, 1,32 millones, antes de encontrar los 20. Con `OR`, el optimizador de rangos arma el intervalo y empieza
justo en el punto. La documentación de MySQL describe qué comparaciones de filas convierte en rangos y cuáles no (en las
referencias de la fase).

**Rúbrica.** Una respuesta correcta tiene que:
- mostrar los dos planes;
- explicar que la diferencia es del optimizador de rangos, no del índice.

[← Volver al ejercicio](../14-la-base-no-estaba-lenta.md#-ejercicio-21--keyset-en-mysql)

### Ejercicio 22

**Enunciado (resumen):** `OFFSET` en MySQL.

**Solución de referencia.**

```text
-> Limit/Offset: 20/999980 row(s)  (cost=133844 rows=20) (actual time=892..892 rows=20 loops=1)
    -> Sort: staging.protocolos.Fecha DESC, staging.protocolos.IdProtocolo DESC, limit input to 1000000 row(s) per chunk  (cost=133844 rows=1.32e+6) (actual time=796..869 rows=1e+6 loops=1)
        -> Table scan on protocolos  (cost=133844 rows=1.32e+6) (actual time=0.0695..454 rows=1.33e+6 loops=1)
```

892 ms: MySQL recorre la tabla entera y la ordena, en lugar de recorrer el índice de `Fecha`, porque visitar la tabla un millón de
veces por el índice le sale más caro. Postgres, con su índice `(ordered_on DESC, lab_order_id DESC)`, hizo la misma página en 196
ms bajo `EXPLAIN ANALYZE`. Las tablas no son iguales (MySQL tiene el índice por `Fecha` solo, y la clave entra por ser la
primaria), así que lo que se compara es el plan, no el motor.

**Rúbrica.** Una respuesta correcta tiene que:
- leer el plan de MySQL;
- no sacar una conclusión sobre los motores de dos tablas distintas.

[← Volver al ejercicio](../14-la-base-no-estaba-lenta.md#-ejercicio-22--offset-en-mysql)

---

## 🔴 Muy difícil (23–26)

### Ejercicio 23

**Enunciado (resumen):** lo que había que comprar en 2014.

**Solución de referencia.** Con las mediciones de la fase, un servidor más grande arreglaba como mucho el tiempo del servidor: los
1,9 s de entregar las claves del formulario y los 1,9 s de entregar `Pacientes`. Los otros 33 s del formulario y 64 s de los
turnos son red. Una respuesta defendible pone el dinero en **horas de desarrollo**: cambiar el formulario para que pida lo que
muestra (de 35 s a 0,04 s en la VPN), llevar la tabla de turnos al servidor (de 66 s a 0,1 s) y juntar las consultas del
subformulario (de 2 s a 0,13 s). Otra defendible pone una parte en **ancho de banda** para los centros, que arregla el formulario
y los turnos a medias y no toca el N+1. Lo que no se defiende es el motor: no arreglaba ninguna de las tres pantallas.

**Rúbrica.** Una respuesta correcta tiene que:
- separar con números lo que es servidor de lo que es red;
- asignar cada gasto a la pantalla que arregla.

[← Volver al ejercicio](../14-la-base-no-estaba-lenta.md#-ejercicio-23--lo-que-había-que-comprar-en-2014)

### Ejercicio 24

**Enunciado (resumen):** ¿está lenta la base?

**Solución de referencia.** No. De los 4 s, la base explica 0,3: los otros 3,7 están entre el servidor y la pantalla (red,
aplicación, *driver*). Las dos mediciones que lo confirman: `calls` de las consultas de esa pantalla en `pg_stat_statements` (si
son decenas o cientos, es un N+1 y el tiempo es latencia) y los bytes que recibe la pantalla (si son megabytes, es una tabla
entera detrás de un formulario). Si las dos dan poco, el tiempo está en la aplicación misma, y se mide ahí.

**Rúbrica.** Una respuesta correcta tiene que:
- restar el tiempo del servidor del de la pantalla;
- proponer las dos mediciones de esta fase.

[← Volver al ejercicio](../14-la-base-no-estaba-lenta.md#-ejercicio-24--está-lenta-la-base)

### Ejercicio 25

**Enunciado (resumen):** "ir a la página".

**Solución de referencia.** Un diseño defendible guarda **marcadores de página**: una tabla con la clave del primer protocolo de
cada página múltiplo de 100 (la 1, la 101, la 201…), recalculada cada noche. "Ir a la página 37" busca el marcador de la página 1
y avanza 36 páginas con `OFFSET` corto (720 filas), o con *keyset* desde el marcador. El costo: los marcadores quedan viejos
durante el día (una página puede mostrar uno o dos protocolos corridos), y hay que recalcularlos. Otro diseño defendible es no
ofrecer "ir a la página" y ofrecer "ir a la fecha", que es lo que un paciente o un médico busca de verdad, y es *keyset* directo.

**Rúbrica.** Una respuesta correcta tiene que:
- evitar el `OFFSET` largo;
- decir lo que cuesta mantener el diseño, o por qué la pregunta del usuario es otra.

[← Volver al ejercicio](../14-la-base-no-estaba-lenta.md#-ejercicio-25--ir-a-la-página)

### Ejercicio 26

**Enunciado (resumen):** `Protocolos` sobre `legacy`.

**Solución de referencia.**

```text
staging.protocolos   viajes=7 filas=1327682 bytes=17337089 ms=2061.5
legacy.Protocolos    viajes=7 filas=1327682 bytes=17337033 ms=1857.4
```

Iguales: los mismos viajes, las mismas filas, y 56 bytes de diferencia en el contenido de las 60 filas. Los índices de la copia
no cambian nada, porque las claves salen de la clave primaria, que las dos tablas tienen. El frontal de 2011 no necesitaba ningún
índice para ser lento.

**Rúbrica.** Una respuesta correcta tiene que:
- correr el formulario sobre la tabla de la caja;
- explicar por qué los índices no influyen.

[← Volver al ejercicio](../14-la-base-no-estaba-lenta.md#-ejercicio-26--protocolos-sobre-legacy)
