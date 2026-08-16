# 🧰 Preparaciones de los incidentes — track base
## Tutorial React 16 — Rifas y chances

Este documento **no lo lee el estudiante**. Es material de autoría, como el bloque
📌 de cada fase: contiene el **estado roto** de cada incidente de
`cuaderno-incidentes.md`, o sea exactamente la respuesta que hay que encontrar por
cuenta propia.

> ⚠️ **Si estás haciendo el curso, cierra la pestaña.** Abrir esto es peor que abrir
> la pista 3: la pista 3 te deja la pregunta cuya respuesta es la causa; esto te
> deja el `git diff`.

**Por qué existe.** La sección "Las tres palancas de la preparación" de
[`plantilla-de-incidente.md`](plantilla-de-incidente.md) define **cómo** llega el
sistema roto a tu máquina —una rama `incidente/NN`, el `CHAOS_LEVEL` del mock y el
estado de `mock/db.json`—, y los veinte enunciados declaran las tres. Lo que no
estaba escrito en ninguna parte era **el contenido**: qué línea rompe cada rama y
qué registros hay que sembrar. Sin eso, diecinueve de los veinte incidentes se
quedaban en la línea del `git checkout`.

**Quién lo aplica.** El curso se trabaja sin instructor, así que hay dos formas y
las dos son legítimas:

- **Tú mismo, antes de empezar el mes.** Preparas las diecinueve ramas y los datos
  de una sentada, aplicando las recetas sin leer más de lo necesario, y no vuelves
  a abrir este archivo. Es menos limpio de lo que parece —vas a ver el diff— pero
  funciona sorprendentemente bien: un mes después, en medio de un ticket vago,
  nadie se acuerda de qué línea movió.
- **Quien coordine el onboarding**, si hay alguien. Deja las ramas y los datos
  listos en el repositorio del equipo y el estudiante solo hace `git checkout`. Es
  la forma buena.

Su hermano del track opcional de backend es
[`preparaciones-de-incidentes-be.md`](preparaciones-de-incidentes-be.md), con las
catorce ramas de Go y las formas de preparación propias de aquel lado del cable.

---

## Índice

