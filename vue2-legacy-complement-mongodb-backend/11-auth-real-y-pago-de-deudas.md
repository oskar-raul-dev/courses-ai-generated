# 🔐 Fase 11 — Auth real y el pago de deudas

## 🎯 Propósito

El backend de la Fase 10 funciona y es un ingenuo total: cree cualquier token,
acepta cualquier `reporter` que el cliente invente, permite cualquier
transición de estado, y su idea de "roles" es lo que el navegador diga. Es
exactamente igual de crédulo que el mock que enterró — **a propósito**:
paridad primero. Hoy se acaba.

Esta fase hace tres cosas entrelazadas:

1. **Mete Mongoose** — el regalo de las 8 líneas, ahora que hiciste todo a
   mano y puedes apreciarlo (y auditarlo) en vez de sufrirlo como magia.
2. **Auth de verdad** — bcrypt, JWT firmado, `req.user`, roles server-side,
   y la inyección NoSQL (donde tu instinto anti-SQL-injection apunta al lugar
   equivocado).
3. **Cobra `SECURITY-NOTES.md`** — el documento vivo que el curso heredado
   arrastró desde el arranque sin cobrarse: token mock, `reporter` inventado, transiciones
   client-side, guard de roles de teatro. Se tachan uno por uno.

Y aquí el régimen del contrato cambia oficialmente: de "no se entera" a **"el
contrato crece, no se rompe"** — con `POST /auth/login` como la única ruptura
admitida y anunciada (`AUDIT-CONTRATO.md`).

---

## ✅ Qué queda listo al terminar

- Mongoose 5 conviviendo con el driver: modelos con schema, y el criterio de
  qué migrar y qué dejar en driver nativo (no es "todo a Mongoose");
- contraseñas con bcrypt (nunca en claro, nunca reversibles);
- `POST /auth/login` que emite un JWT firmado real; middleware `authenticate`
  que lo verifica y puebla `req.user`;
- autorización por rol server-side (`agent` vs `reporter`) y por pertenencia
  (solo el assignee resuelve);
- el `reporter` tomado del token, no del body — deuda 💸 pagada;
- las transiciones validadas server-side con la primitiva de la Fase 6 —
  deuda 💸 pagada;
- inyección NoSQL entendida y bloqueada (el ataque es un objeto, no una
  comilla);
- `SECURITY-NOTES.md` con cuatro deudas tachadas y las notas de lo que aún
  falta para producción real.

## 🚫 Qué NO entra todavía

- refresh tokens, rotación, revocación con blacklist (se discuten; se
  implementa el access token — el refresh es ejercicio 🔴);
- OAuth, SSO, MFA (fuera de alcance; se nombran en Fase 15);
- los sockets autenticados y los adjuntos (Fase 12 — pero el token ya estará
  listo para ellos);
- rate limiting y hardening completo (Apéndice 4; aquí solo lo esencial de
  auth).

---

## 🎁 Mongoose: el regalo, ahora que sabes qué envuelve

Ocho fases con driver nativo te dieron algo que el que empieza por Mongoose
nunca tiene: **sabes qué hace por debajo**. Ahora el azúcar se disfruta sin
adicción.

```js
// src/models/User.js
const mongoose = require("mongoose");

const userSchema = new mongoose.Schema({
  username: { type: String, required: true, unique: true },
  name:     { type: String, required: true },
  role:     { type: String, enum: ["agent", "reporter"], required: true },
  passwordHash: { type: String, required: true }
}, { timestamps: true });   // createdAt/updatedAt automáticos — lo que hiciste a mano en F4

module.exports = mongoose.model("User", userSchema);
```

🔎 **Qué te regala:** el `enum`, el `required`, el `unique`, y `timestamps`
son exactamente el JSON Schema Validation de la Fase 4 y el `updatedAt` de la
migración de la Fase 4 — pero declarados en 8 líneas. **Lo que un cerebro SQL
debe grabar:**

