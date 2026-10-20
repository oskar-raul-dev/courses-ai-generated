# ⚡ Fase 05 — Envíos manuales: concurrencia y UI optimista

> Tutorial React 16 — La Esclusa, la consola de Jewel Locks · Fase 5 de 11 · **12 horas**
> Depende de: Fase 4 — Ruedas CRUD · Habilita: Fase 6 — redux-observable a fondo

---

## 🎯 1. Propósito

La noche de la Esclusa de Oro, el feed de la consola se congeló a las 7:20 y Yariela se quedó sola en soporte, compensando jugadores a ciegas (`00-historia-del-sistema.md` §3, *Hoy*). A la mañana siguiente, el ticket que dejó es corto: *"a Juan lo compensé una vez; en el juego tiene dos"*.

Esta es la fase donde la consola **manda premios**. Un operador compensa a un jugador, o a una lista entera de afectados por una caída, desde la misma pantalla. Cada envío pasa por el servidor, tarda, y puede fallar; mientras tanto, la pantalla tiene que responder: el envío aparece ya en la lista, con su estado, con diez segundos para deshacerlo, y se pinta como enviado antes de que el servidor conteste.

Esa combinación es la fuente de los bugs más caros del sistema: un envío que sale dos veces, un envío confirmado que vuelve a "falló", un tablero de miles de filas que se pinta lento. Cada uno tiene una causa distinta, y los tres se entienden con las mismas herramientas: una **máquina de estados** por envío, con sus transiciones escritas en un solo lugar; una **guarda de origen** antes de cada transición; y Redux DevTools leyendo la secuencia de acciones como un extracto bancario.

---

## ✅ 2. Qué queda listo al terminar

- [ ] `grantSlice` con la máquina de estados de un envío (`queued → sending → sent | failed → reverted`), con las transiciones permitidas declaradas en una tabla (`ALLOWED_TRANSITIONS`).
- [ ] La **ventana de deshacer** de 10 s con `setTimeout` honesto: `openUndoWindow`, `closeUndoWindow` y `expireUndoWindow`, con los temporizadores **fuera** del store.
- [ ] El **envío optimista**: `grantSent` pinta el envío como enviado antes de que el servidor conteste, y `rollbackGrant` lo pasa a `failed` si el servidor lo rechaza; lo que el servidor confirmó no se revierte.
- [ ] La **guarda de origen** en el `condition` de `sendGrant`: solo sale lo que está en cola o falló.
- [ ] `GrantWizard` (hooks): compensar a un jugador o a una lista de afectados, con caso, premio y motivo obligatorio; los jugadores salen del API.
- [ ] `GrantList`: lo que se puede hacer con cada envío según su estado (enviar ahora, deshacer, reintentar, descartar), y «Enviar todos ahora».
- [ ] `GrantsPage` enrutada en `/grants`, con su entrada en el navbar.
- [ ] La ruta de envíos del mock, `POST /players/:id/grants`: `422` sin motivo, `404` si el jugador no existe, `409` si el caso ya se compensó para ese jugador.
- [ ] `toReadableError` con un tipo nuevo, `'conflict'`, para los `409`.
- [ ] El tablero del envío masivo (`GrantBoard`, 10.000 filas) con su render medido, sin y con `React.memo`.

---

## 🚫 3. Qué queda fuera por ahora

- **Los epics** → Fase 6. La ventana de deshacer con `setTimeout` se jubila con un epic (`undoWindowEpic`), y el doble clic se resuelve en el origen con `exhaustMap` (`sendGrantEpic`). Acá se sufre primero la versión sin epics, a propósito.
- **Los reintentos automáticos** → Fase 6 (`retryGrantEpic`). Acá reintentar es un botón.
- **La unicidad garantizada por el servidor** (que el mismo caso no se pueda registrar dos veces, ni con dos pedidos en el mismo milisegundo) → track BE. El mock hace el chequeo al estilo de 2019, en pasos separados, y esa ventana es parte de la lección.
- **Que la cola sobreviva a recargar la página** → no entra. Los envíos en cola viven en el store y sus temporizadores en memoria; un F5 los pierde (ejercicio 🔥).
- **El polling de compras y el cierre de la rueda a hora exacta** → Fase 7. Acá el envío no depende del reloj, salvo por su ventana.
- **El dinero** → Fase 8. Un envío manual no tiene precio: los premios de la consola no tienen valor en dinero (`00-historia-del-sistema.md` §9).

