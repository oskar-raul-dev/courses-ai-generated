# 📎 Prompts iniciales por apéndice
## El motor de motores — 11 sesiones, 11 entregables

Cada sección es el prompt completo de un apéndice, listo para pegar en la sesión que lo redacta.
Los valores salen de [`propuesta-apendices-y-alcance.md`](propuesta-apendices-y-alcance.md); si
cambian allí, se cambian aquí después y **nunca al revés**.

**Una sesión, un archivo** (más su código en `src/`, en los que lo tienen).

> ⚠️ **El orden importa.** `a01`, `a02` y `a03` son el suelo del laboratorio y se escriben **antes
> de F01**, en ese orden, y **después de la tanda de verificación (P8)**: todo lo que muestran se
> ejecutó en contenedor (Linux) o lo verificó Oskar (macOS y Windows); lo que no, se declara. `a08` abre su esqueleto **antes de F00**; `a04` va antes de F02;
> `a06` y el esqueleto de `a07` antes de F04; `a05` nace con F15. `a07` y `a08` son vivos y **se
> cierran al final del curso**. `a09` va después de `a01`–`a03`; `aca-01` con AC01 y `aca-02` con
> AC08.

---

## 🧱 El marco común a todos los apéndices

```markdown
## Marco (no lo repitas, aplícalo)

Fuentes de verdad, en orden: (1) `prompts/alcance-del-proyecto.md`,
(2) `prompts/guia-de-estilo-y-convenciones.md`, (3) `prompts/propuesta-fases-y-alcance.md`,
(4) `prompts/propuesta-apendices-y-alcance.md`, (5) `prompts/plantillas-de-capitulo.md`
(Plantilla 6, la de apéndice, que es laxa), (6) lo verificado en
`prompts/verificacion-de-laboratorio/hallazgos.md` (P8) y en `prompts/inventario-de-fuentes.md`
(P9), (7) las fases y apéndices ya escritos. Los documentos desechables no cuentan y no se citan.

Reglas de apéndice:
- **Esto no se lee de corrido.** Índice de salto rápido, secciones cortas que responden a UNA
  pregunta, ejemplo mínimo ejecutable, tabla de "cuándo usar qué" al final.
- **Un apéndice no repite lo que explica una fase: enlaza.** Si dos documentos explican lo mismo,
  uno de los dos está mal. Si la fase todavía no existe, la referencia va en prosa, sin enlace.
- **Los de instalación dan comandos y nada más**, con el comando que verifica cada paso, en las
  tres plataformas. No enseñan Python, ni gestores de paquetes, ni Docker: el mecanismo se enlaza
  (documentación oficial o `docker-container-legacy/`). Más de dos párrafos de explicación de una
  herramienta es señal de que ese contenido no es de aquí.
- **Nada sin ejecutar.** Ningún comando, ninguna versión, ninguna salida inventada. Las versiones
  salen de P8, con fecha. Lo no verificado se declara con esas palabras, donde el lector lo
  necesita.
- **Identificadores en inglés, comentarios en español con tildes.** Todo ejemplo usa `school`,
  `supply` o relaciones abstractas declaradas; nunca `foo`, `bar`, `tabla1` ni `grade` solo.
- **Notación Unicode, nunca LaTeX. Diagramas ASCII de 75 columnas como máximo.**
- **Declara qué queda fuera** en el encabezado, y dónde está.
- **Ejercicios: 5 a 10**, cortos y de consulta: buscar algo, cambiar un valor y observar, provocar
  un error típico y reconocerlo por su mensaje literal.
- **Toda prueba corre dentro de un contenedor `mdm-*` con la etiqueta `curso=01-bases`**, nunca en
  la máquina de Oskar; sin puertos publicados, y si hace falta uno, en `127.0.0.1` y en el rango
  `56000–56099`, nunca el puerto por defecto del producto (guía §11.1). Lo que no se puede
  contenerizar (recetas de macOS y Windows) se le pide a Oskar o se declara no verificado.
- **Git lo maneja Oskar.** No commitees. Los apéndices que dejan archivos en `src/` (a04, a05, a09,
  aca-02) proponen su tag `apendice-aNN-<slug>` en el cierre; los demás no llevan tag.
```

