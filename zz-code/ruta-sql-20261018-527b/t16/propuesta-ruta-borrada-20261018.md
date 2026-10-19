# 🧮 Propuesta — Ruta SQL

> **Qué es este documento:** la conversación de diseño puesta por escrito. No es todavía el
> alcance (`prompts/alcance-del-proyecto.md`) ni la estructura (`0-ESTRUCTURA-CURSO.md`): es de
> donde van a salir. Lo que está marcado como **decidido** ya se habló y se cerró; lo marcado
> como **abierto** espera respuesta. Cuando todo esté decidido, este documento se parte en los
> de `prompts/` y queda como registro histórico.

---

## 1. 🎯 La tesis

La Ruta NoSQL Lite afirma en su primera fase que *"la mayoría de las veces gana Postgres"*, y no
lo demuestra: su trabajo es ir a por los casos donde no alcanza. **Esta ruta es la que se gana
esa frase.**

El villano es el mismo en los dos cursos —**elegir sin entender el modelo de acceso**—, pero
aquí se ve desde el otro lado, y tiene dos caras que en el fondo son una sola:

- **"Mongo por moda."** Descartar lo relacional sin saber lo que ofrece.
- **"La base es un pote donde creo tablas."** Usar lo relacional sin saber lo que ofrece. Es el
  más frecuente entre seniors, y el más caro, porque se disfraza de experiencia.

Un senior tiene que ver la base de datos como un **problema de optimalidad con tradeoffs**:
qué normalizar y qué no, qué indexar y qué cuesta ese índice en cada escritura, qué nivel de
aislamiento paga qué anomalía, qué identificador filtra qué información. El curso existe para
instalar ese modo de mirar, y para que la respuesta *"esto no es relacional"* —que a veces es la
correcta— se dé con el mismo rigor.

**El instrumento se hereda:** las cinco preguntas de la NoSQL Lite, respondidas desde el lado
relacional. La frontera transaccional pasa a ser la carta más fuerte de lo relacional; *"¿conoces
tus consultas de antemano?"* se vuelve su ventaja estructural, porque el SQL ad hoc sobre un
modelo normalizado responde preguntas que todavía no existen. Las dos rutas quedan cosidas y cada
una es el contrapeso de la otra.

---

## 2. 🗄️ Los motores y su reparto — *decidido*

No simétricos. Tres manuales de producto en paralelo no enseñan a decidir; los motores entran
donde su mecanismo interno **cambia la decisión**.

| Motor | Rol | Por qué está |
|---|---|---|
| 🐘 **PostgreSQL** | laboratorio principal e hilo conductor | abierto, arm64 nativo, `jsonb`, SSI real, PostgREST |
| 🏛️ **Oracle** (Free) | caso de estudio | undo segments, `SERIALIZABLE` que es *snapshot isolation*, hints y baselines, JSON Relational Duality Views, ORDS |
| 🐬 **MySQL** (8.4 LTS) | contraste recurrente | InnoDB clustered (el caso UUID sin emulación ni cláusula DeWitt), gap locks, JSON sin GIN, DDL online, la historia típica de "nos fuimos a Mongo" |
| 🪟 **SQL Server** | **track opcional** | concurrencia pesimista por defecto contra RCSI, Query Store, Data API builder; pensado para shops .NET |

**MariaDB queda fuera**, con una nota en el diccionario de traducción: ya divergió de MySQL lo
suficiente (JSON como alias de `LONGTEXT`, GTID incompatible) como para no representarlo, y lo
que tiene de atractivo —tablas temporales, modo de compatibilidad Oracle— ya lo cubren Oracle y
SQL Server.

**El track de SQL Server** sigue la convención del repo para tracks opcionales: prefijo propio
de archivo, prompts propios, cero añadidos a los documentos del camino base. Laboratorio en
contenedor Linux para todos —en Apple Silicon con emulación, que no altera la forma del plan ni
las lecturas lógicas— y un apéndice corto sobre *qué cambia en Windows* (autenticación
integrada, WSFC contra Pacemaker, SSMS, funciones ausentes en Linux), que es operación y no
motor. ⚠️ Pendiente verificar en `verificacion-de-laboratorio/` que la imagen arranca con
Rosetta en Docker Desktop **y** en Podman.

