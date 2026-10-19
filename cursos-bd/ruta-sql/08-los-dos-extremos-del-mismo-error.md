# ⚖️ Fase 08 — Los dos extremos del mismo error: tablas anchas, EAV, `jsonb` y un modelo tipado

> **Curso:** Ruta SQL · Fase 08 de 27 · Bloque I — El modelo · **8 h**
> **Motores:** PostgreSQL `pgvector/pgvector@sha256:2358fcba361e…` · — · —
> **Entorno de ejecución:** SQL
> **Perfil de volumen:** M para todo
> **El dolor de Alameda:** las 71 tablas anchas, el EAV de 2008 y el informe que hace `UNION` entre los dos (historia §3, 2008)
> **Depende de:** Fase 07 · **Habilita:** Bloque II
> **Apéndices de apoyo:** a04, a05, a07, a08
> **Fecha de verificación ejecutada:** 14/10/2026
> **Objetivo:** guardar los 12,1 millones de resultados de la caja en cuatro modelos, medirlos con la misma
> consulta clínica y la misma lectura de un informe, y dejar armado con `uv run lab load --model` el modelo
> con el que trabaja el Bloque II.

---

## 🧭 1. Dónde estamos

Las fases anteriores normalizaron casi todo menos lo que el laboratorio produce: el resultado. Es el dato
con más filas, el que Norma firma y el que la red le pide a Alameda. Y es el único que la historia guarda de
dos formas opuestas a la vez.

Hasta 2008, Rubén creaba **una tabla por examen**, con una columna por determinación: `Quimica`, `Hemograma`,
`HemoglobinaGlicosilada`. Son 71, con columnas `Obs` y `Otro1`… para lo que no entraba. En 2008 Matías conectó
los equipos y diseñó `ResultadoItem`: protocolo, código de determinación y **valor como texto**, para todo lo
nuevo. Uno es demasiado rígido; el otro, demasiado flexible. Son **los dos extremos del mismo error**, y el
informe de un paciente con resultados de 2007 y de 2009 hace `UNION` entre los dos.

Esta fase mide cuatro modelos del mismo resultado, con la misma consulta y los mismos índices: la tabla
ancha, el EAV, el documento `jsonb` que propone Florencia, y un modelo tipado.

---

## 🎯 2. Objetivos de esta fase

1. Pasar el valor de texto a un modelo tipado, con un parser que coincida con la verdad en cada fila.
2. Construir los cuatro modelos sobre los mismos 12,1 millones de resultados.
3. Medir la misma consulta clínica y la lectura de un informe en los cuatro: bloques y estimaciones.
4. Dejar el modelo del Bloque I armado con un comando: `uv run lab load --profile m --model`.
5. Resolver el 💀 boss del bloque: la señora que es tres pacientes.

---

## 🚫 3. Qué NO entra todavía

- **El tamaño de las filas, TOAST y el particionado** → [Fase 09](09-el-tamano-de-las-cosas.md).
- **Índices y estadísticas en serio** → [Fase 11](11-indices-y-lo-que-cuestan.md) y [Fase 12](12-estadisticas-y-cardinalidad.md). Aquí los cuatro modelos tienen los mismos índices a
  propósito.
- **El documento como respuesta** (Mongo, `jsonb` con índices, el informe en la app) → Bloque IV.

---

## 🏚️ 4. El dolor, en la caja

> 🏚️ **Lo que Matías hizo con los equipos (historia §3, 2008):** *"Los valores llegan como los escribe cada
> equipo: con coma o con punto según la configuración regional, con `<` o con `>` cuando el valor sale del
> rango de medición, y con leyendas como `HEMOLIZADA` o `REPETIR`. Matías los guarda tal cual. No hay otra
> forma sin romper algo."*

La caja lo confirma. Los 12.134.453 valores de `ResultadoItem`, según la verdad del generador:

```text
    state    |  count
-------------+---------
 comma       | 5405033
 dot         | 5377744
 below       |  359747
 empty       |  359737
 above       |  239894
 hemolyzed   |  239687
 qualitative |  152611
(7 rows)
```

Casi la mitad con coma y la otra mitad con punto; casi seiscientos mil con `<` o `>`; casi doscientos
cuarenta mil que no son un valor sino una observación sobre la muestra (`HEMOLIZADA`, `REPETIR`, `MUESTRA
INSUFICIENTE`); y ciento cincuenta mil cualitativos (`DETECTABLE`, `NO DETECTABLE`).

Y del otro lado, las tablas anchas: en `Quimica`, de 1997 a marzo de 2008, 32.564 glucemias, de las cuales
1.304 no son un número (`VER OBS`, `-`, vacío). Para las 7.377 personas con glucemias en las dos épocas,
cualquier evolución es una `UNION`.

---

## 🧩 5. Cuatro modelos del mismo resultado

### 5.1 El modelo tipado y su parser

