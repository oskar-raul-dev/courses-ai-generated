# 📎 Propuesta de apéndices y alcance
## El motor de motores — diez apéndices del camino base y dos del bloque A.C.

> **Qué es este documento:** qué apéndices tiene el curso, qué entra en cada uno, cuántas horas de
> consulta representan, cuándo se escriben y —sobre todo— **qué queda explícitamente fuera**.
> **Precedencia:** por encima, [`alcance-del-proyecto.md`](alcance-del-proyecto.md) y
> [`guia-de-estilo-y-convenciones.md`](guia-de-estilo-y-convenciones.md); al lado,
> [`propuesta-fases-y-alcance.md`](propuesta-fases-y-alcance.md). Por debajo, las plantillas y
> [`prompts-de-apendice.md`](prompts-de-apendice.md), que se actualizan después y nunca al revés.
> **Fecha:** 2 de octubre de 2026, con las decisiones D1–D18 y A–E del alcance (§13) cerradas.
> **Revisada el 5 de octubre de 2026:** el apéndice `a10` (D19), agregado como §15 para no
> renumerar; los diagramas en Mermaid (D-12); las remisiones a otros cursos, en prosa y sin enlace
> (D-03).

---

## 1. 🧭 Qué es un apéndice en este curso

**Un apéndice es consulta rápida, no lección.** No se lee de corrido: se entra por el índice
buscando algo concreto —cómo se activa el `venv` en PowerShell, qué símbolo de `radb` corresponde a
⋈, cómo se copia un `.db` abierto sin corromperlo— y se sale. De ahí su forma, que es la misma de los
cursos hermanos: índice de salto rápido, secciones cortas que responden a una sola pregunta, ejemplo
mínimo ejecutable, una tabla de "cuándo usar qué" al final y **de 5 a 10 ejercicios de consulta**.

**Sus horas no cuentan** dentro de las ≈ 403 h del camino base ni de las ≈ 67 h del bloque A.C. Las
horas de esta propuesta son una estimación del tiempo de consulta, para que el lector sepa cuánto le
cuesta montar su entorno.

**Aquí solo se definen.** Este documento fija qué cubre cada apéndice, qué no, quién lo usa y en
qué momento se escribe. **Ninguno se redacta completo por adelantado**: cada uno se escribe en la
tanda del plan de producción que lo necesita, y los que dependen de la ejecución (versiones,
comandos, salidas) no pueden escribirse antes de que la tanda de verificación los haya corrido.

> 🧭 **La regla de oro de los apéndices de instalación: comandos y nada más.** `a01`, `a02`, `a03`,
> `a09`, `aca-01` y `aca-02` dan la receta y el comando que confirma que funcionó. Si una sección
> necesita más de dos párrafos para explicar qué hace un gestor de paquetes o un contenedor por
> dentro, ese contenido no es de este curso: va un enlace a la documentación oficial, o se nombra en
> prosa, sin enlace, el curso del repositorio que lo enseña (D-03).

> ⚠️ **Ninguna versión se escribe de memoria.** Las versiones salieron de la tanda de verificación
> (P8, 03/10/2026, `verificacion-de-laboratorio/hallazgos.md`) y viven en el apéndice
> correspondiente. Las fases apuntan allí y no repiten el número.

---

## 2. 📊 Los doce, de un vistazo

| # | Apéndice | Horas | Se escribe | Usado por |
|---|---|---|---|---|
| a01 | SQLite nativo y el archivo físico | 2 h | antes de F01 | todo el curso |
| a02 | Python, `venv` y Faker | 2 h | antes de F01 | a03, a04, a05 y las fases con datos generados |
| a03 | `radb` en tres plataformas | 2 h | antes de F01 | Bloque II en adelante |
| a04 | Las bases de ejemplo y su generador | 2 h | antes de F02; crece hasta F13 | todo el curso |
| a05 | Los verificadores y el mini motor | 3 h | con F15; crece hasta F29 | Bloques III a VI |
| a06 | La matemática mínima | 3 h | antes de F04 | Bloques II y III |
| a07 | Notación y glosario bilingüe | 2 h | esqueleto antes de F04; **vivo** | todo el curso |
| a08 | Mapa de bibliografía y recursos | 1 h | esqueleto antes de F00; **vivo** | todo el curso |
| a09 | 🔥 El curso en un contenedor (opcional) | 1 h | después de a01–a03 | quien no quiera instalar nada; F34 |
| a10 | Notaciones de diagramas | 2 h | antes de F02 | F02, F03, F13 y todo diagrama del curso |
| aca-01 | 🏛️ Herramientas nativas del bloque A.C. (opcional) | 1 h | con AC01 | bloque A.C. |
| aca-02 | 🏛️ Contenedores del bloque A.C. (opcional) | 1 h | con AC08 | AC08, y lo que no corra nativo |

