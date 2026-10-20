// Prueba de regresión del incidente 11 (copia de zz-code). Corre contra el mock real.
import axios from "axios";
import { store } from "../app/store";
import { queueGrant } from "../features/grants/grantSlice";

jest.setTimeout(30000);

test("dos operadores no compensan dos veces el mismo caso", async () => {
  const motivo = `compensación ${Date.now()}`; // motivo único por corrida
  await store.dispatch(queueGrant({ id: 301, playerId: 42, reason: motivo, prize: "vidas-2" }));
  await store.dispatch(queueGrant({ id: 302, playerId: 42, reason: motivo, prize: "vidas-2" }));
  await new Promise((resolve) => setTimeout(resolve, 10500));
  const { data } = await axios.get("http://localhost:3001/grants", { params: { playerId: 42 } });
  expect(data.filter((g) => g.reason === motivo).length).toBe(1);
}, 30000);
