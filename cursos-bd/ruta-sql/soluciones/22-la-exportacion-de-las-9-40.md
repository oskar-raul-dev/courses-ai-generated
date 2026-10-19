# ✅ Soluciones — Fase 22: La exportación de las 9:40

> **Curso:** Ruta SQL · Solucionario de la [Fase 22](../22-la-exportacion-de-las-9-40.md)
> **Ejercicios:** 28 · **Perfil:** el 26/12/2025 de la caja M (6.651 resultados, 601 protocolos) · **Motor:** Postgres 18.6 con `wal_level = logical` de [`a02`](../a02-compose-de-la-ruta.md)
> **Fecha de verificación ejecutada:** 14/10/2026

> ⚠️ **Intenta el ejercicio antes de leer su solución.** Leída antes, solo te enseña a reconocerla.

Las soluciones suponen `22-la-exportacion-de-las-9-40/01_setup.sql` corrido, y `02_marca_de_agua.py`, `03_colas.py` y `06_outbox_versiones.py` corridos al menos una vez (crean `staging.f22_result_source`, la cola, el outbox y los descartes). Los ejercicios 1 a 16 están ejecutados con `07_ejercicios.sql`, y su salida se registró en la sesión de verificación del 14/10/2026. Los de 17 a 28 llevan rúbrica, que también está en la lección.

---

## 🟢 Fácil (1–6)

### Ejercicio 1

```text
 resultados | protocolos 
------------+------------
       6651 |        601
```

**Lectura:** la verdad del día son 6.651 resultados en 601 protocolos, unos 11 por protocolo. Es la lista contra la que se cuentan las pérdidas.

### Ejercicio 2

```text
 marca_si_todo_estuviera_confirmado 
 2025-12-26 17:59:00
```

**Lectura:** el último registro del día es a las 17:59, el cierre del horario de atención. Si todo estuviera confirmado en orden, la marca terminaría ahí, y no habría nada que perder.

### Ejercicio 3

```text
 span_medio_min | span_max_min
            0.0 |            0
```

**Lectura:** cada protocolo registra todos sus resultados en el mismo instante. No hay un protocolo que abarque horas; la pérdida no viene del ancho de un protocolo, sino del orden de confirmación y de los empates entre protocolos.

### Ejercicio 4

```text
 instantes | instantes_con_varios_protocolos | protocolos_con_empate 
-----------+---------------------------------+-----------------------
       357 |                             162 |                   406
```

**Lectura:** 162 de los 357 instantes del día los comparten dos o más protocolos, y 406 de los 601 protocolos tienen un empate. Con `recorded_at > marca`, el protocolo que confirma después de otro con la misma fecha queda detrás de la marca: es la segunda causa de pérdida que la lección separa (§5.3).

### Ejercicio 5

```text
 pct_en_el_minuto 
            100.0
```

**Lectura:** la caja registra al minuto. Con milisegundos, los empates serían menos frecuentes, pero no imposibles; la regla de la marca no puede depender de la granularidad.

### Ejercicio 6

```text
 filas_en_la_ventana_de_1h 
                       708
```

**Lectura:** con la marca a la mitad del día, una ventana de una hora relee 708 filas en cada ciclo del exportador. Es el costo de la corrección: un exportador con ventana lee más, y descarta lo ya enviado.

---

## 🟡 Intermedio (7–16)

### Ejercicio 7

```text
 minimo_min_del_dia | maximo_min_del_dia 
--------------------+--------------------
               14.4 |               28.8
```

**Lectura:** con el día reproducido en 30 s de reloj, una transacción lenta de 0,3 a 0,6 s equivale a 14 a 29 minutos del día. La ventana de una hora los cubre con margen; una de 15 minutos no.

### Ejercicio 8

```text
INSERT 0 20000
 wal_retenido 
 1280 kB
```

**Lectura:** el slot retiene el WAL desde su último punto leído. Con 20.000 filas escritas y ningún consumidor, retiene 1.280 kB. Las tablas temporales no sirven para este ejercicio: no se escriben en el WAL lógico, y el slot no las vería (la primera versión del ejercicio lo comprobó).

### Ejercicio 9

```text
BEGIN / INSERT 0 1 / ROLLBACK
BEGIN / INSERT 0 1 / COMMIT
 lineas_de_datos 
               1
```

**Lectura:** de las dos transacciones, solo la confirmada aparece en el flujo. La decodificación ve la confirmación, no el intento.

### Ejercicio 10

```text
 table staging.ej10: UPDATE: id[integer]:1 a[text]:'x' b[text]:'z'
```

**Lectura:** el `UPDATE` cambió solo `b`, y el cambio trae la fila completa (`a` también). El consumidor recibe el estado nuevo, no la diferencia.

### Ejercicio 11

```text
INSERT 0 1
INSERT 0 0
 filas_tras_dos_envios 
                     1
```

**Lectura:** el segundo envío del mismo identificador no entra, y no da error: `ON CONFLICT DO NOTHING` lo descarta. La idempotencia la hace cumplir la clave, no el código.

### Ejercicio 12

```text
 version | payload 
---------+---------
       2 | nueva
```

**Lectura:** la corrección vieja (versión 1) llegó después de la nueva (versión 2) y no la pisó, porque el upsert compara la versión (`WHERE excluded.version > version`). Sin ese `WHERE`, la vieja habría ganado.

