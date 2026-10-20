# 🔁 Fase be03 — CRUD y el reemplazo

> Tutorial React 16 — La Esclusa, la consola de Jewel Locks · **Track BE opcional 🔥** · Fase be03 de be09 · **10 horas**
> Depende de: be02 — la capa de datos y las migraciones · Habilita: be04 — Identidad real

---

## 🎯 1. Propósito

Juliana lo dijo en la primera llamada y lo repite antes de esta fase: el API nuevo se hace *"sin que la consola cambie un archivo"* (`00-historia-del-sistema.md` §3, *Hoy*). Esta es **la bisagra del track**. Todo lo anterior fue preparación: se auditó un contrato, se levantó un servidor y se construyó una capa de datos. Acá se implementan los recursos de ese contrato en capas —handler → service → store—, se siembra la base con **el `db.json` que ya tienes**, y después se hace lo único que de verdad prueba que el trabajo sirvió:

> 🧭 **Se apaga el mock. Se levanta el binario de Go en el puerto `3001`. Se recorre la consola entera. Y el frontend no cambia ni un archivo.**

El criterio de aprobación no es una opinión ni una sensación: es `server/smoke.sh`, escrito en `be00` contra el mock, ejecutado sin modificar una línea contra tu binario. **Pasa o no pasa.**

La deuda 💸 que cobra es la primera de las grandes: `db.json` como almacén. Y con ella se retira el mock del `3001`. 🪦 Las otras deudas que el contrato registró —el giro sin transacción, el chequeo de caso que no protege, la conciliación que el servidor no verifica— se reimplementan **tal cual**, con un comentario que dice qué fase las paga. Un reemplazo que además "arregla cosas" deja de ser verificable: si algo cambia, ya no sabes si fue el reemplazo o el arreglo.

---

## ✅ 2. Qué queda listo al terminar

- [ ] La configuración sale de un único struct validado con `envconfig`, y el proceso **falla al arrancar** si falta algo, no en la primera petición.
- [ ] Las migraciones `000002` y `000003` aplicadas en los dos dialectos: el token de mentira y la forma completa de la conciliación.
- [ ] `server/internal/seed/` siembra Postgres desde `mock/db.json`, es idempotente, conserva los ids originales y le da a cada rueda su versión 1.
- [ ] Las rutas del régimen estricto de `server/CONTRACT.md` están implementadas en capas: handler → service → store.
- [ ] Las dos formas de `404` conviven según `C-04`: `{}` en lo automático y en lo desconocido, `{ "error": … }` en las rutas propias.
- [ ] `name_like` se comporta como en el mock: una expresión regular que no distingue mayúsculas, ni siquiera con tildes.
- [ ] El mock del `3001` está apagado y el binario escucha en el `3001`; el mock de Google Play del `3002` sigue vivo.
- [ ] **`./server/smoke.sh` pasa entero, con las diecisiete verificaciones en verde.**
- [ ] El recorrido completo de `be00` se repite contra el binario y no hay una sola diferencia visible en la consola.
- [ ] `git diff pre-backend-go..HEAD -- . ':!server'` no devuelve nada.

---

## 🚫 3. Qué queda fuera por ahora

- **Autenticación real** → `be04`. El login sigue devolviendo el token de mentira que el frontend espera, ahora guardado en una columna. Sí: vamos a crear una columna para almacenar una credencial falsa, y `be04` la va a borrar. Esa columna es la deuda 💸 hecha DDL.
- **El `409` producido por la base** → `be05`. Acá el giro decide con un `if` en Go sobre una fila leída antes, y el chequeo de caso del envío también. Es el **mismo `if` del mock, traducido de lenguaje**: sigue sin proteger nada bajo concurrencia, y ahora la deuda está escrita en un lenguaje compilado, que es peor porque parece seria.
- **La autoridad del reloj** → `be06`. El cierre de la rueda lo sigue evaluando la consola.
- **La conciliación recalculada en el servidor** → `be07`. Acá `POST /wheels/:id/reconciliation` guarda lo que manda el navegador (`C-07`) y ya.
- **La paginación de la bitácora.** El contrato pide las 10.000 filas de una vez, y así se sirven (régimen estricto, `be00`).

---

## 🧠 4. Conceptos mínimos

### Las tres capas, y qué se prohíbe en cada una

La estructura no es decorativa: cada capa tiene una prohibición, y las prohibiciones son las que hacen que el diseño sirva para algo.

