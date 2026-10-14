# 🦆 Fase 08 — Analítico embebido: la métrica nueva, el dato que no cabe y el segundo proceso

> **Curso:** Ruta NoSQL Lite · Fase 08 de 26 · Bloque II — Leer de otra forma · **10 h**
> **Familia:** analítico embebido · **Motor:** DuckDB 1.5.6, embebido en Python (`duckdb==1.5.6` del
> `uv.lock`)
> **Línea base:** PostgreSQL 18.6 `pgvector/pgvector@sha256:2ba9ca5f2e7d…` (base `analitico`)
> **Entorno de ejecución:** **Python** para DuckDB ([`a06`](a06-lenguajes-y-drivers.md)); TypeScript
> para medir Postgres
> **Volumen:** `reading_x10`, 50 M lecturas: la ampliación ×10 de `reading-5m` (`8dc486dea089…`) que
> construyó la Fase 07, con la misma huella en los dos motores
> **Depende de:** Fase 07 · **Habilita:** Fase 09
> **Apéndices de apoyo:** [`a03`](a03-clis-de-los-motores.md), [`a04`](a04-el-arnes-de-medida.md),
> [`a06`](a06-lenguajes-y-drivers.md), [`a09`](a09-catalogo-de-errores.md)
> **Fecha de verificación ejecutada:** 07/10/2026, en macOS arm64
> **Objetivo:** resolver la apuesta de la métrica nueva midiendo bytes escritos, llevar los dos motores a
> volcar a disco, y encontrar el punto exacto en que DuckDB deja de servir: el segundo proceso.

---

## 🧭 1. Dónde estamos

La [Fase 07](07-analitico-levantar-y-modelar.md) dejó dos bases con los mismos 50 M de lecturas y una
medición que no admite discusión: para tres columnas de todas las filas, DuckDB lee 203 MiB y Postgres
4439. También dejó una advertencia, la de los cuatro escritores que perdían aterrizajes. Esta fase
completa el retrato con las tres preguntas que se hacen el día que el tablero de Lucía funciona y
alguien quiere más: **¿cuánto cuesta añadirle una métrica?**, **¿qué pasa cuando la consulta no cabe en
memoria?** y **¿qué pasa cuando otro programa quiere el mismo archivo?**

La primera es la apuesta de la familia, escrita en el temario el 30/09/2026 y confirmada antes de
medir. La segunda es el *spilling*, y aquí Postgres trae una sorpresa que conviene ver con los números
delante. La tercera es el punto de rotura, y es corto y brutal: no hay volumen que medir, hay un
número de procesos, y el número es dos.

---

## 🎯 2. Objetivos de esta fase

1. Añadir la misma métrica —el margen de EGT, `765 − egt_c`— a los 50 M en las cuatro formas que admite
   Postgres 18 y en las que admite DuckDB, y medir **bytes escritos y tamaño final**.
2. Leer el plan de DuckDB de la consulta de Lucía operador por operador y compararlo con las páginas de
   Postgres: **23,8 MiB contra 446,8**.
3. Bajar la memoria de DuckDB hasta que vuelca y hasta que falla, y comparar con el `work_mem` de
   Postgres, que vuelca antes y más.
4. Reproducir el punto de rotura: **un segundo proceso no puede ni leer** mientras el primero escribe.
5. Escribir cuándo no usar analítico embebido, con las pérdidas en número.

> 🧰 **Miniproyecto de esta familia:** [Bengala — el tablero que tres personas arman distinto cada
> lunes](h-mini-03-analitico-bengala.md). Opcional, fuera de las horas del curso, y no entra a la
> bitácora.

---

## 🪞 3. La apuesta

> 🪞 **Apuesta antes de ejecutar.** Creo que **el `ALTER TABLE` de una métrica nueva sobre la tabla
> ancha de Postgres cuesta un orden de magnitud más que añadir la columna en el modelo columnar**,
> medido en bytes escritos sobre los mismos 50 M de lecturas.

Escrita en el temario el 30/09/2026 y confirmada el 07/10/2026 antes de ejecutar `alter.ts` y
`alter.py`, con una advertencia dicha antes y no después: Postgres 18 trae **columnas generadas
virtuales**, que no se guardan. Si la métrica nueva se puede escribir así, la apuesta tiene un flanco
abierto. **Resultado, en la sección 4.5: ganada para la métrica guardada, por más de dos órdenes de
magnitud; perdida para la calculada al leer, que Postgres añade gratis y DuckDB no sabe añadir.**

---

## 📐 4. La medición contra la línea base

### 4.1 Una métrica nueva sobre 50 millones

El problema: Édinson quiere ver en el tablero el **margen de EGT**, cuánto le falta a cada lectura para
el límite de 765 °C, porque el margen que se estrecha es lo que avisa que un motor viene mal. Es una
columna nueva, calculada de una que ya existe. Hay cuatro formas de añadirla, y no cuestan lo mismo.

