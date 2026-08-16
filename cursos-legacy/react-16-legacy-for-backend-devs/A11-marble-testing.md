# 🔬 Apéndice A11 — Marble testing con rxjs-marbles

> Tutorial React 16 — Rifas y chances · Apéndice de **consulta rápida** · **~2,5 horas**
> Lo usan: Fases 6, 7 y 10, y los incidentes 13-17 · Prioridad: 🔴 Alta
> RxJS **6.6.7** · rxjs-marbles **6.0.1** (D9) · Jest 26 (viene en CRA 4)

Esto no se lee de corrido. Es la página que abres cuando tienes que escribir —o
leer— un test de epic y no te acuerdas si el diagrama va con `hot` o con `cold`,
o cuántos guiones necesita ese `debounceTime`.

Es el apéndice que cierra el círculo del curso. La Fase 6 te enseñó a escribir
epics que se cancelan solos; la Fase 7 los puso bajo presión de red real; este
apéndice es el que te deja **demostrar** que la cancelación ocurre. Sin él, que
un `takeUntil` funcione es una creencia. Con él, es un assert.

> 📝 **De dónde sale este apéndice.** El marble testing vivía repartido entre la
> §5.7 de la Fase 10 y una sección corta del A7, con una cita a un
> `REGRESION-EPICS-CON-MARBLES` que nunca existió. Se unificó acá para que haya
> **un solo lugar** donde buscar la sintaxis.

---

## 🧭 Índice de salto rápido

