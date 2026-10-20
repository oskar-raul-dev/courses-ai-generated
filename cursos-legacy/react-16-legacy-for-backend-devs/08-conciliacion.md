# 💰 Fase 08 — Conciliación

> Tutorial React 16 — La Esclusa, la consola de Jewel Locks · Fase 8 de 11 · **10 horas**
> Depende de: Fase 7 — Cierre a hora exacta y polling de compras · Habilita: Fase 9 — Dashboard

---

## 🎯 1. Propósito

La Licda. Marisol De Gracia viene dos días por semana, abre el reporte de ganancias de Google Play al lado de lo que dice el sistema, y hace una sola pregunta, con la precisión de quien firma: *"¿y ese centavo de dónde salió?"*. La primera vez que alguien se la contestó mal fue en 2021: la primera conciliación contra la tienda dio catorce centavos de diferencia, le costó a la contadora de entonces una tarde entera, y de ahí salió la regla que el API respeta desde ese día: **el dinero se guarda en centavos de dólar, enteros** (`00-historia-del-sistema.md` §3, era 2). La consola, en cambio, nunca hizo una cuenta de dinero. Esta fase es la primera.

La otra pregunta no la hace Marisol sino la tienda. La reseña más votada de Jewel Locks dice *"la rueda está arreglada"*, y hoy nadie puede contestarla con números (historia §3 y §11). La Esclusa publica unos pesos —3.000, 2.000, 1.500… y 50 puntos básicos para la Esclusa de Oro— y guarda una bitácora de cada giro. Si la rueda gira con esos pesos, sus frecuencias tienen que parecerse a ellos; cuánto tienen que parecerse para que la diferencia sea azar y no trampa es estadística, y tiene respuesta.

Esta fase materializa la última transición del ciclo de una rueda, **`ended → reconciled`**, y la hace **irreversible**. Antes de pasarla, la consola concilia dos cosas. **Las compras**: lo que el API acreditó contra lo que la tienda cobró, con su comisión y con el precio de un paquete de 500 giros repartido entre esos giros sin perder un centavo. **Las probabilidades**: lo que la rueda dio contra lo que publica, con una banda de ±3σ por segmento y un chi-cuadrado global, en una función pura sobre enteros. La teoría de las dos herramientas estadísticas vive en `A14-estadistica-para-auditar-una-rueda.md`; acá se usan.

---

## ✅ 2. Qué queda listo al terminar

- [ ] `money.js`: el dinero de la consola entra por `toCents` y sale por `formatCents`, en centavos de dólar enteros, sin un float en el camino (la regla y su porqué, en `A10-aritmetica-de-dinero.md`).
- [ ] Una **bitácora sembrada** de 10.000 giros para la Rueda de fin de mes, que pasa a `ended`: generada con semilla fija por `mock/seed-reconciliation.js`, con la regla nueva (el segmento en que cayó **y** el premio entregado) y, con una bandera, con la regla vieja de la rueda que se acomoda.
- [ ] `oddsAudit(counts, weightsBp)`: función pura en enteros que devuelve `{ bandAlarms, chi2, chi2Alarm }`, las dos señales por separado. La rueda honesta sembrada no da alarma; la que se acomoda, sí.
- [ ] La conciliación de compras: `reconcilePurchases` cruza lo que el API acreditó (`3001`) con el reporte de la tienda (`3002`) y encuentra lo que falta y lo repetido; la comisión de la tienda (`STORE_FEE_BP`, 15 %) se calcula en enteros.
- [ ] `prizeShare` y `prorateSpinPrice`: el precio de un paquete de 500 giros por US$20,99 repartido entre sus giros y sus segmentos, y **las partes suman exactamente 2.099 centavos**.
- [ ] La transición `ended → reconciled` es una sola operación del mock (`POST /wheels/:id/reconciliation`) y no tiene salida en el reducer.
- [ ] La pantalla **Conciliación** (`/reconciliation`), donde Marisol ve las dos conciliaciones y concilia la rueda.

---

## 🚫 3. Qué queda fuera por ahora

- **La teoría estadística** → `A14-estadistica-para-auditar-una-rueda.md`. Esta fase usa la banda y el chi-cuadrado, explica qué deciden y remite para el porqué.
- **Acreditar los giros de una compra**, y defenderse de la notificación duplicada → track BE (`be07`). Acá se ve el daño (una compra acreditada dos veces, otra nunca); repararlo es del backend.
- **Conciliar en el servidor.** La consola baja los 10.000 giros de la bitácora y cuenta en el navegador. Con una rueda de un día alcanza; con la Semana del Canal (180.000 giros en su último día) no. La consulta con `GROUP BY` sobre la base es `be07`. 💸
- **Probar que el aleatorio es impredecible.** Que las frecuencias cuadren no dice que nadie pueda adivinar el próximo giro. Es otra pregunta, con otra herramienta (A14 §6, y el incidente `be-17`).
- **Los gráficos** → Fase 9. Acá las cifras, en tablas.
- **Una librería de dinero** (`dinero.js`, `big.js`) → no se adopta; el porqué está en A10 §7.

---

## 🧠 4. Conceptos mínimos

### El dinero va en centavos enteros → **A10**

Toda la aritmética de esta fase se apoya en una regla que no es de esta fase sino del sistema entero: **el dinero se guarda como entero de centavos y nunca toca un float**. El API la cumple desde 2021; la consola la adopta acá, con el mismo criterio: un solo archivo (`money.js`) por donde entra y sale todo el dinero, y división entera con el resto explícito, nunca `/` a secas. El porqué —IEEE 754, el redondeo que pierde plata, el patrón de reparto donde las partes suman exactamente el todo— está en **`A10-aritmetica-de-dinero.md`**. Si no lo leíste, §1 a §4 son media hora y son prerrequisito real de lo que sigue.

> 🧭 **El resumen de una línea:** US$20,99 se guarda como `2099`. Todo entra por `toCents` y sale por `formatCents`. Se reparte con `prizeShare`: división entera para todos y el resto de a un centavo.

### Dos conciliaciones, dos fuentes cada una

Conciliar es **comparar dos registros independientes del mismo hecho**. Si una sola fuente fuera la verdad, no habría nada que conciliar: solo habría que leerla. Por eso esta fase cruza dos pares:

- **Compras:** lo que el API acreditó (la colección `purchases` del `3001`) contra lo que la tienda cobró (su reporte de ganancias, en el `3002`). Una compra cobrada y no acreditada es un jugador que pagó y no recibió sus giros. Una acreditada dos veces es dinero que el estudio regaló.
- **Probabilidades:** lo que la rueda dio (la bitácora) contra lo que publica (los pesos de sus segmentos). Si no se parecen lo suficiente, la tabla que el juego muestra antes de cada compra —la que exige la tienda— no dice la verdad.

### El segmento en que cayó no es el premio entregado

La rueda nueva tiene **protección de duplicados con sustituto** (historia §5): si cae en un avatar que el jugador ya tiene, se le entrega el sustituto publicado de ese segmento —un set de gemas—. La rueda no cambió sus pesos; lo que cambió es lo que el jugador recibe. Por eso cada fila de la bitácora guarda **las dos cosas**: `landedSegment` (dónde cayó la rueda) y `deliveredPrize` (qué se entregó).

Y por eso **se audita `landedSegment`**. Si contaras los premios entregados, la rueda honesta parecería arreglada: dice que cayó menos veces en el avatar común —porque a los que ya lo tenían se les entregaron gemas— y más en el set de gemas básico. La sección 5.10 lo mide: la misma bitácora da χ² = 4,49 contada por segmento y χ² = 1.335 contada por premio. La rueda vieja, la que se acomoda, guardaba solo el premio entregado, en la única columna que tenía, y con eso no hay forma de saber en qué cayó.

### La banda de ±3σ y el chi-cuadrado → **A14**

Con 10.000 giros, la Esclusa de Oro (50 puntos básicos) tendría que salir unas 50 veces. Si sale 57, ¿la rueda está arreglada? No: el azar no da números redondos. La **banda de ±3σ** dice cuánto se puede alejar cada segmento de su esperado por pura suerte: con 10.000 giros, entre 28,8 y 71,2 veces para la Esclusa de Oro. El **chi-cuadrado** junta los ocho desvíos en un solo número y lo compara con un valor crítico —14,067 para ocho segmentos con α = 0,05—, que se da hecho. De dónde salen σ, la banda y ese 14,067, y por qué una rueda honesta da alarma en uno de cada veinte casos, es A14.

