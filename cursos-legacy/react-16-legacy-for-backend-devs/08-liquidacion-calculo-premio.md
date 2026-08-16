# 💰 Fase 08 — Liquidación + cálculo de premio

> Tutorial React 16 — Rifas y chances · Fase 8 de 11 · **8 horas**
> Depende de: Fase 7 — Cierre + polling de resultado · Habilita: Fase 9 — Dashboard

---

## 🎯 1. Propósito

Hasta acá la rifa ya recorre su vida entera: nace en `draft`, se abre, se
cierra por hora dura, y cuando llega el `winningNumber` del sorteo pasa a
`resolved`. Pero falta el paso que le da sentido económico a todo el
producto: **liquidar**. Calcular cuánto se le paga al ganador, cuánto le
queda al organizador, y dejar ese cálculo grabado de forma que nadie pueda
tocarlo después. Esta fase materializa la última transición del flujo,
`resolved → settled`, y la hace **irreversible**.

El foco real no es la aritmética —sumar y dividir lo sabes hacer desde la
primaria— sino **cómo se representa el dinero en JavaScript sin que se te
escape un centavo**. Y ahí hay una trampa que ha costado incidentes reales
en producción en medio mundo: `0.1 + 0.2 !== 0.3`. Fase 8 es donde el
curso paga la deuda que Fases 4 y 5 dejaron marcada con 💸 —"el dinero de
verdad es tema de Fase 8"— y establece la regla que rige de acá en
adelante: **el dinero se guarda y se calcula en enteros (centavos), nunca
en floats.**

---

## ✅ 2. Qué queda listo al terminar

- [ ] `numberPrice` y `basePrize` quedan definidos como **enteros en
      centavos**, con conversión explícita y auditable en el borde
      (`toCents` al entrar desde el formulario, `formatCents` al mostrar), y
      el `db.json` heredado queda **migrado** de pesos a centavos con una
      migración idempotente (§5.0). La ambigüedad "¿son pesos o centavos?"
      que arrastraban las Fases 0/1/3/4 queda cerrada por escrito.
- [ ] `calculatePrize` y `calculateMargin` son **funciones puras que solo
      operan con enteros**: el premio del ganador y el margen del
      organizador se calculan sin que un solo float entre en la ruta de
      cálculo. El redondeo es determinista y su regla está documentada.
- [ ] `settlementSlice` guarda la liquidación calculada y expone la
      transición `resolved → settled`, con guarda de estado de origen: solo
      se puede liquidar una rifa `resolved`, y una vez `settled` **no hay
      vuelta atrás** (sin acción de "deshacer", sin recálculo).
- [ ] `createSettlement` (thunk) calcula, persiste vía `POST /settlements`
      y despacha la transición de estado, reusando `toReadableError` con un
      `type: 'settlement'` nuevo dentro del mismo shape `{ message, type }`.
- [ ] La pieza forense está reproducida a propósito: un descuadre de
      centavos hecho con floats, diagnosticado en consola y en el store, y
      blindado con una prueba de regresión que falla con floats y pasa con
      enteros.

---

## 🚫 3. Qué queda fuera por ahora

- **Pasarela de pago real** (cobrar la venta, pagarle al ganador de
  verdad) → fuera del curso. Acá se **calcula y registra** la liquidación;
  mover plata real es otro mundo (idempotencia de cobros, conciliación
  bancaria, PCI) que el tutorial no toca.
- **Reparto entre múltiples ganadores** → se difiere. El modelo del mock
  tiene un `winningNumber` único por rifa (deuda 💸 heredada de Fase 7: el
  ganador es fijo por rifa). El reparto entre varios acertantes queda como
  ejercicio 🔥 y como posible incidente, no como código base.
- **Dashboard de indicadores de liquidación** (totales, márgenes agregados,
  gráficos) → Fase 9. Acá se calcula la liquidación de **una** rifa; la
  vista agregada es el trabajo siguiente.
- **Librería de dinero** (`dinero.js`, `big.js`) → se evalúa como 🔥, no se
  adopta. La decisión sigue **pendiente**, anotada en los 📌 Pendientes sugeridos de esta fase
  (ver §4); el código base usa enteros nativos, que no comprometen ninguna
  dependencia.
- **`serverNow` / reloj confiable del servidor** 💸 → sigue diferido. La
  liquidación de esta fase no depende de timestamps para calcular (usa el
  `winningNumber` ya persistido), así que no se paga esa deuda acá.

---

## 🧠 4. Conceptos mínimos

### El dinero va en enteros, en centavos, y nunca en floats → **A10**

Toda la aritmética de esta fase se apoya en una sola regla, y la regla no es de
esta fase sino del sistema entero: **el dinero se guarda como entero de
centavos y nunca toca un float.** El porqué —IEEE 754, el redondeo que pierde
plata, `money.js` con `toCents`/`formatCents`, y el patrón de reparto donde las
partes suman exactamente el todo— vive en
**`A10-aritmetica-de-dinero.md`**.

Si todavía no lo leíste, **léelo ahora**: §1 y §2 del apéndice son veinte
minutos y son prerrequisito real de lo que sigue. Esta fase asume `money.js`
escrito y entendido, y a partir de acá se dedica a lo que es propio del dominio:
qué se calcula en una liquidación de rifa, con qué reglas de negocio, y por qué
la transición a `settled` no tiene vuelta atrás.

> 🧭 **El resumen de una línea, por si vienes de repaso:** `$5.000,00` se guarda
> como `500000` (centavos, entero). Todo entra por `toCents` y sale por
> `formatCents`. Se divide con `Math.floor` más resto explícito, nunca con `/`
> a secas.