Y el **protocolo de tres pasos**, que cierra todos los prompts:

```markdown
## Cómo quiero que trabajes

**Paso 1 — Preguntas antes de escribir.** No redactes. Devuélveme: (a) preguntas bloqueantes
numeradas, marcando cuáles puedes asumir con un valor por defecto; (b) qué de lo que vas a mostrar
ya está verificado en P8/P9 y qué no; (c) el índice del apéndice; (d) cualquier contradicción con
lo ya escrito — dímela, no la resuelvas.
**Paso 2 — Redacción**, cuando yo responda. Ejecuta cada comando antes de escribirlo y copia la
salida literal. Si aparece una duda nueva, **para y pregunta**.
**Paso 3 — Autoverificación** contra el checklist de §15 de la guía, en lo que aplica a un
apéndice, reportada en lista corta.
```

---

## # a01 — SQLite nativo y el archivo físico

```markdown
Esta es la sesión del **Apéndice a01 — 🪶 SQLite nativo y el archivo físico**. Entregable:
`a01-sqlite-nativo.md`. **2 h de consulta.**

{{marco común}}

## Alcance

- **Instalar la CLI `sqlite3`** con el gestor de cada plataforma: `brew` en macOS; `winget`,
  Chocolatey y Scoop en Windows (en una tabla, con cuál recomienda el curso y por qué); `apt`, `dnf`
  y `pacman` en Linux. Y el binario oficial de sqlite.org cuando el gestor trae una versión vieja.
- **Comprobar que la versión admite `STRICT`**, con el comando exacto, la salida esperada y qué
  hacer si no la admite.
- **Los comandos con punto que usa el curso**: `.open`, `.read`, `.schema`, `.tables`, `.mode`,
  `.headers`, `.quit`. Una línea cada uno.
- **La base es un archivo**: dónde queda, qué extensión usa el curso, y cómo se copia, se mueve y
  se respalda **sin corromperla** (con la base cerrada, o con `.backup` y `VACUUM INTO` con una
  conexión abierta). Qué son `-wal` y `-shm`, por qué no se copian sueltos ni se borran a mano, y
  qué pasa si se copia solo el `.db` en modo WAL, con el síntoma literal.
- **Comprobar una copia** con `PRAGMA integrity_check`.
- **Recrear las bases del curso** con un comando, remitiendo a `a04` (en prosa si todavía no existe).

## Qué NO entra

La teoría del respaldo (F35), el WAL como teoría de recuperación (F32), los modos de journal, la
concurrencia de SQLite, las extensiones y todo lo que enseña el curso `05-sqlite`, que se nombra en
una línea y se remite en prosa.

## Pendientes que pueden bloquear

Verificado en P8 (`prompts/verificacion-de-laboratorio/hallazgos.md`, H6, H7, H10 y H11): la
versión por distribución Linux, el nombre del paquete en cada gestor, y la copia con el `-wal`
pendiente, que **pasa `integrity_check`** y pierde datos en silencio (el ejercicio usa la variante de
las 100 filas). **Sigue abierto:** las recetas de macOS y
Windows, que verifica Oskar o se declaran "no verificadas en esta plataforma"; y el `sqlite` de
Homebrew es *keg-only*, así que la receta de macOS tiene que resolver el `PATH`. Pregúntalo en el
paso 1 si Oskar no lo verificó todavía.

## Ejercicios: 8, de consulta

Instalar y verificar la versión; crear una tabla `STRICT` y provocar el error de tipo; respaldar
con `.backup` y con `VACUUM INTO`; comprobar la copia; reconocer el síntoma de una copia mal hecha.

{{protocolo}} Si te descubres explicando cómo funciona un gestor de paquetes, corta y enlaza.
```

---

## # a02 — Python, `venv` y Faker

