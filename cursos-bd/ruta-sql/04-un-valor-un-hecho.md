# 🧱 Fase 04 — Un valor, un hecho: de la 1FN a la BCNF, con la regla en un solo sitio

> **Curso:** Ruta SQL · Fase 04 de 27 · Bloque I — El modelo · **8 h**
> **Motores:** PostgreSQL `pgvector/pgvector@sha256:2358fcba361e…` · contraste MySQL `mysql@sha256:e2bde46db656…` · —
> **Entorno de ejecución:** SQL + Python
> **Perfil de volumen:** M para todo
> **El dolor de Alameda:** `PEREZ PEDRO DNI 23456789`, el parser de Rubén y su copia de 2016 (historia §3.1 y §3.2)
> **Depende de:** Fase 03 · **Habilita:** Fase 05
> **Apéndices de apoyo:** a03, a05, a06, a07, a08
> **Fecha de verificación ejecutada:** 12/10/2026
> **Objetivo:** encontrar en la caja las dependencias funcionales que el esquema no declara, montar el
> área de carga con su tabla de rechazos por regla, y demostrar que una regla en dos lugares diverge:
> el parser de 2016 y el de 2026 difieren en 3 documentos y en 115 fechas.

---

## 🧭 1. Dónde estamos

La [Fase 03](03-lo-que-sql-le-hace-al-modelo.md) mostró lo que SQL le hace al modelo: bolsas, `NULL` y
un orden que no existe. Esta fase va a lo que **el modelo le hace a los datos** cuando una regla no
está en el esquema: alguien la tiene que escribir en otro lado, y ese otro lado se multiplica.

En Alameda, ese otro lado tiene nombre: **el parser**. Rubén lo escribió en 1998 porque la recepción
cargaba todo en un solo campo, *"APELLIDO NOMBRE espacio DNI espacio NÚMERO"*, y alguien tenía que
separarlo. Le fue agregando casos durante veinte años, y en 2016 Matías lo copió a T-SQL para los
reportes. Desde ese día hay dos, y nadie recuerda que hay que mantenerlos iguales.

Esta fase abre además la **medición del bloque**: la tabla de rechazos. Cada regla del modelo nuevo se
corre contra `legacy`, cada fila que la viola queda registrada con su valor, y el informe compara cada
número con lo que sabe la verdad del generador. Las cuatro fases que siguen heredan el formato.

---

## 🎯 2. Objetivos de esta fase

1. Comprobar en la caja tres dependencias funcionales que el esquema no declara, y una que se cree y es
   falsa.
2. Montar `staging.rejection` y su informe, y llenarlo con seis reglas sobre `legacy`.
3. Portar a PL/pgSQL, línea a línea, el parser T-SQL de 2016, y medir cuánto acierta contra la verdad.
4. Reproducir las dos diferencias entre el parser de 2016 y el de 2026, con su número.
5. Crear una clave foránea contra los huérfanos de la caja sin fingir que no existen.

---

## 🚫 3. Qué NO entra todavía

- **Quién es cada paciente.** Separar el documento del nombre es de esta fase; decidir que dos filas son
  la misma persona es de la [Fase 05](05-una-persona-no-es-su-documento.md).
- **La cuarta y la quinta forma normal**, que necesitan dependencias multivaluadas → [Fase 06](06-cuarta-y-quinta-forma-normal.md).
- **Los precios con vigencia** → [Fase 07](07-el-tiempo-en-el-modelo.md).

---

## 🏚️ 4. El dolor, en la caja

> 🏚️ **`vba/ModParser.bas`, tal como lo trae la caja** (272 líneas, nueve `ElseIf` en `ParsearNombre`):
>
> ```text
> '  1998-03  Ruben   version original: DNI y el numero, o el primer numero
> '  2003-05  Ruben   pasaporte: P o PASAP, el pais en tres letras y el numero
> '  2005-08  Ruben   LE y LC son como el DNI (los jubilados con libreta)
> '  2016-10  Matias  OJO: hay una copia en el SQL Server, dbo.fn_ExtraerDNI,
> '                   para los reportes. Si se cambia esto hay que cambiar
> '                   aquella tambien
> '  2019-11  Matias  OTRO: la paciente con el certificado de residencia
> ```

Tres formas del mismo problema conviven en la caja.

