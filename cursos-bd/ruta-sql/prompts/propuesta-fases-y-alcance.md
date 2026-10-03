# 🗺️ Propuesta de fases y alcance
## Ruta SQL — 27 fases, 7 bloques, 252 horas

> **Qué es este documento:** el temario detallado. Por cada fase fija qué dolor de Alameda ataca,
> qué entra, con qué laboratorio, qué apuesta, qué punto de rotura, qué autopsia y qué veredicto.
> Las horas y los conteos de ejercicios de §11 son **los que mandan**: las plantillas y los prompts
> los copian de aquí.
> **Precedencia:** debajo del [alcance](alcance-del-proyecto.md) y de la
> [guía](guia-de-estilo-y-convenciones.md). Si una fase de aquí contradice a uno de los dos, gana
> el otro y esto se corrige.
> **Fecha:** 30/09/2026. **Estado:** temario cerrado. Las decisiones que lo sostienen están en §12,
> cerradas por Oskar el mismo día.

Una advertencia que vale para todo el documento: **las apuestas escritas aquí son candidatas**.
Cada una es una hipótesis razonable, no un resultado. La fase la reescribe en su paso 1 si el
laboratorio sugiere una mejor, y la deja fija **antes** de medir. Lo mismo con los mensajes de
error que se citan como punto de rotura: son los que se esperan, y la fase publica el que salió.

---

## ⏱️ 1. Reparto horario

| Bloque | Qué resuelve | Fases | Horas |
|---|---|---|---|
| **0 · El instrumento** | la tesis, la caja, el arnés de forma y las cinco preguntas desde el lado relacional | F00–F02 | 12 h |
| **I · El modelo** | SQL contra el modelo relacional, 1FN–BCNF, identidad, 4FN–5FN, el tiempo, y los dos extremos del error | F03–F08 | 48 h |
| **II · La física y el tuning** | tamaño, identificadores, índices, estadísticas, optimizador y "la base no estaba lenta" | F09–F14 | 60 h |
| **III · La concurrencia** | aislamiento, el folio sin huecos, MVCC y su factura, bloqueos y DDL | F15–F18 | 40 h |
| **IV · Lo NoSQL dentro del SQL** | JSON en los motores, la propuesta de Florencia medida, y hasta dónde llega el motor | F19–F21 | 30 h |
| **V · La base en la red** | lote contra flujo e integración con el SIH; la base como producto | F22–F23 | 30 h |
| **VI · El árbitro** | el diseño, la migración sin parar y el comité | F24–F26 | 32 h |
| | | **27 fases** | **252 h** |

**252 h ≈ 21 semanas a 12 h semanales.** El track de SQL Server (§8) y los apéndices van aparte.

### 1.1 Por qué 27 fases y no 26

La propuesta de diseño tenía cuatro fases de modelo. Con la historia escrita aparecieron seis
dolores de modelado que no comparten mecanismo: la lógica de tres valores, la atomicidad del dato,
la identidad de la persona, las dependencias multivaluadas y de join, el tiempo, y la elección
entre tablas anchas, EAV y `jsonb`. Meterlos en cuatro fases de 10 h obliga a tratar dos de ellos
en media fase cada uno. La solución es un Bloque I de **seis fases de 8 h**: 48 h en lugar de 40,
que se descuentan del Bloque IV (de 40 a 30) y del VI (de 40 a 32). Decidido así (D1).

### 1.2 El orden

**El de publicación es el de aprendizaje.** A diferencia de la NoSQL Lite, aquí los bloques no son
independientes: el Bloque II mide sobre el modelo del I, y el III concurre sobre las tablas del II.
Un lector puede saltar el IV y el V, pero no puede empezar por el III.

---

## 🧱 2. La forma de una fase

Todas las fases de tema (F03–F23) comparten un esqueleto, porque todas hacen lo mismo con un
mecanismo distinto: **reproducir un dolor de Alameda sobre la caja, entender el mecanismo en
Postgres, contrastarlo donde otro motor cambia la decisión, apostar, medir, romper y decidir.**

1. 🏚️ **El dolor, en la caja**: el problema reproducido sobre `legacy`, con el número de "antes".
2. 🧩 **El mecanismo**, en Postgres: el grueso.
3. 🔀 **El contraste**: MySQL y Oracle, **solo donde cambian la decisión**. Oracle, siempre como
   apuesta sin resolver.
4. 🪞 **La apuesta**, escrita antes, y 📐 la medición.
5. 💥 **El punto de rotura.**
6. ⚰️ **La autopsia**: la decisión de Alameda que produjo el dolor, con números antes y después.
7. 📖 **La traducción**: desde Access y T-SQL, entre los tres motores, y hacia la NoSQL Lite cuando
   aplique.
8. ⚖️ **El veredicto**: cuándo **no** usar lo que la fase acaba de enseñar.

En las fases de plan (F12, F13 y partes de F11 y F14) **el punto de rotura es un precipicio del
plan**: el volumen exacto en que el optimizador cambia de estrategia y las lecturas se disparan.
Su "mensaje literal" es la línea del plan que cambió, y se publica como tal (D16).

Las plantillas completas están en [`plantillas-de-capitulo.md`](plantillas-de-capitulo.md).

---

## 🧭 3. Bloque 0 — El instrumento (12 h)

### 📜 F00 — La base que nadie diseñó (4 h · 12 ejercicios)

- **Propósito:** que el lector se reconozca en una de las dos caras del villano antes de que el
  curso le proponga nada.
- **Entra:** la tesis (el curso que se gana "casi siempre gana Postgres"); el villano doble, "Mongo
  por moda" y "la base como pote", como la misma decisión; Alameda en una página, que enlaza a la
  historia y no la repite; las tres propuestas sobre la mesa, cada una con su mejor argumento; y
  las autopsias. **La central es `DMax + 1`**, de 2004 a 2015: la decisión correcta con una PC por
  sede, el error 10016 con tres cajas, la caja trabada con cuarenta pacientes. Al lado, las de la
  industria que el curso retoma: "todo `text` porque no da error", "UUID porque es moderno", "el ORM
  se encarga", "nos fuimos a Mongo por un `ALTER TABLE`".
- **No entra:** ningún motor, ninguna medición. Las cinco preguntas se anuncian y se desarrollan en
  F02.
