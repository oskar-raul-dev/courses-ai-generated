### M-62 · ss02 · El formulario del almuerzo frente al reporte, con y sin RCSI
**Tipo:** apuesta sin resolver · **Motor:** SQL Server 2025 CU9 (Enterprise Developer, emulado) · **Perfil:** M (la base `ss02`)
**Hipótesis:** con `READ_COMMITTED_SNAPSHOT` apagado, el reporte que lee el hemograma 1 espera al formulario sin confirmar (`LCK_M_S`, con el `blocking_session_id` del formulario) y lee `40` al confirmar; con RCSI, lee `41` sin esperar. En Postgres, publicado en ss02: el reporte lee `41` sin esperar y nadie espera un bloqueo. · **Resuélvela:** `lunch_form_reader.race` y `lunch_form_reader_rcsi.race`, desde `src/`

### M-63 · ss02 · Las anomalías de la Fase 15 en los niveles de SQL Server
**Tipo:** apuesta sin resolver · **Motor:** SQL Server 2025 CU9 (Enterprise Developer, emulado) · **Perfil:** M (la base `ss02`)
**Hipótesis:** lectura sucia en `READ UNCOMMITTED`; actualización perdida sin error en `READ COMMITTED`, 1205 en `REPEATABLE READ` y 3960 en `SNAPSHOT`; *write skew* en `READ COMMITTED` y `SNAPSHOT` (dos tomas) y 1205 en el `INSERT` de uno en `SERIALIZABLE` (una toma), frente al `40001` en el `COMMIT` de Postgres ([M-27](#m-27--f15--la-muestra-tomada-dos-veces-en-cuatro-niveles-y-dos-motores)). · **Resuélvela:** `dirty_read.race`, `lost_update.race` y `write_skew.race` con cada `--isolation`, y `deadlock.race`

### M-64 · ss02 · El *version store* de una lectura `SNAPSHOT` larga
**Tipo:** apuesta sin resolver · **Motor:** SQL Server 2025 CU9 (Enterprise Developer, emulado) · **Perfil:** M (29.241 hemogramas, tres correcciones)
**Hipótesis:** con ADR apagado, el *version store* de `ss02` en `tempdb` crece a varios megabytes con la lectura abierta y vuelve a cero en uno o dos minutos al cerrarla; `dbo.hemogram` crece por la marca de 14 bytes y las páginas partidas, y no vuelve. · **Resuélvela:** `uv run --extra sqlserver python ss02-pesimista-contra-rcsi/03_version_store.py`

### M-65 · ss02 · La misma lectura larga en Postgres
**Tipo:** publicada · **Motor:** PostgreSQL `pgvector/pgvector@sha256:2358fcba361e…` · **Perfil:** M (`staging.hemogram` de la Fase 18, 29.241 filas) · **Fecha:** 18/10/2026
**Hipótesis:** con una lectura `REPEATABLE READ` abierta, tres correcciones de toda la tabla la dejan varias veces más grande, `VACUUM` no puede limpiar nada hasta cerrarla, y al cerrarla limpia pero el archivo no se achica.
**Resultado:** 2.640 KB antes; 10.528 KB con la lectura abierta; `VACUUM` con la lectura abierta, 10.528 KB y 87.723 versiones muertas que no puede borrar; al cerrarla, `VACUUM` deja 0 muertas y el archivo en 10.528 KB (3,99 veces). La lectura vio la misma foto de principio a fin. · **Apuesta:** ganada
**Reproducir:** la solución del ejercicio 16 de ss02, y `src/18-bloqueos-deadlocks-y-ddl/01_setup.sql` para dejar la tabla como estaba
