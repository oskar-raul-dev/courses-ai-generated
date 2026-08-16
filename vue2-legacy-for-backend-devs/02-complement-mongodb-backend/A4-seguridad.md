# 🔑 Apéndice 4 — Seguridad backend (OWASP aplicado)

## 🎯 Para qué sirve este apéndice

La Fase 11 pagó las deudas de autenticación y autorización; la Fase 12 hizo
reales los archivos. Pero `SECURITY-NOTES.md` — el documento que el sistema
heredado venía llenando desde su Fase 2, con quince "esto lo debería hacer el
backend" — merece un cierre completo, no parcial.

Este apéndice es ese cierre: **el OWASP API Security Top 10 aplicado endpoint
por endpoint a tu Mini Jira**, con los ataques ejecutados contra tu propio
sistema. La regla del apéndice, que es también su ética:

> No has defendido nada hasta que has escrito el ataque, lo has visto
> funcionar, y luego lo has visto fallar.

Todo lo que sigue se ejecuta **contra tu laboratorio**. Nada de esto se apunta
a sistemas ajenos: eso no es aprendizaje, es un delito.

---

## 💉 Inyección NoSQL, a fondo

### El origen (y por qué no es culpa de Mongo)

El Apéndice 3 lo dejó dicho: `req.query` puede ser un **objeto**.

```
GET /tickets?status=open           →  req.query.status === "open"          (string)
GET /tickets?status[$ne]=null      →  req.query.status === { $ne: null }   (¡objeto!)
```

El query parser de Express soporta sintaxis anidada. Si ese valor viaja
directo a un filtro de Mongo, el atacante acaba de escribir **parte de tu
query**. Lo mismo con un body JSON: nada impide mandar `{"username": {"$ne":
null}}` en el login.

### Los cuatro ataques clásicos (ejecútalos)

```js
// ATAQUE 1 — Bypass de autenticación (el más famoso de la época)
POST /auth/login
{ "username": { "$ne": null }, "password": { "$ne": null } }
// El findOne({username, password}) matchea al PRIMER usuario. Estás dentro.
// ⚠️ Tu Fase 11 ya no es vulnerable a la parte del password (bcrypt compara
//    un hash, no el filtro) — pero el `username` como objeto SIGUE entrando
//    al filtro. Pruébalo: ¿qué usuario te devuelve?

// ATAQUE 2 — Fuga de filtros por query string
GET /tickets?status[$ne]=zzz       // trae TODOS (ningún status es "zzz")
GET /tickets?status[$regex]=.*     // idem, con regex
GET /tickets?assignee[$exists]=false   // los que nadie tomó, aunque no debas verlos

// ATAQUE 3 — DoS por regex (ReDoS)
GET /tickets?q=(a+)+$              // regex catastrófico: la CPU del server, tuya
// (y sin índice, además: COLLSCAN + backtracking exponencial — F2/F7)

// ATAQUE 4 — $where: ejecución de JavaScript en el servidor
{ "$where": "sleep(5000) || true" }
// Si algo de tu API construye filtros desde input libre, esto es RCE de facto.
```

### Las tres defensas (en capas, no alternativas)

```js
// DEFENSA 1 — VALIDAR (la buena): lista blanca, tipos, enums del contrato
// Con ajv (los schemas de la F4) o express-validator:
const { query } = require("express-validator");
router.get("/",
  query("status").optional().isIn(["open","in_progress","resolved","closed"]),
  query("q").optional().isString().isLength({ max: 100 }),
  query("_sort").optional().isIn(["createdAt","priority","status","title"]),
  handleValidation,
  controller.list
);
// ⬆️ Un objeto {$ne:...} NO es "open". Rechazado antes de tocar Mongo.
// Esta defensa no "escapa" nada: define lo permitido. Es la correcta.

// DEFENSA 2 — SANITIZAR (la red): quitar lo peligroso por si algo se coló
app.use(require("express-mongo-sanitize")());   // elimina claves con $ y puntos
// Útil como defensa en profundidad. NO sustituye a validar: un $ eliminado
// sigue siendo input que nunca debió llegar.

// DEFENSA 3 — CASTEAR EXPLÍCITAMENTE en la frontera (F10: ya lo hacías)
const status = String(req.query.status || "");   // un objeto se vuelve "[object Object]"
// Feo, efectivo, y gratis. El casteo defensivo del que no confía en nadie.
```

