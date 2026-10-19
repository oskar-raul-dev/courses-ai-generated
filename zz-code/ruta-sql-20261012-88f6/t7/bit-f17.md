### M-31 · F17 · La lectura abierta y la media hora más cargada de la caja
**Tipo:** publicada · **Motor:** PostgreSQL `pgvector/pgvector@sha256:2358fcba361e…` y MySQL `mysql@sha256:e2bde46db656…` ·
**Perfil:** M · **Fecha:** 14/10/2026
**Hipótesis:** *"Una lectura abierta durante 30 minutos mientras se corrigen resultados deja la tabla al menos al doble de su
tamaño, y VACUUM no la achica."*
**Resultado:** con la exportación abierta y los 620 resultados de la media hora más cargada corregidos de a uno, la tabla del día
pasa de 39 a 43 páginas (1,10 veces) y una copia de `alameda.result` no crece (87.808); `VACUUM` no devuelve ninguna página. Donde
sí: la fila contador con 10.000 actualizaciones, 1 página sin la exportación y 45 con ella (10.000 muertas que `VACUUM` no puede
borrar, 45 páginas después de cerrarla), y 44 páginas más por cada tanda de 10.000 mientras siga abierta. `ParaLlamar`: 282–308
bytes de WAL por llamada con `UPDATE` contra 120 con `INSERT`, y la lista de pendientes en 40 bloques y 3.141 visitas por lectura
con la exportación abierta, contra 6 bloques sin ella. MySQL: la tabla en 112 KB, la *history list length* en 10.003, y la lectura
abierta 5,4 ms contra 0,17 de una nueva (56 contra 0,29 con 100.000 cambios). · **Apuesta:** perdida (el tamaño), ganada (`VACUUM`)
**Reproducir:** `uv run python 17-mvcc-y-su-factura/mvcc.py counter|results|para_llamar` y
`uv run python 17-mvcc-y-su-factura/mysql_history.py` desde `src/`

### M-32 · F17 · La lectura larga contra el undo de Oracle
**Tipo:** apuesta sin resolver · **Motor:** Oracle Free · **Perfil:** M
**Hipótesis:** con un tablespace de *undo* chico y `UNDO_RETENTION` bajo, una lectura `READ ONLY` abierta mientras otra sesión
actualiza diez mil veces el contador falla con `ORA-01555` al releer la fila, y con `UNDO_RETENTION` suficiente no falla. ·
**Resuélvela:** dos sesiones de `sqlplus`, como pide la [Fase 17](17-mvcc-y-su-factura.md)
