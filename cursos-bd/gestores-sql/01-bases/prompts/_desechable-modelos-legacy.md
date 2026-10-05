# 🗒️ Modelos pre-relacionales y sus herederos — ideas para 01-bases

> 🗑️ **Desechable.** Lluvia de ideas para decidir cuánto de los modelos jerárquico y de red entra
> en el curso, y dónde. No se cita ni se enlaza desde ningún archivo del curso. Lo que se apruebe
> pasa a la propuesta de fases o a la de apéndices, y este archivo se borra con permiso de Oskar.
> **Creado:** 02/10/2026 · **Estado:** ideas sin discutir; nada decidido.
> **Origen:** una conversación sobre si vale la pena estudiar los modelos pre-relacionales en un
> refrescamiento profesional, y sobre los ejercicios de listas multienlazadas en C
> (cliente → factura → línea ← producto) de los cursos de estructuras de datos.

---

## 1. 🧭 La tesis

Hoy la propuesta de temas resuelve la historia de los modelos en una línea de F01. Este documento
propone darle algo más de peso, **no por nostalgia, sino porque es la mejor forma de explicar por
qué existe el modelo relacional**. Se puede contar en una frase: el modelo jerárquico y el de red son
**navegacionales** (el programa recorre punteros y el camino de acceso queda fijo en el esquema),
mientras que el relacional es **declarativo** (dices qué quieres y el optimizador decide cómo).

Eso se conecta con casi todo el curso:

- **F01:** la independencia lógica y física de ANSI/SPARC (1975) nace de esa discusión. Sin el
  "antes", la independencia de datos es un concepto abstracto.
- **F07 y F10:** la ÷ ("proveedores que suministran *todas* las partes") en el modelo de red es un
  programa de dos bucles anidados con currency. En álgebra es una línea.
- **F13:** el mapeo ER → relacional tiene sus hermanos ER → jerárquico y ER → red, y el contraste
  muestra qué gana el relacional (y qué pierde: la localidad física).
- **F21–F25:** los punteros entre registros, la ubicación física *VIA set* y las *database keys*
  son la otra cara de los índices. El modelo de red ponía la estructura de acceso **en el
  esquema lógico**, y el relacional la sacó de ahí.
- **F26:** el mini motor ya cuenta bloques. El mismo contador, puesto sobre un recorrido
  navegacional, permite comparar los dos mundos con números.
- **F37:** el panorama de NoSQL queda mucho mejor parado si el lector ya sabe que un documento
  embebido es un árbol jerárquico y que un grafo es una red con lenguaje declarativo.

> 🧠 **El gancho para el lector:** el ejercicio de listas multienlazadas en C que muchos hicimos en
> la universidad *era* el modelo de red, en memoria. CODASYL le agregó disco, esquema, DML,
> concurrencia y recuperación. Partir de ahí convierte la historia en algo que el lector ya sabe
> hacer con las manos.

---

## 2. 🧩 Dónde podría encajar

| Opción | Qué implica | A favor | En contra |
|---|---|---|---|
| **A · Ampliar F01** | Una sección de la historia de los modelos con algo de profundidad | No crea fases nuevas | F01 ya es densa y la historia queda como lectura, sin ejercicios de verdad |
| **B · Fase propia** (Bloque 0 o VIII) | Una fase de ≈ 8–10 h con su batería | Le da ejercicios y laboratorio | Suma horas a un curso que ya ronda las 400 |
| **C · Apéndice** (`a10-…`) | Teoría, laboratorio y ejercicios fuera del camino principal | Opcional, no alarga el camino base | Los apéndices no cuentan horas, y algunos lectores no llegan a ellos |
| **D · Hilo 🧵 transversal** | Como el hilo de π y −: una sección corta "y en el modelo de red…" en F01, F07, F13, F24 y F37 | Conecta con lo que el lector está estudiando en ese momento | Es más difícil de mantener coherente |

**Recomendación tentativa:** C + D. Se haría un apéndice con el material completo (teoría,
laboratorio y ejercicios) y un hilo de cuatro o cinco recuadros cortos en las fases que remiten a
él. F01 se queda con un resumen de una página.

---

## 3. 📚 Temas candidatos

