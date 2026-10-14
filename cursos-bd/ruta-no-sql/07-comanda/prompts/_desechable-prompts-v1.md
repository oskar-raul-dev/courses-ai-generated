# 🧵 Prompts — Bitácora de Campo

Prompts reutilizables para generar el curso en una conversación nueva, sin
necesitar este proyecto abierto. Cada prompt es **autónomo**: trae el
contexto mínimo (dominio, stack, villano, reglas de forma) para poder
correr solo. Úsalos pegándolos completos al inicio de un chat nuevo, o como
plantilla para encadenar fase tras fase dentro del mismo chat de redacción.

Orden de uso: **Prompt 0** (arranque) → **Prompt de fase** (uno por cada
fase 1–11, rellenando los placeholders con la tabla de la §3) → **prompts de
artefactos transversales** (se disparan cuando la fase que se está
escribiendo los toca por primera vez, y se actualizan en cada fase
siguiente).

---

## 0. Contexto mínimo compartido (pégalo o resúmelo antes de cualquier prompt)

Si vas a usar cualquiera de los prompts de abajo en un chat que **no** tiene
este proyecto cargado, antepón este bloque:

```
Estoy escribiendo el curso "Bitácora de Campo" de una ruta de formación
NoSQL. Enseña el modelo offline-first (sincronización con conflicto de
escritura concurrente como caso normal, no excepción) a través de una app
de inspecciones de campo.

DOMINIO: un inspector trabaja hasta 6 horas sin señal (obra, finca rural,
bodega metálica, socavón minero), hace 20-50 inspecciones (formulario +
hallazgos + fotos + firma + geolocalización), y al reconectar debe subir
todo lo local y bajar todo lo remoto, incluyendo el caso donde dos
inspectores editaron lo mismo mientras ambos estaban offline.

ENTIDADES: inspection (formData, findings[], attachments[], geo, status,
deviceId, rev), inspectionType (schema, version), site (name, address, geo,
assignedTo), inspector (name, deviceIds[], region), attachment (binario +
mimeType + checksum). La unidad de lectura/escritura es LA INSPECCIÓN
COMPLETA.

STACK FIJADO (2026): CouchDB 3.5.2 (servidor de sync) + PouchDB 9.0.0
(cliente, adaptador nodesqlite) + Node.js 24 LTS + TypeScript 5.x +
Express 5.x + Firebase/Firestore SDK v12+ (rival gestionado) + ElectricSQL
última (rival read-path sobre Postgres — en 2026 es sync UNIDIRECCIONAL
read-path vía shapes, las escrituras van por la API del backend, NO es el
local-first bidireccional con CRDTs de sus primeras versiones) + PostgreSQL
18.6 + Zod + Docker Compose v2. Todo contenerizado.

⚠️ CouchDB ≠ Couchbase. CouchDB (Erlang, replicación offline-first,
contraparte PouchDB) es el motor de este curso. Couchbase (C++, N1QL,
memoria-first) NO aparece en ningún rol. Nunca los confundas.

VILLANO: campo_v1, un backend sobre Postgres con conexión constante
asumida, al que se le atornilló sync a mano: cola de pendingOps[] con
last-write-wins por updated_at (reloj de pared del dispositivo), detección
de conflicto con una columna `version` entera que no reconstruye qué
cambió, conflicto de tres vías no contemplado, borrado-contra-edición mal
resuelto, attachments subidos por endpoint aparte del protocolo de sync.

EL "VS": 1) CouchDB/PouchDB vs campo_v1 (motor de fábrica vs atornillado a
mano — métrica reina: escrituras perdidas y conflictos mal resueltos bajo
desconexión concurrente), 2) CouchDB/PouchDB vs Firebase/Firestore (operar
vs pagar), 3) CouchDB/PouchDB vs ElectricSQL (sync bidireccional completo
vs read-path unidireccional — no compiten en la misma cancha, esa es la
lección), 4) replicación de attachments: CouchDB vs Firestore Storage vs
blob-en-tabla. Todo se mide con un arnés `scripts/vs.ts`, nunca se narra un
"gana X" sin número.

REGLAS DE FORMA: código en inglés, todo lo demás en español, SIN VOSEO
(usa "tú"). Tono cálido, informal, de colega senior a colega senior,
humor con moderación. Prosa antes que listas; tablas solo para comparar,
decidir o mapear. Plantilla de fase de 9 secciones obligatoria. 25-40
ejercicios graduados 🟢🟡🟠🔴 por fase (ideal 30; hasta 40 en fases 5-7 por
lo rico del diagnóstico), con numeración continua y encabezados de rango.
Callouts: 📝 nota de contexto, 📚 referencia inline, 🪦 retiro, ⚠️
advertencia, 💡 truco, 🔥 opcional, ⭐ fase central, 💸 (no aplica a este
curso salvo deuda declarada explícita). Recuadros propios: 📖 tabla de
traducción relacional↔offline-first, 🪞 "tu instinto SQL dice… y esta vez
no hay árbitro", 🩻 "esto sí viaja igual", ⚰️ autopsia del villano, ⚖️
veredicto honesto de cuándo NO usar el modelo.

No inventes números de página, DOIs ni IDs de video en referencias; marca
que URLs y títulos deben verificarse antes de publicar.

Sigue exactamente la guía BITACORA-DE-CAMPO-GUIA-ESTILO.md si está
disponible; si no lo está, usa las reglas de arriba como sustituto mínimo.
```

