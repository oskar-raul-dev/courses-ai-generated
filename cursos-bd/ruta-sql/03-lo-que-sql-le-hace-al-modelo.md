# 🧮 Fase 03 — Lo que SQL le hace al modelo relacional: la presentación que perdió 210 prácticas sin dar error

> **Curso:** Ruta SQL · Fase 03 de 27 · Bloque I — El modelo · **8 h**
> **Motores:** PostgreSQL `pgvector/pgvector@sha256:2358fcba361e…` · contraste MySQL `mysql@sha256:e2bde46db656…` · Oracle (apuesta sin resolver)
> **Entorno de ejecución:** SQL
> **Perfil de volumen:** M para todo; las consultas son de un mes
> **El dolor de Alameda:** la presentación mensual a la obra social, *"la primera consulta que un día dio mal"* (historia §3, 1997)
> **Depende de:** Fase 02 · **Habilita:** Fase 04
> **Apéndices de apoyo:** a02, a04, a05, a07, a09
> **Fecha de verificación ejecutada:** 12/10/2026
> **Objetivo:** reproducir sobre la caja la presentación de diciembre de 2009 a PAMI, medir contra la
> verdad cuántas prácticas pierde y cuántas duplica, y explicar cada pérdida por lo que SQL hace con
> los duplicados, los `NULL` y el orden.

---

## 🧭 1. Dónde estamos

El Bloque 0 dejó dos instrumentos: la caja cargada y medida, y las cinco preguntas. Este bloque los
usa sobre la parte más incómoda de Alameda, **el modelo**, y lo empieza por la consulta más vieja de
la empresa.

En 1997, a fin de mes, había que armar la presentación a cada obra social: los pacientes del mes, su
número de afiliado y las prácticas con su código y su precio. Fue la primera consulta de verdad que
Rubén escribió, y la historia la recuerda por una frase: *"la primera que un día dio mal"*. Lo que
nadie supo nunca es **cuánto** daba mal, porque la consulta no fallaba: devolvía filas, sumaba un
total, y la planilla salía.

Esta fase la reproduce sobre la caja, para un mes y una obra social concretos, y la compara con algo
que Rubén no tenía: **la verdad del generador**, que sabe a qué obra social pertenece cada protocolo.
La diferencia no viene de un error de programación. Viene de tres cosas que SQL hace y el modelo
relacional no: guarda filas repetidas, tiene un tercer valor de verdad, y no promete ningún orden.

---

## 🎯 2. Objetivos de esta fase

1. Reproducir la presentación de diciembre de 2009 a PAMI y medir contra `truth` cuántas prácticas
   pierde y cuántas cuenta dos veces.
2. Explicar con la caja por qué un `JOIN` puede multiplicar filas y por qué `DISTINCT` no lo arregla.
3. Predecir el resultado de `NOT IN`, `COUNT(columna)`, `= NULL` e `IS DISTINCT FROM` sobre columnas
   con `NULL`, y comprobarlo.
4. Mostrar, sin ningún número de Oracle, por qué la cadena vacía cambia una migración a ese motor.
5. Escribir la presentación corregida, con cada pérdida a la vista.

---

## 🚫 3. Qué NO entra todavía

- **Reconocer `pami` y `P.A.M.I.` como la misma obra social.** Aquí se acepta la lista de Rubén; la
  obra social como dato es de la [Fase 04](04-un-valor-un-hecho.md).
- **Recuperar la obra social de los protocolos que no la tienen.** Esta fase los cuenta; deducirla del
  paciente es un problema de identidad, de la [Fase 05](05-una-persona-no-es-su-documento.md).
- **La vigencia de los precios.** Las 280 tablas mensuales se usan tal cual; el modelo temporal es de
  la [Fase 07](07-el-tiempo-en-el-modelo.md).

---

## 🏚️ 4. El dolor, en la caja

> 🏚️ **La caja no trae el SQL de Rubén.** Trae sus datos. La consulta de abajo es la presentación
> reconstruida con la lógica que cuenta la historia: los protocolos del mes cuya obra social está
> escrita de alguna de las formas conocidas, sus prácticas, y el precio de cada una en la tabla del
> mes. Está en `src/03-lo-que-sql-le-hace-al-modelo/ruben_presentation.sql`.

La presentación de diciembre de 2009 a PAMI, la obra social de los jubilados:

```sql
-- postgres
SELECT count(*) AS filas,
       count(DISTINCT pp."Id") AS practicas,
       sum(pr."Valor") AS total
FROM legacy."Protocolos" AS p
JOIN legacy."ProtocoloPracticas" AS pp ON pp."IdProtocolo" = p."IdProtocolo"
JOIN legacy."Precios_2009_12" AS pr ON pr."CodPractica" = pp."CodigoPractica"
WHERE p."Fecha" >= '2009-12-01' AND p."Fecha" < '2010-01-01'
  AND p."ObraSocial" IN ('PAMI', 'Pami', 'pami', 'P.A.M.I.', 'INSSJP');
```

