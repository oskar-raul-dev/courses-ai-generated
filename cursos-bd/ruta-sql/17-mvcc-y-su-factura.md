# ♻️ Fase 17 — MVCC y su factura: versiones, VACUUM y la lectura que no termina

> **Curso:** Ruta SQL · Fase 17 de 27 · Bloque III — La concurrencia · **10 h**
> **Motores:** PostgreSQL `pgvector/pgvector@sha256:2358fcba361e…` · contraste MySQL `mysql@sha256:e2bde46db656…` · Oracle, solo con la documentación (🪞🔒)
> **Entorno de ejecución:** SQL y Python
> **Perfil de volumen:** M, con el modelo de `uv run lab load --profile m --model`
> **El dolor de Alameda:** la exportación nocturna al portal, que lee desde las 22:00 hasta las 9:40 mientras el laboratorio sigue cargando y corrigiendo (historia §3, 2013 y 2020)
> **Depende de:** Fase 16 · **Habilita:** Fase 18
> **Apéndices de apoyo:** a03, a04, a07, a08
> **Fecha de verificación ejecutada:** 14/10/2026
> **Objetivo:** medir lo que deja atrás cada `UPDATE` en un motor con versiones, lo que una lectura larga impide limpiar, y
> decidir qué carga conviene sacar del motor o cambiar de forma.

---

## 🧭 1. Dónde estamos

La [Fase 15](15-aislamiento-comparado.md) usó las fotos de `REPEATABLE READ` como una garantía: lo que la transacción leyó no
cambia. La [Fase 16](16-el-folio-sin-huecos.md) actualizó una fila diez mil veces. Esta fase muestra **de dónde salen las fotos**
y quién las paga. En Postgres, cada `UPDATE` deja la versión anterior en la tabla; alguien tiene que borrarla después, y no puede
mientras exista una transacción que todavía la pueda ver.

La exportación de Alameda es esa transacción. Empieza a las 22:00 y termina a las 9:40 del día siguiente: casi doce horas con una
foto abierta, la última parte en plena mañana de carga.

---

## 🎯 2. Objetivos de esta fase

1. Leer las versiones de una fila (`xmin`, `xmax`) y medir las muertas con `pgstattuple`.
2. Ver qué hacen `VACUUM`, autovacuum y HOT, y qué les impide hacerlo una transacción larga.
3. Medir el *bloat* antes y después, y comprobar que `VACUUM` no achica una tabla.
4. Comparar con MySQL, que guarda las versiones viejas fuera de la tabla, y con lo que la documentación de Oracle dice del *undo*.
5. Reconocer el *wraparound* como advertencia, sin provocarlo.
6. Decidir cuándo MVCC cobra más de lo que da, y qué carga conviene cambiar de forma.

---

## 🚫 3. Qué NO entra todavía

- **Los bloqueos que sí esperan: filas, DDL y `pg_locks`** → [Fase 18](18-bloqueos-deadlocks-y-ddl.md).
- **Sacar la exportación de la base: CDC y decodificación lógica** → [Fase 22](22-la-exportacion-de-las-9-40.md).
- **El tuning de autovacuum por tabla** más allá de leerlo: operación, fuera del curso.
- **El *wraparound* como laboratorio**: provocarlo exige dos mil millones de transacciones.

---

## 🏚️ 4. El dolor, en la caja

Desde 2013, una exportación nocturna vuelca los protocolos del día hacia el portal de resultados. En la pandemia empezaba a las
22:00 y terminaba a las 9:40. A esa hora el laboratorio llevaba casi tres horas cargando resultados, y la caja dice cuánto se carga
en la media hora más cargada de todas:

```sql
-- postgres
SELECT date_trunc('hour', "FechaCarga") + (extract(minute FROM "FechaCarga")::int / 30) * interval '30 min' AS media_hora,
       count(*)
FROM legacy."ResultadoItem" GROUP BY 1 ORDER BY 2 DESC LIMIT 1;
```

```text
     media_hora      | count
---------------------+-------
 2024-01-07 17:00:00 |   620
```

En M, que es la décima parte de Alameda, 620 resultados en media hora. Mientras la exportación lee, cada uno de esos resultados
que el laboratorio corrige deja una versión vieja que la exportación todavía puede necesitar. Y el laboratorio no solo corrige:
`ParaLlamar` se marca fila por fila toda la tarde, y desde la [Fase 16](16-el-folio-sin-huecos.md) sabemos que el contador de
comprobantes se actualiza una vez por cada uno.

---

## 🧩 5. Versiones de fila, y quién las limpia

### 5.1 Una fila, varias versiones

En Postgres, un `UPDATE` no cambia la fila: escribe una **versión nueva** y marca la vieja como reemplazada. Cada versión lleva
dos números de transacción: `xmin`, la que la creó, y `xmax`, la que la reemplazó o la borró. Una transacción ve una versión si
`xmin` ya estaba confirmada cuando tomó su foto y `xmax` no. Así funciona la foto de `REPEATABLE READ`: no se copia nada, se
eligen versiones.

