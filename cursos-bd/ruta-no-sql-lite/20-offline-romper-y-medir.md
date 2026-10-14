# 📴 Fase 20 — Offline-first: cien órdenes, tres días, y la resolución que no converge

> **Curso:** Ruta NoSQL Lite · Fase 20 de 26 · Bloque IV — Cuando el dato no cabe en un nodo · **10 h**
> **Familia:** offline-first · **Motor:** Apache CouchDB 3.5.2 `couchdb@sha256:8cf5f8442585…` en el servidor, y
> PouchDB 9.0.0 en las tabletas (LevelDB, desde Node)
> **Línea base:** ninguna honesta (sección 4). El contraste con Postgres como servidor se midió en la
> [Fase 19](19-offline-levantar-y-modelar.md) y vale igual aquí
> **Entorno de ejecución:** TypeScript (`pouchdb` 9.0.0)
> **Volumen:** `workOrder-1m` (`datasetSha256` `11a67c65fb22…`): el millón de órdenes en el servidor, y las últimas
> cien de Freddy para la apuesta
> **Depende de:** Fase 19 · **Habilita:** Fase 21
> **Apéndices de apoyo:** [`a02`](a02-compose-de-la-ruta.md), [`a03`](a03-clis-de-los-motores.md),
> [`a04`](a04-el-arnes-de-medida.md), [`a09`](a09-catalogo-de-errores.md)
> **Fecha de verificación ejecutada:** 11/10/2026, en macOS arm64
> **Objetivo:** llevar el viaje de Freddy a cien órdenes y resolver la apuesta de la familia, medir lo que pesan el
> historial, el conflicto masivo y la compactación, encontrar el tamaño razonable de la tableta, y provocar una
> sincronización que no converge.

---

## 🧭 1. Dónde estamos

La [Fase 19](19-offline-levantar-y-modelar.md) dejó el diseño de esta familia en una frase: **el conflicto es el
caso normal, y se diseña**. Con cuatro órdenes y dos técnicos, la forma del documento decidió cuántas ediciones
se escondían, "el último que escribe gana" borró el lunes entero de Freddy, y el CRDT no perdió nada y dejó a la
vista la única disputa real: dos bombas de combustible en la misma posición.

Cuatro órdenes son un ejemplo, no un volumen. Esta fase pregunta lo que pregunta cualquiera antes de darle una
tableta a un técnico: **¿aguanta un viaje de verdad?** Cien órdenes, ciento diez técnicos más trabajando en la
base, el historial que crece con cada guardado, dos tabletas que editan lo mismo todo el día, la compactación
que alguien va a programar un viernes, y la tableta que baja más de lo que debería.

Y al final, la manera de romperla que no tiene mensaje de error: dos procesos bien intencionados que resuelven
los mismos conflictos, cada uno por su lado, para siempre.

---

## 🎯 2. Objetivos de esta fase

1. Resolver la apuesta con las **cien órdenes** más recientes de Freddy y las tres formas de la Fase 19.
2. Medir cuánto pesa el **historial de revisiones** en la tableta, en el cable y en el servidor, y dónde lo
   corta `_revs_limit`.
3. Provocar el **conflicto masivo**, dos tabletas sobre las mismas cien órdenes todo el día, y ver cómo crecen
   las hojas sin que nadie resuelva.
4. Compactar el servidor y la tableta, y medir **qué libera y qué se lleva**.
5. Encontrar el **tamaño razonable de la tableta** con el millón de órdenes en el servidor, y provocar una
   **sincronización que no converge**.

> 🧰 **Miniproyecto de esta familia:** [Cumbre Roja — la evidencia de cada finca, escrita el viernes sobre lo
> que se vio el lunes](h-mini-09-offline-cumbre-roja.md). Opcional, fuera de las horas del curso, y no entra a
> la bitácora.

---

## 🪞 3. La apuesta

> 🪞 **Apuesta antes de ejecutar.** **Tres días desconectado con cien órdenes editadas sincronizan sin
> intervención manual.** Se lee así: Freddy edita su parte de sus últimas cien órdenes de `workOrder-1m` en la
> tableta, sin señal; los demás técnicos de cada orden (`technicianIds`) hacen su parte en la base, con señal; el
> jueves sincroniza, y con la forma CRDT de la Fase 19 la resolución corre sola en el servidor. **Intervención
> manual** es toda posición con dos seriales vivos y todo conflicto que quede sin resolver.
>
> **Mi predicción, escrita a las 12:53 del 11/10/2026, antes de generar el escenario: la pierdo**, con conflictos
> en unas dos de cada tres órdenes, ninguna edición perdida y **entre una y cinco disputas** de posición.