### 2.1 Los nombres de archivo, que son canónicos

```text
a01-sqlite-nativo.md                  a06-la-matematica-minima.md
a02-python-venv-y-faker.md            a07-notacion-y-glosario.md
a03-radb.md                           a08-mapa-de-bibliografia.md
a04-las-bases-de-ejemplo.md           a09-el-curso-en-un-contenedor.md
a05-verificadores-y-mini-motor.md     a10-notaciones-de-diagramas.md
aca-01-herramientas-nativas.md        aca-02-contenedores.md
```

Son los de la guía de estilo (§5.2) y no se cambian. Dos dígitos siempre. Los dos del bloque A.C.
llevan el prefijo de track del repositorio, `aca-NN-`, para no mezclarse con los del camino base.

### 2.2 Tres familias de apéndice

- **De instalación** (a01, a02, a03, a09, aca-01, aca-02): recetas por plataforma, con el comando
  que verifica cada paso. Se escriben **después** de la tanda de verificación, porque todo lo que
  muestran se ejecutó en Windows, macOS y Linux.
- **De material del curso** (a04, a05): documentan código que vive en `src/`. **Son los únicos que
  dejan archivos en el repositorio** junto con a09 y aca-02, que dejan su `Dockerfile` o su
  `compose.yaml`. Crecen a medida que las fases agregan bases, verificadores o piezas del mini motor.
- **De referencia** (a06, a07, a08, a10): teoría de apoyo y documentos de consulta. **a07 y a08 son
  documentos vivos** (guía §14): cada fase que introduce un símbolo, un término o un recurso los
  alimenta en la misma sesión, y se cierran al final del curso.

### 2.3 El orden importa

**a01, a02 y a03 son el suelo del laboratorio** y se escriben antes de F01, en ese orden: Python va
antes que `radb` porque `radb` se instala con `pip` dentro del `venv`. **a04 va antes de F02**,
porque F02 ya modela `school`, y **a10 también**, porque F02 dibuja los primeros bocetos y F03 pasa
a la pata de gallo. **a08 abre su esqueleto antes de F00**, porque F00 ya cita libros, y
**a06 y a07 antes de F04**, la primera fase con notación formal. **a05 nace con F15**, el primer
verificador, y crece hasta F29.

---

## 3. 🪶 a01 — SQLite nativo y el archivo físico (2 h)

**Qué resuelve:** que el lector tenga `sqlite3` funcionando en su máquina en diez minutos, y que
sepa tratar un `.db` como lo que es: un archivo del disco que se puede copiar, mover y respaldar,
pero no de cualquier forma.

**Qué entra:**

- **Instalar la CLI `sqlite3`** en las tres plataformas, cada una con su gestor: `brew` en macOS;
  `winget`, Chocolatey o Scoop en Windows (los tres en una tabla, con cuál recomienda el curso y
  por qué); `apt`, `dnf` o `pacman` en Linux. Y la alternativa del binario oficial de sqlite.org
  para cuando el gestor trae una versión vieja.
- **Comprobar que la versión admite `STRICT`**, con el comando exacto y la salida esperada. Si el
  gestor de la plataforma trae una versión anterior, qué hacer.
- **Los comandos con punto que usa el curso** —`.open`, `.read`, `.schema`, `.tables`, `.mode`,
  `.headers`, `.quit`—, una línea cada uno.
- **La base es un archivo.** Dónde queda, qué extensión usa el curso, y cómo se copia o se mueve
  **sin corromperla**: con la base cerrada, o con `.backup` y `VACUUM INTO` cuando hay una conexión
  abierta. **Qué son los archivos `-wal` y `-shm`**, por qué no se copian sueltos ni se borran a
  mano, y qué pasa si se copia solo el `.db` en modo WAL.
