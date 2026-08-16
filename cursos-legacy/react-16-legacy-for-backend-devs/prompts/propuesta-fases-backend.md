# 🗺️ Propuesta de fases, apéndices y alcance — Track BE

Documento de encuadre del **track opcional de backend** del tutorial *React 16
Legacy — Rifas y Chances S.A.S.* Define por qué existe, qué cobra, cuánto pesa,
qué versiones congela y cómo se reparte en fases y apéndices.

> **Estado:** aprobada. Las tres preguntas abiertas de la primera versión se
> cerraron el 4/09/2026 y viven ahora como decisiones en §11; los nueve
> documentos de §10 ya están ajustados y los prompts iniciales escritos.
> **Fecha:** 4 de septiembre de 2026.
> **Track base afectado:** ninguno. Las fases 0-11 no cambian ni una línea.
> **Fuentes de verdad que respeta:** `prompts/instrucciones-del-proyecto.md`,
> `00-alcance-del-proyecto.md`, `prompts/decisiones-y-versiones.md`,
> `prompts/guia-de-estilo-y-convenciones.md`, `prompts/plantilla-de-fase.md`.
> **Documentos que obliga a tocar:** ver §10.

---

## 🧭 1. En una frase

Diez fases opcionales que **reemplazan el mock del puerto 3001 por un backend
real en Go 1.19 contra PostgreSQL**, sin que el frontend heredado se entere, y
que usan ese reemplazo para cobrar —una por una— las deudas técnicas 💸 que el
track base declaró a propósito y no podía pagar.

La señal de éxito es verificable y se enuncia en una línea:

> 🧭 **Se apaga `json-server`, se levanta el binario de Go en el mismo puerto
> `3001`, y la aplicación React no cambia ni un archivo.**

Si para que la app funcione hay que tocar `apiClient`, un slice o un epic, el
track falló, por bonito que haya quedado el backend.

---

## ✅ 2. Decisiones cerradas

Estas ya no se discuten en los chats siguientes.

| Pregunta | Decisión | Consecuencia |
|---|---|---|
| ¿Curso aparte o mismo curso? | **Mismo curso, mismo directorio**, track opcional | Un solo README, una sola guía de estilo, un solo diccionario |
| ¿Numeración? | Fases `beNN-tema.md` (be00–be09), apéndices `bea-NN-tema.md` | No colisiona con `NN-` ni con `AN-` del track base |
| ¿Obligatorio? | **No.** El track base se completa con el mock y las 96h no cambian | El track BE se marca 🔥 en el README; sus horas se declaran aparte |
| ¿Prerrequisito? | **Fase 8 del track base terminada** | Es el corte exacto: antes no existen liquidaciones ni el contrato completo. El dashboard (Fase 9) queda fuera del contrato obligatorio |
| ¿Lenguaje? | **Go 1.19**, monolito de un binario | Ver §5 para el porqué de la versión |
| ¿Base de datos? | **PostgreSQL 13** en dev/QA/UAT/PROD; **SQLite** solo en pruebas | La regla que decide cuál se usa está en `be08`, no en el gusto |
| ¿El mock de lotería (`3002`)? | **Se queda en Node, intacto** | Es un proveedor externo, no es nuestro. Borrar esa frontera cuesta pedagogía |
| ¿El middleware de caos? | **Se reimplementa en Go**, con doble control: ruta `POST /_chaos` y variable de entorno, apagado por defecto | Las fases 3 y 7 del track base entrenan contra él; no puede desaparecer |
| ¿Relación con otros cursos? | **Ninguna.** Este track no sabe que existen otros cursos | Todo lo de contenedores y CI que se necesite vive en `bea-02` |
| ¿ORM? | **No.** `database/sql` + `sqlx` | El dialecto tiene que quedar a la vista; es el contenido de `be02` |
| ¿Datos de prueba? | **El `db.json` del propio alumno** como semilla; faker como camino 🔥 | La semilla real hace el reemplazo creíble; el faker se necesita recién cuando hay que medir con volumen |

---

## 💸 3. Por qué existe este track: las seis deudas que cobra

El track base no dejó sus atajos por descuido. Los declaró, los marcó y anunció
dónde se pagarían. Lo que pasa es que **ninguno se puede pagar desde el
frontend**, porque todos viven del otro lado de HTTP. Ese es el hueco que este
track llena, y por eso no es un curso de Go pegado con cinta: es el segundo acto
de una obra que ya estaba escrita.