---

## 🧠 4. Conceptos mínimos

### Por qué un envío es un problema distinto al CRUD

El CRUD de la Fase 4 tenía una propiedad cómoda que no valoras hasta que la pierdes: **las operaciones eran independientes.** Crear la rueda A no compite con crear la rueda B; cada thunk vivía en su burbuja. Un envío rompe eso. Lo que está en disputa —la compensación del caso `C-2210` para Juan— es **una sola**. Dos envíos del mismo caso para el mismo jugador no son independientes: son rivales. Uno tiene que ganar y el otro tiene que perder de forma limpia, y el store no puede quedar mintiendo que los dos ganaron.

Esto es, con nombre y apellido, **contención sobre un recurso único**. Un caso de soporte es un asiento de avión o una entrada de concierto: hay uno solo y lo pueden pedir dos clics, dos pestañas o dos operadores. La regla del dominio —"un caso se compensa una vez por jugador"— es una restricción de unicidad, y hacerla cumplir desde un frontend contra un backend que también puede fallar es, sin dramatizar, de lo más difícil que vas a mantener en este sistema.

### La máquina de estados de un envío

Cada envío vive una máquina de estados chica pero estricta:

```mermaid
stateDiagram-v2
    direction LR
    [*] --> queued: encolar
    queued --> sending: vence la ventana o «Enviar ahora»
    queued --> reverted: deshacer
    sending --> sent: optimista (grantSent)
    sending --> failed: rechazo sin optimista
    sent --> failed: el servidor lo rechaza (rollbackGrant, si no estaba confirmado)
    failed --> sending: reintentar
    failed --> reverted: descartar
    reverted --> [*]
```

- **`queued`**: el envío existe en la consola y todavía no salió. Corre su ventana de deshacer.
- **`sending`**: el envío salió del store hacia el servidor. Dura un instante, porque el optimista lo pinta enseguida.
- **`sent`**: el operador lo ve enviado. Con `confirmed: false` es una promesa; con `confirmed: true`, el servidor ya lo registró, y desde ahí nada lo revierte.
- **`failed`**: el servidor lo rechazó, o no contestó. Se puede reintentar o descartar.
- **`reverted`**: deshecho o descartado. Estado terminal.

Las transiciones ilegales son la mitad del trabajo. No se manda lo que ya salió, no se deshace lo que ya salió, y `reverted` no vuelve a ningún lado. Un reducer que no chequea el estado de **origen** antes de transicionar es un reducer que permite mandar dos veces. Vuelve a esa frase cada vez que escribas un `case`; es literalmente el bug que esta fase existe para prevenir.

### La ventana de deshacer sin epics: el `setTimeout` honesto

El envío necesita **salir solo** pasados diez segundos, sin que nadie haga clic en nada, y tiene que poder cancelarse mientras tanto. Eso es una acción diferida en el tiempo y cancelable, y la forma canónica de resolverla en este stack es un epic de RxJS con `timer`. **No lo vamos a hacer así acá** —es Fase 6— y no por capricho: quiero que sufras primero la versión con `setTimeout`, para que cuando llegue el epic entiendas *exactamente qué problema te está resolviendo.*

La versión de esta fase: al encolar, `openUndoWindow` arranca un `setTimeout` que, al vencer, despacha `expireUndoWindow`, y eso manda el envío. Simple. Y con tres trampas que vas a pisar, porque son justo las que el epic resuelve gratis:

1. **Si el envío sale antes ("Enviar ahora"), hay que cancelar el temporizador.** Un `setTimeout` que sigue vivo después del envío va a disparar un segundo envío sobre algo que ya salió. Si el thunk no se protege, el jugador recibe dos premios. 💸
2. **Encolar dos veces el mismo envío pisa el temporizador del primero.** El `Map` guarda un id por envío; si se escribe dos veces, el primer `setTimeout` queda huérfano: sigue corriendo y nadie lo puede cancelar.
3. **El temporizador no sabe de pantallas.** Si el operador cambia de pantalla, el envío sale igual: es lo que se quiere, y por eso el temporizador vive en el thunk y no en un componente. Pero si cierra sesión, también sale. Esa es la trampa que la Fase 6 cierra con `takeUntil`.