- **Comprobar una copia** con `PRAGMA integrity_check` y la salida que indica que está sana.
- **Recrear las bases del curso** desde sus scripts, con un comando, apuntando a `a04`.

**Qué NO entra:** la teoría del respaldo (F35), el WAL como teoría de recuperación (F32), los modos
de journal y la concurrencia de SQLite, las extensiones y todo lo que enseña el curso `05-sqlite`.
Se nombra en una línea y se remite allí, en prosa y sin enlace (D-03).

**Ejercicios: 8**, de consulta: instalar y verificar la versión, crear una tabla `STRICT` y
provocar el error de tipo, respaldar con `.backup` y con `VACUUM INTO`, comprobar la copia, y un
caso de copia hecha mal (solo el `.db` con el `-wal` pendiente) para reconocer el síntoma.

**Verificado en P8 (H3, H6, H7, H10, H11):** Debian 13, Ubuntu 24.04 y 26.04, Fedora 44 y Arch traen
SQLite entre 3.45.1 y 3.53.4, todas con `STRICT` (mínimo: 3.37.0); el paquete se llama `sqlite3` en
`apt` y `sqlite` en `dnf`, `pacman`, Homebrew, Chocolatey (también `sqlite.shell`) y Scoop, y
`SQLite.SQLite` en winget; la copia hecha con el `-wal` pendiente **pasa `integrity_check`** y pierde
en silencio lo que vivía en el `-wal`. **Pendiente de Oskar:** las recetas de macOS y Windows; ojo con
que `sqlite` de Homebrew es *keg-only* y no reemplaza al `sqlite3` de macOS en el `PATH`.

---

## 4. 🐍 a02 — Python, `venv` y Faker (2 h)

**Qué resuelve:** un entorno de Python aislado y reproducible donde viven `radb`, Faker, los
verificadores y el mini motor, igual en las tres plataformas.

**Qué entra:**

- **Instalar Python 3** en las tres plataformas: el instalador de python.org, `brew`, `winget` y el
  gestor de la distribución; el lanzador `py` de Windows y la casilla del `PATH` que nadie marca.
  La versión mínima que exige el curso es la **3.10** (P8, H9).
- **Crear, activar y desactivar un `venv`**, en una tabla por shell: bash y zsh, PowerShell (con la
  política de ejecución que bloquea el script de activación y cómo se levanta solo para el usuario)
  y `cmd`. Cómo se reconoce que está activo.
- **`pip` y un `requirements.txt` con versiones fijadas**, en la raíz de `src/`, y el comando que
  reproduce el entorno exacto.
- **Faker para datos de prueba:** *locales* en español (`es_MX`, `es_CO`, `es_CL`, `es_AR`, `es_ES`
  como contraste), `Faker.seed()` para que todos generen exactamente los mismos datos, y
  **proveedores propios** para lo que Faker no trae: asignaturas, grados, escalas de notas, números
  de parte.
- ⚠️ **La advertencia que importa:** la misma semilla puede producir datos distintos con otra
  versión de Faker. Por eso la versión va fijada en `requirements.txt`, y el apéndice lo dice con
  esas palabras en la sección de la semilla.
- **Referencias oficiales**: la documentación de Python, de `venv`, de `pip` y de Faker.

**Qué NO entra:** enseñar Python; `uv`, `conda`, `pipx`, `poetry` y cualquier otro gestor (el curso
usa `venv` porque viene con Python, y lo dice una vez); el diseño de las bases que se generan, que
está en `a04`.

**Ejercicios: 8**, de consulta: crear el `venv` en tu shell, provocar y resolver el bloqueo de
PowerShell, reproducir el entorno desde `requirements.txt`, generar diez alumnos con semilla fija y
comprobar que el resultado coincide con el del apéndice, escribir un proveedor propio mínimo.

**Verificado en P8 (H9, H10):** Python 3.10 como mínimo (por Faker 40.40.0; corrido en 3.10.22); la
salida de Faker con semilla y versión fijadas es **idéntica** en arm64 y x86-64, en Debian, Fedora y
Arch, y con Python 3.10 y 3.14; con Faker 30.0.0 cambia. En Debian y Ubuntu, `venv` exige el paquete
`python3-venv`, con un mensaje literal registrado. **Pendiente de Oskar:** el mensaje de la política de
ejecución de PowerShell y las recetas de Windows y macOS.

