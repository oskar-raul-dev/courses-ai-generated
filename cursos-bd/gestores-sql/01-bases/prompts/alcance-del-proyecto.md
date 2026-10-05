# 🎯 Alcance del proyecto
## El motor de motores — La teoría que todos los gestores SQL implementan

> **Qué es este documento:** la fuente de verdad de **qué** enseña el curso, a quién y con qué
> límites. Lo que no esté aquí, no está en el curso.
> **Fecha de cierre de esta versión:** 2 de octubre de 2026, con las decisiones D1–D18 y A–E
> cerradas por Oskar ese día (§13).
> **Precedencia:** manda este documento; después
> [`guia-de-estilo-y-convenciones.md`](guia-de-estilo-y-convenciones.md), que decide **cómo** se
> escribe; después [`propuesta-fases-y-alcance.md`](propuesta-fases-y-alcance.md) y
> [`propuesta-apendices-y-alcance.md`](propuesta-apendices-y-alcance.md); y las plantillas y los
> prompts se actualizan siempre al final. Por encima de todos, el `CLAUDE.md` del repositorio en lo
> que este curso no haya declarado como excepción (§13.3).

---

## 1. 🧭 En una frase

**Un curso de teoría de bases de datos con el rigor y la densidad de ejercicios de un libro de texto
universitario, escrito para desarrolladores que usan bases de datos todos los días y nunca vieron
por qué funcionan.**

No enseña ningún motor. Enseña lo que todos los motores implementan —el modelo relacional, sus
lenguajes formales, la teoría de diseño, las estructuras de acceso, la implementación de los
operadores, la concurrencia, la recuperación y lo esencial de la administración— de forma que el
lector pueda **demostrarlo en papel** y **verificarlo en una herramienta**. Es la base de la familia
`gestores-sql`: el motor que está debajo de los otros seis cursos.

---

## 2. 🔥 El problema que resuelve

La mayoría de los desarrolladores aprendió bases de datos al revés: primero SQL, después un ORM, y
la teoría nunca. Funciona hasta que deja de funcionar, y cuando deja de funcionar falta el
vocabulario para entender qué pasó. Quien no sabe calcular una clausura de atributos no puede
explicar por qué su tabla tiene anomalías de actualización; quien no sabe qué es un plan
serializable por conflicto no puede razonar sobre por qué `REPEATABLE READ` dejó pasar lo que dejó
pasar; quien nunca insertó a mano en un árbol B+ no tiene intuición de por qué una clave primaria
aleatoria fragmenta un índice; quien nunca escribió una diferencia sin `EXCEPT` no sabe por qué su
`NOT IN` devolvió cero filas.

La teoría existe y está muy bien escrita, pero vive en libros de ochocientas páginas, en inglés o en
traducciones de hace dos ediciones, y pensados para un semestre con profesor y ayudantes. **El
lector de este curso estudia solo**, así que necesita lo que el ayudante le daría: cada ejercicio
con su solución desarrollada paso a paso, no solo el resultado.

> 🧠 **El villano no es SQL ni el ORM.** Es **usar una herramienta sin el modelo que la explica**.
> SQL es una aproximación práctica a un modelo matemático preciso, y los lugares donde se aparta de
> ese modelo —multiconjuntos, `NULL`, el orden— son justo los lugares donde nacen los bugs que nadie
> entiende.

---

## 3. 🎓 Objetivo pedagógico

Al terminar el camino base, el estudiante puede hacer seis cosas que antes no podía:

1. **Modelar un dominio** en ER/EER y mapearlo a un esquema relacional con el algoritmo, justificando
   cada decisión de cardinalidad, participación y especialización.
2. **Escribir y leer consultas en los tres lenguajes formales** —álgebra relacional, cálculo de
   tuplas y cálculo de dominios— y traducirlas a SQL y desde SQL, diciendo exactamente dónde SQL se
   aparta del modelo. En particular, **escribir cualquier operador con los cinco primitivos**
   {σ, π, ∪, −, ×}, y la diferencia y la división en SQL sin los operadores que SQL no tiene.
