# 🗺️ Prompts iniciales por fase
## El motor de motores — 38 sesiones, 38 fases con su solucionario

Cada sección es el prompt completo de una fase del camino base, listo para pegar en la sesión que
la redacta. Los prompts del bloque A.C. están aparte, en [`prompts-ac-fase.md`](prompts-ac-fase.md).

**La ficha manda; el prompt completa.** El "Qué entra", la lectura base, la verificación y los
candidatos 🪞 y ⚖️ de cada fase están en su ficha de
[`propuesta-fases-y-alcance.md`](propuesta-fases-y-alcance.md), y el prompt no los repite: los cita
y agrega lo que la ficha no dice (los puntos de cuidado, la prueba de fuego y lo que puede
bloquear). Si la ficha cambia, el prompt se revisa después y **nunca al revés**.

**Una sesión, una fase y su solucionario.** Una fase sin `soluciones/NN-slug.md` completo y
contrastado no está terminada.

> ⚠️ **Antes de la primera sesión.** Ten a mano, en este orden: `prompts/alcance-del-proyecto.md`,
> `prompts/guia-de-estilo-y-convenciones.md`, `prompts/propuesta-fases-y-alcance.md`,
> `prompts/propuesta-apendices-y-alcance.md` y `prompts/plantillas-de-capitulo.md`. **No uses**
> ningún archivo `_desechable-*`: el curso no los cita.

> ⚠️ **Antes de la primera fase con herramientas (F01).** Tienen que estar escritos y verificados
> `a01`, `a02`, `a03` y `a04`. La tanda de verificación (P8) está cerrada desde el 03/10/2026
> (`prompts/verificacion-de-laboratorio/hallazgos.md`); sin esos apéndices, ninguna fase puede
> publicar una salida.

---

## 🧱 El marco común

Va entero en el prompt de F00 y por referencia en los demás. **No lo repitas en el documento:
aplícalo.**

```markdown
## Marco (no lo repitas, aplícalo)

Fuentes de verdad, en este orden: (1) `prompts/alcance-del-proyecto.md`,
(2) `prompts/guia-de-estilo-y-convenciones.md`, (3) `prompts/propuesta-fases-y-alcance.md` (la
ficha de esta fase es el piso del contenido), (4) `prompts/propuesta-apendices-y-alcance.md`,
(5) `prompts/plantillas-de-capitulo.md`, (6) lo verificado en
`prompts/verificacion-de-laboratorio/hallazgos.md` (P8) y en `prompts/inventario-de-fuentes.md` (P9),
(7) los apéndices y las fases ya escritos y aprobados, (8) las decisiones de esta sesión. Los documentos desechables no cuentan y no se citan.

Reglas que no se negocian:
- **Nada se publica sin haberse ejecutado o verificado.** Ninguna salida de `radb`, `sqlite3`, un
  verificador o el mini motor reconstruida de memoria; ningún paso de una solución sin contrastar.
  Lo no verificado se declara con esas palabras.
- **Los costos son un modelo y se dice**, con sus supuestos y su fórmula. Nunca un tiempo medido.
- **Donde SQL se aparta de la teoría, se dice en la misma fase**, con un ejemplo en SQLite.
- **Identificadores en inglés en todas partes, también en el álgebra**; comentarios de código en
  español con tildes. Bases fijas: `school` y `supply` (nombres en `a04`), o relaciones abstractas
  declaradas. Nunca `grade` solo, `foo` ni `tabla1`.
- **Unicode, nunca LaTeX. Diagramas ASCII de 75 columnas como máximo.**
- **Definiciones y teoremas numerados por fase**; los de otras fases se citan por número, no se
  redefinen.
- **Ejercicios originales**, nunca copiados de un libro; la bibliografía remite a los del libro por
  número.
- **Ningún recurso bibliográfico se cita sin comprobarlo en la sesión**; el inventario está en `a08`.
- **Ningún enlace a un documento que todavía no existe**: la referencia va en prosa.
- **Toda prueba corre dentro de un contenedor `mdm-*` con la etiqueta `curso=01-bases`**, nunca en
  la máquina de Oskar; sin puertos publicados, y si hace falta uno, en `127.0.0.1` y en el rango
  `56000–56099`, nunca el puerto por defecto del producto (guía §11.1). Lo que no se puede
  contenerizar (recetas de macOS y Windows) se le pide a Oskar o se declara no verificado.
- La plantilla de fase se sigue literal, sin secciones extra ni reordenadas. Git lo maneja Oskar: no
  commitees ni etiquetes.
- En la misma sesión: términos nuevos a `a07`, recursos nuevos a `a08`, 🪞 nuevos a `INSTINTOS.md`.
```

Y el **protocolo de tres pasos**, que cierra todos los prompts:

```markdown
## Cómo quiero que trabajes

**Paso 1 — Preguntas antes de escribir.** No redactes. Devuélveme: (a) preguntas bloqueantes
numeradas, marcando cuáles puedes asumir con un valor por defecto; (b) tu lectura de la ficha y si
las horas y el conteo de ejercicios cuadran; (c) el índice de la sección 📐 Teoría con sus
subsecciones, definiciones y teoremas numerados; (d) el reparto de los ejercicios por dificultad y
por tipo; (e) cualquier contradicción con lo ya escrito — dímela, no la resuelvas.
**Paso 2 — Redacción** de la fase y de su solucionario, cuando yo responda. Ejecuta antes de
escribir y copia la salida literal. Si aparece una duda nueva, **para y pregunta** en vez de
rellenar con un supuesto plausible.
**Paso 3 — Autoverificación** contra el checklist de §15 de la guía, reportada en lista corta, con
el conteo de palabras del cuerpo y el de ejercicios por dificultad y tipo.
```

---

## 🧱 Bloque 0 · El terreno

## # F00 — El sistema de bases de datos y sus actores

```markdown
Esta es la sesión de la **Fase 00 — 🗄️ El sistema de bases de datos y sus actores**, del curso El
motor de motores. Entregables: `00-el-sistema-de-bases-de-datos.md` y
`soluciones/00-el-sistema-de-bases-de-datos.md`.

{{pega aquí el marco común completo}}

## Identidad

- Fase 00 de 37 · Bloque 0 — El terreno · **4 h** · **18 ejercicios**
- Depende de: nada; es la puerta de entrada · Habilita: F01
- Herramientas: ninguna. **Esta fase se lee.**
- Plantilla: la de panorama (Plantilla 2). Longitud: 2.000–3.000 palabras de cuerpo.
- Ficha: propuesta de fases, §3, F00.

## Puntos de cuidado

- **Abre el curso**: en "Dónde estamos" presenta qué es el curso, su lugar en la familia
  `gestores-sql` (el motor que está debajo de los otros seis), cómo se estudia (a tu ritmo, con
  lápiz, `radb` y SQLite) y cómo están organizados el solucionario y los apéndices. Sin historia ni
  empresa narrativa.
- Presenta **el hilo de π y −** en un párrafo, como promesa de lo que el curso va a recorrer.
- **Cualquier cifra** sobre costos de sistemas sin DBMS va como **escenario declarado** ("un sistema
  de este tamaño, con esta forma"), nunca como dato medido.
- Los ejercicios son de lectura y decisión sobre sistemas descritos (¿hace falta un DBMS aquí? ¿qué
  actor resuelve este problema?), no de ejecución.

## Pendientes que pueden bloquear

La lectura base (Navathe cap. 1) y los recursos de la bibliografía tienen que estar en `a08`, que
abre su esqueleto desde `prompts/inventario-de-fuentes.md` (P9). Si no lo están, dilo en el paso 1.

## Cómo quiero que trabajes

{{protocolo de tres pasos}}
```

