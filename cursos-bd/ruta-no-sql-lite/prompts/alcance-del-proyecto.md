# 🎯 Alcance del proyecto
## Ruta NoSQL Lite — Diez motores, un dominio, cinco preguntas

> **Qué es este documento:** la fuente de verdad de **qué** enseña el curso, a quién y con
> qué límites. Lo que no esté aquí, no está en el curso.
> **Fecha de cierre de esta versión:** 10 de septiembre de 2026 · **revisada** el 29 de
> septiembre de 2026 para adoptar Cóndor MRO como dominio y dar de alta los miniproyectos
> **Precedencia:** manda este documento, después
> [`guia-de-estilo-y-convenciones.md`](guia-de-estilo-y-convenciones.md) —que decide
> **cómo** se escribe—, después las dos propuestas de alcance, y las plantillas y prompts
> se actualizan siempre al final. Por encima de todos, el `CLAUDE.md` del repositorio en
> lo que este curso no haya declarado como excepción (§12).

---

## 1. 🧭 En una frase

**Un curso corto que enseña a elegir familia de base de datos con criterio, tocando diez
motores de verdad y midiendo la forma de cada consulta en lugar de repetir lo que dice la
documentación.**

No forma expertos en MongoDB, ni en Cassandra, ni en ningún producto. Forma la capacidad
de mirar un dominio y decir *"esto es documental por esta razón concreta, y estas otras
tres cosas del sistema no lo son"*, con una medición encima de la mesa.

---

## 2. 🔥 El problema que resuelve

El origen no es académico. Son fricciones reales de proyectos donde se eligió Mongo o
Cassandra por razones que sonaban bien en la reunión y que dos años después habían
costado un rediseño: *"es NoSQL"*, *"no quiero joins"*, *"meto el JSON completo y listo"*,
*"esto tiene que escalar"*.

> 🧠 **El villano no es Mongo, ni Cassandra, ni el hype.** Es **elegir con un criterio que
> no predice el fracaso**. Las preguntas con las que la gente elige —"¿tengo esquema
> fijo?", "¿quiero evitar joins?"— son superficiales y no discriminan. Las que sí lo hacen
> son otras cinco (§5), y el curso entero existe para instalarlas.

Ese villano tiene dos caras, y el curso las cuenta como dos situaciones. No son dos
problemas distintos: son **la misma decisión tomada por el mismo motivo malo** —el
criterio real fue *quién lo dice y qué me resulta familiar*, no *qué modelo de acceso
tiene el dominio*—.

**Situación 1 — el hype.** El sistema sale bien con SQL y aun así se elige NoSQL porque
toca. Su corte es verificable en diez segundos contra la colección de cualquiera: **si
todos los documentos tienen las mismas claves y ninguna anida más de un nivel, no tienes
una base documental, tienes una tabla cara.** Pero ese corte ya es casi consenso y la
gente asiente sin cambiar nada, así que **el material está en el segundo acto**: aparece
la segunda colección, hay que juntarlas, el join termina escrito en el código de la
aplicación, y ahí se disolvió la frontera transaccional sin que nadie lo anotara en
ningún sitio. El coste no fue la flexibilidad desperdiciada; fue que dos años después
nadie sabe cuándo entraron las inconsistencias ni cuáles son.

**Situación 2 — la zona de confort.** La inversa: el problema lo resolvería mejor otro
modelo —o varios en conjunto— y se resuelve en relacional porque es lo que el equipo
domina. Es más difícil de demostrar que la 1, porque exige un contrafáctico, y por eso el
curso la ataca con las dos bases montadas y midiendo la forma (§6), nunca con una cita.

**Situación 3 — la más común de todas, y va una por familia.** Elegiste bien la familia y
aun así te fue mal, **porque la modelaste como si fuera relacional**: Mongo lleno de
referencias, Cassandra modelada por entidades en vez de por consulta, Redis usado como
almacén primario. Es la que entrega gratis el 🪞 *"tu instinto relacional dice… y esta vez
se equivoca"* en cada minicurso.

> ⚠️ **El antagonista no puede ser una persona.** Ni el jefe que pidió Mongo ni el
> arquitecto que se quedó en Postgres. Si el villano es alguien, pierdes justo al lector
> que más lo necesita —el que tomó esa decisión—, y en la situación 2 ese lector **es
> literalmente la audiencia objetivo**. La versión que funciona defiende el argumento
> antes de desmontarlo: quien pide Mongo no suele decir una tontería, dice *"el esquema va
> a cambiar mucho"* o *"esto tiene que escalar"*, que son preocupaciones legítimas con el
> instrumento equivocado. **Autopsia, no juicio:** en la mesa está la decisión, no la
> persona.