Guardamos los ids de los temporizadores **fuera** del store (en un `Map` a nivel de módulo, porque un id de `setTimeout` no es serializable y no va en Redux 💸) y los cancelamos en cada transición que corresponda. Cuando en Fase 6 reemplaces todo esto por un epic, vas a entender en el cuerpo por qué existe `takeUntil`.

### Optimistic update y rollback: mentir rápido, corregir a tiempo

Un envío que se queda esperando la respuesta del servidor antes de pintarse se siente lento y roto, y con cientos de compensaciones por noche nadie quiere esperar el ida y vuelta de cada una. La técnica estándar es **optimista**: pintas `sent` de inmediato, asumiendo que va a salir bien, y mandas la petición en paralelo. Si el servidor confirma, no cambias nada visible —ya estaba pintado— y anotas que está confirmado. Si el servidor **rechaza** (un `503`, o un `409` porque ese caso ya se compensó), tienes que **revertir**: el envío pasa a `failed`, con el mensaje del servidor.

El rollback es la parte que todo el mundo olvida, y por la que aparecen los bugs "fantasma": la fila queda `sent` en la consola pero el servidor nunca registró nada. Y tiene su propia trampa, que es la de esta fase: **el rollback tiene que revertir este envío, y solo si nadie lo confirmó**. Un rollback que busca "el envío de este caso" en vez de "este envío", o que revierte sin preguntar si el servidor ya lo había confirmado, deshace el trabajo de otro. Por eso `rollbackGrant` busca por id y respeta `confirmed`.

> 📝 **De dónde viene esto en este sistema.** El envío optimista es de 2020, de Fiorella: *"la fila se marca como enviada al instante y se revierte si el servidor protesta"* (`00-historia-del-sistema.md` §3, era 2). Funciona casi siempre, y el "casi" es esta fase. No fue una mala decisión: fue la correcta con un caso límite mal cerrado.

### La forma del error legible se hereda, con un tipo nuevo

La Fase 4 fijó que el store nunca guarda el error crudo de axios, sino un objeto `{ message, type }` que arma `toReadableError`. Esta fase **reutiliza esa misma forma** y le suma un tipo: **`'conflict'`**, para cuando el backend responde `409` porque lo que mandas choca con lo que ya registró. Ese tipo es el que le permite a la lista decir "ese caso ya fue compensado para este jugador" en vez del genérico "ocurrió un error". Un tipo nuevo, mismo esquema: no inventamos otra forma.

> 📝 **El 401, igual que en Fase 4.** El interceptor global de `apiClient` (Fase 3) sigue cerrando la sesión ante cualquier 401. El slice de envíos **no** maneja 401: del 401 se encarga la capa de transporte, en un solo lugar.

### Convivencia class/hooks

La Fase 4 dejó `WheelTable` en clase y `WheelForm` en hooks. Esta fase es toda **funcional con hooks**: el asistente, la lista y el tablero se benefician de `useSelector`, `useCallback` y `React.memo` de una forma que en clase sería más verbosa. No fuerzo una clase donde no aporta. La regla del curso no es "usa clases siempre", es "sabe leer y escribir ambas". Acá tocó hooks por mérito propio.

---

## 💻 5. Implementación y código comentado

Trabajamos en `src/features/grants/`, con una ruta nueva en el mock y un tipo nuevo en el error legible. Esta fase no instala nada.

### 5.1 La ruta de envíos del mock — `mock/server.js`

El mock registra cada envío en la colección `grants` de `db.json`, que arranca vacía. La ruta es propia, como el giro de la Fase 3, porque tiene reglas: el motivo es obligatorio (`00-historia-del-sistema.md` §9), el jugador tiene que existir, y un caso se compensa una vez por jugador.

<<<fragmento:mock/server.js|const GRANT_DELIVERY_MS|lo que tarda el juego en entregar un premio>>>

<<<fragmento:mock/server.js|// Envío manual (F05)|return res.status(201).json(grant);
}>>>

<<<fragmento:mock/server.js|server.post("/players/:id/grants"|});>>>

Fíjate en el orden de `registerGrant`: **comprueba, entrega y recién después anota**. Es el estilo del API de 2019, el mismo del giro: entre el chequeo y la escritura pasan `GRANT_DELIVERY_MS` (800 ms por defecto), y dos pedidos del mismo caso que caen dentro de esa ventana pasan los dos. Un pedido que llega después ve el registro del primero y se lleva un `409`. El servidor se defiende bien de lo lento y mal de lo simultáneo, y esa es la mitad del incidente 11.

