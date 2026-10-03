# 📎 Propuesta de apéndices y alcance
## Ruta SQL — diez apéndices transversales y uno del track

> **Qué es este documento:** qué cubre cada apéndice, qué deja fuera, cuándo se escribe y cuántos
> ejercicios lleva. Los prompts de [`prompts-de-apendice.md`](prompts-de-apendice.md) copian de
> aquí.
> **Precedencia:** debajo del [alcance](alcance-del-proyecto.md) y de la
> [guía](guia-de-estilo-y-convenciones.md), al mismo nivel que la
> [propuesta de fases](propuesta-fases-y-alcance.md).
> **Fecha:** 30/09/2026. **Derivado de** la propuesta de apéndices de la Ruta NoSQL Lite.

---

## 1. 🧭 Qué es un apéndice en este curso

Un apéndice **no se lee de corrido**: se entra por el índice buscando algo concreto y se sale. Es
receta, referencia o registro, y nunca pedagogía. Sus horas no cuentan dentro de las 252.

Cuatro reglas lo mantienen en su sitio:

- **Un apéndice no repite lo que explica una fase: la enlaza.** Si dos documentos explican lo mismo,
  uno de los dos está mal.
- **Los de infraestructura no enseñan Docker.** Comandos y nada más.
- **Nada sin ejecutar.** Lo no verificado se declara con esas palabras.
- **La regla de publicación también vale aquí** (guía §6.1). Un apéndice puede enseñar a leer un
  plan de Oracle, pero no publica lecturas de Oracle.

---

## 2. 📊 Los once, de un vistazo

| # | Archivo | Qué es | h | Ej. | Cuándo se escribe | Tag |
|---|---|---|---|---|---|---|
| a01 | `a01-laboratorio-contenerizado.md` | tres plataformas, Docker y Podman, emulación | 3 | 8 | antes de F01 | — |
| a02 | `a02-compose-de-la-ruta.md` | el `compose.yaml`, digests, perfiles y RAM | 2 | 6 | antes de F01 | ✅ |
| a03 | `a03-clis-de-los-motores.md` | `psql`, `mysql`, SQLcl y `sqlplus` | 2 | 8 | esqueleto antes de F01; crece | — |
| a04 | `a04-el-arnes-de-forma.md` | cómo se mide en cada motor, y `lab race` | 3 | 8 | esqueleto antes de F01; crece | — |
| a05 | `a05-la-caja-y-el-generador.md` | la caja, el generador, los perfiles y la verdad | 3 | 6 | antes de F01 | ✅ |
| a06 | `a06-python-java-y-drivers.md` | `uv`, los tres drivers y el Java mínimo | 2 | 6 | antes de F01 | — |
| a07 | `a07-diccionario-y-glosario.md` | traducción entre motores, desde Access y la Lite, y el glosario de Alameda | 2 | 6 | esqueleto antes de F03; crece | — |
| a08 | `a08-catalogo-de-errores.md` | documento vivo: errores con mensaje literal | 3 | 10 | esqueleto en F01; crece | — |
| a09 | `a09-licencias-publicacion-y-riesgo.md` | la cláusula DeWitt, las ediciones gratuitas y el futuro de MySQL | 1 | 5 | antes de F03 | — |
| a10 | `a10-el-access-de-museo.md` | opcional: el `.accdb` sin Office, el `.bas` en LibreOffice | 2 | 6 | al final | ✅ |
| ssa-01 | `ssa-01-que-cambia-en-windows.md` | track: SQL Server fuera del contenedor Linux | 1 | 6 | con el track | — |

Los nombres de archivo son canónicos y no se renumeran.

---

## 3. 🐳 a01 — Laboratorio contenerizado (3 h · 8 ejercicios)

- **Alcance:** Windows 11 con WSL2 (dónde viven los archivos y por qué `/mnt/c` hunde el
  rendimiento); macOS arm64 con Docker Desktop, Podman o Colima, y **la tabla de emulación**: qué
  imagen del curso corre nativa en arm64 y cuál no (SQL Server seguro no; Oracle Free, a verificar);
  Linux, en media página. El ciclo `up`/`ps`/`logs`/`exec`/`down`/`down -v`, una línea cada uno. Las
  tres diferencias de Podman que muerden. Límites de memoria por servicio, que aquí deciden si Oracle
  entra al lado de los otros dos. Recuperar disco.
