# 🔐 Fase be04 — Identidad real: bcrypt, JWT y un CVE

> Tutorial React 16 — La Esclusa, la consola de Jewel Locks · **Track BE opcional 🔥** · Fase be04 de be09 · **8 horas**
> Depende de: be03 — el backend ya sirve a la consola · Habilita: be05 — El giro concurrente

---

## 🎯 1. Propósito

Después de la noche de la Esclusa de Oro, Yariela pidió una sola cosa: *"quiero saber quién mandó cada uno de esos giros"*. Hoy la respuesta es que nadie puede saberlo: cualquiera con usuario puede enviar giros (`00-historia-del-sistema.md` §11), y el servidor nunca preguntó quién pedía. Esta fase cobra **cuatro deudas de una vez**, y las cuatro estaban declaradas por escrito desde la Fase 2 del track base:

1. **El token de mentira.** Una constante de texto en `db.json` que `be03` convirtió en una columna. Sin firma, sin expiración, sin secreto.
2. **Las contraseñas en claro.** El mock las comparaba como strings y `be03` heredó la comparación tal cual, ahora en SQL, con la contraseña viajando en la URL.
3. **El cliente que se dice quien quiere.** Quién manda un envío, quién edita una rueda, es quien el navegador dice que es. El servidor nunca preguntó, y no guarda nada.
4. **Las transiciones libres.** El flujo `draft → scheduled → live → ended → reconciled` lo decide el formulario de la Fase 4, que deja elegir cualquier estado, y nadie verifica que el orden tenga sentido.

Y trae, de regalo, algo que ninguna fase inventada podría mejorar: **la secuencia completa de adoptar una dependencia que era *la* dependencia, descubrir que está abandonada con un aviso de seguridad abierto, y migrar al fork**. No es una anécdota que se cuenta: se hace, con el `go.mod` cambiando en dos commits y un post-mortem al final. Y, medido al escribir esta fase, la historia tiene una segunda vuelta que no estaba en el guion.

> 🧭 Y una restricción que ordena toda la fase: **el JWT firmado viaja en el mismo campo `token` que el frontend ya lee**. El interceptor de `apiClient` manda `Bearer ${token}` desde la Fase 2 justamente para que este día llegara sin tocarlo. No se toca.

---

## ✅ 2. Qué queda listo al terminar

- [ ] Migración `000004`: `users.password` pasa a `password_hash` y **la columna `users.token` desaparece**. La deuda de `be03` se paga borrando su DDL. Migración `000005`: cada envío guarda quién lo mandó.
- [ ] La siembra hashea con `bcrypt` las contraseñas que vienen en claro del `db.json`, y el `db.json` no se modifica.
- [ ] `POST /login` valida contra el hash y devuelve `{ id, email, name, token }` con el `token` firmado; `GET /users` ya no existe.
- [ ] La **única excepción del track** está ejecutada: `src/api/authService.js` modificado, y **ningún otro archivo del frontend** (`D27` / `C-06`).
- [ ] Middleware de verificación montado sobre las rutas de la consola; un token inválido o vencido devuelve `401` con la forma que el interceptor ya sabe manejar. El giro del juego sigue público.
- [ ] La identidad viaja en el contexto y **ningún handler la lee del cuerpo de la petición**: el operador de cada envío sale del token.
- [ ] Las transiciones de la rueda están custodiadas en el service, con su tabla, y una ilegal devuelve `409`.
- [ ] `dgrijalva/jwt-go` v3.2.0 entró al `go.mod` y **salió en la misma fase**, reemplazado por `golang-jwt/jwt/v4` v4.4.2.
- [ ] Existe `server/postmortem-jwt.md`, escrito sin culpabilización.
- [ ] `server/CONTRACT.md` y `server/smoke.sh` están actualizados con el login nuevo, y el `smoke.sh` pasa entero.
- [ ] `git diff pre-backend-go..HEAD -- . ':!server' ':!src/api/authService.js'` no devuelve nada.

---

## 🚫 3. Qué queda fuera por ahora

- **Los *refresh tokens*.** No entran, y esto es una decisión, no un olvido: el JWT expira, el frontend no lo renueva, y cuando expira el interceptor de la Fase 2 hace logout global. **Esa fricción se declara como deuda 💸 viva** en vez de tocar el frontend para arreglarla. Para el laboratorio, el token tiene vida larga. Ver 4.5.
- **Roles y permisos finos.** Todos los operadores pueden todo: Itzel, Yariela y la contadora. Autorización a nivel de objeto es tema de `bea-08`.
- **La autenticación del juego.** El giro lo pide el celular de cada jugador, que no tiene sesión de la consola. Queda público, y por qué eso es aceptable hoy —y no mañana— es `bea-08`.
- **Límite de tasa e intentos fallidos** → `bea-08`. Hoy puedes probar contraseñas todo el día.
- **El `409` del giro concurrente** → `be05`. El `409` de esta fase es el de una transición ilegal, que es otra cosa.
- **El cierre por reloj** → `be06`. Las transiciones se custodian por *orden*, no todavía por *reloj*.

---

## 🧠 4. Conceptos mínimos

### 4.1 `bcrypt`: por qué no es un hash cualquiera

Sabes qué es una función de hash. Lo que hay que tener claro es por qué SHA-256 —que es una excelente función de hash— **es una pésima forma de guardar contraseñas**: porque es rápida. Una GPU moderna calcula miles de millones de SHA-256 por segundo, y eso es exactamente lo que hace un atacante con tu tabla de usuarios.

`bcrypt` resuelve dos problemas a la vez. Es **deliberadamente lento**, con un factor de costo ajustable: subir el costo en uno duplica el tiempo, así que la defensa se puede escalar con el hardware sin cambiar de algoritmo. Y **incorpora la sal en el propio hash**, así que no hay una columna `salt` que administrar ni la posibilidad de olvidarla. El resultado se ve así, y las cuatro partes están a la vista:

```
$2a$10$TjBRaGIeFDFWq6SezmPfCOff15Sn56NffrRBNioqqO2B2X9/VfCzK
 │   │  └── sal (22 caracteres) ─┴── hash (31 caracteres)
 │   └── costo: 10 → 2^10 iteraciones
 └── variante del algoritmo
```

De ahí salen las dos reglas de uso, y las dos son fáciles de romper: **nunca compares hashes con `==`** —se usa `CompareHashAndPassword`, que además tarda lo mismo acierte o falle— y **el hash es opaco**: no se parsea, no se indexa, no se compara por prefijo.

> ⚠️ **La trampa de los 72 bytes.** `bcrypt` ignora todo lo que pase de 72 bytes de entrada. La implementación de Go es honesta y devuelve `bcrypt.ErrPasswordTooLong` en vez de truncar, pero solo si le manejas el error, que es lo que casi nadie hace.

### 4.2 JWT en cinco líneas (el resto está en `bea-04`)

Tres partes separadas por puntos, las dos primeras en Base64URL **sin cifrar**: cabecera (qué algoritmo), *claims* (quién, cuándo expira, para quién) y firma. Cualquiera puede leer el contenido de un JWT; nadie puede modificarlo sin el secreto.

Lo que hay que interiorizar hoy son dos cosas. La primera: **un JWT no es una sesión**. No hay estado del lado del servidor, y por eso no se puede invalidar: un token robado sirve hasta que expira, y punto. La segunda: **la cabecera la elige quien manda el token**, no quien lo verifica. Esa frase inocente es el origen de la familia de ataques de confusión de algoritmo, y es la pieza forense de esta fase.

### 4.3 La identidad viene del contexto, jamás del cuerpo

Hoy, cuando la consola manda un envío, el backend acepta lo que sea que venga en el JSON. Si mañana alguien manda `{"sentBy": 3}` con el token del operador 2, el servidor le cree.

La regla no admite matices: **lo que el cliente afirma sobre sí mismo es un dato de entrada, no una verdad**. La identidad se extrae del token en el middleware, se deja en el contexto y de ahí la leen los services. Cualquier campo del cuerpo que hable de identidad se **ignora**, no se valida: validarlo sería admitir que a veces es fuente de verdad.

Fíjate en la simetría con `be01`: el `X-Request-Id` y el id del operador viajan por el mismo canal y por la misma razón. Son datos de alcance de petición que atraviesan capas sin ser parte de la lógica de negocio. Eso es exactamente para lo que existe `context.Context`. Con un detalle de diseño que el compilador te impone: la clave de la identidad vive en el paquete `auth` y no en el de HTTP, porque los services la leen, y un service que importe la capa HTTP armaría un ciclo de imports.

### 4.4 Las transiciones como máquina de estados

El flujo de una rueda tiene cinco estados y **no todas las transiciones son legales**. Hoy el formulario de la Fase 4 deja elegir cualquiera y el backend obedece; un `PUT` con `status: "live"` sobre una rueda conciliada funciona perfecto y deja el sistema en un estado imposible.

| Desde | Puede ir a |
|---|---|
| `draft` | `scheduled` |
| `scheduled` | `draft`, `live` |
| `live` | `ended` |
| `ended` | `reconciled`, solo conciliando |

Todo lo que no esté en esa tabla es un `409 Conflict`: la petición está bien formada, pero el estado del recurso no permite lo que pide. La misma semántica que el `409` de la rueda en vivo que la Fase 4 ya sabe mostrar. Y a `reconciled` no se llega por `PUT`: solo por la conciliación, que pasa la rueda de estado en la misma operación (Fase 8).

Custodiar esto en el **service** y no en el handler no es purismo: es que la regla tiene que valer también para cualquier consumidor futuro que no entre por HTTP.

### 4.5 El *refresh token* que no vamos a hacer, y por qué se declara

Un JWT que expira deja al operador afuera. La solución estándar es un par de tokens: uno corto para las peticiones y uno largo para renovarlo sin volver a pedir contraseña. Implementarlo requiere un endpoint nuevo **y que el frontend lo llame**, o sea, tocar `apiClient.js`, sus interceptores y probablemente el `authSlice`.

> 🧭 **Decisión: no se hace.** Ampliar la excepción `D27` a media capa de red del frontend convertiría "la única excepción negociada" en una licencia general, y ahí se cae la regla que ordena el track entero.

Así que el token tiene vida larga en el laboratorio (`JWT_TTL`, doce horas por defecto), y la fricción se declara: **cuando expire, el interceptor de la Fase 2 recibirá un `401` y hará logout global, y el operador tendrá que entrar de nuevo**. Eso no es un bug del backend. Es la consecuencia visible de una decisión de alcance, anotada en el mapa de deuda con su fecha y su motivo.

---

## 💻 5. Implementación y código comentado

### 5.1 Las migraciones que borran la vergüenza

<<<archivo:server/migrations/postgres/000004_real_credentials.up.sql>>>

<<<archivo:server/migrations/postgres/000004_real_credentials.down.sql>>>

Y la que contesta la pregunta de Yariela, desde hoy: quién mandó cada envío. Los anteriores quedan en `NULL`, porque no hay forma honesta de saberlo.

<<<archivo:server/migrations/postgres/000005_grant_operator.up.sql>>>

En SQLite, las dos son iguales (`RENAME COLUMN` existe desde la 3.25 y `DROP COLUMN` desde la 3.35), con `INTEGER` en vez de `BIGINT`.

### 5.2 La siembra hashea al entrar

El `db.json` del track base tiene `"password": "esclusa123"` en claro, y **no se modifica**: es el archivo del lector y es evidencia histórica del sistema. Quien traduce es la siembra.

```bash
cd server && go get golang.org/x/crypto@v0.4.0
```

<<<fragmento:server/internal/seed/seed.go|	for _, u := range data.Users {|			return err
		}
	}>>>