### La transición irreversible

Fase 7 materializó `open → closed` (por hora) y `closed → resolved` (por
resultado), cada una con guarda de estado de origen. Fase 8 agrega la
última, `resolved → settled`, con dos reglas nuevas:

- **Guarda de origen:** solo se liquida una rifa en estado `resolved`.
  Intentar liquidar una `open`, `closed` o ya `settled` se rechaza con un
  error legible, no con una excepción que rompe la UI.
- **Irreversibilidad:** una vez `settled`, no existe acción para volver a
  `resolved` ni para recalcular. La liquidación es un hecho contable
  registrado. Esto no es un detalle de UI (esconder un botón): el propio
  slice **no expone** ninguna transición de salida de `settled`. Si mañana
  aparece un requerimiento de "anular liquidación", será una operación nueva
  y auditada (un `reversal` con su propio registro), nunca un "deshacer".

> 📝 **Nota de decisión pendiente.** ¿Enteros nativos en centavos "a mano",
> o una librería tipo `dinero.js` / `big.js`? El stack de referencia del
> curso **no fija** una librería de dinero, y la regla del proyecto es no
> introducir dependencias modernas sin justificarlas contra el stack legacy.
> Por eso el código base usa **enteros nativos en centavos, sin librería**:
> es lo más alineado con "no sumar dependencias" y suficiente para el
> dominio. La evaluación de una librería queda registrada como **pendiente**
> en los 📌 Pendientes sugeridos de esta fase y aparece como ejercicio 🔥, no como código de
> producción de esta fase.

---

## 💻 5. Implementación y código comentado

La fase se reparte en cuatro capas bien separadas, y conviene tenerlas
claras antes de leer el código:

- **backend (mock):** `POST /settlements` en json-server (`apiClient`,
  puerto 3001). La colección `settlements: []` ya existe desde Fase 3.
- **cálculo (función pura):** `money.js` y `settlementMath.js`. Sin React,
  sin Redux, sin red. Aritmética entera testeable en aislamiento. Es el
  corazón de la fase.
- **store:** `settlementSlice` (nuevo) + el thunk `createSettlement` + la
  transición `resolved → settled` sobre `raffleSlice`.
- **frontend:** un componente `SettlementPanel` que muestra el cálculo y
  dispara la liquidación. Mínimo: la fase es de dinero y estado, no de UI.

### 5.0 Primero, la migración: el dato heredado viene en pesos

Antes de escribir una línea de aritmética hay que resolver algo que las fases
anteriores dejaron sin decidir, y que si no se resuelve **ahora** contamina todo
lo demás: **el `db.json` guarda pesos, no centavos.**

Míralo con tus propios ojos. La rifa que la Fase 3 sembró en el mock dice
`numberPrice: 5000` y `basePrize: 500000`, y las Fases 0, 1 y 4 los mostraron
crudos, como "$5000" y "$500000". Interpretados como pesos, eso es un número a
cinco mil pesos y un premio de medio millón: correcto. Interpretados como
centavos —que es lo que esta fase necesita— son cincuenta pesos y cinco mil.
**Cien veces menos.**

Nadie escribió eso mal. Simplemente nadie lo decidió: hasta ahora el dinero solo
se mostraba, y un número que solo se muestra no necesita unidad. En cuanto
empiezas a *sumarlo*, la unidad deja de ser un detalle y pasa a ser lo primero.
Es, palabra por palabra, cómo aparece esta clase de bug en sistemas reales.

📝 **Nota de época.** El equipo que escribió la liquidación en 2021 se comió
exactamente esta trampa, y le costó una tarde de conciliación con tesorería.
De ahí salió la regla que este archivo formaliza: **la unidad canónica del
sistema es el centavo, entero, y toda entrada y salida cruza por `money.js`.**
Está contado en `00-historia-del-sistema.md` §4.

**La migración**, que corre una sola vez sobre el mock:

```javascript
// mock/migrations/001-money-to-cents.js
// Migración única: convierte los montos de pesos a centavos en db.json.
// Se corre a mano (`node mock/migrations/001-money-to-cents.js`) y se marca
// con una bandera para que correrla dos veces no multiplique por 10 000.
const fs = require("fs");
const path = require("path");

const DB = path.join(__dirname, "..", "db.json");
const db = JSON.parse(fs.readFileSync(DB, "utf8"));

if (db.__moneyUnit === "cents") {
  console.log("Ya migrado. No se hace nada.");
  process.exit(0);
}

// * 100 sobre enteros es exacto: no hay float de por medio en ningún punto.
db.raffles = db.raffles.map((raffle) => ({
  ...raffle,
  numberPrice: raffle.numberPrice * 100,
  basePrize: raffle.basePrize * 100,
}));

db.__moneyUnit = "cents"; // la bandera que hace la migración idempotente
fs.writeFileSync(DB, JSON.stringify(db, null, 2));
console.log(`Migradas ${db.raffles.length} rifas de pesos a centavos.`);
```

Después de correrla, la rifa de ejemplo queda con `numberPrice: 500000` y
`basePrize: 50000000`, y **cada pantalla que muestre dinero tiene que pasar por
`formatCents`** — incluidas las que las Fases 0, 1 y 4 dejaron mostrando el
número crudo. Ese arrastre es deuda 💸 declarada: la Fase 8 arregla el
`SettlementPanel` y la tabla de rifas, y el resto queda anotado.