**Y las dos reglas estructurales:**

- **`$where` y `mapReduce`: prohibidos.** Deshabilita la ejecución de JS en el
  servidor (`--noscripting` en mongod) — la Fase 14 tiene el sitio para el
  flag. Ningún endpoint del contrato los necesita.
- **Los regex del usuario, acotados:** el `?q=` del contrato construye un
  regex con input libre. Escapa los metacaracteres del usuario
  (`q.replace(/[.*+?^${}()|[\]\\]/g, "\\$&")`) — busca el texto literal, que
  es lo que el usuario quería, y ReDoS deja de existir.

---

## 🎫 Autenticación: la letra chica

Tu Fase 11 firma JWT con `jsonwebtoken` 8.5. Los agujeros que la época dejó
famosos:

| Agujero | Qué pasa | Cura |
|---|---|---|
| `algorithms` no especificado al **verificar** | el atacante manda un token con `alg: none` o cambia RS256→HS256 usando la clave pública como secreto | `jwt.verify(t, secret, { algorithms: ["HS256"] })` — **siempre** |
| Secreto débil o en el repo | fuerza bruta offline sobre el token | secreto largo aleatorio, en `.env` fuera de git, exigido por el compose (`${JWT_SECRET:?}`) |
| Sin `exp` | el token robado es eterno | `expiresIn` obligatorio (el curso: 1 h) |
| Logout "que no existe" | JWT es stateless: no se puede revocar | asumirlo (expiración corta) o mantener una denylist — decide y **escríbelo** |
| Token en localStorage | cualquier XSS lo roba | el legacy ya lo hizo; documenta el riesgo y la alternativa (cookie httpOnly + CSRF) |
| Claims sin validar | confías en el `role` que viene en el token… que TÚ firmaste, así que vale — pero **no** confíes en nada del body | el `reporter` sale de `req.user`, jamás del payload (F11) |

**Timing attack en el login:** si respondes "usuario no existe" al instante y
"password incorrecta" tras 80 ms de bcrypt, acabas de construir un enumerador
de usuarios. Cura: mismo mensaje genérico y **mismo coste** — corre un bcrypt
contra un hash dummy cuando el usuario no existe (ejercicio 14).

**Contraseñas:** bcrypt con cost ≥ 10 (12 en 2021), nunca SHA/MD5, nunca
"hash propio". Y `bcrypt.compare` — jamás `===` sobre hashes.

---

## 🚪 Autorización: el Top 10 empieza aquí

El #1 del OWASP API Top 10 de la época no es inyección: es **BOLA** (Broken
Object Level Authorization) — el objeto ajeno al que accedes cambiando un id.

```
GET /tickets/<id_de_otro>          ← ¿tu API deja verlo?
PATCH /tickets/<id_de_otro>        ← ¿deja EDITARLO?
DELETE /attachments/<id_ajeno>     ← ¿deja borrarlo?
```

La Fase 11 puso `requireAuth` y `requireRole`. Pero **autenticado ≠
autorizado sobre ESTE objeto**. El checklist que este apéndice exige aplicar a
cada endpoint:

| Endpoint | ¿Quién debe poder? | ¿Tu API lo cumple? |
|---|---|---|
| `GET /tickets/:id` | agentes: todos. Reporteros: ¿solo los suyos? — **decide y documenta** | ⬜ |
| `PATCH /tickets/:id` | agente asignado o admin; el reporter solo su descripción | ⬜ |
| `DELETE /tickets/:id` | ¿alguien, además de admin? | ⬜ |
| `POST /comments` | cualquiera autenticado; `author` del token, no del body | ⬜ |
| `DELETE /attachments/:id` | quien lo subió o un agente | ⬜ |
| `GET /users` | ¿el listado completo de usuarios es público para cualquier logueado? | ⬜ |

Y su hermano **BOPLA** (property level): el PATCH que acepta cualquier campo
del body permite a un reporter cambiar `assignee`, `status`, o inyectar
`role: "agent"` si tus users se actualizaran igual. **Lista blanca de campos
por rol**, siempre — nunca `$set: req.body`.

---

## 🛡️ El resto del kit

### Rate limiting (el freno)

