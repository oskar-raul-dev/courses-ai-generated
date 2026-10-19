# ✅ Soluciones — Apéndice a03: CLIs de los motores

> **Curso:** Ruta SQL · Solucionario de [a03](../a03-clis-de-los-motores.md)
> **Ejercicios:** 8 · **Motores:** PostgreSQL 18.6, MySQL 9.7.2 y Oracle AI Database 26ai Free, los de
> [`a02`](../a02-compose-de-la-ruta.md#-las-versiones-del-curso), con el perfil M
> **Fecha de verificación ejecutada:** 18/10/2026

> ⚠️ **Intenta el ejercicio antes de leer su solución.** Leída antes, solo te enseña a reconocerla.

Todos los comandos, desde `src/lab/`.

---

## 🟢 Fácil (1–3)

### Ejercicio 1

```bash
docker compose exec -T postgres psql -U postgres -d alameda -c 'SELECT count(*) FROM legacy."Pacientes"'
docker compose exec -T mysql mysql -uroot -plab -e 'SELECT count(*) FROM legacy.Pacientes'
echo 'SELECT count(*) FROM LEGACY."Pacientes";' | docker compose exec -T oracle sqlplus -s system/lab@FREEPDB1
```

Los tres dan **242.427**. En Postgres y en Oracle el nombre va entre comillas dobles porque tiene
mayúsculas; en MySQL no, porque en Linux el nombre de la tabla es el del archivo y se escribe tal cual.
Si alguno da otro número, no cargó la misma caja: `uv run lab ps` y [`a05`](../a05-la-caja-y-el-generador.md).

### Ejercicio 2

```text
alameda=# \dt legacy."Pro"*
 Schema |        Name        | Type  |  Owner
--------+--------------------+-------+----------
 legacy | Prolactina         | table | postgres
 legacy | ProteinaCReactiva  | table | postgres
 legacy | Proteinograma      | table | postgres
 legacy | ProtocoloPracticas | table | postgres
 legacy | Protocolos         | table | postgres
 legacy | Protocolos_2010    | table | postgres
 legacy | Proveedores        | table | postgres
(7 rows)
```

```text
mysql> SHOW TABLES FROM legacy LIKE 'Pro%';      SQL> SELECT table_name FROM all_tables
Tables_in_legacy (Pro%)                               WHERE owner = 'LEGACY' AND table_name LIKE 'Pro%';
Protocolos                                       Protocolos
```

Postgres tiene **la caja entera**, las 71 tablas; MySQL y Oracle, solo las cuatro que se cargaron con
`--tables`, y de esas solo `Protocolos` empieza con `Pro`. El patrón es `legacy."Pro"*`: la parte con
mayúsculas entre comillas, el comodín afuera. `legacy.Pro*` busca `pro…` en minúsculas y no encuentra
nada.

### Ejercicio 3

```text
$ … psql … -c '\copy (SELECT "IdPaciente", "DNI" FROM legacy."Pacientes" ORDER BY 1 LIMIT 3) TO STDOUT WITH (FORMAT csv, HEADER)'
IdPaciente,DNI
1,19056268
2,40.021.044
3,25024554

$ … mysql … -B -e 'SELECT IdPaciente, DNI FROM legacy.Pacientes ORDER BY 1 LIMIT 3'
IdPaciente	DNI
1	19056268
2	40.021.044
3	25024554

SQL> SET MARKUP CSV ON
SQL> SET FEEDBACK OFF
SQL> SELECT "IdPaciente", "DNI" FROM LEGACY."Pacientes" ORDER BY 1 FETCH FIRST 3 ROWS ONLY;
"IdPaciente","DNI"
1,"19056268"
2,"40.021.044"
3,"25024554"
```

Postgres pone comillas solo cuando el valor las necesita (una coma, un salto de línea, comillas); MySQL no
pone nunca, porque `-B` separa por tabuladores; Oracle pone siempre en el texto y en los encabezados, y
nunca en los números. Un lector de CSV acepta las tres; un `diff` entre ellas, no.

---

## 🟡 Intermedio (4–5)

### Ejercicio 4

| Cliente | Tal cual | Configurado para detenerse |
|---|---|---|
| `psql` | corre las tres; error en la segunda; sale con **0** | `-v ON_ERROR_STOP=1`: corre una y media, sale con **3** |
| `mysql` | corre la primera, falla en la segunda (`ERROR 1146 (42S02) at line 2`) y se detiene; sale con **1** | ya se detiene; `--force` lo hace seguir y salir con 0 |
| `sqlplus` | corre las tres; `ORA-00942` en la segunda; sale con **0** | `WHENEVER SQLERROR EXIT SQL.SQLCODE` en la primera línea: sale con **174** |

El 174 es 942 módulo 256: el sistema operativo solo guarda un byte del código de salida. Para un script
de CI alcanza con saber que no es 0; para saber cuál fue, hay que leer la salida. `WHENEVER SQLERROR EXIT
FAILURE` da 1, que es más fácil de comparar.

### Ejercicio 5

```text
Time: 1424.053 ms (00:01.424)
Time: 55.450 ms
Time: 22.751 ms
```

Las tres veces se leyeron las mismas 1.327.622 filas. La primera fue con la caché fría (otro programa de
la máquina se había llevado la memoria), y la segunda y la tercera, con las páginas en memoria. Ninguna
va en una medición del curso porque **ninguna dice nada sin las demás condiciones**: la memoria libre, lo
que corría al lado, cuántas veces se repitió. El curso mide la forma, que no cambia de una corrida a otra
(filas, bloques, plan, con `lab measure`), y cuando publica un tiempo lo publica con sus cinco datos y
varias corridas ([`a04`](../a04-el-arnes-de-forma.md)). Tus números van a ser otros, y eso es lo que el
ejercicio quería mostrar.

---

## 🟠 Difícil (6–7)

### Ejercicio 6

```sql
SELECT pid, state, now() - xact_start AS en_transaccion, backend_xmin IS NOT NULL AS retiene
FROM pg_stat_activity
WHERE datname = current_database() AND pid <> pg_backend_pid() AND backend_type = 'client backend'
\watch i=2 c=3
```

```text
  pid  |        state        | en_transaccion  | retiene
-------+---------------------+-----------------+---------
 47268 | idle in transaction | 00:00:01.545774 | f
…
 47268 | idle in transaction | 00:00:03.551365 | f
…
(la fila desaparece cuando la primera sesión confirma o se cierra)
```

La primera sesión está **`idle in transaction`**: no corre nada y tiene una transacción abierta, que
`en_transaccion` muestra creciendo. En `READ COMMITTED`, después de su `SELECT` no retiene ninguna foto
(`retiene` es falso); con `BEGIN ISOLATION LEVEL REPEATABLE READ`, la misma sesión da `retiene` verdadero,
porque guarda la foto de toda la transacción. Esa es la que preocupa a la
[Fase 17](../17-mvcc-y-su-factura.md): mientras exista, `VACUUM` no puede limpiar ninguna versión más
nueva que su `backend_xmin`, y la tabla crece. `idle_in_transaction_session_timeout` la corta (E-44 en
[`a08`](../a08-catalogo-de-errores.md)).

### Ejercicio 7

| Cliente | Cómo salió | Filas al volver |
|---|---|---|
| `psql` | `\q` con la transacción abierta | 0 (la tabla tampoco, si se creó dentro del `BEGIN`) |
| `mysql` | el archivo terminó con la transacción abierta | 0 |
| `sqlplus` | `EXIT` | **1** |

En `sqlplus` quedó la fila: **`EXIT` confirma**. Para salir sin confirmar se escribe `EXIT ROLLBACK`
(comprobado: un `INSERT` seguido de `EXIT ROLLBACK` no deja la fila), o `SET EXITCOMMIT OFF` al principio
de la sesión. En MySQL, ojo con escribir `exit` en un archivo: no es un comando del cliente en modo
script, y da `ERROR 1064 … near 'exit'`; la transacción se deshace igual, porque el cliente termina en ese
error.

---

## 🔴 Muy difícil (8)

### Ejercicio 8

```bash
# Postgres: se detiene y no deja nada
docker compose exec -T postgres psql -U postgres -d alameda -v ON_ERROR_STOP=1 -1 < robusto_pg.sql
#   → exit 3; to_regclass('lab.a03_prueba') es NULL: ni tabla ni fila
```

```sql
-- Oracle: la cabecera deshace la fila, pero la tabla queda
WHENEVER SQLERROR EXIT FAILURE ROLLBACK
--   → exit 1; SELECT count(*) FROM a03_prueba da 0
```

```text
-- MySQL: se detiene solo, y deja la tabla con la primera fila, con START TRANSACTION o sin ella
ERROR 1146 (42S02) at line 3: Table 'lab.no_existe' doesn't exist
id
1
```

**Solo Postgres lo logra con el cliente**, porque su DDL es transaccional: `-1` envuelve el archivo en
una transacción, y el `CREATE TABLE` se deshace con el resto. En **Oracle** el `CREATE TABLE` confirma
antes y después de sí mismo, así que `ROLLBACK` deshace la fila pero no la tabla. En **MySQL** pasa lo
mismo, y además el cliente no tiene un "deshacer al fallar".

**Rúbrica para Oracle y MySQL (sobre 3 puntos):** 1 punto por decir que no se puede con el cliente y por
qué (el DDL confirma solo); 1 por una salida que funcione: separar el DDL en su propio archivo,
idempotente (`CREATE TABLE IF NOT EXISTS` en MySQL; en Oracle 23ai y posteriores, también `IF NOT EXISTS`),
y correr los datos en una transacción; o un bloque de compensación que borre lo creado al fallar; 1 por
comprobar lo que quedó después de correrlo, como hace la solución de Postgres.
