# 📊 Fase 12 — Estadísticas y cardinalidad: lo que el optimizador cree, y cuándo se equivoca

> **Curso:** Ruta SQL · Fase 12 de 27 · Bloque II — La física y el tuning · **10 h**
> **Motores:** PostgreSQL `pgvector/pgvector@sha256:2358fcba361e…` · contraste MySQL `mysql@sha256:e2bde46db656…` · —
> **Entorno de ejecución:** SQL
> **Perfil de volumen:** M, con el modelo de `uv run lab load --profile m --model`
> **El dolor de Alameda:** el informe de la pandemia, que un mes tardaba segundos y al siguiente no terminaba (historia §3, 2020)
> **Depende de:** Fase 11 · **Habilita:** Fase 13
> **Apéndices de apoyo:** a03, a04, a07, a08
> **Fecha de verificación ejecutada:** 14/10/2026
> **Objetivo:** leer lo que el optimizador cree sobre los datos, medir cuánto se equivoca nodo por nodo, y saber cuándo
> ese error cambia el plan y cuándo no le cuesta nada.

---

## 🧭 1. Dónde estamos

La [Fase 11](11-indices-y-lo-que-cuestan.md) midió lo que compra cada índice. Pero quien decide si un índice se usa no es
quien lo crea: es el optimizador, y decide con lo que cree que hay en la tabla. Esa creencia son las **estadísticas**: un
resumen de cada columna que `ANALYZE` arma con una muestra de filas. Cada `rows=` de un plan sale de ahí.

El curso ya se cruzó con ellas tres veces sin detenerse. En la [Fase 01](01-la-caja-y-el-arnes.md), `Pacientes` decía tener
239.414 filas y tenía 242.427. En la [Fase 08](08-los-dos-extremos-del-mismo-error.md), la estimación de las glucemias altas
no mejoraba con estadísticas extendidas. Y en la Fase 11, MySQL estimó 146.386 filas para un día que tenía unas quinientas.
Esta fase explica las tres, y mide cuándo un error de estimación cuesta milisegundos y cuándo cuesta horas.

---

## 🎯 2. Objetivos de esta fase

1. Leer `pg_stats`: valores más frecuentes, histograma, `n_distinct` y correlación.
2. Comparar filas estimadas contra reales en cada nodo de un plan, y encontrar el nodo donde nace el error.
3. Reconocer la suposición de independencia y corregirla con `CREATE STATISTICS`.
4. Medir el volumen en que el plan cambia de método de acceso.
5. Programar `ANALYZE` donde el automático llega tarde.

---

## 🚫 3. Qué NO entra todavía

- **Los métodos de join por dentro, y los planes de las sentencias preparadas** → [Fase 13](13-el-optimizador-en-tres-motores.md).
- **Fijar un plan con hints** → [Fase 13](13-el-optimizador-en-tres-motores.md).
- **Lo que hace el frontal con la base** → [Fase 14](14-la-base-no-estaba-lenta.md).

---

## 🏚️ 4. El dolor, en la caja

**2020.** El laboratorio se habilita para PCR de COVID-19, y en seis semanas pasa de unos 400 protocolos diarios a 2.600, con
un autoservicio de hisopado en el estacionamiento: la sede `E`, que en la caja aparece el 20 de marzo de 2020. Los informes
que pedía la pandemia se armaban con consultas sobre `ResultadoItem`, y uno de ellos (los pacientes con una PCR repetida
dentro de los catorce días) tardaba segundos en marzo y dejó de terminar en el invierno. Nadie había tocado la consulta, ni
el índice, ni el servidor.

Lo que cambió fueron los datos. El 19 de marzo, el código `COVPCR` no existía en la tabla; las estadísticas que el motor tenía
de ella, tampoco lo conocían. En la caja:

```text
 analyte_code |    min     | count
--------------+------------+--------
 COVPCR       | 2020-03-20 | 152611
```

Es la única determinación que aparece después de 2020. Esta fase reproduce el informe en Postgres, con las estadísticas que
tenía la tabla antes de que llegara.

---

## 🧩 5. Lo que el optimizador cree

### 5.1 `pg_stats`: lo que guarda `ANALYZE`

`ANALYZE` lee una muestra de la tabla (300 filas por cada punto de `default_statistics_target`, que vale 100: 30.000 filas) y
guarda, por columna:

- **`n_distinct`**: cuántos valores distintos cree que hay. Negativo, es una proporción de las filas (−1: todos distintos).
- **`most_common_vals`** y sus frecuencias: los valores que más se repiten, hasta cien.
- **`histogram_bounds`**: cien cortes que dividen el resto de los valores en tramos con la misma cantidad de filas.
- **`correlation`**: cuánto se parece el orden de los valores al orden físico de las filas, de −1 a 1.

Con eso estima. Para `site_code = 'E'` busca `'E'` entre los más frecuentes y usa su frecuencia; para un rango, cuenta cuántos
tramos del histograma cubre. Y para un valor que no está en ninguna de las dos listas, supone que es uno más de los valores
poco frecuentes: el resto de las filas dividido por el resto de los distintos. Un valor que no existía cuando corrió `ANALYZE`
recibe esa estimación mínima.

