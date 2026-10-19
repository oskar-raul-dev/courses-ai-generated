# 🔭 Fase 21 — Hasta dónde llega el motor: buscar nombres que la recepción escribe mal, bajar por una jerarquía sin límite de profundidad, y cuándo el vector deja de ser útil

> **Curso:** Ruta SQL · Fase 21 de 27 · Bloque IV — Lo NoSQL dentro del SQL · **10 h** · **cierra el bloque: lleva el boss**
> **Motores:** PostgreSQL `pgvector/pgvector@sha256:2358fcba361e…` (18.6, con `pg_trgm`, `unaccent` y `vector` 0.8.7) · contraste, solo en prosa: la NoSQL Lite, que tiene sus fases de búsqueda, grafos y vectorial
> **Entorno de ejecución:** SQL y Python en `src/21-hasta-donde-llega-el-motor/`
> **Perfil de volumen:** M, con los 242.427 pacientes de la caja y las 75 prácticas de `legacy.Practicas`
> **El dolor de Alameda:** la recepción busca pacientes por nombre mal escrito; el nomenclador tiene prácticas que son paneles de otras prácticas; y Norma quiere buscar en las observaciones libres de treinta años
> **Depende de:** Fase 20 · **Habilita:** el 💀 boss IV, y el Bloque V
> **Apéndices de apoyo:** a02, a04, a07, a08
> **Fecha de verificación ejecutada:** 14/10/2026
> **Objetivo:** distinguir qué resuelve cada herramienta del motor (texto completo, trigramas, recursión, vectores) y dónde se gana su lugar un motor dedicado. Cierra el bloque con el boss del informe en la app.

---

## 🧭 1. Dónde estamos

Las dos fases anteriores midieron documentos. Esta fase mide tres preguntas que la recepción y el equipo hacen todos los días y que el motor relacional responde mal si no se le da la herramienta correcta: **buscar un nombre mal escrito**, **bajar por una jerarquía que no sabemos de qué profundidad es**, y **parecerse a algo** sin que haya una clave que lo diga.

Cada una tiene su herramienta dentro del motor, y cada herramienta tiene su punto de rotura. Esta fase mide los dos lados: lo que se resuelve bien, y lo que se rompe.

---

## 🎯 2. Objetivos de esta fase

1. Buscar nombres con `LIKE`, con texto completo en español (con `unaccent`) y con trigramas, y medir cuál sirve para qué.
2. Entender por qué el texto completo no tolera un error de tipeo, y cuánto ruido trae la similitud de trigramas según el umbral.
3. Recorrer una jerarquía con `WITH RECURSIVE`, con y sin ciclos, y comparar con un informe de niveles fijos.
4. Usar `pgvector` para una búsqueda por parecido, sabiendo cuándo el vector es solo léxico.
5. Resolver el 💀 boss IV: servir el informe a la app con búsqueda por paciente, sin perder la fuente ni la auditoría.

---

## 🚫 3. Qué NO entra todavía

- **Motores dedicados de búsqueda, grafos y vectores.** Se nombran en prosa, con la fase correspondiente de la NoSQL Lite. Aquí solo se mide hasta dónde llega el motor relacional.
- **Embeddings semánticos.** La caja no trae un modelo de lenguaje, y un vector de trigramas no es semántico (§7).
- **Abreviaturas de laboratorio en las observaciones.** Ver §4.3: la caja no las trae, y la rotura que pedía la ficha no se puede medir aquí.
- **Índices de la aplicación y de la pantalla.** La búsqueda se mide en el motor, sin el costo de red.

---

## 🏚️ 4. El dolor, en la caja

### 4.1 Los nombres

La caja tiene **242.427 pacientes** y **95.818 nombres distintos** después de normalizar (sin acentos, en mayúsculas): hay muchas personas con el mismo nombre, y la recepción las distingue por DNI y fecha de nacimiento. Hay también errores de tipeo que la caja refleja: `RODRIGUEZ` aparece como palabra en 4.127 pacientes, y `RODRIGES` en 139.

La pantalla de hoy busca con `LIKE '%PEREZ%'` sobre el nombre. Eso lee todo.

### 4.2 Las prácticas

El nomenclador de la caja (`legacy.Practicas`) es una **lista plana** de 75 prácticas, con su código y su unidad bioquímica. La historia habla de paneles, pero la caja no trae la composición: no hay una tabla que diga qué prácticas forman parte de cuáles.

> 📝 **Supuesto declarado de esta fase.** Para que la jerarquía exista, `staging.practice_composition` declara qué prácticas incluye cada una (`SEROLOGIA` incluye `VDRL`, `CHAGAS`, `TOXOPLASMOSIS`, `RUBEOLA`, `HEPATITISB` y `HEPATITISC`; `PROTEINOGRAMA` incluye `ELECTROFORESIS`). Los códigos son reales, y la composición es del curso, no de la caja. La cadena de derivaciones sí es real: una muestra de orina produce un urocultivo, y el urocultivo, un antibiograma (las tablas `Orina` y `Urocultivo` de la caja lo muestran).

### 4.3 Las observaciones

Norma quiere buscar en las observaciones de treinta años. La caja, sin embargo, tiene **seis textos distintos** en todas sus columnas `Obs`: `REPETIR`, `CONTROL`, `ver hoja`, `MUESTRA LIPEMICA`, `LLAMAR AL MEDICO`, y uno más. No hay abreviaturas como `HEMOLIZ.` ni `S/MUESTRA`.