**El documento dentro del nombre.** En M, **25.575 filas de `Pacientes`** (el 10,5 %) tienen un
documento escrito en `Nombre`, según la verdad. La [Fase 01](01-la-caja-y-el-arnes.md#46-la-prueba-de-fuego)
contó las 18.936 que dicen `DNI`; el resto dice `D.N.I.`, `LC`, `LE` o solo el número.

**El campo multivalor.** El módulo de turnos de 2008 guarda los exámenes pedidos en *un* campo, separados
por punto y coma: `GLU;HBA1C;HEMOG;HEPAT;IONOG;LIPID`. Preguntar "¿cuántos turnos pidieron PCR?" con el
texto da un número equivocado sin dar error:

```sql
-- postgres
SELECT count(*) FILTER (WHERE "ExamenesSolicitados" LIKE '%PCR%') AS like_pcr,
       count(*) FILTER (WHERE 'PCR' = ANY (string_to_array("ExamenesSolicitados", ';'))) AS exacto_pcr,
       count(*) FILTER (WHERE 'COVPCR' = ANY (string_to_array("ExamenesSolicitados", ';'))) AS exacto_covpcr
FROM turnos_raw;
```

```text
 like_pcr | exacto_pcr | exacto_covpcr
----------+------------+---------------
    38508 |      28222 |         10286
(1 row)
```

El `LIKE` cuenta los 10.286 hisopados de COVID como si fueran proteína C reactiva.

**La obra social como texto.** Antes de 2012, `Protocolos.ObraSocial` tiene **40 escrituras distintas**, contando la cadena vacía,
para once obras sociales: `PAMI`, `pami`, `Pami`, `P.A.M.I.` e `INSSJP` son la misma, y también lo son
`IPAM` y `A.P.R.O.S.S.`, o `SMG` y `SWISS MEDICAL`.

Las tres decisiones fueron razonables el día que se tomaron. Un campo grande era lo que la recepción
sabía llenar; un campo multivalor era la función nueva y cómoda de Access 2007; y el texto libre en la
obra social existía porque en 1997 no había una tabla de obras sociales a la cual apuntar.

---

## 🧩 5. Un valor, un hecho

### 5.1 Dependencias funcionales, medidas en la caja

Una **dependencia funcional** `A → B` dice que cada valor de `A` determina un único valor de `B`. Es la
herramienta con la que se decide qué va en qué tabla, y tiene una ventaja que casi nunca se usa: **se
puede comprobar en los datos** con un `GROUP BY`.

```sql
-- postgres
SELECT count(*) AS determinaciones, count(*) FILTER (WHERE unidades > 1) AS con_mas_de_una_unidad
FROM (SELECT "CodDeterminacion", count(DISTINCT "Unidad") AS unidades
      FROM legacy."ResultadoItem" GROUP BY 1) AS d;
```

```text
 determinaciones | con_mas_de_una_unidad
-----------------+-----------------------
              33 |                     0
(1 row)
```

En los 12,1 millones de resultados, `CodDeterminacion → Unidad` se cumple sin excepción, y lo mismo pasa
con el rango de referencia. Otras tres comprobaciones sobre la caja:

| Dependencia | Grupos | Que la violan | Lectura |
|---|---|---|---|
| `CodDeterminacion → Unidad, RangoReferencia` | 33 | 0 | se cumple: la unidad es de la determinación, no del resultado |
| `IdProtocolo → Nomenclador` | 1.327.622 | 0 | se cumple: el nomenclador es del protocolo, no de la práctica |
| `CodigoPractica → Nomenclador` | 38 | 17 | no se cumple: NBU y NBU 2012 usan el mismo código |
| `DNI → Nombre` | — | 10.903 DNI con más de un nombre | **no se cumple**, y es el problema de la Fase 05 |

La última es la que todo el sistema dio por cierta: que un DNI identifica a una persona y a un nombre.
En la caja, 10.903 DNI aparecen con más de un nombre.

**El patrón a memorizar.** Una dependencia funcional no se discute: se mide con un `GROUP BY … HAVING
count(DISTINCT …) > 1`. Si da cero, la tienes; si no, tienes las filas que la contradicen.

### 5.2 La 1FN de verdad: la atomicidad depende del uso

La primera forma normal pide valores **atómicos**, y es la definición más malentendida del modelo. `PEREZ
PEDRO` en un solo campo no viola la 1FN si nadie consulta nunca el apellido por separado; partirlo en dos
columnas por principio es ceremonia. Lo que la viola es **lo que se usa por separado**:

- **El DNI dentro de `Nombre`.** La presentación a la obra social, la búsqueda del paciente y el portal
  necesitan el documento solo. Cada uno lo extrae a su manera, y ese es el parser.
- **Los exámenes del turno.** "Los turnos que pidieron PCR" es una pregunta del negocio, y con el campo
  multivalor no tiene respuesta exacta con SQL de igualdad.

La salida del segundo es una tabla con una fila por examen pedido
(`src/04-un-valor-un-hecho/08_appointments.sql`):

```sql
-- postgres
CREATE TABLE staging.appointment_exam (
    appointment_id integer NOT NULL REFERENCES staging.appointment_raw ("IdTurno"),
    exam_code      varchar(10) NOT NULL,
    CONSTRAINT appointment_exam_pkey PRIMARY KEY (appointment_id, exam_code)
);
INSERT INTO staging.appointment_exam (appointment_id, exam_code)
SELECT t."IdTurno", e.exam_code
FROM staging.appointment_raw AS t
CROSS JOIN LATERAL string_to_table(t."ExamenesSolicitados", ';') AS e (exam_code);
```

```text
 turnos | examenes
--------+----------
 172986 |   837167
(1 row)

 turnos_con_pcr
----------------
          28222
(1 row)
```

La clave primaria `(appointment_id, exam_code)` dice además algo que el campo no podía decir: un turno no
pide dos veces el mismo examen. Se creó sin error, así que en la caja ese hecho ya se cumplía.

### 5.3 2FN, 3FN y BCNF, sobre tablas de la caja

Con las dependencias medidas, las formas normales dejan de ser teoría.

**2FN: nada depende de una parte de la clave.** `ProtocoloPracticas` guarda una fila por práctica de cada
protocolo, y en cada una repite el `Nomenclador`. Pero el nomenclador depende **solo del protocolo**
(`IdProtocolo → Nomenclador`, sin excepciones): lo decide la obra social y la fecha, no la práctica. Es una
dependencia parcial, y el costo es concreto: el mismo dato está **6.132.114 veces** para **1.327.622**
protocolos. Si un protocolo se refactura con otro nomenclador, hay que cambiarlo en cada una de sus
prácticas, y nada impide olvidarse de una.

**3FN: nada depende de algo que no es la clave.** En `ResultadoItem`, la unidad y el rango de referencia
dependen de la determinación (`CodDeterminacion → Unidad, RangoReferencia`), que a su vez depende del
resultado. Es una dependencia transitiva.

> 📐 **Medición: lo que cuesta la dependencia transitiva de `ResultadoItem`** · perfil M ·
> `pgvector/pgvector@sha256:2358fcba361e…` · verificado el 12/10/2026
>
> | | tamaño |
> |---|---|
> | `legacy."ResultadoItem"` completa | 1.309 MB |
> | solo `Unidad` y `RangoReferencia`, repetidas en cada fila | 230 MB |
>
> Reproducir: `SELECT pg_size_pretty(sum(pg_column_size("Unidad") + pg_column_size("RangoReferencia"))::bigint) FROM legacy."ResultadoItem";`

Son 230 MB para guardar 33 unidades y 33 rangos. El tamaño es lo de menos: cuando el laboratorio cambie
el rango de la glucemia, ¿cuál de los dos valores es el vigente?

**BCNF: todo determinante es una clave candidata.** La práctica del nomenclador se identifica por
`(nomenclador, código)`, no por el código solo, porque el NBU de 2005 y el de 2012 comparten códigos para
casi todas las prácticas. Una tabla `practice` con clave `código` estaría en 3FN y no en BCNF: el código
no determina la práctica sin su versión. La clave del modelo es la pareja.

> 🩻 **Esto sí funciona igual** en los tres motores: las dependencias funcionales y las formas normales son
> del modelo, no del producto. Lo que cambia entre motores es qué restricciones te deja declarar para
> defenderlas.

### 5.4 Las restricciones como documentación ejecutable

Una regla escrita en el esquema hace tres cosas que una regla escrita en el código no hace: **el motor la
cumple**, **el optimizador la usa** y **el siguiente desarrollador la lee**. La tabla de obras sociales del
modelo nuevo (`03_payer.sql`) lo muestra en pocas líneas:

```sql
-- postgres
CREATE TABLE alameda.payer (
    payer_id   integer PRIMARY KEY,
    payer_code varchar(20) NOT NULL,
    name       varchar(255) NOT NULL,
    tax_id     varchar(13),
    is_active  boolean NOT NULL,
    CONSTRAINT payer_payer_code_key UNIQUE (payer_code),
    CONSTRAINT payer_tax_id_check CHECK (tax_id ~ '^[0-9]{2}-[0-9]{8}-[0-9]$')
);
```

Un CUIT con un dígito de menos:

```text
ERROR:  new row for relation "payer" violates check constraint "payer_tax_id_check"
DETAIL:  Failing row contains (99, PRUEBA, Obra social de prueba, 30-1234567-8, t).
```

El mensaje nombra la regla, porque la regla tiene nombre: es la convención `<tabla>_<columna>_<sufijo>` del
curso, y por eso el `SYS_C008718` de Oracle en la [Fase 01](01-la-caja-y-el-arnes.md#45-cómo-se-mide-la-forma)
no le decía nada a nadie.

**Las 40 escrituras de la obra social** pasan a una tabla de alias, `staging.payer_alias`, con las 39 formas
reconocibles (la cuadragésima es la cadena vacía), cada una apuntando a un `payer_code` por clave foránea. Medida contra la verdad, la tabla
resuelve **99.931 protocolos anteriores a 2012 y no se equivoca en ninguno**. Lo que no resuelve son los
5.167 con la obra social `NULL` o vacía: ninguna regla sobre el texto los puede asignar.

### 5.5 El área de carga y la tabla de rechazos

El camino del bloque es siempre el mismo: `legacy` → `staging` → `alameda`. En `staging`, cada regla del
modelo nuevo se corre contra la caja, y cada fila que la viola queda en **`staging.rejection`**, con la fase,
la regla, la tabla y la clave de origen, el valor y un detalle:

```sql
-- postgres
CREATE TABLE IF NOT EXISTS staging.rejection (
    rejection_id bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    phase        text NOT NULL,
    rule         text NOT NULL,
    source_table text NOT NULL,
    source_key   text NOT NULL,
    value        text,
    detail       text,
    rejected_at  timestamptz NOT NULL DEFAULT now()
);
```

Lo que se publica es la vista **`staging.rejection_report`**, que junta cada regla con las filas de su tabla
de origen y con lo que dice la verdad. Los ocho scripts de `src/04-un-valor-un-hecho/`, en orden, la dejan
así sobre M:

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

Cada fila del informe se lee contra la verdad, y cada diferencia se explica:

- **`documento_en_nombre`, 25.574 contra 25.575.** La primera versión de la regla rechazaba **26.615**: la
  `P` de pasaporte del patrón encontraba la `P` de `P.A.M.I.` y de `A.P.R.O.S.S.`, y producía **1.041
  falsos positivos**. Exigir el país en tres letras después de la `P` los bajó a cero. Queda una sin
  detectar, `ACOSTA TOMAS DNI1544/23`, con el número pegado a la palabra.
- **`dni_con_formato_invalido`, 5.408 contra 5.137.** La verdad cuenta los pasaportes en el campo `DNI`;
  la regla encuentra además 76 certificados `OTRO` y 195 recién nacidos cargados con el pasaporte de su
  madre extranjera. Las 271 son documentos reales que no son un DNI: el problema de la Fase 05.
- **`nacimiento_posterior_al_alta` y `obra_social_sin_resolver`** coinciden exactamente con la verdad.

**El patrón a memorizar.** Una regla de limpieza también se equivoca, y la única forma de saberlo es
medirla contra algo que no sea ella misma. Por eso el informe tiene la columna de la verdad.

---

## 🔀 6. El contraste: dónde otro motor cambia la decisión

**MySQL ignoraba los `CHECK` hasta la 8.0.16.** El manual de 8.0 lo dice así: *"Prior to MySQL 8.0.16,
CREATE TABLE permits only the following limited version of table CHECK constraint syntax, which is parsed
and ignored"*. Un esquema escrito para MySQL 5.7, como el del portal de Alameda, puede tener `CHECK` que
nunca se cumplieron, y los datos que los violan ya están adentro.

MySQL 9.7 sí los hace cumplir:

```text
ERROR 3819 (HY000) at line 5: Check constraint 'patient_birth_date_check' is violated.
```

La decisión que cambia es la de la migración: **un `CHECK` heredado de un MySQL viejo no es una garantía**,
es una hipótesis. Antes de confiar en él, se corre como regla de rechazo contra los datos. En Oracle,
los `CHECK` se cumplen, y la diferencia que importa para esta fase ya la mostró la
[Fase 03](03-lo-que-sql-le-hace-al-modelo.md#-6-el-contraste-dónde-otro-motor-cambia-la-decisión): la
cadena vacía.

---

## 🪞 7. Tu instinto dice… y la apuesta

**Tu instinto dice** que una función que extrae el DNI es una solución, y que si ya existe y funciona, la
copia también funciona. Es lo que pensó Matías en 2016, con razón: copió la versión de ese momento,
línea por línea, y en ese momento las dos daban lo mismo.

> 🪞 **Apuesta antes de ejecutar** (escrita el 30/09/2026, al diseñar esta fase). *"El parser de Rubén
> acierta el DNI en el 90 % de las filas que dice la historia."*
> **Resultado:** **ganada.** Sobre las 25.575 filas con un documento en `Nombre`, el parser de 2016
> portado a PL/pgSQL acierta **23.045, el 90,1 %**; el de 2026, en su port de Python, **23.048, el
> 90,1 %**. El 10 % de la historia es el 9,9 % de la caja.

Y la parte que la apuesta no preguntaba: **las dos versiones no son la misma.** El port de 2016 sobre las
242.427 filas de `Pacientes`, comparado fila por fila con el de 2026:

```text
nombres: 242427
DNI distinto entre 2026 y 2016: 3 {'OTRO': 3}
fecha distinta entre 2026 y 2016: 115
  'CORDOBA MONICA DNI 6659374 12/03/46': VBA 12/03/1946 · T-SQL 12/03/2046
  'HUANCA FLORES LAURA DNI A8069632 18/07/47': VBA 18/07/1947 · T-SQL 18/07/2047
  'MORALES NICOLAS MIGUEL DNI 5994305 19/04/36': VBA 19/04/1936 · T-SQL 19/04/2036
```

Las dos diferencias que nadie documentó, reproducidas:

1. **El parche de 2019 solo existe en VBA.** `PEÑA LAURA CARMEN OTRO 9242/22` da `OTRO 9242/22` en el
   frontal y una cadena vacía en el reporte. Son 3 filas en M.
2. **La ventana del año de dos dígitos.** VBA sigue la de Windows (del `00` al `29` es 20xx); SQL Server
   usa su corte por defecto, 2049. Una fecha `19/04/36` es 1936 en el frontal y 2036 en el reporte: **115
   pacientes** nacen con un siglo de diferencia según quién lo calcule. El port lo reproduce en
   `staging.try_date_style3`, con el corte explícito.

El port está en `02_parser_2016.sql`. La versión de 2026 en Python es la del generador
(`src/lab/generator/rubens_parser.py`), y el `.bas` original también se puede correr en LibreOffice Basic,
que es el camino del apéndice opcional del [Access de museo](a10-el-access-de-museo.md).

---

## 💥 8. El punto de rotura

En 2011, cuando "la base" pasó a SQL Server, se agregaron cuatro claves foráneas, y las cuatro **`WITH
NOCHECK`**: el motor las crea sin mirar las filas que ya existen. La razón está en la caja. Una clave entre
los resultados y sus protocolos, sobre copias en `staging` (`05_keys.sql`):

```sql
-- postgres
ALTER TABLE staging.result_item
  ADD CONSTRAINT result_item_lab_order_id_fkey FOREIGN KEY (lab_order_id) REFERENCES staging.lab_order (lab_order_id);
```

```text
ERROR:  insert or update on table "result_item" violates foreign key constraint "result_item_lab_order_id_fkey"
DETAIL:  Key (lab_order_id)=(902271366) is not present in table "lab_order".
```

Hay **2.150 resultados de 198 protocolos que ya no existen**, todos cargados entre el 8 de abril de 2008 y el
31 de mayo de 2011. Son los protocolos que la recepción borró y volvió a cargar ("si sale repetido, bórralo
y cárgalo de nuevo"), en una base Access que no exigía integridad referencial: el protocolo se fue, y sus
resultados quedaron.

**El equivalente honesto de `WITH NOCHECK` es `NOT VALID` seguido de `VALIDATE`:**

```sql
-- postgres
ALTER TABLE staging.result_item
  ADD CONSTRAINT result_item_lab_order_id_fkey FOREIGN KEY (lab_order_id) REFERENCES staging.lab_order (lab_order_id) NOT VALID;
INSERT INTO staging.result_item VALUES (999999999, 0);
ALTER TABLE staging.result_item VALIDATE CONSTRAINT result_item_lab_order_id_fkey;
```

```text
ALTER TABLE
ERROR:  insert or update on table "result_item" violates foreign key constraint "result_item_lab_order_id_fkey"
DETAIL:  Key (lab_order_id)=(0) is not present in table "lab_order".
ERROR:  insert or update on table "result_item" violates foreign key constraint "result_item_lab_order_id_fkey"
DETAIL:  Key (lab_order_id)=(-548257407) is not present in table "lab_order".
```

`NOT VALID` crea la clave y **ya protege las filas nuevas**: el `INSERT` con un protocolo inexistente falla.
`VALIDATE` revisa las viejas, y falla mientras haya huérfanos. La diferencia con `WITH NOCHECK` es que la
clave queda marcada como no validada, y el día que se limpia, se valida. `07_orphans.sql` pasa los 2.150 a la
tabla de rechazos, los saca de la copia, y entonces `VALIDATE` termina sin error. En SQL Server, la clave de
2011 sigue sin validar quince años después.

---

## ⚰️ 9. Autopsia: el parser, de 40 a 400 líneas

**1. La decisión.** *"La recepción escribe todo junto en el nombre. Hago una función que lo separe: busca la
palabra DNI y toma lo que sigue; si no está, el primer número de siete u ocho cifras."* Rubén, 1998, cuarenta
líneas de VBA.

**2. Por qué era razonable.** Cambiar el formulario significaba cambiar la costumbre de cinco personas que
cargaban así desde 1997, y cambiar los datos significaba revisar a mano miles de fichas. Una función que
entendía el formato de la recepción no rompía nada y funcionaba el 90 % de las veces.

**3. Qué pasó después.** Cada caso que no encajaba fue un `ElseIf`: el pasaporte en 2003, las libretas en
2005, los recién nacidos en 2008, el certificado `OTRO` en 2019. En 2016, Matías copió la función a T-SQL. El
módulo que trae la caja tiene **272 líneas y nueve ramas** en `ParsearNombre`. Las dos copias difieren hoy en
**3 documentos y 115 fechas**, y el 9,9 % de las filas con un documento en el nombre sigue sin resolverse.

**4. Cuánto cuesta salir.** Separar el documento del nombre en las 25.575 filas, con un tipo de documento,
un país y un número, y cambiar el formulario para que nadie vuelva a escribirlo en el nombre. La primera
parte la hace la Fase 05 con la tabla de rechazos como cola de trabajo; la segunda es del Bloque VI.

**5. Qué lo habría cambiado.** Una columna para el documento, con un `CHECK` de formato. Cada parche del
parser es una regla que no se declaró: *"un documento tiene tipo, país y número"*, *"un recién nacido puede
no tener documento"*. Declaradas en el esquema, viven en un solo sitio, y no hay copia que se separe.

**Antes y después, con números:** dos funciones que difieren en 118 filas y aciertan el 90,1 %, contra una
regla en el esquema que no se puede violar, y una cola de 25.574 filas para limpiar una vez.

---

## 📖 10. Traducción

| Concepto | Access / T-SQL | Postgres | MySQL | Oracle |
|---|---|---|---|---|
| clave foránea sin revisar lo existente | `WITH NOCHECK` (nunca se valida) | `NOT VALID` + `VALIDATE CONSTRAINT` | `SET foreign_key_checks = 0` (sin marca) | `ENABLE NOVALIDATE` + `VALIDATE` |
| `CHECK` | se cumple | se cumple | se cumple desde 8.0.16; antes, ignorado | se cumple |
| campo multivalor | campo multivalor de Access 2007 | arreglo o tabla aparte | `SET` o tabla aparte | tabla anidada o tabla aparte |
| separar un texto en filas | `STRING_SPLIT` (SQL Server 2016) | `string_to_table` | `JSON_TABLE` | `REGEXP_SUBSTR` con `CONNECT BY` |
| corte del año de dos dígitos | 2049 (SQL Server); 2029 (Windows) | el más cercano a 2020 (`to_date` con `YY`) | 1970–2069 | 2000–2099 con `YY`; `RR` aproxima |

Hacia la NoSQL Lite: un arreglo dentro de un documento es el campo multivalor de Access con mejor
prensa, y la pregunta de la 1FN es la misma: ¿lo vas a consultar por elemento? El diccionario completo está
en [`a07`](a07-diccionario-y-glosario.md).

---

## ⚖️ 11. Veredicto honesto: cuándo NO usar esto

**Cuándo no normalizar.** El domicilio del paciente **al momento del protocolo** no es una copia
desnormalizada del domicilio del paciente: es **otro hecho**. Si el paciente se muda, el protocolo de 2019
tiene que seguir diciendo dónde vivía en 2019, porque ahí fue el domicilio de la toma de muestra. Guardarlo
en el protocolo es correcto, y "normalizarlo" lo rompería. La pregunta no es si el dato se repite, sino si
es el mismo hecho.

**Lo que pierde la normalización:** `ResultadoItem` sin la unidad repetida pide un `JOIN` con
`Determinaciones` para cada informe. Son 33 filas, que viven en memoria, y el costo es casi nulo; pero se
mide, y la [Fase 08](08-los-dos-extremos-del-mismo-error.md) lo pone frente a la tabla ancha.

**Lo que no resuelve esta fase:** las 25.574 filas con el documento en el nombre están **identificadas**, no
corregidas. La tabla de rechazos es una cola de trabajo, no una limpieza.

Las cinco preguntas, para lo que enseñó esta fase:

- **Frontera transaccional:** una regla del modelo vive con los datos; dos copias de una función no tienen
  frontera.
- **Consultas conocidas:** "los turnos que pidieron PCR" era una consulta que nadie previó, y la 1FN la
  hizo posible.
- **Unidad de lectura:** el turno con sus exámenes se lee junto, pero se consulta por examen.
- **Saltos:** uno más (`appointment_exam`), conocido.
- **Exactitud o parecido:** el parser es parecido con forma de exactitud: acierta el 90,1 % y lo hace
  pasar por el 100 %.

---

## ⚠️ 12. Errores comunes y diagnóstico

- **`violates check constraint "payer_tax_id_check"`** al cargar. 🩺 El mensaje trae la fila. Corre la
  misma condición como regla de rechazo antes de crear la restricción, y carga solo lo que pasa.
- **`violates foreign key constraint … Key (…)=(…) is not present`** al crear una clave sobre datos
  heredados. 🩺 `SELECT count(*) … WHERE NOT EXISTS (…)` da los huérfanos. Créala `NOT VALID`, rechaza los
  huérfanos y valida.
- **Una regla de limpieza con más filas que la verdad.** 🩺 Cruza los rechazados con `truth` y mira los que
  no deberían estar; casi siempre es un patrón demasiado amplio, como la `P` de `P.A.M.I.`.
- **`LIKE '%X%'` sobre un campo multivalor.** 🩺 Si algún código contiene a otro (`PCR` en `COVPCR`), el
  conteo está mal. Separa el campo.

---

## 📋 13. Checklist de validación

```text
[ ] los ocho scripts de src/04-un-valor-un-hecho/ corren en orden sin error
[ ] staging.rejection_report da las seis reglas con los números de la sección 5.5
[ ] staging.extract_dni_2016 acierta 23.045 de 25.575 contra truth.parser_case
[ ] el parser de 2016 y el de 2026 difieren en 3 DNI y 115 fechas
[ ] la clave result_item_lab_order_id_fkey queda validada después de rechazar 2.150 huérfanos
[ ] staging.appointment_exam tiene 837.167 filas y 28.222 con PCR
```

---

## 🧪 14. Ejercicios (24)

## 🟢 Fácil — medir una dependencia (1–7)

### 🟢 Ejercicio 1 — La unidad es de la determinación

Comprueba en `legacy."ResultadoItem"` que `CodDeterminacion` determina la unidad y el rango de referencia.

**Objetivo:** cero violaciones para las dos, con la consulta.

[Solución](soluciones/04-un-valor-un-hecho.md#ejercicio-1)

### 🟢 Ejercicio 2 — El DNI no determina el nombre

Cuenta los DNI de `legacy."Pacientes"` que aparecen con más de un nombre.

**Objetivo:** 10.903, y una explicación de por qué esa dependencia no se cumple.

[Solución](soluciones/04-un-valor-un-hecho.md#ejercicio-2)

### 🟢 Ejercicio 3 — El área de carga

Corre los ocho scripts de `src/04-un-valor-un-hecho/` en orden y consulta el informe.

**Objetivo:** las seis reglas con sus números.

[Solución](soluciones/04-un-valor-un-hecho.md#ejercicio-3)

### 🟢 Ejercicio 4 — El parser de 2016

Prueba `staging.extract_dni_2016` con cuatro nombres de la historia: con `DNI` y puntos, con pasaporte, con
`OTRO` y con `RN`.

**Objetivo:** los cuatro resultados, y cuál de ellos da distinto que el parser de 2026.

[Solución](soluciones/04-un-valor-un-hecho.md#ejercicio-4)

### 🟢 Ejercicio 5 — Los turnos, una fila por examen

Carga `Turnos.csv` y separa sus exámenes.

**Objetivo:** 172.986 turnos y 837.167 exámenes.

[Solución](soluciones/04-un-valor-un-hecho.md#ejercicio-5)

### 🟢 Ejercicio 6 — El `CHECK` de MySQL 9.7

Crea en MySQL una tabla con un `CHECK` que impida nacer después del alta, e inserta una fila que lo viole.

**Objetivo:** el error literal, y la versión del servidor.

[Solución](soluciones/04-un-valor-un-hecho.md#ejercicio-6)

### 🟢 Ejercicio 7 — Las escrituras de la obra social

Cuenta las formas distintas de escribir la obra social en los protocolos anteriores a 2012.

**Objetivo:** 40, y cuántas son vacías o `NULL`.

[Solución](soluciones/04-un-valor-un-hecho.md#ejercicio-7)

## 🟡 Intermedio — la regla en un solo sitio (8–14)

### 🟡 Ejercicio 8 — `LIKE` sobre un campo multivalor

Cuenta los turnos que pidieron PCR con `LIKE` y con la tabla separada.

**Pregunta:** ¿cuál es la diferencia, y qué código la provoca?

[Solución](soluciones/04-un-valor-un-hecho.md#ejercicio-8)

### 🟡 Ejercicio 9 — El 90 % de Rubén

Mide contra `truth.parser_case` cuánto acierta `staging.extract_dni_2016` en las filas con un documento en
`Nombre`.

**Objetivo:** 23.045 de 25.575, el 90,1 %.

[Solución](soluciones/04-un-valor-un-hecho.md#ejercicio-9)

### 🟡 Ejercicio 10 — Un siglo de diferencia

Encuentra los nombres cuya fecha el parser de 2016 y el de 2026 leen distinto.

**Objetivo:** 115, con tres ejemplos y la regla que explica cada uno.

[Solución](soluciones/04-un-valor-un-hecho.md#ejercicio-10)

### 🟡 Ejercicio 11 — `OTRO`

Lista los nombres con `OTRO` y lo que devuelve el parser de 2016 para cada uno.

**Pregunta:** ¿por qué en tres da vacío y en cuatro da `OTRO`?

[Solución](soluciones/04-un-valor-un-hecho.md#ejercicio-11)

### 🟡 Ejercicio 12 — La regla que encontraba la P de PAMI

Corre la primera versión de `pacientes.documento_en_nombre`, con `\m(DNI|LC|LE|P|PASAP|OTRO)\M`, y mídela
contra la verdad.

**Objetivo:** 26.615 rechazos, 1.041 falsos positivos, y la corrección.

[Solución](soluciones/04-un-valor-un-hecho.md#ejercicio-12)

### 🟡 Ejercicio 13 — La dependencia parcial

Demuestra que `IdProtocolo → Nomenclador` se cumple, y cuenta cuántas veces se guarda el dato.

**Objetivo:** cero violaciones, 6.132.114 copias para 1.327.622 protocolos.

[Solución](soluciones/04-un-valor-un-hecho.md#ejercicio-13)

### 🟡 Ejercicio 14 — Lo que pesa la transitiva

Mide cuánto ocupan la unidad y el rango repetidos en `ResultadoItem`.

**Objetivo:** 230 MB de 1.309 MB, y qué tabla del modelo los guardaría una vez.

[Solución](soluciones/04-un-valor-un-hecho.md#ejercicio-14)

## 🟠 Difícil — claves y rechazos (15–20)

### 🟠 Ejercicio 15 — La clave contra los huérfanos

Reproduce la sección 8 completa: el error, `NOT VALID`, el `INSERT` que falla y el `VALIDATE` que falla.

**Objetivo:** los cuatro mensajes, y la clave validada al final.

[Solución](soluciones/04-un-valor-un-hecho.md#ejercicio-15)

### 🟠 Ejercicio 16 — De dónde salen los huérfanos

Cuenta los resultados sin protocolo, de cuántos protocolos son y entre qué fechas se cargaron.

**Pregunta:** ¿qué pasó en esas fechas, según la historia, y por qué no hay huérfanos después?

[Solución](soluciones/04-un-valor-un-hecho.md#ejercicio-16)

### 🟠 Ejercicio 17 — Los 271 que no son pasaportes

De los 5.408 rechazos de `dni_con_formato_invalido`, la verdad explica 5.137 como pasaportes.

**Objetivo:** clasificar los otros 271 con `truth.person` y `truth.patient_record`.

[Solución](soluciones/04-un-valor-un-hecho.md#ejercicio-17)

### 🟠 Ejercicio 18 — La tabla de alias, contra la verdad

Mide cuántos protocolos anteriores a 2012 resuelve `staging.payer_alias`, y cuántos resuelve mal.

**Objetivo:** 99.931 resueltos, 0 mal resueltos, y por qué los 5.167 restantes no tienen solución en el texto.

[Solución](soluciones/04-un-valor-un-hecho.md#ejercicio-18)

### 🟠 Ejercicio 19 — El `CHECK` del CUIT

Inserta en `alameda.payer` una obra social con un CUIT mal formado.

**Objetivo:** el mensaje literal, y por qué el `CHECK` no reemplaza a la validación del dígito verificador.

[Solución](soluciones/04-un-valor-un-hecho.md#ejercicio-19)

### 🟠 Ejercicio 20 — ¿Viola la 1FN?

Para cada uno de estos campos de la caja, decide si viola la 1FN y por qué: `Pacientes.Nombre`,
`Pacientes.Direccion`, `Turnos.ExamenesSolicitados`, `Pacientes.Telefono` (con notas como `SOLO TARDE`).

**Objetivo:** una decisión por campo, con el uso que la justifica.

[Solución](soluciones/04-un-valor-un-hecho.md#ejercicio-20)

## 🔴 Muy difícil — decidir (21–24)

### 🔴 Ejercicio 21 — Qué fecha es la verdadera

Para los 115 pacientes cuya fecha difiere entre los dos parsers, decide cuál es la correcta con lo que sabe la
caja, sin mirar `truth`. Después compara con la verdad.

**Objetivo:** un criterio, su aplicación y su resultado contra `truth.person`.

[Solución](soluciones/04-un-valor-un-hecho.md#ejercicio-21)

### 🔴 Ejercicio 22 — El último documento

La regla corregida deja sin detectar `ACOSTA TOMAS DNI1544/23`. Amplía el patrón para encontrarlo y mide si
agregaste falsos positivos.

**Objetivo:** 25.575 detectados y 0 falsos positivos, o el número de falsos positivos que cuesta.

[Solución](soluciones/04-un-valor-un-hecho.md#ejercicio-22)

### 🔴 Ejercicio 23 — Una regla nueva

Agrega a la tabla de rechazos la regla `precios.codigo_repetido_en_el_mes`, sobre las 280 tablas de precios.

**Objetivo:** la regla, su línea de base correcta y su fila en el informe.

[Solución](soluciones/04-un-valor-un-hecho.md#ejercicio-23)

### 🔴 Ejercicio 24 — El domicilio del protocolo

Diseña dónde vive el domicilio del paciente en el modelo nuevo, sabiendo que un protocolo tiene que recordar
dónde vivía el paciente ese día.

**Objetivo:** las tablas, sus claves, y una defensa de por qué no es una desnormalización.

[Solución](soluciones/04-un-valor-un-hecho.md#ejercicio-24)

---

## 📚 15. Referencias

**Documentación oficial**

- **Restricciones en Postgres 18** — https://www.postgresql.org/docs/18/ddl-constraints.html — `CHECK`,
  `UNIQUE` y claves foráneas.
- **`ALTER TABLE` en Postgres 18** — https://www.postgresql.org/docs/18/sql-altertable.html — `NOT VALID` y
  `VALIDATE CONSTRAINT`.
- **`CHECK` en MySQL** — https://dev.mysql.com/doc/refman/8.0/en/create-table-check-constraints.html — el
  manual de 8.0, que cuenta lo que pasaba antes de 8.0.16; el de 9.7 ya no lo menciona.

**Papers y libros**

- **E. F. Codd, "A Relational Model of Data for Large Shared Data Banks", 1970** — las dependencias y la
  normalización, en su origen.
- **C. J. Date, *SQL and Relational Theory*, 3.ª ed., O'Reilly, 2015** — dependencias funcionales y formas
  normales, con la atomicidad discutida en serio.
- **Bill Karwin, *SQL Antipatterns, Volume 1*, Pragmatic Bookshelf, 2022** — el capítulo de los valores
  separados por comas, que es el campo multivalor de turnos.

**Orden de lectura sugerido:** la documentación de restricciones antes de la sección 5.4; Date sobre la 1FN
después de la 5.2; Karwin cuando escribas tu primera tabla de alias.

> ⚠️ Las URL y sus contenidos cambian. Se consultaron el 12/10/2026; el enlace de MySQL es del manual de
> 8.0, a propósito.

---

## 🏁 16. Resultado de la fase

```text
LA TABLA DE RECHAZOS DEL BLOQUE I · perfil M · 6 reglas
  pacientes.documento_en_nombre          25.574   verdad 25.575
  pacientes.dni_con_formato_invalido      5.408   verdad  5.137 (+ 271 OTRO y recién nacidos)
  pacientes.nacimiento_posterior_al_alta    442   verdad    442
  protocolos.obra_social_sin_resolver     5.167   verdad  5.167
  resultados.protocolo_inexistente        2.150   (198 protocolos borrados, 2008–2011)
  obras_sociales.sin_sigla                    1
EL PARSER
  2016 (PL/pgSQL)  23.045 de 25.575 · 90,1 %
  2026 (Python)    23.048 de 25.575 · 90,1 %
  difieren en       3 DNI (OTRO) · 115 fechas (corte 2029 contra 2049)
```

> **La señal de que quedó bien:** *"Cada número de mi tabla de rechazos tiene al lado lo que dice la verdad,
> y cada diferencia tiene una explicación que no es 'el parser falló'."*

> 🏷️ **No cierres la fase sin el tag.** Con el checklist en verde y `git status` limpio:
>
> ```bash
> git tag -a fase-04-un-valor-un-hecho -m "F04 cerrada: dependencias medidas, tabla de rechazos con seis reglas, el parser de 2016 portado y sus dos diferencias"
> ```
>
> Commits de la fase con prefijo `f04:`, los de ejercicio `f04 ej17: …`.