```markdown
Esta es la sesión del **Apéndice a02 — 🐍 Python, `venv` y Faker**. Entregable:
`a02-python-venv-y-faker.md` y `src/requirements.txt`. **2 h de consulta.**

{{marco común}}

## Alcance

- **Instalar Python 3** en las tres plataformas: python.org, `brew`, `winget` y el gestor de la
  distribución; el lanzador `py` de Windows y la casilla del `PATH`. La versión mínima del curso
  es la 3.10 (P8, H9).
- **Crear, activar y desactivar un `venv`**, en una tabla por shell: bash/zsh, PowerShell (con la
  política de ejecución que bloquea la activación, su mensaje literal y cómo se levanta solo para el
  usuario) y `cmd`. Cómo se reconoce que está activo.
- **`pip` y `requirements.txt` con versiones fijadas**, en la raíz de `src/`, y el comando que
  reproduce el entorno exacto.
- **Faker para datos de prueba**: *locales* en español (`es_MX`, `es_CO`, `es_CL`, `es_AR`, y
  `es_ES` como contraste), `Faker.seed()` para que todos generen lo mismo, y **proveedores propios**
  para lo que Faker no trae (asignaturas, grados, escalas de notas, números de parte).
- ⚠️ **La advertencia, con esas palabras:** la misma semilla puede dar datos distintos con otra
  versión de Faker; por eso la versión va fijada.
- **Referencias oficiales** de Python, `venv`, `pip` y Faker, verificadas en la sesión.

## Qué NO entra

Enseñar Python; `uv`, `conda`, `pipx`, `poetry` y cualquier otro gestor (el curso usa `venv`
porque viene con Python, y lo dice una vez); el diseño de las bases, que está en `a04`.

## Pendientes que pueden bloquear

Verificado en P8 (H9, H10): Python 3.10 como mínimo; Faker idéntico entre arquitecturas y
distribuciones con semilla y versión fijadas; el mensaje literal de Debian y Ubuntu cuando falta
`python3-venv`. El `requirements.txt` de `src/` copia el de `prompts/verificacion-de-laboratorio/`,
**con SQLAlchemy fijado en 2.0.54** (H2). **Sigue abierto:** el mensaje literal de PowerShell y las
recetas de Windows y macOS, de Oskar o declaradas.

## Ejercicios: 8, de consulta

Crear el `venv` en tu shell; provocar y resolver el bloqueo de PowerShell; reproducir el entorno
desde `requirements.txt`; generar diez alumnos con semilla fija y comparar con el apéndice; escribir
un proveedor propio mínimo.

{{protocolo}}
```

---

## # a03 — `radb` en tres plataformas

```markdown
Esta es la sesión del **Apéndice a03 — 🧮 `radb` en tres plataformas**. Entregable: `a03-radb.md`.
**2 h de consulta.**

{{marco común}}

## Alcance

- **Instalar `radb` con `pip` dentro del `venv` de a02** y comprobar que responde.
- **Conectarlo a un `.db`** de las bases del curso, y su configuración si la necesita.
- **Correr consultas** de forma interactiva y desde archivo, que es como el curso guarda las
  expresiones de los ejemplos y los ejercicios. Fija aquí la convención de carpetas y extensión de
  esos archivos.
- **La sintaxis completa** en una tabla de dos columnas: cada operador de `radb` frente a la
  notación Unicode del curso. La tabla general de símbolos vive en `a07`; aquí va la parte que
  `radb` implementa.
- **Ver el SQL que genera**, que conecta con F10.
- **Lo que no tiene** —÷, ⟕ ⟖ ⟗, ⋉ y ▷— y la receta para escribir cada uno con los primitivos, con
  un ejemplo verificado por operador. Solo la receta: la teoría está en F07 y F08.
- **Su comportamiento con tablas `STRICT` y con `NULL`**, y los errores más comunes con su texto
  literal.

## Qué NO entra

La teoría de cada operador (F06–F08), la semántica de multiconjuntos (F11) y RelaX, que solo se
menciona en la bibliografía.

## Pendientes que pueden bloquear

Ninguno de los de P8: `radb` 3.0.5 **funciona sobre tablas `STRICT`** (H3); la invocación es
`radb base.db -i archivo.ra` y la configuración, `~/.radb.ini` (H4); los mensajes de error, `NULL` y
el SQL generado con `-d` están en H4 y H5, y el aviso de "configuration file" que sale siempre sin
`.radb.ini` también. Los comentarios son `//` y `/* */`, nunca `--`. Si al ejecutar algo no coincide
con los hallazgos, **para en el paso 1**.

