# 📦 Fase be09 — Empaquetado, ambientes y pipeline

> Tutorial React 16 — La Esclusa, la consola de Jewel Locks · **Track BE opcional 🔥** · Fase be09 de be09 · **8 horas**
> Depende de: be08 — la suite dice la verdad · Cierra el track BE

---

## 🎯 1. Propósito

*"Tranquilo, que eso suena: pero en 2028 quiero decidir con números, no con miedo."* Abdiel lo dice al final de la llamada en que Juliana muestra el backend corriendo. La decisión de 2028 —apagar la Esclusa y llevar sus funciones al editor de Unity, o migrarla a las versiones actuales de todo— no se toma hoy (historia §3, *Hoy*). Pero se toma con lo que el equipo aprenda en estos dos años, y una parte de eso es lo que esta fase deja escrito.

Convertir el binario que corre en tu máquina en algo que se puede desplegar: una imagen construida de forma reproducible, configurada por ambiente, con las migraciones aplicadas como paso previo, y un pipeline que corre la suite de `be08` contra Postgres y publica la imagen.

Y una decisión que `D19` dejó abierta desde `be02`, que se paga midiendo y no opinando: **cgo contra Go puro**. Llevas siete fases con `CGO_ENABLED=1` en el binario por un driver que el servidor no usa nunca; toca ponerle números.

Y cerrar el track con lo que el curso entero viene practicando: **un veredicto honesto**. Qué quedó mejor que el mock, qué quedó peor, qué deudas siguen vivas, cuándo reemplazar un mock por un backend propio **no** vale la pena, y qué de todo esto le sirve a Itzel y a Abdiel para la decisión de 2028.

> 🧭 **Autocontención, y acá es crítico.** Esta fase **no remite a ningún otro curso del catálogo**. Todo lo necesario para construir la imagen y el pipeline vive acá y en `bea-02`, escrito como receta cerrada y verificada.

---

## ✅ 2. Qué queda listo al terminar

- [ ] El driver de SQLite vive detrás de `//go:build sqlite`, y el binario de producción compila con `CGO_ENABLED=0`.
- [ ] La medición de `D19` está en `server/evidence/imagen.md`: tamaño del binario y compilación en frío en los tres escenarios, con la decisión tomada con esos números.
- [ ] `server/Dockerfile` multi-stage produce una imagen sobre distroless fijada por digest (`D38`), sin root, que arranca y responde `GET /health`.
- [ ] `cmd/migrate` aplica las migraciones como paso previo, y el API **comprueba** la versión del esquema al arrancar y se niega si no coincide.
- [ ] `docker-compose.yml` levanta Postgres, las migraciones y el API, y la consola del `3000` funciona contra eso sin cambiar nada: `smoke.sh`, el recorrido de Cypress y la smoke de la Fase 10.
- [ ] La configuración de los **cuatro ambientes** está resuelta por variables, con la lista de qué cambia en cada uno.
- [ ] `.github/workflows/ci.yml` corre los niveles de `be08` contra Postgres y publica la imagen por `sha`, y pasa `actionlint` 1.7.9 (`D31`).
- [ ] La separación de edades está explicada en el propio workflow: acciones de hoy, ejecutando Go de 2022.
- [ ] Existe `server/VEREDICTO.md`, escrito por ti, con el cierre honesto del track.

---

## 🚫 3. Qué queda fuera por ahora

- **Orquestación y Kubernetes.** Un compose y una imagen bien construida son el límite del track.
- **Despliegue real a un proveedor.** No hay nube, ni cuenta, ni tarjeta. El pipeline publica la imagen y ahí termina.
- **Observabilidad completa.** Métricas, trazas y alertas quedan fuera. Lo que sí hay —el `X-Request-Id` recorriendo el sistema— se construyó en `be01`.
- **Secretos de verdad.** Variables de entorno y los secretos del repositorio. Un gestor de secretos es otra conversación, apuntada en `bea-08`.
- **La decisión de 2028.** No es de esta fase ni tuya: es de Itzel y Abdiel. Lo que sí es tuyo es dejar escrito lo que la informa (5.6).

---

## 🧠 4. Conceptos mínimos

