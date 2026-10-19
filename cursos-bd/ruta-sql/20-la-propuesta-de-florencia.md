# 🍃 Fase 20 — La propuesta de Florencia, medida: el protocolo como documento, y lo que el documento le concede al modelo relacional

> **Curso:** Ruta SQL · Fase 20 de 27 · Bloque IV — Lo NoSQL dentro del SQL · **10 h**
> **Motores:** PostgreSQL `pgvector/pgvector@sha256:2358fcba361e…` (18.6) · **MongoDB `mongo@sha256:098862b1339f…` (8.0.20)**, el parche vigente en Docker Desktop (ver `a02`) · Oracle Duality Views, solo con la documentación (🪞🔒)
> **Entorno de ejecución:** SQL y Python en `src/20-la-propuesta-de-florencia/`, con `psql` en Postgres y `pymongo` (`uv run --with pymongo`)
> **Perfil de volumen:** muestra de 50.000 protocolos de 2025 con sus 531.736 resultados, sobre la caja M
> **El dolor de Alameda:** la app de 2024 abre un enlace al portal PHP de 2013 para mostrar los resultados, y Florencia propone que cada protocolo sea un documento
> **Depende de:** Fase 19 · **Habilita:** Fase 21
> **Apéndices de apoyo:** a02, a04, a07, a08
> **Fecha de verificación ejecutada:** 14/10/2026
> **Objetivo:** medir la propuesta de Florencia en las cinco operaciones que la app necesita, comparada con dos alternativas dentro del mismo motor relacional, y decidir qué se le concede con número.

---

## 🧭 1. Dónde estamos

La Fase 19 mostró qué pasa cuando un dato sin forma fija se guarda como documento dentro del motor relacional. Esta fase hace la pregunta mayor: **si el protocolo entero es un documento, ¿qué gana y qué pierde la aplicación frente al modelo relacional del Bloque I?** Florencia Marchetti tiene parte de razón, y el curso lo dice antes de medir.

El protocolo de Alameda, visto desde la app, es una unidad: un paciente, una obra social, unas prestaciones, unos resultados, y las correcciones que alguien hizo sobre cada resultado. La pantalla lo lee junto. El modelo relacional lo reparte en `lab_order`, `result`, `patient`, `payer` y la auditoría de correcciones, y para leerlo hace falta reunirlo otra vez. Esa es la tensión que la fase mide.

---

## 🎯 2. Objetivos de esta fase

1. Modelar el protocolo a la manera documental, con las tres reglas de embeber o referenciar.
2. Armar el mismo protocolo en tres diseños: una proyección sobre el modelo relacional, un documento `jsonb` dentro de Postgres y un documento en MongoDB.
3. Medir las cinco operaciones de la ficha en los tres diseños, con el mismo perfil y los mismos índices donde se puede.
4. Decidir, con número, qué se le concede a Florencia y qué no.
5. Validar la forma del documento con `$jsonSchema` y saber qué no valida.

---

## 🚫 3. Qué NO entra todavía

- **Búsqueda de texto, recursión y vectores.** La Fase 21, con `tsvector`, trigramas, `WITH RECURSIVE` y `pgvector`.
- **El documento de paciente completo para la app.** El boss IV de la Fase 21 lo arma con la fuente relacional y la auditoría.
- **Oracle Duality Views.** Se describen como la respuesta "las dos cosas" (🪞🔒): ningún número de Oracle entra en el curso publicado (D20).
- **Sharding, réplicas y concurrencia.** Todo se mide en un nodo, con la caché caliente y un solo cliente.
- **El nombre del paciente.** La muestra no lo incluye: el repositorio no publica datos identificables, y la fase no lo necesita para medir.

---

## 🧩 4. Modelar el protocolo a la manera documental

Un protocolo es la unidad de lectura de la pantalla de resultados, así que es el candidato natural a documento. Las tres reglas de la Fase 03 de la NoSQL Lite (embeber o referenciar) se aplican igual aquí:

- **¿Se lee junto con el padre?** Sí, los resultados se leen con el protocolo: van embebidos.
- **¿Crece sin cota?** Los resultados de un protocolo son unos 10 o 20 (531.736 resultados para 50.000 protocolos: 10,6 de media). Están acotados, así que se embeben. Las correcciones de un resultado, en esta muestra, son como mucho una; en la vida real se acotarían con una regla de negocio, no con la forma del documento.
- **¿Tiene vida propia o se comparte?** El paciente tiene su historia, su fusión con otros pacientes y su identidad, así que se referencia por `patient.id` y se embebe solo un resumen: el sexo y la fecha de nacimiento que la lectura del informe necesita.

El documento de Florencia tiene esta forma:

```json
{
  "_id": 1234567,
  "ordered_on": "2025-01-14",
  "site": "A",
  "payer": { "code": "PAMI" },
  "patient": { "id": 987654, "sex": "F", "birth_date": "1952-03-09" },
  "results": [
    { "analyte": "GLU", "name": "Glucemia", "unit": "mg/dL", "value": 131.0,
      "corrections": [ { "changed_at": "2025-01-15T10:02", "by": "tec_ana",
                         "old_value": "129.0", "reason": "repetición de muestra" } ] },
    { "analyte": "HB", "name": "Hemoglobina", "unit": "g/dL", "value": 13.2 }
  ]
}
```

📝 La forma de los resultados es la que MongoDB guarda como BSON, con sus claves repetidas en cada documento. La forma `jsonb` de Postgres guarda lo mismo con su propia codificación: en la muestra, un protocolo como `jsonb` pesa **1.209 bytes de media**, y la tabla de los 50.000, con sus índices, 67 MB (medido el 18/10/2026 con `pg_column_size` y `pg_total_relation_size`). Cada documento repite los nombres de las claves (`analyte`, `unit`, `corrections`) en cada resultado; en el modelo relacional, el nombre de la columna está una sola vez, en el catálogo.

### 4.1 Los tres diseños, con el mismo dato

| Diseño | Qué es | Dónde vive |
|---|---|---|
| **R** · Relacional con proyección | El modelo del Bloque I (`lab_order`, `result`, `patient`, `payer`, `correction`), armado con `json_agg` al leer | Postgres, tablas de `staging.f20_*` |
| **J** · Documento `jsonb` | Un protocolo, una fila, con sus resultados y correcciones dentro | Postgres, `staging.f20_doc_jsonb` |
| **M** · Documento MongoDB | El mismo protocolo, en una colección | MongoDB 8.0.20, base `alameda`, colección `protocolos` |

Los tres tienen la misma información y los mismos índices donde aplica: la clave del protocolo, el pagador con su fecha, la expresión del analito, y el momento de la corrección. Así la comparación es entre diseños, no entre índices.

### 4.2 El validador: lo que `$jsonSchema` mira, y lo que no

Una colección de MongoDB no tiene esquema, pero se le puede poner uno al crearla. El de `02_cargar_mongo.py` pide que cada protocolo tenga fecha, sede, pagador, paciente y resultados, y que cada resultado tenga su analito y su momento de registro:

```python
SCHEMA = {
    "bsonType": "object",
    "required": ["_id", "ordered_on", "site", "payer", "patient", "results"],
    "properties": {
        "ordered_on": {"bsonType": "date"},
        "payer": {"bsonType": "object", "required": ["code"]},
        "patient": {"bsonType": "object", "required": ["id", "sex"]},
        "results": {"bsonType": "array", "items": {"bsonType": "object",
                    "required": ["analyte", "recorded_at"], …}},
    },
}
```

Un protocolo sin pagador no entra, y el mensaje es corto: `Document failed validation`, con el campo que falta en el detalle del error (E-58 en [`a08`](a08-catalogo-de-errores.md)). Hasta ahí, el validador hace lo que hacen `NOT NULL` y el tipo de una columna.

Lo que no hace es todo lo demás que el Bloque I le pidió al modelo. No sabe si `GLU` existe en el nomenclador, ni si el `patient.id` corresponde a una persona, ni si la obra social tenía convenio esa fecha: **valida la forma de un documento, no su relación con otros**. Tampoco acota el arreglo de correcciones, que es la regla de negocio que hace que el documento no crezca sin fin. Y un validador agregado a una colección que ya tiene datos no revisa lo que ya está: por defecto valida lo que se inserta y lo que se actualiza desde ese momento, como el `NOT VALID` de la Fase 04. En el modelo relacional, esas reglas son claves foráneas y restricciones que el motor hace cumplir; en el documento, son código de la aplicación, que alguien tiene que acordarse de mantener. Es la primera pregunta de las cinco de la [Fase 02](02-las-cinco-preguntas-desde-el-otro-lado.md), la frontera transaccional, vista desde la integridad.

---

## 🔬 5. Las cinco operaciones, con la misma muestra

La ficha pide cinco operaciones. Cada una se mide en los tres diseños: cinco repeticiones tras un calentamiento, y la mediana.

| Operación | Qué hace la app o el equipo |
|---|---|
| **O1 · Leer el informe** | Un protocolo, con todos sus resultados y sus correcciones |
| **O2 · Corregir un resultado** | Cambiar el valor de un resultado y dejar la corrección registrada |
| **O3 · Presentación a la obra social** | Las prestaciones de un pagador en un mes, agrupadas por analito |
| **O4 · Cruce epidemiológico** | Cuántos resultados de glucemia pasan de 126 mg/dL, por sexo, en todo el año |
| **O5 · Auditoría** | Qué correcciones se hicieron en una semana, y quién las hizo |