### Ejercicio 13

```text
 en_descartes |              motivo              
--------------+----------------------------------
            5 | formato inválido tras 3 intentos
```

**Lectura:** los cinco mensajes veneno salieron de la cola al tercer intento, con su motivo. La cola quedó sin pendientes, y los 6.651 resultados se procesaron.

### Ejercicio 14

```text
 pendientes_en_outbox 
                    0
```

**Lectura:** después del relevador, no queda ningún mensaje sin enviar. Los 28 reenvíos de la corrida no dejaron pendientes: cada uno terminó marcado.

### Ejercicio 15

```text
 done_by | procesados 
---------+------------
 c0      |       1663
 c1      |       1668
 c2      |       1667
 c3      |       1653
```

**Lectura:** `SKIP LOCKED` reparte el trabajo sin coordinación: cada consumidor toma la próxima fila libre, y el reparto queda parejo (de 1.653 a 1.668).

### Ejercicio 16

```text
 identificadores_repetidos 
                         0
```

**Lectura:** con el procesamiento transaccional (el destino y la marca de hecho en la misma transacción), no hay repetidos. Los duplicados aparecen solo cuando el envío está fuera de la transacción (la corrida B de `03_colas.py`: 140 o 142, según la corrida).

---

## 🟠 Difícil (17–22) — rúbrica

### Ejercicio 17

*Notificación sin sondeo.*

**Rúbrica (sobre 4 puntos):** 1 punto por el mecanismo (`LISTEN` y `NOTIFY`); 1 por reconocer que la notificación no se persiste y que hace falta reconciliar con una marca; 1 por una reconciliación que use el outbox o la marca; 1 por medir o declarar la latencia.

### Ejercicio 18

*El slot que se olvidó.*

**Rúbrica (sobre 3 puntos):** 1 punto por calcular el crecimiento a partir del ejercicio 8; 1 por una consulta de alerta sobre `pg_replication_slots`; 1 por la decisión (reanudar, o borrar el slot con su costo para el consumidor).

### Ejercicio 19

*La cola particionada.*

**Rúbrica (sobre 4 puntos):** 1 punto por la partición por rango de fecha de encolado; 1 por el índice parcial de pendientes por partición; 1 por la consulta de toma que recorre las particiones en orden; 1 por medir el costo antes y después.

### Ejercicio 20

*El outbox sin relevador.*

**Rúbrica (sobre 3 puntos):** 1 punto por el cálculo con la tasa de cambios; 1 por el efecto en la tabla (crece sin purga, y el índice de no enviados se hace grande); 1 por una alerta sobre la antigüedad del mensaje más viejo sin enviar.

### Ejercicio 21

*Orden por clave.*

**Rúbrica (sobre 4 puntos):** 1 punto por decir que `SKIP LOCKED` no garantiza orden; 1 por una clave de partición (el protocolo) que se toma con un bloqueo asesor (`pg_advisory_xact_lock`) o por hash; 1 por medir que el orden se respeta; 1 por el costo en paralelismo.

### Ejercicio 22

*Lo que Oracle ofrece.*

**Rúbrica (sobre 3 puntos):** 1 punto por describir la cola integrada con la base; 1 por la comparación en prosa, sin números de Oracle (D20); 1 por decir cuándo lo elegirías.

---

## 🔴 Muy difícil (23–28) — rúbrica

### Ejercicio 23

*pgoutput con cliente.*

**Rúbrica (sobre 4 puntos):** 1 punto por el plugin `pgoutput` y su publicación; 1 por el cliente (con `psycopg` o `pg_recvlogical`); 1 por describir el formato binario frente al texto; 1 por el acuse de recibo del consumidor (`confirmed_flush_lsn`).

### Ejercicio 24

*La demora máxima medida.*

**Rúbrica (sobre 4 puntos):** 1 punto por medir la diferencia entre el instante de registro y el de visibilidad (con un sello de confirmación o con el CDC); 1 por un percentil alto más un margen; 1 por el costo de la ventana en filas releídas (el ejercicio 6 da una cifra); 1 por la revisión periódica.

### Ejercicio 25

*La tabla de exportados.*

**Rúbrica (sobre 3 puntos):** 1 punto por limitar la deduplicación a la ventana (lo anterior a la ventana ya no vuelve a leerse); 1 por la purga por rango de fecha; 1 por una prueba de que la purga no reabre duplicados.

### Ejercicio 26

*La marca con zona horaria.*

**Rúbrica (sobre 4 puntos):** 1 punto por normalizar a UTC en la captura; 1 por el problema de la hora repetida o saltada; 1 por una marca en UTC con ventana; 1 por una prueba con la fecha de cambio de horario.

### Ejercicio 27

*El formato del mensaje.*

**Rúbrica (sobre 3 puntos):** 1 punto por los segmentos del mensaje; 1 por declarar qué se simplifica y qué se omite; 1 por la clave de idempotencia del mensaje (el identificador único).

### Ejercicio 28

*El veredicto de la base.*

**Rúbrica (sobre 4 puntos):** 1 punto por la decisión; 1 por el volumen y la latencia medidos (6.651 mensajes en 5,5 s, con cuatro consumidores); 1 por el número de consumidores y sus caídas (140 duplicados sin clave, 0 con clave); 1 por la medida que cambiaría la decisión.