### 4.1 Multi-stage: por qué la imagen final no lleva compilador

Compilar necesita el toolchain de Go, las fuentes y los módulos. **Ejecutar** necesita un binario. Un `Dockerfile` multi-stage hace las dos cosas en la misma receta y descarta la primera etapa. Y no es solo tamaño: una imagen sin compilador, sin shell y sin gestor de paquetes deja a quien consiga ejecutar algo adentro sin con qué. Es la razón por la que se llaman *distroless*.

### 4.2 La cuestión cgo, ahora con números

`mattn/go-sqlite3` envuelve la biblioteca de C de SQLite y exige `CGO_ENABLED=1`. Eso arrastra tres consecuencias:

- **Compilación lenta**, porque hay que compilar C.
- **El binario deja de ser estático**: enlaza contra la `libc` del sistema donde se compiló, y sobre una imagen sin esa `libc` no arranca, con el error más desconcertante que existe (incidente `be-16`).
- **Adiós compilación cruzada barata.**

Y antes de elegir entre `mattn` y `modernc.org/sqlite`, algo que cambia la pregunta entera:

> 🧠 **SQLite solo se usa en pruebas.** El binario de producción no lo necesita jamás. Mientras el `import` del driver esté en un archivo normal, arrastra cgo a **todas** las compilaciones, incluida la de producción, por un driver que allí no se usa. La solución no es cambiar de driver: es **etiquetar la compilación**.

### 4.3 Cuatro ambientes, una imagen

**La misma imagen en todos los ambientes, y todo lo que cambia va por configuración.** Una imagen "de QA" y otra "de producción" significan que lo que probaste no es lo que desplegaste.

| Variable | Desarrollo | QA | UAT | Producción |
|---|---|---|---|---|
| `DATABASE_URL` | local, `sslmode=disable` | de QA, `require` | de UAT, `require` | de producción, `require` |
| `CHAOS_LEVEL` | `low` | `high` | `off` | `off` (y ver abajo) |
| `JWT_SECRET` | de laboratorio | de QA | de UAT | secreto real |
| `JWT_TTL` | `12h` | `12h` | `1h` | `1h` |
| `ALLOWED_ORIGIN` | `http://localhost:3000` | el de QA | el de UAT | el real |
| `PLAY_URL` | el mock del `3002` | el sandbox de la tienda | el sandbox | la tienda |

La zona de presentación no está en la tabla, a propósito: la fija el código (`D29`, `be06` §5.1), y no hay ambiente donde deba cambiar.

> ⚠️ **El caos no debería poder existir en producción, y "apagado por defecto" no alcanza.** Una ruta `POST /_chaos` en un binario de producción es un endpoint para romper tu propio sistema. La respuesta correcta es que ese código **no esté en el binario**, con una etiqueta de compilación, como SQLite en 5.1. Es el ejercicio 24.

### 4.4 Migraciones: al arrancar o como paso previo

`D20` fijó que las migraciones son un paso explícito y **nunca implícito al arrancar en producción**. Aplicarlas en el arranque es cómodo; con más de una réplica, tres procesos intentan aplicar el mismo `ALTER` a la vez. golang-migrate toma un bloqueo, así que en el mejor caso dos esperan; en el peor —un despliegue interrumpido— la base queda `dirty` y **ninguna réplica arranca**.

> 🧭 **Decisión: migraciones como paso previo, con un binario aparte (`cmd/migrate`), y una comprobación al arrancar.** El servidor no migra: **mira si la base está en la versión que espera** y se niega a arrancar si no, con un mensaje que dice qué versión hay y cuál hacía falta. En desarrollo, el compose corre el paso de migración como un servicio previo: el mismo mecanismo, orquestado distinto.

### 4.5 Dos edades en el mismo repositorio

`D23` fija algo que parece contradictorio: la aplicación es de 2022 y **el pipeline es de hoy**. Un workflow con las acciones de 2022 no corre: los runners actuales las rechazan, y `actionlint` 1.7.9 lo dice de `checkout@v3` (`D31`). El track separa las dos edades y lo declara: acciones actuales ejecutando Go 1.19 dentro de un `container: golang:1.19.13` con `services: postgres:13`.

