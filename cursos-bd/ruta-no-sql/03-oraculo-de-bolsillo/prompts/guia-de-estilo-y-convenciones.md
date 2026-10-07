# ✍️ Guía de estilo, tono y convenciones
## Oráculo de Bolsillo — el modelo vectorial a fondo

> **Qué es este documento:** la fuente de verdad editorial del curso: **cómo** se escribe. Cualquier
> sesión que produzca un `.md` de Oráculo de Bolsillo la sigue, para que todas las fases se lean como
> escritas por la misma mano y apunten al mismo sitio: **que el lector decida dónde viven los vectores y
> cómo se sabe que lo recuperado es correcto, permitido y comprobable, y lo defienda con números
> propios.**
> **Vigencia:** 2026-10-06. **Cerrada salvo lo que depende de la propuesta de fases**: la plantilla rígida
> de fase (§6.2) y las longitudes (§9), que se fijan con ella (§15).
> **Herencia:** se escribió con la guía de Ruta NoSQL Lite y las de Proteo, Portalón y Cristalería como
> modelo, porque es la misma ruta y el lector viene de lite. Diverge de lite en: un solo dominio y una
> sola familia, una sola plantilla de fase, Mermaid, tiempos permitidos con dispersión, la profundidad
> full geek y **la calidad de la recuperación como primera medida**. La guía de agosto
> (`_desechable-guia-de-estilo-v1.md`) queda de consulta.
> **Precedencia.** Por encima solo está [`alcance-del-proyecto.md`](alcance-del-proyecto.md). Por debajo
> van el contrato de nombres, el diccionario, las propuestas, las plantillas y los prompts. El `CLAUDE.md`
> del repositorio aplica en todo lo que este curso no haya declarado como excepción (§13).

Si dudas entre dos formas de escribir algo, gana la que le sirva más a alguien que el lunes tiene que
explicarle a un comité de socios por qué el Oráculo ya no puede citar mal ni mostrar lo que no debe.

---

## 1. 🧭 Principio rector

**Todo lo que se escribe apunta a que alguien decida con criterio dónde viven los vectores y cómo se
recupera con ellos, y lo pueda defender con números propios, incluido lo que pasa dentro del índice.**

No enseñamos un motor vectorial como producto ni enseñamos a escribir prompts. Formamos la capacidad de
mirar un sistema de recuperación, saber medir si devuelve lo que debe, ver dónde está la costura con la
base de verdad, dimensionar el índice y saber qué hace cuando lo aprietan.

El filtro para cada párrafo: **¿esto ayuda a recuperar mejor, a medir, a diagnosticar o a decidir?** Si
no, sobra. El modelo de lenguaje es contexto, no tema: un párrafo sobre cómo redacta la respuesta casi
siempre sobra.

> 🧠 **Primero si es correcto, después si es rápido.** En este modelo un resultado rápido y equivocado es
> peor que ninguno —es una cita falsa en un juzgado—. Por eso un tiempo nunca se publica sin su recall, y
> una comparación de motores se hace al mismo recall, no a la misma configuración.

### 1.1 Qué NO es este curso

No es un curso de embeddings desde cero, ni un tutorial de RAG, ni de modelos de lenguaje, ni de
tecnología legal. No repite Ruta NoSQL Lite: lo que lite enseñó de vectorial se **usa** sin volver a
explicarlo.

### 1.2 Requisitos y autocontención

Lo publicado nombra Ruta NoSQL Lite **solo como requisito de entrada**, en el README y en la primera
fase. **No usa su contenido**: no remite a sus fases, no reutiliza sus ejemplos, sus datos ni sus
mediciones; si el curso necesita algo que lite enseñó, lo da por sabido o lo dice con sus propias
palabras y con Valdivieso (D-03). Ningún documento publicado cita otros cursos de la ruta ni el
`CLAUDE.md` del repositorio.

---

## 2. 🎤 Tono

**Semiformal, cálido y directo**, con humor cuando cae bien: un colega que estuvo en el comité el lunes
después de la semana de la casación y te lo cuenta con paciencia.

- **Tuteo latinoamericano, siempre.** *"Levanta la muralla y cuenta cuántas consultas la atraviesan antes
  del cron"*. Nada de voseo, nada de "usted", nada de impersonal permanente.
