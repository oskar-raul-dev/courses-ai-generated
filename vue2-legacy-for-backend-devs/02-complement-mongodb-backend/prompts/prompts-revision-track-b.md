# 🔍 Prompts de revisión — Track B (MongoDB legacy)

Prompts listos para pegar, una revisión por fase. Cada uno pide **continuidad,
alineación al contrato de Track A, estilo y regla de idioma del código**. Están
pensados para correrse en un chat que tenga en el proyecto: los 16 archivos de
Track B, los de Track A, `AUDIT-CONTRATO.md`, `GUIA-DE-ESTILO-Y-CONVENCIONES.md`
y `DICCIONARIO-CODIGO.md`.

Cómo usarlos: corré primero los **3 transversales (T1–T3)**, después uno por
fase. Cada prompt de fase es la plantilla base + una **ficha de riesgos** propia
de esa fase (los puntos donde esa fase suele romper el contrato o el estilo).

---

## 🧭 Prompts transversales (correr primero)

### T1 — Unificar numeración de fases

```
Actuá como editor técnico del curso Track B (MongoDB legacy). La numeración de
fases debe ser ENTERA Y CONTINUA, sin ".5" ni "interludios":
Fase 0, 1, 2, 3, 4, 5, 6, 7, 8 (la autopsia), 9, 10, 11, 12, 13, 14, 15.
Es la numeración de los archivos en disco (00→15, 16 fases). La autopsia es la
Fase 8 a secas: un capítulo entero más de la secuencia, NO un "7.5" ni un
"interludio".

Nota: NO uses PLAN-FORMACION-NOSQL-MONGODB.md como referencia; está descartado
por erróneo. Las instrucciones viejas "B0…B13" también son obsoletas.

Tarea:
- Recorré README.md y las 16 fases + 5 apéndices buscando: (a) toda referencia
  "Fase N" (en prosa, cierres, puentes, tablas de deudas y de extensiones) que
  no cuadre con el esquema entero, y (b) TODA aparición de "7.5", ".5",
  "interludio" o equivalente.
- Reescribí las referencias al esquema entero y ELIMINÁ la palabra
  "interludio"/"7.5" donde aparezca (la autopsia se nombra "Fase 8"). Podés
  conservar que la autopsia es el "clímax del anti-patrón" y un capítulo más
  corto, pero sin numeración fraccionaria ni etiqueta de interludio.
- Listá cada desalineación como: archivo, línea aprox., texto actual, texto
  corregido.
- No reescribas contenido pedagógico: es solo el número y quitar el rótulo.
Entregá la lista de cambios propuestos, sin aplicarlos todavía.
```

### T2 — Auditoría del contrato de API punta a punta

```
Actuá como auditor de contrato entre Track A (frontend Vue 2) y Track B
(backend Mongo/Express). La fuente de verdad es AUDIT-CONTRATO.md; Track A lo
define en TRACKA-03-mock-api-minima.md, TRACKA-05-crud-tickets.md,
TRACKA-08-websockets-minimos.md y TRACKA-09-panel-soporte.md.

Verificá que TODO lo que Track B expone hacia el frontend coincide exactamente
con lo que Track A consume. Chequeá, endpoint por endpoint y evento por evento:
- Rutas, métodos, query params (?status=, ?_sort=, ?_order=, ?q=, ?ticketId=,
  ?role=) y sus manías.
- Formas de respuesta: array plano sin envelope, 404 real, 201 en POST, {} con
  200 en DELETE, ticket completo en PATCH.
- Fechas: Date de BSON en la base, string ISO 8601 en la frontera.
- id vs _id: ObjectId interno, serializado a id string hex en salida, :id →
  ObjectId en entrada.
- assignee/reporter guardan USERNAME (string), no id. (Track A usa "soporte1",
  "usuario1"; vigilá que ningún ejemplo de Track B use un id ahí.)
- Enums: status (open/in_progress/resolved/closed), priority (low/medium/high),
  role (agent/reporter; admin NO es rol). snake_case en in_progress.
- Sockets: socket.io 2.4, eventos ticket:created/updated/deleted, puerto :4000,
  mismo payload; en Track B cambia el emisor (Fase 12), no el evento.
- Extensiones (Fases 11→15): POST /auth/login {token,user}, 401, 403, 409,
  GET /stats, POST /attachments — como extensiones, sin romper lo existente.

Entregá una tabla: aspecto | qué dice Track A / contrato | qué dice Track B |
¿coincide? | archivo y línea si no coincide | corrección propuesta.
```

