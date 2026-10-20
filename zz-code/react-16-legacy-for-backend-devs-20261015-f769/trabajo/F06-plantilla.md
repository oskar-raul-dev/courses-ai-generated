# 🌀 Fase 06 — redux-observable a fondo

> Tutorial React 16 — La Esclusa, la consola de Jewel Locks · Fase 6 de 11 · **12 horas** ⭐
> Depende de: Fase 5 — Envíos manuales · Habilita: Fase 7 — Cierre a hora exacta y polling de compras

---

## 🎯 1. Propósito

Yariela lleva dos semanas con la consola de la Fase 5 y su lista de quejas es corta y precisa: el doble clic en «Enviar ahora» que la consola frena "a veces", y el buscador de jugadores que, si escribe rápido, le muestra a otra persona. Su resumen, en el canal del equipo: *"la consola hace lo que le pido, pero no siempre en el orden en que se lo pido"*.

La Fase 5 te dejó mandando premios de verdad, con una ventana de deshacer que se cierra sola y con la capacidad de leer una race en el store *después* de que ocurrió. Pero lo hizo con muletas a propósito: un `Map` de `setTimeout` a nivel de módulo que hay que cancelar a mano en tres lugares, y una guarda en el `condition` del thunk que frena el segundo clic río abajo. Esas muletas eran deuda técnica marcada con 💸 esperando a esta fase.

La Fase 6 las jubila. Acá aprendes a escribir epics de `redux-observable` que se cancelan solos: la ventana de deshacer es un stream que se apaga cuando el envío sale, se deshace o se cierra la sesión; el segundo clic sobre un envío en vuelo ni siquiera existe para el epic; y la búsqueda de jugadores descarta la respuesta vieja cada vez que el operador cambia una letra. Esto importa para mantenimiento porque **redux-observable es la fuente de bugs más difícil de este stack**: un `takeUntil` olvidado no rompe nada visible hoy, pero deja una suscripción viva que dispara peticiones fantasma después de que el operador cerró sesión. Vas a aprender a escribir esos epics bien y —más importante— a cazarlos cuando alguien los escribió mal.

---

## ✅ 2. Qué queda listo al terminar

- [ ] El `epicMiddleware` de redux-observable y el `rootEpic` (`combineEpics`) están montados sobre el `configureStore` existente, con el cliente HTTP inyectado como dependencia, sin tocar los reducers de `auth` ni de `wheels`.
- [ ] Los `setTimeout` de la ventana de deshacer de la Fase 5 quedan **jubilados 🪦** y reemplazados por `undoWindowEpic` (`timer` + `takeUntil`), que se corta solo al enviar, al deshacer o al cerrar sesión.
- [ ] `sendGrantEpic` manda cada envío con `groupBy` + `exhaustMap`: el doble clic sobre un envío en vuelo da **una** petición, sin frenar a los demás envíos.
- [ ] `searchPlayerEpic` busca jugadores con `debounceTime` + `switchMap`: una búsqueda nueva descarta la respuesta de la anterior.
- [ ] `retryGrantEpic` manda «Enviar todos ahora» y reintenta los errores transitorios (`timeout`, 5xx) con backoff; **nunca** un `conflict`.
- [ ] `cancelOnLogoutEpic` deshace lo que seguía en cola al cerrar sesión, y el estudiante puede reproducir un **memory leak por suscripción sin cancelar** —el refresco de compras pendientes, escrito con el leak a propósito— y contarlo en el log del mock.

---

## 🚫 3. Qué queda fuera por ahora

- **El polling real de compras pendientes** (`pollingEpic` contra el mock de Google Play, puerto `3002`) → Fase 7. Acá se sientan las bases (`interval`/`timer`, `takeUntil`), y el refresco de compras queda roto a propósito para cazarlo.
- **El cierre de la rueda a hora exacta** → Fase 7. Los epics de esta fase no miran el reloj.
- **Las pruebas de canicas** → `A11-marble-testing.md` para la metodología, Fase 10 para aplicarla. Acá los diagramas de canicas son un modelo mental para *leer* un epic; los tests automatizados se escriben después. Que los epics reciban el cliente HTTP por dependencias es lo que va a hacer posibles esos tests.
- **El dinero** → Fase 8. Ningún epic de esta fase calcula nada.
- **`redux-saga` como alternativa** → ejercicio 🔥. El curso usa redux-observable; saga aparece solo como comparación.

---

## 🧠 4. Conceptos mínimos

### Qué es un epic y por qué no es "un thunk más grande"