Y la honestidad que va dicha en la primera fase y no escondida al final: **la mayoría de
las veces gana Postgres.** JSONB, full-text, `pgvector`, `WITH RECURSIVE`, particionado
declarativo. Cuando hace falta otro motor, casi siempre es **al lado** y no en lugar de.
El curso va a por los casos donde eso no alcanza, y los demuestra montando las dos bases.

---

## 3. 🎓 Objetivo pedagógico

Al terminar, el estudiante puede hacer cuatro cosas que antes no podía:

1. **Diagnosticar un dominio** con las cinco preguntas y decir qué familia le corresponde
   a cada parte del sistema —porque casi nunca es una sola—.
2. **Medir la forma de una consulta** en cualquiera de los diez motores: cuántos viajes,
   cuántos documentos examinados contra devueltos, qué fan-out, cuánta amplificación de
   escritura, y qué pasa cuando el dato deja de caber en un nodo.
3. **Defender o rebatir una decisión de arquitectura** en un design review con números
   propios, no con una bandera.
4. **Hacer el triaje de una decisión ya tomada y equivocada**: qué se migra, en qué orden,
   qué se deja, y cómo se hace con la base en producción y sin parar el negocio.

Lo que **no** es objetivo: operar ninguno de estos motores en producción, tunear un
clúster, ni aprobar una certificación de producto.

---

## 4. 👥 Perfil del estudiante

Ingeniero de software con experiencia y **sesgo relacional declarado**. Sabe SQL, sabe
qué es un índice, una transacción y un plan de ejecución. Probablemente ya tomó —o
heredó— una decisión de NoSQL que salió regular.

**Lo que se da por sabido y no se explica jamás:** qué es una CLI, qué es Docker, qué es
un contenedor, qué es HTTP, qué es un índice, qué es una transacción, qué es JSON.

**Lo que sí se explica con cero ambigüedad**, aunque el lector sea senior: qué significa
exactamente *unidad de lectura*, qué hace un `$lookup` por dentro y en qué se parece y en
qué no a un `LEFT JOIN`, por qué `ALLOW FILTERING` es una trampa y no una opción, qué es
de verdad la consistencia eventual sin misticismo, y qué mide cada campo de un `explain`.

> 🧭 ***"Como para un bebé"* en este curso significa ninguna caja negra prematura, no
> menos profundidad.** No se infantiliza a nadie: se elimina la ambigüedad. Si una frase
> obliga al lector a suponer algo, está mal escrita.

**Requisitos de entrada:** Docker o Podman funcionando, 16 GB de RAM recomendados, y
soltura leyendo TypeScript. No hace falta escribir Python a diario: lo poco que aparece
va explicado y acotado (§9).

---

## 5. 🎯 El instrumento: las cinco preguntas

Es la contribución intelectual del curso y lo único que no se puede copiar de la
documentación de nadie. Se presenta entera en la Fase 02 y **reaparece en el cierre de
cada minicurso**, respondida para esa familia.

1. **¿Dónde está la frontera transaccional?** ¿Necesitas atomicidad cruzando entidades, y
   cuáles? *Es la que más caro sale ignorar*, porque cuando se disuelve no avisa: se nota
   dos años después, en forma de inconsistencias sin fecha de entrada.
2. **¿Conoces tus consultas de antemano, y son estables?** Casi todo NoSQL lo exige —y la
   gente elige NoSQL justo cuando **menos** lo sabe—. En Cassandra cada consulta nueva es
   una tabla nueva más un backfill; eso no es un defecto del motor, es el trato.
3. **¿Cuál es la unidad de lectura?** ¿Lees el agregado entero o rebanadas de muchos
   agregados? Es la pregunta que separa documental de columnar, y la que decide si
   embeber o referenciar.
4. **¿Cuántos saltos tiene tu relación típica, y los conoces de antemano?** Uno o dos no
   justifican un grafo: `WITH RECURSIVE` aguanta. Lo que rompe no es descender un árbol,
   es **buscar un patrón** de profundidad desconocida.
5. **¿Necesitas exactitud o parecido?** Es la frontera entre búsqueda por palabra clave y
   búsqueda vectorial, y la única familia sin equivalente relacional razonable.

Y la pieza que casi nadie escribe, que cierra la Fase 02: **"ya elegiste mal, ¿ahora
qué?"** — el triaje de migración con 400 GB en producción y sin poder parar el negocio.
Ahí está el dolor urgente del curso, y por eso es la parte con más valor real.

---

