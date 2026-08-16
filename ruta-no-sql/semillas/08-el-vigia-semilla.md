# ⏱️ Proyecto El Vigía — Semilla del curso (Series temporales)

## 🎯 Motivación

Hay una clase de dato que llega ordenado por el reloj, casi nunca se corrige, y
se consulta siempre por ventana: "dame el uso de CPU de este host en la última
hora", "el promedio por minuto de estas mil máquinas durante ayer", "la
tendencia de latencia de la semana comparada con la anterior". Es el patrón de
acceso de **series temporales**: escritura casi pura de append, lectura por
rango de tiempo, agregación sobre ventanas, y un envejecimiento predecible del
dato (el detalle de hace un año importa mucho menos que el de hace cinco
minutos). El eje dominante no es una entidad, es el **tiempo**.

Un motor relacional generalista puede resolver esto —tienes `timestamp`,
tienes `BETWEEN`, tienes `date_trunc` y `GROUP BY`— pero no fue *diseñado* para
hacerlo bien a escala. Dos propiedades físicas del dato temporal quedan sin
explotar en una tabla genérica. La primera es que la serie es **particionable
por tiempo de forma natural**: si los datos de marzo viven físicamente juntos y
separados de los de abril, una consulta acotada a abril descarta marzo sin
abrir una sola página. Un heap relacional con un índice B-tree sobre
`timestamp` sabe *encontrar* las filas de abril, pero no evita que estén
entreveradas físicamente con todo lo demás, ni que el índice engorde sin
techo a medida que el volumen crece. La segunda es que la serie es
**extremadamente comprimible** cuando se guarda en el orden correcto: valores
consecutivos en el tiempo suelen parecerse (la temperatura no salta de 20° a
900° entre lecturas), y un almacenamiento columnar que aproveche esa cercanía
comprime a una fracción de lo que ocupa fila-a-fila. El motor por filas paga
disco y memoria por una redundancia que la naturaleza del dato regalaba.

A esto se suma una operación que el relacional obliga a construir a mano y el
motor temporal ofrece de fábrica: **retención escalonada y downsampling**.
Conservar el detalle por segundo de la última semana pero solo promedios
horarios de hace un año no es un lujo, es la única forma de que el sistema no
crezca sin límite. En una base genérica eso es un cron artesanal que alguien
escribe, opera y arregla cuando se rompe a las 3 am. En un motor de series es
una política declarativa de primera clase.

**Qué gana un ingeniero senior de bases relacionales al dominar este modelo.**
Deja de cometer el error de arquitectura más común con datos temporales:
meterlos en una tabla ancha genérica, ponerle un índice al `timestamp`, y
descubrir seis meses después que la tabla tiene tres mil millones de filas, el
índice no cabe en RAM, `VACUUM` no termina, y nadie diseñó la retención. Con
este modelo en el criterio, ese ingeniero puede abordar proyectos que antes
esquivaba: monitoreo de infraestructura y observabilidad, telemetría de IoT
industrial, datos de mercado financiero, métricas de producto a alta cadencia.
Y —esto es lo fino— aprende a distinguir cuándo el dato *parece* temporal pero
no lo es (una tabla de pedidos con `created_at` no es una serie temporal: se
actualiza, se une, se consulta por cliente y no por ventana), evitando el error
inverso de montar un motor especializado donde el relacional bastaba de sobra.
La herramienta correcta entra al criterio con su frontera bien marcada, no como
bala de plata.

---

## 🏗️ El dominio: monitoreo de métricas de infraestructura

El Vigía es un sistema de **monitoreo de métricas de infraestructura**: recibe
un flujo continuo de mediciones desde una flota de hosts (uso de CPU, memoria,
disco, latencia de red, contadores de request), las almacena por tiempo, y
responde consultas de tablero —series recientes a resolución completa,
tendencias históricas agregadas, comparaciones ventana-contra-ventana— con una
política de **retención escalonada** y **downsampling automático** que mantiene
el costo de almacenamiento acotado sin perder utilidad analítica.

El dominio se eligió porque **exhibe el patrón de acceso de series temporales
sin forzarlo**. No hay que inventar un caso de uso: el monitoreo *es* el caso
canónico. Cada propiedad del modelo aparece de forma natural, no como ejercicio
de laboratorio.

### La forma del dato

Cada medición es una tupla mínima y repetitiva: un instante, una identidad de
serie (qué host, qué métrica, qué etiquetas), y uno o más valores numéricos.

