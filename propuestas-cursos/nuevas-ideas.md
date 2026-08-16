# 🧭 Nuevas ideas — dirección del repositorio

> **Qué es esto:** el registro de una conversación de estrategia, no un plan aprobado. Recoge
> las decisiones que se tomaron, las hipótesis que **todavía hay que verificar** y las ideas
> que valía la pena no perder.
> **Fecha:** 6 de septiembre de 2026
> **Contexto:** se acaba de cerrar `docker-container-legacy` — 36 fases, 16 apéndices,
> ~204.000 palabras, 941 ejercicios, integridad verificada.
> **Estado:** documento de trabajo, **sin versionar** por ahora, igual que los demás.

Hay una idea que atraviesa todo lo que sigue y conviene ponerla primero, porque es el criterio
con el que se decidió cada cosa:

> 🧠 **Lo escaso no es explicar una tecnología. Es medir en lugar de suponer, y declarar lo que
> no verificaste.** Eso es lo que hace distinto al curso de Docker, y es lo que hay que
> preservar en todo lo que venga después.

---

## 1. 🎥 Viabilidad para vídeo, marca personal y LinkedIn

### 1.1 La decisión tomada

**El objetivo no es monetizar, es construir audiencia y marca personal como creador de
contenido técnico.** Eso cambia por completo el criterio: deja de importar el precio y la
plataforma de venta, y pasa a importar la frecuencia, la capacidad de ser encontrado y la
señal que emites.

### 1.2 Por qué Udemy quedó descartado

Tres razones, y la tercera es la de fondo. Es **vídeo primero** y lo que hay son 204.000
palabras de texto que funcionan como referencia con `Ctrl+F`; convertirlo es reescribirlo.
Su mercado **premia la promesa corta**, y "Docker" está saturado de cursos para principiantes.
Y sobre todo: **la audiencia tiene prisa y el curso vende profundidad**. Quien llega quemado
con `node-gyp` quiere la respuesta en veinte minutos, no 114 horas.

### 1.3 Lo que sí se decidió hacer

**YouTube en formato largo, no en directo.** El contenido es diagnóstico y de referencia, no
narrativo: los lives son mal formato. Lo que funciona es la **playlist de vídeos de 10–15
minutos**, y ahí hay un activo que ya está escrito y quizá no se estaba viendo — los catálogos
de fallos de F31 y F32 tienen unos sesenta fallos documentados con su mensaje literal. Cada uno
es un vídeo con un título que la gente **teclea tal cual en el buscador**, porque pega el error.
Tráfico perenne y muy cualificado.

**TikTok y Shorts como embudo, nunca como producto.** Los datos sorprendentes del curso son
ganchos naturales: *"Node nunca publicó binarios `darwin-arm64` para las ramas 10, 12 y 14. No
es que sea difícil: el archivo no existe."* Frena el scroll de un desarrollador en tres
segundos, pero no monetiza solo — alimenta lo demás.

### 1.4 LinkedIn: el activo no es el curso, son los hallazgos

Publicar *"hice un curso de Docker"* es **un post**. Publicar **cómo piensas** es una marca. Y
lo segundo ya está hecho, solo que enterrado en 204.000 palabras.

De la sola sesión de cierre salen cuatro publicaciones con señal de seniority:

- *"Casi toda la documentación dice que el `IMAGE ID` de Docker es el hash del objeto de
  configuración. Lo medí sobre Docker 29 con el image store de containerd y es falso: es el
  digest del index."* Corriges una creencia extendida, con evidencia.
- *"Node nunca publicó `darwin-arm64` antes de la 16. Si crees que instalaste Node 10 en tu Mac
  M, estás ejecutando un binario Intel bajo Rosetta."*
- *"Emular amd64 en Apple Silicon cuesta 18× en CPU pura y 1,5× en carga de I/O. Medido con la
  misma versión de Node en los dos lados."* Un número citable.
- Y el mejor de los cuatro: *"El Dockerfile de mi propio curso no construía. `npm` es un script
  con shebang `#!/usr/bin/env node`, y en esa capa `node` todavía no estaba en el `PATH`."*
  **Admitir y diagnosticar el error propio es el contenido de mayor confianza que existe.**

> 🧭 **Dos reglas sobre LinkedIn que conviene no olvidar.** No es donde la gente aprende, es
> **donde te ven**: el contenido vive en el blog y en YouTube, y ahí va el relato. Y premia la
> **constancia sobre el volumen**: un curso enorme publicado de golpe es un post; sesenta
> autopsias publicadas cada semana durante un año son una marca.

---

## 2. 🔧 Productizar el curso de Docker para vídeo

### 2.1 Lo que ya está a favor

La estructura del curso **ya tiene forma de guion**, y eso no fue accidente: cada fase abre con
"Dónde estamos" —que es el gancho—, sigue con "Objetivos" —la promesa—, desarrolla, y cierra
con "La señal de que quedó bien". Es exactamente el esqueleto de un vídeo.

### 2.2 El trabajo pendiente

Los guiones hay que escribirlos, y **son más breves que el texto**: 10–15 minutos de screencast
son unas 1.000–1.400 palabras de narración, mientras los cuerpos de fase van de 1.900 a 3.600.
La conversión no es 1 a 1 — la Parte I probablemente dé una temporada de unos 13 vídeos.

**Decisión de proceso tomada:** los guiones se trabajan en **una sesión aparte y con contexto
fresco**, y **solo después de verificar Podman**, para que ningún vídeo enseñe algo sin
ejecutar. Ver §5.3.

### 2.3 🔬 Lo que hay que investigar: ¿tiene audiencia el legacy?

**Esto es una hipótesis, no un hecho, y nadie la ha comprobado todavía.** El razonamiento a
favor es que Vue 2 llegó a EOL, que Angular 8 y React 16 siguen vivos en empresas que no van a
migrar este año, y que Apple Silicon ya es el estándar en equipos de desarrollo, así que el
muro lo encuentra gente nueva cada semana. Es dolor **urgente, caro y con presupuesto detrás**.

Pero conviene medirlo antes de invertir meses de grabación:

- **Volumen de búsqueda** de los mensajes de error literales del catálogo, en español y en
  inglés. Es la señal más directa, porque es exactamente lo que la gente pega en el buscador.
- **Qué existe ya** en YouTube en español sobre estos errores, y con cuántas visitas. Si no hay
  nada, puede ser hueco o puede ser que no haya demanda: hay que distinguirlo.
- **Prueba barata antes que apuesta cara:** publicar tres o cuatro autopsias sueltas y mirar qué
  pasa, antes de comprometerse con una temporada completa.

