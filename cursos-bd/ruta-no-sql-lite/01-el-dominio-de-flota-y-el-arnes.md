# ✈️ Fase 01 — El dominio de flota y el arnés: montar el instrumento antes de medir nada

> **Curso:** Ruta NoSQL Lite · Fase 01 de 25 · Bloque 0 — El instrumento · **5 h**
> **Motor:** solo PostgreSQL 18.6 `pgvector/pgvector@sha256:2ba9ca5f2e7d…` (la línea base)
> **Entorno de ejecución:** TypeScript
> **Volumen:** 10 k para los ejemplos, `workOrder-1m` para las mediciones
> **Depende de:** Fase 00 · **Habilita:** Fase 02
> **Apéndices de apoyo:** [`a01`](a01-laboratorio-contenerizado.md), [`a02`](a02-compose-de-la-ruta.md),
> [`a05`](a05-el-dominio-de-flota.md), [`a06`](a06-lenguajes-y-drivers.md),
> [`a04`](a04-el-arnes-de-medida.md)
> **Fecha de verificación ejecutada:** 29/09/2026, en macOS arm64
> **Objetivo:** que cargues Cóndor en Postgres, midas la consulta de referencia y obtengas **el
> mismo número de filas examinadas que este documento**.

---

## 🧭 1. Dónde estamos

La [Fase 00](00-la-decision-que-se-hereda.md) dejó seis decisiones heredadas y cinco preguntas
anunciadas, y ni un solo número. Aquí empieza lo que distingue a este curso de un resumen de
documentación: **medir**. Pero antes de medir cualquier motor hay que montar el instrumento, y
calibrarlo contra algo que ya conoces.

Ese algo es Postgres. Es la última fase donde todo te va a resultar familiar —tablas, índices,
`EXPLAIN`—, y conviene aprovecharlo: es el terreno donde puedes comprobar que el arnés mide bien
antes de apuntarlo a un motor que no conoces. Si aquí el instrumento da un número que no
entiendes, en la Fase 04 no vas a saber si el raro es Mongo o el instrumento.

Al terminar tienes cuatro cosas que el resto del curso da por hechas: **el dominio de Cóndor
cargado** en el esquema de referencia, **la línea base de Postgres** con sus índices, **el arnés**
que cuenta lo que ningún motor reporta, y **la primera medición del curso** en la bitácora.

---

## 🎯 2. Objetivos de esta fase

1. Cargar `workOrder-1m` en Postgres con el hash del dataset comprobado antes de cargar.
2. Explicar por qué el esquema de referencia usa JSONB para lo polimórfico, y dónde.
3. Leer un `EXPLAIN (ANALYZE, BUFFERS)` de Postgres 18 campo por campo, incluidos los planes
   paralelos.
4. Calcular filas examinadas contra devueltas a partir de un plan, y obtener **1 000 081 contra
   122** sin índices y **145 contra 122** con ellos.
5. Contar viajes con el arnés y explicar por qué una lectura en N+1 cuesta **66 viajes** donde un
   `JOIN` cuesta uno.

---

## 🚫 3. Qué NO entra todavía

- **Ningún motor NoSQL, ninguna comparación.** Empiezan en la
  [Fase 03](03-documental-levantar-y-modelar.md).
- **Postgres a fondo** —JSONB con GIN, full-text, `pgvector`, `WITH RECURSIVE`, particionado—:
  está en [`a07`](a07-postgres-linea-base.md), que se escribe con las fases 03 y 04.
- **El volumen de rotura.** Cada fase B calibra el suyo.
- **La métrica de cada motor.** Cómo se pide el plan en Mongo, Cassandra o Neo4j crece en
  [`a04`](a04-el-arnes-de-medida.md) con cada familia.

---

## 🧰 4. El instrumento

### 4.1 El dominio en doce tablas

Las diez entidades de [`a05`](a05-el-dominio-de-flota.md) se vuelven doce tablas. Las dos de más
salen de relaciones que el dataset canónico trae anidadas dentro de `workOrder`: quién trabajó
en cada orden (`work_order_technician`) y qué se instaló o retiró en cada una
(`work_order_movement`). El esquema completo está en
`src/01-el-dominio-de-flota-y-el-arnes/schema.sql`; aquí, las decisiones que conviene entender.

