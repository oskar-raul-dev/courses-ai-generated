# ✍️ Guía de estilo, tono y convenciones — Curso Libro Mayor (NewSQL)

Esta guía es la fuente de verdad editorial de todo `.md` que se redacte para
el curso Libro Mayor. Deriva de `GUIA-DE-ESTILO-Y-CONVENCIONES.md` (curso
legacy Vue/MongoDB), adaptada al modelo de acceso, al dominio y al villano de
este curso. Donde esta guía no diga algo distinto, aplican los principios
generales de esa guía madre.

> 🧭 **Regla de una línea que rige todo el código:** el **código en inglés**;
> toda la narrativa, comentarios y textos de interfaz **en español neutro,
> sin voseo**. El detalle está en §4.

---

## 1. Principio rector

**Todo lo que se escribe apunta a que alguien pueda auditar un ledger
distribuido ajeno, o defender con números una decisión de arquitectura
distribuida, sin fingir certezas que no midió.** No enseñamos CockroachDB "de
moda": enseñamos a leer una transacción y estimar cuánto cuesta confirmarla,
a decidir el domicilio de una fila como decisión de producto, y a reconocer
cuándo esta familia entera es la respuesta equivocada. Si un párrafo no
ayuda a modelar, medir o decidir, sobra.

El norte compartido del curso es una sola señal de éxito: **poder mirar
cualquier transacción del ledger y decir, con un número del arnés en la mano,
cuánto cuesta confirmarla y por qué.** Todo lo que se escribe sirve a esa
promesa.

---

## 2. Tono

El tono es **cálido, informal y directo** — de colega senior de bases
relacionales a colega senior, con humor cuando cae bien. Es alguien que ya se
peleó con un clúster de tres nodos a las 3 de la mañana explicándotelo con
confianza y sin solemnidad, no un manual acartonado.