### 5.2 El error legible, con conflicto — `src/api/readableError.js`

<<<archivo:src/api/readableError.js>>>

La rueda en vivo de la Fase 4 también responde `409`, así que su mensaje pasa a llegar con `type: 'conflict'`. El mensaje que ve el operador no cambia: es el del servidor.

### 5.3 El slice con su máquina de estados — `src/features/grants/grantSlice.js`

<<<archivo:src/features/grants/grantSlice.js>>>

> **Detalles con intención.**
> - `ALLOWED_TRANSITIONS` y `transition` son la máquina de estados entera. Ningún reducer asigna `status` a mano: todos piden la transición, y la tabla dice si se puede.
> - La guarda de origen está en el `condition` del thunk, **antes** de que exista la petición. Si el envío ya salió, `sendGrant` ni despacha `pending`: no hay nada que deshacer porque no pasó nada.
> - `grantSent` se despacha dentro del thunk, inmediatamente después de `pending`: es el optimista. `sendGrant.fulfilled` no cambia el estado: anota `confirmed`, y la etiqueta pasa de "Enviado (sin confirmar)" a "Enviado".
> - `rollbackGrant` lleva el `grantId` **y** el caso y el jugador. El reducer usa el id; los otros dos viajan para que DevTools muestre de qué caso se trata. La tentación de usarlos para buscar es el incidente 12.
> - `queueGrant`, `undoGrant` y `expireUndoWindow` son thunks de función, no `createAsyncThunk`: no hablan con la red, solo coordinan el temporizador y el store.

Registra el reducer en el store:

<<<fragmento:src/app/store.js|export const store|});>>>

### 5.4 El asistente — `src/features/grants/GrantWizard.jsx`

<<<archivo:src/features/grants/GrantWizard.jsx>>>

Un jugador o una lista de afectados es el mismo flujo: marcar a quién, poner el caso, el premio y el motivo, y encolar. El envío masivo no es otro código: es el mismo `queueGrant` una vez por jugador. Los jugadores salen del API (`GET /players`), y con eso se paga la parte de jugadores de la deuda de la Fase 1; la pantalla *Jugadores* sigue con sus datos de demo, y queda declarada en A12.

### 5.5 La lista — `src/features/grants/GrantList.jsx`

<<<archivo:src/features/grants/GrantList.jsx>>>

«Enviar ahora» sigue a mano mientras el envío no está confirmado. Es una decisión de producto de la época —si un envío parece colgado, el operador puede insistir— y es la puerta por la que entra el doble clic. La protección no está en el botón: está en la guarda del thunk.

### 5.6 La página, la ruta y el navbar

<<<archivo:src/features/grants/GrantsPage.jsx>>>

En `src/AppRouter.jsx` se suman dos rutas. `/grants/board` va **antes** que `/grants`, con `exact`: si no, `/grants` la tapa (es el mismo orden que aprendiste en la Fase 1).

<<<archivo:src/AppRouter.jsx>>>

Y el navbar gana su entrada, "Envíos":

<<<archivo:src/components/Navbar.jsx>>>

### 5.7 El tablero del envío masivo — `src/features/grants/GrantBoard.jsx`

Una caída afecta a miles de jugadores, y antes de compensarlos Yariela revisa la lista: incluye a unos, excluye a otros. Con 10.000 filas, cambiar **una** vuelve a pintar las 10.000, y eso se nota. El tablero conserva ese problema a propósito, y la corrección vive en el mismo archivo para medirla.

<<<archivo:src/features/grants/GrantBoard.jsx>>>

La corrección son dos piezas que solo funcionan juntas. `React.memo` hace que una fila no se vuelva a pintar si sus props son las mismas; `useCallback` hace que `onToggle` sea **la misma función** en cada render. Sin el segundo, cada render crea un `toggle` nuevo, `React.memo` ve una prop distinta en cada fila, y vuelve a pintar las 10.000 igual.

**La medición de la fase.** Corrida del 14/10/2026 con `cypress/included:10.11.0` (Electron, que es Chromium, headless) contra el servidor de desarrollo de la fase, 10.000 filas, cinco cambios de fila por variante:

| Variante | Cambios (ms) | Media (ms) |
|---|---|---|
| Sin `React.memo` (`?memo=0`) | 256, 247, 221, 222, 229 | 235 |
| Con `React.memo` (`?memo=1`) | 68, 54, 56, 51, 59 | 58 |