- **Ejercicios (12):** de lectura y decisión sobre esquemas y decisiones reales.
- **Plantilla:** Bloque 0. **Longitud:** 2.000–3.000 palabras.

### 📦 F01 — La caja y el arnés (5 h · 22 ejercicios)

- **Propósito:** laboratorio arriba, la caja cargada tal cual en los tres motores y el instrumento
  de medida calibrado.
- **Entra:** el compose con `postgres`, `mysql` y `oracle`; el generador con semilla y los perfiles
  S y M (`a05`); **la carga de la caja al esquema `legacy`**, con tipos de texto donde el original
  tenía texto; el primer vistazo a las 214 tablas desde el catálogo (`information_schema`,
  `pg_class`): cuántas, cuánto pesan y cuáles no tienen clave primaria; y **cómo se mide la forma**
  en cada motor, con el primer `EXPLAIN (ANALYZE, BUFFERS)` leído campo por campo, su equivalente en
  MySQL y la estructura de `DBMS_XPLAN` en Oracle (`a04`).
- **💥 Punto de rotura:** los dos CSV en Latin-1. La carga en UTF-8 se cae con el primer `MUÑOZ` y
  un mensaje de secuencia de bytes inválida. Se sale declarando la codificación, y no
  "limpiando" el archivo a mano.
- **Prueba de fuego:** con el perfil M, el lector cuenta las filas de `legacy."Pacientes"` cuyo
  nombre contiene `DNI` y obtiene **el mismo número que el documento**, que es el que declara el
  generador. Si no coincide, el arnés está mal, y el curso entero se cae.
- **No entra:** limpiar nada. El desastre se hereda intacto.
- **Plantilla:** Bloque 0. **Longitud:** 3.000–4.000 palabras.

### ❓ F02 — Las cinco preguntas, desde el otro lado (3 h · 12 ejercicios)

- **Propósito:** el instrumento de decisión, cosido con la NoSQL Lite.
- **Entra:** las cinco preguntas del alcance §5, respondidas desde lo relacional y aplicadas a las
  partes de Alameda (el comprobante, el informe, la presentación a la obra social, la búsqueda de
  pacientes, el nomenclador); por qué *"¿esquema fijo?"* y *"¿necesito escalar?"* no predicen nada; y
  el triaje **"ya está en producción, ¿ahora qué?"**: qué se toca primero en una base que no se
  puede parar.
- **Ejercicios (12):** dominios descritos, contestar las cinco preguntas y defender qué parte es
  relacional y cuál no.
- **Plantilla:** Bloque 0. **Longitud:** 2.000–3.000 palabras.

---

## 🧬 4. Bloque I — El modelo (48 h)

El bloque que desmonta la idea de Rubén, *"tablas unidas por rayitas"*. Cada fase toma una tabla
incómoda de la caja y la convierte en un esquema que **defiende su propia regla**, contando cuántas
filas de `legacy` rechaza. El número de rechazos es la medición del bloque.

### 🧮 F03 — Lo que SQL le hace al modelo relacional (8 h · 22 ejercicios)

- **El dolor:** la presentación a la obra social, *"la primera consulta que un día dio mal"*
  (historia §3, 1997). Un `NOT IN` contra una subconsulta con un `NULL` devuelve cero filas, y un
  join contra `Precios` duplica prácticas.
- **El mecanismo:** relaciones contra *bags*; `DISTINCT` como parche; la lógica de tres valores y
  qué hace `NULL` en `NOT IN`, en `COUNT(col)`, en `=` y en `IS DISTINCT FROM`; el orden que no
  existe sin `ORDER BY`; la crítica de Date y Darwen, sin convertirla en religión.
- **El contraste:** **Oracle trata la cadena vacía como `NULL`**, y la caja trae miles de `''`
  desde SQL Server. MySQL fuera de modo estricto trunca y convierte en silencio. Las dos cosas
  cambian una migración.
- **🪞 Apuesta candidata:** "la consulta de Rubén pierde exactamente las prácticas de los protocolos
  con obra social vacía", comprobada contra la verdad del generador.
- **💥 Rotura:** cargar en Oracle las cadenas vacías de la caja en una columna `NOT NULL`.
- **⚰️ Autopsia:** `SELECT DISTINCT` para arreglar duplicados que produjo un join mal planteado.
- **⚖️ Veredicto:** cuándo no pelear con `NULL`; y el anti-patrón inverso, los centinelas (`'SIN
  DATO'`, `1900-01-01`) que la caja trae por docenas.

### 🧱 F04 — Un valor, un hecho: de la 1FN a la BCNF (8 h · 24 ejercicios)

- **El dolor:** `PEREZ PEDRO DNI 23456789`, el campo multivalor de turnos (`HEM;GLU;URE`) y la obra
  social escrita como texto (`OSDE`, `Osde`, `O.S.D.E`).
- **El mecanismo:** dependencias funcionales; la 1FN de verdad (la atomicidad depende del uso, y
  eso se discute con honestidad); 2FN, 3FN y BCNF sobre tablas de la caja; **las restricciones como
  documentación ejecutable**: tipos, `NOT NULL`, `CHECK`, dominios, `UNIQUE` y claves foráneas.
  Las FK con `NOCHECK` de 2011, y su equivalente honesto en Postgres, `NOT VALID` seguido de
  `VALIDATE CONSTRAINT`.
- **El parser en tres versiones:** el `.bas` de Rubén, el T-SQL de Matías y el port en Python del
  taller, con **las dos diferencias no documentadas** (la ventana del año de dos dígitos y el parche
  de 2019) reproducidas. **Una regla en dos lugares siempre diverge**, y la restricción vive en un
  solo sitio.
- **El laboratorio:** el pipeline `legacy` → área de carga → modelo, con una tabla de rechazos que
  cuenta por regla.
- **El contraste:** MySQL ignoraba los `CHECK` hasta la 8.0.16, y todavía hay esquemas escritos
  para esa época.
- **🪞 Apuesta candidata:** "el parser de Rubén acierta el DNI en el 90 % de las filas que dice
  la historia", medido contra la verdad del generador.