---

## 1. Prompt de arranque — Fase 0 (el laboratorio que se desenchufa)

```
[pegar el CONTEXTO MÍNIMO de la sección 0 si el chat no tiene el proyecto]

Redacta la Fase 0 del curso Bitácora de Campo: "🧪 El laboratorio que se
desenchufa".

NÚCLEO DE LA FASE: montar con Docker Compose el escenario completo — un
CouchDB, un PostgreSQL 18, el emulador de Firestore y el servicio
ElectricSQL, más un contenedor "cliente" que corre PouchDB (adaptador
nodesqlite) para simular dispositivos. Nace scripts/vs.ts con su pieza
distintiva: una primitiva disconnect(clientId)/reconnect(clientId) que
corta y restaura la red de un nodo a voluntad — el verbo sin el cual no se
puede medir nada en este modelo. Se construye el generador de datos que
produce el mismo dataset semántico (inspectores, sitios, tipos,
inspecciones) en la forma de cada motor.

"VS" DE LA FASE: ninguno todavía (es montaje) — pero deja el arnés listo
para que la Fase 1 mida el primer duelo.

DECISIONES PENDIENTES A RESOLVER O MARCAR EXPLÍCITAS EN ESTA FASE (toma la
opción por defecto si no hay indicación en contra, y dilo):
- Dataset semilla sintético generado por script (no dataset público real),
  para controlar el escenario de conflicto de forma determinista.
- Cliente de laboratorio sin navegador: PouchDB + adaptador nodesqlite en
  contenedor Node headless.
- Firestore montado en Compose desde ya, pero ejercitado recién en la
  Fase 9.
- Servidor central: CouchDB directo para el sync + Express al lado para
  auth/negocio.

Sigue la plantilla de 9 secciones. Cierra con su propia sección de
referencias (documentación oficial de CouchDB 3.5, PouchDB, Node 24 LTS,
Docker Compose v2 — URL completa, adviertiendo verificar versión). Genera
30 ejercicios graduados 🟢🟡🟠🔴, anclados a levantar y verificar el
laboratorio (no hay conflicto todavía que ejercitar, así que el foco es
montaje, generador de datos y primeras pruebas de `disconnect`/`reconnect`).
```

---

## 2. Prompt-plantilla por fase (fases 1 a 11)

Rellena los placeholders `[…]` con la fila correspondiente de la tabla de
fases de `07-bitacora-de-campo-semilla.md` (resumida en la §3 de abajo) y
pega el bloque completo.

