# ✍️ Guía de estilo, tono y convenciones
## El Árbitro — la persistencia políglota a fondo

> **Qué es este documento:** la fuente de verdad editorial del curso: **cómo** se escribe. Cualquier sesión que
> produzca un `.md` de El Árbitro la sigue, para que todas las fases se lean como escritas por la misma mano y
> apunten al mismo sitio: **que el lector decida cuántos motores necesita un sistema, cómo los mantiene
> coherentes y cuánto le cuestan, y lo defienda con números propios.**
> **Vigencia:** 2026-10-07. **Cerrada salvo lo que depende de la propuesta de fases**: la plantilla rígida de
> fase (§6.2) y las longitudes (§9), que se fijan con ella (§15).
> **Herencia:** se escribió con la guía de Ruta NoSQL Lite y las de los cursos anteriores de la ruta como
> modelo, porque es la misma ruta y el lector viene de lite. Diverge de lite en: un solo dominio, una sola
> plantilla de fase, Mermaid, tiempos permitidos con dispersión, la profundidad full geek **en la costura** y no
> en cada motor, **la verdad contra cada derivado como primera medida** y **la factura como medición de primera
> clase**. La guía de agosto (`_desechable-guia-de-estilo-v1.md`) queda de consulta.
> **Precedencia.** Por encima solo está [`alcance-del-proyecto.md`](alcance-del-proyecto.md). Por debajo van el
> contrato de nombres, el diccionario, las propuestas, las plantillas y los prompts. El `CLAUDE.md` del
> repositorio aplica en todo lo que este curso no haya declarado como excepción (§13).

Si dudas entre dos formas de escribir algo, gana la que le sirva más a alguien que el lunes entra a una revisión de
arquitectura y tiene que descartar un motor con argumento, o defender el que sí hace falta.

---

## 1. 🧭 Principio rector

**Todo lo que se escribe apunta a que alguien decida con criterio cuántos motores entran a un sistema, cuál es la
verdad de cada dato y cómo viaja cada cambio, y lo pueda defender con números propios, incluida la factura de cada
motor.**

No enseñamos seis motores ni formamos ingenieros de plataformas de datos. Formamos la capacidad de mirar un patrón de
acceso, preguntar si se gana un motor propio o solo aislamiento, nombrar la verdad, diseñar el camino de cada cambio,
romperlo a propósito, restaurarlo, ponerle precio semanal, y decir que no —o que sí— con el número delante.

El filtro para cada párrafo: **¿esto ayuda a modelar, a medir, a diagnosticar o a decidir?** Si no, sobra. Y un
filtro propio de este curso: **¿esto enseña la decisión de integrar el motor, o se volvió el tutorial del motor?**
Si es lo segundo, sobra (D-35).

> 🧠 **Primero la verdad, después el motor, siempre la factura.** En este modelo el primer número es si cada derivado
> dice lo mismo que la verdad y cuánto tarda en decirlo; el segundo, lo que gana el patrón; el tercero, lo que cuesta
> el motor cada semana. Ninguna arquitectura se publica sin los tres.

### 1.1 Qué NO es este curso

No es un curso de ningún motor, ni de Kafka, ni de Debezium, ni de boleterías. No repite Ruta NoSQL Lite: lo que lite
enseñó de cada familia y de su cierre políglota se **usa** sin volver a explicarlo.

### 1.2 Requisitos y autocontención

Lo publicado nombra Ruta NoSQL Lite **solo como requisito de entrada**, en el README y en la primera fase, y puede
decir que el curso cierra la Ruta NoSQL (D-34). **No usa el contenido de lite**: no remite a sus fases, no reutiliza
sus ejemplos, sus datos ni sus mediciones; si el curso necesita algo que lite enseñó, lo da por sabido o lo dice con
sus propias palabras y con Palco (D-03). Ningún documento publicado cita, enlaza ni exige los otros cursos de la ruta,
ni cita el `CLAUDE.md` del repositorio.

