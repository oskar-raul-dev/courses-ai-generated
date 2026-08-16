# ✍️ Guía de estilo, tono y convenciones
## Tutorial Angular 8 — Laboratorio clínico

Esta guía es la fuente de verdad editorial del proyecto. Cualquier chat que
produzca un `.md` la sigue. Su objetivo es simple: que los ~50 documentos del
tutorial se lean como escritos por la misma mano, con la misma voz y el mismo
criterio, y que todos apunten al mismo lugar — mantener LabCore sin romperlo.

Si dudas entre dos formas de escribir algo, gana la que le sirva más a alguien
que mañana tiene que arreglar un bug en producción con el jefe mirando por
encima del hombro.

---

## 1. Principio rector

**Todo lo que se escribe apunta a que alguien arregle un sistema heredado sin
romperlo.**

No enseñamos Angular "bonito". No formamos arquitectos de frontend. Formamos
*ojo clínico* (perdón por el chiste, era inevitable): capacidad de leer código
ajeno y viejo, reproducir un bug desde un ticket vago, depurar un bundle
minificado, comparar UAT contra PROD y aplicar un hotfix que no rompa otras
tres cosas.

El filtro para cada párrafo es este: **¿esto ayuda a diagnosticar, depurar,
corregir o prevenir?** Si no, sobra. Aunque esté muy bien escrito. Sobre todo
si está muy bien escrito.

---

## 2. Tono

El tono es **semi formal, cálido y directo**, con humor cuando cae bien. Piensa
en un colega senior que ya sufrió este código y te lo explica con confianza, sin
solemnidad de manual corporativo, pero también sin palmaditas en la espalda.

Cómo se ve eso en la práctica:

- **Tuteo latinoamericano, siempre.** Le hablas al lector de "tú": *"apaga el
  mock y verás el error real"*, *"si esto te suena flojo, quince minutos de docs
  te alcanzan"*. Nada de voseo (*"agregá"*, *"fijate"*), nada de "usted", nada
  de impersonal permanente ("se debe configurar…") que enfría el texto.
- **Semi formal.** Cercano, pero no chat de WhatsApp. Frases completas,
  puntuación correcta, cero abreviaturas de mensajería. Un "che" no, un "ojo con
  esto" sí.
- **Humor seco y con moderación.** Un 😉 bien puesto, un chiste sobre las
  veinte horas que perdiste depurando un frontend cuando lo que estaba caído era
  el mock. El humor sirve para desdramatizar la fricción del legacy, no para
  rellenar. Regla práctica: **máximo un chiste por sección**, y si no fluye
  solo, se borra.
- **Honesto sobre lo feo.** En legacy hay patrones horribles y se dicen
  horribles: *"esto es un componente de 600 líneas con lógica de negocio adentro;
  es feo, está en producción y así lo vas a encontrar"*. No fingimos elegancia
  donde no la hay.
- **Cálido sin condescendencia.** El lector es un dev senior de backend. Cálido
  significa acompañarlo en la fricción, no explicarle qué es HTTP, JSON, un
  token o una petición asíncrona.
- **Orientado a la duda real.** Anticipa el *"¿y esto por qué está así?"* y
  respóndelo, muchas veces con una 📝 **Nota de época** que dé el contexto
  histórico. En 2019 esa decisión tenía sentido; explicarlo evita que el
  estudiante juzgue en vez de entender.

Lo que evitamos: promesas vacías ("vas a dominar Angular"), motivación de coach,
solemnidad de manual, y explicar lo obvio para el perfil.

---

## 3. Idioma y forma de la narrativa

- **Español latinoamericano neutro**, técnico y claro, para todo lo que no es
  código: títulos, explicaciones, ejercicios, referencias, callouts.
- **Los términos del stack se quedan en inglés** cuando son el nombre real de la
  cosa: *store*, *reducer*, *effect*, *selector*, *guard*, *interceptor*,
  *pipe*, *race condition*, *memory leak*, *bundle*, *source map*, *rolling
  update*. Traducirlos forzadamente ("reductor", "guardián") confunde más de lo
  que aclara y no es lo que van a leer en el código.
- **Markdown siempre.** Nada de HTML embebido salvo que no haya alternativa. La
  única excepción conocida y aceptada son los `<details>` del cuaderno de
  incidentes: sin plegado, la solución se lee sin querer al bajar por la página
  y el ejercicio desaparece (`prompts/formato-cuaderno-incidentes.md` §8).
- **Prosa antes que listas.** Se prefiere razonar en párrafos: un párrafo que
  explica *por qué* vale más que cinco viñetas que enumeran *qué*. Las listas se
  usan cuando la cosa es de verdad una lista — pasos secuenciales, ítems
  paralelos, opciones.
- **Listas antes que tablas en comparativas extensas.** Esta es la diferencia
  con otros cursos del catálogo: cuando compares tres entornos, cuatro
  librerías o cinco estrategias, **usa una lista con subtítulos**, no una tabla
  ancha. Una tabla de siete columnas se lee mal en pantalla, se lee peor en
  móvil y no deja espacio para explicar el porqué de cada celda. La lista sí.

  Formato recomendado para comparativas:

  ```markdown
  **Opción A — Colima con arquitectura arm64**

  Qué es: contenedores Linux nativos, sin emulación.
  Cuándo conviene: cuando priorizas velocidad y no necesitas paridad exacta.
  El costo: `node-sass` no compila; hay que cambiar a `sass`.
  Veredicto: es la que recomendamos por defecto en Mac.
  ```

- **Tablas solo para lo que de verdad es tabular y corto.** Versiones pinneadas,
  mapeo estado → etiqueta, matriz de dificultad de ejercicios, tres columnas
  como máximo. Si necesitas explicar una celda, ya no es una tabla: es una
  lista.
