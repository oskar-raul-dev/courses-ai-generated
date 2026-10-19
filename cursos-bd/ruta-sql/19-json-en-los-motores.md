# 🧾 Fase 19 — JSON en los motores: el antibiograma que no calza en una tabla, y lo que cuesta guardarlo como documento

> **Curso:** Ruta SQL · Fase 19 de 27 · Bloque IV — Lo NoSQL dentro del SQL · **10 h**
> **Motores:** PostgreSQL `pgvector/pgvector@sha256:2358fcba361e…` (18.6) · contraste MySQL `mysql@sha256:e2bde46db656…` (9.7) · Oracle, solo con la documentación (🪞🔒)
> **Entorno de ejecución:** SQL en `src/19-json-en-los-motores/`, con `psql` y el cliente de MySQL dentro de los contenedores del laboratorio
> **Perfil de volumen:** M, con la verdad de antibiogramas de `truth.antibiogram` (D46)
> **El dolor de Alameda:** unos 1.100 tipos de determinación, y el antibiograma de microbiología (el germen, los antibióticos y la sensibilidad a cada uno) que no calza en ninguna tabla
> **Depende de:** Fase 18 · **Habilita:** Fase 20
> **Apéndices de apoyo:** a02, a04, a07, a08
> **Fecha de verificación ejecutada:** 14/10/2026
> **Objetivo:** guardar un antibiograma como documento y como forma larga, medir cuánto cuesta buscar y corregir en cada una, y decidir cuándo `jsonb` es la respuesta honesta.

---

## 🧭 1. Dónde estamos

Hasta aquí, todo el modelo fue relacional: cada hecho en su columna, cada entidad en su tabla. La Fase 04 enseñó que un valor, un hecho; la Fase 06 que cada dependencia tiene su tabla. El Bloque IV es donde el curso concede algo: hay datos que **no tienen una forma fija**, y el JSON existe para eso.

El caso es el antibiograma. Un cultivo de orina produce un germen (*Escherichia coli*, por ejemplo) y una lista de antibióticos, cada uno con su resultado: sensible, intermedio o resistente. El panel depende del germen. Un germen tiene diez antibióticos, otro cuatro, y no hay dos cultivos que tengan el mismo conjunto. En la caja de Alameda, eso vive como texto libre en una columna `Antibiograma` de la tabla de urocultivos, y en 2011 eso bastó. Pero para buscar «los cultivos resistentes a meropenem» hay que leer texto.

Esta fase mide tres cosas: cómo guardar el antibiograma como documento en un motor relacional, cuánto cuesta buscar y corregir en cada forma, y dónde el documento deja de ser la respuesta.

---

## 🎯 2. Objetivos de esta fase

1. Distinguir `json` de `jsonb` y saber qué se guarda en cada uno.
2. Elegir entre `jsonb_ops` y `jsonb_path_ops` para un índice GIN, y medir qué se gana con cada uno.
3. Indexar una ruta del documento con una columna generada (MySQL) o con un índice de expresión (Postgres).
4. Medir la escritura: cuántos bytes de WAL o de redo cuesta corregir un solo antibiótico, según la forma.
5. Validar la forma del documento con `CHECK` y saber qué no valida.
6. Decidir, con números, cuándo `jsonb` es la respuesta y cuándo es un EAV con mejor marketing.

---

## 🚫 3. Qué NO entra todavía

- **Documentos de paciente completos y su proyección para la app.** Son la Fase 20, con la propuesta de Florencia y MongoDB.
- **Búsqueda de texto y recursión sobre jerarquías.** La Fase 21, con `tsvector`, trigramas, `WITH RECURSIVE` y `pgvector`.
- **Índices de texto para el JSON.** Solo se usan GIN y la columna generada; la búsqueda por similitud queda para la Fase 21.
- **La validación por esquema de Oracle.** Se describe en prosa (🪞🔒): ningún número de Oracle entra en el curso publicado (D20).

---

## 🏚️ 4. El dolor, en la caja

La tabla de urocultivos tiene 62 filas en el perfil M. Cada una lleva el antibiograma como texto. Para responder «cuántos urocultivos resistentes a ciprofloxacina hubo en 2019» hace falta un `LIKE` sobre texto libre, y no hay forma de saber cuántos antibióticos se probaron sin leer la columna entera.

El laboratorio de microbiología de Alameda, en cambio, no es un urocultivo: es todo el procesamiento de cultivos desde 2002. La verdad que genera el laboratorio (D46) tiene **60.001 cultivos**, cada uno con su germen y el panel de antibióticos de ese germen: **469.863 filas** en forma larga, una por germen, antibiótico y sensibilidad. Esa es la forma que el generador sabe producir bien, y la que tendría un laboratorio que modela desde cero.

```sql
SELECT germ, count(*) AS cultures
FROM staging.culture_doc
GROUP BY germ
ORDER BY cultures DESC;
```

