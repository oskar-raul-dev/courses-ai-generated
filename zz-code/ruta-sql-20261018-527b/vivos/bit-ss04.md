### M-69 · ss04 · Cinco claves agrupadas sobre los protocolos de la caja
**Tipo:** apuesta sin resolver · **Motor:** SQL Server 2025 CU9 (Enterprise Developer, emulado) · **Perfil:** M (1.327.622 protocolos, de a 5.000 en orden de llegada)
**Hipótesis:** el índice agrupado con UUIDv7 de la aplicación queda tan fragmentado y tan grande como el de UUIDv4 (páginas a menos del 75 %, fragmentación de más del 90 %), porque SQL Server compara los bytes 10 a 15 primero y el v7 pone el tiempo en los bytes 0 a 5; solo `NEWSEQUENTIALID()` se parece a `int IDENTITY`. En InnoDB y Postgres el v7 sí ordena ([M-16](#m-16--f10--uuidv4-y-uuidv7-como-clave-primaria-en-innodb)). · **Resuélvela:** `uv run --extra sqlserver python ss04-clustered-newsequentialid-y-temporales/01_claves.py --private` desde `src/`

### M-70 · ss04 · `NEWSEQUENTIALID()` después de reiniciar, en Linux
**Tipo:** apuesta sin resolver · **Motor:** SQL Server 2025 CU9 (Enterprise Developer, emulado, sobre Linux) · **Perfil:** —
**Hipótesis:** después de reiniciar el contenedor, las mil filas nuevas de `dbo.seq_restart` quedan ordenadas antes de las mil anteriores, como advierte la documentación para Windows. · **Resuélvela:** `02_reinicio.sql`, `docker compose -f ../lab/compose.yaml restart sqlserver` y `02_reinicio_despues.sql`, desde `src/ss04-clustered-newsequentialid-y-temporales/`

### M-71 · ss04 · `uuidv7()` de Postgres 18, en el orden en que se genera
**Tipo:** publicada · **Motor:** PostgreSQL `pgvector/pgvector@sha256:2358fcba361e…` (18.6) · **Perfil:** — · **Fecha:** 18/10/2026
**Hipótesis:** mil valores de `uuidv7()` generados en una sentencia están en el orden de generación según la comparación de `uuid`.
**Resultado:** 0 de 1.000 fuera de orden (comparado cada uno con el anterior, con `lag`). · **Apuesta:** ganada
**Reproducir:** la solución del ejercicio 12 de ss04