`alter.ts` las prueba en Postgres, cada una sobre una copia limpia de `reading_x10`, y mide los bytes de
WAL escritos (`pg_wal_lsn_diff` antes y después) y el tamaño de la tabla. `alter.py` hace lo mismo en
DuckDB, en un archivo aparte, y mide lo que crece el archivo tras un `CHECKPOINT`, porque su perfilador
no cuenta bytes escritos.

```bash
node 08-analitico-romper-y-medir/alter.ts
uv run python 08-analitico-romper-y-medir/alter.py
```

```text
PostgreSQL 18.6 (Debian 18.6-1.pgdg12+2) · copia de reading_x10 por forma
  constant  WAL      0.1 MiB · tabla   4438.9 →   4438.9 MiB · 0.0 s
  update    WAL  13992.4 MiB · tabla   4439.4 →   8877.8 MiB · 67.1 s
  stored    WAL   5739.1 MiB · tabla   4438.9 →   4439.1 MiB · 35.4 s
  virtual   WAL      0.0 MiB · tabla   4439.2 →   4439.2 MiB · 0.0 s
DuckDB 1.5.6 · copia de reading_x10 por forma
  constant  WAL antes del checkpoint    0.0 MiB · archivo   680.3 →   681.0 MiB (+0.8) · 0.2 s
  update    WAL antes del checkpoint    0.0 MiB · archivo   679.5 →   731.3 MiB (+51.8) · 1.0 s
  virtual   ParserException: Parser Error: Adding generated columns after table creation is not supported yet
```

> 📐 **Medición — añadir el margen de EGT** · `reading_x10`, 50 M · DuckDB 1.5.6 · PostgreSQL 18.6 ·
> verificado el 07/10/2026 (DuckDB, dos corridas idénticas)
>
> | Forma | Postgres: WAL escrito · tabla después | DuckDB: lo que crece el archivo |
> |---|---|---|
> | columna con un valor constante | 0,1 MiB · igual | +0,8 MiB |
> | columna y `UPDATE` de los 50 M | **13 992 MiB** · **8878 MiB** (el doble) | **+51,8 MiB** |
> | columna generada guardada (`STORED`) | **5739 MiB** · igual (se reescribe entera) | no existe esta forma |
> | columna generada virtual | **0 MiB** · igual | **no se puede añadir** a una tabla existente |
>
> Reproducir: `node 08-analitico-romper-y-medir/alter.ts` y
> `uv run python 08-analitico-romper-y-medir/alter.py` (desde `src/`)

Lo que dice cada fila. **La constante es gratis en los dos**: Postgres la anota en el catálogo desde la
versión 11, y DuckDB guarda una columna de ceros que comprime a casi nada. **El `UPDATE` es donde se
separan.** Postgres no modifica una fila: escribe una versión nueva entera de cada una de las 50 M, con
sus diez columnas, deja la vieja como tupla muerta hasta el próximo `VACUUM` y lo registra todo en el
WAL: **14 GB de WAL y la tabla al doble** para guardar un entero de cuatro bytes. DuckDB escribe **la
columna nueva y nada más**: 51,8 MiB, que es lo que ocupan 50 M de enteros pequeños comprimidos.

La columna generada guardada reescribe la tabla una vez —5,7 GB de WAL— y la deja del mismo tamaño,
porque cuatro bytes más caben en el relleno de alineación de cada tupla. Y **la virtual no escribe
nada**: Postgres guarda la expresión y la calcula al leer. DuckDB tiene columnas generadas, pero solo
al crear la tabla: añadir una después da el error de la última línea (E-41 en
[`a09`](a09-catalogo-de-errores.md)).

Una nota de método, declarada: las dos columnas de la tabla no miden exactamente lo mismo. En Postgres
es lo que se escribió al WAL, que es lo que cuesta durable; en DuckDB, lo que creció el archivo, porque
no hay otra cifra. La diferencia entre 13 992 y 51,8 MiB es tan grande que el método no la decide.

### 4.2 Columnas leídas contra filas leídas: la derrota que no depende de nada

La Fase 07 midió la agregación de tres columnas (203 contra 4439 MiB, M-16). Aquí, la consulta real de
Lucía, `cost_per_hour.sql`, que cruza horas, órdenes y aeronaves sobre las 5 M lecturas reales:

| | DuckDB | Postgres |
|---|---|---|
| leído para el costo por hora volada | **23,8 MiB** | 57 196 páginas, **446,8 MiB** |
| de `reading`, que es casi todo | columnas `aircraft` y `ts` | la tabla entera, 56 819 páginas |

