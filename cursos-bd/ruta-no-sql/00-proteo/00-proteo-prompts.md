# 🧩 Prompts — Proyecto Proteo

> Prompts reutilizables para arrancar y sostener la redacción del curso
> Proteo en un proyecto nuevo, sin depender del historial de esta
> conversación. Cada prompt es **autónomo**: incluye el contexto mínimo
> necesario para correr solo, pegado en un chat en blanco con
> `00-proteo-semilla.md`, `PROTEO-ALCANCE.md` y `PROTEO-GUIA-ESTILO.md`
> adjuntos como archivos de proyecto (o resumidos inline si no hay adjuntos).

---

## 1. Prompt de arranque — Fase 0

```
Vas a redactar la Fase 0 del curso "Proteo" (modelo documental) de la Ruta
NoSQL. Actuás como coautor senior de un curso técnico en español, no como
generador genérico de tutoriales.

CONTEXTO MÍNIMO (si no tenés los archivos del proyecto adjuntos, usá esto):

- Dominio: backend de un marketplace multi-vertical con PIM propio
  (electrónica, moda, libros, alimentos), donde cada vertical tiene su
  propia forma de atributos y el negocio agrega categorías sin
  coordinación central como parte de su operación normal.
- Modelo de acceso enseñado: documental (agregado autocontenido: lo que se
  lee junto, se guarda junto).
- Rivales medidos: MongoDB 8.0 (motor principal), Couchbase Server 8.0
  (segundo rival documental, memoria-first, N1QL/SQL++), PostgreSQL 18
  (EAV real y JSONB+GIN como las dos mejores armas del relacional).
- Stack completo: Node.js 24 LTS, TypeScript, Express 5, Zod,
  Redis/Valkey, Meilisearch 1.48.x, Docker/Podman + Compose.
- Villano de la ruta: usar el motor donde no toca. Villano específico de
  Proteo: EAV (Entity-Attribute-Value) en Postgres — el "crimen inverso"
  simétrico al villano documental de otros cursos.
- Esqueleto no negociable de cada fase (nueve secciones): 🎯 Propósito, ✅
  Qué queda listo, 🚫 Qué queda fuera, 🧠 Conceptos mínimos, 💻
  Implementación y código comentado, ⚠️ Errores comunes y pieza forense, 🧪
  Ejercicios (20-40, graduados 🟢🟡🟠🔴), 📚 Referencias, 🚀 Cierre y conexión.
- Recuadros propios del modelo: 📖 tabla de traducción SQL↔MQL↔N1QL, 🪞 "tu
  instinto SQL se equivoca", 🩻 "esto sí viaja igual", ⚖️ "y acá el
  instinto SQL tenía razón", ⚰️ caso de estudio del villano.
- Regla de idioma: código, endpoints, colecciones/tablas, campos, enums en
  inglés; narrativa, comentarios y textos de UI en español, sin voseo
  (usar "tú").
- Nunca confundir Couchbase (rival de este curso) con CouchDB (pertenece a
  otro curso de la ruta, offline-first).

TAREA DE ESTA FASE (Fase 0 — El laboratorio de varios motores):

1. Redactar un `docker-compose.yml` comentado que levante MongoDB 8,
   PostgreSQL 18, Couchbase 8, Redis/Valkey y Meilisearch, con un
   contenedor de herramientas (Node 24 + TS), y con el `replica set` de un
   nodo habilitado desde el inicio en Mongo (lo necesita Change Streams en
   la Fase 10, no se reconfigura a mitad de curso).
2. Diseñar el generador de datos que produce el MISMO catálogo semántico
   en las cuatro formas (documento Mongo, documento Couchbase, EAV
   Postgres, JSONB Postgres), parametrizable por volumen, con semilla fija
   para reproducibilidad.
3. Hacer nacer `scripts/vs.ts`: el arnés que ejecuta la misma consulta
   semántica contra los motores en juego, cronometra percentiles (p50/p95)
   descartando warm-up, verifica equivalencia de resultados, y escribe una
   fila en `BENCHMARKS.md`. Incluir su primer duelo trivial (lectura por
   id) para validar el arnés end-to-end.
4. Inaugurar `INSTINTOS.md` con la primera predicción falsable (antes de
   medir): "una tabla de atributos flexible es la forma normal de resolver
   esto en SQL — ¿qué tan caro va a salir leer una ficha completa?".
5. Seguir la plantilla de 9 secciones. 20-40 ejercicios graduados,
   incluyendo al menos uno de diagnóstico (ej.: el Compose no levanta por
   puerto ocupado o memoria insuficiente de Couchbase — reproducir y
   arreglar).
6. Cerrar con Apéndice A (arranque de motores por contenedor) y Apéndice E
   (troubleshooting de setup) si el volumen de la fase lo justifica, o
   dejarlos marcados como pendientes para una fase de apéndices aparte.

Restricciones: no inventar IDs de video, DOIs ni páginas de libro en
referencias; marcar que deben verificarse. No mezclar Couchbase con
CouchDB en ningún fragmento. Todo "vs" que se narre debe tener su fila en
`BENCHMARKS.md`, generada por el propio `vs.ts` que estás definiendo en
esta fase.

Entregá el archivo `.md` completo de la Fase 0.
```

