# 📎 Apéndice bea-09 — Cassandra: la tentación y el acierto que nadie tuvo 🔴

> Tutorial Angular 8 — Laboratorio clínico · 🔥 Track BE · Consulta rápida · **4 horas** · 🔴 avanzado
> Usado por: be05 (ejercicio 🔴 adversarial), be08 (árbol de veredicto) · Versiones cubiertas: Apache Cassandra 4.1 y 5.0 (tags `4.1.12`, `5.0.9`, comprobados en el registro el 10/09/2026)

> ⚠️ **Aquí no se levanta nada.** No hay clúster que montar, ni contenedor que arrancar, ni `cqlsh` al que entrar. Se modela, se compara y se mide **sobre el papel**, contra el patrón de acceso real de LabCore que `be00` ya inventarió. Si esperabas un laboratorio, no lo hay, y es deliberado: la decisión que este apéndice enseña a tomar se toma antes de instalar nada.

**Esto no se lee de corrido.** Se entra cuando alguien propone cambiar de base de datos "porque escala", y se sale con números para contestar.

Resuelve una cosa: **demostrar con números que la alternativa de moda es peor aquí, y admitir con la misma honestidad dónde sí era la respuesta.**

Son dos mitades del mismo círculo y las dos son obligatorias. Quedarse con la primera convierte el apéndice en una defensa corporativa de MongoDB; quedarse con la segunda, en una queja. Juntas dicen algo que sirve.

---

## Índice