`02_typed.sql` separa lo que el texto mezclaba. Un número es un número; el calificador va aparte; el texto
de un cualitativo es texto; la observación sobre la muestra es una bandera; y la unidad y el rango son de la
determinación (la Fase 04 lo midió), no del resultado:

```sql
-- postgres
CREATE TABLE alameda.result (
    result_id     integer PRIMARY KEY,                  -- el IdItem de la caja
    lab_order_id  integer NOT NULL REFERENCES alameda.lab_order (lab_order_id),
    analyte_code  varchar(10) NOT NULL REFERENCES alameda.analyte (analyte_code),
    value_numeric numeric(14, 4),
    qualifier     char(1),
    value_text    varchar(50),
    sample_flag   varchar(30),
    recorded_at   timestamp NOT NULL,
    CONSTRAINT result_qualifier_check CHECK (qualifier IN ('<', '>')),
    CONSTRAINT result_sample_flag_check CHECK (sample_flag IN ('HEMOLIZADA', 'REPETIR', 'MUESTRA INSUFICIENTE')),
    CONSTRAINT result_value_check CHECK (
        (qualifier IS NULL OR value_numeric IS NOT NULL)
        AND num_nonnulls(value_numeric, value_text, sample_flag) <= 1)
);
```

El `CHECK` dice qué combinaciones existen: un calificador sin número no, un número con una bandera de muestra
tampoco. El parser, un `CASE` por columna, corre sobre los 12.132.303 resultados que tienen protocolo (los
2.150 huérfanos de la Fase 04 no entran), y contra la verdad **coincide en todos**, estado por estado. La primera
versión no coincidía en 114.395 cualitativos y dejaba sin bandera 23.870 `MUESTRA INSUFICIENTE`: le sacaba los
espacios a todo el valor, y `NO DETECTABLE` quedaba `NODETECTABLE`. Los espacios se sacan solo después de `<` y
`>`.

`alameda.lab_order` (`01_lab_order.sql`) lleva al paciente que sobrevivió a la fusión de la Fase 05: los
protocolos de una ficha fusionada pasan a la persona.

### 5.2 Los otros tres

- **El EAV** (`03_eav.sql`): `ResultadoItem` tal como está, copiado a `staging` para poder indexarlo, porque en
  `legacy` no se crea nada.
- **La tabla ancha** (`04_wide.sql`): una fila por protocolo y una columna de texto por cada una de las 33
  determinaciones, como las 71 de Rubén pero con todas juntas.
- **El documento** (`05_jsonb.sql`): una fila por protocolo, con sus resultados en `jsonb`; el número como
  número JSON, y lo demás como texto. Es la propuesta de Florencia aplicada al resultado:

```text
 {"k": 3.5000, "cl": 99.0000, "gb": 9501.0000, "gr": 3573504.0000, "hb": 12.7000, "na": 131.0000,
  "glu": 165.0000, "hto": 30.1000, "t4l": 2.1100, "tsh": 1.0500, "crea": 1.4400, "plaq": 353878.0000, "urea": 29.0000}
```

Los cuatro tienen **los mismos índices**: la clave primaria y uno por protocolo. Si uno ganara por un índice que
los otros no tienen, la medición no valdría.

> 📐 **Medición: el mismo resultado en cuatro modelos** · perfil M · `pgvector/pgvector@sha256:2358fcba361e…` ·
> verificado el 14/10/2026
>
> | Modelo | Filas | Tabla | Índices |
> |---|---|---|---|
> | tipado (`alameda.result`) | 12.132.303 | 684 MB | 448 MB |
> | EAV (`staging.result_eav`) | 12.132.303 | 1.049 MB | 368 MB |
> | ancha (`staging.result_wide`) | 1.276.062 | 109 MB | 27 MB |
> | `jsonb` (`staging.result_document`) | 1.276.062 | 294 MB | 27 MB |

La ancha es la más chica: una fila por protocolo, y las columnas vacías casi no ocupan. El EAV es el más grande:
repite en cada fila la unidad y el rango, y guarda cada número como texto.

### 5.3 La consulta clínica

*"Glucemias mayores que 126 en pacientes con hemoglobina glicosilada mayor que 6,5 durante 2024."* En el modelo
tipado:

```sql
-- postgres
WITH o AS (SELECT lab_order_id, patient_id FROM alameda.lab_order
           WHERE ordered_on >= '2024-01-01' AND ordered_on < '2025-01-01'),
     d AS (SELECT DISTINCT o.patient_id FROM o JOIN alameda.result AS r USING (lab_order_id)
           WHERE r.analyte_code = 'HBA1C' AND r.qualifier IS NULL AND r.value_numeric > 6.5)
SELECT count(*) FROM o JOIN d USING (patient_id) JOIN alameda.result AS r USING (lab_order_id)
WHERE r.analyte_code = 'GLU' AND r.qualifier IS NULL AND r.value_numeric > 126;
```

