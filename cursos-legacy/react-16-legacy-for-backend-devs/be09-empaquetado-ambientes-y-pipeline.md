# 📦 Fase be09 — Empaquetado, ambientes y pipeline

> Tutorial React 16 — Rifas y chances · **Track BE opcional 🔥** · Fase be09 de be09 · **8 horas**
> Depende de: be08 — hay una suite que puede correr en CI · Habilita: nada. **Cierra el track.**

---

## 🎯 1. Propósito

Convertir el binario que corre en tu máquina en algo que se puede desplegar: una
imagen construida de forma reproducible, configurada por ambiente, con las
migraciones aplicadas cuando corresponde, y un pipeline que compila, prueba
contra los dos motores y publica.

Y cerrar el track con lo que el curso entero viene practicando: **un veredicto
honesto**. Qué quedó mejor que el mock, qué quedó peor, qué deudas siguen vivas
—porque siguen— y en qué situaciones reemplazar un mock por un backend propio
**no vale la pena**.

Hay además una decisión que `D19` dejó abierta desde `be02` y que se paga acá,
midiendo y no opinando: **cgo contra Go puro**, en tamaño de imagen y tiempo de
compilación. Llevas seis fases sintiendo el peso de `CGO_ENABLED=1`; toca ponerle
números.

> 🧭 **Autocontención, y acá es crítico.** Esta fase **no remite a ningún otro
> curso del catálogo**, exista o no uno de contenedores. Todo lo necesario para
> construir la imagen y el pipeline vive acá y en `bea-02`, escrito como receta
> cerrada y verificable de principio a fin.

---

## ✅ 2. Qué queda listo al terminar

- [ ] `server/Dockerfile` multi-stage produce una imagen que arranca y responde
      `GET /health`.
- [ ] La medición de `D19` está hecha y escrita en `server/evidence/imagen.md`:
      tamaño y tiempo de compilación con cgo y sin cgo, con la decisión tomada y
      justificada con esos números.
- [ ] `docker-compose.yml` levanta backend, Postgres y migraciones, y la
      aplicación React del `3000` funciona contra eso sin cambiar nada.
- [ ] La configuración de los **cuatro ambientes** —desarrollo, QA, UAT y
      producción— está resuelta por variables de entorno, con la lista completa
      de qué cambia en cada uno.
- [ ] Está decidido y justificado si las migraciones corren al arrancar o como
      paso previo del despliegue, **y son distintas en desarrollo y en
      producción**.
- [ ] `.github/workflows/ci.yml` compila, corre los cinco niveles de `be08`
      contra los dos motores y publica la imagen.
- [ ] La separación de edades está explicada en el propio workflow: acciones de
      hoy ejecutando Go de 2022.
- [ ] Existe `server/VEREDICTO.md` con el cierre honesto del track.
- [ ] `./server/smoke.sh` pasa **contra el contenedor**, no solo contra
      `go run`.

---

## 🚫 3. Qué queda fuera por ahora

- **Orquestación y Kubernetes.** Un `docker-compose` y una imagen bien construida
  son el límite del track. Lo demás son decisiones de infraestructura que no
  enseñan nada nuevo sobre este sistema.
- **Despliegue real a un proveedor.** No hay nube, no hay cuenta, no hay tarjeta.
  El pipeline publica la imagen y ahí termina.
- **Observabilidad completa.** Métricas, trazas distribuidas y alertas quedan
  fuera. Lo que sí hay —el `X-Request-Id` recorriendo el sistema entero— se
  construyó en `be01` y se usó en todas las fases.
- **Secretos de verdad.** Se usan variables de entorno y los secretos del
  repositorio. Un gestor de secretos es otra conversación, apuntada en
  `bea-08`.

---

## 🧠 4. Conceptos mínimos

### 4.1 Multi-stage: por qué la imagen final no lleva compilador

Compilar necesita el toolchain de Go, las fuentes y el módulo entero:
aproximadamente un gigabyte. **Ejecutar** necesita un binario. Un `Dockerfile`
multi-stage hace las dos cosas en la misma receta y descarta la primera etapa.

Y no es solo tamaño. Una imagen sin compilador, sin `git`, sin intérprete y sin
gestor de paquetes tiene una superficie de ataque muchísimo menor: quien
consiguiera ejecutar algo dentro no tendría con qué. Es la razón por la que las
imágenes mínimas se llaman *distroless*.

### 4.2 La cuestión cgo, que ya sufriste

`mattn/go-sqlite3` es una envoltura sobre la biblioteca de C de SQLite y exige
`CGO_ENABLED=1`. Eso arrastra tres consecuencias que llevas seis fases
padeciendo:

- **Compilación lenta**, porque hay que compilar C.
- **El binario deja de ser estático**: enlaza contra la `libc` del sistema donde
  se compiló. Un binario compilado sobre Debian (`glibc`) **no corre** en Alpine
  (`musl`), y el error —`no such file or directory` sobre un binario que
  claramente existe— es de los más desconcertantes que hay.
- **Adiós compilación cruzada.** Construir para `linux/amd64` desde un Mac con
  Apple Silicon deja de ser gratis.

Antes de elegir entre `mattn` y `modernc.org/sqlite`, conviene notar algo que
cambia la pregunta entera:

> 🧠 **SQLite solo se usa en pruebas.** El binario de producción no lo necesita
> jamás. Si el `import _ "github.com/mattn/go-sqlite3"` está en un archivo
> normal, arrastra cgo a **todas** las compilaciones, incluida la de producción,
> por un driver que allí no se usa nunca.
>
> La solución no es cambiar de driver: es **etiquetar la compilación** para que el
> driver de pruebas solo entre cuando se pide.

`D19` pide medir, y lo que se mide entonces son tres escenarios: con cgo, sin cgo
mediante etiqueta de compilación, y con `modernc.org/sqlite` (Go puro, que no
necesita etiqueta pero es más lento en ejecución). La decisión sale de los
números, no del gusto.

### 4.3 Cuatro ambientes, una imagen

La regla es vieja y sigue siendo la correcta: **la misma imagen en todos los
ambientes, y todo lo que cambia va por configuración**. Una imagen "de QA" y otra
"de producción" significan que lo que probaste no es lo que desplegaste.

| Variable | Desarrollo | QA | UAT | Producción |
|---|---|---|---|---|
| `DATABASE_URL` | local | de QA | de UAT | de producción |
| `CHAOS_LEVEL` | `low` | `high` | `off` | `off` (y ver abajo) |
| `JWT_SECRET` | de laboratorio | de QA | de UAT | secreto real |
| `JWT_TTL` | `12h` | `12h` | `1h` | `1h` |
| `SQL_DEBUG` | `true` | `true` | `false` | `false` |
| `ALLOWED_ORIGIN` | `localhost:3000` | el de QA | el de UAT | el real |
| `sslmode` | `disable` | `require` | `require` | `require` |

> ⚠️ **El caos no debería poder existir en producción, y "apagado por defecto" no
> alcanza.** Una ruta `POST /_chaos` en un binario de producción es un endpoint
> para romper tu propio sistema, expuesto a internet. La respuesta correcta no es
> una variable: es que ese código **no esté en el binario**, con una etiqueta de
> compilación. Es el ejercicio 24, y es la única concesión del track a la
> seguridad por construcción.

### 4.4 Migraciones: al arrancar o como paso previo

`D20` fijó que las migraciones son un paso explícito y **nunca implícito al
arrancar en producción**. Acá se implementa, y conviene entender el porqué con
precisión, porque la comodidad del atajo es real.

Aplicarlas en el arranque es cómodo en desarrollo: un comando y ya. En producción
con más de una réplica, tres procesos arrancan a la vez y los tres intentan
aplicar el mismo `ALTER`. `golang-migrate` toma un bloqueo, así que en el mejor
caso dos esperan; en el peor —un despliegue interrumpido a mitad— la base queda
marcada como sucia y **ninguna réplica arranca**. Un incidente total causado por
un atajo de conveniencia.

> 🧭 **Decisión: migraciones como paso previo, con un binario aparte
> (`cmd/migrate`), y una comprobación al arrancar.** El servidor no migra: **mira
> si la base está en la versión que espera** y se niega a arrancar si no. Falla
> temprano, ruidoso, y con un mensaje que dice exactamente qué versión hay y cuál
> hacía falta.
>
> En desarrollo, `docker-compose` corre el paso de migración como un servicio
> previo. Es el mismo mecanismo, orquestado distinto — que es exactamente la
> diferencia que hay entre los ambientes.

### 4.5 Dos edades en el mismo repositorio

`D23` fija algo que parece contradictorio: la aplicación es de 2022 y **el
pipeline es de hoy**.

No es una inconsistencia, es la realidad de cualquier repositorio que se revive.
Un workflow escrito con las acciones de 2022 sencillamente **no corre**: los
runners actuales rechazan aquellas versiones de las acciones. Así que el track
separa las dos edades y lo dice: acciones actuales, ejecutando Go 1.19 dentro de
un `container: golang:1.19` con `services: postgres:13`.

📝 Y es, además, exactamente la conversación que tiene un equipo cuando le toca
revivir un repositorio dormido. La pregunta no es "¿modernizamos todo?" sino
"¿qué tiene que ser de hoy y qué puede seguir siendo de entonces?". La respuesta
suele ser la misma: **la infraestructura que ejecuta, de hoy; el código que se
ejecuta, cuando se pueda**.

---

## 💻 5. Implementación y código comentado

### 5.1 La etiqueta que libera al binario de producción

```go
// server/internal/storage/driver_sqlite.go
//go:build sqlite

// Este archivo solo se compila con -tags sqlite. Es lo que mantiene a cgo
// FUERA del binario de producción, que no necesita SQLite para nada.
//
// La línea //go:build tiene que ir antes del package y separada por una
// línea en blanco, o el compilador la trata como un comentario cualquiera
// y no hace nada. Es un error silencioso: compila igual, con cgo, y solo
// lo notas midiendo.
package storage

import _ "github.com/mattn/go-sqlite3"

const sqliteEnabled = true
```

```go
// server/internal/storage/driver_nosqlite.go
//go:build !sqlite

package storage

const sqliteEnabled = false
```

```go
// Y en Open, un mensaje que evita una hora de desconcierto:
if dialect == SQLite && !sqliteEnabled {
	return nil, errors.New(
		"este binario se compiló sin soporte de SQLite: usa -tags sqlite (solo para pruebas)")
}
```