📝 Es la conversación que tiene un equipo cuando revive un repositorio dormido. La pregunta no es *"¿modernizamos todo?"* sino *"¿qué tiene que ser de hoy y qué puede seguir siendo de entonces?"*. Y es, en chico, la decisión de 2028.

---

## 💻 5. Implementación y código comentado

### 5.1 La etiqueta que libera al binario de producción

<<<archivo:server/internal/storage/driver_sqlite.go>>>

<<<archivo:server/internal/storage/driver_nosqlite.go>>>

Y no alcanzó con mover el `import` del driver. `storage/errors.go` importaba `go-sqlite3` por sus tipos de error, para traducir `SQLITE_CONSTRAINT_UNIQUE`: ese `import` también arrastraba cgo. La mitad de SQLite de `IsUniqueViolation` y `IsForeignKeyViolation` se mudó al mismo archivo etiquetado. La comprobación que dice si quedó algo:

```bash
go list -deps ./cmd/api | grep -c sqlite      # 0
```

Y en `Open`, un mensaje que evita una hora de *"sql: unknown driver"*:

<<<fragmento:server/internal/storage/storage.go|	if dialect == SQLite && !sqliteEnabled {|	}>>>

```bash
CGO_ENABLED=0 go build ./cmd/api              # producción: puro Go, estático
go test -tags sqlite ./internal/wheel/        # pruebas: con SQLite
```

El `Makefile` de `be08` pasa a usar `-tags sqlite` en sus objetivos.

### 5.2 La medición de `D19`

No opines: mide. Tres escenarios, el mismo `golang:1.19.13`, la caché de compilación vacía en cada uno:

| Escenario | Binario | `go build` en frío | cgo |
|---|---|---|---|
| cgo (`mattn/go-sqlite3`, `-tags sqlite`) | 13.573.136 bytes | 27,4 s | sí |
| puro Go (la etiqueta) | 8.820.536 bytes | 1,9 s | no |
| `modernc.org/sqlite` v1.19.5 | 13.985.575 bytes | 6,4 s | no |

Casi todo el tiempo del primero es compilar el SQLite en C. Las pruebas que usan SQLite lo pagan una vez —`go test -tags sqlite ./internal/wheel/` con la caché vacía tardó 27,0 s— y nada después.

La decisión: **la etiqueta gana**. El binario de producción queda en 8,8 MB, estático, y compila en dos segundos; las pruebas conservan `mattn`; no hace falta cambiar de driver. `modernc` resuelve el problema de cgo, pero mete en producción 5 MB de un driver que producción no usa.

> 🧠 **Ese giro es la lección de la sección.** `D19` llevaba siete fases abierta como *"cgo o puro Go"*, y la respuesta fue *"esto no debería estar en el binario"*. Cuando una decisión técnica parece un empate entre dos opciones malas, muchas veces la pregunta está mal hecha.

### 5.3 El `Dockerfile`

<<<archivo:server/Dockerfile>>>

```bash
docker build --no-cache -t esclusa-api server/      # 26 s en la máquina del autor
docker image ls esclusa-api                         # 21 MB
```

La versión con cgo de `bea-02` (sobre distroless *base*, con glibc) pesa 81,3 MB.

> 📝 **¿Y las zonas horarias?** La receta de siempre agrega `import _ "time/tzdata"` porque *"una imagen mínima no trae la base de zonas"*. Medido: distroless *static* **sí** la trae (`time.LoadLocation("America/Panama")` funciona), y `scratch` no (*"unknown time zone America/Panama"*). Y este API no carga ninguna zona: la de presentación la pone Postgres (`be06`). El `import` se agrega el día que el binario llame a `LoadLocation`, sabiendo que entonces la versión de la base de zonas pasa a ser la de **tu** Go, no la de la imagen (`be06` §4.2).

### 5.4 Las migraciones como paso previo, y el compose

<<<archivo:server/cmd/migrate/main.go>>>

<<<fragmento:server/internal/storage/version.go|// CheckSchema compara|	return nil
}>>>

Lo que dice la imagen cuando arranca mal, medido:

```text
configuración inválida: required key DATABASE_URL missing value
no se pudo abrir la base: este binario se compiló sin SQLite: compílalo con -tags sqlite (solo para pruebas)
no se pudo leer la versión del esquema (¿se corrieron las migraciones?): pq: relation "schema_migrations" does not exist
```

<<<archivo:server/docker-compose.yml>>>

`PLAY_URL` apunta a tu máquina porque el mock de Google Play corre con la consola (`npm run mock:googleplay`), no en esta red. Medido de punta a punta: `docker compose up -d --build` levanta, `migrate` termina con *"esquema en la versión 8"*, la siembra entra con `go run ./cmd/seed`, y contra el API del compose pasan `smoke.sh` (24 de 24), el recorrido de Cypress y la smoke de la Fase 10 de la consola.

### 5.5 El pipeline

<<<archivo:.github/workflows/ci.yml>>>

Sin runner (`D31`), el workflow se valida con `actionlint` y sus pasos se corren en contenedor:

```bash
docker run --rm -v "$PWD":/repo -w /repo rhysd/actionlint:1.7.9       # 0
```

Con `checkout@v3`, el mismo comando da:

```text
.github/workflows/ci.yml:36:15: the runner of "actions/checkout@v3" action is too old to run on GitHub Actions. update the action's version to fix this issue [action]
```

Y los cuatro pasos del trabajo `test`, en `golang:1.19.13` con un `postgres:13` que se llama `postgres` en la red: `make test-unit` 27 s (con la compilación de SQLite en frío), `make test-handler` 1 s, `make test-all` 72 s, y el binario sin cgo 2 s. Los cuatro con código 0.

> ⚠️ **`.github/` vive en la raíz del repositorio**, porque GitHub lo busca ahí. Es el único archivo fuera de `server/` que el track agrega, y no es frontend: la regla del track (`git diff pre-backend-go..HEAD -- . ':!server' ':!src/api/authService.js' ':!.github'`) sigue vacía.

### 5.6 El veredicto honesto

Es el entregable final del track y va en `server/VEREDICTO.md`. Escríbelo tú, con tu experiencia; lo que sigue es la estructura y las respuestas que este track defiende.

**Qué quedó mejor que el mock.** Entregar una Esclusa de Oro de más pasó de ser posible a ser **imposible de representar** (`be05`). La misma clave da un giro. La identidad dejó de ser una afirmación del cliente (`be04`); el reloj dejó de ser el del celular (`be06`); la compra se acredita una vez aunque Google avise tres, y la conciliación la calcula quien tiene los datos (`be07`). La rueda que se acomoda se reemplazó por la que deja la tabla de probabilidades diciendo la verdad. El `X-Request-Id` recorre el sistema entero. Y la suite falla cuando no prueba lo que dice (`be08`).

**Qué quedó peor, y hay que decirlo.** Levantar el entorno pasó de `npm run mock:api` a un Postgres, unas migraciones y una siembra. El ciclo de retroalimentación es más lento. Hay dos motores que mantener y un DDL duplicado. El caos hubo que reimplementarlo. Y el track costó **86 horas** que no estaban en las 98 del track base.

**Qué deudas siguen vivas** (el mapa completo, con su precio, está en `bea-09`):

- Sin *refresh token*: el JWT vence y la operadora cae al login (`be04`).
- La consola pinta con el reloj del navegador, aunque el servidor publique el suyo (`be06`).
- Los giros pagos no dicen de qué compra salieron, y el prorrateo solo funciona sobre la bitácora sembrada (`be07`).
- El juego no se autentica, ni la notificación de la tienda está firmada (`bea-08`).
- Los barridos —el de giros en proceso y el de cierre— corren en todas las réplicas.
- No hay reembolsos (`be07`, ejercicio 27).
- La versión de la base de zonas depende de la imagen (`be06` §4.2).

Las dos primeras **no son descuidos: son la misma decisión**. Las dos se pagarían tocando la consola, y el track eligió no hacerlo. Decidir no pagar una deuda y escribir por qué es una forma respetable de administrarla.

**Cuándo NO vale la pena reemplazar un mock por un backend propio.**

*Cuando el mock cumple.* Si el sistema no tiene concurrencia sobre recursos únicos, ni dinero, ni reglas que dependan del reloj, ni identidad que proteger, un mock puede alcanzar durante años. La Esclusa tenía las cuatro. La mayoría de las consolas no tiene ninguna.