## # F01 — Conceptos y arquitectura

```markdown
Esta es la sesión de la **Fase 01 — 🏗️ Conceptos y arquitectura**. Entregables:
`01-conceptos-y-arquitectura.md` y su solucionario.

{{marco común}} Añade a las fuentes: **F00 cerrada** y los apéndices `a01`–`a04` escritos y
verificados.

## Identidad

- Fase 01 de 37 · Bloque 0 · **6 h** · **24 ejercicios** · Depende de F00 · Habilita F02 y F04
- Herramientas: SQLite (catálogo) y `radb` (primera consulta) · Apéndices: a01, a02, a03, a04
- Plantilla 1. Longitud: 3.000–4.500 palabras. Lleva recuadro 🏛️.
- Ficha: propuesta de fases, §3, F01.

## Puntos de cuidado

- **Es el primer contacto con las herramientas.** No expliques instalación: enlaza `a01`–`a03`.
- **Prueba de fuego:** el lector abre `school`, lista el catálogo con `sqlite_schema`, ejecuta en
  `radb` la primera proyección y obtiene **el mismo número de tuplas que el documento**. Si no
  coincide, el laboratorio está mal y el curso entero se cae: dilo con esas palabras.
- La independencia lógica y física se enseña con **cambios concretos sobre `school`** (agregar un
  índice, partir una relación, renombrar un atributo) y quién se rompe con cada uno.
- La historia de los modelos va en **una página**, con la distinción navegacional contra
  declarativo; el resto es del bloque A.C. (el recuadro 🏛️ invita, en prosa).

## Pendientes que pueden bloquear

Que `a01`–`a04` estén escritos y que la sintaxis de `radb` esté fijada en `a03`.

{{protocolo}}
```

---

## 🧩 Bloque I · Modelado conceptual

## # F02 — Modelo entidad-relación

```markdown
Esta es la sesión de la **Fase 02 — 🧩 Modelo entidad-relación**. Entregables:
`02-modelo-entidad-relacion.md` y su solucionario.

{{marco común}} Añade: F01 cerrada.

## Identidad

- Fase 02 de 37 · Bloque I · **10 h** · **34 ejercicios** · Depende de F01 · Habilita F03 y F13
- Herramientas: papel · Apéndices: a04, a07
- Plantilla 1. Longitud: 4.500–6.500 palabras.
- Ficha: propuesta de fases, §4, F02.

## Puntos de cuidado

- **Convención de diagramas ER en ASCII.** Es la primera fase con diagramas: propón en el paso 1 la
  convención de Chen en ASCII de 75 columnas (cajas para entidades, rombos o su equivalente legible
  para relaciones, cardinalidades y min-max) y, una vez aprobada, fíjala en `a07`. Todas las fases
  siguientes la usan.
- **El diseño de `school` se construye, no se revela.** Tiene que converger con el esquema de `a04`,
  pero la fase muestra las decisiones discutibles (¿la calificación es atributo o entidad? ¿el
  apoderado es entidad débil?) con sus argumentos. Si el diseño que sale diverge de `a04`, **dilo, no
  lo corrijas por tu cuenta**.
- El total del pedido de `supply` aparece como atributo derivado; adelanta que F20 y F36 vuelven a él.
- Carga los ejercicios hacia 🧩 de modelado, y pon al menos cinco 🟠 de detectar errores en un
  diagrama ajeno.

{{protocolo}}
```

## # F03 — ER extendido y notaciones

```markdown
Esta es la sesión de la **Fase 03 — 🧩 ER extendido y notaciones**. Entregables:
`03-er-extendido-y-notaciones.md` y su solucionario.

{{marco común}} Añade: F02 cerrada, con la convención de diagramas ASCII ya fijada en `a07`.

## Identidad

- Fase 03 de 37 · Bloque I · **10 h** · **32 ejercicios** · Depende de F02 · Habilita F13
- Herramientas: papel · Apéndices: a04, a07
- Plantilla 1. Longitud: 4.500–6.500 palabras. Lleva recuadro 🏛️.
- Ficha: propuesta de fases, §4, F03.

## Puntos de cuidado

- **Las cuatro notaciones lado a lado** (Chen, pata de gallo, UML y min-max) sobre el mismo fragmento
  de `school`, en ASCII. La pata de gallo en ASCII necesita su propia convención: propónla en el
  paso 1 y agrégala a `a07`.
- La diferencia entre **categoría (tipo unión) y generalización** suele confundirse: dale un
  contraejemplo propio en ⚠️ Errores conceptuales.
- El recuadro 🏛️ presenta los diagramas de Bachman en dos líneas, sin enseñarlos.
- Cierra el Bloque I: el resumen deja escrito qué se lleva el lector a F13.

{{protocolo}}
```

---

## 📐 Bloque II · El modelo relacional ⭐

## # F04 — El modelo relacional, formalmente

```markdown
Esta es la sesión de la **Fase 04 — 📐 El modelo relacional, formalmente**. Entregables:
`04-el-modelo-relacional.md` y su solucionario.

{{marco común}} Añade: F01 cerrada, y `a06` y el esqueleto de `a07` escritos.

## Identidad

- Fase 04 de 37 · Bloque II ⭐ · **10 h** · **38 ejercicios** · Depende de F01 · Habilita F05 y F06
- Herramientas: papel y SQLite `STRICT` · Apéndices: a04, a06, a07
- Plantilla 1. Longitud: 4.500–6.500 palabras.
- Ficha: propuesta de fases, §5, F04.

## Puntos de cuidado

- **Abre el bloque de énfasis**: "Dónde estamos" presenta el Bloque II y el recorrido hasta F13.
- **Las dos definiciones de tupla** (secuencia ordenada o función de atributos a valores) y por qué
  el curso adopta una; esa elección condiciona la notación de todo el bloque y va a `a07`.
- **`NULL` se presenta aquí y se profundiza en F11**: no adelantes la lógica de tres valores.
- La escala de notas de `school` como **dominio**, con lo que SQLite `STRICT` y un `CHECK` imponen y
  lo que no; la salida literal del error de tipo.
- Al menos cuatro 🧮: demostrar que un conjunto de atributos es (o no) superclave, clave o clave
  candidata.

{{protocolo}}
```

## # F05 — Restricciones y operaciones de actualización

```markdown
Esta es la sesión de la **Fase 05 — 📐 Restricciones y operaciones de actualización**. Entregables:
`05-restricciones-y-actualizaciones.md` y su solucionario.

{{marco común}} Añade: F04 cerrada.

## Identidad

- Fase 05 de 37 · Bloque II ⭐ · **10 h** · **36 ejercicios** · Depende de F04 · Habilita F06, F12
  y F36
- Herramientas: SQLite `STRICT` con `PRAGMA foreign_keys = ON` · Apéndices: a01, a04
- Plantilla 1. Longitud: 4.500–6.500 palabras. Lleva recuadro 🏛️.
- Ficha: propuesta de fases, §5, F05.

## Puntos de cuidado

- **Cada violación con su mensaje literal de SQLite**, provocada en la sesión.
- **El comportamiento por defecto de `foreign_keys`** en SQLite: P8 (H6) lo dejó en `0` en SQLite
  3.46.1, con la fila huérfana aceptada sin error; la fase lo vuelve a ejecutar en la sesión antes de
  escribir el 🪞. Si cambia por versión o por compilación, no se verificó: dilo así.
- La tabla de "qué viola qué" (inserción, borrado y modificación contra cada tipo de restricción) es
  el centro de la fase: completa, sin huecos.
- Las restricciones que el modelo no expresa (la nota dentro de la escala del país, el total del
  pedido) se anuncian y se difieren a F36 con destino explícito.

{{protocolo}}
```