Es la derrota estructural de Postgres en esta familia, y conviene decir por qué no depende de nada.
No depende del hardware: es una cuenta de bytes. No depende de la versión: un *heap* de filas lee filas,
y lo hará en Postgres 30. Y no la cierra un índice: la Fase 07 midió el mejor, el cubriente, y Postgres
siguió leyendo nueve veces lo que DuckDB, para una sola consulta y con 1,9 GB de índice a cuestas.

### 4.3 El plan de DuckDB, leído con calma

`EXPLAIN ANALYZE` dibuja el plan en cajas. `explain.py` lee el mismo perfil en JSON y lo escribe un
operador por línea, que es más fácil de comparar con Postgres. El plan de `cost_per_hour.sql`, abajo
del todo, que es donde empieza:

```bash
uv run python 08-analitico-romper-y-medir/explain.py
```

```text
07-analitico-levantar-y-modelar/cost_per_hour.sql · leídos 23.8 MiB
…
                  HASH_JOIN · filas 17 · Join Type: INNER · Conditions: registration = aircraft
                    SEQ_SCAN · filas 17 · recorridas 80 · Table: condor.main.aircraft · Projections: registration, model, operator_id
                    PROJECTION · filas 17 · Projections: aircraft, flight_hours
                      PROJECTION · filas 17 · Projections: __internal_decompress_string(#0), #1
                        HASH_GROUP_BY · filas 17 · Groups: #0 · Aggregates: count_star()
                          PROJECTION · filas 4929892 · Projections: aircraft
                            PROJECTION · filas 4929892 · Projections: __internal_compress_string_ubigint(#0)
                              SEQ_SCAN · filas 4929892 · recorridas 5000000 · Table: condor.main.reading · Projections: aircraft · Filters: ts<'2026-10-01 00:00:00'::TIMESTAMP
```

Qué mirar, de abajo arriba. **`SEQ_SCAN` con `Projections`**: las columnas que lee de verdad.
De `reading` solo proyecta `aircraft`; `ts` aparece en **`Filters`**, que se evalúa dentro del recorrido y
contra el mínimo y máximo de cada grupo. **`recorridas` contra `filas`**: recorrió 5 000 000 y dejó pasar
4 929 892; las 70 108 de diferencia son las lecturas fuera de la ventana de la Fase 07. **Las
`PROJECTION` con `__internal_compress_string`** no son trabajo tuyo: DuckDB comprime las matrículas a
enteros para agrupar más rápido y las descomprime al salir. Y **`HASH_GROUP_BY` antes del `HASH_JOIN`**:
agrupa los 5 M en 17 filas y después cruza 17 con 80. Postgres, con su `Parallel Seq Scan`, hace lo
mismo en el mismo orden; lo que no puede es dejar las otras ocho columnas en el disco.

El plan de Postgres para la misma consulta, recortado a los recorridos y sus páginas:

```text
                     ->  Seq Scan on work_order (actual rows=30822.00 loops=1)
                           Filter: (opened_at < '2026-10-01 00:00:00'::timestamp without time zone)
                           Buffers: shared read=360
                                 ->  Seq Scan on aircraft a (actual rows=80.00 loops=1)
                                       Buffers: shared read=1
                                                   ->  Parallel Seq Scan on reading (actual rows=1643297.33 loops=3)
                                                         Filter: (ts < '2026-10-01 00:00:00'::timestamp without time zone)
                                                         Rows Removed by Filter: 23369
                                                         Buffers: shared read=56819
```

Las dos bases cuentan lo mismo con otras palabras. DuckDB dice *recorridas 5 000 000, filas 4 929 892*;
Postgres dice *1 643 297 filas por cada uno de tres procesos, 23 369 descartadas por cada uno*, que son
las mismas 70 108 lecturas fuera de la ventana con el redondeo del promedio por proceso. **El filtro es
idéntico; lo que cambia es lo que viene pegado a cada fila que pasa.** Las 56 819 páginas de `reading`
son la tabla entera: para contar minutos de vuelo por aeronave, Postgres trajo la altitud, la velocidad,
el EGT, la presión y la temperatura de aceite y el flujo de combustible de cinco millones de minutos, y los
tiró. Esa es la columna que falta en cualquier comparación hecha con un cronómetro: **qué se leyó para
nada**.

### 4.4 El dato que no cabe en memoria

Dos consultas sobre los 50 M. Una agrupa por vuelo —624 860 grupos pequeños—; la otra ordena las 50 M
filas por EGT, y para devolver la primera tiene que haberlas visto todas. `spill.py` baja el límite de
memoria de DuckDB hasta que vuelca a disco y hasta que falla; `spill.ts` corre las mismas en Postgres
con el `work_mem` de fábrica, 4 MB, y con 1 GB.

