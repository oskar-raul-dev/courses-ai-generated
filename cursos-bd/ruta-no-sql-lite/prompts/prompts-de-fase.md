# 🗺️ Prompts iniciales por fase
## Ruta NoSQL Lite — 26 chats, 26 entregables

Cada sección es el prompt completo de una fase, listo para copiar al chat que la redacta.
Los valores salen de [`propuesta-fases-y-alcance.md`](propuesta-fases-y-alcance.md); si
alguna vez cambian allí, se cambian aquí después y **nunca al revés**.

**Un chat, un archivo.** Si un chat no produce entregable, o sobra o se salió de alcance.

> ⚠️ **Antes del primer chat.** Sube al conocimiento del proyecto, en este orden:
> `prompts/alcance-del-proyecto.md`, `prompts/guia-de-estilo-y-convenciones.md`,
> `prompts/propuesta-fases-y-alcance.md`, `prompts/propuesta-apendices-y-alcance.md`,
> `prompts/plantillas-de-capitulo.md`, `prompts/formato-bitacora-de-medicion.md` y
> `00-historia-de-condor.md`. Para las fases B, añade `miniproyectos.md`,
> `prompts/formato-de-miniproyectos.md` y el `h-mini` de la familia.
> **No subas** ningún archivo `_desechable-*`: el curso no los cita.

> ⚠️ **Antes de la primera fase que levante un motor (F03 en adelante).** Tienen que estar
> escritos y verificados `a01`, `a02`, `a05` y `a06`, y hecha la sesión de verificación de
> laboratorio. Sin digests fijados, ninguna fase puede publicar una versión.

---

## 🧱 El marco común

Va entero en el prompt de la Fase 00 y comprimido en los demás. **No lo repitas en el
documento: aplícalo.**

```markdown
## Marco (no lo repitas, aplícalo)

Fuentes de verdad, en este orden: (1) `prompts/alcance-del-proyecto.md`,
(2) `prompts/guia-de-estilo-y-convenciones.md`, (3) `prompts/propuesta-fases-y-alcance.md`,
(4) `prompts/propuesta-apendices-y-alcance.md`, (5) `prompts/plantillas-de-capitulo.md`,
(6) `prompts/formato-bitacora-de-medicion.md`, (7) `prompts/contrato-de-nombres.md` y
`prompts/diccionario-de-terminos.md`, (8) `00-historia-de-condor.md`, que es la empresa del
curso y la fuente de todo lo narrativo, (9) las fases ya escritas y aprobadas, (10) decisiones de
este chat. Los documentos desechables no cuentan y no se citan.

Reglas que no se negocian:
- **Nada se publica sin haberse ejecutado.** Ningún número, ninguna versión, ninguna
  salida de terminal inventada. Lo que no se verificó se declara con esas palabras.
- **Se mide la forma, no la velocidad.** Viajes, examinados contra devueltos, particiones
  tocadas, fan-out, amplificación. Ningún veredicto se sostiene sobre un milisegundo.
- **Postgres es la línea base y va bien jugado**, con su índice y su extensión correctos.
- **Autopsia, no juicio.** En la mesa está la decisión, nunca la persona.
- **Aquí no se enseña Docker.** Más de dos párrafos de contenedores: remite a `a01`/`a02`,
  o nombra en prosa el curso de Docker del repositorio, sin enlace.
- **Código en inglés, comentarios en español con tildes.** Nombres del dominio de Cóndor
  fijos: aircraft, part, partCatalog, assembly, workOrder, reading, pirep, technician,
  hangar, supplier.
- **Todo lo que se mide se mide sobre Cóndor.** Los miniproyectos 🧰 de otras empresas se
  anuncian al abrir cada fase B, pero ningún número suyo entra a la bitácora.
- La plantilla de fase se sigue literal, sin secciones extra ni reordenadas, y el cierre
  lleva el bloque 🏷️ del tag.
- **Nada publicado cita `prompts/` ni enlaza otro curso** (D-03): la regla se dice en el texto o
  se remite al apéndice que la publica; los otros cursos, solo en prosa. Una fase que todavía no
  existe se nombra sin enlace y va a la deuda del plan.
- **Diagramas en Mermaid** (D-12, guía §18.1), dibujados con `mmdc` antes de publicar.
- **Sesión:** las pruebas van a `zz-code/` (`python3 zz-code/nuevo.py ruta-no-sql-lite`), con
  contenedores etiquetados `curso=ruta-no-sql-lite`, puertos aleatorios y borrado con sus volúmenes
  al cerrar; nada se instala sin pedirlo; sin commits; secuencial y sin agentes. Al cerrar,
  `python3 prompts/verificar-corpus.py` en cero.
```

Y el **protocolo de tres pasos**, que cierra todos los prompts:

```markdown
## Cómo quiero que trabajes

**Paso 1 — Preguntas antes de escribir.** No redactes. Devuélveme: (a) preguntas
bloqueantes numeradas, marcando cuáles puedes asumir con un valor por defecto; (b) tu
lectura del alcance y si las horas cuadran; (c) un esbozo de la sección más larga;
(d) cualquier contradicción con las fases ya escritas — dímela, no la resuelvas.
**Paso 2 — Redacción**, cuando yo responda. Si aparece una duda nueva, **para y pregunta**
en vez de rellenar con un supuesto plausible.
**Paso 3 — Autoverificación** contra el checklist de §15 de la guía de estilo, reportada en
lista corta.
```

---

## # Fase 00 — La decisión que se hereda

