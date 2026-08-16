# 🔐 Fase be04 — Identidad real: bcrypt, JWT y un CVE

> Tutorial React 16 — Rifas y chances · **Track BE opcional 🔥** · Fase be04 de be09 · **8 horas**
> Depende de: be03 — el backend ya sirve a la aplicación · Habilita: be05 — Venta concurrente

---

## 🎯 1. Propósito

Esta fase cobra **cuatro deudas de una vez**, y las cuatro estaban declaradas por
escrito desde la Fase 2 del track base:

1. **El token de mentira.** Una constante de texto en `db.json` que `be03`
   convirtió en una columna. Sin firma, sin expiración, sin secreto.
2. **Las contraseñas en claro.** `json-server` las comparaba como strings y
   `be03` heredó la comparación tal cual, ahora en SQL.
3. **El cliente mentiroso.** Quien crea una rifa, quien la cierra y quien la
   liquida es quien el navegador dice que es. El servidor nunca preguntó.
4. **Las transiciones libres.** El flujo `borrador → abierta → cerrada →
   resuelta → liquidada` lo decide el frontend, y nadie verifica que el orden
   tenga sentido.

Y trae, de regalo, algo que ninguna fase inventada podría mejorar: **la
secuencia completa de adoptar una dependencia que era *la* dependencia,
descubrir que está abandonada con un aviso de seguridad abierto, y migrar al
fork**. No es una anécdota que se cuenta: se hace, con el `go.mod` cambiando en
dos commits y un post-mortem al final.

> 🧭 Y una restricción que ordena toda la fase: **el JWT firmado viaja en el
> mismo campo `token` que el frontend ya lee**. El interceptor de `apiClient`
> manda `Bearer ${token}` desde la Fase 2 justamente para que este día llegara
> sin tocarlo. No se toca.

---

## ✅ 2. Qué queda listo al terminar

- [ ] Migración `000004`: `users.password` pasa a `password_hash` y **la columna
      `users.token` desaparece**. La deuda de `be03` se paga borrando su DDL.
- [ ] La siembra hashea con `bcrypt` las contraseñas que vienen en claro del
      `db.json`, y el `db.json` no se modifica.
- [ ] `POST /login` valida contra el hash y devuelve
      `{ id, email, name, token }` con el `token` firmado.
- [ ] La **única excepción del track** está ejecutada: `src/api/authService.js`
      modificado, y **ningún otro archivo del frontend** (`D27` / `C-06`).
- [ ] Middleware de verificación montado sobre las rutas del dominio; un token
      inválido o vencido devuelve `401` con la forma que el interceptor ya sabe
      manejar.
- [ ] La identidad viaja en `req.Context()` y **ningún handler la lee del cuerpo
      de la petición**.
- [ ] Las transiciones de estado están custodiadas en el service, con su tabla de
      transiciones legales, y una ilegal devuelve `409`.
- [ ] `dgrijalva/jwt-go` v3.2.0 entró al `go.mod` y **salió en la misma fase**,
      reemplazado por `golang-jwt/jwt/v4` v4.4.2.
- [ ] Existe `server/postmortem-jwt.md`, escrito sin culpabilización.
- [ ] `server/CONTRACT.md` y `server/smoke.sh` están actualizados con el nuevo
      login, y el `smoke.sh` pasa entero.
- [ ] `git diff pre-backend-go..HEAD -- . ':!server' ':!src/api/authService.js'`
      no devuelve nada.

---

## 🚫 3. Qué queda fuera por ahora

- **Los *refresh tokens*.** No entran, y esto es una decisión, no un olvido: el
  JWT expira, el frontend no lo renueva, y cuando expira el interceptor de la
  Fase 2 hace logout global. **Esa fricción se declara como deuda 💸 viva** en
  vez de tocar el frontend para arreglarla. Para el laboratorio, el token tiene
  vida larga. Ver 4.5.
- **Roles y permisos finos.** Todos los usuarios pueden todo. Autorización a
  nivel de objeto —"¿esta rifa es tuya?"— es tema de `bea-08`.
- **Límite de tasa e intentos fallidos** → `bea-08`. Hoy puedes probar
  contraseñas todo el día.
- **El `409` de venta concurrente** → `be05`. El `409` de esta fase es el de una
  transición ilegal, que es otra cosa.
- **La hora de cierre evaluada en el servidor** → `be06`. Las transiciones se
  custodian por *orden*, no todavía por *reloj*.

---

## 🧠 4. Conceptos mínimos

### 4.1 `bcrypt`: por qué no es un hash cualquiera

Sabes qué es una función de hash. Lo que hay que tener claro es por qué SHA-256
—que es una excelente función de hash— **es una pésima forma de guardar
contraseñas**: porque es rápida. Una GPU moderna calcula miles de millones de
SHA-256 por segundo, y eso es exactamente lo que hace un atacante con tu tabla
de usuarios.

`bcrypt` resuelve dos problemas a la vez. Es **deliberadamente lento**, con un
factor de costo ajustable: subir el costo en uno duplica el tiempo, así que la
defensa se puede escalar con el hardware sin cambiar de algoritmo. Y **incorpora
la sal en el propio hash**, así que no hay una columna `salt` que administrar ni
la posibilidad de olvidarla. El resultado se ve así, y las cuatro partes están a
la vista:

```
$2a$10$N9qo8uLOickgx2ZMRZoMye.IjPeCLSjXBSHkVvHXfUqBLNhSHhBFq
 │   │  └── sal (22 caracteres) ─┴── hash (31 caracteres)
 │   └── costo: 10 → 2^10 iteraciones
 └── variante del algoritmo
```

De ahí salen las dos reglas de uso, y las dos son fáciles de romper: **nunca
compares hashes con `==`** —se usa `CompareHashAndPassword`, que además tarda lo
mismo acierte o falle— y **el hash es opaco**: no se parsea, no se indexa, no se
compara por prefijo.

> ⚠️ **La trampa de los 72 bytes.** `bcrypt` ignora todo lo que pase de 72 bytes
> de entrada. Una contraseña de 100 caracteres se trunca en silencio, y las dos
> primeras mitades iguales dan el mismo hash. La implementación de Go es honesta
> y devuelve `bcrypt.ErrPasswordTooLong` en vez de truncar — pero solo si le
> manejas el error, que es lo que casi nadie hace.

### 4.2 JWT en cinco líneas (el resto está en `bea-04`)

Tres partes separadas por puntos, las dos primeras en Base64URL **sin cifrar**:
cabecera (qué algoritmo), *claims* (quién, cuándo expira, para quién) y firma.
Cualquiera puede leer el contenido de un JWT; nadie puede modificarlo sin el
secreto.