> ### 🪞 Tu instinto dice… "el schema de Mongoose ES el esquema de la base"
>
> **Predicción falsable:** "con Mongoose validando, ya no necesito el
> validator del motor (Fase 4): sería redundante".
>
> Peligrosísimo. Mongoose valida **en tu proceso Node**. Un script de
> migración con el driver, mongosh, otro microservicio, el becario con
> Compass — todos escriben saltándose Mongoose por completo. El validator del
> **motor** (Fase 4) aplica a TODOS; el de Mongoose, solo a quien pase por
> tu app. No son redundantes: son **dos anillos de defensa a distinta
> distancia**. El de Mongoose da errores tempranos y lindos; el del motor es
> la última muralla. **Veredicto: el instinto se equivoca — el schema de la
> app no sustituye al de la base.** 📓 A `INSTINTOS.md`. (Y por eso NO
> borramos los validators de la Fase 4.)

**El criterio de qué migrar a Mongoose:** los modelos con reglas ricas y
mucho tráfico de app (User, y opcionalmente Ticket) ganan con Mongoose. Los
scripts de migración, el seed, la analítica de `stats` y las operaciones
atómicas finas (`takeTicket` con su `findOneAndUpdate` condicional) **se
quedan en driver nativo** — Mongoose ahí estorba o esconde lo que necesitas
controlar. Coexisten sobre la misma conexión. Ejercicio 8 documenta la
frontera.

---

## 🔑 Contraseñas: bcrypt y nada más

El `db.json` heredado tenía usuarios sin contraseña (el login era mock). La
migración de auth les pone una:

```js
const bcrypt = require("bcryptjs");

// En el seed de usuarios / registro:
const passwordHash = await bcrypt.hash(plainPassword, 10);  // 10 rounds, época-correcto

// En login:
const ok = await bcrypt.compare(plainPassword, user.passwordHash);
```

🔎 bcrypt es lento **a propósito** (el "cost factor" 10 = 2¹⁰ iteraciones):
hace inviable el fuerza-bruta. Nunca se guarda la contraseña; nunca se puede
"recuperar" (solo resetear). El salt va incrustado en el hash — no gestionas
salts a mano. Tu instinto de "nunca guardar credenciales en claro" (🩻
intacto) por fin tiene su herramienta canónica.

> ⚠️ Y el `passwordHash` **jamás** cruza la frontera de serialización (Fase 10):
> el serializer de user nunca lo incluye. El ejercicio 25 lo testea con saña
> — una fuga de hashes es el titular de prensa de la época.

---

## 🎫 JWT firmado de verdad (adiós al `"mock-jwt-token-123"`)

```js
// src/lib/auth.js
const jwt = require("jsonwebtoken");
const config = require("../config");

function sign(user) {
  return jwt.sign(
    { sub: user.username, role: user.role, name: user.name },  // claims
    config.jwtSecret,                                          // el secreto (env!)
    { expiresIn: "8h" }   // 8h para el curso; en el ej. 22 lo bajas a 30s para ver el 401
  );
}

function verify(token) {
  return jwt.verify(token, config.jwtSecret);  // lanza si firma inválida o expiró
}
```

```js
// POST /auth/login — LA ruptura pactada (única, anunciada, firmada)
async function login(req, res, next) {
  try {
    const { username, password } = req.body;
    const user = await User.findOne({ username });   // ⚠️ ver inyección NoSQL abajo
    if (!user || !(await bcrypt.compare(password, user.passwordHash))) {
      return res.status(401).json({ error: "Credenciales inválidas" });
      // mismo mensaje para "no existe" y "clave mala": no filtres cuál falló
    }
    res.json({ token: sign(user), user: serializeUser(user) });
  } catch (err) { next(err); }
}
```

```js
// src/middleware/authenticate.js — el guard REAL (vs el teatro heredado)
const { verify } = require("../lib/auth");

module.exports = function authenticate(req, res, next) {
  const header = req.headers.authorization || "";
  const token = header.startsWith("Bearer ") ? header.slice(7) : null;
  if (!token) return res.status(401).json({ error: "Token ausente" });
  try {
    req.user = verify(token);   // { sub, role, name } — la fuente de verdad del backend
    next();
  } catch (err) {
    return res.status(401).json({ error: "Token inválido o expirado" });
  }
};
```

