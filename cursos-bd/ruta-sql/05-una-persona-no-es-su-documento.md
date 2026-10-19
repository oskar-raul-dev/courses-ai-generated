# 🪪 Fase 05 — Una persona no es su documento: identidad, documentos y el maestro de pacientes

> **Curso:** Ruta SQL · Fase 05 de 27 · Bloque I — El modelo · **8 h**
> **Motores:** PostgreSQL `pgvector/pgvector@sha256:2358fcba361e…` · contraste MySQL `mysql@sha256:e2bde46db656…` · Oracle (apuesta sin resolver)
> **Entorno de ejecución:** SQL
> **Perfil de volumen:** M para todo; la rotura, sobre muestras de 1.000 a 8.000 pacientes
> **El dolor de Alameda:** los pacientes duplicados, el `RN` con el DNI de la madre y el LIS de 2012 (historia §3.2 y §4)
> **Depende de:** Fase 04 · **Habilita:** Fase 06
> **Apéndices de apoyo:** a03, a05, a07, a08
> **Fecha de verificación ejecutada:** 13/10/2026
> **Objetivo:** separar al paciente de sus documentos, medir contra la verdad del generador cuánto encuentra
> un *matcher* de trigramas y cuánto se equivoca, y fusionar sin borrar: 18.538 fusiones automáticas sin
> un solo error, y 26.187 pares para una persona.

---

## 🧭 1. Dónde estamos

La [Fase 04](04-un-valor-un-hecho.md) separó el documento del nombre y dejó una cola de 25.574 filas
identificadas. También dejó una dependencia que no se cumple: **10.903 DNI aparecen con más de un nombre**.
Esta fase responde la pregunta que esa cifra abre: si el DNI no identifica a una persona, ¿qué la identifica?

La respuesta tiene dos mitades. Una es de modelo: la persona tiene clave propia, y sus documentos son hechos
sobre ella, con tipo, país y número. La otra es de datos: decidir qué filas de `legacy` son la misma persona,
que es **parecido, no exactitud**, la quinta pregunta de la [Fase 02](02-las-cinco-preguntas-desde-el-otro-lado.md).

El generador sabe quién es quién, así que cada par que el *matcher* propone se compara con
`truth.patient_record`: la fase publica su **precisión** (cuántos de los que acepta son la misma persona) y su
**exhaustividad** (cuántos de los pares verdaderos encuentra).

---

## 🎯 2. Objetivos de esta fase

1. Demostrar con la caja por qué el DNI no puede ser la clave del paciente: a cuántas personas mezclaría y a
   cuántas partiría.
2. Modelar `alameda.patient` con clave sustituta, `alameda.identity_document` con un `CHECK` de formato por
   tipo, y "sin documento" como estado válido.
3. Enlazar al recién nacido con su madre a partir del número que la recepción le prestó.
4. Construir un *matcher* con bloqueo y trigramas, y medir su precisión y su exhaustividad contra la verdad.
5. Fusionar en tres niveles (automático, revisión humana y descarte) con una fusión que nunca borra.

---

## 🚫 3. Qué NO entra todavía

- **La historia de los documentos en el tiempo** (desde cuándo vale un pasaporte, cuándo se canjeó la
  libreta) y deshacer una fusión con su registro → [Fase 07](07-el-tiempo-en-el-modelo.md). Aquí la fusión ya guarda quién y cuándo.
- **Los teléfonos y los médicos de cada paciente, y los convenios**, que son dependencias multivaluadas y de
  join → [Fase 06](06-cuarta-y-quinta-forma-normal.md).
- **Unificar el maestro con el del SIH**, que tiene sus propios duplicados → Bloque VI.

---

## 🏚️ 4. El dolor, en la caja

> 🏚️ **La recepción de Alameda, como la cuenta la historia (§3.1):**
>
> ```text
> GONZALEZ MARIA ESTHER DNI 11222333 OSDE 210
> RN GONZALEZ MARIA DNI 11222333
> ```

Dos filas, dos personas, un DNI: la recién nacida, cargada con el documento de su madre. Matías estima que
**entre el 15 % y el 20 %** de los pacientes están duplicados, y la caja lo puede contar:

```sql
-- postgres
SELECT count(*) AS filas, count(DISTINCT person_id) AS personas,
       count(*) - count(DISTINCT person_id) AS sobrantes,
       round(100.0 * (count(*) - count(DISTINCT person_id)) / count(*), 1) AS pct
FROM truth.patient_record;
```

```text
 filas  | personas | sobrantes | pct
--------+----------+-----------+------
 242427 |   200002 |     42425 | 17.5
(1 row)
```

**42.425 filas de `Pacientes` sobran**, el 17,5 %: 47.533 pares de filas que son la misma persona. Las causas
se acumulan: una variante del nombre, el DNI vacío, la otra sede, el pasaporte que después fue DNI, la libreta
canjeada. Esta última es la más limpia: al canjear la libreta por el DNI, el documento nuevo **conservó el mismo
número** (lo dice el trámite oficial; ver las referencias), y la caja tiene a esas personas dos veces, con un
número y dos tipos.

Y está la herencia del LIS de 2012, la tabla `MIG_LIS_PACIENTES` que nadie borró:

```sql
-- postgres
SELECT count(*) AS filas_lis, count(DISTINCT "ORIGEN_ID") AS filas_de_origen, count(DISTINCT r.person_id) AS personas
FROM legacy."MIG_LIS_PACIENTES" AS m
JOIN truth.patient_record AS r ON r.legacy_patient_id = m."ORIGEN_ID";
```

```text
 filas_lis | filas_de_origen | personas
-----------+-----------------+----------
      4737 |            4737 |     4720
(1 row)
```