Lo que hay que interiorizar hoy son dos cosas. La primera: **un JWT no es una
sesión**. No hay estado del lado del servidor, y por eso no se puede invalidar —
un token robado sirve hasta que expira, y punto. La segunda: **la cabecera la
elige quien manda el token**, no quien lo verifica. Esa frase inocente es el
origen de la familia de ataques de confusión de algoritmo, incluido el `alg:
none`, y es la pieza forense de esta fase.

### 4.3 La identidad viene del contexto, jamás del cuerpo

Hoy, cuando el frontend crea una rifa, el backend acepta lo que sea que venga en
el JSON. Si mañana alguien manda `{"ownerId": 7}` con el token del usuario 2, el
servidor le cree.

La regla no admite matices: **lo que el cliente afirma sobre sí mismo es un dato
de entrada, no una verdad**. La identidad se extrae del token en el middleware,
se deja en `req.Context()` y de ahí la leen los services. Cualquier campo del
cuerpo que hable de identidad se **ignora**, no se valida — validarlo sería
admitir que a veces es fuente de verdad.

Fíjate en la simetría con `be01`: el `X-Request-Id` y el `userID` viajan por el
mismo canal y por la misma razón. Son datos de alcance de petición que atraviesan
capas sin ser parte de la lógica de negocio. Eso es exactamente para lo que
existe `context.Context`, y es el único uso legítimo de sus valores.

### 4.4 Las transiciones como máquina de estados

El flujo del dominio tiene cinco estados y **no todas las transiciones son
legales**. Hoy el frontend decide y el backend obedece; un `PUT` con
`status: "settled"` sobre una rifa en borrador funciona perfecto y deja el
sistema en un estado imposible.

| Desde | Puede ir a |
|---|---|
| `draft` | `open` |
| `open` | `closed` |
| `closed` | `resolved` |
| `resolved` | `settled` |

Todo lo que no esté en esa tabla es un `409 Conflict`: la petición está bien
formada, pero el estado del recurso no permite lo que pide. La misma semántica
que el `409` de venta duplicada que la Fase 5 ya sabe manejar, aplicada a otra
cosa.

Custodiar esto en el **service** y no en el handler no es purismo: es que la
regla tiene que valer también para el `SettleRaffle` que `be07` va a llamar desde
otro camino, y para cualquier consumidor futuro que no entre por HTTP.

### 4.5 El *refresh token* que no vamos a hacer, y por qué se declara

Un JWT que expira deja al usuario afuera. La solución estándar es un par de
tokens: uno corto para las peticiones y uno largo para renovarlo sin volver a
pedir contraseña. Implementarlo requiere un endpoint nuevo **y que el frontend lo
llame** — o sea, tocar `apiClient.js`, sus interceptores y probablemente el
`authSlice`.

> 🧭 **Decisión: no se hace.** Ampliar la excepción `D27` a media capa de red del
> frontend convertiría "la única excepción negociada" en una licencia general, y
> ahí se cae la regla que ordena el track entero.

Así que el token tiene vida larga en el laboratorio (`JWT_TTL`, doce horas por
defecto), y la fricción se declara: **cuando expire, el interceptor de la Fase 2
recibirá un `401` y hará logout global, y el usuario tendrá que entrar de
nuevo**. Eso no es un bug del backend. Es la consecuencia visible de una decisión
de alcance, anotada en el mapa de deuda con su fecha y su motivo. Un sistema real
la pagaría; este declara por qué no.

---

## 💻 5. Implementación y código comentado

### 5.1 La migración que borra la vergüenza

```sql
-- server/migrations/postgres/000004_real_credentials.up.sql
-- Cobra dos de las cuatro deudas de esta fase, y las cobra en el DDL:
-- la contraseña deja de ser texto comparable y el token de mentira
-- desaparece de la base.

-- El nombre importa: password_hash le dice a quien lea el esquema dentro de
-- dos años que ahí NO hay una contraseña. Un nombre honesto vale más que un
-- comentario.
ALTER TABLE users RENAME COLUMN password TO password_hash;

-- 🪦 La columna que be03 creó con fecha de vencimiento. Guardaba una
-- credencial sin firma ni expiración; a partir de acá el token se firma en
-- cada login y no se guarda en ninguna parte. Un token que vive en la base
-- es un token que se puede robar de la base.
ALTER TABLE users DROP COLUMN token;
```

```sql
-- server/migrations/postgres/000004_real_credentials.down.sql
-- El down existe, y devolver la vulnerabilidad es exactamente lo que debe
-- hacer: una migración reversible no juzga, revierte. Los hashes que queden
-- en la columna dejarán de servir como contraseñas en claro, y eso es un
-- efecto que hay que documentar en el runbook, no esconder.
ALTER TABLE users ADD COLUMN token TEXT;
ALTER TABLE users RENAME COLUMN password_hash TO password;
```

### 5.2 La siembra hashea al entrar

El `db.json` del track base tiene `"password": "rifas123"` en claro, y **no se
modifica**: es el archivo del alumno y es evidencia histórica del sistema. Quien
traduce es la semilla.

```bash
cd server && go get golang.org/x/crypto@v0.4.0
```

```go
// server/internal/seed/seed.go (extracto: el bucle de usuarios cambia)

for _, u := range data.Users {
	// El db.json trae la contraseña en claro porque así vivía el sistema.
	// Acá entra al backend por última vez en esa forma: se hashea antes de
	// tocar la base, y el valor original no se guarda en ningún lado.
	//
	// bcrypt.DefaultCost es 10. Subirlo endurece la defensa y hace más
	// lenta la siembra; para el laboratorio, 10 está bien y es lo que
	// usarías en producción en 2022. Revisa el costo cada par de años:
	// es un parámetro que envejece con el hardware, no con el algoritmo.
	hash, err := bcrypt.GenerateFromPassword([]byte(u.Password), bcrypt.DefaultCost)
	if err != nil {
		// Este error casi siempre significa ErrPasswordTooLong (>72 bytes).
		// Manejarlo en vez de ignorarlo es lo que evita el truncado
		// silencioso del que habla 4.1.
		return fmt.Errorf("hasheando la contraseña de %s: %w", u.Email, err)
	}

	_, err = tx.ExecContext(ctx, db.Rebind(`
		INSERT INTO users (id, email, password_hash, name)
		VALUES (?, ?, ?, ?)
		ON CONFLICT (id) DO UPDATE
		SET email = EXCLUDED.email, password_hash = EXCLUDED.password_hash,
		    name = EXCLUDED.name`),
		u.ID, u.Email, string(hash), u.Name)
	if err != nil {
		return fmt.Errorf("sembrando el usuario %s: %w", u.Email, err)
	}
}
```