```bash
go build ./cmd/api                    # producción: puro Go, estático
go test -tags sqlite ./...            # pruebas: con SQLite disponible
```

### 5.2 El `Dockerfile`

```dockerfile
# server/Dockerfile
# Multi-stage: se compila con el toolchain completo y se despacha solo el
# binario. La receta completa, con compose y los tres errores que salen
# siempre, está en bea-02.

# ---------- etapa 1: compilar ----------
# golang:1.19 y no una versión actual: el código es de 2022 y usa el
# toolchain de 2022 (D14). El pipeline que ejecuta esto sí es de hoy (D23).
FROM golang:1.19 AS builder

WORKDIR /src

# Las dependencias primero y en su propia capa: cambian mucho menos que el
# código, así que Docker reutiliza esta capa en casi todas las
# construcciones. Copiar todo de una vez invalida la caché con cada edición.
COPY go.mod go.sum ./
RUN go mod download

COPY . .

# CGO_ENABLED=0 es la línea que hace todo lo demás posible: sin cgo el
# binario es estático y corre en una imagen vacía. Se puede poner gracias
# a la etiqueta de 5.1.
#
# -ldflags "-s -w" quita la tabla de símbolos y la información de depuración.
# ⚠️ Y con eso pierdes los nombres en los stack traces del pánico de be01.
# Es un intercambio real: unos megas contra diagnosticabilidad. Acá se
# aceptan porque el pánico se registra con recover y su mensaje; en un
# sistema donde dependas del stack trace, no lo hagas.
RUN CGO_ENABLED=0 GOOS=linux go build \
    -ldflags "-s -w" \
    -o /out/api ./cmd/api

RUN CGO_ENABLED=0 GOOS=linux go build -o /out/migrate ./cmd/migrate

# ---------- etapa 2: ejecutar ----------
# gcr.io/distroless/static-debian11: sin shell, sin gestor de paquetes, sin
# libc. Solo trae certificados raíz y los archivos de usuario. Pesa unos
# 2 MB.
FROM gcr.io/distroless/static-debian11:nonroot

COPY --from=builder /out/api /api
COPY --from=builder /out/migrate /migrate
COPY --from=builder /src/migrations /migrations

# nonroot viene del tag de la imagen base. Si el proceso se compromete, no
# es root — que es lo mínimo exigible y cuesta cero.
USER nonroot:nonroot

EXPOSE 3001
ENTRYPOINT ["/api"]
```

Y el detalle que hunde a mucha gente la primera vez:

```go
// server/cmd/api/main.go
import (
	// Una imagen vacía NO TIENE la base de datos de zonas horarias del
	// sistema. Sin esto, cualquier time.LoadLocation("America/Bogota")
	// devuelve "unknown time zone" DENTRO DEL CONTENEDOR y en ningún otro
	// sitio: funciona perfecto en tu máquina y falla en el despliegue.
	//
	// Este import embebe la base de zonas en el binario (unos 450 KB) y
	// existe desde Go 1.15. Es la solución de una línea a un incidente de
	// media tarde, y conecta directamente con be06.
	_ "time/tzdata"
)
```

### 5.3 La medición de `D19`

No opines: mide. Tres escenarios, la misma máquina, la misma caché fría.

```bash
# 1. Con cgo (lo que venías arrastrando desde be02)
time CGO_ENABLED=1 go build -tags sqlite -o /tmp/api-cgo ./cmd/api
docker build --no-cache -f Dockerfile.cgo -t rifas:cgo .

# 2. Sin cgo, con la etiqueta de 5.1
time CGO_ENABLED=0 go build -o /tmp/api-puro ./cmd/api
docker build --no-cache -t rifas:puro .

# 3. Con modernc.org/sqlite (Go puro, sin etiqueta)
time CGO_ENABLED=0 go build -tags modernc -o /tmp/api-modernc ./cmd/api

ls -lh /tmp/api-*
docker images rifas
```

Lo que hay que anotar en `server/evidence/imagen.md`:

| Escenario | Tamaño del binario | Tamaño de la imagen | `go build` en frío | `go test` completo |
|---|---|---|---|---|
| cgo (`mattn`) | | | | |
| puro Go (etiqueta) | | | | |
| `modernc.org/sqlite` | | | | |

Y la decisión, escrita con esos números al lado. La que este track defiende —y
que tienes que verificar tú— es que **la etiqueta de compilación gana**: el
binario de producción queda puro y estático, las pruebas conservan `mattn`, que
es más rápido en ejecución que `modernc`, y no hace falta cambiar de driver. La
pregunta de `D19` resultó estar mal planteada: no era *qué driver de SQLite*, era
*por qué el binario de producción tiene un driver de SQLite*.

> 🧠 **Ese giro es la lección de la sección.** Cuando una decisión técnica parece
> un empate entre dos opciones malas, muchas veces la pregunta está mal hecha.
> `D19` llevaba siete fases abierta como "cgo o puro Go", y la respuesta real fue
> "esto no debería estar en el binario".

### 5.4 `docker-compose` y las migraciones como paso previo

