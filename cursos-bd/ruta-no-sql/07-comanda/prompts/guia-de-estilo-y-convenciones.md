# ✍️ Guía de estilo, tono y convenciones
## Comanda — el modelo offline-first a fondo

> **Qué es este documento:** la fuente de verdad editorial del curso: **cómo** se escribe. Cualquier sesión que
> produzca un `.md` de Comanda la sigue, para que todas las fases se lean como escritas por la misma mano y
> apunten al mismo sitio: **que el lector decida qué se escribe sin conexión, cómo se junta y qué no se junta
> nunca, y lo defienda con números propios.**
> **Vigencia:** 2026-10-07. **Cerrada salvo lo que depende de la propuesta de fases**: la plantilla rígida de
> fase (§6.2) y las longitudes (§9), que se fijan con ella (§15).
> **Herencia:** se escribió con la guía de Ruta NoSQL Lite y las de los cursos anteriores de la ruta como
> modelo, porque es la misma ruta y el lector viene de lite. Diverge de lite en: un solo dominio y una sola
> familia, una sola plantilla de fase, Mermaid, tiempos permitidos con dispersión, la profundidad full geek y
> **lo escrito contra lo que quedó como primera medida**. La guía de agosto
> (`_desechable-guia-de-estilo-v1.md`) queda de consulta.
> **Precedencia.** Por encima solo está [`alcance-del-proyecto.md`](alcance-del-proyecto.md). Por debajo van el
> contrato de nombres, el diccionario, las propuestas, las plantillas y los prompts. El `CLAUDE.md` del
> repositorio aplica en todo lo que este curso no haya declarado como excepción (§13).

Si dudas entre dos formas de escribir algo, gana la que le sirva más a alguien que el lunes tiene que explicarle
a la dueña de un restaurante por qué la mesa de veinte ya no pierde su cuenta cuando se cae la fibra.

---

## 1. 🧭 Principio rector

**Todo lo que se escribe apunta a que alguien decida con criterio qué se escribe en el dispositivo, cómo se
juntan las escrituras que no se vieron y qué no se junta nunca, y lo pueda defender con números propios,
incluido lo que hace el protocolo por dentro.**

No enseñamos CouchDB como producto ni formamos desarrolladores móviles. Formamos la capacidad de mirar un dato,
preguntar quién lo escribe y dónde, imaginar a dos escribiéndolo sin verse, diseñar la unidad que viaja y su
regla de fusión, medir lo que se pierde, y saber cuándo nada de esto hacía falta.

El filtro para cada párrafo: **¿esto ayuda a modelar, a medir, a diagnosticar o a decidir?** Si no, sobra.

> 🧠 **Primero quién escribe, después el motor.** En este modelo el veredicto depende de cuántos dispositivos
> escriben lo mismo, cuánto dura el corte y qué tan grande es la unidad que viaja. Por eso un número nunca se
> publica sin los dispositivos, la duración del corte y las ediciones concurrentes al lado, y una medición de
> corrección nunca se publica sin lo escrito contra lo que quedó.

### 1.1 Qué NO es este curso

No es un curso de CouchDB desde cero, ni de desarrollo móvil, ni de sistemas para restaurantes. No repite Ruta
NoSQL Lite: lo que lite enseñó de offline-first se **usa** sin volver a explicarlo.

### 1.2 Requisitos y autocontención

Lo publicado nombra Ruta NoSQL Lite **solo como requisito de entrada**, en el README y en la primera fase. **No
usa su contenido**: no remite a sus fases, no reutiliza sus ejemplos, sus datos ni sus mediciones; si el curso
necesita algo que lite enseñó, lo da por sabido o lo dice con sus propias palabras y con La Cazuela (D-03).
Ningún documento publicado cita otros cursos de la ruta ni el `CLAUDE.md` del repositorio.

---

## 2. 🎤 Tono

**Semiformal, cálido y directo**, con humor cuando cae bien: un colega que estuvo de guardia el sábado de
Carnaval y te lo cuenta con paciencia.

- **Tuteo latinoamericano, siempre.** *"Desconecta la tablet de la terraza, agrega tres cervezas a la mesa 12
  desde otra, y cuenta cuántas quedan en la cuenta cuando vuelva"*. Nada de voseo, nada de "usted", nada de
  impersonal permanente.