La versión reemplazada queda en la página, ocupando lugar, hasta que **nadie la pueda ver**. Entonces es una tupla muerta, y
`VACUUM` la borra y deja su lugar libre para versiones nuevas. "Nadie la pueda ver" tiene un número: el **horizonte de `xmin`**, la
transacción más vieja que sigue abierta en toda la base. Lo que murió después de ese horizonte no se puede borrar.

### 5.2 La fila contador, con y sin la exportación

`mvcc.py counter` toma una tabla de seis filas, una por punto de venta, y actualiza la del punto de venta 1 diez mil veces, una
por comprobante, como la [Fase 16](16-el-folio-sin-huecos.md). Dos veces: con la exportación cerrada, y con una conexión que abrió
una transacción `REPEATABLE READ`, leyó, y sigue ahí. `pgstattuple` cuenta lo que hay en cada página:

> 📐 **Medición: 10.000 actualizaciones de una fila** · `pgvector/pgvector@sha256:2358fcba361e…` · verificado el 14/10/2026
>
> | Momento | Exportación cerrada | Exportación abierta |
> |---|---|---|
> | antes | 1 página · 0 muertas | 1 página · 0 muertas |
> | después de 10.000 `UPDATE` | **1 página** · 99 muertas | **45 páginas** · 10.000 muertas |
> | `VACUUM`, con la exportación todavía abierta | — | 45 páginas · 10.000 muertas |
> | `VACUUM`, con la exportación cerrada | 1 página · 0 muertas | **45 páginas** · 0 muertas · 99,5 % libre |

Sin la exportación, la tabla **no crece**: diez mil versiones pasaron por una sola página. Con la exportación abierta, la misma
fila ocupa 45 páginas. Y `VACUUM VERBOSE` dice exactamente por qué no limpia:

```text
tuples: 0 removed, 10006 remain, 10000 are dead but not yet removable
removable cutoff: 210897, which was 10001 XIDs old when operation ended
```

El *removable cutoff* es el horizonte de `xmin`: diez mil transacciones atrás, la de la exportación. Cuando la exportación termina,
`VACUUM` borra las diez mil, y **la tabla sigue en 45 páginas**, vacías en un 99,5 %. `VACUUM` deja el espacio libre para
reutilizarlo; no lo devuelve, salvo las páginas vacías que queden al final del archivo.

### 5.3 HOT y la limpieza de página

¿Cómo pasaron diez mil versiones por una sola página sin la exportación? Las diez mil actualizaciones fueron **HOT** (*heap-only
tuple*, la [Fase 11](11-indices-y-lo-que-cuestan.md) lo midió): ninguna cambió una columna indexada y la versión nueva entró en la
misma página, así que no hizo falta tocar el índice. Y cuando la página se llena, la siguiente lectura o escritura que pasa por
ella la **poda** sola: borra las versiones muertas que ya nadie ve, sin esperar a `VACUUM`. Por eso quedaban 99 muertas y no diez
mil.

Con la exportación abierta, nada se puede podar. La página se llena, la versión siguiente va a otra página, y de las diez mil
actualizaciones, 44 dejaron de ser HOT. **La lectura larga no solo impide `VACUUM`: impide la limpieza que hace que casi nunca
haga falta.**

Dos cosas que parecen ayudar y no ayudan. Un **índice sobre la columna que cambia** apaga HOT: con un índice sobre
`last_number`, ninguna de las diez mil actualizaciones fue HOT, y aun sin la exportación la tabla terminó en 35 páginas y el índice
en 30, porque cada versión nueva necesita su entrada. Y **`fillfactor = 50`** no cambia nada con la exportación abierta: 45 páginas,
igual que con 100. El `fillfactor` reserva lugar en cada página para versiones futuras, pero diez mil versiones que no se pueden
borrar no entran en ningún margen.

### 5.4 Qué retiene el horizonte, y qué no

No toda transacción abierta retiene. Una exportación en **`READ COMMITTED`**, ociosa después de su lectura (`idle in
transaction`), no tiene foto: cada sentencia toma la suya y la suelta al terminar. `pg_stat_activity` la muestra sin
`backend_xmin`, y el contador con diez mil actualizaciones se queda en una página. La que retiene es la de `REPEATABLE READ` o
`SERIALIZABLE`, que conserva la foto de su primera sentencia hasta el final, o una sentencia en curso, de cualquier nivel, que dura
horas.

Lo que sí retiene, retiene **para toda la base**. Una exportación que solo leyó `alameda.result` infla igual el contador, que no
toca: 45 páginas. El horizonte no es de una tabla; es la transacción más vieja, y todo lo que muere después se queda. Y no tiene
techo: con la exportación abierta, tres tandas de diez mil actualizaciones con un `VACUUM` entre cada una dejan el contador en 45,
89 y 133 páginas. `VACUUM` no frena nada mientras el horizonte no se mueva.

