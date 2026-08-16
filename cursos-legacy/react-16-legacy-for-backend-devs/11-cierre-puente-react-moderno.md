# 🏁 Fase 11 — Cierre + puente a React moderno

> Tutorial React 16 — Rifas y chances · Fase 11 de 11 · **6 horas** · **ÚLTIMA FASE**
> Depende de: Fase 10 — Testing mínimo · Habilita: nada (es el cierre del curso)

---

## 🎯 1. Propósito

Llegaste al final de 96 horas. No para aprender React —eso lo sabías al empezar—, sino para volverte alguien que puede **entrar a un sistema legacy ajeno, entenderlo, tocarlo sin romperlo y dejar registro de lo que hizo**. Esa era la promesa del curso, y esta fase la cierra mirando dos direcciones.

Hacia atrás: un recorrido honesto por el viaje. Qué construiste, qué deuda técnica dejaste **a propósito** y por qué dejarla fue una decisión de ingeniería, no un descuido. Un mantenedor que no distingue deuda deliberada de negligencia es peligroso: paga la primera creyendo que arregla la segunda, y rompe cosas que funcionaban.

Hacia adelante: un puente al React moderno que existe fuera de este curso —hooks puros, React Router 6, RTK Query, RxJS 7—, pero cruzado **con la red de tests de Fase 10 puesta**. La tesis de esta fase, y quizás del curso entero, cabe en una línea: **no se moderniza lo que no está testeado**. El orden correcto no es "reescribir y después probar"; es testear primero (Fase 10) y migrar después con la red debajo (Fase 11), usando los tests que ya existen como oráculo de "¿esto preservó el comportamiento?".

La pieza forense de esta fase no es una técnica nueva de debugging. Es el hábito que te llevas: **el test de regresión que reproduce el bug antes del fix**. La disciplina de que ninguna corrección se da por buena hasta que existe un assert que fallaba con el bug presente y pasa con el fix aplicado. Ese hábito es lo que separa apagar un incendio de prevenir el próximo.

> 📝 **Sobre el tono de esta fase.** Las diez fases anteriores construyeron código de dominio. Esta casi no agrega dominio nuevo: reflexiona, compara y ejemplifica migraciones sobre lo que ya existe. Vas a ver menos "acá está el slice nuevo" y más "acá está por qué lo que ya tienes está bien como está, y qué pasaría si lo modernizaras". Es deliberado: cerrar es también saber cuándo *no* tocar.

---

## ✅ 2. Qué queda listo al terminar

- [ ] Un **mapa de la deuda técnica 💸** acumulada en las once fases, consolidado en `A12-mapa-de-deuda-tecnica.md`: qué se dejó sin pagar, por qué, y qué la haría exigible. La deuda deja de ser una anotación suelta por fase y pasa a ser un inventario versionado que el equipo puede priorizar y mantener.
- [ ] El ejercicio 🔥 que Fase 4 dejó plantado —migrar `RaffleTable` de class component a funcional con hooks— **resuelto y explicado línea a línea**, con el test de Fase 10 como oráculo de que la migración no cambió el comportamiento.
- [ ] Una comparación honesta de **corrección mínima vs refactorización** sobre un caso concreto, con el criterio para elegir una u otra bajo presión de producción.
- [ ] Un ejemplo de **puente RxJS 6 → 7** sobre `validateNumberEpic`, con el marble test de Fase 10 mostrando el *antes/después* del scheduler —como comparación, nunca como migración del código principal.
- [ ] Mención encuadrada de **RTK Query, React Router 6 y React 17/18**: qué resuelven, qué costo de migración tienen, y por qué este curso se quedó donde se quedó (D1: React 16.14.0 como punto final de referencia).
- [ ] La **pieza forense consolidada**: el patrón "test de regresión que reproduce el bug antes del fix" como cierre metodológico del track forense de todo el curso.

---

## 🚫 3. Qué queda fuera por ahora

- **Migración real a React 17 o 18.** No se toca `package.json` ni `react-scripts`. React 17/18 aparecen solo como pinceladas comparativas (Apéndice A8, opcional). El código principal sigue en React 16.14.0 (D1) hasta la última línea del curso.
- **Adoptar RTK Query en el código principal.** D4 la deja **solo mencionada**. Migrar `raffleSlice` de `createAsyncThunk` a `createApi` es un ejercicio de comparación 🔥, no un cambio que este curso ejecute.
- **Migrar RxJS 6.6.7 → 7 en el código principal.** El puente se muestra como comparación editorial (regla del proyecto: las alternativas modernas aparecen como comparación o fase opcional, no en el código principal).
- **React Router 5 → 6.** Se menciona la diferencia de API (`Switch`/`component` vs `Routes`/`element`, `useHistory` vs `useNavigate`) como orientación para cuando la encuentres afuera. No se migra.
- **Pagar la deuda técnica acumulada.** El mapa de deuda **inventaria y prioriza**; no la salda. Pagar deuda sin la presión real del equipo es modernización idealizada, justo lo que el curso evita.
- **Construir el e2e exhaustivo.** Fase 10 lo difirió acá, pero como *encuadre*, no como obligación. Queda 🔥. Esta fase decide dónde vive la discusión, no la resuelve entera.
- **Depurar el build de producción y comparar ambientes** → `A13-depurar-el-build-de-produccion.md`, que es material de consulta del track forense y no de esta fase.

---

## 🧠 4. Conceptos mínimos

Esta fase asume que ya internalizaste casi todo. Lo que sigue no son conceptos nuevos de React o Redux; son tres ideas sobre **cómo se mantiene** un sistema, que el curso vino mostrando en la práctica y acá se nombran explícitamente.

### La deuda técnica deliberada no es lo mismo que el descuido

A lo largo del curso marcaste deuda con 💸: el `window.confirm` en vez de un modal, el dinero en enteros nativos sin librería, `raffleSlice` sin normalizar, el reloj del cliente sin `serverNow` (el inventario completo está en `A12-mapa-de-deuda-tecnica.md`). Ninguna de esas cosas es un bug. Son decisiones donde alguien —tú, o el autor original del sistema real— eligió conscientemente **no** hacer lo "correcto" todavía, porque el costo de hacerlo superaba el beneficio en ese momento.