> 📐 **Medición — volcar a disco** · `reading_x10`, 50 M · DuckDB 1.5.6, 8 hilos salvo donde se dice ·
> PostgreSQL 18.6, 2 workers · verificado el 07/10/2026
>
> | | Agrupar por vuelo | Ordenar 50 M por EGT |
> |---|---|---|
> | DuckDB, 4 GB | sin volcar | sin volcar |
> | DuckDB, 512 MB | sin volcar | **921 MiB** a disco |
> | DuckDB, 256 MB | sin volcar | 1166 MiB |
> | DuckDB, 128 MB | sin volcar | **`Out of Memory Error`** |
> | DuckDB, 128 MB, 1 hilo | sin volcar | 1257 MiB |
> | DuckDB, 512 MB, sin directorio temporal | sin volcar | **`Out of Memory Error`** |
> | Postgres, `work_mem` 4 MB | **3597 MiB** de temporales | **5340 MiB** |
> | Postgres, `work_mem` 1 GB | sin volcar | 1777 MiB |
>
> Reproducir: `uv run python 08-analitico-romper-y-medir/spill.py` y
> `node 08-analitico-romper-y-medir/spill.ts` (desde `src/`)

Tres lecturas. **Agrupar por vuelo no vuelca nunca en DuckDB**, ni con 128 MB, y en Postgres con el
`work_mem` de fábrica escribe **3,5 GB de temporales**: el plan dice `Batches: 5 … Disk Usage` en el
agregado y `external merge` en el orden que lo sigue. No es un fallo de Postgres: es que 4 MB por nodo
es una configuración para cientos de conexiones de una aplicación, no para un analista solo; con 1 GB,
no vuelca. **Ordenar 50 M sí obliga a DuckDB a volcar** desde 512 MB, y vuelca menos que Postgres
(921 MiB contra 5340 con los valores de fábrica, contra 1777 con 1 GB).

Y **el límite tiene dos bordes**. Con 128 MB y 8 hilos, DuckDB falla: cada hilo necesita sus bloques y
no caben. El mensaje lo dice y propone la salida —menos hilos—, y con uno solo la misma consulta termina
volcando 1257 MiB. Sin directorio temporal falla con 512 MB, que con disco le alcanzaban. Los dos
mensajes, literales, están en la sección 9.

Dos declaraciones. El perfilador de DuckDB informó picos de memoria **mayores que el límite** en
la consulta de agrupar (909 MiB con 512 MB de límite, 471 con 256); no se investigó qué cuenta ese campo.
Y en Postgres, ordenar con 1 GB fue **más lento** que con 4 MB (57,5 s contra 23,5 s): es contexto, en
esta máquina, y tampoco se investigó.

### 4.5 El resultado de la apuesta

> 🪞 **Resultado.** **Ganada para la métrica guardada**: añadir el margen de EGT y calcularlo para las
> 50 M lecturas escribió **13 992 MiB de WAL y dobló la tabla** en Postgres, y **51,8 MiB** en DuckDB:
> más de dos órdenes de magnitud, no uno. Con la columna generada guardada, 5739 MiB. **Perdida para la
> métrica calculada al leer**: Postgres 18 la añade como columna virtual sin escribir un byte, y DuckDB
> **no puede añadirla** a una tabla que ya existe.

El resultado útil es el matiz. Si la métrica nueva es **un cálculo sobre columnas que ya existen**,
Postgres 18 la tiene gratis y ya no hay apuesta; es lo que pasa con casi todas las métricas de Édinson.
Si es **un dato nuevo que hay que guardar** —un valor de otra fuente, un resultado que no se puede
recalcular—, Postgres reescribe todas las filas y DuckDB escribe una columna. Y las dos cosas se miden
en bytes, no en segundos.

### 4.6 Lo que no se midió

**La concurrencia dentro del proceso** ya se midió en la Fase 07 (M-17): sin candados de fila, el
segundo escritor falla. **El `VACUUM`** que devolvería a Postgres el espacio de las 50 M tuplas muertas
del `UPDATE`. **Una tabla de verdad ancha**, con cien columnas, donde el `UPDATE` de Postgres costaría
proporcionalmente más y la columna de DuckDB lo mismo. Y **la latencia**, por diseño.

---

## 💥 5. El punto de rotura

El punto de rotura de esta familia no tiene volumen: tiene un número de procesos, y es dos.
`two_processes.py` abre una base con un proceso que registra aterrizajes y, mientras escribe, intenta
abrirla desde otro proceso, primero para escribir y después **solo para leer**.

```bash
uv run python 08-analitico-romper-y-medir/two_processes.py
```

