# ⚡ Fase 05 — Envíos manuales: concurrencia y UI optimista

> Tutorial React 16 — La Esclusa, la consola de Jewel Locks · Fase 5 de 11 · **8 horas**
> Depende de: Fase 4 — Ruedas CRUD · Habilita: Fase 6 — redux-observable a fondo

---

## 🎯 1. Propósito

Esta es la fase donde la consola manda premios. Un operador compensa a un jugador, o le envía un premio por una promoción, o lo hace a una lista de afectados. Cada envío pasa por el servidor, tarda, y puede fallar. Mientras tanto la pantalla tiene que responder: el operador ve el envío ya en la lista, con su estado, y puede deshacerlo si se equivocó.

Esa combinación es la fuente de los bugs más caros del sistema. Un envío que sale dos veces, un envío confirmado que vuelve a "falló", un tablero de miles de filas que se pinta lento. Cada uno tiene una causa distinta, y las tres se entienden con la misma herramienta: una **máquina de estados** por envío, con transiciones escritas en una sola tabla.

Esta fase reemplaza la venta de números de la versión vieja. Ya no hay una grilla de 10.000 celdas: hay envíos, cada uno con su estado, y un tablero de envío masivo que muestra miles de filas. El problema de render del tablero se conserva, y se mide en un navegador de verdad.

> 📝 **Nota de convención.** Los estados de un envío van en inglés como valores (`queued`, `sent`), y la etiqueta que ve el operador ("En cola (deshacer)") sale de un mapa.

---

## ✅ 2. Qué queda listo al terminar

- [ ] `grantSlice` con los estados `queued`, `sending`, `sent`, `failed` y `reverted`, y sus transiciones en una sola tabla. Una transición no permitida se ignora.
- [ ] Ventana de deshacer de 10 s: un envío encolado se puede deshacer, y pasado el tiempo sale solo. El temporizador es `setTimeout`, y vive fuera del store.
- [ ] Envío masivo: a una lista de jugadores, cada envío tiene su estado. Si unos fallan, los demás no se tocan.
- [ ] `POST /players/:id/grants` en el mock, con motivo obligatorio (422 sin él) y jugador inexistente (404).
- [ ] Tablero de 10.000 filas, con la medición del render de un cambio de fila en Chrome headless: sin memo y con memo.
- [ ] Pruebas de la máquina de estados con tiempos reales, en verde.

---

## 🚫 3. Qué queda fuera por ahora

- **El polling de compras y el cierre de la rueda a hora exacta**: Fase 7. Acá el envío no depende del reloj.
- **Las compensaciones duplicadas entre operadores**: el incidente 11 lo muestra; su corrección vive en el mock y en la clave del caso, y la sección 5.3 la deja anotada como lo que el incidente pide.
- **Cancelar un envío ya enviado**: no existe. Un envío `sent` es un hecho; lo que se hace después es otro envío, con su motivo.
- **Envíos desde la lista de jugadores**: la pantalla de envíos toma el jugador de un selector. Conectarla con `PlayersPage` llega después de la Fase 9.

---

## 🧠 4. Conceptos mínimos

**Una máquina de estados por envío.** Un envío nace `queued`: ya aparece en la lista, pero no ha salido. Desde `queued` puede pasar a `sending` (cuando vence la ventana) o a `reverted` (si el operador lo deshace). `sending` termina en `sent` o `failed`. `failed` puede revertirse. `sent` y `reverted` son terminales. Esa tabla es la regla; lo demás es implementación.

**La ventana de deshacer.** Diez segundos entre el clic y el envío real. Dentro de la ventana, deshacer es barato: el envío nunca salió. Pasada la ventana, deshacer ya no existe. El temporizador es un `setTimeout`, y es honesto: si la pestaña se cierra, el temporizador se pierde y el envío no sale. Eso es un comportamiento que el operador debe saber, y la pantalla lo dice.

**UI optimista y rollback.** La lista muestra el envío antes de que el servidor responda. Si el servidor falla, el envío pasa a `failed` con su mensaje, y el operador decide. No hay un "reintento automático": un premio mal enviado dos veces es peor que uno que hay que mirar.

**El tablero y el render.** Diez mil filas en React 16 cuestan tiempo en cada actualización si cada fila se vuelve a pintar. `React.memo` evita volver a pintar las filas que no cambiaron, a costa de que la prop de la fila sea estable. La medición de la fase dice cuánto cuesta y cuánto ahorra.

