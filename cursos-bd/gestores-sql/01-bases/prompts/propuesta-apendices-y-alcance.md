# 📎 Propuesta de apéndices y alcance
## El motor de motores — nueve apéndices del camino base y dos del bloque A.C.

> **Qué es este documento:** qué apéndices tiene el curso, qué entra en cada uno, cuántas horas de
> consulta representan, cuándo se escriben y —sobre todo— **qué queda explícitamente fuera**.
> **Precedencia:** por encima, [`alcance-del-proyecto.md`](alcance-del-proyecto.md) y
> [`guia-de-estilo-y-convenciones.md`](guia-de-estilo-y-convenciones.md); al lado,
> [`propuesta-fases-y-alcance.md`](propuesta-fases-y-alcance.md). Por debajo, las plantillas y
> [`prompts-de-apendice.md`](prompts-de-apendice.md), que se actualizan después y nunca al revés.
> **Fecha:** 2 de octubre de 2026, con las decisiones D1–D18 y A–E del alcance (§13) cerradas.

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
> dentro, ese contenido no es de este curso: va un enlace a la documentación oficial o a
> `docker-container-legacy/`.

> ⚠️ **Ninguna versión se escribe de memoria.** Donde esta propuesta dice "se fija en P8", el número
> sale de la tanda de verificación, con fecha, y vive en el apéndice correspondiente. Las fases
> apuntan allí y no repiten el número.

---

## 2. 📊 Los once, de un vistazo

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
| aca-01 | 🏛️ Herramientas nativas del bloque A.C. (opcional) | 1 h | con AC01 | bloque A.C. |
| aca-02 | 🏛️ Contenedores del bloque A.C. (opcional) | 1 h | con AC08 | AC08, y lo que no corra nativo |

### 2.1 Los nombres de archivo, que son canónicos

