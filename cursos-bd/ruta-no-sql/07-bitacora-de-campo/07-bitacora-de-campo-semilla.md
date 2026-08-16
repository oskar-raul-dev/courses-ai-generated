# 📴 Proyecto Bitácora de Campo — Semilla del curso (Offline-first: sincronización; el conflicto de escritura concurrente sin coordinación como caso normal)

## 🎯 Motivación

Tu carrera relacional te entrenó, sin que lo notaras, en un supuesto tan
profundo que dejó de parecer un supuesto: **existe un único nodo autoritativo
que arbitra cada escritura en el instante en que ocurre.** Cuando dos
transacciones tocan la misma fila, el motor las serializa —con un lock, con
MVCC, con un `SERIALIZABLE` que aborta a la perdedora— y el resultado es un
orden total que todo el mundo acepta porque todo el mundo le preguntó al mismo
árbitro antes de escribir. ACID no es solo atomicidad y durabilidad: es la
promesa de que *hubo coordinación previa*. Esa promesa es el aire que respira
el modelo relacional.

El modelo offline-first arranca amputando exactamente ese supuesto. La
pregunta que lo define no es "¿cómo hago esto rápido?" ni "¿cómo escalo las
lecturas?": es **"¿qué pasa cuando dos nodos escribieron lo mismo sin poder
preguntarle a nadie, y recién ahora, minutos u horas después, se vuelven a
ver?"**. En un sistema donde el dispositivo *tiene* que funcionar sin red
—no como degradación graciosa, sino como estado operativo normal durante
horas— no hay árbitro al que consultar en el momento de escribir. Cada nodo
es, temporalmente, su propia autoridad. La coordinación no desaparece: se
**difiere** al momento de la reconexión, y con ella aparece el problema que
lo relacional clásico trata como anomalía a evitar y este modelo trata como
caso central a resolver: el **conflicto de escritura concurrente**.

¿Puede lo relacional hacer esto? Puede, con la misma lógica con la que puede
hacer cualquier cosa: a fuerza de simularlo. Cola de operaciones pendientes
en el cliente, columna `version` para detección optimista, un endpoint de
reconciliación escrito a mano que decide quién gana, un `updated_at` que
alguien reza que baste como reloj. Funciona hasta que no: hasta el primer
conflicto de tres vías, hasta el borrado-contra-edición, hasta el reloj del
dispositivo que estaba dos horas adelantado. El punto no es que sea imposible
—es que estás construyendo, a mano y sin red de contención, un protocolo de
replicación con resolución de conflictos que motores diseñados para esto
llevan quince años puliendo. Ese es exactamente el mismo error que cometió
quien puso un catálogo en una tabla EAV: usar el motor de propósito general
para simular una estructura de acceso que otro motor codifica de fábrica.

Lo que ganas como ingeniero senior al dominar este modelo es doble. Primero,
un tipo de proyecto que antes no podías tomar con seriedad: apps de trabajo de
campo (inspecciones, censos, auditorías, ventas en terreno, logística en
zonas muertas), herramientas colaborativas que sobreviven al túnel del metro,
cualquier producto cuyo requisito literal sea "tiene que funcionar sin señal".
Segundo, y más transferible: dejas de cometer el error de arquitectura de
*bolt-on sync* —atornillar sincronización sobre un backend que asumió
conexión constante— y aprendes a reconocer, en la fase de diseño, cuándo el
conflicto es parte del dominio y no un caso límite. Ese instinto vale aunque
el motor que uses hoy desaparezca mañana: **el modelo de consistencia bajo
desconexión sobrevive al producto que lo implementa.**

---

## 🏗️ El dominio: una app de inspecciones de campo que funciona sin red

Bitácora de Campo es una aplicación para inspectores que trabajan donde la
conexión no existe o es intermitente: una obra en construcción en el sótano,
una finca rural sin cobertura, una bodega de metal que actúa como jaula de
Faraday, un socavón minero. El inspector abre la app en la mañana, sincroniza
lo que puede, **se va del alcance de toda red durante seis horas**, realiza
entre veinte y cincuenta inspecciones —cada una con formulario, fotos, firma,
geolocalización, timestamp—, y por la tarde, al volver a cobertura (o al
conectarse por la noche desde casa), **todo lo que hizo debe subir y todo lo
que cambió en el servidor mientras tanto debe bajar.**

El dominio no es un pretexto para enseñar sync: *exhibe* el patrón de forma
nativa. La desconexión prolongada no es un caso de prueba artificial, es la
jornada laboral. Y el conflicto no es hipotético: dos inspectores pueden ser
asignados por error a la misma instalación, un supervisor puede reasignar una
inspección desde la oficina mientras el inspector ya la está completando en
campo, o el mismo inspector puede editar un borrador desde su tablet y desde
su teléfono. El sistema no puede "prohibir" esto pidiendo permiso antes de
escribir, porque en el momento de escribir **no hay a quién pedírselo.**

### Las entidades y su forma