### T3 — Idioma del código (inglés en código, español en el resto) y tuteo

```
Actuá como revisor de la regla de idioma de GUIA-DE-ESTILO §4 y
DICCIONARIO-CODIGO.md sobre las 16 fases + 5 apéndices de Track B.

Regla: código en inglés (identificadores, funciones, variables, endpoints,
colecciones, campos, enums, nombres de archivo/capa, eventos de socket);
comentarios y textos de interfaz en español; narrativa en español.
Incluí el villano soporte_v1: también en inglés (statuses, priorities, users,
statusId, assigneeId, reporterId), porque el olor del anti-patrón es
ESTRUCTURA, no idioma (guía §4.6).

La narrativa va en TUTEO, no voseo (guía §2 y ya normalizadas la guía y el
diccionario): "tú" y sus formas (tienes, mide, agrega, busca, sigues, verás),
nunca "vos" (tenés, medí, agregá, buscá, seguís).

Por cada archivo, marcá:
- Cualquier identificador de código en español (function/const/campo/colección/
  enum/capa/evento).
- Cualquier endpoint o ruta con segmento en español.
- Cualquier valor de status/priority/role en español.
- Comentarios o UI que por error quedaron en inglés (deberían estar en español).
- Cualquier forma de VOSEO en la narrativa (terminaciones -ás/-és/-ís de vos,
  imperativos como medí/agregá/fijate, presentes como tenés/podés/seguís), con
  su reemplazo en tuteo.
Entregá, por archivo, la lista de hallazgos con la corrección, y actualizá la
matriz de verificación de DICCIONARIO-CODIGO.md §6 (Track B) marcando ✅ lo que
ya cumple. No toques narrativa, comentarios ni textos de UI que ya estén en
español correcto.
```

---

## 🧩 Plantilla base de revisión de fase

Usá este bloque para cualquier fase, reemplazando `{{ARCHIVO}}`, `{{FASE}}` y
pegando debajo la **ficha de riesgos** correspondiente.

```
Actuá como editor técnico senior del curso Track B (MongoDB legacy, época
2018–2021). Revisá el archivo {{ARCHIVO}} (Fase {{FASE}}). No lo reescribas
entero: identificá problemas y proponé correcciones puntuales con archivo,
línea aproximada, texto actual y texto corregido.

Revisá estos cuatro ejes:

1) CONTINUIDAD
- ¿El Propósito conecta con lo que dejó la fase anterior y el Cierre construye
  el puente a la siguiente? ¿Los números de fase citados son correctos (esquema
  0–15, autopsia = Fase 8)?
- ¿Las deudas 💸 que esta fase declara o paga nombran la fase correcta y muestran
  el cambio? (ver tabla de deudas en las instrucciones)
- ¿No contradice ninguna fase previa de Track B ni de Track A?

2) ALINEACIÓN AL CONTRATO Y A TRACK A
- Contrastá contra AUDIT-CONTRATO.md y contra las fases de Track A relevantes.
- Endpoints, formas de respuesta, id↔_id, fechas ISO, enums, eventos de socket:
  ¿todo idéntico a lo que el frontend consume?
- assignee/reporter = username (string), no id. admin no es rol.

3) ESTILO (GUIA-DE-ESTILO)
- Plantilla de 9 secciones en orden (guía §8).
- Callouts correctos (💸 🔥 ⭐ 📝 🪦 ⚠️ 💡) y, donde aporte, los recuadros de
  Track B (📖 tabla SQL↔Mongo, 🪞 instinto, 🩻 esto sí funciona igual, ⚰️).
- Tono cálido, informal, segunda persona en TUTEO (tú, no vos), sin
  condescendencia; humor moderado. Marcar cualquier voseo que se haya colado.
- 25–35 ejercicios graduados y equilibrados 🟢🟡🟠🔴 (guía §9), accionables,
  enganchados al dominio, citando identificadores en inglés vigentes.
- Referencias con URL completa de la versión exacta (Mongo 4.4, driver 3.6,
  Express 4.17, Mongoose 5, socket.io 2.4), orden de lectura, aviso de versión.

4) IDIOMA DEL CÓDIGO (§4)
- Código en inglés (incluido el villano soporte_v1); comentarios y UI en español.
- Todo fragmento corre con las versiones fijadas del stack.

Además, atendé especialmente la ficha de riesgos de esta fase:
{{FICHA_DE_RIESGOS}}

Entregá: (a) tabla de hallazgos con correcciones, (b) veredicto de si la fase
pasa el checklist de calidad o qué falta, (c) lista de identificadores nuevos
que deban sumarse a DICCIONARIO-CODIGO.md si aparecieron.
```

