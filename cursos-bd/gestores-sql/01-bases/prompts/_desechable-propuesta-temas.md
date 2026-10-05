# 🗒️ Propuesta de temas — 01-bases

> 🗑️ **Desechable, pero fuente de verdad mientras dure la discusión.** Por decisión de Oskar
> (02/10/2026), este documento manda sobre todo lo demás de `prompts/` hasta que se cierre la
> conversación del temario. Al cerrarla, se vuelca a `alcance-del-proyecto.md`, a
> `propuesta-fases-y-alcance.md` y a `propuesta-apendices-y-alcance.md`, y se siguen los prompts.
> No se cita ni se enlaza desde ningún archivo publicado del curso.
> **Creado:** 02/10/2026 · **Revisado:** 02/10/2026, con D1 y D6 cerradas y el bloque opcional
> *A.C.* incorporado desde `_desechable-modelos-legacy.md`.
> **Estado:** ✅ **cerrado el 02/10/2026.** Volcado a `alcance-del-proyecto.md`,
> `propuesta-fases-y-alcance.md` y `propuesta-apendices-y-alcance.md`, que desde ese momento son la
> fuente de verdad. Este archivo queda como registro de la discusión.

---

## 1. 🧭 Las decisiones

| # | Decisión | Respuesta de Oskar (02/10/2026) |
|---|---|---|
| D1 | Nombre visible | **El motor de motores** (§2) |
| D2 | Estructura | **Bloques con fases**, como `ruta-sql` y `ruta-no-sql-lite` |
| D3 | Ejercicios | Default: **30–45 por fase**, 18–20 en las de panorama |
| D4 | Soluciones | Default: **solucionario aparte**, `soluciones/NN-slug.md` |
| D5 | Autodiagnóstico por bloque | **No.** Cada estudiante avanza a su ritmo |
| D6 | Datos de ejemplo | **`school`** (sistema escolar) y **`supply`** ampliada con **pedidos y líneas de pedido** (§3) |
| D7 | Notación | **Unicode**, nunca LaTeX |
| D8 | Diagramas | **ASCII**, **75 columnas como máximo** siempre que se pueda |
| D9 | Verificadores en Python | **Sí** |
| D10 | Bibliografía | **Navathe como guía + 4 textos más**, 5 en total (§6) |
| D11 | Cursos | **Udemy, Coursera y cursos completos en YouTube** |
| D12 | Laboratorio | **SQLite nativo**, con apéndice de instalación y de manejo del archivo físico; **contenedor solo como apéndice opcional** |
| D13 | Duración | **La que haga falta**, sin prisa; para YouTube se poda después |
| D14 | `INSTINTOS.md` | Default: **se mantiene**, al menos un 🪞 por bloque |
| D15 | Álgebra ejecutable | **`radb`** (CLI, Python, sobre SQLite) en lugar de RelaX |
| D16 | Scripting | **Python con `venv` y Faker** cuando haga falta automatizar o generar datos |
| D17 | Identificadores | **En inglés en todas partes**, también en el álgebra: relaciones, atributos y asociaciones (`student`, `customer`, `price`…). La prosa sigue en español |
| D18 | Modelos pre-relacionales | **Bloque opcional y autocontenido al final: "A.C. — Antes de Codd"** (§5), con su bibliografía e implementaciones open source para tocar |

### 1.1 Lo que cambia `radb` (D15)

`radb` traduce el álgebra a SQL y la ejecuta sobre SQLite, así que verifica sobre **los mismos
archivos `.db`** que las consultas SQL. Cubre σ, π, ρ, ⋈ (natural y theta), ×, ∪, −, ∩ y
agregación con agrupamiento, con semántica de conjuntos en π.

**No tiene** división, outer join, semijoin ni antijoin. Eso no le quita nada al curso; al
contrario, lo aprovecha: el lector escribe ÷ con π, × y −, y el antijoin con `\diff`, que es
exactamente el ejercicio de "cómo implemento lo que no existe". Las fases que tratan esos operadores
los verifican así, y lo dicen. RelaX queda mencionado en la bibliografía como complemento visual
opcional (dibuja el árbol de operadores), sin depender de él.

⚠️ **Por verificar en P8:** que `radb` funcione sobre tablas `STRICT` y en las tres plataformas;
qué versión de Python exige en la práctica (PyPI declara 3.5+ y la última versión, 3.0.5, es de
agosto de 2023).

---

## 2. 🎬 D1 — El nombre

**El motor de motores** · *la teoría que todos los gestores SQL implementan*

Explica en tres palabras el lugar del curso en la familia `gestores-sql`: es el que está debajo
de los otros seis. La carpeta sigue siendo `01-bases/`. El bloque opcional se llama
**"A.C. — Antes de Codd"**.

---

## 3. 🏫 D6 — Las bases de ejemplo

**Todos los identificadores van en inglés (D17)**, también cuando aparecen en el álgebra o en el
cálculo: `π name (σ city = 'Lima' (supplier))`, nunca `π nombre (σ ciudad = 'Lima' (proveedor))`.
Así lo que el lector escribe en papel es lo mismo que ejecuta en `radb` y en SQLite, y lo mismo que
va a leer en Navathe y en Date. Tablas y atributos en `snake_case` y en singular.

### 3.1 `school` — el sistema escolar