La regla del escenario se fijó antes, en las preguntas de la fase: el trabajo de cada orden —tareas, cambios de
pieza, horas— se reparte entre sus técnicos, y solo hay incompatibilidad si dos registran un cambio en la misma
posición. **Resultado, en la sección 4.1: la apuesta, ganada; mi predicción, perdida.** Y quien la gana no es la
familia.

---

## 📐 4. La medición contra la línea base

**No hay línea base honesta, y no se fabrica.** Postgres no corre en la tableta, y lo que haría como servidor
—rechazar al segundo que llega, con o sin restricción del dominio— ya se midió en la Fase 19, sección 6.5. Esta
sección mide la familia contra sí misma: la forma que propone contra la de siempre, y el volumen contra el
tiempo.

### 4.1 Cien órdenes, tres días

`bet.ts` toma las últimas cien órdenes de Freddy (`T-004`) del millón, reabiertas, y reparte su trabajo:

```text
100 órdenes de Freddy en 87 aeronaves · 89 con otro técnico · 268 ediciones de Freddy sin señal · 284 de 110 técnicos más, con señal
```

> 📐 **Medición — la apuesta** · las cien órdenes de `workOrder-1m` (`11a67c65fb22…`) · CouchDB 3.5.2
> `couchdb@sha256:8cf5f8442585…` y PouchDB 9.0.0 · verificado el 11/10/2026
>
> | Forma · resolución | Conflictos | Conservadas (Freddy · los demás) | Escondidas | Perdidas | Intervenciones manuales |
> |---|---|---|---|---|---|
> | orden como CRDT · fusión del CRDT | 89 | **552/552** (268 · 284) | 0 | 0 | **0** |
> | orden por documento · ganadora de CouchDB | 89 | 347/552 (120 · 227) | **205** | 0 | **89** conflictos sin resolver |
> | orden por documento · el último que escribe gana | 89 | 310/552 (143 · 167) | 0 | **242** | 0 |
>
> La sincronización del jueves: 100 documentos arriba y 89 abajo, 16 peticiones, 209 KiB con la forma CRDT y
> 188 KiB con la otra. Reproducir: `node 20-offline-romper-y-medir/bet.ts`, desde `src/`.

**La apuesta se gana: 89 conflictos, todos fusionados sin que nadie los mire, y las 552 ediciones en su
lugar.** La predicción falló en lo único que la decidía: hubo **cero disputas**, no entre una y cinco. Y la razón
está en el generador, no en CouchDB: en las 1214 órdenes de Freddy del millón, **ninguna registra dos cambios de
pieza en la misma posición**, así que con el trabajo repartido nadie pisa a nadie. El caso de la bomba de la Fase
19 —un técnico que cambia lo que otro ya cambió, con la copia vieja— no aparece en los datos. En la realidad
aparece, y cada vez que aparezca será una intervención manual, con cualquier forma de documento.

Lo que la apuesta sí mide es **lo que depende del diseño**. Con el mismo viaje y la orden como documento de
siempre, la ganadora de CouchDB **esconde 205 ediciones** —el 37 %— en revisiones perdedoras y deja 89 conflictos
para revisar a mano. "El último que escribe gana" **pierde 242** sin decírselo a nadie, y no solo de Freddy: 117
de los técnicos que trabajaron con señal. La frase de la apuesta es cierta **solo con la forma de la Fase 19**.

### 4.2 El historial de revisiones

Una orden guardada N veces en la tableta, sin señal, y después subida (`history.ts`):

> 📐 **Medición — una orden, N guardados** · CouchDB 3.5.2 y PouchDB 9.0.0, `_revs_limit` por defecto ·
> verificado el 11/10/2026, dos corridas con el mismo resultado
>
> | Guardados | Historia en la tableta | Tableta en disco → compactada | Subida | Historia en el servidor | Servidor: vivos · archivo |
> |---|---|---|---|---|---|
> | 1 | 1 | 16 → 24 KiB | 7 peticiones, 0 KiB | 1 | 1 · 24 KiB |
> | 10 | 10 | 24 → 24 KiB | 7, 1 KiB | 10 | 1 · 24 KiB |
> | 100 | 100 | 568 → 272 KiB | 7, 4 KiB | 100 | 4 · 28 KiB |
> | 1000 | 1000 | **9700 → 9144 KiB** | 7, **35 KiB** | 1000 | 38 · 60 KiB |
> | 2000 | **1000** | 12 864 → 2136 KiB | 7, 35 KiB | **1000** | 38 · 60 KiB |
>
> Reproducir: `node 20-offline-romper-y-medir/history.ts`.