La distinción es operativa, no filosófica. Frente a una línea rara en producción, el mantenedor tiene que responder una pregunta antes de tocar nada: *¿esto está así a propósito o por error?* Si es deuda deliberada, tiene un motivo documentado y probablemente un test que fija el comportamiento actual como esperado —como el `formatCents` que **lanza** con float, que Fase 10 testea como correcto—. "Arreglarlo" rompería algo que dependía de ese comportamiento. Si es descuido, no hay motivo ni test, y ahí sí se corrige. Confundir las dos es la forma más común de que un hotfix bienintencionado genere el próximo incidente.

Por eso el mapa de deuda de §5.1 no lista problemas: lista **decisiones**, cada una con su porqué y su condición de exigibilidad. Eso es lo que un equipo real necesita para priorizar.

### Corrección mínima vs refactorización: son dos trabajos distintos

Todo el curso insistió en separarlas, y acá se formaliza. Ante un bug hay dos respuestas legítimas y **no intercambiables**:

La **corrección mínima** (hotfix) cambia lo menos posible para que el síntoma desaparezca. Una o dos líneas. No mejora el diseño, no paga deuda, a veces hasta *agrega* deuda a propósito. Su virtud es el riesgo bajo: cuanto menos tocas, menos puedes romper. Es lo que va a producción a las tres de la tarde con el incidente abierto.

La **refactorización** cambia la estructura para que la clase de bug no vuelva a ser posible. Toca más código, necesita más pruebas, tiene más riesgo. Su virtud es que ataca la causa, no el síntoma. Es lo que va al backlog, con tiempo y con la red de tests puesta.

El error no es elegir una; es **no distinguirlas**. Refactorizar bajo la presión de un incidente es cómo se rompe producción dos veces. Aplicar solo el hotfix y no anotar el refactor pendiente es cómo la deuda se vuelve invisible hasta que explota. La respuesta profesional casi siempre es *las dos, en orden*: hotfix ahora con su test de regresión, refactor después con su 💸 anotada. §5.3 lo muestra sobre un caso.

### Modernizar es una migración con oráculo, no una reescritura con fe

Cuando afuera del curso te toque llevar un módulo de clase a hooks, de RxJS 6 a 7, de `connect()` a `useSelector`, la pregunta que decide si el cambio es seguro no es "¿quedó más lindo?" sino "¿se comporta igual que antes?". Esa pregunta solo tiene respuesta confiable si existe algo que la responda por ti: un test que verifica **comportamiento, no implementación**.

Ahí es donde Fase 10 se revela como la precondición de Fase 11. Sus tests preguntan a la pantalla (`getByText`, `getByRole`, `getByTestId`), invocan el reducer como función pura, verifican la *forma* del stream con marbles. Ninguno sabe —ni le importa— si adentro hay una clase o un hook, un `connect()` o un `useSelector`, RxJS 6 o 7. Por eso sobreviven a la migración y pueden actuar como **oráculo**: corres el test contra la versión vieja (pasa), migras, corres el mismo test contra la versión nueva. Si sigue pasando, el comportamiento se preservó. Si falla, la migración cambió algo —y mejor enterarte por un assert rojo que por un ticket de producción.

El corolario es la regla rectora de esta fase: **no se moderniza lo que no está testeado**. No porque esté prohibido, sino porque sin oráculo estás reescribiendo con fe, y la fe no es una estrategia de mantenimiento.

---

## 💻 5. Implementación y código comentado

Esta fase produce menos código nuevo que ninguna otra, y es correcto que así sea. Lo que produce es: un inventario, dos migraciones de ejemplo (una que sí conviene, una que se muestra solo para comparar) y un caso trabajado de hotfix-vs-refactor. Todo apoyado en artefactos que ya existen —no inventamos dominio nuevo en la última fase.

### 5.1 El mapa de la deuda técnica 💸 → **A12**

Durante once fases fuiste marcando deuda con 💸. Dispersa, cada marca parece una
anotación menor. Junta, es el **backlog técnico real** del sistema: lo que un
equipo de mantenimiento priorizaría en su primer sprint de mejoras.

El inventario completo —once entradas, cada una con qué se hizo en su lugar, por
qué se dejó y **qué la vuelve exigible**— vive en
**`A12-mapa-de-deuda-tecnica.md`**. Ábrelo ahora, léelo entero (son quince
minutos) y vuelve.

Que sea un archivo aparte y no una sección de esta fase no es un detalle de
organización: **es esta misma fase pagando su propia meta-deuda.** La versión
anterior del curso tenía el mapa acá dentro y una 💸 al lado admitiendo que
debería vivir en un archivo versionado. Ahora vive ahí. Es el ejemplo más
pequeño y más literal de todo el curso de cómo se paga una deuda: se identifica,
se declara, y cuando el disparador ocurre —en este caso, que el inventario
creció lo suficiente para no caber en una sección— se ejecuta.

Lo que sí tiene que quedarte de acá, porque es el criterio y no el inventario:

> 🧭 **La columna que importa no es "qué se dejó" sino "qué la vuelve
> exigible".** Mientras el disparador no ocurra, pagar la deuda es trabajo sin
> retorno — peor, es *riesgo* sin retorno, porque estás tocando código que
> funciona. El día que el disparador ocurre, la deuda deja de ser deuda y pasa a
> ser un bug con fecha. El trabajo del equipo no es pagar todo: es **vigilar los
> disparadores**.

Y la distinción que hace utilizable todo el archivo, que es la misma de §4:
**deuda deliberada tiene motivo documentado y a veces un test que fija el
comportamiento actual como esperado; el descuido no tiene ni motivo ni test.**
Frente a una línea rara, esa es la primera pregunta, antes de tocar nada.

### 5.2 Refactor 🔥: `RaffleTable` de clase a hooks, con la red puesta