---

## 2. Prompt-plantilla por fase (parametrizable)

Usar este prompt para cualquier fase 1–12, reemplazando los campos entre
`{{ }}` con los datos de la tabla de fases de `00-proteo-semilla.md`.

```
Vas a redactar la Fase {{NÚMERO}} del curso "Proteo" (modelo documental) de
la Ruta NoSQL: "{{NOMBRE DE LA FASE CON GANCHO}}".

CONTEXTO MÍNIMO (repetir el bloque de contexto del prompt de Fase 0 si no
hay archivos de proyecto adjuntos con la semilla, el alcance y la guía de
estilo).

ESTADO PREVIO: las fases 0 a {{NÚMERO - 1}} ya están escritas y aprobadas.
No las contradigas: reusá los mismos nombres de colección, tabla, campo y
endpoint que ya se fijaron (ver §12 de `PROTEO-GUIA-ESTILO.md`). Si esta
fase necesita un campo o colección nueva, decilo explícitamente como
adición, no como cambio silencioso de lo anterior.

NÚCLEO DE ESTA FASE: {{descripción del "Núcleo" de la tabla de fases}}.

"VS" DE ESTA FASE: {{descripción de la columna "Vs de la fase"}}. Este "vs"
se implementa como un duelo nuevo o extendido en `scripts/vs.ts` y su
resultado se agrega como fila nueva en `BENCHMARKS.md` con fecha, versión
de motor, tamaño de dataset y hardware. No narres el resultado sin haberlo
corrido primero por el arnés (si no podés ejecutar código, dejá el bloque
de resultados como plantilla a completar con la corrida real, marcado
claramente como "pendiente de ejecución").

RECUADROS A INCLUIR SI APLICAN EN ESTA FASE:
- 🪞 "Tu instinto SQL dice… y esta vez se equivoca" — nombrá la trampa
  específica de esta fase ANTES de que el lector caiga.
- 🩻 "Esto sí funciona igual" — qué sobrevive intacto del mundo relacional.
- ⚖️ "Y acá el instinto SQL tenía razón" — únicamente si esta fase es una de
  las que el veredicto reconoce a favor de lo relacional (Fase 3, Fase 12).
- 📖 Tabla de traducción SQL ↔ MQL ↔ N1QL/SQL++ para las consultas nuevas
  de esta fase.
- ⚰️ Solo en las fases 1 y 11: el villano (EAV) construyéndose o siendo
  disecado.
- 📓 Agregar al menos una entrada nueva a `INSTINTOS.md` (predicción antes
  de medir, resultado, veredicto) si esta fase introduce un instinto nuevo
  a poner a prueba.

FORMATO: seguí exactamente la plantilla de 9 secciones de
`PROTEO-GUIA-ESTILO.md` §8. Entre 20 y 40 ejercicios graduados 🟢🟡🟠🔴,
anclados al dominio de Proteo, con numeración continua y encabezados de
rango, incluyendo al menos un ejercicio de diagnóstico. Código con
identificadores en inglés, comentarios y narrativa en español sin voseo.
Referencias al cierre de la fase (sección 8), con URLs completas,
secciones separadas (oficial/libros/video/orden de lectura) y advertencia
de que deben verificarse; no inventes IDs ni DOIs.

Entregá el archivo `.md` completo de la Fase {{NÚMERO}}.
```

