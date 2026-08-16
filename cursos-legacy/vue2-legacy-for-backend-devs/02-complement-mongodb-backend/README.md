# 🍃 Curso 02 · MongoDB para cerebros SQL — el backend de Mini Jira

Curso práctico de **MongoDB 4.4 + Express/Node 14 (época 2018–2021)** para
desarrolladores con años en Oracle, PostgreSQL, MySQL o SQL Server que tienen
que mantener —o rescatar— un backend Mongo heredado.

No enseña "aprende MongoDB". Enseña a **desaprender el cerebro SQL con
criterio**: a saber cuáles de tus instintos relacionales siguen siendo
correctos, cuáles te van a traicionar, y cómo medir la diferencia en vez de
discutirla.

Proyecto hilo conductor: **Mini Jira**, la misma mesa de soporte interna del
[Curso 01](../01-vue2-legacy/README.md) — ahora con un backend real que
reemplaza al mock.

> 🧭 **La señal de éxito del curso, y es verificable:**
> **se apaga json-server, se cambia el `baseURL` del frontend, y la aplicación
> no se entera.**
>
> El frontend heredado se entrega con el curso y **no se toca**. El jefe de
> este proyecto no es Mongo ni Express: es el frontend. Qué significa
> exactamente esa promesa —dónde es estricta y dónde el contrato puede crecer—
> está firmado en [`00-audit-contrato.md`](00-audit-contrato.md).

---

## 🧭 Documentos maestros

| Archivo | Qué es |
|---|---|
| **Este `README.md`** | 📑 **Índice del curso** — empieza aquí |
| [`00-audit-contrato.md`](00-audit-contrato.md) | 📜 **El contrato que el backend debe honrar.** Dialecto de json-server a reimplementar, regímenes estricto y de crecimiento, checklist de smoke test. Fuente de verdad de la costura entre los dos cursos |
| [`prompts/diccionario-codigo.md`](prompts/diccionario-codigo.md) | 📖 Diccionario de código del dominio, compartido con el Curso 01 |
| [`prompts/instrucciones-proyecto-track-b.md`](prompts/instrucciones-proyecto-track-b.md) | 📋 Alcance del curso y realidad en disco |
| [`../prompts/convencion-de-git-y-tags.md`](../prompts/convencion-de-git-y-tags.md) | 🏷️ **Cómo llevas el progreso en git**: repo propio (separado del frontend, y por qué), un tag por fase, y el mensaje del tag como cuaderno de mediciones |
| [`../prompts/guia-de-estilo-y-convenciones.md`](../prompts/guia-de-estilo-y-convenciones.md) | ✍️ Guía editorial compartida con el Curso 01 |
| [`forense-master.md`](forense-master.md) | 🕵️ **La puerta del track forense**: el método de cuatro preguntas y el 🩺 índice de síntomas. Se entra por lo que ves, no por la fase |
| [`cuaderno-incidentes.md`](cuaderno-incidentes.md) | 📓 **12 incidentes** con el ticket como llegó, pistas plegadas y solución de referencia |

> 🚫 `prompts/plan-formacion-nosql-mongodb.md` está **descartado**: su
> numeración no corresponde a los archivos reales. No se usa como fuente de
> verdad. Y `prompts/guia-de-estilo-y-convenciones.md` es la guía **superada**
> del Track B: se conserva como referencia histórica y lleva su aviso 🪦 dentro
> — la vigente es la del paquete, enlazada arriba.

---

## 🧠 Los cinco cambios de paradigma

El curso se organiza alrededor de cinco recalibraciones. No son "cosas nuevas
que aprender": son **certezas tuyas que hay que revisar** — cuatro que se
mueven y una que no.

1. **La normalización deja de ser la virtud por defecto** (F3). Duplicar
   puede ser correcto. La pregunta ya no es "¿está en 3FN?" sino "¿cómo se
   accede a esto?".
2. **El esquema no desaparece — se muda** (F4). De la base a la aplicación,
   del DDL al código, del `ALTER TABLE` a la convivencia de versiones.
3. **El JOIN ya no es gratis ni es el plan A** (F5). `$lookup` existe, se
   enseña completo, y se mide contra embeber. El número decide.