Una fila del LIS por cada fila de origen: **ninguna fusión**. El importador no creó duplicados; los copió
todos, y con ellos la pregunta que Alameda nunca había contestado.

---

## 🧩 5. Una persona, sus documentos y sus copias

### 5.1 La clave natural que no era clave

La tentación es obvia: el DNI es único en la Argentina, así que sirve como clave primaria. Sobre la fila
limpia de la caja (`01_clean.sql` deja en `staging.patient_clean` el nombre normalizado, la fecha de
nacimiento y los dígitos del documento):

```sql
-- postgres
ALTER TABLE staging.patient_clean ADD CONSTRAINT patient_clean_document_digits_key UNIQUE (document_digits);
```

```text
ERROR:  could not create unique index "patient_clean_document_digits_key"
DETAIL:  Key (document_digits)=(9496697) is duplicated.
```

Lo que importa es medir qué haría la clave si se forzara. Contra la verdad:

| Lo que haría el DNI como clave | Filas o personas | Por qué |
|---|---|---|
| no dejaría entrar a nadie sin documento | 9.871 filas | no hay un número que leer |
| **mezclaría** personas distintas en una | 4.608 números, 9.462 personas | 4.558 números involucran a un recién nacido; 118, a un pasaporte que nuestra propia limpieza dejó sin su letra |
| **partiría** a una persona en varias | 5.347 personas con más de un documento | el pasaporte que después fue DNI, el recién nacido que después tuvo el suyo |

La clave natural falla en las dos direcciones a la vez: une a la madre con su hijo y separa al extranjero de su
DNI nuevo. Y los 118 son una advertencia aparte: `01_clean.sql` se queda con los dígitos, y el pasaporte
`X1987735` pasa a ser `1987735`, que puede ser el DNI de otra persona. **Limpiar también inventa datos.**

**El patrón a memorizar.** Una clave natural es una afirmación sobre el mundo: "este dato identifica a esta
cosa, para siempre". Antes de usarla como clave, se mide en las dos direcciones: cuántas cosas distintas lo
comparten, y cuántas veces una misma cosa lo cambia.

### 5.2 El documento como tipo, país y número

La persona recibe una clave sustituta, y sus documentos pasan a otra tabla (`04_identity.sql`):

```sql
-- postgres
CREATE TABLE alameda.identity_document (
    identity_document_id integer GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    patient_id           integer NOT NULL REFERENCES alameda.patient (patient_id),
    document_type        varchar(4) NOT NULL,
    country              char(3) NOT NULL,         -- ISO 3166-1 alfa-3 del emisor
    number               varchar(20) NOT NULL,
    valid_to             date,                     -- NULL: vigente
    CONSTRAINT identity_document_type_check CHECK (document_type IN ('DNI', 'LE', 'LC', 'PAS', 'OTRO')),
    CONSTRAINT identity_document_number_check CHECK (
        CASE document_type
            WHEN 'DNI' THEN country = 'ARG' AND number ~ '^[0-9]{7,8}$'
            WHEN 'LE'  THEN country = 'ARG' AND number ~ '^[0-9]{6,8}$'
            WHEN 'LC'  THEN country = 'ARG' AND number ~ '^[0-9]{6,8}$'
            WHEN 'PAS' THEN country <> 'ARG' AND number ~ '^[A-Z0-9]{6,12}$'
            ELSE number <> ''
        END),
    CONSTRAINT identity_document_type_country_number_key UNIQUE (document_type, country, number)
);
CREATE UNIQUE INDEX identity_document_current_key ON alameda.identity_document (patient_id, document_type)
    WHERE valid_to IS NULL;
```

Cada línea es un parche del parser, declarado: el `CHECK` dice lo que el `ElseIf` de 2003 intentaba decir, y
la clave única, que un documento es de una sola persona. El **índice único parcial** permite a lo sumo un
documento *vigente* de cada tipo por paciente. Y la libreta canjeada cabe sin trucos: `LE 10083258` y
`DNI 10083258` son dos filas del mismo paciente, uno de los 226 que la carga deja así.

El `CHECK`, contra un DNI de seis cifras y un pasaporte argentino:

```text
ERROR:  new row for relation "identity_document" violates check constraint "identity_document_number_check"
DETAIL:  Failing row contains (195682, 1, DNI, ARG, 123456, null).
ERROR:  new row for relation "identity_document" violates check constraint "identity_document_number_check"
DETAIL:  Failing row contains (195683, 1, PAS, ARG, A1234567, null).
```

**"Sin documento" es no tener filas en esta tabla.** No hay un DNI vacío, ni un `0`, ni el número de la madre.
Después de cargar la caja, **28.434 pacientes no tienen documento**, y el modelo lo dice sin mentir.

`06_documents.sql` carga lo que el modelo acepta y manda el resto a la tabla de rechazos de la Fase 04, con
cuatro reglas nuevas:

```text
                    Regla                    | Filas rechazadas | % de legacy | Contra la verdad
---------------------------------------------+------------------+-------------+------------------
 pacientes.documento_de_otro_paciente        |             9049 |        3.73 |
 pacientes.numero_fuera_de_formato           |                9 |        0.00 |
 pacientes.pasaporte_sin_pais                |             5137 |        2.12 |             5137
 pacientes.recien_nacido_con_documento_ajeno |             5397 |        2.23 |             5408
```

- **`pasaporte_sin_pais`, 5.137 contra 5.137.** La caja no guardó el país en ninguna fila. La primera versión
  rechazaba 5.202: se llevaba **65 certificados `OTRO`** escritos en el campo `DNI`, que empiezan con letra.