> 🧠 **Corre la siembra dos veces y mira los dos hashes.** Medido: `$2a$10$TjBRaGIeFDFW…` la primera vez y `$2a$10$/7ITaa8fXaaD…` la segunda, para la misma `esclusa123`. Esa es la sal aleatoria haciendo su trabajo: dos operadores con la misma contraseña no comparten hash, y una tabla filtrada no revela quién usa la misma clave que quién. Y la siembra tardó 334 ms donde antes tardaba 144: son tres `bcrypt` de costo 10.

Hay un detalle de operación que aparece acá: la siembra lee la configuración, y desde esta fase la configuración exige `JWT_SECRET`. Un binario de operador que no firma nada no tiene por qué conocer el secreto, así que la siembra lee solo lo suyo:

<<<fragmento:server/internal/config/config.go|// Database es lo único que necesita la siembra.|return cfg, nil
}>>>

### 5.3 El paquete `auth`, con `dgrijalva/jwt-go` v3.2.0

Ahora la parte que hay que hacer **exactamente así**, aunque sepas cómo termina.

```bash
go get github.com/dgrijalva/jwt-go@v3.2.0+incompatible
```

> 📝 **Por qué esta librería y no otra.** En 2022, `dgrijalva/jwt-go` era *la* librería de JWT en Go: la que aparecía en todos los tutoriales, la que estaba en el `go.mod` de miles de proyectos. Elegirla no era una mala decisión: era **la** decisión. Que esté acá no es una trampa didáctica: es lo que había.
>
> Fíjate en el `+incompatible` del `go get`. Eso significa que el repositorio etiquetó una v3 sin declarar el sufijo `/v3` en su módulo, como pide el versionado semántico de Go. Es una señal, y es de las que se aprenden a leer tarde.

<<<archivo:.adopcion/auth.go>>>

El secreto y la vida del token se suman a la configuración, el secreto **sin valor por defecto**:

<<<fragmento:server/internal/config/config.go|	// be04. El secreto es obligatorio|JWTTTL    time.Duration `envconfig:"JWT_TTL"    default:"12h"`>>>

Medido: sin `JWT_SECRET`, el proceso muere con `configuración inválida: required key JWT_SECRET missing value`; con uno corto, con `JWT_SECRET debe tener al menos 32 caracteres`. En el segundo cero, como enseñó `be03`.

### 5.4 `POST /login` y el middleware

<<<archivo:server/internal/http/auth.go>>>

Y el montaje, que tiene dos decisiones escondidas:

<<<fragmento:server/internal/http/router.go|	// Público: el login, y el giro|api.HandleFunc("/packages", h.listPackages).Methods(http.MethodGet)>>>

La primera: `GET /users` ya no está. Contra el binario de esta fase responde `404` con `{}`, como cualquier ruta que nadie conoce. La segunda: el giro del juego queda **fuera** del subrouter. El juego no tiene sesión de la consola, y exigirle un token de operador lo rompería esta misma noche.

El caos se entera del login nuevo: el `401` aleatorio no puede caer en mitad de un login, y la ruta del login cambió.

<<<fragmento:server/internal/http/chaos.go|			case r.URL.Path != "/users" && r.URL.Path != "/login"|el interceptor como sesión caída.>>>

> ⚠️ **Esto es una validación MÁS ESTRICTA que la del mock, y por lo tanto un riesgo de contrato.** El régimen de crecimiento de `be00` admite validaciones más permisivas, nunca más estrictas: hasta ayer, `GET /wheels` respondía sin token y ahora exige uno.
>
> Se acepta porque **es la deuda que la fase cobra** —un backend que no verifica quién pide no es un backend—, pero no se acepta por fe: se **mide**. Medido el 19/10/2026 con el recorrido completo de `be00` contra el binario de esta fase: todas las peticiones de la consola salen con `Authorization`, ninguna pantalla pide datos antes del login, y el recorrido pasa entero. Anota tu resultado en `CONTRACT.md`.

### 5.5 Las transiciones y el operador, custodiados donde corresponde

<<<archivo:server/internal/wheel/transitions.go>>>

El service las aplica al crear y al editar, antes que todo lo demás:

<<<fragmento:server/internal/wheel/service.go|	if !initialStates[w.Status] {|		return Wheel{}, &IllegalTransitionError{To: w.Status}
	}>>>

<<<fragmento:server/internal/wheel/service.go|	if !canTransition(current.Status, w.Status) {|		return Wheel{}, &IllegalTransitionError{From: current.Status, To: w.Status}
	}>>>

Corre las pruebas de `be03` y una va a fallar: `Una rueda no puede pasar de "draft" a "live".` Es `TestChangingWeightsPublishesANewVersion`, que pasaba la rueda a vivo de un salto. No es un bug de la regla: es la regla haciendo su trabajo sobre una prueba que daba por bueno algo que ahora es ilegal. Se corrige la prueba, no la regla:

<<<fragmento:server/internal/wheel/service_test.go|	// be04: de borrador a vivo no se salta|		t.Fatal(err)
	}>>>

Y el envío deja de creerle al cuerpo:

<<<fragmento:server/internal/player/player.go|	// 🧭 El operador sale del contexto|		g.GrantID, g.PlayerID, g.CaseID, g.Prize, g.Reason, sentBy)>>>

Medido contra el binario de esta fase: un `PUT` que lleva la Rueda de la costa de `reconciled` a `live` responde `409` con `Una rueda no puede pasar de "reconciled" a "live".`; una rueda nueva en `live`, `409` con `Una rueda nueva no puede nacer en "live".`; y un envío de Yariela con `"sentBy": 3` en el cuerpo queda guardado con `"sentBy": 2`, el suyo.

### 5.6 🚨 El descubrimiento

Con todo funcionando, haz lo que deberías hacer con cualquier dependencia antes de que llegue a producción:

```bash
cd server
go list -m -versions github.com/dgrijalva/jwt-go
go run golang.org/x/vuln/cmd/govulncheck@v1.0.0 ./...
```

