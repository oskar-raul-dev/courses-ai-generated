### M-59 · ss01 · `BULK INSERT` y la diferencia entre `""` y el campo vacío
**Tipo:** apuesta sin resolver · **Motor:** SQL Server 2025 CU9 (Enterprise Developer, emulado) · **Perfil:** M
**Hipótesis:** `BULK INSERT … WITH (FORMAT = 'CSV', KEEPNULLS)` sobre `Protocolos.csv` no conserva los 3.649 `""` de `ObraSocial` que Postgres conserva (1.142.443 NULL y 3.649 vacíos con `COPY`): llegan como NULL. · **Resuélvela:** `./sqlcmd.sh < 02_bulk_insert.sql`, desde `src/ss01-la-base-en-su-motor-original/`, la última consulta

### M-60 · ss01 · El T-SQL de 2016 en su motor contra su port de la Fase 04
**Tipo:** apuesta sin resolver · **Motor:** SQL Server 2025 CU9 (Enterprise Developer, emulado) · **Perfil:** M
**Hipótesis:** `dbo.fn_ExtraerDNI` y `dbo.fn_ExtraerFecha`, sin tocar, dan sobre los 242.427 pacientes lo mismo que `staging.extract_dni_2016` y `staging.extract_birth_date_2016`: cero diferencias, y por lo tanto las mismas 3 (DNI) y 115 (fechas) contra la versión de 2026 que midió [M-07](#m-07--f04--el-90--del-parser-de-rubén). · **Resuélvela:** `uv run --extra sqlserver python ss01-la-base-en-su-motor-original/05_comparar.py` desde `src/`

### M-61 · ss01 · El corte de los años de dos cifras, en la conexión que lo cambia
**Tipo:** apuesta sin resolver · **Motor:** SQL Server 2025 CU9 (Enterprise Developer, emulado) · **Perfil:** —
**Hipótesis:** la documentación dice que `two digit year cutoff` vale "immediately"; aun así, la conexión que hace `sp_configure 'two digit year cutoff', 2029; RECONFIGURE` sigue leyendo `12/03/46` como 2046, y solo una conexión nueva lo lee como 1946. · **Resuélvela:** `./sqlcmd.sh < 06_ventana.sql` y después `./sqlcmd.sh < 06b_conexion_nueva.sql`