- **`numero_fuera_de_formato`, 9.** Libretas escritas con espacios, `LC 12 482 807`, que el parser de 2016
  leyó como `12`. **Las encontró el `CHECK`**, al fallar la carga; la regla se escribió después.
- **`recien_nacido_con_documento_ajeno`, 5.397 de 5.408.** Los once que faltan son `RN` sin número.
- **`documento_de_otro_paciente`, 9.049.** Según la verdad, **los 9.049 son la misma persona** que el dueño
  del documento: duplicados que la fusión automática no tomó (sección 5.5).

### 5.3 El recién nacido y su madre

El `RN` no tiene documento propio, pero tiene algo mejor: el número de su madre. `07_newborns.sql` lo usa para
lo que siempre fue, una relación, y no un documento:

```sql
-- postgres
WITH candidate AS (
    SELECT n.patient_id AS newborn_id, d.patient_id AS mother_id
    FROM staging.document_candidate AS r
    JOIN alameda.patient AS n ON n.patient_id = r.patient_id
    JOIN alameda.identity_document AS d ON d.document_type IN ('DNI', 'LE', 'LC') AND d.number = r.number
    JOIN alameda.patient AS m ON m.patient_id = d.patient_id
    WHERE r.document_type = 'RN'
      AND m.sex = 'F'
      AND m.birth_date <= n.birth_date - interval '12 years'
),
unique_mother AS (
    SELECT newborn_id, min(mother_id) AS mother_id
    FROM candidate GROUP BY newborn_id HAVING count(DISTINCT mother_id) = 1
)
UPDATE alameda.patient AS p SET mother_patient_id = u.mother_id
FROM unique_mother AS u
WHERE p.patient_id = u.newborn_id;
```

De los 5.408 recién nacidos, **4.389 quedan enlazados con su madre, y la verdad confirma los 4.389**. Los
demás quedan sin madre conocida, que también es un estado válido: mejor ninguna que la equivocada.

### 5.4 El maestro de pacientes: limpiar, bloquear y comparar

Decidir que dos filas son la misma persona tiene tres pasos, y cada uno se mide aparte.

**Limpiar.** `staging.normalize_name` saca del nombre lo que no es nombre, con las reglas que la Fase 04 ya
había identificado:

```text
                   nombre                    |      normalizado
---------------------------------------------+-----------------------
 GONZALEZ MARIA ESTHER DNI 11222333 OSDE 210 | GONZALEZ MARIA ESTHER
 RN GONZALEZ MARIA DNI 11222333              | GONZALEZ MARIA
 LOPEZ JUAN CARLOS (EL HIJO) DNI 30111222    | LOPEZ JUAN CARLOS
 SILVA ROSA - PAMI 150123456789/00           | SILVA ROSA
 PEÑA LAURA CARMEN OTRO 9242/22              | PENA LAURA CARMEN
(5 rows)
```

**Bloquear.** Comparar a todos con todos son 29.400 millones de pares (sección 8). El **bloqueo** solo compara
filas que comparten algo indexable: `02_candidates.sql` usa la misma fecha o el mismo documento, y deja
**1.144.780 pares candidatos**. Lo que el bloque no junta no se recupera después, así que se mide primero:

| Bloque | Pares verdaderos dentro del bloque | De 47.533 |
|---|---|---|
| misma fecha de nacimiento | 46.414 | 97,6 % |
| misma fecha **o** mismo documento | 47.120 | 99,1 % |

Quedan 413 pares fuera para siempre: la misma persona con otra fecha de nacimiento y otro documento.

**Comparar.** `pg_trgm` calcula la similitud por trigramas del nombre normalizado, de 0 a 1:

```text
           a           |       b        | trigramas
-----------------------+----------------+-----------
 GONZALEZ MARIA ESTHER | GONZALEZ MARIA |      0.68
 GIMENEZ ROSA          | JIMENEZ ROSA   |      0.63
 OLMOS PAEZ            | OLMOS RAUL     |      0.38
 PEREZ PEDRO           | PERES PEDRO    |      0.67
```

El umbral decide, y se mide contra la verdad. Primero, solo con los trigramas:

> 📐 **Medición: trigramas sobre el nombre normalizado, dentro del bloque** · perfil M ·
> `pgvector/pgvector@sha256:2358fcba361e…` · verificado el 13/10/2026
>
> | Umbral | Pares aceptados | Falsos positivos | % de falsos | Exhaustividad |
> |---|---|---|---|---|
> | 0,4 | 45.787 | 4.128 | 9,02 % | 87,6 % |
> | 0,5 | 41.747 | 1.020 | 2,44 % | 85,7 % |
> | 0,6 | 39.884 | 364 | 0,91 % | 83,1 % |
> | 0,7 | 34.504 | 163 | 0,47 % | 72,2 % |
> | 0,8 | 30.850 | 89 | 0,29 % | 64,7 % |
>
> Reproducir: la consulta del ejercicio 9.

No hay un umbral donde las dos sean buenas. Lo que ayuda es una señal que los trigramas no ven: **el mismo
documento con la misma fecha**, que en 28.822 pares no tiene ni un falso positivo. La regla combinada,
`(mismo documento y misma fecha) o trigramas ≥ t`:

| Umbral | Pares aceptados | Falsos positivos | % de falsos | Exhaustividad |
|---|---|---|---|---|
| 0,5 | 41.960 | 1.020 | 2,43 % | 86,1 % |
| 0,6 | 41.112 | 364 | 0,89 % | 85,7 % |
| 0,7 | 40.469 | 163 | 0,40 % | 84,8 % |