La cifra que el curso publica es esa: cuatro veces menos con las filas memorizadas, en un navegador de verdad y no en jsdom. No es comparable con cifras de otro navegador o de otra máquina: el número cambia, la forma de la diferencia no.

### 5.8 Corrección mínima vs refactorización

Un ejemplo concreto de la distinción que el curso repite hasta el cansancio. Supongamos que en producción aparece el doble envío (la trampa 1 de la §4: el temporizador que sigue vivo, o el segundo clic sobre un envío que ya salió).

**Corrección mínima (hotfix):** la guarda de origen en el `condition` de `sendGrant`: solo sale lo que está en `queued` o `failed`. Unas pocas líneas. Impide que un segundo intento llegue a crear la petición. Va a producción hoy, es segura, y no toca la arquitectura.

**Refactorización (con tiempo y pruebas):** mover la ventana a un epic de redux-observable con `timer` y `takeUntil`, y el envío a un epic con `exhaustMap`, que ignora los clics mientras hay un envío en vuelo. Es más correcto —el segundo intento ni siquiera existe— pero toca la arquitectura, necesita RxJS y pruebas con canicas, y es exactamente lo que hace la Fase 6. Y aun así no cierra la mitad del servidor: dos operadores, en dos consolas, en el mismo segundo, solo se frenan con una unicidad garantizada en la base, que es trabajo del track BE.

Saber cuál aplicar según el contexto —30 minutos con producción caída contra un sprint con pruebas— es la habilidad de mantenimiento que esta fase entrena. No hay una respuesta "correcta" universal; hay la correcta para el martes que te toca.

> **Prueba de fuego.** Con `npm run mock:api` arriba y `CHAOS_LEVEL=off`: entra a `/grants`, marca a Juan, caso `C-2210`, motivo "caída", y compensa. Deshaz antes de diez segundos: la fila queda "Deshecho" y en Network no sale nada. Compensa otra vez y espera: a los diez segundos sale solo, "Enviado (sin confirmar)" y al momento "Enviado". Compensa a Juan y a María con el mismo caso y toca «Enviar todos ahora»: el de Juan falla con "Ese caso ya fue compensado para este jugador." y el primero sigue "Enviado". Y en `/grants/board?n=10000&memo=1`, cambiar una fila se siente instantáneo; con `memo=0`, no.

### 💸 Deuda técnica declarada en esta fase

1. **Los temporizadores en un `Map` de módulo.** No son serializables, no se ven en DevTools y sobreviven al logout. Se paga en la Fase 6 con el epic de la ventana.
2. **«Enviar ahora» vivo hasta la confirmación.** La guarda del thunk cubre el doble clic; el `exhaustMap` de la Fase 6 lo cierra en el origen.
3. **El chequeo del caso en el mock no es atómico.** Dos pedidos simultáneos pasan los dos. Es del API heredado; lo paga el track BE con una restricción en la base.
4. **La pantalla *Jugadores* sigue con `demoPlayers`.** El asistente ya lee del API; la pantalla, no. Queda en A12 con su disparador.
5. **La cola no sobrevive a un F5.** Un envío en cola que el operador pierde al recargar no sale nunca, y nadie se entera.

---

## ⚠️ 6. Errores comunes y pieza forense

### Errores comunes

**1. El reducer que no chequea el estado de origen.**
*Síntoma:* un envío sale dos veces, o un envío deshecho sale igual. *Causa:* una transición (`grantSent`, el `pending` de `sendGrant`) que asigna el estado nuevo sin verificar el actual. *Fix mínimo:* la transición pasa por `ALLOWED_TRANSITIONS`, y el thunk tiene su `condition`. Es baratísimo y es la diferencia entre una máquina de estados y un `=` suelto.

**2. El rollback que revierte lo que no es suyo.**
*Síntoma:* un envío que ya figuraba "Enviado" pasa a "Falló" sin que nadie lo toque. *Causa:* el rollback busca el envío por caso (o por jugador) en vez de por id, o revierte sin mirar si el servidor ya lo había confirmado. *Fix:* buscar por id y respetar `confirmed`, como hace `rollbackGrant`.

