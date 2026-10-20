// Ejemplos de A10, todos con su número, contra el money.js y el reconciliationMath.js de la F08.
import { toCents, formatCents } from "../features/reconciliation/money";
import { prizeShare, prorateSpinPrice } from "../features/reconciliation/reconciliationMath";

// §1 — lo que un float no puede representar
test("§1: los floats de siempre", () => {
  expect(0.1 + 0.2).toBe(0.30000000000000004);
  expect(1.005 * 100).toBe(100.49999999999999);
  expect(20.99 / 500).toBe(0.041979999999999996);
});

// §2 — el redondeo: sumar 500 veces el precio por giro en float
test("§2: 500 giros de 20,99/500 en float no suman 20,99", () => {
  let total = 0;
  for (let i = 0; i < 500; i++) total += 20.99 / 500;
  expect(total).toBe(20.98999999999994);
  expect(Math.floor(total * 100)).toBe(2098); // un centavo menos
  expect(Math.round(total * 100)).toBe(2099); // Math.round lo "salva", por esta vez
});

// §3 — la frontera
test("§3: toCents y formatCents", () => {
  expect(toCents("20.99")).toBe(2099);
  expect(toCents("20,99")).toBe(2099);
  expect(parseFloat("5000.10") * 100).toBe(500010.00000000006);
  expect(toCents("5000.10")).toBe(500010);
  expect(() => toCents("20.999")).toThrow();
  expect(formatCents(2099)).toBe("US$20,99");
  expect(formatCents(1596000)).toBe("US$15.960,00");
  expect(() => formatCents(4.198)).toThrow();
});

// §4 — repartir sin perder ni inventar centavos
test("§4: el paquete de 500 giros", () => {
  const shares = prizeShare(2099, 500);
  expect(shares.filter((c) => c === 5)).toHaveLength(99);
  expect(shares.reduce((a, b) => a + b, 0)).toBe(2099);
  expect(prizeShare(100, 3)).toEqual([34, 33, 33]);
  // los giros del paquete tok-ago-05, por segmento (bitácora sembrada de la F08)
  const counts = [148, 95, 71, 74, 57, 38, 13, 4];
  expect(prorateSpinPrice(2099, counts)).toEqual([691, 380, 284, 296, 228, 152, 52, 16]);
  // la versión que calcula cada fila en dólares y redondea
  const rows = counts.map((c) => Math.round(c * (20.99 / 500) * 100));
  expect(rows.reduce((a, b) => a + b, 0)).toBe(2100);
});

// §1 — micros: la unidad de los reportes de anuncios y de los precios de Google Play
// (patrón de consulta: esta función no está en la consola)
function microsToCents(micros) {
  if (!Number.isInteger(micros)) throw new Error(`microsToCents espera un entero, recibió: ${micros}`);
  return Math.floor((micros + 5000) / 10000); // al centavo más cercano, la mitad hacia arriba
}
test("§1: micros a centavos, y por qué se suma en micros", () => {
  expect(microsToCents(20990000)).toBe(2099); // el precio del paquete: exacto
  expect(microsToCents(6500000)).toBe(650);
  const day = [1234400, 2344400, 3454400]; // tres renglones de un reporte de anuncios
  const roundedEach = day.map(microsToCents).reduce((a, b) => a + b, 0);
  const roundedOnce = microsToCents(day.reduce((a, b) => a + b, 0));
  expect(roundedEach).toBe(702); // 123 + 234 + 345
  expect(roundedOnce).toBe(703); // 7.033.200 micros = 703,32 centavos
});

// §5 — migrar un sistema que guardaba dólares en float
test("§5: migrar por el texto encuentra las filas que ya venían corruptas", () => {
  const stored = [20.99, 0.99, 20.98999999999994];
  const migrated = stored.map((amount) => {
    try {
      return toCents(String(amount));
    } catch (error) {
      return null; // a revisar a mano: no se adivina
    }
  });
  expect(migrated).toEqual([2099, 99, null]);
  expect(stored.map((amount) => Math.round(amount * 100))).toEqual([2099, 99, 2099]); // las esconde
});
