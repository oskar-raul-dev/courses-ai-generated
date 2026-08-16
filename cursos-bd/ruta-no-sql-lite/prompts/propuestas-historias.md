# 🎬 Propuestas de historia
## Ruta NoSQL Lite — la empresa ficticia del curso

> **Qué es este documento:** las candidatas a **empresa del curso** —la historia única de la
> que sale todo lo narrativo, al estilo de `00-historia-de-aurea.md` en el curso de Python—
> con sus fortalezas, sus debilidades y lo que cuesta adoptar cada una.
> **Fecha:** 14 de septiembre de 2026
> **Estado:** **decisión abierta.** Ninguna está elegida. Cuando se elija, se escribe
> `00-historia-de-<empresa>.md` en la raíz del curso y **se cierra la decisión 3 de
> [`alcance-del-proyecto.md`](alcance-del-proyecto.md) §12**, que hoy dice "mantenimiento de
> flota" sin historia detrás.
> **Precedencia:** por debajo del alcance y de la
> [guía de estilo](guia-de-estilo-y-convenciones.md). Lo que este documento propone no entra
> en vigor hasta que se refleje en el alcance y en
> [`propuesta-fases-y-alcance.md`](propuesta-fases-y-alcance.md).
>
> 📝 **Relacionado:** [`analisis-modelos-no-sql.md`](analisis-modelos-no-sql.md) defiende por
> qué las diez familias se quedan. Este documento da por hecho ese resultado: **toda historia
> candidata tiene que aguantar las diez**, no nueve.

---

## 1. 🧭 Por qué el curso necesita una historia y no solo un dominio

Hoy el curso tiene **un dominio** —mantenimiento de flota, nueve entidades, tres volúmenes— y
eso ya resuelve el problema técnico: fijar el dominio y variar solo el modelo es lo que hace
comparables las mediciones. Lo que no resuelve es el problema narrativo, y son dos cosas
distintas.

Un dominio te da entidades. Una historia te da **por qué a alguien le importa**. La diferencia
se nota en las tres partes del curso que hoy están escritas en abstracto y se leen como
plantilla:

- **Las cinco autopsias de F00** son hoy anécdotas de terceros: *"elegimos Mongo porque no
  queríamos joins"*. Con una historia, son **el expediente de la casa**: decisiones que esta
  empresa heredó, con nombre de quién las tomó y con la factura que está pagando ahora.
- **Los cinco boss de bloque** son hoy enunciados. Con una historia, son **encargos internos**:
  alguien los pide, alguien los necesita, y hay una consecuencia si salen mal.
- **La situación 3 de cada familia** —elegiste bien la familia y la modelaste como relacional—
  es hoy un anti-patrón genérico. Con una historia, es lo que le pasó a un equipo concreto un
  trimestre concreto.

El modelo a imitar es `00-historia-de-aurea.md`: fundadores con nombre y con desacuerdos, un
producto insignia del que cuelga medio curso, una frontera legal que obliga a decisiones de
diseño reales, gente que sostiene la operación con un Excel, y —esto es lo mejor de esa
historia— **un punto donde el dato se sale del perímetro de la empresa** y ya no lo controlas.

---

## 2. 📐 El criterio: qué tiene que aguantar una historia de este curso

### 2.1 Las cuatro familias difíciles

Seis de las diez salen de casi cualquier empresa. Estas cuatro son las que descartan
candidatas, y son el primer filtro que se le aplica a cualquier idea:

- 🕸️ **Grafos** necesita una **búsqueda de patrón de profundidad desconocida**, no descender
  un árbol. Si la historia solo ofrece una jerarquía —un despiece, un organigrama, un árbol de
  categorías—, el propio curso declara en F14 que eso **no** justifica un grafo, y el minicurso
  se queda sin argumento propio.
- 🏛️ **Columnar ancha** necesita datos que **de verdad no caben en un nodo**. No "muchos
  registros": un régimen de escritura donde la coordinación central deja de ser viable.
