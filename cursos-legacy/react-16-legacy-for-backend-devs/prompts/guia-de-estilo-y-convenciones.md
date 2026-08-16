# ✍️ Guía de estilo, tono y convenciones
## Tutorial React 16 — Rifas y chances

Esta guía es la fuente de verdad editorial del proyecto. Cualquier chat que
produzca un `.md` la sigue. Su objetivo es simple: que los ~30 documentos del
tutorial se lean como escritos por la misma mano, con la misma voz y el mismo
criterio, y que todos apunten al mismo lugar — mantener un sistema legacy sin
romperlo.

Si dudas entre dos formas de escribir algo, gana la que le sirva más a alguien
que mañana tiene que arreglar un bug en producción con el jefe mirando por
encima del hombro.

> 🔄 **Convención de idioma (vigente desde 2026-07-15):** todo el código fuente
> del curso (nombres, constantes, endpoints) se escribe en **inglés**; la
> narrativa, los comentarios y los textos de interfaz de usuario, en **español**.
> Ver §4 para el detalle y `diccionario-codigo-ingles.md` para el diccionario
> operativo. **El ajuste de las fases preexistentes está terminado** (§4.6
> describe el proceso y queda como referencia histórica); las fases nuevas se
> escriben directamente con la convención.

---

## 1. Principio rector

**Todo lo que se escribe apunta a que alguien arregle un sistema legacy sin
romperlo.**

No enseñamos React "bonito". No formamos arquitectos de frontend. Formamos
*ojo clínico*: capacidad de leer código ajeno y viejo, reproducir un bug desde
un ticket vago, depurar un bundle minificado, comparar UAT contra PROD y
aplicar un hotfix que no rompa otras tres cosas.

El filtro para cada párrafo es este: **¿esto ayuda a diagnosticar, depurar,
corregir o prevenir?** Si no, sobra. Aunque esté muy bien escrito. Sobre todo
si está muy bien escrito.

---

## 2. Tono

El tono es **semi formal, cálido y directo**, con humor cuando cae bien. Piensa
en un colega senior que ya sufrió este código y te lo explica con confianza, sin
solemnidad de manual corporativo, pero también sin palmaditas en la espalda.

Cómo se ve eso en la práctica:

- **Tuteo latinoamericano, siempre.** Le hablas al lector de "tú": *"apaga
  json-server y verás el error real"*, *"si esto te suena flojo, quince minutos
  de docs te alcanzan"*. Es una regla normativa, no una preferencia: **nada de
  voseo** (*"agregá"*, *"fijate"*, *"tenés"*, *"podés"*, *"usás"*, *"seguí"*),
  nada de "usted", nada de "vosotros", y nada de impersonal permanente
  ("se debe configurar…") que enfría el texto.

  Las formas correctas, para no dudar: *agrega*, *fíjate*, *tienes*, *puedes*,
  *usas*, *sigue*, *escribe*, *mira*, *pon*, *crea*, *deja*, *vuelve*, *elige*,
  *cambia*, *corre*, *revisa*, *abre*, *prueba*, *instala*, *ejecuta*, *guarda*.
  En imperativo negativo, la forma de tú lleva subjuntivo: *no borres*, *no
  toques*, *no confíes en `response.data`* — nunca *no borrés*.

- **Semi formal.** Cercano, pero no chat de WhatsApp. Frases completas,
  puntuación correcta, cero abreviaturas de mensajería. Un "che" no, un "ojo con
  esto" sí.
- **Humor seco y con moderación.** Un 😉 bien puesto, un chiste sobre los veinte
  minutos que perdiste depurando el frontend cuando lo que estaba apagado era el
  mock. El humor sirve para desdramatizar la fricción del legacy, no para
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
  histórico. En 2020 esa decisión tenía sentido; explicarlo evita que el
  estudiante juzgue en vez de entender.

Lo que evitamos: promesas vacías ("vas a dominar React"), motivación de coach,
solemnidad de manual, y explicar lo obvio para el perfil. El humor es
condimento, no plato principal.

---

## 3. Idioma y forma de la narrativa

- **Español latinoamericano neutro**, técnico y claro, para todo lo que no es
  código: títulos, explicaciones, ejercicios, referencias, callouts. Sin
  regionalismos de España ("ordenador", "vale") ni rioplatenses.
- **Los términos del stack se quedan en inglés** cuando son el nombre real de la
  cosa: *hook*, *slice*, *epic*, *store*, *dispatch*, *thunk*, *reducer*,
  *selector*, *race condition*, *memory leak*, *polling*, *bundle*, *source
  map*. Traducirlos forzadamente ("rebanada", "gancho") confunde más de lo que
  aclara y no es lo que van a leer en el código.
- **Markdown siempre.** Nada de HTML embebido salvo que no haya alternativa.
- **Prosa antes que listas.** Se prefiere razonar en párrafos: un párrafo que
  explica *por qué* vale más que cinco viñetas que enumeran *qué*. Las listas se
  usan cuando la cosa es de verdad una lista — pasos secuenciales, ítems
  paralelos, opciones.
- **Listas antes que tablas en comparativas extensas.** Cuando compares tres
  entornos, cuatro librerías o cinco estrategias, **usa una lista con
  subtítulos**, no una tabla ancha. Una tabla de siete columnas se lee mal en
  pantalla, se lee peor en móvil y no deja espacio para explicar el porqué de
  cada celda. La lista sí.

  Formato recomendado para comparativas:

  ```markdown
  **Opción A — `thunk` para la carga inicial de rifas**

  Qué es: una función async despachada por Redux Toolkit, sin RxJS de por medio.
  Cuándo conviene: cuando la operación es "pide una vez y guarda el resultado".
  El costo: no hay cancelación; si el componente se desmonta, el `.then` corre igual.
  Veredicto: es la opción por defecto salvo que necesites cancelar o coordinar.
  ```

- **Tablas solo para lo que de verdad es tabular y corto.** Versiones pinneadas,
  mapeo estado → etiqueta, matriz de dificultad de ejercicios. El límite práctico
  es **cuatro columnas**, y con una condición: que **ninguna celda necesite más
  de una línea**. Si una celda pide una explicación, ya no es una tabla — es una
  lista con subtítulos, y se reescribe.

  Las **tablas de equivalencia** son el caso arquetípico donde la cuarta columna
  se gana su lugar: `concepto | forma vieja | forma nueva | nota de versión` es
  exactamente la forma que tiene el conocimiento que un mantenedor necesita, y
  partirla en prosa la empeora. Las de `A5`, `A6`, `A7` y `A8` son de ese tipo y
  están bien como están.

  Lo que **sí** se prohíbe sin excepción es la tabla ancha **narrativa**: cinco o
  más columnas, o celdas con párrafos adentro. Ahí no estás tabulando, estás
  escondiendo prosa en una cuadrícula.

  📝 **Por qué esta regla cambió.** Antes decía "tres columnas como máximo", y
  siete de las ocho tablas del curso la incumplían — todas ellas tablas de
  equivalencia perfectamente legibles. Una regla que el 88% de los casos viola no
  es una regla, es una aspiración mal calibrada: o se hace cumplir o se corrige.
  Se corrigió.
