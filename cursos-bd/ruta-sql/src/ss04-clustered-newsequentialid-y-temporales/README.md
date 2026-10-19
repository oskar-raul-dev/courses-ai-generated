# 🔑 ss04 · Clustered, NEWSEQUENTIALID y temporales

Lo que ejecuta [ss04](../../ss04-clustered-newsequentialid-y-temporales.md): la medición de claves de la Fase 10 en
SQL Server, `NEWSEQUENTIALID` después de un reinicio y la pregunta de Norma de la Fase 07 con una tabla temporal.

## 🗂️ Qué hay

| Archivo | Qué hace |
|---|---|
| `01_claves.py` | los 1.327.622 protocolos en cinco tablas que solo difieren en la clave agrupada |
| `02_reinicio.sql`, `02_reinicio_despues.sql` | 1.000 filas con `NEWSEQUENTIALID`, el reinicio, y 1.000 más |
| `03_temporales.sql` | los resultados del 9 de octubre de 2026 en una tabla versionada, y la corrección de la glucemia; dos lotes fallan a propósito |
| `04_temporales_roturas.sql` | lo que una tabla temporal no deja hacer, y la hora en que guarda los períodos |

## ▶️ Cómo se corre

Con la caja cargada en SQL Server ([ss01](../ss01-la-base-en-su-motor-original/README.md)), desde `src/`:

```bash
S=ss01-la-base-en-su-motor-original/sqlcmd.sh
uv run --extra sqlserver python ss04-clustered-newsequentialid-y-temporales/01_claves.py [--private]
$S < ss04-clustered-newsequentialid-y-temporales/02_reinicio.sql
docker compose -f lab/compose.yaml restart sqlserver        # y esperar a que esté healthy
$S < ss04-clustered-newsequentialid-y-temporales/02_reinicio_despues.sql
$S < ss04-clustered-newsequentialid-y-temporales/03_temporales.sql
$S < ss04-clustered-newsequentialid-y-temporales/04_temporales_roturas.sql
```