- **Semiformal.** Frases completas, cero abreviaturas de mensajería.
- **Humor seco y con moderación.** Máximo un chiste por sección; el blanco es la situación (el "esto lo
  hace todo el mundo" de Álvaro), nunca una persona.
- **Cálido sin condescendencia.** El lector es senior y ya hizo lite.
- **Honesto sobre lo feo.** Si Qdrant gana, si el reranker no compra nada en este corpus, si la búsqueda
  léxica sola habría bastado, se dice con esas palabras y con el número delante.
- **Sobrio con el derecho.** El curso no opina sobre derecho ni sobre ningún caso: los documentos son
  datos y el estudio es el contexto.

### 2.1 El tono de las autopsias

⚰️ Una autopsia se escribe sobre una **decisión**, jamás sobre una persona. El motor con su cron lo aprobó
Renato, con buenos argumentos, y el sistema documental —también suyo— es la mejor decisión de la casa. La
cita la copió Mariela, que confió en una herramienta que el estudio le dio. Si un párrafo suena a *"quien
copió los permisos de noche no sabía"* o *"quien no revisó la cita fue descuidada"*, el curso pierde a sus
mejores personajes y al lector que hizo algo parecido.

Se escribe en este orden: la decisión con su mejor argumento; por qué era razonable entonces; qué pasó
después, con número; cuánto cuesta salir, con número; qué pregunta, hecha a tiempo, habría cambiado el
resultado. Lo que nunca aparece: "obviamente", "cualquiera habría visto", "error de novato".

---

## 3. 🗣️ Idioma y forma de la narrativa

- **Español latinoamericano neutro** para todo lo que no sea código o salida de terminal.
- **Los términos del oficio se quedan en inglés** cuando son el nombre real de la cosa: *embedding*,
  *chunk*, *payload*, *recall*, *ground truth*, *HNSW*, *DiskANN*, *iterative scan*, *quantization*,
  *rescoring*, *sparse vector*, *reranker*, *cross-encoder*, *RRF*, *MMR*, *nDCG*, *MRR*. Los que tienen
  traducción asentada —fragmento, vector, índice, filtro, distancia, consulta, búsqueda híbrida,
  cuantización, evaluación— se alternan con naturalidad. **No se inventa vocabulario.**
- **Dos recalls, dos nombres, siempre:** *recall del índice* (aproximado frente a exacto) y *calidad de la
  recuperación* (frente al conjunto etiquetado). Nunca "recall" a secas cuando puede ser cualquiera de
  los dos (D-31).
- **Markdown siempre**, sin HTML embebido. **Prosa antes que listas.** Una frase aislada por sección, dos
  si es larga.
- **Tablas solo para lo tabular y corto**: comparación de motores, cuantizaciones, métricas de una
  evaluación, la traducción SQL ↔ Qdrant.
- **Diagramas en Mermaid** (D-12): el recorrido de una pregunta por el Oráculo, la costura con el sistema
  documental, la ventana del cron, la migración de modelo. Árboles y salidas en `text`.
- **Salida de terminal literal**, en `text`, sin recortar la parte incómoda (sobre todo un resultado
  vacío o una cita que no se encontró).
- **Encabezados con emoji, con moderación.**

---

## 4. 🎓 Pedagogía: cómo se explica

El público es senior, relacional de oficio y ya pasó por lite: **no explicar lo que ya sabe, y no dejar
ambiguo nada de lo que no.**

### 4.1 La regla del andamio

1. **El problema primero**, siempre en Valdivieso: *"Un asociado ve cuarenta expedientes de nueve mil
   ochocientos. Pide los diez fragmentos más cercanos con `ef_search` en 40. ¿Cuántos va a devolver?
   Apúntalo antes de ejecutar."*
2. **El mecanismo después**: el nombre y la definición mínima.
3. **La consulta que corre**, con su salida real y el número que importa señalado.

### 4.2 Del instinto se parte, no se reniega

- 🩻 **"Esto sí funciona igual"** — lo que se transfiere sin cambios del relacional: el índice es un
  derivado que cuesta en escritura, la selectividad manda, el `EXPLAIN` se lee, la transacción sigue
  siendo la herramienta de la consistencia.
- 🪞 **"Tu instinto dice… y esta vez se equivoca"** — el relacional (*"filtro primero con un `WHERE` y
  después busco"*), el de la industria (*"con más volumen hace falta un motor dedicado"*) o el que lite
  dejó demasiado firme (*"con recall alto, funciona"*). **Una por fase como mínimo.**
- ⚖️ **"Y aquí el instinto SQL tenía razón"** — las preguntas donde el veredicto va en la otra dirección:
  el número de expediente que se busca con un índice normal, el permiso que vive en la base de verdad, la
  pregunta que el full-text responde mejor que cualquier vector. Sin este recuadro el curso sonaría a
  folleto.

### 4.3 Nada de cajas negras prematuras

Primero `psql` y la consulta a pelo, y la API HTTP de Qdrant con `curl`; después el cliente y el servicio.
Primero el `EXPLAIN` y las estadísticas del índice; después la herramienta que los dibuja. Si se habla de
cuantización, se muestra cuánto ocupa el índice antes y después, y qué recall perdió.

### 4.4 Analogías, con fecha de caducidad

Una vez, para abrir la puerta, y se abandonan diciendo dónde se rompen. La más peligrosa del curso:
**"el índice vectorial es un índice compuesto con el filtro"**. Se desmonta en el mismo párrafo: el
filtro no reduce el espacio que recorre el grafo, lo vacía de candidatos.

### 4.5 Explica el porqué

Cada decisión lleva su porqué: por qué este tamaño de fragmento, por qué esta fusión, por qué esta
cuantización, por qué este `ef_search`, por qué el permiso se aplica aquí y no allá.

### 4.6 Densidad calibrada

Un concepto nuevo por vez. Ninguna sección teórica supera las dos pantallas sin una consulta, una medición
o un diagrama. Reaparecen con otras palabras: la pregunta del curso, "correcto, permitido y
comprobable", "el índice es un derivado" y "sin fuente, sin respuesta".

### 4.7 Cierra los bucles

Todo paréntesis abierto —*"esto lo pagamos en el bloque de la compresión"*, *"deuda 💸"*— se cierra.

---

## 5. 💻 Código, comandos y archivos

> **Regla normativa:** todo lo que se ejecuta o se versiona va en inglés —archivos, rutas, variables,
> identificadores, tablas, colecciones, campos de payload— y **todos los comentarios van en español con
> tildes**. Lo que ve un abogado va en español: el campo en inglés, el texto en español.

- **Código ejecutable y mínimo**, que corre de punta a punta con las versiones y los modelos fijados.
- **Comentarios que explican el porqué**: `// el permiso se resuelve en la misma consulta: no hay copia
  que pueda llegar tarde` sí; `// filtra` no.
- **Bloques con su lenguaje declarado**: `ts`, `python`, `sql`, `bash` (para `psql` y `curl`), `json`,
  `yaml`, `text`.
- **Un bloque, una idea.** **Nunca `foo`, `bar`, `doc1` ni `test1`**: todo usa Valdivieso.
- **Ningún texto jurídico real** en el código ni en las salidas: todo sale del generador (D-21).

### 5.1 Versiones fijadas

**Digest para las imágenes y archivo de bloqueo con hash para las librerías y los modelos**, con la
versión legible en un comentario. **Ninguna versión ni ningún modelo se escribe de memoria**, y hasta la
verificación previa ningún documento publica un número de versión ni el nombre de un modelo (§15). **Lo
no verificado se dice con esas palabras**: si una imagen no corre nativa en arm64 y se midió emulada, la
medición lo dice.

### 5.2 Los nombres del dominio

Fijos en todo el curso y en inglés. Hasta que exista el contrato de nombres, estos son los vigentes:

| En la narrativa | En el código |
|---|---|
| documento, versión | `document`, `document_version` |
| expediente, equipo | `matter`, `team` |
| permiso, muralla ética | `access_grant`, `ethical_wall` |
| abogado, asociado, socio | `lawyer` (con `role`) |
| resolución, norma (de la biblioteca) | `ruling`, `statute` |
| fragmento | `chunk` |
| procedencia (documento, versión, lugar) | `source_ref` |
| pregunta, respuesta, cita | `question`, `answer`, `citation` |
| conjunto de evaluación, relevancia | `eval_set`, `relevance` |
| el Oráculo | `oracle` |

**Las tablas, en `snake_case` y plural** (`documents`, `chunks`, `ethical_walls`); **la colección de Qdrant
lleva el mismo nombre que la tabla** y los campos del payload los mismos nombres que las columnas. Una
fase no renombra una tabla ni una entidad: si necesita una nueva, la declara y se agrega aquí y en la
historia.

### 5.3 El villano también va en inglés

El código del villano se nombra como estaba en Valdivieso: el cron `sync_permissions.py`, la colección
`oracle_chunks` con el campo de payload `allowed_teams`, la ingesta `ingest_fixed.py`. Su olor es **de
arquitectura**: un permiso copiado con una ventana, identificadores que cambian al reprocesar, un índice
que se trata como fuente de verdad.

### 5.4 Nombres de archivo del curso

Fases `NN-slug.md`; apéndices `aNN-slug.md`; la historia `00-historia-de-valdivieso-abogados.md`;
documentos vivos en la raíz (§7). Minúsculas y guiones, salvo `README.md`, `INSTINTOS.md` y
`BENCHMARKS.md`.

---

## 6. 🧱 La plantilla de los documentos

> 🚧 **Preliminar:** la plantilla rígida de fase se fija con la propuesta de fases. Punto de partida, el
> mismo de Proteo, Portalón y Cristalería: una sola plantilla que recupera **y** mide.

### 6.1 Encabezado obligatorio de fase

```markdown
# 🧬 Fase 05 — La muralla que llega tarde

> **Curso:** Oráculo de Bolsillo · Fase 05 de NN · Bloque II · **10 h**
> **Titular:** PostgreSQL con pgvector `pgvector/pgvector@sha256:…`
> **Rivales en esta fase:** {{pgvectorscale · Qdrant · ninguno}}
> **Modelos:** embeddings `{{nombre y hash}}` · {{reranker · lenguaje · ninguno}}
> **Volumen:** {{el escalón del laboratorio}}
> **Depende de:** Fase 04 · **Habilita:** Fase 06
> **Fecha de verificación ejecutada:** DD/MM/AAAA
> **Objetivo:** …
```

El título nombra el dolor de Valdivieso, no el operador ni el parámetro.

### 6.2 Secciones de una fase (punto de partida)

1. Título y encabezado
2. 🧭 **Dónde estamos** — qué dejó la fase anterior, y el dolor de Valdivieso que abre esta
3. 🎯 **Objetivos**, verificables
4. 🚫 **Qué NO entra todavía**, con destino
5. 🧩 **El modelo** — el fragmento, el índice, el filtro y el porqué
6. 🪞 **La apuesta**, escrita antes de medir
7. 📐 **La medición**: calidad, forma y tiempo, contra los rivales cuando toca
8. 💥 **El punto de rotura**, con volumen y mensaje literal
9. ⚖️ **Veredicto honesto: cuándo NO hacer esto**
10. ⚠️ **Errores comunes y diagnóstico**, con mensaje literal
11. 📋 **Checklist de validación**, ejecutable
12. 🧪 **Ejercicios** (§8)
13. 📚 **Referencias** (§10)
14. 🏁 **Resultado de la fase** y La señal de que quedó bien

Después, fuera de lo que lee el estudiante, puede ir **📌 Pendientes sugeridos**.

### 6.3 Cómo se presenta una medición

**Toda medición se publica con cinco datos**: qué se midió (calidad primero), sobre qué volumen y con qué
modelo de embeddings, con qué motor, digest y parámetros frente a qué alternativa, en qué máquina si hay
tiempos, y el comando exacto para reproducirla.

```markdown
> 📐 **Medición — diez fragmentos con el filtro de un asociado** · 1 M fragmentos, modelo `…` ·
> pgvector con iterative scan frente a Qdrant con payload indexado, al mismo recall del índice ·
> verificado el DD/MM/AAAA · {{máquina}}
>
> | | recall del índice@10 | calidad (nDCG@10) | resultados vacíos | p50 | p95 | p99 |
> |---|---|---|---|---|---|---|
> | pgvector | … | … | … | … | … | … |
> | Qdrant | … | … | … | … | … | … |
>
> Reproducir: `node scripts/measure.ts filtered-search --volume 1m --profile associate`
```

**Los tiempos van con su dispersión** (mediana, p95 y p99, repeticiones y calentamiento declarados) y la
máquina, **y nunca sostienen solos un veredicto** (D-19). **Dos motores se comparan al mismo recall del
índice**, declarado. Los costos de Pinecone llevan ☁️, la fuente y la fecha (D-22). La 🪞 apuesta se
escribe antes y no se edita.

---

## 7. 📐 Los tipos de documento y su coherencia

- **Fases**, **apéndices** y la **historia**, documento del lector y fuente de verdad narrativa: ningún
  dato de Valdivieso se inventa en una fase.
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
- **La escala:** 🟢 reproducir · 🟡 aplicar el patrón a otra pregunta de Valdivieso · 🟠 combinar,
  diagnosticar, decidir · 🔴 abierto o adversarial · 🔥 extra, fuera del mínimo.
- **Distribución ≈ 30 % 🟢, 30 % 🟡, 25 % 🟠, 15 % 🔴**, con margen; el bloque de lo que cuesta carga hacia
  🟠 y 🔴.
- **Al menos un tercio de diagnóstico o medición**: un filtro que vacía el resultado, una cita que apunta
  a otro fragmento, una muralla con ventana, una cuantización que hundió la calidad, un índice que no se
  usa; se pide reproducir, medir y explicar.
- **Predecir antes de ejecutar** en 🟠 y 🔴. **Cada ejercicio cierra con su criterio** (`Objetivo` o
  `Pregunta`). **Agrupados por dificultad**, con el conteo en el título.
- **Sin solución publicada** (D-05). **Taller global:** el Oráculo en `src/`.
- **💀 Boss de bloque**, cuando el bloque lo admita: un Oráculo roto o un encargo completo de alguien de
  Valdivieso (con nombre, de la historia §2), que cruza al menos dos fases y se entrega como artefacto.

---

## 9. 📏 Longitud y densidad

> 🚧 **Preliminar**, a fijar con la propuesta de fases. Punto de partida para una fase de 10 h: **4.000–5.000
> palabras de cuerpo**, contadas hasta el encabezado de 🧪 Ejercicios. Los apéndices son cortos, con
> índice de salto rápido, una tabla de "cuándo usar qué" y de 5 a 10 ejercicios de consulta.

---

## 10. 📚 Referencias y enlaces

### 10.1 Enlaces externos

**Orden de prioridad:** documentación oficial de la versión que usamos (PostgreSQL, pgvector,
pgvectorscale, Qdrant, Pinecone, las fichas de los modelos); después los papers de los algoritmos (HNSW,
DiskANN, la cuantización por producto, RRF) y de las métricas de evaluación; después libros; después
blogs y videos. **Siempre se advierte cuando un enlace apunta a otra versión**, y con los precios de la
nube se cita la fecha de la consulta. Cada URL, DOI y ficha de modelo se comprueba en la sesión que la
escribe.

Cada fase cierra sus referencias con un **orden de lectura sugerido**: antes de ejecutar, durante y
después.

### 10.2 Enlaces internos y anclas

Rutas relativas; anclas comprobadas; **ningún enlace a un documento que todavía no existe**.

### 10.3 Vigencia

Las secciones de referencias advierten que las URL y los contenidos cambian, que los modelos se reemplazan
cada pocos meses y que los precios de la nube cambian sin aviso: se cita la fecha.

---

## 11. 🧷 Vocabulario visual

**Marcadores de estado:** 💸 deuda intencional (con fase de pago) · 🔥 opcional · 🚧 fuera de alcance por
ahora, con destino · ☁️ tomado de documentación, no medido · 🟢🟡🟠🔴 dificultad · ⭐ valoración
bibliográfica, solo en referencias.

**Callouts en blockquote:** 📐 **Medición** (§6.3) · 🪞 **Apuesta / instinto que falla** · 💥 **Punto de
rotura** · ⚰️ **Autopsia** · ⚖️ **Veredicto honesto** y **"Y aquí el instinto SQL tenía razón"** · 🩻
**Esto sí funciona igual** · 📖 **Traducción** SQL ↔ Qdrant, en tabla · 🧠 **Modelo mental** · ⚠️
**Advertencia** · 📝 **Nota de contexto** (licencias, modelos, historia de un proyecto) · 💡 **Truco** ·
🩺 **Diagnóstico**, la consulta que confirma o descarta una hipótesis.

**Secciones narrativas recurrentes:** *Dónde estamos* · *Detalles con intención* · *El patrón a
memorizar* · *Prueba de fuego* · *La señal de que quedó bien*.

---

## 12. ✅ Checklist antes de dar por cerrado un `.md`

```text
[ ] El encabezado está completo, con titular, digest, modelos y fecha de verificación
[ ] La fase abre con un dolor de Valdivieso que está en la historia
[ ] Ningún dato del estudio se inventó en la fase (si hacía falta, se agregó a la historia)
[ ] Ningún texto jurídico ni caso real; todo sale del generador
[ ] Nada de lo que Ruta NoSQL Lite ya enseñó se explicó de nuevo; ninguna remisión a sus fases
[ ] Todo número salió de una ejecución real; lo emulado o no verificado está declarado
[ ] Toda medición trae los cinco datos de §6.3; los tiempos, con mediana, p95 y p99
[ ] El recall del índice y la calidad de la recuperación están nombrados por separado
[ ] Toda comparación de motores está al mismo recall del índice, declarado
[ ] Los costos de la nube llevan ☁️, fuente y fecha
[ ] La apuesta se escribió antes de medir y no se editó después
[ ] El punto de rotura trae volumen exacto y mensaje literal
[ ] PostgreSQL aparece como base de verdad seria, no como adorno
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

1. **Ruta NoSQL Lite como prerrequisito** (D-14) → no se explican los fundamentos del modelo vectorial →
   los da lite, y repetirlos sería el curso que el lector ya hizo.
2. **Los ejercicios no traen solución publicada** (D-05) → el método del curso es apostar y medir antes de
   mirar, y cada ejercicio trae su criterio.

Todo lo demás del `CLAUDE.md` aplica tal cual.

---

## 14. 🧪 Laboratorio

- **Docker Compose es el camino principal**; cada receta trae su equivalente en Podman. **Aquí no se enseña
  Docker. Sin Kubernetes.**
- **Perfiles de Compose** para no pasar de 16 GB: PostgreSQL, el servicio de modelos y el arnés siempre;
  **un rival a la vez** cuando la fase compara; el modelo de lenguaje solo en las fases que generan
  (D-20).
- **Los rivales con su configuración documentada**, nunca con la de otro motor. Si una imagen no corre
  nativa en arm64, se declara (D-29).
- **Servicios nombrados por papel** (`relacional`, `vectorial-rival`, `modelos`, `lenguaje`), para que
  cambiar de motor no rompa los comandos escritos.
- **Los modelos se descargan una vez**, con su hash, a un volumen del laboratorio; ninguna fase los baja
  en tiempo de ejecución.
- **Corpus, preguntas y verdad etiquetada sintéticos con semilla fija** (D-21, D-31).
- **Las pruebas de la producción** corren en contenedores etiquetados con el curso y en puertos altos
  aleatorios; el código de las sesiones va a `zz-code/` con su README.

---

## 15. 📌 Pendientes que afectan a esta guía

- **La plantilla rígida de fase (§6.2) y las longitudes (§9)** se fijan con la propuesta de fases. Todas
  las decisiones del alcance están cerradas (06/10/2026).
- **El diccionario de términos y el contrato de nombres** se escriben después de la propuesta de fases;
  hasta entonces mandan §3 y §5.2.
- **Versiones, digests, modelos y licencias sin fijar** hasta la verificación previa; lo mismo los precios
  de Pinecone.
- **El verificador del curso** se copia de `zz-instrucciones/herramientas/` y se ajusta cuando la plantilla
  de fase esté fijada.
