# 🌉 Apéndice A8 — Puente a React Moderno

> ⚠️ **OPCIONAL · COMPARATIVO · CONTEXTO HISTÓRICO**
> No es material para aplicar en Fase 11 ni en ningún código del curso. Es
> para leer y entender qué hay del otro lado del puente. Todo el código que
> veas acá está marcado como *"si fuera React 18"* o *"alternativa moderna"*:
> **ninguno corre en este proyecto**. El curso termina y se queda en React
> **16.14.0** (D1), y ese es su punto final de referencia. Lo moderno se
> mira, no se toca.

> 📝 **Cómo leer este apéndice.** No es lectura secuencial obligatoria. Es
> consulta: llegás desde §5.5 de la Fase 11 con una pregunta concreta
> ("¿qué es RTK Query?", "¿por qué RxJS 7 rompe mis imports?") y saltás a la
> sección que te la responde. Los fragmentos de código son *ilustrativos y
> no ejecutables en este proyecto* — están para reconocer la forma de lo
> moderno cuando la veas afuera, no para copiarla adentro.

---

## 🧭 Salto rápido

| # | Sección | Te sirve si querés entender… |
|---|---|---|
| 1 | [Para qué sirve este apéndice](#1-para-qué-sirve-este-apéndice-y-para-qué-no) | por qué el curso se queda en 16.14 |
| 2 | [El cambio de mental model](#2-el-cambio-de-mental-model-en-una-frase) | la idea que explica casi todo lo demás |
| 3 | [React 16 → 17](#3-react-16--17-la-release-sin-features) | event delegation, JSX transform |
| 4 | [React 17 → 18](#4-react-17--18-concurrent-de-verdad-esta-vez) | `createRoot`, batching, Suspense, Transitions |
| 5 | [Server Components](#5-server-components-el-giro-de-2023-solo-pincelada) | qué son y por qué quedan lejísimos |
| 6 | [RTK → RTK Query](#6-redux-toolkit--rtk-query) | caching e invalidation sin escribir thunks |
| 7 | [RxJS 6 → 7](#7-rxjs-6--7) | por qué rompen los imports y los marbles |
| 8 | [redux-observable → alternativas](#8-redux-observable--alternativas) | cuándo un epic es demasiado |
| 9 | [La era hooks-only](#9-la-era-hooks-only-leer-la-migración-de-connect) | `connect()` ↔ `useSelector`/`useDispatch` |
| 10 | [Estrategia de migración](#10-estrategia-de-migración-sin-urgencia) | el orden sano, sin urgencia |
| 11 | [Tabla maestra 16 vs 17 vs 18](#11-tabla-maestra-react-16-vs-17-vs-18) | la comparación de un vistazo |
| — | [🧪 Ejercicios de lectura](#-ejercicios-de-lectura-y-reflexión-8) | pensar, no implementar |
| — | [📚 Referencias](#-referencias) | dónde verificar todo esto |

---

## 1. Para qué sirve este apéndice (y para qué NO)

El curso te dejó del lado 16.14.0 a propósito. No porque lo moderno esté
mal, sino porque **aprender a mantener se hace mejor sobre lo que ya existe
que sobre lo que todavía brilla** — esa fue la tesis de la Fase 11 y este
apéndice no la contradice, la extiende.

Entonces, ¿para qué leer sobre React 17, 18 y lo que vino después si no vas
a migrar nada? Por una razón muy concreta de mantenedor: **casi toda la
documentación oficial que vas a encontrar hoy describe versiones más nuevas
que la tuya**. Cuando busques cómo funciona `useEffect` y la doc te hable de
que "corre dos veces en desarrollo", o cuando copies un snippet y te aparezca
`createRoot`, necesitás reconocer que estás leyendo material *posterior* a tu
versión y saber qué parte aplica y qué parte no. Este apéndice es tu traductor
de época: te deja leer doc moderna sin importar accidentalmente una API que
tu `package.json` no soporta.

Lo que **no** es: una guía de migración. No hay pasos para llevar el proyecto
a 18, no hay checklist de upgrade, no hay código que puedas pegar. Si algún
día tu equipo decide migrar de verdad, este apéndice te da el mapa mental;
la ejecución es otro trabajo, con su propio presupuesto y su propia red de
tests (y ya sabés de la Fase 11 cómo se arma esa red).

---

## 2. El cambio de mental model, en una frase

Si tuvieras que quedarte con una sola idea de todo el apéndice, es esta:

> **Legacy: "yo orquesto cuándo y en qué orden ocurre el render y los
> efectos". Moderno: "yo declaro *qué* quiero; React decide *cuándo* y en
> qué orden, y se reserva el derecho de interrumpirse".**

Casi todos los cambios de 17 en adelante son consecuencias de ese giro. En
React 16 el render es síncrono y de un tirón: cuando algo cambia, React
recorre el árbol de arriba a abajo y no suelta el hilo hasta terminar. Tu
modelo mental puede ser "esto pasa, entonces esto otro, en este orden". Es
predecible y es el modelo con el que construiste las once fases.

En React 18 el render puede ser *concurrente*: React puede empezar a
renderizar una actualización, pausarla porque llegó algo más urgente (un
click, un tecleo), y retomarla después —o descartarla—. El árbol que estás
construyendo puede no llegar nunca a pantalla. Eso rompe suposiciones que en
16 eran seguras: que un efecto corre una sola vez, que el orden de las
actualizaciones es el orden en que las escribiste, que si empezó a renderizar
va a terminar.

No necesitás dominar concurrencia para mantener tu sistema 16.14. Sí necesitás
saber que existe, porque explica por qué la doc moderna insiste tanto en
efectos idempotentes, en no leer del DOM a mano, y en `useSyncExternalStore`.
Todo eso es andamiaje para un mundo donde React ya no te promete el orden.

---

## 3. React 16 → 17: la "release sin features"

React 17 es famoso por ser la versión que **no agregó features nuevas para
el desarrollador**. Suena anticlimático, pero fue deliberado: 17 se diseñó
como un *puente*, una versión pensada para que las apps grandes pudieran
migrar gradualmente e incluso correr **dos versiones de React a la vez** en
la misma página (una parte del árbol en 17, otra en 18 más adelante). Para
un sistema legacy grande, esa capacidad de migración parcial es justamente
lo que vuelve viable moverse algún día.

Dos cambios internos importan para leer código moderno:

**Event delegation movida a la raíz.** En React 16, React engancha un único
listener por tipo de evento a nivel `document` y desde ahí despacha a tus
handlers. En 17 ese listener se mueve al nodo raíz donde hiciste `render()`.
Suena a detalle de plomería, pero es lo que permite que dos árboles de React
distintos convivan sin pisarse los eventos, y lo que arregla varios dolores
de integrar React dentro de páginas que no son 100% React. Si alguna vez
dependiste de capturar eventos de React en `document` directamente, ahí hay
un breaking sutil.

**Nuevo JSX Transform.** En 16, cada archivo con JSX necesita `import React
from 'react'` aunque no uses `React` explícitamente, porque el JSX compila a
`React.createElement(...)`. React 17 introdujo un transform nuevo que compila
a una función interna que el compilador importa solo, así que el import deja
de ser obligatorio:

```jsx
// React 16 (tu curso): el import es obligatorio aunque no uses "React"
import React from 'react';
function RaffleBadge() {
  return <span className="badge">Abierta</span>;
}
```

```jsx
// "Si fuera React 17+": con el nuevo JSX transform, sin import de React
function RaffleBadge() {
  return <span className="badge">Abierta</span>;
}
// ⚠️ NO en el código del curso. En 16.14 el import de React sigue haciendo falta.
```

> ⚠️ Este es el error más común al copiar snippets modernos a un proyecto
> 16: pegás un componente sin `import React`, y en 16.14 explota con
> *"React is not defined"*. No es que el snippet esté mal; es de otra época.

Para un mantenedor, el resumen de 16→17 es tranquilizador: **es el escalón
barato**. Casi no hay breaking changes de cara al desarrollador, y habilita
todo lo demás. Si este proyecto algún día se moviera, 17 sería el primer paso
sensato y de bajo riesgo.

---

## 4. React 17 → 18: Concurrent, de verdad esta vez

Acá es donde el mental model de §2 se vuelve tangible. React 18 no es "16 con
más hooks": es el primero que activa el render concurrente, y todo lo nuevo
gira alrededor de eso.

**`createRoot` reemplaza a `render`.** El cambio más visible. Es el que
"enciende" el modo concurrente:

```jsx
// React 16 (tu curso):
import ReactDOM from 'react-dom';
ReactDOM.render(<App />, document.getElementById('root'));
```

```jsx
// "Si fuera React 18": nueva API de raíz
import { createRoot } from 'react-dom/client';
const root = createRoot(document.getElementById('root'));
root.render(<App />);
// ⚠️ NO en el código del curso. En 16.14 solo existe ReactDOM.render.
```

**Batching automático.** En 16, React agrupa varias actualizaciones de estado
en un solo re-render *solo* si ocurren dentro de un event handler de React.
Si hacés dos `setState` dentro de un `.then()` de una promesa o un
`setTimeout`, en 16 son dos renders. En 18, React las agrupa igual en todos
lados. Para tu código de rifas esto sería, en general, una mejora invisible
—menos renders— pero también un cambio de timing que podría descolocar algún
test que contaba renders exactos.

**Suspense para datos y SSR con streaming.** En tu curso, `Suspense` solo
sirve para `React.lazy` (code splitting). En 18 se expande a *data fetching*:
un componente puede "suspenderse" mientras espera datos y React muestra un
fallback sin que vos manejes el `isLoading` a mano. Es un cambio de cómo
pensás el estado de carga, no solo una API nueva.

**Transitions.** La cara amable de la concurrencia. `startTransition` y
`useTransition` te dejan marcar una actualización como "no urgente", para que
React priorice lo que el usuario está tocando ahora mismo por encima de un
re-render pesado:

```jsx
// "Si fuera React 18": marcar el filtrado de una tabla grande de números
// como transición, para que el input no se sienta trabado
import { useTransition } from 'react';

function NumbersFilter() {
  const [isPending, startTransition] = useTransition();
  const onChange = (e) => {
    const value = e.target.value;
    startTransition(() => {
      // filtrar 10.000 números es pesado: que no bloquee el tecleo
      setFilter(value);
    });
  };
  // ...
}
// ⚠️ NO en el código del curso. En 16.14 no existe useTransition.
```

Este ejemplo es, además, la mejor respuesta a *"¿cuándo me convendría de
verdad React 18?"*: cuando tenés una UI con actualizaciones pesadas que
compiten con la interacción del usuario. El tablero de 0000–9999 de la Fase 5
es exactamente el tipo de caso donde las Transitions brillarían. Si tu UI no
tiene ese problema, 18 te da poco a cambio de un costo de migración real.

**Hooks nuevos.** `useId` (IDs estables entre servidor y cliente),
`useSyncExternalStore` (para que librerías como React-Redux se integren
correctamente con el render concurrente — de hecho react-redux 8 lo usa por
dentro) y `useInsertionEffect` (para librerías CSS-in-JS). Ninguno es algo
que escribirías a mano seguido; son plomería para el ecosistema.

**StrictMode que invoca efectos dos veces (en dev).** El que más confunde al
llegar de 16. En desarrollo, React 18 monta, desmonta y vuelve a montar cada
componente bajo `<StrictMode>`, corriendo tus efectos **dos veces a
propósito** para exponer efectos que no limpian bien. Si tenés un `useEffect`
que arranca un polling y no lo cancela en el cleanup, en 18-dev lo vas a ver
duplicado de inmediato. Es, en el fondo, la misma lección forense de la Fase
7 (el polling que no para al desmontar) convertida en herramienta del
framework.

---

## 5. Server Components: el giro de 2023+ (solo pincelada)

Los React Server Components (RSC) son el cambio más profundo y el que **más
lejos queda de tu proyecto**. La idea en una frase: algunos componentes
corren *solo en el servidor*, nunca se envían como JavaScript al navegador, y
mandan al cliente ya renderizados. Eso cambia dónde vive el código: parte de
tu árbol deja de ser una SPA que baja al browser y pasa a ejecutarse del lado
del servidor, con acceso directo a la base de datos o al filesystem.

Por qué esto queda a años-luz de un CRA legacy: RSC necesita un framework que
orqueste el límite servidor/cliente (Next.js App Router es el caso típico),
un bundler que entienda la separación, y un modelo de datos pensado para eso.
Create React App —la base de tu curso— ni siquiera está en esa conversación;
CRA fue efectivamente descontinuado como recomendación oficial, y el mundo RSC
asume un stack completamente distinto.

Para un mantenedor de 16.14, RSC es **contexto cultural, no una opción**: te
sirve para entender por qué la doc moderna habla de "client components" con
la directiva `'use client'` (algo que no tiene ningún sentido en tu proyecto,
donde *todo* es cliente), y para no asustarte cuando leas que "los componentes
por defecto ahora corren en el servidor". En tu mundo, siguen corriendo todos
en el navegador, como siempre. Es la distancia más grande entre donde estás y
donde está el borde del ecosistema, y está perfectamente bien quedarse donde
estás.

---

## 6. Redux Toolkit → RTK Query

Este es probablemente el salto moderno **más relevante** para tu proyecto,
porque toca algo que sí escribiste mucho: la carga de datos con
`createAsyncThunk` + un slice que maneja `loading`/`error`/`data`.

RTK Query (que viene *dentro* de Redux Toolkit, no es otra librería) invierte
el enfoque. En vez de que vos escribas el thunk, el slice, los tres estados y
el selector, declarás *endpoints* y RTK Query genera todo: el fetching, el
cache, los estados de carga, y **hooks listos para usar**.

```javascript
// Tu curso (RTK 1.8): thunk + slice + estados a mano
export const fetchRaffles = createAsyncThunk('raffles/fetch', async () => {
  const res = await apiClient.get('/raffles');
  return res.data;
});
// ...y en el slice, extraReducers para pending/fulfilled/rejected,
// y en el componente, useSelector + useEffect + dispatch.
```

```javascript
// "Alternativa moderna" (RTK Query): declarás el endpoint, no el mecanismo
const raffleApi = createApi({
  reducerPath: 'raffleApi',
  baseQuery: fetchBaseQuery({ baseUrl: '/' }),
  tagTypes: ['Raffle'],
  endpoints: (builder) => ({
    getRaffles: builder.query({
      query: () => 'raffles',
      providesTags: ['Raffle'],
    }),
    sellNumber: builder.mutation({
      query: (body) => ({ url: 'sell', method: 'POST', body }),
      invalidatesTags: ['Raffle'], // al vender, el cache de raffles se marca "viejo"
    }),
  }),
});
// El hook lo genera RTK Query solo:
export const { useGetRafflesQuery, useSellNumberMutation } = raffleApi;
// ⚠️ Alternativa moderna, NO en el código del curso. El proyecto usa
// createAsyncThunk (D4). Esto es solo para reconocer la forma.
```

Lo que RTK Query te *borra*: los tres estados repetidos en cada slice, el
`useEffect` que dispara el fetch, el manejo de "no vuelvas a pedir lo que ya
tengo". Trae **caching** (si dos componentes piden `getRaffles`, hay una sola
request) e **invalidation por tags** (cuando una mutación toca `'Raffle'`,
RTK Query re-fetchea automáticamente lo que dependía de ese tag — justo el
tipo de coordinación que en tu curso resolvés a mano tras vender un número).

Lo que RTK Query te *cuesta*: un acoplamiento fuerte a su forma de pensar el
cache, menos control fino sobre el flujo (que a veces querés, sobre todo con
la lógica de concurrencia de la venta), y una curva para el equipo. Para
lógica asíncrona compleja con cancelación y coordinación —tu epic de polling,
por ejemplo— RTK Query no reemplaza a redux-observable; son herramientas para
problemas distintos. RTK Query brilla en el CRUD de datos (rifas,
participantes); los epics siguen siendo para orquestación fina de streams.

---

## 7. RxJS 6 → 7

Tu curso vive en RxJS **6.6.7** (D2). RxJS 7 no cambia los conceptos —los
Observables, `pipe()`, los operadores siguen siendo lo mismo— pero rompe cosas
de superficie que te van a morder si copiás código moderno.

**Imports y tree-shaking.** RxJS 6 ya había movido los operadores a
`rxjs/operators`. RxJS 7 sigue afinando esto y deprecando formas viejas de
importar, con mejor tree-shaking (bundles más chicos porque el bundler puede
descartar operadores que no usás). Un snippet de RxJS 7 puede tener imports
que en 6.6.7 no resuelven igual.

**`toPromise()` deprecado.** El cambio que más se cruza en la práctica. En
RxJS 6 convertís un Observable a Promise con `.toPromise()`. En 7 eso queda
deprecado en favor de `firstValueFrom` y `lastValueFrom`, que son más
explícitos sobre *qué* valor esperás:

```javascript
// Tu curso (RxJS 6.6.7):
const result = await someObservable$.toPromise();
```

```javascript
// "Alternativa moderna" (RxJS 7):
import { firstValueFrom, lastValueFrom } from 'rxjs';
const result = await firstValueFrom(someObservable$);
// ⚠️ NO en el código del curso. En 6.6.7 no existen firstValueFrom/lastValueFrom.
```

**Cambios en operadores de combinación.** `combineLatest` con la firma de
múltiples argumentos, algunos comportamientos de `merge`, y detalles de
tipado (irrelevantes para vos, que estás en JS plano por D3) se ajustaron. No
son reescrituras grandes, pero un `combineLatest(a$, b$)` copiado de doc 7
puede necesitar `combineLatest([a$, b$])`.

**Impacto en el marble testing.** Este es el que más te tocaría de verdad. En
la Fase 10 probás epics con `rxjs-marbles` (D9) sobre RxJS 6. RxJS 7 cambió
algunos detalles del `TestScheduler` y de cómo se representan ciertos frames.
Migrar el proyecto a RxJS 7 no sería solo cambiar imports en los epics:
tendrías que **re-verificar cada marble test**, porque el harness de testing
es sensible a estos cambios de timing. Es exactamente lo que exploraría el
ejercicio 22 de la Fase 11 (migrar `validateNumberEpic` a RxJS 7 en un branch
aislado) — y la conclusión esperada de ese ejercicio es que la migración de
RxJS toca más superficie de la que parece, empezando por los tests.

---

## 8. redux-observable → alternativas

Tu curso enseña `redux-observable` porque el sistema real lo usa (D2), y con
razón: para orquestación asíncrona compleja —cancelación, debounce,
coordinación de streams, polling que se apaga solo— los epics son excelentes.
Pero parte de madurar como mantenedor es saber **cuándo un epic es demasiado**,
y qué usarías en su lugar. La propia guía de estilo del curso lo dice: a veces
un thunk basta, y sobreusar RxJS es un antipatrón.

| Herramienta | Mental model | Brilla en | Se queda corta / sobra en |
|---|---|---|---|
| **thunk** (`createAsyncThunk`) | "una función async con dispatch" | fetch simple, un request → una respuesta, sin cancelar | cancelación, debounce, streams, coordinación temporal |
| **redux-observable** (tu curso) | "streams de acciones que se transforman" | polling, cancelación (`takeUntil`), debounce, race conditions, timing fino | CRUD trivial: es un martillo para un clavo pequeño |
| **Redux Saga** | "generators: escribo async como si fuera síncrono" | flujos largos con muchos pasos secuenciales, `takeLatest`, orquestación legible | equipos sin experiencia en generators; el mental model es otro mundo |
| **RTK listener middleware** | "escucho acciones y reacciono, ligero" | efectos simples reactivos sin traer todo RxJS | lógica con streams complejos o cancelación fina |

**Redux Saga** merece una nota porque es la alternativa clásica a
redux-observable y representa **otro mental model** para el mismo problema.
Donde el epic piensa en *streams* (`action$.pipe(...)`), la saga piensa en
*generators*: escribís el flujo asíncrono con `yield` como si fuera código
síncrono, y el middleware lo pausa y reanuda por vos.

```javascript
// Tu curso (redux-observable): el flujo es un stream que transformás
const pollingEpic = (action$) =>
  action$.pipe(
    ofType('START_POLLING'),
    switchMap(() =>
      interval(2000).pipe(
        mergeMap(() => apiClient.get('/results')),
        takeUntil(action$.pipe(ofType('STOP_POLLING', 'LOGOUT'))),
      )
    )
  );
```

```javascript
// "Alternativa moderna/distinta" (Redux Saga): el flujo se lee como síncrono
function* pollingSaga() {
  while (true) {
    yield take('START_POLLING');
    // race: o seguimos el polling, o alguien lo detiene
    yield race({
      poll: call(pollLoop),          // loop con delay(2000) adentro
      stop: take(['STOP_POLLING', 'LOGOUT']),
    });
  }
}
// ⚠️ Alternativa comparativa, NO en el código del curso. El proyecto usa
// redux-observable (D2). Sagas son otro mental model para el mismo problema.
```

La comparación honesta: sagas suelen leerse más lineales para flujos
secuenciales largos; los epics son más naturales para todo lo que sea
*stream* de verdad (debounce, `combineLatest`, backpressure). Ninguno es
"mejor"; son dos formas de pensar. Tu curso eligió epics porque el sistema
real los tiene, y cambiar de uno a otro no es una mejora, es un cambio de
paradigma con su propio costo de aprendizaje para todo el equipo.

---

## 9. La era hooks-only: leer la migración de `connect()`

El React moderno es abrumadoramente *hooks-only*: casi nadie escribe class
components nuevos, y `connect()` cedió su lugar a `useSelector`/`useDispatch`.
Tu curso te enseñó a leer **ambos** conviviendo (esa es la realidad del
legacy), y la Fase 11 ya ejecuta una migración concreta de clase a hooks con
el test como oráculo. Acá el foco es distinto y más chico: reconocer el
antes/después de `connect()` → hooks, y sus trampas.

```javascript
// Tu curso, estilo legacy: connect() con mapStateToProps/mapDispatchToProps
class RaffleList extends React.Component {
  componentDidMount() {
    this.props.fetchRaffles();
  }
  render() {
    return this.props.raffles.map((r) => <RaffleRow key={r.id} raffle={r} />);
  }
}
const mapState = (state) => ({ raffles: selectRaffles(state) });
const mapDispatch = { fetchRaffles };
export default connect(mapState, mapDispatch)(RaffleList);
```

```javascript
// "Alternativa moderna" (hooks-only): el mismo componente sin connect()
function RaffleList() {
  const raffles = useSelector(selectRaffles);
  const dispatch = useDispatch();
  useEffect(() => {
    dispatch(fetchRaffles());
  }, [dispatch]);
  return raffles.map((r) => <RaffleRow key={r.id} raffle={r} />);
}
// Funciona en tu stack (react-redux 7.2 ya trae hooks). Pero NO se migra
// automáticamente el código legacy: se convive (regla del curso, §6 de estilo).
```

Lo que **se gana**: menos ceremonia, sin `mapState`/`mapDispatch`, sin el
componente envuelto, y tipos más simples (irrelevante en JS plano, pero visible
en la doc). Lo que hay que **vigilar** —las trampas que la doc moderna no
siempre grita—:

- **Re-renders por igualdad referencial.** `connect()` hacía un shallow compare
  de todo el objeto de props. `useSelector` compara *por selector* con `===`
  por defecto. Si tu selector devuelve un objeto o array nuevo en cada llamada
  (`selectOpenRaffles` que hace `.filter(...)` sin memoizar), el componente
  re-renderiza siempre. La solución moderna es memoizar con `reselect` o pasar
  un comparador — un problema que `connect()` te escondía y `useSelector` te
  expone.
- **Un `useSelector` por porción, no uno gigante.** El patrón sano es varios
  `useSelector` chicos y específicos, no uno que devuelve medio store.
- **`dispatch` es estable**, por eso va en las deps del `useEffect` sin causar
  loops — pero conviene ponerlo igual para que el linter no proteste.

Esto es importante justamente porque `useSelector` es la clase de migración que
*parece* trivial ("saco `connect`, meto el hook") y tiene un filo escondido en
los re-renders. Reconocerlo es lo que separa una migración limpia de una que
introduce un problema de performance silencioso.

---

## 10. Estrategia de migración sin urgencia

Supongamos que algún día el equipo decide moverse. No es este curso, no es la
Fase 11, no es tu problema hoy — pero si lo fuera, el orden importa más que la
velocidad. La regla madre viene de la Fase 11 y no cambia: **no se moderniza
lo que no está testeado**. Todo lo que sigue asume la red de tests de la Fase
10 puesta debajo; sin ella, nada de esto es seguro.

El orden sano, de menor a mayor riesgo:

1. **Tests primero (Fase 10).** No es un paso de migración, es el prerequisito
   de todos. Cada cosa que vayas a migrar necesita un test que fije el
   comportamiento *actual* como oráculo. Sin esto, no empieces.

2. **16 → 17: el escalón barato.** Casi sin breaking changes, habilita el
   nuevo JSX transform y la coexistencia de versiones. Es el primer movimiento
   sensato: bajo riesgo, alto valor de posicionamiento. Si vas a migrar algo,
   empezá acá.

3. **`connect()` → hooks, incremental y por módulo.** Un componente a la vez,
   con su test verde en cada paso (§9). Nunca "todo el store en un PR". Vigilá
   los re-renders por igualdad referencial en cada conversión.

4. **RTK Query, endpoint por endpoint.** No migres todos los slices de golpe.
   Elegí *un* endpoint de solo lectura y bajo riesgo (listar rifas, no vender),
   convertilo, medí, y recién después seguí. La venta concurrente —con su
   lógica fina— es lo *último* que tocarías, si es que la tocás.

5. **17 → 18, solo si hay un problema que resuelva.** No migres a 18 "porque es
   lo nuevo". Migrá si tenés un dolor de responsividad de UI que las
   Transitions arreglan (el tablero de números es el candidato). Si no lo
   tenés, 18 es riesgo (`createRoot`, doble-effect en StrictMode, timing de
   batching) sin premio.

6. **RxJS 6 → 7, al final y con cuidado.** Es el que más superficie de testing
   toca (§7): re-verificás todos los marbles. Bajo beneficio visible, riesgo
   concentrado en los tests de epics. Último de la fila.

Y lo que **no migrarías nunca "porque sí"**: Server Components (§5) implica
cambiar de framework entero, no es una migración, es una reescritura. Redux
Saga (§8) no es una mejora sobre tus epics, es otro paradigma — cambiar por
cambiar solo tira a la basura el conocimiento del equipo.

> 💡 El patrón transferible de toda esta estrategia: **migrá por valor y por
> riesgo, no por novedad; un escalón por vez; con test de oráculo en cada
> paso; y detenete apenas el costo supere el beneficio.** La mayoría de los
> sistemas legacy sanos están "a medio migrar" a propósito, y eso está bien.

---

## 11. Tabla maestra: React 16 vs 17 vs 18

| Aspecto | React 16.14 (el curso) | React 17 (puente) | React 18 (moderno) |
|---|---|---|---|
| **Filosofía de la release** | Fiber estable; `Suspense` solo para `lazy` | "Sin features": habilita migración gradual y dos versiones de React coexistiendo | Concurrencia real: React puede interrumpir, pausar y reordenar renders |
| **Montaje de la app** | `ReactDOM.render(<App/>, root)` | Igual: `ReactDOM.render(...)` | `createRoot(root).render(<App/>)`; `render` clásico queda deprecado |
| **Event delegation** | Listeners a nivel `document` | Movidos a la raíz del árbol (nodo del `render`) — clave para apps embebidas y micro-frontends | Igual que 17 |
| **JSX Transform** | Requiere `import React` en cada archivo con JSX | Nuevo transform: JSX sin importar React (opt-in) | Nuevo transform por defecto |
| **Batching de estado** | Solo dentro de event handlers de React | Igual que 16 | Automático también en promesas, `setTimeout` y callbacks nativos |
| **Suspense** | Solo `React.lazy` (code splitting) | Igual | Suspense para data fetching + streaming SSR |
| **APIs de concurrencia** | No existen | No existen | `startTransition`, `useTransition`, `useDeferredValue` |
| **Hooks nuevos** | Los de 16.8 (`useState`…`useRef`) | Ninguno nuevo | `useId`, `useSyncExternalStore`, `useInsertionEffect` |
| **`useEffect` en StrictMode (dev)** | Corre una vez | Igual | Doble invocación en dev para cazar efectos no idempotentes |
| **Breaking al migrar** | — | Casi ninguno (por diseño); revisar si dependías de eventos en `document` | `createRoot` obligatorio; doble-effect en StrictMode; timing de batching |
| **Qué cambiar en la práctica** | Punto de partida | Subir versión + activar JSX transform; migración casi "gratis" | Cambiar el mount, auditar efectos no idempotentes, decidir dónde usar Transitions |
| **Costo/beneficio para legacy** | — | 🟢 Barato y de bajo riesgo: el escalón sano si algún día se migra | 🟠 Vale solo si hay un dolor de responsividad que la concurrencia resuelva; si no, riesgo sin premio |

> 📝 **Server Components no está en la tabla a propósito.** No es un salto de
> versión de `react-dom`, es otro modelo de ejecución (código en el servidor).
> Va como pincelada en §5, no como columna comparable.

---

## 🧪 Ejercicios de lectura y reflexión (8)

Estos ejercicios **no se implementan**. Son de lectura, comparación y
decisión — el tipo de razonamiento que hace un mantenedor antes de tocar
nada. No hay código que entregar; hay criterio que ejercitar.

**🟢 Lectura básica (1–3)**

1. Abrí la doc oficial de `useEffect` en https://react.dev y encontrá la parte
   que dice que el efecto "corre dos veces en desarrollo". Explicá, en tus
   palabras, por qué eso **no** aplica a tu proyecto 16.14 y qué versión lo
   introduce. ¿Qué lección forense de qué fase del curso se parece a ese
   comportamiento?

2. Tomá un componente cualquiera del curso que empiece con `import React from
   'react'`. Explicá por qué ese import es obligatorio en 16.14 y en qué
   versión dejaría de serlo. ¿Qué error exacto verías si lo borraras hoy?

3. Leé la fila "Batching de estado" de la tabla maestra (§11). Describí un caso
   concreto del código de rifas donde el batching automático de React 18
   cambiaría el número de renders respecto a tu 16.14, y por qué eso podría
   romper un test que cuenta renders.

**🟡 Comparación intermedia (4–6)**

4. Compará el bloque `createAsyncThunk` (§6, tu curso) con el bloque
   `createApi` de RTK Query. Listá tres cosas que RTK Query te *borraría* del
   código de la Fase 4, y una cosa que *perderías* en control. ¿Migrarías el
   listado de rifas? ¿Y la venta concurrente? Justificá la diferencia.

5. Leé la tabla de §8 (thunk / epic / saga / listener). Para tres flujos reales
   del curso —el fetch simple de rifas, el polling del resultado, y la reserva
   temporal con expiración— decidí qué herramienta usarías si empezaras hoy de
   cero, y por qué. ¿En cuáles el epic es la elección correcta y en cuáles es
   sobreingeniería?

6. Compará el `pollingEpic` (redux-observable) con el `pollingSaga` (Redux
   Saga) de §8. Sin migrar nada: ¿cuál te resulta más legible y por qué? ¿Qué
   costo tendría para tu equipo cambiar de un mental model al otro? Nombrá al
   menos un caso donde el stream (epic) es claramente mejor que el generator.

**🟠 Decisión difícil (7–8)**

7. Te dan presupuesto para **un solo** movimiento de modernización sobre el
   sistema de rifas: 16→17, hooks-only, RTK Query en un endpoint, o React 18.
   Elegí uno, defendé la elección por costo/beneficio (incluí el costo
   invisible: testing, curva del equipo, riesgo en producción), y explicá por
   qué los otros tres esperan. Después escribí el contraargumento: por qué
   alguien razonable de tu equipo elegiría distinto. (Este ejercicio dialoga
   con el 26 de la Fase 11 — podés usarlo como ensayo previo.)

8. La estrategia de §10 pone RxJS 6→7 **al final** de la fila. Construí el
   argumento de por qué es el último —qué lo hace caro en relación a su
   beneficio— apoyándote en lo que la Fase 10 dice sobre marble testing. Luego
   el contraejemplo: ¿existe alguna situación (una CVE en RxJS 6, por ejemplo)
   donde tendrías que saltártelo hasta el principio de la fila? ¿Cómo mitigarías
   el riesgo de tests si te vieras forzado?

> 🔥 **Ampliación opcional.** Elegí una sección de la doc oficial moderna
> (React 18 upgrade guide, RTK Query overview, o RxJS 7 breaking changes) y
> escribí un párrafo de "traducción para mantenedores 16.14": qué de esa página
> aplica a tu proyecto, qué es de otra época, y qué señal de alarma te avisa de
> que estás leyendo material posterior a tu versión.

---

## 📚 Referencias

**Documentación oficial (advertencia de versión en cada una)**

- https://legacy.reactjs.org — Doc de React con class components, la que
  corresponde a tu 16.14. Tu fuente por defecto para el código del curso.
- https://react.dev — Doc moderna de React. Cubre ≥ 16.8 pero describe 17/18
  como estado por defecto. Útil para este apéndice; **cuidado** al copiar
  cualquier API al código principal.
- https://react.dev/blog/2020/10/20/react-v17.html — Anuncio oficial de React
  17: la "release sin features", event delegation y el nuevo JSX transform (§3).
- https://react.dev/blog/2022/03/29/react-v18 — Anuncio oficial de React 18:
  concurrencia, `createRoot`, batching automático, Transitions (§4).
- https://react.dev/reference/react/useTransition — Referencia de
  `useTransition` (§4). No existe en 16.14.
- https://redux-toolkit.js.org/rtk-query/overview — RTK Query (§6). Leer como
  comparación; el proyecto usa `createAsyncThunk` (D4), no `createApi`.
- https://rxjs.dev/deprecations/breaking-changes — Cambios de RxJS 6 → 7 (§7):
  imports, `firstValueFrom`/`lastValueFrom`, operadores de combinación.
- https://redux-saga.js.org — Doc de Redux Saga (§8), la alternativa de
  generators a redux-observable. Contexto comparativo, no se adopta.
- https://redux-observable.js.org — Doc de tu librería de epics (RxJS 6). El
  ancla del lado legacy del puente.

**Migración (apuntan a versiones más nuevas que las del curso)**

- https://react.dev/blog/2022/03/08/react-18-upgrade-guide — Guía oficial de
  upgrade a React 18. Contexto para §4 y §10; no se ejecuta en el curso.
- https://legacy.reactjs.org/blog/2020/09/22/introducing-the-new-jsx-transforms.html
  — El nuevo JSX transform de React 17 explicado (§3).

**Apéndices y fases del curso relacionados**

- **Fase 11 — Cierre + puente a React moderno.** Este apéndice es la extensión
  comparativa de su §5.5. La Fase 11 *ejecuta* migraciones puntuales con tests;
  este apéndice solo *describe* el panorama moderno.
- **Apéndice A5 — Class components vs hooks.** El desarrollo largo del mapa
  clase ↔ hooks que §9 solo roza.
- **Apéndice A6 — Redux clásico vs Toolkit.** Respalda la parte `connect()` ↔
  `useSelector`/`useDispatch` de §9.
- **Apéndice A7 — redux-observable épica por épica.** El detalle de los
  operadores RxJS que §7 y §8 mencionan de pasada.

**Orden de lectura sugerido**

Empezá por §2 (el mental model) → tabla maestra §11 para el panorama → saltá a
la sección que te trajo acá (RTK Query, RxJS, o hooks) → cerrá con §10
(estrategia) para ubicar todo en un orden de prioridad. Los anuncios oficiales
de React 17 y 18 se leen *después*, ya con el mapa mental puesto.

> ⚠️ **Sobre las citas.** No tengo acceso a búsqueda web ni a una base de
> datos: estas URLs y los nombres de sección pueden haber cambiado o contener
> imprecisiones. Verificá cada enlace antes de apoyarte en él, y confirmá
> siempre que la versión que estás leyendo coincide con la de tu proyecto
> (React 16.14, RTK 1.8, react-redux 7.2, RxJS 6.6.7, Router 5). Cuando una
> API que no reconocés aparece en la doc (`createRoot`, `useTransition`,
> `createApi`, `firstValueFrom`, `'use client'`), es la señal de que estás
> leyendo material posterior a tu versión — justamente el material de
> comparación de este apéndice. No lo copies al código principal.