> 🧭 **Dónde vive cada cosa.** El estado del envío vive en el store (es lo que la pantalla y el servidor tienen que ver igual). El temporizador vive fuera del store (un temporizador no es serializable y no es un dato). La medición vive en la página (es un instrumento, no un dato del dominio).

---

## 💻 5. Implementación y código comentado

Vamos de abajo hacia arriba: primero el mock, después el servicio, el slice con su máquina de estados, las pantallas, y al final la medición del tablero. No se instala ninguna dependencia nueva.

### 5.1 La ruta de envíos en el mock: `mock/server.js`

El CRUD automático no genera rutas anidadas, así que la ruta de envíos se escribe a mano, como la del giro. Este es el bloque de la fase:

<<<fragmento:mock/server.js|// Envío manual de un premio a un jugador (F05).|server.use(router);>>>

**Detalles con intención.**
- El motivo es obligatorio. Un envío sin motivo no tiene a quién explicarle el premio, y la bitácora queda sin sentido.
- El jugador se comprueba en el servidor: un envío a un jugador que no existe responde 404 y no crea nada.
- La tabla `grants` empieza vacía en la semilla. Si falta en `db.json`, la primera escritura la crea, pero el listado de la consola no tiene nada que mostrar hasta entonces: la semilla siempre la incluye.

### 5.2 El servicio: `src/api/grantService.js`

<<<archivo:src/api/grantService.js>>>

**Detalles con intención.**
- Un 422 lleva el mensaje del servidor ("el motivo es obligatorio"), y ese mensaje es el que ve el operador.
- Un 5xx no se confunde con un rechazo: el servidor no dijo que no; no respondió. La diferencia importa para decidir si el operador puede reintentar.

### 5.3 El slice con su máquina de estados: `src/features/grants/grantSlice.js`

<<<archivo:src/features/grants/grantSlice.js>>>

**Detalles con intención.**
- La tabla `PERMITIDAS` es la regla. Todas las transiciones pasan por `transicion`, y una transición que la tabla no permite se ignora. Esa es la defensa contra las acciones que llegan fuera de orden.
- `queueGrant` arranca el temporizador dentro del thunk, no en un componente. Así el envío sale aunque el operador cambie de pantalla, y el temporizador se cancela solo si el operador deshace.
- `timers` es un `Map` fuera del store. Un temporizador no es un dato serializable; ponerlo en el estado rompe la regla de Redux y las herramientas de depuración.
- `sendGrant.rejected` usa `transicion`: un rechazo solo cambia el estado si el envío estaba `sending`. Esa línea es la que el incidente 12 quita.
- La identificación del caso (`caseId`) queda vacía en la base: el incidente 11 la agrega, y muestra por qué hace falta.

### 5.4 La pantalla de envíos: `src/pages/GrantPage.jsx`

<<<archivo:src/pages/GrantPage.jsx>>>

**Detalles con intención.**
- El formulario tiene estado local (jugador, premio, motivo). La lista de envíos es del store. Un envío a medio escribir no es un dato del dominio.
- "Enviar a todos" encola un envío por jugador. Cada uno tiene su estado; si uno falla, los demás siguen su curso. Es el envío masivo que falla a medias.
- El botón "Deshacer" solo aparece en `queued`. La pantalla no ofrece lo que la máquina de estados no permite.

### 5.5 El tablero de 10.000 filas: `src/pages/GrantBoardPage.jsx`

Este tablero existe para medir. Cada fila es un componente; la versión sin memo vuelve a pintar todas las filas en cada cambio, y la versión con `React.memo` solo vuelve a pintar la fila que cambió. La medición vive en la propia página: `useLayoutEffect` corre después de tocar el DOM y antes de pintar, y ahí se cierra el tiempo.

<<<archivo:src/pages/GrantBoardPage.jsx>>>

**Detalles con intención.**
- `cambiar` tiene `useCallback` con dependencias vacías: su identidad no cambia entre renders. Sin eso, `React.memo` no sirve de nada, porque la prop `onCambiar` sería nueva cada vez.
- `setFilas` usa la forma funcional y crea un arreglo nuevo, pero solo cambia el objeto de la fila afectada. Las demás filas conservan su referencia, y `memo` las reconoce.
- `useLayoutEffect` sin dependencias corre en cada render: cierra la medición que abrió el clic. Es un instrumento de la fase, no código de producción.