Fuente: medida de la sesión de verificación del 14/10/2026.

| Operación | R · relacional | J · `jsonb` | M · MongoDB | Ganador |
|---|---:|---:|---:|---|
| O1 leer el informe | 0,78 ms · 105 bloques | 0,54 ms · 3 bloques | 0,65 ms · 1 documento | empate técnico |
| O2 corregir un resultado | 2,45 ms | 1,83 ms | **1,46 ms** | **M**, 1,7 veces más rápido que R |
| O3 presentación a la obra social | **16,1 ms** · 46.243 bloques | 65,0 ms · 21.709 bloques | 26,9 ms · 13.191 documentos | **R** |
| O4 cruce epidemiológico | **25,8 ms** · 20.962 bloques | 96,6 ms · 37.904 bloques | 289 ms · 50.000 documentos (252 ms con índice multikey) | **R**, 11 veces más rápido que M |
| O5 auditoría | **0,72 ms** · 548 bloques | 252 ms · 62.984 bloques | 103 ms · 50.000 documentos (83 ms con índice multikey, 20.417 documentos) | **R**, entre 115 y 143 veces más rápido que M |

> 📝 **Lo que la mediana no dice.** Las cinco operaciones se midieron con un solo cliente, la caché caliente y un nodo. No dicen qué pasa con cuarenta usuarios de la app a la vez, ni con una réplica, ni con la muestra entera de Alameda en lugar de 50.000 protocolos. Lo que sí dicen, y no cambia con la máquina, son los bloques y los documentos examinados: la forma de cada operación. Por eso el ganador de cada fila se decide por el trabajo, y el tiempo lo acompaña.

🧭 Lo que dicen los números, sin adjetivos: **el documento gana la operación que toca un solo protocolo y lo escribe** (O2), y **empata la que lo lee entero** (O1). **El modelo relacional gana cualquier operación que cruza muchos protocolos** (O3, O4, O5), y la diferencia crece con la pregunta: contra MongoDB, la auditoría sin índice examina el 100 % de la colección, y con índice multikey todavía el 41 %.

### 5.1 Por qué O2 favorece al documento

Corregir un resultado en R son dos sentencias en una transacción: el `UPDATE` de `result` y el `INSERT` de `correction`. En M es una sola actualización, con operador posicional, que cambia el valor y agrega la corrección dentro del mismo documento. En J, la escritura cuesta menos que R pero más que M: hay que leer el documento, modificarlo y reescribirlo entero, que es lo que hace Postgres con cualquier `jsonb`.

🪞 **Tu instinto dice…** que un documento que se reescribe entero en cada corrección es el peor caso de escritura. Aquí no lo es, porque el protocolo entero pesa 1,2 kB, y la operación toca un solo protocolo. La apuesta de la ficha no pedía que el documento escribiera poco, sino que la app lo leyera y lo corrigiera sin reunir nada.

### 5.2 Por qué O4 y O5 favorecen al relacional

El cruce de O4 necesita un analito de todos los protocolos. En R, `result` tiene un índice sobre el analito, y la consulta lee 20.962 bloques de la tabla de resultados. En M, sin índice, cada protocolo se abre para mirar sus resultados: son 50.000 documentos examinados, y 289 ms. Con un índice multikey sobre `results.analyte`, el motor examina los 31.673 documentos que tienen glucemia, que son la mayoría: el índice no es selectivo para ese analito.

O5 es peor: la auditoría de una semana es una búsqueda por fecha de corrección. En R, la tabla de correcciones tiene un índice sobre `changed_at`, y la consulta lee 548 bloques. En M, el índice multikey sobre `results.corrections.changed_at` reduce el examen a los 20.417 documentos que tienen una corrección en esa semana, pero el documento sigue siendo la unidad de lectura: para contar correcciones hay que leer el protocolo entero, con todos sus resultados.

> ⚠️ **El índice multikey solo sirve si el `$match` va antes de los `$unwind`.** En la primera versión de la medida, con el filtro después de desenrollar, el índice de auditoría no bajó el tiempo (219 ms con índice, 226 ms sin él). Al pasar el filtro al principio, el mismo índice baja el examen a 20.417 documentos y el tiempo a 83 ms. Es el error de quien piensa que un índice sobre un arreglo funciona en cualquier pipeline.

### 5.3 El pagador: el índice que todos los diseños tienen