3. **Diseñar y demostrar un esquema normalizado**: calcular clausuras, claves candidatas y
   recubrimientos mínimos; descomponer a 3FN o FNBC con el algoritmo; probar que la descomposición
   es sin pérdida y decir qué dependencias preserva; reconocer DMV y dependencias de join.
4. **Calcular el costo de acceso** de una organización de archivo, un índice o un plan en accesos a
   bloque, y **ejecutar a mano —y en código— los algoritmos** con que un motor implementa cada
   operador: ordenamiento externo, los joins, π con eliminación de duplicados y las operaciones de
   conjuntos por ordenamiento y por hash.
5. **Razonar sobre concurrencia y recuperación con formalismo**: grafos de precedencia, 2PL, marcas
   de tiempo, anomalías por nivel de aislamiento y ARIES sobre una bitácora.
6. **Entender lo core de la administración**: el trabajo del DBA, el catálogo, la autorización
   (`GRANT`, `REVOKE` y su grafo), el respaldo y la continuidad, y los triggers como bases activas.

Lo que **no** es objetivo: dominar un motor, tunear una instancia, ni preparar una certificación de
producto. Eso es materia de los cursos de motor.

---

## 4. 👥 Perfil del estudiante

Desarrollador con experiencia que **usa** bases de datos y escribe SQL con soltura, pero no tuvo
—o no recuerda— un curso formal de bases de datos. También sirve a quien está cursando uno en la
universidad y necesita un segundo texto con más ejercicios resueltos.

**Lo que se da por sabido y no se explica:** qué es una tabla, escribir un `SELECT` con `JOIN`,
`GROUP BY` y subconsultas, usar una línea de comandos, instalar un programa.

**Lo que sí se explica desde la definición**, aunque el lector lo use a diario: qué es un índice,
qué es una transacción, qué es una clave. Es una excepción declarada al `CLAUDE.md` (§13.3): el
lector conoce el **uso** de estas cosas y viene a aprender su **teoría**.

**Requisitos matemáticos:** teoría de conjuntos elemental, lógica de predicados a nivel de leer
"para todo" y "existe", y la idea de una demostración. Lo que haga falta se repone en el apéndice
`a06-la-matematica-minima.md`.

> 🧭 **"Riguroso" en este curso significa definido y demostrable, no críptico.** Toda definición
> formal va acompañada de su intuición y de un ejemplo resuelto. Si un lector con buena voluntad no
> puede seguir un paso, el paso está mal escrito.

**Cada estudiante avanza a su ritmo.** No hay pruebas de nivel ni autodiagnósticos para saltar
bloques (D5): el índice y las dependencias de cada fase bastan para que cada uno elija por dónde
entrar.

---

## 5. 🧱 La forma del curso

**Bloques con fases**, como `ruta-sql` y `ruta-no-sql-lite` (D2). **No hay historia ni empresa
narrativa**: las fases son directas, con teoría, ejemplos resueltos, ejercicios y bibliografía. El
orden lo marca la dependencia conceptual, igual que en un libro, y la guía es Elmasri y Navathe.

| Bloque | Fases | Horas | Ejercicios |
|---|---|---|---|
| 0 · El terreno | F00–F01 | 10 | 42 |
| I · Modelado conceptual | F02–F03 | 20 | 66 |
| **II · El modelo relacional ⭐** | F04–F13 | 110 | 384 |
| **III · Diseño y normalización ⭐** | F14–F20 | 80 | 263 |
| IV · Almacenamiento e índices | F21–F25 | 50 | 177 |
| V · Implementación de operadores y optimización | F26–F28 | 40 | 115 |
| VI · Transacciones | F29–F32 | 45 | 154 |
| VII · Administración: lo core | F33–F36 | 40 | 124 |
| VIII · Panorama | F37 | 8 | 20 |
| **Camino base** | **38 fases** | **≈ 403 h** | **1 345** |
| 🏛️ A.C. — Antes de Codd (opcional) | AC00–AC09 | ≈ 67 h | 221 |

**Los bloques II y III son el énfasis del curso** y suman 190 h, casi la mitad. A 12 h semanales, el
camino base son unas 34 semanas. La duración es la que el contenido necesita (D13); si el material
se lleva a YouTube, se poda después. El detalle de cada fase está en
[`propuesta-fases-y-alcance.md`](propuesta-fases-y-alcance.md).