> 🧠 **Corre la siembra dos veces y mira los dos hashes.** Son distintos, y la
> contraseña es la misma. Esa es la sal aleatoria haciendo su trabajo: dos
> usuarios con la misma contraseña no comparten hash, y por lo tanto una tabla
> filtrada no revela quién usa la misma clave que quién.

### 5.3 El paquete `auth`, con `dgrijalva/jwt-go` v3.2.0

Ahora la parte que hay que hacer **exactamente así**, aunque sepas cómo termina.

```bash
go get github.com/dgrijalva/jwt-go@v3.2.0+incompatible
```

> 📝 **Por qué esta librería y no otra.** En 2022, `dgrijalva/jwt-go` era *la*
> librería de JWT en Go: la que aparecía en todos los tutoriales, la que estaba
> en el `go.mod` de miles de proyectos. Elegirla no era una mala decisión — era
> **la** decisión. Que esté acá no es una trampa didáctica: es lo que había.
>
> Fíjate en el `+incompatible` del `go get`. Eso significa que el repositorio
> etiquetó una v3 sin declarar el sufijo `/v3` en su módulo, como pide el
> versionado semántico de Go. Es una señal, y es de las que se aprenden a leer
> tarde.

```go
// server/internal/auth/auth.go
package auth

import (
	"errors"
	"fmt"
	"time"

	"github.com/dgrijalva/jwt-go"
	"golang.org/x/crypto/bcrypt"
)

var (
	ErrInvalidCredentials = errors.New("email o contraseña incorrectos")
	ErrInvalidToken       = errors.New("token inválido o expirado")
)

// Claims son los datos que viajan firmados. StandardClaims trae los campos
// registrados del RFC 7519 (sub, exp, iat, aud, iss).
//
// ⚠️ Todo lo que pongas acá viaja en Base64, LEGIBLE POR CUALQUIERA. Está
// firmado, no cifrado. Nada de datos sensibles: ni el hash, ni el documento
// del usuario, ni nada que no pondrías en una postal.
type Claims struct {
	Email string `json:"email"`
	jwt.StandardClaims
}

type Signer struct {
	secret []byte
	ttl    time.Duration
}

func NewSigner(secret string, ttl time.Duration) (*Signer, error) {
	// Un secreto corto es un secreto que se rompe por fuerza bruta offline:
	// el atacante tiene el token y todo el tiempo del mundo. 32 bytes es el
	// mínimo razonable para HS256.
	if len(secret) < 32 {
		return nil, errors.New("JWT_SECRET debe tener al menos 32 caracteres")
	}
	return &Signer{secret: []byte(secret), ttl: ttl}, nil
}

// Sign emite el token de un usuario.
func (s *Signer) Sign(userID int64, email string) (string, error) {
	now := time.Now()
	claims := Claims{
		Email: email,
		StandardClaims: jwt.StandardClaims{
			// sub es el usuario. Es la única fuente de identidad que el
			// backend va a aceptar a partir de esta fase.
			Subject:   fmt.Sprintf("%d", userID),
			IssuedAt:  now.Unix(),
			ExpiresAt: now.Add(s.ttl).Unix(),
			Issuer:    "raffles-api",
		},
	}

	token := jwt.NewWithClaims(jwt.SigningMethodHS256, claims)
	signed, err := token.SignedString(s.secret)
	if err != nil {
		return "", fmt.Errorf("firmando el token: %w", err)
	}
	return signed, nil
}

// Verify valida firma y expiración, y devuelve el id del usuario.
func (s *Signer) Verify(tokenString string) (int64, error) {
	var claims Claims

	_, err := jwt.ParseWithClaims(tokenString, &claims, func(t *jwt.Token) (interface{}, error) {
		// 🧭 ESTAS TRES LÍNEAS SON LO MÁS IMPORTANTE DEL ARCHIVO.
		//
		// La cabecera del token la elige QUIEN LO MANDA. Sin esta
		// comprobación, un atacante cambia alg a "none", borra la firma, y
		// una implementación ingenua acepta el token porque "el algoritmo
		// declarado dice que no hay que verificar nada".
		//
		// La función de verificación devuelve la clave; si no compruebas
		// que el método es el que TÚ elegiste, estás delegando en el
		// atacante la decisión de cómo se verifica su propio token.
		if _, ok := t.Method.(*jwt.SigningMethodHMAC); !ok {
			return nil, fmt.Errorf("algoritmo inesperado: %v", t.Header["alg"])
		}
		return s.secret, nil
	})
	if err != nil {
		return 0, ErrInvalidToken
	}

	var userID int64
	if _, err := fmt.Sscanf(claims.Subject, "%d", &userID); err != nil {
		return 0, ErrInvalidToken
	}
	return userID, nil
}

// CheckPassword compara la contraseña con el hash guardado.
//
// bcrypt.CompareHashAndPassword tarda lo mismo acierte o falle, y eso no es
// casualidad: una comparación que devuelve más rápido cuando el primer byte
// no coincide filtra información. Nunca compares hashes con ==.
func CheckPassword(hash, plain string) error {
	if err := bcrypt.CompareHashAndPassword([]byte(hash), []byte(plain)); err != nil {
		// Se devuelve SIEMPRE el mismo error, tanto si el usuario no existe
		// como si la contraseña está mal. Distinguirlos le regala al
		// atacante un enumerador de cuentas válidas.
		return ErrInvalidCredentials
	}
	return nil
}
```

### 5.4 `POST /login` y el middleware