> 🧭 **La regla que te llevas, y que vale para cualquier sistema con dinero:**
> la unidad se declara **una vez, en un solo lugar, por escrito**, y todo lo
> demás se convierte en el borde. Un sistema donde hay que preguntar "¿esto
> está en pesos o en centavos?" ya tiene el bug; solo falta que alguien sume.

> ⚠️ **La bandera `__moneyUnit` no es adorno.** Una migración de dinero que se
> corre dos veces no falla: multiplica. Y multiplica en silencio, sobre datos
> que ya nadie va a mirar hasta la conciliación del mes. Toda migración de
> montos lleva su guarda de idempotencia, sin excepciones.

### `money.js` — el archivo que ya deberías tener

La frontera de entrada y salida del dinero (`toCents`, `formatCents`) está
escrita y explicada línea a línea en **`A10-aritmetica-de-dinero.md` §3**. No la
repetimos acá: es código que se consulta muchas veces a lo largo del curso —la
Fase 9 también lo usa para el dashboard— y duplicarlo garantizaría que las dos
copias diverjan.

Lo único que esta fase necesita que tengas presente:

- `toCents(input)` convierte la entrada del formulario a entero de centavos, y
  **lanza** si el formato no es exacto. Nada de redondeos silenciosos.
- `formatCents(cents)` convierte un entero a `"5.000,50"` para mostrar, y
  **lanza** si le pasas un float. Ese `throw` es deliberado: falla donde está el
  error, no tres pantallas más allá.

Todo lo que sigue en esta fase asume que ambas existen en
`src/features/settlements/money.js` y están testeadas.

### `settlementMath.js` — el cálculo del premio y el margen

```javascript
// src/features/settlements/settlementMath.js
// Cálculo puro de la liquidación. Todo en centavos (enteros). Sin React,
// sin Redux, sin red. Se puede probar con una tabla de casos y nada más.

/**
 * Calcula el recaudo total de una rifa: cuántos números se vendieron por
 * el precio de cada número. Todo entero.
 *
 * @param {object} params
 * @param {number} params.soldCount   - cantidad de números en estado 'sold'
 * @param {number} params.numberPrice - precio por número, EN CENTAVOS
 * @returns {number} recaudo total en centavos
 */
export function calculateTotalCollected({ soldCount, numberPrice }) {
  // Multiplicación de dos enteros: exacta mientras no supere MAX_SAFE_INTEGER.
  return soldCount * numberPrice;
}

/**
 * Calcula el premio a pagar. En el modelo del curso el premio es el
 * basePrize fijo de la rifa: el ganador se lleva el premio base completo.
 * La "fracción del número ganador" del enunciado se materializa cuando el
 * premio se prorratea (ver prizeShare, abajo), no en el caso base.
 *
 * @param {object} params
 * @param {number} params.basePrize     - premio base de la rifa, EN CENTAVOS
 * @param {string} params.winningNumber - número ganador (viene de raffle.result)
 * @param {string[]} params.soldNumbers - números efectivamente vendidos ('sold')
 * @returns {{ prizeAmount: number, isWinnerSold: boolean }}
 */
export function calculatePrize({ basePrize, winningNumber, soldNumbers }) {
  // Regla de negocio: solo se paga premio si el número ganador se vendió.
  // Si el ganador no se vendió, la casa no paga premio (prizeAmount = 0).
  // Esto es una decisión de dominio explícita, no un caso borde olvidado.
  const isWinnerSold = soldNumbers.includes(winningNumber);
  const prizeAmount = isWinnerSold ? basePrize : 0;
  return { prizeAmount, isWinnerSold };
}

/**
 * Calcula el margen del organizador: lo recaudado menos lo pagado en premio.
 * Puede ser negativo (si el premio supera el recaudo): la casa perdió. No
 * lo escondemos ni lo forzamos a cero; un margen negativo es información.
 *
 * @param {object} params
 * @param {number} params.totalCollected - recaudo total en centavos
 * @param {number} params.prizeAmount    - premio pagado en centavos
 * @returns {number} margen en centavos (puede ser negativo)
 */
export function calculateMargin({ totalCollected, prizeAmount }) {
  return totalCollected - prizeAmount;
}

/**
 * 🔥 Reparte un premio entre N ganadores SIN perder ni inventar un centavo.
 * No es código base (el mock tiene un ganador único), pero es el patrón
 * canónico de "las partes suman exactamente el todo" y el corazón del
 * redondeo determinista. Se usa en un ejercicio 🔴.
 *
 * Estrategia: división entera para la parte base de cada uno, y el resto
 * (siempre < N) se reparte de a un centavo entre los primeros ganadores.
 * Así la suma de las partes es EXACTAMENTE prizeAmount, sin floats.
 *
 * @param {number} prizeAmount - premio total en centavos (entero)
 * @param {number} winners     - cantidad de ganadores (entero > 0)
 * @returns {number[]} arreglo de centavos por ganador; su suma === prizeAmount
 */
export function prizeShare(prizeAmount, winners) {
  if (!Number.isInteger(prizeAmount) || !Number.isInteger(winners) || winners <= 0) {
    throw new Error('prizeShare requiere enteros y al menos un ganador');
  }
  const base = Math.floor(prizeAmount / winners); // parte entera para todos
  let remainder = prizeAmount % winners;          // centavos sobrantes: 0..winners-1

  return Array.from({ length: winners }, (_, i) => {
    // Los primeros `remainder` ganadores reciben un centavo extra.
    // Determinista: mismo input, mismo reparto, siempre.
    return base + (i < remainder ? 1 : 0);
  });
}
```