### 5.2 El histograma de un texto que guarda números

El valor de `staging.result_eav`, el EAV de la [Fase 08](08-los-dos-extremos-del-mismo-error.md), es texto. Su histograma
(`01_text_and_correlation.sql`):

```text
n_distinct | 7972
bounds     | {"< 0,05","0,33","0,63","0,79","0,96",10.1,10.4,"10,7","11,0",113,1159,118,<12.0,122,12.5,"1,28",130,…
```

Está en **orden alfabético**: `113`, `1159`, `118`, `<12.0`, `122`. Para el estimador, el tramo entre `113` y `118` contiene a
`1159`, y `"1,28"` va después de `12.5`. Ninguna estimación de rango sobre este histograma dice algo sobre los números.

Y el problema no es solo del estimador:

| Consulta | Glucemias |
|---|---|
| `value > '126'` sobre el texto | 605.229 |
| `value_numeric > 126` sobre el modelo | 442.426 |

La comparación de texto cuenta como mayores que 126 al `13`, al `2` y al `99`, porque `'9' > '1'`. **El histograma está bien
hecho; lo que está mal es el tipo.** Un número guardado como texto no tiene orden de número en ninguna parte del motor, y el
optimizador hereda el error del modelo.

### 5.3 Columnas que dicen lo mismo

El número de protocolo visible lleva el prefijo de la sede: `E-…` en la sede `E`. Dos columnas, un dato. En una copia de
`Protocolos` (`staging.protocol_stats`), las combinaciones más frecuentes:

```text
 site_code | prefix | count
-----------+--------+--------
 C         | C-     | 599711
 A         | A-     | 166540
 R         | R-     | 161170
 J         | J-     | 152593
 V         | V-     | 145010
 E         | E-     |  80918
 C         | 00     |   9999
 C         | 01     |   9524
```

El estimador calcula cada condición por separado y **multiplica** las selectividades, como si fueran independientes. La sede
`E` es el 6 % de los protocolos; el prefijo `E-`, otro 6 %; el producto, un 0,37 %. Pero la segunda condición no filtra nada
después de la primera:

```text
->  Parallel Seq Scan on protocol_stats  (cost=0.00..18192.58 rows=165 width=0) (actual rows=26972.67 loops=3)
      Filter: (((site_code)::text = 'E'::text) AND ("left"((visible_number)::text, 2) = 'E-'::text))
```

**165 filas estimadas por proceso, 26.973 reales: 163 veces menos.** Las estadísticas extendidas le enseñan la dependencia:

```sql
-- postgres
CREATE STATISTICS staging.protocol_stats_site_prefix_stat (dependencies, mcv)
    ON site_code, (left(visible_number, 2)) FROM staging.protocol_stats;
ANALYZE staging.protocol_stats;
```

`dependencies` guarda cuánto determina una columna a la otra; `mcv`, las combinaciones más frecuentes con su frecuencia
conjunta. Desde Postgres 14 aceptan expresiones, y el prefijo es una. Después del `ANALYZE`, la misma consulta estima
**34.537 por proceso**: un 28 % de más, en lugar de 163 veces de menos.

La suposición de independencia tiene una excepción que Postgres reconoce sola: dos comparaciones sobre **la misma columna**.
Para `ordered_on >= '2015-03-10' AND ordered_on < '2015-03-11'` las junta en un rango y estima 25 por proceso, unas 60 en
total, para 65 reales. MySQL no lo hace (sección 6).

> 🩻 **Esto sí funciona igual** en los dos motores: la estimación sale de una muestra, se guarda por columna, y una condición
> que el motor no puede leer en las estadísticas (una función, un valor nuevo) recibe una suposición fija.

### 5.4 Estimadas contra reales, nodo por nodo

`EXPLAIN (ANALYZE)` pone las dos cifras en cada nodo. El error que importa es **el primero**, de abajo hacia arriba: los nodos de
arriba heredan las filas de los de abajo, y un error de 100 veces en una hoja se convierte en el error de cada join que la usa.
Dos cosas para leerlas bien. En un nodo paralelo, las dos cifras son **por proceso**; con dos *workers*, el total estimado es
la cifra por 2,4, y el real, la cifra por `loops`. Y en el lado interno de un *nested loop*, `rows` es por vuelta: hay que
multiplicar por `loops`.

---

## 🔀 6. El contraste: dónde otro motor cambia la decisión

**MySQL no tiene estadísticas por columna salvo que se las pidan.** Sin índice sobre una columna, estima con fracciones fijas:
un tercio para cada comparación de rango. Para un día de `Protocolos` sin histograma (`04_mysql_histograms.sql`):

```text
-> Filter: ((staging.protocol_hist.Fecha >= TIMESTAMP'2015-03-10 00:00:00') and (staging.protocol_hist.Fecha < TIMESTAMP'2015-03-11 00:00:00'))  (cost=134029 rows=147174)
```