Tres lecturas. **La tableta guarda todo**: cada guardado deja su cuerpo y el árbol de revisiones crece con él, y
una sola orden con mil guardados ocupa **9,5 MiB** en LevelDB, donde el servidor tiene 38 KiB vivos. Compactar la
tableta (`db.compact()`) borra los cuerpos viejos, pero LevelDB devuelve el espacio cuando su propia compactación
interna lo decide: a los mil guardados casi nada, a los dos mil, 83 %. **La subida lleva la historia**: la orden
pesa unos cientos de bytes y viaja con **35 KiB** de identificadores de antepasados. Y **`_revs_limit` corta en
mil, en los dos lados**: el guardado 2000 sube con los mil últimos, y la tableta tampoco recuerda más.

Mil guardados de una orden no es un caso de laboratorio: es una app que guarda cada campo al salir de él, y un
técnico que llena una orden de cuarenta campos durante tres días.

### 4.3 El conflicto masivo

Freddy y Jairo Vélez (`T-009`) editan **las mismas cien órdenes** todo el día, con la forma de siempre y sin
resolver nada (`massive.ts`). Cada ronda, cada uno guarda una vez cada orden, en la ganadora que su app le
muestra, y los dos sincronizan:

> 📐 **Medición — dos tabletas, cien órdenes, sin resolver** · CouchDB 3.5.2 y PouchDB 9.0.0 · verificado el
> 11/10/2026
>
> | Ronda | Documentos con conflicto | Hojas por documento | Hojas en total | Servidor: vivos · archivo |
> |---|---|---|---|---|
> | 1 | 100 | 2 | 200 | 114 · 232 KiB |
> | 2 | 100 | 3 | 300 | 173 · 424 KiB |
> | 5 | 100 | 6 | 600 | 353 · 1188 KiB |
> | 10 | 100 | **11** | **1100** | 667 · **3100** KiB |
>
> Reproducir: `node 20-offline-romper-y-medir/massive.ts`.

**Cada ronda suma una hoja a cada documento.** La app edita la ganadora; la perdedora no la ve nadie, y queda;
la ronda siguiente, los dos editan otra vez la misma ganadora, y nacen dos hijas más. A la décima ronda cada orden
tiene **once versiones vivas** —once cuerpos completos que se replican, se guardan y se compactan— y el archivo
del servidor creció **13 veces**. Nada falló: todas las sincronizaciones terminaron bien.

### 4.4 La compactación, y lo que se lleva

Sobre las hojas de la ronda 10:

```text
servidor compactado · archivo 3100 KiB → 2624 KiB · vivos 634 KiB · hojas en total 1100 (conflictos 100) · revisión 1 de WO-0921122: disponible → not_found (missing)
tableta de Freddy compactada · 1668 KiB → 1584 KiB · conflictos 100 · revisión 1 de WO-0921122: disponible → 404 missing
```

**La compactación no resuelve conflictos**: las 1100 hojas siguen ahí, porque son hojas, y por eso el archivo baja
solo un 15 %. Lo que borra son **los cuerpos que no son hoja**, y entre ellos está la revisión 1: **el antepasado
común** de todas las ramas, lo que la orden decía antes de que nadie la tocara (E-67 en
[`a09`](a09-catalogo-de-errores.md)). Una fusión a tres vías —comparar cada rama contra el antepasado para saber
quién cambió qué— funciona hasta la primera compactación y después pide algo que ya no existe. Es la fusión que
la Fase 19 dejó como ejercicio para arreglar el pendiente que volvía.

El CRDT no necesita antepasado: lleva dentro lo que necesita para fusionarse. **Esa es la diferencia que la
compactación vuelve obligatoria.**

### 4.5 El tamaño razonable de la tableta

El servidor tiene ahora **el millón**: `load.ts` lo carga en 175 s por `_bulk_docs`, y ocupa **578 MiB**, un poco
más que el NDJSON (498 MiB); CouchDB llegó a 420 MiB de memoria mientras cargaba. `tablet.ts` hace la primera
bajada de una tableta nueva con un filtro cada vez más ancho:

> 📐 **Medición — la primera bajada, filtro por filtro** · `work_order_1m`, 1 000 000 de órdenes · CouchDB 3.5.2 y
> PouchDB 9.0.0 · macOS arm64, los segundos son contexto · verificado el 11/10/2026
>
> | Filtro | Órdenes | Peticiones | Bajados | Segundos | En la tableta | Memoria del proceso |
> |---|---|---|---|---|---|---|
> | las 100 órdenes del viaje (`doc_ids`) | 100 | 9 | 0,1 MiB | 0 | 0,1 MiB | 178 MiB |
> | sus 87 aeronaves, con su historia (`selector`) | 34 204 | 1721 | 30,1 MiB | **93** | 12,2 MiB | 169 MiB |
> | la base de Villavicencio (`selector`) | 150 785 | 7544 | 132,8 MiB | **90** | 53,5 MiB | 193 MiB |
> | todo `work_order_1m` | 1 000 000 | 50 004 | 881,6 MiB | 275 | **341,2 MiB** | 231 MiB |
>
> Reproducir: `node 20-offline-romper-y-medir/load.ts` y `node 20-offline-romper-y-medir/tablet.ts`.