**El handler** habla HTTP y nada más: lee la petición, valida la *forma* de la entrada, llama al service y traduce lo que vuelve a un código de estado y un JSON. *Prohibido:* tocar la base, decidir reglas de negocio.

**El service** tiene el dominio: qué cambios de pesos publican una versión, qué transiciones son legales, qué operaciones van juntas en una transacción. *Prohibido:* conocer `http.ResponseWriter`, códigos de estado o headers. Si un service devuelve un `404`, la capa se rompió.

**El store** habla SQL. *Prohibido:* tomar decisiones de negocio y dejar escapar un `sql.ErrNoRows` hacia arriba: se traduce a un error de dominio en la frontera, como ya hace `wheel.Store` desde `be02`.

La prueba de que las capas están bien puestas es un ejercicio mental de treinta segundos: **si mañana hubiera que exponer esto por gRPC o por una cola de mensajes, ¿cuánto código se reescribe?** Si la respuesta es "solo los handlers", está bien. Si hay que tocar el service, no.

### Reimplementar un dialecto ajeno es aburrido y correcto

Vas a escribir código que te va a dar comezón. `DELETE` que devuelve `{}` en vez de `204`. Dos formas distintas de `404` conviviendo en el mismo servidor. Un endpoint de login que filtra por query string. Un campo `token` que es una constante guardada en una tabla. Un giro que siempre cae en la Esclusa de Oro, porque así lo hace el giro de medición de la Fase 3. Una búsqueda que interpreta lo que escribe el operador como una expresión regular.

Todo eso está mal, y todo eso se implementa exactamente así.

> 🧭 **`D21`, dicho sin adornos.** Un backend "mejor diseñado" que obliga a cambiar el cliente es, para este curso, un backend roto. La única medida de calidad de esta fase es que el frontend no se entere.

La habilidad que se entrena acá no es escribir APIs bonitas: es **reemplazar una pieza de un sistema vivo sin que el resto se dé cuenta**. Es lo que hace falta para modernizar cualquier cosa que ya tenga usuarios, y es lo contrario del instinto que trae casi todo el mundo. El rediseño viene después, cuando ya controlas las dos orillas, y entonces se hace con una migración del cliente planificada, no de contrabando dentro de un reemplazo de backend.

### El punto peligroso: cómo serializa Go

En `json-server`, lo que devuelve la API es literalmente lo que hay en el archivo. No hay capa de serialización, no hay tipos, no hay conversión. En Go hay las tres, y ahí es donde se rompen los contratos.

Las cuatro reglas que hay que tener presentes todo el tiempo:

**Solo se serializan los campos exportados.** Un campo en minúscula no aparece en el JSON, sin aviso, sin error, sin nada. El síntoma es un objeto al que le falta justo el campo que importa.

**El tipo del campo decide la forma del JSON, y los tipos nulos de `database/sql` son una trampa.** Un `sql.NullString` no serializa a `null` ni a un texto: serializa a `{"String":"paid","Valid":true}`. Es la trampa de esta fase y es la pieza forense.

**Un campo que en el mock no existe no es lo mismo que un campo en `null`.** Las filas que escribe el giro de 2019 no tienen `wheelId` ni `origin`: en el mock, esas claves no están. Un puntero con `omitempty` las omite cuando son `nil`, y la respuesta queda igual a la del mock.

**`time.Time` serializa en RFC 3339, con el huso que traiga el valor.** Y el huso que trae depende de la zona de la **sesión** de Postgres, no de lo que guardaste (`be02`, Divergencia 0). `closesAt` tiene que salir con `-05:00`; los instantes que el mock guardaba con `toISOString()` —`createdAt`, `creditedAt`, `reconciledAt`— tienen que salir en UTC con milisegundos y `Z`. Son dos contratos distintos para el mismo tipo, y cada uno se cumple a propósito.

### Configuración: un struct que falla temprano

`be01` leyó variables con `os.Getenv` y lo declaró como deuda. Se paga acá, y no por elegancia: la configuración dispersa **falla tarde**. Un `DATABASE_URL` vacío con `os.Getenv` no rompe nada al arrancar; rompe en la primera petición de un operador, veinte minutos después del despliegue, con un error que no menciona la configuración.

`envconfig` mapea variables de entorno a un struct, aplica valores por defecto y —lo importante— marca lo obligatorio como `required:"true"`. El proceso muere en el segundo cero con un mensaje que dice qué falta. **Fallar temprano y ruidoso es una decisión de operación, no de estilo.**

---

## 💻 5. Implementación y código comentado

### 5.1 La configuración

```bash
cd server && go get github.com/kelseyhightower/envconfig@v1.4.0
```

