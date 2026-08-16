# 🔑 Apéndice bea-04 — JWT por dentro y su CVE

> Tutorial React 16 — Rifas y chances · **Track BE opcional 🔥** · Consulta rápida · ~3 horas
> Lo referencian: `be04`; `bea-08` lo cruza

---

Este apéndice responde tres preguntas que nacen en `be04` y no caben ahí: **qué
hay realmente dentro de un JWT**, **cómo se lee un aviso de seguridad y se decide
si te afecta**, y **cuándo un JWT es la herramienta correcta y cuándo no**.

No es un curso de criptografía. Damos por sabidos hash, firma y clave simétrica
contra asimétrica. Lo que se explica es lo que la gente sigue equivocando después
de años usando JWT.

---

## 🧭 Índice de salto rápido

1. [Anatomía: tres partes, dos de ellas legibles](#1-anatomía-tres-partes-dos-de-ellas-legibles)
2. [Qué significa "firmado", y qué no significa](#2-qué-significa-firmado-y-qué-no-significa)
3. [Los claims que importan acá](#3-los-claims-que-importan-acá)
4. [Algoritmos y el ataque `alg: none`](#4-algoritmos-y-el-ataque-alg-none)
5. [Por qué un JWT no se puede revocar](#5-por-qué-un-jwt-no-se-puede-revocar)
6. [El CVE de `dgrijalva/jwt-go`](#6-el-cve-de-dgrijalvajwt-go)
7. [Cómo se lee un aviso de seguridad](#7-cómo-se-lee-un-aviso-de-seguridad)
8. [La migración a `golang-jwt/jwt`, paso a paso](#8-la-migración-a-golang-jwtjwt-paso-a-paso)
9. [🧩 Cuándo usar qué: JWT contra sesión](#-cuándo-usar-qué-jwt-contra-sesión)

---

## 1. Anatomía: tres partes, dos de ellas legibles

```
eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIyIiwiZXhwIjoxNzg4MDAwMDAwfQ.4f_kR…
└────────── cabecera ──────────┘ └────────── claims ──────────┘ └─ firma ─┘
```

Tres partes separadas por puntos. Las dos primeras son **Base64URL, no
cifrado**:

```bash
# Léelo tú, sin ninguna clave:
echo 'eyJzdWIiOiIyIiwiZXhwIjoxNzg4MDAwMDAwfQ' | base64 -d
# {"sub":"2","exp":1788000000}
```

> 🧭 **Consecuencia operativa, y es la que más se ignora.** Todo lo que pongas en
> un JWT lo puede leer cualquiera que lo tenga: el usuario, un proxy, quien mire
> el `localStorage` de un equipo prestado, quien lea un log donde se coló el
> header. **Nada sensible en un token.** Ni documentos, ni teléfonos, ni roles
> internos que prefieras no publicar, ni el hash de nada.
>
> Base64 no es cifrado. Es codificación para que un binario viaje por un canal de
> texto.

La tercera parte, la firma, se calcula sobre las dos primeras más un secreto que
solo tiene el servidor.

---

## 2. Qué significa "firmado", y qué no significa

**Significa:** que el contenido no se modificó desde que el servidor lo emitió, y
que lo emitió alguien con el secreto.

**No significa:** que sea secreto (§1). Ni que siga siendo válido (§5). Ni que
quien lo presenta sea su dueño legítimo — un token robado funciona perfectamente,
porque el token *es* la credencial.

📖 **Un JWT no prueba quién eres: prueba que alguien con el secreto afirmó, en
algún momento, quién eras.** De ahí se derivan las tres protecciones que hay que
poner siempre: que expire, que viaje por HTTPS, y que no se registre en ningún
log.

---

## 3. Los claims que importan acá

El RFC 7519 registra siete claims estándar. El track usa cuatro y conviene saber
por qué los otros no.

| Claim | Qué es | En el track |
|---|---|---|
| `sub` | El sujeto: **quién** | El `id` del usuario. **La única fuente de identidad que el backend acepta** |
| `exp` | Cuándo deja de valer | `JWT_TTL`, 12 h en laboratorio, 1 h en UAT y producción |
| `iat` | Cuándo se emitió | Diagnóstico: permite saber la edad de un token |
| `iss` | Quién lo emitió | `raffles-api` |
| `aud` | **Para quién** es | **No se usa** — y ver el §6, porque es justo el del CVE |
| `nbf` | No válido antes de | No se usa: no hay tokens programados |
| `jti` | Identificador único | No se usa: haría falta para una lista de revocación (§5) |

**`aud` merece un párrafo** porque es el claim peor entendido. Sirve para que un
token emitido para el servicio A no valga en el servicio B, aunque compartan
secreto o emisor. Con un solo backend no aporta nada, y por eso este sistema no
lo usa. Con dos o más servicios que confíen en el mismo emisor, **no ponerlo es un
agujero**: cualquier token sirve en cualquiera.

> ⚠️ Y el detalle que hay que mirar dos veces: `exp` e `iat` son
> **NumericDate** —segundos desde el epoch, en UTC—, no cadenas ISO. Los verifica
> el servidor **contra su propio reloj**, lo que conecta directamente con `be06`:
> si el reloj del servidor está mal, la expiración está mal.

---

## 4. Algoritmos y el ataque `alg: none`

| Familia | Qué usa | Cuándo |
|---|---|---|
| `HS256` | Un secreto compartido (HMAC) | Un solo servicio firma y verifica. **Lo del track** |
| `RS256` / `ES256` | Par de claves | Uno firma, muchos verifican sin poder firmar |
| `none` | **Nada** | Nunca, en ningún caso, jamás |

`none` existe en el estándar para tokens que se protegen por otro medio, y es la
puerta de la familia de ataques más conocida de JWT.

**El ataque, en tres pasos.** El atacante toma un token válido, cambia la cabecera
a `{"alg":"none"}`, modifica los claims a su gusto, y deja la firma **vacía**
(pero conserva el punto final). Si el servidor confía en el `alg` que viene en la
cabecera para decidir cómo verificar, concluye que no hay que verificar nada.

> 🧭 **La causa raíz, dicha con precisión: la cabecera la elige quien manda el
> token, no quien lo verifica.** Delegar en un dato controlado por el atacante la
> decisión de cómo se comprueba su propio token es el error de diseño, y `none`
> es solo su manifestación más famosa. La variante hermana es la **confusión de
> algoritmo**: un servidor que espera `RS256` y acepta `HS256`, con la clave
> pública usada como secreto HMAC — y la clave pública es pública.

**La defensa, que son tres líneas y van siempre:**

```go
_, err := jwt.ParseWithClaims(tokenString, &claims, func(t *jwt.Token) (interface{}, error) {
    // No preguntes qué algoritmo dice el token: comprueba que sea el TUYO.
    if _, ok := t.Method.(*jwt.SigningMethodHMAC); !ok {
        return nil, fmt.Errorf("algoritmo inesperado: %v", t.Header["alg"])
    }
    return s.secret, nil
})
```

> ⚠️ Las librerías modernas se niegan a aceptar `none` aunque tú no lo
> compruebes. **Eso no te exime**: si tu defensa consiste en que la librería se
> porte bien, tu defensa es la política de mantenimiento de un tercero. Que es,
> exactamente, de lo que trata el §6.

Y el secreto: **32 bytes como mínimo** para HS256. Un secreto corto se rompe por
fuerza bruta *offline* — el atacante tiene el token y todo el tiempo del mundo.

---

## 5. Por qué un JWT no se puede revocar

Un JWT es **autocontenido**: el servidor no guarda nada. Verifica la firma,
comprueba `exp`, y confía. Esa es toda su gracia —no hay consulta a base en cada
petición, cualquier réplica verifica sin estado compartido— y es también su
límite.

**Consecuencia:** un token robado sirve hasta que expira. No hay "cerrar sesión en
todos los dispositivos", no hay "invalidar el token de ese usuario", no hay
"echar al que despedimos esta mañana". El logout del frontend borra el token del
`localStorage`; el token sigue siendo válido hasta su `exp`.

Las salidas, con su precio:

| Estrategia | Qué cuesta |
|---|---|
| `exp` corto | Al usuario lo echan seguido. Se compensa con *refresh token* |
| Lista de revocación | Una consulta por petición: **acabas de perder lo que hacía atractivo el JWT** |
| Versión de token en el usuario | Igual: una consulta por petición |
| Sesión de servidor de toda la vida | Estado compartido, y funciona perfectamente |

> 🧭 **La decisión del track, y su porqué.** `JWT_TTL` largo en laboratorio, sin
> *refresh token*, y la fricción **declarada como deuda 💸 viva**: cuando el token
> vence, el interceptor de la Fase 2 recibe un `401`, hace logout global, y el
> usuario pierde lo que estuviera haciendo.
>
> No es un olvido. Implementar *refresh* exige que el **cliente** lo llame, o sea
> tocar `apiClient.js` y sus interceptores, y eso excede la única excepción
> negociada del track (`D27`). Decidir no pagar una deuda y escribir por qué es
> una forma respetable de administrarla.

---

## 6. El CVE de `dgrijalva/jwt-go`

`D16` manda adoptar `dgrijalva/jwt-go` v3.2.0 **a propósito** en `be04`,
descubrir su estado y migrar. Este es el aviso, con los datos verificados contra
la fuente oficial al escribir este apéndice:

| Dato | Valor |
|---|---|
| Aviso de GitHub | `GHSA-w73w-5m7g-f7qc` |
| CVE | **`CVE-2020-26160`** |
| Paquete | `github.com/dgrijalva/jwt-go` |
| Versiones afectadas | **hasta la v3.2.0 inclusive** |
| Severidad | **Alta — CVSS 7.5** |
| Publicado | **30 de septiembre de 2020** (NVD) |
| Parche | **No hay.** Migrar a `golang-jwt/jwt` ≥ 3.2.1 |

**El fallo, en una frase.** Cuando el claim de audiencia (`aud`) llega como un
arreglo vacío, la aserción de tipo falla y la audiencia queda como cadena vacía.
Una aplicación que confíe **solo** en esta librería para verificar la audiencia
puede aceptar un token que no era para ella.

**¿Afecta a este backend?** Hazte la pregunta en serio, porque hacérsela **es** el
trabajo. Este sistema no emite `aud`, no lo verifica, y tiene un solo servicio: el
vector concreto no aplica.

**Y aun así se migra.** Porque el CVE es el síntoma y no el problema:

> 🧠 **El problema es que la librería está abandonada.** El proyecto está
> archivado y el aviso dice *"no patch available"*. Este hallazgo no te toca; el
> próximo tampoco va a tener parche, y ese sí podría tocarte. Se migra por eso, no
> por el `aud`.

> ⚠️ **Verifica todo esto tú mismo antes de citarlo.** Los avisos se actualizan,
> las severidades se recalculan y los enlaces cambian. Los datos de arriba se
> confirmaron contra el aviso oficial al escribir este apéndice, y aun así el
> procedimiento correcto es abrirlo y leerlo — que es, literalmente, lo que enseña
> el §7. Un apéndice de seguridad con un dato de segunda mano es peor que no
> tenerlo.

---

## 7. Cómo se lee un aviso de seguridad

Un aviso no se lee para asustarse: se lee para **decidir**. Seis preguntas, en
este orden.

**1. ¿Qué paquete y qué versiones?** El rango afectado es lo primero. Un aviso
sobre la v2 de algo que usas en v4 no es tu problema. Comprueba qué tienes de
verdad, no lo que crees:

```bash
go list -m all | grep jwt
go list -m -u all            # y si hay versión nueva
```

**2. ¿Hay parche?** Si lo hay, la decisión suele terminar acá: actualiza. Si dice
*"no patch available"*, la conversación cambia por completo — y esa frase es, casi
siempre, sinónimo de proyecto abandonado.

**3. ¿Cuál es el vector concreto?** No la puntuación: **el mecanismo**. Qué tiene
que hacer un atacante, qué tiene que hacer tu código para ser vulnerable. Acá:
verificar `aud` apoyándote solo en esta librería.

**4. ¿Mi código hace eso?** La pregunta que solo puedes responder tú, y que ningún
escáner responde bien. Búscalo:

```bash
grep -rn "Audience\|aud\|VerifyAudience" .
```

**5. ¿Qué pasa si no hago nada?** Sé concreto: qué se compromete, para quién, con
qué esfuerzo. "Nada, porque no usamos `aud`" es una respuesta válida **si la
verificaste**.

**6. ¿Qué pasa con el próximo?** La pregunta que decide de verdad. Un proyecto
archivado no va a tener parche la próxima vez. Migrar cuando **no** te urge es
barato; migrar durante un incidente, no.

> 🧭 **El criterio, en una línea:** la severidad decide la **urgencia**; el estado
> de mantenimiento decide la **estrategia**.

Y automatiza la pregunta 1, porque nadie la hace a mano:

```bash
go install golang.org/x/vuln/cmd/govulncheck@latest
govulncheck ./...
```

`govulncheck` no se limita a mirar el `go.mod`: analiza si tu código **alcanza**
la función vulnerable, lo que reduce muchísimo el ruido. `be09` lo pone en el
pipeline.

---

## 8. La migración a `golang-jwt/jwt`, paso a paso

```bash
go get github.com/golang-jwt/jwt/v4@v4.4.2
go mod edit -droprequire github.com/dgrijalva/jwt-go
go mod tidy
```

```go
// ANTES                                 // DESPUÉS
import "github.com/dgrijalva/jwt-go"     import "github.com/golang-jwt/jwt/v4"

jwt.StandardClaims                       jwt.RegisteredClaims
IssuedAt:  now.Unix()                    IssuedAt:  jwt.NewNumericDate(now)
ExpiresAt: now.Add(ttl).Unix()           ExpiresAt: jwt.NewNumericDate(now.Add(ttl))
```

El cambio es sorprendentemente pequeño, y **esa pequeñez también es contenido**:
un fork bien hecho conserva la superficie de la API para que migrar no sea una
excusa para no migrar.

Los tres cambios de la v4, con su porqué:

- **`StandardClaims` → `RegisteredClaims`.** El RFC 7519 los llama "claims
  registrados". El nombre anterior nunca fue el correcto.
- **`int64` → `*jwt.NumericDate`.** Con `int64`, "sin expiración" y "expira en el
  epoch" son el mismo valor: `0`. Con un puntero, ausente y cero son distintos. Es
  la misma lección del `participantId` de `be03`, en otra capa.
- **La verificación de `aud` cambió**, que es lo que arregla el CVE.

Verifica que la deuda se pagó de verdad:

```bash
grep -rn "dgrijalva" .        # no debe devolver nada
go list -m all | grep jwt     # solo golang-jwt
```

> 📝 Y una nota de lectura para el `go.mod`: el
> `github.com/dgrijalva/jwt-go v3.2.0+incompatible` lleva ese sufijo porque el
> repositorio etiquetó una v3 sin declarar el `/v3` en la ruta del módulo, como
> pide el versionado semántico de Go. Es una señal de proyecto que dejó de
> cuidarse, y de las que se aprenden a leer tarde.

---

## 🧩 Cuándo usar qué: JWT contra sesión

| Necesitas… | JWT | Sesión de servidor |
|---|---|---|
| Verificar sin consultar a nadie | ✅ | ❌ |
| Varias réplicas sin estado compartido | ✅ | Necesita almacén común |
| Varios servicios que confían en un emisor | ✅ (con `aud`) | Complicado |
| **Cerrar sesión de verdad, ya** | ❌ §5 | ✅ |
| Cambiar permisos y que apliquen al instante | ❌ | ✅ |
| Guardar datos sensibles de la sesión | ❌ §1 | ✅ |
| Tokens de vida corta con renovación | Con *refresh* | Nativo |

📖 **La regla honesta:** JWT gana cuando el problema es **escalar la
verificación**. Sesión gana cuando el problema es **controlar el acceso en
tiempo real**. Casi todo el mundo elige JWT por moda y descubre el §5 el día que
alguien pide echar a un usuario.

**Y por qué este sistema usa JWT.** No por escala —un monolito con un Postgres no
la necesita— sino por el contrato: el frontend de la Fase 2 ya guarda una cadena
opaca en un campo `token` y la manda como `Bearer`. Un JWT encaja en ese hueco
**sin tocar un solo archivo del cliente**. Una sesión de servidor encajaría igual
de bien en el hueco, y habría exigido una tabla y una consulta por petición a
cambio de una revocación que este dominio no está pidiendo.

> 🧠 Que la respuesta correcta la haya decidido **el contrato heredado** y no una
> comparación de arquitecturas es, probablemente, lo más realista de esta fase.

---

## 🧪 Ejercicios (8)

1. **🟢** Decodifica con `base64 -d` las dos primeras partes de tu token, sin herramientas. Anota qué campos son legibles.
2. **🟢** Comprueba con `curl` que un token con el `sub` modificado en jwt.io devuelve `401`, y encuentra la línea del log del servidor.
3. **🟡 Diagnóstico.** Fabrica un token `alg: none` con `base64` y compruébalo contra tu API. Después comenta la verificación de `t.Method` y repite. Anota si tu versión de la librería te salva sola, y qué implica eso.
4. **🟡** Baja `JWT_TTL` a 60 segundos, usa la aplicación hasta que venza, y documenta la experiencia completa del usuario. Ese es el aspecto exacto de la deuda del §5.
5. **🟠** Lee `GHSA-w73w-5m7g-f7qc` completo y responde las seis preguntas del §7 por escrito, con los comandos que usaste para cada una.
6. **🟠 Diagnóstico.** Ejecuta `govulncheck ./...` antes y después de la migración del §8 y guarda las dos salidas. Explica la diferencia entre lo que reporta y lo que reportaría un escáner que solo mira el `go.mod`.
7. **🟠** Migra a RS256 con un par de claves y explica qué gana el sistema. Sé concreto sobre quién puede firmar y quién solo verificar, y en qué escenario eso importaría acá.
8. **🔴** Implementa una lista de revocación en memoria para invalidar un token antes de su `exp`. Mide el costo por petición y después argumenta, con ese número, qué acabas de perder — y si valió la pena.

---

## 📚 Referencias

**Avisos y fuentes primarias**
- https://github.com/advisories/GHSA-w73w-5m7g-f7qc — el aviso del §6. **Ábrelo**: es material del apéndice, no una nota al pie.
- https://nvd.nist.gov/vuln/detail/CVE-2020-26160 — la entrada en la NVD, con el vector CVSS desglosado.
- https://github.com/golang-jwt/jwt — el fork, con su guía de migración.

**Documentación oficial**
- https://www.rfc-editor.org/rfc/rfc7519 — JWT. Para el §3: la sección 4.1, claims registrados.
- https://www.rfc-editor.org/rfc/rfc8725 — *JSON Web Token Best Current Practices*. **El documento más útil de esta lista**: su §3.1 es el `alg: none` explicado por quienes escribieron el estándar, y su §2.1 dice literalmente que no confíes en el `alg` de la cabecera.
- https://www.rfc-editor.org/rfc/rfc7515 — JWS, la firma por dentro.
- https://cheatsheetseries.owasp.org/cheatsheets/JSON_Web_Token_for_Java_Cheat_Sheet.html — el nombre dice Java; el contenido sobre ataques y mitigaciones aplica a cualquier lenguaje.
- https://pkg.go.dev/golang.org/x/vuln/cmd/govulncheck — el §7 automatizado.
- https://jwt.io — el depurador. **Pega tokens de laboratorio, nunca uno de producción**: es una página web y el token es una credencial.

**Libros**
- *Web Application Security* (Andrew Hoffman) — los capítulos de autenticación y ataques sobre tokens.
- *API Security in Action* (Neil Madden) — el mejor tratamiento largo de JWT contra sesión que conozco, con el §5 discutido a fondo.

**Video / apoyo**
- Busca "JWT alg none attack" y "why JWT is not a session". Verifica que las demostraciones usen librerías actuales: muchas explotan implementaciones ya corregidas y dan una falsa sensación de facilidad.

**Orden de lectura sugerido:** el §1 y el §4 de este apéndice antes de escribir el
paquete `auth` de `be04` → RFC 8725 §2 y §3, que son tres páginas y cubren todos
los errores comunes → el aviso `GHSA-w73w-5m7g-f7qc` entero antes de migrar →
`bea-08` cuando quieras el resto del panorama de seguridad de la API.

> ⚠️ URLs, títulos, **severidades y fechas** pueden haber cambiado: verifícalos.
> Los datos del CVE se confirmaron contra el aviso oficial al escribir este
> apéndice, y aun así el procedimiento correcto es abrirlo. Las referencias a
> libros y videos son de memoria y pueden ser inexactas. La fuente de verdad de
> versiones es `prompts/decisiones-y-versiones.md` §7.

---

> 🏷️ **Este apéndice no lleva tag.** Es de consulta pura. El código de `auth`, la
> migración en sus dos commits y `server/postmortem-jwt.md` son entregables de
> `be04` y se versionan con esa fase.