- ⚡ **NewSQL** necesita una **frontera transaccional que cruce regiones** por una razón que
  no sea capricho: dos reguladores, dos países, residencia de datos obligatoria.
- 📴 **Offline-first** necesita **gente que trabaja sin cobertura de verdad**, durante horas,
  como parte normal del negocio. No "a veces se cae el wifi".

### 2.2 Las tres piezas estructurales que debe traer cualquiera que se elija

**Una adquisición o una fusión en la historia.** Es lo que convierte las autopsias de F00 en
expediente propio en vez de sermón: dos sistemas, dos verdades, y nadie que sepa cuándo
entraron las inconsistencias. Es el equivalente narrativo de la `PLANES_INTEGRALES.xlsx` de
Patricia en Áurea.

**Un proyecto por bloque y uno global.** Los cinco 💀 dejan de ser ejercicios grandes y pasan
a ser encargos con quién los pide y qué entrega. El 🏆 global —hoy llamado "El Taller"— se
vuelve el sistema que la empresa está construyendo mientras el curso avanza, y su nombre sale
de la historia elegida.

**Un punto donde el dato se sale del perímetro.** Es lo mejor de la historia de Áurea: la fase
2 del tratamiento ocurre en el consultorio de un aliado que no reporta nada, el paciente
desaparece meses y el modelo de datos se sale de la empresa. Toda historia candidata necesita
su equivalente, porque ahí viven **offline-first, la costura del capstone y la mitad de los
veredictos honestos**.

### 2.3 El coste de migración, que no es un detalle

El dominio actual atraviesa los seis documentos de `prompts/` con nueve entidades fijas:
`vehicle`, `part`, `partCatalog`, `assembly`, `workOrder`, `reading`, `failureReport`,
`technician`, `workshop`, `supplier`. La guía de estilo §5 las declara **fijas en todo el
curso**, y `plantillas-de-capitulo.md` las repite en los dos esqueletos.

Una historia que las renombre 1:1 cuesta un `sed` y una revisión. Una que las reemplace cuesta
reescribir el alcance §7, el temario entero y las dos plantillas. **Las dos opciones son
legítimas** —nada de esto está publicado todavía—, pero el coste hay que ponerlo en la mesa
antes de elegir, no después.

---

## 3. 🎭 Las siete candidatas

### 3.1 ✈️ Cóndor MRO — taller de mantenimiento aeronáutico

> Dos mecánicos de línea que en 2014 alquilaron media nave en el hangar 7 y hoy mantienen
> ciento cuarenta aeronaves de ocho operadores regionales en tres países. Uno firma; el otro
> vende. Ninguno de los dos sabe dónde está la pieza que la autoridad acaba de inmovilizar.

| Familia | De dónde sale en esta historia |
|---|---|
| 🍃 Documental | La ficha de aeronave: un turbohélice, un monomotor y un helicóptero no comparten campos, y dos del mismo modelo tampoco, por el equipamiento opcional |
| 🔑 Clave-valor | Reserva de slot de hangar, candado de la orden abierta, sesiones del terminal de plataforma |
| 🦆 Analítico | Coste por hora de vuelo, por modelo y por operador |
| ⏱️ Series | Los datos de vuelo que se descargan al aterrizar |
| 🔍 Búsqueda | El catálogo de partes: números, alternos, equivalencias, y todos tecleados mal |
| 🕸️ Grafos | **Llega una directiva sobre un lote de piezas: ¿en qué aeronaves estuvo instalada alguna vez cada una, y qué se desmontó junto con ellas?** Profundidad y camino desconocidos, y atraviesa el tiempo |
| 🧬 Vectorial | Los reportes de piloto: *"algo suelto en cabina"* → *"algo apretado en cabina"*. Prosa telegráfica con jerga y faltas |
| 🏛️ Columnar | La telemetría cuando son ciento cuarenta aeronaves por miles de parámetros por segundo |
| 📴 Offline | El técnico en plataforma a las tres de la mañana, sin señal dentro del fuselaje |
| ⚡ NewSQL | Tres autoridades aeronáuticas, tres países, y cada una exige que sus registros no salgan del suyo |

