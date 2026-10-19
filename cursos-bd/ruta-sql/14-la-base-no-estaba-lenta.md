# 🐢 Fase 14 — La base no estaba lenta: viajes, filas que nadie mira y páginas que no terminan

> **Curso:** Ruta SQL · Fase 14 de 27 · Bloque II — La física y el tuning · **10 h**
> **Motores:** PostgreSQL `pgvector/pgvector@sha256:2358fcba361e…` · contraste MySQL `mysql@sha256:e2bde46db656…` · —
> **Entorno de ejecución:** SQL y Python
> **Perfil de volumen:** M, con el modelo de `uv run lab load --profile m --model`
> **El dolor de Alameda:** el frontal Access sobre ODBC y los dos años de "la base está lenta" (historia §3, 2011–2013)
> **Depende de:** Fase 13 · **Habilita:** Fase 15
> **Apéndices de apoyo:** a03, a04, a07, a08
> **Fecha de verificación ejecutada:** 14/10/2026
> **Objetivo:** medir lo que una pantalla pide a la base en viajes, filas y bytes contra lo que muestra, paginar sin
> leer lo que no se muestra, y saber reconocer cuándo la base sí está lenta.

---

## 🧭 1. Dónde estamos

Las fases 09 a 13 midieron lo que pasa adentro del motor: el tamaño de las filas, los índices, las estadísticas, los
planes. Esta fase sale del motor y mira el cable. Una consulta perfecta puede formar parte de una pantalla lenta, si la
pantalla la manda sesenta veces, o si trae un millón de filas para mostrar sesenta. Desde el lado del usuario, las dos cosas
se ven igual: "la base está lenta".

La unidad de medida cambia en consecuencia. Hasta aquí fueron bloques leídos y bytes de WAL; en esta fase son **viajes, filas y
bytes que cruzan el cable**, contra filas que la pantalla muestra. El tiempo del servidor aparece solo como referencia: es la
parte que la base controla, y casi nunca es la grande.

Es la última fase del Bloque II, y cierra con su 💀 boss: el portal de 2018, que pide todo lo que el bloque mide.

---

## 🎯 2. Objetivos de esta fase

1. Medir una pantalla en viajes, filas y bytes transferidos contra filas mostradas.
2. Reconocer los tres patrones del frontal de 2011: la tabla entera detrás del formulario, el N+1 y el join en el cliente.
3. Paginar con *keyset* en lugar de `OFFSET`, en los dos motores, y medir la diferencia bajo carga.
4. Usar `pg_stat_statements` para ver qué consultas corren cuántas veces y cuánto cuestan.
5. Distinguir una base lenta de una aplicación que le pide demasiado.

---

## 🚫 3. Qué NO entra todavía

- **Dos usuarios pidiendo lo mismo a la vez, y lo que se bloquean** → Bloque III, desde la [Fase 15](15-aislamiento-comparado.md).
- **El portal servido por una API con seguridad por fila** → Bloque V.
- **El tuning de red y del *driver* ODBC**: fuera del curso.

---

## 🏚️ 4. El dolor, en la caja

**2011.** Matías pasa los datos a SQL Server con el asistente de Access, y el frontal sigue siendo el mismo Access, ahora con
tablas vinculadas por ODBC. Con 30 PC y los centros entrando por VPN, abrir el formulario de protocolos trae por la red
cientos de miles de filas; hay consultas que Access resuelve del lado del cliente, con joins que traen dos tablas completas; y
el módulo de turnos se queda en un `.accdb` local, vinculado al servidor para todo lo demás. **La respuesta oficial durante dos
años fue "la base está lenta". La base no estaba lenta.**

La caja trae los datos, no el frontal. `front.py` lo simula contra el MySQL de la caja, con una copia de `Protocolos` y de
`ResultadoItem` que repone los índices del `AutoIndex` (`01_autoindex_copy.sql`, Fase 11). Cada pantalla se mide como la
armaba Access y como la pediría alguien que sabe lo que la pantalla muestra. Para la tabla vinculada, el simulador sigue lo que
describe Mike Wolfe al observar Access contra SQL Server: primero las claves de toda la tabla, después las filas de a diez hasta
llenar la pantalla (las referencias).

---

## 🧩 5. Lo que cruza el cable

### 5.1 Tres pantallas, medidas

`front.py` cuenta las sentencias (cada una es un viaje), las filas que llegan, y los bytes que manda el servidor (el contador
`Bytes_sent` de la sesión de MySQL):

> 📐 **Medición: tres pantallas del frontal de 2011** · la caja M · `mysql@sha256:e2bde46db656…` · verificado el 14/10/2026
>
> | Pantalla | Viajes | Filas | Muestra | Filas por fila mostrada | Bytes |
> |---|---|---|---|---|---|
> | formulario de protocolos, como Access | 7 | 1.327.682 | 60 | 22.128 | 17.337.090 |
> | formulario de protocolos, 60 filas | 1 | 60 | 60 | 1 | 5.692 |
> | resultados de la pantalla, uno por protocolo | 61 | 429 | 429 | 1 | 73.612 |
> | resultados de la pantalla, una consulta | 2 | 429 | 429 | 1 | 34.613 |
> | turnos del día, join en el cliente | 1 | 242.427 | 249 | 974 | 33.065.042 |
> | turnos del día, join en el servidor | 1 | 249 | 249 | 1 | 34.475 |