<<<archivo:server/internal/config/config.go>>>

### 5.2 Las dos migraciones que esta fase necesita

Al implementar el contrato aparecen dos huecos del esquema de `be02`. No son descuidos que ocultar: son **exactamente lo que pasa cuando se diseña un esquema sin medir el cuerpo real de las peticiones**, y por eso se documentan.

**`000002` — la columna de la vergüenza.** El contrato dice que `GET /users?email=…&password=…` devuelve un objeto con un campo `token`, y ese token es una constante que vive en `db.json`. Para devolverlo hay que guardarlo.

<<<archivo:server/migrations/postgres/000002_add_user_token.up.sql>>>

**`000003` — el cuerpo real de una conciliación.** El `POST /wheels/:id/reconciliation` de la Fase 8 manda, además de los conteos y el chi-cuadrado, tres listas que la tabla de `be02` no previó: qué segmentos dieron alarma de banda, qué compras de la tienda no están acreditadas y cuáles se acreditaron dos veces. Las tres **no rompen nada visible** si faltan: el `INSERT` no las nombra, el `201` sale bien, la consola sigue andando. Se pierden en silencio, y la contadora las va a echar de menos en el cierre del semestre.

<<<archivo:server/migrations/postgres/000003_reconciliation_full_shape.up.sql>>>

En SQLite, las mismas columnas son `TEXT NOT NULL DEFAULT '[]'`, y los `down` usan `ALTER TABLE … DROP COLUMN`, que SQLite acepta desde la 3.35 (la tuya, medida en `be02`, es la 3.39.4). Antes de esa versión, ese `down` no se podía escribir.

```bash
migrate -path migrations/postgres -database "$DATABASE_URL" up   # 2/u add_user_token, 3/u reconciliation_full_shape
```

### 5.3 La siembra: `internal/seed`

La siembra sale de **tu** `db.json`, no de un dump nuestro. Que después del reemplazo aparezcan exactamente las ruedas, los jugadores y la bitácora que veías en el track base es la mitad del efecto de esta fase: el mock se apagó y la consola sigue mostrando *tus* datos.

<<<archivo:server/internal/seed/seed.go>>>

<<<archivo:server/cmd/seed/main.go>>>

```bash
go run ./cmd/seed -file ../mock/db.json
go run ./cmd/seed -file ../mock/db.json    # otra vez: no duplica nada
```

Corrida del 19/10/2026 contra `postgres:13`: `siembra completa desde ../mock/db.json en 144ms`, con las 10.000 filas de la bitácora de la Rueda de fin de mes, y la segunda vez igual.

### 5.4 El tipo que rompe el contrato, y cómo se arregla

Antes de escribir un solo handler, el problema que va a aparecer sí o sí.

Las columnas `wheel_id`, `origin`, `delivered_prize` y `purchase_token` de la bitácora son anulables, porque el giro de 2019 escribe filas sin ellas (`C-03`). Si las declaras `string`, el primer `NULL` revienta el `Scan` con `converting NULL to string is unsupported`. La forma directa de arreglarlo es `sql.NullString`, y **eso rompe el contrato en silencio**: el JSON sale `{"String":"paid","Valid":true}`, la consola compara `row.origin === "paid"` y un objeto nunca es igual a un texto.

La forma correcta es un puntero con `omitempty`: `sqlx` lo escanea igual de bien, y `encoding/json` omite la clave cuando es `nil`, que es exactamente lo que el mock devolvía.

<<<archivo:server/internal/spin/spin.go>>>

Y los instantes que el mock escribía con `toISOString()` tienen su propio tipo, para que salgan en UTC, con milisegundos y `Z`, por más que la sesión esté en Panamá:

<<<archivo:server/internal/jsontime/jsontime.go>>>

### 5.5 Los services: donde viven las reglas (y donde todavía no protegen)

La rueda: crear con su versión 1, editar publicando una versión nueva cuando cambian los pesos, el `409` en vivo, y los mensajes de la regla de pesos copiados del mock palabra por palabra.

<<<archivo:server/internal/wheel/service.go>>>

El store de la rueda suma lo que el CRUD de la Fase 4 necesita. La interfaz crece en `wheel.go`:

<<<fragmento:server/internal/wheel/wheel.go|type Store interface {|ListSegments(ctx context.Context, wheelID *int64) ([]Segment, error)
}>>>

<<<fragmento:server/internal/wheel/store.go|// Update cambia los datos de la rueda|return segments, nil
}>>>