## Ejercicios: 8, de consulta

Instalar y conectar; una selección y una proyección; ver el SQL generado; escribir una división con
primitivos y comprobar el resultado; provocar y reconocer un error de sintaxis típico.

{{protocolo}}
```

---

## # a04 — Las bases de ejemplo y su generador

```markdown
Esta es la sesión del **Apéndice a04 — 🏫 Las bases de ejemplo y su generador**. Entregables:
`a04-las-bases-de-ejemplo.md` y `src/a04-las-bases-de-ejemplo/` (DDL, datos chicos y generador).
**2 h de consulta.** Crece hasta F13.

{{marco común}}

## Alcance

- **`school`**: `school_year`, `term`, `grade_level`, `section`, `subject`, `teacher`, `student`,
  `guardian`, `enrollment`, `teaching_assignment`, `assessment`, `score` y `classroom`.
- **`supply` con pedidos**: `supplier`, `part`, `project`, `shipment`, `customer`, `sales_order` y
  `order_line`.
- De cada una: diagrama ER en ASCII (75 columnas), esquema relacional, **DDL `STRICT`** con sus
  restricciones, **datos chicos escritos a mano** (los que se siguen en papel), **el generador con
  Faker** para los volúmenes grandes, con su semilla y su versión fijada, y **recrear cada base desde
  cero en un comando**.
- **Este apéndice es la fuente de los nombres.** Atributos en inglés, `snake_case`, singular. Si una
  fase necesita una relación o un atributo nuevo, se agrega aquí.
- **La escala de notas como dominio** (1–7, 0–10, 0–20, 0–100): cómo la representa `score` y qué
  `CHECK` la impone.
- **El precio de la línea** (`order_line.unit_price`) frente al de la parte (`part.price`), declarado
  como dos hechos distintos del dominio.
- **La convención de relaciones abstractas y de planes**, con remisión a `a07`.

## Qué NO entra

El diseño de las bases: es materia de F02, F13 y del Bloque III, que llegan al mismo esquema por su
cuenta. Aquí se dan hechas. **No pongas en los comentarios del DDL ninguna justificación de diseño**
que adelante lo que esas fases deben descubrir.

## Pendientes que pueden bloquear

Verificado en P8 (H3, H9): los datos generados son idénticos entre arquitecturas con la versión
fijada, y un `.db` `STRICT` funciona con `radb`. El generador guarda **las fechas en `TEXT` ISO 8601**
y **no usa nada relativo a hoy** (`date_of_birth`, `date_this_year`), sino `date_between` con fechas
fijas; las bases no usan `ANY` ni `BLOB`. El tamaño de los volúmenes grandes lo fijan las fases que los necesitan (F21–F28); si no está
decidido, propón uno en el paso 1.

## Ejercicios: 6, de consulta

Recrear las dos bases; contar tuplas por relación y comparar con el apéndice; regenerar con otra
semilla y ver qué cambia; agregar una relación siguiendo las convenciones.

{{protocolo}} El cierre propone el tag `apendice-a04-las-bases-de-ejemplo`.
```

---

## # a05 — Los verificadores y el mini motor

```markdown
Esta es la sesión del **Apéndice a05 — 🔧 Los verificadores y el mini motor**. Entregables:
`a05-verificadores-y-mini-motor.md` y lo que corresponda en `src/a05-verificadores-y-mini-motor/`.
**3 h de consulta.** Nace con F15 y crece hasta F29; cada sesión que lo amplía usa este mismo prompt.

{{marco común}}

## Alcance

- **Cada verificador en una sección propia**: qué entrada recibe, qué devuelve, un ejemplo con su
  salida literal y qué fase lo usa. Los previstos: `closure`, `min_cover`, `keys` (F15);
  `normal_form` (F16); `njb`, `chase`, `preserves` (F17); `synth_3nf`, `bcnf_decompose` (F18); `bplus`
  (F24); `conflict_serializable` (F29). Candidato: `ext_hash`/`linear_hash` (F22).