**El formulario.** Siete viajes: uno para las 1.327.622 claves de `Protocolos`, y seis para las 60 filas visibles, de a diez. El
formulario no trae la tabla entera; trae **todas sus claves**, que en la caja son 17 MB. La versión correcta pide las 60 filas que
muestra, en un viaje y 5,7 kB.

Por qué Access pide las claves es fácil de reconstruir: un formulario enlazado deja moverse a cualquier registro, ir al último,
saltar al 500.000 con la barra de desplazamiento y editar el que se ve. Para todo eso necesita saber qué registros existen y en
qué orden, y la manera más barata de saberlo es tener sus claves. Es un buen diseño para una tabla local de miles de filas, que es
para lo que Access se diseñó. Sobre un millón de filas al otro lado de una VPN, el mismo diseño es una descarga de 17 MB cada vez
que alguien abre el formulario. Y el formulario se abría decenas de veces por día en cada PC.

**El N+1.** La pantalla de resultados muestra los 60 protocolos y sus 369 resultados, 429 filas. Pedirlos uno por protocolo no trae
filas de más: trae **viajes** de más, 61 contra 2, y dobla los bytes, porque cada respuesta lleva su propia descripción de
columnas. Dentro del mismo servidor tarda 18,9 ms contra 2,9.

**El join en el cliente.** Los 249 pacientes con turno ese día en el central están en una tabla local del `.accdb`. Para unirla
con `Pacientes`, que está en el servidor, el frontal trae `Pacientes` entera, 242.427 filas y 33 MB, y descarta 242.178. La
versión correcta manda los 249 identificadores y recibe 249 filas.

### 5.2 Lo que cuesta en la VPN de un centro

Las mediciones de la sección 5.1 corrieron dentro del mismo servidor, donde un viaje cuesta décimas de milisegundo. En 2011, un
centro de extracción entraba por VPN. **Lo que sigue es una cuenta, no una medición**, con dos supuestos que cada lector puede
cambiar: 30 ms de ida y vuelta y 4 Mbit/s de ancho de banda. El tiempo de red de una pantalla es viajes × 30 ms más bytes × 8 /
4.000.000:

| Pantalla | Como Access | Bien pedida |
|---|---|---|
| formulario de protocolos | 0,21 s + 34,7 s = **34,9 s** | 0,03 s + 0,01 s = 0,04 s |
| resultados de la pantalla | 1,83 s + 0,15 s = **2,0 s** | 0,06 s + 0,07 s = 0,13 s |
| turnos del día | 0,03 s + 66,1 s = **66,2 s** | 0,03 s + 0,07 s = 0,10 s |

En las tres, lo que tarda no lo hace el motor. El formulario es ancho de banda; el N+1 es latencia; el join en el cliente es las
dos cosas. Un servidor más grande no cambia ninguno de los tres números.

### 5.3 `pg_stat_statements`: el Query Store de pobre

`pg_stat_statements` guarda, por cada consulta normalizada (las constantes pasan a `$1`), cuántas veces corrió, cuántas filas
devolvió y cuánto tardó en el servidor. Ya está cargado en el laboratorio. `03_stat_statements.sql` corre la pantalla de
resultados de las dos maneras contra Postgres:

```text
 calls | rows | total_ms | mean_ms |                                 query
-------+------+----------+---------+------------------------------------------------------------------------
    60 |  369 |     7.87 |   0.131 | SELECT * FROM alameda.result WHERE lab_order_id = $1
     1 |  369 |     0.26 |   0.256 | SELECT r.* FROM alameda.result r WHERE r.lab_order_id IN (SELECT lab_o
```

El N+1 se ve como **una consulta barata con muchas llamadas**: 0,13 ms de promedio, nada que mirar consulta por consulta, y 30
veces el tiempo total de la versión de una consulta. Por eso el orden útil de esa vista es `total_exec_time`, no
`mean_exec_time`: la consulta más cara del sistema suele ser una barata que corre un millón de veces.

La vista tiene otra señal, que se ve con el portal. Las cien primeras páginas con `OFFSET` quedan como una sola entrada (el
`OFFSET` también se normaliza): 100 llamadas, 0,017 ms la más rápida y 0,282 ms la más lenta, 17 veces más. Una entrada cuyo
máximo está muy lejos del mínimo es una consulta cuyo costo depende del valor del parámetro: una página profunda, o la sede del
central de la Fase 13. `pg_stat_statements` no dice qué valor fue; dice que hay que buscarlo.

MySQL tiene su equivalente en `performance_schema.events_statements_summary_by_digest`, y ya tiene guardado lo que corrió
`front.py`:

```text
COUNT_STAR	SUM_ROWS_SENT	total_ms	avg_ms	DIGEST_TEXT
60	369	11.4	0.19	SELECT * FROM `staging` . `resultado_item` WHERE `IdProtocolo` = ?
2	2655244	3372.1	1686.025	SELECT `IdProtocolo` FROM `staging` . `protocolos` ORDER BY `IdProtocolo` DESC
1	242427	1746.2	1746.171	SELECT * FROM `legacy` . `Pacientes`
```