**3. El temporizador que se queda huérfano.**
*Síntoma:* el operador manda un envío con «Enviar ahora» y a los diez segundos aparece en DevTools un segundo `grants/send` que nadie pidió. *Causa:* el temporizador de la ventana no se canceló, o su id se pisó al encolar dos veces. *Fix mínimo:* `closeUndoWindow` al principio de `sendGrant`, y la guarda de origen como red. *Refactor:* el epic de la Fase 6, que se limpia solo con `takeUntil`.

**4. El optimista sin rollback.**
*Síntoma:* la fila queda "Enviado" pero el servidor nunca registró el envío; al recargar, no está, y el jugador nunca recibió nada. *Causa:* se pinta `sent` optimista pero el `catch` del thunk no revierte. *Fix:* despachar `rollbackGrant` en el `catch`.

### Pieza forense de esta fase — La race de los envíos en el store

Esta es **la** pieza forense de la Fase 5: cómo se manifiesta una race de envíos **en el store**, y cómo cazarla con las herramientas que ya sabes usar desde la Fase 4 —Redux DevTools, time-travel, el panel Diff—. No reintroducimos DevTools; lo llevamos a su terreno natural.

La race canónica: el mismo envío disparado dos veces casi a la vez —un doble clic en «Enviar ahora» mientras el servidor no confirmó, o el clic y el temporizador de la ventana en el mismo segundo—. Sin la guarda de origen, la secuencia en el panel de DevTools se ve así:

```text
grants/send/pending     g-1      ← primer clic: queued → sending
grants/grantSent        g-1      ← el optimista: sending → sent
grants/send/pending     g-1      ← segundo clic: nadie preguntó el origen
grants/grantSent        g-1      ← otra vez "enviado"
grants/send/fulfilled   g-1      ← el servidor registró el primero…
grants/send/fulfilled   g-1      ← …y el segundo: el chequeo del caso no es atómico
```

Dos `fulfilled` para el mismo `grantId`: el jugador recibió dos premios, y la consola muestra **uno**. Eso se ve en el Diff: el segundo `grants/grantSent` no cambia nada visible (ya estaba `sent`), y por eso nadie lo nota en la pantalla. El time-travel te deja pararte justo antes del segundo `pending` y confirmar que, en ese instante, el envío ya había salido. No es magia: es leer la lista de acciones de arriba abajo, entera.

La otra cara es la del rollback. Un envío individual a Juan, confirmado, y un envío masivo que incluye a Juan con el mismo caso: el del masivo recibe un `409` y su rollback, si busca "el envío de Juan en este caso", encuentra el primero y lo pasa a `failed`. En DevTools, el `grants/rollbackGrant` lleva `grantId: "g-7"` en el payload, y el Diff muestra que el que cambió fue `g-1`. **Lo que dice la acción y lo que hace el reducer no coinciden**, y esa es la firma del bug.

Los ejercicios de "rompe a propósito y observa" (23 y 24) te hacen reproducir las dos secuencias, leerlas en DevTools y proponer el blindaje. La solución robusta —cancelar el intento perdedor en el origen— es territorio de epics (Fase 6), y la que cierra la ventana del servidor, del track BE. Acá el objetivo es **verla y nombrarla**, que es el 80 % de resolver un incidente de concurrencia. Un bug que sabes describir es un bug medio muerto.

> 📓 De esta fase salen los incidentes ⭐ **11** y **12** de `cuaderno-incidentes.md`. El 11 es la primera secuencia de arriba, llegando desde soporte con un jugador que tiene dos premios; el 12 es la segunda, con un envío confirmado que vuelve a "falló".

---

## 🧪 7. Ejercicios (28)

**🟢 Fácil (1–8)**

1. Compensa a Juan con el caso `C-1` y deshaz antes de diez segundos. Confirma en la pestaña Network que no salió ninguna petición.
2. Compensa a María y no toques nada. Mide con un reloj cuánto tarda en salir sola y compáralo con `UNDO_WINDOW_MS`.
3. Cambia la ventana a 5 s y verifica a mano (o con una prueba como la del ejercicio 10) que el envío sale solo a los 5 s.
4. En Redux DevTools, sigue un envío completo y anota la secuencia de acciones, desde `grants/grantQueued` hasta `grants/send/fulfilled`.
5. Agrega a la lista una columna con la hora en que se encoló cada envío.
6. Muestra en cada fila en cola cuántos segundos le quedan a su ventana.
7. Intenta compensar sin motivo y mira qué responde el mock (con `curl` o en Network). ¿Qué hace la consola para que eso no pase?
8. Lee `ALLOWED_TRANSITIONS` y dibuja a mano la máquina de estados. Compárala con el diagrama de la §4.

