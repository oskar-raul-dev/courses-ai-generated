// Prueba de F02 en copia de zz-code (no va al curso): contra el mock real (json-server + middleware).
import React from "react";
import ReactDOM from "react-dom";
import { act } from "react-dom/test-utils";
import { store } from "./app/store";
import { login, logout } from "./features/auth/authSlice";
import apiClient from "./api/apiClient";
import AppRouter from "./AppRouter";
import { Provider } from "react-redux";

test("login con credenciales malas deja el mensaje legible y token null", async () => {
  await store.dispatch(login({ email: "ibatista@esclusa.test", password: "mal" }));
  expect(store.getState().auth.error).toBe("Email o contraseña incorrectos");
  expect(store.getState().auth.token).toBeNull();
});

test("login correcto guarda user y token, sin password", async () => {
  await store.dispatch(login({ email: "ibatista@esclusa.test", password: "esclusa123" }));
  const { auth } = store.getState();
  expect(auth.token).toBe("tok_ibatista_3c7e");
  expect(auth.user).toEqual({ id: 1, email: "ibatista@esclusa.test", name: "Itzel Batista" });
  expect(JSON.stringify(auth)).not.toContain("esclusa123");
});

test("las requests salen con Bearer y el mock devuelve X-Request-Id", async () => {
  const r = await apiClient.get("/users");
  expect(r.config.headers.Authorization).toBe("Bearer tok_ibatista_3c7e");
  expect(r.headers["x-request-id"]).toMatch(/^[0-9a-f]{8}$/);
});

test("logout limpia el store y la próxima request sale sin Authorization", async () => {
  store.dispatch(logout());
  expect(store.getState().auth.token).toBeNull();
  const r = await apiClient.get("/users", { params: { id: 1 } });
  expect(r.config.headers.Authorization).toBeUndefined();
});

test("sin sesión, /wheels redirige a /login; /login es pública", () => {
  store.dispatch(logout());
  const container = document.createElement("div");
  document.body.appendChild(container);
  window.history.pushState({}, "", "/wheels");
  act(() => {
    ReactDOM.render(<Provider store={store}><AppRouter /></Provider>, container);
  });
  expect(window.location.pathname).toBe("/login");
  expect(container.querySelector("h1").textContent).toBe("Iniciar sesión");
  ReactDOM.unmountComponentAtNode(container);
});