> **El patrón a memorizar.** *"División entera para la parte, resto
> explícito repartido de a uno, y una aserción de que las partes suman el
> todo."* Si te llevas una sola cosa de esta fase, que sea esta. Es el
> antídoto contra el redondeo que pierde centavos.

### `settlementSlice.js` — el estado de la liquidación

```javascript
// src/features/settlements/settlementSlice.js
import { createSlice, createAsyncThunk } from '@reduxjs/toolkit';
import apiClient from '../../api/apiClient';
import { toReadableError } from '../raffles/raffleSlice';
import { raffleSettled } from '../raffles/raffleSlice';
import { calculateTotalCollected, calculatePrize, calculateMargin } from './settlementMath';

/**
 * Thunk de liquidación. Orquesta: valida el estado de origen, calcula
 * (todo en centavos, funciones puras), persiste en el backend propio y
 * dispara la transición resolved -> settled sobre la rifa.
 *
 * No le pega a apiLottery: el winningNumber ya está en el store desde el
 * polling de Fase 7 (raffle.result). La liquidación es aritmética local
 * más una escritura, no una consulta a la lotería.
 */
export const createSettlement = createAsyncThunk(
  'settlements/create',
  async ({ raffle, soldNumbers, result }, { rejectWithValue, dispatch }) => {
    // Guarda de estado de origen: solo se liquida una rifa 'resolved'.
    // La irreversibilidad empieza acá: una rifa ya 'settled' no vuelve.
    if (raffle.status !== 'resolved') {
      return rejectWithValue({
        message: `No se puede liquidar una rifa en estado "${raffle.status}"`,
        type: 'settlement',
      });
    }

    // El cálculo es puro y entero. Nada de esto toca la red.
    const totalCollected = calculateTotalCollected({
      soldCount: soldNumbers.length,
      numberPrice: raffle.numberPrice, // centavos, garantizado por la migración 5.0
    });
    const { prizeAmount, isWinnerSold } = calculatePrize({
      basePrize: raffle.basePrize,     // centavos, garantizado por la migración 5.0
      winningNumber: result.winningNumber,
      soldNumbers,
    });
    const margin = calculateMargin({ totalCollected, prizeAmount });

    const settlement = {
      raffleId: raffle.id,
      winningNumber: result.winningNumber,
      isWinnerSold,
      soldCount: soldNumbers.length,
      totalCollected, // centavos
      prizeAmount,    // centavos
      margin,         // centavos
      settledAt: new Date().toISOString(),
    };

    try {
      // Persistencia en el backend propio (3001), no en la lotería.
      const response = await apiClient.post('/settlements', settlement);
      // Recién con la persistencia OK disparamos la transición de estado.
      // Si el POST falla, la rifa NO pasa a 'settled': no queremos una
      // rifa marcada como liquidada sin registro de liquidación detrás.
      dispatch(raffleSettled({ raffleId: raffle.id }));
      return response.data;
    } catch (error) {
      return rejectWithValue(toReadableError(error, 'settlement'));
    }
  }
);

const settlementSlice = createSlice({
  name: 'settlements',
  initialState: {
    // Liquidaciones indexadas por raffleId, para lectura O(1) desde selectores.
    byRaffleId: {},
    loading: false,
    error: null,
  },
  reducers: {},
  extraReducers: (builder) => {
    builder
      .addCase(createSettlement.pending, (state) => {
        state.loading = true;
        state.error = null;
      })
      .addCase(createSettlement.fulfilled, (state, action) => {
        state.loading = false;
        const settlement = action.payload;
        state.byRaffleId[settlement.raffleId] = settlement;
      })
      .addCase(createSettlement.rejected, (state, action) => {
        state.loading = false;
        // El payload del rejectWithValue ya viene con shape { message, type }.
        state.error = action.payload || {
          message: 'Error inesperado al liquidar',
          type: 'settlement',
        };
      });
  },
});

export default settlementSlice.reducer;

// --- Selectores ---

export const selectSettlement = (raffleId) => (state) =>
  state.settlements.byRaffleId[raffleId] || null;

export const selectIsRaffleSettled = (raffleId) => (state) =>
  Boolean(state.settlements.byRaffleId[raffleId]);

export const selectSettlementError = (state) => state.settlements.error;

export const selectSettlementLoading = (state) => state.settlements.loading;
```

### La transición `resolved → settled` en `raffleSlice`

La irreversibilidad vive en el reducer de la rifa. Fase 7 dejó el patrón:
cada transición chequea el estado de origen. Fase 8 agrega `raffleSettled`
siguiendo exactamente esa forma.

```javascript
// src/features/raffles/raffleSlice.js  (fragmento agregado por Fase 8)

// Dentro de reducers: {...}
raffleSettled: (state, action) => {
  const { raffleId } = action.payload;
  const raffle = state.items.find((r) => r.id === raffleId);
  if (!raffle) return;

  // Guarda de origen: solo 'resolved' puede pasar a 'settled'.
  // Cualquier otro estado se ignora en silencio a nivel reducer (la UI y
  // el thunk ya rechazaron con mensaje; acá somos la última barrera).
  if (raffle.status !== 'resolved') return;

  // Transición final. No existe ningún reducer que saque de 'settled':
  // esa ausencia ES la irreversibilidad. No es un flag que se pueda
  // flipear; es que la salida no está escrita.
  raffle.status = 'settled';
},
```