La defensa del lado del servidor es `idle_in_transaction_session_timeout`: con 5 segundos en la sesión de la exportación, el
servidor la corta (`terminating connection due to idle-in-transaction timeout`) y el contador vuelve a quedarse en una página.
Corta la transacción ociosa, no la que está leyendo: para esa, `statement_timeout`, o sacarla del primario.

### 5.5 Autovacuum, y cuándo llega

Autovacuum limpia una tabla cuando sus tuplas muertas pasan el 20 % de las filas más 50 (`autovacuum_vacuum_scale_factor` 0,2 y
`autovacuum_vacuum_threshold` 50, los del servidor del curso). Para la tabla del contador, seis filas: llega enseguida, y no sirve
de nada mientras la exportación esté abierta, porque hace lo mismo que el `VACUUM` de la tabla de arriba. Para `alameda.result`,
12,1 millones de filas: hacen falta 2,4 millones de versiones muertas para que llegue. Los dos extremos fallan por razones
distintas.

### 5.6 El *wraparound*, como advertencia

Los números de transacción de Postgres son de 32 bits. Para que una versión vieja no parezca del futuro cuando el contador da la
vuelta, `VACUUM` **congela** las filas viejas: las marca como visibles para todos. Si una tabla pasa demasiadas transacciones sin
congelarse, Postgres fuerza un `VACUUM` agresivo (`autovacuum_freeze_max_age`, 200 millones); y si aun así se acerca al límite de
unos dos mil millones, deja de aceptar escrituras hasta que se haga. En el laboratorio, `age(datfrozenxid)` da 265.340: la
base tiene unas trescientas mil transacciones encima, el 0,13 % del umbral. Una transacción abierta durante días es lo que impide
congelar, igual que impide limpiar. Esto no se provoca en el curso; se mira (`SELECT datname, age(datfrozenxid) FROM pg_database`).

> 🩻 **Esto sí funciona igual** en los tres motores: una lectura no bloquea a una escritura ni al revés, porque la lectura lee una
> versión anterior. Lo que cambia es **dónde** vive esa versión, y quién la limpia.

---

## 🔀 6. El contraste: dónde otro motor cambia la decisión

**InnoDB guarda la versión vieja en el *undo*, no en la tabla.** La fila de la tabla siempre es la última; para leer una foto
anterior, InnoDB la reconstruye aplicando los registros de *undo* hacia atrás. Un proceso de fondo, el *purge*, borra los registros
que ya nadie necesita, y la **history list length** cuenta los que todavía no pudo borrar. `mysql_history.py` repite la fila
contador, con una lectura abierta con `START TRANSACTION WITH CONSISTENT SNAPSHOT`:

| | Lectura cerrada | Lectura abierta |
|---|---|---|
| tabla, después de 10.000 `UPDATE` | 112 KB | **112 KB** |
| *history list length*, después | 64–376 | **10.001–10.003** |
| la lectura ve | — | 247.581, el valor de antes de los 10.000 |
| *history list length*, 5 s después de cerrar la lectura | 65–376 | 0–1 |

La tabla no crece nunca. Crece la deuda del *purge*, que está fuera de la tabla, y se paga en cada lectura de la foto vieja:
reconstruir la versión de hace diez mil cambios recorre diez mil registros de *undo*. Medido con la misma fila: después de 10.000
cambios, la lectura abierta tarda 5,4 ms en leerla y una lectura nueva 0,17 ms; después de 100.000, 56 ms contra 0,29. Crece con
los cambios, en línea recta. Los archivos de *undo* no cambiaron de tamaño
(416 MB, ya crecidos por la carga de la caja). **La decisión que cambia:** en MySQL, una lectura larga no infla la tabla; vuelve
lenta la lectura misma y a todas las que necesiten versiones viejas de las filas más cambiadas.

**Oracle también usa *undo*, y tiene un límite que los otros dos no tienen.** Si los registros de *undo* que una lectura necesita
ya se reutilizaron, la lectura falla con `ORA-01555: snapshot too old: rollback segment number string with name "string" too small`.
La documentación lo explica así: los registros que una lectura consistente necesita fueron sobrescritos por otras escrituras, y
la acción es subir `UNDO_RETENTION`. En Postgres la lectura larga nunca falla: paga la tabla. En Oracle, la tabla no paga y la
lectura puede fallar.