> 💥 **Rotura — el segundo proceso** · `landing.duckdb`, un escritor activo · DuckDB 1.5.6 ·
> verificado el 07/10/2026
>
> ```text
>   con un escritor abierto, otro proceso para escribir: IOException: IO Error: Could not set lock on file "…/src/lab/data/analitico/landing.duckdb": Conflicting lock is held in …/python3.13 (PID 39798) by user …. See also https://duckdb.org/docs/stable/connect/concurrency
>   con un escritor abierto, otro proceso solo para leer: IOException: IO Error: Could not set lock on file "…/src/lab/data/analitico/landing.duckdb": Conflicting lock is held in …/python3.13 (PID 39798) by user …. See also https://duckdb.org/docs/stable/connect/concurrency
>   sin escritor, dos procesos solo para leer: abrió y leyó 9 aterrizajes
> ```

La segunda línea es la que muerde. **Mientras un proceso tiene la base abierta para escribir, ningún
otro la puede abrir, ni para leer.** Si la aplicación de plataforma registrara aterrizajes en
`condor.duckdb`, el tablero de Lucía no abriría hasta que la aplicación soltara el archivo. Sin escritor,
los lectores conviven. El mensaje es el E-08 de [`a09`](a09-catalogo-de-errores.md), que la sesión de
verificación ya había visto con dos escritores; esta fase añade el caso del lector.

En Postgres este caso no existe: cada cliente es una conexión a un servidor, y mil procesos leen mientras
otro escribe. **Es exactamente lo que se paga por no tener servidor.**

El orden de los hechos importa para entender el diseño. DuckDB toma el candado **al abrir** el archivo,
no al escribir: el escritor de `two_processes.py` está casi siempre dormido entre aterrizajes, y aun así
nadie más entra. Por eso no hay un volumen de rotura que calibrar —ni filas, ni escritores por segundo—:
basta que un proceso **tenga abierta** la base para escribir. Y por eso los dos lectores del final
conviven sin problema: abrir en `read_only` comparte el candado entre lectores, pero no con un escritor.

Lo que hay que cambiar para salir, en orden: que escriba **un solo proceso** y los demás reciban archivos
que él publica —Parquet nuevos, nunca el mismo archivo abierto—; que la escritura pase por un servicio
propio que hable con DuckDB; o, si de verdad hay varios escritores, **cambiar de familia**: la escritura
concurrente va en la fuente de verdad.

---

## 🚑 6. Salir de aquí

Cuando un sistema analítico embebido ya duele, en orden de costo:

1. **Configuración.** `memory_limit`, `threads` y un `temp_directory` con disco: la sección 4.4 muestra
   que con un hilo termina lo que con ocho falla. En Postgres, el equivalente para un analista es subir
   `work_mem` en su sesión, no en el servidor.
2. **Modelo de datos.** Las escrituras como eventos que solo se insertan (Fase 07, sección 8), las métricas
   calculables como expresiones al leer, y la tabla cargada en el orden en que se filtra, para que el
   mínimo y el máximo de cada grupo sirvan.
3. **Motor.** Si las consultas son de pocas filas y muchas columnas, o si la métrica nueva es un cálculo,
   Postgres alcanza (secciones 4.1 y 6 de la Fase 07). Si son de pocas columnas y todas las filas, un
   motor por columnas lee veinte veces menos.
4. **Arquitectura.** Un solo proceso escribe, la fuente de verdad sigue siendo `SIGMA` o Postgres, y
   DuckDB lee **una copia** —un Parquet que se regenera—. Es la arquitectura que pide Bengala en su
   miniproyecto, y la única en la que el segundo proceso no rompe nada.

---

## ❓ 7. Las cinco preguntas, respondidas para analítico embebido

1. **Frontera transaccional.** Ajena a la familia. DuckDB es ACID dentro de un proceso, pero no tiene
   candados de fila y no admite un segundo proceso escritor: la frontera de la operación vive en otro
   sitio, y el tablero lee lo que ella ya escribió.
2. **Consultas conocidas.** No hace falta conocerlas: cualquier agregación lee solo sus columnas, sin
   índices que crear. Es la familia que **mejor tolera la consulta nueva**, al revés que clave-valor.
3. **Unidad de lectura.** **Es la pregunta de esta familia**: pocas columnas de muchas filas. Para una
   aeronave con todas sus columnas, el B-tree de Postgres gana (Fase 07, sección 6.7).
4. **Saltos.** Ninguno propio: cruces de una dimensión pequeña con un hecho grande.
5. **Exactitud o parecido.** Exactitud, siempre. Es SQL, y el número sale igual dos veces: la Fase 07 lo
   comprobó al centavo.

---

## ⚖️ 8. Veredicto honesto: cuándo NO usar esto