**Entidades:** `aircraft`, `part`, `partCatalog`, `assembly`, `workOrder`, `reading`, `pirep`,
`technician`, `hangar`, `supplier`. **Mapeo 1:1 con lo que ya está escrito.**

**Frontera transaccional:** la **liberación al servicio**. Una persona firma que el avión puede
volar. **Frontera legal:** la misma — si el sistema no produce el soporte, no hay defensa ante
la autoridad y la licencia del firmante está en juego. Es el equivalente exacto del registro
profesional de Marcela en Áurea, con más dientes.
**El dato fuera del perímetro:** las reparaciones estructurales y los overhauls que se mandan
a un taller externo. La pieza sale, tarda meses y vuelve con un certificado en papel.
**El villano heredado:** en 2023 compraron un taller pequeño que traía su propio sistema en
Mongo *"porque cada avión es distinto"*. Desde entonces hay dos verdades sobre qué pieza está
dónde, y nadie sabe cuándo divergieron.

**Fortalezas.** Es la única candidata que **mejora las dos familias hoy más débiles del
temario sin tirar nada de lo escrito**: la trazabilidad es una búsqueda de patrón genuina —no
un árbol— y la residencia de datos por autoridad aeronáutica es la justificación de NewSQL más
sólida de las siete. La frontera legal es del nivel de Áurea. Y los reportes de piloto son el
mejor corpus de prosa para vectorial de todas las candidatas: cortos, con jerga, con faltas, y
con una tradición de humor propia que le da al curso sus mejores ejemplos.

**Debilidades.** El autor tiene que leer algo de mantenimiento aeronáutico antes de escribir, y
hay riesgo de que el dominio intimide a quien no ha pisado un hangar. Se mitiga con lo mismo
que usa Áurea: la empresa es pequeña, los fundadores son dos personas con manos sucias, y lo
que se explica del negocio es solo lo que el modelo de datos necesita.

**Coste de migración:** 🟢 **el más bajo de las siete.** Renombrado directo.

---

### 3.2 ⚡ Voltaria — distribuidora eléctrica regional

> Una electrificadora que pasó de cuarenta mil a novecientos mil clientes en doce años y tres
> adquisiciones, y que todavía no sabe con certeza qué transformador alimenta a qué casa.

| Familia | De dónde sale |
|---|---|
| 🕸️ Grafos | **La topología de la red.** *"Si abro este seccionador, ¿quién se queda sin luz?"* y *"¿de dónde viene esta falla, aguas arriba?"*. Es el problema de conectividad de profundidad variable por excelencia: en SQL no es que salga caro, es que no se escribe |
| 🏛️ Columnar · ⏱️ Series | Novecientos mil medidores reportando cada quince minutos. No es una metáfora de "no cabe en un nodo" |
| 📴 Offline | Las cuadrillas en zona rural — literalmente adonde no llega la señal porque tampoco llega la luz |
| 🧬 Vectorial | Los reclamos: *"se me quemó la nevera cuando volvió la luz el domingo"* |
| 🍃 Documental | La ficha de activo: transformador, poste, seccionador y medidor no comparten un solo campo |
| 🔑 · 🦆 · 🔍 · ⚡ | Portal de usuarios y candado de corte/reconexión · pérdidas no técnicas por circuito · catálogo de materiales · facturación bajo dos reguladores |

**Entidades:** `asset`, `component`, `materialCatalog`, `feeder`, `serviceOrder`, `reading`,
`claim`, `lineman`, `substation`, `supplier`.