*Cuando no hay quién lo mantenga.* Un backend en Go contra Postgres es un sistema que alguien tiene que operar, migrar y actualizar. En Interoceanic Games, el equipo que mantiene Jewel Locks son dos personas en Unity.

*Cuando lo único que faltaba era persistencia.* Si el problema era guardar datos y no dar garantías, un servicio gestionado lo resuelve en una tarde.

*Cuando el proyecto tiene fecha de caducidad.* Ochenta y seis horas en un sistema que se apaga en seis meses son ochenta y seis horas.

> 🧠 **El criterio que resume el track:** reemplazar un mock por un backend propio vale la pena cuando lo que necesitas son **garantías** que solo el servidor puede dar. Si lo que necesitas son datos, hay caminos más baratos.

**Y la decisión de 2028, que no es tuya.** Lo que el veredicto le debe a Itzel y a Abdiel no es una recomendación: son los criterios, con lo que el track midió.

| Si en 2028… | Inclina hacia |
|---|---|
| las garantías del giro y de la compra siguen siendo del API, y el editor de Unity solo tiene que mostrar y configurar | **decomisionar la consola**: las herramientas del editor le hablan al mismo API, y lo que se apaga es React 16 |
| el equipo de Unity sigue siendo de dos personas y nadie más mantiene web | **decomisionar** |
| la consola sigue creciendo en pantallas de operación (soporte, conciliación, tableros) | **migrar** la consola a versiones actuales |
| las deudas que se pagan tocando el frontend (sesión, reloj) se vuelven exigibles | **migrar**, porque decomisionar no las paga |

Fíjate en lo que **no** está en la tabla: el backend. Las dos salidas lo conservan, porque las dos necesitan que el giro no se pueda hacer dos veces. Es lo único que el track deja decidido.

---

## ⚠️ 6. Errores comunes y pieza forense

### Errores comunes

**1. `COPY . .` antes de `go mod download`.** Síntoma: cada construcción tarda lo mismo que la primera. Causa: cualquier cambio en el código invalida la capa de dependencias. Fix: el orden de 5.3.

**2. Mover el `import` del driver y olvidar los otros.** Síntoma: el binario sigue pidiendo cgo. Causa: otro archivo importa el paquete del driver, aunque sea por sus tipos —acá, `errors.go`—. Fix: `go list -deps ./cmd/api | grep sqlite`, que tiene que dar cero.

**3. `localhost` dentro de un contenedor.** Síntoma, medido: `dial tcp [::1]:5432: connect: connection refused`. Causa: `localhost` es el propio contenedor. Fix: el nombre del servicio (`db`, `postgres`).

**4. `depends_on` sin `condition`.** Síntoma: `migrate` falla con `connection refused` contra un Postgres que todavía se está inicializando. Medido sin `healthcheck`: **cinco de cinco** levantadas fallaron. Fix: `healthcheck` más `condition: service_healthy`.

**5. Publicar `latest`, o construir sobre un tag que se mueve.** Síntoma: nadie puede responder qué hay desplegado, o *"la imagen de ayer"* no es la de ayer. Fix: publicar por `sha` y fijar las imágenes base por digest (`D38`).

**6. Secretos en el compose o en la imagen.** Síntoma: ninguno, hasta que lo hay. Fix: variables inyectadas y secretos del repositorio. **Una capa de imagen conserva lo que borraste en la capa siguiente.**

**7. Volver a encender cgo sin cambiar la imagen de ejecución.** Síntoma: `exec /api: no such file or directory` sobre un binario que existe. Causa: un binario con cgo pide la `libc` con la que se compiló, y distroless *static* no la tiene. Es el incidente `be-16`.

### 🩻 Pieza forense de esta fase

**Construye en tu máquina y no arranca en la imagen.**

*Paso 1 — el clásico de cgo.* En una rama descartable, cambia la línea del API en el `Dockerfile` por `CGO_ENABLED=1 go build -tags sqlite …` y construye **sin caché**. La construcción termina sin un solo aviso. Arráncala:

```text
exec /api: no such file or directory
```

Salida 255. El binario está ahí. Confírmalo con `ldd` sobre el mismo binario compilado en `golang:1.19.13`:

```text
	linux-vdso.so.1 (0x0000ffffa685c000)
	libc.so.6 => /lib/aarch64-linux-gnu/libc.so.6 (0x0000ffffa6670000)
```

**El archivo que no existe es la `libc` que el binario espera.** El binario de la fase dice `not a dynamic executable`.

*Paso 2 — la arquitectura.* Si construyes en un Mac con Apple Silicon y el servidor es `amd64`, el error es `exec format error`. Docker Desktop emula la otra arquitectura y en el laboratorio del autor el error no apareció: no verificado por ejecución. Construye con `--platform linux/amd64` y anota cuánto más tarda.

*Paso 3 — la zona horaria, donde sí falla.* Un programa de tres líneas con `time.LoadLocation("America/Panama")` corre en distroless *static* y falla en `scratch`. Explica cuál de los dos es el error común de las recetas viejas, y por qué este API no lo sufre.

*Paso 4 — el smoke test contra el contenedor.* Levanta todo con compose, siembra, y corre el `smoke.sh` del repositorio contra el API del compose. Que ese guion —nacido en `be00` contra `json-server`— pase sin cambios contra una imagen construida en la última fase **es el cierre del círculo**: el contrato sobrevivió a un cambio de lenguaje, de almacenamiento, de modelo de datos y de empaquetado.

*Paso 5 — el círculo completo, por última vez.* Con todo en contenedores, abre la consola en `localhost:3000`, manda un envío, copia el `X-Request-Id` de la consola del navegador, y búscalo en `docker compose logs api`. En `be00` ese id no llegaba a ninguna parte.

---

> 📓🔥 De esta fase sale el incidente **be-16** de `cuaderno-incidentes-be.md`: la imagen de ayer no arranca y el código no cambió.

---

## 🧪 7. Ejercicios (30)

**🟢 Fácil (1–7)**

1. Construye la imagen y comprueba que responde `GET /health`.
2. Verifica con `docker image ls` cuánto pesa la imagen final.
3. Levanta el compose completo y comprueba que la consola funciona contra él sin cambiar nada.
4. Corre `./server/smoke.sh` contra el contenedor y confirma las 24 verificaciones.
5. Comprueba que el binario de producción es estático (`ldd`, o `go version -m` y su `CGO_ENABLED`).
6. Arranca el API contra una base sin migrar y lee el mensaje con que se niega.
7. Verifica que el contenedor no corre como root.

**🟡 Intermedio (8–18)**

8. Mueve el driver de SQLite detrás de la etiqueta y comprueba con `go list -deps` que el API ya no lo trae.
9. **Diagnóstico.** Pon mal la línea `//go:build` (pegada al `package`) y comprueba que el binario sigue arrastrando cgo. Explica por qué el error es silencioso.
10. Completa la tabla de 5.2 con tus tres escenarios.
11. **Diagnóstico.** Ejecuta el paso 1 de la pieza forense hasta el `no such file or directory` y explícalo con `ldd`.
12. **Diagnóstico.** Ejecuta el paso 3 y determina qué código del backend fallaría en `scratch` si existiera.
13. Invierte el orden de los `COPY` en el `Dockerfile` y mide la diferencia entre dos construcciones consecutivas.
14. Escribe las variables de los cuatro ambientes como archivos `.env` de ejemplo, sin secretos reales.
15. **Diagnóstico.** Quita el `healthcheck` del compose y levanta cinco veces con `down -v` en medio. Cuenta cuántas fallan y explica el número.
16. Haz que el pipeline corra en tu repositorio y que sus pasos pasen.
17. **Diagnóstico.** Cambia `postgres` por `localhost` en el `TEST_DB` del workflow y lee el error. Explica la diferencia entre el runner y el container.
18. Publica la imagen etiquetada por `sha` y comprueba que aparece en el registro.

**🟠 Difícil (19–26)**