**El cable escala con lo que baja**: unas 50 peticiones y 0,9 MiB por cada mil órdenes, con `selector` o sin filtro.
En la tableta, cada orden ocupa unas 0,35 KiB, menos que en el cable y que en el servidor (0,59 KiB).
**El reloj no escala con lo que baja.** Las 34 204 órdenes de las aeronaves de Freddy tardaron lo mismo que las
150 785 de toda la base, y casi un tercio de lo que tardó el millón entero. Un `selector` se evalúa en el servidor
sobre el registro de cambios, y en la primera bajada ese registro es **todo lo que hay**: el costo lo pone el
servidor, no la tableta. `doc_ids` no recorre nada, y por eso la primera fila son nueve peticiones.

¿Cuál es el tamaño razonable? La tabla dice que **no es el número de órdenes**: el millón entero cabe en 341 MiB, y
cualquier tableta tiene ese espacio. Lo que la llena es la sección 4.2, como aritmética declarada: cien órdenes
con mil guardados cada una, al ritmo de una orden de prueba, serían **unos 950 MiB** sin compactar, casi el triple
del millón. El presupuesto de una tableta se calcula con **guardados por orden y días sin compactar**, no con
filas. Y la primera bajada razonable es la de la primera fila: lo que el técnico va a tocar, por `doc_ids`, y la
historia de sus aeronaves si de verdad la consulta sin señal.

---

## 💥 5. El punto de rotura

El viaje de la apuesta deja **89 conflictos** en el servidor y en la tableta de Freddy. Cada ronda, alguien los
resuelve con la fusión del CRDT —la misma función, el mismo resultado, con las claves ordenadas para que dos
réplicas escriban el mismo JSON— y todos sincronizan (`pingpong.ts`). Lo único que cambia es **quién resuelve**:

> 💥 **Rotura — la sincronización que no converge** · las cien órdenes · CouchDB 3.5.2 y PouchDB 9.0.0 ·
> verificado el 11/10/2026
>
> ```text
> A · solo el servidor               · conflictos por ronda ronda 0: 89 · 1: 0 · revisión de WO-0921122 6 · hojas 1 con 1 cuerpo(s) distinto(s) · cambios en el servidor 573 · archivo 1740 KiB
> B · servidor y tableta             · conflictos por ronda ronda 0: 89 · 1: 89 · 2: 89 · 3: 89 · 4: 89 · 5: 89 · 6: 89 · 7: 89 · 8: 89 · 9: 89 · 10: 89 · revisión de WO-0921122 15 · hojas 2 con 1 cuerpo(s) distinto(s) · cambios en el servidor 2264 · archivo 8504 KiB
> C · dos tabletas                   · conflictos por ronda ronda 0: 89 · 1: 0 · revisión de WO-0921122 6 · hojas 1 con 1 cuerpo(s) distinto(s) · cambios en el servidor 573 · archivo 1496 KiB
> D · servidor y tableta, firmando   · conflictos por ronda ronda 0: 89 · 1: 89 · 2: 89 · 3: 89 · 4: 89 · 5: 89 · 6: 89 · 7: 89 · 8: 89 · 9: 89 · 10: 89 · revisión de WO-0921122 15 · hojas 2 con 2 cuerpo(s) distinto(s) · cambios en el servidor 2264 · archivo 8672 KiB
> E · dos tabletas, firmando         · conflictos por ronda ronda 0: 89 · 1: 89 · 2: 89 · 3: 89 · 4: 89 · 5: 89 · 6: 89 · 7: 89 · 8: 89 · 9: 89 · 10: 89 · revisión de WO-0921122 15 · hojas 2 con 2 cuerpo(s) distinto(s) · cambios en el servidor 2264 · archivo 3420 KiB
> ```
>
> Reproducir: `node 20-offline-romper-y-medir/pingpong.ts`.

**Con el servidor y la tableta resolviendo cada uno por su lado (B), no converge nunca.** Diez rondas, 89
conflictos en cada una, el archivo 4,9 veces más grande que en A y **ningún error**: cada sincronización termina bien.
Lo inquietante está en la columna de las hojas: **dos hojas con el mismo cuerpo**. Las dos réplicas escribieron
exactamente lo mismo, y aun así son dos revisiones distintas.

La razón es el `_rev`. Los dos motores lo calculan a partir del contenido, de forma determinista, pero **con
algoritmos distintos**: el mismo documento `{"v":1}` guardado en una tableta nueva da `1-2340a66d…`, y en el
servidor, `1-7a7e4b29…`. Dos tabletas que fusionan lo mismo (C) escriben la misma revisión, y la replicación ve
una sola: convergen en una ronda. Una tableta y el servidor escriben dos hermanas, y la replicación ve un
conflicto nuevo, que en la ronda siguiente los dos vuelven a resolver. **Firmar la resolución** —anotar quién
y cuándo, lo primero que cualquiera agregaría— hace que los cuerpos ya no sean iguales, y entonces no converge
**ni con dos tabletas** (E).