4. **La transacción existe, pero deja de ser el pegamento** (F6). La
   atomicidad del documento cubre más de lo que crees; la precondición en el
   filtro cubre el resto.
5. **El índice sigue siendo el índice** (F7). Esta es la fase reconfortante, y
   es reconfortante **a propósito**: B-trees, selectividad, compuestos,
   `explain()`. Tu década de SQL vale intacta acá.

Y el hilo que los cose: **`soporte_v1`**, una base "migrada a Mongo"
transcribiendo el esquema relacional tabla por tabla. Aparece en F3, se mide
en F5, se indexa sin redención en F7 y recibe su autopsia completa en F8.

---

## 🌳 Las 16 fases

| Archivo | Fase | Qué entra |
|---|---|---|
| [`00-preliminares.md`](00-preliminares.md) | 🛠️ **F0** | Docker, `docker-compose.yml` parametrizable, mongosh y Compass, base de juguete, backup real ensayado |
| [`01-mongo-en-30-min.md`](01-mongo-en-30-min.md) | 🍃 **F1** | Diccionario SQL ↔ Mongo, `ObjectId`, y el **seed del `db.json`** del Curso 01 |
| [`02-consultar-tu-sql-traducido.md`](02-consultar-tu-sql-traducido.md) | 🔍 **F2** | `find` como espejo de tu SQL, el `null` de tres estados, tipos |
| [`03-embeber-vs-referenciar.md`](03-embeber-vs-referenciar.md) | ⚔️ **F3** ⭐ | Cambio #1, los cuatro cuadrantes, y el primer olor de `soporte_v1` |
| [`04-el-esquema-que-no-esta-en-la-base.md`](04-el-esquema-que-no-esta-en-la-base.md) | 🧬 **F4** | Cambio #2, `schemaVersion`, JSON Schema Validation |
| [`05-lookup-y-por-que-es-una-alarma.md`](05-lookup-y-por-que-es-una-alarma.md) | 🔗 **F5** | Cambio #3, `$lookup` completo y **medido** contra embeber |
| [`06-atomicidad-transacciones-consistencia.md`](06-atomicidad-transacciones-consistencia.md) | ⚛️ **F6** ⭐ | Cambio #4, optimistic locking, el doble "tomar" y su `409` |
| [`07-indices.md`](07-indices.md) | ⚡ **F7** | Cambio #5 (el reconfortante), `explain()`, regla ESR, multikey |
| [`08-la-autopsia.md`](08-la-autopsia.md) | ⚰️ **F8** | Rediseño de `soporte_v1` medido antes y después. Sin teoría nueva: hay un cadáver y un bisturí |
| [`09-aggregation.md`](09-aggregation.md) | 🧮 **F9** | Pipeline, `$facet`, y la lógica del futuro `GET /stats` |
| [`10-express-el-vehiculo.md`](10-express-el-vehiculo.md) | 🚂 **F10** | Capas, driver nativo, y **el momento mágico**: 🪦 el mock se apaga |
| [`11-auth-real-y-pago-de-deudas.md`](11-auth-real-y-pago-de-deudas.md) | 🔐 **F11** | Mongoose entra, bcrypt y JWT, inyección NoSQL, y el pago de deudas 💸 |
| [`12-el-backend-habla.md`](12-el-backend-habla.md) | 🔌 **F12** | socket.io del lado del servidor, multer y GridFS. 🔀 Y `/activity`, si hiciste una ruta |
| [`13-testing-de-api.md`](13-testing-de-api.md) | 🧪 **F13** | Jest + supertest + mongodb-memory-server. La suite de contrato |
| [`14-operacion.md`](14-operacion.md) | 🛠️ **F14** | Backups, migraciones en caliente, profiler. Lo que un dev SQL sí extraña |
| [`15-el-veredicto-honesto.md`](15-el-veredicto-honesto.md) | ⚖️ **F15** | ¿Debías haber usado Mongo? Diagnóstico, no moda |

> ⚠️ **La numeración es entera y continua: F0 a F15.** No hay fases `.5` ni
> "interludios". La autopsia es la **Fase 8**, un capítulo completo de la
> secuencia. Cualquier referencia cruzada "Fase N" se verifica contra esta
> tabla.