## # F06 — Álgebra relacional I: operaciones unarias

```markdown
Esta es la sesión de la **Fase 06 — 📐 Álgebra relacional I: operaciones unarias** 🧵. Entregables:
`06-algebra-operaciones-unarias.md` y su solucionario.

{{marco común}} Añade: F05 cerrada.

## Identidad

- Fase 06 de 37 · Bloque II ⭐ · **12 h** · **40 ejercicios** · Depende de F05 · Habilita F07
- Herramientas: `radb` (con el SQL que genera) y SQLite · Apéndices: a03, a04, a07
- Plantilla 1. Longitud: 4.500–6.500 palabras.
- Ficha: propuesta de fases, §5, F06.

## Puntos de cuidado

- **Empieza el hilo de π y −** 🧵: dilo en "Dónde estamos" y marca las secciones de π.
- **El 🪞 de π contra `SELECT`** se demuestra con números: la misma proyección en `radb` (conjunto) y
  en SQLite sin `DISTINCT` (multiconjunto), contando tuplas, con las dos salidas literales.
- **Las leyes** (cascada de σ, conmutatividad de σ, cascada de π, cuándo conmutan σ y π) se
  enuncian como Propiedades numeradas, con demostración; F27 las cita por número.
- **Al menos un tercio de los ejercicios son 🔎 en `radb`**, con "predice antes de ejecutar" en los
  🟠 y 🔴.
- Fija aquí la convención de cómo se guardan las expresiones de `radb` de la fase (carpeta y nombre
  de archivo), siguiendo `a03`.

{{protocolo}}
```

## # F07 — Álgebra relacional II: conjuntos, joins y división

```markdown
Esta es la sesión de la **Fase 07 — 📐 Álgebra relacional II: conjuntos, joins y división** 🧵.
Entregables: `07-algebra-conjuntos-joins-y-division.md` y su solucionario.

{{marco común}} Añade: F06 cerrada.

## Identidad

- Fase 07 de 37 · Bloque II ⭐ · **14 h** · **45 ejercicios** · Depende de F06 · Habilita F08, F09 y
  F10
- Herramientas: `radb` · Apéndices: a03, a04, a06, a07
- Plantilla 1. Longitud: 5.500–7.500 palabras. Lleva recuadro 🏛️.
- Ficha: propuesta de fases, §5, F07.

## Puntos de cuidado

- **Es una de las fases más importantes del curso.** La división y **el conjunto completo
  {σ, π, ∪, −, ×}** son su centro.
- **La división se define, se intuye ("los que se relacionan con *todos*"), se escribe con π, × y −
  y se demuestra la equivalencia**, paso a paso. Después se aplica a *"proveedores que suministran
  todas las partes rojas"* y a *"alumnos que rindieron todas las evaluaciones de su sección"*.
- **`radb` no tiene ÷.** La fase lo dice sin disculparse: el lector la ejecuta escrita con los
  primitivos, que es exactamente lo que la fase enseña. Verifica ambas consultas con datos chicos
  donde el resultado sea no trivial (al menos un proveedor que suministra *casi* todas).
- **Al menos cinco 🧮**: derivar ∩, ⋈ y ÷ de los primitivos; demostrar que − no es conmutativa ni
  asociativa con contraejemplo.
- El recuadro 🏛️ dice en dos líneas que la ÷ en el modelo de red es un programa de dos bucles
  anidados.

{{protocolo}}
```

## # F08 — Álgebra relacional III: operaciones extendidas

```markdown
Esta es la sesión de la **Fase 08 — 📐 Álgebra relacional III: operaciones extendidas** 🧵.
Entregables: `08-algebra-extendida.md` y su solucionario.

{{marco común}} Añade: F07 cerrada.

## Identidad

- Fase 08 de 37 · Bloque II ⭐ · **12 h** · **40 ejercicios** · Depende de F07 · Habilita F10 y F26
- Herramientas: `radb` (γ con `\aggr`) y SQLite (outer joins) · Apéndices: a03, a04, a07
- Plantilla 1. Longitud: 4.500–6.500 palabras.
- Ficha: propuesta de fases, §5, F08.

## Puntos de cuidado

- **El antijoin escrito con −** (R ▷ S = R − (R ⋉ S)) es el paso del hilo 🧵 de esta fase:
  demuéstralo y verifícalo en `radb`.
- **`radb` no tiene outer join, ⋉ ni ▷**: se escriben con primitivos y se ejecutan así; los outer
  joins se contrastan además en SQLite, con el `NULL` que introducen a la vista.
- **γ y la clausura de conjuntos**: muestra el caso donde una agregación sin cuidado produce un
  resultado que no es una relación bien formada, o dilo si `radb` lo impide.
- La clausura recursiva se presenta como operación que el álgebra básica **no** puede expresar, con
  el argumento; F10 la escribe en SQL.

{{protocolo}}
```

## # F09 — Cálculo relacional

```markdown
Esta es la sesión de la **Fase 09 — 📐 Cálculo relacional**. Entregables:
`09-calculo-relacional.md` y su solucionario.

{{marco común}} Añade: F07 cerrada (F08 recomendable).

## Identidad

- Fase 09 de 37 · Bloque II ⭐ · **12 h** · **36 ejercicios** · Depende de F07 · Habilita F10
- Herramientas: papel; verificación vía traducción al álgebra en `radb` · Apéndices: a06, a07
- Plantilla 1. Longitud: 4.500–6.500 palabras.
- Ficha: propuesta de fases, §5, F09.

## Puntos de cuidado

- **El cálculo no se ejecuta**: dilo, y verifica cada consulta traduciéndola al álgebra y corriendo
  esa traducción en `radb`.
- **∀ escrito con ¬∃** es el puente con la división de F07 y con el doble `NOT EXISTS` de F10:
  explícitalo.
- **La seguridad de expresiones** necesita un contraejemplo propio de consulta insegura (infinita),
  sobre `school`.
- La fase carga hacia 🟠 y 🔴 y hacia 🧮: equivalencias, seguridad, traducción en las dos
  direcciones. Los 🔎 son pocos y lo dice el reparto del paso 1.

{{protocolo}}
```

## # F10 — Del álgebra a SQL, operador por operador