> ⚠️ **El riesgo que hay que tener presente:** el nicho envejece. Dentro de tres años habrá
> menos Vue 2 vivo. Conviene tratarlo como una **ventana de dos o tres años**, no como un activo
> permanente — con la salvedad de que la Parte II (OverlayFS, ABI, namespaces, OCI) envejece
> muchísimo mejor que la Parte I y podría desacoplarse y sobrevivir sola.

---

## 3. 🐳 Un curso de Docker para versiones actuales

### 3.1 El planteamiento

Mismo espíritu —**casi bare metal, entender cómo funciona por dentro**— pero con Node y Debian
actuales. El problema evidente: **el dolor del `npm install` no está**. En un stack moderno todo
instala, todo funciona, y desaparece la urgencia que sostenía el curso original.

### 3.2 Qué se pierde y qué sobrevive

De las seis condiciones que hacían especial al curso legacy, **solo sobreviven una y media**.

Se pierden las dos más valiosas. **El dolor urgente**, porque no hay nada roto. Y **el entorno
congelado**, que era una ventaja estructural enorme: Debian 10 y Node 10 están muertos y por eso
el contenido no caduca nunca. Un curso sobre versiones actuales firma una hipoteca de
mantenimiento.

Sobrevive lo importante: **el mecanismo sigue oculto**, y de hecho las herramientas modernas
esconden más que nunca. Y sobrevive la columna vertebral pedagógica, que no es Docker sino
**"quítalo y reconstrúyelo"** — exactamente lo que hace F13 montando OverlayFS a mano antes de
dejarte confiar en `docker run`.

### 3.3 La idea que sí tiene fuerza: `FROM scratch`

Si el ejercicio es "compilar todo desde cero para entender qué hay dentro", **el escenario más
potente no es el legacy: es la imagen vacía**. Empezar con `FROM scratch` —literalmente nada— y
añadir piezas hasta que algo arranque enseña más sobre qué es una imagen que cualquier
escenario de rescate.

De ahí sale un temario que es todo mecanismo y casi nada versión: qué necesita un binario para
ejecutarse cuando no hay sistema operativo debajo, enlazado estático frente a dinámico, `musl`
frente a `glibc`, imágenes distroless, multi-stage de verdad, y por qué una imagen de 6 MB es
posible y qué renuncias.

**Y toda la Parte II actual encaja tal cual**, sin tocar una línea: capas, copy-on-write, PID 1,
namespaces, OCI, registries y supply chain no dependen de la versión de Node.

### 3.4 Qué habría que decidir

El público cambia: de *"ayúdame, tengo una reunión mañana"* a *"tengo curiosidad por saber cómo
funciona"*. **La curiosidad convierte peor que el dolor**, y conviene saberlo antes de empezar.
La mitigación es la de siempre: apuntar al mecanismo que no se mueve, fijar y declarar
versiones, y mantener el aparato de honestidad —fecha de verificación ejecutada, decir qué no se
probó— que ya está montado.

---

## 4. 🗄️ Una ruta NoSQL corta que unifique

### 4.1 De dónde nace, y por qué eso lo cambia todo

El origen no es académico: son **fricciones reales de proyectos pre-pandemia** donde se eligió
Mongo o Cassandra por moda, con razones superficiales — *"es NoSQL"*, *"no quiero joins"*,
*"meto el JSON completo y listo"*.

Eso no es un temario de bases de datos. **Es una tesis con villano**, y el villano no es Mongo
ni Cassandra: es *elegir por moda y pagarlo dos años después*. Envejece mucho mejor que
cualquier catálogo de productos, porque la moda cambia pero el modo de fallo no.

### 4.2 Qué hay hoy en `ruta-no-sql/`

Conviene tenerlo claro antes de planificar: hay **once carpetas** —diez familias más el capstone
políglota `10-el-arbitro`—, cada una con alcance, guía de estilo, prompts y semilla. Son unas
**150.000 palabras de especificación y cero de contenido**. Está *diseñado*, no escrito.

### 4.3 La forma propuesta: núcleo corto + laboratorios

**El objetivo declarado son 3–4 meses**, así que la unidad tiene que cambiar. Once cursos a la
profundidad del de Docker son dos o tres años; eso está descartado.

**Un núcleo** —la tesis, un dominio único modelado N veces, y el instrumento de decisión—. Ahí
es donde se consolida la comprensión, porque obliga a comparar. Es el grueso del esfuerzo.

**Y laboratorios cortos por familia**, de 15–25 mil palabras, no de 200 mil. Cada uno: levantar
el motor, modelar el mismo dominio, **llevarlo hasta su punto de rotura**, medir y escribir el
veredicto honesto. Todo práctico, casi nada expositivo.

> 📏 **Nota de alcance realista.** En 3–4 meses caben cómodamente el núcleo y unos cuatro o
> cinco laboratorios. Los diez completos es más bien trabajo de un año. Conviene decidir si se
> publica por tandas o si se recorta el número de familias de la primera entrega.

**Los cursos actuales de `ruta-no-sql/` no se tiran**: quedan como la especificación para
profundizar en un modelo concreto cuando la audiencia lo pida. La señal la dará el público —
la apuesta razonable es **vectorial**, por el arrastre de RAG y porque conecta con
`tutorial-rag`.

### 4.4 Las piezas concretas del núcleo

**Las autopsias son el gancho, no la taxonomía.** Con la estructura ⚰️ que `CLAUDE.md` ya
define: decisión → razón que se dio → qué pasó a los dos años → cuánto costó salir.

- *"Elegimos Mongo porque no queríamos joins."* Dos años después hay joins en la aplicación, sin
  transacciones y con inconsistencias que nadie sabe cuándo entraron. **El esquema no
  desapareció: se mudó al código y dejó de estar documentado.**
- *"Elegimos Cassandra porque escala."* Y escala. Pero modelas por consulta, así que cada
  consulta nueva es una tabla nueva más un backfill.
- *"Metimos todo el JSON y listo."* Hasta que el documento crece sin cota, o hasta que dos
  partes del agregado tienen ciclos de vida distintos.
- **Redis como almacén primario** y **Elasticsearch como fuente de verdad** cierran la lista.

**Un dominio, N modelos.** Fijar el dominio y variar solo el modelo — el mismo "harness
consistente" que ya defiende la guía, aplicado a modelado. Candidato: **mantenimiento de
flota**, que ilumina todas las familias sin forzar nada: fichas de vehículo (documental),
telemetría (series temporales), catálogo de repuestos (búsqueda), dependencias entre piezas
(grafos), sesiones (clave-valor), tablero de costes (columnar), la app del técnico sin cobertura
(offline-first) y *"¿qué avería se parece a esta?"* (vectorial).

**El instrumento de decisión, que es la contribución intelectual.** La idea central:
**las preguntas con las que la gente elige no son las que predicen el fracaso.** "¿Tengo esquema
fijo?" y "¿quiero joins?" son superficiales. Las que discriminan de verdad:

