# 🧪 Ruta SQL — La base que nadie diseñó

**Un laboratorio clínico, veinticinco años de base heredada y tres motores para rediseñarla con
mediciones propias.** Un curso para mirar una base de datos relacional como un problema de decisiones
con costo, y no como un pote donde se crean tablas.

> 🧠 **El villano no es Access, ni Oracle, ni Mongo.** Es *elegir sin entender el modelo de acceso*, y
> tiene dos caras: descartar lo relacional sin saber lo que ofrece, y usarlo sin saber lo que cuesta.
> La segunda es la más frecuente entre seniors y la más cara, porque se disfraza de experiencia: veinte
> años de `SELECT *` desde un ORM no enseñan qué nivel de aislamiento tiene la conexión.

---

## 🎯 Qué es, y qué no es

**Es** tomar el sistema de **Laboratorio Alameda**, que empezó en Access 97 y vive en SQL Server, con un
portal en MySQL y el sistema del hospital en Oracle, y rediseñarlo fase por fase: el modelo, la física,
la concurrencia, lo que no es relacional, la integración y la migración sin parar un día. Cada decisión
se toma con una medición encima de la mesa.

**No es** un curso para formar DBA de ningún producto, ni para aprobar una certificación, ni para
tunear parámetros de servidor más allá de lo que explica una decisión de diseño.

Tres compromisos lo sostienen:

- 📐 **Se mide la forma, no la velocidad.** Bloques leídos, filas examinadas contra devueltas,
  estimadas contra reales, bytes de tabla, de índice y de WAL, filas bloqueadas. *"Esta consulta lee
  4.160 bloques para contar 18.936 filas"* sigue siendo cierto en otra máquina; *"tarda 29 ms"* no.
- 🪞 **Una apuesta falsable antes de cada medición**, con su número. Se publica el resultado, se gane o
  se pierda: varias se pierden en público, y el curso las cuenta enteras.
- 🔒 **De Oracle y de SQL Server no se publica ningún número.** La licencia de SQL Server lo prohíbe, y el
  curso aplica la misma regla a Oracle. Se publica la estructura del plan, el mensaje de error y la
  **apuesta sin resolver**, con el comando para que la resuelvas tú ([`a09`](a09-licencias-publicacion-y-riesgo.md)).

Y una honestidad que va dicha pronto: **"esto no es relacional" a veces es la respuesta correcta**. El
Bloque IV mide la propuesta de pasar el informe a MongoDB en su terreno, y le concede lo que gana con
número.

---

## 👥 Para quién es

Ingenieros de software con experiencia, que usan bases relacionales todos los días y casi siempre a
través de un ORM. Sabes escribir SQL, sabes qué es un índice y una transacción. Lo que el curso enseña es
**lo que cuestan**: qué hace un índice en cada `INSERT`, qué anomalía deja pasar tu nivel de aislamiento,
por qué el optimizador eligió ese plan.

No se explica qué es una tabla, un join, Docker ni JSON. Sí se explica, sin ambigüedad, qué es una
dependencia funcional, qué significa cada campo de un `EXPLAIN`, qué es MVCC por dentro y por qué un
UUIDv4 parte páginas.