---

## 5. 🧮 a03 — `radb` en tres plataformas (2 h)

**Qué resuelve:** que el lector pueda ejecutar álgebra relacional sobre los mismos `.db` que usa en
SQLite, y que sepa qué hacer con los operadores que `radb` no tiene.

**Qué entra:**

- **Instalarlo con `pip` dentro del `venv` de a02** y comprobar que responde.
- **Conectarlo a un `.db`** de las bases del curso, y su archivo de configuración si lo necesita.
- **Correr consultas** de forma interactiva y desde un archivo, que es como el curso guarda las
  expresiones de los ejemplos y de los ejercicios.
- **La sintaxis completa**, en una tabla de dos columnas: cada operador de `radb` frente a la
  notación Unicode del curso. La tabla completa de símbolos vive en `a07`; aquí está la parte que
  `radb` implementa.
- **Ver el SQL que genera**, que conecta con F10.
- **Lo que no tiene** —÷, ⟕ ⟖ ⟗, ⋉ y ▷— y la receta para escribir cada uno con los primitivos, con un
  ejemplo verificado por operador. La teoría de por qué funcionan está en F07 y F08; aquí va solo la
  receta.
- **Su comportamiento con tablas `STRICT`** y con `NULL`, y los mensajes de error más comunes con
  su texto literal.

**Qué NO entra:** la teoría de cada operador (F06–F08), la semántica de multiconjuntos (F11) y
RelaX, que solo aparece como mención en la bibliografía.

**Ejercicios: 8**, de consulta: instalar y conectar, una selección y una proyección, ver el SQL
generado, escribir una división con primitivos y comprobar el resultado, y provocar y reconocer un
error de sintaxis típico.

**Verificado en P8 (H2–H5):** `radb` 3.0.5 **funciona sobre tablas `STRICT`** (una sola variante de
las bases); exige Python 3.5 según su metadato, y el curso pide 3.10 por Faker; se invoca con
`radb base.db -i archivo.ra` y se configura con `~/.radb.ini` (`db.database = …`); **SQLAlchemy va
fijado en 2.0.54**, porque con la 2.1 tipa `REAL` como `unknown`; la sintaxis, los mensajes de error,
`NULL` y el SQL generado (`-d`) están registrados. Se instaló igual en cinco distribuciones Linux;
**Windows y macOS, pendientes de Oskar**.

---

## 6. 🏫 a04 — Las bases de ejemplo y su generador (2 h)

**Qué resuelve:** que `school` y `supply` existan, sean las mismas para todos los lectores y se
puedan recrear desde cero con un comando.

**Qué entra:**

- **`school`** y **`supply` con pedidos**, cada una con su diagrama en pata de gallo (`erDiagram`,
  con remisión a `a10` para leerlo), su esquema relacional y la lista fija de relaciones y atributos del alcance (§8). Este apéndice es **la fuente
  de los nombres**: si una fase necesita una relación o un atributo nuevo, se agrega aquí.
- **El DDL `STRICT`** de cada base, con sus restricciones.
- **Los datos chicos escritos a mano**, los que se siguen en papel en los ejemplos, con su tamaño
  exacto.
- **El generador con Faker** para los volúmenes grandes, con su semilla, su versión de Faker fijada
  y el tamaño de cada volumen.
- **Recrear cada base desde cero**, chica o generada, en un comando.
- **Relaciones abstractas y planes**: la convención de `R(A, B, C, …)` y de los ítems `X`, `Y`, con
  remisión a `a07` para la notación.

El código vive en `src/a04-las-bases-de-ejemplo/`: DDL, datos chicos y generador.

**Qué NO entra:** el diseño de las bases, que es materia de F02, F13 y del Bloque III. Aquí se dan
hechas, y las fases que las diseñan llegan al mismo esquema por su cuenta.

**Ejercicios: 6**, de consulta: recrear las dos bases, contar tuplas por relación y comparar con el
apéndice, regenerar con otra semilla y ver qué cambia, agregar una relación siguiendo las
convenciones.