**Lo que todos tienen en común va en columnas; lo que cambia según el tipo va en JSONB.** Una
aeronave tiene matrícula, modelo y base, siempre. Pero un helicóptero tiene cabeza de rotor y
gancho de carga, y un turbohélice tiene radar y puerta de carga. Eso es `options`:

```sql
CREATE TABLE aircraft (
  registration        text PRIMARY KEY,
  model               text NOT NULL,
  base_hangar_id      text NOT NULL REFERENCES hangar,
  -- …
  -- lo polimórfico: un helicóptero y un turbohélice no comparten estos campos
  options             jsonb NOT NULL
);
```

Lo mismo con `part.details`: calibración en un instrumento, recauchados en una llanta, ciclos en
un motor. **Esta es la línea base bien jugada**, la que pondría hoy alguien con oficio. No son las
cuarenta columnas anulables de `SIGMA` ni su tabla de atributos adicionales. La guía lo pide sin
matices: **ganarle a una línea base mal puesta no demuestra nada**, y en la
[Fase 04](04-documental-romper-y-medir.md) Mongo compite contra este esquema, no contra el de
2015.

**La trazabilidad sale de una tabla, no de una columna.** `work_order_movement` guarda cada pieza
que una orden retiró o instaló, con su posición y su destino. Qué pieza estuvo en qué aeronave y
cuándo se reconstruye desde aquí, y es exactamente la pregunta de las
[Fases 13–14](13-grafos-levantar-y-modelar.md).

**Los nombres, en `snake_case`.** El dataset canónico viene en `camelCase` y el cargador lo
traduce: `workOrderId` pasa a `work_order_id`. La incoherencia entre familias es deliberada y
está explicada en [`a08`](a08-diccionario-y-glosario.md).

**Los índices, aparte.** `schema.sql` solo tiene claves primarias y foráneas; los índices
secundarios están en `indexes.sql`, porque esta fase mide la misma consulta sin ellos y con
ellos.

### 4.2 Levantar y cargar

Tres comandos, desde la raíz del curso. El laboratorio y su perfil `base` son de
[`a02`](a02-compose-de-la-ruta.md); el generador, de [`a05`](a05-el-dominio-de-flota.md); el
entorno de Node, de [`a06`](a06-lenguajes-y-drivers.md).

```bash
cd src/lab && docker compose --profile base up -d --wait && cd ..
node lab/generator/src/generate.ts --focus workOrder --volume 1m
node 01-el-dominio-de-flota-y-el-arnes/load.ts --dataset lab/data/workOrder-1m
```

```text
dataset workOrder-1m · generador 1.0.0 · datasetSha256 11a67c65fb22fdc9… verificado
  hangar                         6 filas
  technician                   908 filas
  supplier                      60 filas
  part_catalog             1481481 filas
  aircraft                    2593 filas
  part                      740741 filas
  assembly                   11070 filas
  pirep                     218519 filas
  work_order               1000000 filas
  work_order_technician    1988925 filas
  work_order_movement      1247472 filas
  reading                   200000 filas
cargado en 159.1 s · 1732 viajes a Postgres (lotes de 5000)
```

Dos cosas de esa salida importan más que los segundos.

**La primera línea.** Antes de tocar la base, el cargador recalcula el SHA-256 de cada archivo y
lo compara con el manifiesto. Si tu `datasetSha256` empieza por `11a67c65fb22`, tu dataset es
byte a byte el de este documento, y los números de las secciones siguientes tienen que
coincidir con los tuyos. Si no es así, el cargador no carga nada (ver Errores comunes).

**La última.** Cerca de 7 millones de filas en **1732 viajes**, porque el cargador manda cada lote
de 5000 registros en un solo `INSERT … SELECT FROM jsonb_to_recordset($1)`: el lote entero viaja
como un parámetro. Con un `INSERT` por fila habrían sido unos 7 millones de viajes. Es la primera
vez que el curso cuenta viajes, y no será la última.