**La fonética no decide, pero sirve para bloquear.** Con `fuzzystrmatch`, `GIMENEZ` y `JIMENEZ` dan el mismo
Double Metaphone (`JMNS`) y distinto Soundex (`G552`, `J552`). "Misma fecha y mismo Double Metaphone del primer
apellido" encuentra el 97,6 % de los pares, y el **28,94 %** de lo que acepta es falso. Es un buen bloque y una
mala sentencia.

> 🩻 **Esto sí funciona igual** en los tres motores: el bloqueo es un *join* por igualdad sobre columnas
> indexadas, y precisión y exhaustividad se miden con un `LEFT JOIN` contra lo que se sabe. Lo que cambia entre
> motores es la función de similitud que tienes a mano (sección 6).

### 5.5 Tres niveles, una cola y una fusión que nunca borra

Con las mediciones, la decisión deja de ser un umbral y pasa a ser una política, en `03_match.sql`:

| Nivel | Regla | Pares | Misma persona | Personas distintas |
|---|---|---|---|---|
| 1 · automático | mismo documento, misma fecha y trigramas ≥ 0,8 | 19.620 | 19.620 | **0** |
| 2 · revisión humana | mismo documento y misma fecha, o trigramas ≥ 0,4 | 26.187 | 22.059 | 4.128 |
| 3 · descartado | el resto del bloque | 1.098.973 | 5.441 | 1.093.532 |

Solo el primer nivel se fusiona sin una persona. El segundo va a `staging.match_review`, una cola con un
`CHECK` que impide decidir sin firmar. El tercero se descarta, y cuesta 5.441 pares verdaderos.

`05_merge.sql` agrupa los pares (si A es B y B es C, los tres son uno) y deja vivo al más antiguo de cada grupo.
**No borra a nadie:** el fusionado conserva su fila y apunta al que lo absorbió con `merged_into_patient_id`,
`merged_at` y `merged_by`, y cada fusión queda en `alameda.patient_merge`. Contra la verdad:

```text
 pacientes_vivos | personas | grupos_con_dos_personas
-----------------+----------+-------------------------
          223889 |   200002 |                       0
(1 row)
```

**18.538 pacientes fusionados, y ningún grupo mezcla dos personas.** Quedan 23.887 duplicados vivos, que son
el trabajo de la cola. Y si alguien intenta el atajo:

```text
ERROR:  a patient is never deleted: merge 1 into another patient instead
CONTEXT:  PL/pgSQL function alameda.patient_forbid_delete() line 3 at RAISE
```

Y `documento_de_otro_paciente` resulta ser una ayuda: de sus 9.049 rechazos, **9.048 ya están en la cola**, y
todos son la misma persona. No alcanza para fusionar solo, pero dice qué revisar primero.

**El patrón a memorizar.** Un *matcher* no es un umbral: es una política de tres niveles, y cada nivel tiene
su precisión medida. Lo automático es lo que nunca se equivocó contra la verdad; lo demás lo firma una persona.

---

## 🔀 6. El contraste: dónde otro motor cambia la decisión

**MySQL no tiene trigramas.** Ni `similarity` ni nada equivalente:

```text
ERROR 1305 (42000) at line 3: FUNCTION legacy.similarity does not exist
```

Tiene `SOUNDEX`, y su manual advierte dos veces: *"This function, as currently implemented, is intended to
work well with strings that are in the English language only"*, y *"This function implements the original
Soundex algorithm, not the more popular enhanced version"*. Por eso no da lo mismo que Postgres:

```text
+---------+------------+
| n       | SOUNDEX(n) |
+---------+------------+
| GIMENEZ | G520       |
| JIMENEZ | J520       |
| VAZQUEZ | V200       |
| BASQUEZ | B200       |
+---------+------------+
```

Postgres 18 da `G552` y `V220`. La decisión que cambia es dónde vive el *matcher*: en MySQL 9.7, el bloqueo
sigue en SQL, con índices, y la similitud se calcula en la aplicación sobre los pares candidatos. El esquema de
identidad es el mismo.