```markdown
Esta es la sesión de la **Fase 10 — 📐 Del álgebra a SQL, operador por operador** 🧵. Entregables:
`10-del-algebra-a-sql.md` y su solucionario.

{{marco común}} Añade: F07, F08 y F09 cerradas.

## Identidad

- Fase 10 de 37 · Bloque II ⭐ · **14 h** · **45 ejercicios** · Depende de F07, F08 y F09 · Habilita
  F11 y F12
- Herramientas: SQLite y `radb`, contrastados · Apéndices: a01, a03, a04, a07
- Plantilla 1. Longitud: 5.500–7.500 palabras.
- Ficha: propuesta de fases, §5, F10.

## Puntos de cuidado

- **Es el corazón del hilo 🧵.** La diferencia en sus cuatro formas (`EXCEPT`, `NOT EXISTS`,
  `LEFT JOIN … IS NULL`, `NOT IN`) se compara en una tabla, **y el contraejemplo con `NULL` que
  rompe `NOT IN` se ejecuta en SQLite** con su salida literal. `EXCEPT ALL` se presenta aquí y se
  profundiza en F11.
- **La división en SQL**: doble `NOT EXISTS` (que es el ∀ con ¬∃ de F09) y por conteo; el caso donde
  la de conteo falla con duplicados, ejecutado.
- **La afirmación sobre MySQL y `EXCEPT`** quedó verificada en P9 en el manual de MySQL 8.0:
  *"`EXCEPT` was added in MySQL 8.0.31"*, con `DISTINCT` por defecto y `ALL`. La sesión vuelve a
  abrir la URL antes de citarla; si no responde, se escribe en términos genéricos y se declara.
- **Prueba de fuego:** cada consulta SQL de la fase tiene su expresión de álgebra, y **los dos
  resultados coinciden** sobre los datos chicos. Donde no coinciden (multiconjuntos, `NULL`), la
  diferencia es el contenido.
- *SQL Cookbook* y *SQL and Relational Theory* se citan por receta o capítulo; ninguna receta se
  copia.
- Al menos la mitad de los ejercicios son 🔎, y al menos tres 🧮 (equivalencias bajo `NULL`).

{{protocolo}}
```

## # F11 — `NULL`, lógica de tres valores y multiconjuntos

```markdown
Esta es la sesión de la **Fase 11 — 📐 `NULL`, lógica de tres valores y multiconjuntos** 🧵.
Entregables: `11-null-y-multiconjuntos.md` y su solucionario.

{{marco común}} Añade: F10 cerrada.

## Identidad

- Fase 11 de 37 · Bloque II ⭐ · **10 h** · **36 ejercicios** · Depende de F10 · Habilita F12 y F26
- Herramientas: SQLite · Apéndices: a01, a04, a07
- Plantilla 1. Longitud: 4.500–6.500 palabras.
- Ficha: propuesta de fases, §5, F11.

## Puntos de cuidado

- **Qué implementa SQLite de los operadores de bolsas**: `UNION ALL` sí; `INTERSECT ALL` y
  `EXCEPT ALL`, **no** (P8, H6, `near "ALL": syntax error`). Se vuelve a ejecutar en la sesión; lo que
  no implementa se dice, se escribe la alternativa y se remite en prosa a los cursos de motor.
- **La crítica de Date a `NULL`** se presenta con sus argumentos **y con los de la otra parte**
  (Codd y los dos tipos de marcas, la práctica de la industria). Tono de la guía §2: honesto con las
  dos posiciones.
- Las tablas de verdad de `UNKNOWN` van completas; los ejemplos de `NULL` en `GROUP BY`, `DISTINCT` y
  `UNIQUE` se ejecutan, porque ahí SQL es menos intuitivo.
- Cierra el tramo SQL del hilo 🧵: qué leyes del álgebra de conjuntos dejan de valer con bolsas, como
  Propiedades numeradas con contraejemplo.

{{protocolo}}
```

## # F12 — Vistas y el problema de actualizarlas

```markdown
Esta es la sesión de la **Fase 12 — 📐 Vistas y el problema de actualizarlas**. Entregables:
`12-vistas.md` y su solucionario.

{{marco común}} Añade: F05 y F10 cerradas.

## Identidad

- Fase 12 de 37 · Bloque II ⭐ · **6 h** · **30 ejercicios** · Depende de F05 y F10 · Habilita F13
  y F36
- Herramientas: SQLite · Apéndices: a01, a04
- Plantilla 1. Longitud: 3.000–4.500 palabras.
- Ficha: propuesta de fases, §5, F12.

## Puntos de cuidado

- **SQLite no permite actualizar vistas directamente**: verifícalo, dilo, y usa `INSTEAD OF` como la
  salida, sin adelantar la teoría de triggers de F36.
- **La ambigüedad de traducir una actualización** sobre una vista de join se muestra con un
  contraejemplo concreto de dos traducciones válidas y distintas.
- `WITH CHECK OPTION`: SQLite **no lo soporta** (P8, H6, `near "WITH": syntax error`), y **ninguna
  vista de SQLite es actualizable** sin `INSTEAD OF`. Se explica con el estándar, se declara, y el 🔥
  lo ejecuta en el PostgreSQL de `a09` si ya existe.
- Es una fase corta y de muchos ejercicios: carga hacia ✍️ ("¿es actualizable esta vista? ¿por
  qué?") y 🔎.

{{protocolo}}
```

## # F13 — Del ER/EER al modelo relacional

```markdown
Esta es la sesión de la **Fase 13 — 📐 Del ER/EER al modelo relacional**. Entregables:
`13-del-er-al-relacional.md` y su solucionario.

{{marco común}} Añade: F02, F03, F05 y F12 cerradas.

## Identidad

- Fase 13 de 37 · Bloque II ⭐ · **10 h** · **38 ejercicios** · Depende de F02, F03, F05 y F12 ·
  Habilita F14
- Herramientas: SQLite y `radb` · Apéndices: a04, a07
- Plantilla 1. Longitud: 4.500–6.500 palabras. Lleva recuadro 🏛️.
- Ficha: propuesta de fases, §5, F13.

## Puntos de cuidado

- **El mapeo de `school` y `supply` tiene que llegar al esquema de `a04`.** Si llega a otro, dilo en
  el paso 3 y no lo corrijas: la discrepancia la resuelve Oskar.
- **Las cuatro opciones para una jerarquía EER** van con su costo en `NULL`, joins y restricciones,
  en una tabla, y una consulta por opción verificada en `radb`.
- **Jerarquías en el modelo relacional** (lista de adyacencia, conjuntos anidados, camino
  materializado, tabla de clausura): costo de lectura y escritura de cada una como modelo, y una
  consulta de cada una ejecutada en SQLite sobre los prerrequisitos de `subject`.
- Cierra el Bloque II: el resumen dice qué se lleva el lector al Bloque III.

{{protocolo}}
```

---

## 🧱 Bloque III · Diseño y normalización ⭐

## # F14 — Guías informales de diseño y anomalías

```markdown
Esta es la sesión de la **Fase 14 — 🧱 Guías informales de diseño y anomalías**. Entregables:
`14-guias-de-diseno-y-anomalias.md` y su solucionario.

{{marco común}} Añade: F13 cerrada.

## Identidad

- Fase 14 de 37 · Bloque III ⭐ · **8 h** · **30 ejercicios** · Depende de F13 · Habilita F15
- Herramientas: SQLite y `radb` · Apéndices: a04
- Plantilla 1. Longitud: 3.000–4.500 palabras.
- Ficha: propuesta de fases, §6, F14.

## Puntos de cuidado

- **Abre el bloque de énfasis**: presenta el Bloque III y los dos casos que lo recorren (la planilla
  de notas y la factura plana). Ambos se crean como relaciones de trabajo en la fase, con datos
  chicos; si hacen falta en `a04`, se agregan allí.
- **Cada anomalía se provoca con datos**, en SQLite, con la salida antes y después.
- **Las tuplas espurias** aparecen en la salida de `radb` al juntar una mala descomposición: ese
  resultado es la prueba de fuego de la fase.
- No adelantes las definiciones formales de F15–F16: aquí el criterio es informal y se dice.

{{protocolo}}
```

## # F15 — Dependencias funcionales

