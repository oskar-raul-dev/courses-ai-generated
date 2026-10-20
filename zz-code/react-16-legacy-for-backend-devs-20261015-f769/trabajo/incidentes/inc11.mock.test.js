// Incidente 11 contra el mock real (copia de zz-code): el registro de envíos del mock, después del doble clic.
import axios from "axios";
test("doble clic: el mock registra una sola compensación del caso", async () => {
  jest.resetModules();
  const { store } = require("../app/store");
  const { queueGrant, sendGrant } = require("../features/grants/grantSlice");
  const grant = store.dispatch(queueGrant({ player: { id: 42, name: "Juan P." }, caseId: "C-2210", prize: "vidas-5", reason: "caída" }));
  await Promise.all([store.dispatch(sendGrant(grant.id)), store.dispatch(sendGrant(grant.id))]);
  const { data } = await axios.get("http://localhost:3001/grants", { params: { caseId: "C-2210", playerId: 42 } });
  expect(data.length).toBe(1); // con el bug: 2
});
