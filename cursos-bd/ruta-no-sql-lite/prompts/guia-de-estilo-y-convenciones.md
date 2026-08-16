# ✍️ Guía de estilo, tono y convenciones
## Ruta NoSQL Lite — Diez motores, un dominio, cinco preguntas

Esta guía es la fuente de verdad editorial del curso. Cualquier chat que produzca un
`.md` de este proyecto la sigue. Su objetivo es que las veintiséis fases y los diez
apéndices se lean como escritos por la misma mano, con el mismo criterio, y que todos
apunten al mismo sitio: **que el lector sepa elegir familia de base de datos y pueda
defender la elección con una medición propia**.

Si dudas entre dos formas de escribir algo, gana la que le sirva más a alguien que el
lunes tiene un design review y va a tener que decir, delante de su equipo, por qué esto
no va en Mongo.

> **Precedencia.** Por encima de esta guía solo está
> [`alcance-del-proyecto.md`](alcance-del-proyecto.md), que decide **qué** enseña el curso;
> esta decide **cómo** se escribe. Por debajo van las dos propuestas de alcance, las
> plantillas y los prompts, que se actualizan después y nunca al revés. El `CLAUDE.md` del
> repositorio aplica en todo lo que este curso no haya declarado como excepción (§16).

---

## 1. 🧭 Principio rector

**Todo lo que se escribe apunta a que alguien decida con criterio y lo pueda defender con
números propios.**

No enseñamos productos. No formamos administradores de bases de datos. Formamos la
capacidad de mirar un dominio, reconocer su modelo de acceso, montar las dos opciones y
medir la diferencia.

El filtro para cada párrafo es este: **¿esto ayuda a modelar, a medir, a diagnosticar o a
decidir?** Si no, sobra. Aunque esté muy bien escrito. Sobre todo si está muy bien
escrito.

Y el corolario, repetido tantas veces como haga falta:

> 🧠 **Se mide la forma, no la velocidad.** Ningún veredicto de este curso se sostiene
> sobre un milisegundo.

---

## 2. 🎤 Tono

**Semiformal, cálido y directo**, con humor cuando cae bien. Piensa en un colega que ya
pagó esta factura y te la explica con paciencia, sin solemnidad de manual corporativo y
sin palmaditas en la espalda.

Cómo se ve eso en la práctica:

- **Tuteo latinoamericano, siempre.** *"Levanta el contenedor y mira cuántos documentos
  examinó"*, *"si esto te suena raro es porque todavía no vimos las particiones; aguanta
  dos secciones"*. Nada de voseo (*"fijate"*, *"levantá"*), nada de "usted", nada de
  impersonal permanente ("se debe configurar…") que enfría el texto.
- **Semiformal.** Cercano pero no chat de WhatsApp. Frases completas, puntuación correcta,
  cero abreviaturas de mensajería. Un "che" no; un "ojo con esto" sí.
- **Humor seco y con moderación.** Un 😉 bien puesto, un chiste sobre el JSON de 14 MB que
  alguien guardó "porque era más cómodo". El humor desdramatiza la factura del legacy, no
  rellena. Regla práctica: **máximo un chiste por sección**, y si no fluye solo, se borra.
- **Cálido sin condescendencia.** El lector es senior. Se le explica todo con cero
  ambigüedad y no se le explica nada que ya sepa. *"Como para un bebé"* aquí significa
  **ninguna caja negra prematura**, no menos profundidad.
- **Honesto sobre lo feo.** Si el motor del minicurso pierde contra Postgres en el caso
  que acabamos de medir, se dice con esas palabras y con el número delante. Cada familia
  gana en algún sitio y pierde en otro, y las pérdidas van con cifras.

### 2.1 El tono de las autopsias, que es el punto más delicado del curso

⚰️ Una autopsia se escribe sobre una **decisión**, jamás sobre una persona. Si un párrafo
suena a *"quien eligió Mongo es tonto"*, pierdes exactamente al lector que más lo
necesita: el que lo eligió.

La versión que funciona **defiende el argumento antes de desmontarlo**. Quien pidió Mongo
no dijo una tontería: dijo *"el esquema va a cambiar mucho"* o *"esto tiene que escalar"*,
que son preocupaciones legítimas con el instrumento equivocado. Escríbelo así, en este
orden:

1. La decisión, en la voz de quien la tomó y con su mejor argumento.
2. Por qué ese argumento era razonable **en ese momento** y con esa información.
3. Qué pasó a los dos años, con número.
4. Cuánto costó salir, con número.
5. Cuál de las cinco preguntas (§5 del alcance) habría cambiado el resultado.