Los jugadores y sus envíos. Fíjate en dos cosas: `name_like` se resuelve en Go y no en SQL, porque ningún `LIKE` de los dos motores honra una expresión regular que no distingue mayúsculas ni tildes (`be02`, Divergencia 6); y `SendGrant` comprueba, espera y anota, como el mock (`C-07`).

<<<archivo:server/internal/player/player.go>>>

Las compras y el catálogo, el login de la vergüenza y la conciliación que guarda lo que llega:

<<<archivo:server/internal/purchase/purchase.go>>>

<<<archivo:server/internal/auth/auth.go>>>

<<<archivo:server/internal/reconciliation/reconciliation.go>>>

### 5.6 Los handlers: traducir dominio a HTTP

<<<archivo:server/internal/http/handlers.go>>>

### 5.7 El router completo, y el arranque

<<<archivo:server/internal/http/router.go>>>

<<<archivo:server/cmd/api/main.go>>>

> 🧭 **La zona de la sesión va en el DSN.** `closesAt` tiene que salir con `-05:00` (verificación 3 de `smoke.sh`), y Postgres lo devuelve en la zona de la sesión. `lib/pq` pasa a la sesión cualquier parámetro del DSN que no sea suyo, así que basta con agregarlo: `DATABASE_URL="postgres://esclusa:esclusa@localhost:5432/esclusa?sslmode=disable&timezone=America/Panama"`. Medido: sin el parámetro, `SHOW TimeZone` dice `Etc/UTC`; con él, `America/Panama`. Por qué es la sesión y no el proceso quien decide esto es `be06`.

Y las pruebas del service, que corren en los dos motores igual que las de `be02` (Postgres siempre en `esclusa_test`):

<<<archivo:server/internal/wheel/service_test.go>>>

### 5.8 🪦 El momento

Todo lo anterior fue para esto. Sigue los pasos en orden y **no te saltes el primero**, que es el que hace que el reemplazo sea reversible.

```bash
# 1. Red de seguridad: el estado exacto de tus datos antes de tocar nada.
cp mock/db.json mock/db.json.antes-del-reemplazo
git add -A && git commit -m "be03: checkpoint antes del reemplazo"

# 2. Base limpia, migrada y sembrada desde TU db.json, con la zona en el DSN.
cd server
export DATABASE_URL="postgres://esclusa:esclusa@localhost:5432/esclusa?sslmode=disable&timezone=America/Panama"
migrate -path migrations/postgres -database "$DATABASE_URL" up
go run ./cmd/seed -file ../mock/db.json

# 3. 🪦 Se apaga el mock del 3001. Sin red.
#    El 3002 de Google Play SIGUE VIVO: es un tercero y no se toca.
#    (Ctrl+C en la terminal de npm run mock:all, y después npm run mock:googleplay)
lsof -i :3001    # tiene que estar libre

# 4. Se levanta el binario en el 3001. El mismo puerto. Ese es el punto.
go run ./cmd/api

# 5. El criterio de aprobación, sin modificar una línea desde be00.
cd .. && ./server/smoke.sh
```

Corrida del 19/10/2026: `Contrato OK.`, diecisiete de diecisiete. Y entonces, el recorrido. **El mismo de `be00`**, paso por paso, con Network abierto: login, listar, crear, editar y borrar una rueda, abrir el asistente, buscar, compensar, el `409` del caso repetido, consultar una compra, conciliar la Rueda de fin de mes, el tablero, cerrar sesión.

Medido con el recorrido automatizado de `be00` contra los dos servidores: las mismas peticiones, con los mismos status, y dos diferencias que son de crecimiento y no de contrato. Una: Go no manda `ETag`, así que las lecturas repetidas son `200` y nunca `304`. La otra: el `PUT` de la consola lleva un campo `wheelVersion`, porque devuelve la rueda que recibió, y Go lo ignora. Las lecturas del contrato comparadas campo por campo con el mock son idénticas, salvo `wheelVersion`; y una secuencia de veintitrés escrituras —altas, pesos que no suman, decimales, versiones, `409` en vivo, borrados, envíos, giros, conciliaciones— da los mismos status y los mismos cuerpos en los dos.

> 🧭 **El criterio, en una frase que se puede decir en voz alta:** *"apagué el mock, levanté mi binario, y la consola no se enteró."*
>
> Si algo se comporta distinto, **el que está mal es el backend**. No el frontend, no el contrato, no "es que json-server hacía algo raro". El backend. Vuelve a `server/CONTRACT.md`, encuentra en qué punto te desviaste, y corrígelo ahí.