```js
const rateLimit = require("express-rate-limit");

// El login: el objetivo #1 de la fuerza bruta
app.use("/auth/login", rateLimit({
  windowMs: 15 * 60 * 1000, max: 10,          // 10 intentos / 15 min / IP
  message: { error: "Demasiados intentos" }
}));
// Uploads y API general: límites distintos, política escrita
app.use("/attachments", rateLimit({ windowMs: 60000, max: 20 }));
app.use(rateLimit({ windowMs: 60000, max: 300 }));
```

⚠️ Detalle que muerde: tras un proxy (F12/F14), todas las IPs son la del
proxy → `app.set("trust proxy", 1)` o limitarás al proxy, no al atacante.

### helmet, cabecera por cabecera

| Cabecera | Contra qué |
|---|---|
| `X-Content-Type-Options: nosniff` | el navegador "adivinando" que tu adjunto .txt es HTML y ejecutándolo |
| `X-Frame-Options: DENY` | clickjacking (tu API no se embebe) |
| `Strict-Transport-Security` | downgrade a HTTP (solo tiene sentido con HTTPS real) |
| `Content-Security-Policy` | XSS — clave si sirves estáticos; para una API JSON, menor |
| `X-Powered-By: Express` (helmet lo **quita**) | regalarle al escáner tu stack |

### Uploads hostiles (F12, expandido)

- **Content-type spoofing:** un `.exe` renombrado a `.png` con MIME
  falsificado. El MIME del cliente es una **sugerencia**, no un hecho: valida
  por magic bytes (`file-type`) si el negocio lo exige.
- **HTML/SVG con `<script>`:** subir y servir un `.html` es XSS almacenado en
  tu dominio. Defensas: `Content-Disposition: attachment` (ya lo tienes) +
  `nosniff` + servir adjuntos desde otro dominio si el negocio crece.
- **Path traversal en el nombre:** `../../etc/passwd` como `filename`. GridFS
  te protege (el nombre es un campo, no una ruta), pero un `diskStorage`
  ingenuo **no** — sanea siempre.
- **Zip bomb / archivo gigante:** el `limits.fileSize` de multer, no
  negociable, y una cuota por usuario si el negocio lo pide.
- **Bombardeo de disco:** rate limit + cuota + monitoreo del tamaño de
  `fs.chunks` (F14).

### Secretos y errores

- Secretos: `.env` fuera de git (`.gitignore` desde la Fase 0), exigidos por
  el compose (`${VAR:?}`), rotables. El día que crezca: un vault. Lo que
  **nunca**: default en el código (`process.env.JWT_SECRET || "dev123"` es una
  puerta trasera en producción).
- Errores: el 500 seco de la Fase 10/A3 no era estética — un stack trace le
  regala al atacante rutas, versiones y estructura. Y los mensajes del login,
  genéricos por diseño.
- Logs: **nunca** loguees tokens, contraseñas ni bodies completos de auth.
  Ese log lo lee más gente de la que crees.

---

## 🧩 Chuleta

```js
// Inyección NoSQL: nace en el query parser (objeto en req.query), no en Mongo
//   1. VALIDAR (lista blanca, enums del contrato) ← la buena
//   2. SANITIZAR (express-mongo-sanitize)         ← la red
//   3. CASTEAR (String(x)) en la frontera         ← el cinturón
//   + $where/mapReduce PROHIBIDOS (--noscripting) + escapar regex del ?q=

// JWT: verify SIEMPRE con { algorithms: ["HS256"] } · exp obligatorio
//   secreto largo, en .env, sin default en código · logout: decide y escríbelo
// bcrypt cost ≥10 · compare, nunca === · mismo coste si el usuario NO existe

// Autorización: autenticado ≠ autorizado sobre ESTE objeto (BOLA)
//   lista blanca de campos por rol (BOPLA) — nunca $set: req.body

// rate limit (login 10/15min) · trust proxy si hay proxy
// helmet: nosniff · frameguard · sin X-Powered-By
// uploads: MIME es sugerencia · Content-Disposition · limits · sanea nombres
// errores: 500 seco al cliente, stack al log · logs sin secretos
```

---

## ⚠️ Errores comunes

- Creer que Mongo "no tiene inyección porque no es SQL" (tiene la suya, y
  entra por la puerta que Express dejó abierta).
- Sanitizar y no validar: quitaste el `$`, pero sigues aceptando cualquier
  cosa como `status`.
- `jwt.verify` sin `algorithms` (el agujero más citado de la librería).
- Poner auth y olvidar autorización por objeto: el 90% de los BOLA de la vida
  real son sistemas **con** login.
