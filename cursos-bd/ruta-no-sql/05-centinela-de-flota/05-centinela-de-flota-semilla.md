# 🏛️ Proyecto Centinela de Flota — Semilla del curso (Wide-column / columnar ancha)

## 🎯 Motivación

Hay una clase de sistema que no falla por lógica: falla por caudal. La ingesta
de telemetría —millones de dispositivos que emiten una lectura cada pocos
segundos, para siempre, sin pausa— es el caso donde el cuello de botella no es
"¿cómo modelo esta entidad?" sino "¿cuántas escrituras por segundo aguanta el
nodo antes de convertirse en el punto único de falla de todo el negocio?". El
modelo de acceso **wide-column** existe para ese régimen: escritura masiva,
distribuida entre muchos nodos sin coordinador central, donde la unidad de
diseño no es la entidad normalizada sino **la consulta que la aplicación va a
hacer**.

Un motor relacional *puede* ingerir telemetría —nadie lo discute— pero no fue
diseñado para hacerlo bien más allá de cierta escala. Su arquitectura asume un
nodo autoritativo que arbitra cada transacción en el momento en que ocurre; esa
garantía, que es su mayor virtud en un dominio contable, se vuelve su límite
físico cuando el problema es "aceptar dos millones de writes por segundo repartidos
entre trece centros de datos, con disponibilidad garantizada por encima de
consistencia inmediata". A esa escala, un `JOIN` en tiempo de lectura sobre datos
esparcidos en cientos de nodos deja de ser una operación cara para volverse
sencillamente inviable. El modelo relacional normaliza primero y optimiza después;
el modelo wide-column desnormaliza por diseño desde el primer día, guiado
exclusivamente por las preguntas que la aplicación anticipó.

La trampa mental —y el eje pedagógico de este curso— es que esa desnormalización
por diseño **se siente como un pecado** para quien lleva una década normalizando.
Duplicar datos entre tablas, no tener JOINs, no poder consultar ad-hoc lo que no
previste: cada una de esas restricciones viola un instinto relacional bien
entrenado. El curso no te pide que renuncies a ese instinto; te pide que lo
recalibres para el único régimen donde no aplica: cuando el volumen de escritura
convierte la coordinación central en el enemigo.

¿Qué gana un ingeniero senior de bases relacionales al dominar este modelo?
Primero, la capacidad de abordar proyectos que antes tenía que rechazar o
sub-especificar: plataformas de IoT, sistemas de mensajería a escala de miles de
millones de eventos diarios, telemetría multi-región con SLA de disponibilidad.
Segundo, y más valioso, deja de cometer el error de arquitectura inverso —forzar
un motor relacional a un régimen de escritura para el que nunca fue pensado,
descubriéndolo recién cuando la base ya está en producción y el `INSERT` empieza
a tardar. Y tercero, suma a su criterio la herramienta correcta *con su factura
visible*: aprende que "diseñar por consulta" no es magia, es un intercambio
explícito de flexibilidad de lectura por rendimiento de escritura predecible, y
aprende a medir ese intercambio antes de firmarlo.

---

## 🏗️ El dominio: telemetría de una flota IoT con roll-ups progresivos

Centinela de Flota ingiere telemetría de una **flota de dispositivos** —piensa en
vehículos, sensores industriales, medidores, o cualquier parque de aparatos
conectados que reportan su estado sin descanso. Cada dispositivo emite una
**lectura** (`reading`) cada pocos segundos: posición, temperatura, voltaje,
estado del motor, nivel de combustible, códigos de error. El sistema debe (a)
aceptar ese torrente sin perder escrituras ni volverse el cuello de botella, y
(b) responder consultas de tendencia —"¿cómo evolucionó la temperatura del
dispositivo `dev-8842` en las últimas 24 horas?", "¿qué dispositivos de la
región norte superaron el umbral de voltaje esta semana?"— sin tener que recorrer
los datos crudos cada vez.

La segunda parte es la que da nombre al proyecto: **roll-ups progresivos**. Los
datos crudos llegan a resolución de segundos, pero nadie consulta un año de datos
crudos. Se pre-agregan en cascada —por minuto, por hora, por día— de modo que una
consulta de tendencia larga golpee una tabla de resolución gruesa (barata de leer)
en vez de la tabla cruda (cara de recorrer). Cada nivel de roll-up es **su propia
tabla, modelada para su propia consulta**. Ese es el patrón wide-column en estado
puro: no una tabla de `readings` normalizada de la que se derivan vistas, sino una
familia de tablas —cruda, por-minuto, por-hora, por-día— cada una diseñada desde
la pregunta que sirve.

### Las entidades del dominio