O3 es la operación más equilibrada. R y M usan un índice sobre el pagador (con la fecha, en R; solo el pagador, en M), y leen casi el mismo número de registros (46.243 bloques de R, 13.191 documentos de M). La diferencia de 16 a 27 ms es el costo de desenrollar `results` dentro de cada documento que el pipeline recorre. R paga un `JOIN`; M paga un `$unwind`. Es un intercambio, y el número dice cuál de los dos cuesta más en esta caja.

---

## 🪞 6. Tu instinto relacional dice… y la apuesta

**Tu instinto relacional dice** que el documento le conviene a la app solo si la app lee el protocolo siempre entero, y que cualquier pregunta que cruce protocolos es un problema de diseño.

> 🪞 **Apuesta antes de medir** (escrita antes de correr el harness, 14/10/2026): *"leer el informe armado con `json_agg` desde el modelo relacional cuesta como mucho tres veces las lecturas del documento en Mongo, y el cruce epidemiológico en Mongo examina todos los documentos."*
> **Resultado: ganada en las dos mitades.** Leer el informe con `json_agg`: 0,78 ms contra 0,65 ms del documento, 1,2 veces, y no tres. El cruce en Mongo sin índice examina los 50.000 documentos de la muestra, el 100 %.

El resultado de la apuesta tiene matiz: el índice multikey de O4 baja el examen a 31.673 documentos, pero eso sigue siendo el 63 % de la colección. Un analito que aparece en casi todos los protocolos no se beneficia de ningún índice.

---

## 💥 7. El punto de rotura

La rotura de la ficha es **la presentación a la obra social escrita como agregación de Mongo**. Se midió en O3: el documento gana en la lectura de un protocolo y pierde en la de un mes de un pagador. Con 13.191 documentos examinados y 26,9 ms, la agregación es 1,7 veces más lenta que el `JOIN` de R, y la diferencia es lineal con el número de protocolos del mes.

Con la muestra de 50.000 protocolos, la rotura es moderada. Con el volumen completo de Alameda (unos 1,3 millones de protocolos), la presentación mensual de una obra social grande examinaría documentos de todos los meses si el índice no está bien hecho. Eso no se midió en esta caja, y la fase lo deja anotado como la pregunta que sigue.

---

## 🪞 8. Lo que se le concede a Florencia, con número

La ficha dice que la fase tiene que concederle a Florencia lo que ella gana, sin letra chica. Lo que gana, con número:

1. **La corrección de un resultado** en el documento: 1,7 veces más rápida que en el relacional (O2).
2. **La lectura de un informe**: empate técnico con el relacional con proyección (O1). La app recibe el mismo informe en menos de un milisegundo en cualquiera de los tres diseños.

Y lo que no le concede: las consultas que cruzan protocolos (O3, O4, O5). Ahí el relacional gana por 1,7, entre 10 y 11, y entre 115 y 143 veces.

**La respuesta de la fase es una proyección o un documento derivado, no una segunda fuente de verdad.** Florencia tiene razón en que el informe que ve la app es un documento. El relacional tiene razón en que la verdad de un resultado, y su auditoría, no deben vivir en dos lugares. La forma correcta es la del Bloque VI: el modelo relacional como fuente, y el documento como vista de lectura que se reconstruye cuando cambia un resultado.

### 8.1 Las dos cosas a la vez: las *Duality Views* de Oracle

Oracle tiene, desde 23ai, una respuesta que intenta no elegir: las **JSON Relational Duality Views**. Se declara un documento (el protocolo, con sus resultados y sus correcciones adentro) como una vista sobre las tablas relacionales, y la aplicación lo lee y **lo escribe** como documento. El motor traduce cada escritura a las filas de `lab_order`, `result` y la auditoría, con sus claves foráneas y sus restricciones, y cada documento lleva una etiqueta (*ETag*) que cambia cuando cambia cualquiera de sus filas, para que dos escrituras sobre el mismo protocolo no se pisen. Es, dicho en el lenguaje de esta fase, el documento de lectura con una sola fuente de verdad, hecho por el motor en lugar de por la aplicación.

> 🪞🔒 **Apuesta sin resolver: Oracle.** Hipótesis: sobre una *Duality View* del protocolo, leer el informe (O1) cuesta del orden del diseño R con proyección, porque el documento se arma desde las tablas, y la corrección (O2) del orden de R, porque escribe las mismas dos filas; el cruce de O4 se hace sobre las tablas y no sobre la vista, y cuesta lo que cuesta en R. Si eso se cumple, la *Duality View* no le gana a R en ninguna operación: le gana a la aplicación, que deja de mantener la proyección. Resuélvela creando la vista sobre las tablas `f20_*` cargadas en Oracle y midiendo O1, O2 y O4 con `uv run lab measure --engine oracle --private`. El resultado no se publica ([`a09`](a09-licencias-publicacion-y-riesgo.md)).