```yaml
# server/docker-compose.yml
# El laboratorio completo. La aplicación React sigue en el 3000, fuera de
# esto, hablándole al 3001 como desde be03.
services:
  db:
    image: postgres:13
    environment:
      POSTGRES_USER: rifas
      POSTGRES_PASSWORD: rifas
      POSTGRES_DB: rifas
    ports: ["5432:5432"]
    healthcheck:
      # Sin esto, el servicio de migraciones arranca contra un Postgres que
      # todavía está inicializándose y falla. "depends_on" solo espera a que
      # el contenedor exista, no a que el servicio esté listo — es el error
      # número uno de compose y produce fallos intermitentes al levantar.
      test: ["CMD-SHELL", "pg_isready -U rifas"]
      interval: 2s
      retries: 15

  migrate:
    build: .
    entrypoint: ["/migrate", "up"]
    environment:
      DATABASE_URL: postgres://rifas:rifas@db:5432/rifas?sslmode=disable
    depends_on:
      db: { condition: service_healthy }

  api:
    build: .
    ports: ["3001:3001"]
    environment:
      DATABASE_URL: postgres://rifas:rifas@db:5432/rifas?sslmode=disable
      ALLOWED_ORIGIN: http://localhost:3000
      JWT_SECRET: laboratorio-no-usar-esto-en-ningun-otro-lado-32
      CHAOS_LEVEL: "off"
    depends_on:
      # El API espera a que las migraciones TERMINEN. Es el paso previo de
      # §4.4, orquestado por compose en vez de por el pipeline.
      migrate: { condition: service_completed_successfully }
```

```go
// server/cmd/api/main.go — la comprobación de versión, no la migración.
//
// El servidor NO migra. Comprueba que la base esté donde debe y se niega a
// arrancar si no. Fallar en el segundo cero con un mensaje claro es
// infinitamente mejor que arrancar y devolver 500 en la primera consulta
// que toque una columna que todavía no existe.
current, dirty, err := storage.MigrationVersion(ctx, db)
if err != nil {
	log.Fatalf("no se pudo leer la versión del esquema: %v", err)
}
if dirty {
	log.Fatalf("la base está en estado 'dirty' en la versión %d: "+
		"reviso el esquema a mano y uso 'migrate force' antes de arrancar", current)
}
if current != storage.ExpectedSchemaVersion {
	log.Fatalf("el esquema está en la versión %d y este binario espera la %d: "+
		"corre las migraciones antes de desplegar", current, storage.ExpectedSchemaVersion)
}
```

### 5.5 El pipeline

```yaml
# .github/workflows/ci.yml
#
# 📝 LAS DOS EDADES (D23). Las acciones son de HOY porque los runners
# actuales rechazan las versiones de 2022. El código que ejecutan es de
# 2022, y por eso corre dentro de container: golang:1.19. No es una
# inconsistencia: es lo que pasa cuando se revive un repositorio dormido, y
# se declara en vez de esconderse.
#
# ⚠️ Verifica las versiones de las acciones antes de usar este archivo: se
# actualizan varias veces al año y las viejas se retiran.

name: CI
on:
  push: { branches: [master] }
  pull_request:

jobs:
  test:
    runs-on: ubuntu-latest
    container: golang:1.19        # el Go de 2022, dentro de un runner de hoy
    services:
      postgres:
        image: postgres:13
        env:
          POSTGRES_USER: rifas
          POSTGRES_PASSWORD: rifas
          POSTGRES_DB: rifas_test
        options: >-
          --health-cmd pg_isready --health-interval 5s --health-retries 10
    env:
      # "postgres" y no "localhost": dentro de un container, los servicios se
      # resuelven por nombre. Es el error clásico de esta configuración.
      TEST_DATABASE_URL: postgres://rifas:rifas@postgres:5432/rifas_test?sslmode=disable

    steps:
      - uses: actions/checkout@v4

      - name: Migraciones sobre la base de pruebas
        run: |
          go install -tags 'postgres' github.com/golang-migrate/migrate/v4/cmd/migrate@v4.15.2
          migrate -path server/migrations/postgres -database "$TEST_DATABASE_URL" up

      # Los cinco niveles de be08, en orden de costo creciente: lo barato
      # primero, para que un error tonto no gaste tres minutos de runner.
      - run: make -C server test-unit
      - run: make -C server test-integration
      - run: make -C server test-contract
      - run: make -C server test-race

      # LA REGLA DEL MOTOR, EJECUTADA. Este paso es la razón de que el
      # pipeline exista tal como está: verifica que la suite corre contra
      # PostgreSQL, que es el motor de verdad (D18). Si alguien agrega una
      # prueba de concurrencia sin MustPostgres, acá revienta.
      - run: make -C server test-engine-rule

  image:
    needs: test
    runs-on: ubuntu-latest
    permissions: { contents: read, packages: write }
    steps:
      - uses: actions/checkout@v4
      - uses: docker/setup-buildx-action@v3
      - uses: docker/login-action@v3
        with:
          registry: ghcr.io
          username: ${{ github.actor }}
          password: ${{ secrets.GITHUB_TOKEN }}
      - uses: docker/build-push-action@v6
        with:
          context: ./server
          push: ${{ github.event_name == 'push' }}
          # El sha y no "latest": una etiqueta móvil hace que "¿qué hay
          # desplegado?" no tenga respuesta. Cada imagen apunta a un commit.
          tags: ghcr.io/${{ github.repository }}/raffles-api:${{ github.sha }}
```

### 5.6 El veredicto honesto

