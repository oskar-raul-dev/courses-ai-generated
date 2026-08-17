# 📋 Instrucciones del Proyecto — Track B: MongoDB para cerebros SQL

> **Estado:** curso ya redactado (16 fases + 5 apéndices existen en disco). Esta
> fase del proyecto **no es escribir de cero**, es **revisar y alinear** Track B
> a la última versión de Track A: contratos de API, continuidad, estilo y regla
> de idioma del código. Estas instrucciones reemplazan a la versión anterior
> (la del esquema "B0–B13", que ya no corresponde a los archivos reales).

---

## 🎯 Resumen ejecutivo

Track B es un curso de **MongoDB 4.4 + Express/Node 14** (época 2018–2021) que
complementa Track A (Vue 2 Legacy). No enseña "aprende MongoDB": enseña a
**desaprender el cerebro SQL con criterio** — para devs con años en
Oracle/PostgreSQL/MySQL/SQL Server que traicionan sus instintos en Mongo sin
saberlo.

**El proyecto:** Mini Jira (mesa de soporte interna) — el mismo dominio de
Track A, ahora con backend real que reemplaza al mock.

**Señal de éxito (compartida con Track A):** cambiar el `baseURL` del frontend
y que la app **no se entere**. Track A deja el frontend viviendo de json-server;
Track B lo reemplaza por un backend real que honra el mismo contrato
(`AUDIT-CONTRATO.md`).

---

## 📌 La realidad actual en disco (fuente de verdad de estructura)

El curso ya está escrito. Los archivos reales son:

**Tronco (16 fases, prefijo `NN-`):**

| Archivo | Fase interna | Esencia |
|---|---|---|
| `00-preliminares.md` | Fase 0 | Docker + mongosh/Compass, base de juguete, backup real |
| `01-mongo-en-30-min.md` | Fase 1 | Diccionario SQL↔Mongo, ObjectId, **seed del `db.json`** |
| `02-consultar-tu-sql-traducido.md` | Fase 2 | `find` espejo SQL↔MQL, null de 3 estados, tipos |
| `03-embeber-vs-referenciar.md` | Fase 3 ⭐ | Cambio #1, 4 cuadrantes, primer anti-patrón `soporte_v1` |
| `04-el-esquema-que-no-esta-en-la-base.md` | Fase 4 | Cambio #2, `schemaVersion`, JSON Schema Validation |
| `05-lookup-y-por-que-es-una-alarma.md` | Fase 5 | Cambio #3, `$lookup` medido contra embeber |
| `06-atomicidad-transacciones-consistencia.md` | Fase 6 ⭐ | Cambio #4, optimistic locking, doble "tomar", `409` |
| `07-indices.md` | Fase 7 | Cambio #5 (lo reconfortante), `explain()`, ESR, multikey |
| `08-la-autopsia.md` | Fase 8 | Rediseño de `soporte_v1`, medido antes/después (clímax del anti-patrón) |
| `09-aggregation.md` | Fase 9 | Pipeline, `$facet`, lógica del futuro `GET /stats` |
| `10-express-el-vehiculo.md` | Fase 10 | Capas, driver nativo, **el momento mágico** (mock apagado) |
| `11-auth-real-y-pago-de-deudas.md` | Fase 11 | Mongoose entra, bcrypt/JWT, inyección NoSQL, pago de 💸 |
| `12-el-backend-habla.md` | Fase 12 | Socket.io server-side, multer/GridFS |
| `13-testing-de-api.md` | Fase 13 | Jest + supertest + mongodb-memory-server |
| `14-operacion.md` | Fase 14 | Backups, migraciones en caliente, profiler |
| `15-el-veredicto-honesto.md` | Fase 15 | ¿Debías usar Mongo? Diagnóstico, no moda |

**Apéndices (prefijo `AN-`):** `A1-docker.md`, `A2-mongosh-compass.md`,
`A3-express.md`, `A4-seguridad.md`, `A5-mongo-vs-sql.md`.

**Maestros y guías (fuentes de verdad):** `AUDIT-CONTRATO.md`,
`GUIA-DE-ESTILO-Y-CONVENCIONES.md` (compartida con Track A),
`DICCIONARIO-CODIGO.md` (compartido con Track A), `README.md`.

> 🚫 **`PLAN-FORMACION-NOSQL-MONGODB.md` queda descartado.** Es un documento
> erróneo (numeración desalineada y desactualizada) y **no se usa como fuente de
> verdad**. Se elimina del conocimiento del proyecto; no se cita ni se
> re-sincroniza. Las fuentes vigentes son las cuatro de arriba.