---

## 3. 📐 Cómo se mide, y qué no se publica — *decidido en principio*

Se hereda el principio de la NoSQL Lite, **la forma y no la velocidad**: lecturas lógicas
(`BUFFERS`, `STATISTICS IO`, `consistent gets`), forma del plan, filas estimadas contra reales,
*page splits*, bytes de WAL o redo, tamaño de índice, filas bloqueadas.

Aquí el principio deja de ser preferencia y pasa a ser obligación: **las licencias de Oracle y
de SQL Server prohíben divulgar resultados de benchmark sin permiso.** Ejecutarlos en privado
está permitido; publicarlos no. De ahí la regla:

- **Postgres y MySQL:** receta y resultado publicados.
- **Oracle y SQL Server:** se publica la **apuesta falsable completa** —hipótesis, condiciones,
  comando— **sin resolver**. La resuelve el lector en su máquina. El mecanismo se explica citando
  la documentación oficial, no con números propios.
- Las corridas privadas del autor sirven para escribir bien la prosa y validar la receta, y
  **viven fuera del repo**.

Esto diverge del `CLAUDE.md` raíz, que pide resultados en `BENCHMARKS.md`. La guía de estilo del
curso tiene que declarar la excepción explícitamente.

❓ **Abierto:** ¿el repo es o será público? Define qué tan estricta es la regla, sobre todo en la
zona gris de los planes de ejecución de Oracle y SQL Server.

---

## 4. ⏱️ Carga horaria — *decidido: la de la NoSQL Lite*

**252 horas ≈ 21 semanas a 12 h semanales.** Borrador de bloques, para discutir:

| Bloque | Qué resuelve | Fases | Horas |
|---|---|---|---|
| **0 · El instrumento** | la tesis, el sistema heredado, las cinco preguntas vistas desde el lado relacional, el arnés de forma | F00–F02 | 12 h |
| **I · El modelo** | álgebra relacional y dónde SQL la traiciona (bags, `NULL`, orden) · 1FN–BCNF sobre el esquema heredado · 4FN y 5FN · 6FN, lo temporal y **cuándo normalizar estorba** (autopsia de EAV, desnormalización controlada) | F03–F06 | 40 h |
| **II · La física y el tuning** | heap contra clustered · **identificadores** (secuencias, UUIDv4/v7, predictibilidad) · índices y su costo de escritura · estadísticas y cardinalidad · el optimizador en tres motores · tuning de consultas (keyset contra `OFFSET`, N+1, *parameter sniffing*) | F07–F12 | 60 h |
| **III · La concurrencia** | aislamiento comparado (SSI, el falso `SERIALIZABLE` de Oracle, gap locks) · MVCC y su factura (VACUUM y bloat, undo y `ORA-01555`) · bloqueos, deadlocks y el folio duplicado | F13–F16 | 40 h |
| **IV · Lo "NoSQL" dentro del SQL** | JSON en los motores y Duality Views · la propuesta de Mongo, arbitrada con medición · búsqueda, vectores y grafos: hasta dónde llega | F17–F20 | 40 h |
| **V · La base como producto** | PostgREST, RLS como frontera de autorización, el esquema como contrato; ORDS y DAB como equivalentes; cuándo la lógica en la base es una cárcel | F21–F22 | 20 h |
| **VI · El árbitro** | capstone: la decisión de arquitectura de la empresa, defendida con medición | F23–F25 | 40 h |

Se heredan también las dos anclas: **una apuesta falsable** y **un punto de rotura** por fase B.

❓ **Abierto:** ¿entra algo de operación (réplicas, backup, PITR, particionado como operación)? El
tuning la arrastra un poco, pero la NoSQL Lite la dejó fuera a propósito.

---

## 4 bis. 📦 El punto de partida y los lenguajes — *decidido*

**El curso no requiere Access, ni Windows, ni SQL Server.** Access existe en la historia; el
lector nunca lo instala.