- **💥 Rotura:** las claves foráneas contra los huérfanos de la caja.
- **⚰️ Autopsia:** el parser, de 40 a 400 líneas.
- **⚖️ Veredicto:** cuándo no normalizar. El domicilio del paciente **al momento del protocolo**
  no es una desnormalización: es otro hecho.

### 🪪 F05 — Una persona no es su documento (8 h · 24 ejercicios)

- **El dolor:** los pacientes duplicados (entre el 15 % y el 20 %), el recién nacido con el DNI de
  la madre, la libreta que se volvió DNI con el mismo número, el pasaporte en el campo `dni`, la
  refugiada con `OTRO`.
- **El mecanismo:** claves naturales contra sustitutas; `identity_document` como tipo, país y
  número, con un `CHECK` de formato por tipo y un índice único parcial; "sin documento" como estado
  válido; la relación del recién nacido con su madre. Y **el maestro de pacientes**: *blocking*,
  similitud por trigramas (`pg_trgm`) y fonética (`fuzzystrmatch`), umbral, cola de revisión humana
  y fusión que nunca borra.
- **La medición que hace única a esta fase:** **precisión y exhaustividad del matcher contra la
  verdad del generador**, que sabe quién es quién.
- **El contraste:** Oracle `UTL_MATCH` (apuesta sin resolver); MySQL no tiene trigramas, y eso es
  parte del veredicto.
- **🪞 Apuesta candidata:** "trigramas sobre el nombre normalizado más la fecha de nacimiento
  encuentran al menos el 90 % de los duplicados con menos del 1 % de falsos positivos".
- **💥 Rotura:** el autojoin sin *blocking*, cuyas filas examinadas crecen con el cuadrado de la
  tabla.
- **⚰️ Autopsia:** el DNI como clave primaria, y el LIS de 2012 que creó un paciente por variante.
- **⚖️ Veredicto:** cuándo **no** deduplicar automáticamente. En salud, un falso positivo mezcla
  dos historias clínicas, y el costo del error es asimétrico.

### 🔗 F06 — Cuarta y quinta forma normal, con dependencias de verdad (8 h · 20 ejercicios)

- **El dolor:** los convenios (qué obra social cubre qué práctica en qué sede) y las tres columnas
  de código (`CodINOS`, `CodNBU`, `CodNBU2012`) con una tabla de equivalencias incompleta.
- **El mecanismo:** dependencias multivaluadas (coberturas y teléfonos de un paciente) y la 4FN;
  dependencias de join y la 5FN con la regla de convenios **cuando es cíclica**; catálogos
  versionados y tablas de equivalencia entre catálogos.
- **🪞 Apuesta candidata:** "la descomposición en tres tablas binarias no pierde ni inventa filas
  si, y solo si, la regla de negocio es cíclica", demostrada con el generador en las dos variantes.
- **💥 Rotura:** el join que inventa filas espurias cuando la regla no era cíclica, contadas.
- **⚰️ Autopsia:** una columna de código nueva por cada versión del nomenclador.
- **⚖️ Veredicto:** cuándo no llegar a la 5FN: si la dependencia de join es accidental, la
  descomposición se paga en joins y no compra nada.

### ⏳ F07 — El tiempo en el modelo (8 h · 24 ejercicios)

- **El dolor:** las 280 tablas `Precios_AAAA_MM`, la vigencia de 2025 sin fecha de fin, marzo de
  2002 reconstruido a mano, y la pregunta de Norma: *"¿quién cambió este resultado, cuándo, y qué
  decía antes?"*.
- **El mecanismo:** tiempo válido y tiempo de transacción; rangos (`daterange`) y restricciones de
  exclusión; `WITHOUT OVERLAPS` y claves foráneas con período, si la versión del curso las trae
  (se verifica); la historia de correcciones de `result`; bitemporalidad; la 6FN y el *anchor
  modeling*, y dónde hacen explotar los joins y dejan al optimizador sin estimación.
- **El contraste:** Flashback de Oracle (apuesta sin resolver); MySQL sin tablas temporales, con
  *triggers*; las tablas versionadas de SQL Server quedan para el track (`ss04`).
- **🪞 Apuesta candidata:** "la consulta *as-of* sobre el modelo de rangos devuelve el precio
  correcto en los 280 meses; la unión de las 280 tablas falla en los meses donde dos vigencias se
  superponen".
- **💥 Rotura:** la carga de las vigencias superpuestas de 2025 contra la restricción de exclusión.
- **⚰️ Autopsia:** copiar la tabla de precios el primer día de cada mes.
- **⚖️ Veredicto:** cuándo no ir a lo bitemporal, y cuándo no ir a la 6FN.

### ⚖️ F08 — Los dos extremos del mismo error (8 h · 26 ejercicios)

- **El dolor:** las 71 tablas anchas anteriores a 2008 y el EAV de `ResultadoItem`, con el valor
  como texto (`"5,2"`, `"< 0,5"`, `"HEMOLIZADA"`) y el informe que hace `UNION` entre las dos.
- **El mecanismo:** cuatro modelos del mismo resultado, medidos con la misma consulta clínica
  (*"glucemias mayores que 126 en pacientes con HbA1c mayor que 6,5 durante 2024"*) y con la lectura
  de un informe: las tablas anchas, el EAV, `jsonb`, y **un modelo tipado** (`value_numeric`, el
  calificador `<`/`>`, `value_text` y la bandera de muestra) por familia de determinación. Tamaño,
  lecturas y filas estimadas contra reales, porque **el EAV deja al optimizador a ciegas**.
- **🪞 Apuesta candidata:** "la consulta clínica sobre el EAV lee al menos 10 veces más bloques que
  sobre el modelo tipado, y su estimación de filas se equivoca por al menos un orden de magnitud".
- **💥 Rotura:** convertir el texto a número: el primer `HEMOLIZADA`.
- **⚰️ Autopsia:** el EAV de Matías, una buena idea mal terminada, y él lo sabe.
- **⚖️ Veredicto:** cuándo el EAV es la respuesta correcta (atributos abiertos que nadie consulta
  por valor), cuándo lo es `jsonb`, y la pregunta que abre el Bloque IV.
- 💀 **Boss del Bloque I — "La señora que es tres pacientes"**, pedido por Norma Castellani.

---

## ⚙️ 5. Bloque II — La física y el tuning (60 h)