En los otros tres, la condición sobre el valor es la que el modelo obliga a escribir: un `CASE` que convierte
el texto solo si es un número (en el EAV y en la ancha), o que mira si el valor JSON es un número (en el
documento). Los cuatro devuelven **31.083** glucemias.

> 📐 **Medición: la consulta clínica en los cuatro modelos** · perfil M · verificado el 14/10/2026
>
> | Modelo | Bloques | Filas estimadas en el join final | Reales |
> |---|---|---|---|
> | EAV | 269.760 | 196.627 | 31.083 |
> | tipado | 176.902 | 141.842 | 31.083 |
> | `jsonb` | 77.248 | 33.034 | 31.083 |
> | ancha | 29.304 | 33.034 | 31.083 |
>
> Reproducir: las cuatro consultas del ejercicio 8 al 11, con `EXPLAIN (ANALYZE, BUFFERS)`.
>
> En otra carga del mismo perfil, los bloques difieren en uno y las estimaciones cambian con el muestreo de
> `ANALYZE` (130.529, 192.632 y 29.659 en la validación del 14/10/2026); el orden y la forma, no.

Las cuatro recorren su tabla entera dos veces (una por cada determinación), porque ninguna condición sobre el
valor tiene índice. Lo que cambia es cuánto pesa lo que recorren. La ancha y el documento tienen una fila por
protocolo; el tipado y el EAV, una por resultado. Y en la estimación, los dos de una fila por protocolo aciertan,
el tipado se pasa 4,6 veces y el EAV 6,3: en el EAV, el optimizador no sabe nada del valor convertido, y usa su
selectividad por defecto.

### 5.4 La lectura de un informe

El protocolo entero de una paciente, como lo pide el portal:

| Modelo | Filas leídas | Bloques |
|---|---|---|
| tipado (con su determinación) | 13 | 6 |
| EAV | 13 | 4 |
| ancha | 1 | 4 |
| `jsonb` | 1 | 4 |

Para leer un informe, los cuatro son iguales: cuatro o seis bloques por el índice, y en esta escala el
tiempo no se distingue del ruido. La diferencia de modelos no
está en la lectura de uno; está en las preguntas que cruzan muchos.

> 🩻 **Esto sí funciona igual** en los tres motores: la tabla ancha, el EAV y el modelo tipado se escriben igual
> en Postgres, MySQL y Oracle, y la consulta clínica también. El documento cambia de motor a motor, y es del
> Bloque IV.

### 5.5 La `UNION` de las dos épocas

Los cuatro modelos de esta fase empiezan en abril de 2008, porque es cuando empieza el EAV. Antes están las 71
tablas anchas, y una evolución que cruce 2008 tiene que leer las dos:

```text
 viejas | nuevas | ambas
--------+--------+-------
   7382 | 175030 |  7377
(1 row)
```

Casi todas las personas con glucemias en `Quimica` también las tienen en el modelo nuevo: son los crónicos, los
que Norma más mira. La `UNION` tiene tres costos que no se ven en el resultado. Cada tabla ancha es una consulta
distinta (una columna por determinación, con su nombre). El texto de las anchas se convierte con el mismo parser
o la evolución mezcla formatos. Y el paciente de 2005 y el de 2015 tienen que ser la misma persona, que es la
Fase 05. Los tres juntos son el boss de este bloque.

### 5.6 El modelo del Bloque I, con un comando

Las fases 04 a 08 dejaron sus scripts en orden. Desde esta fase, el CLI los corre todos (D41):

Un extracto de la salida:

```text
$ uv run lab load --profile m --model
Cargando el perfil m (caja 3e59292e9918, semilla 1996) en postgres …
  legacy: 419 tablas (33 s)
  truth: 6 tablas (46 s)
  postgres: listo en 62 s
  04-un-valor-un-hecho/01_staging.sql (0 s)
  …
  06-cuarta-y-quinta-forma-normal: planilla de convenios, 1422 filas
  …
  08-los-dos-extremos-del-mismo-error/05_jsonb.sql (257 s)
  modelo: listo en 257 s
```

Borra `staging` y `alameda`, corre los scripts y deja el informe de rechazos con sus trece reglas. Es el punto
de partida del Bloque II, y la tabla de `a05` lo documenta.

---

## 🔀 6. El contraste: dónde otro motor cambia la decisión

Para esta fase, ninguno. Los cuatro modelos y la consulta clínica se escriben igual en MySQL y en Oracle, y la
decisión entre la tabla ancha, el EAV y el modelo tipado es del modelo, no del producto. El documento sí
cambia: MySQL guarda JSON binario sin un índice como el GIN de Postgres, y Oracle tiene su propio tipo JSON y
las *Duality Views*. Eso es el Bloque IV, que pone el documento frente a Mongo y frente al `jsonb`.