Es el entregable final del track y va en `server/VEREDICTO.md`. Escríbelo tú, con
tu experiencia; lo que sigue es la estructura y las respuestas que este track
defiende.

**Qué quedó mejor que el mock.** Vender dos veces el mismo número pasó de ser
posible a ser **imposible de representar**. La identidad dejó de ser una
afirmación del cliente. El reloj dejó de ser el del usuario. El dinero se
recalcula desde los hechos y una liquidación que no cuadra no llega a existir. El
`X-Request-Id` recorre el sistema entero, desde la consola del navegador hasta la
consulta SQL con su tiempo. Y una ruta que el frontend llamaba al vacío desde la
Fase 6 —`C-01`— por fin responde.

**Qué quedó peor, y hay que decirlo.** Levantar el entorno pasó de `npm run
mock:api` a un contenedor de Postgres, unas migraciones y una siembra. El ciclo de
retroalimentación es más lento: donde antes editabas un JSON y recargabas, ahora
compilas y a veces migras. Hay dos motores que mantener y un DDL duplicado. El
caos hubo que reimplementarlo. Y el track costó **84 horas** que no estaban en el
presupuesto de las 96.

**Qué deudas siguen vivas.** Sin *refresh token*: el JWT vence y el usuario cae al
login (`be04`). El frontend sigue pintándose con el reloj del navegador, aunque el
servidor ya publique el suyo (`be06`). Las ventas migradas no tienen autoría real
y no se puede reconstruir (`be05`). `sales` es inmutable por convención y no por
permisos (`be07`). No hay autorización a nivel de objeto: cualquier usuario puede
todo (`be04`). Los *workers* corren en todas las réplicas. Y `GET /stats` sigue
sin existir.

Y algo que vale la pena notar sobre las dos primeras: **no son descuidos, son la
misma decisión**. Las dos se pagarían tocando el frontend, y el track eligió no
hacerlo. Decidir no pagar una deuda y escribir por qué es una forma perfectamente
respetable de administrarla — muy superior a pagarla a escondidas.

**Cuándo NO vale la pena reemplazar un mock por un backend propio.** Esta es la
parte que hay que responder con la mano en el corazón:

*Cuando el mock cumple.* Si el sistema no tiene concurrencia sobre recursos
únicos, ni dinero, ni reglas que dependan del reloj, ni identidad que proteger,
un mock puede ser suficiente durante años. Este dominio tenía las cuatro. La
mayoría no tiene ninguna.

*Cuando no hay quién lo mantenga.* Un backend propio en Go contra Postgres es un
sistema que alguien tiene que operar, migrar, monitorear y actualizar. Si el
equipo son tres personas de frontend, acabas de crearles un segundo trabajo.

*Cuando lo único que faltaba era persistencia.* Si el problema era "necesitamos
guardar datos de verdad" y no "necesitamos garantías", un servicio gestionado
resuelve eso en una tarde. Escribir un backend para tener una base de datos es
una respuesta cara a una pregunta barata.

*Cuando el proyecto tiene fecha de caducidad.* Ochenta y cuatro horas en un
sistema que se apaga en seis meses son ochenta y cuatro horas.

*Y cuando no puedes tocar al cliente y el contrato es un desastre.* Acá el
contrato era feo pero coherente. Si el frontend dependiera de rarezas
irreproducibles, honrarlo costaría más que el backend entero, y la conversación
correcta sería sobre migrar al cliente, no sobre reemplazar al servidor.

> 🧠 **Y el criterio que resume el track:** reemplazar un mock por un backend
> propio vale la pena cuando lo que necesitas son **garantías** que solo el
> servidor puede dar. Si lo que necesitas son datos, hay caminos más baratos.

---

## ⚠️ 6. Errores comunes y pieza forense

### Errores comunes

**1. `COPY . .` antes de `go mod download`.** Síntoma: cada construcción tarda lo
mismo que la primera. Causa: cualquier cambio en el código invalida la capa de
dependencias. Fix: el orden de 5.2.

**2. La imagen vacía sin zonas horarias.** Síntoma: `unknown time zone
America/Bogota` solo dentro del contenedor. Causa: `distroless/static` y `scratch`
no traen `/usr/share/zoneinfo`. Fix: `import _ "time/tzdata"`.

**3. `localhost` dentro de un contenedor.** Síntoma: `connection refused` contra
la base, en compose y en CI. Causa: `localhost` es el propio contenedor. Fix: el
nombre del servicio (`db`, `postgres`).

**4. `depends_on` sin `condition`.** Síntoma: falla al levantar, y una de cada
tres veces funciona. Causa: `depends_on` a secas espera a que el contenedor
exista, no a que el servicio esté listo. Fix: `healthcheck` más
`condition: service_healthy`.

**5. Publicar `latest`.** Síntoma: nadie puede responder qué versión está
desplegada. Causa: una etiqueta móvil. Fix: etiquetar por `sha`.

**6. Secretos en el `compose` o en la imagen.** Síntoma: ninguno, hasta que lo
hay. Causa: comodidad. Fix: variables de entorno inyectadas y secretos del
repositorio. Y recuerda que **una capa de imagen conserva lo que borraste en la
capa siguiente**: un secreto copiado y luego eliminado sigue en el historial de
la imagen.

### 🩻 Pieza forense de esta fase

**Compila en mi máquina y no en el runner.**