- **Encabezados con emoji, con moderación.** Uno por sección de la plantilla.
  Los subtítulos internos pueden llevar emoji-tipo (§7) cuando ayudan a la
  lectura rápida. Un documento que parece un teclado de emojis pierde
  autoridad.

---

## 4. Pedagogía: cómo se explica

Esta sección es la que más define el curso. El estudiante es senior en backend
pero novato en este stack, y tiene un mes. La explicación tiene que ser rápida
sin ser hueca.

### 4.1 La regla del andamio

Todo concepto nuevo se presenta en tres tiempos, en este orden:

1. **El problema primero.** Antes de nombrar la herramienta, muestra el dolor
   que resuelve. *"Tienes cuatro componentes que necesitan saber si el usuario
   está autenticado. Puedes pasarlo por `@Input` en cadena y sufrir, o puedes…"*
2. **La herramienta después.** Ahora sí, el nombre y la definición mínima.
   Definición mínima significa: lo justo para usarla hoy, no el capítulo
   completo de la documentación.
3. **El código que corre.** El fragmento más pequeño que demuestra el punto, con
   comentarios que explican el porqué.

Presentar la herramienta antes que el problema produce estudiantes que saben
escribir un effect pero no saben cuándo hace falta.

### 4.2 Analogías con backend, sin abusar

El estudiante viene de backend. Aprovéchalo: un interceptor HTTP es
conceptualmente primo de un filtro o middleware; un guard es un check de
autorización antes del handler; el store es un estado en memoria compartido con
transiciones controladas.