Un colegio con primaria y secundaria. Sirve para casi todo: ER con participación total y parcial,
entidades débiles, jerarquías (EER), agregación, división (*"alumnos que cursaron todas las
asignaturas de su grado"*), recursión (prerrequisitos) y normalización sobre una planilla de notas
desnormalizada que cualquier lector reconoce.

| Entidad | Relación | Qué es |
|---|---|---|
| Año escolar | `school_year` | el año lectivo, con su inicio, fin y períodos |
| Período | `term` | trimestre o bimestre dentro del año |
| Grado | `grade_level` | primero básico… cuarto medio, o el equivalente |
| Sección | `section` | el curso concreto: 3.º B del año 2026 |
| Asignatura | `subject` | Matemática, Lenguaje…, con prerrequisitos |
| Docente | `teacher` | con sus asignaturas habilitadas |
| Alumno | `student` | con su apoderado |
| Apoderado | `guardian` | tutor o representante legal |
| Matrícula | `enrollment` | alumno × sección × año |
| Carga docente | `teaching_assignment` | docente × asignatura × sección |
| Evaluación | `assessment` | prueba, tarea o examen, con su ponderación |
| Calificación | `score` | alumno × evaluación, con su nota |
| Sala | `classroom` | para horarios y restricciones |

> ⚠️ **"Grade" es una trampa en inglés**: significa tanto el nivel escolar como la nota. Por eso las
> relaciones son `grade_level` y `score`, y la palabra `grade` sola no se usa en ningún
> identificador. La escala de notas (1–7, 0–10, 0–20, 0–100 según el país) se fija como **dominio**
> en F04 y es ejemplo de restricción de dominio.

### 3.2 `supply` — proveedores, partes, proyectos… y pedidos

**El núcleo es el clásico de Date** (`supplier`, `part`, `project`, `shipment`). Es corto, todo el
mundo lo cita, es **el ejemplo canónico de 5FN** (la restricción cíclica proveedor–parte–proyecto)
y el mejor para la división (*"proveedores que suministran todas las partes rojas"*).

**La ampliación son los pedidos**, el otro clásico (`customer`, `sales_order`, `order_line`), sobre
las mismas partes:

```text
customer ──< sales_order ──< order_line >── part >── supplier
                                              │
                          project ──< shipment ┘
```

| Relación | Qué es |
|---|---|
| `customer` | el cliente, con su ciudad y su categoría |
| `sales_order` | la cabecera: cliente, fecha, estado (`order` es palabra reservada de SQL) |
| `order_line` | la línea: pedido × parte, cantidad y **precio al momento de la venta** |

Los pedidos dan el mejor material de diseño del curso, y por eso aparecen sobre todo en el
Bloque III:

- **La factura plana** (cabecera, cliente y líneas en una sola relación) es el caso de 1FN → 2FN →
  3FN que recorre F14–F16, junto con la planilla de notas de `school`.
- **El precio de la línea no depende funcionalmente de la parte**: `part.price` es el precio de hoy
  y `order_line.unit_price` el de ese día. Es el ejemplo de F15 de una DF que *parece* existir en
  los datos y no existe en el dominio, y de F20 de algo que **no** es desnormalización.
- **El total del pedido** es un atributo derivado (F02, F20) y un caso de trigger (F36).
- Es además la base del caso en C del bloque A.C. (§5): cliente → pedido → línea ← parte con
  listas multienlazadas.

### 3.3 Generación de datos

Los datos chicos de los ejemplos se escriben a mano, para que el lector pueda seguirlos en papel.
Los volúmenes grandes (los que hacen falta para que un costo se note en las fases de índices y
optimización) se generan con **Faker y una semilla fija**, para que todos tengan los mismos datos.
El generador vive en `src/` y se documenta en el apéndice de las bases de ejemplo.

---

## 4. 🗺️ El temario base en bloques y fases

Navathe 7.ª ed. es la guía. Los capítulos entre corchetes son **de memoria y se confirman en P9**.
⭐ marca los bloques de énfasis. 🧵 marca **el hilo de la diferencia y la proyección**: los dos
operadores que se siguen de punta a punta, desde la definición hasta la implementación.
🏛️ marca las fases con un recuadro opcional hacia el bloque A.C. (§5.4).

```text
EL HILO DE π Y −, DE PUNTA A PUNTA

F06  π como operador: elimina duplicados, propiedades
F07  − como operador: compatibilidad de unión,
     por qué no es conmutativa, ÷ escrita con −
F08  antijoin = R − (R ⋉ S)
F10  − en SQL: EXCEPT, EXCEPT ALL, NOT EXISTS,
     LEFT JOIN … IS NULL, NOT IN y su NULL
F11  − y π en multiconjuntos
F26  cómo se ejecutan: por ordenamiento y por hash,
     con costo en bloques y en el mini motor
```

### 🧱 Bloque 0 · El terreno (≈ 10 h)

- **F00 · El sistema de bases de datos y sus actores** [1] — qué resuelve un DBMS frente a archivos
  sueltos; actores (DBA, diseñadores, usuarios finales, programadores); ventajas y cuándo **no**
  usar un DBMS. *18 ejercicios.*
- **F01 · Conceptos y arquitectura** 🏛️ [2] — modelos de datos; esquema contra estado; ANSI/SPARC
  de tres niveles; independencia lógica y física; lenguajes (DDL, DML, SDL, VDL); componentes del
  DBMS; catálogo; la historia de los modelos **en una página**, con la distinción navegacional
  contra declarativo y la invitación al bloque A.C. Primer contacto con SQLite y `radb`.
  *24 ejercicios.*

### 🧩 Bloque I · Modelado conceptual (≈ 20 h)

- **F02 · Modelo entidad-relación** [3] — entidades, atributos (compuestos, multivaluados,
  derivados), claves, relaciones, grado, cardinalidad, participación, entidades débiles, atributos
  de relación; diseño de `school` en ER. *34 ejercicios.*
- **F03 · ER extendido y notaciones** 🏛️ [4] — especialización, generalización, restricciones de
  disyunción y completitud, herencia, categorías (uniones); Chen, pata de gallo, UML y min-max; los
  diagramas de Bachman como antecesores de la pata de gallo. *32 ejercicios.*

### 📐 Bloque II · El modelo relacional ⭐ (≈ 110 h)

- **F04 · El modelo relacional, formalmente** [5] — dominio, atributo, tupla, relación como
  conjunto; por qué las tuplas y los atributos no tienen orden; `NULL` y sus tres significados;
  esquema de relación contra estado; superclave, clave, clave candidata, primaria y foránea.
  *38 ejercicios.*
- **F05 · Restricciones y operaciones de actualización** 🏛️ [5] — restricciones inherentes,
  explícitas y semánticas; integridad de entidad y referencial; qué viola cada inserción, borrado y
  modificación, y las opciones para resolverlo (rechazar, cascada, `SET NULL`, `SET DEFAULT`);
  transacciones como unidad de actualización (anticipo). *36 ejercicios.*
- **F06 · Álgebra relacional I: operaciones unarias** 🧵 [8] — σ (conmutativa, en cascada,
  selectividad); **π (elimina duplicados, cascada de proyecciones, por qué π no conmuta con todo)**;
  ρ; secuencias y asignación; grado y cardinalidad del resultado. *40 ejercicios.*
- **F07 · Álgebra relacional II: conjuntos, joins y división** 🧵🏛️ [8] — compatibilidad de unión;
  **∪, ∩, − (no conmutativa, no asociativa) y ×**; θ-join, equijoin, join natural; **÷ y su
  definición con π, × y −**; **el conjunto completo {σ, π, ∪, −, ×}** y la demostración de que ∩, ⋈
  y ÷ se derivan de él. *45 ejercicios.*
- **F08 · Álgebra relacional III: operaciones extendidas** 🧵 [8] — proyección generalizada; γ
  (agregación y agrupamiento); clausura recursiva; outer joins (⟕ ⟖ ⟗) y outer union; semijoin (⋉)
  y **antijoin (▷) escrito con −**; árboles de consulta. *40 ejercicios.*
- **F09 · Cálculo relacional** [8] — cálculo de tuplas y de dominios; cuantificadores; ∀ escrito
  con ¬∃; seguridad de expresiones; equivalencia con el álgebra (teorema de Codd); completitud
  relacional; QBE como mención. *36 ejercicios.*
- **F10 · Del álgebra a SQL, operador por operador** 🧵 [6, 7] — cada operador en SQL y vuelta;
  **π sin `DISTINCT` devuelve un multiconjunto; − en todas sus formas: `EXCEPT` contra
  `EXCEPT ALL`, `NOT EXISTS`, `LEFT JOIN … IS NULL`, `NOT IN` y la trampa del `NULL`**; cómo se
  escribía en motores sin `EXCEPT` (MySQL hasta 8.0.31 — por verificar); **÷, que SQL nunca tuvo:
  doble `NOT EXISTS` y conteo**; `INTERSECT`; outer union; clausura con `WITH RECURSIVE`; correlación
  como cálculo de tuplas. *45 ejercicios.*
- **F11 · `NULL`, lógica de tres valores y multiconjuntos** 🧵 [5, 7] — las tablas de verdad de
  `UNKNOWN`; `NULL` en comparaciones, agregados, `GROUP BY`, `DISTINCT`, `UNIQUE` y claves foráneas;
  álgebra de bolsas (∪, ∩ y − con multiplicidad); por qué `COUNT(*)` y `COUNT(col)` difieren; lo que
  esto rompe de la teoría. *36 ejercicios.*
- **F12 · Vistas y el problema de actualizarlas** [7] — vistas como consultas con nombre; vistas
  materializadas (concepto); cuándo una vista es actualizable y por qué la de un join o una
  agregación no lo es en general; `WITH CHECK OPTION`; triggers `INSTEAD OF` como salida (anticipo
  de F36). *30 ejercicios.*
- **F13 · Del ER/EER al modelo relacional** 🏛️ [9] — el algoritmo de mapeo en siete pasos más los de
  EER (las cuatro opciones para jerarquías, con su costo); `school` y `supply` mapeados de punta a
  punta; ida y vuelta: reconstruir el ER desde un esquema existente. **Jerarquías dentro del
  modelo relacional** (traído del material legacy): lista de adyacencia, conjuntos anidados, camino
  materializado y tabla de clausura, con su costo en lectura y escritura — la respuesta relacional a
  lo que IMS resolvía con punteros. *38 ejercicios.*

### 🧱 Bloque III · Diseño y normalización ⭐ (≈ 80 h)

- **F14 · Guías informales de diseño y anomalías** [14] — semántica clara, redundancia, anomalías
  de inserción, borrado y modificación, `NULL` evitables, tuplas espurias; **la planilla de notas
  de `school` y la factura plana de `supply`** como casos. *30 ejercicios.*
- **F15 · Dependencias funcionales** [14] — definición formal; DF que se cumplen en un estado contra
  DF del esquema (el precio de la línea contra el de la parte); axiomas de Armstrong **con
  demostración de solidez** y reglas derivadas (unión, descomposición, pseudotransitividad);
  clausura de atributos; clausura F⁺; equivalencia; recubrimiento mínimo; cálculo de todas las
  claves candidatas. *45 ejercicios.*
- **F16 · Formas normales: de 1FN a FNBC** [14] — 1FN (y atributos multivaluados y anidados); 2FN y
  3FN en su versión basada en la clave primaria **y en la general**; FNBC; la relación que está en
  3FN y no en FNBC; cómo probar en qué forma normal está una relación; la factura plana llevada
  hasta FNBC. *42 ejercicios.*
- **F17 · Propiedades de las descomposiciones** [15] — join sin pérdida (prueba NJB para dos
  relaciones y algoritmo de la tabla o *chase* para n); preservación de dependencias; proyección de
  F sobre un esquema; por qué FNBC no siempre preserva dependencias. *40 ejercicios.*
- **F18 · Algoritmos de diseño relacional** [15] — síntesis a 3FN (sin pérdida y con preservación);
  descomposición a FNBC; no determinismo de los algoritmos; tuplas colgantes y `NULL` en las claves
  foráneas. *40 ejercicios.*
- **F19 · Más allá de FNBC** [15] — dependencias multivaluadas y sus reglas; 4FN; dependencias de
  join y 5FN con `supply`; dependencias de inclusión; DKNF; otras (de plantilla, funcionales con
  condición). *36 ejercicios.*
- **F20 · Desnormalización y diseño físico** [17] — cuándo romper la norma y qué se paga; tablas de
  resumen, columnas derivadas (el total del pedido), particionado vertical y horizontal; por qué
  guardar el precio en la línea **no** es desnormalizar; decisiones de diseño físico a partir de la
  carga de consultas. *30 ejercicios.*

### 💾 Bloque IV · Almacenamiento e índices (≈ 50 h)

- **F21 · Discos, bloques y organización de archivos** [16] — jerarquía de memoria; discos y SSD;
  bloques, registros fijos y variables, spanned y unspanned; heap y archivos ordenados; costo de
  cada operación; buffer pool y reemplazo (LRU, clock); RAID como mención. *32 ejercicios.*
- **F22 · Hashing** [16] — interno y externo; estático y desbordes; extensible y lineal, paso a paso.
  *34 ejercicios.*
- **F23 · Índices de uno y varios niveles** [17] — primario, de agrupamiento y secundario; denso y
  disperso; multinivel; costo en bloques. *32 ejercicios.*
- **F24 · Árboles B y B+** 🏛️ [17] — orden; búsqueda; inserción con división y borrado con fusión y
  redistribución, a mano; altura y accesos; carga masiva; por qué una clave aleatoria fragmenta.
  *45 ejercicios.*
- **F25 · Otras estructuras de índice** [17] — índices sobre varias claves; cuadrícula; bitmap y su
  compresión; listas invertidas; árboles R; LSM; índices de función. *34 ejercicios.*

### ⚙️ Bloque V · Implementación de operadores y optimización (≈ 40 h)

- **F26 · Cómo se implementa cada operador** 🧵 [18] — ordenamiento externo; selección (búsqueda
  lineal, binaria, por índice, conjuntiva); join (nested loop, por bloques, por índice, sort-merge,
  hash, con su costo); **π con eliminación de duplicados, por ordenamiento y por hash; ∪, ∩ y − por
  sort-merge y por hash**; agregación; outer join; pipelining y materialización. Los operadores se
  implementan en el **mini motor** de Python (§8, punto A). *45 ejercicios.*
- **F27 · Optimización heurística** [19] — árboles de consulta; reglas de transformación del álgebra;
  empujar σ y π; el algoritmo heurístico. *34 ejercicios.*
- **F28 · Optimización basada en costo** [19] — estadísticas del catálogo; selectividad y estimación
  de cardinalidad; histogramas; orden de los joins y programación dinámica; `EXPLAIN QUERY PLAN` en
  SQLite como ventana. *36 ejercicios.*

### 🔒 Bloque VI · Transacciones (≈ 45 h)

- **F29 · Transacciones y planes** [20] — ACID; planes; conflicto; serializabilidad por conflicto y
  por vistas; grafo de precedencia; recuperable, sin cascada, estricto. *42 ejercicios.*
- **F30 · Control de concurrencia** [21] — 2PL básico, conservador, estricto y riguroso; deadlock y
  starvation (wait-die, wound-wait, detección); marcas de tiempo y regla de Thomas; MVCC;
  validación optimista; granularidad múltiple. *42 ejercicios.*
- **F31 · Niveles de aislamiento** [20, 21] — anomalías; los cuatro niveles de SQL; snapshot
  isolation y *write skew*; la crítica de Berenson et al.; qué hace SQLite. *32 ejercicios.*
- **F32 · Recuperación** [22] — bitácora y WAL; actualización diferida e inmediata; checkpoints;
  shadow paging; ARIES paso a paso. *38 ejercicios.*

### 🛠️ Bloque VII · Administración: lo core (≈ 40 h)

- **F33 · El DBA y su trabajo** [1, 17] — funciones del DBA; catálogo y diccionario de datos;
  tuning del diseño físico y de las consultas; monitoreo y planificación de capacidad. *28 ejercicios.*
- **F34 · Seguridad y autorización** [30] — DAC con `GRANT` y `REVOKE`, *grant option*,
  propagación y revocación en cascada (grafo de autorización); RBAC; MAC y Bell-LaPadula; seguridad
  por filas; inyección SQL; inferencia estadística; cifrado y auditoría. *36 ejercicios.*
- **F35 · Respaldo y continuidad** [22] — respaldo completo, incremental y diferencial; respaldo
  lógico contra físico; PITR y archivado de bitácora; RPO y RTO; replicación síncrona y asíncrona;
  alta disponibilidad; probar una restauración. Lo verificable se verifica sobre SQLite (`.backup`,
  `VACUUM INTO`, `PRAGMA integrity_check`). *30 ejercicios.*
- **F36 · Bases activas: triggers** [26] — modelo evento-condición-acción; triggers de fila y de
  sentencia; `BEFORE`, `AFTER`, `INSTEAD OF`; terminación, confluencia y cascadas; el total del
  pedido mantenido por trigger; cuándo un trigger es la peor idea. Verificable en SQLite.
  *30 ejercicios.*

### 🌐 Bloque VIII · Panorama (≈ 8 h)

- **F37 · Más allá del núcleo** 🏛️ [23, 24, 29] — bases distribuidas (fragmentación, replicación,
  2PC); CAP; por qué existen las familias NoSQL; data warehousing y OLAP en una página; remisión a
  la Ruta NoSQL Lite. *20 ejercicios.*

### 📊 Resumen del camino base

| Bloque | Fases | Horas | Ejercicios |
|---|---|---|---|
| 0 · El terreno | F00–F01 | 10 | 42 |
| I · Modelado conceptual | F02–F03 | 20 | 66 |
| II · El modelo relacional ⭐ | F04–F13 | 110 | 384 |
| III · Diseño y normalización ⭐ | F14–F20 | 80 | 263 |
| IV · Almacenamiento e índices | F21–F25 | 50 | 177 |
| V · Operadores y optimización | F26–F28 | 40 | 115 |
| VI · Transacciones | F29–F32 | 45 | 154 |
| VII · Administración | F33–F36 | 40 | 124 |
| VIII · Panorama | F37 | 8 | 20 |
| **Camino base** | **38 fases** | **≈ 403 h** | **1 345** |

A 12 h semanales son unas 34 semanas. Los bloques II y III suman 190 h, casi la mitad del curso,
y eso es el énfasis pedido. Las horas de los apéndices y del bloque A.C. no cuentan.

---

## 5. 🏛️ Bloque A.C. — Antes de Codd (opcional)

> **Opcional y autocontenido.** Va al final, fuera de las horas del camino base, y solo lo lee quien
> quiere. Nada del camino base depende de él: las fases marcadas 🏛️ tienen un recuadro corto que
> invita a venir, y nada más. Absorbe `_desechable-modelos-legacy.md`.

### 5.1 La tesis y por qué vale la pena

El modelo jerárquico y el de red son **navegacionales**: el programa recorre punteros y el camino de
acceso queda fijo en el esquema. El relacional es **declarativo**: dices qué quieres y el
optimizador decide cómo. Estudiar el "antes" no es nostalgia, por tres razones:

- **Explica el porqué del curso entero.** La independencia de datos de F01, la integridad
  referencial de F05, la ÷ de F07 (una línea en álgebra, dos bucles anidados con currency en
  CODASYL) y los índices del Bloque IV (que el modelo de red ponía en el esquema lógico) se
  entienden mejor contra lo que reemplazaron.
- **Explica NoSQL.** Un documento con subdocumentos embebidos *es* un árbol jerárquico, con las
  virtudes y los dolores de IMS. Un grafo *es* una red, ahora con lenguaje declarativo. Y la carga
  diferida de un ORM, con su N+1, es navegación CODASYL sobre un motor relacional.
- **Sigue en producción.** IMS en banca y seguros, IDMS y DMS II en mainframe, y en la región mucho
  sistema contable y de facturación nacido en Clipper o FoxPro. Migrar desde ahí es trabajo real.

> 🧠 **El gancho:** el ejercicio de listas multienlazadas en C que muchos hicimos en la universidad
> (cliente → factura → línea ← producto) *era* el modelo de red, en memoria. CODASYL le agregó
> disco, esquema, DML, concurrencia y recuperación.

### 5.2 🏺 Por qué estudiar arqueología

Es la sección que abre AC00 y la que tiene que convencer a un ingeniero ocupado de que estas 67 h
le pagan. **El argumento no es "así era antes": los modelos navegacionales nunca se fueron.** Se
mudaron a capas donde casi nadie los llama por su nombre, y el ingeniero que los reconoce elige,
diagnostica y migra mejor.

> ⚠️ **Todo lo de esta sección es de memoria y se verifica en P9**: qué motor usa hoy cada producto,
> desde qué versión, y con qué licencia. Varios de estos casos cambiaron de motor en los últimos
> años, y ese cambio es parte del contenido, no un detalle.

#### Dónde vive hoy el modelo jerárquico

| Tecnología actual | Qué tiene de jerárquico |
|---|---|
| Active Directory y LDAP (OpenLDAP) | el directorio X.500 es un árbol de entradas (DIT) con esquema; un DN es un camino desde la raíz |
| El Registro de Windows | colmenas (*hives*) con claves y subclaves: un árbol persistente |
| Sistemas de archivos | directorios e inodos: el jerárquico más usado del mundo |
| MUMPS: InterSystems IRIS, YottaDB, GT.M | los *globals* son árboles dispersos persistentes; sostienen sistemas clínicos grandes, como VistA (YottaDB/GT.M) y Epic (IRIS) |
| JSON, XML y el DOM; MongoDB, Firebase Realtime Database | un documento es un árbol; XPath y JSONPath son navegación con otra sintaxis |
| HDF5 | grupos y *datasets* en árbol, en el cómputo científico |
| IMS | sigue en producción en banca y seguros |

#### Dónde vive hoy el modelo de red y la navegación por punteros

| Tecnología actual | Qué tiene de navegacional |
|---|---|
| Bases de grafos (Neo4j, *index-free adjacency*) | registros que apuntan a registros: el *set* de CODASYL con lenguaje declarativo encima |
| ORM con carga diferida | `order.customer.city` dispara un viaje por salto: el N+1 es currency de CODASYL |
| Git | commits, árboles y *blobs* enlazados por hash: un grafo navegacional direccionado por contenido |
| Bases de objetos y de objetos embebidas (Realm, ObjectBox, Core Data como grafo de objetos) | se navega por referencias, no se consulta por valor |
| IDMS, DMS II, RDM (Raima) | el modelo de red en producción o embebido, hoy |

#### Dónde vive hoy el gestor de registros: el motor sin modelo

Es la parte más útil para un ingeniero que diseña sistemas, porque **son motores que se eligen hoy**
para productos nuevos. Exponen un API navegacional (buscar una clave, moverse al siguiente) y el
modelo de datos lo pone quien los usa.

| Motor | Dónde aparece |
|---|---|
| ESE (*Extensible Storage Engine*, "Jet Blue") | **Active Directory** (`ntds.dit`), Exchange, Windows Search; un ISAM con cursores `Seek` y `Move`. Microsoft lo publicó como open source |
| Berkeley DB | durante años, el motor de OpenLDAP, Subversion, la base de RPM, Postfix y sendmail; varios migraron cuando pasó a AGPL |
| LMDB | el sucesor en OpenLDAP; también en Monero y en otros proyectos embebidos |
| LevelDB y RocksDB | IndexedDB en Chrome, Bitcoin Core, *state stores* de Kafka Streams, TiKV; RocksDB debajo de MyRocks; Pebble, su derivado, debajo de CockroachDB |
| IndexedDB | una base clave-valor con cursores en cada navegador: navegación pura en JavaScript |
| La capa B-tree de SQLite | debajo de SQL hay un gestor de registros navegacional; el lector lo ve en el `EXPLAIN` de SQLite |

#### Lo que gana el ingeniero

- **Reconocer el patrón con su nombre.** El N+1 de un ORM, el documento que creció sin cota y el
  grafo que no escala tienen nombre y autopsia desde los años setenta. Quien conoce el diagnóstico
  original lo identifica antes y con argumentos.
- **Elegir un motor embebido con criterio.** ESE, LMDB, RocksDB o SQLite: saber que son gestores de
  registros, y no "bases de datos" en el sentido relacional, cambia qué se les puede pedir y qué
  hay que construir encima.
- **Migrar lo que todavía corre.** COBOL con VSAM, IMS, Clipper o FoxPro siguen facturando en la
  región. Migrar exige leer su modelo, no solo sus datos: las relaciones están en los punteros y en
  el código, no en el esquema.
- **Leer lo que otros no pueden.** El forense de Active Directory trabaja sobre `ntds.dit`, que es
  ESE; la recuperación de un registro de Windows corrupto es recorrer un árbol; un volcado de
  *globals* de MUMPS se lee como jerárquico. Es trabajo de nicho y bien pagado.
- **Entender por qué ganó lo declarativo**, que es la mejor defensa contra cada nueva ola que
  promete "ahora sí, sin esquema y sin SQL". *What Goes Around Comes Around* (2005 y 2024) es
  exactamente ese argumento.

> 🪞 **Tu instinto de ingeniero moderno dice que esto es historia… y esta vez se equivoca.** Si hoy
> abres sesión en un dominio Windows, consultas un expediente en un hospital grande o haces
> `git log`, estás navegando un modelo pre-relacional.

### 5.3 Las fases

Prefijo de track del repositorio: **`acNN-slug.md`**, tags en el espacio `ac-fase-<slug>`, y lo
que el bloque necesite de propio (prompts, plantilla) en archivos nuevos con el mismo sufijo, nunca
añadidos a los del camino base.

- **AC00 · Navegar contra declarar** — la tesis; **🏺 por qué estudiar arqueología (§5.2)**: dónde
  viven hoy el jerárquico, la red y el gestor de registros, y qué gana el ingeniero; mapa de los
  modelos y sus fechas; qué se lleva el lector a cada fase del camino base. *15 ejercicios.*
- **AC01 · Archivos, registros y punteros en disco** — archivos con aplicación dueña (COBOL, ISAM y
  VSAM); gestores de registros en PC (xBase con `.dbf` y sus índices, Btrieve); de las multilistas y
  las listas ortogonales al disco: *database key* (página, ranura), costo por salto y punteros
  colgantes; 🪞 *"tu instinto de estructuras de datos dice que un puntero cuesta O(1)… y en disco se
  equivoca"*; motor de almacenamiento contra modelo de datos (`dbm`, Berkeley DB, LMDB). **Lab L1**
  (gestor de registros paginado con contador de bloques) y **L5** (`dbm` como motor). *24 ejercicios.*
- **AC02 · El modelo jerárquico** — segmentos y árboles; DBD y PCB/PSB como la primera vista
  externa; DL/I (`GU`, `GN`, `GNP`, `ISRT`, `REPL`, `DLET`) y los SSA; recorrido en preorden;
  punteros hijo/gemelo; HSAM, HISAM, HDAM, HIDAM; el problema del muchos-a-muchos. **Lab L3**:
  `school` en jerárquico con un mini DL/I. *26 ejercicios.*
- **AC03 · El modelo de red** — Bachman e IDS; el informe CODASYL DBTG; registros y *sets*; el
  registro de enlace; diagramas de Bachman; el *set* como lista circular (NEXT, PRIOR, OWNER); DML
  con `FIND`, `GET`, `STORE`, `CONNECT` y currency; inserción y retención como antecesoras del
  `ON DELETE`; ubicación `CALC` y `VIA set`. **Lab L2**: `supply` con pedidos en red, con un mini
  DML. *30 ejercicios.*
- **AC04 · El Gran Debate** — Codd (1970) contra Bachman (*The Programmer as Navigator*, 1973); el
  debate de SIGMOD de 1974; System R, Ingres y Selinger. **Lab L4**: la misma pregunta en dos mundos,
  en álgebra con `radb` y como programa navegacional, con bloques contados; después se cambia la
  pregunta y se mide cuántas líneas cambia cada solución. *20 ejercicios.*
- **AC05 · Los herederos** — documentos como jerárquico (Kleppmann, cap. 2); grafos como red
  declarativa (Cypher, ISO GQL, SQL/PGQ); bases de objetos (ODMG, db4o); ORM y N+1; las vistas de
  dualidad JSON–relacional; *What Goes Around Comes Around* y su secuela de 2024. Laboratorio corto
  con **ZODB**: un grafo de objetos persistente y el N+1
  provocado a propósito. Con la Ruta NoSQL Lite, **solo referencias de concepto**: la documental es
  jerárquica en el fondo y la de grafos es una red, y se remite a sus minicursos. *22 ejercicios.*

**Casos de estudio con productos reales.** Cierran el bloque y tienen la misma forma: se toma un
producto que el lector puede instalar o ya tiene, se identifica su modelo con el vocabulario de
AC01–AC03, se cuentan los saltos de una pregunta navegacional y se escribe la misma pregunta
contra una copia relacional en SQLite, verificada con `radb`.

- **AC06 · Caso de estudio: Git, la base navegacional que ya usas** — el almacén de objetos de Git
  (commits, árboles, *blobs* y *tags*) como un modelo de red direccionado por contenido, con árboles
  jerárquicos colgando de cada commit. Se recorre a mano con `git cat-file` y `git ls-tree`, sin
  instalar nada: *"¿en qué commits cambió este archivo?"* exige navegar todo el historial, y Git
  responde con un recorrido, no con un índice. Después se exporta el grafo de un repositorio chico a
  SQLite (`commit`, `commit_parent`, `tree_entry`) con un script de Python, y la misma pregunta se
  escribe con `WITH RECURSIVE` y en álgebra con clausura (F08). 🪞 *"Tu instinto dice que Git es un
  sistema de archivos… y es una base de datos de grafos con un solo patrón de acceso."* Funciona igual
  en las tres plataformas. *20 ejercicios.*
- **AC07 · Caso de estudio: LMDB, el motor sin modelo** *(§8 E4, cerrado el 02/10/2026)* — un
  gestor de registros real y *standalone* (`pip install lmdb`, nativo en las tres plataformas): árbol
  B+ con copia en escritura, cursores, subbases con nombre y claves con valores duplicados
  (`dupsort`). Sobre él se monta a mano la capa de red de AC03: los *sets* de `supply` con pedidos
  como claves `dupsort`, y un mini DML encima. Se cuentan los accesos con el contador de L1 y se
  compara contra la versión relacional. El cierre explica que es el mismo motor que hay debajo de
  OpenLDAP, y que Active Directory hace lo mismo sobre ESE. *22 ejercicios.*
- **AC08 · Caso de estudio: YottaDB, el jerárquico que sigue en producción** *(§8 E4, cerrado el
  02/10/2026)* — los *globals* de MUMPS como árboles dispersos persistentes, con subíndices en vez de
  segmentos: `^school(year, section, student)`. Se carga `school` como árbol, se recorre con `$ORDER`
  (la navegación de DL/I con otra sintaxis) y desde Python con el paquete `yottadb`; después se
  pregunta lo que el árbol no previó (*"todas las secciones de un alumno"*), se mide cuánto cuesta y
  se resuelve con un *global* inverso, que es un índice secundario a mano. Contexto real: VistA y
  otros sistemas clínicos. **Corre en el contenedor de `aca-02`** en macOS y Windows; en Linux
  x86-64, también nativo. *22 ejercicios.*
- 🔥 **Tercer caso, de reserva: el `.dbf` que factura desde 1994** — migrar a SQLite un sistema de
  facturación en xBase (Clipper o FoxPro): leer los `.dbf` con Python, reconstruir las relaciones que
  vivían en el código y no en el esquema, y normalizar con lo de F14–F18. Es el caso más útil para la
  región y el menos vistoso. Entra si AC06, AC07 o AC08 se caen en la verificación.
- **AC09 · Pedidos en C: el modelo de red a mano** *(E2, cerrado el 02/10/2026)* — la base clásica
  de clientes, pedidos, líneas y partes con estructuras multienlazadas. Primero en memoria y después
  sobre un archivo de páginas con `fseek`, con *database keys* y *sets* circulares (NEXT, PRIOR,
  OWNER) y un mini DML por línea de comandos. **ANSI C, solo CLI, sin dependencias, compilable con
  GCC y con Visual C++.** El código se entrega **hecho**: se genera con asistencia de IA como parte
  del contenido del curso, se revisa y se compila en las tres plataformas antes de publicarse, y
  queda **abierto para ejercicios** de extensión (un *set* nuevo, borrado con retención `MANDATORY`,
  un índice `CALC`). Vive en `src/ac09-…/`. *20 ejercicios.*

| Bloque A.C. | Fases | Horas | Ejercicios |
|---|---|---|---|
| Antes de Codd (opcional) | AC00–AC09 | ≈ 67 h | 221 |

Las horas: AC00 3 h, AC01 8 h, AC02 8 h, AC03 10 h, AC04 6 h, AC05 6 h, AC06 6 h, AC07 6 h, AC08 6 h y AC09 8 h.

> ⚠️ **No hay laboratorio con IMS ni IDMS reales**: no existen ediciones gratuitas que corran en una
> laptop. DL/I y el DML de CODASYL se enseñan en papel y con los mini DML en Python de L2 y L3, y el
> texto lo dice.

### 5.4 Los recuadros 🏛️ en el camino base

Un recuadro corto (tres o cuatro líneas, sin ejercicios) en F01, F03, F05, F07, F13, F24 y F37, con
la forma *"🏛️ Antes de Codd: esto se resolvía así… → bloque A.C."*. Mientras el bloque no exista, la
referencia va en prosa, sin enlace.

### 5.5 Para tocar: implementaciones open source

⚠️ **Candidatos sin verificar.** P9 comprueba que existan, la licencia, que sigan mantenidos y que
corran en las tres plataformas.

| Modelo o idea | Implementación | Qué permite palpar |
|---|---|---|
| Archivos indexados (COBOL) | GnuCOBOL | archivos `INDEXED` y `RELATIVE` como en el mainframe |
| xBase | Harbour (compatible con Clipper) | `USE`, `SEEK`, `SKIP`: navegación sobre `.dbf` |
| Jerárquico (árbol de *globals*) | YottaDB o GT.M (MUMPS) | una base jerárquica en producción, open source |
| Jerárquico (directorio) | OpenLDAP (🔥, solo mención) | un árbol con esquema, sobre LMDB |
| Motor *standalone* (AC07) | LMDB con `lmdb` de Python | el motor de OpenLDAP sin OpenLDAP; *sets* con `dupsort` |
| Grafo de objetos | ZODB | navegación por referencias y N+1 |
| Red | db.* / RDM (Raima), si sigue habiendo versión libre | *sets* y *database keys* reales |
| Motores clave-valor | `dbm` de Python, LMDB, Berkeley DB | la capa de abajo, sin modelo de datos |
| ISAM de Active Directory | ESE (Extensible Storage Engine, publicado por Microsoft) | el motor de `ntds.dit`, con su API de cursores `Seek` y `Move` |
| Navegación en el navegador | IndexedDB | cursores sobre clave-valor, sin instalar nada |
| Mainframe | Hercules (emulador) | el entorno donde vivían IMS e IDMS; ellos no son libres |

### 5.6 Bibliografía del bloque

⚠️ **Nada verificado todavía.** Pasa por P9 como todo lo demás.

- **Papers:** Codd (1970); Bachman, *The Programmer as Navigator* (CACM, 1973); el informe CODASYL
  DBTG (1971); *ACM Computing Surveys* de marzo de 1976 (Taylor y Frank sobre CODASYL; Tsichritzis y
  Lochovsky sobre el jerárquico); Stonebraker y Hellerstein, *What Goes Around Comes Around* (2005);
  Stonebraker y Pavlo, *What Goes Around Comes Around… And Around…* (SIGMOD Record, 2024); Olson,
  Bostic y Seltzer, *Berkeley DB* (USENIX, 1999).
- **Libros:** Elmasri y Navathe (los apéndices de los modelos jerárquico y de red; verificar si la
  7.ª edición los conserva o están en línea); ediciones antiguas de Date, que traían IMS e IDMS;
  Kleppmann, *Designing Data-Intensive Applications*, cap. 2. Estos tres no cuentan contra el tope
  de cinco textos de D10, que es para el camino base.
- **Videos y cursos:** las clases de historia de Andy Pavlo en CMU (15-445 o 15-721), por ubicar;
  material de IBM sobre IMS (IBM Z Xplore, por verificar que siga siendo gratuito).

---

## 6. 📚 D10 — Los cinco textos del camino base

| # | Libro | Papel en el curso |
|---|---|---|
| 1 | Elmasri y Navathe, *Fundamentals of Database Systems*, 7.ª ed. | **Guía**: el orden y la profundidad de casi todas las fases |
| 2 | C. J. Date, *An Introduction to Database Systems*, 8.ª ed. | **La biblia**: el modelo relacional, la teoría de dependencias y la crítica a SQL |
| 3 | C. J. Date, *SQL and Relational Theory*, 3.ª ed. (O'Reilly) | **El puente moderno**: cómo escribir SQL relacionalmente correcto; F10 y F11 se apoyan en él |
| 4 | Alex Petrov, *Database Internals* (O'Reilly) | **Internals moderno**: B-tree, LSM, buffer, recuperación; bloques IV y VI |
| 5 | Molinaro y de Graaf, *SQL Cookbook*, 2.ª ed. (O'Reilly) | **SQL general**: recetas de diferencia, división y relaciones en SQL real; F10 |

Quedan fuera como textos base, aunque se pueden citar puntualmente en alguna fase: Silberschatz,
Garcia-Molina–Ullman–Widom y Ramakrishnan–Gehrke.

⚠️ **Todo por verificar en P9**: ediciones vigentes, año, si hay traducción al español y en qué
edición, y el mapa de capítulos por fase.

## 7. 🎥 D11 — Cursos y videos (candidatos)

Ninguno está verificado todavía. P9 comprueba que existan, la URL, el idioma, si son de pago y la
fecha. **Candidatos de los que tengo razonable certeza**:

- **YouTube:** CMU 15-445/645 *Intro to Database Systems* (Andy Pavlo), las clases de Berkeley CS186
  y la serie de Stanford de Jennifer Widom (*Databases*).
- **Coursera:** *Database Management Essentials* (University of Colorado), por confirmar que sigue
  abierto.
- **Udemy:** sin candidatos nombrados todavía. Hay que buscar en P9 cursos de teoría (modelo
  relacional y normalización), no de SQL de trabajo, y preferir los que estén en español.
- **Complementos:** RelaX (visual), el *Red Book* (*Readings in Database Systems*) para papers y
  los papers fundacionales por fase (Codd 1970, Chen 1976, Bayer y McCreight 1972, Selinger 1979,
  Berenson 1995, Mohan 1992 ARIES, O'Neil 1996 LSM).

---

## 8. ❓ Lo que sigue abierto

✅ **A–D cerrados el 02/10/2026 con su valor por defecto**, aceptado por Oskar.

**A. El mini motor de F26.** Los operadores en Python como iteradores (modelo Volcano, solo
biblioteca estándar): σ, π con eliminación de duplicados por ordenamiento y por hash, ∪, ∩, − por
sort-merge y por hash, ÷, los joins y el ordenamiento externo, con un contador de bloques leídos.
Sería el entregable del Bloque V, el lugar donde la diferencia se implementa sin SQL, y **comparte
el contador de bloques con el L1 del bloque A.C.** · *Por defecto: entra.*

**B. Cómo se verifica F34.** SQLite no tiene usuarios. *Por defecto: en papel, con el grafo de
autorización y remisión a los cursos de motor; PostgreSQL en el contenedor opcional como 🔥.*

**C. Examen integrador por bloque**, en lugar del boss 💀 de los cursos hermanos. *Por defecto: no;
la batería de ejercicios alcanza.*

**D. Temas fuera:** bases temporales, espaciales y deductivas, XML, objeto-relacional y
recuperación de información. *Por defecto: fuera, con mención en F37 o en AC05.*

**E. Bloque A.C.** — cerrado el 02/10/2026:
1. ✅ **Laboratorio completo**, L1–L5.
2. ✅ **AC09 entra** (el caso en C), en ANSI C por CLI, compilable con GCC y Visual C++, con el código hecho y
   abierto para ejercicios.
3. ✅ **Con `ruta-no-sql-lite`, solo referencias de conceptos**: AC05 y F37 dicen que varias familias
   NoSQL son, en el fondo, jerárquicas (documental) o en red (grafos), y remiten a sus minicursos.
   Ese curso no se toca.
4. ✅ **Casos de estudio: Git (AC06), LMDB (AC07) y YottaDB (AC08).** ZODB queda como laboratorio
   corto dentro de AC05. YottaDB corre en contenedor fuera de Linux, con su apéndice `aca-02`: es un
   bloque opcional para quien no tiene problema con contenedores.

**Las alternativas que se evaluaron**, consultadas en PyPI el 02/10/2026 (registro de la decisión):

| Motor | Modelo que deja ver | Instalación | A favor | En contra |
|---|---|---|---|---|
| **LMDB** (`lmdb` 3.0.0) | gestor de registros: B+ *copy-on-write*, cursores, subbases con nombre, claves con valores duplicados (`dupsort`) que funcionan como *sets* | wheels para Windows, macOS y Linux, x86 y ARM; trae LMDB adentro (por confirmar en P8) | es el motor de OpenLDAP, sin OpenLDAP; conecta con F24 y F32; licencia OpenLDAP (permisiva) | no trae modelo: la capa jerárquica o de red se escribe a mano (que es justo el ejercicio) |
| **ZODB** (6.3, abril de 2026) | un grafo de objetos persistente: se navega por referencias, con transacciones ACID y `BTrees` | wheel en Python puro; Python 3.10+ | el heredero de la red más cercano al lector (ORM, N+1); vivo y mantenido | es una base de objetos, no un motor de registros; queda más cerca de AC05 que de AC01 |
| **YottaDB** (`yottadb` 2.0.1) | **jerárquico de verdad**: los *globals* de MUMPS, en producción en sistemas clínicos | wheels solo para Linux x86-64; en macOS y Windows, con el contenedor | el único jerárquico auténtico y vivo del grupo | AGPL; no es nativo en dos de las tres plataformas |
| **UnQLite** (`unqlite` 1.2.0) | clave-valor y documental en un solo archivo de C | wheels para Windows, macOS ARM y Linux x86-64 | muestra que un documento es un árbol sobre un motor KV | proyecto chico; sin wheels para macOS Intel ni Linux ARM |
| **RocksDB** (`rocksdict` 0.3.29) | gestor de registros LSM | wheels para las tres plataformas | conecta con LSM de F25 | es puro clave-valor ordenado: no deja ver punteros ni *sets* |

**Descartados:** **upscaledb**, el sucesor de hamsterdb, está inactivo desde su versión 2.2.1 de
2017. **Berkeley DB** (`berkeleydb` 18.1.15) solo se publica como código fuente y exige compilar
`libdb`, lo que en Windows es una barrera. **ESE** está publicado como open source, pero solo corre
en Windows.

**Elegidos:** LMDB (AC07) y YottaDB (AC08), más ZODB dentro de AC05.

---

## 9. 📎 Los apéndices

Aquí solo **se definen**: qué cubre cada uno, qué queda fuera, quién lo usa y en qué momento se
escribe. Se redactan en la tanda que los necesita, que fija el plan de producción. Ninguno se
escribe completo por adelantado: lo que va en ellos lo decide la ejecución.

Comparten la forma de los apéndices de los cursos hermanos: no se leen de corrido, se entra por el
índice y se sale; secciones cortas que responden a una pregunta; ejemplo mínimo ejecutable; una
tabla de "cuándo usar qué" al final; y de 5 a 10 ejercicios de consulta. **Sus horas no cuentan.**

### 9.1 De un vistazo

| # | Apéndice | Se escribe | Usado por |
|---|---|---|---|
| a01 | SQLite nativo y el archivo físico | antes de F01 | todo el curso |
| a02 | Python, `venv` y Faker | antes de F01 | a03, a04, a05 y las fases con datos generados |
| a03 | `radb` en tres plataformas | antes de F01 | Bloque II en adelante |
| a04 | Las bases de ejemplo y su generador | antes de F02; crece hasta F13 | todo el curso |
| a05 | Los verificadores y el mini motor | con F15; crece hasta F29 | Bloques III a VI |
| a06 | La matemática mínima | antes de F04 | Bloques II y III |
| a07 | Notación y glosario bilingüe | esqueleto antes de F04; **vivo** | todo el curso |
| a08 | Mapa de bibliografía y recursos | esqueleto antes de F00; **vivo** | todo el curso |
| a09 | 🔥 El curso en un contenedor (opcional) | después de a01–a03 | quien no quiera instalar nada |
| aca-01 | 🏛️ Herramientas nativas del bloque A.C. (opcional) | con AC01 | bloque A.C. |
| aca-02 | 🏛️ Contenedores del bloque A.C. (opcional) | con AC08 | AC08, y lo que no corra nativo |

**Cambia el orden respecto de la versión anterior**: Python va antes que `radb` porque `radb` se
instala con `pip` dentro del `venv`, y las bases de ejemplo van antes que los verificadores porque
los verificadores trabajan sobre ellas.

### 9.2 Las fichas

**a01 · SQLite nativo y el archivo físico**
- **Cubre:** instalar la CLI `sqlite3` con `brew` (macOS), `winget`, Chocolatey o Scoop (Windows) y
  `apt`, `dnf` o `pacman` (Linux); comprobar que la versión admite `STRICT`; los comandos con punto
  que usa el curso (`.open`, `.read`, `.schema`, `.mode`, `.headers`); **la base es un archivo**:
  dónde queda, cómo se copia y se mueve sin corromperla (con la base cerrada, o con `.backup` y
  `VACUUM INTO` con la base abierta), qué son los archivos `-wal` y `-shm` y por qué no se copian
  sueltos, `PRAGMA integrity_check` para comprobar la copia.
- **Fuera:** la teoría de respaldo (F35), el modo WAL como teoría de recuperación (F32) y todo lo que
  enseña el curso `05-sqlite`.

**a02 · Python, `venv` y Faker**
- **Cubre:** instalar Python en las tres plataformas (python.org, `brew`, `winget`, el gestor de la
  distribución) y el lanzador `py` de Windows; crear, activar y desactivar un `venv` en bash/zsh,
  PowerShell (con su política de ejecución) y `cmd`; `pip` y un `requirements.txt` con versiones
  fijadas; **Faker para datos de prueba**: *locales* en español (`es_MX`, `es_CO`, `es_CL`…),
  `Faker.seed()` para que todos generen lo mismo, proveedores propios (por ejemplo, para asignaturas
  y escalas de notas). Referencias oficiales de Python, `venv`, `pip` y Faker.
- ⚠️ **La advertencia que importa:** la misma semilla puede dar datos distintos con otra versión de
  Faker. Por eso la versión va fijada en `requirements.txt` y el apéndice lo dice.
- **Fuera:** enseñar Python, `uv`, `conda` y cualquier otro gestor. El curso usa `venv` porque viene
  con Python.

**a03 · `radb` en tres plataformas**
- **Cubre:** instalarlo en el `venv` de a02; conectarlo a un `.db` de SQLite; correr consultas
  interactivas y desde archivo; la sintaxis completa de sus operadores frente a la notación Unicode
  del curso; ver el SQL que genera; **lo que no tiene** (÷, outer join, ⋉, ▷) y cómo escribirlo con
  lo que sí tiene; su comportamiento con tablas `STRICT`.
- **Fuera:** la teoría de cada operador, que está en F06–F08. RelaX solo aparece como mención.

**a04 · Las bases de ejemplo y su generador**
- **Cubre:** `school` y `supply` con pedidos: diagrama ER, esquema relacional, DDL `STRICT`, los
  datos chicos escritos a mano (los de los ejemplos en papel), el generador con Faker y su semilla
  para los volúmenes grandes, y cómo recrear cada base desde cero en un comando. El código vive en
  `src/a04-…/`.
- **Fuera:** el diseño de las bases, que es materia de F02, F13 y el Bloque III; aquí se dan
  hechas.

**a05 · Los verificadores y el mini motor**
- **Cubre:** qué calcula cada script de `src/` (clausura, claves candidatas, recubrimiento mínimo,
  descomposición, *chase*, B+, serializabilidad) y cómo usarlo para revisar una solución propia; el
  mini motor de F26 (operadores como iteradores y el contador de bloques). Crece a medida que las
  fases agregan verificadores.
- **Fuera:** la teoría de los algoritmos, que está en sus fases. El apéndice dice cómo se usan, no
  por qué funcionan.

**a06 · La matemática mínima**
- **Cubre:** conjuntos, producto cartesiano, relaciones y funciones; lógica de predicados,
  cuantificadores y sus negaciones; cómo se lee y se escribe una demostración (directa, por
  contradicción, por contraejemplo, por inducción); logaritmos y potencias para la altura de un
  árbol y el costo de un ordenamiento.
- **Fuera:** todo lo que el curso no use. Si algo no aparece en ninguna fase, no va aquí.

**a07 · Notación y glosario bilingüe** (vivo)
- **Cubre:** cada símbolo Unicode del curso, cómo se escribe en el teclado y su equivalente en
  `radb`; la tabla de notaciones de Navathe, Date y los demás textos cuando difieren; el glosario
  español ↔ inglés en las dos direcciones, con la traducción que usan las ediciones en español.
  Crece con cada fase.
- **Fuera:** definiciones largas. El glosario remite a la fase donde se define cada término.

**a08 · Mapa de bibliografía y recursos** (vivo)
- **Cubre:** la tabla libro × fase con capítulos y edición, para los cinco textos del camino base;
  los cursos (Udemy, Coursera, YouTube y cursos universitarios abiertos) por bloque, con idioma, si
  son de pago y la fecha de verificación; los papers fundacionales por fase. Es la fuente de la
  sección de bibliografía de cada fase.
- **Fuera:** reseñas largas. Cada recurso lleva una línea de por qué vale la pena.

**a09 · 🔥 El curso en un contenedor** (opcional)
- **Cubre:** una imagen con SQLite, Python, `radb` y Faker, con las bases del curso montadas como
  volumen; los comandos con Docker y su equivalente con Podman; y un servicio extra, también
  opcional: un PostgreSQL para practicar `GRANT` y `REVOKE` en F34 (§8, punto B). Las herramientas
  del bloque A.C. no van aquí: tienen su propio apéndice, `aca-02`.
- **Fuera:** enseñar Docker. Si hace falta explicar el mecanismo, se enlaza
  `docker-container-legacy/`. El curso se cita como alternativa; nunca exige el contenedor.

**aca-01 · 🏛️ Herramientas nativas del bloque A.C.** (opcional)
- **Cubre:** instalar en las tres plataformas lo que corre nativo: Git (ya está), `lmdb` y ZODB en
  el `venv` de a02, GnuCOBOL y Harbour para AC01, y GCC o Visual C++ para AC09, con cómo se compila
  con cada uno.
- **Fuera:** la teoría de los modelos, y todo lo que necesite contenedor, que va en `aca-02`.

**aca-02 · 🏛️ Contenedores del bloque A.C.** (opcional)
- **Cubre:** YottaDB en contenedor (imagen oficial, si P8 la confirma), con las bases de `school`
  montadas como volumen y el paquete `yottadb` de Python conectado desde dentro; los comandos con
  Docker y su equivalente con Podman; y cualquier otra herramienta del bloque que P8 encuentre sin
  versión nativa en alguna plataforma.
- **Fuera:** enseñar Docker, que se enlaza a `docker-container-legacy/`. Es independiente de a09: el
  contenedor del camino base no carga con las herramientas del bloque A.C., y viceversa.
---

## 10. ➡️ Qué pasa después

1. Oskar responde §8 (o acepta los valores por defecto).
2. Se vuelca este documento a `alcance-del-proyecto.md` (hoy desactualizado), a
   `propuesta-fases-y-alcance.md` y a `propuesta-apendices-y-alcance.md`.
3. Se escribe el resto de `prompts/`: guía de estilo, plantillas (incluida la del bloque A.C.),
   prompts de fase y de apéndice, y `_desechable-plan-de-produccion.md`.
4. `_desechable-modelos-legacy.md` queda absorbido aquí y se puede borrar con permiso de Oskar.
