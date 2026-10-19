# 📎 Apéndice a10 — 🏛️ El Access de museo: el `.accdb` sin Office y el `.bas` de Rubén en LibreOffice

> 🧭 **Nadie lo necesita para hacer el curso.** El insumo oficial es la caja en CSV de
> [`a05`](a05-la-caja-y-el-generador.md), y ninguna fase usa lo que hay aquí. Este apéndice es para quien
> quiere ver el archivo de Rubén por dentro, o tiene que abrir un `.accdb` real en su trabajo y no tiene
> Windows a mano.

> **Curso:** Ruta SQL · Opcional · **2 h**
> **Usado por:** nadie; la [Fase 04](04-un-valor-un-hecho.md) lo nombra como el camino para correr el
> `.bas` original · **Versiones cubiertas:** Jackcess 4.0.10, UCanAccess 5.1.3 (con HSQLDB 2.7.4), Java
> 25.0.4.1 en la imagen de Maven de [`a02`](a02-compose-de-la-ruta.md#-las-versiones-del-curso), mdbtools
> 1.0.1, LibreOffice 25.2.3 y Python 3.13.5 de Debian trixie
> **Fecha de verificación ejecutada:** 18/10/2026, con todo vuelto a correr en contenedores; los dos CSV
> que salen salieron idénticos byte a byte a los de la prueba de concepto del 29/09/2026

**Esto no se lee de corrido.** Se entra para hacer una cosa: generar el `.accdb`, consultarlo, sacarle
los datos o correr el parser de 1998 tal como lo escribió Rubén. Cada sección responde una pregunta y
trae el comando que la contesta.

**Qué queda fuera:** Access mismo, que no se usa en ningún momento; la historia del parser y sus
parches, que está en la [historia de Alameda](00-historia-de-alameda.md) y en la
[Fase 04](04-un-valor-un-hecho.md); el generador de la caja, que es otro (semilla 1996, 71 tablas) y está
en [`a05`](a05-la-caja-y-el-generador.md); y Java más allá de correr un archivo suelto, que está en
[`a06`](a06-python-java-y-drivers.md#-java-25-un-archivo-y-un-driver).

---

## Índice

- [Qué hay en la vitrina](#️-qué-hay-en-la-vitrina)
- [Generar el `.accdb` y sacarle los datos](#️-generar-el-accdb-y-sacarle-los-datos)
- [Consultarlo con SQL: UCanAccess](#-consultarlo-con-sql-ucanaccess)
- [Sin Java: mdbtools](#-sin-java-mdbtools)
- [Del `.accdb` a Postgres en dos comandos](#-del-accdb-a-postgres-en-dos-comandos)
- [Con interfaz: DBeaver](#️-con-interfaz-dbeaver)
- [El `.bas` de Rubén, tal cual, en LibreOffice Basic](#-el-bas-de-rubén-tal-cual-en-libreoffice-basic)
- [Tu instinto dice que el mismo código da lo mismo](#-tu-instinto-dice-que-el-mismo-código-da-lo-mismo-y-esta-vez-se-equivoca)
- [Los límites conocidos](#️-los-límites-conocidos)
- [El plan B: LibreOffice Base](#-el-plan-b-libreoffice-base)
- [Cuándo usar qué](#-cuándo-usar-qué)
- [Advertencias](#️-advertencias)
- [Referencias](#-referencias)
- [Ejercicios](#-ejercicios-6)

---

## 🗄️ Qué hay en la vitrina

Todo está en `src/a10-el-access-de-museo/`, y todos los comandos de este apéndice se corren desde ahí.
Es la tabla `pacientes` como la cargaba la recepción entre 1997 y 2005, en un `.accdb` de verdad, con 120
filas sucias generadas con la semilla 1997: el DNI con puntos y sin la palabra `DNI`, el recién nacido
con el DNI de la madre, el pasaporte boliviano, el teléfono metido después del DNI, el `NO TRAE` en el
campo del documento. Es una muestra, no la caja: la caja tiene 71 tablas y otra semilla.

| Archivo | Qué hace |
|---|---|
| `AccdbTool.java` | crea el `.accdb` con Jackcess (`generate`), lo exporta a CSV (`export`) y escribe de vuelta lo parseado (`apply`) |
| `QueryAccdb.java` | corre SQL sobre el `.accdb` con UCanAccess (`demo`, `query`) |
| `ModParser.bas` | el parser de Rubén de 1998, en VBA, como texto |
| `parse_patients.py` | el port fiel del VBA a Python, con sus defectos, más el chequeo que Rubén nunca tuvo |
| `TestParser.bas` y `run_bas_tests.py` | 40 aserciones sobre el `.bas` original, corridas en LibreOffice Basic sin interfaz |
| `Dockerfile.libreoffice` | la imagen con LibreOffice, Python y mdbtools |
| `pom.xml` | solo baja Jackcess y UCanAccess a `lib/` |

`lib/` y `out/` no se versionan: se regeneran con los comandos de abajo.

> 📝 **Lo único que cambió para que corriera.** La prueba de concepto del 29/09/2026 se movió a `src/`
> sin tocar su código. Se agregó `Dockerfile.libreoffice`, porque aquella prueba usaba el LibreOffice
> instalado en la máquina del autor y el curso no instala nada fuera de un contenedor. El `README.md`
> de la carpeta todavía describe esa prueba, con Java y Python en la máquina.

---

## ▶️ Generar el `.accdb` y sacarle los datos

Dos imágenes y nada instalado: la de Maven con Java 25 que fija `a02`, para lo de Java, y la de este
apéndice, para Python, mdbtools y LibreOffice. La segunda se construye una vez:

```bash
docker build -t ruta-sql-libreoffice:a10 --label curso=ruta-sql -f Dockerfile.libreoffice .
MVN=maven@sha256:a291659c5ffddf142e5174df5bfc3f3dcb48706e44868f341ef7914b39a254c9
LO=ruta-sql-libreoffice:a10
r() { docker run --rm --label curso=ruta-sql -v "$PWD":/w -w /w "$@"; }
```

El ciclo completo es el de Rubén: el archivo sucio, el parser, y el resultado escrito de vuelta en una
copia ("Hacer una copia de la base ANTES", dice el comentario del `.bas`):

```bash
r $MVN mvn -q dependency:copy-dependencies -DoutputDirectory=lib
mkdir -p out
r $MVN java -cp "lib/*" AccdbTool.java generate out/alameda_1998.accdb
r $MVN java -cp "lib/*" AccdbTool.java export   out/alameda_1998.accdb out/pacientes.csv
r $LO  python3 parse_patients.py out/pacientes.csv out/pacientes_parseado.csv
cp out/alameda_1998.accdb out/alameda_1998_parseado.accdb
r $MVN java -cp "lib/*" AccdbTool.java apply    out/alameda_1998_parseado.accdb out/pacientes_parseado.csv
```

```text
created out/alameda_1998.accdb with 120 rows in table pacientes
exported 120 rows to out/pacientes.csv
120 pacientes, 59 separados por el parser, 17 sospechosos

  id   5  DNI 12156374 no cuadra con nacer en 2001; recién nacido con el DNI de la madre
  id   6  nombre con datos adentro: 'VARGAS MAMANI JUANA PASAP BOL'
  id  18  dni no es un DNI: ''; nombre con datos adentro: 'GONZALEZ MIRTA DEAN FUNES 3427'
  ...
  id  81  nació en el futuro: 12/11/2027
  id  84  DNI 9337949 no cuadra con nacer en 2023
  ...
updated 59 rows in out/alameda_1998_parseado.accdb
```

De los 64 pacientes sin DNI cargado, el parser separa 59, y quedan 5 sin DNI que la recepción tendrá
que volver a pedir. Los 17 sospechosos son lo que una restricción `CHECK` del modelo nuevo habría
rechazado y el parser aceptó: el pasaporte que entró como DNI, el DNI de la madre en el recién nacido,
el `NO TRAE`, y las dos fechas que la ventana de dos cifras mandó de siglo (el 81 nace en 2027; el 84,
con DNI de los años veinte, nace en 2023). Es la misma suciedad que la [Fase 05](05-una-persona-no-es-su-documento.md)
encuentra en la caja, en pequeño.

> 💡 **El generador es determinista.** Con la semilla 1997, `pacientes.csv` y `pacientes_parseado.csv`
> salieron idénticos byte a byte el 29/09 y el 18/10/2026, con dos Java distintos y dos Python
> distintos. Si los tuyos difieren, cambió el código, no la suerte.

---

## 🔎 Consultarlo con SQL: UCanAccess

UCanAccess es un driver JDBC en Java puro: abre el `.accdb`, lo carga en un HSQLDB en memoria y acepta
SQL con sabor a Access. `demo` muestra cuatro cosas: lo que ve la recepción, el parser escrito en SQL
puro, el parser de Rubén aplicado sobre el resultado del SQL, y los aciertos que no son el DNI de esa
persona. `query` corre lo que le pases:

```bash
r $MVN java -cp "lib/*" QueryAccdb.java demo  out/alameda_1998.accdb
r $MVN java -cp "lib/*" QueryAccdb.java query out/alameda_1998.accdb "SELECT COUNT(*) FROM pacientes WHERE dni IS NULL"
```

```text
== 4. Lo que el parser no ve: aciertos que no son un DNI de esa persona

id  | nombre                                                       | dni_con_parser | problema
-----------------------------------------------------------------------------------------------------------
5   | RN CASTELLANI NORMA DNI 12156374 22/05/01                    | 12156374       | es el DNI de la madre
6   | VARGAS MAMANI JUANA PASAP BOL 4873781 21/12/88 RUTA 20 KM 11 | 4873781        | es un pasaporte
18  | GONZALEZ MIRTA DEAN FUNES 3427                               |                | no encontró nada
...
(10 filas)
c1
--
64
(1 filas)
```

La sección 2 de la demo es la que cuenta la historia: el "parser en SQL" busca `'DNI '` y corta ocho
caracteres, y con eso pierde el DNI con puntos y todo lo que no dice `DNI`. Por eso Rubén escribió VBA:
cuatro datos en un solo campo de texto no se separan con SQL, se separan con un programa, y el programa
acierta cuando acierta. La [Fase 05](05-una-persona-no-es-su-documento.md) es lo que se hace en lugar de
eso.

> ⚠️ **El dialecto se parece al de Access, pero no es Access.** En UCanAccess 5.1.3, `InStr()` devuelve 0
> incluso con literales; `LOCATE()` y `SUBSTRING()` funcionan, y la demo los usa. Una consulta guardada
> de Access no se pega tal cual.

---

## 🧰 Sin Java: mdbtools

mdbtools lee archivos de Jet y ACE desde la terminal: lista tablas, saca el esquema traducido a otro
motor y exporta los datos. Está en la imagen del apéndice:

```bash
r $LO mdb-ver    out/alameda_1998.accdb
r $LO mdb-tables -1 out/alameda_1998.accdb
r $LO mdb-export out/alameda_1998.accdb pacientes > out/pacientes_mdb.csv
cmp out/pacientes_mdb.csv out/pacientes.csv && echo idénticos
```

```text
ACE14
pacientes
idénticos
```

`ACE14` es el formato de Access 2010, el que escribe Jackcess. **El CSV de mdbtools es idéntico byte a
byte al que exporta Jackcess**: dos lectores independientes, en dos lenguajes, ven lo mismo, y eso es lo
que quieres antes de confiar en una migración.

`mdb-sql` también existe, y es donde mdbtools se queda corto. Con 1.0.1, `WHERE dni IS NULL` devuelve
**cero filas** (con la advertencia `Calling mdb_test_sarg on unknown operator`), cuando son 64, y
`SELECT COUNT(*) … WHERE dni IS NULL` con `-P` termina en `Segmentation fault`. `LIKE` y las
comparaciones numéricas sí funcionan:

```bash
echo "SELECT id, dni FROM pacientes WHERE dni LIKE '%VER%'" | r -i $LO mdb-sql -F out/alameda_1998.accdb
```

```text
|id         |dni                                                                                                 |
+-----------+----------------------------------------------------------------------------------------------------+
|55         |15519835 (VER)                                                                                      |
|104        |36633751 (VER)                                                                                      |
```

🧭 **mdbtools sirve para sacar los datos, no para consultarlos.** Para preguntar, se exporta a un motor
de verdad.

---

## 🐘 Del `.accdb` a Postgres en dos comandos

`mdb-schema` traduce las tablas al dialecto de otro motor, y `mdb-export -I` saca los datos como
`INSERT`:

```bash
r $LO mdb-schema out/alameda_1998.accdb postgres > out/museo_schema.sql
r $LO mdb-export -I postgres -q "'" out/alameda_1998.accdb pacientes > out/museo_datos.sql
```

```sql
CREATE TABLE IF NOT EXISTS "pacientes"
 (
	"id"			SERIAL,
	"nombre"			VARCHAR (255),
	"dni"			VARCHAR (50),
	"fecha_nac"			VARCHAR (50),
	"direccion"			VARCHAR (255)
);
ALTER TABLE "pacientes" ADD CONSTRAINT "pacientes_pkey" PRIMARY KEY ("id");
```

El autonumérico de Access pasa a `SERIAL`, y lo demás llega como texto, porque Rubén lo guardaba como
texto: `fecha_nac` es `VARCHAR (50)` y sigue diciendo `22/05/01`. Cargados en un Postgres descartable
con la imagen del laboratorio (sin tocar la base `alameda`), dan 120 filas, 64 sin DNI y 5 con un DNI
que no es numérico. La traducción conserva la estructura; **no modela nada**, y lo que falta hacer es el
curso entero.

> ⚠️ **La secuencia queda en 1.** Los `INSERT` traen el `id` explícito, así que la secuencia del `SERIAL`
> no avanza, y el primer paciente nuevo choca con el 1. Es el ejercicio 4.

---

## 🖱️ Con interfaz: DBeaver

Para mirar el archivo con ventanas en Mac o en Linux, DBeaver trae el driver de UCanAccess entre los
suyos: se crea una conexión de tipo Access y se apunta al `.accdb`. Este apéndice no lo probó, porque el
curso no usa clientes gráficos ([`a03`](a03-clis-de-los-motores.md)); lo que veas ahí es lo mismo que
devuelve `QueryAccdb.java`, con el mismo dialecto y los mismos límites.

---

## 🧪 El `.bas` de Rubén, tal cual, en LibreOffice Basic

Sin Access no hay forma de correr el VBA dentro de un `.accdb`, pero LibreOffice Basic con
`Option VBASupport 1` ejecuta el `.bas` sin interfaz, desde la terminal. `run_bas_tests.py` arma una
biblioteca de Basic con `ModParser.bas` y `TestParser.bas`, le quita las dos líneas que solo existen en
Access (`Attribute VB_Name`, `Option Compare Database`) y le agrega `Option VBASupport 1`; nada más.
`TestParser.bas` son 40 aserciones sobre `ParsearNombre` y `ExtraerDNI`, con los valores esperados que da
el port de Python. `ParsearPacientes` compila pero no se ejecuta, porque usa DAO.

El script recibe la configuración regional y el primer año de la ventana de dos cifras, y usa un perfil
de LibreOffice aislado en `out/lo-profile`:

```bash
r $LO python3 run_bas_tests.py                 # es-AR, años desde 1930: la PC de la recepción en 1998
r $LO python3 run_bas_tests.py en-US           # el mismo código, configuración regional de EE. UU.
r $LO python3 run_bas_tests.py es-AR 1950      # otra ventana de años, otro runtime
```

```text
40 passed, 0 failed

FAIL  two-digit year 27 -> 2027 / fecha_nac: got [11/12/2027] expected [12/11/2027]
FAIL  two-digit year 35 -> 1935 / fecha_nac: got [] expected [23/05/1935]
FAIL  two-digit year 35 -> 1935 / direccion: got [23/05/35 DEAN FUNES 3300] expected [DEAN FUNES 3300]
...
31 passed, 9 failed

FAIL  two-digit year 35 -> 1935 / fecha_nac: got [23/05/2035] expected [23/05/1935]
39 passed, 1 failed
```

Las tres son las de la prueba del 29/09/2026: **40 de 40** con la PC de 1998, **31 de 40** en `en-US`
y **39 de 40** con la ventana desde 1950. En `en-US`, `15/03/62` deja de ser una fecha (no hay mes 15) y
cae en la dirección, y `12/11/27` se lee mes primero y sale `11/12/2027`. Con la ventana desde 1950,
`23/05/35` es 2035. **El parser dependía de la configuración regional de la PC donde corría**, y nadie lo
supo mientras corrió siempre en la misma.

> 📝 **La ventana "por defecto" cambió entre versiones de LibreOffice.** La prueba del 29/09 corrió
> `es-AR default` y dio 39 de 40; la imagen de hoy da 40 de 40 con el mismo comando. No es el parser: el
> valor de fábrica de `TwoDigitYear` es **1930** en LibreOffice 25.2.3 (el de Debian trixie) y **1950** en
> LibreOffice 26.2.1 (el de la máquina de la prueba). Por eso arriba la ventana va explícita. El mismo
> `.bas`, con la misma configuración, cambia de resultado al actualizar el runtime.

La salida queda en `out/bas_tests.txt`, porque en LibreOffice `Print` abre un diálogo.

---

## 🪞 Tu instinto dice que el mismo código da lo mismo… y esta vez se equivoca

Tu instinto de desarrollador dice que un programa determinista, con la misma entrada, da la misma
salida. El `.bas` de Rubén es determinista, y su salida depende de dos cosas que no están en el código:
la configuración regional, que decide si `12/11/27` es noviembre o diciembre, y la ventana de dos
cifras, que decide el siglo. `IsDate` y `CDate` preguntan las dos al sistema cada vez.

La [Fase 04](04-un-valor-un-hecho.md) encontró lo mismo en la caja con otro par de runtimes: VBA lee
`19/04/36` como 1936 y SQL Server, con su corte en 2049, como 2036, y **115 pacientes** nacen con un siglo
de diferencia según quién los lea. Aquí se ve la causa en el código y se mide con 40 aserciones. La
corrección no es elegir el runtime bueno: es **que la fecha no pase nunca por una conversión que depende
del entorno**, ni en el parser ni en la base. Un `date` en el modelo y una conversión explícita en la
carga, como hace el curso desde la Fase 04.

> 🩻 **Esto sí funciona igual.** La prueba de caracterización: fijar lo que el código hace hoy, con sus
> defectos, antes de tocarlo. Es la misma técnica con la que la [Fase 25](25-la-migracion-sin-parar.md)
> compara el viejo y el nuevo mientras conviven, aplicada a cuarenta líneas de VBA.

---

## ⚠️ Los límites conocidos

- **El VBA no vive dentro del `.accdb`.** Ni Jackcess ni UCanAccess escriben módulos ni consultas
  guardadas. Con Access en Windows, `ModParser.bas` se importa desde el editor de VBA.
- **Sin campos multivalor ni adjuntos.** Jackcess no los crea; un `.accdb` real que los use se lee, pero
  este no los tiene.
- **UCanAccess no es Access.** El SQL corre sobre HSQLDB. `InStr()` devuelve 0 en 5.1.3, y registrar una
  función Java para llamarla desde SQL (`addFunctions`, como se llamaría una función VBA desde una
  consulta de Access) falló con HSQLDB 2.7.4 en la prueba de concepto y no se investigó más: por eso la
  demo aplica el parser en Java sobre el resultado del SQL.
- **Dos Jackcess en el classpath.** UCanAccess trae su propio fork (`io.github.spannm.jackcess`, la
  `jackcess-5.1.0.jar` de `lib/`); convive con el original de `AccdbTool` porque los paquetes son
  distintos.
- **`mdb-sql` no sirve para consultar.** `IS NULL` da cero filas y una combinación con `-P` se cae.
- **`ModParser.bas` no se ejecutó nunca en Access real.** Corre en LibreOffice Basic, que con
  `VBASupport` imita VBA; la referencia de comportamiento es el port de Python, y las 40 aserciones dicen
  dónde coinciden.

---

## 🧩 El plan B: LibreOffice Base

Si Jackcess dejara de servir (un formato nuevo de Access, un proyecto abandonado), el museo se puede
rehacer como una base de LibreOffice Base (`.odb`, con HSQLDB o Firebird adentro): la tabla `pacientes`
con las mismas columnas de texto, cargada desde `out/pacientes.csv`, y el `.bas` como macro del
documento. Se pierde lo que hace a esto una pieza de museo, que el archivo sea un `.accdb` como el de
Rubén; se conserva lo que enseña, que es el parser y su dependencia del entorno. **Este plan no se
ejecutó**: es la salida prevista, no una receta probada.

---

## 🧭 Cuándo usar qué

| Situación | Qué usas | Por qué |
|---|---|---|
| Hacer el curso | la caja en CSV de `a05` | es el insumo oficial; este apéndice no hace falta |
| Mirar un `.accdb` con SQL, sin Windows | UCanAccess (`QueryAccdb.java query`) | SQL completo, con dialecto de HSQLDB |
| Sacar los datos de un `.accdb` | `mdb-export`, o `AccdbTool export` | los dos dan el mismo CSV, byte a byte |
| Llevar un `.accdb` a Postgres | `mdb-schema … postgres` y `mdb-export -I postgres` | la estructura en dos comandos; después, `setval` |
| Consultar con mdbtools | no lo hagas: exporta | `mdb-sql` pierde filas con `IS NULL` |
| Saber qué hace un VBA heredado | LibreOffice Basic y pruebas de caracterización | corre el original, sin portarlo |
| Saber si ese VBA depende del entorno | las mismas pruebas con otra configuración regional y otra ventana | 40, 31 y 39 de 40 con el mismo código |
| Mirarlo con ventanas | DBeaver con UCanAccess | no probado aquí; mismos límites que el driver |

---

## ⚠️ Advertencias

- **La imagen de LibreOffice se construye desde Debian trixie fijado por digest, pero `apt-get` instala
  lo que el repositorio tenga ese día.** Si una actualización de Debian cambia el LibreOffice, la ventana
  "por defecto" puede cambiar otra vez; por eso los comandos la fijan.
- **`parse_patients.py` usa la fecha de hoy** para marcar "nació en el futuro". El paciente 81 cambia de
  motivo el 12/11/2027 (es el ejercicio 6).
- **El `.accdb` es una muestra de 120 filas.** Ningún número de aquí es de la caja, y ninguno se compara
  con los de las fases.
- **Ninguno de los ejemplos toca la base del laboratorio.** El Postgres de la sección de migración es un
  contenedor descartable.

---

## 📚 Referencias

> ⚠️ Las URL y sus contenidos cambian. Todas se consultaron el 18/10/2026.

- **Jackcess** — https://jackcess.sourceforge.io/ — la biblioteca Java que lee y escribe archivos de
  Access sin Access.
- **UCanAccess** — https://spannm.github.io/ucanaccess/ y https://github.com/spannm/ucanaccess — el driver
  JDBC sobre Jackcess y HSQLDB.
- **mdbtools** — https://github.com/mdbtools/mdbtools — y el paquete de Debian trixie,
  https://packages.debian.org/trixie/mdbtools.
- **`Option VBASupport`** — https://help.libreoffice.org/latest/en-US/text/sbasic/shared/03103350.html —
  qué cambia en LibreOffice Basic al activarlo.
- **`CDate` en LibreOffice Basic** — https://help.libreoffice.org/latest/en-US/text/sbasic/shared/03100300.html
  — la conversión que depende de la configuración regional.
- **Opciones generales de LibreOffice** — https://help.libreoffice.org/latest/en-US/text/shared/optionen/01010600.html
  — "Year (two digits)", la ventana de dos cifras.
- **`IsDate` en VBA** — https://learn.microsoft.com/en-us/office/vba/language/reference/user-interface-help/isdate-function
  — lo que Access considera una fecha.
- **`Format` en VBA** — https://learn.microsoft.com/en-us/office/vba/language/reference/user-interface-help/format-function-visual-basic-for-applications
  — la barra de un formato de fecha es el separador de la configuración regional.
- **Funciones de secuencias de PostgreSQL** — https://www.postgresql.org/docs/current/functions-sequence.html
  — `setval` y `pg_get_serial_sequence`.
- **DBeaver** — https://dbeaver.io/

**Orden sugerido:** el ciclo completo de la segunda sección una vez; las tres corridas del `.bas` justo
después, que son el centro del apéndice; mdbtools y la migración cuando tengas un `.accdb` propio.

---

## 🧪 Ejercicios (6)

Todos se hacen desde `src/a10-el-access-de-museo/`, con `r`, `$MVN` y `$LO` definidos como en la segunda
sección y el ciclo completo ya corrido.

## 🟢 Fácil — el archivo (1–2)

### 🟢 Ejercicio 1 — Lo que el parser deja

Con `QueryAccdb.java query`, cuenta en `out/alameda_1998_parseado.accdb` los pacientes que siguen sin
DNI y los que tienen un DNI que no son solo dígitos. Predice antes los dos números con lo que imprimió
`parse_patients.py`.

**Objetivo:** las dos consultas y sus resultados, y de dónde sale cada uno en la salida del parser.

[Solución](soluciones/a10-el-access-de-museo.md#ejercicio-1)

### 🟢 Ejercicio 2 — Dos lectores

Exporta `pacientes` de `out/alameda_1998_parseado.accdb` con mdbtools y con `AccdbTool export`, y
compáralos.

**Pregunta:** ¿son idénticos? ¿Qué te dice eso sobre `apply`, que escribió el archivo con Jackcess y lo
lee ahora otro programa?

[Solución](soluciones/a10-el-access-de-museo.md#ejercicio-2)

## 🟡 Intermedio — el entorno (3–4)

### 🟡 Ejercicio 3 — La ventana desde 1900

Corre `run_bas_tests.py es-AR 1900`. Antes de correrlo, lee los casos de `TestParser.bas` y predice
cuáles fallan.

**Objetivo:** tu predicción, el resultado (cuántas de 40) y, para cada fallo, qué fecha de la recepción
se movió de siglo y hacia dónde.

[Solución](soluciones/a10-el-access-de-museo.md#ejercicio-3)

### 🟡 Ejercicio 4 — El museo en Postgres

Lleva el `.accdb` a un Postgres descartable con `mdb-schema` y `mdb-export -I`, usando la imagen del
laboratorio (`docker run --rm`, sin puerto publicado, sin tocar el laboratorio). Inserta un paciente
nuevo sin `id`.

**Objetivo:** el error del `INSERT`, la sentencia que lo arregla y el `id` que recibe el paciente nuevo
después del arreglo.

[Solución](soluciones/a10-el-access-de-museo.md#ejercicio-4)

## 🟠 Difícil — el código (5)

### 🟠 Ejercicio 5 — Un parser que no pregunte

Cambia `ModParser.bas`, en una copia de la carpeta, para que la fecha no dependa de la configuración
regional ni de la ventana de LibreOffice: día y mes en ese orden siempre, y del `00` al `29` como 20xx,
que es lo que hacía la PC de 1998. No cambies `TestParser.bas`.

**Objetivo:** 40 de 40 en las cuatro corridas (`es-AR`, `en-US`, `es-AR default` y `es-AR 1950`), y una
frase sobre por qué `Format$(…, "dd/mm/yyyy")` tampoco sirve para escribir la fecha.

[Solución](soluciones/a10-el-access-de-museo.md#ejercicio-5)

## 🔴 Muy difícil — el reloj (6)

### 🔴 Ejercicio 6 — El sospechoso que cambia de motivo

`parse_patients.py` marca al paciente 81 porque "nació en el futuro: 12/11/2027". Sin esperar a 2027,
averigua qué dice de él el 12/11/2027 y el 01/01/2030, y si el total de sospechosos cambia.

**Pregunta:** ¿qué pasa con el 81, y por qué? ¿Qué le falta a una regla de calidad que depende del día
en que corre, y cómo la escribirías como restricción del modelo nuevo para que no dependa?

[Solución](soluciones/a10-el-access-de-museo.md#ejercicio-6)

---

> 🏷️ **Este apéndice deja archivos en el repositorio:** `src/a10-el-access-de-museo/`. `lib/` y `out/` no
> se versionan: se regeneran. El commit que lo cierra se etiqueta `apendice-a10-access-de-museo`.