> **💸 Deuda técnica intencional.** `raffleSettled` recibe el `raffleId` y
> vuelve a buscar la rifa por `find`. Con muchas rifas eso es O(n) por
> transición. La normalización del `raffleSlice` a un `byId` indexado
> —que volvería esto O(1)— es una refactorización mayor que tocaría Fases
> 4-7 y sus tests. **Corrección mínima vs refactor:** la corrección mínima
> (lo que hacemos) es dejar el `find`, que con el volumen del curso es
> irrelevante; el refactor (normalizar el slice entero) se difiere a una
> hipotética fase de limpieza y se marca acá para que quede trazado. No se
> normaliza "de paso" porque cambiar la forma del store rompe selectores de
> cinco fases.

### `toReadableError` extendido con un `type` opcional

Fase 7 dejó `toReadableError(error)` devolviendo `{ message, type }`. Fase 8
necesita etiquetar sus errores como `'settlement'`. En vez de duplicar la
función, se le agrega un parámetro opcional que respeta el default anterior.

```javascript
// src/features/raffles/raffleSlice.js  (ajuste compatible hacia atrás)

/**
 * @param {unknown} error
 * @param {string} [fallbackType='unknown'] - type a usar si no se puede
 *        inferir uno más específico del error. Fase 8 pasa 'settlement'.
 */
export function toReadableError(error, fallbackType = 'unknown') {
  if (error.code === 'ECONNABORTED') {
    return { message: 'El servidor no respondió a tiempo', type: 'timeout' };
  }
  if (error.response && error.response.status === 401) {
    return { message: 'Sesión expirada', type: 'unauthorized' };
  }
  if (error.response && error.response.status >= 500) {
    return { message: 'Error del servidor al procesar la operación', type: 'http' };
  }
  // Sin señal específica: usamos el fallback que pidió el llamador.
  return { message: 'Ocurrió un error inesperado', type: fallbackType };
}
```

> **Nota de compatibilidad.** El parámetro nuevo tiene default `'unknown'`,
> así que todas las llamadas de Fases 4-7 siguen comportándose idéntico. Es
> una extensión, no un cambio: nadie de las fases previas se entera.

### `SettlementPanel.jsx` — la UI mínima

```javascript
// src/features/settlements/SettlementPanel.jsx
import React from 'react';
import { useSelector, useDispatch } from 'react-redux';
import { createSettlement, selectIsRaffleSettled, selectSettlementLoading } from './settlementSlice';
import { selectRaffleResult } from '../raffles/raffleSlice';
import { formatCents } from './money';

/**
 * Panel de liquidación de UNA rifa. Muestra el cálculo (en pesos, vía
 * formatCents) y, si la rifa está 'resolved', permite liquidarla. Una vez
 * 'settled', el botón desaparece: no hay "re-liquidar".
 */
export default function SettlementPanel({ raffle, soldNumbers }) {
  const dispatch = useDispatch();
  const result = useSelector(selectRaffleResult(raffle.id));
  const isSettled = useSelector(selectIsRaffleSettled(raffle.id));
  const loading = useSelector(selectSettlementLoading);

  const canSettle = raffle.status === 'resolved' && !isSettled && result;

  const handleSettle = () => {
    dispatch(createSettlement({ raffle, soldNumbers, result }));
  };

  return (
    <div className="settlement-panel">
      <h3>Liquidación</h3>
      {result && (
        <p>Número ganador: <strong>{result.winningNumber}</strong></p>
      )}
      <p>Precio por número: {formatCents(raffle.numberPrice)}</p>
      <p>Premio base: {formatCents(raffle.basePrize)}</p>

      {isSettled && <p className="text-success">Rifa liquidada. Esta operación es definitiva.</p>}

      {canSettle && (
        <button onClick={handleSettle} disabled={loading}>
          {loading ? 'Liquidando…' : 'Liquidar rifa'}
        </button>
      )}
    </div>
  );
}
```

### Registro del reducer en el store

```javascript
// src/app/store.js  (fragmento)
import settlementReducer from '../features/settlements/settlementSlice';

const store = configureStore({
  reducer: {
    auth: authReducer,
    raffles: raffleReducer,
    sales: saleReducer,
    settlements: settlementReducer, // ← nuevo en Fase 8
  },
  middleware: (getDefaultMiddleware) =>
    getDefaultMiddleware().concat(epicMiddleware),
});
```

### El backend del mock: `POST /settlements`

json-server ya sirve la colección `settlements` (existe vacía desde Fase 3
y está en `PROTECTED_ROUTES`). Un `POST /settlements` con el cuerpo del
objeto `settlement` lo agrega tal cual y le asigna un `id`. No hace falta
código de servidor nuevo: el CRUD de json-server alcanza.

> **Prueba de fuego.** Levanta el mock, haz
> `curl -X POST localhost:3001/settlements -H "Content-Type: application/json" -d '{"raffleId":1,"totalCollected":10000,"prizeAmount":500000,"margin":-490000}'`
> y confirma que `GET /settlements` te lo devuelve con su `id`. Fíjate que
> el `margin` negativo se guarda sin drama: la casa perdió en esa rifa y el
> dato lo refleja.

---

## ⚠️ 6. Errores comunes y pieza forense

### Errores comunes

1. **"El total da un centavo de más (o de menos) y no sé de dónde sale."**
   Síntoma: la suma de las partes no cuadra con el total. Causa: en algún
   punto se convirtió a float para dividir (`prizeAmount / winners` sin
   `Math.floor`, o `parseFloat(...) * 100`). Fix mínimo: mantener enteros y
   repartir el resto explícitamente con `prizeShare`. No es refactor: es
   sacar el float de la línea que lo metió.