---

## 2. 🎤 Tono

**Semiformal, cálido y directo**, con humor cuando cae bien: un colega que estuvo de guardia la preventa de Los
Tiburones del Sur y te lo cuenta con paciencia.

- **Tuteo latinoamericano, siempre.** *"Detén el consumidor de la búsqueda una hora en plena preventa y cuenta
  cuántas compras entran a una función agotada"*. Nada de voseo, nada de "usted", nada de impersonal permanente.
- **Semiformal.** Frases completas, cero abreviaturas de mensajería.
- **Humor seco y con moderación.** Máximo un chiste por sección; el blanco es la situación (el "¡la embarramos!" de
  Joaquín frente a un restore sin instante común), nunca una persona.
- **Cálido sin condescendencia.** El lector es senior y ya hizo lite.
- **Honesto en las dos direcciones.** Si un motor sobra, se dice con su número; si el monolito ya no aguantaba, se
  dice con el suyo. *Terco es el mismo pecado que crédulo, con mejor reputación.*

### 2.1 El tono de las autopsias

⚰️ Una autopsia se escribe sobre una **decisión**, jamás sobre una persona. Los seis motores los puso Bruno, con aval
de Josefina y con un diagnóstico correcto —el monolito no aguantaba las preventas—; el monolito lo hizo Josefina, y
para el teatro lo volvería a hacer. Si un párrafo suena a *"quien dibujó seis motores no sabía"*, el curso pierde a su
mejor personaje y al lector que hizo algo parecido.

Se escribe en este orden: la decisión con su mejor argumento; por qué era razonable entonces; qué pasó después, con
número; cuánto cuesta salir, con número; qué pregunta, hecha a tiempo, habría cambiado el resultado. Lo que nunca
aparece: "obviamente", "cualquiera habría visto", "error de novato".

---

## 3. 🗣️ Idioma y forma de la narrativa

- **Español latinoamericano neutro** para todo lo que no sea código o salida de terminal.
- **Los términos del oficio se quedan en inglés** cuando son el nombre real de la cosa: *dual write*, *outbox*,
  *CDC*, *replication slot*, *logical decoding*, *WAL*, *Debezium*, *topic*, *partition*, *offset*, *consumer
  group*, *consumer lag*, *at-least-once*, *exactly-once*, *idempotent consumer*, *dead letter queue*, *backpressure*,
  *schema registry*, *backfill*, *snapshot*, *PITR*, *RPO*, *RTO*, *runbook*, *bus factor*. Los que tienen traducción
  asentada —fuente de verdad, derivado, costura, tubería, consumidor, atraso, reconciliación, reconstrucción,
  restauración, factura, manual de guardia— se alternan con naturalidad. **No se inventa vocabulario.**
- **"La verdad"** es siempre PostgreSQL; **"derivado"**, todo lo que se puede reconstruir desde ella.
- **Markdown siempre**, sin HTML embebido. **Prosa antes que listas.** Una frase aislada por sección, dos si es larga.
- **Tablas solo para lo tabular y corto**: comparación de arquitecturas, la factura, la traducción entre lenguajes de
  consulta.
- **Diagramas en Mermaid** (D-12): las tres arquitecturas, el camino de un cambio por la costura, el restore
  coherente. Árboles de archivos y salidas en `text`.
- **Salida de terminal literal**, en `text` o `json`, sin recortar la parte incómoda (sobre todo el atraso del
  consumidor, el registro retenido por una ranura y la divergencia que encontró el reconciliador).
- **Encabezados con emoji, con moderación.**

---

## 4. 🎓 Pedagogía: cómo se explica

El público es senior, relacional de oficio y ya pasó por lite: **no explicar lo que ya sabe, y no dejar ambiguo nada
de lo que no.**

### 4.1 La regla del andamio

1. **El problema primero**, siempre en Palco: *"El precio de la platea cambia a las 23:00. La escritura en PostgreSQL
   pasa; la de MongoDB falla. ¿Cuántas entradas se venden al precio viejo antes de que alguien lo note, con escritura
   doble y con captura de cambios? Apúntalo antes de ejecutar."*
