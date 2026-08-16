# 🛡️ Apéndice bea-08 — Seguridad de API aplicada

> Tutorial React 16 — Rifas y chances · **Track BE opcional 🔥** · Consulta rápida · ~3 horas
> Lo referencian: `be04` principalmente; `be03` y `be09` lo consultan

---

Esto es **seguridad defensiva aplicada a esta API**, nunca en abstracto. Cada
sección responde a una pregunta concreta sobre el backend de rifas: *¿puede
alguien vender un número que no le corresponde? ¿puede fijar el precio desde el
cuerpo de un `POST`? ¿qué le estamos contando a un atacante en cada mensaje de
error?*

No hay listas genéricas de OWASP copiadas. Hay seis riesgos que **este** sistema
tiene, con la comprobación que los detecta y la defensa que los cierra. Y al
final, lo más importante del apéndice:

> 🧭 **La lista de lo que este backend NO cubre a propósito.** Para que nadie
> confunda un laboratorio de curso con un backend de producción. Está en el §7 y
> es de lectura obligatoria.

---

## 🧭 Índice de salto rápido

1. [Inyección SQL, y la única concatenación permitida](#1-inyección-sql-y-la-única-concatenación-permitida)
2. [Autorización a nivel de objeto](#2-autorización-a-nivel-de-objeto)
3. [Asignación masiva](#3-asignación-masiva)
4. [Qué filtra un mensaje de error](#4-qué-filtra-un-mensaje-de-error)
5. [Límites de tasa](#5-límites-de-tasa)
6. [CORS bien entendido](#6-cors-bien-entendido)
7. [🚫 Lo que este backend NO cubre](#7--lo-que-este-backend-no-cubre)
8. [🧩 Cuándo usar qué](#-cuándo-usar-qué)

---

## 1. Inyección SQL, y la única concatenación permitida

El track escribe SQL a mano (`D17`), así que esto no es negociable: **los datos
viajan por placeholder, siempre**.

```go
// ✅ El valor nunca es parte de la sentencia. El driver lo manda aparte y
//    Postgres jamás lo interpreta como SQL.
query := s.db.Rebind(`SELECT … FROM raffles WHERE status = ? AND id = ?`)
s.db.GetContext(ctx, &r, query, status, id)

// ❌ Un solo caso de esto y el sistema es de quien lo encuentre.
query := "SELECT … FROM raffles WHERE status = '" + status + "'"
```

Con el segundo, un `status` igual a `open'; DROP TABLE sales; --` no es una
hipótesis de manual: es una tarde mala.

### La excepción, que hay que entender para no imitarla mal

El track **sí** concatena, exactamente una vez:

```go
// be02, en el UPDATE de raffles
`… updated_at = ` + s.db.Now() + ` WHERE id = ?`
```

Y es legítimo por una razón precisa: **`s.db.Now()` devuelve `"now()"` o
`"datetime('now')"`, dos constantes elegidas por un `if` sobre el dialecto**. El
valor no viene del usuario, no viene de la red, no viene de la base. No hay
entrada que envenenar.

> 🧭 **La regla que separa los dos casos, y conviene poder recitarla:** los
> **datos** van por placeholder, sin excepción; los **fragmentos de dialecto**
> pueden concatenarse **si y solo si** salen de un conjunto cerrado definido en el
> código. Un nombre de tabla que llega en un parámetro de query **no** es un
> fragmento de dialecto: es un dato.
>
> Y cuando de verdad necesites componer identificadores dinámicos —un `ORDER BY`
> configurable, por ejemplo—, la defensa es una **lista blanca**, nunca un
> escapado:
>
> ```go
> var orderable = map[string]string{"name": "name", "closesAt": "closes_at"}
> col, ok := orderable[r.URL.Query().Get("_sort")]
> if !ok { col = "id" }   // lo que no está en la lista, no existe
> ```

**Cómo comprobarlo en tu código:** `grep -rn "\" +\|fmt.Sprintf" internal/*/store*.go`.
Cada resultado tiene que poder justificarse con el párrafo de arriba.

---

## 2. Autorización a nivel de objeto

**Autenticación** es saber quién eres; **autorización** es saber si **esto** es
tuyo. `be04` resolvió la primera. La segunda está declarada como deuda 💸 y esta
sección explica exactamente qué falta.

El escenario, con nombres: el usuario 2 —Beto— pide
`PUT /raffles/7` sobre una rifa que creó otra persona. Hoy el backend **verifica
el token, ve que es un usuario válido, y le deja**. La rifa no tiene dueño y
nadie pregunta.

```go
// Lo que hay hoy: identidad verificada, propiedad no verificada.
userID := httpapi.UserIDFrom(ctx)   // ✅ sabemos quién es
if userID == 0 { return ErrUnauthenticated }
// ❌ y nadie pregunta si la rifa 7 es suya
```

**La defensa**, cuando el dominio la exija:

```sql
ALTER TABLE raffles ADD COLUMN owner_id BIGINT REFERENCES users(id);
```

```go
raffle, err := s.store.FindByID(ctx, id)
if err != nil { return err }
if raffle.OwnerID != httpapi.UserIDFrom(ctx) {
	// 404 y no 403, a propósito: un 403 confirma que el recurso existe.
	// Ver §4.
	return ErrNotFound
}
```

> ⚠️ **El error que se repite en todas partes:** verificar la propiedad **en el
> handler** y no en el servicio. Funciona en las cinco rutas que revisaste y falla
> —abierta— en la sexta, la que alguien agregó el mes pasado. La comprobación va
> donde vive la regla: **en el servicio**, junto a la transición de estado que
> `be04` ya custodia ahí.

**Cómo se prueba.** No hay atajo: una prueba por operación sensible, con dos
usuarios. Si el dominio tiene propiedad, esa suite es obligatoria, porque este
fallo **no produce ningún síntoma** hasta que alguien lo aprovecha.

---

## 3. Asignación masiva

Es el riesgo más subestimado de cualquier API que deserializa un cuerpo a un
struct. La pregunta: **¿qué campos del JSON puede fijar el cliente?**

En este dominio, tres campos son peligrosos y por motivos distintos:

| Campo | Si el cliente lo fija… |
|---|---|
| `status` | Salta el flujo: una rifa en borrador pasa a `settled` |
| `numberPrice`, `basePrize` | Cambia cuánto se cobra y cuánto se paga |
| `ownerId` (si existiera) | Se apropia de un recurso ajeno |

**Lo que ya protege el track**, y conviene ver que son tres capas distintas:

1. **Las transiciones custodiadas** (`be04`): el `status` que llega en el cuerpo
   se comprueba contra la tabla de transiciones legales. `draft → settled`
   devuelve `409`.
2. **El recálculo de montos** (`be07`): `totalCollected`, `prizeAmount` y `margin`
   **no se leen del cuerpo**. Se recalculan desde `sales`. La discrepancia se
   registra en el log y se ignora el valor del cliente.
3. **La identidad desde el contexto** (`be04`): un `ownerId` en el cuerpo se
   **ignora**, no se valida.

> 🧭 **La diferencia entre ignorar y validar, que no es sutil.** Validar un campo
> de identidad admite que a veces el cliente puede decidir quién es. Ignorarlo
> dice que nunca. Cuando el dato correcto ya lo tienes de otra fuente —el token,
> la base—, **el campo del cuerpo no se valida: se descarta**.

**Lo que falta**, y es una deuda 💸 real: `numberPrice` y `basePrize` sí se leen
del cuerpo en `PUT /raffles/:id`, porque el CRUD de la Fase 4 manda la rifa
entera. Un vendedor podría bajar el precio de una rifa ajena. La defensa es la
del §2 —propiedad— más una regla de dominio: **el precio no se cambia después de
la primera venta**.

```go
if len(sales) > 0 && incoming.NumberPrice != current.NumberPrice {
	return ErrPriceLocked   // 409: el estado del recurso no lo permite
}
```

📖 **La técnica general:** deserializa a un struct que **solo tenga los campos que
el cliente puede fijar**, no a la entidad del dominio. Si el struct no tiene
`OwnerID`, el JSON no puede fijarlo — y eso lo garantiza el compilador, no tu
memoria.

---

## 4. Qué filtra un mensaje de error

Cada mensaje que sale es información que le das a quien pregunta. Las cuatro
fugas de este dominio:

**Enumeración de cuentas.** Si el login distingue "ese email no existe" de
"contraseña incorrecta", acabas de regalar un verificador de cuentas válidas.
`be04` devuelve **el mismo error** para los dos casos, y `bcrypt.CompareHashAndPassword`
tarda lo mismo acierte o falle — porque la diferencia de tiempo también filtra.

**Existencia de recursos.** Un `403` sobre la rifa 7 confirma que existe; un `404`
no dice nada. Cuando la autorización falla por propiedad, **`404` es la respuesta
más discreta** (§2).

**Detalle interno en un `500`.** Lo que jamás debe salir:

```go
// ❌ pq: relation "raffles" does not exist  → le acabas de contar el motor,
//    el esquema y probablemente la versión
writeError(w, 500, err.Error())

// ✅ el detalle al log con su request-id; al cliente, lo mínimo
log.Printf("[req-id %s] %v", RequestIDFrom(ctx), err)
writeError(w, 500, "Error interno del servidor")
```

> 🧠 **La asimetría es deliberada y es buen diseño:** el servidor sabe qué pasó,
> el cliente no. Y el `X-Request-Id` es lo que permite que un usuario reporte
> "me salió un error, id `9f3a…`" y que tú encuentres el detalle exacto sin
> haberlo publicado (`bea-07`).

**Y la fuga del ejemplo perfecto:** en `be06`, el `409` de rifa cerrada. El
mensaje al cliente es *"La rifa ya cerró: no se pueden vender más números"*. El
log dice *"cerró a las 22:00-05:00 y ahora son las 22:03-05:00"*. Diagnóstico
completo dentro, información mínima fuera.

> ⚠️ Y un caso menos obvio: los mensajes de error del track **están en español y
> son legibles** porque los muestra `toReadableError` al usuario final. Eso es
> contrato (`be00`) y está bien. Lo que no puede pasar es que ese mensaje incluya
> un identificador interno, un nombre de columna o una ruta de archivo.

---

## 5. Límites de tasa

El track **no** los tiene, y hay tres sitios donde harían falta:

| Dónde | Qué evita |
|---|---|
| `POST /login` | Probar contraseñas indefinidamente |
| `POST /…/sell` | Un guion acaparando el tablero entero |
| `POST /…/reserve` | Un usuario reservando todos los números y no comprando ninguno |

El del login es el más grave, porque hoy **puedes probar contraseñas todo el
día**. `bcrypt` con costo 10 hace cada intento lento, y eso es una mitigación
real — pero también significa que un atacante paralelo consume tu CPU, que es
otra forma del mismo problema.

Un limitador mínimo con la biblioteca estándar más `golang.org/x/time/rate`
—que el track no incorpora para no sumar dependencia— cabe en veinte líneas. Lo
importante no es la implementación, son las tres decisiones:

- **¿Por qué se agrupa?** Por IP es lo fácil y castiga a oficinas enteras tras un
  NAT. Por email en el login es más justo y permite que alguien bloquee la cuenta
  de otro. Lo habitual es combinar.
- **¿Qué se devuelve?** `429 Too Many Requests` con `Retry-After`. ⚠️ Ojo: el
  frontend heredado **no sabe manejar un `429`** y lo mostraría como error
  genérico. Otra cosa que el contrato condiciona.
- **¿Dónde vive el contador?** En memoria no sobrevive a un reinicio ni se
  comparte entre réplicas. Compartirlo exige un almacén — y ahí la defensa deja de
  ser gratis.

---

## 6. CORS bien entendido

De todo lo de este apéndice, **es lo que más se malinterpreta**, así que vale la
pena decirlo sin rodeos:

> 🧭 **CORS no protege tu API. CORS protege al usuario del navegador.**
>
> Es una política que **el navegador** aplica sobre las respuestas que recibe. Un
> `curl`, un guion en Python, Postman o cualquier cliente que no sea un navegador
> **la ignoran por completo**. Tu backend con `Access-Control-Allow-Origin`
> restringido sigue respondiendo a todo el mundo.

Compruébalo, que se entiende en diez segundos:

```bash
# Origen no permitido, y responde igual. CORS no rechaza nada del lado del
# servidor: solo omite el header, y es el NAVEGADOR el que descarta.
curl -i localhost:3001/raffles -H 'Origin: http://evil.example' \
     -H "Authorization: Bearer $TOKEN"
```

**Lo que CORS sí hace:** impedir que una página en `evil.example` lea, **con las
credenciales del usuario**, respuestas de tu API desde el navegador de ese
usuario. Eso es valioso y no es poco. Pero no es control de acceso.

**Lo que CORS no hace, y que la gente cree que hace:**

- No sustituye a la autenticación. La autenticación es el `Bearer` de `be04`.
- No impide que nadie llame a tu API desde fuera de un navegador.
- No protege contra CSRF por sí solo. (Este sistema no es vulnerable a CSRF por
  otro motivo: el token va en un header que solo el JavaScript de tu propio
  origen puede poner, no en una cookie que el navegador mande sola.)

**La configuración del track**, con cada línea justificada:

```go
w.Header().Set("Access-Control-Allow-Origin", allowedOrigin)  // el 3000, no "*"
w.Header().Set("Access-Control-Allow-Methods", "GET, POST, PUT, PATCH, DELETE, OPTIONS")
w.Header().Set("Access-Control-Allow-Headers", "Authorization, Content-Type, X-Request-Id")
w.Header().Set("Access-Control-Expose-Headers", "X-Request-Id")  // C-05
```

> ⚠️ **`*` y credenciales no conviven**, y es una regla del propio estándar: con
> `Access-Control-Allow-Credentials: true`, el navegador **rechaza** un
> `Allow-Origin: *`. Este sistema no usa cookies —el token va en un header— así
> que no necesita credenciales, pero el día que alguien mueva el token a una
> cookie `HttpOnly` (ejercicio 30 de `be04`), esta línea deja de ser opcional.
>
> Y el origen sale de configuración (`ALLOWED_ORIGIN`), nunca escrito a mano:
> `be09` §4.3 le da un valor distinto por ambiente.

---

## 7. 🚫 Lo que este backend NO cubre

La sección más importante del apéndice. **Este es un laboratorio de curso y no un
backend de producción.** Lo que sigue no son descuidos: son ausencias declaradas,
y saber enumerarlas es parte de lo que el track enseña.

| No hay | Consecuencia | Dónde se discute |
|---|---|---|
| **Autorización a nivel de objeto** | Cualquier usuario puede editar cualquier rifa | §2, `be04` |
| **Límites de tasa** | Fuerza bruta sin freno sobre el login | §5 |
| **HTTPS** | Todo viaja en claro; el token es interceptable | Se resuelve fuera del proceso, en un proxy |
| **`sslmode=require` en desarrollo** | El tráfico a la base va en claro | `be02`, `be09` §4.3 |
| **Rotación de secretos** | `JWT_SECRET` es fijo; rotarlo invalida todas las sesiones | `be09` |
| **Revocación de tokens** | Un token robado sirve hasta su `exp` | `bea-04` §5 |
| **Gestor de secretos** | Variables de entorno y ya | `be09` |
| **Auditoría de accesos** | Se registra quién vendió, no quién consultó qué | `be07` |
| **Validación de longitud de entrada** | Un `name` de 10 MB entra sin problema | Ejercicio 10 de `be01` |
| **`POST /_chaos` fuera de producción** | Un endpoint para romper tu propio sistema | `be09` §4.3, ejercicio 24 |
| **Cabeceras de seguridad** (`HSTS`, `X-Content-Type-Options`…) | Van en el proxy, no en la API | — |

> 🧠 **Y la que más conviene tener presente:** el propósito del track es enseñar a
> **reemplazar un backend sin romper a su cliente**, no a construir un backend
> endurecido. Cada ausencia de esta tabla es una decisión de alcance, está escrita,
> y `bea-09` la recoge en el mapa de deuda con su criterio de exigibilidad.
>
> Si algún día llevas este código a algo real, **esta tabla es tu lista de
> pendientes**, en este orden: HTTPS, límites de tasa en el login, autorización a
> nivel de objeto, y sacar el caos del binario.

---

## 🧩 Cuándo usar qué

| Si el riesgo es… | La defensa es… | Y **no** |
|---|---|---|
| Inyección SQL | Placeholders, siempre | Escapar a mano |
| Un identificador dinámico en el SQL | Lista blanca | Escapar el nombre |
| Alguien tocando lo ajeno | Propiedad verificada **en el servicio** | Verificar en cada handler |
| El cliente fijando `status` o precio | Un struct de entrada con solo lo permitido | Validar la entidad entera |
| El cliente fijando identidad | **Ignorar** el campo; usar el contexto | Validarlo |
| Enumerar cuentas | El mismo error y el mismo tiempo | Mensajes "útiles" |
| Filtrar el esquema en un `500` | Detalle al log, genérico al cliente | `err.Error()` en la respuesta |
| Confirmar que un recurso existe | `404` en vez de `403` | `403` |
| Fuerza bruta | Límite de tasa | Confiar en que `bcrypt` es lento |
| Una página ajena leyendo tu API | CORS restringido | Creer que eso te protege del resto |
| Un cliente que no es navegador | **Autenticación** | CORS |

---

## 🧪 Ejercicios (9)

1. **🟢** Recorre los stores con `grep` buscando concatenación en consultas y justifica cada resultado con la regla del §1.
2. **🟢** Comprueba con `curl` que `POST /login` devuelve el mismo error y tarda parecido con un email inexistente y con una contraseña incorrecta.
3. **🟡 Diagnóstico.** Manda un `PUT /raffles/1` con un `ownerId` y un `status` inventados. Determina qué hace el backend con cada uno y por qué son casos distintos.
4. **🟡** Comprueba con `curl` y un `Origin` no permitido que la API responde igual. Explica en tres líneas qué protege CORS entonces.
5. **🟠** Implementa la propiedad del §2: columna `owner_id`, comprobación en el servicio, y una prueba con dos usuarios por cada operación sensible.
6. **🟠 Diagnóstico.** Haz que un `500` devuelva `err.Error()` al cliente, provoca un error de base, y anota exactamente cuánta información acabas de publicar.
7. **🟠** Implementa la regla de `ErrPriceLocked` del §3 y demuestra con una prueba que el precio no cambia después de la primera venta.
8. **🔴** Implementa un límite de tasa en `POST /login`, decide las tres cuestiones del §5 y documenta qué pasa en el frontend heredado cuando recibe un `429`.
9. **🔴** Escribe la evaluación de riesgo de este backend como si fuera a producción mañana: toma la tabla del §7, ordénala por riesgo real para **este** dominio, y estima el esfuerzo de cada mitigación. Es el insumo directo de `bea-09`.

---

## 📚 Referencias

**Documentación oficial y guías**
- https://owasp.org/API-Security/editions/2023/en/0x11-t10/ — el top 10 de seguridad de APIs. El §2 es "Broken Object Level Authorization", que es el primero de la lista por algo.
- https://cheatsheetseries.owasp.org/cheatsheets/Mass_Assignment_Cheat_Sheet.html — el §3.
- https://cheatsheetseries.owasp.org/cheatsheets/SQL_Injection_Prevention_Cheat_Sheet.html — el §1, incluida la lista blanca para identificadores.
- https://cheatsheetseries.owasp.org/cheatsheets/Error_Handling_Cheat_Sheet.html — el §4.
- https://developer.mozilla.org/es/docs/Web/HTTP/CORS — el §6, y la parte de "solicitudes con credenciales" es la que casi nadie lee.
- https://fetch.spec.whatwg.org/#cors-protocol — la especificación, para cuando MDN no baste.
- https://pkg.go.dev/golang.org/x/time/rate — el limitador del §5, si decides incorporarlo.

**Libros**
- *API Security in Action* (Neil Madden) — el mejor libro sobre este tema, y su capítulo de autorización cubre el §2 mucho mejor que cualquier resumen.
- *Web Application Security* (Andrew Hoffman) — más introductorio y muy claro sobre por qué cada ataque funciona.

**Video / apoyo**
- Busca "BOLA broken object level authorization" y "CORS explained properly". Para lo segundo, desconfía de cualquier video que presente CORS como un mecanismo de seguridad del servidor: es la confusión del §6.

**Orden de lectura sugerido:** el §7 primero —saber qué **no** cubre el sistema
antes que cómo cubre lo demás— → el §6, porque es lo que más gente tiene mal → el
top 10 de OWASP API para ponerle nombre a cada riesgo → y `bea-04` para todo lo
que sea tokens.

> ⚠️ URLs, títulos y ediciones pueden haber cambiado: verifícalos. Las guías de
> OWASP se reeditan y sus números cambian entre ediciones. Las referencias a
> libros y videos son de memoria y pueden ser inexactas. La fuente de verdad de
> versiones es `prompts/decisiones-y-versiones.md` §7.

---

> 🏷️ **Este apéndice no lleva tag.** Es de consulta pura. Si implementas la
> propiedad del §2 o el límite del §5, van como ejercicios de `be04`
> (`be04 ej…`), según
> [`00-convencion-de-git-y-tags.md`](00-convencion-de-git-y-tags.md).