> ⚖️ **No uses analítico embebido como base de la aplicación.** Con cuatro escritores en el mismo
> proceso perdió entre 272 y 403 de 8000 escrituras sin reintento (Fase 07), y con un segundo proceso
> escribiendo **no deja ni leer** (sección 5). **No lo uses si tus consultas son de pocas filas**: para
> una aeronave, Postgres lee 8,9 MiB con su índice y gana en su terreno. **Y no lo elijas por la métrica
> nueva si es un cálculo**: Postgres 18 la añade virtual sin escribir un byte, y DuckDB no puede.
>
> **Úsalo** cuando el dato **cabe en una máquina, cambia poco y lo leen decenas**: el costo por hora de
> Lucía lee **23,8 MiB contra 446,8**, la agregación de tres columnas **203 contra 4439**, una métrica
> guardada cuesta **51,8 MiB contra 14 GB de WAL**, y todo eso sin un servidor que cuidar.

Para Cóndor, el veredicto es el de un tablero: `SIGMA` y las lecturas siguen siendo la fuente de verdad,
un proceso nocturno publica el Parquet del mes, y Lucía, Édinson y Yamile lo consultan con DuckDB cada
uno desde su máquina. **El día que alguien quiera escribir en el tablero**, deja de ser esta familia.

---

## ⚠️ 9. Errores comunes y diagnóstico

**El segundo proceso** (E-08 en [`a09`](a09-catalogo-de-errores.md)): `IO Error: Could not set lock on
file "…": Conflicting lock is held in … (PID …)`. 🩺 El mensaje nombra el PID: `ps -p <PID>` dice quién
tiene el archivo. Ocurre también si el segundo proceso abre en `read_only`.

**Una columna generada después de crear la tabla** (E-41):

```text
Parser Error: Adding generated columns after table creation is not supported yet
```

🩺 DuckDB solo admite columnas generadas en el `CREATE TABLE`. Para una métrica calculada sobre una tabla
existente, una vista, o recrear la tabla.

**Sin memoria con muchos hilos** (E-42):

```text
Out of Memory Error: failed to pin block of size 256.0 KiB (122.3 MiB/122.0 MiB used)
```

🩺 El límite se reparte entre hilos. `SET threads = 1` lo terminó con 128 MB; o sube `memory_limit`.

**Sin memoria y sin dónde volcar** (E-43):

```text
Out of Memory Error: could not allocate block of size 256.0 KiB (488.3 MiB/488.2 MiB used)
```

🩺 `SELECT current_setting('temp_directory')`: si está vacío, DuckDB no puede volcar. Con disco, la misma
consulta terminó en 512 MB.

**Postgres que escribe gigas de temporales en una consulta de lectura.** Sin mensaje: tarda. 🩺
`EXPLAIN (ANALYZE, BUFFERS)` y busca `external merge  Disk:` y `Batches: N … Disk Usage`. Es `work_mem`
de 4 MB: súbelo en la sesión del analista.

**La tabla que dobla su tamaño tras un `UPDATE`.** 🩺 `pg_relation_size` antes y después, y
`n_dead_tup` en `pg_stat_user_tables`: son 50 M versiones muertas esperando a `VACUUM`.

---

## 📋 10. Checklist de validación

```text
[ ] alter.ts: el UPDATE de 50 M escribe ~14 GB de WAL y dobla la tabla; la columna virtual, 0
[ ] alter.py: la misma métrica crece el archivo de DuckDB 51,8 MiB; la virtual falla con E-41
[ ] La apuesta está escrita antes de la medición, con su resultado en dos mitades
[ ] explain.py: sé qué columnas proyecta el SEQ_SCAN de reading y por qué recorre 5 M y deja 4 929 892
[ ] cost_per_hour.sql lee 23,8 MiB en DuckDB y 446,8 MiB en Postgres
[ ] spill.py: sé con qué límite empieza a volcar el ORDER BY y por qué el GROUP BY no vuelca
[ ] spill.ts: sé por qué Postgres vuelca 3,5 GB agrupando por vuelo con work_mem de fábrica
[ ] two_processes.py: un lector no abre mientras hay un escritor
[ ] M-18 a M-20 en la bitácora, la apuesta 5 en su tabla, E-41 a E-43 en a09
```

---

## 🧪 11. Ejercicios (26)

Salvo donde se indique, desde `src/`, con la base de la Fase 07 construida. El código está en
`src/08-analitico-romper-y-medir/`.

### 🟢 Fácil — reproducir (1–6)

#### 🟢 Ejercicio 1 — Las cuatro formas

Corre `alter.ts` y `alter.py`.

**Objetivo:** reproducir la tabla de la sección 4.1, y decir qué columna esperas que cambie en otra
máquina.

#### 🟢 Ejercicio 2 — Las tuplas muertas

Después del `UPDATE` de `alter.ts --only update`, consulta `n_dead_tup` de `reading_alter` antes de que el
script la borre (comenta la última línea).

