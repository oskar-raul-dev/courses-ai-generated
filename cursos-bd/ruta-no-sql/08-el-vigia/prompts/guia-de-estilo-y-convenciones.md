# ✍️ Guía de estilo, tono y convenciones
## El Vigía — el modelo de series temporales a fondo

> **Qué es este documento:** la fuente de verdad editorial del curso: **cómo** se escribe. Cualquier sesión que
> produzca un `.md` de El Vigía la sigue, para que todas las fases se lean como escritas por la misma mano y
> apunten al mismo sitio: **que el lector decida qué es una serie, con qué etiquetas, a qué resolución y por
> cuánto tiempo, cómo se agrega sin mentir, y lo defienda con números propios.**
> **Vigencia:** 2026-10-07. **Cerrada salvo lo que depende de la propuesta de fases**: la plantilla rígida de
> fase (§6.2) y las longitudes (§9), que se fijan con ella (§15).
> **Herencia:** se escribió con la guía de Ruta NoSQL Lite y las de los cursos anteriores de la ruta como
> modelo, porque es la misma ruta y el lector viene de lite. Diverge de lite en: un solo dominio y una sola
> familia, una sola plantilla de fase, Mermaid, tiempos permitidos con dispersión, la profundidad full geek y
> **lo guardado contra lo emitido, y lo agregado contra lo exacto, como primeras medidas**. La guía de agosto
> (`_desechable-guia-de-estilo-v1.md`) queda de consulta.
> **Precedencia.** Por encima solo está [`alcance-del-proyecto.md`](alcance-del-proyecto.md). Por debajo van el
> contrato de nombres, el diccionario, las propuestas, las plantillas y los prompts. El `CLAUDE.md` del
> repositorio aplica en todo lo que este curso no haya declarado como excepción (§13).

Si dudas entre dos formas de escribir algo, gana la que le sirva más a alguien que el lunes tiene que defender
ante un cliente el percentil de su mes, y ante su guardia por qué la alerta ya no se cae.

---

## 1. 🧭 Principio rector

**Todo lo que se escribe apunta a que alguien decida con criterio qué guarda como serie, cómo la agrega y dónde,
y lo pueda defender con números propios, incluido lo que hace cada motor por dentro.**

No enseñamos InfluxDB ni Prometheus como productos ni formamos ingenieros de observabilidad. Formamos la
capacidad de mirar una métrica, contar sus series antes de crearla, elegir su resolución y su vida, agregarla con
un error conocido, consultarla sin trampas, y saber cuándo un dato con fecha no es una serie.

El filtro para cada párrafo: **¿esto ayuda a modelar, a medir, a diagnosticar o a decidir?** Si no, sobra.

> 🧠 **Primero cuántas series, después qué motor.** En este modelo el veredicto depende de la cardinalidad, de la
> cadencia y de la ventana consultada. Por eso un número nunca se publica sin las series activas, los puntos por
> segundo y la ventana al lado, y un agregado nunca se publica sin su error contra el valor exacto.

### 1.1 Qué NO es este curso

No es un curso de PromQL ni de InfluxDB desde cero, ni de observabilidad como disciplina, ni de facturación
electrónica. No repite Ruta NoSQL Lite: lo que lite enseñó de series temporales se **usa** sin volver a explicarlo.

### 1.2 Requisitos y autocontención

Lo publicado nombra Ruta NoSQL Lite **solo como requisito de entrada**, en el README y en la primera fase. **No
usa su contenido**: no remite a sus fases, no reutiliza sus ejemplos, sus datos ni sus mediciones; si el curso
necesita algo que lite enseñó, lo da por sabido o lo dice con sus propias palabras y con Timbra (D-03). Ningún
documento publicado cita otros cursos de la ruta ni el `CLAUDE.md` del repositorio.

---

## 2. 🎤 Tono

**Semiformal, cálido y directo**, con humor cuando cae bien: un colega que estuvo de guardia el cierre de marzo y
te lo cuenta con paciencia.

- **Tuteo latinoamericano, siempre.** *"Agrega el cliente como etiqueta a la latencia del proveedor y mira la
  memoria de Prometheus durante diez minutos"*. Nada de voseo, nada de "usted", nada de impersonal permanente.
- **Semiformal.** Frases completas, cero abreviaturas de mensajería.
- **Humor seco y con moderación.** Máximo un chiste por sección; el blanco es la situación (el "¡ándale!" de Iván
  cuando por fin carga el tablero), nunca una persona.