- **Encabezados con emoji, con moderación.** Uno por sección de la plantilla.
  Los subtítulos internos pueden llevar emoji-tipo (§7) cuando ayudan a la
  lectura rápida. Un documento que parece un teclado de emojis pierde autoridad.

---

## 4. Idioma del código fuente (código en inglés, curso en español)

> **Regla normativa y no negociable: todo el código fuente del curso se escribe
> en inglés —variables, funciones, componentes, archivos, slices, epics, action
> types, endpoints, constantes, enums, clases CSS— y todos los comentarios se
> escriben en español. Los textos que ve la persona usuaria también van en
> español.** Aplica a cada fragmento de código del proyecto, sin excepción:
> fases, apéndices, incidentes, ejercicios resueltos, tests, `db.json`, el mock
> de Express y los scripts. No hay código legacy "demasiado feo" ni ejemplo
> "demasiado rápido" que quede fuera de esta regla.

El código de Rifas y Chances está en inglés porque lo arrancó un contratista de
fuera en 2019 y la convención quedó (ver `00-historia-del-sistema.md` §3). Es
también lo que va a encontrar el estudiante en casi cualquier base real: si el
tutorial usara `crearRifa` y `rifasSlice`, el vocabulario que practica durante un
mes no sería el que va a leer en producción.

Y la contraparte importa igual: **los comentarios van siempre en español**,
porque son el canal donde se explica el *porqué* de un patrón raro, y ese
razonamiento tiene que leerse en el idioma en que se piensa el curso. Un
comentario en inglés en este proyecto es un error de estilo, aunque el código
que acompañe esté impecable.

La app pedagógica —como la real— **no tiene i18n**: es una app en español para
usuarios de habla hispana. Por eso los textos que ve la persona usuaria (labels,
botones, mensajes de alerta, placeholders) se escriben directamente en español,
tal como se escribieron en el sistema, sin pasar por claves de traducción.
Lo que cambia a inglés es el código que lee y mantiene el equipo.

### 4.1 Cómo se reparte

- **En inglés:** nombres de función, variable, componente, archivo, slice, epic,
  thunk, selector, acción y `actionType`; propiedades de estado y props
  (`state.raffles.items`, `<RaffleForm initialRaffle={…} />`); rutas y endpoints
  (`/raffles`, `/raffles/:id/numbers`, `/login`); constantes y valores de enum
  internos (`status: 'open'`, no `'abierta'`); clases CSS y Sass propias del
  proyecto (`.raffle-card`, no `.tarjeta-rifa`); atributos `data-testid`
  (`data-testid="number-sold"`).
- **En español:** los comentarios de código (`// la reserva expira a los 5 min:
  si no, el número queda bloqueado para siempre`), los textos de interfaz
  (`<button>Vender número</button>`, `"Cargando rifas…"`, placeholders, `alt` de
  imágenes, `title` de tooltips), y toda la narrativa, ejercicios, títulos y
  callouts del tutorial.

Y en la narrativa seguimos hablando en español del dominio: "rifa", "número",
"liquidación", "participante", aunque el código diga `raffle`, `number`,
`settlement`, `participant`.

> ⚠️ **Caso mixto frecuente.** Un objeto de error lleva las *keys* en inglés y el
> *valor* legible por el usuario en español: `{ message: 'El servidor no
> respondió a tiempo', type: 'timeout' }`. Y en un mapeo de estado a etiqueta, el
> `case` es inglés y el `return` es la etiqueta que se muestra:
> `case 'open': return 'Abierta'`.

> 📝 **Por qué este cambio.** Antes de 2026-07-15 el curso mezclaba nombres en
> español (`rifasSlice`, `crearRifa`, `numero`) que no reflejan el código que la
> persona va a mantener de verdad. Ajustamos el pedagógico para que el
> vocabulario de identificadores sea el mismo que va a encontrar en producción,
> sin romper la autocontención del curso (§11).

### 4.2 Criterio rápido ante la duda

Pregúntate quién lee esa cadena de texto. Si la lee **el equipo que mantiene el
sistema** —un identificador, una ruta, un valor de estado interno, una clase
CSS, un `data-testid`—, va en inglés. Si la lee **la persona que usa la app** —un
label, un botón, un mensaje de alerta— o **el estudiante** —un comentario, una
explicación, un enunciado de ejercicio—, va en español. Los nombres del dominio
de negocio en la narrativa no se traducen: el texto sigue hablando de "rifas",
"números" y "liquidación".

### 4.3 Diccionario mínimo del dominio

El diccionario completo y jerarquizado vive en `diccionario-codigo-ingles.md` —
se consulta ahí para cualquier término nuevo. Como referencia mínima, los
términos centrales:

- rifa / rifas → `raffle` / `raffles`
- número / números → `number` / `numbers`
- disponible → `available`
- reservado → `reserved`
- vendido → `sold`
- participante → `participant`
- resultado → `result`
- liquidación → `settlement`
- premio (base) → `(base)Prize`
- hora de cierre → `closingTime` / `closesAt`
- estados de rifa: `draft` → `open` → `closed` → `resolved` → `settled`

Los nombres de componentes, thunks, epics y acciones se arman combinando estos
términos con los verbos técnicos habituales: `get`, `fetch`, `create`, `update`,
`delete`, `sell`, `reserve`, `expire`, `settle`.

### 4.4 Convenciones de nombrado

- **Componentes:** `PascalCase` en inglés — `RaffleTable`, `RaffleForm`,
  `SaleWizard`.
- **Archivos de componente:** mismo nombre que el componente, `.jsx` o `.js`
  según venga usando el proyecto — `RaffleTable.jsx`.
- **Funciones y variables:** `camelCase` en inglés — `sellNumber`,
  `isRaffleOpen`, `closingTime`.