- **El mini motor de F26**: operadores como iteradores (`open`, `next`, `close`), el contador de
  bloques leídos, y cómo se arma un plan. Qué implementa cada operador, sin repetir el algoritmo.
- **Cómo usarlos para revisar una solución propia**, que es la sección más consultada.
- **Python con biblioteca estándar**, sin dependencias, con la versión mínima de a02.

## Qué NO entra

La teoría de los algoritmos, que está en sus fases. El apéndice dice cómo se usan, no por qué
funcionan.

## Reglas propias

- **Cada verificador se prueba contra los ejemplos resueltos de su fase** antes de documentarse, y
  la salida que se publica es la de esa ejecución.
- **El formato de entrada de las relaciones abstractas y las DF** se fija la primera vez (F15) y no
  cambia después.
- **Las trazas** (clausura, *chase*, B+) se imprimen en ASCII de 75 columnas, para que se puedan
  pegar en un solucionario tal cual.

## Ejercicios: 8, de consulta

Correr cada verificador sobre un ejemplo de su fase; encontrar con él el error de una solución mal
hecha que el apéndice entrega; armar un plan de dos operadores en el mini motor y leer su contador.

{{protocolo}} El cierre propone el tag `apendice-a05-verificadores-y-mini-motor`.
```

---

## # a06 — La matemática mínima

```markdown
Esta es la sesión del **Apéndice a06 — ∑ La matemática mínima**. Entregable:
`a06-la-matematica-minima.md`. **3 h de consulta.** Se escribe antes de F04.

{{marco común}}

## Alcance

- **Conjuntos**: pertenencia, inclusión, operaciones, producto cartesiano, conjunto potencia; la
  diferencia entre conjunto y multiconjunto.
- **Relaciones y funciones** en sentido matemático, y por qué una relación de la base es un
  subconjunto de un producto cartesiano de dominios.
- **Lógica de predicados**: conectivos, ∀ y ∃, sus negaciones, y la equivalencia ¬∀x P(x) ⇔ ∃x ¬P(x)
  que F09 y F10 usan para la división.
- **Cómo se lee y se escribe una demostración**: directa, por contradicción, por contraejemplo y por
  inducción, cada una con un ejemplo corto tomado del curso (por ejemplo, la solidez de la
  reflexividad de Armstrong, o que σ es conmutativa).
- **Logaritmos y potencias** para la altura de un árbol y las pasadas de un ordenamiento externo.

## Qué NO entra

Lo que el curso no use. Si un tema no aparece en ninguna fase, no va aquí: sin teoría de órdenes,
sin álgebra abstracta, sin combinatoria más allá de F21–F26.

## Audiencia

Un desarrollador que no toca matemática formal desde la universidad. Cero condescendencia y cero
saltos: cada símbolo se presenta antes de usarse.

## Ejercicios: 10, de consulta y en papel

Operaciones de conjuntos, negar un cuantificador, dar un contraejemplo, una inducción corta,
calcular la altura de un árbol dado su orden y su número de claves.

{{protocolo}}
```

---

## # a07 — Notación y glosario bilingüe (vivo)

```markdown
Esta es la sesión del **Apéndice a07 — 📖 Notación y glosario bilingüe**. Entregable:
`a07-notacion-y-glosario.md`. **2 h de consulta.** **Documento vivo**: esta sesión escribe el
esqueleto antes de F04; cada fase lo alimenta en su propia sesión, y se cierra al final del curso.

{{marco común}}

## Alcance del esqueleto

- **La tabla de símbolos** de la guía §3.1, completa: cada símbolo Unicode, cómo se escribe o de
  dónde se copia en cada sistema, y su equivalente en `radb` cuando lo tiene (tomado de `a03`).
- **La tabla de notaciones** entre libros, con las columnas Navathe, Date y las que hagan falta, para
  lo que ya está decidido: proyección, selección, joins, división, dependencias, planes.
- **La convención de relaciones abstractas y de planes** (`R(A, B, C)`, `AB → C`,
  `r1(X); w2(X); c1`).
- **El glosario español ↔ inglés, en las dos direcciones**, con las entradas de F00–F03 si ya están
  escritas, y la columna "traducción de la edición en español" **vacía, con "sin verificar"**: P9 no
  pudo comprobarla (`prompts/inventario-de-fuentes.md` §4).
