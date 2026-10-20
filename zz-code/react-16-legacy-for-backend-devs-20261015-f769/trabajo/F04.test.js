// Pruebas de F04 (copia de zz-code; no va al curso). Corren contra el mock real (3001), en serie.
import axios from "axios";
import { validateWeights, canEditWeights, sumWeights } from "../features/wheels/weightRules";
import { toReadableError } from "../api/readableError";

const API = "http://localhost:3001";
const seg = (w, i = 0) => ({ segmentId: "s" + i, prizeType: "none", weightBp: w });
const EIGHT = [3000, 2000, 1500, 1500, 1000, 800, 150, 50].map((w, i) => seg(w, i));

describe("reglas de pesos", () => {
  test("suma exacta 10.000 es válida", () => {
    expect(validateWeights([seg(5000, 1), seg(5000, 2)])).toEqual([]);
    expect(sumWeights(EIGHT)).toBe(10000);
  });
  test("9.999 y 10.001 se rechazan", () => {
    expect(validateWeights([seg(9999)]).join(" ")).toMatch(/suman 9999/);
    expect(validateWeights([seg(10001)]).join(" ")).toMatch(/suman 10001/);
  });
  test("no enteros, cero y negativos se rechazan", () => {
    expect(validateWeights([seg(1.5, 1), seg(9998.5, 2)]).join(" ")).toMatch(/entero/);
    expect(validateWeights([seg(0, 1), seg(10000, 2)]).join(" ")).toMatch(/0 o menos/);
    expect(validateWeights([seg(-5, 1), seg(10005, 2)]).join(" ")).toMatch(/0 o menos/);
  });
  test("rueda en vivo: no se editan pesos; nueva o programada, sí", () => {
    expect(canEditWeights({ status: "live" })).toBe(false);
    expect(canEditWeights({ status: "scheduled" })).toBe(true);
    expect(canEditWeights(null)).toBe(true);
  });
});

describe("error legible", () => {
  test("timeout, 5xx, 4xx con regla y desconocido", () => {
    expect(toReadableError({ code: "ECONNABORTED" }).type).toBe("timeout");
    expect(toReadableError({ response: { status: 503, data: { error: "caos: 503 simulado" } } }).message).toBe(
      "El servidor tuvo un problema. Intenta de nuevo."
    );
    expect(toReadableError({ response: { status: 422, data: { error: "Los pesos suman 9999 y deben sumar 10000." } } }).message).toMatch(/suman 9999/);
    expect(toReadableError(new Error("boom"))).toEqual({ message: "boom", type: "unknown" });
  });
});

describe("mock de ruedas", () => {
  test("POST válido crea la rueda con sus ocho segmentos (201)", async () => {
    const { status, data } = await axios.post(`${API}/wheels`, { name: "Prueba", closesAt: "2026-12-20T20:00:00-05:00", segments: EIGHT });
    expect(status).toBe(201);
    expect(data.status).toBe("draft");
    expect(data.segments.length).toBe(8);
  });
  test("POST con suma 9.999 responde 422 y no crea nada", async () => {
    const before = (await axios.get(`${API}/wheels`)).data.length;
    const err = await axios.post(`${API}/wheels`, { name: "Mala", closesAt: "x", segments: [seg(9999)] }).catch((e) => e);
    expect(err.response.status).toBe(422);
    expect((await axios.get(`${API}/wheels`)).data.length).toBe(before);
  });
  test("PUT de pesos sobre la rueda en vivo responde 409", async () => {
    const { data: wheel } = await axios.get(`${API}/wheels/1`, { params: { _embed: "segments" } });
    const changed = wheel.segments.map((s, i) => (i === 0 ? { ...s, weightBp: s.weightBp - 1 } : i === 1 ? { ...s, weightBp: s.weightBp + 1 } : s));
    const err = await axios.put(`${API}/wheels/1`, { ...wheel, segments: changed }).catch((e) => e);
    expect(err.response.status).toBe(409);
    expect(err.response.data.error).toMatch(/en vivo/);
  });
  test("PUT sobre la rueda en vivo sin tocar pesos sí guarda el nombre", async () => {
    const { data: wheel } = await axios.get(`${API}/wheels/1`, { params: { _embed: "segments" } });
    const { data } = await axios.put(`${API}/wheels/1`, { ...wheel, name: "Esclusa de Oro (fin de mes)" });
    expect(data.name).toBe("Esclusa de Oro (fin de mes)");
  });
  test("PUT válido en rueda programada guarda los pesos nuevos", async () => {
    const { data: wheel } = await axios.get(`${API}/wheels/2`, { params: { _embed: "segments" } });
    const changed = wheel.segments.map((s, i) => (i === 0 ? { ...s, weightBp: 2900 } : i === 1 ? { ...s, weightBp: 2100 } : s));
    const { data } = await axios.put(`${API}/wheels/2`, { ...wheel, segments: changed });
    expect(sumWeights(data.segments)).toBe(10000);
    expect(data.segments[0].weightBp).toBe(2900);
  });
  test("DELETE borra la rueda y sus segmentos; sobre una inexistente, 404", async () => {
    await axios.delete(`${API}/wheels/3`);
    const { data: segments } = await axios.get(`${API}/segments`, { params: { wheelId: 3 } });
    expect(segments).toEqual([]);
    const err = await axios.delete(`${API}/wheels/999`).catch((e) => e);
    expect(err.response.status).toBe(404);
  });
});

