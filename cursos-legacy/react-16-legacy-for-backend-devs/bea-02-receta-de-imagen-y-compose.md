# 🐳 Apéndice bea-02 — Receta de imagen y compose

> Tutorial React 16 — Rifas y chances · **Track BE opcional 🔥** · Consulta rápida · ~3 horas
> Lo referencian: `be02` (Postgres en contenedor), `be03` y `be09`

---

Esto es **la receta**. Vienes a copiar algo que funcione, no a estudiar
contenedores: no hay teoría de imágenes, ni capítulo sobre capas, ni comparación
de runtimes. Hay dos archivos que puedes pegar, los comandos para levantarlos y
tumbarlos, y los cuatro errores que salen **siempre**, con su mensaje literal.

> 🧭 **Autocontención.** Todo lo que necesitas está acá. Este apéndice no remite
> a ningún otro curso del catálogo, exista o no uno de contenedores. Si algo no
> funciona siguiendo estos pasos, es un fallo de esta receta y hay que
> arreglarlo acá.

Lo único que damos por instalado es un runtime de Docker con `docker compose`. El
apéndice `A9` del track base ya cubre cómo tenerlo en cada sistema —incluido
Colima en Apple Silicon, que es la opción por defecto ahí— y esa parte no se
repite. Los comandos de abajo son idénticos con Colima o con Docker Desktop.

> 📝 **Relación con `A9`.** El `docker-compose.yml` de `A9` levanta el
> **frontend** (Node 14 y el mock del `3001`). El de acá levanta el **backend**
> (Go y Postgres). A partir de `be03` conviven: apagas el servicio `mock` de
> `A9` y levantas el `api` de acá, en el mismo puerto `3001`. Ese es el 🪦.

---

## 🧭 Índice de salto rápido

