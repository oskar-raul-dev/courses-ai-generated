# 📓 Bitácora de medición

> **Curso:** Ruta SQL · documento vivo · **crece con el curso**
> **Qué es:** todas las mediciones del curso, en orden de ejecución: las publicadas, con sus números,
> y las apuestas sin resolver de Oracle y de SQL Server, con el comando para resolverlas. Cada
> entrada lleva los cinco datos de toda medición: qué se midió, el perfil de volumen, el motor con
> su digest, la máquina si hay tiempos, y el comando exacto. El Bloque VI argumenta citando estas
> entradas, y nada más.
> **Estado:** abierta el 12/10/2026; la primera entrada es la prueba de fuego de la
> [Fase 01](01-la-caja-y-el-arnes.md#46-la-prueba-de-fuego).

---

## 🖥️ Máquina de referencia

Apple M1 Pro, 8 núcleos, 32 GB de RAM, SSD, macOS 26.7.1 · Docker Desktop con motor 29.8.0, VM con
kernel `7.0.12-linuxkit` y **7,75 GiB** asignados · Python 3.13 y `uv` 0.11.14, con las versiones de
los drivers que fija `src/uv.lock` ([`a06`](a06-python-java-y-drivers.md#-uv-y-el-uvlock)); las
mediciones de Python se corren con `uv` dentro de un contenedor de la red del laboratorio.

> ⚠️ **Los tiempos de esta bitácora solo valen en esta máquina**, y ni siquiera ahí son argumento:
> son contexto. Este curso **mide la forma y no la velocidad**: bloques leídos, filas examinadas
> contra devueltas, filas estimadas contra reales, bytes de tabla, de índice y de WAL, filas
> bloqueadas. Eso es lo que se compara entre máquinas.

> 🔒 **Ninguna entrada de Oracle ni de SQL Server trae números.** Van como apuesta sin resolver: la
> hipótesis, el mecanismo que la sostiene y el comando para que la resuelvas tú.

---

## 🗂️ Índice por bloque

| Bloque | Fases | Entradas |
|---|---|---|
| 0 · El instrumento | F00–F02 | [M-01](#m-01--f01--la-prueba-de-fuego-el-arnés-cuenta-lo-que-declara-el-generador) · [M-04](#m-04--f01--el-recorrido-completo-de-protocolos-en-oracle) 🔒 |
| I · El modelo | F03–F08 | [M-05](#m-05--f03--la-presentación-de-rubén-pierde-más-de-lo-que-se-creía) · [M-06](#m-06--f03--la-obra-social-vacía-en-oracle) 🔒 · [M-07](#m-07--f04--el-90--del-parser-de-rubén) · [M-08](#m-08--f05--el-matcher-de-trigramas-no-llega-al-90-) · [M-09](#m-09--f05--jaro-winkler-en-oracle) 🔒 · [M-10](#m-10--f06--la-descomposición-en-tres-tablas-y-la-regla-cíclica) · [M-11](#m-11--f07--la-consulta-as-of-sobre-los-precios-en-rangos) · [M-12](#m-12--f07--flashback-query-en-oracle) 🔒 · [M-13](#m-13--f08--el-eav-contra-el-modelo-tipado) |
| II · La física y el tuning | F09–F14 | [M-14](#m-14--f09--reordenar-las-columnas-de-result) · [M-15](#m-15--f09--los-lob-securefiles-en-oracle) 🔒 · [M-16](#m-16--f10--uuidv4-y-uuidv7-como-clave-primaria-en-innodb) · [M-17](#m-17--f10--sys_guid-en-oracle) 🔒 · [M-18](#m-18--f11--el-wal-por-índice-y-lo-que-mata-hot) · [M-19](#m-19--f12--sede-y-prefijo-sin-estadísticas-extendidas) · [M-20](#m-20--f12--muestreo-dinámico-y-estadísticas-extendidas-en-oracle) 🔒 · [M-21](#m-21--f13--el-plan-genérico-de-la-consulta-por-sede) · [M-22](#m-22--f13--adaptive-cursor-sharing-en-oracle) 🔒 · [M-23](#m-23--f14--el-formulario-de-protocolos-del-frontal-de-2011) · [M-24](#m-24--f14--offset-y-keyset-en-oracle) 🔒 · [M-25](#m-25--f10--las-claves-en-innodb-en-la-validación-del-bloque-ii) · [M-26](#m-26--f11--el-wal-por-índice-en-la-validación-del-bloque-ii) |
| III · La concurrencia | F15–F18 | [M-27](#m-27--f15--la-muestra-tomada-dos-veces-en-cuatro-niveles-y-dos-motores) · [M-28](#m-28--f15--la-muestra-y-la-caja-en-el-serializable-de-oracle) 🔒 · [M-29](#m-29--f16--la-fila-contador-con-tres-cajas-y-diez-mil-comprobantes) · [M-30](#m-30--f16--la-secuencia-y-el-contador-en-oracle) 🔒 · [M-31](#m-31--f17--la-lectura-abierta-y-la-media-hora-más-cargada-de-la-caja) · [M-32](#m-32--f17--la-lectura-larga-contra-el-undo-de-oracle) 🔒 · [M-33](#m-33--f18--la-cola-detrás-de-un-alter-de-dos-milisegundos) · [M-34](#m-34--f18--la-cola-del-ddl-y-el-deadlock-en-oracle) 🔒 |
| IV · Lo NoSQL dentro del SQL | F19–F21 | [M-35](#m-35--f19--el-antibiograma-como-documento-en-la-búsqueda-por-un-resultado) · [M-36](#m-36--f19--el-wal-de-corregir-un-antibiótico-por-forma) · [M-37](#m-37--f19--mysql-la-búsqueda-en-el-json-y-el-redo-por-corrección) · [M-38](#m-38--f20--las-cinco-operaciones-en-tres-diseños) · [M-39](#m-39--f21--la-búsqueda-de-nombres-like-texto-completo-prefijo-y-trigramas) · [M-40](#m-40--f21--la-recursión-contra-el-informe-fijo-y-el-vector-léxico) · [M-41](#m-41--f21--el-boss-iv-el-informe-en-la-app-punto-de-partida-y-solución) · [M-78](#m-78--f21--el-diccionario-español-y-los-nombres-propios) |
| V · La base en la red | F22–F23 | [M-42](#m-42--f22--la-exportación-por-marca-de-agua-con-transacciones-concurrentes) · [M-43](#m-43--f22--la-fila-perdida-con-el-intercalado-determinista) · [M-44](#m-44--f22--la-cola-con-skip-locked-la-entrega-al-menos-una-vez-y-el-veneno) · [M-45](#m-45--f22--el-outbox-frente-a-la-doble-escritura-y-las-correcciones-con-versión) · [M-46](#m-46--f22--la-decodificación-lógica-con-test_decoding) · [M-47](#m-47--f23--lo-que-cuesta-la-seguridad-por-fila-y-dónde-va-el-índice) · [M-48](#m-48--f23--la-api-con-postgrest-vista-desde-afuera) · [M-49](#m-49--f23--el-md5-del-portal-de-2018-revertido) · [M-50](#m-50--f23--el-boss-v-las-940-punto-de-partida-y-solución) · [M-51](#m-51--f23--el-boss-del-puente-punto-de-partida-solución-y-hacía-falta-un-broker) |
| VI · El árbitro | F24–F26 | cita lo anterior, y mide la migración y el martes: [M-52](#m-52--f25--las-71-tablas-anchas-al-modelo-tipado-con-tres-reconciliaciones) · [M-53](#m-53--f25--la-cantidad-que-el-modelo-de-la-fase-07-no-trajo) · [M-54](#m-54--f25--la-convivencia-por-cdc-con-el-frontal-escribiendo-y-el-aplicador-cayéndose) · [M-55](#m-55--f25--el-maestro-de-pacientes-contra-el-del-sih-y-las-huellas-por-cubeta) · [M-56](#m-56--f25--el-simulacro-de-corte-y-su-vuelta-atrás) · [M-57](#m-57--f26--el-boss-global-un-martes-punto-de-partida-y-solución) |
| Track SQL Server | ss01–ss05 | [M-59](#m-59--ss01--bulk-insert-y-la-diferencia-entre--y-el-campo-vacío) 🔒 · [M-60](#m-60--ss01--el-t-sql-de-2016-en-su-motor-contra-su-port-de-la-fase-04) 🔒 · [M-61](#m-61--ss01--el-corte-de-los-años-de-dos-cifras-en-la-conexión-que-lo-cambia) 🔒 · [M-62](#m-62--ss02--el-formulario-del-almuerzo-frente-al-reporte-con-y-sin-rcsi) 🔒 · [M-63](#m-63--ss02--las-anomalías-de-la-fase-15-en-los-niveles-de-sql-server) 🔒 · [M-64](#m-64--ss02--el-version-store-de-una-lectura-snapshot-larga) 🔒 · [M-65](#m-65--ss02--la-misma-lectura-larga-en-postgres) · [M-66](#m-66--ss03--lo-que-le-cuesta-a-cada-sede-el-plan-que-eligió-la-otra) 🔒 · [M-67](#m-67--ss03--la-optimización-psp-sobre-la-consulta-por-sede) 🔒 · [M-68](#m-68--ss03--plan_cache_mode-fijado-para-el-rol-del-reporte) · [M-69](#m-69--ss04--cinco-claves-agrupadas-sobre-los-protocolos-de-la-caja) 🔒 · [M-70](#m-70--ss04--newsequentialid-después-de-reiniciar-en-linux) 🔒 · [M-71](#m-71--ss04--uuidv7-de-postgres-18-en-el-orden-en-que-se-genera) · [M-72](#m-72--ss05--el-índice-json-contra-la-columna-calculada-para-el-antibiograma) 🔒 · [M-73](#m-73--ss05--lo-que-cuesta-la-seguridad-por-fila-de-sql-server-en-el-portal) 🔒 · [M-74](#m-74--ss05--el-contrato-de-la-fase-23-por-data-api-builder-y-la-identidad-fabricada) |
| Apéndices | a02, a04, a06, a10 | [M-58](#m-58--a02--el-devshm-del-contenedor-de-postgres-y-el-hash-join-en-paralelo) · [M-02](#m-02--a06--un-ddl-en-medio-de-la-transacción-confirma-lo-pendiente) · [M-03](#m-03--a06--jdbc-confirma-cada-sentencia-y-los-drivers-de-python-no) · [M-75](#m-75--a04--el-wal-de-cien-filas-en-tres-corridas-seguidas) · [M-76](#m-76--a04--la-mitad-de-los-pacientes-actualizada-sin-cambiar-nada) · [M-77](#m-77--a10--el-parser-de-1998-en-tres-configuraciones-de-libreoffice) |

---

## 🧱 El formato de una entrada

Una entrada publicada:

```markdown
### M-NN · FNN · Qué se midió, en una línea
**Tipo:** publicada · **Motor:** PostgreSQL `imagen@sha256:…` · **Perfil:** M · **Fecha:** DD/MM/AAAA
**Hipótesis:** la apuesta, tal como se escribió antes de medir
**Resultado:** los números · **Apuesta:** ganada | perdida
**Reproducir:** `el comando exacto`
```

Una apuesta sin resolver:

```markdown
### M-NN · FNN · La misma medición en Oracle
**Tipo:** apuesta sin resolver · **Motor:** Oracle Free · **Perfil:** M
**Hipótesis:** … · **Resuélvela:** `el comando exacto`
```

Los identificadores `M-NN` no se reutilizan. **Una entrada publicada nunca se edita**: si la medición
se rehace con otra versión o con otro perfil, se agrega una entrada nueva que cita a la anterior.

---

## 📐 Entradas

### M-01 · F01 · La prueba de fuego: el arnés cuenta lo que declara el generador
**Tipo:** publicada · **Motor:** PostgreSQL `pgvector/pgvector@sha256:2358fcba361e…`, MySQL
`mysql@sha256:e2bde46db656…` y el conteo de la caja en Oracle · **Perfil:** M (y S) · **Fecha:** 12/10/2026
**Hipótesis:** cargada sin limpiar, `legacy."Pacientes"` tiene tantas filas con `DNI` dentro de `Nombre`
como declara `MANIFIESTO.json` (`fire_test`), en los tres motores.
**Resultado:** 18.936 en Postgres, MySQL y Oracle, contra 18.936 del manifiesto de M; 1.959 contra 1.959
en S. Las 419 tablas de `legacy` en Postgres tienen las mismas filas que sus CSV. · **Apuesta:** ganada
**Reproducir:** `SELECT count(*) FROM legacy."Pacientes" WHERE "Nombre" LIKE '%DNI%';` después de
`uv run lab load --profile m`, y `grep -A2 '"fire_test"' src/lab/caja/m/MANIFIESTO.json`

### M-02 · a06 · Un DDL en medio de la transacción confirma lo pendiente
**Tipo:** publicada · **Motor:** PostgreSQL y MySQL de `a02`, y el comportamiento documentado de Oracle ·
**Perfil:** no aplica (una tabla de prueba) · **Fecha:** 12/10/2026
**Hipótesis:** después de un `INSERT` sin confirmar, un `CREATE TABLE` y un `rollback`, la fila
insertada desaparece en los tres motores.
**Resultado:** desaparece solo en Postgres (0 filas); en MySQL queda (1 fila), y en Oracle también,
como dice su documentación. Lo mismo con `ALTER TABLE … ADD`. · **Apuesta:** perdida
**Reproducir:** `uv run python tres_preguntas.py` desde `src/`, con el script de
[`a06`](a06-python-java-y-drivers.md#️-tres-preguntas-a-cada-driver)

### M-03 · a06 · JDBC confirma cada sentencia, y los drivers de Python no
**Tipo:** publicada · **Motor:** PostgreSQL de `a02`, con psycopg 3.3.6, PyMySQL 1.2.3, python-oracledb
26.0.1 y el driver JDBC 42.7.14 en Java 25 · **Perfil:** M · **Fecha:** 12/10/2026
**Hipótesis:** un `UPDATE` seguido de una excepción, sin `commit`, no queda guardado, en Java igual que
en Python.
**Resultado:** los tres drivers de Python arrancan con `autocommit=False`; JDBC, con `true`, y el
`UPDATE` quedó (`name = INSTITUTO NACIONAL`). Con `setAutoCommit(false)` y `rollback()`, no (`name =
PAMI`). · **Apuesta:** perdida
**Reproducir:** `UpdateYExcepcion.java`, del solucionario de
[`a06`](soluciones/a06-python-java-y-drivers.md), con y sin el argumento `manual`

### M-04 · F01 · El recorrido completo de `Protocolos` en Oracle
**Tipo:** apuesta sin resolver · **Motor:** Oracle Free · **Perfil:** M
**Hipótesis:** el `TABLE ACCESS FULL` sobre `Protocolos` lee del mismo orden de bloques que el `Seq Scan`
de Postgres (15.696), porque las dos tablas tienen las mismas filas y los mismos tipos. Se publicó en la
[Fase 01](01-la-caja-y-el-arnes.md#45-cómo-se-mide-la-forma) y se registra aquí al cerrar T3. ·
**Resuélvela:** `uv run lab measure --engine oracle --profile m --private -c "SELECT * FROM
legacy.\"Protocolos\" WHERE \"NroProtocolo\" = 'C-0048213'"`, después de `uv run lab load --profile m
--engine oracle --tables Protocolos`, y mira la columna `Buffers`

### M-05 · F03 · La presentación de Rubén pierde más de lo que se creía
**Tipo:** publicada · **Motor:** PostgreSQL `pgvector/pgvector@sha256:2358fcba361e…` · **Perfil:** M ·
**Fecha:** 12/10/2026
**Hipótesis:** *"La consulta de Rubén pierde exactamente las prácticas de los protocolos con obra social
vacía."*
**Resultado:** para PAMI en diciembre de 2009, la verdad dice 1.413 prácticas; la consulta devuelve 1.314
filas y 1.203 prácticas. Pierde 88 por la obra social `NULL` o vacía (66 y 22), **y además** 122 sin precio
en la tabla del mes, y cuenta dos veces 111 por precios repetidos. · **Apuesta:** perdida
**Reproducir:** `src/03-lo-que-sql-le-hace-al-modelo/ruben_presentation.sql` contra `truth.order_payer`,
como en la [Fase 03](03-lo-que-sql-le-hace-al-modelo.md#-7-tu-instinto-dice-y-la-apuesta)

### M-06 · F03 · La obra social vacía en Oracle
**Tipo:** apuesta sin resolver · **Motor:** Oracle Free · **Perfil:** M
**Hipótesis:** cargada `Protocolos` de M en Oracle, `count(*) WHERE "ObraSocial" IS NULL` para diciembre de
2009 da la suma de los `NULL` y los vacíos que Postgres separa (39 + 20), y `WHERE "ObraSocial" = ''` no
devuelve ninguna fila. · **Resuélvela:** `uv run lab load --profile m --engine oracle --tables Protocolos` y
las dos consultas en `sqlplus` ([`a03`](a03-clis-de-los-motores.md#️-oracle--sqlplus))

### M-07 · F04 · El 90 % del parser de Rubén
**Tipo:** publicada · **Motor:** PostgreSQL `pgvector/pgvector@sha256:2358fcba361e…` · **Perfil:** M ·
**Fecha:** 12/10/2026
**Hipótesis:** *"El parser de Rubén acierta el DNI en el 90 % de las filas que dice la historia."*
**Resultado:** de 25.575 filas con un documento en `Nombre`, el port de 2016 en PL/pgSQL acierta 23.045
(90,1 %) y el de 2026 en Python, 23.048 (90,1 %). Las dos versiones difieren en 3 DNI (`OTRO`) y en 115
fechas (corte del año de dos dígitos en 2029 contra 2049). · **Apuesta:** ganada
**Reproducir:** `staging.extract_dni_2016` contra `truth.parser_case`, después de los scripts de
`src/04-un-valor-un-hecho/`, como en el ejercicio 9 de la [Fase 04](04-un-valor-un-hecho.md)

### M-08 · F05 · El matcher de trigramas no llega al 90 %
**Tipo:** publicada · **Motor:** PostgreSQL `pgvector/pgvector@sha256:2358fcba361e…` · **Perfil:** M ·
**Fecha:** 13/10/2026
**Hipótesis:** *"Trigramas sobre el nombre normalizado más la fecha de nacimiento encuentran al menos el
90 % de los duplicados con menos del 1 % de falsos positivos."*
**Resultado:** sobre 47.533 pares verdaderos y 1.144.780 candidatos del bloque (misma fecha o mismo
documento), la mejor regla con menos del 1 % de falsos es `(mismo documento y misma fecha) o trigramas ≥
0,6`: 85,7 % de exhaustividad y 0,89 % de falsos (364). Ninguna regla medida pasa del 90 %. De los 6.414
pares perdidos, 6.116 tienen una ficha `RN`; sin ellos, la misma regla encuentra el 99,0 %. El nivel
automático (mismo documento, misma fecha y trigramas ≥ 0,8): 19.620 pares, 0 falsos. · **Apuesta:** perdida
**Reproducir:** los siete scripts de `src/05-una-persona-no-es-su-documento/` y las consultas de los
ejercicios 9, 10 y 18 de la [Fase 05](05-una-persona-no-es-su-documento.md)

### M-09 · F05 · Jaro-Winkler en Oracle
**Tipo:** apuesta sin resolver · **Motor:** Oracle Free · **Perfil:** no aplica (cuatro pares literales)
**Hipótesis:** `UTL_MATCH.JARO_WINKLER_SIMILARITY('OLMOS PAEZ', 'OLMOS RAUL')` da 80 o más, aunque los
trigramas den 0,38, porque Jaro-Winkler premia el prefijo común; y por eso, sobre apellidos compartidos por
familias enteras, aceptaría más falsos positivos que los trigramas al mismo nivel de exhaustividad. ·
**Resuélvela:** `SELECT UTL_MATCH.JARO_WINKLER_SIMILARITY('OLMOS PAEZ', 'OLMOS RAUL') FROM dual;` en
`sqlplus`, con los cuatro pares de la sección 5.4 de la Fase 05

### M-10 · F06 · La descomposición en tres tablas y la regla cíclica
**Tipo:** publicada · **Motor:** PostgreSQL `pgvector/pgvector@sha256:2358fcba361e…` · **Perfil:** M ·
**Fecha:** 13/10/2026
**Hipótesis:** *"La descomposición en tres tablas binarias no pierde ni inventa filas si, y solo si, la regla de
negocio es cíclica"*, demostrada con el generador en las dos variantes.
**Resultado:** con la regla cíclica de la planilla de 2026, 556 + 241 + 38 filas reconstruyen los 1.422 convenios
con 0 espurios y 0 perdidos; con la variante no cíclica (semilla 1996, 10 % de exclusiones), 1.305 convenios
y 107 espurios (138 con la semilla 1997, 133 con 2026). Dos tablas binarias inventan 361 aun con la regla
cíclica. · **Apuesta:** ganada
**Reproducir:** los cinco scripts de `src/06-cuarta-y-quinta-forma-normal/` y el ejercicio 17 de la
[Fase 06](06-cuarta-y-quinta-forma-normal.md)

### M-11 · F07 · La consulta *as-of* sobre los precios en rangos
**Tipo:** publicada · **Motor:** PostgreSQL `pgvector/pgvector@sha256:2358fcba361e…` · **Perfil:** M ·
**Fecha:** 14/10/2026
**Hipótesis:** *"La consulta as-of sobre el modelo de rangos devuelve el precio correcto en los 280 meses; la
unión de las 280 tablas falla en los meses donde dos vigencias se superponen."*
**Resultado:** sobre 20.792 pares de práctica y mes, la unión da dos filas en 187 pares (131 meses) y ninguna en
425 (219 meses); los rangos resuelven los 187 y no devuelven nada en los 425. Con la UB del mes como hecho,
20.792 de 20.792. · **Apuesta:** perdida
**Reproducir:** los scripts 01 y 02 de `src/07-el-tiempo-en-el-modelo/` y los ejercicios 15 y 16 de la
[Fase 07](07-el-tiempo-en-el-modelo.md)

### M-12 · F07 · *Flashback Query* en Oracle
**Tipo:** apuesta sin resolver · **Motor:** Oracle Free · **Perfil:** no aplica (una tabla de una fila)
**Hipótesis:** `SELECT … AS OF TIMESTAMP` devuelve el valor anterior de un resultado corregido hace un minuto, sin
tabla de historia; uno corregido hace un día ya no, porque la retención de *undo* no lo garantiza. ·
**Resuélvela:** el `UPDATE` con `COMMIT` y la consulta `AS OF TIMESTAMP` del ejercicio 23 de la Fase 07, en
`sqlplus`, con `SHOW PARAMETER undo_retention`

### M-13 · F08 · El EAV contra el modelo tipado
**Tipo:** publicada · **Motor:** PostgreSQL `pgvector/pgvector@sha256:2358fcba361e…` · **Perfil:** M ·
**Fecha:** 14/10/2026
**Hipótesis:** *"La consulta clínica sobre el EAV lee al menos 10 veces más bloques que sobre el modelo tipado, y su
estimación de filas se equivoca por al menos un orden de magnitud."*
**Resultado:** con los mismos índices en los cuatro modelos y 31.083 glucemias en todos: EAV 269.760 bloques
(estimación 6,3 veces), tipado 176.902 (4,6 veces), `jsonb` 77.248 (1,06), tabla ancha 29.304 (1,06). El EAV
lee 1,5 veces lo del tipado, no 10. · **Apuesta:** perdida
**Reproducir:** `uv run lab load --profile m --model` y las consultas de los ejercicios 8 al 11 de la
[Fase 08](08-los-dos-extremos-del-mismo-error.md)

### M-14 · F09 · Reordenar las columnas de result
**Tipo:** publicada · **Motor:** PostgreSQL `pgvector/pgvector@sha256:2358fcba361e…` · **Perfil:** M ·
**Fecha:** 14/10/2026
**Hipótesis:** *"Reordenar las columnas de `result` reduce su tamaño en al menos un 10 %."*
**Resultado:** reordenada, `result` ocupa exactamente lo mismo, 87.835 bloques (686 MB): el promedio por fila baja de
54,8 a 49,8 bytes y se pierde en el redondeo a 8 bytes. Una tabla con booleanos entre `bigint` sí baja, de 12.414 a 9.767
bloques (−21 %). · **Apuesta:** perdida
**Reproducir:** `src/09-el-tamano-de-las-cosas/03_alignment.sql` con `psql`, después de `uv run lab load --profile m --model`

### M-15 · F09 · Los LOB SecureFiles en Oracle
**Tipo:** apuesta sin resolver · **Motor:** Oracle Free · **Perfil:** M
**Hipótesis:** un BLOB de 90 kB en una columna `SecureFiles` se guarda fuera de la fila, y una consulta que lee solo los
metadatos no toca sus bloques, como TOAST en Postgres. · **Resuélvela:** una tabla con los 2.000 informes de
`staging.report_pdf_bytea` y la consulta por fecha con `SET AUTOTRACE TRACEONLY STATISTICS` en `sqlplus`, como pide la
[Fase 09](09-el-tamano-de-las-cosas.md)

### M-16 · F10 · UUIDv4 y UUIDv7 como clave primaria en InnoDB
**Tipo:** publicada · **Motor:** MySQL `mysql@sha256:e2bde46db656…` · **Perfil:** M · **Fecha:** 14/10/2026
**Hipótesis:** *"Con UUIDv4 como clave primaria en InnoDB, el índice primario del perfil M queda al menos un 30 % más
grande que con `bigint`, y con UUIDv7 la diferencia baja a menos del 10 %."*
**Resultado:** índice primario de 48,6 MB con `bigint`, 93,8 MB con UUIDv4 (+93 %) y 59,6 MB con UUIDv7 (+23 %); el índice
por paciente, de 37,6 a 54,6 MB. En Postgres, 28, 54 y 40 MB, y el índice por paciente igual en los tres. · **Apuesta:** perdida
**Reproducir:** `uv run python 10-identificadores/mysql_keys.py` desde `src/`, y `01_postgres_keys.sql` y
`02_load_keys.sql` de la [Fase 10](10-identificadores.md) con `psql`

### M-17 · F10 · SYS_GUID en Oracle
**Tipo:** apuesta sin resolver · **Motor:** Oracle Free · **Perfil:** M
**Hipótesis:** los valores de `SYS_GUID()` de una misma sesión crecen casi en orden, y un índice primario `RAW(16)` cargado con
ellos queda mucho más cerca del UUIDv7 que del UUIDv4 de MySQL. · **Resuélvela:** los protocolos de M en una tabla con
`DEFAULT SYS_GUID()`, y el tamaño del índice con `DBMS_SPACE` en `sqlplus`, como pide la [Fase 10](10-identificadores.md)

### M-18 · F11 · El WAL por índice y lo que mata HOT
**Tipo:** publicada · **Motor:** PostgreSQL `pgvector/pgvector@sha256:2358fcba361e…` · **Perfil:** M ·
**Fecha:** 14/10/2026
**Hipótesis:** *"Cada índice adicional sobre `result` agrega bytes de WAL por fila en proporción a su ancho, y el cuarto
índice anula las actualizaciones HOT del flujo de correcciones."*
**Resultado:** 146,8 bytes de WAL por fila sin índices y 672,4 con ocho; cada índice agrega entre 48 y 89 bytes, sin relación
con su ancho. HOT: 1 % con `fillfactor` 100, 100 % con 90 y un cuarto índice sobre `recorded_at`, 0 % con un cuarto índice
sobre `value_numeric`. · **Apuesta:** perdida
**Reproducir:** `src/11-indices-y-lo-que-cuestan/01_write_cost.sql` y `02_hot_updates.sql` con `psql`

### M-19 · F12 · Sede y prefijo sin estadísticas extendidas
**Tipo:** publicada · **Motor:** PostgreSQL `pgvector/pgvector@sha256:2358fcba361e…` · **Perfil:** M ·
**Fecha:** 14/10/2026
**Hipótesis:** *"Sin estadísticas extendidas, la estimación del filtro por sede y prefijo se equivoca por al menos 10 veces,
y eso cambia el método de join."*
**Resultado:** 165 filas estimadas por proceso contra 26.973 reales (163 veces); con `CREATE STATISTICS`, 34.537. El join
con `result_eav` pasa de *nested loop* a *hash join* en 10 de 10 `ANALYZE`, y el plan nuevo es 5 veces más lento con la caché
caliente (mediana 697 contra 134 ms), por un segundo error que las estadísticas de una tabla no corrigen (60 resultados
estimados por protocolo, 1 real). · **Apuesta:** ganada
**Reproducir:** `src/12-estadisticas-y-cardinalidad/01_text_and_correlation.sql` con `psql`, y los ejercicios 15 y 16 de la
[Fase 12](12-estadisticas-y-cardinalidad.md)

### M-20 · F12 · Muestreo dinámico y estadísticas extendidas en Oracle
**Tipo:** apuesta sin resolver · **Motor:** Oracle Free · **Perfil:** M
**Hipótesis:** con el muestreo dinámico en su nivel por defecto y sin estadísticas extendidas, el filtro por sede y prefijo se
estima igual de mal que en Postgres; con `DBMS_STATS.CREATE_EXTENDED_STATS` sobre el grupo de columnas, dentro de 2 veces.
**Resuélvela:** `E-Rows` contra `A-Rows` con `DBMS_XPLAN.DISPLAY_CURSOR(format => 'ALLSTATS LAST')` en `sqlplus`, antes y
después de las estadísticas extendidas, como pide la [Fase 12](12-estadisticas-y-cardinalidad.md)

### M-21 · F13 · El plan genérico de la consulta por sede
**Tipo:** publicada · **Motor:** PostgreSQL `pgvector/pgvector@sha256:2358fcba361e…` · **Perfil:** M ·
**Fecha:** 14/10/2026
**Hipótesis:** *"A partir de la sexta ejecución, el plan genérico elige para el laboratorio central el mismo método que para
un centro chico, y lee al menos 10 veces más."*
**Resultado:** si la sesión empieza en los centros, 0 planes genéricos en 6 ejecuciones; si empieza en el central, el
genérico se usa en la sexta y es el centro V el que hereda el *hash join* del central: 87.945 contra 10.865 bloques (8,1
veces) y 242 contra 22 ms. Psycopg 3 llega al genérico en la undécima ejecución. · **Apuesta:** perdida
**Reproducir:** `src/13-el-optimizador-en-tres-motores/01_generic_plans.sql` con `psql`, y
`uv run python 13-el-optimizador-en-tres-motores/psycopg_prepare.py` desde `src/`

### M-22 · F13 · Adaptive cursor sharing en Oracle
**Tipo:** apuesta sin resolver · **Motor:** Oracle Free · **Perfil:** M
**Hipótesis:** con la consulta por sede preparada con una variable de enlace, Oracle mira el valor de la primera ejecución y
arma el plan del central; después de unas pocas ejecuciones de la sede V, el *adaptive cursor sharing* crea un segundo plan
para los centros chicos. · **Resuélvela:** `CHILD_NUMBER`, `IS_BIND_SENSITIVE` e `IS_BIND_AWARE` de `V$SQL` entre ejecuciones,
con un histograma sobre `site_code`, en `sqlplus`, como pide la [Fase 13](13-el-optimizador-en-tres-motores.md)

### M-23 · F14 · El formulario de protocolos del frontal de 2011
**Tipo:** publicada · **Motor:** MySQL `mysql@sha256:e2bde46db656…` · **Perfil:** M · **Fecha:** 14/10/2026
**Hipótesis:** *"El formulario de protocolos trae al menos mil veces más filas de las que muestra."*
**Resultado:** 7 viajes, 1.327.682 filas y 17.337.090 bytes para mostrar 60 (22.128 veces en filas, 3.046 en bytes), contra 1
viaje, 60 filas y 5.692 bytes pidiendo lo que muestra. El N+1, 61 viajes contra 2; el join en el cliente, 242.427 pacientes
para 249. · **Apuesta:** ganada
**Reproducir:** `src/14-la-base-no-estaba-lenta/01_autoindex_copy.sql` con el cliente `mysql`, y
`uv run python 14-la-base-no-estaba-lenta/front.py` desde `src/`

### M-24 · F14 · OFFSET y keyset en Oracle
**Tipo:** apuesta sin resolver · **Motor:** Oracle Free · **Perfil:** M
**Hipótesis:** la página 50.000 con `OFFSET … FETCH NEXT 20 ROWS ONLY` lee las filas descartadas igual que Postgres, y el
*keyset* con comparación de filas usa el índice `(ordered_on, lab_order_id)` como rango, como Postgres y no como MySQL. ·
**Resuélvela:** las dos consultas con `DBMS_XPLAN.DISPLAY_CURSOR(format => 'ALLSTATS LAST')` en `sqlplus`, como pide la
[Fase 14](14-la-base-no-estaba-lenta.md)

### M-25 · F10 · Las claves en InnoDB, en la validación del Bloque II
**Tipo:** publicada · **Motor:** MySQL `mysql@sha256:e2bde46db656…` · **Perfil:** M · **Fecha:** 14/10/2026
**Hipótesis:** la de [M-16](#m-16--f10--uuidv4-y-uuidv7-como-clave-primaria-en-innodb), medida otra vez sobre una carga nueva.
**Resultado:** `bigint` 48,6 MB y UUIDv7 59,6 MB, exactamente como en M-16; UUIDv4 95,8 MB (6.129 páginas, +97 %), contra
93,8 MB en M-16: un índice cargado al azar no mide lo mismo dos veces. En Postgres, el primario con UUIDv4 dio 52 MB (54 en
M-16). La apuesta sigue perdida por la misma razón: el v7 queda un 23 % por encima. · **Apuesta:** perdida
**Reproducir:** el de M-16

### M-26 · F11 · El WAL por índice, en la validación del Bloque II
**Tipo:** publicada · **Motor:** PostgreSQL `pgvector/pgvector@sha256:2358fcba361e…` · **Perfil:** M ·
**Fecha:** 14/10/2026
**Hipótesis:** la de [M-18](#m-18--f11--el-wal-por-índice-y-lo-que-mata-hot), medida otra vez sobre una carga nueva.
**Resultado:** 146,7 bytes por fila sin índices y 672,4 con ocho, como en M-18, pero otro reparto: el séptimo índice sumó
138,4 y el octavo 5,1 (78,6 y 64,9 en M-18). Lo que agrega cada índice varía entre corridas; la suma no, y ninguna corrida
siguió el ancho de las claves. HOT, idéntico: 98, 9.488, 9.488 y 0 de 9.488. · **Apuesta:** perdida
**Reproducir:** el de M-18

### M-27 · F15 · La muestra tomada dos veces, en cuatro niveles y dos motores
**Tipo:** publicada · **Motor:** PostgreSQL `pgvector/pgvector@sha256:2358fcba361e…` y MySQL `mysql@sha256:e2bde46db656…` ·
**Perfil:** M · **Fecha:** 14/10/2026
**Hipótesis:** *"El* write skew *de la muestra pasa en `REPEATABLE READ` de Postgres, y en `SERIALIZABLE` una de las dos
transacciones falla con un error de serialización (`40001`). En MySQL, `REPEATABLE READ` también lo deja pasar, y
`SERIALIZABLE` lo frena con un* deadlock *(1213), no con un error de serialización."*
**Resultado:** Postgres: dos tomas en `READ COMMITTED` y `REPEATABLE READ`, `40001` en el `COMMIT` de b en `SERIALIZABLE`.
MySQL: dos tomas en `REPEATABLE READ`, `1213` en el `INSERT` de b en `SERIALIZABLE`, y también en `REPEATABLE READ` con la lectura
`FOR UPDATE` (*gap lock*), que en Postgres no bloquea. La matriz de seis anomalías, igual en dos corridas; la actualización
perdida pasa en el `REPEATABLE READ` de MySQL (23,00 en vez de 13,00) y no en el de Postgres (`40001`). Con cuatro técnicos en
hilos, `SERIALIZABLE` sin bucle pierde 284–301 tomas de 400; con bucle, 0, a 2,5–2,9 reintentos por toma (5,8 con dieciséis);
con `UNIQUE` en `READ COMMITTED`, 0 perdidas y 0 duplicadas. · **Apuesta:** ganada
**Reproducir:** `uv run lab race -f 15-aislamiento-comparado/write_skew.race --isolation serializable` (y `write_skew_mysql.race`),
`uv run python 15-aislamiento-comparado/matrix.py` y `uv run python 15-aislamiento-comparado/technicians.py` desde `src/`

### M-28 · F15 · La muestra y la caja en el `SERIALIZABLE` de Oracle
**Tipo:** apuesta sin resolver · **Motor:** Oracle Free · **Perfil:** M
**Hipótesis:** en Oracle, `SERIALIZABLE` deja pasar el *write skew* de la muestra (los dos técnicos confirman) y la actualización
perdida termina en `ORA-08177` para la segunda caja. · **Resuélvela:** los pasos de `write_skew.race` y `lost_update.race` a mano en
dos sesiones de `sqlplus` con `SET TRANSACTION ISOLATION LEVEL SERIALIZABLE`, como pide la
[Fase 15](15-aislamiento-comparado.md)

### M-29 · F16 · La fila contador con tres cajas y diez mil comprobantes
**Tipo:** publicada · **Motor:** PostgreSQL `pgvector/pgvector@sha256:2358fcba361e…` · **Perfil:** M · **Fecha:** 14/10/2026
**Hipótesis:** *"Con la fila contador, tres cajas concurrentes emiten 10.000 comprobantes con cero duplicados y cero huecos, y
la espera por comprobante crece con la duración de la transacción que retiene el número."*
**Resultado:** 10.000 autorizados contra el organismo simulado (del 247.582 al 257.581), 0 repetidos, 0 huecos, 0 rechazos, espera
media por el número 5,4 ms. Con el comprobante armado mientras el número está tomado, la espera pasa de 5,5 a 11,9, 22,8 y 36,0 ms
con 0, 2, 5 y 10 ms de armado; con el número asignado al autorizar, entre 0,8 y 2,0 ms. Con el organismo a 50 ms y 900
comprobantes: `UltimoNumero` 180 rechazos 10016, `DMax + 1` 2.404, la fila contador 0. Un punto de venta por caja: 0,21 ms. ·
**Apuesta:** ganada
**Reproducir:** `uv run python 16-el-folio-sin-huecos/cajas.py --design counter --invoices 10000` y las variantes de `--design`,
`--hold` y `--latency` desde `src/`, después de `01_setup.sql`

### M-30 · F16 · La secuencia y el contador en Oracle
**Tipo:** apuesta sin resolver · **Motor:** Oracle Free · **Perfil:** M
**Hipótesis:** una secuencia `NOCACHE ORDER` también deja el hueco del `ROLLBACK`, y la fila contador con `UPDATE … RETURNING
INTO` serializa las cajas igual que en Postgres. · **Resuélvela:** los pasos de `races.py sequence` y `races.py counter` a mano en
dos sesiones de `sqlplus`, como pide la [Fase 16](16-el-folio-sin-huecos.md)

### M-31 · F17 · La lectura abierta y la media hora más cargada de la caja
**Tipo:** publicada · **Motor:** PostgreSQL `pgvector/pgvector@sha256:2358fcba361e…` y MySQL `mysql@sha256:e2bde46db656…` ·
**Perfil:** M · **Fecha:** 14/10/2026
**Hipótesis:** *"Una lectura abierta durante 30 minutos mientras se corrigen resultados deja la tabla al menos al doble de su
tamaño, y VACUUM no la achica."*
**Resultado:** con la exportación abierta y los 620 resultados de la media hora más cargada corregidos de a uno, la tabla del día
pasa de 39 a 43 páginas (1,10 veces) y una copia de `alameda.result` no crece (87.808); `VACUUM` no devuelve ninguna página. Donde
sí: la fila contador con 10.000 actualizaciones, 1 página sin la exportación y 45 con ella (10.000 muertas que `VACUUM` no puede
borrar, 45 páginas después de cerrarla), y 44 páginas más por cada tanda de 10.000 mientras siga abierta. `ParaLlamar`: 282–308
bytes de WAL por llamada con `UPDATE` contra 120 con `INSERT`, y la lista de pendientes en 40 bloques y 3.141 visitas por lectura
con la exportación abierta, contra 6 bloques sin ella. MySQL: la tabla en 112 KB, la *history list length* en 10.003, y la lectura
abierta 5,4 ms contra 0,17 de una nueva (56 contra 0,29 con 100.000 cambios). · **Apuesta:** perdida (el tamaño), ganada (`VACUUM`)
**Reproducir:** `uv run python 17-mvcc-y-su-factura/mvcc.py counter|results|para_llamar` y
`uv run python 17-mvcc-y-su-factura/mysql_history.py` desde `src/`

### M-32 · F17 · La lectura larga contra el undo de Oracle
**Tipo:** apuesta sin resolver · **Motor:** Oracle Free · **Perfil:** M
**Hipótesis:** con un tablespace de *undo* chico y `UNDO_RETENTION` bajo, una lectura `READ ONLY` abierta mientras otra sesión
actualiza diez mil veces el contador falla con `ORA-01555` al releer la fila, y con `UNDO_RETENTION` suficiente no falla. ·
**Resuélvela:** dos sesiones de `sqlplus`, como pide la [Fase 17](17-mvcc-y-su-factura.md)

### M-33 · F18 · La cola detrás de un ALTER de dos milisegundos
**Tipo:** publicada · **Motor:** PostgreSQL `pgvector/pgvector@sha256:2358fcba361e…` · **Perfil:** M · **Fecha:** 14/10/2026
**Hipótesis:** *"Un `ALTER TABLE` que espera detrás de una lectura larga bloquea a todas las sesiones nuevas, aunque él mismo tarde
milisegundos."*
**Resultado:** con la exportación abierta 3 s sobre `staging.result_ddl` (12,1 M filas) y `ADD COLUMN … DEFAULT false` (2 ms de
trabajo), las 30 lecturas que llegaron en esos 3 s quedaron en la cola: 21 esperaron más de 1 s, la peor 3,06 s. Con un valor volátil
(reescribe, 11,2 s), 30 de 30 y la peor 13,02 s; con `lock_timeout` de 1 s, reintento y el valor constante, 0 de 30 y la peor 0,98 s.
`pg_locks` muestra la cola: la lectura nueva bloqueada por el `ALTER`, no por la exportación. En MySQL, la misma cola con el
*metadata lock*, aun con `ALGORITHM=INSTANT`, y `lock_wait_timeout` de un año. · **Apuesta:** ganada
**Reproducir:** `uv run python 18-bloqueos-deadlocks-y-ddl/ten_am.py` y `uv run lab race -f 18-bloqueos-deadlocks-y-ddl/ddl_queue.race`
desde `src/`, después de `01_setup.sql`

### M-34 · F18 · La cola del DDL y el deadlock en Oracle
**Tipo:** apuesta sin resolver · **Motor:** Oracle Free · **Perfil:** M
**Hipótesis:** en Oracle la cola de `ddl_queue.race` no se forma: la lectura abierta no retiene bloqueos de tabla y el `ALTER`
termina enseguida; con un `UPDATE` sin confirmar, el `ALTER` falla en el acto con `ORA-00054` (`DDL_LOCK_TIMEOUT` 0); el *deadlock*
termina en `ORA-00060` para una de las dos, que conserva el resto de su transacción. · **Resuélvela:** tres sesiones de `sqlplus`,
como pide la [Fase 18](18-bloqueos-deadlocks-y-ddl.md)

### M-35 · F19 · El antibiograma como documento, en la búsqueda por un resultado
**Tipo:** publicada · **Motor:** PostgreSQL `pgvector/pgvector@sha256:2358fcba361e…` · **Perfil:** M · **Fecha:** 14/10/2026
**Hipótesis:** la búsqueda de antibiogramas resistentes a un antibiótico, con GIN `jsonb_path_ops`, lee menos del 1 % de los bloques del seq scan.
**Resultado:** meropenem (600 cultivos): forma larga 4.686 bloques; documento sin índice 1.920; GIN `jsonb_ops` 1.632; GIN `jsonb_path_ops` 527, el 27 % del seq scan. Ciprofloxacina (13.303 cultivos, el 22 %): el índice no ayuda, 1.915 bloques. Los 600 cultivos caen en 524 páginas: la lectura no se concentra. · **Apuesta:** perdida
**Reproducir:** `docker exec -i alameda-lab-postgres-1 psql -U postgres -d alameda < 19-json-en-los-motores/02_busquedas.sql` desde `src/`, después de `01_setup.sql`

### M-36 · F19 · El WAL de corregir un antibiótico, por forma
**Tipo:** publicada · **Motor:** PostgreSQL `pgvector/pgvector@sha256:2358fcba361e…` · **Perfil:** M · **Fecha:** 14/10/2026
**Hipótesis:** cada corrección de un antibiótico reescribe el documento entero en WAL.
**Resultado:** en régimen, tras un `CHECKPOINT` y cuatro corridas por forma: fila larga 112 bytes; documento de cultivo 672 bytes; historia del paciente, con cinco cultivos, 1.528 bytes. Tras un punto de control aparecen picos (9.928 y 31.936 bytes): imágenes completas de página, y por eso se reporta la corrida estable. · **Apuesta:** ganada, con matiz: el documento más grande pesa 1,5 kB, bajo el umbral de TOAST
**Reproducir:** `docker exec -i alameda-lab-postgres-1 psql -U postgres -d alameda < 19-json-en-los-motores/03_wal.sql`

### M-37 · F19 · MySQL: la búsqueda en el JSON y el redo por corrección
**Tipo:** publicada · **Motor:** MySQL `mysql@sha256:e2bde46db656…` (9.7) · **Perfil:** M · **Fecha:** 14/10/2026
**Hipótesis:** contraste: el JSON binario con una columna generada indexada resuelve la búsqueda sin GIN.
**Resultado:** escaneo con el índice ignorado: 60.001 filas, 40,7 ms; columna generada indexada: 600 filas, 0,2 ms. Redo por corrección: fila larga 1.024 bytes; documento con `JSON_SET`, de 1.024 a 1.536 bytes. La granularidad de 512 bytes del redo tapa la diferencia de la fila pequeña. · **Apuesta:** no aplica (contraste)
**Reproducir:** `04_mysql_setup.sql` y `05_mysql_medidas.sql` en el contenedor de MySQL, con la caja copiada a `/tmp` del contenedor

### M-38 · F20 · Las cinco operaciones en tres diseños
**Tipo:** publicada · **Motor:** PostgreSQL `pgvector/pgvector@sha256:2358fcba361e…` y MongoDB `mongo@sha256:098862b1339f…` (8.0.20) · **Perfil:** muestra de 50.000 protocolos de 2025, con 531.736 resultados y 21.198 correcciones simuladas · **Fecha:** 14/10/2026
**Hipótesis:** leer el informe armado con `json_agg` cuesta como mucho tres veces las lecturas del documento en Mongo, y el cruce epidemiológico en Mongo examina todos los documentos.
**Resultado:** O1 leer: R 0,78 ms, J 0,54, M 0,65. O2 corregir: R 2,45, J 1,83, **M 1,46**. O3 presentación: **R 16,1**, J 65, M 26,9. O4 cruce: **R 25,8**, J 97, M 289 (252 con índice multikey; 31.673 documentos). O5 auditoría: **R 0,72**, J 252, M 103 (83 con índice; 20.417 documentos). Medianas de cinco tras calentamiento. · **Apuesta:** ganada en las dos mitades (1,2 veces; 50.000 de 50.000 documentos examinados)
**Reproducir:** `01_muestra.sql`, `02_cargar_mongo.py` y `03_jsonb.sql` en Postgres; `04_medir.py` con `uv run --with pymongo`

### M-39 · F21 · La búsqueda de nombres: LIKE, texto completo, prefijo y trigramas
**Tipo:** publicada · **Motor:** PostgreSQL `pgvector/pgvector@sha256:2358fcba361e…` con `pg_trgm` y `unaccent` · **Perfil:** M, 223.889 pacientes sin fusionar · **Fecha:** 14/10/2026
**Hipótesis:** sin apuesta de la ficha: el texto completo en español resuelve la búsqueda de nombres.
**Resultado:** `LIKE '%PEREZ%'` sin índice, 15,4 ms y 3.136 bloques; texto completo sin índice, 12,3 ms; con GIN, 2,9 ms y 2.306 bloques; trigramas con `LIKE`, 5,0 ms y 2.345 bloques. Las cuatro devuelven 4.173 pacientes para la palabra. Prefijo: 8.577 en texto completo contra 7.748 con `LIKE 'PER%'`. Error de tipeo `RODRIGES`: 139 en texto completo; 1.479 con trigramas a 0,3 (6.682 a 0,2; 43 a 0,5). · **Apuesta:** no aplica; el hallazgo es que el texto completo busca palabras y no tolera errores
**Reproducir:** `01_setup.sql` y `02_nombres.sql`, desde `src/21-hasta-donde-llega-el-motor/`

### M-40 · F21 · La recursión contra el informe fijo, y el vector léxico
**Tipo:** publicada · **Motor:** PostgreSQL `pgvector/pgvector@sha256:2358fcba361e…` · **Perfil:** 75 prácticas, con una composición supuesta por el curso · **Fecha:** 14/10/2026
**Hipótesis:** el CTE recursivo examina menos filas que el informe de cuatro `LEFT JOIN` fijos.
**Resultado:** con siete filas de composición, las dos formas leen la tabla entera: no hay diferencia de filas que medir. Con una jerarquía de profundidad cinco, el informe fijo ve 9 de 10 nodos distintos; la recursiva, los 10. Un ciclo con `UNION` termina con 7 nodos. El vecino más cercano de `HEMOGRAMA COMPLETO` en el vector de trigramas es `HEPATOGRAMA` (coseno 0,404): léxico, no semántico. El índice HNSW se usa con la subconsulta escalar y no con `JOIN`. · **Apuesta:** no decidida (la comparación pedida no separa nada; la de completitud, sí)
**Reproducir:** `03_recursion.sql` y `04_vectores.sql`; ejercicio 13 en `05_ejercicios.sql`

### M-41 · F21 · El boss IV: el informe en la app, punto de partida y solución
**Tipo:** publicada · **Motor:** PostgreSQL `pgvector/pgvector@sha256:2358fcba361e…` · **Perfil:** M, sobre la muestra de F20 · **Fecha:** 14/10/2026
**Hipótesis:** el informe puede servirse como documento, con búsqueda por paciente, sin perder la fuente ni la auditoría.
**Resultado:** punto de partida: 2 de 5 (pasan C2, latencia de 0,8 ms, y C3, igualdad con la fuente; fallan C1, el tipeo; C4, la corrección; y C5, la atomicidad). Solución: 5 de 5, con C2 a 4,9 ms. Hallazgos del arnés: el `%` de trigramas necesita `%%` con parámetros; un GiST por `<->` deja fuera al paciente correcto del top 20; con un término corto, ordenar por similitud tarda 121 ms y el prefijo de texto completo, 4,9 ms. · **Apuesta:** ganada por la solución; el punto de partida no pasa
**Reproducir:** `reiniciar-estado.sh` y luego `uv run python 21-hasta-donde-llega-el-motor/boss/arnes.py` desde `src/`; la solución se corre con la ruta del archivo que el arnés acepta como argumento (D42: la solución no se publica)

### M-42 · F22 · La exportación por marca de agua con transacciones concurrentes
**Tipo:** publicada · **Motor:** PostgreSQL `pgvector/pgvector@sha256:2358fcba361e…` · **Perfil:** el 26/12/2025 de la caja M (6.651 resultados, 601 protocolos) · **Fecha:** 14/10/2026
**Hipótesis:** la exportación por marca de agua, con transacciones concurrentes, pierde al menos una fila en 8 de 10 corridas, y la pérdida se cuenta contra `truth.result_value`.
**Resultado:** cuatro escritores, un protocolo por transacción, 5 % de transacciones lentas (0,3 a 0,6 s de reloj), el día en 30 s de reloj. Ingenua (`recorded_at > marca`): pérdida en 10 de 10 corridas, mediana 2.385 filas (36 %). Con ventana de 1 h del día y dedupe por `result_id`: 0 de 10. Instrumentado: todas las transacciones lentas se pierden (34 a 40 por corrida), y además se pierden protocolos rápidos por empates de `recorded_at` (la caja registra al minuto: 357 instantes, 162 compartidos por 406 protocolos). · **Apuesta:** ganada
**Reproducir:** `uv run python 22-la-exportacion-de-las-9-40/02_marca_de_agua.py ingenua` y `… ventana`, desde `src/`, después de `01_setup.sql`

### M-43 · F22 · La fila perdida, con el intercalado determinista
**Tipo:** publicada · **Motor:** PostgreSQL `pgvector/pgvector@sha256:2358fcba361e…` · **Perfil:** dos filas de prueba · **Fecha:** 14/10/2026
**Hipótesis:** el exportador que avanza la marca mientras una transacción anterior sigue abierta pierde esa fila.
**Resultado:** permutación `a1 a2 b1 b2 b3 c1 c2 c3 c4 a3 c5 c6 c7`: el segundo pase del exportador inserta 0 filas, y la comprobación da 1 fila sin exportar. · **Apuesta:** ganada
**Reproducir:** `uv run lab race -f 22-la-exportacion-de-las-9-40/04_marca_de_agua.race` desde `src/`

### M-44 · F22 · La cola con SKIP LOCKED, la entrega al menos una vez y el veneno
**Tipo:** publicada · **Motor:** PostgreSQL `pgvector/pgvector@sha256:2358fcba361e…` · **Perfil:** 6.651 mensajes del 26/12/2025, cuatro consumidores · **Fecha:** 14/10/2026
**Hipótesis:** la cola en Postgres con `SKIP LOCKED` y cuatro consumidores procesa el día sin duplicados en 10 de 10 corridas.
**Resultado:** procesamiento transaccional: 0 duplicados y 0 faltantes en 10 de 10 corridas, mediana 5,49 s, reparto de 1.653 a 1.668 por consumidor. Envío fuera de la transacción con caída del 2 %: 140 y 142 duplicados en un destino sin clave (dos corridas); 0 en una bandeja con clave única. Veneno: 5 mensajes a descartes al tercer intento, 0 pendientes. · **Apuesta:** ganada, con la condición de que el procesamiento sea transaccional
**Reproducir:** `uv run python 22-la-exportacion-de-las-9-40/03_colas.py` desde `src/`

### M-45 · F22 · El outbox frente a la doble escritura, y las correcciones con versión
**Tipo:** publicada · **Motor:** PostgreSQL `pgvector/pgvector@sha256:2358fcba361e…` · **Perfil:** 1.000 operaciones con 2 % de caídas; 100 resultados con 5 versiones · **Fecha:** 14/10/2026
**Hipótesis:** sin apuesta de la ficha: el outbox no pierde mensajes y la doble escritura sí.
**Resultado:** doble escritura: 19 mensajes perdidos de 1.000. Outbox: 0 perdidos, 28 reenvíos absorbidos por un destino idempotente (1.000 de 1.000). Correcciones fuera de orden: la última que llega gana deja 86 de 100 resultados con una versión que no es la última; la comparación por versión, 0. · **Apuesta:** no aplica
**Reproducir:** `uv run python 22-la-exportacion-de-las-9-40/06_outbox_versiones.py` desde `src/`

### M-46 · F22 · La decodificación lógica con test_decoding
**Tipo:** publicada · **Motor:** PostgreSQL `pgvector/pgvector@sha256:2358fcba361e…`, `wal_level = logical` · **Perfil:** una transacción de prueba y el día completo · **Fecha:** 14/10/2026
**Hipótesis:** sin apuesta: el flujo de cambios trae solo lo confirmado, en orden, con la fila completa.
**Resultado:** la transacción revertida no aparece; el `UPDATE` trae la fila entera; los 6.651 resultados del día se decodifican en 6.656 líneas (inserciones, delimitadores y el `TRUNCATE` previo). Un slot sin consumidor retuvo 1.280 kB tras 20.000 filas. Las tablas temporales no se decodifican. · **Apuesta:** no aplica
**Reproducir:** `docker exec -i alameda-lab-postgres-1 psql -U postgres -d alameda < 22-la-exportacion-de-las-9-40/05_cdc.sql` desde `src/`

### M-47 · F23 · Lo que cuesta la seguridad por fila, y dónde va el índice
**Tipo:** publicada · **Motor:** PostgreSQL `pgvector/pgvector@sha256:2358fcba361e…` · **Perfil:** M (1.327.622 protocolos, 12,1 M de resultados) · **Fecha:** 14/10/2026
**Hipótesis:** con índice sobre la columna de la política, RLS agrega un filtro que apenas cambia las lecturas; sin ese índice, cada consulta del portal recorre la tabla entera.
**Resultado:** paciente 39: 600 bloques sin RLS y 692 con RLS (política sobre `lab_order.patient_id`, con su índice). Médico 144, política por subconsulta a `referral`: 14.573 bloques y 864 ms sin índice; 9.684 bloques y 91 ms con índice en `referral`, porque `lab_order` se sigue recorriendo; con el médico como columna de la tabla protegida e indexada, 5 bloques y 0,1–0,25 ms. Escritura que viola la política: `new row violates row-level security policy for table "result"`. · **Apuesta:** ganada, con la condición de que el índice esté en la tabla protegida
**Reproducir:** `02_rls.sql` desde `src/23-la-base-como-producto/`, después de `01_setup.sql`

### M-48 · F23 · La API con PostgREST, vista desde afuera
**Tipo:** publicada · **Motor:** PostgreSQL `pgvector/pgvector@sha256:2358fcba361e…` y PostgREST `postgrest/postgrest@sha256:d155c6718ed9…` (v16.4) · **Perfil:** M · **Fecha:** 14/10/2026
**Hipótesis:** sin apuesta: cada token ve solo lo que su política permite.
**Resultado:** sin token, HTTP 401 (`permission denied for view resultados`); paciente 39, 426 resultados; protocolo ajeno, lista vacía; médico 144, 1.114 protocolos; token adulterado, HTTP 401. Mediana del portal del paciente: 5,0 y 7,3 ms en dos corridas de 20 pedidos. Sin `security_invoker`, el paciente ve filas de 165 pacientes en mil. · **Apuesta:** no aplica
**Reproducir:** `uv run python 23-la-base-como-producto/04_api.py` con `uv run lab up base api`

### M-49 · F23 · El MD5 del portal de 2018, revertido
**Tipo:** publicada · **Motor:** PostgreSQL `pgvector/pgvector@sha256:2358fcba361e…` · **Perfil:** `staging.portal_2018` (1.327.622 URL) · **Fecha:** 14/10/2026
**Hipótesis:** sin apuesta: el MD5 de un número de un espacio chico no oculta nada.
**Resultado:** 1.302.033 candidatos (letra de sede, guion, siete dígitos) en 2,96 s; el cruce con las URL en 0,54 s; 1.305.942 de 1.305.942 URL con número de sede revertidas. · **Apuesta:** no aplica
**Reproducir:** `03_md5.sql` desde `src/23-la-base-como-producto/`

### M-50 · F23 · El boss V, Las 9:40: punto de partida y solución
**Tipo:** publicada · **Motor:** PostgreSQL `pgvector/pgvector@sha256:2358fcba361e…` y PostgREST · **Perfil:** tablas propias del boss en `staging` · **Fecha:** 14/10/2026
**Hipótesis:** el flujo nuevo no pierde ni publica dos veces, notifica a tiempo y el portal no muestra informes ajenos.
**Resultado:** punto de partida 0 de 5: la fila tardía se pierde, el mensaje repetido queda dos veces, la notificación sale 25,7 h después, el paciente ve 50 de 50 filas ajenas y la corrección vieja convive con la nueva. Solución 5 de 5 (no se publica, D42); el relevador del outbox se simula en el instante de la fila. · **Apuesta:** ganada por la solución
**Reproducir:** `uv run python 23-la-base-como-producto/boss/arnes.py` con `uv run lab up base api`

### M-51 · F23 · El boss del puente: punto de partida, solución y ¿hacía falta un broker?
**Tipo:** publicada · **Motor:** PostgreSQL `pgvector/pgvector@sha256:2358fcba361e…`, Apache Artemis `apache/artemis@sha256:0f32b054e1f4…` (2.57.0) y Java 25 · **Perfil:** 1.000 resultados con 2 % de caídas; 6.651 mensajes para la medida · **Fecha:** 14/10/2026
**Hipótesis:** el servicio no pierde ni duplica, respeta la versión, aparta el veneno; y la cola de la Fase 22 se compara con el broker.
**Resultado:** punto de partida 1 de 5: 12 resultados perdidos de 1.000, 1.108 filas para 988 resultados, 0 de 50 correcciones limpias, el veneno en la DLQ de Artemis. Solución 5 de 5. Medida con 6.651 mensajes y cuatro consumidores: publicar 26,8 a 37,2 s, consumir 13,1 a 15,9 s, frente a 5,5 s de la cola en Postgres (2,4 a 2,9 veces). El journal de Artemis escribe sobre el sistema de archivos de Docker Desktop. `CLIENT_ACKNOWLEDGE` con `recover()` dio `AMQ229027`; las sesiones transaccionales, no. · **Apuesta:** la cola en la base gana por velocidad; el broker se justifica para el SIH por el contrato
**Reproducir:** `uv run python 23-la-base-como-producto/puente/arnes.py` con `uv run lab up base puente`, después de bajar las dependencias con Maven a `lib/`

### M-52 · F25 · Las 71 tablas anchas al modelo tipado, con tres reconciliaciones
**Tipo:** publicada · **Motor:** PostgreSQL `pgvector/pgvector@sha256:2358fcba361e…` · **Perfil:** M (230.944 filas en las 71 tablas) · **Fecha:** 15/10/2026
**Hipótesis:** la migración de las anchas se reconcilia en cero con conteos, sumas de control y la verdad del generador, y ningún resultado migrado queda en otra persona.
**Resultado:** 592.358 celdas con valor: 578.005 resultados y 14.353 rechazos (`-` 7.219, `VER OBS` 7.134, de los que 6.078 apuntan a una observación vacía); 38.720 celdas de `Obs` y `Otro1`–`Otro4` sin analito; 33 columnas tipadas y 177 analitos nuevos de texto; 12 a 14 s. R1 (conteos en las dos direcciones) 0; R2 (209 columnas) 0 sumas y 0 huellas distintas; R3 0 resultados en otra persona (1 protocolo de 1.327.622 en todo el modelo). La señora del boss I gana 152 resultados desde el 12/04/1999. · **Apuesta:** ganada
**Reproducir:** `01_anchas.sql` y `02_reconciliacion.sql`, desde `src/25-la-migracion-sin-parar/`

### M-53 · F25 · La cantidad que el modelo de la Fase 07 no trajo
**Tipo:** publicada · **Motor:** PostgreSQL `pgvector/pgvector@sha256:2358fcba361e…` · **Perfil:** M, lo facturado desde 2025 · **Fecha:** 15/10/2026
**Hipótesis:** sin apuesta de la ficha: lo facturado del modelo se reconcilia con `ProtocoloPracticas`.
**Resultado:** no se reconciliaba. Legacy: 1.746.067 prácticas y 1.781.167 unidades; modelo: 1.636.571 filas sin cantidad, 32.866 unidades de menos (35.100 prácticas con cantidad distinta de 1). Con `quantity` agregada por *expand*: 1.669.437 unidades en el modelo, iguales a legacy, y 109.496 prácticas (111.730 unidades) en rechazos por precio; 0 sin destino. La primera versión de la consulta llenó el `/dev/shm` de 64 MB (a08, E-69). · **Apuesta:** no aplica
**Reproducir:** `03_cantidad.sql`, desde `src/25-la-migracion-sin-parar/`

### M-54 · F25 · La convivencia por CDC con el frontal escribiendo y el aplicador cayéndose
**Tipo:** publicada · **Motor:** PostgreSQL `pgvector/pgvector@sha256:2358fcba361e…`, `test_decoding` · **Perfil:** un día comprimido en 60 s, tres sedes, unos 600 protocolos · **Fecha:** 15/10/2026
**Hipótesis:** con la posición guardada en la misma transacción que los cambios, el modelo sigue a legacy con 0 diferencias aunque el aplicador se caiga entre confirmar y avanzar el slot.
**Resultado:** primera corrida: 3.321 resultados nuevos cayeron sobre claves de resultados migrados (secuencia desde el último `IdItem`) y el `ON CONFLICT DO UPDATE` los pisó; 0 de 3.321 iguales. 73 prácticas sin destino por una función que descartaba sin rechazo. Con la secuencia de las anchas desde mil millones, el `ON CONFLICT` condicionado y los rechazos explícitos, en cuatro corridas: 584 a 597 protocolos, 2.023 a 2.073 prácticas, 3.448 a 3.687 resultados, 0 diferencias; 4 a 10 transacciones releídas y salteadas tras la caída; atraso mediana 234 a 269 ms, p95 478 a 525 ms (sondeo cada 0,5 s). · **Apuesta:** ganada, después de las dos autopsias
**Reproducir:** `04_cdc_setup.sql` y `uv run python 25-la-migracion-sin-parar/05_convivencia.py 60 1992` desde `src/`

### M-55 · F25 · El maestro de pacientes contra el del SIH, y las huellas por cubeta
**Tipo:** publicada · **Motor:** PostgreSQL `pgvector/pgvector@sha256:2358fcba361e…`, con el SIH como esquema `sih` armado desde la verdad (regla declarada) · **Perfil:** M · **Fecha:** 15/10/2026
**Hipótesis:** el cruce por documento con fecha y sexo iguales no se equivoca, y lo que no casa es sobre todo suciedad del laboratorio.
**Resultado:** 65.752 pares: 62.612 automáticos, 0 incorrectos; 3.140 a revisar, 3.056 de la misma persona y 84 de otra. Sin pareja: 158.173 fichas del laboratorio (12.364 de personas que están en el SIH: 9.922 sin documento, 1.273 con pasaporte, 693 con otro número, 476 con libreta) y 23.936 del SIH. Huellas por cubeta con tres filas cambiadas: 100 cubetas, 3 distintas, 1.946 filas que bajar de 65.752 (197 con mil cubetas). · **Apuesta:** ganada
**Reproducir:** `06_sih.sql`, desde `src/25-la-migracion-sin-parar/`

### M-56 · F25 · El simulacro de corte y su vuelta atrás
**Tipo:** publicada · **Motor:** PostgreSQL `pgvector/pgvector@sha256:2358fcba361e…` · **Perfil:** el frontal escribiendo 20 s al ritmo de la convivencia · **Fecha:** 15/10/2026
**Hipótesis:** el corte (congelar, drenar, reconciliar, decidir) se decide por un número, y la vuelta atrás antes de decidir es devolver un permiso.
**Resultado:** corte limpio: congelar 24 a 140 ms, drenar 81 a 137 ms (25 a 27 transacciones), reconciliar 151 ms, 0 diferencias, ventana sin escritura 0,3 a 0,5 s; recepción ve `terminating connection due to administrator command` y `permission denied for table Protocolos`. Con una práctica borrada del modelo: diferencias (0, 1, 0), vuelta atrás, ventana 1,0 s. La primera reconciliación, por `IdProtocolo` sin índice en `ResultadoItem`, tardó 97 s. · **Apuesta:** ganada
**Reproducir:** `uv run python 25-la-migracion-sin-parar/07_corte.py 20` y `… 20 --romper`, desde `src/`, después de `04_cdc_setup.sql`

### M-57 · F26 · El boss global "Un martes": punto de partida y solución
**Tipo:** publicada · **Motor:** PostgreSQL `pgvector/pgvector@sha256:2358fcba361e…` · **Perfil:** la semana del 28/09 al 04/10/2026, 15.270 prácticas, con los supuestos declarados de `martes/00_base.sql` · **Fecha:** 15/10/2026
**Hipótesis:** la presentación semanal a las obras sociales corre entera sobre la base nueva, con un rol que no ve legacy, mientras legacy sigue escribiendo, y se reconcilia con la planilla al centavo.
**Resultado:** punto de partida 0 de 5: 6.652 de 14.942 líneas con otro precio, 7.250 prácticas presentadas de más, 282 con otra cantidad, 330 sin destino, la presentación cambia al volver a emitirla. Solución 5 de 5 (no se publica, D42), con tres columnas que el modelo no tenía (el protocolo de lo facturado, el coseguro, y su paso por el CDC), una política de RLS para facturación y el aumento de octubre partido en una sola sentencia (a08, E-70). Reconciliación: planilla 434.511.876,15; sin precio 19.567.269,93; fuera de convenio 205.339.165,78 (artefacto de la caja, D50); en panel 103.779,72; tope 174.721,69; presentado 209.326.939,03; coseguro 9.437.714,80; neto 199.889.224,23; sin explicar, 0 en las diez obras sociales. · **Apuesta:** ganada por la solución
**Reproducir:** `uv run python 26-el-comite/martes/arnes.py [directorio]` desde `src/`, con las Fases 21, 23 y 25 corridas

### M-58 · a02 · El `/dev/shm` del contenedor de Postgres y el *hash join* en paralelo
**Tipo:** publicada · **Motor:** PostgreSQL `pgvector/pgvector@sha256:2358fcba361e…` · **Perfil:** M, la consulta de la primera versión de `03_cantidad.sql` de la Fase 25 (cuatro subconsultas sobre 1,7 millones de prácticas) · **Fecha:** 18/10/2026
**Hipótesis:** con `shm_size: 512m`, la consulta que llenó los 64 MB de fábrica (a08, E-69) pasa con cualquier `work_mem` razonable.
**Resultado:** con los valores por defecto (2 *workers*, `work_mem` de 4 MB) pasa con 64 MB y con 512 MB: el error del 15/10 no se repite sin forzar el plan. Con 4 *workers* y el paralelismo forzado (`parallel_setup_cost` y `parallel_tuple_cost` en 0): con 64 MB falla con cualquier `work_mem` desde 4 MB (pide 8.388.608 bytes, el mismo segmento del error original); con 512 MB pasa con 4, 16 y 32 MB y falla con 64 MB (pide 33.554.432 bytes). `shm_size` corre el borde, no lo elimina: cada *hash join* paralelo reserva del orden de `work_mem` × `hash_mem_multiplier` por proceso, y lo que se usa de `/dev/shm` cuenta dentro del `mem_limit`. · **Apuesta:** perdida en parte
**Reproducir:** la consulta, con `SET max_parallel_workers_per_gather = 4; SET parallel_setup_cost = 0; SET parallel_tuple_cost = 0; SET work_mem = '…'`, y `POSTGRES_SHM=64m uv run lab up` para comparar

### M-59 · ss01 · `BULK INSERT` y la diferencia entre `""` y el campo vacío
**Tipo:** apuesta sin resolver · **Motor:** SQL Server 2025 CU9 (Enterprise Developer, emulado) · **Perfil:** M
**Hipótesis:** `BULK INSERT … WITH (FORMAT = 'CSV', KEEPNULLS)` sobre `Protocolos.csv` no conserva los 3.649 `""` de `ObraSocial` que Postgres conserva (1.142.443 NULL y 3.649 vacíos con `COPY`): llegan como NULL. · **Resuélvela:** `./sqlcmd.sh < 02_bulk_insert.sql`, desde `src/ss01-la-base-en-su-motor-original/`, la última consulta

### M-60 · ss01 · El T-SQL de 2016 en su motor contra su port de la Fase 04
**Tipo:** apuesta sin resolver · **Motor:** SQL Server 2025 CU9 (Enterprise Developer, emulado) · **Perfil:** M
**Hipótesis:** `dbo.fn_ExtraerDNI` y `dbo.fn_ExtraerFecha`, sin tocar, dan sobre los 242.427 pacientes lo mismo que `staging.extract_dni_2016` y `staging.extract_birth_date_2016`: cero diferencias, y por lo tanto las mismas 3 (DNI) y 115 (fechas) contra la versión de 2026 que midió [M-07](#m-07--f04--el-90--del-parser-de-rubén). · **Resuélvela:** `uv run --extra sqlserver python ss01-la-base-en-su-motor-original/05_comparar.py` desde `src/`

### M-61 · ss01 · El corte de los años de dos cifras, en la conexión que lo cambia
**Tipo:** apuesta sin resolver · **Motor:** SQL Server 2025 CU9 (Enterprise Developer, emulado) · **Perfil:** —
**Hipótesis:** la documentación dice que `two digit year cutoff` vale "immediately"; aun así, la conexión que hace `sp_configure 'two digit year cutoff', 2029; RECONFIGURE` sigue leyendo `12/03/46` como 2046, y solo una conexión nueva lo lee como 1946. · **Resuélvela:** `./sqlcmd.sh < 06_ventana.sql` y después `./sqlcmd.sh < 06b_conexion_nueva.sql`

### M-62 · ss02 · El formulario del almuerzo frente al reporte, con y sin RCSI
**Tipo:** apuesta sin resolver · **Motor:** SQL Server 2025 CU9 (Enterprise Developer, emulado) · **Perfil:** M (la base `ss02`)
**Hipótesis:** con `READ_COMMITTED_SNAPSHOT` apagado, el reporte que lee el hemograma 1 espera al formulario sin confirmar (`LCK_M_S`, con el `blocking_session_id` del formulario) y lee `40` al confirmar; con RCSI, lee `41` sin esperar. En Postgres, publicado en ss02: el reporte lee `41` sin esperar y nadie espera un bloqueo. · **Resuélvela:** `lunch_form_reader.race` y `lunch_form_reader_rcsi.race`, desde `src/`

### M-63 · ss02 · Las anomalías de la Fase 15 en los niveles de SQL Server
**Tipo:** apuesta sin resolver · **Motor:** SQL Server 2025 CU9 (Enterprise Developer, emulado) · **Perfil:** M (la base `ss02`)
**Hipótesis:** lectura sucia en `READ UNCOMMITTED`; actualización perdida sin error en `READ COMMITTED`, 1205 en `REPEATABLE READ` y 3960 en `SNAPSHOT`; *write skew* en `READ COMMITTED` y `SNAPSHOT` (dos tomas) y 1205 en el `INSERT` de uno en `SERIALIZABLE` (una toma), frente al `40001` en el `COMMIT` de Postgres ([M-27](#m-27--f15--la-muestra-tomada-dos-veces-en-cuatro-niveles-y-dos-motores)). · **Resuélvela:** `dirty_read.race`, `lost_update.race` y `write_skew.race` con cada `--isolation`, y `deadlock.race`

### M-64 · ss02 · El *version store* de una lectura `SNAPSHOT` larga
**Tipo:** apuesta sin resolver · **Motor:** SQL Server 2025 CU9 (Enterprise Developer, emulado) · **Perfil:** M (29.241 hemogramas, tres correcciones)
**Hipótesis:** con ADR apagado, el *version store* de `ss02` en `tempdb` crece a varios megabytes con la lectura abierta y vuelve a cero en uno o dos minutos al cerrarla; `dbo.hemogram` crece por la marca de 14 bytes y las páginas partidas, y no vuelve. · **Resuélvela:** `uv run --extra sqlserver python ss02-pesimista-contra-rcsi/03_version_store.py`

### M-65 · ss02 · La misma lectura larga en Postgres
**Tipo:** publicada · **Motor:** PostgreSQL `pgvector/pgvector@sha256:2358fcba361e…` · **Perfil:** M (`staging.hemogram` de la Fase 18, 29.241 filas) · **Fecha:** 18/10/2026
**Hipótesis:** con una lectura `REPEATABLE READ` abierta, tres correcciones de toda la tabla la dejan varias veces más grande, `VACUUM` no puede limpiar nada hasta cerrarla, y al cerrarla limpia pero el archivo no se achica.
**Resultado:** 2.640 KB antes; 10.528 KB con la lectura abierta; `VACUUM` con la lectura abierta, 10.528 KB y 87.723 versiones muertas que no puede borrar; al cerrarla, `VACUUM` deja 0 muertas y el archivo en 10.528 KB (3,99 veces). La lectura vio la misma foto de principio a fin. · **Apuesta:** ganada
**Reproducir:** la solución del ejercicio 16 de ss02, y `src/18-bloqueos-deadlocks-y-ddl/01_setup.sql` para dejar la tabla como estaba

### M-66 · ss03 · Lo que le cuesta a cada sede el plan que eligió la otra
**Tipo:** apuesta sin resolver · **Motor:** SQL Server 2025 CU9 (Enterprise Developer, emulado) · **Perfil:** M (la base `ss03`: 343.123 protocolos, 3.659.431 resultados)
**Hipótesis:** en nivel 170, con el plan del central en la caché (`Hash Match` con `Index Scan` de `ResultadoItem`, estructura publicada en ss03), la sede V lee al menos tres veces las lecturas lógicas que lee con su plan (`Index Seek`); con el plan de V, el central lee más que con el suyo. En Postgres, el plan heredado le costaba a V 8,1 veces ([M-21](#m-21--f13--el-plan-genérico-de-la-consulta-por-sede)). · **Resuélvela:** `uv run --extra sqlserver python ss03-query-store-y-parameter-sniffing/02_sniffing.py --private` desde `src/`

### M-67 · ss03 · La optimización PSP sobre la consulta por sede
**Tipo:** apuesta sin resolver · **Motor:** SQL Server 2025 CU9 (Enterprise Developer, emulado) · **Perfil:** M (la base `ss03`)
**Hipótesis:** PSP no arma variantes para `dbo.resultados_por_sede` (el central tiene cuatro veces los protocolos de un centro), y el evento `parameter_sensitive_plan_optimization_skipped_reason` da un motivo de sesgo insuficiente. · **Resuélvela:** `06_psp.sql`, desde `src/ss03-query-store-y-parameter-sniffing/`

### M-68 · ss03 · `plan_cache_mode` fijado para el rol del reporte
**Tipo:** publicada · **Motor:** PostgreSQL `pgvector/pgvector@sha256:2358fcba361e…` · **Perfil:** M, el modelo · **Fecha:** 18/10/2026
**Hipótesis:** con `ALTER ROLE … SET plan_cache_mode = force_custom_plan`, la sesión que empieza el día con el central no le pasa su plan a la sede V: la sexta ejecución, para V, usa su plan propio, sin tocar la consulta.
**Resultado:** cinco ejecuciones para el central y una para V como `ss03_reporte`: 0 planes genéricos y 6 personalizados; V con *nested loop* sobre `result_lab_order_id_idx`, 10.866 bloques (9.257 en caché y 1.609 leídos), contra los 87.945 del genérico heredado en [M-21](#m-21--f13--el-plan-genérico-de-la-consulta-por-sede). El rol necesitó `BYPASSRLS`: sin él, la política de la Fase 23 sobre `alameda.result` no le deja ver ninguna fila. · **Apuesta:** ganada
**Reproducir:** la solución del ejercicio 19 de ss03, con `staging.order_site` de `src/13-el-optimizador-en-tres-motores/01_generic_plans.sql`

### M-69 · ss04 · Cinco claves agrupadas sobre los protocolos de la caja
**Tipo:** apuesta sin resolver · **Motor:** SQL Server 2025 CU9 (Enterprise Developer, emulado) · **Perfil:** M (1.327.622 protocolos, de a 5.000 en orden de llegada)
**Hipótesis:** el índice agrupado con UUIDv7 de la aplicación queda tan fragmentado y tan grande como el de UUIDv4 (páginas a menos del 75 %, fragmentación de más del 90 %), porque SQL Server compara los bytes 10 a 15 primero y el v7 pone el tiempo en los bytes 0 a 5; solo `NEWSEQUENTIALID()` se parece a `int IDENTITY`. En InnoDB y Postgres el v7 sí ordena ([M-16](#m-16--f10--uuidv4-y-uuidv7-como-clave-primaria-en-innodb)). · **Resuélvela:** `uv run --extra sqlserver python ss04-clustered-newsequentialid-y-temporales/01_claves.py --private` desde `src/`

### M-70 · ss04 · `NEWSEQUENTIALID()` después de reiniciar, en Linux
**Tipo:** apuesta sin resolver · **Motor:** SQL Server 2025 CU9 (Enterprise Developer, emulado, sobre Linux) · **Perfil:** —
**Hipótesis:** después de reiniciar el contenedor, las mil filas nuevas de `dbo.seq_restart` quedan ordenadas antes de las mil anteriores, como advierte la documentación para Windows. · **Resuélvela:** `02_reinicio.sql`, `docker compose -f ../lab/compose.yaml restart sqlserver` y `02_reinicio_despues.sql`, desde `src/ss04-clustered-newsequentialid-y-temporales/`

### M-71 · ss04 · `uuidv7()` de Postgres 18, en el orden en que se genera
**Tipo:** publicada · **Motor:** PostgreSQL `pgvector/pgvector@sha256:2358fcba361e…` (18.6) · **Perfil:** — · **Fecha:** 18/10/2026
**Hipótesis:** mil valores de `uuidv7()` generados en una sentencia están en el orden de generación según la comparación de `uuid`.
**Resultado:** 0 de 1.000 fuera de orden (comparado cada uno con el anterior, con `lag`). · **Apuesta:** ganada
**Reproducir:** la solución del ejercicio 12 de ss04

### M-72 · ss05 · El índice JSON contra la columna calculada, para el antibiograma
**Tipo:** apuesta sin resolver · **Motor:** SQL Server 2025 CU9 (Enterprise Developer, emulado) · **Perfil:** M (60.001 cultivos)
**Hipótesis:** para meropenem R (600), el índice JSON lee menos del 10 % del recorrido de la clave agrupada y la columna calculada indexada lee menos que el índice JSON; para ciprofloxacina R (13.303), el índice JSON lee más del 15 % del recorrido. En Postgres, GIN `jsonb_path_ops` leyó el 27 % para meropenem y no ayudó para ciprofloxacina ([M-35](#m-35--f19--el-antibiograma-como-documento-en-la-búsqueda-por-un-resultado)). · **Resuélvela:** las consultas de `04_json.sql`, desde `src/ss05-data-api-builder-y-json/`, con `SET STATISTICS IO ON`

### M-73 · ss05 · Lo que cuesta la seguridad por fila de SQL Server en el portal
**Tipo:** apuesta sin resolver · **Motor:** SQL Server 2025 CU9 (Enterprise Developer, emulado) · **Perfil:** M (12.710.308 resultados)
**Hipótesis:** con la política de `02_api.sql`, el paciente lee del orden de lo que lee sin ella (el predicado usa el índice por `patient_id`) y el médico, por `referral`, varias veces más, como en [M-47](#m-47--f23--lo-que-cuesta-la-seguridad-por-fila-y-dónde-va-el-índice). · **Resuélvela:** como `dab_api`, con `sp_set_session_context` a mano y `SET STATISTICS IO ON`, con la política encendida y apagada

### M-74 · ss05 · El contrato de la Fase 23 por Data API builder, y la identidad fabricada
**Tipo:** publicada · **Motor:** Data API builder 2.1.5 `…data-api-builder@sha256:d07e3e1ce53b…` sobre SQL Server 2025 CU9; los conteos son del modelo, iguales en Postgres · **Perfil:** M · **Fecha:** 18/10/2026
**Hipótesis:** con el proveedor `AppService` y la seguridad por fila de SQL Server sobre `SESSION_CONTEXT`, cada perfil ve lo mismo que en la Fase 23, y una identidad fabricada en el encabezado `X-MS-CLIENT-PRINCIPAL` es aceptada.
**Resultado:** sin identidad, 403; paciente 39, 1.284 resultados en 152 protocolos (los de Postgres hoy; 858 vienen de las tablas anchas de la Fase 25, y los otros 426 son los de M-48); protocolo ajeno, `[]`; médico 144, 1.114 protocolos; sin `X-MS-API-ROLE`, 403; la identidad fabricada del paciente 12594, 200 y 115 resultados ajenos. DAB manda en cada pedido `sp_reset_connection` y los *claims* con `sp_set_session_context … @read_only = 0`, en un solo `sp_executesql`. · **Apuesta:** ganada, que es el problema
**Reproducir:** `uv run --extra sqlserver python ss05-data-api-builder-y-json/03_api.py` desde `src/`, con `uv run lab up sqlserver dab`, después de `01_modelo.py` y `02_api.sql`

### M-75 · a04 · El WAL de cien filas en tres corridas seguidas
**Tipo:** publicada · **Motor:** PostgreSQL 18.6 `pgvector/pgvector@sha256:2358fcba361e…` · **Perfil:** M (una copia de 1.000 pacientes en `lab`) · **Fecha:** 18/10/2026
**Hipótesis:** el mismo `UPDATE` que no cambia nada en 100 filas escribe lo mismo en el WAL cada vez.
**Resultado:** no: 200 registros y 15.995 B; 174 registros, 1 `fpi` y 22.754 B; 102 registros y 10.161 B. La página entera explica la segunda; la tercera tiene lugar en la misma página por la poda de las anteriores. Por fila, de 160 a 100 B, y 228 con la página entera. · **Apuesta:** perdida; el número por fila depende del estado de la tabla, y se publica en régimen
**Reproducir:** `CREATE TABLE lab.a04_wal AS SELECT "IdPaciente", "Nombre", "DNI" FROM legacy."Pacientes" WHERE "IdPaciente" <= 1000;` y tres veces `EXPLAIN (ANALYZE, WAL, COSTS OFF, TIMING OFF, SUMMARY OFF) UPDATE lab.a04_wal SET "DNI" = "DNI" WHERE "IdPaciente" <= 100;` ([`a04`](a04-el-arnes-de-forma.md#️-bytes-de-wal-con-explain-analyze-wal), ejercicio 5)

### M-76 · a04 · La mitad de los pacientes actualizada sin cambiar nada
**Tipo:** publicada · **Motor:** PostgreSQL 18.6 `pgvector/pgvector@sha256:2358fcba361e…` · **Perfil:** M (copia de `legacy."Pacientes"` con el autovacuum apagado) · **Fecha:** 18/10/2026
**Hipótesis:** un `UPDATE` que no cambia ningún valor no hace crecer la tabla.
**Resultado:** 4.160 bloques antes; 121.213 filas actualizadas; 6.198 bloques después (+49 %), con 121.213 filas muertas (31,8 %); después de `VACUUM`, 6.198 bloques, 0 muertas y 32,4 % libre. · **Apuesta:** perdida; cada `UPDATE` escribe una versión nueva, y `VACUUM` libera el espacio sin devolverlo
**Reproducir:** el ejercicio 7 de [`a04`](a04-el-arnes-de-forma.md#-ejercicios-8)

### M-77 · a10 · El parser de 1998 en tres configuraciones de LibreOffice
**Tipo:** publicada · **Motor:** LibreOffice 25.2.3 en `debian:trixie-slim@sha256:a29215f6a35e…` (imagen de `Dockerfile.libreoffice`) · **Perfil:** las 40 aserciones de `TestParser.bas` · **Fecha:** 18/10/2026, contra la prueba de concepto del 29/09/2026
**Hipótesis:** `ModParser.bas` da el mismo resultado con otra configuración regional y otra ventana de años de dos cifras.
**Resultado:** `es-AR` desde 1930, 40 de 40; `en-US`, 31 de 40; `es-AR` desde 1950, 39 de 40; desde 1900, 38 de 40. La ventana "por defecto" es 1930 en LibreOffice 25.2.3 y 1950 en 26.2.1: el mismo comando dio 39 de 40 el 29/09 y 40 de 40 hoy. · **Apuesta:** perdida, que es lo que el apéndice muestra
**Reproducir:** `python3 run_bas_tests.py`, `… en-US`, `… es-AR 1950` y `… es-AR 1900` en la imagen, desde `src/a10-el-access-de-museo/` ([`a10`](a10-el-access-de-museo.md#-el-bas-de-rubén-tal-cual-en-libreoffice-basic))

### M-78 · F21 · El diccionario español y los nombres propios
**Tipo:** publicada · **Motor:** PostgreSQL 18.6 `pgvector/pgvector@sha256:2358fcba361e…` · **Perfil:** M (`staging.patient_name`, 223.889 pacientes sin fusionar) · **Fecha:** 18/10/2026
**Hipótesis:** buscar un nombre con el texto completo en español devuelve los pacientes que tienen ese nombre.
**Resultado:** `to_tsvector('spanish', …)` reduce `MARIA` y `MARIO` a la misma raíz, `mari`. La búsqueda `maria` devuelve 8.149 pacientes: los 4.382 que tienen `MARIA` como palabra y los 3.767 que tienen `MARIO`. Con la configuración `simple`, `MARIA` queda como `maria`. · **Apuesta:** perdida
**Reproducir:** `SELECT count(*) FILTER (WHERE name_tsv @@ to_tsquery('spanish', 'maria')), count(*) FILTER (WHERE name_norm ~ '\mMARIA\M'), count(*) FILTER (WHERE name_norm ~ '\mMARIO\M') FROM staging.patient_name;` después de `21-hasta-donde-llega-el-motor/01_setup.sql` ([F21](21-hasta-donde-llega-el-motor.md), §5.5)