```markdown
Esta es la sesión de la **Fase 15 — 🧮 Dependencias funcionales**. Entregables:
`15-dependencias-funcionales.md`, su solucionario y los verificadores `closure`, `min_cover` y `keys`
en `src/a05-verificadores-y-mini-motor/`, con su sección en `a05`.

{{marco común}} Añade: F14 cerrada.

## Identidad

- Fase 15 de 37 · Bloque III ⭐ · **14 h** · **45 ejercicios** · Depende de F14 · Habilita F16, F17
  y F18
- Herramientas: papel y verificadores · Apéndices: a05, a06, a07
- Plantilla 1. Longitud: 5.500–7.500 palabras.
- Ficha: propuesta de fases, §6, F15.

## Puntos de cuidado

- **Nacen los verificadores.** Fija en el paso 1 el formato de entrada de relaciones y DF (por
  ejemplo, `R(A,B,C,D,E)` y `A->B; BC->D`), que ya no cambia en el resto del curso. Cada verificador
  se prueba contra los ejemplos resueltos de la fase antes de publicar nada.
- **"Una DF es del esquema, no del estado"** es la idea central: el precio de la línea contra el de
  la parte, con datos donde la DF parece cumplirse sin existir.
- **La solidez de los axiomas de Armstrong se demuestra completa**; la completitud, con el
  argumento o la referencia, y se dice cuál.
- **El recubrimiento mínimo no es único**: un ejemplo con dos resultados válidos.
- **Todas las claves candidatas**: el método con sus atajos (atributos que nunca están a la derecha,
  que nunca están a la izquierda), y un caso con más de una clave.
- Al menos la mitad de los ejercicios son ✍️ de cálculo; al menos cinco 🧮.

{{protocolo}}
```

## # F16 — Formas normales: de 1FN a FNBC

```markdown
Esta es la sesión de la **Fase 16 — 🧱 Formas normales: de 1FN a FNBC**. Entregables:
`16-formas-normales.md`, su solucionario y el verificador `normal_form` (con su sección en `a05`).

{{marco común}} Añade: F15 cerrada, con los verificadores en `a05`.

## Identidad

- Fase 16 de 37 · Bloque III ⭐ · **12 h** · **42 ejercicios** · Depende de F15 · Habilita F17 y F18
- Herramientas: papel, verificadores y SQLite · Apéndices: a05, a07
- Plantilla 1. Longitud: 4.500–6.500 palabras.
- Ficha: propuesta de fases, §6, F16.

## Puntos de cuidado

- **Las dos versiones de 2FN y 3FN** (basada en la clave primaria y general) se definen por
  separado, numeradas, con el ejemplo donde difieren.
- **El caso 3FN-no-FNBC** se construye sobre `school` con estructura propia (por ejemplo, alumno,
  asignatura y docente, con docente → asignatura), con datos originales.
- **La factura plana llega hasta FNBC paso a paso**, y SQLite muestra que las anomalías de F14
  desaparecen.
- Carga hacia 🟠 y 🔴 y hacia 🧮 (probar en qué forma normal está una relación).

{{protocolo}}
```

## # F17 — Propiedades de las descomposiciones

```markdown
Esta es la sesión de la **Fase 17 — 🧮 Propiedades de las descomposiciones**. Entregables:
`17-propiedades-de-las-descomposiciones.md`, su solucionario y los verificadores `njb`, `chase` y
`preserves` (con su sección en `a05`).

{{marco común}} Añade: F16 cerrada.

## Identidad

- Fase 17 de 37 · Bloque III ⭐ · **12 h** · **40 ejercicios** · Depende de F16 · Habilita F18
- Herramientas: papel, verificadores y `radb` · Apéndices: a05, a07
- Plantilla 1. Longitud: 4.500–6.500 palabras.
- Ficha: propuesta de fases, §6, F17.

## Puntos de cuidado

- **El *chase* con traza completa** en ASCII de 75 columnas (la tabla de símbolos a y b), en el
  texto y en la salida del verificador, que deben coincidir.
- **La preservación de dependencias** se comprueba con el algoritmo que no calcula F⁺, y se dice por
  qué importa.
- **Independencia de las dos propiedades**: un ejemplo sin pérdida que no preserva y otro que
  preserva con pérdida.
- Las tuplas espurias de una descomposición con pérdida se muestran en `radb`, enlazando con F14.

{{protocolo}}
```

## # F18 — Algoritmos de diseño relacional

```markdown
Esta es la sesión de la **Fase 18 — 🧮 Algoritmos de diseño relacional**. Entregables:
`18-algoritmos-de-diseno.md`, su solucionario y los verificadores `synth_3nf` y `bcnf_decompose`
(con su sección en `a05`).

{{marco común}} Añade: F17 cerrada.

## Identidad

- Fase 18 de 37 · Bloque III ⭐ · **12 h** · **40 ejercicios** · Depende de F17 · Habilita F19 y F20
- Herramientas: papel y verificadores · Apéndices: a05, a07
- Plantilla 1. Longitud: 4.500–6.500 palabras.
- Ficha: propuesta de fases, §6, F18.

## Puntos de cuidado

- **Las propiedades de la síntesis a 3FN se demuestran** (sin pérdida y con preservación); la de
  FNBC, sin pérdida.
- **El no determinismo** se muestra con un mismo F que da dos resultados según el orden, ambos
  válidos, con la salida del verificador en los dos órdenes.
- **Comparación con F13**: los algoritmos aplicados a `school` y `supply` contra el esquema del
  mapeo. Si difieren, la diferencia es contenido, no un error.
- El ⚖️ muestra un resultado correcto y absurdo, y qué criterio de diseño lo corrige.

{{protocolo}}
```

## # F19 — Más allá de FNBC

```markdown
Esta es la sesión de la **Fase 19 — 🧱 Más allá de FNBC**. Entregables: `19-mas-alla-de-fnbc.md` y
su solucionario.

{{marco común}} Añade: F18 cerrada.

## Identidad

- Fase 19 de 37 · Bloque III ⭐ · **12 h** · **36 ejercicios** · Depende de F18 · Habilita F20
- Herramientas: papel y `radb` · Apéndices: a04, a07
- Plantilla 1. Longitud: 4.500–6.500 palabras.
- Ficha: propuesta de fases, §6, F19.

## Puntos de cuidado

- **La 5FN con `shipment`**: la dependencia de join cíclica proveedor–parte–proyecto se enuncia como
  **regla del dominio** (si un proveedor suministra una parte, y esa parte se usa en un proyecto, y
  ese proveedor abastece ese proyecto, entonces…), con datos chicos que la cumplen. **Verifica en
  `radb`** que la descomposición en tres proyecciones y su join reconstruyen exactamente `shipment`,
  y que en dos proyecciones no.
- **Las DMV** con su intuición ("independencia de dos listas") antes de la definición formal.
- DKNF y las dependencias de inclusión se presentan como teoría, sin prometer algoritmo.
- Carga hacia 🧮 y 🔴.

{{protocolo}}
```

## # F20 — Desnormalización y diseño físico

```markdown
Esta es la sesión de la **Fase 20 — 🧱 Desnormalización y diseño físico**. Entregables:
`20-desnormalizacion-y-diseno-fisico.md` y su solucionario.

{{marco común}} Añade: F18 cerrada (F19 recomendable).

## Identidad

- Fase 20 de 37 · Bloque III ⭐ · **10 h** · **30 ejercicios** · Depende de F18 · Habilita F21 y F33
- Herramientas: papel y SQLite · Apéndices: a04
- Plantilla 1. Longitud: 4.500–6.500 palabras.
- Ficha: propuesta de fases, §6, F20.

## Puntos de cuidado

- **Cierra el Bloque III**: el resumen hace el balance del bloque y anuncia el IV.
- **Todos los costos son modelo**: escrituras extra por lectura ahorrada, con supuestos declarados.
  Nada de "es más rápido".
- **El precio de la línea no es desnormalización**: es la idea que la fase tiene que dejar clara, con
  el argumento de F15.
- La anomalía de una columna derivada olvidada se provoca en SQLite. El trigger que la mantendría se
  difiere a F36 con destino explícito.

{{protocolo}}
```

