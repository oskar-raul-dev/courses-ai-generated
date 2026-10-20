// Render de la pantalla de conciliación contra los dos mocks (copia de zz-code; no va al curso).
import React from "react";
import { render, screen, fireEvent, waitFor } from "@testing-library/react";
import { Provider } from "react-redux";
import { store } from "../app/store";
import { login } from "../features/auth/authSlice";
import ReconciliationPage from "../features/reconciliation/ReconciliationPage";

test("la pantalla muestra las dos conciliaciones de la rueda 4 y la concilia", async () => {
  await store.dispatch(login({ email: "mdegracia@esclusa.test", password: "esclusa123" }));
  render(<Provider store={store}><ReconciliationPage /></Provider>);
  await waitFor(() => expect(screen.getByRole("option", { name: /Rueda de fin de mes \(terminada\)/ })).toBeInTheDocument());
  fireEvent.change(screen.getByLabelText("Rueda"), { target: { value: "4" } });
  await waitFor(() => expect(screen.getByText(/sin alarmas/)).toBeInTheDocument(), { timeout: 10000 });
  expect(screen.getByText("Probabilidades: 10000 giros")).toBeInTheDocument();
  expect(screen.getByText(/Cobrado US\$159,60 · comisión de la tienda US\$24,00 · neto US\$135,60 · 39 cobros/)).toBeInTheDocument();
  expect(screen.getByText(/La tienda cobró y el API no acreditó: tok-ago-31/)).toBeInTheDocument();
  expect(screen.getByText(/El API acreditó más de una vez: tok-ago-17/)).toBeInTheDocument();
  expect(screen.getByText("Prorrateo del paquete tok-ago-05")).toBeInTheDocument();
  expect(screen.getByText(/Suma de las filas US\$20,99 · precio del paquete US\$20,99/)).toBeInTheDocument();
  fireEvent.click(screen.getByText("Conciliar rueda"));
  await waitFor(() => expect(screen.getByText(/Esta operación no tiene vuelta atrás/)).toBeInTheDocument());
  expect(screen.queryByText("Conciliar rueda")).toBeNull();
}, 30000);