```text
 filas | practicas |   total
-------+-----------+------------
  1314 |      1203 | 26524.1700
(1 row)
```

La lista del `IN` no es descuidada: son **todas** las formas en que la recepción escribió PAMI ese mes,
`INSSJP` incluida, que es su nombre oficial. Rubén las conocía, y en 2009 era la mejor regla posible
para una columna de texto.

Ahora la verdad. El generador sabe a qué obra social corresponde cada protocolo:

```sql
-- postgres
SELECT count(*) AS practicas_pami,
       count(*) FILTER (WHERE p."ObraSocial" IS NULL OR p."ObraSocial" = '') AS con_obra_social_vacia
FROM legacy."Protocolos" AS p
JOIN legacy."ProtocoloPracticas" AS pp ON pp."IdProtocolo" = p."IdProtocolo"
JOIN truth.order_payer AS op ON op.legacy_protocol_id = p."IdProtocolo"
WHERE p."Fecha" >= '2009-12-01' AND p."Fecha" < '2010-01-01' AND op.payer_code = 'PAMI';
```

```text
 practicas_pami | con_obra_social_vacia
----------------+-----------------------
           1413 |                    88
(1 row)
```

PAMI tuvo **1.413 prácticas** en diciembre de 2009. La presentación cobra **1.203**, en **1.314
filas**. Faltan 210 prácticas y sobran 111 filas, y ninguna consulta dio error. Las secciones que siguen
explican de dónde sale cada una.

> 📐 **Medición: la presentación de diciembre de 2009 a PAMI, contra la verdad** · perfil M ·
> `pgvector/pgvector@sha256:2358fcba361e…` · verificado el 12/10/2026
>
> | | prácticas | filas |
> |---|---|---|
> | según `truth.order_payer` | 1.413 | — |
> | perdidas: protocolo con la obra social NULL o vacía | 88 (66 NULL y 22 `''`) | — |
> | perdidas: práctica sin precio en `Precios_2009_12` | 122 (IONOGRAMA 79, FERRITINA 43) | — |
> | contadas dos veces: precio pegado dos veces | — | 111 |
> | **la presentación de Rubén** | **1.203** | **1.314** |
>
> Reproducir: `src/03-lo-que-sql-le-hace-al-modelo/ruben_presentation.sql` sobre `uv run lab load --profile m`

---

## 🧩 5. Tres cosas que SQL le hace al modelo

### 5.1 Las filas repetidas: SQL trabaja con bolsas

**El dolor.** De las 1.314 filas, 111 sobran. En `Precios_2009_12`, dos prácticas están **dos veces**,
con precios distintos:

```sql
-- postgres
SELECT "CodPractica", count(*), min("Valor"), max("Valor")
FROM legacy."Precios_2009_12"
GROUP BY "CodPractica"
HAVING count(*) > 1;
```

```text
 CodPractica | count |   min   |   max
-------------+-------+---------+---------
 660006      |     2 | 27.6000 | 30.3600
 660021      |     2 | 78.8500 | 86.7400
(2 rows)
```

Alguien pegó el precio nuevo debajo del viejo, el día que se copió `Precios` a `Precios_2009_12`. Cada
práctica de PAMI con esos dos códigos se juntó con **las dos** filas de precio, y apareció dos veces en
la presentación, cobrada dos veces.