> 🪞🔒 **Apuesta sin resolver: Oracle.** Hipótesis: con un tablespace de *undo* chico y `UNDO_RETENTION` bajo, la exportación
> abierta en `READ ONLY` mientras otra sesión actualiza diez mil veces el contador falla con `ORA-01555` al releer la fila del
> contador, y con `UNDO_RETENTION` suficiente no falla. Condiciones: las tablas de `mvcc.py counter` creadas en el esquema de la
> aplicación, `SET TRANSACTION READ ONLY` en una sesión de `sqlplus` ([`a03`](a03-clis-de-los-motores.md#️-oracle--sqlplus)), y
> el bucle de `UPDATE` en otra. El mecanismo, en la documentación oficial de `ORA-01555` y de la gestión automática del *undo*. 📝
> No publicamos números de Oracle; el porqué está en [`a09`](a09-licencias-publicacion-y-riesgo.md).

---

## 🪞 7. Tu instinto dice… y la apuesta

**Tu instinto dice** que una lectura larga, en un motor con versiones, infla la tabla en proporción a lo que se escribe mientras
dura, y que en la tabla de resultados del laboratorio eso es mucho.

> 🪞 **Apuesta antes de ejecutar** (escrita el 30/09/2026, al diseñar esta fase). *"Una lectura abierta durante 30 minutos mientras
> se corrigen resultados deja la tabla al menos al doble de su tamaño, y VACUUM no la achica."*
> **Resultado:** **perdida en la primera mitad, ganada en la segunda.** `mvcc.py results` abre la exportación y corrige, de a uno,
> los 620 resultados de la media hora más cargada de la caja: los resultados de ese día pasan de 39 a 43 páginas (**1,10 veces**),
> y una copia de `alameda.result` entera, de 87.808 a 87.808 (las versiones nuevas entraron en el 0,4 % libre de las páginas).
> `VACUUM`, después, borra las 620 muertas y no devuelve ninguna página: 43 siguen siendo 43.

Media hora de correcciones, aun en el pico, son unos cientos de versiones en una tabla de millones. Lo que duplica una tabla no es
cuánto se escribe en total, sino **cuántas veces se reescribe cada fila**: el contador de la sección 5.2 tiene seis filas y se
reescribió diez mil veces, y pasó de 1 a 45 páginas. La segunda mitad de la apuesta sí se cumple siempre: `VACUUM` no achica nada,
ni la tabla del día ni el contador.

---

## 💥 8. El punto de rotura

**El *bloat* medido, y lo que `VACUUM` no puede borrar.** La rotura de Postgres no es un error: es una tabla que crece sin que
nadie la toque más que antes, y un `VACUUM` que dice que no puede hacer nada:

```text
tuples: 0 removed, 10006 remain, 10000 are dead but not yet removable
removable cutoff: 210897, which was 10001 XIDs old when operation ended
```

Para encontrar al culpable, la transacción que retiene el horizonte:

```sql
SELECT pid, state, xact_start, age(backend_xmin) AS xmin_age, left(query, 40)
FROM pg_stat_activity WHERE backend_xmin IS NOT NULL ORDER BY age(backend_xmin) DESC LIMIT 3;
```

La de arriba es la exportación. El otro lado de la rotura, el de Oracle, es el mensaje `ORA-01555`, que se publica como mensaje
y como apuesta sin resolver (sección 6).

---

## ⚰️ 9. Autopsia: `ParaLlamar`, marcada fila por fila toda la tarde

**1. La decisión.** *"A cada paciente que hay que llamar se le pone `Llamado` en verdadero cuando se lo llama."* Desde 1997 es una
casilla; en la pandemia apareció `LlamadoDos`, para la segunda llamada.

**2. Por qué era razonable.** Es la forma más directa de una lista de tareas: la tarea es una fila, y hacerla es marcarla. En
SQL Server con bloqueos, una casilla que cambia no cuesta más que eso. La lista de pendientes es `WHERE NOT Llamado`.

**3. Qué pasó después.** En Postgres, cada marca reescribe la fila entera (nombre, teléfono, protocolo) para cambiar un booleano.
`mvcc.py para_llamar` marca las 3.141 llamadas de la pandemia y las 954 segundas, de a una, con la lista de pendientes en un índice
parcial (`WHERE NOT called`), con la exportación cerrada y abierta:

| | Exportación cerrada | Exportación abierta |
|---|---|---|
| WAL por llamada, marcando con `UPDATE` | 282 bytes | 308 bytes |
| versiones muertas en la tabla | 36 | **4.095** |
| la lista de pendientes, primera lectura | 40 bloques · 3.141 visitas a la tabla | 40 bloques · 3.141 visitas a la tabla |
| la lista de pendientes, segunda lectura | **6 bloques · 0 visitas** | **40 bloques · 3.141 visitas** |

La lista se apoya en un índice parcial: cuando una fila se marca, su entrada vieja queda en el índice, apuntando a una versión
muerta. Sin la exportación, la primera lectura que la encuentra la marca como muerta en el índice y la siguiente ni la visita. Con
la exportación abierta, esa versión todavía es visible para alguien, y **cada lectura de la lista, toda la tarde, visita las 3.141
filas ya llamadas** para descubrir que no tiene que mostrarlas. Cuatro personas llamando en turnos leen la lista después de cada
llamada.

**4. Cuánto cuesta salir.** Anotar la llamada en vez de marcar la fila: una tabla `call_made (id, attempt, called_at)` donde cada
llamada es un `INSERT`. 120 bytes de WAL por llamada contra 282 o 308; cero versiones muertas, porque una fila insertada no
reemplaza a nadie. La lista de pendientes pasa a ser "los que no tienen llamada", un *anti-join*, y gana algo que la casilla
nunca tuvo: quién llamó y cuándo. **Y pierde algo:** sobre las 3.141 filas de 2020, el *anti-join* lee 656 bloques (con índices
por fecha y por llamada) contra los 6 o 40 del índice parcial, porque ya no hay un índice que contenga solo a los pendientes. Se
recupera leyendo la lista del día, que es la que la recepcionista usa, no la del año.

**5. Qué lo habría cambiado.** Preguntar cuál es la unidad de escritura. La de la lista es el evento "se llamó", no el estado de la
fila, y un evento se agrega, no se reescribe.

**Antes y después, con números:** 308 bytes de WAL y una versión muerta por llamada, y 40 bloques por cada lectura de la lista
con la exportación abierta, contra 120 bytes y ninguna versión muerta, con una lista que lee 656 bloques si se pide el año entero.
La factura de MVCC se cambia por una consulta más cara, que se acota.

---

## 📖 10. Traducción

| Concepto | Access / T-SQL | Postgres | MySQL | Oracle |
|---|---|---|---|---|
| dónde vive la versión vieja | `tempdb`, con RCSI o `SNAPSHOT` | en la tabla | en el *undo* | en el *undo* |
| quién la limpia | la limpieza del almacén de versiones | `VACUUM`, autovacuum y la poda de página | el *purge* | el *undo* se reutiliza |
| cuánto falta limpiar | `sys.dm_tran_version_store_space_usage` | `n_dead_tup`, `pgstattuple` | *history list length* | `V$UNDOSTAT` |
| la lectura que retiene | `sys.dm_tran_active_snapshot_database_transactions` | `backend_xmin` en `pg_stat_activity` | `INNODB_TRX`, la transacción más vieja | `V$TRANSACTION` |
| si la versión ya no está | la lectura falla (error 3966) | no pasa: la tabla crece | no pasa: el *undo* crece | `ORA-01555` |
| devolver el espacio | `ALTER INDEX … REBUILD` | `VACUUM FULL`, `pg_repack` | `OPTIMIZE TABLE` | `ALTER TABLE … SHRINK SPACE` |

Hacia la NoSQL Lite: WiredTiger, el motor de MongoDB, también guarda versiones para sus *snapshots*, en memoria y en su historia;
una transacción no puede durar más de 60 segundos por defecto (`transactionLifetimeLimitSeconds`), que es la decisión opuesta a
la de Postgres: corta la lectura larga en vez de pagarla. El diccionario completo está en [`a07`](a07-diccionario-y-glosario.md).

---

## ⚖️ 11. Veredicto honesto: cuándo MVCC cobra más de lo que da

**Cuando una lectura dura horas en la misma base que escribe.** La exportación de doce horas retiene el horizonte de toda la base,
no solo de las tablas que lee: el contador de la caja infla aunque la exportación no lo toque. En Postgres, una lectura de esa
duración va en una réplica (con `hot_standby_feedback` apagado, la réplica cancela la lectura en lugar de retener el primario) o
sale del motor: la [Fase 22](22-la-exportacion-de-las-9-40.md) la reemplaza por un flujo de cambios.

**Cuando una fila se reescribe miles de veces.** Contadores, colas con estado, marcas de "visto" y de "llamado": en un motor con
versiones cada cambio es una fila nueva. Si el dato es un evento, se inserta (la autopsia); si es un contador, la tabla se queda
chica y se poda sola mientras no haya lecturas largas, y conviene vigilar que no las haya.

**Cuándo no preocuparse.** La tabla de resultados, con sus correcciones del día, crece 1,10 veces en el peor medio día de la caja
con la exportación abierta, y nada en la tabla entera. MVCC es la razón por la que la exportación puede leer doce horas sin
bloquear a nadie, y eso vale más que cuatro páginas.

**Cuándo devolver el espacio.** Casi nunca: una tabla inflada que vuelve a crecer hasta su tamaño inflado reutiliza lo que
`VACUUM` liberó. Si la causa se fue y el espacio no se va a volver a usar, `VACUUM FULL` reescribe la tabla (el contador pasa de 45
páginas a 1) con un bloqueo exclusivo durante toda la reescritura; `pg_repack` hace lo mismo con un bloqueo breve al final, y es
una extensión aparte.

**Lo que no se mide aquí:** las réplicas y `hot_standby_feedback`, el costo de reconstruir versiones en el *undo* de MySQL con
lecturas de verdad largas, y `VACUUM FULL` en una tabla grande, que reescribe la tabla con un bloqueo exclusivo
([Fase 18](18-bloqueos-deadlocks-y-ddl.md)).

Las cinco preguntas, para lo que enseñó esta fase:

- **Frontera transaccional:** una transacción abierta es un costo para toda la base, no para sus tablas.
- **Consultas conocidas:** la exportación es una consulta conocida y larga: es la que conviene sacar.
- **Unidad de lectura:** la lista de pendientes lee el índice y visita la tabla por cada entrada que no puede descartar.
- **Saltos:** cada versión vieja es un salto más para la lectura que la necesita (en el *undo* de MySQL, literal).
- **Exactitud o parecido:** la exportación necesita una foto exacta; la lista de "a quién llamar" podría leer lo último
  confirmado, y no retener nada.

---

## ⚠️ 12. Errores comunes y diagnóstico

- **`N are dead but not yet removable` en `VACUUM VERBOSE`.** 🩺 Una transacción retiene el horizonte: `pg_stat_activity`
  ordenada por `age(backend_xmin)`; también puede ser una réplica con `hot_standby_feedback` o un *slot* de replicación.
- **Una tabla de pocas filas que ocupa cientos de páginas.** 🩺 Una fila muy actualizada y una lectura larga; `pgstattuple` da
  el porcentaje libre.
- **`VACUUM` terminó y la tabla no se achicó.** 🩺 Es lo esperado: el espacio queda para reutilizar. Solo `VACUUM FULL` o
  `pg_repack` lo devuelven.
- **`ORA-01555: snapshot too old`.** 🩺 La lectura necesitaba un *undo* que ya se reutilizó: subir `UNDO_RETENTION`, achicar la
  lectura, o no actualizar las filas que la lectura recorre mientras dura.
- **La *history list length* de MySQL sube y no baja.** 🩺 Una transacción abierta, aunque esté ociosa:
  `information_schema.INNODB_TRX` ordenada por `trx_started`.
- **`WARNING: database "…" must be vacuumed within … transactions`.** 🩺 El *wraparound* se acerca: `age(datfrozenxid)`, y la
  transacción o el *slot* que impide congelar.

---

## 📋 13. Checklist de validación

```text
[ ] mvcc.py counter: 1 página sin la exportación, 45 con ella, y 45 después del VACUUM
[ ] VACUUM VERBOSE con la exportación abierta: 10000 are dead but not yet removable
[ ] mvcc.py results: la tabla del día crece 1,10 veces y la copia de result no crece
[ ] mvcc.py para_llamar: la segunda lectura de la lista, 6 bloques sin la exportación y 40 con ella
[ ] mysql_history.py: la tabla en 112 KB y la history list length en 10.003 con la lectura abierta
[ ] age(datfrozenxid) leída, y comparada con autovacuum_freeze_max_age
```

---

## 🧪 14. Ejercicios (24)

Los scripts se corren desde `src/` con `uv run python 17-mvcc-y-su-factura/<script>`.

## 🟢 Fácil — ver las versiones (1–7)

### 🟢 Ejercicio 1 — `xmin` y `xmax`

Crea una tabla de una fila, actualízala tres veces en tres transacciones y muestra `xmin`, `xmax` y `ctid` de la fila después de
cada una.

**Objetivo:** la fila cambia de `ctid` y de `xmin` en cada actualización.

[Solución](soluciones/17-mvcc-y-su-factura.md#ejercicio-1)

### 🟢 Ejercicio 2 — Lo que ve otra sesión

Con `lab race`, una sesión en `REPEATABLE READ` lee la fila, otra la actualiza y confirma, y la primera la vuelve a leer con
`xmin`.

**Objetivo:** las dos versiones, y qué `xmin` ve cada sesión.

[Solución](soluciones/17-mvcc-y-su-factura.md#ejercicio-2)

### 🟢 Ejercicio 3 — El contador

Corre `mvcc.py counter`.

**Objetivo:** la tabla de la sección 5.2.

[Solución](soluciones/17-mvcc-y-su-factura.md#ejercicio-3)

### 🟢 Ejercicio 4 — El culpable

Con la exportación abierta, encuentra su conexión en `pg_stat_activity` y la edad de su `backend_xmin`.

**Objetivo:** el `pid`, el estado y la edad.

[Solución](soluciones/17-mvcc-y-su-factura.md#ejercicio-4)

### 🟢 Ejercicio 5 — La apuesta

Corre `mvcc.py results`.

**Objetivo:** el crecimiento de la tabla del día y de la copia, y las páginas después del `VACUUM`.

[Solución](soluciones/17-mvcc-y-su-factura.md#ejercicio-5)

### 🟢 Ejercicio 6 — La *history list length*

Corre `mysql_history.py`.

**Objetivo:** el tamaño de la tabla y la *history list length*, con la lectura cerrada y abierta.

[Solución](soluciones/17-mvcc-y-su-factura.md#ejercicio-6)

### 🟢 Ejercicio 7 — La edad de la base

Consulta `age(datfrozenxid)` de cada base y `age(relfrozenxid)` de las tablas más viejas del modelo.

**Objetivo:** cuánto falta para `autovacuum_freeze_max_age`.

[Solución](soluciones/17-mvcc-y-su-factura.md#ejercicio-7)

## 🟡 Intermedio — limpiar (8–14)

### 🟡 Ejercicio 8 — `VACUUM FULL`

Después de `mvcc.py counter` con la exportación abierta y ya cerrada, corre `VACUUM FULL` sobre el contador.

**Objetivo:** las páginas antes y después, y el bloqueo que toma.

[Solución](soluciones/17-mvcc-y-su-factura.md#ejercicio-8)

### 🟡 Ejercicio 9 — El HOT que se rompe

Agrega un índice sobre `last_number` al contador y repite las 10.000 actualizaciones sin la exportación.

**Objetivo:** cuántas fueron HOT, las páginas de la tabla y del índice.

[Solución](soluciones/17-mvcc-y-su-factura.md#ejercicio-9)

### 🟡 Ejercicio 10 — `fillfactor`

Repite el contador sin índice con `fillfactor = 50` y con la exportación abierta.

**Objetivo:** si cambia algo, y por qué.

[Solución](soluciones/17-mvcc-y-su-factura.md#ejercicio-10)

### 🟡 Ejercicio 11 — Autovacuum

Con la exportación cerrada, actualiza 3.000 filas de una copia de los resultados del día y espera a que autovacuum pase.

**Objetivo:** el umbral calculado, y `last_autovacuum` y `n_dead_tup` en `pg_stat_user_tables`.

[Solución](soluciones/17-mvcc-y-su-factura.md#ejercicio-11)

### 🟡 Ejercicio 12 — La exportación en `READ COMMITTED`

Repite `mvcc.py counter` con la exportación en `READ COMMITTED`, ociosa después de su lectura.

**Objetivo:** si retiene el horizonte, y por qué.

[Solución](soluciones/17-mvcc-y-su-factura.md#ejercicio-12)

### 🟡 Ejercicio 13 — `idle in transaction`

Con la exportación ociosa dentro de su transacción, pon `idle_in_transaction_session_timeout` en 5 segundos para su sesión y espera.

**Objetivo:** qué le pasa a la exportación, y al horizonte.

[Solución](soluciones/17-mvcc-y-su-factura.md#ejercicio-13)

### 🟡 Ejercicio 14 — La autopsia

Corre `mvcc.py para_llamar`.

**Objetivo:** el WAL por llamada de cada forma, y los bloques de la segunda lectura de la lista.

[Solución](soluciones/17-mvcc-y-su-factura.md#ejercicio-14)

## 🟠 Difícil — medir la factura (15–20)

### 🟠 Ejercicio 15 — Una tabla que no deja de crecer

Corre el contador en tres tandas de 10.000 con la exportación abierta todo el tiempo y un `VACUUM` entre tandas.

**Objetivo:** las páginas después de cada tanda, y si `VACUUM` frena el crecimiento.

[Solución](soluciones/17-mvcc-y-su-factura.md#ejercicio-15)

### 🟠 Ejercicio 16 — La foto vieja en MySQL

Mide cuánto tarda la lectura abierta en leer la fila del contador después de 10.000 y de 100.000 actualizaciones.

**Objetivo:** el tiempo de esa lectura contra el de una lectura nueva, y por qué cambia.

[Solución](soluciones/17-mvcc-y-su-factura.md#ejercicio-16)

### 🟠 Ejercicio 17 — La lista de pendientes sin índice

Repite la autopsia sin el índice parcial.

**Objetivo:** los bloques de la lista con y sin la exportación, y si el índice ayudaba o no.

[Solución](soluciones/17-mvcc-y-su-factura.md#ejercicio-17)

### 🟠 Ejercicio 18 — La lista con el diseño nuevo

Escribe la lista de pendientes sobre `staging.call_made` y mídela con la exportación abierta.

**Objetivo:** la consulta, su plan y sus bloques.

[Solución](soluciones/17-mvcc-y-su-factura.md#ejercicio-18)

### 🟠 Ejercicio 19 — El horizonte no es de una tabla

Con la exportación leyendo solo `alameda.result`, mide el contador de la Fase 16.

**Objetivo:** que el contador infla igual, aunque la exportación nunca lo lea.

[Solución](soluciones/17-mvcc-y-su-factura.md#ejercicio-19)

### 🟠 Ejercicio 20 — Una réplica para la exportación

Explica qué pasaría con la exportación en una réplica, con `hot_standby_feedback` encendido y apagado.

**Objetivo:** dónde se paga en cada caso, con la documentación.

[Solución](soluciones/17-mvcc-y-su-factura.md#ejercicio-20)

## 🔴 Muy difícil — decidir (21–24)

### 🔴 Ejercicio 21 — Oracle

Resuelve en tu máquina la apuesta 🪞🔒 de la sección 6.

**Objetivo:** el resultado explicado con la documentación de `ORA-01555`, sin publicar ningún número.

[Solución](soluciones/17-mvcc-y-su-factura.md#ejercicio-21)

### 🔴 Ejercicio 22 — Qué sale del motor

De las cargas de Alameda que esta fase midió, decide cuál conviene sacar del motor, cuál cambiar de forma y cuál dejar como está.

**Objetivo:** la decisión de cada una, con su medición.

[Solución](soluciones/17-mvcc-y-su-factura.md#ejercicio-22)

### 🔴 Ejercicio 23 — La alarma

Diseña la alarma que habría avisado de la exportación de doce horas antes de que doliera.

**Objetivo:** la consulta, el umbral y por qué ese.

[Solución](soluciones/17-mvcc-y-su-factura.md#ejercicio-23)

### 🔴 Ejercicio 24 — Postgres o MySQL para el contador

Con las mediciones de las secciones 5.2 y 6, argumenta en qué motor la fila contador de la Fase 16 sufre menos una exportación
larga, y qué paga cada uno.

**Objetivo:** el argumento, con los números y lo que no se midió.

[Solución](soluciones/17-mvcc-y-su-factura.md#ejercicio-24)

---

## 📚 15. Referencias

**Documentación oficial**

- **Control de concurrencia en Postgres 18 (MVCC)** — https://www.postgresql.org/docs/18/mvcc-intro.html
- **`VACUUM` rutinario, autovacuum y el *wraparound*** — https://www.postgresql.org/docs/18/routine-vacuuming.html
- **`pgstattuple`** — https://www.postgresql.org/docs/18/pgstattuple.html
- **Columnas de sistema: `xmin`, `xmax`, `ctid`** — https://www.postgresql.org/docs/18/ddl-system-columns.html
- **Multiversión en InnoDB y el *purge*** — https://dev.mysql.com/doc/refman/9.7/en/innodb-multi-versioning.html y
  https://dev.mysql.com/doc/refman/9.7/en/innodb-purge-configuration.html
- **`ORA-01555`** — https://docs.oracle.com/en/error-help/db/ora-01555/

**Papers y libros**

- **Darl Kuhn y Thomas Kyte, *Expert Oracle Database Architecture*, 4.ª ed., Apress, 2021** — el capítulo de *redo* y *undo*,
  con `ORA-01555` explicado desde adentro. Cubre Oracle 21c, no 23ai.
- **Martin Kleppmann y Chris Riccomini, *Designing Data-Intensive Applications*, 2.ª ed., O'Reilly, 2026** — el capítulo de
  transacciones, con el *snapshot isolation* implementado con versiones.

**Orden de lectura sugerido:** la página de MVCC de Postgres antes de la sección 5; la de `VACUUM` antes de la 5.5; Kyte antes de la
sección 6.

> ⚠️ Las URL y sus contenidos cambian. Se consultaron el 14/10/2026.

---

## 🏁 16. Resultado de la fase

```text
LA FILA CONTADOR · 10.000 actualizaciones
  exportación cerrada     1 página · 99 muertas · HOT y poda de página
  exportación abierta     45 páginas · 10.000 muertas que VACUUM no puede borrar
  exportación cerrada     VACUUM borra todo y la tabla sigue en 45 páginas (99,5 % libre)
LA APUESTA · la media hora más cargada (620 correcciones)
  la tabla del día        1,10 veces · la tabla entera, igual · VACUUM no devuelve ninguna página
PARALLAMAR
  WAL por llamada         282–308 bytes con UPDATE · 120 con INSERT
  la lista, 2.ª lectura   6 bloques sin la exportación · 40 bloques y 3.141 visitas con ella
MYSQL
  la tabla                112 KB siempre · history list length 10.003 con la lectura abierta
```

> **La señal de que quedó bien:** *"Puedo decir quién retiene el horizonte de mi base, cuánto cuesta en páginas o en undo, y qué
> filas de mi diseño se reescriben tanto que conviene convertirlas en eventos."*

> 🏷️ **No cierres la fase sin el tag.** Con el checklist en verde y `git status` limpio:
>
> ```bash
> git tag -a fase-17-mvcc-y-su-factura -m "F17 cerrada: la fila contador con y sin la exportación, la apuesta medida en la media hora más cargada, ParaLlamar como eventos y el undo de MySQL"
> ```
>
> Commits de la fase con prefijo `f17:`, los de ejercicio `f17 ej24: …`.
