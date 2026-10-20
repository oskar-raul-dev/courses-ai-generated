// Incidente 19 (copia de zz-code; la misma prueba que publica el cuaderno). Contra los dos mocks,
// con la Semana del Canal sembrada (--event, 180.000 giros). chart.js simulado: jsdom no pinta canvas.
import React from "react";
import { render, screen, fireEvent, waitFor } from "@testing-library/react";
import { Provider } from "react-redux";
import { store } from "../app/store";
import { login } from "../features/auth/authSlice";
import DashboardPage from "../features/dashboard/DashboardPage";
import { selectSpinSummary } from "../features/dashboard/dashboardSelectors";

jest.mock("chart.js", () =>
  class FakeChart {
    constructor(ctx, config) { this.data = config.data; }
    update() {}
    destroy() {}
  }
);
HTMLCanvasElement.prototype.getContext = () => ({});

test("con la bitácora de un evento, cambiar el origen no vuelve a recorrerla", async () => {
  await store.dispatch(login({ email: "ibatista@esclusa.test", password: "esclusa123" }));
  render(<Provider store={store}><DashboardPage /></Provider>);
  await waitFor(() => expect(screen.getByRole("option", { name: "Semana del Canal" })).toBeInTheDocument());
  fireEvent.change(screen.getByLabelText("Rueda"), { target: { value: "2" } });
  await waitFor(() => expect(screen.getByText("180000")).toBeInTheDocument(), { timeout: 30000 });
  const passes = selectSpinSummary.recomputations();
  for (const origin of ["free", "paid", "all", "free", "paid"]) {
    fireEvent.change(screen.getByLabelText("Origen de los giros"), { target: { value: origin } });
  }
  expect(passes).toBe(1); // una pasada por bitácora cargada
  expect(selectSpinSummary.recomputations()).toBe(passes); // con el bug: el tablero ni usa el selector
}, 60000);
