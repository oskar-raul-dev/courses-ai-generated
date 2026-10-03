# 🗄️ Gestores SQL

> 📝 **Estado: plan tentativo.** Nada de esto es contenido todavía. Este documento fija el reparto entre
> cursos, el esqueleto común y lo que hace distinto a cada motor, para discutirlo antes de escribir la
> guía de estilo y el `0-ESTRUCTURA-CURSO.md` de cada uno.

Esta familia agrupa siete cursos independientes: uno de teoría y seis de motor. Cada curso de motor
se puede leer sin haber leído los otros, aunque eso implique repetir material. Lo que buscan es que el
lector *domine* un motor concreto: que tome decisiones de diseño con fundamento, lo afine con
mediciones y saque partido de su programación y de sus herramientas.

| Curso | Motor de referencia | Para quién |
|---|---|---|
| `01-bases` | ninguno; RelaX y SQLite (`STRICT`) para verificar | quien quiere la teoría de libro de texto que sostiene a todos los demás |
| `02-postgresql` | PostgreSQL 18 | quien trabaja, o va a trabajar, con Postgres |
| `03-mysql` | MySQL 8.4 LTS | el mundo LAMP, SaaS heredados y hosting compartido |
| `04-mariadb` | MariaDB 11.8 LTS | distribuciones Linux, Galera y el ecosistema que divergió de MySQL |
| `05-sqlite` | SQLite 3.5x | apps móviles, de escritorio y edge, y pruebas |
| `06-sql-server` | SQL Server 2025 | shops .NET, ERP corporativos y el stack de datos de Microsoft |
| `07-oracle` | Oracle AI Database 26ai Free | banca, gobierno, telcos y ERP grandes; el motor con más historia en la empresa |

> 🧭 **Relación con `ruta-sql`.** La ruta SQL enseña a *elegir* entre motores, comparándolos con un
> mismo harness. Estos cursos enseñan a *dominar* el motor que ya elegiste o que te tocó. Cuando un
> tema es esencialmente comparativo, el curso de motor remite a la ruta en vez de repetirla. Cada
> guía de estilo deberá declarar de forma explícita que se aparta del principio del repo de "modelos
> de acceso, no productos": aquí el producto *es* el objeto de estudio.

## 🧱 El bloque común de los cursos de motor

Los seis cursos de motor comparten un esqueleto. Así se recorren todos de la misma manera, aunque
cada motor rellena los bloques con lo suyo y algunos los reemplazan (SQLite no tiene servidor que
administrar). Cada bloque abre con una **prueba de nivel**: una lista corta de cosas que, si ya sabes
hacer, te permiten saltar al bloque siguiente sin perder el hilo. Así el lector que viene de cero
empieza por el bloque 0 y el que ya usa el motor en producción entra directo en internals o tuning.

| Bloque | Contenido común | Saltable si… |
|---|---|---|
| **0 · Arranque** | instalación en Windows, Linux, macOS y contenedor; cliente de línea de comandos y uno gráfico; primer esquema | ya tienes el motor corriendo y te mueves en su CLI |
| **I · Fundamentos** | DDL y DML con el dialecto del motor; restricciones; transacciones explícitas | escribes `CREATE`, `ALTER`, `INSERT … ON CONFLICT`/`UPSERT` sin mirar la documentación |
| **II · Datos y tablas** | el sistema de tipos del motor en detalle; columnas generadas; particionado; JSON; fechas y zonas horarias; colaciones | sabes qué tipo elegir para dinero, fechas, identificadores y texto, y por qué |
| **III · Consultas** | funciones nativas; subconsultas y correlación; CTE y recursión; funciones de ventana; lo propio del dialecto | resuelves top-N por grupo, jerarquías y acumulados sin pensar mucho |
| **IV · Programación** | procedimientos, funciones, triggers, manejo de errores; lenguajes alternativos donde los hay | ya mantuviste lógica en la base y conoces sus costos |
| **V · Administración** | usuarios, roles y permisos; seguridad a nivel de fila; respaldos y restauración; replicación y alta disponibilidad; monitoreo | administraste una instancia con respaldos probados |
| **VI · Internals** | almacenamiento en disco; las estructuras de índice que implementa el motor (la teoría está en `01-bases`, aquí se mide); concurrencia (MVCC o locks); bitácora (WAL, redo, undo); el planificador | sabes explicar por qué una consulta usa o no un índice |
| **VII · Tuning** | lectura de planes; estadísticas; configuración de memoria e I/O; consultas patológicas; herramientas de diagnóstico | — (es el destino del curso) |
| **VIII · Ecosistema** | extensiones, herramientas de terceros, conectores e integración con el resto de la plataforma | — |
| **⚖️ Veredicto** | cuándo *no* usar este motor, y hacia dónde ir en ese caso | — |