**La primera es la autenticación.** La Fase 2 lo dice con todas las letras: el
token es una constante escrita a mano en `db.json`, json-server compara
contraseñas en claro, y *"lo correcto —un endpoint `POST /login` que valide y
firme un JWT— vive del lado del backend real"*. El interceptor de `apiClient` ya
manda `Bearer ${token}` con el formato correcto desde el día uno, justamente
para que el día que el token sea real no haya que tocar ese archivo. `be04`
cobra esa promesa.

**La segunda es la venta concurrente.** La Fase 5 es una de las dos ⭐ del curso
y estudia las race conditions donde el frontend puede estudiarlas: en el store,
con doble click y peticiones que se cruzan. Pero la verdad incómoda es que
**ninguna race condition de venta se resuelve en el cliente**. La Fase 3 ya dejó
montada la ruta `POST /raffles/:id/numbers/:number/sell` devolviendo `409` ante
venta duplicada, y ese `409` hoy lo produce un `if` en JavaScript sobre un
archivo JSON. `be05` lo produce donde corresponde: un índice único y una
transacción con `SELECT … FOR UPDATE`. El alumno ve el mismo síntoma resuelto en
dos capas distintas y entiende cuál de las dos es la que de verdad protege.

**La tercera es el tiempo.** La Fase 7 vive de una hora de cierre dura con zona
horaria, y hoy esa hora la evalúa el navegador contra un campo de texto en un
JSON. Un reloj de cliente es un reloj que el usuario controla. `be06` mueve la
autoridad temporal al servidor con `TIMESTAMPTZ`, y de paso convierte el
problema en el que de verdad muerde en producción: qué pasa cuando el servidor
está en UTC, la base en otra zona y el vendedor en una tercera.

**La cuarta es el dinero.** El apéndice A10 ya enseñó aritmética en centavos
enteros y la Fase 8 la aplica. Falta la otra mitad: que la base **también**
guarde enteros, que la liquidación ocurra dentro de una transacción, y que un
reparto que no cuadra reviente en el servidor en vez de mostrarse mal en una
tabla. `be07`.

**La quinta es la confianza en el cliente.** Hoy quien crea una rifa, quien la
cierra y quien la liquida es quien el navegador dice que es, y las transiciones
del flujo `borrador → abierta → cerrada → resuelta → liquidada` las decide el
frontend sin que nadie verifique. `be04` saca la identidad de `req.Context()` y
custodia las transiciones en el servicio.

**La sexta es la trazabilidad.** El interceptor de la Fase 2 lee y loguea el
`X-Request-Id` que devuelve el mock, y A13 enseña a correlacionar UAT contra
PROD con él. En el mock, ese id nace y muere en el middleware. En Go viaja por
`context.Context` hasta el log de la query, y entonces la correlación deja de
ser un ejercicio y se vuelve una herramienta: un id que el alumno copia de la
consola del navegador y encuentra en el log del backend, con la SQL que ejecutó
y cuánto tardó.

> 🧠 **La tesis del track, en una frase.** El track base enseña a diagnosticar
> con lo que se ve desde el navegador. El track BE enseña que **la mitad de los
> bugs que parecían del frontend no lo eran**, y da el otro lado del cable para
> demostrarlo.

---

## 🚫 4. Reglas no negociables

**El frontend no se toca.** Ni un componente, ni un slice, ni un epic, ni el
`baseURL`. El backend se adapta al contrato existente, nunca al revés. Si una
fase necesita cambiar el frontend, la fase está mal diseñada. La única excepción
posible se negocia en `be00` y se registra ahí con nombre y apellido.

**El contrato manda sobre la elegancia.** json-server tiene un dialecto y el
frontend lo consume: `_page`, `_limit`, `_sort`, `_order`, `q`, el header
`X-Total-Count`, el `404` con cuerpo vacío, el `POST` que devuelve el recurso
creado con su `id`. Reimplementarlo en Go es *aburrido y correcto*. Un backend
"mejor diseñado" que rompe el contrato es un backend roto.

**Autocontención estricta.** Este track no remite a ningún otro curso, aunque
exista uno de contenedores en el catálogo. Todo lo que el alumno necesita para
construir la imagen y el pipeline vive en `bea-02`, escrito como receta cerrada
y verificable. Ninguna fase dice "confírmalo contra tu entorno real" ni deja una
versión pendiente.

