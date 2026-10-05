# 🗒️ Plan de tandas — Ruta NoSQL Lite

> 🗑️ **Desechable.** Hoja de ruta de trabajo para escribir y publicar el curso por tandas. No se
> cita ni se enlaza desde ningún archivo del curso.
> **Creado:** 29/09/2026 · **Sustituye a** `_desechable-checklist-pendientes.md`, que queda
> obsoleto: todo lo que tenía abierto está trasladado aquí.
> **Cómo se usa:** cada tanda explica qué se hace y por qué va en ese orden; el checklist del
> final es lo que se marca a medida que se avanza.

---

## 📍 Dónde estamos

**Tanda 0 y Tanda 1 cerradas (29/09/2026).** Publicados F00 a F06 con el boss del Bloque I, los diez
apéndices en el estado que esas fases necesitan (a01, a02, a05, a06, a07 y a10 completos; a03, a04,
a08 y a09 creciendo), la bitácora con M-01 a M-10 y dos apuestas, `INSTINTOS.md` con dos entradas,
`0-programa-del-curso.md` y el README al día. Todo el código de `src/` pasa `tsc` limpio.

**Tanda 2 cerrada el 30/09/2026, salvo el boss III (va con la Tanda 4).** Lo siguiente son las Tandas 3 y
4, en ese orden, **sin tocar el `README.md` ni
`0-programa-del-curso.md`**: los dos se actualizan una sola vez, en la Tanda 7, cuando todo el
contenido esté escrito (ajuste del 30/09/2026). Quedan abiertas la verificación en Linux y en
Windows 11 (sección transversal) y la línea de `a04` sobre fan-out y amplificación de escritura, que
F06 no necesitó y pasa a la primera fase que la mida.

---

## ✍️ Cómo se escribe cada documento

**La entrada de cada fase y de cada apéndice es su prompt**, tal como está escrito:

- **Fases:** [`prompts-de-fase.md`](prompts-de-fase.md), un prompt por fase (las fases A y B de
  una familia comparten sección), con el marco común y el protocolo de tres pasos.
- **Apéndices:** [`prompts-de-apendice.md`](prompts-de-apendice.md), un prompt por apéndice,
  con su marco común y el mismo protocolo.

Cada documento sigue el protocolo que trae su prompt, sin saltarse pasos:

1. **Preguntas antes de escribir:** lectura del alcance, preguntas bloqueantes con su valor por
   defecto, esbozo de la sección más larga y contradicciones con lo ya escrito, dichas y no
   resueltas por cuenta propia.
2. **Redacción**, cuando las preguntas estén respondidas. Si aparece una duda nueva, se para y se
   pregunta.
3. **Autoverificación** contra el checklist de §15 de la guía, reportada en lista corta.

Si un prompt quedó desfasado respecto de una decisión posterior, **se corrige el prompt antes
de usarlo**, porque el prompt se actualiza después de los documentos base y nunca al revés. Por
encima de los prompts mandan el alcance, la guía y las dos propuestas.

---

## 🧱 Tanda 0 · Cerrar lo que bloquea la primera fase

**Qué se hace.** Terminar las cuatro piezas que el plan original pone antes de F01 y dejar
coherente lo que se tocó en la sesión de T10. No se publica nada: es el suelo sobre el que se
escriben todas las demás.

**En este orden, y por qué:**

1. **Revisar el generador antes de documentarlo.** Quitar el foco `aircraft`: 10 k aeronaves
   tardan 30 s, ocupan 1,7 GB y ninguna familia mide aeronaves (documental mide `part`). Después
   regenerar los datasets y volver a comprobar los hashes en las tres plataformas, porque quitar
   el foco no debería cambiar los demás, pero hay que verlo.