- **No entra:** qué es una imagen, capas, redes, `Dockerfile`, *registries*. Todo eso está en
  `cursos-contenedores-cloud-infra/docker-container-legacy/`.
- **Depende de:** la verificación de laboratorio (P8). Hereda la estructura del `a01` de la Lite.

## 4. 🧩 a02 — El `compose.yaml` de la ruta (2 h · 6 ejercicios)

- **Alcance:** perfiles (`base` con Postgres siempre arriba, `contraste` con MySQL, `oracle`, `mongo`
  para F20, `api` para F23, `puente` con broker y servicio Java para el boss del puente,
  `sqlserver` para el track);
  **digests fijados** con su tag en comentario y fecha de verificación (**este apéndice es el único
  sitio del curso donde vive una versión**); *healthchecks*; volúmenes nombrados; y **la tabla de
  RAM medida**: qué combinaciones de perfiles entran en 16 GB.
- **No entra:** orquestación, secretos, despliegue.
- **Deja en el repositorio:** `src/lab/compose.yaml`. Lleva tag `apendice-a02-compose`.
- **Bloqueado por:** P8. Sin digests medidos no se escribe.

## 5. ⌨️ a03 — CLIs de los motores (2 h · 8 ejercicios)

- **Alcance:** `psql` (los metacomandos que el curso usa, `\timing` como contexto y no como
  argumento, `\watch`), el cliente `mysql`, **SQLcl** y `sqlplus` para Oracle. Conectar, cambiar de
  esquema, ver un plan, salir. Crece con el curso: cada fase que usa un comando nuevo lo agrega.
  `sqlcmd` va en `ssa-01`.
- **No entra:** clientes gráficos, salvo una mención de DBeaver para `a10`.

## 6. 📐 a04 — El arnés de forma (3 h · 8 ejercicios)

- **Alcance:** cómo se mide en cada motor, y qué significa cada campo. Postgres: `EXPLAIN (ANALYZE,
  BUFFERS, WAL)`, `pg_stat_statements`, `pg_stat_user_tables`, `pgstattuple`, el tamaño de relaciones
  e índices. MySQL: `EXPLAIN ANALYZE`, `EXPLAIN FORMAT=TREE`, los contadores `Handler_%`,
  `performance_schema`. Oracle: `EXPLAIN PLAN` y `DBMS_XPLAN` para la **estructura**, y cómo se
  ejecuta la apuesta sin resolver. El comando `lab measure` y su salida. Y **`lab race`**, el
  intercalado determinista de sesiones para el Bloque III (D14).
- **Crece con el curso:** cada fase que mide algo nuevo agrega su receta.
- **No entra:** herramientas de monitoreo, ni APM, ni dashboards.

## 7. 📦 a05 — La caja y el generador (3 h · 6 ejercicios)

- **Alcance:** qué trae la caja y por qué cada pieza es verosímil (alcance §7.1); el generador con
  semilla y **cómo produce la suciedad** con las proporciones de la historia; los perfiles S, M y L
  con sus conteos (D4: **S por defecto**, M para medir, L nunca por defecto, y M dentro de 16 GB con
  los tres motores, calibrado en P8); **la verdad del generador**: qué registros son la misma
  persona, qué valor quiso escribir cada equipo, y cómo se consulta para medir una limpieza o una
  deduplicación; el comando `lab load`, que carga `legacy` **donde hace falta** (D13): en Postgres
  siempre, y en MySQL y Oracle solo las tablas que pide cada fase. Las dos
  codificaciones, a propósito.
- **Deja en el repositorio:** `src/lab/generator/` y la caja generada no se versiona (se regenera).
  Lleva tag `apendice-a05-la-caja`.
- **No entra:** los cargadores del modelo nuevo, que los escribe cada fase.

## 8. 🐍 a06 — Python, Java y los drivers (2 h · 6 ejercicios)

- **Alcance:** `uv` y el `uv.lock`; los drivers de Python de los tres motores (psycopg 3 para
  Postgres; el de MySQL y `python-oracledb` en modo *thin*, que no necesita Instant Client, a
  verificar en P8); cómo cada uno maneja transacciones y *autocommit*, que en el Bloque III importa;
  y el **Java mínimo** (D11): Java 21, Maven y ejecutar un solo archivo sin proyecto, para el boss
  del puente y `a10`.