**Idioma, igual que siempre.** Narrativa, comentarios y textos de interfaz en
español latinoamericano con tuteo. Código en inglés, incluido Go: paquetes,
tipos, funciones, campos de struct, tags de JSON, nombres de tabla y de columna.
Los términos del dominio salen de `prompts/diccionario-codigo-ingles.md`, que
gana un anexo Go (§10) para que `Raffle`, `RaffleNumber`, `Participant` y
`Settlement` signifiquen exactamente lo mismo a los dos lados del cable.

**Nada de Go moderno gratuito.** Sin `slog`, sin `errors.Join`, sin
`net/http.ServeMux` con patrones de método, sin genéricos donde el código de
2022 no los usaba. Aparecen como comparación 🔥, igual que React 18 en el track
base.

---

## 🛠️ 5. Stack y versiones

La época objetivo es **2022**: el borde final de la ventana del track base. La
ficción es coherente con `00-historia-del-sistema.md` — el frontend es de la
segunda era y este backend se escribió después, cuando la empresa por fin
aceptó que `db.json` no era un backend.

| Pieza | Versión | Por qué esta y no otra |
|---|---|---|
| Go | **1.19.13** | Agosto 2022. Genéricos disponibles y deliberadamente no usados; `go.mod` con `go 1.19` sigue compilando con toolchains actuales |
| Router HTTP | `gorilla/mux` **1.8.0** | El default absoluto de la época. Se archivó a fines de 2022 y volvió a mantenerse después: una dependencia que muere y resucita es contenido 💸, no un accidente |
| JWT (inicial) | `dgrijalva/jwt-go` **v3.2.0** | Abandonado y con CVE conocido. Se adopta a propósito en `be04` |
| JWT (destino) | `golang-jwt/jwt` **v4.4.2** | El fork oficial. La migración es media fase y un post-mortem |
| Hash de claves | `golang.org/x/crypto/bcrypt` | Sin discusión: es lo que había y sigue estando bien |
| Acceso a datos | `database/sql` + `jmoiron/sqlx` **1.3.5** | Deja el dialecto a la vista. Un ORM escondería justo lo que enseña `be02` |
| Driver PostgreSQL | `lib/pq` **v1.10.7** | El clásico de la época, hoy en modo mantenimiento. `pgx/v4` se discute, no se usa |
| Driver SQLite | `mattn/go-sqlite3` **v1.14.16** | Exige `CGO_ENABLED=1`: rompe Alpine, mata el cross-compile y engorda la imagen. Es un "en mi máquina anda" de manual, y rima con A3 |
| Alternativa SQLite | `modernc.org/sqlite` **v1.19.x** | Puro Go, sin cgo. Elegir entre las dos **es** el ejercicio central de `be09` |
| Migraciones | `golang-migrate/migrate` **v4.15.2** | Dos archivos SQL por versión. Obliga a decidir si el DDL es común o por dialecto |
| Configuración | `os.Getenv` + `flag`, o `kelseyhightower/envconfig` **v1.4.0** | Viper es artillería innecesaria para un monolito |
| Pruebas | `testing`, `net/http/httptest`, `stretchr/testify` **v1.8.1** | Suficiente y de época |
| Datos falsos 🔥 | `brianvoe/gofakeit` **v6.19.x** | Solo para el apéndice `bea-10` y sus ejercicios. No es dependencia del backend |
| PostgreSQL | **13.x** | Septiembre 2020. Lo que tenía media industria en 2022 |
| SQLite | **3.35 o superior** | Cota mínima por `RETURNING`, que llegó en marzo de 2021 |
| Imagen base | `golang:1.19-bullseye` → `debian:bullseye-slim` | Multi-stage. **No Alpine** mientras haya cgo; esa decisión se documenta en `bea-02` |
| Pipeline | GitHub Actions con `container: golang:1.19` y `services: postgres:13` | Ver la nota de las dos edades, abajo |

### Las dos edades del pipeline

Un workflow escrito con las acciones de 2022 **no corre hoy**: los runners
actuales rechazan las versiones de `actions/*` de aquella época. En vez de
fingir, el track separa las dos edades y lo dice en voz alta: **la aplicación es
de 2022 y el pipeline es de hoy, y el pipeline corre el Go de 2022 dentro de un
contenedor**. Es reproducible, es honesto, y es exactamente la conversación que
tiene un equipo de mantenimiento cuando le toca revivir un repo dormido. Ese
contraste es contenido de `be09`, no un problema a esconder.

