# 🏛️ Prompts iniciales del bloque A.C. — Antes de Codd
## El motor de motores — 10 sesiones, 10 fases opcionales con su solucionario

Cada sección es el prompt completo de una fase del bloque opcional A.C., listo para pegar. Es un
archivo de track propio, como pide el repositorio: **una sesión del camino base nunca necesita
leerlo**, y una del bloque A.C. no añade nada a `prompts-de-fase.md`.

**La ficha manda; el prompt completa.** El contenido de cada fase está en su ficha de
[`propuesta-fases-y-alcance.md`](propuesta-fases-y-alcance.md), §12. Si la ficha cambia, el prompt
se revisa después y **nunca al revés**.

> ⚠️ **Antes de la primera sesión del bloque.** Tienen que estar cerrados los bloques II y IV del
> camino base y F26 (el mini motor), porque el bloque compara contra ellos y reutiliza el contador de
> bloques. `aca-01` se escribe con AC01 y `aca-02` con AC08.

---

## 🧱 El marco del bloque

Es el marco común de [`prompts-de-fase.md`](prompts-de-fase.md) con cuatro cambios. **No lo repitas
en el documento: aplícalo.**

```markdown
## Marco (no lo repitas, aplícalo)

El marco común de `prompts/prompts-de-fase.md`, completo, con estos cambios:

- **Plantillas:** la 3 (fase del bloque A.C.) para AC00–AC05 y AC09, y la 4 (caso de estudio) para
  AC06–AC08, en `prompts/plantillas-de-capitulo.md`.
- **Nombres:** fases `acNN-slug.md`, solucionarios `soluciones/acNN-slug.md`, código en
  `src/acNN-slug/`, apéndices `aca-NN-…`. Tags `ac-fase-<slug>` y prefijo de commit `01-bases acNN:`,
  que Oskar aplica; no commitees.
- **Autocontenido:** el bloque puede citar el camino base por fase y número de definición, pero
  **ninguna fase del camino base puede depender de él**. Si al escribir descubres que algo del
  camino base necesita contenido de aquí, dilo; no lo muevas.
- **Productos reales:** toda afirmación sobre qué motor usa hoy un producto (Active Directory,
  OpenLDAP, Subversion, RPM, VistA, Epic…), desde qué versión y con qué licencia, se verifica en una
  fuente primaria en la sesión o se declara no verificada. Varios cambiaron de motor en los últimos
  años, y ese cambio es parte del contenido.
- **Sin IMS ni IDMS reales:** DL/I y el DML de CODASYL se enseñan en papel y con los mini DML de los
  laboratorios, y el texto lo dice.
- **Con la Ruta NoSQL Lite, solo referencias de concepto**, en prosa. Ese curso no se toca.
```

Y el mismo **protocolo de tres pasos** de `prompts-de-fase.md`.

---

## # AC00 — Navegar contra declarar

```markdown
Esta es la sesión de la **Fase AC00 — 🏺 Navegar contra declarar**, del bloque A.C. de El motor de
motores. Entregables: `ac00-navegar-contra-declarar.md` y su solucionario.

{{marco del bloque}}

## Identidad

- Fase AC00 de AC09 · Bloque A.C. (opcional) · **3 h** · **15 ejercicios** · Depende de: bloques II
  y IV · Habilita: AC01
- Herramientas: papel · Plantilla 3. Longitud: 2.000–3.000 palabras.
- Ficha: propuesta de fases, §12, AC00.

## Puntos de cuidado

- **Abre el bloque**: qué es, que es opcional, qué conviene haber leído antes y qué gana quien lo
  hace.
- **🏺 Por qué estudiar arqueología** es la sección que tiene que convencer a un ingeniero ocupado.
  Tres tablas (dónde viven hoy el jerárquico, la red y el gestor de registros sin modelo) y la lista
  de lo que gana el ingeniero. **Cada fila de las tablas se verifica en la sesión** o se marca no
  verificada; ninguna se escribe de memoria.
- **El 🪞 del bloque**: *"Tu instinto de ingeniero moderno dice que esto es historia… y esta vez se
  equivoca"*, con los ejemplos verificados (iniciar sesión en un dominio Windows, `git log`, un
  expediente clínico).
- La línea de tiempo de los modelos en ASCII de 75 columnas.

{{protocolo}}
```

## # AC01 — Archivos, registros y punteros en disco

