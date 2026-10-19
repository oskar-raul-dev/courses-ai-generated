# ✅ Soluciones — Fase 20: La propuesta de Florencia, medida

> **Curso:** Ruta SQL · Solucionario de la [Fase 20](../20-la-propuesta-de-florencia.md)
> **Ejercicios:** 26 · **Perfil:** muestra de 50.000 protocolos de 2025 sobre la caja M · **Motores:** Postgres 18.6 y MongoDB 8.0.20 de [`a02`](../a02-compose-de-la-ruta.md)
> **Fecha de verificación ejecutada:** 14/10/2026

> ⚠️ **Intenta el ejercicio antes de leer su solución.** Leída antes, solo te enseña a reconocerla.

Las soluciones suponen `20-la-propuesta-de-florencia/01_muestra.sql`, `02_cargar_mongo.py` y `03_jsonb.sql` corridos. Los ejercicios 1 a 16 están ejecutados con `05_ejercicios.py`, y su salida se registró en la sesión de verificación del 14/10/2026. Los de 17 a 26 llevan rúbrica. Los tiempos son de una corrida o de la mediana de cinco, según el caso, y se leen con el ruido de la máquina.

---

## 🟢 Fácil (1–8)

### Ejercicio 1

El protocolo elegido tiene nueve resultados, y cada resultado, once campos (los del análisis y, si los tiene, sus correcciones).

```text
campos de primer nivel: ['_id', 'ordered_on', 'patient', 'payer', 'results', 'site']
resultados: 9 · campos del primer resultado: 11
```

**Lectura:** el documento es la unidad que la pantalla lee. Los campos de primer nivel son los que la lectura del informe pide juntos.

### Ejercicio 2

El validador de `$jsonSchema` exige `payer` y lo rechaza:

```text
rechazado: Document failed validation
```

**Por qué:** `payer` está en la lista `required` del esquema. Si el documento no lo tiene, MongoDB no lo guarda. El error no dice qué campo falta; el detalle está en `e.details` del error, y conviene leerlo en la aplicación.

### Ejercicio 3

```text
mongo: {'APROSS': 9852, 'DASPU': 1294, 'GALENO': 1288, 'OSDE': 4571, 'OSECAC': 3082, 'OSPRERA': 1325, 'PAMI': 13191, 'PARTICULAR': 8168, 'SANCOR': 3674, 'SWISS': 1728, 'UOM': 1827}
postgres coincide: True
```

**Lectura:** los dos diseños tienen los mismos 50.000 protocolos con el mismo pagador. La comparación de las operaciones es entre diseños con el mismo dato.

### Ejercicio 4

```text
índices: ['_id_', 'payer.code_1']
PAMI: documentos devueltos 13191 · examinados 13191
```

**Lectura:** con el índice, el motor examina solo los 13.191 documentos que devuelve. Sin él, examinaría los 50.000 (ejercicio 15).

### Ejercicio 5

```text
mediana M: 1.04 ms
```

**Lectura:** es el orden de la lectura de un informe en Mongo. La tabla de §5 de la lección, con las cinco repeticiones y el calentamiento de `04_medir.py`, da 0,65 ms; la diferencia es del ruido de una corrida única, no de la operación.

### Ejercicio 6

```text
BSON medio en Mongo: 1930 bytes · jsonb medio en Postgres: 1209 bytes
BSON pesa más: guarda el tipo y la longitud de cada clave, y las fechas en 8 bytes.
```

**Lectura:** el documento de Mongo pesa 60 % más que el `jsonb` del mismo protocolo. La diferencia viene de la codificación binaria de cada formato; no la desarmamos aquí y no la medimos clave por clave. Es de almacenamiento, no de lectura: el espacio en disco de Mongo es 20,4 MB comprimidos, y el de la tabla `jsonb`, 65 MB.

### Ejercicio 7

```text
protocolos sin resultados: 0
ningún protocolo de la muestra tiene resultados vacíos; el COALESCE de 03_jsonb.sql queda como defensa
```

**Lectura:** en esta muestra no hay protocolos sin resultados. El `COALESCE` de `03_jsonb.sql` evita un `NULL` donde la app espera un arreglo, y es la defensa que la forma pide aunque la caja no la ejercite.

### Ejercicio 8

```text
correcciones del resultado: ['ejercicio 8']
```

**Lectura:** `$push` agrega al arreglo `corrections` del resultado que coincide por el operador posicional `$`. La corrección queda embebida en el protocolo, y el informe la lee con él.

---

## 🟡 Intermedio (9–16)

### Ejercicio 9

```text
filtro después del unwind: documentos examinados 50000
filtro antes del unwind:   documentos examinados 50000
```