La primera dice que no hay nada después de `v3.2.0+incompatible`: la librería no se mueve desde entonces. Y si abres el repositorio vas a encontrar que **está archivado**. La segunda es la que importa. Medido el 19/10/2026, entre lo que reporta hay un aviso sobre la librería que acabas de instalar:

```
Vulnerability #22: GO-2020-0017
    Authorization bypass in github.com/dgrijalva/jwt-go
  More info: https://pkg.go.dev/vuln/GO-2020-0017
  Module: github.com/dgrijalva/jwt-go
    Found in: github.com/dgrijalva/jwt-go@v3.2.0+incompatible
    Fixed in: N/A
```

Ese `GO-2020-0017` es el mismo aviso que el resto del mundo conoce como **`CVE-2020-26160`** y **`GHSA-w73w-5m7g-f7qc`** (los alias están en el registro OSV que `govulncheck -json` devuelve). `Fixed in: N/A`: **no hay versión corregida**. El símbolo afectado es `MapClaims.VerifyAudience`: cuando el *claim* de audiencia llega como un arreglo vacío, la verificación lo trata como cadena vacía, y una aplicación que confíe **solo** en esta librería para verificar la audiencia puede aceptar un token que no era para ella.

> 🧠 **Lee esto antes de encogerte de hombros.** `govulncheck` lo pone en la sección *Informational*: encontró la librería, pero ningún camino de tu código llega a `MapClaims.VerifyAudience`, porque usas `StandardClaims` y no verificas `aud`. Puede que tengas razón en que hoy no te afecta, y esa evaluación es exactamente el trabajo, no un atajo para saltárselo. Lo que sí te afecta seguro es lo otro: **la librería está abandonada**. El aviso es el síntoma; el problema es que el próximo hallazgo tampoco va a tener parche. Se migra por eso.
>
> ⚠️ **Verifica todo esto tú mismo antes de citarlo.** Los avisos se actualizan y los enlaces cambian. La severidad y las fechas del aviso están en https://github.com/advisories/GHSA-w73w-5m7g-f7qc y en https://nvd.nist.gov/vuln/detail/CVE-2020-26160: ábrelos y léelos, que es la mitad de lo que esta fase enseña. `bea-04` explica cómo se lee un aviso línea por línea.

### 5.7 La migración al fork

```bash
go get github.com/golang-jwt/jwt/v4@v4.4.2
go mod edit -droprequire github.com/dgrijalva/jwt-go
go mod tidy
```

El cambio en el código es sorprendentemente pequeño, y esa pequeñez **también es contenido**: un fork bien hecho conserva la superficie de la API para que migrar no sea una excusa para no migrar. Medido con `diff` sobre `auth.go`: seis líneas, de las cuales una es un comentario.

```go
// ANTES                                    // DESPUÉS
import "github.com/dgrijalva/jwt-go"        import "github.com/golang-jwt/jwt/v4"

jwt.StandardClaims                          jwt.RegisteredClaims
IssuedAt:  now.Unix()                       IssuedAt:  jwt.NewNumericDate(now)
ExpiresAt: now.Add(s.ttl).Unix()            ExpiresAt: jwt.NewNumericDate(now.Add(s.ttl))
```

Los tres cambios de v4 tienen su razón y vale la pena entenderlos en vez de aplicarlos a ciegas:

- **`StandardClaims` → `RegisteredClaims`.** El nombre del RFC 7519 es "claims registrados". El anterior nunca fue el correcto.
- **`int64` → `*jwt.NumericDate`.** Con `int64`, "sin expiración" y "expira en el epoch" son el mismo valor: `0`. Con un puntero, ausente y cero son distintos. Es la misma lección del `origin` de `be03`, en otra capa.
- **La verificación de `aud` cambió**, que es lo que arregla el aviso.

Comprueba que la deuda se pagó de verdad, y fíjate en qué comando mirar:

```bash
grep -rn "dgrijalva" --include=*.go .     # nada
grep jwt go.mod                           # solo golang-jwt/jwt/v4 v4.4.2
go list -m all | grep jwt                 # ⚠️ todavía aparece dgrijalva
go build -o /tmp/api ./cmd/api && go version -m /tmp/api | grep jwt   # solo golang-jwt
```

El tercero sorprende: medido, `go list -m all` sigue mostrando `github.com/dgrijalva/jwt-go v3.2.0+incompatible` (y un `form3tech-oss/jwt-go`). Están en el **grafo de módulos** porque los nombra el `go.mod` de `golang-migrate`, no porque tu código los use: `go mod why -m github.com/dgrijalva/jwt-go` contesta `main module does not need module github.com/dgrijalva/jwt-go`, y en el binario —el cuarto comando— solo queda `golang-jwt/jwt/v4 v4.4.2`. El grafo dice qué podría compilarse; el binario dice qué se compiló.

### 5.7 bis La segunda vuelta

Corre `govulncheck` otra vez, ahora con el fork. Medido el 19/10/2026: `GO-2020-0017` desapareció, y aparecieron dos avisos nuevos, **en el fork y en la versión que fija `D16`**, y esta vez no son informativos: el código llega a ellos por `Signer.Verify` → `jwt.ParseWithClaims`.

```
  More info: https://pkg.go.dev/vuln/GO-2024-3250
  Module: github.com/golang-jwt/jwt/v4
    Found in: github.com/golang-jwt/jwt/v4@v4.4.2
    Fixed in: github.com/golang-jwt/jwt/v4@v4.5.1
…
  More info: https://pkg.go.dev/vuln/GO-2025-3553
  Module: github.com/golang-jwt/jwt/v4
    Found in: github.com/golang-jwt/jwt/v4@v4.4.2
    Fixed in: github.com/golang-jwt/jwt/v4@v4.5.2
```

