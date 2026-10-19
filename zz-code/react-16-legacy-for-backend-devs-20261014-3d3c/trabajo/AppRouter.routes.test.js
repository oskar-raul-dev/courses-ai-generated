// Prueba de F01 en copia de zz-code (no va al curso): las rutas y la navegación sin recarga.
import React from "react";
import ReactDOM from "react-dom";
import { act } from "react-dom/test-utils";
import AppRouter from "./AppRouter";

let container;
beforeEach(() => {
  container = document.createElement("div");
  document.body.appendChild(container);
});
afterEach(() => {
  ReactDOM.unmountComponentAtNode(container);
  container.remove();
});

function irA(path) {
  // BrowserRouter escucha popstate, no pushState: se desmonta antes de cambiar la URL.
  ReactDOM.unmountComponentAtNode(container);
  window.history.pushState({}, "", path);
  act(() => {
    ReactDOM.render(<AppRouter />, container);
  });
}

test("la raíz redirige a /wheels y muestra las tres ruedas", () => {
  irA("/");
  expect(window.location.pathname).toBe("/wheels");
  expect(container.textContent).toContain("Esclusa de Oro");
  expect(container.querySelectorAll(".wheel-card").length).toBe(3);
});

test("/wheels/1 muestra el detalle; /wheels/999 dice que no existe", () => {
  irA("/wheels/1");
  expect(container.querySelector("h1").textContent).toBe("Esclusa de Oro");
  expect(container.textContent).toContain("En vivo");
  expect(container.querySelectorAll(".wheel-card").length).toBe(0); // no se apila el listado
  irA("/wheels/999");
  expect(container.textContent).toContain("No existe la rueda #999");
});

test("/players, /bitacora y /dashboard son placeholders con su título", () => {
  irA("/players");
  expect(container.querySelector("h1").textContent).toBe("Jugadores");
  irA("/bitacora");
  expect(container.querySelector("h1").textContent).toBe("Bitácora");
  irA("/dashboard");
  expect(container.querySelector("h1").textContent).toBe("Dashboard");
});

test("una URL inexistente cae en el 404 y dice cuál fue", () => {
  irA("/cualquier-cosa");
  expect(container.textContent).toContain("404");
  expect(container.textContent).toContain("/cualquier-cosa");
});

test("clic en una tarjeta navega al detalle sin recargar el navbar", () => {
  irA("/wheels");
  const navAntes = container.querySelector("nav");
  act(() => {
    container.querySelectorAll(".wheel-card")[1].click();
  });
  expect(window.location.pathname).toBe("/wheels/2");
  expect(container.querySelector("h1").textContent).toBe("Semana del Canal");
  expect(container.querySelector("nav")).toBe(navAntes); // mismo nodo: no se recargó
});