**Lectura:** sin índice multikey, las dos formas examinan todo. La diferencia aparece cuando hay índice (ejercicio 10). Una enseñanza que no se ve aquí y que sí importa: el `$match` antes del `$unwind` es la forma que permite usar el índice, y escribirlo así cuesta lo mismo que escribirlo al revés.

### Ejercicio 10

```text
con índice, filtro después: 50000 · con índice, filtro antes: 31673
```

**Lectura:** con el índice multikey sobre `results.analyte`, el filtro antes del desenrollado examina 31.673 documentos, los que tienen glucemia. El filtro después examina los 50.000: el motor no empuja el `$match` hacia el índice cuando va después del `$unwind`. Es la misma regla de §5.2 de la lección, medida.

### Ejercicio 11

```text
sin índice: 50000
con índice: 20417
```

**Lectura:** el índice sobre `results.corrections.changed_at` examina solo los 20.417 documentos con una corrección en la semana. Es el 41 % de la colección: la auditoría sigue leyendo protocolos enteros para contar correcciones, y eso es lo que la lección llama el costo del documento.

### Ejercicio 12

```text
autocommit, dos sentencias: mediana 1.45 ms
transacción explícita: mediana 1.61 ms
Con autocommit, dos sentencias pueden dejar la historia a medias si la segunda falla. La transacción no cambia el tiempo de forma medible y garantiza las dos juntas.
```

**Lectura:** la transacción cuesta casi lo mismo, y es la que garantiza que el `UPDATE` de `result` y el `INSERT` de `correction` ocurran juntos. Sin ella, una falla entre las dos deja un resultado corregido sin su auditoría: la forma más cara de tener dos fuentes de verdad.

### Ejercicio 13

```text
corrida 1: 32504 bytes de WAL
corrida 2: 1416 bytes de WAL
corrida 3: 1440 bytes de WAL
corrida 4: 1416 bytes de WAL
```

**Lectura:** la primera corrida lleva la imagen completa de la página que sigue al `CHECKPOINT` (32.504 bytes). Las siguientes, en régimen, escriben alrededor de 1,4 kB: la tupla del documento de cinco resultados. Es el mismo patrón que la Fase 19 (§7): el documento escribe el documento entero.

### Ejercicio 14

Un paciente cambia de sexo en la tabla de pacientes, por un error de carga corregido. ¿Qué documentos de Mongo quedan viejos?

**Respuesta:** todos los protocolos de ese paciente, porque el documento embebe un resumen con `patient.sex`. La corrección en el modelo relacional no llega a Mongo por sí sola: hay que reescribir los documentos afectados. Eso es lo que la fase llama la copia que envejece (§4 de la lección): se acepta a sabiendas, y la cuenta se hace por protocolos, no por pacientes.

**Rúbrica (sobre 3 puntos):** 1 punto por decir que los documentos afectados son los del paciente; 1 por decir que la corrección no se propaga sola; 1 por proponer cómo encontrarlos (una consulta por `patient.id` sobre la colección) y cuándo hacerlo (en un proceso de sincronización, no en la lectura).

### Ejercicio 15

```text
R sin índice: 271.61 ms
R con índice: 85.40 ms
M sin índice de payer (devueltos, examinados): (13191, 50000)
M con índice de payer (devueltos, examinados): (13191, 13191)
```

**Lectura:** en Mongo, el índice cambia los documentos examinados de 50.000 a 13.191, sin cambiar lo que devuelve. En Postgres, el índice compuesto de `f20_order` cambia el tiempo, pero estos tiempos de una sola corrida son más altos que los de la medida de §5 (16 ms con índice), y la corrida es única, justo después de borrar y recrear el índice. No la afinamos: la cifra de la lección es la mediana de `04_medir.py`.

### Ejercicio 16

```text
aceptado: el validador solo mira la forma, no el nomenclador
```

**Lectura:** `$jsonSchema` valida que `analyte` sea una cadena, no que exista en el nomenclador. Esa regla no puede escribirse en el validador de una colección, porque el validador no consulta otras colecciones. Vive en la aplicación o en un proceso que revisa la colección.

---

## 🟠 Difícil (17–22) — rúbrica

### Ejercicio 17

*Dos fuentes*

**Rúbrica (sobre 4 puntos):**
- 1 punto: describe el escenario en que la app corrige en Mongo y el laboratorio corrige en `result`.
- 1 punto: propone una consulta de comparación entre R y M por protocolo (por ejemplo, hash del conjunto de resultados por `lab_order_id`).
- 1 punto: dice cuántos protocolos quedarían distintos en la muestra si el escenario ocurriera en un 1 % de los resultados, y por qué el número no es cero aunque nadie lo note.
- 1 punto: propone cómo detectarlo antes de que llegue a la obra social (un control periódico, o un evento de escritura en la fuente).

### Ejercicio 18

*La vista derivada*

