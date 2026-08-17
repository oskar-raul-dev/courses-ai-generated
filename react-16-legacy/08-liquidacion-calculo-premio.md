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

El foco real no es la aritmética —sumar y dividir lo sabés hacer desde la
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
      (`toCents` al entrar desde el formulario, `formatCents` al mostrar).
      La ambigüedad "¿son pesos o centavos?" que arrastraban las Fases 4/5
      queda cerrada.
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
  adopta. La decisión sigue **pendiente** en `DECISIONES-PENDIENTES`
  (ver §4); el código base usa enteros nativos, que no comprometen ninguna
  dependencia.
- **`serverNow` / reloj confiable del servidor** 💸 → sigue diferido. La
  liquidación de esta fase no depende de timestamps para calcular (usa el
  `winningNumber` ya persistido), así que no se paga esa deuda acá.

---

## 🧠 4. Conceptos mínimos

### Por qué el dinero no se representa con floats

JavaScript tiene un solo tipo numérico, `number`, que es un flotante de
doble precisión (IEEE 754). Ese formato **no puede representar exactamente**
muchos decimales que a vos te parecen triviales. El caso canónico:

```javascript
0.1 + 0.2            // 0.30000000000000004
0.1 + 0.2 === 0.3    // false
```

No es un bug de JavaScript: es cómo funciona la aritmética binaria de punto
flotante en casi todos los lenguajes. El problema es que `0.1` en binario es
un decimal periódico infinito, igual que `1/3` lo es en decimal. Al
truncarlo a 64 bits, arrastrás un error minúsculo. Sumás muchos de esos
errores minúsculos a lo largo de una liquidación con cientos de números
vendidos, y terminás con **centavos que aparecen o desaparecen de la nada**.
En dinero, un centavo que no cuadra no es un error de redondeo simpático: es
una liquidación que no se puede auditar.

**La solución que usa toda la industria** (Stripe, bancos, sistemas
contables) es no guardar nunca "pesos con decimales" como float, sino
**guardar la unidad mínima indivisible como entero**. Para pesos con
céntimos, esa unidad es el centavo. `$5.000,00` se guarda como `500000`
(centavos), no como `5000.0`. Todos los cálculos se hacen sobre enteros —que
JavaScript **sí** representa exactamente hasta `Number.MAX_SAFE_INTEGER`,
2⁵³−1, más que suficiente para cualquier rifa— y solo al **mostrar** se
convierte a la representación con separador decimal.

> 📝 **Nota de dominio (COP y por qué igual usamos centavos).** La rifa vive
> en Colombia y la moneda es el peso colombiano (COP), que en la práctica
> cotidiana **no** usa centavos: nadie paga $5.000,50 por un número. Podría
> tentarte trabajar en pesos enteros directamente y olvidarte del problema.
> **No lo hacemos, a propósito.** El sistema real que vas a mantener maneja
> dinero con precisión de céntimos por herencia de integraciones y librerías
> internacionales, y el punto pedagógico es más profundo que "COP no tiene
> decimales": **los floats no son confiables para dinero, tenga o no tenga
> centavos la moneda en la calle.** Trabajar en centavos te entrena en la
> disciplina correcta —la unidad atómica entera— que aplica a cualquier
> moneda. Un `basePrize` de $5.000,00 COP se representa como `500000`
> centavos; lo que en la calle es "cinco mil pesos" en el store es "quinientos
> mil centavos", entero, exacto.

### El redondeo, que es donde de verdad se pierde plata

Sumar y restar enteros nunca pierde precisión. El problema aparece con la
**división**, y la liquidación divide: repartir un premio, calcular una
fracción, prorratear. Cuando dividís enteros, el resto no siempre es cero, y
ahí tenés que decidir qué hacer con la fracción sobrante. Tres cosas
importan:

**Primero, dividí lo último posible y sobre enteros.** No conviertas a
decimal para dividir "cómodo" y después redondees: cada conversión a float
reintroduce el error que estás tratando de evitar. Mantené enteros y usá
división entera (`Math.floor(a / b)`) más el resto (`a % b`) explícito.

**Segundo, elegí una regla de redondeo y hacela explícita.** `Math.round`
redondea `.5` siempre hacia arriba (`Math.round(2.5) === 3`,
`Math.round(-2.5) === -2` —ojo con negativos), lo que introduce un sesgo
sistemático si redondeás muchos valores. Para dinero, la regla más común es
**truncar hacia abajo con `Math.floor` y asignar el resto de forma
determinista** (por ejemplo, el último centavo va a una parte fija), de
modo que la suma de las partes sea **exactamente** igual al total. Esa
propiedad —que las partes sumen el todo, sin centavos colgando— es la que
hace una liquidación auditable.