- **Segunda persona, cercana, sin voseo.** Se usa "tú" en todo el curso —
  "corre el arnés y mira el p99", "si te tienta hacer un `SELECT ... FOR
  UPDATE` como en casa, primero mide". **Nunca** formas de voseo ("corré",
  "mirá", "medí"): el curso se dirige a un público hispanohablante amplio y
  la guía legacy ya fija "tú" como la persona del curso; Libro Mayor la
  hereda sin excepción.
- **Humor seco permitido.** Un 😉, una nota sobre "veinte minutos
  depurando un timeout que en realidad era un reloj desincronizado del
  laboratorio", un 🪦 para jubilar un patrón. El humor desdramatiza la
  fricción de lo distribuido, no rellena.
- **Honesto sobre el costo.** Cuando algo cuesta caro —operar tres motores,
  reintentar transacciones abortadas, la ergonomía real de la geo-partición—
  se dice con números, no con eufemismos de marketing. "Este clúster paga
  120 ms de ida y vuelta por cada commit cross-región, y eso no lo arregla
  ninguna versión nueva" es la voz del curso.
- **Orientado a la duda real.** Anticipa "¿y esto por qué se diseñó así?" y
  la responde, muchas veces con una nota de arquitectura (📝) sobre el
  problema histórico de consenso distribuido que motivó el diseño.
- **Cercanía sin condescendencia.** El lector es senior en SQL relacional: no
  le expliques qué es una transacción, un índice o un plan de ejecución. Lo
  nuevo es cómo cambian —o no— cuando debajo hay rangos replicados por Raft
  en vez de páginas en un disco local.

Evitar: promesas vacías ("vas a dominar lo distribuido"/"NewSQL resuelve
todo"), motivación de coach, solemnidad de manual corporativo, y explicar lo
obvio del paradigma relacional que el lector ya domina. El humor es
condimento, no plato principal.

> 🧠 **Matiz propio de Libro Mayor (el eje del curso).** El lector no llega
> en blanco: llega con años de instintos de un Postgres o un MySQL de un solo
> nodo, bien afinado. El tono reconoce esos instintos y los interpela de
> frente con dos micro-secciones recurrentes (§7.4): 🪞 *"tu instinto de nodo
> único dice… y aquí se paga distinto"* y 🩻 *"esto sí viaja igual"*. Nunca se
> ridiculiza el instinto relacional: es correcto en su contexto original, y el
> curso lo recalibra, no lo desecha.

---

## 3. Idioma y forma (narrativa)

- Español claro, técnico y **sin voseo** para todo lo que no es código
  (títulos, explicaciones, ejercicios, referencias, callouts). Se usa "tú" en
  todas las instrucciones de segunda persona.
- Los términos del stack se dejan en inglés cuando son el nombre real y
  traducirlos sería forzado o confuso: *commit*, *quorum*, *leaseholder*,
  *range*, *follower read*, *backoff*, *hotspot*, *sharding*, *replica set*,
  *savepoint*, *serializable*. No se inventan traducciones como "cuórum" o
  "fragmentación" cuando la comunidad hispanohablante del motor usa el
  término en inglés.
- Markdown siempre.
- Encabezados con emoji **con moderación** — uno por sección de plantilla.
  Los subtítulos internos pueden llevar emoji-tipo (§7) cuando aporta lectura
  rápida.
- **Prosa antes que listas.** Se prefiere razonar en párrafos, como en la
  semilla. Las listas se usan cuando son de verdad una lista (pasos, ítems
  paralelos).
- **Tablas solo para comparar, decidir o mapear.** "Cuándo usar CockroachDB
  vs TiDB vs Yugabyte", el marco de 5 preguntas, matrices de decisión, y
  —muy importante en este curso— **tablas de traducción nodo único ↔ clúster
  distribuido** (§7.4). No para narrar.

---

## 4. Idioma del código fuente (código en inglés, curso en español)

Normativa para **todo** fragmento de código del curso: cuerpo de fase,
incidente, apéndice o ejercicio resuelto.

### 4.1 Regla general

| Capa | Idioma | Ejemplo |
|---|---|---|
| **Código fuente** (identificadores) | 🇬🇧 Inglés | `function postTransfer(input) {}`, `const isHotAccount = false` |
| **Endpoints y rutas** | 🇬🇧 Inglés | `/transfers`, `/accounts/:id/balance`, `/accounts/:id/statement` |
| **Tablas, columnas y constraints SQL** | 🇬🇧 Inglés | `accounts`, `home_region`, `amount_minor`, `chk_postings_sum_zero` |
| **Constantes y enums internos** | 🇬🇧 Inglés | `region: 'eu'`, `TRANSFER_STATUS_POSTED`, `MAX_RETRY_ATTEMPTS` |
| **Nombres de archivo, servicio, script del arnés** | 🇬🇧 Inglés | `TransferService.ts`, `transferService.ts`, `scripts/vs.ts`, `scripts/seed.ts` |
| **Comentarios de código** | 🇪🇸 Español | `// la precondición va en el WHERE: si el saldo ya bajó del límite, la transacción aborta sola` |
| **Textos de interfaz y mensajes de error legibles** | 🇪🇸 Español | `{ message: 'La cuenta europea no puede recibir esta transferencia fuera de su región' }` |
| **Narrativa del curso** | 🇪🇸 Español | Todo el texto fuera de bloques de código |

> 📝 **Por qué esta regla.** Un ledger real mantenido por un equipo técnico
> tiene su código en inglés, con comentarios en el idioma del equipo —igual
> que aquí—. Escribir el laboratorio así hace que el vocabulario de
> identificadores sea el mismo que el lector va a encontrar en un sistema de
> producción real, y el mismo en los cuatro motores: `transfer` es `transfer`
> en el DDL de Cockroach, en el de TiDB y en el de Yugabyte.

### 4.2 Qué se traduce y qué no (criterio rápido)