**🟡 Intermedio (9–17)**

9. Agrega un selector `selectGrantCounts` que devuelva cuántos envíos hay en cada estado, y muéstralo arriba de la lista.
10. Escribe una prueba que encole diez envíos, deshaga cinco, y verifique que salen cinco peticiones (con un adapter de axios que las cuente).
11. Haz que «Descartar» pida confirmación antes de pasar el envío a `reverted`.
12. Agrega un filtro por estado a la lista (todos, en cola, fallidos).
13. Con `CHAOS_LEVEL=high`, manda diez envíos y anota cuántos fallan y con qué mensaje. ¿Cuáles son `conflict` y cuáles `http`?
14. Haz que «Reintentar» esté deshabilitado mientras el envío está en `sending`. ¿Hace falta, si el thunk ya tiene su guarda?
15. Agrega al asistente un buscador de jugadores por nombre (filtro local sobre la lista que vino del API).
16. Escribe el JSDoc de `queueGrant`, con la forma de su parámetro.
17. En `GrantBoard`, quita `useCallback` y deja `React.memo`. Mide con el Profiler de React DevTools y explica el resultado.

**🟠 Difícil (18–24)**

18. Haz que encolar dos veces el mismo caso para el mismo jugador, en la misma sesión, se ignore en el store. ¿Dónde va la regla: en `queueGrant`, en el reducer o en el componente? Justifica.
19. Reproduce el temporizador huérfano en una prueba de Jest: despacha `openUndoWindow` dos veces para el mismo envío, espera la ventana y cuenta cuántas peticiones salen. ¿Qué evita que salgan dos?
20. Diagnóstico: un compañero propone poner el `setTimeout` de la ventana dentro de un `useEffect` de `GrantList`. Describe qué se rompe cuando el operador cambia de pantalla.
21. Con el mock arriba, manda con `curl` dos pedidos del mismo caso en el mismo segundo (`&` en la terminal) y otros dos con un segundo de diferencia. Explica las respuestas con el orden de `registerGrant`.
22. Haz que un `409` de tipo `conflict` deje el envío en `reverted` en vez de `failed`, con su mensaje. ¿Qué gana el operador y qué pierde?
23. **Rompe a propósito y observa:** quita el `condition` de `sendGrant`, pon `GRANT_DELIVERY_MS=3000` y haz doble clic en «Enviar ahora». Copia la secuencia de DevTools y cuenta los registros en `GET /grants`. Después restaura la guarda.
24. **Rompe a propósito y observa:** cambia `rollbackGrant` para que busque el envío por caso y jugador. Reproduce el envío individual confirmado y el masivo del mismo caso, y encuentra en el Diff el envío que cambió sin que su id esté en la acción.

**🔴 Muy difícil (25–28)**

25. Escribe una prueba de reducer puro que reproduzca la secuencia del incidente 12 (sin red, sin componentes) y falle si alguien vuelve a buscar por caso en `rollbackGrant`.
26. Diseña cómo sería un envío que sobrevive al cierre de la pestaña: qué guardas, dónde, y qué pasa con la ventana de deshacer al volver.
27. Mide el tablero con 20.000 filas, sin y con `React.memo`, con el mismo arnés de la fase. ¿Crece lineal? ¿Qué parte del tiempo no es de React?
28. Corrección mínima contra refactor: te dan 30 minutos para frenar el doble envío en producción. Escribe el hotfix y, aparte, describe el refactor con epics que harías con un sprint y pruebas. Marca qué queda como 💸 y quién la paga.

**🔥 Opcionales**

- 🔥 Reemplaza el `setTimeout` por una cola de trabajos en el servidor. ¿Qué gana el operador y qué pierde la ventana de deshacer?
- 🔥 Virtualiza el tablero (solo se pintan las filas visibles) sin librerías. Compara con `React.memo` en la misma medición.
- 🔥 Porta `GrantList` a un class component con `connect()` y compáralo línea a línea con la versión de hooks.

---

## 📚 8. Referencias

**Documentación oficial**

