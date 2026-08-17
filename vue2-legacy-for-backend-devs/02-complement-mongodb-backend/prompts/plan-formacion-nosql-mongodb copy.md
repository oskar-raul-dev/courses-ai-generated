# 🍃 Formación no-SQL + MongoDB legacy para backend devs

> **Plan del curso.** Curso autocontenido: no requiere haber tomado ningún otro
> curso. El material entregado incluye todo lo necesario (frontend de
> referencia compilado, fixture de datos, contrato de API). Las decisiones de
> contrato están firmadas en `AUDIT-CONTRATO.md`.

---

## 🎯 El curso en una línea

Enseñar a **razonar en el paradigma no-SQL** a desarrolladores backend con años
de SQL Server / Oracle / PostgreSQL / MySQL, desaprendiendo con criterio:
cuándo el instinto viejo aplica y cuándo hay que suspenderlo. MongoDB
(época 2018–2021, la que vas a heredar) es el tema; Node y Express son el
vehículo.

### El diagnóstico que lo justifica

Un dev con 10 años de Oracle no necesita que le expliquen qué es un índice.
**Ya lo sabe.** Su problema son los instintos formados que en Mongo lo
traicionan: modela normalizado, mete `$lookup` en cada consulta, y concluye
"Mongo es lento y miente". Y tiene razón: *ese* Mongo es lento y miente —
porque no era Mongo, era Postgres con menos garantías.

---

## 🏗️ El escenario (autocontenido)

Te entregan un sistema interno real de época: **Mini Jira**, una mesa de
soporte con dos caras (quien reporta tickets y el agente que los resuelve).

**Lo que recibes con el curso:**

- Un **frontend legacy funcionando** (Vue 2, época 2018–2021). No hace falta
  saber Vue ni tocarlo: es la aplicación cliente que tu backend debe servir,
  como en cualquier trabajo real donde el frontend es de otro equipo.
- Su "backend" actual: un **mock con json-server** y un archivo `db.json` con
  los datos (tickets, users, comments).
- `API-CONTRACT.md` y `SECURITY-NOTES.md`: el contrato que el frontend consume
  y el inventario de todo lo que hoy es teatro de seguridad.

**Tu misión en el curso:** reemplazar el mock por un backend real con MongoDB.
La prueba de éxito es brutal y simple:

> **Cambiar el `baseURL` del frontend y que no se entere.**

### Modelo de datos heredado

`tickets` (title, description, status, priority, assignee, reporter,
createdAt) · `users` (username, name, role: agent|reporter) · `comments`
(ticketId, author, body, createdAt) · adjuntos (nunca fueron reales: el mock
no procesa multipart).

Máquina de estados: `open → in_progress → resolved → closed` (+ reabrir a
`open` desde cualquiera). Hoy **solo el cliente la respeta**.

### 💸 Deudas heredadas que el backend debe pagar

El sistema entregado declara sus vergüenzas por escrito. Cada una tiene fase
de pago:

| Deuda | Fase de pago |
|---|---|
| El token es mock (`"mock-jwt-token-123"`); nadie lo valida | 10 |
| El `reporter` lo inventa el cliente en el payload | 10 |
| Las transiciones de estado solo las respeta el cliente | 10 |
| El guard de roles es teatro (se edita localStorage y listo) | 10 |
| El "cliente mentiroso": quien crea el ticket emite el evento de socket | 11 |
| Doble "tomar": dos agentes toman el mismo ticket, el último PATCH gana en silencio | 6 |
| Las métricas se agregan en el navegador; no existe `GET /stats` | 8 |
| La subida de archivos nunca fue real | 11 |

---

## 🔄 Los 5 cambios de paradigma (columna vertebral)

No son diferencias de sintaxis: son **inversiones de reglas** que el
estudiante lleva una década aplicando bien.

1. **La normalización deja de ser la virtud por defecto.** Se modela por
   patrón de acceso: "¿qué se lee junto y qué cambia junto?". Duplicar tiene
   un precio explícito que se calcula con números de negocio, no con reglas de
   higiene. → Fase 3
2. **El esquema no desaparece: se muda** de la base a la aplicación. → Fase 4
3. **El JOIN ya no es gratis ni es el plan A.** `$lookup` en la consulta
   caliente es un síntoma de modelado. → Fase 5
