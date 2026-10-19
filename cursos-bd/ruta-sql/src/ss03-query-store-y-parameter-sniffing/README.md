# 🔎 ss03 · Query Store y parameter sniffing

Lo que ejecuta [ss03](../../ss03-query-store-y-parameter-sniffing.md): la consulta por sede de la Fase 13 como
procedimiento en SQL Server, el plan que queda según la primera sede, Query Store y las salidas que se escriben en
el código.

## 🗂️ Qué hay

| Archivo | Qué hace |
|---|---|
| `01_setup.sql` | la base aparte `ss03`, donde se cambian índices, Query Store y compatibilidad sin tocar `ALAMEDA` |
| `02_sniffing.py` | el procedimiento en dos órdenes y con compatibilidad 170 y 100; la estructura del plan en caché |
| `03_query_store.py` | los dos planes en Query Store, uno forzado, y una pista sin tocar el código |
| `04_alternativas.py` | `OPTIMIZE FOR`, `OPTIMIZE FOR UNKNOWN` y `RECOMPILE`, con el plan estimado |
| `05_roturas.sql` | dos maneras de fijar un plan que dejan de servir cuando cambian los índices; un lote falla a propósito |
| `06_psp.sql` | el evento extendido que dice por qué PSP no armó variantes |

## ▶️ Cómo se corre

Con la caja cargada en SQL Server ([ss01](../ss01-la-base-en-su-motor-original/README.md)), desde `src/`:

```bash
S=ss01-la-base-en-su-motor-original/sqlcmd.sh
$S -b < ss03-query-store-y-parameter-sniffing/01_setup.sql
uv run --extra sqlserver python ss03-query-store-y-parameter-sniffing/02_sniffing.py [--private]
uv run --extra sqlserver python ss03-query-store-y-parameter-sniffing/03_query_store.py [--private]
uv run --extra sqlserver python ss03-query-store-y-parameter-sniffing/04_alternativas.py
$S < ss03-query-store-y-parameter-sniffing/05_roturas.sql
$S < ss03-query-store-y-parameter-sniffing/06_psp.sql
```

`--private` agrega, solo para ti, las cifras de SQL Server que el curso no publica (apéndice `a09`).