| Elemento | ¿Inglés? | Ejemplo |
|---|---|---|
| Tablas y columnas SQL | ✅ Sí | `postings`, `account_id`, `currency`, `created_at` |
| Nombres de constraint y de índice | ✅ Sí | `chk_balance_ge_limit`, `idx_accounts_home_region` |
| Endpoints REST | ✅ Sí | `POST /transfers`, `GET /accounts/:id/statement` |
| Funciones y variables del arnés y de la API | ✅ Sí | `runScenario()`, `retryOnSerializationFailure()`, `hotAccountId` |
| Nombres de archivo, módulo, capa | ✅ Sí | `transfers.routes.ts`, `transfers.service.ts`, `ledger.errors.ts` |
| Escenarios del arnés (identificador interno) | ✅ Sí | `scenario: 'cross-region-transfer-32-clients'` |
| Comentarios `//`, `/* */` | ❌ No | `// el reintento es seguro porque la operación es idempotente por transferId` |
| Mensajes de error legibles para el usuario de la API | ❌ No (la key sí va en inglés) | `{ code: 'INSUFFICIENT_FUNDS', message: 'Fondos insuficientes para completar la transferencia' }` |
| Nombres del dominio en la narrativa | ❌ No | El texto sigue hablando de "cuenta", "transferencia", "asiento", "región de origen" |
| Etiquetas de estado visibles | ❌ No (clave en inglés, label en español) | `POSTED: { label: 'Registrado' }`, `REVERSED: { label: 'Revertido' }` |

> ⚠️ **Caso mixto frecuente — errores del ledger.** El objeto de error usa
> claves en inglés (`{ code, message }`), pero el **valor** de `message` que
> ve quien consume la API va en español:
>
> ```ts
> // ledger.errors.ts
> export const LEDGER_ERRORS = {
>   INSUFFICIENT_FUNDS: { code: 'INSUFFICIENT_FUNDS', message: 'Fondos insuficientes para completar la transferencia' },
>   CROSS_REGION_RESIDENCY_VIOLATION: { code: 'CROSS_REGION_RESIDENCY_VIOLATION', message: 'La cuenta debe permanecer en su región de residencia' },
>   SERIALIZATION_CONFLICT: { code: 'SERIALIZATION_CONFLICT', message: 'La transacción entró en conflicto y debe reintentarse' },
> };
> ```
>
> La clave (`SERIALIZATION_CONFLICT`) es el enum que viaja por la API y que
> el cliente compara en código; el `message` es humano y va en español.
> **Nunca** se guarda el texto en español como valor de comparación en el
> código.

### 4.3 Diccionario del dominio (Libro Mayor)

Referencia mínima; el diccionario extendido (incluyendo los términos propios
de cada motor: *range*, *placement*, *tablespace*, *Region*) vive en el
`DICCIONARIO-TRADUCCION-LIBRO-MAYOR.md` que nace en la Fase 2.

| Español (dominio, narrativa) | Inglés (código) |
|---|---|
| cuenta | `account` |
| transferencia | `transfer` |
| asiento / movimiento | `posting` |
| titular | `holder` |
| región de origen / domicilio | `home_region` |
| saldo | `balance` |
| límite de crédito | `credit_limit` |
| moneda | `currency` |
| unidad mínima (centavos) | `amount_minor` |
| cuenta de sistema / cuenta caliente | `system_account` / `hot_account` |
| registrado → revertido | `posted` → `reversed` |
| reintentar / abortar (una transacción) | `retry` / `abort` |
| conflicto de serialización | `serialization_conflict` |

### 4.4 Convenciones de nombrado

- **Funciones y variables:** `camelCase` en inglés — `postTransfer`,
  `isSerializationConflict`, `retryAttempt`.
- **Constantes de configuración:** `SCREAMING_SNAKE_CASE` —
  `MAX_RETRY_ATTEMPTS`, `CROSS_REGION_TIMEOUT_MS`.
- **Endpoints REST:** sustantivo en plural, inglés — `/accounts`,
  `/transfers`, `/accounts/:id/postings`.
- **Tablas SQL:** `snake_case` plural en inglés — `accounts`, `transfers`,
  `postings`.
- **Columnas SQL:** `snake_case` en inglés — `home_region`, `amount_minor`,
  `created_at`, `reversed_at`.
