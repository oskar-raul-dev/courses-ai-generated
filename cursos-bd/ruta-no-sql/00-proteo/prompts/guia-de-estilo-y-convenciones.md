# ✍️ Guía de estilo, tono y convenciones
## Proteo — el modelo documental a fondo

> **Qué es este documento:** la fuente de verdad editorial del curso: **cómo** se escribe. Cualquier
> sesión que produzca un `.md` de Proteo la sigue, para que todas las fases se lean como escritas por la
> misma mano y apunten al mismo sitio: **que el lector decida qué parte de un sistema vota documento y lo
> defienda con números propios, también cuando el motor crece.**
> **Vigencia:** 2026-10-06. **Cerrada salvo lo que depende de la propuesta de fases**: la plantilla
> rígida de fase (§6.2) y las longitudes (§9), que se fijan con ella (§15).
> **Herencia:** se escribió con la guía de Ruta NoSQL Lite como modelo, porque el lector viene de ese
> curso y espera su tono, su forma de medir y su honestidad. Diverge en: un solo dominio y una sola
> familia, una sola plantilla de fase en lugar de las fases A y B, Mermaid en lugar de ASCII, tiempos
> permitidos con dispersión, y la profundidad full geek. La guía de agosto (`_desechable-guia-de-estilo-v1.md`)
> queda de consulta.
> **Precedencia.** Por encima de esta guía solo está [`alcance-del-proyecto.md`](alcance-del-proyecto.md),
> que decide **qué** enseña el curso. Por debajo van el contrato de nombres, el diccionario, las
> propuestas, las plantillas y los prompts, que se actualizan después y nunca al revés. El `CLAUDE.md`
> del repositorio aplica en todo lo que este curso no haya declarado como excepción (§13).

Si dudas entre dos formas de escribir algo, gana la que le sirva más a alguien que el lunes tiene que
explicarle a una junta por qué el catálogo se va a MongoDB y la liquidación no.

---

## 1. 🧭 Principio rector

**Todo lo que se escribe apunta a que alguien decida con criterio y lo pueda defender con números
propios, incluido lo que pasa dentro del motor.**

No enseñamos MongoDB como producto. No formamos administradores. Formamos la capacidad de mirar un
dominio, reconocer qué parte de él se lee como un documento, modelarla bien, medirla contra el
relacional bien jugado y saber qué le cuesta al motor sostenerla cuando crece.

El filtro para cada párrafo: **¿esto ayuda a modelar, a medir, a diagnosticar o a decidir?** Si no,
sobra. Aunque esté muy bien escrito.

> 🧠 **Primero la forma, después el reloj.** Un veredicto de este curso se sostiene sobre lo que se
> examinó, lo que se escribió y lo que se movió; el tiempo lo acompaña, no lo reemplaza.

### 1.1 Qué NO es este curso

No es un curso de MongoDB desde cero, ni una preparación de certificación, ni un curso de
administración. No repite Ruta NoSQL Lite: lo que lite enseñó del modelo documental se **usa** sin
volver a explicarlo, y cuando hace falta recordarlo se hace en una línea.

### 1.2 Requisitos y autocontención

El lector viene de lite o sabe lo equivalente (alcance §4). Lo publicado nombra Ruta NoSQL Lite solo como
requisito de entrada, en el README y en la primera fase. **No usa su contenido**: no remite a sus fases,
no reutiliza sus ejemplos, sus datos ni sus mediciones, y si el curso necesita algo que lite enseñó, lo
da por sabido o lo dice aquí con sus propias palabras y con Mercado Ceibo (D-03). Ningún documento publicado cita otros
cursos de la ruta ni el `CLAUDE.md` del repositorio.

---

## 2. 🎤 Tono

**Semiformal, cálido y directo**, con humor cuando cae bien: un colega que ya pasó por los Días Ceibo y
te lo cuenta con paciencia.