4. **La transacción existe, pero deja de ser el pegamento.** La unidad natural
   de consistencia es el documento. → Fase 6
5. **El índice sigue siendo el índice** (buenas noticias: aquí tu experiencia
   vale intacta). → Fase 7

---

## 🪜 Las fases

### Fase 0 — 🛠️ Preliminares: instalar, arrancar y tocar Mongo

MongoDB **4.4** corriendo antes de hablar de paradigmas. Camino principal:
Docker con un `docker-compose.yml` **parametrizable por `.env`** (puerto, ruta
física de los datos vía bind mount, flags de `mongod`); caminos alternos
documentados: instalador MSI en Windows (servicio, `mongod.cfg`, `dbPath`) y
Homebrew en macOS. mongosh + Compass + Database Tools. Práctica con una base
de juguete (`playground.personas`): insertar, consultar mínimo, actualizar,
borrar, y el ciclo completo de volcado a disco con `mongoexport`/`mongoimport`
(NDJSON vs `--jsonArray`, Extended JSON reconocido a ojo) — más el **menú de
backup real**: `mongodump`/`mongorestore` con restauración ensayada y la copia
fría del `dbPath` (JSON ≠ backup, dicho desde el día cero). Entregable:
`SETUP.md`, el runbook del entorno.

### Fase 1 — 🍃 Mongo en 30 min para gente que ya sabe bases de datos

Diccionario de traducción (tabla→colección, fila→documento, PK→`_id`/ObjectId),
qué se conserva y qué no. El entorno ya corre desde la Fase 0: aquí se piensa.
Rápido, sin condescendencia. **Cierre práctico:** importar el `db.json` heredado con un
script de seed — primer encuentro con ObjectId sobre un problema real:
retraducir referencias a mano ("la integridad referencial ahora es tu
problema"). Incluye el descarte argumentado de los ids autoincrementales.

### Fase 2 — 🔍 Consultar: tu SQL, traducido

`find` como `SELECT`, operadores, proyección, sort/skip/limit — todo en
**formato espejo SQL↔Mongo**. Trampas: el `NULL` que no es tu `NULL`, tipos no
estrictos. Se consulta la base del Mini Jira ya sembrada en la Fase 1.

### Fase 3 — ⚔️ Embeber vs referenciar: el capítulo que decide todo

**Cambio de paradigma #1.** Los 4 cuadrantes (se lee junto × cambia junto) con
las cuentas hechas sobre Mini Jira: ¿comentarios embebidos? ¿el historial de
estados? — el contraste escritura-intensiva entra aquí con el bucket pattern.
Patrones canónicos (subset, extended reference, computed, bucket). Límite de
16 MB y arrays sin techo. Corolario incómodo dicho en voz alta: si todo es
escritura y todo cambia junto, Mongo no era la respuesta. **Primera aparición
del anti-patrón ⚰️:** se presenta la base "Postgres disfrazado" y se mide su
dolor.

### Fase 4 — 🧬 El esquema que no está en la base

**Cambio #2.** Documentos de 3 versiones conviviendo en la misma colección, no
hay `ALTER TABLE`. Migraciones perezosas vs masivas, `schemaVersion`, JSON
Schema Validation — el `CHECK` que creías perdido.

### Fase 5 — 🔗 `$lookup` y por qué es una alarma

**Cambio #3.** `$lookup` existe pero no es un join: sin optimizador, sin hash
join, sin estadísticas. Se enseña, se mide contra el modelo embebido, se da la
regla: legítimo en el reporte nocturno, síntoma de modelado en el endpoint
caliente. Denormalización deliberada y qué hacer cuando se desincroniza
(porque se va a desincronizar). **Segunda visita al anti-patrón ⚰️:** el
dashboard con `$lookup`, cronómetro en mano.

### Fase 6 — ⚛️ Atomicidad del documento, transacciones y consistencia

**Cambio #4.** El documento como unidad natural de consistencia (su escritura
atómica es el premio de haber embebido bien). `$inc`/`$push`/
`findOneAndUpdate`, write/read concern, transacciones multi-doc donde de
verdad tocan. **Optimistic locking vía update condicional** — el doble "tomar"
se resuelve con `findOneAndUpdate({ _id, assignee: null })` porque el contrato
prohíbe pedirle al frontend un campo de versión: la restricción empuja al
patrón idiomático. Responde `409` (extensión pactada).