La base ocupa **1317 MB** en disco con los índices de referencia.

### 4.3 La consulta de referencia

La pregunta que Yamile contesta a mano cada semana: **qué se le hizo a una aeronave en un
trimestre, con lo que se instaló y retiró en cada orden**.

```sql
SELECT wo.work_order_id, wo.opened_at, wo.type, m.kind, m.serial_number, m.position
FROM work_order wo
LEFT JOIN work_order_movement m ON m.work_order_id = wo.work_order_id
WHERE wo.aircraft = $1 AND wo.opened_at >= $2 AND wo.opened_at < $3
ORDER BY wo.opened_at, m.kind, m.serial_number;
```

La aeronave no se elige a mano: es la que más órdenes tiene en el primer trimestre de 2025, con
desempate por matrícula. Con el dataset del curso es la **`HK-12372`**, con **65 órdenes y 122
filas** devueltas. Cualquiera que cargue el mismo dataset obtiene la misma.

### 4.4 `EXPLAIN (ANALYZE, BUFFERS)`, campo por campo

`EXPLAIN` a secas te dice qué **piensa** hacer Postgres. `ANALYZE` lo **ejecuta** y te dice lo que
hizo. `BUFFERS` añade cuántos bloques de 8 kB tocó; desde Postgres 18 va incluido con `ANALYZE`,
pero en este curso se escribe igual, para que la consulta diga lo que pide. Siempre los tres. Con
los índices de referencia:

```text
 Incremental Sort  (cost=18.87..325.85 rows=22 width=60) (actual time=0.186..0.700 rows=122.00 loops=1)
   Sort Key: wo.opened_at, m.kind, m.serial_number
   Presorted Key: wo.opened_at
   Buffers: shared hit=296
   ->  Nested Loop Left Join  (cost=0.85..325.00 rows=22 width=60) (actual time=0.035..0.633 rows=122.00 loops=1)
         Buffers: shared hit=287
         ->  Index Scan using work_order_aircraft_opened_at on work_order wo  (cost=0.42..76.83 rows=18 width=27) (actual time=0.020..0.232 rows=65.00 loops=1)
               Index Cond: ((aircraft = 'HK-12372'::text) AND (opened_at >= '2025-01-01 00:00:00+00'::timestamp with time zone) AND (opened_at < '2025-04-01 00:00:00+00'::timestamp with time zone))
               Index Searches: 1
               Buffers: shared hit=67
         ->  Index Scan using work_order_movement_pkey on work_order_movement m  (cost=0.43..13.75 rows=4 width=44) (actual time=0.006..0.006 rows=1.23 loops=65)
               Index Cond: (work_order_id = wo.work_order_id)
               Index Searches: 65
               Buffers: shared hit=220
 Execution Time: 0.765 ms
```

Se lee de adentro hacia afuera, y cada nodo tiene dos paréntesis.

**El primer paréntesis es la estimación.** `rows=18` en el `Index Scan` de `work_order` es lo que
el planificador **esperaba** encontrar. `cost` es una unidad interna del planificador, no son
milisegundos: sirve para comparar planes entre sí, no para nada más.

**El segundo paréntesis es lo que pasó.** `rows=65.00 loops=1`: el índice devolvió 65 órdenes en una
pasada. El planificador esperaba 18. Esa diferencia no rompe este plan, pero cuando la estimación
se equivoca por órdenes de magnitud, es la primera pista de por qué Postgres eligió un plan
malo.

**`loops` multiplica.** El `Index Scan` de `work_order_movement` dice `rows=1.23 loops=65`: se
ejecutó **una vez por cada orden** —es el lado interno del `Nested Loop`— y devolvió en promedio
1,23 filas por vuelta. En total, 1,23 × 65 ≈ 80 movimientos. **`rows` es un promedio por vuelta, y
desde Postgres 18 lleva decimales**; antes se mostraba como entero, y ese redondeo escondía justo
lo que aquí se ve.