147.174 filas, el 11,1 % de la tabla: un tercio por un tercio. El día tiene 65. `ANALYZE TABLE … UPDATE HISTOGRAM` construye
un histograma (de tipo *equi-height* para la fecha, con 100 tramos; *singleton* para la sede, que tiene seis valores) con una
muestra del 5,9 % de la tabla. Con él, cada mitad del rango se estima por separado:

| Condición | Estimada | Real |
|---|---|---|
| `Fecha >= '2015-03-10'` | 1,15 M | 1.152.979 |
| `Fecha < '2015-03-11'` | 173.087 | 174.708 |
| las dos juntas | **150.478** | **65** |
| `Fecha = '2015-03-10'` | 1.325 | 65 |

**Las dos mitades están cerca y el total está mal**: MySQL las multiplica como si fueran independientes (0,869 × 0,130), aunque
sean dos bordes del mismo rango. La muestra cambia en cada `UPDATE HISTOGRAM`: en otra corrida, la segunda mitad dio 125.248
y las dos juntas 113.381, para el mismo día de 65. La igualdad mejora, pero un histograma de cien tramos sobre treinta años no ve un día. La
decisión que cambia: en MySQL, un histograma ayuda con igualdades y con rangos de un solo lado; un rango de dos lados sobre una
columna sin índice hay que medirlo antes de confiar en él. Si un índice sirve para el rango, MySQL no usa el histograma: cuenta
en el índice (*index dives*), y prefiere esa cuenta. El día de la Fase 11 se estimó con el mismo 11,1 %: la tabla no tenía
histograma, y su índice `(Sede, Fecha)` no servía para contar un rango de fechas sin la sede.

**El histograma de MySQL no se actualiza solo.** Queda como se lo creó hasta el próximo `UPDATE HISTOGRAM`, salvo que se lo
declare con `AUTO UPDATE`, que lo rehace con cada `ANALYZE TABLE` y cuando InnoDB recalcula en segundo plano las estadísticas
persistentes de la tabla. En Postgres,
`ANALYZE` lo dispara el autovacuum; en MySQL, nada, si no se pide.