El bloque que desmonta *"la base está lenta"*. Todo se mide en lecturas, filas y bytes, sobre el
modelo que dejó el Bloque I.

### 📦 F09 — El tamaño de las cosas (10 h · 24 ejercicios)

- **El dolor:** 1,1 TB de órdenes escaneadas y PDF dentro de la base, sobre 1,4 TB en total, y un
  respaldo de seis horas que ya no entra en la ventana nocturna.
- **El mecanismo:** páginas y bloques en los tres motores; la cabecera de la fila y el relleno por
  alineación (el orden de las columnas importa en Postgres); TOAST; *heap* contra *clustered*
  (InnoDB *es* su clave primaria); `fillfactor`; `bytea`, objetos grandes y referencia externa con
  hash; **particionado** de `result` por mes como diseño: *pruning* en el plan y el mes viejo que se
  desprende entero.
- **🪞 Apuesta candidata:** "reordenar las columnas de `result` reduce su tamaño en al menos un
  10 %".
- **💥 Rotura:** el PDF grande contra el límite de paquete de MySQL, con su mensaje.
- **⚰️ Autopsia:** los PDF de 2013 guardados "para que no se pierdan".
- **⚖️ Veredicto:** cuándo **sí** va el archivo en la base: consistencia transaccional, archivos
  chicos, un solo respaldo.

### 🔑 F10 — Identificadores (10 h · 26 ejercicios)

- **El dolor:** el protocolo `-1847263541` de la replicación de Jet, el `DMax + 1`, y el portal
  enumerado en 2018 con su corrección, el MD5 del número.
- **El mecanismo:** `bigint` con *identity* o secuencia, caché de secuencias y huecos, hi/lo en los
  ORM; UUIDv4 contra UUIDv7 (`uuidv7()` nativo en Postgres 18, a verificar); *page splits* en InnoDB
  con UUIDv4; tamaño de índice y *full-page writes* en Postgres; **qué filtra cada identificador**
  (el secuencial filtra el volumen de negocio; el v7, la fecha de creación; el MD5 de un secuencial
  se revierte precalculando los N hashes); el patrón **`bigint` interno más identificador público
  opaco**. Y la frase que la fase deja escrita: **el ID opaco no arregla un IDOR**, lo arregla la
  autorización (F23).
- **El contraste:** MySQL es el caso central (*clustered* y publicable); `SYS_GUID()` de Oracle,
  como apuesta sin resolver; `NEWSEQUENTIALID()` queda para el track.
- **🪞 Apuesta candidata:** "con UUIDv4 como clave primaria en InnoDB, el índice primario del
  perfil M queda al menos un 30 % más grande que con `bigint`, y con UUIDv7 la diferencia baja a
  menos del 10 %".
- **💥 Rotura:** la secuencia que queda atrás después de una carga con identificadores explícitos,
  y la clave duplicada en el primer `INSERT` del día siguiente.
- **⚰️ Autopsia:** el MD5 del número de protocolo.
- **⚖️ Veredicto:** cuándo un UUID como clave sí vale la pena.

### 🗂️ F11 — Índices y lo que cuestan (10 h · 28 ejercicios)

- **El dolor:** el `AutoIndex` de Access, que indexaba solo cualquier campo terminado en `ID`,
  `key`, `code` o `num`, y que el asistente de *upsizing* trasladó intacto a SQL Server.
- **El mecanismo:** B-tree y orden de columnas en el compuesto; índices parciales y de expresión
  (sobre el nombre normalizado, sobre el valor ya parseado); `INCLUDE`, *index-only scans* y el mapa
  de visibilidad; GIN y BRIN (este sobre la fecha de un `result` que solo crece); *skip scan*, si la
  versión lo trae; y **el costo de escritura**: bytes de WAL por fila con cero a ocho índices,
  actualizaciones HOT y lo que las mata. En MySQL, cada índice secundario carga la clave primaria, y
  eso cose esta fase con F10.
- **🪞 Apuesta candidata:** "cada índice adicional sobre `result` agrega bytes de WAL por fila en
  proporción a su ancho, y el cuarto índice anula las actualizaciones HOT del flujo de
  correcciones".
- **💥 Rotura:** indexar la columna `Obs` de texto libre, contra el tamaño máximo de una entrada de
  B-tree.
- **⚰️ Autopsia:** un índice por columna "por las dudas".
- **⚖️ Veredicto:** cuándo no indexar.

### 📊 F12 — Estadísticas y cardinalidad (10 h · 24 ejercicios)

- **El dolor:** 15 M de filas de resultados con el valor en texto, y un informe mensual que un día
  pasó de segundos a horas "sin que nadie tocara nada".
- **El mecanismo:** `ANALYZE`, histogramas, valores más frecuentes y `n_distinct`; por qué un valor
  en texto destruye el histograma; columnas correlacionadas (la sede y el prefijo del protocolo) y
  estadísticas extendidas; filas estimadas contra reales, nodo por nodo; cómo un error de
  estimación elige el join equivocado.
- **El contraste:** los histogramas de MySQL (`ANALYZE TABLE … UPDATE HISTOGRAM`); el muestreo
  dinámico y las estadísticas extendidas de Oracle (apuesta sin resolver).
- **🪞 Apuesta candidata:** "sin estadísticas extendidas, la estimación del filtro por sede y
  prefijo se equivoca por al menos 10 veces, y eso cambia el método de join".
- **💥 Rotura:** el precipicio del plan: el volumen exacto en que cambia de estrategia.
- **⚰️ Autopsia:** el informe mensual y el `ANALYZE` que nadie programó.
- **⚖️ Veredicto:** cuándo no confiar en las estadísticas, y fijar el plan.

### 🧠 F13 — El optimizador en tres motores (10 h · 24 ejercicios)

- **El dolor:** la consulta por sede que anda bien en los centros de extracción y se arrastra en
  el laboratorio central, que concentra la mayoría de las filas.
- **El mecanismo:** métodos de join (*nested loop*, *hash*, *merge*) y orden de joins; sentencias
  preparadas, planes genéricos contra personalizados (`plan_cache_mode`); *bind peeking* en Oracle;
  hints (los de MySQL, `pg_hint_plan` si está disponible, los de Oracle) y *SQL plan baselines*; la
  estabilidad del plan como decisión.