---

## 🪞 7. Tu instinto dice… y la apuesta

**Tu instinto dice** que el EAV es el peor de los cuatro por mucho, y que un modelo tipado lo aplasta en
cualquier consulta. Es lo que dice cualquier libro sobre EAV, y la mitad es cierta.

> 🪞 **Apuesta antes de ejecutar** (escrita el 30/09/2026, al diseñar esta fase). *"La consulta clínica sobre el
> EAV lee al menos 10 veces más bloques que sobre el modelo tipado, y su estimación de filas se equivoca por al
> menos un orden de magnitud."*
> **Resultado:** **perdida.** El EAV lee **1,5 veces** los bloques del tipado (269.760 contra 176.902), no 10, y
> su estimación se equivoca **6,3 veces** (196.627 contra 31.083), no 10.

El EAV es peor, y no por lo que la apuesta creía. Los dos modelos tienen una fila por resultado y los dos
recorren su tabla entera: la diferencia es el peso de la fila (el texto, la unidad y el rango repetidos). Y el
modelo tipado también se equivoca en la estimación, 4,6 veces, porque las estadísticas de Postgres son por
columna: sabe cuántas glucemias hay y cuántos valores pasan de 126, pero no cuántas glucemias pasan de 126. Ni
las estadísticas extendidas lo arreglan (ejercicio 16).

Lo que la apuesta no preguntaba: **la tabla ancha gana esta consulta**, con 29.304 bloques, seis veces menos que
el tipado. Una fila por protocolo con las dos determinaciones adentro es exactamente la forma de una pregunta
que cruza dos determinaciones del mismo protocolo. La rigidez de Rubén tenía una virtud, y se mide.

---

## 💥 8. El punto de rotura

Convertir el texto a número, como haría cualquiera la primera vez:

```sql
-- postgres
SELECT count(*) FROM staging.result_eav WHERE analyte_code = 'GLU' AND value::numeric > 126;
```

```text
ERROR:  invalid input syntax for type numeric: "HEMOLIZADA"
```

Con el `replace` de la coma, y con el `ltrim` de los calificadores, el error es el mismo: el primer `HEMOLIZADA`
corta la consulta entera. Y la versión que parece arreglarlo tiene una trampa:

```sql
-- postgres
SELECT count(*) FROM staging.result_eav
WHERE value ~ '^[0-9]+([.,][0-9]+)?$' AND analyte_code = 'GLU' AND replace(value, ',', '.')::numeric > 126;
```

```text
 count
--------
 428014
(1 row)
```

Funcionó, pero SQL no garantiza el orden en que evalúa las condiciones de un `AND`. El optimizador puede poner
la conversión antes que la expresión regular, y el mismo `HEMOLIZADA` vuelve otro día, con otro plan. **El
`CASE` es la única forma que garantiza el orden**, y por eso todas las consultas de esta fase lo usan. En el
modelo tipado, el problema no existe: la conversión se hizo una vez, al cargar, y el `CHECK` impide que vuelva.

---

## ⚰️ 9. Autopsia: el EAV de Matías, una buena idea mal terminada

**1. La decisión.** *"No hace falta una tabla por examen. Todo examen nuevo va a una tabla genérica: protocolo,
determinación y valor."* Matías, 2008.

**2. Por qué era razonable.** Era la solución correcta al problema que tenía: cada examen nuevo era una tabla
nueva, y los equipos mandaban valores en formatos que no se podían convertir sin perder algo. Guardarlos tal
cual no rompía nada, y desde ese día ningún examen nuevo necesitó un cambio de esquema. Que quedó mal terminado, Matías
lo sabe mejor que nadie (historia §5).

**3. Qué pasó después.** Lo que faltaba era el segundo paso: convertir al cargar. Quedó el texto, y cada consulta
que necesita un número lo convierte de nuevo, con su `CASE`, y con el riesgo del primer `HEMOLIZADA`. Medido: 1,5
veces los bloques del modelo tipado, 1.049 MB contra 684, y una estimación 6,3 veces equivocada. Y las 71 tablas
viejas se quedaron al lado, con la `UNION` en cada informe que cruza 2008.

**4. Cuánto cuesta salir.** `02_typed.sql`: un parser de cuatro `CASE` que coincide con la verdad en los 12,1
millones de filas, y dos minutos de carga en esta máquina. Lo caro no es el parser, son las pantallas y los
informes que leen `ResultadoItem` como texto.

**5. Qué lo habría cambiado.** El EAV con el valor tipado desde el primer día: las mismas filas, con
`value_numeric`, `qualifier`, `value_text` y `sample_flag`. La flexibilidad de Matías y los tipos de Rubén. Es,
casi exactamente, el modelo tipado de esta fase.

**Antes y después, con números:** 1.049 MB de texto que se convierte en cada consulta, contra 684 MB tipados que
se convirtieron una vez y que un `CHECK` defiende.