- **Valores de enum/status:** inglés, `snake_case` si son compuestos —
  `serialization_conflict` (no `serializationConflict` ni `conflicto_serie`).
- **Scripts del arnés y del laboratorio:** `kebab-case.ts` dentro de
  `scripts/` — `scripts/vs.ts`, `scripts/seed.ts`, `scripts/chaos-kill-node.ts`.
- **Servicios de la API:** `<dominio>Service` — `transferService`,
  `accountService`, `statementService`.

### 4.5 Lo que nunca cambia

- **Comentarios de código:** 100 % español, explicando el porqué (§5).
- **Textos de interfaz y mensajes de error legibles:** 100 % español.
- **Narrativa del curso:** 100 % español, sin voseo.
- **Nombres propios del dominio en la narrativa:** "cuenta", "transferencia",
  "asiento" siguen siendo las palabras con que se *habla* del sistema, aunque
  el código diga `account`, `transfer`, `posting`.

---

## 5. Orientación a la práctica

- **Nada de teoría suelta.** Si se explica el aislamiento serializable, se
  explica sobre una transferencia entre dos cuentas concurrentes de Libro
  Mayor, no en abstracto. Si se explica Raft, es sobre el commit de un
  `posting` cruzando de región.
- **Código ejecutable y coherente.** Todo fragmento corre con las versiones
  fijadas en la semilla (§ Stack) y no contradice fases anteriores. Nada de
  pseudocódigo que "se entiende": si un ejemplo usa `withRetry`, es el mismo
  `withRetry` que nace en la Fase 4.
- **Código mínimo.** El fragmento más pequeño que demuestra el punto, pero
  ejecutable y con su prueba en Vitest cuando aplique.
- **Comentarios que explican el porqué, no el qué, siempre en español.**
  `// el backoff exponencial evita que los tres clientes reintenten en el
  mismo instante y repitan el conflicto` sí; `// incrementa el contador` no.
- **Distinguir capas.** Siempre queda claro si un comportamiento vive en la
  ruta HTTP, en el `service`, en el propio motor (constraint, transacción,
  Raft) o en el arnés. Es la distinción que salva a quien depura un aborto de
  transacción a las tres de la mañana.

---

## 6. Manejo del "legacy" propio de este curso: el villano

Libro Mayor no tiene código legacy heredado como el curso Vue/Mongo, pero
tiene su propio patrón deliberadamente mal construido: **el falso dilema**,
en sus tres caras (§ semilla, "El villano"). Se construye, se mide, se
disecciona — nunca se esconde ni se arregla en silencio.

- **Cara A (saga a mano).** Vive en un motor sin transacciones multi-clave,
  con compensaciones escritas en la capa de aplicación. El código de esta
  cara se muestra tal como se vería en producción: feo, plausible, y con el
  bug de "proceso muerto entre el débito y el crédito" reproducible a
  voluntad. No se disculpa por ser feo: **es feo a propósito**, igual que
  `soporte_v1` en el curso legacy.
- **Cara B (monolito forzado).** Un único nodo con réplica asíncrona y
  failover manual documentado en una wiki ficticia. Se muestra con el mismo
  respeto: es una arquitectura real que muchos equipos operan hoy, no un
  espantapájaros.
- **Cara C (fanboy).** Un CRUD de una sola región sobre un clúster de tres
  nodos. Aquí el humor sí puede subir un poco: es el caso donde "usar el
  motor donde no toca" se ve más rápido en el número del arnés.
- **El villano también se normaliza al inglés del código (§4.6 heredado del
  curso legacy).** El anti-patrón se reconoce por sus decisiones —dinero en
  el limbo, failover manual, consenso pagado por nada— no por el idioma de
  sus identificadores. Un ledger con identificadores en inglés puede ser
  igual de mal diseñado.

---

## 7. Marcadores y callouts (vocabulario visual del curso)

### 7.1 Marcadores de estado