### Fase 7 — ⚡ Índices: donde tu experiencia SQL vale intacta

**Cambio #5.** `explain()` como tu `EXPLAIN PLAN`, collection scan = full
table scan, compuestos y prefijo izquierdo como en Oracle, la selectividad
manda igual. Lo nuevo: **multikey** (sobre arrays — lo que hace viable
embeber), anidados, parciales, TTL, regla ESR. **Capítulo deliberadamente
reconfortante** tras cuatro fases de cuestionar certezas. **Tercera visita al
anti-patrón ⚰️:** los índices no lo salvan — el índice no arregla el modelo.

### Fase 8 — ⚰️ La autopsia

El clímax del anti-patrón. Rediseño completo de la base mal modelada aplicando
los 5 paradigmas, re-medición, veredicto numérico antes/después. Corto, sin
teoría nueva: es el examen práctico de las fases 3–7, y el ejercicio que más
se parece a lo que van a heredar.

### Fase 9 — 🧮 Aggregation: tu GROUP BY con esteroides

Pipeline (etapas) vs SQL (declarativo). `$match`/`$group`/`$project`/
`$unwind`/`$facet`. Traducciones desde `GROUP BY`/`HAVING`/window functions.
Deja escrita la lógica del futuro `GET /stats` (deuda 💸: hoy las métricas se
calculan en el navegador).

### Fase 10 — 🚂 Express: el vehículo (sin ceremonia)

Capas (routes→controller→service→model), middlewares, errores, códigos HTTP —
explícitamente rápido: "esto ya lo sabes en otro lenguaje". **Todo con driver
nativo** (Mongoose todavía no: el momento mágico no se contamina con dos
novedades). Implementa el dialecto json-server (`?q=`, `?_sort=`/`?_order=`) y
el mapeo `_id → id` en la frontera, defendido por escrito. **El momento
mágico: json-server apagado, frontend vivo.** Smoke test del contrato
(checklist en `AUDIT-CONTRATO.md`). `git diff` del frontend: una línea.

### Fase 11 — 🔐 Auth real y el pago de deudas

Abre con el **refactor a Mongoose 5** — el regalo de las 8 líneas, ahora que
ya se hizo a mano. bcrypt, JWT firmado, `req.user`, roles server-side.
**Inyección NoSQL** (`{$ne: null}` en un login mal hecho: el instinto
anti-inyección apunta a comillas y aquí el ataque es un *objeto*). Aquí la
regla pasa de "no se entera" a **"el contrato crece, no se rompe"**:
`POST /auth/login` es la única ruptura admitida y anunciada. Se tachan las 💸
de token mock, `reporter` inventado, transiciones client-side y guard de roles
de teatro. `SECURITY-NOTES.md` empieza a tacharse.

### Fase 12 — 🔌 El backend habla

El servidor emite los eventos de socket tras persistir (muere el relé tonto y
el cliente mentiroso — mismo evento, mismo payload, distinto emisor). multer +
GridFS para los adjuntos que nunca fueron reales (`POST /attachments`,
multipart). socket.io 2.4 obligatorio: 2.x y 3.x no se hablan.

### Fase 13 — 🧪 Testing de API

Jest + supertest + mongodb-memory-server. Qué se testea en cada capa y por
qué; la testeabilidad como detector de diseño.

### Fase 14 — 🛠️ Operación: lo que un dev SQL sí extraña

`mongodump`/`mongorestore`, migraciones, índices en producción sin bloquear,
**el profiler de queries lentas = tu Slow Query Log**, docker-compose final.

### Fase 15 — ⚖️ El veredicto honesto: ¿debías haber usado Mongo?

La conversación que ningún tutorial tiene. Cuándo fue elección correcta y
cuándo fue moda de 2015; cómo diagnosticar cuál de las dos fue tu legacy; qué
hacer si la respuesta es "moda" (spoiler: no siempre es migrar). Cierra con
`INSTINTOS.md` completo como checklist de la promesa del curso.