```markdown
Esta es la sesión de la **Fase AC01 — 📁 Archivos, registros y punteros en disco**. Entregables:
`ac01-archivos-registros-y-punteros.md`, su solucionario, los laboratorios L1 y L5 en
`src/ac01-archivos-registros-y-punteros/` y el apéndice `aca-01-herramientas-nativas.md` (con su
propio prompt, en `prompts-de-apendice.md`).

{{marco del bloque}}

## Identidad

- Fase AC01 de AC09 · Bloque A.C. · **8 h** · **24 ejercicios** · Depende de AC00 y F21 · Habilita
  AC02 y AC03
- Herramientas: Python (L1, L5); 🔥 GnuCOBOL y Harbour · Plantilla 3. Longitud: 3.000–4.500 palabras.
- Ficha: propuesta de fases, §12, AC01.

## Puntos de cuidado

- **L1 es la base de L2, L3 y L5**: diseña en el paso 1 su interfaz (páginas fijas, *database key*
  como página y ranura, contador de bloques) **reutilizando el contador del mini motor de F26**, para
  que los números del bloque se puedan comparar con los del camino base.
- **L5** monta L1 sobre el módulo `dbm` de Python: la separación entre motor y modelo, ejecutada.
- **El 🪞 del puntero O(1)**: un recorrido por punteros en L1 con su contador de bloques, contra el
  mismo recorrido en memoria.
- GnuCOBOL y Harbour son 🔥: si P8 no confirmó que se instalan, los ejercicios que los usan se marcan
  🚧 con destino.

{{protocolo}}
```

## # AC02 — El modelo jerárquico

```markdown
Esta es la sesión de la **Fase AC02 — 🌲 El modelo jerárquico**. Entregables:
`ac02-modelo-jerarquico.md`, su solucionario y el laboratorio L3 en `src/ac02-modelo-jerarquico/`.

{{marco del bloque}}

## Identidad

- Fase AC02 de AC09 · Bloque A.C. · **8 h** · **26 ejercicios** · Depende de AC01 · Habilita AC04
  y AC08
- Herramientas: Python (L3, sobre L1) · Plantilla 3. Longitud: 3.000–4.500 palabras.
- Ficha: propuesta de fases, §12, AC02.

## Puntos de cuidado

- **L3: `school` como árbol** (curso → sección → matrícula → calificación) recorrido en preorden con
  un mini DL/I (`gu`, `gn`, `gnp`), con el contador de bloques de L1.
- **La pregunta inversa** (*"¿en qué secciones está este alumno?"*) se ejecuta en L3 y se cuenta: es
  el dolor del modelo, y AC08 vuelve a ella.
- **DL/I se enseña en papel**: escribe los programas con la sintaxis de IMS como pseudocódigo
  declarado, y su equivalente ejecutable en el mini DL/I.
- El mapeo ER → jerárquico de `school`, con la duplicación que exige el muchos-a-muchos, contada.

{{protocolo}}
```

## # AC03 — El modelo de red

```markdown
Esta es la sesión de la **Fase AC03 — 🕸️ El modelo de red**. Entregables: `ac03-modelo-de-red.md`,
su solucionario y el laboratorio L2 en `src/ac03-modelo-de-red/`.

{{marco del bloque}}

## Identidad

- Fase AC03 de AC09 · Bloque A.C. · **10 h** · **30 ejercicios** · Depende de AC01 · Habilita AC04,
  AC07 y AC09
- Herramientas: Python (L2, sobre L1) · Plantilla 3. Longitud: 3.000–4.500 palabras.
- Ficha: propuesta de fases, §12, AC03.

## Puntos de cuidado

- **L2: `supply` con pedidos en red**: `customer`, `sales_order`, `order_line` y `part` como tipos de
  registro, *sets* como listas circulares (NEXT, PRIOR, OWNER) y un mini DML con currency explícita.
  El diseño de los *sets* lo reutilizan AC07 (sobre LMDB) y AC09 (en C): fíjalo en el paso 1.
- **El diagrama de Bachman** de `supply` en ASCII de 75 columnas.
- **Inserción y retención contra `ON DELETE`** (F05): la tabla de traducción en las dos direcciones,
  con la que no tiene equivalente.
- El DML de CODASYL se escribe en papel con su sintaxis como pseudocódigo declarado, y su equivalente
  ejecutable en el mini DML.

{{protocolo}}
```

## # AC04 — El Gran Debate

