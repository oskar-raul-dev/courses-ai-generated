# 🎨 Apéndice A7 — Redux-Observable Épica por Épica

> Material de **consulta rápida**, no de lectura secuencial. Se usa desde la
> Fase 6 en adelante. Cuando estés escribiendo un epic y no te acordás si va
> `switchMap` o `mergeMap`, saltás acá, mirás el patrón, copiás el molde y
> volvés. Cada patrón trae lo mismo: **cuándo usarlo · ejemplo mínimo (un
> epic real de rifas) · el error común que te va a morder · cómo probarlo con
> marbles**.

Stack fijado (no lo cambies sin justificar): **redux-observable 1.2.0 · RxJS
6.6.7 · rxjs-marbles para marble testing (D9) · JavaScript plano ES2019**.
Todos los epics de acá son los mismos de la Fase 6 —`sellNumberEpic`,
`validateNumberEpic`, `reservationExpirationEpic`, `retrySellEpic`,
`cancelOnLogoutEpic`— o extensiones coherentes con ellos.

---

## ⚡ Cómo usar este apéndice (mapa de 30 segundos)

Los ocho operadores se parten en dos familias. La primera decide **qué pasa
con la operación anterior cuando llega una nueva acción**: esa decisión es,
en la práctica, el 80% de los bugs de epics. La segunda familia se ocupa de
**no morir**: cancelar limpio, reintentar con cabeza y sobrevivir a un error.

- **Mapeo (flattening):** `debounceTime`, `switchMap`, `mergeMap`, `concatMap`, `exhaustMap`.
- **Cancelación y resiliencia:** `takeUntil`, `retry`/`retryWhen`, `catchError`.

