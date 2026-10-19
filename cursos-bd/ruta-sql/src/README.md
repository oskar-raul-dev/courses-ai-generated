# 🧰 `src/` — el código de la Ruta SQL

Todo lo que el curso ejecuta está aquí: el laboratorio, una carpeta por cada fase o apéndice que deja
código, y los boss. **La prosa vive en las lecciones**; esto es lo que el lector corre, y las dos cosas
cuentan lo mismo. Cada carpeta lleva el nombre exacto de su documento.

---

## ▶️ Cómo se usa

`src/` es un proyecto de Python con `uv`: el `pyproject.toml` declara los tres drivers y el comando `lab`,
y el `uv.lock` fija cada versión ([`a06`](../a06-python-java-y-drivers.md#-uv-y-el-uvlock)). Lo único que
pide en tu máquina es `uv` y Docker. Todo se corre **desde `src/`**:

```bash
uv run --locked lab up                         # levanta Postgres (el perfil base) y espera a que esté sano
uv run lab generate --profile m                # genera la caja M desde su semilla (a05)
uv run lab load --profile m --model            # la carga en Postgres, con la verdad y el modelo de las fases 04 a 08
uv run lab measure -c "SELECT …"               # la forma de una consulta (a04)
uv run lab race -f 15-aislamiento-comparado/lost_update.race   # dos sesiones en un orden fijo (a04)
uv run python 16-el-folio-sin-huecos/races.py <escenario>      # los scripts de cada fase
```

Los `.sql` de cada fase se corren con el cliente del motor, desde `src/lab/`
([`a03`](../a03-clis-de-los-motores.md#-correr-un-archivo-en-los-tres)). El orden de los archivos de una
carpeta es el de su prefijo (`01_`, `02_`…), y cada lección dice cuál corre cuándo.

**El track de SQL Server** se instala aparte, con el extra `sqlserver`: `uv run --extra sqlserver lab …`.
El camino base no lo necesita.

---

## 🗂️ Qué hay

| Carpeta | Qué guarda |
|---|---|
| [`lab/`](lab/README.md) | el laboratorio: el `compose.yaml`, el CLI `lab`, el generador de la caja, la carga en cuatro motores, `measure` y `race` |
| `03-lo-que-sql-le-hace-al-modelo/` | la presentación de Rubén y la corregida |
| `04-un-valor-un-hecho/` | del *staging* a la BCNF: el parser de 2016 portado, los pagadores, los pacientes, las claves y los huérfanos |
| `05-una-persona-no-es-su-documento/` | la limpieza, los candidatos por trigramas, la identidad, la fusión deshacible y los recién nacidos |
| `06-cuarta-y-quinta-forma-normal/` | los catálogos, los convenios desde la planilla de Excel (`xlsx_to_csv.py`) y la regla cíclica |
| `07-el-tiempo-en-el-modelo/` | los precios con vigencia, `WITHOUT OVERLAPS`, la historia de resultados y lo bitemporal |
| `08-los-dos-extremos-del-mismo-error/` | el protocolo, el modelo tipado, el EAV, las anchas y `jsonb`; y el 💀 [boss I](08-los-dos-extremos-del-mismo-error/boss/README.md) |
| `09-el-tamano-de-las-cosas/` | las órdenes escaneadas y los PDF que la caja no trae, la alineación de columnas, el resultado particionado por mes y la compresión de TOAST |
| `10-identificadores/` | las claves en Postgres y en InnoDB (`mysql_keys.py`), la secuencia atrasada y lo que filtra un id |
| `11-indices-y-lo-que-cuestan/` | el costo de escritura de cada índice, HOT, los tipos de índice y el índice de texto |
| `12-estadisticas-y-cardinalidad/` | la correlación, las estadísticas viejas, el precipicio del plan y los histogramas de MySQL |
| `13-el-optimizador-en-tres-motores/` | los planes genéricos, los métodos de join, el *hint* y el plan fijo en el tiempo |
| `14-la-base-no-estaba-lenta/` | el frontal de 2011 simulado contra MySQL (`front.py`), la paginación del portal y `pg_stat_statements`; y el 💀 [boss II](14-la-base-no-estaba-lenta/boss/README.md) |
| `15-aislamiento-comparado/` | las anomalías como `.race` en Postgres y MySQL, la matriz (`matrix.py`) y los técnicos con hilos |
| `16-el-folio-sin-huecos/` | el organismo fiscal simulado (`fiscal.py`), las cajas y los contadores |
| `17-mvcc-y-su-factura/` | la fila contador con una lectura larga abierta, en Postgres (`mvcc.py`) y en MySQL (`mysql_history.py`) |
| `18-bloqueos-deadlocks-y-ddl/` | los bloqueos, los *deadlocks* y la cola detrás del DDL; y el 💀 [boss III](18-bloqueos-deadlocks-y-ddl/boss/README.md) |
| `19-json-en-los-motores/` | el antibiograma en forma larga y como documento, las búsquedas y el WAL |
| `20-la-propuesta-de-florencia/` | la muestra, su carga en MongoDB y las cinco operaciones medidas |
| `21-hasta-donde-llega-el-motor/` | los nombres mal escritos, la recursión y los vectores; y el 💀 [boss IV](21-hasta-donde-llega-el-motor/boss/README.md) |
| `22-la-exportacion-de-las-9-40/` | la marca de agua, las colas, el CDC con `test_decoding` y el *outbox* |
| `23-la-base-como-producto/` | los roles, la seguridad por fila, el MD5 del portal y la API; el 💀 [boss V](23-la-base-como-producto/boss/README.md) y el ☕ [boss del puente](23-la-base-como-producto/puente/README.md) |
| `24-el-diseno/` | el inventario del diseño |
| `25-la-migracion-sin-parar/` | las 71 anchas al modelo, la reconciliación, el CDC (`cdc.py`), la convivencia, el SIH, el corte y su vuelta atrás |
| `26-el-comite/` | la factura de licencias (`01_factura.py`) y el 🏆 [martes](26-el-comite/martes/README.md) |
| `ss01-…` a `ss05-…` | el track de SQL Server: la carga y el parser de 2016, las carreras con y sin RCSI, Query Store, las claves y las temporales, y Data API builder (`dab-config.json`) |
| [`a10-el-access-de-museo/`](a10-el-access-de-museo/README.md) | opcional: el `.accdb` de Rubén sin Office, y su `.bas` en LibreOffice |

Las fases 00 a 02 no dejan carpeta: usan `lab/` y nada más.

---

## 💀 Los boss

Cada carpeta `boss/` (y `puente/` y `martes/`) trae **el punto de partida roto** y lo que lo evalúa. Se
arregla lo que su README dice que se arregla, y nada más. **Ninguna solución vive en el repositorio**: el
criterio de aceptación es el entregable.

---

## 🙈 Lo que no se versiona

`.venv/`, la caja (`lab/caja/`, que el generador rehace desde su semilla), la configuración local
(`.env`, `lab/compose.override.yaml`), lo que bajan los proyectos de Java (`target/`,
`23-…/puente/lib/`, `a10-…/lib/`) y la salida del museo (`a10-…/out/`). El `.gitignore` del curso está aquí y se
sostiene solo; el de la raíz ignora únicamente archivos del sistema operativo y de los editores.