## 6. 📐 Cómo se mide: la forma, no la velocidad

Es una decisión técnica con consecuencia editorial en cada página.

Un número de latencia caduca con la versión, con el hardware y con la carga de la
máquina; una medida estructural no. *"Esta consulta necesita tres viajes y escanea la
partición entera"* seguirá siendo cierto dentro de cinco años. *"Tarda 12 ms"* no lo es ya
mañana en otra máquina.

Lo que el curso mide, entonces:

- **viajes de ida y vuelta** entre la aplicación y el motor para resolver una operación;
- **documentos, filas o columnas examinados contra devueltos** —el cociente, no el total—;
- **particiones o segmentos tocados** por consulta;
- **fan-out** de una escritura: cuántas estructuras se actualizan al escribir una vez;
- **amplificación de escritura y de espacio** en los motores LSM;
- **qué se rompe cuando el dato deja de caber en un nodo**, que es la pregunta que
  ninguna demo de laptop contesta.

Los tiempos se anotan **como contexto, nunca como argumento**, y siempre con la máquina,
la versión y el digest de imagen al lado. Un veredicto del curso jamás se sostiene sobre
un milisegundo.

Medir la forma es también lo que hace pagable **la hipoteca de mantenimiento**. Un curso
legacy se puede congelar porque todo lo que enseña está EOL; aquí los diez motores se
mueven solos. Por eso las imágenes van fijadas por digest y no por tag, cada documento
declara su fecha de verificación ejecutada y el texto apunta al mecanismo y no a la
versión. Lo que envejece de verdad son los `compose.yaml`, y esos se actualizan en diez
minutos.

Y sobre eso se montan las dos anclas que impiden que el curso degenere en resumen de
documentación —el único riesgo serio que tiene—:

- 🪞 **Una apuesta falsable por familia.** Antes de ejecutar se escribe la predicción y el
  número esperado. Después se mide y se publica el resultado, se gane o se pierda. **La
  apuesta que se pierde en público vale más que diez mediciones favorables**, y además
  inmuniza contra la acusación de estar vendiendo motores.
- 💥 **Un punto de rotura por familia.** Levantar y modelar lo hace cualquiera. Llevar el
  motor hasta que se rompe —y decir con qué volumen, con qué mensaje de error literal y
  cuánto costó salir— es lo que separa esto de los mil *"MongoDB en 20 minutos"*.

---

## 7. ✈️ El dominio: Cóndor MRO

Un dominio único para todo el curso, modelado diez veces. **Fijar el dominio y variar solo
el modelo es lo que hace comparables las mediciones**; si cada familia trajera su propio
ejemplo de juguete, no habría curso, habría diez tutoriales en fila.

El sistema: **Cóndor MRO**, un taller aeronáutico de reparación que mantiene una flota de
ciento cuarenta aeronaves de ocho operadores en tres países, desde seis bases. La empresa,
su gente, sus sistemas heredados y sus números viven en
[`00-historia-de-condor.md`](../00-historia-de-condor.md), que es la fuente de todo lo
narrativo del curso. Este apartado fija solo lo que el modelo de datos necesita.

> ⚠️ **El curso no enseña regulación aeronáutica.** Autoridades, certificados y programas
> están simplificados hasta el punto exacto en que le sirven al modelo de datos. Si algo
> choca con la realidad del oficio, gana el modelo de datos.

**Las diez entidades del dominio, que son las mismas en las diez familias:**

- `aircraft` — la ficha de la aeronave: matrícula, modelo, año, configuración y
  equipamiento opcional. Dos aeronaves del mismo modelo no tienen los mismos campos, y ahí
  empieza todo.
- `part` — la pieza instalable **con identidad propia**: número de serie, horas, ciclos y
  su propia historia, que no es la de ningún avión.
- `partCatalog` — el catálogo: números de parte, alternos, equivalentes por modelo y
  proveedores.
- `assembly` — el conjunto (motor, tren, hélice): contiene piezas y se instala como una sola
  cosa. La diferencia con `part` es de identidad, no de tamaño.
- `workOrder` — la orden de trabajo: qué se hizo, quién, cuándo, qué se instaló y qué se
  retiró. Es la entidad con frontera transaccional de verdad, y su historia es la que
  construye el grafo de trazabilidad.
- `reading` — la lectura descargada al aterrizar: parámetro de vuelo, horas, ciclos. Llega
  ordenada y no se corrige nunca.
- `pirep` — el reporte del piloto, en prosa telegráfica, con jerga y con faltas.
- `technician` — el técnico y su licencia, que es lo que decide qué puede firmar.
- `hangar` — la base o el taller.
- `supplier` — el proveedor de partes **y** el taller aliado, distinguidos por su tipo.