- **Semiformal.** Frases completas, cero abreviaturas de mensajería.
- **Humor seco y con moderación.** Máximo un chiste por sección; el blanco es la situación (el "fresco" de
  Brayan con la tablet en 2025), nunca una persona.
- **Cálido sin condescendencia.** El lector es senior y ya hizo lite.
- **Honesto sobre lo feo.** Si un CRDT gana, si Firestore resuelve con menos código, si la caja con cable no
  necesitaba nada, se dice con esas palabras y con el número delante.

### 2.1 El tono de las autopsias

⚰️ Una autopsia se escribe sobre una **decisión**, jamás sobre una persona. La cola la puso Julián, con aval de
Andrés y con un buen argumento —salir el lunes—, y durante dos años permitió vender en cada corte. Si un párrafo
suena a *"quien confió en el reloj de la tablet no sabía"*, el curso pierde a su mejor personaje y al lector que
hizo algo parecido.

Se escribe en este orden: la decisión con su mejor argumento; por qué era razonable entonces; qué pasó después,
con número; cuánto cuesta salir, con número; qué pregunta, hecha a tiempo, habría cambiado el resultado. Lo que
nunca aparece: "obviamente", "cualquiera habría visto", "error de novato".

---

## 3. 🗣️ Idioma y forma de la narrativa

- **Español latinoamericano neutro** para todo lo que no sea código o salida de terminal.
- **Los términos del oficio se quedan en inglés** cuando son el nombre real de la cosa: *offline-first*,
  *local-first*, *changes feed*, *checkpoint*, *revs_diff*, *bulk_get*, *revision tree*, *winning revision*,
  *`_conflicts`*, *`_deleted`*, *purge*, *compaction*, *`_revs_limit`*, *attachment*, *`validate_doc_update`*,
  *filtered replication*, *CRDT*, *add-wins set*, *PN-counter*, *hybrid logical clock*, *last-write-wins*,
  *shape*. Los que tienen traducción asentada —replicación, revisión, conflicto, réplica, reloj lógico, fusión,
  punto de control, adjunto, borrado, compactación— se alternan con naturalidad. **No se inventa vocabulario.**
- **"Sincronizar"** se usa en general; **"replicar"** cuando se habla del protocolo de CouchDB.
- **Markdown siempre**, sin HTML embebido. **Prosa antes que listas.** Una frase aislada por sección, dos si es
  larga.
- **Tablas solo para lo tabular y corto**: comparación de motores, resultados por corte y por dispositivos, la
  traducción SQL ↔ replicación.
- **Diagramas en Mermaid** (D-12): el árbol de revisiones, la topología tablet–local–nube, la secuencia de una
  replicación, el recorrido de una línea de pedido. Árboles de archivos y salidas en `text`.
- **Salida de terminal literal**, en `text` o `json`, sin recortar la parte incómoda (sobre todo `_conflicts`, el
  rechazo de `validate_doc_update` y la replicación que no avanza).
- **Encabezados con emoji, con moderación.**

---

## 4. 🎓 Pedagogía: cómo se explica

El público es senior, relacional de oficio y ya pasó por lite: **no explicar lo que ya sabe, y no dejar ambiguo
nada de lo que no.**

### 4.1 La regla del andamio

1. **El problema primero**, siempre en La Cazuela: *"Cuatro meseros atienden la mesa de una comparsa, dos sin
   red. Cada uno agrega diez platos en veinte minutos. Si la cuenta es un documento, ¿cuántas revisiones en
   conflicto va a haber al volver la red? ¿Y si cada línea es un documento? Apúntalo antes de ejecutar."*
2. **El mecanismo después**: el nombre y la definición mínima.
3. **La consulta o el comando que corre**, con su salida real y la línea que importa señalada.

### 4.2 Del instinto se parte, no se reniega

- 🩻 **"Esto sí funciona igual"** — lo que se transfiere sin cambios del relacional: validar la entrada, la
  concurrencia optimista detecta que alguien más escribió, el registro de cambios es la historia, la copia no es
  un respaldo hasta que se restaura.