- **Slices:** `<dominio>Slice.js` — `raffleSlice.js`, `saleSlice.js`.
- **Thunks:** verbo + dominio — `fetchRaffles`, `createRaffle`, `sellNumber`.
- **Epics:** `<propósito>Epic` — `pollingEpic`, `sellNumberEpic`.
- **Action types (Redux clásico):** `SCREAMING_SNAKE_CASE` en inglés —
  `SELL_NUMBER`, `START_POLLING`, `STOP_POLLING`. Aplica solo a los types que el
  sistema declara a mano; los que genera Redux Toolkit (`auth/logout`,
  `sales/sellNumber/pending`) **no se escriben nunca a mano**: se toman del
  action creator (`logout.type`). Ver Fase 6 §5.
- **Selectores:** `select` + dominio — `selectRaffleCount`, `selectOpenRaffles`.
- **Endpoints REST:** sustantivo plural en inglés — `/raffles`,
  `/raffles/:id/numbers`, `/results`.
- **Constantes de configuración:** `SCREAMING_SNAKE_CASE` — `CHAOS_LEVEL`,
  `POLLING_INTERVAL_MS`.

### 4.5 Lo que nunca cambia

Los comentarios de código son 100% español y explican el porqué (§5.3). Los
textos de interfaz son 100% español. La narrativa del tutorial es 100% español.
Y los nombres del dominio en la narrativa —"rifa", "número", "liquidación"—
siguen siendo las palabras que usas para *hablar* del sistema, aunque el código
diga `raffle`, `number`, `settlement`.

### 4.6 Ajuste de fases ya escritas

Las fases escritas antes de este cambio usan identificadores en español
(`rifasSlice`, `crearRifa`, `RifasTabla`, `numero`, `estado`). Se ajustan
siguiendo este proceso, fase por fase, en el orden en que fueron escritas:

1. Aplicar el diccionario (`diccionario-codigo-ingles.md`) a cada bloque de
   código.
2. Verificar consistencia con las fases ya ajustadas: si `raffleSlice` usa
   `fetchRaffles`, la fase siguiente no puede usar `getRaffles` para lo mismo.