> 🪞🔒 **Apuesta sin resolver: Oracle.** Hipótesis: con el muestreo dinámico de Oracle (`OPTIMIZER_DYNAMIC_SAMPLING` en 2, el
> valor por defecto) y sin estadísticas extendidas, el filtro por sede y prefijo de la sección 5.3 se estima igual de mal que en
> Postgres, porque el muestreo dinámico solo actúa sobre tablas sin estadísticas; con `DBMS_STATS.CREATE_EXTENDED_STATS` sobre
> el grupo de columnas, la estimación queda dentro de 2 veces. Condiciones: los protocolos de M en una tabla con estadísticas
> recogidas por `DBMS_STATS.GATHER_TABLE_STATS`, y la estimación con `DBMS_XPLAN.DISPLAY_CURSOR` en `sqlplus`
> ([`a03`](a03-clis-de-los-motores.md#️-oracle--sqlplus)). El mecanismo, en la documentación oficial: las estadísticas extendidas
> y el muestreo dinámico (en las referencias). 📝 No publicamos números de Oracle; el porqué está en
> [`a09`](a09-licencias-publicacion-y-riesgo.md).

---

## 🪞 7. Tu instinto dice… y la apuesta

**Tu instinto dice** que una estimación equivocada lleva a un plan peor, y que corregirla lo arregla. La primera mitad suele
ser cierta.

> 🪞 **Apuesta antes de ejecutar** (escrita el 30/09/2026, al diseñar esta fase). *"Sin estadísticas extendidas, la estimación
> del filtro por sede y prefijo se equivoca por al menos 10 veces, y eso cambia el método de join."*
> **Resultado:** **ganada, con una sorpresa.** La estimación se equivoca 163 veces, y el método cambia: sin estadísticas
> extendidas, el join de los protocolos de la sede `E` con `result_eav` es un *nested loop*; con ellas, un *hash join*, en diez
> de diez `ANALYZE` seguidos. Pero el plan de la estimación correcta es **cinco veces más lento**: entre 598 y 945 ms contra
> entre 115 y 252 ms, con la caché caliente.

El *hash join* recorre `result_eav` entera (134.208 bloques, 1.049 MB) para quedarse con 80.918 filas; el *nested loop* hace
80.918 búsquedas en el índice de `lab_order_id`. El optimizador prefirió recorrer la tabla porque esperaba 315.641 filas del
join, y no 80.918. Ese es **el segundo error**, y ninguna estadística extendida lo corrige: en el lado interno del *nested
loop*, el índice estima 60 resultados por protocolo, y cada protocolo de la sede `E` tiene **uno**, la PCR. El promedio de la
tabla es de unos nueve resultados por protocolo, y ni siquiera ese promedio llega al estimador: `n_distinct` de
`lab_order_id`, sacado de una muestra de 30.000 filas, dice 202.393 protocolos distintos donde hay 1,33 millones, y 12,13
millones de filas entre 202.393 dan las 60. La relación entre la sede (en una tabla) y la cantidad de resultados (en otra) es una correlación entre tablas, y
las estadísticas de Postgres son de una sola tabla.

Con la estimación mala, los dos errores se compensaban: 165 protocolos por 60 resultados cada uno se parecía más a la
realidad que 34.537 por 60. **Corregir una estimación puede empeorar el plan**, si el error que queda iba en sentido contrario.
Sobre `result_as_is`, que no tiene índice por protocolo, no hay *nested loop* posible: el join es *hash* con las dos
estimaciones, y lo único que cambia es la agregación (por orden o por *hash*), con el mismo tiempo, entre 1.054 y 1.079 ms.

---

## 💥 8. El punto de rotura

**El precipicio del plan.** `03_plan_cliff.sql` cuenta los resultados de un rango de fechas sobre `staging.result_as_is`, con un
B-tree en `recorded_at`, y barre el ancho del rango desde un día hasta diez años. Para cada ancho mide el plan que elige el
optimizador, y los tres métodos de acceso forzados: el índice, el *bitmap* y la recorrida entera. Mediana de tres ejecuciones,
con la caché caliente:

> 📐 **Medición: el precipicio del plan** · 11,95 M de resultados, 686 MB · `pgvector/pgvector@sha256:2358fcba361e…` · verificado
> el 14/10/2026
>
> | Rango | Elegido | Estimadas | Reales | Índice | *Bitmap* | Entera | Elegido |
> |---|---|---|---|---|---|---|---|
> | 1 día | *bitmap* | 678 | 711 | 0,1 ms | 0,1 ms | 555 ms | 0,1 ms |
> | 1 mes | *bitmap* | 21.014 | 22.115 | 3,0 | 2,6 | 438 | 3,5 |
> | 6 meses | *bitmap* | 125.716 | 127.196 | 29,3 | 27,3 | 410 | 60,0 |
> | 1 año | *bitmap* | 258.460 | 257.309 | 57,3 | 33,5 | 394 | 107,1 |
> | 2 años | *bitmap* | 518.625 | 522.505 | 106,1 | 51,0 | 405 | 61,6 |
> | 4 años | *bitmap* | 1.041.050 | 1.058.595 | 94,8 | 123,6 | 396 | 87,6 |
> | **6 años** | **entera** | 2.000.021 | 2.017.282 | **167,2** | **145,9** | 440 | **492,1** |
> | 10 años | entera | 7.156.319 | 7.210.380 | 615,0 | 515,9 | 594 | 559,3 |

Entre cuatro y seis años de rango, con el doble de filas, el plan elegido pasa de 88 a 492 ms: **5,6 veces más**, por cambiar
de método. Y en ese punto, el método que dejó era tres veces más rápido que el que eligió. Las estimaciones son buenas en todas
las filas (nunca más de un 10 % de error): el precipicio no es de cardinalidad, es del **modelo de costos**. El optimizador
cuenta cada página leída al azar como cuatro veces más cara que una leída en secuencia (`random_page_cost = 4`), que es lo que
cuesta en un disco de los de antes; la tabla entera cabe en la memoria del contenedor, y ahí una página al azar cuesta casi lo
mismo que una en secuencia.

📝 Los milisegundos se mueven entre corridas: en la misma máquina corrían otros contenedores, y en una segunda corrida el
plan elegido a seis años tardó 1.002 ms y el *bitmap* forzado, 314. **Lo que se repitió en las dos** es la forma: el cambio de
método entre los cuatro y los seis años de rango (entre el 9 y el 17 % de la tabla), el salto del plan elegido, y el método
abandonado tres veces más rápido. Mide en tu máquina antes de tomar los números.

El precipicio existe en cualquier optimizador por costos. Lo que lo vuelve peligroso es estar cerca de él sin saberlo: un
informe que filtra un rango que crece con el tiempo lo cruza un día, y se vuelve cinco veces más lento sin que nadie lo toque.

---

## ⚰️ 9. Autopsia: el informe de la pandemia y el `ANALYZE` que nadie programó

**1. La decisión.** *"Apaguemos el autovacuum de la tabla mientras dure la carga."* Una carga masiva de resultados, en marzo,
con el autovacuum compitiendo por el disco. La carga terminó; el autovacuum siguió apagado.

**2. Por qué era razonable.** Durante una carga masiva, el autovacuum compite por el disco y no aporta nada: la tabla todavía no
tiene lecturas que dependan de sus estadísticas. Apagarlo para la carga, y analizar al final, es una práctica documentada.

**3. Qué pasó después.** `02_stale_statistics.sql` arma `staging.result_2020` con enero y febrero de 2020, la analiza con el
autovacuum apagado para la tabla, y después le carga marzo de 2020 a diciembre de 2021. Para las estadísticas, `COVPCR` no
existe:

```text
->  Index Scan using result_2020_analyte_recorded_idx on result_2020 a  (cost=0.43..8.44 rows=1 width=12)
      Index Cond: ((analyte_code)::text = 'COVPCR'::text)
```

**Una fila estimada para 91.475.** El informe simple, las PCR y los positivos por sede, no lo nota: el plan es un *nested loop*
de búsquedas por clave, que para 91.475 filas sigue siendo razonable. Mediana de cinco ejecuciones: **190 ms antes del
`ANALYZE`, 144 ms después** (en otra corrida, 220 y 111). El informe de las PCR repetidas une la tabla consigo misma por paciente, y ahí la fila estimada
se vuelve un *nested loop* cuyo lado interno no es una búsqueda puntual sino **todas las PCR**, una vez por cada PCR:

| Datos | PCR | Con las estadísticas de febrero | Después del `ANALYZE` |
|---|---|---|---|
| marzo y abril de 2020 | 5.303 | 40,9 s | 0,1 s |
| marzo de 2020 a diciembre de 2021 | 91.475 | cancelado a los 300 s | entre 0,14 y 0,7 s |

El trabajo del *nested loop* crece con el cuadrado de las PCR: 91.475 es 17 veces 5.303, y 17² es 297. Extrapolado desde los
40,9 s, **unas 3,4 horas**. Es una extrapolación, no una medición: el curso cortó la consulta a los cinco minutos. Después del
`ANALYZE`, el mismo informe es un *hash join* que tardó entre 0,14 y 0,7 s en seis ejecuciones de tres corridas.

**4. Cuánto cuesta salir.** Un `ANALYZE` de la tabla: un par de segundos. Y volver a prender el autovacuum.

**5. Qué lo habría cambiado.** Un `ANALYZE` explícito al final de cada carga masiva, y un control que avise de tablas con el
autovacuum apagado (`reloptions` en `pg_class`). Y entender el umbral del automático, porque **ni siquiera con el autovacuum
prendido habría llegado a tiempo**: analiza cuando cambia el 10 % de la tabla más 50 filas. Sobre `alameda.result` entera, con
2.762.555 resultados antes de marzo de 2020, eso son 276.306 filas nuevas: el primer `ANALYZE` automático habría corrido el
**5 de agosto de 2020**, después de 17.475 PCR. Cuatro meses y medio de pandemia con un código que, para el optimizador, no
existía. En una tabla grande que recibe un valor nuevo, el umbral por defecto es tarde; se baja por tabla
(`ALTER TABLE … SET (autovacuum_analyze_scale_factor = 0.01)`) o se programa el `ANALYZE`.

**Antes y después, con números:** 40,9 s contra 0,1 s con dos meses de pandemia, y unas 3,4 horas (extrapoladas) contra menos de un
segundo con veintidós.

---

## 📖 10. Traducción

| Concepto | Access / T-SQL | Postgres | MySQL | Oracle |
|---|---|---|---|---|
| recoger estadísticas | `UPDATE STATISTICS` | `ANALYZE` | `ANALYZE TABLE` | `DBMS_STATS.GATHER_TABLE_STATS` |
| histograma de una columna | parte de cada estadística | `pg_stats.histogram_bounds` | `UPDATE HISTOGRAM ON …` | `METHOD_OPT … SIZE n` |
| estadísticas de varias columnas | estadística de varias columnas | `CREATE STATISTICS` | — | `CREATE_EXTENDED_STATS` |
| actualización automática | `AUTO_UPDATE_STATISTICS` | autovacuum (10 % + 50) | estadísticas persistentes de InnoDB; histograma solo con `AUTO UPDATE` | tarea nocturna de estadísticas |
| ver estimadas y reales | plan real | `EXPLAIN (ANALYZE)` | `EXPLAIN ANALYZE` | `DBMS_XPLAN.DISPLAY_CURSOR` con `ALLSTATS LAST` |
| costo de una página al azar | — | `random_page_cost` | — (modelo de costos propio) | `db_file_multiblock_read_count`, estadísticas del sistema |

Hacia la NoSQL Lite: MongoDB no estima con estadísticas; prueba los planes candidatos un rato y se queda con el que devolvió
más rápido, y guarda la decisión en caché hasta que el rendimiento cambia. Es otro modo de equivocarse: el plan que ganó con los
datos de ayer. El diccionario completo está en [`a07`](a07-diccionario-y-glosario.md).

---

## ⚖️ 11. Veredicto honesto: cuándo NO usar esto

**Cuándo no confiar en las estadísticas.** Cuando la columna guarda números como texto: el histograma está en el orden
equivocado y ninguna estadística lo arregla. Cuando dos columnas de la misma tabla dicen lo mismo y no hay estadísticas
extendidas. Cuando la relación está **entre tablas** (la sede en una, la cantidad de resultados en otra): ahí ningún motor de
este curso la ve. Y cuando la tabla recibió algo nuevo después del último `ANALYZE`: un valor que no existía, o un rango de
fechas posterior al histograma.

**Cuándo no corregir una estimación.** Cuando el plan actual es bueno por casualidad: la sección 7 corrigió una estimación y el
plan se volvió cinco veces más lento, porque quedaba otro error en sentido contrario. Antes de agregar estadísticas extendidas,
mide el plan que resulta, no solo la estimación.

**Cuándo fijar el plan en lugar de las estadísticas.** Cuando una consulta crítica está cerca del precipicio y su rango crece
con el tiempo, y cuando el costo de equivocarse es de horas. La [Fase 13](13-el-optimizador-en-tres-motores.md) mide los hints y lo que cuestan; el veredicto de esta
fase es que **fijar un plan es renunciar a que el optimizador se adapte a los datos**, y que se justifica solo con una consulta
que se midió cruzando el precipicio.

**Lo que no se mide aquí:** el costo de `ANALYZE` en una tabla muy grande, y el de subir `default_statistics_target`. Los dos
crecen con la muestra; en la caja M, `ANALYZE` de `result` entera tarda un segundo y medio.

Las cinco preguntas, para lo que enseñó esta fase:

- **Frontera transaccional:** `ANALYZE` no bloquea escrituras y no necesita transacción propia; se puede correr en cualquier
  momento.
- **Consultas conocidas:** las estadísticas extendidas se crean para una consulta medida, como los índices.
- **Unidad de lectura:** la estimación decide si la unidad es la página (recorrida) o la fila (índice).
- **Saltos:** cada join multiplica el error del nodo de abajo.
- **Exactitud o parecido:** la estimación es parecido por definición; lo que se mide es cuánto.

---

## ⚠️ 12. Errores comunes y diagnóstico

- **`rows=1` en un nodo que devuelve miles.** 🩺 Un valor que no está en las estadísticas: `SELECT last_analyze,
  last_autoanalyze FROM pg_stat_user_tables` y `ANALYZE`.
- **`canceling statement due to statement timeout` en un informe que antes andaba.** 🩺 Compara estimadas contra reales en un
  `EXPLAIN (ANALYZE)` con un rango más chico: el nodo con el error más grande es el origen.
- **Una estimación que no mejora con `CREATE STATISTICS`.** 🩺 Las extendidas sirven para igualdades y combinaciones frecuentes;
  no para un `>` sobre un número continuo, ni para columnas de tablas distintas.
- **Un histograma de MySQL que no cambia la estimación.** 🩺 La columna tiene índice (MySQL cuenta en el índice), o el rango tiene
  dos lados (los multiplica).
- **Un plan que cambia sin que nadie toque nada.** 🩺 Un rango que crece cerca del precipicio, o un `ANALYZE` automático que acaba
  de correr: `pg_stat_user_tables.last_autoanalyze`.
- **Una tabla con el autovacuum apagado.** 🩺 `SELECT relname, reloptions FROM pg_class WHERE reloptions::text LIKE
  '%autovacuum_enabled=false%'`.

---

## 📋 13. Checklist de validación

```text
[ ] value > '126' cuenta 605.229 glucemias, y value_numeric > 126, 442.426
[ ] sede E y prefijo E-: 165 estimadas por proceso sin estadísticas extendidas, unas 34.500 con ellas, 26.973 reales
[ ] el join con result_eav pasa de nested loop a hash join con las estadísticas extendidas
[ ] COVPCR estima 1 fila con las estadísticas de febrero, y el informe de las repetidas no termina en 300 s
[ ] después del ANALYZE, el mismo informe tarda menos de un segundo
[ ] el barrido cambia a recorrida entera entre 4 y 6 años de rango
[ ] MySQL estima ~150.000 filas para el día con histograma, y 65 son las reales
```

---

## 🧪 14. Ejercicios (24)

## 🟢 Fácil — leer las estadísticas (1–6)

### 🟢 Ejercicio 1 — `pg_stats` de una columna

Lee `n_distinct`, los cinco valores más frecuentes y la correlación de `alameda.lab_order.site_code`.

**Objetivo:** seis valores, sus frecuencias, y cuánto suman.

[Solución](soluciones/12-estadisticas-y-cardinalidad.md#ejercicio-1)

### 🟢 Ejercicio 2 — Los 239.414 de la Fase 01

Explica de dónde salió el número de filas de `Pacientes` que la Fase 01 leyó en las estadísticas de MySQL.

**Objetivo:** la tabla de MySQL de donde sale, y por qué no es exacto.

[Solución](soluciones/12-estadisticas-y-cardinalidad.md#ejercicio-2)

### 🟢 Ejercicio 3 — El histograma alfabético

Lee el histograma de `value` en `staging.result_eav` y encuentra tres cortes fuera del orden numérico.

**Objetivo:** los tres cortes, y por qué están ahí.

[Solución](soluciones/12-estadisticas-y-cardinalidad.md#ejercicio-3)

### 🟢 Ejercicio 4 — Mayor que 126

Cuenta las glucemias mayores que 126 sobre el texto y sobre el número.

**Objetivo:** 605.229 contra 442.426.

[Solución](soluciones/12-estadisticas-y-cardinalidad.md#ejercicio-4)

### 🟢 Ejercicio 5 — Por proceso

En el plan del filtro por sede y prefijo, calcula el total estimado y el total real a partir de las cifras por proceso.

**Objetivo:** unas 400 estimadas y 80.918 reales.

[Solución](soluciones/12-estadisticas-y-cardinalidad.md#ejercicio-5)

### 🟢 Ejercicio 6 — El mismo rango en Postgres

Estima un día de `ordered_on` en `staging.protocol_stats`.

**Objetivo:** unas 60 filas estimadas para 65.

[Solución](soluciones/12-estadisticas-y-cardinalidad.md#ejercicio-6)

## 🟡 Intermedio — dónde nace el error (7–12)

### 🟡 Ejercicio 7 — Sede y prefijo, sin y con

Corre la sección 2 de `01_text_and_correlation.sql`.

**Objetivo:** 165 contra unas 34.500 estimadas por proceso, para 26.973.

[Solución](soluciones/12-estadisticas-y-cardinalidad.md#ejercicio-7)

### 🟡 Ejercicio 8 — Lo que guardó `CREATE STATISTICS`

Lee `pg_stats_ext` para el objeto de estadísticas de la sección 5.3.

**Objetivo:** el grado de dependencia y la frecuencia de `('E', 'E-')`.

[Solución](soluciones/12-estadisticas-y-cardinalidad.md#ejercicio-8)

### 🟡 Ejercicio 9 — Solo `dependencies`

Crea el objeto de estadísticas con `dependencies` y sin `mcv`, y repite la estimación.

**Objetivo:** la estimación nueva, y qué parte del arreglo hace cada tipo.

[Solución](soluciones/12-estadisticas-y-cardinalidad.md#ejercicio-9)

### 🟡 Ejercicio 10 — Un valor que no existía

Con las estadísticas de febrero de `02_stale_statistics.sql`, estima las filas de `COVPCR` y las de `GLU`.

**Objetivo:** 1 contra unas 91.475 reales, y una estimación de `GLU` cercana a la real.

[Solución](soluciones/12-estadisticas-y-cardinalidad.md#ejercicio-10)

### 🟡 Ejercicio 11 — El informe que no lo nota

Mide el informe simple de PCR por sede antes y después del `ANALYZE`.

**Objetivo:** unos 190 contra unos 145 ms, y por qué el error de 91.475 veces cuesta tan poco.

[Solución](soluciones/12-estadisticas-y-cardinalidad.md#ejercicio-11)

### 🟡 Ejercicio 12 — Cuándo habría llegado el automático

Calcula, para `alameda.result` entera, la fecha en que el autovacuum habría analizado la tabla después del 1 de marzo de 2020.

**Objetivo:** el 5 de agosto de 2020, y cuántas PCR antes.

[Solución](soluciones/12-estadisticas-y-cardinalidad.md#ejercicio-12)

## 🟠 Difícil — cuándo cambia el plan (13–18)

### 🟠 Ejercicio 13 — El informe de las repetidas, chico

Cambia `02_stale_statistics.sql` para que cargue solo hasta abril de 2020, y mide el informe de las repetidas.

**Objetivo:** unos 41 s contra unos 0,1 s.

[Solución](soluciones/12-estadisticas-y-cardinalidad.md#ejercicio-13)

### 🟠 Ejercicio 14 — El informe de las repetidas, entero

Corre `02_stale_statistics.sql` tal como está.

**Objetivo:** el corte a los 300 s, menos de un segundo después, y la extrapolación.

[Solución](soluciones/12-estadisticas-y-cardinalidad.md#ejercicio-14)

### 🟠 Ejercicio 15 — Diez `ANALYZE` seguidos

Corre diez veces `ANALYZE` sobre `staging.protocol_stats` con las estadísticas extendidas, y anota el método del join con
`result_eav` cada vez.

**Objetivo:** cuántas veces sale *hash join*, y cuánto varía la estimación.

[Solución](soluciones/12-estadisticas-y-cardinalidad.md#ejercicio-15)

### 🟠 Ejercicio 16 — Los dos joins, forzados

Mide el join de la sección 7 forzando el *nested loop* y forzando el *hash join*, con la caché caliente.

**Objetivo:** cuatro ejecuciones de cada uno, y la diferencia.

[Solución](soluciones/12-estadisticas-y-cardinalidad.md#ejercicio-16)

### 🟠 Ejercicio 17 — El segundo error

En el plan del *nested loop* de la sección 7, encuentra la estimación del lado interno y compárala con lo real.

**Objetivo:** 60 contra 1 por vuelta, y de dónde sale el 60.

[Solución](soluciones/12-estadisticas-y-cardinalidad.md#ejercicio-17)

### 🟠 Ejercicio 18 — El histograma de MySQL

Corre `04_mysql_histograms.sql`.

**Objetivo:** las cuatro estimaciones de la tabla de la sección 6, y la multiplicación que explica la tercera.

[Solución](soluciones/12-estadisticas-y-cardinalidad.md#ejercicio-18)

## 🔴 Muy difícil — decidir (19–24)

### 🔴 Ejercicio 19 — El precipicio en tu máquina

Corre `03_plan_cliff.sql` dos veces.

**Objetivo:** en qué rango cambia el método en cada corrida, y cuánto se mueven los milisegundos.

[Solución](soluciones/12-estadisticas-y-cardinalidad.md#ejercicio-19)

### 🔴 Ejercicio 20 — Mover el precipicio

Repite el barrido con `random_page_cost = 1.1` en la sesión.

**Objetivo:** el rango nuevo del cambio, y si el plan elegido queda más cerca del más rápido.

[Solución](soluciones/12-estadisticas-y-cardinalidad.md#ejercicio-20)

### 🔴 Ejercicio 21 — El umbral de `result`

Propón el `autovacuum_analyze_scale_factor` de `alameda.result` para que un código nuevo se analice dentro de la semana en que
aparece.

**Objetivo:** el valor, con la cuenta de filas por semana de la caja M.

[Solución](soluciones/12-estadisticas-y-cardinalidad.md#ejercicio-21)

### 🔴 Ejercicio 22 — La glucemia de la Fase 08

La Fase 08 dejó una estimación de glucemias altas que las estadísticas extendidas no mejoraban. Explica por qué con lo que
viste en esta fase, y propón un cambio en el modelo que la arregle.

**Objetivo:** el cambio, y la estimación antes y después.

[Solución](soluciones/12-estadisticas-y-cardinalidad.md#ejercicio-22)

### 🔴 Ejercicio 23 — Oracle

Resuelve en tu máquina la apuesta 🪞🔒 de la sección 6.

**Objetivo:** explicar el resultado con la documentación de Oracle, sin publicar ningún número.

[Solución](soluciones/12-estadisticas-y-cardinalidad.md#ejercicio-23)

### 🔴 Ejercicio 24 — ¿Estadísticas extendidas o no?

Decide si `staging.protocol_stats_site_prefix_stat` se queda, sabiendo lo que hizo con el join de la sección 7.

**Objetivo:** la decisión, con las consultas conocidas que la ganan y la que la pierde.

[Solución](soluciones/12-estadisticas-y-cardinalidad.md#ejercicio-24)

---

## 📚 15. Referencias

**Documentación oficial**

- **Estadísticas que usa el planificador** — https://www.postgresql.org/docs/18/planner-stats.html — `pg_stats`, las
  estadísticas extendidas y sus tres tipos.
- **Cómo estima filas el planificador** — https://www.postgresql.org/docs/18/row-estimation-examples.html — los cálculos de la
  sección 5.1, con ejemplos.
- **`CREATE STATISTICS`** — https://www.postgresql.org/docs/18/sql-createstatistics.html
- **El autovacuum y su umbral de `ANALYZE`** — https://www.postgresql.org/docs/18/routine-vacuuming.html#VACUUM-FOR-STATISTICS
- **Histogramas en MySQL 9.7** — https://dev.mysql.com/doc/refman/9.7/en/optimizer-statistics.html — tipos, muestreo y
  `AUTO UPDATE`.
- **Estadísticas extendidas en Oracle** — https://docs.oracle.com/en/database/oracle/oracle-database/23/tgsql/managing-extended-statistics.html
- **Muestreo dinámico en Oracle** — https://docs.oracle.com/en/database/oracle/oracle-database/26/tgsql/options-for-optimizer-statistics-gathering.html

**Papers y libros**

- **Viktor Leis et al., "How Good Are Query Optimizers, Really?", VLDB 2015** — la estimación de cardinalidad como la fuente
  principal de planes malos, medida con datos reales; su conclusión sobre la suposición de independencia es la de la sección 5.3.
- **Markus Winand, *SQL Performance Explained*** — https://use-the-index-luke.com — el capítulo sobre el optimizador y las
  estadísticas.

**Orden de lectura sugerido:** la página de estimación de filas antes de la sección 5.1; Leis et al. antes de la sección 7.

> ⚠️ Las URL y sus contenidos cambian. Se consultaron el 14/10/2026.

---

## 🏁 16. Resultado de la fase

```text
LO QUE CREE · Postgres
  texto con números                   value > '126': 605.229 · como número: 442.426
  sede y prefijo                      165 estimadas por proceso · 34.537 con CREATE STATISTICS · 26.973 reales
  el join con result_eav              nested loop → hash join · 5 veces más lento con la estimación correcta
LO QUE CREE · MySQL
  un día, con histograma              150.478 estimadas · 65 reales (multiplica las dos mitades)
LA ROTURA
  el precipicio                       entre 4 y 6 años de rango · 88 → 492 ms · el método abandonado, 3 veces más rápido
LA AUTOPSIA
  COVPCR con estadísticas de febrero  1 fila estimada, 91.475 reales
  el informe de las repetidas         40,9 s → 0,1 s (dos meses) · ~3,4 h extrapoladas → < 1 s (veintidós)
  el automático, con 2,76 M de filas  el 5 de agosto de 2020, 17.475 PCR después
```

> **La señal de que quedó bien:** *"Puedo encontrar en un plan el nodo donde nace el error de estimación, decir si cambia el
> método o no, y saber cuándo el `ANALYZE` automático llega tarde para mis tablas."*

> 🏷️ **No cierres la fase sin el tag.** Con el checklist en verde y `git status` limpio:
>
> ```bash
> git tag -a fase-12-estadisticas-y-cardinalidad -m "F12 cerrada: histograma de texto, sede y prefijo con estadísticas extendidas, el precipicio del plan y el informe de la pandemia"
> ```
>
> Commits de la fase con prefijo `f12:`, los de ejercicio `f12 ej24: …`.
