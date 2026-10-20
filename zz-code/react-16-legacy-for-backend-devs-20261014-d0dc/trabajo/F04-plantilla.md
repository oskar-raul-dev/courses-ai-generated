# 🧱 Fase 04 — Ruedas CRUD

> Tutorial React 16 — La Esclusa, la consola de Jewel Locks · Fase 4 de 11 · **8 horas**
> Depende de: Fase 3 — Mock API y Express caos · Habilita: Fase 5 — Envíos manuales

---

## 🎯 1. Propósito

Itzel está armando la rueda de la próxima Semana del Canal y carga los pesos segmento por segmento. La consola los guarda sin decir nada, y el juego, al publicarlos, los rechaza. Su mensaje llega temprano: *"cargué la rueda nueva y el juego dice que los pesos no suman cien; ¿cómo me dejó guardar eso la consola?"*.

Hasta acá la app sabía navegar (Fase 1), autenticarse (Fase 2) y hablar con un backend que falla a propósito (Fase 3). Lo que no sabía era **hacer algo útil con datos**. Esta fase construye el primer CRUD real del sistema: administrar ruedas y sus segmentos contra el mock, con Redux Toolkit como store.

El objetivo no es que aprendas a escribir un slice —eso lo hace cualquiera con la doc abierta— sino que aprendas a escribir uno que **sobreviva a un backend áspero**. El mock de Fase 3 mete latencia, 503, timeouts y respuestas malformadas. Un CRUD que solo maneja el camino feliz es un bug esperando el ticket. Acá cada operación nace sabiendo que puede fallar, y el store refleja esa realidad en vez de fingir que todo sale bien.

Es CRUD honesto: crear, listar, editar y borrar ruedas, con la regla del dominio que más importa a la vista: **los pesos de una rueda son enteros en puntos básicos y suman exactamente 10.000**, y una rueda en vivo no los cambia. Las transiciones de estado con reglas duras (`live → ended` a hora fija), los envíos y los epics son de fases posteriores. Acá se sientan los cimientos del store sobre los que todo lo demás se va a apoyar.

---

## ✅ 2. Qué queda listo al terminar

- [ ] Slice `wheelSlice` con Redux Toolkit 1.8.x: estado con lista, flags de carga, error legible y rueda en edición, conectado al mock de Fase 3.
- [ ] Cuatro `createAsyncThunk` (`fetchWheels`, `createWheel`, `updateWheel`, `deleteWheel`) sobre `apiClient`, cada uno con su rama `rejected` desde el día uno.
- [ ] El error legible (`toReadableError`) en `src/api/readableError.js`, para que el resto de los slices hable el mismo idioma de errores.
- [ ] Reglas de pesos en `src/features/wheels/weightRules.js`: enteros, mayores que cero, suma 10.000; y la regla "en vivo no se editan pesos".
- [ ] Tabla de ruedas (`WheelTable`) como **class component** con `connect()`, con estados visuales de carga, error, vacío y lista.
- [ ] Formulario de alta y edición (`WheelForm`) como **componente funcional con hooks**, controlado, que muestra la suma de los pesos y no deja guardar una rueda que no cuadra.
- [ ] Página contenedora (`WheelsPage`) que integra tabla y formulario, **enrutada en `/wheels`** en reemplazo del `WheelListPage` de Fase 1.
- [ ] Las rutas de ruedas del mock (`mock/wheelsSegmentsRouter.js`): crear, editar y borrar una rueda con sus segmentos, con `422` para unos pesos que no cuadran y `409` para tocar los pesos de una rueda en vivo.
- [ ] 💸 **Pago de deuda:** el listado deja de leer `demoWheels` y pasa a leer del store. La deuda de datos hardcodeados que arrastra desde la Fase 0 queda saldada para el listado (el detalle queda declarado en A12).
- [ ] Manejo explícito del caso "respuesta malformada": el thunk valida la forma antes de confiar en `response.data`.

---

## 🚫 3. Qué queda fuera por ahora

- **Envíos manuales, la ventana de deshacer y las races en el store** → Fase 5. Acá no se le manda nada a ningún jugador.
- **Epics de redux-observable** → Fase 6. Todo el async de esta fase es `createAsyncThunk`, que alcanza y sobra para un CRUD.
- **Transiciones de estado con reglas duras** (el cierre a hora exacta, con su zona) → Fase 7. Acá `status` es un campo más del formulario.
- **La versión nueva de una rueda en vivo** (`wheelVersion`, D33) → el track BE la guarda en una tabla propia (`be02`). Acá la consola solo se niega a editar los pesos de una rueda en vivo.
- **Validación robusta de formulario** → se deja como deuda 💸 (ver §5.8). Por ahora, `required` de HTML y la regla de los pesos.
- **Manejo de 401 en el slice** → no entra nunca. El interceptor de Fase 3 ya cierra la sesión ante cualquier 401. Duplicarlo en el slice sería un antipatrón (ver §4).

---

## 🧠 4. Conceptos mínimos

### CRUD sobre un backend que falla a propósito

