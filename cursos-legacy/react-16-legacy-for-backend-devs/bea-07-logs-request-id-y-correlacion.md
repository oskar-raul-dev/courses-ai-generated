# 🧵 Apéndice bea-07 — Logs, `request-id` y correlación

> Tutorial React 16 — Rifas y chances · **Track BE opcional 🔥** · Consulta rápida · ~2 horas
> Lo referencian: `be01` y todas las fases posteriores

---

Este apéndice cierra un bucle que el track base abrió y no pudo terminar.

En la **Fase 2**, el interceptor de respuesta de `apiClient` lee el
`X-Request-Id` que devuelve el mock y lo imprime en la consola. En el mock, ese
id **nace y muere en un middleware de tres líneas**: no hay nada al otro lado con
qué correlacionarlo. El apéndice `A13` enseña a usarlo para distinguir UAT de
producción, y aun así el id sigue siendo medio hilo colgando.

Acá se ata el otro extremo. El mismo id cruza el backend entero —handler,
servicio, store, consulta SQL— y la correlación deja de ser un ejercicio para
volverse una herramienta:

> 🧭 **El recorrido completo que el track promete:** copiar un id de la consola
> del navegador y encontrarlo en el log del servidor, con la consulta que ejecutó,
> cuánto tardó y qué usuario la pidió.

---

## 🧭 Índice de salto rápido