2. **Redactar `a05`** con lo que ya está medido: las diez entidades y su diagrama, la escala por
   entidad principal con el tope ×25, el determinismo (PRNG propio, fecha ancla, hash por
   archivo y los mismos hashes en macOS arm64, Linux arm64 y Linux amd64), los tiempos y la
   memoria de cada volumen, los casos plantados de `answers.json` y el 15 % de pireps
   duplicados a 1 M, declarado. Deja el generador en el repositorio: lleva tag propio.
3. **Redactar `a06`**: Node 24 con TypeScript sin compilar (y la regla de sintaxis
   "borrable"), Python con su entorno, un driver por motor con versión, `iovalkey` y su 0.x,
   `intfloat/multilingual-e5-small` en la revisión `614241f6…` con la paridad ya verificada, la
   guarda `__main__` de `multiprocessing` (§H6), y cómo se conectan los scripts a los puertos
   desplazados de `a02`. Todo lo que muestre, ejecutado.
4. **Repasar la coherencia de lo tocado en T10:** los enlaces de `a01` y `a02` hacia `a05`,
   `a06` y `a09` deben resolver; la guía §17 tiene una línea vieja sobre la paridad de e5 que ya
   está verificada; y el README todavía no menciona `src/lab/`.

---

## 🍃🔑 Tanda 1 · "Lo básico, bien hecho": Bloque 0 + Bloque I

**Qué se publica.** F00 a F06 (52 h), el boss del Bloque I, sus dos miniproyectos y todo lo que
esas fases necesitan de alrededor. Es la tanda que el análisis de modelos ya identificó como la
primera natural: **cierra con su boss y deja al lector con criterio utilizable**, aunque no haga
nada más del curso.

**En este orden, y por qué:**

1. **F00 — La decisión que se hereda.** No usa laboratorio, así que puede escribirse en
   paralelo con la Tanda 0. Su autopsia central es la del sistema de Camilo.
2. **Esqueletos de los documentos vivos**, antes de la primera fase que los alimenta:
   `a09-catalogo-de-errores.md` sembrado con los errores literales de T10 (§H1, §H2, §H4, §H6,
   §H9, §H12), `bitacora-de-medicion.md`, `INSTINTOS.md`, y los esqueletos de `a03`, `a04` y
   `a08`, que crecen con cada fase.
3. **F01 — El dominio de flota y el arnés.** Decide el esquema relacional de referencia y
   escribe el cargador de Postgres sobre el dataset canónico de `a05`. Su prueba de fuego es el
   mismo número de filas examinadas que el documento.
4. **F02 — Las cinco preguntas.** Sin laboratorio. Cierra el Bloque 0.
5. **`a07` — Postgres como línea base**, junto con F03–F04, porque es la primera vez que
   Postgres compite y tiene que ir bien jugado.
6. **F03 y F04 — Documental.** F04 anuncia `h-mini-01` al abrir y publica la primera apuesta
   falsable.
7. **`a10` — Licencias y riesgo**, junto con F05, con los tres casos de T10: ScyllaDB,
   TimescaleDB con TSL y CockroachDB.
8. **F05 y F06 — Clave-valor.** F06 anuncia `h-mini-02` y cierra el bloque con el boss
   *"La orden que entró dos veces"*.
9. **Revisar `h-mini-01` y `h-mini-02`** contra lo que F03–F06 terminaron enseñando.
10. **`0-programa-del-curso.md`** y la actualización del README con la Tanda 1 publicada.

**Decisión abierta de esta tanda:** publicarla completa, o por minicurso (primero F00–F04 y
después F05–F06).

---

## 🧬 Tanda 2 · Vectorial, adelantado a propósito

**Qué se publica.** F15 y F16, y `h-mini-07`. Sale en tercer lugar, fuera de su sitio
pedagógico, por el arrastre de RAG y su conexión con `tutorial-rag/` (decisión 14 del alcance).
Puede hacerlo porque los minicursos son casi independientes.