**Frontera transaccional:** el **corte y la reconexión**. Cortarle la luz a quien ya pagó es un
incidente regulatorio con multa, no un bug. **Frontera legal:** el regulador, que pide
indicadores de calidad del servicio calculados sobre datos que la empresa hoy no sabe
reconstruir.
**El dato fuera del perímetro:** el operador de red de transmisión aguas arriba, que avisa de
sus maniobras cuando quiere y en el formato que quiere.
**El villano heredado:** el "datalake" de 2021 del que salen tres cifras distintas de pérdidas
según quién lo consulte.

**Fortalezas.** **El mejor minicurso de grafos que este curso puede llegar a tener**, sin
discusión: una red eléctrica es el caso canónico de conectividad de profundidad desconocida, y
las dos preguntas del dominio —aguas abajo y aguas arriba— son distintas entre sí y ninguna se
escribe cómoda en SQL. Columnar ancha y offline-first también son de los más honestos de las
siete. Las adquisiciones están en el ADN de la historia, así que F00 se escribe sola.

**Debilidades.** NewSQL solo se sostiene si la empresa opera bajo dos reguladores, y eso hay
que meterlo en la historia a propósito —se resuelve con un párrafo, pero es un párrafo puesto
para justificar una fase, y eso se huele—. Hay que reescribir las nueve entidades enteras. Y
es una empresa grande y algo impersonal: cuesta más darle la calidez que tiene Áurea.

**Coste de migración:** 🟠 alto.

---

### 3.3 ☕ Cumbre Roja — cooperativa cafetera vuelta exportadora

> Dos mil trescientos caficultores que dejaron de venderle a un intermediario, montaron su
> propia trilladora y hoy exportan a cuatro países con marca propia. La calidad la decide una
> mesa de catación; la plata la decide una báscula.

| Familia | De dónde sale |
|---|---|
| 🧬 Vectorial | **Las notas de catación.** *"panela, mora madura, cuerpo sedoso, acidez cítrica"*. Prosa de verdad, y *"¿qué lote se parece a este?"* es literalmente la pregunta del negocio |
| 🕸️ Grafos | **La trazabilidad de origen con mezcla.** Un lote se mezcla con otros, se parte, se vuelve a mezclar. Llega un rechazo por contaminante en el puerto de destino: ¿qué fincas pudieron aportar a este contenedor? Es el caso que el árbol no cubre, porque los caminos convergen |
| 📴 Offline | El técnico de campo en la finca de la montaña. El caso más honesto de las siete |
| 🍃 · ⏱️ · 🔍 | Ficha de finca y de lote · sensores de secado y de silo · catálogo de perfiles y variedades |
| 🦆 · 🔑 · 🏛️ · ⚡ | Costos por finca y cosecha · turno de báscula y candado del lote en compra · pesajes y eventos de toda la red de puntos de compra · liquidación a caficultores contra ventas en tres mercados |

**Entidades:** `farm`, `lot`, `varietyCatalog`, `blend`, `purchaseOrder`, `reading`,
`cuppingNote`, `agronomist`, `mill`, `buyer`.

**Frontera transaccional:** la **compra en báscula**. Se paga en efectivo contra un peso y una
calidad; si se paga dos veces o se paga mal, el caficultor no vuelve y se lleva a tres vecinos.
**Frontera legal:** la trazabilidad de origen ante las certificaciones y la normativa europea
de deforestación. Si no puedes demostrar de qué finca salió el grano, el contenedor no entra.
**El dato fuera del perímetro:** la trilladora de terceros y el agente de aduana, que procesan
el café y reportan en PDF cuando pueden.
**El villano heredado:** la cooperativa vecina que absorbieron en 2022, con su propio sistema y
su propia numeración de lotes.

**Fortalezas.** Es la historia con **más carácter** y la más difícil de confundir con un caso
de estudio genérico. Vectorial deja de ser la familia rara y pasa a ser la que resuelve la
pregunta central del negocio, lo cual es un regalo. La trazabilidad con mezcla es un grafo
genuino —convergente, no jerárquico— y es un caso que casi nadie usa de ejemplo. Offline-first
es impecable. Y la frontera legal es real, actual y con dinero encima.

