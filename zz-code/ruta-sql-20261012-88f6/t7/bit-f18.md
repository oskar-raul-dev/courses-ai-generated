### M-33 · F18 · La cola detrás de un ALTER de dos milisegundos
**Tipo:** publicada · **Motor:** PostgreSQL `pgvector/pgvector@sha256:2358fcba361e…` · **Perfil:** M · **Fecha:** 14/10/2026
**Hipótesis:** *"Un `ALTER TABLE` que espera detrás de una lectura larga bloquea a todas las sesiones nuevas, aunque él mismo tarde
milisegundos."*
**Resultado:** con la exportación abierta 3 s sobre `staging.result_ddl` (12,1 M filas) y `ADD COLUMN … DEFAULT false` (2 ms de
trabajo), las 30 lecturas que llegaron en esos 3 s quedaron en la cola: 21 esperaron más de 1 s, la peor 3,06 s. Con un valor volátil
(reescribe, 11,2 s), 30 de 30 y la peor 13,02 s; con `lock_timeout` de 1 s, reintento y el valor constante, 0 de 30 y la peor 0,98 s.
`pg_locks` muestra la cola: la lectura nueva bloqueada por el `ALTER`, no por la exportación. En MySQL, la misma cola con el
*metadata lock*, aun con `ALGORITHM=INSTANT`, y `lock_wait_timeout` de un año. · **Apuesta:** ganada
**Reproducir:** `uv run python 18-bloqueos-deadlocks-y-ddl/ten_am.py` y `uv run lab race -f 18-bloqueos-deadlocks-y-ddl/ddl_queue.race`
desde `src/`, después de `01_setup.sql`

### M-34 · F18 · La cola del DDL y el deadlock en Oracle
**Tipo:** apuesta sin resolver · **Motor:** Oracle Free · **Perfil:** M
**Hipótesis:** en Oracle la cola de `ddl_queue.race` no se forma: la lectura abierta no retiene bloqueos de tabla y el `ALTER`
termina enseguida; con un `UPDATE` sin confirmar, el `ALTER` falla en el acto con `ORA-00054` (`DDL_LOCK_TIMEOUT` 0); el *deadlock*
termina en `ORA-00060` para una de las dos, que conserva el resto de su transacción. · **Resuélvela:** tres sesiones de `sqlplus`,
como pide la [Fase 18](18-bloqueos-deadlocks-y-ddl.md)
