// Integración de F07 con los dos mocks reales (copia de zz-code; no va al curso). PLAY_PENDING_MS=3000.
import axios from "axios";
const PLAY = "http://localhost:3002";
const wait = (ms) => new Promise((r) => setTimeout(r, ms));
function fresh() {
  jest.resetModules();
  return {
    store: require("../app/store").store,
    auth: require("../features/auth/authSlice"),
    purchases: require("../features/purchases/purchaseSlice"),
    grants: require("../features/grants/grantSlice"),
    wheels: require("../features/wheels/wheelSlice"),
  };
}

test("una compra en efectivo pendiente se confirma por polling, y el polling termina", async () => {
  const { store, auth, purchases } = fresh();
  await axios.post(`${PLAY}/purchases`, { purchaseToken: "tok-efecty-1", method: "cash" });
  await store.dispatch(auth.login({ email: "ypinzon@esclusa.test", password: "esclusa123" }));
  store.dispatch(purchases.startPolling("tok-efecty-1"));
  await wait(1000);
  expect(store.getState().purchases.byToken["tok-efecty-1"].state).toBe("pending");
  await wait(4500);
  expect(store.getState().purchases.byToken["tok-efecty-1"].state).toBe("confirmed");
  expect(store.getState().purchases.pollingToken).toBeNull();
}, 15000);

test("el logout corta el polling: el 3002 no recibe consultas sin sesión", async () => {
  const { store, auth, purchases } = fresh();
  await axios.post(`${PLAY}/purchases`, { purchaseToken: "tok-oxxo-2", method: "cash" });
  await store.dispatch(auth.login({ email: "ypinzon@esclusa.test", password: "esclusa123" }));
  store.dispatch(purchases.startPolling("tok-oxxo-2"));
  await wait(2500);
  store.dispatch(auth.logout());
  await wait(6000); // con el leak, acá saldrían tres consultas más (log del 3002: «sin sesión»)
  expect(store.getState().purchases.byToken["tok-oxxo-2"].state).toBe("pending");
}, 15000);

test("un giro en la rueda abierta sale; en la que cerró el 30/08 a las 20:00, se rechaza", async () => {
  const { store, auth, grants, wheels } = fresh();
  await store.dispatch(auth.login({ email: "ibatista@esclusa.test", password: "esclusa123" }));
  await store.dispatch(wheels.fetchWheels());
  const open = store.dispatch(grants.grantQueued({ player: { id: 42, name: "Juan P." }, caseId: "C-G1", prize: "spin:1", reason: "caída" })).payload;
  const closed = store.dispatch(grants.grantQueued({ player: { id: 42, name: "Juan P." }, caseId: "C-G2", prize: "spin:4", reason: "caída" })).payload;
  store.dispatch(grants.sendGrantRequested(open.id));
  store.dispatch(grants.sendGrantRequested(closed.id));
  await wait(1500);
  expect(store.getState().grants.byId[open.id]).toMatchObject({ status: "sent", confirmed: true });
  expect(store.getState().grants.byId[closed.id]).toMatchObject({ status: "failed", error: { type: "closed" } });
}, 10000);
