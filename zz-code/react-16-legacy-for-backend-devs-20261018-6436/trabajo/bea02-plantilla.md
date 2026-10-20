# 🐳 Apéndice bea-02 — Receta de imagen y compose

> Tutorial React 16 — La Esclusa, la consola de Jewel Locks · **Track BE opcional 🔥** · Consulta rápida · ~3 horas
> Lo referencian: `be02` (Postgres en contenedor), `be03` y `be09`

---

Esto es **la receta**. Vienes a copiar algo que funcione, no a estudiar contenedores: no hay teoría de imágenes, ni capítulo sobre capas, ni comparación de runtimes. Hay los archivos que puedes pegar, los comandos para levantarlos y tumbarlos, y los errores que salen **siempre**, con su mensaje literal.

> 🧭 **Autocontención.** Todo lo que necesitas está acá. Este apéndice no remite a ningún otro curso del catálogo. Si algo no funciona siguiendo estos pasos, es un fallo de esta receta y hay que arreglarlo acá.

Lo único que damos por instalado es un runtime de Docker con `docker compose`. El apéndice `A9` del track base cubre cómo tenerlo en cada sistema —incluido Colima en Apple Silicon— y esa parte no se repite. Los comandos de abajo son los mismos con Colima o con Docker Desktop.

> 📝 **Relación con `A9`.** El compose de `A9` levanta la **consola** (Node 14 y los mocks). El de acá levanta el **backend** (Go y Postgres). A partir de `be03` conviven: apagas el mock del `3001` y levantas el `api` de acá, en el mismo puerto. Ese es el 🪦. El mock de Google Play del `3002` sigue siendo el de la consola.

---

## 🧭 Índice de salto rápido