- `$set: req.body` en el PATCH (mass assignment con otro nombre).
- Rate limit tras un proxy sin `trust proxy` (limitas al proxy).
- Servir adjuntos sin `Content-Disposition` ni `nosniff` desde tu dominio.
- Secretos con default en el código "para desarrollo".
- Loguear el body del login "temporalmente, para depurar".
- Probar la seguridad solo con tests felices: si no escribiste el ataque, no
  sabes si la defensa funciona.

---

## 🧪 Ejercicios (36) — todos opcionales, todos contra TU laboratorio

**🟢 Fácil (1–10)**

1. Lanza el ataque 2 (`?status[$ne]=zzz`) contra tu API. ¿Devolvió todos los tickets? Loguea qué llegó a `req.query.status`. Si tu API sobrevivió, averigua QUÉ capa te salvó (¿el casteo de la F10?).
2. El ataque 1 contra `/auth/login` con `{"username":{"$ne":null}}`. ¿Qué pasa? Traza el camino del objeto hasta el `findOne`. Documenta si entraste, si fallaste en bcrypt, o si te rechazó una validación.
3. Instala `express-mongo-sanitize` y repite 1 y 2. Verifica en el log que la clave con `$` desapareció.
4. Ahora quita el sanitize y añade validación con `express-validator` (lista blanca de `status`). Repite los ataques: ¿qué status recibes ahora? ¿Qué defensa prefieres y por qué NO son alternativas?
5. `jwt.verify` sin `algorithms`: verifica que tu Fase 11 lo especifica. Si no, arréglalo y escribe el comentario que explica por qué.
6. Busca un `|| "secreto_dev"` en tu código (o ponlo y sufre). Reemplázalo por un `throw` si falta la variable. Verifica que el compose falla al arrancar sin `.env`.
7. Rate limit en el login: 15 intentos seguidos con curl. Verifica el 429 y su cabecera `Retry-After`.
8. helmet: compara las cabeceras de respuesta con y sin él (`curl -I`). Lista las 6 que aparecen y qué hace cada una.
9. Sube un `.html` con `<script>alert(1)</script>` como adjunto y ábrelo desde el navegador vía tu `GET /attachments/:id`. ¿Se ejecutó? Verifica que `Content-Disposition: attachment` está y funciona.
10. Abre `SECURITY-NOTES.md` y marca el estado REAL de cada línea heredada: pagada, parcial, o viva. Es tu punto de partida honesto.

**🟡 Intermedio (11–22)**

11. ReDoS en vivo: `?q=(a+)+$` (o el regex catastrófico que prefieras) sobre 100k tickets. Mide el tiempo de respuesta y la CPU del contenedor (`docker stats`). Ahora escapa los metacaracteres del input y repite. Tabula: antes/después.
12. `$where` prohibido: intenta usarlo desde mongosh y luego arranca mongod con `--noscripting`. Verifica el error. Añade el flag al compose de la F14 y documenta que ningún endpoint lo necesita.
13. BOLA en tu API: crea un ticket con el usuario A; con el token de B (rol reporter), intenta `GET`, `PATCH` y `DELETE` sobre él. Completa la tabla del checklist con lo que REALMENTE pasó. Cada ⬜ que se llene con "sí puede" es un hallazgo.
14. Timing attack: mide 100 logins con usuario inexistente vs 100 con usuario válido y password errónea. Grafica/tabula la diferencia. Ahora aplica el bcrypt dummy y vuelve a medir. ¿Se cerró la brecha?
15. BOPLA: manda un PATCH con `{"status":"closed","assignee":"yo","role":"agent","reporter":"otro"}` como reporter. ¿Cuántos campos pasaron? Implementa la lista blanca por rol y repite.
16. Mass assignment en users: si tuvieras `PATCH /users/:id`, ¿podría alguien escalarse a `role: "agent"`? Escribe el endpoint vulnerable, explota, y luego arréglalo. (El endpoint no está en el contrato: es un laboratorio.)
17. Enumeración de usuarios: `GET /users` con un token de reporter. ¿Devuelve todos los usernames y roles? Decide si es aceptable en un sistema interno, documenta la decisión, y si no lo es, restringe.
18. Cuenta de intentos por usuario (no solo por IP): implementa un bloqueo temporal tras N fallos del mismo username. Discute el nuevo problema que acabas de crear (DoS contra un usuario legítimo) y cómo lo mitigarías.
19. `trust proxy`: monta el proxy del A1 (ej. 30) y verifica que tu rate limit ahora ve la IP del proxy. Arréglalo y demuéstralo con dos IPs simuladas (`X-Forwarded-For`).
20. Path traversal: implementa el `diskStorage` ingenuo (A1/F12) y sube un archivo llamado `../../evil.txt`. ¿Dónde acabó? Sanea el nombre y repite. (GridFS te salvaba; el disco no.)
21. Magic bytes: sube un ejecutable renombrado a `.png` con MIME falsificado. Detéctalo con `file-type` (lee los primeros bytes) y rechaza. ¿Cuándo vale la pena esta defensa y cuándo es paranoia? Escribe el criterio.
22. Logs limpios: audita tu `console.error` y tu morgan — ¿algún log imprime tokens, passwords o el body del login? Límpialo y añade una regla al code review del equipo.