Lo que nunca aparece: "obviamente", "cualquiera habría visto", "error de novato", ni
ninguna variante de la misma superioridad.

Lo que evitamos en todo el curso: promesas vacías ("vas a dominar NoSQL"), motivación de
coach, solemnidad de manual, y esa forma tan cómoda de enseñar que consiste en pegar el
`docker run` oficial y decir "listo, ya tienes Mongo".

---

## 3. 🗣️ Idioma y forma de la narrativa

- **Español latinoamericano neutro**, técnico y claro, para todo lo que no sea código o
  salida de terminal.
- **Los términos del oficio se quedan en inglés** cuando son el nombre real de la cosa:
  *shard*, *partition key*, *clustering key*, *replica set*, *write amplification*,
  *fan-out*, *embedding*, *inverted index*, *compaction*, *tombstone*, *CRDT*, *LSM tree*,
  *primary key*, *upsert*. Traducirlos forzadamente confunde y además no es lo que el
  lector va a leer en la documentación ni en los mensajes de error. Los que ya tienen
  traducción asentada —índice, consulta, colección, partición, agregación— se alternan con
  naturalidad. Lo importante es **no inventar vocabulario**.
- **Markdown siempre.** Nada de HTML embebido salvo que no haya alternativa.
- **Prosa antes que listas.** Un párrafo que explica *por qué* vale más que cinco viñetas
  que enumeran *qué*. Las listas se usan cuando la cosa es de verdad una lista: pasos
  secuenciales, ítems paralelos, opciones.
- **Nada de prosa telegrama.** Una frase corta y sola, con línea en blanco a ambos lados,
  es un golpe de ritmo excelente. Tres seguidas son un telegrama, y el lector deja de
  encontrar el argumento porque no hay párrafo donde buscarlo. **Una frase aislada por
  sección, dos si la sección es larga.**
- **Tablas solo para lo tabular y corto.** Mapeos de traducción, matriz familia × pregunta,
  versiones fijadas, tabla de decisión. Tres o cuatro columnas como máximo. Si necesitas
  explicar una celda, ya no era una tabla: era una lista con subtítulos.
- **Diagramas ASCII en bloques `text`**, sin timidez, cuando hay estructura que mostrar:
  cómo se reparte una partition key, cuántos viajes hace una consulta, qué se duplica al
  desnormalizar.

  ```text
  UNA LECTURA DE LA FICHA DE VEHÍCULO

  documental          referenciado al estilo relacional
  ───────────         ─────────────────────────────────
  app                 app
   │                   │
   │ 1 viaje           ├── 1 viaje → vehicles
   ▼                   ├── 1 viaje → engines
  vehicles             ├── 1 viaje → options  (N)
  (1 documento)        └── 1 viaje → warranty
                              = 3 + N viajes
  ```

- **Salida de terminal literal.** Tal como sale, en bloque `text`, sin embellecer y sin
  recortar la parte incómoda. **El error real enseña más que el error editado**, y además
  es lo que alguien va a pegar en un buscador.
- **Encabezados con emoji, con moderación.** Uno por sección numerada, casi ninguno en
  subsecciones. Un documento que parece un teclado de emojis pierde autoridad.

---

## 4. 🎓 Pedagogía: cómo se explica

El público es senior y con sesgo relacional. La regla que lo cubre: **no explicar lo que
ya sabe, y no dejar ambiguo nada de lo que no**.

### 4.1 La regla del andamio

Todo concepto nuevo se presenta en tres tiempos y en este orden:

1. **El problema primero**, y siempre en el dominio de flota. *"Necesitas saber qué órdenes
   de trabajo tocaron la pieza X el trimestre pasado. En la colección que modelaste el
   martes, eso son cuántos viajes… ¿lo calculas antes de ejecutar?"*
2. **El mecanismo después.** El nombre y la definición mínima: lo justo para usarlo hoy,
   no el capítulo entero de la documentación.
3. **El comando que corre**, con su salida real y el campo del `explain` señalado.

Presentar el mecanismo antes que el problema produce lectores que saben escribir un
`$lookup` pero no saben cuándo no deberían.

### 4.2 Del instinto relacional se parte, no se reniega

El lector llega con un modelo mental que funciona. Dos micro-secciones recurrentes lo
honran antes de corregirlo:

- 🩻 **"Esto sí funciona igual"** — lo que se transfiere sin cambios desde el relacional:
  un índice sigue siendo un índice, un plan sigue siendo un plan, una escritura sin
  índice sigue siendo cara. Tranquiliza y ahorra páginas.
- 🪞 **"Tu instinto relacional dice… y esta vez se equivoca"** — el punto exacto donde el
  modelo mental se rompe, con la medición que lo prueba. **Una por fase A como mínimo**,
  y todas se acumulan en `INSTINTOS.md`.

### 4.3 Nada de cajas negras prematuras

Primero el mecanismo, después la comodidad. Primero la CLI y la consulta a mano; después,
y solo si simplifica de verdad, el ORM o el cliente de alto nivel. Primero `explain` a
pelo; después la herramienta bonita que lo dibuja.

No es que esas capas sean malas: es que ocultan justo lo que el curso quiere enseñar, y
cuando el lector entiende el mecanismo, se aprenden en una tarde.

### 4.4 Analogías, con fecha de caducidad

Se usan **una vez, para abrir la puerta**, y se abandonan diciendo dónde se rompen. *"Una
colección se parece a una tabla; hasta aquí el paralelo funciona. La diferencia es que dos
documentos de la misma colección no tienen por qué tener las mismas claves, y eso cambia
qué significa un índice."*

Cuidado especial con la más peligrosa del tema: **"NoSQL es SQL sin esquema"**. Si aparece,
se desmonta en el mismo párrafo — el esquema no desapareció, se mudó al código y dejó de
estar documentado.

### 4.5 Explica el porqué, no solo el cómo

Cada decisión de modelado lleva su porqué, aunque sea media línea entre paréntesis: por
qué esta partition key y no la otra, por qué embeber aquí y referenciar allá, por qué este
índice compuesto en este orden y no al revés. Un paso sin justificación es un paso que el
lector no puede adaptar cuando su dominio difiera del ejemplo — y su dominio siempre
difiere.

### 4.6 Densidad calibrada

- Un concepto nuevo por vez. Si un bloque introduce tres cosas desconocidas, se parte.
- **Repetir lo importante está bien.** Las cinco preguntas, la frontera transaccional, la
  unidad de lectura y "casi siempre gana Postgres" reaparecen con otras palabras en todo
  el curso. La repetición espaciada funciona; la enciclopedia no.
- Ninguna sección teórica supera las dos pantallas sin un comando, una medición o un
  diagrama.

### 4.7 Cierra los bucles

Si abres un paréntesis —*"esto lo medimos en la Fase 12"*, *"por ahora lo dejamos como
deuda 💸"*—, tiene que cerrarse en algún documento del curso. Un pendiente que nunca se
resuelve es ruido, y el lector deja de creerse las promesas del texto.

---

## 5. 💻 Código, comandos y archivos

> **Regla normativa y no negociable:** todo lo que se ejecuta o se versiona va en inglés
> —nombres de archivo, rutas, variables de entorno, identificadores, colecciones, campos,
> claves, targets— y **todos los comentarios van en español con tildes**.

- **Nombres del dominio, fijos en todo el curso** y en inglés: `vehicle`, `part`,
  `partCatalog`, `assembly`, `workOrder`, `reading`, `failureReport`, `technician`,
  `workshop`, `supplier`. Una fase no renombra una entidad; si necesita una nueva, la
  declara y se añade aquí.
- **`camelCase` para campos** en los motores que no imponen otra cosa; `snake_case` en
  Postgres, Timescale, DuckDB, Cassandra y CockroachDB, que es lo idiomático allí. La
  incoherencia es deliberada y se explica una vez, en `a08`.
- **Nunca `foo`, `bar` ni `test1`.** Todo ejemplo usa el dominio de flota con datos que
  parezcan reales.
- **Bloques de código con su lenguaje declarado**: `ts`, `python`, `sql`, `javascript`,
  `yaml`, `bash`, `text` para salida de terminal.
- **Un bloque, una idea.** Si el fragmento hace tres cosas, se parte en tres con prosa
  entre medias.

### 5.1 Versiones e imágenes

- **Digest, no tag.** Toda imagen se referencia por digest (`image@sha256:…`), y el tag
  legible va en un comentario al lado.
- **Ninguna versión se escribe de memoria.** Se copia de la ejecución real, y el documento
  declara la **fecha de verificación**.
- **Si algo no se verificó, se dice con esas palabras**: *"esto no lo ejecuté; la
  documentación de la versión X lo describe así"*. No hay término medio y no hay vergüenza
  en ello: **declarar lo que no se verificó es la marca de la casa**, no una debilidad.