- **¿Dónde está la frontera transaccional?** ¿Necesitas atomicidad cruzando entidades? *Es la
  que más caro sale ignorar.*
- **¿Conoces tus consultas de antemano y son estables?** Casi todo NoSQL lo exige, y la gente
  elige NoSQL justo cuando **menos** lo sabe.
- **¿Cuál es la unidad de lectura?** ¿El agregado entero o rebanadas?
- **¿Cuántos saltos tiene tu relación típica?** Uno o dos no justifican un grafo.
- **¿Necesitas exactitud o parecido?**

**Y la parte que casi nadie escribe: "ya elegiste mal, ¿ahora qué?"** Triaje de migración con
400 GB en producción y sin poder parar el negocio. Ahí está el dolor urgente — el equivalente
al `npm install` que revienta — y por eso es la parte con más valor real.

### 4.5 Dos decisiones técnicas que evitan que esto envejezca mal

**Mide la forma, no la velocidad.** Un número de latencia caduca con la versión y el hardware;
una medida estructural no. *"Esta consulta necesita tres viajes y escanea la partición entera"*
sigue siendo cierto dentro de cinco años; *"tarda 12 ms"* no. Prioriza viajes de ida y vuelta,
filas escaneadas, fan-out, amplificación de escritura y qué pasa cuando el dato ya no cabe en un
nodo.

**El curso de Docker es la infraestructura de laboratorio de esta ruta.** Cada familia es un
contenedor con versión fijada y reproducible, sin ensuciar la máquina. Los dos trabajos componen
en vez de competir.

### 4.6 El orden para aprender

No es el orden del catálogo actual, porque el orden óptimo para **aprender** no es el mismo que
para clasificar:

1. **Documental** — el default de todo el mundo y el peor entendido. Aquí viven las autopsias.
2. **Clave-valor** — el modelo de acceso más puro; es el que enseña qué significa la expresión.
3. **Analítico columnar** — el contraste más nítido: por filas contra por columnas.
4. **Series temporales** — especialización del anterior; enseña **cómo una restricción se
   convierte en rendimiento**.
5. **Búsqueda** — índice invertido, y el anti-patrón de usarlo como fuente de verdad.
6. **Grafos** — cardinalidad de travesía.
7. **Vectorial** — parecido en vez de exactitud; conecta con `tutorial-rag`.
8. **Columnar ancho** — el más difícil; necesita todo lo anterior.
9. **Offline-first** — conflictos y CRDTs.
10. **NewSQL** — la síntesis: por qué existe y qué cuesta.

### 4.7 ¿Vale la pena como refresco profesional?

Sí, y con convicción. **Es la habilidad de vida media más larga que hay en software:** los
frameworks caducan cada tres años, los modelos de acceso llevan décadas iguales. **Es la
decisión con el coste de error más alto y la única que no se deshace** — un frontend se
reescribe, un modelo de datos se hereda. **Es lo que separa senior de arquitecto** en un design
review. Y hay un argumento de 2026 que no existía al plantear la ruta: **lo vectorial pasó de
nicho a obligatorio en dos años**, y quien entendía modelos de acceso lo absorbió en una semana.

> ⚠️ **Lo único que puede arruinarlo:** que acabe siendo un resumen de documentación. Lo que
> hizo real al curso de Docker fue estar **ejecutado contra una máquina** — ahí apareció que el
> propio Dockerfile no construía. Si cada laboratorio termina con *"medí esto y me sorprendió"*,
> la ruta vale mucho. Si termina con *"la documentación dice que"*, no.

---

## 5. 🎓 Direcciones de aprendizaje y de compartir conocimiento

### 5.1 El posicionamiento

No es *"enseño Docker"* ni *"enseño bases de datos"*. Es **"mido en lugar de suponer, y digo lo
que no verifiqué"**. Es una postura escasa y reconocible en tres segundos por quien decide.

De ahí salen tres formatos con papeles distintos: el **blog o libro** para la profundidad
buscable, **YouTube largo** para las autopsias que la gente busca por su mensaje de error, y
**LinkedIn** para el relato y el hallazgo. Los shorts, si acaso, como embudo.

### 5.2 La continuidad de audiencia que conviene explotar

**Quien acaba de rescatar el Angular 8 es exactamente quien tiene que decidir qué lo
reemplaza — y con qué base de datos.** Los cursos del repositorio no son islas: `docker-legacy`
es la infraestructura de laboratorio de la ruta NoSQL, y la ruta NoSQL es la decisión que sigue
al rescate. Secuenciados así, **la audiencia se acumula en vez de reiniciarse**.

### 5.3 Orden de trabajo acordado

1. **Verificar Podman** en F24–F26, que es el último hueco declarado del curso de Docker.
2. **Guiones de vídeo**, en sesión aparte y con contexto fresco, ya sin nada sin ejecutar.
3. **Ruta NoSQL light** — semana 0 primero (tesis, dominio único e instrumento de decisión) y
   luego los minicursos de familia, uno cada dos semanas. Es el trabajo activo; ver §6.
4. **Ruta NoSQL larga**, sin plazo: los cursos profundos de `ruta-no-sql/` se escriben despacio,
   empezando por las familias que la audiencia de la light señale.

### 5.4 Advertencias que conviene releer antes de empezar cada cosa

**El tono de las autopsias es autopsia, no juicio.** Si suena a *"quien eligió Mongo es tonto"*,
pierdes justo al lector que más lo necesita: el que lo eligió. La honestidad que ya practica el
repositorio —cada familia gana en algún sitio y pierde en otro— es lo que hace que ese lector se
quede.

**La curiosidad convierte peor que el dolor.** Vale para el Docker moderno y para la ruta NoSQL.
Cuando se pueda elegir, apuntar a lo que hoy hace perder tardes.

**Ojo con la hipoteca de mantenimiento.** El curso legacy puede congelarse porque todo lo que
enseña está EOL, y esa es una ventaja estructural que no se repite. Todo lo demás se mueve, así
que hay que apuntar al mecanismo, fijar versiones y declarar fechas.

---

## 6. ⚡ Ruta NoSQL **light** — la que se hace primero

### 6.1 La decisión tomada

La ruta corta del §4 se concreta en un formato propio y **pasa a ser el trabajo activo**:
**diez minicursos de dos semanas, uno por familia, más el capstone políglota**. La ruta larga
—los once cursos a profundidad, tal y como están especificados en `ruta-no-sql/`— **no se
cancela**: se va escribiendo despacio, curso a curso, allí donde apetezca más profundidad o
donde la audiencia la pida. No hay prisa, y ese es exactamente el punto: son dos horizontes
distintos y no compiten.

