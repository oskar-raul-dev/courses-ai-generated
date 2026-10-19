# ✅ Soluciones — Fase 25: La migración sin parar

> **Curso:** Ruta SQL · Solucionario de la [Fase 25](../25-la-migracion-sin-parar.md)
> **Ejercicios:** 24 · **Perfil:** M · **Motor:** Postgres 18.6 de [`a02`](../a02-compose-de-la-ruta.md)
> **Fecha de verificación ejecutada:** 15/10/2026

> ⚠️ **Intenta el ejercicio antes de leer su solución.** Leída antes, solo te enseña a reconocerla.

Las soluciones suponen `01_anchas.sql` a `06_sih.sql` corridos, y `05_convivencia.py` recién terminado, con el slot todavía creado. Los ejercicios 1 a 16 están ejecutados con `09_ejercicios.sql`, y su salida se registró en la sesión de verificación del 15/10/2026. Los de 17 a 24 llevan rúbrica, que también está en la lección. Al terminar, borra el slot: `SELECT pg_drop_replication_slot('f25_legacy')`.

---

## 🟢 Fácil (1–7)

### Ejercicio 1

```sql
SELECT typed AS tipada, count(*) AS columnas, count(DISTINCT source_table) AS tablas
FROM staging.wide_column GROUP BY typed ORDER BY typed DESC;
```

```text
 tipada | columnas | tablas
--------+----------+--------
 t      |       33 |     15
 f      |      177 |     56
```

**Lectura:** las 15 tablas de las prácticas de siempre tienen 33 columnas que son analitos del modelo, y su valor entra como número. Las otras 56 aportan 177 columnas que pasan a ser analitos nuevos de texto. Las 71 están en el mapa, y no queda ninguna afuera.

### Ejercicio 2

```sql
SELECT rule, value, count(*) FROM staging.rejection WHERE phase = '25' AND rule LIKE 'anchas.%'
GROUP BY 1, 2 ORDER BY 3 DESC;
```

```text
           rule           |  value  | count
--------------------------+---------+-------
 anchas.valor_no_numerico | -       |  7219
 anchas.valor_no_numerico | VER OBS |  7134
```

**Lectura:** solo dos valores, y ninguno es un número mal escrito: el parser de la Fase 08 lee bien todas las comas y los puntos. No hubo protocolos inexistentes ni celdas repetidas, y por eso esas dos reglas no aparecen.

### Ejercicio 3

```sql
SELECT source_column, count(*) AS resultados FROM staging.wide_result
WHERE source_table = 'Hemograma' GROUP BY 1 ORDER BY 1;
```

```text
 source_column | resultados
---------------+------------
 GlobBlancos   |      28121
 GlobRojos     |      28024
 Hematocrito   |      28091
 Hemoglobina   |      28137
 Plaquetas     |      28027
```

**Lectura:** `Hemograma` tiene 29.241 filas, y cada columna trae entre 28.024 y 28.137 resultados. La diferencia (entre 1.104 y 1.217 por columna) son las celdas vacías, que no son un resultado, y los `-` y `VER OBS` de esa columna, que fueron a rechazos.

### Ejercicio 4

```sql
SELECT count(*) FILTER (WHERE x."Cantidad" <> 1) AS practicas_con_cantidad,
       sum(x."Cantidad") - count(*) AS unidades_de_mas
FROM legacy."ProtocoloPracticas" AS x
JOIN alameda.billed_practice AS b ON b.legacy_order_practice_id = x."Id";
```

```text
 practicas_con_cantidad | unidades_de_mas
------------------------+-----------------
                  32905 |           32905
```

**Lectura:** cada práctica con cantidad distinta de 1 tiene cantidad 2, así que suma una unidad de más. La lección dice 32.866 porque midió antes de la convivencia. Las 39 de diferencia son las prácticas con cantidad 2 que cargó el día comprimido de `05_convivencia.py`, más la que corrige el arnés del 🏆 "Un martes" si ya lo corriste. Es la misma cuenta sobre más filas.