- **Cálido sin condescendencia.** El lector es senior y ya hizo lite.
- **Honesto sobre lo feo.** Si TimescaleDB empata, si un boceto se equivoca más de lo que el contrato tolera, si
  PostgreSQL alcanzaba, se dice con esas palabras y con el número delante.

### 2.1 El tono de las autopsias

⚰️ Una autopsia se escribe sobre una **decisión**, jamás sobre una persona. La tabla la hizo Diego, con aval de
Paola y con un buen argumento —el reporte de SLA es un `GROUP BY`—, y sin ella Timbra no habría firmado un
contrato con nivel de servicio. Si un párrafo suena a *"quien escribió una fila por petición no sabía"*, el curso
pierde a su mejor personaje y al lector que hizo algo parecido.

Se escribe en este orden: la decisión con su mejor argumento; por qué era razonable entonces; qué pasó después,
con número; cuánto cuesta salir, con número; qué pregunta, hecha a tiempo, habría cambiado el resultado. Lo que
nunca aparece: "obviamente", "cualquiera habría visto", "error de novato".

---

## 3. 🗣️ Idioma y forma de la narrativa

- **Español latinoamericano neutro** para todo lo que no sea código o salida de terminal.
- **Los términos del oficio se quedan en inglés** cuando son el nombre real de la cosa: *line protocol*, *tag*,
  *field*, *series*, *cardinality*, *head block*, *WAL*, *chunk*, *hypertable*, *columnstore*, *Parquet*,
  *delta-of-delta*, *Gorilla*, *continuous aggregate*, *downsampling*, *native histogram*, *sketch*, *t-digest*,
  *counter*, *gauge*, *`rate()`*, *recording rule*, *exemplar*, *remote write*, *scrape*, *out-of-order*,
  *gap filling*, *LOCF*. Los que tienen traducción asentada —serie, etiqueta, campo, cardinalidad, compresión,
  retención, resolución, cubeta, ventana, percentil, histograma, contador— se alternan con naturalidad. **No se
  inventa vocabulario.**
- **"Métrica"** es lo que se mide; **"serie"** es cada combinación de métrica y etiquetas; nunca se usan como
  sinónimos.
- **Markdown siempre**, sin HTML embebido. **Prosa antes que listas.** Una frase aislada por sección, dos si es
  larga.
- **Tablas solo para lo tabular y corto**: comparación de motores, resultados por cardinalidad o por ventana, la
  traducción SQL ↔ PromQL.
- **Diagramas en Mermaid** (D-12): el camino de un punto hasta el disco, las resoluciones por edad, la ventana
  contra ventana. Árboles de archivos y salidas en `text`.
- **Salida de terminal literal**, en `text` o `json`, sin recortar la parte incómoda (sobre todo la memoria de
  Prometheus subiendo, la consulta que no termina y el punto rechazado por llegar tarde).
- **Encabezados con emoji, con moderación.**

---

## 4. 🎓 Pedagogía: cómo se explica

El público es senior, relacional de oficio y ya pasó por lite: **no explicar lo que ya sabe, y no dejar ambiguo
nada de lo que no.**

### 4.1 La regla del andamio

1. **El problema primero**, siempre en Timbra: *"La latencia del proveedor tiene tres etiquetas: servicio, país y
   resultado. Ahora le agregas el cliente. ¿Cuántas series nuevas son? ¿Cuánta memoria va a pedir Prometheus?
   Apúntalo antes de ejecutar."*
2. **El mecanismo después**: el nombre y la definición mínima.
3. **La consulta que corre**, con su salida real y la línea que importa señalada.

### 4.2 Del instinto se parte, no se reniega

- 🩻 **"Esto sí funciona igual"** — lo que se transfiere sin cambios del relacional: el índice se paga al escribir,
  la partición que no se lee no cuesta, el plan se lee, agregar antes de leer es más barato que leer y agregar.