Fase 4 dejó este ejercicio explícitamente plantado (§7, opcional 🔥): "reescribe `RaffleTable` de class component a funcional con hooks". Lo resolvemos acá porque es el ejemplo canónico de **migración segura**: hay un test de Fase 10 que verifica el comportamiento de la tabla sin saber si adentro hay una clase o una función. Ese test es el oráculo.

El procedimiento tiene un orden que no es negociable:

1. Correr el test existente de `RaffleTable` contra la versión de clase. **Verde.** Esto establece la línea base: "así se comporta hoy".
2. Escribir la versión funcional.
3. Correr **el mismo test, sin tocarlo**, contra la versión funcional. Si sigue verde, el comportamiento se preservó. Si se pone rojo, la migración cambió algo observable.

El paso 3 es el que le da sentido a todo. Si para que pase el test tuvieras que *modificar* el test, no estarías migrando: estarías cambiando el contrato. Ese es el anti-patrón que anula la red (nota de continuidad §1.1).

**Versión original (clase con `connect()`, de Fase 4):**

```javascript
// src/features/raffles/RaffleTable.jsx (versión de clase, Fase 4)
import React from 'react';
import { connect } from 'react-redux';
import {
  fetchRaffles,
  deleteRaffle,
  selectRaffleToEdit,
  selectRaffles,
  selectLoadingList,
  selectRaffleError,
} from './raffleSlice';

class RaffleTable extends React.Component {
  componentDidMount() {
    // Cargamos al montar: en clase, el equivalente al useEffect([]) de hooks.
    this.props.fetchRaffles();
  }

  handleDelete = (id) => {
    // 💸 window.confirm nativo como placeholder (deuda de Fase 4, sigue abierta).
    if (window.confirm('¿Eliminar esta rifa? No se puede deshacer.')) {
      this.props.deleteRaffle(id);
    }
  };

  render() {
    const { raffles, loadingList, error } = this.props;
    // ... (los cuatro estados visuales: cargando / error / vacío / lista)
  }
}

const mapStateToProps = (state) => ({
  raffles: selectRaffles(state),
  loadingList: selectLoadingList(state),
  error: selectRaffleError(state),
});

const mapDispatchToProps = { fetchRaffles, deleteRaffle, selectRaffleToEdit };

export default connect(mapStateToProps, mapDispatchToProps)(RaffleTable);
```

**Versión migrada (funcional con hooks):**

```javascript
// src/features/raffles/RaffleTable.jsx (versión funcional, Fase 11)
import React, { useEffect } from 'react';
import { useSelector, useDispatch } from 'react-redux';
import {
  fetchRaffles,
  deleteRaffle,
  selectRaffleToEdit,
  selectRaffles,
  selectLoadingList,
  selectRaffleError,
} from './raffleSlice';

// statusLabel no cambia: es una función pura, ajena a clase/hooks. Se mantiene igual.

function RaffleTable() {
  const dispatch = useDispatch();
  // useSelector reemplaza mapStateToProps: una suscripción por porción de estado.
  const raffles = useSelector(selectRaffles);
  const loadingList = useSelector(selectLoadingList);
  const error = useSelector(selectRaffleError);

  // useEffect con array vacío = componentDidMount. Corre una vez, al montar.
  useEffect(() => {
    dispatch(fetchRaffles());
  }, [dispatch]); // dispatch es estable; el efecto no se re-dispara.

  const handleDelete = (id) => {
    // 💸 La MISMA deuda de la versión de clase. Migrar a hooks NO paga deuda
    // de UI: window.confirm sigue acá. Modernizar ≠ arreglar todo de paso.
    if (window.confirm('¿Eliminar esta rifa? No se puede deshacer.')) {
      dispatch(deleteRaffle(id));
    }
  };

  // El JSX del render es idéntico: los cuatro estados visuales no cambian.
  // La pantalla que ve el usuario —y que el test consulta— es la misma.
  // ...
}

export default RaffleTable; // sin connect(): el componente ya no está envuelto.
```

**El mapa de equivalencias**, que es lo que de verdad te llevas (coincide con el Apéndice A5, "class vs hooks"):

| Clase + `connect()` | Función + hooks | Nota |
|---|---|---|
| `mapStateToProps` | un `useSelector` por porción | Cada `useSelector` es una suscripción independiente |
| `mapDispatchToProps` | `const dispatch = useDispatch()` + `dispatch(action())` | El envoltorio automático de `connect()` ahora es explícito |
| `componentDidMount` | `useEffect(() => {...}, [])` | El array vacío es lo que lo vuelve "solo al montar" |
| `componentWillUnmount` | `return` del `useEffect` | (No aplica acá; `RaffleTable` no limpia nada) |
| `this.props.x` | la variable `x` directa | Ya no hay `this` |
| `connect(...)(Componente)` | el componente se exporta pelado | La conexión al store la hacen los hooks adentro |

> **La diferencia entre corrección mínima y refactorización, aplicada acá.** Esta migración **no es un fix**: `RaffleTable` en clase no tiene ningún bug. Es una refactorización pura, opcional (🔥), motivada por consistencia de estilo, no por un incidente. Por eso puede esperar al backlog y hacerse con calma. Si en cambio la tabla *tuviera* un bug en producción, la respuesta correcta **no** sería "aprovecho y la migro a hooks": sería el hotfix mínimo sobre la clase, y la migración quedaría como 💸 aparte. Mezclar un fix urgente con una refactorización opcional es multiplicar el riesgo del fix por el de la migración, justo cuando menos lo quieres.

> ⚠️ **Ajuste menor pendiente (nota de continuidad §2/§4).** El test de `RaffleTable` de Fase 10 asume `data-testid="raffles-loading"` para el estado de carga. La versión de clase de Fase 4 renderiza ese estado como `<div className="alert alert-info">Cargando rifas…</div>` **sin ese testid**. Es decir: el testid es un requisito **nuevo** que Fase 10 introdujo y que hay que agregar al componente —tanto en la versión de clase como en la funcional— para que el oráculo funcione. Es un ajuste menor de una línea (`data-testid="raffles-loading"` en el `div` de carga), no una reapertura de diseño. Al migrar, ese testid se mantiene idéntico: renombrarlo rompería el test (los `data-testid` son contrato de testing desde Fase 10).