**`Index Cond` contra `Filter`.** `Index Cond` es la condición que el índice resolvió
directamente: las filas que no la cumplen ni se leyeron. Un `Filter`, cuando aparece, es una
condición que se comprobó **después** de leer la fila, y las descartadas se cuentan en
`Rows Removed by Filter`. Esa línea es la que delata una consulta cara.

**`Index Searches`**, también nuevo en Postgres 18, cuenta cuántas veces se bajó por el árbol del índice:
1 para las órdenes y 65 para los movimientos, uno por orden.

**`Buffers: shared hit=287`**: 287 bloques de 8 kB leídos, todos de la caché (`hit`). Si alguno
hubiera venido de disco, aparecería como `read`.

**Lo que no se mira:** `actual time` y `Execution Time`. Son reales, pero dependen de la máquina,
de la caché y de lo que haya arriba. Son contexto, nunca argumento.

Ahora el mismo plan **sin** el índice `work_order_aircraft_opened_at`:

```text
 Gather Merge  (cost=32065.13..32067.69 rows=22 width=60) (actual time=27.975..30.171 rows=122.00 loops=1)
   Workers Planned: 2
   Workers Launched: 2
   Buffers: shared hit=1762 read=22155
   ->  Sort  (…) (actual time=25.937..25.941 rows=40.67 loops=3)
         ->  Nested Loop Left Join  (…) (actual time=16.741..25.899 rows=40.67 loops=3)
               ->  Parallel Seq Scan on work_order wo  (cost=0.00..30954.67 rows=8 width=27) (actual time=16.662..25.659 rows=21.67 loops=3)
                     Filter: ((opened_at >= '2025-01-01 00:00:00+00'::timestamp with time zone) AND (opened_at < '2025-04-01 00:00:00+00'::timestamp with time zone) AND (aircraft = 'HK-12372'::text))
                     Rows Removed by Filter: 333312
                     Buffers: shared hit=1508 read=22155
               ->  Index Scan using work_order_movement_pkey on work_order_movement m  (…) (actual time=0.010..0.010 rows=1.23 loops=65)
```

Sin índice, Postgres lee la tabla entera, y la reparte entre **tres procesos**: el principal y los
dos `Workers Launched`. Por eso el `Parallel Seq Scan` dice `loops=3`, y aquí está la trampa del
campo más importante: **en un nodo paralelo, `rows` y `Rows Removed by Filter` son promedios por
proceso**. `Rows Removed by Filter: 333312` no son las filas descartadas: son las descartadas **por
cada uno de los tres**. En total, (21,67 + 333 312) × 3 ≈ 1 000 001: **el millón de órdenes, leído
entero para devolver 65**. Y `read=22155`: esta vez la mayoría de los bloques vinieron de disco.

### 4.5 Filas examinadas contra devueltas: el cociente

El curso resume un plan en dos números: **filas examinadas** —las que leyeron los nodos de acceso,
incluidas las que el filtro descartó— y **filas devueltas**. Lo que importa es el cociente, no el
total: una consulta que examina 1000 filas para devolver 1000 está bien; una que examina 1000 para
devolver una, no.

El arnés los calcula leyendo el plan en JSON (`src/lab/harness/explain.ts`): suma, en cada nodo de
acceso, `(Actual Rows + Rows Removed by Filter) × Actual Loops`. Así ya viene incluida la trampa
de los nodos paralelos, y el redondeo de los decimales de Postgres 18.

| | filas examinadas | devueltas | cociente | bloques |
|---|---|---|---|---|
| sin índices secundarios | 1 000 081 | 122 | 8197,4 | 23 937 |
| con los índices de referencia | 145 | 122 | 1,2 | 287 |

**Un índice compuesto `(aircraft, opened_at)` convierte un millón de filas examinadas en 145.**
Nada de esto es nuevo para ti, y es justamente el punto: acabas de comprobar que el instrumento
mide bien lo que ya sabías. A partir de la Fase 03 va a medir lo que no sabes.