Lo que importa en esta fase es la decisión de diseño: `oddsAudit` reporta **las dos señales por separado**. La banda dice *qué* segmento se alejó; el chi-cuadrado dice si el conjunto se aleja más de lo que el azar explica. Una sola alarma es una pregunta, no una condena.

### Enteros también en la estadística

`oddsAudit` trabaja con conteos y puntos básicos, que son enteros. La banda, que en los libros se escribe con una raíz cuadrada, se compara al cuadrado y multiplicada por 10.000, y queda entera. El único cálculo con decimales es el chi-cuadrado, porque es un cociente; se compara con el valor crítico y no se guarda como dinero ni como conteo. Que la decisión sea entera no es una manía: es que dos máquinas distintas, con la misma bitácora, lleguen a la misma alarma.

### La transición irreversible

La Fase 4 dejó el ciclo de una rueda escrito: `draft → scheduled → live → ended → reconciled`. Esta fase materializa la última, con dos reglas:

- **Guarda de origen:** solo se concilia una rueda `ended`. El mock lo hace cumplir (`409`) y el reducer lo repite como última barrera.
- **Irreversibilidad:** una rueda `reconciled` no vuelve. No es un botón escondido: el reducer **no tiene ningún caso** que saque de `reconciled`, y el mock no tiene ruta para hacerlo. Si mañana hace falta anular una conciliación, será una operación nueva y auditada, nunca un "deshacer".

Y una tercera, que viene de la Fase 5: registrar la conciliación y cambiar el estado es **una sola operación del servidor**. Si fueran dos llamadas, una caída entre las dos dejaría una rueda conciliada sin registro detrás, o un registro de una rueda que sigue abierta.

---

## 💻 5. Implementación y código comentado

La fase se reparte en cuatro capas:

- **datos (mock):** la siembra de la bitácora y de las compras, la ruta de conciliación del `3001` y el reporte de ganancias del `3002`.
- **cálculo (funciones puras):** `money.js`, `oddsAudit.js` y `reconciliationMath.js`. Sin React, sin Redux, sin red. Es el corazón de la fase.
- **store:** `reconciliationSlice` con dos thunks, y la transición en `wheelSlice`.
- **pantalla:** `ReconciliationPage`, con su ruta y su entrada en el navbar.

### 5.1 La bitácora sembrada — `mock/spinLogGenerator.js`

Una conciliación necesita una bitácora, y la del laboratorio tiene que ser **reproducible**: con `Math.random()`, la conciliación de hoy y la de mañana darían números distintos y no habría forma de comparar un antes y un después. El generador usa un aleatorio sembrado —misma semilla, misma bitácora— y escribe las dos reglas de la historia: la nueva, con sustituto, y la vieja, la que se acomoda.

```javascript
// Generador sembrado de la bitácora de giros (F08). Misma semilla, misma bitácora:
// sin eso, la conciliación de hoy y la de mañana no serían comparables.
// Dos reglas, las dos de la historia:
//  - "substitute" (la nueva): la rueda cae con los pesos publicados; si el premio es un
//    avatar que el jugador ya tiene, se entrega su sustituto. Se guardan las dos cosas.
//  - "accommodating" (la vieja, 2021): antes de girar se sacan los avatares que el jugador
//    ya tiene y su peso se reparte entre los demás. Solo se guardaba lo entregado.

// Lo que se entrega cuando la rueda cae en un avatar repetido.
const SUBSTITUTES = {
  "avatar-comun": "set-gemas-basico",
  "avatar-raro": "set-gemas-plata",
  "esclusa-de-oro": "set-gemas-plata",
};

// PRNG de 32 bits (mulberry32): rápido, sembrable y suficiente para simular.
// No es un aleatorio para producción: la rueda de verdad no gira con esto.
function mulberry32(seed) {
  let a = seed | 0;
  return function next() {
    a = (a + 0x6d2b79f5) | 0;
    let t = Math.imul(a ^ (a >>> 15), 1 | a);
    t = (t + Math.imul(t ^ (t >>> 7), 61 | t)) ^ t;
    return ((t ^ (t >>> 14)) >>> 0) / 4294967296;
  };
}

// Elige un segmento según sus pesos (enteros que suman el total de la lista).
function pick(random, segments) {
  const total = segments.reduce((sum, s) => sum + s.weightBp, 0);
  const r = Math.floor(random() * total); // entero en [0, total)
  let acc = 0;
  for (const segment of segments) {
    acc += segment.weightBp;
    if (r < acc) return segment;
  }
  return segments[segments.length - 1];
}

/**
 * @param {object} options
 * @param {number} options.seed
 * @param {number} options.spins - cuántos giros
 * @param {number} options.wheelId
 * @param {{ segmentId: string, prizeType: string, weightBp: number }[]} options.segments
 * @param {"substitute" | "accommodating"} [options.rule]
 * @param {number} [options.players] - cuántos jugadores distintos giran
 * @param {number} [options.veteranShare] - fracción de jugadores que ya tienen los avatares comunes
 * @param {string} [options.startsAt] - instante del primer giro (ISO con offset)
 * @returns {object[]} filas de spinLog
 */
function generateSpinLog({
  seed,
  spins,
  wheelId,
  segments,
  rule = "substitute",
  players = 800,
  veteranShare = 0.3,
  startsAt = "2026-08-01T00:00:00-05:00",
}) {
  const random = mulberry32(seed);
  const avatars = segments.filter((s) => s.prizeType === "avatar").map((s) => s.segmentId);
  // Inventario de avatares por jugador. Los veteranos arrancan con los dos más comunes.
  const owned = new Map();
  for (let i = 0; i < players; i++) {
    const playerId = 1001 + i;
    owned.set(playerId, new Set(random() < veteranShare ? avatars.slice(0, 2) : []));
  }
  const start = Date.parse(startsAt);
  const rows = [];
  for (let i = 0; i < spins; i++) {
    const playerId = 1001 + Math.floor(random() * players);
    const has = owned.get(playerId);
    const createdAt = new Date(start + i * 240000).toISOString(); // un giro cada cuatro minutos
    const idempotencyKey = `seed-${seed}-${i}`;
    const origin = random() < 0.25 ? "paid" : "free";
    if (rule === "accommodating") {
      // La rueda que se acomoda: los repetidos salen de la rueda antes de girar.
      const eligible = segments.filter((s) => !has.has(s.segmentId));
      const landed = pick(random, eligible);
      if (landed.prizeType === "avatar") has.add(landed.segmentId);
      // Solo se guardaba el premio entregado, en la única columna que había.
      rows.push({ wheelId, playerId, landedSegment: landed.segmentId, origin, idempotencyKey, createdAt });
    } else {
      const landed = pick(random, segments);
      let deliveredPrize = landed.segmentId;
      if (landed.prizeType === "avatar") {
        if (has.has(landed.segmentId)) deliveredPrize = SUBSTITUTES[landed.segmentId];
        else has.add(landed.segmentId);
      }
      rows.push({ wheelId, playerId, landedSegment: landed.segmentId, deliveredPrize, origin, idempotencyKey, createdAt });
    }
  }
  return rows;
}

module.exports = { generateSpinLog, mulberry32, SUBSTITUTES };
```

> ⚠️ **`mulberry32` no es el aleatorio de la rueda.** Es un generador rápido y sembrable para simular, que es lo que hace falta acá. La rueda de producción gira en el servidor con un aleatorio criptográfico; elegirlo bien es otra pregunta (A14 §6 y `be-17`).

### 5.2 La siembra — `mock/seed-reconciliation.js`

El script pone a la Rueda de fin de mes en `ended` —cerró el 30 de agosto a las 20:00, y la Fase 7 ya no deja enviar giros de ella—, le escribe 10.000 giros con la semilla 42, y siembra lo que la conciliación de compras cruza: el catálogo de la tienda (historia §8: 10 giros por US$0,99 y 500 por US$20,99), las compras que el API acreditó, y el reporte de ganancias de agosto que deja el mock de Google Play. Los giros pagos consumen las compras acreditadas, en orden.