**Un hilo recorre el curso de punta a punta: π y −** 🧵. La proyección y la diferencia se siguen
desde la definición (F06–F07) hasta el antijoin (F08), sus formas en SQL, incluida la diferencia sin
`EXCEPT` y la división que SQL nunca tuvo (F10), los multiconjuntos (F11) y su implementación por
ordenamiento y por hash en el mini motor (F26).

Cada fase cumple un contrato fijo, que detallan la guía de estilo (§8) y las plantillas:

- **Teoría por andamio:** el problema que motiva el concepto, la definición formal, la intuición,
  un ejemplo resuelto y, cuando aplica, la verificación ejecutable.
- **De la teoría a los motores:** qué se transfiere tal cual a SQL y a los motores reales, y dónde se
  aparta, con remisión en prosa al curso de motor que lo mide.
- **Errores conceptuales comunes**, con su contraejemplo.
- **⚖️ Hasta dónde llega la teoría:** cuándo no conviene aplicar lo que la fase acaba de enseñar. Es
  la forma que toma aquí el veredicto honesto del repositorio.
- **Una batería larga y graduada de ejercicios**, con solución desarrollada en el solucionario (§7).
- **Bibliografía y recursos por fase**: libros con capítulo, cursos de Udemy y Coursera, cursos
  completos en YouTube, papers y otros recursos, todos verificados (§9).

---

## 6. 🔬 Cómo se verifica: en papel y en herramienta

Este curso **no mide**: demuestra y verifica. Es la razón de que no tenga `BENCHMARKS.md` (§13.3).

- **Lo formal se demuestra en papel.** Una clausura, una descomposición, un grafo de precedencia o
  una inserción en un árbol B+ se resuelven paso a paso, y la solución muestra los pasos.
- **El álgebra se ejecuta en `radb`** (D15), un intérprete de álgebra relacional por línea de
  comandos que traduce a SQL y corre sobre SQLite. Cubre σ, π, ρ, ⋈, ×, ∪, −, ∩ y agregación con
  agrupamiento. **No tiene** ÷, outer join, semijoin ni antijoin, y el curso lo aprovecha: el lector
  los escribe con los primitivos, que es justo el ejercicio de "cómo implemento lo que no existe".
- **El SQL se ejecuta en SQLite con tablas `STRICT`**, sobre los mismos archivos `.db` que usa
  `radb`. `STRICT` evita que la afinidad de tipos de SQLite contradiga la teoría de dominios; donde
  SQLite igual se aparte del modelo, el texto lo dice. La salida de ambas herramientas se copia
  literal.
- **Los algoritmos se contrastan con verificadores** (D9): scripts en Python, solo con la biblioteca
  estándar, que calculan clausuras, claves candidatas, recubrimientos mínimos, descomposiciones, el
  *chase*, inserciones en B+ y serializabilidad. Sirven para que el autor no publique un paso mal
  hecho y para que el lector compruebe los suyos.
- **El mini motor** (decisión A) implementa en Python los operadores como iteradores, con un
  contador de bloques leídos: es donde la diferencia y la proyección se implementan sin SQL.
- **Los costos se calculan, no se miden.** Las afirmaciones de "X es mejor que Y" se sostienen sobre
  el modelo de costo de la fase (accesos a bloque, pasadas, altura del árbol) y se dice que es un
  modelo. La medición en un motor real es materia del bloque VI de cada curso de motor.

> ⚠️ **La regla de la casa, aplicada aquí:** nada se publica sin haberse ejecutado o verificado.
> Ninguna salida de `radb` ni de SQLite reconstruida de memoria, ningún paso de una solución sin
> contrastar. Lo que no se verificó se declara con esas palabras.

---

## 7. 🧪 Los ejercicios son el centro del curso

- **De 30 a 45 por fase** (D3), 18–20 en las de panorama, al estilo de los ejercicios de fin de
  capítulo de Elmasri y Navathe. Unos 1 345 en el camino base y 221 en el bloque A.C.