| Germen | Cultivos | Filas de la forma larga |
|---|---:|---:|
| *Escherichia coli* | 33.597 | 302.373 |
| *Klebsiella pneumoniae* | 7.361 | 51.527 |
| *Staphylococcus aureus* | 6.098 | 42.686 |
| *Pseudomonas aeruginosa* | 4.876 | 29.256 |
| *Enterococcus faecalis* | 4.393 | 21.965 |
| *Proteus mirabilis* | 3.676 | 22.056 |
| **Total** | **60.001** | **469.863** |

> 📝 Las proporciones de resistencia son de uso común en laboratorios generales, no de ningún laboratorio real. El panel de cada germen es fijo; la sensibilidad, aleatoria con esas proporciones. Lo que la fase mide es la **forma** del dato, no la epidemiología.

---

## 🧩 5. El documento: `jsonb`, operadores y `jsonpath`

En Postgres hay dos tipos JSON. `json` guarda el texto tal cual, con sus espacios y sus claves repetidas. `jsonb` lo guarda ya parseado, en binario, sin orden de claves garantizado y sin claves repetidas. Para casi todo, `jsonb` es la respuesta; `json` solo cuando hay que conservar el texto exacto.

Un cultivo se vuelve un documento con una agregación:

```sql
SELECT culture_id, person_id, culture_date, germ,
       jsonb_object_agg(antibiotic, sensitivity ORDER BY antibiotic) AS antibiogram
FROM truth.antibiogram
GROUP BY culture_id, person_id, culture_date, germ;
```

El operador `@>` pregunta por contención: `antibiogram @> '{"MEROPENEM": "R"}'` es verdadero si el documento tiene ese par. El operador `->>` extrae un valor como texto, y `jsonpath` permite expresiones más largas: `antibiogram @@ '$.* == "R"'` pregunta si algún antibiótico es resistente.

🧠 **Mental model:** un `jsonb` es una tabla de una sola fila, con claves que se buscan por nombre. Lo que pierdes es la forma: el motor no sabe qué claves hay, ni de qué tipo son, ni que `MEROPENEM` debe ser `S`, `I` o `R`. Eso se pone en `CHECK`.

### 5.1 Índices GIN: `jsonb_ops` contra `jsonb_path_ops`

Un índice GIN sobre `jsonb` tiene dos clases. `jsonb_ops` (la de por defecto) indexa cada clave y cada valor por separado. `jsonb_path_ops` indexa cada ruta completa, clave y valor juntos: es más selectivo para `@>`, pero no sirve para preguntar solo por la existencia de una clave. En esta caja, los dos índices pesan lo mismo (808 kB y 816 kB): la ventaja de `jsonb_path_ops` es de selectividad, no de tamaño. En otras cajas, con claves más largas, la diferencia de tamaño puede ser grande; aquí no lo es.

La medida, en `staging.culture_doc` (60.001 documentos, 15 MB), con la búsqueda por meropenem resistente (600 cultivos):

| Consulta | Plan | Bloques leídos | Tiempo |
|---|---|---:|---:|
| Forma larga, con su clave primaria | *Parallel Seq Scan* sobre 36 MB | 4.686 | 15,6 ms |
| Documento, sin índice | *Seq Scan* sobre 15 MB | 1.920 | 9,2 ms |
| GIN `jsonb_ops` (808 kB) | *Bitmap Index Scan* + *Bitmap Heap Scan* | 1.632 | 2,8 ms |
| GIN `jsonb_path_ops` (816 kB) | *Bitmap Index Scan* + *Bitmap Heap Scan* | 527 | 0,7 ms |

Fuente: medida de la sesión de verificación del 14/10/2026.

🪞 **Tu instinto dice…** que un índice GIN sobre el documento convierte la búsqueda en un acceso casi directo, y para una consulta selectiva lo hace: 527 bloques contra 4.686 de la forma larga. Pero ese instinto no mide cuántos bloques toca el índice *en el heap*, que es el costo real. Para una consulta que devuelve el 1 % de los documentos, cada documento encontrado cae en una página distinta, y el motor lee casi todas.

**Apuesta antes de medir:** *"la búsqueda de antibiogramas resistentes a un antibiótico, con GIN `jsonb_path_ops`, lee menos del 1 % de los bloques del seq scan"*.
**Resultado: perdida.** Con meropenem, que es el antibiótico más raro, el índice lee 527 bloques, el **27 %** de los 1.920 del *seq scan* sobre el documento. Son 600 cultivos repartidos sobre 524 páginas: casi cada página tiene un resultado que buscar. Con ciprofloxacina, que es común, el índice no ayuda: 13.304 cultivos, 1.915 bloques, el mismo costo que leer todo.

> ⚠️ **Lo que hizo perder la apuesta:** los documentos están en orden de llegada, no agrupados por resultado. Medido en el ejercicio 11: con un índice btree sobre `->> 'MEROPENEM'` y un `CLUSTER` que reordena la tabla por esa expresión, la misma búsqueda pasa de 527 bloques a 17. Eso es un diseño físico, no un cambio de forma, y es la diferencia entre medir el documento y medir cómo se guarda. Un `CLUSTER` se paga una vez y se pierde con cada escritura nueva, así que esto sirve para datos que se leen mucho y se escriben poco.