```javascript
// Siembra los datos de la conciliación (F08). Determinista: semilla fija.
//   node mock/seed-reconciliation.js                  la bitácora con la regla nueva (sustituto)
//   node mock/seed-reconciliation.js --accommodating  la misma rueda con la regla vieja (se acomoda)
// Escribe mock/db.json (rueda 4 terminada, su bitácora, paquetes, compras acreditadas por el API)
// y mock/googlePlay/earnings.json (el reporte de ganancias de la tienda de agosto).
const fs = require("fs");
const path = require("path");
const { generateSpinLog } = require("./spinLogGenerator");

const SEED = 42;
const SPINS = 10000;
const WHEEL_ID = 4; // la Rueda de fin de mes, que cerró el 30/08 a las 20:00
const rule = process.argv.includes("--accommodating") ? "accommodating" : "substitute";

const DB = path.join(__dirname, "db.json");
const EARNINGS = path.join(__dirname, "googlePlay", "earnings.json");
const db = JSON.parse(fs.readFileSync(DB, "utf8"));

// El catálogo de la tienda (historia §8): 10 giros por US$0,99 y 500 por US$20,99.
db.packages = [
  { productId: "spins-10", spins: 10, packagePriceCents: 99 },
  { productId: "spins-500", spins: 500, packagePriceCents: 2099 },
];

// Cuarenta compras de agosto. Una de cada siete es el paquete grande.
const purchases = Array.from({ length: 40 }, (_, i) => ({
  purchaseToken: `tok-ago-${String(i + 1).padStart(2, "0")}`,
  productId: (i + 1) % 7 === 5 ? "spins-500" : "spins-10",
  chargedAt: new Date(Date.parse("2026-08-01T10:00:00-05:00") + i * 64800000).toISOString(),
}));

// Lo que el API acreditó. Dos descuadres, los dos de la vida real:
//  - tok-ago-31 se pagó en efectivo y se confirmó tarde: el API nunca la acreditó.
//  - tok-ago-17 llegó en dos notificaciones y el API la acreditó dos veces.
const credited = [];
for (const p of purchases) {
  if (p.purchaseToken === "tok-ago-31") continue;
  credited.push({ purchaseToken: p.purchaseToken, productId: p.productId, creditedAt: p.chargedAt });
  if (p.purchaseToken === "tok-ago-17") credited.push({ purchaseToken: p.purchaseToken, productId: p.productId, creditedAt: p.chargedAt });
}
db.purchases = credited;

// La bitácora de la rueda 4. Los giros pagos consumen las compras acreditadas, en orden.
const segments = db.segments.filter((s) => s.wheelId === WHEEL_ID);
const log = generateSpinLog({ seed: SEED, spins: SPINS, wheelId: WHEEL_ID, segments, rule });
const spinsOf = Object.fromEntries(db.packages.map((p) => [p.productId, p.spins]));
let purchase = 0;
let used = 0;
for (const row of log) {
  if (row.origin !== "paid") continue;
  while (purchase < credited.length && used >= spinsOf[credited[purchase].productId]) {
    purchase += 1;
    used = 0;
  }
  if (purchase >= credited.length) {
    row.origin = "free"; // se acabaron los paquetes: el resto de los giros fueron gratis
    continue;
  }
  row.purchaseToken = credited[purchase].purchaseToken;
  used += 1;
}
let nextId = 1;
db.spinLog = db.spinLog.filter((row) => row.wheelId !== WHEEL_ID).concat(log);
db.spinLog.forEach((row) => { row.id = nextId++; });

db.wheels.find((w) => w.id === WHEEL_ID).status = "ended";
db.reconciliations = db.reconciliations || [];
fs.writeFileSync(DB, JSON.stringify(db, null, 2) + "\n");

// El reporte de la tienda: un renglón por cobro, con la comisión que la tienda redondeó.
const priceOf = Object.fromEntries(db.packages.map((p) => [p.productId, p.packagePriceCents]));
const earnings = purchases.map((p) => {
  const chargedCents = priceOf[p.productId];
  const feeCents = Math.floor((chargedCents * 1500 + 5000) / 10000);
  return { purchaseToken: p.purchaseToken, productId: p.productId, chargedAt: p.chargedAt, chargedCents, feeCents };
});
fs.writeFileSync(EARNINGS, JSON.stringify(earnings, null, 2) + "\n");

console.log(`regla ${rule}: ${log.length} giros en la rueda ${WHEEL_ID}, ${credited.length} acreditaciones, ${earnings.length} cobros de la tienda`);
```

Los dos descuadres de compras no son inventos del laboratorio: son los de la Fase 7. Una compra en efectivo que se confirmó tarde y nadie acreditó es el ticket de Yariela *"ya pagué y no me llegaron los giros"*; una notificación de la tienda que llega dos veces (`PLAY_DUPLICATE=1` en el mock) es la que el backend tiene que aprender a ignorar en `be07`.

El script entra como `npm run seed:reconciliation`. Se corre con los mocks parados, porque json-server lee el `db.json` al arrancar:

```bash
npm run seed:reconciliation
# regla substitute: 10000 giros en la rueda 4, 40 acreditaciones, 40 cobros de la tienda
```

> 💡 **El `db.json` crece a unos 2,7 MB.** Diez mil filas de bitácora son eso. Está versionado igual que antes —es dato semilla—, y volver a correr el script lo deja idéntico: borra los giros de la rueda 4 antes de escribirlos.

### 5.3 `money.js` — la frontera del dinero

El archivo es el de `A10-aritmetica-de-dinero.md` §3, en dólares: `toCents` convierte la entrada a centavos sin multiplicar por 100 en float y rechaza más de dos decimales; `formatCents` arma `"US$20,99"` con aritmética entera y **explota** si le llega un float. Ese `throw` es deliberado: falla donde está el error, no tres pantallas más allá.

```javascript
// Punto único de conversión entre lo que ve el operador (dólares con coma decimal)
// y lo que guarda el sistema (centavos de dólar, enteros). Todo el dinero cruza por acá.

/**
 * Convierte una entrada en DÓLARES ("20.99", "20,99" o "21") a un entero de CENTAVOS.
 * Rechaza lo que no puede representar exacto: más de dos decimales es un error del
 * llamador, no algo que se redondee en silencio. Nunca multiplica por 100 en float.
 * @param {string | number} input
 * @returns {number}
 */
export function toCents(input) {
  const raw = String(input).trim().replace(",", ".");
  if (!/^-?\d+(\.\d{1,2})?$/.test(raw)) {
    throw new Error(`Monto inválido para convertir a centavos: "${input}"`);
  }
  const [dollarsPart, centsPart = ""] = raw.split(".");
  const sign = dollarsPart.startsWith("-") ? -1 : 1;
  const dollars = Math.abs(parseInt(dollarsPart, 10));
  const cents = parseInt(centsPart.padEnd(2, "0"), 10); // "9" → 90, "" → 0
  return sign * (dollars * 100 + cents);
}

/**
 * Convierte un entero de centavos a texto para mostrar: 2099 → "US$20,99".
 * Si le llega un float, explota: alguien más arriba calculó con decimales.
 * @param {number} cents
 * @returns {string}
 */
export function formatCents(cents) {
  if (!Number.isInteger(cents)) {
    throw new Error(`formatCents espera un entero de centavos, recibió: ${cents}`);
  }
  const sign = cents < 0 ? "-" : "";
  const abs = Math.abs(cents);
  const dollars = String(Math.floor(abs / 100)).replace(/\B(?=(\d{3})+(?!\d))/g, ".");
  const rest = String(abs % 100).padStart(2, "0");
  return `${sign}US$${dollars},${rest}`;
}
```

### 5.4 `oddsAudit.js` — la conciliación de probabilidades