| Elemento | Ejemplo | Rol en el modelo |
|---|---|---|
| `timestamp` | `2026-08-16T14:03:11.482Z` | el eje — partición y orden físico |
| `metric` | `cpu.usage.percent` | qué se mide |
| tags (`host`, `region`, `env`) | `host=web-01, region=us-east` | identidad de la serie; cardinalidad a vigilar |
| `value` (fields) | `73.4` | la medición; comprimible por cercanía temporal |

La **cardinalidad de series** (el producto de todas las combinaciones de tags)
es la métrica de diseño que reemplaza mentalmente al "número de filas" del
mundo relacional. Un tag mal elegido —un `request_id` único por evento como
tag— hace explotar la cardinalidad y hunde cualquier motor temporal. Es la
trampa que el curso enseña a oler temprano.

### Los tres regímenes de consulta

El dominio tiene exactamente los patrones de lectura que el modelo optimiza:

- **Reciente a resolución completa** — "CPU de `web-01` en los últimos 15
  minutos, punto a punto". Toca poca ventana, mucho detalle.
- **Histórico agregado** — "promedio por hora de CPU de toda la región `us-east`
  el último trimestre". Toca mucha ventana, poco detalle, se sirve de roll-ups
  pre-agregados, no de datos crudos.
- **Ventana contra ventana** — "latencia de esta semana vs. la anterior".
  Comparación temporal, el pan de cada día de un tablero de observabilidad.

### El marco de 5 preguntas, aplicado ANTES de modelar

| Pregunta | Veredicto para El Vigía |
|---|---|
| ¿Qué se lee junto? | rangos de tiempo de una misma serie (o de series agrupadas por tag); nunca "una fila por su id" |
| ¿Quién custodia la forma / las invariantes? | la forma es fija y pobre (ts + tags + values); la invariante real es *append-only* y *orden temporal*, no integridad referencial |
| ¿Cuánto se une en caliente? | casi nada; a lo sumo se agrupa por tag. No hay JOINs de negocio en el camino caliente |
| ¿Dónde viven las invariantes? | en el eje temporal: monotonía de escritura, inmutabilidad del histórico, política de retención |
| ¿Qué pide la operación? | escritura masiva sostenida (append), lectura por rango, agregación por ventana, compresión agresiva, retención automática |

**Veredicto: vota series temporales 5-0.** Es uno de los dominios más limpios de
toda la ruta: no hay tensión, no hay "depende". El dato nace ordenado por
tiempo, no se corrige, se lee por ventana y crece sin techo si nadie lo poda.
Cada una de esas cinco propiedades es exactamente lo que un motor temporal
codifica en su estructura física. El matiz honesto —que sí lo hay— no está en
*si* el modelo temporal gana, sino en *qué motor* temporal, y en dónde termina
la ventaja frente a un PostgreSQL bien extendido: eso es lo que el "vs" del
curso mide sin piedad.

### El villano del curso

El anti-patrón que El Vigía disecciona con autopsia medida es **guardar series
temporales en una tabla genérica sin partición temporal ni compresión
especializada**: la tabla `metrics(id, timestamp, metric, host, value)` con un
índice B-tree en `timestamp`, que "funciona" en la demo con diez mil filas y se
convierte en un pantano a los tres mil millones. Inserciones que se frenan
porque el índice ya no cabe en memoria, `VACUUM` que nunca alcanza, consultas de
rango que escanean de más porque nada está particionado, disco que se llena
porque nadie diseñó retención ni downsampling, y cardinalidad descontrolada
porque se metió un tag único como columna sin pensarlo. Es el crimen del
ingeniero que trató el tiempo como "una columna más".

El curso lo construye de verdad, lo carga hasta que duele, lo mide, y luego lo
migra a un diseño temporal con los números antes/después a la vista. Y —clave
para no caer en el fanboyismo inverso— también nombra el crimen simétrico:
montar InfluxDB o TimescaleDB para una tabla de eventos de negocio que en
realidad se consulta por entidad y se actualiza, donde Postgres a secas era la
respuesta. El villano es "el motor donde no toca", en las dos direcciones.

---

## 📐 Stack (2026, estable y moderno)

Todo el stack es open source de acceso gratuito en desarrollo y **enteramente
contenerizado** (la audiencia ya vive en contenedores). Las versiones reflejan
lo último estable a mediados de 2026; confírmalas en la Fase 0 antes de fijar
`docker-compose`.