> ⚠️ **La rotura de la ficha no se puede medir con esta caja.** La ficha la pedía con abreviaturas, y la caja no las tiene. Lo que sí se mide es la búsqueda sobre el vocabulario que hay, que es casi trivial, y la sección de rotura (§7) usa los nombres, donde sí hay errores reales. Si el curso quiere la rotura de abreviaturas, la caja tiene que cambiar, y eso se decide aparte: es una decisión de la generación, no de esta fase.

---

## 🧩 5. Buscar nombres: LIKE, texto completo, prefijo y trigramas

### 5.1 Los tres índices y sus preguntas

Se normaliza el nombre con `unaccent` y mayúsculas, y se guarda un vector de texto completo en español (`to_tsvector('spanish', …)`). Para que `unaccent` pueda indexarse hace falta un envoltorio `IMMUTABLE`, que el script `01_setup.sql` crea.

Cada herramienta responde a una pregunta distinta:

| Pregunta | Herramienta | Índice |
|---|---|---|
| ¿Contiene la palabra? | `LIKE '%PEREZ%'` (sin índice), o texto completo | ninguno, o GIN sobre el vector |
| ¿Empieza con lo que tipea la recepción? | `LIKE 'PER%'` sobre el nombre, o prefijo de texto completo | GIN de trigramas, o GIN de texto completo |
| ¿Se parece, con errores? | `%` (similitud de trigramas) | GIN de trigramas |

### 5.2 Medidas

Con `EXPLAIN (ANALYZE, BUFFERS)`, sobre los 223.889 pacientes que no están fusionados:

| Consulta | Plan | Bloques | Tiempo |
|---|---|---:|---:|
| `LIKE '%PEREZ%'`, sin índice | *Parallel Seq Scan* | 3.136 | 15,4 ms |
| Texto completo `'perez'`, sin índice | *Parallel Seq Scan* | 3.136 | 12,3 ms |
| Texto completo `'perez'`, con GIN | *Bitmap Index Scan* | 2.306 | 2,9 ms |
| `LIKE '%PEREZ%'`, con GIN de trigramas | *Bitmap Index Scan* + recheck | 2.345 | 5,0 ms |

Fuente: medida de la sesión de verificación del 14/10/2026.

Los tres devuelven lo mismo cuando la pregunta es la misma: 4.173 pacientes con `PEREZ` como palabra o como parte del nombre, con y sin acento (ejercicio 5).

🪞 **Tu instinto dice…** que un índice de texto completo sirve para buscar nombres. Sirve para buscar **palabras**. El texto completo responde a "la palabra PEREZ está en el nombre", y no a "el nombre empieza con PER". Esa diferencia no se ve en un ejemplo corto, y se ve en la pantalla.

### 5.3 El prefijo, que no es el prefijo

Lo que la recepción tipea es un prefijo: `PER` mientras escribe. El texto completo tiene un operador de prefijo (`per:*`), y devuelve **8.577** pacientes: cualquier palabra del nombre que empiece con `per`. `LIKE 'PER%'`, sobre el nombre completo, devuelve **7.748**. La diferencia son **829 pacientes** cuyo apellido no empieza con `PER` pero tiene una segunda palabra que sí (por ejemplo, un nombre compuesto).

> ⚠️ **El texto completo busca palabras; el `LIKE` busca el principio.** Si la pantalla espera que el prefijo sea el principio del nombre, el texto completo la lleva a resultados que no son.

### 5.4 El error de tipeo: donde el texto completo se rinde

`RODRIGES CAMILA` no es un nombre de la caja, pero `RODRIGUEZ CAMILA` sí, y es el que la recepción quiere. El texto completo no lo ve: `to_tsquery('spanish', 'rodriges')` devuelve **139** pacientes, todos con la grafía que la consulta tiene, y `rodriguez` devuelve 4.127. Ninguna búsqueda de palabra exacta cruza esa distancia.

Los trigramas sí: `name_norm % 'RODRIGES CAMILA'` devuelve candidatos ordenados por parecido, y `RODRIGUEZ CAMILA` aparece con similitud 0,65. El precio es el ruido, que depende del umbral:

| Umbral de `pg_trgm` | Candidatos para `RODRIGES CAMILA` |
|---:|---:|
| 0,2 | 6.682 |
| 0,3 (por defecto) | 1.479 |
| 0,5 | 43 |

🧭 **El umbral no es una propiedad del índice, es una decisión de la pantalla.** Con 0,2 la recepción ve seis mil nombres; con 0,5 pierde a `RODRIGUEZ CAMILA` si el error es grande. Ninguno de los tres valores es correcto en abstracto.

### 5.5 Por dentro: qué compara un trigrama, y qué guarda el texto completo

Las dos herramientas parecen hacer lo mismo y miran cosas distintas. **Un trigrama es un trozo de tres letras.** `pg_trgm` parte cada palabra con dos espacios adelante y uno atrás, y se queda con el conjunto:

```sql
SELECT show_trgm('PEREZ');
--  {"  p"," pe",ere,"ez ",per,rez}
```

