# 🌐 ss05 · Data API builder y JSON

Lo que ejecuta [ss05](../../ss05-data-api-builder-y-json.md): el contrato que la Fase 23 publicó con PostgREST,
servido desde SQL Server con Data API builder, y los antibiogramas de la Fase 19 con el tipo `json` de SQL Server 2025.

## 🗂️ Qué hay

| Archivo | Qué hace |
|---|---|
| `01_modelo.py` | copia el modelo de la Fase 23 de Postgres a la base `ss05`, y los antibiogramas como documentos |
| `02_api.sql` | el esquema `api`, el login de DAB y la seguridad por fila con `SESSION_CONTEXT`; es repetible |
| `dab-config.json` | la configuración de DAB 2.1.5, con la cadena de conexión desde el entorno |
| `03_api.py` | los mismos pedidos que la Fase 23 le hizo a PostgREST, con la identidad en `X-MS-CLIENT-PRINCIPAL` |
| `04_json.sql` | la búsqueda por un resultado sin índice, con el índice JSON y con una columna calculada; el último lote falla a propósito |

## ▶️ Cómo se corre

Con el modelo de la Fase 23 en Postgres y la caja en SQL Server, desde `src/`:

```bash
uv run --extra sqlserver lab up base sqlserver
uv run --extra sqlserver python ss05-data-api-builder-y-json/01_modelo.py
ss01-la-base-en-su-motor-original/sqlcmd.sh -b < ss05-data-api-builder-y-json/02_api.sql
uv run --extra sqlserver lab up sqlserver dab
uv run --extra sqlserver python ss05-data-api-builder-y-json/03_api.py
ss01-la-base-en-su-motor-original/sqlcmd.sh < ss05-data-api-builder-y-json/04_json.sql
```

## ✅ Lo que tiene que salir

`uv run lab up sqlserver dab` levanta DAB, y `03_api.py` da las seis líneas de la sección 4 de la lección. ⚠️ El proveedor `AppService` confía en el encabezado:
sin App Service delante, cualquiera lo escribe, y eso es lo que muestra la sección 8.