| Componente | Versión / elección | Rol |
|---|---|---|
| **InfluxDB 3 Core** | 3.x (Core, open source) | motor de series dedicado principal — el "nativo temporal" del curso |
| **TimescaleDB** | 2.28+ (extensión de PostgreSQL) | rival #1: series temporales *dentro* del mundo relacional |
| **PostgreSQL** | 17 (o 18 si ya estable en tu setup) | base del `vs`: tanto TimescaleDB como el villano "tabla genérica" corren aquí |
| **MongoDB** | 8.x (Community) | rival #2: colecciones **Time Series** nativas del motor documental generalista |
| **Node.js** | 24 LTS | runtime del arnés, generador de datos y API de tablero |
| **TypeScript** | 5.x | tipado en todo el código de instrumentación y `vs.ts` |
| **Docker / Podman** | última | orquestación local de los tres motores + generador |
| **Grafana** (opcional) | última | tablero de visualización sobre los tres motores, para "sentir" el dato |

### Por qué InfluxDB 3 Core como motor principal

InfluxDB es la referencia dedicada de la categoría y la que mejor encarna la
tesis "el tiempo es el eje". La generación 3 (reescrita en Rust, con motor
columnar sobre formato tipo Parquet y almacenamiento orientado a objetos) es lo
estable y moderno en 2026 —no la 1.x/2.x en Go, que son legacy—. El curso usa la
edición **Core** (open source, gratuita, mono-nodo) porque basta de sobra para
enseñar el modelo sin costo ni cuenta cloud. **Nota de verificación:** confirma
en la Fase 0 el lenguaje de consulta vigente de Core (SQL y/o InfluxQL) y sus
límites frente a la edición Enterprise, porque la superficie de features cambió
fuerte entre la 2.x y la 3.x; no des por sentada la API de memoria.

### Por qué TimescaleDB y MongoDB Time Series como rivales

El "vs" de este curso no es "temporal contra relacional genérico" (eso lo
representa el villano). Es un triángulo mucho más honesto e interesante:

- **TimescaleDB** es la respuesta más seria a "no necesitas un motor nuevo,
  extiende el Postgres que ya tienes": hypertables con particionado temporal
  automático (chunks), compresión columnar, agregados continuos (continuous
  aggregates) y políticas de retención, todo hablando SQL puro sobre PostgreSQL.
  Si iguala a InfluxDB en tu caso, adoptar un motor dedicado hay que
  justificarlo con algo más que gusto. Es el rival que puede *ganar* capítulos.
- **Las colecciones Time Series nativas de MongoDB** (maduras desde la 5.0,
  optimizadas de forma continua hasta la 8.x) son la evidencia de que hasta un
  motor documental generalista terminó incorporando soporte de primera clase
  para este patrón. Sirven para dos cosas: medir cuánto acorta la brecha un
  generalista con soporte nativo, y —crucial para las NOTAS_ESPECIALES— tener
  el contraste directo contra el **bucket pattern manual** que ese mismo Mongo
  obligaba a construir a mano *antes* de tener Time Series nativo. El curso
  muestra las dos formas en Mongo y las mide entre sí.

### Por qué TypeScript + Node LTS

El proyecto es instrumentación y API de tablero, no analítica pesada de
dataframes, así que no hay razón para salir de la zona por defecto de la ruta:
**TypeScript sobre Node 24 LTS**. Es multiplataforma (Linux, macOS, Windows vía
WSL2), el ecosistema de drivers de los tres motores es maduro en Node, y el
tipado ayuda a mantener honesto el generador de datos y el arnés `vs.ts`. El
generador de carga a alta cadencia puede necesitar tuning (workers, batching);
si el volumen objetivo lo exige, se documenta como decisión pendiente si
conviene un generador auxiliar en Go/Rust, pero **por defecto todo en TS**.

### Validación y tooling transversal

- **`scripts/vs.ts`** — el arnés de benchmark (§siguiente).
- **Generador de datos** — un módulo TS que produce el **mismo dataset semántico
  de telemetría** en las tres formas (line protocol / SQL para Timescale /
  documentos Time Series de Mongo), con cardinalidad y cadencia parametrizables,
  para que ningún "vs" compare peras con manzanas.
- **`docker-compose.yml`** — los tres motores + Grafana opcional, arranque de un
  comando, datos efímeros por defecto y volúmenes nombrados cuando se quiera
  persistir.

---

## ⚖️ El método del "vs": un arnés, no anécdotas