La similitud entre dos textos es la cuenta más simple posible: **trigramas en común sobre trigramas en total**. `RODRIGES CAMILA` tiene 16, `RODRIGUEZ CAMILA` tiene 17, y comparten 13: 13 sobre 20 distintos, 0,65, el número de la sección anterior. Por eso los trigramas toleran el error de tipeo (cambiar una letra rompe dos o tres trigramas de quince) y por eso traen ruido: dos apellidos cortos que comparten la terminación comparten media similitud sin tener nada que ver. El índice GIN de trigramas guarda, para cada trigrama, qué filas lo tienen, y la consulta junta las listas.

**El texto completo no guarda letras: guarda raíces.** `to_tsvector('spanish', …)` pasa cada palabra por el diccionario del idioma, que quita las palabras vacías y reduce cada una a su raíz:

```sql
SELECT to_tsvector('spanish', 'GONZALEZ MARIA DE LOS ANGELES');
--  'angel':5 'gonzalez':1 'mari':2
SELECT to_tsvector('spanish', 'DE LA FUENTE ROSARIO');
--  'fuent':3 'rosari':4
```

`DE` y `LOS` desaparecen, `ANGELES` queda como `angel` y `MARIA` como `mari`. Para un texto en prosa, eso es lo que se quiere: buscar `ángel` encuentra `ángeles`. Para un nombre propio es un problema, y se puede medir:

```sql
SELECT to_tsvector('spanish', 'MARIO') AS mario, to_tsvector('spanish', 'MARIA') AS maria;
--  'mari':1 | 'mari':1
SELECT count(*) FILTER (WHERE name_tsv @@ to_tsquery('spanish', 'maria')) AS ts_maria,
       count(*) FILTER (WHERE name_norm ~ '\mMARIA\M')                     AS palabra_maria,
       count(*) FILTER (WHERE name_norm ~ '\mMARIO\M')                     AS palabra_mario
FROM staging.patient_name;
--  8149 | 4382 | 3767
```

**Buscar `maria` con el diccionario español devuelve 8.149 pacientes: los 4.382 que se llaman MARIA y los 3.767 que se llaman MARIO**, que la raíz junta. La recepción busca a una mujer y recibe casi el doble de nombres, la mitad de hombres (M-78 en la [bitácora](bitacora-de-medicion.md)). Para nombres, la configuración es `simple`, que solo pasa a minúsculas y no recorta: `to_tsvector('simple', 'MARIA')` da `'maria'`. El índice de la sección 5.2 usa `spanish` porque es lo que un equipo pone por defecto, y el boss IV es el lugar para cambiarlo.

> 🩻 **Esto sí funciona igual** que cualquier otro índice de la [Fase 11](11-indices-y-lo-que-cuestan.md): un GIN de trigramas o de texto completo se paga en cada `INSERT` y en cada `UPDATE` del nombre, y como un nombre tiene muchos trigramas, se paga más que un B-tree. Postgres lo amortigua con una lista de pendientes (`fastupdate`) que se vuelca de a tandas; por eso una búsqueda justo después de una carga grande puede leer más bloques que la misma búsqueda un rato después.

### 5.6 La búsqueda que funciona en la caja

El boss IV (§16) necesita las dos cosas: un apellido que se tipea a mitad de palabra, y un nombre completo que puede venir con error. La solución que pasa el arnés separa los dos casos: un término corto se resuelve con prefijo de texto completo, con su índice GIN, y un nombre completo, con trigramas ordenados por parecido. Esa separación es la lección de la fase: **el mismo motor resuelve bien cada pregunta cuando la pregunta se parte en dos.**

---

## 🌳 6. Jerarquías: `WITH RECURSIVE`

### 6.1 El informe fijo de hoy

Un informe que baja cuatro niveles con `LEFT JOIN` fijos funciona mientras la jerarquía tiene cuatro niveles. Es el caso de la caja hoy: la composición supuesta de `SEROLOGIA` tiene dos niveles, y el informe fijo llega a todos sus nodos.

El problema aparece cuando alguien agrega un nivel más. El informe fijo no falla: **devuelve menos**, y nadie se entera.

### 6.2 La prueba del nivel de más

Se agregan cuatro prácticas de prueba bajo `VDRL`, de modo que la profundidad sea cinco. Medido:

| Informe | Nodos distintos que devuelve | Profundidad |
|---|---:|---:|
| Fijo, cuatro `LEFT JOIN` | **9** de 10 | hasta 4 |
| `WITH RECURSIVE` | **10** de 10 | 5, sin límite |

El nodo que falta es el de nivel 5. Ningún error, ninguna alarma, un informe incompleto.

Fuente: medida de la sesión de verificación del 14/10/2026. En tiempo, con 7 filas, las dos formas son indistinguibles (0,17 ms frente a 0,03 ms en la corrida de la lección, con la misma tabla en caché).

🪞 **Apuesta antes de medir** (escrita antes de correr `03_recursion.sql`, 14/10/2026): *"el CTE recursivo del nomenclador completo examina menos filas que la versión que el informe hace hoy con cuatro `LEFT JOIN` fijos."*
**Resultado: no decidida, y mal planteada.** Con siete filas de composición, las dos formas leen la tabla entera, y el número de filas examinadas no separa nada. La comparación que sí decide es otra: **el informe fijo es más barato porque ve menos**. El costo que la apuesta pedía no es el criterio; la completitud sí.

### 6.3 Ciclos