### 5.2 La ruta indexada con una expresión

Cuando la búsqueda es por una sola clave, no hace falta GIN: un índice de expresión sobre `->>` cubre esa expresión y nada más, y así se escribe menos por cada cambio de documento. En Postgres:

```sql
CREATE INDEX culture_doc_meropenem ON staging.culture_doc ((antibiogram ->> 'MEROPENEM'));
SELECT count(*) FROM staging.culture_doc WHERE antibiogram ->> 'MEROPENEM' = 'R';
```

El índice de expresión solo responde a esa expresión exacta. Si mañana la pregunta es sobre gentamicina, no sirve, y hay que crear otro. El GIN responde a cualquier clave, a costa de ser más grande y de escribir más.

### 5.3 Validar la forma: `CHECK` y lo que no valida

El documento no tiene esquema, pero se le puede poner uno mínimo con `CHECK`. Aquí, que el antibiograma sea un objeto, y que cada sensibilidad sea `S`, `I` o `R`:

```sql
ALTER TABLE staging.culture_doc ADD CONSTRAINT antibiogram_is_object
  CHECK (jsonb_typeof(antibiogram) = 'object');
ALTER TABLE staging.culture_doc ADD CONSTRAINT antibiogram_values_valid
  CHECK (NOT (antibiogram @? '$.keyvalue() ? (@.value != "S" && @.value != "I" && @.value != "R")'));
```

La segunda restricción usa `jsonpath` porque una subconsulta no se permite en un `CHECK` de Postgres. Si la regla necesita contar, una función `IMMUTABLE` sí se permite dentro del `CHECK`: `CHECK (staging.n_antibiotics(antibiogram) >= 3)`, con `n_antibiotics` escrita en SQL sobre `jsonb_object_keys`. Probada en la caja: acepta el antibiograma válido y rechaza `{"AMPICILINA": "X"}` con `violates check constraint "antibiogram_values_valid"`.

Lo que `CHECK` no valida: que los antibióticos sean los del panel de su germen. Eso pediría consultar otra tabla o el germen mismo dentro de la restricción, y un `CHECK` solo ve la fila. Esa regla vive en la aplicación o en un trigger, y el curso la mide en la Fase 20.

### 5.4 Lo que `jsonb` guarda, y lo que tira

La diferencia entre `json` y `jsonb` no es de nombre: es qué conserva el motor del texto que le mandaste. Con un antibiograma escrito a mano, con un espacio de más y una clave repetida, como los que llegan de una planilla corregida dos veces:

```sql
SELECT '{"MEROPENEM": "S",  "AMPICILINA": "R", "MEROPENEM": "R"}'::json  AS como_json,
       '{"MEROPENEM": "S",  "AMPICILINA": "R", "MEROPENEM": "R"}'::jsonb AS como_jsonb;
```

```text
                        como_json                         |              como_jsonb
----------------------------------------------------------+---------------------------------------
 {"MEROPENEM": "S",  "AMPICILINA": "R", "MEROPENEM": "R"} | {"MEROPENEM": "R", "AMPICILINA": "R"}
```

`json` devuelve el texto tal cual, con el doble espacio y las dos claves. `jsonb` se queda con **la última** `MEROPENEM`, tira los espacios y reordena las claves: las guarda ordenadas por largo y después por contenido, para buscarlas rápido, así que `MEROPENEM` (nueve letras) sale antes que `AMPICILINA` (diez). No es un error, es el contrato: un documento `jsonb` es un conjunto de pares, no un texto. Si el orden o la clave repetida significan algo para el negocio, `jsonb` lo pierde sin avisar, y lo que se vuelve a leer no es lo que se escribió. La Fase 03 encontró el mismo tipo de pérdida silenciosa con `NULL`; aquí es con la forma.

Dos detalles más que importan al diseñar. El primero: **`jsonb` no siempre es más chico.** Ese mismo par de antibióticos ocupa 41 bytes como `json` y 45 como `jsonb`, porque el binario lleva una cabecera con la posición de cada clave. Lo que `jsonb` compra no es espacio: es no volver a parsear el texto en cada `->>`, y poder indexar. El segundo: **los números se guardan como `numeric`**, con su escala. `{"x": 1.50}` vuelve como `1.50`, y aun así es igual a `1.5` cuando se compara como `jsonb`. Una concentración informada como `1.50` no pierde el cero, pero tampoco lo usa para distinguir.

> 🩻 **Esto sí funciona igual.** Un `jsonb` es una columna más de una fila más. La transacción, el `ROLLBACK`, el MVCC de la Fase 17, los bloqueos de la Fase 18 y el `EXPLAIN` de [`a04`](a04-el-arnes-de-forma.md) no cambian en nada: el documento se bloquea, se versiona y se lee como cualquier otra tupla. Por eso el costo de corregirlo, en la sección 7, es el de reescribir la tupla entera.