**La frontera transaccional del dominio es la liberación al servicio**: un inspector firma,
con su licencia, que todo lo instalado en la aeronave tiene trazabilidad válida. Es
también frontera legal, y es la que el curso vuelve a encontrar en cada familia.

**Cómo ilumina cada familia, sin forzar nada:**

| Familia | La parte del dominio que le toca |
|---|---|
| Documental | la ficha de aeronave, polimórfica por modelo y equipamiento |
| Clave-valor | la reserva del puesto de hangar, el candado de la orden abierta, las sesiones del terminal de plataforma |
| Analítico embebido | el costo por hora volada, por modelo y por operador: el precio de venta de Ala Continua |
| Series temporales | los parámetros de vuelo que se descargan al aterrizar, y sus roll-ups |
| Búsqueda | el catálogo de partes: números, alternos y equivalencias, tecleados mal |
| Grafos | la trazabilidad: *"¿en qué aeronaves estuvo instalada alguna vez una pieza de este lote, y qué se desmontó junto con ella?"* — profundidad y camino desconocidos, a través del tiempo |
| Vectorial | *"esto ya lo vimos"*: qué reporte de piloto se parece a este |
| Columnar ancha | los parámetros de vuelo cuando son las ciento cuarenta aeronaves y ya no caben en un nodo |
| Offline-first | el técnico itinerante en una pista del Guaviare sin señal |
| NewSQL | el expediente de la aeronave con tres autoridades, tres países y residencia de datos por contrato |

**Tres volúmenes para todo el curso**, generados con semilla determinista para que la
medición sea la misma en tu máquina y en la mía: **10 k** (desarrollo y ejemplos), **1 M**
(donde empiezan a notarse las decisiones de modelado) y **el volumen de rotura**, que cada
familia calibra por su cuenta. **El volumen cuenta los registros de la entidad principal de
cada familia** —`part` en documental, `reading` en series, `pirep` en vectorial…—, y el resto
del dataset escala con las proporciones de Cóndor. Por eso "los mismos datos" significa el
mismo generador, la misma semilla y las mismas proporciones, y **dentro de cada familia, el
motor y Postgres cargan exactamente los mismos bytes**, comprobados por hash. El detalle está
en `a05`, que decidió así el 29/09/2026.

---

## 8. 🗄️ Los diez motores y su rival permanente

**Postgres está montado en todos los minicursos.** No es un apéndice opcional ni un gesto
de prudencia: es el instrumento de medida. Sin la línea base relacional al lado, cualquier
afirmación del curso es una opinión.

| Familia | Motor del curso | Línea base | Por qué este y no otro |
|---|---|---|---|
| Documental | MongoDB | Postgres JSONB | es el default del mundo y el peor entendido |
| Clave-valor | Valkey | tabla `UNLOGGED` | fork BSD de Redis; ver a10 |
| Analítico embebido | DuckDB | Postgres | **habla SQL**, y por eso demuestra la tesis: lo que cambia el resultado no es el lenguaje ni la etiqueta, es el modelo de acceso |
| Series temporales | TimescaleDB | Postgres particionado | el rival *es* Postgres, y ese es justamente el punto |
| Búsqueda | OpenSearch | Postgres FTS | fork Apache 2.0 de Elasticsearch; ver a10 |
| Grafos | Neo4j Community | `WITH RECURSIVE` | la familia más discutible, y por eso la mejor para la apuesta que se pierde |
| Vectorial | Qdrant | `pgvector` | la única familia sin equivalente relacional real |
| Columnar ancha | Cassandra | Postgres particionado | la más difícil de modelar bien; necesita todo lo anterior |
| NewSQL | CockroachDB | Postgres de un nodo | la síntesis: por qué existe y qué cuesta |
| Offline-first | CouchDB + PouchDB | — | conflictos y CRDTs; no hay rival relacional honesto |

> ⚠️ **Ninguna versión de esta tabla está verificada todavía.** Las versiones exactas y
> los digests se fijan ejecutando, en la sesión de verificación de laboratorio, y quedan
> escritas en `a02` con su fecha. Hasta entonces, ningún documento del curso publica un
> número de versión.

---

## 9. 🧰 El stack del laboratorio

**TypeScript por defecto, Python donde manda.** La regla que evita que esto degenere en
dos cursos paralelos:

- **El arnés de medida y el generador de datos son TypeScript siempre.** Son el
  instrumento del curso, y un instrumento con dos implementaciones deja de ser un
  instrumento.