### Ejercicio 5

```sql
SELECT slot_name, plugin, slot_type, active, confirmed_flush_lsn IS NOT NULL AS tiene_posicion
FROM pg_replication_slots WHERE slot_name = 'f25_legacy';
```

```text
 slot_name  |    plugin     | slot_type | active | tiene_posicion
------------+---------------+-----------+--------+----------------
 f25_legacy | test_decoding | logical   | f      | t
```

**Lectura:** `active` es `f` porque el aplicador no mantiene una conexión de replicación abierta: lee con `pg_logical_slot_peek_changes` y avanza con `pg_replication_slot_advance`. Un slot inactivo sigue reteniendo el WAL desde su posición, y por eso se borra al terminar.

### Ejercicio 6

```sql
SELECT table_name, string_agg(privilege_type, ', ' ORDER BY privilege_type) AS permisos
FROM information_schema.role_table_grants
WHERE grantee = 'access_frontend' AND table_schema = 'legacy' GROUP BY 1 ORDER BY 1;
```

```text
     table_name     |            permisos
--------------------+--------------------------------
 Determinaciones    | SELECT
 Pacientes          | SELECT
 ProtocoloPracticas | DELETE, INSERT, SELECT, UPDATE
 Protocolos         | DELETE, INSERT, SELECT, UPDATE
 ResultadoItem      | DELETE, INSERT, SELECT, UPDATE
```

**Lectura:** el corte de `07_corte.py` le quita `INSERT`, `UPDATE` y `DELETE` en las tres tablas de escritura, y le deja `SELECT`: recepción puede seguir consultando legacy mientras se decide.

### Ejercicio 7

```sql
SELECT count(*) AS antes_de_2008, min(o.ordered_on) AS primero
FROM truth.planted_case AS c
JOIN truth.patient_record AS tp ON tp.person_id = c.person_id
JOIN alameda.patient AS p ON p.legacy_patient_id = tp.legacy_patient_id
JOIN alameda.lab_order AS o ON o.patient_id = coalesce(p.merged_into_patient_id, p.patient_id)
JOIN staging.wide_result AS w ON w.lab_order_id = o.lab_order_id
WHERE c.case_code = 'boss-1-lady';
```

```text
 antes_de_2008 |  primero
---------------+------------
           152 | 1999-04-12
```

**Lectura:** la consulta llega a la señora por la verdad (sus tres fichas de la caja) y después por el paciente que sobrevivió a la fusión. Los 152 resultados son los antecedentes que Norma pedía en 2012.

---

## 🟡 Intermedio (8–14)

### Ejercicio 8

```sql
SELECT count(*) AS ver_obs,
       count(*) FILTER (WHERE NOT EXISTS (SELECT 1 FROM staging.wide_unmapped AS u
                                          WHERE u.source_table = c.source_table AND u.lab_order_id = c.lab_order_id
                                            AND u.source_column = 'Obs')) AS sin_obs
FROM staging.wide_cell AS c WHERE btrim(c.raw_value) = 'VER OBS';
```

```text
 ver_obs | sin_obs
---------+---------
    7134 |    6078
```

**Lectura:** 6.078 de los 7.134 `VER OBS` apuntan a una observación vacía. Los otros 1.056 tienen una observación, pero las de la caja son textos como `REPETIR` o `ver hoja`, no un valor. En los dos casos el dato no existe, y el rechazo lo dice con su celda.

### Ejercicio 9

```sql
SELECT (SELECT sum(replace(btrim(raw_value), ',', '.')::numeric) FROM staging.wide_cell AS c
         JOIN staging.wide_result USING (source_table, lab_order_id, source_column)
         WHERE c.source_table = 'Hemograma' AND c.source_column = 'Hemoglobina') AS origen,
       (SELECT sum(t.value_numeric) FROM staging.wide_result AS w JOIN alameda.result AS t USING (result_id)
         WHERE w.source_table = 'Hemograma' AND w.source_column = 'Hemoglobina') AS destino;
```