---

## 🔀 6. El contraste: MySQL, el JSON binario y la columna generada

MySQL 9.7 guarda `JSON` como binario, como Postgres `jsonb`, pero con diferencias que cambian lo que se puede hacer. No hay GIN: el índice se hace sobre una **columna generada** que extrae una ruta, o con un índice multivalor sobre un arreglo dentro del documento. Un antibiograma es un objeto, así que el índice multivalor no aplica; la respuesta de MySQL es la columna generada.

```sql
ALTER TABLE staging.culture_doc
  ADD COLUMN meropenem CHAR(1) GENERATED ALWAYS AS (JSON_UNQUOTE(JSON_EXTRACT(antibiogram, '$.MEROPENEM'))) VIRTUAL,
  ADD INDEX culture_doc_meropenem (meropenem);
```

Con `EXPLAIN ANALYZE` (MySQL 8.0.18 y posteriores), la misma búsqueda por meropenem:

| Plan | Filas examinadas | Tiempo |
|---|---:|---:|
| Tabla completa, con el índice ignorado (`IGNORE INDEX`) | 60.001 | 40,7 ms |
| *Covering index lookup* sobre la columna generada | 600 | 0,2 ms |

Fuente: medida de la sesión de verificación del 14/10/2026.

📝 MySQL guarda el documento completo en la fila, así que el índice de la columna generada lleva solo la clave y la clave primaria; la búsqueda sobre el documento sin índice recorre todo.

⚠️ **La columna generada es una decisión de diseño que hay que pagar.** Cada ruta que quieras indexar es una columna nueva, y cada una cuesta espacio y tiempo de escritura. Un GIN de Postgres cubre cualquier clave con un solo índice; en MySQL hay que anticipar las preguntas.

### 6.1 El redo de una corrección

La escritura es lo que MySQL mide de forma distinta. El contador `Innodb_os_log_written` cuenta el redo que InnoDB produce. Corregir un antibiótico, en cuatro corridas alternadas:

| Forma | Redo por corrección |
|---|---:|
| Fila larga, `UPDATE` de una fila | 1.024 bytes |
| Documento, `JSON_SET` sobre la ruta | 1.024 a 1.536 bytes |

🪞 **Tu instinto dice…** que un `JSON_SET` que cambia 1 de 9 claves escribe mucho menos que una fila entera. Aquí no se ve. InnoDB registra el redo en bloques de 512 bytes, y con filas de unos 100 o 250 bytes el bloque de registro tapa la diferencia. El ahorro existe, pero es menor que la granularidad de la medida.

> 🧭 Lo que se mide, y no se adivina: en MySQL, el JSON no empeora la escritura frente a la fila larga para este tamaño. En Postgres, sí (ver §7). Son dos motores con dos formas de contar.

La razón de fondo está en cómo actualiza cada motor. MySQL puede hacer una **actualización parcial** del documento: cuando un `JSON_SET`, `JSON_REPLACE` o `JSON_REMOVE` cambia un valor por otro que no es más largo, InnoDB lo escribe en su lugar dentro del binario y registra solo el cambio. Cambiar una `S` por una `R` es exactamente ese caso. Postgres no tiene ese camino: su MVCC escribe una versión nueva de la fila completa en cada `UPDATE`, sea de una columna entera o de un byte dentro del documento. La diferencia no se nota con un antibiograma de 221 bytes, y se nota mucho con un documento de decenas de kilobytes, que es el caso de la Fase 20.

### 6.2 Oracle: el tipo `JSON` y su índice de búsqueda

Oracle tiene un tipo `JSON` propio desde la versión 21c, guardado en un formato binario que llama OSON, con la misma idea que `jsonb`: el documento se parsea una vez y se lee por ruta sin volver al texto. Para indexar ofrece dos caminos, que son los mismos dos de Postgres con otros nombres: un índice de función sobre `JSON_VALUE(antibiogram, '$.MEROPENEM')`, que cubre una ruta como el índice de expresión de la sección 5.2, y un **índice de búsqueda JSON** (`CREATE SEARCH INDEX … FOR JSON`), que cubre cualquier clave del documento como el GIN. La validación mínima es `IS JSON` en un `CHECK`, y desde 23ai se le puede pedir que cumpla un esquema JSON.

> 🪞🔒 **Apuesta sin resolver: Oracle.** Hipótesis: en el antibiograma, el índice de función sobre `JSON_VALUE` lee del orden de lo que lee el índice de expresión de Postgres para meropenem, y el índice de búsqueda JSON, del orden del GIN, con el mismo límite: los 600 cultivos resistentes están repartidos por toda la tabla. Resuélvela con `uv run lab measure --engine oracle --private` sobre `staging.culture_doc` cargada en Oracle con `JSON_OBJECTAGG`, con cada índice por separado. El resultado queda en tu terminal ([`a09`](a09-licencias-publicacion-y-riesgo.md)).

---

## ✍️ 7. La escritura en Postgres: el WAL de una corrección