**Tercero, el redondeo silencioso es el enemigo.** Un `Math.round` metido a
mitad de un cálculo, sin comentario, "para que quede lindo", es como se
pierden centavos sin que nadie se dé cuenta hasta que contabilidad reclama.
Toda operación de redondeo en esta fase es explícita, comentada, y tiene su
prueba.

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
> en `DECISIONES-PENDIENTES` y aparece como ejercicio 🔥, no como código de
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

### `money.js` — la frontera entre "lo que ve el humano" y "lo que calcula la máquina"

```javascript
// src/features/settlements/money.js
// Punto único de conversión entre la representación que ve el usuario
// (pesos con separador) y la representación interna (centavos, entero).
// TODO el dinero cruza por acá. Si un centavo se pierde, se pierde acá,
// y por eso acá es donde ponemos los tests más finos.

/**
 * Convierte una entrada de usuario (string o number en PESOS) a un entero
 * en CENTAVOS. Es la única puerta de entrada del dinero al sistema.
 *
 * Rechaza entradas que no pueda representar de forma exacta: si alguien
 * escribe más decimales que los que un centavo admite, es un error del
 * llamador, no algo que redondeemos en silencio.
 *
 * @param {string | number} input - monto en pesos, p. ej. "5000" o 5000.50
 * @returns {number} entero de centavos, p. ej. 500000 o 500050
 */
export function toCents(input) {
  // Normalizamos a string para no depender de cómo JS imprime el number.
  const raw = String(input).trim();

  // Aceptamos separador decimal con punto; el separador de miles se asume
  // ya removido por la capa de formulario (no adivinamos formatos locales
  // acá: eso es responsabilidad del input, no del conversor de dinero).
  if (!/^-?\d+(\.\d{1,2})?$/.test(raw)) {
    throw new Error(`Monto inválido para convertir a centavos: "${raw}"`);
  }

  const [pesosPart, centsPart = ''] = raw.split('.');
  const sign = pesosPart.startsWith('-') ? -1 : 1;
  const pesos = Math.abs(parseInt(pesosPart, 10));

  // Rellenamos a dos dígitos SIN usar floats: "5" -> "50" centavos,
  // "" -> "00". Nada de multiplicar por 100 en punto flotante.
  const cents = parseInt(centsPart.padEnd(2, '0'), 10);

  return sign * (pesos * 100 + cents);
}

/**
 * Convierte un entero de centavos a un string en PESOS para mostrar.
 * Es la única puerta de SALIDA del dinero hacia la interfaz.
 *
 * No usa toLocaleString con decimales sobre un float: parte el entero en
 * pesos y centavos con aritmética entera y arma el string a mano.
 *
 * @param {number} cents - entero de centavos, p. ej. 500050
 * @returns {string} representación en pesos, p. ej. "5.000,50"
 */
export function formatCents(cents) {
  if (!Number.isInteger(cents)) {
    // Si esto explota, alguien metió un float donde debía haber un entero:
    // es exactamente el bug que esta fase persigue. Fallamos ruidosamente.
    throw new Error(`formatCents espera un entero de centavos, recibió: ${cents}`);
  }

  const sign = cents < 0 ? '-' : '';
  const abs = Math.abs(cents);
  const pesos = Math.floor(abs / 100);   // división entera: sin float
  const remainder = abs % 100;           // resto exacto: 0..99

  // Separador de miles a mano para no depender de toLocaleString con floats.
  const pesosStr = String(pesos).replace(/\B(?=(\d{3})+(?!\d))/g, '.');
  const centsStr = String(remainder).padStart(2, '0');

  return `${sign}${pesosStr},${centsStr}`;
}
```

> **Detalle con intención.** Fijate que `toCents` **nunca multiplica por
> 100 en float**. La tentación obvia es `Math.round(parseFloat(raw) * 100)`,
> y funciona… casi siempre. `parseFloat("5000.10") * 100` da
> `500009.9999999999`, y ahí `Math.round` te salva por poco. Pero apoyarte
> en que `Math.round` "te salve" es precisamente la clase de redondeo
> silencioso que buscamos erradicar. Partir el string y trabajar los
> centavos como enteros elimina el float de raíz.

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
> todo."* Si te llevás una sola cosa de esta fase, que sea esta. Es el
> antídoto contra el redondeo que pierde centavos.