Vienes de Fase 3, donde el mock aprendió a portarse mal. Corre en `3001` con `CHAOS_LEVEL` (por defecto `off`): en `low` y `high` inyecta latencia, errores 503, timeouts, respuestas malformadas y 401 sobre rutas protegidas —y `/wheels` es una de ellas—. Esto no es un obstáculo para esta fase: es el escenario de esta fase.

La consecuencia de diseño es concreta y no se negocia: **todo `createAsyncThunk` de ruedas maneja `rejected` desde la primera línea que escribes**. Un slice que solo define el caso `fulfilled` no es "una versión simple que después mejoramos"; es un slice roto. Con el caos en `low` ya vas a ver fallos en desarrollo. Si quieres trabajar una feature sin ruido, deja `CHAOS_LEVEL=off` en la terminal del mock; para estresar la resiliencia, `high`. Lo que no se hace es apagar el caos en el código del proyecto: se apaga en tu entorno, temporalmente.

### Los pesos, en puntos básicos

Una rueda tiene segmentos, y cada segmento un premio y un peso. El peso es la probabilidad de que la rueda caiga ahí, y se guarda en **puntos básicos**: enteros, donde 1 punto básico es 0,01 %. Los pesos de una rueda suman **exactamente 10.000** (`00-historia-del-sistema.md` §9, decisión D33). La Esclusa de Oro, con 50 puntos básicos, sale una vez cada doscientos giros.

¿Por qué enteros y no porcentajes con decimales? Por lo mismo que el dinero va en centavos: un 0,5 % son 50 puntos básicos, y 50 se compara, se suma y se guarda sin redondeo. Con decimales, `0.1 + 0.2` no da `0.3`, y una suma que "casi" da 100 es la puerta por la que entra una rueda que el juego rechaza.

Y una regla más, que es de negocio y no de formato: **una rueda en vivo no cambia sus pesos**. Las probabilidades se publican en el juego antes de cualquier compra (Google Play lo exige); cambiarlas con la rueda girando es cambiar las reglas a mitad del partido. Para cambiarlas se publica una versión nueva de la rueda, y eso es trabajo del backend. La consola deshabilita los pesos de una rueda en vivo, y el mock responde `409` si alguien los manda igual: **la regla se repite en el servidor porque el servidor no confía en lo que valida la consola**.

### Los tres errores que el slice sí maneja, y el que no

No todos los fallos son iguales, y tratarlos igual es un error. El slice de ruedas distingue:

| Fallo | Cómo llega al thunk | Quién lo maneja |
|---|---|---|
| **5xx / 4xx (no 401)** | Rechazo de axios con `error.response.status` | El `rejected` del thunk de ruedas |
| **Timeout** | Rechazo de axios con `error.code === 'ECONNABORTED'` (no hay `response`) | El `rejected` del thunk de ruedas |
| **Malformado** | `200 OK` con un body que no tiene la forma esperada | El propio thunk, validando antes de confiar |
| **401** | Response 401 sobre ruta protegida | **El interceptor global de Fase 3**, no el slice |

El 401 es el caso interesante por lo que **no** haces. `apiClient` ya tiene un interceptor de response (Fase 3) que ante cualquier 401 cierra la sesión y redirige a `/login`. Si una petición de ruedas devuelve 401, la sesión se cae globalmente. Meter manejo de 401 en el slice de ruedas duplica una responsabilidad que ya vive en un solo lugar, y peor: te deja dos verdades sobre qué significa "no autorizado". El `rejected` de tus thunks maneja los otros tres; del 401 se encarga la capa de transporte. Esa separación es la que hace mantenible el sistema.

> 📝 **Nota de época.** La tabla de ruedas es de la agencia de 2019: una clase con `connect()`. Los slices con `createAsyncThunk` son de los de Lima, en 2020-2021, que decidieron no reescribir lo viejo pero escribir lo nuevo con Redux Toolkit (`00-historia-del-sistema.md` §3). Los thunks a mano (`dispatch(pending()); api.get()...`) todavía se ven en código de 2018-2019; A6 muestra ese estilo para cuando lo encuentres.

### El fallo más silencioso: la respuesta malformada

De los cuatro fallos, el malformado es el que más caro sale, porque no explota donde ocurre. Un 503 lo ves: axios rechaza y tu `rejected` corre. Un malformado llega como `200 OK` —axios lo da por bueno— y tu código lo procesa como si fuera válido. Si el thunk guarda `response.data` a ciegas y la tabla hace `wheels.map(...)` sobre algo que vino como texto roto, el `.map` tira `TypeError` en un lugar que no tiene nada que ver con la red. Vas a depurar el componente veinte minutos antes de darte cuenta de que el problema fue la forma de la respuesta.

La defensa es barata: antes de confiar en `response.data`, verificas que tenga la forma que esperas. Si no la tiene, lo tratas como un error explícito con un mensaje claro, no dejas que reviente río abajo. Lo vas a ver en `fetchWheels` en la §5.3.

### Error legible, no error crudo

