# 🧰 Preparaciones de los incidentes — track base
## Tutorial React 16 — La Esclusa, la consola de Jewel Locks

Este documento **no lo lee el estudiante**. Es material de autoría, como el bloque
📌 de cada fase: contiene el **estado roto** de cada incidente de
`cuaderno-incidentes.md`, o sea exactamente la respuesta que hay que encontrar por
cuenta propia.

> ⚠️ **Si estás haciendo el curso, cierra la pestaña.** Abrir esto es peor que abrir
> la pista 3: la pista 3 te deja la pregunta cuya respuesta es la causa; esto te
> deja el `git diff`.

> 🧭 **Estado de este documento (P6, 14/10/2026): especificación.** Cada rama está
> escrita sobre el contrato de nombres de la reescritura (`propuesta-fases-y-alcance.md`
> §2 y `diccionario-codigo-ingles.md`). Lo que dice qué se rompe, con qué datos y
> cómo se ve el síntoma es el compromiso de P6. **La forma exacta del diff y la línea
> se fijan en la tanda que escribe la fase** (T1–T6), con el código ya corrido en el
> repo de prueba; ahí se corrige esta página. Hasta entonces, un `grep` que no
> encuentre la línea indicada es señal de que la rama se fija tarde, no de que haya
> que inventarla.

**Por qué existe.** La sección "Las tres palancas de la preparación" de
[`plantilla-de-incidente.md`](plantilla-de-incidente.md) define **cómo** llega el
sistema roto a tu máquina —una rama `incidente/NN`, el `CHAOS_LEVEL` del mock y el
estado de `mock/db.json`—, y los enunciados declaran las tres. Lo que no estaba
escrito en ninguna parte era **el contenido**: qué línea rompe cada rama y qué
registros hay que sembrar.

**Quién lo aplica.** El curso se trabaja sin instructor, así que hay dos formas y
las dos son legítimas:

- **Tú mismo, antes de empezar el mes.** Preparas las ramas y los datos de una
  sentada, aplicando las recetas sin leer más de lo necesario. Es menos limpio de lo
  que parece, pero funciona: un mes después, en medio de un ticket vago, nadie se
  acuerda de qué línea movió.
- **Quien coordine el onboarding**, si hay alguien. Deja las ramas y los datos
  listos en el repositorio del equipo y el estudiante solo hace `git checkout`. Es
  la forma buena.

Su hermano del track opcional de backend es
[`preparaciones-de-incidentes-be.md`](preparaciones-de-incidentes-be.md), con las
ramas de Go y las formas de preparación propias de aquel lado del cable.

---

## Índice