```markdown
Este es el chat de la **Fase 00 — 📜 La decisión que se hereda**, del curso Ruta NoSQL
Lite. Su único entregable es `00-la-decision-que-se-hereda.md`.

## Marco (no lo repitas, aplícalo)

{{pega aquí el marco común completo}}

## Identidad de esta fase

- Fase 00 de 25 · Bloque 0 — El instrumento · **4 h**
- Depende de: nada. Es la puerta de entrada del curso.
- Habilita: F01
- Apéndices de apoyo: ninguno todavía
- Entorno de ejecución: ninguno. **Esta fase se lee.**

## Alcance

- **Propósito:** que el lector reconozca su propia decisión en una de las autopsias antes
  de que el curso le proponga nada.
- **Qué entra:** las autopsias ⚰️. **La central es la de Cóndor** (§3 de la historia): el
  sistema documental de Camilo, elegido con un argumento correcto, el cruce con órdenes de
  trabajo escrito en la aplicación, y la factura de marzo de 2026 —dos verdades sobre un
  actuador de tren y cuatro días de tres personas para reconstruirlo—. Al lado, las de la
  industria que el curso retoma: "Cassandra porque escala", "metimos el JSON completo",
  Redis como almacén primario, Elasticsearch como fuente de verdad. Cada una con decisión, mejor argumento de quien la tomó, por qué era razonable,
  factura a los dos años con número y coste de salida. Las dos situaciones —hype y zona de
  confort— presentadas como la misma decisión tomada por el mismo motivo malo. Y el aviso
  de que **casi siempre gana Postgres**, dicho aquí y no al final.
- **Qué NO entra:** ningún motor, ningún contenedor, ninguna medición. Las cinco preguntas
  se anuncian pero se desarrollan en F02.
- **La precisión que marca la casa:** Mongo sí tiene transacciones multi-documento desde
  la 4.0. La autopsia honesta es "las había, exigían réplica, y nadie las usó porque
  eligieron Mongo justamente para no pensar en eso". Deja la primera entrada del catálogo
  de errores: `Transaction numbers are only allowed on a replica set member or mongos`.
- **Ejercicios: 12** (exención declarada: fase de criterio). De lectura y decisión sobre
  esquemas reales, no de ejecución.
- **Plantilla:** la del Bloque 0, en `plantillas-de-capitulo.md`. **Longitud:** 2.000–3.000
  palabras de cuerpo (4 h).

## Pendientes que pueden bloquear

- Las cifras de las autopsias de la industria. Las de Cóndor salen de la historia y no se
  inventan otras. Para las demás, si no son de un caso real que puedas sostener, escríbelas
  como **escenario declarado** —"un sistema de este tamaño, con esta forma"— y dilo. Lo que
  no se puede es dar por medido lo que no se midió.

## Audiencia

Ingeniero senior con sesgo relacional, que probablemente tomó o heredó una de estas
decisiones —igual que Camilo—. No le expliques qué es una transacción ni qué es JSON. Sí explícale por qué el
esquema no desapareció: se mudó al código y dejó de estar documentado.

## Cómo quiero que trabajes

{{protocolo de tres pasos}} Vigila especialmente el tono: si una autopsia suena a juicio
sobre una persona, está mal escrita.
```

---

## # Fase 01 — El dominio de flota y el arnés

```markdown
Este es el chat de la **Fase 01 — ✈️ El dominio de flota y el arnés**. Entregable:
`01-el-dominio-de-flota-y-el-arnes.md`.

## Marco

El de F00. Añade a las fuentes: **F00 cerrada y aprobada**, y los apéndices `a01`, `a02`,
`a05` y `a06` ya escritos y verificados.

## Identidad

- Fase 01 de 25 · Bloque 0 · **5 h** · Depende de F00 · Habilita F02
- Apéndices de apoyo: a01, a02, a05, a06, a07
- Entorno: TypeScript · Motor: solo PostgreSQL (línea base)

## Alcance

- **Propósito:** dejar el laboratorio montado y el instrumento de medida calibrado, con
  Postgres cargado y midiendo.
- **Qué entra:** el dominio de Cóndor con sus diez entidades y sus relaciones (§6 de la
  historia), y los números de la casa que fijan los volúmenes (§5); el generador con
  semilla determinista y los tres volúmenes; el `compose.yaml` maestro con perfiles;
  Postgres arriba; y **cómo se mide la forma** con el primer `EXPLAIN (ANALYZE, BUFFERS)`
  del curso, leído campo por campo.
- **Qué NO entra:** ningún motor NoSQL. Ninguna comparación todavía.
- **Prueba de fuego:** el lector carga 1 M de filas, corre la consulta de referencia y
  obtiene **el mismo número de filas examinadas que el documento**. Si no coincide, el
  arnés está mal y el curso entero se cae — dilo con esas palabras.
- **Plantilla:** la del Bloque 0, en `plantillas-de-capitulo.md`. **Longitud:** calíbrala en
  el paso 1 y dímelo (5 h, con laboratorio).
- **Ejercicios: 22**, la mitad de medir y leer planes.

## Pendientes

- El esquema relacional de referencia del dominio: decídelo aquí y déjalo escrito, porque
  las diez familias lo van a citar.

## Audiencia

Senior relacional. Aquí está en su terreno y hay que aprovecharlo: es la última fase donde
todo le resulta familiar, y conviene decírselo.

## Cómo quiero que trabajes

{{protocolo}} Presta atención a que el generador sea determinista de verdad y a que el
número de la prueba de fuego esté ejecutado, no estimado.
```

---

## # Fase 02 — Las cinco preguntas