> 🧠 **El argumento decisivo no es pedagógico, es de cadencia.** La ruta larga no produce nada
> publicable durante un año. La light produce **un ciclo completo de contenido cada dos
> semanas** — y el §1.4 ya dejó dicho que lo que construye marca es la constancia, no el
> volumen.

Y hay un segundo argumento que resuelve una duda abierta del §4.3: **el minicurso de cada
familia es el tráiler del curso profundo de esa familia**. En seis meses la light dice, con
datos de audiencia en lugar de intuición, qué familias merecen los 200.000 palabras. La
apuesta previa era vectorial; ahora no hay que apostar, hay que medir.

### 6.2 La aritmética

Las familias son **diez**, no nueve: documental, clave-valor, analítico embebido, vectorial,
grafos, columnar ancha, búsqueda, offline-first, series temporales y NewSQL. Con el capstone
políglota, la cuenta queda así:

| Bloque | Duración | Acumulado |
|---|---|---|
| Semana 0 — tesis, dominio e instrumento de decisión | 1 semana | 1 |
| Diez minicursos de familia × 2 semanas | 20 semanas | 21 |
| ⚖️ Políglota (capstone) | 8 semanas | 29 |

**29 semanas ≈ 6,7 meses**, a un ritmo de **10 horas semanales** (20 h por minicurso). No hace
falta recortar ninguna familia para que la cuenta cierre.

### 6.3 Qué es —y qué no es— un minicurso de dos semanas

No es "volverse experto", y el curso lo dice en voz alta desde la primera línea. Es **tocar el
producto**: levantarlo desde una imagen de Docker Hub, modelar el dominio, ejecutar la CLI,
observar y medir. La audiencia son ingenieros de software con experiencia, así que **no se
explica qué es una CLI ni qué es Docker** — eso solo acelera la curva.

El formato rompe deliberadamente dos convenciones de `CLAUDE.md`, y conviene que quede escrito
para que nadie lo "arregle" después:

- **Sin ejercicios por curso.** El ejercicio es ejecutar todo lo que el curso trae y observar
  qué pasa.
- **Sin apéndices por curso.** Los apéndices son **transversales a la ruta**: guías rápidas
  compartidas (Docker, CLIs, comparativa de motores, glosario), no una cola por minicurso.
- **Boss project opcional y fuera de las 20 h**, para quien quiera seguir. Ver §6.6.

> ⚠️ **El único riesgo serio de este formato es degenerar en resumen de documentación** — el
> mismo que ya avisa el §4.6. Dos anclas baratas lo evitan, y ninguna cuesta ejercicios:
>
> - 🪞 **Una apuesta falsable por minicurso.** Antes de ejecutar, escribes la predicción y el
>   número que esperas. Después mides. Si aciertas, aburrido; si fallas, tienes el vídeo.
> - 💥 **Un punto de rotura por minicurso.** Levantar y modelar lo hace cualquiera; llevar el
>   motor hasta que se rompe, y decir cuánto costó, no. Es lo que separa esto de los mil
>   "MongoDB en 20 minutos" que ya existen.

### 6.4 Semana 0 — decidida, va entera y va delante

Sin ella, la ruta light son diez tutoriales de producto puestos en fila. Con ella, es una tesis
con diez comprobaciones. Contiene, en versión comprimida, las tres piezas del §4.4: las
**autopsias** que dan el gancho, el **dominio único** —mantenimiento de flota— que se va a
modelar diez veces, y el **instrumento de decisión** (frontera transaccional, estabilidad de
las consultas, unidad de lectura, saltos de la relación típica, exactitud contra parecido).

La alternativa que se descartó era repartir el instrumento en media página por minicurso: más
fácil de escribir, pero deja la tesis diluida y le quita a la ruta lo único que no se puede
copiar de la documentación. El marco narrativo con el que se cuenta va en §6.5.

### 6.5 El marco narrativo: dos situaciones en la semana 0 y una tercera por familia

**Situación 1 — sale bien con SQL, pero se elige NoSQL por moda.** El jefe insiste en Mongo o
Cassandra porque toca.

**Situación 2 — la inversa: el arquitecto se queda en su zona de confort relacional** cuando el
problema lo resuelve mejor otro modelo, o varios en conjunto.

> 🧠 **No son dos problemas: son la misma decisión tomada por el mismo motivo malo.** En la 1 se
> elige por moda, en la 2 por comodidad, y en ambas el criterio real fue *quién lo dice y qué me
> resulta familiar*, no *qué modelo de acceso tiene el dominio*. El villano del §4.1 tiene dos
> caras, hype y zona de confort, y las dos se curan con la misma pregunta — que es justamente el
> instrumento de decisión de la semana 0.

⚠️ **El antagonista no puede ser el jefe ni el arquitecto.** Si el villano es una persona,
pierdes al lector que tomó esa decisión, que es el que más lo necesita (§5.4) — y en la
situación 2 ese lector **es literalmente la audiencia objetivo**: ingenieros con experiencia y
sesgo relacional. La versión que funciona defiende el argumento antes de desmontarlo: quien pide
Mongo no suele decir una tontería, dice *"el esquema va a cambiar mucho"* o *"esto tiene que
escalar"*, que son preocupaciones legítimas con el instrumento equivocado. Autopsia, no juicio:
en la mesa está la decisión, no la persona.

#### El corte de la situación 1: Mongo como una tabla SQL grande con JSONs

El diagnóstico cabe en un short y es verificable en diez segundos contra la colección de
cualquiera: **si todos los documentos tienen las mismas claves y ninguna anida más de un nivel,
no tienes una base documental — tienes una tabla cara.**

Pero ese corte solo ya es casi consenso; la gente asiente y no cambia nada. **El material está
en el segundo acto:** aparece la segunda colección, hay que juntarlas, el join se hace en el
código de la aplicación, y ahí se disolvió la frontera transaccional sin que nadie lo escribiera
en ningún sitio. Conecta directo con la primera pregunta del instrumento (§4.4), la marcada como
*la que más caro sale ignorar*. El coste no fue la flexibilidad desperdiciada: fue que dos años
después nadie sabe cuándo entraron las inconsistencias ni cuáles son.

📝 **Precisión que hay que mantener, porque es la marca de la casa:** Mongo **sí** tiene
transacciones multi-documento desde la 4.0. La autopsia honesta no es *"no había
transacciones"*, es *"las había, exigían réplica, y nadie las usó porque eligieron Mongo
justamente para no pensar en eso"*. Y de paso regala una entrada del catálogo de errores con
mensaje literal: `Transaction numbers are only allowed on a replica set member or mongos`.

#### Los dos candidatos de la situación 2, que no son igual de sólidos