Desde la Fase 0 se monta `scripts/vs.ts`: un arnés que ejecuta **la misma
consulta semántica** contra los motores en juego, la corre varias veces
(descartando el warm-up), cronometra percentiles (no solo el promedio, que
miente con las colas), registra tamaño en disco tras compresión, y acumula todo
en `BENCHMARKS.md`. Ningún "X es mejor para Y" entra al curso sin pasar antes
por el arnés; los benchmarks de marketing de cualquiera de los tres motores se
rechazan de entrada.

Los duelos que atraviesan el curso, derivados de los rivales:

1. **InfluxDB 3 vs. tabla genérica en Postgres (el villano)** — el contraste
   fundacional: ingesta sostenida, tamaño en disco, consulta de rango. Es donde
   el villano se desangra.
2. **InfluxDB 3 vs. TimescaleDB** — dedicado contra "Postgres extendido". El
   duelo principal y más honesto: ingesta, compresión, agregados continuos vs.
   downsampling nativo, y ergonomía de consulta (SQL puro vs. el lenguaje de
   InfluxDB).
3. **InfluxDB 3 vs. MongoDB Time Series nativo** — dedicado contra generalista
   con soporte de primera clase: cuánto acorta la brecha el generalista.
4. **MongoDB Time Series nativo vs. bucket pattern manual en Mongo** — el "antes
   y después" dentro del mismo motor documental, para que se vea qué compra el
   soporte nativo frente a la artesanía a mano.

---

## 🌳 Estructura de fases

Doce fases (0–11). La Fase 0 monta el laboratorio contenerizado y el generador;
la última es la autopsia del villano y el veredicto honesto. El número cae en el
rango porque el modelo temporal tiene menos "sub-modelos" que uno documental o
de grafo: la riqueza está en compresión, retención y cardinalidad, no en formas
de datos variadas.

| # | Fase | Núcleo | "Vs" de la fase |
|---|---|---|---|
| **0** | 🧪 El laboratorio de tres relojes | Compose con InfluxDB 3 + Postgres/Timescale + Mongo. Generador de telemetría con cadencia y cardinalidad parametrizables. Nace `vs.ts` | — (montaje) |
| **1** | ⚖️ El marco, antes de modelar | Las 5 preguntas aplicadas al monitoreo. Se construye el villano (tabla genérica) y se siente el dolor de ingesta en vivo | tabla genérica: ingesta cruda, sin partición |
| **2** | 🕰️ El tiempo como eje: partición nativa | Hypertables (Timescale) y particionado de InfluxDB. Por qué "descartar rangos sin abrirlos" cambia todo | InfluxDB partición vs. Timescale chunks vs. B-tree del villano |
| **3** | 🗜️ Compresión: el dato temporal regala redundancia | Compresión columnar por cercanía temporal; tamaño en disco medido | InfluxDB vs. Timescale compression vs. tabla sin comprimir |
| **4** | 🏷️ Cardinalidad: la trampa que hunde el modelo | Diseño de tags/dimensiones; el `request_id`-como-tag que explota; medición de series activas | InfluxDB tag cardinality vs. índices de Timescale vs. metaField de Mongo |
| **5** | ⭐ Roll-ups y downsampling automático | Agregados continuos (Timescale) vs. tareas de downsampling de InfluxDB; el histórico agregado se sirve solo | continuous aggregates vs. downsampling nativo |
| **6** | ⏳ Retención escalonada | Políticas de retención por resolución (detalle reciente, promedios viejos); poda automática | políticas de retención de los tres motores, lado a lado |
| **7** | ⭐ El bucket pattern a mano (Mongo) vs. Time Series nativo | Se construye el bucket pattern manual y se mide contra la colección Time Series nativa de Mongo | ⚰️ autopsia parcial: bucket manual vs. nativo — trata NOTAS_ESPECIALES |
| **8** | 📊 Consultas de ventana y comparación temporal | `time_bucket`, funciones de ventana, gap-filling, comparación semana-contra-semana | SQL/Timescale window vs. lenguaje de InfluxDB |
| **9** | 🚰 Ingesta a alta cadencia | Batching, backpressure, el generador a tope; percentiles de latencia de escritura | ingesta sostenida en los tres motores bajo la misma carga |
| **10** | 📺 El tablero: sirviendo las tres consultas | API de tablero (Node/TS) + Grafana; reciente, histórico y ventana-contra-ventana, servidos desde cada motor | latencia de lectura de tablero real |
| **11** | ⚰️ La autopsia del villano y ⚖️ el veredicto | La tabla genérica medida de punta a punta contra los tres motores temporales; y cuándo NO usar un motor temporal (el crimen inverso) | veredicto honesto con árbol de decisión |