```markdown
Este es el chat de la **Fase 02 — ❓ Las cinco preguntas**. Entregable:
`02-las-cinco-preguntas.md`.

## Marco

El de F00, más F01 cerrada.

## Identidad

- Fase 02 de 25 · Bloque 0 · **3 h** · Depende de F01 · Habilita F03
- Entorno: ninguno. Fase de criterio.

## Alcance

- **Propósito:** entregar el instrumento de decisión completo, que es lo único de este
  curso que no se puede copiar de la documentación de nadie.
- **Qué entra:** las cinco preguntas —frontera transaccional, estabilidad de las consultas,
  unidad de lectura, saltos de la relación típica, exactitud contra parecido—, cada una con
  **el modo de fallo que predice** y por qué las preguntas habituales ("¿esquema fijo?",
  "¿quiero joins?") no predicen nada. Y el cierre: **"ya elegiste mal, ¿ahora qué?"** — el
  triaje de migración con 400 GB en producción, qué se migra primero, qué se deja, cómo se
  convive con dos bases durante meses y cómo se mide que va bien.
- **Qué NO entra:** las respuestas por familia; cada minicurso trae las suyas en su fase B.
- **Plantilla:** la del Bloque 0, en `plantillas-de-capitulo.md`. **Longitud:** 2.000–3.000
  palabras de cuerpo (3 h).
- **Ejercicios: 12** (exención declarada). Se entregan dominios descritos y se pide
  contestar las cinco preguntas y defender la familia elegida.

## Audiencia

Senior relacional. La sección de triaje es la que más le va a servir en el trabajo real:
escríbela como si la fuera a usar el lunes.

## Cómo quiero que trabajes

{{protocolo}} Vigila que la pregunta de la frontera transaccional quede marcada como **la
que más caro sale ignorar**, con el porqué: cuando se disuelve no avisa.
```

---

## # Fases 03 y 04 — Documental (MongoDB)

```markdown
Este es el chat de la **Fase {{03|04}}**, minicurso de la familia **documental** con
MongoDB. Entregable: `{{03-documental-levantar-y-modelar.md | 04-documental-romper-y-medir.md}}`.

## Marco

El de F00, más las fases anteriores cerradas y los apéndices a01–a07 disponibles.
Plantilla: **fase {{A|B}}**, seguida literal.

## Identidad

- Fase {{NN}} de 25 · Bloque I — Los dos que ya usas · **10 h**
- Motor: MongoDB · Línea base: PostgreSQL JSONB · Entorno: TypeScript
- Ejercicios: **{{26|28}}**

## Alcance — Fase 03 (levantar y modelar)

- La ficha de aeronave, polimórfica de verdad —turbohélice, monomotor de carga y
  helicóptero no comparten casi nada—; embeber contra referenciar y la pregunta que
  lo decide (unidad de lectura); índices sobre campos anidados y sobre arrays con su coste;
  el límite de 16 MB y qué crece sin cota en este dominio; `$lookup` y lo que hace por
  dentro.
- 🪞 **El instinto que falla:** "normalizo, que para eso aprendí". La ficha referenciada
  necesita 3 + N viajes para lo que la embebida resuelve en uno. **Mídelo.**
- ⚰️ **Situación 3:** Mongo con referencias por todas partes y el join en el código de la
  aplicación — ahí se disolvió la frontera transaccional y nadie lo anotó. Es lo que le
  pasó al sistema de Camilo.

## Alcance — Fase 04 (romper, medir y decidir)

- 🧰 Al cerrar los objetivos, anuncia el miniproyecto: `h-mini-01-documental-barlovento.md`.
- 🪞 **Apuesta, escrita antes:** "Postgres con JSONB y GIN aguanta la misma consulta
  polimórfica con menos de 2× de degradación frente a Mongo".
- Medición contra JSONB en tres consultas del dominio; el documento que crece sin cota;
  transacciones multi-documento, la exigencia de replica set y el error del standalone; la
  actualización de un array anidado.
- 💥 **Punto de rotura:** el documento que no cabe, con el volumen exacto y el mensaje literal
  (en la verificación salió `Resulting document after update is larger than 16777216`, code 10334).
- ⚖️ **Veredicto:** no uses documental cuando la frontera transaccional cruza agregados,
  cuando la unidad de lectura son rebanadas, y cuando todos tus documentos tienen las
  mismas claves — eso es una tabla cara.

## Audiencia

Senior relacional que probablemente ya usó Mongo. No le expliques qué es una colección. Sí
explícale qué significa exactamente `totalDocsExamined` frente a `nReturned`, y por qué el
cociente es la métrica y no el total.

## Cómo quiero que trabajes

{{protocolo}} En la 04, la apuesta va escrita **antes** de la medición y no se edita
después.
```

---

## # Fases 05 y 06 — Clave-valor (Valkey)