El corazón del dominio es la **inspección** (`inspection`): un documento
autocontenido que un inspector produce en campo. Lleva un formulario cuyos
campos dependen del **tipo de inspección** (`inspectionType`) —una inspección
eléctrica no tiene los mismos campos que una sanitaria—, un conjunto de
**hallazgos** (`findings`, subdocumentos con severidad y descripción), cero o
más **adjuntos** (`attachments`: fotos, firmas), la geolocalización capturada,
y metadatos de sincronización que el modelo necesita y que en SQL rara vez son
de primera clase: identidad del dispositivo de origen, timestamp lógico, y el
historial de revisiones que permite reconstruir qué pasó cuando dos versiones
chocan.

| Entidad | Campos distintivos | Por qué vive así |
|---|---|---|
| `inspection` | `formData`, `findings[]`, `attachments[]`, `geo`, `status`, `deviceId`, `rev` | agregado autocontenido que se crea y edita **entero**, offline, en un solo dispositivo |
| `inspectionType` | `schema` (campos válidos por tipo), `version` | forma variable por tipo; se replica al cliente para validar sin red |
| `site` | `name`, `address`, `geo`, `assignedTo` | la instalación inspeccionada; punto de conflicto de reasignación |
| `inspector` | `name`, `deviceIds[]`, `region` | un humano con uno o varios dispositivos, cada uno un nodo de escritura |
| `attachment` | binario + `mimeType` + `checksum` | el caso especial: replicación de binarios grandes, no solo JSON |

La unidad natural de lectura y escritura es **la inspección completa**: se
crea entera en campo, se edita entera, se sincroniza entera. Esa localidad es
la que hace del modelo documental-que-replica el ajuste natural, y la que hace
que el binario adjunto (foto de 4 MB) sea un problema distinto del documento
JSON que lo referencia —un matiz que el curso trata explícitamente, porque la
replicación de attachments es donde CouchDB, Firestore y una solución casera
divergen más.

### El marco de 5 preguntas, aplicado ANTES de modelar

| Pregunta | Veredicto para Bitácora de Campo |
|---|---|
| ¿Qué se lee junto? | la inspección completa: formulario + hallazgos + adjuntos + geo, siempre como una pieza |
| ¿Quién custodia la forma y las invariantes? | el **tipo de inspección** define el esquema; pero la validez se comprueba **en el dispositivo**, sin red, porque no hay servidor que consultar en campo |
| ¿Cuánto se une en caliente? | casi nada durante el trabajo de campo: el dispositivo tiene localmente todo lo que necesita; los cruces (¿quién inspeccionó qué?) ocurren en el servidor tras sincronizar |
| ¿Dónde viven las invariantes? | dentro de la inspección y en las reglas de resolución de conflicto; el reto no es la invariante en un nodo, es **reconciliar dos nodos que evolucionaron por separado** |
| ¿Qué pide la operación? | escritura local sin latencia de red, disponibilidad total offline, sincronización bidireccional eventual, y **resolución de conflicto como operación normal, no como error** |

**Veredicto: vota offline-first 5-0** — pero con un matiz honesto que el curso
sostiene desde el día 0. El dominio vota *sincronización con tolerancia a
desconexión* de forma inequívoca; lo que **no** está pre-decidido es *qué
motor* de sincronización, porque la categoría se ha fracturado (ver el "vs" y
las consideraciones finales). El veredicto elige el modelo de acceso, no el
producto. Elegirlo con números es el trabajo del curso.

### El villano: asumir conexión constante y tratar el conflicto como excepción rara

El anti-patrón que Bitácora de Campo disecciona con autopsia medida es el que
casi todo backend comete por defecto: **`campo_v1`**, un servicio construido
sobre el supuesto de conexión permanente, al que alguien —cuando el producto
descubrió que sus usuarios trabajan sin señal— le atornilló sincronización a
mano. Es feo por diseño, y como el villano de todo el resto de la ruta, no es
feo por su idioma sino por sus decisiones:

- Una cola de operaciones en el cliente (`pendingOps[]`) que se reproducen en
  orden de llegada al servidor, con `last-write-wins` implícito por
  `updated_at` —usando el **reloj de pared del dispositivo**, que miente.
- Detección de conflicto con una sola columna `version` entera, que reconoce
  "hubo un cambio" pero no puede reconstruir *qué* cambió ni fusionar dos
  ediciones no solapadas del mismo documento.
- El conflicto de tres vías (servidor + dos dispositivos) no contemplado: el
  segundo en llegar pisa al primero sin dejar rastro.
- El borrado-contra-edición resuelto por accidente, casi siempre mal.
- Attachments binarios subidos por un endpoint aparte que no participa del
  protocolo de sync, de modo que una foto puede quedar huérfana de su
  inspección o viceversa.