```text
a01-sqlite-nativo.md                  a06-la-matematica-minima.md
a02-python-venv-y-faker.md            a07-notacion-y-glosario.md
a03-radb.md                           a08-mapa-de-bibliografia.md
a04-las-bases-de-ejemplo.md           a09-el-curso-en-un-contenedor.md
a05-verificadores-y-mini-motor.md
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
- **De referencia** (a06, a07, a08): teoría de apoyo y documentos de consulta. **a07 y a08 son
  documentos vivos** (guía §14): cada fase que introduce un símbolo, un término o un recurso los
  alimenta en la misma sesión, y se cierran al final del curso.

### 2.3 El orden importa

**a01, a02 y a03 son el suelo del laboratorio** y se escriben antes de F01, en ese orden: Python va
antes que `radb` porque `radb` se instala con `pip` dentro del `venv`. **a04 va antes de F02**,
porque F02 ya modela `school`. **a08 abre su esqueleto antes de F00**, porque F00 ya cita libros, y
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
Se nombra en una línea y se remite allí, en prosa mientras ese curso no exista.

**Ejercicios: 8**, de consulta: instalar y verificar la versión, crear una tabla `STRICT` y
provocar el error de tipo, respaldar con `.backup` y con `VACUUM INTO`, comprobar la copia, y un
caso de copia hecha mal (solo el `.db` con el `-wal` pendiente) para reconocer el síntoma.

**Verificaciones pendientes (P8):** la versión que trae cada gestor en cada plataforma y si admite
`STRICT`; que `winget`, Chocolatey y Scoop tengan paquete de la CLI y cómo se llama; el
comportamiento literal de una copia hecha con el `-wal` pendiente.

---

## 4. 🐍 a02 — Python, `venv` y Faker (2 h)

**Qué resuelve:** un entorno de Python aislado y reproducible donde viven `radb`, Faker, los
verificadores y el mini motor, igual en las tres plataformas.

**Qué entra:**

- **Instalar Python 3** en las tres plataformas: el instalador de python.org, `brew`, `winget` y el
  gestor de la distribución; el lanzador `py` de Windows y la casilla del `PATH` que nadie marca.
  La versión mínima que exige el curso se fija en P8.
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

**Verificaciones pendientes (P8):** la versión mínima de Python que necesitan `radb` y Faker juntos;
el mensaje literal de la política de ejecución de PowerShell; que la salida de Faker con la semilla
y la versión fijadas sea idéntica en las tres plataformas.

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

**Verificaciones pendientes (P8):** que `radb` funcione sobre tablas `STRICT` (si no, se decide en
esa tanda si las bases se crean en dos variantes, guía §17); la versión de Python que exige en la
práctica; la sintaxis exacta de invocación y de configuración; que se instale igual en Windows,
macOS y Linux.

---

## 6. 🏫 a04 — Las bases de ejemplo y su generador (2 h)

**Qué resuelve:** que `school` y `supply` existan, sean las mismas para todos los lectores y se
puedan recrear desde cero con un comando.

**Qué entra:**

- **`school`** y **`supply` con pedidos**, cada una con su diagrama ER en ASCII, su esquema
  relacional y la lista fija de relaciones y atributos del alcance (§8). Este apéndice es **la fuente
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

**Verificaciones pendientes (P8):** que el generador produzca los mismos datos en las tres
plataformas con la versión fijada de Faker; que los `.db` resultantes funcionen con `radb`.

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
  en español de los libros y la que elige el curso cuando difieren. Es la fuente que fija el
  vocabulario (guía §3).
- **La convención de las relaciones abstractas y de los planes de transacciones.**

**Es un documento vivo:** cada fase que introduce un símbolo o un término lo agrega en la misma
sesión. Se abre con su esqueleto antes de F04 y se cierra al final del curso.

**Qué NO entra:** definiciones largas. Cada entrada del glosario remite a la fase y al número de
definición donde se define.

**Ejercicios: 6**, de consulta: traducir una expresión de la notación de un libro a la del curso,
encontrar el término inglés de un concepto y al revés, escribir en `radb` una expresión dada en
Unicode.

**Verificaciones pendientes (P9):** la terminología de las ediciones en español de los libros.

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

**Verificaciones pendientes (P9):** todo. Ediciones vigentes, capítulos, traducciones, URLs con su
código de estado, si cada curso sigue abierto y si es de pago.

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

**Qué NO entra:** enseñar Docker (si hace falta el mecanismo, se enlaza `docker-container-legacy/`);
las herramientas del bloque A.C., que tienen su propio apéndice (`aca-02`); administrar PostgreSQL,
que es materia de `02-postgresql`. **El curso cita este apéndice como alternativa y nunca lo exige.**

**Ejercicios: 5**, de consulta: levantar el contenedor, abrir una base del curso desde dentro,
comprobar que un cambio queda en el `.db` del disco, levantar el PostgreSQL y conectarse.

**Verificaciones pendientes (P8):** las imágenes base y sus versiones; que el volumen montado
funcione igual en las tres plataformas; el consumo de memoria del PostgreSQL extra.

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

**Verificaciones pendientes (P8):** que el paquete `lmdb` traiga LMDB incluido y no exija instalarlo
aparte; que GnuCOBOL y Harbour tengan paquete en los tres sistemas; los *flags* exactos de ANSI C en
GCC y en Visual C++.

---

## 13. 🏛️ aca-02 — Contenedores del bloque A.C. (1 h · opcional)

**Qué resuelve:** que AC08 corra en macOS y en Windows, donde YottaDB no tiene versión nativa, y que
cualquier otra herramienta del bloque sin versión nativa tenga dónde correr.

**Qué entra:**

- **YottaDB en contenedor**, con la imagen oficial si P8 la confirma, las bases de `school` montadas
  como volumen y el paquete `yottadb` de Python conectado desde dentro.
- **Los comandos con Docker y su equivalente con Podman.**
- **Cualquier otra herramienta del bloque** que P8 encuentre sin versión nativa en alguna
  plataforma.
- **El `compose.yaml`** queda en `src/aca-02-contenedores/`.

**Qué NO entra:** enseñar Docker, que se enlaza a `docker-container-legacy/`; administrar YottaDB.
**Es independiente de a09**: el contenedor del camino base no carga con las herramientas del bloque
A.C., y viceversa.

**Ejercicios: 5**, de consulta: levantar YottaDB, escribir y leer un *global* desde la consola,
conectarse desde Python, comprobar que los datos sobreviven a un reinicio del contenedor.

**Verificaciones pendientes (P8):** que exista una imagen oficial de YottaDB y su arquitectura (en
particular, si corre en macOS arm64 sin emulación); que el paquete `yottadb` de Python funcione
dentro del contenedor (sus wheels publicados son solo para Linux x86-64).

---

## 14. 📌 Pendientes de este documento

- **Todas las versiones** —SQLite, Python, `radb`, Faker, `lmdb`, ZODB, YottaDB, GnuCOBOL, Harbour,
  los compiladores y las imágenes de contenedor— se fijan en P8 y viven en su apéndice.
- **`radb` con `STRICT`**: si no funciona, afecta a a01, a03 y a04 a la vez, y se decide en P8 (guía
  §17).
- **La terminología de las ediciones en español** que fija a07, y el inventario completo de a08, se
  resuelven en P9.
- **Los cuatro apéndices que dejan archivos** (a04, a05, a09 y aca-02) tienen su carpeta en `src/`
  con el mismo nombre que el apéndice. Para cuando Oskar commitee, se propone que lleven tag propio
  en el espacio `apendice-aNN-<slug>` (y `apendice-aca-NN-<slug>`); los demás no llevan tag.
- **Las horas** son estimaciones de consulta y se recalibran al escribir cada apéndice.
