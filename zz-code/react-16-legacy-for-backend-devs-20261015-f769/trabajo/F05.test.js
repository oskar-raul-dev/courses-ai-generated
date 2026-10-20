// Pruebas de F05 (copia de zz-code; no va al curso). Sin red salvo el bloque del mock (3001), en serie.
import axios from "axios";

const API = "http://localhost:3001";
const JUAN = { id: 42, name: "Juan P." };
const MARIA = { id: 43, name: "María R." };

// Store nuevo por prueba, con un adapter de axios que registra los POST y contesta lo que se le pida.
function setup(reply = () => ({ status: 201, data: {} })) {
  jest.resetModules();
  const apiClient = require("../api/apiClient").default;
  const { store } = require("../app/store");
  const grants = require("../features/grants/grantSlice");
  const posts = [];
  apiClient.defaults.adapter = (config) => {
    posts.push(JSON.parse(config.data));
    const { status, data } = reply(JSON.parse(config.data), posts.length);
    if (status >= 400) {
      const err = new Error(`Request failed with status code ${status}`);
      err.config = config;
      err.response = { status, data, headers: {}, config };
      return Promise.reject(err);
    }
    return Promise.resolve({ status, data, headers: {}, config, statusText: "OK" });
  };
  const byId = (id) => store.getState().grants.byId[id];
  return { store, grants, posts, byId };
}
const flush = () => new Promise((resolve) => setTimeout(resolve, 0));

describe("máquina de estados", () => {
  test("reverted es terminal y sent solo vuelve atrás a failed", () => {
    const { ALLOWED_TRANSITIONS } = require("../features/grants/grantSlice");
    expect(ALLOWED_TRANSITIONS.reverted).toEqual([]);
    expect(ALLOWED_TRANSITIONS.sent).toEqual(["failed"]);
    expect(ALLOWED_TRANSITIONS.queued).toEqual(["sending", "reverted"]);
  });
});

describe("ventana de deshacer (tiempos reales)", () => {
  test("deshacer dentro de la ventana no manda nada; sin tocar, sale solo a los 10 s", async () => {
    const { store, grants, posts, byId } = setup();
    const kept = store.dispatch(grants.queueGrant({ player: JUAN, caseId: "C-1", prize: "vidas-5", reason: "caída" }));
    const undone = store.dispatch(grants.queueGrant({ player: MARIA, caseId: "C-1", prize: "vidas-5", reason: "caída" }));
    store.dispatch(grants.undoGrant(undone.id));
    expect(byId(undone.id).status).toBe("reverted");
    expect(byId(kept.id).status).toBe("queued");
    await new Promise((resolve) => setTimeout(resolve, 10500));
    await flush();
    expect(posts.length).toBe(1);
    expect(posts[0].grantId).toBe(kept.id);
    expect(byId(kept.id)).toMatchObject({ status: "sent", confirmed: true });
    expect(byId(undone.id).status).toBe("reverted");
  }, 15000);
});