Postgres registra cada cambio de fila en WAL. Un `UPDATE` escribe la tupla nueva completa, no solo el cambio, así que el tamaño de la tupla es el costo. Medida en estado estable (cuatro corridas por forma tras un `CHECKPOINT`, con la última reportada), corrigiendo ciprofloxacina de un cultivo del paciente 4977:

| Forma | Tamaño de lo que cambia | WAL por corrección |
|---|---:|---:|
| Fila larga (`antibiogram_long`) | una fila del cultivo, 112 bytes | 112 bytes |
| Documento del cultivo (`culture_doc`) | 221 bytes | 672 bytes |
| Historia del paciente (`patient_doc`) | 1.453 bytes, con cinco cultivos | 1.528 bytes |

Fuente: medida de la sesión de verificación del 14/10/2026. La historia del paciente tiene picos de 9.928 y 31.936 bytes en las corridas que siguen a un punto de control: son imágenes completas de página, y por eso se reporta la corrida estable.

**Apuesta antes de medir:** *"cada corrección de un antibiótico reescribe el documento entero en WAL"*.
**Resultado: ganada, con matiz.** La historia del paciente escribe 1.528 bytes para cambiar 4 bytes de valor; la fila larga, 112. El documento reescribe la tupla completa, como dice la apuesta, y el costo crece con su tamaño. El matiz: el documento más grande que produce esta caja pesa 1,5 KB, por debajo del umbral en que Postgres lo lleva a TOAST (unos 2 KB). Con un documento de 20 KB, la corrección reescribiría más, y el TOAST cambiaría la cuenta.

> ⚠️ **La rotura de la ficha pedía un documento grande.** Un antibiograma es corto por naturaleza: nadie tiene cinco cultivos de meropenem por año. La medida es honesta con eso: el costo es proporcional a la tupla, y con antibiogramas cortos la diferencia es un orden de magnitud, no un abismo.

---

## 🪞 8. Tu instinto dice… y la apuesta

Ya están los dos números. El instinto de quien viene de relacional es que el documento es un mal modelo para datos que cambian: un `UPDATE` que reescribe todo parece un error de diseño. La medida dice algo más preciso: **reescribe lo que contiene**. Para documentos chicos, eso es barato; para documentos que crecen sin límite, es el problema de la Fase 20, cuando la historia del paciente se vuelve el documento de la app.

---

## 💥 9. El punto de rotura

La rotura de esta fase es la **corrección de un antibiótico en un documento que crece**. Se midió en el orden de 1.500 bytes de WAL, con cinco cultivos. Con cincuenta cultivos, un documento de unos 15 KB, la reescritura supera el umbral de TOAST, y cada corrección deja de ser una escritura de página chica: el documento se parte en bloques fuera de la fila, y la lectura del documento entero se vuelve más cara. Eso no se midió en esta caja porque no existe un paciente con cincuenta cultivos; la fase lo deja como ejercicio con el generador.

---

## ⚰️ 10. Autopsia: la columna `extra jsonb` que terminó siendo el esquema

El caso que casi todos los equipos conocen: una tabla con sus columnas bien definidas y una columna `extra jsonb` para lo que aparezca. En el primer trimestre es práctica. A los dos años, la columna tiene 40 claves distintas, cada consulta de reporte la lee con `->>` y un cast, nadie sabe qué claves son obligatorias, y el `CHECK` que se agregó tarde falla para la mitad de las filas.

El costo no se ve en un día. Se ve cuando el reporte tarda seis segundos porque cada fila se parsea otra vez, o cuando un cambio de nombre de clave deja medio año de datos sin leer. La lección no es «no uses `jsonb`»: es que una columna `jsonb` que se consulta con frecuencia es un esquema, y merece su `CHECK` y su índice desde el día uno.

---

## 📖 11. Traducción

| Lo que sabes (relacional) | En `jsonb` / JSON | Lo que cambia |
|---|---|---|
| Una columna por atributo | Una clave por atributo, sin tipo fijo | El motor no valida el tipo ni la presencia sin `CHECK` |
| `WHERE col = 'R'` | `WHERE doc @> '{"col": "R"}'` o `doc ->> 'col' = 'R'` | Un índice por expresión no sirve para otra clave |
| Índice sobre la columna | GIN sobre el documento, o índice de expresión | GIN cubre todas las claves; el de expresión, una |
| Tabla de hijos (un antibiótico por fila) | Un objeto con los antibióticos dentro | La forma larga es más fácil de agregar; el documento, de leer por cultivo |
| `UPDATE` de una columna | `jsonb_set` o `JSON_SET` | El motor reescribe el documento completo (Postgres) o escribe un diff (MySQL) |

📖 **De `jsonb` a relacional:** cuando una clave aparece en casi todos los documentos y se consulta con frecuencia, sácala a columna. El documento queda para lo que varía.

---

## ⚖️ 12. Veredicto honesto: cuándo `jsonb` es la respuesta, y cuándo es un EAV con mejor marketing