*Paso 1 — provoca el clásico de cgo.* Vuelve a poner el `import` del driver de
SQLite en un archivo **sin** etiqueta de compilación y construye la imagen sobre
Alpine:

```dockerfile
FROM golang:1.19-alpine AS builder
RUN CGO_ENABLED=1 go build -o /out/api ./cmd/api   # sin gcc en la imagen
```

Falla, y falla con un mensaje que no menciona a cgo por ninguna parte. Anótalo.
Instala `gcc musl-dev`, vuelve a construir sobre Alpine, y ejecuta ese binario en
`debian`. Ahora el error es el mejor de todos: `no such file or directory` sobre
un binario que existe, que puedes ver, y que tiene permisos de ejecución. **El
archivo que no existe es la `libc` que el binario espera.** Confírmalo con `file`
y con `ldd`, y escribe la explicación.

*Paso 2 — la arquitectura.* Si trabajas en un Mac con Apple Silicon, construye
sin especificar plataforma y ejecuta la imagen en el runner (o simula con
`docker run --platform linux/amd64`). El error de formato ejecutable es el otro
clásico. Arréglalo con `--platform` y anota cuánto más tarda una construcción
emulada.

*Paso 3 — la zona horaria que solo falla en el contenedor.* Quita
`_ "time/tzdata"`, construye, y llama desde dentro del contenedor a algo que use
`time.LoadLocation`. Falla ahí y solo ahí. Este es el hermano exacto de lo que
`A3` cuenta sobre "en mi máquina anda", y `be06` es quien lo hace posible.

*Paso 4 — el smoke test contra el contenedor.* Levanta todo con compose y corre
el mismo `server/smoke.sh` de `be00`, sin modificar una línea:

```bash
docker compose up -d
BASE_URL=http://localhost:3001 ./server/smoke.sh
```

Que ese guion —escrito en la primera fase del track contra `json-server`— pase
sin cambios contra una imagen construida en la última, **es el cierre del
círculo**. El contrato sobrevivió a un cambio de lenguaje, de almacenamiento, de
modelo de datos y de empaquetado.

*Paso 5 — el círculo completo, por última vez.* Con todo en contenedores, abre la
aplicación en `localhost:3000`, haz una venta, copia el `X-Request-Id` de la
consola, y búscalo en `docker compose logs api`. Ahí está: la petición, la
consulta SQL, el tiempo, y el usuario que la hizo.

En `be00` ese id no llegaba a ninguna parte. Ese recorrido —consola del navegador
→ log de un contenedor → consulta SQL— es exactamente lo que el track prometió en
su primera página, y es la mejor forma de terminarlo.

---

> 📓🔥 De esta fase sale el incidente **be-16** de `cuaderno-incidentes-be.md`: la imagen de ayer no arranca y el código no cambió — que es, palabra por palabra, la definición de una etiqueta móvil.

---

## 🧪 7. Ejercicios (30)

**🟢 Fácil (1–7)**

1. Construye la imagen y comprueba que responde `GET /health`.
2. Verifica con `docker images` cuánto pesa la imagen final.
3. Levanta el compose completo y comprueba que la aplicación React funciona contra él sin cambiar nada.
4. Corre `./server/smoke.sh` contra el contenedor y confirma que pasa entero.
5. Comprueba que el binario de producción es estático (`file` y `ldd`).
6. Arranca el API sin haber corrido las migraciones y comprueba que se niega, diciendo qué versión falta.
7. Verifica que el contenedor no corre como root.

**🟡 Intermedio (8–18)**

8. Implementa la etiqueta de compilación de 5.1 y comprueba que `go build ./cmd/api` ya no necesita cgo.
9. **Diagnóstico.** Pon mal la línea `//go:build` (pegada al `package`) y comprueba que el binario sigue arrastrando cgo. Explica por qué el error es silencioso.
10. Completa la tabla de medición de `D19` con tus tres escenarios.
11. **Diagnóstico.** Ejecuta el paso 1 de la pieza forense hasta el `no such file or directory` y explícalo con `ldd`.
12. **Diagnóstico.** Ejecuta el paso 3 (zonas horarias) y determina qué código exacto del backend fallaría por eso.
13. Invierte el orden de `COPY` en el Dockerfile y mide la diferencia de tiempo entre dos construcciones consecutivas.
14. Escribe las variables de los cuatro ambientes como archivos `.env` de ejemplo, sin secretos reales.
15. **Diagnóstico.** Quita el `healthcheck` del compose y levanta diez veces. Cuenta cuántas fallan.
16. Haz que el pipeline corra en tu repositorio y que los cinco niveles pasen.
17. **Diagnóstico.** Cambia `postgres` por `localhost` en `TEST_DATABASE_URL` del workflow y lee el error. Explica la diferencia entre correr en el runner y correr en un container.
18. Publica la imagen etiquetada por `sha` y comprueba que aparece en el registro.

**🟠 Difícil (19–26)**