---

## 💾 Bloque IV · Almacenamiento e índices

## # F21 — Discos, bloques y organización de archivos

```markdown
Esta es la sesión de la **Fase 21 — 💾 Discos, bloques y organización de archivos**. Entregables:
`21-discos-y-archivos.md` y su solucionario.

{{marco común}} Añade: F20 cerrada.

## Identidad

- Fase 21 de 37 · Bloque IV · **10 h** · **32 ejercicios** · Depende de F20 · Habilita F22 y F23
- Herramientas: papel; SQLite como ventana (`PRAGMA page_size`, `page_count`) · Apéndices: a01, a06
- Plantilla 1. Longitud: 4.500–6.500 palabras.
- Ficha: propuesta de fases, §7, F21.

## Puntos de cuidado

- **Abre el bloque IV y fija el modelo de costo** que usan F21–F28: la unidad (acceso a bloque), los
  símbolos (b, bfr, r, n_B…) con su notación en `a07`, y los supuestos. Ninguna fase posterior lo
  redefine.
- **SSD contra disco giratorio**: qué cambia en la realidad y qué no cambia en el modelo, sin
  números de producto.
- **Las políticas de reemplazo del buffer** se trazan sobre una secuencia de referencias concreta.
- Declara el volumen generado de `a04` que usan las fases del bloque, o propón uno en el paso 1.

{{protocolo}}
```

## # F22 — Hashing

```markdown
Esta es la sesión de la **Fase 22 — 💾 Hashing**. Entregables: `22-hashing.md` y su solucionario.

{{marco común}} Añade: F21 cerrada.

## Identidad

- Fase 22 de 37 · Bloque IV · **10 h** · **34 ejercicios** · Depende de F21 · Habilita F25 y F26
- Herramientas: papel; verificador `ext_hash`/`linear_hash` (candidato) · Apéndices: a05, a06
- Plantilla 1. Longitud: 4.500–6.500 palabras.
- Ficha: propuesta de fases, §7, F22.

## Puntos de cuidado

- **Decide en el paso 1 si se escribe el verificador de hashing.** Si sí, entra en `a05` en esta
  sesión; si no, cada traza se contrasta con una segunda resolución independiente y se dice.
- **Hashing extensible y lineal paso a paso**, con trazas ASCII de 75 columnas: directorio,
  profundidades global y local, puntero de división, nivel.
- La convención de qué bits se usan (los de menor o mayor orden) se fija y va a `a07`.
- Carga hacia 🟢 y 🟡: el músculo se hace con trazas.

{{protocolo}}
```

## # F23 — Índices de uno y varios niveles

```markdown
Esta es la sesión de la **Fase 23 — 💾 Índices de uno y varios niveles**. Entregables:
`23-indices-de-uno-y-varios-niveles.md` y su solucionario.

{{marco común}} Añade: F21 cerrada.

## Identidad

- Fase 23 de 37 · Bloque IV · **8 h** · **32 ejercicios** · Depende de F21 · Habilita F24
- Herramientas: papel · Apéndices: a06
- Plantilla 1. Longitud: 3.000–4.500 palabras.
- Ficha: propuesta de fases, §7, F23.

## Puntos de cuidado

- **La terminología de índices varía entre libros** (primario, *clustering*, secundario; denso y
  disperso): la tabla de traducción de la sección 📖 es especialmente importante aquí, y va a `a07`.
- Cada tipo de índice con su costo calculado sobre el mismo archivo de `supply`, para que se puedan
  comparar.
- El costo de mantener un índice secundario en cada escritura se calcula, y es el ⚖️.

{{protocolo}}
```

## # F24 — Árboles B y B+

```markdown
Esta es la sesión de la **Fase 24 — 🌳 Árboles B y B+**. Entregables: `24-arboles-b-y-b-mas.md`, su
solucionario y el verificador `bplus` (con su sección en `a05`).

{{marco común}} Añade: F23 cerrada.

## Identidad

- Fase 24 de 37 · Bloque IV · **12 h** · **45 ejercicios** · Depende de F23 · Habilita F25 y F26
- Herramientas: papel, verificador `bplus`, SQLite como ventana · Apéndices: a05, a06, a07
- Plantilla 1. Longitud: 4.500–6.500 palabras. Lleva recuadro 🏛️.
- Ficha: propuesta de fases, §7, F24.

## Puntos de cuidado

- **La definición de "orden" es la mayor fuente de confusión del tema**: Navathe, Knuth y otros la
  definen distinto (máximo de punteros, mínimo de claves…). Fija en el paso 1 la del curso, con su
  equivalencia con las otras en la sección 📖 y en `a07`. Todas las trazas y ejercicios la usan.
- **Inserción con división y borrado con fusión y redistribución, con trazas completas** en ASCII de
  75 columnas, que deben coincidir con la salida de `bplus`.
- **El 🪞 del UUID**: la ocupación de las hojas con claves crecientes contra aleatorias, calculada o
  simulada con `bplus`, y dicho como modelo.
- **`dbstat` y `sqlite3_analyzer`** están disponibles en `mdm-lab` (P8, H8; el segundo viene en el
  paquete `sqlite3-tools` de Debian). En las plataformas del lector no se verificaron: la fase lo
  dice, y la ventana a SQLite es complementaria, nunca el centro.
- Al menos la mitad de los ejercicios son ✍️ de trazas.

{{protocolo}}
```

## # F25 — Otras estructuras de índice

```markdown
Esta es la sesión de la **Fase 25 — 💾 Otras estructuras de índice**. Entregables:
`25-otras-estructuras-de-indice.md` y su solucionario.

{{marco común}} Añade: F22 y F24 cerradas.

## Identidad

- Fase 25 de 37 · Bloque IV · **10 h** · **34 ejercicios** · Depende de F22 y F24 · Habilita F26
- Herramientas: papel · Apéndices: a06
- Plantilla 1. Longitud: 4.500–6.500 palabras.
- Ficha: propuesta de fases, §7, F25.

## Puntos de cuidado

- **Cierra el bloque IV.** Su tabla de cierre ("qué estructura para qué patrón de acceso, con qué
  costo") es lo que los cursos de motor van a citar: completa, con costos como modelo.
- **LSM con su amplificación de escritura, de lectura y de espacio** como fórmulas con supuestos,
  citando a Petrov y a O'Neil et al.
- **Bitmap y su compresión** sobre una columna de baja cardinalidad de `school` (por ejemplo, el
  período).
- Remite en prosa a los cursos de motor que implementan cada estructura, sin afirmar qué motor tiene
  qué sin verificarlo en su documentación.

{{protocolo}}
```

---

## ⚙️ Bloque V · Implementación de operadores y optimización

## # F26 — Cómo se implementa cada operador