---

## 🧰 Recursos didácticos transversales (en todas las fases)

- **📖 Diccionario de traducción siempre visible** — cada consulta primero en
  SQL, después su gemela Mongo.
- **🪞 "Tu instinto dice… y esta vez se equivoca"** — nombra la intuición SQL
  antes de que falle; donde se pueda, como **predicción falsable que se mide**.
- **🩻 "Esto SÍ funciona igual"** — índices, `explain`, selectividad, paranoia
  N+1: viajan intactos. El curso no es "olvida todo lo que sabes".
- **⚰️ El anti-patrón** — transversal (fases 3, 5, 7) con clímax en la Fase 8.
- **📓 `INSTINTOS.md`** — entregable-documento: el estudiante acumula fase a
  fase cada 🪞 con su veredicto medido. Materializa la promesa del curso.

---

## 📐 Formato de cada fase

1. 🎯 Propósito
2. ✅ Qué queda listo al terminar
3. 🚫 Qué NO entra todavía
4. 🧠 Concepto mínimo — con 🪞 y 🩻
5. 💻 Código mínimo con bloques **🔎 Qué hace** y **✅ Buenas prácticas**
6. 🔄 Flujos paso a paso (evento por evento)
7. 🧩 Chuleta de la fase
8. ⚠️ Errores comunes
9. 🧪 **30–40 ejercicios graduados** 🟢🟡🟠🔴, balanceados y cubriendo todo el
   tema de la fase (apéndices: 30–50 con ≥10 muy difíciles; todo apéndice es
   opcional)
10. 📚 **Referencias** — doc oficial de la versión exacta primero (manual
    MongoDB 4.4, driver Node 3.6, Express 4.17, Mongoose 5, socket.io 2.x),
    luego material de apoyo, con orden de lectura sugerido para perfil senior
11. 🚀 Cierre con puente a la siguiente fase

**Tono:** informal, emojis, directo, sin condescendencia — el estudiante es
senior en otra cosa. Deudas 💸 declaradas con su fase de pago. Decisiones de
arquitectura defendidas por escrito. Entregables-documento: `SETUP.md`,
`DATA-MODEL.md`, `SECURITY-NOTES.md`, `INSTINTOS.md`, `MODERNIZATION.md`.

---

## 🧱 Stack (época 2018–2021)

| Pieza | Versión | Nota |
|---|---|---|
| Node | 14.21.3 | `.nvmrc` incluido |
| MongoDB | **4.4** | Docker `mongo:4.4` |
| driver `mongodb` | 3.6.x | **fases 1–9: driver nativo, sin ODM** |
| Mongoose | 5.x | entra en la **Fase 11** como refactor |
| Express | 4.17.x | |
| jsonwebtoken / bcryptjs | 8.5.x / 2.4.x | |
| socket.io | 2.4.1 | emparejado con el cliente del frontend entregado |
| multer | 1.4.x | multipart |
| express-validator | 6.x | |
| cors, morgan, helmet, dotenv | — | kit mínimo |
| Jest + supertest + mongodb-memory-server | — | testing |
| Compass / mongosh | — | diagnóstico diario |

**Pedagogía del stack:** primero a mano, después el wrapper — driver nativo
antes que Mongoose, para que las 8 líneas se sientan regalo y no magia opaca.

---

## 📎 Apéndices (opcionales, 30–50 ejercicios c/u)

1. 🐳 Docker mínimo — imagen, contenedor, volumen, compose. Sin Kubernetes.
2. 🍃 mongosh / Compass a fondo.
3. 🚂 Express a fondo — el pipeline de middlewares y el `next()` que todos
   olvidan.
4. 🔑 Seguridad backend — OWASP aplicado: inyección NoSQL, rate limiting,
   helmet, secretos.
5. ⚖️ Mongo vs SQL, la conversación honesta — profundiza la Fase 15.

---

## 🎯 La promesa del curso

> "Puedo mirar un esquema Mongo ajeno y decir en cinco minutos si fue
> **diseñado** o si fue **traducido de un modelo relacional por alguien que no
> quiso pensarlo**. Y si es lo segundo, sé qué duele, por qué, y qué haría
> distinto."