**El lector recibe un volcado, no una base.** El primer día del encargo, Matías le entrega "la
caja": cada tabla de `ALAMEDA` exportada a CSV con `bcp`, el DDL que generó SSMS, los módulos VBA
de Rubén exportados como `.bas` (texto, para leer y portar, no para ejecutar) y las planillas
Excel que el laboratorio recibe de afuera. La primera fase carga todo eso **tal cual** en un
esquema `legado` de Postgres, con tipos de texto donde el original tenía texto. **El desastre se
hereda intacto**, y limpiarlo es el curso.

Esto encaja en la historia sin forzarla, porque es exactamente lo que pasa en un proyecto real.
Nadie le da acceso de escritura a producción al arquitecto nuevo el primer día.

Qué trae la caja, y por qué cada pieza es verosímil:

| Pieza | Formato | Qué enseña |
|---|---|---|
| Tablas de `ALAMEDA` | CSV (UTF-8 y, a propósito, un par en Latin-1) | la carga sucia, la codificación, los tipos que mienten |
| DDL original | `.sql` de T-SQL | leer un esquema ajeno y traducirlo |
| `ExtraerDNI()` y compañía | `.bas` de VBA, y la versión T-SQL de Matías | portar el parser a Python y descubrir las dos diferencias no documentadas |
| El `.accdb` de turnos | CSV, con el campo multivalor exportado como `HEM;GLU;URE` | la violación de la 1FN tal como sale de Access |
| Padrones de afiliados de las obras sociales | Excel y TXT de ancho fijo | datos de referencia que llegan de afuera y cambian cada mes |
| El NBU y los convenios de precios | Excel | datos de referencia versionados |
| La planilla de notificación de la pandemia | Excel | el copiar y pegar de 2020 como fuente de verdad involuntaria |
| Órdenes escaneadas y PDF | **no vienen**: un CSV de metadatos con el tamaño de cada archivo | el terabyte que no va en la base se discute con números, sin descargarlo |

**Los datos son sintéticos y con semilla**, como en la NoSQL Lite, pero el generador tiene que
producir **la suciedad**: nombres con el DNI adentro, recién nacidos con el DNI de la madre,
fechas de nacimiento en el futuro, resultados con coma y con punto, duplicados plausibles.

**Lenguajes: el más simple que encaje en la narrativa.** Sin dogma, pero con un default:

- **SQL es el lenguaje del curso.** Casi todo se resuelve en el motor, y cuando no se puede, eso
  ya es un hallazgo.
- **Python para todo lo demás**: el generador de datos, la carga de la caja, la lectura de los
  Excel, el port del parser, el arnés de medición y las simulaciones de concurrencia (dos
  recepcionistas pidiendo folio a la vez son dos hilos). Una sola dependencia de lenguaje para el
  lector.
- **Java solo si una fase lo justifica narrativamente**, por ejemplo si la interfaz con el SIH se
  cuenta como un servicio Java de la red. Nunca como segunda vía para lo mismo.
- **PostgREST reemplaza el código de aplicación** en el bloque V. El cliente de la app se simula
  con `curl` o con un script corto.

Esto cierra el stack y se aparta de la NoSQL Lite (TypeScript por defecto), a propósito: aquí el
protagonista es el motor, no la aplicación.

**El track de SQL Server** carga la misma caja en SQL Server y ejecuta el T-SQL de Matías tal como
está. Es el único lugar donde el lector ve "la base" en su motor original.

### 🧪 Se decide en el taller

Dos piezas tienen la dirección acordada, pero se confirman con el laboratorio andando:

- **El puente de integración, en Java.** Es el mundo de la red: ActiveMQ Artemis en contenedor y un
  servicio Java chico, hecho sin demasiada ingeniería, que mueve órdenes del SIH hacia el
  laboratorio y resultados de vuelta, con mensajes que imitan HL7 v2 (`ORM` y `ORU`). El broker no
  es el tema. Es el lugar donde aparecen los problemas de consistencia entre dos bases: doble
  escritura y *outbox*, entrega duplicada e idempotencia, correcciones fuera de orden y el mensaje
  veneno. El veredicto que lo cierra: **¿hacía falta un broker?**, medido contra una cola en
  Postgres con `SKIP LOCKED` y contra las colas dentro de Oracle.
