# ⚡ Ruta NoSQL Lite

**Diez motores, un dominio, cinco preguntas.** Un curso corto para decidir con criterio qué
familia de base de datos le corresponde a tu sistema — y para poder defenderlo con una
medición propia, no con una bandera.

> 🧠 **El villano no es Mongo, ni Cassandra, ni el hype.** Es *elegir con un criterio que no
> predice el fracaso*. Las preguntas con las que la gente elige —"¿tengo esquema fijo?",
> "¿quiero evitar joins?"— son superficiales y no discriminan. Las que sí lo hacen son otras
> cinco, y este curso existe para instalarlas.

---

## 🎯 Qué es, y qué no es

**Es** tocar diez motores de verdad: levantarlos, modelar el mismo dominio en cada uno,
llevarlos hasta su punto de rotura, medir y escribir el veredicto honesto.

**No es** volverse experto en ningún producto, y el curso lo dice desde la primera línea.
Tampoco es un curso de operación: aquí no se administra nada en producción.

Tres compromisos lo separan de los mil *"MongoDB en 20 minutos"* que ya existen:

- 📐 **Se mide la forma, no la velocidad.** *"Esta consulta necesita tres viajes y escanea
  la partición entera"* seguirá siendo cierto dentro de cinco años; *"tarda 12 ms"* no lo es
  ya mañana en otra máquina. Se miden viajes, documentos examinados contra devueltos,
  particiones tocadas, fan-out y amplificación de escritura.
- 🪞 **Una apuesta falsable por familia.** Antes de ejecutar se escribe la predicción con su
  número. Después se mide y se publica el resultado, se gane o se pierda.
- 💥 **Un punto de rotura por familia.** Levantar y modelar lo hace cualquiera. Llevar el
  motor hasta que se rompe —y decir con qué volumen, con qué mensaje literal y cuánto costó
  salir— no.

Y una honestidad que va dicha en la primera fase y no escondida al final: **la mayoría de
las veces gana Postgres.** JSONB, full-text, `pgvector`, `WITH RECURSIVE`, particionado. El
curso va a por los casos donde eso no alcanza, y lo demuestra con las dos bases montadas.

---

## 👥 Para quién es

Ingenieros de software con experiencia y **sesgo relacional declarado**. Sabes SQL, sabes
qué es un índice y una transacción, y probablemente ya tomaste —o heredaste— una decisión
de NoSQL que salió regular.

No se explica qué es una CLI, qué es Docker ni qué es un índice. Sí se explica, con cero
ambigüedad, qué significa *unidad de lectura*, qué hace un `$lookup` por dentro o por qué
`ALLOW FILTERING` es una trampa y no una opción.

**Necesitas:** Docker o Podman, 16 GB de RAM recomendados y soltura leyendo TypeScript.

---

## ⏱️ Cuánto cuesta

**252 horas ≈ 21 semanas a 12 h semanales** (unos cinco meses). A 10 h semanales, seis.

| Bloque | Familias | Fases | Horas |
|---|---|---|---|
| **0 · El instrumento** | la tesis, el dominio, las cinco preguntas | F00–F02 | 12 h |
| **I · Los dos que ya usas** | documental · clave-valor | F03–F06 | 40 h |
| **II · Leer de otra forma** | analítico embebido · series temporales · búsqueda | F07–F12 | 60 h |
| **III · Preguntas que no sabes escribir en SQL** | grafos · vectorial | F13–F16 | 40 h |
| **IV · Cuando el dato no cabe en un nodo** | columnar ancha · offline-first · NewSQL | F17–F22 | 60 h |
| **V · El árbitro** | capstone políglota | F23–F25 | 40 h |

Cada familia son **dos semanas en dos fases**: la A levanta y modela, la B rompe, mide y
decide. Los apéndices, los proyectos boss y los miniproyectos van **fuera** de esas horas.

---

## 🗄️ Los diez motores y su rival permanente

**Postgres está montado en los diez minicursos.** No es un gesto de prudencia: es el
instrumento de medida. Sin la línea base relacional al lado, cualquier afirmación de este
curso sería una opinión.

| Familia | Motor | Línea base | La parte del dominio que le toca |
|---|---|---|---|
| 🍃 Documental | MongoDB | Postgres JSONB | la ficha de aeronave, polimórfica de verdad |
| 🔑 Clave-valor | Valkey | tabla `UNLOGGED` | reservas de hangar, candados, sesiones |
| 🦆 Analítico embebido | DuckDB | Postgres | el costo por hora volada |
| ⏱️ Series temporales | TimescaleDB | Postgres particionado | los parámetros de vuelo |
| 🔍 Búsqueda | OpenSearch | Postgres FTS | el catálogo de partes |
| 🕸️ Grafos | Neo4j | `WITH RECURSIVE` | la trazabilidad de cada pieza en el tiempo |
| 🧬 Vectorial | Qdrant | `pgvector` | *"esto ya lo vimos"* en los reportes de piloto |
| 🏛️ Columnar ancha | Cassandra | Postgres particionado | los parámetros que no caben en un nodo |
| 📴 Offline-first | CouchDB + PouchDB | — | el técnico en una pista sin señal |
| ⚡ NewSQL | CockroachDB | Postgres de un nodo | el expediente con tres autoridades en tres países |

Todas las imágenes van **fijadas por digest** y con fecha de verificación ejecutada. Las
versiones vigentes viven en el apéndice `a02` y en ningún otro sitio.

---

## ✈️ Una empresa, diez modelos