### 5.3 Caso trabajado: hotfix mínimo vs refactor, sobre el mismo bug

Tomemos un bug real del curso para ver las dos respuestas lado a lado. El ejercicio 🔴 25 de Fase 4 describe el síntoma: "a veces, al crear una rifa con caos alto, aparece duplicada en la tabla". La causa raíz es un doble submit rápido: el usuario clickea "Crear" dos veces antes de que `loadingMutation` bloquee el botón, y se disparan dos `createRaffle` que el `push` del reducer inserta ambos.

**Primero, el test de regresión que reproduce el bug antes del fix** (la pieza forense de esta fase). Se escribe *antes* de tocar el código, y debe fallar con el bug presente:

```javascript
// src/features/raffles/raffleSlice.test.js (extracto)
// Este test se escribe ANTES del fix. Con el bug presente, falla.
it('no duplica la rifa si createRaffle.fulfilled llega dos veces con el mismo id', () => {
  const raffle = { id: 'r1', name: 'Navideña', status: 'draft' };
  let state = raffleReducer(undefined, { type: '@@INIT' });
  // Simulamos el doble submit: dos fulfilled con la MISMA rifa.
  state = raffleReducer(state, createRaffle.fulfilled(raffle));
  state = raffleReducer(state, createRaffle.fulfilled(raffle));
  // Con el push ingenuo, items.length === 2. El assert exige 1.
  expect(state.items).toHaveLength(1);
});
```

**El hotfix mínimo** (va a producción con el incidente abierto): que el reducer no inserte un id que ya existe. Una guarda de una línea.

```javascript
// raffleSlice.js — dentro de createRaffle.fulfilled
.addCase(createRaffle.fulfilled, (state, action) => {
  state.loadingMutation = false;
  // 💸 Hotfix: guarda de idempotencia contra el doble-fulfilled.
  // No ataca la causa (el doble submit); solo evita el síntoma (duplicado).
  const exists = state.items.some((r) => r.id === action.payload.id);
  if (!exists) state.items.push(action.payload);
})
```

Riesgo bajo, una línea, el test pasa. Pero **el doble submit sigue ocurriendo**: se disparan dos peticiones POST, el backend crea dos veces (o falla la segunda), y solo el store se salva del duplicado visual. El hotfix tapa el síntoma en la capa donde el incidente dolía, no en la capa donde nace.

**El refactor correcto** (va al backlog, con la 💸 anotada): impedir el doble submit en el origen. Deshabilitar el botón sincrónicamente al primer click, no esperar a que `loadingMutation` viaje por el store. O —más robusto— derivar la deshabilitación de un estado local inmediato además del flag de Redux. Esto ataca la causa: nunca se dispara la segunda petición.

```javascript
// RaffleForm.jsx — refactor, no hotfix
const [submitting, setSubmitting] = useState(false);

const handleSubmit = async () => {
  if (submitting) return;         // corta el segundo click SINCRÓNICAMENTE
  setSubmitting(true);
  try {
    await dispatch(createRaffle(draft)).unwrap();
  } finally {
    setSubmitting(false);
  }
};
// El botón usa disabled={submitting || loadingMutation}: local para lo inmediato,
// Redux para lo global. El segundo click nunca llega a despachar.
```

| | Hotfix mínimo | Refactor correcto |
|---|---|---|
| **Qué ataca** | El síntoma (duplicado en el store) | La causa (el doble submit) |
| **Superficie de cambio** | 1 línea en el reducer | Estado local + handler en el form |
| **Riesgo** | Bajo | Medio (toca el flujo de submit) |
| **Cuándo** | Ahora, con el incidente abierto | Backlog, con la red de tests puesta |
| **Deja deuda** | Sí: el POST doble sigue ocurriendo (💸) | No: la elimina en el origen |

La respuesta profesional es **las dos, en orden**: el hotfix ahora con su test de regresión, el refactor después. Y —esto es lo que se olvida— **anotar la 💸** del hotfix, para que la duplicidad de POST no quede como una bomba silenciosa. Un hotfix sin su deuda anotada es cómo un síntoma tapado se convierte en el próximo incidente.

### 5.4 Puente RxJS 6 → 7, como comparación: `validateNumberEpic`

Este es el ejemplo que la nota de continuidad §1.3 anticipa: si algún día migras RxJS 6.6.7 → 7, los marble tests de Fase 10 son el oráculo que confirma que **el timing no cambió**. Lo mostramos como comparación editorial —**no** se migra el código principal (regla del proyecto: RxJS 7 es material de comparación o fase opcional).

El epic de validación de Fase 6 casi no cambia entre versiones, y eso es la buena noticia:

```javascript
// validateNumberEpic — el cuerpo del epic es idéntico en RxJS 6 y 7.
// Los operadores debounceTime, switchMap, map, catchError existen igual en ambas.
export const validateNumberEpic = (action$) =>
  action$.pipe(
    ofType(numberValidationRequested.type),
    debounceTime(300),
    switchMap((action) => {
      const { raffleId, number } = action.payload;
      return from(apiClient.get(`/raffles/${raffleId}/numbers/${number}`)).pipe(
        map((response) => numberValidationSucceeded({ number, status: response.data.status })),
        catchError((error) => of(numberValidationFailed({ number, error: toReadableError(error) })))
      );
    })
  );
```

Lo que **sí** cambia entre 6 y 7 no es el epic: son los imports periféricos y —para el test— la sintaxis del `TestScheduler`. Un mapa de las diferencias que importan para mantenimiento:

| Aspecto | RxJS 6.6.7 (vigente en el curso) | RxJS 7 (comparación) |
|---|---|---|
| Import de operadores | `from 'rxjs/operators'` | También `from 'rxjs'` directamente (los reexporta) |
| `toPromise()` | Disponible (deprecado) | Eliminado; se usa `firstValueFrom`/`lastValueFrom` |
| Tipos de `TestScheduler` | `rxjs-marbles@6` | `rxjs-marbles@7`, sintaxis de scheduler levemente distinta |
| Cuerpo de este epic | — | **Sin cambios** |