- **🪞 Apuesta candidata:** "a partir de la sexta ejecución, el plan genérico elige para el
  laboratorio central el mismo método que para un centro chico, y lee al menos 10 veces más".
- **💥 Rotura:** el cambio a plan genérico, con la línea del plan que cambió.
- **⚰️ Autopsia:** el hint que sobrevivió a tres versiones del motor.
- **⚖️ Veredicto:** cuándo no usar hints.

### 🐢 F14 — La base no estaba lenta (10 h · 26 ejercicios)

- **El dolor:** 2011–2013. El frontal Access sobre ODBC trae tablas enteras por la red, resuelve
  joins del lado del cliente, y la respuesta oficial durante dos años es *"la base está lenta"*.
- **El mecanismo:** el frontal simulado en Python (formulario enlazado a la tabla, subformulario,
  join en el cliente); N+1; paginación por `OFFSET` contra *keyset*; el `count(*)` para "página 1
  de 4.812"; `pg_stat_statements` como el Query Store de pobre. Todo medido en **viajes y filas
  transferidas contra mostradas**.
- **🪞 Apuesta candidata:** "el formulario de protocolos trae al menos mil veces más filas de las que
  muestra".
- **💥 Rotura:** la página 5.000 del portal con `OFFSET`, contra el `statement_timeout`.
- **⚰️ Autopsia:** la licencia Standard de 2014, comprada para una base que no estaba lenta.
- **⚖️ Veredicto:** cuándo la base **sí** está lenta, y cómo se reconoce.
- 💀 **Boss del Bloque II — "El portal de 2018"**, pedido por Verónica Colombo.

---

## 🔒 6. Bloque III — La concurrencia (40 h)

Dos recepcionistas pidiendo folio a la vez son dos hilos de Python. Todo el bloque se ejecuta con
el arnés de carreras (`lab race`, `a04`), que intercala sesiones de forma **determinista**, para que
la anomalía se reproduzca siempre y no "a veces".

### 🔀 F15 — Aislamiento comparado (10 h · 26 ejercicios)

- **El dolor:** la muestra asignada dos veces: dos técnicos comprueban a la vez que nadie la tomó,
  y la toman los dos.
- **El mecanismo:** las anomalías (lectura sucia, no repetible, fantasma, *lost update*, *write
  skew*, la anomalía de solo lectura) y la crítica de Berenson et al. a los niveles del estándar;
  la matriz por motor: `READ COMMITTED`, `REPEATABLE READ` como *snapshot isolation* y
  `SERIALIZABLE` como SSI en Postgres; `REPEATABLE READ` con *gap locks* y lecturas bloqueantes en
  MySQL; el `SERIALIZABLE` de Oracle, que es *snapshot isolation* (apuesta sin resolver).
- **🪞 Apuesta candidata:** "el *write skew* de la muestra pasa en `REPEATABLE READ` de Postgres, y
  en `SERIALIZABLE` una de las dos transacciones falla con un error de serialización".
- **💥 Rotura:** el error de serialización sin bucle de reintento en la aplicación.
- **⚰️ Autopsia:** "ponemos `SERIALIZABLE` y listo", sin reintentos.
- **⚖️ Veredicto:** cuándo no subir el aislamiento, y resolverlo con una restricción o con un
  bloqueo explícito.

### 🔢 F16 — El folio sin huecos (10 h · 26 ejercicios)

- **El dolor:** `DMax + 1` (2004), `UltimoNumero` sin transacción (2015), y el web service fiscal
  que exige el último autorizado más uno y rechaza con el error 10016.
- **El mecanismo:** por qué una secuencia no sirve (no es transaccional: el `ROLLBACK` deja huecos, y
  la caché también); la carrera del `max() + 1`; la fila contador por punto de venta con
  `UPDATE … RETURNING` y lo que serializa; los *advisory locks*; y **el diseño que corresponde al
  dominio**: el número se asigna en el paso de autorización, no al crear el comprobante. Un web
  service fiscal simulado en Python responde como el real.
- **🪞 Apuesta candidata:** "con la fila contador, tres cajas concurrentes emiten 10.000
  comprobantes con cero duplicados y cero huecos, y la espera por comprobante crece con la duración
  de la transacción que retiene el número".
- **💥 Rotura:** el rechazo 10016, reproducido con el diseño de 2015.
- **⚰️ Autopsia:** `UltimoNumero`, la tarde de julio y los cuarenta pacientes.
- **⚖️ Veredicto:** cuándo **no** exigir numeración sin huecos. Casi nunca hace falta: el protocolo
  no la necesita, y solo el comprobante fiscal la exige por ley.
- **Es la fase estrella del curso**, y la que primero se publica como vídeo.

### ♻️ F17 — MVCC y su factura (10 h · 24 ejercicios)

- **El dolor:** la exportación nocturna que lee durante horas mientras el laboratorio corrige
  resultados.
- **El mecanismo:** versiones de fila, `xmin`/`xmax`, tuplas muertas, VACUUM y autovacuum, *bloat*
  medido (`pgstattuple`), HOT, el horizonte de `xmin` retenido por una transacción larga, y el
  *wraparound* como advertencia. En MySQL, el *purge* y la *history list length*. En Oracle, el
  *undo* y `ORA-01555`: se publica el mensaje, no el resultado.
- **🪞 Apuesta candidata:** "una lectura abierta durante 30 minutos mientras se corrigen resultados
  deja la tabla al menos al doble de su tamaño, y VACUUM no la achica".
- **💥 Rotura:** `ORA-01555 snapshot too old`, como apuesta sin resolver, y el *bloat* medido en
  Postgres.
- **⚰️ Autopsia:** la marca `Llamado` y `LlamadoDos` de `ParaLlamar`, actualizada fila por fila toda
  la tarde.
- **⚖️ Veredicto:** cuándo MVCC cobra más de lo que da, y la carga que conviene sacar del motor.

### 🔐 F18 — Bloqueos, deadlocks y DDL (10 h · 26 ejercicios)

- **El dolor:** el formulario de hemograma abierto a la hora del almuerzo, y la historia típica de
  "nos fuimos a Mongo" que empieza con un `ALTER TABLE` que bloqueó producción.
