# ✅ Soluciones — Fase 04: Un valor, un hecho

> **Curso:** Ruta SQL · Solucionario de la [Fase 04](../04-un-valor-un-hecho.md)
> **Ejercicios:** 24 · **Perfil:** M · **Motores:** Postgres y MySQL de
> [`a02`](../a02-compose-de-la-ruta.md#-las-versiones-del-curso); Python 3.13 con el entorno del curso
> **Fecha de verificación ejecutada:** 12/10/2026

> ⚠️ **Intenta el ejercicio antes de leer su solución.** Leída antes, solo te enseña a reconocerla.

---

## 🟢 Fácil (1–7)

### Ejercicio 1

**Enunciado (resumen):** comprobar `CodDeterminacion → Unidad, RangoReferencia`.

**Solución.**

```sql
-- postgres
SELECT count(*) FILTER (WHERE unidades > 1) AS violan_unidad, count(*) FILTER (WHERE rangos > 1) AS violan_rango
FROM (SELECT "CodDeterminacion", count(DISTINCT "Unidad") AS unidades, count(DISTINCT "RangoReferencia") AS rangos
      FROM legacy."ResultadoItem" GROUP BY 1) AS d;
```

```text
 violan_unidad | violan_rango
---------------+--------------
             0 |            0
(1 row)
```

Las dos dependencias se cumplen en los 12,1 millones de filas: la unidad y el rango son de la
determinación.

[← Volver al ejercicio](../04-un-valor-un-hecho.md#-ejercicio-1--la-unidad-es-de-la-determinación)

### Ejercicio 2

**Enunciado (resumen):** DNI con más de un nombre.

**Solución.**

```sql
-- postgres
SELECT count(*) AS dni_con_varios_nombres
FROM (SELECT "DNI" FROM legacy."Pacientes" WHERE "DNI" IS NOT NULL GROUP BY 1 HAVING count(DISTINCT "Nombre") > 1) AS d;
```

```text
 dni_con_varios_nombres
------------------------
                  10903
(1 row)
```

`DNI → Nombre` no se cumple porque la misma persona aparece escrita de varias formas, porque un recién
nacido comparte el DNI de su madre, y porque el campo `DNI` también guarda pasaportes. El DNI no
identifica ni una persona ni un nombre, y es el punto de partida de la [Fase 05](../05-una-persona-no-es-su-documento.md).

[← Volver al ejercicio](../04-un-valor-un-hecho.md#-ejercicio-2--el-dni-no-determina-el-nombre)

### Ejercicio 3

**Enunciado (resumen):** correr los ocho scripts y leer el informe.

**Solución.** Desde `src/04-un-valor-un-hecho/`, contra el Postgres del laboratorio:

```bash
for f in 0*.sql; do docker compose -f ../lab/compose.yaml exec -T postgres psql -U postgres -d alameda -q -v ON_ERROR_STOP=1 < "$f"; done
```

Corrió en 22 s sobre M. El informe es el de la sección 5.5:

```text
                 Regla                  | Filas rechazadas | % de legacy | Contra la verdad
----------------------------------------+------------------+-------------+------------------
 obras_sociales.sin_sigla               |                1 |        4.17 |
 pacientes.dni_con_formato_invalido     |             5408 |        2.23 |             5137
 pacientes.documento_en_nombre          |            25574 |       10.55 |            25575
 pacientes.nacimiento_posterior_al_alta |              442 |        0.18 |              442
 protocolos.obra_social_sin_resolver    |             5167 |        4.92 |             5167
 resultados.protocolo_inexistente       |             2150 |        0.02 |
(6 rows)
```

Correr los scripts dos veces da el mismo informe: `01_staging.sql` borra los rechazos de la fase antes de
recalcularlos.

[← Volver al ejercicio](../04-un-valor-un-hecho.md#-ejercicio-3--el-área-de-carga)

### Ejercicio 4

**Enunciado (resumen):** cuatro nombres de la historia con `staging.extract_dni_2016`.

**Solución.**

```sql
-- postgres
SELECT staging.extract_dni_2016('PEREZ PEDRO DNI 23.456.789') AS a,
       staging.extract_dni_2016('VARGAS MAMANI JUANA PASAP BOL 4455667') AS b,
       staging.extract_dni_2016('ZAPATA ANA OTRO 1234/19') AS c,
       staging.extract_dni_2016('RN GONZALEZ MARIA DNI 11222333') AS d;
```

```text
    a     |    b    | c |    d
----------+---------+---+----------
 23456789 | 4455667 |   | 11222333
(1 row)
```

Difiere del parser de 2026 el tercero: el `.bas` devuelve `OTRO 1234/19` (lo dice su propia prueba,
`ProbarParser`), y la copia de 2016 no conoce `OTRO`. El cuarto da el DNI de la madre en las dos versiones:
es la regla de 2008.

[← Volver al ejercicio](../04-un-valor-un-hecho.md#-ejercicio-4--el-parser-de-2016)

### Ejercicio 5

**Enunciado (resumen):** cargar `Turnos.csv` y separar los exámenes.

**Solución.** `08_appointments.sql`:

```text
 turnos | examenes
--------+----------
 172986 |   837167
(1 row)
```

Un promedio de 4,8 exámenes por turno, que antes vivían en un solo campo.

[← Volver al ejercicio](../04-un-valor-un-hecho.md#-ejercicio-5--los-turnos-una-fila-por-examen)

### Ejercicio 6

**Enunciado (resumen):** un `CHECK` en MySQL que impida nacer después del alta.

**Solución.**

```sql
-- mysql
CREATE TABLE prueba.patient (patient_id INT PRIMARY KEY, birth_date DATE NOT NULL, registered_on DATE NOT NULL,
  CONSTRAINT patient_birth_date_check CHECK (birth_date <= registered_on));
INSERT INTO prueba.patient VALUES (1, '2025-03-15', '1999-06-01');
SELECT VERSION();
```

```text
ERROR 3819 (HY000) at line 5: Check constraint 'patient_birth_date_check' is violated.
+-----------+
| VERSION() |
+-----------+
| 9.7.2     |
+-----------+
```

En MySQL 9.7 el `CHECK` se cumple. Antes de 8.0.16 se aceptaba la sintaxis y se ignoraba.

[← Volver al ejercicio](../04-un-valor-un-hecho.md#-ejercicio-6--el-check-de-mysql-97)

### Ejercicio 7

**Enunciado (resumen):** formas distintas de escribir la obra social antes de 2012.

**Solución.**

```sql
-- postgres
SELECT count(DISTINCT coalesce("ObraSocial", '<NULL>')) AS escrituras,
       count(*) FILTER (WHERE "ObraSocial" IS NULL) AS nulos,
       count(*) FILTER (WHERE "ObraSocial" = '') AS vacios
FROM legacy."Protocolos" WHERE "Fecha" < '2012-01-01';
```

```text
 escrituras | nulos | vacios
------------+-------+--------
         41 |  3160 |  2007
(1 row)
```

41 con el `NULL` como una más, 40 sin él (`count(DISTINCT)` no cuenta los `NULL`): 39 escrituras con texto y la
cadena vacía. Los 3.160 `NULL` y los 2.007 vacíos suman los 5.167 protocolos sin obra social resoluble.

[← Volver al ejercicio](../04-un-valor-un-hecho.md#-ejercicio-7--las-escrituras-de-la-obra-social)

## 🟡 Intermedio (8–14)

### Ejercicio 8

**Enunciado (resumen):** turnos con PCR, con `LIKE` y con la tabla separada.

**Solución.** La consulta de la sección 4: 38.508 con `LIKE` contra 28.222 exactos. La diferencia, 10.286,
son los turnos con `COVPCR`, que contiene la cadena `PCR`. Con la tabla separada,
`SELECT count(*) FROM staging.appointment_exam WHERE exam_code = 'PCR'` da 28.222.

[← Volver al ejercicio](../04-un-valor-un-hecho.md#-ejercicio-8--like-sobre-un-campo-multivalor)

### Ejercicio 9

**Enunciado (resumen):** cuánto acierta `staging.extract_dni_2016`.

**Solución.**

```sql
-- postgres
SELECT count(*) FILTER (WHERE staging.extract_dni_2016(p."Nombre") = coalesce(pc.expected_dni, '')) AS aciertos,
       count(*) AS filas
FROM legacy."Pacientes" AS p
JOIN truth.patient_record AS r ON r.legacy_patient_id = p."IdPaciente"
LEFT JOIN truth.parser_case AS pc ON pc.legacy_patient_id = p."IdPaciente"
WHERE 'dni_in_name' = ANY (r.dirt);
```

```text
 aciertos | filas
----------+-------
    23045 | 25575
(1 row)
```

El 90,1 %. El `coalesce` cuenta como acierto que el parser no devuelva nada cuando la verdad dice que no
hay un documento propio que extraer, como en el recién nacido con el DNI de la madre.

[← Volver al ejercicio](../04-un-valor-un-hecho.md#-ejercicio-9--el-90--de-rubén)

### Ejercicio 10

**Enunciado (resumen):** los nombres cuya fecha leen distinto los dos parsers.

**Solución.** Con el script de comparación de la sección 7 (el port de Python de 2026 contra el de PL/pgSQL
de 2016, fila por fila):

```text
fecha distinta entre 2026 y 2016: 115
  'CORDOBA MONICA DNI 6659374 12/03/46': VBA 12/03/1946 · T-SQL 12/03/2046
  'HUANCA FLORES LAURA DNI A8069632 18/07/47': VBA 18/07/1947 · T-SQL 18/07/2047
  'MORALES NICOLAS MIGUEL DNI 5994305 19/04/36': VBA 19/04/1936 · T-SQL 19/04/2036
```

Los tres tienen el año entre `30` y `49`. Para el VBA, que sigue la ventana de Windows, del `30` al `99` es
19xx; para SQL Server, con su corte por defecto en 2049, del `00` al `49` es 20xx. Fuera de esa franja, los dos
coinciden.

[← Volver al ejercicio](../04-un-valor-un-hecho.md#-ejercicio-10--un-siglo-de-diferencia)

### Ejercicio 11

**Enunciado (resumen):** los nombres con `OTRO` y qué devuelve el parser de 2016.

**Solución.**

```sql
-- postgres
SELECT "Nombre", staging.extract_dni_2016("Nombre") AS dni_2016
FROM legacy."Pacientes" WHERE "Nombre" ~ '\mOTRO\M' ORDER BY "IdPaciente";
```

```text
                   Nombre                    | dni_2016
---------------------------------------------+----------
 PEÑA LAURA CARMEN OTRO 9242/22              |
 FERNANDEZ ESTEBAN RAUL DNI OTRO 7965/23     | OTRO
 PEREZ CEBALLOS GRACIELA MONICA OTRO 9971/25 |
 SUAREZ MARCELO DNI OTRO 8018/20             | OTRO
 VILLARREAL LUIS RAMON OTRO 8895/20          |
 FERREYRA SERGIO DNI OTRO 7465/20            | OTRO
 PEREYRA MARCELO DNI OTRO 3226/22            | OTRO
(7 rows)
```

Cuando la recepción escribió `DNI OTRO …`, los dos parsers toman la palabra que sigue a `DNI`, que es `OTRO`:
dan lo mismo, y los dos se equivocan. Cuando escribió solo `OTRO …`, el de 2026 tiene el parche de 2019 y el de
2016 no: esas tres son las diferencias.

[← Volver al ejercicio](../04-un-valor-un-hecho.md#-ejercicio-11--otro)

### Ejercicio 12

**Enunciado (resumen):** la primera versión de la regla del documento, medida contra la verdad.

**Solución.** Con el patrón `'[0-9]{7,8}|\m(DNI|LC|LE|P|PASAP|OTRO)\M|D\.N\.I\.'`, la regla inserta **26.615**
rechazos, y cruzados con `truth.patient_record`:

```text
 falsos_positivos
------------------
             1041
(1 row)

                value
-------------------------------------
 VERA BEATRIZ LUCIA P.A.M.I.
 GARCIA NATALIA P.A.M.I.
 GARCIA TOMAS EDUARDO A.P.R.O.S.S.
```

`\mP\M` encuentra la `P` aislada de `P.A.M.I.` y `A.P.R.O.S.S.`. La corrección exige el país en tres letras
después de la `P`: `\m(P|PASAP) [A-Z]{3}\M`. Con ella, 25.574 rechazos y 0 falsos positivos.

[← Volver al ejercicio](../04-un-valor-un-hecho.md#-ejercicio-12--la-regla-que-encontraba-la-p-de-pami)

### Ejercicio 13

**Enunciado (resumen):** `IdProtocolo → Nomenclador` y cuántas veces se guarda.

**Solución.**

```sql
-- postgres
SELECT count(*) AS protocolos, count(*) FILTER (WHERE n > 1) AS con_dos_nomencladores
FROM (SELECT "IdProtocolo", count(DISTINCT "Nomenclador") AS n FROM legacy."ProtocoloPracticas" GROUP BY 1) AS d;
```

```text
 protocolos | con_dos_nomencladores
------------+-----------------------
    1327622 |                     0
(1 row)
```

Ningún protocolo mezcla nomencladores, y `ProtocoloPracticas` tiene 6.132.114 filas: el mismo dato,
guardado 6.132.114 veces para 1.327.622 protocolos. En el modelo nuevo va una vez, en el protocolo.

[← Volver al ejercicio](../04-un-valor-un-hecho.md#-ejercicio-13--la-dependencia-parcial)

### Ejercicio 14

**Enunciado (resumen):** lo que ocupan la unidad y el rango repetidos.

**Solución.** La medición de la sección 5.3: 230 MB de 1.309 MB. Las guardaría una vez la tabla de
determinaciones del modelo, con una fila por determinación (33 en la caja), y el resultado se queda con el
código de la determinación y su valor.

[← Volver al ejercicio](../04-un-valor-un-hecho.md#-ejercicio-14--lo-que-pesa-la-transitiva)

## 🟠 Difícil (15–20)

### Ejercicio 15

**Enunciado (resumen):** la sección 8 completa.

**Solución de referencia.** Con `05_keys.sql` corrido, los cuatro pasos y sus mensajes:

```text
ERROR:  insert or update on table "result_item" violates foreign key constraint "result_item_lab_order_id_fkey"
DETAIL:  Key (lab_order_id)=(902271366) is not present in table "lab_order".
ALTER TABLE
ERROR:  insert or update on table "result_item" violates foreign key constraint "result_item_lab_order_id_fkey"
DETAIL:  Key (lab_order_id)=(0) is not present in table "lab_order".
ERROR:  insert or update on table "result_item" violates foreign key constraint "result_item_lab_order_id_fkey"
DETAIL:  Key (lab_order_id)=(-548257407) is not present in table "lab_order".
```

Y `07_orphans.sql`:

```text
INSERT 0 2150
DELETE 2150
ALTER TABLE
```

**Rúbrica.** Una respuesta correcta tiene que:
- mostrar que `NOT VALID` crea la clave y ya rechaza filas nuevas;
- mover los huérfanos a la tabla de rechazos antes de borrarlos de la copia;
- terminar con `VALIDATE` sin error.

Y queda invalidada si:
- borra los huérfanos sin registrarlos, o deja la clave sin validar.

[← Volver al ejercicio](../04-un-valor-un-hecho.md#-ejercicio-15--la-clave-contra-los-huérfanos)

### Ejercicio 16

**Enunciado (resumen):** de dónde salen los huérfanos.

**Solución de referencia.**

```sql
-- postgres
SELECT count(*) AS resultados_huerfanos, count(DISTINCT r."IdProtocolo") AS protocolos_borrados,
       min(r."FechaCarga")::date, max(r."FechaCarga")::date
FROM legacy."ResultadoItem" AS r
WHERE NOT EXISTS (SELECT 1 FROM legacy."Protocolos" AS p WHERE p."IdProtocolo" = r."IdProtocolo");
```

```text
 resultados_huerfanos | protocolos_borrados |    min     |    max
----------------------+---------------------+------------+------------
                 2150 |                 198 | 2008-04-08 | 2011-05-31
(1 row)
```

Desde abril de 2008 existe `ResultadoItem` (los equipos conectados de Matías), y hasta mayo de 2011 la base
fue Access, sin integridad referencial: un protocolo borrado dejaba sus resultados. Desde junio de 2011, en
SQL Server, la clave `WITH NOCHECK` controla las filas nuevas, y por eso no hay huérfanos después.

**Rúbrica.** Una respuesta correcta tiene que:
- dar los tres números;
- relacionar las fechas con la historia (2008 y 2011);
- explicar por qué `WITH NOCHECK` impide huérfanos nuevos y conserva los viejos.

Y queda invalidada si:
- atribuye los huérfanos al generador sin mirar las fechas.

[← Volver al ejercicio](../04-un-valor-un-hecho.md#-ejercicio-16--de-dónde-salen-los-huérfanos)

### Ejercicio 17

**Enunciado (resumen):** los 271 DNI inválidos que no son pasaportes.

**Solución de referencia.**

```sql
-- postgres
SELECT pe.document_type, count(*)
FROM staging.rejection AS j
JOIN truth.patient_record AS r ON r.legacy_patient_id = j.source_key::int
JOIN truth.person AS pe ON pe.person_id = r.person_id
WHERE j.rule = 'pacientes.dni_con_formato_invalido' AND NOT 'passport_in_dni' = ANY (r.dirt)
GROUP BY 1;
```

```text
 document_type | count
---------------+-------
 DNI           |   187
 OTRO          |    76
 PAS           |     8
(3 rows)
```

Los 76 `OTRO` son certificados como `OTRO 1771/19`. Los 195 restantes (187 con DNI y 8 con pasaporte) son
recién nacidos: `truth.patient_record` los marca `newborn_mother_dni`, y su campo `DNI` tiene el pasaporte de
la madre, como `B1912215`. Ninguno es un error de tipeo: son documentos reales en el campo equivocado.

**Rúbrica.** Una respuesta correcta tiene que:
- clasificar los 271 con la verdad;
- distinguir el documento de la persona del documento escrito en su fila.

[← Volver al ejercicio](../04-un-valor-un-hecho.md#-ejercicio-17--los-271-que-no-son-pasaportes)

### Ejercicio 18

**Enunciado (resumen):** la tabla de alias contra la verdad.

**Solución de referencia.**

```sql
-- postgres
SELECT count(*) AS protocolos_resueltos, count(*) FILTER (WHERE a.payer_code <> op.payer_code) AS mal_resueltos
FROM legacy."Protocolos" AS p
JOIN staging.payer_alias AS a ON a.written_as = p."ObraSocial"
JOIN truth.order_payer AS op ON op.legacy_protocol_id = p."IdProtocolo"
WHERE p."Fecha" < '2012-01-01';
```

```text
 protocolos_resueltos | mal_resueltos
----------------------+---------------
                99931 |             0
(1 row)
```

Cada escritura apunta a una sola obra social, así que la tabla de alias es exacta. Los 5.167 sin resolver
tienen la obra social `NULL` o vacía: no hay texto que mapear. Para asignarlos hace falta otra fuente, como la
obra social del paciente en sus otros protocolos, y eso ya es identidad ([Fase 05](../05-una-persona-no-es-su-documento.md)).

**Rúbrica.** Una respuesta correcta tiene que:
- medir la tabla contra `truth`, no contra sí misma;
- explicar por qué los vacíos no tienen solución con el texto.

[← Volver al ejercicio](../04-un-valor-un-hecho.md#-ejercicio-18--la-tabla-de-alias-contra-la-verdad)

### Ejercicio 19

**Enunciado (resumen):** un CUIT mal formado en `alameda.payer`.

**Solución de referencia.**

```text
ERROR:  new row for relation "payer" violates check constraint "payer_tax_id_check"
DETAIL:  Failing row contains (99, PRUEBA, Obra social de prueba, 30-1234567-8, t).
```

El `CHECK` verifica la **forma** (dos dígitos, ocho, uno). El dígito verificador es una cuenta sobre los
otros diez, y un `CHECK` con una expresión regular no la hace. Se puede con un `CHECK` que llame a una función
inmutable, o con un dominio, y es una decisión: más regla en el esquema a cambio de una función más que
mantener.

**Rúbrica.** Una respuesta correcta tiene que:
- reproducir el mensaje;
- distinguir forma de validez;
- proponer dónde vive la validación del dígito, con su costo.

[← Volver al ejercicio](../04-un-valor-un-hecho.md#-ejercicio-19--el-check-del-cuit)

### Ejercicio 20

**Enunciado (resumen):** si viola la 1FN, campo por campo.

**Solución de referencia.**

- **`Pacientes.Nombre`**: viola la 1FN **por el documento** que lleva adentro, que se usa por separado. Sin el
  documento, `APELLIDO NOMBRE` en un campo no la viola mientras nadie consulte el apellido solo.
- **`Pacientes.Direccion`**: no la viola mientras se use entera para imprimir. Si el curso tuviera que agrupar
  por barrio o por código postal, la violaría.
- **`Turnos.ExamenesSolicitados`**: la viola. Es un grupo repetido, y "los turnos con PCR" es una pregunta del
  negocio.
- **`Pacientes.Telefono`** con `SOLO TARDE`: la viola, porque mezcla el número con una nota, y llamar o mandar
  un mensaje necesita el número solo.

**Rúbrica.** Una respuesta correcta tiene que:
- decidir por el **uso**, no por la forma del dato;
- reconocer que un mismo campo puede estar bien o mal según cómo se consulte.

Y queda invalidada si:
- declara que todo campo con espacios viola la 1FN.

[← Volver al ejercicio](../04-un-valor-un-hecho.md#-ejercicio-20--viola-la-1fn)

## 🔴 Muy difícil (21–24)

### Ejercicio 21

**Enunciado (resumen):** qué fecha es la verdadera en los 115 conflictos, primero sin la verdad.

**Solución de referencia.** **El criterio, sin `truth`:** una fecha de nacimiento no puede ser posterior al
alta del paciente. Si la lectura de 2016 cae en 2030–2049 y el paciente se dio de alta antes, esa lectura es
imposible. Aplicado y comparado:

```sql
-- postgres
WITH conflicto AS (
  SELECT p."IdPaciente", p."FechaAlta"::date AS alta,
         staging.extract_birth_date_2016(p."Nombre") AS fecha_2016,
         (staging.extract_birth_date_2016(p."Nombre") - interval '100 years')::date AS fecha_2026
  FROM legacy."Pacientes" AS p
  WHERE staging.extract_birth_date_2016(p."Nombre") BETWEEN '2030-01-01' AND '2049-12-31')
SELECT count(*) AS conflictos,
       count(*) FILTER (WHERE fecha_2016 > alta) AS lectura_2016_posterior_al_alta,
       count(*) FILTER (WHERE pe.birth_date = c.fecha_2026) AS verdad_igual_2026,
       count(*) FILTER (WHERE pe.birth_date = c.fecha_2016) AS verdad_igual_2016
FROM conflicto AS c
JOIN truth.patient_record AS r ON r.legacy_patient_id = c."IdPaciente"
JOIN truth.person AS pe ON pe.person_id = r.person_id;
```

```text
 conflictos | lectura_2016_posterior_al_alta | verdad_igual_2026 | verdad_igual_2016
------------+--------------------------------+-------------------+-------------------
        115 |                            115 |               115 |                 0
(1 row)
```

El criterio resuelve los 115 sin mirar la verdad, y la verdad confirma la lectura de 2026 en todos. El criterio
funciona porque las fechas del conflicto caen en el futuro; no serviría para un año `20`, que los dos parsers
leen como 2020.

**Rúbrica.** Una respuesta correcta tiene que:
- proponer un criterio que no use `truth`;
- aplicarlo y después medirlo contra la verdad;
- decir dónde dejaría de funcionar.

Y queda invalidada si:
- usa `truth` para decidir.

[← Volver al ejercicio](../04-un-valor-un-hecho.md#-ejercicio-21--qué-fecha-es-la-verdadera)

### Ejercicio 22

**Enunciado (resumen):** ampliar el patrón para `DNI1544/23` y medir los falsos positivos.

**Solución de referencia.** Agregando `DNI[0-9]` al patrón:

```sql
-- postgres
SELECT count(*) FILTER (WHERE NOT 'dni_in_name' = ANY (r.dirt)) AS falsos_positivos,
       count(*) FILTER (WHERE 'dni_in_name' = ANY (r.dirt)) AS verdaderos
FROM legacy."Pacientes" AS p
JOIN truth.patient_record AS r ON r.legacy_patient_id = p."IdPaciente"
WHERE p."Nombre" ~ '[0-9]{7,8}|\m(DNI|LC|LE|OTRO)\M|\m(P|PASAP) [A-Z]{3}\M|D\.N\.I\.|DNI[0-9]';
```

```text
 falsos_positivos | verdaderos
------------------+------------
                0 |      25575
(1 row)
```

Los 25.575, sin costo. Que no cueste en esta caja no significa que no cueste en otra: un apellido que empiece
con `DNI` seguido de un número no existe aquí, y la regla lo rechazaría.

**Rúbrica.** Una respuesta correcta tiene que:
- medir verdaderos y falsos positivos después del cambio;
- decir qué caso podría romper el patrón nuevo.

[← Volver al ejercicio](../04-un-valor-un-hecho.md#-ejercicio-22--el-último-documento)

### Ejercicio 23

**Enunciado (resumen):** la regla `precios.codigo_repetido_en_el_mes`.

**Solución de referencia.**

```sql
-- postgres
DO $$
DECLARE t text;
BEGIN
    FOR t IN SELECT table_name FROM information_schema.tables
             WHERE table_schema = 'legacy' AND table_name ~ '^Precios_[0-9]{4}_[0-9]{2}$' LOOP
        EXECUTE format($q$
            INSERT INTO staging.rejection (phase, rule, source_table, source_key, value, detail)
            SELECT '04', 'precios.codigo_repetido_en_el_mes', %L, "CodPractica", string_agg("Valor"::text, ' · '), count(*)::text || ' filas'
            FROM legacy.%I GROUP BY "CodPractica" HAVING count(*) > 1 $q$, t, t);
    END LOOP;
END $$;
```

187 códigos repetidos en las 280 tablas, entre ellos los dos de diciembre de 2009 de la [Fase 03](../03-lo-que-sql-le-hace-al-modelo.md):

```text
  source_table   | source_key |       value
-----------------+------------+-------------------
 Precios_2009_12 | 660006     | 27.6000 · 30.3600
 Precios_2009_12 | 660021     | 78.8500 · 86.7400
(2 rows)
```

**La línea de base es la trampa.** Si se carga `source_rows = 280` (las tablas), el informe dice **66,79 %**,
que no significa nada. La base correcta son las filas de las 280 tablas, **20.554**, y la regla rechaza el
**0,91 %**.

**Rúbrica.** Una respuesta correcta tiene que:
- recorrer las 280 tablas con SQL dinámico y nombres citados (`%I`);
- cargar una línea de base en filas, no en tablas;
- dejar el valor repetido a la vista en `value`.

Y queda invalidada si:
- publica el porcentaje sin revisar qué lo divide.

[← Volver al ejercicio](../04-un-valor-un-hecho.md#-ejercicio-23--una-regla-nueva)

### Ejercicio 24

**Enunciado (resumen):** dónde vive el domicilio, si el protocolo tiene que recordar el de ese día.

**Solución de referencia.** Dos hechos, dos lugares:

- **El domicilio del paciente hoy**: en `patient` o en una tabla de domicilios del paciente con su vigencia,
  si interesa la historia ([Fase 07](../07-el-tiempo-en-el-modelo.md)).
- **El domicilio de la toma de muestra**: en `lab_order`, como columnas propias (`collection_address`), copiado
  al crear el protocolo y nunca actualizado.

**La defensa:** una desnormalización es guardar el mismo hecho en dos lugares, con el riesgo de que diverjan.
Aquí no hay un hecho repetido: "dónde vive hoy" y "dónde vivía el día del protocolo" son dos hechos que
coinciden al principio y se separan con la primera mudanza. Actualizar el protocolo cuando el paciente se muda
sería **perder** un dato.

**Rúbrica.** Una respuesta correcta tiene que:
- separar los dos hechos con sus claves;
- defender la copia en el protocolo como un hecho propio;
- decir que la del protocolo no se actualiza.

Y queda invalidada si:
- normaliza el domicilio del protocolo a una clave foránea al domicilio actual.

[← Volver al ejercicio](../04-un-valor-un-hecho.md#-ejercicio-24--el-domicilio-del-protocolo)