19. **Diagnóstico.** Ejecuta el paso 2 (arquitectura) y documenta el error de formato ejecutable, con el tiempo de una construcción emulada frente a una nativa.
20. Escribe `server/evidence/imagen.md` con la medición completa y la decisión de `D19` justificada con tus números. Si tus números contradicen la conclusión de 5.3, defiende la tuya.
21. Implementa `cmd/migrate` y la comprobación de versión del arranque, incluido el caso `dirty`.
22. **Diagnóstico.** Deja la base en estado `dirty` a propósito y comprueba que el API se niega a arrancar con un mensaje accionable. Escribe el runbook de salida.
23. Agrega al pipeline un paso que falle si el binario de producción resulta enlazado dinámicamente. Es la forma de que la decisión de `D19` no se deshaga sola dentro de seis meses.
24. Saca el caos del binario de producción con una etiqueta de compilación, de modo que `POST /_chaos` **no exista** salvo que se compile con `-tags chaos`. Comprueba que el laboratorio sigue funcionando.
25. **Diagnóstico.** Añade `govulncheck` al pipeline (el mecanismo del ejercicio 29 de `be04`) y anota qué reporta hoy sobre tu `go.mod`.
26. Mide el pipeline completo y decide qué correría en cada *pull request* y qué solo en `master`. Justifica con los tiempos.

**🔴 Muy difícil (27–30)**

27. **El veredicto honesto.** Escribe `server/VEREDICTO.md` completo con la estructura de 5.6. No copies las respuestas del track: son las de quien lo escribió. Las tuyas tienen que salir de tus 84 horas, y la sección de "cuándo NO vale la pena" tiene que incluir al menos un caso que acá no esté.
28. Diseña la estrategia de despliegue sin interrupción para este sistema: cómo conviven dos versiones del binario contra un solo esquema, qué clase de migración es segura y cuál no, y qué papel juega el apagado ordenado de `be01`. Escríbelo como plan operativo.
29. **Diagnóstico + regresión.** Ticket: *"la imagen de ayer no arranca en producción y la de anteayer sí, y el código no cambió"*. Enumera las cinco causas candidatas ordenadas por probabilidad —incluyendo las que no están en tu código—, di cómo descartas cada una, y escribe el control que lo habría atrapado.
30. **Post-mortem del track.** Escribe el post-mortem del track BE completo, tratándolo como un proyecto entregado: qué salió mejor de lo esperado, qué salió peor, qué decisión tomarías distinta con lo que sabes ahora, y qué se llevó de aquí que sirve fuera de este dominio. Sin culpabilización, incluida hacia ti.

**🔥 Opcionales**

- 🔥 **`GET /stats`**, el pendiente que el track viene arrastrando desde `be00`. Implementa las agregaciones del dashboard de la Fase 9 en SQL y mide contra veinte mil ventas. Ningún cliente lo consume: es un ejercicio de agregación para quien terminó el curso entero, y ninguna fase depende de él.
- 🔥 Construye la imagen para `linux/amd64` y `linux/arm64` con `buildx` y publica un manifiesto múltiple. Mide cuánto tarda cada una.
- 🔥 Agrega un `HEALTHCHECK` al Dockerfile y decide, con lo que `be02` cerró en `D26`, si debe apuntar a `/health` o a una ruta de *liveness* separada. Implementa la que falte.

---

## 📚 8. Referencias

**Documentación oficial**
- https://docs.docker.com/build/building/multi-stage/ — el patrón de 5.2.
- https://docs.docker.com/compose/compose-file/05-services/#depends_on — `condition` y por qué hace falta.
- https://github.com/GoogleContainerTools/distroless — qué traen y qué no las imágenes mínimas.
- https://pkg.go.dev/time/tzdata — el import de una línea del error común 2.
- https://pkg.go.dev/cmd/go#hdr-Build_constraints — la sintaxis exacta de `//go:build`, incluida la regla de la línea en blanco.
- https://docs.github.com/en/actions/using-jobs/running-jobs-in-a-container y https://docs.github.com/en/actions/using-containerized-services — `container` y `services`, que son `D23` hecho YAML.
- https://go.dev/doc/go1.18#go-generics — no por los genéricos, sino porque en esa página está el contexto de qué había y qué no en el Go de esta época.

**Libros**
- *Continuous Delivery* (Humble y Farley) — "construye el binario una sola vez y promociónalo entre ambientes" es §4.3 en su forma original.
- *The Docker Book* o cualquier referencia actual de Docker — verifica la edición: esta es el área del curso que más rápido envejece.

**Video / apoyo**
- Busca "multi-stage docker build Go" y "distroless images explained". Y para la pieza forense, cualquier charla sobre "static vs dynamic linking cgo" aclara el paso 1 mejor que un texto.

**Orden de lectura sugerido:** la página de multi-stage primero, que es corta →
`build constraints` antes de escribir la etiqueta de 5.1, porque la regla de la
línea en blanco es exactamente el ejercicio 9 → `bea-02` para la receta completa
con sus tres errores clásicos → y la documentación de Actions cuando el pipeline
no arranque.

> ⚠️ URLs, títulos y ediciones pueden haber cambiado: verifícalos, y acá más que
> en ninguna otra fase — las versiones de las acciones de GitHub se retiran varias
> veces al año y el YAML de 5.5 va a envejecer antes que el resto del curso. Las
> referencias a libros son de memoria y pueden ser inexactas. Cualquier
> discrepancia de versiones la resuelve `prompts/decisiones-y-versiones.md` §7.

---

## 🚀 9. Cierre del track

Se acabó. Diez fases, 84 horas, y un backend en Go contra PostgreSQL 13 que
reemplazó a `json-server` sin que la aplicación React cambiara **un solo archivo**
—salvo el que la Fase 2 había señalado con el dedo dos años antes—.

