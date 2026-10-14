# ✍️ Guía de estilo, tono y convenciones
## Rastro — el modelo de columnar ancha a fondo

> **Qué es este documento:** la fuente de verdad editorial del curso: **cómo** se escribe. Cualquier sesión
> que produzca un `.md` de Rastro la sigue, para que todas las fases se lean como escritas por la misma mano y
> apunten al mismo sitio: **que el lector decida qué dato es un río y cuál un libro, dónde vive cada uno y qué
> le cuesta al motor, y lo defienda con números propios.**
> **Vigencia:** 2026-10-07. **Cerrada salvo lo que depende de la propuesta de fases**: la plantilla rígida de
> fase (§6.2) y las longitudes (§9), que se fijan con ella (§15).
> **Herencia:** se escribió con la guía de Ruta NoSQL Lite y las de los cursos anteriores de la ruta como
> modelo, porque es la misma ruta y el lector viene de lite. Diverge de lite en: un solo dominio y una sola
> familia, una sola plantilla de fase, Mermaid, tiempos permitidos con dispersión, la profundidad full geek y
> **lo leído contra lo escrito como primera medida**. La guía de agosto (`_desechable-guia-de-estilo-v1.md`)
> queda de consulta.
> **Precedencia.** Por encima solo está [`alcance-del-proyecto.md`](alcance-del-proyecto.md). Por debajo van el
> contrato de nombres, el diccionario, las propuestas, las plantillas y los prompts. El `CLAUDE.md` del
> repositorio aplica en todo lo que este curso no haya declarado como excepción (§13).

Si dudas entre dos formas de escribir algo, gana la que le sirva más a alguien que el lunes tiene que
explicarle a ciento cuarenta couriers aliados por qué el rastro se queda en Cassandra y el saldo se va.

---

## 1. 🧭 Principio rector

**Todo lo que se escribe apunta a que alguien decida con criterio qué dato merece un motor de columnar ancha y
cómo se modela y se opera ahí, y lo pueda defender con números propios, incluido lo que pasa dentro del motor.**

No enseñamos Cassandra como producto ni formamos administradores. Formamos la capacidad de mirar un dato,
preguntar si se escribe una vez y se lee siempre por la misma puerta, modelarlo para el pico, elegir su
compactación y su quórum, medir lo que se pierde y lo que cuesta, y saber qué hace el motor cuando lo aprietan.

El filtro para cada párrafo: **¿esto ayuda a modelar, a medir, a diagnosticar o a decidir?** Si no, sobra.

> 🧠 **Primero la puerta, después el motor.** En este modelo el veredicto depende de cómo se lee el dato, de
> cuánto llega por segundo y de qué consistencia se pidió. Por eso un tiempo nunca se publica sin el nivel de
> consistencia, el factor de réplica, los nodos y el caudal al lado, y una medición de corrección nunca se
> publica sin lo leído contra lo escrito.

### 1.1 Qué NO es este curso

No es un curso de CQL desde cero, ni de Cassandra como producto, ni de logística, ni de analítica. No repite
Ruta NoSQL Lite: lo que lite enseñó de columnar ancha se **usa** sin volver a explicarlo.

### 1.2 Requisitos y autocontención

Lo publicado nombra Ruta NoSQL Lite **solo como requisito de entrada**, en el README y en la primera fase. **No
usa su contenido**: no remite a sus fases, no reutiliza sus ejemplos, sus datos ni sus mediciones; si el curso
necesita algo que lite enseñó, lo da por sabido o lo dice con sus propias palabras y con Encomienda 305 (D-03).
Ningún documento publicado cita otros cursos de la ruta ni el `CLAUDE.md` del repositorio.

---

## 2. 🎤 Tono

**Semiformal, cálido y directo**, con humor cuando cae bien: un colega que estuvo de guardia el Black Friday y
te lo cuenta con paciencia.