**Verificado en P8 (H3, H9):** Faker con semilla y versión fijadas da los mismos datos en las
arquitecturas y distribuciones probadas, y un `.db` `STRICT` funciona con `radb`. Dos reglas para el
generador: **fechas en `TEXT` ISO 8601**, porque `STRICT` no admite `DATE`, y **nada relativo a hoy**
(`date_of_birth`, `date_this_year`), porque cambia con la fecha aunque la semilla sea la misma; se usa
`date_between` con fechas fijas.

---

## 7. 🔧 a05 — Los verificadores y el mini motor (3 h)

**Qué resuelve:** que el lector pueda comprobar sus propias soluciones con las mismas herramientas
con que el autor comprobó las del solucionario.

**Qué entra:**

- **Cada verificador**, con una sección propia: qué entrada recibe, qué devuelve, un ejemplo con su
  salida literal y qué fase lo usa. La lista crece con el curso: clausura de atributos, clausura de
  un conjunto de DF, recubrimiento mínimo, claves candidatas (F15); forma normal (F16); prueba NJB y
  *chase* (F17); síntesis a 3FN y descomposición a FNBC (F18); inserción y borrado en B+ (F24);
  serializabilidad por conflicto y grafo de precedencia (F29).
- **El mini motor de F26**: operadores como iteradores (modelo Volcano), el contador de bloques
  leídos, y cómo se arma un plan con ellos. Qué implementa cada operador, sin repetir el algoritmo,
  que está en F26.
- **Cómo usarlos para revisar una solución propia**, que es la sección más consultada.

El código vive en `src/a05-verificadores-y-mini-motor/`, en Python con biblioteca estándar.

**Qué NO entra:** la teoría de los algoritmos, que está en sus fases. El apéndice dice cómo se usan,
no por qué funcionan.

**Ejercicios: 8**, de consulta: correr cada verificador sobre un ejemplo de su fase, encontrar con
él el error de una solución mal hecha que el apéndice entrega, armar un plan de dos operadores en el
mini motor y leer su contador de bloques.

**Verificaciones pendientes:** ninguna de plataforma más allá de las de a02; cada verificador se
prueba en la tanda de la fase que lo introduce.

---

## 8. ∑ a06 — La matemática mínima (3 h)

**Qué resuelve:** que un lector que no tocó matemática formal desde la universidad pueda leer las
definiciones y las demostraciones de los bloques II y III sin trabarse en la notación.

**Qué entra:**

- **Conjuntos**: pertenencia, inclusión, operaciones, producto cartesiano, conjunto potencia; la
  diferencia entre conjunto y multiconjunto, que el curso usa todo el tiempo.
- **Relaciones y funciones** en el sentido matemático, y por qué una relación de la base de datos es
  un subconjunto de un producto cartesiano.
- **Lógica de predicados**: conectivos, cuantificadores ∀ y ∃, sus negaciones y la equivalencia
  ¬∀ ⇔ ∃¬ que F09 y F10 usan para escribir la división.
- **Cómo se lee y se escribe una demostración**: directa, por contradicción, por contraejemplo y por
  inducción, cada una con un ejemplo corto tomado del curso.
- **Logaritmos y potencias** para la altura de un árbol y el número de pasadas de un ordenamiento
  externo.

**Qué NO entra:** todo lo que el curso no use. Si un tema no aparece en ninguna fase, no va aquí.
Sin teoría de órdenes, sin álgebra abstracta, sin combinatoria más allá de lo que piden F21–F26.

**Ejercicios: 10**, de consulta y en papel: operaciones de conjuntos, negar un cuantificador, dar un
contraejemplo, una inducción corta, calcular la altura de un árbol dado su orden y su número de
claves.

**Verificaciones pendientes:** ninguna de plataforma.

---

## 9. 📖 a07 — Notación y glosario bilingüe (2 h · vivo)

**Qué resuelve:** que el lector encuentre en un solo lugar cómo se escribe cada símbolo, cómo lo
escribe cada libro y cómo se dice cada término en español y en inglés.

**Qué entra:**

- **Cada símbolo Unicode del curso**, cómo se escribe en el teclado de cada sistema (o de dónde se
  copia) y su equivalente en `radb` cuando lo tiene.
- **La tabla de notaciones** de Navathe, Date y los demás textos cuando difieren: cómo escribe cada
  uno la proyección, el join, las dependencias, los planes.