- **Python aparece solo donde el ecosistema de la familia vive ahí de verdad:** vectorial
  (embeddings) y analítico embebido (DuckDB). En ninguna otra parte.
- **Cada fase declara en su encabezado con qué se ejecuta.** El lector nunca tiene que
  adivinar qué entorno necesita antes de empezar.
- La sintaxis de ambos entornos se delega a `a06`, con tabla de equivalencias. Las fases
  enlazan; no reexplican.
- **TypeScript se ejecuta nativo en Node 24** (`node script.ts`), sin compilar y sin `tsx`: el
  código del curso usa solo sintaxis "borrable" (sin `enum` ni *parameter properties*), y
  `tsc` queda opcional para comprobar tipos. **Python se gestiona con `uv` y un `uv.lock`**,
  que fija el intérprete y las dependencias transitivas y reproduce el entorno exacto en
  las tres plataformas. Decidido el 29/09/2026.

**Contenedores:** Docker Compose es el camino principal y **cada receta trae su
equivalente Podman al lado**. Sin Kubernetes en ninguna parte del curso, ni como
apéndice, ni como ampliación 🔥.

---

## 10. ✅ Lo que está dentro del alcance

- Levantar diez motores desde contenedor, con digest fijado, en Windows 11 (WSL2), macOS
  arm64 y Linux.
- Modelar el mismo dominio en las diez familias, a la manera de cada una.
- Medir la forma de las consultas y comparar contra Postgres en todas.
- Llevar cada motor a su punto de rotura y documentarlo con su mensaje de error literal.
- El anti-patrón ⚰️ de cada familia, con números antes y después.
- El ⚖️ veredicto honesto de cada familia: cuándo **no** usarla.
- El triaje de migración de una decisión ya tomada y equivocada.
- El capstone políglota: combinar motores y **pagar la factura de tenerlos**.

## 11. 🚫 Lo que está fuera del alcance

- **Operación en producción:** clústeres reales, backup y restore serios, alta
  disponibilidad, tuning de kernel, seguridad y hardening. Se nombran cuando explican una
  decisión de modelado, nunca como tema.
- **Kubernetes y orquestación.** Ni aquí ni en los apéndices.
- **Pedagogía de Docker.** Los apéndices dan la receta; el curso que explica el mecanismo
  es `docker-container-legacy/` y se nombra sin enlace (D-03).
- **Servicios gestionados de nube** (Atlas, DynamoDB, Bigtable, Pinecone y compañía). Se
  mencionan como alternativa comercial en el veredicto de su familia, y no se levantan.
- **Comparativas de producto dentro de la misma familia.** El curso enseña modelos de
  acceso: MongoDB contra Couchbase no es materia de aquí, es materia del curso profundo.
- **Modelado de datos relacional.** Se da por sabido.
- **Entrenar modelos de embeddings.** En vectorial se usa un modelo pequeño y fijado, y se
  explica qué hace; entrenarlo es otro curso.

---

## 12. ⚖️ Decisiones cerradas

Cerradas quiere decir cerradas: si una sesión futura quiere cambiar una, primero la
cambia aquí y después en todo lo demás, nunca al revés.

1. **Nombre y carpeta:** Ruta NoSQL Lite, en `ruta-no-sql-lite/`. En texto visible siempre
   "Lite", nunca "light" ni "ruta corta".
2. **Idioma:** español latinoamericano neutro con tuteo. Código, comandos, nombres de
   archivo, identificadores y salida de terminal en inglés; comentarios de código en
   español con tildes.
3. **Dominio único: Cóndor MRO** (§7), la empresa de
   [`00-historia-de-condor.md`](../00-historia-de-condor.md), con diez entidades fijas,
   tres volúmenes fijos y semilla determinista. Las otras candidatas quedan registradas en
   [`propuestas-historias.md`](propuestas-historias.md), y cinco de ellas aportan los
   miniproyectos de familia (§13).
4. **Postgres montado en todos los minicursos** como línea base (§8).
5. **Se mide la forma, no la velocidad** (§6), con una apuesta falsable y un punto de
   rotura por familia.
6. **Nada se publica sin haberse ejecutado.** Ningún número, ninguna versión, ninguna
   salida de terminal inventada. Lo que no se verificó se declara con esas palabras.
7. **Imágenes fijadas por digest**, no por tag, con fecha de verificación visible.
8. **Estructura:** 26 fases en seis bloques, dos fases por familia —*levantar y modelar* y
   *romper, medir y decidir*—. El detalle está en
   [`propuesta-fases-y-alcance.md`](propuesta-fases-y-alcance.md).