Las tres pantallas, vistas desde el servidor: el N+1 como 60 llamadas de 0,19 ms; las claves del formulario (dos corridas) como
1,7 s por llamada y 1.327.622 filas cada una; los pacientes enteros, 1,7 s y 242.427 filas. El servidor ve las filas que manda y
cuánto tarda en mandarlas, que es el límite de lo que un servidor más grande puede mejorar. No ve los 33 s que esas filas tardan en
cruzar la VPN.

> 🩻 **Esto sí funciona igual** en los dos motores: el cable cobra viajes y bytes, y el motor no ve ninguno de los dos.

### 5.4 Paginar: `OFFSET` y *keyset*

El portal lista los protocolos de a 20, del más nuevo al más viejo. Con `OFFSET`, la página *n* lee y descarta las 20 × (*n* − 1)
filas anteriores. Con *keyset*, la página siguiente pide "los 20 anteriores al último que mostré", y lee 20.
`02_portal_paging.sql`, sobre `staging.portal_order` con un índice `(ordered_on DESC, lab_order_id DESC)`:

| Página | `OFFSET`: bloques | `OFFSET`: ms | *Keyset*: bloques | *Keyset*: ms |
|---|---|---|---|---|
| 1 | 20 | 0,01 | 21 | 0,03 |
| 1.000 | 17.687 | 3,8 | 22 | 0,02 |
| 5.000 | 87.969 | 37,2 | 20 | 0,03 |
| 50.000 | 878.758 | 196,0 | 21 | 0,07 |

El costo de `OFFSET` crece con la página, unos 17,6 bloques por página; el de *keyset* es plano. La clave del *keyset* tiene que
ser única y estar en el índice. Las dos condiciones se miden.

**Única:** la primera página del portal es entera del último día, que tiene 518 protocolos. Con la clave solo por fecha, la
página 2 pediría los anteriores a ese día, y **los otros 498 protocolos de ese día no aparecerían en ninguna página**; con `<=` en
lugar de `<`, la página 2 repetiría la primera. El desempate por `lab_order_id` hace única cada posición. **En el índice:** sin
`(ordered_on DESC, lab_order_id DESC)`, la misma página con *keyset* recorre la tabla entera y la ordena para quedarse con 20:
10.688 bloques y 46 ms, en cada página. *Keyset* no es una manera de escribir la consulta; es la consulta más el índice en el
orden de la lista.

Y "página 1 de 66.382" cuesta su propio `count(*)`: 10.688 bloques y 38 ms, en cada página, para un número que nadie usa. Una
estimación (`reltuples`) o un "siguiente" sin total sale gratis.

---

## 🔀 6. El contraste: dónde otro motor cambia la decisión

**En MySQL, el *keyset* hay que escribirlo de una manera precisa.** La comparación de filas, la forma natural:

```text
-> Index scan on protocolos using protocolos_fecha_idx (reverse)  (cost=0.0234 rows=20) (actual time=0.0842..1099 rows=1.32e+6 loops=1)
```

MySQL no la usa como rango: recorre el índice desde el principio y filtra, 1,32 millones de entradas y **1.169 ms**, más que el
`OFFSET` de la página 50.000 (892 ms, con un *filesort* sobre la tabla entera). La misma condición escrita con `OR`:

```sql
-- mysql
WHERE Fecha < '2001-06-01' OR (Fecha = '2001-06-01' AND IdProtocolo < 2147483647)
```

```text
-> Index range scan on protocolos using protocolos_fecha_idx over (NULL < Fecha < '2001-06-01 00:00:00.000') OR (Fecha = '2001-06-01 00:00:00.000' AND IdProtocolo < 2147483647) (reverse)
   (actual time=0.353..0.445 rows=20 loops=1)
```

**0,45 ms.** El índice de `Fecha` sirve también para el desempate porque InnoDB guarda la clave primaria en cada índice
secundario (Fase 09). Postgres convierte la comparación de filas en un rango del índice sin ayuda. La decisión que cambia: en
MySQL, un *keyset* se valida con su plan, porque la forma elegante puede ser la peor.