```go
// server/internal/http/auth.go

// LoginHandler → POST /login
//
// 🧭 La forma de la RESPUESTA es contrato: { id, email, name, token }, con
// token como string opaca. Es exactamente lo que devolvía el mock, y por eso
// el authSlice, el interceptor y los componentes no cambian. Lo único que
// cambia es que ahora ese string está firmado y expira.
func LoginHandler(svc *auth.Service) http.HandlerFunc {
	return func(w http.ResponseWriter, r *http.Request) {
		var body struct {
			Email    string `json:"email"`
			Password string `json:"password"`
		}
		if err := json.NewDecoder(r.Body).Decode(&body); err != nil {
			writeError(w, http.StatusBadRequest, "Cuerpo inválido")
			return
		}

		session, err := svc.Login(r.Context(), body.Email, body.Password)
		if errors.Is(err, auth.ErrInvalidCredentials) {
			// 401 con el mensaje en español que authService traduce a la UI.
			//
			// ⚠️ Detalle que importa: el interceptor de respuesta de la
			// Fase 2 dispara el manejo global de sesión ante un 401. Que
			// ESTE 401 —el de un login fallido, cuando todavía no hay
			// sesión— no cause un efecto raro es algo que hay que
			// COMPROBAR en el navegador, no suponer. Ejercicio 17.
			writeError(w, http.StatusUnauthorized, "Email o contraseña incorrectos")
			return
		}
		if err != nil {
			writeError(w, http.StatusInternalServerError, "Error interno del servidor")
			return
		}
		writeJSON(w, http.StatusOK, session)
	}
}

// authMiddleware verifica el token y deja el id del usuario en el contexto.
func authMiddleware(signer *auth.Signer) func(http.Handler) http.Handler {
	return func(next http.Handler) http.Handler {
		return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
			header := r.Header.Get("Authorization")
			// El formato lo fija el interceptor de la Fase 2 desde el día
			// uno: "Bearer <token>". Se compara sin distinguir mayúsculas
			// porque el RFC 7235 dice que el esquema es case-insensitive.
			parts := strings.SplitN(header, " ", 2)
			if len(parts) != 2 || !strings.EqualFold(parts[0], "Bearer") {
				writeError(w, http.StatusUnauthorized, "Token inválido o expirado")
				return
			}

			userID, err := signer.Verify(parts[1])
			if err != nil {
				// Mismo mensaje que inyectaba el caos del mock, a
				// propósito: el frontend ya sabe reaccionar a este 401 y
				// no tiene por qué distinguir un token vencido de uno
				// falsificado. El que sí tiene que distinguirlos es el
				// log del servidor.
				writeError(w, http.StatusUnauthorized, "Token inválido o expirado")
				return
			}

			// La identidad entra al contexto. De acá en adelante, NINGÚN
			// handler vuelve a mirar el cuerpo para saber quién pide.
			ctx := context.WithValue(r.Context(), userIDKey, userID)
			next.ServeHTTP(w, r.WithContext(ctx))
		})
	}
}

// UserIDFrom es la única puerta a la identidad. Devuelve 0 si no hay
// ninguna, y un service que reciba 0 debe rechazar la operación: es el
// caso "alguien montó una ruta protegida fuera del middleware".
func UserIDFrom(ctx context.Context) int64 {
	if id, ok := ctx.Value(userIDKey).(int64); ok {
		return id
	}
	return 0
}
```

Y el montaje, que tiene una decisión escondida:

```go
// server/internal/http/router.go (extracto)

// Público: solo el login y el andamiaje del laboratorio.
r.HandleFunc("/login", LoginHandler(authSvc)).Methods(http.MethodPost)
r.HandleFunc("/health", healthHandler(db)).Methods(http.MethodGet)
r.HandleFunc("/_chaos", chaosHandler(chaos)).Methods(http.MethodPost)

// Protegido: todo el dominio. Un subrouter con su propio middleware.
api := r.NewRoute().Subrouter()
api.Use(authMiddleware(signer))
api.HandleFunc("/raffles", ListRafflesHandler(raffleSvc)).Methods(http.MethodGet)
// … el resto del dominio
```

> ⚠️ **Esto es una validación MÁS ESTRICTA que la del mock, y por lo tanto un
> riesgo de contrato.** El régimen de crecimiento de `be00` admite validaciones
> más permisivas, nunca más estrictas: hasta ayer, `GET /raffles` respondía sin
> token y ahora exige uno.
>
> Se acepta porque **es la deuda que la fase cobra** —un backend que no verifica
> quién pide no es un backend—, pero no se acepta por fe: se **mide**. El
> frontend manda `Authorization` en toda petición con sesión activa y la guarda
> de rutas impide llegar a esas pantallas sin sesión, así que en la práctica no
> se rompe nada. Compruébalo tú en el recorrido completo antes de darlo por
> bueno, y anota el resultado en `CONTRACT.md`. Si alguna pantalla pide datos
> antes del login, la encontraste ahora y no en producción.

### 5.5 Las transiciones, custodiadas donde corresponde

```go
// server/internal/raffle/transitions.go
package raffle

// legalTransitions es la máquina de estados del dominio, escrita una sola
// vez y en el service. El frontend puede pedir lo que quiera; acá se decide.
var legalTransitions = map[string][]string{
	"draft":    {"open"},
	"open":     {"closed"},
	"closed":   {"resolved"},
	"resolved": {"settled"},
	"settled":  {}, // estado final: de acá no se sale
}

var ErrIllegalTransition = errors.New("esa rifa no puede pasar a ese estado")

func canTransition(from, to string) bool {
	// Un PUT que no cambia el estado no es una transición: es una edición
	// de otros campos. Permitirlo explícitamente evita que el CRUD de la
	// Fase 4 —que manda la rifa entera en cada PUT— empiece a fallar.
	if from == to {
		return true
	}
	for _, allowed := range legalTransitions[from] {
		if allowed == to {
			return true
		}
	}
	return false
}

// Update aplica la edición verificando la transición.
func (s *Service) Update(ctx context.Context, incoming Raffle) (Raffle, error) {
	current, err := s.store.FindByID(ctx, incoming.ID)
	if err != nil {
		return Raffle{}, err
	}

	if !canTransition(current.Status, incoming.Status) {
		return Raffle{}, fmt.Errorf("de %q a %q: %w",
			current.Status, incoming.Status, ErrIllegalTransition)
	}

	// 🧭 La identidad sale del contexto. Si el cuerpo trajera un ownerId,
	// se IGNORA — no se valida, se ignora. Validarlo sería admitir que a
	// veces el cliente puede decidir quién es.
	//
	// 💸 Hoy solo se registra en el log: no hay columna owner_id ni reglas
	// de propiedad. Autorización a nivel de objeto es bea-08.
	log.Printf("[req-id %s] usuario %d cambia la rifa %d de %s a %s",
		RequestIDFrom(ctx), UserIDFrom(ctx), incoming.ID, current.Status, incoming.Status)

	return s.store.Update(ctx, incoming)
}
```

El handler traduce el error de dominio a `409`, con la misma semántica que el
`409` de venta duplicada que la Fase 5 ya sabe mostrar: la petición está bien
formada, el estado del recurso no la permite.

### 5.6 🚨 El descubrimiento

Con todo funcionando, haz lo que deberías hacer con cualquier dependencia antes
de que llegue a producción:

```bash
cd server
go list -m -u all | grep jwt
go list -m -versions github.com/dgrijalva/jwt-go
```

Y después abre el repositorio. Vas a encontrarte con que el proyecto **está
archivado**, que su README remite a otro sitio, y que hay un aviso de seguridad
abierto **sin parche disponible**.

Este es el aviso, y es el que hay que leer entero:

- **`GHSA-w73w-5m7g-f7qc`** — https://github.com/advisories/GHSA-w73w-5m7g-f7qc
- **`CVE-2020-26160`** — https://nvd.nist.gov/vuln/detail/CVE-2020-26160