```text
  origen  |   destino
----------+-------------
 365047.6 | 365047.6000
```

**Lectura:** iguales. El destino tiene cuatro decimales porque `value_numeric` es `numeric(14, 4)`. Si la migración hubiera corrido una columna (la hemoglobina en el hematocrito), la suma habría saltado de 365 mil a casi un millón: la suma ve lo que el conteo no ve.

### Ejercicio 10

```sql
SELECT count(*) AS resultados, min(result_id), max(result_id)
FROM staging.wide_result WHERE source_table = 'Ferritina';
```

```text
 resultados |    min     |    max
------------+------------+------------
       6926 | 1000000000 | 1000006925
```

**Lectura:** deshacer `Ferritina` es `DELETE FROM alameda.result WHERE result_id IN (SELECT result_id FROM staging.wide_result WHERE source_table = 'Ferritina')`, y después borrar sus filas del mapa. Las claves están en el rango de mil millones: ninguna es de `ResultadoItem`.

### Ejercicio 11

```sql
BEGIN;
SELECT staging.f25_apply_result(jsonb_build_object(
    'IdItem', (SELECT min(result_id) FROM staging.wide_result), 'IdProtocolo', 11000000,
    'CodDeterminacion', 'GLU', 'Valor', '99', 'FechaCarga', '2026-10-12 09:00:00'));
SELECT rule, detail FROM staging.rejection WHERE rule = 'cdc.clave_ocupada';
SELECT t.lab_order_id = w.lab_order_id AS sigue_siendo_la_migrada
FROM staging.wide_result AS w JOIN alameda.result AS t USING (result_id)
WHERE w.result_id = (SELECT min(result_id) FROM staging.wide_result);
ROLLBACK;
```

```text
       rule        |                   detail
-------------------+---------------------------------------------
 cdc.clave_ocupada | la clave ya es de otro resultado del modelo

 sigue_siendo_la_migrada
-------------------------
 t
```

**Lectura:** la cláusula `WHERE` del `DO UPDATE` no se cumple (otro protocolo, otro analito), así que no se actualiza nada, `FOUND` queda en falso y la función deja el rechazo. El resultado migrado sigue intacto. Sin esa cláusula, esta llamada habría pisado el valor, que es lo que hizo la primera versión del aplicador 3.321 veces.

### Ejercicio 12

```sql
SELECT p.applied_lsn, s.confirmed_flush_lsn, p.applied_lsn <= s.confirmed_flush_lsn AS slot_al_dia
FROM staging.f25_cdc_position AS p JOIN pg_replication_slots AS s ON s.slot_name = p.slot_name;
```

```text
 applied_lsn | confirmed_flush_lsn | slot_al_dia
-------------+---------------------+-------------
 20/AEF7C00  | 20/AEFDE10          | t
```

**Lectura:** la posición es el `COMMIT` de la última transacción de legacy aplicada. El slot está un poco más adelante porque el aplicador también avanza sobre las transacciones que no son de legacy (las suyas propias, que el slot decodifica igual). Si el slot estuviera *detrás* de la posición, sería la ventana de una caída: lo que está entre los dos se relee y se saltea.

### Ejercicio 13

```sql
SELECT count(*) AS transacciones,
       round(percentile_cont(0.5) WITHIN GROUP (ORDER BY extract(epoch FROM applied_at - committed_at))::numeric * 1000) AS mediana_ms,
       round(percentile_cont(0.95) WITHIN GROUP (ORDER BY extract(epoch FROM applied_at - committed_at))::numeric * 1000) AS p95_ms
FROM staging.f25_cdc_log;
```

```text
 transacciones | mediana_ms | p95_ms
---------------+------------+--------
          1018 |        250 |    485
```

**Lectura:** con un sondeo cada 500 ms, una transacción espera en promedio medio intervalo antes de que el aplicador la vea. La mediana de 250 ms es eso, y el p95 es casi el intervalo entero. Para bajarla se sondea más seguido o se usa una conexión de replicación que reciba los cambios en el momento.