**Debilidades.** **Columnar ancha y NewSQL son los más forzados de las siete.** Se sostienen
—una red de puntos de compra genera volumen, y exportar a tres mercados genera multi-región—
pero se nota que la historia los está estirando. Reescritura completa de entidades.

**Coste de migración:** 🟠 alto.

---

### 3.4 📣 Bengala — agencia de publicidad, medios y redes sociales

> Una creativa y un planificador de medios que se fueron de una multinacional en 2016 con dos
> clientes y un computador. Hoy son ochenta personas en tres países, manejan pauta ajena por
> una cifra que les quita el sueño, y siguen conciliando comisiones de influencers en una hoja
> de cálculo.

**Sobre el nombre.** Una bengala es exactamente lo que se vende: una señal que arde fuerte y
se apaga. El claim que acompaña —**"la atención se compra; la memoria se construye"**— es la
tensión interna de la casa: ella vende marca a largo plazo, él vende conversión esta semana, y
ninguno de los dos productos existe sin el otro. Es el mismo reparto de poder que sostiene
Áurea entre ortodoncia y estética, y sirve igual de bien: **cada decisión de arquitectura del
curso cae de un lado o del otro de esa discusión.**

| Familia | De dónde sale |
|---|---|
| 🍃 Documental | **La pieza creativa.** Un anuncio de video vertical, un banner display, un correo, una valla y un guion de audio no comparten un solo campo, y cada plataforma exige los suyos. Polimórfico de verdad y creciendo: cada formato nuevo de cada red añade campos que nadie previó |
| 🔑 Clave-valor | **Las cuotas de las APIs de las plataformas**, que son duras y te suspenden la cuenta si las pasas: rate limiting propio antes de llamar. Más tokens de acceso con expiración, el candado del job de publicación programada y la cola de publicaciones |
| 🦆 Analítico | **El tablero de rendimiento.** Las plataformas exportan CSV y Parquet y la agencia vive de cruzarlos. Es el caso de uso para el que este motor parece diseñado |
| ⏱️ Series | Métricas por anuncio y por hora: impresiones, clics, gasto, alcance |
| 🔍 Búsqueda | **El archivo creativo:** buscar entre diez años de piezas por copy, cliente, etiqueta o concepto. Y la moderación de comentarios por palabra |
| 🕸️ Grafos | **Fraude de influencers y granjas de bots.** Cuentas que se siguen en anillo, y cuentas aparentemente distintas detrás del mismo dispositivo o el mismo correo. Anillos de longitud desconocida e identidad indirecta: es el caso de fraude de `04-telarana`, en un dominio que la audiencia entiende sin explicación |
| 🧬 Vectorial | *"¿Qué campaña pasada se parece a este brief?"* sobre briefs y copys en prosa. Y la otra mitad: encontrar comentarios parecidos a los que ya marcamos como crisis de marca, que es seguridad de marca de verdad |
| 🏛️ Columnar | **Los eventos del pixel propio** en los sitios de los clientes: cada impresión, clic y scroll. Un puñado de clientes de comercio electrónico produce miles de millones de eventos, y ahí no cabe en un nodo |
| 📴 Offline | **Mercadeo de campo:** promotores en un concierto, en un supermercado, en una activación de marca — sin señal, levantando registros y fotos de góndola durante ocho horas |
| ⚡ NewSQL | **El presupuesto de pauta comprometido en tiempo real** desde tres oficinas en tres países, más la residencia de datos de audiencias europeas |

**Entidades:** `campaign`, `creative`, `creativeLibrary`, `placement`, `insertionOrder`,
`metric`, `comment`, `planner`, `office`, `platform` — más `account` para el grafo de cuentas
e influencers, que es la única que no tiene equivalente en el dominio actual.