1. [Lo mínimo: solo Postgres](#1-lo-mínimo-solo-postgres)
2. [El `Dockerfile`, en sus dos versiones](#2-el-dockerfile-en-sus-dos-versiones)
3. [El `docker-compose.yml` completo](#3-el-docker-composeyml-completo)
4. [Variables por ambiente](#4-variables-por-ambiente)
5. [Comandos: arrancar, parar, resetear](#5-comandos-arrancar-parar-resetear)
6. [Los cuatro errores que salen siempre](#6-los-cuatro-errores-que-salen-siempre)
7. [🧩 Cuándo usar qué](#-cuándo-usar-qué)

---

## 1. Lo mínimo: solo Postgres

Durante `be02` no hace falta contenerizar el backend: lo corres con `go run` y
solo necesitas una base. Este es el comando, y es el que usarás durante seis
fases:

```bash
docker run -d --name rifas-pg \
  -e POSTGRES_USER=rifas \
  -e POSTGRES_PASSWORD=rifas \
  -e POSTGRES_DB=rifas \
  -p 5432:5432 \
  postgres:13

export DATABASE_URL="postgres://rifas:rifas@localhost:5432/rifas?sslmode=disable"
psql "$DATABASE_URL" -c 'select version();'
```

> ⚠️ **Si el `5432` ya está ocupado** —porque tienes un Postgres instalado en el
> sistema—, publica en otro puerto y ajusta la URL. Nada más cambia: la
> configuración por variables de entorno lo cubre entero.
>
> ```bash
> docker run -d --name rifas-pg … -p 5433:5432 postgres:13
> export DATABASE_URL="postgres://rifas:rifas@localhost:5433/rifas?sslmode=disable"
> ```
>
> El `-p 5433:5432` mapea **el puerto de tu máquina** al del contenedor: adentro
> Postgres sigue en el 5432, siempre.

Y la base de **pruebas**, que desde `be08` es un contenedor aparte:

```bash
docker run -d --name rifas-pg-test \
  -e POSTGRES_USER=rifas -e POSTGRES_PASSWORD=rifas -e POSTGRES_DB=rifas_test \
  -p 5434:5432 postgres:13

export TEST_DATABASE_URL="postgres://rifas:rifas@localhost:5434/rifas_test?sslmode=disable"
```

📖 **Dos contenedores y dos puertos es más barato que un susto.** La suite de
`be08` hace `TRUNCATE` antes de cada caso; apuntada a la base de desarrollo borra
seis fases de trabajo. Por eso el *helper* de `be08` se niega a correr si la URL
no menciona `rifas_test`.

---

## 2. El `Dockerfile`, en sus dos versiones

Y acá hay que explicar algo antes de copiar, porque **la receta cambia en
`be09`** y el motivo es contenido del curso.

Mientras el `import` del driver de SQLite esté en un archivo normal, **todo el
binario arrastra cgo** —aunque SQLite solo se use en pruebas— y un binario con
cgo enlaza contra la `libc` del sistema donde se compiló. En `be09` eso se
resuelve con una etiqueta de compilación y el binario pasa a ser estático.

| Versión | Cuándo | Runtime | Por qué |
|---|---|---|---|
| **A — con cgo** | `be02`–`be08` | `debian:bullseye-slim` | El binario necesita `glibc` |
| **B — estática** | desde `be09` | `distroless/static` | No necesita nada |

### Versión A — con cgo (`be02` a `be08`)

```dockerfile
# server/Dockerfile
# ---------- etapa 1: compilar ----------
FROM golang:1.19-bullseye AS builder
WORKDIR /src

# Las dependencias en su propia capa: cambian mucho menos que el código, así
# que Docker reutiliza esta capa en casi todas las construcciones. Copiar
# todo de una vez invalida la caché con cada edición y cada build tarda lo
# mismo que la primera.
COPY go.mod go.sum ./
RUN go mod download

COPY . .

# CGO_ENABLED=1 porque mattn/go-sqlite3 lo exige (D19). golang:1.19-bullseye
# ya trae gcc, así que no hay nada más que instalar.
RUN CGO_ENABLED=1 GOOS=linux go build -o /out/api ./cmd/api
RUN CGO_ENABLED=1 GOOS=linux go build -o /out/migrate ./cmd/migrate
RUN CGO_ENABLED=1 GOOS=linux go build -o /out/seed ./cmd/seed

# ---------- etapa 2: ejecutar ----------
# 🧭 debian:bullseye-slim y NO Alpine, y esto no es una preferencia.
#
# Alpine usa musl como libc; el builder de arriba es Debian y usa glibc. Un
# binario con cgo compilado contra glibc NO ARRANCA en Alpine, y el error es
# el peor que existe: "no such file or directory" sobre un binario que
# puedes ver, listar y que tiene permisos de ejecución. El archivo que no
# existe es la libc que el binario espera, no el binario.
#
# Se podría compilar sobre Alpine con musl-dev, pero entonces el binario no
# corre en Debian. Mientras haya cgo, builder y runtime tienen que compartir
# libc. Punto.
FROM debian:bullseye-slim

# ca-certificates: sin esto, cualquier llamada HTTPS de salida falla con
# "x509: certificate signed by unknown authority". Hoy el backend no hace
# ninguna, pero cuesta 200 KB y evita una tarde perdida.
# tzdata: las zonas horarias que be06 necesita.
RUN apt-get update \
 && apt-get install -y --no-install-recommends ca-certificates tzdata \
 && rm -rf /var/lib/apt/lists/*

# Usuario sin privilegios. Cuesta dos líneas y es lo mínimo exigible.
RUN useradd --uid 10001 --create-home rifas
USER rifas

COPY --from=builder /out/api /usr/local/bin/api
COPY --from=builder /out/migrate /usr/local/bin/migrate
COPY --from=builder /out/seed /usr/local/bin/seed
COPY --from=builder /src/migrations /migrations

EXPOSE 3001
ENTRYPOINT ["/usr/local/bin/api"]
```

### Versión B — estática (desde `be09`)

Cuando `be09` mete el driver de SQLite detrás de `//go:build sqlite`, el binario
de producción ya no necesita cgo y el runtime puede ser una imagen prácticamente
vacía:

```dockerfile
FROM golang:1.19-bullseye AS builder
WORKDIR /src
COPY go.mod go.sum ./
RUN go mod download
COPY . .

# Sin cgo → binario estático. -ldflags "-s -w" quita símbolos e información
# de depuración: unos megas menos, a cambio de perder los nombres en los
# stack traces del pánico de be01. Es un intercambio real, no gratis.
RUN CGO_ENABLED=0 GOOS=linux go build -ldflags "-s -w" -o /out/api ./cmd/api
RUN CGO_ENABLED=0 GOOS=linux go build -o /out/migrate ./cmd/migrate
RUN CGO_ENABLED=0 GOOS=linux go build -o /out/seed ./cmd/seed

# Sin shell, sin gestor de paquetes, sin libc. ~2 MB, y trae los
# certificados raíz y un usuario nonroot ya definido.
FROM gcr.io/distroless/static-debian11:nonroot
COPY --from=builder /out/api /api
COPY --from=builder /out/migrate /migrate
COPY --from=builder /out/seed /seed
COPY --from=builder /src/migrations /migrations
USER nonroot:nonroot
EXPOSE 3001
ENTRYPOINT ["/api"]
```

> ⚠️ **La versión B necesita `import _ "time/tzdata"` en `main.go`.** Una imagen
> vacía no tiene `/usr/share/zoneinfo`, así que `time.LoadLocation("America/Bogota")`
> devuelve `unknown time zone` **solo dentro del contenedor**. Funciona perfecto
> en tu máquina y falla en el despliegue. El import embebe la base de zonas en el
> binario (unos 450 KB) y existe desde Go 1.15.

Y el archivo que evita construcciones lentas y filtraciones tontas:

```gitignore
# server/.dockerignore
.git
*_test.go
evidence/
*.db
.env
```

---

## 3. El `docker-compose.yml` completo

El laboratorio entero del backend. La aplicación React sigue fuera, en el `3000`,
hablándole al `3001` exactamente como desde `be03`.

```yaml
# server/docker-compose.yml
services:
  db:
    image: postgres:13
    environment:
      POSTGRES_USER: rifas
      POSTGRES_PASSWORD: rifas
      POSTGRES_DB: rifas
    ports: ["5432:5432"]        # cámbialo a "5433:5432" si el 5432 está ocupado
    volumes:
      # Volumen NOMBRADO y no un directorio del proyecto: los datos
      # sobreviven a `down` y no ensucian tu repositorio. Para borrarlos de
      # verdad hace falta `down -v`, que es justo la fricción que quieres
      # antes de destruir una base.
      - rifas-pgdata:/var/lib/postgresql/data
    healthcheck:
      # Sin esto, migrate arranca contra un Postgres que todavía se está
      # inicializando y falla. `depends_on` a secas solo espera a que el
      # CONTENEDOR exista, no a que el servicio esté listo: es el error nº 4.
      test: ["CMD-SHELL", "pg_isready -U rifas -d rifas"]
      interval: 2s
      timeout: 3s
      retries: 15

  migrate:
    build: .
    entrypoint: ["/usr/local/bin/migrate", "up"]   # "/migrate" en la versión B
    environment:
      DATABASE_URL: postgres://rifas:rifas@db:5432/rifas?sslmode=disable
    depends_on:
      db: { condition: service_healthy }
    restart: "no"                # corre una vez y termina; no es un servicio

  api:
    build: .
    ports: ["3001:3001"]
    environment:
      # "db" y NO "localhost": dentro de un contenedor, localhost es el
      # propio contenedor. Los servicios se resuelven por su nombre.
      DATABASE_URL: postgres://rifas:rifas@db:5432/rifas?sslmode=disable
      ALLOWED_ORIGIN: http://localhost:3000
      JWT_SECRET: laboratorio-no-usar-esto-en-ningun-otro-lado-32
      JWT_TTL: 12h
      CHAOS_LEVEL: "off"
      SQL_DEBUG: "true"
    depends_on:
      # Espera a que las migraciones TERMINEN, no a que arranquen.
      migrate: { condition: service_completed_successfully }

volumes:
  rifas-pgdata:
```

---

## 4. Variables por ambiente

Una sola imagen para todos los ambientes; lo que cambia va por configuración. Una
imagen "de QA" y otra "de producción" significan que lo que probaste no es lo que
desplegaste.

| Variable | Desarrollo | QA | UAT | Producción |
|---|---|---|---|---|
| `DATABASE_URL` | local | de QA | de UAT | de producción |
| `sslmode` | `disable` | `require` | `require` | `require` |
| `ALLOWED_ORIGIN` | `http://localhost:3000` | el de QA | el de UAT | el real |
| `JWT_SECRET` | el del compose | secreto de QA | secreto de UAT | secreto real |
| `JWT_TTL` | `12h` | `12h` | `1h` | `1h` |
| `CHAOS_LEVEL` | `low` | `high` | `off` | `off` ⚠️ |
| `SQL_DEBUG` | `true` | `true` | `false` | `false` |
| `PORT` | `3001` | `3001` | `3001` | `3001` |

En desarrollo, todo eso vive en el `compose`. Para los demás ambientes, un
archivo por ambiente que **no se versiona**:

```bash
# server/.env.uat  (en .gitignore, siempre)
DATABASE_URL=postgres://…?sslmode=require
JWT_SECRET=…
JWT_TTL=1h
CHAOS_LEVEL=off
```

```bash
docker run --env-file .env.uat -p 3001:3001 rifas/raffles-api:<sha>
```

> ⚠️ **`CHAOS_LEVEL=off` no es suficiente para producción.** Una ruta
> `POST /_chaos` en un binario de producción es un endpoint para romper tu propio
> sistema, expuesto a quien lo encuentre. La respuesta correcta es que **ese
> código no esté en el binario**, con una etiqueta de compilación. Es el ejercicio
> 24 de `be09`.
>
> 💸 Y un recordatorio que vale para siempre: **una capa de imagen conserva lo que
> borraste en la capa siguiente**. Un secreto copiado y luego eliminado sigue en
> el historial de la imagen y se puede extraer. Los secretos se inyectan, nunca
> se copian.

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
cd .. && ./server/smoke.sh         # el checklist de be00, sin modificar

# --- sembrar desde TU db.json (be03) ---
docker compose run --rm api /usr/local/bin/seed -file /mock/db.json
# ⚠️ el seed necesita ver el archivo: agrega al servicio api
#    volumes: ["../mock:/mock:ro"]

# --- parar ---
docker compose stop                # para, conserva contenedores y datos
docker compose down                # elimina contenedores, CONSERVA el volumen
docker compose down -v             # elimina TAMBIÉN los datos ⚠️ sin vuelta

# --- resetear la base sin borrar todo ---
docker compose exec db psql -U rifas -d rifas -c \
  'DROP SCHEMA public CASCADE; CREATE SCHEMA public;'
docker compose run --rm migrate

# --- entrar a mirar ---
docker compose exec db psql -U rifas -d rifas
#   \dt          las tablas
#   \d raffles   la definición de una tabla
#   \q           salir

# --- ver el tamaño de lo que construiste (be09) ---
docker images | grep raffles-api
```

---

## 6. Los cuatro errores que salen siempre

### 6.1 `no such file or directory` sobre un binario que existe

```
exec /usr/local/bin/api: no such file or directory
```

**Causa.** Binario con cgo compilado contra `glibc` ejecutándose en Alpine
(`musl`). El archivo que falta es la biblioteca, no el binario.

**Cómo confirmarlo.**

```bash
docker run --rm --entrypoint file <imagen> /usr/local/bin/api
# "dynamically linked, interpreter /lib64/ld-linux-x86-64.so.2" → tiene cgo
# "statically linked"                                          → no lo tiene
```

**Arreglo.** Runtime `debian:bullseye-slim` (versión A), o quitar cgo con la
etiqueta de compilación (versión B). Nunca mezclar builder Debian con runtime
Alpine mientras haya cgo.

### 6.2 `connection refused` contra la base

```
la base no responde (postgres): dial tcp 127.0.0.1:5432: connect: connection refused
```

**Causa.** `localhost` dentro de un contenedor **es ese contenedor**. Postgres
está en otro.

**Arreglo.** El nombre del servicio: `postgres://rifas:rifas@db:5432/rifas`. La
misma URL con `localhost` es la correcta cuando corres el backend con `go run`
fuera de Docker — y por eso el error aparece justo al contenerizar algo que
funcionaba.

### 6.3 La base no está lista todavía

```
error: dial tcp 172.18.0.2:5432: connect: connection refused
# …y a la segunda vez funciona
```

**Causa.** `depends_on` sin `condition` solo espera a que el contenedor **exista**.
Postgres tarda unos segundos en inicializarse la primera vez, así que el fallo es
intermitente — el peor tipo.

**Arreglo.** El `healthcheck` del §3 más `condition: service_healthy`. Compruébalo
levantando diez veces seguidas con `down -v` en medio.

### 6.4 `exec format error`

```
exec /api: exec format error
```

**Causa.** Arquitectura equivocada: imagen construida para `arm64` (un Mac con
Apple Silicon) ejecutándose en `amd64`, o al revés.

**Arreglo.** Fijar la plataforma al construir:

```bash
docker build --platform linux/amd64 -t rifas/raffles-api .
```

Y prepárate: construir emulado tarda bastante más. Si vas a hacerlo seguido, mide
cuánto y decide si prefieres construir nativo y publicar un manifiesto múltiple
(ejercicio 🔥 de `be09`).

### Bonus — `unknown time zone America/Bogota`

Solo con la versión B, y solo dentro del contenedor. Falta `import _ "time/tzdata"`
en `main.go`. Ver §2.

---

## 🧩 Cuándo usar qué

| Si estás en… | Levanta | Con |
|---|---|---|
| `be02` (capa de datos) | solo Postgres | `docker run` del §1 |
| `be03`–`be08` (desarrollo) | Postgres + `go run` del backend | §1 y `go run ./cmd/api` |
| `be08` (pruebas) | un Postgres **aparte** | el `rifas-pg-test` del §1 |
| `be09` (empaquetado) | todo en contenedores | el `compose` del §3, Dockerfile B |
| Enseñarle el laboratorio a alguien | todo en contenedores | `docker compose up -d --build` |

| Si necesitas… | Usa | Y no |
|---|---|---|
| Parar y seguir mañana | `docker compose stop` | `down -v` |
| Empezar de cero con los datos | `down -v` y volver a sembrar | borrar tablas a mano |
| Runtime con cgo | `debian:bullseye-slim` | Alpine |
| Runtime sin cgo | `distroless/static` | Debian |
| Hablarle a la base desde otro contenedor | el nombre del servicio | `localhost` |
| Esperar a que la base esté lista | `healthcheck` + `condition` | un `sleep` |
| Guardar un secreto | variable de entorno inyectada | `COPY` al Dockerfile |

---

## 🧪 Ejercicios (8)

1. **🟢** Levanta Postgres con `docker run`, conéctate con `psql` y comprueba la versión.
2. **🟢** Construye la imagen (versión A) y comprueba que `GET /health` responde desde el contenedor.
3. **🟡** Levanta el compose completo y comprueba que la aplicación React del `3000` funciona contra él sin cambiar un archivo.
4. **🟡** Ejecuta `./server/smoke.sh` con `BASE_URL` apuntando al contenedor y confirma que pasa entero.
5. **🟠 Diagnóstico.** Cambia el runtime a `alpine:3.17` con la versión A y provoca el error 6.1. Confírmalo con `file` y explica qué biblioteca falta.
6. **🟠 Diagnóstico.** Quita el `healthcheck` y levanta diez veces con `down -v` en medio. Cuenta cuántas fallan y explica por qué el fallo es intermitente.
7. **🟠** Invierte el orden de los `COPY` en el Dockerfile y mide el tiempo de dos construcciones consecutivas con y sin ese cambio.
8. **🔴 Diagnóstico.** Construye la versión B sin `import _ "time/tzdata"`, llama desde dentro del contenedor a algo que use `time.LoadLocation`, y documenta por qué el mismo código funciona fuera. Después arréglalo y verifica.

---

## 📚 Referencias

**Documentación oficial**
- https://docs.docker.com/build/building/multi-stage/ — el patrón del §2.
- https://docs.docker.com/reference/dockerfile/ — la referencia completa de instrucciones.
- https://docs.docker.com/compose/compose-file/05-services/#depends_on — `condition`, que es el error 6.3.
- https://docs.docker.com/compose/compose-file/05-services/#healthcheck — la otra mitad del mismo error.
- https://hub.docker.com/_/postgres — variables de entorno de la imagen de Postgres y qué hace en el primer arranque.
- https://github.com/GoogleContainerTools/distroless — qué traen y qué no las imágenes mínimas de la versión B.
- https://pkg.go.dev/time/tzdata — el import de una línea del bonus del §6.
- https://docs.docker.com/build/building/best-practices/ — el orden de las capas del ejercicio 7.

**Video / apoyo**
- Busca "multi-stage docker build Go" y "static vs dynamic linking cgo". Lo segundo aclara el error 6.1 mejor que cualquier texto.

**Orden de lectura sugerido:** nada, si lo que quieres es levantar el laboratorio
— copia el §1 y sigue con tu fase. Cuando algo falle, salta al §6, que está
ordenado por frecuencia. La página de multi-stage vale la pena solo cuando
llegues a `be09` y quieras entender qué estás copiando.

> ⚠️ **Esta es el área del curso que más rápido envejece.** Las etiquetas de
> imagen se mueven, la sintaxis del `compose` evoluciona y las buenas prácticas
> de Docker cambian cada pocos años. Verifica cada URL y cada etiqueta antes de
> apoyarte en ellas. Las versiones fijas del track —`postgres:13`,
> `golang:1.19`— salen de `prompts/decisiones-y-versiones.md` §7 y esas sí no se
> mueven.

---

> 🏷️ **Este apéndice sí deja código.** El `Dockerfile`, el `.dockerignore` y el
> `docker-compose.yml` viven en `server/`. Cuando los tengas funcionando:
>
> ```bash
> git tag -a apendice-bea-02-receta-de-imagen-y-compose -m "bea-02: \
> Dockerfile multi-stage (versión con cgo), .dockerignore y docker-compose.yml \
> con Postgres 13, migraciones como paso previo y healthcheck; \
> smoke.sh pasando contra el contenedor"
> ```
>
> Los commits van con el prefijo de la fase desde la que llegaste (`be02: …`,
> `be09: …`), no con el del apéndice. La convención completa está en
> [`00-convencion-de-git-y-tags.md`](00-convencion-de-git-y-tags.md).