- **Tuteo latinoamericano, siempre.** *"Corta el enlace entre Doral y Bogotá y cuenta cuántos eventos llegan
  tarde cuando vuelve"*. Nada de voseo, nada de "usted", nada de impersonal permanente.
- **Semiformal.** Frases completas, cero abreviaturas de mensajería.
- **Humor seco y con moderación.** Máximo un chiste por sección; el blanco es la situación (el "aguas" de
  Héctor antes de cada `nodetool`), nunca una persona.
- **Cálido sin condescendencia.** El lector es senior y ya hizo lite.
- **Honesto sobre lo feo.** Si PostgreSQL aguanta el rastro, si ScyllaDB gana, si la reparación tarda más que
  el periodo de gracia, se dice con esas palabras y con el número delante.

### 2.1 El tono de las autopsias

⚰️ Una autopsia se escribe sobre una **decisión**, jamás sobre una persona. La plataforma en Cassandra la puso
Rodrigo, con aval de Gustavo y con un buen argumento —una sola base, que ya operaban—; el rastro en Cassandra,
también de Gustavo, sobrevivió al corte de Doral. Si un párrafo suena a *"quien puso el saldo en un contador no
sabía"*, el curso pierde a su mejor personaje y al lector que hizo algo parecido.

Se escribe en este orden: la decisión con su mejor argumento; por qué era razonable entonces; qué pasó
después, con número; cuánto cuesta salir, con número; qué pregunta, hecha a tiempo, habría cambiado el
resultado. Lo que nunca aparece: "obviamente", "cualquiera habría visto", "error de novato".

---

## 3. 🗣️ Idioma y forma de la narrativa

- **Español latinoamericano neutro** para todo lo que no sea código o salida de terminal.
- **Los términos del oficio se quedan en inglés** cuando son el nombre real de la cosa: *commit log*,
  *memtable*, *flush*, *SSTable*, *bloom filter*, *partition index*, *key cache*, *compaction*, *STCS*,
  *LCS*, *TWCS*, *UCS*, *tombstone*, *gc_grace_seconds*, *repair*, *hinted handoff*, *read repair*,
  *gossip*, *vnodes*, *token ring*, *bootstrap*, *streaming*, *lightweight transaction*, *Paxos*, *logged
  batch*, *counter*, *SAI*, *shard-per-core*, *tablets*. Los que tienen traducción asentada —partición,
  réplica, nodo, centro de datos, quórum, lápida, compactación, reparación, lote, contador, anillo— se
  alternan con naturalidad. **No se inventa vocabulario.**
- **"Tabla"** se usa en los dos mundos; cuando haga falta distinguir, se dice *tabla de Cassandra* o *tabla
  de PostgreSQL*. *Column family* solo aparece para explicar de dónde viene el nombre de la familia.
- **Markdown siempre**, sin HTML embebido. **Prosa antes que listas.** Una frase aislada por sección, dos si
  es larga.
- **Tablas solo para lo tabular y corto**: comparación de motores, resultados por nivel de consistencia o por
  caudal, la traducción SQL ↔ CQL.
- **Diagramas en Mermaid** (D-12): el anillo de tokens, el camino de una escritura y de una lectura, los dos
  centros de datos, el recorrido de un paquete. Árboles de archivos y salidas en `text`.
- **Salida de terminal literal**, en `text`, sin recortar la parte incómoda (sobre todo la de `nodetool`, la
  de una lectura que vence y la del registro del nodo en pausa).
- **Encabezados con emoji, con moderación.**

---

## 4. 🎓 Pedagogía: cómo se explica

El público es senior, relacional de oficio y ya pasó por lite: **no explicar lo que ya sabe, y no dejar
ambiguo nada de lo que no.**

### 4.1 La regla del andamio

1. **El problema primero**, siempre en Encomienda 305: *"El revendedor de Valencia recibió treinta y un mil
   paquetes esta semana, y su casillero es una partición. ¿Cuántos megas va a pesar el viernes? ¿Cuántas
   SSTables va a tocar la lectura de Diana? Apúntalo antes de ejecutar."*