```javascript
import { TOTAL_BP } from "../wheels/weightRules";

// Valor crítico de chi-cuadrado con 7 grados de libertad (8 segmentos) y α = 0,05.
// Se da hecho, de tabla: la teoría está en A14.
export const CHI2_CRITICAL_DF7_05 = 14.067;

/**
 * Cuántas veces cayó la rueda en cada segmento, en el orden de `segments`.
 * Cuenta landedSegment, no el premio entregado: lo que se audita es la rueda.
 * @param {{ landedSegment: string }[]} spinLog
 * @param {{ segmentId: string }[]} segments
 * @returns {number[]}
 */
export function countLanded(spinLog, segments) {
  const index = new Map(segments.map((s, i) => [s.segmentId, i]));
  const counts = segments.map(() => 0);
  for (const row of spinLog) {
    const i = index.get(row.landedSegment);
    if (i !== undefined) counts[i] += 1;
  }
  return counts;
}

/**
 * Concilia lo observado contra los pesos publicados. Función pura, sobre enteros.
 *
 *  - Banda de ±3σ por segmento: |observado − esperado| > 3σ. Multiplicando por
 *    TOTAL_BP y elevando al cuadrado, la comparación queda entera y sin raíz:
 *    (c·10.000 − n·w)² > 9 · n · w · (10.000 − w).
 *  - Chi-cuadrado global: Σ (observado − esperado)² / esperado. Es el ÚNICO cálculo
 *    con decimales, porque el estadístico es un cociente; se compara con el valor
 *    crítico y no se guarda como dinero ni como conteo.
 *
 * @param {number[]} counts - giros observados por segmento
 * @param {number[]} weightsBp - pesos publicados, en puntos básicos (suman TOTAL_BP)
 * @returns {{ bandAlarms: number[], chi2: number, chi2Alarm: boolean }}
 *   bandAlarms: índices de los segmentos fuera de su banda
 */
export function oddsAudit(counts, weightsBp) {
  if (counts.length !== weightsBp.length) throw new Error("oddsAudit: un conteo por segmento");
  if (!counts.concat(weightsBp).every(Number.isInteger)) throw new Error("oddsAudit: solo enteros");
  const n = counts.reduce((sum, c) => sum + c, 0);
  // Sin giros no hay nada que auditar: ni alarma, ni un χ² de 0/0.
  if (n === 0) return { bandAlarms: [], chi2: 0, chi2Alarm: false };
  const bandAlarms = [];
  let chi2 = 0;
  weightsBp.forEach((w, i) => {
    // Desvío escalado por TOTAL_BP: entero. Exacto mientras |d| < 9,49·10⁷, o sea,
    // salvo desvíos de más de 9.000 giros, que ya están fuera de cualquier banda.
    const d = counts[i] * TOTAL_BP - n * w;
    if (d * d > 9 * n * w * (TOTAL_BP - w)) bandAlarms.push(i);
    chi2 += (d * d) / (TOTAL_BP * n * w); // = (c − e)² / e, con e = n·w / TOTAL_BP
  });
  return { bandAlarms, chi2, chi2Alarm: chi2 > CHI2_CRITICAL_DF7_05 };
}
```

Dos detalles merecen una segunda lectura. `countLanded` cuenta `landedSegment` y no `deliveredPrize`: es la sección 4 escrita en código. Y la banda: la condición `|c − e| > 3σ` de los libros, con `e = n·w / 10.000` y `σ² = n·w·(10.000 − w) / 10.000²`, multiplicada por 10.000 y elevada al cuadrado, es exactamente la línea de `bandAlarms`. Sin raíz y sin decimales.

> 🧭 **Por qué una función pura.** `oddsAudit` no sabe de dónde salen los conteos: de una bitácora del mock, de una consulta del backend, de una simulación en una prueba. Por eso la Fase 10 la prueba con un generador sembrado, y por eso `be07` puede devolver los conteos desde PostgreSQL y la consola los audita igual.

### 5.5 `reconciliationMath.js` — la conciliación de compras

```javascript
// Las cuentas de la conciliación de compras. Todo en centavos de dólar, enteros.
// Sin React, sin Redux, sin red: se prueban con una tabla de casos y nada más.

// Comisión de Google Play sobre las compras de la app: 15 % (en puntos básicos).
export const STORE_FEE_BP = 1500;

/**
 * Reparte un total en `parts` partes iguales SIN perder ni inventar un centavo.
 * División entera para todas, y el resto (siempre < parts) de a un centavo
 * para las primeras. 2.099 entre 500: 99 partes de 5 y 401 de 4.
 * @param {number} totalCents
 * @param {number} parts
 * @returns {number[]} su suma es exactamente totalCents
 */
export function prizeShare(totalCents, parts) {
  if (!Number.isInteger(totalCents) || !Number.isInteger(parts) || parts <= 0) {
    throw new Error("prizeShare requiere enteros y al menos una parte");
  }
  const base = Math.floor(totalCents / parts);
  const remainder = totalCents - base * parts;
  return Array.from({ length: parts }, (_, i) => base + (i < remainder ? 1 : 0));
}

/**
 * Cuánto del precio de un paquete corresponde a los giros que cayeron en cada
 * segmento. Prorratea por giro con prizeShare y suma por segmento, en el orden de
 * `counts`: las filas suman exactamente el precio del paquete.
 * @param {number} packagePriceCents
 * @param {number[]} counts - giros del paquete por segmento
 * @returns {number[]} centavos por segmento
 */
export function prorateSpinPrice(packagePriceCents, counts) {
  const spins = counts.reduce((sum, c) => sum + c, 0);
  const shares = prizeShare(packagePriceCents, spins);
  let next = 0;
  return counts.map((count) => {
    let cents = 0;
    for (let i = 0; i < count; i++) cents += shares[next++];
    return cents;
  });
}

/**
 * La comisión de la tienda sobre un cobro, redondeada al centavo más cercano
 * (la mitad, hacia arriba), sin floats: (c · 1.500 + 5.000) / 10.000, entero.
 * @param {number} chargedCents
 * @returns {number}
 */
export function storeFeeCents(chargedCents) {
  return Math.floor((chargedCents * STORE_FEE_BP + 5000) / 10000);
}

/**
 * Cruza las compras que el API acreditó con el reporte de la tienda.
 * @param {{ purchaseToken: string }[]} credited - colección purchases del API
 * @param {{ purchaseToken: string, chargedCents: number, feeCents: number }[]} storeRows - el reporte de ganancias
 * @returns {{
 *   matched: number,
 *   missingInApi: string[],    // la tienda cobró y el API no acreditó
 *   duplicatedInApi: string[], // el API acreditó más de una vez
 *   missingInStore: string[],  // el API acreditó algo que la tienda no cobró
 *   totals: { chargedCents: number, feeCents: number, netCents: number }
 * }}
 */
export function reconcilePurchases(credited, storeRows) {
  const creditedTimes = new Map();
  for (const { purchaseToken } of credited) {
    creditedTimes.set(purchaseToken, (creditedTimes.get(purchaseToken) || 0) + 1);
  }
  const inStore = new Set(storeRows.map((row) => row.purchaseToken));
  const totals = { chargedCents: 0, feeCents: 0, netCents: 0 };
  let matched = 0;
  const missingInApi = [];
  for (const row of storeRows) {
    totals.chargedCents += row.chargedCents;
    totals.feeCents += row.feeCents;
    if (creditedTimes.has(row.purchaseToken)) matched += 1;
    else missingInApi.push(row.purchaseToken);
  }
  totals.netCents = totals.chargedCents - totals.feeCents;
  const duplicatedInApi = [...creditedTimes].filter(([, times]) => times > 1).map(([token]) => token);
  const missingInStore = [...creditedTimes.keys()].filter((token) => !inStore.has(token));
  return { matched, missingInApi, duplicatedInApi, missingInStore, totals };
}
```

`prizeShare(2099, 500)` da 99 partes de 5 centavos y 401 de 4: un giro del paquete vale 4,198 centavos de media, y ningún giro puede valer eso. `prorateSpinPrice` reparte esas partes entre los segmentos en que cayeron los giros del paquete, y **sus filas suman 2.099**, sean cuales sean los conteos. La comisión se redondea al centavo más cercano con aritmética entera: 15 % de US$20,99 es 314,85 centavos, y se cobran 315.

> **El patrón a memorizar.** *"División entera para la parte, resto explícito repartido de a uno, y una aserción de que las partes suman el todo."* Si te llevas una sola cosa de esta fase, que sea esta. El incidente 18 es lo que pasa cuando alguien la cambia por "calcular cada fila y redondear".

### 5.6 El mock: la conciliación de una rueda y el reporte de la tienda

En el `3001`, una ruta propia, montada después del router de ruedas:

```javascript
// La conciliación de una rueda (puerto 3001, F08). Registrar la conciliación y pasar la
// rueda a reconciled es UNA operación: si fueran dos llamadas, una caída entre las dos
// dejaría una rueda conciliada sin registro, o un registro de una rueda que sigue abierta.
const express = require("express");

/**
 * @param {object} db - la base lowdb de json-server (router.db)
 */
function reconciliationRouter(db) {
  const router = express.Router();

  router.get("/wheels/:id/reconciliation", (req, res) => {
    const wheelId = Number(req.params.id);
    const record = db.get("reconciliations").find({ wheelId }).value();
    if (!record) return res.status(404).json({ error: `La rueda ${wheelId} no está conciliada.` });
    return res.json(record);
  });

  router.post("/wheels/:id/reconciliation", (req, res) => {
    const wheelId = Number(req.params.id);
    const wheel = db.get("wheels").find({ id: wheelId }).value();
    if (!wheel) return res.status(404).json({ error: `No existe la rueda ${wheelId}.` });
    // Solo se concilia una rueda terminada, y una sola vez: reconciled no tiene salida.
    if (wheel.status !== "ended") {
      return res.status(409).json({ error: `Solo se concilia una rueda terminada; esta está en "${wheel.status}".` });
    }
    const record = { ...req.body, wheelId, reconciledAt: new Date().toISOString() };
    db.get("reconciliations").push(record).write();
    db.get("wheels").find({ id: wheelId }).assign({ status: "reconciled" }).write();
    return res.status(201).json({ wheel: db.get("wheels").find({ id: wheelId }).value(), reconciliation: record });
  });

  return router;
}

module.exports = reconciliationRouter;
```

```javascript
server.use(wheelsSegmentsRouter(db)); // F04: ruedas con sus segmentos y sus reglas
server.use(reconciliationRouter(db)); // F08: conciliar una rueda terminada, en una sola operación
```

En el `3002`, el reporte de ganancias. En la tienda real es un archivo mensual que se descarga de la consola de Google Play; acá es una ruta que lee lo que dejó la siembra:

```javascript
// F08: el reporte de ganancias de la tienda, un renglón por cobro con su comisión.
// Lo escribe mock/seed-reconciliation.js; en la tienda real es un archivo mensual.
app.get("/earnings", (req, res) => {
  const file = path.join(__dirname, "earnings.json");
  res.json(fs.existsSync(file) ? JSON.parse(fs.readFileSync(file, "utf8")) : []);
});
```

### 5.7 El slice — `src/features/reconciliation/reconciliationSlice.js`

```javascript
import { createSlice, createAsyncThunk } from "@reduxjs/toolkit";
import apiClient from "../../api/apiClient";
import apiStore from "../../api/apiStore";
import { toReadableError } from "../../api/readableError";
import { countLanded, oddsAudit } from "./oddsAudit";
import { prorateSpinPrice, reconcilePurchases } from "./reconciliationMath";

/**
 * Carga todo lo que la conciliación de una rueda necesita y la calcula.
 * Las dos conciliaciones son funciones puras; el thunk solo junta los datos.
 * Las compras se cruzan de dos fuentes: lo que el API acreditó (3001) y lo que
 * la tienda cobró (3002). Si una sola fuente fuera la verdad, no habría qué conciliar.
 */
export const fetchReconciliation = createAsyncThunk("reconciliation/fetch", async (wheelId, { rejectWithValue }) => {
  try {
    const [segmentsRes, logRes, creditedRes, packagesRes, earningsRes] = await Promise.all([
      apiClient.get("/segments", { params: { wheelId } }),
      apiClient.get("/spinLog", { params: { wheelId } }),
      apiClient.get("/purchases"),
      apiClient.get("/packages"),
      apiStore.get("/earnings"),
    ]);
    const segments = segmentsRes.data;
    const spinLog = logRes.data;
    const counts = countLanded(spinLog, segments);
    const audit = oddsAudit(counts, segments.map((s) => s.weightBp));

    // El prorrateo de un paquete de 500: el primero que la bitácora consumió entero.
    const big = packagesRes.data.find((p) => p.productId === "spins-500");
    const spinsByToken = new Map();
    for (const row of spinLog) {
      if (row.purchaseToken) spinsByToken.set(row.purchaseToken, (spinsByToken.get(row.purchaseToken) || []).concat(row));
    }
    const token = creditedRes.data
      .filter((p) => p.productId === "spins-500")
      .map((p) => p.purchaseToken)
      .find((t) => (spinsByToken.get(t) || []).length === big.spins);
    const packageProration = token
      ? {
          purchaseToken: token,
          packagePriceCents: big.packagePriceCents,
          counts: countLanded(spinsByToken.get(token), segments),
          cents: prorateSpinPrice(big.packagePriceCents, countLanded(spinsByToken.get(token), segments)),
        }
      : null;

    return {
      wheelId,
      segments,
      counts,
      audit,
      purchases: reconcilePurchases(creditedRes.data, earningsRes.data),
      packageProration,
    };
  } catch (error) {
    return rejectWithValue(toReadableError(error));
  }
});

/**
 * Concilia la rueda: registra el resultado y la pasa de ended a reconciled en una sola
 * operación del servidor. No hay acción para deshacerlo.
 */
export const reconcileWheel = createAsyncThunk("reconciliation/reconcile", async (_, { getState, rejectWithValue }) => {
  const { wheelId, segments, counts, audit, purchases } = getState().reconciliation;
  try {
    const response = await apiClient.post(`/wheels/${wheelId}/reconciliation`, {
      spins: counts.reduce((sum, c) => sum + c, 0),
      counts,
      chi2: audit.chi2,
      chi2Alarm: audit.chi2Alarm,
      bandAlarms: audit.bandAlarms.map((i) => segments[i].segmentId),
      purchases: {
        ...purchases.totals,
        missingInApi: purchases.missingInApi,
        duplicatedInApi: purchases.duplicatedInApi,
      },
    });
    return response.data; // { wheel, reconciliation }
  } catch (error) {
    return rejectWithValue(toReadableError(error));
  }
});

const reconciliationSlice = createSlice({
  name: "reconciliation",
  initialState: {
    wheelId: null,
    segments: [],
    counts: [],
    audit: null,
    purchases: null,
    packageProration: null,
    record: null,
    loading: false,
    error: null,
  },
  reducers: {},
  extraReducers: (builder) => {
    builder
      .addCase(fetchReconciliation.pending, (state) => {
        state.loading = true;
        state.error = null;
        state.record = null;
      })
      .addCase(fetchReconciliation.fulfilled, (state, action) => {
        state.loading = false;
        Object.assign(state, action.payload);
      })
      .addCase(fetchReconciliation.rejected, (state, action) => {
        state.loading = false;
        state.error = action.payload;
      })
      .addCase(reconcileWheel.pending, (state) => {
        state.loading = true;
        state.error = null;
      })
      .addCase(reconcileWheel.fulfilled, (state, action) => {
        state.loading = false;
        state.record = action.payload.reconciliation;
      })
      .addCase(reconcileWheel.rejected, (state, action) => {
        state.loading = false;
        state.error = action.payload;
      });
  },
});

export const selectReconciliation = (state) => state.reconciliation;
export default reconciliationSlice.reducer;
```

El thunk `fetchReconciliation` junta cinco respuestas de dos servicios y calcula; el estado guarda **los conteos y los resultados**, no las 10.000 filas de la bitácora. Guardarlas en el store pondría a correr el `serializableCheck` y el `immutableCheck` de Toolkit sobre diez mil objetos en cada acción, y nadie las necesita después de contar.

Se registra en el store como los anteriores:

```javascript
    purchases: purchaseReducer, // Fase 7
    reconciliation: reconciliationReducer, // Fase 8
```

### 5.8 La transición en `wheelSlice`

```javascript
      // F08: la última transición, ended → reconciled. Solo desde ended, y no hay
      // ningún caso que saque de reconciled: esa ausencia ES la irreversibilidad.
      .addCase(reconcileWheel.fulfilled, (state, action) => {
        const wheel = state.items.find((w) => w.id === action.payload.wheel.id);
        if (wheel && wheel.status === "ended") wheel.status = "reconciled";
      });
```

> 💡 **Diseño: la transición escucha el thunk de otro slice.** `wheelSlice` importa `reconcileWheel` y reacciona a su `fulfilled`; `reconciliationSlice` no importa nada de `wheelSlice`. La dependencia va en un solo sentido, y por eso no hay un ciclo de imports.

### 5.9 La pantalla, la ruta y el navbar

