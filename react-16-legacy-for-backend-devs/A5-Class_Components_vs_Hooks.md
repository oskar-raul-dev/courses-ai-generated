# 🔀 Apéndice A5 — Class Components vs Hooks

> Tutorial React 16 — Rifas y chances · Apéndice de **consulta rápida** · ~3 h
> Lo referencian: Fase 2 y posteriores · React/React DOM **16.14.0** (D1) · JavaScript plano ES2019 (D3)

> 📝 **Cómo se lee esto.** No es una fase: es material de mesa de trabajo. Cuando abras un archivo del proyecto y no sepas si estás mirando una clase o una función con hooks —o cuando tengas que traducir mentalmente un `componentDidMount` a un `useEffect` para arreglar algo—, saltás acá, buscás la sección y volvés a lo tuyo. No hace falta leerlo de corrido.

---

## 🧭 Salto rápido

1. [Por qué esto importa en mantenimiento](#1-por-qué-esto-importa-en-mantenimiento)
2. [Anatomía lado a lado: la misma vista en clase y en hook](#2-anatomía-lado-a-lado)
3. [🗺️ Tabla grande de equivalencias (ciclo de vida ↔ hooks)](#3--tabla-grande-de-equivalencias)
4. [Estado: `this.state` / `setState` ⟷ `useState`](#4-estado-thisstate--setstate--usestate)
5. [Props: `this.props` ⟷ argumentos de la función](#5-props-thisprops--argumentos-de-la-función)
6. [Efectos: los tres momentos del ciclo de vida ⟷ `useEffect`](#6-efectos--useeffect)
7. [Estado complejo: `this.state` grande ⟷ `useReducer`](#7-estado-complejo--usereducer)
8. [Contexto: `contextType` / `Consumer` ⟷ `useContext`](#8-contexto--usecontext)
9. [🔍 Leer código mezclado sin marearte](#9--leer-código-mezclado-sin-marearte)
10. [Convertir una clase a hook, paso a paso (didáctico)](#10-convertir-una-clase-a-hook-paso-a-paso)
11. [⚠️ Trampas comunes](#11--trampas-comunes)
12. [🧪 Ejercicios](#-ejercicios-8)
13. [📚 Referencias](#-referencias)

---

## 1. Por qué esto importa en mantenimiento

El código que vas a mantener es **mixto**. Desde la Fase 2 conviven, por ejemplo, `RaffleListPage` —una clase con `connect()`— y componentes funcionales con hooks que leen del mismo store con `useSelector()`. Esto no es un descuido: es el estado natural de una base que empezó antes de React 16.8 (febrero de 2019, cuando llegaron los hooks) y fue creciendo sin reescribir lo que ya funcionaba. Vas a encontrar clases de 2019 al lado de funciones de 2022, y tenés que leer las dos con la misma soltura.

No venís a migrar. Venís a **entender, reproducir y arreglar**. La mitad de los bugs de ciclo de vida que vas a tocar (una suscripción que no se limpia, un efecto que corre de más, un `setState` sobre un componente desmontado) se diagnostican igual en los dos estilos una vez que tenés clara la equivalencia. Convertir una clase a hooks "porque sí" en un hotfix es la forma más rápida de introducir un bug nuevo mientras arreglás otro. Este apéndice te da el mapa mental; la conversión real de un módulo es una fase extra 🔥 aparte, no algo que se hace de pasada.

---

## 2. Anatomía lado a lado

Misma vista, `RaffleDetail`: carga una rifa por `id` de la URL al montar, muestra un loading mientras tanto y limpia al desmontar. A la izquierda el estilo legacy (clase + `connect()`), a la derecha el moderno (función + hooks). Fijate que **hacen exactamente lo mismo**; cambia el andamiaje, no la lógica.

**Clase (legacy):**

```jsx
// RaffleDetail.jsx — estilo clase, el que vas a encontrar en módulos viejos
import React from 'react';
import { connect } from 'react-redux';
import { fetchRaffleById, clearRaffleDetail } from '../store/raffleSlice';

class RaffleDetail extends React.Component {
  constructor(props) {
    super(props);
    // estado local: solo la UI, no lo que vive en el store
    this.state = { expanded: false };
  }

  componentDidMount() {
    // al montar: pedimos la rifa de la URL
    this.props.fetchRaffleById(this.props.match.params.id);
  }

  componentDidUpdate(prevProps) {
    // si cambia el id de la URL, recargamos (navegar de /raffles/1 a /raffles/2)
    if (prevProps.match.params.id !== this.props.match.params.id) {
      this.props.fetchRaffleById(this.props.match.params.id);
    }
  }

  componentWillUnmount() {
    // al salir: limpiamos el detalle para que la próxima rifa no muestre datos viejos
    this.props.clearRaffleDetail();
  }

  render() {
    const { raffle, loading } = this.props;
    if (loading) return <p>Cargando rifa…</p>;
    if (!raffle) return null;
    return <h1>{raffle.name}</h1>;
  }
}

const mapStateToProps = (state) => ({
  raffle: state.raffles.detail,
  loading: state.raffles.loadingDetail,
});
export default connect(mapStateToProps, { fetchRaffleById, clearRaffleDetail })(RaffleDetail);
```

**Función con hooks (moderno):**

```jsx
// RaffleDetail.jsx — estilo hooks, el de los módulos nuevos
import React, { useEffect } from 'react';
import { useSelector, useDispatch } from 'react-redux';
import { useParams } from 'react-router-dom';
import { fetchRaffleById, clearRaffleDetail } from '../store/raffleSlice';

function RaffleDetail() {
  const { id } = useParams();               // la URL, sin this.props.match
  const dispatch = useDispatch();
  const raffle = useSelector((s) => s.raffles.detail);
  const loading = useSelector((s) => s.raffles.loadingDetail);

  useEffect(() => {
    // corre al montar Y cada vez que cambia id: cubre didMount + didUpdate de un saque
    dispatch(fetchRaffleById(id));
    // el return es el cleanup: hace de componentWillUnmount
    return () => dispatch(clearRaffleDetail());
  }, [id, dispatch]);                        // deps: de qué depende este efecto

  if (loading) return <p>Cargando rifa…</p>;
  if (!raffle) return null;
  return <h1>{raffle.name}</h1>;
}

export default RaffleDetail;
```

Lo que la versión de clase reparte en tres métodos (`componentDidMount`, `componentDidUpdate`, `componentWillUnmount`), la de hooks lo junta en **un solo `useEffect`**. Esa es la idea de fondo: los hooks agrupan por *preocupación* ("cargar y limpiar la rifa"), no por *momento del ciclo de vida*.

> 📝 **Nota de época.** El detalle de Redux (`connect` vs `useSelector`/`useDispatch`) es su propio tema: vive en el **Apéndice A6 — Redux clásico vs Toolkit**. Acá lo mostramos solo para que reconozcas el paquete completo tal como aparece en el código real.

---

## 3. 🗺️ Tabla grande de equivalencias

El corazón de este apéndice. Guardala a mano: es lo que vas a mirar cuando tengas una clase adelante y necesites pensar en hooks (o al revés).

| En la clase (legacy) | Cuándo corría | Equivalente con hooks | Trampa al traducir |
|---|---|---|---|
| `constructor(props)` + `this.state = {…}` | Una vez, antes del primer render | `useState(initial)` (uno por porción de estado) | En hooks no metés todo en un objeto por defecto; usás varios `useState` o `useReducer` |
| `this.setState({ x })` (hace *merge* parcial) | Cuando sea | `setX(nuevo)` — **reemplaza**, no fusiona | Si el estado es un objeto, el merge lo hacés vos: `setState(s => ({ ...s, x }))` |
| `render()` | Cada render | El cuerpo de la función (lo que va antes del `return`) + el `return` | Todo lo que estaba en `render()` es ahora el JSX que retorna la función |
| `componentDidMount()` | Una vez, tras montar | `useEffect(() => {…}, [])` | El `[]` vacío es lo que lo hace "solo al montar". Sin él, corre en **cada** render |
| `componentDidUpdate(prevProps, prevState)` | Tras cada actualización | `useEffect(() => {…}, [deps])` | No hay `prevProps` gratis: comparás contra las deps, o guardás el valor previo con `useRef` |
| `componentWillUnmount()` | Al desmontar | El `return () => {…}` **dentro** del `useEffect` (cleanup) | El cleanup vive dentro del mismo effect, no en un hook separado |
| `componentDidMount` + `componentDidUpdate` con la misma lógica | Montaje y updates | Un solo `useEffect(() => {…}, [deps])` | Es la razón de ser de `useEffect`: unifica los dos momentos que en clase duplicabas |
| `componentWillReceiveProps(nextProps)` 💸 | Antes de recibir props nuevas (legacy/unsafe) | Derivar en el cuerpo del render, o `useEffect([prop])` si es un efecto | No tiene traducción 1:1; casi siempre era estado derivado mal resuelto |
| `shouldComponentUpdate()` | Antes de re-renderizar | `React.memo(Component)` (+ `useMemo`/`useCallback` en las deps) | `memo` compara props superficialmente; un objeto nuevo en cada render lo anula |
| `this.props.x` | Siempre | El argumento `props` (o desestructurado) | No hay `this`; las props son el parámetro de la función |
| `this.context` / `static contextType = Ctx` | Siempre | `useContext(Ctx)` | Un `useContext` por cada contexto que consumas |
| `this.state` con muchas transiciones acopladas | — | `useReducer(reducer, initial)` | **No es Redux**: es estado local con forma de reducer (el store es otra cosa → A6) |

> ⚠️ **`componentWillMount`, `componentWillReceiveProps`, `componentWillUpdate`** están marcados como *unsafe* (`UNSAFE_component…`) desde React 16.3 y siguen presentes en 16.14. Los vas a **leer** en código muy viejo, pero no son un patrón a imitar: cuando toques uno, la pregunta correcta suele ser "¿esto era estado derivado que se puede calcular en render?". Marcá 💸 y seguí.

---

## 4. Estado: `this.state` / `setState` ⟷ `useState`

**Cuándo usarlo.** Estado local de UI que no necesita vivir en el store: un toggle, el texto de un input controlado, si un panel está abierto. Si lo comparten varias vistas o lo maneja un thunk/epic, va al store (Redux), no en `useState`.

**Ejemplo mínimo (lado a lado):**

```jsx
// Clase
class RaffleFilter extends React.Component {
  constructor(props) {
    super(props);
    this.state = { query: '', onlyOpen: false };
  }
  render() {
    return (
      <input
        value={this.state.query}
        // setState hace merge: onlyOpen se conserva solo
        onChange={(e) => this.setState({ query: e.target.value })}
      />
    );
  }
}
```

```jsx
// Hooks
function RaffleFilter() {
  const [query, setQuery] = useState('');
  const [onlyOpen, setOnlyOpen] = useState(false);
  // un useState por cosa; no hay objeto que fusionar
  return <input value={query} onChange={(e) => setQuery(e.target.value)} />;
}
```

**Error común.** Esperar que `useState` haga *merge* como `setState`. No lo hace: **reemplaza**. Si guardás un objeto, el spread es tuyo.

```jsx
const [form, setForm] = useState({ query: '', onlyOpen: false });

// ❌ borra onlyOpen: el estado queda { query: 'abc' }
setForm({ query: 'abc' });

// ✅ conservás el resto
setForm((prev) => ({ ...prev, query: 'abc' }));
```

---

## 5. Props: `this.props` ⟷ argumentos de la función

**Cuándo usarlo.** Siempre que un componente reciba datos de su padre. La diferencia es puramente de acceso: en la clase están colgadas de `this`; en la función son el parámetro.

**Ejemplo mínimo:**

```jsx
// Clase
class RaffleBadge extends React.Component {
  render() {
    const { status } = this.props;               // this.props
    return <span className={`badge badge-${status}`}>{labelFor(status)}</span>;
  }
}
```

```jsx
// Hooks
function RaffleBadge({ status }) {               // desestructurado del argumento
  return <span className={`badge badge-${status}`}>{labelFor(status)}</span>;
}

// status llega en inglés ('open', 'closed'…), la etiqueta que ve el usuario va en español
function labelFor(status) {
  switch (status) {
    case 'open': return 'Abierta';
    case 'closed': return 'Cerrada';
    default: return status;
  }
}
```

**Error común — el difunto `componentWillReceiveProps`.** En clases viejas verás esto para "reaccionar" a props nuevas, normalmente copiándolas a `this.state`:

```jsx
// 💸 patrón legacy: casi siempre era estado derivado mal hecho
componentWillReceiveProps(nextProps) {
  if (nextProps.raffle.id !== this.props.raffle.id) {
    this.setState({ localName: nextProps.raffle.name });
  }
}
```

El problema: duplicás en estado local algo que ya viene en props, y ahora tenés dos fuentes de verdad que se desincronizan. En hooks casi nunca lo traducís literal. Si solo necesitás *mostrar* el valor, **derivalo en el render** (`const localName = raffle.name`). Si de verdad necesitás disparar un efecto cuando la prop cambia, ese es el trabajo de `useEffect([raffle.id])`.

---

## 6. Efectos ⟷ `useEffect`

Acá es donde más tiempo vas a pasar traduciendo, porque los tres métodos de ciclo de vida más usados (`componentDidMount`, `componentDidUpdate`, `componentWillUnmount`) colapsan en un solo hook. Entender el **deps array** y el **cleanup** es lo que te salva de la mayoría de los bugs de suscripciones —justo los que vas a cazar en las fases de polling y epics (7 en adelante).

**Cuándo usarlo.** Cualquier cosa que no sea "calcular el JSX a partir de props y estado": pedir datos, suscribirte a algo, arrancar un `setInterval`, tocar el DOM a mano. Si podés calcularlo directo en el render, **no** va en un effect.

**Los tres casos, mapeados:**

```jsx
// Solo al montar → componentDidMount
useEffect(() => {
  dispatch(fetchRaffles());
}, []);                          // deps vacías: una vez y listo

// Al montar y cuando cambia una dep → didMount + didUpdate
useEffect(() => {
  dispatch(fetchRaffleById(id));
}, [id]);                        // corre de nuevo cada vez que cambia id

// Suscripción con limpieza → didMount + componentWillUnmount
useEffect(() => {
  const timer = setInterval(() => dispatch(pollResult()), 3000);
  return () => clearInterval(timer);   // cleanup: corre al desmontar (y antes de re-ejecutar)
}, [dispatch]);
```

**Error común #1 — olvidar el deps array.** Sin segundo argumento, el effect corre en **cada** render. Si adentro hacés un `dispatch` que cambia el estado, provocás otro render, que dispara el effect otra vez: loop.

```jsx
// ❌ sin deps: fetch en bucle infinito
useEffect(() => { dispatch(fetchRaffles()); });

// ✅ una sola vez
useEffect(() => { dispatch(fetchRaffles()); }, []);
```

**Error común #2 — cleanup ausente = memory leak.** Todo lo que arranques (interval, suscripción a un observable, listener) tenés que apagarlo en el `return`. Si no, el timer sigue vivo después de que el componente desapareció, intentando actualizar algo que ya no existe. En React 16 esto se manifiesta como el warning *"Can't perform a React state update on an unmounted component"*.

```jsx
// ❌ el interval sobrevive al desmontaje: sigue haciendo polling en el vacío
useEffect(() => {
  setInterval(() => dispatch(pollResult()), 3000);
}, [dispatch]);

// ✅ se limpia al salir
useEffect(() => {
  const timer = setInterval(() => dispatch(pollResult()), 3000);
  return () => clearInterval(timer);
}, [dispatch]);
```

> 💡 Regla mnemotécnica: **si el effect abre algo, el return lo cierra.** Interval → `clearInterval`. Subscription → `unsubscribe`. Listener → `removeEventListener`. Esta simetría es la misma que en las fases de RxJS vas a ver como `takeUntil` / teardown.

---

## 7. Estado complejo ⟷ `useReducer`

**Cuándo usarlo.** Cuando el estado local tiene varias piezas que cambian juntas o transiciones con reglas ("de `idle` no puedo pasar a `success` sin pasar por `loading`"). Ahí un puñado de `useState` sueltos se vuelve frágil, y un reducer local lo ordena. Un wizard de venta con pasos, por ejemplo, es candidato natural.

**Ejemplo mínimo:**

```jsx
// máquina chica de estados para un pedido de reserva local (no es el store)
function reservationReducer(state, action) {
  switch (action.type) {
    case 'start':   return { status: 'loading', error: null };
    case 'success': return { status: 'reserved', error: null };
    case 'fail':    return { status: 'idle', error: action.error };
    default:        return state;
  }
}

function ReserveButton({ number }) {
  const [state, localDispatch] = useReducer(reservationReducer, { status: 'idle', error: null });
  // state.status controla el render; las transiciones viven en un solo lugar
  return (
    <button disabled={state.status === 'loading'} onClick={() => localDispatch({ type: 'start' })}>
      Reservar {number}
    </button>
  );
}
```

**Error común.** Confundir este `useReducer` **local** con Redux. No comparten nada: `useReducer` no tiene store global, ni DevTools de time-travel, ni middleware, ni epics. Es estado de un solo componente que resulta tener forma de reducer. Cuándo usar uno u otro —y cómo se ve el reducer del **store** con Redux Toolkit— es tema del **Apéndice A6**.

---

## 8. Contexto ⟷ `useContext`

**Cuándo usarlo.** Para leer un contexto (tema visual, locale, un cliente que se inyecta arriba del árbol). En el proyecto la sesión vive en el store, no en Context —así que esto lo vas a ver menos—, pero aparece en librerías de terceros y en código viejo.

**Ejemplo mínimo (lado a lado):**

```jsx
// Clase: contextType (un solo contexto) o Consumer con render prop
class ThemedPanel extends React.Component {
  static contextType = ThemeContext;
  render() {
    return <div className={this.context.dark ? 'panel-dark' : 'panel'} />;
  }
}
```

```jsx
// Hooks: un useContext por contexto, sin anidar render props
function ThemedPanel() {
  const theme = useContext(ThemeContext);
  return <div className={theme.dark ? 'panel-dark' : 'panel'} />;
}
```

**Error común.** En clases, `static contextType` solo admite **un** contexto; para leer dos había que anidar `<Consumer>` dentro de `<Consumer>` (el famoso "pyramid of doom"). Con hooks llamás `useContext` tantas veces como contextos necesites, sin anidar. Si ves esa pirámide en código viejo, es exactamente lo que `useContext` viene a aplanar.

---

## 9. 🔍 Leer código mezclado sin marearte

Lo primero que hacés al abrir un archivo desconocido: identificar de qué estilo es, en cinco segundos, para saber qué buscar. Estas señales alcanzan.

| Si ves… | Estás en… | Dónde buscar el estado / los efectos |
|---|---|---|
| `class X extends React.Component` | Clase | `this.state`, `this.setState`, métodos `componentXxx` |
| `function X() {` o `const X = () => {` con `return <…>` | Función | Hooks arriba del `return`: `useState`, `useEffect`, `useSelector` |
| `this.props`, `this.state`, `render()` | Clase | — |
| `useState`, `useEffect`, `useParams`, `useSelector` | Función con hooks | Las deps de cada `useEffect` te dicen cuándo corre |
| `connect(mapState, mapDispatch)(X)` al final | Redux clásico enchufado (clase **o** función) | `mapStateToProps` para ver qué lee del store → detalle en A6 |
| `useSelector(...)` / `useDispatch()` | Redux moderno vía hooks | Los selectores inline o importados → A6 |
| `componentWillMount` / `UNSAFE_` / `componentWillReceiveProps` | Clase **muy** legacy 💸 | Sospechá de estado derivado mal hecho |

Dos reglas que evitan el mareo:

- **El estilo del componente y el estilo de Redux son ejes independientes.** Podés tener una clase con `useSelector`… no (los hooks no van en clases), pero sí una clase con `connect()` **y** una función con `connect()`, además de la función con `useSelector`. No asumas "clase ⇒ connect, función ⇒ hooks": mirá el final del archivo. En el proyecto, `RaffleListPage` es clase con `connect()`, y hay funcionales que leen el mismo store con `useSelector()`.
- **No hay que unificar para arreglar un bug.** Un fix vive dentro del estilo del archivo que tocás. Reescribir de clase a hooks es una decisión aparte (fase 🔥), nunca un efecto colateral de un hotfix.

---

## 10. Convertir una clase a hook, paso a paso

Esto es **didáctico**: sirve para entender la equivalencia y, si algún día hay una tarea 🔥 de migración, para hacerla con método. **No** es algo que se hace dentro de un hotfix. La conversión automatizada (herramientas que reescriben por vos) queda fuera: acá se hace a mano, entendiendo cada paso.

Sobre el `RaffleDetail` de la sección 2, el proceso es:

1. **Cambiá la firma.** De `class RaffleDetail extends React.Component` a `function RaffleDetail(props) {`. El cuerpo de `render()` pasa a ser el cuerpo de la función (lo de antes del `return` y el `return` mismo).
2. **`this.state` → `useState`.** Cada campo del `state` inicial se vuelve un `useState`. `this.state.expanded` → `const [expanded, setExpanded] = useState(false)`. Cada `this.setState({ expanded: v })` → `setExpanded(v)`.
3. **`this.props` → argumento.** Borrás los `this.`: `this.props.match.params.id` → `props.match.params.id`, o mejor, con Router 5, `const { id } = useParams()`.
4. **Ciclo de vida → `useEffect`.** Juntá `componentDidMount` + `componentDidUpdate` + `componentWillUnmount` que compartan lógica en un `useEffect`. El cuerpo de mount/update va adentro; el de unmount va en el `return` (cleanup); las deps salen de las condiciones del `componentDidUpdate` (ej. `if (prevProps.id !== id)` → `[id]`).
5. **Reemplazá `connect`.** `mapStateToProps` → uno o varios `useSelector`; `mapDispatchToProps` → `useDispatch` + `dispatch(action())`. (El detalle de esta parte, en A6.)
6. **Verificá el deps array.** Es el paso que más bugs mete. Repasá que cada valor externo que usás dentro del effect esté en las deps, y que las deps reflejen exactamente cuándo debe re-correr. Si algo no debe recrearse en cada render (una función que pasás como dep), ahí entran `useCallback`/`useMemo`.

> ⚠️ **Qué NO tocar en un hotfix.** Si el bug que arreglás está en una clase, arreglalo *en la clase*. Convertir "de paso" cambia el timing de los efectos (el orden y el momento en que corren `componentDidUpdate` vs `useEffect` no son idénticos) y es una fuente clásica de regresiones. Migrás cuando tenés tiempo, pruebas y una tarea dedicada —no cuando estás apagando un incendio.

---

## 11. ⚠️ Trampas comunes

Las cuatro que más caro salen, todas alrededor de `useEffect`:

- **Deps array mentiroso.** Usás una variable dentro del effect pero no la listás en las deps. El effect se queda con el valor *viejo* (una *stale closure*): el bug clásico es un handler que dispara con datos de hace tres renders. Regla: si lo usás adentro y viene de afuera, va en las deps. Si el linter de hooks te lo marca, hacele caso antes de silenciarlo.
- **Cleanup ausente → memory leak.** Ya visto en §6, pero es *la* trampa del curso: interval, suscripción a observable o listener que no se apagan en el `return`. Se manifiesta como polling que sigue después de salir de la pantalla y el warning de "state update on an unmounted component". Es exactamente el tipo de bug que las fases 7 (polling) y 6 (epics) enseñan a cazar.
- **Re-render por objeto/función nueva.** Pasar `{ }`, `[]` o una arrow function inline como prop crea una **referencia nueva en cada render**. Si el hijo está envuelto en `React.memo` (el equivalente a `shouldComponentUpdate`), la comparación superficial falla siempre y el `memo` no sirve de nada. Y si ese objeto nuevo es una dep de un `useEffect`, el effect corre de más. Estabilizá con `useMemo` / `useCallback` cuando la identidad importe.
- **Loop de render por `setState` en el cuerpo.** Llamar a un setter de estado directo en el cuerpo del componente (no dentro de un effect ni de un handler) dispara un render que vuelve a llamar al setter: bucle. El estado que depende de props se **deriva** en el render, no se "setea".

> 💡 Instalá y respetá el plugin `eslint-plugin-react-hooks`. La regla `exhaustive-deps` te avisa de la mayoría de los deps mentirosos antes de que lleguen a UAT. No la apagues por comodidad; cuando de verdad querés omitir una dep, dejá un comentario explicando por qué.

---

## 🧪 Ejercicios (8)

Cortos, de consulta y diagnóstico. La idea no es construir features, sino afilar la lectura del código mixto.

**🟢 Fácil (1–3)**

1. Abrí `RaffleListPage` (clase con `connect()`) y `RaffleDetail` en su versión con hooks. Sin ejecutar nada, listá para cada uno: dónde vive el estado, dónde se leen las props y dónde está el efecto de carga. Usá la tabla de §9 como checklist.
2. Traducí a hooks, en papel, esta clase: `constructor` con `this.state = { count: 0 }`, un `componentDidMount` que hace `console.log('montado')` y un botón que hace `this.setState({ count: this.state.count + 1 })`. Marcá qué `useState` y qué `useEffect` te quedan.
3. Dado `useEffect(() => { dispatch(fetchRaffles()); })` (sin segundo argumento), explicá en una frase por qué entra en loop y escribí la corrección.

**🟡 Intermedio (4–6)**

4. **Diagnóstico.** Te pasan un componente funcional con `useEffect(() => { const t = setInterval(...); }, [])` sin `return`. Reproducí el warning de "state update on an unmounted component" navegando fuera de la vista, explicá la causa y aplicá el fix mínimo.
5. Convertí el `componentWillReceiveProps` 💸 de §5 (el que copia `raffle.name` a `this.state.localName`) a la solución correcta con hooks. Justificá por qué desaparece el estado local en vez de traducirse a un `useState`.
6. Tomá el `RaffleDetail` de clase de §2 y hacé solo el **paso 4** de la conversión (§10): unificá `componentDidMount` + `componentDidUpdate` + `componentWillUnmount` en un único `useEffect` con sus deps y su cleanup. No toques todavía la parte de `connect`.

**🟠 Difícil (7–8)**

7. **Diagnóstico.** Un `React.memo(RaffleBadge)` no evita re-renders: el padre le pasa `style={{ color: 'red' }}` inline. Demostralo con un `console.count` en el render del hijo, explicá por qué el `memo` no corta, y corregilo estabilizando la referencia. Relacioná el problema con `shouldComponentUpdate` de la tabla de §3.
8. **Diagnóstico integrador.** Te dan un `useEffect` que usa una prop `raffleId` adentro pero tiene `[]` como deps. Reproducí la *stale closure* (el efecto sigue pidiendo la rifa vieja al cambiar de `raffleId`), mostrá cómo lo delata `eslint-plugin-react-hooks`, y arreglá las deps. Explicá por qué en la versión de clase (`componentDidUpdate` comparando `prevProps.raffleId`) este bug no aparecía igual.

> 🔥 **Opcional.** Migrá `RaffleListPage` completa de clase con `connect()` a función con `useSelector`/`useDispatch`, siguiendo los seis pasos de §10. Compará ambas versiones lado a lado y anotá cualquier diferencia de timing que notes. (Es la fase extra de migración; no cuenta en las horas base.)

---

## 📚 Referencias

**Documentación oficial**

- React (clases, legacy) — ciclo de vida de `React.Component`: https://legacy.reactjs.org/docs/react-component.html — la referencia canónica de `componentDidMount`, `componentDidUpdate`, `componentWillUnmount` y los `UNSAFE_`. Es la doc de la línea 16.x, la que fija D1.
- React (hooks) — `useState`, `useEffect`, `useReducer`, `useContext`: https://react.dev/reference/react — cubre hooks desde 16.8. ⚠️ Los ejemplos y algunas notas asumen React 18; ignorá `useTransition`, `useDeferredValue`, `useId` y demás APIs de 17/18, que **no** van en el código principal (D1).
- React (hooks, guía conceptual todavía viva) — "Using the Effect Hook": https://legacy.reactjs.org/docs/hooks-effect.html — explica el modelo mount/update/unmount → `useEffect` con la mentalidad de la época 16.x; muy alineado con este apéndice.
- React Router 5 — hooks (`useParams`, `useHistory`, `useLocation`): https://v5.reactrouter.com/web/api/Hooks — para reemplazar `this.props.match` al pasar de clase a función (D5 fija la 5.3.x).

**Video / apoyo**

- Buscá un screencast del tipo "class components to hooks" que sea de React 16.8–16.14; abundan en YouTube. Verificá que **no** use APIs de React 18 y que el `useEffect` incluya cleanup. Los títulos y URLs pueden haber cambiado: confirmá la versión antes de fiarte.

**Orden de lectura sugerido:** ciclo de vida de `React.Component` en legacy.reactjs.org → "Using the Effect Hook" (mismo modelo, otra forma) → la tabla de equivalencias de §3 de este apéndice → volvé al código mixto del proyecto y releé `RaffleDetail` en sus dos versiones con la tabla al lado.
