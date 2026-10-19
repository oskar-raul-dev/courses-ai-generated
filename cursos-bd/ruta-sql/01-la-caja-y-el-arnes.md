# 📦 Fase 01 — La caja y el arnés: Alameda cargada tal cual, y el instrumento calibrado

> **Curso:** Ruta SQL · Fase 01 de 27 · Bloque 0 — El instrumento · **5 h**
> **Motores:** PostgreSQL `pgvector/pgvector@sha256:2358fcba361e…` · MySQL `mysql@sha256:e2bde46db656…`
> · Oracle `gvenzl/oracle-free@sha256:f5ff19033860…` (estructura, sin números); las versiones, en
> [`a02`](a02-compose-de-la-ruta.md#-las-versiones-del-curso)
> **Entorno de ejecución:** SQL + Python
> **Depende de:** Fase 00 · **Habilita:** Fase 02
> **Apéndices de apoyo:** a01, a02, a03, a04, a05, a06
> **Fecha de verificación ejecutada:** 12/10/2026, con los perfiles S y M
> **Objetivo:** tener la caja de Alameda cargada sin limpiar en los tres motores, leer su forma desde
> el catálogo y desde un plan, y demostrar que el arnés cuenta lo mismo que el generador.

---

## 🧭 1. Dónde estamos

La [Fase 00](00-la-base-que-nadie-diseno.md) contó Alameda sin un solo número. Esta fase pone los
números sobre la mesa: levanta el laboratorio, carga **la caja** —la carpeta que Matías armó un
sábado a la noche— en Postgres, MySQL y Oracle, y calibra el instrumento con el que se va a medir
todo el curso.

Hay una regla que manda en toda la fase y que va a costar: **nada se limpia**. La caja trae el DNI
dentro del nombre, fechas de nacimiento en el futuro y dos archivos en Latin-1, y así se carga. Si
algo se arregla antes de cargarlo, se pierde justamente lo que el curso va a medir.

---

## 🎯 2. Objetivos de esta fase

1. Levantar los tres motores y cargar la caja en el esquema `legacy`, entera en Postgres y por
   tablas en MySQL y Oracle.
2. Romper la carga con los archivos en Latin-1 y salir declarando la codificación, no tocando el
   archivo.
3. Contar desde el catálogo cuántas tablas tiene la caja, cuánto pesan y cuáles no tienen clave.
4. Leer un `EXPLAIN (ANALYZE, BUFFERS)` campo por campo, su equivalente en MySQL y la estructura de
   un plan de Oracle.
5. Pasar la prueba de fuego: el mismo número que declara el generador.

---

## 🚫 3. Qué NO entra todavía

- **Limpiar nada.** Ni el DNI del nombre, ni las comas de los resultados, ni las fechas imposibles.
  El Bloque I lo hace, y mide cuánto cuesta.
- **Índices nuevos.** `legacy` tiene solo las claves que tenía SQL Server. Los índices son del Bloque II.
- **El modelo nuevo.** El esquema `alameda` aparece en el Bloque I.

---

## 🏚️ 4. La caja, cargada y medida

### 4.1 El laboratorio, arriba

Desde `src/`, con Docker funcionando ([`a01`](a01-laboratorio-contenerizado.md)):

```text
$ uv run lab up base contraste oracle
→ docker compose --profile base --profile contraste --profile oracle up -d --wait
…
 Container alameda-lab-postgres-1 Healthy
 Container alameda-lab-mysql-1 Healthy
 Container alameda-lab-oracle-1 Healthy
```

Los tres perfiles, sus versiones y lo que ocupa cada uno están en
[`a02`](a02-compose-de-la-ruta.md). En esta fase solo importa que los tres digan `Healthy`.

### 4.2 La caja

La caja no viene en el repositorio: la fabrica el generador, siempre igual
([`a05`](a05-la-caja-y-el-generador.md)). Con la semilla del curso, el perfil M:

```text
$ uv run lab generate --profile m
Generando el perfil m con la semilla 1996 en …/src/lab/caja/m …
mundo: 200002 personas, 242427 filas de Pacientes, 1327622 protocolos (53 s)
…
Listo en 214 s: 200002 personas, 242427 filas de Pacientes, 1327622 protocolos, 12134453 filas de ResultadoItem.
SHA-256 de la caja: 3e59292e9918ee259e44c49c928d0b024686019fe070cc9fdca40a97fb2dd465
```

El hash es la garantía: si el tuyo es otro, tu caja no es la del curso. S, el perfil de todos los
días, empieza con `49cfb8db4194…`. Los dos están en la tabla de perfiles de
[`a05`](a05-la-caja-y-el-generador.md#-los-tres-perfiles), junto con lo que trae cada carpeta.

### 4.3 Cargar sin limpiar

`lab load` carga la caja en el esquema **`legacy`**, con **los nombres originales** (`legacy."Pacientes"`,
`legacy."Errores de pegado"`) y **texto donde el original tenía texto**: si SQL Server guardaba el DNI
como `nvarchar(50)`, aquí es `varchar(50)`, con sus puntos y sus espacios.

```text
$ uv run lab load --profile m
Cargando el perfil m (caja 3e59292e9918, semilla 1996) en postgres …
  legacy: 419 tablas (30 s)
  truth: 6 tablas (45 s)
  postgres: listo en 51 s
$ uv run lab load --profile m --engine mysql --tables Pacientes,Protocolos,ResultadoItem,Practicas
Cargando el perfil m (caja 3e59292e9918, semilla 1996) en mysql …
  mysql: 4 tablas en 38 s
```

Postgres la recibe entera; MySQL y Oracle, solo las tablas que pide cada fase. Al lado de `legacy`,
Postgres recibe **`truth`**: lo que el generador sabe y la caja no dice, para medir limpiezas más
adelante ([`a05`](a05-la-caja-y-el-generador.md#-la-verdad-del-generador)). Los tiempos son contexto,
de esta máquina.

> 💥 **El punto de rotura: los dos CSV en Latin-1.** `Pacientes.csv` y `Medicos.csv` salieron de
> `bcp` en Latin-1, "porque así salieron", dice el `LEEME.txt`. `lab load` lo declara. Esto es lo que
> pasa si no lo declaras, en los tres motores.

En **Postgres**, un `COPY` sin `ENCODING` en una base UTF-8:

```sql
-- postgres
CREATE TABLE public.pacientes_utf8 (LIKE legacy."Pacientes");
COPY public.pacientes_utf8 FROM '/caja/m/tablas/Pacientes.csv' WITH (FORMAT csv, HEADER true);
```

```text
ERROR:  invalid byte sequence for encoding "UTF8": 0xf1 0x6f 0x73 0x22
CONTEXT:  COPY pacientes_utf8, line 6
```

No se cayó con un `MUÑOZ`, como uno esperaría: se cayó en la línea 6, con `Edad`. La recepción
escribió `"43 años"` en un campo que el sistema nunca validó, y `0xF1 0x6F 0x73` es `ños` en Latin-1.
La primera eñe de la caja está en una edad.

En **MySQL**, un `LOAD DATA … CHARACTER SET utf8mb4` sobre el mismo archivo:

```text
ERROR 1366 (HY000) at line 4: Incorrect string value: '\xF1os' for column 'Edad' at row 5
```

La misma fila: MySQL cuenta las filas de datos desde 1, y Postgres, las líneas del archivo con el
encabezado.

En **Oracle**, una tabla externa con `CHARACTERSET AL32UTF8` **no da error**. Lee los bytes como
vienen, y el problema aparece después, al mostrarlos:

```text
SP2-0784: Invalid or incomplete character beginning 0xF1 returned
Help: https://docs.oracle.com/error-help/db/sp2-0784/
```

Y si en lugar de mirarla la copias a una tabla real, la copia se hace sin queja:

```text
BYTES
------------------------------------------------------------
Typ=1 Len=7: 34,33,20,61,f1,6f,73
```

Esos siete bytes son `43 años` en Latin-1, guardados tal cual en una base que dice ser UTF-8. **Postgres
y MySQL te detienen en la carga; Oracle te deja seguir con datos que no son lo que dicen.** El costo
aparece meses después, en un informe que no se puede imprimir.

**Cómo se sale, en los tres:** declarando la codificación del archivo. `ENCODING 'LATIN1'` en el `COPY`,
`CHARACTER SET latin1` en el `LOAD DATA`, `CHARACTERSET WE8ISO8859P1` en la tabla externa. Con eso, el
mismo `COPY` carga las 242.427 filas. **No se sale "limpiando" el archivo** con `iconv` antes de
cargarlo, y el ejercicio 21 muestra por qué: el archivo convertido ya no coincide con el manifiesto, y
deja de poder demostrar que es la caja del curso.

### 4.4 El primer recorrido, desde el catálogo

Antes de mirar una sola fila, el catálogo dice qué hay. En Postgres, `information_schema` y
`pg_class`:

```sql
-- postgres
SELECT count(*) AS tablas FROM information_schema.tables WHERE table_schema = 'legacy';

SELECT c.relname AS tabla, c.reltuples::bigint AS filas_estimadas,
       pg_size_pretty(pg_total_relation_size(c.oid)) AS tamano
FROM pg_class AS c
JOIN pg_namespace AS n ON n.oid = c.relnamespace
WHERE n.nspname = 'legacy' AND c.relkind = 'r'
ORDER BY pg_total_relation_size(c.oid) DESC
LIMIT 8;
```

```text
 tablas
--------
    419

       tabla        | filas_estimadas | tamano
--------------------+-----------------+---------
 ResultadoItem      |        12134152 | 1309 MB
 ProtocoloPracticas |         6131824 | 461 MB
 Protocolos         |         1327622 | 151 MB
 Comprobantes       |          570046 | 58 MB
 Pacientes          |          242427 | 38 MB
 ParaLlamar         |           97035 | 10 MB
 Quimica            |           44435 | 4096 kB
 Recibos            |           29243 | 3888 kB
```

**419 tablas y 2.061 MB**, y dos de ellas, `ResultadoItem` y `ProtocoloPracticas`, son el 86 % del
peso. `filas_estimadas` sale de las estadísticas, no de contar: `Pacientes` dice 239.414 y tiene
242.427. La [Fase 12](12-estadisticas-y-cardinalidad.md) vuelve sobre esa diferencia.

Lo que la caja no tiene:

```sql
-- postgres
SELECT count(*) AS sin_clave_primaria
FROM pg_class AS c
JOIN pg_namespace AS n ON n.oid = c.relnamespace
WHERE n.nspname = 'legacy' AND c.relkind = 'r'
  AND NOT EXISTS (SELECT 1 FROM pg_constraint AS k WHERE k.conrelid = c.oid AND k.contype = 'p');
```

```text
 sin_clave_primaria
--------------------
                353
```

**353 de 419 tablas sin clave primaria**, y en `legacy` ninguna clave foránea: el `ALAMEDA.sql`
original tiene cuatro, todas creadas `WITH NOCHECK` para que no fallaran contra los huérfanos que ya
había, y `lab load` no las replica. De las 1.766 columnas, 1.219 son `varchar` y 3 son `text`: el DNI,
la edad y el número de afiliado están entre ellas. Seis tablas tienen espacios o símbolos en el nombre
(`Copia de Pacientes`, `Errores de importación`, `Hoja1$`) y solo se pueden nombrar entre comillas.

**En MySQL, el catálogo es el mismo estándar con otras columnas.** `information_schema.tables` existe en
los dos motores, y en MySQL trae además una columna que tienta: `table_rows`.

```sql
-- mysql
SELECT table_name, table_rows FROM information_schema.tables WHERE table_schema = 'legacy' ORDER BY table_name;
```

```text
TABLE_NAME	TABLE_ROWS
Pacientes	240233
Practicas	75
Protocolos	1319488
ResultadoItem	12108863
```

`Protocolos` tiene 1.327.622 filas, no 1.319.488: `table_rows` es una **estimación** que InnoDB saca de
muestrear páginas, igual que `reltuples` en Postgres. Sirve para saber el orden de magnitud y la usa el
optimizador, pero **no para verificar una carga**. Para eso se cuenta, y es lo que hace `lab load` con
cada tabla grande. En MySQL, además, un esquema y una base de datos son la misma cosa: `legacy` es una
base, y `USE legacy` reemplaza al `search_path` de Postgres ([`a03`](a03-clis-de-los-motores.md)).

### 4.5 Cómo se mide la forma

El curso no mide cuánto tarda una consulta: mide **cuánto trabajo hizo**. El instrumento es el plan
ejecutado. Dos consultas sobre `legacy."Protocolos"` de M: una por la clave, otra por el número que se
imprime en el sobre del paciente, `C-0048213`, el de la URL del portal de 2013.

```sql
-- postgres
EXPLAIN (ANALYZE, BUFFERS) SELECT * FROM legacy."Protocolos" WHERE "IdProtocolo" = 10006666;
```

```text
 Index Scan using "Protocolos_pkey" on "Protocolos"  (cost=0.43..8.45 rows=1 width=59) (actual time=2.985..2.986 rows=1.00 loops=1)
   Index Cond: ("IdProtocolo" = 10006666)
   Index Searches: 1
   Buffers: shared hit=1 read=3
 Planning:
   Buffers: shared hit=36
 Planning Time: 0.217 ms
 Execution Time: 3.010 ms
```

```sql
-- postgres
EXPLAIN (ANALYZE, BUFFERS) SELECT * FROM legacy."Protocolos" WHERE "NroProtocolo" = 'C-0048213';
```

```text
 Gather  (cost=1000.00..23610.80 rows=1 width=59) (actual time=3.297..30.635 rows=1.00 loops=1)
   Workers Planned: 2
   Workers Launched: 2
   Buffers: shared hit=15696
   ->  Parallel Seq Scan on "Protocolos"  (cost=0.00..22610.70 rows=1 width=59) (actual time=17.502..25.438 rows=0.33 loops=3)
         Filter: (("NroProtocolo")::text = 'C-0048213'::text)
         Rows Removed by Filter: 442540
         Buffers: shared hit=15696
 Planning Time: 0.053 ms
 Execution Time: 30.655 ms
```

Campo por campo, lo que se lee:

| Campo | En la primera | En la segunda | Qué dice |
|---|---|---|---|
| nodo | `Index Scan using "Protocolos_pkey"` | `Parallel Seq Scan` | cómo llegó a las filas: por un índice o recorriendo la tabla |
| `rows=` en `cost=(…)` | 1 | 1 | lo que el planificador **estimó** |
| `rows=` en `actual` | 1.00 | 0.33 por vuelta, en 3 vueltas | lo que **pasó**; Postgres 18 lo da por vuelta, con decimales |
| `Rows Removed by Filter` | — | 442.540 por vuelta | filas leídas y tiradas |
| `Buffers: shared hit` · `read` | 1 · 3 | 15.696 · 0 | páginas de 8 KB tomadas de memoria y pedidas al disco |
| `Execution Time` | 3,0 ms | 30,7 ms | **contexto**, de esta máquina |

**4 bloques contra 15.696, para devolver la misma fila.** Esa es la medida del curso, y no depende de
la máquina. El segundo plan leyó la tabla entera (tres procesos, 442.540 filas tiradas cada uno, más
la que encontró) porque `NroProtocolo`, el número que la gente ve, no tiene índice. La [Fase 11](11-indices-y-lo-que-cuestan.md) decide
cuánto cuesta ponérselo.

> 🧭 **El tiempo no es el argumento.** 3 ms contra 30 ms parece decir lo mismo, pero el número de
> bloques se repite en tu máquina y el tiempo no. Cada campo de esta salida, y la versión resumida que
> imprime `uv run lab measure`, está explicado en [`a04`](a04-el-arnes-de-forma.md).

**En MySQL**, `EXPLAIN ANALYZE` cuenta otra historia con otras palabras:

```text
EXPLAIN: -> Rows fetched before execution  (cost=0..0 rows=1) (actual time=0.032..0.0321 rows=1 loops=1)

EXPLAIN: -> Filter: (Protocolos.NroProtocolo = 'C-0048213')  (cost=138388 rows=131949) (actual time=69.3..566 rows=1 loops=1)
    -> Table scan on Protocolos  (cost=138388 rows=1.32e+6) (actual time=0.371..494 rows=1.33e+6 loops=1)
```

La búsqueda por clave primaria ni siquiera llega a ejecutarse: MySQL la resuelve al **preparar** la
consulta, porque una igualdad sobre la clave devuelve a lo sumo una fila. La otra recorre 1,33
millones de filas, y su estimación es la mitad de interesante: **131.949 filas esperadas para una que
devolvió**. Sin estadísticas sobre esa columna, MySQL supone que el filtro deja pasar un 10 %.

**En Oracle**, el curso publica la **estructura**, de `EXPLAIN PLAN` sin ejecutar
([`a09`](a09-licencias-publicacion-y-riesgo.md)):

```text
  ---------------------------------------------------
  | Id  | Operation                   | Name        |
  ---------------------------------------------------
  |   0 | SELECT STATEMENT            |             |
  |   1 |  TABLE ACCESS BY INDEX ROWID| Protocolos  |
  |*  2 |   INDEX UNIQUE SCAN         | SYS_C008718 |
  ---------------------------------------------------

     2 - access("IdProtocolo"=10006666)

  ----------------------------------------
  | Id  | Operation         | Name       |
  ----------------------------------------
  |   0 | SELECT STATEMENT  |            |
  |*  1 |  TABLE ACCESS FULL| Protocolos |
  ----------------------------------------

     1 - filter("NroProtocolo"='C-0048213')
```

La misma decisión que en los otros dos: índice único para la clave, recorrido completo para el número.
Fíjate en el nombre del índice, **`SYS_C008718`**: Oracle lo inventó porque la clave se creó sin
nombre. Un error que lo nombre no le va a decir nada a nadie, y por eso el curso nombra cada
restricción.

> 🪞🔒 **Apuesta sin resolver: Oracle.** Hipótesis: el `TABLE ACCESS FULL` sobre `Protocolos` lee
> del mismo orden de bloques que el `Seq Scan` de Postgres (15.696), porque las dos tablas tienen las
> mismas filas y los mismos tipos. Condiciones: perfil M, `Protocolos` cargada con `uv run lab load
> --profile m --engine oracle --tables Protocolos`. Resuélvela: `uv run lab measure --engine oracle
> --profile m --private -c "SELECT * FROM legacy.\"Protocolos\" WHERE \"NroProtocolo\" = 'C-0048213'"`
> y mira la columna `Buffers`. El mecanismo: los recorridos completos de tabla, en la *SQL Tuning
> Guide* de Oracle (en las referencias). 📝 No publicamos el resultado: el curso no publica números de
> Oracle ([`a09`](a09-licencias-publicacion-y-riesgo.md)).

### 4.6 La prueba de fuego

El arnés no se cree a sí mismo. El generador escribió en `MANIFIESTO.json` cuántas filas de
`Pacientes` tienen la palabra `DNI` dentro de `Nombre`, contadas sobre el CSV antes de cargarlo:

```text
$ grep -A2 '"fire_test"' src/lab/caja/m/MANIFIESTO.json
 "fire_test": {
  "Pacientes.Nombre LIKE '%DNI%'": 18936
 },
```

Ahora tú lo cuentas en la base:

```sql
-- postgres
SELECT count(*) AS nombre_con_dni FROM legacy."Pacientes" WHERE "Nombre" LIKE '%DNI%';
```

```text
 nombre_con_dni
----------------
          18936
```

**18.936 en Postgres, 18.936 en MySQL y 18.936 en Oracle**, contra 18.936 del manifiesto. Es un
conteo de la caja, igual en los tres motores, y por eso también se publica el de Oracle. Con S, el
número es 1.959. **Si el tuyo no coincide, el arnés está mal**: la caja es otra (compara el hash), la
carga perdió filas (compara `lab.loaded`) o la codificación se rompió en el camino. Cualquiera de las
tres invalida todo lo que se mida después, y por eso esta prueba va antes que cualquier medición del
curso.

> 📝 **18.936 no es la cantidad de documentos escritos en `Nombre`.** Es lo que encuentra un `LIKE`
> ingenuo. El generador sabe que son 25.575: el resto dice `D.N.I.`, `DNI:` o solo el número. La
> diferencia es el problema de la [Fase 04](04-un-valor-un-hecho.md), y el ejercicio 20 la mide.

---

## 🐘 5. Lo que el motor relacional ya te daba

La caja corre en un motor relacional desde 2011, y no usa casi nada de él. **353 tablas sin clave
primaria**, cuatro claves foráneas que nunca se validaron, el DNI, la edad y el precio como texto, una
fecha de nacimiento sin `CHECK` que dejó pasar 442 nacimientos en el futuro en M. Ninguna de esas
reglas faltaba porque SQL Server no pudiera defenderla: faltaba porque nadie la escribió.

Y la carga de esta fase muestra la otra cara. **Postgres y MySQL rechazaron un archivo que no era lo
que decía ser**, sin que nadie se lo pidiera, porque la codificación de la base es una regla que el
motor hace cumplir. Eso es lo que el resto del curso va a hacer con el DNI, el precio y el folio.

---

## ⚠️ 6. Errores comunes y diagnóstico

Errores de laboratorio, con su mensaje literal. Todos están en el [catálogo](a08-catalogo-de-errores.md).

- **`invalid byte sequence for encoding "UTF8": 0xf1 …`** (Postgres) o **`ERROR 1366 (HY000) …
  Incorrect string value: '\xF1os'`** (MySQL). 🩺 El archivo es Latin-1. Se sale declarando la
  codificación en la carga, nunca convirtiendo el archivo.
- **`SP2-0784: Invalid or incomplete character beginning 0xF1 returned`** (Oracle). 🩺 Los bytes ya
  están guardados mal; `DUMP(columna, 16)` lo confirma. Se sale recreando la tabla externa con
  `CHARACTERSET WE8ISO8859P1` y volviendo a cargar.
- **`ORA-12154` u `ORA-12541` al conectar.** 🩺 Oracle todavía no está `healthy`: `uv run lab ps`
  ([`a01`](a01-laboratorio-contenerizado.md#️-conectarse-antes-de-tiempo)).
- **`✗ No existe la caja del perfil m`.** 🩺 Falta `uv run lab generate --profile m`.
- **Una prueba de fuego que no coincide.** 🩺 Compara el hash de la caja con el de
  [`a05`](a05-la-caja-y-el-generador.md#-los-tres-perfiles) y `lab.loaded` con el manifiesto; si los
  dos coinciden, la carga cambió algún carácter.

---

## 📋 7. Checklist de validación

- [ ] Los tres motores en `healthy`, y la caja de M con el hash `3e59292e9918…`.
- [ ] `legacy` en Postgres con 419 tablas, y `truth` cargado.
- [ ] Reproduje el error de Latin-1 en Postgres y en MySQL, y vi que Oracle no lo da.
- [ ] Sé contar desde el catálogo las tablas, su peso y las que no tienen clave.
- [ ] Sé leer `Buffers`, `rows` estimadas y reales, y `Rows Removed by Filter`.
- [ ] La prueba de fuego me dio 18.936 con M.

---

## 🧪 8. Ejercicios (22)

## 🟢 Fácil — la caja tal cual (1–7)

### 🟢 Ejercicio 1 — Los tres motores, arriba

Levanta `base`, `contraste` y `oracle` y comprueba su estado.

**Objetivo:** los tres servicios en `healthy` en `uv run lab ps`.

[Solución](soluciones/01-la-caja-y-el-arnes.md#ejercicio-1)

### 🟢 Ejercicio 2 — La caja de M

Genera el perfil M.

**Objetivo:** el hash `3e59292e9918ee25…` y los conteos de personas, pacientes y protocolos de la
sección 4.2.

[Solución](soluciones/01-la-caja-y-el-arnes.md#ejercicio-2)

### 🟢 Ejercicio 3 — S en Postgres

Carga S y consulta qué caja quedó cargada.

**Objetivo:** `lab.loaded` con el perfil `s`, la semilla 1996, la caja `49cfb8db4194` y 419 tablas.

[Solución](soluciones/01-la-caja-y-el-arnes.md#ejercicio-3)

### 🟢 Ejercicio 4 — Cuántas tablas

Cuenta las tablas de `legacy` desde `information_schema` y desde `pg_class`.

**Pregunta:** ¿dan lo mismo las dos fuentes, y cuántas son?

[Solución](soluciones/01-la-caja-y-el-arnes.md#ejercicio-4)

### 🟢 Ejercicio 5 — Las que no tienen clave

Cuenta las tablas de `legacy` sin clave primaria y lista diez de ellas.

**Objetivo:** 353, y diez nombres que muestren de qué grupos de la caja son.

[Solución](soluciones/01-la-caja-y-el-arnes.md#ejercicio-5)

### 🟢 Ejercicio 6 — Lo que pesa

Con M cargado, lista las cinco tablas más pesadas de `legacy`.

**Objetivo:** las cinco, con su tamaño, y qué porcentaje del total ocupan las dos primeras.

[Solución](soluciones/01-la-caja-y-el-arnes.md#ejercicio-6)

### 🟢 Ejercicio 7 — La prueba de fuego en S

Cuenta en S las filas de `legacy."Pacientes"` con `DNI` en `Nombre` y compáralo con el manifiesto de S.

**Objetivo:** 1.959 en la base y 1.959 en `MANIFIESTO.json`.

[Solución](soluciones/01-la-caja-y-el-arnes.md#ejercicio-7)

## 🟡 Intermedio — leer los motores (8–13)

### 🟡 Ejercicio 8 — Las mismas cuatro en MySQL

Carga `Pacientes`, `Protocolos`, `ResultadoItem` y `Practicas` de M en MySQL y cuenta sus filas.

**Objetivo:** los cuatro conteos iguales a los de Postgres.

[Solución](soluciones/01-la-caja-y-el-arnes.md#ejercicio-8)

### 🟡 Ejercicio 9 — Un plan, campo por campo

Ejecuta los dos `EXPLAIN (ANALYZE, BUFFERS)` de la sección 4.5 sobre tu M.

**Objetivo:** explicar con tus números qué es cada campo de la tabla de la sección, y cuántos bloques
separan las dos consultas.

[Solución](soluciones/01-la-caja-y-el-arnes.md#ejercicio-9)

### 🟡 Ejercicio 10 — El mismo plan en MySQL

Ejecuta las dos consultas con `EXPLAIN ANALYZE` en MySQL.

**Pregunta:** ¿por qué la búsqueda por clave dice `Rows fetched before execution`, y de dónde sale la
estimación de filas del recorrido?

[Solución](soluciones/01-la-caja-y-el-arnes.md#ejercicio-10)

### 🟡 Ejercicio 11 — La estructura en Oracle

Con `Protocolos` de M cargada en Oracle, obtén la estructura de los dos planes con `uv run lab measure
--engine oracle`.

**Objetivo:** los dos planes, la operación que usa cada uno y el nombre del índice, sin ningún número de
ejecución.

[Solución](soluciones/01-la-caja-y-el-arnes.md#ejercicio-11)

### 🟡 Ejercicio 12 — La carga sucia, en Postgres

Carga `Pacientes.csv` de M en una tabla aparte con `COPY`, sin `ENCODING`. Después, con
`ENCODING 'LATIN1'`.

**Objetivo:** el error literal, la línea y la palabra que lo provocó, y la carga correcta con 242.427
filas.

[Solución](soluciones/01-la-caja-y-el-arnes.md#ejercicio-12)

### 🟡 Ejercicio 13 — La carga sucia, en MySQL

Haz lo mismo en MySQL con `LOAD DATA … CHARACTER SET utf8mb4`.

**Pregunta:** ¿en qué fila y columna falla, y por qué el número de fila no coincide con el de Postgres?

[Solución](soluciones/01-la-caja-y-el-arnes.md#ejercicio-13)

## 🟠 Difícil — diagnosticar la carga (14–19)

### 🟠 Ejercicio 14 — La carga sucia, en Oracle

Crea una tabla externa sobre `Pacientes.csv` con `CHARACTERSET AL32UTF8`, consulta la fila 5 y cópiala a
una tabla real. Predice antes si Oracle va a dar error.

**Objetivo:** el mensaje que aparece y dónde, los bytes guardados según `DUMP`, y por qué este
comportamiento es más peligroso que el de los otros dos motores.

[Solución](soluciones/01-la-caja-y-el-arnes.md#ejercicio-14)

### 🟠 Ejercicio 15 — Estimadas contra reales

En el plan de la prueba de fuego, compara las filas estimadas y las reales del `Parallel Seq Scan`.

**Pregunta:** ¿cuántas estimó el planificador en total, cuántas devolvió, y por qué el plan muestra
un número por *worker*?

[Solución](soluciones/01-la-caja-y-el-arnes.md#ejercicio-15)

### 🟠 Ejercicio 16 — En memoria o del disco

Ejecuta dos veces seguidas el `EXPLAIN (ANALYZE, BUFFERS)` de la prueba de fuego, la primera después de
reiniciar Postgres.

**Objetivo:** el cambio de `read` a `hit`, y por qué el total de bloques no cambia aunque el tiempo sí.

[Solución](soluciones/01-la-caja-y-el-arnes.md#ejercicio-16)

### 🟠 Ejercicio 17 — Las filas que MySQL cree tener

Compara `table_rows` de `information_schema.tables` con un `count(*)` en las cuatro tablas de MySQL.

**Pregunta:** ¿por qué no coinciden, y cuál de los dos usarías para la prueba de fuego?

[Solución](soluciones/01-la-caja-y-el-arnes.md#ejercicio-17)

### 🟠 Ejercicio 18 — La prueba de fuego en tres motores

Corre el conteo de la prueba de fuego en Postgres, MySQL y Oracle.

**Pregunta:** ¿por qué dan lo mismo, si MySQL compara sin distinguir mayúsculas y Postgres sí, y por qué
este número de Oracle sí se puede publicar?

[Solución](soluciones/01-la-caja-y-el-arnes.md#ejercicio-18)

### 🟠 Ejercicio 19 — Todas las tablas, contra sus CSV

Escribe un script en Python que compare las filas de cada una de las 419 tablas de `legacy` con las del
CSV de la caja.

**Objetivo:** 419 tablas comparadas y 0 distintas, con un script que cuente registros CSV y no líneas.

[Solución](soluciones/01-la-caja-y-el-arnes.md#ejercicio-19)

## 🔴 Muy difícil — lo que el arnés no ve (20–22)

### 🔴 Ejercicio 20 — 18.936 contra 25.575

La prueba de fuego cuenta 18.936, y `truth` dice que hay 25.575 filas con un documento en `Nombre`.

**Pregunta:** ¿qué son las 6.639 que el `LIKE` no ve? Clasifícalas por cómo está escrito el documento,
con números, cruzando `legacy` con `truth`.

[Solución](soluciones/01-la-caja-y-el-arnes.md#ejercicio-20)

### 🔴 Ejercicio 21 — "Arreglemos el CSV antes"

Un colega propone pasar `Pacientes.csv` a UTF-8 con `iconv` antes de cargarlo, "así no hay que acordarse
de la codificación". Hazlo y compara el archivo con el manifiesto.

**Objetivo:** el hash antes y después, y un argumento de tres líneas sobre por qué la carga se arregla
declarando la codificación y no tocando la caja.

[Solución](soluciones/01-la-caja-y-el-arnes.md#ejercicio-21)

### 🔴 Ejercicio 22 — ¿Qué se puede comparar?

Tienes el plan de Postgres (bloques), el de MySQL (filas) y la estructura de Oracle de la misma consulta.

**Pregunta:** ¿qué afirmación comparativa entre los tres se puede sostener con esos datos, cuál no, y qué
tendrías que medir para poder hacerla?

[Solución](soluciones/01-la-caja-y-el-arnes.md#ejercicio-22)

---

## 📚 9. Referencias

> ⚠️ Las URL y sus contenidos cambian. Se consultaron el 12/10/2026, para las versiones de
> [`a02`](a02-compose-de-la-ruta.md).

- **`EXPLAIN` en Postgres 18** — https://www.postgresql.org/docs/18/using-explain.html — cada campo del
  plan, con ejemplos.
- **`COPY` en Postgres 18** — https://www.postgresql.org/docs/18/sql-copy.html — `ENCODING` y el formato
  CSV.
- **`EXPLAIN ANALYZE` en MySQL 9.7** — https://dev.mysql.com/doc/refman/9.7/en/explain.html — la salida en
  árbol y sus estimaciones.
- **Recorridos completos de tabla en Oracle** — https://docs.oracle.com/en/database/oracle/oracle-database/26/tgsql/optimizer-access-paths.html
  — la *SQL Tuning Guide*, para el mecanismo de la apuesta.
- **Markus Winand, *Use The Index, Luke*** — https://use-the-index-luke.com/ — leer un plan en varios
  motores, con la misma idea de esta fase: el trabajo, no el tiempo.

**Orden sugerido:** el de `EXPLAIN` de Postgres antes del ejercicio 9; Winand, en paralelo con el Bloque
II.

---

## 🏁 10. Resultado de la fase

Tienes el laboratorio arriba, la caja de Alameda cargada sin limpiar en tres motores, y el instrumento
calibrado: sabes leer un plan por sus bloques y no por su tiempo, y el arnés contó lo mismo que el
generador. La [Fase 02](02-las-cinco-preguntas-desde-el-otro-lado.md) trae el otro instrumento, el que
no mide nada y decide casi todo.

> **La señal de que quedó bien:** *"Mi prueba de fuego dio 18.936, y sé decir por qué 4 bloques contra
> 15.696 importa más que 3 ms contra 30."*

> 🏷️ **Tag:** `fase-01-la-caja-y-el-arnes` · prefijo de commit `f01:`