```jsx
import React, { useEffect, useState } from "react";
import { useDispatch, useSelector } from "react-redux";
import { fetchWheels, selectWheels } from "../wheels/wheelSlice";
import { TOTAL_BP } from "../wheels/weightRules";
import { fetchReconciliation, reconcileWheel, selectReconciliation } from "./reconciliationSlice";
import { CHI2_CRITICAL_DF7_05 } from "./oddsAudit";
import { formatCents } from "./money";

// Solo para mostrar: el esperado y el desvío en sigmas tienen decimales. La decisión
// (dentro o fuera de la banda) ya la tomó oddsAudit con enteros; esto no decide nada.
function expectedOf(n, weightBp) {
  return (n * weightBp) / TOTAL_BP;
}
function sigmasOf(count, n, weightBp) {
  const p = weightBp / TOTAL_BP;
  return (count - n * p) / Math.sqrt(n * p * (1 - p));
}

// La conciliación de una rueda terminada: de probabilidades y de compras.
function ReconciliationPage() {
  const dispatch = useDispatch();
  const wheels = useSelector(selectWheels).filter((w) => w.status === "ended" || w.status === "reconciled");
  const { wheelId, segments, counts, audit, purchases, packageProration, record, loading, error } = useSelector(selectReconciliation);
  const [selected, setSelected] = useState("");

  useEffect(() => {
    dispatch(fetchWheels());
  }, [dispatch]);

  useEffect(() => {
    if (selected) dispatch(fetchReconciliation(Number(selected)));
  }, [dispatch, selected]);

  const wheel = wheels.find((w) => w.id === wheelId);
  const n = counts.reduce((sum, c) => sum + c, 0);

  return (
    <div className="container mt-4">
      <h2 className="mb-4">Conciliación</h2>
      <div className="form-group">
        <label htmlFor="wheel">Rueda</label>
        <select id="wheel" className="form-control" value={selected} onChange={(e) => setSelected(e.target.value)}>
          <option value="">Elige una rueda terminada</option>
          {wheels.map((w) => (
            <option key={w.id} value={w.id}>{w.name} ({w.status === "reconciled" ? "conciliada" : "terminada"})</option>
          ))}
        </select>
      </div>
      {loading && <p className="text-muted">Calculando…</p>}
      {error && <p className="text-danger">{error.message}</p>}

      {audit && (
        <>
          <h4>Probabilidades: {n} giros</h4>
          <table className="table table-sm">
            <thead>
              <tr><th>Segmento</th><th>Peso</th><th>Esperado</th><th>Observado</th><th>Desvío</th></tr>
            </thead>
            <tbody>
              {segments.map((s, i) => (
                <tr key={s.segmentId} className={audit.bandAlarms.includes(i) ? "table-danger" : ""}>
                  <td>{s.segmentId}</td>
                  <td>{(s.weightBp / 100).toFixed(2)} %</td>
                  <td>{expectedOf(n, s.weightBp).toFixed(1)}</td>
                  <td>{counts[i]}</td>
                  <td>{sigmasOf(counts[i], n, s.weightBp).toFixed(2)} σ{audit.bandAlarms.includes(i) && " · fuera de la banda"}</td>
                </tr>
              ))}
            </tbody>
          </table>
          <p>
            χ² = {audit.chi2.toFixed(2)} (crítico {CHI2_CRITICAL_DF7_05}, 7 grados, α = 0,05):{" "}
            {audit.chi2Alarm || audit.bandAlarms.length > 0 ? (
              <strong className="text-danger">la rueda no se comporta como sus pesos publicados.</strong>
            ) : (
              <strong className="text-success">sin alarmas.</strong>
            )}
          </p>
        </>
      )}

      {purchases && (
        <>
          <h4>Compras de agosto</h4>
          <p>
            Cobrado {formatCents(purchases.totals.chargedCents)} · comisión de la tienda{" "}
            {formatCents(purchases.totals.feeCents)} · neto {formatCents(purchases.totals.netCents)} ·{" "}
            {purchases.matched} cobros con su acreditación.
          </p>
          {purchases.missingInApi.length > 0 && (
            <p className="text-danger">La tienda cobró y el API no acreditó: {purchases.missingInApi.join(", ")}</p>
          )}
          {purchases.duplicatedInApi.length > 0 && (
            <p className="text-danger">El API acreditó más de una vez: {purchases.duplicatedInApi.join(", ")}</p>
          )}
          {purchases.missingInStore.length > 0 && (
            <p className="text-danger">El API acreditó algo que la tienda no cobró: {purchases.missingInStore.join(", ")}</p>
          )}
        </>
      )}

      {packageProration && (
        <>
          <h4>Prorrateo del paquete {packageProration.purchaseToken}</h4>
          <table className="table table-sm">
            <thead>
              <tr><th>Segmento</th><th>Giros</th><th>Del precio</th></tr>
            </thead>
            <tbody>
              {segments.map((s, i) => (
                <tr key={s.segmentId}>
                  <td>{s.segmentId}</td>
                  <td>{packageProration.counts[i]}</td>
                  <td>{formatCents(packageProration.cents[i])}</td>
                </tr>
              ))}
            </tbody>
          </table>
          <p>
            Suma de las filas {formatCents(packageProration.cents.reduce((sum, c) => sum + c, 0))} · precio del paquete{" "}
            {formatCents(packageProration.packagePriceCents)}
          </p>
        </>
      )}

      {wheel && wheel.status === "ended" && audit && (
        <button className="btn btn-primary" disabled={loading} onClick={() => dispatch(reconcileWheel())}>
          Conciliar rueda
        </button>
      )}
      {wheel && wheel.status === "reconciled" && (
        <p className="text-success">
          Rueda conciliada{record ? ` el ${record.reconciledAt}` : ""}. Esta operación no tiene vuelta atrás.
        </p>
      )}
    </div>
  );
}

export default ReconciliationPage;
```

`expectedOf` y `sigmasOf` tienen decimales, y está bien: son para mostrar. La decisión de qué fila se pinta en rojo ya la tomó `oddsAudit`, con enteros.

```jsx
          <PrivateRoute path="/purchases" component={PurchasesPage} />
          <PrivateRoute path="/reconciliation" component={ReconciliationPage} />
```

```jsx
        <NavLink className="nav-item nav-link" to="/reconciliation">
          Conciliación
        </NavLink>
```

### 5.10 Lo que da la corrida

Corrida del 16/10/2026, con la bitácora sembrada (semilla 42, 10.000 giros de la Rueda de fin de mes) y el reporte de agosto:

| Qué se audita | Conteos (sin-premio … esclusa-de-oro) | χ² | Bandas fuera |
|---|---|---|---|
| Regla nueva, por `landedSegment` | 3017 · 1962 · 1515 · 1483 · 1040 · 784 · 142 · 57 | 4,49 | ninguna |
| Regla nueva, por `deliveredPrize` | 3017 · 1962 · 505 · 2493 · 1040 · 823 · 104 · 56 | 1.335,29 | avatar-comun, set-gemas-basico, avatar-raro |
| Regla vieja (se acomoda) | 3404 · 2179 · 505 · 1704 · 1161 · 877 · 106 · 64 | 808,35 | seis de los ocho |

Con 300 semillas distintas, la rueda honesta dio alguna alarma en 17 corridas (5,7 %) y la que se acomoda, en las 300. Esa primera cifra no es un defecto de `oddsAudit`: es lo que la estadística promete, y A14 explica por qué.

Las compras de agosto: 40 cobros de la tienda por US$159,60, US$24,00 de comisión y US$135,60 netos; 39 con su acreditación, `tok-ago-31` cobrada y nunca acreditada, `tok-ago-17` acreditada dos veces. El paquete `tok-ago-05` cayó 148 · 95 · 71 · 74 · 57 · 38 · 13 · 4 veces en los ocho segmentos, y `prorateSpinPrice` le asigna 691 · 380 · 284 · 296 · 228 · 152 · 52 · 16 centavos: **2.099, exactos**.

### 💸 Deuda técnica declarada en esta fase

- **La consola baja la bitácora entera para contar.** 10.000 filas por la red para obtener ocho números. Se paga en `be07`, con la consulta agregada en el servidor (`GROUP BY wheel_version, landed_segment`), y la consola sigue llamando a `oddsAudit` igual.
- **La bitácora del laboratorio no guarda la versión de los pesos ni los segmentos elegibles** que pide la historia §9. Con una sola versión de pesos por rueda, no hace falta para auditar; hará falta el día que una rueda publique una versión nueva a mitad de un evento. → `be07`.
- **El reporte de la tienda se lee completo**, sin filtrar por mes ni por rueda. Con un mes alcanza.

