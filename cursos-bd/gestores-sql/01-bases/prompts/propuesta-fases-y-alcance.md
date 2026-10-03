# 🗺️ Propuesta de fases y alcance
## El motor de motores — 38 fases en nueve bloques, más el bloque opcional A.C.

> **Qué es este documento:** el temario. Qué fases hay, qué entra en cada una, cómo se verifica,
> cuántas horas y cuántos ejercicios. Es la fuente de verdad de la estructura del curso.
> **Precedencia:** por encima están [`alcance-del-proyecto.md`](alcance-del-proyecto.md) y
> [`guia-de-estilo-y-convenciones.md`](guia-de-estilo-y-convenciones.md); al lado,
> [`propuesta-apendices-y-alcance.md`](propuesta-apendices-y-alcance.md). Por debajo, las plantillas
> y los prompts, que se actualizan después y nunca al revés.
> **Fecha:** 2 de octubre de 2026, con las decisiones D1–D18 y A–E del alcance (§13) cerradas.

---

## ⏱️ 1. Reparto horario

**Camino base: ≈ 403 h ÷ 12 h semanales ≈ 34 semanas**, unos ocho meses. A 10 h semanales son
unas 40 semanas. La duración es la que el contenido necesita (D13); si el material se lleva a
YouTube, se poda después.

Las horas de los **apéndices no cuentan**: son consulta bajo demanda. Las del **bloque A.C.
tampoco**: es opcional y vive fuera del calendario del camino base.

| Bloque | Fases | Horas | Ejercicios |
|---|---|---|---|
| **0 · El terreno** | F00–F01 | 10 | 42 |
| **I · Modelado conceptual** | F02–F03 | 20 | 66 |
| **II · El modelo relacional ⭐** | F04–F13 | 110 | 384 |
| **III · Diseño y normalización ⭐** | F14–F20 | 80 | 263 |
| **IV · Almacenamiento e índices** | F21–F25 | 50 | 177 |
| **V · Implementación de operadores y optimización** | F26–F28 | 40 | 115 |
| **VI · Transacciones** | F29–F32 | 45 | 154 |
| **VII · Administración: lo core** | F33–F36 | 40 | 124 |
| **VIII · Panorama** | F37 | 8 | 20 |
| **Camino base** | **38 fases** | **403 h** | **1 345** |
| 🏛️ **A.C. — Antes de Codd** (opcional) | AC00–AC09 | 67 h | 221 |

**Los bloques II y III son el énfasis del curso**: 190 h, casi la mitad. Es donde Navathe pone su
mayor densidad, y donde el lector que viene de SQL tiene más que aprender.

### 1.1 El hilo de π y − 🧵

La proyección y la diferencia se siguen de punta a punta, desde la definición hasta la
implementación. Cada fase del hilo lo marca con 🧵 en su título de sección.

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

### 1.2 Por qué este orden

Es el de Navathe, con dos cambios deliberados. **El mapeo ER → relacional (F13) va al final del
Bloque II** y no justo después del ER, porque el mapeo usa claves foráneas, integridad referencial
y vistas, y es más sólido cuando el lector ya domina el modelo. **SQL (F10–F12) se estudia después
de los tres lenguajes formales** y no antes, porque el curso lo mira a la luz de la teoría: el
lector ya sabe SQL, y lo que le falta es ver dónde se aparta del modelo.

---

## 🧱 2. La forma de una fase

Cada fase cumple el contrato de la guía de estilo (§8), con su plantilla en
[`plantillas-de-capitulo.md`](plantillas-de-capitulo.md): dónde estamos, objetivos verificables,
qué no entra, **la teoría por andamio** (problema, definición, intuición, ejemplo resuelto,
verificación), de la teoría a los motores, el 🪞 cuando lo hay, errores conceptuales con
contraejemplo, traducción de notación en las dos direcciones, ⚖️ hasta dónde llega la teoría,
resumen, ejercicios con su solucionario aparte, bibliografía en cuatro grupos y cierre.

Las fichas de este documento dicen **qué cambia de fase a fase**:

- **Lectura base** — el capítulo de Navathe 7.ª ed. que la fase sigue. ⚠️ Los números de capítulo
  son de memoria y **se confirman en P9**, junto con los de los otros cuatro textos.
- **Qué entra** — el piso de la fase, no el techo.
- **Verificación** — con qué se comprueba lo que se muestra: ✍️ papel, `radb`, SQLite, un
  verificador o el mini motor.
- **🪞 candidato** y **⚖️ candidato** — puntos de partida; la fase puede encontrar uno mejor.
- **🏛️** — si lleva el recuadro opcional hacia el bloque A.C.
- **Tipos dominantes** — qué tipos de ejercicio cargan la batería.

**Longitud del cuerpo:** la fija la tabla de la guía de estilo (§8) según las horas de cada fase,
de 2.000–3.000 palabras en F00, F37 y AC00 hasta 5.500–7.500 en las fases de 14–16 h.

---

## 🧱 3. Bloque 0 · El terreno (10 h)

Pone el vocabulario y deja las herramientas funcionando. Es la puerta de entrada del curso.

### 🗄️ F00 — El sistema de bases de datos y sus actores (4 h · 18 ejercicios)

**Lectura base:** Navathe, cap. 1. **Depende de:** nada · **Habilita:** F01.