Un detalle de diseño del estado: guardamos el error como un objeto pequeño y legible (`{ message, type }`), no el objeto de error de axios entero. Dos razones. Primero, el objeto de axios no es serializable del todo y Redux Toolkit se queja si lo metes al store. Segundo, y más importante, la UI necesita distinguir "se cayó el servidor" de "vino mal la respuesta" para mostrar mensajes distintos, y eso se decide una sola vez —en el thunk, que sabe qué pasó— y no en cada componente que lea el error.

La función que arma ese objeto vive en `src/api/readableError.js`, al lado del cliente HTTP, y no dentro del slice: el slice de envíos de la Fase 5 la va a usar igual, y le va a sumar un tipo.

> ⚠️ **Ojo con el caso mixto.** La **key** del objeto va en inglés (`message`, `type`), pero el **valor** de `message` es lo que lee el operador y va en español: `{ message: 'El servidor tardó demasiado. Reintenta.', type: 'timeout' }`. El código en inglés, el texto de interfaz en español.

### Convivencia class/hooks en un mismo módulo

Esta fase es una buena excusa para lo que el curso viene prometiendo: código mezclado. La tabla (`WheelTable`) va como **class component con `connect()`**, al estilo de los módulos viejos del sistema. El formulario (`WheelForm`) va **funcional con hooks** (`useState`, `useDispatch`, `useSelector`). No es capricho: es exactamente lo que vas a encontrar en una base que evolucionó de 2019 a 2023. Aprender a leer los dos sin marearte —y a que convivan en la misma pantalla despachando al mismo store— es la habilidad real. Si quieres el mapa de equivalencias `connect()` ↔ hooks, está en A6; y si lo que te cuesta es leer la clase en sí —`this.setState`, el ciclo de vida—, el traductor completo está en `A5-class-components-vs-hooks.md`. Para las clases de tabla y formulario de Bootstrap, `A1-bootstrap-4-y-sass.md` §4 y §5.

---

## 💻 5. Implementación y código comentado

Trabajamos en `src/features/wheels/`, más una pieza en `src/api/` y otra en el mock. Esta fase no instala nada: todo lo que usa ya está desde la Fase 3.

### 5.1 Las reglas de pesos — `src/features/wheels/weightRules.js`

Empezamos por la regla del dominio, porque la usan el formulario y las pruebas, y no depende de React ni de la red.

<<<archivo:src/features/wheels/weightRules.js>>>

> **Detalles con intención.**
> - `validateWeights` devuelve **todos** los errores, no el primero: el operador ve de una vez que hay un peso con decimales y que la suma no da.
> - Un peso de 0 no se acepta. Un segmento que nunca sale no es un segmento: es un premio que la tabla publicada promete y la rueda no entrega.
> - `canEditWeights(null)` es `true`: una rueda nueva todavía no tiene estado guardado, y se edita libre.

### 5.2 El error legible — `src/api/readableError.js`

<<<archivo:src/api/readableError.js>>>

Los 5xx del caos traen un texto de depuración (`caos: 503 simulado`) que no es para el operador: se reemplaza por un mensaje legible. Los 4xx del mock, en cambio, traen la regla que se rompió, ya en español, y se muestran tal cual.

### 5.3 El slice — `src/features/wheels/wheelSlice.js`

El store es la fuente de verdad; los componentes son consumidores.

<<<archivo:src/features/wheels/wheelSlice.js>>>

> **Detalles con intención.**
> - En `deleteWheel` devolvemos el `id`, no volvemos a pedir la lista. Menos viajes a un backend que falla = menos superficie de error.
> - `editingId` guarda el **id**, no la rueda entera. La rueda vive en `items`; duplicarla en dos lugares es pedir que se desincronicen. El selector `selectEditingWheel` la resuelve al vuelo.
> - `error` se limpia en cada `pending`. Si no, un error viejo sobrevive a una operación nueva que sí funcionó.
> - `fetchWheels` le pide al mock cada rueda con sus segmentos (`_embed=segments`): json-server junta las dos colecciones por `wheelId`.

**El patrón a memorizar:** `pending` prende loading y limpia error → `fulfilled` apaga loading y aplica el cambio a `items` → `rejected` apaga loading y guarda error legible. Los cuatro thunks siguen el mismo molde, a propósito: un helper reduciría el ruido, pero escondería justo el patrón que la fase enseña. Si escribes uno sin `rejected`, no está incompleto: está mal.

Registra el reducer en el store (viene de Fase 3, solo se suma la clave):

<<<fragmento:src/app/store.js|import { configureStore }|wheels: wheelReducer, // ← nuevo en Fase 4
  },
});>>>

### 5.4 La tabla — `src/features/wheels/WheelTable.jsx` (class component)

El listado va como clase con `connect()`, al estilo de 2019. Dispara el `fetchWheels` en `componentDidMount` y renderiza los cuatro estados visuales: cargando, error, vacío y lista.

<<<archivo:src/features/wheels/WheelTable.jsx>>>