```
[pegar el CONTEXTO MÍNIMO de la sección 0 si el chat no tiene el proyecto]

Redacta la Fase [N] del curso Bitácora de Campo: "[EMOJI TÍTULO DE LA FASE]".

NÚCLEO DE LA FASE: [núcleo — copiar de la tabla de fases].

"VS" DE LA FASE: [vs de la fase — copiar de la tabla de fases].

CONTEXTO DE LO YA CONSTRUIDO (no lo contradigas): [pegar aquí un resumen de
2-4 líneas de lo que las fases anteriores ya dejaron fijado — el modelo de
`inspection`, el estado de `campo_v1`, qué estrategia de resolución está
vigente, etc. Si es la primera fase que escribes en el chat, indica "ninguna
fase previa en este chat: asume el contenido de las fases anteriores según
07-bitacora-de-campo-semilla.md"].

Si esta fase corresponde a una de las marcadas ⭐ en la semilla (Fase 5 o 6),
trátala como pieza central: puede llevar más profundidad y más ejercicios de
diagnóstico que el resto.

Si esta fase toca por primera vez INSTINTOS.md, BENCHMARKS.md o
DICCIONARIO-SYNC.md, créalos o extiéndelos según los prompts de la sección 4
de BITACORA-DE-CAMPO-PROMPTS.md.

Sigue la plantilla de 9 secciones. Cierra con su propia sección de
referencias (URL completa, advertencia de versión — usa las fuentes fijadas
para esta fase en 07-bitacora-de-campo-semilla.md, sección "Referencias por
fase", si están disponibles; si no, busca la documentación oficial vigente
y marca que debe verificarse). Genera entre 25 y 40 ejercicios graduados
🟢🟡🟠🔴 con numeración continua y encabezados de rango, anclados al dominio
de inspecciones/sitios/inspectores/dispositivos. Si la fase es la 5, 6 o 7,
incluye un puñado explícito de ejercicios de diagnóstico (se entrega un bug,
se pide reproducir y localizar).
```

### Tabla-resumen de fases (para rellenar el prompt anterior)

| N | Título | Núcleo (resumen) | "Vs" de la fase |
|---|---|---|---|
| 1 | ⚖️ El marco, para decidir | 5 preguntas antes de modelar; se construye `campo_v1` y se siente el primer conflicto en vivo | sync casero vs "aún nada" |
| 2 | 🔁 Replicación 101 | CouchDB↔PouchDB, protocolo de replicación incremental, `_rev` como árbol | replicación de fábrica vs la cola de `campo_v1` |
| 3 | 📄 La inspección como agregado que viaja | Modelado del documento `inspection` autocontenido; la localidad como lo que hace replicable la unidad | documento replicable vs 6 tablas dispersas en Postgres |
| 4 | ⚡ Escribir sin red | PouchDB como fuente de verdad local; UI optimista real; Zod offline | latencia local vs round-trip a Postgres |
| 5 ⭐ | El conflicto como ciudadano de primera clase | `_rev` divergentes visibles; "no hay verdad única hasta reconciliar" | detección de CouchDB vs `version` entera de `campo_v1` |
| 6 ⭐ | Estrategias de resolución | LWW honesto (reloj lógico), merge campo-a-campo, intervención humana; borrado-contra-edición | resolución de fábrica vs reconciliación a mano; autopsia mini del LWW ingenuo |
| 7 | 🖼️ Attachments | Fotos/firmas como binarios replicados; checksum, deduplicación, adjunto huérfano | CouchDB attachments vs Firestore Storage vs blob-en-tabla |
| 8 | 🌐 El servidor y la topología de sync | Filtros de replicación por inspector/sitio, `validate_doc_update` | filtro de replicación vs endpoint de autorización casero |
| 9 | ☁️ Firestore de punta a punta | Reconstrucción sobre Firestore; resolución por defecto, reglas de seguridad, factura | Firestore vs CouchDB propio — operar vs pagar |
| 10 | 🔀 ElectricSQL en su cancha | Shapes, sync read-path sobre Postgres; qué resuelve y qué no | lo que hace igual de bien + dónde no compite |
| 11 | ⚰️ La autopsia y el veredicto | `campo_v1` medido entero; conversión con antes/después; veredicto de cuándo NO usar el modelo | el cierre, medido |

---

## 3. Prompt — artefacto acumulativo `INSTINTOS.md`