> ⚠️ **Numeración: entera y continua, sin `.5` ni "interludios".** La numeración
> canónica es la de los **archivos**: Fase 0, 1, 2, 3, 4, 5, 6, 7, **8 (la
> autopsia), 9, 10, … 15**. La autopsia es un **capítulo entero más** de la
> secuencia, no un "7.5" ni un "interludio". Toda referencia cruzada "Fase N"
> dentro de las fases y en el `README` se verifica contra este esquema,
> **eliminando cualquier "7.5", ".5" o "interludio"** que haya quedado. Es el
> primer trabajo de revisión (prompt transversal T1).

---

## 🚦 Decisiones ya tomadas (no reabrir sin motivo)

Estas decisiones **ya están materializadas** en los archivos. No se reabren:
revisar es verificar que el contenido las respeta, no re-decidirlas.

| # | Decisión | Resuelto como |
|---|---|---|
| 1 | Nº de fases | **16** (0–15), numeración **entera y continua**, sin `.5` ni interludios; la autopsia es la Fase 8 |
| 2 | Dominio | **Solo Mini Jira** (ficticio, sin NDA — ver guía §11) |
| 3 | Anti-patrón `soporte_v1` | **Transversal** (fases 3, 5, 7) con **clímax en la autopsia (8)** |
| 4 | Veredicto honesto | **Capítulo real** (Fase 15) + Apéndice 5 que lo profundiza |
| 5 | `id` vs `_id` | **ObjectId interno, mapeo `_id`→`id` hex en la frontera** (contrato) |
| 6 | Villano en inglés | `soporte_v1` **también se normaliza a inglés** (guía §4.6): el olor es estructura, no idioma |
| 7 | Driver antes que Mongoose | Driver nativo fases 1–10; **Mongoose entra en la Fase 11** |

---

## 📡 El contrato es la costura entre tracks (lo más importante a alinear)

`AUDIT-CONTRATO.md` es la fuente de verdad de la frontera. Todo lo que Track B
expone hacia el frontend debe coincidir **exactamente** con lo que Track A
consume. Los puntos que hay que verificar fase por fase:

**Endpoints del dialecto json-server (régimen estricto, fases 1→10):**

- `GET /tickets` — soporta `?status=`, `?_sort=<campo>`, `?_order=asc|desc`,
  `?q=`. Devuelve **array plano, sin envelope**.
- `GET /tickets/:id` — **404 real** si no existe.
- `POST /tickets` — devuelve el ticket creado con su `id`, status **201**.
- `PATCH /tickets/:id` — merge parcial, devuelve el **ticket completo**.
- `DELETE /tickets/:id` — devuelve `{}` con **200** (manía de json-server).
- `GET /users` — soporta `?role=agent`. Array plano.
- `GET /comments` — soporta `?ticketId=X` y `?_sort=createdAt`.
- `POST /comments` — devuelve el comentario con `id`, status **201**.

**Reglas de forma:**

- JSON plano, **sin envelope** (`{ data: [...] }` está prohibido: el frontend
  hace `res.data` y espera el recurso directo).
- Fechas como **string ISO 8601** en la frontera (`Date` de BSON en la base).
- El `q=` de nuestro backend busca solo en `title` y `description` (desviación
  declarada y aceptable).
- `_id` ObjectId interno → serializado a `id` **string hex** en cada respuesta;
  `:id` de ruta → traducido a ObjectId en cada entrada.

**Sockets (socket.io 2.4, puerto `:4000`):** eventos `ticket:created`,
`ticket:updated`, `ticket:deleted`. **La versión importa: 2.x y 3.x no se
hablan.** En Track A, quien crea el ticket emite (el "cliente mentiroso"); en la
Fase 12 de Track B **cambia el emisor** (el servidor tras persistir), **no el
evento ni el payload**.

**Extensiones pactadas (régimen "el contrato crece", fases 11→15):**

| Extensión | Fase (archivo) | Tipo |
|---|---|---|
| `POST /auth/login` → `{ token, user }` con JWT | 11 | ⚠️ Única ruptura admitida y anunciada |
| `401` con token inválido/ausente | 11 | Extensión |
| `403` por rol insuficiente | 11 | Extensión |
| `409` en el doble "tomar" | 6 / 11 | Extensión |
| `GET /stats` (agregaciones server-side) | 10 (lógica en 9) | Endpoint nuevo previsto |
| `POST /attachments` (multipart) + descarga | 12 | Endpoint nuevo previsto |
| Server emite los sockets | 12 | Cambio de emisor, no de contrato |