Lo verificado contra el aviso, al escribir esta fase: afecta a
`github.com/dgrijalva/jwt-go` **hasta la v3.2.0 inclusive** —o sea, exactamente
la que acabas de instalar—, severidad **alta (CVSS 7.5)**, publicado el **30 de
septiembre de 2020** en la NVD. **No hay parche**: la solución es migrar al fork
`golang-jwt/jwt`, desde su v3.2.1.

El fallo, en una frase: cuando el *claim* de audiencia (`aud`) llega como un
arreglo vacío, la aserción de tipo falla y la audiencia queda como cadena vacía.
Una aplicación que confíe **solo** en esta librería para verificar la audiencia
puede aceptar un token que no era para ella.

> 🧠 **Lee esto antes de encogerte de hombros.** Es tentador decir "pero nosotros
> no usamos `aud`, no nos afecta". Puede que tengas razón — y esa evaluación es
> exactamente el trabajo, no un atajo para saltárselo. Lo que sí te afecta seguro
> es lo otro: **la librería está abandonada**. El CVE es el síntoma; el problema
> es que el próximo hallazgo tampoco va a tener parche. Se migra por eso.
>
> ⚠️ **Verifica todo esto tú mismo antes de citarlo.** Los avisos se actualizan,
> las severidades se recalculan y los enlaces cambian. Los datos de arriba se
> confirmaron contra el aviso oficial al escribir esta fase, y aun así el
> procedimiento correcto es abrirlo y leerlo — que es, además, la mitad de lo que
> esta fase enseña. `bea-04` explica cómo se lee un aviso de seguridad línea por
> línea.

### 5.7 La migración al fork

```bash
go get github.com/golang-jwt/jwt/v4@v4.4.2
go mod edit -droprequire github.com/dgrijalva/jwt-go
go mod tidy
```

El cambio en el código es sorprendentemente pequeño, y esa pequeñez **también es
contenido**: un fork bien hecho conserva la superficie de la API para que migrar
no sea una excusa para no migrar.

```go
// ANTES                                    // DESPUÉS
import "github.com/dgrijalva/jwt-go"        import "github.com/golang-jwt/jwt/v4"

jwt.StandardClaims                          jwt.RegisteredClaims
IssuedAt:  now.Unix()                       IssuedAt:  jwt.NewNumericDate(now)
ExpiresAt: now.Add(ttl).Unix()              ExpiresAt: jwt.NewNumericDate(now.Add(ttl))
```

Los tres cambios de v4 tienen su razón y vale la pena entenderlos en vez de
aplicarlos a ciegas:

- **`StandardClaims` → `RegisteredClaims`.** El nombre del RFC 7519 es "claims
  registrados". El anterior nunca fue el correcto.
- **`int64` → `*jwt.NumericDate`.** Con `int64`, "sin expiración" y "expira en el
  epoch" son el mismo valor: `0`. Con un puntero, ausente y cero son distintos.
  Es la misma lección del `participantId` de `be03`, en otra capa.
- **La verificación de `aud` cambió**, que es lo que arregla el CVE.

Comprueba que la deuda se pagó de verdad:

```bash
grep -rn "dgrijalva" . ; go list -m all | grep jwt
```

El primero no debe devolver nada, y el segundo solo `golang-jwt`.

### 5.8 La excepción: el único archivo del frontend

Ha llegado el momento de ejecutar `D27` / `C-06`. **Un archivo. Solo este.**

```javascript
// src/api/authService.js
import apiClient from './apiClient';

/**
 * Login contra el backend real (be04). Antes esto filtraba /users por query
 * string con la password a la vista; ahora las credenciales viajan en el
 * cuerpo de un POST y el token que vuelve es un JWT firmado que expira.
 *
 * Lo que NO cambió, y es el punto de toda la fase: la forma que este módulo
 * devuelve al resto de la app. authSlice, apiClient, sus dos interceptores y
 * los componentes siguen exactamente igual, porque siguen recibiendo
 * { id, email, name, token }.
 * @param {{ email: string, password: string }} credentials
 * @returns {Promise<{ id: number, email: string, name: string, token: string }>}
 */
export async function login({ email, password }) {
  try {
    const { data } = await apiClient.post('/login', { email, password });
    return data;
  } catch (error) {
    // El backend responde 401 con { message }. Se traduce al mismo error
    // legible que este módulo tiraba antes, para que LoginForm no cambie.
    if (error.response?.status === 401) {
      throw new Error('Email o contraseña incorrectos');
    }
    throw error;
  }
}

export default { login };
```

Y ahora la verificación que demuestra que la excepción se respetó:

```bash
# Debe listar UN archivo y solo uno.
git diff --name-only pre-backend-go..HEAD -- . ':!server'

# Y este comando —el que usan todas las fases desde acá— debe salir vacío:
git diff pre-backend-go..HEAD -- . ':!server' ':!src/api/authService.js'
```

### 5.9 El contrato cambió: actualízalo

`be00` fue tajante: el contrato es lo que se observa. Acabas de cambiar lo que se
observa, así que el contrato y su checklist se actualizan **en esta fase**, no
"cuando haya tiempo".

En `server/CONTRACT.md`: `GET /users?email=…&password=…` sale del régimen
estricto, con una nota de que se retiró en `be04` por la excepción `D27`, y entra
`POST /login` con su cuerpo, su respuesta y su `401`.

En `server/smoke.sh`, las verificaciones 1 y 2:

```bash
# 1. Login correcto: 200 con el token firmado.
LOGIN=$(curl -s -X POST "$BASE/login" -H 'Content-Type: application/json' \
        -d '{"email":"organizador@rifas.test","password":"rifas123"}')
check "POST /login válido devuelve token" \
      "true" "$(echo "$LOGIN" | jq 'has("token")')"
# Un JWT tiene tres partes separadas por puntos. Si esto falla, alguien
# devolvió una constante otra vez.
check "el token es un JWT (tres partes)" \
      "3" "$(echo "$LOGIN" | jq -r '.token' | tr '.' '\n' | wc -l | tr -d ' ')"

# 2. Credenciales inválidas: 401, y NO 200 con array vacío.
check "credenciales inválidas devuelven 401" "401" \
      "$(curl -s -o /dev/null -w '%{http_code}' -X POST "$BASE/login" \
         -H 'Content-Type: application/json' \
         -d '{"email":"nadie@rifas.test","password":"x"}')"
```

---

## ⚠️ 6. Errores comunes y pieza forense

### Errores comunes

**1. No comprobar el método de firma.** Síntoma: ninguno, hasta que alguien entra
con un token que se fabricó solo. Causa: la función de verificación devuelve la
clave sin mirar `t.Method`. Fix: las tres líneas de 5.3. Es **la** vulnerabilidad
clásica de JWT y sigue apareciendo en auditorías todos los años.