### Tabla de referencia rápida para completar `{{ }}` (de la semilla)

| # | Nombre de fase | Núcleo | Vs de la fase |
|---|---|---|---|
| 1 | ⚖️ El marco, para decidir | Las 5 preguntas ANTES de modelar; se construye el EAV en SQL y se siente el dolor en vivo | EAV vs JSONB vs documento (escritura y lectura de ficha) |
| 2 | 🧬 Heterogeneidad como feature | Catálogo de 4 verticales en documentos; `$jsonSchema` polimórfico | EAV vs JSONB+GIN vs documento — costo de categoría nueva sin migración |
| 3 | 📄 La página del producto | El `findOne` que sirve la ficha completa de un tiro | JSONB **empata** en lectura de blob — primer "vs" honesto donde Mongo no gana |
| 4 | ⭐ Reseñas: embeber, referenciar o "depende del tamaño" | Bucket pattern + computed pattern | `AVG`/`COUNT` relacional vs patrones de documento |
| 5 | 📦 Inventario multi-almacén | Array de subdocumentos; `$inc` atómico; precondición en el filtro | Decremento concurrente vs tabla puente `warehouse_stock` |
| 6 | 🕰️ Historial de precios y el pedido como fotografía | El documento de orden congela el producto (inmutable por diseño) | SCD Type 2 relacional vs snapshot embebido |
| 7 | 🔍 Búsqueda y facetas | `$facet` de aggregation | SQL+GIN vs Mongo `$facet` vs Meilisearch |
| 8 | 🕸️ "Quienes compraron X también compraron Y" | Co-ocurrencia con aggregation | Por qué esto es agregación y no grafo |
| 9 | 🛒 El carrito: key-value en su hábitat | Redis con TTL | Redis vs carrito-como-colección-Mongo |
| 10 | 🔄 Change Streams | Mongo alimentando Meilisearch/Redis en tiempo real | — (se mide latencia de propagación) |
| 11 | ⚰️ La autopsia inversa | EAV completo medido de punta a punta; conversión a documento | El ritual del villano, en espejo |
| 12 | ⚖️ El veredicto con las dos manos | Documento gana el catálogo; relacional gana pagos/contabilidad | Documento vs relacional en su propio terreno (el libro mayor) |

---

## 3. Prompt para `INSTINTOS.md`

Usar una vez al arrancar el proyecto (crea el archivo) y luego para pedir
que se agregue una entrada nueva al cerrar cada fase.

```
Vas a {{crear / actualizar}} `INSTINTOS.md` del curso "Proteo" (modelo
documental, Ruta NoSQL).

QUÉ ES: el diario de instintos SQL puestos a prueba a lo largo del curso.
Cada entrada tiene exactamente esta forma:

- **Instinto:** el instinto relacional tal como lo diría un senior de SQL
  ("una tabla de atributos flexible es la forma normal de hacer esto",
  "embebé todo lo que se lee junto", "esto es claramente un problema de
  grafo").
- **Predicción falsable:** una afirmación medible, escrita ANTES de correr
  el benchmark ("leer una ficha completa vía EAV va a ser al menos 5x más
  lento que vía documento a 10k productos").
- **Resultado del cronómetro:** el número real, con referencia a la fila
  correspondiente de `BENCHMARKS.md` (motor, dataset, p50/p95, fecha).
- **Veredicto:** el instinto acertó / se equivocó / "esta vez sí viaja
  igual". No se borra un instinto equivocado: se deja con su autopsia.
- **Fase de origen:** en qué fase nació esta entrada.

REGLA DURA: ninguna entrada se escribe sin una fila correspondiente en
`BENCHMARKS.md` que la respalde, salvo que sea explícitamente un instinto
todavía sin medir (marcado "⏳ pendiente de medición" y con la predicción
igual escrita de antemano).

{{Si estás creando el archivo: generá la primera entrada de la Fase 0, la
predicción sobre EAV vs documento antes de que el curso la mida en la Fase
1.}}

{{Si estás actualizando: agregá la(s) entrada(s) nueva(s) de la Fase
{{NÚMERO}}, sin tocar ni reformular las entradas anteriores.}}

Español, sin voseo, tono de diario técnico (no de reporte corporativo).
```

