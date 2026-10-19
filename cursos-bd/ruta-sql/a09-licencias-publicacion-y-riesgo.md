# 📎 Apéndice a09 — Licencias, publicación y riesgo: qué se puede publicar de cada motor

> ⚖️ **Esto no es asesoramiento legal.** Es lo que dicen hoy los textos de las licencias, citados con
> enlace y fecha, y cómo los aplica este curso. Para una decisión de tu empresa, pregúntale a quien
> lleva sus contratos.

> **Curso:** Ruta SQL · Consulta rápida · **1 h**
> **Usado por:** todas las fases que miden, desde la Fase 03 · **Versiones cubiertas:** SQL Server 2025
> Developer y Express, Oracle AI Database 26ai Free, MySQL 9.7, PostgreSQL 18 y MongoDB 8.0
> **Fecha de verificación ejecutada:** 12/10/2026: los textos de las licencias se descargaron y se
> releyeron ese día; ninguno cambió respecto de la consulta del 11/10/2026

**Esto no se lee de corrido.** Se entra para saber por qué una fase publica el resultado de Postgres
y deja sin resolver el de Oracle, o para decidir si un número tuyo se puede compartir. Responde tres
preguntas: qué dice cada licencia sobre publicar resultados, qué hace el curso con eso, y qué riesgo
corre cada motor de aquí a cinco años.