9. **Ejercicios: 20–30 por fase**, la banda del repositorio, calibrada fase por fase.
10. **Apéndices transversales al curso y no por minicurso**, diez en total, de receta y no
    de pedagogía. Ver [`propuesta-apendices-y-alcance.md`](propuesta-apendices-y-alcance.md).
11. **Boss global acumulativo "El Hangar"**, cinco 💀 boss de bloque —uno por cada bloque
    del I al V; el Bloque 0 no lleva— y un 🧰 miniproyecto por familia (§13).
12. **Stack mixto TypeScript/Python** con la regla de §9.
13. **Duración objetivo: 252 h ≈ 21 semanas a 12 h semanales**, unos cinco meses. A 10 h
    semanales son seis.
14. **Orden de publicación distinto del orden de aprendizaje.** Documental abre por los
    dos criterios; **vectorial se publica en tercer lugar**, fuera de su sitio pedagógico,
    por arrastre de RAG y por su conexión con `tutorial-rag/`. El README declara los dos
    órdenes y el curso puede permitírselo porque los minicursos son independientes — salvo
    el boss global, que por eso es opcional.
15. **`a01`, `a02`, `a05` y `a06` se escriben antes de la primera fase**; sin ellos no hay
    laboratorio. `a03`, `a04`, `a08` y `a09` crecen con el curso. `a07` y `a10` se
    escriben cuando toca su familia.
16. **Columnar ancha se hace con Cassandra, y con el heap fijado.** Se midió el 29/09/2026
    en macOS arm64, en reposo y con un nodo. **Cassandra con `MAX_HEAP_SIZE=512M`: 1,04 GiB
    y 60 s hasta aceptar CQL; con la configuración por defecto, 4,63 GiB**, porque calcula
    el heap a partir de la RAM de la máquina. **ScyllaDB: entre 90 y 420 MiB y 6 s.**
    Con el heap fijado, las dos caben en el presupuesto, así que la RAM dejó de
    discriminar y **decidió la licencia**: desde la 2025.1, ScyllaDB es *source-available*
    y su última versión AGPL está congelada, que es el mismo motivo por el que el curso usa
    Valkey y OpenSearch. Consecuencias: el `compose.yaml` fija el heap **obligatoriamente**
    (`a02`), ScyllaDB aparece en `a10` como caso de licencia y en el veredicto de F18 como
    alternativa. Linux se mide en la sesión de laboratorio; WSL2, al trabajar el curso.
17. **El cliente de Valkey en TypeScript es `iovalkey`**, el fork de ioredis que mantiene
    valkey-io: MIT, JS puro y sin binario nativo que pueda fallar en alguna de las tres
    plataformas. Además tiene la API que el lector ya conoce. Se descartaron `ioredis`,
    que ahora mantiene Redis Inc. y sería incoherente con haber elegido Valkey por licencia,
    y `@valkey/valkey-glide`, el cliente oficial, por su núcleo nativo y su API distinta.
    Está en versión 0.x, y eso se declara en `a06`.
18. **El modelo de embeddings es `intfloat/multilingual-e5-small`**: MIT, multilingüe, 384
    dimensiones, **fijado por revisión** en `a06` y nunca entrenado. Se eligió porque trae
    su ONNX en el mismo repositorio, de modo que la ingesta en Python y la consulta en
    TypeScript (con `transformers.js`) cargan los mismos pesos. Exige los prefijos
    `query:` y `passage:`, y **si olvidarlos cuesta recall es una apuesta de F15, no un
    hecho**: en la sesión de laboratorio, con cinco reportes, el orden no cambió. La paridad
    se verificó el 29/09/2026: Python y TypeScript dan el mismo vector, con una diferencia
    máxima de 1,5 × 10⁻⁷ (`verificacion-de-laboratorio/hallazgos.md` §H8).
19. **NewSQL en varias regiones con `cockroach demo --global`, sin licencia.** F21 modela
    sobre un nodo (`start-single-node`, en el compose). F22 y el boss del Bloque IV miden
    sobre `cockroach demo --nodes=9 --global`: nueve nodos en tres regiones con latencia
    inyectada, **exento de licencia y de telemetría**. Medido el 29/09/2026: fila local a
    67–69 ms y remota a 133–134 ms, con 1,71 GiB (§H10). Se descartó el clúster con
    licencia *Enterprise Free*, porque obliga a cada lector a registrarse, a aceptar
    telemetría y a renovar la clave cada año, y sin ella queda limitado a 5 transacciones a
    los 7 días (§H5). El precio se declara: datos en memoria que se recargan en cada sesión,
    y latencia simulada, no una red real.