---

## ⚠️ 6. Errores comunes y pieza forense

### Errores comunes

1. **Auditar el premio entregado en vez del segmento.** Síntoma: la rueda honesta da alarma, con el avatar común muy por debajo y el set de gemas básico muy por encima. Causa: se contó `deliveredPrize`, que incluye los sustitutos. Fix: `countLanded` cuenta `landedSegment`. La sección 5.10 tiene el número: χ² = 1.335 contra 4,49, con la misma bitácora.
2. **Calcular cada fila y redondear.** Síntoma: el prorrateo de un paquete suma un centavo de más o de menos, y no siempre: depende de cómo cayeron los giros. Causa: el precio por giro en dólares (0,04198) multiplicado por cada fila y redondeado. Fix: `prorateSpinPrice`, que reparte con `prizeShare`. Es el incidente 18.
3. **Tratar una alarma como una prueba de fraude.** Síntoma: alguien ve una sola banda en rojo y declara la rueda arreglada. Causa: olvidar que una rueda honesta da alguna alarma en más o menos una de cada veinte conciliaciones. Fix: una alarma abre una investigación —otra bitácora, más giros, el chi-cuadrado—, no cierra un caso (A14 §5).
4. **Conciliar contra una sola fuente.** Síntoma: "todo cuadra" y aun así hay un jugador que pagó y no recibió. Causa: se sumaron las compras del API y se compararon con el precio de catálogo, no con lo que la tienda cobró. Fix: cruzar por `purchaseToken` contra el reporte de la tienda.
5. **La comisión sobre el total.** Síntoma: la comisión de la consola no coincide con la del reporte, por unos centavos que crecen con el mes. Causa: el 15 % se calculó sobre el total cobrado, y la tienda lo cobra —y lo redondea— cobro por cobro. Con las compras de agosto: 15 % de US$159,60 son 2.394 centavos; la suma de las cuarenta comisiones del reporte, 2.400. Fix: la comisión se suma renglón por renglón, como la tienda, y se compara contra su renglón.

### Pieza forense de esta fase — una conciliación que no cuadra

La mecánica del bug de floats —cómo se ve, cómo se caza, la prueba que lo blinda— está en A10 §6. Acá va lo propio de esta fase: **qué capa auditas cuando una conciliación concreta no cuadra**. Las candidatas son cuatro, y se descartan en este orden porque cada una cuesta más que la anterior:

**1. El cálculo (funciones puras).** Corre `oddsAudit` o `prorateSpinPrice` en una consola de Node con los conteos exactos del reporte. Si el descuadre aparece ahí, terminaste: no es React, no es Redux, no es la red.

**2. Las entradas.** Si la función da bien, el problema son sus argumentos. ¿Los conteos salen de `landedSegment`? ¿Las compras acreditadas incluyen la duplicada, y el reporte, todos los cobros? En Redux DevTools, el `payload` del `reconciliation/fetch/fulfilled`.

**3. El estado.** ¿El slice guardó lo que el thunk calculó? Compara ese `payload` con `state.reconciliation`.

**4. La presentación.** ¿La pantalla muestra lo que hay en el store, o hace sus propias cuentas? `ReconciliationPage` hace dos, y las dos son de presentación; si una tercera decidiera algo, ese sería el lugar del bug.

**Ejercicio "rompe a propósito y observa".** Con los mocks parados, siembra la regla vieja:

```bash
node mock/seed-reconciliation.js --accommodating
# regla accommodating: 10000 giros en la rueda 4, 40 acreditaciones, 40 cobros de la tienda
```

Levanta los mocks, abre la conciliación de la Rueda de fin de mes, y mira: la tabla en rojo en seis segmentos, χ² = 808. Nadie cambió un peso. Lo que cambió es la regla con que se entregan los premios, y es exactamente lo que la reseña *"la rueda está arreglada"* intuía sin poder probarlo. Ahora mira la columna del avatar común: 505 contra 1.500 esperados. La rueda vieja se lo sacaba a los veteranos antes de girar. Vuelve a sembrar sin la bandera y compara.

> 🧠 **Lo que enseña ese contraste.** La rueda que se acomoda no rompía ningún peso configurado: los pesos de la consola eran verdad. Lo que no era verdad era la tabla del juego, porque la regla que la contradecía vivía en un solo lugar que nadie más veía (historia §5). Una conciliación de probabilidades no audita la configuración: audita **lo que pasó**.

> 📓 De esta fase sale el incidente **18** de `cuaderno-incidentes.md`.

---

## 🧪 7. Ejercicios (30)

**🟢 Fácil (1–8)**

1. Corre `npm run seed:reconciliation` dos veces y confirma con `git diff --stat mock/db.json` que la segunda no cambió nada. Explica en una línea qué parte del script lo garantiza.
2. Llama a `toCents` con `"20.99"`, `"20,99"`, `"0.5"` y `"20.999"`. **Criterio:** 2099, 2099, 50 y un error; explica por qué el último no se redondea.
3. Llama a `formatCents(2099)` y a `formatCents(4.198)`. **Criterio:** `"US$20,99"` y un error; ubica en el código la línea que lo lanza.
4. Calcula `prizeShare(2099, 500)` y cuenta cuántas partes valen 5. **Criterio:** 99, y la suma es 2.099.
5. Con la consola, concilia la Rueda de fin de mes y copia los ocho conteos de la tabla. **Criterio:** coinciden con la primera fila de §5.10.
6. Confirma en Network que la conciliación le pide `/earnings` al `3002` y el resto al `3001`. **Criterio:** al elegir la rueda salen cinco peticiones, y una sola va al `3002`.
7. Concilia la rueda y confirma en Redux DevTools que su `status` pasó a `reconciled` y que el botón desapareció.
8. Intenta conciliarla otra vez con `curl -X POST localhost:3001/wheels/4/reconciliation` (con el token). **Criterio:** `409`, y el mensaje dice en qué estado está.

**🟡 Intermedio (9–17)**

9. Escribe una prueba de `storeFeeCents` para 99, 100, 2099 y 0. **Criterio:** 15, 15, 315 y 0, y la prueba explica el caso de 99 (14,85).
10. Cambia `countLanded` para que cuente `deliveredPrize` y concilia. **Criterio:** reproduces el error común #1 con las tres bandas de §5.10; vuelve a dejarlo como estaba.
11. Escribe una prueba de `reconcilePurchases` con tres compras acreditadas y tres cobros, una de cada clase de descuadre. **Criterio:** cada lista tiene exactamente un token.
12. Agrega a la pantalla la cantidad de giros que la compra `tok-ago-17` le dio al jugador. **Criterio:** 20, contados en la bitácora, y explicas por qué no son 10.
13. Intenta conciliar la Esclusa de Oro (la rueda 1, `live`) desde la consola, despachando `reconcileWheel` a mano con su `wheelId` en el estado. **Criterio:** el mock responde `409`, el reducer no la toca, y el error se ve en pantalla.
14. Calcula a mano la banda de ±3σ de la Esclusa de Oro con 10.000 giros (A14 §3) y compárala con la condición entera de `oddsAudit`. **Criterio:** los dos dan alarma para 72 y no para 71.
15. Siembra con la semilla 7 en vez de 42 y concilia. **Criterio:** χ² de 8,02, sin alarma; anota los conteos.
16. Documenta en un comentario, sobre `reconcileWheel`, la diferencia entre la corrección mínima (la guarda en el reducer) y la garantía real (la operación única del mock).
17. Muestra en la tabla de probabilidades el peso en porcentaje y el esperado sin decimales cuando son enteros. **Criterio:** la decisión de la alarma no cambia; explica por qué.

**🟠 Difícil (18–24)**