19. **Diagnóstico.** Ejecuta el paso 2 (arquitectura) donde puedas reproducirlo, y documenta el error con el tiempo de una construcción emulada frente a una nativa.
20. Escribe `server/evidence/imagen.md` con tu medición y la decisión de `D19`. Si tus números contradicen la de 5.2, defiende la tuya.
21. **Diagnóstico.** Deja la base `dirty` a propósito (una migración que falla a la mitad) y comprueba que el API se niega a arrancar. Escribe el runbook de salida con `migrate force`.
22. Agrega al pipeline un paso que falle si el binario de producción resulta enlazado dinámicamente.
23. Agrega al pipeline la corrida de la suite contra SQLite (`make test-sqlite`) y argumenta si vale lo que cuesta.
24. Saca el caos del binario de producción con una etiqueta de compilación, de modo que `POST /_chaos` **no exista** salvo con `-tags chaos`. Comprueba que el laboratorio sigue funcionando.
25. **Diagnóstico.** Añade `govulncheck` al pipeline y anota qué reporta hoy.
26. Mide el pipeline completo y decide qué correría en cada *pull request* y qué solo en `master`.

**🔴 Muy difícil (27–30)**

27. **El veredicto honesto.** Escribe `server/VEREDICTO.md` con la estructura de 5.6. No copies las respuestas del track: son las de quien lo escribió. La sección de *"cuándo NO vale la pena"* tiene que incluir un caso que acá no esté, y la tabla de 2028, una fila tuya.
28. Diseña el despliegue sin interrupción: cómo conviven dos versiones del binario contra un esquema, qué migración es segura y cuál no, y qué papel juegan el apagado ordenado de `be01` y la comprobación de versión de 5.4 (que hoy exige la versión exacta).
29. **Diagnóstico + regresión.** Ticket: *"la imagen de ayer no arranca en producción y la de anteayer sí, y el código no cambió"*. Enumera las causas candidatas ordenadas por probabilidad, di cómo descartas cada una, y escribe el control que lo habría atrapado.
30. **Post-mortem del track.** Escribe el post-mortem del track BE como un proyecto entregado: qué salió mejor de lo esperado, qué salió peor, qué decisión tomarías distinta, y qué te llevas que sirve fuera de este dominio. Sin culpas, incluida hacia ti.

**🔥 Opcionales**

- 🔥 **`GET /stats`**: las agregaciones del tablero de la Fase 9 en SQL, medidas contra la Semana del Canal sembrada. Ningún cliente lo consume, y esa es la pregunta: ¿merece la pena construir algo sin consumidor?
- 🔥 Construye la imagen para `linux/amd64` y `linux/arm64` con `buildx` y publica un manifiesto múltiple.
- 🔥 Agrega un `HEALTHCHECK` al `Dockerfile` y decide, con lo que `be02` cerró en `D26`, si debe apuntar a `/health` o a una ruta de *liveness* separada.

---

## 📚 8. Referencias

**Documentación oficial**
- https://docs.docker.com/build/building/multi-stage/ — el patrón de 5.3.
- https://docs.docker.com/compose/compose-file/05-services/#depends_on — `condition`, el error común 4.
- https://github.com/GoogleContainerTools/distroless — qué traen *static* y *base*, y por qué se fijan por digest.
- https://pkg.go.dev/cmd/go#hdr-Build_constraints — la sintaxis exacta de `//go:build`, incluida la línea en blanco.
- https://github.com/golang-migrate/migrate — la biblioteca de `cmd/migrate` y `migrate force`.
- https://docs.github.com/en/actions/using-jobs/running-jobs-in-a-container y https://docs.github.com/en/actions/using-containerized-services — `container` y `services`, que son `D23` hecho YAML.
- https://github.com/rhysd/actionlint — lo que valida y lo que no.

**Libros**
- *Continuous Delivery* (Humble y Farley) — *"construye el binario una sola vez y promuévelo entre ambientes"* es 4.3 en su forma original.

**Video / apoyo**
- Busca "multi-stage docker build Go" y "static vs dynamic linking cgo": lo segundo aclara la pieza forense mejor que cualquier texto.

**Orden de lectura sugerido:** la página de multi-stage → *build constraints* antes de escribir la etiqueta de 5.1 → `bea-02` para la receta completa con sus errores → la documentación de Actions cuando el pipeline no arranque.