### Fase 0 — El laboratorio de tres relojes

Monta los tres motores en contenedores, arranca de un comando, y construye el
generador de telemetría: produce el **mismo dataset semántico** (misma flota,
misma cadencia, misma cardinalidad) en las tres formas de entrada. Nace
`vs.ts`. Se fija la disciplina: nada se afirma sin medir. 🩻 Primer recuadro de
"esto SÍ viaja igual": SQL, `EXPLAIN`, la noción de índice y selectividad, y el
sentido común de "mide antes de optimizar" cruzan intactos desde el mundo
relacional a los tres motores.

### Fase 1 — El marco, antes de modelar

Se aplican las 5 preguntas al monitoreo y se construye el villano a propósito:
una tabla `metrics` genérica en Postgres, se le vuelca el generador, y se siente
en vivo cómo la ingesta se degrada. 🪞 Primer recuadro de instinto SQL: *"mi
instinto dice: le pongo un índice al timestamp y listo"* — y esta vez el índice
es parte del problema, no de la solución, porque engorda sin techo y compite por
la RAM con el propio dato caliente.

### Fase 2 — El tiempo como eje: partición nativa

El concepto central del modelo. Hypertables de Timescale (chunks por intervalo
de tiempo) y el particionado nativo de InfluxDB, contra el heap indexado del
villano. Se mide una consulta de rango acotado: cuánto se ahorra por *no abrir*
las particiones fuera de rango. 🪞 *"mi instinto dice: el índice ya me da el
rango"* — sí, te lo encuentra, pero igual paga por tener todo entreverado.

### Fase 3 — Compresión: el dato temporal regala redundancia

Por qué valores temporalmente cercanos comprimen tanto, y cómo lo explota cada
motor. Se mide tamaño en disco del mismo dataset en los tres, comprimido y sin
comprimir. 🩻 "esto SÍ viaja igual": la intuición de que menos I/O es más
rápido no cambia; lo nuevo es cuánto I/O te ahorra la forma física correcta.

### Fase 4 — Cardinalidad: la trampa que hunde el modelo

La métrica de diseño que reemplaza a "número de filas". Diseño de tags, el
antipatrón del tag de altísima cardinalidad, y cómo cada motor sufre distinto:
InfluxDB (histórico) sensible a cardinalidad de series, Timescale más elástico
pero no gratis, `metaField` de Mongo. 🪞 *"mi instinto dice: agrego el
`request_id` como dimensión, así lo puedo filtrar"* — y acabas de multiplicar la
cardinalidad por el número de requests.

### Fase 5 — Roll-ups y downsampling automático

Cómo se sirve el histórico agregado sin recorrer datos crudos. Agregados
continuos de Timescale (materializados e incrementales) frente a las tareas de
downsampling de InfluxDB. Se mide una consulta de "promedio por hora del último
trimestre" con y sin roll-up. ⭐ Fase central del valor operativo del modelo.

### Fase 6 — Retención escalonada

Conservar detalle fino reciente y solo agregados del histórico viejo, como
política declarativa. Poda automática vs. el cron artesanal del villano. Se mide
el crecimiento de disco con y sin política a lo largo del tiempo simulado.

### Fase 7 — El bucket pattern a mano vs. Time Series nativo (Mongo)

Aquí caen las **NOTAS_ESPECIALES**. Se construye el bucket pattern manual en
Mongo (agrupar N mediciones por documento-cubo para no explotar en documentos
minúsculos) y se mide contra la colección Time Series nativa, que hace ese
bucketing por dentro y transparente. ⚰️ Autopsia parcial: qué compra el soporte
nativo (compresión de columnas internas, `metaField`, optimizaciones de
inserción) frente a la artesanía. ⭐ Fase que ancla la comparación
documental-generalista contra dedicado.

### Fase 8 — Consultas de ventana y comparación temporal

`time_bucket`, funciones de ventana, relleno de huecos (gap-filling), y la
comparación semana-contra-semana que todo tablero pide. 📖 Aquí vive el grueso
del diccionario de traducción SQL → cada motor: cómo se dice "agrupa por hora y
rellena los huecos" en SQL/Timescale y en el lenguaje de InfluxDB.

