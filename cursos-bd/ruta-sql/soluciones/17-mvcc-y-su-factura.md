# ✅ Soluciones — Fase 17: MVCC y su factura

> **Curso:** Ruta SQL · Solucionario de la [Fase 17](../17-mvcc-y-su-factura.md)
> **Ejercicios:** 24 · **Perfil:** M · **Motores:** Postgres y MySQL de
> [`a02`](../a02-compose-de-la-ruta.md#-las-versiones-del-curso)
> **Fecha de verificación ejecutada:** 14/10/2026

> ⚠️ **Intenta el ejercicio antes de leer su solución.** Leída antes, solo te enseña a reconocerla.

Todas las soluciones suponen el modelo de `uv run lab load --profile m --model` y la extensión `pgstattuple`
(`CREATE EXTENSION IF NOT EXISTS pgstattuple`, que viene en la imagen). Las funciones `size`, `vacuum` y `export_open` son las de
`17-mvcc-y-su-factura/mvcc.py`; "la exportación" es una conexión con una transacción `REPEATABLE READ` abierta. Los números de
transacción (`xmin`) cambian en cada corrida; las páginas y las tuplas, no.

---

## 🟢 Fácil (1–7)

### Ejercicio 1

**Enunciado (resumen):** `xmin` y `xmax`.

**Solución.**

```sql
SELECT ctid, xmin, xmax, last_number FROM staging.mvcc_counter WHERE point_of_sale = 1;
-- y UPDATE … SET last_number = last_number + 1, tres veces, cada una en su transacción
```

```text
('(0,1)', '266087', '0', 247581)
('(0,7)', '266088', '0', 247582)
('(0,8)', '266089', '0', 247583)
('(0,9)', '266090', '0', 247584)
```

Cada actualización deja la fila en otra posición de la página (`ctid` 1, 7, 8, 9: las posiciones 2 a 6 son de las otras cinco
filas) y con el `xmin` de la transacción que la escribió. `xmax` es 0 en la versión vigente; la versión anterior tiene como `xmax`
el `xmin` de la siguiente, pero no se ve con un `SELECT`.

**Rúbrica.** Una respuesta correcta tiene que:
- notar que el `ctid` cambia: la fila no se modificó en su lugar.

[← Volver al ejercicio](../17-mvcc-y-su-factura.md#-ejercicio-1--xmin-y-xmax)

### Ejercicio 2

**Enunciado (resumen):** lo que ve otra sesión.

**Solución.**

```text
 a2  1 fila  (266093, 247581)
 b1  UPDATE 1
 a3  1 fila  (266093, 247581)
 a4  COMMIT
 b2  1 fila  (266094, 247582)
```

a sigue viendo la versión con `xmin` 266.093 después de que b escribió y confirmó la 266.094: las dos versiones existen a la vez
en la tabla, y cada sesión elige la que le corresponde por su foto.

**Rúbrica.** Una respuesta correcta tiene que:
- mostrar dos `xmin` distintos para la misma fila.

[← Volver al ejercicio](../17-mvcc-y-su-factura.md#-ejercicio-2--lo-que-ve-otra-sesión)

### Ejercicio 3

**Enunciado (resumen):** el contador.

**Solución.** La tabla de la sección 5.2: sin la exportación, 1 página y 99 muertas después de 10.000 `UPDATE`, todas HOT; con la
exportación, 45 páginas y 10.000 muertas, `10000 are dead but not yet removable` en `VACUUM VERBOSE`, y 45 páginas con el 99,5 %
libre después del `VACUUM` con la exportación cerrada.

**Rúbrica.** Una respuesta correcta tiene que:
- citar la línea de `VACUUM VERBOSE` que dice por qué no limpia.

[← Volver al ejercicio](../17-mvcc-y-su-factura.md#-ejercicio-3--el-contador)

### Ejercicio 4

**Enunciado (resumen):** el culpable.

**Solución.**

```sql
SELECT pid, state, xact_start, age(backend_xmin) AS xmin_age, left(query, 40)
FROM pg_stat_activity WHERE backend_xmin IS NOT NULL ORDER BY age(backend_xmin) DESC LIMIT 3;
```

La primera fila es la exportación: `state` `idle in transaction`, la `query` es su última lectura, y `xmin_age` crece con cada
transacción que corre después (con el contador, unas diez mil).

**Rúbrica.** Una respuesta correcta tiene que:
- ordenar por la edad de `backend_xmin`, no por `xact_start`.

[← Volver al ejercicio](../17-mvcc-y-su-factura.md#-ejercicio-4--el-culpable)

### Ejercicio 5

**Enunciado (resumen):** la apuesta.

**Solución.**

```text
la media hora más cargada: 2024-01-07 17:00:00 con 620 resultados
staging.result_day:  39 → 43 páginas · 620 muertas · crecimiento 1,1026 veces · después del VACUUM, 43
staging.result_copy: 87.808 → 87.808 páginas · 620 muertas · crecimiento 1,0000 · después del VACUUM, 87.808
```

La apuesta se pierde en el tamaño (1,10 y 1,00 veces, no 2) y se gana en que `VACUUM` no devuelve nada.

**Rúbrica.** Una respuesta correcta tiene que:
- calcular el crecimiento como cociente de páginas.

[← Volver al ejercicio](../17-mvcc-y-su-factura.md#-ejercicio-5--la-apuesta)

### Ejercicio 6

**Enunciado (resumen):** la *history list length*.

**Solución.** La tabla de la sección 6: 112 KB siempre; *history list length* entre 64 y 376 sin la lectura (lo que el *purge* no alcanzó todavía) y 10.001–10.003 con ella; la lectura
ve 247.581; cinco segundos después de cerrarla, 0.

**Rúbrica.** Una respuesta correcta tiene que:
- explicar por qué la tabla no crece.

[← Volver al ejercicio](../17-mvcc-y-su-factura.md#-ejercicio-6--la-history-list-length)

### Ejercicio 7

**Enunciado (resumen):** la edad de la base.

**Solución.**

```text
  datname  |  age   | freeze_max_age
-----------+--------+----------------
 alameda   | 265340 | 200000000
  relname  |  age
-----------+--------
 lab_order | 261435
 result    | 261433
```

El 0,13 % de `autovacuum_freeze_max_age`. El *wraparound* está a unos dos mil millones; esta base está a casi doscientos millones
de que autovacuum siquiera empiece a preocuparse.

**Rúbrica.** Una respuesta correcta tiene que:
- comparar con `autovacuum_freeze_max_age` y no con el límite de 32 bits.

[← Volver al ejercicio](../17-mvcc-y-su-factura.md#-ejercicio-7--la-edad-de-la-base)

---

## 🟡 Intermedio (8–14)

### Ejercicio 8

**Enunciado (resumen):** `VACUUM FULL`.

**Solución.**

```text
antes de VACUUM FULL       45 páginas ·  6 vivas · 0 muertas · 99,5 % libre
después de VACUUM FULL      1 página  ·  6 vivas · 0 muertas · 97,1 % libre
```

`VACUUM FULL` reescribe la tabla en un archivo nuevo, con un bloqueo `ACCESS EXCLUSIVE` que impide incluso leerla mientras dura.
En seis filas es instantáneo; en `alameda.result`, son minutos sin que nadie pueda leer resultados
([Fase 18](../18-bloqueos-deadlocks-y-ddl.md)).

**Rúbrica.** Una respuesta correcta tiene que:
- nombrar el bloqueo.

[← Volver al ejercicio](../17-mvcc-y-su-factura.md#-ejercicio-8--vacuum-full)

### Ejercicio 9

**Enunciado (resumen):** el HOT que se rompe.

**Solución.**

```text
con índice: 10000 actualizaciones, 0 HOT · tabla 35 páginas · 6 vivas · 111 muertas · 84,4 % libre
índice 30 páginas
```

Con un índice sobre la columna que cambia, ninguna actualización puede ser HOT: cada versión nueva necesita su entrada en el índice.
Sin la exportación, la tabla crece igual a 35 páginas y el índice a 30: cada versión nueva lleva su entrada en el índice, y lo que
una versión no HOT deja atrás (su entrada en el índice, su puntero en la página) no se recupera del todo hasta que pasa `VACUUM`.
Con HOT, en cambio, la poda de página sola alcanzaba para quedarse en una página.

**Rúbrica.** Una respuesta correcta tiene que:
- dar 0 HOT y el crecimiento sin exportación.

[← Volver al ejercicio](../17-mvcc-y-su-factura.md#-ejercicio-9--el-hot-que-se-rompe)

### Ejercicio 10

**Enunciado (resumen):** `fillfactor`.

**Solución.** Con `fillfactor = 50` y la exportación abierta: 45 páginas, 10.000 muertas, exactamente como con el valor por
defecto. El `fillfactor` deja lugar libre en cada página **al insertar**, para que las actualizaciones futuras quepan en la misma
página; con seis filas, el lugar reservado es de unas pocas versiones, y las diez mil que no se pueden borrar ocupan lo mismo.

**Rúbrica.** Una respuesta correcta tiene que:
- explicar que el problema es la cantidad de versiones retenidas, no dónde caen.

[← Volver al ejercicio](../17-mvcc-y-su-factura.md#-ejercicio-10--fillfactor)

### Ejercicio 11

**Enunciado (resumen):** autovacuum.

**Solución.** Sobre una copia de los resultados del 7 de enero de 2024 (5.294 filas), el umbral es 0,2 × 5.294 + 50 = 1.109
tuplas muertas. Con 3.000 actualizaciones:

```text
a los 20 s: n_dead_tup 0, last_autovacuum 2026-10-14 15:57:01
```

Autovacuum pasó en los primeros 20 segundos (su ciclo de revisión, `autovacuum_naptime`, es de un minuto por base, y la medición
cayó cerca del siguiente) y dejó cero muertas.

**Rúbrica.** Una respuesta correcta tiene que:
- calcular el umbral antes de medir.

[← Volver al ejercicio](../17-mvcc-y-su-factura.md#-ejercicio-11--autovacuum)

### Ejercicio 12

**Enunciado (resumen):** la exportación en `READ COMMITTED`.

**Solución.**

```text
backend_xmin de la exportación en READ COMMITTED, ociosa: (None, 'idle in transaction')
contador                             1 página · 6 vivas · 99 muertas
```

No retiene: en `READ COMMITTED` cada sentencia toma su foto y la suelta al terminar, y una transacción que solo leyó no tiene
número propio. Mientras su `SELECT` corre, sí retiene; al terminar, no.

**Rúbrica.** Una respuesta correcta tiene que:
- mostrar `backend_xmin` nulo.

[← Volver al ejercicio](../17-mvcc-y-su-factura.md#-ejercicio-12--la-exportación-en-read-committed)

### Ejercicio 13

**Enunciado (resumen):** `idle in transaction`.

**Solución.**

```text
la exportación: IdleInTransactionSessionTimeout terminating connection due to idle-in-transaction timeout
contador después                     1 página · 6 vivas · 99 muertas
```

El servidor corta la conexión de la exportación a los 5 segundos de ociosidad dentro de la transacción, y el horizonte se libera:
el contador no infla. El límite no corta una lectura que está corriendo, solo una transacción que espera sin hacer nada.

**Rúbrica.** Una respuesta correcta tiene que:
- citar el mensaje y su efecto sobre el contador.

[← Volver al ejercicio](../17-mvcc-y-su-factura.md#-ejercicio-13--idle-in-transaction)

### Ejercicio 14

**Enunciado (resumen):** la autopsia.

**Solución.** La tabla de la sección 9: 282 bytes de WAL por llamada con `UPDATE` sin la exportación y 308 con ella, contra 120 con
`INSERT`; la segunda lectura de la lista, 6 bloques sin la exportación y 40 con ella, con 3.141 visitas a la tabla.

**Rúbrica.** Una respuesta correcta tiene que:
- explicar por qué la segunda lectura sin la exportación es más barata que la primera.

[← Volver al ejercicio](../17-mvcc-y-su-factura.md#-ejercicio-14--la-autopsia)

---

## 🟠 Difícil (15–20)

### Ejercicio 15

**Enunciado (resumen):** una tabla que no deja de crecer.

**Solución de referencia.**

```text
tanda 1    45 páginas · 10000 muertas
tanda 2    89 páginas · 20000 muertas
tanda 3   133 páginas · 30000 muertas
```

44 páginas por tanda, sin techo. `VACUUM` entre tandas no borra nada, porque el horizonte no se movió.

**Rúbrica.**
- **Aprobado:** las tres medidas.
- **Bien:** el crecimiento lineal explicado.
- **Excelente:** cuántas páginas tendría el contador después de las doce horas de la exportación, con la cantidad de comprobantes
  de un día de la caja.

[← Volver al ejercicio](../17-mvcc-y-su-factura.md#-ejercicio-15--una-tabla-que-no-deja-de-crecer)

### Ejercicio 16

**Enunciado (resumen):** la foto vieja en MySQL.

**Solución de referencia.**

```text
  10000 cambios · la lectura abierta ve 247581 en 5.38 ms
  10000 cambios · una lectura nueva  ve 257581 en 0.17 ms
 100000 cambios · la lectura abierta ve 247581 en 56.22 ms
 100000 cambios · una lectura nueva  ve 347581 en 0.29 ms
```

Para dar la versión de su foto, InnoDB parte de la fila actual y aplica los registros de *undo* hacia atrás, uno por cambio. Diez
veces más cambios, diez veces más tiempo. La lectura nueva lee la fila tal como está.

**Rúbrica.**
- **Aprobado:** los cuatro tiempos.
- **Bien:** la reconstrucción por el *undo* explicada.
- **Excelente:** qué le pasa a una exportación que recorre una tabla entera de filas muy cambiadas.

[← Volver al ejercicio](../17-mvcc-y-su-factura.md#-ejercicio-16--la-foto-vieja-en-mysql)

### Ejercicio 17

**Enunciado (resumen):** la lista de pendientes sin índice.

**Solución de referencia.** Sin el índice parcial, la lista recorre la tabla entera: 960 bloques en las dos lecturas, con la
exportación cerrada y abierta. El índice ayudaba aun con la exportación (40 bloques contra 960); lo que la exportación le quita es
la limpieza que lo deja en 6.

**Rúbrica.**
- **Aprobado:** los 960 bloques.
- **Bien:** separa lo que aporta el índice de lo que quita la exportación.
- **Excelente:** nota que sin índice la exportación no cambia nada, porque recorrer la tabla ya visita todas las versiones.

[← Volver al ejercicio](../17-mvcc-y-su-factura.md#-ejercicio-17--la-lista-de-pendientes-sin-índice)

### Ejercicio 18

**Enunciado (resumen):** la lista con el diseño nuevo.

**Solución de referencia.**

```sql
SELECT count(*) FROM staging.para_llamar p
WHERE p.called_on >= '2020-03-01' AND p.called_on < '2021-01-01'
  AND NOT EXISTS (SELECT 1 FROM staging.call_made c WHERE c.id = p.id AND c.attempt = 1);
```

Sin índices, 1.074 bloques (recorre las dos tablas). Con un índice sobre `para_llamar (called_on)` y otro sobre
`call_made (id, attempt)`, 656 bloques: un *hash anti join* entre las 3.141 filas del período y las 3.141 llamadas. Más que los 6 o
40 del índice parcial, y la exportación abierta no lo cambia, porque ninguna de las dos tablas tiene versiones muertas. Acotada al
día, la lista lee unas pocas páginas.

**Rúbrica.**
- **Aprobado:** la consulta y su plan.
- **Bien:** los bloques con y sin índices.
- **Excelente:** el precio honesto del diseño nuevo, y cómo se acota.

[← Volver al ejercicio](../17-mvcc-y-su-factura.md#-ejercicio-18--la-lista-con-el-diseño-nuevo)

### Ejercicio 19

**Enunciado (resumen):** el horizonte no es de una tabla.

**Solución de referencia.** Con la exportación leyendo solo `alameda.result`, el contador termina en 45 páginas y 10.000
muertas, igual que en la sección 5.2. Postgres no sabe qué tablas va a leer una transacción `REPEATABLE READ` en el futuro: su
foto vale para toda la base, y por eso retiene las versiones de toda la base.

**Rúbrica.**
- **Aprobado:** las 45 páginas.
- **Bien:** por qué la foto es de la base y no de las tablas leídas.
- **Excelente:** la consecuencia para una base que comparte la exportación con la caja.

[← Volver al ejercicio](../17-mvcc-y-su-factura.md#-ejercicio-19--el-horizonte-no-es-de-una-tabla)

### Ejercicio 20

**Enunciado (resumen):** una réplica para la exportación.

**Solución de referencia.** En una réplica física, la exportación lee versiones que el primario puede borrar. Con
`hot_standby_feedback` **encendido**, la réplica le informa al primario su horizonte y el primario no borra esas versiones: la
tabla del primario infla igual que en esta fase, y la exportación no se interrumpe. Con el *feedback* **apagado**, el primario
limpia, y cuando la réplica tiene que aplicar esa limpieza mientras la exportación necesita las versiones borradas, espera hasta
`max_standby_streaming_delay` y después cancela la lectura. Se paga en el primario o en la exportación; la réplica elige dónde, no
evita el pago. (La documentación de Postgres lo trata en "Hot Standby", en los conflictos de consulta.)

**Rúbrica.**
- **Aprobado:** los dos casos.
- **Bien:** dónde se paga en cada uno.
- **Excelente:** por qué la [Fase 22](../22-la-exportacion-de-las-9-40.md) saca la exportación del motor en lugar de moverla a una réplica.

[← Volver al ejercicio](../17-mvcc-y-su-factura.md#-ejercicio-20--una-réplica-para-la-exportación)

---

## 🔴 Muy difícil (21–24)

### Ejercicio 21

**Enunciado (resumen):** Oracle.

**Solución de referencia.** No se publica resultado (la regla está en [`a09`](../a09-licencias-publicacion-y-riesgo.md)).

**Rúbrica.**
- **Aprobado:** las dos corridas, con `UNDO_RETENTION` bajo y suficiente, y el mensaje literal si aparece.
- **Bien:** el resultado explicado con la documentación de `ORA-01555` ("rollback records needed by a reader for consistent read
  are overwritten by other writers").
- **Excelente:** la comparación con Postgres: dónde paga cada motor una lectura larga (la tabla o la lectura).

[← Volver al ejercicio](../17-mvcc-y-su-factura.md#-ejercicio-21--oracle)

### Ejercicio 22

**Enunciado (resumen):** qué sale del motor.

**Solución de referencia.**

| Carga | Decisión | La medición |
|---|---|---|
| la exportación de doce horas | sale del motor ([Fase 22](../22-la-exportacion-de-las-9-40.md)) o, mientras tanto, a una réplica | retiene el horizonte de toda la base: el contador, 45 páginas por cada 10.000 comprobantes |
| el contador de comprobantes | se queda | sin lecturas largas, 1 página con 10.000 actualizaciones |
| `ParaLlamar` | cambia de forma: eventos | 120 bytes contra 282–308 por llamada, ninguna versión muerta |
| las correcciones de resultados | se quedan como están | 1,10 veces en la peor media hora, con la exportación abierta |

**Rúbrica.**
- **Aprobado:** una decisión por carga.
- **Bien:** cada una con su número.
- **Excelente:** lo que cuesta cada cambio (el *anti-join* de la lista, la réplica).

[← Volver al ejercicio](../17-mvcc-y-su-factura.md#-ejercicio-22--qué-sale-del-motor)

### Ejercicio 23

**Enunciado (resumen):** la alarma.

**Solución de referencia.**

```sql
SELECT pid, application_name, state, now() - xact_start AS duration, age(backend_xmin) AS xmin_age
FROM pg_stat_activity
WHERE backend_xmin IS NOT NULL AND (now() - xact_start > interval '15 minutes' OR age(backend_xmin) > 1000000)
ORDER BY age(backend_xmin) DESC;
```

Dos umbrales, porque miden cosas distintas: el tiempo, para la exportación de doce horas aunque la base esté quieta; y la edad del
horizonte en transacciones, porque es lo que se acumula como versiones retenidas. Un millón de transacciones, con la caja, es del
orden de cien veces el contador de la sección 5.2. Y una tercera fuente: `pg_replication_slots` con su `xmin`, porque un *slot*
abandonado retiene igual que una transacción.

**Rúbrica.**
- **Aprobado:** la consulta con un umbral.
- **Bien:** los dos umbrales y por qué.
- **Excelente:** los *slots* y `hot_standby_feedback`, que retienen sin aparecer como transacción.

[← Volver al ejercicio](../17-mvcc-y-su-factura.md#-ejercicio-23--la-alarma)

### Ejercicio 24

**Enunciado (resumen):** Postgres o MySQL para el contador.

**Solución de referencia.** Con la exportación abierta, Postgres paga en la tabla (de 1 a 45 páginas por cada diez mil
comprobantes, que `VACUUM` no devuelve) y la exportación lee rápido. MySQL paga en la lectura (la *history list length* sube a
10.003, la tabla queda en 112 KB, y la lectura abierta tarda 5,4 ms donde una nueva tarda 0,17) y lo que sufre es la exportación
y el *purge*. Para el contador, que es lo que la caja necesita rápido, MySQL sufre menos; para la exportación, Postgres. Lo que no
se midió: la exportación recorriendo millones de filas cambiadas en MySQL (cada una con su cadena de *undo*), y el costo de una
tabla inflada en un `shared_buffers` real.

**Rúbrica.**
- **Aprobado:** dónde paga cada motor.
- **Bien:** con los números.
- **Excelente:** que la decisión depende de quién tiene que ser rápido, y lo que no se midió.

[← Volver al ejercicio](../17-mvcc-y-su-factura.md#-ejercicio-24--postgres-o-mysql-para-el-contador)