Si solo tenés diez segundos: elegir mal entre `switchMap` y `mergeMap` es la
causa raíz más común de "pintó un estado viejo" y de "se me duplicó la venta".
Andá directo a la [tabla maestra](#-tabla-maestra-cuándo-usar-qué-operador).

---

## 🧭 Salto rápido

**Mapeo**
1. [`debounceTime` — esperar a que pare de tipear](#1-debouncetime--esperar-a-que-pare-de-tipear)
2. [`switchMap` — el último gana, cancela lo anterior](#2-switchmap--el-último-gana-cancela-lo-anterior)
3. [`mergeMap` — todo en paralelo](#3-mergemap--todo-en-paralelo)
4. [`concatMap` — encolar y respetar el orden](#4-concatmap--encolar-y-respetar-el-orden)
5. [`exhaustMap` — ignorar lo nuevo mientras proceso](#5-exhaustmap--ignorar-lo-nuevo-mientras-proceso)

**Cancelación y resiliencia**
6. [`takeUntil` — apagar el stream ante un trigger](#6-takeuntil--apagar-el-stream-ante-un-trigger)
7. [`retryWhen` — reintentar transitorios con backoff](#7-retrywhen--reintentar-transitorios-con-backoff)
8. [`catchError` — que un error no mate el epic](#8-catcherror--que-un-error-no-mate-el-epic)

**Soporte**
- [Tabla maestra: cuándo usar qué operador](#-tabla-maestra-cuándo-usar-qué-operador)
- [Chuleta de imports (RxJS 6, ojo con RxJS 7)](#-chuleta-de-imports-rxjs-6-ojo-con-rxjs-7)
- [🩸 Memory leaks en epics: cómo se ven, cómo se previenen](#-memory-leaks-en-epics-cómo-se-ven-cómo-se-previenen)
- [🔬 Marble testing con rxjs-marbles: sintaxis mínima](#-marble-testing-con-rxjs-marbles-sintaxis-mínima)
- [🧪 Ejercicios (8)](#-ejercicios-8)
- [📚 Referencias](#-referencias)

---

## 📊 Tabla maestra: cuándo usar qué operador

| Situación en Rifas y chances | Operador | Qué hace con lo anterior | Antipatrón si te equivocás |
|---|---|---|---|
| El usuario tipea un número y validás contra la API | `switchMap` | **Cancela** la validación anterior en vuelo | `mergeMap` → la respuesta de `034` llega tras la de `0347` y pinta un estado viejo |
| Validación/búsqueda: esperar a que pare de tipear | `debounceTime(300)` | Descarta lo intermedio, deja pasar el último | Sin él: una petición por tecla, floodeás el mock |
| Expiración de reservas de números **distintos**, en paralelo | `mergeMap` | **Nada**: corren todas concurrentes | `switchMap` → reservar `0912` cancela la expiración del `0347` |
| Cola de operaciones que deben aplicarse **en orden** | `concatMap` | **Espera** a que termine la anterior | `mergeMap` → orden no garantizado, estado inconsistente |
| Submit de "Vender" (evitar doble venta por doble click) | `exhaustMap` | **Ignora** disparos mientras hay uno en curso | `mergeMap` → dos POST `/sell` para el mismo número |
| Cortar cualquier stream al `LOGOUT` / desmontar | `takeUntil(logout$)` | Completa y ejecuta el teardown | Olvidarlo → suscripción zombi, acciones fantasma |
| Fallo transitorio (`timeout`, `http` 5xx) al vender | `retryWhen` + backoff | Reintenta N veces con espera creciente | `retry` a secas → martillás el server; reintentar un `conflict` → vendés dos veces |
| Que un error no mate el epic | `catchError(e => of(action))` | Reemplaza el error por una acción | Sin él → el epic se completa y **deja de escuchar para siempre** |

> 💡 **Mnemotecnia que cierra la tabla:** *switch* = el último gana · *merge*
> = todos a la vez · *concat* = uno detrás de otro · *exhaust* = el primero
> manda hasta que termine. Los cuatro reciben acciones y devuelven un
> Observable interno; lo único que cambia es **qué hacen con el interno
> anterior cuando llega uno nuevo.**

---

## 🧾 Chuleta de imports (RxJS 6, ojo con RxJS 7)

Fijado RxJS **6.6.7**. Los operadores viven en `rxjs/operators` y los
creadores de Observable en `rxjs`. Esto **no** es intercambiable con RxJS 7.

```javascript
// ✅ RxJS 6 — así se importa en todo el curso
import { from, of, timer, interval, throwError } from 'rxjs';
import {
  map, filter, debounceTime,
  switchMap, mergeMap, concatMap, exhaustMap,
  takeUntil, retryWhen, catchError,
} from 'rxjs/operators';

// ❌ RxJS 7 (NO usar en código principal) — firstValueFrom/lastValueFrom no existen en 6,
//    y en 7 se desalienta retryWhen a favor de retry({ delay }). Acá seguimos en 6.
```

> ⚠️ **Trampa de versión.** Mucho tutorial de RxJS que encontrás online es 7+.
> Si ves `retry({ count, delay })`, `firstValueFrom`, o imports de operadores
> desde `rxjs` directo (no `rxjs/operators`), es RxJS 7 y **no compila igual
> acá**. En 6 usamos `retryWhen` con `timer` para el backoff (patrón 7).

---

## Patrones de mapeo (flattening)

### 1. `debounceTime` — esperar a que pare de tipear

**Cuándo.** Cuando llegan muchas emisiones seguidas y solo te importa la
última *después de una pausa*. El caso canónico: el usuario tipea el número
que quiere vender y no querés pegarle a la API en cada tecla.

**Ejemplo mínimo** (el `validateNumberEpic` de Fase 6, recortado a lo esencial):

```javascript
// El componente despacha numberValidationRequested({ raffleId, number }) en cada cambio del input.
export const validateNumberEpic = (action$) =>
  action$.pipe(
    ofType(numberValidationRequested.type),
    debounceTime(300),        // espera 300ms de silencio antes de dejar pasar el último
    switchMap((action) => {   // debounce + switchMap es el dúo clásico de validación
      const { raffleId, number } = action.payload;
      return from(apiClient.get(`/raffles/${raffleId}/numbers/${number}`)).pipe(
        map((response) => numberValidationSucceeded({ number, status: response.data.status })),
        catchError((error) => of(numberValidationFailed({ number, error: toReadableError(error) })))
      );
    })
  );
```

**Error común.** Poner `debounceTime` pero olvidar `switchMap` y usar
`mergeMap`. El debounce reduce la cantidad de peticiones, pero si el usuario
tipea `034`, espera, y sigue con `0347`, dos validaciones pueden quedar en
vuelo y la lenta pisar a la rápida. `debounceTime` controla *cuándo salís*;
`switchMap` controla *que la anterior muera*. Necesitás los dos.

**Cómo probarlo con marbles.** Se testea que emisiones dentro de la ventana se
colapsan en una sola:

```javascript
it('debounceTime(300): colapsa tecleos rápidos en una sola validación', marbles((m) => {
  // Tres cambios de input separados por menos de 300ms; solo el último debe disparar.
  const action$ = m.hot('  -a-b-c-------|', {
    a: { type: numberValidationRequested.type, payload: { raffleId: 1, number: '03' } },
    b: { type: numberValidationRequested.type, payload: { raffleId: 1, number: '034' } },
    c: { type: numberValidationRequested.type, payload: { raffleId: 1, number: '0347' } },
  });
  // La aserción del debounce en sí: solo 'c' sobrevive la ventana de silencio.
  // (El mock de apiClient responde inmediato para aislar el comportamiento del debounce.)
  m.expect(action$.pipe(debounceTime(300, m.scheduler))).toBeObservable('-------c----|', {
    c: { type: numberValidationRequested.type, payload: { raffleId: 1, number: '0347' } },
  });
}));
```

> 💡 En marbles cada carácter es un *frame*. `debounceTime(300, m.scheduler)`
> le pasa el `TestScheduler` de rxjs-marbles para que el tiempo virtual
> avance con el diagrama y no con el reloj real.

---

### 2. `switchMap` — el último gana, cancela lo anterior

**Cuándo.** Cuando solo te importa el resultado de la **última** acción y las
respuestas viejas son basura que puede corromper el estado. Validación
mientras se tipea, navegación (cargar el detalle de la rifa que se abrió
*ahora*), y la venta que gana la carrera.

**Ejemplo mínimo** (`sellNumberEpic` de Fase 6):

```javascript
export const sellNumberEpic = (action$) =>
  action$.pipe(
    ofType(SELL_NUMBER),
    switchMap((action) => {   // si llega otra venta del mismo número, la anterior se aborta EN EL ORIGEN
      const { raffleId, number, participant } = action.payload;
      return from(apiClient.post(`/raffles/${raffleId}/numbers/${number}/sell`, { participant })).pipe(
        map((response) => numberSoldOptimistic({ raffleId, number, participantId: response.data.participantId })),
        catchError((error) => of(rollbackSale({ raffleId, number, error: toReadableError(error) })))
      );
    })
  );
```

Lo valioso es que el perdedor de la carrera **nunca llega a despachar su
rollback**: `switchMap` cancela su petición HTTP en vuelo. En Fase 5, sin
epic, ese rollback llegaba tarde y revertía una venta legítima.

**Error común.** Usar `switchMap` cuando las operaciones son **independientes
y no deben cancelarse entre sí**. Si lo usás para expirar reservas, reservar
el `0912` cancelaría la expiración del `0347` en curso, y ese número quedaría
reservado para siempre. Regla: `switchMap` solo si *el anterior ya no importa*.

**Cómo probarlo con marbles.** Se prueba la **cancelación**: el resultado del
primero no debe aparecer.

```javascript
it('switchMap: la venta anterior del mismo número se cancela al re-disparar', marbles((m) => {
  // apiClient.post tarda 30ms en responder (cold que emite tras el retardo).
  const apiPost = () => m.cold('---a|', { a: { data: { participantId: 7 } } });

  // Dos SELL_NUMBER del mismo número separados por 10ms: el 2do llega antes de que responda el 1ro.
  const action$ = m.hot('  -a-b|', {
    a: { type: SELL_NUMBER, payload: { raffleId: 1, number: '0347', participant: 'A' } },
    b: { type: SELL_NUMBER, payload: { raffleId: 1, number: '0347', participant: 'B' } },
  });

  const output$ = action$.pipe(
    ofType(SELL_NUMBER),
    switchMap(() => apiPost().pipe(map((res) => numberSoldOptimistic({ raffleId: 1, number: '0347', participantId: res.data.participantId }))))
  );

  // Solo emite el resultado del segundo. El del primero fue abortado: no aparece.
  m.expect(output$).toBeObservable('-----c|', {
    c: numberSoldOptimistic({ raffleId: 1, number: '0347', participantId: 7 }),
  });
}));
```

> La aserción *es la ausencia*: probar una cancelación con marbles significa
> demostrar que algo **no** aparece en el diagrama esperado.

---

### 3. `mergeMap` — todo en paralelo

**Cuándo.** Cuando cada acción arranca una operación **independiente** que no
debe cancelar ni bloquear a las demás. El caso de rifas: la expiración de la
reserva de cada número corre en su propio timer, en paralelo.

**Ejemplo mínimo** (`reservationExpirationEpic` de Fase 6):

```javascript
export const reservationExpirationEpic = (action$) =>
  action$.pipe(
    ofType(reserveNumber.fulfilled.type),
    // mergeMap y NO switchMap: dos reservas de números distintos deben expirar en paralelo.
    // switchMap cancelaría la expiración anterior cada vez que se reserva otro número.
    mergeMap((action) => {
      const { number } = action.payload;
      return timer(RESERVATION_TTL_MS).pipe(
        map(() => reservationExpired({ number })),
        takeUntil(action$.pipe(  // pero se cancela si ESE número se vende antes
          ofType(sellNumber.fulfilled.type),
          filter((sold) => sold.payload.number === number)
        ))
      );
    })
  );
```

**Error común.** `mergeMap` sin freno en una fuente rápida crea concurrencia
ilimitada: cientos de suscripciones internas vivas. Si la operación no es
naturalmente acotada, poné un límite (`mergeMap(fn, concurrency)`) o cambiá el
operador. En rifas está acotado por la cantidad de reservas activas, pero el
antipatrón existe.

**Cómo probarlo con marbles.** Se prueba que dos entrantes producen dos
internos **solapados en el tiempo**:

```javascript
it('mergeMap: dos reservas expiran en paralelo, sin cancelarse', marbles((m) => {
  const action$ = m.hot('  -a-b------|', {
    a: { type: reserveNumber.fulfilled.type, payload: { number: '0347' } },
    b: { type: reserveNumber.fulfilled.type, payload: { number: '0912' } },
  });
  // TTL virtual de 4 frames. Cada expiración cae 4 frames después de SU reserva → solapan.
  const epic = (a$) => a$.pipe(
    ofType(reserveNumber.fulfilled.type),
    mergeMap((action) => timer(4, m.scheduler).pipe(map(() => reservationExpired({ number: action.payload.number }))))
  );
  m.expect(epic(action$)).toBeObservable('-----x-y--|', {
    x: reservationExpired({ number: '0347' }),
    y: reservationExpired({ number: '0912' }),
  });
}));
```

Si esto fuera `switchMap`, `x` **no** aparecería: la reserva de `0912`
cancelaría la expiración de `0347`. El test protege exactamente esa decisión.

---

### 4. `concatMap` — encolar y respetar el orden

**Cuándo.** Cuando las operaciones deben ejecutarse **una después de otra, en
el orden en que llegaron**, sin solaparse. Escenario de rifas: aplicar en cola
una serie de liquidaciones sobre la misma rifa, donde cada una depende del
saldo que dejó la anterior.

> 📝 `concatMap` no aparece en el código de Fase 6 (que se concentra en
> switch/merge/debounce/takeUntil/retry/catchError). Va acá como patrón de
> consulta, con un ejemplo de dominio nuevo pero coherente. Aparece en el
> terreno real recién con liquidaciones (Fase 8).

**Ejemplo mínimo:**

```javascript
// Cada settlementRequested debe procesarse en orden estricto: la nº2 no arranca
// hasta que la nº1 terminó, porque ambas mutan el saldo de la misma rifa.
export const settlementQueueEpic = (action$) =>
  action$.pipe(
    ofType(SETTLEMENT_REQUESTED),
    concatMap((action) =>   // cola FIFO: espera a que termine la anterior antes de la siguiente
      from(apiClient.post(`/raffles/${action.payload.raffleId}/settlements`, action.payload)).pipe(
        map((response) => settlementApplied({ raffleId: action.payload.raffleId, balance: response.data.balance })),
        catchError((error) => of(settlementFailed({ raffleId: action.payload.raffleId, error: toReadableError(error) })))
      )
    )
  );
```

**Error común.** Usar `concatMap` para algo que **debería** ser paralelo:
cargar cinco rifas independientes con `concatMap` las serializa y multiplica
la latencia por cinco. `concatMap` es correcto solo cuando el orden importa o
las operaciones comparten un recurso mutable. Si no, es `mergeMap`.

**Cómo probarlo con marbles.** Se prueba la **serialización**: aunque las
acciones lleguen casi juntas, los resultados salen en orden y sin solaparse.

```javascript
it('concatMap: procesa liquidaciones en orden, sin solapar', marbles((m) => {
  const action$ = m.hot('  -a-b|', {
    a: { type: SETTLEMENT_REQUESTED, payload: { raffleId: 1 } },
    b: { type: SETTLEMENT_REQUESTED, payload: { raffleId: 2 } },
  });
  // Cada operación dura 3 frames. Con concatMap, la de 'b' NO empieza hasta que 'a' termina.
  const epic = (a$) => a$.pipe(
    ofType(SETTLEMENT_REQUESTED),
    concatMap((action) => m.cold('---r|', { r: settlementApplied({ raffleId: action.payload.raffleId, balance: 0 }) }))
  );
  m.expect(epic(action$)).toBeObservable('----x--y|', {
    x: settlementApplied({ raffleId: 1, balance: 0 }),
    y: settlementApplied({ raffleId: 2, balance: 0 }),
  });
}));
```

`y` cae **después** de que `x` completó, no en paralelo. Con `mergeMap` ambas
saldrían casi juntas y el test fallaría — que es justo lo que queremos vigilar.

---

### 5. `exhaustMap` — ignorar lo nuevo mientras proceso

**Cuándo.** Cuando hay una operación en curso y los nuevos disparos deben
**descartarse hasta que termine**. El caso de manual: el botón "Vender" y el
doble click nervioso. Con `exhaustMap`, el segundo click se ignora mientras el
primer POST está en vuelo.

> 📝 Igual que `concatMap`, `exhaustMap` no está en el código de Fase 6. Se
> incluye como patrón de consulta porque es la respuesta correcta al doble
> submit, un problema que la venta concurrente (Fase 5) roza de cerca.

**Ejemplo mínimo:**

```javascript
// SUBMIT_SALE se dispara al click de "Vender". exhaustMap ignora clicks repetidos
// mientras la venta anterior sigue resolviéndose: no hay doble POST.
export const submitSaleEpic = (action$) =>
  action$.pipe(
    ofType(SUBMIT_SALE),
    exhaustMap((action) =>   // descarta disparos entrantes hasta que el interno complete
      from(apiClient.post(`/raffles/${action.payload.raffleId}/numbers/${action.payload.number}/sell`, action.payload)).pipe(
        map((response) => numberSoldOptimistic({ ...action.payload, participantId: response.data.participantId })),
        catchError((error) => of(rollbackSale({ ...action.payload, error: toReadableError(error) })))
      )
    )
  );
```

**Error común.** Confundir `exhaustMap` con `switchMap`. Los dos "resuelven" el
doble click, pero al revés: `switchMap` **cancela el primero y se queda con el
último**; `exhaustMap` **se queda con el primero e ignora el resto**. Para un
submit de venta querés `exhaustMap` (que se complete el POST que ya salió); si
usaras `switchMap`, el segundo click abortaría una venta que quizá ya impactó
en el server → estado incierto. La distinción no es cosmética: cambia qué
venta queda registrada.

**Cómo probarlo con marbles.** Se prueba que el disparo intermedio **se
ignora**:

```javascript
it('exhaustMap: ignora el segundo click mientras el primero está en vuelo', marbles((m) => {
  const action$ = m.hot('  -a-b----|', {   // 'b' llega mientras 'a' aún procesa
    a: { type: SUBMIT_SALE, payload: { raffleId: 1, number: '0347' } },
    b: { type: SUBMIT_SALE, payload: { raffleId: 1, number: '0347' } },
  });
  const epic = (a$) => a$.pipe(
    ofType(SUBMIT_SALE),
    exhaustMap((action) => m.cold('----r|', { r: numberSoldOptimistic({ ...action.payload, participantId: 1 }) }))
  );
  // Solo el resultado de 'a'. 'b' cayó dentro de la ventana ocupada → descartado.
  m.expect(epic(action$)).toBeObservable('-----r--|', {
    r: numberSoldOptimistic({ raffleId: 1, number: '0347', participantId: 1 }),
  });
}));
```

---

## Patrones de cancelación y resiliencia

### 6. `takeUntil` — apagar el stream ante un trigger

**Cuándo.** Siempre que un stream de larga vida deba **cortarse ante un
evento**: logout, desmontaje del componente, o que ocurra la acción que
vuelve irrelevante la espera. Es el operador de cancelación de todo el curso y
la única defensa real contra los memory leaks de epics (siguiente sección).

**Ejemplo mínimo** — el corte de la expiración cuando el número se vende
(dentro de `reservationExpirationEpic`):

```javascript
timer(RESERVATION_TTL_MS).pipe(
  map(() => reservationExpired({ number })),
  takeUntil(action$.pipe(          // corta la espera si...
    ofType(sellNumber.fulfilled.type),
    filter((sold) => sold.payload.number === number)   // ...se vende ESTE número
  ))
)
```

Y el patrón que la Fase 7 va a reutilizar para el polling:
`takeUntil(action$.pipe(ofType(STOP_POLLING, 'LOGOUT')))`.

**Error común.** Dos, y ambos duelen:

1. **Olvidarlo** en un stream infinito (`interval`, `timer`, polling). No rompe
   nada visible hoy, pero deja la suscripción viva disparando acciones fantasma
   después del unmount o el logout.
2. **Creer que `takeUntil` emite el valor del notifier hacia afuera.** No lo
   hace: usa el notifier solo como señal de corte. Si necesitás despachar una
   acción *al cancelar* (p. ej. `sellCancelled`), no la metas dentro del
   `takeUntil`; ponela en su propio epic (`cancelOnLogoutEpic`). Este es
   exactamente el matiz que la Fase 6 marca con ⚠️.

**Cómo probarlo con marbles.** Se prueba que tras el notifier **deja de
emitir**:

```javascript
it('takeUntil: la expiración se corta cuando el número se vende', marbles((m) => {
  const source$ = m.cold('----e|', { e: reservationExpired({ number: '0347' }) }); // expiraría en frame 4
  const sold$   = m.hot('  --s--', { s: { type: sellNumber.fulfilled.type, payload: { number: '0347' } } });
  // La venta (frame 2) llega antes de la expiración (frame 4): el stream se completa vacío.
  m.expect(source$.pipe(takeUntil(sold$))).toBeObservable('--|');
}));
```

El `|` sin ningún valor antes es la prueba: se completó por cancelación, sin
llegar a emitir `reservationExpired`.

---

### 7. `retryWhen` — reintentar transitorios con backoff

**Cuándo.** Cuando un fallo puede ser pasajero (`timeout`, `http` 5xx) y vale
la pena reintentar con espera creciente. La regla dura de rifas: **nunca
reintentes un `conflict`** — si el número ya se vendió, reintentar diez veces
son diez `409` y quizás una venta doble.

**Ejemplo mínimo** (`retrySellEpic` de Fase 6, núcleo del `retryWhen`):

```javascript
retryWhen((errors$) =>
  errors$.pipe(
    mergeMap((error, index) => {
      const readable = toReadableError(error);
      const isTransient = readable.type === 'timeout' || readable.type === 'http';
      // No transitorio o pasado el tope → rendirse: re-lanzar para que lo agarre catchError.
      if (!isTransient || index >= MAX_RETRIES) {
        return throwError(error);
      }
      // Backoff exponencial: 500ms, 1000ms, 2000ms.
      return timer(500 * 2 ** index);
    })
  )
)
```

> ⚠️ **RxJS 6, no 7.** En RxJS 7 esto se escribe `retry({ count, delay })`.
> En 6.6.7 no existe esa firma; el backoff se arma a mano con `retryWhen` +
> `timer`, como acá.

**Error común.** `retry(3)` a secas. Reintenta **cualquier** error, incluido
el `conflict` que jamás va a mejorar, y sin espera: tres golpes instantáneos
al server. `retryWhen` te deja filtrar *qué* error reintentar y *cuánto*
esperar. Si no distinguís el tipo de error, no reintentes.

**Cómo probarlo con marbles.** Marble testing de backoff con tiempos reales es
incómodo; en la práctica se combina con `TestScheduler`/rxjs-marbles para
tiempos cortos, o —más legible— se testea la **decisión** (¿reintenta o se
rinde?) con un `apiClient` mockeado que falla N veces y luego responde:

```javascript
it('retryWhen: reintenta un timeout y se rinde ante un conflict', marbles((m) => {
  // Primer intento: timeout (transitorio) → reintenta. Segundo: éxito.
  let call = 0;
  const apiPost = () => {
    call += 1;
    return call === 1
      ? m.cold('#', {}, { type: 'timeout' })         // error transitorio
      : m.cold('r|', { r: { data: { participantId: 9 } } });
  };
  const epic = (a$) => a$.pipe(
    ofType(SELL_NUMBER_WITH_RETRY),
    switchMap(() => apiPost().pipe(
      map((res) => numberSoldOptimistic({ raffleId: 1, number: '0347', participantId: res.data.participantId })),
      retryWhen((e$) => e$.pipe(mergeMap((err, i) => (err.type === 'timeout' && i < 3 ? timer(1, m.scheduler) : throwError(err))))),
      catchError((err) => of(rollbackSale({ raffleId: 1, number: '0347', error: err })))
    ))
  );
  const action$ = m.hot('-a|', { a: { type: SELL_NUMBER_WITH_RETRY, payload: {} } });
  m.expect(epic(action$)).toBeObservable('--x|', { x: numberSoldOptimistic({ raffleId: 1, number: '0347', participantId: 9 }) });
}));
```

> 💡 Para el caso `conflict`, el mismo test con `{ type: 'conflict' }` debe
> emitir `rollbackSale` sin reintentar. Ese contraste (transitorio reintenta /
> conflict se rinde) es el ejercicio 7.

---

### 8. `catchError` — que un error no mate el epic

**Cuándo.** Siempre que un Observable interno pueda fallar. Sin `catchError`,
un error **completa el epic entero** y este deja de escuchar acciones para
siempre: el bug más silencioso y más grave de todos.

**Ejemplo mínimo** — el detalle que importa es **dónde** va el `catchError`:

```javascript
// ✅ Correcto: catchError DENTRO del map interno. El error de una venta
//    se convierte en rollbackSale y el epic sigue vivo para la próxima.
action$.pipe(
  ofType(SELL_NUMBER),
  switchMap((action) =>
    from(apiClient.post(/* ... */)).pipe(
      map((res) => numberSoldOptimistic(/* ... */)),
      catchError((error) => of(rollbackSale({ error: toReadableError(error) })))  // ← acá adentro
    )
  )
);

// ❌ Fatal: catchError al final del pipe EXTERNO. El primer error mata el
//    stream principal y el epic no vuelve a reaccionar a ningún SELL_NUMBER.
action$.pipe(
  ofType(SELL_NUMBER),
  switchMap((action) => from(apiClient.post(/* ... */)).pipe(map(/* ... */))),
  catchError((error) => of(rollbackSale({ error })))  // ← MAL: mata el epic entero
);
```

**Error común.** Justo el de arriba: `catchError` en el pipe externo. Es un
error de *posición*, no de olvido, y por eso es traicionero: el código
"maneja errores", el primer fallo hasta se despacha bien… y a partir de ahí el
epic está muerto y nadie lo nota hasta que otra venta simplemente no responde.
Regla: **el `catchError` va dentro del Observable interno**, aislando el error
a esa operación.

**Cómo probarlo con marbles.** Se prueba que **tras un error, el epic sigue
respondiendo** a la siguiente acción:

```javascript
it('catchError interno: un fallo no mata el epic; la próxima venta sigue funcionando', marbles((m) => {
  const responses = [
    m.cold('#', {}, { type: 'http' }),                          // 1ª venta: falla
    m.cold('r|', { r: { data: { participantId: 5 } } }),        // 2ª venta: ok
  ];
  let i = 0;
  const epic = (a$) => a$.pipe(
    ofType(SELL_NUMBER),
    mergeMap((action) => responses[i++].pipe(
      map((res) => numberSoldOptimistic({ ...action.payload, participantId: res.data.participantId })),
      catchError((err) => of(rollbackSale({ ...action.payload, error: err })))   // interno
    ))
  );
  const action$ = m.hot('-a-b|', {
    a: { type: SELL_NUMBER, payload: { number: '0347' } },
    b: { type: SELL_NUMBER, payload: { number: '0912' } },
  });
  m.expect(epic(action$)).toBeObservable('-x-y|', {
    x: rollbackSale({ number: '0347', error: { type: 'http' } }),
    y: numberSoldOptimistic({ number: '0912', participantId: 5 }),
  });
}));
```

Que `y` aparezca **después** de que `x` fue un error es la prueba de que el
epic sobrevivió. Si el `catchError` estuviera afuera, `y` nunca llegaría.

---

## 🩸 Memory leaks en epics: cómo se ven, cómo se previenen

Un epic es un Observable que **nunca se completa**: escucha `action$` para
siempre, que es lo que querés. El problema aparece con los Observables
**internos** de larga vida —`interval`, `timer`, polling— que arrancás dentro
de un `mergeMap`/`switchMap`. Si no les das una condición de corte, quedan
vivos aunque el componente que los originó ya no exista.

**Cómo se ve un leak (la evidencia forense):**

- En **Redux DevTools**, acciones que siguen llegando después de que el usuario
  hizo logout o cambió de pantalla: `pollingTick`, `reservationExpired` de una
  rifa que ya cerraste. Acciones fantasma.
- En **Chrome DevTools → Performance / Memory**, el heap crece escalonado y no
  baja tras navegar: cada visita a la pantalla suma una suscripción que no se
  liberó.
- En **Network**, peticiones periódicas que siguen saliendo hacia el mock
  después de cerrar sesión.

**Cómo se previene** — una sola idea, tres formas de la misma idea:

1. **Todo stream infinito lleva `takeUntil`** con un notifier de fin de vida:
   `takeUntil(action$.pipe(ofType(STOP_POLLING, 'LOGOUT')))`. Sin esto, no hay
   polling seguro.
2. **El teardown de RxJS es tu amigo:** cuando `takeUntil` corta o el operador
   externo cambia de interno (`switchMap`), RxJS ejecuta el teardown y limpia
   `timer`/`interval` solos. No hay `clearInterval` que recordar — esa es la
   razón de existir de los epics frente a los `setTimeout` de Fase 5. 💸 La
   deuda de `reservationTimers.js` se paga exactamente así.
3. **Elegí bien el operador de mapeo.** `switchMap` cancela el interno anterior
   por diseño; usarlo donde corresponde previene leaks *gratis*. `mergeMap` sin
   corte es donde se acumulan.

> 📚 Checklist operativo de cancelación/teardown: ver `FORENSE-CHECKLIST-RXJS`
> (memory leaks, cancelación, unsubscribe). Este apéndice te da los patrones;
> esa checklist te da el procedimiento de caza.

---

## 🔬 Marble testing con rxjs-marbles: sintaxis mínima

Fijado **rxjs-marbles** (D9) sobre Jest 26. Es más conciso que instanciar
`TestScheduler` a mano y trae el scheduler ya cableado al diagrama.

**El diagrama en cinco símbolos:**

| Símbolo | Significa |
|---|---|
| `-` | un frame de tiempo virtual, sin emisión |
| `a`, `b`, `c`… | una emisión con ese valor (lo definís en el objeto de valores) |
| `|` | el stream **completa** |
| `#` | el stream **emite error** |
| `(ab)` | `a` y `b` emiten **en el mismo frame** |

**Los tres helpers que vas a usar:**

- `m.cold('---a|', values)` — Observable frío: se suscribe cada quien por su
  cuenta desde el frame 0. Sirve para respuestas de `apiClient`.
- `m.hot('-a-b|', values)` — Observable caliente: ya está corriendo, útil para
  `action$` que "va pasando".
- `m.expect(stream$).toBeObservable(diagrama, values)` — la aserción.

**Molde base de un test de epic:**

```javascript
import { marbles } from 'rxjs-marbles/jest';

it('describe el comportamiento observable, no la implementación', marbles((m) => {
  const action$ = m.hot('   -a|', { a: { type: SOME_ACTION, payload: {} } });
  const expected = '        -x|';
  const values   = { x: someResultAction() };
  m.expect(myEpic(action$)).toBeObservable(expected, values);
}));
```

**Dos principios que evitan tests frágiles:**

1. **Alineá los diagramas visualmente.** Que `action$` y `expected` empiecen en
   la misma columna hace obvio el timing. Los espacios tras las comillas no
   cuentan como frames (el primer carácter no-espacio es el frame 0).
2. **Testeá timing y cancelación, no solo el valor.** El valor lo cubre un test
   de reducer. Lo que *solo* marbles puede probar es *cuándo* emite y *qué no
   emite* tras un corte. Si tu marble test no depende del tiempo, probablemente
   no necesitabas marbles.

> 📝 En `DECISIONES-CONFIRMADAS.md` (D9) hay un ejemplo con
> `createTestScheduler()`; acá usamos la API idiomática de rxjs-marbles
> (`marbles((m) => …)` con `m.cold`/`m.hot`/`m.expect`), que es la forma que el
> curso adopta a partir de la Fase 10. Mismo concepto, API más limpia.

> 📚 La metodología completa de marble testing de epics (incluido el
> `TestScheduler` crudo, para cuando lo encuentres en código viejo) vive en
> `REGRESION-EPICS-CON-MARBLES` y se enseña de lleno en la Fase 10.

---

## 🧪 Ejercicios (8)

Cortos, de consulta. Los que dicen **(marbles)** se resuelven escribiendo un
marble test. Recordá: identificadores en inglés, comentarios y UI en español.

**🟢 Fácil**

1. Escribí de memoria la línea de imports de RxJS 6 para un epic que use
   `debounceTime`, `switchMap`, `map` y `catchError`. Verificá que ninguno
   venga de `rxjs` en vez de `rxjs/operators`.
2. Dada la tabla maestra, decidí el operador para cada caso y justificá en una
   frase: (a) cargar el detalle de la rifa que el usuario acaba de abrir;
   (b) expirar reservas de tres números distintos; (c) evitar doble submit del
   botón "Vender".

**🟡 Intermedio**

3. Tomá `validateNumberEpic` y explicá qué bug reaparece si cambiás `switchMap`
   por `mergeMap`, manteniendo el `debounceTime(300)`. ¿El debounce solo
   alcanza para evitarlo? ¿Por qué no?
4. **(marbles)** Escribí un marble test que pruebe que `debounceTime` colapsa
   tres tecleos dentro de la ventana en una sola emisión (la última).
5. Reescribí un epic que hoy tiene `catchError` en el pipe externo para moverlo
   al Observable interno. Explicá, en un comentario en español, qué se rompía
   antes.

**🟠 Difícil**

6. **(marbles)** Probá con un diagrama que `switchMap` cancela la operación
   anterior: dos acciones del mismo número, la segunda antes de que responda la
   primera; el resultado de la primera **no** debe aparecer en `expected`.
7. **(marbles)** Escribí dos tests para `retrySellEpic`: uno donde un `timeout`
   se reintenta y luego tiene éxito, y otro donde un `conflict` **no** se
   reintenta y cae directo en `rollbackSale`. El contraste es el objetivo.

**🔴 Muy difícil**

8. **(marbles)** Diagnóstico: te entregan un `pollingEpic` con
   `interval(2000)` dentro de un `mergeMap` **sin `takeUntil`**. Primero,
   describí la evidencia que verías en Redux DevTools, Memory y Network tras un
   logout. Después, corregilo con `takeUntil(action$.pipe(ofType('LOGOUT',
   STOP_POLLING)))` y escribí un marble test que demuestre que, tras el
   notifier de logout, el epic **deja de emitir** `pollingTick`.

**🔥 Opcionales**

- 🔥 Reimplementá `settlementQueueEpic` con `mergeMap` y demostrá con un marble
  test que el orden de los `settlementApplied` deja de estar garantizado.
  Después volvé a `concatMap` y mostrá el test en verde.
- 🔥 Compará el backoff de `retryWhen` (RxJS 6) con la firma
  `retry({ count, delay })` de RxJS 7. Escribí ambos y explicá por qué el
  segundo **no** compila en el stack fijado.

---

## 📚 Referencias

### Documentación oficial

- **redux-observable (1.x)** — README, epics y `combineEpics`, dependencies de
  epic: https://redux-observable.js.org
  > ⚠️ La doc actual cubre 1.x y 2.x; el curso está fijado en **1.2.0**. Ignorá
  > cualquier nota de migración a 2.x.
- **RxJS 6** — operadores, `pipe`, creación de Observables:
  https://rxjs.dev
  > ⚠️ El sitio documenta **RxJS 7+** por defecto. Estamos en **6.6.7**:
  > operadores desde `rxjs/operators`, y `retryWhen` en lugar de
  > `retry({ delay })`. Verificá siempre la firma contra la 6.
- **Referencia de operadores concretos** (buscá cada uno en rxjs.dev, leyendo la
  sección de RxJS 6): `debounceTime`, `switchMap`, `mergeMap`, `concatMap`,
  `exhaustMap`, `takeUntil`, `retryWhen`, `catchError`.
- **rxjs-marbles** — sintaxis de diagramas, integración con Jest, helpers
  `cold`/`hot`/`expect`: https://github.com/cartant/rxjs-marbles
- **Marble testing (concepto)** — guía oficial de testing de RxJS con
  `TestScheduler`, útil para entender qué hace rxjs-marbles por debajo:
  https://rxjs.dev/guide/testing/marble-testing

> 📝 Las URLs y títulos pueden haber cambiado desde la redacción; verificalos.
> No se citan versiones exactas de página ni anclas internas que envejecen
> rápido.

### Orden de lectura sugerido

README de redux-observable → sección de operadores de RxJS 6 (empezá por
`switchMap` vs `mergeMap`) → volvé a la [tabla maestra](#-tabla-maestra-cuándo-usar-qué-operador)
de este apéndice → rxjs-marbles para escribir el primer test → Fase 10 para la
metodología completa de marble testing de epics.

### Dentro del curso

- **Fase 6 — redux-observable a fondo:** el código real de todos los epics que
  citás acá.
- **Fase 7 — cierre y polling:** donde `takeUntil` + `interval` se vuelven
  polling de verdad.
- **Fase 8 — liquidación:** el terreno natural de `concatMap`.
- **`FORENSE-CHECKLIST-RXJS`:** procedimiento de caza de leaks y suscripciones
  sin cancelar.
- **`REGRESION-EPICS-CON-MARBLES`:** metodología de marble testing (Fase 10).
