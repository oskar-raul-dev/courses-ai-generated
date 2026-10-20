# 🔬 Apéndice A11 — Pruebas de canicas con rxjs-marbles
## Tutorial React 16 — La Esclusa, la consola de Jewel Locks

> **Material de consulta rápida** · **~2,5 horas** · Lo usan las Fases 6, 7 y 10, y los
> incidentes 13–17 · Prioridad: 🔴 Alta
> RxJS **6.6.7** · rxjs-marbles **6.0.1** (D9) · Jest 26 (viene con CRA 4)

Esto no se lee de corrido. Es la página que abres cuando tienes que escribir —o
leer— una prueba de un epic y no te acuerdas de si el diagrama va con `hot` o con
`cold`, o de cómo se escriben los trescientos milisegundos de un `debounceTime`.

Es el apéndice que cierra el círculo del curso. La Fase 6 te enseñó a escribir epics
que se cancelan solos; la Fase 7 los puso bajo presión de red real; este apéndice es
el que te deja **demostrar** que la cancelación ocurre. Sin él, que un `takeUntil`
funcione es una creencia. Con él, es una aserción.

Todas las pruebas de esta página están escritas contra los epics de la consola tal
como quedan al cerrar la Fase 7, y pasan. Para correrlas, rxjs-marbles se instala
fijado, como manda D9 (la Fase 10 lo agrega de forma permanente):

```bash
npm install --save-dev --save-exact rxjs-marbles@6.0.1
```

---

## 🧭 Índice de salto rápido