> 🎯 **Discrepancia de datos a vigilar entre tracks.** Track A, en su modelo de
> referencia (`TRACKA-0-plan-del-curso.md`), muestra un ejemplo con
> `assignee: "agente1"` y un usuario `{ username: 'admin', role: 'agent' }`;
> `TRACKA-03-mock-api-minima.md` usa `assignee: "soporte1"/"soporte2"` (username,
> no id). **El contrato real es: `assignee`/`reporter` guardan el `username`
> (string), no un id.** Verificar que el seed de la Fase 1 y todos los ejemplos
> de Track B usen `username` en `assignee`/`reporter`, coherente con Track A.
> `admin` es solo un username (rol `agent`), **nunca un rol** (ver
> `DICCIONARIO-CODIGO.md` §2.1).

---

## 🎯 Los 5 cambios de paradigma (columna vertebral)

1. **Normalización ≠ virtud por defecto** → modelar por patrón de acceso → Fase 3
2. **El esquema no desaparece, se muda a la app** → heterogeneidad, migraciones → Fase 4
3. **`$lookup` no es join gratis** → síntoma de mal modelado → Fase 5
4. **Transacción multi-doc es rara, no moneda corriente** → el documento es atómico → Fase 6
5. **El índice sigue siendo índice** ← lo reconfortante → Fase 7

El anti-patrón `soporte_v1` es el hilo que cose las fases 3, 5 y 7, con clímax
en la autopsia (Fase 8).

---

## 🧱 Stack (época 2018–2021, coherente con Track A)

| Pieza | Versión | Nota |
|---|---|---|
| Node | 14.21.3 | `.nvmrc` incluido |
| MongoDB | **4.4** | Docker `mongo:4.4` |
| driver `mongodb` | 3.6.x | **fases 1–10: driver nativo, sin ODM** |
| Mongoose | 5.x | entra en la **Fase 11** como refactor |
| Express | 4.17.x | |
| jsonwebtoken / bcryptjs | 8.5.x / 2.4.x | |
| socket.io | **2.4.1** | emparejado con el cliente de Track A; 2.x ≠ 3.x |
| multer | 1.4.x | multipart |
| express-validator | 6.x | |
| cors, morgan, helmet, dotenv | — | kit mínimo |
| Jest + supertest + mongodb-memory-server | — | testing |

**Pedagogía del stack:** primero a mano, después el wrapper — driver nativo
antes que Mongoose, para que las 8 líneas se sientan regalo y no magia opaca.

---

## ✍️ Convenciones de contenido (la guía manda)

`GUIA-DE-ESTILO-Y-CONVENCIONES.md` y `DICCIONARIO-CODIGO.md` son la **fuente de
verdad editorial de ambos tracks**. Lo esencial para revisar:

**Regla de una línea:** el **código en inglés**; todo lo demás —narrativa,
comentarios, textos de interfaz— **en español** (guía §4). Incluye el villano:
`soporte_v1` también en inglés (`statuses`, `statusId`, `assigneeId`…), porque
el olor del anti-patrón es **estructura, no idioma** (guía §4.6).