1. [El id: generarlo o respetarlo](#1-el-id-generarlo-o-respetarlo)
2. [Propagación por `context.Context`](#2-propagación-por-contextcontext)
3. [Log estructurado con Go 1.19 (sin `slog`)](#3-log-estructurado-con-go-119-sin-slog)
4. [Qué se loguea y qué NUNCA se loguea](#4-qué-se-loguea-y-qué-nunca-se-loguea)
5. [Niveles y ruido](#5-niveles-y-ruido)
6. [El recorrido completo, paso a paso](#6-el-recorrido-completo-paso-a-paso)
7. [🧩 Cuándo usar qué: logs contra DevTools](#-cuándo-usar-qué-logs-contra-devtools)

---

## 1. El id: generarlo o respetarlo

```go
const requestIDHeader = "X-Request-Id"

func requestIDMiddleware(next http.Handler) http.Handler {
	return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		// Si viene del cliente, se RESPETA. Un proxy, una prueba o un
		// servicio que ya lo generó tienen derecho a fijarlo, y así el id
		// cruza varios saltos siendo el mismo.
		id := r.Header.Get(requestIDHeader)
		if id == "" {
			id = newRequestID()
		}
		w.Header().Set(requestIDHeader, id)
		ctx := context.WithValue(r.Context(), requestIDKey, id)
		next.ServeHTTP(w, r.WithContext(ctx))
	})
}

// 16 caracteres hex de crypto/rand. NO hace falta una dependencia de UUID:
// el id solo tiene que ser único dentro de una ventana de logs.
func newRequestID() string {
	b := make([]byte, 8)
	if _, err := rand.Read(b); err != nil {
		return "ts-" + time.Now().UTC().Format("150405.000000")
	}
	return hex.EncodeToString(b)
}
```

**Tres decisiones y su porqué:**

- **Respetar el que venga.** Es lo que permite que el id sobreviva a un proxy o
  que una prueba lo fije para buscarlo después.
- **Ponerlo primero en la cadena.** Todo lo que venga después —incluido el log de
  un pánico— lo necesita para ser útil (`be01` §4).
- **Devolverlo en la respuesta.** Y —esto es el hallazgo `C-05` de `be00`—
  **exponerlo a CORS**, o el navegador lo recibe y no deja que JavaScript lo lea:

```go
w.Header().Set("Access-Control-Expose-Headers", requestIDHeader)
```

> ⚠️ Sin esa línea, el header **se ve perfectamente en la pestaña Network** y
> `response.headers['x-request-id']` vale `undefined`. Es el bug más silencioso
> del track base y la deuda que `be01` paga con una línea. Si alguna vez la
> trazabilidad "a veces no funciona", empieza por acá.

---

## 2. Propagación por `context.Context`

El id viaja en el contexto, no en las firmas. Cualquier función del backend lo
recupera sin recibirlo como parámetro suelto:

```go
type ctxKey int
const requestIDKey ctxKey = iota   // tipo propio: nadie fuera del paquete puede
                                   // construir esta clave → colisión imposible

func RequestIDFrom(ctx context.Context) string {
	if id, ok := ctx.Value(requestIDKey).(string); ok { return id }
	return ""
}
```

Y por eso `context.Context` es el **primer parámetro** de todo lo que cruza una
frontera —handler, service, store—: es el vehículo. La misma vía transporta la
identidad del usuario desde `be04`, y por la misma razón.

> 🧭 **La regla de los valores en el contexto:** solo para datos de alcance de
> petición que atraviesan capas **sin ser parte de la lógica**. El request id, la
> identidad. Nunca parámetros de negocio disfrazados.

---

## 3. Log estructurado con Go 1.19 (sin `slog`)

`log/slog` es de Go 1.21 y este código es de 2022 (`D14`). Con la biblioteca
estándar de 1.19 hay dos caminos y los dos son legítimos:

### Texto legible — lo que usa el track

```go
log.Printf("[req-id %s] %s %s → %d (%d bytes) en %s",
	RequestIDFrom(r.Context()), r.Method, r.URL.RequestURI(),
	rec.status, rec.bytes, time.Since(start).Round(time.Microsecond))
```

```
2026/09/08 14:22:31 [req-id 9f3a1c7d2e5b] POST /raffles/1/numbers/0347/sell → 409 (46 bytes) en 12.418ms
```

**El id va delante y entre corchetes**, y eso no es estética: es lo que lo hace
grepeable sin comerse líneas vecinas.

```bash
grep '9f3a1c7d2e5b' server.log
docker compose logs api | grep '9f3a1c7d2e5b'
```

### JSON — cuando los logs los lee una máquina

```go
// Un logger estructurado en 25 líneas, sin dependencias. Es lo que hacía
// medio ecosistema Go antes de slog.
type entry struct {
	Time      string `json:"time"`
	Level     string `json:"level"`
	Msg       string `json:"msg"`
	RequestID string `json:"requestId,omitempty"`
	UserID    int64  `json:"userId,omitempty"`
	Method    string `json:"method,omitempty"`
	Path      string `json:"path,omitempty"`
	Status    int    `json:"status,omitempty"`
	DurMS     int64  `json:"durationMs,omitempty"`
	Err       string `json:"error,omitempty"`
}

func logJSON(e entry) {
	e.Time = time.Now().UTC().Format(time.RFC3339Nano)
	b, _ := json.Marshal(e)
	// Una línea por evento y nada más: es lo que exige cualquier colector.
	os.Stdout.Write(append(b, '\n'))
}
```

**La comparación honesta:**

| | Texto | JSON |
|---|---|---|
| Leerlo en una terminal | ✅ Directo | ❌ Ilegible sin `jq` |
| `grep` por un id | ✅ | ✅ |
| Filtrar por status ≥ 500 | ❌ Con expresiones frágiles | ✅ `jq 'select(.status>=500)'` |
| Agregar y graficar | ❌ | ✅ |
| Tamaño por línea | Menor | ~40 % más |

> 🧭 **Cuándo cambia la respuesta.** Texto mientras el log lo lea una persona en
> una terminal —que es todo este curso—. JSON en cuanto lo lea una máquina: un
> colector, un buscador, un panel. El track se queda en texto porque es coherente
> con la época (`D14`) y porque una línea legible enseña mejor. 💸 Está declarado
> como deuda y esta sección es su pago sobre el papel.

Y una regla operativa que vale para los dos formatos:

📖 **Escribe a `stdout`, no a un archivo.** El proceso no debe saber dónde
terminan sus logs: eso lo decide quien lo ejecuta. `docker compose logs`, el
runner de CI y cualquier orquestador esperan `stdout`. Un backend que abre un
archivo de log se pelea con la rotación, con los permisos y con el contenedor.

---

## 4. Qué se loguea y qué NUNCA se loguea

### Nunca, sin excepciones

| Nunca | Por qué |
|---|---|
| El header `Authorization` completo | **Es la credencial.** Quien lea el log entra como ese usuario |
| Un JWT, entero o en trozos | Igual: el token *es* el acceso |
| Contraseñas, ni siquiera al fallar | Ni en el error de login, ni "temporalmente para depurar" |
| El hash de `bcrypt` | Es material para atacar sin límite de intentos |
| `JWT_SECRET` o el `DATABASE_URL` completo | Trae la contraseña de la base |
| El cuerpo completo de una petición | Hoy no trae nada sensible; mañana sí, y nadie va a revisar el logger |
| Datos personales de participantes | Nombre, documento, teléfono |

> ⚠️ **La trampa del volcado cómodo.** Un `log.Printf("%+v", req)` parece
> inofensivo y es la forma más habitual de filtrar un token: el struct incluye
> los headers. Loguea **campos elegidos**, nunca estructuras enteras.
>
> Y recuerda que los logs viajan: se agregan a tickets, se pegan en chats, se
> mandan por correo a soporte. **Un secreto en un log es un secreto publicado.**

### Sí, y siempre

- El `request-id`, en **todas** las líneas.
- Método, ruta y código de estado.
- La duración.
- El id del usuario (`be04`) — un número, no su email.
- El resultado de la operación de negocio: qué error de dominio se devolvió.
- Los eventos que solo el servidor conoce: el desfase de reloj de `be06`, la
  discrepancia de montos de `be07`, el cambio de nivel de caos, el cierre de una
  rifa por reloj.

**Si tienes que registrar un token para diagnosticar**, registra su huella, nunca
el token:

```go
sum := sha256.Sum256([]byte(token))
log.Printf("[req-id %s] token rechazado (huella %x)", id, sum[:6])
```

Sirve para saber si dos peticiones usaron el mismo token, que suele ser lo que
necesitas, y no sirve para entrar.

---

## 5. Niveles y ruido

Sin `slog` no hay niveles nativos. Lo mínimo que hace falta y lo que significa
cada uno:

| Nivel | Cuándo | Ejemplo del track |
|---|---|---|
| `DEBUG` | Detrás de una variable | Cada consulta SQL con su tiempo (`SQL_DEBUG`) |
| `INFO` | Un evento por petición | La línea de acceso; el cierre de una rifa |
| `WARN` | Algo raro que no rompió | Desfase de reloj (`be06`), discrepancia de montos (`be07`) |
| `ERROR` | Falló y alguien debería mirar | Pánico recuperado, la base no responde |

> 🧭 **El criterio que evita el ruido: un log de `ERROR` es una petición de
> atención humana.** Si nadie va a hacer nada al verlo, no es `ERROR`.
>
> Un `401` por token vencido es rutina: `INFO`. Un `409` por venta duplicada es el
> sistema funcionando: `INFO`. Un pánico recuperado es `ERROR`, siempre. Confundir
> esto produce el peor de los resultados: un log lleno de errores que nadie mira,
> y entre ellos el que sí importaba.

**El SQL solo detrás de una variable.** `SQL_DEBUG=true` en desarrollo y QA,
`false` en UAT y producción (`be09` §4.3). Registrar cada consulta en producción
multiplica el volumen y —peor— es la forma más fácil de que un valor de negocio
acabe en un log sin que nadie lo decidiera.

---

## 6. El recorrido completo, paso a paso

Esto es lo que el track viene construyendo desde `be00`, fase por fase. Hazlo
entero una vez:

**1. En el navegador.** Vende un número y mira la consola. El interceptor de la
Fase 2 imprimió:

```
[req-id 9f3a1c7d2e5b] POST /raffles/1/numbers/0347/sell → 409
```

Si **no** aparece pero el header sí está en Network, te falta
`Access-Control-Expose-Headers` (§1). Ese es el hallazgo `C-05`.

**2. En el log del servidor.** Con el id:

```bash
docker compose logs api | grep 9f3a1c7d2e5b
```

```
[req-id 9f3a1c7d2e5b] POST /raffles/1/numbers/0347/sell → 409 (46 bytes) en 12.418ms
[req-id 9f3a1c7d2e5b] usuario 2 intentó vender 0347: ese número ya fue vendido
```

**3. En la consulta SQL.** Con `SQL_DEBUG=1`:

```
[req-id 9f3a1c7d2e5b] SQL SELECT … FROM raffle_numbers WHERE raffle_id=$1 AND number=$2 FOR UPDATE → 8.1ms
[req-id 9f3a1c7d2e5b] SQL INSERT INTO sales … → error 23505 en 1.9ms
```

**4. Y en la base, si hace falta.** Con la venta ya registrada, el `sold_by` y el
`sold_at` de `sales` dicen quién ganó la carrera que este id perdió.

> 🧠 **Eso es el círculo cerrado.** En `be00` el id no llegaba a ninguna parte. En
> `be01` llegó al log. En `be02` a la consulta. En `be04` trajo la identidad. En
> `be05` explicó una carrera perdida. En `be08` recorre el sistema **dentro de una
> prueba automatizada**, que es la forma final de la trazabilidad: no un ejercicio
> de diagnóstico, sino una propiedad verificada.

**Un truco que vale la pena conocer:** puedes **fijar** el id desde el cliente
(§1). En un guion de diagnóstico, eso te deja buscar exactamente lo que acabas de
hacer:

```bash
curl -H 'X-Request-Id: diagnostico-oskar-01' localhost:3001/raffles
docker compose logs api | grep diagnostico-oskar-01
```

---

## 🧩 Cuándo usar qué: logs contra DevTools

Las dos orillas responden preguntas distintas, y la mitad del tiempo perdido
diagnosticando es haber elegido la herramienta equivocada.

| La pregunta es… | Herramienta |
|---|---|
| ¿Qué pidió el navegador y qué recibió? | **Network** |
| ¿Por qué el componente pinta eso? | **React / Redux DevTools** |
| ¿Salió la petición siquiera? | **Network** — si no está ahí, el bug es del cliente |
| ¿Por qué el servidor decidió eso? | **Log del backend** |
| ¿Cuánto tardó, y en qué parte? | **Log**, con la duración de la consulta |
| ¿Se llegó a escribir en la base? | **Log** + `psql` |
| ¿Quién pidió esto? | **Log**, con el `userId` del token |
| ¿Pasó más de una vez? | **Log**, agrupando por ruta |
| ¿Está pasando **ahora**? | `pg_stat_activity` (`bea-05` §8) |

> 🧭 **La regla que ordena el diagnóstico.** Empieza en Network: te dice si el
> problema está **antes o después** del cable. Si la petición salió y volvió con
> lo que volvió, el frontend hizo su trabajo y el resto de la investigación es del
> otro lado. Ese único corte ahorra más tiempo que cualquier herramienta.
>
> Y el `X-Request-Id` es lo que hace posible cruzar el corte sin perder el hilo.
> Sin él, correlacionar es adivinar por marcas de tiempo — que es lo que hacía el
> track base, y por eso `A13` cuesta lo que cuesta.

**Lo que este backend no tiene, y hay que decirlo:** no hay trazas distribuidas,
ni métricas agregadas, ni alertas. Con un monolito y un `request-id` bien
propagado, un log de texto llega sorprendentemente lejos. Con diez servicios, no
— ahí empieza otra conversación (OpenTelemetry, y el `request-id` pasa a ser un
`trace-id` con contexto de propagación estándar), y queda fuera del track.

---

## 🧪 Ejercicios (7)

1. **🟢** Haz una petición fijando tú el `X-Request-Id` y encuéntrala en el log con `grep`.
2. **🟢** Comprueba en el navegador que el id de la consola y el de Network coinciden. Si no aparece en la consola, encuentra por qué (§1).
3. **🟡** Activa `SQL_DEBUG` y sigue un id desde la consola del navegador hasta la consulta SQL con su tiempo. Es el §6 completo.
4. **🟡 Diagnóstico.** Quita `Access-Control-Expose-Headers` y documenta con dos capturas que el header se ve en Network y no se puede leer desde JavaScript.
5. **🟠** Sustituye el logger de texto por el JSON del §3, y filtra con `jq` todas las peticiones que devolvieron 5xx. Mide cuánto crece cada línea.
6. **🟠 Diagnóstico.** Escribe a propósito un `log.Printf("%+v", r)` con la petición entera, haz una llamada autenticada, y encuentra el token en el log. Después arréglalo y explica la regla del §4.
7. **🔴** Instrumenta el store para que registre cada consulta con su id, su duración y su resultado, detrás de `SQL_DEBUG`. Después usa esa instrumentación para encontrar la consulta más lenta de la suite de `be08` y explica por qué lo es.

---

## 📚 Referencias

**Documentación oficial**
- https://pkg.go.dev/log — lo que hay en Go 1.19. Corto, y suficiente.
- https://pkg.go.dev/log/slog — lo que llegó en 1.21. Léelo para saber qué te estás perdiendo y por qué `D14` lo deja fuera.
- https://pkg.go.dev/context — la propagación del §2.
- https://developer.mozilla.org/en-US/docs/Web/HTTP/Headers/Access-Control-Expose-Headers — el hallazgo `C-05`, en una página.
- https://www.w3.org/TR/trace-context/ — el estándar de propagación de contexto de traza. No lo usamos; conviene saber que existe antes de inventar un formato propio.
- https://12factor.net/logs — "trata los logs como flujos de eventos", que es el argumento del `stdout` del §3.
- https://cheatsheetseries.owasp.org/cheatsheets/Logging_Cheat_Sheet.html — el §4 con más detalle.

**Libros**
- *Release It!* (Michael Nygard) — su capítulo sobre transparencia y qué hace que un sistema sea diagnosticable en producción.

**Video / apoyo**
- Busca "structured logging Go" y "correlation id microservices". Casi todo el material asume `slog` o una librería: tradúcelo mentalmente al §3.

**Orden de lectura sugerido:** haz el recorrido del §6 antes de leer nada más —es
media hora y explica el apéndice entero— → la página de
`Access-Control-Expose-Headers` si el paso 1 falla → `12factor.net/logs`, que son
diez líneas → y el resto por saltos.

> ⚠️ URLs, títulos y ediciones pueden haber cambiado: verifícalos. Las
> referencias a libros y videos son de memoria y pueden ser inexactas. La fuente
> de verdad de versiones es `prompts/decisiones-y-versiones.md` §7.

---

> 🏷️ **Este apéndice no lleva tag.** Es de consulta pura. El middleware de
> `request-id`, el logger y la instrumentación del store son entregables de `be01`
> y `be02`, y se versionan con esas fases.