1. [Por qué los epics no se testean con timers reales](#1-por-qué-los-epics-no-se-testean-con-timers-reales)
2. [El diagrama en cinco símbolos](#2-el-diagrama-en-cinco-símbolos)
3. [`hot` frente a `cold`, y cuándo usar cada uno](#3-hot-frente-a-cold-y-cuándo-usar-cada-uno)
4. [El molde base de un test de epic](#4-el-molde-base-de-un-test-de-epic)
5. [Probar `debounceTime`](#5-probar-debouncetime)
6. [Probar `switchMap` (la cancelación del anterior)](#6-probar-switchmap-la-cancelación-del-anterior)
7. [Probar `takeUntil` (el corte, y el leak que previene)](#7-probar-takeuntil-el-corte-y-el-leak-que-previene)
8. [Probar un polling periódico](#8-probar-un-polling-periódico)
9. [Errores comunes al escribir marbles](#9-errores-comunes-al-escribir-marbles)
10. [🧩 Cuándo usar qué](#-cuándo-usar-qué)
11. [🧪 Ejercicios](#-ejercicios-8)

---

## 1. Por qué los epics no se testean con timers reales

Un epic con `debounceTime(300)` testeado con un `setTimeout` de verdad tiene
tres problemas, y el tercero es el que importa.

**Es lento.** Cada test espera 300 milisegundos reales. Con veinte tests de
epics, la suite se lleva seis segundos solo esperando. Molesto, no fatal.

**Es frágil.** El `setTimeout` del test y el del epic compiten en el mismo event
loop. A veces el assert corre antes de que el epic emita y el test falla sin que
nada esté roto. Eso es un test **flaky**, y un test flaky es peor que ningún
test: entrena al equipo a ignorar el rojo.

**Y —lo determinante— no puede probar lo que más importa.** El assert clave de
un epic no es "emitió esto"; es **"no emitió nada después del corte"**. Con
timers reales, "no emitió nada" solo se puede afirmar esperando… ¿cuánto? ¿Un
segundo? ¿Diez? Nunca sabes si esperaste lo suficiente. Es la misma razón por la
que un memory leak de suscripción es invisible: la ausencia de un evento no se
observa esperando.

La solución es un **reloj virtual**. El `TestScheduler` de RxJS avanza el tiempo
en pasos discretos que tú controlas: `debounceTime(300)` "pasa" al instante y de
forma determinista, y el scheduler sabe con certeza que el stream completó y no
va a emitir más. `rxjs-marbles` (D9) es un envoltorio fino sobre ese scheduler
que te deja escribir el flujo como un diagrama.

> 🧠 **La frase que resume el apéndice.** Los marbles no sirven para verificar
> *qué* emite un epic —eso lo cubre un test de reducer, más barato—. Sirven para
> verificar **cuándo emite y qué deja de emitir**. Si tu marble test no depende
> del tiempo, probablemente no necesitabas marbles.

---

## 2. El diagrama en cinco símbolos

| Símbolo | Significa |
|---|---|
| `-` | un frame de tiempo virtual, sin emisión |
| `a`, `b`, `c`… | una emisión con ese valor (lo defines en el objeto de valores) |
| `\|` | el stream **completa** |
| `#` | el stream **emite error** |
| `(ab)` | `a` y `b` emiten **en el mismo frame** |

Un frame es una unidad de tiempo virtual, no un milisegundo. Lo importante es
la **posición relativa**: `'-a--b|'` dice que `b` llega tres frames después de
`a`, y eso es todo lo que el test necesita saber.

> ⚠️ **El detalle que confunde a todo el mundo la primera vez.** Los espacios
> después de las comillas de apertura **no cuentan** como frames: el frame 0 es
> el primer carácter que no sea espacio. Eso es a propósito, y es lo que te
> permite alinear varios diagramas visualmente sin alterar el timing.

---

## 3. `hot` frente a `cold`, y cuándo usar cada uno

Es la distinción que más errores causa, y la regla práctica es corta.

**`m.hot('-a-b|', values)`** — un Observable que **ya está corriendo**. Los
suscriptores se enganchan a mitad y se pierden lo anterior. Es la naturaleza de
`action$`: el stream de acciones del store existe desde que arrancó la app y va
pasando, emitas o no. **Úsalo siempre para `action$`.**

**`m.cold('---a|', values)`** — un Observable que **arranca cuando alguien se
suscribe**, desde su frame 0. Es la naturaleza de una petición HTTP: no ocurre
nada hasta que el epic se suscribe, y ahí empieza a contar. **Úsalo para
simular las respuestas de `apiClient` y `apiLottery`.**

La confusión típica: usar `cold` para `action$`. El test entonces "funciona"
pero prueba otra cosa —un stream de acciones que nace con la suscripción del
epic, que no es cómo funciona Redux—, y suele pasar cuando debería fallar.

> 💡 **El truco para no dudar:** pregúntate si el evento habría ocurrido igual
> sin que nadie mirara. Un click del usuario, sí → `hot`. Una petición HTTP que
> solo sale porque alguien se suscribió, no → `cold`.

---

## 4. El molde base de un test de epic

Tres piezas: el diagrama de entrada, el diagrama esperado, y el objeto de
valores que da significado a cada letra.

```javascript
import { marbles } from 'rxjs-marbles/jest';

it('describe el comportamiento observable, no la implementación', marbles((m) => {
  const action$ = m.hot('   -a|', { a: { type: SOME_ACTION, payload: {} } });
  const expected = '        -x|';
  const values   = { x: someResultAction() };
  m.expect(myEpic(action$)).toBeObservable(expected, values);
}));
```

**Alinea los diagramas visualmente.** Que `action$` y `expected` empiecen en la
misma columna hace que el timing se lea de un vistazo, y convierte un test
denso en un dibujo. Es la única razón por la que los espacios iniciales no
cuentan como frames: para que puedas hacer exactamente esto.

**Nombra el `it` por el comportamiento, no por el operador.** `'debouncea: solo
valida el último número'` te dice qué se rompió cuando falla;
`'test de debounceTime'`, no.

---

## 5. Probar `debounceTime`

El escenario: el usuario tipea `03` y enseguida `0347`, ambos dentro de la
ventana del debounce. El epic tiene que validar **una sola vez**, con el último
valor.

```javascript
// src/features/sales/epics/validateNumberEpic.test.js
import { marbles } from 'rxjs-marbles/jest';
import { ActionsObservable } from 'redux-observable';
import { validateNumberEpic } from './validateNumberEpic';
import { numberTyped, validateNumber } from '../saleSlice';

it(
  'debouncea: solo valida el ÚLTIMO número si el usuario tipea rápido',
  marbles((m) => {
    // 'a' y 'b' caen dentro de la misma ventana de debounce.
    const action$ = new ActionsObservable(
      m.hot('  -a-b--------|', {
        a: numberTyped('03'),
        b: numberTyped('0347'),
      })
    );
    // Una sola emisión, la de 'b', tras cumplirse el debounce.
    const expected = '     -----------c|';
    const values = { c: validateNumber.pending(undefined, { number: '0347' }) };

    m.expect(validateNumberEpic(action$, null, {})).toBeObservable(expected, values);
  })
);
```

El assert que importa no es *dónde* aparece la `c`: es que **haya una sola
letra** en el diagrama esperado. Si el debounce desaparece del epic, el
diagrama tendría dos emisiones y el test falla.

> ⚠️ **Los guiones dependen del `debounceTime` real del epic.** Si el epic usa
> `debounceTime(300)` y tu diagrama cuenta frames de a uno, ajusta la cantidad
> de guiones al valor configurado. Cuando el número de guiones se vuelve
> incómodo de contar, es señal de que conviene parametrizar el debounce en una
> constante que el test también importe (`VALIDATION_DEBOUNCE_MS`) en vez de
> hardcodearlo en los dos sitios.

---

## 6. Probar `switchMap` (la cancelación del anterior)

El escenario: llega `a`, arranca una validación que va a tardar, y antes de que
termine llega `b`. `switchMap` tiene que **cancelar** la de `a`.

```javascript
it(
  'switchMap: al cambiar de número CANCELA la validación anterior en vuelo',
  marbles((m) => {
    const action$ = new ActionsObservable(
      m.hot('  -a----b-----|', {
        a: numberTyped('0347'),
        b: numberTyped('0912'),
      })
    );
    // Solo la validación de 'b' llega a emitir. La de 'a' NO aparece,
    // y ese "no aparece" ES el assert de la cancelación.
    const expected = '     ------------(d|)';
    const values = { d: validateNumber.pending(undefined, { number: '0912' }) };

    m.expect(validateNumberEpic(action$, null, {})).toBeObservable(expected, values);
  })
);
```

> 🧠 **La lección general de este test.** El assert vive en lo que *falta* del
> diagrama esperado. Es el único estilo de test del curso donde la ausencia de
> algo es la verificación, y por eso los marbles son irreemplazables para
> cancelación: cualquier otra herramienta te obligaría a esperar y confiar.

Para distinguirlo de `mergeMap`: cambia el operador del epic a `mergeMap` y
corre este mismo test. Debe fallar, porque ahora aparecerían **dos** emisiones.
Si no falla, el test no está probando lo que crees — y ese ejercicio de
verificar el test rompiendo el código es el 5 de abajo.

---

## 7. Probar `takeUntil` (el corte, y el leak que previene)

El escenario: el usuario tipea y, antes de que el debounce dispare, hace logout.
El epic tiene que completar sin emitir nada.

```javascript
import { logout } from '../../auth/authSlice';

it(
  'takeUntil: un logout CORTA el epic aunque haya validaciones pendientes',
  marbles((m) => {
    const action$ = new ActionsObservable(
      m.hot('  -a---L------|', {
        a: numberTyped('0347'),
        L: logout(),          // type 'auth/logout', ver Fase 6 §5
      })
    );
    // Nada se valida: el stream completa en el frame del logout.
    const expected = '     -----|';
    m.expect(validateNumberEpic(action$, null, {})).toBeObservable(expected, {});
  })
);
```

Este test es **la red que atrapa el memory leak** de la Fase 6. Si alguien borra
el `takeUntil`, el stream deja de completar en ese frame y el diagrama esperado
—que sí completa— deja de cuadrar. El test falla exactamente donde vive el leak,
que es lo que ninguna herramienta manual logra.

> ⚠️ **Usa el action creator, nunca el string.** `logout()` en vez de
> `{ type: 'LOGOUT' }`. Un string mal escrito en el test no falla: hace que el
> diagrama de logout no matchee nada, el epic no se corte, y el test falle con
> un mensaje de timing que te manda a buscar el bug al lugar equivocado. Es
> exactamente el mismo bug que la Fase 6 documenta en el código de producción,
> y muerde igual de fuerte en los tests.

---

## 8. Probar un polling periódico

El otro sabor de `takeUntil`: cortar un flujo que emite para siempre.

```javascript
// src/features/raffles/epics/pollingEpic.test.js
import { marbles } from 'rxjs-marbles/jest';
import { ActionsObservable } from 'redux-observable';
import { pollingEpic } from './pollingEpic';
import { startPolling, stopPolling } from '../raffleSlice';

it(
  'deja de emitir en cuanto llega STOP_POLLING',
  marbles((m) => {
    const action$ = new ActionsObservable(
      m.hot('  s------S----', {
        s: startPolling({ raffleId: 1 }),
        S: stopPolling(),
      })
    );
    // El assert clave: NO hay emisiones a la derecha de S, y el stream completa.
    // Los frames de las emisiones dependen de POLLING_INTERVAL_MS del epic.
    m.expect(pollingEpic(action$, null, {})).toBeObservable('-------|', {});
  })
);
```

La diferencia con §7 es de naturaleza, no de técnica: allá el `timer` emitía una
vez y el `takeUntil` prevenía esa única emisión; acá el `timer` emitiría
indefinidamente y el `takeUntil` es lo único que hace que el test **termine**.
Sin él, el diagrama esperado no puede escribirse: no hay forma de dibujar
"emite para siempre".

> 💡 **Ese detalle es también el diagnóstico.** Si escribiendo el marble de un
> epic te das cuenta de que no puedes expresar el diagrama esperado porque el
> stream no completa nunca, acabas de encontrar un epic sin cancelación. El test
> te dijo dónde está el leak antes de correrlo.

---

## 9. Errores comunes al escribir marbles

**Usar `cold` para `action$`.** El test pasa cuando debería fallar, porque el
stream de acciones nace con la suscripción en vez de estar ya corriendo. §3.

**Contar mal los frames del debounce.** El diagrama esperado no cuadra por uno o
dos guiones y el mensaje de error habla de timing, no de tu operador. Antes de
tocar el epic, cuenta de nuevo — y considera parametrizar el valor (§5).

**Probar el valor en vez del timing.** Si el assert es "emitió esta acción con
este payload" y el diagrama tiene una sola letra sin guiones interesantes, ese
test es un test de reducer disfrazado. Escríbelo como test de reducer: es más
rápido, más claro y no depende de RxJS.

**Escribir el action type a mano.** §7. Usa siempre el creator.

**Mezclar `rxjs-marbles` 7.x con RxJS 6.** El paquete ata su major a la de RxJS.
`npm install rxjs-marbles` a secas te trae la 7 contra tu RxJS 6.6.7, y los
tests fallan con errores de scheduler que no dicen nada útil. Va pineado a
`6.0.1` (D9, `prompts/decisiones-y-versiones.md`).

**Olvidar `ActionsObservable`.** `redux-observable` 1.x espera que `action$` sea
un `ActionsObservable`, no un Observable pelado, porque de ahí sale `ofType`.
Envolver el `m.hot` es obligatorio en esta versión. (En redux-observable 2.x
esto cambió; si ves un ejemplo sin el wrapper, es de otra versión.)

---

## 🧩 Cuándo usar qué

- **Verificar que un reducer produce el estado correcto** → test de reducer, sin
  marbles. Fase 10 §5.3.
- **Verificar que un selector memoiza** → test de identidad referencial, sin
  marbles. Fase 10 §5.4.
- **Verificar que un epic emite la acción correcta** → si el timing no importa,
  un test normal con `toPromise()` alcanza y se lee mejor.
- **Verificar un `debounceTime` o un `throttleTime`** → marbles (§5).
- **Verificar que `switchMap` cancela** → marbles (§6). No hay alternativa.
- **Verificar que un `takeUntil` corta** → marbles (§7 y §8). No hay
  alternativa, y es el test más valioso del curso.
- **Verificar un backoff con `retryWhen`** → marbles, contando los frames entre
  reintentos. Es el más difícil de escribir de todos.

---

## 🧪 Ejercicios (8)

1. **🟢** Escribe el marble más simple posible: un epic que hace `map` de una
   acción a otra, sin tiempo de por medio. Confirma que pasa y después mueve la
   letra del diagrama esperado un frame a la derecha para verlo fallar. Lee el
   mensaje de error con atención: es el que vas a ver siempre.
2. **🟢** Toma el test de §5 y cambia `m.hot` por `m.cold` en `action$`.
   Documenta qué pasa y explica por qué, con §3 delante.
3. **🟡** Escribe el test de `reservationExpirationEpic` (Fase 6): la reserva
   expira tras `RESERVATION_DURATION_MS`, **salvo** que llegue una venta antes.
   Necesitas dos tests: el camino de expiración y el de cancelación.
4. **🟡** Escribe el test de `retrySellEpic` (Fase 6) que verifica que reintenta
   ante `timeout` y **no** reintenta ante `conflict`. El segundo caso es el que
   más gente olvida y el que evita vender dos veces por reintento.
5. **🟠 Verifica tu propio test.** Toma el test de §6 y cambia el `switchMap` del
   epic por `mergeMap`. El test **debe** fallar. Si pasa, tu test no probaba la
   cancelación: arréglalo hasta que falle, y recién ahí revierte el epic. Un
   test que no falla cuando el código se rompe es decoración.
6. **🟠** Escribe el marble de un `retryWhen` con backoff exponencial del
   `pollingEpic` (Fase 7): verifica que el segundo reintento ocurre más tarde
   que el primero, contando frames. Es el más difícil del apéndice.
7. **🔴 Diagnóstico.** Te entregan un epic y su marble test en verde, pero en
   producción el epic deja suscripciones vivas tras el logout. El test pasa y el
   bug existe: **el test está mal**. Encuentra qué no está verificando, escríbelo
   correctamente y demuestra que ahora falla con el epic actual.
8. **🔴** Toma los cinco epics del curso —`sellNumberEpic`,
   `reservationExpirationEpic`, `validateNumberEpic`, `retrySellEpic`,
   `pollingEpic`— y escribe, para cada uno, **el test de cancelación**. Solo el
   de cancelación. Al terminar tienes la red completa que le falta al sistema
   heredado, y es exactamente el entregable que un equipo de mantenimiento
   agradecería más.

**🔥 Opcionales**

- 🔥 Reescribe uno de estos tests con el `TestScheduler` crudo de RxJS, sin
  `rxjs-marbles`. Compara la verbosidad. Sirve para reconocer el estilo cuando
  lo encuentres en código de 2019, que es anterior a la adopción del wrapper.
- 🔥 Compara la sintaxis de marbles de RxJS 6 con la de RxJS 7 (`run()` y los
  tiempos en milisegundos con `300ms a`). Explica por qué la de 7 sería más
  legible para el ejercicio 6 y por qué aun así no la usamos.

---

## 📚 Referencias

**Documentación oficial**

- rxjs-marbles — https://github.com/cartant/rxjs-marbles — la API de
  `marbles()`, `m.hot`, `m.cold` y `m.expect`. **Ojo con la versión:** el README
  actual cubre la línea 7.x; nosotros usamos la 6.x, que es la que corresponde a
  RxJS 6.
- Marble testing en RxJS 6 —
  https://rxjs.dev/guide/testing/marble-testing — la referencia del
  `TestScheduler` y la gramática del diagrama. La página actual documenta RxJS
  7: la gramática de símbolos es la misma, pero la API `run()` y los tiempos en
  milisegundos son de la 7 y **no** aplican acá.
- redux-observable — https://redux-observable.js.org/docs/recipes/WritingTests.html
  — la receta oficial de tests de epics, incluido `ActionsObservable`.
  Corresponde a la línea 1.x, que es la nuestra (D2).
- Jest 26 — https://archive.jestjs.io/docs/en/26.x/expect — la referencia
  archivada de la versión que trae CRA 4.

**Orden de lectura sugerido:** §1 y §2 de este apéndice (el porqué y la
gramática) → §4 (el molde) → escribe el test de §5 con la doc de rxjs-marbles
abierta → §7, que es el que de verdad justifica todo el aparato.

> ⚠️ La documentación oficial de RxJS y de rxjs-marbles cubre hoy la línea 7.
> Casi todo lo conceptual aplica, pero las APIs no: si un ejemplo usa
> `testScheduler.run(({ cold, expectObservable }) => ...)` o tiempos como
> `'300ms a'`, es RxJS 7 y no compila contra nuestro 6.6.7. Verifica siempre.

---

## 🚀 Y ahora, de vuelta al código

Si viniste desde la Fase 10, vuelve a §5.8 y cierra con el smoke de Cypress. Si
viniste desde la Fase 6 o la 7 persiguiendo un epic que no cancela, el test de
§7 es la herramienta, y los incidentes **14** y **17** del
`cuaderno-incidentes.md` son ese problema con un ticket delante.

> **La señal de que quedó bien:** cuando escribas un epic nuevo y, antes de
> pensar qué acción emite, te preguntes *"¿cómo se corta esto y cómo lo pruebo?"*.
> Ese orden —cancelación primero— es lo que separa un epic que envejece bien de
> uno que deja fantasmas.

---

> 🏷️ **Este apéndice deja código: márcalo.** Cuando termines lo que viniste a
> hacer acá, con `git status` limpio:
>
> ```bash
> git tag -a apendice-a11-marble-testing -m "A11: primer marble test de cancelación en verde, con el TestScheduler
> configurado en el proyecto."
> ```
>
> Los commits llevan su prefijo (`a11: …`) y los de ejercicio su número
> (`a11 ej3: …`). La convención completa —tags de fase, de ejercicio y de
> incidente— está en [`00-convencion-de-git-y-tags.md`](00-convencion-de-git-y-tags.md).