- [1. Cómo se usa este documento](#1-cómo-se-usa-este-documento)
- [2. Mapa: qué necesita cada incidente](#2-mapa-qué-necesita-cada-incidente)
- [3. Las diecinueve ramas](#3-las-diecinueve-ramas)
- [4. Los datos que hay que sembrar](#4-los-datos-que-hay-que-sembrar)
- [5. El único que se prepara solo con caos](#5-el-único-que-se-prepara-solo-con-caos)
- [6. Verificar que la preparación sirve](#6-verificar-que-la-preparación-sirve)
- [⚠️ Advertencias](#️-advertencias)

---

## 1. Cómo se usa este documento

Cada receta trae cuatro cosas y siempre las mismas:

1. **De dónde sale** — el tag de la fase, con el slug completo
   (`00-convencion-de-git-y-tags.md`).
2. **Qué archivo se toca** — la ruta exacta dentro de `src/`.
3. **El cambio** — el antes y el después, en el estilo del archivo que se toca:
   clases y hooks conviviendo, `connect()` junto a `useSelector`, slices de RTK,
   epics con `.pipe()` e identificadores en inglés.
4. **Cómo comprobar que la preparación quedó bien** — el síntoma que tiene que
   verse. Una preparación que no reproduce el síntoma es peor que ninguna: manda a
   alguien a investigar un bug que no está.

El cambio es siempre **el mínimo que produce el síntoma**. Nada de reescribir un
archivo entero ni de sembrar dos bugs a la vez: una línea movida, un operador
cambiado, un `addCase` comentado. Si una receta pide tocar dos sitios, es porque el
síntoma los necesita a los dos, y lo dice.

Las ramas salen del tag de la fase y se crean así:

```bash
git checkout -b incidente/14 fase-06-redux-observable-a-fondo
# …se aplica el cambio de la receta…
git commit -am "incidente(14): boardRefreshEpic sin takeUntil"
git checkout main
```

> 🧭 **Tu repositorio es tuyo.** Estas ramas salen de los tags que pusiste al cerrar
> cada fase, así que el contenido depende de tu código. Si resolviste un ejercicio
> de otra forma, la línea a tocar puede verse distinta — el `grep` de cada receta la
> encuentra igual.

---

## 2. Mapa: qué necesita cada incidente

| ID | Preparación | Artefacto |
|---|---|---|
| 01 | rama | `incidente/01` + un Node 17+ a mano |
| 02 | rama | `incidente/02` + una segunda arquitectura |
| 03 | rama | `incidente/03` |
| 04 | rama + datos | `incidente/04` + dos rifas distinguibles |
| 05 | rama | `incidente/05` |
| 06 | rama | `incidente/06` (dos archivos) |
| 07 | rama + caos | `incidente/07` + `CHAOS_LEVEL=high` |
| 08 | **solo caos** | `CHAOS_LEVEL=high` |
| 09 | rama | `incidente/09` |
| 10 | rama + caos | `incidente/10` + `CHAOS_LEVEL=high` en la segunda vuelta |
| 11 | rama + datos + caos | `incidente/11` + el `0347` en `reserved` |
| 12 | rama + datos | `incidente/12` + dos rifas que comparten número |
| 13 | rama + caos | `incidente/13` + `CHAOS_LEVEL=high` |
| 14 | rama | `incidente/14` |
| 15 | rama + datos + caos | `incidente/15` + el par `034` / `0347` |
| 16 | rama + datos | `incidente/16` + una rifa con `closesAt` en `-05:00` |
| 17 | rama + caos | `incidente/17` + caos en el `3002` |
| 18 | rama + datos | `incidente/18` + la rifa de a diez centavos |
| 19 | rama + datos | `incidente/19` + `mock/seed-volume.js` |
| 20 | rama | `incidente/20` |

**Diecinueve ramas y un solo incidente que se prepara sin tocar código.** Ese
reparto no es casualidad: el sistema del curso está escrito *bien* —cada fase paga
su deuda o la declara—, así que para que un bug de mantenimiento aparezca hay que
devolverlo a mano. El track BE, en cambio, tiene cuatro incidentes que se
reproducen con el código tal como quedó escrito, porque allá las deudas viven más
tiempo.

> 📝 **Dos de estas ramas no estaban en el enunciado original.** Los incidentes
> **07** y **10** decían "Rama: ninguna, el bug ya está en tu aplicación", y no era
> cierto: la Fase 3 le pone `timeout: 5000` a `apiClient` en el pago de deuda #2, y
> la Fase 4 escribe los cuatro `rejected` desde la primera línea. Sobre el código
> vigente ninguno de los dos se reproduce. Se agregaron sus ramas y se corrigió la
> "🔧 Preparación" de los dos enunciados en el mismo movimiento.

---

## 3. Las diecinueve ramas

### `incidente/01` — el Node que nadie fijó

**Sale de:** `fase-00-setup-hola-mundo-cra`
**Archivo:** `.nvmrc` (se borra)

```bash
git rm .nvmrc
```

La rama no rompe ninguna línea de `src/`: quita la única defensa que tenía el
proyecto contra "el Node que yo tenía puesto". El detonante lo pones tú al
resolverlo, parándote en un Node moderno antes de arrancar:

```bash
nvm use 20      # o cualquier Node 17+
npm start
```

**Queda bien si:** `npm start` muere antes de abrir el navegador con
`error:0308010C:digital envelope routines::unsupported` —a veces disfrazado de
`ERR_OSSL_EVP_UNSUPPORTED`—, el volcado menciona `webpack` y **ninguna línea del
volcado nombra un archivo de `src/`**. Esa última es la que separa este incidente
de un error de código.

---

### `incidente/02` — el `node-sass` que volvió

**Sale de:** `fase-00-setup-hola-mundo-cra`
**Archivo:** `package.json`

```diff
   "dependencies": {
-    "sass": "1.32.5",
+    "node-sass": "4.14.1",
```

```bash
grep -n '"node-sass"\|"sass"' package.json
rm -rf node_modules package-lock.json
```

Es el `package.json` que el curso decidió **no** tener (decisión D11 de
`decisiones-y-versiones.md`), devuelto a su estado de 2021. No hay que tocar
`src/index.scss`: los `@import` de Sass son idénticos para las dos
implementaciones, y que el código de estilos no cambie es justamente parte de la
lección.

**Queda bien si:** en `arm64` (Apple Silicon) el `npm install` falla compilando con
`node-gyp`, con errores de Python o de `binding.gyp` y no de JavaScript; y en
`x64` con Node 14 el mismo `npm install` **funciona**. La receta necesita las dos
máquinas: sin la que funciona, el incidente pierde su mitad interesante. Si solo
tienes una, el contenedor hace de segunda:

```bash
docker run --rm -it -v "$PWD":/app -w /app node:14 bash
```

---

### `incidente/03` — el ancla que destruye el árbol

**Sale de:** `fase-01-estructura-base-router-5`
**Archivo:** `src/components/Navbar.jsx`

```diff
-      <Link className="nav-link" to="/raffles">Rifas</Link>
+      {/* Un enlace "de toda la vida". Lo escribió quien venía de páginas
+          server-side y todavía no había leído el Router. */}
+      <a className="nav-link" href="/raffles">Rifas</a>
```

```bash
grep -n "href=\"/" src/components/Navbar.jsx
```

**Solo uno de los enlaces**, no todos. El incidente vive de que el estudiante
compare el enlace que parpadea con los que no, y si los conviertes todos se queda
sin control.

**Queda bien si:** al hacer clic en "Rifas" la pantalla parpadea, DevTools con
*Preserve log* muestra una petición de tipo `document` seguida del `bundle.js`
entero, y un formulario a medio llenar se vacía. Navegando desde la tabla de
rifas —que sigue con `<Link>`— no aparece ninguna de las dos cosas.

---

### `incidente/04` — el estado que se inicializa una vez

**Sale de:** `fase-01-estructura-base-router-5`
**Archivo:** `src/pages/RaffleDetailPage.jsx`

```diff
   const { id } = useParams();
-  const [raffle, setRaffle] = useState(null);
-
-  useEffect(() => {
-    setRaffle(findRaffle(id));
-  }, [id]);
+  // El inicializador de useState corre UNA sola vez, en el primer montaje.
+  const [raffle, setRaffle] = useState(findRaffle(id));
```

```bash
grep -n "useState(findRaffle\|useEffect" src/pages/RaffleDetailPage.jsx
```

**Datos:** los de §4.1, dos rifas con nombres inconfundibles.

**Queda bien si:** navegando `/raffles` → detalle de la 1 → atrás → detalle de la 2,
el encabezado sigue diciendo "Rifa de Navidad"; la URL dice `/raffles/2`; React
DevTools muestra `useParams` en `"2"` y el estado en la rifa 1 **al mismo tiempo**;
y **F5 lo arregla**. Si el F5 no lo arregla, rompiste otra cosa.

---

### `incidente/05` — el token leído una sola vez

**Sale de:** `fase-02-autenticacion-minima`
**Archivo:** `src/api/apiClient.js`

```diff
+// Se lee una vez, al importar el módulo. "Total, el token no cambia."
+const token = store.getState().auth.token;
+
 apiClient.interceptors.request.use((config) => {
-  const token = getToken();
   if (token) config.headers.Authorization = `Bearer ${token}`;
   return config;
 });
```

```bash
grep -n "getState().auth.token\|getToken()" src/api/apiClient.js
```

Es exactamente lo que la Fase 2 advierte que **no** se hace, con su comentario
("el token NO vive en este módulo") borrado.

**Queda bien si:** el login funciona y Redux DevTools muestra el token en
`auth.token`, y **aun así** ninguna petición posterior lleva el header
`Authorization` en Network. La contradicción entre las dos pantallas es el
incidente entero.

---

### `incidente/06` — el logout a medias y la ruta mal protegida

**Sale de:** `fase-02-autenticacion-minima`
**Archivos:** dos, y los dos hacen falta.

```diff
 // src/features/auth/authSlice.js
     logout(state) {
       state.token = null;
-      state.user = null;
     },
```

```diff
 // src/App.jsx
-      <Route path="/login" component={LoginPage} />
+      <PrivateRoute path="/login" component={LoginPage} />
```

```bash
grep -n -A3 "logout(state)" src/features/auth/authSlice.js
grep -n "path=\"/login\"" src/App.jsx
```

Son **dos bugs distintos que el mismo clic destapa**, y esa es la lección: el
primero deja el nombre del vendedor en la barra, el segundo produce el titileo. Si
preparas solo uno, el estudiante encuentra la mitad y cierra el ticket convencido.

**Queda bien si:** tras el logout la barra superior sigue mostrando el usuario **y**
la pantalla parpadea entre `/login` y sí misma. En DevTools, el *Diff* de la acción
`auth/logout` muestra **una sola clave en verde**.

---

### `incidente/07` — el cliente que espera para siempre

**Sale de:** `fase-03-mock-api-express-caos`
**Archivo:** `src/api/apiClient.js`

```diff
 const apiClient = axios.create({
   baseURL: "http://localhost:3001",
-  timeout: 5000, // clave: sin esto, un timeout del mock cuelga la UI
 });
```

```bash
grep -n "timeout" src/api/apiClient.js      # no tiene que devolver nada
```

El valor por defecto de axios es `0`, que significa *esperar indefinidamente*.
Quitar la línea es devolver el cliente a su estado de la Fase 2, antes de que el
caos existiera y de que alguien se preguntara cuánto es demasiado.

**Caos:** `CHAOS_LEVEL=high` en el `3001`, obligatorio. El fallo de tipo *timeout*
es el que el middleware inyecta sin responder nunca.

**Queda bien si:** recargando `/raffles` varias veces, en alguna la pantalla se
queda en "Cargando rifas…" **sin ningún error en consola**; en Network la petición
figura en estado `(pending)` indefinidamente; y en Redux DevTools la última acción
despachada es `raffles/fetch/pending`, sin `fulfilled` ni `rejected` detrás.

---

### `incidente/09` — el formulario que se envía solo

**Sale de:** `fase-04-rifas-crud`
**Archivo:** `src/features/raffles/RaffleForm.jsx`

```diff
   function handleSubmit(e) {
-    e.preventDefault();
     dispatch(createRaffle(form));
   }
```

```bash
grep -n "preventDefault" src/features/raffles/RaffleForm.jsx
```

**Queda bien si:** al guardar, la página **se recarga entera**, el formulario vuelve
en blanco, el store aparece vacío en DevTools… y la barra de direcciones dice algo
como `/raffles/new?name=Rifa+de+Navidad&closesAt=2026-08-30`. Los datos del usuario,
ahí a la vista. Si la URL no cambia, el `<form>` no tiene `onSubmit` y la rama está
mal aplicada.

---

### `incidente/10` — el `rejected` que falta

**Sale de:** `fase-04-rifas-crud`
**Archivo:** `src/features/raffles/raffleSlice.js`

```diff
       .addCase(fetchRaffles.fulfilled, (state, action) => {
         state.loadingList = false;
         state.items = action.payload;
       })
-      .addCase(fetchRaffles.rejected, (state, action) => {
-        state.loadingList = false;
-        state.error = action.payload;
-      })
```

```bash
grep -n "fetchRaffles.rejected" src/features/raffles/raffleSlice.js
```

**Solo el de `fetchRaffles`.** Los otros tres thunks conservan su rama `rejected`, y
esa asimetría es deliberada: el estudiante que compare los cuatro casos tiene el
diagnóstico servido, y el que no compare va a tardar bastante más.

**Caos:** la primera vuelta se hace con `off` **a propósito** —ahí el incidente no
se reproduce, y ese es su primer entregable—; la segunda con `high`.

**Queda bien si:** con `CHAOS_LEVEL=off` la lista carga siempre y no hay nada que
ver; con `high`, en cuanto un `GET /raffles` devuelve `500`, la pantalla se queda en
"Cargando rifas…" para siempre y DevTools muestra `raffles/fetch/rejected`
despachada con `loadingList` todavía en `true`.

---

### `incidente/11` — el rollback que pisa una venta buena

**Sale de:** `fase-05-venta-de-numeros`
**Archivo:** `src/features/sales/saleSlice.js`

```diff
     numberSoldOptimistic(state, action) {
-      if (state.byNumber[action.payload.number] !== "reserved") return;
       state.byNumber[action.payload.number] = "sold";
     },
     rollbackSale(state, action) {
-      // Solo se revierte lo que sigue siendo nuestro.
-      if (state.byNumber[action.payload.number] !== "sold") return;
       state.byNumber[action.payload.number] = action.payload.previousStatus;
     },
```

```bash
grep -n -A4 "numberSoldOptimistic(state\|rollbackSale(state" src/features/sales/saleSlice.js
```

Son **dos guardas quitadas y el orden importa**: la primera sola solo produce un
repintado cosmético; la segunda es la que fabrica el segundo comprobante. El
incidente necesita las dos para que la secuencia de DevTools se lea completa.

**Caos:** `CHAOS_LEVEL=high`. Sin latencia la ventana entre las dos pestañas es
demasiado estrecha para acertarle a mano.

**Datos:** la rifa 1 en `open` con el `0347` en `reserved` (§4.2).

**Queda bien si:** vendiendo el `0347` casi a la vez desde dos pestañas, una recibe
`200` y la otra `409`, y al final **el tablero muestra el número disponible o
reservado**, no vendido. En Redux DevTools la última acción de la secuencia es
`rollbackSale` con `previousStatus: "reserved"`, despachada **después** del
`fulfilled` de la otra pestaña.

---

### `incidente/12` — el temporizador que sobrevive al desmontaje

**Sale de:** `fase-05-venta-de-numeros`
**Archivo:** `src/features/sales/NumbersBoard.jsx`

```diff
   useEffect(() => {
     scheduleExpiration(dispatch, number, RESERVATION_DURATION_MS);
-    return () => cancelAllExpirations();
   }, [raffleId]);
```

```bash
grep -n -B2 -A6 "scheduleExpiration" src/features/sales/NumbersBoard.jsx
```

La segunda mitad de la causa **no se prepara**: el reducer ya indexa por número y no
por rifa (`state.byNumber['0347']`), que es una decisión de diseño de la Fase 5 y
está así en el código vigente. Por eso la expiración de una rifa aterriza sobre el
tablero de otra, y por eso la frase del ticket *"también lo vi en otra rifa"* es el
bug describiéndose solo.

**Caos:** `low`. Con `high` los fallos de venta mezclan la causa B —el rollback del
incidente 11— y cuesta separarlas.

**Datos:** dos rifas en `open` que **compartan el número** `0347` (§4.3).

**Queda bien si:** reservas el `0347` en la rifa 1, navegas a la rifa 2 y, unos
minutos después y sin tocar nada, aparece en DevTools un `reservationExpired` con el
`raffleId` de la rifa **vieja**, y el `0347` de la rifa 2 se pone disponible. Y la
comprobación que lo confirma: **en Network no hay ninguna petición** al lado de esa
acción.

---

### `incidente/13` — el epic que dejó de existir

**Sale de:** `fase-06-redux-observable-a-fondo`
**Archivo:** `src/features/sales/epics/sellNumberEpic.js`

```diff
     switchMap(({ payload }) =>
       from(api.sellNumber(payload)).pipe(
-        map((res) => sellNumberFulfilled(res.data)),
-        catchError((err) => of(sellNumberRejected(toReadableError(err))))
+        map((res) => sellNumberFulfilled(res.data))
       )
     )
```

```bash
grep -n "catchError" src/features/sales/epics/sellNumberEpic.js
```

**Caos:** `CHAOS_LEVEL=high`, obligatorio: hace falta que una venta falle de verdad.

**Queda bien si:** tras la primera venta fallida **no vuelve a salir ninguna
petición de venta** —cero en Network—, las acciones `SELL_NUMBER` se siguen viendo
en DevTools sin nada del otro lado, y, si lo compruebas, la validación del número en
tiempo real también dejó de responder. Ese daño colateral es parte del incidente:
`combineEpics` usa `merge`, y un error que mata a uno mata a todos.

---

### `incidente/14` — el `interval` que nadie corta

**Sale de:** `fase-06-redux-observable-a-fondo`
**Archivo:** `src/features/sales/epics/boardRefreshEpic.js`

```diff
     switchMap(({ payload }) =>
       interval(BOARD_REFRESH_MS).pipe(
-        map(() => fetchNumbers(payload.raffleId)),
-        takeUntil(action$.pipe(ofType("STOP_BOARD_REFRESH", "auth/logout")))
+        map(() => fetchNumbers(payload.raffleId))
       )
     )
```

```bash
grep -n "takeUntil" src/features/sales/epics/boardRefreshEpic.js
```

Es textualmente la "versión con leak" que la Fase 6 §5.8 muestra para explicar el
`takeUntil`, con el comentario de advertencia quitado.

**Queda bien si:** entras, abres el tablero de la rifa 3, cierras sesión y **no
tocas nada**: en Network siguen saliendo `GET /raffles/3/numbers` cada cinco
segundos, y salen **sin el header `Authorization`**, porque el interceptor lee el
store en cada petición y ahí ya no hay token. Si dejas la pestaña abierta diez
minutos, el log del mock tiene la prueba de las tres de la mañana.

---

### `incidente/15` — el `mergeMap` que no cancela

**Sale de:** `fase-06-redux-observable-a-fondo`
**Archivo:** `src/features/sales/epics/validateNumberEpic.js`

```diff
     debounceTime(300),
-    switchMap(({ payload }) =>
+    mergeMap(({ payload }) =>
       from(api.validateNumber(payload)).pipe(
```

```bash
grep -n "mergeMap\|switchMap" src/features/sales/epics/validateNumberEpic.js
```

**Caos:** `CHAOS_LEVEL=high`, y el motivo es preciso: con latencia uniforme las
respuestas vuelven en orden y el bug se esconde. Lo que lo destapa es que la
respuesta de `034` tarde **más** que la de `0347`.

**Datos:** una rifa en `open` con el `034` en `sold` y el `0347` en `available`
(§4.4). Sin ese par, las dos respuestas dicen lo mismo y no hay síntoma.

**Queda bien si:** escribiendo `0347` a velocidad normal en el campo de venta, cada
tanto el cartel dice "número no disponible" sobre un número que **sí** lo está. En
Network se ven dos validaciones vivas al mismo tiempo y la del prefijo corto
respondiendo última.

---

### `incidente/16` — la hora desarmada en componentes

**Sale de:** `fase-07-cierre-polling-resultado`
**Archivo:** `src/features/raffles/closing.js`

```diff
 export function isPastClosing(closesAt) {
-  return new Date().getTime() >= new Date(closesAt).getTime();
+  // "Comparar las horas" — lo natural, y por eso sobrevivió dos años.
+  const closing = new Date(closesAt);
+  return new Date().getHours() >= closing.getHours();
 }
```

```bash
grep -n "getHours\|getTime" src/features/raffles/closing.js
```

**Datos:** una rifa con `closesAt` en `2026-08-30T20:00:00-05:00` y números todavía
disponibles (§4.5).

**Cómo se ve el síntoma sin mudarte de provincia:** el navegador toma la zona del
sistema operativo, así que se cambia ahí — o se arranca el dev server con `TZ`
puesto, que es lo más rápido:

```bash
TZ=America/Bogota  npm start     # el vendedor de la capital: cierra a las 20:00
TZ=America/Santiago npm start    # el de la costa: para él son otras horas
```

**Queda bien si:** con las dos zonas, y a la misma hora real, **un navegador ofrece
el botón de vender y el otro no**. Ese desacuerdo entre dos máquinas frente al mismo
dato es la firma del incidente, y es la misma forma de razonar del 02 y del 20.

---

### `incidente/17` — el `catchError` que mata al `timer`

**Sale de:** `fase-07-cierre-polling-resultado`
**Archivo:** `src/features/raffles/epics/pollingEpic.js`

```diff
     switchMap(({ payload }) =>
       timer(0, POLLING_INTERVAL_MS).pipe(
-        mergeMap(() =>
-          from(apiLottery.get(`/results/${payload.raffleId}`)).pipe(
-            map((res) => resultReceived(res.data)),
-            catchError((err) => of(pollingFailed(err)))
-          )
-        ),
+        mergeMap(() => from(apiLottery.get(`/results/${payload.raffleId}`))),
+        map((res) => resultReceived(res.data)),
         takeUntil(action$.pipe(ofType("STOP_POLLING"))),
+        // El catchError de afuera: atrapa el error y completa lo que envuelve.
+        catchError((err) => of(pollingFailed(err)))
       )
     )
```

```bash
grep -n -A3 "catchError" src/features/raffles/epics/pollingEpic.js
```

El `catchError` **no se borra: se muda para afuera**. Que siga estando es lo que
vuelve difícil el incidente — el estudiante lo ve, comprueba que existe, y tiene que
entender que el problema es *dónde* está.

**Caos:** `CHAOS_LEVEL=high` en el mock de lotería del **`3002`**, no en el `3001`.
Confundir los dos puertos es el error de preparación más frecuente de este
incidente.

**Queda bien si:** al primer `500` de la lotería los `GET /results/:id` **paran y no
vuelven nunca**, la pantalla se queda en "esperando resultado", y en el store no hay
nada nuevo tras el corte. Si los `GET` siguen saliendo, preparaste la causa B —el
`204` tratado como error— que es el otro final posible y no el de este ticket.

---

### `incidente/18` — la aritmética en pesos

**Sale de:** `fase-08-liquidacion-calculo-premio`
**Archivo:** `src/features/settlements/settlementMath.js`

La versión rota es la de la pieza forense de la Fase 8 —floats contra enteros— y
la reserva del incidente ya le puso nombre: `calculateTotalCollectedBroken`. La
rama la deja escrita al lado de la buena y **conecta el panel a ella**, que es lo
que el ejercicio 18 de la fase hace "temporalmente" y alguien se olvidó de
deshacer.

```diff
 // src/features/settlements/settlementMath.js
+// 💸 La cuenta en pesos, como se hacía antes de A10. Se dejó "para comparar".
+export function calculateTotalCollectedBroken({ soldCount, numberPriceInPesos }) {
+  const totalInPesos = soldCount * numberPriceInPesos;
+  return Math.round(totalInPesos * 100);
+}
```

```diff
 // src/features/settlements/SettlementPanel.jsx
-import { calculateTotalCollected, calculatePrize, calculateMargin } from "./settlementMath";
+import { calculateTotalCollectedBroken, calculatePrize, calculateMargin } from "./settlementMath";
…
-  const totalCollected = calculateTotalCollected({
-    soldCount: soldNumbers.length,
-    numberPrice: raffle.numberPrice,
-  });
+  const totalCollected = calculateTotalCollectedBroken({
+    soldCount: soldNumbers.length,
+    numberPriceInPesos: raffle.numberPriceInPesos,
+  });
```

```bash
grep -rn "calculateTotalCollectedBroken" src/features/settlements/
```

**Datos, y son exactos:** la rifa de a diez centavos con tres números vendidos
(§4.6). Sin esos números el error de representación no sale a la superficie y la
liquidación cuadra.

**Queda bien si:** la liquidación de esa rifa difiere en **un centavo** del total de
las ventas, y la misma cuenta en una consola de Node lo confirma sin abrir el
navegador:

```bash
node -e "console.log(3 * 0.1 * 100)"   # 30.000000000000004
```

Si el descuadre es de más de un centavo, sembraste mal los datos: el incidente vive
de que la diferencia sea ridícula y aun así innegociable.

---

### `incidente/19` — la memoización que no memoiza

**Sale de:** `fase-09-dashboard`
**Archivo:** `src/features/dashboard/DashboardPage.jsx`

```diff
-  const topNumbers = useSelector(selectTopSoldNumbers);
+  const byNumber = useSelector((state) => state.sales.byNumber);
+  const topNumbers = useMemo(
+    () => computeTopNumbers(byNumber),
+    [Object.values(byNumber)]   // "las dependencias, por si acaso"
+  );
```

```bash
grep -n "useMemo\|selectTopSoldNumbers" src/features/dashboard/DashboardPage.jsx
```

La rama **devuelve el dashboard a mano** el cálculo que la Fase 9 había movido a un
selector memoizado. Es el error común #1 de esa fase, y su gracia es que la
memoización está ahí, prolijamente escrita, en la línea correcta.

**Datos:** volumen. Con tres rifas de demostración no se nota nada (§4.7).

**Queda bien si:** con el store cargado, un `console.count("computeTopNumbers")`
dentro de la función pura marca **una vuelta por render**, y el *Profiler* de React
DevTools mide el render del dashboard en cientos de milisegundos. Con pocos datos
tiene que verse rápido: que el síntoma dependa del volumen es la mitad del ticket
("a la mañana vuela y a la tarde no").

---

### `incidente/20` — el componente que consulta el reloj

**Sale de:** `fase-09-dashboard`
**Archivo:** `src/features/dashboard/MetricCard.jsx`

```diff
-export default function MetricCard({ label, date, now }) {
-  const isToday = isSameDay(new Date(date), now);
+export default function MetricCard({ label, date }) {
+  // "Hoy es hoy, para qué pasarlo por props."
+  const isToday = isSameDay(new Date(date), new Date());
```

```bash
grep -n "new Date()" src/features/dashboard/MetricCard.jsx
```

El test de la Fase 10 —que asegura un texto de fecha concreto— **no se toca**. Que
el test siga siendo el mismo es el corazón del incidente: no se rompió la prueba, se
rompió el componente, y la prueba lo descubrió.

**Queda bien si:** las dos corridas dan resultados distintos y **cada una de forma
determinista**, el 100% y el 0% de las veces:

```bash
npm test -- MetricCard            # tu zona horaria: pasa
TZ=UTC npm test -- MetricCard     # la del runner: falla
```

Si falla a veces en el **mismo** ambiente, preparaste otra cosa: eso sí sería un
test flaky, y el incidente 20 existe justamente para enseñar a no confundirlos.

---

## 4. Los datos que hay que sembrar

Los datos viven en `mock/db.json`, que **está versionado** —es dato semilla del
curso, no un artefacto generado—, así que el ciclo de siempre funciona:

```bash
git checkout -- mock/db.json     # tablero limpio antes de sembrar
```

Cada estado de abajo se aplica sobre el `db.json` de la fase que corresponda, y
cambia **solo** los registros que el incidente necesita. Nada de un archivo escrito
a mano desde cero: el resto del sistema tiene que seguir cuadrando.

> 💡 **Cuándo va en la rama y cuándo no.** Si el dato es parte del estado roto
> —§4.6, la rifa de a diez centavos— se commitea en la rama del incidente y viaja
> con ella. Si es solo escenario —§4.1, dos rifas con nombres distintos— puede
> quedarse en `main` sin molestar a nadie.

### 4.1 Dos rifas distinguibles (incidente 04)

```jsonc
"raffles": [
  { "id": 1, "name": "Rifa de Navidad",  "lotteryId": "boyaca",
    "closesAt": "2026-12-20T20:00:00-05:00",
    "numberPrice": 5000, "basePrize": 500000, "status": "open" },
  { "id": 2, "name": "Rifa de Año Nuevo", "lotteryId": "boyaca",
    "closesAt": "2026-12-30T20:00:00-05:00",
    "numberPrice": 5000, "basePrize": 500000, "status": "open" }
]
```

Los nombres tienen que ser **inconfundibles a un metro de la pantalla**. Con "Rifa
1" y "Rifa 2" el síntoma existe igual y no se ve.

### 4.2 El `0347` reservado (incidente 11)

```jsonc
"numbers": [
  { "raffleId": 1, "number": "0347", "status": "reserved" },
  { "raffleId": 1, "number": "1500", "status": "available" }
]
```

El estado de partida es `reserved` y no `available` porque el `previousStatus` que
captura el rollback es justamente ese: si el número arranca disponible, el rollback
lo devuelve a disponible y el síntoma se lee peor.

### 4.3 Dos rifas que comparten número (incidente 12)

Las dos rifas de §4.1, y en las dos el mismo número:

```jsonc
"numbers": [
  { "raffleId": 1, "number": "0347", "status": "available" },
  { "raffleId": 2, "number": "0347", "status": "sold" }
]
```

**Que el número se repita entre rifas es el incidente.** El reducer indexa por
número —`state.byNumber['0347']`— y ahí es donde la expiración de una aterriza sobre
la otra.

### 4.4 El par `034` / `0347` (incidente 15)

```jsonc
"numbers": [
  { "raffleId": 1, "number": "034",  "status": "sold" },
  { "raffleId": 1, "number": "0347", "status": "available" }
]
```

Uno es prefijo del otro **y tienen estados opuestos**. Esas dos condiciones juntas
son las que hacen que la respuesta vieja contradiga a la nueva; con estados iguales,
el `mergeMap` sigue estando mal y no se nota.

### 4.5 La rifa que cierra a las 20:00 (incidente 16)

```jsonc
{ "id": 1, "name": "Rifa fin de mes", "lotteryId": "boyaca",
  "closesAt": "2026-08-30T20:00:00-05:00",
  "numberPrice": 5000, "basePrize": 500000, "status": "open" }
```

**El offset explícito no es decorativo**: es el dato que hace que dos navegadores en
zonas distintas lean el mismo instante y muestren horas diferentes. Un `closesAt` en
`Z`, o sin offset, cambia el incidente.

### 4.6 La rifa de a diez centavos (incidente 18)

```jsonc
{ "id": 7, "name": "Rifa de la esquina", "lotteryId": "boyaca",
  "closesAt": "2026-08-30T20:00:00-05:00",
  "numberPrice": 10,
  "numberPriceInPesos": 0.1,
  "basePrize": 100000, "status": "closed" }
```

Con **tres** números vendidos, ni uno más:

```jsonc
{ "raffleId": 7, "number": "0001", "status": "sold" },
{ "raffleId": 7, "number": "0002", "status": "sold" },
{ "raffleId": 7, "number": "0003", "status": "sold" }
```

El campo `numberPriceInPesos` **lo agrega la rama** y es lo único que el sistema
sano no tiene: en el código vigente los precios viven en centavos enteros
(`numberPrice`) y nadie los divide. Tres por diez centavos es el caso más barato
donde el error de la IEEE 754 sale a la superficie, y por eso son tres y no
doscientos.

### 4.7 El volumen del dashboard (incidente 19)

Con tres rifas no hay incidente. Hace falta un `db.json` grande, y se genera:

```javascript
// mock/seed-volume.js
// Doce mil ventas repartidas en veinte rifas: el final de un día bueno.
// Determinista a propósito — con Math.random(), el "antes y después" del
// Profiler deja de ser comparable.
const fs = require("fs");

const db = JSON.parse(fs.readFileSync("mock/db.json", "utf8"));
const numbers = [];
let seed = 42;
const next = () => (seed = (seed * 1103515245 + 12345) % 2147483648);

for (let raffleId = 1; raffleId <= 20; raffleId++) {
  for (let i = 0; i < 600; i++) {
    numbers.push({
      raffleId,
      number: String(next() % 10000).padStart(4, "0"),
      status: "sold",
      participantId: (next() % 300) + 1,
    });
  }
}

db.numbers = numbers;
fs.writeFileSync("mock/db.volume.json", JSON.stringify(db, null, 2));
console.log(`sembrados ${numbers.length} números en 20 rifas`);
```

```bash
node mock/seed-volume.js
cp mock/db.volume.json mock/db.json      # y al terminar: git checkout -- mock/db.json
```

---

## 5. El único que se prepara solo con caos

El **incidente 08** —"me saca a login al azar mientras estoy trabajando"— no lleva
rama ni datos especiales, y eso es exactamente lo que enseña: el `401` lo inyecta el
middleware de caos de `mock/server.js` sobre `PROTECTED_ROUTES`, tal como la Fase 3
lo escribió, y **eso no es el bug**. Un backend real hace lo mismo cuando la sesión
expira. El defecto está en cómo reacciona el interceptor, que es código sano en el
sentido de que hace lo que dice.

```bash
CHAOS_LEVEL=high npm run mock:api
npm start
```

**Queda bien si:** empiezas a llenar el formulario de una rifa nueva, sigues
navegando, y en algún momento aterrizas en `/login` **sin ningún mensaje** y sin lo
que estabas escribiendo. Si tarda demasiado en pasar, es cuestión de insistir: el
`401` es aleatorio y el ticket dice "al azar" por algo.

---

## 6. Verificar que la preparación sirve

Antes de dar por lista una rama, tres comprobaciones que cuestan un minuto y evitan
mandar a alguien a investigar un bug que no está:

1. **El síntoma aparece**, y aparece como lo describe el ticket. No "algo falla":
   *eso* falla.
2. **El resto del sistema sigue en pie.** Un `npm test` en la rama del incidente
   tiene que fallar en lo que el incidente rompió y en nada más. Si caen ocho
   pruebas, el cambio no fue mínimo.
3. **El diff cabe en una pantalla.** Si `git diff main...incidente/NN` no entra en
   veinte líneas, revisa: casi siempre significa que arrastraste cambios de fases
   posteriores al salir del tag equivocado.

```bash
git diff --stat fase-06-redux-observable-a-fondo...incidente/14
```

---

## ⚠️ Advertencias

- **No abras este archivo mientras resuelves.** Ya está dicho arriba y se repite
  acá porque es la única regla que importa.
- **Los datos de las recetas son los del `db.json` del curso.** Si resolviste un
  ejercicio que cambió la semilla, ajusta el dato o ajusta el enunciado, pero que
  coincidan: los enunciados nombran números concretos (`0347`, `034`, la rifa 7).
- **Las ramas no se mezclan entre sí.** Cada una sale de su tag de fase y vive
  sola. Encadenar dos incidentes en la misma rama produce síntomas cruzados que no
  corresponden a ningún ticket.
- **No borres las ramas al terminar.** Son la única copia del estado roto, y el par
  de tags `inc/<ID>/<slug>-roto` / `-fix` de `00-convencion-de-git-y-tags.md`
  cuenta lo otro: cómo saliste.
- **Si una receta no reproduce el síntoma en tu repo, gana tu repo.** El código es
  tuyo y estas recetas describen el del curso. Ajusta la línea, no el enunciado — y
  si el ajuste es grande, probablemente saliste del tag equivocado.
