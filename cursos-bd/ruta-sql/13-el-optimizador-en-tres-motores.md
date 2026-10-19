# 🧠 Fase 13 — El optimizador en tres motores: métodos de join, planes reutilizados y hints

> **Curso:** Ruta SQL · Fase 13 de 27 · Bloque II — La física y el tuning · **10 h**
> **Motores:** PostgreSQL `pgvector/pgvector@sha256:2358fcba361e…` · contraste MySQL `mysql@sha256:e2bde46db656…` · —
> **Entorno de ejecución:** SQL y Python
> **Perfil de volumen:** M, con el modelo de `uv run lab load --profile m --model`
> **El dolor de Alameda:** la consulta por sede que anda bien en los centros de extracción y se arrastra en el central (historia §3, 2009 en adelante)
> **Depende de:** Fase 12 · **Habilita:** Fase 14
> **Apéndices de apoyo:** a03, a04, a07, a08
> **Fecha de verificación ejecutada:** 14/10/2026
> **Objetivo:** medir los tres métodos de join sobre la misma consulta, ver cuándo un plan se reutiliza para un valor
> que no le corresponde, y decidir cuándo fijar un plan con un hint y cuándo no.

---

## 🧭 1. Dónde estamos

La [Fase 12](12-estadisticas-y-cardinalidad.md) midió lo que el optimizador cree. Esta mide lo que hace con eso: el
**método** con que une dos tablas, y cuándo **reutiliza** una decisión para un valor distinto del que la motivó. Un plan
reutilizado ahorra el tiempo de planificar; si se reutiliza para el valor equivocado, cobra en ejecución lo que ahorró en
planificación, multiplicado.

El dolor no es nuevo en Alameda. Desde 2009 hay un laboratorio central y cuatro centros de extracción, y el central concentra
casi la mitad de los protocolos. Una consulta por sede que se escribió y se probó en un centro chico no tiene por qué
comportarse igual en el central, ni al revés.

---

## 🎯 2. Objetivos de esta fase

1. Reconocer en un plan los tres métodos de join y medir cada uno forzado sobre la misma consulta.
2. Explicar cuándo Postgres pasa de planes personalizados a un plan genérico, y medir lo que cuesta.
3. Ver cómo llega una aplicación en Python al plan genérico sin escribir `PREPARE`.
4. Comparar con MySQL, que no reutiliza planes, y con lo que la documentación de Oracle describe.
5. Decidir cuándo un hint se justifica y cuándo es un problema que espera.

---

## 🚫 3. Qué NO entra todavía

- **Lo que hace el frontal con la base (N+1, paginación)** → [Fase 14](14-la-base-no-estaba-lenta.md).
- **Los bloqueos que toma una consulta** → [Fase 18](18-bloqueos-deadlocks-y-ddl.md).
- **El tuning de la memoria del servidor (`work_mem`, `shared_buffers`)**: operación, fuera del curso.

---

## 🏚️ 4. El dolor, en la caja

Las sedes no son parejas. Septiembre de 2026 en `staging.order_site`, una copia de `alameda.lab_order` con un índice
`(site_code, ordered_on)`:

```text
 site_code | count
-----------+-------
 A         |  2823
 C         | 10255
 J         |  2674
 R         |  2784
 V         |  2626
```

El central tiene casi cuatro veces los protocolos de cada centro, y la sede `E`, el autoservicio de la pandemia, no tiene
ninguno: cerró en 2022. La consulta que guía esta fase cuenta los resultados del mes por determinación para una sede:

```sql
-- postgres
SELECT r.analyte_code, count(*)
FROM staging.order_site o JOIN alameda.result r USING (lab_order_id)
WHERE o.site_code = $1 AND o.ordered_on >= '2026-09-01'
GROUP BY r.analyte_code;
```

Es el tipo de consulta que una aplicación corre cientos de veces por día con distintos valores, y la que el motor más
quiere reutilizar.

---

## 🧩 5. Lo que hace el optimizador

### 5.1 Tres maneras de unir dos tablas

**Nested loop**: por cada fila del lado externo, busca sus pares en el interno, idealmente por un índice. Barato con pocas
filas externas; su costo crece con ellas. **Hash join**: lee el lado chico, arma una tabla de hash en memoria, y recorre el
lado grande una vez buscando en ella. Su costo es el de recorrer el lado grande entero, con una fila o con un millón.
**Merge join**: ordena los dos lados por la clave y los recorre juntos. Gana si los dos ya vienen ordenados.

`02_join_methods.sql` corre la consulta con cada método, forzado apagando los otros dos (`enable_hashjoin`,
`enable_nestloop`, `enable_mergejoin` en la sesión), después de una ejecución para calentar:

> 📐 **Medición: tres métodos de join sobre la misma consulta** · septiembre de 2026 · `pgvector/pgvector@sha256:2358fcba361e…` ·
> verificado el 14/10/2026
>
> | Sede | Método | Bloques | Tiempo | ¿Elegido? |
> |---|---|---|---|---|
> | central (10.255) | *nested loop* | 41.953 | 35 ms | |
> | central | *hash join* | 87.953 | 265 ms (mediana de cinco) | ✅ |
> | central | *merge join* | 1.269.854 | 986 ms | |
> | centro V (2.626) | *nested loop* | 10.865 | 22 ms (mediana de cinco) | ✅ |
> | centro V | *hash join* | 87.927 | 936 ms | |
> | centro V | *merge join* | 1.269.802 | 980 ms | |

El *hash join* lee siempre lo mismo, unos 88.000 bloques: es `alameda.result` entera. El *nested loop* lee en proporción a los
protocolos de la sede. El *merge join* es el peor en los dos casos: recorre el índice de `lab_order_id` de `result` entero
para ir en orden, un millón de bloques.

Y en el central, **el optimizador eligió el *hash join*, que tarda 7,6 veces lo que el *nested loop***. Es el precipicio de la
Fase 12 otra vez: el modelo de costos cuenta cada página leída al azar como cuatro secuenciales, y los resultados del
central caben en memoria. Con `random_page_cost = 1.1` en la sesión, el plan elegido para el central es el *nested loop*.

Con dos tablas, la otra decisión del optimizador, **el orden de los joins**, es casi trivial: cuál va afuera. Con más tablas, el
número de órdenes posibles crece como un factorial, y Postgres los explora todos solo hasta cierto tamaño:
`join_collapse_limit` (8 por defecto) limita cuántas tablas reordena juntas, y desde `geqo_threshold` (12) usa una búsqueda
genética que no garantiza el mejor orden. Un error de estimación en la primera tabla elige el orden de todas las demás; es la
multiplicación de errores de la Fase 12, ahora en la forma del plan.

### 5.2 Planes personalizados y el plan genérico

Una sentencia preparada (`PREPARE`, o el protocolo extendido de un *driver*) se planifica con el valor de cada parámetro
las primeras cinco veces: son **planes personalizados**. Desde la sexta ejecución, Postgres arma también un **plan
genérico**, sin mirar los valores, y lo compara con el promedio de costo de los cinco personalizados; si el genérico no es
más caro, lo usa desde ahí en adelante, y deja de planificar. El genérico estima los parámetros como un valor promedio: para
`site_code = $1` con seis sedes, un sexto de la tabla.

`01_generic_plans.sql` corre la consulta preparada en dos sesiones, que solo difieren en qué sede consulta primero:

| Sesión | Primeras cinco | Sexta | Planes genéricos usados | Personalizados |
|---|---|---|---|---|
| empieza en los centros | V, A, R, J, V | central | 0 | 6 |
| empieza en el central | C ×5 | centro V | 1 | 5 |

Con los centros chicos primero, el promedio de los personalizados es barato (*nested loop*) y el genérico (*hash join*,
para el sexto de la tabla) es más caro: Postgres sigue planificando cada vez. Con el central primero, el promedio de los
personalizados es el de un *hash join*, y el genérico cuesta lo mismo o menos: se queda con él. **Qué plan usa la sede V
depende de qué sede consultó primero en esa conexión.**

El genérico no siempre pierde. Con la fecha también como parámetro (el informe del central, mes por mes), el genérico estima un
sexto de la tabla por un rango de fechas desconocido, unas 1.100 filas, y elige el *nested loop*. Sus cinco personalizados para el
central eran *hash join*, más caros, y Postgres se queda con el genérico: **el central recibe el método de un centro chico**, que
es la dirección que esperaba la apuesta de la sección 7. Y aquí acierta: 22 ms contra 244 del personalizado. Dos errores, el del
modelo de costos y el del genérico, se cancelaron. Un plan genérico no es un plan peor; es un plan que no miró el valor.

### 5.3 La aplicación no escribe `PREPARE`

Psycopg 3, el *driver* de Python que usa el curso, prepara en el servidor cualquier consulta que se ejecutó cinco veces en
la misma conexión (`prepare_threshold = 5`). `psycopg_prepare.py` corre la consulta diez veces para el central y después
para la sede V:

```text
prepare_threshold = 5
 5 C   289.0 ms  preparadas=0 genéricos=0 personalizados=0
 6 C   300.7 ms  preparadas=1 genéricos=0 personalizados=1
10 C   263.6 ms  preparadas=1 genéricos=0 personalizados=5
11 V   265.3 ms  preparadas=1 genéricos=1 personalizados=5
12 V   265.8 ms  preparadas=1 genéricos=2 personalizados=5
```

Cinco ejecuciones sin preparar, cinco preparadas con planes personalizados, y **la undécima ya es genérica**. La sede V tarda
265 ms donde su plan personalizado tardaría 22. Nadie en el código pidió un plan genérico: lo pidieron un umbral del *driver*
y otro del motor, uno detrás del otro. Un *pool* de conexiones lo agrava: la conexión que usó el central a las siete de la
mañana atiende al centro V a las diez.