**Objetivo:** las 50 M versiones muertas, y cuánto devuelve un `VACUUM` y cuánto un `VACUUM FULL`.

#### 🟢 Ejercicio 3 — El plan entero

Corre `explain.py` y señala, de abajo arriba, en qué operador se reducen las filas de 5 M a 17.

**Pregunta:** ¿por qué el `HASH_GROUP_BY` va antes que el `HASH_JOIN`?

#### 🟢 Ejercicio 4 — El límite de memoria

Corre `spill.py`.

**Objetivo:** el primer límite en que el orden vuelca, y el mensaje con 128 MB y ocho hilos.

#### 🟢 Ejercicio 5 — El `work_mem`

Corre `spill.ts` y busca en el plan de la agrupación el `Batches` del agregado.

**Pregunta:** ¿cuántos lotes, y cuánto disco con 4 MB?

#### 🟢 Ejercicio 6 — Dos procesos

Corre `two_processes.py` y anota el PID del mensaje.

**Objetivo:** encontrar con `ps` el proceso que tenía el candado.

### 🟡 Intermedio — medir de otra forma (7–13)

#### 🟡 Ejercicio 7 — La métrica en una vista

En DuckDB, crea una vista con el margen de EGT sobre `reading_x10` y mide con el perfilador una
agregación sobre ella.

**Objetivo:** los bytes leídos, y por qué la vista es la salida al E-41.

#### 🟡 Ejercicio 8 — La virtual, al leer

En Postgres, añade la columna virtual y mide `avg(egt_margin_c)` con `BUFFERS`.

**Pregunta:** ¿lee más o menos que `avg(765 - egt_c)`? ¿Qué no ahorró la columna?

#### 🟡 Ejercicio 9 — Otra consulta en el plan

Escribe el pivote por año de la Fase 07 a un archivo y pásalo por `explain.py`.

**Objetivo:** qué operador hace el `PIVOT` y cuántas columnas lee de `reading`.

#### 🟡 Ejercicio 10 — `work_mem` en escalones

Repite la agrupación por vuelo en Postgres con 16, 64 y 256 MB.

**Objetivo:** el `work_mem` mínimo con el que no vuelca, y los lotes en cada escalón.

#### 🟡 Ejercicio 11 — Hilos contra memoria

Con 128 MB, ordena con 1, 2, 4 y 8 hilos.

**Objetivo:** con cuántos hilos empieza a fallar, y lo que vuelca cada uno que termina.

#### 🟡 Ejercicio 12 — El orden que se mantiene

Repite el orden de 50 M con `SET preserve_insertion_order = false`, que el mensaje del E-42 sugiere.

**Pregunta:** ¿cambia el volcado? ¿Por qué esa opción no aplica a un `ORDER BY`?

#### 🟡 Ejercicio 13 — El lector que espera

Modifica `two_processes.py` para que el lector reintente cada segundo hasta abrir.

**Objetivo:** cuánto espera, y qué pasaría con un tablero que se refresca cada minuto mientras el
escritor nunca suelta.

### 🟠 Difícil — diagnosticar y decidir (14–21)

#### 🟠 Ejercicio 14 — Predecir el WAL

Antes de medir, predice el WAL del `UPDATE` de una sola columna sobre `reading` (5 M). Después mídelo con
`alter.ts` cambiando la tabla.

**Objetivo:** tu número escrito antes, y si escala en línea recta con las filas.

#### 🟠 Ejercicio 15 — HOT

Repite el `UPDATE` sobre una copia creada con `fillfactor = 50`.

**Objetivo:** WAL, tamaño final y cuántas actualizaciones fueron HOT (`n_tup_hot_upd`). ¿Cambia el
resultado de la apuesta?

#### 🟠 Ejercicio 16 — La tabla de verdad ancha

Crea en los dos motores una tabla de 5 M filas con 60 columnas enteras y repite la métrica nueva.

**Objetivo:** cómo crece la diferencia con el ancho, y una frase sobre cuándo la apuesta pasa de un
orden de magnitud a dos.

#### 🟠 Ejercicio 17 — Un dato que no se calcula

La métrica nueva es el número de orden de trabajo que atendió cada vuelo, que viene de `work_order`.
Añádela en los dos motores.

**Objetivo:** por qué aquí la columna virtual no sirve, y lo que escribe cada uno.

#### 🟠 Ejercicio 18 — El volcado en el plan de Postgres

Para el orden de 50 M con 1 GB de `work_mem`, explica por qué sigue volcando 1777 MiB.

**Objetivo:** la cuenta de cuánta memoria necesitaría el orden en memoria, con el ancho de las tres
columnas.

#### 🟠 Ejercicio 19 — Un Parquet por escritor

Rediseña `two_processes.py` para que el escritor publique un Parquet nuevo cada minuto y el lector lea
el último.

