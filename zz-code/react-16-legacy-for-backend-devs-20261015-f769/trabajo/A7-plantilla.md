# 🌀 Apéndice A7 — Redux-Observable Épica por Épica
## Tutorial React 16 — La Esclusa, la consola de Jewel Locks

> **Material de consulta rápida** · **~3 horas** · Lo usan las Fases 6, 7, 10 y 11 ·
> Prioridad: 🔴 Alta
>
> No se lee de corrido. Cuando estés escribiendo un epic y no te acuerdes de si va
> `switchMap` o `mergeMap`, saltas acá, miras el patrón, copias el molde y vuelves.
> Cada patrón trae lo mismo: **cuándo usarlo · el epic de la consola que lo usa · el
> error común que te va a morder · su prueba de canicas**.

Stack fijado (no lo cambies sin justificar): **redux-observable 1.2.0 · RxJS 6.6.7 ·
rxjs-marbles 6.0.1 para las pruebas de canicas · JavaScript plano**. Los epics de
acá son los de la consola tal como quedan al cerrar la Fase 7 —`undoWindowEpic`,
`sendGrantEpic`, `searchPlayerEpic`, `retryGrantEpic`, `cancelOnLogoutEpic` y
`pollingEpic`—, copiados de los archivos, no reescritos para el apéndice. La única
excepción es `concatMap`, que la consola no usa y va con un epic de consulta
declarado como tal.

Las pruebas de cada patrón también son reales: están escritas contra esos epics y
pasan contra el código de la Fase 7. Todas reciben el cliente HTTP por el tercer
argumento —`{ api }`, `{ store }`—, que es lo que la Fase 6 preparó al pasarlo por
`createEpicMiddleware({ dependencies })`. La metodología de las canicas (la
gramática del diagrama, `hot` contra `cold`, el molde) está en
`A11-marble-testing.md`; acá alcanza con el recordatorio de la sección 🔬.

---

## ⚡ Cómo usar este apéndice (mapa de 30 segundos)

Los ocho operadores se parten en dos familias. La primera decide **qué pasa con la
operación anterior cuando llega una acción nueva**, y esa decisión es, en la
práctica, el 80 % de los bugs de epics. La segunda se ocupa de **no morir**: cortar
limpio, reintentar con cabeza y sobrevivir a un error.

- **Mapeo (aplanamiento):** `debounceTime`, `switchMap`, `mergeMap`, `concatMap`, `exhaustMap`.
- **Cancelación y resiliencia:** `takeUntil`, `retryWhen`, `catchError`.