2. **El mecanismo después**: el nombre y la definición mínima.
3. **El comando o la consulta que corre**, con su salida real y la línea que importa señalada.

### 4.2 Del instinto se parte, no se reniega

- 🩻 **"Esto sí funciona igual"** — lo que se transfiere sin cambios del relacional: la transacción protege lo que
  está dentro de ella, el registro es la historia, la réplica atrasa, la copia no es un respaldo hasta que se
  restaura.
- 🪞 **"Tu instinto dice… y esta vez se equivoca"** — el relacional (*"la base es consistente"*), el de la
  conferencia (*"con Kafka cada mensaje llega una vez"*) o el que lite dejó demasiado firme (*"si uso captura de
  cambios, los derivados están al día"*). **Una por fase como mínimo.**
- ⚖️ **"Y aquí el instinto SQL tenía razón"** — las preguntas donde el veredicto va en la otra dirección: las
  recomendaciones de dos saltos, la puerta, la ficha que cabe en JSONB. Sin este recuadro el curso sonaría a folleto.

### 4.3 Nada de cajas negras prematuras

Primero `psql` contra la ranura de replicación, el tópico leído a mano y el desplazamiento de cada consumidor; después
el panel. Primero el reconciliador ejecutado sobre un rango; después el proceso programado. Si se habla del atraso, se
muestra el número.

### 4.4 Analogías, con fecha de caducidad

Una vez, para abrir la puerta, y se abandonan diciendo dónde se rompen. La más peligrosa del curso: **"un derivado es
como un índice"**. Se desmonta en el mismo párrafo: un índice se actualiza en la misma transacción; un derivado llega
después, puede no llegar, puede llegar dos veces, y su motor puede caerse sin que la verdad se entere.

### 4.5 Explica el porqué

Cada decisión lleva su porqué: por qué este patrón se gana un motor y aquel no, por qué captura de cambios y no
bandeja, por qué este consumidor es idempotente así, por qué esta factura.

### 4.6 Densidad calibrada

Un concepto nuevo por vez. Ninguna sección teórica supera las dos pantallas sin una consulta, una medición o un
diagrama. Reaparecen con otras palabras: la pregunta del curso, "¿cuál es la verdad?", "si no se reconstruye, no es
un derivado" y "la factura".

### 4.7 Cierra los bucles

Todo paréntesis abierto —*"esto lo pagamos en el bloque de la costura"*, *"deuda 💸"*— se cierra.

---

## 5. 💻 Código, comandos y archivos

> **Regla normativa:** todo lo que se ejecuta o se versiona va en inglés —archivos, rutas, variables,
> identificadores, tablas, colecciones, tópicos, eventos— y **todos los comentarios van en español con tildes**. Lo
> que ve un comprador, un productor o la puerta va en español.

- **Código ejecutable y mínimo**, que corre de punta a punta con las versiones fijadas.
- **Comentarios que explican el porqué**: `// idempotente por event_id: la tubería entrega al menos una vez` sí;
  `// procesa evento` no.
- **Bloques con su lenguaje declarado**: `ts`, `sql`, `json`, `bash`, `yaml`, `text`.
- **Un bloque, una idea.** **Nunca `foo`, `bar`, `evt1` ni `test1`**: todo usa Palco.
- **Todo consumidor declara su clave de idempotencia**, y toda escritura en un derivado sale de un evento, nunca del
  código de negocio (salvo en el villano, donde se muestra como lo que es).

### 5.1 Versiones fijadas

**Digest para las imágenes y archivo de bloqueo para las librerías y los conectores**, con la versión legible en un
comentario. **Ninguna versión se escribe de memoria**, y hasta la verificación previa ningún documento publica un
número de versión (§15). **Lo no verificado se dice con esas palabras**.

### 5.2 Los nombres del dominio

Fijos en todo el curso y en inglés. Hasta que exista el contrato de nombres, estos son los vigentes:

| En la narrativa | En PostgreSQL (la verdad) | En los derivados | Evento |
|---|---|---|---|
| evento, función | `events`, `performances` | colección `event_pages` (MongoDB); índice `events` (búsqueda) | `event.updated` |
| recinto, sector, ubicación | `venues`, `sections`, `seats` | — | — |
| aforo, reserva | `seat_holds` (con `SKIP LOCKED`) | claves `hold:*` y `avail:*` (Valkey) | `hold.created`, `hold.expired` |
| compra, entrada, pago | `orders`, `tickets`, `payments` | — | `order.paid` |
| precio | `price_tiers` | dentro de `event_pages` | `price.changed` |
| escaneo | `scans` | medición `gate_scans` (InfluxDB 3, villano) | `ticket.scanned` |
| recomendación | consulta de dos saltos | grafo de asistencia (Neo4j, villano) | — |
| liquidación | `settlements` | Parquet y DuckDB | — |
| bandeja de salida | `outbox` | tópicos `palco.<entidad>` | — |

**Tablas, colecciones, campos y eventos en `snake_case`, con los eventos como `entidad.verbo_en_pasado`**; tipos y
variables de TypeScript en `camelCase` y `PascalCase`. La misma entidad lleva el mismo nombre en todos los motores.
Una fase no renombra nada: si necesita algo nuevo, lo declara y se agrega aquí y en la historia.

### 5.3 El villano también va en inglés

El código del villano se nombra como estaba en Palco: `saveEvent()` con su segunda escritura en MongoDB, el contador
`avail:*` de Redis como fuente del aforo, `kafkaSearchSync.ts`, `redButton.ts` (el botón rojo) y los reportes de
`producerReports.sql` contra el principal. Su olor es **de arquitectura**: dos verdades que nadie firmó, una costura
sin medidor y una restauración que nunca se ensayó junta.

### 5.4 Nombres de archivo del curso

Fases `NN-slug.md`; apéndices `aNN-slug.md`; la historia `00-historia-de-palco.md`; documentos vivos en la raíz (§7).
Minúsculas y guiones, salvo `README.md`, `INSTINTOS.md`, `BENCHMARKS.md` y `FACTURA.md`.

---

## 6. 🧱 La plantilla de los documentos

> 🚧 **Preliminar:** la plantilla rígida de fase se fija con la propuesta de fases. Punto de partida, el mismo de los
> cursos anteriores de la ruta: una sola plantilla que modela **y** mide.

### 6.1 Encabezado obligatorio de fase

```markdown
# 🎟️ Fase 07 — La costura

> **Curso:** El Árbitro · Fase 07 de NN · Bloque III · **10 h**
> **Arquitectura:** {{A · B · C}} · **La verdad:** PostgreSQL `postgres@sha256:…`
> **Motores y piezas en esta fase:** {{Debezium `…@sha256:…` · tubería `…@sha256:…` · MongoDB · …}}
> **Carga:** {{preventa, compras por segundo, atraso inyectado}}
> **Depende de:** Fase 06 · **Habilita:** Fase 08
> **Fecha de verificación ejecutada:** DD/MM/AAAA
> **Objetivo:** …
```

El título nombra el dolor de Palco, no la herramienta.

### 6.2 Secciones de una fase (punto de partida)

1. Título y encabezado
2. 🧭 **Dónde estamos** — qué dejó la fase anterior, y el dolor de Palco que abre esta
3. 🎯 **Objetivos**, verificables
4. 🚫 **Qué NO entra todavía**, con destino
5. 🧩 **El modelo** — el patrón, su verdad, su derivado y el camino del cambio
6. 🪞 **La apuesta**, escrita antes de medir
7. 📐 **La medición**: la verdad contra el derivado, la forma, el tiempo y la línea de la factura
8. 💥 **El punto de rotura**, con volumen y mensaje literal
9. ⚖️ **Veredicto honesto: cuándo NO hacer esto**
10. ⚠️ **Errores comunes y diagnóstico**, con mensaje literal
11. 📋 **Checklist de validación**, ejecutable
12. 🧪 **Ejercicios** (§8)
13. 📚 **Referencias** (§10)
14. 🏁 **Resultado de la fase** y La señal de que quedó bien

Después, fuera de lo que lee el estudiante, puede ir **📌 Pendientes sugeridos**.

### 6.3 Cómo se presenta una medición

**Toda medición se publica con cinco datos**: qué se midió (la verdad contra el derivado y la forma primero), sobre
qué arquitectura y qué carga, con qué piezas, digest y configuración frente a qué alternativa, en qué máquina si hay
tiempos, y el comando exacto para reproducirla. **Siempre con la arquitectura, la carga de la preventa y el atraso de
la costura.**

```markdown
> 📐 **Medición — el precio que cambia en plena preventa** · arquitectura B, 2.000 compras/min, consumidor detenido
> 10 min · `postgres@sha256:…`, `debezium@sha256:…`, `mongo@sha256:…` frente a escritura doble · verificado el
> DD/MM/AAAA · {{máquina}}
>
> | camino | ventas a precio viejo | divergencia máxima | tiempo hasta converger | registro retenido | p50 | p95 | p99 |
> |---|---|---|---|---|---|---|---|
> | escritura doble | … | … | nunca | — | … | … | … |
> | bandeja de salida | … | … | … | — | … | … | … |
> | captura de cambios | … | … | … | … | … | … | … |
>
> Reproducir: `node scripts/measure.ts price-change --arch B --pause-consumer 10m`
```

**Los tiempos van con su dispersión** (mediana, p95 y p99, repeticiones y calentamiento declarados) y la máquina,
**y nunca sostienen solos un veredicto** (D-19). **La factura** se publica con el método de D-27 y sus supuestos a la
vista. Los costos de los gestionados llevan ☁️, la fuente y la fecha (D-22). La 🪞 apuesta se escribe antes y no se
edita.

---

## 7. 📐 Los tipos de documento y su coherencia

- **Fases**, **apéndices** y la **historia**, documento del lector y fuente de verdad narrativa: ningún dato de Palco
  se inventa en una fase.
- **Documentos vivos** en la raíz, que son producto: `INSTINTOS.md` (cada 🪞 con su medición), **`BENCHMARKS.md`**
  (toda medición publicada, con los cinco datos de §6.3), **`FACTURA.md`** (la factura de cada motor y de cada
  arquitectura, con el método de D-27, que crece fase a fase) y el catálogo de errores con su mensaje literal (si es
  apéndice o documento aparte, lo dice la propuesta de apéndices).
- **Los apéndices no repiten una fase, y viceversa: se enlazan.** **Una fase no cita el temario ni el plan.** 🗑️ **Los
  `_desechable-*` no se citan nunca.**
- **Git:** tags `fase-NN-<slug>`, prefijo de commit `fNN:`, ejercicios `fNN ejM: …` (D-09).

---

## 8. 🧪 Evaluación: ejercicios

- **Cantidad: 20 mínimo y 30 máximo por fase**, calibrada con *"¿cuántas cosas distintas enseña esta fase que se
  puedan comprobar por separado?"*.
- **La escala:** 🟢 reproducir · 🟡 aplicar el patrón a otra pieza de Palco · 🟠 combinar, diagnosticar, decidir · 🔴
  abierto o adversarial · 🔥 extra, fuera del mínimo.
- **Distribución ≈ 30 % 🟢, 30 % 🟡, 25 % 🟠, 15 % 🔴**, con margen; los bloques de la costura y de las fallas cargan
  hacia 🟠 y 🔴.
- **Al menos un tercio de diagnóstico o medición**: una ranura que nadie consume, un consumidor que no es idempotente,
  un evento que cambió de forma, un derivado que miente sin que nadie lo vea, un restore sin instante común; se pide
  reproducir, medir y explicar.
- **Predecir antes de ejecutar** en 🟠 y 🔴. **Cada ejercicio cierra con su criterio** (`Objetivo` o `Pregunta`).
  **Agrupados por dificultad**, con el conteo en el título.
- **Sin solución publicada** (D-05). **Taller global:** la plataforma en `src/`.
- **💀 Boss de bloque**, cuando el bloque lo admita: una preventa rota o un encargo completo de alguien de Palco (con
  nombre, de la historia §2), que cruza al menos dos fases y se entrega como artefacto.

---

## 9. 📏 Longitud y densidad

> 🚧 **Preliminar**, a fijar con la propuesta de fases. Punto de partida para una fase de 10 h: **4.000–5.000
> palabras de cuerpo**, contadas hasta el encabezado de 🧪 Ejercicios. Los apéndices son cortos, con índice de salto
> rápido, una tabla de "cuándo usar qué" y de 5 a 10 ejercicios de consulta.

---

## 10. 📚 Referencias y enlaces

### 10.1 Enlaces externos

**Orden de prioridad:** documentación oficial de la versión que usamos (PostgreSQL y su decodificación lógica,
Debezium, la tubería elegida, MongoDB, Valkey, el motor de búsqueda, DuckDB, Neo4j, InfluxDB); después los textos de
base sobre registros, captura de cambios y sistemas de datos derivados; después libros; después blogs y videos, con
escepticismo explícito ante los de parte interesada. **Siempre se advierte cuando un enlace apunta a otra versión**, y
con las licencias y los precios se cita la fecha. Cada URL se comprueba por código de estado en la sesión que la
escribe.

Cada fase cierra sus referencias con un **orden de lectura sugerido**: antes de ejecutar, durante y después.

### 10.2 Enlaces internos y anclas

Rutas relativas; anclas comprobadas; **ningún enlace a un documento que todavía no existe**.

### 10.3 Vigencia

Las secciones de referencias advierten que las URL y los contenidos cambian, que las garantías de las tuberías cambian
entre versiones, y que las licencias y los precios cambian: se cita la fecha.

---

## 11. 🧷 Vocabulario visual

**Marcadores de estado:** 💸 deuda intencional (con fase de pago) · 🔥 opcional · 🚧 fuera de alcance por ahora, con
destino · ☁️ tomado de documentación, no medido · 🧾 línea de la factura · 🟢🟡🟠🔴 dificultad · ⭐ valoración
bibliográfica, solo en referencias.

**Callouts en blockquote:** 📐 **Medición** (§6.3) · 🧾 **Factura**, el costo semanal de un motor con su método · 🪞
**Apuesta / instinto que falla** · 💥 **Punto de rotura** · ⚰️ **Autopsia** · ⚖️ **Veredicto honesto** y **"Y aquí el
instinto SQL tenía razón"** · 🩻 **Esto sí funciona igual** · 📖 **Traducción** entre lenguajes de consulta, en tabla ·
🧠 **Modelo mental** · ⚠️ **Advertencia** · 📝 **Nota de contexto** · 💡 **Truco** · 🩺 **Diagnóstico**, la consulta o
la salida que confirma o descarta una hipótesis.

**Secciones narrativas recurrentes:** *Dónde estamos* · *Detalles con intención* · *El patrón a memorizar* · *Prueba
de fuego* · *La señal de que quedó bien*.

---

## 12. ✅ Checklist antes de dar por cerrado un `.md`

```text
[ ] El encabezado está completo, con arquitectura, digest de cada pieza, carga y fecha de verificación
[ ] La fase abre con un dolor de Palco que está en la historia
[ ] Ningún dato de la empresa se inventó en la fase (si hacía falta, se agregó a la historia)
[ ] Nada de lo que Ruta NoSQL Lite ya enseñó se explicó de nuevo; ninguna remisión a sus fases ni a otros cursos
[ ] La fase enseña la decisión de integrar, no el tutorial de un motor
[ ] Todo número salió de una ejecución real; lo emulado o no verificado está declarado
[ ] Toda medición trae los cinco datos de §6.3, con arquitectura, carga y atraso de la costura
[ ] Toda divergencia trae la verdad contra el derivado; toda arquitectura, su línea en FACTURA.md
[ ] El monolito y la arquitectura de seis jugaron bien escritos, salvo lo que la historia declara roto
[ ] Todo consumidor declara su clave de idempotencia
[ ] Los costos de la nube llevan ☁️, fuente y fecha; las licencias, fecha
[ ] La apuesta se escribió antes de medir y no se editó después
[ ] El punto de rotura trae volumen exacto y mensaje literal
[ ] Hay un ⚖️ veredicto con la pérdida cuantificada, en las dos direcciones cuando toca
[ ] Ninguna autopsia juzga a una persona
[ ] Las mediciones, los errores, la factura y el 🪞 entraron en sus documentos vivos
[ ] Ejercicios: 20–30, agrupados, con conteo, un tercio de diagnóstico, cada uno con Objetivo o Pregunta
[ ] Los diagramas están en Mermaid; los árboles y salidas, en text o json
[ ] Tuteo en todo el documento; cero voseo, cero "usted"
[ ] Código en inglés, comentarios en español con tildes
[ ] Ningún enlace a un documento que no existe; grep -ln "_desechable-" *.md no devuelve nada
```

---

## 13. ⚖️ Excepciones declaradas

1. **Ruta NoSQL Lite como prerrequisito** (D-14) → no se explican las familias ni lo básico de la costura → los da
   lite, y repetirlos sería el curso que el lector ya hizo.
2. **Los ejercicios no traen solución publicada** (D-05) → el método del curso es apostar y medir antes de mirar, y
   cada ejercicio trae su criterio.
3. **Cada motor no se enseña a fondo** (D-35) → el objeto del curso es la integración; la profundidad vive en la
   costura.

Todo lo demás del `CLAUDE.md` aplica tal cual.

---

## 14. 🧪 Laboratorio

- **Docker Compose es el camino principal**; cada receta trae su equivalente en Podman. **Aquí no se enseña Docker.
  Sin Kubernetes.**
- **Un perfil de Compose por arquitectura** (`arch-a`, `arch-b`, `arch-c`), **una a la vez**; la C con memoria mínima
  por motor, y por partes si no cabe entera (D-20).
- **Servicios nombrados por papel** (`verdad`, `ficha`, `aforo`, `busqueda`, `tuberia`, `captura`), para que cambiar
  de motor no rompa los comandos escritos.
- **Redis se reemplaza por Valkey** y se dice (D-33).
- **Datos sintéticos con semilla fija** y cada compra verdadera conocida; el simulador de preventa (D-21, D-30, D-31).
- **Las pruebas de la producción** corren en contenedores etiquetados con el curso y en puertos altos aleatorios; el
  código de las sesiones va a `zz-code/` con su README.

---

## 15. 📌 Pendientes que afectan a esta guía

- **La plantilla rígida de fase (§6.2) y las longitudes (§9)** se fijan con la propuesta de fases. Todas las
  decisiones del alcance están cerradas (07/10/2026).
- **El diccionario de términos y el contrato de nombres** se escriben después de la propuesta de fases; hasta
  entonces mandan §3 y §5.2.
- **Versiones, digests, conectores y licencias sin fijar** hasta la verificación previa; lo mismo la tubería (D-25) y
  si la arquitectura C cabe entera en 16 GB (D-20).
- **El formato de `FACTURA.md`** se fija con la propuesta de fases, a partir del método de D-27.
- **El recorte contra lite** se revisa cuando sus fases 23 a 25 estén escritas.
- **El verificador del curso** se copia de `zz-instrucciones/herramientas/` y se ajusta cuando la plantilla de fase
  esté fijada.
