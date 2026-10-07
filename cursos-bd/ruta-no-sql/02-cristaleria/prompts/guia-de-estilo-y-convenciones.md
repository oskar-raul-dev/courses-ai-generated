# ✍️ Guía de estilo, tono y convenciones
## Cristalería — el modelo analítico embebido a fondo

> **Qué es este documento:** la fuente de verdad editorial del curso: **cómo** se escribe. Cualquier
> sesión que produzca un `.md` de Cristalería la sigue, para que todas las fases se lean como escritas por
> la misma mano y apunten al mismo sitio: **que el lector decida qué pregunta cabe en un proceso, con qué
> herramienta, y lo defienda con números propios.**
> **Vigencia:** 2026-10-06. **Cerrada salvo lo que depende de la propuesta de fases**: la plantilla rígida
> de fase (§6.2) y las longitudes (§9), que se fijan con ella (§15).
> **Herencia:** se escribió con la guía de Ruta NoSQL Lite y las de Proteo y Portalón como modelo, porque
> es la misma ruta y el lector viene de lite. Diverge de lite en: un solo dominio y una sola familia, una
> sola plantilla de fase, Mermaid, tiempos permitidos con dispersión, la profundidad full geek y **Python
> como lenguaje principal**. La guía de agosto (`_desechable-guia-de-estilo-v1.md`) queda de consulta.
> **Precedencia.** Por encima solo está [`alcance-del-proyecto.md`](alcance-del-proyecto.md). Por debajo
> van el contrato de nombres, el diccionario, las propuestas, las plantillas y los prompts. El `CLAUDE.md`
> del repositorio aplica en todo lo que este curso no haya declarado como excepción (§13).

Si dudas entre dos formas de escribir algo, gana la que le sirva más a alguien que el lunes tiene que
explicarle a una junta por qué las cuentas del concejo caben en una laptop y el clúster sigue encendido
para otra cosa —o por qué ya no—.

---

## 1. 🧭 Principio rector

**Todo lo que se escribe apunta a que alguien decida con criterio dónde corre una pregunta analítica, y
lo pueda defender con números propios, incluido lo que pasa dentro del motor.**

No enseñamos DuckDB como producto ni formamos ingenieros de plataforma. Formamos la capacidad de mirar
una pregunta, reconocer su forma (cuántas columnas, cuántas filas, cuánto se une, cuánto se repite),
llevarla al archivo donde está, medir cuánto lee y cuánto pide de memoria, y saber qué hace el motor
cuando lo aprietan.

El filtro para cada párrafo: **¿esto ayuda a preguntar, a medir, a diagnosticar o a decidir?** Si no,
sobra.

> 🧠 **Primero los bytes, después el reloj.** En este modelo lo que manda es cuánto se lee y cuánta
> memoria se pide; el tiempo es la consecuencia. Por eso un tiempo nunca se publica solo: va con los bytes
> leídos, la memoria pico y la dispersión.

### 1.1 Qué NO es este curso

No es un curso de DuckDB desde cero, ni de pandas ni de Polars, ni de ingeniería de datos, ni de
visualización. No repite Ruta NoSQL Lite: lo que lite enseñó de analítico embebido se **usa** sin volver
a explicarlo.

### 1.2 Requisitos y autocontención

Lo publicado nombra Ruta NoSQL Lite **solo como requisito de entrada**, en el README y en la primera
fase. **No usa su contenido**: no remite a sus fases, no reutiliza sus ejemplos, sus datos ni sus
mediciones; si el curso necesita algo que lite enseñó, lo da por sabido o lo dice con sus propias
palabras y con Pasaje (D-03). Ningún documento publicado cita otros cursos de la ruta ni el `CLAUDE.md`
del repositorio.

---

## 2. 🎤 Tono

**Semiformal, cálido y directo**, con humor cuando cae bien: un colega que estuvo en la semana del pasaje
y te lo cuenta con paciencia.

- **Tuteo latinoamericano, siempre.** *"Corre la consulta con el perfil activado y cuenta cuántos row
  groups se saltó"*. Nada de voseo, nada de "usted", nada de impersonal permanente.