---

## 📎 Apéndices — consulta, no lectura

Se leen cuando el tema aparece. Todos sus ejercicios son opcionales, y todos
se hacen contra **tu** laboratorio, no contra ejemplos de juguete.

| Archivo | Qué es |
|---|---|
| [`a01-docker.md`](a01-docker.md) | 🐳 Docker mínimo — compose, bind mount contra volumen, el bug del `rs.initiate` con hostname |
| [`a02-mongosh-compass.md`](a02-mongosh-compass.md) | 🍃 mongosh y Compass a fondo — el shell como REPL, `.mongoshrc.js`, Schema y Explain |
| [`a03-express.md`](a03-express.md) | 🚂 Express a fondo — pipeline de middlewares y las promesas no atrapadas de Express 4 |
| [`a04-seguridad.md`](a04-seguridad.md) | 🔑 Seguridad backend (OWASP aplicado) — inyección NoSQL, BOLA/BOPLA, JWT, rate limiting, uploads |
| [`a05-mongo-vs-sql.md`](a05-mongo-vs-sql.md) | ⚖️ Mongo contra SQL, la conversación a fondo — el hype 2009–2021, CAP y PACELC, Jepsen, el canon del debate |

---

## 🕵️ Track forense

Doce recorridos de investigación con el ticket literal, la salida de cada paso y
qué descarta cada uno. **No se leen de corrido: se entra por el síntoma.**

La puerta es [`forense-master.md`](forense-master.md), con el método de cuatro
preguntas y el **índice de síntomas transversal** — porque nadie llega sabiendo
de qué fase es su problema, llega con *"esto va lento"*.

| | Síntoma que cubre |
|---|---|
| [`forense-fase-00.md`](forense-fase-00.md) | "Levanté todo y no conecta", con errores que no hablan de lo que pasa |
| [`forense-fase-01.md`](forense-fase-01.md) | "El dato está en la base y la consulta no lo encuentra" |
| [`forense-fase-02.md`](forense-fase-02.md) | "Traduje mi WHERE y devuelve de más" ⭐ |
| [`forense-fase-04.md`](forense-fase-04.md) | "El validator rechaza un documento que a mí me parece correcto" |
| [`forense-fase-05.md`](forense-fase-05.md) | "Esta pantalla hace seis viajes a la base" ⭐ |
| [`forense-fase-06.md`](forense-fase-06.md) | "Dos agentes tomaron el mismo ticket" ⭐ |
| [`forense-fase-07.md`](forense-fase-07.md) | "El índice está creado y `explain()` sigue diciendo COLLSCAN" |
| [`forense-fase-08.md`](forense-fase-08.md) | "La migración pasó el conteo y los datos son basura" |
| [`forense-fase-09.md`](forense-fase-09.md) | "Mi GROUP BY devuelve UNA fila" |
| [`forense-fase-10.md`](forense-fase-10.md) | "El request se queda girando para siempre" ⭐ |
| [`forense-fase-12.md`](forense-fase-12.md) | "Por socket llega distinto que por HTTP" |
| [`forense-fase-13.md`](forense-fase-13.md) | "Verde en mi máquina, rojo en CI" |

**Cuatro fases no tienen pieza, y es a propósito:** F3, F11, F14 y F15 no
producen un recorrido de diagnóstico propio —lo suyo son decisiones de modelado,
pago de deudas, operación y veredicto—, y una pieza sin recorrido propio no es
una pieza: es un resumen de la fase con otro nombre. Sus errores típicos siguen
en la sección **⚠️ Errores comunes** de cada una.

Cada fase con pieza la enlaza desde su sección **⚠️ Errores comunes y pieza
forense**, donde además hay un bloque 🧨 **Rompe a propósito** para provocar el
fallo en tu propia máquina. El formato está especificado en
[`../prompts/formato-piezas-forenses.md`](../prompts/formato-piezas-forenses.md).

---

## 📓 Cuaderno de incidentes