Cuando pase, escríbelo. Un párrafo en `server/CONTRACT.md` con la fecha, qué recorriste y qué falló en el camino antes de quedar en verde. Ese párrafo es el retiro formal del mock del `3001`, y en seis meses va a ser el documento que explique por qué el `3001` responde lo que responde.

---

## ⚠️ 6. Errores comunes y pieza forense

### Errores comunes

**1. La secuencia que se quedó atrás.** Síntoma: la siembra funciona, la consola lista las ruedas perfecto, y la primera alta devuelve `500`; en el log, `pq: duplicate key value violates unique constraint "wheels_pkey"`. Causa: insertar ids explícitos no mueve la secuencia de `BIGSERIAL`; el `nextval` sigue en 1. Fix: el `setval` de `fixSequences`. Es el error más frecuente de la fase y no tiene nada que ver con tu código.

**2. `time.Time` que vuelve en otro huso.** Síntoma: `closesAt` sale `2031-01-01T01:00:00Z` donde el mock devolvía `2030-12-31T20:00:00-05:00`, y la verificación 3 de `smoke.sh` falla. Causa: `TIMESTAMPTZ` guarda el instante y lo devuelve en la zona de la **sesión**, que por defecto es la del servidor de base (`Etc/UTC` en `postgres:13`). Fix mínimo: `timezone=America/Panama` en el DSN. Corrección frente a refactorización: la línea del DSN es la corrección; decidir de quién es la autoridad temporal es `be06`, y es una conversación entera.

**3. Campos en minúscula.** Síntoma: al objeto le falta justo un campo, sin error, sin aviso. Causa: `encoding/json` solo serializa campos exportados. Fix: mayúscula inicial. Cuesta cinco minutos encontrarlo la primera vez y treinta segundos la segunda.

**4. Uniformar los `404`.** Síntoma: `toReadableError` empieza a mostrar mensajes que nadie escribió, o deja de mostrar los que sí. Causa: alguien —con toda la razón del mundo— hizo que todos los `404` devolvieran `{ "error": … }`, o que ninguno lo hiciera. Fix: volver a `C-04`. Es la mejora razonable que rompe un cliente, y por eso `be00` la registró como trampa.

**5. Validar más de lo que validaba el mock.** Síntoma: una alta que antes iba bien devuelve `400` o `422`. Causa: agregaste validación de negocio en el `POST /wheels`. Fix: quitarla. Validar más es **romper el contrato**: el régimen de crecimiento admite validaciones más permisivas, nunca más estrictas. Hay una sola excepción en esta fase, y está declarada: el mock acepta `"closesAt": "mañana"` y lo guarda tal cual; Go responde `400`, porque `TIMESTAMPTZ` no puede guardar algo que no es un instante. El formulario de la Fase 4 pide el texto con su ejemplo, y en el recorrido no aparece; anótalo en `CONTRACT.md` como desvío deliberado.

**6. `name_like` con `LIKE`.** Síntoma: la búsqueda de jugadores funciona en las pruebas con SQLite y en la consola no encuentra a "Ángela" cuando escribes "ángela", o al revés. Causa: la Divergencia 6 de `be02`. Fix: el filtro con `regexp` y `(?i)`, igual en los dos motores. Y si el operador escribe `(`, el mock responde `500` con el `SyntaxError` de la expresión regular, y Go, un `500` con su mensaje genérico: el mismo contrato.

### 🩻 Pieza forense de esta fase

**La discrepancia que encuentra el frontend y no encuentra ningún test.**

Es la forma real en que aparecen estos bugs, y por eso la fase la provoca a propósito. Tus pruebas de `be02` pasan. `go vet` está limpio. `curl` devuelve algo que se ve perfecto. Y la consola se comporta raro.

*Caso A — el objeto que debía ser un texto.* Cambia `Origin *string` por `sql.NullString` en `spin.Spin` y abre el tablero de la Rueda de fin de mes.

1. Anota qué devuelve `curl localhost:3001/spinLog?wheelId=4 | jq '.[0].origin'`. Vas a ver `{"String":"free","Valid":true}`, y te va a parecer obvio **ahora que lo buscas**.
2. Anota qué se ve en la consola. Medido: la tarjeta de giros dice *10000 · 10000 gratis · 0 pagos*, al lado de unos ingresos netos de US$135,60. **Sin un solo error en consola.**
3. Escribe la prueba de Go que lo habría atrapado. Pista incómoda: una prueba que compare structs **no lo atrapa nunca**, porque el problema no está en los datos sino en la serialización. Hay que comparar el **JSON** contra la respuesta que daba el mock.
4. Vuelve al puntero y confirma que el JSON queda idéntico al del mock.