El marble test de Fase 10 que fija el debounce + switchMap sirve como *antes/después*: se corre contra el epic bajo RxJS 6 (pasa), y si algún día se migra a 7, se corre el mismo test —adaptando solo el harness de `rxjs-marbles` de 6.x a 7.x— para confirmar que el frame de emisión no se corrió. Si el marble sigue verde, el timing se preservó; si cambia de frame, la migración alteró el comportamiento temporal y hay que investigar.

> **Por qué esto importa más que el resto del puente.** De todas las modernizaciones posibles, la de RxJS es la más traicionera, porque su bug característico —un `takeUntil` que cancela un frame tarde, una suscripción que sobrevive al logout— **no se ve** en un render ni en un click. Solo un test que fija el timing lo atrapa. El marble test es el único oráculo confiable para migrar streams. Sin él, migrar RxJS es exactamente "reescribir con fe".

### 5.5 RTK Query, React Router 6, React 17/18: qué son y por qué el curso paró donde paró

Tres pinceladas comparativas (Apéndice A8, opcional). Ninguna se aplica al código principal; el punto es que **reconozcas** estas herramientas cuando las cruces afuera y entiendas el costo de migrar hacia ellas.

**RTK Query** (mencionada por D4, no adoptada). Es la capa de data-fetching de Redux Toolkit: reemplaza el patrón `createAsyncThunk` + slice + estados de carga por un `createApi` que genera hooks (`useGetRafflesQuery`) con caché, invalidación y refetch automáticos. Sobre `raffleSlice`, RTK Query se comería casi todo el archivo: los cuatro thunks, los flags `loadingList`/`loadingMutation`, buena parte de los `extraReducers`. A cambio, agrega su propio reducer y middleware al store —y ahí está el costo oculto para el testing: `renderWithStore` (Fase 10) tendría que sumar ese middleware, rompiendo su premisa de "store síncrono sin middleware". Migrar a RTK Query no es cambiar un slice; es cambiar la forma del store y, con ella, el helper de test. Por eso queda como comparación 🔥.

**React Router 6** (el curso usa Router 5, D del stack). La diferencia de API es grande y mecánica: `<Switch>` pasa a `<Routes>`, `component={X}` pasa a `element={<X />}`, `useHistory()` pasa a `useNavigate()`, y las rutas anidadas cambian de modelo. No es conceptualmente más difícil; es simplemente *distinto*, y una migración toca cada archivo de rutas. El curso se quedó en 5 porque el sistema de referencia está en 5 y migrar el router no enseña nada sobre mantenimiento que las otras migraciones no enseñen mejor.

**React 17 y 18** (el código principal es 16.14.0, D1). React 17 fue casi sin features nuevas: su cambio relevante para un mantenedor es que el *event delegation* dejó de colgarse de `document`, lo que rara vez importa salvo en apps que mezclan React con jQuery viejo. React 18 sí trae cosas de fondo —`createRoot`, batching automático de actualizaciones, `Suspense` en el servidor, el modo concurrente— pero ninguna es gratis de adoptar en una base de clase + hooks + epics como esta. El curso fija 16.14.0 como **punto final de referencia exacto** (D1) precisamente para no diluir el foco: el objetivo era mantener un legacy real, no perseguir la última versión. Saber que 17 y 18 existen, y qué cambian, es suficiente; migrar hacia ellos es un proyecto en sí mismo, no un capítulo de cierre.

> **El hilo común de las tres.** Cada modernización promete borrar código (RTK Query borra thunks, Router 6 simplifica rutas, React 18 automatiza el batching). Y cada una tiene un costo que no está en el diff visible: RTK Query cambia el store y el harness de test, Router 6 toca cada ruta, React 18 cambia cómo se montan y actualizan los componentes. La lección de mantenimiento no es "moderniza" ni "no modernices": es **mide el costo real, incluido el que no se ve en el código, antes de decidir**. Y no decidas nunca sin la red de tests que te diga si el comportamiento sobrevivió.

---

## ⚠️ 6. Errores comunes y pieza forense

### 6.1 Los errores clásicos de la última milla

**Migrar sin correr el test viejo primero.** El error de proceso más común: escribir la versión funcional de `RaffleTable`, correr el test, verlo verde y declarar victoria. Falta el paso cero: correr el test contra la versión **de clase** antes de tocar nada, para confirmar que la línea base es verde. Si el test estaba rojo desde antes (por ejemplo, porque falta el `data-testid="raffles-loading"`), tu "migración exitosa" no probó nada: pasaste de rojo a rojo. El oráculo solo sirve si estableces la línea base primero.

**Tocar el test para que pase.** El anti-patrón que anula la red. Si al migrar el test se pone rojo y tu reacción es editar el test, párate: acabas de convertir el oráculo en un espejo. Un test que modificas para que pase con la implementación nueva ya no verifica nada; solo describe lo que escribiste. Si el test rojo es correcto —la migración cambió el comportamiento— el que se arregla es el código, no el test.

**Aprovechar la migración para "arreglar cositas".** Estás migrando `RaffleTable` a hooks y de paso cambias el `window.confirm` por un modal, y ya que estás normalizas el slice. Ahora tu PR de migración toca tres cosas no relacionadas, y si algo se rompe no sabes cuál fue. Una migración es una refactorización de comportamiento-cero: entra igual, sale igual, el diff solo debería mostrar el cambio de mecanismo. Las mejoras van en PRs aparte, cada una con su propio test.

**Confundir "el test pasa" con "la migración está completa".** El test de Fase 10 cubre el happy path y algunos bordes, no todo. Que pase es necesario, no suficiente. Un `useEffect` con las dependencias mal puestas puede pasar el test de montaje y aun así re-disparar `fetchRaffles` en cada render en producción. El oráculo reduce el riesgo; no lo elimina. Después del verde, sigue mirando el comportamiento real (DevTools, Network) en los caminos que el test no cubre.

**Pagar deuda sin su disparador.** Ves `raffleSlice` sin normalizar y te pica normalizarlo "porque es lo correcto". Pero el disparador (cientos de rifas) no ocurrió: estás gastando riesgo sin retorno, tocando código que funciona para ganar performance que nadie necesita todavía. La deuda se paga cuando su disparador se acerca, no cuando te molesta estéticamente.