### 5.2 Nombres de archivo del curso

Fases `NN-slug.md` con dos dígitos. Apéndices `aNN-slug.md`, también con dos dígitos para
que `a09` no quede después de `a10`. Documentos vivos: `INSTINTOS.md` y
`bitacora-de-medicion.md` en la raíz del curso, y `a09-catalogo-de-errores.md`, que es
apéndice y documento vivo a la vez — **no hay un catálogo aparte del apéndice**. Todo en
minúsculas y con guiones, salvo los que el repositorio ya fija en mayúsculas.

---

## 6. 📐 Cómo se presenta una medición

Esta sección es normativa: una medición mal presentada es peor que ninguna, porque parece
evidencia.

**Toda medición del curso se publica con cinco datos**, sin excepción:

1. **Qué se midió**, en forma estructural: viajes, documentos examinados contra devueltos,
   particiones tocadas, fan-out, amplificación de escritura o de espacio.
2. **Sobre qué volumen** de los tres del curso (10 k, 1 M, rotura).
3. **Con qué motor y digest**, y con qué versión de la línea base al lado.
4. **En qué máquina**, si aparece algún tiempo.
5. **Cómo reproducirlo**: el comando exacto, no la descripción del comando.

Formato recomendado, y suficiente:

```markdown
> 📐 **Medición — ficha de vehículo, lectura completa** · 1 M · `mongo@sha256:…` ·
> verificado el 12/09/2026
>
> | | documentos examinados | devueltos | viajes |
> |---|---|---|---|
> | embebido | 1 | 1 | 1 |
> | referenciado | 1 + 3 + N | 1 | 3 + N |
>
> Reproducir: `npm run measure -- vehicle-read --shape embedded --volume 1m`
```

**Los tiempos son contexto, nunca argumento.** Pueden aparecer —son legítimos y a veces
son el gancho de un vídeo— pero jamás sostienen solos un veredicto. Si un párrafo
concluye algo y lo único que tiene debajo es un milisegundo, está mal escrito.

**La apuesta falsable** se escribe **antes** de la medición, en el documento, y no se
edita después. Si la pierdes, la pérdida se cuenta entera y con gusto: es el contenido de
mayor confianza que produce este curso.

```markdown
> 🪞 **Apuesta antes de ejecutar.** Creo que el grafo va a ganar a `WITH RECURSIVE` a
> partir del cuarto salto, por un factor de al menos 5× en filas examinadas.
> **Resultado: la perdí.** Postgres aguantó hasta el sexto salto con el índice correcto.
> Lo que sí rompe no es la profundidad: es el patrón. Ver §7.
```

El **punto de rotura** se documenta con el volumen exacto al que rompió, el **mensaje de
error literal** y qué había que cambiar para salir. El mensaje literal entra además en
`a09-catalogo-de-errores.md`, siempre, aunque ese día no se use.

---

## 7. 🧷 Marcadores, callouts y encabezado

### 7.1 Bloque de encabezado obligatorio

Toda fase abre con el título y, debajo, un blockquote de metadatos:

```markdown
# 🍃 Fase 03 — Documental: levantar y modelar la ficha que nunca tiene los mismos campos

> **Curso:** Ruta NoSQL Lite · Fase 03 de 25 · Bloque I · **10 h**
> **Familia:** documental · **Motor:** MongoDB `mongo@sha256:…`
> **Línea base:** PostgreSQL `postgres@sha256:…` (JSONB)
> **Entorno de ejecución:** TypeScript
> **Volumen:** 10 k para los ejemplos, 1 M para las mediciones
> **Depende de:** Fase 02 · **Habilita:** Fase 04
> **Apéndices de apoyo:** a01, a02, a03, a05, a06
> **Fecha de verificación ejecutada:** 12/09/2026
> **Objetivo:** …
```

El título es descriptivo y con carácter: `Fase NN — Familia: la promesa concreta del
documento`. Nada de `Fase 03 — MongoDB` a secas.

### 7.2 Marcadores de estado

- 💸 **Deuda intencional.** El atajo que se deja a propósito. Se declara, se explica por
  qué se acepta y se dice en qué fase se paga (o que no se paga).
- 🔥 **Opcional o ampliación.** Fuera del alcance base. En ejercicios es el escalón por
  encima de 🔴.