La diferencia con el guard heredado es toda la fase en una frase: **el
frontend tenía un token que nadie verificaba y roles que él mismo se
otorgaba; ahora el backend firma, verifica y decide.** El `Bearer` que el
interceptor de axios ya mandaba (Fase 2 del curso heredado) por fin le habla
a alguien que lo escucha.

> 📝 **El interceptor heredado ya estaba listo:** el frontend adjunta
> `Authorization: Bearer <token>` desde su Fase 2. Por eso `authenticate` NO
> rompe el contrato: el header ya viajaba. Lo único que cambia para el
> frontend es que ahora `POST /auth/login` devuelve un token real en vez de
> fabricarlo el cliente — la ruptura pactada, y el frontend ya devolvía una
> Promise en su login (heredado, Fase 2, ej. 18), así que el terreno estaba
> preparado.

---

## 💉 Inyección NoSQL: donde tu instinto apunta mal

Llevas años defendiéndote de `' OR 1=1 --`. Ese ataque **no existe** aquí (no
hay SQL que envenenar). Pero hay uno gemelo que tu reflejo no ve venir:

```js
// El login espera username y password como STRINGS. ¿Y si el cliente manda?
//   POST /auth/login   { "username": "admin", "password": { "$ne": null } }

// Tu código:  User.findOne({ username, password })  ← si compararas password directo
//   se convierte en:  { username: "admin", password: { $ne: null } }
//   → "cualquier admin cuya password no sea null" → LOGIN SIN CONTRASEÑA 💀
```

> ### 🪞 Tu instinto dice… "sanitizo comillas y estoy a salvo de inyección"
>
> **Predicción falsable:** "escapando comillas y caracteres especiales, la
> inyección queda muerta como en SQL".
>
> El ataque NoSQL no es un string malicioso: es un **objeto** malicioso. No
> hay comilla que escapar — hay un `{ $ne: null }` donde esperabas un string.
> Escapar caracteres no hace nada contra esto. Las defensas reales:
> (1) **validar tipos** (express-validator: `username` y `password` DEBEN ser
> string — un objeto se rechaza antes de tocar Mongo); (2) nunca comparar la
> contraseña como campo de query (se compara el hash con bcrypt, fuera del
> filtro); (3) castear explícitamente lo que va a un filtro. **Veredicto: el
> instinto correcto (desconfiar del input) apunta al mecanismo equivocado
> (comillas) — el vector cambió de forma.** 📓 A `INSTINTOS.md`, y a
> `SECURITY-NOTES.md` como amenaza nueva del paradigma.

---

## 🧹 Las deudas, tachadas una por una

### 💸 → ✅ El `reporter` inventado por el cliente

```js
// ANTES (F10, paridad con el mock): reporter salía del body. Cualquiera reportaba como cualquiera.
// AHORA: el reporter es QUIÉN ESTÁS AUTENTICADO SIENDO.
async function create(req, res, next) {
  const ticket = await service.create({
    ...whitelist(req.body, ["title", "description", "priority"]),
    reporter: req.user.sub,       // ⬅️ del token, no del body. Innegociable.
    status: "open", createdAt: new Date(), history: []
  });
  res.status(201).json(serializeTicket(ticket));
}
```

### 💸 → ✅ El guard de roles de teatro

```js
// src/middleware/authorize.js
function requireRole(role) {
  return function (req, res, next) {
    if (req.user.role !== role) return res.status(403).json({ error: "Prohibido" });
    next();
  };
}
// En las rutas: solo agentes toman/transicionan/comentan-como-agente
router.patch("/:id", authenticate, requireRole("agent"), ctrl.patch);
```

Editar el `localStorage` ya no otorga nada: el rol vive en el token firmado,
que el cliente no puede forjar sin el secreto.

### 💸 → ✅ Las transiciones solo respetadas por el cliente