---

## 4. Prompt para `BENCHMARKS.md`

```
Vas a {{crear / actualizar}} `BENCHMARKS.md` del curso "Proteo" (modelo
documental, Ruta NoSQL).

QUÉ ES: la memoria acumulativa de todos los "vs" ejecutados por
`scripts/vs.ts`. Es evidencia, no narración: cada fila representa una
corrida real (o, si no podés ejecutar código, una plantilla de corrida
claramente marcada como "pendiente de ejecución real" — nunca un número
inventado presentado como medido).

FORMATO DE CADA FILA (tabla, no prosa):

| Fecha | Fase | Consulta semántica | Motores comparados | Dataset (volumen) | Versión de motor | Hardware | p50 | p95 | Lectura |
|---|---|---|---|---|---|---|---|---|---|

- **Consulta semántica:** qué se está midiendo en términos de negocio
  ("lectura de ficha completa por id", "decremento de stock bajo 50
  escrituras concurrentes"), no solo el nombre de la query.
- **Lectura:** una frase corta de interpretación ("JSONB empata en lectura
  por id; pierde 4x en categoría nueva sin migración"), nunca una
  afirmación de rendimiento sin la fila que la sostiene.

REGLA DURA: nada entra a este archivo sin haber pasado por el arnés
`scripts/vs.ts`. Si estás redactando contenido de curso y necesitás citar
un "vs" que todavía no se ejecutó, generá la fila con los campos de
identificación completos y los campos numéricos marcados `⏳ pendiente`.

{{Si estás creando el archivo: generá la cabecera y la primera fila
(duelo trivial de lectura por id de la Fase 0).}}

{{Si estás actualizando: agregá la(s) fila(s) nueva(s) del "vs" de la Fase
{{NÚMERO}} ({{descripción del vs de esa fase}}), sin modificar filas
anteriores.}}

Español para la columna "Lectura"; el resto de las columnas puede llevar
términos técnicos en inglés cuando sea el nombre real (endpoint, motor,
query).
```

---

## 5. Prompt para el diccionario de traducción (SQL ↔ MQL ↔ N1QL/SQL++)

```
Vas a generar (o extender) la tabla de traducción SQL ↔ MQL ↔ N1QL/SQL++
del curso "Proteo" (modelo documental, Ruta NoSQL), para usar dentro del
recuadro 📖 de la sección "🧠 Conceptos mínimos" de la Fase {{NÚMERO}}.

FORMATO (tabla, no prosa):

| Operación | SQL (PostgreSQL) | MQL (MongoDB) | N1QL/SQL++ (Couchbase) |
|---|---|---|---|

CUBRIR EN ESTA ENTREGA las operaciones que introduce la Fase {{NÚMERO}}:
{{listar operaciones concretas de la fase, ej.: "filtro por categoría",
"actualización atómica de stock con precondición", "`$facet` con conteos
agrupados"}}.

REGLAS:
- Cada fila debe ser una traducción REAL y ejecutable en los tres motores
  con el stack fijado (Postgres 18, MongoDB 8.0, Couchbase Server 8.0), no
  una aproximación conceptual.
- Usar el vocabulario del dominio de Proteo en los ejemplos (tabla/colección
  `products`, campos `sku`, `category`, `warehouseId`), no ejemplos
  genéricos de `users`/`orders` sin contexto.
- Si una operación no tiene equivalente directo en uno de los tres motores
  (por ejemplo, algo que en Postgres exige EAV y en Mongo es un campo
  directo), decirlo explícitamente en una fila con la columna
  correspondiente marcada "— (requiere EAV, ver Fase 1/11)" en vez de
  forzar una traducción falsa.
- Identificadores de código en inglés dentro de cada celda; el nombre de
  la "Operación" en español.

Entregá solo la tabla lista para pegar en la fase, con una línea de
introducción en español (sin voseo) que la contextualice.
```