No hay volumen de rotura: rompe **en la primera ronda**, con cuatro órdenes o con cien. El mensaje literal es que
no hay mensaje. **Lo que hay que cambiar para salir:** que resuelva **un solo lugar** —el servidor, como en A—, y
que la tableta solo muestre. O, si las tabletas tienen que resolver sin señal, que **ninguna réplica de otro motor
resuelva** y que la resolución no lleve nada propio de quien la hace.

---

## 🚑 6. Salir de aquí

Cuando offline-first ya duele, en orden de costo:

1. **Configuración.** Un solo resolvedor, en el servidor (sección 5). Bajar a la tableta solo lo que el técnico va
   a tocar, por `doc_ids` y no por `selector` (sección 4.5). Compactar la tableta al volver a tener señal, después
   de sincronizar.
2. **Modelo.** La forma de la Fase 19: el documento cortado por quién lo edita, y cada campo que se fusiona como un
   CRDT, que no necesita el antepasado que la compactación borra (sección 4.4). Guardar menos veces: un guardado por
   acción del técnico, no por campo (sección 4.2). Y una vista diaria de conflictos y disputas, porque **la
   intervención manual que el dataset no trae, la trae la realidad** (sección 4.1).
3. **Motor.** Si los técnicos casi siempre tienen señal, una app en línea con una cola local y Postgres con la regla
   del dominio en la tabla rechaza exactamente el desacuerdo real (Fase 19, sección 6.5), y te ahorras las
   secciones 4.3 a 5.
4. **Arquitectura.** Mandar **operaciones** en vez de documentos —"Freddy firmó la tarea 3 de `WO-0921122`"— a un
   servidor que es el único que decide. Es un CRDT de operaciones, o un registro de eventos; es más trabajo, y es lo
   que hacen las librerías como Automerge por dentro.

---

## ❓ 7. Las cinco preguntas, respondidas para offline-first

1. **Frontera transaccional.** **Es la pregunta de esta familia.** Un documento en una réplica, y entre réplicas
   ninguna: dos ediciones del mismo documento sin verse son un conflicto, siempre. Lo que se diseña es dónde cortar
   el documento para que el conflicto caiga donde de verdad hay desacuerdo.
2. **Consultas conocidas.** Las que importan son las de **replicación**: qué baja cada tableta. Un `selector` sobre un
   servidor grande recorre su registro de cambios entero (sección 4.5).
3. **Unidad de lectura.** El documento local. La tableta lee lo suyo sin red, y por eso puede leer algo de hace
   tres días.
4. **Saltos.** Pocos, y mejor ninguno: dos documentos que se refieren uno al otro pueden llegar a la tableta en
   distinto orden, o uno sin el otro si el filtro los separa.
5. **Exactitud o parecido.** Exactitud **eventual y con conflictos**: todas las réplicas terminan mostrando lo mismo,
   y eso no quiere decir que alguien haya decidido qué era lo correcto.

---

## ⚖️ 8. Veredicto honesto: cuándo NO usar esto

> ⚖️ **Offline-first es la familia con el mayor coste de complejidad por unidad de beneficio de todo el curso.**
> El beneficio es uno, y es enorme cuando existe: el técnico escribe donde está, cuando pasa. El coste es todo lo
> demás. Con la forma de siempre, el mismo viaje **esconde 205 de 552 ediciones** o **pierde 242** sin avisar
> (sección 4.1). Para que no pase hacen falta una forma de documento pensada por quién edita qué, unas **cien
> líneas** de tipos CRDT y de resolución (`crdt.ts`, la forma CRDT de `trip.ts` y `resolve.ts`, sin comentarios), un
> solo lugar que resuelva —**dos que resuelven lo mismo no convergen nunca** (sección 5)—, una vista de conflictos
> que alguien mire, y una tableta que puede ocupar **9,5 MiB por una orden** guardada mil veces.
>
> **No la uses si tus usuarios casi siempre tienen señal**: una app en línea con cola local y Postgres hace lo mismo
> sin réplica en la tableta, sin hojas que guardar y sin nadie que tenga que resolver. **No la uses si no puedes decir, campo por campo, cómo se fusiona**: cada campo sin
> respuesta es una intervención manual. **Y no la uses sin un dueño de la resolución.**
>
> **Úsala** cuando el trabajo de verdad ocurre sin conexión y escribirlo después es peor que diseñar los conflictos:
> el registro de mantenimiento que hoy se transcribe el viernes.