> 🪞🔒 **Apuesta sin resolver: Oracle.** Hipótesis: `UTL_MATCH.JARO_WINKLER_SIMILARITY('OLMOS PAEZ', 'OLMOS
> RAUL')` da 80 o más, aunque los trigramas den 0,38, porque Jaro-Winkler premia el prefijo común; y por la
> misma razón, sobre apellidos compartidos por familias enteras, aceptaría más falsos positivos que los
> trigramas al mismo nivel de exhaustividad. Condiciones: `SELECT … FROM dual` en `sqlplus`
> ([`a03`](a03-clis-de-los-motores.md#️-oracle--sqlplus)), con los cuatro pares de la sección 5.4. El
> mecanismo, en la documentación oficial: el paquete `UTL_MATCH`, con `EDIT_DISTANCE`,
> `EDIT_DISTANCE_SIMILARITY`, `JARO_WINKLER` y `JARO_WINKLER_SIMILARITY` (en las referencias). 📝 No publicamos
> números de Oracle; el porqué está en [`a09`](a09-licencias-publicacion-y-riesgo.md).

---

## 🪞 7. Tu instinto dice… y la apuesta

**Tu instinto dice** que los duplicados son nombres mal escritos, y que una buena función de similitud con un
umbral bien elegido los resuelve. Con un apellido escrito de tres formas delante, tiene razón.

> 🪞 **Apuesta antes de ejecutar** (escrita el 30/09/2026, al diseñar esta fase). *"Trigramas sobre el
> nombre normalizado más la fecha de nacimiento encuentran al menos el 90 % de los duplicados con menos del
> 1 % de falsos positivos."*
> **Resultado:** **perdida.** Con menos del 1 % de falsos positivos, lo mejor que se midió es la regla
> combinada con umbral 0,6: **85,7 % de exhaustividad y 0,89 % de falsos**. Y ninguna regla medida pasa del
> 90 %: con umbral 0,4, los trigramas llegan al 87,6 % con un 9,02 % de falsos.

La parte que la apuesta no preguntaba es **quién se pierde**. De los 6.414 pares verdaderos que la regla no
encuentra (los de fuera del bloque, más los que quedan bajo el umbral), **6.116 tienen de un lado una ficha
`RN`**:

```text
          a          |                b                | sim  | fecha | doc
---------------------+---------------------------------+------+-------+-----
 OLMOS PAEZ          | OLMOS RAUL                      | 0.38 | t     | f
 MARTINEZ VILLARREAL | MARTINEZ ALVAREZ SUSANA CLAUDIA | 0.21 | t     | f
 SOSA GUTIERREZ      | SOSA OSCAR CARLOS               | 0.19 | t     | f
```

El recién nacido entra como `RN` y los dos apellidos, sin nombre, y años después vuelve con su nombre y un solo
apellido. No es una variante del nombre: es **otro estado de la identidad**. Sin esos pares, la misma regla
encuentra el **99,0 %** de los 40.482 restantes. El instinto acertaba con los nombres mal escritos; lo que no
veía es que el 95 % de lo que falta no es un problema de escritura.

---

## 💥 8. El punto de rotura

Sin bloqueo, cada paciente se compara con todos. La consulta es honesta y el plan también:

```sql
-- postgres
EXPLAIN (ANALYZE, BUFFERS)
WITH muestra AS MATERIALIZED (SELECT legacy_patient_id, norm_name FROM staging.patient_clean
                              ORDER BY legacy_patient_id LIMIT 8000)
SELECT count(*) FROM muestra a JOIN muestra b
  ON a.legacy_patient_id < b.legacy_patient_id AND similarity(a.norm_name, b.norm_name) >= 0.6;
```

> 📐 **Medición: el autojoin sin bloqueo** · perfil M, primeros *n* pacientes ·
> `pgvector/pgvector@sha256:2358fcba361e…` · verificado el 13/10/2026
>
> | *n* | Filas descartadas por el filtro del *join* | Pares devueltos | Tiempo (contexto) |
> |---|---|---|---|
> | 1.000 | 999.839 | 161 | 1,7 s |
> | 2.000 | 3.999.381 | 619 | 7,1 s |
> | 4.000 | 15.997.597 | 2.403 | 28,4 s |
> | 8.000 | 63.990.411 | 9.589 | 111,5 s |

Las filas examinadas son exactamente *n*²: duplicar la muestra cuadruplica el trabajo, en cualquier hardware.
Con los 242.427 pacientes de M serían 58.800 millones de comparaciones; extrapolado desde la última fila, sin
medirlo, más de un día.

Con el bloqueo, la tabla entera:

```text
   ->  Nested Loop  (actual time=71.193..1425.758 rows=572390.00 loops=2)
         ->  Bitmap Heap Scan on patient_clean b  (actual time=0.009..0.011 rows=4.72 loops=242427)
               ->  BitmapOr
                     ->  Bitmap Index Scan on patient_clean_birth_date_idx  (rows=10.37 loops=242427)
                     ->  Bitmap Index Scan on patient_clean_document_digits_idx  (rows=1.26 loops=242427)
 Execution Time: 1476.901 ms
```

Unas once filas por paciente, a través de dos índices: **1,5 segundos para M**. El bloqueo no es una
optimización del *matcher*, es la condición para que exista.

---

## ⚰️ 9. Autopsia: el DNI como clave, y el LIS que creó un paciente por variante

**1. La decisión.** *"Una persona es un DNI."* Es lo único que sabía el parser de Rubén en 1998 (historia
§3.2), y existía para sacar ese número del nombre. Catorce años después, el importador del LIS hizo lo contrario.
No buscó a nadie, y cada fila de `Pacientes` fue un paciente.

**2. Por qué era razonable.** El DNI es único por ley. Y para el proveedor del LIS, fusionar era una decisión
clínica ajena: un paciente por fila no podía mezclar dos historias.

**3. Qué pasó después.** Medido en la caja, el DNI como clave mezcla a **9.462 personas en 4.608
números** y parte a **5.347 personas** en más de un documento. El LIS, con su copia fiel, heredó el 17,5 % de
duplicados: 4.737 filas en `MIG_LIS_PACIENTES`, ninguna fusionada. La historia lo cuenta como una de las tres razones
por las que el LIS se abandonó: *"los pacientes se multiplicaron"*.

**4. Cuánto cuesta salir.** Siete scripts, y las 18.538 fusiones automáticas son la parte barata. Los 26.187
pares de la cola son, a medio minuto por par, unas 218 horas de alguien que conoce a los pacientes (una cuenta,
no una medición).

**5. Qué lo habría cambiado.** Una tabla de documentos con tipo y país, una búsqueda que devuelva
**candidatos**, y un importador que trajera las fusiones como propuestas para revisar.

**Antes y después, con números:** una clave que mezcla a 9.462 personas y parte a 5.347, contra una clave
sustituta que no se equivoca con nadie, un nivel automático con 0 errores en 19.620 pares, y una cola que dice
qué revisar primero.

---

## 📖 10. Traducción

| Concepto | Access / T-SQL | Postgres | MySQL | Oracle |
|---|---|---|---|---|
| similitud por trigramas | — | `pg_trgm`: `similarity`, `%` | — | — |
| distancia de edición | `EDIT_DISTANCE` (SQL Server 2025, en *preview*) | `fuzzystrmatch`: `levenshtein` | — | `UTL_MATCH.EDIT_DISTANCE` |
| Jaro-Winkler | `JARO_WINKLER_SIMILARITY` (SQL Server 2025, en *preview*) | — | — | `UTL_MATCH.JARO_WINKLER_SIMILARITY` |
| fonética | `SOUNDEX`, `DIFFERENCE` | `soundex`, `dmetaphone`, `daitch_mokotoff` | `SOUNDEX` (el original) | `SOUNDEX` |
| índice único parcial | índice filtrado (`WHERE`) | `CREATE UNIQUE INDEX … WHERE` | no existe; columna generada que vale `NULL` fuera del caso | índice por función con `CASE` que da `NULL` |
| prohibir el `DELETE` | `INSTEAD OF DELETE` | disparador `BEFORE DELETE` | disparador con `SIGNAL` | disparador con `RAISE_APPLICATION_ERROR` |

Hacia la NoSQL Lite: un documento de paciente con un arreglo de documentos de identidad es la misma decisión
de modelo, y el problema de los duplicados es idéntico; lo que cambia es dónde vive la regla de unicidad. El
diccionario completo está en [`a07`](a07-diccionario-y-glosario.md).

---

## ⚖️ 11. Veredicto honesto: cuándo NO usar esto

**Cuándo no deduplicar automáticamente.** En salud, el error es asimétrico. Un falso negativo deja dos fichas
de la misma persona: molesta, se ve, y se arregla con una fusión. Un **falso positivo mezcla dos historias
clínicas**. Norma firma con su matrícula un informe con los antecedentes de otra persona, y nadie lo nota hasta
que un médico decide con ellos. La regla combinada con umbral 0,6, que parece excelente (0,89 % de falsos),
fusionaría **364 pares de personas distintas** en M. En la escala real de Alameda, con unos 1,9 millones de
pacientes, el número crecería en proporción. Para un laboratorio, el nivel automático es solo lo que nunca se
equivocó contra la verdad: aquí, 19.620 pares, el 41 % del total.

**Lo que esta fase no garantiza:** el 0 del nivel automático es contra la verdad **de esta caja**. Un
generador no tipea mal un DNI que coincide con el de otra persona con la misma fecha de nacimiento; la
recepción sí, una vez cada tanto. Por eso la fusión guarda quién y cuándo, y nunca borra.

**Cuándo no vale la pena el *matcher*:** si los datos se capturan bien desde el primer día, los duplicados
nuevos los resuelve la recepción. El *matcher* es para el pasado.

Las cinco preguntas, para lo que enseñó esta fase:

- **Frontera transaccional:** la fusión mueve una identidad entera, en una transacción.
- **Consultas conocidas:** "todos los protocolos de esta persona".
- **Unidad de lectura:** el paciente con sus documentos.
- **Saltos:** uno más (`identity_document`), y el de la madre.
- **Exactitud o parecido:** parecido, y por primera vez con su precisión publicada.

---

## ⚠️ 12. Errores comunes y diagnóstico

- **`could not create unique index … is duplicated`** sobre un documento. 🩺 No es un problema de datos sucios:
  es la clave natural. Mide en las dos direcciones (sección 5.1) antes de limpiar.
- **Un *matcher* sin bloqueo que nunca termina.** 🩺 `EXPLAIN` sobre una muestra: si *Rows Removed by Join
  Filter* es *n*², falta el bloque.
- **Un umbral elegido mirando ejemplos.** 🩺 Sin una verdad, el umbral es una opinión: revisa una muestra a
  mano y mide.
- **`violates check constraint "identity_document_number_check"`** al cargar. 🩺 El mensaje trae la fila;
  casi siempre es un número que el parser leyó mal, como `LC 12 482 807`. Corre la condición como regla de
  rechazo y carga el resto.
- **Un `DELETE` para "limpiar" duplicados.** 🩺 Se pierden los protocolos que apuntaban a la fila borrada, o
  falla la clave foránea. Fusiona.

---

## 📋 13. Checklist de validación

```text
[ ] los siete scripts de src/05-una-persona-no-es-su-documento/ corren en orden sin error
[ ] staging.match_candidate tiene 1.144.780 pares y staging.match_review 45.807
[ ] 18.538 pacientes fusionados y ningún grupo con dos personas según truth
[ ] el informe de rechazos da las cuatro reglas nuevas con los números de la sección 5.2
[ ] 4.389 recién nacidos enlazados con su madre, todos correctos
[ ] el DELETE de un paciente falla con el mensaje del disparador
```

---

## 🧪 14. Ejercicios (24)

## 🟢 Fácil — la identidad, a mano (1–7)

### 🟢 Ejercicio 1 — Cuántos sobran

Cuenta con `truth.patient_record` las filas de `Pacientes`, las personas y las filas que sobran.

**Objetivo:** 242.427, 200.002 y 42.425, el 17,5 %.

[Solución](soluciones/05-una-persona-no-es-su-documento.md#ejercicio-1)

### 🟢 Ejercicio 2 — El DNI como clave

Intenta crear una restricción `UNIQUE` sobre `staging.patient_clean.document_digits`.

**Objetivo:** el error literal, y cuántas filas no tienen documento.

[Solución](soluciones/05-una-persona-no-es-su-documento.md#ejercicio-2)

### 🟢 Ejercicio 3 — Los siete scripts

Corre en orden los siete scripts de `src/05-una-persona-no-es-su-documento/`.

**Objetivo:** 1.144.780 candidatos, 45.807 pares en la cola y 18.538 fusiones.

[Solución](soluciones/05-una-persona-no-es-su-documento.md#ejercicio-3)

### 🟢 Ejercicio 4 — El nombre limpio

Pasa por `staging.normalize_name` los cinco nombres de la sección 5.4.

**Objetivo:** los cinco resultados, y qué regla quitó cada parte.

[Solución](soluciones/05-una-persona-no-es-su-documento.md#ejercicio-4)

### 🟢 Ejercicio 5 — Cuatro similitudes

Calcula `similarity` para los cuatro pares de la sección 5.4.

**Pregunta:** ¿por qué `OLMOS PAEZ` y `OLMOS RAUL`, que son la misma persona, dan menos que `GIMENEZ ROSA` y
`JIMENEZ ROSA`?

[Solución](soluciones/05-una-persona-no-es-su-documento.md#ejercicio-5)

### 🟢 Ejercicio 6 — El `CHECK` por tipo

Inserta en `alameda.identity_document` un DNI de seis cifras, un pasaporte argentino y un pasaporte
boliviano, cada uno en su transacción.

**Objetivo:** dos errores y un `INSERT 0 1`.

[Solución](soluciones/05-una-persona-no-es-su-documento.md#ejercicio-6)

### 🟢 Ejercicio 7 — La fusión nunca borra

Intenta borrar el paciente 1 de `alameda.patient`.

**Objetivo:** el mensaje del disparador, y qué tendrías que hacer en su lugar.

[Solución](soluciones/05-una-persona-no-es-su-documento.md#ejercicio-7)

## 🟡 Intermedio — medir el *matcher* (8–14)

### 🟡 Ejercicio 8 — Lo que el bloque deja afuera

Mide cuántos pares verdaderos comparten la fecha de nacimiento, y cuántos la fecha o el documento.

**Objetivo:** 46.414 y 47.120 de 47.533.

[Solución](soluciones/05-una-persona-no-es-su-documento.md#ejercicio-8)

### 🟡 Ejercicio 9 — La curva del umbral

Mide precisión y exhaustividad de los trigramas solos, con umbrales de 0,4 a 0,8.

**Objetivo:** la tabla de la sección 5.4.

[Solución](soluciones/05-una-persona-no-es-su-documento.md#ejercicio-9)

### 🟡 Ejercicio 10 — La señal que los trigramas no ven

Mide la regla combinada `(mismo documento y misma fecha) o trigramas ≥ t` con 0,5, 0,6 y 0,7, y los falsos
positivos de "mismo documento y misma fecha" sola.

**Objetivo:** la segunda tabla de la sección 5.4, y 0 falsos en 28.822 pares.

[Solución](soluciones/05-una-persona-no-es-su-documento.md#ejercicio-10)

### 🟡 Ejercicio 11 — La fonética

Mide "misma fecha y mismo Double Metaphone del primer apellido" como regla de decisión, y compara el Soundex de
Postgres y el de MySQL para `GIMENEZ`, `JIMENEZ`, `VAZQUEZ` y `BASQUEZ`.

**Pregunta:** ¿para qué sirve una regla con 97,6 % de exhaustividad y 28,94 % de falsos?

[Solución](soluciones/05-una-persona-no-es-su-documento.md#ejercicio-11)

### 🟡 Ejercicio 12 — La madre

Mide contra `truth.person.mother_person_id` cuántas madres enlazó `07_newborns.sql`, y cuántas bien.

**Objetivo:** 4.389 de 5.408, todas correctas.

[Solución](soluciones/05-una-persona-no-es-su-documento.md#ejercicio-12)

### 🟡 Ejercicio 13 — Los pasaportes que no lo eran

Mide `pasaporte_sin_pais` con la primera versión de la clasificación, que buscaba `OTRO` solo en el nombre y
no en el campo `DNI`.

**Objetivo:** 5.202 rechazos, los 65 que no son pasaportes y por qué.

[Solución](soluciones/05-una-persona-no-es-su-documento.md#ejercicio-13)

### 🟡 Ejercicio 14 — Las libretas con espacios

Lista las nueve filas de `numero_fuera_de_formato` con su `Nombre` original.

**Pregunta:** ¿qué hizo el parser de 2016 con ellas, y quién lo descubrió?

[Solución](soluciones/05-una-persona-no-es-su-documento.md#ejercicio-14)

## 🟠 Difícil — la escala y la política (15–20)

### 🟠 Ejercicio 15 — El cuadrado

Reproduce la rotura de la sección 8 con 1.000 y 2.000 pacientes.

**Objetivo:** 999.839 y 3.999.381 filas descartadas, y la fórmula que las explica.

[Solución](soluciones/05-una-persona-no-es-su-documento.md#ejercicio-15)

### 🟠 Ejercicio 16 — El plan con bloqueo

Lee el plan de `02_candidates.sql` con `EXPLAIN (ANALYZE, BUFFERS)`.

**Objetivo:** cuántas filas lee por paciente cada índice, y cuántas comparaciones son en total.

[Solución](soluciones/05-una-persona-no-es-su-documento.md#ejercicio-16)

### 🟠 Ejercicio 17 — El documento como prioridad

Cruza los rechazos de `documento_de_otro_paciente` con `staging.match_review`.

**Objetivo:** 9.048 de 9.049 ya en la cola, y una propuesta de orden para revisarla.

[Solución](soluciones/05-una-persona-no-es-su-documento.md#ejercicio-17)

### 🟠 Ejercicio 18 — A quién pierde el *matcher*

Clasifica los pares verdaderos que la regla combinada con 0,6 no encuentra.

**Objetivo:** 6.414 perdidos, 6.116 con un `RN`, y la exhaustividad sin ellos.

[Solución](soluciones/05-una-persona-no-es-su-documento.md#ejercicio-18)

### 🟠 Ejercicio 19 — El LIS, otra vez

Mide qué habría hecho el nivel automático de esta fase con las filas de `MIG_LIS_PACIENTES`.

**Objetivo:** cuántas filas del LIS habrían quedado como un solo paciente, y cuántas personas distintas habría
mezclado.

[Solución](soluciones/05-una-persona-no-es-su-documento.md#ejercicio-19)

### 🟠 Ejercicio 20 — El costo de la cola

Estima cuánto trabajo humano son los 26.187 pares del nivel 2, y diseña cómo repartirlo.

**Objetivo:** una estimación con sus supuestos explícitos, y un orden de revisión defendido con números.

[Solución](soluciones/05-una-persona-no-es-su-documento.md#ejercicio-20)

## 🔴 Muy difícil — decidir (21–24)

### 🔴 Ejercicio 21 — El recién nacido, años después

Usa el enlace con la madre para proponer, para cada `RN`, su ficha posterior: misma fecha de nacimiento y el
mismo primer apellido, sin `RN`. Mide la propuesta contra la verdad.

**Objetivo:** cuántos pares propones, cuántos son correctos, y a qué nivel los mandarías.

[Solución](soluciones/05-una-persona-no-es-su-documento.md#ejercicio-21)

### 🔴 Ejercicio 22 — Deshacer una fusión

Un médico avisa que dos pacientes fusionados son personas distintas. Diseña cómo se deshace, sin perder el
registro de que estuvieron fusionados.

**Objetivo:** el cambio al esquema, la sentencia y por qué un `UPDATE … SET merged_into_patient_id = NULL` no
alcanza.

[Solución](soluciones/05-una-persona-no-es-su-documento.md#ejercicio-22)

### 🔴 Ejercicio 23 — Jaro-Winkler

Resuelve en tu máquina la apuesta 🪞🔒 de la sección 6.

**Objetivo:** explicar el resultado con la documentación de Oracle, sin publicar ningún número.

[Solución](soluciones/05-una-persona-no-es-su-documento.md#ejercicio-23)

### 🔴 Ejercicio 24 — El umbral de Norma

Propón el nivel automático para Alameda y defiéndelo ante Norma, que firma los informes.

**Objetivo:** la regla, su precisión y su exhaustividad medidas, y qué pasa con lo que no fusiona.

[Solución](soluciones/05-una-persona-no-es-su-documento.md#ejercicio-24)

---

## 📚 15. Referencias

**Documentación oficial**

- **`pg_trgm` en Postgres 18** — https://www.postgresql.org/docs/18/pgtrgm.html — `similarity`, el operador
  `%`, el umbral por defecto (0,3) y los índices GIN y GiST que lo aceleran.
- **`fuzzystrmatch` en Postgres 18** — https://www.postgresql.org/docs/18/fuzzystrmatch.html — Soundex,
  Metaphone, Double Metaphone, Daitch-Mokotoff y Levenshtein; la advertencia sobre UTF-8, que el nombre
  normalizado sin tildes esquiva.
- **Funciones de texto de MySQL 9.7** — https://dev.mysql.com/doc/refman/9.7/en/string-functions.html —
  `SOUNDEX`, con sus dos advertencias.
- **`UTL_MATCH` en Oracle Database 23** —
  https://docs.oracle.com/en/database/oracle/oracle-database/23/arpls/UTL_MATCH.html — distancia de edición y
  Jaro-Winkler.
- **Canjear LE o LC por DNI** — https://www.argentina.gob.ar/node/37308 — el trámite oficial: el DNI nuevo
  *"conservará el mismo número de sus libretas"*.

**Papers y libros**

- **I. P. Fellegi y A. B. Sunter, "A Theory for Record Linkage", *Journal of the American Statistical
  Association*, 1969** — el modelo probabilístico del que salen los niveles de esta fase.
- **Peter Christen, *Data Matching*, Springer, 2012** — bloqueo, comparación, clasificación y cómo medirlas.

**Orden de lectura sugerido:** `pg_trgm` antes de la sección 5.4; Christen sobre bloqueo después de la
sección 8; Fellegi y Sunter cuando diseñes tus propios niveles.

> ⚠️ Las URL y sus contenidos cambian. Se consultaron el 13/10/2026.

---

## 🏁 16. Resultado de la fase

```text
EL MAESTRO DE PACIENTES · perfil M · contra truth
  filas 242.427 · personas 200.002 · sobrantes 42.425 (17,5 %)
  bloque (fecha o documento)     47.120 de 47.533 pares verdaderos · 1.144.780 candidatos
  regla combinada, umbral 0,6    exhaustividad 85,7 % · falsos 0,89 % (sin los RN: 99,0 %)
  nivel 1 · automático           19.620 pares · 0 falsos · 18.538 fusiones
  nivel 2 · revisión humana      26.187 pares · 22.059 iguales · 4.128 distintos
EL MODELO
  identity_document              DNI 194.094 · LC 797 · LE 718 · OTRO 72 · sin documento 28.434
  recién nacidos con madre       4.389 de 5.408 · 0 errores
  rechazos nuevos                pasaporte_sin_pais 5.137 · recien_nacido 5.397 · otro_paciente 9.049 · formato 9
```

> **La señal de que quedó bien:** *"Puedo decir cuántos pacientes fusioné, cuántos de esos estaban mal según
> la verdad, y dónde está cada paciente fusionado: en su fila, apuntando al que lo absorbió."*

> 🏷️ **No cierres la fase sin el tag.** Con el checklist en verde y `git status` limpio:
>
> ```bash
> git tag -a fase-05-una-persona-no-es-su-documento -m "F05 cerrada: identidad separada de los documentos, matcher medido contra la verdad, fusión en tres niveles que nunca borra"
> ```
>
> Commits de la fase con prefijo `f05:`, los de ejercicio `f05 ej21: …`.