[`cuaderno-incidentes.md`](cuaderno-incidentes.md) — **12 incidentes** graduados
🟢🟡🟠🔴 y repartidos por todo el curso. Cada uno trae el ticket **como llegó**
—vago, en palabras de quien lo reporta—, la preparación para tener el sistema
roto en tu máquina, tres pistas plegadas, un espacio en blanco para tu
investigación, y la solución de referencia con causa raíz, parche mínimo,
refactorización correcta, **prueba de regresión en código**, prevención y
post-mortem sin culpabilización.

Los dos últimos son **incidentes de costura** —el frontend apuntando a tu
backend— y son **autocontenidos**: se entrega el frontend construido, así que se
resuelven sin haber hecho el Curso 01. Los IDs son propios de este curso y no se
comparten con el otro cuaderno.

Y la regla que es la mitad del ejercicio: **la solución viene incluida, y abrirla
antes de escribir la tuya no te ahorra tiempo — te ahorra el ejercicio.**

---

## 🗺️ El arco del curso

```
  F0 ── F1 ── F2 ─────── F3 ── F4 ── F5 ── F6 ── F7 ── F8
setup  MQL  consultar  embeber esquema lookup atom índices AUTOPSIA
                          ⭐                     ⭐        │
                          └──── el hilo `soporte_v1` ──────┘
                                                            │
  F9 ─── F10 ─── F11 ─── F12 ─── F13 ─── F14 ─── F15
 agg   EXPRESS   auth   sockets  tests  operar  veredicto
         │        │       │
         │        └───────┴── se pagan las deudas 💸 del Curso 01
         │
   🪦 json-server se apaga. El frontend no se entera.
```

Las fases 0 a 9 son **datos**: modelar, consultar, medir, rediseñar. La 10 es
la bisagra —el backend se monta detrás de HTTP y ocurre la prueba de fuego— y
de la 11 a la 14 el sistema se vuelve serio: autenticación real, sockets del
servidor, archivos, tests y operación. La 15 no añade técnica: da criterio.

---

## 💸 Las deudas que este curso cobra

El Curso 01 dejó deudas **declaradas a propósito**, porque un frontend contra
un mock siempre las tiene. Este curso las paga, y ese cobro es contenido, no
un apéndice:

- **El cliente mentiroso.** Hoy quien crea un ticket es quien el navegador
  dice que es. → F11 y F12: el `reporter` sale de `req.user`, y el evento de
  socket lo emite el servidor.
- **El doble "tomar".** Dos agentes toman el mismo ticket y gana el último. →
  F6: la precondición va en el filtro y el segundo recibe un `409`.
- **Las transiciones de estado libres.** El frontend decide y nadie verifica.
  → F11: transiciones custodiadas en el service.
- **Las métricas calculadas en el navegador.** → F9 y F10: `GET /stats` con la
  forma exacta que fija `utils/ticketStats.js`, para que la vista pueda hacer
  fallback al cálculo local sin cambiar una línea.
- **El timeline de actividad con el reloj del cliente** (solo si hiciste una
  ruta Q4/VU4/NX4). → F12: `/activity` servido como proyección del `history`
  que ya embebiste, y el evento emitido por el servidor.
- **El cuaderno de "esto lo debería hacer el backend"** que `SECURITY-NOTES.md`
  viene acumulando desde la Fase 2 del Curso 01. → F11, F12 y el apéndice de
  seguridad los cierran, y F15 declara los que quedan vivos.

---

## 🧭 Cómo usarlo

1. Lee este índice y, antes de escribir una línea de código,
   [`00-audit-contrato.md`](00-audit-contrato.md). Sin el contrato,
   "no romper el frontend" no significa nada.
2. Haz la **Fase 0** y deja Docker y Mongo 4.4 respirando. No sigas sin eso.
3. Avanza **en orden** y **cierra cada fase con su tag**
   (`git tag -a fase-07-indices …`). Las fases 3 a 8 son un arco: la autopsia
   de F8 no funciona si no mediste el villano en F5 y lo indexaste en F7 — y
   esos números viven mejor en el mensaje de un tag anotado que en un `.md` que
   vas a sobrescribir tres veces.