- 🪞 **"Tu instinto dice… y esta vez se equivoca"** — el relacional (*"el promedio de los percentiles por hora es
  el percentil del mes"*), el de la conferencia (*"este motor no tiene límite de cardinalidad"*) o el que lite dejó
  demasiado firme (*"con un roll-up continuo ya tengo el mes"*). **Una por fase como mínimo.**
- ⚖️ **"Y aquí el instinto SQL tenía razón"** — las preguntas donde el veredicto va en la otra dirección: la tabla
  de facturas, el reporte que se audita, la consulta que cruza con clientes. Sin este recuadro el curso sonaría a
  folleto.

### 4.3 Nada de cajas negras prematuras

Primero `curl` contra cada motor, `psql` y la consulta a pelo; después el cliente y el tablero. Primero el
`EXPLAIN` y el estado interno del motor (las series de la cabeza de Prometheus, los archivos de InfluxDB 3, los
fragmentos de TimescaleDB); después el panel que los dibuja.

### 4.4 Analogías, con fecha de caducidad

Una vez, para abrir la puerta, y se abandonan diciendo dónde se rompen. La más peligrosa del curso: **"una etiqueta
es una columna con índice"**. Se desmonta en el mismo párrafo: cada valor distinto de una etiqueta crea series
nuevas, y cada serie cuesta memoria y estructura aunque nunca se consulte.

### 4.5 Explica el porqué

Cada decisión lleva su porqué: por qué esta etiqueta y no ese campo, por qué esta resolución, por qué este boceto,
por qué este motor para esta ventana.

### 4.6 Densidad calibrada

Un concepto nuevo por vez. Ninguna sección teórica supera las dos pantallas sin una consulta, una medición o un
diagrama. Reaparecen con otras palabras: la pregunta del curso, "¿cuántas series?", "lo agregado contra lo
exacto" y "no todo lo que tiene fecha es una serie".

### 4.7 Cierra los bucles

Todo paréntesis abierto —*"esto lo pagamos en el bloque de los motores"*, *"deuda 💸"*— se cierra.

---

## 5. 💻 Código, comandos y archivos

> **Regla normativa:** todo lo que se ejecuta o se versiona va en inglés —archivos, rutas, variables,
> identificadores, métricas, etiquetas, tablas— y **todos los comentarios van en español con tildes**. Lo que ve un
> cliente en su reporte o la guardia en una alerta va en español.

- **Código ejecutable y mínimo**, que corre de punta a punta con las versiones fijadas.
- **Comentarios que explican el porqué**: `// el cliente va como campo: como etiqueta serían 48.000 series por
  servicio` sí; `// escribe punto` no.
- **Bloques con su lenguaje declarado**: `ts`, `sql`, `promql`, `json`, `bash`, `yaml`, `text`.
- **Un bloque, una idea.** **Nunca `foo`, `bar`, `metric1` ni `test1`**: todo usa Timbra.
- **Consultas siempre con parámetros** donde el motor los admite; nunca concatenando lo que llega de un cliente.

### 5.1 Versiones fijadas

**Digest para las imágenes y archivo de bloqueo para las librerías**, con la versión legible en un comentario.
**Ninguna versión se escribe de memoria**, y hasta la verificación previa ningún documento publica un número de
versión (§15). **Lo no verificado se dice con esas palabras**: si una imagen no corre nativa en arm64 y se midió
emulada, la medición lo dice; si una función no existe en la edición Core o es de licencia distinta, se dice cuál.

### 5.2 Los nombres del dominio

Fijos en todo el curso y en inglés. Hasta que exista el contrato de nombres, estos son los vigentes (convenciones de
nombre de Prometheus para las métricas):

| En la narrativa | Métrica o tabla de series | Etiquetas | En PostgreSQL |
|---|---|---|---|
| duración de una petición | `api_request_duration_seconds` (histograma) | `service`, `country`, `outcome` | `request_metrics.duration_ms` (villano) |
| peticiones | `api_requests_total` (contador) | `service`, `country`, `outcome` | — |
| latencia del proveedor | `stamping_provider_latency_seconds` | `country`, `provider` | — |
| cola de timbrado | `stamping_queue_depth` (medidor) | `country` | — |
| infraestructura | `node_cpu_seconds_total` y afines | `node`, `service` | — |
| SLA por cliente | `sla_request_duration` (agregado por cliente y hora) | cliente como campo o tabla aparte, según la fase | `sla_reports` |
| cliente, documento | — | — | `customers`, `invoices` |

**Métricas en `snake_case` con su unidad y el sufijo `_total` en los contadores; tablas en `snake_case` y plural.**
El identificador de cliente es `customer_id` en todos los mundos. Una fase no renombra una métrica ni una tabla: si
necesita una nueva, la declara y se agrega aquí y en la historia.

### 5.3 El villano también va en inglés

El código del villano se nombra como estaba en Timbra: la tabla `request_metrics`, el middleware
`recordRequestMetric()` que escribe dentro de la petición, el borrado `purgeOldMetrics.sql` y la consulta
`monthlySla.sql`. Su olor es **de arquitectura**: el tiempo como una columna más, la métrica dentro del camino del
negocio, el borrado por filas y el percentil leído de los crudos.

### 5.4 Nombres de archivo del curso

Fases `NN-slug.md`; apéndices `aNN-slug.md`; la historia `00-historia-de-timbra.md`; documentos vivos en la raíz
(§7). Minúsculas y guiones, salvo `README.md`, `INSTINTOS.md` y `BENCHMARKS.md`.

---

## 6. 🧱 La plantilla de los documentos

> 🚧 **Preliminar:** la plantilla rígida de fase se fija con la propuesta de fases. Punto de partida, el mismo de
> los cursos anteriores de la ruta: una sola plantilla que modela **y** mide.

### 6.1 Encabezado obligatorio de fase

```markdown
# ⏱️ Fase 03 — Cuarenta y ocho mil clientes como etiqueta

> **Curso:** El Vigía · Fase 03 de NN · Bloque I · **10 h**
> **Motor:** InfluxDB 3 Core `influxdb@sha256:…` · **Base de verdad:** PostgreSQL `postgres@sha256:…`
> **Rivales en esta fase:** {{TimescaleDB · Prometheus · MongoDB · ninguno}}
> **Carga:** {{series activas, puntos por segundo, ventana consultada}}
> **Depende de:** Fase 02 · **Habilita:** Fase 04
> **Fecha de verificación ejecutada:** DD/MM/AAAA
> **Objetivo:** …
```

El título nombra el dolor de Timbra, no la función del motor.

### 6.2 Secciones de una fase (punto de partida)

1. Título y encabezado
2. 🧭 **Dónde estamos** — qué dejó la fase anterior, y el dolor de Timbra que abre esta
3. 🎯 **Objetivos**, verificables
4. 🚫 **Qué NO entra todavía**, con destino
5. 🧩 **El modelo** — la serie, sus etiquetas, su resolución y su consulta, en cada motor
6. 🪞 **La apuesta**, escrita antes de medir
7. 📐 **La medición**: lo guardado contra lo emitido, lo agregado contra lo exacto, la forma y el tiempo
8. 💥 **El punto de rotura**, con volumen y mensaje literal
9. ⚖️ **Veredicto honesto: cuándo NO hacer esto**
10. ⚠️ **Errores comunes y diagnóstico**, con mensaje literal
11. 📋 **Checklist de validación**, ejecutable
12. 🧪 **Ejercicios** (§8)
13. 📚 **Referencias** (§10)
14. 🏁 **Resultado de la fase** y La señal de que quedó bien

Después, fuera de lo que lee el estudiante, puede ir **📌 Pendientes sugeridos**.

### 6.3 Cómo se presenta una medición

**Toda medición se publica con cinco datos**: qué se midió (lo guardado, lo agregado y la forma primero), sobre
qué carga, con qué motor, digest y configuración frente a qué alternativa, en qué máquina si hay tiempos, y el
comando exacto para reproducirla. **Siempre con series activas, puntos por segundo y ventana consultada.**

```markdown
> 📐 **Medición — el percentil 99,5 del mes por cliente** · 1.200 clientes con SLA, 30 días, 2,6 M peticiones/día
> · `influxdb@sha256:…` frente a `timescale@sha256:…` y `request_metrics` · verificado el DD/MM/AAAA · {{máquina}}
>
> | motor | método | error contra el exacto (p99,5) | series o filas leídas | disco | p50 | p95 | p99 |
> |---|---|---|---|---|---|---|---|
> | PostgreSQL | crudos | 0 | … | … | … | … | … |
> | InfluxDB 3 | histograma por hora | … | … | … | … | … | … |
> | TimescaleDB | boceto por hora | … | … | … | … | … | … |
>
> Reproducir: `node scripts/measure.ts sla --month 2026-03 --customers 1200`
```

**Los tiempos van con su dispersión** (mediana, p95 y p99, repeticiones y calentamiento declarados) y la máquina,
**y nunca sostienen solos un veredicto** (D-19). Los costos de los gestionados llevan ☁️, la fuente y la fecha
(D-22). La 🪞 apuesta se escribe antes y no se edita.

---

## 7. 📐 Los tipos de documento y su coherencia

- **Fases**, **apéndices** y la **historia**, documento del lector y fuente de verdad narrativa: ningún dato de
  Timbra se inventa en una fase.
- **Documentos vivos** en la raíz, que son producto: `INSTINTOS.md` (cada 🪞 con su medición),
  **`BENCHMARKS.md`** (toda medición publicada, con los cinco datos de §6.3) y el catálogo de errores con su
  mensaje literal (si es apéndice o documento aparte, lo dice la propuesta de apéndices).
- **Los apéndices no repiten una fase, y viceversa: se enlazan.** **Una fase no cita el temario ni el plan.** 🗑️
  **Los `_desechable-*` no se citan nunca.**
- **Git:** tags `fase-NN-<slug>`, prefijo de commit `fNN:`, ejercicios `fNN ejM: …` (D-09).

---

## 8. 🧪 Evaluación: ejercicios

- **Cantidad: 20 mínimo y 30 máximo por fase**, calibrada con *"¿cuántas cosas distintas enseña esta fase que se
  puedan comprobar por separado?"*.
- **La escala:** 🟢 reproducir · 🟡 aplicar el patrón a otra métrica de Timbra · 🟠 combinar, diagnosticar,
  decidir · 🔴 abierto o adversarial · 🔥 extra, fuera del mínimo.
- **Distribución ≈ 30 % 🟢, 30 % 🟡, 25 % 🟠, 15 % 🔴**, con margen; el bloque de los motores carga hacia 🟠 y 🔴.
- **Al menos un tercio de diagnóstico o medición**: una etiqueta que explota, un promedio de percentiles, un
  contador que se reinicia, un punto que llega tarde y se pierde, una alerta que nunca dispara; se pide
  reproducir, medir y explicar.
- **Predecir antes de ejecutar** en 🟠 y 🔴. **Cada ejercicio cierra con su criterio** (`Objetivo` o `Pregunta`).
  **Agrupados por dificultad**, con el conteo en el título.
- **Sin solución publicada** (D-05). **Taller global:** la observabilidad en `src/`.
- **💀 Boss de bloque**, cuando el bloque lo admita: un cierre de mes roto o un encargo completo de alguien de
  Timbra (con nombre, de la historia §2), que cruza al menos dos fases y se entrega como artefacto.

---

## 9. 📏 Longitud y densidad

> 🚧 **Preliminar**, a fijar con la propuesta de fases. Punto de partida para una fase de 10 h: **4.000–5.000
> palabras de cuerpo**, contadas hasta el encabezado de 🧪 Ejercicios. Los apéndices son cortos, con índice de
> salto rápido, una tabla de "cuándo usar qué" y de 5 a 10 ejercicios de consulta.

---

## 10. 📚 Referencias y enlaces

### 10.1 Enlaces externos

**Orden de prioridad:** documentación oficial de la versión que usamos (InfluxDB 3, TimescaleDB, Prometheus,
MongoDB, PostgreSQL, Apache Parquet); después los papers de base (la compresión de Gorilla, los bocetos de
cuantiles); después libros; después blogs y videos, con escepticismo explícito ante las comparativas de parte
interesada. **Siempre se advierte cuando un enlace apunta a otra versión**, y con las licencias y los precios se
cita la fecha. Cada URL se comprueba por código de estado en la sesión que la escribe.

Cada fase cierra sus referencias con un **orden de lectura sugerido**: antes de ejecutar, durante y después.

### 10.2 Enlaces internos y anclas

Rutas relativas; anclas comprobadas; **ningún enlace a un documento que todavía no existe**.

### 10.3 Vigencia

Las secciones de referencias advierten que las URL y los contenidos cambian, que InfluxDB cambió de arquitectura
entre generaciones y que las ediciones y las licencias cambian: se cita la fecha.

---

## 11. 🧷 Vocabulario visual

**Marcadores de estado:** 💸 deuda intencional (con fase de pago) · 🔥 opcional · 🚧 fuera de alcance por ahora,
con destino · ☁️ tomado de documentación, no medido · 🟢🟡🟠🔴 dificultad · ⭐ valoración bibliográfica, solo en
referencias.

**Callouts en blockquote:** 📐 **Medición** (§6.3) · 🪞 **Apuesta / instinto que falla** · 💥 **Punto de rotura** ·
⚰️ **Autopsia** · ⚖️ **Veredicto honesto** y **"Y aquí el instinto SQL tenía razón"** · 🩻 **Esto sí funciona
igual** · 📖 **Traducción** SQL ↔ PromQL ↔ consulta de cada motor, en tabla · 🧠 **Modelo mental** · ⚠️
**Advertencia** · 📝 **Nota de contexto** (licencias, ediciones, historia de un proyecto) · 💡 **Truco** · 🩺
**Diagnóstico**, la consulta o el estado interno que confirma o descarta una hipótesis.

**Secciones narrativas recurrentes:** *Dónde estamos* · *Detalles con intención* · *El patrón a memorizar* ·
*Prueba de fuego* · *La señal de que quedó bien*.

---

## 12. ✅ Checklist antes de dar por cerrado un `.md`

```text
[ ] El encabezado está completo, con motor, digest, rivales, carga y fecha de verificación
[ ] La fase abre con un dolor de Timbra que está en la historia
[ ] Ningún dato de la empresa se inventó en la fase (si hacía falta, se agregó a la historia)
[ ] Nada de lo que Ruta NoSQL Lite ya enseñó se explicó de nuevo; ninguna remisión a sus fases
[ ] Todo número salió de una ejecución real; lo emulado o no verificado está declarado
[ ] Toda medición trae los cinco datos de §6.3, con series activas, puntos por segundo y ventana
[ ] Toda pérdida trae lo guardado contra lo emitido; todo agregado, su error contra el exacto
[ ] PostgreSQL jugó con lo mejor que tiene (particionado, BRIN, TimescaleDB), no como adorno
[ ] Cada función con licencia distinta está marcada; los costos de la nube llevan ☁️, fuente y fecha
[ ] La apuesta se escribió antes de medir y no se editó después
[ ] El punto de rotura trae volumen exacto y mensaje literal
[ ] Hay un ⚖️ veredicto con la pérdida cuantificada
[ ] Ninguna autopsia juzga a una persona
[ ] Las mediciones, los errores y el 🪞 entraron en sus documentos vivos
[ ] Ejercicios: 20–30, agrupados, con conteo, un tercio de diagnóstico, cada uno con Objetivo o Pregunta
[ ] Los diagramas están en Mermaid; los árboles y salidas, en text o json
[ ] Tuteo en todo el documento; cero voseo, cero "usted"
[ ] Código en inglés, comentarios en español con tildes; métricas con unidad y sufijo
[ ] Ningún enlace a un documento que no existe; grep -ln "_desechable-" *.md no devuelve nada
```

---

## 13. ⚖️ Excepciones declaradas

1. **Ruta NoSQL Lite como prerrequisito** (D-14) → no se explican los fundamentos de series temporales → los da
   lite, y repetirlos sería el curso que el lector ya hizo.
2. **Los ejercicios no traen solución publicada** (D-05) → el método del curso es apostar y medir antes de mirar,
   y cada ejercicio trae su criterio.

Todo lo demás del `CLAUDE.md` aplica tal cual.

---

## 14. 🧪 Laboratorio

- **Docker Compose es el camino principal**; cada receta trae su equivalente en Podman. **Aquí no se enseña
  Docker. Sin Kubernetes.**
- **Perfiles de Compose** para no pasar de 16 GB: PostgreSQL, el simulador, Prometheus y el arnés siempre; **un
  motor de series más a la vez** (D-20).
- **Cada motor con su configuración documentada**, nunca con la de otro. Si una imagen no corre nativa en arm64, se
  declara (D-29).
- **Servicios nombrados por papel** (`relacional`, `series`, `series-rival`, `extractor`), para que cambiar de motor
  no rompa los comandos escritos.
- **Grafana es visor** y nunca entra a una medición (D-28).
- **Datos sintéticos con semilla fija** y cada punto emitido conocido (D-21, D-31).
- **Las pruebas de la producción** corren en contenedores etiquetados con el curso y en puertos altos aleatorios;
  el código de las sesiones va a `zz-code/` con su README.

---

## 15. 📌 Pendientes que afectan a esta guía

- **La plantilla rígida de fase (§6.2) y las longitudes (§9)** se fijan con la propuesta de fases. Todas las
  decisiones del alcance están cerradas (07/10/2026).
- **El diccionario de términos y el contrato de nombres** se escriben después de la propuesta de fases; hasta
  entonces mandan §3 y §5.2.
- **Versiones, digests y licencias sin fijar** hasta la verificación previa; lo mismo si InfluxDB 3 Core sirve
  como principal (D-24) y qué bocetos trae cada motor (D-26).
- **El recorte contra lite** se revisa cuando sus fases 09 y 10 estén escritas.
- **El verificador del curso** se copia de `zz-instrucciones/herramientas/` y se ajusta cuando la plantilla de
  fase esté fijada.