```markdown
Esta es la sesión de la **Fase AC04 — ⚔️ El Gran Debate**. Entregables: `ac04-el-gran-debate.md`, su
solucionario y el laboratorio L4 en `src/ac04-el-gran-debate/`.

{{marco del bloque}}

## Identidad

- Fase AC04 de AC09 · Bloque A.C. · **6 h** · **20 ejercicios** · Depende de AC02, AC03 y F07 ·
  Habilita AC05
- Herramientas: `radb` y Python (L4, sobre L2) · Plantilla 3. Longitud: 3.000–4.500 palabras.
- Ficha: propuesta de fases, §12, AC04.

## Puntos de cuidado

- **El debate con sus argumentos en las dos voces**: Bachman no estaba equivocado en 1973; la
  eficiencia era un argumento real. Tono de la guía §2.1: se discuten ideas, no personas.
- **L4 es la prueba del bloque**: la ÷ de F07 en `radb` y como programa navegacional en L2, con
  bloques contados; después se cambia la pregunta y se cuentan **las líneas que cambia cada
  solución**. Esa cuenta es la independencia de datos medida, y se publica tal cual salga.
- Las citas de Codd y Bachman se toman de los textos originales verificados en la sesión, o se
  parafrasean y se dice.

{{protocolo}}
```

## # AC05 — Los herederos

```markdown
Esta es la sesión de la **Fase AC05 — 🧬 Los herederos**. Entregables: `ac05-los-herederos.md`, su
solucionario y el laboratorio de ZODB en `src/ac05-los-herederos/`.

{{marco del bloque}}

## Identidad

- Fase AC05 de AC09 · Bloque A.C. · **6 h** · **22 ejercicios** · Depende de AC04 · Habilita AC06,
  AC07 y AC08
- Herramientas: ZODB en el `venv` · Plantilla 3. Longitud: 3.000–4.500 palabras.
- Ficha: propuesta de fases, §12, AC05.

## Puntos de cuidado

- **El laboratorio de ZODB** provoca un N+1 a propósito sobre un grafo de objetos de `supply`, y
  cuenta los accesos. Es el puente con el ORM que el lector usa.
- **Con la Ruta NoSQL Lite, solo referencias de concepto**: documental como jerárquico, grafos como
  red. Nada de rehacer sus minicursos.
- **SQL/PGQ, ISO GQL y las vistas de dualidad JSON–relacional**: qué motor implementa qué se
  verifica en documentación oficial con fecha, o se escribe en general.
- *What Goes Around Comes Around* (2005 y 2024) como cierre del argumento del bloque.

{{protocolo}}
```

## # AC06 — Caso de estudio: Git

```markdown
Esta es la sesión de la **Fase AC06 — 🔬 Caso de estudio: Git, la base navegacional que ya usas**.
Entregables: `ac06-caso-git.md`, su solucionario y el exportador en `src/ac06-caso-git/`.

{{marco del bloque}}

## Identidad

- Fase AC06 de AC09 · Bloque A.C. · **6 h** · **20 ejercicios** · Depende de AC05 y F10 · Habilita
  nada
- Herramientas: Git, Python y SQLite · Plantilla 4 (caso de estudio). Longitud: 3.000–4.500 palabras.
- Ficha: propuesta de fases, §12, AC06.

## Puntos de cuidado

- **El repositorio de práctica se crea en la sesión**, chico y determinista (commits con fechas y
  autores fijos), para que los hashes y las salidas de `git cat-file` sean reproducibles. Fija en el
  paso 1 cómo se crea.
- **La pregunta navegacional** (*"¿en qué commits cambió este archivo?"*) con los saltos contados a
  mano, y la misma pregunta en SQLite con `WITH RECURSIVE` sobre `commit`, `commit_parent` y
  `tree_entry`, con los resultados comparados.
- **El 🪞 de Git como base de grafos** se sostiene con el modelo de objetos, no con una analogía.
- Lo que se afirme del formato interno de Git (objetos sueltos, *packfiles*) se verifica en su
  documentación oficial.

{{protocolo}}
```

## # AC07 — Caso de estudio: LMDB