- **Tuteo latinoamericano, siempre.** *"Levanta el replica set y mira cuánto oplog te queda"*. Nada de
  voseo (*"fijate"*, *"levantá"*), nada de "usted", nada de impersonal permanente.
- **Semiformal.** Frases completas, puntuación correcta, cero abreviaturas de mensajería.
- **Humor seco y con moderación.** Máximo un chiste por sección, y si no fluye solo, se borra. El blanco
  del humor es la situación (el nocturno que termina a las 5:40), nunca una persona.
- **Cálido sin condescendencia.** El lector es senior y ya hizo lite: se le explica con cero ambigüedad
  lo que no sabe y nada de lo que sabe.
- **Honesto sobre lo feo.** Si PostgreSQL empata o gana en la pregunta que acabamos de medir, se dice con
  esas palabras y con el número delante.

### 2.1 El tono de las autopsias

⚰️ Una autopsia se escribe sobre una **decisión**, jamás sobre una persona. El EAV lo eligió Hernán en
2019, con buenos argumentos, y Hernán es quien contrató al lector para medirlo: si un párrafo suena a
*"quien eligió el EAV no sabía"*, el curso pierde a su mejor personaje y al lector que eligió algo
parecido.

Se escribe en este orden:

1. La decisión, en la voz de quien la tomó y con su mejor argumento.
2. Por qué era razonable **en ese momento** y con esa información.
3. Qué pasó después, con número.
4. Cuánto cuesta salir, con número.
5. Qué pregunta, hecha a tiempo, habría cambiado el resultado.

Lo que nunca aparece: "obviamente", "cualquiera habría visto", "error de novato".

---

## 3. 🗣️ Idioma y forma de la narrativa

- **Español latinoamericano neutro**, técnico y claro, para todo lo que no sea código o salida de
  terminal.
- **Los términos del oficio se quedan en inglés** cuando son el nombre real de la cosa: *replica set*,
  *oplog*, *shard*, *shard key*, *chunk*, *balancer*, *checkpoint*, *write concern*, *read concern*,
  *change stream*, *resume token*, *working set*, *upsert*, *bucket pattern*. Los que tienen traducción
  asentada —índice, consulta, colección, agregación, partición, réplica— se alternan con naturalidad.
  **No se inventa vocabulario.** El criterio completo irá en el diccionario de términos.
- **Markdown siempre**, sin HTML embebido.
- **Prosa antes que listas.** Un párrafo que explica *por qué* vale más que cinco viñetas que enumeran
  *qué*.
- **Nada de prosa telegrama.** Una frase aislada por sección, dos si la sección es larga.
- **Tablas solo para lo tabular y corto**: traducción, matriz de decisión, versiones, resultados de una
  medición. Tres o cuatro columnas como máximo.
- **Diagramas en Mermaid** (D-12): el flujo de cambios, la forma de un documento frente a sus filas EAV,
  el reparto de un clúster particionado, la elección en un replica set. Los árboles de archivos y las
  salidas siguen en `text`.
- **Salida de terminal literal**, en bloque `text`, sin embellecer ni recortar la parte incómoda.
- **Encabezados con emoji, con moderación**: uno por sección numerada, casi ninguno en subsecciones.

---

## 4. 🎓 Pedagogía: cómo se explica

El público es senior, relacional de oficio y ya pasó por lite. La regla: **no explicar lo que ya sabe, y
no dejar ambiguo nada de lo que no.**

### 4.1 La regla del andamio

Todo concepto nuevo, en tres tiempos y en este orden:

1. **El problema primero**, siempre en Mercado Ceibo: *"Repuestos Paredes subió doce mil repuestos.
   ¿Cuántas entradas de oplog genera eso, y cuánto historial te queda para un nodo que se cayó?
   Apúntalo antes de ejecutar."*
2. **El mecanismo después**: el nombre y la definición mínima, lo justo para usarlo hoy.
3. **El comando que corre**, con su salida real y el campo que importa señalado.

### 4.2 Del instinto se parte, no se reniega

El lector trae dos instintos: el relacional y el que le dejó lite. Las dos micro-secciones recurrentes
los honran antes de corregirlos:

- 🩻 **"Esto sí funciona igual"** — lo que se transfiere sin cambios: un índice sigue siendo un índice, un
  plan sigue siendo un plan, el N+1 sigue siendo el N+1.
- 🪞 **"Tu instinto dice… y esta vez se equivoca"** — el punto exacto donde el modelo mental se rompe, con
  la medición que lo prueba. Puede ser el instinto relacional (*"una tabla de atributos es la forma
  normal de hacer esto"*) o uno que lite dejó demasiado firme (*"si todo se lee junto, embebe todo"*).
  **Una por fase como mínimo.**
- ⚖️ **"Y aquí el instinto SQL tenía razón"** — propio de Proteo: las preguntas donde el veredicto va en
  la otra dirección (la ficha por identificador, donde JSONB empata; la liquidación, donde PostgreSQL
  gana). Sin este recuadro el curso sonaría a folleto de MongoDB.

### 4.3 Nada de cajas negras prematuras

Primero el mecanismo, después la comodidad: primero el driver nativo, nunca un ODM; primero
`db.serverStatus()` y `rs.status()` a mano, después la herramienta que los dibuja. En el bloque del motor
por dentro esto es más estricto: si se habla de la caché de WiredTiger, se muestra el campo de
`serverStatus` que la mide.

### 4.4 Analogías, con fecha de caducidad

Una vez, para abrir la puerta, y se abandonan diciendo dónde se rompen. La más peligrosa del curso:
**"el EAV es un documento guardado en filas"**. Se desmonta en el mismo párrafo: el documento conserva
los tipos, la localidad y la unidad de escritura; el EAV pierde las tres.

### 4.5 Explica el porqué

Cada decisión de modelado lleva su porqué, aunque sea media línea: por qué este patrón y no el otro, por
qué este índice compuesto en este orden, por qué esta clave de partición. Un paso sin justificación no se
puede adaptar a otro dominio.

### 4.6 Densidad calibrada

Un concepto nuevo por vez. Ninguna sección teórica supera las dos pantallas sin un comando, una medición
o un diagrama. Repetir lo importante está bien: la pregunta del curso, la unidad de lectura, la frontera
transaccional y "PostgreSQL bien jugado es un rival serio" reaparecen con otras palabras.

### 4.7 Cierra los bucles

Todo paréntesis abierto —*"esto lo pagamos en la fase de los derivados"*, *"deuda 💸"*— se cierra en algún
documento del curso.

---

## 5. 💻 Código, comandos y archivos

> **Regla normativa:** todo lo que se ejecuta o se versiona va en inglés —archivos, rutas, variables,
> identificadores, colecciones, campos, tablas— y **todos los comentarios van en español con tildes**.
> Los mensajes que ve una persona usuaria también van en español: la clave en inglés, el valor en español.

- **Código ejecutable y mínimo**: el fragmento más pequeño que muestra el punto, pero que corre de punta a
  punta con las versiones fijadas.
- **Comentarios que explican el porqué**: `// el candado vive en el filtro: si qty ya bajó de 1, no
  coincide` sí; `// decrementa` no.
- **Bloques con su lenguaje declarado**: `ts`, `javascript` (para `mongosh`), `sql`, `yaml`, `bash`,
  `text` para la salida.
- **Un bloque, una idea.**
- **Nunca `foo`, `bar` ni `test1`**: todo ejemplo usa Mercado Ceibo con datos que parezcan reales.

### 5.1 Versiones fijadas

- **Digest, no tag**, con el tag legible en un comentario al lado.
- **Ninguna versión se escribe de memoria**: se copia de la ejecución real y el documento declara su fecha
  de verificación. Hasta la verificación previa, ningún documento publica un número de versión (§15).
- **Lo no verificado se dice con esas palabras**, donde el lector lo necesita. Todo lo de Amazon DocumentDB
  va así.

### 5.2 Los nombres del dominio

Fijos en todo el curso y en inglés. Hasta que exista el contrato de nombres, estos son los vigentes (su
significado está en la historia):

| En la narrativa | En el código |
|---|---|
| producto, ficha | `product`, `productCard` (la tabla de 2024: `product_card`) |
| vertical | `vertical` (`books`, `electronics`, `fashion`, `grocery`, `motoParts`) |
| vendedor, oferta | `seller`, `offer` (el precio y las existencias de un vendedor para un producto) |
| variante | `variant` |
| bodega, existencias | `warehouse`, `stock` |
| compatibilidad | `fitment` (marca, modelo y rango de años) |
| reseña | `review` |
| pedido, línea | `order`, `orderLine` |
| carrito | `cart` |
| liquidación | `settlement`, `settlementLine` |
| Días Ceibo | `ceiboDays` (solo en datos y escenarios) |

- **`camelCase` para campos** en MongoDB y Couchbase; **`snake_case`** en PostgreSQL, que es lo idiomático
  allí. La diferencia es deliberada y se explica una vez.
- **Colecciones y tablas en plural**: `products`, `reviews`, `orders`; `product`, `attribute` y
  `attribute_value` en el EAV conservan su nombre heredado de Voltio, en singular, porque así se llamaban.
- Una fase no renombra una entidad; si necesita una nueva, la declara y se agrega aquí y en la historia.

### 5.3 El villano también va en inglés

El EAV de Voltio se nombra en inglés (`attribute`, `attribute_set`, `attribute_value` con `value_text`,
`value_int`, `value_decimal`, `value_date`). Su olor es **estructural** —una fila por atributo, tipos
repartidos en columnas, una ficha que pide catorce `JOIN`—, no de idioma, y así el ejercicio de detectarlo
huele estructura y no vocabulario.

### 5.4 Nombres de archivo del curso

Fases `NN-slug.md` con dos dígitos; apéndices `aNN-slug.md`; la historia `00-historia-de-mercado-ceibo.md`;
documentos vivos en la raíz (§7). Todo en minúsculas y con guiones, salvo los que el repositorio fija en
mayúsculas (`README.md`, `INSTINTOS.md`).

---

## 6. 🧱 La plantilla de los documentos

> 🚧 **Preliminar:** la plantilla rígida de fase se fija con la propuesta de fases. Lo de abajo es el
> punto de partida, tomado de la fase A y la fase B de lite y unido en una sola, porque en Proteo cada
> fase modela **y** mide.

### 6.1 Encabezado obligatorio de fase

```markdown
# 🍃 Fase 05 — Las existencias: diecisiete vendidas, nueve en la bodega

> **Curso:** Proteo · Fase 05 de NN · Bloque II · **10 h**
> **Motor:** MongoDB `mongo@sha256:…` · **Línea base:** PostgreSQL `postgres@sha256:…`
> **Rivales en esta fase:** {{Couchbase · ninguno}}
> **Volumen:** {{los del laboratorio}}
> **Depende de:** Fase 04 · **Habilita:** Fase 06
> **Fecha de verificación ejecutada:** DD/MM/AAAA
> **Objetivo:** …
```

El título es descriptivo y con carácter, y nombra el dolor de Mercado Ceibo, no el producto.

### 6.2 Secciones de una fase (punto de partida)

1. Título y encabezado
2. 🧭 **Dónde estamos** — qué dejó la fase anterior, y el dolor de Mercado Ceibo que abre esta
3. 🎯 **Objetivos**, verificables
4. 🚫 **Qué NO entra todavía**, con destino
5. 🧩 **El modelo** — el grueso: modelar, con el porqué de cada decisión
6. 🪞 **La apuesta**, escrita antes de medir
7. 📐 **La medición** contra la línea base y, cuando toca, contra Couchbase
8. 💥 **El punto de rotura**, con volumen y mensaje literal
9. ⚖️ **Veredicto honesto: cuándo NO hacer esto**
10. ⚠️ **Errores comunes y diagnóstico**, con mensaje literal
11. 📋 **Checklist de validación**, ejecutable
12. 🧪 **Ejercicios** (§8)
13. 📚 **Referencias** (§10)
14. 🏁 **Resultado de la fase** y La señal de que quedó bien

Después de la última sección, fuera de lo que lee el estudiante, puede ir **📌 Pendientes sugeridos**.

### 6.3 Cómo se presenta una medición

Normativo: una medición mal presentada es peor que ninguna, porque parece evidencia. **Toda medición se
publica con cinco datos**: qué se midió (en forma estructural primero), sobre qué volumen, con qué motor
y digest frente a qué línea base, en qué máquina si hay tiempos, y el comando exacto para reproducirla.

```markdown
> 📐 **Medición — la ficha de un repuesto, lectura completa** · 400 k productos ·
> `mongo@sha256:…` frente a `postgres@sha256:…` · verificado el DD/MM/AAAA · {{máquina}}
>
> | | documentos o filas examinados | devueltos | viajes | p50 | p95 |
> |---|---|---|---|---|---|
> | documento | 1 | 1 | 1 | … | … |
> | JSONB (`product_card`) | 1 | 1 | 1 | … | … |
> | EAV | 1 + 38 + … | 1 | 1 | … | … |
>
> Reproducir: `node scripts/measure.ts card-read --volume 400k`
```

**Los tiempos van con su dispersión** (mediana y p95 como mínimo, el número de repeticiones y el
calentamiento declarados) **y nunca sostienen solos un veredicto** (D-20). La 🪞 apuesta se escribe antes
y no se edita; si se pierde, se cuenta entera.

---

## 7. 📐 Los tipos de documento y su coherencia

- **Fases**, **apéndices** y la **historia**, que es documento del lector y fuente de verdad narrativa:
  ningún dato de Mercado Ceibo se inventa en una fase; si hace falta, se agrega primero a la historia.
- **Documentos vivos** en la raíz, que crecen durante todo el curso y son producto: `INSTINTOS.md` (cada 🪞
  con su medición), **`BENCHMARKS.md`** (toda medición publicada, con los cinco datos de §6.3, D-20) y
  el catálogo de errores con su mensaje literal (si es apéndice o documento aparte lo dice la propuesta
  de apéndices).
- **Los apéndices no repiten una fase, y viceversa: se enlazan.**
- **Una fase no cita el temario ni el plan**: cita otra fase, un apéndice o la historia.
- 🗑️ **Los `_desechable-*` no se citan nunca** desde ningún documento del curso.
- **Git:** tags `fase-NN-<slug>`, prefijo de commit `fNN:`, ejercicios `fNN ejM: …` (D-09).

---

## 8. 🧪 Evaluación: ejercicios

- **Cantidad: 20 mínimo y 30 máximo por fase**, calibrada con *"¿cuántas cosas distintas enseña esta fase
  que se puedan comprobar por separado?"*. Subir de 20 a 28 solo vale si los ocho nuevos comprueban algo
  que ninguno de los veinte comprobaba.
- **La escala:**

  | | Nivel | Qué pide |
  |---|---|---|
  | 🟢 | Fácil | Reproducir lo que la fase acaba de mostrar |
  | 🟡 | Intermedio | Aplicar el patrón a otra vertical o a otra parte de Mercado Ceibo |
  | 🟠 | Difícil | Combinar patrones, diagnosticar, decidir entre alternativas |
  | 🔴 | Muy difícil | Abierto o adversarial: algo roto que hay que razonar |
  | 🔥 | Extra | Ampliación fuera del alcance base; no cuenta para el mínimo |

- **Distribución ≈ 30 % 🟢, 30 % 🟡, 25 % 🟠, 15 % 🔴**, con margen; en el bloque del motor por dentro carga
  hacia 🟠 y 🔴. Dos fases seguidas con el reparto idéntico son señal de que se copió.
- **Al menos un tercio son de diagnóstico o de medición**: se entrega una ficha mal modelada, un índice
  que no se usa, una clave de partición con punto caliente, un nodo atrasado, y se pide reproducir, medir
  y explicar.
- **Predecir antes de ejecutar** en 🟠 y 🔴.
- **Cada ejercicio cierra con su criterio**: una línea `**Objetivo:**` o una `**Pregunta:**` que solo se
  responde habiéndolo hecho. Nunca "modela la colección" a secas.
- **Agrupados por dificultad**, con el conteo en el título de la sección y el rango en cada grupo.
- **Sin solución publicada** (D-05): el criterio de cada ejercicio es lo que permite autoevaluarse.
- **Taller global:** el backend de Mercado Ceibo en `src/`, que crece fase a fase.
- **💀 Boss de bloque**, cuando el bloque lo admita: empieza con un sistema roto o un encargo completo de
  alguien de Mercado Ceibo (con nombre, de la historia §2), cruza al menos dos fases y se entrega como
  artefacto. Si cabe en tres líneas, era un 🔴. No cuenta para el mínimo de ejercicios.

---

## 9. 📏 Longitud y densidad

> 🚧 **Preliminar**, a fijar con la propuesta de fases. Punto de partida, el de lite para una fase de
> 10 h: **4.000–5.000 palabras de cuerpo**, contadas hasta el encabezado de 🧪 Ejercicios. El aparato de
> ejercicios va encima. Los apéndices son cortos, con índice de salto rápido, una tabla de "cuándo usar
> qué" y de 5 a 10 ejercicios de consulta.

---

## 10. 📚 Referencias y enlaces

### 10.1 Enlaces externos

**Orden de prioridad:** documentación oficial de la versión que usamos; después especificaciones, papers
y documentación de arquitectura (la de WiredTiger, la de replicación y la de partición de MongoDB; el
modelo de datos de Couchbase); después libros; después blogs y videos. **Siempre se advierte cuando un
enlace apunta a otra versión.** Formato: URL completa, título y una nota de qué cubre y por qué vale la
pena. Cada URL se comprueba por código de estado en la sesión que la escribe; aterrizar en la portada
cuenta como roto.

Fuentes base, por comprobar en la verificación previa: la documentación de MongoDB de la versión fijada,
la de PostgreSQL (tipos JSON, índices GIN), la de Couchbase Server (SQL++), la de Amazon DocumentDB (sus
diferencias funcionales con MongoDB), la de Meilisearch, la de Valkey y la de Express 5.

Cada fase cierra sus referencias con un **orden de lectura sugerido**: antes de ejecutar, durante y
después.

### 10.2 Enlaces internos y anclas

Rutas relativas; anclas comprobadas; **ningún enlace a un documento que todavía no existe**: la mención va
en prosa y se anota como deuda en el plan.

### 10.3 Vigencia

Las secciones de referencias advierten que las URL y los contenidos cambian, y que la documentación de
estos productos suele cubrir solo la última versión.

---

## 11. 🧷 Vocabulario visual

**Marcadores de estado:** 💸 deuda intencional (con fase de pago) · 🔥 opcional · 🚧 fuera de alcance por
ahora, con destino · 🟢🟡🟠🔴 dificultad · ⭐ valoración bibliográfica, solo en referencias.

**Callouts en blockquote:**

- 📐 **Medición** (§6.3), el más importante del curso.
- 🪞 **Apuesta / instinto que falla.**
- 💥 **Punto de rotura.**
- ⚰️ **Autopsia** (§2.1), sobre todo la del EAV.
- ⚖️ **Veredicto honesto**, y **"Y aquí el instinto SQL tenía razón"** (§4.2).
- 🩻 **Esto sí funciona igual.**
- 📖 **Traducción** SQL ↔ MQL ↔ SQL++ de Couchbase, lado a lado, en tabla.
- 🧠 **Modelo mental.** · ⚠️ **Advertencia.** · 📝 **Nota de contexto.** · 💡 **Truco.** · 🩺 **Diagnóstico**,
  el comando que confirma o descarta una hipótesis.
- ☁️ **No verificado**: lo que se dice de Amazon DocumentDB, desde su documentación.

**Secciones narrativas recurrentes:** *Dónde estamos* · *Detalles con intención* · *El patrón a
memorizar* · *Prueba de fuego* · *La señal de que quedó bien*.

---

## 12. ✅ Checklist antes de dar por cerrado un `.md`

```text
[ ] El encabezado está completo, con motor, digest y fecha de verificación
[ ] La fase abre con un dolor de Mercado Ceibo que está en la historia
[ ] Ningún dato de la empresa se inventó en la fase (si hacía falta, se agregó a la historia)
[ ] Nada de lo que Ruta NoSQL Lite ya enseñó se explicó de nuevo; ninguna remisión a sus fases
[ ] Todo número salió de una ejecución real; lo no verificado (DocumentDB) está declarado
[ ] Toda medición trae los cinco datos de §6.3; los tiempos, con mediana y p95
[ ] La apuesta se escribió antes de medir y no se editó después
[ ] El punto de rotura trae volumen exacto y mensaje literal
[ ] PostgreSQL aparece en su mejor versión (EAV serio, JSONB con GIN), no como adorno
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

El `CLAUDE.md` permite apartarse de sus defaults **si se nombra la regla y se dice por qué**:

1. **Ruta NoSQL Lite como prerrequisito** (D-14) → el curso no explica los fundamentos del modelo documental
   → los da lite, y repetirlos sería el curso que el lector ya hizo.
2. **Amazon DocumentDB no se mide** (D-16) → se describe desde su documentación con ☁️ → medirlo cuesta
   dinero; la regla de no publicar sin ejecutar se cumple declarándolo.
3. **Los ejercicios no traen solución publicada** (D-05) → el método del curso es apostar y medir antes de
   mirar, y cada ejercicio trae su criterio.

Todo lo demás del `CLAUDE.md` aplica tal cual: idioma, tono, estructuras recurrentes, convenciones de
markdown, nombres de archivo y flujo de git.

---

## 14. 🧪 Laboratorio

- **Docker Compose es el camino principal**; cada receta trae su equivalente en Podman, y las diferencias
  que muerden se explican una vez, en el apéndice del laboratorio. **Aquí no se enseña Docker**: más de dos
  párrafos de contenedores es otro curso. **Sin Kubernetes.**
- **Perfiles de Compose** para no pasar de 16 GB: MongoDB, PostgreSQL y el arnés siempre; Couchbase,
  Meilisearch y Valkey cuando la fase los pide (D-21, D-22).
- **Datos sintéticos con semilla fija** y volumen parametrizable, el mismo catálogo semántico en cada forma,
  más un lote de Excel "de vendedor" para la carga sucia (D-24).
- **MongoDB en replica set desde la primera fase** (D-25); el clúster particionado aparece solo en su
  bloque y se apaga al terminarlo.
- **Servicios nombrados por papel y no por producto** (`documental`, `relacional`, `busqueda`, `cache`),
  para que cambiar de motor no rompa los comandos escritos.
- **Las pruebas de la producción** corren en contenedores etiquetados con el curso y en puertos altos
  aleatorios; el código de las sesiones va a `zz-code/` con su README.

---

## 15. 📌 Pendientes que afectan a esta guía

- **La plantilla rígida de fase (§6.2) y las longitudes (§9)** se fijan con la propuesta de fases. Todas
  las decisiones del alcance que tocaban esta guía están cerradas (06/10/2026).
- **El diccionario de términos y el contrato de nombres** se escriben después de la propuesta de fases;
  hasta entonces mandan §3 y §5.2 de esta guía.
- **Versiones y digests sin fijar** hasta la verificación previa; ningún documento publica un número de
  versión antes.
- **El verificador del curso** (`verificar-corpus.py` y `verificador_base.py`) se copia de
  `zz-instrucciones/herramientas/` y se ajusta cuando la plantilla de fase esté fijada.