### `settlementSlice.js` — el estado de la liquidación

```javascript
// src/features/settlements/settlementSlice.js
import { createSlice, createAsyncThunk } from '@reduxjs/toolkit';
import apiClient from '../../app/apiClient';
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
      numberPrice: raffle.numberPrice, // ya en centavos
    });
    const { prizeAmount, isWinnerSold } = calculatePrize({
      basePrize: raffle.basePrize,     // ya en centavos
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

> **Prueba de fuego.** Levantá el mock, hacé
> `curl -X POST localhost:3001/settlements -H "Content-Type: application/json" -d '{"raffleId":1,"totalCollected":10000,"prizeAmount":500000,"margin":-490000}'`
> y confirmá que `GET /settlements` te lo devuelve con su `id`. Fijate que
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
   `formatCents` haciendo su trabajo de alarma. Fix: rastreá hacia atrás
   qué cálculo devolvió el decimal. La aserción está puesta justamente para
   que el float no llegue en silencio a la pantalla.

3. **"Liquidé dos veces la misma rifa."** Síntoma: dos registros en
   `/settlements` para el mismo `raffleId`. Causa: la guarda de estado se
   chequeó en la UI (esconder el botón) pero no en el thunk/reducer, y un
   doble click o un dispatch programático se coló. Fix mínimo: la guarda
   `raffle.status !== 'resolved'` en el thunk **y** en el reducer, que ya
   está en el código de arriba. Distinguí capas: esconder el botón es UX, no
   es la garantía; la garantía vive en el reducer.

4. **"El margen negativo me parece un bug y lo forcé a cero."** No es un
   bug. Síntoma: alguien "corrige" el margen con `Math.max(0, margin)`.
   Causa: confundir "no me gusta el número" con "el número está mal". Un
   margen negativo es un hecho: la casa pagó más premio del que recaudó.
   Esconderlo es falsear la liquidación. Fix: sacá el `Math.max` y dejá que
   el dato diga la verdad.

### Pieza forense de esta fase — Bug de dinero: floats vs enteros, redondeo silencioso

Esta es la pieza forense central: **auditar la aritmética del dinero**. El
principio heredado de fases anteriores se mantiene —identificá la capa: ¿el
descuadre está en el cálculo (función pura), en el store (reducer) o en el
backend (json-server guardó algo raro)?

**Ejercicio de "rompe a propósito y observa".** Tomá `calculateTotalCollected`
y reescribila mal, con floats y pesos en vez de centavos:

```javascript
// VERSIÓN ROTA — a propósito. NO va al código base.
function calculateTotalCollectedBroken({ soldCount, numberPriceInPesos }) {
  // Suma acumulada en float en vez de multiplicación entera de centavos.
  let total = 0;
  for (let i = 0; i < soldCount; i++) {
    total += numberPriceInPesos * 0.1 * 10; // simula un cálculo "inocente"
  }
  return total;
}
```

Ahora, en la consola de DevTools:

1. Corré `calculateTotalCollectedBroken({ soldCount: 3, numberPriceInPesos: 0.1 })`.
   Observá que no da `0.3` limpio.
2. Abrí Redux DevTools y compará: liquidá una rifa con la versión entera y
   mirá `totalCollected` en el store —un entero exacto de centavos—. Después
   imaginá ese mismo número guardado con la versión rota: el descuadre que
   contabilidad reclamaría.
3. En Network, mirá el cuerpo del `POST /settlements`. ¿Los montos son
   enteros? Un decimal ahí es la evidencia de que un float se coló hasta la
   persistencia.

**La prueba de regresión que blinda el arreglo:**

```javascript
// settlementMath.test.js
import { calculateTotalCollected } from './settlementMath';

test('el recaudo total es entero exacto, sin residuo de float', () => {
  // 3 números a 10 centavos: DEBE ser exactamente 30, no 30.000000004.
  const total = calculateTotalCollected({ soldCount: 3, numberPrice: 10 });
  expect(total).toBe(30);
  expect(Number.isInteger(total)).toBe(true);
});