---

## 📇 Fichas de riesgos por fase

Pegá la ficha correspondiente en `{{FICHA_DE_RIESGOS}}`.

### Fase 0 — `00-preliminares.md`
```
- Docker mongo:4.4 y compose parametrizable por .env (puerto, dbPath vía bind
  mount, flags de mongod). Caminos alternos Windows (MSI, mongod.cfg) y macOS.
- mongosh + Compass + Database Tools. Base de juguete playground.personas.
- El menú de backup REAL: mongodump/mongorestore con restore ensayado + copia
  fría del dbPath. Insistir "JSON ≠ backup" desde el día cero.
- Entregable SETUP.md. No debe hablar todavía del Mini Jira ni del contrato.
- No adelantar paradigmas: es setup, no modelado.
```

### Fase 1 — `01-mongo-en-30-min.md`
```
- Diccionario tabla→colección, fila→documento, PK→_id/ObjectId. Qué viaja
  intacto (índices, N+1) y qué no.
- EL SEED del db.json heredado es el corazón: convertir cada id numérico a
  ObjectId nuevo, RETRADUCIR referencias (comments.ticketId → ObjectId nuevo del
  ticket), fechas string → Date de BSON.
- Verificar que el seed usa username en assignee/reporter (soporte1, usuario1),
  coherente con TRACKA-03. Que la colección users trae role agent/reporter.
- Descarte argumentado de ids autoincrementales (anti-patrón, contra el
  contrato §"id vs _id").
- Calibra el tono de todo el track: sin condescendencia, el lector sabe SQL.
```

### Fase 2 — `02-consultar-tu-sql-traducido.md`
```
- find como SELECT, operadores, proyección, sort/skip/limit en formato espejo
  SQL↔MQL (📖 tabla es obligatoria y central aquí).
- Trampas 🪞: el null de tres estados (no existe vs null vs no coincide), tipos
  no estrictos. Que la trampa se nombre ANTES de caer.
- La tabla "del contrato a MQL": cómo ?status=, ?_sort=, ?_order= se traducen a
  find/sort (prepara la Fase 10). Coherencia con el dialecto del contrato.
- Aún driver/mongosh, sin Express todavía.
```

### Fase 3 — `03-embeber-vs-referenciar.md` ⭐
```
- Cambio de paradigma #1. Los 4 cuadrantes (se lee junto × cambia junto) con
  cuentas sobre Mini Jira: ¿comentarios embebidos? ¿historial de estados?
- Patrones canónicos: subset, extended reference, computed, bucket. Límite 16MB
  y arrays sin techo.
- PRIMERA aparición del anti-patrón ⚰️ soporte_v1: presentarlo y MEDIR su dolor.
  Verificar que soporte_v1 está en INGLÉS (statuses, statusId, assigneeId…) y su
  olor es estructural (lookup-tables de ≤10 docs {_id numérico, name}, FKs que
  nadie valida, 7 colecciones para lo que el buen modelo resuelve en 1-2).
- El "detector de traducido-no-diseñado" huele estructura, no idioma.
- Fase central ⭐: pedagogía impecable, ejercicios exigentes.
```

### Fase 4 — `04-el-esquema-que-no-esta-en-la-base.md`
```
- Cambio #2. 3 versiones de documento conviviendo, no hay ALTER TABLE.
- schemaVersion, migraciones perezosas vs masivas. JSON Schema Validation con
  despliegue en 3 tiempos (warn → reparar → error) — el CHECK que creías perdido.
- El ejercicio de validación de roles: admin es valor ILEGAL que el enum rechaza
  (agent/reporter son los únicos roles). Coherencia con DICCIONARIO §2.1.
- 🪞 el esquema no desapareció, se mudó a tu app.
```