18. Reproduce el error común #2: escribe la versión que calcula cada fila en dólares y redondea, conéctala a la pantalla, y encuentra el paquete de la bitácora que descuadra. **Criterio:** `tok-ago-05` suma 2.100; prueba los otros tres paquetes de 500 y explica por qué uno cuadra y otro da 2.098.
19. Diagnostica: *"la rueda quedó `reconciled` y no hay registro de conciliación"*. Formula la hipótesis (dos llamadas en vez de una) y demuestra por qué con la ruta del mock no puede pasar.
20. Escribe una prueba que genere 50 bitácoras honestas con semillas distintas y verifique que `oddsAudit` no da alarma en más de 8. **Criterio:** la prueba es determinista (semillas fijas), y explicas por qué el límite no puede ser cero (A14 §5).
21. Haz que el reporte de la tienda traiga un cobro con `feeCents` distinto del que calcula `storeFeeCents`, y agrega a `reconcilePurchases` la lista de esas diferencias. **Criterio:** la pantalla la muestra, y la prueba del ejercicio 11 sigue pasando.
22. Mide cuánto tarda `fetchReconciliation` con la bitácora de 10.000 giros y con una de 100.000 (cambia `SPINS`). **Criterio:** tabla con las dos medidas, en el Profiler o con `performance.now()`, y una frase sobre cuándo deja de servir contar en el navegador.
23. Encuentra el bug: un compañero escribió `const fee = Math.round(chargedCents * 0.15)`. Encuentra un precio en centavos donde da distinto de `storeFeeCents`, o demuestra que no existe uno entre 1 y 100.000.
24. Diagnostica una conciliación que cayó en el `malformed` del caos de la Fase 3: ¿la rueda quedó conciliada o no? **Criterio:** reproduces con `CHAOS_LEVEL=high`, y explicas qué capa te lo dijo.

**🔴 Muy difícil (25–30)**

25. Extiende la siembra para que la Rueda de fin de mes publique una **versión nueva de pesos** a mitad del mes, y haz que `oddsAudit` concilie cada versión por separado. **Criterio:** la bitácora guarda la versión, y conciliar las dos versiones juntas da alarma aunque cada una por separado no.
26. Escribe una prueba de propiedad: para cualquier precio entero y cualquier conjunto de conteos que sumen al menos 1, `prorateSpinPrice` devuelve filas que suman exactamente el precio. **Criterio:** que falle si alguien cambia `prizeShare` por una división con floats.
27. Documenta como incidente completo (ocho puntos, sin culpables) el descuadre de `tok-ago-17`: síntoma en la conciliación, reproducción, evidencia en la bitácora, causa raíz (la notificación duplicada), corrección (del lado del backend), regresión, prevención y post-mortem.
28. Diseña —sin implementarla— la **anulación** de una conciliación que respete la irreversibilidad: no un "deshacer", sino un registro nuevo y auditado. Documenta qué estado necesitaría la rueda y por qué no puede volver a `ended`.
29. Calcula cuántos giros hacen falta para que la regla vieja dé alarma en la **banda de la Esclusa de Oro** y no solo en el chi-cuadrado. **Criterio:** una tabla de tamaños de bitácora contra tasa de alarma, con la simulación sembrada.
30. Correlación de punta a punta: cruza la compra `tok-ago-31` con la Fase 7 —su polling, su confirmación tardía— y arma el procedimiento reproducible que lleva del ticket de Yariela (*"ya pagué y no me llegaron los giros"*) a la fila roja de la conciliación.

**🔥 Opcionales**

- 🔥 Evalúa `dinero.js` o `big.js` para el dinero de la consola: compara su API con los enteros nativos de `money.js`, y justifica si vale una dependencia en este stack. No la integres sin esa justificación.
- 🔥 Haz que la conciliación de probabilidades acepte cualquier número de segmentos: el valor crítico de chi-cuadrado depende de los grados de libertad. **Criterio:** una tabla de valores críticos citada, y la rueda de ocho segmentos sigue dando lo mismo.
- 🔥 Exporta la conciliación a CSV con los montos en centavos y en dólares, y verifica que reimportarla da los mismos enteros.

---

## 📚 8. Referencias

**Del curso** (léelo primero)
- `A10-aritmetica-de-dinero.md` — floats, redondeo, `money.js`, el reparto sin perder centavos y cómo se caza el bug.
- `A14-estadistica-para-auditar-una-rueda.md` — la binomial, la banda de ±3σ, el chi-cuadrado, la tasa de falsas alarmas y cuánta muestra hace falta.

**Documentación oficial**
- https://redux-toolkit.js.org/api/createAsyncThunk — `createAsyncThunk` y `rejectWithValue` (RTK 1.8.6, la versión fijada).
- https://redux-toolkit.js.org/api/serializabilityMiddleware — por qué el store no guarda la bitácora entera.
- https://support.google.com/googleplay/android-developer/answer/112622 — las comisiones de Google Play sobre las compras dentro de la app. El 15 % aplica al primer millón de dólares de ingresos de cada año; desde el 30/06/2026 hay un esquema nuevo en EE. UU., el Reino Unido y el Espacio Económico Europeo, que en Latinoamérica llega después.
- https://support.google.com/googleplay/android-developer/answer/9858738 — la política de Google Play sobre artículos aleatorios: las probabilidades se publican antes de la compra.

**Orden de lectura sugerido:** A10 §1–§4 → A14 §1–§4 → `oddsAudit.js` y `reconciliationMath.js` con las pruebas en la otra pantalla → la pieza forense.

> ⚠️ Las URL y los contenidos pueden haber cambiado desde la redacción; verifícalos. Las comisiones de las tiendas están cambiando en 2026: antes de usar el 15 % en una cuenta de verdad, confirma el que aplica a tu país y a tu volumen.

---

## 🚀 9. Cierre y conexión con la siguiente fase

Con esto el ciclo de una rueda se cierra de punta a punta: nace en `draft`, se publica, gira en `live`, cierra a hora exacta en `ended` y —ahora— se **concilia** de forma definitiva. La consola hizo sus primeras cuentas de dinero sin un float en el camino, y contestó con números una pregunta que la tienda le hace al estudio desde 2025. La transición a `reconciled` es irreversible no por una regla de interfaz, sino porque el reducer no escribe ninguna salida y el mock no tiene ruta de vuelta.

La Fase 9 construye el **Dashboard**: toma estas conciliaciones —ruedas, compras, frecuencias— y las pone en una sola pantalla con gráficos, incluida la banda de ±3σ de cada segmento. Y aparece el costo de mostrar mucho: lo que en una tabla de ocho filas no se nota, en un tablero que se recalcula con cada acción, sí.

> **La señal de que quedó bien:** siembras la regla vieja y la consola la señala; siembras la nueva y no; y el paquete de 500 giros suma 2.099 centavos en cualquier bitácora que le pongas delante.

> 🏷️ **No cierres la fase sin el tag.** Con el checklist de la sección 2 en verde y `git status` limpio:
>
> ```bash
> git tag -a fase-08-conciliacion -m "F8 cerrada: <el checklist, en una línea por ítem>"
> ```
>
> Los commits de la fase llevan su prefijo (`f08: …`) y los de ejercicio su número (`f08 ej17: …`). Si un ejercicio merece su propio marcador va en `ej/f08/17`, y un incidente resuelto en el par `inc/<ID>/<slug>-roto` / `-fix`, con el ID que le reserva `cuaderno-incidentes.md`. Todo eso está en [`00-convencion-de-git-y-tags.md`](00-convencion-de-git-y-tags.md).
>
> Y si vas a seguir con el track BE opcional 🔥 —que se puede empezar acá—, este es el commit que lleva además `git tag pre-backend-go`: el estado del frontend que `be03` tiene que dejar intacto.

---

## 📌 Pendientes sugeridos

> Material de autoría, no de lectura. Va acá abajo, fuera de la plantilla de nueve secciones, porque es lo que apareció al escribir la fase y no cabía adentro — y porque no debe competir con el cierre.

- **La conciliación en el servidor** queda para `be07`. Cuando exista, la consola debería dejar de bajar la bitácora y pedir los conteos; la pantalla no cambia.
- **"Concilié con una alarma"** no tiene incidente propio. Es el error común #3 y vale uno; si se escribe, toma un ID nuevo, nunca uno reasignado.

### Reservas para el cuaderno de incidentes

Los IDs quedan reservados en `cuaderno-incidentes.md`, donde el enunciado ya está redactado con sus pistas y su solución de referencia. El ID nunca se reasigna.

- **18** — *La conciliación da un centavo de diferencia* · Dinero · 🟠. Sale del error común #2: el prorrateo del paquete de 500 calculado por fila en dólares y redondeado. El síntoma es de un centavo; la causa es estructural, y esa desproporción es la lección.
