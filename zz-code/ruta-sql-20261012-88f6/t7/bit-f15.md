### M-27 · F15 · La muestra tomada dos veces, en cuatro niveles y dos motores
**Tipo:** publicada · **Motor:** PostgreSQL `pgvector/pgvector@sha256:2358fcba361e…` y MySQL `mysql@sha256:e2bde46db656…` ·
**Perfil:** M · **Fecha:** 14/10/2026
**Hipótesis:** *"El* write skew *de la muestra pasa en `REPEATABLE READ` de Postgres, y en `SERIALIZABLE` una de las dos
transacciones falla con un error de serialización (`40001`). En MySQL, `REPEATABLE READ` también lo deja pasar, y
`SERIALIZABLE` lo frena con un* deadlock *(1213), no con un error de serialización."*
**Resultado:** Postgres: dos tomas en `READ COMMITTED` y `REPEATABLE READ`, `40001` en el `COMMIT` de b en `SERIALIZABLE`.
MySQL: dos tomas en `REPEATABLE READ`, `1213` en el `INSERT` de b en `SERIALIZABLE`, y también en `REPEATABLE READ` con la lectura
`FOR UPDATE` (*gap lock*), que en Postgres no bloquea. La matriz de seis anomalías, igual en dos corridas; la actualización
perdida pasa en el `REPEATABLE READ` de MySQL (23,00 en vez de 13,00) y no en el de Postgres (`40001`). Con cuatro técnicos en
hilos, `SERIALIZABLE` sin bucle pierde 284–301 tomas de 400; con bucle, 0, a 2,5–2,9 reintentos por toma (5,8 con dieciséis);
con `UNIQUE` en `READ COMMITTED`, 0 perdidas y 0 duplicadas. · **Apuesta:** ganada
**Reproducir:** `uv run lab race -f 15-aislamiento-comparado/write_skew.race --isolation serializable` (y `write_skew_mysql.race`),
`uv run python 15-aislamiento-comparado/matrix.py` y `uv run python 15-aislamiento-comparado/technicians.py` desde `src/`

### M-28 · F15 · La muestra y la caja en el `SERIALIZABLE` de Oracle
**Tipo:** apuesta sin resolver · **Motor:** Oracle Free · **Perfil:** M
**Hipótesis:** en Oracle, `SERIALIZABLE` deja pasar el *write skew* de la muestra (los dos técnicos confirman) y la actualización
perdida termina en `ORA-08177` para la segunda caja. · **Resuélvela:** los pasos de `write_skew.race` y `lost_update.race` a mano en
dos sesiones de `sqlplus` con `SET TRANSACTION ISOLATION LEVEL SERIALIZABLE`, como pide la
[Fase 15](15-aislamiento-comparado.md)