2. **"`formatCents` explota con 'espera un entero'."** Síntoma: excepción al
   renderizar. Causa: le llegó un float, lo que significa que **más arriba**
   un cálculo produjo un float. Esto no es un bug de `formatCents`: es
   `formatCents` haciendo su trabajo de alarma. Fix: rastrea hacia atrás
   qué cálculo devolvió el decimal. La aserción está puesta justamente para
   que el float no llegue en silencio a la pantalla.

3. **"Liquidé dos veces la misma rifa."** Síntoma: dos registros en
   `/settlements` para el mismo `raffleId`. Causa: la guarda de estado se
   chequeó en la UI (esconder el botón) pero no en el thunk/reducer, y un
   doble click o un dispatch programático se coló. Fix mínimo: la guarda
   `raffle.status !== 'resolved'` en el thunk **y** en el reducer, que ya
   está en el código de arriba. Distingue capas: esconder el botón es UX, no
   es la garantía; la garantía vive en el reducer.

4. **"El margen negativo me parece un bug y lo forcé a cero."** No es un
   bug. Síntoma: alguien "corrige" el margen con `Math.max(0, margin)`.
   Causa: confundir "no me gusta el número" con "el número está mal". Un
   margen negativo es un hecho: la casa pagó más premio del que recaudó.
   Esconderlo es falsear la liquidación. Fix: saca el `Math.max` y deja que
   el dato diga la verdad.

### Pieza forense de esta fase — auditar una liquidación que no cuadra

La mecánica del bug de floats —cómo se ve, cómo se caza paso a paso, y el test
de regresión que lo blinda— está en **`A10-aritmetica-de-dinero.md` §6**. Acá va
la parte que es propia de esta fase: **qué capa auditas cuando una liquidación
concreta no cuadra**, que es una pregunta distinta de "por qué falla un float".

El principio heredado de las fases anteriores se mantiene: antes de tocar nada,
identifica la capa. Con dinero, las candidatas son cuatro y se descartan en este
orden, porque cada una es más cara de investigar que la anterior:

**1. El cálculo (función pura).** Corre `calculateTotalCollected` y
`calculatePrize` en la consola de Node con los datos exactos del reporte. Si el
descuadre aparece ahí, terminaste: no es React, no es Redux, no es la red.

**2. Las entradas del cálculo.** Si la función pura da bien, el problema son sus
argumentos. ¿`soldNumbers` trae los números correctos? ¿`raffle.numberPrice`
está en centavos o alguien guardó pesos después de la migración de §5.0? En
Redux DevTools, mira el estado justo antes del `createSettlement`.

**3. El reducer.** ¿El slice guardó lo que el thunk calculó, o hay una
transformación de por medio? Compara el `payload` de la acción `fulfilled`
contra el `state.settlements.byRaffleId[id]` resultante.

**4. La persistencia.** En Network, el cuerpo del `POST /settlements`. Si el
monto que sale por la red difiere del que está en el store, tienes una
serialización de por medio; si coincide y aun así el `db.json` guarda otra cosa,
el problema es del mock.

**Ejercicio de "rompe a propósito y observa".** Salta la migración de §5.0 —deja
el `db.json` con `numberPrice: 5000` en pesos— y liquida una rifa. El cálculo no
va a fallar: va a dar un total exactamente cien veces menor, sin un solo error en
consola. Míralo en Redux DevTools y en el `POST`. Ese es el bug más caro de esta
familia: **el que da un número perfectamente válido y perfectamente equivocado.**
Corre la migración y compara.

> 🧠 **Lo que enseña ese contraste.** Un bug de unidad no se caza con un
> `try/catch` ni con un test de "no lanza". Se caza con un test que conoce el
> valor esperado en la unidad correcta, o con una guarda en el borde que
> verifique el rango plausible. Es la razón de que §5.0 grabe `__moneyUnit` en el
> propio dato: para que la pregunta "¿en qué unidad está esto?" tenga respuesta
> sin adivinar.

Esta pieza forense es el insumo del incidente **18** de
`cuaderno-incidentes.md`.

---

## 🧪 7. Ejercicios (30)

**🟢 Fácil (1–8)**
1. Corre la migración de §5.0 sobre tu `db.json` y confirma que la rifa 1
   quedó con `numberPrice: 500000` y la bandera `__moneyUnit: "cents"`.
2. Vuelve a correr la migración y confirma que **no hace nada**. Explica en una
   línea qué habría pasado sin la bandera.
3. Antes de migrar, liquida una rifa y anota el `totalCollected`. Migra, liquida
   otra vez y compara: confirma el factor de 100 y explica por qué el primer
   resultado no lanzó ningún error.
4. Calcula el recaudo total de una rifa con 12 números vendidos a `500000`
   centavos cada uno usando `calculateTotalCollected`.
5. Llama `calculatePrize` con un `winningNumber` que **no** esté en
   `soldNumbers` y confirma que `prizeAmount` es `0` y `isWinnerSold` es
   `false`.
6. Muestra el margen de la rifa 1 en el `SettlementPanel` con `formatCents` y
   confirma que se ve como pesos, no como centavos crudos.
7. Liquida la rifa 1 desde `SettlementPanel` y confirma en Redux DevTools
   que su `status` pasó a `settled`.
8. Confirma con `curl` que `GET /settlements` devuelve la liquidación que
   acabas de crear, con su `id` asignado.

**🟡 Intermedio (9–17)**
9. Calcula el margen de una rifa que recaudó `1000000` centavos y pagó un
   premio de `500000`. Después, una que recaudó `100000` y pagó `500000`:
   confirma que el margen es negativo y explica qué significa.