No es una trampa del curso: es lo que pasa con cualquier versión congelada. El fork está mantenido —por eso hay versión corregida—, y la `v4.4.2` es la de 2022, que es la época de esta aplicación (`D14`, `D16`). El curso **la deja congelada** y lo dice: subir a la `v4.5.2` es el ejercicio 25, con su criterio medible. Lo que esta fase te deja no es una versión limpia para siempre, sino el mecanismo que avisó las dos veces. Y en la misma corrida hay un dato más grande, que va al veredicto de `be09`: `govulncheck` reporta 42 vulnerabilidades de la **biblioteca estándar** de Go 1.19.13 que este código alcanza. El lenguaje también envejece.

### 5.8 La excepción: el único archivo del frontend

Ha llegado el momento de ejecutar `D27` / `C-06`. **Un archivo. Solo este.**

<<<archivo:src/api/authService.js>>>

Y ahora la verificación que demuestra que la excepción se respetó:

```bash
# Debe listar UN archivo y solo uno.
git diff --name-only pre-backend-go..HEAD -- . ':!server'

# Y este comando —el que usan todas las fases desde acá— debe salir vacío:
git diff pre-backend-go..HEAD -- . ':!server' ':!src/api/authService.js'
```

> ⚠️ **El `401` del login pasa por el interceptor global.** Una contraseña mal escrita devuelve `401`, y el interceptor de la Fase 2 lo toma por sesión caída: hace logout y manda a `/login`. Medido en el navegador: como el operador ya está en `/login` y sin sesión, no se nota; la pantalla muestra *"Email o contraseña incorrectos"*, y con la contraseña correcta entra. Que no se note es un accidente feliz del orden de las cosas, no un diseño: el ejercicio 17 te pide explicar por qué.

### 5.9 El contrato cambió: actualízalo

`be00` fue tajante: el contrato es lo que se observa. Acabas de cambiar lo que se observa, así que el contrato y su checklist se actualizan **en esta fase**, no "cuando haya tiempo".

En `server/CONTRACT.md`, la sección de autenticación pasa a ser esta:

<<<fragmento:server/CONTRACT.md|## Régimen estricto — autenticación (be04, excepción C-06)|- **Crecimiento:** cada envío lleva `sentBy`, el operador que lo mandó, sacado del token; si el cuerpo trae un `sentBy`, se ignora.>>>

Y en `server/smoke.sh` cambian las verificaciones 1 y 2, aparece una de `401` sin token, y todas las peticiones del dominio llevan `-H "$AUTH"`:

<<<fragmento:server/smoke.sh|# 1. Login (be04)|"$(curl -s -o /dev/null -w '%{http_code}' "$BASE/wheels?_embed=segments")">>>

Corrida del 19/10/2026 contra el binario de esta fase: `Contrato OK.`, dieciocho de dieciocho.

---

## ⚠️ 6. Errores comunes y pieza forense

### Errores comunes

**1. No comprobar el método de firma.** Síntoma: ninguno, hasta que alguien entra con un token que se fabricó solo. Causa: la función de verificación devuelve la clave sin mirar `t.Method`. Fix: las tres líneas de 5.3. Es **la** vulnerabilidad clásica de JWT y sigue apareciendo en auditorías todos los años; la pieza forense mide qué la detiene y qué no.

**2. Distinguir "usuario no existe" de "contraseña incorrecta".** Síntoma: ninguno visible; el sistema parece más amable. Causa: dos ramas de error distintas en el login. Por qué importa: le regala a un atacante un enumerador de cuentas válidas. Fix: un solo error para los dos casos, que es lo que hace `Login`. Y fíjate en lo que **no** hace, medido contra el binario de esta fase: con un email que no existe, el `401` sale en ~1 ms; con un email válido y la clave mal, en ~67 ms, porque `bcrypt` solo corre en el segundo caso. El mensaje no filtra; el reloj, sí. Cerrarlo —comparar contra un hash de relleno también cuando el email no existe— es el ejercicio 2 de `bea-08`.

**3. El secreto en el código.** Síntoma: funciona perfecto. Causa: `JWT_SECRET` con un valor por defecto en el struct de configuración, "para que sea fácil levantarlo". Fix: `required:"true"`. Un secreto con valor por defecto es un secreto público: está en el repositorio, en la imagen y en el historial de git.

**4. Cambiar el nombre del campo `token`.** Síntoma: el login "funciona" —el `POST` devuelve `200`— y todas las peticiones siguientes dan `401`. Causa: alguien lo llamó `accessToken`, que es mejor nombre. Fix: volver a `token`. El contrato manda: `authSlice` lee `token` y el interceptor lee del store.

**5. Verificar el token en el handler y no en el middleware.** Síntoma: funciona en las cinco rutas que revisaste y falla —abierta— en la sexta. Causa: la verificación como responsabilidad de cada handler. Fix: middleware sobre el subrouter. **Una ruta protegida tiene que estar protegida por dónde está montada, no por lo que recuerde su autor.**

**6. Olvidar el `exp`.** Síntoma: ninguno, durante años. Causa: no poner `ExpiresAt`. Un token sin expiración es una llave maestra permanente: quien lo copie de un log, de una captura o del `localStorage` de un equipo prestado entra para siempre.

### 🩻 Pieza forense de esta fase

**Un token manipulado, y el ataque que no funciona por la razón que crees.**