20. **TimescaleDB con la imagen TSL, declarada.** Los roll-ups continuos y la compresión, que
    son el núcleo de F09, están bajo Timescale License (*source-available*) y no vienen en
    la imagen `-oss` (§H4). Se aceptan con la licencia escrita en `a10` y en el veredicto de
    F10, donde además **es parte del argumento**: el particionado declarativo de Postgres
    no tiene esa restricción. Es la única excepción al criterio de licencias con el que se
    eligieron Valkey y OpenSearch y se descartó ScyllaDB, y la diferencia se dice: en
    ScyllaDB había una alternativa libre que no perdía contenido; aquí no la hay.

**Excepciones declaradas al `CLAUDE.md` del repositorio**, con su porqué, tal como exige
el propio `CLAUDE.md`:

- **Los apéndices son transversales al curso, no por minicurso.** Diez apéndices para
  veintiséis fases, ninguno perteneciente a una familia concreta. Motivo: el laboratorio,
  el dominio y el arnés son compartidos por definición; un apéndice por familia
  significaría escribir diez veces la misma receta.
- **`BENCHMARKS.md` se sustituye por `bitacora-de-medicion.md`.** El motivo es de fondo y
  no de forma: este curso mide la forma y no la velocidad (§6), así que un archivo de
  latencias sería exactamente el artefacto que envejece mal. Lo que se versiona son
  viajes, documentos examinados, fan-out y amplificación, con su fecha y su digest.
- **`INSTINTOS.md` se mantiene y es central**, no accesorio: es donde se acumulan los 🪞
  de las diez familias.

La lista completa, con las que se agregaron al revisar el curso contra los lineamientos, está en
la guía §16.

### 12.1 Las decisiones de la plantilla general, D-01–D-13 (06/10/2026)

Los lineamientos de producción del repositorio (`zz-instrucciones/`) piden que todo curso cierre
trece decisiones con nombre fijo. Este curso ya había cerrado casi todas con su propia numeración;
esta tabla dice cuál es cuál, y las que faltaban las cerró Oskar el 06/10/2026. **La numeración
1–20 se conserva**, porque la citan la guía, las propuestas, los prompts y los hallazgos.

| ID | Decisión | Valor en este curso | Equivale a | Estado |
|---|---|---|---|---|
| D-01 | Idioma | Español latinoamericano neutro con tuteo; código, comandos, nombres de archivo e identificadores en inglés; **comentarios de código en español con tildes** | 2 | ✅ |
| D-02 | Tipo de curso | Curso completo, con boss de bloque, boss global y miniproyectos de otras empresas | 8, 11 | ✅ |
| D-03 | Autocontención | **Editorial, sin enlaces**: otros cursos del repositorio solo se nombran en prosa, como lectura sugerida y nunca como requisito; ningún enlace sale de la carpeta del curso, y nada publicado cita `prompts/` | §15 🔄 | ✅ 06/10/2026 |
| D-04 | Promesa de esfuerzo | Horas por fase (252 h en total), sin peso ligera/media/densa | 13 | ✅ |
| D-05 | Aparato de evaluación | 20–30 ejercicios por fase (12 en F00 y F02), con criterio `**Objetivo:**` o `**Pregunta:**` y **sin solución publicada**; los boss y los miniproyectos, con criterios de aceptación | 9 | ✅ (sin solución: por defecto, a revisar por Oskar) |
| D-06 | Plataformas | macOS, Linux y Windows 11 con WSL2; el autor verificó en macOS arm64 (T10); Linux y WSL2 quedan declarados sin verificar hasta la pasada en los equipos de Oskar | 16, `a01` | ✅ |
| D-07 | Política de versiones | Imágenes fijadas por digest con fecha de verificación, en `a02`; no se persiguen versiones nuevas salvo por un fallo (Mongo 8.0.20) | 7 | ✅ |
| D-08 | Ejecución | Nada se publica sin haberse ejecutado; lo no verificado se declara con esas palabras | 6 | ✅ |
| D-09 | Código | `src/` con una carpeta por fase o apéndice que deja código, con el nombre exacto del documento, más `src/lab/` para lo compartido (compose, generador, arnés) | — | ✅ |
| D-10 | README y temario | El README y `0-ESTRUCTURA-CURSO.md` se actualizan una sola vez, en la Tanda 7, cuando todo el contenido exista (ajuste del 30/09/2026) | — | ✅ |
| D-11 | Historia | Con historia: Cóndor MRO, en `00-historia-de-condor.md`; los miniproyectos traen cinco empresas más, sin historia larga | 3 | ✅ |
| D-12 | Diagramas | **Mermaid obligatorio** para todo diagrama estructural o conceptual; salidas, árboles de claves o de archivos y fichas de cierre siguen en `text` (guía §18.1) | — | ✅ 06/10/2026 |
| D-13 | Publicación | Repositorio público propio, con la carpeta del curso sin `prompts/`; ningún enlace a otro curso que convertir | — | ✅ 06/10/2026 |