*Caso B — los tres campos que se pierden en silencio.* Deshaz la migración `000003` (`migrate down 1`), quita del `INSERT` de `Reconcile` las tres columnas, y concilia la Rueda de fin de mes desde la consola.

1. El `POST /wheels/4/reconciliation` devuelve `201`. La consola festeja. La rueda pasa a conciliada. Todo verde.
2. Ahora `GET /wheels/4/reconciliation` y compara con el cuerpo que viajó, que tienes en Network. Medido: la consola mandó `missingInApi: ["tok-ago-31"]` y `duplicatedInApi: ["tok-ago-17"]`, los dos descuadres de agosto; lo guardado dice `[]` y `[]`.
3. **Nadie se entera.** La pantalla de conciliación no vuelve a leer el registro. El dato se perdió el día que se guardó, y el síntoma va a aparecer dentro de meses, cuando alguien pregunte qué compras no cuadraban en agosto.
4. Vuelve a aplicar la migración y escribe, en tres líneas, qué prueba habría detectado esto. Después responde la pregunta difícil: ¿esa prueba la habrías escrito?

*El contraste que hay que anotar.* El Caso A es ruidoso: rompe algo visible y se encuentra en veinte minutos. El Caso B es silencioso: no rompe nada, no lo encuentra ningún test, y cuesta muchísimo más caro. **Los bugs de contrato que duelen no son los que fallan: son los que pasan.**

*Rompe a propósito, bonus.* Con el binario corriendo, quita un campo de una respuesta —`segmentId` de `wheel.Segment`, por ejemplo— y recorre la consola. Cronometra cuánto tardas en encontrar la causa **sin** mirar el código del backend, solo con DevTools. Ese cronómetro es la medida de lo que vale un contrato escrito.

---

> 📓🔥 De esta fase salen los incidentes **be-06** y **be-07** de `cuaderno-incidentes-be.md`, los dos sobre lo mismo desde ángulos opuestos: un campo que cambió de forma y un campo que se perdió en silencio. Y desde acá se reproducen **be-04** y **be-05**, que nacieron en el código de `be02` y recién se ven cuando la consola lee del binario.

---

## 🧪 7. Ejercicios (33)

**🟢 Fácil (1–8)**

1. Arranca el binario sin `DATABASE_URL` y comprueba que muere en el segundo cero con un mensaje que dice qué falta.
2. Siembra dos veces seguidas y verifica con `psql` que no hay filas duplicadas en `wheels`, `players` ni `spin_log`.
3. Comprueba con `curl` que `GET /wheels/1` y `GET /wheels/9999` responden lo mismo que respondían contra el mock.
4. Corre `server/smoke.sh` contra el binario en el `3001` y pega la salida en `CONTRACT.md`.
5. Comprueba que `GET /players?name_like=ANA` encuentra a "Ana" y a "Anaís", como en el mock.
6. Verifica que el mock de Google Play sigue respondiendo en el `3002` con el `3001` en manos de Go.
7. Abre el tablero de la Rueda de fin de mes y confirma que muestra los mismos cuatro números que con el mock.
8. Comprueba con `psql` que el `PUT` que cambia pesos de una rueda en borrador crea la versión 2 en `wheel_versions`.

**🟡 Intermedio (9–18)**

9. **Diagnóstico.** Quita `fixSequences` de la siembra, siembra en una base limpia y crea una rueda. Encuentra el error en el log, explica por qué pasa y por qué no pasa con SQLite.
10. **Diagnóstico.** Quita `timezone=America/Panama` del DSN y corre `smoke.sh`. Encuentra qué verificación falla y qué ve el operador en la tabla de ruedas.
11. Escribe una prueba de Go que compare el JSON de `GET /spinLog?wheelId=4` contra un archivo con la respuesta del mock, byte a byte después de normalizar.
12. **Diagnóstico.** Cambia el tipo de `Segment.WeightBp` a `float64` y mira qué ve `WheelForm`. ¿Rompe algo? Explica por qué sí o por qué no.
13. Agrega `GET /stock/:id` como crecimiento, con su `404` de json-server, y escribe en `CONTRACT.md` por qué no rompe a nadie.
14. **Diagnóstico.** Manda a `PUT /wheels/1` un cuerpo con `"weightBp": "1500"` (texto) y compara qué responde el mock y qué responde Go. Decide si la diferencia es contrato.
15. Mide con `curl -w` el tiempo de `GET /spinLog?wheelId=4` contra el mock y contra Go, cinco veces cada uno. Explica la diferencia.
16. Siembra la Semana del Canal con `--event` (Fase 9), vuelve a sembrar Go y mide `GET /spinLog` de esa rueda: bytes, tiempo y memoria del proceso.
17. **Diagnóstico.** Busca `(` en el asistente de envíos contra el mock y contra Go. Compara lo que ve el operador en los dos casos y decide si es la misma respuesta.
18. Escribe en `CONTRACT.md` el párrafo del retiro del mock: fecha, recorrido y lo que falló antes de quedar en verde.