### Puertos

Cuatro procesos. Los tres primeros ya existen en `decisiones-y-versiones.md` §5
y no se mueven.

- **`3000`** — dev server de CRA. Sirve la SPA.
- **`3001`** — **antes** `json-server`; **después de `be03`**, el binario de Go.
  Es el mismo puerto a propósito: el frontend no debe enterarse.
- **`3002`** — mock de lotería en Express. Sigue en Node, sigue fallando.
- **`5432`** — PostgreSQL en contenedor. Si el alumno ya tiene un Postgres
  local, se publica en `5433`; la variable de entorno lo cubre y `bea-02` lo
  explica.

> ⚠️ **Verifica cada número al instalar.** Los módulos se mueven de path, los
> registros cambian y un `go list -m -versions <módulo>` te saca de dudas en
> cinco segundos. Lo mismo vale para el CVE de `jwt-go` y para las fechas de
> archivado de `gorilla/mux`: cítalos desde el aviso oficial, nunca de memoria.

---

## ⏱️ 6. Presupuesto de horas

El track base **sigue siendo de 96 horas** y no cambia. El track BE declara las
suyas aparte, y son menos, porque el alumno ya trae el dominio aprendido: no
tiene que entender qué es una reserva ni por qué el dinero va en centavos.

| Bloque | Fases | Horas |
|---|---|---|
| Contrato y cimientos | be00–be02 | 24h |
| El reemplazo y la identidad | be03–be04 | 18h |
| Las tres fases del dominio | be05–be07 | 24h |
| Pruebas y entrega | be08–be09 | 18h |
| **Total track BE** | **10 fases** | **84h** |

Los apéndices no cuentan: son consulta bajo demanda, igual que A1-A13.

---

## 🌳 7. Las diez fases

Cada una usa la plantilla obligatoria de nueve secciones
(`prompts/plantilla-de-fase.md`) y cierra con sus 📌 pendientes fuera de lo que
lee el alumno. Ejercicios: 25 mínimo, 30-35 ideal, con al menos un tercio de
diagnóstico. Cada fase nombra su **pieza forense**, que en este track suele ser
un log, un `EXPLAIN` o una transacción bloqueada en vez de un DevTools.

### 📜 be00 — El contrato: auditoría del mock (6h)

La fase que ordena todo el track y la única que no escribe una línea de Go. Se
audita el mock existente hasta dejar por escrito **el contrato que el backend
tendrá que honrar**: cada endpoint que el frontend consume, con su método, su
forma de entrada, su forma de salida, sus códigos de error y sus rarezas de
json-server. Se separa el **régimen estricto** —lo que no puede cambiar porque
el frontend lo consume tal cual— del **régimen de crecimiento** —lo que el
backend puede añadir sin romper nada.

Entra: inventario de rutas (`/raffles`, `/numbers`, `/participants`,
`/settlements`, `/users`, `POST /login`, las tres rutas propias de la Fase 3 y
`POST /_chaos`); el dialecto de json-server; el header `X-Request-Id`; el
checklist de smoke test que se ejecuta al final de `be03` y de cada fase
posterior.

Pieza forense: capturar con la pestaña Network **todas** las peticiones que hace
la app en un recorrido completo, y convertir esa captura en el contrato. No se
adivina lo que consume el frontend: se mide.

Deuda que cobra: ninguna. Prepara el terreno para cobrarlas todas.

### 🐹 be01 — Go 1.19 y la forma del monolito (8h)

Entra: `go.mod` y el layout del proyecto en `server/`; `net/http` y `gorilla/mux`;
la cadena de middlewares (recuperación de pánico, CORS para el `3000`, logging,
`X-Request-Id`); `context.Context` como el vehículo transversal; manejo de
errores con `error` explícito y sin excepciones; apagado ordenado con
`http.Server.Shutdown`; y el primer endpoint vivo, `GET /health`.