`campo_v1` funciona en la demo, con wifi de oficina, con un solo inspector.
Se desangra en producción el primer día de campo real. El curso lo mide de
punta a punta —tasa de escrituras perdidas bajo desconexión concurrente,
conflictos silenciosamente mal resueltos, binarios huérfanos— y luego muestra
cuánto de ese dolor desaparece cuando el protocolo de replicación con
resolución de conflictos es una primitiva del motor y no código de aplicación
escrito bajo presión. **El villano no es "usar sync": es fingir que la
desconexión es rara y el conflicto un bug.**

---

## 📐 Stack (2026, estable y moderno)

Todo el stack es open source, de acceso libre en entorno de desarrollo, y
**enteramente contenerizado**. La audiencia ya vive en contenedores; el
laboratorio de la Fase 0 arranca con un solo `docker compose up`.

| Componente | Versión / elección | Rol |
|---|---|---|
| CouchDB | **3.5.2** | motor de sincronización principal (servidor de replicación offline-first) |
| PouchDB | **9.0.0** | contraparte de cliente de CouchDB; base local en el dispositivo, habla el mismo protocolo de replicación |
| Node.js | **24 LTS** ("Krypton") | runtime del backend y de los scripts |
| TypeScript | **5.x** (última) | tipado en todo el código de aplicación |
| Express | **5.x** (última) | API de aplicación (auth, validación de negocio, endpoints que no son sync) |
| Firebase / Firestore | SDK v12+ (última) | **rival gestionado** del "vs": sync offline-first como servicio administrado |
| ElectricSQL | **última** (motor de sync sobre Postgres) | **rival del enfoque relacional-que-sincroniza**; ver nota crítica abajo, su modelo cambió |
| PostgreSQL | **18.6** | motor bajo ElectricSQL y base del `campo_v1` relacional del villano |
| Zod | última | validación de aplicación en el cliente (el esquema del `inspectionType`, comprobado sin red) |
| Docker / Podman | Compose v2 | orquestación de todo el laboratorio |

> ⚠️ **CouchDB ≠ Couchbase.** El motor de este curso es **CouchDB** (Erlang,
> licencia Apache 2.0, diseñado desde el origen para replicación
> multi-primaria y offline-first), con **PouchDB** como su contraparte
> JavaScript en el cliente. **No es Couchbase** (C++, N1QL, memoria-first,
> source-available bajo BSL, orientado a operacional de baja latencia).
> Comparten prefijo y ancestro histórico y nada más que importe aquí. Si en
> algún momento el texto dice "Couchbase", es un error: revísalo.

### Por qué CouchDB + PouchDB como eje

Porque son la implementación **fundacional y de referencia** del modelo, y
—crucialmente para un curso que enseña el *modelo* y no el *producto*— porque
el par expone el protocolo de replicación como el objeto de estudio central:
CouchDB en el servidor y PouchDB en el cliente hablan exactamente el mismo
protocolo de replicación incremental, y la resolución de conflictos es
explícita y visible (documentos con múltiples revisiones en conflicto que el
desarrollador ve y resuelve, en vez de una fusión mágica opaca). Eso es
pedagógicamente oro: el estudiante *ve* el conflicto como dato de primera
clase, no como un log de error. PouchDB 9 además incorpora el adaptador
`nodesqlite` (persistencia sobre el SQLite nativo de Node), lo que simplifica
correr el "cliente" en el laboratorio sin navegador.

### Por qué esos rivales, y el matiz de ElectricSQL

El "vs" necesita cubrir las tres respuestas reales que un equipo evaluaría hoy:

- **Firebase/Firestore** es el rival **gestionado y de mayor adopción móvil**:
  responde "¿y si no quiero operar el motor de sync yo mismo?". Trae su
  resolución de conflictos (last-write-wins por defecto, con
  timestamps del servidor) y su costo operativo tercerizado. Medirlo obliga a
  discutir el eje operar-vs-pagar, no solo latencia.

- **ElectricSQL** es el rival del enfoque **"no cambies de paradigma, sincroniza
  tu Postgres"**. Aquí va una advertencia que la semilla fija para que el curso
  no prometa lo que el producto ya no hace: **ElectricSQL en 2026 es un motor
  de sync unidireccional read-path** —Postgres → cliente vía shapes sobre HTTP,
  con las **escrituras yendo directo al backend por la API existente**. Ya no
  es el "local-first bidireccional con CRDTs en cada cliente" de sus primeras
  versiones. Esto lo hace un rival **fascinante y honesto** justamente por el
  contraste: es excelente para "lecturas en vivo, siempre frescas, tolerantes a
  red mala", pero **no resuelve por sí solo el conflicto de escritura offline
  concurrente**, que es el corazón del dominio. Medirlo enseña la lección más
  importante del curso: no todo lo que se llama "sync" resuelve el mismo
  problema. El curso lo trata con rigor, sin caricaturizarlo y sin fingir que
  la categoría es homogénea.

- **`campo_v1` sobre PostgreSQL 18** es el villano medible: la sincronización
  casera atornillada, para tener el "antes" numérico de la autopsia.

### Por qué TypeScript + Node