Para Cóndor: **sí, para Freddy y los técnicos itinerantes, y solo para lo que ellos editan**: las órdenes abiertas
de sus aeronaves, con la forma de la Fase 19 y el servidor como único resolvedor. El resto de la empresa —el
catálogo, el inventario, las lecturas de vuelo— se queda en línea. Cumbre Roja, el miniproyecto, tiene el mismo
dolor con otro oficio, y además fotos.

---

## ⚠️ 9. Errores comunes y diagnóstico

**Un antepasado que ya no existe** (E-67 en [`a09`](a09-catalogo-de-errores.md)):

```text
{"error":"not_found","reason":"missing"}
```

Desde PouchDB, `404 missing`. 🩺 Pediste una revisión por su `_rev` (`?rev=…`) después de una compactación, y no era
hoja. `?revs_info=true` la lista como `missing`. Salir: una fusión que no dependa del antepasado (un CRDT), o
guardar en el documento lo que haga falta comparar.

**El proceso que termina sin terminar** (E-68):

```text
Warning: Detected unsettled top-level await at file:///…/20-offline-romper-y-medir/bet.ts:52
await run(crdtDoc, crdtMerge);
^
```

🩺 Apareció en dos de seis corridas de `bet.ts`, y una vez en la Fase 19, siempre en una replicación que
pasaba por el contador de bytes del arnés. Node se queda sin nada pendiente mientras una promesa sigue esperando:
la copia del cuerpo que hacía `res.clone()` a veces no terminaba nunca. Salir: leer el cuerpo una vez y devolverle
a PouchDB una respuesta nueva con esos bytes, como hace hoy `lab/harness/couch.ts`; con eso, ocho corridas de
ocho.

**Los conflictos que no bajan.** Sin mensaje. 🩺 La cuenta de `allDocs({ conflicts: true })` no baja de una ronda a
la otra aunque alguien resuelva, y las hojas en conflicto tienen el mismo cuerpo. Hay dos resolvedores (sección 5).
Salir: dejar uno solo.

**La tableta que pesa megas por una orden.** Sin mensaje. 🩺 `du` sobre la carpeta de la tableta contra el número de
guardados; `?revs=true` da el largo de la historia. Salir: guardar por acción, compactar al volver a tener señal,
y no esperar que LevelDB devuelva el espacio en el acto (sección 4.2).

---

## 📋 10. Checklist de validación

```text
[ ] La apuesta: 89 conflictos y 0 intervenciones con la forma CRDT; 205 escondidas o 242 perdidas con la de siempre
[ ] Sé por qué hubo 0 disputas, y por qué en la realidad no van a ser 0
[ ] Una orden con 1000 guardados: 9,5 MiB en la tableta, 35 KiB de historia en la subida, 38 KiB en el servidor
[ ] _revs_limit corta en 1000 en la tableta y en el servidor
[ ] El conflicto masivo: una hoja más por documento y ronda; 11 hojas a la décima
[ ] La compactación deja las 1100 hojas y se lleva la revisión 1 (E-67)
[ ] El tamaño de la tableta con cada filtro, y por qué el selector sobre el millón es lento
[ ] Servidor y tableta resolviendo lo mismo no convergen; dos tabletas sí, salvo que firmen; sé por qué
[ ] M-56 a M-60 en la bitácora, la apuesta 10 en su tabla, E-67 y E-68 en a09
```

---

## 🧪 11. Ejercicios (24)

Desde `src/`, con el perfil `offline` arriba y `load.ts` corrido. Los ejercicios que cambian `scenario.ts` o los
guiones se miden antes y después.

### 🟢 Fácil — reproducir (1–5)

#### 🟢 Ejercicio 1 — La apuesta

Corre `bet.ts` dos veces.

**Objetivo:** las tres filas de la sección 4.1, iguales en las dos corridas.

#### 🟢 Ejercicio 2 — La historia de una orden

Guarda una orden 50 veces en una tableta y pídela con `revs: true` y con `revs_info: true`.

**Objetivo:** el largo de la historia, y cuántas revisiones tienen cuerpo antes y después de `compact()`.

#### 🟢 Ejercicio 3 — Las hojas a mano

Después de `massive.ts`, pide una orden con `?conflicts=true` y con `?open_revs=all` ([`a03`](a03-clis-de-los-motores.md)).

**Objetivo:** las once hojas, y qué tiene cada una en `notes`.

#### 🟢 Ejercicio 4 — Compactar

Compacta `work_order_1m` (`POST /work_order_1m/_compact`) y mira `sizes` antes y después.

**Pregunta:** ¿cuánto bajó, y por qué casi nada en una base que nunca se editó?

#### 🟢 Ejercicio 5 — Dos `_rev`

Guarda el mismo documento en una tableta nueva y en una base nueva del servidor.

**Objetivo:** los dos `_rev`, y explicar con ellos la fila B de la sección 5.