### Fase 5 — `05-lookup-y-por-que-es-una-alarma.md`
```
- Cambio #3. $lookup existe pero NO es un join: sin optimizador, sin hash join,
  sin estadísticas. Enseñarlo, MEDIRLO contra el modelo embebido.
- Regla nocturno-vs-caliente: legítimo en reporte batch, síntoma en endpoint
  caliente. Las tres formas de unir (N+1, batch, $lookup) medidas.
- Protocolo de denormalización adulta y qué hacer cuando se desincroniza.
- SEGUNDA visita al anti-patrón ⚰️: el dashboard con $lookup, cronómetro en mano.
- 🩻 el N+1 sigue siendo N+1: tu paranoia SQL vale acá igual.
```

### Fase 6 — `06-atomicidad-transacciones-consistencia.md` ⭐
```
- Cambio #4. El documento como unidad de consistencia. $inc/$push/
  findOneAndUpdate, write/read concern, transacciones multi-doc donde de verdad
  tocan; replica set de 1 nodo como plan C.
- OPTIMISTIC LOCKING vía update condicional: el doble "tomar" se resuelve con
  findOneAndUpdate({ _id, assignee: null }) porque el contrato prohíbe pedirle al
  frontend un campo de versión. Responde 409 (extensión pactada).
- Verificar que takeTicket coincide en nombre con la action takeTicket de Track A
  (DICCIONARIO §5.3). El 409 es la extensión que el PATCH del frontend recibe
  donde antes había éxito silencioso.
- Es la fase que paga la deuda del doble "tomar" (nace en Track A).
```

### Fase 7 — `07-indices.md`
```
- Cambio #5, EL RECONFORTANTE (tras 4 fases cuestionando certezas). Bajar la
  ansiedad: explain() = EXPLAIN PLAN, collection scan = full table scan,
  compuestos y prefijo izquierdo como en Oracle, selectividad manda igual.
- Lo nuevo: multikey (sobre arrays, lo que hace viable embeber), anidados,
  parciales, TTL, regla ESR.
- El ?q= del contrato motiva índice de texto vs $regex (AUDIT-CONTRATO §"?q=").
- TERCERA visita al anti-patrón ⚰️: los índices NO lo salvan; el índice no
  arregla el modelo. 🩻 domina esta fase entera.
```

### Fase 8 — `08-la-autopsia.md`
```
- El clímax del anti-patrón. Rediseño completo de soporte_v1 aplicando los 5
  paradigmas; re-medición; veredicto numérico antes/después.
- Corto, sin teoría nueva: es el examen práctico de las fases 3–7.
- Es una FASE ENTERA (Fase 8), no un "interludio" ni "7.5": verificar que el
  encabezado, el cuerpo y toda referencia interna la nombran "Fase 8" y que se
  eliminó cualquier rótulo "7.5"/"interludio" (ver T1). Puede seguir siendo más
  corta que las demás y describirse como "clímax del anti-patrón", pero es un
  capítulo de pleno derecho en la secuencia continua.
- Aun siendo corta, debe encajar en la plantilla de 9 secciones (guía §8) en la
  medida en que aplique; verificar contra la guía qué secciones son exigibles.
```

### Fase 9 — `09-aggregation.md`
```
- Pipeline (etapas) vs SQL (declarativo). $match/$group/$project/$unwind/$facet.
  Traducciones desde GROUP BY/HAVING/window functions (📖 tabla).
- Deja ESCRITA la lógica del futuro GET /stats (deuda 💸: hoy las métricas se
  calculan en el navegador — nace en TRACKA-07-metricas-minimas).
- No usar $setWindowFields (es Mongo 5+; fuera del stack). Verificar que las
  stats reproducen las que Track A calcula en cliente (tickets por estado, por
  agente).
```

### Fase 10 — `10-express-el-vehiculo.md`
```
- EL MOMENTO MÁGICO. Capas routes→controller→service→model, middlewares,
  errores, códigos HTTP, explícitamente rápido ("esto ya lo sabes").
- TODO con driver nativo (Mongoose todavía no; el momento mágico no se contamina
  con dos novedades).
- Implementa el dialecto json-server COMPLETO (?q= solo en title/description,
  ?_sort=/?_order=) y el mapeo _id→id en la frontera, DEFENDIDO por escrito.
- json-server apagado, frontend vivo. Smoke test del contrato (checklist de
  AUDIT-CONTRATO). git diff del frontend: una línea.
- GET /stats entra aquí (lógica venía de la Fase 9).
- Este es el archivo cuyo título interno decía "Fase 10" y el PLAN lo llamaba
  "Fase 9 Express": punto caliente de la deuda de numeración (T1).
```