- [1. Cómo se usa este documento](#1-cómo-se-usa-este-documento)
- [2. Mapa: qué necesita cada incidente](#2-mapa-qué-necesita-cada-incidente)
- [3. Las ramas](#3-las-ramas)
- [4. Los datos que hay que sembrar](#4-los-datos-que-hay-que-sembrar)
- [5. Los que se preparan solo con caos o con el mock](#5-los-que-se-preparan-solo-con-caos-o-con-el-mock)
- [6. Verificar que la preparación sirve](#6-verificar-que-la-preparación-sirve)
- [⚠️ Advertencias](#️-advertencias)

---

## 1. Cómo se usa este documento

Cada receta trae cuatro cosas y siempre las mismas:

1. **De dónde sale**: el tag de la fase, con el slug nuevo
   (`00-convencion-de-git-y-tags.md`).
2. **Qué archivo se toca**: la ruta dentro de `src/`, con el nombre que tiene en la
   reescritura.
3. **El cambio**: qué se rompe y el mínimo que lo produce. El diff exacto se fija en
   la tanda.
4. **Cómo comprobar que la preparación quedó bien**: el síntoma que tiene que verse.
   Una preparación que no reproduce el síntoma es peor que ninguna: manda a alguien a
   investigar un bug que no está.

El cambio es siempre **el mínimo que produce el síntoma**. Nada de reescribir un
archivo entero ni de sembrar dos bugs a la vez: una línea movida, un operador
cambiado, un `addCase` comentado. Si una receta pide tocar dos sitios, es porque el
síntoma los necesita a los dos, y lo dice.

Las ramas salen del tag de la fase y se crean así:

```bash
git checkout -b incidente/14 fase-07-cierre-polling-compras
# …se aplica el cambio de la receta…
git commit -am "incidente(14): pollingPurchasesEpic sin takeUntil"
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
| 04 | rama + datos | `incidente/04` + dos ruedas distinguibles |
| 05 | rama | `incidente/05` |
| 06 | rama | `incidente/06` (dos archivos) |
| 07 | rama + caos | `incidente/07` + `CHAOS_LEVEL=high` |
| 08 | **solo caos** | `CHAOS_LEVEL=high` |
| 09 | rama | `incidente/09` |
| 10 | rama + caos | `incidente/10` + `CHAOS_LEVEL=high` en la segunda vuelta |
| 11 ⭐ | rama | `incidente/11` (con `GRANT_DELIVERY_MS` alto, si se quiere más margen para el doble clic) |
| 12 | rama | `incidente/12` (el envío confirmado se crea en la reproducción) |
| 13 | rama + caos | `incidente/13` + `CHAOS_LEVEL=high` |
| 14 ⭐ | rama + mock | `incidente/14` (dos archivos) + `PLAY_PENDING_MS` alto en el `3002` |
| 15 | rama + datos + caos | `incidente/15` + el par de jugadoras con nombre prefijo |
| 16 | rama + datos | `incidente/16` + la rueda 4 con `closesAt` en `-05:00` + `TZ` |
| 17 | rama + caos | `incidente/17` + caos en el `3002` |
| 18 | rama + datos | `incidente/18` + la siembra de la fase (el paquete de 20,99 USD por 500 giros) |
| 19 | rama + datos | `incidente/19` + la siembra `--event` (180.000 giros) |
| 20 | rama | `incidente/20` |
| 21 ➕ | datos | sin rama de commit: la siembra `--accommodating` (la bitácora de la regla vieja) |

**Veinte ramas y dos incidentes que se preparan sin tocar código.** El 08 se prepara
con caos, y el 21 con un dato del mock: el sistema del curso está escrito *bien*
—cada fase paga su deuda o la declara—, así que para que un bug de mantenimiento
aparezca hay que devolverlo a mano. El 21 es distinto: no es un defecto de código
sino de la rueda, y termina en diagnóstico, no en commit (DR-03).

> 📝 **Dos de estas ramas no estaban en el enunciado original.** Los incidentes
> **07** y **10** decían "Rama: ninguna, el bug ya está en tu aplicación", y no era
> cierto: la Fase 3 le pone `timeout: 5000` a `apiClient` en el pago de deuda #2, y
> la Fase 4 escribe los `rejected` desde la primera línea. Sobre el código vigente
> ninguno de los dos se reproduce. Se agregaron sus ramas y se corrigió la
> "🔧 Preparación" de los dos enunciados en el mismo movimiento.

---

## 3. Las ramas

### `incidente/01` — el Node que nadie fijó

**Sale de:** `fase-00-setup-hola-mundo-cra`
**Archivo:** `.nvmrc` (se borra)

La rama no rompe ninguna línea de `src/`: quita la única defensa que tenía el
proyecto contra "el Node que yo tenía puesto". El detonante lo pones tú al
resolverlo, parándote en un Node moderno antes de arrancar (`nvm use 20`, o cualquier
Node 17+, y `npm start`).

**Queda bien si:** `npm start` muere antes de abrir el navegador con
`error:0308010C:digital envelope routines::unsupported` —a veces disfrazado de
`ERR_OSSL_EVP_UNSUPPORTED`—, el volcado menciona `webpack` y **ninguna línea del
volcado nombra un archivo de `src/`**. Esa última es la que separa este incidente de
un error de código.

### `incidente/02` — el `node-sass` que volvió

**Sale de:** `fase-00-setup-hola-mundo-cra`
**Archivo:** `package.json`

Se cambia `sass` (1.32.5, decisión de `00-decisiones-y-versiones.md`) por `node-sass`
(4.14.1) en las dependencias, y se borran `node_modules` y el lockfile. No hay que
tocar `src/index.scss`: los `@import` son idénticos para las dos implementaciones, y
que el código de estilos no cambie es justamente parte de la lección.

**Queda bien si:** en `arm64` (Apple Silicon) el `npm install` falla compilando con
`node-gyp`, con errores de Python o de `binding.gyp` y no de JavaScript; y en `x64`
con Node 14 el mismo `npm install` **funciona**. La receta necesita las dos máquinas:
sin la que funciona, el incidente pierde su mitad interesante. Si solo tienes una, el
contenedor hace de segunda (`docker run --rm -it -v "$PWD":/app -w /app node:14 bash`).

### `incidente/03` — el ancla que destruye el árbol

**Sale de:** `fase-01-estructura-base-router-5`
**Archivo:** `src/components/Navbar.jsx`

Un solo enlace del menú (el de *Ruedas*) pasa de `<Link>` a `<a href>`. El
incidente vive de que el estudiante compare el enlace que parpadea con los que no, y
si los conviertes todos se queda sin control.

**Queda bien si:** al hacer clic en *Ruedas* la pantalla parpadea, DevTools con
*Preserve log* muestra una petición de tipo `document` seguida del `bundle.js`
entero, y un formulario a medio llenar se vacía. Navegando desde la tabla de ruedas
—que sigue con `<Link>`— no aparece ninguna de las dos cosas.

### `incidente/04` — el estado que se inicializa una vez

**Sale de:** `fase-01-estructura-base-router-5`
**Archivo:** `src/pages/WheelDetailPage.jsx`

El detalle de la rueda deja de sincronizarse con `:id`: el estado se inicializa con
la rueda del primer montaje y el `useEffect` que lo actualiza se quita. Es el mismo
patrón de la rama antigua, con el nombre nuevo.

**Datos:** los de §4.1, dos ruedas con nombres inconfundibles.

**Queda bien si:** navegando `/wheels` → detalle de la 1 → atrás → detalle de la 2,
el encabezado sigue diciendo *Rueda del Canal*; la URL dice `/wheels/2`; React
DevTools muestra `useParams` en `"2"` y el estado en la rueda 1 **al mismo tiempo**;
y **F5 lo arregla**. Si el F5 no lo arregla, rompiste otra cosa.

### `incidente/05` — el token leído una sola vez

**Sale de:** `fase-02-autenticacion-minima`
**Archivo:** `src/api/apiClient.js`

El token se lee una vez, al importar el módulo, en vez de en cada petición. Es
exactamente lo que la Fase 2 advierte que **no** se hace.

**Queda bien si:** el login funciona y Redux DevTools muestra el token en
`auth.token`, y **aun así** ninguna petición posterior lleva el header
`Authorization` en Network. La contradicción entre las dos pantallas es el
incidente entero.

### `incidente/06` — el logout a medias y la ruta mal protegida

**Sale de:** `fase-02-autenticacion-minima`
**Archivos:** dos, y los dos hacen falta: `src/features/auth/authSlice.js` (el
`logout` deja de borrar `user`) y `src/App.jsx` (la ruta de `/login` pasa a
`PrivateRoute`).

Son **dos bugs distintos que el mismo clic destapa**: el primero deja el nombre del
operador en la barra, el segundo produce el titileo. Si preparas solo uno, el
estudiante encuentra la mitad y cierra el ticket convencido.

**Queda bien si:** tras el logout la barra superior sigue mostrando el usuario **y**
la pantalla parpadea entre `/login` y sí misma. En DevTools, el *Diff* de la acción
`auth/logout` muestra **una sola clave en verde**.

### `incidente/07` — el cliente que espera para siempre

**Sale de:** `fase-03-mock-api-express-caos`
**Archivo:** `src/api/apiClient.js`

Se quita el `timeout` de `apiClient`. El valor por defecto de axios es `0`, que
significa *esperar indefinidamente*. Quitar la línea es devolver el cliente a su
estado de la Fase 2, antes de que el caos existiera.

**Caos:** `CHAOS_LEVEL=high` en el `3001`, obligatorio. El fallo de tipo *timeout* es
el que el middleware inyecta sin responder nunca.

**Queda bien si:** recargando `/wheels` varias veces, en alguna la pantalla se queda
en "Cargando ruedas…" **sin ningún error en consola**; en Network la petición figura
en `(pending)` indefinidamente; y en Redux DevTools la última acción es
`wheels/fetch/pending`, sin `fulfilled` ni `rejected` detrás.

### `incidente/08` — el `401` al azar

**Sin rama.** Ver §5: el 08 se prepara solo con caos.

### `incidente/09` — el formulario que se envía solo

**Sale de:** `fase-04-ruedas-crud`
**Archivo:** `src/features/wheels/WheelForm.jsx`

Se quita el `e.preventDefault()` de `handleSubmit`.

**Queda bien si:** al crear una rueda, la página **se recarga entera**, el formulario
vuelve en blanco… y la barra de direcciones muestra los datos del formulario en la
query (`/wheels?name=…&closesAt=…&weight-sin-premio=…`). Si la URL no cambia, el
`<form>` no tiene `onSubmit` y la rama está mal aplicada. La prueba de regresión del
cuaderno falla con `Expected: true`, `Received: false`.

### `incidente/10` — el `rejected` que falta

**Sale de:** `fase-04-ruedas-crud`
**Archivo:** `src/features/wheels/wheelSlice.js`

Se quita el caso `fetchWheels.rejected`. Solo ese: los otros tres thunks conservan su
rama `rejected`, y esa asimetría es deliberada: el estudiante que compare los cuatro
casos tiene el diagnóstico servido.

**Caos:** la primera vuelta se hace con `off` **a propósito** —ahí el incidente no se
reproduce, y ese es su primer entregable—; la segunda con `high`.

**Queda bien si:** con `CHAOS_LEVEL=off` la lista carga siempre y no hay nada que
ver; con `high`, en cuanto un `GET /wheels` devuelve `503`, la pantalla se queda en
"Cargando ruedas…" para siempre y DevTools muestra `wheels/fetch/rejected` despachada
con `loadingList` todavía en `true`. La prueba de regresión falla con
`Expected: false`, `Received: true`.

### `incidente/11` ⭐ — el envío que sale dos veces

**Sale de:** `fase-05-envios-manuales`
**Archivo:** `src/features/grants/grantSlice.js`

Se quitan las dos guardas de origen del envío: el `condition` de `sendGrant` (solo se
manda lo que está en `queued` o `failed`) y la transición de `grantSent` (solo se pinta
`sent` desde `sending`), que pasa a asignar `sent` sin preguntar. «Enviar ahora» sigue
visible mientras el envío no está confirmado (es así en la fase), así que un doble clic
manda dos veces el mismo envío.

**Caos:** `off`. La ventana la da el mock: `registerGrant` comprueba el caso, espera
`GRANT_DELIVERY_MS` (800 ms) y recién después anota. Con `GRANT_DELIVERY_MS=3000` el
doble clic entra holgado.

**Datos:** los de la fase (jugadores 42 y 43; `grants` vacía). El caso lo escribe el
estudiante en el asistente (`C-2210` en el enunciado).

**Queda bien si:** después del doble clic, `GET /grants?caseId=C-2210` devuelve **dos**
registros del mismo caso y jugador, y Redux DevTools muestra dos `grants/send/pending`
y dos `grants/grantSent` para el mismo `grantId`. Se reproduce en **una** pestaña: con
dos pestañas (dos operadores) se ve solo la mitad del servidor, porque cada pestaña
tiene su propio store. La prueba de regresión falla con `Expected: 1`, `Received: 2`.

### `incidente/12` — el rollback que pisa una confirmación

**Sale de:** `fase-05-envios-manuales`
**Archivo:** `src/features/grants/grantSlice.js`

`rollbackGrant` busca el envío por caso y jugador en vez de por id, y deja de respetar
`confirmed`. El rollback del envío masivo encuentra el envío individual del mismo caso,
ya confirmado, y lo pasa a `failed`.

**Datos:** los de la fase. El envío confirmado se crea en la reproducción: primero un
envío individual a Juan (caso `C-2210`), que queda "Enviado"; después un envío masivo
a Juan y María con el mismo caso, con «Enviar todos ahora». El `409` del de Juan lo da
el propio mock.

**Queda bien si:** el envío individual, que figuraba "Enviado", pasa a "Falló" con
"Ese caso ya fue compensado para este jugador."; el del masivo se queda "Enviado (sin
confirmar)"; y en Redux DevTools el `grants/rollbackGrant` lleva en su payload el
`grantId` del masivo mientras el Diff muestra que cambió el individual. La prueba de
regresión falla con `Expected: "sent"`, `Received: "failed"`.

### `incidente/13` — el epic que dejó de existir

**Sale de:** `fase-06-redux-observable-a-fondo`
**Archivo:** `src/features/grants/epics/sendGrantEpic.js`

Se quita el `catchError` del stream de cada envío, el que vive dentro del
`exhaustMap`. Un error de red completa con error la cadena entera y, como
`combineEpics` une los epics con `merge`, se lleva a todos los demás con ella.

**Caos:** `CHAOS_LEVEL=high`, obligatorio: hace falta que un envío falle de verdad.

**Queda bien si:** tras el primer envío fallido **no vuelve a salir ninguna petición
de envío** —cero en Network—, las acciones `grants/sendGrantRequested` se siguen
viendo en DevTools sin nada del otro lado, la consola del navegador tiene un solo
`Uncaught` con el `503`, y la búsqueda de jugadores también dejó de responder. Ese
daño colateral es parte del incidente. La prueba de regresión termina en error (`#`)
en el frame del fallo y el segundo envío nunca sale.

### `incidente/14` ⭐ — el polling que sigue tras el logout

**Sale de:** `fase-07-cierre-polling-compras`
**Archivos:** `src/features/purchases/epics/pollingEpic.js` y
`src/features/purchases/PurchasesPage.jsx`

Dos commits. El primero deja el `takeUntil` del pipe interno escuchando solo
`stopPolling`, sin el logout. El segundo le quita a `PurchasesPage` la limpieza del
`useEffect` que despacha `stopPolling` al desmontarse. **Hacen falta los dos**: con
la limpieza puesta, el logout redirige a `/login`, la pantalla se desmonta, despacha
su `stopPolling` y el bug no se ve en el navegador (la prueba de pantalla del repo de
prueba lo confirmó). El fix mínimo del cuaderno es solo el del epic, y alcanza.

**Datos:** una compra en efectivo que siga pendiente. El mock de Google Play la deja
pendiente `PLAY_PENDING_MS` milisegundos (3000 por defecto): con el valor por defecto
la compra se confirma, el `takeWhile` cierra el polling y no se ve nada. Se levanta
con `PLAY_PENDING_MS=600000` y se crea la compra con `POST /purchases`.

**Queda bien si:** entras, consultas la compra en `/purchases`, cierras sesión y **no
tocas nada**: en Network siguen saliendo `GET /purchases/<token>` cada dos segundos,
**sin el header `Authorization`**, porque el interceptor de `apiStore` lee el store en
cada petición y ahí ya no hay token. El log del `3002` las cuenta:
`[3002] sin sesión #2: GET /purchases/tok-…`, `#3`… (el `#1` es el `POST` que creó la
compra, que no lleva sesión). La prueba de regresión cuenta dos consultas en vez de
dos más una cada dos segundos.

### `incidente/15` — el `mergeMap` que no cancela

**Sale de:** `fase-06-redux-observable-a-fondo`
**Archivo:** `src/features/grants/epics/searchPlayerEpic.js`

El `switchMap` de la búsqueda de jugadores pasa a `mergeMap`. Las respuestas de cada
búsqueda se acumulan y la última en llegar gana, aunque corresponda a una búsqueda
vieja. El `debounceTime` se queda como está: el incidente enseña que no es la causa.

**Caos:** `CHAOS_LEVEL=high`, y el motivo es preciso: con latencia uniforme las
respuestas vuelven en orden y el bug se esconde. Lo que lo destapa es que la respuesta
de la búsqueda corta (`Ana`) tarde **más** que la de la búsqueda larga (`Anaís`).

**Datos:** dos jugadoras cuyo nombre es prefijo de otro, con estados opuestos (§4.4).
Sin ese par, las dos respuestas dicen lo mismo y no hay síntoma.

**Queda bien si:** escribiendo `Anaís` a velocidad normal en el buscador del
asistente, cada tanto la lista muestra a *Ana* — suspendida, con la casilla
deshabilitada — en vez de a Anaís. En Network se ven dos búsquedas vivas al mismo
tiempo y la del prefijo corto respondiendo última. La prueba de regresión recibe dos
`grants/playerSearchSucceeded`, la de `Ana` en último lugar.

### `incidente/16` — la rueda que sigue girando después del cierre

**Sale de:** `fase-07-cierre-polling-compras`
**Archivo:** `src/features/wheels/closing.js`

`isWheelClosed` compara la hora del día con `getHours()` en vez de instantes:
`new Date(now).getHours() >= new Date(wheel.closesAt).getHours()`. Ignora la fecha y
lee la hora en la zona de la máquina. Como la guarda del epic de envío y la del
asistente usan la misma función, las dos se equivocan juntas.

**Datos:** la Rueda de fin de mes (id 4) del `db.json` de la fase, `live`, con
`closesAt` en `2026-08-30T20:00:00-05:00` (§4.5). No hay que sembrar nada.

**Cómo se ve el síntoma sin mudarte de país:** el navegador toma la zona del sistema
operativo, así que se arranca el dev server con `TZ` puesto. Panamá y Bogotá están
ambas en `-05:00` todo el año, así que para que la diferencia aparezca hay que
comparar con una zona de otro offset, como Santiago:

```bash
TZ=America/Panama npm start      # la consola de la oficina: el cierre se ve a las 20
TZ=America/Santiago npm start    # la computadora en hora de Chile: se ve a las 21
```

**Queda bien si:** de día, en cualquier fecha posterior al cierre, **las dos** ofrecen
la rueda (la hora del día es menor que la del cierre); y entre las 23:00 y las 24:00
de Panamá, la de Panamá la niega y la de Santiago la ofrece, porque allá ya es la
medianoche y `getHours()` da 0. Ese desacuerdo entre dos máquinas frente al mismo dato
es la firma del incidente, y es la misma forma de razonar del 02 y del 20. La prueba
de regresión se corre con `TZ=America/Panama`: en UTC pasa con el bug (el cierre se
ve a la 1 y "15 ≥ 1").

### `incidente/17` — el `catchError` que mata al `timer`

**Sale de:** `fase-07-cierre-polling-compras`
**Archivo:** `src/features/purchases/epics/pollingEpic.js`

El `catchError` sale del tick: deja de envolver la consulta de adentro del `mergeMap`
y pasa a envolver el `timer` entero. Un `500` del mock de Google Play lo dispara, emite
su `pollingFailed` y **completa el `timer`**: el polling muere ahí.

**Caos:** `CHAOS_LEVEL=high` en el mock de Google Play del **`3002`**, no en el `3001`.
Confundir los dos puertos es el error de preparación más frecuente de este incidente.

**Datos:** una compra en efectivo creada justo antes de consultarla, con la demora por
defecto (`PLAY_PENDING_MS=3000`).

**Queda bien si:** al primer `500` del `3002` las consultas de compra **paran y no
vuelven nunca**; la pantalla se queda en "Esperando confirmación · consultando…" (el
`pollingToken` no se limpia), el aviso rojo del `500` se queda fijo y la columna
«Última consulta» se congela. Si las consultas siguen saliendo, lo que tienes delante
es la causa B del enunciado —la espera real de la tienda—, que es el otro final posible
y no el de este ticket. La prueba de regresión se queda en `f`: el tick siguiente no
pregunta.

### `incidente/18` — la aritmética en dólares

**Sale de:** `fase-08-conciliacion`
**Archivo:** `src/features/reconciliation/reconciliationMath.js` (la función rota) y
`src/features/reconciliation/reconciliationSlice.js` (que la usa)

La rama agrega `prorateSpinPriceBroken` al lado de la buena —el precio por giro en
dólares, `packagePriceCents / 100 / spins`, y cada fila redondeada con `Math.round`— y
conecta el panel a ella: es lo que el ejercicio 18 de la fase hace "temporalmente" y
alguien se olvidó de deshacer.

**Datos:** los de la fase (§4.6), sembrados con `npm run seed:reconciliation`. El
panel muestra `tok-ago-05`, el primer paquete de 500 que la bitácora consume entero:
148 · 95 · 71 · 74 · 57 · 38 · 13 · 4 giros por segmento.

**Queda bien si:** la suma de las filas del prorrateo da **US$21,00** contra un
paquete de US$20,99 —un centavo de más—, y la misma cuenta en una consola de Node lo
confirma sin abrir el navegador. Comprobado en T5 (16/10/2026) con `node`: 621 · 399 ·
298 · 311 · 239 · 160 · 55 · 17 = 2.100. Los otros tres paquetes de 500 de agosto
dan 2.100 (`tok-ago-12`), 2.099 (`tok-ago-19`) y 2.098 (`tok-ago-26`), que es lo que
el ticket cuenta. La prueba de regresión falla con `Expected: 2099`, `Received: 2100`.

Si el descuadre es de más de un centavo, la siembra no es la de la fase: el incidente
vive de que la diferencia sea ridícula y aun así innegociable.

### `incidente/19` — los chequeos de desarrollo sobre la bitácora del evento

**Sale de:** `fase-09-dashboard`
**Archivo:** `src/app/store.js`

La rama devuelve el store al middleware por defecto (`getDefaultMiddleware()` sin
opciones): los chequeos de inmutabilidad y de serialización vuelven a recorrer la
bitácora del tablero en cada acción, y el de serialización también el payload de la
acción que la trae.

**Datos:** volumen (§4.7): `node mock/seed-reconciliation.js --event`, que deja la
Semana del Canal terminada con 180.000 giros. Con la Rueda de fin de mes (10.000
giros) el síntoma casi no se nota, y eso es la mitad del ticket.

**Queda bien si:** con el tablero de la Semana del Canal cargado, cualquier acción
de cualquier pantalla tarda cientos de milisegundos (medido en T6, el 18/10/2026: 213
ms de mediana, contra 0,1 ms en la fase) y la consola del navegador repite el aviso
de Toolkit, *"SerializableStateInvariantMiddleware took … ms, which is more than the
warning threshold of 32ms"*. La prueba de regresión falla con ese aviso; en la fase,
pasa sin ninguno.

> 📝 **El mecanismo cambió en T6.** La especificación de P6 era un `useMemo` con una
> dependencia que siempre cambia. Medido con la Semana del Canal, cuesta 12,5 ms por
> cambio de filtro contra 2,2 ms: real, y nadie lo siente. Quedó como la pieza
> forense de la Fase 9 (rama `previo-t6/incidente-19-usememo` del repo de prueba), y
> el 19 pasó a ser los chequeos de desarrollo, por decisión del autor.

### `incidente/20` — la tarjeta que consulta el reloj

**Sale de:** `fase-10-testing-minimo`
**Archivo:** `src/features/dashboard/MetricCard.jsx`

`MetricCard` deja de mostrar el instante que le llega por props (`updatedAt`) y
calcula su "Actualizado" con `new Date()`, formateado sin `timeZone`, o sea en la
zona de la máquina. La prueba de la Fase 10 que asegura `"Actualizado: 20/12 21:00"`
**no se toca**: no se rompió la prueba, se rompió el componente, y la prueba lo
descubrió.

**Queda bien si:** las dos corridas dan resultados distintos y **cada una de forma
determinista** (medido en T6: 3 de 3 en cada zona):

```bash
TZ=America/Bogota npm test -- MetricCard     # pasa
TZ=UTC npm test -- MetricCard                # falla: recibe "Actualizado: 21/12 02:00"
```

Si falla a veces en el **mismo** ambiente, preparaste otra cosa: eso sí sería una
prueba intermitente, y el incidente 20 existe justamente para enseñar a no
confundirlas.

### `incidente/21` ➕ — la rueda que dice 15 % y el tablero muestra 5 %

**Sin rama de commit** (DR-03): el incidente termina en diagnóstico y en una decisión.
**Sale de:** `fase-09-dashboard`, con la siembra de la regla vieja.

La preparación es un dato, no un cambio de código: `node mock/seed-reconciliation.js
--accommodating` escribe la bitácora de la Rueda de fin de mes con la regla de la
rueda que se acomoda (historia §5): antes de girar, se sacan los avatares que el
jugador ya tiene y su peso se reparte (§4.8).

**Queda bien si:** el tablero muestra "Con alarma", χ² = 808,35, y el avatar común
en 505 giros contra 1.500 esperados (medido en T6). El diagnóstico se hace con lo
que el repo trae: el tablero, la conciliación de la Fase 8 y la bitácora por
jugador —el avatar común salió 505 veces a 505 jugadores distintos, y a ninguno dos
veces; con la regla nueva, 448 jugadores lo sacaron dos o más—. Sin commit.

> 📝 **El síntoma cambió en T6.** La especificación de P6 decía que la Esclusa de Oro
> saldría al ≈ 2 % contra 0,5 %; ese número venía de una tabla artificial del
> prototipo de P7. Con el mecanismo de la historia, que es el que implementó la Fase
> 8, la Esclusa de Oro sale al 0,64 % y la que se desploma es el avatar común. El
> autor eligió el síntoma real.

---

## 4. Los datos que hay que sembrar

Los datos viven en `mock/db.json`, que **está versionado** —es dato semilla del curso,
no un artefacto generado—, así que el ciclo de siempre funciona:

```bash
git checkout -- mock/db.json     # tablero limpio antes de sembrar
```

Cada estado de abajo se aplica sobre el `db.json` de la fase que corresponda, y cambia
**solo** los registros que el incidente necesita. Nada de un archivo escrito a mano
desde cero: el resto del sistema tiene que seguir cuadrando.

> 💡 **Cuándo va en la rama y cuándo no.** Si el dato es parte del estado roto
> —§4.6, el paquete de 20,99 USD— se commitea en la rama del incidente y viaja con
> ella. Si es solo escenario —§4.1, dos ruedas con nombres distintos— puede quedarse
> en `main` sin molestar a nadie.

> ⚠️ **La forma del `db.json` la fija la Fase 3 (T2).** Las formas que siguen son las de
> la propuesta de reescritura (`wheels`, `segments`, `players`, `purchases`); los
> nombres de campo son los del diccionario y se confirman al escribir la fase. Lo que
> no cambia es el dato que cada incidente necesita.

### 4.1 Dos ruedas distinguibles (incidente 04)

```jsonc
"wheels": [
  { "id": 1, "name": "Rueda del Canal", "status": "live",
    "closesAt": "2026-12-20T20:00:00-05:00", "timezone": "America/Panama" },
  { "id": 2, "name": "Rueda de la Costa", "status": "live",
    "closesAt": "2026-12-30T20:00:00-05:00", "timezone": "America/Panama" }
]
```

Los nombres tienen que ser **inconfundibles a un metro de la pantalla**. Con "Rueda 1"
y "Rueda 2" el síntoma existe igual y no se ve.

### 4.2 Los jugadores de los envíos (incidentes 11 y 12)

No hace falta sembrar nada: el `db.json` de la Fase 5 trae los dos jugadores y la
colección de envíos vacía.

```jsonc
"players": [
  { "id": 42, "name": "Juan P.", "country": "Colombia" },
  { "id": 43, "name": "María R.", "country": "Chile" }
],
"grants": []
```

Los envíos se crean en la reproducción, desde el asistente: son los que el incidente
necesita, y ninguno más. Los usuarios `ibatista` e `ypinzon` son **operadores** de la
consola, no jugadores: no se mezclan.

### 4.3 (retirada)

Describía una versión del incidente 12 con dos ruedas que comparten un segmento; el 12
quedó en T3 como el rollback del envío masivo (§3), que no necesita datos sembrados. El
número se conserva para no mover las referencias a §4.4–§4.8.

### 4.4 Las jugadoras que son prefijo (incidente 15)

```jsonc
"players": [
  { "id": 44, "name": "Ana",   "country": "Colombia", "status": "banned" },
  { "id": 45, "name": "Anaís", "country": "México",   "status": "active" }
]
```

Vienen en el `db.json` desde la Fase 6, que es la que introduce el `status` de los
jugadores: no hay que sembrarlas.

Uno es prefijo del otro **y tienen estados opuestos**. Esas dos condiciones juntas son
las que hacen que la respuesta vieja contradiga a la nueva; con estados iguales, el
`mergeMap` sigue estando mal y no se nota.

### 4.5 La rueda que cierra a las 20:00 (incidente 16)

```jsonc
{ "id": 4, "name": "Rueda de fin de mes", "status": "live",
  "closesAt": "2026-08-30T20:00:00-05:00", "timezone": "America/Panama" }
```

Viene en el `db.json` desde la Fase 7, con sus segmentos. Es una rueda nueva, la 4, y no
una de las tres de antes con otro `closesAt`: cada una tiene su papel (la 3 está
conciliada, y la 1 es la que sigue `live` hasta 2030 y sirve de contraste en el
asistente).

**El offset explícito no es decorativo**: es el dato que hace que dos navegadores en
zonas distintas lean el mismo instante y muestren horas diferentes. Un `closesAt` en
`Z`, o sin offset, cambia el incidente.

### 4.6 El paquete de 20,99 USD (incidente 18)

```jsonc
"packages": [
  { "productId": "spins-10",  "spins": 10,  "packagePriceCents": 99 },
  { "productId": "spins-500", "spins": 500, "packagePriceCents": 2099 }
]
```

No hay que sembrar nada aparte: el catálogo, las compras acreditadas, la bitácora de
10.000 giros de la Rueda de fin de mes (semilla 42) y el reporte de la tienda los
escribe `npm run seed:reconciliation`, desde la Fase 8. El paquete de **500 giros**
por 2.099 centavos es el que hace visible el problema: el prorrateo por giro sale de
`2.099 / 500 = 4,198`, que no es un número de centavos. En el código vigente el
reparto se hace con `prizeShare`, que no pierde centavos; la rama es la que vuelve a
calcular cada fila en dólares y redondear.

### 4.7 El volumen del dashboard (incidente 19)

Con la Rueda de fin de mes (10.000 giros) no hay incidente: hace falta un evento. Lo
genera la siembra de la Fase 8, con su bandera de la Fase 9:

```bash
node mock/seed-reconciliation.js --event   # la Semana del Canal (rueda 2) terminada, con 180.000 giros
# al terminar: git checkout -- mock/db.json mock/googlePlay/earnings.json
```

Determinista a propósito, como el resto de la siembra (semilla 2025): con
`Math.random()`, el antes y el después de una medición dejan de ser comparables. El
`db.json` pasa a unos 50 MB y no se commitea. (La versión de P6 usaba un
`mock/seed-volume.js` aparte, con segmentos inventados; se retiró en T6.)

### 4.8 La rueda que se acomoda (incidente 21)

No existe como funcionalidad del alumno ni como bandera del mock: es una regla del API
de 2021, y lo que el laboratorio puede reproducir es **su bitácora**. La genera la
siembra con la regla vieja:

```bash
node mock/seed-reconciliation.js --accommodating
```

La Rueda de fin de mes queda con 10.000 giros sorteados como lo hacía el API viejo
—800 jugadores, el 30 % veteranos con los dos avatares más comunes—, y la bitácora
guarda solo lo entregado, en la única columna que tenía. Es el único cambio de este
incidente, y no se commitea. (La versión de P6 hablaba de un `rigged: true` en la
rueda; no llegó a existir.)

---

## 5. Los que se preparan solo con caos o con el mock

El **incidente 08** —"me saca a login al azar mientras estoy trabajando"— no lleva
rama ni datos especiales, y eso es exactamente lo que enseña: el `401` lo inyecta el
middleware de caos de `mock/server.js` sobre las rutas protegidas, tal como la Fase 3
lo escribió, y **eso no es el bug**. Un backend real hace lo mismo cuando la sesión
expira. El defecto está en cómo reacciona el interceptor, que es código sano en el
sentido de que hace lo que dice.

```bash
CHAOS_LEVEL=high npm run mock:api
npm start
```

**Queda bien si:** empiezas a llenar el formulario de una rueda nueva, sigues
navegando, y en algún momento aterrizas en `/login` **sin ningún mensaje** y sin lo
que estabas escribiendo. Si tarda demasiado en pasar, es cuestión de insistir: el `401`
es aleatorio y el ticket dice "al azar" por algo.

El **incidente 21** también se prepara sin rama: lo prepara la siembra de §4.8 y el
observador es el tablero de F09. Su cierre es el diagnóstico, no un commit.

---

## 6. Verificar que la preparación sirve

Antes de dar por lista una rama, tres comprobaciones que cuestan un minuto y evitan
mandar a alguien a investigar un bug que no está:

1. **El síntoma aparece**, y aparece como lo describe el ticket. No "algo falla":
   *eso* falla.
2. **El resto del sistema sigue en pie.** Un `npm test` en la rama del incidente
   tiene que fallar en lo que el incidente rompió y en nada más. Si caen ocho pruebas,
   el cambio no fue mínimo.
3. **El diff cabe en una pantalla.** Si `git diff main...incidente/NN` no entra en
   veinte líneas, revisa: casi siempre significa que arrastraste cambios de fases
   posteriores al salir del tag equivocado.

```bash
git diff --stat fase-07-cierre-polling-compras...incidente/14
```

Para cada rama se corre la comprobación en la tanda que escribe su fase, y el
resultado (síntoma visto, o «no verificado por ejecución») va a la bitácora del plan.

---

## ⚠️ Advertencias

- **No abras este archivo mientras resuelves.** Ya está dicho arriba y se repite acá
  porque es la única regla que importa.
- **Los datos de las recetas son los del `db.json` del curso.** Si resolviste un
  ejercicio que cambió la semilla, ajusta el dato o ajusta el enunciado, pero que
  coincidan: los enunciados nombran datos concretos (la jugadora `ibatista`, la rueda
  del Canal, el paquete de 500 giros).
- **Las ramas no se mezclan entre sí.** Cada una sale de su tag de fase y vive sola.
  Encadenar dos incidentes en la misma rama produce síntomas cruzados que no se pueden
  separar.