```markdown
Este es el chat de la **Fase {{05|06}}**, minicurso de **clave-valor** con Valkey.
Entregable: `{{05-clave-valor-levantar-y-modelar.md | 06-clave-valor-romper-y-medir.md}}`.

## Identidad

- Bloque I · **10 h** · Motor: Valkey · Línea base: tabla `UNLOGGED` de Postgres
- Entorno: TypeScript · Ejercicios: **{{24|26}}**
- La 06 cierra bloque: lleva además el 💀 **boss del Bloque I**.

## Alcance — Fase 05

- La reserva del puesto con foso, el candado de la orden abierta desde dos terminales, las
  sesiones del terminal de plataforma, una cola de trabajos; hash, set ordenado y stream, y cuándo cada uno; TTL como
  parte del modelo y no como limpieza; **el modelo de acceso más puro**: sin la clave, no
  hay consulta.
- 🪞 "Le pongo un índice secundario". No hay. Hay que escribir la segunda estructura y
  mantenerla coherente a mano.
- ⚰️ Valkey como almacén primario, y el día del reinicio sin persistencia.

## Alcance — Fase 06

- 🧰 Al cerrar los objetivos, anuncia el miniproyecto: `h-mini-02-clave-valor-nodo-sur.md`.
- 🪞 **Apuesta, en forma:** "una tabla `UNLOGGED` de Postgres con la sesión indexada por clave resuelve cada operación en los mismos viajes que Valkey y ocupa menos de 3× su memoria por sesión; lo que de verdad las separa es qué se pierde al reiniciar". La latencia va solo como contexto, con la máquina
  declarada: el tiempo solo es argumento en F22.
- `maxmemory`, políticas de evicción y el error literal
  `OOM command not allowed when used memory > 'maxmemory'`; RDB contra AOF y qué se pierde
  exactamente en cada una; el coste operativo de un componente más en el diagrama.
- 💥 El dataset que no cabe en RAM y la evicción silenciosa.
- ⚖️ Clave-valor es **un efecto, no una causa**: al lado de la fuente de verdad, nunca en
  su lugar.
- 💀 **Boss del bloque — "La orden que entró dos veces":** lo pide Yamile Cruz. Componentes
  en Mongo, reservas y candados en Valkey, una orden de trabajo entró dos veces hace tres
  meses. Reproducir la carrera, encontrar qué frontera se
  disolvió, entregar informe con medición y arreglo mínimo.

## Cómo quiero que trabajes

{{protocolo}} El boss se escribe como encargo completo con sistema roto, en voz de quien
lo pide, no como un ejercicio 🔴 con mejor nombre.
```

---

## # Fases 07 y 08 — Analítico embebido (DuckDB)

```markdown
Este es el chat de la **Fase {{07|08}}**, minicurso de **analítico embebido** con DuckDB.
Entregable: `{{07-analitico-levantar-y-modelar.md | 08-analitico-romper-y-medir.md}}`.

## Identidad

- Bloque II — Leer de otra forma · **10 h** · Motor: DuckDB · Línea base: PostgreSQL
- Entorno: **Python** (con el arnés en TypeScript) · Ejercicios: **{{24|26}}**

## Alcance — Fase 07

- El costo por hora volada por modelo y por operador —el precio de venta de Ala Continua,
  que hoy Lucía arma a mano—; almacenamiento por columnas contra
  por filas, con diagrama y aritmética; Parquet como formato de intercambio; agregaciones
  sobre millones de filas sin servidor; el pivote hecho como se debe.
- 🪞 **El instinto que falla, y es el más importante del curso:** "si habla SQL, es lo mismo
  que Postgres". Agregar tres columnas sobre 200 M de filas lee tres columnas aquí y
  doscientos millones de filas allá. **La etiqueta no decide nada; el modelo de acceso sí.**
  Di explícitamente que este episodio es la tesis del curso demostrada con un contraejemplo
  que rompe la etiqueta "NoSQL".
- ⚰️ DuckDB tratado como base transaccional con varios escritores.

## Alcance — Fase 08

- 🧰 Al cerrar los objetivos, anuncia el miniproyecto: `h-mini-03-analitico-bengala.md`.
- 🪞 **Apuesta:** "el `ALTER TABLE` de una métrica nueva sobre la tabla ancha de Postgres
  cuesta un orden de magnitud más que añadir la columna en el modelo columnar".
- Medición en **columnas leídas contra filas leídas** — la derrota estructural de Postgres,
  que no depende de hardware ni de versión; el `EXPLAIN` de DuckDB; el dataset que no cabe
  en memoria y el spilling; la concurrencia de escritura.
- 💥 Dos procesos escribiendo el mismo archivo.
- ⚖️ Analítico embebido cuando cabe en una máquina, cambia poco y los lectores son decenas.
  Nunca como base de la aplicación.

## Audiencia

Senior relacional, y aquí especialmente cómodo porque es SQL. Aprovecha esa comodidad: es
lo que hace que el número duela y se recuerde.

## Cómo quiero que trabajes

{{protocolo}} Declara en el encabezado que esta fase se ejecuta en Python y por qué.
```

---

## # Fases 09 y 10 — Series temporales (TimescaleDB)

```markdown
Este es el chat de la **Fase {{09|10}}**, minicurso de **series temporales** con
TimescaleDB. Entregable:
`{{09-series-levantar-y-modelar.md | 10-series-romper-y-medir.md}}`.

## Identidad

- Bloque II · **10 h** · Motor: TimescaleDB · Línea base: Postgres con particionado
  declarativo · Entorno: TypeScript · Ejercicios: **26** en ambas

## Alcance — Fase 09

- Los parámetros de vuelo que se descargan al aterrizar —treinta aeronaves con registro,
  lecturas ordenadas que no se corrigen nunca—; hypertables y
  particionado por tiempo; roll-ups continuos de minuto a hora a día; retención y
  compresión **como parte del modelo**, no como mantenimiento; y por qué una restricción
  —los datos llegan en orden y no se actualizan— **se convierte en rendimiento**.
- 🪞 "Una tabla con índice en la fecha ya es una serie temporal". Lo es hasta que hay mil
  millones de filas y hay que borrar el año pasado: `DELETE` contra `DROP` de partición.
- ⚰️ Series temporales que se actualizan retroactivamente y rompen la compresión.

## Alcance — Fase 10

- 🧰 Al cerrar los objetivos, anuncia el miniproyecto: `h-mini-04-series-voltaria.md`.
- ⚖️ El veredicto declara la licencia: roll-ups continuos y compresión son Timescale License
  (alcance §12, 20), y el particionado declarativo de Postgres no tiene esa restricción.
- 🪞 **Apuesta:** "el particionado declarativo a secas llega al 80 % del rendimiento de
  Timescale y me ahorra una extensión". **El rival aquí es Postgres, y ese es el punto:**
  dilo explícitamente.
- Compresión medida en tamaño en disco antes y después; consultas por rango; **la
  cardinalidad que mata** —cada aeronave × parámetro como serie distinta—; el backfill contra
  una hypertable comprimida.
- 💥 La explosión de cardinalidad.
- ⚖️ Series temporales cuando los datos llegan ordenados, no se actualizan y se consultan
  por rango. Si falla una de las tres, no es tu familia.

## Cómo quiero que trabajes

{{protocolo}}
```