### 🟡 Intermedio — medir de otra forma (6–12)

#### 🟡 Ejercicio 6 — La apuesta con la bomba

Agrega al escenario, en una de cada veinte órdenes compartidas, un segundo técnico que registra el cambio de una
pieza que ya cambió otro, con la copia vieja (el caso de la Fase 19).

**Objetivo:** cuántas intervenciones manuales aparecen, y si la apuesta sigue ganada.

#### 🟡 Ejercicio 7 — Doscientas órdenes

Corre la apuesta con `loadTrip(200)` y con `loadTrip(50)`.

**Objetivo:** conflictos, conservadas y bytes de la sincronización; qué escala con las órdenes y qué no.

#### 🟡 Ejercicio 8 — Guardar por acción

Cambia `history.ts` para que la orden se guarde una vez por cada diez cambios.

**Objetivo:** la tableta y la subida para 1000 cambios, contra la fila de 1000 guardados.

#### 🟡 Ejercicio 9 — `_revs_limit` bajo

Pon `_revs_limit` en 10 en el servidor (`PUT /f20_history/_revs_limit`) y repite `history.ts`.

**Objetivo:** la historia en el servidor y lo que sube; explica qué pasa si una tableta vuelve después de once
guardados en el servidor.

#### 🟡 Ejercicio 10 — Resolver el conflicto masivo

Al final de `massive.ts`, resuelve en el servidor con una unión de las notas de todas las hojas.

**Objetivo:** las hojas y el archivo antes y después de resolver y compactar.

#### 🟡 Ejercicio 11 — La compactación automática

Abre la tableta con `auto_compaction: true` y repite `history.ts`.

**Objetivo:** el disco de la tableta con 1000 guardados, contra la tabla de la sección 4.2.

#### 🟡 Ejercicio 12 — `doc_ids` contra `selector`

Baja a una tableta las órdenes de las 87 aeronaves por `doc_ids` (los ids salen de una consulta previa) en lugar de
por `selector`.

**Objetivo:** peticiones, bytes y segundos contra la fila del `selector` de la sección 4.5.

### 🟠 Difícil — diagnosticar y decidir (13–19)

#### 🟠 Ejercicio 13 — Predecir las hojas

Antes de correr, predice cuántas hojas tiene una orden si tres tabletas editan cinco rondas sin resolver.

**Objetivo:** tu número escrito antes, y el medido.

#### 🟠 Ejercicio 14 — La fusión a tres vías, antes y después

Escribe la fusión de notas que compara cada rama contra la revisión 1. Córrela antes y después de compactar.

**Objetivo:** el resultado antes, y el error literal después (E-67).

#### 🟠 Ejercicio 15 — La variante E

Agrega a `pingpong.ts` una variante con el servidor y la tableta resolviendo, pero la tableta solo cuando no hay
nadie más con señal.

**Pregunta:** ¿converge? ¿Qué regla de la sección 6 estás implementando?

#### 🟠 Ejercicio 16 — Firmar sin romper

Haz que la resolución quede firmada (quién y cuándo) sin que la variante C deje de converger.

**Objetivo:** dónde guardaste la firma, y la cuenta de conflictos por ronda.

#### 🟠 Ejercicio 17 — Cuánto cuesta el `selector`

Mide el tiempo de la bajada por `selector` de las 87 aeronaves con 10 k, 100 k y 1 M órdenes en el servidor.

**Pregunta:** ¿con qué crece: con lo que baja o con lo que hay?

#### 🟠 Ejercicio 18 — La memoria del servidor

Con `docker stats`, mira la memoria de CouchDB en reposo, cargando el millón y atendiendo la bajada por `selector`.

**Objetivo:** las tres cifras, y cuál le pondrías como límite al servicio.

#### 🟠 Ejercicio 19 — La autopsia de "sincronizo y ya"

Toma la fila "el último que escribe gana" de la sección 4.1.

**Objetivo:** los cinco pasos de la autopsia, con las 242 ediciones como factura.

### 🔴 Muy difícil — romper y decidir (20–24)

#### 🔴 Ejercicio 20 — Otra rotura

Encuentra otra manera de que la replicación no converja, sin dos resolvedores.

**Objetivo:** el guion que la provoca, la cuenta por ronda y el mecanismo.

#### 🔴 Ejercicio 21 — Un CRDT de operaciones

Cambia la orden como CRDT por un registro de operaciones —un documento por operación, nunca editado— y una vista
que arma la orden.

**Objetivo:** conflictos, tamaño y bytes de la apuesta, contra la primera fila de la sección 4.1.

#### 🔴 Ejercicio 22 — El presupuesto de la tableta

Con los números de esta fase, escribe cuántas órdenes, cuántos guardados por orden y cuántos días sin señal caben
en una tableta con 2 GB libres.