### 3.1 Antes de los modelos: archivos y gestores de registros

- **Archivos con aplicación dueña:** COBOL con archivos secuenciales e indexados; ISAM y VSAM (KSDS,
  ESDS, RRDS) en el mainframe; por qué cada programa definía su propio formato.
- **Gestores de registros en PC:** dBase, Clipper y FoxPro (xBase, `.dbf` + `.ndx`/`.cdx`); Btrieve
  (hoy Actian Zen). Navegación con `SEEK`, `SKIP` y `GO TOP`: también es acceso navegacional.
- 📝 **Relevancia latinoamericana:** mucho sistema contable, de nómina y de facturación de la región
  nació en Clipper o FoxPro, y la banca sigue en COBOL sobre mainframe. Migrar desde ahí es trabajo
  real.

### 3.2 El modelo jerárquico (IMS)

- **Estructura:** tipos de segmento, el árbol de un registro de base de datos, la relación
  padre-hijo como única relación posible.
- **Definición:** DBD (la base) y PCB/PSB (la vista que ve cada programa). Es la primera forma de
  "vista externa" de la historia.
- **DL/I:** `GU`, `GN`, `GNP`, `ISRT`, `REPL`, `DLET`; los SSA para calificar; el recorrido en
  preorden como orden "natural" de la base.
- **Por dentro:** punteros hijo/gemelo (*child/twin*), que son la representación "primer hijo,
  siguiente hermano" de los cursos de árboles; organizaciones HSAM, HISAM, HDAM e HIDAM.
- **El problema de fondo:** las relaciones muchos-a-muchos. Las salidas eran duplicar segmentos o
  usar relaciones lógicas entre árboles, un parche que acerca el modelo al de red.
- **Vigencia:** IMS sigue en producción en banca y seguros. Otros árboles vivos son LDAP y Active
  Directory, el Registro de Windows, los *globals* de MUMPS/InterSystems IRIS, HDF5 y Firebase
  Realtime Database.

### 3.3 El modelo de red (CODASYL)

- **Origen:** Bachman y el IDS de General Electric (≈ 1963); el informe CODASYL DBTG (1971);
  IDMS, DMS II e IDS/II como implementaciones.
- **Estructura:** tipos de registro y **sets** (relación 1:N con dueño y miembros); el **registro de
  enlace** como única forma de expresar un muchos-a-muchos; los **diagramas de Bachman**, que son
  antecesores directos de la pata de gallo.
- **Implementación de un set:** lista circular dueño → miembros → dueño, con punteros NEXT, PRIOR y
  OWNER opcionales. Es la misma forma que las listas ortogonales de las matrices dispersas.
- **DML:** `FIND FIRST/NEXT … WITHIN set`, `FIND OWNER`, `GET`, `STORE`, `CONNECT`,
  `DISCONNECT`; los **indicadores de currency** (de la unidad de ejecución, de cada tipo de registro
  y de cada set) como estado implícito del programa.
- **Restricciones:** inserción `AUTOMATIC`/`MANUAL` y retención `MANDATORY`/`OPTIONAL`/`FIXED`,
  leídas como antecesoras de la integridad referencial y del `ON DELETE` (conecta con F05).
- **Ubicación física:** `CALC` (hash por clave) y `VIA set` (junto al dueño). El diseño lógico y el
  físico eran una sola decisión.
- **Vigencia:** IDMS (Broadcom) y DMS II (Unisys) en mainframe; Raima RDM como heredero embebido
  que combina el modelo de red con SQL.

### 3.4 El Gran Debate

- Codd (1970) contra Bachman (*The Programmer as Navigator*, conferencia del Premio Turing de 1973).
- El debate de SIGMOD de 1974 y sus argumentos: eficiencia contra independencia de datos, y el
  programador como navegador contra el programador como especificador.
- System R e Ingres como prueba de que lo declarativo podía ser eficiente; el optimizador de
  Selinger (1979), que ya está en la bibliografía de F28.
- Stonebraker y Hellerstein (2005) y Stonebraker y Pavlo (2024): la historia se repite, y cada
  generación redescubre por qué ganó lo declarativo.

### 3.5 De las estructuras de datos a las bases de datos