---

## # Fases 11 y 12 — Búsqueda (OpenSearch)

```markdown
Este es el chat de la **Fase {{11|12}}**, minicurso de **búsqueda** con OpenSearch.
Entregable: `{{11-busqueda-levantar-y-modelar.md | 12-busqueda-romper-y-medir.md}}`.

## Identidad

- Bloque II · **10 h** · Motor: OpenSearch · Línea base: Postgres FTS · Entorno: TypeScript
- Ejercicios: **{{26|28}}** · La 12 cierra bloque: lleva el 💀 **boss del Bloque II**.
- Apéndice obligatorio de apoyo: **a10** (por qué OpenSearch y no Elasticsearch).

## Alcance — Fase 11

- El catálogo de partes —ochenta mil referencias con alternos, equivalencias por modelo y
  proveedores que escriben el mismo número de cuatro formas— con sinónimos y tolerancia a
  errores de tecleo;
  el índice invertido por dentro —analizadores, tokens, stemming— con diagrama; facetas y
  agregaciones; y el `mapping`, **que es un esquema aunque se llame de otra forma**.
- 🪞 "Un `LIKE '%junta%'` ya busca". Busca, escanea la tabla entera, y no encuentra
  "juntas", ni "junta tórica", ni "junta torica" sin tilde.
- ⚰️ El motor de búsqueda como fuente de verdad, y el día del reindexado.

## Alcance — Fase 12

- 🧰 Al cerrar los objetivos, anuncia el miniproyecto: `h-mini-05-busqueda-bengala.md`.
- 🪞 **Apuesta:** "el full-text de Postgres con `tsvector` y GIN cubre el 90 % de este
  catálogo y nadie notará la diferencia".
- Medición contra Postgres FTS en relevancia, tolerancia a errores y facetas; el reindexado
  completo con 1 M de documentos y cuánto dura; el clúster en solo-lectura por disco lleno
  con `cluster_block_exception … read-only-allow-delete`; cuánto tarda en verse un
  documento recién escrito.
- 💥 Disco lleno e índice en solo-lectura.
- ⚖️ Búsqueda es **un índice, no una fuente de verdad**: siempre al lado y siempre
  reconstruible.
- 💀 **Boss del bloque — "El tablero que nadie puede reconstruir":** lo pide Lucía Arango,
  que va a renovar un contrato de Ala Continua con ese número. DuckDB, Timescale y
  OpenSearch dan tres cifras distintas para el costo por hora volada. Informe de reconciliación con la
  medición de cada camino.

## Cómo quiero que trabajes

{{protocolo}}
```

---

## # Fases 13 y 14 — Grafos (Neo4j)

```markdown
Este es el chat de la **Fase {{13|14}}**, minicurso de **grafos** con Neo4j. Entregable:
`{{13-grafos-levantar-y-modelar.md | 14-grafos-romper-y-medir.md}}`.

## Identidad

- Bloque III — Preguntas que no sabes escribir en SQL · **10 h** · Motor: Neo4j Community
- Línea base: `WITH RECURSIVE` en Postgres · Entorno: TypeScript
- Ejercicios: **{{24|28}}**

## Alcance — Fase 13

- La trazabilidad de Cóndor en sus dos formas: el despiece —qué pieza va dentro de qué
  conjunto, que es un árbol— y la historia de instalación —qué pieza estuvo en qué aeronave
  y cuándo, construida con los retiros e instalaciones de `workOrder`, que **no** es un
  árbol—; nodos, relaciones y propiedades, y por qué la relación es ciudadana de primera;
  Cypher lo justo para el dominio; la cardinalidad de travesía como medida.
- 🪞 "Eso es una tabla de adyacencia con un join recursivo". Lo es, hasta que la profundidad
  es desconocida de antemano.
- ⚰️ El grafo modelado como tablas —nodos genéricos con campo "tipo", relaciones sin
  propiedades—, que es perder exactamente lo único que el grafo daba. Más el producto
  cartesiano de Cypher con su aviso literal.

## Alcance — Fase 14 — ATENCIÓN: es la fase más importante del curso

- 🧰 Al cerrar los objetivos, anuncia el miniproyecto: `h-mini-06-grafos-voltaria.md`.
- 🪞 **La apuesta que el curso espera perder, y se escribe antes:** "el grafo gana a
  `WITH RECURSIVE` a partir del cuarto salto". Se mide. **Postgres aguanta.** Se reconoce la
  derrota, se publica el número, y *ahí* se sube la apuesta: lo que rompe no es descender un
  árbol, es **buscar un patrón** — ciclos, caminos entre dos nodos cualesquiera, anillos,
  profundidad variable y desconocida. Ese es el punto donde el grafo no es más cómodo, sino
  que lo otro **no se puede escribir**. En Cóndor, el árbol es el despiece y el patrón es
  **la directiva que llega un jueves**: ¿en qué aeronaves estuvo instalada alguna vez una
  pieza de este lote, y qué se desmontó junto con ella?
- Si al ejecutar resulta que la apuesta se gana, **sospecha de la medición antes que del
  instinto** y dímelo: probablemente el `WITH RECURSIVE` está mal escrito o le falta el
  índice.
- El grafo que no cabe en memoria; el coste operativo de mantener un motor más por una
  consulta al mes.
- 💥 La consulta sin límite de profundidad sobre un grafo con ciclos.
- ⚖️ El veredicto más honesto del curso: **uno o dos saltos no justifican un grafo**, y
  meter Neo4j para bajar cuatro niveles de un árbol de categorías es el anti-patrón que
  este mismo curso declara.

## Audiencia

Senior relacional, y aquí tiene razón más veces de las que el marketing admite. Trátalo
como tal: la fase gana credibilidad **perdiendo** la apuesta, no ganándola.

## Cómo quiero que trabajes

{{protocolo}} Esta es la fase donde el aparato de honestidad del curso se pone a prueba.
Si sale tibia, no sirve.
```