**El mecanismo.** En el modelo relacional, una relación es un **conjunto**: no puede tener dos tuplas
iguales, y un *join* nunca produce más hechos de los que hay. SQL no implementa conjuntos sino **bolsas**
(*bags*): una tabla sin clave admite filas repetidas, y un `JOIN` contra una tabla sin clave
**multiplica**. `Precios_2009_12` no tiene clave primaria, como las otras 279 tablas de precios
([Fase 01](01-la-caja-y-el-arnes.md#44-el-primer-recorrido-desde-el-catálogo)). Nada impidió la segunda
fila, y nada avisó que el `JOIN` dejaba de ser uno a uno.

La caja tiene bolsas peores, con filas idénticas:

```sql
-- postgres
SELECT count(*) AS filas, count(DISTINCT e) AS distintas FROM legacy."Errores de pegado" AS e;
```

```text
 filas | distintas
-------+-----------
   378 |       311
(1 row)
```

**El patrón a memorizar.** Un `JOIN` es seguro cuando del otro lado hay una clave que garantiza **una
fila por valor**. Sin esa clave, el número de filas del resultado no es el número de hechos, y nadie te
lo va a decir.

### 5.2 El tercer valor: `NULL`

**El dolor.** De las 210 prácticas perdidas, 88 son de protocolos de PAMI cuya obra social quedó en
`NULL` (66) o en cadena vacía (22). La recepción no la cargó, o cargó un espacio que alguien borró.
Para el `IN`, ninguna de las dos es `PAMI`, y la fila se va.

**El mecanismo.** SQL tiene **lógica de tres valores**: una comparación con `NULL` no da verdadero ni
falso, da *desconocido*, y el `WHERE` solo deja pasar lo verdadero. Sobre los 976 protocolos de
diciembre de 2009:

```sql
-- postgres
SELECT count(*) AS protocolos,
       count("ObraSocial") AS con_obra_social,
       count(*) FILTER (WHERE "ObraSocial" = NULL) AS igual_a_null,
       count(*) FILTER (WHERE "ObraSocial" IS NULL) AS es_null,
       count(*) FILTER (WHERE "ObraSocial" IS DISTINCT FROM 'PAMI') AS distinto_de_pami,
       count(*) FILTER (WHERE "ObraSocial" <> 'PAMI') AS no_igual_a_pami
FROM legacy."Protocolos"
WHERE "Fecha" >= '2009-12-01' AND "Fecha" < '2010-01-01';
```

```text
 protocolos | con_obra_social | igual_a_null | es_null | distinto_de_pami | no_igual_a_pami
------------+-----------------+--------------+---------+------------------+-----------------
        976 |             937 |            0 |      39 |              933 |             894
(1 row)
```

Cuatro lecturas de la misma columna:

- **`COUNT(columna)` no cuenta los `NULL`**: 937 contra 976.
- **`= NULL` nunca es verdadero**, ni siquiera para las 39 filas que son `NULL`. Se pregunta con `IS NULL`.
- **`<> 'PAMI'` tampoco deja pasar los `NULL`**: 894 filas, contra las 933 de `IS DISTINCT FROM 'PAMI'`,
  que trata a `NULL` como un valor más. La diferencia son exactamente los 39 `NULL`.
- **La cadena vacía no es `NULL` en Postgres**: los 20 protocolos con `''` entran en `con_obra_social`.

**La trampa más cara es `NOT IN`.** `x NOT IN (lista)` es `x <> a AND x <> b AND …`, y si la lista
tiene un `NULL`, la comparación con él da desconocido y **la condición entera nunca es verdadera**. La
caja lo tiene listo: en 2006, con el NBU, alguien quiso saber qué prácticas se seguían cargando con un
código que no fuera del INOS viejo.

```sql
-- postgres
SELECT count(*) AS not_in FROM legacy."ProtocoloPracticas" AS pp
WHERE pp."CodigoPractica" NOT IN (SELECT "CodINOS" FROM legacy."Practicas");

SELECT count(*) AS not_exists FROM legacy."ProtocoloPracticas" AS pp
WHERE NOT EXISTS (SELECT 1 FROM legacy."Practicas" AS pa WHERE pa."CodINOS" = pp."CodigoPractica");
```

```text
 not_in
--------
      0
(1 row)

 not_exists
------------
    5893632
(1 row)
```

**Cero contra 5.893.632.** En `Practicas` hay una sola fila sin `CodINOS`: la PCR de SARS-CoV-2, que se
cargó en 2020 y nunca tuvo código en un nomenclador de 1994. Desde el 20 de marzo de 2020, día del primer
protocolo con esa práctica, la consulta devuelve cero filas, y nadie lo nota porque cero es una respuesta
posible. `NOT EXISTS` no tiene el problema: una fila con `NULL` simplemente no coincide.

**El patrón a memorizar.** Con columnas que admiten `NULL`, **`NOT IN` contra una subconsulta es un
error esperando su `NULL`**: usa `NOT EXISTS`. Y cada `=` o `<>` sobre una columna que admite `NULL`
pierde esas filas sin avisar; si las quieres, pídelas con `IS NULL` o `IS DISTINCT FROM`.

### 5.3 El orden que no existe

La presentación de Rubén salía ordenada como estaban cargadas las filas, y durante años coincidió con
el orden de los protocolos. **Una tabla no tiene orden**: Postgres devuelve las filas en el orden físico
en que las encuentra, y ese orden cambia con cualquier escritura.

```sql
-- postgres
CREATE TEMP TABLE obras AS SELECT "IdObraSocial", "Sigla" FROM legacy."ObrasSociales" ORDER BY "IdObraSocial" LIMIT 5;
SELECT * FROM obras;
UPDATE obras SET "Sigla" = 'APROSS ' WHERE "IdObraSocial" = 2;
SELECT * FROM obras;
```

```text
 IdObraSocial | Sigla
--------------+--------
            1 | PAMI
            2 | APROSS
            3 | OSDE
            4 | SANCOR
            5 | SWISS
(5 rows)

 IdObraSocial |  Sigla
--------------+---------
            1 | PAMI
            3 | OSDE
            4 | SANCOR
            5 | SWISS
            2 | APROSS
(5 rows)
```

Un `UPDATE` en Postgres escribe una versión nueva de la fila al final de la tabla, y el segundo
`SELECT` la encuentra última. La [Fase 17](17-mvcc-y-su-factura.md) explica por qué; aquí basta con la regla: **sin `ORDER BY`, el
orden es un accidente.**

> 🩻 **Esto sí funciona igual** en los tres motores: las bolsas, la lógica de tres valores, `NOT IN`
> contra un `NULL` y el orden sin `ORDER BY` son del estándar SQL, no de Postgres. El ORM tampoco te
> protege: genera el mismo `NOT IN` y el mismo `JOIN`.

### 5.4 Date y Darwen, como herramienta

C. J. Date y Hugh Darwen llevan treinta años sosteniendo que SQL se apartó del modelo relacional en
estos tres puntos, y que los tres son errores de diseño del lenguaje: una relación no tiene duplicados,
la lógica tiene dos valores, y el orden no es parte de los datos. No hace falta estar de acuerdo con
todo para usar la crítica: **cada pérdida de la presentación de Rubén está en su lista**. Lo práctico
es escribir el SQL como si tuvieran razón: claves en todas las tablas, `NOT NULL` donde no hay una
razón para el `NULL`, `NOT EXISTS` en lugar de `NOT IN`, y `ORDER BY` siempre que el orden importe.

---

## 🔀 6. El contraste: dónde otro motor cambia la decisión

**Oracle trata la cadena vacía como `NULL`.** Su documentación lo dice sin rodeos: *"The database treats
a character value with a length of zero as null"*. Es un comportamiento, no una medición, y se ve en una
línea:

```sql
-- oracle
SELECT CASE WHEN '' IS NULL THEN 'la cadena vacía es NULL' ELSE 'la cadena vacía no es NULL' END AS oracle FROM dual;
```

```text
ORACLE
---------------------------
la cadena vacía es NULL
```

En Postgres, la misma consulta devuelve `la cadena vacía no es NULL`. **Esto cambia una migración.** La
caja trae miles de `''` desde SQL Server, que los distingue de `NULL` igual que Postgres. Al llevarlos a
Oracle, los 20 protocolos de diciembre de 2009 con obra social vacía se vuelven `NULL`, y una limpieza
que pregunte por `= ''` ya no encuentra ninguno: en Oracle, `= ''` es `= NULL`, que nunca es verdadero.

> 🪞🔒 **Apuesta sin resolver: Oracle.** Hipótesis: cargada `Protocolos` de M en Oracle, `count(*)
> WHERE "ObraSocial" IS NULL` para diciembre de 2009 da la suma de los `NULL` y los vacíos que Postgres
> separa (39 + 20), y `WHERE "ObraSocial" = ''` no devuelve ninguna fila. Condiciones: perfil M,
> `uv run lab load --profile m --engine oracle --tables Protocolos`. Resuélvela con esas dos consultas en
> `sqlplus` ([`a03`](a03-clis-de-los-motores.md#️-oracle--sqlplus)). El mecanismo, en la documentación
> oficial: *Nulls*, en la referencia de SQL de Oracle (en las referencias). 📝 No publicamos números de
> Oracle; el porqué está en [`a09`](a09-licencias-publicacion-y-riesgo.md).

**MySQL fuera de modo estricto convierte en silencio.** MySQL 9.7 arranca con `STRICT_TRANS_TABLES`, y
rechaza un texto en una columna numérica y un valor demasiado largo:

```text
ERROR 1265 (01000) at line 5: Data truncated for column 'practicas' at row 1
ERROR 1406 (22001) at line 6: Data too long for column 'obra_social' at row 1
```

Con `SET SESSION sql_mode = ''`, que es como corren muchos esquemas heredados de la época de MySQL 5, el
mismo `INSERT INTO presentacion VALUES ('12 practicas', 'P.A.M.I.')` **entra** con dos advertencias y
guarda otra cosa:

```text
+-----------+-------------+
| practicas | obra_social |
+-----------+-------------+
|        12 | P.A.M       |
+-----------+-------------+
```

Si la base de la que migras corrió años sin modo estricto, la caja que te den ya trae esos truncamientos
adentro, y ninguna fila los marca.

---

## 🪞 7. Tu instinto dice… y la apuesta

**Tu instinto dice** que un `JOIN` agrega columnas y no filas, que un filtro sobre la obra social deja
afuera solo lo que no es de esa obra social, y que si sobra algo, `DISTINCT` lo arregla. Es el instinto
correcto en un modelo con claves y sin `NULL`, y por eso sobrevive tantos años.

> 🪞 **Apuesta antes de ejecutar** (escrita el 30/09/2026, al diseñar esta fase). *"La consulta de Rubén
> pierde exactamente las prácticas de los protocolos con obra social vacía."*
> **Resultado:** **perdida.** Pierde las 88 de los protocolos con obra social vacía, como se esperaba,
> **y además** 122 que no tienen precio en la tabla del mes, porque el `JOIN` interno descarta lo que
> no encuentra; y cuenta dos veces 111 por los precios repetidos. La apuesta veía un solo mecanismo de
> los tres.

---

## 💥 8. El punto de rotura

La rotura aparece al llevar la caja a Oracle con el modelo que pide el negocio: **la obra social es
obligatoria**. En Postgres, una columna `NOT NULL` acepta la cadena vacía y rechaza el `NULL`:

```text
ERROR:  null value in column "obra_social" of relation "presentacion" violates not-null constraint
DETAIL:  Failing row contains (null).
```

En Oracle, la cadena vacía **ya es** `NULL`, y el `INSERT` de un `''` falla:

```text
INSERT INTO presentacion VALUES ('')
                                 *
ERROR at line 1:
ORA-01400: cannot insert NULL into ("ALAMEDA"."PRESENTACION"."OBRA_SOCIAL")
Help: https://docs.oracle.com/error-help/db/ora-01400/
```

La misma columna, el mismo valor, y un motor que lo guarda y otro que no. **Cómo se sale:** decidiendo
qué significa `''` **antes** de migrar. En la caja, es "la recepción no cargó la obra social", igual que
`NULL`, así que se convierte a `NULL` en la carga y la columna del modelo nuevo **no** es `NOT NULL` hasta
que cada protocolo tenga una obra social o el estado "particular" explícito. Si `''` significara otra
cosa, tendría que ser otro valor, porque Oracle no lo puede guardar.

---

## ⚰️ 9. Autopsia: `SELECT DISTINCT` para arreglar los duplicados

**1. La decisión.** *"La presentación sale con prácticas repetidas. Le pongo `DISTINCT` y listo: si dos
filas son iguales, es la misma práctica."* La toma cualquiera que vio una fila de más en un informe, y es
la respuesta más rápida que tiene SQL.

**2. Por qué era razonable.** Funciona cuando las filas repetidas son **idénticas**, y en una planilla
lo eran casi siempre. No pide entender el `JOIN`, que es justamente lo que nadie tenía tiempo de hacer a
fin de mes.

**3. Qué pasó después.** Con `DISTINCT` sobre las columnas de la planilla (paciente, afiliado, práctica
y precio):

```text
 filas | con_distinct | practicas_reales |   total    | total_distinct
-------+--------------+------------------+------------+----------------
  1314 |         1281 |             1203 | 26524.1700 |     25911.3600
```

`DISTINCT` sacó **33 filas**, y **ninguna era un duplicado**: eran las 33 veces que un mismo paciente se
hizo la misma práctica en dos protocolos del mes, que son dos prácticas reales y se cobran dos veces.
Las 111 filas de precio repetido **sobrevivieron**, porque sus dos precios son distintos y para
`DISTINCT` son filas diferentes. El parche sacó lo que había que cobrar y dejó lo que no.

**4. Cuánto cuesta salir.** Poco, una vez que se ve: entender por qué se multiplicó, y arreglar el lado
que no tenía clave. La presentación corregida (`fixed_presentation.sql`) deja una fila por práctica,
toma un precio por código con un criterio declarado (el menor de los repetidos) y muestra las que no
tienen precio en lugar de perderlas:

```text
 practicas | con_precio |   total
-----------+------------+------------
      1325 |       1203 | 23154.2100
```

**1.325 prácticas** de PAMI según lo que dice la columna (las 1.413 de la verdad menos las 88 con la obra
social vacía, que ninguna consulta puede asignar sin saber más), **122 a la vista sin precio**, y un total
de $23.154,21 contra los $26.524,17 de Rubén: **$3.369,96 cobrados de más** solo por los precios
repetidos.

**5. Qué lo habría cambiado.** Una **clave primaria en `Precios_2009_12`** sobre el código de práctica:
la segunda fila no habría entrado, y el `JOIN` habría sido uno a uno. Y la pregunta 5 del instrumento,
*¿exactitud o parecido?*: una presentación a una obra social es exactitud, y `DISTINCT` es una
aproximación que se ve como un arreglo.

**Antes y después, con números:** 1.314 filas y $26.524,17 contra 1.325 prácticas, 122 marcadas sin
precio y $23.154,21, sobre los mismos datos.

---

## 📖 10. Traducción

| Concepto | Access / T-SQL | Postgres | MySQL | Oracle |
|---|---|---|---|---|
| cadena vacía | distinta de `NULL` | distinta de `NULL` | distinta de `NULL` | **es `NULL`** |
| `NOT IN` con un `NULL` | ninguna fila | ninguna fila | ninguna fila | ninguna fila |
| igualdad que trata `NULL` como valor | `IS NOT DISTINCT FROM` desde SQL Server 2022 | `IS NOT DISTINCT FROM` | `<=>` | `DECODE(a, b, 1)` |
| truncar en silencio | `SET ANSI_WARNINGS OFF` | nunca | sin `STRICT_TRANS_TABLES` | nunca |
| orden garantizado | solo con `ORDER BY` | solo con `ORDER BY` | solo con `ORDER BY` | solo con `ORDER BY` |

Hacia la NoSQL Lite: un documento sin el campo no es lo mismo que un campo en `null`, y las dos se
consultan distinto: es el mismo problema con un cuarto valor. El diccionario completo está en
[`a07`](a07-diccionario-y-glosario.md).

---

## ⚖️ 11. Veredicto honesto: cuándo NO usar esto

**Cuándo no pelear con `NULL`.** Hay datos que de verdad no se conocen: la fecha de entrega de un
protocolo en proceso, el médico de un protocolo de la caja (el 7 % no lo tiene). Prohibir el `NULL` ahí
obliga a inventar un valor, y eso es peor.

**El anti-patrón inverso: los centinelas.** La caja trae los suyos, en las tablas anchas: en
`Hemograma.Hemoglobina` hay **372 `-`, 371 `VER OBS` y 361 vacíos**. Un centinela es un `NULL` con
disfraz: no se puede promediar, no se puede comparar, y cada consulta tiene que conocerlo. Si el dato no
está, es `NULL`; si hay un motivo, va en otra columna.

**Lo que esta fase pierde:** el `LEFT JOIN` y la clave en precios no recuperan las 88 prácticas sin obra
social. Para eso hace falta saber de quién es el protocolo, y es el Bloque I entero.

Las cinco preguntas, para lo que enseñó esta fase:

- **Frontera transaccional:** la presentación de un mes es una unidad: se arma entera o no se presenta.
- **Consultas conocidas:** la presentación cambia con cada convenio, y por eso tiene que poder escribirse
  bien en SQL, no precalcularse.
- **Unidad de lectura:** filas de cinco tablas; aquí no hay documento que ayude.
- **Saltos:** tres `JOIN` conocidos, el terreno del modelo relacional.
- **Exactitud o parecido:** exactitud. `DISTINCT` es parecido, y por eso falló.

---

## ⚠️ 12. Errores comunes y diagnóstico

- **Una consulta que devuelve cero filas y no debería.** 🩺 ¿Tiene un `NOT IN` contra una subconsulta?
  `SELECT count(*) FROM (subconsulta) WHERE columna IS NULL`. Si da más de cero, cámbialo por
  `NOT EXISTS`.
- **Un total más alto que la suma de sus partes.** 🩺 Cuenta las filas del `JOIN` contra las de la tabla
  principal; si hay más, el otro lado no tiene una fila por valor. Busca la clave que falta, no el
  `DISTINCT`.
- **`ORA-01400: cannot insert NULL into (…)`** al migrar a Oracle una columna con `''`. 🩺 `SELECT count(*)
  FROM … WHERE columna = ''` en el origen. Decide qué significa antes de cargar.
- **`ERROR 1265` o `ERROR 1406` en MySQL** con datos que "siempre entraron". 🩺 `SELECT @@sql_mode`: el
  origen corría sin modo estricto, y lo que entró ya estaba truncado.

---

## 📋 13. Checklist de validación

```text
[ ] ruben_presentation.sql devuelve 1.314 filas y 1.203 prácticas sobre M
[ ] contra truth.order_payer, PAMI tiene 1.413 prácticas en diciembre de 2009
[ ] sé explicar las 88, las 122 y las 111
[ ] NOT IN devuelve 0 y NOT EXISTS 5.893.632, y sé por qué
[ ] fixed_presentation.sql devuelve 1.325 prácticas, 1.203 con precio
[ ] reproduje ORA-01400 con una cadena vacía
```

---

## 🧪 14. Ejercicios (22)

## 🟢 Fácil — los tres valores, a mano (1–7)

### 🟢 Ejercicio 1 — Vacías y nulas

Cuenta, para 2009, los protocolos con la obra social en `NULL` y los que la tienen en `''`.

**Objetivo:** los dos números y el total de protocolos del año.

[Solución](soluciones/03-lo-que-sql-le-hace-al-modelo.md#ejercicio-1)

### 🟢 Ejercicio 2 — Lo que `COUNT` no cuenta

Cuenta en `legacy."Pacientes"` las filas y las que tienen `DNI`.

**Pregunta:** ¿cuántos pacientes no tienen DNI, y qué función lo dice sin un `WHERE`?

[Solución](soluciones/03-lo-que-sql-le-hace-al-modelo.md#ejercicio-2)

### 🟢 Ejercicio 3 — `= NULL`

Cuenta los protocolos de diciembre de 2009 con `"ObraSocial" = NULL` y con `"ObraSocial" IS NULL`.

**Objetivo:** 0 y 39, y la explicación en una línea.

[Solución](soluciones/03-lo-que-sql-le-hace-al-modelo.md#ejercicio-3)

### 🟢 Ejercicio 4 — `NOT IN` contra `NOT EXISTS`

Ejecuta las dos consultas de la sección 5.2 sobre `Practicas`.

**Objetivo:** 0 y 5.893.632, y la fila de `Practicas` que lo provoca.

[Solución](soluciones/03-lo-que-sql-le-hace-al-modelo.md#ejercicio-4)

### 🟢 Ejercicio 5 — Una bolsa

Encuentra en `legacy."Errores de pegado"` tres filas que estén repetidas.

**Objetivo:** las tres, con cuántas veces aparece cada una.

[Solución](soluciones/03-lo-que-sql-le-hace-al-modelo.md#ejercicio-5)

### 🟢 Ejercicio 6 — El orden que no existe

Reproduce la tabla temporal de la sección 5.3 y su `UPDATE`.

**Objetivo:** ver cómo cambia el orden, y la consulta que lo vuelve estable.

[Solución](soluciones/03-lo-que-sql-le-hace-al-modelo.md#ejercicio-6)

### 🟢 Ejercicio 7 — La cadena vacía en Oracle

Ejecuta en Oracle y en Postgres la consulta `CASE WHEN '' IS NULL …` de la sección 6.

**Objetivo:** las dos respuestas, y la línea de la documentación de Oracle que lo explica.

[Solución](soluciones/03-lo-que-sql-le-hace-al-modelo.md#ejercicio-7)

## 🟡 Intermedio — la presentación, pieza por pieza (8–13)

### 🟡 Ejercicio 8 — La consulta de Rubén

Ejecuta `ruben_presentation.sql` sobre M.

**Objetivo:** 1.314 filas, 1.203 prácticas y $26.524,17, y por qué filas y prácticas no coinciden.

[Solución](soluciones/03-lo-que-sql-le-hace-al-modelo.md#ejercicio-8)

### 🟡 Ejercicio 9 — Los precios repetidos

Encuentra los códigos repetidos de `Precios_2009_12` y cuántas filas de la presentación de PAMI los usan.

**Objetivo:** los dos códigos y las 111 filas.

[Solución](soluciones/03-lo-que-sql-le-hace-al-modelo.md#ejercicio-9)

### 🟡 Ejercicio 10 — Las prácticas sin precio

Encuentra las prácticas de PAMI de ese mes que no tienen precio en la tabla del mes.

**Objetivo:** las dos prácticas, cuántas veces aparece cada una, y la tabla de precios donde sí estaban.

[Solución](soluciones/03-lo-que-sql-le-hace-al-modelo.md#ejercicio-10)

### 🟡 Ejercicio 11 — Contra la verdad

Mide con `truth.order_payer` cuántas prácticas de PAMI de diciembre de 2009 tienen la obra social vacía,
separando `NULL` y `''`.

**Objetivo:** 66 y 22.

[Solución](soluciones/03-lo-que-sql-le-hace-al-modelo.md#ejercicio-11)

### 🟡 Ejercicio 12 — MySQL sin modo estricto

Reproduce en MySQL el `INSERT` de la sección 6 con el modo de fábrica y con `sql_mode = ''`.

**Objetivo:** los dos errores, las dos advertencias y lo que quedó guardado.

[Solución](soluciones/03-lo-que-sql-le-hace-al-modelo.md#ejercicio-12)

### 🟡 Ejercicio 13 — `<>` contra `IS DISTINCT FROM`

Cuenta los protocolos de diciembre de 2009 cuya obra social no es `PAMI` con las dos formas.

**Pregunta:** ¿cuál es la diferencia, y cuál usarías para "todos los protocolos que no son de PAMI"?

[Solución](soluciones/03-lo-que-sql-le-hace-al-modelo.md#ejercicio-13)

## 🟠 Difícil — diagnosticar (14–18)

### 🟠 Ejercicio 14 — Qué sacó `DISTINCT`

Aplica `DISTINCT` a la presentación de Rubén y averigua qué filas sacó.

**Objetivo:** demostrar con una consulta que las 33 filas eliminadas eran prácticas reales, y que las 111
repetidas siguen.

[Solución](soluciones/03-lo-que-sql-le-hace-al-modelo.md#ejercicio-14)

### 🟠 Ejercicio 15 — La presentación corregida

Escribe una presentación que no multiplique, no pierda prácticas sin precio y muestre las que no tienen
obra social.

**Objetivo:** 1.325 prácticas, 1.203 con precio, $23.154,21, y el conteo de los protocolos para revisar.

[Solución](soluciones/03-lo-que-sql-le-hace-al-modelo.md#ejercicio-15)

### 🟠 Ejercicio 16 — La consulta que murió en 2020

El `NOT IN` contra `CodINOS` funcionaba hasta un día.

**Pregunta:** ¿qué día, por qué, y cuál es la corrección mínima que mantiene `NOT IN`?

[Solución](soluciones/03-lo-que-sql-le-hace-al-modelo.md#ejercicio-16)

### 🟠 Ejercicio 17 — La rotura, en los dos motores

Reproduce el `NOT NULL` de la sección 8 en Postgres y en Oracle.

**Objetivo:** los dos mensajes literales y una regla de migración para los `''` de la caja.

[Solución](soluciones/03-lo-que-sql-le-hace-al-modelo.md#ejercicio-17)

### 🟠 Ejercicio 18 — Los centinelas

Cuenta en `Hemograma.Hemoglobina` los valores que no son un número.

**Pregunta:** ¿qué significa cada uno, y cuáles serían `NULL` en el modelo nuevo?

[Solución](soluciones/03-lo-que-sql-le-hace-al-modelo.md#ejercicio-18)

## 🔴 Muy difícil — otro mes, otra obra social (19–22)

### 🔴 Ejercicio 19 — OSDE, abril de 2010

Antes de ejecutar nada, predice qué va a perder la consulta de Rubén para OSDE en abril de 2010. Después,
mídelo contra la verdad.

**Objetivo:** la predicción, el número real de prácticas perdidas y repetidas, y cada pérdida explicada.

[Solución](soluciones/03-lo-que-sql-le-hace-al-modelo.md#ejercicio-19)

### 🔴 Ejercicio 20 — La apuesta de Oracle

Resuelve en tu máquina la apuesta 🪞🔒 de la sección 6.

**Objetivo:** explicar el resultado con la documentación de Oracle, sin publicar ningún número.

[Solución](soluciones/03-lo-que-sql-le-hace-al-modelo.md#ejercicio-20)

### 🔴 Ejercicio 21 — El promedio del coseguro

Calcula el coseguro promedio de 2025 con `avg("Coseguro")` y con `avg(coalesce("Coseguro", 0))`.

**Pregunta:** ¿cuál es el correcto, y qué tendrías que saber del negocio para decidirlo?

[Solución](soluciones/03-lo-que-sql-le-hace-al-modelo.md#ejercicio-21)

### 🔴 Ejercicio 22 — Cuándo la obra social puede ser `NULL`

Diseña la columna de obra social del protocolo en el modelo nuevo.

**Objetivo:** el tipo, si admite `NULL` y por qué, qué pasa con los particulares y con los 88 de la
caja, y la restricción que lo defiende.

[Solución](soluciones/03-lo-que-sql-le-hace-al-modelo.md#ejercicio-22)

---

## 📚 15. Referencias

**Documentación oficial**

- **Comparaciones y `IS DISTINCT FROM` en Postgres 18** — https://www.postgresql.org/docs/18/functions-comparison.html
- **`NOT IN` y `NOT EXISTS` en Postgres 18** — https://www.postgresql.org/docs/18/functions-subquery.html —
  el comportamiento con `NULL`, documentado.
- **Los `NULL` en Oracle** — https://docs.oracle.com/en/database/oracle/oracle-database/23/sqlrf/Nulls.html —
  la cadena vacía como `NULL`.
- **El modo estricto de MySQL 9.7** — https://dev.mysql.com/doc/refman/9.7/en/sql-mode.html

**Papers y libros**

- **C. J. Date, *SQL and Relational Theory*, 3.ª ed., O'Reilly, 2015** — duplicados, `NULL` y orden, con
  el argumento completo de la sección 5.4.
- **Bill Karwin, *SQL Antipatterns, Volume 1*, Pragmatic Bookshelf, 2022** — los capítulos de los valores
  `NULL` y de las claves que faltan.

**Orden de lectura sugerido:** la documentación de subconsultas antes de la sección 5.2; Date después de
la fase, para el argumento de fondo.

> ⚠️ Las URL y sus contenidos cambian. Se consultaron el 12/10/2026; el enlace de Oracle es de la versión
> 23, que la documentación de 26ai mantiene.

---

## 🏁 16. Resultado de la fase

```text
LA PRESENTACIÓN DE DICIEMBRE DE 2009 A PAMI · perfil M
  verdad                         1.413 prácticas
  consulta de Rubén              1.203 prácticas en 1.314 filas · $26.524,17
    perdidas por obra social vacía      88
    perdidas por precio faltante       122
    filas de precio repetido           111
  corregida                      1.325 prácticas · 1.203 con precio · $23.154,21
  NOT IN contra CodINOS          0 filas desde el 20/03/2020
```

> **La señal de que quedó bien:** *"Puedo explicar cada una de las 210 prácticas que faltan y de las 111
> filas que sobran, y ninguna con la palabra 'bug'."*

> 🏷️ **No cierres la fase sin el tag.** Con el checklist en verde y `git status` limpio:
>
> ```bash
> git tag -a fase-03-lo-que-sql-le-hace-al-modelo -m "F03 cerrada: la presentación medida contra la verdad, NOT IN, DISTINCT y la cadena vacía de Oracle"
> ```
>
> Commits de la fase con prefijo `f03:`, los de ejercicio `f03 ej17: …`.