> ⚠️ URLs, títulos y ediciones pueden haber cambiado: verifícalos, y acá más que en ninguna otra fase: las versiones de las acciones se retiran varias veces al año, y el YAML de 5.5 va a envejecer antes que el resto del curso. Las cifras son de las corridas del 20/10/2026 en la máquina del autor (arm64). Cualquier discrepancia de versiones la resuelve `00-decisiones-y-versiones.md` §7.

---

## 🚀 9. Cierre del track

Se acabó. Diez fases, 86 horas, y un backend en Go contra PostgreSQL 13 que reemplazó a `json-server` sin que la consola cambiara **un solo archivo** —salvo el que la Fase 2 había señalado con el dedo—.

Lo que te llevas no es Go. Go es el vehículo, y en dos años puede ser otro. Lo que te llevas es esto: puedes tomar un contrato de API existente, **medirlo** en vez de adivinarlo, y reimplementarlo sin romper a quien lo consume. Sabes en qué capa vive de verdad cada bug de concurrencia, y por qué la consola nunca fue el lugar para arreglarlo. Sabes qué prueba puede correr contra SQLite y cuál te estaría engañando. Puedes seguir un `X-Request-Id` desde la consola del navegador hasta la consulta que lo produjo. Y sabes decir, con números, cuándo reemplazar un mock **no** valía la pena.

Y una cosa más, que el track base no podía darte. Volviste a mirar los mismos bugs desde el otro lado del cable y descubriste que **la mitad de los que parecían de la consola no lo eran**. La compensación doble de la Fase 5. La rueda que cerraba con el reloj del navegador en la Fase 7. La conciliación de la Fase 8, que calculaba con lo que tenía cargado. Los tres se veían desde el navegador y ninguno se resolvía ahí.

> **La señal de que quedó bien:** *"apagué el mock, levanté mi imagen, y la única forma de notar el cambio fue que la Esclusa de Oro dejó de entregarse de más."*

> 🏷️ **No cierres la fase sin el tag.** Con el checklist de la sección 2 en verde y `git status` limpio:
>
> ```bash
> git tag -a fase-be09-empaquetado-ambientes-y-pipeline -m "be09 cerrada: \
> binario de producción sin cgo y sin SQLite (D19 medida en tres escenarios); \
> imagen distroless fijada por digest; migraciones como paso previo y comprobación de versión al arrancar; \
> compose de punta a punta con la consola; pipeline validado con actionlint; server/VEREDICTO.md escrito"
> ```
>
> Y el tag que cierra el track entero:
> `git tag -a track-be-completo -m "🔥 Track BE terminado: 10 fases, 86 horas, frontend intacto"`.
>
> Los commits de la fase llevan su prefijo (`be09: …`) y los de ejercicio su número (`be09 ej27: …`). Todo eso está en [`00-convencion-de-git-y-tags.md`](00-convencion-de-git-y-tags.md).

---

## 📌 Pendientes sugeridos

*(Fuera de lo que lee el estudiante.)*

- **`D19` cerrada con números** (5.2): la etiqueta, no el cambio de driver; `modernc.org/sqlite` v1.19.5, medido y descartado. **`D38`** (nueva): las imágenes base fijadas por digest. **`D31`** suma las acciones de Docker del trabajo `image`.
- **El veredicto no recomienda la salida de 2028** (historia §3, *Hoy*): da criterios. Es una decisión del autor del curso.
- **`.github/` es el único archivo fuera de `server/`** que agrega el track; la regla del `git diff` lo excluye explícitamente desde esta fase.
- **El `import _ "time/tzdata"` no se agrega**: el API no carga zonas, y distroless *static* trae la base. Las recetas viejas lo pedían por `scratch`.
- **El YAML de 5.5 es lo que más rápido envejece.** Revisarlo en cada revisión editorial.
- **`bea-09` recibe la lista completa del §5.6**, ordenada por lo que la vuelve exigible.
- **Reserva para el cuaderno de incidentes:** `be-16` — *la imagen de ayer no arranca y el código no cambió* (🔥 despliegue, 🟠). Desde be09 la imagen ya no tiene cgo; la rama lo vuelve a encender en el `Dockerfile`.