> 📝 **Nota de época.** `mapDispatchToProps` como objeto (no como función con `dispatch =>`) es el atajo que react-redux ya recomendaba. Cada acción se envuelve en `dispatch` automáticamente. En código más viejo vas a ver la forma larga `dispatch => ({ fetchWheels: () => dispatch(fetchWheels()) })`; hacen lo mismo.

### 5.5 El formulario — `src/features/wheels/WheelForm.jsx` (hooks)

El formulario es funcional con hooks. Sirve para crear y para editar: si el store tiene una rueda en edición, precarga sus valores; si no, arranca con la tabla de segmentos de la Esclusa de Oro, que ya suma 10.000.

<<<archivo:src/features/wheels/WheelForm.jsx>>>

> **Detalles con intención.**
> - Un solo `WheelForm` sirve para crear y editar. El modo lo decide el store (`editingId`), no una prop ni una ruta. Menos componentes, una sola verdad sobre "qué se está editando".
> - La suma se calcula en cada render, sobre el borrador. No hay un estado `sum` aparte que mantener sincronizado: se deriva.
> - El botón de guardar se deshabilita mientras la suma no cuadre, **y** `handleSubmit` vuelve a mirar los errores. La primera defensa es para el operador; la segunda, para el que despache el submit sin pasar por el botón.
> - El `useEffect` que sincroniza `draft` con `editingWheel` es el puente entre store y estado local: dependencia explícita, sin bucles.

### 5.6 La página — `src/features/wheels/WheelsPage.jsx`

Contenedor mínimo que junta las dos piezas —una en clase, otra en hooks— despachando al mismo store sin saber ni importarles el estilo de la otra.

<<<archivo:src/features/wheels/WheelsPage.jsx>>>

### 5.7 Las rutas de ruedas del mock — `mock/wheelsSegmentsRouter.js`

json-server sabe crear, editar y borrar una colección, pero una rueda son **dos** colecciones (`wheels` y `segments`) y tiene reglas que el CRUD genérico no expresa. Así que crear, editar y borrar una rueda son rutas propias, como el giro de la Fase 3:

<<<archivo:mock/wheelsSegmentsRouter.js>>>

Se importa en `mock/server.js` y se monta antes del router de json-server, para que estas rutas ganen; la lectura (`GET /wheels?_embed=segments`) la sigue haciendo json-server:

<<<fragmento:mock/server.js|const wheelsSegmentsRouter|;>>>

<<<fragmento:mock/server.js|server.use(wheelsSegmentsRouter(db));|server.use(router);>>>

Y en `mock/db.json`, las ruedas 2 y 3 reciben su tabla de segmentos (la misma de la Esclusa de Oro), para que haya algo que editar en una rueda que no está en vivo. La forma del archivo es la de la Fase 3.

### 5.8 Conectar la ruta y jubilar los datos hardcodeados 💸 **Pago de deuda**

Falta el paso que hace visible todo lo anterior, y es el que más gente olvida: **`WheelsPage` no está enrutada.** La ruta `/wheels` sigue apuntando a `WheelListPage`, la clase que la Fase 1 conectó a `demoWheels` —el array hardcodeado en `src/mock/wheels.js`—. Sin este cambio, escribes el CRUD entero y no puedes abrirlo en el navegador.

Este es el momento de pagar la deuda 💸 más vieja del curso: la que declaró la Fase 0 con su rueda escrita a mano, que la Fase 1 amplió a `demoWheels`, y que la Fase 2 dejó explícitamente anotada. Recién ahora se puede pagar: la Fase 3 construyó el backend, pero hasta que no hubo store ni thunks —o sea, hasta esta fase— no había con qué reemplazar el array.

El cambio en el router es de dos líneas, el import y la ruta de `/wheels`:

<<<archivo:src/AppRouter.jsx>>>

`WheelListPage` queda sin nadie que la use. Bórrala (`rm src/pages/WheelListPage.jsx`): el listado ahora es la tabla.

Y a continuación, la parte que hay que hacer con cuidado. `src/mock/wheels.js` exporta dos cosas y **solo una queda huérfana**:

- `demoWheels` — ya no la importa nadie de afuera. Deja de exportarse; sigue en el archivo porque la usa la función de abajo.
- `findWheel(id)` — la sigue usando `WheelDetailPage`, que esta fase **no** toca.

<<<fragmento:src/mock/wheels.js|// 💸 DEUDA PARCIALMENTE PAGADA|WheelDetailPage. Ver A12-mapa-de-deuda-tecnica.md.>>>

**Y acá conviene ser honesto sobre lo que queda.** El detalle no se migra en esta fase. Una rueda que crees en la tabla tiene su link de detalle, y ese detalle dice que la rueda no existe, porque `findWheel` busca en el array de la Fase 1. Esa asimetría no es un descuido: **la deuda queda declarada, no diferida con vaguedad**. El listado lee del store, el detalle lee del array, y esa asimetría está registrada en `A12-mapa-de-deuda-tecnica.md` con su disparador. Es una situación incómodamente realista: casi todo sistema en migración tiene una pantalla que se quedó atrás, y lo que distingue a un equipo que la controla de uno que no es que la primera esté escrita en algún lado.