Se reimplementa aquí el **middleware de caos**, apagado por defecto y con
**dos controles**: la misma ruta `POST /_chaos` que expone el mock —para que las
prácticas de las fases 3 y 7 del track base sigan funcionando sin cambios— y una
variable de entorno `CHAOS_LEVEL` que fija el nivel al arrancar. No es
redundancia: la ruta sirve para el laboratorio interactivo y la variable para
levantar un ambiente ya degradado, que es como se reproduce un incidente sin
tocar el proceso. Cuál gana cuando se contradicen se decide y se documenta en la
fase; la propuesta dice que gana la última orden recibida, y que el arranque
cuenta como orden.

Pieza forense: un pánico dentro de un handler. Sin `recover`, tumba el proceso
entero y el navegador solo ve una conexión cortada. Es la primera lección
cultural de Go para quien viene de Node.

Sale a `bea-01`: la sintaxis de Go para quien no escribe Go.

### 🗄️ be02 — La costura de datos y el mito de la agnosia (10h)

La fase incómoda y honesta. **La portabilidad total no existe**; lo que existe
es portabilidad por disciplina, con una costura donde el dialecto se hace
explícito en vez de esconderse.

Entra: `database/sql` y el pool de conexiones; `sqlx` y el `Rebind` para los
placeholders (`?` contra `$1`); migraciones con `golang-migrate`; el esquema
completo de `raffles`, `raffle_numbers`, `participants`, `settlements` y
`users`; y el inventario medido de dónde se rompe la agnosia: identidades
autoincrementales, `RETURNING`, booleanos, tipos de fecha —que en SQLite
sencillamente no existen—, y semántica de bloqueo.

Pieza forense: la misma consulta corriendo contra los dos motores y devolviendo
resultados distintos. No se argumenta la diferencia: se muestra.

Sale a `bea-03`: el diccionario completo de divergencias.

### 🪦 be03 — CRUD de rifas y el momento del reemplazo (10h)

**La bisagra del track.** Se implementan los recursos del contrato con la
arquitectura en capas del monolito (handler → service → store), se siembra la
base **desde el `db.json` que el alumno ya tiene** —no desde un dump que
entreguemos nosotros: que los datos sean los suyos es justamente lo que hace
creíble el reemplazo— y entonces ocurre la prueba de fuego: se
apaga `json-server`, se levanta el binario en el `3001` y se recorre la
aplicación entera **sin tocar el frontend**.

El checklist de smoke test de `be00` es el criterio de aprobación, y no es
opinable: pasa o no pasa.

Pieza forense: una discrepancia de contrato encontrada por el frontend, no por
un test. Típicamente un campo que json-server devolvía como número y Go
serializa como string, o una lista que llegaba envuelta. Es la forma real en que
aparecen estos bugs.

🔥 **Ejercicio opcional de esta fase:** generar volumen con un faker. Cincuenta
rifas y veinte mil números no se escriben a mano, y sin volumen las mediciones de
`be05` y `be08` no dicen nada. El apéndice `bea-10` trae la receta y las
referencias.

Deuda que cobra: `db.json` como almacén. 🪦 Retiro formal de json-server.

### 🔐 be04 — Identidad real: bcrypt, JWT y un CVE (8h)

Entra: `POST /login` que valida contra un hash bcrypt y firma un JWT cuyo string
viaja en el **mismo campo `token`** que el frontend ya lee, de modo que el
interceptor de la Fase 2 sigue funcionando sin cambios; middleware de
verificación; identidad tomada de `req.Context()` y no del cuerpo de la
petición; y transiciones del flujo custodiadas en el servicio.

Y el plato fuerte: se adopta `dgrijalva/jwt-go` **a propósito**, se descubre que
está abandonado y tiene un CVE de manejo de audiencia, y se migra al fork
`golang-jwt/jwt`. El alumno escribe el post-mortem sin culpabilización que pide
la guía de estilo §13.

Pieza forense: un token manipulado. Cambiar el payload en jwt.io, reenviar la
petición, y ver la firma fallar — y después ver qué pasa si el servidor acepta
el algoritmo `none`.

Deudas que cobra: token de mentira, contraseñas en claro, cliente mentiroso,
transiciones libres.

> 🔀 **Nota de contrato.** El JWT introduce expiración, que el token de `db.json`
> no tenía. El frontend no implementa refresh. Esa fricción **se declara como
> deuda viva**, se le da una vida larga al token para el laboratorio, y se
> convierte en incidente reservado en vez de en un cambio al frontend.

### ⚔️ be05 — ⭐ Venta concurrente resuelta donde se resuelve (10h)

La contraparte de la Fase 5 del track base y una de las dos ⭐ de este track.