### Fase 9 — Ingesta a alta cadencia

El régimen de escritura real: batching, backpressure, el generador a tope. Se
miden **percentiles** de latencia de escritura (p50/p95/p99), no promedios, en
los tres motores bajo idéntica carga. 🩻 "esto SÍ viaja igual": el concepto de
throughput vs. latencia y por qué las colas mienten es el mismo que ya conoces.

### Fase 10 — El tablero: sirviendo las tres consultas

Se cierra el proyecto: API de tablero en Node/TS que sirve las tres consultas
canónicas (reciente, histórico, ventana-contra-ventana), con Grafana opcional
por encima. Se mide latencia de lectura de tablero real contra cada motor.

### Fase 11 — La autopsia del villano y el veredicto

⚰️ La tabla genérica medida de punta a punta contra los tres motores temporales,
con la tabla de números antes/después completa. ⚖️ Veredicto honesto y árbol de
decisión: cuándo un motor temporal gana sin discusión, cuándo TimescaleDB le
gana a InfluxDB (o al revés), cuándo MongoDB Time Series basta, y —el crimen
inverso— **cuándo NO usar ninguno**: dato que parece temporal pero se actualiza,
se une por entidad y se consulta fuera del eje del tiempo; ahí Postgres a secas
gana y montar un motor temporal es el villano en su otra cara.

### Apéndices

- **A) Arranque de los tres motores vía contenedores** — imágenes, puertos,
  healthchecks, y la trampa de los volúmenes efímeros vs. persistentes.
- **B) `docker-compose.yml` / `Containerfile` de trabajo** — el archivo real del
  laboratorio, comentado en español.
- **C) Guía rápida de lenguajes de consulta** — tabla lado a lado: SQL de
  Timescale, el lenguaje de consulta de InfluxDB 3 (verificar cuál en Fase 0), y
  la aggregation de Mongo sobre Time Series.
- **D) El generador de datos** — diseño del generador de telemetría, parámetros
  de cadencia y cardinalidad, y cómo garantiza el "mismo dataset semántico".
- **E) Troubleshooting de setup** — errores típicos: puertos ocupados,
  cardinalidad que tumba el contenedor, relojes de contenedor desincronizados,
  drivers incompatibles con la versión del motor.

---

## 📓 Artefactos acumulativos

**`INSTINTOS.md`** — el cuaderno de instintos SQL puestos a prueba. Cada entrada
sigue el ritual 🪞: se escribe la **predicción** del ingeniero relacional
("meterle un índice al timestamp resuelve el rango"), se **cronometra** contra
la realidad medida, y se escribe el **veredicto** (confirmado / recalibrado /
refutado). Crece fase a fase: la Fase 1 aporta el instinto del índice, la 2 el
de la partición, la 4 el de la cardinalidad ("un tag más no cuesta nada"), la 5
el del downsampling ("ya lo hago con un GROUP BY nocturno"). Al final del curso
es un mapa honesto de qué instintos relacionales sobreviven al mundo temporal y
cuáles hay que desaprender.

**`BENCHMARKS.md`** — el contrapeso medido. Todo "vs" que aparece en cualquier
fase deja aquí su registro: consulta semántica, motores comparados, dataset
(cardinalidad y cadencia), número de corridas, percentiles de latencia, tamaño
en disco tras compresión, y una línea de interpretación. Se alimenta solo desde
`vs.ts` —nunca a mano, nunca "de memoria"—. Crece capítulo a capítulo hasta ser,
al cierre, la evidencia completa que sostiene el veredicto de la Fase 11.

---

## 📚 Referencias por fase (semilla)

> ⚠️ **Todas las URLs, títulos e IDs de video de abajo deben verificarse antes
> de citarlos en una fase.** No se inventan números de página, DOIs ni IDs de
> video. La generación 3 de InfluxDB movió mucha documentación respecto de la
> 2.x: confirma que cada enlace apunta a la versión del stack fijada en la Fase 0.

**Documentación oficial (verificar versión al citar)**
- InfluxDB 3 Core — docs: `https://docs.influxdata.com/` (navegar a la sección de InfluxDB 3 Core; verificar).
- TimescaleDB / Tiger Data — docs: `https://docs.tigerdata.com/` (verificar; el dominio de docs migró de `docs.timescale.com`).
- PostgreSQL 17/18 — manual: `https://www.postgresql.org/docs/` (elegir la versión fijada).
- MongoDB Time Series — manual: `https://www.mongodb.com/docs/manual/core/timeseries-collections/` (verificar contra la versión 8.x fijada).
- Node.js 24 LTS — docs: `https://nodejs.org/docs/latest-v24.x/api/` (verificar que 24 siga siendo el LTS activo).