Porque el modelo vive en el cliente tanto como en el servidor, y JavaScript/
TypeScript es el único ecosistema donde el **mismo lenguaje y el mismo
protocolo** corren en ambos lados (PouchDB en el dispositivo, CouchDB detrás,
Node orquestando). Es multiplataforma real (Linux, macOS, Windows vía WSL) y
se contineriza sin fricción. Un curso de sync en dos lenguajes distintos
gastaría medio presupuesto pedagógico traduciendo tipos entre cliente y
servidor; aquí ese costo es cero.

### Validación en capas (sin red)

- **Zod** en el cliente: valida el formulario contra el `schema` del
  `inspectionType` **en el dispositivo, sin conexión**, porque la validez no
  puede depender de un servidor que no está.
- **Validación en el servidor** (CouchDB `validate_doc_update` y/o la capa
  Express): la última línea, la que ningún cliente puede esquivar al replicar.

---

## ⚖️ El método del "vs": un arnés, no anécdotas

Desde la Fase 0 se monta `scripts/vs.ts`: un arnés que ejecuta **el mismo
escenario semántico** contra los motores en juego, lo cronometra y lo mide,
y acumula resultados en `BENCHMARKS.md`. En un curso de sync, "la misma
consulta" rara vez es un `SELECT`: es un **escenario de replicación**
—desconectar N clientes, generar escrituras concurrentes, reconectar, medir
qué sobrevivió, cuánto tardó converger, cuántos conflictos se detectaron y
cuántos se perdieron en silencio. El arnés estandariza *ese* experimento para
que ningún "gana X" del curso salga de una anécdota.

Los duelos que atraviesan el curso, todos derivados de los rivales:

1. **CouchDB/PouchDB vs `campo_v1` (Postgres + sync casero)** — el eje
   principal: protocolo de replicación de fábrica vs atornillado a mano.
   Métrica reina: **escrituras perdidas y conflictos mal resueltos** bajo
   desconexión concurrente.
2. **CouchDB/PouchDB vs Firebase/Firestore** — motor propio operado vs servicio
   gestionado. Métricas: latencia de convergencia, comportamiento de la
   resolución por defecto, y el costo operativo/económico cualitativo.
3. **CouchDB/PouchDB vs ElectricSQL** — el duelo conceptual: sync completo
   bidireccional con conflicto de primera clase **vs** sync read-path
   unidireccional sobre Postgres. Mide qué problema resuelve cada uno, no cuál
   es "más rápido" —porque no compiten en la misma cancha, y demostrarlo es la
   lección.
4. **Replicación de attachments**: CouchDB vs Firestore Storage vs blob-en-tabla
   —el sub-duelo de los binarios grandes, que casi ningún benchmark cubre.

---

## 🌳 Estructura de fases

Doce fases. La Fase 0 monta el laboratorio contenerizado y el generador; la
última cierra con la autopsia del villano y el veredicto honesto. El número
—doce— responde a que el modelo tiene tres frentes que exigen fase propia y no
se pueden colapsar: el **protocolo de replicación** en sí, la **resolución de
conflictos** (el núcleo del modelo, merece dos fases), y la **replicación de
binarios**, que es un problema aparte del JSON.

| # | Fase | Núcleo | "Vs" de la fase |
|---|---|---|---|
| **0** | 🧪 El laboratorio que se desenchufa | Compose con CouchDB + Postgres + Firestore emulator + Electric. Generador de dataset semántico común. Nace `vs.ts` con su primitiva `disconnect()` | — (montaje) |
| **1** | ⚖️ El marco, para decidir | Las 5 preguntas ANTES de modelar. Se construye `campo_v1` (Postgres + cola casera) y se siente el dolor del primer conflicto en vivo | sync casero vs "aún nada" — el costo de escribirlo a mano |
| **2** | 🔁 Replicación 101: dos bases que se persiguen | CouchDB ↔ PouchDB, protocolo de replicación incremental, `_rev`. La primera sincronización que "simplemente funciona" | replicación de fábrica vs la cola de `campo_v1` |
| **3** | 📄 La inspección como agregado que viaja | Modelado del documento `inspection` autocontenido; por qué la localidad hace replicable la unidad | documento replicable vs filas dispersas en 6 tablas de Postgres |
| **4** | ⚡ Escribir sin red: la app que no espera al servidor | PouchDB como fuente de verdad local; UI optimista real (no simulada); Zod validando offline | latencia de escritura local vs round-trip a Postgres |
| **5** | ⭐ El conflicto como ciudadano de primera clase | `_rev` divergentes, revisiones en conflicto **visibles**; el modelo mental de "no hay verdad única hasta reconciliar" | detección de conflicto de CouchDB vs `version` entera de `campo_v1` |
| **6** | ⭐ Estrategias de resolución | last-write-wins honesto (con reloj lógico, no de pared), merge por campo, resolución con intervención humana; el borrado-contra-edición | resolución de fábrica vs la reconciliación a mano; ⚰️ mini-autopsia de LWW ingenuo |
| **7** | 🖼️ Attachments: replicar binarios, no solo JSON | Fotos y firmas como attachments replicados; checksum, deduplicación, el binario huérfano | CouchDB attachments vs Firestore Storage vs blob-en-tabla |
| **8** | 🌐 El servidor y la topología de sync | CouchDB en el centro, filtros de replicación (cada inspector sincroniza solo lo suyo), `validate_doc_update` como última línea | filtro de replicación vs endpoint de autorización casero |
| **9** | ☁️ El rival gestionado: Firestore de punta a punta | La misma app sobre Firestore; su resolución por defecto, su modelo de seguridad, su factura | Firestore vs CouchDB propio — operar vs pagar |
| **10** | 🔀 El rival relacional: ElectricSQL en su cancha | Shapes, sync read-path sobre Postgres; qué resuelve de verdad y qué deja al backend | 🩻 lo que ElectricSQL hace igual de bien + ⚖️ dónde no compite |
| **11** | ⚰️ La autopsia y el veredicto con las dos manos | `campo_v1` medido de punta a punta (escrituras perdidas, conflictos silenciosos, binarios huérfanos); conversión al modelo con números antes/después; ⚖️ cuándo NO usar offline-first | el ritual de cierre, medido |