describe("envío optimista, guarda de origen y rollback", () => {
  test("al enviar, se pinta 'sent' antes de la respuesta; con el 201 queda confirmado", async () => {
    const { store, grants, byId } = setup();
    const g = store.dispatch(grants.queueGrant({ player: JUAN, caseId: "C-2", prize: "vidas-2", reason: "error de cobro" }));
    const pending = store.dispatch(grants.sendGrant(g.id));
    expect(byId(g.id)).toMatchObject({ status: "sent", confirmed: false });
    await pending;
    expect(byId(g.id)).toMatchObject({ status: "sent", confirmed: true });
  });
  test("doble clic en 'Enviar ahora': sale una sola petición (incidente 11)", async () => {
    const { store, grants, posts } = setup();
    const g = store.dispatch(grants.queueGrant({ player: JUAN, caseId: "C-3", prize: "vidas-5", reason: "caída" }));
    await Promise.all([store.dispatch(grants.sendGrant(g.id)), store.dispatch(grants.sendGrant(g.id))]);
    expect(posts.length).toBe(1);
  });
  test("el 409 del masivo deja fallido su envío y no toca el individual confirmado (incidente 12)", async () => {
    const { store, grants, byId } = setup((body, n) =>
      n === 1 ? { status: 201, data: body } : { status: 409, data: { error: "Ese caso ya fue compensado para este jugador." } }
    );
    const g1 = store.dispatch(grants.queueGrant({ player: JUAN, caseId: "C-2210", prize: "vidas-5", reason: "caída" }));
    await store.dispatch(grants.sendGrant(g1.id));
    const g7 = store.dispatch(grants.queueGrant({ player: JUAN, caseId: "C-2210", prize: "vidas-5", reason: "caída (masivo)" }));
    await store.dispatch(grants.sendAllQueued());
    expect(byId(g1.id)).toMatchObject({ status: "sent", confirmed: true });
    expect(byId(g7.id).status).toBe("failed");
    expect(byId(g7.id).error).toEqual({ message: "Ese caso ya fue compensado para este jugador.", type: "conflict" });
  });
  test("un 503 hace rollback a 'failed'; reintentar lo vuelve a mandar; descartar lo deja deshecho", async () => {
    const { store, grants, posts, byId } = setup((body, n) => (n === 1 ? { status: 503, data: {} } : { status: 201, data: body }));
    const g = store.dispatch(grants.queueGrant({ player: MARIA, caseId: "C-4", prize: "avatar-comun", reason: "caída" }));
    await store.dispatch(grants.sendGrant(g.id));
    expect(byId(g.id).status).toBe("failed");
    expect(byId(g.id).error.message).toBe("El servidor tuvo un problema. Intenta de nuevo.");
    await store.dispatch(grants.sendGrant(g.id));
    expect(byId(g.id)).toMatchObject({ status: "sent", confirmed: true, error: null });
    expect(posts.length).toBe(2);
    const h = store.dispatch(grants.queueGrant({ player: MARIA, caseId: "C-5", prize: "avatar-comun", reason: "caída" }));
    store.dispatch(grants.grantSent({ grantId: h.id })); // sin pasar por sending: se ignora
    expect(byId(h.id).status).toBe("queued");
    store.dispatch(grants.undoGrant(h.id));
    store.dispatch(grants.discardGrant(h.id)); // reverted es terminal: no pasa nada
    expect(byId(h.id).status).toBe("reverted");
  });
  test("'Enviar todos ahora' manda solo lo que sigue en cola", async () => {
    const { store, grants, posts } = setup();
    const a = store.dispatch(grants.queueGrant({ player: JUAN, caseId: "C-6", prize: "vidas-2", reason: "caída" }));
    const b = store.dispatch(grants.queueGrant({ player: MARIA, caseId: "C-6", prize: "vidas-2", reason: "caída" }));
    store.dispatch(grants.undoGrant(b.id));
    await store.dispatch(grants.sendAllQueued());
    expect(posts.map((p) => p.grantId)).toEqual([a.id]);
  });
});

describe("ruta de envíos del mock", () => {
  test("sin motivo, 422; jugador inexistente, 404", async () => {
    const e1 = await axios.post(`${API}/players/42/grants`, { grantId: "t-1", caseId: "X", prize: "vidas-2", reason: " " }).catch((e) => e);
    expect(e1.response.status).toBe(422);
    const e2 = await axios.post(`${API}/players/999/grants`, { grantId: "t-2", caseId: "X", prize: "vidas-2", reason: "r" }).catch((e) => e);
    expect(e2.response.status).toBe(404);
  });
  test("el mismo caso más tarde: 409", async () => {
    const first = await axios.post(`${API}/players/42/grants`, { grantId: "t-3", caseId: "C-9", prize: "vidas-2", reason: "r" });
    expect(first.status).toBe(201);
    const again = await axios.post(`${API}/players/42/grants`, { grantId: "t-4", caseId: "C-9", prize: "vidas-2", reason: "r" }).catch((e) => e);
    expect(again.response.status).toBe(409);
  });
  test("el mismo caso dos veces a la vez: el chequeo no es atómico y pasan los dos", async () => {
    const send = (grantId) => axios.post(`${API}/players/43/grants`, { grantId, caseId: "C-10", prize: "vidas-2", reason: "r" });
    const [a, b] = await Promise.all([send("t-5"), send("t-5")]);
    expect([a.status, b.status]).toEqual([201, 201]);
    const { data } = await axios.get(`${API}/grants`, { params: { caseId: "C-10", playerId: 43 } });
    expect(data.length).toBe(2);
  });
});