**Objetivo:** que el lector nunca falle, y cuánto retraso tiene lo que ve.

#### 🟠 Ejercicio 20 — El reintento contra el candado

Un equipo propone reintentar el `connect` en bucle mientras el escritor trabaja.

**Pregunta:** ¿qué mide `two_processes.py` que hace inútil la propuesta, y qué lo arreglaría?

#### 🟠 Ejercicio 21 — La apuesta, con una columna generada

Recrea `reading_x10` en DuckDB con el margen de EGT como columna generada desde el `CREATE TABLE`.

**Objetivo:** lo que ocupa y lo que lee una agregación sobre ella, comparado con la vista del ejercicio 7.

### 🔴 Muy difícil — romper y autopsias (22–26)

#### 🔴 Ejercicio 22 — La autopsia del tablero con escritura

Bengala quiere que el cliente marque datos como revisados en el tablero. Con lo medido en las Fases 07 y
08, escribe la autopsia de la decisión de hacerlo sobre el mismo archivo de DuckDB.

**Objetivo:** los cinco pasos de la Fase 00, con las cifras de M-17 y M-20 como factura.

#### 🔴 Ejercicio 23 — El volcado que llena el disco

Pon `temp_directory` en un volumen pequeño (un disco en memoria de 512 MB) y ordena los 50 M con 256 MB.

**Objetivo:** el mensaje literal, y si DuckDB limpia lo que volcó. Si sale un error nuevo, entra en `a09`.

#### 🔴 Ejercicio 24 — La apuesta inversa

Escribe una apuesta nueva, antes de medir, donde Postgres gane a DuckDB en bytes escritos.

**Objetivo:** medirla y publicarla, gane o pierda.

#### 🔴 Ejercicio 25 — 200 millones y 8 GB

Amplía a ×40 y repite la agrupación por vuelo y el orden con el límite de memoria por defecto.

**Objetivo:** lo que vuelca cada motor, y en qué punto la máquina de laboratorio deja de servir.

#### 🔴 Ejercicio 26 — El veredicto de Cóndor

Con los números de las Fases 07 y 08, decide dónde vive el tablero de Lucía: en DuckDB, en Postgres o
en los dos.

**Objetivo:** una página con la decisión, quién escribe y quién lee, y la factura de cada opción.

### 🔥 Opcionales

- **MotherDuck o un servidor de DuckDB.** Qué cambia del punto de rotura cuando hay un proceso en medio;
  solo documentación, porque no se levanta.
- **`COPY … TO` particionado**, y el lector que solo abre la partición de su mes.

---

## 📚 12. Referencias

> ⚠️ Las URLs y sus contenidos cambian, y la documentación de estos productos cubre la última versión.
> Esta fase se verificó con DuckDB 1.5.6 y PostgreSQL 18.6.

- **DuckDB, concurrencia** — https://duckdb.org/docs/stable/connect/concurrency — un proceso escritor, y
  el candado.
- **DuckDB, memoria y volcado** — https://duckdb.org/docs/stable/guides/performance/how_to_tune_workloads
  — `memory_limit`, `threads`, `temp_directory`; es la página que cita el E-42.
- **DuckDB, `ALTER TABLE`** — https://duckdb.org/docs/stable/sql/statements/alter_table
- **DuckDB, columnas generadas** — https://duckdb.org/docs/stable/sql/statements/create_table
- **PostgreSQL 18, columnas generadas** — https://www.postgresql.org/docs/18/ddl-generated-columns.html —
  virtuales por defecto desde la 18.
- **PostgreSQL 18, `work_mem`** — https://www.postgresql.org/docs/18/runtime-config-resource.html
- **PostgreSQL 18, HOT** — https://www.postgresql.org/docs/18/storage-hot.html

**Orden sugerido:** columnas generadas de los dos antes de la sección 4.1; memoria y volcado durante la
4.4; concurrencia antes de la sección 5.

---

## 🏁 13. Resultado de la fase

Añadiste la misma métrica a 50 M lecturas en los dos motores y la apuesta salió en dos mitades: **51,8 MiB
contra 14 GB de WAL** si la métrica se guarda, **0 contra imposible** si se calcula. Viste a Postgres
volcar 3,5 GB agrupando lo que DuckDB agrupó en 128 MB, y a DuckDB fallar con ocho hilos lo que con uno
termina. Y encontraste el borde de la familia: **un segundo proceso no puede ni leer**.

> **La señal de que quedó bien:** *"Puedo decir, para una métrica nueva del tablero, cuánto escribe cada
> motor según sea un dato o un cálculo, y explicar por qué el tablero de Lucía no puede ser también el
> lugar donde la operación escribe."*

> 🏷️ **Tag:** `fase-08-analitico-romper-y-medir` · prefijo de commit `f08:`
