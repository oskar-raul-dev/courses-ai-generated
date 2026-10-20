// Pruebas de F04 (copia de zz-code; no va al curso). Corren contra el mock real (3001).
import axios from "axios";
import { validateWeights, canEditWeights } from "./features/wheels/weightRules";

const seg = (w) => ({ segmentId: "s" + w, prizeType: "none", weightBp: w });

test("pesos: suma exacta 10.000 es válida", () => {
  expect(validateWeights([seg(5000), seg(5000)])).toEqual([]);
});
test("pesos: suma 9.999 y 10.001 se rechazan", () => {
  expect(validateWeights([seg(9999)]).join(" ")).toMatch(/suman 9999/);
  expect(validateWeights([seg(10001)]).join(" ")).toMatch(/suman 10001/);
});
test("pesos: no enteros, cero y negativos se rechazan", () => {
  expect(validateWeights([seg(1.5), seg(9998.5)]).join(" ")).toMatch(/entero/);
  expect(validateWeights([seg(0), seg(10000)]).join(" ")).toMatch(/0 o menos/);
  expect(validateWeights([seg(-5), seg(10005)]).join(" ")).toMatch(/0 o menos/);
});
test("rueda en vivo: no se editan pesos", () => {
  expect(canEditWeights({ status: "live" })).toBe(false);
  expect(canEditWeights({ status: "scheduled" })).toBe(true);
});

test("mock: PUT sobre rueda en vivo responde 409", async () => {
  const err = await axios.put("http://localhost:3001/wheels/1/segments", { segments: [seg(10000)] }).catch((e) => e);
  expect(err.response.status).toBe(409);
});
test("mock: PUT con suma 9.999 responde 422 y no guarda", async () => {
  const err = await axios.put("http://localhost:3001/wheels/2/segments", { segments: [seg(9999)] }).catch((e) => e);
  expect(err.response.status).toBe(422);
  expect(err.response.data.error).toMatch(/suman 9999/);
});
test("mock: PUT válido en rueda programada guarda y devuelve los segmentos", async () => {
  const pesos = [3000, 2000, 1500, 1500, 1000, 800, 150, 50];
  const segs = pesos.map((w, i) => ({ segmentId: "x" + i, prizeType: "none", weightBp: w }));
  const { data } = await axios.put("http://localhost:3001/wheels/2/segments", { segments: segs });
  expect(data.map((s) => s.weightBp).reduce((a, b) => a + b, 0)).toBe(10000);
});

test("slice: respuesta mal formada se convierte en error legible", async () => {
  jest.resetModules();
  const apiClient = require("./api/apiClient").default;
  const { store } = require("./app/store");
  const { fetchWheels } = require("./features/wheels/wheelSlice");
  apiClient.defaults.adapter = (config) =>
    Promise.resolve({ data: { no: "es una lista" }, status: 200, statusText: "OK", headers: {}, config });
  await store.dispatch(fetchWheels());
  expect(store.getState().wheels.error).toBe("La respuesta del servidor no tiene el formato esperado.");
  expect(store.getState().wheels.items).toEqual([]);
});

test("slice: la lista real trae ruedas con sus segmentos", async () => {
  jest.resetModules();
  const apiClient = require("./api/apiClient").default;
  delete apiClient.defaults.adapter;
  const { store } = require("./app/store");
  const { fetchWheels } = require("./features/wheels/wheelSlice");
  await store.dispatch(fetchWheels());
  const { items, error } = store.getState().wheels;
  expect(error).toBeNull();
  expect(items.length).toBe(3);
  expect(items[0].segments.length).toBe(8);
});