Este es el puente con el ejercicio en C que motivó el documento.

- Multilistas, listas ortogonales y árboles "primer hijo, siguiente hermano" como lo que de verdad
  hay debajo de los modelos jerárquico y de red.
- Qué cambia cuando el puntero deja de ser una dirección de memoria y pasa a ser una dirección de
  página y registro en disco: costo por salto, localidad y el problema de los punteros colgantes en
  un archivo.
- Un 🪞 posible: *"Tu instinto de estructuras de datos dice que un puntero cuesta O(1)… y en disco
  se equivoca"*. Cada salto puede ser un acceso a bloque.

### 3.6 Motor de almacenamiento contra modelo de datos

- **La distinción:** Berkeley DB, LMDB, LevelDB/RocksDB, WiredTiger y bbolt son **motores
  clave-valor embebidos**, no modelos de datos. Jerárquico, de red, relacional y documental son
  capas lógicas que se montan encima.
- **El linaje Unix:** `dbm` (1979) → `ndbm` → la familia de Berkeley DB. El módulo `dbm` de la
  biblioteca estándar de Python es descendiente directo, así que sirve para el laboratorio sin
  instalar nada.
- **Ejemplos de capas sobre KV:** OpenLDAP (un árbol) sobre LMDB; MongoDB (documentos) sobre
  WiredTiger; MySQL con MyRocks sobre RocksDB; el RSS de System R como gestor de registros debajo
  de SQL.
- 📝 **Dato de licencias:** Berkeley DB pasó a AGPL en su versión 6 (2013), y varias distribuciones
  migraron a LMDB. Conecta con la idea de riesgo de licencias de los cursos de motor.

### 3.7 Los herederos modernos