> 🩻 **Esto sí funciona igual en todo el curso.** Un índice sigue siendo un índice, un plan sigue
> siendo un plan y una lectura sin índice sigue siendo cara. Lo que cambia de familia en familia es
> **dónde se mira**: `totalDocsExamined` en Mongo, `TRACING ON` en Cassandra, `PROFILE` en Neo4j.
> Esa tabla crece en [`a04`](a04-el-arnes-de-medida.md).

### 4.6 Los viajes: lo que ningún motor te cuenta

Ningún `EXPLAIN` dice cuántas veces tu programa habló con la base. Se cuenta **en el cliente**, y
por eso es lo primero que el arnés instrumenta: `countRoundTrips` envuelve el método `query` del
driver y suma uno por llamada (`src/lab/harness/roundtrips.ts`).

La misma información, pedida de dos maneras:

- **Con el `JOIN` de la consulta de referencia: 1 viaje.**
- **Las órdenes primero y después los movimientos de cada una, con un `SELECT` por orden: 66
  viajes.** Una consulta para las 65 órdenes y 65 para sus movimientos.

Es el N+1 de toda la vida. Lo que le interesa a este curso es que **ese 66 no aparece en ningún
plan**: cada una de las 66 consultas tiene un plan perfecto, con índice y cociente de 1. El costo
está entre las consultas, no dentro de ellas. Cuando en la Fase 03 veas que una ficha referenciada
en Mongo necesita 3 + N viajes, lo vas a reconocer.

### 4.7 La prueba de fuego

```bash
node 01-el-dominio-de-flota-y-el-arnes/reference-query.ts --dataset lab/data/workOrder-1m
```

```text
aeronave HK-12372 · 2025-01-01 a 2025-04-01 · 65 órdenes · 122 filas devueltas

sin índices: examinadas 1000081 · devueltas 122 · cociente 8197.4 · bloques 23937
   Seq Scan on work_order
   Index Scan on work_order_movement using work_order_movement_pkey
con índices: examinadas 145 · devueltas 122 · cociente 1.2 · bloques 287
   Index Scan on work_order using work_order_aircraft_opened_at
   Index Scan on work_order_movement using work_order_movement_pkey
viajes: JOIN 1 · N+1 66
```

**Tu salida tiene que decir exactamente 1000081, 145, 122 y 66.** Se verificó tres veces el
29/09/2026, dos de ellas con la base borrada y cargada desde cero, y los cuatro números salieron
idénticos. **Los bloques no**: sin índices fueron 23 937 en las dos primeras y 23 938 en la
tercera. Por eso no forman parte de la prueba: dependen de cómo quedaron las páginas en disco, y
eso no lo fija el dataset. Si los tuyos no coinciden, **el arnés o el dataset están mal, y el
curso entero se cae**: todo lo que se mida después hereda ese error. Vuelve al hash de la
sección 4.2 antes de seguir.

El script termina imprimiendo la ficha de la primera medición del curso, que entra en la
[bitácora](bitacora-de-medicion.md) como **M-01**:

> 📐 **M-01 — órdenes de una aeronave en un trimestre, con sus movimientos** · workOrder-1m
> (`11a67c65fb22…`) · PostgreSQL 18.6 `pgvector/pgvector@sha256:2ba9ca5f2e7d…` · verificado el
> 29/09/2026
>
> |  | filas examinadas | devueltas | viajes |
> |---|---|---|---|
> | sin índices secundarios | 1000081 | 122 | 1 |
> | con los índices de referencia | 145 | 122 | 1 |
> | con índices, en N+1 | — | 122 | 66 |
>
> Reproducir: `node 01-el-dominio-de-flota-y-el-arnes/reference-query.ts --dataset lab/data/workOrder-1m`

---

## 🐘 5. Casi siempre gana Postgres

Lo que acabas de montar es el rival de todo el curso, y conviene decir desde ya qué trae: JSONB
para lo que no tiene los mismos campos, índices compuestos, planes que se pueden leer, y
`pg_stat_statements` para contar consultas desde el servidor (la librería la precarga el
laboratorio y `schema.sql` crea la extensión). Con los
índices de referencia, la pregunta más común del taller se resuelve examinando 145 filas.