**Necesitas:** Docker con Compose, [`uv`](a06-python-java-y-drivers.md#-uv-y-el-uvlock) (que baja Python 3.13 por su cuenta), **16 GB de RAM** y soltura leyendo Python. El curso se ejecutó con
Docker Desktop; Podman se probó solo con SQL Server, y ahí no arranca ([`a01`](a01-laboratorio-contenerizado.md)). Java 25 aparece solo en el boss del puente y en el apéndice opcional del Access
de museo, los dos en contenedor. En tu máquina no se instala nada más que Docker y `uv`.

---

## ⏱️ Cuánto cuesta

**252 horas ≈ 21 semanas a 12 h semanales.** El track de SQL Server, los boss y los apéndices van aparte.

| Bloque | Qué resuelve | Fases | Horas |
|---|---|---|---|
| **0 · El instrumento** | la tesis, la caja, el arnés de forma y las cinco preguntas desde el lado relacional | F00–F02 | 12 h |
| **I · El modelo** | lo que SQL le hace al modelo, de la 1FN a la 5FN, la identidad, el tiempo, y anchas contra EAV contra `jsonb` | F03–F08 | 48 h |
| **II · La física y el tuning** | tamaño, identificadores, índices, estadísticas, optimizador y "la base no estaba lenta" | F09–F14 | 60 h |
| **III · La concurrencia** | aislamiento, el folio sin huecos, MVCC y su factura, bloqueos y DDL | F15–F18 | 40 h |
| **IV · Lo NoSQL dentro del SQL** | JSON en los motores, la propuesta de MongoDB medida, y hasta dónde llega el motor | F19–F21 | 30 h |
| **V · La base en la red** | la exportación, la cola y el CDC; la base como producto, con su API y su seguridad por fila | F22–F23 | 30 h |
| **VI · El árbitro** | el diseño, la migración sin parar y el comité | F24–F26 | 32 h |
| 🪟 **Track SQL Server** (opcional) | la base en su motor original: RCSI, Query Store, *clustered*, temporales y Data API builder | ss01–ss05 | 40 h |

El temario fase por fase, con horas, ejercicios y estado, está en
[`0-ESTRUCTURA-CURSO.md`](0-ESTRUCTURA-CURSO.md).

---

## 🗄️ Los motores, y para qué está cada uno

| Motor | Papel | Por qué |
|---|---|---|
| 🐘 **PostgreSQL 18** | laboratorio principal | abierto, arm64 nativo, `jsonb`, SSI real, restricciones de exclusión, PostgREST |
| 🐬 **MySQL 9.7 LTS** | contraste recurrente | InnoDB *clustered*, *gap locks*, JSON sin GIN, DDL en línea; el portal de 2013 |
| 🏛️ **Oracle 26ai Free** | caso de estudio | *undo*, el `SERIALIZABLE` que es *snapshot isolation*, *hints* y *baselines*; el SIH de la red |
| 🪟 **SQL Server 2025** | track opcional | "la base" en su motor original: concurrencia pesimista por defecto, Query Store, Data API builder |
| 🍃 **MongoDB 8.0** | invitado de la Fase 20 | la propuesta de Florencia, medida en su terreno |

Todas las imágenes van **fijadas por digest**, con fecha de verificación ejecutada, en
[`a02`](a02-compose-de-la-ruta.md). El laboratorio entero se levanta con `uv run lab up`.

---

## 🧪 Una empresa, un sistema que nadie diseñó

**Laboratorio Alameda**, de Córdoba, fundado en 1996 y hoy laboratorio central de una red de salud para
el interior del país. Su sistema lo armó Rubén, un contador, en Access 97: tablas unidas por rayitas con
un formulario arriba, un parser que saca el DNI del nombre del paciente, y veinticinco años de parches
que funcionaron. El curso respeta esa historia, porque alcanzó, y la usa como material, porque cada tabla
incómoda tiene un año y una razón. Está entera en [`00-historia-de-alameda.md`](00-historia-de-alameda.md).

**El lector no recibe el `.mdb`: recibe la caja**, el volcado en CSV que dejó Matías, el de sistemas,
generado con semilla determinista y con su suciedad intacta: 71 tablas anchas, nombres con el DNI
adentro, fechas de dos cifras, claves foráneas que nunca se validaron. Y debajo, **la verdad**, lo que el
generador sabe y la caja no dice, que permite medir si una limpieza acertó ([`a05`](a05-la-caja-y-el-generador.md)).
**La misma medición en tu máquina y en la mía.**

---

## 🚦 Por dónde empezar: tres rutas

**El orden de publicación es el de aprendizaje**, y los bloques no son independientes: el Bloque II mide
sobre el modelo del I, y el III concurre sobre las tablas del II. Se puede saltar el IV y el V; no se
puede empezar por el III. Antes de la Fase 00: [`a01`](a01-laboratorio-contenerizado.md) y
[`a02`](a02-compose-de-la-ruta.md) para el laboratorio, y la
[convención de git](00-convencion-de-git-y-tags.md) para tu repositorio.

| Ruta | Qué haces | Horas | Sales con |
|---|---|---|---|
| 🥾 **Mínima** | el Bloque 0 y el Bloque I (F00–F08), con el 💀 boss I | 60 h | un esquema de pacientes que defiende sus reglas, y la medición de cuánto rechaza |
| ⚙️ **Rendimiento** | la mínima, más el Bloque II y el Bloque III (F09–F18), con los boss II y III | 160 h | leer un plan en tres motores, elegir índices y niveles de aislamiento sabiendo qué cuestan, y demostrarlo con dos sesiones |
| 🗺️ **Completa, con el track** | las 27 fases y sus boss, el 🏆 "Un martes", y el track de SQL Server (ss01–ss05 y ssa-01) | 292 h | el diseño, la migración y la presentación ante el comité, y la misma base en el motor donde nació |

**El track de SQL Server** necesita el camino base hasta la Fase 18; `ss01` se puede hacer después de la
Fase 04. En Apple Silicon exige Docker Desktop, porque SQL Server corre emulado y en Podman no arranca.

> 📝 **El curso está escrito entero:** las 27 fases, los seis boss, el 🏆 "Un martes", las cinco fases
> del track, los once apéndices y los 43 solucionarios, ejecutados en macOS arm64 con Docker Desktop.
> Linux y Windows 11 con WSL2 están escritos desde la documentación y sin ejecutar
> ([`a01`](a01-laboratorio-contenerizado.md)).

---

## 🏆 Los proyectos boss

- 🏆 **"Un martes"**, el boss global, acumulativo y opcional. El `LEEME.txt` de Matías termina con
  *"cualquier cosa me llaman, pero no los martes que es día de facturación"*: el encargo termina cuando
  **la facturación de un martes corre entera sobre la base nueva**, mientras la vieja sigue viva al lado.
  Cierra en la [Fase 26](26-el-comite.md#55-un-martes-el-boss-global).
- 💀 **Un boss por bloque**, del I al V, y el ☕ **boss del puente** en Java 25 con Apache Artemis. Cada uno es
  un encargo de alguien de Alameda con nombre, empieza con un sistema roto y se acepta con criterios que
  un arnés comprueba. **Ninguna solución se publica**: el criterio de aceptación es el entregable.

---

## 📚 Cómo está organizado

- **`00-historia-de-alameda.md`**: la empresa, su gente y la genealogía del sistema, de 1996 a 2026. No es
  una fase: es de donde sale todo lo narrativo.
- **`0-ESTRUCTURA-CURSO.md`**: el temario en una página, con el estado de cada documento.
- **`00-convencion-de-git-y-tags.md`**: cómo se commitea y se etiqueta lo que haces.
- **Fases** `00-…md` a `26-…md`: el curso, con la misma forma en cada una (setup, conceptos, apuesta,
  punto de rotura, autopsia, traducción, veredicto honesto y ejercicios).
- **Track** `ss01-…md` a `ss05-…md` y `ssa-01-…md`: SQL Server, con prefijo propio y cero añadidos al
  camino base.
- **Apéndices** `a01-…md` a `a10-…md`: de consulta y no de pedagogía. Laboratorio, `compose.yaml`, CLIs,
  el arnés de forma, la caja, Python y Java con sus drivers, el diccionario de traducción, el catálogo de
  errores, las licencias y, opcional, el Access de museo.
- **`soluciones/`**: un solucionario por cada documento con ejercicios, con el mismo nombre.
- **Documentos vivos**: [`bitacora-de-medicion.md`](bitacora-de-medicion.md) (las 78 mediciones, con su
  comando), [`a08-catalogo-de-errores.md`](a08-catalogo-de-errores.md) (102 errores con su mensaje literal)
  e [`INSTINTOS.md`](INSTINTOS.md) (los 30 puntos donde el instinto de desarrollador falla, con la medición
  que lo prueba). Leídos juntos, son el resumen del curso.
- **`src/`**: todo el código que se ejecuta, con su [README](src/README.md): el laboratorio
  (`src/lab/`, con el CLI `lab`, el `compose.yaml` y el generador de la caja), una carpeta por fase o
  apéndice que deja código, con el mismo nombre que su documento, y el entorno de Python fijado en
  `src/uv.lock`.

---

## 🗺️ Dónde encaja

- **La Ruta NoSQL Lite**, del mismo autor, afirma en su primera fase que *"la mayoría de las veces gana
  Postgres"*, y su trabajo es buscar los casos donde no alcanza. **Este curso es el que se gana esa
  frase**, desde el otro lado, con las mismas cinco preguntas.
- **El curso de Docker** del mismo autor es la infraestructura de laboratorio: aquí se dan recetas, y el
  mecanismo se explica allí.

---

## ⚖️ Lo que este curso promete al terminar

Que puedas mirar un esquema y decir *"esta tabla necesita esta restricción por esta razón, este índice
cuesta esto en cada escritura, este nivel de aislamiento deja pasar esta anomalía, y esta parte del
sistema no es relacional"*, con la medición delante. Y que, cuando la respuesta honesta sea *"esto no
hacía falta"*, lo digas igual: la [Fase 26](26-el-comite.md) cierra con el árbol de cuándo **no** usar
lo que el curso enseña.

---

## 📜 Licencia y ficción

Texto y código, bajo **CC BY-SA 4.0**. Los detalles, y las licencias de lo que el código baja al correr,
están en [`LICENSE.md`](LICENSE.md).

Laboratorio Alameda, la Clínica Mediterránea, la red Horizonte Salud y su gente son **inventados** para este
curso, y los datos de la caja son sintéticos: ningún paciente existe. Si un nombre se parece al de una
empresa o una persona reales, es coincidencia. Lo que sí es real son las fechas, las normas y el
comportamiento de los motores, cada uno con su fuente.
