# ✅ Soluciones — Fase 03: Lo que SQL le hace al modelo relacional

> **Curso:** Ruta SQL · Solucionario de la [Fase 03](../03-lo-que-sql-le-hace-al-modelo.md)
> **Ejercicios:** 22 · **Perfil:** M · **Motores:** Postgres y MySQL de
> [`a02`](../a02-compose-de-la-ruta.md#-las-versiones-del-curso); Oracle, solo comportamiento y mensajes
> **Fecha de verificación ejecutada:** 12/10/2026

> ⚠️ **Intenta el ejercicio antes de leer su solución.** Leída antes, solo te enseña a reconocerla.

---

## 🟢 Fácil (1–7)

### Ejercicio 1

**Enunciado (resumen):** protocolos de 2009 con la obra social en `NULL` y en `''`.

**Solución.**

```sql
-- postgres
SELECT count(*) FILTER (WHERE "ObraSocial" IS NULL) AS nulos,
       count(*) FILTER (WHERE "ObraSocial" = '') AS vacios,
       count(*) AS protocolos
FROM legacy."Protocolos"
WHERE "Fecha" >= '2009-01-01' AND "Fecha" < '2010-01-01';
```

```text
 nulos | vacios | protocolos
-------+--------+------------
   344 |    207 |      11504
(1 row)
```

`FILTER` cuenta cada condición por separado en una sola pasada. Juntas, 551 de 11.504: el 4,8 % de los
protocolos de 2009 no dice de qué obra social es.

[← Volver al ejercicio](../03-lo-que-sql-le-hace-al-modelo.md#-ejercicio-1--vacías-y-nulas)

### Ejercicio 2

**Enunciado (resumen):** filas de `Pacientes` y cuántas tienen DNI.

**Solución.**

```sql
-- postgres
SELECT count(*) AS filas, count("DNI") AS con_dni, count(*) - count("DNI") AS sin_dni FROM legacy."Pacientes";
```

```text
 filas  | con_dni | sin_dni
--------+---------+---------
 242427 |  217640 |   24787
(1 row)
```

`count("DNI")` no cuenta los `NULL`, y la resta da los pacientes sin DNI sin escribir ningún `WHERE`.

[← Volver al ejercicio](../03-lo-que-sql-le-hace-al-modelo.md#-ejercicio-2--lo-que-count-no-cuenta)

### Ejercicio 3

**Enunciado (resumen):** `= NULL` contra `IS NULL` en diciembre de 2009.

**Solución.** La consulta de la sección 5.2 da `igual_a_null` 0 y `es_null` 39. `= NULL` compara con un
valor desconocido, el resultado es desconocido, y el `FILTER` (como el `WHERE`) solo cuenta lo verdadero.

[← Volver al ejercicio](../03-lo-que-sql-le-hace-al-modelo.md#-ejercicio-3---null)

### Ejercicio 4

**Enunciado (resumen):** `NOT IN` contra `NOT EXISTS` sobre `Practicas`.

**Solución.** Las salidas son las de la sección 5.2: 0 y 5.893.632. La fila que lo provoca:

```sql
-- postgres
SELECT "IdPractica", "CodNBU2012", "Descripcion" FROM legacy."Practicas" WHERE "CodINOS" IS NULL;
```

```text
 IdPractica | CodNBU2012 |           Descripcion
------------+------------+---------------------------------
         19 | 660519     | DETECCIÓN DE SARS-COV-2 POR PCR
(1 row)
```

Un solo `NULL` en la subconsulta alcanza para que `NOT IN` no deje pasar ninguna fila.

[← Volver al ejercicio](../03-lo-que-sql-le-hace-al-modelo.md#-ejercicio-4--not-in-contra-not-exists)

### Ejercicio 5

**Enunciado (resumen):** tres filas repetidas de `Errores de pegado`.

**Solución.**

```sql
-- postgres
SELECT "Campo0", "Campo1", "Campo2", count(*)
FROM legacy."Errores de pegado"
GROUP BY 1, 2, 3
HAVING count(*) > 1
ORDER BY 4 DESC
LIMIT 3;
```

```text
  Campo0   |    Campo1     |    Campo2     | count
-----------+---------------+---------------+-------
 VER       |               | PRUEBA MATIAS |     4
 NO BORRAR | 1             | -             |     4
 NO BORRAR | PRUEBA MATIAS | PENDIENTE     |     4
(3 rows)
```

`GROUP BY` sobre todas las columnas es la forma de encontrar filas idénticas en una tabla sin clave. Con
una clave, no podrían existir.

[← Volver al ejercicio](../03-lo-que-sql-le-hace-al-modelo.md#-ejercicio-5--una-bolsa)

### Ejercicio 6

**Enunciado (resumen):** el orden que cambia después de un `UPDATE`, y cómo estabilizarlo.

**Solución.** Las salidas son las de la sección 5.3: la fila 2 pasa al final. La consulta estable es la
misma con `ORDER BY "IdObraSocial"`, y devuelve 1, 2, 3, 4, 5 antes y después del `UPDATE`. El orden es
parte de la consulta, nunca de la tabla.

[← Volver al ejercicio](../03-lo-que-sql-le-hace-al-modelo.md#-ejercicio-6--el-orden-que-no-existe)

### Ejercicio 7

**Enunciado (resumen):** `CASE WHEN '' IS NULL` en Oracle y en Postgres.

**Solución.** Oracle responde `la cadena vacía es NULL` y Postgres `la cadena vacía no es NULL`. La
documentación de Oracle, en *Nulls*: *"The database treats a character value with a length of zero as
null."* Es una decisión del motor, anterior al estándar, y Oracle la mantiene por compatibilidad.

[← Volver al ejercicio](../03-lo-que-sql-le-hace-al-modelo.md#-ejercicio-7--la-cadena-vacía-en-oracle)

## 🟡 Intermedio (8–13)

### Ejercicio 8

**Enunciado (resumen):** ejecutar la consulta de Rubén y explicar por qué filas y prácticas no coinciden.

**Solución.**

```text
 filas | practicas |   total
-------+-----------+------------
  1314 |      1203 | 26524.1700
(1 row)
```

`count(*)` cuenta filas del resultado, y `count(DISTINCT pp."Id")` cuenta prácticas, porque `Id` es la
clave de `ProtocoloPracticas`. Hay 111 filas más que prácticas porque algunas prácticas se juntaron con
dos filas de precio.

[← Volver al ejercicio](../03-lo-que-sql-le-hace-al-modelo.md#-ejercicio-8--la-consulta-de-rubén)

### Ejercicio 9

**Enunciado (resumen):** los códigos repetidos de `Precios_2009_12` y cuántas filas los usan.

**Solución.** Los códigos son `660006` y `660021` (sección 5.1). Las prácticas de PAMI con esos códigos:

```sql
-- postgres
SELECT count(*) FROM legacy."Protocolos" AS p
JOIN legacy."ProtocoloPracticas" AS pp USING ("IdProtocolo")
WHERE p."Fecha" >= '2009-12-01' AND p."Fecha" < '2010-01-01'
  AND p."ObraSocial" IN ('PAMI', 'Pami', 'pami', 'P.A.M.I.', 'INSSJP')
  AND pp."CodigoPractica" IN ('660006', '660021');
```

```text
 count
-------
   111
(1 row)
```

Cada una aparece dos veces en la presentación: las 111 filas de más.

[← Volver al ejercicio](../03-lo-que-sql-le-hace-al-modelo.md#-ejercicio-9--los-precios-repetidos)

### Ejercicio 10

**Enunciado (resumen):** las prácticas de PAMI de diciembre de 2009 sin precio en la tabla del mes.

**Solución.**

```sql
-- postgres
SELECT pp."CodigoPractica", pa."Descripcion", count(*)
FROM legacy."Protocolos" AS p
JOIN legacy."ProtocoloPracticas" AS pp USING ("IdProtocolo")
LEFT JOIN legacy."Practicas" AS pa ON pa."CodNBU" = pp."CodigoPractica" OR pa."CodNBU2012" = pp."CodigoPractica"
WHERE p."Fecha" >= '2009-12-01' AND p."Fecha" < '2010-01-01'
  AND p."ObraSocial" IN ('PAMI', 'Pami', 'pami', 'P.A.M.I.', 'INSSJP')
  AND NOT EXISTS (SELECT 1 FROM legacy."Precios_2009_12" AS pr WHERE pr."CodPractica" = pp."CodigoPractica")
GROUP BY 1, 2
ORDER BY 3 DESC;
```

```text
 CodigoPractica | Descripcion | count
----------------+-------------+-------
 660010         | IONOGRAMA   |    79
 660014         | FERRITINA   |    43
(2 rows)
```

Estaban en el mes anterior: `SELECT "CodPractica" FROM legacy."Precios_2009_11" EXCEPT SELECT "CodPractica"
FROM legacy."Precios_2009_12"` devuelve `660010` y `660014`, entre otros. Alguien las borró al copiar la
tabla del mes.

[← Volver al ejercicio](../03-lo-que-sql-le-hace-al-modelo.md#-ejercicio-10--las-prácticas-sin-precio)

### Ejercicio 11

**Enunciado (resumen):** prácticas de PAMI con la obra social vacía, separando `NULL` y `''`.

**Solución.**

```sql
-- postgres
SELECT count(*) FILTER (WHERE p."ObraSocial" IS NULL) AS nulos,
       count(*) FILTER (WHERE p."ObraSocial" = '') AS vacios
FROM legacy."Protocolos" AS p
JOIN legacy."ProtocoloPracticas" AS pp USING ("IdProtocolo")
JOIN truth.order_payer AS op ON op.legacy_protocol_id = p."IdProtocolo"
WHERE p."Fecha" >= '2009-12-01' AND p."Fecha" < '2010-01-01' AND op.payer_code = 'PAMI';
```

```text
 nulos | vacios
-------+--------
    66 |     22
(1 row)
```

`truth` dice de quién es cada protocolo; `legacy`, lo que quedó escrito. Cruzarlos es la única forma de
saber qué se perdió.

[← Volver al ejercicio](../03-lo-que-sql-le-hace-al-modelo.md#-ejercicio-11--contra-la-verdad)

### Ejercicio 12

**Enunciado (resumen):** el `INSERT` en MySQL con y sin modo estricto.

**Solución.** Con el modo de fábrica (`ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,
ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION`):

```text
ERROR 1265 (01000) at line 5: Data truncated for column 'practicas' at row 1
ERROR 1406 (22001) at line 6: Data too long for column 'obra_social' at row 1
```

Con `SET SESSION sql_mode = ''`, el `INSERT` entra:

```text
+---------+------+--------------------------------------------------+
| Level   | Code | Message                                          |
+---------+------+--------------------------------------------------+
| Warning | 1265 | Data truncated for column 'practicas' at row 1   |
| Warning | 1265 | Data truncated for column 'obra_social' at row 1 |
+---------+------+--------------------------------------------------+
```

Y guarda `12` y `P.A.M`. El segundo `INSERT` del modo estricto (`12, 'P.A.M.I.'`) falla por el largo: el
`12` era válido, el texto no.

[← Volver al ejercicio](../03-lo-que-sql-le-hace-al-modelo.md#-ejercicio-12--mysql-sin-modo-estricto)

### Ejercicio 13

**Enunciado (resumen):** `<>` contra `IS DISTINCT FROM` para "no es PAMI".

**Solución.** La consulta de la sección 5.2: 894 con `<> 'PAMI'` y 933 con `IS DISTINCT FROM 'PAMI'`. La
diferencia son los 39 protocolos con obra social `NULL`. Para "todos los protocolos que no son de PAMI",
`IS DISTINCT FROM`, porque un protocolo sin obra social tampoco es de PAMI; con `<>` desaparece de las
dos listas, la de PAMI y la de los demás.

[← Volver al ejercicio](../03-lo-que-sql-le-hace-al-modelo.md#-ejercicio-13---contra-is-distinct-from)

## 🟠 Difícil (14–18)

### Ejercicio 14

**Enunciado (resumen):** qué filas sacó `DISTINCT`.

**Solución de referencia.** Agrupando la presentación por las columnas del `DISTINCT` y mirando de cuántos
protocolos viene cada grupo repetido:

```sql
-- postgres
WITH ruben AS (
  SELECT pa."Nombre", pa."NroAfiliado", pp."CodigoPractica", pr."Valor", p."IdProtocolo"
  FROM legacy."Protocolos" AS p
  JOIN legacy."Pacientes" AS pa ON pa."IdPaciente" = p."IdPaciente"
  JOIN legacy."ProtocoloPracticas" AS pp ON pp."IdProtocolo" = p."IdProtocolo"
  JOIN legacy."Precios_2009_12" AS pr ON pr."CodPractica" = pp."CodigoPractica"
  WHERE p."Fecha" >= '2009-12-01' AND p."Fecha" < '2010-01-01'
    AND p."ObraSocial" IN ('PAMI', 'Pami', 'pami', 'P.A.M.I.', 'INSSJP'))
SELECT count(*) AS grupos_colapsados,
       sum(n - 1) AS filas_que_saco_distinct,
       count(*) FILTER (WHERE protocolos = n) AS de_protocolos_distintos
FROM (SELECT count(*) AS n, count(DISTINCT "IdProtocolo") AS protocolos
      FROM ruben GROUP BY "Nombre", "NroAfiliado", "CodigoPractica", "Valor" HAVING count(*) > 1) AS g;
```

```text
 grupos_colapsados | filas_que_saco_distinct | de_protocolos_distintos
-------------------+-------------------------+-------------------------
                31 |                      33 |                      31
(1 row)
```

Los 31 grupos que colapsó vienen, cada uno, de **protocolos distintos**: son prácticas reales del mismo
paciente en dos visitas. Las 111 filas de precio repetido no están en ningún grupo, porque sus dos precios
son distintos: `DISTINCT` las dejó.

**Rúbrica.** Una respuesta correcta tiene que:
- identificar las filas que colapsó, no solo contarlas;
- demostrar que son de protocolos distintos;
- explicar por qué las 111 sobrevivieron.

Y queda invalidada si:
- concluye que `DISTINCT` "arregló la mitad".

[← Volver al ejercicio](../03-lo-que-sql-le-hace-al-modelo.md#-ejercicio-14--qué-sacó-distinct)

### Ejercicio 15

**Enunciado (resumen):** la presentación corregida.

**Solución de referencia.** `src/03-lo-que-sql-le-hace-al-modelo/fixed_presentation.sql`:

```text
 practicas | con_precio |   total
-----------+------------+------------
      1325 |       1203 | 23154.2100
(1 row)

 nulos | vacios
-------+--------
    39 |     20
(1 row)
```

Tres decisiones: `LEFT JOIN`, para que la práctica sin precio aparezca con el precio en `NULL`; los precios
agrupados por código antes del `JOIN`, con un criterio **declarado** (aquí el menor, pero podría ser el
último cargado si hubiera con qué saberlo); y una segunda consulta con los 59 protocolos del mes sin obra
social, para revisar antes de presentar.

**Rúbrica.** Una respuesta correcta tiene que:
- garantizar una fila por práctica;
- dejar a la vista las prácticas sin precio y los protocolos sin obra social;
- declarar cómo elige el precio cuando hay dos.

Y queda invalidada si:
- usa `DISTINCT` para corregir los duplicados, o pierde en silencio alguna práctica.

[← Volver al ejercicio](../03-lo-que-sql-le-hace-al-modelo.md#-ejercicio-15--la-presentación-corregida)

### Ejercicio 16

**Enunciado (resumen):** el día en que murió el `NOT IN`, y la corrección mínima.

**Solución de referencia.** La práctica sin `CodINOS` es la PCR de SARS-CoV-2 (código NBU 2012
`660519`). Su primer protocolo:

```sql
-- postgres
SELECT min(p."Fecha")::date AS primera_vez
FROM legacy."ProtocoloPracticas" AS pp JOIN legacy."Protocolos" AS p USING ("IdProtocolo")
WHERE pp."CodigoPractica" = (SELECT "CodNBU2012" FROM legacy."Practicas" WHERE "CodINOS" IS NULL);
```

```text
 primera_vez
-------------
 2020-03-20
(1 row)
```

La práctica se cargó en el catálogo para esa fecha, y desde entonces la subconsulta tiene un `NULL`. La
corrección mínima que conserva `NOT IN` es sacar el `NULL` de la subconsulta:

```sql
-- postgres
SELECT count(*) AS not_in_corregido FROM legacy."ProtocoloPracticas" AS pp
WHERE pp."CodigoPractica" NOT IN (SELECT "CodINOS" FROM legacy."Practicas" WHERE "CodINOS" IS NOT NULL);
```

```text
 not_in_corregido
------------------
          5893632
(1 row)
```

Funciona, pero depende de que alguien se acuerde del filtro. `NOT EXISTS` no lo necesita.

**Rúbrica.** Una respuesta correcta tiene que:
- dar la fecha y la práctica, con la consulta;
- explicar por qué la consulta no falló, sino que devolvió cero;
- comparar la corrección mínima con `NOT EXISTS`.

Y queda invalidada si:
- propone poner un código INOS falso a la PCR.

[← Volver al ejercicio](../03-lo-que-sql-le-hace-al-modelo.md#-ejercicio-16--la-consulta-que-murió-en-2020)

### Ejercicio 17

**Enunciado (resumen):** `NOT NULL` con una cadena vacía en Postgres y en Oracle, y una regla de
migración.

**Solución de referencia.** Los mensajes son los de la sección 8: Postgres acepta `''` y rechaza `NULL`
(`null value in column "obra_social" … violates not-null constraint`); Oracle rechaza `''` con
`ORA-01400: cannot insert NULL into ("ALAMEDA"."PRESENTACION"."OBRA_SOCIAL")`. **La regla:** en la carga,
`NULLIF(obra_social, '')` en todas las columnas de texto donde `''` significa "no cargado", que en la caja
son todas; la columna nueva acepta `NULL` hasta que el dato se complete; y cualquier `''` con significado
propio se convierte en un valor explícito antes de migrar.

**Rúbrica.** Una respuesta correcta tiene que:
- reproducir los dos mensajes;
- decidir qué significa `''` antes de cargar;
- dar una regla que funcione igual en los dos motores.

Y queda invalidada si:
- reemplaza `''` por un espacio para que Oracle lo acepte.

[← Volver al ejercicio](../03-lo-que-sql-le-hace-al-modelo.md#-ejercicio-17--la-rotura-en-los-dos-motores)

### Ejercicio 18

**Enunciado (resumen):** los valores no numéricos de `Hemograma.Hemoglobina`.

**Solución de referencia.**

```sql
-- postgres
SELECT "Hemoglobina", count(*) FROM legacy."Hemograma"
WHERE "Hemoglobina" !~ '^[0-9]' OR "Hemoglobina" IS NULL
GROUP BY 1 ORDER BY 2 DESC;
```

```text
 Hemoglobina | count
-------------+-------
 -           |   372
 VER OBS     |   371
             |   361
(3 rows)
```

`-` y el vacío dicen "no se midió": en el modelo nuevo son `NULL`. `VER OBS` dice "hay algo que leer en
`Obs`": el valor tampoco existe, pero hay un motivo, y el motivo va en su propia columna. Ninguno de los
tres es un número, y los tres hacen fallar un `avg()` sobre la columna.

**Rúbrica.** Una respuesta correcta tiene que:
- contar los tres centinelas;
- distinguir "no hay dato" de "hay un motivo";
- proponer `NULL` más una columna de motivo, no un número especial.

Y queda invalidada si:
- reemplaza los centinelas por `0`.

[← Volver al ejercicio](../03-lo-que-sql-le-hace-al-modelo.md#-ejercicio-18--los-centinelas)

## 🔴 Muy difícil (19–22)

### Ejercicio 19

**Enunciado (resumen):** la consulta de Rubén para OSDE en abril de 2010, predicha y medida.

**Solución de referencia.** Una predicción razonable: pierde los protocolos de OSDE con obra social vacía,
pierde las prácticas sin precio en `Precios_2010_04`, y duplica las del código repetido de esa tabla
(`660054`). Primero, cómo está escrita OSDE ese mes según la verdad: `OSDE 310`, `O.S.D.E`, `Osde`,
`osde 210`, `OSDE`, más 11 `NULL` y 8 `''`. La consulta, con esas cinco escrituras:

```text
 filas | practicas |   total
-------+-----------+-----------
   388 |       388 | 8042.4200
(1 row)
```

Contra la verdad:

```text
 verdad | obra_social_vacia | sin_precio | con_precio_duplicado
--------+-------------------+------------+----------------------
    413 |                19 |          7 |                    0
(1 row)
```

Pierde 25: las 19 con obra social vacía y las 7 sin precio, una de las cuales está en los dos grupos. **No
duplica ninguna**: OSDE no tuvo ninguna práctica con el código `660054` ese mes. La parte de la predicción
sobre los duplicados era plausible y salió mal, y eso también se dice.

**Rúbrica.** Una respuesta correcta tiene que:
- escribir la predicción antes de medir;
- obtener las escrituras de OSDE de los datos, no de memoria;
- explicar la diferencia de 25 con la superposición.

Y queda invalidada si:
- ajusta la predicción después de medir.

[← Volver al ejercicio](../03-lo-que-sql-le-hace-al-modelo.md#-ejercicio-19--osde-abril-de-2010)

### Ejercicio 20

**Enunciado (resumen):** resolver la apuesta de Oracle de la sección 6.

**Solución.** El mecanismo, según la documentación (*Nulls*, en la referencia de SQL de Oracle): una cadena
de largo cero **es** `NULL`. Al cargar `Protocolos`, las tablas externas de `lab load` leen el campo `""`
como cadena vacía, y la columna `VARCHAR2` lo guarda como `NULL`. Qué mirar en tu resultado: si `count(*)
WHERE "ObraSocial" IS NULL` para diciembre de 2009 coincide con la suma de las dos columnas de Postgres, la
apuesta se gana; si `WHERE "ObraSocial" = ''` devuelve alguna fila, se pierde y hay algo en la carga que no
se entendió. El número es tuyo: el curso no lo publica.

[← Volver al ejercicio](../03-lo-que-sql-le-hace-al-modelo.md#-ejercicio-20--la-apuesta-de-oracle)

### Ejercicio 21

**Enunciado (resumen):** el coseguro promedio de 2025, con y sin `coalesce`.

**Solución de referencia.**

```sql
-- postgres
SELECT avg("Coseguro") AS avg_coseguro, avg(coalesce("Coseguro", 0)) AS avg_con_cero,
       count("Coseguro") AS con_coseguro, count(*) AS protocolos
FROM legacy."Protocolos" WHERE "Fecha" >= '2025-01-01' AND "Fecha" < '2026-01-01';
```

```text
    avg_coseguro    |    avg_con_cero    | con_coseguro | protocolos
--------------------+--------------------+--------------+------------
 39109.348271452252 | 16291.128626224989 |        80234 |     192614
(1 row)
```

`avg()` ignora los `NULL`: es el promedio **de los protocolos que pagaron coseguro**. Con `coalesce`, es el
promedio **por protocolo**, contando como cero los que no pagaron. Los dos son correctos para preguntas
distintas. Lo que hay que saber del negocio es qué significa el `NULL`: si es "no paga coseguro", el cero es
verdad; si es "no se cargó", el cero es inventado y el primer promedio es el honesto.

**Rúbrica.** Una respuesta correcta tiene que:
- explicar qué promedia cada versión;
- condicionar la elección al significado del `NULL`.

Y queda invalidada si:
- declara una de las dos correcta sin preguntar qué significa el `NULL`.

[← Volver al ejercicio](../03-lo-que-sql-le-hace-al-modelo.md#-ejercicio-21--el-promedio-del-coseguro)

### Ejercicio 22

**Enunciado (resumen):** la columna de obra social del protocolo en el modelo nuevo.

**Solución de referencia.** Una clave foránea `payer_id` a `alameda.payer`, **no** texto. El particular
**no** es `NULL`: es una fila de `payer` ("particular"), porque "paga el paciente" es un dato, y `NULL`
diría "no sabemos". La columna admite `NULL` solo mientras dure la migración, para los protocolos de la
caja cuya obra social no se pudo recuperar (los 88 de PAMI de diciembre de 2009 son de esos), y se
declara `NOT NULL` con `NOT VALID` y se valida cuando la cola de revisión llegue a cero, como en el triaje
de la [Fase 02](../02-las-cinco-preguntas-desde-el-otro-lado.md#48-ya-está-en-producción-el-triaje).

**Rúbrica.** Una respuesta correcta tiene que:
- usar una clave foránea, no texto;
- tratar al particular como un valor, no como `NULL`;
- tener un plan para los protocolos de la caja sin obra social.

Y queda invalidada si:
- usa un centinela (`'SIN OS'`, `0`) en lugar de `NULL` para "no sabemos".

[← Volver al ejercicio](../03-lo-que-sql-le-hace-al-modelo.md#-ejercicio-22--cuándo-la-obra-social-puede-ser-null)