### 6.2 Pieza forense de la fase: el test de regresión que reproduce el bug antes del fix

Esta es la pieza forense de Fase 11, y el cierre del track forense de todo el curso. No es una herramienta nueva: es la consolidación de una disciplina.

Repasa la cadena forense que el curso construyó fase a fase: Fase 5 te enseñó a *leer el store en el tiempo* (Redux DevTools, time-travel). Fase 6, a *leer el flujo de un Observable*. Fase 7, a *correlacionar el ciclo de vida de un epic con la red*. Fase 8, a *auditar la aritmética del dinero*. Fase 9, a *auditar performance y dónde vive la caché*. Fase 10, a *convertir cada reproducción manual en un assert automatizado*. Fase 11 le pone el broche: **todo bug se cierra con un test que fallaba antes del fix y pasa después**.

El procedimiento, que ya usaste en §5.3 y que te llevas como hábito permanente:

1. **Reproduce el bug** manualmente, hasta poder provocarlo a voluntad. Un bug que no sabes reproducir no lo sabes arreglar.
2. **Escribe el test que lo captura**, y confirma que **falla** con el bug presente. Este paso es el que la gente se saltea, y es el más importante: un test que nunca viste fallar no sabes si prueba lo que crees.
3. **Aplica el fix.**
4. **Corre el test.** Ahora pasa. El delta rojo→verde es la evidencia de que *ese* cambio arregló *ese* bug —no otra cosa, no una casualidad.
5. **El test queda.** Es la regresión: si alguien vuelve a introducir el bug, el test se vuelve rojo antes de que llegue a producción.

La razón profunda de escribir el test *antes* del fix, y no después: un test escrito después del fix nunca lo viste fallar, así que no sabes si realmente captura el bug o si pasa por otro motivo. El único momento en que puedes estar seguro de que un test prueba lo que dices es cuando lo ves fallar por la razón correcta. Por eso el orden es rojo primero, verde después. Un test que nació verde es un test en el que no puedes confiar como red de regresión.

> **El post-mortem sin culpabilización, como hábito de cierre.** Cuando un bug llega a producción, el track forense del curso termina no en el fix sino en el post-mortem: qué pasó, qué lo dejó pasar, qué cambia para que no vuelva —sin buscar a quién culpar. El doble submit de §5.3 no fue "culpa de quien escribió el `push`"; fue una interacción entre un backend caótico y una deshabilitación de botón que viajaba por el store. La pregunta no es *quién* sino *qué del sistema lo permitió*. Un equipo que busca culpables aprende a esconder errores; uno que busca causas aprende a prevenirlos. Ese es el último hábito que el curso te deja.

---

## 🧪 7. Ejercicios (30)

Los ejercicios de la última fase son distintos: algunos son de código, pero muchos son de **reflexión estructurada** y **decisión de mantenimiento**, porque esa es la habilidad que la fase cierra. Varios se resuelven mejor por escrito que por teclado.

**🟢 Fácil (1–7)**

1. Corre el test de `RaffleTable` de Fase 10 contra la versión de clase. Confirma que es verde (o rojo, si falta el `data-testid="raffles-loading"`). Anota cuál de los dos casos te tocó y por qué.
2. Agrega `data-testid="raffles-loading"` al `div` de carga de `RaffleTable` (versión de clase). Vuelve a correr el test. Describe el cambio de estado del test.
3. Recorre el mapa de deuda de §5.1 y elige la deuda que, en tu criterio, tiene el disparador **más cercano** hoy. Justifica en dos frases.
4. Para esa misma deuda, escribe cómo te darías cuenta de que el disparador ocurrió (qué síntoma, en qué herramienta lo verías).
5. Lista tres cosas que el curso te enseñó que *no* son sobre React en particular, sino sobre mantener software en general.
6. Mira la versión migrada de `RaffleTable` (§5.2) e identifica qué línea es el equivalente exacto de `componentDidMount`.
7. Explica con tus palabras por qué `statusLabel` no cambia entre la versión de clase y la funcional.

**🟡 Intermedio (8–17)**

8. Completa la migración de `RaffleTable` a hooks: escribe el `render`/JSX completo de los cuatro estados (cargando, error, vacío, lista) en la versión funcional, partiendo del esqueleto de §5.2. Corre el test como oráculo.
9. En la versión funcional, ¿qué pasa si pones `useEffect(() => { dispatch(fetchRaffles()); })` **sin** array de dependencias? Predice el comportamiento, después verifícalo en Network. Explica el bug.
10. Escribe el test de regresión (rojo primero) para el bug del ejercicio 9: un assert que falle si `fetchRaffles` se dispara más de una vez al montar. ¿Cómo lo verificas sin llamar al backend real?
11. Toma una deuda 💸 del mapa y escribe, en prosa, su ticket de backlog: título, contexto, disparador, criterio de aceptación del fix.
12. Compara el `handleDelete` de la versión de clase y la funcional. ¿Qué se mantiene idéntico y qué cambia? ¿Por qué la deuda del `window.confirm` sobrevive a la migración?
13. Escribe el marble test (conceptual, con `rxjs-marbles`) que confirmaría que `validateNumberEpic` emite en el mismo frame bajo RxJS 6 y 7. ¿Qué diagrama de marbles esperas?
14. Para el caso de §5.3, escribe el post-mortem sin culpabilización del doble submit: síntoma, causa raíz, qué del sistema lo permitió, prevención. Máximo una página.
15. RTK Query: describe qué archivos de `raffleSlice` desaparecerían si migraras, y qué línea nueva aparecería en `renderWithStore`. No lo implementes; solo el inventario del cambio.
16. Router 5 → 6: toma el archivo de rutas del proyecto (Fase 1) y escribe, ruta por ruta, cómo quedaría en Router 6 (`Routes`/`element`). Marca qué se rompería si migraras a medias.
17. Distingue, para tres deudas del mapa, si cada una es "deuda que conviene pagar pronto", "deuda que conviene vigilar" o "deuda que probablemente nunca se pague". Justifica el criterio.