**Frontera transaccional:** el **presupuesto de pauta**. El cliente deposita dinero y la
agencia lo compromete en varias plataformas a la vez, en tiempo real. Comprometer dos veces el
mismo peso o pasarse del tope no es un descuadre: **lo paga la agencia de su bolsillo**, y es
la clase de error que se descubre a fin de mes.
**Frontera legal:** **datos personales y consentimiento.** La agencia sube listas de correos
para construir audiencias personalizadas. Si el sistema no puede demostrar de dónde salió cada
dato y con qué consentimiento, la multa es real y **la marca que arde es la del cliente**, no
la de la agencia. Es el equivalente exacto de la dicotomía en Áurea: una restricción legal que
obliga a modelar bien, no a modelar bonito.
**El dato fuera del perímetro — y aquí Bengala es la mejor de las siete:** las plataformas. La
agencia **no es dueña de sus propias métricas**. Los números de ayer cambian hoy porque la
ventana de atribución se recalculó, la API se rompe sin avisar, un campo se deprecia con treinta
días de aviso, y dos plataformas reportan la misma conversión porque las dos se la atribuyen.
*"¿Cuál de los tres números es el bueno?"* no es un ejercicio inventado: es el trabajo. Y los
influencers son los aliados de Áurea calcados — reportan lo que quieren, desaparecen, y a veces
se llevan al cliente.
**El villano heredado:** en 2023 compraron una boutique de performance de cuatro personas que
traía su plataforma propia, **todo en Mongo porque "cada plataforma manda un JSON distinto"**.
El argumento era bueno. Lo que nadie previó fue la segunda colección, y hoy el reporte que ve
el cliente y el que ve finanzas no cuadran.

**Fortalezas.** Es la candidata con **la mejor relación entre dominio comprensible y dificultad
técnica real**: no hay que explicarle a nadie qué es una campaña, y aun así el problema de
datos es genuinamente duro. Clave-valor es la más natural de las siete —el rate limiting no es
un ejemplo, es una necesidad operativa con consecuencias—. Analítico embebido cae como un
guante. La reformulación retroactiva de métricas es **el mejor material sobre consistencia
eventual** que tiene cualquiera de estas historias, y alimenta directamente F24, la costura del
capstone. Y el grafo de fraude de influencers es un patrón real, actual, con dinero encima, y
comprimido directamente de `04-telarana`.

**Debilidades.** **Offline-first es el punto débil, y hay que reconocerlo:** el mercadeo de
campo lo rescata y es una línea de negocio real de las agencias, pero es una actividad lateral,
no el corazón del negocio, y se nota al lado de una cuadrilla eléctrica o un técnico en una
finca. **Segundo riesgo, y es el serio:** es la historia con más probabilidad de degenerar en
*"un CRUD de campañas"* si no se construye con disciplina, porque la superficie del dominio es
engañosamente familiar. Y hay una tercera que conviene mirar de frente: es un negocio que
algunos lectores desprecian de entrada. Se compensa con lo que los desarrolladores sí respetan
—las integraciones con las APIs de las plataformas son notoriamente dolorosas y mucha gente de
la audiencia ha sufrido una.

**Coste de migración:** 🟠 alto, aunque menor que el resto de las no aeronáuticas: seis de las
nueve entidades tienen equivalente conceptual directo.

---

### 3.5 🚢 Barlovento — operador portuario y de patio de contenedores

> Cuatro terminales, dos países, y una aduana que no perdona.

Documental (carga refrigerada, peligrosa, a granel y de proyecto no comparten campos) · grafos
(**cadena de custodia**: este contenedor con contrabando, ¿qué otros pasaron por los mismos
actores? — patrón de fraude, profundidad variable) · series (temperatura de los contenedores
refrigerados; si se sale de rango se pierde la carga) · columnar (eventos de posición de
decenas de miles de contenedores) · búsqueda (el arancel, con sinónimos y errores) · vectorial
(la descripción de la mercancía contra la partida arancelaria, que es una clasificación por
parecido hecha a mano todos los días) · offline (inspectores de patio) · clave-valor (cita de
camión, turno, candado de muelle) · NewSQL (dos aduanas, dos países) · analítico (demoras y
sobrestadía).