1. [Por qué los epics no se prueban con timers reales](#1-por-qué-los-epics-no-se-prueban-con-timers-reales)
2. [El diagrama, símbolo por símbolo](#2-el-diagrama-símbolo-por-símbolo)
3. [`hot` frente a `cold`, y cuándo usar cada uno](#3-hot-frente-a-cold-y-cuándo-usar-cada-uno)
4. [El molde base de una prueba de epic](#4-el-molde-base-de-una-prueba-de-epic)
5. [Probar `debounceTime`](#5-probar-debouncetime)
6. [Probar `switchMap` (la cancelación del anterior)](#6-probar-switchmap-la-cancelación-del-anterior)
7. [Probar `takeUntil` (el corte, y el leak que previene)](#7-probar-takeuntil-el-corte-y-el-leak-que-previene)
8. [Probar un polling periódico](#8-probar-un-polling-periódico)
9. [Errores comunes al escribir canicas](#9-errores-comunes-al-escribir-canicas)
10. [🧩 Cuándo usar qué](#-cuándo-usar-qué)
11. [🧪 Ejercicios](#-ejercicios-8)

---

## 1. Por qué los epics no se prueban con timers reales

Un epic con `debounceTime(300)` probado con un `setTimeout` de verdad tiene tres
problemas, y el tercero es el que importa.

**Es lento.** Cada prueba espera 300 milisegundos reales; la ventana de deshacer, diez
segundos. Con veinte pruebas de epics, la suite se pasa minutos esperando. Molesto, no
fatal.

**Es frágil.** El `setTimeout` de la prueba y el del epic compiten en el mismo event
loop. A veces la aserción corre antes de que el epic emita y la prueba falla sin que
nada esté roto. Eso es una prueba **intermitente**, y una prueba intermitente es peor
que ninguna: entrena al equipo a ignorar el rojo.

**Y —lo determinante— no puede probar lo que más importa.** La aserción clave de un
epic no es "emitió esto"; es **"no emitió nada después del corte"**. Con timers
reales, "no emitió nada" solo se puede afirmar esperando… ¿cuánto? ¿Un segundo?
¿Diez? Nunca sabes si esperaste lo suficiente. Es la misma razón por la que un memory
leak de suscripción es invisible: la ausencia de un evento no se observa esperando.

La solución es un **reloj virtual**. El `TestScheduler` de RxJS avanza el tiempo en
pasos que tú controlas: los diez segundos de la ventana "pasan" al instante y de
forma determinista, y el scheduler sabe con certeza qué emitió el stream y cuándo.
rxjs-marbles es un envoltorio fino sobre ese scheduler que te deja escribir el flujo
como un diagrama.

> 🧠 **La frase que resume el apéndice.** Las canicas no sirven para verificar *qué*
> emite un epic —eso lo cubre una prueba de reducer, más barata—. Sirven para
> verificar **cuándo emite y qué deja de emitir**. Si tu prueba de canicas no depende
> del tiempo, probablemente no necesitabas canicas.

---

## 2. El diagrama, símbolo por símbolo

| Símbolo | Significa |
|---|---|
| `-` | un frame de tiempo virtual sin emisión |
| `a`, `b`, `c`… | una emisión con ese valor (lo defines en el objeto de valores) |
| `\|` | el stream **completa** |
| `#` | el stream **emite error** |
| `(ab)` | `a` y `b` emiten **en el mismo frame** |
| `300ms` | avanza trescientos frames de golpe (va entre espacios) |
| `^` y `!` | en un diagrama de suscripción: dónde empieza y dónde se corta |

rxjs-marbles 6 corre adentro de `TestScheduler.run`, y en ese modo **un frame es un
milisegundo virtual**. Por eso `300ms` existe: escribir trescientos guiones sería
ilegible, y la ventana de deshacer necesitaría diez mil. Y por eso los epics no
reciben ningún scheduler: adentro de `run`, `debounceTime`, `timer` y compañía usan el
tiempo virtual solos.

> ⚠️ **Los dos detalles que confunden a todo el mundo la primera vez.** Los espacios
> **no cuentan** como frames en ningún lugar del diagrama: solo separan, y te permiten
> alinear diagramas. Y un grupo `(ab)` **ocupa tantos frames como caracteres tiene**:
> en `-(st)c`, `s` y `t` caen en el frame 1 y `c` en el 5, no en el 2.

---

## 3. `hot` frente a `cold`, y cuándo usar cada uno

Es la distinción que más errores causa, y la regla práctica es corta.

**`m.hot(...)`** — un Observable que **ya está corriendo**. Los suscriptores se
enganchan donde va y se pierden lo anterior. Es la naturaleza de `action$`: el stream
de acciones del store existe desde que arrancó la aplicación. **Úsalo siempre para
`action$`.**

**`m.cold(...)`** — un Observable que **arranca cuando alguien se suscribe**, desde su
frame 0, y que arranca de nuevo **por cada** suscriptor. Es la naturaleza de una
petición HTTP: no ocurre nada hasta que el epic se suscribe. **Úsalo para las
respuestas del `api` y del `store` falsos.**

La confusión típica es usar `cold` para `action$`, y lo traicionero es que con una
sola suscripción los dos se comportan igual. La diferencia aparece cuando el epic se
suscribe a `action$` **más de una vez**, que es exactamente lo que hace un `takeUntil`
que escucha acciones. Este par de pruebas usa el mismo diagrama contra
`undoWindowEpic`:

```javascript
test("hot: el «Deshacer» a los 6 s del encolado corta la ventana", marbles((m) => {
  const action$ = m.hot("5000ms q 6000ms u", { q: juanQueued, u: undoGrant(juan.id) });
  m.expect(undoWindowEpic(action$)).toBeObservable("");
}));
```

```javascript
test("cold: el mismo diagrama deja salir el envío, porque el takeUntil ve su propia copia", marbles((m) => {
  const action$ = m.cold("5000ms q 6000ms u", { q: juanQueued, u: undoGrant(juan.id) });
  // El takeUntil se suscribe en el frame 5000 y su copia del «Deshacer» llega en el 16001:
  // tarde para una ventana que vence en el 15000.
  m.expect(undoWindowEpic(action$)).toBeObservable("15000ms s", { s: sendGrantRequested(juan.id) });
}));
```

Con `hot`, el «Deshacer» del frame 11001 corta la ventana, que vencía en el 15000. Con
`cold`, el `takeUntil` se suscribe en el frame 5000 y recibe **su propia copia** del
stream, que empieza de cero: su «Deshacer» llega en el 16001, tarde. La misma prueba,
con la misma intención, da el resultado contrario. Una prueba escrita con `cold` no
está probando cómo funciona Redux.

> 💡 **El truco para no dudar:** pregúntate si el evento habría ocurrido igual sin que
> nadie lo mirara. Un clic del operador, sí → `hot`. Una petición HTTP que solo sale
> porque alguien se suscribió, no → `cold`.

---

## 4. El molde base de una prueba de epic

Tres piezas: el diagrama de entrada, el diagrama esperado, y el objeto de valores que
le da significado a cada letra. El epic más simple de la consola, `cancelOnLogoutEpic`,
alcanza para verlas:

```javascript
test("el logout reinicia los envíos", marbles((m) => {
  const action$ = m.hot("  -L", { L: logout() });
  const expected = "       -r";
  const values = { r: grantsReset() };
  m.expect(cancelOnLogoutEpic(action$)).toBeObservable(expected, values);
}));
```

**Alinea los diagramas visualmente.** Que `action$` y `expected` empiecen en la misma
columna hace que el tiempo se lea de un vistazo. Los espacios no cuentan como frames
justamente para que puedas hacer esto.

**Pasa las dependencias como el middleware.** Los epics de la consola reciben
`(action$, state$, { api, store, now })`. En la prueba, `state$` es un objeto con
`value` y las dependencias son objetos falsos que devuelven un `m.cold(...)`. Es lo
que la Fase 6 preparó al pasar el cliente HTTP por `createEpicMiddleware({
dependencies })`: un epic que importara su cliente solo se probaría con un servidor
levantado.

**Nombra la prueba por el comportamiento, no por el operador.** *"Tipear rápido busca
una sola vez"* te dice qué se rompió cuando falla; *"prueba de debounceTime"*, no.

---

## 5. Probar `debounceTime`

El escenario: el operador escribe `A`, `An` y `Ana` en el buscador del asistente, las
tres teclas dentro de la ventana del debounce. `searchPlayerEpic` tiene que buscar
**una sola vez**, con el último texto.

```javascript
test("tipear rápido busca una sola vez, con el último texto", marbles((m) => {
  const calls = [];
  const api = { get: (url, { params }) => { calls.push(params.name_like); return m.cold("r|", { r: { data: [] } }); } };
  const action$ = m.hot("-a-b-c", {
    a: playerSearchRequested("A"),
    b: playerSearchRequested("An"),
    c: playerSearchRequested("Ana"),
  });
  // La última tecla cae en el frame 5; la búsqueda sale SEARCH_DEBOUNCE_MS después.
  m.expect(searchPlayerEpic(action$, null, { api })).toBeObservable(`----- ${SEARCH_DEBOUNCE_MS}ms s`, {
    s: playerSearchSucceeded({ query: "Ana", results: [] }),
  });
  m.flush();
  expect(calls).toEqual(["Ana"]);
}));
```

La aserción que importa no es *dónde* aparece la `s`: es que **haya una sola letra** en
el diagrama esperado, y que el `api` falso haya recibido una sola búsqueda. Si el
debounce desaparece del epic, el diagrama tendría tres emisiones y la prueba falla.

> 💡 **La prueba importa la constante del epic.** `SEARCH_DEBOUNCE_MS` viene del mismo
> archivo que el epic, y la prueba la interpola en el diagrama. Si mañana alguien sube
> el debounce a 400, la prueba sigue en verde, que es lo correcto: lo que protege es el
> comportamiento ("una sola búsqueda, la última"), no el número.

---

## 6. Probar `switchMap` (la cancelación del anterior)

El escenario: el operador busca `Ana`, la búsqueda sale y va a tardar, y antes de que
vuelva busca `Anaís`. `switchMap` tiene que **cancelar** la de `Ana`, aunque su
respuesta llegue después.

```javascript
test("la búsqueda nueva cancela la vieja aunque la vieja responda después", marbles((m) => {
  const ANA = [{ id: 44, name: "Ana", status: "banned" }, { id: 45, name: "Anaís", status: "active" }];
  const ANAIS = [{ id: 45, name: "Anaís", status: "active" }];
  const api = {
    get: (url, { params }) =>
      params.name_like === "Ana" ? m.cold("500ms r|", { r: { data: ANA } }) : m.cold("100ms r|", { r: { data: ANAIS } }),
  };
  const action$ = m.hot("-a 400ms b", { a: playerSearchRequested("Ana"), b: playerSearchRequested("Anaís") });
  m.expect(searchPlayerEpic(action$, null, { api })).toBeObservable("802ms s", {
    s: playerSearchSucceeded({ query: "Anaís", results: ANAIS }),
  });
}));
```

> 🧠 **La lección general de esta prueba.** La aserción vive en lo que *falta* del
> diagrama esperado. Es el único estilo de prueba del curso donde la ausencia de algo
> es la verificación, y por eso las canicas son irreemplazables para la cancelación:
> cualquier otra herramienta te obligaría a esperar y confiar.

Para distinguirlo de `mergeMap`: cambia el operador del epic y corre esta misma
prueba. **Tiene** que fallar, con dos `playerSearchSucceeded` y la de `Ana` al final,
que es el incidente 15. Si no falla, la prueba no está probando lo que crees, y ese
ejercicio de verificar la prueba rompiendo el código es el 5 de abajo.

---

## 7. Probar `takeUntil` (el corte, y el leak que previene)

El escenario: un envío entra en su ventana de deshacer y, antes de que venza, el
operador cierra sesión. `undoWindowEpic` no tiene que emitir nada.

```javascript
test("el logout dentro de la ventana corta el timer: no sale nada", marbles((m) => {
  const action$ = m.hot("-q 3000ms L", { q: juanQueued, L: logout() });
  m.expect(undoWindowEpic(action$)).toBeObservable("");
}));
```

Esta prueba es **la red que atrapa el leak**. Si alguien borra el logout del
`takeUntil`, el diagrama recibido tiene un `sendGrantRequested` en el frame 10001 y el
esperado está vacío: la prueba falla exactamente donde vive el leak, que es lo que
ninguna herramienta manual logra.

Un corte tiene que ser **preciso**, además de existir. La segunda prueba de la sección
comprueba el `filter`: el «Deshacer» de otro envío no corta esta ventana.

```javascript
test("el «Deshacer» de OTRO envío no corta esta ventana", marbles((m) => {
  const action$ = m.hot("-q 5000ms u", { q: juanQueued, u: undoGrant("g-otro") });
  m.expect(undoWindowEpic(action$)).toBeObservable("- 10000ms s", { s: sendGrantRequested(juan.id) });
}));
```

> ⚠️ **Usa el action creator, nunca el string.** `logout()` y no `{ type: "LOGOUT" }`.
> El type real es `auth/logout`, porque lo genera `createSlice`, y un string mal escrito
> en la prueba no falla por sí mismo: hace que el corte no coincida con nada, el epic no
> se corte, y la prueba falle con un mensaje de tiempo que te manda a buscar el bug al
> lugar equivocado. Es el mismo error que la Fase 6 documenta en el código de
> producción, y muerde igual de fuerte en las pruebas.

---

## 8. Probar un polling periódico

El otro sabor de `takeUntil`: cortar un flujo que emitiría para siempre. `pollingEpic`
pregunta cada `POLLING_INTERVAL_MS` hasta que la compra se confirma, el operador lo
para, o se cierra la sesión.

```javascript
test("el polling pregunta cada POLLING_INTERVAL_MS y deja de preguntar con el stop", marbles((m) => {
  let calls = 0;
  const store = { get: () => { calls += 1; return m.cold("r|", { r: { data: { state: "pending" } } }); } };
  const action$ = m.hot("a 4500ms S", { a: startPolling("tok-oxxo-2"), S: stopPolling() });
  const tick = expect.objectContaining({ type: "purchases/purchaseStatusReceived" });
  // Ticks en 0, 2000 y 4000; el stop en 4501; la prueba mira hasta el 15000.
  m.expect(pollingEpic(action$, null, { store }), "^ 15000ms !").toBeObservable(
    `p ${POLLING_INTERVAL_MS - 1}ms q ${POLLING_INTERVAL_MS - 1}ms r`,
    { p: tick, q: tick, r: tick }
  );
  m.flush();
  expect(calls).toBe(3);
}));
```

La diferencia con §7 es de naturaleza, no de técnica: allá el `timer` emitía una vez y
el `takeUntil` prevenía esa única emisión; acá el `timer` emitiría indefinidamente. Por
eso esta prueba lleva un **diagrama de suscripción** (`"^ 15000ms !"`): le dice a la
prueba que mire quince segundos y corte. Sin él, si el corte fallara, el tiempo virtual
correría para siempre.

La otra salida del polling, la confirmación, se prueba sin diagrama de suscripción,
porque el propio epic termina el `timer`:

```javascript
test("el polling termina solo cuando la compra se confirma", marbles((m) => {
  let calls = 0;
  const store = {
    get: () => {
      calls += 1;
      const state = calls < 3 ? "pending" : "confirmed";
      return m.cold("r|", { r: { data: { state } } });
    },
  };
  const action$ = m.hot("a", { a: startPolling("tok-efecty-1") });
  const status = (state) => expect.objectContaining({ payload: expect.objectContaining({ state }) });
  // Sin marca de suscripción: el takeWhile completa el timer, y el tiempo virtual termina.
  m.expect(pollingEpic(action$, null, { store })).toBeObservable(
    `p ${POLLING_INTERVAL_MS - 1}ms q ${POLLING_INTERVAL_MS - 1}ms c`,
    { p: status("pending"), q: status("pending"), c: status("confirmed") }
  );
  m.flush();
  expect(calls).toBe(3);
}));
```

> 💡 **Ese detalle es también el diagnóstico.** Si escribiendo la prueba de un epic te
> das cuenta de que no puedes expresar el diagrama esperado sin cortar la suscripción a
> mano, porque el stream no termina nunca, acabas de encontrar un epic que depende de
> que alguien lo corte desde afuera. La prueba te dijo dónde mirar antes de correrla.

---

## 9. Errores comunes al escribir canicas

**Usar `cold` para `action$`.** La prueba pasa o falla por la razón equivocada en
cuanto el epic tiene un `takeUntil` que escucha acciones. §3.

**Contar mal los frames.** El diagrama esperado no cuadra por uno o dos frames y el
mensaje de error habla de tiempo, no de tu operador. El sospechoso habitual es un grupo
`(ab)`, que ocupa cuatro frames y no uno. Antes de tocar el epic, cuenta de nuevo, y
escribe los tiempos largos con `ms` y con las constantes del epic (§5).

**Un `timer` infinito sin corte en la prueba.** Si el epic arranca un polling y la
prueba no lo para —ni con una acción de stop, ni con un diagrama de suscripción—, el
tiempo virtual no termina nunca: la prueba se cuelga y Jest muere por memoria. No es un
bug del epic, es una prueba sin final. §8.

**Probar el valor en vez del tiempo.** Si la aserción es "emitió esta acción con este
payload" y el diagrama tiene una sola letra sin tiempo interesante, esa prueba es una
prueba de reducer disfrazada. Escríbela como prueba de reducer: es más rápida, más
clara y no depende de RxJS.

**Escribir el action type a mano.** §7. Usa siempre el creator.

**Mezclar rxjs-marbles 7 con RxJS 6.** El paquete ata su major a la de RxJS.
`npm install rxjs-marbles` a secas te trae la 7 contra tu RxJS 6.6.7, y las pruebas
fallan con errores de scheduler que no dicen nada útil. Va fijado en `6.0.1` (D9).

**Copiar ejemplos de rxjs-marbles en modo viejo.** Antes de la 4 (mayo de 2018),
rxjs-marbles no corría en `run`: los ejemplos de esa época le pasan `m.scheduler` a cada operador, o
llaman a `m.bind()`. En la 6.0.1, `m.bind()` lanza un error ("not supported") y pasar el
scheduler sobra. Si ves eso en un ejemplo, es de otra versión.

> 📝 **Y uno que no es error.** Hay ejemplos de redux-observable 1.x que envuelven el
> `m.hot(...)` en `new ActionsObservable(...)`. Hace falta solo si el epic usa el
> método `action$.ofType(...)`, que es del estilo anterior. Los epics de la consola usan
> el operador `ofType` dentro del `pipe`, que funciona sobre cualquier Observable, y por
> eso todas las pruebas de esta página le pasan el `m.hot` directo.

---

## 🧩 Cuándo usar qué

- **Verificar que un reducer produce el estado correcto** → prueba de reducer, sin
  canicas (Fase 10).
- **Verificar que un selector memoiza** → prueba de identidad referencial, sin canicas
  (Fase 10).
- **Verificar que un epic emite la acción correcta** → si el tiempo no importa, una
  prueba normal con `toPromise()` alcanza y se lee mejor.
- **Verificar un `debounceTime`** → canicas (§5).
- **Verificar que `switchMap` cancela** → canicas (§6). No hay alternativa.
- **Verificar que un `takeUntil` corta** → canicas (§7 y §8). No hay alternativa, y es
  la prueba más valiosa del curso.
- **Verificar un backoff con `retryWhen`** → canicas, con el backoff escrito en `ms`
  en el diagrama. Está trabajado en `A7-redux-observable-epica-por-epica.md`, patrón 7.

---

## 🧪 Ejercicios (8)

1. **🟢** Copia la prueba de §4, confirma que pasa, y después mueve la `r` del diagrama
   esperado un frame a la derecha para verla fallar. **Criterio:** lees el mensaje de
   error y señalas en él el frame esperado y el recibido; es el mensaje que vas a ver
   siempre.
2. **🟢** Toma la prueba de §7 (el logout) y cambia `m.hot` por `m.cold` en `action$`.
   **Criterio:** documentas qué pasa y lo explicas con §3 delante: ¿por qué acá el
   cambio no altera el resultado y en la pareja de §3 sí?
3. **🟡** Escribe la prueba de `undoWindowEpic` para el «Enviar ahora»: un
   `sendGrantRequested` del mismo envío a los dos segundos corta la ventana.
   **Criterio:** el diagrama esperado no tiene el `sendGrantRequested` del frame 10001,
   y la prueba falla si quitas `sendGrantRequested.match` del `filter`.
4. **🟡** Escribe la prueba de `retryGrantEpic` que verifica que reintenta ante un
   `timeout` y **no** ante un `409`. **Criterio:** dos pruebas, y la del `409` comprueba
   con un contador que salió una sola petición.
5. **🟠 Verifica tu propia prueba.** Cambia el `switchMap` de `searchPlayerEpic` por
   `mergeMap` y corre la prueba de §6. **Criterio:** la prueba falla. Si pasa, tu prueba
   no probaba la cancelación: arréglala hasta que falle, y recién ahí revierte el epic.
   Una prueba que no falla cuando el código se rompe es decoración.
6. **🟠** Escribe la prueba del polling con un `500` en el segundo tick: el tercer tick
   pregunta igual. **Criterio:** el diagrama esperado tiene un `pollingFailed` entre dos
   `purchaseStatusReceived`, y la prueba falla con la rama `incidente/17`.
7. **🔴 Diagnóstico.** Te entregan un epic y su prueba de canicas en verde, pero en
   producción el epic sigue consultando después del logout. La prueba pasa y el bug
   existe: **la prueba está mal**. **Criterio:** encuentras qué no está verificando (pista:
   ¿hay algún logout en su diagrama de entrada?), la reescribes, y demuestras que ahora
   falla con el epic actual. La rama `incidente/14` sirve de epic.
8. **🔴** Toma los epics de la consola —`undoWindowEpic`, `sendGrantEpic`,
   `searchPlayerEpic`, `retryGrantEpic`, `pollingEpic`— y escribe, para cada uno, **la
   prueba de cancelación**. Solo la de cancelación. **Criterio:** cinco pruebas en verde,
   y cada una falla si borras la línea que corta. Al terminar tienes la red que le falta
   al sistema heredado, que es el entregable que un equipo de mantenimiento agradecería
   más.

**🔥 Opcionales**

- 🔥 Reescribe una de estas pruebas con el `TestScheduler` crudo de RxJS, sin
  rxjs-marbles: `new TestScheduler(...)` y `scheduler.run(({ hot, cold,
  expectObservable }) => …)`. Compara la verbosidad. Las pruebas de regresión del
  cuaderno de incidentes están escritas así, porque un incidente de la Fase 6 se
  resuelve antes de que la Fase 10 instale rxjs-marbles.
- 🔥 Para `sendGrantEpic`, la prueba del doble clic necesita `groupBy` y `exhaustMap` a la
  vez. Escribe la variante en la que el segundo clic es **de otro envío**, y demuestra
  que ese sí sale.

---

## 📚 Referencias

**Documentación oficial**

- rxjs-marbles — https://github.com/cartant/rxjs-marbles — la API de `marbles()`,
  `m.hot`, `m.cold`, `m.expect` y `m.flush`. **Ojo con la versión:** el README actual
  cubre la línea 7; nosotros usamos la 6, que corresponde a RxJS 6.
- Pruebas de canicas en RxJS — https://rxjs.dev/guide/testing/marble-testing — la
  referencia del `TestScheduler`, de `run()` y de la gramática del diagrama, incluida la
  sintaxis de tiempo (`300ms`). `run()` existe desde RxJS 6, así que la gramática
  aplica tal cual; lo que es de la 7 son algunas APIs alrededor.
- redux-observable — https://redux-observable.js.org — la receta oficial de pruebas de
  epics. Corresponde a la línea 1.x, que es la nuestra (D2).
- Jest 26 — https://archive.jestjs.io/docs/en/26.x/expect — la referencia archivada de
  la versión que trae CRA 4.

**Orden de lectura sugerido:** §1 y §2 de este apéndice (el porqué y la gramática) →
§4 (el molde) → escribe la prueba de §5 con la documentación de rxjs-marbles abierta →
§7, que es la que de verdad justifica todo el aparato.

> ⚠️ La documentación oficial de RxJS y de rxjs-marbles cubre hoy la línea 7. La
> gramática del diagrama aplica, pero algunas APIs no: si un ejemplo importa operadores
> desde `rxjs` directo, o usa `firstValueFrom`, es RxJS 7 y no compila contra nuestro
> 6.6.7. Verifica siempre.

---

## 🚀 Y ahora, de vuelta al código

Si viniste desde la Fase 10, vuelve a ella y sigue. Si viniste desde la Fase 6 o la 7
persiguiendo un epic que no cancela, la prueba de §7 es la herramienta, y los
incidentes **14** y **17** del `cuaderno-incidentes.md` son ese problema con un ticket
delante.

> **La señal de que quedó bien:** cuando escribas un epic nuevo y, antes de pensar qué
> acción emite, te preguntes *"¿cómo se corta esto y cómo lo pruebo?"*. Ese orden
> —cancelación primero— es lo que separa un epic que envejece bien de uno que deja
> fantasmas.

---

> 🏷️ **Este apéndice deja código: márcalo.** Cuando termines lo que viniste a hacer
> acá, con `git status` limpio:
>
> ```bash
> git tag -a apendice-a11-marble-testing -m "A11: primera prueba de canicas de cancelación en verde, con rxjs-marbles 6.0.1 en el proyecto."
> ```
>
> Los commits llevan su prefijo (`a11: …`) y los de ejercicio su número (`a11 ej3: …`).
> La convención completa —tags de fase, de ejercicio y de incidente— está en
> [`00-convencion-de-git-y-tags.md`](00-convencion-de-git-y-tags.md).