**Orden de lectura sugerido por bloque de fases**
- Fases 0–1 (montaje y marco): primero el "getting started" de InfluxDB 3 Core, luego el de hypertables de TimescaleDB, luego el core-concept de colecciones Time Series de Mongo. Así se ve la misma idea contada por tres motores antes de medir.
- Fases 2–4 (eje, compresión, cardinalidad): la doc de particionado/chunks de Timescale y la de almacenamiento de InfluxDB 3; para cardinalidad, la guía de "schema design / tag cardinality" de InfluxDB.
- Fases 5–6 (roll-ups y retención): continuous aggregates y retention policies de Timescale; downsampling y retention de InfluxDB.
- Fase 7 (Mongo): primero la doc del bucket pattern (histórica) y luego la de Time Series nativo, en ese orden, para sentir el "antes y después".
- Fases 8–11: funciones de ventana de PostgreSQL, `time_bucket`/gap-filling de Timescale, y el lenguaje de consulta de InfluxDB 3.

**Libros y video (verificar existencia y edición antes de citar)**
- Buscar un libro reciente y vigente sobre bases de datos de series temporales o sobre TimescaleDB/InfluxDB de generación actual; **no citar de memoria** ediciones ni autores.
- Buscar screencasts oficiales de InfluxData y de Tiger Data (TimescaleDB) para el montaje contenerizado; verificar que correspondan a la generación de motor fijada, no a la 1.x/2.x.

---

## 🧪 Nota sobre ejercicios

Cada fase lleva entre **20 y 40 ejercicios** graduados 🟢🟡🟠🔴, todos anclados
al dominio del monitoreo (hosts, métricas, tags, ventanas, retención), no a
ejemplos abstractos. Distribución sugerida para ~30 ejercicios: ~8 🟢 (calientan:
escribir una consulta de rango, crear una hypertable, insertar con line
protocol), ~9 🟡 (intermedios: diseñar tags sin explotar cardinalidad, montar un
continuous aggregate), ~7 🟠 (difíciles: comparar compresión medida entre dos
motores, diseñar una política de retención escalonada correcta), ~5 🔴 (muy
difíciles: integrar varias fases, cerrar un caso de cardinalidad descontrolada,
optimizar ingesta a percentil objetivo). Al menos un puñado por fase son de
**diagnóstico**: se entrega un motor mal configurado (índice que engorda,
cardinalidad explotada, retención que borra lo que no debía, downsampling que
promedia mal) y se pide **reproducir y localizar** con `EXPLAIN`/profiler antes
de arreglar. Los 🔥 opcionales (comparar contra un cuarto motor, meter Grafana,
simular una flota de 10k hosts) van aparte, sin numeración continua.

---

## 🧩 Decisiones pendientes de confirmar antes de redactar la Fase 0

- [ ] **Versión exacta de InfluxDB 3 Core** y su lenguaje de consulta vigente
      (SQL, InfluxQL, o ambos) — verificar en web en Fase 0; es el punto de mayor
      riesgo de desactualización del stack.
- [ ] **PostgreSQL 17 o 18** como base de TimescaleDB — confirmar que la versión
      de Timescale fijada soporta la de Postgres elegida (evitar los minor con el
      breaking binario mencionado por Tiger Data).
- [ ] **Dataset semilla**: telemetría 100% sintética generada por el módulo TS
      (propuesta por defecto, da control total de cadencia y cardinalidad) vs.
      adaptar un dataset público real de métricas. *Propuesta: sintético,
      parametrizable; queda pendiente confirmar.*
- [ ] **¿Los tres motores desde la Fase 0, o Mongo Time Series entra más tarde?**
      *Propuesta: los tres desde Fase 0 (el "vs" se construye en paralelo), pero
      Mongo puede quedar "montado y dormido" hasta la Fase 7 si complica el
      compose inicial.*
- [ ] **Grafana: parte del stack base o apéndice opcional.** *Propuesta:
      opcional, para no acoplar el aprendizaje del modelo a una herramienta de
      viz concreta.*
- [ ] **Cardinalidad y cadencia objetivo del generador** (¿10k series? ¿100k?
      ¿1/seg? ¿10/seg?) — define cuánto "duele" el villano; fijar un número que
      corra en un portátil de desarrollo sin swappear.