> ⚠️ **El error que este orden evita.** La tentación es borrar `src/mock/wheels.js` de una vez, porque «ya tenemos backend». Hazlo y `WheelDetailPage` deja de compilar — y el fallo aparece en una pantalla que no tocaste, lo que te va a costar diez minutos entender de dónde salió. **Pagar una deuda es también verificar quién más dependía de ella**, y `grep` es la herramienta: antes de borrar un módulo, búscalo entero por el proyecto.

> 🧠 **Y el reflejo de mantenimiento que hay debajo.** Fíjate en la forma de la decisión, porque la vas a repetir toda tu carrera: encontraste un módulo heredado con dos consumidores, migraste uno, y en vez de forzar el otro —«ya que estoy»— dejaste el archivo con un comentario que dice exactamente qué queda y cuándo se cierra. Migrar de a un consumidor por vez es más lento de leer en el diff y muchísimo más barato de revertir si algo sale mal.

> **Prueba de fuego.** Con el mock levantado y `CHAOS_LEVEL=off`: entra a `/wheels`, crea una rueda, edítala, bórrala. Edita la Semana del Canal y baja un peso en uno: el botón se apaga y aparece "Los pesos suman 9999 y deben sumar 10000.". Abre la Esclusa de Oro: los pesos están deshabilitados. Ahora sube a `CHAOS_LEVEL=high` y recarga varias veces: tienes que ver el `alert-danger` con "Reintentar" cuando cae un 503, "El servidor tardó demasiado" cuando hay timeout, y "forma inesperada" cuando llega un malformado —cada uno con su mensaje, no un genérico—. Si todos los fallos muestran el mismo texto, tu `toReadableError` no está distinguiendo tipos.

### 💸 Deuda técnica declarada en esta fase

Cuatro deudas intencionales, todas anotadas para pagarse después:

1. **Validación de formulario mínima** (`required` de HTML y la regla de los pesos). Lo correcto —validar el formato de la fecha de cierre, que el nombre no sea solo espacios— se aborda cuando el dominio lo exija. En un hotfix, `required` no rompe; solo deja pasar datos flojos.
2. **`window.confirm` para eliminar** en vez de un modal de Bootstrap. Funciona, es feo, se reemplaza en una pasada de UI o como ejercicio 🔥. Se vuelve exigible el día que borrar una rueda deje de ser reversible desde el backend.
3. **El estado se elige libre en el formulario.** Cualquier rueda pasa a cualquier estado; las transiciones con reglas son de la Fase 7 y del track BE.
4. **El detalle de una rueda sigue leyendo `src/mock/wheels.js`** (§5.8), y queda en A12 con su disparador.

---

## ⚠️ 6. Errores comunes y pieza forense

### Errores comunes

**Slice que solo maneja `fulfilled`.** El más común y el más caro. Escribes los cuatro thunks, pruebas con `CHAOS_LEVEL=off`, todo anda, cierras el ticket. En producción (o en UAT con caos) el primer 503 deja el `loadingList` en `true` para siempre —nunca lo apagaste en `rejected`— y la UI queda colgada en "Cargando ruedas…". *Síntoma:* spinner eterno tras un fallo de red. *Causa:* falta la rama `rejected`. *Fix mínimo:* agregar el `addCase(...rejected)` que apaga el loading y guarda el error. No es refactor: es completar el thunk.

**`.map` a ciegas sobre respuesta malformada.** El thunk guarda `response.data` sin validar. Con el mock devolviendo un malformado (200 con un body roto), la tabla hace `wheels.map(...)` sobre un texto y tira `TypeError: wheels.map is not a function`. *Síntoma:* excepción en un lugar que no huele a red; el stack apunta al componente, no a axios. *Causa:* confiaste en la forma sin verificarla. *Fix mínimo:* la guarda `isValidWheelList` antes de usar los datos, y `rejectWithValue` si no pasa.

**Manejar el 401 en el slice.** Alguien "por las dudas" agrega en el `rejected` una rama que detecta 401 y redirige a login. Ahora hay dos lugares que manejan 401: el interceptor global y el slice. *Síntoma:* doble redirect, o un redirect que pelea con el del interceptor. *Causa:* duplicar una responsabilidad que ya vive en la capa de transporte. *Fix:* borrar esa rama del slice. El 401 no es asunto del slice de ruedas (el incidente 08, de la Fase 3, lo cuenta desde el otro lado).

**Perder el `e.preventDefault()` en el submit.** Sin él, el navegador recarga la página al enviar el form, se pierde el estado de Redux y parece que "no pasó nada" o que "se reinició la app". *Síntoma:* flash de recarga al guardar una rueda, y los datos del formulario en la barra de direcciones. *Causa:* form HTML nativo haciendo su trabajo por defecto. *Fix:* `e.preventDefault()` en `handleSubmit`.

### Pieza forense de esta fase — Redux DevTools: time-travel y replay