Entra: índice único como última línea de defensa; transacciones y niveles de
aislamiento; `SELECT … FOR UPDATE` frente a `INSERT … ON CONFLICT`; reservas con
expiración y el trabajo que las vence; el `409` producido por la base y no por
un `if`; y una comparación medida entre bloqueo pesimista y optimista sobre el
mismo caso.

Pieza forense: dos clientes concurrentes peleando por el número 0347 desde la
línea de comandos, y la transacción bloqueada observada desde
`pg_stat_activity`. El alumno **ve** el bloqueo, no lo imagina.

Y el remate: el mismo escenario contra SQLite, donde no hay `FOR UPDATE` y
aparece un `SQLITE_BUSY`. Es la evidencia que justifica la regla de `be08`.

### 🕐 be06 — Hora dura, zonas horarias y la autoridad del reloj (8h)

Entra: `TIMESTAMPTZ` frente a `TIMESTAMP` y por qué la diferencia es una
factura; la hora de cierre evaluada en el servidor; el rechazo de venta tras el
cierre como regla de negocio y no como validación de formulario; serialización
en RFC 3339; y el desfase entre el reloj del cliente y el del servidor, expuesto
a propósito.

Pieza forense: adelantar el reloj del navegador y comprobar que el frontend deja
vender y el backend no. Es la demostración de una sola pantalla de por qué la
autoridad temporal vive del lado del servidor.

Deuda que cobra: la hora de cierre evaluada en el cliente.

### 💰 be07 — Liquidación: dinero entero y transaccional (6h)

Entra: `BIGINT` en centavos, coherente con A10; el cálculo del premio dentro de
una transacción; el reparto que cuadra al centavo y la política explícita para
el residuo; idempotencia de la liquidación; y la trazabilidad como registro
inmutable en vez de como campo actualizable.

Pieza forense: una liquidación interrumpida a la mitad. Con transacción, no pasa
nada. Sin ella, la base queda con dinero repartido y la rifa sin liquidar.

### 🧪 be08 — Pruebas por niveles y la regla del motor (10h)

Entra: `httptest` para handlers; suite de contrato que verifica el checklist de
`be00` endpoint por endpoint; pruebas de integración contra Postgres en
contenedor; pruebas de concurrencia con goroutines; y `go test -race`.

Y el contenido central, que es una regla y su justificación:

> 🧭 **SQLite vale para pruebas que no tocan concurrencia, bloqueos, zonas
> horarias ni SQL específico del motor. En cuanto una prueba toca cualquiera de
> las cuatro, corre contra PostgreSQL o no vale.**

No se enuncia como opinión: se demuestra con una prueba que **pasa en SQLite y
falla en Postgres**, y con otra que hace lo contrario. Una suite verde contra el
motor equivocado es peor que no tener suite, porque da permiso para desplegar.

Pieza forense: exactamente ese par de pruebas.

### 📦 be09 — Empaquetado, ambientes y pipeline (8h)

Entra: build multi-stage; la decisión cgo contra puro Go con su medición de
tamaño y de tiempo de compilación; configuración por variables de entorno para
los cuatro ambientes; migraciones ejecutadas en el arranque frente a ejecutadas
como paso previo del despliegue; y un workflow de GitHub Actions que compila,
prueba contra los dos motores y publica la imagen.

Cierra el track con el **veredicto honesto**: qué quedó mejor que el mock, qué
quedó peor, qué deudas siguen vivas —el refresh token, entre ellas— y cuándo
**no** vale la pena reemplazar un mock por un backend propio.

Pieza forense: la imagen que compila en la máquina del alumno y no en el runner,
o al revés. El clásico de cgo, musl y arquitectura.

---

## 📎 8. Los apéndices

Consulta, no lectura corrida. Se abren cuando una fase manda a ellos. Entre 5 y
10 ejercicios cortos cada uno, contra el laboratorio propio.