**Qué tiene de particular:** es la tanda que más se apoya en el generador. Mide recall contra
la verdad de referencia de `pirep-labels.ndjson`, y publica la apuesta de los prefijos
`query:`/`passage:` (§H8), que hoy no está demostrada. Y avisa lo que falta: **el boss del
Bloque III cruza grafos y vectores, así que no sale en esta tanda**, sino con grafos en la
Tanda 4.

---

## 🦆⏱️🔍 Tanda 3 · Bloque II: leer de otra forma

**Qué se publica.** F07 a F12 (analítico embebido, series temporales y búsqueda), el boss
*"El tablero que nadie puede reconstruir"* y los miniproyectos `h-mini-03`, `h-mini-04` y
`h-mini-05`.

**Decisiones del paso 1, respondidas el 30/09/2026** (todavía sin empezar a escribir):

1. **Apuesta de F08** (`ALTER TABLE` un orden de magnitud más caro que la columna nueva en columnar): se
   publica tal como está, aunque en Postgres 11+ el `ADD COLUMN` con default sea solo metadatos. Se mide
   la columna sola y la columna calculada para todas las filas. **Al llegar a F08 se revisa si se
   mantiene o se retira.**
2. **Volúmenes de F07 y F09–F10:** la medición estructural va con los datasets de 1 M; el volumen grande
   se amplía dentro del motor con `generate_series` (unos 50 M de lecturas), declarado como ampliación
   sintética y fuera de la tabla de hashes de `a05`.
3. **"La cardinalidad que mata" (F10):** comprimir por una columna de cardinalidad altísima (aeronave ×
   parámetro × vuelo) y chunks diminutos, con lo que cuestan al planificador.
4. **Disco lleno de OpenSearch (F12):** se provoca bajando los umbrales de disco (watermarks), no
   llenando el disco, y se declara así.
5. **Relevancia de F12:** la verdad son los alternos y las formas de escribir un número de parte que ya
   trae el catálogo del generador.
6. **Boss II, las tres cifras distintas:** **depende**. Si una opción del generador lo simplifica, se
   puede usar; en el encargo se presentan **las dos opciones** —tres definiciones legítimas (horas por
   lecturas u órdenes, corte UTC u hora de Colombia, duplicados tras un reindexado) y discrepancias
   sembradas por el generador— y se elige al escribirlo.

**Qué tiene de particular:** es el primer bloque con Python (DuckDB, F07–F08); F09–F10 usan la
imagen de TimescaleDB con TSL, y el veredicto de F10 lo declara; y es el primer boss que junta
dos familias JVM en la misma máquina, así que la advertencia de RAM de `a02` se pone a prueba.

---

## 🕸️ Tanda 4 · Bloque III completo: grafos

**Qué se publica.** F13 y F14, el boss *"Freddy ya vio esto"*, que ya puede salir porque
vectorial está publicado, y `h-mini-06`.

**Qué tiene de particular:** F14 es la fase más importante del curso, la de la apuesta que se
espera perder. Se apoya en el lote de la directiva que planta el generador (`answers.json`),
que es la respuesta conocida contra la que se mide la consulta de patrón.

---

## 🏛️📴⚡ Tanda 5 · Bloque IV: cuando el dato no cabe en un nodo

**Qué se publica.** F17 a F22 (columnar, offline-first y NewSQL), el boss *"La estación del
Coca"* y los miniproyectos `h-mini-08`, `h-mini-09` y `h-mini-10`.

**Qué tiene de particular:** usa las dos piezas raras del laboratorio: Cassandra con el heap
fijado y `newsql-global` con su sidecar. El boss IV no puede levantar `newsql-global` junto con
todo lo demás en 8 GB (§H13), y el encargo tiene que tenerlo en cuenta.

---

## ⚖️ Tanda 6 · Bloque V y cierre del curso

**Qué se publica.** F23 a F25, el boss *"Las dos verdades"* y el cierre de El Hangar. Después, el
cierre del contenido: los apéndices que crecieron (`a03`, `a04`, `a08`, `a09`) se dan por
terminados y los documentos vivos se consolidan. Los README quedan para la Tanda 7.