**2. Distinguir "usuario no existe" de "contraseña incorrecta".** Síntoma:
ninguno visible; el sistema parece más amable. Causa: dos ramas de error
distintas en el login. Por qué importa: le regala a un atacante un enumerador de
cuentas válidas, y con eso el ataque siguiente es dirigido. Fix: un solo error
para los dos casos, y el mismo tiempo de respuesta.

**3. El secreto en el código.** Síntoma: funciona perfecto. Causa: `JWT_SECRET`
con un valor por defecto en el struct de configuración, "para que sea fácil
levantarlo". Fix: `required:"true"` y que el proceso no arranque sin él. Un
secreto con valor por defecto es un secreto público — está en el repositorio, en
la imagen y en el historial de git.

**4. Cambiar el nombre del campo `token`.** Síntoma: el login "funciona" —el
`POST` devuelve `200`— y todas las peticiones siguientes dan `401`. Causa:
alguien lo llamó `accessToken`, que es mejor nombre. Fix: volver a `token`. El
contrato manda: `authSlice` lee `token` y el interceptor lee del store.

**5. Verificar el token en el handler y no en el middleware.** Síntoma: funciona
en las cinco rutas que revisaste y falla —abierta— en la sexta. Causa: la
verificación como responsabilidad de cada handler. Fix: middleware sobre el
subrouter. La regla operativa: **una ruta protegida tiene que estar protegida por
dónde está montada, no por lo que recuerde su autor**.

**6. Olvidar el `exp`.** Síntoma: ninguno, durante años. Causa: no poner
`ExpiresAt`. Un token sin expiración es una llave maestra permanente: quien lo
copie de un log, de una captura o del `localStorage` de un equipo prestado entra
para siempre.

### 🩻 Pieza forense de esta fase

**Un token manipulado, y el ataque que casi funciona.**

*Paso 1 — mira lo que estás mandando.* Loguéate en la aplicación, copia el token
del store (Redux DevTools) o del header `Authorization` en Network, y pégalo en
https://jwt.io. Lee el `payload` **sin ninguna clave**: ahí está el `sub`, el
`exp`, el `email`. Anota la conclusión con tus palabras: *un JWT no es secreto,
es verificable*. Si en algún proyecto tuyo hay datos personales en un token, hoy
es un buen día para revisarlo.

*Paso 2 — modifícalo.* En jwt.io, cambia el `sub` a otro id y copia el token
resultante:

```bash
curl -i localhost:3001/raffles -H "Authorization: Bearer <token-manipulado>"
```

`401`. La firma no cuadra porque no tienes el secreto. Anota el mensaje del log
del servidor y compáralo con el que ve el cliente: **el servidor sabe qué pasó y
el cliente no se entera**. Esa asimetría es deliberada y es buen diseño de
seguridad; `bea-08` la trata a fondo.

*Paso 3 — el ataque `alg: none`.* Fabrica un token sin firma:

```bash
# Cabecera {"alg":"none","typ":"JWT"} y payload con el sub que quieras,
# en Base64URL, y la tercera parte VACÍA (el punto final va igual).
HEADER=$(printf '{"alg":"none","typ":"JWT"}' | base64 | tr '+/' '-_' | tr -d '=')
PAYLOAD=$(printf '{"sub":"1","exp":9999999999}' | base64 | tr '+/' '-_' | tr -d '=')
curl -i localhost:3001/raffles -H "Authorization: Bearer $HEADER.$PAYLOAD."
```

Con tu código, `401`: la comprobación de `t.Method` lo rechaza antes de mirar
nada más.

*Paso 4 — ahora quita la defensa.* Comenta las tres líneas del `if _, ok :=
t.Method.(*jwt.SigningMethodHMAC)` y repite el paso 3.

Anota lo que pasa. Anótalo con cuidado, porque es el momento de la fase: **el
comportamiento exacto depende de la versión de la librería** —las modernas se
niegan a aceptar `none` aunque tú no lo compruebes— y esa dependencia es
precisamente la lección. Si tu defensa consiste en que la librería se porte bien,
tu defensa es la política de mantenimiento de un tercero. Que es, exactamente,
por lo que acabas de migrar de librería.

*Paso 5 — el token vencido.* Baja `JWT_TTL` a un minuto, loguéate, espera, y usa
la aplicación. El `401` llega, el interceptor de la Fase 2 hace logout global, y
el usuario aterriza en el login sin explicación. **Ese es el aspecto exacto de la
deuda 💸 del refresh token.** Escríbelo tal cual en el mapa de deuda: no como
"falta implementar refresh", sino como "al vencer el token, el usuario pierde lo
que estuviera haciendo".

*Paso 6 — el círculo, con identidad.* Haz una venta y sigue el `X-Request-Id`
desde la consola del navegador hasta el log del backend. Ahora esa línea tiene
también el `userID`, sacado del token y no del cuerpo. Compárala con la de
`be03`: la diferencia entre las dos líneas es toda la fase.

---

> 📓🔥 De esta fase sale el incidente **be-08** de `cuaderno-incidentes-be.md`, hermano del **08** del track base. Mismo síntoma —te saca de la sesión sin avisar— y otra causa: allá el `401` es del caos y aparece repartido al azar; acá es un `exp` real y por eso tiene **patrón horario**.

---

## 🧪 7. Ejercicios (32)

**🟢 Fácil (1–8)**

1. Aplica la migración `000004` y comprueba en `psql` que `users.token` ya no existe y que la columna se llama `password_hash`.
2. Siembra dos veces y verifica que los hashes de la misma contraseña son distintos. Explica por qué en una línea.
3. Haz `POST /login` con `curl` y comprueba que el token tiene tres partes.
4. Pega el token en jwt.io y anota qué campos son legibles sin clave.
5. Comprueba que `POST /login` con contraseña incorrecta devuelve `401` con `{"message":…}`.
6. Verifica que `GET /raffles` sin `Authorization` devuelve `401`.
7. Arranca el binario sin `JWT_SECRET` y comprueba que no arranca.
8. Ejecuta el `git diff` de 5.8 y confirma que solo aparece `authService.js`.

**🟡 Intermedio (9–19)**