---

## 📖 10. Traducción

| Concepto | Access / T-SQL | Postgres | MySQL | Oracle |
|---|---|---|---|---|
| convertir sin error | `TRY_CAST`, `TRY_CONVERT` | `CASE` con una expresión regular | `CASE` con `REGEXP_LIKE` | `CAST (… DEFAULT NULL ON CONVERSION ERROR)` |
| documento | `nvarchar(max)` con `JSON_VALUE`; tipo `json` en 2025 | `jsonb` | `JSON` | `JSON` (21c) |
| estadísticas de varias columnas | `CREATE STATISTICS` sobre varias columnas | `CREATE STATISTICS … (mcv, dependencies)` | — | estadísticas de grupo de columnas |
| restricción entre columnas | `CHECK` | `CHECK` con `num_nonnulls` | `CHECK` (desde 8.0.16) | `CHECK` |

Hacia la NoSQL Lite: el documento de esta fase es la colección de protocolos de la Lite, y su ventaja es la misma
que se midió aquí: cuando la pregunta cabe en un protocolo, se lee una fila. El diccionario completo está en
[`a07`](a07-diccionario-y-glosario.md).

---

## ⚖️ 11. Veredicto honesto: cuándo NO usar esto

**Cuándo el EAV es la respuesta correcta.** Para atributos abiertos que nadie consulta por valor: las
observaciones, los comentarios del bioquímico, los campos que cada equipo agrega y nadie filtra. Ahí el EAV es
honesto: no promete tipos que no tiene. Para un resultado de laboratorio, que se consulta por valor todos los
días, no lo es.

**Cuándo lo es `jsonb`.** Cuando la unidad de lectura es el protocolo y la mayoría de las preguntas caben adentro:
el informe, el portal, la app. Midió el segundo mejor tiempo en la consulta clínica y un solo índice. Lo que no
trae es el `CHECK` del tipado: un `"glu": "HEMOLIZADA"` entra sin que nadie se entere.

**Cuándo la tabla ancha.** Ganó la consulta clínica, y no se recomienda: cada determinación nueva es un `ALTER
TABLE`, y Alameda tiene 33 en la caja y unas 1.100 en la red. Ganó porque la pregunta tenía su forma.

**El modelo tipado es el del Bloque II** no porque gane todas las mediciones (no gana ninguna de las dos de esta
fase), sino porque es el único que el motor puede defender con restricciones y el único en que una pregunta nueva
no obliga a reconvertir texto. Lo que le falta, índices y estadísticas para preguntas por valor, es exactamente lo
que mide el Bloque II.

**La pregunta que abre el Bloque IV:** si el documento lee casi como la tabla ancha y se escribe como el EAV,
¿cuándo vale la pena el modelo tipado y cuándo el documento? Florencia tiene media razón, y el Bloque IV la mide.

Las cinco preguntas, para lo que enseñó esta fase:

- **Frontera transaccional:** un protocolo con sus resultados se escribe junto, en los cuatro modelos.
- **Consultas conocidas:** el informe (todos igual) y la consulta clínica (gana la forma que la imita).
- **Unidad de lectura:** el protocolo, y por eso el documento y la ancha leen poco.
- **Saltos:** uno, del resultado al protocolo; dos, hasta el paciente.
- **Exactitud o parecido:** exactitud, y el texto no la da.

---

## ⚠️ 12. Errores comunes y diagnóstico

- **`invalid input syntax for type numeric: "HEMOLIZADA"`.** 🩺 Un valor que no es un número llegó a una
  conversión. Usa `CASE`, no un `AND` con la expresión regular delante.
- **`violates check constraint "result_value_check"`.** 🩺 Un número con una bandera de muestra, o un
  calificador sin número. Revisa el parser, no el `CHECK`.
- **Un parser que no coincide con la verdad en una sola categoría.** 🩺 Cuenta por estado, como en la sección
  5.1: 114.395 cualitativos distintos era un `replace` de más.
- **Un índice sobre el valor que no baja los bloques.** 🩺 Las glucemias están repartidas en toda la tabla: el
  índice encuentra las filas, pero visita casi todas las páginas (ejercicio 15). Es del Bloque II.

---

## 📋 13. Checklist de validación

```text
[ ] uv run lab load --profile m --model termina con "modelo: listo" y el informe de rechazos con trece reglas
[ ] alameda.result tiene 12.132.303 filas y el parser coincide con truth.result_value en todas
[ ] los cuatro modelos devuelven 31.083 en la consulta clínica
[ ] la tabla de bloques de la sección 5.3 se reproduce con EXPLAIN (ANALYZE, BUFFERS)
[ ] value::numeric falla con HEMOLIZADA, y el CASE no
[ ] el boss: Norma recibe su paciente entera (la sección 16)
```