- 💀 **Boss.** Cierra un bloque, no una fase. Ver §9.
- 🟢🟡🟠🔴 **Dificultad de ejercicios.** La escala completa está en §9.
- 🚧 **Fuera de alcance por ahora**, siempre con destino explícito.
- ⭐ **Valoración bibliográfica y nada más.** De una a cinco estrellas, solo en secciones
  de referencias y siempre con su leyenda visible. **No gradúa ejercicios jamás.**

### 7.3 Callouts en blockquote

- 📐 **Medición.** El formato de §6. Es el callout más importante del curso.
- 🪞 **Apuesta falsable / instinto relacional que falla.**
- 💥 **Punto de rotura.** Dónde rompió, con qué volumen y con qué mensaje.
- ⚰️ **Autopsia.** Decisión, argumento, factura a los dos años, coste de salida.
- ⚖️ **Veredicto honesto.** Cuándo NO usar esto.
- 🩻 **Esto sí funciona igual.** Lo que se transfiere del relacional sin cambios.
- 📖 **Traducción.** Del vocabulario relacional al de la familia y vuelta.
- 🧠 **Modelo mental.** La frase que hay que llevarse.
- ⚠️ **Advertencia.** Algo que rompe si lo ignoras.
- 📝 **Nota de contexto.** Por qué un producto es así: su historia, su licencia, la
  restricción que lo originó.
- 💡 **Truco** que ahorra tiempo real.
- 📚 **Referencia rápida inline**, justo donde nace la duda.
- 🩺 **Diagnóstico.** El comando que confirma o descarta una hipótesis.

No hace falta usarlos todos en cada documento. Se usan cuando aportan.

### 7.4 Secciones narrativas recurrentes

- **Dónde estamos.** Apertura: qué dejó la fase anterior y qué falta.
- **Detalles con intención.** Lista corta con las decisiones deliberadas de un bloque de
  código y su porqué.
- **El patrón a memorizar.** Una o dos frases con la lección transferible.
- **Prueba de fuego.** Verificación concreta incrustada en el flujo: *"vuelve a ejecutar
  el `explain` y confirma que `totalDocsExamined` bajó a 1"*.
- **La señal de que quedó bien.** En el cierre, un criterio en forma de cita.

---

## 8. 🧱 Plantilla obligatoria de fase

Los esqueletos completos, con placeholders, están en
[`plantillas-de-capitulo.md`](plantillas-de-capitulo.md). Lo normativo es esto:

**Las fases A —levantar y modelar— llevan estas secciones, en este orden:**

1. Título y bloque de metadatos (§7.1)
2. 🧭 **Dónde estamos**
3. 🎯 **Objetivos de esta fase**, verificables y no aspiracionales
4. 🚫 **Qué NO entra todavía**, con destino exacto
5. 🏗️ **Levantar el motor** — la receta mínima, enlazando a `a01`/`a02`; nunca explicando
   Docker
6. 📖 **El diccionario de la familia** — cómo se dice aquí lo que en SQL se decía así, y
   el 🩻 de lo que funciona igual
7. 🧩 **Modelar el dominio a la manera de la familia** — el grueso de la fase
8. 🪞 **Tu instinto relacional dice… y esta vez se equivoca** — con medición
9. ⚰️ **La situación 3: modelado como si fuera relacional** — el anti-patrón de la familia,
   con números antes y después
10. ⚠️ **Errores comunes y diagnóstico**, con mensaje literal
11. 📋 **Checklist de validación**, ejecutable, en bloque `text` con casillas
12. 🧪 **Ejercicios** (§9)
13. 📚 **Referencias** (§10)
14. 🏁 **Resultado de la fase** y La señal de que quedó bien

**Las fases B —romper, medir y decidir— llevan estas:**

1. Título y metadatos
2. 🧭 **Dónde estamos**
3. 🎯 **Objetivos**
4. 🪞 **La apuesta falsable**, escrita antes de ejecutar
5. 📐 **La medición contra la línea base** — el grueso de la fase
6. 💥 **El punto de rotura**
7. 🚑 **Salir de aquí** — qué se cambia cuando ya te pasó: índice, modelo, motor o
   arquitectura, en ese orden de coste
8. ❓ **Las cinco preguntas, respondidas para esta familia**
9. ⚖️ **Veredicto honesto: cuándo NO usar esto**
10. ⚠️ **Errores comunes y diagnóstico**
11. 📋 **Checklist de validación**
12. 🧪 **Ejercicios**
13. 📚 **Referencias**
14. 🏁 **Resultado** y La señal de que quedó bien

Después de la última sección, fuera de lo que lee el estudiante, cada fase puede cerrar
con **📌 Pendientes sugeridos**: lo que apareció al escribirla y no cabía adentro, con
destino explícito. Es material de autoría.