**🟠 Difícil (19–27)**

19. **Diagnóstico.** Ejecuta el Caso A de la pieza forense y escribe la prueba que compara el JSON contra el del mock. Muestra que falla con `sql.NullString` y pasa con el puntero.
20. **Diagnóstico.** Ejecuta el Caso B y escribe la prueba que lo habría detectado. Justifica en qué capa vive.
21. Implementa `name_like` en SQL para Postgres con el operador `~*` y compara con la versión en Go: qué expresiones dan distinto, y qué gana y qué pierde cada una.
22. Mide qué pasa con dos `POST /players/42/grants` del mismo caso lanzados a la vez contra Go. Compáralo con el `C-07` medido contra el mock en `be00`.
23. **Diagnóstico.** Mide el `C-01` contra Go: la misma clave de giro dos veces a la vez, y mil quinientos giros con el generador de la Fase 3. Compara las cifras con las del mock y explica por qué no son iguales aunque el código haga lo mismo.
24. Diseña la prueba de contrato en Go que reemplazaría a `smoke.sh` en `be08`, con una tabla de casos. No la escribas entera: escribe su esqueleto y tres casos.
25. **Diagnóstico.** Apaga Postgres con la consola abierta y recorre las pantallas. Compara con el inventario de síntomas que levantaste en `be00` con el mock caído.
26. Argumenta por escrito si `GET /spinLog` debería paginar. Escribe qué tendría que cambiar en la Fase 9 primero, y qué régimen del contrato toca.
27. Agrega al `logging` el número de filas que devolvió cada lectura de la bitácora, y úsalo para encontrar la pantalla que más filas pide.

**🔴 Muy difícil (28–33)**

28. **Diagnóstico.** Recorre la consola con el caos en `high` contra el mock y contra Go, y compara los síntomas. ¿Son los mismos? Si no, encuentra la diferencia en `chaos.go`.
29. Reescribe el giro de 2019 para que escriba la fila completa de la bitácora sin cambiar su respuesta. Mide si el tablero cambia y decide si eso es un arreglo de contrato o de crecimiento. (No lo dejes en la rama principal: es `be05`.)
30. Escribe la estrategia de corte para producción: cómo pasarías del API heredado de Node a este binario con el juego y la consola en vivo, sin ventana de mantenimiento. Incluye cómo volver atrás.
31. **Diagnóstico + regresión.** Ticket: *"desde el cambio de servidor, la conciliación de agosto no dice qué compras faltan"*. Reconstruye la causa sin mirar este documento, escribe la prueba de regresión y el mensaje a la contadora.
32. Argumenta si el servidor debería empezar a recalcular la conciliación ya, en esta fase, o esperar a `be07`. Defiende las dos posturas con el criterio del reemplazo verificable.
33. **Post-mortem.** Escribe el post-mortem del Caso B como si hubiera ocurrido en producción, según los ocho puntos del post-mortem de `cuaderno-incidentes.md`. Sin culpabilización.

**🔥 Opcionales**

- 🔥 Agrega `ETag` a `GET /spinLog` y mide cuánto ahorra con el tablero abierto. Decide si es crecimiento.
- 🔥 Implementa `_page` y `_limit` en `GET /spinLog` y comprueba que la consola no se entera. Mira qué pasa con `Access-Control-Expose-Headers` (la rareza de `C-02`).
- 🔥 Reescribe la siembra con `COPY` de Postgres y compara tiempos con la de lotes de 500 filas.

---

## 📚 8. Referencias

**Documentación oficial**
- https://github.com/kelseyhightower/envconfig — la etiqueta `required`, los valores por defecto y los tipos que entiende (`time.Duration` incluido).
- https://pkg.go.dev/encoding/json — la sección sobre `omitempty` y sobre qué campos se serializan.
- https://pkg.go.dev/database/sql#NullString — el tipo de la pieza forense, con su forma exportada.
- https://pkg.go.dev/github.com/lib/pq — los parámetros del DSN y cómo pasa a la sesión los que no son suyos.
- https://www.postgresql.org/docs/13/functions-sequence.html — `setval` y `pg_get_serial_sequence`.
- https://github.com/gorilla/mux — `NotFoundHandler` y las variables de ruta con expresión regular.