- **El mecanismo:** bloqueos de fila, `FOR UPDATE`, `NOWAIT` y `SKIP LOCKED`; `lock_timeout` e
  `idle_in_transaction_session_timeout`; *deadlocks* por orden de adquisición; `pg_locks` y
  `performance_schema.data_locks`; los niveles de bloqueo del DDL en Postgres, **la cola de bloqueos
  detrás de un `ACCESS EXCLUSIVE`**, `CREATE INDEX CONCURRENTLY` y qué `ALTER` reescribe la tabla;
  el DDL online de MySQL (`INSTANT`, `INPLACE`) y el *metadata lock*.
- **🪞 Apuesta candidata:** "un `ALTER TABLE` que espera detrás de una lectura larga bloquea a
  todas las sesiones nuevas, aunque él mismo tarde milisegundos".
- **💥 Rotura:** el *deadlock* detectado, y el tiempo de espera de bloqueo de MySQL, con sus
  mensajes.
- **⚰️ Autopsia:** el `ALTER TABLE` de las diez de la mañana.
- **⚖️ Veredicto:** cuándo el DDL online no alcanza y hace falta *expand/contract* (F25).
- 💀 **Boss del Bloque III — "Una tarde de julio"**, pedido por Matías Ledesma.

---

## 🍃 7. Bloque IV — Lo NoSQL dentro del SQL (30 h)

El bloque donde el curso tiene que ser más honesto, porque es donde Florencia tiene razón en algo.

### 🧾 F19 — JSON en los motores (10 h · 24 ejercicios)

- **El dolor:** unos 1.100 tipos de determinación, y el antibiograma de microbiología (el germen,
  los antibióticos, la sensibilidad a cada uno) que no calza en ninguna tabla. Liliana lo sabe desde
  1996.
- **El mecanismo:** `jsonb` por dentro, operadores y `jsonpath`; GIN con `jsonb_ops` contra
  `jsonb_path_ops`; índices de expresión sobre `->>`; validar la forma con `CHECK`. En MySQL, el
  JSON binario, las columnas generadas indexadas y los índices multivalor. En Oracle, el tipo JSON
  nativo y la validación por esquema (apuesta sin resolver).
- **🪞 Apuesta candidata:** "la búsqueda de antibiogramas resistentes a un antibiótico, con GIN
  `jsonb_path_ops`, lee menos del 1 % de los bloques del *seq scan*, y cada corrección de un
  antibiótico reescribe el documento entero en WAL".
- **💥 Rotura:** la actualización chica sobre un documento grande, medida en bytes de WAL.
- **⚰️ Autopsia:** la columna `extra jsonb` que terminó siendo el esquema.
- **⚖️ Veredicto:** cuándo `jsonb` es la respuesta honesta, y cuándo es un EAV con mejor marketing.

### 🍃 F20 — La propuesta de Florencia, medida (10 h · 26 ejercicios)

- **El dolor:** la app de 2024, que abre un enlace al portal PHP de 2013 para mostrar resultados.
- **El mecanismo:** el protocolo como documento en MongoDB, tal como lo propone Florencia y con su
  mejor argumento; el mismo documento en `jsonb`; y el modelo relacional del Bloque I con una
  **proyección** (una vista materializada o el documento armado con `json_agg` al leer). Se miden
  cinco operaciones: leer el informe, corregir un resultado, armar la presentación a la obra social,
  un cruce epidemiológico ad hoc y la auditoría de correcciones. Las Duality Views de Oracle, como
  la respuesta "las dos cosas" (apuesta sin resolver).
- **🪞 Apuesta candidata:** "leer el informe armado con `json_agg` desde el modelo relacional cuesta
  como mucho tres veces las lecturas del documento en Mongo, y el cruce epidemiológico en Mongo
  examina todos los documentos".
- **💥 Rotura:** la presentación a la obra social escrita como agregación de Mongo.
- **⚰️ Autopsia:** la premisa *"el EAV prueba que lo relacional no calza"*. Lo que prueba es que un
  EAV no es un modelo relacional.
- **⚖️ Veredicto:** **lo que se le concede a Florencia, con número**: el modelo de lectura de la
  app. La respuesta es una proyección o un documento derivado, no una segunda fuente de verdad.
  Enlaza con las fases documentales de la NoSQL Lite.

### 🔭 F21 — Hasta dónde llega el motor (10 h · 24 ejercicios)

- **El dolor:** la recepción busca pacientes por nombre mal escrito; el nomenclador tiene prácticas
  que son paneles de otras prácticas (el perfil lipídico); Norma quiere buscar en las observaciones
  libres de treinta años.
- **El mecanismo:** búsqueda de texto completo (`tsvector` con configuración en español y
  `unaccent`) y trigramas para búsqueda interactiva; `WITH RECURSIVE` sobre la jerarquía de
  prácticas y la cadena de derivaciones; `pgvector` como muestra breve. Cada uno con su punto de
  rotura y **el enlace a su fase de la NoSQL Lite**, que es donde está el motor dedicado.
- **🪞 Apuesta candidata:** "el CTE recursivo del nomenclador completo examina menos filas que la
  versión que el informe hace hoy con cuatro `LEFT JOIN` fijos".
- **💥 Rotura:** la búsqueda de texto completo sobre observaciones con abreviaturas del laboratorio
  (`HEMOLIZ.`, `S/MUESTRA`), donde el diccionario no ayuda.
- **⚰️ Autopsia:** el `LIKE '%PEREZ%'` de la pantalla de recepción.
- **⚖️ Veredicto:** hasta dónde llega cada uno, y cuándo el motor dedicado se gana su lugar.
- 💀 **Boss del Bloque IV — "El informe en la app"**, pedido por Florencia Marchetti.

---

## 🌐 8. Bloque V — La base en la red (30 h)

### 🌙 F22 — La exportación de las 9:40 (15 h · 28 ejercicios)

- **El dolor:** la exportación nocturna al portal, que en la pandemia empezaba a las 22:00 y
  terminaba a las 9:40; la notificación obligatoria en doce horas copiada a mano; y la interfaz con
  el SIH, *"la pieza del sistema que más incidentes genera"*, vista desde la base.