- **Graduados** con la escala del repositorio, 🟢🟡🟠🔴, más 🔥 para ampliaciones.
- **De cinco tipos**, marcados en el título: ✍️ cálculo en papel, 🔎 verificación en herramienta,
  🧮 demostración o refutación, 🧩 modelado y 📖 lectura guiada de una fuente.
- **Cada uno con criterio de éxito explícito y con su solución desarrollada**: los pasos, no solo el
  resultado; la salida literal de la herramienta cuando la hubo; una rúbrica en los abiertos.
- **Originales.** Se inspiran en el tipo de ejercicio de los libros de referencia, pero no se copian
  sus enunciados ni sus datos. Para práctica adicional, la bibliografía remite a los ejercicios del
  libro por su número.
- **El solucionario va aparte** (D4): `soluciones/NN-slug.md`, con el mismo nombre que la fase, para
  que el lector no vea la solución por accidente. Una fase no está terminada mientras su
  solucionario no esté completo y verificado.
- **No hay examen ni boss por bloque** (decisión C): la batería de cada fase cumple ese papel.

---

## 8. 🏫 Las bases de ejemplo

**Todos los identificadores van en inglés (D17), también en el álgebra y en el cálculo**:
`π name (σ city = 'Lima' (supplier))`. Lo que el lector escribe en papel es lo mismo que ejecuta en
`radb` y en SQLite, y lo mismo que va a leer en Navathe y en Date. Relaciones y atributos en
`snake_case` y en singular. La prosa sigue en español.

- **`school`, el sistema escolar** (D6): `school_year`, `term`, `grade_level`, `section`, `subject`,
  `teacher`, `student`, `guardian`, `enrollment`, `teaching_assignment`, `assessment`, `score` y
  `classroom`. Sirve para ER y EER, entidades débiles, división, recursión (prerrequisitos) y la
  planilla de notas desnormalizada. **La palabra `grade` sola no se usa en ningún identificador**,
  porque en inglés significa tanto el nivel como la nota.
- **`supply`, proveedores, partes, proyectos y pedidos**: el clásico de Date (`supplier`, `part`,
  `project`, `shipment`), que es el ejemplo canónico de 5FN y de división, ampliado con el otro
  clásico, los pedidos (`customer`, `sales_order`, `order_line`). La factura plana recorre la
  normalización de F14 a F16, y el precio de la línea frente al de la parte es el caso de una
  dependencia funcional que parece existir y no existe.
- **Relaciones abstractas** `R(A, B, C, …)` para la teoría de dependencias, y **planes sobre ítems**
  `X`, `Y` para transacciones, como en los libros.

Los datos chicos se escriben a mano, para seguirlos en papel. Los volúmenes grandes se generan con
**Faker y una semilla fija** (D16), con la versión de Faker fijada, para que todos tengan los mismos
datos. El detalle vive en `a04-las-bases-de-ejemplo.md`.

---

## 9. 📚 La bibliografía

**Cinco textos para el camino base** (D10), con Navathe como guía:

1. Elmasri y Navathe, *Fundamentals of Database Systems*, 7.ª ed. — **la guía**: el orden y la
   profundidad de casi todas las fases.
2. C. J. Date, *An Introduction to Database Systems*, 8.ª ed. — **la biblia** del modelo relacional,
   la teoría de dependencias y la crítica a SQL.