**Cóndor MRO**, un taller aeronáutico de reparación que mantiene ciento cuarenta aeronaves
de ocho operadores en tres países, modelado diez veces. Fijar el dominio y variar solo el
modelo es lo que hace comparables las mediciones; si cada familia trajera su propio
ejemplo, esto serían diez tutoriales puestos en fila.

Aeronaves que no tienen los mismos campos, piezas que viajan entre aviones, almacenes y
talleres aliados durante años, parámetros de vuelo que se descargan al aterrizar, reportes
de piloto escritos con prisa y con jerga, un técnico que pasa tres días en pistas sin señal
y un expediente que no puede salir de su país. Y debajo de todo, alguien que firma con su
licencia que el avión puede volar. La empresa entera está en
[`00-historia-de-condor.md`](00-historia-de-condor.md). Los datos se generan con semilla
determinista: **la misma medición en tu máquina y en la mía**.

---

## 🚦 Por dónde empezar

**Orden de aprendizaje** — el de las fases, y el que conviene si vas a hacer el curso
entero. El Bloque 0 no se salta: sin él, esto son diez tutoriales de producto.

**Orden de publicación** — distinto a propósito. Documental abre por los dos criterios, y
**vectorial se adelanta al tercer puesto** aunque pedagógicamente le tocara mucho más tarde.
El curso puede permitírselo porque los minicursos son casi independientes.

**Si solo vas a hacer un bloque, haz el 0 y el I.** Son 52 horas, cierran con su boss y
salen con criterio utilizable, no con medio curso.

> 📍 **Publicado hoy:** el Bloque 0 y el Bloque I completos —[F00](00-la-decision-que-se-hereda.md) a
> [F06](06-clave-valor-romper-y-medir.md)—, con el boss *"La orden que entró dos veces"*, los
> miniproyectos de Barlovento y Nodo Sur, y los diez apéndices en el estado que esas fases necesitan.
> Qué está publicado y qué viene después, fase por fase, en
> [`0-ESTRUCTURA-CURSO.md`](0-ESTRUCTURA-CURSO.md).

---

## 🏆 Los proyectos boss y los miniproyectos

- 🏆 **"El Hangar"** — el boss global, acumulativo y **opcional**. El sistema que Cóndor
  necesita para saber dónde está cada pieza y de dónde vino, y que crece con el curso: cada bloque le añade un motor y una
  capacidad. Es la única parte que se consume en orden, y es el mejor portafolio que deja la
  ruta.
- 💀 **Un boss por bloque** — un encargo interno de Cóndor que solo se resuelve cruzando
  las familias de ese bloque, y que empieza con un sistema roto. No es un ejercicio difícil
  con mejor nombre.
- 🧰 **Un miniproyecto por familia** — el encargo de **otra empresa**: un puerto, un
  proveedor de internet, una agencia de publicidad, una distribuidora eléctrica y una
  cooperativa cafetera. Existe para demostrar que lo aprendido es un modelo de acceso y no
  un truco del dominio. Opcional, de 4 a 6 h, y se anuncia al abrir cada fase B. El índice
  está en [`miniproyectos.md`](miniproyectos.md).

---

## 📚 Cómo está organizado

- **`00-historia-de-condor.md`** — la empresa del curso. No es una fase: es de donde sale
  todo lo narrativo.
- **`0-ESTRUCTURA-CURSO.md`** — el temario en una página: horas, ejercicios, estado de cada fase y
  orden de publicación.
- **Fases** `00-…md` a `25-…md` — el curso. Dos por familia.
- **Miniproyectos** `h-mini-01-…md` a `h-mini-10-…md` — uno por familia, de otra empresa.
- **Apéndices** `a01-…md` a `a10-…md` — transversales a toda la ruta, de receta y no de
  pedagogía: laboratorio en tres plataformas, el `compose.yaml`, CLIs, el arnés de medida,
  el dominio y sus datos, lenguajes y drivers, Postgres como línea base, diccionario de
  traducción, catálogo de errores y licencias.
- **Documentos vivos** — `bitacora-de-medicion.md` (toda medición publicada, con su comando
  de reproducción), `a09-catalogo-de-errores.md` (todo error con su mensaje literal) e
  `INSTINTOS.md` (cada punto donde el instinto relacional falla, con la medición que lo
  prueba).
- **`src/`** — el código que se ejecuta: el laboratorio (`src/lab/compose.yaml`, de `a02`), el
  generador de datos (`src/lab/generator/`, de `a05`) y el entorno de TypeScript y Python con
  sus versiones fijadas (`a06`). Cada fase deja el suyo en `src/NN-nombre/`.
- **`prompts/`** — el aparato editorial: alcance, guía de estilo, propuestas de fases y
  apéndices, plantillas y los prompts de redacción.

---

## 🗺️ Dónde encaja en el repositorio

- **`docker-container-legacy/`** es la infraestructura de laboratorio. Aquí se dan recetas;
  el mecanismo se explica allí. Este curso **no enseña Docker** a propósito.
- **`ruta-no-sql/`** es la especificación de los cursos profundos por familia. Cada
  minicurso de la Lite es el tráiler del suyo.
- **`tutorial-rag/`** conecta con el minicurso vectorial.

---

## ⚖️ Lo que este curso promete al terminar

Que puedas entrar a un design review y **descartar motores con argumento**, en vez de
proponerlos todos. Que sepas responder las cinco preguntas sobre tu propio sistema. Y que,
cuando la respuesta honesta sea *"esto lo resuelve Postgres"*, lo digas sin que te duela el
ego — con el número delante.