- 💸 **Deuda técnica intencional.** Todo shortcut que se deja a propósito y
  se paga después. Ejemplo vivo del curso: el saldo particionado de la Fase 7
  complica leer el total agregado; esa deuda se paga explícitamente sirviendo
  el total desde un snapshot histórico en la Fase 8.
- 🔥 **Opcional / ampliación.** Ejercicios o secciones que exceden el alcance
  base (por ejemplo, explorar `AUTO_RANDOM` de TiDB a fondo, o un cuarto
  motor NewSQL solo como lectura).
- ⭐ **Fase o pieza central.** En este curso, las Fases 3, 4, 7 y 12.
- 🟢🟡🟠🔴 **Dificultad de ejercicios.** Fácil / intermedio / difícil / muy
  difícil (§9).

### 7.2 Callouts en blockquote (emoji-tipo)

- 📝 **Nota de arquitectura.** Contexto histórico o de diseño detrás de una
  decisión de un motor. Ej.: "Percolator, el paper de Google detrás del
  esquema optimista de TiDB, nació para resolver indexación incremental, no
  pagos — y eso explica por qué su modelo de conflicto se siente distinto."
- 📚 **Referencia rápida inline.** Un enlace útil justo donde surge la duda,
  sin esperar a la sección de referencias del cierre de fase.
- 🪦 **Retiro / jubilación.** Cuando un patrón cumple su función y se retira.
  Ej.: "🪦 Se apaga el modo de un solo nodo por motor: ya cumplió su función
  de comparación base."
- ⚠️ **Advertencia.** Algo que rompe si se ignora — la licencia de
  CockroachDB (CSL, no Apache) desde 24.3, una clave primaria `SERIAL` en un
  motor distribuido, un `withRetry` sobre una operación no idempotente.
- 💡 **Truco o atajo** que ahorra tiempo real de laboratorio.

### 7.3 Secciones narrativas recurrentes (comunes)

- **💸 Pago de deuda.** Dónde se salda una deuda declarada antes; se nombra
  qué deuda era, de qué fase venía, y se muestra el cambio.
