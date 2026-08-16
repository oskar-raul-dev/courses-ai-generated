# 🎯 Alcance del proyecto
## Ruta NoSQL Lite — Diez motores, un dominio, cinco preguntas

> **Qué es este documento:** la fuente de verdad de **qué** enseña el curso, a quién y con
> qué límites. Lo que no esté aquí, no está en el curso.
> **Fecha de cierre de esta versión:** 10 de septiembre de 2026
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

## 7. 🚚 El dominio: mantenimiento de flota

Un dominio único para todo el curso, modelado diez veces. **Fijar el dominio y variar solo
el modelo es lo que hace comparables las mediciones**; si cada familia trajera su propio
ejemplo de juguete, no habría curso, habría diez tutoriales en fila.

El sistema: una empresa que mantiene una flota de vehículos industriales. Talleres,
técnicos, repuestos, telemetría a bordo y un historial de averías que nadie ha sabido
explotar.

**Las entidades del dominio, que son las mismas en las diez familias:**

- `vehicle` — la ficha: matrícula, modelo, año, configuración, equipamiento opcional. Dos
  vehículos del mismo modelo no tienen los mismos campos, y ahí empieza todo.
- `part` y `partCatalog` — repuestos, con referencias cruzadas, equivalencias y
  compatibilidades por modelo.
- `assembly` — despiece: qué pieza va dentro de qué conjunto, y qué se arrastra al
  cambiarla. Profundidad variable y desconocida de antemano.
- `workOrder` — la orden de trabajo: qué se hizo, quién, cuándo, con qué piezas y cuánto
  costó. Es la entidad con frontera transaccional de verdad.
- `reading` — telemetría a bordo: una lectura por sensor y por minuto, por vehículo.
  Millones de filas que nunca se actualizan.
- `failureReport` — el parte de avería escrito por el técnico, en prosa, con faltas de
  ortografía y jerga de taller.
- `technician`, `workshop`, `supplier` — el resto del elenco.

**Cómo ilumina cada familia, sin forzar nada:**

| Familia | La parte del dominio que le toca |
|---|---|
| Documental | la ficha de vehículo, polimórfica por modelo y equipamiento |
| Clave-valor | sesiones del terminal del taller, rate limiting, el candado de la orden abierta |
| Analítico embebido | el tablero de costes por modelo, taller y trimestre |
| Series temporales | la telemetría a bordo y sus roll-ups |
| Búsqueda | el catálogo de repuestos con sinónimos, tolerancia a errores y facetas |
| Grafos | el despiece y el *"si cambio esta pieza, ¿qué más cae?"* |
| Vectorial | *"¿qué avería se parece a esta?"* sobre los partes en prosa |
| Columnar ancha | la telemetría cuando ya no cabe en un nodo |
| Offline-first | la app del técnico en un taller sin cobertura |
| NewSQL | el libro de órdenes de trabajo con talleres en tres regiones |

**Tres volúmenes fijos para todo el curso**, generados con semilla determinista para que
la medición sea la misma en tu máquina y en la mía: **10 k** (desarrollo y ejemplos), **1
M** (donde empiezan a notarse las decisiones de modelado) y **el volumen de rotura**, que
cada familia calibra por su cuenta.

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
  es `docker-container-legacy/` y se enlaza.
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
3. **Dominio único:** mantenimiento de flota (§7), con tres volúmenes fijos y semilla
   determinista.
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
11. **Boss global acumulativo "El Taller"** más un 💀 boss por bloque (§13).
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

---

## 13. 🏆 Los proyectos boss

- 🏆 **"El Taller" — el boss global.** Un sistema de mantenimiento de flota que crece con
  el curso: cada bloque le añade un motor y una capacidad. **Opcional y fuera de las 252
  h**, porque es la única parte del curso que se consume en el orden canónico. Es el mejor
  portafolio que deja la ruta.
- 💀 **El boss de bloque.** Un encargo que solo se resuelve cruzando las familias de ese
  bloque, y que empieza con un sistema roto o un encargo completo. **No es un ejercicio 🔴
  con mejor nombre**: si cabe en tres líneas, no era un boss.
- ⚖️ **El capstone políglota (Bloque V) no es ninguno de los dos.** Es contenido normal del
  curso, con sus fases y sus ejercicios, y es la conclusión que la ruta lleva prometiendo
  cinco meses: añadir un motor al lado **y pagar la factura de tenerlo**.

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
- **`docker-container-legacy/`** es la infraestructura de laboratorio. Aquí se dan recetas;
  el mecanismo se explica allí y se enlaza.
- **`tutorial-rag/`** conecta con el minicurso vectorial, y es parte del argumento para
  publicarlo tercero.
- **Los cursos de Angular, React y Vue legacy** aportan el andamiaje editorial que este
  curso imita: guía de estilo, plantillas de capítulo, propuesta de fases y apéndices, y
  prompts por documento.