**La medición de la fase.** Corrida del 14/10/2026 con `cypress/included:10.11.0` (Electron, que es Chromium, headless) contra el servidor de desarrollo de la fase, 10.000 filas, cinco cambios de fila por variante:

| Variante | Cambios (ms) | Media (ms) |
|---|---|---|
| Sin `React.memo` (`?memo=0`) | 250, 256, 224, 220, 213 | 233 |
| Con `React.memo` (`?memo=1`) | 163, 54, 48, 50, 53 | 74 |

El primer cambio de la variante con memo es más lento que los siguientes: es el primer render de las filas memorizadas. La cifra que el curso publica es la media de la variante sin memo y la de la variante con memo, con esa salvedad. No es comparable con cifras de otro navegador o de otra máquina: el número cambia, la forma de la diferencia no.

### 5.6 La ruta del tablero: `src/AppRouter.jsx`

<<<fragmento:src/AppRouter.jsx|<PrivateRoute exact path="/grants/board"|<PrivateRoute path="/grants" component={GrantPage} />>>>

---

## ⚠️ 6. Errores comunes y pieza forense

### Errores comunes

**1. El envío que sale dos veces.** Síntoma: el jugador recibe el premio dos veces. Causa: dos operadores, o dos pestañas, envían el mismo caso, y el servidor no lo sabe. Es el incidente 11.

**2. El envío confirmado que vuelve a "falló".** Síntoma: un envío enviado aparece como fallido con un error viejo. Causa: un rechazo tardío de un intento anterior escribe el estado sin mirar la transición. Es el incidente 12.

**3. El temporizador que se queda huérfano.** Síntoma: el operador deshace, pero el envío sale igual. Causa: el temporizador no se cancela, o se cancela después de que disparó. La prueba de deshacer dentro de la ventana lo fija.

**4. El tablero que tarda.** Síntoma: un clic en una fila tarda cientos de milisegundos. Causa: todas las filas vuelven a pintarse. La medición de esta fase tiene el número y la corrección.

### Pieza forense de esta fase: leer la máquina de estados

En Redux DevTools, un envío bien tratado deja esta secuencia: `grants/queueGrant/fulfilled` (queda `queued`), `grants/sendGrant/pending` (queda `sending`), `grants/sendGrant/fulfilled` (queda `sent`). Un envío que se deshace deja `grants/undoGrant/fulfilled` y nada más. Si ves un `sendGrant/rejected` después de `sent`, el reducer no lo aplicó: la transición lo rechazó, y el estado sigue siendo `sent`.

La medición del tablero se repite en el navegador: abre la página con `?n=10000&memo=0` y `?n=10000&memo=1`, haz clic en "Cambiar fila 1" varias veces y mira `window.__ultimoRender` en la consola.

---

## 🧪 7. Ejercicios (24)

Trabaja sobre la app de la fase. Varios son de diagnóstico.

**🟢 Fácil (1–6)**

1. Agrega un contador de envíos por estado en la cabecera de la pantalla de envíos.
2. Cambia la ventana de deshacer a 5 s y verifica que la prueba de "sale solo" sigue pasando con el nuevo valor.
3. Muestra en la tabla la hora de encolado de cada envío.
4. Agrega un mensaje de confirmación cuando un envío llega a `sent`.
5. Cambia el texto del botón "Revertir" por "Reintentar" y explica por qué no es lo mismo en la máquina de estados.
6. Haz que "Enviar a todos" pida confirmación antes de encolar.

**🟡 Intermedio (7–14)**

7. Agrega la transición `sent → reverted` (compensar un envío ya enviado con un envío de signo contrario). ¿Qué parte de la tabla cambias y qué pruebas escribes?
8. Escribe una prueba que encole diez envíos, deshaga cinco y verifica que solo salen cinco.
9. Haz que `sendGrant` reintente una vez los 5xx, sin reintentar los 4xx. Justifica la diferencia y escribe la prueba.
10. Agrega un selector `selectGrantsByPlayer(playerId)` y úsalo para mostrar el historial de un jugador.
11. Quita el `useCallback` de `cambiar` en `GrantBoardPage` y mide en el navegador con `?memo=1`. ¿Qué pasa con el tiempo?
12. Cambia `FilaSinMemo` por una fila con `React.PureComponent` y compara.
13. Agrega un botón "Deshacer todos" que deshaga los envíos en `queued` de un jugador.
14. Escribe una prueba que demuestre que un temporizador cancelado no dispara `sendGrant`.

**🟠 Difícil (15–20)**