- https://redux-toolkit.js.org/api/createAsyncThunk — la opción `condition`, que cancela el thunk antes de `pending`. Fíjate en la versión: el proyecto usa RTK **1.8.x**.
- https://legacy.reactjs.org/docs/react-api.html#reactmemo — `React.memo` en React 16.
- https://legacy.reactjs.org/docs/hooks-reference.html#usecallback — `useCallback`, y por qué una función nueva rompe la memorización.
- https://legacy.reactjs.org/docs/hooks-reference.html#uselayouteffect — `useLayoutEffect`, que corre después de tocar el DOM y antes de pintar.
- https://developer.mozilla.org/es/docs/Web/API/setTimeout — `setTimeout` y `clearTimeout`, y por qué su id no es un dato serializable.
- https://github.com/reduxjs/redux-devtools — Redux DevTools: el panel Diff y el time-travel.

**Lectura de apoyo**

- Martin Fowler, *"Optimistic Offline Lock"*, en *Patterns of Enterprise Application Architecture* (2002) — el mismo problema del lado del servidor: qué hacer cuando dos actores escribieron sobre lo mismo.

**Orden de lectura sugerido:** la máquina de estados de la §4 → `grantSlice.js` en la §5.3 → la opción `condition` en la doc de `createAsyncThunk` → la pieza forense, con Redux DevTools abierto.

> ⚠️ Las URLs, títulos y números de sección pueden haber cambiado o apuntar a versiones más nuevas que las fijadas. Verifica siempre que lo que lees aplique a RTK 1.8 y React 16.14.

---

## 🚀 9. Cierre y conexión con la Fase 6

El operador manda premios con una ventana para deshacer, cada envío tiene su estado y sus transiciones están en una tabla, el envío se pinta antes de que el servidor conteste y se corrige si el servidor protesta, y el tablero de diez mil filas se pinta en una fracción de lo que tardaba. También viste, en DevTools, las dos races que este diseño deja abiertas, y cuál es la corrección mínima de cada una.

La **Fase 6 — redux-observable a fondo** jubila los temporizadores de esta fase. La ventana de deshacer pasa a un epic con `timer` y `takeUntil`, el doble clic se resuelve en el origen con `exhaustMap`, y el envío que sigue saliendo después del logout se corta con un epic que escucha el logout. Lo que esta fase hizo con guardas, la siguiente lo hace con operadores.

> **La señal de que quedó bien:** si un compañero abre la consola, manda un premio, lo deshace dentro de la ventana y ve la lista cambiar; hace doble clic en «Enviar ahora» y en `GET /grants` hay un solo registro; y manda el mismo caso dos veces y el primero sigue "Enviado" —la fase cumplió.

> 🏷️ **No cierres la fase sin el tag.** Con el checklist de la sección 2 en
> verde y `git status` limpio:
>
> ```bash
> git tag -a fase-05-envios-manuales -m "F5 cerrada: <el checklist, en una línea por ítem>"
> ```
>
> Los commits de la fase llevan su prefijo (`f05: …`) y los de ejercicio su
> número (`f05 ej23: …`). Si un ejercicio merece su propio marcador va en
> `ej/f05/23`, y un incidente resuelto en el par `inc/<ID>/<slug>-roto` /
> `-fix`, con el ID que le reserva `cuaderno-incidentes.md`. Todo eso está en
> [`00-convencion-de-git-y-tags.md`](00-convencion-de-git-y-tags.md).

---

## 📌 Pendientes sugeridos

> Material de autoría, no de lectura. Va acá abajo, fuera de la plantilla de nueve
> secciones, porque es lo que apareció al escribir la fase y no cabía adentro — y
> porque no debe competir con el cierre.

- **El tablero del envío masivo es de previsualización**: no está conectado a la cola. → Decidir en la Fase 9 si el dashboard lo reutiliza, o si queda como instrumento de medición.
- **La cola que se pierde con un F5** no tiene disparador escrito. → Agregarlo a A12: el día que un operador pierda un envío al recargar en un evento.

### Reservas para el cuaderno de incidentes

Los IDs quedan reservados en `cuaderno-incidentes.md`, donde el enunciado ya está redactado con sus pistas y su solución de referencia. El ID nunca se reasigna.

- **11** ⭐ — *Compensamos dos veces a la misma jugadora* · Concurrencia · 🔴. Sale de la guarda de origen que falta: el doble clic manda dos veces el mismo envío y el chequeo del caso en el servidor no es atómico.
- **12** — *Un envío que ya estaba enviado volvió a «falló»* · Concurrencia · 🟠. Sale del rollback que busca por caso: el `409` del envío masivo pisa el envío individual ya confirmado.