### Fase 0 — 🧪 El laboratorio que se desenchufa
Monta con Docker Compose el escenario completo: un CouchDB, un PostgreSQL 18,
el emulador de Firestore y el servicio ElectricSQL, más un contenedor "cliente"
que corre PouchDB (adaptador `nodesqlite`) para simular dispositivos. Nace
`scripts/vs.ts` con su pieza distintiva: una primitiva `disconnect(clientId)`
/ `reconnect(clientId)` que corta y restaura la red de un nodo a voluntad —el
verbo sin el cual no se puede medir nada en este modelo. Se construye el
generador de datos que produce el mismo dataset semántico (inspectores, sitios,
tipos, inspecciones) en la forma de cada motor.

### Fase 1 — ⚖️ El marco, para decidir
Se aplican las 5 preguntas al dominio, en voz alta, antes de tocar un motor de
sync. Luego se construye deliberadamente `campo_v1`: Postgres, una tabla de
inspecciones, una cola de operaciones pendientes en el cliente, resolución
`last-write-wins` por `updated_at`. Se lo pone a funcionar y se provoca el
primer conflicto en vivo: dos clientes desconectados editan la misma
inspección, reconectan, y uno pisa al otro sin dejar rastro. 🪞 **Primer
instinto falsable:** "una columna `version` basta para detectar conflictos"
—predicción, cronómetro, veredicto.

### Fase 2 — 🔁 Replicación 101: dos bases que se persiguen
CouchDB y PouchDB, el protocolo de replicación incremental, el `_rev` y por
qué es un árbol y no un contador. La primera sincronización que funciona sola.
📖 Aquí abre el **diccionario de traducción** SQL → replicación (transacción ↔
lote de revisiones, `UPDATE` ↔ nueva revisión, no hay `UPDATE in place`).

### Fase 3 — 📄 La inspección como agregado que viaja
Se modela `inspection` como documento autocontenido y se explica por qué la
localidad —todo lo que se lee y escribe junto, junto— es lo que lo hace
replicable como una pieza. Contraste con las 6 tablas normalizadas que
`campo_v1` tendría que sincronizar coordinadamente.

### Fase 4 — ⚡ Escribir sin red: la app que no espera al servidor
PouchDB como fuente de verdad local: la app escribe al dispositivo, la UI
responde al instante, la red es un detalle de fondo. UI optimista **real**,
no el truco de "muestra el spinner y reza". Zod valida el formulario contra el
`schema` del tipo sin conexión. 🩻 **Esto sí viaja igual:** validación de
esquema, restricciones de dominio, tu instinto de "no confíes en la entrada"
—todo intacto; lo único que cambió es *dónde* y *cuándo* se valida.

### Fase 5 — ⭐ El conflicto como ciudadano de primera clase
El corazón del curso. Se fuerzan `_rev` divergentes y se muestra que CouchDB
**no esconde el conflicto**: guarda las revisiones en conflicto y te las
enseña. El cambio de modelo mental que recalibra al lector relacional: **no
existe una verdad única hasta que alguien reconcilia.** 🪞 "tu instinto SQL
dice 'el motor ya resolvió esto por mí'; esta vez el motor te entrega el
conflicto y espera tu decisión".

### Fase 6 — ⭐ Estrategias de resolución
Las opciones reales: last-write-wins **honesto** (con reloj lógico o vector,
nunca el reloj de pared del dispositivo), merge campo-a-campo cuando las
ediciones no se solapan, y resolución con intervención humana para lo que no se
puede fusionar automáticamente. El caso peliagudo del borrado-contra-edición.
⚰️ mini-autopsia: cuánto pierde el LWW ingenuo de `campo_v1` medido contra una
resolución consciente.

