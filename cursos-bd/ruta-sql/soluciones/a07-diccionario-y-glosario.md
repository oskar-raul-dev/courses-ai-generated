# ✅ Soluciones — Apéndice a07: Diccionario de traducción y glosario

> **Curso:** Ruta SQL · Solucionario de [a07](../a07-diccionario-y-glosario.md)
> **Ejercicios:** 6 · **Motores:** PostgreSQL 18.6, MySQL 9.7.2 y Oracle AI Database 26ai Free, los de
> [`a02`](../a02-compose-de-la-ruta.md#-las-versiones-del-curso), con el perfil M
> **Fecha de verificación ejecutada:** 18/10/2026

> ⚠️ **Intenta el ejercicio antes de leer su solución.** Leída antes, solo te enseña a reconocerla.

Las salidas de Oracle son conteos y filas de la caja, no tiempos: se publican (la regla está en
[`a09`](../a09-licencias-publicacion-y-riesgo.md)).

---

## 🟢 Fácil (1–2)

### Ejercicio 1

```sql
-- Postgres
SELECT "IdProtocolo", "NroProtocolo", "Fecha" FROM legacy."Protocolos"
ORDER BY "Fecha" DESC, "IdProtocolo" DESC LIMIT 5;
-- MySQL
SELECT IdProtocolo, NroProtocolo, Fecha FROM legacy.Protocolos
ORDER BY Fecha DESC, IdProtocolo DESC LIMIT 5;
-- Oracle
SELECT "IdProtocolo", "NroProtocolo", "Fecha" FROM LEGACY."Protocolos"
ORDER BY "Fecha" DESC, "IdProtocolo" DESC FETCH FIRST 5 ROWS ONLY;
```

```text
 IdProtocolo | NroProtocolo |        Fecha
-------------+--------------+---------------------
    11233733 | C-0597929    | 2026-10-10 00:00:00
    11233732 | C-0597928    | 2026-10-10 00:00:00
    11233731 | A-0166039    | 2026-10-10 00:00:00
    11233730 | A-0166038    | 2026-10-10 00:00:00
    11233729 | J-0152133    | 2026-10-10 00:00:00
```

Las mismas cinco filas en los tres (Oracle muestra la fecha como `10-OCT-26 12.00.00.000 AM`, que es el
formato de su sesión, no otro valor). El `IdProtocolo` en el `ORDER BY` es porque **la caja guarda la
fecha del protocolo sin hora**: todos los del 10/10 empatan, y sin un desempate cada motor puede devolver
cinco distintos, y el mismo motor, cinco distintos en otra corrida. "Los cinco últimos" no existe sin una
clave que rompa el empate ([F03](../03-lo-que-sql-le-hace-al-modelo.md)).

### Ejercicio 2

```sql
-- Postgres
SELECT count(*) FILTER (WHERE "Edad" = '') AS vacio, count(*) FILTER (WHERE "Edad" IS NULL) AS nulo
FROM legacy."Pacientes";
-- MySQL
SELECT SUM(Edad = '') AS vacio, SUM(Edad IS NULL) AS nulo FROM legacy.Pacientes;
-- Oracle
SELECT COUNT(CASE WHEN "Edad" = '' THEN 1 END) AS vacio, COUNT(CASE WHEN "Edad" IS NULL THEN 1 END) AS nulo
FROM LEGACY."Pacientes";
```

| Motor | `= ''` | `IS NULL` |
|---|---|---|
| Postgres | 1.481 | 1.417 |
| MySQL | 2.898 | 0 |
| Oracle | 0 | 2.898 |

Son las mismas 2.898 filas en los tres. La caja distingue el campo entrecomillado vacío (`""`) del campo
sin nada, y **cada carga lo leyó distinto**: Postgres conserva la diferencia; el `LOAD DATA` de MySQL
escribe cadena vacía en los dos casos; Oracle no puede guardar una cadena vacía, porque para Oracle es
`NULL`, y `"Edad" = ''` compara con `NULL` y no da verdadero nunca. La condición que da lo mismo en los
tres es la que no distingue: `WHERE NULLIF("Edad", '') IS NULL`, que da 2.898 en los tres. Ojo con la que
parece equivalente, `coalesce("Edad", '') = ''`: da 2.898 en Postgres y en MySQL y **0 en Oracle**, porque
ahí el `''` del `coalesce` también es `NULL`. Y la lección es la de la [Fase 03](../03-lo-que-sql-le-hace-al-modelo.md): si la
diferencia entre vacío y desconocido importa, no puede depender del motor.

---

## 🟡 Intermedio (3–4)

### Ejercicio 3

```sql
-- Postgres
SELECT count(*) FILTER (WHERE "Nombre" || ' ' || "DNI" IS NULL) AS concat_nula,
       count(*) FILTER (WHERE concat_ws(' ', "Nombre", "DNI") IS NULL) AS concat_ws_nula
FROM legacy."Pacientes";
-- MySQL
SELECT SUM(CONCAT(Nombre, ' ', DNI) IS NULL) AS concat_nula,
       SUM(CONCAT_WS(' ', Nombre, DNI) IS NULL) AS concat_ws_nula FROM legacy.Pacientes;
SELECT Nombre || ' ' || DNI AS con_pipes FROM legacy.Pacientes ORDER BY IdPaciente LIMIT 2;
-- Oracle
SELECT COUNT(CASE WHEN "Nombre" || ' ' || "DNI" IS NULL THEN 1 END) AS concat_nula FROM LEGACY."Pacientes";
```

| Motor | concatenación nula | con `concat_ws` |
|---|---|---|
| Postgres | 24.787 | 0 |
| MySQL | 0 | 0 |
| Oracle | 0 | — |

En T-SQL, `+` con un `NULL` da `NULL`, igual que `||` en Postgres: las 24.787 fichas sin DNI pierden la
etiqueta entera, nombre incluido. En MySQL da 0, pero no por la concatenación: **sus DNI vacíos son
cadena vacía**, no `NULL` (ejercicio 2), y `CONCAT` con un `NULL` también daría `NULL`. En Oracle da 0 por
la regla opuesta: `||` trata `NULL` como cadena vacía. Y en MySQL, `Nombre || ' ' || DNI` devuelve `1`,
porque `||` es un `OR` lógico salvo con `PIPES_AS_CONCAT`. La versión que da la etiqueta en las 242.427
filas de los tres es `concat_ws(' ', "Nombre", "DNI")` en Postgres y MySQL, y `||` en Oracle; en T-SQL,
`CONCAT_WS` desde 2017.

### Ejercicio 4

```sql
-- Postgres                               -- MySQL                                 -- Oracle
SELECT max("IdProtocolo"),                SELECT MAX(IdProtocolo),                 SELECT MAX("IdProtocolo"),
       2147483647 - max("IdProtocolo")           2147483647 - MAX(IdProtocolo)            2147483647 - MAX("IdProtocolo")
FROM legacy."Protocolos";                 FROM legacy.Protocolos;                  FROM LEGACY."Protocolos";
```

```text
   maximo   | quedan
------------+--------
 2147413574 |  70073
```

El mismo resultado en los tres: **quedan 70.073 números**, algo más de cuatro meses al ritmo de 2026 (entre
14.901 y 16.630 protocolos por mes). El máximo salió de la replicación de Jet de 2004, que volvió aleatorios
los autonuméricos durante una semana ([historia](../00-historia-de-alameda.md),
[F10](../10-identificadores.md)); la identidad sigue numerando por los 11 millones (el último de 2026 es el
11.233.733), pero un `DMax + 1` arranca desde el más alto, que está casi en el techo, y en un `integer`
termina en E-32 ([`a08`](../a08-catalogo-de-errores.md)). En lugar del `DMax`: `bigint GENERATED BY DEFAULT AS
IDENTITY` en Postgres y Oracle, `BIGINT AUTO_INCREMENT` en MySQL, y la carga de legacy con su `id`
explícito seguida de `setval` (Postgres) o `START WITH LIMIT VALUE` (Oracle); MySQL ajusta solo. Y si el
número tiene que ser correlativo y sin huecos, ninguno de los tres: es la
[Fase 16](../16-el-folio-sin-huecos.md).

---

## 🟠 Difícil (5)

### Ejercicio 5

```sql
-- Postgres (dentro de BEGIN … ROLLBACK, para no dejar nada)
CREATE TABLE lab.a07_precio (cod_nbu varchar(20) PRIMARY KEY, ub numeric(8,2));
INSERT INTO lab.a07_precio VALUES ('475', 2.00);
INSERT INTO lab.a07_precio (cod_nbu, ub) VALUES ('475', 2.50), ('711', 1.25)
ON CONFLICT (cod_nbu) DO UPDATE SET ub = EXCLUDED.ub;

-- MySQL
CREATE TABLE lab.a07_precio (cod_nbu varchar(20) PRIMARY KEY, ub decimal(8,2));
INSERT INTO lab.a07_precio VALUES ('475', 2.00);
INSERT INTO lab.a07_precio (cod_nbu, ub) VALUES ('475', 2.50), ('711', 1.25) AS n
ON DUPLICATE KEY UPDATE ub = n.ub;
DROP TABLE lab.a07_precio;

-- Oracle
CREATE TABLE a07_precio (cod_nbu VARCHAR2(20) PRIMARY KEY, ub NUMBER(8,2));
INSERT INTO a07_precio VALUES ('475', 2.00);
MERGE INTO a07_precio p
USING (SELECT '475' AS cod_nbu, 2.50 AS ub FROM dual UNION ALL SELECT '711', 1.25 FROM dual) n
ON (p.cod_nbu = n.cod_nbu)
WHEN MATCHED THEN UPDATE SET p.ub = n.ub
WHEN NOT MATCHED THEN INSERT (cod_nbu, ub) VALUES (n.cod_nbu, n.ub);
DROP TABLE a07_precio PURGE;
```

```text
 cod_nbu |  ub
---------+------
 475     | 2.50
 711     | 1.25
```

La misma tabla en los tres. `ON CONFLICT` y `ON DUPLICATE KEY` necesitan **una restricción única** que
detecte el choque: el `INSERT` intenta, el índice choca y el motor actualiza. `MERGE` no: une por la
condición del `ON`, que puede ser cualquier cosa. La diferencia importa con concurrencia: dos `MERGE` a la
vez sobre una fila que no existe pueden intentar insertar los dos y uno falla por la clave, mientras que
`ON CONFLICT` está hecho para ese caso. En MySQL, el alias `AS n` reemplaza a `VALUES(ub)`, que está
obsoleto desde 8.0.20. Y Oracle no tiene `VALUES (…), (…)` como tabla en el `USING`: se arma con `dual`.

**Rúbrica, si tu versión es otra (sobre 3 puntos):** 1 por las dos filas finales en los tres motores; 1 por
nombrar la restricción única; 1 por borrar la tabla de prueba.

---

## 🔴 Muy difícil (6)

### Ejercicio 6

**Rúbrica (sobre 5 puntos):**

- **1 punto: Postgres.** `REPEATABLE READ`: es *snapshot isolation*, como `SNAPSHOT`, y la segunda
  escritura falla con `40001` (`could not serialize access due to concurrent update`, E-42) donde SQL
  Server da el 3960. El reintento cambia de código, nada más.
- **1 punto: MySQL.** Cambiar el nivel **no alcanza**: su `REPEATABLE READ` deja pasar la actualización
  perdida, y su `SERIALIZABLE` la convierte en un *deadlock* 1213 ([F15](../15-aislamiento-comparado.md)).
- **1 punto: qué escribes en MySQL.** Leer el saldo con `SELECT … FOR UPDATE` en la misma transacción, o
  escribir el descuento como `UPDATE … SET balance = balance - ?`, que lee lo último confirmado. Las dos
  funcionan en cualquier nivel.
- **1 punto: Oracle,** si lo nombras: `SERIALIZABLE`, que es *snapshot isolation* y falla con `ORA-08177`
  (por su documentación; el curso no lo mide).
- **1 punto: el reintento.** En los tres, el error obliga a reintentar la transacción entera, desde el
  principio; y el *write skew* entre filas distintas no lo frena ninguno de estos niveles salvo el
  `SERIALIZABLE` de Postgres.