**Libros**
- *Working Effectively with Legacy Code* (Michael Feathers) — la idea de "costura" y de reemplazar sin que el resto se entere es suya.
- *Monolith to Microservices* (Sam Newman) — el patrón *strangler fig*, que es lo que esta fase hace con un solo servicio.

**Video / apoyo**
- Busca "strangler fig pattern" y "Go json omitempty pointer" en YouTube.

**Orden de lectura sugerido:** la documentación de `encoding/json` sobre `omitempty` primero —es corta y es la pieza forense— → la de `envconfig` → el capítulo de costuras de Feathers, cuando el reemplazo ya esté en verde.

> ⚠️ URLs, títulos y ediciones pueden haber cambiado: verifícalos. Las referencias a libros son de memoria y pueden ser inexactas. Cualquier discrepancia de versiones la resuelve `00-decisiones-y-versiones.md` §7.

---

## 🚀 9. Cierre y conexión con la siguiente fase

El mock del `3001` ya no existe para la consola. Lo que contesta es tu binario, con tus datos, en el mismo puerto, y la consola no se enteró: diecisiete verificaciones en verde, el mismo recorrido con las mismas peticiones, las mismas respuestas campo por campo. Con él se fueron el `db.json` como almacén y la configuración sin validar.

Lo que no se fue, porque no tenía que irse todavía, está escrito en `CONTRACT.md` con su fase: el login por query string con su token de mentira, el giro que decide con lo que leyó antes, el caso que se compensa dos veces, la conciliación que el servidor no verifica. `be04` cobra el primero: contraseñas con `bcrypt`, un JWT firmado en el mismo campo `token`, la identidad que sale del token y no del cuerpo, y una librería de JWT que se adopta y se abandona en la misma fase.

> **La señal de que quedó bien:** *"apagué el mock, levanté mi binario, y la consola no se enteró; y puedo señalar en `CONTRACT.md` cada deuda que reimplementé a propósito."*

> 🏷️ **No cierres la fase sin el tag.** Con el checklist de la sección 2 en verde y `git status` limpio:
>
> ```bash
> git tag -a fase-be03-crud-y-el-reemplazo -m "be03 cerrada: \
> configuración validada con envconfig; migraciones 000002 y 000003; \
> siembra idempotente desde mock/db.json; régimen estricto de CONTRACT.md en capas; \
> las dos formas de 404 (C-04); mock del 3001 apagado y binario en el 3001; \
> smoke.sh 17/17 contra Go; recorrido de be00 repetido sin diferencias visibles"
> ```
>
> Los commits de la fase llevan su prefijo (`be03: …`) y los de ejercicio su número (`be03 ej19: …`). Si un ejercicio merece su propio marcador va en `ej/be03/19`, y un incidente resuelto en el par `inc/<ID>/<slug>-roto` / `-fix`, con el ID que le reserva `cuaderno-incidentes-be.md`. Todo eso está en [`00-convencion-de-git-y-tags.md`](00-convencion-de-git-y-tags.md).

---

## 📌 Pendientes sugeridos

*(Fuera de lo que lee el estudiante.)*

- **El retiro del mock queda escrito en `CONTRACT.md`**, con fecha. Que `be08` lo use como línea base de su suite de contrato.
- **Deudas reimplementadas a propósito, con su fase:** el giro sin idempotencia y con el stock descontado después (`C-01`, `be05`); la fila pobre de la bitácora (`C-03`, `be05`); el chequeo de caso del envío no atómico (`C-07`, `be05`); la conciliación guardada sin verificar (`C-07`, `be07`); el token de mentira en una columna (`be04`).
- **Desvío deliberado del contrato:** `closesAt` que no es un instante responde `400` (el mock lo guarda). Va a `CONTRACT.md` y a `bea-09`.
- **`be06` hereda la zona de la sesión en el DSN** como corrección mínima, y la decide como autoridad (D29).
- **Reserva para el cuaderno de incidentes:** `be-06` — *"el tablero dice que nadie compró giros"* (🔥 contrato, 🟠), el Caso A; y `be-07` — *"faltan datos en las conciliaciones"* (🔥 contrato, 🔴), el Caso B. `be-04` y `be-05` (de `be02`) se reproducen desde el tag de esta fase.