- **El mecanismo:** lote contra flujo; la exportación incremental por marca de agua y **la fila que
  se pierde** porque su transacción confirmó tarde con una marca anterior; CDC por decodificación
  lógica; el patrón *outbox*; la cola dentro de Postgres con `SKIP LOCKED`; `LISTEN`/`NOTIFY`.
- **Mensajes entre bases, sin broker:** la tabla de mensajes entrantes con una restricción única
  sobre su identificador (la idempotencia la hace cumplir el motor), las correcciones fuera de
  orden resueltas con un número de versión, y el mensaje veneno apartado a una tabla de descartes.
  Todo en SQL y Python. Las colas de Oracle (AQ/TxEventQ), como apuesta sin resolver.
- **El puente Java queda para el 💀 boss del puente (D3)**, al cierre del bloque: esta fase deja
  medida la cola dentro de la base, que es contra lo que el boss compara el broker.
- **🪞 Apuesta candidata:** "la cola en Postgres con `SKIP LOCKED` y cuatro consumidores procesa el
  día de la red sin duplicados; la exportación por marca de agua pierde filas con transacciones
  concurrentes, y la cantidad se cuenta contra la verdad del generador".
- **💥 Rotura:** las filas perdidas por la marca de agua.
- **⚰️ Autopsia:** la doble escritura, en la base y en el sistema de destino, sin *outbox*.
- **⚖️ Veredicto:** hasta dónde llega la cola dentro de la base, con número. La otra mitad de la
  pregunta, **¿hacía falta un broker?**, la contesta el boss del puente.

### 🔌 F23 — La base como producto (15 h · 26 ejercicios)

- **El dolor:** el incidente del portal de 2018, los catorce mil informes y la corrección que no
  corrigió nada.
- **El mecanismo:** PostgREST sobre un esquema `api` de vistas; **seguridad por fila (RLS)** como la
  corrección real del IDOR: el paciente ve lo suyo y el médico derivante ve lo que derivó, por
  *claims* del JWT; el esquema como contrato, con vistas versionadas; ORDS de Oracle (apuesta sin
  resolver) y Data API builder (track) como equivalentes; y **cuándo la lógica en la base es una
  cárcel**, con los miles de paquetes PL/SQL del SIH como caso.
- **🪞 Apuesta candidata:** "con índice sobre la columna de la política, RLS agrega un filtro que
  apenas cambia las lecturas; sin ese índice, cada consulta del portal recorre la tabla entera".
- **💥 Rotura:** la política sin índice, y el `INSERT` que viola la política, con su mensaje.
- **⚰️ Autopsia:** el MD5 del número de protocolo, otra vez, ahora con la corrección de verdad al
  lado.
- **⚖️ Veredicto:** cuándo no exponer la base como API.
- 💀 **Boss del Bloque V — "Las 9:40"**, pedido por Verónica Colombo, en SQL y Python.
- 💀☕ **Boss del puente — "El puente"**, pedido por Matías Ledesma: la interfaz con el SIH con Java
  21, ActiveMQ Artemis y mensajes que imitan HL7 v2 (`ORM` y `ORU`). El broker no es el tema: es el
  lugar donde aparecen la doble escritura, la entrega duplicada, las correcciones fuera de orden y
  el mensaje veneno. Cierra con **¿hacía falta un broker?**, medido contra la cola de F22. Opcional
  y fuera de las 252 h, como todos los boss.

---

## ⚖️ 9. Bloque VI — El árbitro (32 h)

El capstone no es un boss: es contenido del curso, con sus ejercicios. Su materia es **decidir y
defender**, con la bitácora como evidencia. Tiene su propia plantilla.

### 🏗️ F24 — El diseño (12 h · 22 ejercicios)

Las tres propuestas, puestas lado a lado con la bitácora en la mano: la de Verónica (el laboratorio
como módulo del SIH), la de Florencia (los resultados como documentos) y la del lector. Por cada
parte de Alameda: las cinco preguntas, el diseño y la medición que lo sostiene. **Se entrega un
documento de diseño**, y los ejercicios son las preguntas que un comité le haría.

### 🚚 F25 — La migración sin parar (10 h · 24 ejercicios)

*Expand/contract* a escala de sistema; la convivencia de los dos modelos con CDC desde `legacy`;
**las 71 tablas anchas** migradas al modelo tipado con consultas de reconciliación (conteos, sumas
de control y la verdad del generador); el maestro de pacientes unificado con el del SIH en Oracle,
con reconciliación entre motores; el plan de corte con vuelta atrás. Y desmontar con cuidado *"migrar
es imposible"*, que tiene algo de razón.

### 🏛️ F26 — El comité (10 h · 20 ejercicios)

La factura: licencias (Oracle por núcleo contra Postgres), personas (**Matías tiene que poder
operarlo**) y riesgo, incluido quién mantiene MySQL dentro de cinco años. El árbol de veredicto:
**cuándo no usar un motor relacional**. Y el cierre del boss global: la facturación de un martes,
corriendo entera sobre la base nueva.

---

## 🪟 10. Track opcional — SQL Server (40 h, fuera de las 252)

Convención del repositorio para tracks: prefijo `ss`, prompts propios
(`prompts/prompts-sqlserver-fase.md`), tags en `ss-fase-*` y **cero añadidos a los documentos del
camino base**. Laboratorio en contenedor Linux, con emulación en Apple Silicon (declarada). **Todo
resultado de SQL Server va sin resolver** (guía §6.1).

| # | Fase | h | Ej. | Qué cambia la decisión |
|---|---|---|---|---|
| ss01 | La base en su motor original | 8 | 20 | cargar la caja en SQL Server y correr el T-SQL de Matías tal cual; la ventana de 2049, en vivo |
| ss02 | Pesimista contra RCSI | 8 | 22 | `READ COMMITTED` con bloqueos por defecto, el formulario del almuerzo que bloquea lectores, `READ_COMMITTED_SNAPSHOT` y el *version store* |
| ss03 | Query Store y *parameter sniffing* | 8 | 22 | regresiones de plan, planes forzados, `OPTIMIZE FOR` |
| ss04 | Clustered, `NEWSEQUENTIALID` y tablas temporales | 8 | 20 | el caso UUID en su motor más famoso; tablas versionadas por sistema para la auditoría de resultados |
| ss05 | Data API builder y el tipo `json` | 8 | 20 | DAB contra PostgREST; el tipo `json` nativo de SQL Server 2025 (a verificar) |
| ssa-01 | Qué cambia en Windows | — | 6 | autenticación integrada, WSFC contra Pacemaker, SSMS, funciones ausentes en Linux |