Un thunk es una función que corre una vez, hace su trabajo asíncrono y termina. Un epic es distinto: es una **función que recibe un stream de todas las acciones** que pasan por el store (`action$`) y devuelve **otro stream de acciones** que se van a despachar. No corre una vez: está siempre escuchando. La firma es `(action$, state$, dependencias) => action$` y esa simetría —acciones entran, acciones salen— es toda la idea.

La ganancia sobre el thunk aparece cuando el problema es *temporal* y no solo *asíncrono*: "espera diez segundos pero cancela si el operador deshace", "ignora los clics mientras el envío está en vuelo", "busca cuando el operador deje de escribir y olvida la búsqueda anterior", "reintenta con backoff pero solo si el error es transitorio", "corta todo cuando el operador cierra sesión". Todo eso en un thunk se resuelve con `setTimeout`, flags y guardas cosidas a mano —la Fase 5 lo hizo así—; en un epic es un operador de RxJS que ya viene resuelto y —esto es lo que de verdad importa— **se cancela solo cuando la suscripción se cierra**.

### `.pipe()` y el puñado de operadores que vas a usar todo el curso

`.pipe()` encadena operadores. No hay magia: cada operador toma un Observable y devuelve otro transformado. Los que importan para mantener esta app:

- **`map`** — transforma cada valor. `map(() => grantConfirmed(grantId))`. Uno entra, uno sale.
- **`mergeMap`** — por cada acción entrante arranca un Observable interno y **deja correr todos en paralelo**. Sirve cuando las operaciones son independientes (la ventana del envío de Juan no debe cancelar la del envío de María).
- **`switchMap`** — por cada acción entrante arranca un Observable interno pero **abandona el anterior si todavía no terminó**. Es la herramienta de "solo me importa el último": la búsqueda mientras se escribe.
- **`exhaustMap`** — lo contrario de `switchMap`: mientras el Observable interno está en curso, **ignora** las acciones nuevas. Es la herramienta del doble clic: el segundo clic llega con el primero en vuelo, y no existe.
- **`groupBy`** — parte el stream en un stream por clave. Con `groupBy` por envío, el `exhaustMap` de cada grupo ignora los clics de *ese* envío sin frenar a los demás.
- **`debounceTime(ms)`** — espera a que dejen de llegar valores por `ms` antes de dejar pasar el último. Clásico de búsqueda en formularios.
- **`retryWhen`** — reintenta la fuente si emite error, y te deja meter backoff y decidir *qué* errores reintentar.
- **`catchError`** — atrapa el error del stream y lo reemplaza por otro Observable (típicamente `of(rollbackGrant(...))`). **Sin `catchError`, un error mata el epic entero y deja de escuchar para siempre** — este es el error #1 de la sección 6.
- **`takeUntil(notifier$)`** — deja pasar valores hasta que `notifier$` emite; ahí completa y **cancela la suscripción interna**. Es el operador de cancelación de todo el curso: cortar al deshacer, al enviar, al cerrar sesión.

### `ofType`: pattern matching sobre el stream de acciones

`action$` recibe *todas* las acciones. `ofType(...)` es el filtro que deja pasar solo las que te interesan, comparando por `action.type`. Los action creators de Redux Toolkit exponen su tipo (`grantQueued.type` vale `'grants/grantQueued'`), y además un `match` (`undoGrant.match(action)`), que es la forma segura de comparar en un `filter`. `ofType(grantQueued.type)` significa "cada vez que se encola un envío, haz algo" — que es exactamente donde arranca la ventana de deshacer.

### Por qué un stream se cancela solo y un `setTimeout` no

Un `setTimeout` es fuego y olvido: una vez agendado, corre pase lo que pase, y para evitar que dispare tienes que guardar su `id` y llamar `clearTimeout` a mano, en cada camino posible de salida. La Fase 5 hizo justo eso, con un `Map` de ids y `closeUndoWindow` en tres puntos (deshacer, enviar ahora, y el envío que llega por la ventana). Un Observable, en cambio, tiene *teardown*: cuando la suscripción se cierra —porque `takeUntil` emitió, o porque el epic se desuscribió— todos sus recursos internos (incluido el `timer`) se limpian solos. No hay `id` que guardar ni `clear` que llamar. Esa es, en una frase, la razón de existir de esta fase.

> ⚠️ **Cancelar no es abortar.** Cuando `switchMap` abandona una búsqueda, deja de escuchar su respuesta; la petición HTTP, si ya salió, llega igual al servidor —un `from(promesa)` no sabe abortar—. Para la búsqueda alcanza: lo que importa es que la respuesta vieja no pinte. Para un envío, no alcanzaría: por eso el doble clic se resuelve con `exhaustMap`, que no deja ni salir al segundo.

### Los epics reciben sus dependencias