Una jerarquía de prácticas puede tener un ciclo por error de carga: si `TOXOPLASMOSIS` "incluye" a `SEROLOGIA`, que la incluye a ella. Con `UNION ALL`, la recursión no termina. Con `UNION`, la consulta descarta las filas repetidas y termina, con 7 nodos en lugar de una cantidad infinita (ejercicio 10). Postgres 14 y posteriores tienen también la cláusula `CYCLE`, que marca el ciclo sin cortar la consulta.

### 6.4 La cadena hacia arriba

La misma recursión sirve para subir. De dónde sale un antibiograma: el urocultivo (un paso), y la orina de la que sale el urocultivo (dos pasos). El orden de los niveles es el orden de la derivación, y la consulta lo da en una sola pasada.

### 6.5 Por dentro: la recursión es un bucle con una tabla de trabajo

`WITH RECURSIVE` no es recursión en el sentido de una función que se llama a sí misma. Es un bucle: el motor corre la parte de arriba del `UNION` una vez, guarda el resultado en una **tabla de trabajo**, corre la parte de abajo contra esa tabla, agrega lo nuevo al resultado y repite con lo nuevo como tabla de trabajo, hasta que una vuelta no produce filas. Con `UNION`, cada vuelta descarta lo que ya estaba en el resultado, y por eso un ciclo termina: la vuelta que vuelve a `SEROLOGIA` no agrega nada nuevo. Con `UNION ALL` no descarta, y el ciclo da vueltas para siempre.

De ahí salen dos consecuencias prácticas. La primera: el orden en que salen las filas es el de las vueltas, es decir, **por nivel**, no por rama. Si el informe necesita la jerarquía dibujada como árbol, rama por rama, Postgres tiene la cláusula `SEARCH DEPTH FIRST BY …`, que agrega una columna para ordenar en profundidad. La segunda: la condición de corte la pone el dato, no la consulta. Si la jerarquía de prácticas tuviera mil niveles por un error de carga, la recursión los bajaría todos, y una columna de profundidad con un `WHERE depth < 20` en la parte de abajo es el seguro barato contra eso.

---

## 🧲 7. `pgvector`: el parecido que no es significado

La última pregunta es la que más se vende: "buscar lo que se parece". `pgvector` guarda vectores y los compara por distancia: coseno, euclídea o producto interno.

Aquí, como muestra breve y sin modelo de lenguaje (que la caja no trae), cada práctica se representa por un vector de **64 cubetas de trigramas con hash**. Es un vector léxico: dos nombres se parecen si comparten trigramas. La búsqueda exacta sobre las 75 prácticas da:

| Vecino más cercano de `HEMOGRAMA COMPLETO` (coseno) | Distancia |
|---|---:|
| `HEPATOGRAMA` | 0,404 |
| `IONOGRAMA` | 0,420 |
| `ESPERMOGRAMA` | 0,444 |

Los tres comparten la palabra `GRAMA`. No hay ningún significado detrás: un hemograma no se parece a un hepatograma, ni a un espermograma, salvo en la terminación del nombre.

> ⚠️ **Un vector sin modelo es un índice de palabras con otro nombre.** La similitud semántica necesita un modelo que produzca los vectores, y ese modelo es una decisión de producto, con su costo de cómputo y su privacidad (los datos clínicos no salen de la caja). Esta fase lo deja en prosa.

**Lo que haría falta para que el vector signifique algo.** Un modelo de lenguaje que convierta cada texto en un vector, entrenado para que los textos que dicen lo mismo queden cerca. Ese modelo es una pieza nueva del sistema, con tres preguntas que el motor no contesta: dónde corre (los textos clínicos de Alameda no pueden ir a un servicio externo sin un acuerdo de tratamiento de datos), qué versión produjo cada vector (si se cambia el modelo, todos los vectores viejos dejan de ser comparables con los nuevos y hay que recalcularlos), y cuánto cuesta producirlos para treinta años de observaciones. `pgvector` guarda y compara lo que el modelo produce, con el mismo índice HNSW de abajo; no lo reemplaza. Para seis textos distintos de observación, como los de esta caja, ninguna de las tres preguntas se justifica.

**Índice HNSW.** Con 75 vectores, el índice no compra nada. Se mide para aprender la forma de la consulta: el planificador usa `practice_vec_hnsw` solo si el vector de referencia es una **subconsulta escalar** (`ORDER BY emb <=> (SELECT emb …)`). La forma con `JOIN` contra la misma subconsulta no lo usa, aunque sea equivalente (ejercicio 13). Es la misma lección que el índice multikey de la Fase 20: la forma de la consulta decide qué índice se puede usar.

---

## 🪞 8. Tu instinto dice… y la rotura

**Tu instinto dice** que una búsqueda con índice de texto completo resuelve la recepción. Esta fase dice que resuelve la palabra, no el prefijo, no el error de tipeo, y que el error de tipeo necesita trigramas, con un umbral que la pantalla tiene que elegir.

> 💥 **Punto de rotura medido.** El texto completo no encuentra `RODRIGUEZ CAMILA` con la grafía `RODRIGES` (139 contra 4.127 con la correcta). Los trigramas sí, con 1.479 candidatos al umbral de 0,3. La rotura de la búsqueda de nombres es la combinación de las dos: el texto completo sin trigramas pierde el error de tipeo, y los trigramas sin límite inundan la pantalla.

La rotura de la ficha, con abreviaturas de observaciones, queda declarada y no medida (§4.3).

---