1. [Lo mínimo: solo Postgres](#1-lo-mínimo-solo-postgres)
2. [El `Dockerfile`, en sus dos versiones](#2-el-dockerfile-en-sus-dos-versiones)
3. [El `docker-compose.yml`](#3-el-docker-composeyml)
4. [Variables por ambiente](#4-variables-por-ambiente)
5. [Comandos: arrancar, parar, resetear](#5-comandos-arrancar-parar-resetear)
6. [Los errores que salen siempre](#6-los-errores-que-salen-siempre)
7. [🧩 Cuándo usar qué](#-cuándo-usar-qué)

---

## 1. Lo mínimo: solo Postgres

Durante `be02` no hace falta contenerizar el backend: lo corres con `go run` y solo necesitas una base. Este es el comando, y es el que usarás durante siete fases:

```bash
docker run -d --name esclusa-pg \
  -e POSTGRES_USER=esclusa \
  -e POSTGRES_PASSWORD=esclusa \
  -e POSTGRES_DB=esclusa \
  -p 5432:5432 \
  postgres:13

export DATABASE_URL="postgres://esclusa:esclusa@localhost:5432/esclusa?sslmode=disable"
psql "$DATABASE_URL" -c 'select version();'
```

> ⚠️ **Si el `5432` ya está ocupado** —porque tienes un Postgres instalado en el sistema—, publica en otro puerto y ajusta la URL. Nada más cambia:
>
> ```bash
> docker run -d --name esclusa-pg … -p 5433:5432 postgres:13
> export DATABASE_URL="postgres://esclusa:esclusa@localhost:5433/esclusa?sslmode=disable"
> ```
>
> El `-p 5433:5432` mapea **el puerto de tu máquina** al del contenedor: adentro Postgres sigue en el 5432, siempre.

Y la base de **pruebas**. Desde `be05` las pruebas de concurrencia la necesitan, y desde `be08` es obligatoria. Puede vivir en el mismo contenedor:

```bash
psql "$DATABASE_URL" -c 'CREATE DATABASE esclusa_test;'
export TEST_DATABASE_URL="postgres://esclusa:esclusa@localhost:5432/esclusa_test?sslmode=disable"
```

📖 **Una base de pruebas con otro nombre es más barata que un susto.** La suite de `be08` borra y recrea el esquema en cada caso; apuntada a la base de desarrollo, borra siete fases de trabajo. Por eso su *helper* se niega a correr si la URL no nombra `esclusa_test`.

---

## 2. El `Dockerfile`, en sus dos versiones

Hay que explicar algo antes de copiar, porque **la receta cambia en `be09`** y el motivo es contenido del curso.

Mientras el `import` del driver de SQLite esté en un archivo normal, **todo el binario arrastra cgo** —aunque SQLite solo se use en pruebas—, y un binario con cgo enlaza contra la `libc` del sistema donde se compiló. En `be09` eso se resuelve con una etiqueta de compilación y el binario pasa a ser estático.

| Versión | Cuándo | Imagen de ejecución | Por qué | Tamaño medido |
|---|---|---|---|---|
| **A — con cgo** | `be02`–`be08` | distroless *base* (con glibc) | el binario necesita la `glibc` de `golang:1.19.13` (Debian 12) | 81,3 MB |
| **B — estática** | desde `be09` | distroless *static* | no necesita nada | 21 MB |

Las dos imágenes base van fijadas por digest (`D38`): una etiqueta como `nonroot` se mueve, y *"la imagen de ayer"* tiene que ser la de ayer.

### Versión A — con cgo (`be02` a `be08`)

<<<archivo:server/Dockerfile>>>

Antes de `be09` no hay un binario de migraciones propio: el compose usa la imagen oficial de golang-migrate, en la versión de `D20` (§3).

### Versión B — estática (desde `be09`)

{{B_DOCKERFILE}}

`be09` le agrega `cmd/migrate`, que entra en la misma imagen.

> 📝 **¿Hace falta `import _ "time/tzdata"`?** Medido: distroless *static* trae la base de zonas (`time.LoadLocation("America/Panama")` funciona), y `scratch` no (*"unknown time zone America/Panama"*). Y este backend no carga zonas: la de presentación la pone Postgres (`be06`). Solo hace falta si construyes sobre `scratch` y el código llama a `LoadLocation` (§6, el bonus).

Y el archivo que evita construcciones lentas y filtraciones tontas:

<<<archivo:server/.dockerignore>>>

---

## 3. El `docker-compose.yml`

El backend entero de la versión A. La consola sigue fuera, en el `3000`, hablándole al `3001` exactamente como desde `be03`.

<<<archivo:server/docker-compose.yml>>>

Desde `be09` el servicio `migrate` usa el binario propio de la imagen (`entrypoint: ["/migrate", "up"]`) y el API comprueba la versión del esquema al arrancar; el compose de `be09` §5.4 es esa versión.

---

## 4. Variables por ambiente

Una sola imagen para todos los ambientes; lo que cambia va por configuración. La tabla completa está en `be09` §4.3. En desarrollo, todo vive en el compose. Para los demás ambientes, un archivo por ambiente que **no se versiona**:

```bash
# server/.env.uat  (en .gitignore, siempre)
DATABASE_URL=postgres://…?sslmode=require
JWT_SECRET=…
JWT_TTL=1h
CHAOS_LEVEL=off
PLAY_URL=…
```

```bash
docker run --env-file .env.uat -p 3001:3001 esclusa-api:<sha>
```

> ⚠️ **`CHAOS_LEVEL=off` no es suficiente para producción.** Una ruta `POST /_chaos` en un binario de producción es un endpoint para romper tu propio sistema. La respuesta correcta es que ese código **no esté en el binario**, con una etiqueta de compilación, como SQLite en `be09`. Es el ejercicio 24 de `be09`.
>
> 💸 Y un recordatorio que vale para siempre: **una capa de imagen conserva lo que borraste en la capa siguiente**. Un secreto copiado y luego eliminado sigue en el historial de la imagen. Los secretos se inyectan, nunca se copian.

---

## 5. Comandos: arrancar, parar, resetear

```bash
cd server

# --- levantar ---
docker compose up -d --build       # construye y levanta en segundo plano
docker compose ps                  # qué está corriendo y con qué salud
docker compose logs -f api         # seguir los logs del backend

# --- verificar que funciona ---
curl -i localhost:3001/health
cd .. && ./server/smoke.sh         # el checklist de contrato, sin modificar

# --- sembrar desde TU db.json (be03) ---
docker compose exec api /seed -file /mock/db.json   # el compose monta ../mock en /mock

# --- parar ---
docker compose stop                # para, conserva contenedores y datos
docker compose down                # elimina contenedores, CONSERVA el volumen
docker compose down -v             # elimina TAMBIÉN los datos ⚠️ sin vuelta

# --- resetear la base sin borrar todo ---
docker compose exec db psql -U esclusa -d esclusa -c \
  'DROP SCHEMA public CASCADE; CREATE SCHEMA public;'
docker compose run --rm migrate

# --- entrar a mirar ---
docker compose exec db psql -U esclusa -d esclusa
#   \dt          las tablas
#   \d wheels    la definición de una tabla
#   \q           salir

# --- el tamaño de lo que construiste ---
docker image ls | grep api
```

Medido con la versión A, en la rama del apéndice: `docker compose up -d --build` en 50 s (la mayor parte, compilar el SQLite en C), `migrate` hasta la versión del esquema de `be03`, la siembra en 161 ms y `smoke.sh` en verde contra el contenedor.

---

## 6. Los errores que salen siempre

### 6.1 `no such file or directory` sobre un binario que existe

```text
exec /api: no such file or directory
```

**Causa.** Un binario con cgo, compilado contra la `glibc` de `golang:1.19.13`, en una imagen que no la tiene: distroless *static*, `scratch` o Alpine (`musl`). El archivo que falta es la biblioteca, no el binario. Es el incidente `be-16`.

**Cómo confirmarlo.** Compila el mismo binario fuera de la imagen, en `golang:1.19.13`, y pregúntale:

```bash
ldd /tmp/api
#   libc.so.6 => /lib/aarch64-linux-gnu/libc.so.6   → tiene cgo
#   not a dynamic executable                         → no lo tiene
```

**Arreglo.** La versión A (imagen con `glibc`) mientras haya cgo, o quitar cgo con la etiqueta de `be09` (versión B). Nunca una imagen sin `glibc` para un binario con cgo.

### 6.2 `connection refused` contra la base

```text
no se pudo abrir la base: la base no responde (postgres): dial tcp [::1]:5432: connect: connection refused
```

**Causa.** `localhost` dentro de un contenedor **es ese contenedor** (el `[::1]` es su `localhost` en IPv6). Postgres está en otro.

**Arreglo.** El nombre del servicio: `postgres://esclusa:esclusa@db:5432/esclusa`. La misma URL con `localhost` es la correcta cuando corres el backend con `go run` fuera de Docker, y por eso el error aparece justo al contenerizar algo que funcionaba.

### 6.3 La base no está lista todavía

```text
error: dial tcp 172.24.0.5:5432: connect: connection refused
```

**Causa.** `depends_on` sin `condition` solo espera a que el contenedor **exista**. Postgres tarda unos segundos en inicializarse, y `migrate` arranca antes. Medido sin `healthcheck`, levantando cinco veces con `down -v` en medio: **cinco de cinco** fallaron. No es intermitente: con una base nueva, falla siempre.

**Arreglo.** El `healthcheck` del §3 más `condition: service_healthy`.

### 6.4 `exec format error`

```text
exec /api: exec format error
```

**Causa.** Arquitectura equivocada: una imagen construida para `arm64` (un Mac con Apple Silicon) ejecutándose en `amd64`, o al revés. Docker Desktop emula la otra arquitectura, y en el laboratorio del autor el error no apareció: no verificado por ejecución.

**Arreglo.** Fijar la plataforma al construir:

```bash
docker build --platform linux/amd64 -t esclusa-api .
```

Y prepárate: construir emulado tarda bastante más.

### Bonus — `unknown time zone America/Panama`

Solo en `scratch`, y solo si el código llama a `time.LoadLocation`. Medido con un programa de tres líneas: en distroless *static*, `<nil>`; en `scratch`, *"unknown time zone America/Panama"*. Se arregla con `import _ "time/tzdata"`, que embebe la base en el binario (unos 390 KB con Go 1.19.13).

---

## 🧩 Cuándo usar qué

| Si estás en… | Levanta | Con |
|---|---|---|
| `be02` (capa de datos) | solo Postgres | el `docker run` del §1 |
| `be03`–`be07` (desarrollo) | Postgres y `go run` del backend | §1 y `go run ./cmd/api` |
| `be08` (pruebas) | la base `esclusa_test` | §1 |
| `be09` (empaquetado) | todo en contenedores | el compose de `be09`, Dockerfile B |
| Enseñarle el laboratorio a alguien | todo en contenedores | `docker compose up -d --build` |

| Si necesitas… | Usa | Y no |
|---|---|---|
| Parar y seguir mañana | `docker compose stop` | `down -v` |
| Empezar de cero con los datos | `down -v` y volver a sembrar | borrar tablas a mano |
| Imagen para un binario con cgo | distroless *base* (glibc) | *static*, `scratch` o Alpine |
| Imagen para un binario sin cgo | distroless *static* | una con shell y gestor de paquetes |
| Hablarle a la base desde otro contenedor | el nombre del servicio | `localhost` |
| Esperar a que la base esté lista | `healthcheck` + `condition` | un `sleep` |
| Guardar un secreto | variable de entorno inyectada | `COPY` al Dockerfile |

---

## 🧪 Ejercicios (8)

1. **🟢** Levanta Postgres con `docker run`, conéctate con `psql` y comprueba la versión.
2. **🟢** Construye la imagen de la versión A y comprueba que `GET /health` responde desde el contenedor.
3. **🟡** Levanta el compose completo y comprueba que la consola del `3000` funciona contra él sin cambiar un archivo.
4. **🟡** Ejecuta `./server/smoke.sh` con `BASE_URL` apuntando al contenedor y confirma que pasa entero.
5. **🟠 Diagnóstico.** Cambia la imagen de ejecución de la versión A por distroless *static* y provoca el error 6.1. Confírmalo con `ldd` y explica qué biblioteca falta.
6. **🟠 Diagnóstico.** Quita el `healthcheck` y levanta cinco veces con `down -v` en medio. Cuenta cuántas fallan y explica por qué.
7. **🟠** Invierte el orden de los `COPY` en el Dockerfile y mide el tiempo de dos construcciones consecutivas con y sin ese cambio.
8. **🔴 Diagnóstico.** Construye un programa que llame a `time.LoadLocation("America/Panama")` sobre `scratch` y sobre distroless *static*, sin y con `import _ "time/tzdata"`. Documenta los cuatro resultados y por qué el mismo código funciona fuera del contenedor.

---

## 📚 Referencias

**Documentación oficial**
- https://docs.docker.com/build/building/multi-stage/ — el patrón del §2.
- https://docs.docker.com/reference/dockerfile/ — la referencia completa de instrucciones.
- https://docs.docker.com/compose/compose-file/05-services/#depends_on — `condition`, el error 6.3.
- https://docs.docker.com/compose/compose-file/05-services/#healthcheck — la otra mitad del mismo error.
- https://hub.docker.com/_/postgres — las variables de la imagen de Postgres y qué hace en el primer arranque.
- https://hub.docker.com/r/migrate/migrate — la imagen de golang-migrate del §3.
- https://github.com/GoogleContainerTools/distroless — qué traen *static* y *base*.
- https://pkg.go.dev/time/tzdata — el import del bonus.

**Video / apoyo**
- Busca "multi-stage docker build Go" y "static vs dynamic linking cgo". Lo segundo aclara el error 6.1 mejor que cualquier texto.

**Orden de lectura sugerido:** nada, si lo que quieres es levantar el laboratorio: copia el §1 y sigue con tu fase. Cuando algo falle, salta al §6. La página de multi-stage vale la pena cuando llegues a `be09`.

> ⚠️ **Esta es el área del curso que más rápido envejece.** Las etiquetas de imagen se mueven, la sintaxis del compose evoluciona y las buenas prácticas cambian cada pocos años. Verifica cada URL antes de apoyarte en ella. Las versiones fijas del track —`postgres:13`, `golang:1.19.13`, los digest de distroless, `migrate/migrate:v4.15.2`— salen de `00-decisiones-y-versiones.md` §7, y esas no se mueven. Las cifras son de las corridas del 20/10/2026 en la máquina del autor (arm64).

---

> 🏷️ **Este apéndice sí deja código.** El `Dockerfile`, el `.dockerignore` y el `docker-compose.yml` de la versión A viven en `server/`. Cuando los tengas funcionando:
>
> ```bash
> git tag -a apendice-bea-02-receta-de-imagen-y-compose -m "bea-02: \
> Dockerfile multi-stage con cgo (versión A), .dockerignore y docker-compose.yml \
> con Postgres 13, migraciones como paso previo y healthcheck; \
> smoke.sh pasando contra el contenedor"
> ```
>
> Los commits van con el prefijo de la fase desde la que llegaste (`be02: …`, `be09: …`), no con el del apéndice. La convención completa está en [`00-convencion-de-git-y-tags.md`](00-convencion-de-git-y-tags.md).