Si solo tienes diez segundos: elegir mal entre `switchMap` y `mergeMap` es la causa
raíz más común de "me mostró a otra jugadora" y de "se compensó dos veces". Anda
directo a la [tabla maestra](#-tabla-maestra-cuándo-usar-qué-operador).

---

## 🧭 Salto rápido

**Mapeo**
1. [`debounceTime` — esperar a que pare de escribir](#1-debouncetime--esperar-a-que-pare-de-escribir)
2. [`switchMap` — el último gana, cancela lo anterior](#2-switchmap--el-último-gana-cancela-lo-anterior)
3. [`mergeMap` — todo en paralelo](#3-mergemap--todo-en-paralelo)
4. [`concatMap` — encolar y respetar el orden](#4-concatmap--encolar-y-respetar-el-orden)
5. [`exhaustMap` — ignorar lo nuevo mientras proceso](#5-exhaustmap--ignorar-lo-nuevo-mientras-proceso)

**Cancelación y resiliencia**
6. [`takeUntil` — apagar el stream ante una señal](#6-takeuntil--apagar-el-stream-ante-una-señal)
7. [`retryWhen` — reintentar los transitorios con backoff](#7-retrywhen--reintentar-los-transitorios-con-backoff)
8. [`catchError` — que un error no mate el epic](#8-catcherror--que-un-error-no-mate-el-epic)

**Soporte**
- [Tabla maestra: cuándo usar qué operador](#-tabla-maestra-cuándo-usar-qué-operador)
- [Chuleta de imports (RxJS 6, ojo con RxJS 7)](#-chuleta-de-imports-rxjs-6-ojo-con-rxjs-7)
- [🩸 Memory leaks en epics: cómo se ven, cómo se previenen](#-memory-leaks-en-epics-cómo-se-ven-cómo-se-previenen)
- [💸 La deuda: dos epics con el mismo cuerpo](#-la-deuda-dos-epics-con-el-mismo-cuerpo)
- [🔬 Pruebas de canicas → **A11**](#-pruebas-de-canicas--a11)
- [🧪 Ejercicios (8)](#-ejercicios-8)
- [📚 Referencias](#-referencias)

---

## 📊 Tabla maestra: cuándo usar qué operador

| Situación en la consola | Operador | Qué hace con lo anterior | Antipatrón si te equivocas |
|---|---|---|---|
| Buscar jugadores mientras el operador escribe | `switchMap` | **Cancela** la búsqueda anterior en vuelo | `mergeMap` → la respuesta de `Ana` llega después de la de `Anaís` y pinta a la jugadora equivocada (incidente 15) |
| La misma búsqueda: esperar a que pare de escribir | `debounceTime(300)` | Descarta lo intermedio, deja pasar el último | Sin él, una petición por tecla contra el mock |
| La ventana de deshacer de **cada** envío encolado | `mergeMap` | **Nada**: corren todas a la vez | `switchMap` → encolar a María cancela la ventana de Juan, que no sale nunca |
| Consultar otra compra pendiente | `switchMap` | Cancela el polling de la anterior | `mergeMap` → dos pollings vivos, el doble de consultas al `3002` |
| Operaciones que deben aplicarse **en orden** | `concatMap` | **Espera** a que termine la anterior | `mergeMap` → el orden no está garantizado y el estado queda inconsistente |
| «Enviar ahora» con doble clic | `exhaustMap` (por envío, con `groupBy`) | **Ignora** los clics mientras el envío está en vuelo | `mergeMap` → dos `POST` del mismo envío (incidente 11) |
| Cortar un stream al logout o al «Deshacer» | `takeUntil` | Completa y ejecuta el teardown | Olvidarlo → suscripción zombi, consultas sin sesión (incidente 14) |
| Un `timeout` o un `5xx` en el envío masivo | `retryWhen` + backoff | Reintenta N veces con espera creciente | `retry` a secas → martillas el servidor; reintentar un `409` da diez `409` |
| Que un error no mate el epic | `catchError(e => of(action))` adentro | Reemplaza el error por una acción | Sin él, o afuera → el epic deja de escuchar para siempre (incidentes 13 y 17) |

> 💡 **La mnemotecnia que cierra la tabla:** *switch* = el último gana · *merge* =
> todos a la vez · *concat* = uno detrás de otro · *exhaust* = el primero manda hasta
> que termine. Los cuatro reciben acciones y devuelven un Observable interno; lo único
> que cambia es **qué hacen con el interno anterior cuando llega uno nuevo**.

---

## 🧾 Chuleta de imports (RxJS 6, ojo con RxJS 7)

Fijado RxJS **6.6.7**. Los operadores viven en `rxjs/operators` y los creadores de
Observable en `rxjs`. Es lo mismo que importa `retryGrantEpic`, el epic con más
piezas de la consola:

<<<fragmento:esclusa-app/src/features/grants/epics/retryGrantEpic.js|import { ofType }|from "rxjs/operators";>>>

> ⚠️ **Trampa de versión.** Mucho tutorial de RxJS que encuentras en línea es 7+. Si
> ves `retry({ count, delay })`, `firstValueFrom` o imports de operadores desde `rxjs`
> directo (no desde `rxjs/operators`), es RxJS 7 y **no compila igual acá**. En 6 el
> backoff se arma con `retryWhen` y `timer` (patrón 7).

---

## Patrones de mapeo (aplanamiento)

### 1. `debounceTime` — esperar a que pare de escribir

**Cuándo.** Cuando llegan muchas emisiones seguidas y solo te importa la última
*después de una pausa*. El caso de la consola: el buscador del asistente de
compensaciones, que despacha `playerSearchRequested(texto)` en cada tecla.

**El epic que lo usa** (`searchPlayerEpic`, Fase 6):

<<<fragmento:esclusa-app/src/features/grants/epics/searchPlayerEpic.js|export const SEARCH_DEBOUNCE_MS|    })
  );>>>

**Error común.** Creer que el debounce resuelve el orden de las respuestas. Reduce la
cantidad de peticiones, pero si el operador escribe `Ana`, hace una pausa y sigue
con `Anaís`, dos búsquedas pueden quedar en vuelo, y con `mergeMap` la lenta pisa a
la rápida. `debounceTime` controla *cuándo sales*; `switchMap` controla *que la
anterior muera*. Necesitas los dos, y el incidente 15 es lo que pasa cuando falta el
segundo.

**Su prueba de canicas.** Tres teclas dentro de la ventana se colapsan en una sola
búsqueda, con el último texto:

<<<fragmento:trabajo/A7.marbles.test.js|test("debounceTime|}));>>>

> 💡 Cada carácter del diagrama es un *frame* de un milisegundo virtual, y `300ms`
> avanza trescientos de golpe. El epic no recibe ningún scheduler: rxjs-marbles 6
> corre adentro de `TestScheduler.run`, que hace que `debounceTime`, `timer` y
> compañía usen el tiempo virtual solos.

---

### 2. `switchMap` — el último gana, cancela lo anterior

**Cuándo.** Cuando solo te importa el resultado de la **última** acción y las
respuestas viejas son basura que puede corromper el estado. En la consola hay dos:
la búsqueda de jugadores (arriba) y el polling de compras, donde consultar otra
compra cancela el polling de la anterior.

**El epic que lo usa** (`pollingEpic`, Fase 7, en su forma completa):

<<<fragmento:esclusa-app/src/features/purchases/epics/pollingEpic.js|export const pollingEpic|    })
  );>>>

Lo valioso es que la búsqueda perdedora **nunca llega a despachar su resultado**:
`switchMap` se desuscribe de ella, y con la desuscripción se va todo lo que venía
detrás. Lo mismo con el polling: un `startPolling` nuevo apaga el `timer` del
anterior sin que nadie llame a nada.

**Error común.** Usar `switchMap` cuando las operaciones son **independientes y no
deben cancelarse entre sí**. Si lo usaras en la ventana de deshacer, encolar el envío
de María cancelaría la ventana de Juan, y el de Juan no saldría nunca. Regla:
`switchMap` solo si *el anterior ya no importa*.

**Su prueba de canicas.** Se prueba la **cancelación**: el resultado de la búsqueda
vieja no aparece, aunque llegue después.

<<<fragmento:trabajo/A7.marbles.test.js|test("switchMap|}));>>>

> La aserción *es la ausencia*: probar una cancelación con canicas significa demostrar
> que algo **no** aparece en el diagrama esperado. Es la misma prueba que cierra el
> incidente 15.

---

### 3. `mergeMap` — todo en paralelo

**Cuándo.** Cuando cada acción arranca una operación **independiente** que no debe
cancelar ni bloquear a las demás. El caso de la consola: la ventana de deshacer de
cada envío encolado corre en su propio `timer`, en paralelo con las demás.

**El epic que lo usa** (`undoWindowEpic`, Fase 6):

<<<fragmento:esclusa-app/src/features/grants/epics/undoWindowEpic.js|export const undoWindowEpic|    })
  );>>>

**Error común.** `mergeMap` sin freno sobre una fuente rápida crea concurrencia
ilimitada: cientos de suscripciones internas vivas a la vez. Si la operación no está
acotada por naturaleza, ponle un límite con el segundo argumento. Es lo que hace
`retryGrantEpic` con «Enviar todos ahora»: `mergeMap(…, BULK_CONCURRENCY)` manda de a
cuatro, y no los cuarenta envíos encolados de golpe contra el mock.

**Su prueba de canicas.** Dos encolados producen dos ventanas **solapadas en el
tiempo**, y cada una vence a su hora:

<<<fragmento:trabajo/A7.marbles.test.js|test("mergeMap|}));>>>

Si esto fuera `switchMap`, `a` **no** aparecería: el encolado de María cancelaría la
ventana de Juan. La prueba protege exactamente esa decisión.

---

### 4. `concatMap` — encolar y respetar el orden

**Cuándo.** Cuando las operaciones deben ejecutarse **una después de otra, en el
orden en que llegaron**, sin solaparse, porque cada una parte del estado que dejó la
anterior.

> 📝 **La consola no usa `concatMap`.** Va acá como patrón de consulta, con un epic
> que no existe en el código: ajustes de existencias de un segmento limitado, donde
> cada ajuste parte del `remaining` que dejó el anterior. Las acciones son objetos
> escritos a mano, sin slice, para que quede claro que es un molde y no una pieza de
> la Esclusa.

**El molde:**

<<<fragmento:trabajo/A7.marbles.test.js|const stockAdjustmentEpic|    })
  );>>>

**Error común.** Usar `concatMap` para algo que **debería** ser paralelo: cargar
cinco ruedas independientes con `concatMap` las serializa y multiplica la latencia
por cinco. Es correcto solo cuando el orden importa o las operaciones comparten un
recurso mutable. Si no, es `mergeMap`.

**Su prueba de canicas.** Se prueba la **serialización**: aunque las acciones lleguen
casi juntas, la segunda no sale hasta que vuelve la primera.

<<<fragmento:trabajo/A7.marbles.test.js|test("concatMap|}));>>>

`y` cae **cuatro frames después** de `x`, no uno: la segunda petición esperó a que la
primera completara. Con `mergeMap`, `y` caería en el frame 6 y el `remaining` de
cada respuesta dependería de cuál llegó primero al servidor.

---

### 5. `exhaustMap` — ignorar lo nuevo mientras proceso

**Cuándo.** Cuando hay una operación en curso y los disparos nuevos deben
**descartarse hasta que termine**. El caso de manual: el «Enviar ahora» y el doble
clic nervioso. Con `exhaustMap`, el segundo clic se ignora mientras el primer `POST`
está en vuelo.

**El epic que lo usa** (`sendGrantEpic`, Fase 6, con la guarda de cierre de la Fase 7):

<<<fragmento:esclusa-app/src/features/grants/epics/sendGrantEpic.js|export const sendGrantEpic|    )
  );>>>

El `groupBy` es lo que hace que la exclusión sea **por envío**: el doble clic sobre
Juan se ignora, y el clic sobre María, un frame después, sale igual. Un `exhaustMap`
sin `groupBy` ignoraría a María también, porque "hay algo en vuelo" sería cierto para
toda la consola.

**Error común.** Confundir `exhaustMap` con `switchMap`. Los dos "resuelven" el doble
clic, pero al revés: `switchMap` **cancela el primero y se queda con el último**;
`exhaustMap` **se queda con el primero e ignora el resto**. Para un envío quieres
`exhaustMap`: cancelar del lado del navegador una petición que ya salió no la
cancela en el servidor, y la compensación puede haber llegado igual. La distinción
no es cosmética: cambia qué envío queda registrado.

**Su prueba de canicas.** Se prueba que el disparo intermedio **se ignora**, y que
salió una sola petición:

<<<fragmento:trabajo/A7.marbles.test.js|test("exhaustMap|}));>>>

---

## Patrones de cancelación y resiliencia

### 6. `takeUntil` — apagar el stream ante una señal

**Cuándo.** Siempre que un stream de larga vida deba **cortarse ante un evento**: el
logout, el «Deshacer», o la acción que vuelve irrelevante la espera. Es el operador
de cancelación de todo el curso y la única defensa real contra los memory leaks de
epics (sección 🩸).

**Dónde está en la consola.** Dos veces, en los dos epics de arriba. En
`undoWindowEpic`, corta la ventana de **ese** envío si llega su «Deshacer», su
«Enviar ahora», el envío masivo o el logout —el `filter` compara el id—. En
`pollingEpic`, corta el `timer` con el stop del operador o el logout:

<<<fragmento:esclusa-app/src/features/purchases/epics/pollingEpic.js|        takeUntil(|logout.match(other))))>>>

**Error común.** Dos, y los dos duelen:

1. **Olvidarlo**, o dejarle una señal afuera, en un stream infinito (`interval`,
   `timer`, polling). No rompe nada visible hoy, y deja la suscripción viva mandando
   consultas sin sesión después del logout. Es el incidente 14 ⭐.
2. **Ponerlo en el pipe equivocado.** `takeUntil` corta todo lo que está antes de él
   en el pipe donde vive. En el pipe interno corta el `timer`; en el externo corta el
   epic entero, y el primer logout lo apaga para siempre. Regla práctica: casi
   siempre va **último, en el pipe interno**.

**Sus pruebas de canicas.** Las dos pruebas de un corte tienen la misma forma: el
diagrama esperado **termina** donde el corte lo dice.

<<<fragmento:trabajo/A7.marbles.test.js|test("takeUntil: «Deshacer»|}));>>>

<<<fragmento:trabajo/A7.marbles.test.js|test("takeUntil: después del logout|}));>>>

El diagrama vacío de la primera y el `!` de la segunda (la suscripción que la prueba
corta diez segundos después del logout) son toda la aserción. Sin canicas,
"comprobar que algo no pasa nunca más" requiere esperar para siempre.

---

### 7. `retryWhen` — reintentar los transitorios con backoff

**Cuándo.** Cuando un fallo puede ser pasajero (`timeout`, `5xx`) y vale la pena
reintentar con espera creciente. La regla dura de la consola: **nunca reintentes un
`409`**. Si el caso ya está compensado para ese jugador, reintentar diez veces da
diez `409`.

**El epic que lo usa** (`retryGrantEpic`, Fase 6; el núcleo del reintento):

<<<fragmento:esclusa-app/src/features/grants/epics/retryGrantEpic.js|              defer(() =>|                ),>>>

Dos detalles que la Fase 6 explica y que acá conviene ver juntos. El `defer`: una
promesa ya cumplida no se vuelve a pedir, así que reintentar `from(promesa)` repite
el fallo sin salir a la red; `defer` crea la petición de nuevo en cada intento. Y el
`index`, que `mergeMap` le pasa como segundo argumento: es el número de error, y con
él se calcula el backoff (500 ms, 1 s, 2 s) y el tope (`MAX_RETRIES`).

> ⚠️ **RxJS 6, no 7.** En RxJS 7 esto se escribe `retry({ count, delay })`. En 6.6.7
> no existe esa firma; el backoff se arma a mano con `retryWhen` y `timer`, como acá.

**Error común.** `retry(3)` a secas. Reintenta **cualquier** error, incluido el `409`
que jamás va a mejorar, y sin espera: tres golpes instantáneos al servidor.
`retryWhen` te deja filtrar *qué* error reintentar y *cuánto* esperar. Si no
distingues el tipo de error, no reintentes.

**Sus pruebas de canicas.** El contraste es el objetivo: un `503` se reintenta y un
`409` no.

<<<fragmento:trabajo/A7.marbles.test.js|test("retryWhen: un 503|}));>>>

<<<fragmento:trabajo/A7.marbles.test.js|test("retryWhen: un 409|}));>>>

El `1499ms` de la primera es el backoff entero escrito en el diagrama: 500 ms del
primer reintento, 1000 del segundo, más un frame por cada respuesta del `cold`. Si
alguien cambia la fórmula del backoff, esta prueba se pone roja.

---

### 8. `catchError` — que un error no mate el epic

**Cuándo.** Siempre que un Observable interno pueda fallar. Sin `catchError`, un
error **completa el epic entero** con error, y deja de escuchar acciones para
siempre: el bug más silencioso y más grave de todos.

**Dónde va.** El detalle que importa es la posición. En `sendGrantEpic` (patrón 5)
el `catchError` envuelve **la petición de ese envío**, adentro del `exhaustMap`. En
`pollingEpic` (patrón 2) envuelve **la consulta de ese tick**, adentro del `mergeMap`.
Los dos están en el lugar donde quieres que el error muera:

```javascript
// ❌ Afuera del tick: el primer 500 completa el timer entero (incidente 17).
timer(0, POLLING_INTERVAL_MS).pipe(
  mergeMap(() => from(store.get(`/purchases/${token}`)).pipe(map(/* … */))),
  catchError((error) => of(pollingFailed({ token, error: toReadableError(error) })))
);
```

**Error común.** Justo el de arriba. Es un error de *posición*, no de olvido, y por
eso es traicionero: el código "maneja errores", el primer fallo hasta se despacha
bien… y a partir de ahí el stream está muerto y nadie lo nota. Regla: **el
`catchError` va dentro del Observable interno**, aislando el error a esa operación.
Y su primo, el olvido, es el incidente 13: sin `catchError`, el error sube hasta
`combineEpics` y se lleva a **todos** los epics con él.

**Sus pruebas de canicas.** Se prueba que **tras un error, el epic sigue
respondiendo**:

<<<fragmento:trabajo/A7.marbles.test.js|test("catchError adentro|}));>>>

<<<fragmento:trabajo/A7.marbles.test.js|test("catchError por tick|}));>>>

Que el envío de María aparezca **después** del rollback de Juan, y que el segundo
tick traiga la confirmación después del `500`, es la prueba de que los epics
sobrevivieron. Un test que solo mire el primer fallo pasa con el bug adentro.

---

## 🩸 Memory leaks en epics: cómo se ven, cómo se previenen

Un epic es un Observable que **nunca se completa**: escucha `action$` para siempre,
que es lo que quieres. El problema aparece con los Observables **internos** de larga
vida —`interval`, `timer`, polling— que arrancas dentro de un `mergeMap` o un
`switchMap`. Si no les das una condición de corte, quedan vivos aunque la pantalla
que los originó ya no exista.

La consola tuvo uno a propósito: el refresco de compras de la Fase 6 (§5.8), un
`interval(5000)` sin `takeUntil` que seguía consultando `GET /purchases?status=pending`
después del logout. La Fase 7 lo borró y lo reemplazó por `pollingEpic`, con sus dos
salidas.

**Cómo se ve un leak (la evidencia forense):**

- En **Redux DevTools**, acciones que siguen llegando después del logout o de salir
  de la pantalla: `purchases/purchaseStatusReceived` de una compra que ya nadie mira.
  Acciones fantasma.
- En **Network**, peticiones periódicas que siguen saliendo, ya sin `Authorization`.
- En el **log del mock**, el contador de peticiones sin sesión: `[3001] sin sesión #N`
  en el refresco de la Fase 6, `[3002] sin sesión #N` en el polling de la Fase 7. Ese
  número no lo deduces: lo cuentas.
- En **Chrome DevTools → Memory**, el heap que crece escalonado y no baja: cada visita
  suma una suscripción que no se liberó.

**Cómo se previene** — una sola idea, de tres formas:

1. **Todo stream infinito lleva `takeUntil`** con sus señales de fin de vida, el
   logout entre ellas, en el mismo pipe donde nació.
2. **El teardown de RxJS es tu aliado:** cuando `takeUntil` corta o `switchMap`
   cambia de interno, RxJS limpia el `timer` o el `interval` solo. No hay
   `clearTimeout` que recordar —esa es la razón de existir de los epics frente a los
   `setTimeout` de la Fase 5—, y por eso `undoWindowEpic` no tiene un `Map` de ids.
3. **Elige bien el operador de aplanamiento.** `switchMap` cancela el interno anterior
   por diseño; usarlo donde corresponde previene leaks gratis. `mergeMap` sin corte es
   donde se acumulan.

> 📚 El procedimiento de caza está en la pieza forense de la Fase 6 (§6) y en la de la
> Fase 7. Este apéndice te da los patrones; esas piezas te dan el procedimiento.

---

## 💸 La deuda: dos epics con el mismo cuerpo

La Fase 6 deja declarada una deuda que este apéndice no paga: `sendGrantEpic` y
`retryGrantEpic` repiten casi el mismo cuerpo. Los dos arman el `concat` del
optimista, el `POST /players/:id/grants`, el `grantConfirmed` y el `rollbackGrant`, y
desde la Fase 7 los dos llaman a `closedWheelRejection`. Lo único que cambia es el
`retryWhen` del masivo.

La extracción natural es una función que devuelve el Observable de **un** envío, y
que cada epic compone con su operador:

```javascript
// Lo que comparten: el ciclo de un envío. retry decide si se reintenta.
const grantRequest$ = (grant, api, retry = (request$) => request$) =>
  concat(
    of(grantSending(grant.id), grantSent({ grantId: grant.id })),
    retry(defer(() => api.post(`/players/${grant.playerId}/grants`, { /* … */ }))).pipe(
      map(() => grantConfirmed(grant.id)),
      catchError((error) => of(rollbackGrant({ /* … */ error: toReadableError(error) })))
    )
  );
```

No se paga en el curso porque los dos epics están cubiertos por pruebas y el costo de
la duplicación, hoy, es leerla dos veces. Se paga el día que un tercer epic necesite
el mismo ciclo, o el día que alguien arregle un bug en uno y se olvide del otro. Es el
ejercicio 27 de la Fase 6, y las pruebas de los patrones 5, 7 y 8 son la red para
hacerlo sin miedo.

---

## 🔬 Pruebas de canicas → **A11**

Cada patrón de arriba trae su prueba porque la prueba es parte del patrón, no un
añadido. Lo que **no** está acá es la metodología: la gramática del diagrama, `hot`
contra `cold`, el molde base, los errores comunes al escribir canicas y las pruebas
trabajadas paso a paso.

Todo eso vive en **`A11-marble-testing.md`**, y se aplica de lleno en la Fase 10.

El recordatorio mínimo, para leer las pruebas de este apéndice sin saltar de archivo:

- `-` es un frame (un milisegundo virtual) · una letra es una emisión · `|` completa ·
  `#` error · `(ab)` son dos emisiones en el mismo frame · `300ms` avanza trescientos
  frames de golpe.
- `m.hot(...)` para `action$` (ya está corriendo); `m.cold(...)` para las respuestas
  HTTP (nacen con la suscripción).
- `m.expect(epic(action$, state$, deps)).toBeObservable(esperado, valores)` es la
  aserción; `m.flush()` corre el tiempo virtual hasta el final, para mirar contadores
  después.
- Los epics reciben un `state$` mínimo (`{ value: … }`) y un `api` o un `store` falso:
  por eso las dependencias del middleware importan.

> 🧠 **Y el principio que gobierna todas las pruebas de este apéndice:** prueba
> *tiempo* y *cancelación*, no valores. El valor lo cubre una prueba de reducer, que es
> más barata. Lo que **solo** las canicas pueden probar es cuándo emite un stream y
> —sobre todo— qué deja de emitir tras un corte. Si tu prueba de canicas no depende
> del tiempo, probablemente no necesitabas canicas.

---

## 🧪 Ejercicios (8)

Cortos, de consulta. Los que dicen **(canicas)** se resuelven escribiendo una prueba
de canicas con rxjs-marbles 6, contra el epic real. Recuerda: identificadores en
inglés, comentarios y UI en español.

**🟢 Fácil**

1. Escribe de memoria la línea de imports de RxJS 6 para un epic que use
   `debounceTime`, `switchMap`, `map` y `catchError`. **Criterio:** ninguno de los
   cuatro viene de `rxjs`, y el archivo compila con `npm run build`.
2. Con la tabla maestra, decide el operador para cada caso y justifícalo en una frase:
   (a) cargar el detalle de la rueda que el operador acaba de abrir; (b) la ventana de
   deshacer de tres envíos encolados; (c) el doble clic en «Enviar ahora».
   **Criterio:** (a) `switchMap`, (b) `mergeMap`, (c) `exhaustMap`, cada uno con lo que
   pasaría con el operador equivocado.

**🟡 Intermedio**

3. Cambia el `switchMap` de `searchPlayerEpic` por `mergeMap`, dejando el
   `debounceTime(300)`, y corre la prueba del patrón 2. **Criterio:** la prueba se
   pone roja con dos `playerSearchSucceeded`, y puedes explicar en dos frases por qué
   el debounce solo no alcanza.
4. **(canicas)** Escribe una prueba que demuestre que `searchPlayerEpic` busca
   **dos** veces si el operador hace una pausa de 400 ms en mitad del nombre.
   **Criterio:** el diagrama esperado tiene dos `playerSearchSucceeded`, y la prueba
   pasa contra el epic sin tocarlo.
5. Mueve el `catchError` de `pollingEpic` afuera del `mergeMap` (como el ❌ del patrón
   8) y corre la prueba del patrón 8. **Criterio:** la prueba se pone roja y el
   diagrama recibido termina en `f`; vuelve a dejarlo adentro y escribe en un
   comentario en español qué se rompía.

**🟠 Difícil**

6. **(canicas)** Prueba que consultar una segunda compra **cancela** el polling de la
   primera: `startPolling("tok-a")` y, tres segundos después, `startPolling("tok-b")`.
   **Criterio:** después del segundo `startPolling` no aparece ningún
   `purchaseStatusReceived` de `tok-a`, y el `store.get` falso registra que
   `/purchases/tok-a` dejó de pedirse.
7. **(canicas)** Escribe la prueba de `retryGrantEpic` para un `timeout` (axios lo
   marca con `code: "ECONNABORTED"`): se reintenta y confirma. **Criterio:** el
   diagrama esperado incluye el backoff, y la misma prueba con un `409` cae directo en
   `rollbackGrant` con una sola petición.

**🔴 Muy difícil**

8. **(canicas)** Diagnóstico: quita el `logout` del `takeUntil` de `pollingEpic`.
   Primero describe la evidencia que verías en Redux DevTools, en Network y en el log
   del `3002` tras un logout con la pantalla de compras abierta (pista: la pantalla se
   desmonta y despacha su `stopPolling`; ¿qué otra cosa tendrías que quitar para ver
   el leak en el navegador?). Después corre la segunda prueba del patrón 6.
   **Criterio:** la prueba se pone roja con `calls` mayor que 2, y tu descripción
   nombra las dos salidas que faltan.

**🔥 Opcionales**

- 🔥 Reimplementa `stockAdjustmentEpic` con `mergeMap` y demuestra con una prueba de
  canicas que el orden de los `stockAdjusted` deja de estar garantizado cuando el
  segundo `PATCH` responde antes. Después vuelve a `concatMap` y muestra la prueba en
  verde.
- 🔥 Paga la deuda de la sección 💸: extrae `grantRequest$` y deja `sendGrantEpic` y
  `retryGrantEpic` usándola. **Criterio:** las pruebas de los patrones 5, 7 y 8 siguen
  en verde sin cambiar una línea.

---

## 📚 Referencias

### Documentación oficial

- **redux-observable (1.x)** — README, epics, `combineEpics` y las dependencias de los
  epics: https://redux-observable.js.org
  > ⚠️ La documentación actual cubre 1.x y 2.x; el curso está fijado en **1.2.0**.
  > Ignora cualquier nota de migración a 2.x.
- **RxJS 6** — operadores, `pipe`, creación de Observables: https://rxjs.dev
  > ⚠️ El sitio documenta **RxJS 7+** por defecto. Estamos en **6.6.7**: operadores
  > desde `rxjs/operators`, y `retryWhen` en lugar de `retry({ delay })`. Verifica
  > siempre la firma contra la 6.
- **Los operadores de este apéndice** (búscalos en rxjs.dev, en la sección de RxJS 6):
  `debounceTime`, `switchMap`, `mergeMap`, `concatMap`, `exhaustMap`, `groupBy`,
  `takeUntil`, `retryWhen`, `catchError`.
- **rxjs-marbles** — sintaxis de diagramas, integración con Jest, `cold`, `hot` y
  `expect`: https://github.com/cartant/rxjs-marbles
- **Pruebas de canicas (el concepto)** — la guía oficial de `TestScheduler`, que es lo
  que rxjs-marbles usa por debajo: https://rxjs.dev/guide/testing/marble-testing

> 📝 Las URL y los títulos pueden haber cambiado desde la redacción; verifícalos. No
> se citan versiones exactas de página ni anclas internas, que envejecen rápido.

### Orden de lectura sugerido

README de redux-observable → los operadores de RxJS 6 (empieza por `switchMap` contra
`mergeMap`) → vuelve a la [tabla maestra](#-tabla-maestra-cuándo-usar-qué-operador) de
este apéndice → `A11-marble-testing.md` para escribir la primera prueba → Fase 10 para
aplicarlo sobre los epics del proyecto.

### Dentro del curso

- **Fase 6 — redux-observable a fondo:** el código completo de los epics de envíos y
  búsqueda, y el leak a propósito.
- **Fase 7 — cierre y polling:** donde `timer`, `takeWhile` y `takeUntil` se vuelven
  polling de verdad, y la guarda de cierre entra en los epics.
- **`A11-marble-testing.md`:** la metodología completa de las pruebas de canicas.
- **Fase 6 §6 y la sección 🩸 de este apéndice:** el procedimiento de caza de leaks.
- **`cuaderno-incidentes.md`, incidentes 13, 14, 15 y 17:** los cuatro bugs de epics
  con su ticket delante.

---

> 🏷️ **Este apéndice no lleva tag propio.** Es material de consulta: si no cambia el
> repo, no hay nada que apuntar. Cuando de leerlo sí salga código —un operador
> cambiado en un epic—, commitéalo con el prefijo de la fase desde la que llegaste
> (`f06: …`), no con el del apéndice, para que el `git log --oneline --grep '^f06'` de
> esa fase siga completo. Y si el ejercicio produjo una medición, el número va en el
> mensaje del tag (`ej/a7/3`), que es donde no se pierde. Todo eso está en
> [`00-convencion-de-git-y-tags.md`](00-convencion-de-git-y-tags.md).