**Qué tiene de particular:** el boss V necesita una opción nueva del generador, dos sistemas ya
divergidos con discrepancias sembradas, y conviene diseñarla cuando se escriba F24, no antes.

---

## 📚 Tanda 7 · Los README, al final

**Qué se hace.** Actualizar de una vez los documentos índice, cuando ya no quede contenido por
escribir: el `README.md` del curso (qué está publicado, el orden de publicación que de verdad
ocurrió, la organización de archivos) y `0-programa-del-curso.md` (el estado de cada fase,
apéndice, boss y miniproyecto). Se añade el de `src/` si para entonces el código lo pide.

**Por qué va aparte y al final.** Desde el 30/09/2026 las Tandas 2 a 6 **no tocan ningún README**:
actualizarlos en cada tanda obliga a reescribir el mismo índice cinco veces y deja estados
intermedios que envejecen. Hasta la Tanda 7, el README y el programa describen la Tanda 1, y eso se
acepta a sabiendas.

**En este orden:** primero `0-programa-del-curso.md`, que es el inventario; después el README, que
se apoya en él; y al final una pasada de enlaces rotos por todo el curso, porque es el primer
momento en que todas las fases existen.

---

## 🌐 Transversal · Lo que no pertenece a ninguna tanda

- **Verificación en Linux** (tu equipo): `medir.sh`, `verificar-lab.sh`, `combinaciones.sh` y la
  prueba de carga de Mongo, más completar las secciones de Linux de `a01` y `a02`.
- **Verificación en Windows 11 con WSL2** (tu equipo): lo mismo, y las secciones de WSL2.
- **Mongo 8.0.20:** volver a la 8.0 vigente cuando Docker Desktop traiga un kernel 7.0.14 o
  posterior (§H1).
- **Colima y Podman** siguen declarados sin verificar en `a01`.

---

## ✅ Checklist

### Tanda 0 · Cerrar lo que bloquea la primera fase
- [x] Quitar el foco `aircraft` del generador
- [x] Regenerar los datasets y comprobar hashes en macOS arm64, Linux arm64 y Linux amd64
      (10 k y `reading-1m`; los demás 1 M, solo macOS)
- [x] Lote de la directiva repartido en aeronaves distintas (antes, a 10 k, estaba en una sola)
- [x] `a05-el-dominio-de-flota.md`
- [x] `a06-lenguajes-y-drivers.md` + entorno de `src/` (`package.json`, `uv.lock`, `tsconfig.json`)
      y los tres scripts de `src/lab/check/`: diez motores conectados desde TypeScript
- [x] Enlaces entre apéndices resueltos (los de `a03`, `a04` y `a09`, al crear sus esqueletos)
- [x] Guía §17: actualizar la línea de la paridad de e5
- [x] README: mencionar `src/`

### Tanda 1 · Bloque 0 + Bloque I
- [x] Plantilla del Bloque 0 (F00–F02) en `plantillas-de-capitulo.md`; F00 y F02 en
      2.000–3.000 palabras
- [x] Decidido: la Tanda 1 se publica **completa**
- [x] Apuesta de F06 reformulada a forma (viajes, memoria por sesión, pérdida al reiniciar)
- [x] F00 · `00-la-decision-que-se-hereda.md` (2.505 palabras, 12 ejercicios; autopsia doble de Cóndor)
- [x] `a09-catalogo-de-errores.md` sembrado: 15 entradas, todas con mensaje literal ejecutado
- [x] Esqueletos de `bitacora-de-medicion.md` e `INSTINTOS.md`
- [x] Esqueletos de `a03`, `a04` y `a08` (en `a08`, las convenciones de nombrado ya escritas)
- [x] F01 · `01-el-dominio-de-flota-y-el-arnes.md` (3.021 palabras, 22 ejercicios): esquema de
      referencia, cargador, arnés en `src/lab/harness/` y prueba de fuego verificada tres veces
      (1000081 · 145 · 122 · 66). Alimentó M-01, `a03` (psql), `a04` (viajes y Postgres) y `a09`
      (E-16 a E-19)