- **El glosario español ↔ inglés en las dos direcciones**, con la traducción que usan las ediciones
  en español de los libros y la que elige el curso cuando difieren. **Publica para el lector** lo que
  fija `prompts/diccionario-de-terminos.md` (guía §3), y crece con él.
- **La convención de las relaciones abstractas y de los planes de transacciones.**

**Es un documento vivo:** cada fase que introduce un símbolo o un término lo agrega en la misma
sesión. Se abre con su esqueleto antes de F04 y se cierra al final del curso.

**Qué NO entra:** definiciones largas. Cada entrada del glosario remite a la fase y al número de
definición donde se define.

**Ejercicios: 6**, de consulta: traducir una expresión de la notación de un libro a la del curso,
encontrar el término inglés de un concepto y al revés, escribir en `radb` una expresión dada en
Unicode.

**No verificable en P9** (`inventario-de-fuentes.md` §4): la terminología de las traducciones solo
estaba en copias no autorizadas. `a07` fija la del curso y deja la columna de las traducciones con
"sin verificar".

---

## 10. 📚 a08 — Mapa de bibliografía y recursos (1 h · vivo)

**Qué resuelve:** que cada recurso que cita el curso esté verificado una sola vez, con fecha, y que
las fases lo tomen de aquí.

**Qué entra:**

- **La tabla libro × fase** para los cinco textos del camino base (alcance §9), con edición y
  capítulo o sección, y la traducción al español cuando existe.
- **Los cursos por bloque**: Udemy y Coursera, con plataforma, idioma, si son de pago 💲 y la fecha
  de verificación; los cursos completos de YouTube, con la clase concreta de cada fase.
- **Los papers fundacionales por fase**, con su referencia completa y dónde se consiguen.
- **La bibliografía propia del bloque A.C.**, en una sección aparte que no cuenta contra el tope de
  cinco textos.

**Es un documento vivo:** abre su esqueleto antes de F00 y cada fase agrega lo que verificó.

**Qué NO entra:** reseñas largas. Cada recurso lleva una línea de por qué vale la pena.

**Ejercicios: 5**, de consulta: encontrar la lectura base de una fase, encontrar un curso gratuito
en español de un bloque, ubicar un paper y su fecha.

**Verificado en P9** (`inventario-de-fuentes.md`, 03/10/2026): ediciones, traducciones, capítulos
de los cinco textos, cursos de CMU, Berkeley, Stanford y Coursera, y veinte papers por DOI. **Sin
verificar:** Udemy (403 a toda consulta automática), el precio de Coursera y lo que lista el §9 del
inventario. El esqueleto de `a08` vuelve a comprobar cada URL el día que la publica.

---

## 11. 🐳 a09 — 🔥 El curso en un contenedor (1 h · opcional)

**Qué resuelve:** que quien no quiera instalar nada en su máquina tenga todo el camino base en una
imagen, y que quien quiera practicar `GRANT` y `REVOKE` de verdad tenga un servidor donde hacerlo.

**Qué entra:**

- **Una imagen con SQLite, Python, `radb` y Faker**, con las bases del curso montadas como volumen
  para que los `.db` sigan siendo archivos del disco del lector.
- **Los comandos con Docker y su equivalente con Podman**, al lado; cuando son idénticos, se dice y
  no se duplica.
- **Un servicio extra, también opcional: PostgreSQL** para los ejercicios 🔥 de F34 (decisión B del
  alcance), con un usuario administrador y la receta para crear los usuarios del ejercicio.
- **El `Dockerfile` o el `compose.yaml`** quedan en `src/a09-el-curso-en-un-contenedor/`.

**Qué NO entra:** enseñar Docker (si hace falta el mecanismo, se remite a la documentación oficial, o
se nombra en prosa el curso del repositorio que lo enseña, sin enlace);
las herramientas del bloque A.C., que tienen su propio apéndice (`aca-02`); administrar PostgreSQL,
que es materia de `02-postgresql`. **El curso cita este apéndice como alternativa y nunca lo exige.**

**Ejercicios: 5**, de consulta: levantar el contenedor, abrir una base del curso desde dentro,
comprobar que un cambio queda en el `.db` del disco, levantar el PostgreSQL y conectarse.

