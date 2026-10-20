// Integración de F06 contra el mock real (copia de zz-code; no va al curso). En serie, con tiempos reales.
import axios from "axios";
const API = "http://localhost:3001";
const wait = (ms) => new Promise((r) => setTimeout(r, ms));

function fresh() {
  jest.resetModules();
  const { store } = require("../app/store");
  const grants = require("../features/grants/grantSlice");
  const auth = require("../features/auth/authSlice");
  const apiClient = require("../api/apiClient").default;
  return { store, grants, auth, apiClient };
}

test("doble clic con las épicas: un solo registro en el mock", async () => {
  const { store, grants, auth } = fresh();
  await store.dispatch(auth.login({ email: "ibatista@esclusa.test", password: "esclusa123" }));
  const { payload } = store.dispatch(grants.grantQueued({ player: { id: 42, name: "Juan P." }, caseId: "C-I1", prize: "vidas-5", reason: "caída" }));
  store.dispatch(grants.sendGrantRequested(payload.id));
  store.dispatch(grants.sendGrantRequested(payload.id));
  await wait(1500);
  expect(store.getState().grants.byId[payload.id]).toMatchObject({ status: "sent", confirmed: true });
  const { data } = await axios.get(`${API}/grants`, { params: { caseId: "C-I1" } });
  expect(data.length).toBe(1);
}, 10000);

test("la ventana de 10 s: lo deshecho no sale, lo demás sale solo", async () => {
  const { store, grants, auth } = fresh();
  await store.dispatch(auth.login({ email: "ibatista@esclusa.test", password: "esclusa123" }));
  const a = store.dispatch(grants.grantQueued({ player: { id: 42, name: "Juan P." }, caseId: "C-I2", prize: "vidas-5", reason: "caída" })).payload;
  const b = store.dispatch(grants.grantQueued({ player: { id: 43, name: "María R." }, caseId: "C-I2", prize: "vidas-5", reason: "caída" })).payload;
  store.dispatch(grants.undoGrant(b.id));
  await wait(11500);
  expect(store.getState().grants.byId[a.id]).toMatchObject({ status: "sent", confirmed: true });
  expect(store.getState().grants.byId[b.id].status).toBe("reverted");
  const { data } = await axios.get(`${API}/grants`, { params: { caseId: "C-I2" } });
  expect(data.map((x) => x.playerId)).toEqual([42]);
}, 20000);

test("búsqueda: «Ana» trae a Ana (suspendida) y a Anaís", async () => {
  const { store, grants, auth } = fresh();
  await store.dispatch(auth.login({ email: "ibatista@esclusa.test", password: "esclusa123" }));
  store.dispatch(grants.playerSearchRequested("Ana"));
  await wait(800);
  const names = store.getState().grants.playerSearch.results.map((p) => `${p.name}:${p.status}`);
  expect(names).toEqual(["Ana:banned", "Anaís:active"]);
}, 10000);

test("el leak de la fase: tras el logout, el refresco de compras sigue pidiendo, sin token", async () => {
  const { store, auth, apiClient } = fresh();
  const afterLogout = [];
  let loggedOut = false;
  apiClient.interceptors.request.use((config) => {
    if (loggedOut && config.url === "/purchases") afterLogout.push(config.headers.Authorization || "sin token");
    return config;
  });
  await store.dispatch(auth.login({ email: "ibatista@esclusa.test", password: "esclusa123" }));
  store.dispatch({ type: "START_PURCHASES_REFRESH" });
  await wait(5500);
  store.dispatch(auth.logout());
  loggedOut = true;
  await wait(10500);
  expect(afterLogout).toEqual(["sin token", "sin token"]); // el mock los cuenta en su log: «[3001] sin sesión»
}, 25000);
