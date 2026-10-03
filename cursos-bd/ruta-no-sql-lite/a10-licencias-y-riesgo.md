# 📎 Apéndice a10 — Licencias y riesgo

> **Curso:** Ruta NoSQL Lite · Consulta rápida · **1 h**
> **Usado por:** F03–F04, F05–F06, F09–F12, F17–F22 · **Versiones cubiertas:** las licencias de cada
> repositorio oficial, leídas el 29/09/2026
> **Fecha de verificación ejecutada:** 29/09/2026 (licencias leídas de los repositorios y de las
> webs de cada proyecto; no hay nada que ejecutar)

**Esto no es asesoría legal**, y conviene decirlo en la primera línea: este apéndice orienta la
conversación con quien sí sabe —el área legal o de compras de tu empresa—, no la sustituye. Lo que
sí hace es contestar la pregunta de un ingeniero: **¿puedo usar este motor para lo que quiero, y a
partir de qué momento el problema deja de ser técnico?**

**Qué queda fuera:** la interpretación jurídica de cada cláusula, y cualquier opinión sobre qué
licencia es mejor. Aquí se informa, no se milita.

---

## Índice

- [La tabla del curso](#-la-tabla-del-curso)
- [Cuatro familias de licencias, en lo que importa](#-cuatro-familias-de-licencias-en-lo-que-importa)
- [Por qué Valkey y no Redis](#-por-qué-valkey-y-no-redis)
- [Por qué OpenSearch y no Elasticsearch](#-por-qué-opensearch-y-no-elasticsearch)
- [Los tres casos de la sesión de laboratorio](#-los-tres-casos-de-la-sesión-de-laboratorio)
- [Qué preguntar, y a quién](#-qué-preguntar-y-a-quién)
- [Cuándo usar qué](#-cuándo-usar-qué) · [Referencias](#-referencias) · [Ejercicios](#-ejercicios-5)

---

## 🗂️ La tabla del curso

Lo que declara cada repositorio oficial el 29/09/2026. Las licencias cambian —varias de estas
cambiaron entre 2018 y 2025—, así que **antes de decidir, vuelve a leerla en su fuente**.

| Motor del curso | Licencia | Familia |
|---|---|---|
| PostgreSQL, pgvector | PostgreSQL License | permisiva |
| DuckDB | MIT | permisiva |
| Valkey | BSD 3-Clause | permisiva |
| OpenSearch | Apache 2.0 | permisiva |
| Qdrant | Apache 2.0 | permisiva |
| Cassandra | Apache 2.0 | permisiva |
| CouchDB (y PouchDB) | Apache 2.0 | permisiva |
| Neo4j Community | GPL v3 | copyleft |
| TimescaleDB | Apache 2.0 el núcleo; **Timescale License (TSL)** lo que está en `tsl/` | mixta: permisiva y *source-available* |
| MongoDB | **Server Side Public License (SSPL) v1** | *source-available* |
| CockroachDB | **CockroachDB Software License**, desde la 24.3 | *source-available*, con clave |

Y los que el curso **no** usa, pero aparecen en su historia: Redis 8 (RSALv2, SSPL o AGPLv3, a
elegir), Elasticsearch (AGPLv3, SSPL o Elastic License 2.0, a elegir) y ScyllaDB desde la 2025.1
(licencia propia, *source-available*).

---

## ⚖️ Cuatro familias de licencias, en lo que importa

**Permisivas** —MIT, BSD, Apache 2.0, la licencia de PostgreSQL—. Puedes usar, modificar, distribuir
y ofrecer como servicio, sin publicar tu código. Pides poco: conservar el aviso de copyright y, en
Apache, el de patentes. **Es la familia con la que casi ninguna empresa tiene problemas.**

**Copyleft** —GPL v3, la de Neo4j Community—. Si **distribuyes** el programa, modificado o enlazado
de cierta forma, tienes que distribuir el código bajo la misma licencia. Usarlo dentro de tu empresa,
o detrás de tu aplicación, no es distribuirlo. La pregunta que decide es qué cuenta como
distribución en tu caso.

**Copyleft de red** —AGPL v3—. Como la GPL, pero la obligación se dispara también cuando los usuarios
**interactúan con el programa modificado a través de la red**. Es la que Redis 8 y Elasticsearch
ofrecen hoy como opción, y es open source aprobada por la OSI. Muchas empresas tienen una política
propia sobre AGPL, y esa política decide antes que cualquier análisis técnico.

***Source-available*** —SSPL, Elastic License 2.0, TSL, la de CockroachDB, la de ScyllaDB—. El código
se puede leer, y el uso interno suele estar permitido, pero **hay algo que la licencia prohíbe o
condiciona**, casi siempre ofrecer el motor como servicio a terceros. No son licencias open source
según la OSI. Las tres cláusulas que más aparecen, citadas de su texto:

- **SSPL, sección 13** (MongoDB): *"If you make the functionality of the Program or a modified version
  available to third parties as a service, you must make the Service Source Code available via network
  download to everyone at no charge"*. El "código del servicio" incluye todo lo necesario para ofrecer
  ese servicio, y es lo que la hace tan amplia.
- **Elastic License 2.0** (Elasticsearch): *"You may not provide the software to third parties as a
  hosted or managed service, where the service provides users with access to any substantial set of
  the features or functionality of the software."*
- **Timescale License, sección 2.1**: permite el **uso interno** y los **productos o servicios de valor
  añadido**, siempre que el cliente no pueda *"defining, redefining, or modifying the database schema"*
  de la base que usa el servicio.

**BSL** (*Business Source License*) es una variante con fecha: el código es *source-available* hasta
una fecha de cambio, y a partir de ella pasa a una licencia open source. **Ningún motor del curso la usa
hoy**, pero aparece en muchos productos de infraestructura, y la pregunta que plantea es siempre la
misma: qué versión estás usando, y cuándo cambia.

> 🧭 **El momento en que el problema deja de ser técnico** es casi siempre el mismo: **cuando lo que
> construyes deja que terceros usen el motor**, directa o indirectamente. Un sistema interno de Cóndor
> sobre MongoDB no tiene ese problema. Un servicio que Cóndor vendiera a otros talleres, con la base
> expuesta, podría tenerlo. Ahí se llama a legal.

---

## 🔑 Por qué Valkey y no Redis

**La historia, por versiones.** Redis fue BSD hasta la versión 7.2, como dice su propio archivo de
licencia. Después pasó a una licencia dual *source-available* (RSALv2 y SSPL), y la comunidad hizo un
fork de la última versión BSD: **Valkey**, que hoy es un proyecto respaldado por la Linux Foundation, con licencia BSD 3-Clause.
**Desde Redis 8**, Redis ofrece además **AGPLv3** como tercera opción, que es open source aprobada por
la OSI.

**Por qué el curso sigue usando Valkey**, y el argumento ya no es *"libre contra no libre"*:

- **Permisiva contra copyleft de red.** Valkey es BSD: ninguna obligación al ofrecerlo como servicio.
  Redis 8, en su opción open source, es AGPLv3, con las obligaciones de red de la sección anterior y
  con las políticas internas que muchas empresas tienen sobre ella.
- **Un curso no debería depender de una decisión de licencia de un tercero** que ya cambió dos veces.
  Valkey, bajo una fundación, cambia por un proceso distinto.
- **Técnicamente, para lo que el curso enseña, son intercambiables**: el protocolo es el mismo, y el
  cliente del curso, `iovalkey`, habla con los dos ([`a06`](a06-lenguajes-y-drivers.md)).

---

## 🔍 Por qué OpenSearch y no Elasticsearch

Mismo patrón. Elasticsearch pasó de Apache 2.0 a una licencia dual *source-available* (SSPL y Elastic
License), y hubo un fork de la última versión Apache: **OpenSearch**, hoy bajo la **OpenSearch
Software Foundation**, un proyecto de la Linux Foundation, con licencia Apache 2.0. Hoy Elasticsearch
ofrece además **AGPLv3** como tercera opción, según su archivo de licencia.

La razón del curso es la misma que con Valkey: **permisiva contra copyleft de red**, y una fundación
detrás. Y la advertencia honesta: desde el fork, **OpenSearch y Elasticsearch son proyectos distintos**,
cada uno con sus versiones. El curso no los comparó, así que lo que mida en OpenSearch no se traslada
automáticamente a Elasticsearch.

---

## 🧪 Los tres casos de la sesión de laboratorio

La verificación del laboratorio (alcance §12, decisiones 16, 19 y 20) tropezó con tres licencias, y
cada una se resolvió de una forma distinta. Juntas son la mejor ilustración de que **la licencia es un
criterio de selección como cualquier otro**, con su costo y su beneficio.

**ScyllaDB: descartada.** Para columnar ancha, ScyllaDB ganaba a Cassandra en RAM (90 MiB contra 1,04
GiB en reposo) y en arranque. Pero desde la 2025.1 es *source-available*, gratis hasta 50 vCPU y 10 TB
por organización según su propia FAQ, y su última versión AGPL, la 6.2, quedó congelada. **Había una
alternativa Apache 2.0 —Cassandra— que no perdía contenido del curso**, y se eligió esa.

**TimescaleDB con TSL: aceptada y declarada.** Los roll-ups continuos y la compresión, el núcleo de la
Fase 09, están bajo la Timescale License, en la parte `tsl` del código; la imagen `-oss` no los trae.
**Aquí no había alternativa sin perder justo lo que se enseña**, así que se aceptó, con la cláusula
escrita arriba: el uso interno y los servicios de valor añadido están permitidos, siempre que el cliente
no pueda tocar el esquema. Para un sistema interno como el de Cóndor, no hay conflicto. La Fase 10 lo
usa como argumento: el particionado de Postgres no tiene esa restricción.

**CockroachDB: libre en un nodo y en `demo`, con clave en un clúster.** Desde la 24.3, CockroachDB
usa la CockroachDB Software License. Según su documentación de licencias: **un nodo solo
(`start-single-node`) y `cockroach demo` no necesitan clave y no se limitan**; un clúster de varios
nodos tiene 7 días de gracia y después queda **limitado a 5 transacciones concurrentes** sin clave. La
clave *Enterprise Free* es gratuita por debajo de 10 millones de dólares de facturación anual, se
renueva cada año y **exige telemetría**. El curso usa un nodo (F21) y `demo --global` (F22), y no
necesita ninguna clave.

**MongoDB con SSPL** no es un caso de la sesión, pero es el motor más usado del curso: para uso interno
—el de Cóndor, y el de las Fases 03 y 04— la sección 13 no se activa. Se activaría si Cóndor ofreciera
su base Mongo como servicio a terceros.

---

## ❓ Qué preguntar, y a quién

Antes de proponer un motor en una empresa, estas preguntas ahorran una reunión:

1. **¿Qué licencia tiene la versión exacta que voy a usar?** No la del producto en general: la de esa
   versión. *A quién:* al repositorio oficial, no a un blog.
2. **¿Mi uso es interno o expone el motor a terceros?** Una API que deja a clientes definir esquemas,
   o un servicio gestionado, cambian la respuesta. *A quién:* a tu propio diseño, y después a legal.
3. **¿Mi empresa tiene política sobre AGPL, SSPL o *source-available*?** Muchas la tienen, y decide
   antes que el análisis. *A quién:* al área legal o de compras.
4. **¿Hay un fork o una alternativa permisiva, y quién la mantiene?** Una fundación, una empresa, una
   persona: su continuidad no es la misma. *A quién:* al historial de versiones y a la gobernanza del
   proyecto.
5. **¿Qué pasa si la licencia cambia en la próxima versión?** Ya pasó con Redis, Elasticsearch,
   CockroachDB y ScyllaDB. *A quién:* a tu plan de salida (la escalera de
   [Fase 04](04-documental-romper-y-medir.md) §6 sirve también para esto).

---

## 🧭 Cuándo usar qué

| Situación | Lo que suele bastar | Cuándo llamar a legal |
|---|---|---|
| Sistema interno, motor permisivo | nada más que conservar avisos | nunca por licencia |
| Sistema interno, motor copyleft o *source-available* | leer la cláusula de servicio | si el sistema podría abrirse a terceros |
| Producto que se distribuye a clientes | revisar GPL y TSL (distribución) | siempre |
| Servicio que expone el motor a terceros | revisar SSPL, ELv2, TSL, AGPL | siempre, antes de diseñar |
| Clúster de CockroachDB en producción | presupuestar clave y telemetría | si la facturación pasa del umbral |

---

## 📚 Referencias

> ⚠️ Las licencias cambian con las versiones. Todo lo de este apéndice se leyó el 29/09/2026: vuelve a
> leerlo en la fuente antes de decidir.

- **SSPL de MongoDB** — https://github.com/mongodb/mongo/blob/master/LICENSE-Community.txt
- **Licencia de Redis** — https://github.com/redis/redis/blob/unstable/LICENSE.txt — la triple licencia
  desde Redis 8.
- **Valkey** — https://valkey.io/ — el fork BSD y su respaldo en la Linux Foundation.
- **Licencia de Elasticsearch** — https://github.com/elastic/elasticsearch/blob/main/LICENSE.txt
- **Elastic License 2.0** — https://www.elastic.co/licensing/elastic-license
- **OpenSearch Software Foundation** — https://opensearch.org/foundation/
- **Licencia de TimescaleDB** — https://github.com/timescale/timescaledb/blob/main/LICENSE — y la TSL en
  `tsl/LICENSE-TIMESCALE`.
- **Licencias de CockroachDB** — https://docs.cockroachlabs.com/docs/stable/licensing-faqs
- **FAQ de la licencia de ScyllaDB** — https://www.scylladb.com/source-available-faq/
- **Licencias aprobadas por la OSI** — https://opensource.org/licenses

---

## 🧪 Ejercicios (5)

### 🟢 Ejercicio 1 — La tabla, a mano

Elige tres motores de la tabla y lee la licencia en su repositorio oficial.

**Objetivo:** confirmar o corregir la tabla, con la fecha de tu lectura.

### 🟢 Ejercicio 2 — Interno o servicio

Clasifica: el sistema de mantenimiento de Cóndor; una API que Cóndor vende a otros talleres para
consultar su catálogo; un servicio donde cada taller cliente crea sus propias tablas.

**Pregunta:** ¿en cuál de los tres podría activarse la sección 13 de la SSPL si la base fuera Mongo? ¿Y
la TSL si fuera TimescaleDB?

### 🟡 Ejercicio 3 — Valkey o Redis 8

Un equipo propone Redis 8 con AGPLv3 en lugar de Valkey.

**Objetivo:** escribir en cinco líneas qué cambia para la empresa, sin decir que una opción es mejor que
la otra.

### 🟡 Ejercicio 4 — La licencia que cambió

Elige un motor de la tabla y rastrea en su historial cuándo cambió de licencia por última vez.

**Pregunta:** ¿qué versión quedó con la licencia anterior, y quién la mantiene hoy, si alguien lo hace?

### 🟠 Ejercicio 5 — El plan de salida

Cóndor usa TimescaleDB con TSL, y en la próxima versión la licencia cambia de forma que su uso deja de
estar permitido.

**Objetivo:** un plan de salida en tres pasos, usando la escalera de la Fase 04 y el triaje de la Fase 02.
¿Qué tabla de Cóndor migrarías primero, y a qué?

---

> 🏷️ **Este apéndice no lleva tag propio.** Se commitea con el prefijo de la fase desde la que se llegó;
> la primera es la Fase 05.