9. Haz el recorrido completo en la aplicación con el backend nuevo y confirma que el login funciona igual que antes desde la interfaz.
10. **Diagnóstico.** Renombra el campo `token` a `accessToken` en la respuesta y describe con precisión en qué punto falla la aplicación y por qué el login parece haber funcionado.
11. Implementa la tabla de transiciones y comprueba con `curl` que un `PUT` de `draft` a `settled` devuelve `409`.
12. **Diagnóstico.** Manda un `PUT /raffles/1` con un campo `ownerId` inventado. Demuestra que el backend lo ignora y encuentra dónde se descarta.
13. Comprueba que un `PUT` que no cambia el estado sigue funcionando, y explica por qué esa excepción de `canTransition` es necesaria para el CRUD de la Fase 4.
14. **Diagnóstico.** Provoca el paso 2 de la pieza forense (token manipulado) y correlaciona el `401` que ve el navegador con la línea del log del servidor por su `X-Request-Id`.
15. Baja `JWT_TTL` a 60 segundos y documenta la experiencia de usuario completa cuando vence a mitad de una venta.
16. Agrega el `userID` a la línea de log de cada petición autenticada y verifica que sale del token.
17. **Diagnóstico.** Comprueba en el navegador qué hace el interceptor de respuesta de la Fase 2 con el `401` de un login fallido. ¿Dispara el logout global? Si lo hace, ¿se nota? Documenta el resultado: es la clase de interacción que solo aparece midiendo.
18. Actualiza `CONTRACT.md` y `smoke.sh` con el nuevo login y déjalo pasando entero.
19. **Diagnóstico.** Intenta hacer login con una contraseña de 100 caracteres. Determina qué pasa y en qué capa.

**🟠 Difícil (20–27)**

20. **Diagnóstico.** Ejecuta los pasos 3 y 4 de la pieza forense y escribe el informe del `alg: none`, incluida la conclusión sobre depender de la librería para defenderte.
21. Escribe la prueba de Go que falla si alguien quita la comprobación de `t.Method`. Esa prueba es más importante que la comprobación misma: argumenta por qué.
22. **Diagnóstico.** Antes de migrar, evalúa por escrito si `CVE-2020-26160` afecta a **este** backend. Lee el aviso, mira si usamos `aud`, y llega a una conclusión razonada. Después migra igual y explica por qué la conclusión no cambia la decisión.
23. Ejecuta la migración a `golang-jwt/jwt/v4` en un commit propio y deja el `go.mod` limpio. Verifica con `grep` y con `go list -m all`.
24. **Diagnóstico.** Rompe la migración a propósito: migra el import pero deja `StandardClaims`. Lee el error del compilador y explica qué te está diciendo el diseño de v4.
25. Escribe la prueba que verifica que un token firmado con **otro** secreto se rechaza, y otra que verifica que uno vencido se rechaza. Explica por qué son dos pruebas y no una.
26. **Diagnóstico.** Enforcing de auth sobre `/raffles`: demuestra con el recorrido completo que ninguna pantalla pide datos antes del login. Si encuentras una, documéntala como hallazgo de contrato con su código `C-NN`.
27. Diseña el registro de auditoría que dejaría rastro de quién cambió el estado de cada rifa. Decide si va en una tabla, en el log, o en las dos, y justifica con lo que `be07` va a necesitar para su trazabilidad inmutable.

**🔴 Muy difícil (28–32)**

28. **Post-mortem.** Escribe `server/postmortem-jwt.md` según la guía §13: síntoma (una dependencia central archivada con un aviso sin parche), evidencia (el aviso, las fechas, la versión afectada), causa raíz, corrección, prueba de regresión y prevención. **Sin culpabilización**: adoptar `dgrijalva/jwt-go` en 2020 era la decisión correcta con la información de 2020. La prevención tiene que ser un mecanismo verificable, no "estar más atentos".
29. Diseña e implementa ese mecanismo: algo que avise cuando una dependencia del `go.mod` quede archivada o adquiera un aviso. Puede ser tosco (`govulncheck` en CI, un script contra la API de avisos). `be09` lo va a querer en el pipeline.
30. Argumenta por escrito si el token debería guardarse en `localStorage` —donde está hoy— o en una cookie `HttpOnly`. Defiende las dos posturas con XSS y CSRF sobre la mesa, y después responde la pregunta que de verdad importa acá: **¿podrías cambiarlo sin tocar el frontend?** Deja la conclusión en el mapa de deuda.
31. Diseña la implementación completa de *refresh tokens* para este sistema: endpoints, almacenamiento, rotación, revocación. Enumera **exactamente** qué archivos del frontend habría que tocar y calcula si eso cabe dentro de la excepción `D27`. Concluye si se haría, y con qué plan.
32. **Diagnóstico + regresión.** Ticket: *"algunos usuarios dicen que los saca de la sesión al mediodía, todos los días, y otros nunca"*. Con lo que sabes de `exp` y de la ausencia de refresh, reconstruye la causa, di cómo la confirmarías con los logs que tienes, y escribe la prueba de regresión y la comunicación al usuario.

**🔥 Opcionales**

- 🔥 Sustituye HS256 por RS256 (par de claves) y explica qué gana el sistema: quién puede firmar, quién puede verificar, y por qué eso importa el día que haya un segundo servicio.
- 🔥 Implementa una lista de revocación en memoria para invalidar un token antes de su `exp`, y después argumenta qué acabas de perder — pista: era la propiedad que hacía atractivo el JWT.
- 🔥 Ejecuta `govulncheck` sobre el módulo antes y después de la migración, y guarda las dos salidas.

---

## 📚 8. Referencias

**Documentación oficial y avisos**
- https://github.com/advisories/GHSA-w73w-5m7g-f7qc — el aviso de GitHub. **Ábrelo y léelo**: es material de la fase, no una nota al pie.
- https://nvd.nist.gov/vuln/detail/CVE-2020-26160 — la entrada en la NVD, con el vector CVSS desglosado.
- https://github.com/golang-jwt/jwt — el fork, con su guía de migración desde `dgrijalva`.
- https://pkg.go.dev/golang.org/x/crypto/bcrypt — la API, `DefaultCost` y `ErrPasswordTooLong`.
- https://www.rfc-editor.org/rfc/rfc7519 — JWT. Para hoy: §4.1 (claims registrados).
- https://www.rfc-editor.org/rfc/rfc8725 — *JSON Web Token Best Current Practices*. El documento más útil de esta lista: el §3.1 es el `alg: none` explicado por quienes escribieron el estándar.
- https://cheatsheetseries.owasp.org/cheatsheets/Password_Storage_Cheat_Sheet.html — almacenamiento de contraseñas, con recomendaciones de costo actualizadas.
- https://jwt.io — el depurador de la pieza forense. Pega **tokens de laboratorio**, nunca uno de producción: es una página web y el token es una credencial.

**Libros**
- *Web Application Security* (Andrew Hoffman) — los capítulos de autenticación y de ataques sobre tokens.
- *Security Engineering* (Ross Anderson) — el capítulo sobre contraseñas, para entender por qué `bcrypt` es lento a propósito. La tercera edición está disponible en el sitio del autor.

**Video / apoyo**
- Busca "JWT alg none attack" y "bcrypt vs sha256 password" en YouTube. Hay charlas cortas y buenas; verifica que la demostración corresponda a una librería actual, porque muchas usan implementaciones ya corregidas.