3. C. J. Date, *SQL and Relational Theory*, 3.ª ed. (O'Reilly) — **el puente moderno**: SQL escrito
   relacionalmente.
4. Alex Petrov, *Database Internals* (O'Reilly) — **los internals modernos**: B-tree, LSM, buffer y
   recuperación.
5. Molinaro y de Graaf, *SQL Cookbook*, 2.ª ed. (O'Reilly) — **SQL general**: diferencia, división y
   relaciones en SQL real.

Silberschatz, Garcia-Molina–Ullman–Widom y Ramakrishnan–Gehrke quedan fuera como textos base, aunque
una fase puede citarlos puntualmente. El bloque A.C. tiene su propia bibliografía, que no cuenta
contra este tope.

**Cursos y videos** (D11): Udemy, Coursera y cursos completos en YouTube (los candidatos de partida
son CMU 15-445/645, Berkeley CS186 y la serie de Jennifer Widom de Stanford), más papers
fundacionales por fase. RelaX aparece como complemento visual opcional.

> ⚠️ **Ningún recurso se cita sin comprobarlo en la misma sesión**: libro con edición y capítulo,
> URL con su código de estado, curso con su plataforma, idioma, si es de pago 💲 y la fecha de
> verificación. A igual calidad, gana el gratuito y el que está en español. Las ediciones y el mapa
> de capítulos se fijaron en la tanda de fuentes (P9, 03/10/2026, `prompts/inventario-de-fuentes.md`)
> y viven en `a08-mapa-de-bibliografia.md`.

---

## 10. 🧰 El stack del curso

- **SQLite**, nativo en Windows, macOS y Linux (D12), con versión que admita `STRICT`. Sin
  contenedores en el camino base: es un binario, y el archivo `.db` es un archivo más del disco, que
  el lector aprende a copiar, mover y respaldar sin corromperlo (`a01`).
- **Python 3 con `venv`** (D16), solo para automatizar, verificar y generar datos: `radb`, Faker,
  los verificadores y el mini motor. `venv` porque viene con Python; nada de `uv` ni `conda`.
- **`radb`**, instalado con `pip` dentro del `venv`.
- **Lápiz y papel.** La mitad de los ejercicios se resuelven así, y el curso lo dice.
- 🔥 **Un contenedor opcional con todo lo anterior** (`a09`), para quien prefiera no instalar nada,
  con un PostgreSQL extra para practicar `GRANT` y `REVOKE` en F34. Se cita, nunca se exige.

Las versiones se fijaron en la tanda de verificación (P8, 03/10/2026,
`prompts/verificacion-de-laboratorio/hallazgos.md`) y viven en los apéndices `a01`–`a03`.

---

## 11. ✅ Lo que está dentro del alcance

- Los nueve bloques del camino base, con el énfasis en el modelo relacional y en la normalización.
- La teoría de **todas** las estructuras de índice que los cursos de motor van a medir: B y B+,
  hashing estático, extensible y lineal, listas invertidas, bitmap, árboles R, LSM, índices
  multiclave y de cuadrícula.
- **La implementación de los operadores**, con π, ∪, ∩ y − por ordenamiento y por hash, en papel y
  en el mini motor.
- Los puntos exactos donde SQL se aparta del modelo relacional: multiconjuntos, `NULL` y la lógica de
  tres valores, el orden y los duplicados.
- **Lo core de la administración**: el DBA y el catálogo, la seguridad y la autorización, el respaldo
  y la continuidad, y los triggers.
- El bloque opcional A.C. (§14).

## 12. 🚫 Lo que está fuera del alcance

- **Cualquier motor concreto**, salvo SQLite como instrumento. Lo de cada motor está en su curso.
- **Benchmarks y mediciones de rendimiento.** Ver §6.
- **SQL como lenguaje de trabajo**: se usa y se analiza a la luz de la teoría, pero no se enseña
  desde cero ni se cubren dialectos.
- **Administración operativa de un motor** (instalar un servidor, configurarlo, tunearlo): el curso
  da la teoría y los cursos de motor la aplican.
- **Bases distribuidas, NoSQL y analíticas en profundidad.** F37 las presenta y remite a la Ruta
  NoSQL Lite.
- **Bases temporales, espaciales, deductivas, XML, objeto-relacionales y recuperación de
  información** como teoría propia (decisión D): a lo sumo una mención en F37 o en AC05.

---

## 13. ⚖️ Decisiones cerradas

Cerradas quiere decir cerradas: si una sesión futura quiere cambiar una, primero la cambia aquí y
después en todo lo demás, nunca al revés.

### 13.1 D1–D18 (02/10/2026)

1. **D1 · Nombre:** *El motor de motores*, subtítulo *La teoría que todos los gestores SQL
   implementan*. Carpeta `01-bases/`.
2. **D2 · Estructura:** bloques con fases (§5).
3. **D3 · Ejercicios:** 30–45 por fase, 18–20 en las de panorama.
4. **D4 · Soluciones:** solucionario aparte, `soluciones/NN-slug.md`.
5. **D5 · Sin autodiagnóstico por bloque.** Cada estudiante avanza a su ritmo.
6. **D6 · Bases de ejemplo:** `school` y `supply` con pedidos (§8).
7. **D7 · Notación:** Unicode (σ, π, ⋈, ρ, γ, ÷, ⟕, ⋉, ▷, →, ↠), nunca LaTeX.
8. **D8 · Diagramas:** ASCII en bloques `text`, 75 columnas como máximo siempre que se pueda.
9. **D9 · Verificadores en Python**, en `src/`.
10. **D10 · Bibliografía:** cinco textos, Navathe como guía (§9).
11. **D11 · Cursos:** Udemy, Coursera y cursos completos en YouTube.
12. **D12 · Laboratorio:** SQLite nativo, con apéndice de instalación y del archivo físico; el
    contenedor solo como apéndice opcional.
13. **D13 · Duración:** la que haga falta; se poda después para YouTube.
14. **D14 · `INSTINTOS.md`:** se mantiene, con al menos un 🪞 por bloque.
15. **D15 · `radb`** como intérprete de álgebra, en lugar de RelaX.
16. **D16 · Python con `venv` y Faker** para automatizar y generar datos.
17. **D17 · Identificadores en inglés en todas partes**, también en el álgebra.
18. **D18 · Bloque opcional A.C. — Antes de Codd**, al final y autocontenido (§14).

### 13.2 A–E (02/10/2026)

- **A · Mini motor:** entra, en F26, en Python con biblioteca estándar.
- **B · F34 se verifica en papel**, con el grafo de autorización; PostgreSQL en el contenedor
  opcional como 🔥.
- **C · Sin examen ni boss por bloque.**
- **D · Temas fuera:** los de §12, con mención en F37 o AC05.
- **E · Bloque A.C.:** laboratorio completo (L1–L5); AC09 en C entra; con la Ruta NoSQL Lite, solo
  referencias de concepto; casos de estudio Git (AC06), LMDB (AC07) y YottaDB (AC08).

### 13.3 Excepciones declaradas al `CLAUDE.md` del repositorio

El `CLAUDE.md` permite que un curso se aparte de los defaults **si nombra la regla y dice por qué**.
La guía de estilo (§16) las repite para que ninguna sesión futura las "arregle" de vuelta.

1. **Sin benchmarks ni `BENCHMARKS.md`.** Las afirmaciones "X es mejor que Y" se respaldan con el
   modelo de costo de la fase, calculado y declarado como modelo, porque el curso es de teoría y no
   tiene motor que medir. La medición vive en los cursos de motor.
2. **Forma de fase de libro de texto**, no la lección por defecto (setup → conceptos →
   anti-patrones → traducción → ejercicios → veredicto). Los elementos del repositorio se conservan
   reinterpretados: la ⚰️ autopsia de anti-patrón pasa a ser **errores conceptuales con
   contraejemplo**, y el ⚖️ veredicto pasa a ser **hasta dónde llega la teoría**.
3. **Más ejercicios, no menos**: 30–45 por fase en vez de 20–30, con solución desarrollada aparte.
4. **Se explica desde la definición lo que el lector ya usa** (índices, transacciones, claves).
5. **Sin historia narrativa**, a diferencia de los cursos hermanos de `cursos-bd/`.
6. **"Enseña modelos de acceso, no productos" no aplica en su forma habitual**, porque aquí no hay
   productos: el curso entero es el modelo. La pregunta del repositorio —*¿qué modelo de acceso tiene
   mi dominio?*— reaparece en los bloques IV y V como pregunta de costo, y en el bloque A.C. como
   navegar contra declarar.
7. **Comentarios de código en español con tildes**, como en los cursos hermanos de `cursos-bd/`,
   en lugar del inglés del default. Los identificadores sí van en inglés.

Todo lo demás del `CLAUDE.md` aplica tal cual: idioma, tono, convenciones de markdown, nombres de
archivo (incluido el prefijo de track del bloque A.C.), escala de ejercicios y flujo de git.

---

## 14. 🏛️ El bloque opcional "A.C. — Antes de Codd"

**Opcional, autocontenido y fuera de las horas del camino base.** Solo lo lee quien quiere; nada del
camino base depende de él. Sus fases llevan el prefijo de track del repositorio (`acNN-slug.md`),
sus tags el espacio `ac-fase-<slug>`, y lo que necesite de propio —prompts, plantilla, apéndices
`aca-NN-…`— va en archivos nuevos, nunca añadido a los del camino base.

**La tesis:** el modelo jerárquico y el de red son **navegacionales** (el programa recorre punteros
y el camino de acceso queda fijo en el esquema); el relacional es **declarativo**. Estudiar el
"antes" explica el porqué del camino base (independencia de datos, integridad referencial, ÷,
índices), explica NoSQL (un documento es un árbol jerárquico, un grafo es una red) y **no es
arqueología inútil**: los modelos navegacionales siguen vivos en Active Directory y LDAP, el Registro
de Windows, los *globals* de MUMPS en sistemas clínicos, Git, los ORM con su N+1 y los motores
embebidos como LMDB, ESE, LevelDB o IndexedDB.

| Fase | Contenido |
|---|---|
| AC00 | Navegar contra declarar, y 🏺 por qué estudiar arqueología |
| AC01 | Archivos, registros y punteros en disco; motor contra modelo |
| AC02 | El modelo jerárquico (IMS, DL/I) |
| AC03 | El modelo de red (CODASYL) |
| AC04 | El Gran Debate, y la misma pregunta en los dos mundos |
| AC05 | Los herederos: documentos, grafos, objetos (con ZODB), ORM |
| AC06 | Caso de estudio: Git |
| AC07 | Caso de estudio: LMDB, el motor sin modelo |
| AC08 | Caso de estudio: YottaDB, el jerárquico en producción |
| AC09 | Pedidos en C: el modelo de red a mano, en ANSI C |

**Laboratorio:** cinco laboratorios en Python (gestor de registros paginado, `supply` en red,
`school` en jerárquico, la misma pregunta en dos mundos, `dbm` como motor) y AC09 en **ANSI C por
línea de comandos, compilable con GCC y con Visual C++**, con el código entregado hecho y abierto a
ejercicios. YottaDB corre en contenedor fuera de Linux (`aca-02`), porque es una sección para quien
no tiene problema con contenedores. **No hay laboratorio con IMS ni IDMS reales**, porque no existen
ediciones gratuitas para una laptop, y el texto lo dice.

Con la Ruta NoSQL Lite hay **solo referencias de concepto**: ese curso no se modifica.

---

## 15. 🎯 Criterios de éxito

El curso está bien si:

- **Un lector que estudia solo puede resolver los ejercicios** y, si se traba, la solución le muestra
  el paso que le faltó, no solo el resultado.
- **Ninguna solución publicada tiene un paso mal hecho.** El verificador o la herramienta la
  contrastó, y la fecha está escrita.
- **El lector puede escribir la diferencia y la división en SQL de cuatro formas distintas** y decir
  cuál falla con `NULL` y por qué.
- **Cada fase dice dónde SQL y los motores se apartan de la teoría**, y a qué curso de motor ir para
  medirlo.
- **La bibliografía sirve un año después**: cada recurso tiene fecha de verificación, y los cursos de
  pago lo dicen.
- **Los cursos de motor pueden remitir aquí** en vez de repetir la teoría de índices, concurrencia y
  recuperación.

---

## 16. 🗺️ Relación con el resto del repositorio

- **Los seis cursos de motor de `gestores-sql/`** (`02-postgresql` a `07-oracle`) son independientes
  pero se apoyan en este: su bloque VI retoma los bloques IV a VI de aquí y los mide. Este curso
  remite a ellos **en prosa y sin enlace mientras no existan**.
- **`ruta-sql/`** enseña a elegir y medir entre motores con narrativa propia, y aplica la
  normalización y el aislamiento a casos de empresa. Este curso es su base teórica; no se repiten,
  se complementan.
- **`ruta-no-sql-lite/`** es el destino de F37 y de AC05 para quien quiera seguir hacia otras
  familias. Solo se citan sus conceptos.
- **`docker-container-legacy/`** se enlaza cuando un apéndice de contenedores necesite explicar el
  mecanismo.
- **`ruta-no-sql-lite/prompts/`** y **`ruta-sql/prompts/`** aportan el andamiaje editorial que este
  curso imita.
