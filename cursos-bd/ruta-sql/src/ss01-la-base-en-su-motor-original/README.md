# 🗄️ ss01 · La base en su motor original

Lo que ejecuta [ss01](../../ss01-la-base-en-su-motor-original.md), la primera fase del track de SQL Server: la caja
de vuelta en SQL Server, lo que dejó el script de SSMS y el parser de 2016 corrido en su motor. **Todo el track usa
el `sqlcmd.sh` de esta carpeta.**

## 🗂️ Qué hay

| Archivo | Qué hace |
|---|---|
| `sqlcmd.sh` | el `sqlcmd` del contenedor contra el laboratorio; `-b` corta en el primer error |
| `01_bcp_in.sh` | devuelve dos tablas con `bcp`, en la base aparte `ss01_pruebas` (`PERFIL=s` para la caja chica) |
| `02_bulk_insert.sql` | el segundo intento, con `BULK INSERT … FORMAT = 'CSV'`: tres pruebas, una por lote |
| `03_esquema.sql` | lo que el script de SSMS dejó en `ALAMEDA`, leído del catálogo; solo lee |
| `04_parser_2016.sh` | `tsql/fn_ExtraerDNI.sql` de la caja, sin tocar una línea, y una muestra de lo que devuelve |
| `05_comparar.py` | el parser de 2016 en SQL Server, su port de la Fase 04 y el VBA de 2026, paciente por paciente |
| `06_ventana.sql`, `06b_conexion_nueva.sql` | la ventana del año de dos dígitos, en esta conexión y en otra |

## ▶️ Cómo se corre

Desde `src/`, con el extra `sqlserver`:

```bash
uv run --extra sqlserver lab up sqlserver
uv run --extra sqlserver lab load --engine sqlserver --profile m
cd ss01-la-base-en-su-motor-original
./01_bcp_in.sh
./sqlcmd.sh < 02_bulk_insert.sql
./sqlcmd.sh < 03_esquema.sql
./04_parser_2016.sh
cd .. && uv run --extra sqlserver python ss01-la-base-en-su-motor-original/05_comparar.py && cd -
./sqlcmd.sh < 06_ventana.sql
./sqlcmd.sh < 06b_conexion_nueva.sql
```

`05_comparar.py` necesita también Postgres con las funciones de la Fase 04.

## ✅ Lo que tiene que salir

`lab load --engine sqlserver --profile m` carga 419 tablas y ninguna difiere del manifiesto. El resto, en la lista de
comprobación de la fase.
