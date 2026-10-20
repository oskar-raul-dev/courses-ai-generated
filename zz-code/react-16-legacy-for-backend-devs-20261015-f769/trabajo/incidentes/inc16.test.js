// Incidente 16 (copia de zz-code; la misma prueba que publica el cuaderno). Se corre con TZ=America/Panama.
import { isWheelClosed } from "../features/wheels/closing";

test("una rueda que cerró el 30/08 a las 20:00 sigue cerrada un 15/10 a las 10:00", () => {
  const wheel = { id: 4, status: "live", closesAt: "2026-08-30T20:00:00-05:00" };
  const now = Date.parse("2026-10-15T10:00:00-05:00");
  expect(isWheelClosed(wheel, now)).toBe(true); // con el bug: false (10 < 20, y la fecha no cuenta)
});