`jsonb` es la respuesta cuando la forma varía **de verdad** entre registros y la consulta por una clave concreta es rara o se puede indexar. El antibiograma cumple: el panel depende del germen, y casi nadie pregunta por un antibiótico concreto sin un filtro por germen.

No es la respuesta cuando los datos son una tabla disfrazada. Si cada documento tiene las mismas claves, si las claves se consultan todo el tiempo, si necesitas integridad referencial o si la forma cambia con cada release, es un esquema. Un EAV (tabla de pares clave-valor) dentro de `jsonb` es lo peor de los dos mundos: pierde la forma y la integridad, y no gana la flexibilidad que prometía.

La forma larga, que es lo que el generador produce, también es válida: 469.863 filas, agregable con `GROUP BY`, con integridad por clave primaria. Su costo es el `JOIN` o la agregación para reconstruir el cultivo. Elegir entre las dos no es una cuestión de moda: es qué consulta se hace más seguido.

---

## ⚠️ 13. Errores comunes y diagnóstico

- **Usar `json` en lugar de `jsonb`** y después extrañar que `@>` no funciona: `json` no tiene índices GIN ni operadores de contención.
- **Crear un GIN `jsonb_ops` por defecto** cuando la consulta es siempre `@>`: `jsonb_path_ops` es más selectivo aquí, aunque pese casi lo mismo.
- **Confundir `->` con `->>`:** `->` devuelve `jsonb`, y comparar con `'R'` falla en silencio sin cast.
- **Un `CHECK` que pregunta por otra tabla:** no se permite, y las reglas cruzadas viven en la aplicación.
- **Creer que el documento ahorra escritura** porque es una fila: la tupla completa se reescribe, y el costo es proporcional a su tamaño.

---

## 📋 14. Checklist de validación

- [ ] `staging.antibiogram_long` tiene 469.863 filas y clave primaria `(culture_id, antibiotic)`.
- [ ] `staging.culture_doc` tiene 60.001 documentos, uno por cultivo, con `jsonb_typeof = 'object'`.
- [ ] Los dos `CHECK` del §5.3 se aceptan sin error y rechazan un valor `X` si se inserta a propósito.
- [ ] Los GIN pesan lo que dice el §5.1: `jsonb_ops` 808 kB y `jsonb_path_ops` 816 kB en esta caja.
- [ ] La medida de WAL se hizo tras un `CHECKPOINT`, con las corridas de estabilización descartadas.
- [ ] La columna generada de MySQL se crea con `VIRTUAL` y su índice aparece en el `EXPLAIN ANALYZE`.

---

## 🧪 15. Ejercicios (24)

Cada ejercicio tiene su solución en `soluciones/19-json-en-los-motores.md`. Empieza por la búsqueda, no por el índice: si no mides la línea de base, no sabes qué ganó el índice.

### 🟢 Fácil (1–8)

### 🟢 Ejercicio 1 — Un `json` que no busca.

Crea una copia del documento como `json` (no `jsonb`) y prueba `@>`. Anota el error y explica por qué el motor lo rechaza.