- **Detalles con intención.** Lista corta que destila decisiones deliberadas
  ("la clave primaria usa UUIDv7 y no `SERIAL`, porque la monotonía
  concentra el rango de escritura en un solo nodo").
- **El patrón a memorizar.** Una o dos frases con la lección transferible.
- **Prueba de fuego.** Verificación manual incrustada en el flujo: "mata el
  nodo líder del rango de `accounts` a mitad de una transferencia: la
  aplicación reintenta y el dinero nunca queda en el limbo."
- **Mini-repaso.** Cuando una fase usa un concepto que el lector de SQL de
  nodo único quizá no domina (Raft, quórum, geo-partición), un repaso exprés
  en tabla antes del código, con su 📚.
- **La señal de que quedó bien.** En el cierre, un criterio en forma de
  cita: "si mañana el negocio abre en una cuarta región, solo agrego una fila
  de configuración de `REGIONAL BY ROW` y ninguna transferencia existente se
  entera."

### 7.4 Secciones propias de Libro Mayor (nodo único → clúster distribuido)

Estas cuatro son la columna vertebral del curso y aparecen cuando el
contenido lo pide:

- **📖 Tabla de traducción nodo único ↔ clúster distribuido.** Lado a lado,
  el concepto o comando en un Postgres de un solo nodo y su equivalente en el
  motor distribuido en cuestión. Ej.: `CREATE INDEX` en Postgres ↔
  `CREATE INDEX` en Cockroach, pero con la nota de que el índice ahora vive
  replicado por rango. Es tabla (§3), no prosa.
- **🪞 "Tu instinto de nodo único dice… y aquí se paga distinto."** Nombra la
  trampa **antes** de caer: `SERIAL` como clave primaria, dar por sentado que
  una réplica siempre está atrasada, asumir que `SELECT ... FOR UPDATE`
  cuesta lo mismo que en casa. Honra el instinto —fue correcto en su
  contexto— y lo recalibra con un número del arnés.
- **🩻 "Esto sí viaja igual."** Lo reconfortante: SQL, tipos, `EXPLAIN`
  (leído distinto, pero el razonamiento de selectividad es el mismo),
  índices, y el vocabulario de anomalías de aislamiento (lectura sucia, no
  repetible, fantasma) valen exactamente lo que valían. Baja la ansiedad del
  lector.
- **⚰️ Caso de estudio: el villano.** Las tres caras del falso dilema (§6),
  medidas y diseccionadas. Es el hilo que cose las Fases 1, 7, 9 y 12.

---

## 8. Plantilla obligatoria de cada fase (9 secciones)

Toda fase produce un `.md` con exactamente estas nueve secciones, en orden:

1. **🎯 Propósito** — qué resuelve esta fase; puede abrir con la situación
   heredada ("hasta ahora el ledger vive en un solo nodo y nadie preguntó qué
   pasa si Europa se cae…").
2. **✅ Qué queda listo al terminar** — checklist verificable.
3. **🚫 Qué queda fuera por ahora** — qué se difiere y a qué fase.
4. **🧠 Conceptos mínimos** — solo lo necesario, anclado al dominio. Aquí
   caben el **Mini-repaso**, las **Notas de arquitectura** (📝), la 📖 tabla
   de traducción y los recuadros 🪞/🩻.
5. **💻 Implementación y código comentado** — el grueso; código ejecutable
   con comentarios de porqué, identificadores en inglés (§4). Aquí caben
   **Detalles con intención**, **El patrón a memorizar**, **Prueba de fuego**
   y **💸 Pago de deuda**.
6. **⚠️ Errores comunes y pieza forense** — qué se rompe típicamente
   (conflictos de serialización no manejados, particiones mal declaradas,
   relojes desincronizados) y cómo depurarlo con el plan distribuido y las
   métricas del arnés.
7. **🧪 Ejercicios progresivos** — 20 a 40, objetivo 30 (§9).
8. **📚 Referencias** — documentación oficial primero, luego papers y libros,
   luego video/apoyo, con orden de lectura sugerido y advertencia de
   verificación (§10). **Van al final de cada fase, sin excepción.**
9. **🚀 Cierre y conexión con la siguiente fase** — qué sigue y por qué. Aquí
   va **La señal de que quedó bien**.

Los apéndices no siguen esta plantilla: usan índice de salto rápido +
secciones cortas + tabla "cuándo usar qué" + 5-10 ejercicios cortos.

---

## 9. Ejercicios

- **Cantidad: 20 a 40 por fase, objetivo cómodo 30** (heredado de la propia
  semilla del curso, que ajusta el mínimo general de 25 de la guía legacy
  porque algunas fases —la 6, conceptual— rinden mejor con menos ejercicios
  bien elegidos que con relleno).
- **Distribución equilibrada por nivel.** Para 30: ~8 🟢, ~9 🟡, ~7 🟠, ~6 🔴,
  más los 🔥 opcionales listados aparte y sin numeración.
- **Diversidad real de dificultad dentro de cada rango**, no solo de
  etiqueta: dentro de 🟡, por ejemplo, conviven ejercicios de "usa bien una
  herramienta de la fase" (correr un escenario del arnés con otro número de
  clientes) con ejercicios que exigen leer un plan distribuido completo. No
  todos los 🟡 deben sentirse igual de fáciles entre sí.
- **Numeración continua con encabezado de rango por dificultad:**
  ```
  ## 🧪 Ejercicios (30)

  **🟢 Fácil (1–8)**
  1. ...
  **🟡 Intermedio (9–17)**
  9. ...
  **🟠 Difícil (18–24)**
  18. ...
  **🔴 Muy difícil (25–30)**
  25. ...
  **🔥 Opcionales**
  - 🔥 ...
  ```
- **Progresión real.** Los 🟢 calientan y verifican comprensión ("escribe la
  transferencia entre dos cuentas de la misma región y comprueba que la suma
  de `postings` es cero"). Los 🟡 exigen usar bien una herramienta de la
  fase. Los 🟠 obligan a medir con el arnés y defender el número. Los 🔴
  integran varias fases o cierran un caso esquivo (reproducir una anomalía
  bajo concurrencia, bajar el p99 cross-región sin romper la invariante,
  sostener throughput sobre la cuenta caliente con el clúster degradado).
- **Al menos cinco por fase son de diagnóstico.** Se entrega código o
  configuración con un fallo plantado —un `withRetry` que reintenta una
  operación no idempotente, una clave primaria monótona que serializa el
  clúster, una partición mal declarada que saca cuentas europeas de Europa—
  y se pide reproducir, localizar y corregir, en ese orden.
- **Accionables y verificables.** "Haz que la transferencia entre la cuenta
  `acc_eu_00042` y la cuenta de comisiones no supere 40 ms de p99 con 64
  clientes concurrentes" — no "reflexiona sobre la contención".
- **Enganchados al dominio.** Cuentas, transferencias, asientos, regiones y
  monedas de Libro Mayor. Nunca `foo`, `bar` ni tablas genéricas.
- **Cuando un ejercicio nombra código, usa el identificador en inglés
  vigente** ("agrega el `service` `reverseTransfer`", "escribe el
  `retryOnSerializationFailure`"), aunque el enunciado esté en español.
- Los 🔥 son opcionales y se listan aparte, sin numeración continua.

En apéndices bastan 5-10 ejercicios cortos de consulta.

---

## 10. Bibliografía y referencias

**Regla:** documentación oficial de la versión fijada en el stack
**primero**; luego papers y libros; luego blogs, charlas y video. Siempre se
advierte cuando un enlace apunta a una versión distinta a la fijada, y las
referencias **van al final de cada fase**, no dispersas en el cuerpo (salvo
un 📚 puntual justo donde surge la duda, que no reemplaza la sección final).

### 10.1 Formato

- **URLs completas y clicables**, no solo el dominio.
- **Secciones separadas** dentro de "Referencias": Documentación oficial (con
  URL completa y nota de versión), Papers y libros cuando apliquen,
  Video/apoyo (charlas, screencasts con URL completa), y **Orden de lectura
  sugerido** (una línea que encadena qué leer primero) — exactamente como
  fija la tabla de referencias por fase de la semilla.

### 10.2 Fuentes oficiales de base (usar URL completa al citar)

- **CockroachDB:** https://www.cockroachlabs.com/docs/stable/
- **TiDB:** https://docs.pingcap.com/tidb/stable/
- **YugabyteDB:** https://docs.yugabyte.com/stable/
- **PostgreSQL 17:** https://www.postgresql.org/docs/17/index.html
- **Toxiproxy:** https://github.com/Shopify/toxiproxy
- **Node.js:** https://nodejs.org/docs/latest-v24.x/api/
- **TypeScript:** https://www.typescriptlang.org/docs/

### 10.3 Advertencias

- **Sobre citas:** cuando se mencione un paper, libro, charla o post
  específico, se deja claro que URLs y títulos deben verificarse al momento
  de redactar; el lector también debe confirmarlos. **No se inventan números
  de página, DOIs ni identificadores de video.**
- **No usar en el código principal** versiones del stack distintas a las
  fijadas en la semilla (§ Stack): CockroachDB fuera de la línea LTS elegida,
  TiDB o YugabyteDB de otra rama, TypeScript 7 si el ecosistema de pruebas
  todavía cojea (fallback documentado a 6.0). Las alternativas más recientes
  aparecen solo como comparación o en una sección 🔥.
- **CouchDB ≠ Couchbase**, y **NewSQL ≠ NoSQL**: ambas confusiones se marcan
  explícitamente la primera vez que el curso podría prestarse a ellas.

---

## 11. Sobre el dominio (ficticio, sin NDA)

Libro Mayor es un dominio **enteramente ficticio**: una plataforma de pagos
inventada para este curso, sin cliente real ni confidencialidad que
preservar. Esto simplifica dos cosas:

- Los ejemplos pueden ser todo lo concretos que convenga —montos, regiones,
  cuentas de sistema— sin "generalizar ante la duda".
- El vocabulario del dominio (cuenta, transferencia, asiento, región,
  moneda) es estable y se fija en `DICCIONARIO-TRADUCCION-LIBRO-MAYOR.md`; no
  compite con ningún vocabulario "real" que haya que evitar.

La regla de idioma del código (§4) es una convención de calidad, no una
cuestión de NDA.

---

## 12. Coherencia entre documentos

- **No contradecir fases anteriores.** Un fragmento de la Fase 6 no puede
  asumir una estrategia de clave primaria distinta de la que la Fase 3
  estableció como ganadora, salvo que la propia Fase 6 lo declare
  explícitamente como revisión.
- **No reescribir decisiones aprobadas** sin señalar la incompatibilidad y
  por qué.
- **Fuentes de verdad, en orden:** (1) instrucciones del proyecto de la Ruta
  NoSQL, (2) `RUTA-NOSQL-FUNDAMENTOS.md`, (3) `09-libro-mayor-semilla.md`,
  (4) entregables aprobados de fases anteriores del curso, (5) decisiones
  explícitas del chat actual.
- Nombres de tablas, columnas, endpoints, servicios y scripts se mantienen
  estables entre fases (en inglés, §4.4). Si algo se renombra, se documenta
  el cambio y se propaga a `DICCIONARIO-TRADUCCION-LIBRO-MAYOR.md`.

---

## 13. Post-mortems e incidentes de laboratorio

Cada incidente del arnés o del laboratorio de chaos sigue esta estructura de
ocho puntos:

1. Síntoma.
2. Pasos de reproducción (incluye el comando exacto de `vs.ts` o de
   Toxiproxy usado).
3. Evidencia observable (métricas del arnés, plan distribuido, logs del
   motor, panel de rangos).
4. Causa raíz.
5. Corrección.
6. Prueba de regresión (un escenario nuevo o ajustado en `vs.ts`).
7. Prevención.
8. Post-mortem **sin culpabilización** (blameless): se analiza el sistema y
   el diseño, nunca a quien lo escribió.

El tono del post-mortem es sereno y analítico. El humor cálido del resto del
curso baja un punto aquí: un post-mortem es serio, aunque no acartonado.

---

## 14. Checklist rápido antes de dar por cerrado un `.md`

- [ ] Sigue la plantilla de 9 secciones (o el formato de apéndice).
- [ ] Tono cálido e informal, segunda persona **con "tú", sin voseo**, humor
      con moderación.
- [ ] Todo el código corre con las versiones fijadas en la semilla.
- [ ] **Tablas, columnas, endpoints, servicios, constantes y enums del
      código en inglés (§4).**
- [ ] **Comentarios de código y mensajes/textos de interfaz en español (§4.5).**
- [ ] No contradice ninguna fase anterior; respeta el árbol de decisión y el
      veredicto del marco de 5 preguntas de la semilla.
- [ ] Distingue capas (ruta / service / motor / arnés) donde importa.
- [ ] Usa el vocabulario de callouts (📝 🪦 📚 ⚠️ 💡) y los recuadros propios
      del curso (📖 🪞 🩻 ⚰️) donde aporten.
- [ ] Marca 💸 la deuda técnica (y la paga si corresponde) y 🔥 lo opcional.
- [ ] Tiene entre 20 y 40 ejercicios (objetivo 30) numerados con rangos
      🟢🟡🟠🔴 equilibrados y con **diversidad de dificultad dentro de cada
      rango** (o 5-10 en apéndices), con al menos cinco de diagnóstico.
- [ ] Todo "vs" citado en el texto está respaldado por una entrada real en
      `BENCHMARKS.md`, nunca narrado a ojo.
- [ ] **Referencias al final de la fase**, con URL completa, secciones
      (oficial / papers y libros / video / orden de lectura), y advertencia
      de verificación de versión, título y URL.
- [ ] Explica el *porqué* de cada decisión relevante.
- [ ] Incluye "La señal de que quedó bien" en el cierre.