> 🩻 **Esto sí funciona igual** en los tres motores: los mismos tres métodos de join, el mismo criterio (el costo
> estimado), y la misma tensión entre planificar cada vez y reutilizar.

---

## 🔀 6. El contraste: dónde otro motor cambia la decisión

**MySQL no guarda planes.** Una sentencia preparada ahorra el análisis del texto, pero se optimiza de nuevo en cada
`EXECUTE`, con el valor del parámetro. `EXPLAIN` se puede preparar, y así se ve (`03_mysql_prepared.sql`):

```text
-> Covering index range scan on protocolos_en_orden using protocolos_en_orden_sede_fecha_idx over (Sede = 'C' AND …)  (cost=3823 rows=18892)
-> Covering index range scan on protocolos_en_orden using protocolos_en_orden_sede_fecha_idx over (Sede = 'V' AND …)  (cost=532 rows=2626)
-> Covering index range scan on protocolos_en_orden using protocolos_en_orden_sede_fecha_idx over (Sede = 'E' AND …)  (cost=1.21 rows=1)
```

Una estimación por valor, contada en el índice. El problema de esta fase no existe en MySQL; a cambio, cada ejecución paga
la optimización, y el plan de una consulta frecuente puede cambiar entre dos ejecuciones seguidas si cambian las
estadísticas. La decisión que cambia: en MySQL se fija un plan con hints, porque no hay otro mecanismo; en Postgres, primero
se decide si el plan se reutiliza.

**Oracle y SQL Server fijan planes enteros**, no solo una decisión: Oracle con las *SQL plan baselines*, que guardan los planes
aceptados de una consulta y solo dejan usar uno nuevo después de verificarlo; SQL Server con el Query Store, que guarda el
historial de planes de cada consulta y permite forzar uno. Las dos herramientas tienen lo que le faltó al hint de la sección 9:
saben qué plan fijaron, cuándo, y si dejó de servir. Ninguna de las dos se mide aquí.

**Los hints de MySQL** son de dos familias. Las *index hints* (`FORCE INDEX`, `USE INDEX`, `IGNORE INDEX`) van después del
nombre de la tabla. Los *optimizer hints* van en un comentario después del `SELECT` (`/*+ INDEX(p idx) */`, `JOIN_ORDER`,
`NO_INDEX`, `BNL`) y abarcan más decisiones. Las dos fallan distinto (sección 8).