## ⚰️ 9. Autopsia: el `LIKE '%PEREZ%'` de la pantalla de recepción

El caso: la pantalla de búsqueda de la recepción usa `LIKE '%término%'` sobre el nombre, sin índice, y la tabla crece. A los 200.000 pacientes, la búsqueda tarda 15 ms en el motor, y a los dos millones, 150. El costo no se nota en la pantalla de prueba, y se nota en el día de los pacientes del lunes.

La autopsia no está en el `LIKE` sino en el hábito: nadie midió la búsqueda con el volumen real, y cuando alguien lo midió, el índice de texto completo se puso a buscar palabras cuando la pantalla necesitaba prefijos. La lección es que **la forma de la pregunta decide la herramienta, y la forma de la pregunta se escribe con el usuario delante**.

---

## 📖 10. Traducción

| Lo que sabes (relacional) | En el motor, para esta fase | Lo que cambia |
|---|---|---|
| `LIKE '%x%'` | Texto completo (palabra) o trigramas (parecido) | El índice responde a una pregunta distinta según la herramienta |
| `LIKE 'x%'` | Prefijo de texto completo (`x:*`) | El prefijo de texto completo busca en cualquier palabra |
| `JOIN` recursivo a mano | `WITH RECURSIVE` | Sin límite de profundidad, y con `UNION` termina si hay ciclos |
| Columna de similitud | `vector` y `<=>` | El vector es un número, y su sentido lo pone el modelo que lo produjo |

📖 **Para un motor dedicado:** cuando la búsqueda es el producto (búsqueda de documentos con relevancia, sinónimos, facetas), el motor dedicado se gana su lugar. Esta fase no lo mide; lo nombra, con la fase correspondiente de la NoSQL Lite.

---

## ⚖️ 11. Veredicto honesto: hasta dónde llega el motor, y cuándo el motor dedicado se gana su lugar

El motor relacional resuelve, sin salir de Postgres, la búsqueda de nombres con prefijo, con trigramas y con texto completo, con un índice cada una. Resuelve la jerarquía con recursión, con sus ciclos bajo control. Y guarda vectores que comparan, aunque no comprendan.

El motor dedicado se gana su lugar cuando **la relevancia es el producto**: ordenar por qué tan buen resultado es, con sinónimos, con facetas, con miles de millones de documentos. La caja de Alameda tiene doscientos mil pacientes y seis textos de observación. No es ese caso.

Para Alameda, la decisión queda escrita así. La recepción busca con dos índices sobre la misma tabla: el de texto completo con la configuración `simple`, para el apellido que se tipea a medias, y el de trigramas, para el nombre completo con error, con un umbral que la pantalla fija y muestra. El nomenclador baja con `WITH RECURSIVE` y un tope de profundidad, porque el informe fijo de cuatro niveles ya demostró que pierde nodos sin avisar. Y el vector queda para cuando haya un texto que lo justifique y un modelo que se pueda correr adentro: hoy no hay ninguno de los dos.

La regla que sale: **empieza con el motor que ya tienes, mide la pregunta real, y cambia de herramienta cuando la medida lo diga, no cuando lo diga la moda.**

---

## ⚠️ 12. Errores comunes y diagnóstico

- **Usar texto completo para buscar prefijos** y sorprenderse de que devuelva palabras del medio del nombre.
- **Creer que `'rodriges'` y `'rodriguez'` son la misma palabra** para el texto completo: no lo son, y la recepción no lo sabe.
- **Fijar el umbral de trigramas sin medir** los candidatos: el valor por defecto de 0,3 deja 1.479 nombres para un error de tipeo.
- **Recursión sin `UNION` sobre un grafo con ciclos**: la consulta no termina.
- **Comparar `JOIN` y subconsulta escalar para un índice ANN** como si fueran la misma consulta para el planificador.
- **Presentar un vector léxico como búsqueda semántica.**
- **Indexar nombres propios con el diccionario `spanish`:** `MARIA` y `MARIO` comparten la raíz `mari`, y buscar a una devuelve a los dos (8.149 contra 4.382, M-78). Para nombres, la configuración es `simple`.

---

## 📋 13. Checklist de validación

- [ ] `staging.patient_name` tiene 223.889 pacientes sin fusionar, y su vector de texto completo y su normalización.
- [ ] Las cuatro consultas de §5.2 devuelven 4.173 pacientes para `PEREZ` cuando la pregunta es la palabra.
- [ ] El umbral de trigramas se fijó explícitamente (`set_limit`) y se midió en 0,2, 0,3 y 0,5.
- [ ] `staging.practice_composition` y `staging.practice_derivation` están creadas, y la composición se declara como supuesto.
- [ ] El informe fijo se compara con la recursiva con un nivel de más, y se reporta la diferencia.
- [ ] El índice HNSW se prueba con la forma escalar, y la salida muestra cuál forma lo usa.
- [ ] El arnés del boss corre sobre un estado limpio (se reconstruyen `staging.f20_*` con `20-la-propuesta-de-florencia/01_muestra.sql` y `03_jsonb.sql`) y reporta sus cinco criterios.

---

## 🧪 14. Ejercicios (24)

Cada ejercicio tiene su solución en `soluciones/21-hasta-donde-llega-el-motor.md`. Los 1 a 16 se corren con `05_ejercicios.sql`, y los 17 a 24 se resuelven con su rúbrica.

### 🟢 Fácil (1–8)