| Archivo | Qué resuelve |
|---|---|
| `bea-01-go-para-quien-no-escribe-go.md` | Go mínimo para un senior de otro lenguaje: paquetes, `error` en vez de excepciones, interfaces implícitas, punteros, `context`, goroutines y el modelo de concurrencia |
| `bea-02-receta-de-imagen-y-compose.md` | **La receta rápida.** Dockerfile multi-stage copiable, `docker-compose.yml` con Postgres y el backend, comandos de arranque, y los tres errores que salen siempre. Cerrado y autocontenido |
| `bea-03-sql-portable-y-dialectos.md` | Diccionario de divergencias SQLite ↔ PostgreSQL: placeholders, identidades, fechas, booleanos, `RETURNING`, bloqueo, y qué hacer con cada una |
| `bea-04-jwt-por-dentro-y-su-cve.md` | Anatomía de un JWT, algoritmos, el ataque `alg: none`, el CVE de `jwt-go`, y cómo se lee un aviso de seguridad |
| `bea-05-concurrencia-en-postgres.md` | Niveles de aislamiento, `FOR UPDATE` y sus variantes, `ON CONFLICT`, deadlocks, y cómo observarlos |
| `bea-06-tiempo-zonas-y-relojes.md` | UTC como única verdad, `TIMESTAMPTZ`, RFC 3339, horario de verano, y el reloj del cliente como fuente de bugs |
| `bea-07-logs-request-id-y-correlacion.md` | Log estructurado, propagación por `context`, y el recorrido completo de un `X-Request-Id` desde la consola del navegador hasta la query |
| `bea-08-seguridad-de-api-aplicada.md` | OWASP sobre este dominio: inyección SQL, autorización a nivel de objeto, asignación masiva, límites de tasa y qué exponen los mensajes de error |
| `bea-09-mapa-de-deuda-del-track-be.md` | Qué quedó feo a propósito en el backend, qué lo vuelve exigible y en qué orden se pagaría. Hermano de A12 |
| `bea-10-datos-de-prueba-y-faker.md` 🔥 | Sembrar y generar datos: la semilla desde `db.json`, faker para volumen, datos deterministas con semilla fija, y por qué un dataset aleatorio arruina una prueba de regresión |

`bea-02` es el que más cuidado necesita: es el único punto donde el track toca
contenedores, y tiene que funcionar de principio a fin sin remitir a nada
externo.

---

## 📐 9. Convenciones de archivo

Fases: `be00-tema.md` a `be09-tema.md`, minúsculas con guiones, igual que el
track base. Apéndices: `bea-01-tema.md` a `bea-10-tema.md`. El prefijo `be`
mantiene los tres bloques ordenados y separados dentro del mismo directorio: las
fases base (`00-` a `11-`), sus apéndices (`A1-` a `A13-`) y el track BE.

El código de ejemplo del backend se referencia como `server/…` dentro del mismo
proyecto del alumno. El frontend sigue en la raíz, sin moverse.

---

## 🔧 10. Documentos existentes que hay que tocar

Ninguno de estos cambios altera el contenido del track base; todos son
adiciones. Se hacen **antes** de escribir `be00`, para que las fases nuevas
tengan a qué referirse.

1. **`README.md`** — sección nueva del track opcional 🔥, con su tabla de fases,
   su tabla de apéndices, su presupuesto de horas declarado aparte de las 96, y
   el prerrequisito.
2. **`prompts/decisiones-y-versiones.md`** — bloque de decisiones del backend
   (continuando la numeración D14 en adelante), el `go.mod` completo, qué
   instala cada fase BE, y el cuarto puerto. Sigue siendo la fuente de verdad
   única de versiones, ahora también para Go.
3. **`prompts/diccionario-codigo-ingles.md`** — anexo Go: nombres de paquete,
   tipos, campos de struct, tags JSON, tablas y columnas. `Raffle` tiene que
   significar lo mismo en el slice y en el store.
4. **`prompts/guia-de-estilo-y-convenciones.md`** — registrar la convención
   `beNN-` / `bea-NN-`, las reglas de estilo de código Go, y que la plantilla de
   nueve secciones también aplica al track BE.
5. **`prompts/instrucciones-del-proyecto.md`** — párrafo del track opcional en el
   bloque de alcance, para que un chat nuevo sepa que existe y que es opcional.
6. **`00-alcance-del-proyecto.md`** — el track BE en la sección de alcance, con
   su declaración explícita de opcionalidad.
7. **`CLAUDE.md`** (raíz del repositorio) — la convención de nombres de archivo
   del track BE en la sección de *File Naming Conventions*.
