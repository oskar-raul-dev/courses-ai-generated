// Pruebas de F03 (copia de zz-code; no va al curso): pagos #1 y #2, y el mensaje de los 5xx.
import { history } from "./app/history";

beforeEach(() => {
  localStorage.clear();
  jest.resetModules();
});

test("pago #1: la sesión se guarda al loguear y sobrevive a recargar el módulo (F5)", async () => {
  const { store } = require("./app/store");
  const { login } = require("./features/auth/authSlice");
  await store.dispatch(login({ email: "ibatista@esclusa.test", password: "esclusa123" }));
  expect(JSON.parse(localStorage.getItem("esclusa.auth")).token).toBe("tok_ibatista_3c7e");

  jest.resetModules(); // simula recargar la página: el store se construye de nuevo
  const recargado = require("./app/store").store;
  expect(recargado.getState().auth.token).toBe("tok_ibatista_3c7e");
  expect(recargado.getState().auth.user.name).toBe("Itzel Batista");
});

test("pago #1: logout borra la sesión del storage y del estado", async () => {
  const { store } = require("./app/store");
  const { login, logout } = require("./features/auth/authSlice");
  await store.dispatch(login({ email: "ibatista@esclusa.test", password: "esclusa123" }));
  store.dispatch(logout());
  expect(localStorage.getItem("esclusa.auth")).toBeNull();
  expect(store.getState().auth.token).toBeNull();
});

test("pago #1: basura en el storage no rompe el arranque", () => {
  localStorage.setItem("esclusa.auth", "{no es json");
  const { store } = require("./app/store");
  expect(store.getState().auth.token).toBeNull();
});

test("pago #2: un 401 cierra la sesión y manda a /login", async () => {
  const { store } = require("./app/store");
  const apiClient = require("./api/apiClient").default; // la misma instancia que tiene los interceptores
  const { history } = require("./app/history"); // el mismo history que usa el store
  const { login } = require("./features/auth/authSlice");
  await store.dispatch(login({ email: "ibatista@esclusa.test", password: "esclusa123" }));
  history.push("/wheels");

  apiClient.defaults.adapter = (config) => {
    const err = new Error("Request failed with status code 401");
    err.config = config;
    err.response = { status: 401, headers: {}, config };
    return Promise.reject(err);
  };
  await expect(apiClient.get("/players/42/grants")).rejects.toBeTruthy();
  expect(store.getState().auth.token).toBeNull();
  expect(history.location.pathname).toBe("/login");
  expect(localStorage.getItem("esclusa.auth")).toBeNull();
});

test("un 5xx del mock muestra un mensaje legible, no el de axios", async () => {
  const { store } = require("./app/store");
  const apiClient = require("./api/apiClient").default;
  const { login } = require("./features/auth/authSlice");
  apiClient.defaults.adapter = (config) => {
    const err = new Error("Request failed with status code 503");
    err.config = config;
    err.response = { status: 503, headers: {}, config };
    return Promise.reject(err);
  };
  await store.dispatch(login({ email: "ibatista@esclusa.test", password: "esclusa123" }));
  expect(store.getState().auth.error).toBe("El servidor tuvo un problema. Intenta de nuevo.");
});