- **Semiformal.** Frases completas, cero abreviaturas de mensajería.
- **Humor seco y con moderación.** Máximo un chiste por sección; el blanco es la situación (el "ya
  mismo" de Marcelo, el despertar del clúster), nunca una persona.
- **Cálido sin condescendencia.** El lector es senior y ya hizo lite.
- **Honesto sobre lo feo.** Si Polars gana, si pandas alcanza, si el clúster era la respuesta para una
  pregunta, se dice con esas palabras y con el número delante.

### 2.1 El tono de las autopsias

⚰️ Una autopsia se escribe sobre una **decisión**, jamás sobre una persona. La plataforma la firmó
Rodrigo, con buenos argumentos, y sin ella Pasaje no habría sobrevivido al GPS en 2021; el cuaderno de
Andrés es la razón por la que los informes salieron durante años. Si un párrafo suena a *"quien montó un
clúster para esto no sabía"*, el curso pierde a su mejor personaje y al lector que hizo algo parecido.

Se escribe en este orden: la decisión con su mejor argumento; por qué era razonable entonces; qué pasó
después, con número; cuánto cuesta salir, con número; qué pregunta, hecha a tiempo, habría cambiado el
resultado. Lo que nunca aparece: "obviamente", "cualquiera habría visto", "error de novato".

---

## 3. 🗣️ Idioma y forma de la narrativa

- **Español latinoamericano neutro** para todo lo que no sea código o salida de terminal.
- **Los términos del oficio se quedan en inglés** cuando son el nombre real de la cosa: *row group*,
  *page*, *predicate pushdown*, *projection pushdown*, *zone map*, *morsel*, *pipeline*, *spilling*,
  *buffer manager*, *checkpoint*, *WAL*, *ASOF join*, *hash join*, *range join*, *dataframe*, *lazy*,
  *streaming*, *range request*, *row group size*, *dictionary encoding*. Los que tienen traducción asentada
  —columna, fila, partición, unión, agregación, ventana, memoria, compresión, consulta— se alternan con
  naturalidad. **No se inventa vocabulario.**
- **Markdown siempre**, sin HTML embebido. **Prosa antes que listas.** Una frase aislada por sección, dos
  si es larga.
- **Tablas solo para lo tabular y corto**: comparación de motores, codificaciones, resultados de un duelo,
  la traducción SQL ↔ dataframe.
- **Diagramas en Mermaid** (D-12): el pipeline de Pasaje, el recorrido de una consulta por los row groups,
  el plan con sus operadores, el tablero y el servidor estático. Árboles de archivos y salidas en `text`.
- **Salida de terminal literal**, en `text`, sin recortar la parte incómoda (sobre todo la del perfil de
  la consulta y la de un `MemoryError`).
- **Encabezados con emoji, con moderación.**

---

## 4. 🎓 Pedagogía: cómo se explica

El público es senior, relacional de oficio y ya pasó por lite: **no explicar lo que ya sabe, y no dejar
ambiguo nada de lo que no.**

### 4.1 La regla del andamio

1. **El problema primero**, siempre en Pasaje: *"Un trimestre de validaciones, ocho gigabytes de Parquet.
   La consulta del concejo pide tres columnas y una semana. ¿Cuántos megabytes va a leer? Apúntalo antes
   de ejecutar."*
2. **El mecanismo después**: el nombre y la definición mínima.
3. **La consulta que corre**, con su salida real y la línea del perfil señalada.

### 4.2 Del instinto se parte, no se reniega

- 🩻 **"Esto sí funciona igual"** — lo que se transfiere sin cambios del relacional: el SQL, el plan que
  se lee de abajo hacia arriba, la selectividad que manda, una ventana sigue siendo una ventana.
- 🪞 **"Tu instinto dice… y esta vez se equivoca"** — el relacional (*"primero lo cargo"*, *"un índice lo
  arregla"*), el de dataframes (*"si no entra en RAM, necesito un clúster"*) o el que lite dejó demasiado
  firme (*"columnar siempre gana"*). **Una por fase como mínimo.**
- ⚖️ **"Y aquí el instinto SQL tenía razón"** — las preguntas donde el veredicto va en la otra dirección:
  la búsqueda de una fila, la escritura concurrente, la pregunta que el clúster sí merecía. Sin este
  recuadro el curso sonaría a folleto.

### 4.3 Nada de cajas negras prematuras

Primero la consulta en la CLI de DuckDB o en Python a pelo; después el pipeline. Primero el metadato del
Parquet (`parquet_metadata`) y el perfil de la consulta; después la herramienta que los dibuja. Si se
habla de spilling, se muestra cuántos bytes se escribieron al directorio temporal.

### 4.4 Analogías, con fecha de caducidad

Una vez, para abrir la puerta, y se abandonan diciendo dónde se rompen. La más peligrosa del curso:
**"DuckDB es el SQLite de la analítica"**. Se desmonta en el mismo párrafo: comparten que viven en el
proceso, y en casi nada más —formato, ejecución, concurrencia y para qué sirven—.

### 4.5 Explica el porqué

Cada decisión lleva su porqué: por qué este orden de filas al materializar, por qué este tamaño de row
group, por qué esta partición, por qué SQL y no dataframe en esta transformación, o al revés.

### 4.6 Densidad calibrada

Un concepto nuevo por vez. Ninguna sección teórica supera las dos pantallas sin una consulta, una medición
o un diagrama. Reaparecen con otras palabras: la pregunta del curso, "cuánto lee y cuánta memoria pide",
"el volcado es inmutable" y "un viaje es un pasaje cobrado".

### 4.7 Cierra los bucles

Todo paréntesis abierto —*"esto lo pagamos en el bloque de memoria"*, *"deuda 💸"*— se cierra.

---

## 5. 💻 Código, comandos y archivos

> **Regla normativa:** todo lo que se ejecuta o se versiona va en inglés —archivos, rutas, variables,
> identificadores, columnas, tablas— y **todos los comentarios van en español con tildes**. Lo que ve el
> público del tablero va en español: la columna en inglés, la etiqueta en español.

- **Código ejecutable y mínimo**, que corre de punta a punta con las versiones fijadas.
- **Comentarios que explican el porqué**: `# ordenar por fecha antes de escribir: los row groups quedan
  con rangos que no se pisan` sí; `# ordenar` no.
- **Bloques con su lenguaje declarado**: `python`, `sql`, `ts`, `bash`, `yaml`, `text`.
- **Un bloque, una idea.** **Nunca `foo`, `bar`, `df1` ni `test1`**: todo usa Pasaje.
- **Python moderno y tipado**: anotaciones de tipo, `pathlib`, sin `import *`. **El SQL va en SQL**, no
  armado con f-strings: los parámetros, con los mecanismos del cliente.

### 5.1 Versiones fijadas

**Digest para las imágenes y archivo de bloqueo para las librerías**, con la versión legible en un
comentario. **Ninguna versión se escribe de memoria**, y hasta la verificación previa ningún documento
publica un número de versión (§15). **Lo no verificado se dice con esas palabras**: si una imagen no
corre nativa en arm64 y se midió emulada, la medición lo dice.

### 5.2 Los nombres del dominio

Fijos en todo el curso y en inglés. Hasta que exista el contrato de nombres, estos son los vigentes:

| En la narrativa | En el código |
|---|---|
| validación, validador | `tap`, `validator` |
| tarjeta (seudonimizada), tarjeta de servicio | `card_id`, `staff_card` |
| tipo de tarifa (general, preferencial) | `fare_type` (`general`, `student`, `senior`, `disability`) |
| viaje, transbordo | `trip`, `transfer` |
| operadora, ruta, parada, estación | `operator`, `route`, `stop`, `station` |
| bus, posición GPS | `bus`, `gps_ping` |
| conteo a bordo, tablet | `onboard_count`, `tablet` |
| parroquia | `parish` |
| volcado (y su versión) | `dump`, `dump_version` |
| derivado | `derived` |
| tablero | `dashboard` |

**Las tablas y columnas, en `snake_case`**; las tablas en plural (`taps`, `gps_pings`, `trips`). Los
archivos siguen un esquema de rutas fijo, que se declara en la primera fase que escribe archivos y no se
cambia: `data/raw/dumps/operator=…/month=…/`, `data/raw/gps/date=…/hour=…/`, `data/derived/…`. Una fase
no renombra una columna ni una entidad: si necesita una nueva, la declara y se agrega aquí y en la
historia.

### 5.3 El villano también va en inglés

El código del villano se nombra como estaba en Pasaje: el trabajo de Spark `trips_job.py`, el cuaderno de
Andrés `quarterly_fares.ipynb`, la API `public_api`. Su olor es **de arquitectura**: un clúster que
despierta para una pregunta que cabe en un proceso, una ingesta para archivos que se podían leer donde
estaban, un servidor encendido para servir agregados que no cambian.

### 5.4 Nombres de archivo del curso

Fases `NN-slug.md`; apéndices `aNN-slug.md`; la historia `00-historia-de-pasaje.md`; documentos vivos en
la raíz (§7). Minúsculas y guiones, salvo `README.md`, `INSTINTOS.md` y `BENCHMARKS.md`.

---

## 6. 🧱 La plantilla de los documentos

> 🚧 **Preliminar:** la plantilla rígida de fase se fija con la propuesta de fases. Punto de partida, el
> mismo de Proteo y Portalón: una sola plantilla que pregunta **y** mide.

### 6.1 Encabezado obligatorio de fase

```markdown
# 🦆 Fase 05 — La parada que el validador no anota

> **Curso:** Cristalería · Fase 05 de NN · Bloque II · **10 h**
> **Motor:** DuckDB `{{versión del uv.lock}}` en `python@sha256:…` · **Control:** PostgreSQL `postgres@sha256:…`
> **Rivales en esta fase:** {{pandas · Polars · SQLite · Spark · ninguno}}
> **Dónde corre:** {{proceso de Python · navegador · ambos}}
> **Volumen:** {{chico y grande, los del laboratorio}}
> **Depende de:** Fase 04 · **Habilita:** Fase 06
> **Fecha de verificación ejecutada:** DD/MM/AAAA
> **Objetivo:** …
```

El título nombra el dolor de Pasaje, no la función de DuckDB.

### 6.2 Secciones de una fase (punto de partida)

1. Título y encabezado
2. 🧭 **Dónde estamos** — qué dejó la fase anterior, y el dolor de Pasaje que abre esta
3. 🎯 **Objetivos**, verificables
4. 🚫 **Qué NO entra todavía**, con destino
5. 🧩 **La pregunta y su forma** — qué columnas, cuántas filas, qué se une, y la consulta
6. 🪞 **La apuesta**, escrita antes de medir
7. 📐 **La medición** contra los rivales y, cuando toca, contra PostgreSQL
8. 💥 **El punto de rotura**, con volumen y mensaje literal
9. ⚖️ **Veredicto honesto: cuándo NO hacer esto**
10. ⚠️ **Errores comunes y diagnóstico**, con mensaje literal
11. 📋 **Checklist de validación**, ejecutable
12. 🧪 **Ejercicios** (§8)
13. 📚 **Referencias** (§10)
14. 🏁 **Resultado de la fase** y La señal de que quedó bien

Después, fuera de lo que lee el estudiante, puede ir **📌 Pendientes sugeridos**.

### 6.3 Cómo se presenta una medición

**Toda medición se publica con cinco datos**: qué se midió (en forma estructural primero), sobre qué
volumen, con qué motor y versión frente a qué alternativa, en qué máquina con qué hilos y qué límite de
memoria si hay tiempos, y el comando exacto para reproducirla.

```markdown
> 📐 **Medición — viajes por tarifa y semana, un trimestre** · 95 M validaciones, 2,1 GB en Parquet ·
> DuckDB `x.y.z` frente a Polars `x.y.z` y pandas `x.y.z` · 8 hilos, 6 GB de límite · caché caliente ·
> verificado el DD/MM/AAAA · {{máquina}}
>
> | | bytes leídos | memoria pico | p50 | p95 | p99 | líneas |
> |---|---|---|---|---|---|---|
> | DuckDB (SQL) | … | … | … | … | … | … |
> | Polars (lazy) | … | … | … | … | … | … |
> | pandas | … | … | … | … | … | … |
>
> Reproducir: `uv run harness fares-by-week --volume large --cache warm`
```

**Los tiempos van con su dispersión** (mediana, p95 y p99, repeticiones y calentamiento declarados), caché
frío y caliente por separado, y la máquina, **y nunca sostienen solos un veredicto** (D-19). **Todo duelo
se publica en dos volúmenes** (D-27). Los costos de la nube llevan ☁️, la fuente y la fecha, y nunca van
en la misma tabla que lo medido sin esa marca. La 🪞 apuesta se escribe antes y no se edita.

---

## 7. 📐 Los tipos de documento y su coherencia

- **Fases**, **apéndices** y la **historia**, documento del lector y fuente de verdad narrativa: ningún
  dato de Pasaje se inventa en una fase.
- **Documentos vivos** en la raíz, que son producto: `INSTINTOS.md` (cada 🪞 con su medición),
  **`BENCHMARKS.md`** (toda medición publicada, con los cinco datos de §6.3) y el catálogo de errores con
  su mensaje literal (si es apéndice o documento aparte, lo dice la propuesta de apéndices).
- **Los apéndices no repiten una fase, y viceversa: se enlazan.** **Una fase no cita el temario ni el
  plan.** 🗑️ **Los `_desechable-*` no se citan nunca.**
- **Git:** tags `fase-NN-<slug>`, prefijo de commit `fNN:`, ejercicios `fNN ejM: …` (D-09).

---

## 8. 🧪 Evaluación: ejercicios

- **Cantidad: 20 mínimo y 30 máximo por fase**, calibrada con *"¿cuántas cosas distintas enseña esta fase
  que se puedan comprobar por separado?"*.
- **La escala:** 🟢 reproducir · 🟡 aplicar el patrón a otra pregunta de Pasaje · 🟠 combinar,
  diagnosticar, decidir · 🔴 abierto o adversarial · 🔥 extra, fuera del mínimo.
- **Distribución ≈ 30 % 🟢, 30 % 🟡, 25 % 🟠, 15 % 🔴**, con margen; el bloque del proceso por dentro carga
  hacia 🟠 y 🔴.
- **Al menos un tercio de diagnóstico o medición**: un Parquet escrito sin orden que no salta nada, una
  unión sin acotar, la tarjeta de servicio que desbalancea, un `MemoryError`, un tablero que baja el
  archivo entero; se pide reproducir, medir y explicar.
- **Predecir antes de ejecutar** en 🟠 y 🔴. **Cada ejercicio cierra con su criterio** (`Objetivo` o
  `Pregunta`). **Agrupados por dificultad**, con el conteo en el título.
- **Sin solución publicada** (D-05). **Taller global:** el pipeline de Pasaje en `src/`.
- **💀 Boss de bloque**, cuando el bloque lo admita: un pipeline roto o un encargo completo de alguien de
  Pasaje (con nombre, de la historia §2), que cruza al menos dos fases y se entrega como artefacto.

---

## 9. 📏 Longitud y densidad

> 🚧 **Preliminar**, a fijar con la propuesta de fases. Punto de partida para una fase de 10 h: **4.000–5.000
> palabras de cuerpo**, contadas hasta el encabezado de 🧪 Ejercicios. Los apéndices son cortos, con
> índice de salto rápido, una tabla de "cuándo usar qué" y de 5 a 10 ejercicios de consulta.

---

## 10. 📚 Referencias y enlaces

### 10.1 Enlaces externos

**Orden de prioridad:** documentación oficial de la versión que usamos (DuckDB, DuckDB-Wasm, Polars,
pandas, SQLite, PostgreSQL, Spark); después especificaciones (Parquet, Arrow, GTFS) y los papers del
equipo de DuckDB y de los otros motores; después libros; después blogs y videos. **Siempre se advierte
cuando un enlace apunta a otra versión**, y con los precios de la nube se cita la fecha de la consulta.
Cada URL se comprueba por código de estado en la sesión que la escribe.

Cada fase cierra sus referencias con un **orden de lectura sugerido**: antes de ejecutar, durante y
después.

### 10.2 Enlaces internos y anclas

Rutas relativas; anclas comprobadas; **ningún enlace a un documento que todavía no existe**.

### 10.3 Vigencia

Las secciones de referencias advierten que las URL y los contenidos cambian, que estos proyectos
publican versiones nuevas cada pocos meses y que los precios de la nube cambian sin aviso: se cita la
fecha.

---

## 11. 🧷 Vocabulario visual

**Marcadores de estado:** 💸 deuda intencional (con fase de pago) · 🔥 opcional · 🚧 fuera de alcance por
ahora, con destino · ☁️ tomado de documentación, no medido · 🟢🟡🟠🔴 dificultad · ⭐ valoración
bibliográfica, solo en referencias.

**Callouts en blockquote:** 📐 **Medición** (§6.3) · 🪞 **Apuesta / instinto que falla** · 💥 **Punto de
rotura** · ⚰️ **Autopsia** · ⚖️ **Veredicto honesto** y **"Y aquí el instinto SQL tenía razón"** · 🩻
**Esto sí funciona igual** · 📖 **Traducción** SQL ↔ dataframe, en tabla · 🧠 **Modelo mental** · ⚠️
**Advertencia** · 📝 **Nota de contexto** (licencias, precios, historia de un proyecto) · 💡 **Truco** ·
🩺 **Diagnóstico**, la consulta o el perfil que confirma o descarta una hipótesis.

**Secciones narrativas recurrentes:** *Dónde estamos* · *Detalles con intención* · *El patrón a
memorizar* · *Prueba de fuego* · *La señal de que quedó bien*.

---

## 12. ✅ Checklist antes de dar por cerrado un `.md`

```text
[ ] El encabezado está completo, con motor, versión, dónde corre y fecha de verificación
[ ] La fase abre con un dolor de Pasaje que está en la historia
[ ] Ningún dato de la empresa se inventó en la fase (si hacía falta, se agregó a la historia)
[ ] Nada de lo que Ruta NoSQL Lite ya enseñó se explicó de nuevo; ninguna remisión a sus fases
[ ] Todo número salió de una ejecución real; lo emulado o no verificado está declarado
[ ] Toda medición trae los cinco datos de §6.3; los tiempos, con mediana, p95 y p99, caché frío y caliente
[ ] Todo duelo está en dos volúmenes; los hilos y el límite de memoria de cada motor, declarados
[ ] Los costos de la nube llevan ☁️, fuente y fecha
[ ] La apuesta se escribió antes de medir y no se editó después
[ ] El punto de rotura trae volumen exacto y mensaje literal
[ ] pandas, Polars y SQLite aparecen como rivales serios, no como adorno
[ ] Hay un ⚖️ veredicto con la pérdida cuantificada
[ ] Ninguna autopsia juzga a una persona
[ ] Las mediciones, los errores y el 🪞 entraron en sus documentos vivos
[ ] Ejercicios: 20–30, agrupados, con conteo, un tercio de diagnóstico, cada uno con Objetivo o Pregunta
[ ] Los diagramas están en Mermaid; los árboles y salidas, en text
[ ] Tuteo en todo el documento; cero voseo, cero "usted"
[ ] Código en inglés, comentarios en español con tildes
[ ] Ningún enlace a un documento que no existe; grep -ln "_desechable-" *.md no devuelve nada
```

---

## 13. ⚖️ Excepciones declaradas

1. **Ruta NoSQL Lite como prerrequisito** (D-14) → no se explican los fundamentos del analítico embebido →
   los da lite, y repetirlos sería el curso que el lector ya hizo.
2. **Los ejercicios no traen solución publicada** (D-05) → el método del curso es apostar y medir antes de
   mirar, y cada ejercicio trae su criterio.
3. **Python como lenguaje principal, TypeScript solo en el tablero** (D-17) → es una excepción a la regla
   de la ruta (R-06), no al `CLAUDE.md` → los rivales de dataframe viven en Python, y el idioma de la
   analítica es Python con SQL; forzar TypeScript sería medir a pandas y a Polars desde afuera.

Todo lo demás del `CLAUDE.md` aplica tal cual.

---

## 14. 🧪 Laboratorio

- **Docker Compose es el camino principal**; cada receta trae su equivalente en Podman. **Aquí no se enseña
  Docker. Sin Kubernetes.**
- **Perfiles de Compose** para no pasar de 16 GB: el contenedor de Python con DuckDB y el arnés siempre;
  PostgreSQL cuando la fase lo usa; el almacenamiento de objetos y el servidor estático en su bloque;
  **Spark solo en el bloque del villano** (D-20).
- **Cada rival con su configuración documentada**, nunca con la de otro (Polars lazy, pandas con PyArrow,
  Spark local con su memoria declarada). Si una imagen no corre nativa en arm64, se declara (D-29).
- **Servicios nombrados por papel** (`analitica`, `relacional`, `objetos`, `estatico`, `cluster`), para
  que cambiar de versión no rompa los comandos escritos.
- **Datos sintéticos con semilla fija** y los generadores del recaudo, del GPS, del GTFS y de las tablets
  (D-21). Las extensiones de DuckDB vienen instaladas en la imagen (D-25).
- **El límite de memoria se fija a propósito** en cada medición que lo necesita, en el motor y en el
  contenedor, y se declara.
- **Las pruebas de la producción** corren en contenedores etiquetados con el curso y en puertos altos
  aleatorios; el código de las sesiones va a `zz-code/` con su README.

---

## 15. 📌 Pendientes que afectan a esta guía

- **La plantilla rígida de fase (§6.2) y las longitudes (§9)** se fijan con la propuesta de fases. Todas
  las decisiones del alcance están cerradas (06/10/2026).
- **El diccionario de términos y el contrato de nombres** se escriben después de la propuesta de fases;
  hasta entonces mandan §3 y §5.2.
- **Versiones, digests y licencias sin fijar** hasta la verificación previa; lo mismo los precios de la
  nube del villano.
- **El recorte contra lite** se revisa cuando sus fases 07 y 08 estén escritas.
- **El verificador del curso** se copia de `zz-instrucciones/herramientas/` y se ajusta cuando la plantilla
  de fase esté fijada.