**Entidades:** `container`, `cargo`, `tariffCatalog`, `consolidation`, `gateOrder`, `reading`,
`inspection`, `inspector`, `terminal`, `carrier`.

**Frontera transaccional:** la **liberación de la carga**. Entregar dos veces el mismo
contenedor es un delito, no un descuadre. **Frontera legal:** la aduana, con retención de
mercancía como consecuencia inmediata.
**El dato fuera del perímetro:** las navieras y sus mensajes de estado, que llegan en formatos
de los años ochenta y con retraso.

**Fortalezas.** Todas las familias caen sin esfuerzo y la frontera transaccional es de las más
nítidas de las siete. El grafo de cadena de custodia es genuino. El dominio tiene escala real
sin tener que inflarla.

**Debilidades.** Es la más **"empresa grande y fría"** de las siete: cuesta encontrarle los dos
fundadores con manos sucias que hacen funcionar a Áurea. Y el dominio aduanero es árido de
explicar sin perder al lector en vocabulario.

**Coste de migración:** 🟠 alto.

---

### 3.6 📡 Nodo Sur — proveedor regional de internet por fibra

El **mejor encaje técnico bruto** de las siete: grafos es la topología de red, columnar ancha
son los registros de tráfico —el caso canónico de la familia—, clave-valor son sesiones y rate
limiting *que aquí son literalmente el producto*, offline-first son los instaladores, vectorial
son los tickets de soporte, y NewSQL es la facturación en dos países.

**Debilidades, y son de peso.** Es **informática hablando de informática**. Se pierde el efecto
Áurea —un dominio ajeno que obliga al lector a aprender un negocio que no es el suyo, que es
justamente lo que entrena el músculo de modelar— y sube el riesgo de que el lector confunda el
ejemplo del curso con la infraestructura del curso. Además, la audiencia ya tiene intuiciones
sobre este dominio, y las intuiciones previas son exactamente lo que el curso quiere
recalibrar, no confirmar.

**Coste de migración:** 🟠 alto.

---

### 3.7 🚚 Rueda Viva — la flota actual, narrativizada

Mantener el dominio de mantenimiento de flota tal como está y ponerle encima lo que le falta:
fundadores, historia, el Excel de alguien, la adquisición que trajo el sistema heredado.

**Fortalezas.** **Coste cero.** Nada de lo escrito se toca, la decisión 3 del alcance se
confirma en vez de reabrirse, y el trabajo se va entero a escribir la historia.

**Debilidades.** Cojea exactamente donde cojea hoy, y por eso apareció esta discusión. **Grafos
se queda en el despiece, que es descender un árbol** — y el propio curso declara en F14 que eso
no justifica un grafo, así que el minicurso tendría que apoyarse en un caso que la historia no
le da. Y NewSQL con tres talleres regionales no convence: la fase quedaría sosteniéndose sobre
un supuesto.

**Coste de migración:** 🟢 nulo.

---

## 4. ⚖️ Tabla comparativa

Las columnas son las cuatro familias difíciles de §2.1, más lo que decide en la práctica.