- [x] F02 · `02-las-cinco-preguntas.md` (≈2.550 palabras, 12 ejercicios; triaje sobre escenario
      declarado, que remite al boss V)
- [x] `a07-postgres-linea-base.md`: siete técnicas medidas sobre Cóndor; scripts en
      `src/a07-postgres-linea-base/`. Hallazgos: `->>` no usa GIN, `unaccent` no hizo falta, IVFFlat
      con 1 sonda pierde 2 de 10, el `OR` en el JOIN recursivo no termina, *skip scan* de PG18
- [x] F03 · `03-documental-levantar-y-modelar.md` (4.008 palabras, 26 ejercicios): cargador en dos
      formas, ficha 1 viaje contra 25, `$lookup` 22 contra 1 000 000, trampa `apu`, fechas como texto
- [x] F04 · `04-documental-romper-y-medir.md` (4.012 palabras, 28 ejercicios): apuesta ganada 1,00×,
      ficha 1 doc contra 50 filas, rotura a las 90 344 lecturas, WriteConflict, espacio 83 contra 159 MB.
      Alimentó M-02 a M-06, INSTINTOS n.º 1, E-20 a E-25, `a03`/`a04`/`a08` de Mongo; índice
      `assembly_aircraft` añadido a la línea base de F01
- [x] `a10-licencias-y-riesgo.md`: licencias leídas en cada repositorio; Redis 8 y Elasticsearch
      ofrecen hoy AGPLv3, así que el argumento pasa a ser permisiva contra copyleft de red
- [x] F05 · `05-clave-valor-levantar-y-modelar.md` (4.988 palabras, 24 ejercicios): 100 k sesiones en
  100 viajes y 206 B; el índice a mano (202 contra 2 viajes, 1000 fantasmas); situación 3, 0 de 1 M;
  `trips.ts` nuevo (escrituras al socket)
- [x] F06 · `06-clave-valor-romper-y-medir.md`, con el boss del Bloque I (4.092 palabras, 26
  ejercicios): apuesta ganada, 1 contra 1 viajes y 0,74× los bytes; `extra.ts` nuevo (reserva y
  candado en Postgres); OOM, evicción silenciosa de 100 187 claves, RDB 0 / AOF 50 000; el boss
  duplica 91–98 de 200 y su solución no se publica
- [x] Documentos vivos de F05–F06: M-07 a M-10 y la apuesta 2 en la bitácora, E-26 a E-31 en `a09`,
  el 🪞 2 en `INSTINTOS.md`; secciones de Valkey en `a03`, `a04` y `a08`
- [x] Revisar `h-mini-01` y `h-mini-02`: a cada uno se le añadió el matiz medido que su veredicto
  tiene que resistir (JSONB 1,00× en Barlovento; sesión `UNLOGGED` y candado consultivo en Nodo Sur)
- [x] `0-programa-del-curso.md`, como documento vivo que se actualiza con cada tanda
- [x] README con la Tanda 1 publicada

- [x] Auditoría del 30/09/2026: faltaba en `a04` el protocolo de la apuesta falsable (marcado 🚧 Fase 04
  con F04 publicada); escrito. Índice de `a08` al día con lo que ya tenía

### Tanda 2 · Vectorial
- [x] F15 · `15-vectorial-levantar-y-modelar.md` (4.340 palabras, 24 ejercicios): Qdrant sin HNSW bajo el
  umbral con 10 k; `ILIKE` contra vectores (728 de 1258); situación 3, 4 de 186. `ingest.py`, `search.ts`,
  `compare.ts`