**🟠 Difícil (23–30)**

23. **La suite de ataques:** convierte los ejercicios 1, 2, 11, 13, 15 y 20 en tests de la Fase 13 (`test/security/`). Cada uno afirma que el ataque **falla**. Ahora tu seguridad es una regresión: quien la rompa, romperá el build. Es el entregable mayor del apéndice.
24. XSS almacenado, cadena completa: el `body` de un comentario con `<img src=x onerror=...>`. Tu API lo guarda tal cual (¿debe?). El frontend Vue lo escapa por defecto… salvo con `v-html`. Traza la cadena completa de responsabilidad backend↔frontend y escribe la política: ¿escapa el backend al guardar, al servir, o confía en el cliente? Defiende tu respuesta (no hay una única correcta, hay una que debes poder justificar).
25. CSRF: tu API usa `Authorization: Bearer` de localStorage — argumenta por qué eso te hace **inmune** a CSRF clásico (y vulnerable a XSS). Ahora diseña la variante con cookie httpOnly: ¿qué defensa CSRF necesitarías? Tabla comparativa de los dos modelos con sus riesgos.
26. Denylist de tokens: implementa el logout real (colección `revoked_tokens` con TTL index — un índice de la F7 que no usaste). Mide el costo (una lectura extra por request) y decide si vale la pena frente a la expiración corta. Documenta la decisión en `SECURITY-NOTES.md`.
27. Refresh tokens: diseña e implementa el par access (15 min) + refresh (7 días, rotativo, revocable en base). Prueba el flujo completo, incluida la detección de reuso de un refresh robado. Es el sistema de auth que un producto real necesita — y el que la Fase 11 declinó por alcance.
28. Cuotas de almacenamiento: límite por usuario en GridFS (suma de `length` en `attachments.files`). Implementa, prueba con un usuario que se pasa, y mide el costo de la comprobación. ¿Índice necesario? (Sí: cuál.)
29. Escáner casero: script que recorra tus rutas y reporte las que NO tienen `requireAuth`, las que no validan entrada, y las que hacen `$set` del body completo. Un linter de seguridad para tu propia API — y para la ajena que audites.
30. Pentest de una hora contra tu Mini Jira: cronómetro, sin mirar tu propio código, solo la API. Documenta cada hallazgo como un reporte real (severidad, reproducción paso a paso, impacto, remediación). Al terminar, compara con lo que sabías: ¿encontraste algo que no esperabas?

**🔴 Muy difícil (31–36)**