**Pivotes y cálculos horizontales — el fuerte.** Tablas anchas llenas de `CASE WHEN` para
pivotar, y la métrica nueva que exige un `ALTER TABLE` sobre 200 millones de filas. No apunta a
"NoSQL": apunta a **columnar/analítico**, que es donde Postgres pierde de forma estructural y no
por poco — escanear filas enteras para agregar tres columnas es medible en columnas leídas
contra filas leídas, sin depender de hardware ni versión. Es de los pocos casos donde el "eso ya
lo hace Postgres" no salva. Y tiene un efecto secundario pedagógico enorme: **DuckDB habla
SQL**, así que el episodio demuestra que lo que cambia el resultado no es el lenguaje de
consulta ni la etiqueta NoSQL, sino el modelo de acceso. Es la tesis de la ruta probada con un
contraejemplo que rompe la etiqueta.

**Jerarquías contra grafos — el débil, y por eso el mejor formato.** Tal cual es el ejemplo más
atacable posible: `WITH RECURSIVE` aguanta un árbol de categorías perfectamente, y meter Neo4j
para bajar cuatro niveles **es el anti-patrón que la propia ruta declara**. Por eso se da la
vuelta y se convierte en **la apuesta falsable que se pierde en público** (§6.3): se abre con el
dolor reconocible —nested sets, el `ALTER` que reordena medio árbol—, se predice que el grafo
gana, se mide, **y Postgres aguanta**. Se reconoce la derrota y *ahí* se sube la apuesta: lo que
rompe no es descender un árbol, es **buscar un patrón** — ciclos, caminos entre dos nodos
cualesquiera, anillos de fraude, profundidad variable y desconocida de antemano. Ese es el punto
donde el grafo no es más cómodo, sino que lo otro no se puede escribir.

> 💡 Ese episodio es probablemente el de mayor confianza de toda la ruta, por la misma razón que
> lo fue el Dockerfile propio que no construía: **admitir en cámara que tu instinto falló vale
> más que diez benchmarks favorables** — y te inmuniza contra la acusación de estar vendiendo
> motores.

#### El problema epistémico de la situación 2, y su antídoto

La situación 1 tiene evidencia: pasaron dos años, hubo un coste, se puede contar. La 2 obliga a
demostrar un **contrafáctico** —"habría ido mejor así"—, que es el terreno exacto donde se
resbala hacia *"la documentación dice que"*. El antídoto ya está montado: **dominio fijo, arnés
consistente y medir la forma en vez de la velocidad** (§4.5). No se dice "es mejor", se dice
*"esta consulta necesita tres viajes y escanea la partición entera; esta otra, uno"*. Eso no es
opinión y no caduca. Casi nadie lo hace porque implica montar las dos.

Y hay que decir en voz alta, desde el principio, que **la mayoría de las veces gana Postgres**
—JSONB, full-text, pgvector, particionado— y que cuando hace falta otro motor suele ser **al
lado** y no en lugar de. Blinda contra la acusación previsible y además es título directo:
*"El 70% de los casos donde crees que necesitas NoSQL los resuelve Postgres. Vamos a por el 30%
que no."*

Ordenadas por lo defendibles que son, de más a menos: **vectorial** (no hay equivalente
relacional, punto), **búsqueda** (nadie defiende un `LIKE '%x%'` a escala), **columnar y
pivotes** (derrota estructural medible), **series temporales** (retención y compresión) y, al
final, **grafos** — la más discutible, y por eso la mejor para el formato de apuesta perdida.

#### La situación 3, que va una por minicurso

Falta el caso más común de todos y no cabe en la semana 0: **elegiste bien la familia y aun así
te fue mal, porque la modelaste como si fuera relacional.** Mongo lleno de referencias,
Cassandra modelada por entidades en vez de por consulta. Reparto limpio: **la semana 0 carga las
situaciones 1 y 2 a nivel de ruta, y cada minicurso carga su versión de la 3** — que además
entrega gratis el 🪞 *"tu instinto relacional dice… y esta vez se equivoca"* en cada familia.

#### Dos consecuencias de reparto

**Las familias se parten solas entre las dos situaciones.** Donde el hype hace daño es
documental y clave-valor: ahí viven las autopsias de la situación 1. Donde la comodidad hace
daño es búsqueda, series temporales, grafos con travesía profunda y vectorial. Columnar ancha y
NewSQL quedan en medio y admiten las dos lecturas, que las hace las más interesantes de contar.

**Y el "varios en conjunto" es el capstone.** La forma honesta de casi toda situación 2 no es
reemplazar, es **añadir un motor al lado y pagar la factura de tenerlo** — que es exactamente el
políglota. Si la semana 0 lo anuncia desde el principio, el capstone deja de ser un ejercicio
final y pasa a ser la conclusión que la ruta llevaba prometiendo seis meses.

### 6.6 El boss project: creciente, opcional y con serie propia

**Uno solo, acumulativo, sobre el dominio de flota**, que crece con cada minicurso en lugar de
diez proyectos sueltos. Es mejor portafolio, es mejor narrativa y, sobre todo, **es una serie
de vídeo distinta de la del curso**: la ruta enseña el modelo, el boss project enseña el
sistema creciendo. Dos playlists, dos públicos, un solo trabajo de campo.

El coste que hay que aceptar es que **acopla los minicursos**, y eso choca de frente con el
orden de publicación libre del §6.9. Se resuelve porque es **opcional**: quien sigue la ruta
suelta no lo necesita, y quien lo sigue acepta el orden canónico. Es la única parte de la ruta
que se consume en secuencia.

### 6.7 El plan de contenido, que es la razón de ser del formato

**El problema honesto de partida:** el curso legacy tenía dolor buscable —mensajes de error
literales que la gente pega en el buscador— y NoSQL, a primera vista, no. El §5.4 ya lo avisó:
la curiosidad convierte peor que el dolor.

**Y la solución está dentro del propio formato:** el dolor buscable de NoSQL sí existe, solo
que **aparece al ejecutar**, y este formato es exactamente ejecutar. `E11000 duplicate key
error`, `Transaction numbers are only allowed on a replica set`, `ALLOW FILTERING`, `OOM
command not allowed when used memory > 'maxmemory'`, `cluster_block_exception ...
read-only-allow-delete`, el aviso de producto cartesiano de Neo4j. Es el catálogo de fallos de
F31/F32 en versión NoSQL, y sale gratis si se lleva bitácora mientras se graba.

> 🧭 **Regla operativa:** todo error que aparezca al ejecutar se anota con su **mensaje
> literal**, aunque ese día no se use. Ese catálogo, no las lecciones, es el activo de YouTube.

De ahí salen los tres formatos, cada uno con su papel:

- **YouTube largo** — la autopsia de cada error, con el título que la gente teclea tal cual.
  Tráfico perenne y muy cualificado.