```markdown
Esta es la sesión de la **Fase 26 — ⚙️ Cómo se implementa cada operador** 🧵. Entregables:
`26-implementacion-de-operadores.md`, su solucionario y **el mini motor** en
`src/a05-verificadores-y-mini-motor/`, con su sección en `a05`.

{{marco común}} Añade: F08, F11, F24 y F25 cerradas.

## Identidad

- Fase 26 de 37 · Bloque V · **16 h** · **45 ejercicios** · Depende de F08, F11, F24 y F25 ·
  Habilita F27 y F28
- Herramientas: papel, mini motor y `EXPLAIN QUERY PLAN` de SQLite · Apéndices: a04, a05, a06
- Plantilla 1. Longitud: 5.500–7.500 palabras.
- Ficha: propuesta de fases, §8, F26.

## Puntos de cuidado

- **Es el final del hilo 🧵**: π con eliminación de duplicados y ∪, ∩ y − **por ordenamiento y por
  hash**, con su costo en papel y su implementación en el mini motor. "Dónde estamos" recapitula el
  hilo desde F06.
- **El mini motor**: Python con biblioteca estándar, operadores como iteradores (`open`, `next`,
  `close`) y un contador de bloques leídos que simula páginas. Diseña en el paso 1 su interfaz y el
  tamaño de página simulado; ese diseño lo reutiliza el bloque A.C. (L1).
- **Prueba de fuego:** para cada algoritmo, **el contador del mini motor coincide con el costo
  calculado en papel** sobre los mismos datos. Si no coincide, uno de los dos está mal: dilo.
- **El 🪞 de `DISTINCT`** se demuestra con el costo de la eliminación de duplicados contra la misma
  proyección sin ella.
- `EXPLAIN QUERY PLAN` de SQLite es una ventana: qué algoritmo eligió para una consulta dada, sin
  afirmar internals que no muestre.
- Al menos un tercio de los ejercicios son 🔎 en el mini motor, y hay 🧩 de implementar un operador
  que falta.

{{protocolo}}
```

## # F27 — Optimización heurística

```markdown
Esta es la sesión de la **Fase 27 — ⚙️ Optimización heurística**. Entregables:
`27-optimizacion-heuristica.md` y su solucionario.

{{marco común}} Añade: F26 cerrada.

## Identidad

- Fase 27 de 37 · Bloque V · **10 h** · **34 ejercicios** · Depende de F26 · Habilita F28
- Herramientas: papel y mini motor · Apéndices: a05, a07
- Plantilla 1. Longitud: 4.500–6.500 palabras.
- Ficha: propuesta de fases, §8, F27.

## Puntos de cuidado

- **Las reglas de transformación citan por número las Propiedades de F06–F08**; las que no se
  demostraron allí, se demuestran aquí o se dice que se toman del libro.
- **Árboles de consulta en ASCII de 75 columnas**, antes y después de cada paso del algoritmo
  heurístico.
- **El costo del árbol inicial contra el optimizado**, calculado y ejecutado en el mini motor.

{{protocolo}}
```

## # F28 — Optimización basada en costo

```markdown
Esta es la sesión de la **Fase 28 — ⚙️ Optimización basada en costo**. Entregables:
`28-optimizacion-por-costo.md` y su solucionario.

{{marco común}} Añade: F27 cerrada.

## Identidad

- Fase 28 de 37 · Bloque V · **14 h** · **36 ejercicios** · Depende de F27 · Habilita F33
- Herramientas: papel; SQLite como ventana (`EXPLAIN QUERY PLAN`, `ANALYZE`) · Apéndices: a04, a06
- Plantilla 1. Longitud: 5.500–7.500 palabras.
- Ficha: propuesta de fases, §8, F28.

## Puntos de cuidado

- **La programación dinámica para el orden de joins**, con la tabla completa para tres o cuatro
  relaciones de `supply`.
- **El 🪞 del optimizador**: un caso calculado donde la estimación con independencia de columnas falla
  por órdenes de magnitud (columnas correlacionadas de `school`, como sección y grado).
- **SQLite como ventana**: qué cambia en `EXPLAIN QUERY PLAN` antes y después de `ANALYZE`, verificado.
  No afirmes cómo funciona su planificador por dentro más allá de su documentación.
- Cierra el bloque V.

{{protocolo}}
```

---

## 🔒 Bloque VI · Transacciones

## # F29 — Transacciones y planes

```markdown
Esta es la sesión de la **Fase 29 — 🔒 Transacciones y planes**. Entregables:
`29-transacciones-y-planes.md`, su solucionario y el verificador `conflict_serializable` (con su
sección en `a05`).

{{marco común}} Añade: F05 cerrada (el resto del curso recomendable).

## Identidad

- Fase 29 de 37 · Bloque VI · **12 h** · **42 ejercicios** · Depende de F05 · Habilita F30, F31 y F32
- Herramientas: papel y verificador · Apéndices: a05, a07
- Plantilla 1. Longitud: 4.500–6.500 palabras.
- Ficha: propuesta de fases, §9, F29.

## Puntos de cuidado

- **Abre el bloque VI y fija la notación de planes** (`r1(X); w2(X); c1; a2`) en `a07`; el verificador
  la acepta tal cual.
- **Grafo de precedencia con traza** y orden serial equivalente, en el texto y en la salida del
  verificador.
- **La jerarquía de planes** (estrictos ⊂ sin cascada ⊂ recuperables) con un plan en cada franja y
  uno fuera de todas.
- La serializabilidad por vistas: el ejemplo con escritura ciega que es serializable por vistas y no
  por conflicto.

{{protocolo}}
```

## # F30 — Control de concurrencia

```markdown
Esta es la sesión de la **Fase 30 — 🔒 Control de concurrencia**. Entregables:
`30-control-de-concurrencia.md` y su solucionario.

{{marco común}} Añade: F29 cerrada.

## Identidad

- Fase 30 de 37 · Bloque VI · **14 h** · **42 ejercicios** · Depende de F29 · Habilita F31 y F32
- Herramientas: papel y el verificador de F29 · Apéndices: a05, a07
- Plantilla 1. Longitud: 5.500–7.500 palabras.
- Ficha: propuesta de fases, §9, F30.

## Puntos de cuidado

- **La demostración de que 2PL garantiza serializabilidad por conflicto**, completa.
- **Cada protocolo con traza sobre el mismo par de transacciones**, para que se puedan comparar:
  2PL en sus variantes, wait-die, wound-wait, marcas de tiempo (con y sin regla de Thomas), MVCC y
  validación optimista.
- **El problema de los fantasmas** y por qué el bloqueo de tuplas no lo resuelve.
- MVCC se enseña como teoría; cómo lo implementa cada motor se remite en prosa a su curso.

{{protocolo}}
```

## # F31 — Niveles de aislamiento

```markdown
Esta es la sesión de la **Fase 31 — 🔒 Niveles de aislamiento**. Entregables:
`31-niveles-de-aislamiento.md` y su solucionario.

{{marco común}} Añade: F30 cerrada.

## Identidad

- Fase 31 de 37 · Bloque VI · **8 h** · **32 ejercicios** · Depende de F30 · Habilita F32
- Herramientas: papel y SQLite con dos conexiones · Apéndices: a01
- Plantilla 1. Longitud: 3.000–4.500 palabras.
- Ficha: propuesta de fases, §9, F31.

## Puntos de cuidado

- **El *write skew* con el ejemplo de los dos docentes de turno**, en un plan escrito con la notación
  de F29, y por qué snapshot isolation lo permite.
- **Qué hace SQLite** con dos conexiones (un escritor, `SQLITE_BUSY`, modo WAL), verificado en la
  sesión con su salida literal.
- **El 🪞 de `SERIALIZABLE`**: cualquier afirmación sobre qué nivel implementa un motor concreto se
  verifica en su documentación oficial con fecha; si no, se escribe en general ("en algunos motores")
  y se remite al curso de motor.
- Berenson et al. se presenta con sus fenómenos (P0–P3, A5A, A5B) en la notación del curso.

{{protocolo}}
```