- [x] F16 · `16-vectorial-romper-y-medir.md` (4.845 palabras, 26 ejercicios): apuesta 3 perdida en su
  letra y ganada en su fondo, apuesta 4 perdida (métrica saturada), filtro 0,995 contra 0,10, memoria del
  cgroup contra `docker stats`, rotura de Qdrant (se vuelve disco; int8 muere antes) y de `pgvector`
  (64 MB: 2246 s contra 299 s; `halfvec` 957 MB sin perder recall). `load_pgvector.py`, `measure.ts`,
  `rotura.py`. **El boss III queda marcado 🚧 en su sitio: se escribe en la Tanda 4**
- [x] `shm_size` en el servicio `base` del compose (E-35), documentado en `a02`
- [x] Revisar `h-mini-07`: tres matices medidos añadidos
- [x] Documentos vivos y apéndices: `a03` (Qdrant), `a04` (recall en sus dos sentidos), `a08`
  (vectorial), `a09` (E-32 a E-37), bitácora (M-11 a M-14, apuestas 3 y 4), `INSTINTOS.md` (n.º 3)
- [x] Recargar la colección `pirep` del millón en el laboratorio

### Tanda 3 · Bloque II
- [ ] F07 · `07-analitico-levantar-y-modelar.md`
- [ ] F08 · `08-analitico-romper-y-medir.md`
- [ ] F09 · `09-series-levantar-y-modelar.md`
- [ ] F10 · `10-series-romper-y-medir.md`
- [ ] F11 · `11-busqueda-levantar-y-modelar.md`
- [ ] F12 · `12-busqueda-romper-y-medir.md`, con el boss del Bloque II
- [ ] Revisar `h-mini-03`, `h-mini-04` y `h-mini-05`
- [ ] Crecer apéndices y documentos vivos

### Tanda 4 · Bloque III completo
- [ ] F13 · `13-grafos-levantar-y-modelar.md`
- [ ] F14 · `14-grafos-romper-y-medir.md`
- [ ] Boss del Bloque III, *"Freddy ya vio esto"*
- [ ] Revisar `h-mini-06`
- [ ] Crecer apéndices y documentos vivos

### Tanda 5 · Bloque IV
- [ ] F17 · `17-columnar-levantar-y-modelar.md`
- [ ] F18 · `18-columnar-romper-y-medir.md`
- [ ] F19 · `19-offline-levantar-y-modelar.md`
- [ ] F20 · `20-offline-romper-y-medir.md`
- [ ] F21 · `21-newsql-levantar-y-modelar.md`
- [ ] F22 · `22-newsql-romper-y-medir.md`, con el boss del Bloque IV
- [ ] Revisar `h-mini-08`, `h-mini-09` y `h-mini-10`
- [ ] Crecer apéndices y documentos vivos

### Tanda 6 · Bloque V y cierre
- [ ] Opción del generador para dos sistemas divergidos (boss V)
- [ ] F23 · `23-poliglota-el-diseno.md`
- [ ] F24 · `24-poliglota-la-costura.md`
- [ ] F25 · `25-poliglota-la-factura.md`, con el boss V y el cierre de El Hangar
- [ ] Cerrar `a03`, `a04`, `a08` y `a09`
- [ ] Consolidar la bitácora, el catálogo (50 entradas) e `INSTINTOS.md` (los diez 🪞)

### Tanda 7 · Los README
- [ ] `0-programa-del-curso.md`: estado final de fases, apéndices, boss y miniproyectos
- [ ] `README.md` del curso con el orden de publicación real y la organización final
- [ ] README de `src/`, si el código lo necesita
- [ ] Pasada de enlaces rotos por todo el curso

### Transversal
- [ ] Verificación completa en Linux y secciones de Linux de `a01`/`a02`
- [ ] Verificación completa en Windows 11 (WSL2) y secciones de WSL2
- [ ] Volver de Mongo 8.0.20 a la 8.0 vigente cuando el kernel lo permita
- [ ] Colima y Podman: verificar o dejar declarados