### Ejercicio 14

```sql
SELECT x.status, count(*) FILTER (WHERE tp.person_id = x.sih_patient_id - 5000000) AS misma,
       count(*) FILTER (WHERE tp.person_id <> x.sih_patient_id - 5000000) AS otra
FROM staging.patient_sih AS x JOIN alameda.patient AS p USING (patient_id)
JOIN truth.patient_record AS tp ON tp.legacy_patient_id = p.legacy_patient_id
GROUP BY 1 ORDER BY 1;
```

```text
   status   | misma | otra
------------+-------+------
 automatico | 62612 |    0
 revisar    |  3056 |   84
```

**Lectura:** el 97 % de los pares a revisar son la misma persona. Lo que hay que revisar a mano es sobre todo la suciedad del laboratorio (fichas sin sexo o sin fecha), y la revisión ahorra 84 errores: 47 DNI compartidos con otro sexo, y 37 más que comparten DNI con otra persona, por un dígito cambiado en el SIH o un documento ajeno en la ficha del laboratorio.

---

## 🟠 Avanzado (15–20)

### Ejercicio 15

```sql
WITH l AS (SELECT sih_patient_id % 1000 AS cubeta, md5(string_agg(sih_patient_id || '|' || patient_id || '|' || status, ','
                  ORDER BY sih_patient_id)) AS h, count(*) AS n FROM staging.patient_sih GROUP BY 1),
     s AS (SELECT sih_patient_id % 1000 AS cubeta, md5(string_agg(sih_patient_id || '|' || patient_id || '|' || status, ','
                  ORDER BY sih_patient_id)) AS h FROM sih.lab_link GROUP BY 1)
SELECT count(*) AS cubetas, count(*) FILTER (WHERE l.h <> s.h) AS distintas,
       sum(n) FILTER (WHERE l.h <> s.h) AS filas_a_bajar
FROM l JOIN s USING (cubeta);
```

```text
 cubetas | distintas | filas_a_bajar
---------+-----------+---------------
    1000 |         3 |           197
```

**Lectura:** con mil cubetas se bajan 197 filas en lugar de 1.946, a cambio de comparar mil huellas en lugar de cien. El punto justo depende de cuánto diverjan las copias: con tres filas distintas convienen muchas cubetas, y con miles, pocas, porque casi todas van a diferir igual. Una estrategia de dos niveles (cien cubetas, y mil dentro de las que difieren) se queda con lo mejor de las dos.

### Ejercicio 16

```text
  ultimo  | primer_aleatorio_por_encima | numeros_libres | por_dia
----------+-----------------------------+----------------+---------
 11233733 |                    60018570 |       48784837 |     531
```

**Lectura:** el primer número aleatorio de 2004 por encima de la identidad es 60.018.570. Quedan 48,8 millones de números libres, y a 531 protocolos por día son unos 250 años. El choque existe y es real, porque la identidad de SQL Server no salta los números ocupados y el `INSERT` va a fallar con una violación de clave primaria. Pero no le pasa a nadie que lea este curso. La pregunta útil es otra: el modelo **hereda** ese espacio de claves y no debería. Después del corte, las claves nuevas salen de una secuencia del modelo, que empieza después del último número usado y no sabe nada de la replicación de 2004.

### Ejercicio 17

*El paciente nuevo.*

**Solución de referencia:** el aplicador no inventa el paciente: un paciente nuevo exige el parser de la Fase 04 y el maestro de la Fase 05, que no son trabajo de un aplicador. El protocolo va a rechazos como `cdc.paciente_desconocido`, y sus prácticas y resultados como `cdc.protocolo_desconocido`. La bandeja de Norma (la revisión de la Fase 05) crea o vincula el paciente. Después se reaplican las filas del protocolo desde legacy con las mismas funciones, que son idempotentes por clave.

**Rúbrica (sobre 4 puntos):** 1 punto por no inventar el paciente; 1 por el destino del protocolo y sus prácticas mientras se espera; 1 por quién lo resuelve y con qué herramienta (Fase 05); 1 por cómo se reaplica después sin duplicar.