> 🪞🔒 **Apuesta sin resolver: Oracle.** Hipótesis: con la consulta por sede preparada con una variable de enlace, Oracle mira
> el valor de la primera ejecución (*bind peeking*) y arma el plan del central; la ejecución para la sede V reutiliza ese plan, y
> después de unas pocas ejecuciones con mucho más trabajo del esperado, el *adaptive cursor sharing* marca el cursor como
> sensible a los valores y crea un segundo plan para los centros chicos. Condiciones: los protocolos de M con un índice
> `(site_code, ordered_on)`, histogramas recogidos sobre `site_code`, y `V$SQL.IS_BIND_SENSITIVE`, `IS_BIND_AWARE` y
> `CHILD_NUMBER` consultados entre ejecuciones en `sqlplus` ([`a03`](a03-clis-de-los-motores.md#️-oracle--sqlplus)). El
> mecanismo, en la documentación oficial: *adaptive cursor sharing* (en las referencias). 📝 No publicamos números de Oracle; el
> porqué está en [`a09`](a09-licencias-publicacion-y-riesgo.md).

---

## 🪞 7. Tu instinto dice… y la apuesta

**Tu instinto dice** que un plan reutilizado favorece al caso común, y que el caso grande, el central, es el que sufre cuando
le toca un plan pensado para otro.

> 🪞 **Apuesta antes de ejecutar** (escrita el 30/09/2026, al diseñar esta fase). *"A partir de la sexta ejecución, el plan
> genérico elige para el laboratorio central el mismo método que para un centro chico, y lee al menos 10 veces más."*
> **Resultado:** **perdida, al revés y por poco.** Si la sesión empieza en los centros chicos, el plan genérico nunca se usa:
> el central recibe su propio plan personalizado. Si empieza en el central, el genérico se usa, y es **el centro chico** el que
> recibe el método del central: un *hash join* que lee 87.945 bloques donde su plan personalizado leía 10.865. **8,1 veces**
> más bloques, no 10; en tiempo, 11 veces (242 contra 22 ms, mediana de cinco).

La apuesta suponía que el genérico se parece al caso común. Se parece al **promedio**, y Postgres solo lo acepta si no es más
caro que lo que ya vio. Un genérico barato no puede reemplazar a planes caros sin que nadie lo note; uno caro reemplaza a planes
caros sin culpa, y castiga al primer valor barato que llega. Y la parte del central tampoco salió como se esperaba: su plan
personalizado ya era el equivocado (sección 5.1). La dirección de la apuesta sí aparece con la fecha como parámetro (sección 5.2),
y ahí el central lee menos, no diez veces más.

---

## 💥 8. El punto de rotura

**El cambio a plan genérico, con la línea del plan que cambió.** La sede V con su plan personalizado:

```text
->  Nested Loop  (cost=35.39..147027.92 rows=11815 width=3) (actual rows=14022.00 loops=2)
      ->  Index Scan using result_lab_order_id_idx on result r  (cost=0.43..109.38 rows=39 width=7) (actual rows=10.68 loops=2626)
Execution Time: 23.858 ms
```

La misma sede, la misma consulta, en la sexta ejecución de la sesión que empezó en el central:

```text
->  Parallel Hash Join  (cost=6653.32..158252.87 rows=13121 width=3) (actual rows=9348.00 loops=3)
      ->  Parallel Seq Scan on result r  (cost=0.00..138329.89 rows=5055089 width=7) (actual rows=4044101.00 loops=3)
      ->  Bitmap Index Scan on order_site_site_ordered_idx  (cost=0.00..50.89 rows=3446 width=0) (actual rows=2626.00 loops=1)
            Index Cond: ((site_code = $1) AND (ordered_on >= '2026-09-01'::date))
```

La línea que lo delata es `site_code = $1`: un plan personalizado muestra el valor; el genérico, el parámetro. Y la estimación
de 3.446 filas no es la de la sede V ni la del central: es la de una sede promedio. `pg_prepared_statements` cuenta los dos
tipos de plan por sentencia (`generic_plans`, `custom_plans`), y es la primera consulta cuando una sentencia preparada se
vuelve lenta "sin razón".

Las salidas, en orden de alcance: `SET plan_cache_mode = force_custom_plan` para la sesión o el rol que corre esta consulta
(planifica siempre, cuesta unas décimas de milisegundo por ejecución), `prepare_threshold = None` en psycopg para esa conexión
(no prepara nunca), o arreglar el plan del central, que es el que contagia: con el modelo de costos ajustado, los dos son
*nested loop* y el genérico se vuelve inofensivo.

---

## ⚰️ 9. Autopsia: el hint que sobrevivió a la sede que cerró

**1. La decisión.** *"Que la lista de últimos protocolos use el índice por fecha."* La pantalla de cada sede muestra sus últimos
50 protocolos, y en 2012 el único índice útil era el de la fecha. El motor a veces elegía otro camino, y un hint de índice lo
fijó. Años después alguien agregó un índice `(Sede, Fecha)`, que es el correcto, y el hint siguió mandando.

**2. Por qué era razonable.** Un hint arregla hoy, en una línea, un plan que el optimizador elige mal. Funcionó durante una
década: para una sede activa, recorrer el índice por fecha hacia atrás encuentra 50 protocolos de esa sede enseguida.

**3. Qué pasó después.** La sede `E` cerró en 2022. Para encontrar sus últimos 50 protocolos, el índice por fecha hay que
recorrerlo desde octubre de 2026 hasta 2021. En MySQL (`04_the_hint.sql`, sobre una copia de `Protocolos` con los dos
índices):

| Sede | Con el hint | Sin el hint (índice `(Sede, Fecha)`) |
|---|---|---|
| V | 367 entradas leídas, 0,5 ms | 50 entradas, 1,1 ms |
| E | **691.136 entradas, 619 ms** | 50 entradas, 1,1 ms |

Con el hint, la sede cerrada lee 13.800 veces más entradas que las que muestra. El optimizador sin hint usa el índice compuesto y
encuentra las 50 en un salto, para cualquier sede. El hint no se equivocó en 2012; se equivocó cuando los datos cambiaron y él no.

Y un hint puede romperse de dos maneras distintas cuando el índice que nombra deja de existir:

```text
ERROR 1176 (42000) at line 36: Key 'protocol_hint_fecha_idx' doesn't exist in table 'protocol_hint'
Warning	3128	Unresolved name `p`@`select#1` `protocol_hint_gone_idx` for INDEX hint
```

`FORCE INDEX` hace fallar la consulta; el *optimizer hint* deja un aviso y la consulta corre con el plan que el optimizador
quiera. Ninguna de las dos le avisa a nadie que el hint quedó viejo mientras el índice siga existiendo.

**4. Cuánto cuesta salir.** Borrar el hint: una línea. Encontrarlo: buscar `FORCE INDEX`, `USE INDEX` y `/*+` en todo el código
que manda SQL, y medir cada uno sin él.

**5. Qué lo habría cambiado.** Un hint con fecha y con la medición que lo justificó, en un comentario al lado, y una revisión
cuando cambian los índices de la tabla. Y antes del hint, la pregunta de por qué el optimizador elegía mal: en 2012 faltaba el
índice compuesto, que es lo que hacía falta. Sin ese índice, el hint no era el único culpable posible: la misma consulta en
Postgres, sobre `staging.order_site` con solo el índice por fecha, comete sola el error del hint. Recorre el índice hacia atrás y
descarta 691.064 protocolos en 63 ms, porque cree que la sede `E` está repartida en el tiempo. Con el índice compuesto lee seis
bloques. El índice correcto arregla el plan para cualquier sede; el hint fija el plan para las sedes que había.

**Antes y después, con números:** 619 ms y 691.136 entradas para 50 protocolos con el hint, contra 1,1 ms y 50 entradas sin él.

---

## 📖 10. Traducción

| Concepto | Access / T-SQL | Postgres | MySQL | Oracle |
|---|---|---|---|---|
| ver el plan con lo real | plan real (`SET STATISTICS XML`) | `EXPLAIN (ANALYZE, BUFFERS)` | `EXPLAIN ANALYZE` | `DBMS_XPLAN.DISPLAY_CURSOR` |
| sentencia preparada | `sp_prepare`, parametrización | `PREPARE` / protocolo extendido | `PREPARE` (sin plan guardado) | cursor compartido |
| plan genérico | plan en caché por parámetros (*parameter sniffing*) | plan genérico desde la sexta ejecución | — | *bind peeking* y *adaptive cursor sharing* |
| planificar siempre | `OPTION (RECOMPILE)` | `plan_cache_mode = force_custom_plan` | (siempre) | — |
| forzar un índice | `WITH (INDEX(…))` | — (`pg_hint_plan`) | `FORCE INDEX`, `/*+ INDEX */` | `/*+ INDEX */` |
| forzar un método de join | `OPTION (LOOP JOIN)` | `enable_*` en la sesión, `pg_hint_plan` | `/*+ BNL */`, `/*+ NO_BNL */` | `/*+ USE_NL */`, `/*+ USE_HASH */` |
| fijar un plan entero | *plan guides*, Query Store | — | — | *SQL plan baselines* |

Hacia la NoSQL Lite: el caché de planes de MongoDB elige un plan por la forma de la consulta, no por sus valores, y lo
reutiliza hasta que rinde mucho peor que cuando lo eligió. Es el plan genérico con otro nombre. El diccionario completo está en
[`a07`](a07-diccionario-y-glosario.md).

---

## ⚖️ 11. Veredicto honesto: cuándo NO usar esto

**Cuándo no usar un hint.** Cuando el problema es una estimación mala o un parámetro del modelo de costos: el hint arregla una
consulta y deja el error para todas las demás. El *nested loop* del central se arregla igual con `random_page_cost = 1.1`, y eso
arregla también el resto. Cuando el plan depende de un rango que crece: `05_fixed_plan_over_time.sql` fija el *nested loop* para
la consulta del central y la corre desde distintas fechas:

| Desde | Protocolos del central | *Nested loop* fijado | *Hash join* |
|---|---|---|---|
| septiembre de 2026 | 10.255 | 36,8 ms | 250,1 ms |
| enero de 2026 | 72.592 | 201,0 ms | 310,8 ms |
| enero de 2022 | 379.483 | 630,5 ms | 586,5 ms |
| enero de 2012 | 549.190 | 1.534,6 ms | 1.548,4 ms |
| todo | 620.703 | 1.405,1 ms | 1.243,5 ms |

El hint gana 6,8 veces con el mes, y desde unos 380.000 protocolos empata o pierde hasta un 13 %. Con los datos en memoria la
pérdida es chica; con los datos en disco, el *nested loop* sobre medio millón de protocolos es el que lee al azar. Un hint es una
estimación congelada. **Y cuando el hint nombra un índice:** el día que el índice cambia, el hint falla, avisa en voz baja o
sigue mandando sobre datos que ya no son los que lo justificaron.

**Cuándo sí.** Cuando la consulta está medida en el precipicio, el costo de equivocarse es grande, la causa no se puede arreglar
en el modelo, y el hint lleva su fecha y su medición al lado. Es una deuda declarada, no una solución.

**Cuándo no reutilizar planes.** Cuando el parámetro tiene valores de tamaños muy distintos, como la sede, y la consulta es lo
bastante cara como para que planificar cada vez sea gratis en comparación: aquí, unas décimas de milisegundo contra 220 ms.

**Lo que no se mide aquí:** el costo de planificar en consultas de muchas tablas, donde el plan genérico sí ahorra, y los planes
fijados de Oracle y SQL Server, que el curso no publica.

Las cinco preguntas, para lo que enseñó esta fase:

- **Frontera transaccional:** un plan genérico vive en la conexión, no en la transacción; un *pool* lo pasa de un usuario al
  siguiente.
- **Consultas conocidas:** un hint fija una consulta conocida a una distribución de datos conocida; cuando cambia la segunda, el
  hint no lo sabe.
- **Unidad de lectura:** el *hash join* lee la tabla entera; el *nested loop*, las filas que le piden.
- **Saltos:** cada join es una decisión de método, y un error de estimación las arrastra a todas.
- **Exactitud o parecido:** el plan genérico es el plan del valor promedio, que no es ningún valor.

---

## ⚠️ 12. Errores comunes y diagnóstico

- **Una consulta preparada que se vuelve lenta después de unas ejecuciones.** 🩺 `SELECT name, generic_plans, custom_plans FROM
  pg_prepared_statements`, en la misma conexión, y el plan con `EXPLAIN EXECUTE`: si muestra `$1`, es el genérico.
- **La misma consulta, rápida en `psql` y lenta desde la aplicación.** 🩺 En `psql` se planifica con el valor; la aplicación la
  preparó. Prueba con `PREPARE` y seis `EXECUTE` en `psql`.
- **`ERROR 1176 (42000): Key '…' doesn't exist in table` en MySQL.** 🩺 Un `FORCE INDEX` o `USE INDEX` que nombra un índice
  borrado o renombrado.
- **`Warning 3128 Unresolved name … for INDEX hint`.** 🩺 Un *optimizer hint* que no encontró lo que nombra: la consulta corre sin
  él.
- **Un *merge join* que lee un millón de bloques.** 🩺 Está recorriendo un índice entero para obtener el orden; revisa si el otro
  lado es chico.
- **Un plan distinto en dos servidores con los mismos datos.** 🩺 `random_page_cost`, `effective_cache_size` y la versión: el
  costo no es el mismo en los dos.

---

## 📋 13. Checklist de validación

```text
[ ] 02_join_methods.sql: el central elige hash join, y el nested loop forzado es más rápido
[ ] 01_generic_plans.sql: 0 genéricos si empieza en los centros, 1 si empieza en el central
[ ] la sede V con el plan genérico lee unos 88.000 bloques; con el personalizado, unos 10.900
[ ] psycopg_prepare.py: la undécima ejecución es la primera genérica
[ ] 04_the_hint.sql: la sede E con el hint lee 691.136 entradas, sin él 50
[ ] FORCE INDEX con un índice borrado da el error 1176; el optimizer hint, el aviso 3128
```

---

## 🧪 14. Ejercicios (24)

## 🟢 Fácil — leer un plan (1–7)

### 🟢 Ejercicio 1 — Los tres métodos

Corre `02_join_methods.sql` y anota el método, los bloques y el tiempo de cada plan.

**Objetivo:** la tabla de la sección 5.1.

[Solución](soluciones/13-el-optimizador-en-tres-motores.md#ejercicio-1)

### 🟢 Ejercicio 2 — Lo que lee el *hash join*

Explica por qué el *hash join* lee casi los mismos bloques para el central y para la sede V.

**Objetivo:** el tamaño de `alameda.result` en bloques, y su relación con los 88.000.

[Solución](soluciones/13-el-optimizador-en-tres-motores.md#ejercicio-2)

### 🟢 Ejercicio 3 — `random_page_cost`

Repite el plan del central con `random_page_cost = 1.1` en la sesión.

**Objetivo:** el método elegido, y su costo estimado contra el del *hash join*.

[Solución](soluciones/13-el-optimizador-en-tres-motores.md#ejercicio-3)

### 🟢 Ejercicio 4 — Seis `EXECUTE`

Prepara la consulta por sede, ejecútala seis veces con el central y mira `pg_prepared_statements`.

**Objetivo:** cuántos planes de cada tipo, y el `$1` en el plan.

[Solución](soluciones/13-el-optimizador-en-tres-motores.md#ejercicio-4)

### 🟢 Ejercicio 5 — Empezar por los chicos

La misma preparación, con las cinco primeras ejecuciones para centros chicos y la sexta para el central.

**Objetivo:** cero planes genéricos.

[Solución](soluciones/13-el-optimizador-en-tres-motores.md#ejercicio-5)

### 🟢 Ejercicio 6 — El *driver* que prepara

Corre `psycopg_prepare.py`.

**Objetivo:** en qué ejecución se prepara la consulta y en cuál se usa el primer plan genérico.

[Solución](soluciones/13-el-optimizador-en-tres-motores.md#ejercicio-6)

### 🟢 Ejercicio 7 — `EXPLAIN` preparado en MySQL

Corre `03_mysql_prepared.sql`.

**Objetivo:** una estimación distinta para cada sede, y la real de cada una.

[Solución](soluciones/13-el-optimizador-en-tres-motores.md#ejercicio-7)

## 🟡 Intermedio — los planes reutilizados (8–14)

### 🟡 Ejercicio 8 — De dónde sale el 3.446

En el plan genérico, la estimación del índice es 3.446 filas. Calcúlala con `pg_stats`.

**Objetivo:** la cuenta, con la fracción de una sede y la del rango de fechas.

[Solución](soluciones/13-el-optimizador-en-tres-motores.md#ejercicio-8)

### 🟡 Ejercicio 9 — El costo de planificar

Mide el `Planning Time` de la consulta con plan personalizado, diez veces.

**Objetivo:** el tiempo de planificar contra los 220 ms que pierde la sede V con el genérico.

[Solución](soluciones/13-el-optimizador-en-tres-motores.md#ejercicio-9)

### 🟡 Ejercicio 10 — `force_custom_plan`

Repite la sesión que empieza en el central con `plan_cache_mode = force_custom_plan`.

**Objetivo:** el plan de la sede V en la sexta ejecución, y los contadores.

[Solución](soluciones/13-el-optimizador-en-tres-motores.md#ejercicio-10)

### 🟡 Ejercicio 11 — Sin preparar en Python

Cambia `psycopg_prepare.py` para que la conexión no prepare nunca.

**Objetivo:** los tiempos de la sede V, y cero sentencias preparadas.

[Solución](soluciones/13-el-optimizador-en-tres-motores.md#ejercicio-11)

### 🟡 Ejercicio 12 — El genérico con el modelo de costos ajustado

Repite la sesión que empieza en el central con `random_page_cost = 1.1`.

**Objetivo:** el método de los planes personalizados y del genérico, y el tiempo de la sede V.

[Solución](soluciones/13-el-optimizador-en-tres-motores.md#ejercicio-12)

### 🟡 Ejercicio 13 — El *merge join*

Explica por qué el *merge join* lee más de un millón de bloques en la consulta de esta fase.

**Objetivo:** el nodo que los lee, y qué tendría que pasar para que el *merge join* ganara.

[Solución](soluciones/13-el-optimizador-en-tres-motores.md#ejercicio-13)

### 🟡 Ejercicio 14 — Los hints de MySQL sobre la caja

Sobre `staging.protocolos_en_orden`, cuenta los protocolos de la sede V de septiembre con `/*+ NO_INDEX(…) */` y con
`FORCE INDEX` sobre el índice por paciente.

**Objetivo:** el plan de cada uno, y por qué el segundo recorre la tabla aunque fuerce un índice.

[Solución](soluciones/13-el-optimizador-en-tres-motores.md#ejercicio-14)

## 🟠 Difícil — fijar o no fijar (15–20)

### 🟠 Ejercicio 15 — El hint en las sedes activas

Corre la primera parte de `04_the_hint.sql` para las cinco sedes activas y la cerrada.

**Objetivo:** las entradas leídas con el hint en cada una, y su relación con la proporción de la sede.

[Solución](soluciones/13-el-optimizador-en-tres-motores.md#ejercicio-15)

### 🟠 Ejercicio 16 — Los dos hints que ya no encuentran su índice

Corre la última parte de `04_the_hint.sql`.

**Objetivo:** el error y el aviso, y cuál de los dos preferirías en producción.

[Solución](soluciones/13-el-optimizador-en-tres-motores.md#ejercicio-16)

### 🟠 Ejercicio 17 — Un plan fijado que envejece

Corre `05_fixed_plan_over_time.sql`.

**Objetivo:** el rango en que el *nested loop* fijado deja de ganar.

[Solución](soluciones/13-el-optimizador-en-tres-motores.md#ejercicio-17)

### 🟠 Ejercicio 18 — El central, mes por mes

Con la consulta preparada y `plan_cache_mode = auto`, ejecuta la consulta del central para doce meses distintos de 2025
(la fecha como segundo parámetro).

**Objetivo:** si aparece un plan genérico, y por qué.

[Solución](soluciones/13-el-optimizador-en-tres-motores.md#ejercicio-18)

### 🟠 Ejercicio 19 — La pantalla de la sede, en Postgres

Escribe en Postgres la consulta de los últimos 50 protocolos de una sede sobre `staging.order_site`, y mide la sede `E`
con el índice compuesto y sin él.

**Objetivo:** el plan y los bloques en los dos casos.

[Solución](soluciones/13-el-optimizador-en-tres-motores.md#ejercicio-19)

### 🟠 Ejercicio 20 — El *pool* de conexiones

Diseña un experimento con dos conexiones de psycopg que muestre que el plan genérico es de la conexión y no de la consulta.

**Objetivo:** las dos conexiones con contadores distintos para la misma consulta.

[Solución](soluciones/13-el-optimizador-en-tres-motores.md#ejercicio-20)

## 🔴 Muy difícil — decidir (21–24)

### 🔴 Ejercicio 21 — Oracle

Resuelve en tu máquina la apuesta 🪞🔒 de la sección 6.

**Objetivo:** explicar el resultado con la documentación de Oracle, sin publicar ningún número.

[Solución](soluciones/13-el-optimizador-en-tres-motores.md#ejercicio-21)

### 🔴 Ejercicio 22 — La política de Alameda

Propón la regla de Alameda para las consultas por sede en la aplicación nueva: preparar o no, `plan_cache_mode`, y el
parámetro del modelo de costos.

**Objetivo:** la regla, con la medición que la justifica y lo que cuesta.

[Solución](soluciones/13-el-optimizador-en-tres-motores.md#ejercicio-22)

### 🔴 Ejercicio 23 — ¿Bajar `random_page_cost` en el servidor?

Decide si Alameda baja `random_page_cost` para todo el servidor, sabiendo lo que hizo en la Fase 12 y en esta.

**Objetivo:** la decisión, con las dos mediciones y la condición del disco.

[Solución](soluciones/13-el-optimizador-en-tres-motores.md#ejercicio-23)

### 🔴 Ejercicio 24 — Inventario de hints

Escribe la búsqueda que encontraría los hints en el código de una aplicación que manda SQL a MySQL y a Postgres, y la ficha que
cada hint encontrado debería tener.

**Objetivo:** la búsqueda y la ficha, con los campos que habrían salvado a la pantalla de la sede `E`.

[Solución](soluciones/13-el-optimizador-en-tres-motores.md#ejercicio-24)

## 🔥 Opcionales

### 🔥 Ejercicio 🔥 1 — `pg_hint_plan` en una imagen derivada

`pg_hint_plan` no viene en la imagen del curso. Arma una imagen derivada con el paquete de PGDG para Postgres 18, levanta un
contenedor de prueba etiquetado `curso=ruta-sql` sin puertos publicados, y fuerza un *nested loop* con `/*+ NestLoop(o r) */`.
Después nombra en el hint una tabla que no existe.

**Objetivo:** el plan con el hint, y qué pasa con el hint mal escrito.

[Solución](soluciones/13-el-optimizador-en-tres-motores.md#ejercicio--1)

---

## 📚 15. Referencias

**Documentación oficial**

- **`PREPARE` y los planes genéricos** — https://www.postgresql.org/docs/18/sql-prepare.html — la regla de las cinco
  ejecuciones y `plan_cache_mode`.
- **Planes de ejecución y métodos de join** — https://www.postgresql.org/docs/18/planner-optimizer.html
- **Constantes de costo del planificador** — https://www.postgresql.org/docs/18/runtime-config-query.html — `random_page_cost`
  y los `enable_*`.
- **Sentencias preparadas en psycopg 3** — https://www.psycopg.org/psycopg3/docs/advanced/prepare.html — `prepare_threshold`.
- **Optimizer hints e index hints en MySQL 9.7** — https://dev.mysql.com/doc/refman/9.7/en/optimizer-hints.html y
  https://dev.mysql.com/doc/refman/9.7/en/index-hints.html
- **Adaptive cursor sharing en Oracle** — https://docs.oracle.com/en/database/oracle/oracle-database/23/tgsql/improving-rwp-cursor-sharing.html
- **`pg_hint_plan`** — https://github.com/ossc-db/pg_hint_plan — la extensión del 🔥.

**Papers y libros**

- **Goetz Graefe, "Query Evaluation Techniques for Large Databases", *ACM Computing Surveys*, 1993** — los métodos de join y
  cuándo gana cada uno.
- **Viktor Leis et al., "How Good Are Query Optimizers, Really?", VLDB 2015** — cuánto del error del plan es de cardinalidad y
  cuánto del modelo de costos.

**Orden de lectura sugerido:** la página de `PREPARE` antes de la sección 5.2; Graefe, la parte de joins, antes de la 5.1.

> ⚠️ Las URL y sus contenidos cambian. Se consultaron el 14/10/2026.

---

## 🏁 16. Resultado de la fase

```text
LOS TRES MÉTODOS · septiembre de 2026
  central        nested loop 35 ms · hash join 265 ms (el elegido) · merge 986 ms
  centro V       nested loop 22 ms (el elegido) · hash 936 ms · merge 980 ms
EL PLAN GENÉRICO
  empieza en los centros        0 genéricos · el central con su plan
  empieza en el central         la sede V hereda el hash join: 87.945 contra 10.865 bloques, 242 contra 22 ms
  psycopg 3                     prepara en la 6.ª ejecución · la 11.ª ya es genérica
EL HINT
  sede E con FORCE INDEX        691.136 entradas, 619 ms · sin él, 50 entradas, 1,1 ms
  índice borrado                FORCE INDEX: error 1176 · optimizer hint: aviso 3128
  nested loop fijado            gana 6,8× con el mes · empata o pierde desde 380.000 protocolos
```

> **La señal de que quedó bien:** *"Puedo decir qué plan está usando una consulta preparada en una conexión dada, por qué, y
> qué cuesta cada salida; y no pongo un hint sin su fecha y su medición."*

> 🏷️ **No cierres la fase sin el tag.** Con el checklist en verde y `git status` limpio:
>
> ```bash
> git tag -a fase-13-el-optimizador-en-tres-motores -m "F13 cerrada: los tres métodos de join medidos, el plan genérico que hereda la sede chica, psycopg que prepara solo, y el hint de la sede que cerró"
> ```
>
> Commits de la fase con prefijo `f13:`, los de ejercicio `f13 ej24: …`.