- **Cada entrada remite a la fase y al número de definición** donde se define.

## Qué NO entra

Definiciones largas: el glosario remite, no explica.

## Pendientes que pueden bloquear

La terminología de las ediciones en español no se pudo verificar en P9: la columna va con "sin
verificar", y ninguna entrada afirma cómo traduce un libro un término.

## Ejercicios: 6, de consulta

Traducir una expresión de la notación de un libro a la del curso; encontrar el término inglés de un
concepto y al revés; escribir en `radb` una expresión dada en Unicode.

{{protocolo}}
```

---

## # a08 — Mapa de bibliografía y recursos (vivo)

```markdown
Esta es la sesión del **Apéndice a08 — 📚 Mapa de bibliografía y recursos**. Entregable:
`a08-mapa-de-bibliografia.md`. **1 h de consulta.** **Documento vivo**: esta sesión escribe el
esqueleto antes de F00, con lo que P9 dejó verificado en `prompts/inventario-de-fuentes.md`; cada
fase agrega lo suyo, y se cierra al final.

{{marco común}}

## Alcance del esqueleto

- **Los cinco textos del camino base** (alcance §9) con edición, año, editorial y traducción al
  español si existe, y **la tabla libro × fase** con el capítulo de cada texto (P9 verificó capítulos,
  no secciones), y la advertencia de que las traducciones al español son de ediciones anteriores y
  numeran distinto.
- **Los cursos por bloque**: Udemy y Coursera, con plataforma, idioma, si son de pago 💲 y la fecha
  de verificación; los cursos completos de YouTube (CMU 15-445/645, Berkeley CS186, la serie de
  Jennifer Widom), con la clase concreta por fase cuando se sepa.
- **Los papers fundacionales por fase**, con referencia completa y dónde se consiguen.
- **La bibliografía propia del bloque A.C.**, en una sección aparte que no cuenta contra el tope.
- **La leyenda de ⭐ y de 💲.**

## Reglas propias

- **Ningún recurso entra sin comprobarlo en la misma sesión**: libro con edición y capítulo, URL con
  su código de estado, curso con su plataforma y precio. Lo que no se pudo comprobar no entra, o
  entra marcado "sin verificar".
- **A igual calidad, gana el gratuito y el que está en español.**
- **Una línea por recurso** de por qué vale la pena; nada de reseñas largas.

## Ejercicios: 5, de consulta

Encontrar la lectura base de una fase; encontrar un curso gratuito en español de un bloque; ubicar
un paper y su fecha.

{{protocolo}}
```

---

## # a09 — 🔥 El curso en un contenedor (opcional)

```markdown
Esta es la sesión del **Apéndice a09 — 🐳 El curso en un contenedor**. Entregables:
`a09-el-curso-en-un-contenedor.md` y `src/a09-el-curso-en-un-contenedor/` (`Dockerfile` o
`compose.yaml`). **1 h de consulta. Opcional**: el curso lo cita y nunca lo exige.

{{marco común}}

## Alcance

- **Una imagen con SQLite, Python, `radb` y Faker**, con las versiones de `a01`–`a03`, y las bases
  del curso montadas como volumen para que los `.db` sigan siendo archivos del disco del lector.
- **Docker como camino principal y Podman al lado**; cuando el comando es idéntico, se dice y no se
  duplica.
- **Un servicio extra, también opcional: PostgreSQL** para los ejercicios 🔥 de F34 (decisión B del
  alcance), con un usuario administrador y la receta para crear los usuarios del ejercicio.

## Qué NO entra

Enseñar Docker (se enlaza `docker-container-legacy/`); las herramientas del bloque A.C., que tienen
su propio apéndice (`aca-02`); administrar PostgreSQL, que es materia de `02-postgresql`.

## Pendientes que pueden bloquear

Verificado en P8 (H1): `python:3.14.8-slim-trixie` como base y el volumen en macOS arm64. Se
verifican en esta sesión, al crear `mdm-pg` (plan §2.4): el PostgreSQL extra y su memoria, y el
volumen en Windows y Linux, o se declaran.

## Ejercicios: 5, de consulta