*Paso 1 — mira lo que estás mandando.* Entra a la consola, copia el token del header `Authorization` en Network, y decodifica su segunda parte. Medido: `{"email":"ibatista@esclusa.test","iss":"esclusa-api","sub":"1","exp":…,"iat":…}`, sin ninguna clave. Anota la conclusión con tus palabras: *un JWT no es secreto, es verificable*. (https://jwt.io lo hace en una página web; pega ahí **solo tokens de laboratorio**: un token es una credencial.)

*Paso 2 — modifícalo.* Cambia el `sub` a `2`, conserva la firma y pide las ruedas:

```bash
curl -i localhost:3001/wheels -H "Authorization: Bearer <token-manipulado>"
```

`401` con `Token inválido o expirado`. En el log del servidor, la razón: `signature is invalid`. **El servidor sabe qué pasó y el cliente no se entera.** Esa asimetría es deliberada y es buen diseño de seguridad; `bea-08` la trata a fondo.

*Paso 3 — el ataque `alg: none`.* Fabrica un token sin firma:

```bash
# Cabecera {"alg":"none","typ":"JWT"} y payload con el sub que quieras,
# en Base64URL, y la tercera parte VACÍA (el punto final va igual).
HEADER=$(printf '{"alg":"none","typ":"JWT"}' | base64 | tr '+/' '-_' | tr -d '=\n')
PAYLOAD=$(printf '{"sub":"1","exp":9999999999}' | base64 | tr '+/' '-_' | tr -d '=\n')
curl -i localhost:3001/wheels -H "Authorization: Bearer $HEADER.$PAYLOAD."
```

`401`. En el log: `algoritmo inesperado: none`. Fue tu comprobación de `t.Method`.

*Paso 4 — ahora quita la defensa.* Comenta las tres líneas del `if _, ok := t.Method.(*jwt.SigningMethodHMAC)` y repite el paso 3.

Medido con las dos librerías, `dgrijalva/jwt-go` v3.2.0 y `golang-jwt/jwt/v4` v4.4.2: **sigue dando `401`**, y el log dice otra cosa: `'none' signature type is not allowed`. Las dos librerías se niegan a aceptar `none` salvo que la clave sea una constante especial que dice explícitamente *"acepto tokens sin firma"*, y tu función devuelve el secreto. El ataque de manual no pasa ni siquiera sin tu comprobación.

¿Entonces sobra? No, y esa es la lección del momento. Lo que te salvó en el paso 4 es una decisión de diseño **de un tercero**, y tu defensa no puede consistir en que la librería se porte bien. La comprobación protege de lo que la librería sí deja pasar: el día que el backend firme con RSA —un par de claves, `bea-04`—, un atacante que cambie `RS256` por `HS256` y firme con tu clave **pública** hace que una función que devuelve "la clave" sin mirar el método verifique su token con ella. Esa es la confusión de algoritmo, y contra ella las tres líneas son la única defensa que es tuya.

*Paso 5 — el token vencido.* Arranca con `JWT_TTL=2s`, entra, espera y pide. Medido: `401`, y en el log `token is expired by 1.6846098s`. Ahora hazlo en la consola con `JWT_TTL=3m`: a los tres minutos, el primer clic te deja en el login sin explicación. **Ese es el aspecto exacto de la deuda 💸 del refresh token.** Escríbelo tal cual en el mapa de deuda: no como "falta implementar refresh", sino como "al vencer el token, el operador pierde lo que estuviera haciendo".

*Paso 6 — el círculo, con identidad.* Manda un envío y sigue el `X-Request-Id` desde la consola del navegador hasta el log del backend. Después pide `GET /grants` y busca el `sentBy` de tu envío. Compáralo con lo que se guardaba en `be03`, que era nada: la diferencia entre las dos filas es toda la fase.

---

> 📓🔥 De esta fase sale el incidente **be-08** de `cuaderno-incidentes-be.md`, hermano del **08** del track base. Mismo síntoma —te saca de la sesión sin avisar— y otra causa: allá el `401` es del caos y aparece repartido al azar; acá es un `exp` real y por eso tiene **patrón horario**.

---

## 🧪 7. Ejercicios (32)

**🟢 Fácil (1–8)**

1. Aplica las migraciones `000004` y `000005` y comprueba en `psql` que `users.token` ya no existe, que la columna se llama `password_hash` y que `grants` tiene `sent_by`.
2. Siembra dos veces y verifica que los hashes de la misma contraseña son distintos. Explica por qué en una línea.
3. Haz `POST /login` con `curl` y comprueba que el token tiene tres partes.
4. Decodifica la segunda parte del token con `base64` y anota qué campos son legibles sin clave.
5. Comprueba que `POST /login` con contraseña incorrecta devuelve `401` con `{"error":…}`.
6. Verifica que `GET /wheels` sin `Authorization` devuelve `401`, y que `POST /players/42/spins` no lo pide.
7. Arranca el binario sin `JWT_SECRET` y comprueba que no arranca.
8. Ejecuta el `git diff` de 5.8 y confirma que solo aparece `authService.js`.

**🟡 Intermedio (9–19)**

9. Haz el recorrido completo en la consola con el backend nuevo y confirma que el login funciona igual que antes desde la interfaz.
10. **Diagnóstico.** Renombra el campo `token` a `accessToken` en la respuesta y describe con precisión en qué punto falla la consola y por qué el login parece haber funcionado.
11. Con `curl`, intenta llevar una rueda de `draft` a `live` sin pasar por `scheduled`, y después de `live` a `draft`. Anota los dos `409` y sus mensajes.
12. **Diagnóstico.** Manda un envío con un campo `sentBy` inventado. Demuestra que el backend lo ignora y encuentra la línea donde se decide quién lo mandó.
13. Comprueba que un `PUT` que no cambia el estado sigue funcionando, y explica por qué esa excepción de `canTransition` es necesaria para el CRUD de la Fase 4.
14. **Diagnóstico.** Provoca el paso 2 de la pieza forense (token manipulado) y correlaciona el `401` que ve el navegador con la línea del log del servidor por su `X-Request-Id`.
15. Baja `JWT_TTL` a 60 segundos y documenta la experiencia de operador completa cuando vence a mitad de un envío masivo.
16. Agrega el id del operador a la línea de log de cada petición autenticada y verifica que sale del token.
17. **Diagnóstico.** El `401` de un login fallido pasa por el interceptor de respuesta de la Fase 2, que hace logout y redirige. Explica, con el código de `store.js` a la vista, por qué no se nota. Después diseña el caso en que sí se notaría.
18. Agrega a `smoke.sh` una verificación de que `GET /users?email=…&password=…` ya no responde, y explica por qué también es contrato.
19. **Diagnóstico.** Intenta entrar con una contraseña de 100 caracteres. Determina qué pasa y en qué capa.

**🟠 Difícil (20–27)**

20. **Diagnóstico.** Ejecuta los pasos 3 y 4 de la pieza forense y escribe el informe del `alg: none`, incluida la conclusión sobre depender de la librería para defenderte.
21. Intenta escribir la prueba de Go que falla si alguien quita la comprobación de `t.Method`, probando un token `none`, uno HS512 y uno RS256. Vas a descubrir que, mientras el backend solo firme con HMAC, los tres dan `401` con o sin la comprobación, y que solo cambia el mensaje del log. Explica por qué, y escribe la prueba que sí fallaría el día que el backend pase a RS256.
22. **Diagnóstico.** Antes de migrar, evalúa por escrito si `GO-2020-0017` afecta a **este** backend. Usa el símbolo afectado que da `govulncheck -json` y busca si el código lo llama. Después migra igual y explica por qué la conclusión no cambia la decisión.
23. Ejecuta la migración a `golang-jwt/jwt/v4` en un commit propio y deja el `go.mod` limpio. Verifica con `grep`, con `go version -m` y explica por qué `go list -m all` no basta.
24. **Diagnóstico.** Rompe la migración a propósito: migra el import pero deja `StandardClaims`. Lee el error del compilador y explica qué te está diciendo el diseño de v4.
25. Sube `golang-jwt/jwt/v4` a la v4.5.2 en una rama, corre `govulncheck` antes y después, y escribe en el mapa de deuda qué cambia y qué cuesta cambiar `D16`. **Criterio:** los dos avisos de 5.7 bis desaparecen y las pruebas siguen en verde.
26. **Diagnóstico.** Demuestra con el recorrido completo que ninguna pantalla pide datos antes del login. Si encuentras una, documéntala como hallazgo de contrato con su código `C-NN`.
27. Diseña el registro de auditoría que dejaría rastro de quién cambió el estado de cada rueda. Decide si va en una tabla, en el log, o en las dos, y justifica con lo que `be07` va a necesitar.

**🔴 Muy difícil (28–32)**

28. **Post-mortem.** Escribe `server/postmortem-jwt.md` según los ocho puntos del post-mortem de `cuaderno-incidentes.md`: síntoma, evidencia (el aviso, la versión afectada, la salida de `govulncheck`), causa raíz, corrección, prueba de regresión y prevención. **Sin culpabilización**: adoptar `dgrijalva/jwt-go` en 2020 era la decisión correcta con la información de 2020. La prevención tiene que ser un mecanismo verificable, no "estar más atentos".
29. Diseña e implementa ese mecanismo: `govulncheck` como paso del pipeline, con una regla sobre qué hallazgos lo hacen fallar (los informativos, ¿sí o no?). `be09` lo va a querer.
30. Argumenta por escrito si el token debería guardarse en `localStorage` —donde está hoy— o en una cookie `HttpOnly`. Defiende las dos posturas con XSS y CSRF sobre la mesa, y después responde la pregunta que de verdad importa acá: **¿podrías cambiarlo sin tocar el frontend?**
31. Diseña la implementación completa de *refresh tokens* para este sistema: endpoints, almacenamiento, rotación, revocación. Enumera **exactamente** qué archivos del frontend habría que tocar y calcula si eso cabe dentro de la excepción `D27`. Concluye si se haría, y con qué plan.
32. **Diagnóstico + regresión.** Ticket: *"a Yariela la saca de la sesión a las ocho de la noche, justo en el cierre de la rueda, y a Itzel nunca"*. Con lo que sabes de `exp` y de la ausencia de refresh, reconstruye la causa, di cómo la confirmarías con los logs que tienes, y escribe la prueba de regresión y la comunicación al equipo.

**🔥 Opcionales**

- 🔥 Sustituye HS256 por RS256 (par de claves) y explica qué gana el sistema: quién puede firmar, quién puede verificar, y por qué eso importa el día que el juego necesite verificar tokens.
- 🔥 Implementa una lista de revocación en memoria para invalidar un token antes de su `exp`, y después argumenta qué acabas de perder. Pista: era la propiedad que hacía atractivo el JWT.
- 🔥 Corre `govulncheck` con Go 1.22 sobre el mismo código y compara cuántas de las 42 vulnerabilidades de la biblioteca estándar desaparecen.

---

## 📚 8. Referencias

**Documentación oficial y avisos**
- https://pkg.go.dev/vuln/GO-2020-0017 — el aviso en la base de datos de vulnerabilidades de Go, con sus alias y el símbolo afectado.
- https://github.com/advisories/GHSA-w73w-5m7g-f7qc — el aviso de GitHub. **Ábrelo y léelo**: es material de la fase, no una nota al pie.
- https://nvd.nist.gov/vuln/detail/CVE-2020-26160 — la entrada en la NVD, con el vector CVSS desglosado.
- https://pkg.go.dev/vuln/GO-2024-3250 y https://pkg.go.dev/vuln/GO-2025-3553 — los dos avisos del fork en la v4.4.2.
- https://go.dev/doc/tutorial/govulncheck — `govulncheck`: qué reporta, y la diferencia entre lo que el código alcanza y lo informativo.
- https://github.com/golang-jwt/jwt — el fork, con su guía de migración desde `dgrijalva`.
- https://pkg.go.dev/golang.org/x/crypto/bcrypt — la API, `DefaultCost` y `ErrPasswordTooLong`.
- https://www.rfc-editor.org/rfc/rfc7519 — JWT. Para hoy: §4.1 (claims registrados).
- https://www.rfc-editor.org/rfc/rfc8725 — *JSON Web Token Best Current Practices*. El documento más útil de esta lista: el §2.1 y el §3.1 son la confusión de algoritmo explicada por quienes escribieron el estándar.
- https://cheatsheetseries.owasp.org/cheatsheets/Password_Storage_Cheat_Sheet.html — almacenamiento de contraseñas, con recomendaciones de costo actualizadas.

**Libros**
- *Web Application Security* (Andrew Hoffman) — los capítulos de autenticación y de ataques sobre tokens.
- *Security Engineering* (Ross Anderson) — el capítulo sobre contraseñas, para entender por qué `bcrypt` es lento a propósito.

**Video / apoyo**
- Busca "JWT algorithm confusion attack" y "bcrypt vs sha256 password" en YouTube. Verifica que la demostración corresponda a una librería actual: muchas usan implementaciones ya corregidas, como mide el paso 4.

**Orden de lectura sugerido:** el aviso `GO-2020-0017` primero, entero, antes de escribir código —así la migración de 5.7 llega con contexto— → RFC 8725 §2 y §3, que son pocas páginas y cubren todos los errores comunes de esta fase → `bea-04` para la anatomía completa del token → `bea-08` cuando quieras el resto del panorama de seguridad de la API.

> ⚠️ URLs, títulos, severidades y fechas pueden haber cambiado: **verifícalos**. Las salidas de `govulncheck` de esta fase son de la corrida del 19/10/2026, y la base de datos de vulnerabilidades crece todos los meses: la tuya va a tener más líneas. Las referencias a libros son de memoria y pueden ser inexactas. Cualquier discrepancia de versiones la resuelve `00-decisiones-y-versiones.md` §7.

---

## 🚀 9. Cierre y conexión con la siguiente fase

Cuatro deudas pagadas. Las contraseñas son hashes con sal, el token es un JWT firmado que expira, la identidad sale del token y no del cuerpo —cada envío sabe quién lo mandó—, y las transiciones de la rueda las custodia el service. La columna de la vergüenza que `be03` creó ya no existe, y el `go.mod` pasó por una librería abandonada y salió del otro lado con un post-mortem escrito y un mecanismo que, la segunda vez, avisó solo.

La consola, mientras tanto, cambió **un archivo**: el que la Fase 2 había señalado con el dedo.

Queda una deuda declarada y viva: sin *refresh token*, un token vencido tira al operador al login. Está en el mapa de deuda con su motivo, y `be09` la va a recoger en el veredicto honesto del track.

`be05` es la primera de las dos fases ⭐ y va al corazón del curso. Ya sabes quién manda cada envío; falta que **mil jugadores girando en el mismo segundo no se lleven 1.047 Esclusas de Oro de un stock de mil**. El giro de 2019 sigue exactamente igual de indefenso que en el mock, y esta vez no se traduce de lenguaje: se resuelve donde se resuelve, con una clave de idempotencia única, un descuento condicional y `SELECT … FOR UPDATE`, medido con k6.

> **La señal de que quedó bien:** *"el backend ya no le cree nada al navegador sobre quién es, y la consola no se dio cuenta del cambio."*

> 🏷️ **No cierres la fase sin el tag.** Con el checklist de la sección 2 en verde y `git status` limpio:
>
> ```bash
> git tag -a fase-be04-identidad-real-jwt-y-un-cve -m "be04 cerrada: \
> migraciones 000004 (password_hash, sin token) y 000005 (sent_by); siembra con bcrypt; \
> POST /login firmando JWT en el mismo campo token; middleware y subrouter protegido; \
> identidad desde el contexto; transiciones custodiadas en el service; \
> dgrijalva/jwt-go adoptado y migrado a golang-jwt/jwt v4.4.2 con post-mortem; \
> excepción D27 en un solo archivo; CONTRACT.md y smoke.sh actualizados"
> ```
>
> Los commits de la fase llevan su prefijo (`be04: …`) y los de ejercicio su número (`be04 ej28: …`). La adopción y la migración de la librería van en **dos commits distintos** —`be04: adopta dgrijalva/jwt-go v3.2.0` y `be04: migra a golang-jwt/jwt v4 (CVE-2020-26160)`—: el `git log` de esta fase tiene que contar la historia solo. Si un ejercicio merece su propio marcador va en `ej/be04/28`, y un incidente resuelto en el par `inc/<ID>/<slug>-roto` / `-fix`, con el ID que le reserva `cuaderno-incidentes-be.md`. Todo eso está en [`00-convencion-de-git-y-tags.md`](00-convencion-de-git-y-tags.md).

---

## 📌 Pendientes sugeridos

*(Fuera de lo que lee el estudiante.)*

- **El comando de verificación cambia a partir de acá.** Todas las fases `be05` a `be09` usan `git diff pre-backend-go..HEAD -- . ':!server' ':!src/api/authService.js'` en su checklist (D27).
- **`CONTRACT.md` y `smoke.sh` cambiaron en esta fase**, y sienta el precedente: cuando una fase cambia lo observable, actualiza los dos documentos **en la misma fase**. Desde acá `smoke.sh` hace login y manda el token.
- **`D16` queda congelada en v4.4.2 por decisión del autor (19/10/2026)**, con los dos avisos medidos (`GO-2024-3250`, `GO-2025-3553`) contados en 5.7 bis y la subida como ejercicio 25. Las 42 vulnerabilidades de la biblioteca estándar de Go 1.19.13 van al veredicto de `be09` y a `bea-09`.
- **Deuda 💸 viva declarada: sin *refresh token*.** Tiene que aparecer en `bea-09` y en el veredicto de `be09`. Es la deuda que el track decide **no** pagar.
- **Deudas menores declaradas:** 💸 sin autorización a nivel de objeto ni roles (`bea-08`); 💸 sin límite de intentos de login (`bea-08`); 💸 el giro del juego sin autenticación (`bea-08`); 💸 el token en `localStorage`.
- **`be05` empieza con el giro de 2019 intacto** y con el chequeo de caso del envío intacto. Esta fase no los tocó a propósito.
- **`be06` hereda las transiciones.** Hoy se custodian por *orden*; cuando el reloj sea autoridad del servidor, `live → ended` va a poder dispararse también por tiempo.
- **Reserva para el cuaderno de incidentes:** `be-08` — *"a Yariela la saca de la sesión a las ocho de la noche y a Itzel nunca"* (🔥 autenticación, 🟡), rama de diff vacío con `JWT_TTL=3m`.