**Longitud:** 4.000–5.000 palabras de **cuerpo**, medido cortando el documento por el
encabezado de 🧪 Ejercicios. El aparato de ejercicios añade entre 1.300 y 2.800 palabras
encima, y eso está bien: la banda vigila la densidad de la prosa, no el peso del archivo.

**Los apéndices no siguen esta plantilla.** Usan índice de salto rápido, secciones cortas,
una tabla de "cuándo usar qué" al final y de 5 a 10 ejercicios de consulta.

---

## 9. 🧪 Ejercicios

- **Cantidad: 20 mínimo y 30 máximo por fase**, calibrada con la pregunta *"¿cuántas cosas
  distintas enseña esta fase que se puedan comprobar por separado?"*. Una fase con tres
  mecanismos independientes pide más que una que desarrolla uno a fondo, aunque ocupen lo
  mismo.

  > ⚠️ **La cantidad no arregla un aparato flojo.** Subir de 20 a 28 solo tiene sentido si
  > los ocho nuevos comprueban **algo que ninguno de los veinte comprobaba**. Si al
  > escribirlos te sale una variante de otro, el número correcto era 20.

- **Exención declarada:** las fases **00** y **02** son de criterio y no de ejecución. Su
  mínimo baja a 12, y sus ejercicios son de lectura y decisión —*"aquí tienes el esquema
  de un sistema real; di qué frontera transaccional tiene y dónde se disolvería"*—.

- **La escala, completa:**

  | | Nivel | Qué pide |
  |---|---|---|
  | 🟢 | Fácil | Reproducir lo que la fase acaba de mostrar |
  | 🟡 | Intermedio | Aplicar el patrón a otra parte del dominio de flota |
  | 🟠 | Difícil | Combinar patrones, diagnosticar, decidir entre alternativas |
  | 🔴 | Muy difícil | Abierto o adversarial: se entrega algo roto y hay que razonarlo |
  | 🔥 | Extra | Ampliaciones fuera del alcance base |
  | 💀 | Boss de bloque | Cruza las familias del bloque; va al final del bloque, no de la fase |

  **🔥 y 💀 no cuentan para el mínimo.**

- **Distribución ≈ 30 % 🟢, 30 % 🟡, 25 % 🟠, 15 % 🔴**, con un escalón de margen según la
  fase. Las fases B cargan hacia 🟠 y 🔴 porque su materia es medir y romper; las fases A
  cargan hacia 🟢 y 🟡. **La desviación deliberada respecto de la tabla es señal de que se
  calibró**; dos fases seguidas con el reparto idéntico son señal de que se copió.

- **Al menos un tercio son de diagnóstico o de medición**, no de construcción: se entrega
  un modelo mal hecho, un índice que no se usa, una partition key que crea un hot spot, y
  se pide reproducir, medir y explicar. Es el músculo que este curso entrena.

- **Predecir antes de ejecutar.** En 🟠 y 🔴 se pide explícitamente anticipar el número y
  después comparar. Es donde aparecen los modelos mentales rotos.

- **Cada ejercicio cierra con su criterio**: una línea `**Objetivo:**` con lo que hay que
  haber entendido, o una `**Pregunta:**` que solo se puede responder habiéndolo hecho.
  Nunca "modela la colección" a secas — siempre *"…y demuestra con `explain` que
  `totalDocsExamined` es 1"*.

- **Anclados al laboratorio**, con los nombres vigentes del dominio y los volúmenes del
  curso. Nunca `foo`, nunca "tu colección".

- **Agrupados por dificultad, con encabezado de rango y el conteo en el título:**

  ```markdown
  # 🧪 Ejercicios de la Fase 03 (24)

  ## 🟢 Fácil — la colección y su forma (1–7)
  ### 🟢 Ejercicio 1 — …
  **Objetivo:** …
  ## 🟡 Intermedio — embeber y referenciar (8–15)
  ## 🟠 Difícil — cuando el índice no se usa (16–21)
  ## 🔴 Muy difícil — modelos ajenos y autopsias (22–24)
  ## 🔥 Opcionales
  ```

### 9.1 El boss de bloque

Uno por bloque, al cierre de su última fase, en un apartado propio. Sale de preguntarse
*"¿hay aquí un trabajo que solo se resuelva cruzando las familias de este bloque?"*. Si la
respuesta honesta es no, no hay boss.