### 🟢 Ejercicio 1 — ¿Qué usa el índice?

Muestra el plan de `to_tsquery('spanish', 'perez')` con y sin GIN.

*Solución:* [soluciones/21-hasta-donde-llega-el-motor.md#ejercicio-1](soluciones/21-hasta-donde-llega-el-motor.md#ejercicio-1)

### 🟢 Ejercicio 2 — El prefijo.

Cuenta los pacientes con `per:*` y con `LIKE 'PER%'`. Explica la diferencia con un ejemplo de la caja.

*Solución:* [soluciones/21-hasta-donde-llega-el-motor.md#ejercicio-2](soluciones/21-hasta-donde-llega-el-motor.md#ejercicio-2)

### 🟢 Ejercicio 3 — El error de tipeo.

Cuenta los pacientes para `rodriges` y `rodriguez` en texto completo.

*Solución:* [soluciones/21-hasta-donde-llega-el-motor.md#ejercicio-3](soluciones/21-hasta-donde-llega-el-motor.md#ejercicio-3)

### 🟢 Ejercicio 4 — El umbral.

Cuenta los candidatos de `RODRIGES CAMILA` con 0,2, 0,3 y 0,5.

*Solución:* [soluciones/21-hasta-donde-llega-el-motor.md#ejercicio-4](soluciones/21-hasta-donde-llega-el-motor.md#ejercicio-4)

### 🟢 Ejercicio 5 — Los acentos.

Compara la búsqueda de `pérez` normalizada con la de `PEREZ`.

*Solución:* [soluciones/21-hasta-donde-llega-el-motor.md#ejercicio-5](soluciones/21-hasta-donde-llega-el-motor.md#ejercicio-5)

### 🟢 Ejercicio 6 — Las palabras vacías.

Muestra qué entra al vector de `DE LA CRUZ MARIA`.

*Solución:* [soluciones/21-hasta-donde-llega-el-motor.md#ejercicio-6](soluciones/21-hasta-donde-llega-el-motor.md#ejercicio-6)

### 🟢 Ejercicio 7 — El stemming.

Compara `CAMILA` y `CAMILO`. ¿Comparten raíz?

*Solución:* [soluciones/21-hasta-donde-llega-el-motor.md#ejercicio-7](soluciones/21-hasta-donde-llega-el-motor.md#ejercicio-7)

### 🟢 Ejercicio 8 — Normalizar la comparación.

Cuenta los `GARCIA` con la búsqueda normalizada y con la no normalizada, sobre el mismo universo de pacientes.

*Solución:* [soluciones/21-hasta-donde-llega-el-motor.md#ejercicio-8](soluciones/21-hasta-donde-llega-el-motor.md#ejercicio-8)

### 🟡 Intermedio (9–16)

### 🟡 Ejercicio 9 — La jerarquía completa.

Lista todos los nodos bajo `SEROLOGIA` con su nivel.

*Solución:* [soluciones/21-hasta-donde-llega-el-motor.md#ejercicio-9](soluciones/21-hasta-donde-llega-el-motor.md#ejercicio-9)

### 🟡 Ejercicio 10 — El ciclo.

Agrega una arista que cree un ciclo, y muestra que `UNION` termina y `UNION ALL` no.

*Solución:* [soluciones/21-hasta-donde-llega-el-motor.md#ejercicio-10](soluciones/21-hasta-donde-llega-el-motor.md#ejercicio-10)

### 🟡 Ejercicio 11 — La cadena hacia arriba.

Escribe la consulta que sube desde el antibiograma hasta el origen.

*Solución:* [soluciones/21-hasta-donde-llega-el-motor.md#ejercicio-11](soluciones/21-hasta-donde-llega-el-motor.md#ejercicio-11)

### 🟡 Ejercicio 12 — Coseno y euclídea.

Compara el orden de las tres prácticas más cercanas con las dos distancias.

*Solución:* [soluciones/21-hasta-donde-llega-el-motor.md#ejercicio-12](soluciones/21-hasta-donde-llega-el-motor.md#ejercicio-12)

### 🟡 Ejercicio 13 — HNSW.

Muestra con `EXPLAIN` que el índice se usa con la forma escalar y no con la forma de `JOIN`.

*Solución:* [soluciones/21-hasta-donde-llega-el-motor.md#ejercicio-13](soluciones/21-hasta-donde-llega-el-motor.md#ejercicio-13)

### 🟡 Ejercicio 14 — El apellido con inicial.

Compara `PEREZ J` con texto completo y con trigramas.

*Solución:* [soluciones/21-hasta-donde-llega-el-motor.md#ejercicio-14](soluciones/21-hasta-donde-llega-el-motor.md#ejercicio-14)

### 🟡 Ejercicio 15 — El índice GIN contra ninguno.

Mide el prefijo sobre una copia de la tabla, con y sin índice.

*Solución:* [soluciones/21-hasta-donde-llega-el-motor.md#ejercicio-15](soluciones/21-hasta-donde-llega-el-motor.md#ejercicio-15)

### 🟡 Ejercicio 16 — El nivel de más.

Agrega un nivel a la jerarquía y cuenta los nodos del informe fijo y de la recursiva.

*Solución:* [soluciones/21-hasta-donde-llega-el-motor.md#ejercicio-16](soluciones/21-hasta-donde-llega-el-motor.md#ejercicio-16)

### 🟠 Difícil (17–22) — rúbrica

### 🟠 Ejercicio 17 — Norma y las observaciones.

La caja tiene seis textos de observación. Escribe qué búsqueda se necesitaría con 30 años de texto libre de verdad, y qué herramienta usarías.

**Rúbrica (sobre 4 puntos):** 1 punto por reconocer que el vocabulario de la caja no es el de la pregunta real; 1 por proponer texto completo con diccionario médico y su costo; 1 por decir qué medida haría antes de decidir; 1 por decir cuándo el motor dedicado se gana el lugar.

*Solución:* [soluciones/21-hasta-donde-llega-el-motor.md#ejercicio-17](soluciones/21-hasta-donde-llega-el-motor.md#ejercicio-17)

### 🟠 Ejercicio 18 — Un ciclo que llega a producción.

Un ciclo entra por carga. Describe cómo lo detectarías en producción, sin cortar la consulta.

**Rúbrica (sobre 3 puntos):** 1 punto por la cláusula `CYCLE` o un control de ciclos; 1 por una consulta de detección; 1 por decir quién corrige la carga.

*Solución:* [soluciones/21-hasta-donde-llega-el-motor.md#ejercicio-18](soluciones/21-hasta-donde-llega-el-motor.md#ejercicio-18)

### 🟠 Ejercicio 19 — El umbral en la pantalla.

Diseña la regla de la pantalla que combina prefijo y trigramas, con el umbral y el orden.

**Rúbrica (sobre 4 puntos):** 1 punto por separar término corto y nombre completo; 1 por el umbral elegido con su medida; 1 por el orden de resultados; 1 por la regla de qué mostrar cuando no hay resultados.

*Solución:* [soluciones/21-hasta-donde-llega-el-motor.md#ejercicio-19](soluciones/21-hasta-donde-llega-el-motor.md#ejercicio-19)

### 🟠 Ejercicio 20 — La apuesta de la recursión, reescrita.

Escribe una apuesta sobre la recursión que se pueda ganar o perder con número.

**Rúbrica (sobre 3 puntos):** 1 punto por una apuesta con número; 1 por la medida que la decide; 1 por decir si la ganaste.

*Solución:* [soluciones/21-hasta-donde-llega-el-motor.md#ejercicio-20](soluciones/21-hasta-donde-llega-el-motor.md#ejercicio-20)

### 🟠 Ejercicio 21 — Vectores con modelo.

Describe qué cambiaría si el vector saliera de un modelo de lenguaje local en lugar de trigramas.

**Rúbrica (sobre 4 puntos):** 1 punto por el cambio de representación; 1 por el costo de cómputo de generar los vectores; 1 por la privacidad de los datos clínicos; 1 por qué no cambia la necesidad de medir.

*Solución:* [soluciones/21-hasta-donde-llega-el-motor.md#ejercicio-21](soluciones/21-hasta-donde-llega-el-motor.md#ejercicio-21)

### 🟠 Ejercicio 22 — El informe fijo en producción.

Un informe fijo de cuatro niveles lleva dos años en producción. Diseña la prueba que lo habría detectado antes.

**Rúbrica (sobre 3 puntos):** 1 punto por una prueba con un nivel de más; 1 por el dato de producción que la motiva; 1 por cómo se automatiza.

*Solución:* [soluciones/21-hasta-donde-llega-el-motor.md#ejercicio-22](soluciones/21-hasta-donde-llega-el-motor.md#ejercicio-22)

### 🔴 Muy difícil (23–24) — rúbrica

### 🔴 Ejercicio 23 — Oracle, con la documentación.

Lee la sección de búsqueda de texto de Oracle y escribe, sin números, qué ofrece y qué no frente a Postgres (🪞🔒, D20).

**Rúbrica (sobre 4 puntos):** 1 punto por describir la búsqueda por contexto; 1 por la gestión de sinónimos; 1 por la comparación en prosa sin cifras; 1 por la decisión que tomarías.

*Solución:* [soluciones/21-hasta-donde-llega-el-motor.md#ejercicio-23](soluciones/21-hasta-donde-llega-el-motor.md#ejercicio-23)

### 🔴 Ejercicio 24 — El motor dedicado.

Decide, con argumentos y las medidas de la fase, si la búsqueda de Alameda necesita un motor dedicado. Justifica con la pregunta más frecuente y la más exigente.

**Rúbrica (sobre 4 puntos):** 1 punto por la decisión; 1 por la pregunta más frecuente medida; 1 por la pregunta más exigente medida; 1 por la medida que cambiaría la decisión.


---

*Solución:* [soluciones/21-hasta-donde-llega-el-motor.md#ejercicio-24](soluciones/21-hasta-donde-llega-el-motor.md#ejercicio-24)

## 📚 15. Referencias

**Documentación oficial**

- **Búsqueda de texto completo en Postgres 18** — https://www.postgresql.org/docs/18/textsearch.html — diccionarios, configuraciones y operadores.
- **`pg_trgm`** — https://www.postgresql.org/docs/18/pgtrgm.html — trigramas, umbral y los índices GIN y GiST.
- **`unaccent`** — https://www.postgresql.org/docs/18/unaccent.html
- **`WITH` y consultas recursivas** — https://www.postgresql.org/docs/18/queries-with.html — incluida la cláusula `CYCLE`.
- **pgvector** — https://github.com/pgvector/pgvector — operadores de distancia, índices HNSW e IVFFlat.

**Papers y libros**

- **Martin Kleppmann, *Designing Data-Intensive Applications*, 2.ª ed., O'Reilly, 2026** — el capítulo de búsqueda y de índices.

> ⚠️ **Verificación pendiente:** las URL de esta sección no se comprobaron con su código de estado en esta sesión. Quedan como deuda de verificación de la fase (plan §4).

---

## 💀 16. Boss del Bloque IV — El informe en la app

**Pedido de Florencia Marchetti:** servir el informe a la app como documento, con búsqueda por paciente, sin perder la fuente relacional ni la auditoría. Cruza F19 (el documento con sus valores), F20 (el informe y las cinco operaciones) y F21 (la búsqueda de nombres).

El punto de partida está en `src/21-hasta-donde-llega-el-motor/boss/`: `informe.py` tiene tres funciones (`buscar_paciente`, `leer_informe`, `corregir`) con fallas que no se dicen, y `arnes.py` evalúa cinco criterios. **Antes de correrlo, reconstruye `staging.f20_*`** con `20-la-propuesta-de-florencia/01_muestra.sql` y `03_jsonb.sql`, porque el arnés escribe en `staging`.

**Los cinco criterios:**

1. **C1 · La búsqueda tolera un error de tipeo.** `RODRIGES CAMILA` tiene que encontrar a `RODRIGUEZ CAMILA` (paciente 1).
2. **C2 · La búsqueda responde en menos de 10 ms** en mediana, sobre cinco búsquedas de `PEREZ`.
3. **C3 · El informe leído es igual a la fuente**, a la precisión de la fuente (4 decimales).
4. **C4 · Una corrección deja fuente, auditoría y documento de acuerdo.**
5. **C5 · Una corrección inválida no cambia nada**: sin usuario, la corrección falla y la fuente queda como estaba.

**Punto de partida:** pasa C2 y C3, y falla C1, C4 y C5. Su salida está en el registro de la sesión.

**Lo que dice el arnés sobre el diseño, no solo sobre el código:**

- C1 y C2 juntos prueban que **un solo índice no sirve para todas las preguntas**. La solución separa el término corto (prefijo de texto completo, con GIN) del nombre completo (trigramas, con similitud). Dos intentos fallaron y se midieron: ordenar por similitud sobre los miles de candidatos de `PEREZ` tardó 121 ms, y ordenar con un GiST por distancia (`<->`) dejó afuera a `RODRIGUEZ CAMILA` del top 20.
- C4 y C5 prueban que **el documento y la auditoría son escrituras de la misma transacción**. La solución valida antes de escribir, y reescribe el documento con el valor de la fuente, sin pasar por `float`.
- C3 trae un hallazgo de la caja: un documento escrito desde Python en `float` quedó en 9,699999999999996 frente a 9,7000 en la fuente, por acumulación de 0,1. Por eso C3 compara a 4 decimales, la precisión de la fuente, y por eso la solución escribe el valor con `numeric`.

**Solución:** no se publica (D42). Está en la sesión de verificación del 14/10/2026, con su salida en el registro de la sesión: **cinco de cinco**.

---

## 🏁 17. Resultado de la fase

- **Búsqueda de nombres:** el texto completo busca palabras, no prefijos (8.577 frente a 7.748), y no tolera errores de tipeo (139 frente a 4.127). Los trigramas tolerán el error y traen ruido según el umbral (1.479 candidatos a 0,3).
- **Recursión:** el informe fijo de cuatro niveles devuelve 9 de 10 nodos cuando la jerarquía tiene cinco; la recursiva, los 10. La apuesta de costo no decide con siete filas; la de completitud, sí.
- **Vectores:** `pgvector` busca parecido léxico. Sin modelo de lenguaje, `HEMOGRAMA` se parece a `HEPATOGRAMA` por la terminación, no por el significado.
- **Rotura de abreviaturas:** no se puede medir en esta caja, y queda declarada.
- **El boss IV pasa cinco de cinco**, con la solución fuera del repositorio.

Esta fase cierra el Bloque IV. El Bloque V abre con la exportación de las 9:40, y con el motor que ya conoce el curso: lo que sale de la base, cuándo, y por qué no es un problema de búsqueda.

> 🏆 **"Un martes", opcional.** Si vas armando la base nueva de Alameda bloque a bloque, el Bloque IV te deja qué es documento
> y qué no: el antibiograma en `jsonb` con su validación, el informe derivado de la fuente relacional para la app, y la búsqueda de
> pacientes con trigramas. La facturación de un martes no cambia: sigue siendo relacional, porque cruza precios, convenios y
> coseguros. El Bloque V trae lo que pasa cuando esa facturación tiene que salir de la base hacia otros sistemas.

> **La señal de que quedó bien:** *"Sé hasta dónde llega el motor: qué búsqueda tolera el tipeo, qué recursión ve toda la jerarquía, y qué parecido es léxico y no semántico."*

> 🏷️ **No cierres la fase sin el tag.** Con el checklist en verde y `git status` limpio:
>
> ```bash
> git tag -a fase-21-hasta-donde-llega-el-motor -m "F21 cerrada: la búsqueda de nombres, la recursión, los vectores y el boss IV"
> ```
>
> Commits de la fase con prefijo `f21:`, los de ejercicio `f21 ej24: …`.
