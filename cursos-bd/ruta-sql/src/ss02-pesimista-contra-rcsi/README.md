# 🔒 ss02 · Pesimista contra RCSI

Lo que ejecuta [ss02](../../ss02-pesimista-contra-rcsi.md): las anomalías de la Fase 15 y los bloqueos de la Fase 18
en SQL Server, con `lab race`, con y sin versiones de filas.

## 🗂️ Qué hay

| Archivo | Qué hace |
|---|---|
| `01_setup.sql` | la base aparte `ss02`, copiada de `ALAMEDA`, porque las opciones de versiones son de toda la base |
| `02_snapshot.sql` | enciende `READ_COMMITTED_SNAPSHOT` y `ALLOW_SNAPSHOT_ISOLATION` |
| `03_version_store.py` | el *version store* de `tempdb` antes, durante y después de una lectura `SNAPSHOT` larga |
| `lunch_form_reader.race`, `…_rcsi.race` | el formulario abierto a la hora del almuerzo, con bloqueos y con RCSI |
| `lunch_form_reader_pg.race` | el mismo formulario en Postgres, para el contraste |
| `dirty_read.race`, `lost_update.race`, `write_skew.race`, `deadlock.race` | las anomalías de la Fase 15 y el deadlock de la Fase 18 |

## ▶️ Cómo se corre

Con la caja cargada en SQL Server ([ss01](../ss01-la-base-en-su-motor-original/README.md)), desde `src/`:

```bash
S=ss01-la-base-en-su-motor-original/sqlcmd.sh
$S -b < ss02-pesimista-contra-rcsi/01_setup.sql
uv run --extra sqlserver lab race -f ss02-pesimista-contra-rcsi/lunch_form_reader.race
uv run --extra sqlserver lab race -f ss02-pesimista-contra-rcsi/lunch_form_reader_rcsi.race
uv run --extra sqlserver lab race -f ss02-pesimista-contra-rcsi/dirty_read.race --isolation read-uncommitted
uv run --extra sqlserver lab race -f ss02-pesimista-contra-rcsi/lost_update.race --isolation read-committed
uv run --extra sqlserver lab race -f ss02-pesimista-contra-rcsi/deadlock.race
$S < ss02-pesimista-contra-rcsi/02_snapshot.sql        # antes de las carreras con --isolation snapshot
uv run --extra sqlserver python ss02-pesimista-contra-rcsi/03_version_store.py
```

Cada `.race` lista en su cabecera los niveles con que se corre. `lunch_form_reader_pg.race` va contra Postgres, con
el `01_setup.sql` de la Fase 18.