Cada fase B va a comparar su motor contra **este** Postgres, con su mejor configuración razonable
para ese caso ([`a07`](a07-postgres-linea-base.md)), y cuando gane Postgres se va a escribir así.
La pregunta del curso nunca es *"¿puede otro motor hacer esto?"*, sino **"¿hace falta?"**.

---

## ⚠️ 6. Errores comunes y diagnóstico

**Postgres no está arriba.** Olvidaste el perfil `base`, o el contenedor se apagó:

```text
AggregateError [ECONNREFUSED]:
  code: 'ECONNREFUSED',
  [errors]: [
    Error: connect ECONNREFUSED ::1:15432
```

🩺 `docker compose ps` desde `src/lab`. Fíjate en que el cargador **ya había verificado el
dataset** antes de fallar: la verificación no necesita la base.

**El dataset no es el del curso.** Un solo campo cambiado en un archivo:

```text
Error: workOrder.ndjson: el hash no coincide con el manifiesto (0c2d14da68a3 ≠ fe139626e58b)
```

🩺 Regenera con el mismo comando y compara tu `datasetSha256` con la tabla de
[`a05`](a05-el-dominio-de-flota.md). El cargador se niega a cargar a propósito: una medición sobre
otros datos no se puede comparar con las del curso.

**Un lote hijo antes que su padre.** Si escribes tu propio cargador por lotes, este es el error
que te espera (lo cometió el de esta fase en su primera versión):

```text
error: insert or update on table "work_order_technician" violates foreign key constraint "work_order_technician_work_order_id_fkey"
detail: 'Key (work_order_id)=(WO-0000001) is not present in table "work_order".'
```

Cada orden tiene varios técnicos, así que el lote de `work_order_technician` se llena antes que
el de `work_order` y se envía primero. 🩺 El `detail` nombra la clave que falta en la tabla padre.
La salida: cuando se llena el lote de cualquier tabla, se vacían todas, **en orden de
dependencia**.

**Tus números no coinciden y el hash sí.** Mira `access` en la salida: si ves `Seq Scan` donde este
documento dice `Index Scan`, los índices no se crearon, o te falta el `ANALYZE` del final de
`indexes.sql`.

**El script no termina.** Una conexión quedó abierta. Está explicado en
[`a06`](a06-lenguajes-y-drivers.md).

---

## 📋 7. Checklist de validación

```text
[ ] docker compose ps muestra base (healthy)
[ ] Mi datasetSha256 de workOrder-1m empieza por 11a67c65fb22
[ ] load.ts cargó 1 000 000 de work_order y 1 247 472 de work_order_movement
[ ] reference-query.ts elige la aeronave HK-12372 y devuelve 122 filas
[ ] Sin índices: 1 000 081 filas examinadas; con índices: 145
[ ] Viajes: 1 con JOIN y 66 en N+1
[ ] Sé leer rows, loops, Filter, Rows Removed by Filter y Buffers en un plan paralelo
[ ] La ficha M-01 está en la bitácora
```

---

## 🧪 8. Ejercicios (22)

Todos se ejecutan contra la base cargada con `workOrder-1m`, salvo donde se indique.

### 🟢 Fácil — cargar y leer (1–7)

#### 🟢 Ejercicio 1 — Tu hash

Genera `workOrder-1m` y compara tu `datasetSha256` con el de la sección 4.2.

**Objetivo:** saber si tus mediciones van a ser comparables con las del curso antes de medir nada.

#### 🟢 Ejercicio 2 — Cargar 10 k

Carga `workOrder-10k` y anota cuántas filas tiene cada tabla y cuántos viajes hizo el cargador.

**Pregunta:** ¿por qué `work_order_technician` tiene más filas que `work_order`?

#### 🟢 Ejercicio 3 — La prueba de fuego

Ejecuta `reference-query.ts` sobre `workOrder-1m`.

**Objetivo:** obtener 1000081, 145, 122 y 66. Si alguno no coincide, encontrar por qué antes de
seguir.

#### 🟢 Ejercicio 4 — Las opciones de una aeronave