Dos límites: la analogía se usa **una vez, para abrir la puerta**, y después se
abandona; y se dice explícitamente dónde se rompe (*"hasta acá el paralelo
funciona; la diferencia es que el guard corre en el navegador y el usuario puede
saltárselo, así que no es seguridad, es experiencia de usuario"*). Una analogía
que no se cierra genera bugs conceptuales que aparecen tres fases después.

### 4.3 Explica el porqué, no solo el cómo

Un paso sin justificación es un paso que el estudiante no puede adaptar cuando
LabCore difiera del ejemplo. Cada decisión relevante lleva su porqué,
aunque sea media línea entre paréntesis.

Y cuando el porqué es histórico y no técnico —que en legacy pasa seguido—, se
dice también: *"esto está así porque en 2019 era la única forma; hoy hay tres
mejores y ninguna te sirve porque no vas a migrar"*.

### 4.4 Densidad calibrada

- Un concepto nuevo por vez. Si un bloque de código introduce tres cosas
  desconocidas, se parte en tres bloques.
- Repetir lo importante está bien. Los conceptos que sostienen el curso —flujo
  de datos, ciclo de vida, dónde vive el estado, qué corre en el navegador y qué
  en el servidor— pueden reaparecer varias veces con otras palabras. La
  repetición espaciada funciona; la enciclopedia no.
- Ninguna sección teórica supera las dos pantallas sin que aparezca código.

### 4.5 Cierra los bucles

Si abres un paréntesis pedagógico —*"esto lo vemos en la Fase 8"*, *"acá dejamos
deuda 💸"*— tiene que cerrarse en algún documento del curso. Un pendiente que
nunca se resuelve es ruido, y el lector deja de confiar en las promesas del
texto.

---

## 5. Idioma del código fuente

> **Regla normativa y no negociable: todo el código fuente del curso se escribe
> en inglés —variables, funciones, clases, archivos, endpoints, constantes,
> enums, clases CSS— y todos los comentarios se escriben en español.** Aplica a
> cada fragmento de código del proyecto, sin excepción: fases, apéndices,
> incidentes, ejercicios resueltos, tests, `db.json`, Dockerfile y scripts.
> No hay código legacy "demasiado feo" ni ejemplo "demasiado rápido" que quede
> fuera de esta regla.

LabCore lo escribió un equipo internacional y su código está en inglés, como el de
casi cualquier sistema que un equipo de mantenimiento hereda. Si el tutorial usara
`crearOrden` y `pacientesService`, el vocabulario que el estudiante practica
durante un mes no sería el que va a leer en producción.

Y la contraparte importa igual: **los comentarios van siempre en español**,
porque son el canal donde se explica el *porqué* de un patrón raro, y ese
razonamiento tiene que leerse en el idioma en que se piensa el curso. Un
comentario en inglés en este proyecto es un error de estilo, aunque el código
que acompañe esté impecable.

Cómo se reparte:

- **En inglés:** nombres de clase, componente, servicio, método, variable,
  archivo, módulo, action, reducer, selector, effect, guard, interceptor; rutas
  y endpoints (`/patients`, `/orders/:id/samples`); constantes y valores de
  enum (`status: 'in_process'`, no `'en_proceso'`); clases CSS propias del
  proyecto; atributos `data-testid`.
- **En español:** los comentarios de código (`// el rango de referencia se
  versiona: nunca se edita el vigente, se crea uno nuevo`), y toda la narrativa,
  ejercicios, títulos y callouts del tutorial.
- **Con tildes, también en los comentarios.** Es español y el resto del documento
  las lleva; un comentario sin acentos junto a otro con ellos parece un descuido y
  no una decisión. La única excepción legítima sería un `.ts` que no admita UTF-8,
  y eso no le pasa a ningún proyecto de esta época.
- **Vía claves de traducción:** los textos que ve el usuario. Como el proyecto
  monta i18n con tres idiomas, en la plantilla no va texto literal sino la clave
  (`{{ 'orders.create' | translate }}`), y el árbol de traducciones en español
  es el de referencia.

> ⚠️ **Caso mixto frecuente.** Un objeto de error lleva las *keys* en inglés y
> el *valor* legible por el usuario resuelto desde i18n:
> `{ code: 'sample_expired', messageKey: 'errors.sampleExpired' }`. Y en un
> mapeo de estado a etiqueta, el `case` es inglés y lo que se muestra sale del
> diccionario de traducciones: `case 'in_process': return 'orders.status.inProcess'`.

Y en la narrativa seguimos hablando en español del dominio: "orden", "muestra",
"resultado", "rango de referencia", aunque el código diga `order`, `sample`,
`result`, `referenceRange`.

### 5.1 Diccionario mínimo del dominio

- paciente → `patient`
- orden (médica) → `order`
- examen → `test`
- muestra → `sample`
- cadena de custodia → `custodyChain`
- resultado → `result`
- rango de referencia → `referenceRange`
- validación / validar → `validation` / `validate`
- entrega → `delivery`
- vigencia / vencimiento → `validity` / `expiration`
- registro de auditoría → `auditLog`
- estados de orden: `pending` → `in_process` → `partial_results` → `complete` →
  `delivered` → `expired`
- estados de muestra: `scheduled` → `collected` → `received` → `in_process` →
  `processed` → `discarded`

Los nombres de servicios, actions y effects se arman combinando estos términos
con los verbos técnicos habituales: `get`, `fetch`, `create`, `update`,
`delete`, `validate`, `deliver`, `expire`.

### 5.2 Convenciones de nombrado

- **Componentes:** `PascalCase` + sufijo — `OrderListComponent`,
  `SampleTimelineComponent`.
- **Archivos:** `kebab-case` con el sufijo de Angular — `order-list.component.ts`,
  `patient.service.ts`, `auth.guard.ts`, `auth.interceptor.ts`.
- **Módulos:** `PatientsModule` en `patients.module.ts`.
- **Servicios y métodos:** `camelCase` — `getOrders()`, `validateResult()`.
- **Constantes de configuración:** `SCREAMING_SNAKE_CASE` — `CHAOS_LEVEL`,
  `TOKEN_STORAGE_KEY`.
- **Endpoints REST:** sustantivo plural en inglés — `/patients`, `/orders`,
  `/reference-ranges`.

---

## 6. Manejo del código legacy (el corazón del tutorial)

Acá está la tentación grande: escribir código *bueno* en vez de código *real*.
No lo hacemos.

- **No modernizar por reflejo.** Si LabCore tiene componentes gordos con
  la lógica de negocio adentro, el tutorial muestra componentes gordos con la
  lógica adentro. Se comenta que es discutible; no se corrige.
- **NgModules siempre.** Nada de standalone components, nada de `inject()`, nada
  de control flow moderno. Solo aparecen como comparación en un apéndice de
  migración o en una sección 🔥.
- **RxJS mínimo.** `.subscribe()` a pelo es aceptable y frecuente. Los seis
  operadores que sí aparecen en código real se enseñan bien; el resto no se
  menciona. Sobreusar RxJS es un antipatrón que nombramos.
- **TS-0 asumido.** `strict: false`, `any` tolerado. Se señala con humor cuando
  un `any` está tapando un bug potencial, pero no se corrige en Track A.
- **Métodos de clase con sintaxis de método** (`submit() { }`), nunca propiedades
  con arrow (`submit = () => { }`). La segunda ata el `this` al construir y
  esconde justo el problema que este curso quiere que veas. *(La regla original
  decía "`function () {}` en métodos de clase", que en TypeScript no se puede
  escribir; la **Fase 0 §5.7** ya lo señalaba en un comentario del código.)*
- **Callbacks con `function () {}` y el `this` atado con `.bind(this)`**, no
  arrow. Es el idioma único del proyecto y se escribe siempre igual:

  ```typescript
  this.store.select(selectAllPatients)
    .subscribe(function (this: PatientListComponent, patients) {
      this.patients = patients;
    }.bind(this));
  ```

  La otra forma de la época —`var self = this` y un callback que cierra sobre
  `self`— es igual de correcta y **no se usa acá**, salvo donde `.bind` no llega:
  dentro del `.then()` de una promesa, que es el caso del `AppConfigService` de la
  **Fase 13 §5.3**, y dentro de una función que *devuelve* el callback, como el
  validador asíncrono de la **Fase 5 §5.10**. En esos dos sitios se usa `var self`
  y se comenta por qué.
- **La excepción, dentro de un `pipe` de RxJS: arrow.** Un `.bind(this)` sobre un
  callback que no toca `this` es ruido, y encadenar los dos mecanismos en la misma
  cadena de operadores se lee peor que elegir uno. La regla práctica, y así está
  escrito todo el curso: **`.bind(this)` en `subscribe` y en `createEffect`, arrow
  dentro de `pipe`.**
- **Corrección mínima vs refactor.** Cada vez que aparece un fix, se distingue
  el parche mínimo —lo que va en un hotfix un viernes— de la refactorización
  —lo que iría con calma y pruebas. Es una de las lecciones más transferibles
  del curso.
- **El idioma del código no es negociable ni en el código más feo.** Un
  componente de 600 líneas se muestra tal cual —con su lógica de negocio
  adentro y su `any` a la vista—, pero con identificadores en inglés y
  comentarios en español. La fealdad que enseñamos es de arquitectura y de
  decisiones, no de idioma.
- **Fechas con zona horaria explícita.** Nunca un `new Date()` suelto donde
  importe el día: los resultados de fin de semana y las órdenes vencidas viven
  de esa precisión.

---

## 7. Marcadores y callouts

Vocabulario visual compartido por todos los documentos, para que el lector lo
reconozca de un vistazo.

### 7.1 Marcadores de estado

- 💸 **Deuda técnica intencional.** Todo atajo o patrón feo que se deja a
  propósito para reproducir LabCore. En Track A **no se paga**: se
  declara, se explica por qué se acepta, y se sigue.
- 🔥 **Opcional o ampliación.** Fases, secciones y ejercicios fuera del alcance
  base. No cuentan en el calendario.
- ⭐ **Pieza central.** Las fases y los incidentes más formativos del curso.
- 🟢🟡🟠🔴 **Dificultad de ejercicios.** Fácil, intermedio, difícil, muy difícil.
- 🏷️ **Tag de progreso.** El recordatorio de cerrar la fase —o el apéndice— en
  git. Va **una sola vez por documento**, al final, con la forma fija de §8.1.
- 🪦 **Pendiente cerrado.** Un 📌 que se resolvió: se marca así en vez de borrarlo,
  con dónde quedó la respuesta. Es el mismo emoji del *retiro* de §7.2, y la idea
  es la misma —algo que cumplió su función y sale— aplicada a una decisión.
- 👁️ **solo lee** y ✍️ **modifica**, en apéndices de infraestructura. Nacieron en
  A09 para marcar cada comando de `kubectl` y son de lo más útil que tiene ese
  apéndice: un lector con acceso de lectura sabe de un vistazo qué puede correr
  con el jefe mirando. Se usan también en A13 con los contextos de Docker.
- 🩺 **Diagnóstico por síntoma.** Encabeza la tabla de "esto me pasó, dónde miro",
  que es la sección más consultada de A12 y A13.
- 🧨 **Rompe a propósito.** Marca un experimento destructivo dentro de un apéndice,
  donde no hay una sección 6 que lo aloje como en las fases.
- 🕵️ **Track forense.** Encabeza `forense-master.md` y las quince piezas
  `forense-fase-NN.md`, y marca —en blockquote— el puntero desde un apéndice o desde
  el cuaderno hacia el recorrido que desarrolla lo que ahí se explica. Su formato
  completo está en `prompts/formato-piezas-forenses.md`; dentro de una pieza se
  usan además 🎫 (el ticket), ⚰️ (los callejones) y 🧬 (la pregunta propia del
  track: ¿lo escribió el sistema o llegó roto en el dato?).

### 7.2 Callouts en blockquote

- 📝 **Nota de época.** Contexto histórico de un patrón que hoy se ve raro.
- 📚 **Referencia rápida inline.** El enlace útil justo donde nace la duda, sin
  esperar a la sección de referencias.
- ⚠️ **Advertencia.** Algo que rompe si lo ignoras: versión incompatible,
  `node_modules` compartido entre arquitecturas, config horneada en el build.
- 💡 **Truco o atajo** que ahorra tiempo real.
- 🪦 **Retiro.** Cuando algo cumple su función y sale del proyecto.

No hace falta usarlos todos en cada documento. Se usan cuando aportan.

### 7.3 Secciones narrativas recurrentes

Micro-secciones con nombre fijo, que aparecen cuando el contenido las pide:

- **Detalles con intención.** Lista corta con las decisiones deliberadas de un
  bloque de código y su porqué.
- **El patrón a memorizar.** Una o dos frases que destilan la lección
  transferible del fragmento.
- **Prueba de fuego.** Verificación manual concreta, incrustada en el flujo y no
  en los ejercicios: *"apaga el mock, recarga, confirma que ves el mensaje de
  error con botón de reintento; vuelve a levantarlo y reintenta"*.
- **Mini-repaso.** Cuando la fase usa sintaxis que el dev de backend quizá no
  domina (decoradores, tipos genéricos, operadores de RxJS), un repaso exprés
  antes de entrar al código, con su 📚 a la documentación oficial.
- **La señal de que quedó bien.** En el cierre, un criterio en forma de cita que
  describe cómo se siente el trabajo bien hecho: *"si mañana cambian el mock por
  el backend real, solo toco la configuración y ninguna vista se entera"*.

---

## 8. Plantilla obligatoria de cada fase (9 secciones)

Toda fase produce un `.md` con exactamente estas nueve secciones, en orden:

1. **🎯 Propósito** — qué resuelve la fase. Puede abrir con la situación
   heredada de la fase anterior.
2. **✅ Qué queda listo al terminar** — checklist verificable, no promesas.
3. **🚫 Qué NO entra todavía** — qué se difiere y a qué fase exacta.
4. **🧠 Concepto mínimo** — la teoría justa, anclada al dominio. Acá caben el
   Mini-repaso y las Notas de época.
5. **💻 Código mínimo con comentarios** — el grueso. Código ejecutable con las
   versiones fijadas, identificadores en inglés, comentarios en español. Acá
   caben Detalles con intención, El patrón a memorizar y Prueba de fuego.
6. **⚠️ Errores comunes y pieza forense** — qué se rompe típicamente y cómo se
   depura. Enlaza con `forense-fase-NN.md`.
7. **🧪 Ejercicios** — ver §9.
8. **📚 Referencias** — ver §10.
9. **🚀 Cierre** — qué sigue, por qué, La señal de que quedó bien y el
   recordatorio 🏷️ del tag de la fase (§8.1).

Después de la novena, y fuera de la plantilla que lee el estudiante, cada fase
cierra con **📌 Pendientes sugeridos**: lo que apareció al escribirla y no cabía
adentro, con destino explícito (otra fase, un apéndice, un ejercicio 🔥 o una
decisión de proyecto). Ahí abajo vive también la subsección **Reservas para el
cuaderno de incidentes**, con el ID, el título propuesto, la categoría y la
dificultad de cada incidente que la fase produce. Es material de autoría, no de
lectura, y por eso va al final y no compite con el cierre.

### 8.1 El recordatorio del tag, en el cierre

Toda fase termina con un bloque 🏷️ que recuerda cerrarla en git. Es de forma
fija —cambian solo el nombre del tag, la etiqueta de la fase y el prefijo de
commit— y va **después** de La señal de que quedó bien, justo antes del `---`
que abre los 📌 Pendientes:

````markdown
> 🏷️ **No cierres la fase sin el tag.** Con el checklist de la sección 2 en
> verde y `git status` limpio:
>
> ```bash
> git tag -a fase-07-muestras-custodia -m "F7 cerrada: <el checklist, en una línea por ítem>"
> ```
>
> Los commits de la fase llevan su prefijo (`f07: …`) y los de ejercicio su
> número (`f07 ej17: …`). Si un ejercicio merece su propio marcador va en
> `ej/f07/17`, y un incidente resuelto en el par `inc/<ID>/<slug>-roto` /
> `-fix`, con el ID que le reserva `cuaderno-incidentes.md`. Todo eso está en
> [`00-convencion-de-git-y-tags.md`](../00-convencion-de-git-y-tags.md).
````

El nombre del tag es **`fase-` + el mismo slug del archivo `.md`**, sin
excepciones (`07-muestras-custodia.md` → `fase-07-muestras-custodia`), y el
prefijo de commit es `f` + los dos dígitos de la fase. Nada de la convención se
reexplica en la fase: se enlaza. Cuando la fase tenga algo propio que decir
sobre git —la Fase 4, de donde salen las ramas `incidente/NN`; la 13, que
estrena la imagen— se agrega un párrafo corto al final del mismo bloque, no un
bloque nuevo.

**Los apéndices también lo llevan**, y ahí el caso normal es el contrario: como
son consulta rápida y el código que explican lo escriben las fases, **no llevan
tag propio**, y el bloque lo dice explícitamente junto con qué prefijo usar para
lo que sí salga de leerlos (`f05: …`, el de la fase desde la que se llegó). La
única excepción es **A13**, cuyo §6 escribe el `.devcontainer/`: si se decide
versionarlo, ese commit se etiqueta `apendice-a13-docker-colima`. Un tag que no
apunta a un cambio no marca nada.

---

Los apéndices no siguen esta plantilla: usan índice de salto rápido, secciones
cortas, una guía final de "cuándo usar qué" y 5-10 ejercicios cortos.

---

## 9. Ejercicios

- **Cantidad: 25 mínimo, 30 ideal por fase, hasta 35 en las densas.** Menos de
  25 se queda corto para media jornada de práctica. Las fases largas —1 y 8—
  llegan a 35 y ese es el techo razonable: más allá, el bloque de ejercicios pesa
  más que la fase. La única fase por debajo del mínimo es la **14**, que es 🔥
  opcional, no ocupa calendario y se queda en 15.
- **Distribución equilibrada.** Para ~30 ejercicios: unos 8 🟢, 9 🟡, 7 🟠 y 5
  🔴, más los 🔥 aparte. No cargues todo en fácil.
- **Numeración continua con encabezado de rango**, así:

  ```markdown
  ## 🧪 Ejercicios (30)

  **🟢 Fácil (1–8)**
  1. ...

  **🟡 Intermedio (9–17)**
  9. ...

  **🟠 Difícil (18–24)**
  18. ...

  **🔴 Muy difícil (25–30)**
  25. ...

  **🔥 Opcionales**
  - 🔥 ...
  ```

  El título lleva el conteo total.
- **Accionables y verificables.** *"Haz que una muestra descartada no pueda
  volver al estado `in_process`, ni por la interfaz ni despachando la acción a
  mano desde DevTools"* — no *"reflexiona sobre las máquinas de estado"*.
- **Al menos un tercio son de diagnóstico**, no de construcción: se entrega algo
  roto y se pide reproducir, localizar y explicar. Es el músculo que este curso
  entrena.
- **Enganchados al dominio.** Pacientes, órdenes, muestras, resultados, rangos
  versionados. Nunca `foo` y `bar`.
- **Con el identificador vigente.** Si el ejercicio nombra código, usa el nombre
  en inglés que ya existe en la fase (`validateResult`, no `validarResultado`).

En apéndices bastan 5-10 ejercicios cortos de consulta.

---

## 10. Bibliografía y referencias

**Regla:** documentación oficial compatible con las versiones fijadas primero;
después libros; después blogs y videos. Siempre se advierte cuando un enlace
apunta a una versión distinta de la que usamos, que con Angular pasa casi
siempre.

### 10.1 Formato

URLs completas y clicables, nunca solo el dominio. Dentro de "Referencias", se
separa en documentación oficial, libros cuando apliquen, video y apoyo, y una
línea final de **orden de lectura sugerido** que encadene qué leer primero.

### 10.2 Fuentes oficiales por tema

- **Angular 8:** https://v8.angular.io/docs — es la referencia por defecto.
  Cuidado con caer en https://angular.io o https://angular.dev, que documentan
  versiones muy posteriores.
- **Angular CLI 8:** https://v8.angular.io/cli
- **Angular Material 8:** https://v8.material.angular.io
- **RxJS 6:** https://rxjs.dev — advertir las diferencias de imports y
  operadores con RxJS 7.
- **TypeScript:** https://www.typescriptlang.org/docs — advertir que documenta
  versiones muy posteriores a 3.5.
- **json-server:** https://github.com/typicode/json-server
- **Docker y nginx:** https://docs.docker.com · https://nginx.org/en/docs
- **Playwright:** https://playwright.dev
- **MDN** para JavaScript base: https://developer.mozilla.org

### 10.3 Advertencias

- Cuando se cite un artículo, libro o video específico, se aclara que el título
  o la URL pueden haber cambiado y que conviene verificarlos. No se inventan
  números de página, ISBN ni identificadores de video.
- **No usar en el código principal** APIs de Angular 9 en adelante (Ivy
  explícito, standalone, `inject()`, nuevo control flow) ni RxJS 7. Aparecen
  solo como comparación o en secciones 🔥.

---

## 11. Coherencia de la ficción

El sistema heredado del curso se llama **LabCore** y es ficticio. Nació en 2019
sobre Angular 8.2.14, creció hasta 2021, hoy está en mantenimiento y tiene
decomisión prevista en dos o tres años. El curso lo **construye pieza por pieza**:
al terminar la última fase obligatoria, el estudiante tiene LabCore delante, en su
disco, y puede abrir cualquier archivo del que el material haya hablado.

Esa es toda la ficción, y es lo que hace el curso autocontenido. También impone
cuatro reglas, y la primera es la que de verdad cuesta.

**Regla 1 — Si el curso afirma que algo está así en LabCore, tiene que poder
mostrarlo.** *"Así lo hace LabCore"* es una frase legítima cuando el código está en
alguna fase, y solo entonces. No lo es cuando describe pantallas que el curso no
escribe, porque promete un archivo que el lector no puede abrir. Es la regla que
sustituye a la vieja coartada del NDA: antes se podía afirmar cualquier cosa sobre
un sistema que nadie iba a ver.

**Regla 2 — Lo que LabCore tiene y el curso no construye se cuenta como historia,
no como observación.** Hay cosas del sistema heredado que importan y que no caben
en un tutorial: las mil claves de i18n crecidas por sedimentación, la regla de
negocio repetida en tres pantallas con un filtro de más en una de ellas, los siete
slices escritos por gente distinta. Se cuentan, porque son la razón de la mitad de
las deudas 💸 — pero se cuentan **en pasado y como contexto**:

> ✅ *"LabCore acumuló esa regla en tres pantallas a lo largo de los años; acá
> construyes una, y el reflejo que te llevas es buscar las otras dos."*
>
> ❌ *"El sistema real tiene esa regla en tres componentes, y uno de los tres
> tiene un filtro de más."*

La segunda promete un código que nadie puede abrir. La primera dice lo mismo, es
igual de útil, y es verdad.

**Regla 3 — La cronología es fija.** 2019 el nacimiento, 2021 el último crecimiento
grande, hoy el mantenimiento. Toda 📝 **Nota de época** se sitúa dentro de esa
línea, y ninguna decisión de LabCore puede justificarse con algo que no existía
cuando se tomó. Es lo que hace creíbles las notas de época, que son de lo mejor que
tiene este curso.

**Regla 4 — Ningún ejercicio pide algo que solo se pueda hacer con un sistema que
el estudiante no tiene.** Ni "verifica esta versión contra tu `package.json`", ni
"compara con cómo lo resuelve tu empresa", ni "pregúntale a tu equipo". Las
versiones están fijadas en el README; lo que un dev haría con un proyecto heredado
propio es el **Apéndice A03 §8**, y es una sección, no una instrucción suelta.

> 🧭 **Y el corolario, que es lo que se gana:** el curso se puede tomar entero, de
> principio a fin, sin acceso a nada más que a este repositorio. Cualquier frase que
> rompa eso es un error de estilo, aunque esté bien escrita.

---

## 12. Coherencia entre documentos

- **No contradecir fases anteriores.** Un fragmento de la Fase 8 no puede usar
  una estructura de estado distinta a la que definió la Fase 1.
- **No reescribir decisiones aprobadas** sin señalar explícitamente la
  incompatibilidad y explicar por qué.
- **Nombres estables.** Archivos, servicios, componentes y acciones se mantienen
  idénticos entre fases. Si algo se renombra, se documenta el cambio y se
  ajustan las fases afectadas.
- **Fuentes de verdad, en este orden:** (1) instrucciones del proyecto, (2)
  `prompts/alcance-del-proyecto.md`, (3) `prompts/propuesta-fases-y-alcance.md`,
  (4) esta guía —con `00-convencion-de-git-y-tags.md` como su anexo para todo lo
  que toque git, repos y tags, `prompts/formato-piezas-forenses.md` como su anexo
  para el track forense y `prompts/formato-cuaderno-incidentes.md` como su anexo
  para el cuaderno de incidentes—, (5) entregables ya aprobados de fases anteriores,
  (6) decisiones explícitas del chat actual. No hay un `plan-del-curso.md`: se citó durante un
  tiempo y nunca se escribió. `prompts/_deprecado-tutorial-angular8.md` **no**
  cuenta: su numeración de apéndices (A1-A9) no es la vigente. Los apéndices
  van de **A01 a A13** según la tabla de `propuesta-fases-y-alcance.md` §4.

---

## 13. Post-mortems e incidentes

Cada incidente del cuaderno sigue esta estructura de ocho puntos:

1. Síntoma, en palabras del usuario.
2. Pasos de reproducción exactos.
3. Evidencia observable: consola, Network, DevTools, logs.
4. Causa raíz, hasta la línea o el commit.
5. Corrección aplicada.
6. Prueba de regresión que falla antes del fix y pasa después.
7. Prevención: test, feature flag o alerta.
8. Post-mortem **sin culpabilización**: se analiza el sistema y el proceso, no a
   la persona.

El tono acá baja un punto de humor. Un post-mortem es sereno y analítico —no
acartonado, pero tampoco el lugar para el chiste.

Esos ocho puntos son el esqueleto; **el formato completo del archivo —el índice y
la reserva de IDs, las tres formas de repartir el sistema roto, la convención de
commits `incidente(NN):`, la plantilla con las pistas plegadas y el checklist de
cierre— está en `prompts/formato-cuaderno-incidentes.md`**, que es el anexo de
esta guía para todo lo que toque el cuaderno, y cubre también el
`cuaderno-incidentes-be.md` del track BE. El **estado roto** de cada incidente
—qué línea rompe cada rama y qué lleva cada `db.incidente-NN.json`— vive aparte, en
`prompts/preparaciones-de-incidentes.md`, porque es la respuesta y no puede quedar
a un clic del enunciado.

Los puntos 1 a 6 tienen traducción exacta a git, y conviene pedirla: el par de
tags `inc/<ID>/<slug>-roto` e `inc/<ID>/<slug>-fix` deja el síntoma y la
regresión en rojo en el primero, la causa raíz y el fix en el segundo, y el
`git diff` entre los dos **es** el punto 5 aislado del ruido de la fase. El
`<ID>` es el que `cuaderno-incidentes.md` ya tiene reservado, nunca uno
inventado. El detalle está en `00-convencion-de-git-y-tags.md`, y las fases lo
enlazan desde su bloque 🏷️ sin reexplicarlo.

---

## 14. Checklist antes de dar por cerrado un `.md`

- [ ] Sigue la plantilla de 9 secciones (o el formato de apéndice).
- [ ] Tono semi formal y cálido, tuteo latinoamericano, humor con moderación.
- [ ] Explica el problema antes que la herramienta, y el porqué de cada decisión.
- [ ] Prosa antes que listas; listas antes que tablas en comparativas extensas.
- [ ] Todo el código corre con las versiones fijadas del stack.
- [ ] **Todo el código en inglés** (variables, funciones, clases, archivos,
      endpoints, constantes, enums) y **todos los comentarios en español**;
      textos de interfaz vía claves de i18n. Sin excepciones (§5).
- [ ] NgModules, RxJS mínimo, `any` tolerado, y **un solo idioma para el `this`**:
      `.bind(this)` en `subscribe` y `createEffect`, arrow dentro de `pipe` (§6).
- [ ] Marca 💸 la deuda intencional (y aclara que no se paga) y 🔥 lo opcional.
- [ ] Tiene 25-35 ejercicios con rangos 🟢🟡🟠🔴 equilibrados, varios de
      diagnóstico (o 5-10 cortos en apéndices).
- [ ] Enlaza su pieza forense y los incidentes relacionados.
- [ ] Referencias con URL completa a documentación de la versión correcta, con
      advertencia cuando no lo sea.
- [ ] No contradice ninguna fase anterior, ni en pedagogía ni en nombres.
- [ ] Coherencia de la ficción (§11): nada que afirme sobre LabCore algo que el
      curso no pueda mostrar, y ningún ejercicio que exija un sistema externo.
- [ ] Incluye "La señal de que quedó bien" en el cierre.
- [ ] Lleva el bloque 🏷️ del tag al final, con el nombre correcto (`fase-` + el
      slug del archivo) y el prefijo de commit correcto (§8.1). En los apéndices,
      el bloque dice que no llevan tag propio —salvo A13— y con qué prefijo se
      commitea lo que salga de leerlos.

---

## 15. Pendientes que afectan a esta guía

Anotados acá para no bloquear la escritura, pero hay que resolverlos:

- 🪦 **Presupuesto horario: cerrado.** 108h de fases más 14h de cuaderno,
  **122h**, verificado sumando los encabezados. La cifra de 96h y 12 fases venía de
  `_deprecado-tutorial-angular8.md` y ya no circula. El `plan-del-curso.md` que
  varios documentos citaban **nunca existió** y se retiró de la cadena de fuentes de
  verdad: su función la cumplen `propuesta-fases-y-alcance.md` §2 y el README.
- **Solución de i18n.** 🪦 Resuelto: **runtime con `@ngx-translate` 11**
  (`http-loader` 4), decidido y justificado en `02-i18n.md` §4. En
  consecuencia, todo texto de interfaz del curso se escribe como
  `{{ 'clave' | translate }}` en plantilla o `translate.instant('clave')` en
  código, y nunca como literal. El apéndice **A07** ya está escrito y es el dueño
  de la API de consulta, el árbol de claves, la pluralización y los formatos. Lo
  que sigue abierto son versiones puntuales del stack (ngx-charts, Bootstrap) y
  las del compilador ICU si algún día se adopta (A07 §5), declaradas con ⚠️ en el
  documento que las usa.

---

## 16. 🔥 El track opcional de backend

Sección de encuadre del **track BE**, cuyo alcance completo vive en
`prompts/propuesta-fases-backend.md` §4, §5 y §9. Acá solo va lo que esta guía
tiene que decir para que un capítulo del track se escriba igual que uno del track
base. **Si algo de abajo contradice a la propuesta, manda la propuesta.**

### 16.1 Qué se hereda sin cambios

- **La plantilla obligatoria de nueve secciones** de §8, incluido el bloque 📌 de
  autoría fuera de lo que lee el estudiante.
- **La voz, el tuteo, la regla del andamio** y la prosa antes que listas (§2-§4).
- **El régimen de ejercicios** de §9: 25 mínimo, 30 ideal, hasta 35 en las densas,
  con al menos un tercio de diagnóstico y los rangos 🟢🟡🟠🔴 equilibrados.
- **Los marcadores y callouts** de §7, con una adición: las secciones narrativas
  recurrentes del repositorio —🪞 *"tu instinto relacional dice… y esta vez se
  equivoca"*, 🩻 *"esto sí funciona igual"*, ⚰️ autopsia de anti-patrón, 📖
  diccionario de traducción— **son obligatorias donde la fase las pida** y están
  nombradas una a una en §7 de la propuesta.
- **El checklist de cierre** de §14, con los ítems de Angular sustituidos por los
  equivalentes de Java (abajo).

### 16.2 Nombres de archivo y tags

Fases **`beNN-tema.md`** (`be00` a `be08`); apéndices **`bea-NN-tema.md`**
(`bea-01` a `bea-12`). Minúsculas con guiones, dos dígitos.

El prefijo `be` mantiene los cuatro bloques separados en el mismo directorio sin
subdirectorios: fases base (`00-` a `14-`), apéndices base (`a01-` a `a13-`),
piezas forenses (`forense-fase-NN.md`) y track BE.

> 📝 El track base usa `aNN-`, así que `beaNN-` habría rimado mejor localmente.
> Se elige `bea-NN-` porque es la convención registrada en el `CLAUDE.md` del
> repositorio. Un solo nombre para la misma cosa en todo el repositorio vale más
> que la rima local.
>
> 🪦 **Renombrado el 10/09/2026: antes era `be-a-NN-`.** Tres segmentos separados
> por guion antes del tema se leían como tres cosas en vez de una. Con `bea-`
> como prefijo único, todo archivo del repositorio tiene la misma forma
> —`<prefijo>-<número>-<tema>`, igual que `forense-fase-NN`— y el número del
> apéndice es lo primero después del prefijo. Si encuentras un `be-a-NN-` en
> algún sitio, es un resto del nombre viejo.

**Tags:** namespace propio, `be-fase-` + el slug del archivo
(`be00-el-contrato-auditoria-del-mock.md` → `be-fase-00-el-contrato-auditoria-del-mock`),
para que `git tag -l 'fase-*'` siga siendo el índice limpio del track base.
Prefijo de commit `beNN:`, y de ejercicio `beNN ejNN:`.

**No hay `forense-be-NN.md`.** Divergencia declarada: los `forense-fase-NN.md`
existen para sostener capturas de DevTools y recetas de breakpoints. La pieza
forense del track BE es una agregación, un `explain()` o un log de `mongod`, y
**cabe en la §6 de la fase**, junto al código que la produce.

**Cuaderno propio:** `cuaderno-incidentes-be.md`, con IDs `be-01` … `be-12`
independientes de los del cuaderno base. Un estudiante que solo hace el track base
no debe recibir incidentes de MongoDB mezclados con los suyos.

### 16.3 Estilo de código del track

- **Código en inglés, comentarios en español con tildes.** También en Java:
  paquetes, clases, campos, nombres de colección y de campo BSON.
- **Nada de Java moderno gratuito.** Sin `var`, sin `record`, sin `List.of`, sin
  text blocks, sin nada reactivo, sin `Optional` donde el código de 2019 no lo
  usaba. Lo posterior a Java 8 aparece marcado 🔥 como comparación, nunca como la
  forma en que LabCore está escrito.
- **El frontend no se toca.** Ni un componente, ni un slice de NgRx, ni un effect,
  ni el interceptor, ni `environment.apiUrl`. Si un capítulo necesita cambiar el
  frontend, el capítulo está mal diseñado.
- **Autocontención estricta.** El track no remite a ningún otro curso del
  catálogo, ni siquiera para los contenedores. Todo lo necesario vive en `bea-02`.

### 16.4 Diccionario del dominio, lado servidor

Los nombres del dominio tienen que significar **exactamente lo mismo a los dos
lados del cable**. Las entidades salen de §5.1 de esta guía y del `db.json` del
mock; en el backend se escriben así:

| Concepto | Clase Java | Colección | Ruta |
|---|---|---|---|
| Paciente | `Patient` | `patients` | `/patients` |
| Orden médica | `Order` | `orders` | `/orders` |
| Muestra | `Sample` | `samples` | `/samples` |
| Eslabón de custodia | `CustodyLink` | `custodyLinks` | — (interno, **no existe hoy**) |
| Resultado | `Result` | `results` | `/results` |
| Rango de referencia | `ReferenceRange` | `referenceRanges` | `/referenceRanges` |
| Asiento de auditoría | `AuditEntry` | `auditLog` | `/auditLog` |

Clases en `PascalCase`, campos y colecciones en `camelCase` —**igual que el
`db.json`**, porque el contrato lo exige y el contrato manda sobre la elegancia—.

> ⚠️ **Dos filas de esa tabla se corrigieron contra el contrato real, y son la
> primera lección del track.** La bitácora se llama `auditLog` y no
> `auditEntries`: es el nombre que el `AuditService` de la Fase 11 tiene escrito
> en un `POST`, y como el frontend no se toca, **el nombre bonito pierde**. Y
> `custodyLinks` **no existe en el sistema de hoy**: la custodia vive embebida en
> el documento de la muestra, en los campos `collectedBy` / `collectedAt` y sus
> hermanos, y el componente de la Fase 7 la reconstruye a mano con
> `custodyEvents()`. La colección aparte es lo que `be05` propone, no lo que hay.
> Si una fase del track las nombra de otra forma, la fase está mal.
**Los valores de `status` no se traducen nunca**: son identificadores del sistema y
viajan tal cual al frontend, que los convierte en claves de i18n.

> ⚠️ **El flujo canónico de estados es el del track base y no se reinventa.** Una
> orden vive en `pending → in_process → partial_results → complete → delivered →
> expired`; una muestra en `scheduled → collected → received → in_process →
> processed → discarded`. Comparten la palabra `in_process` y no significan lo
> mismo. Eso es una decisión de LabCore y una fuente real de confusión en los
> tickets: se mantiene.

### 16.5 Coherencia de la ficción, ampliada

§11 sigue mandando, con tres anclas nuevas que **ninguna fase del track puede
contradecir**:

- **El backend es de 2019**, lo escribió otro frente del mismo equipo contratado, y
  está descrito en `00-historia-del-sistema.md`. Quedó congelado y sin dueño, y eso
  es lo que explica el audit log escrito por el frontend y el timestamp de custodia
  puesto por el navegador.
- **Se desplegó un `mongod` suelto, no un replica set**, y eso sobrevivió intacto a
  los cuatro upgrades. La transacción sigue siendo imposible en 2026.
- **Mongo no es el villano.** El panel de resultados **es** un documento; un
  hemograma y un perfil lipídico no comparten forma. El equipo de 2019 acertó en
  eso y generalizó desde ahí a todo el sistema. Cualquier capítulo que se lea como
  *"Mongo es malo"* está mal escrito y se reescribe.