Lo que la *Duality View* no resuelve es lo que no resuelve ninguna proyección: el documento tiene la forma que le sirve a una pantalla, y la pantalla siguiente pide otra forma. En Postgres, la misma idea se arma a mano, con una vista que devuelve `jsonb` y una función que recibe el documento y escribe las filas; la Fase 23 hace eso para el portal, con la API delante.

> 🩻 **Esto sí funciona igual** en los tres diseños: una transacción. MongoDB tiene transacciones de varios documentos desde la versión 4.0, con foto de comienzo y error si otra transacción escribió el mismo documento; exigen un *replica set*, y el contenedor del laboratorio es un nodo suelto, así que esta fase no las usa. La corrección de O2 en M, que toca un solo documento, es atómica sin transacción: MongoDB garantiza que una actualización de un documento se aplica entera o no se aplica. Por eso el diseño embebido es, también, una decisión de atomicidad. Los índices de MongoDB son árboles B como los de Postgres, con el mismo costo en cada escritura de la Fase 11, y su `explain` cuenta documentos examinados contra devueltos, que es la misma pregunta que `lab measure` le hace a Postgres.

> ⚠️ La premisa de Florencia en su propuesta original era que *"el EAV prueba que lo relacional no calza"*. Esta fase no lo prueba. Lo que prueba es que **un documento de lectura** sirve a la app, y que **un documento de escritura y auditoría** no reemplaza el modelo relacional.

---

## ⚰️ 9. Autopsia: la segunda fuente de verdad

El caso que casi todos los equipos conocen: el documento se convierte en la fuente de la verdad porque la app lo escribe, y el relacional queda como respaldo. Un año después, el informe de la app y la tabla de resultados no coinciden, porque una corrección entró por un camino y no por el otro. La auditoría ya no es confiable porque no hay una sola historia de cada resultado.

El costo no se ve en una medida de latencia: se ve en la reunión en la que se pregunta qué valor es el correcto. La regla de la fase es que **un resultado tiene una sola fuente**, y el documento es una copia que se rehace.

---

## 📖 10. Traducción

| Lo que sabes (relacional) | En MongoDB | Lo que cambia |
|---|---|---|
| `JOIN` entre `lab_order` y `result` | Un documento con `results` embebido | La lectura es una sola operación; el cruce es un `$unwind` |
| Índice sobre la clave foránea | Índice simple sobre el campo del documento | Igual en idea; diferente en qué se lee al encontrarlo |
| Tabla de auditoría | Arreglo `corrections` dentro del resultado | Es acotado solo si la regla de negocio lo acota |
| `CHECK` sobre una columna | `$jsonSchema` en el validador | Valida la forma, no la existencia en otra colección |
| Clave foránea hacia `patient` | Referencia por `patient.id` más un resumen embebido | Se copia lo que la lectura pide, y se acepta que el resumen envejezca |

📖 **De MongoDB a relacional:** el arreglo embebido que crece sin cota se vuelve tabla. El documento que se lee junto se vuelve `JOIN` cuando el cruce gana más que la lectura.

---

## ⚖️ 11. Veredicto honesto: cuándo el documento es la respuesta, y cuándo no

**El documento es la respuesta** cuando la unidad de lectura es una sola entidad, la app la lee entera, las escrituras se hacen sobre esa entidad, y las preguntas que cruzan entidades son raras o se pueden responder desde otra vista. El protocolo para la pantalla de resultados cumple las cuatro.

**El documento no es la respuesta** cuando el cruce es el caso normal (presentaciones, epidemiología, auditoría), cuando la misma entidad tiene varias fuentes de verdad, o cuando la forma cambia tanto que el `$jsonSchema` es una lista de excepciones. La presentación a la obra social cumple las tres.

Para Alameda, en concreto: la pantalla de resultados de la app puede leer un documento, armado desde el modelo cada vez que un resultado cambia, y la presentación a las obras sociales, la notificación epidemiológica y la auditoría siguen leyendo las tablas. Es lo que el boss IV de la [Fase 21](21-hasta-donde-llega-el-motor.md) pide construir.

La regla que sale de la fase: **el documento es un modelo de lectura; el modelo relacional es la fuente**. Un documento derivado se reconstruye cuando cambia la fuente, y el costo de esa reconstrucción es el que la app tiene que pagar.

---

## ⚠️ 12. Errores comunes y diagnóstico