31. Auditoría del OWASP API Top 10 completo (la lista de 2019, la de la época) endpoint por endpoint, en una matriz: 10 riesgos × N endpoints, con estado y evidencia. Los "no aplica" también se justifican. Es el documento que un cliente enterprise te pediría.
32. Threat model del Mini Jira (STRIDE simplificado): identifica los activos (tickets, credenciales, adjuntos), los actores (reporter, agente, anónimo, atacante externo, insider), y las amenazas por límite de confianza (navegador↔API, API↔Mongo, API↔disco). 2 páginas. Descubrirás amenazas que ninguna checklist te habría dado — por ejemplo, ¿qué puede hacer un agente malicioso *legítimo*?
33. Defensa en profundidad, medida: para la inyección NoSQL, implementa las tres capas y luego **desactívalas de a una** verificando qué ataque pasa con cada combinación. Tabla de 8 filas (2³). El objetivo: entender qué capa te salvaría el día que otra falle por un bug.
34. Seguridad de la operación (cierra la F14): audita el otro lado — ¿Mongo escucha en 0.0.0.0 sin auth? (¡es el default del contenedor!) Activa autenticación de MongoDB (usuarios, roles, `--auth`), crea un usuario de aplicación con permisos mínimos (no root), y actualiza la connection string. Es el hallazgo #1 de los escaneos de internet de 2016–2019: decenas de miles de Mongos abiertos y ransomeados. Que el tuyo no sea uno.
35. Secretos como adultos: saca `JWT_SECRET` del `.env` a un gestor (Docker secrets, o un vault local), implementa la **rotación** (dos secretos válidos durante la transición: firma con el nuevo, verifica con ambos) y demuéstralo sin desloguear a nadie. Es el procedimiento que nadie ensaya hasta que lo necesita.
36. **El cierre de `SECURITY-NOTES.md`** (el entregable final): cada línea heredada del sistema Vue con su veredicto — **pagada** (con el commit/fase que la pagó), **mitigada** (con qué y qué riesgo residual queda), o **viva** (con su justificación, dueño y disparador: "se cierra cuando el frontend mande token en el handshake"). Más las líneas NUEVAS que este apéndice descubrió. El documento que el sistema heredado empezó en su Fase 2, cerrado por ti quince fases después: eso es pagar una deuda técnica de verdad.

---

## 📚 Referencias

**OWASP (la fuente)**

- OWASP API Security Top 10 (2019 — la de la época; y compara con 2023): https://owasp.org/API-Security/editions/2019/en/0x00-header/
- OWASP — Testing for NoSQL Injection: https://owasp.org/www-project-web-security-testing-guide/latest/4-Web_Application_Security_Testing/07-Input_Validation_Testing/05.6-Testing_for_NoSQL_Injection
- OWASP — File Upload Cheat Sheet: https://cheatsheetseries.owasp.org/cheatsheets/File_Upload_Cheat_Sheet.html
- OWASP — Authentication Cheat Sheet: https://cheatsheetseries.owasp.org/cheatsheets/Authentication_Cheat_Sheet.html
- OWASP — JSON Web Token Cheat Sheet: https://cheatsheetseries.owasp.org/cheatsheets/JSON_Web_Token_for_Java_Cheat_Sheet.html
- OWASP — Node.js Security Cheat Sheet: https://cheatsheetseries.owasp.org/cheatsheets/Nodejs_Security_Cheat_Sheet.html

**Documentación oficial**

- MongoDB 4.4 — Security Checklist (el ej. 34 sale de aquí): https://www.mongodb.com/docs/v4.4/administration/security-checklist/
- MongoDB 4.4 — Enable Auth: https://www.mongodb.com/docs/v4.4/tutorial/enable-authentication/
- MongoDB — `$where` y riesgos de scripting: https://www.mongodb.com/docs/v4.4/reference/operator/query/where/
- helmet: https://helmetjs.github.io/
- express-rate-limit: https://github.com/express-rate-limit/express-rate-limit
- express-mongo-sanitize: https://github.com/fiznool/express-mongo-sanitize
- express-validator: https://express-validator.github.io/docs/
- jsonwebtoken (lee la sección de `algorithms`): https://github.com/auth0/node-jsonwebtoken
- bcrypt / bcryptjs: https://github.com/dcodeIO/bcrypt.js

**Lectura de contexto**

- Auth0 — Critical vulnerabilities in JSON Web Token libraries (el `alg: none`, 2015): https://auth0.com/blog/critical-vulnerabilities-in-json-web-token-libraries/
- Las oleadas de ransomware a MongoDB abiertos (2017): busca "MongoDB ransomware 2017" — el contexto del ejercicio 34, y una lección de humildad operativa

**Video (YouTube)**

- NoSQL Injection explained — busca charlas de OWASP/DEF CON sobre "NoSQL injection" (las de 2016–2019 usan exactamente los payloads de este apéndice)
- JWT security best practices — cualquiera de las charlas de Philippe De Ryck

**Orden de lectura sugerido:**
la sección de inyección (ejecuta los 4 ataques ANTES de leer las defensas —
el susto educa) → OWASP API Top 10 2019 completo (una tarde bien invertida) →
la tabla de BOLA con tu API en la mano → el Security Checklist de MongoDB
antes del ejercicio 34 → los cheat sheets como consulta permanente.