15. **Diagnóstico.** Deshaces un envío y, a veces, el envío sale igual. Reproduce el caso con tiempos reales (pista: el orden entre `clearTimeout` y el disparo).
16. **Diagnóstico.** Un envío aparece `failed` con un error de un intento anterior. Reproduce con una acción de rechazo tardío (pista: `meta.arg`) y localiza la línea.
17. Agrega la clave de caso que pide el incidente 11, y verifica que dos operadores no pueden compensar dos veces el mismo caso. ¿Dónde va la regla, en el cliente o en el servidor?
18. Escribe la prueba del tablero: con `?n=100`, el cambio de una fila no re-renderiza las demás cuando usas `memo=1`.
19. Migra `GrantPage` a una clase conectada con `connect()`. Compara el código y anota qué cambia en las pruebas.
20. Agrega al envío masivo una cola con límite de concurrencia de cinco envíos a la vez. ¿Qué cambia para el operador?

**🔴 Muy difícil (21–24)**

21. **Diagnóstico integrador.** El operador reporta que "a veces el tablero se congela al cambiar una fila". Reproduce con 10.000 filas, mide, y separa si es el render, la red o el store.
22. Mide el tablero con 2.000, 5.000 y 10.000 filas en el navegador y dibuja la curva. ¿A partir de qué número el clic se nota?
23. Escribe un post-mortem completo (síntoma, reproducción, evidencia, causa raíz, corrección, prueba, prevención, análisis sin culpa) para "dos jugadores recibieron la misma compensación".
24. Diseña cómo sería un envío que sobrevive al cierre de la pestaña: qué guardas, dónde, y qué pasa con la ventana de deshacer.

**🔥 Opcionales**

- 🔥 Sustituye `setTimeout` por una cola de trabajos en el servidor. ¿Qué gana el operador y qué pierde la ventana de deshacer?
- 🔥 Reemplaza el tablero de filas por una tabla virtualizada y compara la medición.

---

## 📚 8. Referencias

- Redux Toolkit — `createSlice` y reducers con casos: https://redux-toolkit.js.org/api/createSlice
- React — `React.memo` y `useCallback`: https://legacy.reactjs.org/docs/react-api.html#reactmemo
- React — `useLayoutEffect`: https://legacy.reactjs.org/docs/hooks-reference.html#uselayouteffect
- Cypress — `cy.writeFile` y el imagen `cypress/included`: https://docs.cypress.io/api/commands/writefile
- `A6-redux-clasico-vs-toolkit.md`, para los reducers con casos y `createSlice`.
- `A11-marble-testing.md`, para probar la secuencia de acciones de un flujo asíncrono.

---

## 🚀 9. Cierre y conexión con la Fase 6

El operador manda premios con una ventana para deshacer, cada envío tiene su estado y sus transiciones están en una tabla, y el tablero de diez mil filas tiene un número medido en un navegador. Lo que todavía no existe es la reacción automática al estado: el polling de compras, y la lógica que decide cuándo algo se reintenta. Eso es el epic de la Fase 6.

> **La señal de que quedó bien:** si un compañero abre la consola, manda un premio, lo deshace dentro de la ventana y ve la lista cambiar, la fase cumplió. Si un envío confirmado aparece como fallido, la fase no cumplió, y el incidente 12 explica por qué.

> 🏷️ **No cierres la fase sin el tag.** Con el checklist de la sección 2 en verde:
>
> ```bash
> git tag -a fase-05-envios-manuales -m "F5 cerrada: <el checklist, en una línea por ítem>"
> ```

---

## 📌 Pendientes sugeridos

> Material de autoría, no de lectura.

- **La medición del tablero depende del navegador**: Electron (Chromium) de `cypress/included:10.11.0`, no Chrome instalado. → Decirlo en la cifra publicada; si se necesita Chrome, instalarlo en una imagen propia con versión fijada.
- **La clave de caso del incidente 11** es una regla de negocio que todavía no tiene dueño en la historia. → Preguntar a tesorería antes de fijarla en el servidor.

### Reservas para el cuaderno de incidentes

- **11 ⭐** — *Compensamos dos veces a la misma jugadora* · Concurrencia · 🔴. Sale de la compensación sin clave de caso. Tiene su rama `incidente/11`.
- **12** — *Un envío que ya estaba enviado volvió a "falló"* · Concurrencia · 🟠. Sale del rechazo tardío que escribe el estado sin mirar la transición. Tiene su rama `incidente/12`.