- **Documentos = jerárquico.** Un documento con subdocumentos embebidos tiene las virtudes y los
  dolores de IMS. Kleppmann lo plantea en *Designing Data-Intensive Applications*, cap. 2 ("¿las
  bases documentales repiten la historia?").
- **Grafos = red con lenguaje declarativo.** La adyacencia sin índice (*index-free adjacency*) de
  Neo4j; Cypher; el estándar ISO GQL (2024) y SQL/PGQ, que Oracle 26ai ya implementa (ver
  `07-oracle`).
- **Bases de objetos:** ODMG, ObjectStore y db4o como el intento de los 90 de volver a navegar.
- **ORM y N+1:** la carga diferida es navegación CODASYL sobre un motor relacional. Es el ejemplo
  más cercano al lector.
- **Dualidad documento ↔ relacional:** las JSON Relational Duality Views de Oracle 26ai como el
  intento de tener las dos vistas sobre los mismos datos.

### 3.8 Jerarquías dentro del modelo relacional

Este tema podría vivir en F10 o F13 aunque el resto quede fuera, porque es teoría que el lector usa.

- Lista de adyacencia con `WITH RECURSIVE` (F10 ya trata la clausura), y `CONNECT BY` de Oracle como
  mención.
- Conjuntos anidados (*nested sets*), camino materializado (*materialized path*) y tabla de
  clausura (*closure table*), con el costo de cada uno en lectura y en escritura.
- 🧠 Las cuatro son la respuesta relacional a la pregunta que IMS resolvía con punteros.

---

## 4. 🔬 Laboratorio posible

Todo cabe en las decisiones ya tomadas: Python con biblioteca estándar (D9 y D16), diagramas ASCII
(D8) y el contador de bloques del mini motor de F26.

- **L1 · Un gestor de registros paginado.** Un archivo de páginas de tamaño fijo, registros con
  *database key* (página, ranura) y un contador de bloques leídos y escritos. Es la base de los
  demás laboratorios.
- **L2 · `supply` en el modelo de red.** Registros `SUPPLIER`, `PART` y `SHIPMENT` (el registro de
  enlace), y los sets `S-SH` y `P-SH` como listas circulares. Un mini DML con `find_first`,
  `find_next`, `find_owner` y currency explícita.
- **L3 · `escolar` en el modelo jerárquico.** Un árbol curso → sección → inscripción, recorrido en
  preorden con un mini DL/I (`gu`, `gn`, `gnp`). Se ve cómo duele la pregunta inversa ("¿en qué
  secciones está este alumno?").
- **L4 · La misma pregunta, dos mundos.** Una consulta en álgebra (`radb`) contra el programa
  navegacional equivalente, con bloques contados. Después se cambia la pregunta y se compara cuánto
  cambia cada solución: la independencia de datos medida en líneas de código.
- **L5 · `dbm` como motor.** Se montan L2 o L3 sobre el módulo `dbm` de Python en lugar del archivo
  propio, para ver la separación entre motor y modelo.
- 🔥 **Opcional en C:** el ejercicio clásico de listas multienlazadas, en memoria y después sobre un
  archivo con `fseek`, para quien quiera reencontrarse con el original.

> ⚠️ **No hay laboratorio con IMS ni IDMS reales.** No existen ediciones gratuitas ejecutables en
> una laptop, así que DL/I y el DML de CODASYL se enseñan en papel y con los mini DML de L2 y L3.
> Eso hay que decirlo en el texto.

---

## 5. 🧪 Ideas de ejercicios

- 🟢 Dibujar el diagrama de Bachman de `supply` y marcar dueño y miembro en cada set.
- 🟢 Dado un árbol IMS de `escolar`, escribir la secuencia de segmentos en preorden.
- 🟡 Escribir en pseudo DML CODASYL "partes que suministra S1" y "proveedores de P2". Contar los
  accesos a registro de cada una.
- 🟡 Mapear un ER con un muchos-a-muchos a jerárquico (con duplicación) y a red (con registro de
  enlace). Comparar redundancia.
- 🟠 Escribir la ÷ ("proveedores que suministran todas las partes") como programa navegacional y
  como álgebra. Contar líneas y bloques.
- 🟠 Traducir las reglas de inserción y retención de un set a `FOREIGN KEY … ON DELETE` y decir cuál
  no tiene equivalente directo.
- 🔴 Agregar un atributo nuevo y una pregunta nueva a `supply`. Medir cuántas líneas cambian en el
  programa navegacional de L4 y cuántas en la versión relacional.
- 🔴 Diseñar un documento JSON para `escolar` optimizado para una pantalla, y mostrar la consulta
  que lo deja en evidencia como modelo jerárquico.

---

## 6. 📖 Bibliografía y recursos candidatos

⚠️ **Nada verificado.** Todo pasa por P9: existencia, edición, URL y acceso.

- **Papers:** Codd (1970); Bachman, *The Programmer as Navigator* (CACM, 1973); el informe CODASYL
  DBTG (1971); el número especial de *ACM Computing Surveys* de marzo de 1976 (Taylor y Frank sobre
  CODASYL, Tsichritzis y Lochovsky sobre el modelo jerárquico); Stonebraker y Hellerstein, *What Goes
  Around Comes Around* (2005); Stonebraker y Pavlo, *What Goes Around Comes Around… And Around…*
  (SIGMOD Record, 2024); Olson, Bostic y Seltzer, *Berkeley DB* (USENIX, 1999).
- **Libros:** Elmasri y Navathe (los modelos jerárquico y de red estaban en apéndices; verificar si
  la 7.ª edición los conserva y si son en línea); ediciones antiguas de Date, que traían IMS e IDMS;
  Kleppmann, *Designing Data-Intensive Applications*, cap. 2 (verificar el estado de la 2.ª
  edición).
- **Videos:** las clases de historia de bases de datos de Andy Pavlo en CMU (15-445 o 15-721), por
  ubicar.

---

## 7. ❓ Preguntas para Oskar

1. **¿Dónde encaja?** A, B, C o D del §2, o C + D como propongo.
2. **¿Cuánto laboratorio?** De L1 a L5 completos, solo L4 (la comparación), o nada y todo en papel.
3. **¿Entra la versión en C** como 🔥 opcional, o el curso se queda solo con Python?
4. **¿§3.8 (jerarquías en SQL)** se mueve a F10 o F13 aunque el resto quede en un apéndice?
5. **¿Puente con `ruta-no-sql-lite`?** Un 🪞 en su `INSTINTOS.md` del tipo "tu instinto documental
   ya existía en 1968", que remita aquí.