10. Escribe un test que verifique que `calculatePrize` devuelve
    `prizeAmount: 0` cuando el `winningNumber` no está en `soldNumbers`.
11. Intenta liquidar una rifa en estado `open` y confirma que el thunk la
    rechaza con `type: 'settlement'` sin tocar el store de rifas.
12. Agrega al `SettlementPanel` la línea "Recaudo total" y "Margen"
    mostrados con `formatCents`, leídos de la liquidación persistida.
13. Reproduce el error común #3: fuerza un doble dispatch de
    `createSettlement` y confirma que la guarda del reducer evita el segundo
    `settled`.
14. Escribe `toCents` para que rechace `"5000.555"` (tres decimales) y
    justifica por qué no lo redondeamos en silencio.
15. Verifica que `raffleSettled` sobre una rifa ya `settled` no hace nada
    (idempotencia de la transición final).
16. Documenta en un comentario la diferencia entre la corrección mínima
    (guarda en el reducer) y el refactor (máquina de estados formal) para la
    transición de estado.
17. Confirma que liquidar **no** le pega a `apiLottery` (puerto 3002):
    mira Network y verifica que el único POST va a `3001/settlements`.

**🟠 Difícil (18–24)**
18. Reproduce el error de redondeo silencioso: reemplaza temporalmente
    `calculateTotalCollected` por la versión rota con floats de la pieza
    forense, liquida, y encuentra el descuadre en el cuerpo del
    `POST /settlements` en Network.
19. Diagnostica: "una liquidación quedó con `status: settled` en la rifa
    pero no hay registro en `/settlements`". Formula la hipótesis (¿el POST
    falló después del dispatch?) y propón el orden correcto de operaciones.
20. Escribe un test parametrizado que pruebe `prizeShare` para
    `(100, 3)`, `(10, 4)`, `(1, 5)` y `(0, 3)`, verificando en cada caso que
    la suma de las partes es exactamente el total.
21. La rifa liquidó con el ganador **no** vendido (`isWinnerSold: false`).
    Confirma que `prizeAmount` es 0 y que el margen es igual al recaudo
    total. Explica el caso de negocio.
22. Instrumenta `createSettlement` para loguear en consola los tres montos
    (recaudo, premio, margen) antes del POST, y correlaciona ese log con el
    cuerpo real en Network.
23. Encuentra el bug: un compañero escribió
    `const margin = Math.max(0, totalCollected - prizeAmount)`. Explica qué
    liquidaciones falsea y por qué es peor que un margen negativo visible.
24. Diagnostica un `POST /settlements` que cayó en el fallo `malformed` del
    caos de Fase 3: ¿la rifa quedó en `settled` o no? ¿Por qué el orden
    "persistir primero, transicionar después" importa acá?

**🔴 Muy difícil (25–30)**
25. Implementa el reparto real entre múltiples ganadores usando
    `prizeShare`: extiende `calculatePrize` para aceptar un arreglo de
    ganadores y devolver cuánto le toca a cada uno, garantizando que la suma
    sea exactamente el `basePrize`.
26. Escribe una prueba de propiedad (property-based, con muchos inputs
    aleatorios) que afirme: para cualquier `prizeAmount` entero y cualquier
    `winners > 0`, `prizeShare` devuelve partes que suman exactamente el
    total. Que falle si alguien reintroduce un float.
27. Reproduce y documenta como incidente completo (8 puntos, blameless) un
    caso de "dinero mal redondeado": síntoma en contabilidad, reproducción,
    evidencia en Network y store, causa raíz (float en el cálculo),
    corrección, regresión, prevención, post-mortem.
28. Diseña (sin implementar la pasarela) cómo sería una **anulación** de
    liquidación que respete la irreversibilidad: no un "deshacer", sino un
    `reversal` con su propio registro auditado. Documenta qué transición de
    estado necesitaría y por qué no puede volver a `resolved`.
29. Investiga el borde de `Number.MAX_SAFE_INTEGER`: ¿a partir de qué monto
    en centavos la aritmética entera de JavaScript deja de ser exacta? ¿Es
    un problema real para una rifa? Documenta el límite y cuándo importaría.
30. Correlación punta a punta: liquida bajo `CHAOS_LEVEL=high`, provoca que
    el `POST /settlements` falle y reintente, y arma el procedimiento
    reproducible que cruza el estado del store, el cuerpo del POST en
    Network y el registro final en `/settlements`, confirmando que no quedó
    ninguna rifa `settled` sin su liquidación detrás.

**🔥 Opcionales**
- 🔥 Evalúa adoptar `dinero.js` o `big.js` para el manejo de dinero:
  compara su API con el enfoque de enteros nativos, justifica si vale la
  dependencia contra el stack legacy, y registra la conclusión en
  los 📌 Pendientes sugeridos de esta fase. No lo integres al código base sin esa
  justificación.
- 🔥 Normaliza el `raffleSlice` a `byId` indexado (paga la deuda 💸 marcada
  en `raffleSettled`) y mide el impacto en los selectores de las Fases 4-7.
- 🔥 Agrega al `SettlementPanel` un desglose visual del reparto entre
  ganadores usando `prizeShare`, mostrando que las partes suman el todo.

---

## 📚 8. Referencias

**Del curso** (léelo primero)
- `A10-aritmetica-de-dinero.md` — el fundamento entero: floats, redondeo,
  `money.js`, reparto sin perder centavos y cómo se caza el bug. Sus referencias
  bibliográficas (Goldberg, MDN, IEEE 754) viven allá y no se duplican acá.