```js
// La máquina de estados, server-side, sobre la primitiva atómica de la Fase 6.
const LEGAL = {
  open: ["in_progress"], in_progress: ["resolved", "open"],
  resolved: ["closed", "open"], closed: ["open"]
};

async function changeStatus(db, ticketId, to, byUser) {
  const ticket = await getById(ticketId);
  if (!ticket) return { notFound: true };
  if (!LEGAL[ticket.status].includes(to))
    return { illegal: true, from: ticket.status, to };
  // precondición en el filtro (F6): el estado no cambió bajo nuestros pies
  const result = await db.collection("tickets").findOneAndUpdate(
    { _id: ticketId, status: ticket.status },     // ⬅️ optimistic: status esperado
    { $set: { status: to, updatedAt: new Date() },
      $push: { history: { from: ticket.status, to, by: byUser, at: new Date() } } },
    { returnOriginal: false }
  );
  if (!result.value) return { conflict: true };   // alguien transicionó primero → 409
  return { ok: true, ticket: result.value };
}
```

Las tres deudas de estado convergen: la transición es **legal** (máquina de
estados server-side), **atómica** (findOneAndUpdate), **sin carrera**
(precondición del status en el filtro) y **atribuida** (el `by` sale de
`req.user`, no del body). La Fase 6 forjó la primitiva; la Fase 11 le pone
las reglas y el guardia.

---

## 🧩 Chuleta de la fase

```
Mongoose: schema con enum/required/unique/timestamps = la F4 en 8 líneas
  PERO no reemplaza el validator del MOTOR (dos anillos, distinta distancia)
  Coexiste con driver nativo: modelos ricos → Mongoose · atómico/scripts → driver

bcrypt.hash(pwd, 10) al guardar · bcrypt.compare al login · hash NUNCA sale
JWT: sign(claims, secret, {expiresIn}) · verify lanza · secret en env
authenticate → req.user (la verdad del backend) · requireRole(r) → 403

Inyección NoSQL: el ataque es un OBJETO ({$ne:null}), no una comilla
  → valida TIPOS (express-validator) · nunca password en el filtro

Deudas tachadas: reporter del token · roles server-side · transiciones
  legales+atómicas+atribuidas · token verificado
Régimen: "el contrato CRECE, no se rompe" · POST /auth/login = la ruptura pactada
```

---

## ⚠️ Errores comunes

- Creer que Mongoose reemplaza el validator del motor (el 🪞 de la fase).
- Migrar `takeTicket`/`changeStatus` a Mongoose y perder el control fino del
  `findOneAndUpdate` condicional (déjalos en driver).
- `password` o `passwordHash` cruzando la frontera de serialización.
- El secreto JWT hardcodeado en el código (va en env, y el `.env` al
  gitignore — Fase 0 cobrando otra vez).
- Mensajes de login que distinguen "usuario no existe" de "clave incorrecta"
  (regalo para el atacante que enumera usuarios).
- Validar `username`/`password` sin exigir que sean **string** (la puerta de
  la inyección NoSQL).
- Tomar `reporter`/`by`/rol de cualquier fuente que no sea `req.user`.
- Poner `requireRole` antes de `authenticate` (no hay `req.user` todavía:
  orden de middlewares, tu pipeline de siempre).
- Borrar los validators de la Fase 4 "porque ahora hay Mongoose".

---

## 🧪 Ejercicios (25)

**🟢 Fácil (1–8)**