Esta es la fase donde Redux DevTools se vuelve tu mejor herramienta. Con el store ya poblado de acciones reales, aprende a leerlas.

Abre la extensión Redux DevTools con la app corriendo y haz una operación —crea una rueda—. Vas a ver la secuencia de acciones despachadas: `wheels/create/pending` → `wheels/create/fulfilled`. Selecciona cada una y mira el panel **Diff**: te muestra exactamente qué cambió en el state con esa acción. En `pending` vas a ver `loadingMutation: false → true`; en `fulfilled`, la rueda nueva empujada a `items` y el loading de vuelta en `false`.

Ahora con la regla de la rueda en vivo. Si mandas los pesos de la Esclusa de Oro por fuera de la consola (con `curl`, o quitándole el `disabled` al input en las herramientas del navegador), el `wheels/update/rejected` trae en su `payload` el mensaje del `409`, y el Diff muestra el `error` pasando de `null` a ese objeto. La regla del servidor se ve en el store sin que la consola la haya escrito.

Y con `CHAOS_LEVEL=high`. Recarga hasta que un `fetchWheels` falle. Vas a ver `wheels/fetch/pending` → `wheels/fetch/rejected`. Selecciona el `rejected` y mira el Diff: el `error` pasó de `null` al objeto legible que armó tu thunk, y `loadingList` volvió a `false`. **Ahí está la prueba visual de que tu rama `rejected` funciona.** Si el `loadingList` quedó en `true` después del rejected, encontraste el bug del spinner eterno sin siquiera tocar la UI.

El **time-travel**: haz clic en una acción vieja de la lista. La app entera vuelve a ese estado —la tabla se vuelve a pintar con los datos de ese momento—. Es tu máquina del tiempo para entender "¿en qué momento se rompió el estado?". Y el **replay**: puedes volver a despachar una secuencia de acciones para reproducir un camino exacto. En la Fase 5, cuando aparezca la race de los envíos en el store, esto va a ser la diferencia entre "no puedo reproducirlo" y "lo tengo".

> 💡 **Truco.** Con el caos en `high`, deja Redux DevTools abierto y anda haciendo operaciones. Cada `rejected` que veas es un fallo que tu slice manejó bien. Es la forma más rápida de ganar confianza en que la resiliencia funciona: no la deduces, la ves.

**Rompe a propósito y observa:** comenta el `addCase(fetchWheels.rejected, ...)` en el slice, pon `CHAOS_LEVEL=high`, y fuerza un fallo de carga. Mira en DevTools cómo `loadingList` queda en `true` y no baja nunca. Después descomenta y comprueba que vuelve a bajar. Esa es la firma visual del bug más común de la fase.

> 📓 De esta fase salen los incidentes **09** y **10** de `cuaderno-incidentes.md`. El 10 es el que acabas de provocar; el 09 es más chico y más desconcertante, porque su síntoma no se parece en nada a su causa.

---

## 🧪 7. Ejercicios (28)

**🟢 Fácil (1–8)**

1. Levanta el mock con `CHAOS_LEVEL=off`, entra a `/wheels` y crea tres ruedas distintas. Confirma que aparecen en la tabla.
2. Edita una rueda que no esté en vivo: cambia su nombre, su estado y dos pesos que se compensen. Verifica que la tabla refleja el cambio sin recargar.
3. Elimina una rueda y confirma que desaparece de la tabla y del store (míralo en Redux DevTools).
4. En Redux DevTools, despacha una creación y describe en una frase qué muestra el panel Diff en el `pending` contra el `fulfilled`.
5. Agrega a `WheelTable` una columna "Zona" que muestre `wheel.timezone`.
6. Muestra en el formulario, al lado de cada peso, su porcentaje (`weightBp / 100` con dos decimales). ¿Por qué ese número es solo para mostrar y no se guarda?
7. Identifica en el código cuál de los dos componentes (tabla o formulario) es clase y cuál es funcional, y qué API de Redux usa cada uno (`connect()` contra hooks).
8. Pon `CHAOS_LEVEL=low` y recarga `/wheels` varias veces hasta ver el `alert-danger`. Anota qué mensaje mostró.

**🟡 Intermedio (9–17)**

9. Agrega un selector `selectWheelCount` que devuelva `state.wheels.items.length` y muéstralo en un badge junto al título "Ruedas".
10. Haz que el botón "Crear rueda" quede deshabilitado también cuando `name` esté vacío (además del `required`), usando el estado del componente.
11. Agrega un thunk `fetchWheelById` que traiga una sola rueda con sus segmentos (`GET /wheels/:id?_embed=segments`) con su rama `rejected`. No lo conectes a UI todavía; solo el slice.
12. En `toReadableError`, agrega un tipo `'network'` para el caso en que no hay `response` ni `ECONNABORTED` (error de red puro) y dale un mensaje propio.
13. Haz que al eliminar una rueda que estaba en edición, el formulario vuelva solo a modo "Nueva rueda" (pista: `editingId` apunta a un id que ya no existe).
14. Agrega un botón "Ajustar el último segmento" que cambie el peso del último segmento para que la suma dé 10.000. ¿Qué tiene que pasar si el resultado da 0 o menos?
15. Muestra el `type` del error además del mensaje, en letra chica, dentro del `alert-danger`. Verifica que distintos fallos muestran distinto `type`.
16. Escribe un JSDoc completo para `createWheel` documentando la forma del parámetro `wheel`, segmentos incluidos.
17. Con `CHAOS_LEVEL=high`, reproduce un timeout y confirma en DevTools que el `error.type` guardado es `'timeout'` y no `'http'`.