4. Completa al menos los ejercicios 🟢 y 🟡 antes de avanzar. Los 🔴 exigen
   medir, y medir es el músculo del curso.
5. Los apéndices son consulta. El de seguridad conviene leerlo **junto a F11**,
   no después.
6. **Escribe tus documentos.** El curso te pide mantener varios entregables
   —`SETUP.md`, `DATA-MODEL.md`, `INSTINTOS.md`, `SECURITY-NOTES.md`,
   `AUTOPSIA.md`, `MODERNIZATION.md`— que crecen fase a fase. No son deberes
   de relleno: `INSTINTOS.md` es el registro de tus recalibraciones, y es lo
   que te vas a llevar cuando el curso se olvide.

> 🔀 **¿Hiciste una ruta del Curso 01?** Entonces tu frontend pide dos cosas
> que el tronco no pide, y las dos están cubiertas como secciones y ejercicios
> **condicionales**, marcados con 🔀:
>
> - **Q3 o VU3** migran el dashboard a una tabla que pagina en servidor: tu
>   backend necesita `?_page` / `?_limit` y el header `X-Total-Count`
>   (**Fase 10**).
> - **Q4, VU4 o NX4** añaden la colección `activity` para el timeline
>   (**Fase 12**).
>
> Si terminaste el Curso 01 en F11, sáltate ambas sin deber nada.

> 📝 **¿Hace falta haber hecho el Curso 01?** No para escribir el backend, pero
> sí para entender contra qué estás trabajando. Como mínimo, lee su
> [`0-plan-del-curso.md`](../01-vue2-legacy/0-plan-del-curso.md) y su Fase 3
> ([`03-mock-api-minima.md`](../01-vue2-legacy/03-mock-api-minima.md)), que es
> donde nace el mock que vas a reemplazar.

---

## 🧱 Stack de época (versiones fijadas)

| Herramienta | Versión | Nota |
|---|---|---|
| MongoDB | **4.4** | La época. Transacciones existen pero piden replica set |
| Node.js | **14** | El mismo del Curso 01 |
| Driver `mongodb` | **3.6** | **Primero a mano.** Mongoose entra recién en F11 |
| Mongoose | **5.x** | El wrapper, después de entender qué envuelve |
| Express | **4.x** | Con sus promesas no atrapadas y su `asyncHandler` |
| socket.io | **2.x** | ⚠️ Tiene que coincidir con el cliente del Curso 01 |
| Jest · supertest · mongodb-memory-server | — | La red de F13 |
| Docker · Docker Compose | — | Desde la primera línea de F0 |

⚠️ **Fuera del código principal:** MongoDB 5 o superior, driver `mongodb` 4/5/6,
Mongoose 6 o superior, socket.io 3/4. Aparecen solo como comparación o en
secciones 🔥.

---

## 📊 El material en números

- **16 fases** + **5 apéndices**
- **12 piezas forenses** y **12 incidentes** en el cuaderno
- **695 ejercicios** graduados 🟢 fácil → 🟡 intermedio → 🟠 difícil →
  🔴 muy difícil, más los 🔥 opcionales
- 25–38 ejercicios por fase; 30–36 por apéndice (todos opcionales)
- Buena parte de los 🔴 son de **medición**: `explain()`, reproducir un N+1,
  cerrar una race condition, cronometrar un restore. Sin números no hay
  veredicto

| Bloque | Estado |
|---|---|
| Fases F0–F15 | ✅ terminado |
| Apéndices a01–a05 | ✅ terminado |
| `00-audit-contrato.md` | ✅ firmado |
| Track forense (`forense-*.md`) | ✅ terminado |
| `cuaderno-incidentes.md` | ✅ terminado |

---

## 🎓 La promesa del curso

> "Heredé una base Mongo que alguien 'migró' desde Postgres tabla por tabla. Sé
> medir cuánto cuesta eso, sé rediseñarla sin romper a quien la consume, y sé
> decir con números si Mongo era la herramienta correcta — o si fue la moda de
> 2015 con uniforme."

Y la de la fase 10, que es la que se siente:

> "Apagué json-server, cambié una línea del frontend, y el dashboard cargó
> igual. Ninguna vista se enteró."