| Entidad (español, narrativa) | Código (inglés) | Rol |
|---|---|---|
| dispositivo | `device` | el aparato que emite telemetría; tiene región, tipo, metadatos |
| lectura | `reading` | una muestra cruda: `(deviceId, timestamp, metrics…)` |
| métrica | `metric` | un valor medido dentro de una lectura (`temperature`, `voltage`, `fuelLevel`) |
| flota | `fleet` | agrupación lógica de dispositivos (por región, por cliente, por tipo) |
| roll-up | `rollup` | agregación pre-computada a una resolución (`perMinute`, `perHour`, `perDay`) |
| umbral / alerta | `threshold` / `alert` | regla de negocio que dispara cuando una métrica cruza un límite |

Los nombres de columna, tabla, keyspace y campo van en **inglés**
(`readings_by_device`, `deviceId`, `bucketStart`, `avgTemperature`); la narrativa,
los comentarios de código y cualquier texto que vería un operador humano van en
**español**. Esta regla se detalla en la guía de estilo del curso y no es
negociable ni siquiera en el modelado del villano.

### Por qué este dominio EXHIBE el patrón wide-column de forma natural

No hay que forzar nada. La telemetría de flota tiene, de fábrica, las tres
propiedades que el modelo wide-column premia:

Primero, **la escritura domina abrumadoramente sobre la actualización**. Una
lectura, una vez tomada, es inmutable: nadie corrige la temperatura que un sensor
reportó a las 14:03:07. Es append puro, el patrón que este modelo trata como caso
central y no como excepción.