---

## # Fases 15 y 16 — Vectorial (Qdrant)

```markdown
Este es el chat de la **Fase {{15|16}}**, minicurso **vectorial** con Qdrant. Entregable:
`{{15-vectorial-levantar-y-modelar.md | 16-vectorial-romper-y-medir.md}}`.

## Identidad

- Bloque III · **10 h** · Motor: Qdrant · Línea base: `pgvector`
- Entorno: **Python** para embeddings, TypeScript para el arnés
- Ejercicios: **{{24|26}}** · La 16 cierra bloque: lleva el 💀 **boss del Bloque III**.
- Conecta con `tutorial-rag/` del repositorio; enlázalo, no lo reexpliques.

## Alcance — Fase 15

- "Esto ya lo vimos" sobre los reportes de piloto —veintiséis mil, tres líneas con prisa,
  jerga y faltas: "ruido metálico al bajar tren" tiene que encontrar "golpeteo al
  extender"—;
  qué es un embedding y qué no, **sin entrenar nada**; distancia coseno contra producto
  interno; HNSW y sus dos parámetros que importan; filtrado con metadatos, que es donde
  esta familia se vuelve útil de verdad.
- 🪞 "Esto es buscar con `LIKE` pero mejor". No: **es la primera familia del curso que no
  devuelve la respuesta correcta, devuelve las parecidas**, y eso cambia cómo se evalúa el
  resultado.
- ⚰️ Vectorial usado para búsqueda exacta, donde un índice de toda la vida gana por goleada
  y encima acierta.

## Alcance — Fase 16

- 🧰 Al cerrar los objetivos, anuncia el miniproyecto: `h-mini-07-vectorial-cumbre-roja.md`.
- 🪞 **Apuesta:** "`pgvector` con HNSW aguanta 1 M de vectores con recall comparable y me
  ahorra el motor aparte". Es la familia **más defendible** de las diez —no hay equivalente
  relacional para "parecido"— pero eso no significa que el motor dedicado gane siempre.
- Medición en **recall contra velocidad**, que es la métrica propia de esta familia, con su
  trampa declarada: se puede ser rapidísimo devolviendo basura; el coste de construir el
  índice; la memoria de 1 M de vectores y por qué; y la reindexación completa al cambiar de
  modelo de embeddings.
- 💥 El índice que no cabe en RAM y el recall que se desploma al bajar parámetros.
- ⚖️ Vectorial cuando necesitas parecido y no exactitud. Para palabras clave, la búsqueda
  exacta existe, es más barata y acierta más.
- 💀 **Boss del bloque — "Freddy ya vio esto":** lo pide Hernán Peñaloza. Dado un reporte
  de piloto nuevo, las cinco intervenciones más parecidas **y** las piezas que la
  trazabilidad dice que podrían estar implicadas. Cruza grafo y vectores, con medición que justifique qué hace cada motor.

## Pendientes que pueden bloquear

- El modelo es **`intfloat/multilingual-e5-small`** (alcance §12, 18), con la revisión
  fijada en `a06`. Si `a06` todavía no dejó ejecutada la comprobación de que Python y
  TypeScript producen el mismo vector, **para** (verificado el 29/09/2026 en macOS, §H8).
  Los prefijos `query:`/`passage:` dan una apuesta falsable: *"olvidarlos baja el recall"*.
  En la sesión de laboratorio, con cinco reportes, el orden no cambió, así que se escribe
  antes, se mide sobre el corpus completo y se publica el resultado, gane o pierda.

## Cómo quiero que trabajes

{{protocolo}}
```

---

## # Fases 17 y 18 — Columnar ancha (Cassandra)