### Ejercicio 18

*La vuelta atrás después del corte.*

**Solución de referencia:** la fuente es un outbox del modelo (Fase 22), escrito en la misma transacción que cada cambio, o un slot sobre las tablas del modelo. Un traductor lo lleva al formato de legacy (el `Valor` como texto con coma, la obra social por id). Las claves nuevas del modelo tienen que caber en legacy sin chocar: si el modelo numera desde el último `IdItem`, legacy no puede estar recibiendo escrituras propias, y no las recibe porque el frontal ya no escribe. El flujo se apaga cuando termina la ventana de vuelta atrás acordada, y legacy se archiva.

**Rúbrica (sobre 4 puntos):** 1 punto por la fuente (outbox o CDC del modelo); 1 por la traducción al formato de legacy; 1 por el espacio de claves; 1 por cuándo se apaga.

### Ejercicio 19

*Los informes viejos.*

**Solución de referencia:** una vista `legacy_compat."Hemograma"` sobre el modelo, que pivotea los cinco analitos por protocolo con `max(...) FILTER (WHERE analyte_code = 'HB')` y devuelve el valor como texto con coma, como la tabla. Se reconcilia contra la tabla con un `EXCEPT` en las dos direcciones, que tiene que dar vacío para los protocolos anteriores a 2008 (los rechazados no vuelven: la vista no inventa los `-`). Primero se pasan los informes a la vista, después la tabla queda de solo lectura, y por último se borra.

**Rúbrica (sobre 3 puntos):** 1 punto por la vista de compatibilidad sobre el modelo; 1 por la reconciliación de la vista contra la tabla; 1 por el orden en que se apaga.

### Ejercicio 20

*Las prácticas sin precio.*

**Solución de referencia:** la migración no tiene que inventar un precio: las 109.496 prácticas no tienen una vigencia del precio de su obra social ese día, por los huecos y las vigencias duplicadas de la tabla de Matías (Fase 07, `precios.vigencia_duplicada`). Eso es un problema del negocio, y la migración lo hace visible con la cola de rechazos. Lo decide quien negocia los convenios. Para facturar esas prácticas hace falta un precio acordado, y la presentación de la Fase 26 las lista como `sin_precio`.

**Rúbrica (sobre 3 puntos):** 1 punto por separar lo que es de la migración y lo que es del negocio; 1 por la causa (vigencias duplicadas y huecos, Fase 07); 1 por quién decide.

---

## 🔴 Muy difícil (21–24) — rúbrica

### Ejercicio 21

*La carta a Norma.*

**Rúbrica (sobre 4 puntos):** 1 punto por los números de la señora; 1 por lo que queda como texto o sin analito, dicho sin esconderlo; 1 por las tres reconciliaciones en lenguaje de laboratorio; 1 por el tono (ni triunfal ni técnico).

### Ejercicio 22

*Las huellas en Oracle.*

**Rúbrica (sobre 4 puntos):** 1 punto por la función de huella de Oracle (`STANDARD_HASH(LISTAGG(... ) WITHIN GROUP (ORDER BY ...), 'MD5')`, con el límite de largo de `LISTAGG` resuelto por cubeta o con `ON OVERFLOW`); 1 por la misma serialización en los dos lados (formato de números, fechas y `NULL`); 1 por la comparación fuera de los motores (un script que trae las dos listas de huellas); 1 por no publicar números (D20).

### Ejercicio 23

*El día del corte.*

**Rúbrica (sobre 5 puntos):** 1 punto por el horario (no un martes); 1 por los roles; 1 por el criterio escrito antes; 1 por la ventana medida; 1 por lo que se comunica a las sedes.

### Ejercicio 24

*Lo que nadie sabe qué es.*

**Rúbrica (sobre 3 puntos):** 1 punto por separar lo que se puede tipar de lo que no; 1 por quién decide (bioquímica, no sistemas); 1 por cómo se ve en el informe mientras tanto.