**Objetivo:** la cuenta, con cada supuesto declarado.

#### 🔴 Ejercicio 23 — Las fotos

Agrega a cada cambio de pieza una foto sintética de 300 KB como adjunto, y repite la apuesta y la sección 4.5.

**Objetivo:** bytes y segundos con y sin fotos, y qué cambia en el filtro.

#### 🔴 Ejercicio 24 — El veredicto para el segundo operador

El segundo operador estatal quiere que sus inspectores también trabajen sin señal.

**Objetivo:** sí o no, con qué forma de documento, quién resuelve y qué baja cada tableta, justificado con las
secciones 4 y 5.

### 🔥 Opcionales

- **Automerge contra `crdt.ts`**: el mismo viaje con `Automerge.Doc`, comparando bytes por orden y conflictos.
- **La replicación continua**: `live: true` en la tableta de Freddy, y medir cuántas peticiones hace por minuto sin
  cambios.

---

## 📚 12. Referencias

> ⚠️ Las URLs y sus contenidos cambian, y la documentación de CouchDB y PouchDB cubre la última versión. Esta
> fase se verificó con CouchDB 3.5.2 y PouchDB 9.0.0.

- **Compactación en CouchDB** — https://docs.couchdb.org/en/stable/maintenance/compaction.html — qué borra y qué no.
- **Conflictos en CouchDB** — https://docs.couchdb.org/en/stable/replication/conflicts.html — la ganadora
  determinista, y por qué la fusión que busca el antepasado común deja de poder hacerse después de compactar.
- **El protocolo de replicación** — https://docs.couchdb.org/en/stable/replication/protocol.html — `_revs_diff` y la
  lista de antepasados que viaja con cada documento.
- **PouchDB: compactación** — https://pouchdb.com/guides/compact-and-destroy.html — `compact()` y
  `auto_compaction` en el cliente.
- **La API de replicación de PouchDB** — https://pouchdb.com/api.html — las opciones `doc_ids` y `selector` de
  `replicate()`.
- **Kleppmann y Beresford, *A Conflict-Free Replicated JSON Datatype*** (IEEE TPDS, 2017) —
  https://arxiv.org/abs/1608.03960 — el CRDT de documentos JSON en el que se basa Automerge.
- **Kleppmann, Wiggins, van Hardenberg y McGranaghan, *Local-first software*** (Ink & Switch, 2019) —
  https://www.inkandswitch.com/local-first/ — los siete ideales, y por qué ningún producto los cumple todos.

**Orden sugerido:** compactación antes de la sección 4.4; conflictos, la parte de resolución, antes de la 5;
*Local-first software* al cerrar el veredicto.

---

## 🏁 13. Resultado de la fase

```text
CouchDB · servidor                                   Tabletas · PouchDB
  work_order_1m    1 000 000 órdenes, 578 MiB          freddy-100       las cien órdenes de la apuesta
  f20_bet          la apuesta, en su última forma     massive-*        dos tabletas, once hojas por orden
  f20_massive      100 órdenes · 1100 hojas            history          una orden, 2000 guardados
  f20_pingpong     la variante E, sin converger         size-*           la primera bajada con cada filtro
```

La apuesta se ganó, y no por la familia: el dataset no trae el caso que la habría hecho perder, y la realidad sí.
Lo que la fase deja medido es todo lo que el diseño decide: la forma que conserva las 552 ediciones o esconde 205,
la historia que pesa más que la orden, el conflicto sin resolver que crece una hoja por ronda, la compactación que
borra el antepasado, la tableta que baja más de lo que necesita, y dos resolvedores que no se ponen de acuerdo
aunque escriban lo mismo. Offline-first funciona, y cada una de esas cosas es una decisión que alguien tiene que
tomar antes del primer viaje.

> **La señal de que quedó bien:** *"Puedo decir quién resuelve los conflictos en mi sistema, qué baja cada tableta
> y por qué, y qué pasa con la fusión el día que alguien compacta."*

> 🏷️ **No cierres la fase sin el tag.** Con el checklist en verde y `git status` limpio:
>
> ```bash
> git tag -a fase-20-offline-romper-y-medir -m "F20 cerrada: apuesta 10 ganada (100 órdenes, 89 conflictos, 0 intervenciones con la forma CRDT; 205 escondidas o 242 perdidas con la de siempre), predicción perdida y el porqué; historia: 1000 guardados = 9,5 MiB en la tableta y 35 KiB en la subida, _revs_limit 1000; conflicto masivo +1 hoja por ronda; compactar deja las hojas y borra el antepasado; tamaño de tableta por filtro; servidor y tableta resolviendo lo mismo no convergen (rev distinto por motor)"
> ```
>
> Commits de la fase con prefijo `f20:`, los de ejercicio `f20 ej14: …`.