> 🪞🔒 **Apuesta sin resolver: Oracle.** Hipótesis: en Oracle, la página 50.000 con `OFFSET … FETCH NEXT 20 ROWS ONLY` lee las
> filas descartadas igual que Postgres, porque la cláusula es una forma de `ROW_NUMBER()` sobre el orden; y el *keyset* con
> comparación de filas usa el índice `(ordered_on, lab_order_id)` como rango, como Postgres y no como MySQL. Condiciones: los
> protocolos de M con ese índice, y `DBMS_XPLAN.DISPLAY_CURSOR` con `ALLSTATS LAST` en `sqlplus`
> ([`a03`](a03-clis-de-los-motores.md#️-oracle--sqlplus)). El mecanismo, en la documentación oficial: la cláusula de límite de
> filas de `SELECT` (en las referencias). 📝 No publicamos números de Oracle; el porqué está en
> [`a09`](a09-licencias-publicacion-y-riesgo.md).

---

## 🪞 7. Tu instinto dice… y la apuesta

**Tu instinto dice** que un formulario sobre una tabla grande trae de más, y que eso se arregla con un filtro. Las dos cosas son
ciertas, y la primera se queda corta.

> 🪞 **Apuesta antes de ejecutar** (escrita el 30/09/2026, al diseñar esta fase). *"El formulario de protocolos trae al menos mil
> veces más filas de las que muestra."*
> **Resultado:** **ganada, por veintidós.** Trae 1.327.682 filas para mostrar 60: **22.128 veces más**. En bytes, 17,3 MB contra
> 5,7 kB, 3.046 veces.

La apuesta se quedó corta porque pensaba en filas completas. Access no trae las filas: trae las claves, y una clave es chica. Por
eso en bytes la proporción es siete veces menor que en filas. Las dos cifras importan: las filas dicen cuánto trabajo pidió la
pantalla; los bytes, cuánto tarda en cruzar la VPN. Un filtro en el servidor achica las dos: con los protocolos de septiembre, el
mismo formulario trae 21.162 claves, unos 275 kB.

---

## 💥 8. El punto de rotura

**La página profunda contra el `statement_timeout`, con el portal bajo carga.** Una página sola con `OFFSET`, con la caché
caliente, no llega a romper un límite de 100 ms: la última, la 66.381, tarda entre 45 y 62 ms. El portal no tiene un usuario a la
vez. `portal_offset.pgbench` y `portal_keyset.pgbench` piden páginas al azar con ocho clientes durante 30 segundos, con `pgbench`
dentro del contenedor:

| Paginación | Páginas servidas | Promedio | Páginas de más de 100 ms |
|---|---|---|---|
| `OFFSET` | 1.851 (61 por segundo) | 130,3 ms | **1.137 (61,4 %)** |
| *keyset* | 1.590.281 (53.019 por segundo) | 0,15 ms | 0 |

Con un `statement_timeout` de 100 ms, **seis de cada diez páginas del portal se cancelarían** con `canceling statement due to
statement timeout`. Con *keyset*, ninguna, y el mismo servidor atiende 863 veces más páginas por segundo.

Un bot que recorre el portal entero, como el de 2018, pide exactamente las páginas profundas, y las pide todas. **Lo que sigue es
una cuenta** con los rendimientos medidos: las 66.381 páginas, a 61 por segundo con ocho clientes, son unos 18 minutos de un
servidor ocupado en eso y en nada más; con *keyset*, a 53.019 por segundo, un segundo y cuarto. El portal de 2018 no tenía un
problema de rendimiento con el bot; tenía un problema de seguridad que el rendimiento hacía barato. El portal nuevo del boss tiene
que cerrar los dos.

---

## ⚰️ 9. Autopsia: la licencia Standard de 2014, y una base que no estaba lenta

**1. La decisión.** *"La base está lenta."* Durante dos años, cada queja por el formulario de protocolos o por los turnos terminó
en la base. En 2014 llegó la licencia Standard (por el techo de 10 GB de la edición Express, historia §3), y con ella la esperanza
de que la base dejara de estar lenta.

**2. Por qué era razonable.** Lo que se ve desde la PC es una pantalla que tarda, y lo único que se ve del otro lado es el
servidor. Nadie en Alameda tenía una herramienta para medir el cable: el SQL Server Profiler mostraba consultas rápidas, y eso
confirmaba que el problema estaba "en otro lado", que nadie podía nombrar.

**3. Qué pasó después.** Lo que cambió la licencia lo dice la sección 5.2: el formulario tarda unos 35 segundos en la VPN de un
centro, y de eso el servidor pone a lo sumo los 1,9 s que tarda entregar los 17 MB dentro de la misma máquina. Ni un servidor
infinitamente rápido baja el formulario de los 34,9 s de red. Los turnos, 66 s. El N+1, 2 s de latencia pura.

**4. Cuánto cuesta salir.** Cambiar cada pantalla para que pida lo que muestra: un `LIMIT`, un `IN`, una consulta en lugar de
sesenta. Es trabajo de la aplicación, pantalla por pantalla, y en Access implica dejar las tablas vinculadas por consultas de
paso a través o por formularios sin enlazar.

**5. Qué lo habría cambiado.** Medir el cable antes de comprar el motor: viajes y bytes por pantalla, como `front.py`. El motor
lo tenía a mano: `Bytes_sent` en MySQL, el Profiler en SQL Server, `pg_stat_statements` en Postgres.

**Antes y después, con números:** 17.337.090 bytes y unos 35 s en la VPN para el formulario de protocolos, contra 5.692 bytes y
0,04 s pidiendo las 60 filas que muestra.

---

## 📖 10. Traducción

| Concepto | Access / T-SQL | Postgres | MySQL | Oracle |
|---|---|---|---|---|
| estadísticas por consulta | Query Store, `sys.dm_exec_query_stats` | `pg_stat_statements` | `events_statements_summary_by_digest` | `V$SQL`, AWR |
| bytes enviados al cliente | — (lo ve el cliente) | — (lo ve la aplicación) | `Bytes_sent` de la sesión | `V$SESSTAT`, *bytes sent via SQL\*Net* |
| página por posición | `OFFSET … FETCH` | `OFFSET … LIMIT` | `LIMIT o, n` | `OFFSET … FETCH` |
| página por *keyset* | `WHERE (…) < (…)` expandido | `WHERE (a, b) < (x, y)` | `WHERE a < x OR (a = x AND b < y)` | comparación de filas o expandida |
| tiempo máximo por sentencia | `SET LOCK_TIMEOUT` (solo bloqueos) | `statement_timeout` | `max_execution_time` (solo `SELECT`) | perfiles de recursos |
| tabla vinculada | tabla vinculada por ODBC | `postgres_fdw` | `FEDERATED` | *database link* |

Hacia la NoSQL Lite: un cursor de MongoDB con `skip()` es `OFFSET`, con el mismo costo creciente, y la paginación por el último
`_id` visto es el *keyset*. El diccionario completo está en [`a07`](a07-diccionario-y-glosario.md).

---

## ⚖️ 11. Veredicto honesto: cuándo NO usar esto

**Cuándo la base sí está lenta, y cómo se reconoce.** Cuando `pg_stat_statements` ordenado por `total_exec_time` muestra una
consulta con un promedio alto, muchos bloques leídos por llamada y un plan que la Fase 12 o la 13 explican. Cuando el tiempo del
servidor (`total_exec_time` de la ventana) se acerca al tiempo que el usuario esperó. Y cuando una consulta tarda lo mismo desde
`psql` en el servidor que desde la pantalla. Si el tiempo de la pantalla es mucho mayor que la suma del tiempo del servidor, lo
que está lento es el cable o la aplicación, y la base es inocente.

**Cuándo no usar *keyset*.** Cuando el usuario necesita saltar a la página 37 por número: *keyset* va a la siguiente y a la
anterior, no a una página arbitraria. Para listas cortas (las 56 páginas de un médico derivante), `OFFSET` cuesta poco y es más
simple. Y cuando el orden no tiene una clave única: hay que agregarle el desempate, o el *keyset* pierde filas.

**Cuándo no preocuparse por el N+1.** Cuando son diez consultas y no mil, y la aplicación corre en la misma máquina que la base:
dentro del servidor, el N+1 de esta fase cuesta 16 ms más que la consulta única. El problema aparece con la distancia; la misma pantalla en la VPN cuesta 2
segundos.

**Cuándo no alcanza `pg_stat_statements` solo.** Mide el servidor, y nada más: no ve el cable, ni la aplicación, ni el tiempo que
una pantalla espera entre una consulta y la siguiente. Guarda un número limitado de consultas distintas
(`pg_stat_statements.max`, 5.000 por defecto) y descarta las menos usadas cuando se llena; y acumula desde el último
`pg_stat_statements_reset()`, así que un promedio de meses esconde el lunes en que todo se puso lento. Sirve para la pregunta "¿qué
le cuesta a la base?", y por eso es la primera mirada; la pregunta "¿por qué tarda la pantalla?" necesita además los viajes y los
bytes de la pantalla, medidos del lado del cliente como en `front.py`.

**Lo que no se mide aquí:** la red real. Los tiempos de la sección 5.2 son una cuenta con dos supuestos; los viajes y los bytes sí
son medidos.

Las cinco preguntas, para lo que enseñó esta fase:

- **Frontera transaccional:** sesenta consultas no son una transacción; si la pantalla necesita ver un estado consistente, el N+1
  además puede mostrar cosas que nunca existieron juntas.
- **Consultas conocidas:** cada pantalla es una consulta conocida; escribirla es saber qué muestra.
- **Unidad de lectura:** la fila mostrada; todo lo demás es costo.
- **Saltos:** cada salto es un viaje, y en una VPN un viaje vale 30 ms.
- **Exactitud o parecido:** "página 1 de 66.382" exacto cuesta 38 ms en cada página; aproximado, nada.

---

## ⚠️ 12. Errores comunes y diagnóstico

- **`canceling statement due to statement timeout` en las páginas finales de una lista.** 🩺 Un `OFFSET` profundo: cámbialo por
  *keyset*.
- **Una consulta con miles de `calls` y un promedio bajo arriba de todo en `pg_stat_statements`.** 🩺 Un N+1: busca en la
  aplicación el bucle que la manda.
- **Un *keyset* en MySQL que tarda más que el `OFFSET`.** 🩺 La comparación de filas no se usa como rango: escríbela con `OR`.
- **Una lista con *keyset* que pierde o repite filas.** 🩺 La clave del orden no es única: agrégale la clave primaria.
- **La misma consulta, rápida en `psql` y lenta en la pantalla.** 🩺 Cuenta viajes y bytes de la pantalla antes de mirar el plan.
- **Un formulario de Access que tarda en abrir sobre una tabla vinculada.** 🩺 Trae todas las claves de la tabla: ponle un filtro o
  bórralo de la tabla.

---

## 📋 13. Checklist de validación

```text
[ ] front.py: el formulario como Access trae 1.327.682 filas y unos 17 MB para mostrar 60
[ ] el N+1 hace 61 viajes contra 2; el join en el cliente trae 242.427 pacientes para 249
[ ] pg_stat_statements muestra la consulta del N+1 con calls = 60
[ ] la página 50.000 con OFFSET lee unos 880.000 bloques; con keyset, unos 20
[ ] pgbench con OFFSET: más de la mitad de las páginas por encima de 100 ms; con keyset, ninguna
[ ] el keyset de MySQL con comparación de filas recorre el índice entero; con OR, 20 filas
```

---

## 🧪 14. Ejercicios (26)

## 🟢 Fácil — medir una pantalla (1–8)

### 🟢 Ejercicio 1 — El formulario, como Access

Corre `front.py` y lee la fila del formulario de protocolos como lo armaba Access.

**Objetivo:** 7 viajes, 1.327.682 filas y unos 17 MB, y de dónde sale cada viaje.

[Solución](soluciones/14-la-base-no-estaba-lenta.md#ejercicio-1)

### 🟢 Ejercicio 2 — El formulario, bien pedido

Lee la fila del formulario que pide 60 filas.

**Objetivo:** un viaje y 5.692 bytes, y la consulta.

[Solución](soluciones/14-la-base-no-estaba-lenta.md#ejercicio-2)

### 🟢 Ejercicio 3 — El N+1

Compara las dos filas de la pantalla de resultados.

**Objetivo:** 61 contra 2 viajes, con las mismas 429 filas.

[Solución](soluciones/14-la-base-no-estaba-lenta.md#ejercicio-3)

### 🟢 Ejercicio 4 — El join en el cliente

Compara las dos filas de los turnos del día.

**Objetivo:** 242.427 contra 249 filas, y 33 MB contra 34 kB.

[Solución](soluciones/14-la-base-no-estaba-lenta.md#ejercicio-4)

### 🟢 Ejercicio 5 — `OFFSET`, página 1 y página 1.000

Mide con `EXPLAIN (ANALYZE, BUFFERS)` las páginas 1 y 1.000 del portal con `OFFSET`.

**Objetivo:** 20 contra 17.687 bloques.

[Solución](soluciones/14-la-base-no-estaba-lenta.md#ejercicio-5)

### 🟢 Ejercicio 6 — *Keyset*, página 1.000

La página 1.000 con *keyset*, a partir del último protocolo de la 999.

**Objetivo:** unos 20 bloques, y la consulta.

[Solución](soluciones/14-la-base-no-estaba-lenta.md#ejercicio-6)

### 🟢 Ejercicio 7 — "Página 1 de …"

Mide el `count(*)` de `staging.portal_order`.

**Objetivo:** 10.688 bloques, y cuántas veces se paga.

[Solución](soluciones/14-la-base-no-estaba-lenta.md#ejercicio-7)

### 🟢 Ejercicio 8 — `pg_stat_statements`

Corre `03_stat_statements.sql`.

**Objetivo:** la consulta del N+1 con 60 llamadas, normalizada con `$1`.

[Solución](soluciones/14-la-base-no-estaba-lenta.md#ejercicio-8)

## 🟡 Intermedio — leer lo que se midió (9–16)

### 🟡 Ejercicio 9 — La cuenta de la VPN

Con los viajes y los bytes de `front.py`, calcula el tiempo de red de cada pantalla con 30 ms y 4 Mbit/s, y con 80 ms y 1 Mbit/s.

**Objetivo:** las dos tablas, y qué pantalla depende de la latencia y cuál del ancho de banda.

[Solución](soluciones/14-la-base-no-estaba-lenta.md#ejercicio-9)

### 🟡 Ejercicio 10 — Lo que pesa un viaje

Explica por qué el N+1 manda 73.612 bytes y la consulta única 34.613, si las filas son las mismas.

**Objetivo:** los bytes de más por cada viaje de más.

[Solución](soluciones/14-la-base-no-estaba-lenta.md#ejercicio-10)

### 🟡 Ejercicio 11 — La página 50.000

Mide la página 50.000 con los dos métodos.

**Objetivo:** unos 880.000 contra unos 20 bloques.

[Solución](soluciones/14-la-base-no-estaba-lenta.md#ejercicio-11)

### 🟡 Ejercicio 12 — El total aproximado

Reemplaza el `count(*)` del portal por la estimación de `pg_class`.

**Objetivo:** la consulta, lo que lee, y cuánto se aleja del total real.

[Solución](soluciones/14-la-base-no-estaba-lenta.md#ejercicio-12)

### 🟡 Ejercicio 13 — El N+1 visto desde el servidor

Con la salida de `03_stat_statements.sql`, compara el promedio y el total de las dos consultas.

**Objetivo:** por qué ordenar por promedio esconde el N+1.

[Solución](soluciones/14-la-base-no-estaba-lenta.md#ejercicio-13)

### 🟡 Ejercicio 14 — *Keyset* sin su índice

Repite la página con *keyset* sin el índice `(ordered_on DESC, lab_order_id DESC)`.

**Objetivo:** el plan y los bloques.

[Solución](soluciones/14-la-base-no-estaba-lenta.md#ejercicio-14)

### 🟡 Ejercicio 15 — Los turnos, con los identificadores

Escribe la consulta de los turnos que manda al servidor los pacientes de la tabla local.

**Objetivo:** 249 filas, y un límite práctico de esa técnica.

[Solución](soluciones/14-la-base-no-estaba-lenta.md#ejercicio-15)

### 🟡 Ejercicio 16 — Cien páginas en `pg_stat_statements`

Recorre las primeras cien páginas del portal con `OFFSET` y lee lo que acumuló `pg_stat_statements`.

**Objetivo:** las 100 llamadas, el mínimo y el máximo, y los bloques totales.

[Solución](soluciones/14-la-base-no-estaba-lenta.md#ejercicio-16)

## 🟠 Difícil — bajo carga y en el otro motor (17–22)

### 🟠 Ejercicio 17 — Ocho clientes con `OFFSET`

Corre `portal_offset.pgbench` con ocho clientes durante 30 segundos y cuenta las páginas de más de 100 ms en el registro.

**Objetivo:** el promedio y la fracción que se cancelaría con ese límite.

[Solución](soluciones/14-la-base-no-estaba-lenta.md#ejercicio-17)

### 🟠 Ejercicio 18 — Ocho clientes con *keyset*

Lo mismo con `portal_keyset.pgbench`.

**Objetivo:** el promedio, las páginas por segundo, y la proporción contra `OFFSET`.

[Solución](soluciones/14-la-base-no-estaba-lenta.md#ejercicio-18)

### 🟠 Ejercicio 19 — El formulario con filtro

Mide en MySQL los bytes de las claves del formulario de protocolos filtrado a septiembre de 2026.

**Objetivo:** las claves y los bytes, contra los de la tabla entera.

[Solución](soluciones/14-la-base-no-estaba-lenta.md#ejercicio-19)

### 🟠 Ejercicio 20 — *Keyset* solo por fecha

Explica qué pasaría si la clave del *keyset* fuera solo `ordered_on`, con los protocolos del último día de la primera página.

**Objetivo:** cuántas filas comparten ese día, y cuántas se perderían.

[Solución](soluciones/14-la-base-no-estaba-lenta.md#ejercicio-20)

### 🟠 Ejercicio 21 — *Keyset* en MySQL

Mide en MySQL la página con la comparación de filas y con `OR`.

**Objetivo:** 1,32 millones de entradas contra 20, y por qué.

[Solución](soluciones/14-la-base-no-estaba-lenta.md#ejercicio-21)

### 🟠 Ejercicio 22 — `OFFSET` en MySQL

Mide la página 50.000 en MySQL con `LIMIT 999980, 20`.

**Objetivo:** el plan y el tiempo, contra el de Postgres.

[Solución](soluciones/14-la-base-no-estaba-lenta.md#ejercicio-22)

## 🔴 Muy difícil — decidir (23–26)

### 🔴 Ejercicio 23 — Lo que había que comprar en 2014

Con las mediciones de esta fase, decide en qué se habría gastado mejor el dinero de la licencia de 2014, si la licencia no hubiera
hecho falta por el techo de 10 GB.

**Objetivo:** la decisión, con la pantalla que cada gasto arreglaba y la que no.

[Solución](soluciones/14-la-base-no-estaba-lenta.md#ejercicio-23)

### 🔴 Ejercicio 24 — ¿Está lenta la base?

Una pantalla tarda 4 s. `pg_stat_statements`, en la misma ventana, suma 0,3 s para las consultas de esa pantalla. Diagnostica.

**Objetivo:** el diagnóstico, y las dos mediciones que lo confirmarían.

[Solución](soluciones/14-la-base-no-estaba-lenta.md#ejercicio-24)

### 🔴 Ejercicio 25 — "Ir a la página"

El portal de pacientes necesita "ir a la página 37". Diseña una paginación que lo permita sin el costo de `OFFSET`.

**Objetivo:** el diseño, con lo que cuesta mantenerlo.

[Solución](soluciones/14-la-base-no-estaba-lenta.md#ejercicio-25)

### 🔴 Ejercicio 26 — `Protocolos` sobre `legacy`

Corre en MySQL el formulario como Access sobre `legacy.Protocolos`, la tabla de la caja, sin la copia de staging, y compara.

**Objetivo:** los viajes, las filas y los bytes, y si cambian.

[Solución](soluciones/14-la-base-no-estaba-lenta.md#ejercicio-26)

---

## 📚 15. Referencias

**Documentación oficial**

- **`pg_stat_statements`** — https://www.postgresql.org/docs/18/pgstatstatements.html
- **`LIMIT` y `OFFSET`** — https://www.postgresql.org/docs/18/queries-limit.html — "las filas que se saltean igual se
  calculan".
- **`pgbench`** — https://www.postgresql.org/docs/18/pgbench.html — scripts propios y `--log`.
- **Variables de estado de MySQL 9.7** — https://dev.mysql.com/doc/refman/9.7/en/server-status-variables.html — `Bytes_sent`.
- **Optimización de comparaciones de filas en MySQL** — https://dev.mysql.com/doc/refman/9.7/en/row-constructor-optimization.html
- **La cláusula de límite de filas en Oracle** — https://docs.oracle.com/en/database/oracle/oracle-database/23/sqlrf/SELECT.html

**Artículos, papers y libros**

- **Mike Wolfe, "How Access Reads Data From SQL Server", *No Longer Set*, 2022** —
  https://nolongerset.com/how-access-reads-data-from-sql-server/ — las claves primero y las filas de a diez, observado con el
  Profiler. Remite al *white paper* de Andy Baron, "Optimizing Microsoft Office Access Applications Linked to SQL Server" (2006).
- **Markus Winand, "We need tool support for keyset pagination"** — https://use-the-index-luke.com/no-offset — `OFFSET` contra
  *keyset*, en todos los motores.

**Orden de lectura sugerido:** Wolfe antes de la sección 5.1; Winand antes de la 5.4.

> ⚠️ Las URL y sus contenidos cambian. Se consultaron el 14/10/2026.

---

## 🏁 16. Resultado de la fase

```text
EL CABLE · frontal de 2011 simulado contra la caja
  formulario como Access     7 viajes · 1.327.682 filas · 17,3 MB · 60 mostradas (22.128×)
  N+1                        61 viajes contra 2 · 73,6 contra 34,6 kB
  join en el cliente         242.427 pacientes para 249 · 33 MB
  en la VPN (cuenta)         35 s · 2 s · 66 s, contra 0,04 · 0,13 · 0,10 s
EL PORTAL
  página 50.000              OFFSET 878.758 bloques · keyset 21
  ocho clientes              OFFSET 130 ms y 61 % sobre 100 ms · keyset 0,15 ms y 0 %
  MySQL                      keyset con comparación de filas 1.169 ms · con OR 0,45 ms
```

### 💀 Boss del Bloque II — El portal de 2018

> *"En 2018 un chico de sistemas le restó uno a un número y se llevó catorce mil informes, serologías incluidas. La corrección
> que pidió la agencia fue poner el MD5 del número en la URL, y el curso ya les mostró lo que vale eso: con un diccionario de
> cuatro millones de números se revierte todo en siete segundos. El portal nuevo sale con la base nueva, y quiero dos cosas
> firmadas antes de que salga. Que ningún informe se pueda abrir con un enlace que alguien pueda calcular, y que los enlaces que
> mandamos por mail desde 2018 dejen de abrir informes sin dejar de responder, porque hay médicos que los tienen guardados. Y
> que la página del médico derivante no se traiga la tabla entera para mostrarle veinte protocolos: hoy cada página lee un
> millón trescientas mil filas, y el día que un médico con mil protocolos pase la página cincuenta, me llaman a mí. Si esto sale mal,
> la agencia abre otra actuación, y la próxima no la paga la clínica: la paga Horizonte."*
>
> — **Verónica Colombo**, gerenta de datos de Horizonte

**El sistema roto.** `src/14-la-base-no-estaba-lenta/boss/01_portal_2018.sql` arma `staging.portal_2018`, el portal como quedó
en 2018, y muestra lo que ve Verónica: un informe se abre leyendo 17.856 bloques (la tabla no tiene índice por enlace); el script
del estudiante, con MD5, alcanza 100 de los 100 informes que siguen a uno conocido; y cada página del médico 144 lee unos 17.900
bloques, más otro tanto para su `count(*)`.

**Lo que se entrega**, en una transacción:

1. **Un enlace por informe que no se pueda calcular**: ni secuencial, ni derivado del número, ni con la fecha adentro (Fase 10).
2. **Los enlaces de 2018, vencidos**: cada uno responde que venció, y ninguno abre un informe. Ojo con los 3.902 números de
   protocolo repetidos de la Fase 10: en 2018, un mismo enlace abría dos informes.
3. **La página del médico derivante** paginada sin leer lo que no muestra, con su total, y con los índices que pide (Fases 11 y
   14).
4. **Las mediciones** de cada criterio, con `EXPLAIN (ANALYZE, BUFFERS)`.

**Criterios de aceptación:**

- el diccionario de la Fase 10 (el MD5 de todos los números de protocolo posibles, de las seis sedes) no alcanza ningún informe, y
  los cien vecinos de `C-0118696` tampoco;
- abrir un informe por su enlace lee 5 bloques o menos;
- la primera y la última página del médico 144 leen 25 bloques o menos cada una, y el total del médico, 10 o menos;
- los enlaces de 2018 están todos registrados como vencidos, y ninguno coincide con un enlace nuevo.

La solución de referencia no se publica: es un encargo, no un ejercicio.

> 🏆 **"Un martes", opcional.** Si vas armando la base nueva de Alameda bloque a bloque, el Bloque II te deja sus decisiones
> físicas: qué índices tiene cada tabla y por qué, las claves que no se pueden adivinar, las estadísticas que hay que programar,
> y las pantallas que piden lo que muestran. La facturación de un martes todavía no corre; el Bloque III trae lo que pasa cuando
> tres cajas la corren a la vez.

> **La señal de que quedó bien:** *"Antes de decir que la base está lenta, cuento los viajes y los bytes de la pantalla y miro
> `pg_stat_statements`; y ninguna lista mía lee las filas que no muestra."*

> 🏷️ **No cierres la fase sin el tag.** Con el checklist en verde y `git status` limpio:
>
> ```bash
> git tag -a fase-14-la-base-no-estaba-lenta -m "F14 cerrada: el frontal de 2011 medido en viajes y bytes, OFFSET contra keyset bajo carga, pg_stat_statements, y el boss II"
> ```
>
> Commits de la fase con prefijo `f14:`, los de ejercicio `f14 ej26: …`.
