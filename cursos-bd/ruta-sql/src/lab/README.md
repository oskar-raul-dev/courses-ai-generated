# 🧪 `src/lab/` — el laboratorio

El paquete `lab` y el `compose.yaml` del curso: levanta los motores, genera la caja de Alameda, la carga,
y mide. Es lo único compartido entre las fases; cada fase trae lo suyo en su propia carpeta de `src/`.
Todos los comandos se corren **desde `src/`** con `uv run lab …`.

---

## 📋 Los comandos

| Comando | Qué hace | Dónde se explica |
|---|---|---|
| `lab up [perfil …]` | levanta los perfiles del compose (`base` por defecto) y espera a que estén sanos | [`a02`](../../a02-compose-de-la-ruta.md) |
| `lab down [-v]` | baja el laboratorio; con `-v` borra también sus volúmenes, y con ellos los datos | [`a02`](../../a02-compose-de-la-ruta.md) |
| `lab ps` | qué está arriba | [`a02`](../../a02-compose-de-la-ruta.md) |
| `lab generate --profile s\|m\|l` | genera la caja del perfil en `lab/caja/`, con la semilla 1996 | [`a05`](../../a05-la-caja-y-el-generador.md) |
| `lab load --profile m [--model]` | carga la caja en Postgres (`legacy` entera y `truth`); con `--model`, también el modelo de las fases 04 a 08 | [`a05`](../../a05-la-caja-y-el-generador.md), [F01](../../01-la-caja-y-el-arnes.md) |
| `lab load --engine mysql\|oracle --tables …` | las tablas pedidas, en MySQL u Oracle | [F01](../../01-la-caja-y-el-arnes.md) |
| `lab load --engine sqlserver` | la caja entera en SQL Server, con el extra `sqlserver` | [ss01](../../ss01-la-base-en-su-motor-original.md) |
| `lab measure [--engine …] -c "…"` | la forma de una consulta: filas, bloques o lecturas, y el plan | [`a04`](../../a04-el-arnes-de-forma.md) |
| `lab race -f escenario.race` | sesiones intercaladas en un orden fijo, en Postgres, MySQL o SQL Server | [`a04`](../../a04-el-arnes-de-forma.md#-uv-run-lab-race-sesiones-en-un-orden-fijo) |

`--private`, en `load` y `measure`, muestra en tu terminal los tiempos y las estadísticas de ejecución de
Oracle y de SQL Server. **No se publican** ([`a09`](../../a09-licencias-publicacion-y-riesgo.md)).

---

## 🗄️ Los perfiles del compose

| Perfil | Servicio | Puerto en `127.0.0.1` | Para qué |
|---|---|---|---|
| `base` | PostgreSQL 18 con pgvector | 25432 | todo el curso |
| `contraste` | MySQL 9.7 | 23306 | el contraste de cada fase |
| `oracle` | Oracle 26ai Free | 21521 | el caso de estudio |
| `mongo` | MongoDB 8.0 | 27027 | la Fase 20 |
| `api` | PostgREST | 23000 | la Fase 23 |
| `puente` | Apache Artemis | 26161 (consola 28161) | el boss del puente |
| `sqlserver` | SQL Server 2025 | 21433 | el track |
| `dab` | Data API builder | 25000 | ss05 |

Los puertos no son los de fábrica a propósito, para no chocar con un motor que ya tengas. Cada uno se
cambia con su variable (`POSTGRES_PORT`, `MYSQL_PORT`…) en `src/lab/.env`; la memoria de cada servicio,
con la suya (`POSTGRES_MEMORY`, `SQLSERVER_MEMORY`…). La tabla completa, con los digests y la RAM medida,
está en [`a02`](../../a02-compose-de-la-ruta.md#-puertos-y-variables). Todos los contenedores, volúmenes y la
red llevan la etiqueta `curso=ruta-sql`.

---

## 🗂️ Qué hay

| Archivo | Qué es |
|---|---|
| `compose.yaml` | los ocho servicios, fijados por digest, con sus perfiles, memoria y *healthchecks* |
| `cli.py` | el comando `lab` |
| `config.py` | puertos, contraseñas y el comando de compose, leídos del entorno con los valores de fábrica |
| `engines/` | la carga de la caja y `measure` en Postgres, MySQL, Oracle y SQL Server, uno por archivo |
| `generator/` | el generador de la caja: el mundo de Alameda, las 71 tablas anchas, los nombres, el parser de Rubén en Python (`rubens_parser.py`), los antibiogramas y la planilla de convenios en Excel |
| `model.py` | el modelo de las fases 04 a 08, que `lab load --model` construye sobre la caja |
| `race.py` | el arnés de `lab race`, que también se usa desde Python (`from lab.race import Race`) |

La caja que genera (`lab/caja/`) no se versiona: se rehace desde la semilla, y su hash por perfil está en
[`a05`](../../a05-la-caja-y-el-generador.md). Si ya tienes una caja generada en otro lado, `LAB_CAJA` le
dice al compose dónde montarla.

---

## ⚠️ Antes de empezar

- **`lab down -v` borra los datos del curso**, y solo esos: el compose solo conoce sus propios volúmenes.
  Para limpiar contenedores o volúmenes a mano, **nunca uses `docker volume prune` ni `docker system
  prune`**: borran también lo de otros proyectos de tu máquina. Usa la etiqueta (`--filter
  label=curso=ruta-sql`) y nombres explícitos.
- **La memoria de la VM de Docker se comparte** con todo lo que corre en tu máquina. Con el laboratorio
  entero arriba y otro proyecto al lado, el kernel mata contenedores por memoria (`OOMKilled` en `docker
  inspect`); levanta solo los perfiles que la fase pide.
- **SQL Server solo corre en amd64**: en Apple Silicon, con la emulación de Docker Desktop; en Podman no
  arranca ([`a01`](../../a01-laboratorio-contenerizado.md)).