- **Tomar el documento como fuente de verdad** porque es la escritura más fácil. Dos caminos de escritura a la misma historia terminan en auditorías que no cierran.
- **Un índice multikey con el `$match` después del `$unwind`**: el índice existe y no se usa. El `explain` lo muestra con todos los documentos examinados.
- **Creer que un índice sobre un analito muy común es selectivo**: el de glucemia, en esta muestra, cubre el 63 % de la colección.
- **Medir con un solo protocolo y declarar un ganador**: la diferencia de O1 es menor que el ruido, y solo las cinco repeticiones la hacen legible.
- **Comparar un diseño con índices contra otro sin ellos**: aquí todos tienen los mismos índices donde se pudo.

---

## 📋 13. Checklist de validación

- [ ] `staging.f20_order` tiene 50.000 protocolos, `staging.f20_result` 531.736 resultados y `staging.f20_correction` 21.198 correcciones simuladas.
- [ ] La colección `alameda.protocolos` en Mongo tiene 50.000 documentos y su validador `$jsonSchema`.
- [ ] `staging.f20_doc_jsonb` tiene 50.000 documentos y su índice sobre `payer.code`.
- [ ] Cada operación se midió con cinco repeticiones y un calentamiento; la mediana es la que se reporta.
- [ ] El `$match` de O4 y O5 va antes de los `$unwind`, y el `explain` confirma el índice multikey.
- [ ] Las correcciones de la prueba de O2 suman lo mismo en R y en M (12 y 12 en esta corrida).

---

## 🧪 14. Ejercicios (26)

Cada ejercicio tiene su solución en `soluciones/20-la-propuesta-de-florencia.md`. Antes de medir, escribe la apuesta.

### 🟢 Fácil (1–8)

### 🟢 Ejercicio 1 — Un protocolo como documento.

Arma en JSON el protocolo de `min(lab_order_id)` de la muestra, con sus resultados, sin correcciones. Cuenta sus campos.