Los epics de esta fase no importan `apiClient`: lo reciben como tercer argumento (`{ api }`), desde `createEpicMiddleware({ dependencies })`. Es la forma idiomática de redux-observable, y tiene un motivo de mantenimiento: un epic que importa su cliente HTTP solo se prueba levantando un servidor; uno que lo recibe se prueba pasándole uno falso que responde cuando el test quiere. La Fase 10 y A11 viven de eso.

### Convivencia de estilos en esta fase

Los epics son módulos aparte, no viven en componentes; no hay clase ni hook que forzar acá. El punto de convivencia relevante es otro: los epics **conviven con los thunks de la Fase 4, no los reemplazan**. El thunk sigue siendo la herramienta correcta para un pedido asíncrono simple de una sola pasada (traer las ruedas, crear una). El epic entra solo cuando hay una dimensión temporal o de cancelación que el thunk no puede expresar limpio: `fetchWheels` sigue siendo un thunk; el envío de un premio, con su ventana, su doble clic y su reintento, pasa a epics.

---

## 💻 5. Implementación y código comentado

### 5.1 Montar redux-observable sobre el store existente

Instala las dos dependencias de la fase, con versión exacta (`00-decisiones-y-versiones.md`, D2):

```bash
npm install --save-exact redux-observable@1.2.0 rxjs@6.6.7
```

El store suma el middleware de epics **sin tocar los reducers** de `auth` ni de `wheels`. Lo nuevo es el `epicMiddleware`, con sus dependencias, y el `rootEpic`:

<<<archivo:src/app/store.js>>>

<<<archivo:src/app/rootEpic.js>>>

> 💸 **Deuda intencional.** Importar cada epic a mano en `rootEpic.js` no escala si el proyecto creciera a decenas de epics; lo correcto sería un registro automático. No lo resolvemos acá porque con seis epics el costo es cero y el explícito se lee mejor para aprender. Si la Fase 7 suma uno, es una línea más.

### 5.2 Los cambios en `grantSlice`: lo que se jubila 🪦 y lo que se suma

El slice de la Fase 5 conserva su máquina de estados entera: `ALLOWED_TRANSITIONS`, `transition`, el optimista (`grantSent`) y el rollback por id. Lo que se va es todo lo que coordinaba tiempo y red: el `Map` de temporizadores, `openUndoWindow`, `closeUndoWindow`, `expireUndoWindow` y los thunks `queueGrant`, `undoGrant`, `sendGrant` y `sendAllQueued`. Lo que coordinaban ahora lo hacen los epics, y el slice queda con acciones planas:

<<<archivo:src/features/grants/grantSlice.js>>>

> **Detalles con intención.**
> - `sendGrantRequested` y `sendAllRequested` son **intenciones**: acciones sin reducer, que solo escuchan los epics. El componente pide; el epic decide si y cuándo.
> - `grantQueued` arma el id en su `prepare`: el reducer sigue puro, y la acción que ve DevTools ya trae el envío completo.
> - `canSend` es la guarda de origen de la Fase 5, sacada a una función: el epic la consulta antes de crear la petición.
> - `grantsReset` usa el tipo de error `'cancelled'`: lo que seguía en cola al cerrar sesión no sale, y la fila dice por qué.

### 5.3 `undoWindowEpic`: jubilando 🪦 los `setTimeout`

El reemplazo directo de la deuda estrella de la Fase 5. Cuando se encola un envío, el epic espera diez segundos y pide el envío; lo que en la Fase 5 eran tres llamadas a `closeUndoWindow`, acá es un `takeUntil`.

<<<archivo:src/features/grants/epics/undoWindowEpic.js>>>

Nota lo que *no* está: ni `Map` de ids, ni `clearTimeout`, ni la trampa del temporizador huérfano al encolar dos veces. Y una que la Fase 5 tenía abierta se cierra sola: el logout corta la ventana, así que un envío en cola **no sale** después de que el operador se fue.

### 5.4 `sendGrantEpic`: el doble clic resuelto en el origen

El incidente 11 de la Fase 5 se resolvió con una guarda en el `condition` del thunk: el segundo clic llegaba hasta el thunk y la guarda lo frenaba. Acá el segundo clic **no llega a ningún lado**.

<<<archivo:src/features/grants/epics/sendGrantEpic.js>>>

`groupBy` arma un stream por envío, y `exhaustMap`, dentro de cada uno, ignora los pedidos de ese envío mientras el anterior está en vuelo. ¿Por qué no `switchMap`? Porque `switchMap` abandonaría el **primer** envío —que ya salió hacia el servidor— y se quedaría con el segundo: dos peticiones, y la respuesta de la primera, perdida. Y ¿por qué no `exhaustMap` sin `groupBy`? Porque ignoraría los envíos de **otros** jugadores mientras uno está en vuelo, y «Enviar ahora» sobre Juan frenaría a María. El `catchError` va **adentro** del stream de cada envío: un envío fallido se vuelve un `rollbackGrant`, y el epic sigue escuchando.

