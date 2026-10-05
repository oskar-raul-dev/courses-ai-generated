# 📚 Inventario de fuentes verificadas (P9)

> **Qué es esto:** lo que la tanda de fuentes comprobó —libros con edición y capítulo, cursos,
> videos, papers, y los datos del bloque A.C.—, con la fecha y la forma en que se comprobó. Es la
> entrada del esqueleto de `a08-mapa-de-bibliografia.md` (T2) y de las fichas de la propuesta de
> fases. **No es material del curso**: el lector ve `a08`, que se escribe desde aquí y vuelve a
> comprobar cada URL el día que la publica (regla 5 del plan).
> **Fecha de la verificación:** 03/10/2026.
> **Cómo se comprobó:** páginas de la editorial, del autor o del catálogo de la plataforma; Open
> Library para ediciones; Crossref para cada DOI; los códigos de estado HTTP desde `mdm-lab`. Los
> scripts están en `verificacion-de-laboratorio/comprobaciones/p9-*.py`. **No se usó ninguna copia no
> autorizada de un libro**, ni siquiera para leer un índice: lo que solo estaba en una copia así
> queda marcado como no verificado.

**Salto rápido:** [1](#1--los-cinco-textos-del-camino-base) · [2](#2--navathe-7ª-contra-las-38-fases) ·
[3](#3--los-otros-cuatro-textos-por-capítulo) · [4](#4--terminología-de-las-ediciones-en-español) ·
[5](#5--cursos-y-videos) · [6](#6--papers-fundacionales-por-fase) · [7](#7--mysql-y-except) ·
[8](#8--bloque-ac) · [9](#9--lo-que-no-se-pudo-verificar)

---

## 1. 📖 Los cinco textos del camino base

| Texto | Edición vigente | Editorial y año | ISBN | Traducción al español |
|---|---|---|---|---|
| Elmasri y Navathe, *Fundamentals of Database Systems* | **7.ª** (no hay 8.ª) | Pearson, publicada el 08/06/2015, © 2016 | 978-0-13-397077-7 | **5.ª ed.**, *Fundamentos de sistemas de bases de datos*, Pearson Educación, Madrid, 2007, ISBN 978-84-7829-085-7. **No se encontró traducción de la 6.ª ni de la 7.ª.** |
| C. J. Date, *An Introduction to Database Systems* | **8.ª** | Addison-Wesley (Pearson), 2003/2004 | 978-0-321-19784-9 | **7.ª ed.**, *Introducción a los sistemas de bases de datos*, Pearson Educación (México), 2001, ISBN 978-968-444-419-5. **No se encontró traducción de la 8.ª.** |
| C. J. Date, *SQL and Relational Theory* | **3.ª** | O'Reilly, 2015 | 978-1-4919-4117-1 | no se encontró |
| Alex Petrov, *Database Internals* | **1.ª** (única) | O'Reilly, 2019 | 978-1-4920-4034-7 | no se encontró (el sitio del autor menciona una traducción al chino) |
| Molinaro y de Graaf, *SQL Cookbook* | **2.ª** | O'Reilly, diciembre de 2020 (Open Library registra 2021) | 978-1-4920-7744-2 | solo la **1.ª**: *Curso de SQL*, Anaya Multimedia/O'Reilly, 2006, trad. Rocío Irigoyen, ISBN 978-84-415-2041-7 |

**Fuentes:** Pearson (página del libro y su índice breve), Open Library (`/isbn/<ISBN>.json`, 200), Dialnet
(Navathe en español), Pearson India (índice de Date 8.ª), librerías para Date y Molinaro en español.

> ⚠️ **Lo que obliga a decir `a08`:** las traducciones al español de Navathe y de Date son de
> **ediciones anteriores** a las que sigue el curso, y **su numeración de capítulos no coincide**.
> `a08` lo advierte, y la tabla libro × fase da el capítulo de la edición en inglés.

---

## 2. 🗺️ Navathe 7.ª contra las 38 fases

**Verificado a nivel de capítulo** contra el índice publicado por Pearson y por un distribuidor
(`cb-india.com`, los mismos 30 capítulos). **Los números de sección (§8.1, §17.3…) que tenían las fichas no
se pudieron verificar**: Pearson solo publica el índice breve, y las únicas fuentes con el índice
completo eran copias no autorizadas. P10 los quita de las fichas y deja el tema en palabras.

**Los capítulos de la 7.ª**, literales: 1 *Databases and Database Users* · 2 *Database Systems Concepts
and Architecture* · 3 *Data Modeling Using the Entity Relationship (ER) Model* · 4 *The Enhanced Entity
Relationship (EER) Model* · 5 *The Relational Data Model and Relational Database Constraints* · 6
*Basic SQL* · 7 *More SQL: Complex Queries, Triggers, Views, and Schema Modification* · 8 *The
Relational Algebra and Relational Calculus* · 9 *Relational Database Design by ER- and
EER-to-Relational Mapping* · 10 *Introduction to SQL Programming Techniques* · 11 *Web Database
Programming Using PHP* · 12 *Object and Object-Relational Databases* · 13 *XML: Extensible Markup
Language* · 14 *Basics of Functional Dependencies and Normalization for Relational Databases* · 15
*Relational Database Design Algorithms and Further Dependencies* · 16 *Disc Storage, Basic File
Structures, Hashing, and Modern Storage Architectures* · 17 *Indexing Structures for Files and Physical
Database Design* · 18 *Strategies for Query Processing* · 19 *Query Optimization* · 20 *Introduction to
Transaction Processing Concepts and Theory* · 21 *Concurrency Control Techniques* · 22 *Database
Recovery Techniques* · 23 *Distributed Database Concepts* · 24 *NOSQL Databases and Big Data Storage
Systems* · 25 *Big Data Technologies Based on MapReduce and Hadoop* · 26 *Enhanced Data Models:
Introduction to Active, Temporal, Spatial, Multimedia, and Deductive Databases* · 27 *Introduction to
Information Retrieval and Web Search* · 28 *Data Mining Concepts* · 29 *Overview of Data Warehousing and
OLAP* · 30 *Database Security*.

**Apéndices** (Pearson): A *Alternative Diagrammatic Notations for ER Models* · B *Parameters of Disks*
· C *Overview of the QBE Language* · **D *Overview of the Hierarchical Data Model*** · **E *Overview of
the Network Data Model***. D y E responden la pregunta del bloque A.C. (§8): la 7.ª los conserva.

| Fase | Capítulo de Navathe 7.ª | ¿Coincide con la ficha? |
|---|---|---|
| F00 | 1 | ✅ |
| F01 | 2 | ✅ |
| F02 | 3 | ✅ |
| F03 | 4 (y apéndice A para las notaciones) | ✅; el apéndice A se agrega |
| F04, F05 | 5 | ✅ |
| F06, F07, F08, F09 | 8 | ✅ (QBE de F09: apéndice C) |
| F10 | 6 y 7 | ✅ |
| F11 | 5 y 7 | ✅ |
| F12 | 7 | ✅ |
| F13 | 9 | ✅ |
| F14, F15, F16 | 14 | ✅ (F15 también 15) |
| F17, F18 | 15 | ✅ |
| F19 | 14 y 15 | ✅ |
| F20 | 17 (diseño físico) | ✅; ya no "a confirmar": el título del capítulo lo incluye |
| F21, F22 | 16 (y apéndice B, parámetros de disco) | ✅; el apéndice B se agrega a F21 |
| F23, F24, F25 | 17 | ✅ |
| F26 | 18 | ✅ |
| F27, F28 | 19 | ✅ |
| F29 | 20 | ✅ |
| F30 | 21 | ✅ |
| F31 | 20 y 21 | ✅ |
| F32 | 22 | ✅ |
| F33 | 1 y 17 | ✅; ya no "a confirmar" |
| F34 | 30 | ✅ |
| F35 | 22 | ✅ el capítulo; **la sección de respaldo y catástrofes, sin verificar** |
| F36 | 26 (bases activas) y 7 (triggers en SQL) | ✅; el 7 se agrega |
| F37 | 23, 24 y 29 | ✅ |

---

## 3. 📗 Los otros cuatro textos, por capítulo

**Date, *An Introduction to Database Systems*, 8.ª** (índice de Pearson India; la numeración sale del
orden): 1 *An Overview of Database Management* · 2 *Database System Architecture* · 3 *An Introduction
to Relational Databases* · 4 *An Introduction to SQL* · 5 *Types* · 6 *Relations* · 7 *Relational
Algebra* · 8 *Relational Calculus* · 9 *Integrity* · 10 *Views* · 11 *Functional Dependencies* · 12
*Further Normalization I: 1NF, 2NF, 3NF, BCNF* · 13 *Further Normalization II: Higher Normal Forms* · 14
*Semantic Modeling* · 15 *Recovery* · 16 *Concurrency* · 17 *Security* · 18 *Optimization* · 19
*Missing Information* · 20–27 (herencia de tipos, distribuidas, soporte a decisiones, temporales,
lógicas, objetos, objeto-relacionales, XML). Apéndice D: *Storage Structures and Access Methods*.

| Fase | Ficha | Verificado | Se agrega |
|---|---|---|---|
| F04 | caps. 3 y 6 | ✅ | |
| F05 | — | | cap. 9 (*Integrity*) |
| F07 | cap. 7 | ✅ | |
| F09 | cap. 8 | ✅ | |
| F11 | — | | cap. 19 (*Missing Information*) |
| F12 | cap. 10 | ✅ | |
| F15 | cap. 11 | ✅ | |
| F16 | — | | cap. 12 |
| F17 | cap. 12 | ✅ (la descomposición sin pérdida está en el 12) | |
| F19 | cap. 13 | ✅ | |
| F28 | — | | cap. 18 (*Optimization*) |

**Date, *SQL and Relational Theory*, 3.ª** (índice de O'Reilly visto en el buscador; la página
devuelve 403 a la lectura directa): 1 *Setting the Scene* · 2 *Types and Domains* · 3 *Tuples and
Relations, Rows and Tables* · 4 *No Duplicates, No Nulls* · 5 *Base Relvars, Base Tables* · 6 *SQL and
Relational Algebra I: The Original Operators* · 7 *SQL and Relational Algebra II: Additional Operators*
· 8 *SQL and Constraints* · 9 *SQL and Views* · 10 *SQL and Logic* · 11 *Using Logic to Formulate SQL
Expressions* · 12 *Miscellaneous SQL Topics*; apéndices A–G (B: *SQL Departures from the Relational
Model*; C: *A Relational Approach to Missing Information*).

| Fase | Ficha | Corrección |
|---|---|---|
| F10 | caps. 1–4 y 10 | ❌ **caps. 6 y 7** (álgebra ↔ SQL, operador por operador), más 10 y 11 para la lógica |
| F11 | caps. 3–4 | ✅ (el 4 es *No Duplicates, No Nulls*); se agrega el apéndice C |
| F12 | — | se agrega el cap. 9 |

**Petrov, *Database Internals*** (Parte I, *Storage Engines*; títulos confirmados en dos fuentes
secundarias, sin índice de la editorial legible): 1 *Introduction and Overview* · 2 *B-Tree Basics* ·
3 *File Formats* · 4 *Implementing B-Trees* · 5 *Transaction Processing and Recovery* · 6 *B-Tree
Variants* · 7 *Log-Structured Storage*. La Parte II (caps. 8–14) es de sistemas distribuidos.

| Fase | Ficha | Verificado |
|---|---|---|
| F21 | caps. 1–3 | ✅ |
| F24 | caps. 2 y 4 | ✅ (el 6, variantes de B-tree, es candidato) |
| F25 | cap. 7 | ✅ |
| F26 | cap. 1 | ✅ |
| F30 | — | se agrega el cap. 5 (control de concurrencia local) |
| F32 | cap. 5 | ✅ |

***SQL Cookbook*, 2.ª**: el cap. 3 es *Working with Multiple Tables* e incluye la receta
*Retrieving Values from One Table That Do Not Exist in Another* (diferencia), confirmada en el índice
de O'Reilly visto en el buscador. **Qué receta trata la división, sin verificar**: F10 lo comprueba o
cita solo el cap. 3.

---

## 4. 🗣️ Terminología de las ediciones en español

**No verificada.** Las únicas fuentes con el texto de las traducciones eran copias no autorizadas, y no
se usaron. Lo que circula en buscadores (que la traducción de Navathe dice "CONCATENACIÓN" por *join*,
por ejemplo) **no se confirmó**.

**Decisión para `a07`:** el glosario fija la terminología **del curso** (la que ya fija la guía, con
el operador en inglés al lado) y deja la columna "en la traducción de…" vacía con la nota "sin
verificar", hasta que Oskar o un lector con el libro la confirme. Ninguna fase afirma cómo traduce un
libro un término.

---

## 5. 🎥 Cursos y videos

**Gratuitos, en inglés, completos** (los tres candidatos de partida del alcance):

| Curso | Dónde | Estado al 03/10/2026 | Uso en el curso |
|---|---|---|---|
| **CMU 15-445/645**, *Intro to Database Systems*, Andy Pavlo | sitio `15445.courses.cs.cmu.edu` (200); lista de YouTube *CMU Intro to Database Systems (15-445/645 - Fall 2025)* del canal *CMU Database Group* (200) | se dicta el **Fall 2026**; la lista completa es la de **Fall 2025** | bloques IV–VI |
| **Berkeley CS186**, *Introduction to Database Systems* | `cs186berkeley.net` (200), Fall 2026 con Alvin Cheung; lista de YouTube *UC Berkeley CS186 (Intro to DB Systems) Playlist* (200) | vigente | bloques IV–VI, y el modelo relacional |
| **Stanford, la serie de Jennifer Widom** | edX, cinco cursos *self-paced* de StanfordOnline: *Relational Databases and SQL* (200, gratuito según su ficha, inglés, 2 semanas), *Advanced Topics in SQL*, *Modeling and Theory*, *OLAP and Recursion*, *Semistructured Data* | vigente | bloques I–III |

**Las clases de CMU 15-445 (Fall 2025) por fase**, de su calendario oficial: 01 *Relational Model &
Algebra* → F04–F07 · 02 *Modern SQL* → F10 · 03 y 05 *Database Storage I/II*, 04 *Memory Management* →
F21 · 06 *Storage Models & Compression* → F21, F37 · 07 *Hash Tables* → F22 · 08 y 09 *Indexes &
Filters I/II* → F23–F25 · 10 *Index Concurrency Control* → F30 · 11 *Sorting & Aggregations
Algorithms*, 12 *Joins Algorithms*, 13 y 14 *Query Execution I/II* → F26 · 15 y 16 *Query Planning &
Optimization I/II* → F27–F28 · 17 *Concurrency Control Theory* → F29 · 18 *Two-Phase Locking*, 19
*Timestamp Ordering*, 20 *Multi-Version Concurrency Control* → F30–F31 · 21 *Database Logging*, 22
*Database Recovery* → F32 · 23 y 24 *Distributed Database Systems I/II* → F37.

**La clase por fase de CS186 y de la serie de Widom, sin verificar**: las listas existen, pero sus
títulos no se pudieron leer de forma automática.

**Coursera** (títulos, instructor e idioma leídos de la página de cada curso, 200):

| Curso | Institución · instructor | Idioma | Bloque |
|---|---|---|---|
| *Relational Database Design* (`illinois-tech-relational-database-design`) | Illinois Tech · Gerald Balekaki, Yousef Elmehdwi | inglés | III |
| *Relational Database Design* (`relational-database-design`), de la especialización *Databases for Data Scientists* | University of Colorado Boulder · Di Wu | inglés | III |
| *Database Management Essentials* (`database-management`) | Michael Mannino | inglés | II–III |
| *Relational database systems* (`relational-database`) | UNAM · María del Pilar Ángeles | inglés | II |
| *Introducción a SQL y bases de datos relacionales* | Universitat Politècnica de València · Nacho Despujol | **español** | II (introductorio) |

💲 **El precio de Coursera no se pudo fijar**: la especialización de Boulder se declara accesible
gratis en sus metadatos, y el certificado es de pago; el resto, sin dato. `a08` lo comprueba el día
que lo publica.

**Udemy: no verificable de forma automática.** Todas sus páginas devuelven 403 a cualquier cliente que
no sea un navegador. Hay candidatos en español sobre diseño relacional y normalización
(`diseno-de-bases-de-datos-relacionales`, `guia-definitiva-diseno-de-bases-de-datos-relacionales`),
pero ni el autor, ni el precio, ni la fecha de actualización están comprobados. **Pendiente de Oskar
en un navegador**, o `a08` sale sin Udemy y lo dice.

---

## 6. 📄 Papers fundacionales por fase

Todos con el DOI resuelto en Crossref el 03/10/2026 (`comprobaciones/p9-papers.py`). `dl.acm.org`
devuelve 403 a los scripts; el DOI es la referencia estable.

| Fase | Paper | Publicación | DOI |
|---|---|---|---|
| F04 | Codd, *A relational model of data for large shared data banks* | CACM 13(6):377–387, 1970 | 10.1145/362384.362685 |
| F02 | Chen, *The entity-relationship model—toward a unified view of data* | ACM TODS 1(1):9–36, 1976 | 10.1145/320434.320440 |
| F11 | Codd, *Extending the database relational model to capture more meaning* | ACM TODS 4(4):397–434, 1979 | 10.1145/320107.320109 |
| F17 | Aho, Beeri y Ullman, *The theory of joins in relational databases* | ACM TODS 4(3):297–314, 1979 | 10.1145/320083.320091 |
| F18 | Bernstein, *Synthesizing third normal form relations from functional dependencies* | ACM TODS 1(4):277–298, 1976 | 10.1145/320493.320489 |
| F19 | Fagin, *Multivalued dependencies and a new normal form for relational databases* | ACM TODS 2(3):262–278, 1977 | 10.1145/320557.320571 |
| F19 | Fagin, *Normal forms and relational database operators* (5FN) | SIGMOD 1979, p. 153 | 10.1145/582095.582120 |
| F22 | Fagin, Nievergelt, Pippenger y Strong, *Extendible hashing* | ACM TODS 4(3):315–344, 1979 | 10.1145/320083.320092 |
| F24 | Bayer y McCreight, *Organization and maintenance of large ordered indexes* | Acta Informatica 1(3):173–189, 1972 | 10.1007/BF00288683 |
| F24 | Comer, *The Ubiquitous B-Tree* | ACM Computing Surveys 11(2):121–137, 1979 | 10.1145/356770.356776 |
| F25 | O'Neil, Cheng, Gawlick y O'Neil, *The log-structured merge-tree (LSM-tree)* | Acta Informatica 33(4):351–385, 1996 | 10.1007/s002360050048 |
| F26 | Graefe, *Volcano—an extensible and parallel query evaluation system* | IEEE TKDE 6(1):120–135, 1994 | 10.1109/69.273032 |
| F28 | Selinger, Astrahan, Chamberlin, Lorie et al., *Access path selection in a relational database management system* | SIGMOD 1979, p. 23 | 10.1145/582095.582099 |
| F29 | Eswaran, Gray, Lorie y Traiger, *The notions of consistency and predicate locks in a database system* | CACM 19(11):624–633, 1976 | 10.1145/360363.360369 |
| F30 | Kung y Robinson, *On optimistic methods for concurrency control* | ACM TODS 6(2):213–226, 1981 | 10.1145/319566.319567 |
| F31 | Berenson, Bernstein, Gray, Melton et al., *A critique of ANSI SQL isolation levels* | SIGMOD 1995, pp. 1–10 | 10.1145/223784.223785 |
| F32 | Haerder y Reuter, *Principles of transaction-oriented database recovery* | ACM Computing Surveys 15(4):287–317, 1983 | 10.1145/289.291 |
| F32 | Mohan, Haderle, Lindsay, Pirahesh et al., *ARIES* | ACM TODS 17(1):94–162, 1992 | 10.1145/128765.128770 |
| F34 | Griffiths y Wade, *An authorization mechanism for a relational database system* | ACM TODS 1(3):242–255, 1976 | 10.1145/320473.320482 |
| F01, F37 | Hellerstein, Stonebraker y Hamilton, *Architecture of a Database System* | Foundations and Trends in Databases 1(2):141–259, 2007 | 10.1561/1900000002 |

**Sin DOI, citados por referencia y no verificados en esta sesión:** Armstrong, *Dependency structures
of data base relationships* (IFIP Congress 1974; F15); Codd, *Relational completeness of data base
sublanguages* (1972; F09); Litwin, *Linear hashing* (VLDB 1980; F22, la URL candidata de vldb.org
devolvió 404).

**Gratis y verificado:** el *Red Book* (*Readings in Database Systems*, 5.ª ed., Bailis, Hellerstein y
Stonebraker) en `redbook.io` (200), útil para F26–F32 y F37.

---

## 7. 🐬 MySQL y `EXCEPT`

**Confirmado** en el manual oficial de MySQL 8.0 (sección *EXCEPT Clause*): *"`EXCEPT` was added in
MySQL 8.0.31."* Admite `DISTINCT` (por defecto) y `ALL`, igual que `UNION` e `INTERSECT`. F10 puede
decirlo así; "MySQL no tiene `EXCEPT`" solo vale para versiones anteriores a la 8.0.31.

---

## 8. 🏛️ Bloque A.C.

### 8.1 Qué motor usa hoy cada producto de AC00

| Producto | Motor hoy | Desde cuándo | Fuente |
|---|---|---|---|
| **Active Directory** | **ESE** (*Extensible Storage Engine*, `Esent.dll`), un ISAM; base `ntds.dit` | desde Windows 2000 ("históricamente llamado Jet") | Microsoft Learn: *How the Data Store Works* (2003) y *Memory usage considerations in AD DS performance tuning* (2019, vigente), que describe la caché de ESE dentro de LSASS |
| **OpenLDAP** | **LMDB** (`back-mdb`), "the recommended primary backend" | `back-bdb` y `back-hdb` obsoletos en 2.4 y **eliminados en 2.5** | guía de administración de OpenLDAP 2.6 y apéndice de cambios de la 2.5 |
| **Subversion** | **FSFS** por defecto; el *back-end* de Berkeley DB, **obsoleto desde la 1.8** (2013) | — | notas de versión de Subversion 1.8 |
| **RPM** | **SQLite** como base de paquetes | **Fedora 33** (2020); antes, Berkeley DB 5 | Fedora Wiki, *Changes/Sqlite_Rpmdb* |
| **Epic** (Chronicles) | **InterSystems IRIS**, una base MUMPS jerárquica | desde la versión de agosto de 2020; antes, otra tecnología de InterSystems durante "más de 40 años" (Caché, según fuentes secundarias) | comunicado de InterSystems en `intersystems.com`, 13/10/2020 |
| **VistA** | MUMPS: el VA, sobre **Caché** de InterSystems; las variantes abiertas (WorldVistA, VistA Forge), sobre **GT.M o YottaDB** | — | hardhats.org, WorldVistA, YottaDB. **Si el VA migró a IRIS, sin verificar.** |

### 8.2 Implementaciones open source (§12.2 de la propuesta)

| Implementación | Estado al 03/10/2026 | Verificación |
|---|---|---|
| GnuCOBOL 3.2 | activo; paquete en Debian, Fedora, Homebrew y Chocolatey | P8, H12: archivo `INDEXED` corrido |
| Harbour 3.2.0 | **primera versión estable en años**, 07/07/2026; último *push* el 01/10/2026 | P8, H12: `.dbf` con `SEEK` corrido |
| YottaDB r2.06 | activo (GitLab `YottaDB/DB/YDB`, 200) | P8, H12: *global* desde M y desde Python |
| GT.M | SourceForge (`fis-gtm`) devuelve 403 a los scripts | **sin verificar** |
| LMDB 0.9.36 (`lmdb` 3.0.0 de PyPI) | activo; `symas.com/mdb` (200) | P8, H12 |
| ZODB 6.3 | activo; `zodb.org` (200) | P8, H12 |
| `dbm` de Python | biblioteca estándar, documentada en Python 3.14.8 (200) | sin correr |
| Berkeley DB | página de Oracle (200) | licencia y última versión **sin verificar** |
| ESE | **abierto por Microsoft**, `microsoft/Extensible-Storage-Engine`, licencia MIT, último *push* 22/05/2026 | sin correr; la propuesta decía "solo Windows" |
| OpenLDAP | solo mención | — |
| Hercules (SDL Hyperion) | activo, release 4.9.1 del 07/12/2025 | sin correr |

### 8.3 Bibliografía del bloque

| Recurso | Estado |
|---|---|
| Codd (1970) | §6 |
| Bachman, *The programmer as navigator*, CACM 16(11):653–658, 1973 | ✅ DOI 10.1145/355611.362534 |
| *ACM Computing Surveys* 8(1), marzo de 1976: Taylor y Frank, *CODASYL Data-Base Management Systems* (10.1145/356662.356666); Tsichritzis y Lochovsky, *Hierarchical Data-Base Management: A Survey* (pp. 105–123, 10.1145/356662.356667); Michaels, Mittman y Carlson, *A Comparison of the Relational and CODASYL Approaches* (pp. 125–151, 10.1145/356662.356668); Chamberlin, *Relational Data-Base Management Systems* (10.1145/356662.356665); Fry y Sibley, *Evolution of Data-Base Management Systems* (10.1145/356662.356664) | ✅ los cinco DOI en Crossref |
| Stonebraker y Pavlo, *What Goes Around Comes Around… And Around…*, SIGMOD Record 53(2):21–37, 2024 | ✅ DOI 10.1145/3685980.3685984; PDF libre en `db.cs.cmu.edu` (200) |
| Stonebraker y Hellerstein, *What Goes Around Comes Around* (2005) | capítulo de *Readings in Database Systems*, 4.ª ed.; **URL libre sin verificar** |
| Olson, Bostic y Seltzer, *Berkeley DB*, USENIX 1999 | ✅ página y PDF en `usenix.org` (200) |
| Informe CODASYL DBTG (1971) | **sin verificar** |
| Navathe 7.ª, apéndices D (jerárquico) y E (red) | ✅ en el índice de Pearson |
| Ediciones antiguas de Date con IMS e IDMS | **sin verificar** cuáles |
| Kleppmann, *Designing Data-Intensive Applications* | 1.ª ed. (O'Reilly, 2017): cap. 2, *Data Models and Query Languages*, con la historia jerárquico/red (fuentes secundarias). **Hay 2.ª ed.** (Kleppmann y Riccomini, O'Reilly, marzo de 2026, ISBN 978-1-0981-1906-5): **su capítulo equivalente, sin verificar** |
| Clases de historia de Pavlo; material de IBM sobre IMS | **sin verificar** |

---

## 9. 📌 Lo que no se pudo verificar

- **Las secciones de Navathe** (§2): se citan capítulos.
- **La terminología de las traducciones** (§4).
- **Udemy entero y el precio de Coursera** (§5): pendiente de Oskar en un navegador.
- **La clase por fase de CS186 y de la serie de Widom** (§5).
- **La receta de división del *SQL Cookbook*** (§3).
- **Armstrong (1974), Codd (1972) y Litwin (1980)**, sin DOI (§6).
- **GT.M, Berkeley DB, el informe DBTG, las ediciones antiguas de Date, la 2.ª ed. de Kleppmann, las
  clases de historia de Pavlo y el material de IMS** (§8).
- **Si el VA corre VistA sobre IRIS** (§8.1).

Cada uno lo resuelve la fase que lo necesita, en su paso 1, o sale del curso con la nota "sin
verificar". Ninguno bloquea T1 ni T2.