La señal de que está bien puesto: **empieza con un sistema roto o un encargo completo**,
cruza al menos dos familias y se entrega como artefacto —un informe con mediciones, un
modelo migrado, un diagnóstico con su comando—. Si al escribirlo te cabe en tres líneas,
era un 🔴 con mejor nombre.

### 9.2 El boss global "El Taller"

Opcional, acumulativo y fuera de las horas del curso. Cada bloque le añade un motor y una
capacidad. **Se referencia al cierre de cada bloque, no al de cada fase**, y siempre
marcado como opcional: quien sigue el curso suelto no lo necesita y no debe sentir que le
falta algo.

---

## 10. 📚 Bibliografía y referencias

**Orden de prioridad:** documentación oficial de la versión que usamos, después
especificaciones y papers fundacionales (Dynamo, BigTable, Raft, el paper de LSM),
después libros, después blogs y vídeos. **Siempre se advierte cuando un enlace apunta a
una versión distinta de la del curso**, que con estos motores pasa casi siempre.

Formato: URL completa, título, y una nota de qué versión cubre y por qué vale la pena.
La valoración ⭐ es opcional y, si se usa, lleva su leyenda en el documento.

Cada fase cierra sus referencias con un **orden de lectura sugerido**: qué leer antes de
ejecutar, qué consultar durante y a qué volver después.

> ⚠️ En todas las secciones de referencias va una advertencia explícita de que las URLs y
> los contenidos cambian, y de que la documentación de estos productos suele cubrir solo
> la última versión.

---

## 11. 🐳🦭 Convención Docker / Podman

- **Docker Compose es el camino principal.** Todos los ejemplos se escriben para
  `docker compose`.
- **Cada receta trae su equivalente Podman al lado**, y las tres diferencias que de verdad
  muerden se explican una vez en `a01`: modo rootless, puertos por debajo de 1024 y
  permisos de volumen.
- **Cuando el comando es idéntico, se dice y no se duplica.** Duplicar bloques idénticos
  para "cubrir los dos" es ruido.
- **Aquí no se enseña Docker.** Si una explicación de contenedores pasa de dos párrafos,
  pertenece a `docker-container-legacy/` y se enlaza. Esta regla es la que impide que el
  curso se convierta en otro curso.
- **Sin Kubernetes**, en ninguna forma.
- Los servicios del `compose.yaml` se nombran por familia y no por producto
  (`documental`, `busqueda`, `vectorial`), para que cambiar de motor no rompa media
  docena de comandos escritos.

---

## 12. 🤝 Honestidad: las reglas que no se negocian

Son cinco, y son lo que distingue a este curso de un resumen de documentación:

1. **Nada se publica sin haberse ejecutado.** Ningún número, ninguna versión, ninguna
   salida de terminal inventada o "reconstruida de memoria".
2. **Lo que no se verificó se declara con esas palabras**, en el sitio donde el lector lo
   necesita, no en una nota al pie.
3. **Cada familia gana en algún sitio y pierde en otro**, y las pérdidas van con número.
   Un minicurso que solo trae ventajas está mal escrito.
4. **La apuesta perdida se publica igual que la ganada**, y con más gusto.
5. **"Casi siempre gana Postgres" se dice pronto y en voz alta**, no al final y con la
   boca pequeña. Blinda el curso contra la acusación previsible y además es verdad.

---

## 13. 🔗 Coherencia entre documentos

- **Los nombres del dominio no se renombran** entre fases. Ante la duda, se revisa el
  entregable anterior; no se improvisa un sinónimo.
- **Los apéndices no repiten lo que explica una fase, y viceversa: se enlazan.** Si dos
  documentos explican lo mismo, uno de los dos está mal.
- **Una fase no cita el temario ni el plan de trabajo**, cita a otra fase o a un apéndice.
- 🗑️ **Los documentos desechables no se citan nunca.** `nuevas-ideas.md` y
  `plan-accion-creacion-docs-base.md` son andamio de trabajo y van a desaparecer; ningún
  archivo del curso puede enlazarlos ni apoyarse en ellos. La comprobación está en §15.
- **Git:** tags `fase-NN-<slug>` y prefijo de commit `fNN:`; ejercicios `fNN ejM: …`. Los
  apéndices no llevan tag propio salvo que dejen archivos en el repositorio.

---

## 14. 📓 Los tres documentos vivos

Crecen durante todo el curso y son producto, no apuntes.

- **`a09-catalogo-de-errores.md`** — todo error que aparezca al ejecutar entra aquí **con su
  mensaje literal**, aunque ese día no se use. Formato: mensaje exacto, motor y versión,
  qué lo provocó, cómo se confirma y cómo se sale. Es el activo más buscable del curso.