describe("wheelSlice contra el mock", () => {
  const load = () => {
    jest.resetModules();
    const apiClient = require("../api/apiClient").default;
    const { store } = require("../app/store");
    const slice = require("../features/wheels/wheelSlice");
    return { apiClient, store, slice };
  };

  test("fetch trae las ruedas con sus segmentos y apaga loadingList", async () => {
    const { store, slice } = load();
    await store.dispatch(slice.fetchWheels());
    const { items, loadingList, error } = store.getState().wheels;
    expect(error).toBeNull();
    expect(loadingList).toBe(false);
    expect(items.length).toBeGreaterThanOrEqual(2);
    expect(items.every((w) => Array.isArray(w.segments))).toBe(true);
  });
  test("respuesta malformada: error 'malformed', lista vacía, sin TypeError", async () => {
    const { apiClient, store, slice } = load();
    apiClient.defaults.adapter = (config) => Promise.resolve({ data: '{"data": [1, 2', status: 200, statusText: "OK", headers: {}, config });
    await store.dispatch(slice.fetchWheels());
    expect(store.getState().wheels.error).toEqual({ message: "La respuesta de ruedas vino con forma inesperada.", type: "malformed" });
    expect(store.getState().wheels.items).toEqual([]);
  });
  test("503: el rejected apaga loadingList y deja un mensaje legible", async () => {
    const { apiClient, store, slice } = load();
    apiClient.defaults.adapter = (config) => {
      const err = new Error("Request failed with status code 503");
      err.config = config;
      err.response = { status: 503, headers: {}, config, data: { error: "caos: 503 simulado" } };
      return Promise.reject(err);
    };
    await store.dispatch(slice.fetchWheels());
    expect(store.getState().wheels.loadingList).toBe(false);
    expect(store.getState().wheels.error.message).toBe("El servidor tuvo un problema. Intenta de nuevo.");
  });
  test("crear, editar (sale del modo edición) y borrar actualizan items sin re-fetch", async () => {
    const { store, slice } = load();
    await store.dispatch(slice.fetchWheels());
    const created = await store.dispatch(slice.createWheel({ name: "Rueda nueva", closesAt: "2026-12-30T20:00:00-05:00", segments: EIGHT }));
    const id = created.payload.id;
    expect(store.getState().wheels.items.some((w) => w.id === id)).toBe(true);
    store.dispatch(slice.selectWheelToEdit(id));
    expect(slice.selectEditingWheel(store.getState()).name).toBe("Rueda nueva");
    await store.dispatch(slice.updateWheel({ ...created.payload, name: "Rueda editada" }));
    expect(store.getState().wheels.editingId).toBeNull();
    expect(store.getState().wheels.items.find((w) => w.id === id).name).toBe("Rueda editada");
    await store.dispatch(slice.deleteWheel(id));
    expect(store.getState().wheels.items.some((w) => w.id === id)).toBe(false);
  });
  test("editar pesos de la rueda en vivo: el 409 llega como error legible con la regla", async () => {
    const { store, slice } = load();
    await store.dispatch(slice.fetchWheels());
    const live = store.getState().wheels.items.find((w) => w.status === "live");
    const changed = live.segments.map((s, i) => (i === 0 ? { ...s, weightBp: s.weightBp - 1 } : i === 1 ? { ...s, weightBp: s.weightBp + 1 } : s));
    await store.dispatch(slice.updateWheel({ ...live, segments: changed }));
    expect(store.getState().wheels.error.message).toMatch(/en vivo/);
    expect(store.getState().wheels.loadingMutation).toBe(false);
  });
});