```markdown
Esta es la sesión de la **Fase AC07 — 🔬 Caso de estudio: LMDB, el motor sin modelo**.
Entregables: `ac07-caso-lmdb.md`, su solucionario y la capa de red sobre LMDB en
`src/ac07-caso-lmdb/`.

{{marco del bloque}}

## Identidad

- Fase AC07 de AC09 · Bloque A.C. · **6 h** · **22 ejercicios** · Depende de AC03, AC05 y F24 ·
  Habilita nada
- Herramientas: `lmdb` en el `venv`, SQLite · Plantilla 4. Longitud: 3.000–4.500 palabras.
- Ficha: propuesta de fases, §12, AC07.

## Puntos de cuidado

- **Reutiliza el diseño de *sets* de L2** (AC03): los *sets* de `supply` con pedidos como claves
  `dupsort`, y el mismo mini DML encima, para que el lector compare la misma capa sobre dos motores.
- **El contador de accesos** sobre LMDB se define en el paso 1 (LMDB no expone bloques leídos como
  L1): qué se cuenta y por qué es comparable, dicho como modelo.
- **El árbol B+ con copia en escritura** se conecta con F24 y F32 por número de definición.
- La afirmación de que OpenLDAP usa LMDB y Active Directory usa ESE se verifica en fuentes primarias
  en la sesión.

{{protocolo}}
```

## # AC08 — Caso de estudio: YottaDB

```markdown
Esta es la sesión de la **Fase AC08 — 🔬 Caso de estudio: YottaDB, el jerárquico que sigue en
producción**. Entregables: `ac08-caso-yottadb.md`, su solucionario, los scripts en
`src/ac08-caso-yottadb/` y el apéndice `aca-02-contenedores.md` (con su propio prompt, en
`prompts-de-apendice.md`).

{{marco del bloque}}

## Identidad

- Fase AC08 de AC09 · Bloque A.C. · **6 h** · **22 ejercicios** · Depende de AC02 y AC05 · Habilita
  nada
- Herramientas: YottaDB (contenedor de `aca-02` en macOS y Windows; nativo en Linux x86-64) y el
  paquete `yottadb` de Python · Plantilla 4. Longitud: 3.000–4.500 palabras.
- Ficha: propuesta de fases, §12, AC08.

## Puntos de cuidado

- **`school` como *globals***: fija en el paso 1 el diseño de subíndices
  (`^school(year, section, student)` u otro), y compáralo con el árbol de L3 (AC02).
- **`$ORDER` como DL/I con otra sintaxis**: la equivalencia operación por operación en la sección 📖.
- **La pregunta que el árbol no previó**, resuelta con un *global* inverso, se presenta como índice
  secundario hecho a mano, citando F23 por número; el costo de mantenerlo en cada escritura se cuenta.
- **El contexto real (VistA, otros sistemas clínicos)** se verifica en fuentes primarias, o se dice
  en general.
- Si P8 no confirmó la imagen de YottaDB y el paquete de Python dentro del contenedor, **para en el
  paso 1**: la fase entera depende de eso, y el caso de reserva (el `.dbf`) ocupa su lugar.

{{protocolo}}
```

## # AC09 — Pedidos en C

```markdown
Esta es la sesión de la **Fase AC09 — 🧷 Pedidos en C: el modelo de red a mano**. Entregables:
`ac09-pedidos-en-c.md`, su solucionario y el código en `src/ac09-pedidos-en-c/`.

{{marco del bloque}}

## Identidad

- Fase AC09 de AC09 · Bloque A.C. · **8 h** · **20 ejercicios** · Depende de AC03 · Cierra el bloque
- Herramientas: GCC (Linux y macOS) y Visual C++ (Windows) · Plantilla 3. Longitud: 3.000–4.500
  palabras.
- Ficha: propuesta de fases, §12, AC09.

## Puntos de cuidado

- **El código se entrega hecho**, generado con asistencia de IA como parte del contenido y revisado
  línea por línea en la sesión. El documento lo dice con esas palabras, y explica el código: no es una
  caja negra.
- **ANSI C, solo CLI, sin dependencias.** Fija en el paso 1 el estándar exacto (C89/C90 o C99) y los
  *flags* de GCC y de Visual C++ que lo imponen; van también a `aca-01`.
- **Dos etapas**: en memoria (listas multienlazadas: cliente → pedido → línea ← parte) y sobre un
  archivo de páginas con `fseek`, con *database keys* y *sets* circulares con el diseño de L2.
- **Compila y corre en las tres plataformas antes de publicarse**, sin advertencias con los *flags*
  fijados, y la salida literal de cada etapa va en el documento.
- **Abierto a ejercicios**: los 🟠 y 🔴 extienden el código (un *set* nuevo, borrado con retención
  `MANDATORY`, una ubicación `CALC`), con su solución como diff en el solucionario.
- **Cierra el bloque A.C.**: el resumen vuelve a la tesis de AC00.

{{protocolo}}
```