| Historia | 🕸️ Grafos | 🏛️ Columnar | ⚡ NewSQL | 📴 Offline | Frontera legal | Calidez narrativa | Coste |
|---|---|---|---|---|---|---|---|
| ✈️ **Cóndor MRO** | ✅ fuerte | ✅ fuerte | ✅ fuerte | ✅ fuerte | ✅ máxima | 🟡 media-alta | 🟢 nulo |
| ⚡ **Voltaria** | ✅ **máximo** | ✅ **máximo** | 🟡 estirado | ✅ **máximo** | ✅ alta | 🟡 media | 🟠 alto |
| ☕ **Cumbre Roja** | ✅ fuerte | 🟡 estirado | 🟡 estirado | ✅ **máximo** | ✅ alta | ✅ **máxima** | 🟠 alto |
| 📣 **Bengala** | ✅ fuerte | ✅ fuerte | 🟡 medio | 🟠 **débil** | ✅ alta | ✅ alta | 🟠 alto |
| 🚢 **Barlovento** | ✅ fuerte | ✅ fuerte | ✅ fuerte | ✅ fuerte | ✅ alta | 🟠 baja | 🟠 alto |
| 📡 **Nodo Sur** | ✅ **máximo** | ✅ **máximo** | ✅ fuerte | ✅ fuerte | 🟡 media | 🟠 **baja** | 🟠 alto |
| 🚚 **Rueda Viva** | 🟠 **débil** | ✅ fuerte | 🟠 **débil** | ✅ fuerte | 🟡 media | 🟡 por escribir | 🟢 nulo |

Una lectura que conviene no perder: **ninguna candidata es fuerte en las siete columnas.**
Elegir aquí es elegir qué debilidad se prefiere pagar, y por eso la decisión es del autor y no
del análisis.

---

## 5. 🧭 Recomendación

**Cóndor MRO**, y no por gusto sino por aritmética. Es la única de las siete que **mejora las
dos familias hoy más débiles del temario —grafos y NewSQL— sin tirar ninguno de los seis
documentos de `prompts/`**. El renombrado es mecánico; lo que cambia de verdad es el argumento
de F13/F14 y F21/F22, que hoy se sostienen sobre supuestos. Y trae la frontera legal más
afilada de todas: alguien firma que un avión puede volar.

**Si se prefiere la apuesta ambiciosa, Voltaria**, asumiendo dos cosas conscientemente: la
reescritura completa del dominio, y un párrafo de historia puesto a propósito para que NewSQL
tenga sentido. A cambio, el mejor minicurso de grafos que este curso puede tener.

**Si se prefiere la historia que nadie ha contado, Cumbre Roja**, asumiendo que columnar ancha
y NewSQL van a ir estirados y que el veredicto honesto de esas dos familias tendrá que hacerse
cargo de ello — cosa que, bien escrita, hasta juega a favor: *"en esta empresa, esta familia no
se justifica, y lo medimos"* es exactamente lo que el curso promete.

**Y una recomendación sobre Bengala que no es elegirla.** Aunque no sea la empresa del curso,
**es la mejor fuente de autopsias que hay en este documento**. Las tres que trae —el Mongo
heredado de la boutique de performance, los tres números que no cuadran porque la atribución se
recalculó, y la conciliación de comisiones en una hoja de cálculo— son mejores que las cinco
genéricas que hoy tiene F00 en `propuesta-fases-y-alcance.md` §3. Si gana otra historia,
**estas tres deberían migrar a F00 como casos de otra empresa**, que es exactamente para lo que
sirven las autopsias: decisiones ajenas de las que se aprende barato.

---

## 6. ❓ Lo que hay que decidir, en orden

1. **Qué historia gana.** Todo lo demás cuelga de aquí.
2. **Si el dominio se renombra o se reemplaza**, y con ello si se reabre la decisión 3 del
   alcance §12 o solo se le añade la historia detrás.
3. **El nombre del boss global.** Hoy es "El Taller" y sale del dominio de flota; con cualquier
   otra historia hay que renombrarlo, y el nombre debe salir de la empresa elegida.
4. **Dónde vive la historia.** La propuesta es `00-historia-de-<empresa>.md` en la raíz del
   curso, igual que en el curso de Python, y **fuera** de la numeración de fases para que F00
   siga siendo la primera fase lectiva. Habría que declararlo en la convención de nombres de
   `propuesta-fases-y-alcance.md` §10, que hoy no lo contempla.
5. **Si los cinco boss de bloque se reescriben como encargos internos** con quién los pide y
   qué entregan. La recomendación es que sí, y es la mitad del valor de tener una historia.