## 📚 `01-bases` — teoría de bases de datos

Un curso de teoría en la línea de los textos clásicos: Elmasri y Navathe (*Fundamentals of Database
Systems*) como columna vertebral, con Silberschatz, Korth y Sudarshan (*Database System Concepts*),
Garcia-Molina, Ullman y Widom (*Database Systems: The Complete Book*) y Date (*An Introduction to
Database Systems*) como referencias de apoyo. No enseña ningún motor: enseña lo que todos los motores
implementan, con el rigor y la densidad de ejercicios de un curso universitario.

> 📝 **Divergencia declarada.** Este curso se aparta de tres defaults del repo: no tiene benchmarks
> (es teoría, se demuestra en papel), no sigue la forma de lección "setup → conceptos →
> anti-patrones" sino la de capítulo de libro de texto, y **sube** la cantidad de ejercicios en vez
> de bajarla. La guía de estilo del curso lo dejará escrito.

**Los ejercicios son el centro del curso.** Cada capítulo cierra con una batería larga y graduada,
como los ejercicios de fin de capítulo de Navathe: muchos de lápiz y papel (expresiones de álgebra,
cálculo de clausuras, descomposiciones, grafos de precedencia, inserciones en un árbol B+ paso a
paso), cada uno con su solución desarrollada, no solo el resultado. Para verificar se usan dos
herramientas: [RelaX](https://dbis-uibk.github.io/relax/) para ejecutar álgebra relacional y SQLite
con tablas `STRICT` para contrastar con SQL. `STRICT` evita que el sistema de tipos flexible de
SQLite contradiga la teoría de dominios. Donde SQL se aparta del modelo (multiconjuntos en vez de
conjuntos, `NULL` y la lógica de tres valores), el curso lo dice.

### Parte I · Fundamentos y modelado

- **El DBMS:** qué resuelve frente a archivos sueltos; arquitectura ANSI/SPARC de tres niveles; independencia lógica y física; catálogo; componentes de un DBMS; historia de los modelos (jerárquico, de red, relacional y lo que vino después).
- **Modelo ER y EER:** entidades, atributos (compuestos, multivaluados, derivados), relaciones y sus restricciones de cardinalidad y participación; entidades débiles; especialización, generalización, categorías; notaciones (Chen, pata de gallo, UML).
- **Del modelo conceptual al relacional:** el algoritmo de mapeo ER/EER paso a paso.

### Parte II · El modelo relacional y sus lenguajes

- **Modelo relacional:** relaciones, tuplas, dominios; superclaves, claves candidatas, primarias y foráneas; integridad de entidad y referencial; las reglas de Codd.
- **Álgebra relacional:** selección, proyección, renombre, unión, intersección, diferencia, producto; join theta, equijoin, natural, semijoin y antijoin, outer joins; división; agregación y agrupamiento; operadores extendidos.
- **Cálculo relacional:** de tuplas y de dominios; cuantificadores; seguridad de expresiones; equivalencia con el álgebra.
- **SQL a la luz de la teoría:** traducción de álgebra a SQL y de SQL a álgebra; multiconjuntos, `NULL` y lógica de tres valores; subconsultas correlacionadas como cálculo.

### Parte III · Diseño y normalización

- **Dependencias funcionales:** axiomas de Armstrong y reglas derivadas; clausura de atributos y de conjuntos de dependencias; equivalencia; recubrimiento mínimo; cálculo de claves candidatas.
- **Formas normales:** 1FN, 2FN, 3FN y FNBC, con su definición formal y sus anomalías; dependencias multivaluadas y 4FN; dependencias de join y 5FN; DKNF.
- **Algoritmos de diseño:** síntesis a 3FN; descomposición a FNBC; prueba de join sin pérdida (método de la tabla, o *chase*); preservación de dependencias y por qué a veces no se puede tener todo.
- **Desnormalización:** cuándo y con qué costo, en teoría (los cursos de motor lo miden).

### Parte IV · Almacenamiento e índices

Aquí vive la **teoría** de las estructuras de acceso. Cada curso de motor la retoma en su bloque VI y
la aterriza en lo que ese motor implementa de verdad, con mediciones.

- **Almacenamiento físico:** jerarquía de memoria, bloques y páginas, registros de longitud fija y variable, organización de archivos (heap, ordenado, hash), buffer pool y políticas de reemplazo.
- **Hashing:** estático, extensible y lineal; manejo de desbordes.
- **Índices de un nivel y multinivel:** primarios, de agrupamiento (clustering) y secundarios; densos y dispersos.
- **Árboles B y B+:** orden, ocupación, búsqueda, inserción con división y borrado con fusión, paso a paso; cálculo de altura y de accesos a disco; carga masiva (bulk loading).
- **Otras estructuras:** listas invertidas (índices de texto completo y archivos invertidos), índices bitmap y su compresión, árboles R para datos espaciales, árboles LSM, índices de varias claves y de cuadrícula.
- **Costo de las estructuras:** qué cuesta mantener cada índice en escrituras, y por qué ninguno es gratis.

### Parte V · Procesamiento y optimización de consultas

- **Algoritmos:** ordenamiento externo; selección con y sin índice; joins (nested loop, block nested loop, index nested loop, sort-merge, hash join); proyección y eliminación de duplicados; agregación.
- **Optimización heurística:** árboles de consulta, reglas de equivalencia del álgebra, empujar selecciones y proyecciones.
- **Optimización basada en costo:** estadísticas del catálogo, selectividad y estimación de cardinalidad, orden de los joins y programación dinámica.

### Parte VI · Transacciones, concurrencia y recuperación

- **Transacciones:** ACID; planes (schedules); serializabilidad por conflicto y por vistas; grafo de precedencia; planes recuperables, sin aborto en cascada y estrictos.
- **Control de concurrencia:** bloqueo en dos fases (básico, conservador, estricto, riguroso); deadlocks (prevención, detección, wait-die y wound-wait); ordenamiento por marcas de tiempo; MVCC; validación optimista; granularidad múltiple.
- **Aislamiento:** anomalías y niveles de SQL; snapshot isolation y su anomalía de *write skew*.
- **Recuperación:** bitácora y WAL; actualización diferida e inmediata; checkpoints; shadow paging; ARIES.

### Parte VII · Más allá del núcleo (panorama)

Un capítulo corto de orientación, sin la profundidad de los anteriores: bases distribuidas
(fragmentación, replicación, commit en dos fases), el teorema CAP y por qué existen las familias
NoSQL, con remisión a la Ruta NoSQL para quien quiera seguir.

## 🐘 `02-postgresql`

Postgres es el motor más extensible del grupo, y el curso se apoya en eso: buena parte de lo
característico no está en el núcleo sino en lo que se le enchufa.

- **Programación en varios lenguajes:** PL/pgSQL como base, y procedimientos en PL/Python (`plpython3u`), PL/Perl, PL/Tcl, PL/v8 (JavaScript) y PL/Rust; lenguajes confiables contra no confiables y lo que eso implica para la seguridad.
- **Sistema de tipos rico:** dominios, tipos compuestos y enumerados, rangos y multirangos, arreglos, `jsonb`, tipos de red; restricciones de exclusión (por ejemplo, reservas que no se solapan).
- **Familia de índices:** B-tree, hash, GIN, GiST, SP-GiST y BRIN; índices parciales, de expresión y de cobertura (`INCLUDE`); skip scan en B-tree (nuevo en la 18).
- **Extensiones:** PostGIS, pgvector, pg_stat_statements, pg_cron, pg_partman, TimescaleDB, Citus; cómo se escribe una extensión propia.
- **Datos externos:** foreign data wrappers (`postgres_fdw`, `file_fdw`) para consultar otras bases o archivos como si fueran tablas.
- **Mensajería y eventos:** `LISTEN`/`NOTIFY`, colas con `SKIP LOCKED`, replicación lógica y decodificación lógica para CDC.
- **Internals:** MVCC con tuplas versionadas en el heap, `VACUUM` y bloat, TOAST, WAL, I/O asíncrono (nuevo en la 18).
- **Seguridad:** roles, `GRANT` a nivel de columna, Row-Level Security.
- **Ecosistema operativo:** `psql`, `pgbench`, `pg_dump`/`pg_restore`, `pg_basebackup`, pgBackRest, PgBouncer, Patroni; `EXPLAIN (ANALYZE, BUFFERS)` y `auto_explain`.

## 🐬 `03-mysql`

MySQL se entiende desde InnoDB: casi todas las decisiones de diseño y de tuning nacen de que la
tabla *es* su índice primario.

- **InnoDB por dentro:** índice clustered y sus consecuencias (el caso de las PK UUID), índices secundarios que apuntan a la PK, buffer pool, redo y undo, doublewrite buffer.
- **Concurrencia:** `REPEATABLE READ` por defecto, gap locks y next-key locks, deadlocks típicos.
- **Dialecto y modos:** `sql_mode` y lo que deja pasar; `utf8mb4` y colaciones; `ON DUPLICATE KEY UPDATE`.
- **Esquema en caliente:** DDL instantáneo y en línea; gh-ost y `pt-online-schema-change` cuando no alcanza.
- **JSON e índices modernos:** índices multivalor sobre arreglos JSON, índices funcionales, índices invisibles, histogramas.
- **Programación:** procedimientos, funciones, triggers y eventos programados en SQL; los programas en JavaScript existen pero solo en Enterprise y HeatWave.
- **Replicación y alta disponibilidad:** binlog y sus formatos, GTID, Group Replication, InnoDB Cluster, MySQL Router; plugin Clone.
- **Herramientas:** MySQL Shell (con modos JS y Python), Performance Schema y esquema `sys`, `EXPLAIN ANALYZE`, Percona Toolkit, XtraBackup.
- **LTS contra Innovation:** qué trae la serie 9.x (tipo `VECTOR`, entre otros) y por qué el curso se fija en la 8.4.

## 🦭 `04-mariadb`

Comparte con MySQL las raíces y buena parte del dialecto, pero hoy es otro motor. El curso es
independiente: repite lo común y pone el peso en lo que divergió.

- **Motores de almacenamiento enchufables:** InnoDB, Aria, MyRocks (LSM), ColumnStore (analítico columnar), Spider (sharding), S3 (tablas archivadas en almacenamiento de objetos) y CONNECT (CSV, ODBC y otras fuentes externas como tablas).
- **Datos temporales:** tablas versionadas por sistema (`AS OF`), períodos de aplicación y bitemporalidad.
- **Dialecto propio:** secuencias, `RETURNING` en `INSERT` y `DELETE`, `INTERSECT`/`EXCEPT`, tipos `UUID` e `INET6`; modo de compatibilidad con Oracle (`sql_mode=ORACLE`) para migrar PL/SQL.
- **Vectores:** MariaDB Vector, con índices HNSW nativos.
- **Optimizador:** el modelo de costo rehecho en la serie 11 y en qué se aparta del de MySQL.
- **Alta disponibilidad:** Galera Cluster (multi-primario síncrono) y MaxScale como proxy (ojo con su licencia BSL).
- **Operación:** thread pool incluido en la versión comunitaria, `mariadb-backup`.
- **Dónde se separa de MySQL:** un diccionario en ambas direcciones para quien llega desde MySQL o tiene que volver.

## 🪶 `05-sqlite`

No hay servidor, usuarios ni red, así que el bloque V se reemplaza por lo que sí importa en un
motor embebido: el archivo, la concurrencia dentro del proceso y la integración con el lenguaje que
lo hospeda.

- **El modelo embebido:** una biblioteca y un archivo; cuándo esto es una ventaja (móvil, escritorio, edge, pruebas) y cuándo una trampa.
- **Tipos:** afinidad de tipos, tablas `STRICT`, `WITHOUT ROWID`, columnas generadas.
- **Concurrencia:** modos de journal, WAL, un solo escritor, `busy_timeout`, `BEGIN IMMEDIATE`.
- **Programación en el lenguaje anfitrión:** funciones, agregados y colaciones definidos por la aplicación (Python, Go, C); tablas virtuales; extensiones cargables.
- **Extensiones incluidas:** FTS5 para búsqueda de texto, R*Tree para datos espaciales, JSON y JSONB; sqlite-vec para vectores.
- **Configuración:** los `PRAGMA` que importan; `VACUUM` y `auto_vacuum`; caché de páginas y `mmap`.
- **Diagnóstico:** `EXPLAIN QUERY PLAN`, `.expert`, `ANALYZE`, `sqlite3_analyzer`.
- **Seguridad sin usuarios:** permisos del sistema de archivos, SQLCipher.
- **SQLite en red y replicado:** Litestream, LiteFS, libSQL/Turso; hasta dónde se puede estirar antes de que convenga un servidor.

## 💸 Motores comerciales: solo lo que se puede explorar gratis

`06-sql-server` y `07-oracle` enseñan **solo lo que el lector puede ejecutar con una edición gratuita**.
Si una función exige una edición de pago, una opción con licencia aparte o un servicio en la nube
con costo, queda fuera del temario. A lo sumo se menciona en una línea para que el lector sepa que
existe. Cada tema se valida contra la licencia de la edición gratuita antes de escribirlo, no contra
la documentación general del producto.

**Benchmarks en privado.** Las licencias de ambos motores prohíben publicar resultados de benchmark
sin permiso. Por eso estos dos cursos **no publican benchmarks**: entregan el harness y la receta, y
cada estudiante los ejecuta en su máquina. Los resultados se quedan fuera del repositorio (en un
directorio ignorado por git) y no se citan en el material. Esto reemplaza tanto el `BENCHMARKS.md`
que pide el `CLAUDE.md` como la "apuesta falsable" de `ruta-sql`, y las guías de estilo de ambos
cursos lo declararán como divergencia.

## 🪟 `06-sql-server`

SQL Server es el motor del grupo más metido en una plataforma de datos completa. El curso aprovecha
esa integración en vez de tratarlo como un motor aislado. El laboratorio usa la edición **Developer**
(todas las funciones, gratis para desarrollo y pruebas, no para producción) y menciona **Express**
como la gratuita que sí se puede usar en producción, con sus límites.

- **T-SQL** como lenguaje de programación completo: variables, control de flujo, `TRY…CATCH`, tablas temporales y variables de tabla, `MERGE`.
- **Otros lenguajes dentro del motor:** integración CLR para procedimientos en .NET; Machine Learning Services para Python y R (⚠️ verificar su disponibilidad en la 2025 y en Linux).
- **Stack de datos de Microsoft:** SSIS para ETL, SSRS para reportes y SSAS para modelos analíticos, incluidos en la edición Developer pero solo en Windows; consumo desde Power BI Desktop (gratis). El espejado hacia Microsoft Fabric queda fuera porque requiere capacidad de pago.
- **Virtualización y captura de cambios:** PolyBase para consultar Parquet, CSV y S3 como tablas; linked servers; Change Data Capture y Change Tracking; Change Event Streaming (nuevo en la 2025).
- **Novedades de la 2025:** tipo `VECTOR` e índices DiskANN, tipo JSON nativo, funciones de expresiones regulares, `sp_invoke_external_rest_endpoint`, optimized locking.
- **Almacenamiento y rendimiento:** índices columnstore, In-Memory OLTP, tablas temporales e historial.
- **Concurrencia:** el modelo pesimista por defecto contra RCSI y snapshot isolation.
- **Tuning:** Query Store, Intelligent Query Processing, *parameter sniffing*, planes forzados.
- **Seguridad:** Always Encrypted, Row-Level Security, enmascaramiento dinámico, tablas ledger.
- **Operación:** SQL Server Agent; Always On Availability Groups armados con varios contenedores; SSMS, `sqlcmd` y la extensión de VS Code (Azure Data Studio está retirado).
- ⚠️ **Laboratorio:** la imagen de contenedor es solo x86-64. En Macs con Apple Silicon corre emulada, y eso hay que verificarlo antes de prometerlo.

## 🏛️ `07-oracle`

Oracle es el motor con más superficie del grupo, y también el que más cuesta separar del producto
comercial. El laboratorio usa **Oracle AI Database 26ai Free** (sucesora de la 23ai Free) en
contenedor, y el temario se recorta a lo que esa edición permite: limita CPU, memoria y volumen de
datos, y no todas las opciones y packs de Enterprise vienen incluidos. ⚠️ Antes de escribir cada
bloque hay que verificar en la licencia de la edición Free qué está incluido; lo que no lo esté, sale.

- **PL/SQL a fondo:** paquetes, tipos y colecciones, `BULK COLLECT` y `FORALL`, cursores, excepciones, transacciones autónomas, SQL dinámico; SQL Macros.
- **Otros lenguajes dentro del motor:** procedimientos en Java con la JVM embebida (OJVM) y en JavaScript con el Multilingual Engine (MLE, desde la 23ai).
- **Arquitectura propia:** instancia contra base de datos; multitenant con CDB y PDB; tablespaces y archivos de datos; esquema igual a usuario; SGA y PGA.
- **Concurrencia y consistencia:** lectura consistente con segmentos undo, `ORA-01555` (*snapshot too old*), un `SERIALIZABLE` que en realidad es snapshot isolation, lectores que nunca bloquean escritores.
- **Estructuras de almacenamiento:** tablas heap, tablas organizadas por índice (IOT), clusters de índice y de hash; índices B-tree, bitmap y basados en función; particionado (⚠️ verificar que la edición Free lo incluye).
- **Vistas materializadas** con refresco incremental y reescritura de consultas.
- **Lo nuevo de 23ai y 26ai:** JSON Relational Duality Views, grafos de propiedades con SQL/PGQ, AI Vector Search, tipo `BOOLEAN`, `IF [NOT] EXISTS`, dominios de datos.
- **Flashback:** consulta en el pasado (`AS OF`), recuperar tablas borradas, retroceder la base entera.
- **Respaldo:** redo y archive logs, RMAN, Data Pump para exportar e importar. RAC y Data Guard quedan fuera porque no se pueden montar con la edición Free.
- **Seguridad:** roles y privilegios, Virtual Private Database (seguridad a nivel de fila), auditoría unificada.
- **Tuning:** el optimizador, hints, SQL Plan Baselines, estadísticas e histogramas, `DBMS_XPLAN`, las vistas `V$` y Statspack. AWR, ASH y el Tuning Advisor entran solo si la edición Free los incluye.
- **Ecosistema:** SQL*Plus, SQLcl, SQL Developer (extensión de VS Code); ORDS para exponer la base como REST; APEX para aplicaciones low-code; database links.
- ⚠️ **Laboratorio:** hay que verificar la imagen arm64 en Macs con Apple Silicon antes de prometerla.

## 🧭 Decisiones pendientes

- **Narrativa:** una empresa distinta por motor, con el perfil que le pega (una fintech con Postgres, un e-commerce LAMP con MySQL, una app móvil con SQLite, un ERP .NET con SQL Server, una aseguradora o un banco con Oracle), o un mismo dominio en los seis para poder comparar.
- **Ejercicios en los cursos de motor:** el default del repo (20–30 por sección) daría 200–300 por motor. La propuesta es 8–12 por bloque, declarado en cada guía de estilo. `01-bases` va en sentido contrario: baterías largas por capítulo, al estilo de un libro de texto.
- **Formato de las soluciones en `01-bases`:** soluciones al final de cada capítulo, o en un solucionario aparte para que el lector no las vea por accidente.
- **Prueba de nivel:** formato concreto (checklist, mini examen con solución, o un reto práctico por bloque).
- **Inventario de ediciones gratuitas:** levantar, antes de escribir `06-sql-server` y `07-oracle`, la lista de lo que incluyen SQL Server Developer y Express y Oracle AI Database Free, porque define el temario real de ambos cursos.
- **Versiones:** fijar las de referencia en cada guía y decidir cómo se tratan las novedades de versiones Innovation.

> 📝 **Fuera por ahora:** Db2. IBM ofrece Db2 Community Edition gratis y en contenedor, así que se
> puede retomar más adelante como `08-db2`.