- **El `.accdb` de museo, opcional.** Se genera desde la misma semilla con Jackcess (Java puro, sin
  Office ni Access) y se abre en Mac con DBeaver y UCanAccess, o se lee desde Python con
  mdbtools. Límites conocidos: Jackcess no crea campos multivalor ni de adjuntos, y ninguna
  herramienta extrae VBA, formularios ni macros, así que el VBA sigue viajando como `.bas` en la
  caja. **Si no resulta viable, el plan B es una base de LibreOffice Base**: cambia el formato, no
  la narrativa. En cualquier caso, **nadie lo necesita para hacer el curso**; el insumo oficial es
  la caja en CSV.

---

## 5. 🧪 La empresa del curso — *en desarrollo*

> 📝 Se eligió el candidato A. La historia se desarrolla en
> [`00-historia-de-alameda.md`](../00-historia-de-alameda.md): Laboratorio Alameda (Córdoba, 1996), absorbido
> por la Clínica Mediterránea (2011) y por la red Horizonte Salud (2022). Lo que sigue en esta
> sección es el razonamiento que llevó ahí; donde difiera de la historia, gana la historia.

### 5.1 Lo que tiene que cumplir

Otro sector y otra empresa que Cóndor MRO (aeronáutica, NoSQL Lite) y Cordillera Media
(editorial, curso de C#). Y hay una restricción que conviene decir en voz alta: **Cordillera ya
cuenta la historia xBase → SQL Server** —FoxPro, pasantes, asistente de importación, sin llaves
foráneas, fechas en `char(8)`, borrado por bandera, una tabla por año—. Si esta ruta repite ese
origen, el lector que hizo los dos cursos siente que lee lo mismo.

**Access es mejor origen para este curso**, y no solo por variar. El problema de Cordillera era
el *código* heredado; el de esta empresa tiene que ser el *modelo de datos* y el *modelo de
acceso* heredados. Y Access produce exactamente eso: la idea de que una base de datos es un
puñado de tablas unidas por líneas que se dibujan arrastrando, con un formulario encima. Nadie
diseñó nada, y todo funcionó durante años —esa parte hay que respetarla igual que Cordillera
respeta a sus pasantes—.

Lo que Access le deja al curso y FoxPro no:

- **Campos de búsqueda y campos multivalor** (Access 2007 en adelante): la violación de la 1FN
  hecha función del producto. Es la entrada natural al bloque de normalización.
- **Relaciones dibujadas sin marcar "exigir integridad referencial"**: huérfanos con diagrama
  incluido, que es peor que no tener diagrama.
- **El folio con `DMax() + 1`**: numeración de facturas o de órdenes calculada leyendo el máximo.
  Funciona con un usuario; con dos sedes emite folios duplicados. Es la puerta de entrada al
  bloque de concurrencia.
- **Replicación de Jet y el autonumérico aleatorio**: al replicar, Access convierte los
  autonuméricos en aleatorios para que las sedes no choquen. Es la historia de origen del
  capítulo de identificadores, contada por la propia empresa.
- **El límite de 2 GB del `.mdb`** y el ritual de *compactar y reparar*.
- **Las tablas vinculadas por ODBC** tras el *upsizing*: el frontal Access siguió resolviendo
  joins en el cliente y trayéndose tablas enteras por la red. Es el N+1 y el "la base está
  lenta" más didáctico que existe, porque la base no estaba lenta.
- **El límite de 10 GB de SQL Server Express**, que es la segunda pared contra la que choca una
  empresa que ya se había "modernizado".

### 5.2 Cómo se arma la genealogía para que los cuatro motores lleguen solos

La gracia de Cordillera es que nadie eligió ser una casa Microsoft: pasó. Aquí se puede hacer lo
mismo con los cuatro motores, sin que ninguno esté puesto por el curso:

1. **Access** — el sistemita del sobrino, en una sola sede.
2. **Access dividido** (frontal y datos) en una carpeta compartida, cuando llega la segunda sede;
   luego **replicación de Jet** y el lote nocturno entre sedes.
3. ***Upsizing* a SQL Server Express** con el frontal Access intacto por ODBC. Hasta que choca con
   los 10 GB.
4. **MySQL** llega por un costado: una agencia construye el portal web en PHP y lo alimenta con un
   volcado nocturno.
5. **Oracle** llega por una adquisición o por un socio grande (un hospital, una aseguradora, el
   regulador) que corre sobre Oracle y exige integración.
6. **Hoy**: un equipo nuevo tiene que consolidar. Alguien propone Postgres; alguien propone Mongo.
   **El curso es esa decisión.**

La propuesta de Mongo no puede ser un hombre de paja. Tiene que venir de alguien competente con
un argumento que en parte es correcto, y el curso tiene que concederle lo que tiene de razón.

### 5.3 Tres sectores candidatos

**🧪 A — Red de laboratorios clínicos.** *(recomendado)*
Empieza con una bioquímica que abre su laboratorio y un sobrino que le arma el sistema en Access 97
para imprimir resultados. Crece a una red de sedes de toma de muestra con un laboratorio central.

- **Por qué encaja tan bien:** los resultados de examen son **el caso canónico de EAV** —cientos
  de tipos de examen, cada uno con parámetros, unidades y rangos de referencia distintos—, que es
  justo la tentación que lleva a "esto es un documento, vámonos a Mongo". El argumento de Mongo es
  genuinamente fuerte aquí, y por eso el veredicto vale.
- **Identificadores:** el portal de resultados con `resultado.php?id=48213`. Alguien cambia el
  número y ve el examen de otra persona. Es el incidente que abre el capítulo de IDs, y enseña
  sin sermón que el ID opaco **no** arregla un IDOR: lo arregla la autorización, y RLS entra ahí.
- **Temporal y auditoría:** un resultado corregido tiene que conservar la versión anterior y quién
  la cambió. En Access cualquiera abría el `.mdb` y editaba. Es la motivación natural de la 6FN y
  de las tablas temporales.
- **Concurrencia:** el número de orden con `DMax() + 1` en tres sedes; la muestra asignada dos
  veces.
- **Lote nocturno:** las sedes sincronizan de noche, y el día que la red creció el lote terminó a
  las nueve de la mañana con pacientes esperando.
- **Riesgo:** el dominio sanitario pide cuidado con datos personales. Los datos son sintéticos y
  con semilla, como en la NoSQL Lite, y el propio curso lo puede convertir en tema.

**💊 B — Distribuidora farmacéutica.**
Lotes, fechas de vencimiento, despacho FEFO, sustancias controladas con trazabilidad regulada,
sucursales. Tiene invariantes durísimas (stock nunca negativo, lote nunca vencido despachado) y es
muy buen dominio relacional, pero tiene menos tensión NoSQL: casi todo en él *es* relacional, y
el veredicto sale sin rival serio.

**📦 C — Empresa de mensajería y encomiendas.**
Guías de envío numeradas en secuencia (la enumeración de números de guía es un incidente real y
frecuente del sector), agencias en ciudades pequeñas con conectividad mala, consolidación
nocturna y rastreo público. Buena para identificadores y lote nocturno, pero se solapa con el
técnico sin señal de Cóndor y con la parte offline-first de la NoSQL Lite.

### 5.4 Borrador de genealogía para el candidato A

Todos los nombres, fechas y cifras son provisionales; están para ver si la historia se sostiene.

- **1994.** Una bioquímica abre su laboratorio en una ciudad intermedia (país por definir, para
  no repetir Colombia ni los tres de Cóndor). Resultados escritos a máquina y un cuaderno de
  órdenes.
- **1999.** Su sobrino, estudiante de ingeniería, le arma "el sistemita" en **Access 97**:
  pacientes, órdenes, resultados en campos memo, e impresión del informe. Tablas `Tabla1`,
  `Pacientes copia`, `Resultados NUEVA`. Funciona muy bien, y ese es el problema.
- **2004.** Segunda sede. Base dividida en una carpeta compartida; bloqueos, corrupción y el ritual
  de compactar y reparar de los lunes. Se acerca a los 2 GB y se parte por año.
- **2007.** Tercera y cuarta sede con enlaces lentos: **replicación de Jet**, lote nocturno,
  autonuméricos que de repente son negativos y enormes. Pacientes duplicados entre sedes, con dos
  historiales que nadie puede fusionar.
- **2010.** Un consultor hace el *upsizing* a **SQL Server Express**. El frontal Access sigue
  intacto por ODBC. Por un tiempo todo mejora; después, "la base está lenta".
- **2014.** Una agencia construye el portal de resultados en **PHP y MySQL**, alimentado por un
  volcado nocturno. El portal muestra resultados de hasta ayer y nadie lo considera un problema.
- **2018.** SQL Server Express llega a 10 GB. Se compra una licencia Standard a regañadientes.
- **2019.** El incidente del portal: IDs secuenciales enumerados. Multa o amonestación del
  regulador y un titular en el periódico local.
- **2021.** La red se asocia con una clínica grande (o la compra una aseguradora) que corre su
  sistema hospitalario sobre **Oracle**, y hay que integrarse.
- **2026.** Llega una jefa técnica nueva, que es el lugar del lector. Encargo: consolidar todo sin
  parar la operación. Un desarrollador senior recién contratado, que viene de una startup,
  propone MongoDB para los resultados, con buenos argumentos. El sobrino, que hoy es gerente de
  operaciones, protege "su sistema", y conoce el negocio mejor que nadie.

❓ **Abierto:** sector (A, B, C u otro), país y ciudad, nombre de la empresa y del elenco.

---

## 6. 🔑 Temas que ya tienen dueño

Para que no se pierdan mientras se arma la estructura:

- **Identificadores:** `bigint` identity/secuencia, UUIDv4 contra UUIDv7 (`uuidv7()` nativo en
  Postgres 18), `NEWSEQUENTIALID()`, `SYS_GUID()`; *page splits* en clustered (MySQL, SQL
  Server), full-page writes y WAL en Postgres; qué filtra cada uno (volumen de negocio, fecha de
  creación); el patrón `bigint` interno más identificador público opaco; caché de secuencias,
  huecos, hi/lo en los ORM.
- **Normalización exótica:** 4FN con dependencias multivaluadas reales; 5FN con dependencias de
  join que no sean de libro; 6FN y *anchor modeling*; dónde la 6FN hace explotar joins y deja al
  optimizador sin estimación posible.
- **SQL contra el modelo relacional:** la crítica de Date y Darwen, sin convertirla en religión.
- **JSON:** `jsonb` + GIN, JSON de MySQL con columnas generadas e índices multivalor, OSON y
  **Duality Views** en Oracle; el tipo `json` nativo de SQL Server 2025 en el track opcional.
- **Tuning:** la referencia natural es *Use The Index, Luke* de Markus Winand, que compara
  justamente estos motores.
- **MySQL y la migración a Mongo:** muchas historias de "nos fuimos a Mongo" empiezan con un
  `ALTER TABLE` que bloqueó producción. El problema era operativo y no del modelo.
- **Honestidad sobre MySQL:** las señales de desinversión de Oracle en 2025 van en el veredicto.
  La pregunta no es si el motor está bien, sino quién lo mantiene dentro de cinco años.

---

## 7. 📋 Preguntas abiertas, en un solo lugar

1. ¿El repo es o será público? (§3)
2. ¿Entra algo de operación? (§4)
3. ~~¿Mismo stack de laboratorio que la NoSQL Lite?~~ Cerrado en §4 bis: SQL + Python, sin Access.
4. ~~Sector, país y elenco de la empresa.~~ En desarrollo en `00-historia-de-alameda.md`.
5. Nombre definitivo del curso: `ruta-sql` a secas, o con sufijo como la NoSQL Lite.