Consulta `options` de tres aeronaves de tipos distintos (`kind`).

**Pregunta:** ¿qué claves tiene cada una que las otras no tienen? ¿Cuántas columnas anulables
habría necesitado `SIGMA` para guardarlas?

#### 🟢 Ejercicio 5 — Un plan a mano

Pide en `psql` el `EXPLAIN (ANALYZE, BUFFERS)` de la consulta de referencia para otra aeronave y
otro trimestre.

**Objetivo:** señalar en tu plan la estimación, lo real, `loops` y los bloques de cada nodo.

#### 🟢 Ejercicio 6 — Estimado contra real

En tu plan del ejercicio 5, compara `rows` estimado y real en cada nodo.

**Pregunta:** ¿en qué nodo se equivoca más el planificador, y por cuánto?

#### 🟢 Ejercicio 7 — Los viajes del cargador

Carga `workOrder-10k` con `--batch 500` y con `--batch 5000`.

**Pregunta:** ¿cuántos viajes hace cada uno, y qué fórmula los predice?

### 🟡 Intermedio — medir (8–14)

#### 🟡 Ejercicio 8 — Otro índice, otra pregunta

Mide con `explain.ts` la historia de una pieza: todos los movimientos de un `serial_number`, sin
el índice `work_order_movement_serial` y con él.

**Objetivo:** filas examinadas contra devueltas en los dos casos, con el cociente.

#### 🟡 Ejercicio 9 — El orden del índice compuesto

Crea `(opened_at, aircraft)` en lugar de `(aircraft, opened_at)` y repite la consulta de referencia.

**Pregunta:** ¿cuántas filas examina ahora y por qué? **Predice el número antes de ejecutar.**

#### 🟡 Ejercicio 10 — El trimestre entero

Quita el filtro por aeronave y mide las órdenes del trimestre de toda la flota.

**Pregunta:** ¿sigue usando el índice? ¿Por qué el cociente examinadas/devueltas puede ser bueno
aunque examine mucho?

#### 🟡 Ejercicio 11 — El paralelo, a mano

En el plan sin índice, calcula las filas examinadas del `Parallel Seq Scan` a partir de `rows`,
`Rows Removed by Filter` y `loops`.

**Objetivo:** llegar a ≈ 1 000 001 y explicar por qué usar solo `Rows Removed by Filter` da un
tercio.

#### 🟡 Ejercicio 12 — N+1 en otra consulta

Escribe con el arnés una lectura de las 10 aeronaves con más órdenes y sus pireps: primero en N+1
y después con un `JOIN`.

**Objetivo:** contar los viajes de cada versión con `countRoundTrips`.

#### 🟡 Ejercicio 13 — Lo que cuenta el servidor

Con `pg_stat_statements`, busca cuántas veces se ejecutó la consulta de movimientos del N+1.

**Pregunta:** ¿coincide con el contador del arnés? ¿Qué cuenta cada uno que el otro no ve?

#### 🟡 Ejercicio 14 — JSONB con índice

Busca las aeronaves con `options->>'weatherRadar' = 'true'`, primero sin índice y después con un
índice GIN sobre `options`.

**Objetivo:** filas examinadas contra devueltas en los dos casos. (JSONB a fondo está en
[`a07`](a07-postgres-linea-base.md).)

### 🟠 Difícil — diagnosticar (15–19)

#### 🟠 Ejercicio 15 — El índice que no se usa

Crea un índice sobre `work_order (type)` y busca las órdenes de tipo `routine`.

**Pregunta:** ¿lo usa el planificador? Si no, ¿qué campo del plan te dice por qué no le conviene?

#### 🟠 Ejercicio 16 — Sin `ANALYZE`

Recarga la base, crea los índices **sin** el `ANALYZE` final y ejecuta la consulta de referencia.

**Pregunta:** ¿cambia el plan o el número de filas examinadas? Compara las estimaciones con las de
la sección 4.4.

#### 🟠 Ejercicio 17 — La caché

Ejecuta dos veces seguidas la consulta sin índice y compara `hit` y `read` en `Buffers`.