*Solución:* [soluciones/20-la-propuesta-de-florencia.md#ejercicio-1](soluciones/20-la-propuesta-de-florencia.md#ejercicio-1)

### 🟢 Ejercicio 2 — La forma del validador.

Inserta en la colección un documento sin `payer` y lee el error del validador. Explica por qué lo rechaza.

*Solución:* [soluciones/20-la-propuesta-de-florencia.md#ejercicio-2](soluciones/20-la-propuesta-de-florencia.md#ejercicio-2)

### 🟢 Ejercicio 3 — El pagador.

Cuenta los protocolos de cada obra social, con `payer.code` en Mongo y `payer_code` en Postgres. ¿Coinciden?

*Solución:* [soluciones/20-la-propuesta-de-florencia.md#ejercicio-3](soluciones/20-la-propuesta-de-florencia.md#ejercicio-3)

### 🟢 Ejercicio 4 — Un índice simple.

Crea un índice sobre `payer.code` (ya existe) y consulta `explain` para ver que lo usa. Anota los documentos examinados.

*Solución:* [soluciones/20-la-propuesta-de-florencia.md#ejercicio-4](soluciones/20-la-propuesta-de-florencia.md#ejercicio-4)

### 🟢 Ejercicio 5 — La lectura de un informe.

Mide la lectura de un protocolo en los tres diseños, cinco veces, y anota la mediana.

*Solución:* [soluciones/20-la-propuesta-de-florencia.md#ejercicio-5](soluciones/20-la-propuesta-de-florencia.md#ejercicio-5)

### 🟢 Ejercicio 6 — El tamaño de un documento.

Compara el tamaño medio de un documento en Mongo (`avgObjSize`) y en `jsonb` (`pg_column_size`). ¿Cuál pesa más, y por qué?

*Solución:* [soluciones/20-la-propuesta-de-florencia.md#ejercicio-6](soluciones/20-la-propuesta-de-florencia.md#ejercicio-6)

### 🟢 Ejercicio 7 — Un arreglo vacío.

Busca protocolos sin resultados y cuenta cuántos hay. ¿Qué forma tienen sus documentos en `jsonb`?

*Solución:* [soluciones/20-la-propuesta-de-florencia.md#ejercicio-7](soluciones/20-la-propuesta-de-florencia.md#ejercicio-7)

### 🟢 Ejercicio 8 — Una corrección.

Agrega una corrección a un resultado en Mongo con `$push` y confirma con una consulta que aparece.

*Solución:* [soluciones/20-la-propuesta-de-florencia.md#ejercicio-8](soluciones/20-la-propuesta-de-florencia.md#ejercicio-8)

### 🟡 Intermedio (9–16)

### 🟡 Ejercicio 9 — El cruce sin índice.

Cuenta los resultados de un analito en Mongo con `$unwind` y `$match` después, y con `$match` antes. Compara los documentos examinados.

*Solución:* [soluciones/20-la-propuesta-de-florencia.md#ejercicio-9](soluciones/20-la-propuesta-de-florencia.md#ejercicio-9)

### 🟡 Ejercicio 10 — El multikey que no se usa.

Crea un índice multikey sobre `results.analyte` y mide el cruce con el `$match` mal ubicado y bien ubicado. ¿Cuál lo usa?

*Solución:* [soluciones/20-la-propuesta-de-florencia.md#ejercicio-10](soluciones/20-la-propuesta-de-florencia.md#ejercicio-10)

### 🟡 Ejercicio 11 — La auditoría con índice.

Crea el índice multikey sobre `results.corrections.changed_at` y mide O5 en Mongo con y sin él. Explica la diferencia.

*Solución:* [soluciones/20-la-propuesta-de-florencia.md#ejercicio-11](soluciones/20-la-propuesta-de-florencia.md#ejercicio-11)

### 🟡 Ejercicio 12 — Dos sentencias.

Mide la corrección de O2 en R con y sin transacción explícita. ¿Cambia el tiempo? ¿Por qué debería cambiar la consistencia?

*Solución:* [soluciones/20-la-propuesta-de-florencia.md#ejercicio-12](soluciones/20-la-propuesta-de-florencia.md#ejercicio-12)

### 🟡 Ejercicio 13 — El `jsonb` que se reescribe.

Mide cuántos bytes de WAL cuesta corregir un resultado en `jsonb`, con la historia de un protocolo de cinco resultados.

*Solución:* [soluciones/20-la-propuesta-de-florencia.md#ejercicio-13](soluciones/20-la-propuesta-de-florencia.md#ejercicio-13)

### 🟡 Ejercicio 14 — El resumen que envejece.

Cambia el sexo de un paciente en el modelo relacional y mira qué documentos de Mongo quedan viejos. Dilo en prosa.

*Solución:* [soluciones/20-la-propuesta-de-florencia.md#ejercicio-14](soluciones/20-la-propuesta-de-florencia.md#ejercicio-14)

### 🟡 Ejercicio 15 — La presentación con su índice.

Mide O3 en R y en M sin el índice de `payer` y con él. ¿Cuánto cambia cada una?

*Solución:* [soluciones/20-la-propuesta-de-florencia.md#ejercicio-15](soluciones/20-la-propuesta-de-florencia.md#ejercicio-15)

### 🟡 Ejercicio 16 — El validador que no valida.

Inserta un documento con un analito que no existe en el nomenclador y muestra que `$jsonSchema` lo acepta. Explica qué regla falta.

*Solución:* [soluciones/20-la-propuesta-de-florencia.md#ejercicio-16](soluciones/20-la-propuesta-de-florencia.md#ejercicio-16)

### 🟠 Difícil (17–22)

### 🟠 Ejercicio 17 — Dos fuentes.

Simula que la app corrige un resultado en Mongo y el laboratorio lo corrige en `result`. Dime cuántos protocolos quedan distintos entre R y M, y cómo lo detectarías.

*Solución:* [soluciones/20-la-propuesta-de-florencia.md#ejercicio-17](soluciones/20-la-propuesta-de-florencia.md#ejercicio-17)

### 🟠 Ejercicio 18 — La vista derivada.

Diseña una vista materializada de R que reconstruya el documento y mide su costo de refresco tras corregir 100 resultados.

*Solución:* [soluciones/20-la-propuesta-de-florencia.md#ejercicio-18](soluciones/20-la-propuesta-de-florencia.md#ejercicio-18)

### 🟠 Ejercicio 19 — Un documento que crece.

Agrega 50 correcciones a un mismo resultado en Mongo y mide el tamaño del documento y la latencia de O1. ¿Dónde pasa el umbral?

*Solución:* [soluciones/20-la-propuesta-de-florencia.md#ejercicio-19](soluciones/20-la-propuesta-de-florencia.md#ejercicio-19)

### 🟠 Ejercicio 20 — El límite de 16 MB.

Estima cuántas correcciones por resultado hacen falta para llegar al límite de 16 MB de un documento, y di si el caso es real en Alameda.

*Solución:* [soluciones/20-la-propuesta-de-florencia.md#ejercicio-20](soluciones/20-la-propuesta-de-florencia.md#ejercicio-20)

### 🟠 Ejercicio 21 — La presentación completa.

Escribe la presentación de un mes a una obra social en los tres diseños y compara filas leídas, tiempo y complejidad del código.

*Solución:* [soluciones/20-la-propuesta-de-florencia.md#ejercicio-21](soluciones/20-la-propuesta-de-florencia.md#ejercicio-21)

### 🟠 Ejercicio 22 — Otra forma de la misma pregunta.

Reescribe O4 con un índice de expresión en `jsonb` y mide si el cruce mejora. Anota el resultado aunque sea negativo.

*Solución:* [soluciones/20-la-propuesta-de-florencia.md#ejercicio-22](soluciones/20-la-propuesta-de-florencia.md#ejercicio-22)

### 🔴 Muy difícil (23–26)

### 🔴 Ejercicio 23 — Oracle, con la documentación.

Lee la sección de Duality Views y escribe, sin números, qué es la respuesta "las dos cosas" de Florencia y qué la hace difícil de operar (🪞🔒).

*Solución:* [soluciones/20-la-propuesta-de-florencia.md#ejercicio-23](soluciones/20-la-propuesta-de-florencia.md#ejercicio-23)

### 🔴 Ejercicio 24 — La decisión de Alameda.

Decide, con argumentos y las medidas de la fase, si el protocolo es documento, relacional o las dos cosas. Justifica con la operación que más se hace y la que más escribe.

*Solución:* [soluciones/20-la-propuesta-de-florencia.md#ejercicio-24](soluciones/20-la-propuesta-de-florencia.md#ejercicio-24)

### 🔴 Ejercicio 25 — Tu propia apuesta.

Escribe una apuesta nueva sobre O5 con un número, mídela en los tres diseños, y di si la ganaste.

*Solución:* [soluciones/20-la-propuesta-de-florencia.md#ejercicio-25](soluciones/20-la-propuesta-de-florencia.md#ejercicio-25)

### 🔴 Ejercicio 26 — La presentación en la app.

Diseña la forma del documento de la presentación para una obra social, con los datos que la obra social pide, y di qué parte de ella sería documento y qué parte sería consulta relacional.


---

*Solución:* [soluciones/20-la-propuesta-de-florencia.md#ejercicio-26](soluciones/20-la-propuesta-de-florencia.md#ejercicio-26)

## 📚 15. Referencias

**Documentación oficial**

- **Modelado de datos en MongoDB** — https://www.mongodb.com/docs/manual/data-modeling/ — embeber o referenciar, y el límite de 16 MB.
- **Validación de esquema en MongoDB con `$jsonSchema`** — https://www.mongodb.com/docs/manual/core/schema-validation/
- **Índices multikey** — https://www.mongodb.com/docs/manual/core/index-multikey/ — por qué el filtro va antes de los `$unwind`.
- **Explicar un pipeline con `explain`** — https://www.mongodb.com/docs/manual/reference/command/explain/
- **Funciones JSON de Postgres 18** — https://www.postgresql.org/docs/18/functions-json.html — `json_agg`, `jsonb_build_object` y `jsonb_agg`.
- **Documentación de Oracle sobre Duality Views** — la sección del manual de JSON de la versión 23ai, consultada solo para la comparación (🪞🔒, D20).

**Papers y libros**

- **Martin Kleppmann, *Designing Data-Intensive Applications*, 2.ª ed., O'Reilly, 2026** — el capítulo de modelos de datos, para la discusión de documento contra relacional.

> ⚠️ **Verificación pendiente:** las URL de esta sección no se comprobaron con su código de estado en esta sesión. Quedan como deuda de verificación de la fase (plan §4).

---

## 🏁 16. Resultado de la fase

- **Apuesta del §6 (la lectura con `json_agg` y el cruce sin índice): ganada en las dos mitades.** La lectura del informe cuesta 1,2 veces la del documento, no tres, y el cruce sin índice examina el 100 % de la colección.
- **Florencia gana en la corrección del documento** (O2, 1,7 veces) y **empata en la lectura del informe** (O1). Es lo que se le concede, con número.
- **El relacional gana en lo que cruza protocolos** (O3, O4, O5), por 1,7, entre 10 y 11, y entre 115 y 143 veces.
- **La regla que queda:** el documento es el modelo de lectura de la app; el modelo relacional es la fuente de la verdad y de la auditoría.

Esta fase deja a F21 la pregunta de hasta dónde llega el motor, con la búsqueda por texto, la recursión sobre la jerarquía de prácticas y el vector como muestra breve. Y deja al boss IV la tarea de servir el informe a la app sin perder la fuente ni la auditoría.

> **La señal de que quedó bien:** *"Puedo decir en qué operación gana la propuesta de Florencia, por cuánto, y en cuáles pierde por un orden de magnitud, con la misma muestra para los tres diseños."*

> 🏷️ **No cierres la fase sin el tag.** Con el checklist en verde y `git status` limpio:
>
> ```bash
> git tag -a fase-20-la-propuesta-de-florencia -m "F20 cerrada: las cinco operaciones en tres diseños, medidas con la misma muestra"
> ```
>
> Commits de la fase con prefijo `f20:`, los de ejercicio `f20 ej26: …`.