Levantar el contenedor; abrir una base del curso desde dentro; comprobar que un cambio queda en el
`.db` del disco; levantar el PostgreSQL y conectarse.

{{protocolo}} El cierre propone el tag `apendice-a09-el-curso-en-un-contenedor`.
```

---

## 🏛️ Apéndices del bloque A.C.

Llevan el prefijo de track `aca-NN-`, son opcionales como todo el bloque, y no se mezclan con los
del camino base.

### # aca-01 — Herramientas nativas del bloque A.C.

```markdown
Esta es la sesión del **Apéndice aca-01 — 🏛️ Herramientas nativas del bloque A.C.** Entregable:
`aca-01-herramientas-nativas.md`. **1 h de consulta. Opcional.** Se escribe con AC01.

{{marco común}}

## Alcance

- **Git**, que el lector ya tiene, y los comandos de bajo nivel de AC06 (`git cat-file`,
  `git ls-tree`), con la comprobación de que están.
- **`lmdb` y ZODB** en el `venv` de a02, para AC07 y AC05, con su versión fijada en
  `requirements.txt` (o en un archivo propio del bloque, si se decide en el paso 1).
- **GnuCOBOL y Harbour** para AC01, con lo que trae cada gestor y la alternativa cuando no lo trae.
- **GCC o Visual C++** para AC09: cómo se instala cada uno y **cómo se compila con cada uno** el
  código de `src/ac09-pedidos-en-c/`, con los *flags* de ANSI C.
- **Una tabla de qué corre nativo en cada sistema** y qué queda para `aca-02`.

## Qué NO entra

La teoría de los modelos (AC00–AC05); enseñar C, COBOL o xBase; todo lo que necesite contenedor.

## Pendientes que pueden bloquear

Verificado en P8 (H12): `lmdb` trae LMDB 0.9.36 incluido; GnuCOBOL 3.2 con paquete en Debian,
Fedora, Homebrew y Chocolatey (no en Scoop ni en winget); Harbour 3.2.0 sin paquete en Linux, se
compila desde el fuente (tarball sin carpeta raíz, `ldconfig` sobre `/usr/local/lib/harbour`); en GCC,
`-std=c89 -pedantic -Wall -Wextra -Werror`. **Sigue abierto:** los *flags* de Visual C++, de Oskar o
declarados.

## Ejercicios: 5, de consulta

Comprobar cada herramienta; compilar AC09 con tu compilador; abrir una base LMDB vacía desde Python.

{{protocolo}}
```

### # aca-02 — Contenedores del bloque A.C.

```markdown
Esta es la sesión del **Apéndice aca-02 — 🏛️ Contenedores del bloque A.C.** Entregables:
`aca-02-contenedores.md` y `src/aca-02-contenedores/compose.yaml`. **1 h de consulta. Opcional.**
Se escribe con AC08.

{{marco común}}

## Alcance

- **YottaDB en contenedor**, con la imagen oficial `yottadb/yottadb` (P8, H12), las bases de
  `school` montadas como volumen y el paquete `yottadb` de Python conectado desde dentro.
- **Docker como camino principal y Podman al lado.**
- **Cualquier otra herramienta del bloque sin versión nativa** en alguna plataforma; P8 no encontró
  ninguna más.

## Qué NO entra

Enseñar Docker (se enlaza `docker-container-legacy/`) y administrar YottaDB. **Es independiente de
a09**: el contenedor del camino base no carga con las herramientas del bloque A.C., y viceversa.

## Pendientes que pueden bloquear

Ninguno de los de P8 (H12): `yottadb/yottadb:r2.06` es multiarquitectura y corre nativa en macOS
arm64, y el paquete `yottadb` 2.0.1 se compila desde el fuente dentro del contenedor (`gcc`,
`python3-dev`, `python3-venv`, `libffi-dev`), cargando antes `ydb_env_set`.

## Ejercicios: 5, de consulta

Levantar YottaDB; escribir y leer un *global* desde la consola; conectarse desde Python; comprobar
que los datos sobreviven a un reinicio del contenedor.

{{protocolo}} El cierre propone el tag `apendice-aca-02-contenedores`.
```