### 5.5 `searchPlayerEpic`: buscar con `debounceTime` + `switchMap`

El asistente de la Fase 5 traía a todos los jugadores de una vez. Con miles, hace falta buscar: el operador escribe y la consola le muestra a quién encontró, sin una petición por tecla y sin que una respuesta vieja pise a la nueva.

<<<archivo:src/features/grants/epics/searchPlayerEpic.js>>>

Para que el asistente la use, despacha `playerSearchRequested` en cada tecla y lee los resultados del store. Los jugadores suspendidos aparecen, pero no se pueden marcar: no se le compensa a un jugador suspendido.

<<<archivo:src/features/grants/GrantWizard.jsx>>>

Este epic **no** maneja 401: si la búsqueda devuelve 401, el interceptor global de `apiClient` (Fase 3) cierra la sesión. El `catchError` de acá se ocupa de `http`, `timeout` y `malformed`; del 401 se encarga el transporte, como siempre.

### 5.6 `retryGrantEpic`: el envío masivo, con reintento

«Enviar todos ahora» manda lo que sigue en cola, de a cuatro a la vez, y reintenta. Reintentar tiene una trampa: **nunca reintentes un `conflict`**. Si el caso ya está compensado, reintentar diez veces devuelve diez `409`. Solo tienen sentido los errores transitorios (`timeout` y 5xx).

<<<archivo:src/features/grants/epics/retryGrantEpic.js>>>

Fíjate en `defer`. Un `from(api.post(...))` crea la promesa **una vez**: cuando `retryWhen` vuelve a suscribirse, encuentra la misma promesa ya rechazada y "reintenta" sin mandar nada. `defer` crea la petición de nuevo en cada suscripción. Es un error que no se ve en el código y sí en Network: tres "reintentos" y una sola petición.

> 💸 **Deuda intencional.** `retryGrantEpic` y `sendGrantEpic` comparten casi todo el cuerpo (el optimista, la petición, el rollback). Lo correcto sería extraer un helper `grantRequest$(grant)` reutilizable. No lo hacemos acá para que veas los dos flujos completos lado a lado; el ejercicio 27 te pide justamente esa extracción sin cambiar el comportamiento.

### 5.7 `cancelOnLogoutEpic`: lo que estaba en cola, no sale

Al cerrar sesión, la ventana de cada envío ya se corta sola (5.3). Falta que la lista lo diga: lo que seguía en cola pasa a "Deshecho", con su motivo.

<<<archivo:src/app/cancelOnLogoutEpic.js>>>

> ⚠️ **El bug que este import evita, y que te va a morder al menos una vez.**
> Un epic escrito como `ofType('LOGOUT')` **compila, arranca y no falla nunca**.
> Simplemente no reacciona: el `authSlice` de la Fase 2 se llama `auth` y su
> reducer `logout`, así que Redux Toolkit genera el type `'auth/logout'` — no `'LOGOUT'`.
> El `ofType` filtra por igualdad de strings, no encuentra nada, y el epic
> queda escuchando un evento que no existe.
>
> Lo peligroso es cómo se manifiesta: si ese `ofType` estaba dentro de un
> `takeUntil`, el `takeUntil` **nunca emite**, y por lo tanto **nunca cancela**.
> Tienes una suscripción viva para siempre, sin un solo error en consola. Es
> exactamente el memory leak que esta fase enseña a cazar, generado por una
> comilla mal puesta.
>
> Por eso la regla del proyecto: **el type siempre sale del action creator**
> (`logout.type`, `logout.match(action)`), nunca de un string escrito a mano.
> Un `import` roto se ve al instante; un string mal escrito, jamás.
> Los `SCREAMING_SNAKE_CASE` del diccionario aplican a los action types
> **clásicos** que el sistema define a mano (`START_PURCHASES_REFRESH`), no a
> los que Redux Toolkit genera solo.

La lista de envíos despacha las intenciones nuevas en vez de los thunks de la Fase 5:

<<<fragmento:src/features/grants/GrantList.jsx|import { selectGrants|from "./grantSlice";>>>

### 5.8 El memory leak que vas a provocar a propósito

Un epic mal escrito no falla ruidosamente: sigue vivo, emitiendo peticiones fantasma. El caso de esta casa es el de la historia: en 2022, Renzo hizo que la consola preguntara cada pocos segundos por las compras pendientes, y *"funcionaba… hasta que alguien cerraba sesión y el navegador seguía preguntando. Para siempre"* (`00-historia-del-sistema.md` §3, era 3). Lo introducimos acá roto, para cazarlo en la sección 6 y pagarlo en la Fase 7.

<<<archivo:src/features/purchases/epics/purchasesRefreshEpic.js>>>

Para contar el leak hace falta un testigo del lado del servidor. Después del logout, el interceptor ya no encuentra token y la petición sale **sin** `Authorization`; el mock suma un contador de esas peticiones y las anota en su log:

<<<archivo:mock/sessionlessCounter.js>>>

<<<fragmento:mock/server.js|server.use(requestIdMiddleware);|// F06: las peticiones que llegan sin sesión, contadas>>>

Y en `mock/db.json`, los jugadores ganan su `status` y llegan dos más, Ana (`banned`) y Anaís (`active`): el buscador los necesita, y el incidente 15 también.

---

## ⚠️ 6. Errores comunes y pieza forense

### Errores comunes

**1. Olvidar `catchError` y matar el epic entero.** Síntoma: el primer envío que falla deja de mandar *todos* los envíos futuros, sin error visible; y como `combineEpics` une los epics, la búsqueda deja de responder también. Causa: un error no atrapado se propaga hasta el epic raíz y completa el Observable: los epics dejan de escuchar `action$` para siempre. Fix mínimo: `catchError` **dentro** del Observable interno (el de cada envío), no afuera. Si lo pones afuera, atrapas el error pero igual pierdes el stream externo.

**2. `mergeMap` donde iba `switchMap` (y viceversa).** Síntoma con `mergeMap` en la búsqueda: respuestas viejas pisan a las nuevas (buscas `Anaís`, ves a `Ana`). Síntoma con `switchMap` en la ventana de deshacer: encolar un segundo envío cancela la ventana del primero, que ya nunca sale. Fix: `switchMap` cuando solo importa el último; `mergeMap` cuando cada operación es independiente; `exhaustMap` cuando el primero manda. No es cosmético — es corrección contra bug.

**3. `takeUntil` mal ubicado en el `.pipe()`.** Síntoma: la cancelación no ocurre o cancela de más. Causa: `takeUntil` corta *todo lo que está antes* de él en el pipe. Si lo pones antes del `map` de éxito, cancelas también la emisión buena. Regla práctica: `takeUntil` casi siempre va **último** en el pipe interno. Corrección mínima contra refactor: mover una línea es el fix mínimo; rediseñar qué stream es el notifier es refactor.

**4. Correr `epicMiddleware.run(rootEpic)` antes de crear el store.** Síntoma: el arranque explota con un error dentro de redux-observable. Causa: el middleware necesita el store montado para tener `action$`. Fix: `run` siempre después de `configureStore`.

### Pieza forense de esta fase — Debug de epics: memory leak por no `takeUntil`, switchMap contra mergeMap

La Fase 5 te enseñó a leer el store en el tiempo (Redux DevTools, time-travel). Esta fase suma **leer el flujo de un Observable en el tiempo**: qué acciones entran y salen de un epic, y —lo más difícil— detectar una suscripción que sigue viva después de que debió morir.

El ejercicio de **"rompe a propósito y observa"** de esta fase usa el refresco de compras de 5.8:

1. Levanta el mock (`npm run mock:api`) y la consola, y entra.
2. En el panel **Dispatch** de Redux DevTools, despacha `{ "type": "START_PURCHASES_REFRESH" }`. En Network, sale un `GET /purchases?status=pending` cada cinco segundos, con su `Authorization`: normal.
3. Cierra sesión y **no toques nada**.
4. **Síntoma forense:** los `GET /purchases` **siguen saliendo** cada cinco segundos. En Request Headers, ya sin `Authorization`. Esa es la suscripción zombi.
5. Correlaciona del lado del servidor: el log del mock anota cada una, `[3001] sin sesión #1: GET /purchases?status=pending`, `#2`, `#3`… Ese contador es tu evidencia: no la deduces, la cuentas. En producción esto es carga de servidor invisible y batería del cliente drenada.
6. Fix: agrega `takeUntil(action$.pipe(ofType(logout.type)))` al final del pipe del `switchMap`. Repite desde el paso 1 y confirma que, tras el logout, el contador no se mueve más.

Y la otra mitad de la pieza, `switchMap` contra `mergeMap`, en la búsqueda: con `CHAOS_LEVEL=high`, escribe `Ana` y enseguida `Anaís`, y mira en Network las dos búsquedas. Con `switchMap`, la lista pinta lo que trajo `Anaís` aunque la de `Ana` responda después; cámbialo a `mergeMap` y, cada tanto, la lista pinta a Ana, la suspendida.

> 📓 De esta fase salen los incidentes **13** y **15** de `cuaderno-incidentes.md`, y nace el **14** ⭐: el epic que muere en silencio, la respuesta vieja que pisa a la nueva, y la suscripción que sobrevive al logout. El 14 se prepara con el polling de la Fase 7, cuando las compras pendientes ya son reales, y es el que el curso usa como ejemplo del par de tags `inc/…-roto` / `-fix`.

---

## 🧪 7. Ejercicios (30)

**🟢 Fácil (1–7)**
1. Monta `epicMiddleware` en tu store y confirma con un epic vacío (`(action$) => action$.pipe(ofType('NADA'))`) que la app arranca sin errores.
2. Escribe un epic mínimo que, ante `PING`, despache `PONG`. Verifícalo en Redux DevTools.
3. Cambia `SEARCH_DEBOUNCE_MS` a 1500 y describe, escribiendo en el buscador, la diferencia perceptible.
4. Explica en un comentario por qué `undoWindowEpic` usa `mergeMap` y no `switchMap`, con un ejemplo de dos envíos.
5. Agrega un `console.log` dentro del `map` de `sendGrantEpic` y observa cuándo se imprime respecto del optimista.
6. Lista, mirando `rootEpic.js` y los epics, todos los `action.type` a los que reacciona la app hoy vía `ofType` o `match`.
7. Dado el esquema `{ message, type }`, enumera los valores de `type` vigentes tras la Fase 6 (incluye `'cancelled'`) y de qué fase vino cada uno.

**🟡 Intermedio (8–15)**
8. Haz que `undoWindowEpic`, además de pedir el envío, despache una acción de registro `undoWindowExpired` con la hora, sin agregar otro epic (extiende el pipe).
9. Haz que `searchPlayerEpic` ignore búsquedas de menos de dos letras *antes* del `debounceTime`, con un `filter`. ¿Qué pasa con la búsqueda vacía del arranque?
10. Explica, con un diagrama de canicas en un comentario, qué haría `sendGrantEpic` con `switchMap` en lugar de `exhaustMap` ante un doble clic. ¿Cuántas peticiones salen?
11. Haz que `cancelOnLogoutEpic` también limpie los envíos fallidos de la lista, no solo los que estaban en cola. ¿Es una buena idea? Justifica.
12. En `grantsReset`, el motivo es un texto fijo. Agrega la hora del cierre de sesión al mensaje y explica qué agregarías para correlacionarlo con un request ID.
13. Escribe un epic que, ante un `rollbackGrant` con `type: 'conflict'`, despache una acción de UI que marque el caso como "ya compensado por otro operador".
14. Simula con el caos (Fase 3) un `timeout` en la ruta de envíos y confirma que «Enviar todos ahora» reintenta tres veces con el backoff esperado (mira los tiempos en Network).
15. Explica por qué `retryGrantEpic` re-lanza el error (`throwError`) para un `conflict` en vez de reintentarlo, con la consecuencia concreta si no lo hiciera.

**🟠 Difícil (16–23)**
16. **Diagnóstico:** te dan `sendGrantEpic` con el `catchError` quitado. Reproduce el síntoma (un envío fallido mata todos los futuros, y la búsqueda también), localiza la línea y aplica el fix mínimo.
17. **Diagnóstico:** `searchPlayerEpic` usa `mergeMap`. Provoca la carrera de respuestas (`Ana` → `Anaís` con caos alto) y muestra en Network cómo una respuesta vieja pinta la lista.
18. Reproduce el leak del refresco de compras (5.8) siguiendo la pieza forense, y aplica el `takeUntil`. Confirma con el log del mock que el contador para tras el logout.
19. **Diagnóstico:** un epic tiene el `takeUntil` puesto *antes* del `map` de éxito. Explica por qué el envío legítimo nunca llega al store y corrige la posición.
20. Cambia `from(api.post(...))` por la llamada directa dentro de `retryGrantEpic`, sin `defer`, y muestra en Network que los "reintentos" no mandan nada. Vuelve a `defer` y explica la diferencia.
21. Mide (pestaña Network) cuántas búsquedas salen al escribir `Anaís` letra por letra, con y sin `debounceTime`.
22. **Diagnóstico:** escribe `ofType('LOGOUT')` en `cancelOnLogoutEpic` y muestra que, tras cerrar sesión, los envíos en cola quedan "En cola" para siempre. Corrige con `logout.type`.
23. Escribe un epic que, ante el logout, deshaga **todos** los envíos fallidos pendientes de reintento, y explica por qué el `takeUntil` de `undoWindowEpic` no alcanzaba (pista: ese `takeUntil` solo corta ventanas abiertas).

**🔴 Muy difícil (24–30)**
24. **Diagnóstico + regresión:** a veces un envío sale aunque el operador tocó «Deshacer». Encuentra la condición de carrera entre el `timer` de la ventana y el `takeUntil` cuando el clic y el vencimiento caen en el mismo milisegundo, y propón el fix (pista: el orden de emisión).
25. Diseña un experimento con tres búsquedas simultáneas en tres asistentes abiertos, y documenta con `switchMap` contra `mergeMap` cuál es correcto y por qué. ¿Cambia la respuesta si las tres buscan el mismo texto?
26. Reproduce un leak que **no** sea de `interval`: un epic con `takeUntil` cuyo notifier nunca emite (un string mal escrito en el `ofType`). Cázalo mostrando que la suscripción sigue viva.
27. Refactoriza `sendGrantEpic` y `retryGrantEpic` a un helper común `grantRequest$(grant)` sin cambiar el comportamiento de ninguno. Justifica qué quedó en el helper y qué en cada epic.
28. `groupBy` nunca cierra sus grupos: una consola abierta todo un evento acumula un grupo por envío. Mide cuántos hay tras cien envíos y propón el `durationSelector` que los cierra.
29. Compara (sin implementar) cómo se vería el doble clic en `redux-saga` (con `takeLeading`) frente al `exhaustMap` de esta fase. ¿Qué se gana y qué se pierde en legibilidad de mantenimiento?
30. Escribe el post-mortem completo (los ocho puntos del post-mortem de `cuaderno-incidentes.md`: síntoma, reproducción, evidencia, causa raíz, corrección, prueba de regresión, prevención, sin culpabilización) del leak del refresco de compras cazado en la pieza forense.

**🔥 Opcionales**
- 🔥 Prototipa el polling de una compra (Fase 7) con `timer(0, 2000)` + `takeUntil`, pegándole a `GET /purchases/:token` del mock de Google Play, sin integrarlo al store real todavía.
- 🔥 Agrega *jitter* (backoff aleatorizado) a `retryGrantEpic` y explica qué problema de "thundering herd" mitiga en un backend real.
- 🔥 Escribe un mini diagrama de canicas (en comentario) de `exhaustMap` ignorando un doble clic, como anticipo del marble testing de la Fase 10.

---

## 📚 8. Referencias

**Documentación oficial**
- https://redux-observable.js.org/docs/basics/Epics.html — anatomía de un epic, `ofType`, `combineEpics`. Versión 1.2.0 del curso.
- https://redux-observable.js.org/docs/basics/SettingUpTheMiddleware.html — `createEpicMiddleware` y `epicMiddleware.run`.
- https://redux-observable.js.org/docs/recipes/InjectingDependenciesIntoEpics.html — las dependencias como tercer argumento.
- https://rxjs.dev/api/operators/switchMap, https://rxjs.dev/api/operators/mergeMap y https://rxjs.dev/api/operators/exhaustMap — léelas juntas; la diferencia es la base del error común #2.
- https://rxjs.dev/api/operators/groupBy — un stream por clave.
- https://rxjs.dev/api/operators/takeUntil — el operador de cancelación de todo el curso.
- https://rxjs.dev/api/operators/debounceTime — para la búsqueda.
- https://rxjs.dev/api/operators/retryWhen y https://rxjs.dev/api/index/function/defer — reintento con backoff; en RxJS 7 `retryWhen` está deprecado en favor de `retry({ delay })`, pero acá usamos **RxJS 6.6.7**.
- https://rxjs.dev/api/operators/catchError — por qué va dentro del Observable interno, no afuera.

**Libros**
- No hay un libro de redux-observable ampliamente adoptado; la documentación oficial y la de RxJS 6.x son la fuente más confiable para estas versiones.

**Video / apoyo**
- Busca en YouTube "redux-observable epics tutorial" y "RxJS switchMap vs mergeMap vs exhaustMap marble diagram". Prefiere contenido de 2020–2022 para que las versiones coincidan con las del curso.

**Orden de lectura sugerido:** anatomía del epic → `SettingUpTheMiddleware` → `takeUntil` → volver a `undoWindowEpic` (5.3) y releerlo → recién ahí `switchMap`, `mergeMap` y `exhaustMap` comparando las tres páginas → `retryWhen` y `defer` al final.

> ⚠️ URLs, títulos y contenidos pueden estar desactualizados; verifícalos antes de compartir. La doc enlazada de RxJS es la de **6.x** — confirma que no estás leyendo la de RxJS 7, que cambia imports (`rxjs/operators` sigue válido en 6.x) y deprecó `retryWhen`.

---

## 🚀 9. Cierre y conexión con la Fase 7

Saliste de esta fase con epics que se cancelan solos. Jubilaste 🪦 los `setTimeout` de la ventana de deshacer y su cancelación manual repartida, reemplazándolos por un `timer` + `takeUntil` que se limpia solo, y que además no deja salir un envío después del logout. Resolviste *en el origen* el doble clic que la Fase 5 frenaba río abajo: ahora el segundo clic no existe. Y —lo más valioso para mantenimiento— aprendiste a cazar una suscripción zombi y a contarla del lado del servidor: ese bug silencioso que no rompe nada hoy pero drena servidor y batería mañana.

La **Fase 7 — cierre a hora exacta y polling de compras** toma el patrón `timer` + `takeUntil` que dominaste acá y lo lleva a su forma más exigente: un `pollingEpic` que pregunta por una compra pendiente al mock de Google Play (puerto `3002`) cada dos segundos, que **debe** detenerse cuando la compra se confirma, cuando el operador sale de la pantalla y cuando cierra sesión; y una guarda de envío que se cruza con el reloj real —el instante de cierre de una rueda, con su zona horaria— que hasta ahora nadie miró. El `takeUntil` deja de ser un detalle: es la diferencia entre un polling que se apaga y el refresco que acabas de cazar.

> **La señal de que quedó bien:** si puedes provocar el leak del refresco de compras, verlo en Network y en el log del mock como peticiones sin sesión que no paran, y arreglarlo agregando una sola línea de `takeUntil` mientras le explicas a un compañero *por qué* esa línea apaga la suscripción entera — esta fase cumplió su propósito.

> 🏷️ **No cierres la fase sin el tag.** Con el checklist de la sección 2 en
> verde y `git status` limpio:
>
> ```bash
> git tag -a fase-06-redux-observable-a-fondo -m "F6 cerrada: <el checklist, en una línea por ítem>"
> ```
>
> Los commits de la fase llevan su prefijo (`f06: …`) y los de ejercicio su
> número (`f06 ej17: …`). Si un ejercicio merece su propio marcador va en
> `ej/f06/17`, y un incidente resuelto en el par `inc/<ID>/<slug>-roto` /
> `-fix`, con el ID que le reserva `cuaderno-incidentes.md`. Todo eso está en
> [`00-convencion-de-git-y-tags.md`](00-convencion-de-git-y-tags.md).

---

## 📌 Pendientes sugeridos

> Material de autoría, no de lectura. Va acá abajo, fuera de la plantilla de nueve
> secciones, porque es lo que apareció al escribir la fase y no cabía adentro — y
> porque no debe competir con el cierre.

- **El registro de epics 💸 se paga a medias.** La Fase 7 agrega una línea al `rootEpic.js` manual, que es exactamente lo que esta fase marcó como no escalable. → O la Fase 7 lo declara **💸 Pago de deuda** y crea el registro automático, o la deuda se reconoce como permanente y se documenta así.
- **`retryGrantEpic` y `sendGrantEpic` comparten casi todo el cuerpo 💸** y no tienen fecha de pago. → `A7-redux-observable-epica-por-epica.md`, o ejercicio 🔴 de extracción (el 27).
- **`groupBy` sin `durationSelector`** acumula un grupo por envío mientras la consola esté abierta. → Ejercicio 28; si algún día pesa, se paga con `groupBy(key, undefined, () => timer(...))`.

### Reservas para el cuaderno de incidentes

Los IDs quedan reservados en `cuaderno-incidentes.md`, donde el enunciado ya está redactado con sus pistas y su solución de referencia. El ID nunca se reasigna.

- **13** — *Falló un envío y desde entonces no sale ninguno* · RxJS / epics · 🟠. Sale del error común #1: sin `catchError`, el primer error mata el epic entero y la consola no dice nada. El silencio es el síntoma.
- **14** ⭐ — *Cerré sesión y el servidor sigue recibiendo peticiones* · RxJS / epics · 🟠. La suscripción zombi del polling de compras sin `takeUntil` del logout. Nace acá, con el refresco de 5.8, y su rama sale de la Fase 7. Se caza en Network y en el log del mock, no en el código, y su fix es una línea.
- **15** — *Busco a la jugadora rápido y me muestra a otra* · RxJS / epics · 🟠. Sale del error común #2: `mergeMap` donde iba `switchMap` en la búsqueda. Las respuestas viejas pisan a las nuevas y el resultado depende de la latencia, así que solo se reproduce con caos alto.