2. **El mecanismo después**: el nombre y la definición mínima.
3. **La consulta o el comando que corre**, con su salida real y la línea que importa señalada.

### 4.2 Del instinto se parte, no se reniega

- 🩻 **"Esto sí funciona igual"** — lo que se transfiere sin cambios del relacional: el registro antes del
  dato, el índice decide el punto de partida, el plan se lee, la copia no es un respaldo hasta que se
  restaura.
- 🪞 **"Tu instinto dice… y esta vez se equivoca"** — el relacional (*"un lote es una transacción"*), el de
  la conferencia (*"Cassandra escala sola"*) o el que lite dejó demasiado firme (*"con quórum siempre leo lo
  último"*). **Una por fase como mínimo.**
- ⚖️ **"Y aquí el instinto SQL tenía razón"** — las preguntas donde el veredicto va en la otra dirección: el
  saldo, el consecutivo, las tarifas, la pregunta que nadie previó. Sin este recuadro el curso sonaría a
  folleto.

### 4.3 Nada de cajas negras prematuras

Primero `cqlsh`, `nodetool` y `psql` a pelo; después el driver y el servicio. Primero el `TRACING ON` de una
consulta y `nodetool tablehistograms`; después la herramienta que los dibuja. Si se habla de una partición
grande, se muestra su tamaño y el aviso del registro.

### 4.4 Analogías, con fecha de caducidad

Una vez, para abrir la puerta, y se abandonan diciendo dónde se rompen. La más peligrosa del curso: **"un lote
de CQL es una transacción"**. Se desmonta en el mismo párrafo: un lote con registro garantiza que, tarde o
temprano, se aplica entero; no garantiza aislamiento ni que nadie lea la mitad.

### 4.5 Explica el porqué

Cada decisión lleva su porqué: por qué esta cubeta de tiempo, por qué esta compactación para esta tabla, por
qué `LOCAL_QUORUM` y no `QUORUM`, por qué este dato sale de Cassandra.

### 4.6 Densidad calibrada

Un concepto nuevo por vez. Ninguna sección teórica supera las dos pantallas sin una consulta, una medición o
un diagrama. Reaparecen con otras palabras: la pregunta del curso, "la puerta", "río o libro" y "lo leído
contra lo escrito".

### 4.7 Cierra los bucles

Todo paréntesis abierto —*"esto lo pagamos en el bloque de la distribución"*, *"deuda 💸"*— se cierra.

---

## 5. 💻 Código, comandos y archivos

> **Regla normativa:** todo lo que se ejecuta o se versiona va en inglés —archivos, rutas, variables,
> identificadores, keyspaces, tablas, columnas— y **todos los comentarios van en español con tildes**. Lo que
> ve un cliente de Encomienda 305 o un aliado va en español.

- **Código ejecutable y mínimo**, que corre de punta a punta con las versiones fijadas.
- **Comentarios que explican el porqué**: `// cubeta semanal: el revendedor no puede volver a llenar una
  partición` sí; `// inserta evento` no.
- **Bloques con su lenguaje declarado**: `ts`, `cql`, `sql`, `bash`, `yaml`, `text`.
- **Un bloque, una idea.** **Nunca `foo`, `bar`, `t1` ni `test1`**: todo usa Encomienda 305.
- **CQL siempre con sentencias preparadas**, nunca con valores concatenados.

### 5.1 Versiones fijadas

**Digest para las imágenes y archivo de bloqueo para las librerías**, con la versión legible en un comentario.
**Ninguna versión se escribe de memoria**, y hasta la verificación previa ningún documento publica un número
de versión (§15). **Lo no verificado se dice con esas palabras**: si una imagen no corre nativa en arm64 y se
midió emulada, la medición lo dice; si una función de CQL no existe en ScyllaDB o en la versión de Cassandra,
se dice cuál y desde qué versión.

### 5.2 Los nombres del dominio

Fijos en todo el curso y en inglés. Hasta que exista el contrato de nombres, estos son los vigentes:

| En la narrativa | En Cassandra | En PostgreSQL |
|---|---|---|
| casillero, cliente, aliado | `lockers`, `customers`, `partners` | `lockers`, `customers`, `partners` |
| guía, paquete | `tracking_number` | `packages` |
| evento de rastreo | `events_by_tracking`, `events_by_locker`, `events_by_warehouse_day` | `tracking_events`, particionada por mes |
| estado actual | `package_status` | `packages.status` |
| bodega, transportista | `warehouse`, `carrier` | `warehouses`, `carriers` |
| tarifa, recargo | `rates_by_*` (las seis tablas del villano) | `rates`, `surcharges` |
| saldo prepago | `prepaid_balance` (contador del villano) | `prepaid_ledger` |
| factura, consecutivo | `invoices`, `invoice_sequence` | `invoices`, `invoice_sequences` |
| reclamo | `claims` | `claims` |

**Keyspaces, tablas y columnas en `snake_case`** en los dos mundos; tipos y variables de TypeScript en
`camelCase` y `PascalCase`. La misma entidad lleva el mismo nombre en los dos mundos. Una fase no renombra una
tabla: si necesita una nueva, la declara y se agrega aquí y en la historia.

### 5.3 El villano también va en inglés

El código del villano se nombra como estaba en Encomienda 305: el keyspace `platform`, el script
`updateRates.ts` con su lote sin registro, `debitBalance.ts` con el contador, `nextInvoiceNumber.ts` con la
transacción ligera, y `customsHoldReport.ts` con su `ALLOW FILTERING`. Su olor es **de arquitectura**: un dato
que cambia, que tiene invariantes o que se pregunta de formas imprevistas, guardado en un motor hecho para
escribir una vez y leer por la misma puerta.

### 5.4 Nombres de archivo del curso

Fases `NN-slug.md`; apéndices `aNN-slug.md`; la historia `00-historia-de-encomienda-305.md`; documentos vivos en
la raíz (§7). Minúsculas y guiones, salvo `README.md`, `INSTINTOS.md` y `BENCHMARKS.md`.

---

## 6. 🧱 La plantilla de los documentos

> 🚧 **Preliminar:** la plantilla rígida de fase se fija con la propuesta de fases. Punto de partida, el mismo
> de los cursos anteriores de la ruta: una sola plantilla que modela **y** mide.

### 6.1 Encabezado obligatorio de fase

```markdown
# 📦 Fase 03 — El casillero del revendedor

> **Curso:** Rastro · Fase 03 de NN · Bloque I · **10 h**
> **Motor:** Apache Cassandra `cassandra@sha256:…` · **Control:** PostgreSQL `postgres@sha256:…`
> **Rivales en esta fase:** {{ScyllaDB · PostgreSQL particionado · ninguno}}
> **Topología y carga:** {{nodos, centros de datos, factor de réplica, caudal}}
> **Depende de:** Fase 02 · **Habilita:** Fase 04
> **Fecha de verificación ejecutada:** DD/MM/AAAA
> **Objetivo:** …
```

El título nombra el dolor de Encomienda 305, no la cláusula de CQL.

### 6.2 Secciones de una fase (punto de partida)

1. Título y encabezado
2. 🧭 **Dónde estamos** — qué dejó la fase anterior, y el dolor de Encomienda 305 que abre esta
3. 🎯 **Objetivos**, verificables
4. 🚫 **Qué NO entra todavía**, con destino
5. 🧩 **El modelo** — la pregunta, su puerta, la tabla y lo que hace el motor con ella, en los dos mundos
6. 🪞 **La apuesta**, escrita antes de medir
7. 📐 **La medición**: lo leído contra lo escrito, la forma y el tiempo, por caudal y consistencia
8. 💥 **El punto de rotura**, con volumen y mensaje literal
9. ⚖️ **Veredicto honesto: cuándo NO hacer esto**
10. ⚠️ **Errores comunes y diagnóstico**, con mensaje literal
11. 📋 **Checklist de validación**, ejecutable
12. 🧪 **Ejercicios** (§8)
13. 📚 **Referencias** (§10)
14. 🏁 **Resultado de la fase** y La señal de que quedó bien

Después, fuera de lo que lee el estudiante, puede ir **📌 Pendientes sugeridos**.

### 6.3 Cómo se presenta una medición

**Toda medición se publica con cinco datos**: qué se midió (lo leído contra lo escrito y la forma primero),
sobre qué volumen y qué topología, con qué motor, digest y configuración frente a qué alternativa, en qué
máquina si hay tiempos, y el comando exacto para reproducirla. **Siempre con consistencia, réplica, nodos y
caudal.**

```markdown
> 📐 **Medición — el rastro de una guía durante una ráfaga** · 4 nodos (2 + 2), RF 2 por centro ·
> `cassandra@sha256:…` frente a `postgres@sha256:…` particionado por mes · verificado el DD/MM/AAAA ·
> {{máquina}}
>
> | caudal ofrecido | consistencia | motor | perdidos / duplicados / obsoletos | SSTables por lectura | p50 | p95 | p99 |
> |---|---|---|---|---|---|---|---|
> | 5.000/s | LOCAL_QUORUM | Cassandra | … | … | … | … | … |
> | 5.000/s | — | PostgreSQL | … | … | … | … | … |
>
> Reproducir: `node scripts/measure.ts tracking --rate 5000 --cl LOCAL_QUORUM`
```

**Los tiempos van con su dispersión** (mediana, p95 y p99, repeticiones y calentamiento declarados) y la
máquina, **y nunca sostienen solos un veredicto** (D-19). Los costos de los gestionados llevan ☁️, la fuente y
la fecha (D-22). La 🪞 apuesta se escribe antes y no se edita.

---

## 7. 📐 Los tipos de documento y su coherencia

- **Fases**, **apéndices** y la **historia**, documento del lector y fuente de verdad narrativa: ningún dato de
  Encomienda 305 se inventa en una fase.
- **Documentos vivos** en la raíz, que son producto: `INSTINTOS.md` (cada 🪞 con su medición),
  **`BENCHMARKS.md`** (toda medición publicada, con los cinco datos de §6.3) y el catálogo de errores con su
  mensaje literal (si es apéndice o documento aparte, lo dice la propuesta de apéndices).
- **Los apéndices no repiten una fase, y viceversa: se enlazan.** **Una fase no cita el temario ni el plan.**
  🗑️ **Los `_desechable-*` no se citan nunca.**
- **Git:** tags `fase-NN-<slug>`, prefijo de commit `fNN:`, ejercicios `fNN ejM: …` (D-09).

---

## 8. 🧪 Evaluación: ejercicios

- **Cantidad: 20 mínimo y 30 máximo por fase**, calibrada con *"¿cuántas cosas distintas enseña esta fase que
  se puedan comprobar por separado?"*.
- **La escala:** 🟢 reproducir · 🟡 aplicar el patrón a otra pregunta de Encomienda 305 · 🟠 combinar,
  diagnosticar, decidir · 🔴 abierto o adversarial · 🔥 extra, fuera del mínimo.
- **Distribución ≈ 30 % 🟢, 30 % 🟡, 25 % 🟠, 15 % 🔴**, con margen; los bloques del motor y de la distribución
  cargan hacia 🟠 y 🔴.
- **Al menos un tercio de diagnóstico o medición**: una partición sin cubeta, un contador reintentado, una
  lectura que tropieza con lápidas, una reparación que no corrió, un nodo que vuelve tarde; se pide
  reproducir, medir y explicar.
- **Predecir antes de ejecutar** en 🟠 y 🔴. **Cada ejercicio cierra con su criterio** (`Objetivo` o
  `Pregunta`). **Agrupados por dificultad**, con el conteo en el título.
- **Sin solución publicada** (D-05). **Taller global:** el rastreo y la plataforma en `src/`.
- **💀 Boss de bloque**, cuando el bloque lo admita: un clúster roto o un encargo completo de alguien de
  Encomienda 305 (con nombre, de la historia §2), que cruza al menos dos fases y se entrega como artefacto.

---

## 9. 📏 Longitud y densidad

> 🚧 **Preliminar**, a fijar con la propuesta de fases. Punto de partida para una fase de 10 h: **4.000–5.000
> palabras de cuerpo**, contadas hasta el encabezado de 🧪 Ejercicios. Los apéndices son cortos, con índice de
> salto rápido, una tabla de "cuándo usar qué" y de 5 a 10 ejercicios de consulta.

---

## 10. 📚 Referencias y enlaces

### 10.1 Enlaces externos

**Orden de prioridad:** documentación oficial de la versión que usamos (Apache Cassandra, ScyllaDB, el driver
de Node, PostgreSQL, Bigtable, Amazon Keyspaces); después los papers fundacionales (Bigtable, Dynamo) y las
propuestas de mejora de Cassandra que expliquen una función (Accord, SAI, la compactación unificada); después
libros; después blogs y videos, con escepticismo explícito ante los de parte interesada. **Siempre se advierte
cuando un enlace apunta a otra versión**, y con las licencias y los precios se cita la fecha. Cada URL se
comprueba por código de estado en la sesión que la escribe.

Cada fase cierra sus referencias con un **orden de lectura sugerido**: antes de ejecutar, durante y después.

### 10.2 Enlaces internos y anclas

Rutas relativas; anclas comprobadas; **ningún enlace a un documento que todavía no existe**.

### 10.3 Vigencia

Las secciones de referencias advierten que las URL y los contenidos cambian, que el comportamiento de
Cassandra y de ScyllaDB cambia entre versiones, y que las licencias y los precios cambian: se cita la fecha.

---

## 11. 🧷 Vocabulario visual

**Marcadores de estado:** 💸 deuda intencional (con fase de pago) · 🔥 opcional · 🚧 fuera de alcance por ahora,
con destino · ☁️ tomado de documentación, no medido · 🟢🟡🟠🔴 dificultad · ⭐ valoración bibliográfica, solo
en referencias.

**Callouts en blockquote:** 📐 **Medición** (§6.3) · 🪞 **Apuesta / instinto que falla** · 💥 **Punto de rotura**
· ⚰️ **Autopsia** · ⚖️ **Veredicto honesto** y **"Y aquí el instinto SQL tenía razón"** · 🩻 **Esto sí funciona
igual** · 📖 **Traducción** SQL ↔ CQL, en tabla · 🧠 **Modelo mental** · ⚠️ **Advertencia** · 📝 **Nota de
contexto** (licencias, papers, historia de un proyecto) · 💡 **Truco** · 🩺 **Diagnóstico**, el comando o la
traza que confirma o descarta una hipótesis.

**Secciones narrativas recurrentes:** *Dónde estamos* · *Detalles con intención* · *El patrón a memorizar* ·
*Prueba de fuego* · *La señal de que quedó bien*.

---

## 12. ✅ Checklist antes de dar por cerrado un `.md`

```text
[ ] El encabezado está completo, con motor, digest, rivales, topología y carga, y fecha de verificación
[ ] La fase abre con un dolor de Encomienda 305 que está en la historia
[ ] Ningún dato de la empresa se inventó en la fase (si hacía falta, se agregó a la historia)
[ ] Nada de lo que Ruta NoSQL Lite ya enseñó se explicó de nuevo; ninguna remisión a sus fases
[ ] Todo número salió de una ejecución real; lo emulado o no verificado está declarado
[ ] Toda medición trae los cinco datos de §6.3, con consistencia, réplica, nodos y caudal
[ ] Toda medición de corrección trae lo leído contra lo escrito; los tiempos, con mediana, p95 y p99
[ ] PostgreSQL jugó con lo mejor que tiene (particionado, índices, lotes, autovacuum), no como adorno
[ ] Los costos de la nube llevan ☁️, fuente y fecha; la licencia de ScyllaDB, con fecha
[ ] La apuesta se escribió antes de medir y no se editó después
[ ] El punto de rotura trae volumen exacto y mensaje literal
[ ] Hay un ⚖️ veredicto con la pérdida cuantificada
[ ] Ninguna autopsia juzga a una persona
[ ] Las mediciones, los errores y el 🪞 entraron en sus documentos vivos
[ ] Ejercicios: 20–30, agrupados, con conteo, un tercio de diagnóstico, cada uno con Objetivo o Pregunta
[ ] Los diagramas están en Mermaid; los árboles y salidas, en text
[ ] Tuteo en todo el documento; cero voseo, cero "usted"
[ ] Código en inglés, comentarios en español con tildes; CQL con sentencias preparadas
[ ] Ningún enlace a un documento que no existe; grep -ln "_desechable-" *.md no devuelve nada
```

---

## 13. ⚖️ Excepciones declaradas

1. **Ruta NoSQL Lite como prerrequisito** (D-14) → no se explican los fundamentos de columnar ancha → los da
   lite, y repetirlos sería el curso que el lector ya hizo.
2. **Los ejercicios no traen solución publicada** (D-05) → el método del curso es apostar y medir antes de
   mirar, y cada ejercicio trae su criterio.

Todo lo demás del `CLAUDE.md` aplica tal cual.

---

## 14. 🧪 Laboratorio

- **Docker Compose es el camino principal**; cada receta trae su equivalente en Podman. **Aquí no se enseña
  Docker. Sin Kubernetes.**
- **Perfiles de Compose** para no pasar de 16 GB: PostgreSQL, el servicio y el arnés siempre; **un motor de la
  familia a la vez**; Cassandra en tres nodos o en dos más dos (D-20).
- **Cada motor con su configuración documentada** (memoria y recolector de Cassandra, núcleos y memoria de
  ScyllaDB), nunca con la de otro. Si una imagen no corre nativa en arm64, se declara (D-29).
- **Servicios nombrados por papel** (`relacional`, `columnar`, `columnar-rival`), y los nodos por centro de
  datos (`doral-1`, `bogota-1`), para que cambiar de motor no rompa los comandos escritos.
- **Los dos centros de datos son una simulación** en la misma máquina, con latencia y cortes provocados por
  red, y se dice (D-28).
- **Datos sintéticos con semilla fija** y la trayectoria verdadera, la ingesta simulada y el simulador de
  aliados (D-21, D-30, D-31).
- **Las pruebas de la producción** corren en contenedores etiquetados con el curso y en puertos altos
  aleatorios; el código de las sesiones va a `zz-code/` con su README.

---

## 15. 📌 Pendientes que afectan a esta guía

- **La plantilla rígida de fase (§6.2) y las longitudes (§9)** se fijan con la propuesta de fases. Todas las
  decisiones del alcance están cerradas (07/10/2026).
- **El diccionario de términos y el contrato de nombres** se escriben después de la propuesta de fases; hasta
  entonces mandan §3 y §5.2.
- **Versiones, digests, el driver de Node y licencias sin fijar** hasta la verificación previa; lo mismo la
  licencia de ScyllaDB (D-24), los precios de los gestionados y si la versión estable de Cassandra trae Accord
  (D-26).
- **El recorte contra lite** se revisa cuando sus fases 17 y 18 estén escritas.
- **El verificador del curso** se copia de `zz-instrucciones/herramientas/` y se ajusta cuando la plantilla de
  fase esté fijada.