### Fase 7 — 🖼️ Attachments: replicar binarios, no solo JSON
Las fotos y la firma no son JSON y no se replican igual. Attachments de
CouchDB, checksums, deduplicación, y el bug clásico: el binario que llega sin
su documento o el documento que referencia un binario que nunca subió. Se mide
contra Firestore Storage y contra guardar el blob en una columna de Postgres.

### Fase 8 — 🌐 El servidor y la topología de sync
CouchDB en el centro, filtros de replicación para que cada inspector sincronice
solo sus sitios asignados (no toda la base), y `validate_doc_update` como la
validación que corre en el servidor y ningún cliente puede saltar al replicar.
El equivalente honesto de "autorización a nivel de fila", pero en el protocolo
de sync.

### Fase 9 — ☁️ El rival gestionado: Firestore de punta a punta
Se reconstruye la misma app sobre Firestore para sentir el otro extremo del eje
operar-vs-pagar: su resolución de conflictos por defecto, su modelo de reglas
de seguridad, su comportamiento offline en el SDK, y la factura. Medición
honesta: dónde Firestore te ahorra trabajo real y dónde te ata las manos.

### Fase 10 — 🔀 El rival relacional: ElectricSQL en su cancha
ElectricSQL evaluado por lo que **es** en 2026: shapes, sync read-path
unidireccional sobre Postgres, escrituras por la API del backend. 🩻 Brilla
para lecturas en vivo siempre frescas sobre red mala; ⚖️ pero **no resuelve
solo** el conflicto de escritura offline concurrente. La fase mide ambas cosas
sin caricatura y extrae la lección: "sync" nombra problemas distintos, y elegir
mal el motor es elegir mal el problema.

### Fase 11 — ⚰️ La autopsia y el veredicto con las dos manos
`campo_v1` medido entero: tasa de escrituras perdidas, conflictos resueltos
mal en silencio, binarios huérfanos, todo con número. Conversión al modelo
offline-first con el antes/después a la vista. Y el ⚖️ **veredicto honesto**:
cuándo **NO** usar offline-first —cuando la conexión sí es fiable y constante,
cuando el conflicto real es tan raro que su costo de infraestructura no se
paga, cuando una lectura fresca en vivo (ElectricSQL) o un simple
optimistic-UI con reintento basta. El fanboy de offline-first —que mete
replicación multi-primaria donde un CRUD con caché habría bastado— es el
villano en su dirección inversa, y también se nombra.

### Apéndices

- **A) Arranque de motores vía contenedores** — CouchDB, Postgres, emulador de
  Firestore y ElectricSQL con Compose; puertos, volúmenes, credenciales de
  laboratorio.
- **B) `docker-compose.yml` / `Containerfile` de trabajo** — el archivo real
  del laboratorio, comentado en español.
- **C) Guía rápida del protocolo de replicación** — `_rev`, árbol de
  revisiones, `_conflicts`, `bulk_docs`, filtros de replicación: la "cheat
  sheet" del modelo.
- **D) Generador de datos** — el script TS que siembra inspectores, sitios,
  tipos e inspecciones en las formas de cada motor, con un modo "provoca
  conflicto" para los benchmarks.
- **E) Troubleshooting de setup** — el emulador de Firestore que no levanta,
  el `_rev` que no coincide, PouchDB `nodesqlite` en el contenedor, CORS de
  CouchDB, el reloj del contenedor desincronizado (que en este curso *sí*
  importa).

---

## 📓 Artefactos acumulativos

**`INSTINTOS.md`** recoge, fase a fase, cada instinto relacional que el curso
pone a prueba: "una columna `version` detecta conflictos", "`updated_at` sirve
como reloj para ordenar escrituras", "el motor siempre resuelve el conflicto
por mí", "sincronizar es subir una cola de operaciones", "un binario se sube
por su propio endpoint y ya". Cada entrada lleva la **predicción** del lector,
el **experimento** que la falsó o confirmó, y el **veredicto escrito**. Crece
como el diario de recalibración del instinto.

**`BENCHMARKS.md`** acumula todo "vs" corrido con `vs.ts`: nunca un "gana X"
narrado, siempre el escenario, los parámetros (cuántos clientes, cuánto tiempo
desconectados, cuántas escrituras concurrentes), y los números —convergencia,
escrituras perdidas, conflictos detectados vs perdidos, latencia de escritura
local, peso replicado. Es el contrapeso medido de `INSTINTOS.md`: uno guarda lo
que creíamos, el otro lo que medimos.

---

## 📚 Referencias por fase (semilla)

> ⚠️ **Verificar todo.** Las URLs, títulos de libro e IDs/títulos de video de
> abajo son punto de partida y **deben verificarse** antes de publicarse: las
> versiones de la documentación cambian, los videos se borran o se renombran.
> No se han inventado números de página ni IDs de video; donde no hay un dato
> confiable, no se pone. Prioridad de lectura: **documentación oficial de la
> versión fijada primero**, luego libros, luego video.