Lo que te llevas no es Go. Go es el vehículo, y en dos años puede ser otro. Lo que
te llevas es esto:

Puedes tomar un contrato de API existente, **medirlo** en vez de adivinarlo, y
reimplementarlo sin romper a quien lo consume. Sabes en qué capa vive de verdad
cada bug de concurrencia, y por qué el frontend nunca fue el lugar para
arreglarlo. Sabes qué prueba puede correr contra SQLite y cuál te estaría
engañando. Puedes seguir un `X-Request-Id` desde la consola del navegador hasta la
consulta SQL que lo produjo. Y sabes decir, con argumentos y con números, cuándo
reemplazar un mock por un backend propio **no** valía la pena.

Y hay una cosa más, que es la que el track base no podía darte. Volviste a mirar
los mismos bugs desde el otro lado del cable y descubriste que **la mitad de los
que parecían del frontend no lo eran**. La venta duplicada de la Fase 5. La hora
de cierre de la Fase 7. El centavo que no cuadra de la Fase 8. Los tres se veían
desde el navegador y ninguno se resolvía ahí.

Esa es la tesis del track, y ahora la tienes demostrada con tus propias manos.

> **La señal de que quedó bien:** *"apagué el mock, levanté mi binario, y la única
> forma de notar el cambio fue que el bug de la venta doble dejó de pasar."*

> 🏷️ **No cierres la fase sin el tag.** Con el checklist de la sección 2 en
> verde y `git status` limpio:
>
> ```bash
> git tag -a fase-be09-empaquetado-ambientes-y-pipeline -m "be09 cerrada: \
> Dockerfile multi-stage con binario estático y distroless; D19 medida y decidida; \
> compose con migraciones como paso previo y comprobación de versión al arrancar; \
> configuración de los cuatro ambientes; pipeline que prueba contra los dos motores y publica por sha; \
> smoke.sh de be00 pasando contra el contenedor; server/VEREDICTO.md escrito"
> ```
>
> Y el tag que cierra el track entero:
> `git tag -a track-be-completo -m "🔥 Track BE terminado: 10 fases, 84 horas, frontend intacto"`.
>
> Los commits de la fase llevan su prefijo (`be09: …`) y los de ejercicio su
> número (`be09 ej27: …`). Todo eso está en
> [`00-convencion-de-git-y-tags.md`](00-convencion-de-git-y-tags.md).

---

## 📌 Pendientes sugeridos

*(Fuera de lo que lee el estudiante.)*

- **Registrar en `prompts/decisiones-y-versiones.md` §7** el cierre de `D19`, que
  llevaba siete fases abierta: **no se cambia de driver, se etiqueta la
  compilación**. El binario de producción va sin cgo y `mattn/go-sqlite3` queda
  detrás de `-tags sqlite` para pruebas. `modernc.org/sqlite` se mide y se
  descarta. Y anotar el giro: la pregunta de `D19` estaba mal planteada.
- **Registrar también el tag de hito `track-be-completo`**, junto con
  `mock-retirado` de `be03`, en `00-convencion-de-git-y-tags.md` como los dos
  únicos tags del track que no siguen el patrón `fase-…`.
- **El YAML de 5.5 es la parte del curso que más rápido envejece.** Conviene
  revisarlo en cada revisión editorial y verificar las versiones de las acciones
  contra su documentación. El texto ya lo advierte al alumno, pero la
  advertencia no arregla el archivo.
- **`bea-02` tiene que ser autosuficiente.** Esta fase muestra el Dockerfile y
  el compose y remite ahí para la receta cerrada con sus tres errores clásicos.
  El apéndice no puede limitarse a repetir: le corresponde el detalle operativo
  —volúmenes, redes, puertos ocupados, limpieza— que acá no cabe.
- **`bea-09` (mapa de deuda del track BE) recibe la lista completa** del §5.6, y
  debería ordenarla por lo que `A12` usa como criterio: qué la vuelve exigible.
  Las dos deudas que el track decide **no** pagar —*refresh token* y reloj del
  cliente— merecen tratamiento propio, porque su causa es la misma regla del
  track y no un descuido.
- **El `GET /stats` queda como pendiente 🔥 y así debe quedarse.** Ninguna fase
  depende de él y el `smoke.sh` no lo exige. Está en el ejercicio opcional con la
  pregunta honesta de si merece la pena construir algo sin consumidor.
- **Reserva para el cuaderno de incidentes:** `be-16` — *"la imagen de ayer no
  arranca y el código no cambió"* (categoría 🔥 despliegue, dificultad 🟠), el
  ejercicio 29. **Con esto se completa el rango `be-01`–`be-16`** que se amplió al
  escribir `be04`. Si se redactan los enunciados, conviene revisar que los
  dieciséis cubran las cuatro categorías propias del track —base de datos,
  transacciones, despliegue y contrato— de forma equilibrada; hoy contrato y
  transacciones están mejor servidas que despliegue.
- **Cierre editorial del track:** las diez fases están escritas. Faltan los diez
  apéndices `bea-01`–`bea-10`, y conviene escribirlos en orden de dependencia
  —`bea-01` (Go) y `bea-02` (imagen) son los que más fases citan— antes que los
  temáticos.
