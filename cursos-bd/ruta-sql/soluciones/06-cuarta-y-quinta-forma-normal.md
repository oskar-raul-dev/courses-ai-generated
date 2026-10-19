# ✅ Soluciones — Fase 06: Cuarta y quinta forma normal

> **Curso:** Ruta SQL · Solucionario de la [Fase 06](../06-cuarta-y-quinta-forma-normal.md)
> **Ejercicios:** 20 · **Perfil:** M · **Motores:** Postgres y MySQL de
> [`a02`](../a02-compose-de-la-ruta.md#-las-versiones-del-curso); Python 3.13, solo la biblioteca estándar
> **Fecha de verificación ejecutada:** 13/10/2026

> ⚠️ **Intenta el ejercicio antes de leer su solución.** Leída antes, solo te enseña a reconocerla.

Todas las soluciones suponen M cargado en Postgres, los scripts de `src/04-un-valor-un-hecho/` corridos (F06
usa `alameda.payer` y `staging.payer_alias`) y los de `src/06-cuarta-y-quinta-forma-normal/` en orden, con la
planilla cargada entre el 02 y el 03.

---

## 🟢 Fácil (1–6)

### Ejercicio 1

**Enunciado (resumen):** cargar la planilla de convenios.

**Solución.** Desde `src/`, después de `02_agreement_raw.sql`:

```bash
python3 -I 06-cuarta-y-quinta-forma-normal/xlsx_to_csv.py lab/caja/m/planillas/convenios_2026.xlsx \
  | psql -c "\copy staging.agreement_raw FROM STDIN CSV HEADER"
```

```text
COPY 1422
```

```sql
-- postgres
SELECT count(*) AS filas, count(DISTINCT payer) AS obras_sociales,
       count(DISTINCT practice) AS practicas, count(DISTINCT site) AS sedes
FROM staging.agreement_raw;
```

```text
 filas | obras_sociales | practicas | sedes
-------+----------------+-----------+-------
  1422 |             10 |        75 |     5
(1 row)
```

`xlsx_to_csv.py` abre el `.xlsx` como lo que es, un ZIP con XML adentro, y no necesita ninguna biblioteca. La
clave primaria de `agreement_raw` (las tres columnas) es la primera comprobación: si la planilla tuviera una
fila repetida, el `\copy` fallaría.

[← Volver al ejercicio](../06-cuarta-y-quinta-forma-normal.md#-ejercicio-1--la-planilla)

### Ejercicio 2

**Enunciado (resumen):** las tres proyecciones.

**Solución.**

```sql
-- postgres
SELECT (SELECT count(*) FROM (SELECT DISTINCT payer, practice FROM staging.agreement_raw) AS a) AS pp,
       (SELECT count(*) FROM (SELECT DISTINCT practice, site FROM staging.agreement_raw) AS a) AS ps,
       (SELECT count(*) FROM (SELECT DISTINCT payer, site FROM staging.agreement_raw) AS a) AS ys;
```

```text
 pp  | ps  | ys
-----+-----+----
 556 | 241 | 38
(1 row)
```

835 filas en total, contra las 1.422 de la planilla. Que sean menos no prueba nada todavía: la prueba es el
ejercicio 3.

[← Volver al ejercicio](../06-cuarta-y-quinta-forma-normal.md#-ejercicio-2--las-tres-proyecciones)

### Ejercicio 3

**Enunciado (resumen):** la vista contra la planilla, en las dos direcciones.

**Solución.**

```sql
-- postgres
SELECT count(*) AS vista FROM alameda.agreement;

SELECT count(*) AS espurias
FROM alameda.agreement AS g
JOIN alameda.practice_code AS c ON c.practice_id = g.practice_id AND c.nomenclator_code = 'NBU2012'
WHERE NOT EXISTS (SELECT 1 FROM staging.agreement_raw AS a
                  WHERE a.payer = g.payer_code AND a.practice = c.code AND a.site = g.site_code);

SELECT count(*) AS perdidas
FROM staging.agreement_raw AS a
JOIN alameda.practice_code AS c ON c.nomenclator_code = 'NBU2012' AND c.code = a.practice
WHERE NOT EXISTS (SELECT 1 FROM alameda.agreement AS g
                  WHERE g.payer_code = a.payer AND g.practice_id = c.practice_id AND g.site_code = a.site);
```

```text
 vista
-------
  1422
(1 row)

 espurias
----------
        0
(1 row)

 perdidas
----------
        0
(1 row)
```

Las dos direcciones hacen falta. "Misma cantidad de filas" no alcanza: podría haber tantas espurias como
perdidas.

[← Volver al ejercicio](../06-cuarta-y-quinta-forma-normal.md#-ejercicio-3--el-join-que-vuelve)

### Ejercicio 4

**Enunciado (resumen):** pacientes con dos teléfonos.

**Solución.**

```sql
-- postgres
SELECT count(*) FILTER (WHERE "Telefono" LIKE '% / %') AS con_dos_telefonos, count(*) AS pacientes
FROM legacy."Pacientes";
```

```text
 con_dos_telefonos | pacientes
-------------------+-----------
              4799 |    242427
(1 row)
```

El separador es ` / `, con espacios, como en `15-149280 / 15-6660461`. Por eso `05_patient_contacts.sql`
parte con `string_to_table(…, ' / ')`, y `patient_phone` tiene 242.427 + 4.799 = 247.226 filas.

[← Volver al ejercicio](../06-cuarta-y-quinta-forma-normal.md#-ejercicio-4--dos-teléfonos)

### Ejercicio 5

**Enunciado (resumen):** los códigos de la creatininemia.

**Solución.**

```sql
-- postgres
SELECT p.description, c.nomenclator_code, c.code
FROM alameda.practice_code AS c JOIN alameda.practice AS p USING (practice_id)
WHERE p.practice_id = 4 ORDER BY 2;
```

```text
  description  | nomenclator_code |  code
---------------+------------------+--------
 CREATININEMIA | INOS             | 410
 CREATININEMIA | NBU              | 660004
 CREATININEMIA | NBU2012          | 660504
(3 rows)
```

Un informe de 2015 elegiría la columna según el nomenclador del protocolo, que en 2015 puede ser cualquiera de
los dos NBU: `CodNBU` para unas obras sociales y `CodNBU2012` para otras. Es el `CASE` que el catálogo
versionado reemplaza por un join con `nomenclator_code`.

[← Volver al ejercicio](../06-cuarta-y-quinta-forma-normal.md#-ejercicio-5--los-tres-códigos-de-una-práctica)

### Ejercicio 6

**Enunciado (resumen):** convenios por sede.

**Solución.**

```sql
-- postgres
SELECT s.site_code, s.name, count(a.*) AS convenios
FROM alameda.site AS s LEFT JOIN staging.agreement_raw AS a ON a.site = s.site_code
GROUP BY 1, 2 ORDER BY 1;
```

```text
 site_code |              name              | convenios
-----------+--------------------------------+-----------
 A         | Alta Córdoba                   |       228
 C         | Laboratorio Central            |       556
 E         | Autohisopado (estacionamiento) |         0
 J         | Barrio Jardín                  |       175
 R         | Cerro de las Rosas             |       214
 V         | Villa Allende                  |       249
(6 rows)
```

El autohisopado de 2020 no tiene convenios en la planilla: hace una sola práctica, el hisopado, y no figura
como sede en los convenios de 2026. Está bien que exista en `site` sin convenios: la sede es un hecho propio,
y en la planilla no habría forma de registrarla sin inventarle uno. El central tiene 556, uno por cada par de
obra social y práctica, porque atiende a todas y hace todas.

[← Volver al ejercicio](../06-cuarta-y-quinta-forma-normal.md#-ejercicio-6--la-sede-sin-convenios)

---

## 🟡 Intermedio (7–12)

### Ejercicio 7

**Enunciado (resumen):** dos tablas binarias.

**Solución.**

```sql
-- postgres
WITH pp AS (SELECT DISTINCT payer, practice FROM staging.agreement_raw),
     ps AS (SELECT DISTINCT practice, site FROM staging.agreement_raw)
SELECT count(*) AS dos_binarias, count(*) - 1422 AS espurias FROM pp JOIN ps USING (practice);
```

```text
 dos_binarias | espurias
--------------+----------
         1783 |      361
(1 row)
```

Falta el hecho "la sede atiende a la obra social". Sin él, cada obra social que cubre una práctica queda con
convenio en todas las sedes que la hacen, incluidas las que no la atienden. Con dos tablas alcanzaría si la
regla fuera una dependencia multivaluada; no lo es.

[← Volver al ejercicio](../06-cuarta-y-quinta-forma-normal.md#-ejercicio-7--dos-tablas-no-alcanzan)

### Ejercicio 8

**Enunciado (resumen):** las tres tablas de contactos, medidas.

**Solución.**

```sql
-- postgres
SELECT (SELECT count(*) FROM staging.patient_phone) AS telefonos,
       (SELECT count(*) FROM staging.patient_physician) AS medicos,
       (SELECT count(*) FROM staging.patient_contact_combined) AS combinada;
SELECT pg_size_pretty(pg_total_relation_size('staging.patient_phone')) AS tel,
       pg_size_pretty(pg_total_relation_size('staging.patient_physician')) AS med,
       pg_size_pretty(pg_total_relation_size('staging.patient_contact_combined')) AS comb;
SELECT round(count(*)::numeric / count(DISTINCT (legacy_patient_id, phone)), 2) AS copias_por_telefono
FROM staging.patient_contact_combined;
```

```text
 telefonos | medicos | combinada
-----------+---------+-----------
    247226 | 1229411 |   1254558
(1 row)

  tel  |  med  |  comb
-------+-------+--------
 19 MB | 69 MB | 100 MB
(1 row)

 copias_por_telefono
---------------------
                5.15
(1 row)
```

La combinada tiene menos filas que las dos separadas sumadas, porque casi todos tienen un teléfono: para ellos
es la tabla de médicos con el teléfono repetido. Pesa más (100 MB contra 88) y repite cada teléfono 5,15 veces.

[← Volver al ejercicio](../06-cuarta-y-quinta-forma-normal.md#-ejercicio-8--la-combinada)

### Ejercicio 9

**Enunciado (resumen):** pacientes con teléfono fuera de la combinada.

**Solución.**

```sql
-- postgres
SELECT count(DISTINCT f.legacy_patient_id) AS pacientes_con_telefono_sin_medico
FROM staging.patient_phone AS f
WHERE NOT EXISTS (SELECT 1 FROM staging.patient_physician AS m WHERE m.legacy_patient_id = f.legacy_patient_id);
```

```text
 pacientes_con_telefono_sin_medico
-----------------------------------
                              3608
(1 row)
```

No tienen ningún protocolo con médico, y la combinada no tiene una fila "teléfono sin médico" que no ponga un
`NULL` en su clave. Es la anomalía de inserción de libro, medida: un hecho que no se puede guardar porque el
otro no existe.

[← Volver al ejercicio](../06-cuarta-y-quinta-forma-normal.md#-ejercicio-9--los-que-pierden-el-teléfono)

### Ejercicio 10

**Enunciado (resumen):** traducir el INOS al NBU 2012, de dos maneras.

**Solución.**

```sql
-- postgres
SELECT count(*) AS filas_inos,
       count(*) FILTER (WHERE e."CodNBU2012" IS NOT NULL) AS por_equivalencias,
       count(*) FILTER (WHERE t.code IS NOT NULL) AS por_practice_code
FROM legacy."ProtocoloPracticas" AS pp
LEFT JOIN legacy."EquivalenciasCodigos" AS e ON e."CodINOS" = pp."CodigoPractica"
LEFT JOIN alameda.practice_code AS f ON f.nomenclator_code = 'INOS' AND f.code = pp."CodigoPractica"
LEFT JOIN alameda.practice_code AS t ON t.nomenclator_code = 'NBU2012' AND t.practice_id = f.practice_id
WHERE pp."Nomenclador" = 'INOS';
```

```text
 filas_inos | por_equivalencias | por_practice_code
------------+-------------------+-------------------
     238482 |             90446 |            238482
(1 row)
```

La tabla de equivalencias pierde de dos formas: prácticas que no tienen fila (72.836 filas facturadas) y filas
sin el código de 2012 (75.200). Las equivalencias que sí tiene no contradicen a `Practicas` en ningún caso: no
está mal, está incompleta.

[← Volver al ejercicio](../06-cuarta-y-quinta-forma-normal.md#-ejercicio-10--la-tabla-de-equivalencias)

### Ejercicio 11

**Enunciado (resumen):** el análisis de orina en Villa Allende.

**Solución.**

```sql
-- postgres
SELECT count(*) AS filas_en_la_planilla
FROM alameda.payer_practice AS pp
JOIN alameda.payer_site AS ys ON ys.payer_code = pp.payer_code AND ys.site_code = 'V'
WHERE pp.practice_id = 20;
```

```text
 filas_en_la_planilla
----------------------
                    8
(1 row)
```

En el modelo, `INSERT INTO alameda.practice_site VALUES (20, 'V');`: una fila, y la vista muestra los ocho
convenios. En la planilla, ocho filas que alguien tiene que deducir aplicando la regla a mano, y que pueden
quedar siete.

[← Volver al ejercicio](../06-cuarta-y-quinta-forma-normal.md#-ejercicio-11--una-práctica-nueva-en-una-sede)

### Ejercicio 12

**Enunciado (resumen):** leer un convenio en la planilla y en la vista.

**Solución.**

```sql
-- postgres
EXPLAIN (ANALYZE, BUFFERS, COSTS OFF)
SELECT 1 FROM staging.agreement_raw WHERE payer = 'OSDE' AND practice = '660007' AND site = 'V';
EXPLAIN (ANALYZE, BUFFERS, COSTS OFF)
SELECT 1 FROM alameda.agreement WHERE payer_code = 'OSDE' AND practice_id = 7 AND site_code = 'V';
```

```text
 Index Only Scan using agreement_raw_pkey on agreement_raw (actual time=0.014..0.014 rows=1.00 loops=1)
   Index Cond: ((payer = 'OSDE'::text) AND (practice = '660007'::text) AND (site = 'V'::bpchar))
   Buffers: shared hit=3

 Nested Loop (actual time=0.030..0.032 rows=1.00 loops=1)
   Buffers: shared hit=7
   ->  Nested Loop (actual time=0.025..0.026 rows=1.00 loops=1)
         ->  Index Only Scan using payer_practice_pkey on payer_practice pp (… rows=1.00 loops=1)
               Buffers: shared hit=3
         ->  Index Only Scan using practice_site_pkey on practice_site ps (… rows=1.00 loops=1)
               Buffers: shared hit=2
   ->  Index Only Scan using payer_site_pkey on payer_site ys (… rows=1.00 loops=1)
         Buffers: shared hit=2
```

Cada paso usa la clave primaria de su tabla, y la vista lee 7 bloques contra 3. Es más del doble, y no
importa: son 835 filas que viven en memoria. Lo que se mide es la forma, y la forma es un join de tres índices.

[← Volver al ejercicio](../06-cuarta-y-quinta-forma-normal.md#-ejercicio-12--lo-que-cuesta-leer)

---

## 🟠 Difícil (13–17)

### Ejercicio 13

**Enunciado (resumen):** la variante no cíclica.

**Solución.** Después de `04_noncyclic.sql`:

```sql
-- postgres
WITH t AS (SELECT * FROM staging.agreement_noncyclic),
     pp AS (SELECT DISTINCT payer, practice FROM t),
     ps AS (SELECT DISTINCT practice, site FROM t),
     ys AS (SELECT DISTINCT payer, site FROM t),
     j AS (SELECT pp.payer, pp.practice, ps.site
           FROM pp JOIN ps USING (practice) JOIN ys ON ys.payer = pp.payer AND ys.site = ps.site)
SELECT (SELECT count(*) FROM t) AS ternaria, (SELECT count(*) FROM pp) AS pp, (SELECT count(*) FROM ps) AS ps,
       (SELECT count(*) FROM ys) AS ys, (SELECT count(*) FROM j) AS rejoin,
       (SELECT count(*) FROM j WHERE NOT EXISTS (SELECT 1 FROM t WHERE t.payer = j.payer AND t.practice = j.practice AND t.site = j.site)) AS espurias,
       (SELECT count(*) FROM t WHERE NOT EXISTS (SELECT 1 FROM j WHERE t.payer = j.payer AND t.practice = j.practice AND t.site = j.site)) AS perdidas;
```

```text
 ternaria | pp  | ps  | ys | rejoin | espurias | perdidas
----------+-----+-----+----+--------+----------+----------
     1305 | 548 | 241 | 38 |   1412 |      107 |        0
(1 row)
```

Se excluyeron 117 convenios y el join inventa 107. La diferencia son 10 exclusiones que se llevaron también su
par de obra social y práctica (556 pasan a 548): sin el par, el join no tiene con qué inventarlas.

**Rúbrica.** Una respuesta correcta tiene que:
- comparar en las dos direcciones;
- explicar por qué las perdidas son siempre cero.

[← Volver al ejercicio](../06-cuarta-y-quinta-forma-normal.md#-ejercicio-13--la-variante-no-cíclica)

### Ejercicio 14

**Enunciado (resumen):** otras semillas.

**Solución.** Con la semilla como parámetro del hash de `04_noncyclic.sql`:

```text
 seed | ternaria | espurias
------+----------+----------
 1996 |     1305 |      107
 1997 |     1270 |      138
 2026 |     1283 |      133
(3 rows)
```

Para que una variante no invente nada, cada convenio excluido tendría que llevarse alguno de sus tres pares:
ser el único convenio de su obra social y práctica, o de su práctica y sede, o de su obra social y sede. Con 1.422
convenios sobre 835 pares, casi ninguno está solo, así que excluir un 10 % al azar siempre deja exclusiones que
el join vuelve a inventar.

**Rúbrica.** Una respuesta correcta tiene que:
- medir al menos otra semilla;
- dar la condición (el convenio excluido se lleva un par) en lugar de probar semillas.

[← Volver al ejercicio](../06-cuarta-y-quinta-forma-normal.md#-ejercicio-14--otra-semilla)

### Ejercicio 15

**Enunciado (resumen):** la dependencia multivaluada de la combinada, demostrada.

**Solución.**

```sql
-- postgres
SELECT count(*) AS reconstruida
FROM (SELECT DISTINCT legacy_patient_id, phone FROM staging.patient_contact_combined) AS a
JOIN (SELECT DISTINCT legacy_patient_id, physician_id FROM staging.patient_contact_combined) AS b
  USING (legacy_patient_id);
```

```text
 reconstruida
--------------
      1254558
(1 row)
```

Exactamente las filas de la combinada: la reconstrucción desde dos proyecciones no inventa nada, y eso es lo
que significa `paciente →→ teléfono` (y, por simetría, `paciente →→ médico`). La combinada se construyó así, de
modo que el resultado era de esperar; el ejercicio es para que la prueba quede escrita, y sirva el día que la
tabla venga de otro lado.

**Rúbrica.** Una respuesta correcta tiene que:
- reconstruir desde proyecciones sobre la misma clave, no sobre el paciente solo;
- distinguir esta prueba (dos proyecciones) de la de la 5FN (tres).

[← Volver al ejercicio](../06-cuarta-y-quinta-forma-normal.md#-ejercicio-15--la-dependencia-multivaluada-demostrada)

### Ejercicio 16

**Enunciado (resumen):** códigos en más de un nomenclador.

**Solución.**

```sql
-- postgres
SELECT count(*) AS codigos_en_dos_nomencladores
FROM (SELECT code FROM alameda.practice_code GROUP BY 1 HAVING count(*) > 1) AS x;
SELECT count(*) AS mismo_codigo_otra_practica
FROM alameda.practice_code AS a
JOIN alameda.practice_code AS b ON a.code = b.code AND a.nomenclator_code < b.nomenclator_code
                                AND a.practice_id <> b.practice_id;
```

```text
 codigos_en_dos_nomencladores
------------------------------
                           68
(1 row)

 mismo_codigo_otra_practica
----------------------------
                          0
(1 row)
```

Hoy, en esta caja, el código solo identificaría la práctica. La clave sigue siendo el par porque eso es una
propiedad de estos datos, no del nomenclador: nada impide que una versión reuse un código para otra práctica, y
una clave por código solo rechazaría esa fila.

**Rúbrica.** Una respuesta correcta tiene que:
- separar lo que dicen los datos de lo que garantiza la regla;
- no proponer una clave por código.

[← Volver al ejercicio](../06-cuarta-y-quinta-forma-normal.md#-ejercicio-16--un-código-dos-nomencladores)

### Ejercicio 17

**Enunciado (resumen):** la prueba de dependencia de join, como función.

**Solución de referencia.**

```sql
-- postgres
CREATE OR REPLACE FUNCTION pg_temp.spurious_join_rows(tbl regclass) RETURNS bigint LANGUAGE plpgsql AS $$
DECLARE n bigint;
BEGIN
    EXECUTE format($q$
        WITH pp AS (SELECT DISTINCT payer, practice FROM %1$s),
             ps AS (SELECT DISTINCT practice, site FROM %1$s),
             ys AS (SELECT DISTINCT payer, site FROM %1$s)
        SELECT count(*) FROM (
            SELECT pp.payer, pp.practice, ps.site
            FROM pp JOIN ps USING (practice) JOIN ys ON ys.payer = pp.payer AND ys.site = ps.site
            EXCEPT
            SELECT payer, practice, site FROM %1$s) AS x$q$, tbl) INTO n;
    RETURN n;
END $$;
SELECT 'staging.agreement_raw' AS tabla, pg_temp.spurious_join_rows('staging.agreement_raw') AS espurias
UNION ALL
SELECT 'staging.agreement_noncyclic', pg_temp.spurious_join_rows('staging.agreement_noncyclic');
```

```text
            tabla            | espurias
-----------------------------+----------
 staging.agreement_raw       |        0
 staging.agreement_noncyclic |      107
(2 rows)
```

Solo cuenta las espurias, porque el join de proyecciones nunca pierde filas. Un cero dice que los datos de hoy
cumplen la dependencia; no dice que la regla sea esa.

**Rúbrica.** Una respuesta correcta tiene que:
- usar las tres proyecciones y comparar con `EXCEPT` (o `NOT EXISTS`);
- dar 0 y 107;
- aclarar qué prueba un cero y qué no.

[← Volver al ejercicio](../06-cuarta-y-quinta-forma-normal.md#-ejercicio-17--es-cíclica)

---

## 🔴 Muy difícil (18–20)

### Ejercicio 18

**Enunciado (resumen):** la 5FN con una tabla de excepciones.

**Solución de referencia.**

```sql
-- postgres
CREATE TEMP TABLE agreement_exclusion AS
SELECT payer, practice, site FROM staging.agreement_raw
EXCEPT SELECT payer, practice, site FROM staging.agreement_noncyclic;

WITH t AS (SELECT * FROM staging.agreement_noncyclic),
     pp AS (SELECT DISTINCT payer, practice FROM t),
     ps AS (SELECT DISTINCT practice, site FROM t),
     ys AS (SELECT DISTINCT payer, site FROM t),
     v AS (SELECT pp.payer, pp.practice, ps.site
           FROM pp JOIN ps USING (practice) JOIN ys ON ys.payer = pp.payer AND ys.site = ps.site
           EXCEPT SELECT payer, practice, site FROM agreement_exclusion)
SELECT (SELECT count(*) FROM agreement_exclusion) AS excepciones, (SELECT count(*) FROM v) AS vista,
       (SELECT count(*) FROM (SELECT * FROM v EXCEPT SELECT * FROM t) AS x) AS espurias,
       (SELECT count(*) FROM (SELECT * FROM t EXCEPT SELECT * FROM v) AS x) AS perdidas;
```

```text
SELECT 117
 excepciones | vista | espurias | perdidas
-------------+-------+----------+----------
         117 |  1305 |        0 |        0
(1 row)
```

Con las 117 exclusiones de la variante funciona, pero sobran 10: las que el join ya no inventaba (ejercicio
13). El mínimo son las **107** espurias del join, y es lo que la tabla debería guardar.

**Rúbrica.** Una respuesta correcta tiene que:
- declarar la excepción como dato, con su clave foránea a los tres hechos;
- dar 107 como mínimo y explicar las 10 que sobran;
- decir cuándo deja de valer la pena (si las excepciones se acercan a los convenios, la ternaria es más
  simple).

Y queda invalidada si:
- abandona la 5FN sin medir cuántas excepciones hay.

[← Volver al ejercicio](../06-cuarta-y-quinta-forma-normal.md#-ejercicio-18--la-excepción-declarada)

### Ejercicio 19

**Enunciado (resumen):** un nomenclador nuevo, en el modelo y en `Practicas`.

**Solución de referencia.** En el modelo, una transacción de prueba (aquí con los códigos de 2012, porque la
caja no trae otra versión):

```sql
-- postgres
BEGIN;
INSERT INTO alameda.nomenclator VALUES ('NBU2016', 'Nomenclador Bioquímico Único, actualización 2016', '2017-01-01');
INSERT INTO alameda.practice_code (nomenclator_code, code, practice_id)
SELECT 'NBU2016', code, practice_id FROM alameda.practice_code WHERE nomenclator_code = 'NBU2012';
SELECT nomenclator_code, count(*) FROM alameda.practice_code GROUP BY 1 ORDER BY 1;
ROLLBACK;
```

```text
INSERT 0 1
INSERT 0 75
 nomenclator_code | count
------------------+-------
 INOS             |    74
 NBU              |    74
 NBU2012          |    75
 NBU2016          |    75
(4 rows)
```

En `Practicas`: `ALTER TABLE "Practicas" ADD "CodNBU2016" nvarchar(20)`, el `UPDATE` de 75 filas, y la lista de
lo que hay que revisar: cada `CASE` que elige columna según el nomenclador (informes, presentación, el portal),
`EquivalenciasCodigos` (otra columna, o una tabla que ya no alcanza), y cada planilla que copia los códigos.

**Rúbrica.** Una respuesta correcta tiene que:
- mostrar que en el modelo no cambia ningún esquema ni ninguna consulta;
- listar lo que hay que buscar en el viejo, no solo el `ALTER TABLE`.

[← Volver al ejercicio](../06-cuarta-y-quinta-forma-normal.md#-ejercicio-19--el-nomenclador-que-viene)

### Ejercicio 20

**Enunciado (resumen):** ¿5FN o tabla ternaria para los convenios de Alameda?

**Solución de referencia.** La decisión depende de una pregunta, y hay que hacérsela a quien arma la planilla:
*"¿Hay algún convenio que no exista aunque la obra social cubra la práctica, la sede la haga y la sede atienda
a la obra social?"*

- **Si la respuesta es "nunca"**, la 5FN: los datos de 2026 lo confirman (0 espurias), abrir una práctica en una
  sede es una fila y no ocho, dejar de atender a una obra social en una sede es una fila y no 29, y el join cuesta
  7 bloques contra 3.
- **Si es "a veces"**, la 5FN con la tabla de excepciones del ejercicio 18, si son pocas.
- **Si es "depende de cada obra social"**, la ternaria con su clave: la regla no es cíclica y la descomposición
  inventaría convenios (107 con un 10 % de excepciones).

**Rúbrica.** Una respuesta correcta tiene que:
- formular la pregunta en términos del negocio, no de formas normales;
- usar los números de la fase (0 y 107 espurias, 8 y 29 filas, 3 y 7 bloques);
- elegir según la respuesta, no según los datos de hoy.

Y queda invalidada si:
- decide la 5FN solo porque la planilla de 2026 no da espurias.

[← Volver al ejercicio](../06-cuarta-y-quinta-forma-normal.md#-ejercicio-20--tres-tablas-o-una)