**Rúbrica (sobre 4 puntos):**
- 1 punto: escribe la vista materializada del documento a partir de R (la forma de `03_jsonb.sql`).
- 1 punto: mide el costo de refrescarla después de corregir 100 resultados (con `REFRESH MATERIALIZED VIEW` completo, y con una actualización incremental si se diseña).
- 1 punto: explica que el refresco completo cuesta lo que toda la tabla, y cuándo eso no importa.
- 1 punto: dice qué ventana de desfase acepta la app, y la consecuencia de leer el documento viejo.

### Ejercicio 19

*Un documento que crece*

**Rúbrica (sobre 4 puntos):**
- 1 punto: agrega 50 correcciones a un mismo resultado en Mongo con `$push`.
- 1 punto: mide el tamaño del documento antes y después, y la latencia de O1.
- 1 punto: identifica el punto en que la latencia de O1 cambia, si lo hay, y por qué (el tamaño sube, pero el informe sigue leyéndose en un solo viaje).
- 1 punto: dice qué regla de negocio acotaría las correcciones, y que la forma del documento no la acota.

### Ejercicio 20

*El límite de 16 MB*

**Rúbrica (sobre 3 puntos):**
- 1 punto: estima cuántas correcciones hacen falta para 16 MB, a partir de 1.930 bytes por documento y el tamaño medio de una corrección (unos 150 bytes en esta muestra).
- 1 punto: dice que el caso no es real en Alameda: un resultado con miles de correcciones no existe en la caja.
- 1 punto: dice qué pasaría si el caso fuera real, y propone el arreglo (sacar las correcciones a una colección propia referenciada por `result_id`).

### Ejercicio 21

*La presentación completa*

**Rúbrica (sobre 4 puntos):**
- 1 punto: escribe la presentación del mes a una obra social en los tres diseños.
- 1 punto: compara filas o documentos leídos, y tiempo, con la tabla de §5.
- 1 punto: compara la complejidad del código (un `JOIN` y un `GROUP BY`, un pipeline de `$unwind` y `$group`, una consulta de `jsonb_array_elements`).
- 1 punto: dice cuál de los tres escribirías, y por qué el costo de código cuenta junto con el de ejecución.

### Ejercicio 22

*Otra forma de la misma pregunta*

**Rúbrica (sobre 3 puntos):**
- 1 punto: crea un índice de expresión en `jsonb` para la glucemia, y lo mide en O4.
- 1 punto: dice el resultado, aunque sea negativo: el índice de expresión sobre un analito que aparece en el 63 % de los documentos no es selectivo.
- 1 punto: propone la alternativa (un índice GIN con `jsonb_path_ops` sobre `results`, o la columna por analito en R) y dice qué medirías.

---

## 🔴 Muy difícil (23–26) — rúbrica

### Ejercicio 23

*Oracle, con la documentación*

**Rúbrica (sobre 4 puntos):**
- 1 punto: describe qué es una Duality View, sin cifras.
- 1 punto: explica la respuesta "las dos cosas": una vista de documento sobre un modelo relacional que se escribe por la vista.
- 1 punto: dice qué la hace difícil de operar (la misma fuente de verdad, la auditoría, la concurrencia de escrituras por dos caminos).
- 1 punto: deja la comparación en 🪞🔒 y no pone ningún número de Oracle en el texto (D20).

### Ejercicio 24

*La decisión de Alameda*

**Rúbrica (sobre 4 puntos):**
- 1 punto: decide (documento, relacional con proyección o las dos) y lo justifica en una frase.
- 1 punto: cita la operación que más se hace (lectura del informe, O1) y su medida.
- 1 punto: cita la operación que más escribe (corrección, O2) y su medida.
- 1 punto: dice qué medida cambiaría la decisión (una presentación mensual que no pudiera indexarse, o un cruce que se volviera la pantalla principal).

### Ejercicio 25

*Tu propia apuesta*

**Rúbrica (sobre 4 puntos):**
- 1 punto: escribe la apuesta con un número antes de medir, sobre O5 o sobre una operación nueva.
- 1 punto: la mide en los tres diseños con cinco repeticiones y calentamiento.
- 1 punto: dice si la ganó, y con qué margen.
- 1 punto: explica qué diseño físico (índice, orden, partición) habría cambiado el resultado, y si lo midió.

### Ejercicio 26

*La presentación en la app*

**Rúbrica (sobre 4 puntos):**
- 1 punto: diseña la forma del documento de presentación con los datos que la obra social pide (paciente, prestación, código, importe, fecha).
- 1 punto: separa lo que es documento (la lectura del lote) de lo que es consulta relacional (el cruce con el nomenclador y el convenio).
- 1 punto: dice qué campo del documento envejece y cómo se rehace.
- 1 punto: dice cuál de las dos partes necesita la fuente relacional, y por qué.