**🟠 Difícil (18–24)**

18. Migra `RaffleTable` a hooks **y** demuestra que el test siguió verde en cada paso. Documenta el proceso rojo/verde: qué corriste, cuándo, qué viste. Si en algún punto se puso rojo, explica qué lo causó y cómo lo resolviste sin tocar el test.
19. Toma el bug del doble submit (§5.3). Implementa **primero** el hotfix con su test de regresión, **después** el refactor. Entrega los dos como si fueran dos PRs separados, cada uno con su descripción. Explica por qué no van juntos.
20. Elige una deuda 💸 del mapa y **págala de verdad** en un branch: implementa el fix correcto con su test. Después escribe por qué —fuera de este ejercicio— probablemente **no** deberías haberla pagado todavía (disparador ausente). El ejercicio es reconocer la tensión.
21. Reproduce el bug del `useEffect` sin dependencias (ejercicio 9) en la app real, captura la evidencia en Network (múltiples GET `/raffles`), escribe el test de regresión rojo, aplica el fix (`[dispatch]`), confirma verde. Post-mortem incluido.
22. Diseña la migración de `validateNumberEpic` a RxJS 7 **en un branch aislado que no toca el código principal**: cambia imports, adapta el harness de `rxjs-marbles` de 6 a 7, corre el marble. Documenta qué cambió en el test y qué NO cambió en el epic. Concluye si valdría la pena migrar todo el proyecto.
23. 💸 del reloj cliente/servidor: retoma el ejercicio 🟠 23 de Fase 10 (el test que falla en CI por zona horaria). Propón el diseño de `serverNow` que pagaría esta deuda, y el test que lo fijaría. ¿Por qué esta deuda es más peligrosa que la del `window.confirm`?
24. Audita el store completo del proyecto y decide, capa por capa (slice, epic, componente, selector), cuál migrarías primero si tuvieras que modernizar todo. Ordena por relación riesgo/beneficio y justifica. ¿Cuál dejarías para el final y por qué?

**🔴 Muy difícil (25–30) — finales de reflexión**

25. Escribe el **post-mortem del curso entero** como si el sistema de rifas fuera un producto real que mantuviste seis meses: los tres incidentes que más te costaron (elígelos de los que viste en las fases), qué patrón común tenían, y qué cambiarías en el diseño original para que esa clase de incidente no fuera posible. Sin culpar a nadie.
26. Ensayo de decisión: te dan presupuesto para modernizar **una** cosa del sistema —RTK Query, Router 6, React 18, o RxJS 7—. Elige una, defiende la elección con costo/beneficio real (incluido el costo invisible), y argumenta por qué las otras tres esperan. Después escribe el contraargumento: por qué alguien razonable elegiría distinto.
27. Diseña la estrategia e2e completa que Fase 10 dejó como 🔥: qué flujos cubrir además del happy path, si el smoke debería correr contra json-server efímero o seguir stubbeado (`cy.intercept`), y cómo esa decisión interactúa con la deuda de "smoke stubbeado vs real". No la implementes entera; diseña el plan y su orden de construcción.
28. El curso sostiene "no se moderniza lo que no está testeado". Construye el **contraejemplo más fuerte que puedas**: un caso real donde tuvieras que modernizar algo sin poder testearlo primero. ¿Cómo mitigarías el riesgo? ¿Qué haría la regla demasiado rígida, y dónde sigue siendo correcta?
29. Toma el sistema completo y propón qué **cuatro incidentes nuevos** agregarías al cuaderno forense del curso para cubrir huecos que ninguna fase tocó (pista: mira las deudas sin disparador del mapa). Para cada uno: síntoma, causa raíz plausible, y qué herramienta forense lo cazaría.
30. Meta-reflexión: si tuvieras que reescribir este curso para tu propio equipo entrante, ¿qué fase agregarías, cuál sacarías, y qué mantendrías intacto? Justifica cada decisión desde lo que de verdad necesita un mantenedor de legacy —no desde lo que sería "más completo". El curso tiene 96 horas por una razón; defiende o refuta ese límite.

---

## 📚 8. Referencias

**Documentación oficial (compatible con las versiones del curso)**

- https://legacy.reactjs.org/docs/hooks-effect.html — `useEffect` y su equivalencia con los métodos de ciclo de vida de clase. Es la doc que respalda la migración de §5.2.
- https://react-redux.js.org/api/hooks — `useSelector`/`useDispatch`, el reemplazo de `connect()`. Fíjate en react-redux 7.2.x.
- https://redux-toolkit.js.org/rtk-query/overview — RTK Query, mencionada por D4 (`prompts/decisiones-y-versiones.md`). Leerla como comparación, no como algo a adoptar: el proyecto usa `createAsyncThunk`.
- https://rxjs.dev/deprecations/breaking-changes — cambios de RxJS 6 → 7. Útil para el ejercicio 22; el código principal se queda en 6.6.7.

**Migración (leer con criterio, apuntan a versiones más nuevas)**

- https://reactrouter.com/en/main/upgrading/v5 — guía oficial de migración Router 5 → 6. Referencia para los ejercicios 16 y 26; no se migra en el curso.
- https://react.dev/blog/2022/03/08/react-18-upgrade-guide — guía de upgrade a React 18 (`createRoot`, batching). Contexto para la pincelada de §5.5.

**Apéndices del curso**

- **Apéndice A5** — Class components vs hooks. Es el desarrollo largo del mapa de equivalencias de §5.2.
- **Apéndice A6** — Redux clásico vs Toolkit. Respalda la parte `connect()` ↔ hooks.
- **Apéndice A7** — redux-observable épica por épica. Contexto del puente RxJS de §5.4.
- **Apéndice A8** — Puente a React moderno (opcional, comparativo). Es la extensión natural de §5.5: React 17/18, Server Components, solo pinceladas.

> ⚠️ Casi toda la doc oficial de estas librerías apunta hoy a versiones más nuevas que las del curso. Cuando veas una API que no reconoces (`createRoot`, `useNavigate`, `createApi`, `firstValueFrom`), es señal de que estás leyendo material posterior a las versiones fijadas —justamente el material de comparación de esta fase—. No lo copies al código principal.