8. **`prompts/prompts-backend-fase.md`** y
   **`prompts/prompts-backend-apendice.md`** — archivos nuevos, no adiciones a
   los juegos existentes: el track BE tiene sus propias fuentes de verdad y
   mezclarlo con los prompts del track base haría que un chat de la Fase 4
   arrastrara contexto de Go que no necesita. Contienen los prompts **A** —los
   que cargan contexto y confirman encuadre—; los prompts B de solicitud de
   redacción se escriben en el mismo chat, cuando el modelo confirmó el
   contexto.
9. **`cuaderno-incidentes.md`** — reserva de un rango de IDs para los incidentes
   que produce el track BE, sin redactarlos todavía. El cuaderno ya tiene un
   hueco declarado; este track no lo agranda, solo reserva su espacio.

---

## ⚖️ 11. Riesgos y decisiones de detalle

### Los dos riesgos que hay que vigilar

**El riesgo de tamaño.** Diez fases de backend pueden crecer hasta convertirse
en un curso de Go, y este track no lo es. El antídoto: **cada fase tiene que
poder responder qué deuda del track base cobra**. La que no pueda, sobra. `be01`
y `be02` son las más expuestas a esta deriva y las que hay que vigilar al
escribirlas.

**El riesgo de contrato.** El frontend consume detalles del dialecto de
json-server que hoy no están inventariados en ninguna parte. Si `be00` los
audita mal, `be03` falla y el alumno pierde la fe en el track. Por eso `be00` se
apoya en una captura real de Network y no en la lectura del código.

### Tres decisiones de detalle, ya cerradas

**El corte de entrada es la Fase 8 del track base.** Es el punto exacto donde el
dominio está completo: existen rifas, números, participantes, resultados y
liquidaciones, y por lo tanto existe todo lo que el backend tiene que servir. La
Fase 9 (dashboard) queda **fuera del contrato obligatorio**, y con ella un
eventual `GET /stats`: hoy las métricas se calculan en el navegador y ahí se
quedan. Se registra como 🔥 en los pendientes de `be09` — un endpoint de
estadísticas es un buen ejercicio de agregación para quien terminó el curso
entero, pero ninguna fase puede depender de él ni el smoke test exigirlo.

**El caos se controla por los dos caminos.** La ruta `POST /_chaos` porque el
mock ya la expone y las prácticas del track base la usan tal cual, y la variable
de entorno `CHAOS_LEVEL` porque un ambiente que nace degradado es la forma de
reproducir un incidente sin tocar el proceso. Apagado por defecto en los dos
casos. La regla de precedencia —gana la última orden recibida, y el arranque
cuenta como orden— se escribe en `be01` y se prueba en `be08`.

**La semilla sale del `db.json` del propio alumno.** No entregamos un dump. Que
los datos que aparecen tras el reemplazo sean exactamente los que el alumno vio
en el track base es la mitad del efecto de `be03`: el mock se apagó y la
aplicación sigue mostrando *sus* rifas. Un dataset ajeno rompe esa continuidad y
además contradice la autocontención.

Dicho eso, la semilla real no alcanza para todo. Cincuenta rifas y veinte mil
números no se escriben a mano, y sin volumen las mediciones de `be05`
(concurrencia) y `be08` (índices y tiempos) no dicen nada. Por eso entra
**`bea-10` como apéndice opcional 🔥 de datos de prueba y faker**: cómo generar
volumen con `gofakeit`, cómo fijar la semilla del generador para que los datos
sean reproducibles, y —lo importante— **por qué un dataset aleatorio arruina una
prueba de regresión**. Ese último punto es el que justifica el apéndice: el
faker es una herramienta de carga y de medición, no de aserción. Las referencias
a tutoriales externos van ahí, con la advertencia habitual de verificarlas.

---

## 🎯 12. Criterio de éxito del track

No es "el alumno aprendió Go". Es esto, y se verifica:

Puede tomar un contrato de API existente y reimplementarlo sin romper a quien lo
consume. Sabe en qué capa vive de verdad cada bug de concurrencia, y por qué el
frontend nunca fue el lugar para arreglarlo. Sabe qué prueba puede correr contra
SQLite y cuál lo engañaría. Puede seguir un `X-Request-Id` desde la consola del
navegador hasta la consulta SQL que lo produjo. Y sabe decir, con argumentos,
cuándo reemplazar un mock por un backend propio **no** valía la pena.

> **La señal de que quedó bien:** *"apagué el mock, levanté mi binario, y la
> única forma de notar el cambio fue que el bug de la venta doble dejó de pasar."*