- **TikTok y Shorts** — el punto de rotura, que es gancho casi sin edición: *"le metí 100k
  documentos y la consulta pasó de 4 ms a 9 s; mira por qué"*. Visual, numérico, cuarenta
  segundos.
- **LinkedIn** — la apuesta falsable fallada. Predecir en público, equivocarse y publicar el
  número es el contenido de mayor confianza que existe, igual que lo fue el Dockerfile propio
  que no construía.

**Sobre los directos, con un matiz respecto al §1.3.** Allí se descartaron para el curso de
Docker, y con razón: aquel contenido es diagnóstico y de referencia. Este es **ejecución**, que
es lo único que el directo hace mejor que el vídeo editado — y los errores en vivo son mejor
contenido que los ensayados. Aun así, la idea de cuatro directos por minicurso son **cuarenta
directos**, y eso no se sostiene desde cero. El plan realista:

1. Los **dos primeros minicursos, todo editado**. Un directo con tres espectadores es un vídeo
   mal grabado.
2. A partir del tercero, **dos directos por minicurso** (uno al cierre de cada semana), no
   cuatro. Se sube a cuatro solo si los números lo justifican.
3. Cada directo se diseña **para sobrevivir como VOD**, con capítulos, porque casi todas las
   vistas llegan después.

### 6.8 Cuatro decisiones estructurales que evitan dolor luego

**Las últimas versiones son una hipoteca, no una ventaja.** La intuición de "sin legacy no hay
problema" es al revés: el curso legacy se puede congelar porque todo lo que enseña está EOL, y
esta ruta se mueve sola. Mitigación: fijar **digests** de imagen y no tags, declarar fecha de
verificación ejecutada, y **medir la forma y no la velocidad** (§4.5) — viajes de ida y vuelta,
particiones escaneadas, fan-out y amplificación de escritura no caducan con la versión. Lo que
envejece de verdad son los `compose.yaml`, y esos se actualizan en diez minutos.

**La excepción editorial hay que escribirla.** `CLAUDE.md` exige 20–30 ejercicios y apéndices
por curso. Esta ruta los quita a propósito. Si no queda declarado en su propia guía de estilo,
cada sesión futura lo va a "arreglar" de vuelta.

**Carpeta aparte.** `ruta-no-sql-light/`, que **consume** los `*-alcance.md` y `*-semilla.md`
existentes como fuente pero no vive dentro de `ruta-no-sql/` — esas once carpetas son la
especificación de los cursos profundos y no se tocan.

**El curso de Docker sigue siendo la infraestructura de laboratorio** (§4.5), y en la light
cuenta el doble: diez motores en seis meses sin ensuciar la máquina es lo que hace viable el
ritmo.

### 6.9 Orden de aprendizaje contra orden de publicación

El orden del §4.6 es el óptimo para **aprender**, no para **publicar**. Para contenido,
documental sigue siendo el primero por ambos criterios —es el default de todo el mundo, el peor
entendido y donde viven las autopsias—, pero **vectorial debería salir mucho antes** de lo que
le tocaría: arrastre de RAG y conexión directa con `tutorial-rag`.

La ventaja de este formato es que **puede permitírselo**. Los minicursos son bastante
independientes entre sí, así que el README declara el orden de aprendizaje y la publicación
sigue otro. Con la ruta larga eso no se podía hacer. La única atadura al orden canónico es el
boss project acumulativo del §6.6, y por eso es opcional.

### 6.10 Lo que queda abierto de la light

- **Qué familia va segunda en publicación.** Documental abre; después hay tensión entre seguir
  el orden de aprendizaje (clave-valor) y el orden de tracción (vectorial).
- **Si los apéndices transversales se escriben antes o se acumulan sobre la marcha.** Escribir
  antes cuesta semanas que no están en el presupuesto de 29; acumular obliga a reeditar.
- **Cuánto de la semana 0 es público.** Es la pieza con más valor intelectual de toda la ruta y
  probablemente el mejor contenido de LinkedIn del año.

---

## 7. 🔩 La vía geek: `propuesta-complemento-docker/`, Lima y el "from scratch"

> **Qué se revisó:** las trece piezas de `propuesta-complemento-docker/` contra las 36 fases y
> 16 apéndices de `docker-container-legacy/`, para decidir si eso es un apéndice del curso, un
> curso nuevo, o material que no debería publicarse tal cual.
> El doc 13 —compra de hardware en Colombia— queda **fuera del alcance** de esta revisión por
> decisión explícita: es logística personal, es perecedero y es local. No es contenido de curso.

### 7.1 El veredicto corto, antes del detalle

De los trece documentos, **doce ya están cubiertos por el curso —y en varios puntos el curso los
contradice con medición— y uno abre un hueco real**. El hueco es el 09, compilar Node desde
fuente. Todo lo demás es la versión pre-verificación de lo que el curso ya cerró.

Eso no es un fracaso de la propuesta: es que la propuesta **es anterior**. Fue la conversación
exploratoria de la que salió el curso, y el curso ya la absorbió, la ejecutó y la corrigió. Lo
que hay que rescatar es la parte que el curso decidió no hacer, no la que hizo mejor.

### 7.2 Qué ya está cubierto, y dónde el curso gana la discusión

El solapamiento es casi total y conviene verlo pieza a pieza, porque decide qué se importa:

| Doc de la propuesta | Dónde ya vive en el curso |
|---|---|
| 04 glibc vs musl | [F14](docker-container-legacy/14-abi-libc-y-prebuilds.md) ABI, libc y prebuilds |
| 05 paquetes que explotan | F14 + F15 laboratorios de dependencias nativas + F31/F32 catálogo de fallos |
| 06 estrategia Rosetta/QEMU/nativo | F21 arquitecturas y emulación + F22 Apple Silicon |
| 07 rendimiento Colima/QEMU | F21 §emulación + a07 Colima y Lima |
| 08 errata Rosetta macOS 27 | F22, ya escrito con la versión corregida |
| 10 templates de Dockerfile | F02, F07, F12 y `src/` (86 archivos ejecutados) |
| 11 referencias | [F35](docker-container-legacy/35-referencias.md) |
| 01/02/03 puerta de entrada, resumen, póster | README + `0-programa-del-curso.md` |

Y hay tres puntos donde no es solapamiento sino **conflicto**, que es lo que hace que estos
documentos no se puedan reciclar por copia:

- **"Rosetta desaparece en macOS 28"** aparece afirmado en los docs 02, 06 y 07, y el propio doc
  08 lo desmiente. El curso ya nace con la versión corregida. Publicar el material viejo sería
  reintroducir a mano un error que ya costó una errata.