**Transversales (todo el curso)**
- CouchDB 3.5 (manual oficial): https://docs.couchdb.org/en/stable/ — verificar que apunte a la 3.5.x
- PouchDB (guías y API): https://pouchdb.com/ y https://pouchdb.com/api.html
- PouchDB 9 (notas de versión): https://pouchdb.apache.org/ (blog de releases)
- Node.js 24 LTS (docs): https://nodejs.org/docs/latest-v24.x/api/
- Docker Compose v2: https://docs.docker.com/compose/

**Fase 0–1 (laboratorio y marco)**
- Guía "Getting Started" de CouchDB: https://docs.couchdb.org/en/stable/intro/index.html
- PostgreSQL 18 (docs): https://www.postgresql.org/docs/18/
- *Orden sugerido:* intro de CouchDB → levantar el Compose → releer las 5 preguntas del marco antes de escribir una línea de `campo_v1`.

**Fase 2–3 (replicación y modelado)**
- Replicación en CouchDB: https://docs.couchdb.org/en/stable/replication/intro.html
- Modelo de revisiones (`_rev`): https://docs.couchdb.org/en/stable/intro/api.html — sección de revisiones
- Libro: *CouchDB: The Definitive Guide* (O'Reilly) — verificar edición y vigencia; partes del protocolo siguen válidas aunque el libro es antiguo.
- *Orden sugerido:* replicación → revisiones → recién entonces modelar el documento.

**Fase 4–6 (offline, conflicto, resolución) — el núcleo**
- Conflictos en PouchDB (guía dedicada): https://pouchdb.com/guides/conflicts.html
- Resolución de conflictos, CouchDB: https://docs.couchdb.org/en/stable/replication/conflicts.html
- Zod (validación): https://zod.dev/
- *Orden sugerido:* guía de conflictos de PouchDB (la más clara) → doc de CouchDB para el detalle del árbol de revisiones → estrategias de resolución.

**Fase 7 (attachments)**
- Attachments en CouchDB: https://docs.couchdb.org/en/stable/api/document/attachments.html
- Attachments en PouchDB: https://pouchdb.com/guides/attachments.html

**Fase 8 (servidor y topología)**
- `validate_doc_update`: https://docs.couchdb.org/en/stable/ddocs/ddocs.html — sección de validación
- Replicación filtrada: https://docs.couchdb.org/en/stable/replication/intro.html — filtros

**Fase 9 (Firestore)**
- Firestore, comportamiento offline: https://firebase.google.com/docs/firestore/manage-data/enable-offline
- Emulador local de Firestore: https://firebase.google.com/docs/emulator-suite
- *Advertencia de versión:* el SDK de Firebase evoluciona rápido; confirmar la versión mayor vigente al redactar.

**Fase 10 (ElectricSQL)**
- ElectricSQL (docs oficiales): https://electric-sql.com/docs — **verificar**, el proyecto reorganizó su sitio y su modelo; confirmar que la doc describe el motor de sync read-path actual y no una versión anterior con CRDTs bidireccionales.
- Concepto de Shapes: buscar la guía de "Shapes" en la doc vigente.

**Fase 11 (autopsia y veredicto)**
- Sin fuente nueva: se apoya en lo ya medido en `BENCHMARKS.md`.

**Video / YouTube de apoyo**
- Buscar charlas recientes sobre "local-first" y "offline-first sync" (p. ej. del movimiento *local-first software*) — **verificar autor, vigencia y que la charla no describa una versión obsoleta del stack** antes de citar. No se fija aquí ningún ID concreto por la regla de no inventar.

---

## 🧪 Nota sobre ejercicios

Cada fase llevará entre **20 y 40 ejercicios** graduados 🟢🟡🟠🔴, todos
anclados al dominio de Bitácora de Campo (inspecciones, inspectores,
dispositivos, sitios, conflictos reales). Distribución sugerida para ~30:
~8 🟢, ~9 🟡, ~7 🟠, ~4–6 🔴, más los 🔥 opcionales aparte.

Al menos un puñado por fase deben ser de **diagnóstico**: se entrega un bug y
se pide reproducir y localizar, no solo construir. En este modelo los bugs de
diagnóstico son especialmente jugosos y deben abundar en las fases 5–7:
"reproduce la escritura que se pierde cuando dos dispositivos editan offline y
reconectan en cierto orden", "localiza por qué esta foto quedó huérfana de su
inspección", "explica por qué esta resolución LWW borró un hallazgo que nadie
quería borrar", "el reloj de este contenedor está adelantado 90 minutos:
demuestra qué escritura gana mal y arréglalo con un reloj lógico". Los 🔴
integran varias fases o cierran un conflicto de tres vías reproducible.

---

## 🧩 Decisiones pendientes de confirmar antes de redactar la Fase 0

- [ ] **Dataset semilla:** ¿inspecciones sintéticas generadas por script (control total del escenario de conflicto) o un dataset público de inspecciones adaptado? *Propuesta por defecto:* sintético generado, porque el curso necesita provocar conflictos deterministas y reproducibles; un dataset real no da control sobre la concurrencia. Pendiente de confirmar.
- [ ] **¿Cliente de laboratorio con o sin navegador?** *Propuesta por defecto:* PouchDB con adaptador `nodesqlite` en un contenedor Node, para que todo el "vs" corra headless y reproducible; una demo con navegador queda como 🔥 opcional. Pendiente.
- [ ] **¿Firestore entra desde la Fase 0 (emulador siempre levantado) o se reserva a la Fase 9?** *Propuesta por defecto:* montado en Compose desde la Fase 0 pero solo ejercitado en la 9, para no cargar el laboratorio inicial de conceptos ajenos. Pendiente.
- [ ] **¿ElectricSQL se implementa de verdad o se documenta como diseño?** *Propuesta por defecto:* se implementa lo mínimo para medir su sync read-path real (una shape en vivo), no una integración completa; su rol es contraste conceptual medido, no un pilar del proyecto. Pendiente.
- [ ] **¿El servidor central es CouchDB puro o CouchDB detrás de Express?** *Propuesta por defecto:* CouchDB directo para el sync + Express al lado para auth y lógica de negocio que no es replicación. Confirmar el reparto de responsabilidades.
- [ ] **Estrategia de resolución "de la casa":** ¿el proyecto adopta LWW-con-reloj-lógico como default y merge/humano como opt-in, o al revés? Pendiente de fijar en la Fase 6.
- [ ] **Formato de fase:** ¿se mantiene la plantilla de 9 secciones o se ajusta por ser un curso de 12 fases centrado en un solo modelo? *Propuesta:* mantener las 9 secciones; el modelo lo justifica.

---

## 💭 Consideraciones adicionales

### CouchDB ≠ Couchbase (lo más importante de no equivocar)
Ya está en el aviso del stack, pero se repite porque es el error más fácil y
más caro de este curso. **CouchDB** (Erlang, Apache 2.0, replicación
offline-first, contraparte PouchDB) es el motor de Bitácora de Campo.
**Couchbase** (C++, N1QL, memoria-first, source-available) no aparece en este
curso en ningún rol. Comparten un ancestro histórico —Damien Katz fundó ambos—
y divergen desde 2011 en licencia, lenguaje, arquitectura y nicho. Cualquier
mención de "Couchbase" en material de este curso es un bug a corregir.

### El costo operativo del modelo, dicho sin adornos
Adoptar offline-first no es gratis. Un CouchDB propio es una superficie
operativa completa: backups, monitoreo, gestión de compactación (el archivo
crece con cada revisión hasta que se compacta), y —lo más subestimado— la
**carga cognitiva permanente del equipo** para razonar sobre un sistema donde
"el dato correcto" es una función de reconciliación y no una fila. La
resolución de conflictos no se termina de escribir nunca: cada campo nuevo del
formulario puede introducir una nueva forma de conflicto. El curso obliga a
nombrar este costo en la Fase 11, porque un veredicto honesto lo incluye.

### Los límites de la analogía con SQL
El lector viene de un mundo de un solo reloj y una sola verdad. Dos analogías
lo ayudan pero lo pueden traicionar. La detección optimista de concurrencia
(`version` / `xmin`) **se parece** al `_rev`, pero el `_rev` es un árbol, no un
contador: retiene la historia divergente en vez de rechazarla. Y `updated_at`
**parece** un reloj utilizable para ordenar, pero entre dispositivos sin
sincronización horaria es una mentira peligrosa; el modelo necesita relojes
lógicos. El curso nombra estas dos trampas explícitamente (🪞) antes de que el
lector caiga en ellas por inercia relacional.

### Cómo se valida contra un mercado real (productizable: ✅ Muy fuerte)
El dominio no es un laboratorio sin contraparte: hay un mercado real y
verificable de plataformas de inspección y trabajo de campo offline-first
(software de inspección de construcción, auditoría de seguridad, gestión de
activos en terreno, censos y encuestas sin conexión). El curso se ancla a esa
necesidad de negocio: lo que se construye es reconocible como el núcleo técnico
de un producto que ya existe y se vende. Eso mantiene el aprendizaje pegado a
una necesidad verificable y no a un ejercicio de vitrina —y le da al graduado
un portfolio que habla el idioma de un sector concreto.

### El riesgo pedagógico a vigilar
El mayor riesgo del curso es que el estudiante salga **enamorado** del modelo y
lo lleve a todas partes —el villano en su dirección inversa. La Fase 11 existe
para vacunar contra eso: la mitad del veredicto es "cuándo SÍ", la otra mitad,
igual de medida, es "cuándo esto es sobre-ingeniería y un optimistic-UI con
reintento, o un ElectricSQL para lecturas frescas, resuelve el problema real
sin montar un motor de replicación multi-primaria que alguien tendrá que operar
un martes a las 3 am".