**Qué queda fuera:** asesoramiento legal, precios de licencias, y el análisis de contratos
particulares, que no son públicos. Cómo se presenta una medición publicada y una apuesta sin resolver
está en [`a04`](a04-el-arnes-de-forma.md); los motores y sus versiones, en
[`a02`](a02-compose-de-la-ruta.md#-las-versiones-del-curso).

---

## Índice

- [La regla del curso, en una tabla](#️-la-regla-del-curso-en-una-tabla)
- [SQL Server: la cláusula, tal cual](#-sql-server-la-cláusula-tal-cual)
- [Oracle Free: sin cláusula, y el curso igual no publica](#-oracle-free-sin-cláusula-y-el-curso-igual-no-publica)
- [Qué sí se publica de Oracle y de SQL Server](#-qué-sí-se-publica-de-oracle-y-de-sql-server)
- [Postgres, MySQL y MongoDB](#-postgres-mysql-y-mongodb)
- [El riesgo a cinco años: MySQL](#-el-riesgo-a-cinco-años-mysql)
- [Qué preguntar, y a quién](#-qué-preguntar-y-a-quién)
- [Cuándo usar qué](#-cuándo-usar-qué)
- [Advertencias](#️-advertencias)
- [Referencias](#-referencias)
- [Ejercicios](#-ejercicios-5)

---

## 🗂️ La regla del curso, en una tabla

| Motor | Qué publica el curso | Por qué |
|---|---|---|
| PostgreSQL | la receta, la apuesta y **el resultado** | su licencia no restringe nada de esto |
| MySQL | la receta, la apuesta y **el resultado** | la GPL no restringe publicar resultados |
| MongoDB (Fase 20) | la receta, la apuesta y **el resultado** | la SSPL tampoco |
| SQL Server | la apuesta completa, **sin resolver** | su licencia exige permiso para divulgar un *benchmark* |
| Oracle | la apuesta completa, **sin resolver** | decisión del curso, aunque Free no tiene la cláusula (abajo) |

"Sin resolver" quiere decir: hipótesis, condiciones y comando, para que la resuelvas en tu máquina,
y el mecanismo explicado con la documentación oficial. Nunca un número propio. La forma de escribirla,
con su 🪞🔒, está en la guía del curso y en cada fase que la usa.

---

## 📜 SQL Server: la cláusula, tal cual

La licencia de SQL Server 2025 Developer, Express y Evaluation es un PDF de seis páginas, fechado el
05/12/2025, al que se llega desde `microsoft.com/useterms`. La imagen del laboratorio no la trae: solo
remite a `aka.ms/useterms`. Su sección 5, completa:

> **5. BENCHMARK TESTING.** You must obtain Microsoft's prior written approval to disclose to a third
> party the results of any benchmark test of the software.

No distingue ediciones: vale para Developer, que es la del track del curso, igual que para Express.
Se la conoce como **cláusula DeWitt**, por David DeWitt, investigador de la Universidad de Wisconsin
conocido por sus *benchmarks* de bases de datos. La anécdota de su origen circula en versiones que no
pude confirmar con una fuente primaria, y por eso no se cuenta aquí.

La misma licencia, §1.a.i, dice para qué sirve Developer: *"to design, develop, test and demonstrate
your programs. You may not use the software in a production environment."* Y los límites de Express,
según la documentación de ediciones de SQL Server 2025:

| Límite | Express | Developer |
|---|---|---|
| Cómputo por instancia | el menor entre 1 socket y 4 núcleos | el de la edición que imita: Enterprise o Standard |
| Memoria del *buffer pool* | 1.410 MB | ídem |
| Tamaño de una base | 50 GB | ídem |
| Producción | permitida | **no** |

Desde 2025, Developer viene en dos sabores, **Enterprise Developer** y **Standard Developer**, con las
funciones de la edición de su nombre. El laboratorio usa la primera
([`a02`](a02-compose-de-la-ruta.md#-las-versiones-del-curso)).

**Qué hace el curso:** no publica ningún número propio de SQL Server. Ni tiempos, ni lecturas, ni
filas reales de un plan, ni tamaños medidos.

---

## 📜 Oracle Free: sin cláusula, y el curso igual no publica

**Oracle AI Database Free** no se licencia con el contrato de empresa de Oracle. Su manual de
licencias, en la versión 26, lo dice así: *"is released under the Oracle Free Use Terms and
Conditions"*. Ese texto, en `oracle.com/downloads/licenses/oracle-free-license.html`, lleva la fecha
*"Last updated: 9 June 2021"*, y **no tiene cláusula de benchmark**: el 12/10/2026 se buscaron en él
`benchmark`, `disclos` y `publish`, sin resultados.

Los textos de Oracle que sí la tienen son los de las otras licencias. El *Oracle Technology Network
License Agreement*, el que acompaña a muchas descargas de desarrollo (actualizado el 09/09/2014),
prohíbe *"disclose results of any Program benchmark tests without Oracle's prior consent"*. Los
contratos de empresa, con los que corre el Oracle que tienes en tu trabajo, no son públicos, y este
apéndice no los cita.

**Por qué el curso igual no publica números de Oracle:** un número medido en Free invita a
extrapolarlo a la edición que el lector usa en su empresa, que corre bajo un contrato con esa
cláusula. Y Free tiene sus propios techos, que el manual da para cada instancia: **2 CPU, 2 GB de RAM
y 12 GB de datos de usuario**. Un número medido con esos techos no dice nada de un Enterprise Edition.
Publicar la apuesta sin resolverla no pierde nada: la resuelves tú, en tu máquina, y el resultado es
tuyo.

> ⚠️ **El riesgo que sí está en los *Free Use Terms*.** El texto dice: *"You are granted the right to
> use the Programs to provide third party training in the use of the Programs and associated
> Separately Licensed Technology only if there is express authorization of such use by Oracle on the
> Program's download page or in the Program Documentation."* Un curso que usa Oracle Free podría
> leerse como formación a terceros. El 12/10/2026, ni la página de descarga de Free ni su manual de
> licencias mencionaban la formación. El curso lo trata como **riesgo declarado**: usa Oracle para
> contrastar mecanismos documentados y no lo enseña como producto. Si tú vas a dar un curso, esa
> frase es la que tienes que llevarle a tu abogado.

---

## 🔎 Qué sí se publica de Oracle y de SQL Server

La regla es sobre **resultados**, no sobre todo lo que sale de una terminal. Lo que el curso publica,
y por qué no es un resultado de rendimiento:

| Se publica | Ejemplo | Por qué |
|---|---|---|
| La **estructura** de un plan, de `EXPLAIN PLAN` sin ejecutar | `TABLE ACCESS FULL` con su predicado, en [`a04`](a04-el-arnes-de-forma.md#-uv-run-lab-measure-y-su-salida) | son las operaciones y su orden, no lo que costaron |
| **Los mensajes de error** | `KUP-04076`, `ORA-03113`, en [`a08`](a08-catalogo-de-errores.md) | dicen qué pasó, no cuánto tardó |
| **El dimensionamiento del laboratorio** | arranque y memoria de cada contenedor, en `a01` y `a02` | sin eso no sabes si entra en tu máquina; no es el motor bajo una carga |
| **Conteos de la caja** | cuántas tablas cargó `lab load` | es un dato del generador, igual en los tres motores |
| **Comportamiento documentado** | Oracle trata `''` como NULL | se cita de la documentación, con enlace |

Lo que **no** se publica: lecturas lógicas, filas reales, tiempos de carga o de consulta, tamaños de
tablas o de volúmenes, y cualquier comparación numérica con otro motor. `lab load` y `lab measure`
esconden el tiempo y las estadísticas de Oracle salvo que pidas `--private`, y esa salida es para ti.

---

## 🐘 Postgres, MySQL y MongoDB

**PostgreSQL** se publica bajo la *PostgreSQL License*, que su propio sitio describe como *"a liberal
Open Source license, similar to the BSD or MIT licenses"*. No restringe medir, publicar ni usar en
producción.

**MySQL** tiene **licencia dual**: la edición Community, bajo la **GPLv2**, y una licencia comercial de
Oracle para quien distribuye MySQL dentro de un producto cerrado y no quiere publicar su código bajo
GPL. Usarlo como servidor de tu aplicación no te obliga a nada de eso, y la GPL no restringe publicar
resultados. El driver que usa el curso, PyMySQL, es MIT e independiente de Oracle
([`a06`](a06-python-java-y-drivers.md#-los-tres-drivers)).

**MongoDB**, el invitado de la Fase 20, se publica bajo la *Server Side Public License* (SSPL), que
apunta a quien ofrece MongoDB como servicio a terceros. El texto no menciona *benchmarks* ni la
divulgación de resultados (se buscaron las dos palabras el 12/10/2026).

---

## 📉 El riesgo a cinco años: MySQL

**La pregunta no es si MySQL es un buen motor.** Lo es, y el curso lo usa como contraste en todas las
fases donde su mecanismo cambia la decisión. La pregunta es **quién lo va a mantener dentro de cinco
años**, y en eso hay señales que conviene conocer con fecha:

- **21/04/2026.** Sale MySQL 9.7, la LTS de la serie 9, con soporte *premier* hasta el **30/04/2031** y
  extendido hasta el 30/04/2034. Es la que usa el curso. Es también la última con numeración
  secuencial: el manual dice que las siguientes usan versiones de calendario (*"MySQL 26.7 represents
  the July 2026 release"*).
- **Septiembre de 2025.** Oracle despide a parte del equipo de MySQL. The Register (11/09/2025) cita a
  una fuente de la comunidad que habla de unas 70 personas, sin confirmarlo, y a Monty Widenius, el
  fundador de MySQL: *"heartbroken"*. Oracle no respondió a la consulta del medio.
- **Febrero de 2026.** Oracle publica una entrada en su blog sobre una "nueva etapa" de MySQL:
  funciones que pasan de la edición comercial a la Community, una hoja de ruta pública y más
  participación de la comunidad (The Register, 16/02/2026). Al día siguiente, Percona publica una
  **carta abierta** que pide llevar MySQL a una fundación sin fabricante dominante (17/02/2026); a los
  dos días tenía al menos 248 firmas, de Percona, MariaDB, PlanetScale, DigitalOcean y otros
  (InfoWorld, 19/02/2026).
- **La actividad.** Según un análisis de Percona citado por InfoWorld, los *commits* bajaron de 22.360
  en 2010 a 4.730 en 2024, y los contribuyentes activos, de 135 en el último trimestre de 2017 a unos
  75 en el tercero de 2025.

Dicho sin dramatismo: **MySQL 9.7 tiene soporte asegurado más allá de cualquier horizonte de este
curso**, y la carta y la respuesta de Oracle muestran que hay más de un actor interesado en que el
proyecto siga. Lo que cambió es que ya no se puede dar por sentado quién lo conduce. Para una decisión
de cinco años, eso pide un plan B escrito: Percona Server es compatible con MySQL y se mantiene aparte,
y el SQL estándar que el curso enseña se lleva a Postgres con un trabajo acotado. MariaDB es un fork
que ya divergió lo suficiente como para no ser un reemplazo directo, y el curso lo deja fuera.

> 🧭 **El riesgo no está solo en MySQL.** En Alameda, el portal de 2013 corre **MySQL 5.7, fuera de
> soporte desde el 31/10/2023**. Ese es el riesgo concreto del laboratorio hoy, y no depende de lo que
> haga Oracle en 2027.

---

## ❓ Qué preguntar, y a quién

| Pregunta | A quién | Por qué |
|---|---|---|
| ¿Qué licencia tiene el motor que voy a medir, y qué dice sobre *benchmarks*? | el texto de la licencia, y a legales si hay dudas | Free y Developer no tienen las mismas condiciones que tu contrato |
| ¿Puedo compartir este número fuera de la empresa? | legales, con el contrato de la empresa en la mano | la cláusula prohíbe divulgarlo a terceros, no medirlo |
| ¿Puedo usar Oracle Free para formar a otros? | legales; la frase está en los *Free Use Terms* | exige una autorización expresa que no se encontró |
| ¿Quién mantiene este motor en 2031? | las notas de versión, la hoja de soporte del fabricante y la actividad del repositorio | la respuesta cambia con los años, como con MySQL |

---

## 🧭 Cuándo usar qué

| Situación | Qué haces | Por qué |
|---|---|---|
| Mediste algo en Postgres o MySQL | lo publicas con los cinco datos de una medición | sus licencias no lo restringen |
| Mediste algo en Oracle o SQL Server | lo guardas para ti, y publicas la apuesta sin resolver | cláusula en SQL Server; decisión del curso en Oracle |
| Un plan de Oracle | publicas `EXPLAIN PLAN` sin ejecutar, nunca `ALLSTATS` | estructura sí, estadísticas no |
| Un error de Oracle | lo publicas literal en `a08` | un mensaje no es un resultado |
| Vas a armar un curso con Oracle Free | consultas antes la frase de *third party training* | el texto exige autorización expresa |
| Eliges motor para cinco años | miras soporte, actividad y gobierno, no solo funciones | el caso MySQL de 2025–2026 |

---

## ⚠️ Advertencias

- **Los textos cambian.** Todo lo citado aquí es del 12/10/2026. Antes de apoyarte en una cláusula,
  vuelve a leerla en la fuente.
- **Los contratos de empresa no son públicos.** Lo que dice el tuyo puede no coincidir con ningún texto
  de este apéndice.
- **Que una licencia no restrinja publicar no hace correcto un número.** Un resultado de Postgres sin
  los cinco datos de una medición sigue sin publicarse en este curso.

---

## 📚 Referencias

> ⚠️ Las URL y sus contenidos cambian. Todas se consultaron el 12/10/2026.

- **Licencia de SQL Server 2025 Developer, Express y Evaluation** —
  https://www.microsoft.com/content/dam/microsoft/usetm/documents/sql-server/sql-server-2025-developer%2c-express%2c-evaluation/retail/SQL_Server_2025_Developer_Express_and_Evaluation_Edition_English.pdf
  — el PDF del 05/12/2025, con la §5.
- **Ediciones de SQL Server 2025** — https://learn.microsoft.com/en-us/sql/sql-server/editions-and-components-of-sql-server-2025
  — los límites de Express y qué es cada Developer.
- **Oracle Free Use Terms and Conditions** — https://www.oracle.com/downloads/licenses/oracle-free-license.html
  — sin cláusula de *benchmark*, con la de *third party training*.
- **Licencias de Oracle AI Database 26ai** — https://docs.oracle.com/en/database/oracle/oracle-database/26/dblic/Licensing-Information.html
  — Free y sus límites de 2 CPU, 2 GB y 12 GB.
- **Oracle Technology Network License Agreement** — https://www.oracle.com/downloads/licenses/standard-license.html
  — un texto público de Oracle que sí tiene la cláusula.
- **La licencia de PostgreSQL** — https://www.postgresql.org/about/licence/
- **La licencia comercial de MySQL** — https://www.mysql.com/about/legal/licensing/oem/ — el modelo
  dual, GPLv2 y comercial.
- **Versiones de MySQL: LTS e Innovation** — https://dev.mysql.com/doc/refman/9.7/en/mysql-releases.html
  — y la numeración por calendario.
- **Fechas de soporte de MySQL** — https://endoflife.date/mysql — 9.7 hasta 2031 y 2034; 5.7, fuera
  desde 2023.
- **La SSPL de MongoDB** — https://www.mongodb.com/legal/licensing/server-side-public-license
- **The Register, 11/09/2025** — https://www.theregister.com/2025/09/11/oracle_slammed_for_mysql_job/
  — los despidos en el equipo de MySQL.
- **The Register, 16/02/2026** — https://www.theregister.com/2026/02/16/oracle_new_era_mysql/ — la
  "nueva etapa" que anunció Oracle.
- **La carta abierta de Percona, 17/02/2026** — https://www.percona.com/blog/an-open-letter-to-oracle-lets-talk-about-mysqls-future/
- **InfoWorld, 19/02/2026** — https://www.infoworld.com/article/4134394/community-push-intensifies-to-free-mysql-from-oracles-control-amid-stagnation-fears.html
  — las firmas de la carta y las cifras de actividad.

**Orden sugerido:** la tabla del principio la primera vez; la sección de lo que sí se publica cuando
escribas tu primera medición de Oracle; el riesgo de MySQL cuando tengas que defender un motor ante un
comité.

---

## 🧪 Ejercicios (5)

## 🟢 Fácil — leer las licencias (1–2)

### 🟢 Ejercicio 1 — La cláusula, en su fuente

Abre la licencia de SQL Server 2025 y los *Free Use Terms* de Oracle, y busca en los dos `benchmark`.

**Objetivo:** citar la sección exacta donde aparece en uno, y demostrar que no aparece en el otro,
con la fecha de actualización de cada texto.

[Solución](soluciones/a09-licencias-publicacion-y-riesgo.md#ejercicio-1)

### 🟢 Ejercicio 2 — ¿Se publica o no?

Clasifica estas seis salidas como publicables o no, según la regla del curso: el tiempo de arranque
del contenedor de Oracle; la estructura de un plan de Oracle con `TABLE ACCESS FULL`; los `consistent
gets` de esa misma consulta; el mensaje de `ORA-03113`; el tiempo de `lab load` en Oracle; y las
lecturas de un plan de MySQL.

**Objetivo:** las seis clasificadas, cada una con la razón en una línea.

[Solución](soluciones/a09-licencias-publicacion-y-riesgo.md#ejercicio-2)

## 🟡 Intermedio — aplicarlo (3–4)

### 🟡 Ejercicio 3 — La apuesta sin resolver

Mediste en tu máquina que una consulta lee el doble de bloques en Oracle que en Postgres, y quieres
contarlo en un artículo.

**Objetivo:** reescribir el hallazgo como apuesta sin resolver: hipótesis, condiciones, comando y la
documentación que explica el mecanismo, sin ningún número de Oracle.

[Solución](soluciones/a09-licencias-publicacion-y-riesgo.md#ejercicio-3)

### 🟡 Ejercicio 4 — Tu contrato

Escribe las tres preguntas que le harías al área legal de tu empresa antes de publicar una comparación
entre el Oracle de producción y Postgres.

**Pregunta:** ¿qué documento le pedirías que mire, y por qué los *Free Use Terms* no sirven para
contestarlas?

[Solución](soluciones/a09-licencias-publicacion-y-riesgo.md#ejercicio-4)

## 🟠 Difícil — el riesgo (5)

### 🟠 Ejercicio 5 — El plan de salida del portal

El portal de Alameda corre MySQL 5.7. Con las fechas de este apéndice, propón qué hacer con él en los
próximos cinco años.

**Objetivo:** un plan de media página con tres opciones (MySQL 9.7 LTS, Percona Server, Postgres), el
riesgo de cada una con su fecha y la que elegirías, sin descalificar ninguna sin un dato.

[Solución](soluciones/a09-licencias-publicacion-y-riesgo.md#ejercicio-5)

---

> 🏷️ **Este apéndice no lleva tag propio.** Es consulta rápida: lo que salga de leerlo se commitea con
> el prefijo de la fase desde la que se llegó.