Segundo, **las consultas son predecibles y se conocen de antemano**. No hay
analista lanzando `SELECT` ad-hoc creativos: hay un puñado de patrones de acceso
fijos ("dame las lecturas de este dispositivo en este rango", "dame el roll-up
horario de esta región"). Eso permite —exige— diseñar una tabla por patrón, que
es exactamente la filosofía del modelo.

Tercero, **el volumen hace inviable la coordinación central**. A flota completa,
el caudal de escritura desborda lo que un nodo relacional autoritativo puede
arbitrar. La distribución sin coordinador no es un lujo: es el requisito.

### El marco de 5 preguntas, aplicado ANTES de modelar

| Pregunta | Veredicto para Centinela de Flota |
|---|---|
| ¿Qué se lee junto? | las lecturas de **un** dispositivo (o una partición) en **un** rango de tiempo — nunca "todas las lecturas de todos" |
| ¿Quién custodia la forma / las invariantes? | la forma es rígida y conocida por adelantado; no hay heterogeneidad — lo que varía es el **patrón de consulta**, no el esquema |
| ¿Cuánto se une en caliente? | **cero**: no hay JOINs; cada consulta golpea una sola tabla diseñada para ella, con la duplicación ya pagada en escritura |
| ¿Dónde viven las invariantes? | fuera del motor: no hay integridad referencial multi-tabla; la consistencia es eventual y el diseño la asume |
| ¿Qué pide la operación? | **escritura masiva** (el eje), lectura por rango de partición, latencia predecible, evolución de esquema mínima, disponibilidad > consistencia inmediata |

**Veredicto: vota wide-column 5-0** — *pero solo en el régimen de alto volumen*.
Y ese matiz es la mitad del curso: el mismo dominio, con **cien** dispositivos en
vez de un millón, vota relacional sin dudar. Wide-column no gana "la telemetría":
gana "la telemetría a una escala que un solo nodo no absorbe". La honestidad de
medir dónde está exactamente esa frontera —no asumirla— es la columna vertebral de
Centinela de Flota.

### ⚰️ El villano del curso: Cassandra para un CRUD que no la necesita

El anti-patrón que este curso disecciona con autopsia medida es **usar un motor
wide-column donde el volumen no lo justifica**: montar Cassandra (o ScyllaDB) para
un catálogo de dispositivos de bajo caudal, un panel de administración con
diez mil filas, o un CRUD interno con relaciones de verdad. El síntoma es siempre
el mismo: alguien leyó que "Cassandra escala" y la eligió como base primaria de un
sistema que jamás verá la escala que la justifica —y ahora paga el precio de un
modelo que renuncia a los JOINs, a las transacciones multi-fila, a la consulta
ad-hoc y a la integridad referencial, sin recibir a cambio el único beneficio que
compensaría esas renuncias: escritura distribuida masiva que ningún nodo único
podría absorber.

Es el crimen simétrico al de forzar relacional donde el volumen desborda: mismo
personaje —el que elige el motor por moda y no por patrón de acceso—, dirección
opuesta. El curso lo reproduce en vivo (un CRUD real montado sobre Cassandra),
mide el dolor (latencia de lectura ad-hoc, imposibilidad de un `JOIN` trivial,
sobre-provisión operativa para un caudal ridículo), y lo migra a Postgres con
números antes/después. La lección transferible no es "Cassandra es mala": es
"Cassandra sin el volumen que la justifica es todo costo y ningún beneficio".

---

## 📐 Stack (2026, estable y moderno)

> ⚠️ **Verifica las versiones antes de fijar la Fase 0.** Las de abajo reflejan lo
> último estable comprobado a mediados de 2026; para cuando redactes cada fase,
> reconfirma en la web —los motores publican patches y a veces majors nuevos.

| Componente | Versión / elección | Rol |
|---|---|---|
| **Apache Cassandra** | **5.0.x** (última 5.0.8, abr 2026) | motor wide-column principal del curso |
| **ScyllaDB** | **2026.1 LTS** (última patch 2026.1.9) | rival directo: reimplementación en C++, protocolo compatible con Cassandra |
| **Bigtable** | referencia **conceptual** (no operado) | representante del modelo gestionado en la nube; se estudia el diseño, no se levanta |
| **PostgreSQL** | **17.x** | control relacional bajo la misma carga; también el destino de la autopsia del villano |
| **Node.js** | **24 LTS** ("Krypton") | runtime del arnés, el generador de datos y la API de consulta |
| **TypeScript** | **5.x** (última estable) | tipado en todo el código del curso |
| **Driver Cassandra/Scylla** | `cassandra-driver` (Node, DataStax) última | acceso a ambos motores (protocolo CQL compartido) |
| **Driver Postgres** | `pg` (node-postgres) última | acceso al control relacional |
| **Docker / Podman** | última | todo contenerizado; clúster multi-nodo local vía Compose |
| **Zod** | última | validación de la lectura entrante en la frontera de la API |

### Por qué Cassandra como motor principal

Cassandra es la referencia histórica y más extendida del modelo wide-column: es
donde nació la disciplina de "diseña una tabla por consulta", donde CQL (su
lenguaje, deliberadamente parecido a SQL en sintaxis para engañar al recién
llegado) fuerza al estudiante a chocar contra las diferencias reales, y donde la
comunidad y la documentación de patrones de modelado son más ricas. La versión 5.0
además trae Storage-Attached Indexes (SAI) y búsqueda vectorial, lo que permite
mostrar cómo el modelo evolucionó sin abandonar su núcleo. Enseñar el modelo sobre
Cassandra maximiza el terreno de comparación y la transferibilidad del criterio.

### Por qué ScyllaDB como rival directo

ScyllaDB es la refutación más interesante que existe *dentro* de la familia: mismo
modelo de acceso, mismo protocolo (CQL), misma filosofía de modelado —pero
reescrito en C++ con una arquitectura shard-per-core que promete el mismo trabajo
con mucho menos hardware. Es el "documento vs documento" de este curso, trasladado
a wide-column: no comparamos solo wide-column contra relacional, sino
**wide-column contra wide-column**, para que el estudiante entienda que elegir el
modelo no cierra la decisión —todavía hay que medir la implementación. El arnés
corre la misma carga contra ambos y deja que los números hablen, sin asumir que
"C++ siempre gana".

### Por qué Bigtable como referencia solo conceptual

Bigtable es el ancestro intelectual de todo el modelo (el paper de Google de 2006
que inspiró a Cassandra y HBase) y su encarnación gestionada más pura. Pero
operarlo exige una cuenta cloud con costo real y ata el curso a un proveedor. La
decisión es estudiarlo **como diseño** —su modelo de filas ordenadas, su ausencia
deliberada de secundarios, su tablet splitting— sin levantarlo, para que el
estudiante entienda la genealogía y el trade-off del modelo gestionado (no operas
nada, pero no controlas nada y pagas por acceso) sin quemar presupuesto.

### Por qué PostgreSQL como control relacional

Todo "vs" del curso necesita el ancla relacional: el motor que el estudiante ya
domina, sometido a la misma carga, para que la frontera se vea con números y no con
fe. Postgres 17 es el control honesto —no un enemigo de paja mal configurado— y es
también el destino de la autopsia del villano: cuando Cassandra se usa donde no
toca, la migración correcta es *de vuelta* a Postgres, y el curso la mide.

### Por qué TypeScript + Node 24

El arnés `vs.ts`, el generador de datos de alto caudal y la API de consulta se
escriben en TypeScript sobre Node 24 LTS por tres razones: el `cassandra-driver`
oficial de Node es maduro y comparte protocolo con Scylla (un solo cliente para
ambos motores), el ecosistema es multiplataforma sin fricción (Windows vía WSL,
Linux, macOS), y el tipado ayuda a que el generador de cargas y el arnés de
medición sean código que el estudiante puede leer y auditar. Para la generación de
carga verdaderamente masiva, el curso complementa con `cassandra-stress` /
`nb` (NoSQLBench) —herramientas del ecosistema— cuando el volumen exceda lo que un
proceso Node genera cómodamente; esto se decide y se justifica en la Fase 0.

### Validación y tooling transversal

**Zod** valida la lectura entrante en la frontera de la API (forma, tipos, rangos
plausibles de cada métrica) antes de escribir —el motor wide-column no impone
esquema estricto sobre los valores, así que la validación vive en la aplicación.
El **generador de datos** produce el mismo dataset semántico de telemetría en las
tres formas (tablas Cassandra/Scylla y tablas Postgres) para que el "vs" sea justo.
El arnés `scripts/vs.ts` es el juez único de todo benchmark.

---

## ⚖️ El método del "vs": un arnés, no anécdotas

`scripts/vs.ts` es el corazón metodológico del curso. Ejecuta **la misma consulta
semántica** —"escribe N lecturas", "lee el rango horario del dispositivo X",
"calcula el roll-up diario de la región Y"— contra cada motor en juego, cronometra
con el mismo reloj, corre suficientes repeticiones para que la varianza no engañe,
y **acumula los resultados en `BENCHMARKS.md`**. Ninguna afirmación de "X es mejor
para Y" entra al curso sin haber pasado por el arnés primero. Se rechazan
explícitamente los benchmarks de marketing de cualquiera de los tres motores.

Los duelos que atraviesan el curso:

1. **Cassandra vs PostgreSQL** — wide-column vs relacional, bajo carga de escritura
   creciente. El eje: encontrar el punto donde el nodo relacional deja de absorber
   el caudal y la escritura distribuida empieza a ganar. La frontera se **mide**, no
   se asume.
2. **Cassandra vs ScyllaDB** — wide-column vs wide-column, misma carga, mismo
   protocolo. El eje: ¿cuánto de la promesa de rendimiento de Scylla es real en
   *este* dominio, y a qué costo de madurez/ecosistema?
3. **Diseño correcto vs diseño ingenuo (dentro de Cassandra)** — el "vs" interno más
   valioso: la misma consulta sobre una tabla bien modelada (partición y clustering
   pensados) contra una tabla que arrastra hábitos relacionales (partición
   gigante, `ALLOW FILTERING`). Enseña que el motor no te salva del mal modelado.

---

## 🌳 Estructura de fases

Doce fases. La Fase 0 monta el laboratorio contenerizado, el generador de datos y
`vs.ts`; la Fase 11 es la autopsia del villano y el veredicto honesto. El número
—doce— responde a que el modelo wide-column exige dedicar fases enteras a
conceptos que en otros modelos son un párrafo: el diseño de la partition key, el
clustering, la tabla-por-consulta, la consistencia sintonizable, la compactación.
Cada uno es una fase porque cada uno recalibra un instinto relacional distinto.

| # | Fase | Núcleo | "Vs" de la fase |
|---|---|---|---|
| **0** | 🧪 El laboratorio de tres motores | Compose con clúster Cassandra multi-nodo + ScyllaDB + Postgres. Generador de telemetría que produce el mismo dataset en las tres formas. Nace `scripts/vs.ts` | — (montaje) |
| **1** | ⚖️ El marco, antes de modelar | Las 5 preguntas aplicadas a la telemetría. Se modela la primera tabla "por consulta" y se siente el vértigo de no normalizar | Escritura ingenua Postgres vs Cassandra a bajo volumen (Postgres gana — honestidad desde el día 1) |
| **2** | 🔑 La partition key lo es todo | Diseñar la clave de partición: cómo reparte, qué es una partición caliente, el pecado de la partición ilimitada | Partición bien vs mal diseñada — tamaño y latencia |
| **3** | ⭐ Tabla por consulta: desnormalizar por diseño | Modelar `readings_by_device`, `readings_by_region`; duplicar la escritura a propósito | Un modelo relacional normalizado vs N tablas desnormalizadas — costo de escritura |
| **4** | 📊 Clustering y orden dentro de la partición | Clustering columns, orden físico, lecturas por rango de tiempo eficientes | `ORDER BY` relacional vs orden físico de clustering |
| **5** | ⏱️ Roll-ups progresivos por minuto/hora/día | Pre-agregar en cascada; tabla por resolución; escritura de roll-up en el camino de ingesta | Agregación relacional en tiempo de lectura vs roll-up pre-computado |
| **6** | 🌡️ Ingesta a alto caudal | Batching correcto, escritura asíncrona, contrapresión; **SENTIR** el volumen alto contra Postgres bajo idéntica carga | Cassandra vs Postgres — la curva de escritura donde se cruzan |
| **7** | 🎚️ Consistencia sintonizable | `ONE`/`QUORUM`/`ALL`, el teorema CAP en la práctica, replicación multi-DC | Garantía relacional fija vs consistencia por-consulta |
| **8** | 🧹 Compactación, TTL y retención | Estrategias de compactación, TTL nativo por fila, tombstones y su trampa | Retención artesanal en SQL vs TTL nativo |
| **9** | 🐎 Cassandra vs ScyllaDB, medido | El mismo dominio, la misma carga, contra Scylla; dónde la promesa de C++ se cumple y dónde no | Wide-column vs wide-column con `vs.ts` |
| **10** | 🔍 Los límites: secundarios, SAI y lo que NO deberías consultar | Índices secundarios, SAI, `ALLOW FILTERING` como olor; por qué la consulta ad-hoc sigue sin ser lo tuyo | Consulta ad-hoc en Postgres vs el dolor de forzarla en Cassandra |
| **11** | ⚰️ La autopsia del villano y ⚖️ el veredicto | El CRUD montado sobre Cassandra, medido de punta a punta; migración a Postgres con números; árbol de decisión de cuándo NO usar wide-column | El ritual de cierre — medido, no narrado |

### Fase 0 — El laboratorio de tres motores

Levanta, con Docker/Podman Compose, un **clúster Cassandra de varios nodos**
(no un solo nodo: el punto del modelo es la distribución, y hay que verla),
un nodo ScyllaDB y un Postgres, todos en la misma red local reproducible. Se
escribe el **generador de telemetría**: un proceso que fabrica lecturas
sintéticas realistas (dispositivos con región y tipo, métricas con deriva
temporal creíble, ráfagas y huecos) y las materializa en el esquema de cada
motor. Nace `scripts/vs.ts` con su primer duelo trivial (un `INSERT` y un `SELECT`
por clave en los tres motores) para validar el arnés. No se modela nada serio
aún: se valida que los tres motores respondan y que el arnés cronometre.
Apéndices A/B/E viven aquí.

### Fase 1 — El marco, antes de modelar

Se aplican las 5 preguntas a la telemetría en frío y se escribe el veredicto
(vota wide-column, con el matiz del volumen). Se modela la **primera tabla por
consulta** y aquí cae el primer 🪞 **instinto falsable**: el estudiante,
relacional de médula, querrá una tabla `readings` normalizada con FK a `devices`.
Se le pide predecir qué pasará y se mide: a bajo volumen, **Postgres gana** —y esa
honestidad temprana es deliberada. Wide-column no es un martillo universal.
Primer 📖 diccionario de traducción (tabla → column family, PK → partition key +
clustering).

### Fase 2 — La partition key lo es todo

La decisión de diseño más importante y más ajena al instinto relacional: la
**partition key** no es "la primary key de siempre", es *cómo se reparten
físicamente los datos entre nodos*. Se enseña qué es una partición caliente, por
qué una partición ilimitada (p.ej. particionar solo por `deviceId` de un
dispositivo que emite para siempre) es una bomba de tiempo, y el patrón de
**time-bucketing** para acotarla. 🪞 aquí: "tu instinto dice que la PK identifica
la fila; en realidad decide en qué nodo vive". Se mide partición sana vs enferma.

### Fase 3 — Tabla por consulta: desnormalizar por diseño

La fase ⭐ central. Se modelan varias tablas para el mismo dato
(`readings_by_device`, `readings_by_region`, `readings_by_metric_threshold`),
aceptando escribir la misma lectura en todas. Aquí el instinto relacional grita
"¡esto es redundancia, es un pecado!" y el curso responde: a esta escala, la
redundancia en escritura es el precio correcto por lecturas sin JOIN. 🩻 **"esto sí
viaja igual"**: la selectividad, el pensar en el patrón de acceso, la importancia
del índice —siguen valiendo; lo que cambia es que ahora el "índice" es una tabla
entera. Se mide el costo de escritura de N tablas contra el modelo normalizado.

### Fase 4 — Clustering y orden dentro de la partición

Dentro de una partición, las **clustering columns** definen el orden físico de las
filas, lo que hace que "dame las últimas 24h de este dispositivo" sea un escaneo
secuencial barato en vez de un sort. Se contrasta con el `ORDER BY` relacional
(que ordena en tiempo de consulta) frente al orden físico ya materializado. 📖 se
extiende el diccionario con clustering, `WITH CLUSTERING ORDER BY`.

### Fase 5 — Roll-ups progresivos por minuto/hora/día

El corazón del proyecto Centinela. Se construyen las tablas de roll-up
(`rollup_per_minute`, `rollup_per_hour`, `rollup_per_day`) y la lógica que las
alimenta en el camino de ingesta —cada lectura cruda actualiza también sus
agregados. Se discute el trade-off contra calcular la agregación en tiempo de
lectura (barato de escribir, caro de leer) vs pre-agregar (caro de escribir,
barato de leer). Se mide una consulta de tendencia larga contra ambos enfoques.

### Fase 6 — Ingesta a alto caudal

La fase donde el estudiante **siente** el modelo. Se sube el generador a un caudal
deliberadamente agresivo y se corre la misma carga contra Cassandra y contra
Postgres, graficando la curva de latencia de escritura de ambos a medida que sube
el volumen. Aquí se ve, con números propios, el punto donde el nodo relacional
empieza a ahogarse y la escritura distribuida sostiene el ritmo. Se enseña el
batching correcto (y por qué el `BATCH` de CQL **no** es el batch relacional que
crees), escritura asíncrona y contrapresión. Duelo estrella Cassandra vs Postgres.

### Fase 7 — Consistencia sintonizable

El CAP en la práctica. Se explica cómo cada consulta elige su nivel de consistencia
(`ONE`, `QUORUM`, `ALL`) y qué se gana/pierde, y cómo la replicación multi-DC
cambia el cálculo. 🪞: "tu instinto asume consistencia fuerte gratis en cada
lectura; aquí la consistencia es una perilla que tú giras por consulta, con costo
de latencia". Se mide latencia vs nivel de consistencia.

### Fase 8 — Compactación, TTL y retención

Cómo Cassandra materializa físicamente los datos (SSTables, compactación) y por qué
importa para el rendimiento. El **TTL nativo por fila** —que expira la telemetría
vieja sin un job de borrado artesanal— y su lado oscuro: los **tombstones** y cómo
una mala estrategia de borrado envenena las lecturas. 🩻: la idea de retención
escalonada existía en SQL, pero aquí es primitiva. Se mide el impacto de tombstones.

### Fase 9 — Cassandra vs ScyllaDB, medido

Se traslada todo el dominio a ScyllaDB (protocolo compartido: el mismo código de
cliente sirve) y se corre la carga completa del curso contra ambos. Se documenta
dónde la arquitectura shard-per-core de Scylla se traduce en ventaja real en *este*
dominio y dónde el ecosistema/madurez de Cassandra pesa. Todo con `vs.ts`; ninguna
afirmación sin número.

### Fase 10 — Los límites: secundarios, SAI y lo que NO deberías consultar

Los índices secundarios y los Storage-Attached Indexes (SAI) de 5.0 existen, pero
usarlos como muleta para recuperar la consulta ad-hoc relacional es un olor. Se
enseña `ALLOW FILTERING` como la señal de alarma que es, cuándo un secundario está
justificado y cuándo delata que modelaste mal. 🪞 final: "tu instinto quiere
`WHERE` sobre cualquier columna; el modelo te da eso solo si aceptas escanear —y
escanear es lo que viniste a evitar".

### Fase 11 — La autopsia del villano y el veredicto

El ritual de cierre. Se monta el CRUD real sobre Cassandra —un catálogo de
dispositivos de bajo volumen con relaciones de verdad, exactamente el caso donde el
motor no toca— y se mide de punta a punta: la latencia de la lectura ad-hoc, la
gimnasia para simular un JOIN, la sobre-provisión operativa para un caudal
ridículo. Se migra a Postgres y se ponen los números antes/después lado a lado.
Se cierra con el ⚖️ **árbol de decisión honesto**: cuándo NO usar wide-column
(bajo volumen, relaciones ricas, consulta ad-hoc, necesidad de transacciones
multi-fila), y cuándo SÍ (caudal que desborda un nodo, patrones de consulta fijos y
conocidos, disponibilidad sobre consistencia inmediata).

### Apéndice A — Arranque de motores vía contenedores

Comandos y notas para levantar el clúster Cassandra multi-nodo, el nodo Scylla y
Postgres con Compose; cómo verificar que el clúster formó anillo (`nodetool
status`), cómo conectarse con `cqlsh`, y las trampas de recursos (Cassandra pide
memoria; un clúster de tres nodos en una laptop necesita ajustes de heap).

### Apéndice B — `docker-compose` / `Containerfile` de trabajo

El Compose completo y comentado del laboratorio, con las variables de entorno de
cada motor, los volúmenes de datos y la red compartida.

### Apéndice C — Guía rápida de CQL para quien viene de SQL

Referencia de salto rápido: qué se parece a SQL (y te traiciona por parecerse) y
qué no existe (JOIN, subqueries, `GROUP BY` arbitrario, transacciones multi-fila).
Tabla CQL ↔ SQL.

### Apéndice D — El generador de telemetría

Diseño del generador de datos: cómo produce deriva temporal creíble, ráfagas,
huecos y distribución por región/tipo; cómo materializa el mismo dataset semántico
en los tres motores; y cómo se escala su caudal para las fases de alto volumen
(incluyendo cuándo delegar en `cassandra-stress` / NoSQLBench).

### Apéndice E — Troubleshooting de setup

Los errores típicos: el clúster que no forma anillo, el nodo que se queda en
`JOINING`, el OOM por heap mal dimensionado, el driver que no encuentra el
contact point, la diferencia de puertos entre Cassandra y Scylla.

---

## 📓 Artefactos acumulativos

**`INSTINTOS.md`** registra cada instinto relacional que el curso pone a prueba,
en formato falsable: la **predicción** del estudiante ("normalizar y hacer JOIN
será más rápido"), el **experimento** (qué midió `vs.ts`), y el **veredicto
escrito** (qué ganó y por qué, con el número). Crece fase a fase: la Fase 1 aporta
"normalizar gana a bajo volumen" (¡verdadero!), la Fase 3 aporta "desnormalizar es
un pecado" (falso en este régimen), la Fase 6 aporta "un solo nodo aguanta
cualquier caudal razonable" (falso pasado el cruce). Al final es el mapa personal
de un instinto recalibrado.

**`BENCHMARKS.md`** acumula todo "vs" medido con `vs.ts`: cada duelo lleva el
dataset, el hardware, el número de repeticiones, la mediana y la dispersión, y una
línea de veredicto. Es el contrapeso empírico de `INSTINTOS.md`: uno registra lo
que creías, el otro lo que midió el reloj. Ninguna afirmación comparativa del curso
existe sin su entrada aquí.

---

## 📚 Referencias por fase (semilla)

> ⚠️ **Todas las URLs, títulos e IDs de video de abajo deben verificarse antes de
> publicar cada fase.** No se inventan números de página, DOIs ni IDs de video. Si
> un enlace apunta a una versión distinta de la fijada en el stack, se advierte.

**Fases 0–2 (setup, marco, partition key)**
- Documentación oficial de Apache Cassandra 5.0: https://cassandra.apache.org/doc/latest/ (verificar).
- Guía de modelado de datos de Cassandra (data modeling) en la doc oficial (verificar sección).
- Documentación de ScyllaDB 2026.1: https://docs.scylladb.com/ (verificar).
- *Cassandra: The Definitive Guide* (Carpenter & Hewitt), 3ª ed. — verificar edición vigente y capítulos de modelado.
- Video de apoyo: charla introductoria de modelado wide-column en YouTube (verificar canal, título e ID — no inventar).
- **Orden de lectura sugerido:** doc oficial "data modeling" → capítulo de modelado del libro → charla introductoria.

**Fases 3–5 (tabla por consulta, clustering, roll-ups)**
- Doc oficial de CQL: creación de tablas, clustering order, tipos (verificar URL).
- Patrones de modelado por consulta (query-first) — doc oficial y/o DataStax Academy (verificar disponibilidad y URL).
- Material sobre time-series y roll-ups en Cassandra/Scylla (verificar fuente).
- **Orden de lectura sugerido:** CQL de tablas → query-first modeling → time-series patterns.

**Fase 6 (alto caudal)**
- Documentación de `cassandra-stress` y/o NoSQLBench (verificar URLs).
- Doc del `cassandra-driver` de Node (escritura asíncrona, batching) (verificar).
- **Orden de lectura sugerido:** driver Node → herramienta de stress → tuning de ingesta.

**Fase 7 (consistencia)**
- Doc oficial de niveles de consistencia y replicación multi-DC (verificar).
- Material de referencia sobre el teorema CAP aplicado (verificar fuente académica; no inventar DOI).
- **Orden de lectura sugerido:** consistency levels → replication strategy → CAP en la práctica.

**Fase 8 (compactación, TTL, tombstones)**
- Doc oficial de estrategias de compactación y TTL (verificar).
- Artículo/charla sobre la trampa de los tombstones (verificar autor y URL).
- **Orden de lectura sugerido:** compaction strategies → TTL → tombstones y sus riesgos.

**Fase 9 (Cassandra vs ScyllaDB)**
- Documentación de arquitectura de ScyllaDB (shard-per-core, seastar) (verificar URL).
- Comparativas oficiales — leer con escepticismo: son de parte interesada; el curso mide con su propio arnés.
- **Orden de lectura sugerido:** arquitectura de Scylla → compatibilidad CQL → medir con `vs.ts`.

**Fase 10 (secundarios, SAI, límites)**
- Doc oficial de Storage-Attached Indexes (SAI) y secondary indexes en 5.0 (verificar).
- Material sobre por qué evitar `ALLOW FILTERING` (verificar fuente).
- **Orden de lectura sugerido:** SAI → secondary indexes → `ALLOW FILTERING` como olor.

**Fase 11 (autopsia y veredicto)**
- Bigtable: paper original de Google (2006) como lectura conceptual de cierre (verificar URL del paper).
- Doc de PostgreSQL 17 para el destino de la migración (verificar).
- **Orden de lectura sugerido:** paper Bigtable → repaso del árbol de decisión propio → doc Postgres de la migración.

---

## 🧪 Nota sobre ejercicios

Cada fase lleva **entre 20 y 40 ejercicios** graduados 🟢🟡🟠🔴, todos anclados al
dominio de la telemetría de flota (dispositivos, lecturas, roll-ups, regiones,
umbrales — nunca ejemplos abstractos). Distribución sugerida para ~30 ejercicios:
~8 🟢 (calientan: escribir una tabla, un `INSERT`, una consulta por clave), ~9 🟡
(modelar una tabla por consulta, diseñar una partition key acotada), ~7 🟠
(diagnosticar una partición caliente, medir un roll-up contra agregación en
lectura), ~4–6 🔴 (reproducir el ahogo de escritura de Postgres bajo el cruce de
caudal, cazar una tormenta de tombstones, cerrar la brecha de un `ALLOW
FILTERING`), más los 🔥 opcionales aparte. **Al menos un puñado por fase son de
diagnóstico**: se entrega un bug —una partición que crece sin límite, una consulta
que exige `ALLOW FILTERING`, un roll-up que cuenta doble— y se pide reproducir y
localizar, no solo construir.

---

## 🧩 Decisiones pendientes de confirmar antes de redactar la Fase 0

- [ ] **Dataset semilla:** ¿telemetría 100% sintética generada (propuesta por
      defecto, por control total del caudal y la forma) o un dataset público de IoT
      adaptado? Propuesta: sintético, para poder subir el caudal a voluntad en la
      Fase 6.
- [ ] **¿ScyllaDB entra desde la Fase 0 o se reserva a la Fase 9?** Propuesta:
      montado desde Fase 0 (comparte protocolo, cuesta poco), pero solo se **mide en
      serio** en la Fase 9. Confirmar impacto en recursos de la laptop.
- [ ] **¿El clúster Cassandra es multi-nodo real o un solo nodo con `num_tokens`
      simulando distribución?** Propuesta: multi-nodo (tres) real, porque el punto
      del modelo es la distribución; con nota de troubleshooting de recursos.
- [ ] **¿La generación de carga masiva de la Fase 6 usa el generador Node propio o
      delega en `cassandra-stress`/NoSQLBench?** Propuesta: generador propio para el
      dataset semántico, herramienta dedicada para el caudal bruto; decidir el
      umbral de cambio.
- [ ] **¿Bigtable se toca aunque sea con free tier o se queda 100% en papel?**
      Propuesta: 100% conceptual, sin cuenta cloud, para no atar el curso a un
      proveedor ni a un costo.
- [ ] **Formato de fase:** ¿se mantiene la plantilla de 9 secciones del esqueleto
      compartido, o se ajusta por ser un curso con fases más técnicas y densas?
      Propuesta: mantener las 9 secciones.
- [ ] **Nombre y granularidad exactos de las métricas del dispositivo** (¿cuántas,
      cuáles, con qué rangos plausibles) — afecta el generador y los umbrales.

---

## 💭 Consideraciones adicionales

### El caudal alto es un requisito pedagógico, no un adorno

El riesgo más grande de este curso es enseñar wide-column a bajo volumen: si el
estudiante nunca ve el punto donde Postgres se ahoga, no entenderá *por qué*
renunció a los JOINs, y saldrá creyendo que Cassandra es "una base rara y
limitada". Por eso el **volumen de escritura simulado en la Fase 6 debe ser
deliberadamente agresivo** —suficiente para que en su propia máquina, con su
propio reloj, vea la curva de latencia relacional despegar mientras la
distribuida sostiene. Ese momento de "ah, *por eso*" es el objetivo pedagógico
central del curso, y todo el diseño (generador escalable, clúster multi-nodo real,
arnés que grafica la curva) existe para producirlo. Si la laptop del estudiante no
llega al caudal necesario, el Apéndice D debe ofrecer una vía (NoSQLBench,
perfiles de recursos, o un caudal calibrado al hardware) para que el cruce sea
visible aunque a menor escala absoluta.

### El costo operativo del modelo, nombrado sin rodeos

Adoptar wide-column es adoptar una superficie operativa pesada: un clúster que
mantener, `nodetool` que aprender, compactación que sintonizar, tombstones que
vigilar, replicación multi-DC que configurar, y una curva de aprendizaje de equipo
que no es trivial. El curso nombra ese costo en cada fase relevante (especialmente
7 y 8) para que la decisión de adoptar el modelo sea arquitectónica y no solo
técnica: el motor que "escala" también es el que más caro sale de operar un martes
a las 3 am. Esa honestidad operativa es lo que separa este curso de un tutorial de
fanboy.

### Los límites de la analogía con SQL

CQL se parece a SQL a propósito, y esa semejanza es una trampa: `SELECT`, `WHERE`,
`INSERT` lucen iguales pero se comportan distinto (no hay JOIN, el `WHERE` solo
funciona sobre la clave sin `ALLOW FILTERING`, el `BATCH` no es transaccional en el
sentido que crees, no hay `GROUP BY` arbitrario). El curso explota esa semejanza
para enganchar y luego la desmonta deliberadamente, porque el mayor peligro para el
lector senior es asumir que sabe CQL porque sabe SQL. El Apéndice C y los recuadros
🪞 existen precisamente para marcar cada punto donde la analogía se rompe.

### Productizabilidad: ⚠️ media, necesita un vertical propio

El criterio que enseña este curso es fuertemente transferible, pero como *producto*
la ingesta de telemetría genérica es difícil de vender: el mercado de observabilidad
e IoT está ocupado por incumbentes fuertes. La validación contra mercado real es,
por tanto, condicional: Centinela de Flota se vuelve productizable cuando se ancla a
un **vertical concreto** con su jerga y sus umbrales (telemetría de flota de
vehículos comerciales, monitoreo de maquinaria industrial pesada, medición
energética distribuida), donde el conocimiento del dominio —no el motor— es el
diferenciador. El curso lo señala como una decisión de negocio a tomar, no como una
promesa de que "monta esto y tienes un SaaS". Esa honestidad sobre el techo
comercial del proyecto es parte del criterio que se enseña: saber cuándo lo que
construiste es infraestructura interna valiosa y cuándo es un producto vendible son
dos juicios distintos.