Dispara este prompt la primera vez que una fase produzca un instinto
falsable (típicamente desde la Fase 1), y repítelo cada fase siguiente para
extender el archivo.

```
[pegar el CONTEXTO MÍNIMO de la sección 0 si el chat no tiene el proyecto]

Actualiza (o crea, si no existe) INSTINTOS.md del curso Bitácora de Campo.

Es un artefacto acumulativo, fase a fase, de cada instinto relacional que el
curso pone a prueba. Por cada instinto nuevo que surgió en la fase que
acabas de escribir, agrega una entrada con esta estructura:

## [Nombre corto del instinto]
- **Predicción del lector:** qué esperaría alguien con instinto relacional.
- **Experimento:** qué se hizo para probarlo (con `vs.ts` o en vivo).
- **Veredicto:** qué pasó de verdad, con el número si lo hay.
- **Fase de origen:** [N].

Instintos típicos ya esperables en este curso (no te limites a esta lista,
pero no la contradigas si ya se escribió antes): "una columna `version`
basta para detectar conflictos", "`updated_at` sirve como reloj para
ordenar escrituras", "el motor siempre resuelve el conflicto por mí",
"sincronizar es subir una cola de operaciones", "un binario se sube por su
propio endpoint y ya".

No reescribas entradas de fases anteriores salvo error factual. Español,
sin voseo, tono cálido y directo.
```

---

## 4. Prompt — artefacto acumulativo `BENCHMARKS.md`

Dispara este prompt cada vez que una fase corre un escenario nuevo con
`scripts/vs.ts`.

```
[pegar el CONTEXTO MÍNIMO de la sección 0 si el chat no tiene el proyecto]

Actualiza (o crea, si no existe) BENCHMARKS.md del curso Bitácora de Campo.

Es el contrapeso medido de INSTINTOS.md: nunca un "gana X" narrado, siempre
el escenario, los parámetros y los números. Por cada corrida nueva de
scripts/vs.ts en la fase que acabas de escribir, agrega una entrada:

## [Nombre del escenario] — Fase [N]
- **Escenario:** qué se desconectó, cuántos clientes, cuánto tiempo
  desconectados, cuántas escrituras concurrentes, qué motores participan.
- **Parámetros exactos:** tabla con los valores usados.
- **Resultados:** convergencia (tiempo), escrituras perdidas, conflictos
  detectados vs conflictos perdidos en silencio, latencia de escritura
  local, peso replicado — los que apliquen al escenario.
- **Lectura:** una o dos frases de qué dice el número, sin narrar más allá
  de lo medido.

No inventes números: si esta fase no corrió el arnés todavía, no agregues
entrada — indícalo y detente. Español, sin voseo, tablas para los números,
prosa mínima para la lectura.
```

---

## 5. Prompt — diccionario de traducción `DICCIONARIO-SYNC.md`

Dispara este prompt junto con la Fase 2 (donde abre el primer diccionario
relacional→replicación) y actualízalo cada vez que una fase introduzca un
término nuevo.

```
[pegar el CONTEXTO MÍNIMO de la sección 0 si el chat no tiene el proyecto]

Actualiza (o crea, si no existe) DICCIONARIO-SYNC.md: el diccionario de
traducción relacional → offline-first de Bitácora de Campo.

Estructura: una tabla única, ordenada por tema (transacciones y escritura,
concurrencia y conflicto, relaciones y agregados, tiempo y orden,
validación), con columnas "Instinto relacional (SQL)" y "Su forma en
offline-first (CouchDB/PouchDB)". Ejemplo de fila ya fijada — no la
contradigas:

| Instinto relacional | Su forma en offline-first |
|---|---|
| columna `version` para concurrencia optimista | árbol de `_rev`: retiene ambas escrituras divergentes, no rechaza una |

Agrega las filas nuevas que la fase que acabas de escribir haya introducido.
No elimines filas existentes salvo error. Es tabla (regla §3 de la guía de
estilo: tablas solo para comparar/mapear), nada de prosa narrativa dentro
del diccionario — la prosa que explica cada fila vive en la fase misma, no
acá.
```
