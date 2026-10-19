# ✅ Soluciones — Fase 21: Hasta dónde llega el motor

> **Curso:** Ruta SQL · Solucionario de la [Fase 21](../21-hasta-donde-llega-el-motor.md)
> **Ejercicios:** 24 · **Perfil:** M · **Motor:** Postgres 18.6 con `pg_trgm`, `unaccent` y `vector` 0.8.7 de [`a02`](../a02-compose-de-la-ruta.md)
> **Fecha de verificación ejecutada:** 14/10/2026

> ⚠️ **Intenta el ejercicio antes de leer su solución.** Leída antes, solo te enseña a reconocerla.

Las soluciones suponen `21-hasta-donde-llega-el-motor/01_setup.sql`, `02_nombres.sql`, `03_recursion.sql` y `04_vectores.sql` corridos. Los ejercicios 1 a 16 están ejecutados con `05_ejercicios.sql`; su salida está en la sesión de verificación del 14/10/2026. Los de 17 a 24 llevan rúbrica.

---

## 🟢 Fácil (1–8)

### Ejercicio 1

```sql
EXPLAIN (COSTS OFF)
SELECT count(*) FROM staging.patient_name WHERE name_tsv @@ to_tsquery('spanish', 'perez');
```

```text
Bitmap Heap Scan on patient_name ... Bitmap Index Scan on patient_name_tsv
```

**Lectura:** con el índice GIN de texto completo, el motor no lee la tabla entera; lee las entradas de la palabra `perez` y de ahí las filas. Sin el índice, el plan es un *Parallel Seq Scan*, como en §5.2 de la lección.

### Ejercicio 2

```text
tsv_prefijo_en_cualquier_palabra | 8577
like_prefijo_del_nombre          | 7748
```

**Lectura:** `per:*` busca cualquier palabra del nombre que empiece con `per`; `LIKE 'PER%'` busca solo el principio. La diferencia de 829 son nombres compuestos en los que la segunda palabra empieza con `PER` y el primero no. Para una pantalla que espera prefijo de nombre, la respuesta correcta es el `LIKE`, o un prefijo de texto completo sobre la primera palabra solamente.

### Ejercicio 3

```text
tsv_rodriges   | 139
tsv_rodriguez  | 4127
```

**Lectura:** el texto completo no cruza el error de tipeo. `rodriges` y `rodriguez` son palabras distintas, y el diccionario no las relaciona. Los trigramas son los que lo resuelven (§5.4 de la lección).

### Ejercicio 4

```text
umbral_020 | 6682
umbral_030 | 1479
umbral_050 | 43
```

**Lectura:** el umbral no es propiedad del índice. A 0,5 quedan 43 candidatos y, con ellos, puede perderse `RODRIGUEZ CAMILA` si el error es grande. A 0,2, quedan casi siete mil, y la pantalla no puede mostrarlos. La decisión es de la pantalla, y se mide.

### Ejercicio 5

```text
con_acento | 3746
sin_acento | 3746
```

**Lectura:** normalizar los dos lados con `unaccent` y mayúsculas hace que `pérez` y `PEREZ` sean la misma búsqueda. La normalización se hace al guardar el nombre (`name_norm`) y se aplica a la consulta, no al revés.

### Ejercicio 6

```text
vector                 | consulta_con_de
'cruz':3 'mari':4      | 'cruz'
```

**Lectura:** `de` y `la` son palabras vacías del español: no entran al vector, y la consulta `de & cruz` se reduce a `cruz`. Para un apellido compuesto como `DE LA CRUZ`, eso es lo que se quiere; para una frase en la que `de` importa, no.

### Ejercicio 7

```text
camila | camilo
'camil':1 | 'camil':1
```

**Lectura:** el stemmer del español reduce `CAMILA` y `CAMILO` a la misma raíz `camil`. Para un nombre propio es una coincidencia no deseada: el texto completo los trata como la misma palabra, y la búsqueda de uno devuelve el otro.

### Ejercicio 8

```text
normalizada                          | 4143
sin_normalizar_mismo_universo        | 4143
sin_normalizar_incluye_fusionados    | 4497
```