3. Dejar intactos comentarios, narrativa y textos de interfaz.
4. Revisar ejercicios y referencias que citen nombres de código ("agrega el
   thunk `crearRifa`" pasa a "agrega el thunk `createRaffle`").
5. Marcar el archivo como ajustado en la matriz de verificación (plantilla
   operativa en `diccionario-codigo-ingles.md` §6).

No se reescribe la explicación ni la pedagogía: es un cambio de identificadores,
no de contenido.

---

## 5. Pedagogía: cómo se explica

Esta sección es la que más define el curso. El estudiante es senior en backend
pero novato en este stack, y tiene un mes. La explicación tiene que ser rápida
sin ser hueca.

### 5.1 La regla del andamio

Todo concepto nuevo se presenta en tres tiempos, en este orden:

1. **El problema primero.** Antes de nombrar la herramienta, muestra el dolor
   que resuelve. *"Tienes cuatro componentes que necesitan saber si el usuario
   está autenticado. Puedes pasarlo por props en cadena y sufrir, o puedes…"*
2. **La herramienta después.** Ahora sí, el nombre y la definición mínima.
   Definición mínima significa: lo justo para usarla hoy, no el capítulo
   completo de la documentación.
3. **El código que corre.** El fragmento más pequeño que demuestra el punto, con
   comentarios que explican el porqué.

Presentar la herramienta antes que el problema produce estudiantes que saben
escribir un epic pero no saben cuándo hace falta. Y en este curso ese error se
paga caro: la mitad de los antipatrones que enseñamos nacen de usar RxJS donde
bastaba un thunk.

### 5.2 Analogías con backend, sin abusar

El estudiante viene de backend. Aprovéchalo: un middleware de Redux es
conceptualmente primo de un filtro o interceptor HTTP; una ruta protegida es un
check de autorización antes del handler; el store es un estado en memoria
compartido con transiciones controladas; un epic es un consumidor de una cola de
eventos que puede emitir eventos nuevos.

Dos límites: la analogía se usa **una vez, para abrir la puerta**, y después se
abandona; y se dice explícitamente dónde se rompe (*"hasta acá el paralelo
funciona; la diferencia es que la ruta protegida corre en el navegador y el
usuario puede saltársela, así que no es seguridad, es experiencia de usuario"*).
Una analogía que no se cierra genera bugs conceptuales que aparecen tres fases
después.

### 5.3 Explica el porqué, no solo el cómo

Un paso sin justificación es un paso que el estudiante no puede adaptar cuando
el código que abras difiera del ejemplo. Cada decisión relevante lleva su porqué,
aunque sea media línea entre paréntesis.

Eso vale también para los comentarios de código: **explican el porqué, no el
qué, y siempre en español**. `// la reserva expira a los 5 min: si no, el número
queda bloqueado para siempre` sí; `// incrementa i` no, ni en español ni en
inglés.

Y cuando el porqué es histórico y no técnico —que en legacy pasa seguido—, se
dice también: *"esto está así porque en 2020 era la única forma; hoy hay tres
mejores y ninguna te sirve porque no vas a migrar"*.

### 5.4 Densidad calibrada

- Un concepto nuevo por vez. Si un bloque de código introduce tres cosas
  desconocidas, se parte en tres bloques.
- Repetir lo importante está bien. Los conceptos que sostienen el curso —flujo
  de datos unidireccional, ciclo de vida, dónde vive el estado, qué corre en el
  navegador y qué en el mock— pueden reaparecer varias veces con otras palabras.
  La repetición espaciada funciona; la enciclopedia no.
- Ninguna sección teórica supera las dos pantallas sin que aparezca código.

### 5.5 Anclado al dominio y a código que corre

- **Nada de teoría suelta.** Si se explica `switchMap`, se explica sobre el epic
  de polling del resultado de la lotería, no en abstracto.
- **Código ejecutable y coherente.** Todo fragmento debe correr con las
  versiones fijadas y no contradecir fases anteriores. Nada de pseudocódigo que
  "se entiende".
- **Código mínimo.** El fragmento más pequeño que muestra el punto. Se recorta lo
  accesorio, pero el resultado sigue siendo ejecutable.
- **Distinguir capas.** Siempre queda claro si un comportamiento vive en el
  componente, en el store (Redux), en el epic (RxJS) o en el backend (mock). Es
  la distinción que salva al que depura.

### 5.6 Cierra los bucles

Si abres un paréntesis pedagógico —*"esto lo vemos en la Fase 7"*, *"acá dejamos
deuda 💸"*— tiene que cerrarse en algún documento del curso. Un pendiente que
nunca se resuelve es ruido, y el lector deja de confiar en las promesas del
texto. En este curso la deuda 💸 además **se paga** explícitamente (§7.3), no
solo se declara.

---

## 6. Manejo del código legacy (el corazón del tutorial)

Acá está la tentación grande: escribir código *bueno* en vez de código *real*.
No lo hacemos.

- **No modernizar por reflejo.** Si el módulo real es una clase con
  `componentDidMount`, se muestra la clase. No se "mejora" a hooks salvo en una
  fase o ejercicio 🔥 marcado.
- **Clases y hooks conviven.** Se enseñan ambos y se muestra cómo leer código
  mezclado sin marearse.
- **`connect()` y `useSelector` conviven.** Igual: ambos aparecen según el
  módulo.
- **Redux Toolkit para slices nuevos**, pero se muestra el estilo clásico cuando
  sea pedagógicamente útil.
- **RxJS con moderación.** Los epics son necesarios, pero se enseña *cuándo NO
  usar un epic*: a veces un thunk basta. Sobreusar RxJS es un antipatrón que
  nombramos.
- **Corrección mínima vs refactor.** Cada vez que aparece un fix, se distingue el
  parche mínimo —lo que va en un hotfix un viernes— de la refactorización —lo que
  iría con calma y pruebas. Es una de las lecciones más transferibles del curso.
- **El idioma del código (§4) no es negociable ni en el código más feo.** Un
  módulo viejo y mal escrito se muestra viejo y mal escrito, pero con
  identificadores en inglés y comentarios en español. La fealdad que enseñamos
  es de arquitectura y de decisiones, no de idioma. Todo el código del curso se
  normaliza a
  inglés siempre.

### 6.1 Convenciones de código concretas

- `function () {}` en métodos de clase, no arrow, para mantener el sabor de la
  época y hacer visible el tema del `this`. Las arrow sí se usan en componentes
  funcionales y callbacks cortos.
- Dinero en enteros (centavos), nunca floats.
- Fechas con zona horaria explícita. Nunca un `new Date()` suelto donde importe
  el día: las rifas que cierran a medianoche viven de esa precisión.
- Los epics con `.pipe()` y operadores nombrados, no encadenamientos crípticos.
- Identificadores, endpoints y constantes en inglés (§4); comentarios y textos
  de interfaz en español (§4.5).

---

## 7. Marcadores y callouts (vocabulario visual del curso)

Vocabulario visual compartido por todos los documentos, para que el lector lo
reconozca de un vistazo.

### 7.1 Marcadores de estado

- 💸 **Deuda técnica intencional.** Todo atajo o patrón feo que se deja a
  propósito para reproducir cómo envejece un sistema. Se declara en una fase y se **paga**
  explícitamente en otra (§7.3).
- 🔥 **Opcional o ampliación.** Fases, secciones y ejercicios fuera del alcance
  base. No cuentan en las 96h.
- ⭐ **Pieza central.** Las fases 5 y 6, y los incidentes más formativos del
  curso.
- 🟢🟡🟠🔴 **Dificultad de ejercicios.** Fácil, intermedio, difícil, muy difícil.
- 🏷️ **Tag de progreso.** El recordatorio de cerrar la fase (o el apéndice) con
  su tag de git. Va **una sola vez por documento**, al final, con la forma fija
  de §8.1.

### 7.2 Callouts en blockquote (emoji-tipo)

- 📝 **Nota de época.** Contexto histórico de un patrón que hoy se ve raro. Ej:
  *"usamos `var self = this` + `function () {}` para mantener el sabor legacy; en
  bases reales verás también arrow functions o `.bind(this)`."*
- 📚 **Referencia rápida inline.** El enlace útil justo donde nace la duda, sin
  esperar a la sección de referencias.
- 🪦 **Retiro.** Cuando algo cumple su función y sale del proyecto. Ej: *"retiro
  formal de `stubby`: puedes borrarlo o dejarlo en `docs/legacy/` como recuerdo."*
- ⚠️ **Advertencia.** Algo que rompe si lo ignoras: versión incompatible,
  `node_modules` compartido entre arquitecturas, config horneada en el build.
- 💡 **Truco o atajo** que ahorra tiempo real.

No hace falta usarlos todos en cada documento. Se usan cuando aportan.

### 7.3 Secciones narrativas recurrentes

Micro-secciones con nombre fijo, que aparecen cuando el contenido las pide:

- **💸 Pago de deuda.** Sección donde una deuda declarada en una fase anterior se
  salda. Se nombra qué deuda era, de qué fase venía, y se muestra el cambio.
  Cierra el ciclo declarar → pagar.
- **Detalles con intención.** Lista corta con las decisiones deliberadas de un
  bloque de código y su porqué: *"devolvemos `res.data`, no la respuesta cruda de
  axios, porque el componente no debería conocer la forma del objeto de axios"*.
- **El patrón a memorizar.** Una o dos frases que destilan la lección
  transferible del fragmento: *"`loading = true` → llamar servicio → `.then`
  guarda datos → `.catch` guarda error legible → `.finally` apaga el loading"*.
- **Prueba de fuego.** Verificación manual concreta, incrustada en el flujo y no
  en los ejercicios: *"apaga json-server, recarga, confirma que ves el mensaje de
  error con botón de reintento; vuelve a levantarlo y reintenta"*.
- **Mini-repaso.** Cuando la fase usa sintaxis que el dev de backend quizá no
  domina (JSX, hooks, operadores de RxJS), un repaso exprés antes de entrar al
  código, con su 📚 a la documentación oficial.
- **La señal de que quedó bien.** En el cierre, un criterio en forma de cita que
  describe cómo se siente el trabajo bien hecho: *"si mañana me cambian el mock
  por un backend real, solo toco el `baseURL` y ninguna vista se entera"*.

---

## 8. Plantilla obligatoria de cada fase (9 secciones)

Toda fase produce un `.md` con exactamente estas nueve secciones, en orden:

1. **🎯 Propósito** — qué resuelve la fase. Puede abrir con la situación heredada
   de la fase anterior (*"hasta ahora la app vive de mentiras piadosas…"*).
2. **✅ Qué queda listo al terminar** — checklist verificable, no promesas.
3. **🚫 Qué queda fuera por ahora** — qué se difiere y a qué fase exacta.
4. **🧠 Conceptos mínimos** — la teoría justa, anclada al dominio. Acá caben el
   **Mini-repaso** y las **Notas de época**.
5. **💻 Implementación y código comentado** — el grueso. Código ejecutable con las
   versiones fijadas, identificadores en inglés y comentarios en español (§4).
   Acá caben **Detalles con intención**, **El patrón a memorizar**, **Prueba de
   fuego** y **💸 Pago de deuda**.
6. **⚠️ Errores comunes y pieza forense** — qué se rompe típicamente y cómo se
   depura. Enlaza con los incidentes que la fase produce en
   `cuaderno-incidentes.md`, por ID.
7. **🧪 Ejercicios progresivos** — ver §9.
8. **📚 Referencias** — ver §10.
9. **🚀 Cierre y conexión con la siguiente fase** — qué sigue, por qué, **La
   señal de que quedó bien** y el recordatorio 🏷️ del tag de la fase (§8.1).

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
commit— y va **después** de "La señal de que quedó bien", justo antes del `---`
que abre los 📌 Pendientes:

````markdown
> 🏷️ **No cierres la fase sin el tag.** Con el checklist de la sección 2 en
> verde y `git status` limpio:
>
> ```bash
> git tag -a fase-04-rifas-crud -m "F4 cerrada: <el checklist, en una línea por ítem>"
> ```
>
> Los commits de la fase llevan su prefijo (`f04: …`) y los de ejercicio su
> número (`f04 ej17: …`). Si un ejercicio merece su propio marcador va en
> `ej/f04/17`, y un incidente resuelto en el par `inc/<ID>/<slug>-roto` /
> `-fix`, con el ID que le reserva `cuaderno-incidentes.md`. Todo eso está en
> [`00-convencion-de-git-y-tags.md`](../00-convencion-de-git-y-tags.md).
````

El nombre del tag es **`fase-` + el mismo slug del archivo `.md`**, sin
excepciones (`04-rifas-crud.md` → `fase-04-rifas-crud`,
`be03-crud-y-el-reemplazo.md` → `fase-be03-crud-y-el-reemplazo`), y el prefijo
de commit es `f` + dos dígitos en el track base (`f04`) o el código de fase en
el track BE (`be03`). Nada más se reexplica en la fase: se enlaza.

**Los apéndices también lo llevan**, en dos variantes según lo que dejen en el
repo. Los que dejan código —`A1`, `A2`, `A9`, `A10`, `A11`— cierran con su tag
propio (`apendice-` + el slug del archivo en minúscula:
`A10-aritmetica-de-dinero.md` → `apendice-a10-aritmetica-de-dinero`) y su
prefijo de commit (`a10: …`). Los de consulta pura —`A3`, `A4`, `A5`, `A6`,
`A7`, `A8`, `A12`, `A13`— dicen explícitamente que **no** llevan tag propio y
que lo que salga de leerlos se commitea con el prefijo de la fase desde la que
se llegó. Un tag que no apunta a un cambio no marca nada.

---

Los apéndices no siguen esta plantilla: usan índice de salto rápido, secciones
cortas, una guía final de "cuándo usar qué" y 5-10 ejercicios cortos.

---

## 9. Ejercicios

- **Cantidad: 25 mínimo, 30-35 ideal por fase.** Menos de 25 se queda corto para
  media jornada de práctica. Las fases largas llegan a 35 y ese es el techo
  razonable: más allá, el bloque de ejercicios pesa más que la fase.
- **Distribución equilibrada.** Para ~30 ejercicios: unos 8 🟢, 9 🟡, 7 🟠 y 4-6
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
- **Progresión real.** Los 🟢 calientan; los 🔴 exigen integrar varias fases o
  depurar algo esquivo.
- **Accionables y verificables.** *"Haz que el número 0347 no pueda venderse dos
  veces bajo doble click rápido"* — no *"reflexiona sobre concurrencia"*.
- **Al menos un tercio son de diagnóstico**, no de construcción: se entrega algo
  roto y se pide reproducir, localizar y explicar. Es el músculo que este curso
  entrena.
- **Enganchados al dominio.** Rifas, números, participantes, resultados y
  liquidaciones. Nunca `foo` y `bar`.
- **Con el identificador vigente.** Si el ejercicio nombra código, usa el nombre
  en inglés que ya existe en la fase ("agrega el thunk `createRaffle`", no
  "agrega el thunk `crearRifa`"), aunque el enunciado esté en español.
- Los 🔥 son opcionales y se listan aparte, sin numeración continua.

En apéndices bastan 5-10 ejercicios cortos de consulta.

---

## 10. Bibliografía y referencias

**Regla:** documentación oficial compatible con las versiones fijadas primero;
después libros; después blogs, videos y tutoriales. Siempre se advierte cuando un
enlace apunta a una versión distinta de la que usamos, que con React pasa casi
siempre.

### 10.1 Formato

URLs completas y clicables, nunca solo el dominio:
`https://legacy.reactjs.org/docs/react-component.html`, no "legacy.reactjs.org".
Dentro de "Referencias", se separa en documentación oficial (con nota de
versión), libros cuando apliquen, video y apoyo —screencasts y crash courses en
YouTube son bienvenidos: a este perfil le sirven—, y una línea final de **orden
de lectura sugerido** que encadene qué leer primero. Ej: *"README de
redux-observable → RxJS operators → volver al epic."*

### 10.2 Fuentes oficiales por tema

- **React clases (legacy):** https://legacy.reactjs.org — es la referencia por
  defecto.
- **React hooks:** https://react.dev — advertir: cubre ≥ 16.8; cuidado con APIs
  de 17/18.
- **Redux y Redux Toolkit:** https://redux.js.org · https://redux-toolkit.js.org
  (fijar en 1.x).
- **redux-observable:** https://redux-observable.js.org
- **RxJS 6:** https://rxjs.dev — advertir las diferencias de imports y operadores
  con RxJS 7.
- **React Router 5:** https://v5.reactrouter.com
- **Bootstrap 4.6:** https://getbootstrap.com/docs/4.6
- **Testing:** https://jestjs.io · https://testing-library.com ·
  https://playwright.dev
- **MDN** para JavaScript base (Promises, Intl, etc.):
  https://developer.mozilla.org

### 10.3 Advertencias

- Cuando se cite un artículo, libro o video específico, se aclara que el título o
  la URL pueden haber cambiado y que conviene verificarlos. No se inventan
  números de página, ISBN ni identificadores de video.
- **No usar en el código principal** APIs exclusivas de React 17/18, React Router
  6, RTK moderno (listener middleware, etc.) ni RxJS 7. Aparecen solo como
  comparación o en secciones y fases 🔥.

---

## 11. Autocontención

**Regla no negociable: el curso se completa solo.** Un estudiante con este
directorio, una máquina y conexión a internet para leer documentación oficial
tiene todo lo que necesita. Sin repositorio de empresa, sin sistema previo, sin
instructor, sin compañeros.

De ahí salen cuatro prohibiciones concretas al escribir:

- **No cites archivos que no existen.** Cada referencia cruzada —a una fase, a un
  apéndice, a un incidente, a un archivo de decisiones— tiene que resolver a algo
  real dentro del repositorio. Una cita rota le hace perder media hora a alguien
  buscando un documento que nadie escribió.
- **No difieras una decisión a una confirmación externa.** Nada de "pendiente de
  confirmar contra el sistema real" ni "cuando el equipo defina la versión". Si el
  curso necesita una versión, una librería o un dato del dominio, **se decide y se
  registra** en `prompts/decisiones-y-versiones.md` (versiones y stack) o en
  `00-historia-del-sistema.md` (por qué el sistema es como es), y se cita desde ahí.
- **No inventes contexto en el aire.** Si una fase necesita explicar por qué un
  componente está feo, el porqué vive en `00-historia-del-sistema.md` y la fase lo
  enlaza. Así el mismo hecho no se cuenta de tres formas distintas en tres
  archivos.
- **No dependas de material que el estudiante no pueda conseguir.** Un video de
  YouTube que puede desaparecer es una sugerencia, no un requisito; el contenido
  necesario para completar una fase está siempre en la fase.

📝 **De dónde viene esta sección.** Antes decía "Confidencialidad (NDA)" y
regulaba cómo hablar de un sistema corporativo real que el curso usaba como
referencia sin poder describirlo. Ese encuadre se eliminó: Rifas y Chances
S.A.S. es una empresa ficticia y su historia se cuenta entera. La regla que
sobrevive del original es la buena — **ante la duda, se explicita** — solo que
ahora explicitar es gratis, porque no hay nada que ocultar.

---

## 12. Coherencia entre documentos

- **No contradecir fases anteriores.** Un fragmento de la Fase 6 no puede usar
  una estructura de store distinta a la que definió la Fase 4.
- **No reescribir decisiones aprobadas** sin señalar explícitamente la
  incompatibilidad y explicar por qué.
- **Nombres de archivo del curso, todos en minúscula.** Las fases son
  `NN-slug-en-minusculas.md` (`04-rifas-crud.md`), los apéndices
  `AN-slug-en-minusculas.md` (`A3-node-y-npm.md`), y los documentos de encuadre
  y editoriales igual (`00-alcance-del-proyecto.md`,
  `prompts/decisiones-y-versiones.md`). Sin guiones bajos, sin mayúsculas
  internas y **sin tildes**: separador es el guion.

  🔥 **El track BE opcional usa su propio prefijo, en el mismo directorio:** las
  fases son `beNN-slug.md` (`be03-crud-y-el-reemplazo.md`) y los apéndices
  `bea-NN-slug.md` (`bea-02-receta-de-imagen-y-compose.md`). El prefijo
  mantiene los tres bloques ordenados y separados sin subdirectorios, y la
  numeración de dos dígitos en los apéndices evita el desorden alfabético que
  arrastran los `A1`–`A13` del track base. Ver §16.

  📝 **Por qué sin tildes, que es la parte que sorprende.** No es purismo
  técnico: es que un repositorio se clona en macOS, Linux y Windows, y los tres
  normalizan los acentos de forma distinta en el sistema de archivos. Un
  `A7-redux-observable-épica.md` puede quedar rastreado dos veces en git tras un
  clon cruzado. El contenido sigue en español con todas sus tildes; solo el
  nombre del archivo se mantiene ASCII.

  ⚠️ **Y el caso que ya mordió una vez:** macOS no distingue mayúsculas en
  nombres de archivo y Linux sí. Un archivo llamado `ALCANCE-DEL-PROYECTO.md` y
  citado como `Alcance-del-proyecto.md` funciona en tu máquina y rompe las 64
  referencias en CI. La minúscula uniforme elimina la clase entera de problema.

- **Nombres estables.** Archivos, slices, componentes, epics y acciones se
  mantienen idénticos entre fases (todos en inglés, §4.4). Si algo se renombra,
  se documenta el cambio y se ajustan las fases afectadas.
- **Fuentes de verdad, en este orden:** (1) `prompts/instrucciones-del-proyecto.md`,
  (2) `00-alcance-del-proyecto.md`, (3) `prompts/decisiones-y-versiones.md` para cualquier
  versión o decisión técnica y `00-historia-del-sistema.md` para cualquier porqué
  del sistema, (4) esta guía, (5)
  `prompts/diccionario-codigo-ingles.md` para cualquier término de código, (6)
  `prompts/plantilla-de-fase.md` para la forma del entregable —con
  `00-convencion-de-git-y-tags.md` como su anexo para todo lo que toque git,
  repos y tags—, (7) entregables ya
  aprobados de fases anteriores, (8) decisiones explícitas del chat actual. Los
  archivos `prompts/prompts-a-*.md`, `prompts/prompts-b-*.md` y
  `prompts/prompts-backend-*.md` son insumos de redacción, no fuentes de verdad:
  si contradicen a esta guía, gana la guía.

  🔥 **Para el track BE se intercala una fuente más**, entre la (2) y la (3):
  `prompts/propuesta-fases-backend.md`, que es el encuadre del track —qué deuda
  cobra cada fase, el presupuesto de horas y el alcance. Para versiones sigue
  mandando `prompts/decisiones-y-versiones.md`, ahora en su §7.

---

## 13. Post-mortems e incidentes

Cada incidente sigue esta estructura de ocho puntos:

1. Síntoma, en palabras del usuario.
2. Pasos de reproducción exactos.
3. Evidencia observable: consola, Network, DevTools, logs.
4. Causa raíz, hasta la línea o el commit.
5. Corrección aplicada.
6. Prueba de regresión que falla antes del fix y pasa después.
7. Prevención: test, feature flag o alerta.
8. Post-mortem **sin culpabilización** (blameless): se analiza el sistema y el
   proceso, no a la persona.

El tono acá baja un punto de humor. Un post-mortem es sereno y analítico —no
acartonado, pero tampoco el lugar para el chiste.

Los puntos 1 a 6 tienen traducción exacta a git, y conviene pedirla: el par de
tags `inc/<ID>/<slug>-roto` e `inc/<ID>/<slug>-fix` deja el síntoma y la
regresión en rojo en el primero, la causa raíz y el fix en el segundo, y el
`git diff` entre los dos **es** el punto 5 aislado del ruido. El `<ID>` es el
que `cuaderno-incidentes.md` ya tiene reservado, nunca uno inventado. El detalle
está en `00-convencion-de-git-y-tags.md`, y las fases lo enlazan desde su bloque
🏷️ sin reexplicarlo.

---

## 14. Checklist antes de dar por cerrado un `.md`

- [ ] Sigue la plantilla de 9 secciones (o el formato de apéndice), con 📌
      Pendientes sugeridos y reservas de incidentes al final.
- [ ] Tono semi formal y cálido, humor con moderación.
- [ ] **Tuteo latinoamericano en todo el documento: cero voseo** (§2).
- [ ] Explica el problema antes que la herramienta, y el porqué de cada decisión.
- [ ] Prosa antes que listas; listas antes que tablas en comparativas extensas.
      Tablas de hasta cuatro columnas y sin celdas de más de una línea (§3).
- [ ] Las analogías con backend se cierran diciendo dónde se rompen.
- [ ] Todo el código corre con las versiones fijadas del stack.
- [ ] **Identificadores, endpoints, constantes y enums del código en inglés**
      (§4); **comentarios y textos de interfaz en español** (§4.5). Sin
      excepciones, ni en el código legacy más feo.
- [ ] Clases y hooks conviven; `function () {}` en métodos, dinero en enteros,
      fechas con zona horaria explícita.
- [ ] Distingue componente / store / epic / backend donde importa.
- [ ] Usa el vocabulario de callouts (📝 🪦 📚 ⚠️ 💡) y las secciones narrativas
      donde aporten.
- [ ] Marca 💸 la deuda técnica (y la paga si corresponde) y 🔥 lo opcional.
- [ ] Cierra los bucles que abrió: nada de "esto lo vemos después" sin destino.
- [ ] Tiene 25-35 ejercicios con rangos 🟢🟡🟠🔴 equilibrados, varios de
      diagnóstico (o 5-10 cortos en apéndices).
- [ ] Enlaza su pieza forense y los incidentes relacionados, **y los apéndices
      que su contenido necesita**: si la fase escribe Bootstrap enlaza A1, si
      tiene una clase enlaza A5, si tiene un slice enlaza A6, si tiene un epic
      enlaza A7 y A11, si toca dinero enlaza A10.
- [ ] Referencias con URL completa, secciones (oficial / libros / video / orden
      de lectura) y advertencia de versión cuando no coincida.
- [ ] No contradice ninguna fase anterior, ni en pedagogía ni en nombres.
- [ ] Nombres de archivo en minúscula, con guiones y sin tildes (§12).
- [ ] Autocontenido (§11): cada referencia cruzada resuelve a un archivo real,
      ninguna decisión queda "pendiente de confirmar", ninguna dependencia de
      material externo.
- [ ] Incluye "La señal de que quedó bien" en el cierre.
- [ ] Lleva el bloque 🏷️ del tag al final, con el nombre correcto (`fase-` o
      `apendice-` + el slug del archivo) y el prefijo de commit correcto
      (§8.1). En los apéndices de consulta pura, el bloque dice que no llevan
      tag propio.

---

## 15. Pendientes que afectan a esta guía

Anotados acá para no bloquear la escritura, pero hay que resolverlos:

- ~~**Presupuesto horario.**~~ **Resuelto.** La duda era si las cifras que
  circulan por varios documentos se contradecían. No se contradicen: las horas que
  declara cada fase en su cabecera suman **exactamente** los totales publicados —el
  track base `6+8+8+6+8+12+12+10+8+6+6+6 = 96 h`, y el track BE
  `6+8+10+10+8+10+8+6+10+8 = 84 h`—. Queda fijada la autoridad: manda
  `00-alcance-del-proyecto.md` (§1 y §7) para los totales, y la cabecera de cada
  fase para su tramo. Si alguna vez dejan de cuadrar, gana el alcance y se ajusta
  la fase.
- ~~**Tablas anchas heredadas.**~~ **Resuelto**, en parte reescribiendo y en
  parte corrigiendo la regla. Las dos tablas narrativas que de verdad
  incumplían —la matriz de entornos de la Fase 0 (seis columnas) y el mapa de
  deuda de la Fase 11 (cinco, con párrafos por celda)— se convirtieron en listas
  con subtítulos al extraer los apéndices A9 y A12. Las siete restantes son
  tablas de equivalencia de cuatro columnas, y §3 ahora las admite
  explícitamente.
- ~~**El cuaderno de incidentes está vacío.**~~ **Resuelto.** Los veinte
  enunciados están redactados siguiendo la estructura de ocho puntos de §13, con
  sus tres pistas escalonadas y su solución de referencia colapsada. Se agregó
  además la sección 🩺 "Entrar por el síntoma" —método de cuatro preguntas y tabla
  de síntoma a herramienta—, que el cuaderno del track BE replica. La plantilla,
  que vivía embebida en el archivo como "Incidente 01", se extrajo a
  `prompts/plantilla-de-incidente.md`; su hermana de backend es
  `plantilla-de-incidente-be.md`.
- ~~**Los enunciados dicen `git checkout incidente/NN` y nadie escribió qué trae
  esa rama.**~~ **Resuelto el 11/09/2026.** El **estado roto** de cada incidente
  —qué línea rompe cada rama, qué registros hay que sembrar y cómo comprobar que
  la preparación reproduce el síntoma— vive en
  `prompts/preparaciones-de-incidentes.md` y, para el track opcional, en
  `prompts/preparaciones-de-incidentes-be.md`. Van **aparte de los cuadernos y sin
  enlace desde ellos**, porque son la respuesta y no pueden quedar a un clic del
  enunciado. Escribirlos destapó dos enunciados irreproducibles —los incidentes
  **07** y **10** declaraban "Rama: ninguna" sobre código que las Fases 3 y 4
  escriben bien—, que se corrigieron en el mismo movimiento.
- **Seis tablas superan las cuatro columnas, y las seis son excepciones
  deliberadas a §3.** La regla de §3 apunta a las tablas *narrativas* —aquellas
  cuyas celdas necesitan una frase para entenderse—, y ninguna de estas lo es: son
  **registros**, con celdas de una o dos palabras, donde pasar a lista con
  subtítulos las volvería ilegibles. Quedan documentadas acá para que no se
  "corrijan" por error:
  - los **índices de los dos cuadernos de incidentes** (seis columnas: ID, fase,
    título, categoría, dificultad, estado). Es el caso arquetípico de tabla;
  - las dos **matrices de variables por ambiente** (`bea-02` §7 y `be09` §3), de
    cinco columnas, una por ambiente. Son las hermanas de la matriz de entornos de
    la Fase 0 que sí se convirtió a lista, y se conservan porque aquí las celdas
    son valores, no párrafos;
  - la **tabla de mediciones** de `be09` §8, cinco columnas de cifras;
  - la **tabla de cumplimiento por archivo** de `diccionario-codigo-ingles.md`, de
    siete columnas. Es material de autoría, no de lectura, y funciona como
    checklist.

Resueltos desde la última revisión —se dejan anotados para no repetir el
trabajo—: la normalización de voseo a tuteo en las doce fases, los ocho
apéndices y los `prompts-*.md`; el reemplazo de las citas a archivos que nunca
existieron (`PLAN-DEL-CURSO`, `TUTORIAL-REACT16`, `DECISIONES-PENDIENTES`,
`CATALOGO-FASES-Y-APENDICES`, `DECISIONES-CONFIRMADAS`, `FORENSE-CHECKLIST-RXJS`,
`REGRESION-EPICS-CON-MARBLES`) por los archivos reales de §12; el ajuste §4.6 de identificadores a inglés; y la
creación de `cuaderno-incidentes.md` con sus veinte IDs reservados desde las
fases que los producen.


---

## 16. Track BE opcional 🔥 — lo que cambia y lo que no

El track de backend (`be00`–`be09`, apéndices `bea-01`–`bea-10`) se rige por
**esta misma guía**, sin excepciones editoriales. Tono, tuteo, prosa antes que
listas, tablas cortas, callouts, marcadores 💸🔥⭐🪦 y la plantilla de nueve
secciones: todo igual. Lo que sigue son las adiciones que el cambio de lenguaje
y de capa obliga a precisar.

### 16.1 Lo que no cambia

La plantilla de nueve secciones de §8 aplica tal cual, incluidos los 📌
Pendientes sugeridos al final. Los ejercicios siguen la regla de §9: 25 mínimo,
30-35 ideal, con al menos un tercio de diagnóstico. Los apéndices siguen siendo
consulta rápida con 5-10 ejercicios. Y el idioma se reparte exactamente igual
que en §4: **narrativa, comentarios y textos de interfaz en español; código en
inglés**, y eso incluye nombres de paquete, tipos, funciones, campos de struct,
etiquetas JSON, tablas y columnas.

También aplica el bloque 🏷️ de §8.1, con una precisión propia: el tag es
`fase-be03-…` y el prefijo de commit `be03:`. El backend vive en `server/`
dentro del mismo repositorio del alumno (`prompts/propuesta-fases-backend.md`
§9), así que la regla de §16.2 se demuestra con un diff acotado —
`git diff pre-backend-go..HEAD -- . ':!server'` vacío—, y conviene que cada fase
BE lo pida explícitamente en su checklist de la sección 2. Ver
`00-convencion-de-git-y-tags.md`.

### 16.1bis Los incidentes del track viven aparte

Los dieciséis incidentes del track BE (`be-01`–`be-16`) están en
**`cuaderno-incidentes-be.md`**, no en `cuaderno-incidentes.md`. Es una
divergencia deliberada de la frase *"este es el único archivo de incidentes del
curso"*, escrita antes de que el track existiera, y su motivo está declarado en
los dos archivos: el track BE es opcional y no debe filtrarse al cuaderno de
quien solo hace las 96 horas base.

La estructura, las reglas y el tono son **idénticos**; lo único que cambia son las
herramientas —logs, `psql`, `pg_stat_activity`, `EXPLAIN`, `go test -race`,
`docker`— y una pregunta propia que encabeza cada enunciado: **de qué lado del
cable está la causa**. La plantilla está en
`prompts/plantilla-de-incidente-be.md`, y es a `cuaderno-incidentes-be.md` lo que
`prompts/plantilla-de-fase.md` es a una fase.

Cuando un incidente BE comparta síntoma con uno del track base, **se marca en los
dos sentidos**: el paralelo —mismo síntoma, otra capa, otra causa raíz— es de lo
más formativo que ofrece el track.

### 16.2 La regla que ordena el track entero

> 🧭 **El frontend heredado no se toca.** El backend se adapta al contrato
> existente, nunca al revés. Si una fase necesita cambiar un componente, un
> slice, un epic o el `baseURL`, la fase está mal diseñada.

De ahí se deriva una segunda regla de escritura: **cada fase BE tiene que poder
responder qué deuda 💸 del track base cobra**. La que no pueda responderlo sobra,
por interesante que sea. Es el antídoto contra la deriva natural de este track,
que es convertirse en un curso de Go.

### 16.3 Convenciones de código Go

- Errores explícitos con `if err != nil`, envueltos con `%w` cuando aporten
  contexto. Nada de `panic` fuera del arranque.
- `context.Context` como primer parámetro en todo lo que cruce una frontera:
  handler, service, store. Es el vehículo del `X-Request-Id` y de la
  cancelación.
- SQL escrito a mano y **visible** en el código, nunca generado. Placeholders
  parametrizados siempre: el track enseña inyección SQL en `bea-08` y no puede
  predicar con un mal ejemplo.
- Dinero en `int64` de centavos, coherente con `A10`. Fechas en `TIMESTAMPTZ` y
  serializadas en RFC 3339.
- Estructura en capas explícita —handler → service → store— y nombrada así en la
  narrativa, del mismo modo que el track base distingue frontend / store / epic /
  backend.
- **Nada de Go moderno gratuito** (D14): sin `slog`, sin `errors.Join`, sin los
  patrones de método de `http.ServeMux`, sin genéricos. Aparecen marcados 🔥
  como comparación, igual que React 18 en el track base.

### 16.4 La pieza forense cambia de herramienta

En el track base la pieza forense vive en el navegador: consola, Network, React
DevTools, Redux DevTools. En el track BE vive del otro lado del cable, y por eso
hay que nombrarla con la misma precisión: un log estructurado, un `EXPLAIN`, una
transacción bloqueada observada en `pg_stat_activity`, un `go test -race`, un
`docker build` que falla solo en el runner. Cuando la fase pueda cerrar el
círculo entre las dos orillas —un `X-Request-Id` copiado de la consola del
navegador y encontrado en el log del backend, con su consulta y su tiempo—, eso
es preferible a cualquier otra pieza forense.

### 16.5 Autocontención, con un matiz extra

Rige §11 completa, y encima una restricción propia: **este track no remite a
ningún otro curso del catálogo**, exista o no uno de contenedores. Todo lo que el
alumno necesite para construir la imagen y el pipeline vive en `bea-02`,
escrito como receta cerrada y verificable de principio a fin.