1. Instala Mongoose 5, conéctalo sobre la MISMA conexión/URI del driver, y crea el modelo `User` del capítulo. Verifica que lee los usuarios que el driver sembró (coexistencia demostrada).
2. Migración de contraseñas: script que asigne a cada usuario del seed un `passwordHash` de bcrypt (contraseña = username + "123", solo para el curso). Idempotente (Fase 4).
3. `POST /auth/login` completo: 200 + token + user con credenciales buenas, 401 con malas. Curl a ambos. Luego decodifica el token en jwt.io (solo el payload, sin el secreto): ¿qué claims viajan? ¿Hay algo que NO debería estar ahí (dato sensible)?
4. Middleware `authenticate`: protégelo sobre `GET /tickets` y verifica los tres casos (sin token 401, token basura 401, token válido 200). Después `requireRole("agent")` sobre `PATCH /tickets/:id`: loguéate como reporter e intenta editar (403), como agente pasa.
5. El serializer de user: confirma con curl que `passwordHash` NO aparece en ninguna respuesta de `/users` ni en el `user` del login.
6. Documenta la frontera Mongoose/driver: tabla de qué componente usa cuál y por qué. A `SECURITY-NOTES.md` o `DATA-MODEL.md`.
7. Tacha en `SECURITY-NOTES.md` la primera deuda (token mock) con el commit que la resolvió referenciado. El ritual importa.
8. El interceptor heredado, verificado: confirma en el frontend que el `Bearer` ya viajaba desde su Fase 2 y que ahora tu backend lo lee (una request en Network con el header presente: captura). Y verifica que el mensaje de login es uniforme: "usuario inexistente" y "clave mala" devuelven EXACTAMENTE el mismo 401; si no, arréglalo.

**🟡 Intermedio (9–18)**

9. La ruptura pactada, ejecutada: conecta el login del frontend a `POST /auth/login` real (la función del `authService.js` heredado que devuelve Promise). Verifica el flujo completo: login → token guardado → requests autenticadas → logout. Documenta el `git diff` del frontend (ahora son más de una línea — y está BIEN: régimen "el contrato crece").
10. Demuestra la inyección NoSQL: ANTES de defenderte, manda `{ username: "admin", password: { $ne: null } }` a un login escrito ingenuamente (compara password en el filtro). ¿Entraste sin contraseña? Documenta el horror. Luego defiéndete: express-validator que exija `username` y `password` string no vacíos; repite el ataque (ahora 400) y explica las dos defensas (tipo + hash fuera del filtro) en `SECURITY-NOTES.md`.
11. El `reporter` del token: paga la deuda (capítulo). Ataca el endpoint viejo (reporter en body) y el nuevo (reporter del token) con un reporter falso: demuestra que el nuevo lo ignora. Tacha la deuda.
12. Roles server-side: define quién puede qué (agente: toma, transiciona, comenta; reporter: crea, comenta en lo suyo, ve). Implementa los guards. Tabla de permisos a `SECURITY-NOTES.md`.
13. La máquina de estados server-side (capítulo): impleméntala y prueba las 4 transiciones legales + 3 ilegales (incluida `closed→resolved`). Legal: 200. Ilegal: 400/409 según corresponda. Tacha la deuda.
14. El 409 de transición: dos agentes transicionan el mismo ticket concurrentemente (adapta el duelo de la F10). Exactamente uno gana; el otro recibe 409 porque su `status` esperado ya no matchea. La precondición de la Fase 6, ahora con reglas.
15. Autorización por pertenencia: solo el `assignee` puede resolver SU ticket (no cualquier agente). Añade la comprobación con `req.user.sub`. Prueba el caso cruzado: agente A intenta resolver el ticket de agente B → 403.
16. Refresh de la deuda de guard de roles: en el frontend, edita el `localStorage` para "ser agente" e intenta una acción de agente. Ahora el backend te rechaza (403) aunque el frontend te deje pulsar el botón. El teatro, cancelado. Captura del 403.
17. Config de secreto y expiración: `jwtSecret` desde env, fail-fast si falta al arrancar (genera un secreto decente, no "secret"). Luego pon `expiresIn: "30s"`, loguéate, espera, y verifica que la siguiente request da 401; el interceptor de respuesta heredado (F2 ej. 23) ¿limpia sesión y redirige? Documenta por qué el token deja de valer si rotas el secreto (y qué implica para sesiones activas).
18. Coexistencia sin fugas: confirma que `takeTicket` y `changeStatus` siguen en driver nativo (no Mongoose) y siguen atómicos. Corre el torture de la Fase 6 sobre ellos con auth activa: las invariantes se mantienen.

**🟠 Difícil (19–25)**