- [ ] **Formato de fase**: mantener la plantilla de 9 secciones del esqueleto de
      la ruta, o ajustarla por ser un modelo con menos sub-formas de dato.
      *Propuesta: mantener las 9 secciones.*
- [ ] **¿El generador a alta cadencia se queda en TS o necesita un auxiliar en
      Go/Rust** si el volumen objetivo no se alcanza desde Node? *Propuesta:
      empezar en TS con workers/batching; decidir con la medición real.*

---

## 💭 Consideraciones adicionales

### El bucket pattern manual como bisagra pedagógica (NOTAS_ESPECIALES)

El contraste explícito contra el **bucket pattern** es una de las lecciones más
transferibles del curso, y por eso tiene fase propia (7). El bucket pattern es
lo que un motor documental *sin* soporte nativo de series obliga a construir a
mano: en vez de un documento por medición (que explota en millones de
documentos minúsculos con overhead brutal de `_id` e índices), se agrupan N
mediciones consecutivas en un documento-cubo. Funciona, pero el ingeniero paga
en complejidad de escritura (append dentro del cubo, rotación de cubos), de
lectura (desanidar el cubo) y de índices. La colección Time Series nativa de
Mongo hace exactamente ese bucketing por dentro, transparente y con compresión
de columnas internas. Mostrar las dos formas y **medirlas** enseña algo que
trasciende Mongo: casi todo motor temporal "nativo" está, por dentro, haciendo
una versión sofisticada del bucketing —y entender el patrón a mano es entender
qué te regala el soporte nativo. Es también el puente honesto para decir "si tu
generalista ya tiene Time Series nativo, el bucket manual es deuda técnica que
no hace falta pagar".

### Costo operativo del modelo

Cada motor temporal es una superficie operativa propia. InfluxDB 3 Core suma un
motor más que respaldar, monitorear y del que hacer guardia; su modelo de
almacenamiento orientado a objetos y su generación reciente implican curva de
aprendizaje real. TimescaleDB tiene la ventaja operativa enorme de ser "el
Postgres que ya sabes operar" con una extensión —mismos backups, mismas
herramientas, mismo `psql`—, y ese ahorro operativo es un argumento de peso que
el curso pesa explícitamente, no solo el rendimiento crudo. MongoDB Time Series
no añade motor si ya tienes Mongo. El veredicto de la Fase 11 debe ponderar
*costo de operar*, no solo *velocidad de consultar*: a veces el motor un 20% más
lento gana porque no agrega una guardia nueva a las 3 am.

### Límites de la analogía con SQL

El instinto relacional acierta más de lo que uno esperaría en este modelo —SQL,
índices, selectividad, `EXPLAIN` viajan casi intactos, sobre todo con
TimescaleDB, que *es* SQL—. Donde el instinto se rompe es en tres puntos que el
curso machaca: (1) la **cardinalidad** reemplaza al "número de filas" como
métrica de diseño y se comporta distinto; (2) la **inmutabilidad del histórico**
cambia el modelo mental —no hay `UPDATE` de negocio, hay append y downsampling—;
y (3) la **retención es diseño, no mantenimiento** —se decide el día 0, no
cuando el disco se llena—. Nombrar estos tres límites temprano evita que el
lector arrastre hábitos que en este modelo son bugs.

### Validación contra mercado real (PRODUCTIZABLE: ⚠️ débil como SaaS horizontal)

El monitoreo de infraestructura genérico es un mercado **saturado y difícil**:
compites contra Grafana, Datadog, Prometheus, la propia InfluxData. Por eso la
productización de El Vigía es honestamente **débil como SaaS horizontal** —y el
curso lo dice sin adornos—. Donde el modelo *sí* produce valor de negocio
defendible es en un **vertical nicho**: telemetría de un tipo específico de
maquinaria industrial, métricas de un dominio regulado con requisitos de
retención propios, observabilidad de un stack particular donde las herramientas
horizontales no encajan. La lección productizable no es "hazte un Datadog", sino
"el modelo temporal es un *componente* casi siempre correcto dentro de un
producto más grande, y saber elegir e integrar el motor bien es lo que se
monetiza, no el motor en sí". El curso valida contra ese marco: el entregable no
es un producto, es el **criterio** para meter series temporales donde toca —y no
meterlas donde no— dentro de un sistema real.