**Lectura:** la comparación honesta es con el mismo universo: los 4.143 son los pacientes sin fusionar con `GARCIA`, y lo mismo sin normalizar. Los 4.497 incluyen los fusionados, que la búsqueda no debe devolver. Comparar 4.143 con 4.497 habría parecido una pérdida de la normalización, y no lo es.

---

## 🟡 Intermedio (9–16)

### Ejercicio 9

La jerarquía completa bajo `SEROLOGIA` (21), con su nivel:

```text
component_id | nivel
      22     |   1
      23     |   1
      25     |   1
      26     |   1
      27     |   1
      28     |   1
```

**Lectura:** seis nodos en nivel 1. La composición supuesta de esta fase no tiene un nivel 2 para `SEROLOGIA`; el nivel de más se agrega en el ejercicio 16.

### Ejercicio 10

```text
INSERT 0 1
nodos_con_ciclo_y_union | 7
DELETE 1
```

**Lectura:** con `TOXOPLASMOSIS (27)` "incluyendo" a `SEROLOGIA (21)`, la jerarquía es un ciclo. Con `UNION`, la recursión descarta las filas repetidas y termina, con 7 nodos distintos. Con `UNION ALL`, el ciclo haría que la consulta no terminara nunca. Postgres 14 y posteriores también ofrecen `CYCLE`, que marca el ciclo sin cortar la consulta.

### Ejercicio 11

```text
 source_id | derived_id | nivel 
-----------+------------+-------
        41 |         71 |     1
        20 |         71 |     2
```

**Lectura:** el antibiograma (71) sale del urocultivo (41), que sale de la orina (20). El nivel es la distancia hacia el antibiograma, y el orden de la consulta es el orden de la derivación.

### Ejercicio 12

```text
descr        | coseno | euclidea 
-------------+--------+----------
HEPATOGRAMA  |  0.404 |    0.239
IONOGRAMA    |  0.420 |    0.262
ESPERMOGRAMA |  0.444 |    0.269
```

**Lectura:** el orden de los tres vecinos es el mismo con las dos distancias en esta caja. Eso no siempre pasa: en vectores normalizados coseno y euclídea ordenan igual, y en vectores sin normalizar pueden no hacerlo. Por eso la elección de la distancia es parte del modelo, y se fija con el modelo que produce los vectores.

### Ejercicio 13

```text
Limit
  InitPlan 1 ... Seq Scan on practice_vec (filtro id = 1)
  ->  Index Scan using practice_vec_hnsw on practice_vec p
        Order By: (emb <=> (InitPlan 1).col1)
```

**Lectura:** con la forma escalar, `ORDER BY emb <=> (SELECT emb …)`, el planificador usa el índice HNSW. Con la forma de `JOIN` contra la misma subconsulta, no lo usa, aunque sea la misma consulta para un humano. Con 75 filas, el índice no compra nada; el ejercicio enseña la forma que el planificador necesita.

### Ejercicio 14

```text
tsv_perez_j | 453
trgm_perez_j | 2775
```

**Lectura:** `perez & j:*` pide las dos palabras, con la inicial como prefijo: 453 pacientes. La similitud de trigramas de `PEREZ J` trae 2.775, porque cualquier nombre con `PEREZ` se parece. El texto completo es más preciso para esta pregunta, y los trigramas, más tolerantes. Es el mismo trade-off de §5.4, con otra pregunta.

### Ejercicio 15

```text
Parallel Seq Scan on ex21_names ...          Execution Time: 25.644 ms
Bitmap Index Scan on ex21_tsv ...            Execution Time: 4.296 ms
```

**Lectura:** el índice GIN de texto completo baja el prefijo de 25,6 ms a 4,3 ms sobre la copia de la tabla. El ahorro en bloques sigue el mismo patrón que en §5.2. El tiempo es de una corrida; la cifra que la lección usa es la de `02_nombres.sql`.

### Ejercicio 16

```text
nodos_distintos_del_informe_fijo | 9
nodos_recursivos                 | 10
```

**Lectura:** con un nivel de más (profundidad 5), el informe fijo de cuatro niveles ve 9 nodos distintos, y la recursiva, los 10. El nodo perdido es el de nivel 5. El resultado es el mismo que en §6.2 de la lección: el informe fijo no falla, devuelve menos.

---

## 🟠 Difícil (17–22) — rúbrica