19. Registro (`POST /auth/register`) con rol: solo un `agent` marcado como admin (username, no rol nuevo — el enum sigue siendo `agent`/`reporter`) puede crear agentes; los reporters se autorregistran. Hashea, valida unicidad (el `unique` de Mongoose + el índice del motor — dos anillos), maneja el `E11000` como 409. ¿Extensión o ruptura? Clasifícalo en el audit.
20. Auditoría de fugas de auth: script que loguee con cada rol y recorra TODOS los endpoints, verificando que ninguna respuesta filtra `passwordHash`, secretos, o datos de otros usuarios que el rol no debería ver. Cero tolerancia, integrado a `npm run smoke`.
21. El middleware `authorize` genérico: en vez de `requireRole` suelto, una tabla declarativa `{ "PATCH /tickets/:id": ["agent"], ... }` y un solo middleware que la consulta. Refactoriza. La autorización como dato, no como código disperso.
22. Rate limit del login (anti fuerza-bruta): `express-rate-limit` solo en `/auth/login`, 5 intentos / 15 min por IP. Verifica el 429. Discute lo que NO resuelve (ataque distribuido) y apunta a Fase/Apéndice.
23. Inyección NoSQL en el `?q=` y filtros: ¿puede un `?status[$ne]=closed` (Express parsea `[]` a objeto) colarse a tu filtro? Pruébalo contra tu `GET /tickets` de la Fase 10. Si pasa, es una vulnerabilidad real de la época — defiéndete casteando query params a string. (Este es de los buenos: el vector menos obvio.)
24. `SECURITY-NOTES.md` de cierre parcial: tacha las 4 deudas de esta fase con evidencia (ataque que antes funcionaba, request que ahora lo bloquea). Y escribe la sección "lo que AÚN falta para producción": refresh/revocación, HTTPS obligatorio, secretos en un vault, auditoría de accesos, rate limit distribuido. La honestidad de siempre.
25. La frontera Mongoose vs driver, estresada: elige UNA operación que hiciste en driver y reescríbela en Mongoose; mide si perdiste control (¿puedes hacer el `findOneAndUpdate` condicional igual de limpio?) o rendimiento. Decide con datos si la frontera del ej. 6 estaba bien trazada o hay que moverla.

**🔥 Opcionales (sin numeración — los de integración profunda)**

- 🔥 Refresh tokens completos: access token corto (15 min) + refresh token largo (7 días) en colección `refreshTokens` con rotación (cada uso invalida el anterior) y revocación (logout borra). Reimplementa el interceptor del frontend para renovar transparente. El sistema de sesión que 2021 consideraba serio.
- 🔥 JWT sin librería (para entenderlo): firma y verifica un HS256 a mano con `crypto.createHmac` (base64url de header.payload, HMAC del secreto). Compara tu token con el de `jsonwebtoken`: ¿idénticos? Documenta la anatomía. (Conecta con el "JWT falso" de la Fase 2 del curso heredado — ahora lo haces DE VERDAD.)
- 🔥 Autorización a nivel de dato (row-level): un reporter solo ve SUS tickets (`reporter: req.user.sub`) y los comentarios de esos. Implementa el filtrado automático en el service según `req.user`, sin que cada controller lo repita. ¿Dónde vive esa regla para no esparcirla? (Middleware que inyecta el filtro base, o service consciente del usuario — decide y defiende.)
- 🔥 El pentest de tu propia API: escribe `scripts/pentest.js` que intente sistemáticamente: inyección NoSQL en cada endpoint, escalada de rol, acceso a datos ajenos, reporter/by falsificados, token de otro usuario, token expirado, token con claims manipulados (sin re-firmar). Reporte tipo informe de seguridad. Cada ataque bloqueado, con el status que lo bloqueó. Es la promesa del curso en modo ofensivo.
- 🔥 Migración de auth sin downtime (el escenario real): tienes usuarios activos con el token mock viejo en su localStorage. ¿Cómo despliegas auth real sin desloguear a todos de golpe? Diseña la estrategia (¿periodo de gracia aceptando ambos? ¿forzar re-login?), sus riesgos, y qué avisa al usuario. Una página; conecta con el régimen del audit y con la Fase 14.
- 🔥 **El ensayo de la fase** (1 página, `INSTINTOS.md` + cierre de `SECURITY-NOTES.md`): "El backend es el único que no miente". Tesis: en el sistema heredado, cada garantía de seguridad vivía en el cliente — es decir, en manos del atacante; auth real no es "agregar login", es **mover la frontera de confianza** del navegador al servidor, y el `reporter` del token es esa mudanza en miniatura. Usa los ataques que documentaste (ej. 10, 16, 23 y el pentest) como evidencia. Cierra con el inventario final: qué garantiza ahora el backend que antes fingía el frontend, y qué sigue siendo teatro incluso hoy.