```markdown
Este es el chat de la **Fase {{17|18}}**, minicurso de **columnar ancha**. Entregable:
`{{17-columnar-levantar-y-modelar.md | 18-columnar-romper-y-medir.md}}`.

## Identidad

- Bloque IV — Cuando el dato no cabe en un nodo · **10 h**
- Motor: Cassandra, con el heap fijado (alcance §12, 16). ScyllaDB se menciona en el
  veredicto como alternativa y en `a10` por su licencia
- Línea base: Postgres particionado · Entorno: TypeScript · Ejercicios: **28** en ambas
- Es la familia **más difícil del curso** y va aquí porque necesita todo lo anterior.

## Alcance — Fase 17

- Los parámetros de vuelo cuando ya no caben en un nodo —las ciento cuarenta aeronaves,
  escritos y jamás actualizados, consultados por aeronave y por rango de fechas—; **modelar por consulta y no por entidad**,
  que es el cambio de paradigma más grande del curso; partition key contra clustering key y
  qué decide cada una; desnormalizar a propósito y mantener N tablas de lo mismo;
  consistencia ajustable con quórum.
- 🪞 "Primero modelo el dominio y luego escribo las consultas". Aquí es literalmente al
  revés: **cada consulta nueva es una tabla nueva más un backfill.** Eso no es un defecto,
  es el trato — dilo así.
- ⚰️ Cassandra modelada por entidades con `ALLOW FILTERING` puesto para que "funcione":
  funciona con 10 k filas en la laptop y se cae en producción.

## Alcance — Fase 18

- 🧰 Al cerrar los objetivos, anuncia el miniproyecto: `h-mini-08-columnar-nodo-sur.md`.
- 🪞 **Apuesta:** "el particionado declarativo de Postgres cubre este caso hasta el volumen
  al que llega esta empresa, y Cassandra solo empieza a ganar más allá".
- Particiones tocadas por consulta; el **hot spot** por partition key mal elegida,
  provocado a propósito y medido; amplificación de escritura y compactaciones; tombstones y
  por qué borrar es lo más caro que puedes hacer aquí; `ALLOW FILTERING` con su mensaje
  literal y su coste real.
- 💥 La partición que crece sin cota y el nodo que se cae por ella.
- ⚖️ Columnar ancha con escrituras masivas, consultas conocidas de antemano y datos que no
  se actualizan. **Si no conoces tus consultas, esta familia es una trampa cara.**

## Cómo quiero que trabajes

{{protocolo}} Vigila el consumo de RAM: si el motor no levanta cómodamente en las tres
plataformas, dímelo antes de redactar — puede cambiar la elección de producto.
```

---

## # Fases 19 y 20 — Offline-first (CouchDB + PouchDB)

```markdown
Este es el chat de la **Fase {{19|20}}**, minicurso **offline-first**. Entregable:
`{{19-offline-levantar-y-modelar.md | 20-offline-romper-y-medir.md}}`.

## Identidad

- Bloque IV · **10 h** · Motor: CouchDB + PouchDB · Línea base: ninguna honesta — **dilo**
- Entorno: TypeScript · Ejercicios: **24** en ambas

## Alcance — Fase 19

- La app de Freddy Manrique, el técnico itinerante que pasa tres días en pistas del
  Guaviare sin señal; replicación bidireccional; la revisión de
  documento como historia y no como versión; **conflictos: detectarlos, resolverlos y
  decidir quién gana**; qué es un CRDT y cuándo te ahorra escribir la resolución a mano.
- 🪞 "Sincronizo cuando vuelva la conexión y ya". El conflicto no es un caso de error: **es
  el caso normal**, y hay que diseñarlo.
- ⚰️ Resolución por "el último que escribe gana", que en este dominio significa perder
  silenciosamente el trabajo de un técnico que estuvo sin cobertura toda la mañana — o dos
  técnicos que, sin poder verse, escriben cosas incompatibles sobre el mismo componente.

## Alcance — Fase 20

- 🧰 Al cerrar los objetivos, anuncia el miniproyecto: `h-mini-09-offline-cumbre-roja.md`.
- 🪞 **Apuesta:** "tres días desconectado con cien órdenes editadas sincronizan sin
  intervención manual".
- Volumen de sincronización y tamaño del historial de revisiones; el conflicto masivo
  provocado con dos clientes editando lo mismo; la compactación y qué se pierde; el límite
  de tamaño razonable en la tableta del técnico.
- 💥 La sincronización que no converge.
- ⚖️ Offline-first cuando tus usuarios trabajan de verdad sin conexión. Es la familia con
  **el mayor coste de complejidad por unidad de beneficio** de todo el curso, y hay que
  decirlo con esas palabras.

## Cómo quiero que trabajes

{{protocolo}} Aquí no hay línea base relacional honesta; declara esa ausencia en lugar de
fabricar una comparación forzada.
```

---

## # Fases 21 y 22 — NewSQL (CockroachDB)