**Requisito:** el camino base hasta F18. `ss01` se puede hacer después de F04.

---

## 📊 11. Resumen de fases

| # | Archivo | Bloque | Horas | Ejercicios |
|---|---|---|---|---|
| 00 | `00-la-base-que-nadie-diseno.md` | 0 | 4 | 12 |
| 01 | `01-la-caja-y-el-arnes.md` | 0 | 5 | 22 |
| 02 | `02-las-cinco-preguntas-desde-el-otro-lado.md` | 0 | 3 | 12 |
| 03 | `03-lo-que-sql-le-hace-al-modelo.md` | I | 8 | 22 |
| 04 | `04-un-valor-un-hecho.md` | I | 8 | 24 |
| 05 | `05-una-persona-no-es-su-documento.md` | I | 8 | 24 |
| 06 | `06-cuarta-y-quinta-forma-normal.md` | I | 8 | 20 |
| 07 | `07-el-tiempo-en-el-modelo.md` | I | 8 | 24 |
| 08 | `08-los-dos-extremos-del-mismo-error.md` | I | 8 | 26 |
| 09 | `09-el-tamano-de-las-cosas.md` | II | 10 | 24 |
| 10 | `10-identificadores.md` | II | 10 | 26 |
| 11 | `11-indices-y-lo-que-cuestan.md` | II | 10 | 28 |
| 12 | `12-estadisticas-y-cardinalidad.md` | II | 10 | 24 |
| 13 | `13-el-optimizador-en-tres-motores.md` | II | 10 | 24 |
| 14 | `14-la-base-no-estaba-lenta.md` | II | 10 | 26 |
| 15 | `15-aislamiento-comparado.md` | III | 10 | 26 |
| 16 | `16-el-folio-sin-huecos.md` | III | 10 | 26 |
| 17 | `17-mvcc-y-su-factura.md` | III | 10 | 24 |
| 18 | `18-bloqueos-deadlocks-y-ddl.md` | III | 10 | 26 |
| 19 | `19-json-en-los-motores.md` | IV | 10 | 24 |
| 20 | `20-la-propuesta-de-florencia.md` | IV | 10 | 26 |
| 21 | `21-hasta-donde-llega-el-motor.md` | IV | 10 | 24 |
| 22 | `22-la-exportacion-de-las-9-40.md` | V | 15 | 28 |
| 23 | `23-la-base-como-producto.md` | V | 15 | 26 |
| 24 | `24-el-diseno.md` | VI | 12 | 22 |
| 25 | `25-la-migracion-sin-parar.md` | VI | 10 | 24 |
| 26 | `26-el-comite.md` | VI | 10 | 20 |
| | **Total** | | **252 h** | **634** |

Los slugs son canónicos: una fase no se renombra una vez escrita. Los de `ss` están en §10, y los de
los apéndices en la propuesta de apéndices §2.

---

## 📌 12. Registro de decisiones

Lo que sostiene este temario. **Cerradas por Oskar el 30/09/2026**, y trasladadas el mismo día al
sitio que dice "Manda en". Esta tabla queda como registro; si una decisión cambia, se cambia primero
en su sitio y después aquí.

| ID | Decisión | Valor | Estado | Manda en |
|---|---|---|---|---|
| D1 | Estructura | 27 fases en 7 bloques, Bloque I de 6 × 8 h (§1.1) | ✅ | alcance §12 |
| D2 | Operación | Fuera, salvo el particionado como diseño y "qué va en la base" (F09) | ✅ | alcance §11 |
| D3 | Puente Java con Artemis | **Boss** ("El puente", al cierre del Bloque V), no laboratorio de F22 | ✅ | alcance §9 y §13 |
| D4 | Volumen | Perfiles S, M y L; **S y M por defecto**; M ≈ 200.000 pacientes y 15 M de resultados, y siempre dentro de 16 GB con los tres motores | ✅ | alcance §7.1, `a05` |
| D5 | Miniproyectos de otras empresas | No: todo gira alrededor de Alameda | ✅ | alcance §11 |
| D6 | Publicación | Repositorio tratado como público; de Oracle y SQL Server, solo la estructura del plan | ✅ | alcance §6.1, guía §6.1 |
| D7 | Nombre | Ruta SQL, en `cursos-bd/ruta-sql/` | ✅ | alcance §12 |
| D8 | Track SQL Server | `ss01`–`ss05` y `ssa-01`, 40 h fuera de las 252 | ✅ | §10 |
| D9 | Boss | Cinco de bloque, el boss del puente en Java y el global "Un martes" | ✅ | alcance §13 |
| D10 | Nombres | Inglés, convención habitual de SQL (`snake_case`, singular) y palabras completas dentro del límite del motor más restrictivo; `legacy` conserva los nombres de la caja | ✅ | alcance §7, guía §5 |
| D11 | Java | Java 21 LTS, solo en el boss del puente y en `a10` | ✅ | `a06` |
| D12 | Versiones | Última estable, o última LTS donde exista la línea, a la fecha de la verificación de laboratorio | ✅ | `a02` |
| D13 | Dónde se carga `legacy` | Donde hace falta: Postgres siempre; MySQL y Oracle, las tablas que pide cada fase | ✅ | `a05` |
| D14 | Arnés de carreras | Intercalado determinista de sesiones en Python (`lab race`) | ✅ | `a04` |
| D15 | El Access de museo | Apéndice opcional `a10`; el código pasa de `taller/accdb-museo/` a `src/a10-el-access-de-museo/` en su tanda | ✅ | propuesta de apéndices |
| D16 | Punto de rotura en fases de plan | El precipicio del plan, con la línea que cambió (§2) | ✅ | guía §6 |
| D17 | Reubicación de archivos | La historia en `00-historia-de-alameda.md`, con la nomenclatura de los otros cursos; la propuesta de diseño en `prompts/_desechable-propuesta-ruta.md` | ✅ | — |