- [🔴 Parte 1 — La tentación](#-parte-1--la-tentación)
  - [Cómo se modela en Cassandra: la tabla se diseña por consulta](#cómo-se-modela-en-cassandra-la-tabla-se-diseña-por-consulta)
  - [El patrón de acceso real de LabCore](#el-patrón-de-acceso-real-de-labcore)
  - [La cuenta: cuántas tablas harían falta](#la-cuenta-cuántas-tablas-harían-falta)
  - [El argumento que zanja la discusión antes de llegar al rendimiento](#el-argumento-que-zanja-la-discusión-antes-de-llegar-al-rendimiento)
  - [Y las garantías: sería peor, no mejor](#y-las-garantías-sería-peor-no-mejor)
- [📝 Parte 2 — El acierto que nadie tuvo](#-parte-2--el-acierto-que-nadie-tuvo)
- [🧭 La regla que queda escrita](#-la-regla-que-queda-escrita)
- [🪦 Nota para el registro: RethinkDB](#-nota-para-el-registro-rethinkdb)
- [🧭 Cuándo usar qué](#-cuándo-usar-qué)
- [📚 Referencias](#-referencias)
- [🧪 Ejercicios](#-ejercicios-7)

---

## 🔴 Parte 1 — La tentación

La escena, que vas a vivir tarde o temprano con otro nombre:

> Llega un arquitecto nuevo, mira el sistema dos días, y propone: *"esto hay que llevarlo a Cassandra, que escala de verdad y no tiene estos problemas de consistencia"*.

No es una propuesta absurda. Cassandra es una base excelente, escala horizontalmente mejor que casi nada, no tiene un nodo primario que se convierta en cuello de botella, y su modelo de replicación multi-maestro resuelve problemas que a MongoDB le cuestan. Quien lo propone **no está equivocado sobre Cassandra**: está equivocado sobre LabCore, y demostrarlo requiere medir, no discutir.

### Cómo se modela en Cassandra: la tabla se diseña por consulta

La diferencia fundamental, y es la que decide todo lo demás:

> 🧭 **En un motor relacional modelas la verdad y las consultas se adaptan. En MongoDB modelas el agregado. En Cassandra modelas *la consulta*: una tabla por cada forma de pregunta que vayas a hacer.**

```sql
-- La clave primaria de Cassandra tiene dos partes y las dos mandan:
CREATE TABLE orders_by_patient (
    patient_id   int,          -- ← clave de PARTICIÓN: decide en qué nodo vive
    created_at   timestamp,    -- ← columna de AGRUPACIÓN: decide el orden dentro
    order_id     int,
    status       text,
    PRIMARY KEY ((patient_id), created_at)
) WITH CLUSTERING ORDER BY (created_at DESC);
```

De ahí salen las tres reglas que hacen a Cassandra rapidísima y rígida:

1. **Toda consulta eficiente lleva la clave de partición.** Sin ella, el motor no sabe a qué nodo preguntar y tiene que preguntarles a todos.
2. **No hay `JOIN`.** Ninguno. Si necesitas datos de dos sitios, los duplicas al escribir.
3. **No hay agregación ad-hoc sobre el clúster.** No hay un `$group` que recorra todo y te diga cuántas formas de documento hay. Ese tipo de pregunta —que es **la mitad de este track**— no se hace.

Y la señal de alarma que todo el mundo aprende a la mala:

```sql
SELECT * FROM orders WHERE status = 'pending' ALLOW FILTERING;
--                                              ^^^^^^^^^^^^^^
-- Cassandra te obliga a escribir eso para dejarte hacer una consulta que
-- recorre el clúster entero. No es una opción de rendimiento: es el motor
-- pidiéndote que firmes que sabes lo que estás haciendo. En producción,
-- ALLOW FILTERING en una consulta de pantalla es un incidente esperando.
```

### El patrón de acceso real de LabCore

Esto no se supone: está inventariado en `be00` §5.2, medido con la pestaña Network abierta. Las consultas que el frontend hace de verdad:

| # | Consulta | Frecuencia observada |
|---|---|---|
| 1 | **Todos** los pacientes | cada carga de `/patients` |
| 2 | Pacientes por `documentId` | por cada tecla del validador |
| 3 | Un paciente por `id` | al abrir una ficha |
| 4 | **Todas** las órdenes | cada carga de `/orders` |
| 5 | Órdenes por `patientId` | selector cruzado |
| 6 | Una orden por `id` | |
| 7 | Muestras por `orderId` | |
| 8 | Una muestra por `id` | |
| 9 | Resultados por `sampleId` | |
| 10 | **Todos** los rangos | cada pantalla de resultados |
| 11 | **Toda** la bitácora | cada `ngOnInit` de la timeline |
| 12 | Conteos por estado, para el dashboard | cada carga del dashboard |

### La cuenta: cuántas tablas harían falta

Una por forma de consulta, más las duplicaciones para mantenerlas sincronizadas:

| Tabla | Para qué | Clave de partición |
|---|---|---|
| `patients_by_id` | consulta 3 | `patient_id` |
| `patients_by_document` | consulta 2 | `document_id` |
| `patients_all` | consulta 1 | ⚠️ **no tiene clave natural** |
| `orders_by_id` | 6 | `order_id` |
| `orders_by_patient` | 5 | `patient_id` |
| `orders_all` | 4 | ⚠️ ídem |
| `samples_by_id` | 8 | `sample_id` |
| `samples_by_order` | 7 | `order_id` |
| `results_by_sample` | 9 | `sample_id` |
| `reference_ranges_all` | 10 | cabe en una partición: **aquí sí funciona** |
| `audit_by_entity` | parte de 11 | `(entity_type, entity_id)` |
| `audit_all` | 11 | ⚠️ ídem |
| `order_counts_by_status` | 12 | contadores mantenidos al escribir |

**Trece tablas para once endpoints.** Y con una consecuencia que no aparece en la tabla: **cada escritura toca varias de ellas**. Crear una orden escribe en `orders_by_id`, `orders_by_patient`, `orders_all` y el contador de estado — cuatro escrituras que el código de la aplicación tiene que mantener sincronizadas a mano, porque no hay nada que lo haga por ti.

> 🧠 **Y ahí está el primer número:** pasar de 5 colecciones a 13 tablas, con 4 escrituras por cada creación de orden en vez de 1. En un sistema **sin una sola prueba de regresión**, eso no es una migración: es una reescritura del acceso a datos completo, con una clase nueva de bug —la desincronización entre vistas— que hoy no existe.

### El argumento que zanja la discusión antes de llegar al rendimiento

Mira las tres filas marcadas con ⚠️. Son las consultas 1, 4 y 11: **"tráeme todo"**.

Y ahora recuerda por qué existen, que está medido en `be00` y declarado como deuda 💸 3: **el frontend de LabCore pagina, filtra y ordena en el navegador**, con la colección entera en memoria, porque el backend nunca expuso paginación.

> 🧠 **"Tráeme la tabla entera" es el anti-patrón fundacional de Cassandra.** No es que vaya lento: es que el motor está diseñado alrededor de la premisa de que nunca vas a hacer eso. Una consulta sin clave de partición pregunta a todos los nodos, junta los resultados en el coordinador, y escala **peor** cuantos más nodos tengas — que es exactamente lo contrario de lo que el arquitecto vino a vender.
>
> Así que la propuesta choca contra la única regla no negociable del track: **para que LabCore funcione sobre Cassandra hay que cambiar el frontend.** Y el frontend no se toca.

Esa frase termina la conversación, y conviene notar **por qué** la termina: no porque Cassandra sea mala, sino porque el patrón de acceso del cliente —que nadie puede cambiar— es incompatible con el modelo de acceso del producto. **Es exactamente el criterio del repositorio, aplicado en contra de la tecnología nueva en vez de a favor.**

### Y las garantías: sería peor, no mejor

El arquitecto dijo *"no tiene estos problemas de consistencia"*. Vale la pena comprobarlo, porque es la parte de la propuesta que suena más convincente y es la más falsa.

El invariante de `be05` necesita que tres escrituras pasen juntas: la muestra, la orden y el asiento. ¿Qué ofrece Cassandra?

| Mecanismo | Qué da | Para el invariante de LabCore |
|---|---|---|
| Escritura simple | Atómica **por partición** | Igual que Mongo: una fila, sí; tres tablas, no |
| `BATCH` registrado | **Atomicidad** eventual entre particiones | Sin **aislamiento**: otro lector ve estados intermedios |
| Transacción ligera (LWT) | *Compare-and-set* con Paxos | **Solo dentro de una partición**, y es caro |
| Consistencia ajustable | `ONE` / `QUORUM` / `ALL` por consulta | Es durabilidad, no atomicidad. Ver [`bea-07`](./bea-07-transacciones-replica-sets-y-el-standalone.md) §6 |

> 🧠 **Conclusión medible: la garantía que LabCore necesita y no tiene, en Cassandra tampoco la tendría — y encima perdería la que sí tiene.** Hoy, el `findAndModify` del contador de `be03` es atómico sobre un documento; en Cassandra, el equivalente es una transacción ligera con Paxos, que cuesta varias vueltas de red. Y la alternativa que MongoDB sí ofrece —convertir a replica set y usar transacciones multidocumento, dos días de trabajo— **en Cassandra no existe en absoluto**.
>
> La propuesta, examinada, empeora el problema que decía venir a resolver.

---

## 📝 Parte 2 — El acierto que nadie tuvo

Y ahora la otra mitad, que es la que hace honesto el apéndice.

**Hay un sitio en Laboratorios Andina donde Cassandra era exactamente la respuesta correcta. Y nadie la usó, porque nadie usó ninguna base de datos.**

Los analizadores de la sede central emiten telemetría continua: temperatura de la cámara, presión, estado de los reactivos, ciclos completados, códigos de error. Decenas de miles de lecturas por hora, veinticuatro horas al día, desde 2019.

Mira la forma de ese dato:

| Propiedad | La telemetría | El dominio de LabCore |
|---|---|---|
| Volumen | Enorme y creciente | Modesto |
| Escrituras | Masivas, continuas | Pocas, humanas |
| Actualizaciones | **Ninguna.** Una lectura no se corrige | Constantes |
| Borrados | Por antigüedad | Nunca (baja lógica) |
| Consultas | Por aparato y **rango de tiempo** | Por identificador, y "tráeme todo" |
| Consistencia | Perder una lectura no rompe nada | Perder un asiento es un hallazgo |

Cada fila es lo contrario de la anterior. **Son dos dominios distintos que llevan siete años dentro del mismo sistema conceptual**, y a uno de ellos nadie le prestó atención.

```sql
-- Y así de simple se modela, porque la consulta es una sola:
-- "las lecturas del analizador X entre dos instantes".
CREATE TABLE analyzer_telemetry (
    analyzer_id  text,
    day          date,        -- ← partición por aparato Y día, para que
    ts           timestamp,   --    ninguna partición crezca sin techo
    metric       text,
    value        double,
    PRIMARY KEY ((analyzer_id, day), ts, metric)
) WITH CLUSTERING ORDER BY (ts DESC)
  AND default_time_to_live = 31536000;   -- ← un año, y se borra solo
```

Por qué aquí gana, punto por punto:

- **Una sola forma de consulta**, que es justo lo que el modelo pide.
- **Escritura masiva sin coordinación**: es en lo que Cassandra es mejor que casi todo.
- **La partición compuesta `(aparato, día)`** evita el problema de la partición que crece sin techo, que es el error clásico de las series temporales.
- **TTL nativo por fila.** El dato caduca solo, sin un proceso de limpieza. Y aquí sí es legítimo: **esto no es evidencia**, es telemetría operativa, a diferencia de lo que pasa con el audit log en [`bea-05`](./bea-05-indices-y-explain-en-mongodb.md).
- **Y ninguna actualización**, que es la condición bajo la cual el modelo de Cassandra brilla y la que LabCore no cumple en ninguna otra parte.

**¿Y dónde está hoy ese dato?** En ninguna base. Está en los logs propios de cada aparato, en archivos que alguien copia a una carpeta compartida cuando el proveedor lo pide, y se pierde cuando el disco del analizador se llena. Nadie puede contestar *"¿la cámara del analizador 2 estuvo fuera de rango la semana que salieron aquellos resultados raros?"*, y esa es una pregunta de calidad clínica de primer orden.

> 🧠 **No era mala la tecnología: estaba en el módulo equivocado.** El arquitecto que propuso Cassandra tenía razón sobre la herramienta y se equivocó de sitio por completo. Y lo más incómodo del apéndice es que **el sitio correcto estaba vacío**: no había que sustituir nada, había que empezar algo que nadie empezó.
>
> Ese patrón —*la tecnología adecuada, aplicada al módulo equivocado, mientras el módulo que la necesitaba no tenía nada*— es mucho más común que elegir mal, y casi nadie lo enseña.

---

## 🧭 La regla que queda escrita

> **El modelo de acceso manda sobre el producto.** No se elige base de datos: se identifica qué forma tiene el acceso a cada parte del dominio, y eso decide. Y admite **respuestas distintas dentro del mismo sistema**, que es lo que casi nadie se permite.

Aplicada a Laboratorios Andina, la respuesta honesta de todo el track cabe en tres líneas:

| Parte del dominio | Modelo de acceso | Qué le venía bien |
|---|---|---|
| El **panel de resultados** | Documental: formas heterogéneas, se lee entero | **MongoDB.** El equipo de 2019 acertó |
| **Pacientes, órdenes, custodias, rangos** | Relacional: entidades con integridad que a alguien le importa | Un motor relacional. Se generalizó desde el acierto anterior, y ese es el error del track |
| La **telemetría del analizador** | Serie temporal: escritura masiva, lectura por rango, sin actualizaciones | **Cassandra.** Y no se usó nada |

Tres modelos de acceso, tres respuestas distintas, un solo sistema. **Cada familia gana en algún sitio**, y el error de 2019 no fue elegir Mongo: fue creer que la pregunta tenía una sola respuesta.

---

## 🪦 Nota para el registro: RethinkDB

Una historia corta que hay que conocer antes de opinar sobre elegir bases de datos.

RethinkDB era, en 2015, técnicamente excelente: un motor de documentos con consultas en tiempo real —*changefeeds*— que se adelantó años a lo que después fueron los *change streams* de MongoDB. La gente que lo usaba lo adoraba. Elegirlo era una decisión **técnicamente correcta**, defendible en cualquier revisión de arquitectura.

La empresa cerró en **octubre de 2016**, después de ocho años y 12,2 millones de dólares de inversión, sin encontrar un modelo de negocio. En **febrero de 2017** la CNCF compró los activos de propiedad intelectual por 25.000 dólares, relicenció el código de AGPLv3 a **Apache 2.0** y lo donó a la Linux Foundation. El proyecto sobrevive; la empresa detrás, no.

> 🧠 **Elegiste bien y perdiste igual.** Es una lección de seniority que casi nadie enseña, y no tiene moraleja cómoda: no hay una evaluación técnica que te hubiera salvado, porque lo que falló no era técnico. Lo único que se puede hacer es **contar esa clase de riesgo como lo que es** —el riesgo de que quien sostiene la herramienta deje de sostenerla— y ponerlo en la misma tabla que el rendimiento y las garantías, no en una conversación aparte.
>
> Es la misma familia de riesgos que [`bea-10`](./bea-10-riesgo-de-licencia-sspl.md) desarrolla con las licencias. Con una diferencia que consuela poco: el de RethinkDB acabó bien para los que ya lo usaban.

---

## 🧭 Cuándo usar qué

Una tabla de familias, que es lo que este apéndice deja de verdad.

| Si tu acceso es… | Familia | Y su precio |
|---|---|---|
| Entidades con integridad que a alguien le importa | **Relacional** | Rigidez de esquema, y un DBA entre tú y una columna nueva |
| Documentos heterogéneos leídos enteros | **Documental** | Nadie garantiza la integridad. Ver `be02` |
| Serie temporal, escritura masiva, sin actualizar | **Columnar ancha** (Cassandra) | Una tabla por consulta, y nada de "tráeme todo" |
| Clave-valor con latencia mínima | **Clave-valor en memoria** | Es una caché, no un almacén primario |
| Relaciones profundas y recorridos | **Grafo** | Escala peor, y casi nunca es el problema que crees tener |
| **Varias de las anteriores en el mismo sistema** | **Varias.** Es legítimo | Operar dos motores cuesta, y hay que contarlo |

Y la pregunta que se hace **antes** de mirar esa tabla, que es la que este track entrena:

> ⚖️ *¿Cuánto le queda a este sistema?* Con diez años por delante, la respuesta correcta es la de la tabla. Con dos, la respuesta correcta es casi siempre **quedarse donde estás y contener**, y eso es lo que `be08` termina escribiendo.

---

## 📚 Referencias

- Apache Cassandra — documentación de modelado de datos, con la regla de "una tabla por consulta": https://cassandra.apache.org/doc/latest/cassandra/developing/data-modeling/index.html
- Claves de partición y de agrupación: https://cassandra.apache.org/doc/latest/cassandra/developing/cql/ddl.html
- `ALLOW FILTERING` y por qué existe: https://cassandra.apache.org/doc/latest/cassandra/developing/cql/dml.html
- Transacciones ligeras (LWT) y `BATCH`, con sus límites de atomicidad y aislamiento: https://cassandra.apache.org/doc/latest/cassandra/developing/cql/dml.html#batch
- Niveles de consistencia ajustables: https://cassandra.apache.org/doc/latest/cassandra/architecture/dynamo.html
- Jeff Carpenter y Eben Hewitt, *Cassandra: The Definitive Guide*, 3ª ed. (2020) — los capítulos 4 y 5 son el modelado dirigido por consultas, que es lo que decide la parte 1.
- Martin Kleppmann, *Designing Data-Intensive Applications* (2017), capítulos 2 y 3 — modelos de datos y motores de almacenamiento. Es la comparación entre familias mejor escrita que existe.
- CNCF — la compra y relicencia de RethinkDB, febrero de 2017: https://www.cncf.io/blog/2017/02/06/cncf-purchases-rethinkdb-source-code-contributes-linux-foundation-apache-license/
- LWN — *RethinkDB source relicensed, donated to the Linux Foundation*: https://lwn.net/Articles/713716/

> ⚠️ URLs y contenidos cambian; verifícalos. Y las versiones de Cassandra de la cabecera se comprobaron contra el registro el 10/09/2026: compruébalas tú también si vas a citarlas, aunque en este apéndice no se instale nada.

---

## 🧪 Ejercicios (7)

Ninguno requiere instalar Cassandra. Todos son de modelado, comparación y medición sobre el papel.

1. Toma el inventario de peticiones de `be00` §5.2 —el tuyo, el que capturaste— y escribe la tabla de Cassandra que serviría cada una. Cuenta cuántas te salen.
2. Para cada una de las cinco entidades, escribe qué escrituras haría falta hacer al crear un documento. Anota el número total y compáralo con el que hace LabCore hoy.
3. Marca en tu lista del ejercicio 1 las consultas que son "tráeme todo". Explica en tres líneas por qué esas tres deciden la discusión antes que ninguna medición de rendimiento.
4. **Diagnóstico.** Escribe el invariante de `be05` —muestra, orden y asiento— como operaciones de Cassandra. Decide qué garantía obtendrías con un `BATCH` registrado y cuál con una transacción ligera. Compara con lo que tienes hoy en un `mongod` suelto y con lo que tendrías con un replica set.
5. Modela la telemetría del analizador con clave de partición compuesta y TTL. Calcula, con cifras plausibles (lecturas por hora × aparatos × un año), cuántas filas serían y cuánto ocuparían. Ese número es la mitad del argumento de la parte 2.
6. **Escritura.** Redacta la respuesta de una página al arquitecto de la Parte 1. Tiene que reconocer lo que su propuesta tiene de razonable, presentar los números de los ejercicios 1 a 4, y terminar proponiéndole el sitio donde **sí** tendría razón. Sin condescendencia: es un compañero, no un adversario.
7. **Adversarial.** Ahora defiende la posición contraria lo mejor que puedas: *"con Cassandra, LabCore nunca habría tenido el problema de la transacción de `be05`, porque el diseño te obliga a resolverlo en la modelación"*. Es un argumento fuerte y en parte cierto. Después refútalo — o concédelo, si al escribirlo te convence, y explica qué cambia eso en el veredicto de `be08`.

---

> 🏷️ **Este apéndice no lleva tag propio**, y en su caso ni siquiera hay código que commitear: no se escribe una línea de producción. Lo que salga de leerlo —el documento del ejercicio 6, sobre todo— se commitea con el prefijo de la fase desde la que llegaste (`be05: …`, `be08: …`) y acaba citado en el árbol de veredicto de `IRRECOVERABLE.md`. La convención completa está en [`00-convencion-de-git-y-tags.md`](./00-convencion-de-git-y-tags.md) §10.