**Objetivo:** explicar por qué los bloques cambian de `read` a `hit` y por qué el número de filas
examinadas no cambia.

#### 🟠 Ejercicio 18 — La trazabilidad de una pieza

Con `work_order_movement`, reconstruye las aeronaves por las que pasó un número de serie del lote
`LOT-2022-117` (su respuesta está en `answers.json`).

**Objetivo:** que tu consulta devuelva las mismas aeronaves que `answers.json`, y medir sus filas
examinadas. Guárdala: la Fase 14 la retoma.

#### 🟠 Ejercicio 19 — Un cargador fila a fila

Modifica una copia de `load.ts` para que inserte fila a fila y carga `workOrder-10k`.

**Pregunta:** ¿cuántos viajes hace? Extrapola a `workOrder-1m` sin ejecutarlo y explica por qué el
número de viajes es la métrica, y no los segundos.

### 🔴 Muy difícil — el instrumento (20–22)

#### 🔴 Ejercicio 20 — El arnés miente

Escribe una consulta donde `explain.ts` cuente mal las filas examinadas: un tipo de nodo que no
termine en `Scan`, o uno que examine filas sin reportarlas en `Rows Removed by Filter`.

**Objetivo:** encontrar el límite del arnés y proponer la corrección. Si la encuentras, es una
contribución al curso.

#### 🔴 Ejercicio 21 — Dos máquinas, un número

Ejecuta la prueba de fuego en otra máquina u otra plataforma (Linux, WSL2).

**Pregunta:** ¿qué números tienen que coincidir exactamente, cuáles pueden cambiar, y por qué los
bloques no son una garantía aunque aquí coincidieran?

#### 🔴 Ejercicio 22 — La consulta de Yamile

Yamile quiere, para cada aeronave, cuántas piezas se le cambiaron en el último año y cuánto costaron.

**Objetivo:** escribir la consulta, medirla y decidir con los números si hace falta un índice nuevo.
Justifica la decisión con el cociente, no con el tiempo.

---

## 📚 9. Referencias

> ⚠️ Las URLs y sus contenidos cambian, y la documentación suele cubrir solo la última versión. Esta
> fase se verificó con PostgreSQL 18.6.

- **Using EXPLAIN** — https://www.postgresql.org/docs/current/using-explain.html — el capítulo
  oficial; léelo entero antes del ejercicio 5.
- **EXPLAIN** — https://www.postgresql.org/docs/current/sql-explain.html — las opciones `ANALYZE`,
  `BUFFERS` y `FORMAT JSON`.
- **pg_stat_statements** — https://www.postgresql.org/docs/current/pgstatstatements.html — contar
  consultas desde el servidor.
- **Markus Winand, *Use The Index, Luke*** — https://use-the-index-luke.com/ — el orden de las
  columnas en un índice compuesto, que es el ejercicio 9.
- **Notas de la versión 18** — https://www.postgresql.org/docs/release/18.0/ — los recuentos con
  decimales, `Index Searches` y `BUFFERS` por defecto en `EXPLAIN ANALYZE`.
- **jsonb_to_recordset** — https://www.postgresql.org/docs/current/functions-json.html — la
  función que usa el cargador para mandar un lote en un viaje.

**Orden sugerido:** *Using EXPLAIN* antes de la sección 4.4; *Use The Index, Luke* antes del
ejercicio 9; `pg_stat_statements` en el ejercicio 13.

---

## 🏁 10. Resultado de la fase

Tienes Cóndor cargado en su esquema de referencia, una línea base de Postgres bien jugada, un arnés
que cuenta filas examinadas y viajes, y la primera entrada de la bitácora. Y comprobaste que el
instrumento mide bien donde ya sabías la respuesta, que es el único sitio donde se puede calibrar.

> **La señal de que quedó bien:** *"Obtuve 1000081, 145, 122 y 66, y sé explicar de dónde sale cada
> uno sin mirar este documento."*

> 🏷️ **Tag:** `fase-01-el-dominio-de-flota-y-el-arnes` · prefijo de commit `f01:`
