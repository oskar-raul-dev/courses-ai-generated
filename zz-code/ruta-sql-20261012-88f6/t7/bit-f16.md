### M-29 · F16 · La fila contador con tres cajas y diez mil comprobantes
**Tipo:** publicada · **Motor:** PostgreSQL `pgvector/pgvector@sha256:2358fcba361e…` · **Perfil:** M · **Fecha:** 14/10/2026
**Hipótesis:** *"Con la fila contador, tres cajas concurrentes emiten 10.000 comprobantes con cero duplicados y cero huecos, y
la espera por comprobante crece con la duración de la transacción que retiene el número."*
**Resultado:** 10.000 autorizados contra el organismo simulado (del 247.582 al 257.581), 0 repetidos, 0 huecos, 0 rechazos, espera
media por el número 5,4 ms. Con el comprobante armado mientras el número está tomado, la espera pasa de 5,5 a 11,9, 22,8 y 36,0 ms
con 0, 2, 5 y 10 ms de armado; con el número asignado al autorizar, entre 0,8 y 2,0 ms. Con el organismo a 50 ms y 900
comprobantes: `UltimoNumero` 180 rechazos 10016, `DMax + 1` 2.404, la fila contador 0. Un punto de venta por caja: 0,21 ms. ·
**Apuesta:** ganada
**Reproducir:** `uv run python 16-el-folio-sin-huecos/cajas.py --design counter --invoices 10000` y las variantes de `--design`,
`--hold` y `--latency` desde `src/`, después de `01_setup.sql`

### M-30 · F16 · La secuencia y el contador en Oracle
**Tipo:** apuesta sin resolver · **Motor:** Oracle Free · **Perfil:** M
**Hipótesis:** una secuencia `NOCACHE ORDER` también deja el hueco del `ROLLBACK`, y la fila contador con `UPDATE … RETURNING
INTO` serializa las cajas igual que en Postgres. · **Resuélvela:** los pasos de `races.py sequence` y `races.py counter` a mano en
dos sesiones de `sqlplus`, como pide la [Fase 16](16-el-folio-sin-huecos.md)
