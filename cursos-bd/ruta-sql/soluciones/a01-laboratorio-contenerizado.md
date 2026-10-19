# ✅ Soluciones — Apéndice a01: Laboratorio contenerizado

> **Curso:** Ruta SQL · Solucionario del [Apéndice a01](../a01-laboratorio-contenerizado.md)
> **Ejercicios:** 8 · **Perfil:** M donde hay datos · **Motores:** los de
> [`a02`](../a02-compose-de-la-ruta.md#-las-versiones-del-curso), con Docker Desktop 29.8.0 en macOS
> arm64
> **Fecha de verificación ejecutada:** 12/10/2026

> ⚠️ **Intenta el ejercicio antes de leer su solución.** Leída antes, solo te enseña a reconocerla.

---

## 🟢 Fácil (1–3)

### Ejercicio 1

**Enunciado (resumen):** ejecutar los dos comandos de la prueba de entorno y decir de quién es el
kernel y si alcanza la memoria.

**Solución.** En la máquina de verificación:

```bash
docker info --format '{{.OperatingSystem}} · kernel {{.KernelVersion}} · {{.NCPU}} CPU · {{.MemTotal}} bytes'
docker compose version
```

```text
Docker Desktop · kernel 7.0.12-linuxkit · 8 CPU · 8319770624 bytes
Docker Compose version v5.5.1
```

`linuxkit` es el kernel de la VM de Docker Desktop, no el de macOS: cambia cuando actualizas Docker
Desktop. En Windows con WSL2 lo cambia `wsl --update`, y solo en Linux es el de tu sistema. Los
8.319.770.624 bytes son 7,75 GiB, y el laboratorio entero con M cargado ocupa unos 3,8 GiB: alcanza,
con unos 4 GiB de margen.

> ⚠️ **Error típico:** leer `MemTotal` como la RAM de la máquina. Es la de la VM; la de tu Mac no
> importa si la VM tiene menos.

[← Volver al ejercicio](../a01-laboratorio-contenerizado.md#-ejercicio-1--la-prueba-de-que-todo-está-en-su-sitio)

### Ejercicio 2

**Enunciado (resumen):** levantar `base`, consultar la versión, y comprobar qué deja `down` y qué
borra `down -v`.

**Solución.** El volumen sobrevive a `down` y desaparece con `down -v`:

```text
$ uv run lab up
→ docker compose --profile base up -d --wait
…
 Container alameda-lab-postgres-1 Healthy

$ docker compose exec postgres psql -U postgres -d alameda -tAc 'SELECT version()'
PostgreSQL 18.6 (Debian 18.6-1.pgdg12+2) on aarch64-unknown-linux-gnu, compiled by gcc (Debian 12.2.0-14+deb12u1) 12.2.0, 64-bit

$ uv run lab down
→ docker compose --profile base --profile contraste --profile oracle --profile mongo --profile sqlserver down
 Container alameda-lab-postgres-1 Stopping
 Container alameda-lab-postgres-1 Stopped
 Container alameda-lab-postgres-1 Removing
 Container alameda-lab-postgres-1 Removed
 Network alameda-lab_default Removing
 Network alameda-lab_default Removed

$ docker volume ls --filter label=curso=ruta-sql
DRIVER    VOLUME NAME
local     alameda-lab_postgres-data

$ uv run lab down -v
→ docker compose --profile base --profile contraste --profile oracle --profile mongo --profile sqlserver down -v
 Volume alameda-lab_postgres-data Removing
 Volume alameda-lab_postgres-data Removed

$ docker volume ls --filter label=curso=ruta-sql
DRIVER    VOLUME NAME
```

`lab down` pasa todos los perfiles para que no quede nada arriba aunque no recuerdes cuáles
levantaste. `aarch64` en la versión confirma que Postgres corre nativo.

[← Volver al ejercicio](../a01-laboratorio-contenerizado.md#-ejercicio-2--qué-borra-cada-down)

### Ejercicio 3

**Enunciado (resumen):** levantar `oracle` sin `--wait`, conectarse enseguida, y medir cuánto tarda en
estar *healthy*.

**Solución.** Desde `src/lab/`:

```text
$ docker compose --profile oracle up -d
…
 Container alameda-lab-oracle-1 Started

$ docker compose exec oracle sqlplus -s -L system/lab@FREEPDB1
ERROR:
ORA-12154: Cannot connect to database. Cannot find alias FREEPDB1 in
/opt/oracle/product/26ai/dbhomeFree/network/admin/tnsnames.ora.
Help: https://docs.oracle.com/error-help/db/ora-12154/


SP2-0751: Unable to connect to Oracle.  Exiting SQL*Plus
Help: https://docs.oracle.com/error-help/db/sp2-0751/

$ docker compose ps
SERVICE   STATUS
oracle    Up Less than a second (health: starting)
```

Un bucle que pregunta cada segundo dio *healthy* **6 s después de la primera consulta**, y entonces:

```text
$ docker compose ps
SERVICE   STATUS
oracle    Up 6 seconds (healthy)

$ docker compose exec oracle sqlplus -s -L system/lab@FREEPDB1

ESTADO
-------
conecta
```

La consulta fue `SELECT 'conecta' AS estado FROM dual;`. En otra corrida del mismo día, un poco más
tarde dentro del arranque, el error fue `ORA-12541: Cannot connect. No listener at host 172.25.0.2
port 1521.`: el alias ya existía y el *listener* todavía no. Los dos son "todavía no", y ninguno se
arregla tocando la configuración.

[← Volver al ejercicio](../a01-laboratorio-contenerizado.md#-ejercicio-3--conectarse-antes-de-tiempo)

## 🟡 Intermedio (4–6)

### Ejercicio 4

**Enunciado (resumen):** ocupar el 25432, reproducir el error, encontrar al dueño y salir con
`POSTGRES_PORT`.

**Solución.** Un Postgres cualquiera en ese puerto, y después el laboratorio:

```bash
docker run -d --rm --name otro-postgres -e POSTGRES_PASSWORD=x -p 127.0.0.1:25432:5432 pgvector/pgvector:0.8.7-pg18
```

```text
$ uv run lab up
→ docker compose --profile base up -d --wait
…
Error response from daemon: failed to set up container networking: driver failed programming external connectivity on endpoint alameda-lab-postgres-1 (4dbc5937244b98e0572efcb7b0c8405fe4f431f080596b0a9bd7222762784cfe): Bind for 127.0.0.1:25432 failed: port is already allocated

$ docker ps --filter publish=25432 --format 'table {{.Names}}\t{{.Ports}}'
NAMES           PORTS
otro-postgres   127.0.0.1:25432->5432/tcp

$ POSTGRES_PORT=25433 uv run lab up
→ docker compose --profile base up -d --wait
 Container alameda-lab-postgres-1 Recreate
 Container alameda-lab-postgres-1 Recreated
…
 Container alameda-lab-postgres-1 Healthy
```

Y `uv run lab ps` termina la fila de Postgres con `127.0.0.1:25433->5432/tcp`. El puerto de adentro
sigue siendo 5432: los otros contenedores y los scripts que corren en la red del laboratorio no se
enteran. Para que dure, `POSTGRES_PORT=25433` en `src/lab/.env`.

> ⚠️ **Error típico:** cambiar el `5432` de la derecha. Ese es el puerto del motor dentro del
> contenedor, y moverlo rompe el *healthcheck* y a todo el que se conecte por la red interna.

[← Volver al ejercicio](../a01-laboratorio-contenerizado.md#-ejercicio-4--puerto-ocupado)

### Ejercicio 5

**Enunciado (resumen):** Oracle con 512 MB, tres veces, y explicar por qué un contenedor *healthy*
puede tener `OOMKilled=true`.

**Solución.** Cada intento con un volumen nuevo (`uv run lab down -v` entre uno y otro):

```text
$ ORACLE_MEMORY=512m uv run lab up oracle
…
$ docker compose ps -a --format '{{.Service}} {{.Status}}'
$ docker inspect alameda-lab-oracle-1 --format 'oom={{.State.OOMKilled}} exit={{.State.ExitCode}}'
```

| Intento | Estado | `inspect` |
|---|---|---|
| 1 | `oracle Up 10 seconds (healthy)` | `oom=true exit=0` |
| 2 | `oracle Exited (41) Less than a second ago` | `oom=true exit=41` |
| 3 | `oracle Exited (41) Less than a second ago` | `oom=true exit=41` |

La línea que lo anuncia es la segunda del log, que la imagen escribe siempre que el límite baja de 2 GB:

```text
CONTAINER: WARNING: The container has less than 2 GB memory available to run Oracle Database Free.
There are currently only 512 MiB available inside the container.
```

El intento 3 murió en `ORA-03113: end-of-file on communication channel`, justo después de `Database
mounted.`; el 2, después de `Database opened.`. **Por qué *healthy* con OOM:** el kernel mata un
proceso del grupo de control del contenedor, el que elige su *OOM killer* (en general, el que más
memoria ocupa). Si ese proceso
no es el principal ni uno que el *healthcheck* necesite, el contenedor sigue y responde, con un
proceso menos. Por eso la pregunta es `OOMKilled` y no el estado.

**El piso, en la máquina de verificación con la VM sola:** 768 MB y 1 GB arrancaron dos de dos veces;
512 MB, nunca limpio. Con el laboratorio cargado al lado, 1 GB y 1,5 GB fallaron: tu número depende de
lo que tengas arriba.

[← Volver al ejercicio](../a01-laboratorio-contenerizado.md#-ejercicio-5--oracle-sin-memoria)

### Ejercicio 6

**Enunciado (resumen):** con M cargado y `ResultadoItem` recorrida en los tres motores, medir la
memoria y decidir si entra un segundo Oracle.

**Solución.** Después de un `SELECT sum(length("Valor")) FROM legacy."ResultadoItem"` en cada motor
(con SQL Server también arriba) y un minuto de espera:

```text
$ docker stats --no-stream --format '{{.Name}}\t{{.MemUsage}}'
alameda-lab-postgres-1	612.9MiB / 2GiB
alameda-lab-sqlserver-1	705.1MiB / 2GiB
alameda-lab-mysql-1	878.1MiB / 2GiB
alameda-lab-oracle-1	1.602GiB / 3GiB
```

Suman unos 3,8 GiB en una VM de 7,75: quedan unos 4. Un segundo Oracle recién creado ocupa unos 2 GiB
(el del laboratorio, sin datos, marcó 2,01 GiB), así que **entra, pero sin margen** para las cargas,
que suben el pico de cada motor (en la carga de M, Oracle llegó a 1,70 GiB y MySQL a 911 MiB). Con
los tres motores y M cargados, un segundo Oracle con 1 o 1,5 GB de límite no arrancó en la
verificación de este apéndice.

[← Volver al ejercicio](../a01-laboratorio-contenerizado.md#-ejercicio-6--qué-cabe-en-tu-máquina)

## 🟠 Difícil (7–8)

### Ejercicio 7

**Enunciado (resumen):** recuperar 5 GB sin tocar nada que no sea del curso, con la lista de comandos
del más acotado al más amplio.

**Solución de referencia.** Primero, qué es del curso y cuánto pesa:

```text
$ docker system df -v | grep alameda-lab
alameda-lab_postgres-data                                          1         4.263GB
alameda-lab_mysql-data                                             1         1.814GB
```

Esa fue la máquina de verificación con M cargado (el volumen de Oracle también aparece; su tamaño no
se publica). Con eso, en orden:

1. `uv run lab down -v`: unos 6 GB más el volumen de Oracle; se pierden los datos cargados, que
   `lab load` repone en un par de minutos.
2. `rm -r src/lab/caja/m`: 2,2 GB; `lab generate --profile m` la rehace idéntica en menos de tres
   minutos.
3. `docker image rm` de SQL Server, si no vas a hacer el track: 2,42 GB.

El primero ya alcanza. **Por qué no `docker volume prune`:** borra todos los volúmenes sin contenedor
de la máquina, también los de otros proyectos, que no tienen nada que ver con este curso y quizá no se
regeneran.

**Rúbrica.** Una respuesta correcta tiene que:
- empezar por mirar (`docker system df` o `-v`) antes de borrar;
- identificar lo del curso por la etiqueta `curso=ruta-sql` o por el prefijo `alameda-lab`;
- decir qué se pierde con cada comando y cómo se recupera.

Y queda invalidada si:
- usa `docker volume prune`, `docker system prune --volumes` o un `rm -rf` sobre el directorio de
  Docker;
- borra volúmenes o imágenes de otros proyectos.

[← Volver al ejercicio](../a01-laboratorio-contenerizado.md#-ejercicio-7--recuperar-disco-sin-tocar-lo-ajeno)

### Ejercicio 8

**Enunciado (resumen):** predecir qué devuelve `uname -m` dentro de SQL Server en un Mac con Apple
Silicon, comprobarlo y explicar por qué sus tiempos no dicen nada.

**Solución de referencia.** La predicción correcta es `x86_64`: la imagen solo existe para `amd64`.

```text
postgres	aarch64	arm64
mysql	aarch64	arm64
oracle	aarch64	arm64
sqlserver	x86_64	amd64
```

(La salida del bucle de la sección de macOS de `a01`.) SQL Server cree correr en un x86 de 64 bits;
la máquina es `arm64`, y la VM traduce cada instrucción con Rosetta. Un tiempo medido ahí mezcla el
motor con la traducción, y no se puede separar una cosa de la otra: no sirve para comparar con
Postgres, ni con el mismo SQL Server en un x86 nativo.

**Rúbrica.** Una respuesta correcta tiene que:
- predecir `x86_64` antes de ejecutar, y decir por qué (la arquitectura de la imagen);
- nombrar la emulación como la diferencia entre lo que ve el contenedor y la máquina.

Y queda invalidada si:
- concluye algo sobre la velocidad de SQL Server a partir de una medición en ese contenedor.

[← Volver al ejercicio](../a01-laboratorio-contenerizado.md#-ejercicio-8--sql-server-y-la-emulación)