### Fase 11 — `11-auth-real-y-pago-de-deudas.md`
```
- Abre con el refactor a MONGOOSE 5 (el regalo de las 8 líneas, ya hecho a mano).
- bcrypt, JWT firmado, req.user, roles server-side (agent/reporter).
- INYECCIÓN NoSQL: {$ne: null} en un login mal hecho — el ataque es un OBJETO,
  no comillas. 🪞 tu instinto anti-inyección apunta al lugar equivocado.
- Aquí la regla pasa de "no se entera" a "el contrato crece, no se rompe":
  POST /auth/login {token,user} es la ÚNICA ruptura admitida y anunciada.
- Paga 4 deudas de Track A: token mock, reporter inventado, transiciones
  client-side, guard de roles de teatro. SECURITY-NOTES.md empieza a tacharse.
- Verificar 401/403 como extensiones. Mongoose 5 (no 6/7/8).
```

### Fase 12 — `12-el-backend-habla.md`
```
- El servidor emite los sockets tras persistir: muere el relé tonto y el
  "cliente mentiroso" (mismo evento, mismo payload, distinto emisor). Deuda de
  Track A (TRACKA-08) pagada.
- socket.io 2.4 OBLIGATORIO: 2.x y 3.x no se hablan (⚠️). Puerto :4000.
- multer + GridFS para adjuntos que nunca fueron reales (POST /attachments,
  multipart) — deuda de Track A pagada.
- Verificar que los eventos siguen siendo ticket:created/updated/deleted y que
  el payload es idéntico al que emitía el cliente.
```

### Fase 13 — `13-testing-de-api.md`
```
- Jest + supertest + mongodb-memory-server. Qué se testea en cada capa y por qué;
  la testeabilidad como detector de diseño.
- El duelo del doble "tomar" (Fase 6) y el smoke test del contrato convertidos en
  suite automática.
- Fixtures en inglés (DICCIONARIO §5.4): claves de objeto en inglés (agent/
  reporter), username y name son datos (no se traducen). makeTicket, no
  ticketLibre.
```

### Fase 14 — `14-operacion.md`
```
- mongodump/mongorestore, migraciones, índices en producción sin bloquear (4.4),
  el profiler de queries lentas = tu Slow Query Log. docker-compose final.
- 🩻 fuerte: esto es lo que un dev SQL SÍ extraña y acá lo recupera.
- Coherencia con el backup real ya visto en la Fase 0 (no repetir, profundizar).
```

### Fase 15 — `15-el-veredicto-honesto.md`
```
- La conversación que ningún tutorial tiene. Las 5 preguntas del marco, la tabla
  de olores, el árbol post-diagnóstico. Cuándo fue elección correcta y cuándo
  moda de 2015; qué hacer si fue moda (spoiler: no siempre migrar).
- Cierra INSTINTOS.md y MODERNIZATION.md como checklist de la promesa del curso.
- Es capítulo real (no apéndice); el Apéndice 5 lo profundiza. Verificar que no
  se pisan ni se contradicen.
- Tono reflexivo pero sin solemnidad de manual.
```

---

## 📎 Prompt de revisión de apéndices (A1–A5)

```
Actuá como editor técnico del curso Track B. Revisá el apéndice {{ARCHIVO}}.
Los apéndices NO siguen la plantilla de 9 secciones: usan índice de salto rápido
+ secciones cortas + tabla "cuándo usar qué" + 5–10 ejercicios cortos (o 30–50
según el plan). Revisá:
- Continuidad: el apéndice se referencia desde la(s) fase(s) que lo necesitan y
  no contradice el tronco.
- Contrato e idioma del código: mismas reglas que las fases (código en inglés,
  comentarios/UI en español, versiones del stack).
- A1-docker: compose, bind mount vs volumen, el bug del rs.initiate con hostname.
- A2-mongosh-compass: shell como REPL, .mongoshrc.js, Compass (Schema/Explain/
  Pipeline Builder).
- A3-express: pipeline de middlewares, promesas no atrapadas en Express 4 y el
  asyncHandler, el error handler de 4 argumentos.
- A4-seguridad: inyección NoSQL a fondo, BOLA/BOPLA, JWT, rate limiting, uploads
  hostiles, cierre de SECURITY-NOTES.md.
- A5-mongo-vs-sql: historia del hype 2009–2021, CAP/PACELC, Jepsen, el canon del
  debate; que profundice la Fase 15 sin repetirla.
Entregá tabla de hallazgos con correcciones y veredicto.
```