**Orden de lectura sugerido:** el aviso `GHSA-w73w-5m7g-f7qc` primero, entero,
antes de escribir código —así la migración de 5.7 llega con contexto— → RFC 8725
§3, que son tres páginas y cubren todos los errores comunes de esta fase →
`bea-04` para la anatomía completa del token → `bea-08` cuando quieras el resto
del panorama de seguridad de la API.

> ⚠️ URLs, títulos, severidades y fechas pueden haber cambiado: **verifícalos**.
> Los datos del CVE de esta fase se confirmaron contra el aviso oficial al
> escribirla, y aun así el procedimiento correcto es abrirlo. Las referencias a
> libros son de memoria y pueden ser inexactas. Cualquier discrepancia de
> versiones la resuelve `prompts/decisiones-y-versiones.md` §7.

---

## 🚀 9. Cierre y conexión con la siguiente fase

Cuatro deudas pagadas. Las contraseñas son hashes con sal, el token es un JWT
firmado que expira, la identidad sale del token y no del cuerpo, y las
transiciones de estado las custodia el servicio. La columna de la vergüenza que
`be03` creó ya no existe, y el `go.mod` pasó por una librería abandonada y salió
del otro lado con un post-mortem escrito.

El frontend, mientras tanto, cambió **un archivo**: el que la Fase 2 había
señalado con el dedo dos años antes.

Queda una deuda declarada y viva: sin *refresh token*, un token vencido tira al
usuario al login. Está en el mapa de deuda con su motivo, y `be09` la va a
recoger en el veredicto honesto del track.

`be05` es la primera de las dos fases ⭐ y va al corazón del curso. Ya sabes quién
vende; falta que **dos personas no puedan vender el mismo número**. El `if` de
`SellNumber` sigue exactamente igual de indefenso que en el mock, y esta vez no
se traduce de lenguaje: se resuelve donde se resuelve, con un índice único, una
transacción y `SELECT … FOR UPDATE`. Vas a ver dos clientes peleando por el
número `0347` desde la línea de comandos y la transacción bloqueada en
`pg_stat_activity` — el bloqueo, en pantalla, no imaginado.

> **La señal de que quedó bien:** *"el backend ya no le cree nada al navegador
> sobre quién es, y el frontend no se dio cuenta del cambio."*

> 🏷️ **No cierres la fase sin el tag.** Con el checklist de la sección 2 en
> verde y `git status` limpio:
>
> ```bash
> git tag -a fase-be04-identidad-real-jwt-y-un-cve -m "be04 cerrada: \
> migración 000004 con password_hash y sin columna token; siembra que hashea con bcrypt; \
> POST /login firmando JWT en el mismo campo token; middleware de verificación; \
> identidad desde req.Context(); transiciones custodiadas en el service; \
> dgrijalva/jwt-go adoptado y migrado a golang-jwt/jwt v4 con post-mortem; \
> excepción D27 ejecutada en un solo archivo; CONTRACT.md y smoke.sh actualizados"
> ```
>
> Los commits de la fase llevan su prefijo (`be04: …`) y los de ejercicio su
> número (`be04 ej28: …`). La adopción y la migración de la librería van en **dos
> commits distintos** —`be04: adopta dgrijalva/jwt-go v3.2.0` y
> `be04: migra a golang-jwt/jwt v4 (CVE-2020-26160)`—: el `git log` de esta fase
> tiene que contar la historia solo. Si un ejercicio merece su propio marcador va
> en `ej/be04/28`, y un incidente resuelto en el par `inc/<ID>/<slug>-roto` /
> `-fix`, con el ID que le reserva `cuaderno-incidentes.md`. Todo eso está en
> [`00-convencion-de-git-y-tags.md`](00-convencion-de-git-y-tags.md).

---

## 📌 Pendientes sugeridos

*(Fuera de lo que lee el estudiante.)*

- **El comando de verificación cambia a partir de acá.** Todas las fases `be05` a
  `be09` deben usar
  `git diff pre-backend-go..HEAD -- . ':!server' ':!src/api/authService.js'` en su
  checklist de la sección 2. Está en `D27`; que ninguna lo olvide.
- **`CONTRACT.md` y `smoke.sh` cambiaron en esta fase.** Es la primera vez que el
  contrato se modifica desde `be00`, y sienta el precedente: cuando una fase
  cambia lo observable, actualiza los dos documentos **en la misma fase**. `be08`
  debería verificarlo automáticamente.
- **El CVE hay que reverificarlo al publicar o revisar el curso.** Los datos se
  confirmaron contra `GHSA-w73w-5m7g-f7qc` al escribir la fase (CVE-2020-26160,
  CVSS 7.5, publicado 2020-09-30, afecta ≤ v3.2.0, sin parche, migrar a
  `golang-jwt` ≥ 3.2.1). Las severidades se recalculan; el texto ya advierte al
  alumno que verifique, pero la revisión editorial debería rehacerlo.
- **Deuda 💸 viva declarada: sin *refresh token*.** Tiene que aparecer en
  `bea-09` (mapa de deuda del track BE) y en el veredicto honesto de `be09`. Es
  la deuda que el track decide **no** pagar, y decir por qué es más valioso que
  pagarla.
- **Deudas menores declaradas:** 💸 no hay `owner_id` ni autorización a nivel de
  objeto (solo se registra en el log; `bea-08`); 💸 sin límite de intentos de
  login (`bea-08`); 💸 el token vive en `localStorage` y cambiarlo requeriría
  tocar el frontend (ejercicio 30, y va al mapa de deuda).
- **`be05` empieza con el `if` de `SellNumber` intacto.** Esta fase no lo tocó a
  propósito. Que `be05` abra reproduciendo la carrera con el código que el alumno
  ya tiene.
- **`be06` hereda las transiciones.** Hoy se custodian por *orden*; cuando el
  reloj sea autoridad del servidor, `open → closed` va a poder dispararse también
  por tiempo y no solo por petición. Que `be06` lo recoja explícitamente.
- **`be07` hereda el ejercicio 27** (registro de auditoría) como insumo directo de
  su trazabilidad como registro inmutable.
- **Reserva para el cuaderno de incidentes:** `be-08` — *"a algunos usuarios los
  saca de la sesión al mediodía y a otros nunca"* (categoría 🔥 autenticación,
  dificultad 🟡), que es el ejercicio 32 llegado como ticket vago. **Con esto se
  agota el rango `be-01`–`be-08`** que reservó `cuaderno-incidentes.md`: las
  fases `be05` a `be09` van a necesitar ampliarlo, y conviene decidir el rango
  nuevo antes de escribir `be05`.