- **Los números de emulación no coinciden.** La propuesta dice "QEMU ~10×, Rosetta ~1,2×"; el
  curso midió **18× en CPU pura y 1,5× en carga de I/O**, con la misma versión de Node en los dos
  lados. No es un matiz: es la diferencia entre un número heredado y un número ejecutado, que es
  justamente la marca de la casa (§1.4).
- **El doc 09 no está ejecutado**, y se le nota. Dice "crear una VM Debian 10 (buster) ARM64" y a
  continuación arranca `template://debian-12`; instala `python2.7`, que **bookworm ya no
  empaqueta**; y usa `--shared-openssl` para compilar Node 14 contra la OpenSSL del sistema, que
  en Debian 12 es la rama 3.x mientras Node 14 espera 1.1.1. Las tres son hipótesis de fallo, no
  hechos verificados —hay que ejecutarlas—, pero apuntan todas al mismo sitio: **ese documento
  no ha tocado una máquina**.

> 🧭 **La regla que sale de aquí y conviene no olvidar.** El material de la propuesta entra al
> repositorio **reescrito y ejecutado, o no entra**. Importar por copia degradaría lo único que
> distingue al curso, y lo haría en la dirección más cara: hacia atrás.

### 7.3 Lo que sí es hueco real: compilar Node desde fuente

El curso establece el muro con toda claridad —**Node nunca publicó `darwin-arm64` para las ramas
10, 12 y 14, el archivo no existe**— y lo resuelve por la vía sensata: contenedor `amd64` con
traducción de binarios. Pero deja sin responder la pregunta que cualquier lector con curiosidad
se hace treinta segundos después:

> *"Si el binario no existe… ¿por qué no lo construyo yo?"*

Esa pregunta es **exactamente la columna vertebral pedagógica del curso** —"quítalo y
reconstrúyelo" (§3.2)— aplicada a la única pieza que el curso trata como dada. F13 te hace montar
OverlayFS a mano antes de dejarte confiar en `docker run`; el equivalente aquí es construir el
binario de Node antes de dejarte confiar en `FROM node:14`. Es el mismo movimiento, y falta.

Y cierra un bucle que ya está abierto en el propio curso: [a03](docker-container-legacy/a03-binutils-y-elf.md)
enseña a leer un ELF con `file`, `nm` y `readelf`, pero siempre sobre binarios que alguien más
compiló. Aquí lees el ELF que **acabas de producir**, y el `ELF 64-bit LSB, ARM aarch64` deja de
ser un dato del apéndice y pasa a ser la prueba de que funcionó.

**Y tiene un cierre honesto propio**, que es lo que lo hace publicable: al final del apéndice,
tras veinticinco minutos de `make -j`, la conclusión es **que casi nunca deberías hacer esto en
el trabajo**. Te queda un Node que nadie parchea, que no coincide con el de tu CI, y cuya única
ventaja sobre la imagen `amd64` es que no emula. Se hace una vez, para entender. Es la misma
estructura del ⚖️ veredicto honesto que ya usa cada fase.

### 7.4 La forma concreta: un apéndice, no trece documentos

**`a17-compilar-node-desde-fuente.md`**, dentro de `docker-container-legacy/`, siguiendo la
convención de sus apéndices —que no es la de las fases: los dieciséis actuales suman ~30.000
palabras y 91 ejercicios, o sea unas 2.000 palabras y media docena de ejercicios cada uno, no las
25–35 que exige una fase—. El recorrido:

1. **Por qué Lima y no un contenedor.** No es capricho geek: dentro de un contenedor el toolchain
   ya viene resuelto por la imagen base, y el ejercicio es precisamente verlo montarse. La VM es
   el sustrato más parecido a bare metal que hay en un Mac sin reiniciarlo, y **el curso ya tiene
   Lima instalado y explicado en [a07](docker-container-legacy/a07-colima-y-lima.md)**, así que
   el apéndice no añade herramienta nueva: reutiliza una que el lector ya tiene arrancada.
2. **`./configure` como material didáctico**, que es donde el doc 09 acierta: `--shared-openssl`,
   `--with-intl`, `--debug` y `--prefix` explican, cada uno, una decisión de empaquetado que
   luego el lector reconocerá en las imágenes oficiales.
3. **La compilación y sus fallos**, anotados con **mensaje literal** — la regla operativa del
   §6.7 aplicada aquí. Si la hipótesis de OpenSSL 3 se confirma, ese fallo solo ya vale el
   apéndice y es entrada directa al catálogo de F31/F32.
4. **Verificar con las herramientas de a03**, cerrando el bucle.
5. **Convertirlo en Dockerfile multi-stage** —etapa de compilación, etapa de runtime con solo el
   binario— que conecta con F12 y con [F28](docker-container-legacy/28-publicar-la-imagen.md):
   compilas una vez, publicas, y el equipo entero deja de compilar.
6. **El veredicto honesto de §7.3.**

Lo que **no** entra: los docs 01–08, 10 y 11 no se importan. El 13 tampoco, ya dicho.

### 7.5 ¿Y el minicurso geek "todo desde cero sobre Lima"?

Aquí conviene separar dos cosas que la propuesta mezcla y que **no son el mismo ejercicio**,
porque de la confusión sale un temario imposible de 200 horas:

**`FROM scratch` es sobre la frontera del contenedor.** Imagen vacía, un binario estático dentro,
y la pregunta de qué necesita un proceso para arrancar cuando debajo no hay nada. Es el §3.3 de
este documento, y es **corto, medible y perenne**: enlazado estático contra dinámico, distroless,
por qué caben 6 MB y qué se renuncia.

**LFS es sobre la frontera del sistema.** Construir la distribución entera, veinte horas de
seguir un libro, y la pregunta de qué es una distro. Es otro ejercicio, con otro coste y otro
público.

> 🧠 **El puente que los une, y que es el único ángulo que aquí no está commoditizado.** Un
> contenedor no trae kernel: trae *el resto*. LFS construye exactamente ese resto a mano. Así que
> LFS deja de ser una hazaña y pasa a ser **el instrumento de medida de la frontera del
> contenedor**: construyes el userland a mano, y después preguntas qué hay realmente dentro de
> `debian/eol:buster` y qué de eso tuviste que fabricar tú. Eso ya no es un tutorial de LFS, es
> la tesis del curso —**el contenedor contiene el toolchain, no el proyecto**— demostrada desde
> el otro lado.

Con esa separación, el minicurso geek tiene una escalera natural que ordena todo lo que hay
disperso en el doc 12, y que además va **de barato a caro**:

1. `FROM scratch` con un binario estático — una tarde.
2. Un rootfs mínimo a mano con `debootstrap`, y meterlo en una imagen — una tarde.
3. Un "contenedor" sin Docker: `unshare`, cgroups v2 a mano, `pivot_root` — el clásico "Docker en
   100 líneas". **Y esto el curso casi lo tiene**: F13 monta OverlayFS a mano y F25 explica los
   user namespaces; falta ensamblar las piezas en un solo ejercicio.