**Verificado en P8 (H1):** la imagen `python:3.14.8-slim-trixie` con SQLite 3.46.1 sirve de base (es la
de `mdm-lab`), y el volumen montado funciona en macOS arm64. **Pendiente para T12**, al crear `mdm-pg`:
el PostgreSQL extra y su consumo de memoria, y el volumen en Windows y Linux.

---

## 12. 🏛️ aca-01 — Herramientas nativas del bloque A.C. (1 h · opcional)

**Qué resuelve:** instalar en las tres plataformas todo lo que el bloque A.C. usa sin contenedor.

**Qué entra:**

- **Git**, que el lector ya tiene, y los comandos de bajo nivel que usa AC06 (`git cat-file`,
  `git ls-tree`), con la comprobación de que están.
- **`lmdb` y ZODB** en el `venv` de a02, para AC07 y AC05.
- **GnuCOBOL y Harbour** para AC01, con lo que trae cada gestor de paquetes y la alternativa cuando
  no lo trae.
- **GCC o Visual C++** para AC09: cómo se instala cada uno y **cómo se compila con cada uno** el
  código de `src/ac09-pedidos-en-c/`, con los *flags* de ANSI C.
- **Una tabla de qué corre nativo en cada sistema** y qué queda para `aca-02`.

**Qué NO entra:** la teoría de los modelos (fases AC00–AC05); enseñar C, COBOL o xBase; todo lo
que necesite contenedor.

**Ejercicios: 5**, de consulta: comprobar cada herramienta, compilar AC09 con tu compilador, abrir
una base LMDB vacía desde Python.

**Verificado en P8 (H12):** `lmdb` 3.0.0 **trae LMDB 0.9.36 incluido**; GnuCOBOL 3.2 tiene paquete en
Debian, Fedora, Homebrew y Chocolatey, **no en Scoop ni en winget**; **Harbour no tiene paquete** en
Debian ni en Fedora, y en Homebrew está en la 3.0.0 y marcado obsoleto: se compila la 3.2.0 desde el
fuente (o el binario de GitHub en Windows); en GCC, `-std=c89 -pedantic -Wall -Wextra -Werror`.
**Pendiente de Oskar:** los *flags* de Visual C++, que no tiene modo C89.

---

## 13. 🏛️ aca-02 — Contenedores del bloque A.C. (1 h · opcional)

**Qué resuelve:** que AC08 corra en macOS y en Windows, donde YottaDB no tiene versión nativa, y que
cualquier otra herramienta del bloque sin versión nativa tenga dónde correr.

**Qué entra:**

- **YottaDB en contenedor**, con la imagen oficial `yottadb/yottadb` (P8, H12), las bases de
  `school` montadas como volumen y el paquete `yottadb` de Python conectado desde dentro.
- **Los comandos con Docker y su equivalente con Podman.**
- **Cualquier otra herramienta del bloque sin versión nativa** en alguna plataforma. P8 no encontró
  ninguna más: Harbour no tiene paquete en Debian ni en Fedora, pero se compila desde el fuente, y eso
  es de `aca-01`.
- **El `compose.yaml`** queda en `src/aca-02-contenedores/`.

**Qué NO entra:** enseñar Docker (como en a09, documentación oficial o mención en prosa, sin enlace);
administrar YottaDB.
**Es independiente de a09**: el contenedor del camino base no carga con las herramientas del bloque
A.C., y viceversa.

**Ejercicios: 5**, de consulta: levantar YottaDB, escribir y leer un *global* desde la consola,
conectarse desde Python, comprobar que los datos sobreviven a un reinicio del contenedor.

**Verificado en P8 (H12):** la imagen oficial `yottadb/yottadb:r2.06` es multiarquitectura y **corre
nativa en macOS arm64**; el paquete `yottadb` 2.0.1 de Python se compila desde el fuente dentro del
contenedor (con `gcc`, `python3-dev`, `python3-venv` y `libffi-dev`) y lee los *globals*. AC08 no
necesita el caso de reserva.

---

## 14. 📌 Pendientes de este documento