**Documentación oficial**
- https://redux-toolkit.js.org/api/createAsyncThunk — `createAsyncThunk`, patrón usado por `createSettlement` (RTK 1.8.6, la versión fijada).
- https://redux-toolkit.js.org/api/createSlice — `createSlice` y `extraReducers` con el builder callback.

**Video / apoyo**
- Búsqueda sugerida en YouTube: "redux toolkit createAsyncThunk tutorial" — para
  el patrón del thunk. Confirma que sea RTK 1.x y no 2.x.

**Orden de lectura sugerido:** `A10-aritmetica-de-dinero.md` §1-§3 (los
fundamentos, si no los tienes frescos) → doc de `createAsyncThunk` para el patrón
del thunk → volver a `settlementMath.js` y `settlementSlice.js` con los tests en
la otra pantalla.

> ⚠️ Las URLs, títulos de video y contenidos pueden estar desactualizados;
> verifícalos antes de compartirlos con el grupo. La doc de Redux Toolkit
> corresponde a versiones recientes: confirma que el API que uses exista en
> la 1.8.x fijada por el proyecto (el `createAsyncThunk` y el builder de
> `extraReducers` sí están disponibles en esa versión).

---

## 🚀 9. Cierre y conexión con la siguiente fase

Con esto el flujo de la rifa por fin se cierra de punta a punta: nace en
`draft`, vive abierta, se cierra por hora, se resuelve con el sorteo y
—ahora— se **liquida** de forma definitiva. El dinero dejó de ser un string
ambiguo arrastrado desde Fase 4 y pasó a ser lo que siempre debió: enteros
en centavos, con conversión explícita en los bordes y cálculo determinista
en el medio. La transición `resolved → settled` es irreversible no por una
regla de UI, sino porque el slice sencillamente no escribe ninguna salida de
`settled`: la irreversibilidad es la ausencia de la puerta de vuelta.

La Fase 9 construye el **Dashboard**: toma todas estas liquidaciones —cada
una con su recaudo, su premio y su margen, todos enteros exactos— y las
agrega en indicadores y vistas de conjunto. Es el paso natural: una vez que
cada rifa se liquida bien, la pregunta siguiente es "¿cómo va el negocio en
total?", y esa respuesta se construye sumando liquidaciones que, gracias a
esta fase, **suman exacto**.

> **La señal de que quedó bien:** si liquidas cien rifas, sumas sus cien
> márgenes en centavos, y el total cuadra al centavo con la suma de recaudos
> menos la suma de premios —sin un solo decimal fantasma— esta fase cumplió
> su propósito.


> 🏷️ **No cierres la fase sin el tag.** Con el checklist de la sección 2 en
> verde y `git status` limpio:
>
> ```bash
> git tag -a fase-08-liquidacion-calculo-premio -m "F8 cerrada: <el checklist, en una línea por ítem>"
> ```
>
> Los commits de la fase llevan su prefijo (`f08: …`) y los de ejercicio su
> número (`f08 ej17: …`). Si un ejercicio merece su propio marcador va en
> `ej/f08/17`, y un incidente resuelto en el par `inc/<ID>/<slug>-roto` /
> `-fix`, con el ID que le reserva `cuaderno-incidentes.md`. Todo eso está en
> [`00-convencion-de-git-y-tags.md`](00-convencion-de-git-y-tags.md).
>
> Y si vas a seguir con el track BE opcional 🔥 —que se puede empezar acá—,
> este es el commit que lleva además `git tag pre-backend-go`: el estado del
> frontend que `be03` tiene que dejar intacto.

---

## 📌 Pendientes sugeridos

> Material de autoría, no de lectura. Va acá abajo, fuera de la plantilla de nueve
> secciones, porque es lo que apareció al escribir la fase y no cabía adentro — y
> porque no debe competir con el cierre.

- **Normalizar `raffleSlice` a `byId` 💸 es ejercicio 🔥 sin disparador
  cuantificado.** "Cientos de rifas" no es un umbral. → Fijar el número a partir
  del costo real del `find` en el dashboard de Fase 9.
- **La librería de dinero (`dinero.js` / `big.js`) sigue sin decidir.** La fase
  usa enteros nativos a propósito y lo justifica bien; la decisión de adoptar una
  librería queda cerrada en `prompts/decisiones-y-versiones.md`: no se adopta. → No
  integrarla al código base sin esa confirmación.
- **"Liquidé dos veces la misma rifa" es el error común #3 y no llegó a incidente
  propio.** El incidente 18 cubre el centavo de diferencia, que es más sutil pero
  menos frecuente. → Ejercicio 🔴 acá; si más adelante se convierte en incidente,
  toma un ID nuevo (21), nunca uno reasignado.
- **El margen negativo (error común #4) es el mejor ejemplo del curso de "esto no
  es un bug".** Merece más espacio del que tiene. → Ampliar con el caso de negocio
  que lo produce.

### Reservas para el cuaderno de incidentes

Los IDs quedan reservados en `cuaderno-incidentes.md`, donde el enunciado ya
está redactado con sus pistas y su solución de referencia. El ID nunca se reasigna.

- **18** — *La liquidación da un centavo de diferencia* · Dinero · 🟠. Sale de la
  pieza forense de floats contra enteros: `calculateTotalCollectedBroken` con
  `numberPriceInPesos: 0.1` y tres números vendidos. El síntoma es de un centavo;
  la causa es estructural, y esa desproporción es la lección.