**🟠 Difícil (18–24)**

18. Reproduce el bug del spinner eterno: comenta la rama `rejected` de `fetchWheels`, fuerza un fallo con caos, y documenta el síntoma exacto que ves en la UI y en DevTools. Después arréglalo.
19. Reproduce el malformado a mano: en `mock/server.js`, monta antes del router una ruta `GET /wheels` que devuelva `200` con `{ "error": "oops" }`. Confirma que la guarda `isValidWheelList` lo atrapa y muestra "forma inesperada" en vez de explotar. Quita la guarda y observa el `TypeError`.
20. Manda con `curl` un `PUT /wheels/1` que cambie los pesos de la Esclusa de Oro y explica, con la respuesta en la mano, por qué el `409` está en el servidor aunque la consola ya deshabilite los inputs.
21. Diagnóstico: te pasan un slice donde `createWheel.fulfilled` hace `state.items = action.payload` en vez de `state.items.push(action.payload)`. Sin correrlo, explica qué bug produce y cómo se manifiesta en la tabla.
22. Con el caos en `high`, espera un 401 sobre `/wheels` (el caos simula un token vencido). Confirma por comportamiento que la sesión se cae y te manda a login **sin que el slice de ruedas maneje el 401**. Explica qué capa lo hizo.
23. Agrega un contador de reintentos: cada vez que el operador toca "Reintentar" tras un error de carga, incrementa un contador y muéstralo. ¿Va en el slice o en el componente? Justifica.
24. Time-travel: crea tres ruedas, edita una, elimina otra. En Redux DevTools, viaja a la acción anterior a la eliminación y describe qué muestra la tabla. Explica por qué el time-travel puede "resucitar" visualmente una rueda borrada.

**🔴 Muy difícil (25–28)**

25. Diagnóstico esquivo: un compañero reporta que "a veces al crear una rueda aparece duplicada en la tabla". Con `CHAOS_LEVEL=high`, reprodúcelo (pista: doble submit rápido mientras `loadingMutation` no bloquea el botón). Propón el fix mínimo y explica por qué el `disabled={loadingMutation}` no siempre alcanza.
26. Integra tabla y formulario para que, al editar una rueda y guardar mientras el caos dispara un `rejected` en el `updateWheel`, el formulario **no** pierda los pesos que el operador había cargado. Diseña el manejo de estado que lo garantiza.
27. Escribe una prueba de regresión (Jest 26 + RTL 11) que falle si alguien vuelve a quitar la rama `rejected` de `fetchWheels`. ¿Qué assert la hace fallar exactamente?
28. Refactor contra hotfix: te dan 30 minutos para arreglar el spinner eterno en producción. Escribe el hotfix mínimo (una línea o dos) y, aparte, describe el refactor "correcto" que harías con más tiempo y pruebas. Marca cuál va en el hotfix y cuál queda como 💸.

**🔥 Opcionales**

- 🔥 Reescribe `WheelTable` de class component a funcional con hooks (`useEffect` + `useSelector` + `useDispatch`). Compara línea a línea con la versión de clase y anota las equivalencias (ver A6). La Fase 11 lo hace en serio.
- 🔥 Reemplaza el `window.confirm` de eliminación por un modal de Bootstrap 4 controlado por estado.
- 🔥 Migra el slice a `createEntityAdapter` (RTK 1.8) para normalizar `items` por id. ¿Qué selectores te regala gratis y qué cambia en los `extraReducers`?

---

## 📚 8. Referencias

**Documentación oficial**

- https://redux-toolkit.js.org/api/createAsyncThunk — patrón `pending/fulfilled/rejected` y `rejectWithValue`. Fíjate en la versión: el proyecto usa RTK **1.8.x**; la doc actual puede mostrar APIs más nuevas.
- https://redux-toolkit.js.org/api/createSlice — `reducers` contra `extraReducers` con el callback `builder`.
- https://react-redux.js.org/api/connect — `connect()`, `mapStateToProps`, `mapDispatchToProps` como objeto. Es la API que usa la tabla.
- https://react-redux.js.org/api/hooks — `useSelector` y `useDispatch`, la API que usa el formulario.
- https://legacy.reactjs.org/docs/react-component.html — `componentDidMount` y el ciclo de vida de clases (React 16). Es el equivalente al `useEffect([])` del formulario.
- https://github.com/typicode/json-server/tree/v0.16.3 — `_embed` y las relaciones por `<recurso>Id`, en la versión fijada.
- https://getbootstrap.com/docs/4.6/content/tables/ y https://getbootstrap.com/docs/4.6/components/forms/ — clases de tabla y formulario usadas acá.