- 🪞 **"Tu instinto dice… y esta vez se equivoca"** — el relacional (*"una columna de versión detecta el
  conflicto"*), el de la conferencia (*"con CRDT ya no hay conflictos"*) o el que lite dejó demasiado firme
  (*"CouchDB me entrega el conflicto, así que no pierdo nada"*). **Una por fase como mínimo.**
- ⚖️ **"Y aquí el instinto SQL tenía razón"** — las preguntas donde el veredicto va en la otra dirección: el pago,
  la factura, el cierre, los reportes. Sin este recuadro el curso sonaría a folleto.

### 4.3 Nada de cajas negras prematuras

Primero `curl` contra CouchDB y el documento con `?revs_info=true&conflicts=true`; después PouchDB y la app.
Primero el feed de cambios y la petición de `_revs_diff` a pelo; después la replicación que los esconde. Si se
habla de un conflicto, se muestra el árbol de revisiones.

### 4.4 Analogías, con fecha de caducidad

Una vez, para abrir la puerta, y se abandonan diciendo dónde se rompen. La más peligrosa del curso: **"`_rev` es
una columna de versión"**. Se desmonta en el mismo párrafo: una columna de versión rechaza la segunda escritura;
el árbol de revisiones la guarda, y deja a las dos ramas vivas hasta que alguien decide.

### 4.5 Explica el porqué

Cada decisión lleva su porqué: por qué este tamaño de documento, por qué este reloj, por qué esta regla de
fusión, por qué el pago no se fusiona.

### 4.6 Densidad calibrada

Un concepto nuevo por vez. Ninguna sección teórica supera las dos pantallas sin una consulta, una medición o un
diagrama. Reaparecen con otras palabras: la pregunta del curso, "¿quién escribe?", "varias verdades hasta que
alguien reconcilia" y "lo escrito contra lo que quedó".

### 4.7 Cierra los bucles

Todo paréntesis abierto —*"esto lo pagamos en el bloque del protocolo"*, *"deuda 💸"*— se cierra.

---

## 5. 💻 Código, comandos y archivos

> **Regla normativa:** todo lo que se ejecuta o se versiona va en inglés —archivos, rutas, variables,
> identificadores, bases, campos, tablas— y **todos los comentarios van en español con tildes**. Lo que ve un
> mesero, la cocina o un cliente va en español.

- **Código ejecutable y mínimo**, que corre de punta a punta con las versiones fijadas.
- **Comentarios que explican el porqué**: `// una línea por documento: dos meseros no se pisan al agregar` sí;
  `// guarda línea` no.
- **Bloques con su lenguaje declarado**: `ts`, `json`, `sql`, `bash`, `yaml`, `text`.
- **Un bloque, una idea.** **Nunca `foo`, `bar`, `doc1` ni `test1`**: todo usa La Cazuela.
- **Los identificadores de documento se diseñan**, no se dejan al azar: llevan el local y la entidad
  (`store-12:check:…`), porque deciden el orden y el filtrado.

### 5.1 Versiones fijadas

**Digest para las imágenes y archivo de bloqueo para las librerías**, con la versión legible en un comentario.
**Ninguna versión se escribe de memoria**, y hasta la verificación previa ningún documento publica un número de
versión (§15). **Lo no verificado se dice con esas palabras**: si una imagen no corre nativa en arm64 y se midió
emulada, la medición lo dice; si el emulador de Firestore se comporta distinto del servicio en algo documentado,
se dice.

### 5.2 Los nombres del dominio

Fijos en todo el curso y en inglés. Hasta que exista el contrato de nombres, estos son los vigentes:

| En la narrativa | En CouchDB (tipo de documento) | En PostgreSQL |
|---|---|---|
| local | base `store-NN` | `stores` |
| mesa | `table` | `tables` |
| cuenta | `check` | `checks` |
| línea de pedido, modificador | `check_line` (con `modifiers`) | `check_lines`, `line_modifiers` |
| comanda | `kitchen_ticket` | `kitchen_tickets` |
| plato, menú, agotado | `menu_item` (con `sold_out`) | `menu_items` |
| pago | — (por la API) | `payments` |
| factura, rango de numeración | — (por la API) | `invoices`, `invoice_ranges` |
| cierre de caja | — (por la API) | `cash_closings` |
| tablet, dispositivo | `device_id` en cada documento | `devices` |

**Campos y tablas en `snake_case`**; el campo `type` de cada documento lleva el nombre de la primera columna;
tipos y variables de TypeScript en `camelCase` y `PascalCase`. La misma entidad lleva el mismo nombre en los dos
mundos. Una fase no renombra un tipo ni una tabla: si necesita uno nuevo, lo declara y se agrega aquí y en la
historia.

### 5.3 El villano también va en inglés

El código del villano se nombra como estaba en La Cazuela: `comanda_v1`, con `pendingOps` en cada tablet,
`replayQueue.ts` en el servidor del local, el `updated_at` del reloj de la tablet como árbitro, y
`saveCheck()` que reescribe la cuenta entera. Su olor es **de arquitectura**: un conflicto tratado como
accidente, un reloj que miente usado como juez, una unidad demasiado grande, y un pago que viaja por la misma
cola que una cerveza.

### 5.4 Nombres de archivo del curso

Fases `NN-slug.md`; apéndices `aNN-slug.md`; la historia `00-historia-de-la-cazuela.md`; documentos vivos en la
raíz (§7). Minúsculas y guiones, salvo `README.md`, `INSTINTOS.md` y `BENCHMARKS.md`.

---

## 6. 🧱 La plantilla de los documentos

> 🚧 **Preliminar:** la plantilla rígida de fase se fija con la propuesta de fases. Punto de partida, el mismo de
> los cursos anteriores de la ruta: una sola plantilla que modela **y** mide.

### 6.1 Encabezado obligatorio de fase

```markdown
# 🍲 Fase 03 — Dos meseros, una mesa

> **Curso:** Comanda · Fase 03 de NN · Bloque I · **10 h**
> **Motor:** CouchDB `couchdb@sha256:…` y PouchDB `pouchdb@x.y.z` · **Base de verdad:** PostgreSQL `postgres@sha256:…`
> **Rivales en esta fase:** {{Automerge · Firestore (emulador) · ElectricSQL · ninguno}}
> **Topología y carga:** {{locales, tablets, duración del corte, ediciones concurrentes}}
> **Depende de:** Fase 02 · **Habilita:** Fase 04
> **Fecha de verificación ejecutada:** DD/MM/AAAA
> **Objetivo:** …
```

El título nombra el dolor de La Cazuela, no la función del motor.

### 6.2 Secciones de una fase (punto de partida)

1. Título y encabezado
2. 🧭 **Dónde estamos** — qué dejó la fase anterior, y el dolor de La Cazuela que abre esta
3. 🎯 **Objetivos**, verificables
4. 🚫 **Qué NO entra todavía**, con destino
5. 🧩 **El modelo** — quién escribe, la unidad que viaja, la regla de fusión, en los dos mundos
6. 🪞 **La apuesta**, escrita antes de medir
7. 📐 **La medición**: lo escrito contra lo que quedó, la forma y el tiempo, por corte y por dispositivos
8. 💥 **El punto de rotura**, con volumen y mensaje literal
9. ⚖️ **Veredicto honesto: cuándo NO hacer esto**
10. ⚠️ **Errores comunes y diagnóstico**, con mensaje literal
11. 📋 **Checklist de validación**, ejecutable
12. 🧪 **Ejercicios** (§8)
13. 📚 **Referencias** (§10)
14. 🏁 **Resultado de la fase** y La señal de que quedó bien

Después, fuera de lo que lee el estudiante, puede ir **📌 Pendientes sugeridos**.

### 6.3 Cómo se presenta una medición

**Toda medición se publica con cinco datos**: qué se midió (lo escrito contra lo que quedó y la forma primero),
sobre qué topología y qué carga, con qué motor, digest y configuración frente a qué alternativa, en qué máquina
si hay tiempos, y el comando exacto para reproducirla. **Siempre con dispositivos, duración del corte y
ediciones concurrentes.**

```markdown
> 📐 **Medición — la mesa de la comparsa** · 1 local, 4 tablets (2 sin red 40 min), 120 líneas ·
> `couchdb@sha256:…` frente a `comanda_v1` sobre `postgres@sha256:…` · verificado el DD/MM/AAAA · {{máquina}}
>
> | motor | unidad | líneas perdidas / duplicadas | conflictos abiertos | converge | bytes por la red | p50 | p95 | p99 |
> |---|---|---|---|---|---|---|---|---|
> | comanda_v1 | cuenta entera | … | — | … | … | … | … | … |
> | CouchDB | una línea por documento | … | … | … | … | … | … | … |
>
> Reproducir: `node scripts/measure.ts party-table --tablets 4 --offline 2:40m`
```

**Los tiempos van con su dispersión** (mediana, p95 y p99, repeticiones y calentamiento declarados) y la máquina,
**y nunca sostienen solos un veredicto** (D-19). Los costos de Firestore llevan ☁️, la fuente y la fecha (D-22). La
🪞 apuesta se escribe antes y no se edita.

---

## 7. 📐 Los tipos de documento y su coherencia

- **Fases**, **apéndices** y la **historia**, documento del lector y fuente de verdad narrativa: ningún dato de La
  Cazuela se inventa en una fase.
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
- **La escala:** 🟢 reproducir · 🟡 aplicar el patrón a otra pieza de La Cazuela · 🟠 combinar, diagnosticar,
  decidir · 🔴 abierto o adversarial · 🔥 extra, fuera del mínimo.
- **Distribución ≈ 30 % 🟢, 30 % 🟡, 25 % 🟠, 15 % 🔴**, con margen; el bloque del protocolo carga hacia 🟠 y 🔴.
- **Al menos un tercio de diagnóstico o medición**: una tablet con el reloj atrasado, un punto de control
  perdido, un conflicto que nadie resolvió, un adjunto huérfano, una tablet con la versión vieja; se pide
  reproducir, medir y explicar.
- **Predecir antes de ejecutar** en 🟠 y 🔴. **Cada ejercicio cierra con su criterio** (`Objetivo` o `Pregunta`).
  **Agrupados por dificultad**, con el conteo en el título.
- **Sin solución publicada** (D-05). **Taller global:** el sistema de mesas en `src/`.
- **💀 Boss de bloque**, cuando el bloque lo admita: una noche de servicio rota o un encargo completo de alguien de
  La Cazuela (con nombre, de la historia §2), que cruza al menos dos fases y se entrega como artefacto.

---

## 9. 📏 Longitud y densidad

> 🚧 **Preliminar**, a fijar con la propuesta de fases. Punto de partida para una fase de 10 h: **4.000–5.000
> palabras de cuerpo**, contadas hasta el encabezado de 🧪 Ejercicios. Los apéndices son cortos, con índice de
> salto rápido, una tabla de "cuándo usar qué" y de 5 a 10 ejercicios de consulta.

---

## 10. 📚 Referencias y enlaces

### 10.1 Enlaces externos

**Orden de prioridad:** documentación oficial de la versión que usamos (CouchDB y su protocolo de replicación,
PouchDB, Automerge, Firebase, ElectricSQL, PostgreSQL); después los papers de base (CRDT, relojes lógicos e
híbridos) y los textos fundacionales de local-first; después libros; después blogs y videos. **Siempre se
advierte cuando un enlace apunta a otra versión**, y con los precios se cita la fecha. Cada URL se comprueba por
código de estado en la sesión que la escribe.

Cada fase cierra sus referencias con un **orden de lectura sugerido**: antes de ejecutar, durante y después.

### 10.2 Enlaces internos y anclas

Rutas relativas; anclas comprobadas; **ningún enlace a un documento que todavía no existe**.

### 10.3 Vigencia

Las secciones de referencias advierten que las URL y los contenidos cambian, que esta categoría cambia rápido (un
motor de sincronización cambia de modelo entre versiones) y que los precios cambian: se cita la fecha.

---

## 11. 🧷 Vocabulario visual

**Marcadores de estado:** 💸 deuda intencional (con fase de pago) · 🔥 opcional · 🚧 fuera de alcance por ahora,
con destino · ☁️ tomado de documentación, no medido · 🟢🟡🟠🔴 dificultad · ⭐ valoración bibliográfica, solo en
referencias.

**Callouts en blockquote:** 📐 **Medición** (§6.3) · 🪞 **Apuesta / instinto que falla** · 💥 **Punto de rotura** ·
⚰️ **Autopsia** · ⚖️ **Veredicto honesto** y **"Y aquí el instinto SQL tenía razón"** · 🩻 **Esto sí funciona
igual** · 📖 **Traducción** SQL ↔ replicación, en tabla · 🧠 **Modelo mental** · ⚠️ **Advertencia** (incluida la de
CouchDB ≠ Couchbase) · 📝 **Nota de contexto** · 💡 **Truco** · 🩺 **Diagnóstico**, la petición o la salida que
confirma o descarta una hipótesis.

**Secciones narrativas recurrentes:** *Dónde estamos* · *Detalles con intención* · *El patrón a memorizar* ·
*Prueba de fuego* · *La señal de que quedó bien*.

---

## 12. ✅ Checklist antes de dar por cerrado un `.md`

```text
[ ] El encabezado está completo, con motor, digest, rivales, topología y carga, y fecha de verificación
[ ] La fase abre con un dolor de La Cazuela que está en la historia
[ ] Ningún dato de la empresa se inventó en la fase (si hacía falta, se agregó a la historia)
[ ] Nada de lo que Ruta NoSQL Lite ya enseñó se explicó de nuevo; ninguna remisión a sus fases
[ ] Todo número salió de una ejecución real; lo emulado o no verificado está declarado
[ ] Toda medición trae los cinco datos de §6.3, con dispositivos, duración del corte y ediciones concurrentes
[ ] Toda medición de corrección trae lo escrito contra lo que quedó, y si las réplicas convergen
[ ] El emulador de Firestore solo midió comportamiento; su costo lleva ☁️, fuente y fecha
[ ] La apuesta se escribió antes de medir y no se editó después
[ ] El punto de rotura trae volumen exacto y mensaje literal
[ ] Hay un ⚖️ veredicto con la pérdida cuantificada
[ ] Ninguna autopsia juzga a una persona
[ ] Dice CouchDB donde es CouchDB; Couchbase no aparece
[ ] Las mediciones, los errores y el 🪞 entraron en sus documentos vivos
[ ] Ejercicios: 20–30, agrupados, con conteo, un tercio de diagnóstico, cada uno con Objetivo o Pregunta
[ ] Los diagramas están en Mermaid; los árboles y salidas, en text o json
[ ] Tuteo en todo el documento; cero voseo, cero "usted"
[ ] Código en inglés, comentarios en español con tildes; identificadores de documento diseñados
[ ] Ningún enlace a un documento que no existe; grep -ln "_desechable-" *.md no devuelve nada
```

---

## 13. ⚖️ Excepciones declaradas

1. **Ruta NoSQL Lite como prerrequisito** (D-14) → no se explican los fundamentos de offline-first → los da lite, y
   repetirlos sería el curso que el lector ya hizo.
2. **Los ejercicios no traen solución publicada** (D-05) → el método del curso es apostar y medir antes de mirar,
   y cada ejercicio trae su criterio.

Todo lo demás del `CLAUDE.md` aplica tal cual.

---

## 14. 🧪 Laboratorio

- **Docker Compose es el camino principal**; cada receta trae su equivalente en Podman. **Aquí no se enseña
  Docker. Sin Kubernetes.**
- **Perfiles de Compose** para no pasar de 16 GB: PostgreSQL y CouchDB de la nube siempre; dos o tres locales con
  su CouchDB y sus tablets simuladas; **un rival a la vez** (D-20).
- **Las tablets son procesos de Node con PouchDB** en contenedores, con su reloj desfasable y su red cortable
  (D-26, D-27, D-35).
- **Servicios nombrados por papel** (`nube`, `local-01`, `tablet-01-03`), para que los comandos escritos no
  dependan de cuántos haya.
- **Los cortes son una simulación** sobre la red de los contenedores, y se dice.
- **Datos sintéticos con semilla fija** y los pedidos verdaderos (D-21, D-31).
- **Las pruebas de la producción** corren en contenedores etiquetados con el curso y en puertos altos aleatorios;
  el código de las sesiones va a `zz-code/` con su README.

---

## 15. 📌 Pendientes que afectan a esta guía

- **La plantilla rígida de fase (§6.2) y las longitudes (§9)** se fijan con la propuesta de fases. Todas las
  decisiones del alcance están cerradas (07/10/2026).
- **El diccionario de términos y el contrato de nombres** se escriben después de la propuesta de fases; hasta
  entonces mandan §3 y §5.2.
- **Versiones, digests y el adaptador de PouchDB sin fijar** hasta la verificación previa; lo mismo el modelo
  vigente de ElectricSQL y lo que el emulador de Firestore reproduce del servicio.
- **El nombre del curso** (D-34) espera la confirmación del autor.
- **El recorte contra lite** se revisa cuando sus fases 19 y 20 estén escritas.
- **El verificador del curso** se copia de `zz-instrucciones/herramientas/` y se ajusta cuando la plantilla de
  fase esté fijada.