**Tuteo, no voseo.** La narrativa se dirige al lector de **"tú"** ("apaga
json-server y verás el error", "primero mide"), no de "vos". La guía §2 ya lo
pedía; `GUIA-DE-ESTILO-Y-CONVENCIONES.md` y `DICCIONARIO-CODIGO.md` ya quedaron
normalizados a tuteo. Al revisar cada fase, verificar que no se coló voseo
(`tenés`, `medí`, `agregá`, `buscá`, `seguís`…) y pasarlo a tuteo
(`tienes`, `mide`, `agrega`, `busca`, `sigues`…).

**Plantilla obligatoria de cada fase (9 secciones, guía §8):**
1. 🎯 Propósito
2. ✅ Qué queda listo al terminar
3. 🚫 Qué queda fuera por ahora
4. 🧠 Conceptos mínimos (aquí viven 📖 tabla SQL↔Mongo, 🪞 y 🩻)
5. 💻 Implementación y código comentado (identificadores en inglés)
6. ⚠️ Errores comunes y pieza forense
7. 🧪 Ejercicios progresivos (25–35, graduados 🟢🟡🟠🔴)
8. 📚 Referencias (doc oficial de la versión exacta primero)
9. 🚀 Cierre y conexión con la siguiente fase

**Secciones propias de Track B (guía §7.4):** 📖 tabla de traducción SQL↔Mongo,
🪞 "tu instinto SQL dice… y esta vez se equivoca", 🩻 "esto sí funciona igual",
⚰️ el anti-patrón.

**Callouts (guía §7):** 💸 deuda técnica (declarada con su fase de pago), 🔥
opcional, ⭐ fase central, 📝 nota de época, 🪦 jubilación, ⚠️ advertencia, 💡
truco, 📚 referencia inline.

**Ejercicios (guía §9):** 25–35 por fase, distribución equilibrada
(~8🟢 / ~9🟡 / ~7🟠 / ~4-6🔴 + 🔥 aparte), numeración continua con encabezado de
rango, accionables y verificables, enganchados al dominio, usando el
identificador en inglés vigente. Apéndices: 5–10 cortos (o 30–50 según el plan).

---

## 💸 Deudas heredadas y su fase de pago (verificar continuidad)

Cada deuda se declara en Track A y se paga en Track B. La revisión confirma que
la fase que paga **la nombra, dice de qué fase viene, y muestra el cambio**:

| Deuda (nace en Track A) | Fase de pago (Track B, archivo) |
|---|---|
| Token mock (`"mock-jwt-token-123"`), nadie lo valida | 11 |
| El `reporter` lo inventa el cliente en el payload | 11 |
| Transiciones de estado solo las respeta el cliente | 11 |
| Guard de roles es teatro (localStorage) | 11 |
| "Cliente mentiroso": quien crea el ticket emite el socket | 12 |
| Doble "tomar" sin candado (último PATCH gana en silencio) | 6 |
| Métricas agregadas en el navegador; no existe `GET /stats` | 9→10 |
| La subida de archivos nunca fue real | 12 |

---

## ✅ Smoke test de la promesa (checklist de la Fase 10)

Con json-server apagado y `baseURL` apuntando al Express, debe sobrevivir todo
el checklist de `AUDIT-CONTRATO.md`: login mock, carga de tickets, `?q=` y
filtros, orden por columna, detalle con 404 real, crear (form y wizard),
editar/tomar/cambiar estado/eliminar, comentarios ordenados, métricas en cliente,
recarga con sesión activa, y **`git diff` del frontend: exactamente una línea**.

---

## 🎬 Qué falta hacer (el trabajo de esta etapa)

### 🔴 Transversal (antes de las fases)
1. **Unificar numeración** a la de los archivos (0–15); re-sincronizar
   el `README` y las referencias cruzadas "Fase N", eliminando cualquier "7.5"
   o "interludio". (`PLAN-FORMACION` no se toca: está descartado.)
2. **Auditar el contrato** de punta a punta contra `AUDIT-CONTRATO.md` y contra
   las fases de Track A que lo definen (`03`, `05`, `08` websockets, `09` panel).
3. **Verificar la regla de idioma** (§4 guía) en todo el código de Track B,
   incluido el villano, y llenar la matriz de `DICCIONARIO-CODIGO.md` §6.

### 🟡 Por fase (16 revisiones + 5 apéndices)
4. Correr el **prompt de revisión de fase** (abajo, archivo aparte) sobre cada
   uno de los 16 archivos de tronco y los 5 apéndices.

### 🟢 Cierre
5. Cerrar la **matriz de verificación** (`DICCIONARIO-CODIGO.md` §6) con cada
   archivo marcado.
6. **Feedback externo:** un dev SQL con 10+ años lee Fase 1 + Fase 3 (calibran
   tono y el primer cambio de paradigma).

---

## 📊 Checklist de calidad (por fase) — para la revisión

- [ ] 9 secciones de la plantilla presentes y en orden (guía §8)
- [ ] 25–35 ejercicios, graduados y equilibrados 🟢🟡🟠🔴 (guía §9)
- [ ] 📖 tabla SQL↔Mongo donde el contenido lo pide
- [ ] 🪞 y 🩻 donde aporten; ⚰️ anti-patrón en las fases 3/5/7/8
- [ ] Flujo paso a paso (evento por evento) donde haya flujo
- [ ] Deudas 💸 declaradas con su fase de pago; 🔥 lo opcional
- [ ] **Código en inglés** (identificadores, endpoints, colecciones, campos,
      enums), incluido el villano; **comentarios y UI en español**
- [ ] **Tuteo, no voseo** en toda la narrativa
- [ ] No contradice `AUDIT-CONTRATO.md` (forma, `id`↔`_id`, enums, eventos)
- [ ] No contradice fases anteriores **ni Track A** (pedagogía y nombres)
- [ ] Referencias con URL completa de la versión exacta (Mongo 4.4, driver 3.6,
      Express 4.17, Mongoose 5, socket.io 2.4), orden de lectura, aviso de versión
- [ ] Numeración de fase coherente con el esquema unificado (0–15)
- [ ] Cierre con puente a la siguiente fase y "la señal de que quedó bien"

---

## 🎯 Señal de éxito final del curso

> "Un dev con 10 años de Oracle leyó las 16 fases, hizo cientos de ejercicios, y
> puede mirar un esquema Mongo ajeno y decir en cinco minutos si fue **diseñado**
> o **traducido mal de SQL**. Y sabe qué duele, por qué, y qué haría distinto."
