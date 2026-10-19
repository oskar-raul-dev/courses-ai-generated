# 📎 Apéndice a03 — CLIs de los motores

> **Curso:** Ruta SQL · Consulta rápida · **2 h**
> **Usado por:** todas las fases · **Versiones cubiertas:** las del `compose.yaml` del curso, que
> fija el apéndice [`a02`](a02-compose-de-la-ruta.md#-las-versiones-del-curso)
> **Fecha de verificación ejecutada:** la de cada sección; lo de correr archivos, `\timing`, `\watch` y
> los ejercicios, el 18/10/2026 con el perfil M. **Estado:** abierto el 12/10/2026 con lo que usa la
> Fase 01, cerrado el 18/10/2026

**Esto no se lee de corrido.** Se entra por el motor y se sale. Cada sección tiene la misma forma:
conectar desde el contenedor y desde tu máquina, cambiar de esquema entre `legacy` y `alameda`,
pedir un plan, correr un archivo, sacar una consulta a CSV y salir sin dejar la sesión colgada con una
transacción abierta.

**Qué queda fuera:** clientes gráficos (salvo una mención de DBeaver para el
[Access de museo](a10-el-access-de-museo.md)), administración, usuarios y permisos, y `sqlcmd`, que va con
el track de SQL Server: sus dos versiones y la opción que viene apagada están en
[`ssa-01`](ssa-01-que-cambia-en-windows.md#-las-herramientas-ssms-vs-code-y-los-dos-sqlcmd). **Solo entra
lo que el curso usa**: este apéndice nunca se convierte en el manual de `psql`.

---

## Índice

| Motor | CLI | Estado |
|---|---|---|
| [PostgreSQL (`base`)](#-postgresql--psql) | `psql` | ✅ conectar y planes, 12/10/2026; archivos, CSV, `\timing` y `\watch`, 18/10/2026 |
| [MySQL (`contraste`)](#-mysql--mysql) | `mysql` | ✅ conectar y planes, 12/10/2026; archivos y CSV, 18/10/2026 |
| [Oracle (`oracle`)](#️-oracle--sqlplus) | `sqlplus`, el que trae la imagen | ✅ conectar y planes, 12/10/2026; archivos, CSV y `EXIT`, 18/10/2026 |
| [Correr un archivo en los tres](#-correr-un-archivo-en-los-tres) | — | ✅ 18/10/2026 |
| [Cuándo usar qué](#-cuándo-usar-qué) | — | — |
| [Ejercicios](#-ejercicios-8) | — | ocho |

**Todos se usan desde adentro del contenedor**, con `docker compose exec` desde `src/lab/`: así no hace
falta instalar ningún cliente en tu máquina. Si tienes uno instalado, conéctalo a `127.0.0.1` con el
puerto de [`a02`](a02-compose-de-la-ruta.md#-puertos-y-variables). Para pasarle un archivo por la entrada
estándar, `exec` lleva `-T`.

---

## 🐘 PostgreSQL · `psql`

Verificado el 12/10/2026 con el perfil M cargado.

```text
$ docker compose exec postgres psql -U postgres -d alameda
alameda=# \dn
      List of schemas
  Name  |       Owner
--------+-------------------
 lab    | postgres
 legacy | postgres
 public | pg_database_owner
 truth  | postgres
(4 rows)
```

**Cambiar de esquema** es cambiar el `search_path`: `SET search_path = legacy;` y desde ahí
`SELECT count(*) FROM "Pacientes";` sin el prefijo. Las comillas no se van: los nombres de la caja
tienen mayúsculas.

> ⚠️ **Los patrones de `\dt` también pasan a minúsculas.** `\dt legacy.Pac*` no encuentra nada, y
> `\dt legacy."Pac*"` tampoco, porque dentro de las comillas el `*` es literal. Lo que funciona es
> citar solo la parte con mayúsculas y dejar el comodín afuera:
>
> ```text
> alameda=# \dt legacy."Pac"*
>  Schema |             Name             | Type  |  Owner
> --------+------------------------------+-------+----------
>  legacy | Pacientes                    | table | postgres
>  legacy | Pacientes_Duplicados_Revisar | table | postgres
>  legacy | Pacientes_Fusionar           | table | postgres
>  legacy | Pacientes_bak_20140312       | table | postgres
> ```

**Una fila ancha se lee con `\x`**, que muestra cada columna en su propia línea:

```text
alameda=# \x
Expanded display is on.
alameda=# SELECT * FROM "Pacientes" WHERE "IdPaciente" = 5;
-[ RECORD 1 ]-----------------------------
IdPaciente  | 5
Nombre      | RAMIREZ NELIDA ROMINA INSSJP
DNI         | 10.619.295
FechaNac    | 1953-06-29 00:00:00
Edad        | 43 años
…
```

**Un plan** se pide con `EXPLAIN (ANALYZE, BUFFERS)` delante de la consulta, y se lee como en
[`a04`](a04-el-arnes-de-forma.md). **Se sale** con `\q`; si una transacción quedó abierta, `psql` la
deshace al salir: un `BEGIN; CREATE TABLE lab.a03_q …; \q` no deja la tabla.

**`\timing` es contexto, no argumento.** Muestra cuánto tardó cada sentencia, medido desde el cliente:

```text
alameda=# \timing on
alameda=# SELECT count(*) FROM legacy."Protocolos";
Time: 1424.053 ms (00:01.424)
alameda=# SELECT count(*) FROM legacy."Protocolos";
Time: 55.450 ms
alameda=# SELECT count(*) FROM legacy."Protocolos";
Time: 22.751 ms
```

Las tres son la misma consulta sobre las mismas 1.327.622 filas, el 18/10/2026; la primera, con la caché
fría después de que otro programa de la máquina se llevó la memoria. Un número de `\timing` dice qué pasó
esa vez, y por eso el curso mide la **forma** (filas, bloques, plan) con `lab measure`
([`a04`](a04-el-arnes-de-forma.md)) y usa el tiempo solo como contexto.

**`\watch` repite la última consulta**, y sirve para mirar algo que cambia mientras otra sesión trabaja,
como las sesiones abiertas durante una carrera de la [Fase 15](15-aislamiento-comparado.md). `i` es el
intervalo en segundos y `c` cuántas veces:

```text
alameda=# SELECT count(*) AS sesiones FROM pg_stat_activity WHERE datname = current_database() \watch i=1 c=3
Mon 19 Oct 2026 01:51:37 AM UTC (every 1s)

 sesiones
----------
        2
…
```

**Una consulta a CSV**, sin pasar por un archivo del servidor, se saca con `\copy` hacia la salida
estándar:

```bash
docker compose exec -T postgres psql -U postgres -d alameda \
  -c '\copy (SELECT "IdPaciente", "DNI" FROM legacy."Pacientes" ORDER BY 1 LIMIT 3) TO STDOUT WITH (FORMAT csv, HEADER)'
```

```text
IdPaciente,DNI
1,19056268
2,40.021.044
3,25024554
```

## 🐬 MySQL · `mysql`

Verificado el 12/10/2026 con cuatro tablas de M cargadas.

```text
$ docker compose exec mysql mysql -uroot -plab
mysql> USE legacy;
mysql> SHOW TABLES;
+------------------+
| Tables_in_legacy |
+------------------+
| Pacientes        |
| Practicas        |
| Protocolos       |
| ResultadoItem    |
+------------------+
```

**En MySQL, un esquema y una base son la misma cosa**: `legacy` aparece en `SHOW DATABASES` al lado de
`lab`, y `USE legacy` es el equivalente del `search_path` de Postgres. Los nombres no llevan comillas
dobles: si hicieran falta, son acentos graves (`` `Errores de pegado` ``). Para filtrar la lista:
`SHOW TABLES FROM legacy LIKE 'Pro%'`.

**Un plan** se pide con `EXPLAIN ANALYZE` delante de la consulta. **La salida vertical** se pide con
`\G` al final de la sentencia en una sesión interactiva; cuando le pasas un script por la entrada
estándar, el cliente no acepta `\G` y hay que usar la opción `-E`. **Se sale** con `exit` en una sesión
interactiva; en un script, `exit` no es un comando del cliente (da `ERROR 1064 … near 'exit'`), y basta
con que el archivo termine. Si queda una transacción abierta al terminar, MySQL la deshace.

**Una consulta separada por tabuladores** sale con `-B`, que quita los bordes de la tabla:

```text
$ docker compose exec -T mysql mysql -uroot -plab -B -e 'SELECT IdPaciente, DNI FROM legacy.Pacientes ORDER BY 1 LIMIT 3'
IdPaciente	DNI
1	19056268
2	40.021.044
3	25024554
```

La advertencia `Using a password on the command line interface can be insecure` sale por la salida de
error en cada llamada con `-plab`; en el laboratorio es ruido, en un servidor real es un aviso.

## 🏛️ Oracle · `sqlplus`

Verificado el 12/10/2026 con cuatro tablas de M cargadas.

```text
$ docker compose exec oracle sqlplus -s system/lab@FREEPDB1
SQL> ALTER SESSION SET CURRENT_SCHEMA = LEGACY;

Session altered.

SQL> SELECT count(*) FROM "Pacientes";

  COUNT(*)
----------
    242427
```

`FREEPDB1` es la base enchufable donde vive todo lo del curso; `-s` quita el encabezado de `sqlplus`.

> ⚠️ **`CURRENT_SCHEMA` cambia cómo se resuelven los nombres, no quién eres.** Después del `ALTER
> SESSION`, `SELECT … FROM "Pacientes"` encuentra la tabla de `LEGACY`, pero `user_tables` sigue
> listando las 31 tablas de `SYSTEM`. Las de la caja se listan con `SELECT table_name FROM all_tables
> WHERE owner = 'LEGACY'`.

**Un plan** se pide con `uv run lab measure --engine oracle`, que corre `EXPLAIN PLAN` y
`DBMS_XPLAN` por ti y devuelve solo la estructura ([`a04`](a04-el-arnes-de-forma.md)). **Se sale** con
`EXIT`, que confirma lo pendiente: en `sqlplus`, **salir hace commit** salvo que digas `EXIT ROLLBACK`.
Comprobado el 18/10/2026: un `INSERT` seguido de `EXIT` deja la fila, y uno seguido de `EXIT ROLLBACK` no.

**Una consulta a CSV** sale con `SET MARKUP CSV ON`, y `SET FEEDBACK OFF` quita la línea de "rows
selected":

```text
SQL> SET MARKUP CSV ON
SQL> SET FEEDBACK OFF
SQL> SELECT "IdPaciente", "DNI" FROM LEGACY."Pacientes" ORDER BY 1 FETCH FIRST 3 ROWS ONLY;
"IdPaciente","DNI"
1,"19056268"
2,"40.021.044"
3,"25024554"
```

**Por qué `sqlplus` y no SQLcl:** SQLcl es el cliente moderno de Oracle, con historial y formatos de
salida, pero no viene en ninguna de las dos imágenes de Oracle Free. `sqlplus` sí, y alcanza para todo lo
que el curso hace. Si tienes SQLcl instalado, los comandos de esta sección funcionan igual.

---

## 📜 Correr un archivo en los tres

Los `01_setup.sql` de las fases se corren pasándole el archivo al cliente por la entrada estándar, desde
`src/lab/`. Lo que importa es **qué hace cada cliente cuando una sentencia falla**, porque los tres hacen
algo distinto. Con un archivo de tres sentencias cuya segunda falla:

| Cliente | Por defecto | Para que se detenga | Código de salida al fallar |
|---|---|---|---|
| `psql` | **sigue** con la tercera, y sale con 0 | `-v ON_ERROR_STOP=1` | 3 |
| `mysql` | **se detiene** en la sentencia que falla | ya lo hace; `--force` lo hace seguir | 1 |
| `sqlplus` | **sigue** con la tercera, y sale con 0 | `WHENEVER SQLERROR EXIT SQL.SQLCODE` al principio del archivo | el código del error, módulo 256 (`ORA-00942` da 174) |

```bash
docker compose exec -T postgres psql -U postgres -d alameda -v ON_ERROR_STOP=1 < 01_setup.sql
docker compose exec -T mysql mysql -uroot -plab < 01_setup_mysql.sql
docker compose exec -T oracle sqlplus -s system/lab@FREEPDB1 < 01_setup_oracle.sql
```

Detenerse no es deshacer. Con `CREATE TABLE`, un `INSERT`, el error y otro `INSERT`:

- **`psql -v ON_ERROR_STOP=1`** deja la tabla con la primera fila. Con **`-1`** además, todo el archivo es
  una transacción, y no deja nada: en Postgres el DDL también es transaccional.
- **`mysql`** deja la tabla con la primera fila, y envolverlo en `START TRANSACTION` no cambia nada,
  porque el `CREATE TABLE` confirma solo lo que había antes y lo que sigue corre en *autocommit*.
- **`sqlplus` con `WHENEVER SQLERROR EXIT FAILURE ROLLBACK`** deshace la fila, pero la tabla queda: el DDL
  de Oracle confirma solo.

🧭 **Un script que tiene que poder correrse dos veces** se escribe para eso, no se confía en el cliente:
`CREATE TABLE IF NOT EXISTS` o `DROP … IF EXISTS` al principio (E-61 en [`a08`](a08-catalogo-de-errores.md)).

---

## 🧭 Cuándo usar qué

| Quieres | Postgres | MySQL | Oracle |
|---|---|---|---|
| conectarte | `psql -U postgres -d alameda` | `mysql -uroot -plab` | `sqlplus -s system/lab@FREEPDB1` |
| cambiar de esquema | `SET search_path = legacy` | `USE legacy` | `ALTER SESSION SET CURRENT_SCHEMA = LEGACY` |
| listar tablas | `\dt legacy."Pac"*` | `SHOW TABLES FROM legacy LIKE 'Pac%'` | `all_tables WHERE owner = 'LEGACY'` |
| una fila ancha | `\x` | `\G`, o `-E` en un script | `SET LINESIZE`, o una columna por consulta |
| el plan | `EXPLAIN (ANALYZE, BUFFERS)` | `EXPLAIN ANALYZE` | `lab measure --engine oracle` |
| correr un archivo que se detenga | `-v ON_ERROR_STOP=1` (y `-1`) | lo que hace solo | `WHENEVER SQLERROR EXIT …` |
| una consulta a CSV | `\copy (…) TO STDOUT WITH (FORMAT csv, HEADER)` | `-B` (tabuladores) | `SET MARKUP CSV ON` |
| mirar algo que cambia | `\watch i=1 c=n` | — | — |
| salir sin confirmar | `\q` deshace | terminar deshace | `EXIT ROLLBACK`; `EXIT` **confirma** |
| SQL Server | — | — | `sqlcmd`, en [`ssa-01`](ssa-01-que-cambia-en-windows.md#-las-herramientas-ssms-vs-code-y-los-dos-sqlcmd) |

---

## ⚠️ Advertencias

- **`sqlplus` confirma al salir.** Es la diferencia que más daño hace: lo que en `psql` se perdería al
  cerrar, en `sqlplus` queda escrito.
- **`psql` sigue después de un error** si no le dices otra cosa, y sale con 0. Un script de carga sin
  `ON_ERROR_STOP` puede fallar a la mitad y parecer que anduvo.
- **La contraseña en la línea de comandos** es aceptable en el laboratorio, donde es `lab` y escucha en
  `127.0.0.1`. En cualquier otro lado, no.

---

## 📚 Referencias

> ⚠️ Las URL y sus contenidos cambian. Todas se consultaron el 18/10/2026.

- **`psql`** — https://www.postgresql.org/docs/current/app-psql.html — `ON_ERROR_STOP`, `-1`, `\copy`,
  `\watch` y `\timing`.
- **El cliente `mysql`** — https://dev.mysql.com/doc/refman/9.7/en/mysql.html — `-B`, `-E` y `--force`.
- **SQL\*Plus** — https://docs.oracle.com/en/database/oracle/oracle-database/26/sqpug/ — `WHENEVER
  SQLERROR`, `EXIT` y `SET MARKUP CSV`.
- **SQLcl** — https://www.oracle.com/database/sqldeveloper/technologies/sqlcl/

**Orden sugerido:** la sección del motor que vas a usar la primera vez; la de correr un archivo antes del
primer `01_setup.sql`; la tabla de cuándo usar qué, de ahí en adelante.

---

## 🧪 Ejercicios (8)

Todos desde `src/lab/`, con el perfil M cargado (en MySQL y Oracle, `--tables
Pacientes,Protocolos,ResultadoItem,Practicas`).

## 🟢 Fácil — conectar y mirar (1–3)

### 🟢 Ejercicio 1 — La misma cuenta en los tres

Conéctate a los tres motores y cuenta las filas de `Pacientes` de la caja.

**Objetivo:** el comando de conexión, la consulta y el resultado de cada uno, que tiene que ser el mismo.

[Solución](soluciones/a03-clis-de-los-motores.md#ejercicio-1)

### 🟢 Ejercicio 2 — Las tablas que empiezan con «Pro»

Lista las tablas de la caja cuyo nombre empieza con `Pro` en cada motor.

**Pregunta:** ¿por qué Postgres muestra siete y MySQL y Oracle muestran una? ¿Qué patrón de `\dt` usaste?

[Solución](soluciones/a03-clis-de-los-motores.md#ejercicio-2)

### 🟢 Ejercicio 3 — Tres pacientes en CSV

Saca a CSV (o separado por tabuladores, en MySQL) los tres primeros pacientes por `IdPaciente`, con su
DNI, en los tres motores.

**Objetivo:** el comando y la salida de cada uno; ¿cuál pone comillas y dónde?

[Solución](soluciones/a03-clis-de-los-motores.md#ejercicio-3)

## 🟡 Intermedio — scripts (4–5)

### 🟡 Ejercicio 4 — La sentencia que falla

Escribe un archivo con tres sentencias para cada motor: un conteo de `Pacientes`, un conteo de una tabla
que no existe y un `SELECT` de un literal. Córrelo en los tres, primero tal cual y después configurado
para que se detenga.

**Objetivo:** qué sentencias corrió cada cliente, con qué código de salida terminó, y qué cambiaste para
que se detenga.

[Solución](soluciones/a03-clis-de-los-motores.md#ejercicio-4)

### 🟡 Ejercicio 5 — El mismo conteo, tres tiempos

Con `\timing on`, cuenta las filas de `legacy."Protocolos"` tres veces seguidas.

**Pregunta:** ¿cuánto dio cada vez? ¿Cuál de los tres números pondrías en una medición, y por qué la
respuesta del curso es ninguno?

[Solución](soluciones/a03-clis-de-los-motores.md#ejercicio-5)

## 🟠 Difícil — transacciones y salidas (6–7)

### 🟠 Ejercicio 6 — La sesión que quedó abierta

Abre una sesión de `psql`, haz `BEGIN` y un `SELECT` cualquiera, y déjala así. Desde otra sesión, mira con
`\watch` en qué estado está la primera según `pg_stat_activity`.

**Objetivo:** la consulta que vigilas, el estado que ves (y cómo cambia al cerrar la primera), y por qué a
la [Fase 17](17-mvcc-y-su-factura.md) le preocupa ese estado.

[Solución](soluciones/a03-clis-de-los-motores.md#ejercicio-6)

### 🟠 Ejercicio 7 — Salir

En los tres motores, crea una tabla de prueba, abre una transacción, inserta una fila y sal del cliente
sin confirmar. Vuelve a entrar y cuenta las filas. Borra la tabla al terminar.

**Pregunta:** ¿en cuál quedó la fila? ¿Qué escribes en ese cliente para salir sin confirmar?

[Solución](soluciones/a03-clis-de-los-motores.md#ejercicio-7)

## 🔴 Muy difícil — un script que no deje nada a medias (8)

### 🔴 Ejercicio 8 — Todo o nada

Un archivo crea una tabla, inserta una fila, falla y quiere insertar otra. Haz que en cada motor el
cliente se detenga en el error y que **no quede nada**: ni la fila, ni la tabla.

**Objetivo:** el comando o la cabecera en cada motor, lo que queda después de correrlo (compruébalo), y
en cuáles no se puede lograr solo con el cliente, y qué haces entonces.

[Solución](soluciones/a03-clis-de-los-motores.md#ejercicio-8)

---

> 🏷️ **Este apéndice no lleva tag propio.** Crece con los commits de las fases que le agregan
> comandos.