---

## 📚 Referencias

**Documentación oficial (versiones de época)**

- Mongoose 5 — Guide (schemas, models, validation): https://mongoosejs.com/docs/5.x/docs/guide.html
- Mongoose 5 — Validation: https://mongoosejs.com/docs/5.x/docs/validation.html
- jsonwebtoken (8.5.x): https://github.com/auth0/node-jsonwebtoken
- bcryptjs: https://github.com/dcodeIO/bcrypt.js
- express-validator 6.x: https://express-validator.github.io/docs/
- MongoDB — NoSQL Injection (defensa oficial): https://www.mongodb.com/docs/v4.4/faq/fundamentals/#how-does-mongodb-address-sql-or-query-injection-
- JWT — Introduction: https://jwt.io/introduction

**Seguridad (léelas, son la fase)**

- OWASP — NoSQL Injection: https://owasp.org/www-community/Injection_Flaws
- OWASP — Authentication Cheat Sheet: https://cheatsheetseries.owasp.org/cheatsheets/Authentication_Cheat_Sheet.html
- OWASP — JWT Cheat Sheet: https://cheatsheetseries.owasp.org/cheatsheets/JSON_Web_Token_for_Java_Cheat_Sheet.html
- OWASP — Password Storage (por qué bcrypt y qué cost): https://cheatsheetseries.owasp.org/cheatsheets/Password_Storage_Cheat_Sheet.html

**Video (YouTube)**

- JWT Authentication con Node/Express — Web Dev Simplified: https://www.youtube.com/watch?v=mbsmsi7l3r4
- NoSQL Injection — PwnFunction / cualquier charla de la época sobre `$ne`/`$gt` en login: busca "NoSQL injection explained"
- bcrypt explicado — Fireship (password hashing en 100s)

**Orden de lectura sugerido para perfil senior:**
NoSQL Injection de OWASP (te va a abrir los ojos: tu instinto apuntaba mal) →
Mongoose 5 Validation (corto, y confirma que NO reemplaza al motor) → JWT
Introduction → Password Storage de OWASP → implementar con `SECURITY-NOTES.md`
al lado, tachando → el pentest (ej. 34) como examen final.

---

## 🚀 Cierre

Al final de esta fase el backend dejó de ser crédulo: firma y verifica
tokens, hashea contraseñas, decide roles y pertenencia server-side, toma el
`reporter` de quien de verdad eres, y solo permite transiciones legales,
atómicas y atribuidas. La inyección NoSQL — el ataque que tu instinto SQL no
veía — está entendida y bloqueada. Mongoose entró con criterio, sin desalojar
al driver de donde el control fino importa, y sin tocar los validators del
motor. Y `SECURITY-NOTES.md`, que esperó sin cobrarse desde el arranque, tiene
cuatro tachones y una lista honesta de lo que aún falta.

La señal de que quedó bien:

> "cada garantía de seguridad que el frontend fingía, ahora la hace cumplir
> el backend — y cuando veo un `reporter` o un rol que viene del body,
> siento el mismo escalofrío que ante un `WHERE` construido por concatenación
> de strings".

**Siguiente parada:** 🔌 Fase 12 — El backend habla. Quedan dos mentiras del
sistema heredado: el "cliente mentiroso" que emite sus propios eventos de
socket (cualquiera puede inventar un ticket falso) y los adjuntos que nunca
existieron. El servidor tomará la palabra: emitirá los eventos tras
persistir, y GridFS hará reales los archivos.