- **`bitacora-de-medicion.md`** — toda medición publicada, con los cinco datos de §6. Es
  lo que sustituye al `BENCHMARKS.md` del repositorio, y el motivo está declarado en §16.
- **`INSTINTOS.md`** — los 🪞 acumulados de las diez familias: cada punto donde el instinto
  relacional falla, con la medición que lo demuestra y la familia donde apareció.

> 🧭 **Regla operativa que sale gratis y vale mucho:** cuando estés ejecutando, anota el
> error **antes** de arreglarlo. Reconstruir un mensaje de memoria produce mensajes que no
> existen, y un mensaje que no existe no lo encuentra nadie en un buscador.

---

## 15. ✅ Checklist antes de dar por cerrado un `.md`

```text
[ ] El bloque de metadatos está completo, con motor, digest y fecha de verificación
[ ] Todo número del documento salió de una ejecución real
[ ] Lo no verificado está declarado con esas palabras, donde el lector lo necesita
[ ] Toda medición trae los cinco datos de §6 y su comando de reproducción
[ ] La apuesta falsable se escribió antes de la medición y no se editó después
[ ] El punto de rotura trae volumen exacto y mensaje de error literal
[ ] Los errores nuevos entraron en a09-catalogo-de-errores.md con su mensaje literal
[ ] Las mediciones entraron en bitacora-de-medicion.md
[ ] El 🪞 de la fase entró en INSTINTOS.md
[ ] Hay al menos un ⚖️ veredicto honesto, con la pérdida cuantificada
[ ] Ninguna autopsia juzga a una persona (§2.1)
[ ] Postgres aparece como línea base y no como adorno
[ ] Ejercicios: 20–30 (12 en F00 y F02), agrupados, con conteo en el título
[ ] Al menos un tercio de los ejercicios son de diagnóstico o medición
[ ] Cada ejercicio tiene Objetivo o Pregunta, y usa nombres del dominio de flota
[ ] Ninguna explicación de Docker pasa de dos párrafos; lo demás enlaza
[ ] Cuerpo entre 4.000 y 5.000 palabras, medido sin el aparato de ejercicios
[ ] Todo pendiente abierto tiene destino explícito
[ ] Tuteo en todo el documento; cero voseo, cero "usted"
[ ] Código en inglés, comentarios en español con tildes
[ ] grep -rn "nuevas-ideas\|plan-accion-creacion-docs-base" no devuelve nada
```

---

## 16. ⚖️ Excepciones declaradas al `CLAUDE.md` del repositorio

El `CLAUDE.md` permite que un curso se aparte de los defaults **si nombra la regla y dice
por qué**. Estas son las de este curso. Si no estuvieran escritas aquí, cada sesión futura
las "arreglaría" de vuelta.

1. **Los apéndices son transversales al curso, no por minicurso.** Diez apéndices para
   veintiséis fases. Motivo: el laboratorio, el dominio y el arnés de medida son
   compartidos por definición; un apéndice por familia sería escribir diez veces la misma
   receta de contenedores.
2. **`BENCHMARKS.md` se sustituye por `bitacora-de-medicion.md`.** Motivo de fondo, no de
   forma: este curso mide la forma y no la velocidad, así que un archivo de latencias
   sería justo el artefacto que envejece mal. Lo que se versiona son viajes, documentos
   examinados, fan-out y amplificación, con fecha y digest.
3. **Ejercicios: 20–30 por fase**, dentro de la banda del repositorio, con la exención
   declarada de F00 y F02 (12 mínimo) por ser fases de criterio y no de ejecución.
4. **`INSTINTOS.md` se mantiene y es central**, no accesorio.

Todo lo demás del `CLAUDE.md` aplica tal cual: idioma, tono, estructuras recurrentes,
convenciones de markdown, nombres de archivo y flujo de git.

---

## 17. 📌 Pendientes que afectan a esta guía

- **Las versiones y digests de los diez motores están sin fijar** hasta la sesión de
  verificación de laboratorio. Mientras tanto, ningún documento publica un número de
  versión. Cuando se fijen, viven en `a02` y esta guía solo apunta allí.
- **El modelo de embeddings del minicurso vectorial** está sin elegir. Condiciona `a06` y
  la Fase 15.
- **Cassandra o ScyllaDB** para columnar ancha: se decide midiendo cuál levanta con menos
  RAM en las tres plataformas, no por preferencia.