4. Compilar Node desde fuente — el a17 de §7.4.
5. LFS virtualizado — el jefe final, y solo aquí.

### 7.6 LFS, YouTube y TikTok: dónde funciona y dónde no

La intuición de que esto da vídeo es correcta, pero **no del tipo de vídeo que este repositorio
sabe hacer**, y la distinción decide si vale la pena.

**El activo de YouTube que el §1.3 identificó es el error literal**: alguien pega
`gyp ERR! stack Error: EACCES` en el buscador y aterriza en tu autopsia. Tráfico perenne,
cualificado, y por eso barato de sostener. **LFS no tiene ese tráfico.** Sus fallos son fallos
que solo comete quien ya decidió hacer LFS —un público diminuto y ya servido por el propio libro,
que es excelente— y no hay una masa de gente buscando salir de ese dolor un martes por la tarde.

Lo que LFS sí tiene es **formato de hazaña**: la barra de progreso, el time-lapse, el primer
arranque del sistema que construiste. Eso funciona en TikTok y en Shorts —que el §1.3 ya define
como embudo y nunca como producto— y funciona en LinkedIn como relato. No funciona como playlist
de referencia.

> ⚠️ **Y hay un riesgo de fondo que conviene decir en voz alta: LFS es seguir un libro.** Veinte
> horas de teclear lo que otro ya escribió, sin una sola decisión que medir y sin una sola
> sorpresa que reportar. Es **exactamente el modo de fallo** contra el que avisan el §4.6 y el
> §6.3 —degenerar en resumen de documentación— solo que en su versión más laboriosa. El
> antídoto es el mismo de siempre y es el ángulo del §7.5: **la comparación es el contenido, no
> la construcción.** Si el vídeo es "hora 14 de LFS", no hay nada. Si es "esto es lo que
> `debian/eol:buster` trae hecho y esto tuve que fabricarlo yo", hay una tesis.

### 7.7 ¿Curso aparte? Sí, pero no ahora — y probablemente no como curso

Las tres opciones, con su coste real:

**El apéndice `a17` (§7.4) se hace ya.** Son unas 2.000 palabras más una tarde de compilación en
una VM que ya está montada. Cierra un hueco declarado, encaja en la estructura existente, y
produce material de vídeo sin trabajo extra. **Es la única pieza de las tres que recomendaría sin
reservas.**

**El minicurso geek no se hace como curso propio, se hace como Parte III.** Y esto resuelve, de
paso, uno de los cabos sueltos del §8: la escalera del §7.5 —peldaños 1, 2 y 3— **es** el temario
del Docker moderno del §3.3. No son dos proyectos: es el mismo, y el §3.3 ya había llegado a la
conclusión de que toda la Parte II actual encaja debajo sin tocar una línea. Un curso geek aparte
duplicaría F13, F25 y F14 para volver a explicar lo mismo con otro nombre.

**LFS no es un curso, es una serie de laboratorio.** No tiene ejercicios graduados, no tiene
veredicto honesto, no tiene modo de fallo que catalogar; tiene un libro que ya existe y está
mejor escrito de lo que quedaría la versión resumida. Como contenido, sí: **una serie corta de
laboratorio con el ángulo comparativo del §7.5**, y como jefe final del peldaño 5. Como curso del
repositorio, no.

> ⚠️ **La advertencia de calendario, que es la más importante de esta sección.** El §5.3 ya dejó
> un orden de trabajo acordado —Podman, guiones, ruta light— y el §6.2 ya comprometió **29
> semanas a diez horas semanales**. La vía geek es atractiva justamente porque es divertida, y
> por eso es la candidata perfecta a convertirse en un cuarto frente que no cierra ninguno de los
> tres abiertos. La forma de tenerla sin pagarla es la de arriba: **una tarde de apéndice ahora,
> y el resto plegado dentro del Docker moderno cuando le toque**, que no es este semestre.

### 7.8 Lo que hay que verificar antes de escribir el a17

Tres cosas, todas ejecutables en una sesión y ninguna opinable:

- **Que Node 14 compila en la VM**, y con qué plantilla de Lima. Si `bookworm` rompe por OpenSSL
  3 o por la ausencia de `python2.7`, el apéndice tiene que arrancar en `bullseye` o en una VM
  `debian/eol:buster` — y **ese fallo se documenta con su mensaje literal**, porque es contenido.
- **Cuánto tarda de verdad** en el Mac de referencia, con `-j` y con `ccache` en la segunda
  pasada. El doc 09 dice "15-20 min" sin decir en qué máquina; el curso no publica números así.
- **Que el binario resultante ejecuta el proyecto del curso.** No basta con `node --version`: el
  criterio de éxito es un `npm ci` y un `build` de uno de los fixtures, que es como el curso mide
  todo lo demás.

---

## 8. 📌 Lo que queda por decidir

- Si el legacy tiene audiencia medible (§2.3). **Es la única hipótesis que puede invalidar una
  temporada entera de vídeo, y es barata de probar.**
- Si el Docker moderno se hace como curso propio o como una **Parte III** del existente,
  aprovechando que toda la Parte II ya sirve sin cambios (§3.3). El §7.7 se inclina por la
  Parte III, porque la escalera geek y el temario del Docker moderno resultaron ser lo mismo.
- Si `propuesta-complemento-docker/` se archiva o se borra una vez extraído el `a17` (§7.4).
  Argumento para archivar: es la traza de cómo se llegó al curso. Argumento para borrar: contiene
  afirmaciones que el curso ya desmintió (§7.2) y nadie relee la advertencia antes de copiar.
- Si la serie de laboratorio de LFS se hace alguna vez, y con qué prioridad frente a todo lo
  demás (§7.6, §7.7). No compite por calidad, compite por calendario.
- Los tres cabos sueltos de la ruta light: orden de publicación, apéndices transversales y
  cuánto de la semana 0 es público (§6.10).
- Si este documento se versiona o se queda en disco, como los demás documentos de trabajo.

**Ya no está abierto:** el alcance de la primera entrega de la ruta NoSQL (§4.3). La respuesta
es la ruta light completa —diez familias más capstone en 29 semanas (§6.2)— y la ruta larga sin
plazo, curso a curso, guiada por lo que pida la audiencia.

**Tampoco está abierto** —y conviene que quede escrito para que ninguna sesión futura lo
reabra— que los documentos 01–08 y 10–13 de `propuesta-complemento-docker/` **no se importan al
repositorio** (§7.2). Lo único que se rescata es el 09, reescrito y ejecutado, como
`a17-compilar-node-desde-fuente.md` (§7.4).