### Ejercicio 17

*Norma y las observaciones*

**Rúbrica (sobre 4 puntos):**
- 1 punto: reconoce que el vocabulario de la caja (seis textos) no es el de la pregunta real (treinta años de texto libre).
- 1 punto: propone texto completo en español con un diccionario médico (sinónimos, abreviaturas) y dice cuál es su costo de mantenimiento.
- 1 punto: propone la medida previa: una muestra de observaciones reales, con un conjunto de preguntas y su resultado esperado, antes de elegir herramienta.
- 1 punto: dice cuándo el motor dedicado se gana el lugar (relevancia, sinónimos y facetas a escala) y cuándo no.

### Ejercicio 18

*Un ciclo que llega a producción*

**Rúbrica (sobre 3 puntos):**
- 1 punto: propone `CYCLE` o un control de ciclos (un `UNION` con la ruta acumulada en un arreglo).
- 1 punto: escribe una consulta de detección que lista los ciclos sin recorrerlos todos.
- 1 punto: dice quién corrige la carga y cómo se evita que vuelva a entrar (una restricción de aplicación o un trigger).

### Ejercicio 19

*El umbral en la pantalla*

**Rúbrica (sobre 4 puntos):**
- 1 punto: separa el término corto (prefijo de texto completo) del nombre completo (trigramas).
- 1 punto: fija el umbral con una medida (los 6.682, 1.479 y 43 candidatos del ejercicio 4) y dice cuál usaría.
- 1 punto: define el orden de resultados (similitud, luego nombre, luego identificador) y dice por qué.
- 1 punto: define qué muestra cuando no hay resultados: una sugerencia con el umbral más bajo, no una pantalla vacía.

### Ejercicio 20

*La apuesta de la recursión, reescrita*

**Rúbrica (sobre 3 puntos):**
- 1 punto: escribe una apuesta con número sobre completitud (por ejemplo, "el informe fijo pierde nodos cuando la profundidad supera a cuatro").
- 1 punto: la mide con la prueba del ejercicio 16 y con una jerarquía de profundidad variable.
- 1 punto: dice si la ganaste, y que la apuesta de costo de la lección no decidía.

### Ejercicio 21

*Vectores con modelo*

**Rúbrica (sobre 4 puntos):**
- 1 punto: describe el cambio de representación (un modelo que produce el vector a partir del texto, y su dimensión).
- 1 punto: estima el costo de generar los vectores (una pasada por cada observación al ingresarla, o al migrar).
- 1 punto: dice qué datos no salen de la caja, y por qué (los datos clínicos).
- 1 punto: dice que la necesidad de medir no cambia: hay que volver a medir la calidad de los vecinos con preguntas reales.

### Ejercicio 22

*El informe fijo en producción*

**Rúbrica (sobre 3 puntos):**
- 1 punto: propone una prueba con un nivel de más sobre una copia de la jerarquía, que falle si el informe pierde nodos.
- 1 punto: usa un dato de producción que la motive (una práctica nueva con un panel dentro de otro).
- 1 punto: dice cómo se automatiza (en la suite de pruebas del catálogo, en cada cambio del nomenclador).

---

## 🔴 Muy difícil (23–24) — rúbrica

### Ejercicio 23

*Oracle, con la documentación*

**Rúbrica (sobre 4 puntos):**
- 1 punto: describe qué ofrece la búsqueda de texto de Oracle (búsqueda por contexto), sin cifras.
- 1 punto: menciona la gestión de sinónimos y de tesauros, y qué la hace distinta de la de Postgres.
- 1 punto: compara en prosa, sin números de Oracle (D20).
- 1 punto: dice qué decisión tomarías con esa comparación.

### Ejercicio 24

*El motor dedicado*

**Rúbrica (sobre 4 puntos):**
- 1 punto: decide (motor relacional, o motor dedicado) con una frase.
- 1 punto: cita la pregunta más frecuente que mediste (la búsqueda de paciente, §5) y su resultado.
- 1 punto: cita la pregunta más exigente que mediste (la jerarquía de profundidad variable, o la búsqueda de observaciones reales) y lo que no pudiste medir.
- 1 punto: dice qué medida cambiaría la decisión (una búsqueda de relevancia con sinónimos a escala de millones de documentos).