- **Las versiones** —SQLite, Python, `radb`, SQLAlchemy, Faker, `lmdb`, ZODB, YottaDB, GnuCOBOL,
  Harbour, GCC y las imágenes— quedaron fijadas en P8 (`verificacion-de-laboratorio/hallazgos.md`) y
  pasan a su apéndice. **Pendientes de Oskar** (plan §2.3): las recetas de macOS y Windows, el
  mensaje de PowerShell y los *flags* de Visual C++. **Pendiente de T12**: el PostgreSQL de `a09`.
- **`radb` con `STRICT`**: funciona (H3); una sola variante de las bases.
- **La terminología de las ediciones en español** que fija a07 no se pudo verificar; el inventario de
  a08 sale de `inventario-de-fuentes.md` (P9).
- **Los cuatro apéndices que dejan archivos** (a04, a05, a09 y aca-02) tienen su carpeta en `src/`
  con el mismo nombre que el apéndice. Para cuando Oskar commitee, se propone que lleven tag propio
  en el espacio `apendice-aNN-<slug>` (y `apendice-aca-NN-<slug>`); los demás no llevan tag.
- **Las horas** son estimaciones de consulta y se recalibran al escribir cada apéndice.

---

## 15. 🧭 a10 — Notaciones de diagramas (2 h)

Agregado el 05/10/2026 (D19). Va al final del documento para no renumerar §14, que citan el plan y
los prompts.

**Qué resuelve:** que el lector pueda leer y dibujar los diagramas que va a encontrar en el oficio
—y los de este curso— sin tener que aprender Mermaid por separado. Cada notación trae su código
Mermaid listo para copiar, así que el apéndice funciona como minitutorial **sin ser un tutorial de
Mermaid**: enseña notaciones, y Mermaid es la forma en que se escriben.

**Qué entra:**

- **El boceto con óvalos** de F00–F02: entidad, relación, atributo (clave, compuesto, multivaluado,
  derivado), entidad débil y relación identificadora, cardinalidad y min-max en las aristas, con la
  convención de la guía §3.2.
- **La pata de gallo**, la notación del curso desde F03: los cuatro extremos (cero o uno, uno, cero o
  muchos, uno o muchos), relación identificadora y no identificadora, atributos con tipo y `PK`, `FK`,
  `UK`, la entidad débil, y **lo que no dibuja** —especialización, categorías, atributos multivaluados
  y relaciones n-arias— con la forma en que el curso lo resuelve (subtipo con etiqueta, relación
  asociativa).
- **El diagrama de clases de dominio en UML**: clases con atributos, asociaciones con multiplicidad,
  generalización con `{disjoint, complete}`, y por qué no se dibujan métodos en un modelo de datos.
- **Chen y min-max como traducción**: cómo leer los diagramas de Navathe y de los demás libros, que
  no se dibujan en Mermaid tal cual, con la tabla de equivalencias entre las cuatro notaciones.
- **Los esquemas relacionales** en pata de gallo, como los dibuja F13.
- **Los otros diagramas del curso**, una sección corta por tipo: árboles (B+, de consulta,
  jerárquicos), grafos (de precedencia, de autorización, de Bachman), estados y secuencias.
- **Una tabla de "qué notación para qué"** al final.

**Qué NO entra:** la teoría del modelado (F02, F03, F13), que el apéndice usa y no explica; la
sintaxis completa de Mermaid, ni su instalación: solo lo que el curso dibuja, y la mención de que
GitHub y muchos editores lo dibujan solos.

**Ejercicios: 8**, de consulta: traducir un fragmento de `school` del boceto a la pata de gallo y al
diagrama de clases; leer un diagrama de Chen de un libro y escribirlo en pata de gallo; encontrar el
error en un `erDiagram` con la cardinalidad al revés; dibujar una especialización con su etiqueta;
dibujar un árbol de consulta y un grafo de precedencia.

**Verificado (H13, 05/10/2026):** la convención entera dibuja con `mmdc` 12.0.0 (Mermaid 12.1.0); la
forma `ellipse` no existe y el óvalo se dibuja como estadio. **Sin verificar:** que GitHub dibuje
igual, y el `<u>` de la clave; se comprueba al publicar F02.

**Lo usan:** F02, F03 y F13, y toda fase con un diagrama. **Depende de:** la guía §3.2.
**Riesgo:** convertirse en un tutorial de Mermaid. Cada sección empieza por la notación y su
significado; el código viene después, como la forma de escribirla.