**Qué entra:** qué resuelve un DBMS frente a archivos sueltos con aplicación dueña (redundancia,
inconsistencia, acceso concurrente, recuperación, seguridad); las características del enfoque de
bases de datos (catálogo autodescriptivo, abstracción, vistas múltiples, transacciones); los actores
(DBA, diseñadores, usuarios finales, analistas y programadores, y los que trabajan "detrás de
escena"); ventajas y costos; **cuándo no usar un DBMS**.

**Verificación:** ✍️ papel. Esta fase se lee; no usa herramientas.

**🪞 candidato:** *"Tu instinto dice que un archivo JSON bien organizado ya es una base de datos… y
esta vez se equivoca"*: le faltan catálogo, concurrencia, recuperación y un lenguaje declarativo.

**⚖️ candidato:** cuándo un archivo plano o una hoja de cálculo es la decisión correcta, con el
costo de cada una.

**Tipos dominantes:** 📖 y 🧩 (de lectura y decisión sobre sistemas descritos).

### 🏗️ F01 — Conceptos y arquitectura (6 h · 24 ejercicios) · 🏛️

**Lectura base:** Navathe, cap. 2. **Depende de:** F00 · **Habilita:** F02, F04.
**Apéndices de apoyo:** a01, a02, a03, a04.

**Qué entra:** modelos de datos (conceptuales, de representación, físicos); esquema contra estado
(intensión y extensión); la arquitectura ANSI/SPARC de tres niveles y los *mappings* entre ellos;
**independencia lógica y física**, con ejemplos de qué cambio rompe a quién; lenguajes (DDL, DML,
SDL, VDL; procedural contra declarativo); componentes de un DBMS y sus módulos; el catálogo; la
historia de los modelos **en una página**, con la distinción navegacional contra declarativo. Primer
contacto con SQLite y `radb` sobre `school`: leer el catálogo con `sqlite_schema` y ejecutar la
primera proyección.

**Verificación:** SQLite (catálogo) y `radb` (la primera consulta).

**🪞 candidato:** *"Tu instinto dice que cambiar un índice o mover una tabla de disco no le importa
a la aplicación… y tiene razón, y por eso existe ANSI/SPARC"* (es un 🩻 disfrazado de 🪞).

**⚖️ candidato:** la independencia lógica completa no existe en la práctica: qué cambios de esquema
siguen rompiendo vistas y aplicaciones.

**🏛️:** antes de Codd, la estructura de acceso estaba en el esquema lógico → AC00.

**Tipos dominantes:** 📖, 🔎 (catálogo y primeras consultas) y 🧩.

---

## 🧩 4. Bloque I · Modelado conceptual (20 h)

El lector modela `school` de punta a punta. Lo que sale de aquí se mapea al relacional en F13.

### 🧩 F02 — Modelo entidad-relación (10 h · 34 ejercicios)

**Lectura base:** Navathe, cap. 3. **Depende de:** F01 · **Habilita:** F03, F13.

**Qué entra:** entidades y conjuntos de entidades; atributos simples y compuestos, monovaluados y
multivaluados, almacenados y derivados, y `NULL` en el modelo conceptual; claves; tipos de relación,
grado, y relaciones recursivas con sus roles; **restricciones de razón de cardinalidad y de
participación**, y la notación min-max; entidades débiles, clave parcial y relación identificadora;
atributos de relación y dónde se pueden mover; el diseño de `school` paso a paso, con las decisiones
discutibles a la vista (¿la calificación es atributo de la matrícula o una entidad?); el total del
pedido de `supply` como atributo derivado.

**Verificación:** ✍️ papel. Los diagramas van en ASCII de 75 columnas.

**🪞 candidato:** *"Tu instinto dice que cada sustantivo del enunciado es una entidad… y esta vez se
equivoca"*: varios son atributos, otros son relaciones.

**⚖️ candidato:** el ER no captura todas las restricciones del dominio; las que quedan fuera se
anotan y se resuelven en el esquema relacional o en la aplicación.

**Tipos dominantes:** 🧩 (modelado), ✍️ (lectura de diagramas) y 🟠 de detectar errores de modelado.

### 🧩 F03 — ER extendido y notaciones (10 h · 32 ejercicios) · 🏛️

**Lectura base:** Navathe, cap. 4. **Depende de:** F02 · **Habilita:** F13.

**Qué entra:** subclases, superclases y herencia; especialización y generalización; restricciones
de disyunción y de completitud, y sus cuatro combinaciones; jerarquías y retículos; categorías
(tipos unión) y en qué se distinguen de una generalización; las notaciones —Chen, pata de gallo, UML
y min-max— y la traducción entre ellas; `school` con docentes y personal administrativo como
especialización, y apoderados como categoría.

**Verificación:** ✍️ papel.

**⚖️ candidato:** cuándo una jerarquía EER complica más de lo que modela, y conviene un atributo de
tipo.

**🏛️:** los diagramas de Bachman, antecesores de la pata de gallo → AC03.

**Tipos dominantes:** 🧩 y ✍️ (traducir entre notaciones).

---

## 📐 5. Bloque II · El modelo relacional ⭐ (110 h)

El corazón del curso, junto con el Bloque III. El lector sale escribiendo cualquier consulta en
álgebra, en cálculo y en SQL, y sabiendo exactamente dónde SQL se aparta del modelo.

### 📐 F04 — El modelo relacional, formalmente (10 h · 38 ejercicios)

**Lectura base:** Navathe, cap. 5 (§5.1). Date, *An Introduction…*, caps. 3 y 6. **Depende de:**
F01 · **Habilita:** F05, F06. **Apéndices de apoyo:** a06, a07.

**Qué entra:** dominio, atributo, tupla y relación como **conjunto** de tuplas; grado y
cardinalidad; por qué las tuplas no tienen orden y los atributos tampoco (y las dos definiciones de
tupla: secuencia o función); valores atómicos y 1FN como parte de la definición; `NULL` y sus tres
significados (desconocido, inaplicable, no informado); esquema de relación y estado; superclave,
clave, clave candidata, primaria y alternativa, clave foránea; la escala de notas de `school` como
dominio.

**Verificación:** ✍️ papel y SQLite `STRICT` (lo que un dominio permite y lo que rechaza).

**🪞 candidato:** *"Tu instinto dice que una relación es una tabla… y esta vez se equivoca"*: la
tabla admite duplicados, orden y `NULL`; la relación, no (o no del mismo modo).

**⚖️ candidato:** SQL no implementa dominios como tipos de verdad; `CHECK` y `STRICT` llegan hasta
cierto punto.

**Tipos dominantes:** ✍️ y 🧮 (probar que un conjunto de atributos es o no clave).

### 📐 F05 — Restricciones y operaciones de actualización (10 h · 36 ejercicios) · 🏛️

**Lectura base:** Navathe, cap. 5 (§5.2–5.3). **Depende de:** F04 · **Habilita:** F06, F12, F36.

**Qué entra:** restricciones inherentes, explícitas (de esquema) y semánticas (de aplicación);
restricciones de dominio, de clave y de `NULL`; integridad de entidad e integridad referencial;
**qué viola cada inserción, borrado y modificación**, caso por caso, y las opciones para resolverlo
(rechazar, cascada, `SET NULL`, `SET DEFAULT`); restricciones que el modelo no puede expresar (las
del total del pedido, la nota dentro de la escala del país); la transacción como unidad de
actualización, en anticipo de F29.

**Verificación:** SQLite `STRICT` con `PRAGMA foreign_keys = ON`, y la salida literal de cada
violación.

**🪞 candidato:** *"Tu instinto dice que la clave foránea protege la integridad siempre… y en SQLite
se equivoca si no activaste `foreign_keys`"* (verificar el comportamiento por defecto en P8).

**⚖️ candidato:** `ON DELETE CASCADE` como atajo que borra más de lo que nadie quería.

**🏛️:** las reglas de inserción y retención de CODASYL como antecesoras del `ON DELETE` → AC03.

**Tipos dominantes:** ✍️ (qué viola qué), 🔎 (provocar cada violación).

### 📐 F06 — Álgebra relacional I: operaciones unarias (12 h · 40 ejercicios) · 🧵

**Lectura base:** Navathe, cap. 8 (§8.1). **Depende de:** F05 · **Habilita:** F07.
**Apéndices de apoyo:** a03, a07.

**Qué entra:** el álgebra como lenguaje cerrado; **σ**: condición, selectividad, conmutatividad y
cascada (σ c1 (σ c2 (R)) = σ c1 ∧ c2 (R)); **π**: lista de atributos, **eliminación de duplicados**,
grado y cardinalidad del resultado, cascada de proyecciones (π L1 (π L2 (R)) = π L1 (R) si L1 ⊆ L2),
cuándo π y σ conmutan y cuándo no; **ρ** para renombrar relaciones y atributos; secuencias de
operaciones y asignación (←); cómo se lee una expresión anidada.

**Verificación:** `radb` sobre `school` y `supply`, con la salida literal, y el SQL que genera.

**🪞 candidato:** *"Tu instinto dice que π es `SELECT columnas`… y esta vez se equivoca"*: `SELECT`
sin `DISTINCT` no elimina duplicados. Se verifica contando tuplas en `radb` y en SQLite.

**⚖️ candidato:** la eliminación de duplicados no es gratis; su costo se calcula en F26.

**Tipos dominantes:** ✍️ (escribir expresiones), 🔎 (≥ 1/3 en `radb`) y 🧮 (demostrar las leyes).

### 📐 F07 — Álgebra relacional II: conjuntos, joins y división (14 h · 45 ejercicios) · 🧵 🏛️

**Lectura base:** Navathe, cap. 8 (§8.2–8.3). Date, *An Introduction…*, cap. 7. **Depende de:** F06
· **Habilita:** F08, F09, F10.

**Qué entra:** compatibilidad de unión; **∪, ∩ y −**, sus propiedades (∪ e ∩ conmutan y asocian; −
no conmuta ni asocia) y R ∩ S = R − (R − S); el producto cartesiano y su grado; θ-join, equijoin y
join natural, y cómo los tres se escriben con × y σ; **la división**: definición, intuición ("los
que se relacionan con *todos*") y **su escritura con π, × y −**, con la demostración; **el conjunto
completo {σ, π, ∪, −, ×}** y la demostración de que ∩, ⋈ y ÷ se derivan de él; *"proveedores que
suministran todas las partes rojas"* y *"alumnos que rindieron todas las evaluaciones de su
sección"*.

**Verificación:** `radb` para ∪, ∩, −, ×, ⋈. **`radb` no tiene ÷**: la división se ejecuta
escrita con los primitivos, y la fase lo dice y lo aprovecha.

**🪞 candidato:** *"Tu instinto dice que 'todos' se escribe con un `JOIN`… y esta vez se
equivoca"*: el join responde "alguno"; "todos" es división, o doble negación.

**⚖️ candidato:** la división escrita con primitivos es correcta y es cara; los motores no la
implementan como operador y conviene saber por qué.

**🏛️:** la ÷ en el modelo de red es un programa de dos bucles anidados con currency → AC04.

**Tipos dominantes:** ✍️ y 🔎 (≥ 1/3), y al menos cinco 🧮 (derivar operadores de los primitivos).

### 📐 F08 — Álgebra relacional III: operaciones extendidas (12 h · 40 ejercicios) · 🧵

**Lectura base:** Navathe, cap. 8 (§8.4). **Depende de:** F07 · **Habilita:** F10, F26.

**Qué entra:** proyección generalizada (atributos calculados); **γ**: funciones de agregación y
agrupamiento, y por qué rompe la clausura de conjuntos si no se cuida; la operación de clausura
recursiva y por qué el álgebra básica no puede expresarla; outer joins (⟕ ⟖ ⟗) y el `NULL` que
introducen; outer union; **semijoin (⋉) y antijoin (▷), con el antijoin escrito con −**:
R ▷ S = R − (R ⋉ S); árboles de consulta como notación, en anticipo de F27.

**Verificación:** `radb` para γ (con agrupamiento). **`radb` no tiene outer join, ⋉ ni ▷**: se
escriben con primitivos y se ejecutan así; los outer joins se contrastan además en SQLite.

**⚖️ candidato:** el álgebra extendida pierde propiedades del álgebra básica (por ejemplo, γ y π no
conmutan libremente); el optimizador lo sabe y el lector también tiene que saberlo.

**Tipos dominantes:** ✍️ y 🔎 (≥ 1/3), 🧮 (equivalencias del antijoin).

### 📐 F09 — Cálculo relacional (12 h · 36 ejercicios)

**Lectura base:** Navathe, cap. 8 (§8.6–8.7). Date, *An Introduction…*, cap. 8. **Depende de:** F07
· **Habilita:** F10. **Apéndices de apoyo:** a06.

**Qué entra:** cálculo relacional de tuplas: variables de tupla, rangos, fórmulas atómicas,
cuantificadores libres y ligados; **∀ escrito con ¬∃** y su uso para la división; expresiones
seguras e inseguras, con el contraejemplo de una consulta infinita; cálculo relacional de dominios;
**equivalencia con el álgebra** (teorema de Codd) y la idea de completitud relacional; QBE como
mención; traducir cada consulta de F07 al cálculo y de vuelta.

**Verificación:** ✍️ papel. El cálculo no se ejecuta; se traduce al álgebra y se verifica allí con
`radb`, y la fase lo dice.

**🪞 candidato:** *"Tu instinto dice que el SQL que escribes es álgebra… y esta vez se equivoca"*:
su `WHERE EXISTS` es cálculo de tuplas.

**⚖️ candidato:** la seguridad de una expresión no es decidible en general; los lenguajes reales la
garantizan por sintaxis.

**Tipos dominantes:** ✍️ (traducciones) y 🧮 (seguridad, equivalencias); pocos 🔎.

### 📐 F10 — Del álgebra a SQL, operador por operador (14 h · 45 ejercicios) · 🧵

**Lectura base:** Navathe, caps. 6 y 7. Date, *SQL and Relational Theory*, caps. 1–4 y 10. *SQL
Cookbook*, recetas de diferencia y división. **Depende de:** F07, F08, F09 · **Habilita:** F11, F12.

**Qué entra:** cada operador del álgebra en SQL y de vuelta, con la tabla de traducción en las dos
direcciones; **π sin `DISTINCT` devuelve un multiconjunto**; **la diferencia en todas sus formas**
—`EXCEPT` contra `EXCEPT ALL`, `NOT EXISTS`, `LEFT JOIN … IS NULL` y `NOT IN`—, cuál es equivalente
a cuál y **cuál falla con `NULL`**, con el contraejemplo; cómo se escribía la diferencia en motores
sin `EXCEPT` (en MySQL hasta la 8.0.31, a confirmar en P9); **la división, que SQL nunca tuvo**: con
doble `NOT EXISTS` y con conteo, y por qué la de conteo falla con duplicados; `INTERSECT` y sus
alternativas; outer union; la clausura con `WITH RECURSIVE` (prerrequisitos de `subject`); la
subconsulta correlacionada como cálculo de tuplas.

**Verificación:** SQLite para todo el SQL y `radb` para la expresión de álgebra de la que sale; la
comparación de resultados es la prueba de fuego de la fase.

**🪞 candidato:** *"Tu instinto dice que `NOT IN` y `NOT EXISTS` son lo mismo… y esta vez se
equivoca"*: basta un `NULL` en la subconsulta para que `NOT IN` devuelva cero filas.

**⚖️ candidato:** la forma más legible de una diferencia no siempre es la que el optimizador
ejecuta mejor; el curso de motor lo mide.

**Tipos dominantes:** 🔎 (≥ 1/2, SQL y álgebra contrastados) y ✍️; al menos tres 🧮 (equivalencias
bajo `NULL`).

### 📐 F11 — `NULL`, lógica de tres valores y multiconjuntos (10 h · 36 ejercicios) · 🧵

**Lectura base:** Navathe, caps. 5 y 7. Date, *SQL and Relational Theory*, caps. 3–4. **Depende
de:** F10 · **Habilita:** F12, F26.

**Qué entra:** las tablas de verdad de `UNKNOWN`; `NULL` en comparaciones, en `WHERE` frente a
`CHECK`, en agregados, en `GROUP BY`, en `DISTINCT`, en `UNIQUE` y en claves foráneas; por qué
`COUNT(*)` y `COUNT(col)` difieren; **el álgebra de multiconjuntos**: ∪, ∩ y − con multiplicidad
(`UNION ALL`, `INTERSECT ALL`, `EXCEPT ALL`) y π sin eliminación de duplicados; qué leyes del
álgebra de conjuntos dejan de valer con bolsas; la crítica de Date a `NULL`, presentada con sus
argumentos y con los de la otra parte.

**Verificación:** SQLite para cada caso, con la salida literal. ⚠️ Si SQLite no implementa
`INTERSECT ALL` o `EXCEPT ALL`, se dice, se escribe la alternativa y se remite a los cursos de motor
(verificar en P8).

**🪞 candidato:** *"Tu instinto dice que `NULL = NULL` es verdadero… y esta vez se equivoca"*: es
`UNKNOWN`, y `WHERE` lo descarta.

**⚖️ candidato:** evitar `NULL` por diseño tiene su propio costo (más relaciones, más joins);
cuándo vale la pena.

**Tipos dominantes:** 🔎 y ✍️ (tablas de verdad); 🧮 (qué leyes fallan en bolsas).

### 📐 F12 — Vistas y el problema de actualizarlas (6 h · 30 ejercicios)

**Lectura base:** Navathe, cap. 7 (§7.3). Date, *An Introduction…*, cap. 10. **Depende de:** F05,
F10 · **Habilita:** F13, F36.

**Qué entra:** la vista como consulta con nombre y como nivel externo de ANSI/SPARC; vistas
materializadas como concepto (sin motor); **cuándo una vista es actualizable** y por qué la de un
join, una agregación o una proyección sin la clave no lo es en general; la ambigüedad de traducir
una actualización de la vista a las relaciones base, con contraejemplo; `WITH CHECK OPTION`; los
triggers `INSTEAD OF` como salida, en anticipo de F36.

**Verificación:** SQLite (incluido lo que SQLite no permite actualizar en una vista y cómo lo
resuelve con `INSTEAD OF`).

**⚖️ candidato:** una vista que oculta un join caro sigue siendo un join caro.

**Tipos dominantes:** ✍️ (¿es actualizable?), 🔎 y 🧮 (la ambigüedad de la traducción).

### 📐 F13 — Del ER/EER al modelo relacional (10 h · 38 ejercicios) · 🏛️

**Lectura base:** Navathe, cap. 9. **Depende de:** F02, F03, F05, F12 · **Habilita:** F14.

**Qué entra:** el algoritmo de mapeo en siete pasos (entidades fuertes, débiles, relaciones 1:1,
1:N y M:N, atributos multivaluados, relaciones n-arias) y los pasos de EER (**las cuatro opciones
para mapear una jerarquía**, con el costo de cada una en `NULL`, joins y restricciones); categorías;
`school` y `supply` mapeados de punta a punta; ida y vuelta: reconstruir el ER desde un esquema
existente. **Jerarquías dentro del modelo relacional**: lista de adyacencia, conjuntos anidados,
camino materializado y tabla de clausura, con su costo en lectura y escritura.

**Verificación:** SQLite (el DDL resultante, cargado con los datos chicos de `a04`) y `radb` (una
consulta por opción de jerarquía).

**⚖️ candidato:** el mapeo es mecánico pero no único; dos esquemas correctos pueden diferir en
costo, y el Bloque III dice cuál está mejor diseñado.

**🏛️:** lo que IMS resolvía con punteros, aquí se resuelve con cuatro esquemas → AC02.

**Tipos dominantes:** 🧩 (mapear), ✍️ y 🔎.

---

## 🧱 6. Bloque III · Diseño y normalización ⭐ (80 h)

La teoría de diseño con todo su rigor. La planilla de notas de `school` y la factura plana de
`supply` lo recorren de punta a punta; las relaciones abstractas `R(A, B, C, …)` son el campo de
entrenamiento de los algoritmos.

### 🧱 F14 — Guías informales de diseño y anomalías (8 h · 30 ejercicios)

**Lectura base:** Navathe, cap. 14 (§14.1). **Depende de:** F13 · **Habilita:** F15.

**Qué entra:** las cuatro guías informales (semántica clara, sin redundancia, sin `NULL` evitables,
sin tuplas espurias); anomalías de inserción, borrado y modificación, con su ejemplo en **la
planilla de notas** de `school` y **la factura plana** de `supply`; tuplas espurias al juntar una
mala descomposición, mostradas con datos.

**Verificación:** SQLite y `radb` (la tupla espuria aparece en la salida).

**⚖️ candidato:** las guías informales no bastan para decidir; por eso existe la teoría formal de
F15 en adelante.

**Tipos dominantes:** ✍️ y 🔎 (provocar cada anomalía).

### 🧮 F15 — Dependencias funcionales (14 h · 45 ejercicios)

**Lectura base:** Navathe, cap. 14 (§14.2) y cap. 15 (§15.1). Date, *An Introduction…*, cap. 11.
**Depende de:** F14 · **Habilita:** F16, F17, F18. **Apéndices de apoyo:** a05, a06.

**Qué entra:** definición formal; **una DF es del esquema, no del estado** (el precio de la línea
contra el de la parte: los datos pueden cumplirla hoy sin que exista); DF triviales; axiomas de
Armstrong **con la demostración de su solidez** y la idea de su completitud; reglas derivadas
(unión, descomposición, pseudotransitividad) con su derivación; **clausura de un conjunto de
atributos** (el algoritmo y su traza); clausura F⁺; equivalencia de conjuntos de DF; **recubrimiento
mínimo** (atributos extraños, DF redundantes, y por qué no es único); **cálculo de todas las claves
candidatas**.

**Verificación:** verificadores `closure`, `min_cover` y `keys` (nacen en esta fase y se documentan
en `a05`).

**🪞 candidato:** *"Tu instinto dice que si los datos cumplen X → Y, entonces hay una DF… y esta vez
se equivoca"*: un estado no prueba una DF; solo puede refutarla.

**⚖️ candidato:** encontrar todas las claves candidatas es exponencial en el peor caso; con
esquemas reales se hace bien, y la fase muestra cuándo no.

**Tipos dominantes:** ✍️ (≥ 1/2: clausuras, recubrimientos y claves), 🧮 (al menos cinco) y 🔎
(verificadores).

### 🧱 F16 — Formas normales: de 1FN a FNBC (12 h · 42 ejercicios)

**Lectura base:** Navathe, cap. 14 (§14.3–14.5). **Depende de:** F15 · **Habilita:** F17, F18.

**Qué entra:** atributos primos y no primos; 1FN y lo que viola (atributos multivaluados y
anidados); 2FN y 3FN **en su versión basada en la clave primaria y en la versión general**
(sobre todas las claves candidatas), y por qué difieren; FNBC; **la relación que está en 3FN y no en
FNBC**, con el ejemplo clásico de dos claves superpuestas; cómo demostrar en qué forma normal está
una relación; la factura plana llevada paso a paso hasta FNBC.

**Verificación:** verificador `normal_form`, y SQLite para mostrar que las anomalías de F14
desaparecen.

**🪞 candidato:** *"Tu instinto dice que 3FN alcanza siempre… y esta vez se equivoca"*: el caso de
claves candidatas superpuestas.

**⚖️ candidato:** FNBC no siempre se puede alcanzar sin perder una dependencia (anticipo de F17).

**Tipos dominantes:** ✍️ y 🧮 (probar la forma normal), carga hacia 🟠 y 🔴.

### 🧮 F17 — Propiedades de las descomposiciones (12 h · 40 ejercicios)

**Lectura base:** Navathe, cap. 15 (§15.2). Date, *An Introduction…*, cap. 12. **Depende de:** F16
· **Habilita:** F18.

**Qué entra:** descomposición y propiedad de atributos; **preservación de dependencias**:
proyección de F sobre un esquema y el algoritmo para comprobarla sin calcular F⁺; **join sin
pérdida**: la prueba NJB para dos relaciones y **el algoritmo de la tabla (*chase*)** para n, con
traza completa; por qué un join sin pérdida no garantiza preservar dependencias ni al revés; el
contraejemplo de FNBC que no preserva.

**Verificación:** verificadores `njb`, `chase` y `preserves`, y `radb` para mostrar las tuplas
espurias de una descomposición con pérdida.

**⚖️ candidato:** cuando no se puede tener FNBC y preservación a la vez, se elige; el costo de cada
elección es una restricción que hay que controlar con un join o con un trigger.

**Tipos dominantes:** ✍️ (trazas del *chase*), 🧮 y 🔎.

### 🧮 F18 — Algoritmos de diseño relacional (12 h · 40 ejercicios)

**Lectura base:** Navathe, cap. 15 (§15.3). **Depende de:** F17 · **Habilita:** F19, F20.

**Qué entra:** **síntesis a 3FN** con join sin pérdida y preservación de dependencias, con la
demostración de ambas propiedades; **descomposición a FNBC** con join sin pérdida; el no
determinismo de los dos algoritmos (resultados distintos según el orden), con ejemplos; problemas
de `NULL` en las claves foráneas y tuplas colgantes; los dos algoritmos aplicados a `school` y a
`supply`, comparados con el esquema que salió del mapeo en F13.

**Verificación:** verificadores `synth_3nf` y `bcnf_decompose`, más `chase` y `preserves` sobre el
resultado.

**⚖️ candidato:** los algoritmos producen esquemas correctos y a veces absurdos (relaciones de dos
atributos que nadie consulta por separado); el criterio de diseño sigue haciendo falta.

**Tipos dominantes:** ✍️ (correr los algoritmos), 🔎 y 🧮.

### 🧱 F19 — Más allá de FNBC (12 h · 36 ejercicios)

**Lectura base:** Navathe, cap. 14 (§14.6–14.7) y cap. 15 (§15.4–15.7). Date, *An Introduction…*,
cap. 13. **Depende de:** F18 · **Habilita:** F20.

**Qué entra:** dependencias multivaluadas (↠): definición, intuición y reglas de inferencia; 4FN y
la descomposición a 4FN; **dependencias de join y 5FN**, con la restricción cíclica
proveedor–parte–proyecto de `supply`, el ejemplo canónico; dependencias de inclusión; DKNF como
ideal teórico; otras dependencias (de plantilla, funcionales con condición) como mención.

**Verificación:** ✍️ papel y `radb` (la descomposición de `shipment` en tres proyecciones y el join
que la reconstruye).

**🪞 candidato:** *"Tu instinto dice que una tabla de tres columnas con todo en la clave no se puede
normalizar más… y esta vez se equivoca"*: 4FN y 5FN viven justo ahí.

**⚖️ candidato:** la 5FN casi nunca se aplica en la práctica; cuándo sí, y qué cuesta reconocerla.

**Tipos dominantes:** 🧮 y ✍️, carga hacia 🟠 y 🔴.

### 🧱 F20 — Desnormalización y diseño físico (10 h · 30 ejercicios)

**Lectura base:** Navathe, cap. 17 (diseño físico y tuning; ubicación a confirmar en P9). **Depende
de:** F18 · **Habilita:** F21, F33.

**Qué entra:** cuándo romper la norma y qué se paga, en anomalías y en mantenimiento; tablas de
resumen, columnas derivadas (el total del pedido), particionado vertical y horizontal; **por qué
guardar el precio en la línea no es desnormalizar** (es otro hecho del dominio); decisiones de
diseño físico a partir de la carga de consultas (frecuencia, selectividad, tipo de acceso), en
anticipo del Bloque IV.

**Verificación:** ✍️ papel y SQLite (mantener una columna derivada a mano y ver la anomalía
cuando se olvida).

**⚖️ candidato:** la desnormalización es una deuda con interés compuesto; la fase calcula cuántas
escrituras extra cuesta cada lectura ahorrada.

**Tipos dominantes:** 🧩 (decidir el diseño), ✍️ (costos) y 🟠 de decisión.

---

## 💾 7. Bloque IV · Almacenamiento e índices (50 h)

Aquí vive la **teoría** de las estructuras de acceso. Los cursos de motor la retoman en su bloque VI
y la miden en lo que cada motor implementa.

### 💾 F21 — Discos, bloques y organización de archivos (10 h · 32 ejercicios)

**Lectura base:** Navathe, cap. 16 (§16.1–16.7). Petrov, *Database Internals*, caps. 1–3.
**Depende de:** F20 · **Habilita:** F22, F23.

**Qué entra:** jerarquía de memoria; discos y SSD (lo que cambia y lo que no para el modelo de
costo); bloques, factor de bloqueo, registros de longitud fija y variable, *spanned* y *unspanned*;
archivos heap y ordenados, y el costo de buscar, insertar y borrar en cada uno; buffer pool y
políticas de reemplazo (LRU, clock, MRU), con su traza; RAID como mención.

**Verificación:** ✍️ papel (costos en bloques), y el tamaño de página y el número de páginas de una
base de SQLite como ventana (`PRAGMA page_size`, `PRAGMA page_count`).

**🪞 candidato:** *"Tu instinto dice que leer un registro cuesta lo mismo esté donde esté… y esta
vez se equivoca"*: cuesta un bloque, y el bloque es la unidad de todo el bloque IV.

**⚖️ candidato:** el modelo de costo en bloques simplifica el disco real (caché, lectura anticipada,
SSD); sirve para comparar, no para predecir tiempos.

**Tipos dominantes:** ✍️ (≥ 1/2: costos y trazas del buffer).

### 💾 F22 — Hashing (10 h · 34 ejercicios)

**Lectura base:** Navathe, cap. 16 (§16.8). **Depende de:** F21 · **Habilita:** F25, F26.

**Qué entra:** hashing interno y externo; funciones de hash y colisiones; hashing estático con
cubetas y desbordes, y su degradación; **hashing extensible** (directorio, profundidad global y
local, división y duplicación del directorio) y **hashing lineal** (puntero de división, nivel),
ambos paso a paso con traza; costo de búsqueda e inserción.

**Verificación:** ✍️ papel. Un verificador `ext_hash`/`linear_hash` es candidato: si se escribe, se
agrega a `a05`.

**⚖️ candidato:** el hash no sirve para rangos ni para orden; por eso los motores lo usan poco como
índice primario.

**Tipos dominantes:** ✍️ (trazas), 🟢 y 🟡 cargados.

### 💾 F23 — Índices de uno y varios niveles (8 h · 32 ejercicios)

**Lectura base:** Navathe, cap. 17 (§17.1–17.2). **Depende de:** F21 · **Habilita:** F24.

**Qué entra:** índice primario, de agrupamiento (*clustering*) y secundario; denso y disperso;
cuántos índices de cada tipo puede tener un archivo; índices multinivel y su *fan-out*; el costo en
bloques de cada uno, calculado.

**Verificación:** ✍️ papel.

**⚖️ candidato:** cada índice secundario se paga en cada escritura; la fase calcula cuánto.

**Tipos dominantes:** ✍️ (costos).

### 🌳 F24 — Árboles B y B+ (12 h · 45 ejercicios) · 🏛️

**Lectura base:** Navathe, cap. 17 (§17.3). Petrov, *Database Internals*, caps. 2 y 4. Bayer y
McCreight (1972). **Depende de:** F23 · **Habilita:** F25, F26.

**Qué entra:** orden de un árbol B y de un B+, y la diferencia entre nodos internos y hojas;
búsqueda; **inserción con división** y **borrado con fusión y redistribución**, a mano y con traza
completa; altura mínima y máxima, y el número de accesos; carga masiva (*bulk loading*) y su
ocupación; **por qué una clave aleatoria fragmenta** y una creciente no.

**Verificación:** verificador `bplus` (inserción y borrado con traza ASCII de 75 columnas), y SQLite
como ventana (`sqlite3_analyzer` o `dbstat`, si P8 confirma que están disponibles).

**🪞 candidato:** *"Tu instinto dice que da igual si la clave primaria es un UUID aleatorio o un
entero creciente… y esta vez se equivoca"*: se calcula la ocupación de las hojas en los dos casos.

**⚖️ candidato:** el B+ es el mejor índice general y no el mejor para todo; F25 dice para qué no.

**🏛️:** los punteros entre registros de CODASYL como la otra cara de los índices → AC01.

**Tipos dominantes:** ✍️ (≥ 1/2: trazas), 🔎 (verificador) y algunos 🧮 (cotas de altura).

### 💾 F25 — Otras estructuras de índice (10 h · 34 ejercicios)

**Lectura base:** Navathe, cap. 17 (§17.4–17.6). Petrov, *Database Internals*, cap. 7 (LSM). O'Neil
et al. (1996). **Depende de:** F22, F24 · **Habilita:** F26.

**Qué entra:** índices sobre varias claves y el orden de las columnas; índices de cuadrícula
(*grid files*); **bitmap** y su compresión; **listas invertidas** para texto; **árboles R** para
datos espaciales; **árboles LSM** (*memtable*, niveles, compactación, amplificación de escritura y
de lectura); índices de función; costo de mantener cada uno.

**Verificación:** ✍️ papel (costos y trazas).

**⚖️ candidato:** cada estructura gana en un patrón de acceso y pierde en otro; la tabla de cierre
de la fase dice cuál, con el costo.

**Tipos dominantes:** ✍️ y 🧩 (elegir la estructura para un patrón de acceso).

---

## ⚙️ 8. Bloque V · Implementación de operadores y optimización (40 h)

Cómo se ejecuta lo que el Bloque II definió. **F26 es donde el hilo de π y − llega a su
implementación**, y el mini motor es el entregable del bloque.

### ⚙️ F26 — Cómo se implementa cada operador (16 h · 45 ejercicios) · 🧵

**Lectura base:** Navathe, cap. 18. Petrov, *Database Internals*, cap. 1 (como contexto).
**Depende de:** F08, F11, F24, F25 · **Habilita:** F27, F28. **Apéndices de apoyo:** a05.

**Qué entra:** ordenamiento externo (*merge sort* de varias pasadas, número de pasadas y costo);
selección: búsqueda lineal, binaria, por índice primario, de agrupamiento y secundario, y selección
conjuntiva; **join**: nested loop, por bloques, por índice, sort-merge y hash (con particionado), con
el costo de cada uno; **π con eliminación de duplicados, por ordenamiento y por hash; ∪, ∩ y − por
sort-merge y por hash**; agregación por ordenamiento y por hash; outer join; *pipelining* contra
materialización; **el mini motor**: los operadores como iteradores (`open`, `next`, `close`), con un
contador de bloques leídos, sobre los datos de `supply`.

**Verificación:** el mini motor (cada algoritmo implementado y su contador comparado con el costo
calculado en papel) y `EXPLAIN QUERY PLAN` de SQLite como ventana.

**🪞 candidato:** *"Tu instinto dice que `DISTINCT` es gratis… y esta vez se equivoca"*: cuesta un
ordenamiento o una tabla hash, y la fase calcula cuánto.

**⚖️ candidato:** ningún algoritmo de join gana siempre; la tabla de cierre dice cuál gana según
tamaños, memoria e índices.

**Tipos dominantes:** ✍️ (costos), 🔎 (mini motor, ≥ 1/3) y 🧩 (implementar un operador).

### ⚙️ F27 — Optimización heurística (10 h · 34 ejercicios)

**Lectura base:** Navathe, cap. 19 (§19.1). **Depende de:** F26 · **Habilita:** F28.

**Qué entra:** árboles de consulta y grafos de consulta; **las reglas de transformación del
álgebra**, con su demostración o su referencia; empujar σ y π hacia las hojas; reordenar joins por
selectividad; el algoritmo heurístico de optimización paso a paso; traducir SQL a un árbol inicial.

**Verificación:** ✍️ papel, y el mini motor para comparar el costo del árbol inicial con el
optimizado.

**⚖️ candidato:** las heurísticas fallan cuando la selectividad engaña; por eso existe F28.

**Tipos dominantes:** ✍️ (transformar árboles), 🧮 (equivalencias) y 🔎.

### ⚙️ F28 — Optimización basada en costo (14 h · 36 ejercicios)

**Lectura base:** Navathe, cap. 19 (§19.2–19.5). Selinger et al. (1979). **Depende de:** F27 ·
**Habilita:** F33.

**Qué entra:** las estadísticas del catálogo; **selectividad y estimación de cardinalidad** de
selecciones y joins, con los supuestos de uniformidad e independencia; histogramas; el espacio de
planes; **orden de los joins con programación dinámica** (al estilo de System R), con traza; planes
izquierdos contra arbustivos; `EXPLAIN QUERY PLAN` y `ANALYZE` de SQLite como ventana.

**Verificación:** ✍️ papel (estimaciones y la tabla de programación dinámica) y SQLite como ventana.

**🪞 candidato:** *"Tu instinto dice que el optimizador encuentra el mejor plan… y esta vez se
equivoca"*: encuentra el mejor plan *según su estimación*, y la estimación puede fallar por órdenes
de magnitud. Se calcula un caso.

**⚖️ candidato:** con estadísticas viejas o columnas correlacionadas, un *hint* o una reescritura
manual pueden ser la decisión correcta.

**Tipos dominantes:** ✍️ (estimaciones), 🧮 y 🟠 de diagnóstico.

---

## 🔒 9. Bloque VI · Transacciones (45 h)

### 🔒 F29 — Transacciones y planes (12 h · 42 ejercicios)

**Lectura base:** Navathe, cap. 20. **Depende de:** F05 · **Habilita:** F30, F31, F32.
**Apéndices de apoyo:** a05, a07.

**Qué entra:** el problema (actualización perdida, lectura sucia, resumen incorrecto, lectura no
repetible); estados de una transacción; ACID; planes (*schedules*), operaciones en conflicto; planes
seriales y serializables; **serializabilidad por conflicto** y el **grafo de precedencia**, con
traza; serializabilidad por vistas y escrituras ciegas; planes recuperables, sin abortos en cascada
y estrictos, y la jerarquía entre ellos.

**Verificación:** verificador `conflict_serializable` (grafo de precedencia y orden serial
equivalente).

**🪞 candidato:** *"Tu instinto dice que si cada transacción es correcta sola, el conjunto es
correcto… y esta vez se equivoca"*.

**⚖️ candidato:** probar serializabilidad por vistas es NP-completo; por eso los motores garantizan
la de conflicto.

**Tipos dominantes:** ✍️ (≥ 1/2: grafos y clasificación de planes), 🔎 y 🧮.

### 🔒 F30 — Control de concurrencia (14 h · 42 ejercicios)

**Lectura base:** Navathe, cap. 21. **Depende de:** F29 · **Habilita:** F31, F32.

**Qué entra:** bloqueos compartidos y exclusivos; **2PL** básico, conservador, estricto y riguroso,
con la demostración de que 2PL garantiza serializabilidad por conflicto; *deadlock* y *starvation*:
prevención (wait-die, wound-wait), detección con grafo de espera y *timeouts*; **ordenamiento por
marcas de tiempo** y la regla de escritura de Thomas; **MVCC**; validación optimista; granularidad
múltiple y bloqueos de intención; el problema de los fantasmas.

**Verificación:** ✍️ papel (trazas de cada protocolo), y el verificador de F29 sobre los planes que
cada protocolo admite.

**⚖️ candidato:** cada protocolo cambia una anomalía por un costo (esperas, abortos, versiones); la
tabla de cierre lo compara.

**Tipos dominantes:** ✍️ (trazas) y 🧮 (demostraciones y contraejemplos).

### 🔒 F31 — Niveles de aislamiento (8 h · 32 ejercicios)

**Lectura base:** Navathe, caps. 20 y 21. Berenson et al. (1995). **Depende de:** F30 ·
**Habilita:** F32.

**Qué entra:** las anomalías como fenómenos (lectura sucia, no repetible, fantasma) y los cuatro
niveles de SQL; **la crítica de Berenson et al.** y las anomalías que la definición del estándar no
captura; **snapshot isolation y *write skew***, con el contraejemplo clásico (dos docentes de turno
que se dan de baja a la vez); qué hace SQLite (un escritor, aislamiento serializable por diseño).

**Verificación:** ✍️ papel y SQLite con dos conexiones (lo que su modelo de un escritor impide y
cómo se manifiesta).

**🪞 candidato:** *"Tu instinto dice que `SERIALIZABLE` es serializable en todos los motores… y esta
vez se equivoca"*: en algunos es snapshot isolation; el curso de motor lo mide.

**⚖️ candidato:** subir el nivel de aislamiento cuesta abortos o esperas; a veces la solución
correcta es una restricción, no un nivel.

**Tipos dominantes:** ✍️ (qué anomalía permite cada nivel) y 🧮 (contraejemplos).

### 🔒 F32 — Recuperación (11 h · 38 ejercicios)

**Lectura base:** Navathe, cap. 22. Mohan et al. (1992), ARIES. Petrov, *Database Internals*,
cap. 5. **Depende de:** F30 · **Habilita:** F35.

**Qué entra:** fallas y qué protege cada mecanismo; la bitácora y **la regla WAL**; caché de
páginas, *steal/no-steal*, *force/no-force*; actualización diferida (NO-UNDO/REDO) e inmediata
(UNDO/REDO); *checkpoints* y *fuzzy checkpoints*; *shadow paging*; **ARIES paso a paso**: análisis,
redo y undo sobre una bitácora con LSN, tabla de transacciones y tabla de páginas sucias.

**Verificación:** ✍️ papel (trazas de ARIES), y el modo WAL de SQLite como ventana (los archivos
`-wal` de `a01`).

**⚖️ candidato:** *no-force* y *steal* son más rápidos y más complejos de recuperar; la fase dice
cuándo se paga cada uno.

**Tipos dominantes:** ✍️ (trazas) y 🧮.

---

## 🛠️ 10. Bloque VII · Administración: lo core (40 h)

La teoría de lo que el DBA hace, sin motor. Lo operativo de cada producto está en su curso.

### 🛠️ F33 — El DBA y su trabajo (8 h · 28 ejercicios)

**Lectura base:** Navathe, caps. 1 y 17 (diseño físico y tuning; a confirmar en P9). **Depende de:**
F20, F28 · **Habilita:** F34, F35.

**Qué entra:** las funciones del DBA; el catálogo y el diccionario de datos, y qué guarda cada uno;
tuning del diseño físico (índices, desnormalización, particionado) y de las consultas a partir de la
carga; monitoreo y planificación de capacidad; el ciclo de vida de una base.

**Verificación:** ✍️ papel y el catálogo de SQLite.

**⚖️ candidato:** el tuning sin una carga medida es superstición; el curso de motor da el
instrumento.

**Tipos dominantes:** 🧩 (decisiones) y 📖.

### 🛡️ F34 — Seguridad y autorización (12 h · 36 ejercicios)

**Lectura base:** Navathe, cap. 30. **Depende de:** F12, F33 · **Habilita:** F35.

**Qué entra:** amenazas y contramedidas; **control discrecional**: `GRANT` y `REVOKE`, la *grant
option*, la propagación de privilegios y **la revocación en cascada con el grafo de autorización**,
paso a paso; las vistas como mecanismo de seguridad; **RBAC**; **control obligatorio** y el modelo
Bell-LaPadula; seguridad por filas y por etiquetas; inyección SQL y cómo la evita una consulta
parametrizada; inferencia en bases estadísticas; cifrado y auditoría.

**Verificación:** ✍️ papel (el grafo de autorización). SQLite no tiene usuarios. 🔥 Opcional: los
mismos ejercicios en el PostgreSQL del contenedor de `a09`.

**🪞 candidato:** *"Tu instinto dice que `REVOKE` quita el permiso que diste y nada más… y esta vez
se equivoca"*: en cascada quita también los que se concedieron a partir de él.

**⚖️ candidato:** la seguridad dentro de la base no sustituye a la de la aplicación, y al revés.

**Tipos dominantes:** ✍️ (grafos de autorización) y 🧩.

### 💾 F35 — Respaldo y continuidad (10 h · 30 ejercicios)

**Lectura base:** Navathe, cap. 22 (§22.8, respaldo y recuperación ante catástrofes; a confirmar).
**Depende de:** F32 · **Habilita:** F37.

**Qué entra:** respaldo completo, incremental y diferencial; respaldo lógico contra físico; archivado
de la bitácora y **recuperación a un punto en el tiempo**; **RPO y RTO** y cómo se calculan para una
estrategia; replicación síncrona y asíncrona, y lo que cada una arriesga; alta disponibilidad como
concepto; **probar una restauración**, que es lo único que demuestra que el respaldo existe.

**Verificación:** SQLite para lo verificable (`.backup`, `VACUUM INTO`, restaurar y `PRAGMA
integrity_check`), y ✍️ papel para RPO, RTO y estrategias.

**🪞 candidato:** *"Tu instinto dice que tienes respaldo porque el job corre todas las noches… y esta
vez se equivoca"*: no lo tienes hasta que restauraste.

**⚖️ candidato:** un RPO de cero cuesta replicación síncrona y latencia en cada escritura; la fase lo
calcula.

**Tipos dominantes:** 🧩 (estrategias), ✍️ (RPO/RTO) y 🔎.

### ⚡ F36 — Bases activas: triggers (10 h · 30 ejercicios)

**Lectura base:** Navathe, cap. 26 (§26.1). **Depende de:** F05, F12 · **Habilita:** F37.

**Qué entra:** el modelo evento-condición-acción; triggers de fila y de sentencia; `BEFORE`,
`AFTER` e `INSTEAD OF`; **terminación y confluencia** de un conjunto de reglas, y cómo se analizan
con el grafo de activación; cascadas de triggers; **el total del pedido mantenido por trigger**;
restricciones que solo un trigger puede imponer (las de F05 y F17); cuándo un trigger es la peor
idea.

**Verificación:** SQLite (triggers de fila, `INSTEAD OF` sobre la vista de F12 y una cascada).

**⚖️ candidato:** la lógica escondida en triggers es la más difícil de mantener; cuándo el costo
vale la pena.

**Tipos dominantes:** 🔎 y ✍️ (terminación y confluencia).

---

## 🌐 11. Bloque VIII · Panorama (8 h)

### 🌐 F37 — Más allá del núcleo (8 h · 20 ejercicios) · 🏛️

**Lectura base:** Navathe, caps. 23, 24 y 29. **Depende de:** F35, F36 · **Habilita:** nada; cierra
el camino base.

**Qué entra:** bases distribuidas (fragmentación horizontal y vertical, replicación, transparencia);
**commit en dos fases**, paso a paso; el teorema CAP sin misticismo; por qué existen las familias
NoSQL, y la observación de que **varias son, en el fondo, jerárquicas (documental) o en red
(grafos)**, con remisión en prosa a los minicursos de la Ruta NoSQL Lite; data warehousing y OLAP
en una página; las bases temporales, espaciales y deductivas, en una línea cada una.

**Verificación:** ✍️ papel (2PC, decisiones de fragmentación).

**🪞 candidato:** *"Tu instinto dice que NoSQL escala porque no tiene joins… y esta vez se
equivoca"*: escala porque renuncia a otras cosas, y la fase dice cuáles.

**⚖️ candidato:** el veredicto del curso: cuándo el modelo relacional no es la respuesta, y hacia
dónde ir.

**🏛️:** el documento como árbol y el grafo como red → AC05.

**Tipos dominantes:** 📖 y 🧩.

---

## 🏛️ 12. Bloque A.C. · Antes de Codd (opcional, 67 h)

**Opcional, autocontenido y fuera del calendario del camino base.** Nada del camino base depende de
él. Sus fases llevan el prefijo de track (`acNN-slug.md`), sus prompts van en un archivo propio
(`prompts-ac-fase.md`) y sus tags en el espacio `ac-fase-<slug>`. Se recomienda haber terminado al
menos los bloques II y IV, porque compara contra ellos.

**La tesis:** el jerárquico y el de red son **navegacionales** (el programa recorre punteros y el
camino de acceso queda fijo en el esquema); el relacional es **declarativo**. Estudiar el "antes"
explica el camino base, explica NoSQL y **no es arqueología inútil**: estos modelos siguen vivos en
Active Directory y LDAP, el Registro de Windows, los *globals* de MUMPS, Git, los ORM y los motores
embebidos.

**Los laboratorios**, en Python con biblioteca estándar salvo donde se indica, comparten el contador
de bloques del mini motor de F26:

| Lab | Qué es | Fase |
|---|---|---|
| L1 | Un gestor de registros paginado: páginas fijas, *database key* (página, ranura), contador de bloques | AC01 |
| L2 | `supply` con pedidos en el modelo de red: *sets* como listas circulares, mini DML con currency | AC03 |
| L3 | `school` en el modelo jerárquico: un árbol en preorden con un mini DL/I | AC02 |
| L4 | La misma pregunta en dos mundos: `radb` contra el programa navegacional, con bloques y líneas | AC04 |
| L5 | `dbm` de Python como motor debajo de L2 o L3 | AC01 |

> ⚠️ **No hay laboratorio con IMS ni IDMS reales**: no existen ediciones gratuitas para una laptop.
> DL/I y el DML de CODASYL se enseñan en papel y con los mini DML de L2 y L3, y el texto lo dice.

### 🏺 AC00 — Navegar contra declarar (3 h · 15 ejercicios)

**Qué entra:** la tesis; **🏺 por qué estudiar arqueología**: dónde viven hoy el jerárquico (Active
Directory y LDAP, el Registro de Windows, los sistemas de archivos, los *globals* de MUMPS en
sistemas clínicos, JSON y XML, HDF5, IMS), la red y la navegación por punteros (bases de grafos, los
ORM y su N+1, Git, las bases de objetos) y el gestor de registros sin modelo (ESE debajo de Active
Directory, Berkeley DB y su historia de licencias, LMDB, LevelDB y RocksDB, IndexedDB, la capa B-tree
de SQLite); **qué gana el ingeniero** (reconocer el patrón con su nombre, elegir un motor embebido,
migrar lo que todavía corre, leer lo que otros no pueden, entender por qué ganó lo declarativo); el
mapa de los modelos y sus fechas.

**Verificación:** ✍️ papel. ⚠️ Qué motor usa hoy cada producto, desde qué versión y con qué licencia
se verifica en P9: varios cambiaron de motor en los últimos años.

**🪞 candidato:** *"Tu instinto de ingeniero moderno dice que esto es historia… y esta vez se
equivoca"*.

**Tipos dominantes:** 📖 y 🧩.

### 📁 AC01 — Archivos, registros y punteros en disco (8 h · 24 ejercicios)

**Qué entra:** archivos con aplicación dueña (COBOL con archivos secuenciales e indexados; ISAM y
VSAM); gestores de registros en PC (xBase con `.dbf` y sus índices; Btrieve); de las multilistas y
las listas ortogonales al disco: *database key*, costo por salto, punteros colgantes; **motor de
almacenamiento contra modelo de datos** (`dbm`, Berkeley DB, LMDB); la relevancia regional de
Clipper, FoxPro y COBOL. **Labs L1 y L5.**

**Verificación:** L1 y L5, con su contador de bloques.

**🪞 candidato:** *"Tu instinto de estructuras de datos dice que un puntero cuesta O(1)… y en disco se
equivoca"*: cada salto puede ser un acceso a bloque.

**Tipos dominantes:** ✍️ (costos) y 🔎 (labs).

### 🌲 AC02 — El modelo jerárquico (8 h · 26 ejercicios)

**Qué entra:** tipos de segmento y el árbol de un registro; DBD y PCB/PSB como la primera vista
externa; **DL/I** (`GU`, `GN`, `GNP`, `ISRT`, `REPL`, `DLET`) y los SSA; el recorrido en preorden;
punteros hijo/gemelo; organizaciones HSAM, HISAM, HDAM e HIDAM; **el problema del muchos-a-muchos**
y las relaciones lógicas; el mapeo ER → jerárquico. **Lab L3.**

**Verificación:** L3 y ✍️ papel.

**Tipos dominantes:** ✍️ (recorridos y DL/I), 🔎 y 🧩 (mapear).

### 🕸️ AC03 — El modelo de red (10 h · 30 ejercicios)

**Qué entra:** Bachman e IDS; el informe CODASYL DBTG; tipos de registro y *sets*; **el registro de
enlace** para el muchos-a-muchos; diagramas de Bachman; **el *set* como lista circular** (NEXT,
PRIOR, OWNER); el DML (`FIND`, `GET`, `STORE`, `CONNECT`, `DISCONNECT`) y **los indicadores de
currency**; inserción (`AUTOMATIC`/`MANUAL`) y retención (`MANDATORY`/`OPTIONAL`/`FIXED`) como
antecesoras del `ON DELETE`; ubicación `CALC` y `VIA set`; el mapeo ER → red. **Lab L2.**

**Verificación:** L2 y ✍️ papel.

**Tipos dominantes:** ✍️ (programas navegacionales), 🔎 y 🧩.

### ⚔️ AC04 — El Gran Debate (6 h · 20 ejercicios)

**Qué entra:** Codd (1970) contra Bachman (*The Programmer as Navigator*, 1973); el debate de SIGMOD
de 1974 y sus argumentos; System R, Ingres y el optimizador de Selinger como prueba de que lo
declarativo podía ser eficiente. **Lab L4**: la misma pregunta (la ÷ de F07) en álgebra con `radb` y
como programa navegacional, con bloques contados; después se cambia la pregunta y se mide cuántas
líneas cambia cada solución.

**Verificación:** L4.

**Tipos dominantes:** 🔎 (L4) y 📖.

### 🧬 AC05 — Los herederos (6 h · 22 ejercicios)

**Qué entra:** documentos como jerárquico; grafos como red declarativa (Cypher, ISO GQL, SQL/PGQ);
bases de objetos (ODMG, db4o); **ORM y N+1 como navegación CODASYL sobre un motor relacional**; las
vistas de dualidad JSON–relacional; *What Goes Around Comes Around* (2005) y su secuela (2024).
**Laboratorio corto con ZODB**: un grafo de objetos persistente y el N+1 provocado a propósito. Con
la Ruta NoSQL Lite, **solo referencias de concepto**.

**Verificación:** ZODB en el `venv` (`aca-01`).

**Tipos dominantes:** 📖, 🔎 y 🧩.

### 🔬 AC06 — Caso de estudio: Git, la base navegacional que ya usas (6 h · 20 ejercicios)

**Qué entra:** el almacén de objetos de Git (commits, árboles, *blobs* y *tags*) como un modelo de
red direccionado por contenido, con árboles jerárquicos colgando de cada commit; recorrido a mano con
`git cat-file` y `git ls-tree`; *"¿en qué commits cambió este archivo?"* como recorrido sin índice;
exportar el grafo de un repositorio chico a SQLite (`commit`, `commit_parent`, `tree_entry`) con un
script de Python y escribir la misma pregunta con `WITH RECURSIVE` y en álgebra con clausura.

**Verificación:** Git (sin instalar nada), Python y SQLite, en las tres plataformas.

**🪞 candidato:** *"Tu instinto dice que Git es un sistema de archivos… y es una base de datos de
grafos con un solo patrón de acceso"*.

**Tipos dominantes:** 🔎 (≥ 1/2) y ✍️ (saltos contados).

### 🔬 AC07 — Caso de estudio: LMDB, el motor sin modelo (6 h · 22 ejercicios)

**Qué entra:** un gestor de registros real y *standalone* (`pip install lmdb`, nativo en las tres
plataformas): árbol B+ con copia en escritura, cursores, subbases con nombre y claves con valores
duplicados (`dupsort`); **montar a mano la capa de red de AC03** sobre él, con los *sets* de `supply`
con pedidos como claves `dupsort` y un mini DML encima; contar accesos con el contador de L1 y
comparar con la versión relacional; el cierre: es el mismo motor que hay debajo de OpenLDAP, y
Active Directory hace lo mismo sobre ESE.

**Verificación:** `lmdb` en el `venv`, y SQLite para la versión relacional.

**Tipos dominantes:** 🔎 (≥ 1/2) y 🧩 (diseñar la capa).

### 🔬 AC08 — Caso de estudio: YottaDB, el jerárquico que sigue en producción (6 h · 22 ejercicios)

**Qué entra:** los *globals* de MUMPS como árboles dispersos persistentes, con subíndices en vez de
segmentos (`^school(year, section, student)`); cargar `school` como árbol; recorrerlo con `$ORDER`
(la navegación de DL/I con otra sintaxis) y desde Python con el paquete `yottadb`; preguntar lo que
el árbol no previó (*"todas las secciones de un alumno"*), medir cuánto cuesta y resolverlo con un
*global* inverso, que es un índice secundario hecho a mano; el contexto real (VistA y otros sistemas
clínicos).

**Verificación:** YottaDB en el contenedor de `aca-02` en macOS y Windows; nativo en Linux x86-64.

**Tipos dominantes:** 🔎 (≥ 1/2) y ✍️.

### 🧷 AC09 — Pedidos en C: el modelo de red a mano (8 h · 20 ejercicios)

**Qué entra:** la base clásica de clientes, pedidos, líneas y partes con estructuras multienlazadas;
primero en memoria y después sobre un archivo de páginas con `fseek`, con *database keys* y *sets*
circulares (NEXT, PRIOR, OWNER) y un mini DML por línea de comandos. **ANSI C, solo CLI, sin
dependencias, compilable con GCC y con Visual C++.** El código se entrega **hecho**: se genera con
asistencia de IA como parte del contenido del curso, se revisa y se compila en las tres plataformas
antes de publicarse, y queda **abierto a ejercicios** de extensión (un *set* nuevo, borrado con
retención `MANDATORY`, una ubicación `CALC`). Vive en `src/ac09-pedidos-en-c/`.

**Verificación:** compilar y correr con GCC (Linux y macOS) y con Visual C++ (Windows), con la salida
literal.

**Tipos dominantes:** 🔎 y 🧩 (extender el código).

### 🔥 Caso de reserva: el `.dbf` que factura desde 1994

Migrar a SQLite un sistema de facturación en xBase (Clipper o FoxPro): leer los `.dbf` con Python,
reconstruir las relaciones que vivían en el código y no en el esquema, y normalizar con lo de
F14–F18. **Entra solo si AC06, AC07 o AC08 se caen en la verificación**, y ocupa su lugar.

### 12.1 Los recuadros 🏛️ en el camino base

Un recuadro de tres o cuatro líneas, sin ejercicios, en **F01, F03, F05, F07, F13, F24 y F37**, con
la forma *"🏛️ Antes de Codd: esto se resolvía así… → bloque A.C."*. Mientras el bloque no exista, la
referencia va en prosa, sin enlace.

### 12.2 Para tocar: implementaciones open source

⚠️ **Sin verificar**, salvo lo que se consultó en PyPI el 02/10/2026 (`lmdb`, ZODB, `yottadb`). P8 y
P9 comprueban existencia, licencia, mantenimiento y plataformas.

| Modelo o idea | Implementación | Qué permite palpar |
|---|---|---|
| Archivos indexados (COBOL) | GnuCOBOL | archivos `INDEXED` y `RELATIVE` |
| xBase | Harbour (compatible con Clipper) | `USE`, `SEEK`, `SKIP` sobre `.dbf` |
| Jerárquico (*globals*) | YottaDB (AC08) o GT.M | una base jerárquica en producción |
| Motor *standalone* | LMDB con `lmdb` de Python (AC07) | *sets* con `dupsort` |
| Grafo de objetos | ZODB (AC05) | navegación por referencias y N+1 |
| Motores clave-valor | `dbm` de Python, Berkeley DB | la capa de abajo, sin modelo |
| ISAM de Active Directory | ESE (publicado por Microsoft; solo Windows) | cursores `Seek` y `Move` |
| Directorio | OpenLDAP (solo mención) | un árbol con esquema sobre LMDB |
| Mainframe | Hercules (emulador) | el entorno de IMS e IDMS, que no son libres |

### 12.3 Bibliografía del bloque

⚠️ **Nada verificado todavía.** Pasa por P9. No cuenta contra el tope de cinco textos.

- **Papers:** Codd (1970); Bachman, *The Programmer as Navigator* (CACM, 1973); el informe CODASYL
  DBTG (1971); *ACM Computing Surveys* de marzo de 1976 (Taylor y Frank; Tsichritzis y Lochovsky);
  Stonebraker y Hellerstein, *What Goes Around Comes Around* (2005); Stonebraker y Pavlo, *What
  Goes Around Comes Around… And Around…* (2024); Olson, Bostic y Seltzer, *Berkeley DB* (1999).
- **Libros:** Elmasri y Navathe (los apéndices de los modelos jerárquico y de red, si la 7.ª edición
  los conserva o están en línea); ediciones antiguas de Date, que traían IMS e IDMS; Kleppmann,
  *Designing Data-Intensive Applications*, cap. 2.
- **Videos y cursos:** las clases de historia de Andy Pavlo en CMU; el material de IBM sobre IMS.

---

## 📊 13. Resumen de fases

| # | Fase | Bloque | Horas | Ejercicios |
|---|---|---|---|---|
| 00 | El sistema de bases de datos y sus actores | 0 | 4 | 18 |
| 01 | Conceptos y arquitectura | 0 | 6 | 24 |
| 02 | Modelo entidad-relación | I | 10 | 34 |
| 03 | ER extendido y notaciones | I | 10 | 32 |
| 04 | El modelo relacional, formalmente | II | 10 | 38 |
| 05 | Restricciones y operaciones de actualización | II | 10 | 36 |
| 06 | Álgebra I: operaciones unarias | II | 12 | 40 |
| 07 | Álgebra II: conjuntos, joins y división | II | 14 | 45 |
| 08 | Álgebra III: operaciones extendidas | II | 12 | 40 |
| 09 | Cálculo relacional | II | 12 | 36 |
| 10 | Del álgebra a SQL, operador por operador | II | 14 | 45 |
| 11 | `NULL`, lógica de tres valores y multiconjuntos | II | 10 | 36 |
| 12 | Vistas y el problema de actualizarlas | II | 6 | 30 |
| 13 | Del ER/EER al modelo relacional | II | 10 | 38 |
| 14 | Guías informales de diseño y anomalías | III | 8 | 30 |
| 15 | Dependencias funcionales | III | 14 | 45 |
| 16 | Formas normales: de 1FN a FNBC | III | 12 | 42 |
| 17 | Propiedades de las descomposiciones | III | 12 | 40 |
| 18 | Algoritmos de diseño relacional | III | 12 | 40 |
| 19 | Más allá de FNBC | III | 12 | 36 |
| 20 | Desnormalización y diseño físico | III | 10 | 30 |
| 21 | Discos, bloques y organización de archivos | IV | 10 | 32 |
| 22 | Hashing | IV | 10 | 34 |
| 23 | Índices de uno y varios niveles | IV | 8 | 32 |
| 24 | Árboles B y B+ | IV | 12 | 45 |
| 25 | Otras estructuras de índice | IV | 10 | 34 |
| 26 | Cómo se implementa cada operador | V | 16 | 45 |
| 27 | Optimización heurística | V | 10 | 34 |
| 28 | Optimización basada en costo | V | 14 | 36 |
| 29 | Transacciones y planes | VI | 12 | 42 |
| 30 | Control de concurrencia | VI | 14 | 42 |
| 31 | Niveles de aislamiento | VI | 8 | 32 |
| 32 | Recuperación | VI | 11 | 38 |
| 33 | El DBA y su trabajo | VII | 8 | 28 |
| 34 | Seguridad y autorización | VII | 12 | 36 |
| 35 | Respaldo y continuidad | VII | 10 | 30 |
| 36 | Bases activas: triggers | VII | 10 | 30 |
| 37 | Más allá del núcleo | VIII | 8 | 20 |
| | **Camino base** | | **403** | **1 345** |
| AC00 | Navegar contra declarar | A.C. | 3 | 15 |
| AC01 | Archivos, registros y punteros en disco | A.C. | 8 | 24 |
| AC02 | El modelo jerárquico | A.C. | 8 | 26 |
| AC03 | El modelo de red | A.C. | 10 | 30 |
| AC04 | El Gran Debate | A.C. | 6 | 20 |
| AC05 | Los herederos | A.C. | 6 | 22 |
| AC06 | Caso de estudio: Git | A.C. | 6 | 20 |
| AC07 | Caso de estudio: LMDB | A.C. | 6 | 22 |
| AC08 | Caso de estudio: YottaDB | A.C. | 6 | 22 |
| AC09 | Pedidos en C | A.C. | 8 | 20 |
| | **Bloque A.C.** | | **67** | **221** |

---

## 📁 14. Convención de nombres

Los nombres canónicos de fases, apéndices, solucionarios y `src/` están en la guía de estilo
(§5.2); este documento no los repite para que no diverjan.

Dos dígitos en todo. Tags `fase-NN-<slug>` en el camino base y `ac-fase-<slug>` en el bloque A.C.,
para que `git tag -l 'fase-*'` siga siendo el índice limpio del camino base. Prefijo de commit
`01-bases fNN:` (ejercicios `01-bases fNN ejM:`) y `01-bases acNN:`. **Git lo maneja Oskar**: las
sesiones de escritura no commitean ni etiquetan.

`README.md` y `0-ESTRUCTURA-CURSO.md` se escriben al final, en una tanda propia, cuando todo el
contenido exista.

---

## 📌 15. Lo que esta propuesta deja pendiente

- **Los capítulos y secciones de Navathe 7.ª ed.** de cada ficha son de memoria; se confirman en P9,
  junto con los de Date, *SQL and Relational Theory*, Petrov y *SQL Cookbook*.
- **`radb` sobre tablas `STRICT`**, su sintaxis exacta de invocación y su comportamiento con `NULL`
  (P8).
- **Lo que SQLite implementa y lo que no** de lo que citan las fichas: `INTERSECT ALL` y
  `EXCEPT ALL` (F11), `foreign_keys` por defecto (F05), `dbstat` y `sqlite3_analyzer` (F24),
  actualización de vistas (F12) (P8).
- **MySQL y `EXCEPT` desde la 8.0.31** (F10), a confirmar en la documentación oficial (P9).
- **El verificador de hashing** (F22) es candidato; si se escribe, entra en `a05`.
- **Las implementaciones y la bibliografía del bloque A.C.** (§12.2 y §12.3), en P8 y P9.
- **Las horas** de cada fase se recalibran en el paso 1 de su prompt; si cambian, cambian aquí
  primero.