**Video / apoyo**

- Redux Toolkit — "Async Logic and Data Fetching" del tutorial oficial de Redux (busca "Redux Essentials Part 5" en redux.js.org). Cubre `createAsyncThunk` con el mismo patrón de esta fase.

**Orden de lectura sugerido:** `createAsyncThunk` (para entender las tres ramas) → `createSlice` con `extraReducers` (para ver dónde se enganchan) → `connect()` y hooks de react-redux (para comparar los dos componentes) → volver al `wheelSlice.js` de la §5.3.

> ⚠️ Las URLs, títulos y números de sección pueden haber cambiado o apuntar a versiones más nuevas que las fijadas. Verifica siempre que lo que lees aplique a RTK 1.8, react-redux 7.2 y React 16.14. Cuando la doc oficial muestre una API que no existe en estas versiones, es señal de que estás leyendo material más nuevo.

---

## 🚀 9. Cierre y conexión con la Fase 5

Ya tienes el primer CRUD real del sistema: un slice de Redux Toolkit que crea, lista, edita y borra ruedas contra un backend que falla a propósito, con cada operación manejando sus modos de fallo desde el día uno y sin duplicar el manejo de 401 que ya vive en la capa de transporte. Los pesos se validan en puntos básicos en la consola y otra vez en el servidor, y una rueda en vivo no deja que nadie los toque. La tabla en clase y el formulario en hooks conviven despachando al mismo store —tu primera prueba de que el código mezclado no muerde si sabes leerlo—. Y Redux DevTools dejó de ser un adorno para volverse tu instrumento de diagnóstico.

La Fase 5 sube la apuesta con lo que hace difícil de verdad a este dominio: los **envíos manuales**. Soporte compensa a un jugador, o a una lista de afectados por una caída, con una ventana de diez segundos para deshacer, y el envío se marca como hecho antes de que el servidor conteste. Ahí aparecen las races que el CRUD tranquilo de esta fase todavía no tenía, y el time-travel de Redux DevTools que aprendiste acá se vuelve la herramienta para cazarlas. El store que armaste es la base sobre la que se apoya todo eso.

> **La señal de que quedó bien:** si subo el caos a `high`, recargo diez veces, y cada fallo distinto me muestra su propio mensaje mientras el store nunca queda colgado en "cargando" —y si una rueda que no suma 10.000 no se puede guardar ni por la consola ni por fuera de ella—, entonces el CRUD no es de juguete: aguanta el mundo real.

> 🏷️ **No cierres la fase sin el tag.** Con el checklist de la sección 2 en
> verde y `git status` limpio:
>
> ```bash
> git tag -a fase-04-ruedas-crud -m "F4 cerrada: <el checklist, en una línea por ítem>"
> ```
>
> Los commits de la fase llevan su prefijo (`f04: …`) y los de ejercicio su
> número (`f04 ej17: …`). Si un ejercicio merece su propio marcador va en
> `ej/f04/17`, y un incidente resuelto en el par `inc/<ID>/<slug>-roto` /
> `-fix`, con el ID que le reserva `cuaderno-incidentes.md`. Todo eso está en
> [`00-convencion-de-git-y-tags.md`](00-convencion-de-git-y-tags.md).

---

## 📌 Pendientes sugeridos

> Material de autoría, no de lectura. Va acá abajo, fuera de la plantilla de nueve
> secciones, porque es lo que apareció al escribir la fase y no cabía adentro — y
> porque no debe competir con el cierre.

- **La versión nueva de una rueda en vivo** (D33) no tiene pantalla en el track base. → Decidir en la Fase 11 si el horizonte de dos años la necesita en la consola o solo en el API.
- **El detalle de una rueda** sigue en `src/mock/wheels.js`. → Su entrada en A12 lleva el disparador: el día que un operador necesite ver en el detalle una rueda creada desde la consola.
- **"Manejar el 401 en el slice" es el mejor ejemplo de responsabilidad duplicada** del curso, pero se solapa con el incidente 08 de la Fase 3. → Se queda acá como error común con referencia cruzada, sin desarrollar el diagnóstico dos veces.

### Reservas para el cuaderno de incidentes

Los IDs quedan reservados en `cuaderno-incidentes.md`, donde el enunciado ya está redactado con sus pistas y su solución de referencia. El ID nunca se reasigna.

- **09** — *Guardo la rueda, la pantalla se recarga y pierdo lo que escribí* · Estado (store) · 🟢. Sale del `e.preventDefault()` olvidado en el submit. Fácil de arreglar, muy formativo: el síntoma ("se borró todo") no se parece en nada a la causa.
- **10** — *La lista de ruedas se queda cargando para siempre* · Estado (store) · 🟡. Sale del error común #1: el slice que solo maneja `fulfilled`. Con `CHAOS_LEVEL=off` no se reproduce nunca, y esa es la mitad de la lección.
