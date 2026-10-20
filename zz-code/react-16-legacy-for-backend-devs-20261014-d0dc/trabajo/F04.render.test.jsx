// Pruebas de render de F04 (copia de zz-code; no va al curso). Sin red: el store se arma a mano.
import React from "react";
import { render, screen, fireEvent } from "@testing-library/react";
import { Provider } from "react-redux";
import { MemoryRouter } from "react-router-dom";
import { configureStore } from "@reduxjs/toolkit";
import wheelReducer from "../features/wheels/wheelSlice";
import WheelTable from "../features/wheels/WheelTable";
import WheelForm from "../features/wheels/WheelForm";

const segments = [3000, 2000, 1500, 1500, 1000, 800, 150, 50].map((w, i) => ({ segmentId: "s" + i, prizeType: "none", weightBp: w }));
const wheels = [
  { id: 1, name: "Esclusa de Oro", closesAt: "2026-10-31T20:00:00-05:00", status: "live", timezone: "America/Panama", segments },
  { id: 2, name: "Semana del Canal", closesAt: "2026-08-15T20:00:00-05:00", status: "scheduled", timezone: "America/Panama", segments },
];
function renderWith(ui, wheelsState) {
  const store = configureStore({
    reducer: { wheels: wheelReducer },
    preloadedState: { wheels: { items: [], loadingList: false, loadingMutation: false, error: null, editingId: null, ...wheelsState } },
  });
  // Los thunks (el fetch de componentDidMount) no salen a la red en esta prueba: se descartan.
  const originalDispatch = store.dispatch;
  store.dispatch = (action) => (typeof action === "function" ? Promise.resolve() : originalDispatch(action));
  render(<Provider store={store}><MemoryRouter>{ui}</MemoryRouter></Provider>);
  return store;
}

test("tabla: cargando", () => {
  renderWith(<WheelTable />, { loadingList: true });
  expect(screen.getByText("Cargando ruedas…")).toBeInTheDocument();
});
test("tabla: error con Reintentar", () => {
  renderWith(<WheelTable />, { error: { message: "El servidor tardó demasiado. Reintenta.", type: "timeout" } });
  expect(screen.getByRole("alert")).toHaveTextContent("El servidor tardó demasiado");
  expect(screen.getByText("Reintentar")).toBeInTheDocument();
});
test("tabla: vacía", () => {
  renderWith(<WheelTable />, {});
  expect(screen.getByText(/No hay ruedas todavía/)).toBeInTheDocument();
});
test("tabla: lista con etiqueta de estado en español", () => {
  renderWith(<WheelTable />, { items: wheels });
  expect(screen.getByText("Esclusa de Oro")).toBeInTheDocument();
  expect(screen.getByText("En vivo")).toBeInTheDocument();
  expect(screen.getByText("Programada")).toBeInTheDocument();
});
test("formulario: rueda nueva arranca sumando 10.000 y avisa si la suma se rompe", () => {
  renderWith(<WheelForm />, {});
  expect(screen.getByText("Suma: 10000 de 10000 pb.")).toBeInTheDocument();
  fireEvent.change(screen.getByLabelText("Peso de sin-premio"), { target: { value: "2999" } });
  expect(screen.getByText("Los pesos suman 9999 y deben sumar 10000.")).toBeInTheDocument();
  expect(screen.getByText("Crear rueda")).toBeDisabled();
});
test("formulario: la rueda en vivo no deja tocar los pesos", () => {
  renderWith(<WheelForm />, { items: wheels, editingId: 1 });
  expect(screen.getByLabelText("Peso de s0")).toBeDisabled();
  expect(screen.getByText(/En vivo: los pesos no se cambian/)).toBeInTheDocument();
});
test("formulario: el submit no recarga la página (preventDefault)", () => {
  renderWith(<WheelForm />, {});
  fireEvent.change(screen.getByLabelText("Nombre"), { target: { value: "Rueda de prueba" } });
  fireEvent.change(screen.getByLabelText("Cierre (ISO, con offset)"), { target: { value: "2026-12-20T20:00:00-05:00" } });
  const form = screen.getByText("Nueva rueda").closest("form");
  const event = new Event("submit", { bubbles: true, cancelable: true });
  form.dispatchEvent(event);
  expect(event.defaultPrevented).toBe(true);
});