---

## 13. 🏆 Los proyectos boss

- 🏆 **"El Hangar" — el boss global.** El sistema que Cóndor aprobó en marzo de 2026: saber
  dónde está cada pieza, de dónde vino y qué sostiene su trazabilidad. Crece con el curso,
  y cada bloque le añade un motor y una capacidad. **Opcional y fuera de las 252 h**,
  porque es la única parte del curso que se consume en el orden canónico. Es el mejor
  portafolio que deja la ruta.
- 💀 **El boss de bloque.** Un encargo interno de Cóndor que solo se resuelve cruzando las
  familias de ese bloque. Lo pide alguien de la empresa, tiene una consecuencia si sale mal
  y empieza con un sistema roto o un encargo completo. **No es un ejercicio 🔴 con mejor
  nombre**: si cabe en tres líneas, no era un boss.
- 🧰 **El miniproyecto de familia.** Uno por familia, diez en total, y **ninguno es de
  Cóndor**: cada uno viene de otra empresa, con otro dolor, y existe para demostrar que lo
  aprendido es un modelo de acceso y no un truco del dominio. **Opcional, fuera de las 252
  h, de 4 a 6 h cada uno, y se anuncia al abrir la fase B.** Se construye y se razona, pero
  **no entra a la bitácora de medición**: todo lo que se mide se mide sobre Cóndor. El
  índice y el criterio están en
  [`miniproyectos.md`](../miniproyectos.md).
- ⚖️ **El capstone políglota (Bloque V) no es ninguno de los dos.** Es contenido normal del
  curso, con sus fases y sus ejercicios, y es la conclusión que la ruta lleva prometiendo
  cinco meses: añadir un motor al lado **y pagar la factura de tenerlo**.
  Su boss de bloque es otra cosa y va aparte: el capstone diseña añadiendo motores, y el
  boss del Bloque V —*"Las dos verdades"*— empieza con dos sistemas ya divergidos y puede
  terminar **retirando** uno.

---

## 14. 🎯 Criterios de éxito

El curso está bien si:

- **Cada fase B cierra con un número medido que sorprendió a quien la escribió.** Si cierra
  con *"la documentación dice que"*, se reescribe. Es el criterio que decide si esto vale
  algo.
- **Al menos una apuesta falsable se pierde en público**, y se cuenta entera. La candidata
  natural es grafos contra `WITH RECURSIVE`, donde Postgres aguanta mucho más de lo que el
  instinto dice.
- **Un lector que solo hace el Bloque I** —documental y clave-valor— sale con criterio
  utilizable, no con medio curso.
- **Ninguna afirmación comparativa del curso se sostiene sin su medición al lado**, y toda
  medición dice en qué máquina, con qué versión y con qué digest se hizo.
- **El catálogo de errores llega a cincuenta entradas con mensaje literal.** Ese catálogo,
  y no las lecciones, es lo que alguien encuentra un martes por la tarde cuando pega su
  error en un buscador.

---

## 15. 🗺️ Relación con el resto del repositorio

- **`ruta-no-sql/`** es la especificación de los cursos profundos: once carpetas con
  alcance, guía de estilo, prompts y semilla, unas 150.000 palabras de diseño y cero de
  contenido. Este curso **la consume como fuente** —dominio, rivales, anti-patrones,
  veredictos— y **no la modifica**. Cada minicurso de la Lite es el tráiler de su curso
  profundo, y la audiencia de la Lite dirá qué familia merece las 200.000 palabras.
- **`docker-container-legacy/`** (*Docker Legacy Node*) es la infraestructura de laboratorio.
  Aquí se dan recetas; el mecanismo se explica allí, y el curso lo **nombra en prosa** como
  lectura sugerida, sin enlazarlo (D-03, §12.1).
- **`tutorial-rag/`** (*Tutorial RAG*) conecta con el minicurso vectorial, y es parte del
  argumento para publicarlo tercero. También se nombra sin enlace.
- **Los cursos de Angular, React y Vue legacy** aportan el andamiaje editorial que este
  curso imita: guía de estilo, plantillas de capítulo, propuesta de fases y apéndices, y
  prompts por documento.