> ⚠️ **Sobre las citas.** No tengo acceso a una base de datos ni a búsqueda web, así que estas URLs y nombres de sección pueden haber cambiado o contener imprecisiones. Verifica cada enlace antes de apoyarte en él, y confirma siempre que la versión que estás leyendo coincida con la del curso (React 16.14, RTK 1.8, react-redux 7.2, RxJS 6.6.7, Router 5).

---

## 🚀 9. Cierre del curso

Empezaste sabiendo React. Terminas sabiendo **mantener** un sistema React que no escribiste, que evolucionó de 2019 a hoy, que mezcla clases con hooks y `connect()` con `useSelector`, que habla con un backend que falla a propósito, y que tiene la clase de bugs —race conditions, suscripciones sin cancelar, aritmética de dinero, cierres por zona horaria— que no aparecen en ningún tutorial de "aprende React en un fin de semana". Esa es la diferencia entre escribir código y sostenerlo.

Las 96 horas no fueron sobre features. Fueron sobre una forma de trabajar: **leer antes de tocar**, distinguir la deuda deliberada del descuido, separar el hotfix del refactor, reproducir el bug antes de arreglarlo, cerrar cada corrección con un test que la fija, y modernizar solo lo que la red de tests te deja modernizar sin fe. Si te llevas una sola frase, que sea esta: **no se moderniza lo que no está testeado, y no se toca lo que no se entiende**. Todo lo demás son detalles de implementación.

Sobre el puente a lo moderno: existe, es real, y algún día lo vas a cruzar. RTK Query borrará tus thunks, Router 6 simplificará tus rutas, React 18 automatizará tu batching, RxJS 7 limpiará tus imports. Pero ahora sabes lo que ningún changelog te dice: cada una de esas mejoras tiene un costo que no está en el diff, y la única forma de cruzar el puente sin caerte es tener la red de Fase 10 puesta debajo. El curso te deja del lado 16.14.0 no porque lo moderno esté mal, sino porque aprender a mantener se hace mejor sobre lo que ya existe que sobre lo que todavía brilla.

La deuda técnica que dejaste está mapeada en `A12-mapa-de-deuda-tecnica.md`, con nombre y disparador. Los bugs que viste tienen su test de regresión. Los incidentes tienen su post-mortem sin culpables, y la 🪞 retrospectiva del mes al final de `cuaderno-incidentes.md` es el último entregable que te queda por escribir — el único de todo el curso que te llevas literalmente al trabajo real. El sistema que recibes no es perfecto —ninguno lo es— pero ahora lo entiendes lo suficiente para tocarlo sin miedo y con red. Eso es, en una línea, todo lo que un equipo de mantenimiento necesita de ti.

Fin del curso. El sistema es tuyo para mantener.

> **La señal de que todo quedó bien:** si mañana entra un ticket de un bug que nunca viste, y tu primer instinto —antes de tocar una línea— es reproducirlo, escribir el test que falla, y recién ahí arreglarlo… entonces el curso funcionó. No aprendiste React 16. Aprendiste a mantener.


> 🏷️ **No cierres la fase sin el tag.** Con el checklist de la sección 2 en
> verde y `git status` limpio:
>
> ```bash
> git tag -a fase-11-cierre-puente-react-moderno -m "F11 cerrada: <el checklist, en una línea por ítem>"
> ```
>
> Los commits de la fase llevan su prefijo (`f11: …`) y los de ejercicio su
> número (`f11 ej17: …`). Si un ejercicio merece su propio marcador va en
> `ej/f11/17`, y un incidente resuelto en el par `inc/<ID>/<slug>-roto` /
> `-fix`, con el ID que le reserva `cuaderno-incidentes.md`. Todo eso está en
> [`00-convencion-de-git-y-tags.md`](00-convencion-de-git-y-tags.md).
>
> Antes de tocar los ejercicios 🔥 de migración, pon el punto de retorno:
> `git tag pre-modernizacion`. Probar Router 6 o RTK Query deja de ser un
> riesgo cuando volver cuesta un comando.

---

## 📌 Pendientes sugeridos

> Material de autoría, no de lectura. Va acá abajo, fuera de la plantilla de nueve
> secciones, porque es lo que apareció al escribir la fase y no cabía adentro — y
> porque no debe competir con el cierre.

- ~~**La meta-deuda 💸 que la propia fase declara.**~~ **Pagada:** el mapa vive
  en `A12-mapa-de-deuda-tecnica.md`, versionado y mantenible, con su protocolo
  de actualización (§4 del apéndice).
- ~~**La tabla de deuda de §5.1 tiene cinco columnas.**~~ **Resuelta con la
  misma extracción:** en el A12 el inventario es una lista con subtítulos, como
  manda §3 de la guía, y cada entrada tiene el espacio para explicar su porqué
  en prosa en vez de comprimirlo en una celda.
- ~~**El cierre del curso no menciona el cuaderno de incidentes.**~~
  **Resuelto:** §9 enlaza la 🪞 retrospectiva del mes.
- ~~**`serverNow`, el `participantSlice` y la normalización de `raffleSlice`
  llegan al final sin fecha.**~~ **Resuelto:** el A12 §3 las declara
  explícitamente como las tres que sobreviven al curso, con el porqué de cada
  una. Una deuda eterna declarada es honesta; una diferida cinco veces, no.

### Reservas para el cuaderno de incidentes

Los IDs quedan reservados en `cuaderno-incidentes.md`, donde el enunciado ya
está redactado con sus pistas y su solución de referencia. El ID nunca se reasigna.

Esta fase **no produce incidentes nuevos**, y es la única que no lo hace. Su
trabajo es de cierre: aporta el criterio con el que se resuelven los veinte
anteriores —hotfix frente a refactor, deuda deliberada frente a descuido— y
cierra el incidente **20**, que Fase 10 dejó abierto.

Si más adelante alguna migración de esta fase produce un bug propio, entra al
cuaderno con un ID nuevo (21 en adelante). Los veinte existentes no se reasignan.