## # F32 — Recuperación

```markdown
Esta es la sesión de la **Fase 32 — 🔒 Recuperación**. Entregables: `32-recuperacion.md` y su
solucionario.

{{marco común}} Añade: F30 cerrada.

## Identidad

- Fase 32 de 37 · Bloque VI · **11 h** · **38 ejercicios** · Depende de F30 · Habilita F35
- Herramientas: papel; el modo WAL de SQLite como ventana · Apéndices: a01, a07
- Plantilla 1. Longitud: 4.500–6.500 palabras.
- Ficha: propuesta de fases, §9, F32.

## Puntos de cuidado

- **ARIES paso a paso** sobre una bitácora con LSN, tabla de transacciones y tabla de páginas sucias:
  análisis, redo y undo, con traza completa en ASCII de 75 columnas. Contrasta cada traza con una
  segunda resolución independiente y dilo en el solucionario.
- **La matriz *steal/no-steal* × *force/no-force*** con qué exige cada combinación (UNDO, REDO).
- **El WAL de SQLite como ventana**: que existe el archivo `-wal`, qué contiene en términos generales
  y el `checkpoint`, sin afirmar detalles de formato no verificados.
- Cierra el bloque VI.

{{protocolo}}
```

---

## 🛠️ Bloque VII · Administración: lo core

## # F33 — El DBA y su trabajo

```markdown
Esta es la sesión de la **Fase 33 — 🛠️ El DBA y su trabajo**. Entregables: `33-el-dba.md` y su
solucionario.

{{marco común}} Añade: F20 y F28 cerradas.

## Identidad

- Fase 33 de 37 · Bloque VII · **8 h** · **28 ejercicios** · Depende de F20 y F28 · Habilita F34 y F35
- Herramientas: papel y el catálogo de SQLite · Apéndices: a01
- Plantilla 1. Longitud: 3.000–4.500 palabras.
- Ficha: propuesta de fases, §10, F33.

## Puntos de cuidado

- **Abre el bloque VII** y dice con claridad qué es teoría de administración (este curso) y qué es
  operación de un producto (los cursos de motor).
- **El tuning se enseña como decisión a partir de una carga**, con los costos de F20–F28, no como
  lista de trucos.
- Los ejercicios cargan hacia 🧩 de decisión sobre cargas descritas.

{{protocolo}}
```

## # F34 — Seguridad y autorización

```markdown
Esta es la sesión de la **Fase 34 — 🛡️ Seguridad y autorización**. Entregables:
`34-seguridad-y-autorizacion.md` y su solucionario.

{{marco común}} Añade: F12 y F33 cerradas.

## Identidad

- Fase 34 de 37 · Bloque VII · **12 h** · **36 ejercicios** · Depende de F12 y F33 · Habilita F35
- Herramientas: papel; 🔥 PostgreSQL del contenedor de `a09` · Apéndices: a09
- Plantilla 1. Longitud: 4.500–6.500 palabras.
- Ficha: propuesta de fases, §10, F34.

## Puntos de cuidado

- **SQLite no tiene usuarios**: la fase se verifica en papel, con el grafo de autorización, y lo dice
  en el encabezado.
- **La revocación en cascada** se traza sobre un grafo de autorización con al menos un ciclo de
  concesiones, con la semántica del estándar SQL verificada en la sesión (o declarada).
- **Los ejercicios 🔥** repiten los de `GRANT`/`REVOKE` en el PostgreSQL de `a09`, con su salida
  literal; si `a09` todavía no existe, se marcan 🚧 con destino.
- **La inyección SQL** se muestra con una consulta concatenada y su versión parametrizada, en Python
  sobre SQLite, ejecutadas.

{{protocolo}}
```

## # F35 — Respaldo y continuidad

```markdown
Esta es la sesión de la **Fase 35 — 💾 Respaldo y continuidad**. Entregables:
`35-respaldo-y-continuidad.md` y su solucionario.

{{marco común}} Añade: F32 cerrada.

## Identidad

- Fase 35 de 37 · Bloque VII · **10 h** · **30 ejercicios** · Depende de F32 · Habilita F37
- Herramientas: SQLite (`.backup`, `VACUUM INTO`, `PRAGMA integrity_check`) y papel · Apéndices: a01
- Plantilla 1. Longitud: 4.500–6.500 palabras.
- Ficha: propuesta de fases, §10, F35.

## Puntos de cuidado

- **No repitas `a01`**: el apéndice da los comandos; la fase da la teoría y los usa en un ejercicio de
  restauración completo, verificado.
- **RPO y RTO se calculan** para tres estrategias descritas, con supuestos declarados.
- **Restaurar es la prueba**: al menos tres ejercicios exigen restaurar y comprobar la copia, no solo
  respaldar.

{{protocolo}}
```

## # F36 — Bases activas: triggers

```markdown
Esta es la sesión de la **Fase 36 — ⚡ Bases activas: triggers**. Entregables:
`36-bases-activas-triggers.md` y su solucionario.

{{marco común}} Añade: F05 y F12 cerradas.

## Identidad

- Fase 36 de 37 · Bloque VII · **10 h** · **30 ejercicios** · Depende de F05 y F12 · Habilita F37
- Herramientas: SQLite · Apéndices: a01, a04
- Plantilla 1. Longitud: 4.500–6.500 palabras.
- Ficha: propuesta de fases, §10, F36.

## Puntos de cuidado

- **Cierra los pendientes que otras fases difirieron aquí**: el total del pedido (F02, F20), las
  restricciones que el modelo no expresa (F05) y la que FNBC no preserva (F17). Revisa esas fases y
  cita cada pendiente por número.
- **Terminación y confluencia** con el grafo de activación, sobre un conjunto de reglas propio con
  un ciclo.
- **Lo que SQLite soporta y lo que no** (triggers de sentencia, por ejemplo) se verifica y se dice.
- Cierra el bloque VII.

{{protocolo}}
```

---

## 🌐 Bloque VIII · Panorama

## # F37 — Más allá del núcleo

```markdown
Esta es la sesión de la **Fase 37 — 🌐 Más allá del núcleo**. Entregables:
`37-mas-alla-del-nucleo.md` y su solucionario.

{{marco común}} Añade: F35 y F36 cerradas (el curso entero recomendable).

## Identidad

- Fase 37 de 37 · Bloque VIII · **8 h** · **20 ejercicios** · Depende de F35 y F36 · Cierra el camino
  base
- Herramientas: papel · Plantilla 2 (panorama). Longitud: 2.000–3.000 palabras. Lleva recuadro 🏛️.
- Ficha: propuesta de fases, §11, F37.

## Puntos de cuidado

- **Cierra el curso.** El ⚖️ es el veredicto del camino base: cuándo el modelo relacional no es la
  respuesta y hacia dónde ir, con el mismo tono honesto de todo el curso.
- **2PC paso a paso**, incluido el bloqueo del coordinador caído.
- **CAP sin misticismo**: qué dice y qué no dice el teorema.
- **NoSQL con referencias de concepto a la Ruta NoSQL Lite**, en prosa: la documental es jerárquica en
  el fondo y la de grafos es una red. Ese curso no se modifica.
- El recuadro 🏛️ invita al bloque A.C. como continuación opcional.

{{protocolo}}
```