- **No entra:** ORMs. Si una fase necesita mostrar lo que genera un ORM, lo muestra como SQL.

## 9. 📖 a07 — Diccionario de traducción y glosario (2 h · 6 ejercicios)

- **Alcance:** en **las dos direcciones**:
  - **Access y T-SQL → Postgres, MySQL y Oracle**: autonumérico, `DMax`, campo multivalor, `Memo`,
    objeto OLE, `NOCHECK`, `IDENTITY`, `NEWID()`.
  - **Entre los tres motores**: tipos, `LIMIT`/`FETCH FIRST`, secuencias, `ON CONFLICT`/`ON
    DUPLICATE KEY`/`MERGE`, niveles de aislamiento con su nombre y su comportamiento real.
  - **Relacional ↔ NoSQL Lite**: lo que F19–F21 enlazan.
  - **El glosario de Alameda**: obra social, prepaga, nomenclador, UB, protocolo, débito,
    determinación, práctica, convenio, con su equivalente en otros países y su entidad en inglés.
  - **MariaDB**, con la nota de por qué queda fuera.
- **Crece con el curso.**

## 10. 🧯 a08 — Catálogo de errores (3 h · 10 ejercicios)

- **Documento vivo** (guía §15): mensaje exacto, motor y versión, qué lo provocó, cómo se confirma y
  cómo se sale. **Los mensajes de Oracle y SQL Server se publican**: un mensaje de error no es un
  resultado de rendimiento.
- **Meta:** cincuenta entradas al cierre, repartidas entre los tres motores (alcance §14).
- **Ejercicios:** provocar un error a propósito y reconocerlo por su mensaje.

## 11. ⚖️ a09 — Licencias, publicación y riesgo (1 h · 5 ejercicios)

- **Alcance:** **la cláusula DeWitt** en las licencias de Oracle Database y SQL Server, citada del
  texto de la licencia vigente, y cómo la aplica el curso (guía §6.1); qué permiten Oracle Free, SQL
  Server Developer y Express (límites de CPU, RAM y tamaño, y el uso que no es de desarrollo); la
  licencia de Postgres, la GPL de MySQL y su modelo comercial; y **el riesgo a cinco años**: las
  señales de desinversión de Oracle en MySQL desde 2025, dichas con fuentes y sin dramatismo.
- **No entra:** asesoramiento legal. Se dice con esas palabras.

## 12. 🏛️ a10 — El Access de museo (2 h · 6 ejercicios) · opcional

- **Alcance:** lo que el taller comprobó el 29/09/2026, puesto como receta: generar el `.accdb` con
  Jackcess desde la misma semilla, consultarlo con UCanAccess o con `mdbtools`, abrirlo con DBeaver,
  y **ejecutar el `.bas` de Rubén en LibreOffice Basic** para ver que el parser depende de la
  configuración regional (40 de 40 aserciones en `es-AR`, 31 de 40 en `en-US`, 39 de 40 con la
  ventana de años de LibreOffice). Los límites conocidos: sin campos multivalor, sin adjuntos, sin
  VBA dentro del archivo. El plan B, una base de LibreOffice Base, si Jackcess deja de servir.
- **Deja en el repositorio:** `src/a10-el-access-de-museo/`, que recibe el contenido de
  `taller/accdb-museo/` (D15), sin `lib/` ni `out/`. Lleva tag `apendice-a10-access-de-museo`.
- **Regla de oro:** nadie lo necesita para hacer el curso. El insumo oficial es la caja en CSV.

## 13. 🪟 ssa-01 — Qué cambia en Windows (1 h · 6 ejercicios) · track

- **Alcance:** autenticación integrada, WSFC contra Pacemaker, SSMS, `sqlcmd`, y las funciones que
  no existen en SQL Server para Linux. Operación, no motor.
- **No entra:** instalar SQL Server en Windows paso a paso.

---

## 14. 📌 Pendientes de este documento

- **a01, a02, a05 y a06 están bloqueados por P8**, la verificación de laboratorio.
- **El nombre del driver de MySQL para Python** se decide en P8, entre el conector oficial y PyMySQL,
  por su comportamiento con transacciones y con `LOAD DATA`.
- **El texto exacto de la cláusula de las licencias** se cita en `a09` desde la licencia vigente, no
  de memoria.