test('prizeShare reparte sin perder ni inventar centavos', () => {
  const shares = prizeShare(100, 3); // 100 centavos entre 3
  expect(shares).toEqual([34, 33, 33]);
  expect(shares.reduce((a, b) => a + b, 0)).toBe(100); // las partes suman el todo
});
```

Esta pieza forense se referencia luego en `Forense - Fase 08`, y alimenta
los incidentes 🟠 de "dinero mal redondeado / cálculo erróneo" del cuaderno.

---

## 🧪 7. Ejercicios (30)

**🟢 Fácil (1–8)**
1. Convertí `"5000"` (pesos) a centavos con `toCents` y confirmá que da
   `500000`. Después convertilo de vuelta con `formatCents`.
2. Probá `toCents("5000.50")` y `toCents("5000.5")` y explicá por qué ambos
   deben dar `500050`.
3. Confirmá en consola que `0.1 + 0.2 !== 0.3` y escribí en un comentario
   por qué eso descalifica a los floats para dinero.
4. Llamá `formatCents(500050)` y verificá que devuelve `"5.000,50"`.
5. Calculá el recaudo total de una rifa con 12 números vendidos a `500000`
   centavos cada uno usando `calculateTotalCollected`.
6. Pasale a `formatCents` un float (`5000.5`) y observá que lanza la
   excepción. Explicá por qué eso es deseable.
7. Liquidá la rifa 1 desde `SettlementPanel` y confirmá en Redux DevTools
   que su `status` pasó a `settled`.
8. Confirmá con `curl` que `GET /settlements` devuelve la liquidación que
   acabás de crear, con su `id` asignado.

**🟡 Intermedio (9–17)**
9. Calculá el margen de una rifa que recaudó `1000000` centavos y pagó un
   premio de `500000`. Después, una que recaudó `100000` y pagó `500000`:
   confirmá que el margen es negativo y explicá qué significa.
10. Escribí un test que verifique que `calculatePrize` devuelve
    `prizeAmount: 0` cuando el `winningNumber` no está en `soldNumbers`.
11. Intentá liquidar una rifa en estado `open` y confirmá que el thunk la
    rechaza con `type: 'settlement'` sin tocar el store de rifas.
12. Agregá al `SettlementPanel` la línea "Recaudo total" y "Margen"
    mostrados con `formatCents`, leídos de la liquidación persistida.
13. Reproducí el error común #3: forzá un doble dispatch de
    `createSettlement` y confirmá que la guarda del reducer evita el segundo
    `settled`.
14. Escribí `toCents` para que rechace `"5000.555"` (tres decimales) y
    justificá por qué no lo redondeamos en silencio.
15. Verificá que `raffleSettled` sobre una rifa ya `settled` no hace nada
    (idempotencia de la transición final).
16. Documentá en un comentario la diferencia entre la corrección mínima
    (guarda en el reducer) y el refactor (máquina de estados formal) para la
    transición de estado.
17. Confirmá que liquidar **no** le pega a `apiLottery` (puerto 3002):
    mirá Network y verificá que el único POST va a `3001/settlements`.

**🟠 Difícil (18–24)**
18. Reproducí el error de redondeo silencioso: reemplazá temporalmente
    `calculateTotalCollected` por la versión rota con floats de la pieza
    forense, liquidá, y encontrá el descuadre en el cuerpo del
    `POST /settlements` en Network.
19. Diagnosticá: "una liquidación quedó con `status: settled` en la rifa
    pero no hay registro en `/settlements`". Formulá la hipótesis (¿el POST
    falló después del dispatch?) y proponé el orden correcto de operaciones.
20. Escribí un test parametrizado que pruebe `prizeShare` para
    `(100, 3)`, `(10, 4)`, `(1, 5)` y `(0, 3)`, verificando en cada caso que
    la suma de las partes es exactamente el total.
21. La rifa liquidó con el ganador **no** vendido (`isWinnerSold: false`).
    Confirmá que `prizeAmount` es 0 y que el margen es igual al recaudo
    total. Explicá el caso de negocio.
22. Instrumentá `createSettlement` para loguear en consola los tres montos
    (recaudo, premio, margen) antes del POST, y correlacioná ese log con el
    cuerpo real en Network.
23. Encontrá el bug: un compañero escribió
    `const margin = Math.max(0, totalCollected - prizeAmount)`. Explicá qué
    liquidaciones falsea y por qué es peor que un margen negativo visible.
24. Diagnosticá un `POST /settlements` que cayó en el fallo `malformed` del
    caos de Fase 3: ¿la rifa quedó en `settled` o no? ¿Por qué el orden
    "persistir primero, transicionar después" importa acá?

**🔴 Muy difícil (25–30)**
25. Implementá el reparto real entre múltiples ganadores usando
    `prizeShare`: extendé `calculatePrize` para aceptar un arreglo de
    ganadores y devolver cuánto le toca a cada uno, garantizando que la suma
    sea exactamente el `basePrize`.
26. Escribí una prueba de propiedad (property-based, con muchos inputs
    aleatorios) que afirme: para cualquier `prizeAmount` entero y cualquier
    `winners > 0`, `prizeShare` devuelve partes que suman exactamente el
    total. Que falle si alguien reintroduce un float.
27. Reproducí y documentá como incidente completo (8 puntos, blameless) un
    caso de "dinero mal redondeado": síntoma en contabilidad, reproducción,
    evidencia en Network y store, causa raíz (float en el cálculo),
    corrección, regresión, prevención, post-mortem.
28. Diseñá (sin implementar la pasarela) cómo sería una **anulación** de
    liquidación que respete la irreversibilidad: no un "deshacer", sino un
    `reversal` con su propio registro auditado. Documentá qué transición de
    estado necesitaría y por qué no puede volver a `resolved`.
29. Investigá el borde de `Number.MAX_SAFE_INTEGER`: ¿a partir de qué monto
    en centavos la aritmética entera de JavaScript deja de ser exacta? ¿Es
    un problema real para una rifa? Documentá el límite y cuándo importaría.
30. Correlación punta a punta: liquidá bajo `CHAOS_LEVEL=high`, provocá que
    el `POST /settlements` falle y reintente, y armá el procedimiento
    reproducible que cruza el estado del store, el cuerpo del POST en
    Network y el registro final en `/settlements`, confirmando que no quedó
    ninguna rifa `settled` sin su liquidación detrás.

**🔥 Opcionales**
- 🔥 Evaluá adoptar `dinero.js` o `big.js` para el manejo de dinero:
  compará su API con el enfoque de enteros nativos, justificá si vale la
  dependencia contra el stack legacy, y registrá la conclusión en
  `DECISIONES-PENDIENTES`. No lo integres al código base sin esa
  justificación.
- 🔥 Normalizá el `raffleSlice` a `byId` indexado (paga la deuda 💸 marcada
  en `raffleSettled`) y medí el impacto en los selectores de las Fases 4-7.
- 🔥 Agregá al `SettlementPanel` un desglose visual del reparto entre
  ganadores usando `prizeShare`, mostrando que las partes suman el todo.

---

## 📚 8. Referencias

**Documentación oficial**
- https://redux-toolkit.js.org/api/createAsyncThunk — `createAsyncThunk`, patrón usado por `createSettlement` (RTK 1.8.x, la versión fijada).
- https://redux-toolkit.js.org/api/createSlice — `createSlice` y `extraReducers` con el builder callback.
- https://developer.mozilla.org/es/docs/Web/JavaScript/Reference/Global_Objects/Number/MAX_SAFE_INTEGER — límite de enteros exactos, relevante para el ejercicio 29.
- https://developer.mozilla.org/es/docs/Web/JavaScript/Reference/Global_Objects/Math/round — comportamiento de `Math.round` con `.5` y negativos.

**Libros / lectura de fondo**
- "What Every Computer Scientist Should Know About Floating-Point Arithmetic" (David Goldberg) — el clásico sobre por qué los floats fallan. Denso pero definitivo.

**Video / apoyo**
- Búsqueda sugerida en YouTube: "why 0.1 + 0.2 does not equal 0.3 floating point" — hay varias explicaciones visuales buenas del problema base.
- Búsqueda sugerida: "handling money in javascript integers cents" — confirmá que el enfoque coincida con el de esta fase (enteros, no floats).

**Orden de lectura sugerido:** el artículo de Goldberg (o un resumen en
video) para entender *por qué* → doc de `createAsyncThunk` para el patrón del
thunk → volver a `money.js` y `settlementMath.js` con los tests en la otra
pantalla.

> ⚠️ Las URLs, títulos de video y contenidos pueden estar desactualizados;
> verificalos antes de compartirlos con el grupo. La doc de Redux Toolkit
> corresponde a versiones recientes: confirmá que el API que uses exista en
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

> **La señal de que quedó bien:** si liquidás cien rifas, sumás sus cien
> márgenes en centavos, y el total cuadra al centavo con la suma de recaudos
> menos la suma de premios —sin un solo decimal fantasma— esta fase cumplió
> su propósito.