---

## 🧪 14. Ejercicios (26)

## 🟢 Fácil — los modelos, uno por uno (1–7)

### 🟢 Ejercicio 1 — Las 71 tablas anchas

Cuenta en el catálogo las tablas de `legacy` que tienen `IdProtocolo` y `Obs`.

**Objetivo:** 71, y tres ejemplos.

[Solución](soluciones/08-los-dos-extremos-del-mismo-error.md#ejercicio-1)

### 🟢 Ejercicio 2 — Los estados del valor

Cuenta los resultados de la caja por estado, con `truth.result_value`.

**Objetivo:** la tabla de la sección 4.

[Solución](soluciones/08-los-dos-extremos-del-mismo-error.md#ejercicio-2)

### 🟢 Ejercicio 3 — El primer `HEMOLIZADA`

Convierte a número el valor de las glucemias del EAV con `value::numeric`.

**Objetivo:** el error literal.

[Solución](soluciones/08-los-dos-extremos-del-mismo-error.md#ejercicio-3)

### 🟢 Ejercicio 4 — Los cuatro modelos

Corre los cinco scripts de `src/08-los-dos-extremos-del-mismo-error/` y mide filas y tamaño de cada modelo.

**Objetivo:** la tabla de la sección 5.2.

[Solución](soluciones/08-los-dos-extremos-del-mismo-error.md#ejercicio-4)

### 🟢 Ejercicio 5 — El parser contra la verdad

Compara `alameda.result` con `truth.result_value`, estado por estado.

**Objetivo:** todos iguales, en los siete estados.

[Solución](soluciones/08-los-dos-extremos-del-mismo-error.md#ejercicio-5)

### 🟢 Ejercicio 6 — Un informe en cuatro modelos

Lee el protocolo 11232670 en los cuatro modelos con `EXPLAIN (ANALYZE, BUFFERS)`.

**Objetivo:** la tabla de la sección 5.4.

[Solución](soluciones/08-los-dos-extremos-del-mismo-error.md#ejercicio-6)

### 🟢 Ejercicio 7 — El documento

Muestra el documento `jsonb` del protocolo 11000001.

**Pregunta:** ¿qué hace el documento con un valor que tiene calificador?

[Solución](soluciones/08-los-dos-extremos-del-mismo-error.md#ejercicio-7)

## 🟡 Intermedio — la consulta clínica (8–14)

### 🟡 Ejercicio 8 — En el modelo tipado

Corre la consulta clínica sobre `alameda.result` con `EXPLAIN (ANALYZE, BUFFERS)`.

**Objetivo:** 31.083 y unos 177.000 bloques.

[Solución](soluciones/08-los-dos-extremos-del-mismo-error.md#ejercicio-8)

### 🟡 Ejercicio 9 — En el EAV

Escribe y mide la misma consulta sobre `staging.result_eav`.

**Objetivo:** 31.083 y unos 270.000 bloques.

[Solución](soluciones/08-los-dos-extremos-del-mismo-error.md#ejercicio-9)

### 🟡 Ejercicio 10 — En la tabla ancha

Escribe y mide la misma consulta sobre `staging.result_wide`.

**Objetivo:** 31.083 y unos 29.000 bloques.

[Solución](soluciones/08-los-dos-extremos-del-mismo-error.md#ejercicio-10)

### 🟡 Ejercicio 11 — En el documento

Escribe y mide la misma consulta sobre `staging.result_document`.

**Objetivo:** 31.083 y unos 77.000 bloques.

[Solución](soluciones/08-los-dos-extremos-del-mismo-error.md#ejercicio-11)

### 🟡 Ejercicio 12 — Las estimaciones

Compara, en los cuatro planes, las filas estimadas y las reales del join final.

**Pregunta:** ¿por qué aciertan los dos modelos de una fila por protocolo?

[Solución](soluciones/08-los-dos-extremos-del-mismo-error.md#ejercicio-12)

### 🟡 Ejercicio 13 — El orden del `AND`

Corre la consulta de la sección 8 con la expresión regular delante de la conversión.

**Pregunta:** si funciona, ¿por qué no es segura?

[Solución](soluciones/08-los-dos-extremos-del-mismo-error.md#ejercicio-13)

### 🟡 Ejercicio 14 — Las dos épocas

Cuenta las personas con glucemias en `Quimica`, en el modelo tipado y en los dos.

**Objetivo:** 7.382, 175.030 y 7.377.

[Solución](soluciones/08-los-dos-extremos-del-mismo-error.md#ejercicio-14)

## 🟠 Difícil — lo que cambia cada modelo (15–20)

### 🟠 Ejercicio 15 — Un índice sobre el valor

Crea un índice `(analyte_code, value_numeric)` en el modelo tipado y vuelve a medir la consulta clínica.

**Pregunta:** el plan usa el índice; ¿por qué los bloques casi no bajan?

[Solución](soluciones/08-los-dos-extremos-del-mismo-error.md#ejercicio-15)

### 🟠 Ejercicio 16 — Estadísticas extendidas

Crea estadísticas `(mcv, dependencies)` sobre `analyte_code` y `value_numeric` y mide otra vez.

**Objetivo:** la estimación antes y después, y por qué no mejora.

[Solución](soluciones/08-los-dos-extremos-del-mismo-error.md#ejercicio-16)

### 🟠 Ejercicio 17 — El peso de una fila

Explica con números por qué el EAV ocupa 1.049 MB y el tipado 684, con las mismas filas.

**Objetivo:** lo que pesan la unidad y el rango repetidos, y el número como texto.

[Solución](soluciones/08-los-dos-extremos-del-mismo-error.md#ejercicio-17)

### 🟠 Ejercicio 18 — El `CHECK` del valor

Inserta en `alameda.result` una glucemia con número y bandera de muestra, y otra con calificador y sin número.

**Objetivo:** los dos errores literales.

[Solución](soluciones/08-los-dos-extremos-del-mismo-error.md#ejercicio-18)

### 🟠 Ejercicio 19 — Las tablas anchas al modelo tipado

Mide cuántas glucemias de `Quimica` son un número y qué son las demás.

**Objetivo:** 31.260 de 32.564, y las tres formas de no serlo.

[Solución](soluciones/08-los-dos-extremos-del-mismo-error.md#ejercicio-19)

### 🟠 Ejercicio 20 — El documento con índice

Crea un índice GIN `jsonb_path_ops` sobre los resultados y mide `results @? '$.glu ? (@ > 126)'` y
`results @> '{"glu": 126}'`.

**Pregunta:** ¿por qué usa el índice en una y no en la otra?

[Solución](soluciones/08-los-dos-extremos-del-mismo-error.md#ejercicio-20)

## 🔴 Muy difícil — decidir (21–26)

### 🔴 Ejercicio 21 — Una determinación nueva

Llega la vitamina D. Escribe lo que cambia en cada uno de los cuatro modelos.

**Objetivo:** las sentencias, y en cuáles hay que tocar consultas que ya existen.

[Solución](soluciones/08-los-dos-extremos-del-mismo-error.md#ejercicio-21)

### 🔴 Ejercicio 22 — Cuándo gana el EAV

Busca en la caja un dato que esté bien en un EAV, y defiéndelo.

**Objetivo:** el dato, por qué nadie lo consulta por valor, y el modelo.

[Solución](soluciones/08-los-dos-extremos-del-mismo-error.md#ejercicio-22)

### 🔴 Ejercicio 23 — Los valores con calificador

La consulta clínica ignora los `>1000`. Reescríbela para que una glucemia `>500` cuente, y mide cuántas suma.

**Objetivo:** 32.691, y la regla clínica que decidiste para cada calificador.

[Solución](soluciones/08-los-dos-extremos-del-mismo-error.md#ejercicio-23)

### 🔴 Ejercicio 24 — Con `lab measure`

Mide la consulta clínica del modelo tipado con `uv run lab measure`.

**Objetivo:** la salida, y qué línea muestra el error de estimación.

[Solución](soluciones/08-los-dos-extremos-del-mismo-error.md#ejercicio-24)

### 🔴 Ejercicio 25 — El modelo del Bloque II

Defiende ante Matías por qué el Bloque II arranca con el modelo tipado y no con su EAV.

**Objetivo:** tres argumentos con números de esta fase, y lo que le reconoces.

[Solución](soluciones/08-los-dos-extremos-del-mismo-error.md#ejercicio-25)

### 🔴 Ejercicio 26 — ¿Documento o tipado?

Florencia propone servir el informe desde `staging.result_document`. Decide qué modelo es la fuente y cuál se
deriva.

**Objetivo:** la decisión, con la lectura del informe y la consulta clínica medidas.

[Solución](soluciones/08-los-dos-extremos-del-mismo-error.md#ejercicio-26)

---

## 📚 15. Referencias

**Documentación oficial**

- **Reglas de evaluación de expresiones en Postgres 18** —
  https://www.postgresql.org/docs/18/sql-expressions.html#SYNTAX-EXPRESS-EVAL — por qué un `AND` no garantiza
  el orden, y el `CASE` como salida.
- **`jsonb` y sus índices en Postgres 18** — https://www.postgresql.org/docs/18/datatype-json.html — `jsonb`,
  `jsonb_path_ops` y qué operadores acelera cada clase.
- **`CREATE STATISTICS` en Postgres 18** — https://www.postgresql.org/docs/18/sql-createstatistics.html — las
  estadísticas de varias columnas.

**Papers y libros**

- **Bill Karwin, *SQL Antipatterns, Volume 1*, Pragmatic Bookshelf, 2022** — el capítulo del EAV, con sus
  alternativas.
- **Prakash M. Nadkarni y otros, "Organization of Heterogeneous Scientific Data Using the EAV/CR
  Representation", *JAMIA*, 1999** — el EAV en sistemas clínicos, defendido por quien lo usa bien.

**Orden de lectura sugerido:** Karwin antes de la sección 5; Nadkarni después del veredicto, para ver el EAV
bien terminado.

> ⚠️ Las URL y sus contenidos cambian. Se consultaron el 14/10/2026.

---

## 🏁 16. Resultado de la fase

```text
EL RESULTADO EN CUATRO MODELOS · perfil M · 12.132.303 resultados
  tipado         684 MB · consulta clínica 176.902 bloques · estimación 4,6× · parser = verdad en el 100 %
  EAV          1.049 MB · consulta clínica 269.760 bloques · estimación 6,3×
  jsonb          294 MB · consulta clínica  77.248 bloques · estimación 1,1×
  ancha          109 MB · consulta clínica  29.304 bloques · estimación 1,1×
  un informe     4 a 6 bloques en los cuatro
EL MODELO DEL BLOQUE I
  uv run lab load --profile m --model     257–274 s · trece reglas de rechazo · punto de partida del Bloque II
```

### 💀 Boss del Bloque I — La señora que es tres pacientes

> *"Tengo una paciente, Elvira Agüero de Bustos. Diabética, viene cada tres meses desde 1999. La conozco, me
> conoce, y cuando le firmo un informe quiero ver su glucemia y su glicosilada de los últimos veinticinco años.
> Pido su evolución y el sistema me da tres pacientes: una con libreta cívica que se corta en 2009, otra con DNI
> que empieza ese mismo año, y un recién nacido, su nieto, que según el sistema tiene una hemoglobina
> glicosilada de 7,9. Quiero una sola Elvira, con todos sus resultados, y quiero saber quién la juntó y cuándo,
> porque si el día de mañana me equivoco con otra paciente, eso tiene que poder deshacerse. Y al nieto no me lo
> mezclen con nadie. Si firmo un informe con la glicosilada de un bebé en la historia de su abuela, el
> problema es de mi matrícula, no del sistema."*
>
> — **Norma Castellani**, directora técnica

**El sistema roto.** Con el modelo de `uv run lab load --profile m --model`,
`src/08-los-dos-extremos-del-mismo-error/boss/01_what_norma_sees.sql` muestra lo que ve Norma: tres pacientes,
la evolución de la glucemia desde 2008 solamente (las tablas anchas no aparecen), y la ficha del nieto con un
control de diabetes adentro.

**Lo que se entrega**, en una transacción:

1. **La persona reconstruida**, con sus dos documentos (la libreta y el DNI que la reemplazó, con el mismo
   número), y la fusión registrada con quién, cuándo y por qué, deshacible como en la Fase 05.
2. **El protocolo de la abuela cargado en la ficha del nieto**, reasignado a ella, con el registro de la
   reasignación. El nieto queda como un paciente aparte, sin documento y sin su protocolo de hemograma tocado.
3. **La historia unificada** de glucemia, hemoglobina glicosilada y creatinina, de 1999 a 2026, en una vista
   que junta las tablas anchas y el modelo tipado con el mismo parser, y que resuelve la fusión.
4. **La medición** de la consulta de la historia con `uv run lab measure`.

**Criterios de aceptación:**

- la cantidad de protocolos de la historia es la que `truth` le asigna a la persona de `truth.planted_case`
  (`boss-1-lady`), ni uno más ni uno menos;
- ningún resultado de hemograma del nieto aparece en la historia de la abuela;
- las glucemias de las dos épocas salen tipadas, y las que no son un número salen como lo que son;
- todo lo que cambió tiene su fila de registro, y se puede deshacer sin borrar nada.

La solución de referencia no se publica: es un encargo, no un ejercicio.

> 🏆 **"Un martes", opcional.** Si vas armando la base nueva de Alameda bloque a bloque, el modelo de `--model`
> es tu primer entregable: los pacientes, sus documentos, los precios con vigencia y los resultados tipados. La
> facturación de un martes todavía no corre sobre él; el Bloque VI la necesita entera.

> **La señal de que quedó bien:** *"Puedo decir cuánto cuesta cada modelo con la misma pregunta, por qué el que
> elegí no ganó ninguna medición, y por qué igual es el correcto."*

> 🏷️ **No cierres la fase sin el tag.** Con el checklist en verde y `git status` limpio:
>
> ```bash
> git tag -a fase-08-los-dos-extremos-del-mismo-error -m "F08 cerrada: el resultado en cuatro modelos medidos con la misma consulta, el parser igual a la verdad, lab load --model, y el boss I"
> ```
>
> Commits de la fase con prefijo `f08:`, los de ejercicio `f08 ej23: …`.