*Solución:* [soluciones/19-json-en-los-motores.md#ejercicio-1](soluciones/19-json-en-los-motores.md#ejercicio-1)

### 🟢 Ejercicio 2 — Extraer.

Saca la sensibilidad del meropenem de tres cultivos con `->>`, y compara con `->` (que devuelve `jsonb`).

*Solución:* [soluciones/19-json-en-los-motores.md#ejercicio-2](soluciones/19-json-en-los-motores.md#ejercicio-2)

### 🟢 Ejercicio 3 — Las claves de un germen.

Lista los antibióticos que aparecen en los cultivos de *Enterococcus faecalis*, con `jsonb_object_keys`. ¿Cuántos son?

*Solución:* [soluciones/19-json-en-los-motores.md#ejercicio-3](soluciones/19-json-en-los-motores.md#ejercicio-3)

### 🟢 Ejercicio 4 — Un `jsonpath`.

Escribe una consulta que encuentre los cultivos con *algún* antibiótico resistente, usando `@@`. Cuenta cuántos.

*Solución:* [soluciones/19-json-en-los-motores.md#ejercicio-4](soluciones/19-json-en-los-motores.md#ejercicio-4)

### 🟢 Ejercicio 5 — Un índice de expresión.

Crea un índice sobre `antibiogram ->> 'CIPROFLOXACINA'` y confirma con `EXPLAIN` que lo usa para esa expresión, y no para otra.

*Solución:* [soluciones/19-json-en-los-motores.md#ejercicio-5](soluciones/19-json-en-los-motores.md#ejercicio-5)

### 🟢 Ejercicio 6 — El tamaño.

Compara `pg_column_size` del documento y de la fila larga de un mismo cultivo. Explica la diferencia.

*Solución:* [soluciones/19-json-en-los-motores.md#ejercicio-6](soluciones/19-json-en-los-motores.md#ejercicio-6)

### 🟢 Ejercicio 7 — Las claves no tienen orden.

Inserta un documento con las claves en otro orden y compara la igualdad con el original. ¿Qué pasa?

*Solución:* [soluciones/19-json-en-los-motores.md#ejercicio-7](soluciones/19-json-en-los-motores.md#ejercicio-7)

### 🟢 Ejercicio 8 — Un contador.

Cuenta cuántos cultivos tienen *cuatro* o más resistencias, con `jsonb_each_text`.

*Solución:* [soluciones/19-json-en-los-motores.md#ejercicio-8](soluciones/19-json-en-los-motores.md#ejercicio-8)

### 🟡 Intermedio (9–15)

### 🟡 Ejercicio 9 — Dos GIN.

Crea los dos índices GIN sobre el documento, mide el tamaño de cada uno y la búsqueda por meropenem con `EXPLAIN (ANALYZE, BUFFERS)`. Llena una tabla como la del §5.1.

*Solución:* [soluciones/19-json-en-los-motores.md#ejercicio-9](soluciones/19-json-en-los-motores.md#ejercicio-9)

### 🟡 Ejercicio 10 — Lo común.

Repite la búsqueda por ciprofloxacina con `jsonb_path_ops`. ¿Cuántos bloques lee? Explica por qué el índice deja de ayudar cuando la consulta devuelve más del 20 % de la tabla.

*Solución:* [soluciones/19-json-en-los-motores.md#ejercicio-10](soluciones/19-json-en-los-motores.md#ejercicio-10)

### 🟡 Ejercicio 11 — El desorden.

Reordena la tabla `culture_doc` por la columna `meropenem` (un `CLUSTER` sobre el índice de expresión), vuelve a medir y explica el cambio.

*Solución:* [soluciones/19-json-en-los-motores.md#ejercicio-11](soluciones/19-json-en-los-motores.md#ejercicio-11)

### 🟡 Ejercicio 12 — La columna generada en MySQL.

Replica la columna generada del §6 para `CIPROFLOXACINA`, con `VIRTUAL` y con `STORED`. Compara el tamaño de la tabla y el tiempo de escritura de un `UPDATE` masivo.

*Solución:* [soluciones/19-json-en-los-motores.md#ejercicio-12](soluciones/19-json-en-los-motores.md#ejercicio-12)

### 🟡 Ejercicio 13 — Un arreglo.

Describe, con un ejemplo, un índice multivalor de MySQL sobre un arreglo de documentos (por ejemplo, los cultivos de un paciente). ¿Por qué no aplica al antibiograma?

*Solución:* [soluciones/19-json-en-los-motores.md#ejercicio-13](soluciones/19-json-en-los-motores.md#ejercicio-13)

### 🟡 Ejercicio 14 — El costo de la escritura con GIN.

Mide el WAL de insertar 1.000 cultivos nuevos con y sin GIN `jsonb_path_ops`. Anota la diferencia.

*Solución:* [soluciones/19-json-en-los-motores.md#ejercicio-14](soluciones/19-json-en-los-motores.md#ejercicio-14)

### 🟡 Ejercicio 15 — La autopsia en números.

Toma la columna `antibiogram` y cuenta cuántas claves distintas tiene el conjunto de todos los cultivos. Explica por qué eso es el esquema que nadie escribió.

*Solución:* [soluciones/19-json-en-los-motores.md#ejercicio-15](soluciones/19-json-en-los-motores.md#ejercicio-15)

### 🟠 Difícil (16–21)

### 🟠 Ejercicio 16 — Corregir sin reescribir.

Compara `UPDATE ... SET antibiogram = jsonb_set(...)` con reemplazar el documento entero, en WAL y en tiempo, para cinco cultivos. Explica la diferencia.

*Solución:* [soluciones/19-json-en-los-motores.md#ejercicio-16](soluciones/19-json-en-los-motores.md#ejercicio-16)

### 🟠 Ejercicio 17 — Un `CHECK` que duele.

Agrega una restricción que exija que cada cultivo tenga al menos tres antibióticos. Mide qué pasa con los inserts existentes y propón cómo migrarlos sin parar.

*Solución:* [soluciones/19-json-en-los-motores.md#ejercicio-17](soluciones/19-json-en-los-motores.md#ejercicio-17)

### 🟠 Ejercicio 18 — La forma larga contra el documento.

Reconstruye la forma larga desde el documento con `jsonb_each` y compara con la tabla original: ¿cuántas filas faltan o sobran? Si la respuesta no es cero, encuentra la causa.

*Solución:* [soluciones/19-json-en-los-motores.md#ejercicio-18](soluciones/19-json-en-los-motores.md#ejercicio-18)

### 🟠 Ejercicio 19 — El reporte por germen.

Escribe el reporte de resistencia a ciprofloxacina por germen, sobre el documento y sobre la forma larga. Mide ambos y dime cuál gana y en qué.

*Solución:* [soluciones/19-json-en-los-motores.md#ejercicio-19](soluciones/19-json-en-los-motores.md#ejercicio-19)

### 🟠 Ejercicio 20 — Un documento inválido.

Inserta, a propósito, un documento con una sensibilidad `X`, y diseña una vista que lo detecte sin borrarlo. Explica cómo lo detectaría la aplicación.

*Solución:* [soluciones/19-json-en-los-motores.md#ejercicio-20](soluciones/19-json-en-los-motores.md#ejercicio-20)

### 🟠 Ejercicio 21 — El costo de un índice de más.

Con los dos GIN y el índice de expresión, mide el costo de un `INSERT` de 5.000 cultivos. ¿Cuál cuesta más, y cuánto?

*Solución:* [soluciones/19-json-en-los-motores.md#ejercicio-21](soluciones/19-json-en-los-motores.md#ejercicio-21)

### 🔴 Muy difícil (22–24)

### 🔴 Ejercicio 22 — Oracle, con la documentación.

Lee la sección sobre el tipo JSON nativo de Oracle y la validación por esquema. Escribe, sin números, qué ganaría el antibiograma con validación por esquema y qué perdería frente a `CHECK`. (Ningún número de Oracle entra en el curso publicado, D20.)

*Solución:* [soluciones/19-json-en-los-motores.md#ejercicio-22](soluciones/19-json-en-los-motores.md#ejercicio-22)

### 🔴 Ejercicio 23 — La regla de Alameda.

Decide, con argumentos y las medidas de esta fase, si el antibiograma debe ser un documento, una forma larga o las dos cosas. Justifica con la consulta que más se hace y la que más escribe.

*Solución:* [soluciones/19-json-en-los-motores.md#ejercicio-23](soluciones/19-json-en-los-motores.md#ejercicio-23)

### 🔴 Ejercicio 24 — EAV con mejor marketing.

Diseña el mismo antibiograma como EAV (`culture_id`, `key`, `value` dentro de `jsonb`, o como tabla de pares). Mide las tres búsquedas del §5 y dile al equipo si el EAV gana en algo que el documento no gane.


---

*Solución:* [soluciones/19-json-en-los-motores.md#ejercicio-24](soluciones/19-json-en-los-motores.md#ejercicio-24)

## 📚 16. Referencias

**Documentación oficial**

- **Tipos JSON de PostgreSQL 18** — https://www.postgresql.org/docs/18/datatype-json.html — `json` frente a `jsonb`, operadores y `jsonpath`.
- **Índices GIN y sus clases de operador** — https://www.postgresql.org/docs/18/gin.html — `jsonb_ops` y `jsonb_path_ops`.
- **JSON en MySQL 9.7** — https://dev.mysql.com/doc/refman/9.7/en/json.html — el tipo binario, `JSON_SET` y las funciones de extracción.
- **Columnas generadas indexadas en MySQL** — https://dev.mysql.com/doc/refman/9.7/en/create-table-secondary-indexes.html — el índice sobre una columna generada que extrae una ruta.
- **Índices multivalor de MySQL** — la misma sección de índices secundarios, para arreglos dentro de documentos.

**Papers y libros**

- **Martin Kleppmann, *Designing Data-Intensive Applications*, 2.ª ed., O'Reilly, 2026** — el capítulo sobre modelos de datos: documento frente a relacional, y cuándo cada uno.

**Orden de lectura sugerido:** la página de tipos JSON de Postgres antes del §5; la de GIN antes del §5.1; la de columnas generadas de MySQL antes del §6.

> ⚠️ **Verificación pendiente:** las URL de esta sección no se comprobaron con su código de estado en esta sesión. Quedan como deuda de verificación de la fase, y se revisan antes de publicar (plan §4).

---

## 🏁 17. Resultado de la fase

- **Apuesta del §5.1 (lectura del índice): perdida.** Con jsonb_path_ops se leen 27 % de los bloques del seq scan sobre el documento, no menos del 1 %.
- **Apuesta del §7 (WAL del documento): ganada, con matiz.** El documento escribe 1.528 bytes por una corrección contra 112 de la fila, y el umbral de TOAST no se alcanza con antibiogramas cortos.
- **Hallazgo de MySQL (§6.1):** el redo por corrección no distingue la fila del documento a este tamaño: la granularidad de 512 bytes lo tapa.
- **La regla que queda:** `jsonb` es la respuesta cuando el panel varía por registro y la consulta es por germen; la forma larga cuando la consulta es agregada y la integridad importa.

Esta fase deja a F20 el documento de paciente completo, con la propuesta de Florencia: esta es la fase que le concede a Florencia que el documento le sirve a la app, y la mide.

> **La señal de que quedó bien:** *"Antes de guardar algo como documento, sé qué pregunta lo lee, qué índice la contesta y cuántos bytes de WAL cuesta corregirlo."*

> 🏷️ **No cierres la fase sin el tag.** Con el checklist en verde y `git status` limpio:
>
> ```bash
> git tag -a fase-19-json-en-los-motores -m "F19 cerrada: el antibiograma como documento, sus índices y su WAL, en Postgres y MySQL"
> ```
>
> Commits de la fase con prefijo `f19:`, los de ejercicio `f19 ej24: …`.