```markdown
Este es el chat de la **Fase {{21|22}}**, minicurso **NewSQL**. Entregable:
`{{21-newsql-levantar-y-modelar.md | 22-newsql-romper-y-medir.md}}`.

## Identidad

- Bloque IV · **10 h** · Motor: CockroachDB · Línea base: Postgres de un nodo
- Entorno: TypeScript · Ejercicios: **26** en ambas
- La 22 cierra bloque: lleva el 💀 **boss del Bloque IV**.

## Alcance — Fase 21

- El expediente de la aeronave con tres autoridades en tres países —un operador estatal
  cuyos registros no pueden salir de su territorio, y una aeronave que hace rutina en el
  Coca y la inspección mayor en Bogotá—; **la síntesis del curso**:
  SQL y ACID sobre un sistema distribuido y qué cuesta eso exactamente; rangos, réplicas y
  consenso sin misticismo; localidad de datos y por qué la geografía aparece en el esquema;
  y el reloj, que es el problema de fondo de todo esto.
- 🪞 "Si habla SQL y es ACID, es Postgres con más nodos". Lo es, hasta que una transacción
  cruza regiones y la latencia de la luz aparece en tu `COMMIT`.
- ⚰️ NewSQL con el esquema copiado tal cual de Postgres, sin pensar la localidad, y cada
  transacción cruzando una frontera dos veces — incluidos registros que, por contrato, no
  podían salir de su país.

## Alcance — Fase 22

- 🧰 Al cerrar los objetivos, anuncia el miniproyecto: `h-mini-10-newsql-barlovento.md`.
- 🪞 **Apuesta:** "un Postgres de un nodo con réplica de lectura resuelve este caso a una
  fracción del coste y de la latencia". Casi siempre es verdad, **y esa es la lección**. Lo
  que un Postgres de un nodo no puede dar es la residencia de datos por autoridad, y ahí se
  sostiene o se cae el caso de Cóndor.
- Latencia de commit por localidad — **la única excepción declarada del curso donde el
  tiempo sí es el argumento**, porque es física y no hardware: dilo explícitamente;
  contención sobre la misma fila desde dos regiones; el reintento de transacción como parte
  del modelo de programación; coste operativo y económico real.
- 💥 La transacción distribuida con contención alta.
- ⚖️ NewSQL cuando necesitas ACID de verdad sobre varias regiones, o cuando la ley decide
  dónde vive cada fila. Si una región basta,
  Postgres es más simple, más barato y más rápido.
- 💀 **Boss del bloque — "La estación del Coca":** lo pide Lucía Arango antes de firmar con
  un segundo operador estatal. Sin cobertura fiable, parámetros de vuelo que siguen llegando
  y un expediente que se firma en tres países. Diseñar el reparto, provocar las tres
  roturas del bloque y entregar el informe con mediciones y decisiones.

## Cómo quiero que trabajes

{{protocolo}} La simulación de latencia entre regiones tiene que estar ejecutada, no
descrita. Se monta con `cockroach demo --nodes=9 --global` (alcance §12, 19), sin licencia;
la latencia se mide **en el servidor y sentencia por sentencia** con `EXPLAIN ANALYZE`,
nunca con el reloj del cliente sobre un lote (§H10 de la verificación). Si no puedes
montarla, dilo y declara qué no se verificó.
```

---

## # Fases 23, 24 y 25 — El capstone políglota

```markdown
Este es el chat de la **Fase {{23|24|25}}**, del capstone **⚖️ El árbitro**. Entregable:
`{{23-poliglota-el-diseno.md | 24-poliglota-la-costura.md | 25-poliglota-la-factura.md}}`.

## Identidad

- Bloque V · **{{12|14|14}} h** · Ejercicios: **{{22|26|24}}**
- Depende de: **todas las fases anteriores cerradas**. Es el único punto del curso con esa
  dependencia total, y es deliberado.
- Entorno: TypeScript (Python donde ya se usaba)

## Alcance — Fase 23 (el diseño)

- El sistema de Cóndor completo pasado por las cinco preguntas, parte por parte; qué motores
  entran de verdad y cuáles se descartan **con su razón escrita**; dónde está la fuente de
  verdad, que es la decisión que ordena todas las demás; el diagrama del sistema y sus
  fronteras.
- 🧠 **La regla que ordena el bloque:** todo motor que no sea la fuente de verdad tiene que
  ser **reconstruible desde ella**. Si no lo es, no es un índice: es una segunda verdad, y
  tarde o temprano se contradice con la primera.

## Alcance — Fase 24 (la costura)

- Cómo se propaga una escritura de la fuente de verdad a los demás motores: **dual write y
  por qué casi siempre está mal**, contra outbox y CDC; la ventana de inconsistencia,
  **medida**; la reconstrucción completa de un índice y cuánto dura; qué se hace cuando un
  motor secundario está caído.
- 💥 El dual write con fallo parcial, provocado: se mide la divergencia y se cuenta cuánto
  cuesta detectarla.

## Alcance — Fase 25 (la factura y el veredicto)

- El coste operativo real de cinco motores: despliegue, monitoreo, backup, actualizaciones
  y gente que sepa de cada uno.
- El ⚖️ **árbol de veredicto honesto** completo, con las diez familias y sus "cuándo NO".
- Y el cierre que la ruta debe desde la primera página: **cuándo todo esto era innecesario
  y bastaba con Postgres**, dicho con los números propios acumulados durante cinco meses.
- **La señal de que el curso quedó bien:** el lector es capaz de entrar a un design review
  y **descartar motores con argumento**, no de proponerlos todos.
- 💀 **Boss del bloque — "Las dos verdades"** (va en la 25): lo pide Lucía Arango para el
  comité que decide si el sistema de Camilo se retira, y Camilo Duarte defiende su sistema.
  `SIGMA` y el sistema de componentes llegan ya divergidos, con discrepancias sembradas por
  el generador. Encontrarlas y explicar de qué costura sale cada una; decidir la fuente de
  verdad y si el sistema de Camilo se retira o se queda como índice reconstruible; montar
  la costura y medir su ventana de inconsistencia; poner la factura al lado de cada opción.
  Cierra el círculo de la autopsia de F00 con el triaje de F02, y el veredicto puede darle
  la razón a Camilo.
- 🏆 Aquí cierra el boss global "El Hangar", siempre marcado como opcional: quien no lo
  siguió no ha perdido nada del curso.

## Cómo quiero que trabajes

{{protocolo}} En la 25, no dejes que el cierre se vuelva triunfal. El curso termina
diciendo cuándo no hacía falta nada de esto, y esa es su mejor página.
```

---

## 🧾 Recordatorio de cierre del curso

Cuando las 26 fases estén escritas, quedan tres tareas que no son fases y que nadie debe
dar por hechas:

1. **Cerrar `a03`, `a04`, `a08` y `a09`**, que crecieron con el curso.
2. **Consolidar los tres documentos vivos**: la bitácora con su tabla-resumen de apuestas,
   el catálogo con sus cincuenta entradas y `INSTINTOS.md` con los diez 🪞.
3. **Escribir `0-ESTRUCTURA-CURSO.md`** y actualizar el `README.md` con el orden de
   publicación real, que para entonces ya no será una hipótesis.
